﻿-- TE4 - T-Engine 4
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org

require "engine.krtrUtils"
require "engine.class"

--- Handles actors stats
module(..., package.seeall, class.make)

_M.talents_def = {}
_M.talents_types_def = {}

--- Defines actor talents
-- Static!
function _M:loadDefinition(file, env)
	local f, err = util.loadfilemods(file, setmetatable(env or {
		DamageType = require("engine.DamageType"),
		Particles = require("engine.Particles"),
		Talents = self,
		Map = require("engine.Map"),
		newTalent = function(t) self:newTalent(t) end,
		newTalentType = function(t) self:newTalentType(t) end,
		load = function(f) self:loadDefinition(f, getfenv(2)) end
	}, {__index=_G}))
	if not f and err then error(err) end
	f()
end

--- Defines one talent type(group)
-- Static!
function _M:newTalentType(t)
	assert(t.name, "no talent type name")
	assert(t.type, "no talent type type")
	t.description = t.description or ""
	t.points = t.points or 1
	t.talents = {}
	table.insert(self.talents_types_def, t)
	self.talents_types_def[t.type] = t
end

--- Defines one talent
-- Static!
function _M:newTalent(t)
	assert(t.name, "no talent name")
	assert(t.type, "no or unknown talent type")
	if type(t.type) == "string" then t.type = {t.type, 1} end
	if not t.type[2] then t.type[2] = 1 end
	t.short_name = t.short_name or t.name
	t.short_name = t.short_name:upper():gsub("[ ']", "_")
	t.mode = t.mode or "activated"
	t.points = t.points or 1
	assert(t.mode == "activated" or t.mode == "sustained" or t.mode == "passive", "wrong talent mode, requires either 'activated' or 'sustained'")
	assert(t.info, "no talent info")

	-- Can pass a string, make it into a function
	if type(t.info) == "string" then
		local infostr = t.info
		t.info = function() return infostr end
	end
	-- Remove line stat with tabs to be cleaner ..
	local info = t.info
	t.info = function(self, t) return info(self, t):gsub("\n\t+", "\n") end

	t.id = "T_"..t.short_name
	self.talents_def[t.id] = t
	assert(not self[t.id], "talent already exists with id T_"..t.short_name)
	self[t.id] = t.id
--	print("[TALENT]", t.name, t.short_name, t.id)

	-- Register in the type
	table.insert(self.talents_types_def[t.type[1]].talents, t)
end

--- Initialises stats with default values if needed
function _M:init(t)
	self.talents = t.talents or {}
	self.talents_types = t.talents_types or {}
	self.talents_types_mastery = self.talents_types_mastery  or {}
	self.talents_cd = self.talents_cd or {}
	self.sustain_talents = self.sustain_talents or {}
	self.talents_auto = self.talents_auto or {}
	self.talents_confirm_use = self.talents_confirm_use or {}
	self.talents_learn_vals = t.talents_learn_vals or {}
end

--- Resolve leveling talents
function _M:resolveLevelTalents()
	if not self.start_level or not self._levelup_talents then return end
	for tid, info in pairs(self._levelup_talents) do
		if not info.max or (self.talents[tid] or 0) < info.max then
			local last = info.last or self.start_level
			if self.level - last >= info.every then
				self:learnTalent(tid, true)
				info.last = self.level
			end
		end
	end
end

-- Make the actor use the talent
-- @param id talent ID
-- @param who talent user
-- @param force_level talent level(raw) override 
-- @param ignore_cd do not affect or consider cooldown
-- @param force_target the target of the talent (override)
-- @param silent do not display messages about use
-- @param no_confirm  Never ask confirmation
function _M:useTalent(id, who, force_level, ignore_cd, force_target, silent, no_confirm)
	who = who or self
	local ab = _M.talents_def[id]
	assert(ab, "trying to cast talent "..tostring(id).." but it is not defined")

	local cancel = false
	if ab.mode == "activated" and ab.action then
		if self:isTalentCoolingDown(ab) and not ignore_cd then
			game.logPlayer(who, "%s 아직 대기 시간이 %d 턴 만큼 남아있습니다.", (ab.kr_name or ab.name):capitalize():addJosa("는"), self.talents_cd[ab.id])
			return
		end
		local co = coroutine.create(function()
			if cancel then
				success = false
				return false
			end
			if not self:preUseTalent(ab, silent) then return end
			local old_level
			local old_target
			
			if force_level then old_level = who.talents[id]; who.talents[id] = force_level end
			if force_target then old_target = rawget(who, "getTarget"); who.getTarget = function(a) return force_target.x, force_target.y, not force_target.__no_self and force_target end end
			self.__talent_running = ab
			local ok, ret = xpcall(function() return ab.action(who, ab) end, debug.traceback)
			self.__talent_running = nil
			if force_target then who.getTarget = old_target end
			if force_level then who.talents[id] = old_level end

			if not ok then error(ret) end

			if not self:postUseTalent(ab, ret, silent) then return end

			-- Everything went ok? then start cooldown if any
			if not ignore_cd then self:startTalentCooldown(ab) end
		end)
		local success, err
		if not no_confirm and self:isTalentConfirmable(ab) then
			local abname = game:getGenericTextTiles(ab)..(ab.kr_name or ab.name):addJosa("를") --@@ 아랫줄에 사용될 조사를 일단 여기 붙여 놓음
			require "engine.ui.Dialog":yesnoPopup("기술 사용 확인", ("%s 사용합니까?"):format(abname),
			function(quit)
				if quit ~= false then
					cancel = true
				end
				success, err = coroutine.resume(co)
			end,
			"취소","계속")
		else
			-- cancel checked in coroutine
			success, err = coroutine.resume(co)
		end
		if not success and err then print(debug.traceback(co)) error(err) end
	elseif ab.mode == "sustained" and ab.activate and ab.deactivate then
		if self:isTalentCoolingDown(ab) and not ignore_cd then
			game.logPlayer(who, "%s 아직 대기 시간이 %d 턴 만큼 남아있습니다.", (ab.kr_name or ab.name):capitalize():addJosa("는"), self.talents_cd[ab.id])
			return
		end
		local co = coroutine.create(function()
			if cancel then
				success = false
				return false
			end
			if not self:preUseTalent(ab, silent) then return end
			if not self.sustain_talents[id] then
				local old_level
				if force_level then old_level = who.talents[id]; who.talents[id] = force_level end
				local ret = ab.activate(who, ab)
				if ret == true then ret = {} end -- fix for badly coded talents
				if force_level then who.talents[id] = old_level end

				if not self:postUseTalent(ab, ret) then return end

				self.sustain_talents[id] = ret
			else
				local old_level
				if force_level then old_level = who.talents[id]; who.talents[id] = force_level end
				local p = self.sustain_talents[id]
				if p and type(p) == "table" and p.__tmpvals then
					for i = 1, #p.__tmpvals do
						self:removeTemporaryValue(p.__tmpvals[i][1], p.__tmpvals[i][2])
					end
				end
				local ret = ab.deactivate(who, ab, p)
				if force_level then who.talents[id] = old_level end

				if not self:postUseTalent(ab, ret, silent) then return end

				-- Everything went ok? then start cooldown if any
				if not ignore_cd then self:startTalentCooldown(ab) end
				self.sustain_talents[id] = nil
			end
		end)
		local success, err
		if not no_confirm and self:isTalentConfirmable(ab) then
			local abname = game:getGenericTextTiles(ab)..ab.name
			require "engine.ui.Dialog":yesnoPopup("Talent Use Confirmation", ("%s %s?"):
			format(self:isTalentActive(ab.id) and "Deactivate" or "Activate",abname),
			function(quit)
				if quit ~= false then
					cancel = true
				end
				success, err = coroutine.resume(co)
			end,
			"Cancel","Continue")
		else
			-- cancel checked in coroutine
			success, err = coroutine.resume(co)
		end
		if not success and err then print(debug.traceback(co)) error(err) end
	else
		print("Activating non activable or sustainable talent: "..id.." :: "..ab.name.." :: "..ab.mode)
	end
	self.changed = true
	return true

end

--- Replace some markers in a string with info on the talent
function _M:useTalentMessage(ab)
	if not ab.message then return nil end
	local str = util.getval(ab.message, self, ab)
	local _, _, target = self:getTarget()
	local tname = "누군가"
	if target then tname = target.kr_name or target.name end
	local sname = self.kr_name or self.name --@@ 다음줄~여덟줄 뒤까지 사용 : 한글 이름 저장 변수
	str = str:gsub("@Source@", sname:capitalize())
	str = str:gsub("@source@", sname)
	str = str:gsub("@Source1@", sname:capitalize():addJosa("가"))
	str = str:gsub("@source1@", sname:addJosa("가"))
	str = str:gsub("@Source2@", sname:capitalize():addJosa("는"))
	str = str:gsub("@source2@", sname:addJosa("는"))
	str = str:gsub("@Source3@", sname:capitalize():addJosa("를"))
	str = str:gsub("@source3@", sname:addJosa("를"))
	str = str:gsub("@source4@", tname:addJosa("로"))
	str = str:gsub("@Source4@", tname:capitalize():addJosa("로"))
	str = str:gsub("@source5@", tname:addJosa("다"))
	str = str:gsub("@Source5@", tname:capitalize():addJosa("다"))
	str = str:gsub("@source6@", tname:addJosa("과"))
	str = str:gsub("@Source6@", tname:capitalize():addJosa("과"))
	str = str:gsub("@source7@", tname:addJosa(7))
	str = str:gsub("@Source7@", tname:capitalize():addJosa(7))
	str = str:gsub("@target@", tname)
	str = str:gsub("@Target@", tname:capitalize())
	str = str:gsub("@target1@", tname:addJosa("가"))
	str = str:gsub("@Target1@", tname:capitalize():addJosa("가"))
	str = str:gsub("@target2@", tname:addJosa("는"))
	str = str:gsub("@Target2@", tname:capitalize():addJosa("는"))
	str = str:gsub("@target3@", tname:addJosa("를"))
	str = str:gsub("@Target3@", tname:capitalize():addJosa("를"))
	str = str:gsub("@target4@", tname:addJosa("로"))
	str = str:gsub("@Target4@", tname:capitalize():addJosa("로"))
	str = str:gsub("@target5@", tname:addJosa("다"))
	str = str:gsub("@Target5@", tname:capitalize():addJosa("다"))
	str = str:gsub("@target6@", tname:addJosa("과"))
	str = str:gsub("@Target6@", tname:capitalize():addJosa("과"))
	str = str:gsub("@target7@", tname:addJosa(7))
	str = str:gsub("@Target7@", tname:capitalize():addJosa(7))
	return str
end

--- Called before an talent is used
-- Redefine as needed
-- @param ab the talent (not the id, the table)
-- @param silent no messages will be outputted
-- @param fake no actions are taken, only checks
-- @return true to continue, false to stop
function _M:preUseTalent(talent, silent, fake)
	return true
end

--- Called before an talent is used
-- Redefine as needed
-- @param ab the talent (not the id, the table)
-- @param ret the return of the talent action
-- @return true to continue, false to stop
function _M:postUseTalent(talent, ret, silent)
	return true
end

--- Force a talent to activate without using energy or such
-- "def" can have a field "ignore_energy" to not consume energy; other parameters can be passed and handled by an overload of this method.
-- Object activation interface calls this method with an "ignore_ressources" parameter
function _M:forceUseTalent(t, def)
	local oldpause = game.paused
	local oldenergy = self.energy.value
	if def.ignore_energy then self.energy.value = 10000 end

	if def.ignore_ressources then self:attr("force_talent_ignore_ressources", 1) end
	local ret = {self:useTalent(t, def.force_who, def.force_level, def.ignore_cd, def.force_target, def.silent, true)}
	if def.ignore_ressources then self:attr("force_talent_ignore_ressources", -1) end

	if def.ignore_energy then
		game.paused = oldpause
		self.energy.value = oldenergy
	end
	return unpack(ret)
end

--- Is the sustained talent activated ?
function _M:isTalentActive(t_id)
	return self.sustain_talents[t_id]
end

--- Returns how many talents of this type the actor knows
-- @param type the talent type to count
-- @param exclude_id if not nil the count will ignore this talent id
function _M:numberKnownTalent(type, exclude_id)
	local nb = 0
	for id, _ in pairs(self.talents) do
		local t = _M.talents_def[id]
		if t.type[1] == type and (not exclude_id or exclude_id ~= id) then nb = nb + 1 end
	end
	return nb
end

--- Actor learns a talent
-- @param t_id the id of the talent to learn
-- @param force if true do not check canLearnTalent
-- @param nb the amount to increase the raw talent level by, default 1
-- @return true if the talent was learnt, nil and an error message otherwise
function _M:learnTalent(t_id, force, nb)
--	print("[TALENT]", self.name, self.uid, "learning", t_id, force, nb)
	local t = _M.talents_def[t_id]

	if not force then
		local ok, err = self:canLearnTalent(t)
		if not ok and err then return nil, err end
	end

	if not self.talents[t_id] then
		-- Auto assign to hotkey
		if t.mode ~= "passive" and self.hotkey then
			local position

			if self.player then
				if self == game:getPlayer(true) then
					position = self:findQuickHotkey("Player: Specific", "talent", t_id)
					if not position then
						local global_hotkeys = engine.interface.PlayerHotkeys.quickhotkeys["Player: Global"]
						if global_hotkeys and global_hotkeys["talent"] then position = global_hotkeys["talent"][t_id] end
					end
				else
					position = self:findQuickHotkey(self.name, "talent", t_id)
				end
			end

			if position and not self.hotkey[position] then
				self.hotkey[position] = {"talent", t_id}
			else
				for i = 1, 12 * (self.nb_hotkey_pages or 5) do
					if not self.hotkey[i] then
						self.hotkey[i] = {"talent", t_id}
						break
					end
				end
			end
		end
	end

	for i = 1, (nb or 1) do
		self.talents[t_id] = (self.talents[t_id] or 0) + 1
		if t.on_learn then 
			local ret = t.on_learn(self, t)
			if ret then
				if ret == true then ret = {} end
				self.talents_learn_vals[t.id] = self.talents_learn_vals[t.id] or {}
				self.talents_learn_vals[t.id][self.talents[t_id]] = ret
			end
		end
	end

	if t.passives then 
		self.talents_learn_vals[t.id] = self.talents_learn_vals[t.id] or {}
		local p = self.talents_learn_vals[t.id]

		if p.__tmpvals then for i = 1, #p.__tmpvals do
			self:removeTemporaryValue(p.__tmpvals[i][1], p.__tmpvals[i][2])
		end end
		self.talents_learn_vals[t.id] = {}

		t.passives(self, t, self.talents_learn_vals[t.id])
	end

	self.changed = true
	return true
end

--- Actor forgets a talent
-- @param t_id the id of the talent to learn
-- @return true if the talent was unlearnt, nil and an error message otherwise
function _M:unlearnTalent(t_id, nb)
	if not self:knowTalent(t_id) then return false, "talent not known" end

	local t = _M.talents_def[t_id]

	nb = math.min(nb or 1, self.talents[t_id])

	for j = 1, nb do
		if self.talents[t_id] and self.talents[t_id] == 1 then
			if self.hotkey then
				for i, known_t_id in pairs(self.hotkey) do
					if known_t_id[1] == "talent" and known_t_id[2] == t_id then self.hotkey[i] = nil end
				end
			end
		end

		self.talents[t_id] = self.talents[t_id] - 1
		if self.talents[t_id] == 0 then self.talents[t_id] = nil end

		if t.on_unlearn then 
			local p = nil
			if self.talents_learn_vals[t.id] and self.talents_learn_vals[t.id][(self.talents[t_id] or 0) + 1] then
				p = self.talents_learn_vals[t.id][(self.talents[t_id] or 0) + 1]
				if p.__tmpvals then
					for i = 1, #p.__tmpvals do
						self:removeTemporaryValue(p.__tmpvals[i][1], p.__tmpvals[i][2])
					end
				end
			end
			t.on_unlearn(self, t, p)
		end
	end

	if t.passives then 
		self.talents_learn_vals[t.id] = self.talents_learn_vals[t.id] or {}
		local p = self.talents_learn_vals[t.id]

		if p.__tmpvals then for i = 1, #p.__tmpvals do
			self:removeTemporaryValue(p.__tmpvals[i][1], p.__tmpvals[i][2])
		end end

		if self:knowTalent(t_id) then
			self.talents_learn_vals[t.id] = {}
			t.passives(self, t, self.talents_learn_vals[t.id])
		else
			self.talents_learn_vals[t.id] = nil
		end
	end

	if self.talents[t_id] == nil then self.talents_auto[t_id] = nil end

	self.changed = true
	return true
end

--- Checks the talent if learnable
-- @param t the talent to check
-- @param offset the level offset to check, defaults to 1
function _M:canLearnTalent(t, offset)
	-- Check prerequisites
	if rawget(t, "require") then
		local req = t.require
		if type(req) == "function" then req = req(self, t) end
		local tlev = self:getTalentLevelRaw(t) + (offset or 1)

		-- Obviously this requires the ActorStats interface
		if req.stat then
			for s, v in pairs(req.stat) do
				v = util.getval(v, tlev)
				if self:getStat(s) < v then return nil, "not enough stat" end
			end
		end
		if req.level then
			if self.level < util.getval(req.level, tlev) then
				return nil, "not enough levels"
			end
		end
		if req.special then
			if not req.special.fct(self, t, offset) then
				return nil, req.special.desc
			end
		end
		if req.talent then
			for _, tid in ipairs(req.talent) do
				if type(tid) == "table" then
					if type(tid[2]) == "boolean" and tid[2] == false then
						if self:knowTalent(tid[1]) then return nil, "missing dependency" end
					else
						if self:getTalentLevelRaw(tid[1]) < tid[2] then return nil, "missing dependency" end
					end
				else
					if not self:knowTalent(tid) then return nil, "missing dependency" end
				end
			end
		end
	end

	if not self:knowTalentType(t.type[1]) and not t.type_no_req then return nil, "unknown talent type" end

	-- Check talent type
	local known = self:numberKnownTalent(t.type[1], t.id)
	if t.type[2] and known < t.type[2] - 1 then
		return nil, "not enough talents of this type known"
	end

	-- Ok!
	return true
end

--- Formats the requirements as a (multiline) string
-- @param t_id the id of the talent to desc
-- @param levmod a number (1 should be the smartest) to add to current talent level to display requirements, defaults to 0
function _M:getTalentReqDesc(t_id, levmod)
	local t = _M.talents_def[t_id]
	local req = t.require
	if not req then return "" end
	if type(req) == "function" then req = req(self, t) end

	local tlev = self:getTalentLevelRaw(t_id) + (levmod or 0)

	local str = tstring{}

	if not t.type_no_req then
		str:add((self:knowTalentType(t.type[1]) and {"color", 0x00,0xff,0x00} or {"color", 0xff,0x00,0x00}), "- 기술 계열 습득", true)
	end

	if t.type[2] and t.type[2] > 1 then
		local known = self:numberKnownTalent(t.type[1], t.id)
		local c = (known >= t.type[2] - 1) and {"color", 0x00,0xff,0x00} or {"color", 0xff,0x00,0x00}
		str:add(c, ("- 같은 계열의 기술: %d"):format(t.type[2] - 1), true)
	end

	-- Obviously this requires the ActorStats interface
	if req.stat then
		for s, v in pairs(req.stat) do
			v = util.getval(v, tlev)
			local c = (self:getStat(s) >= v) and {"color", 0x00,0xff,0x00} or {"color", 0xff,0x00,0x00}
			str:add(c, ("- %s %d"):format(self.stats_def[s].name:krStat(), v), true) --@@ 능력치 이름 한글화
		end
	end
	if req.level then
		local v = util.getval(req.level, tlev)
		local c = (self.level >= v) and {"color", 0x00,0xff,0x00} or {"color", 0xff,0x00,0x00}
		str:add(c, ("- 레벨 %d"):format(v), true)
	end
	if req.special then
		local c = (req.special.fct(self, t, offset)) and {"color", 0x00,0xff,0x00} or {"color", 0xff,0x00,0x00}
		str:add(c, ("- %s"):format(req.special.desc), true)
	end
	if req.talent then
		for _, tid in ipairs(req.talent) do
			if type(tid) == "table" then
				local tn = self:getTalentFromId(tid[1]).kr_name or self:getTalentFromId(tid[1]).name --@@ 네줄뒤, 일곱줄뒤 사용 : 너무 길어서 변수로 뺌
				
				if type(tid[2]) == "boolean" and tid[2] == false then
					local c = (not self:knowTalent(tid[1])) and {"color", 0x00,0xff,0x00} or {"color", 0xff,0x00,0x00}
					str:add(c, ("- %s 기술 (모름)\n"):format(tn), true)
				else
					local c = (self:getTalentLevelRaw(tid[1]) >= tid[2]) and {"color", 0x00,0xff,0x00} or {"color", 0xff,0x00,0x00}
					str:add(c, ("- %s 기술 (%d)\n"):format(tn, tid[2]), true)
				end
			else
				local c = self:knowTalent(tid) and {"color", 0x00,0xff,0x00} or {"color", 0xff,0x00,0x00}
				str:add(c, ("- %s 기술\n"):format(self:getTalentFromId(tid).kr_name or self:getTalentFromId(tid).name), true)
			end
		end
	end

	return str
end

--- Return the full description of a talent
-- You may overload it to add more data (like power usage, ...)
function _M:getTalentFullDescription(t)
	return tstring{t.info(self, t), true}
end

--- Do we know this talent type
function _M:knowTalentType(name)
	return self.talents_types[name]
end

--- Do we know this talent
function _M:knowTalent(id)
	if type(id) == "table" then id = id.id end
	return (self:getTalentLevelRaw(id) > 0) and true or false
end

--- Talent level, 0 if not known
function _M:getTalentLevelRaw(id)
	if type(id) == "table" then id = id.id end
	return self.talents[id] or 0
end

--- Talent level, 0 if not known
-- Includes mastery
function _M:getTalentLevel(id)
	local t

	if type(id) == "table" then
		t, id = id, id.id
	else
		t = _M.talents_def[id]
	end
	return (self:getTalentLevelRaw(id)) * ((self.talents_types_mastery[t.type[1]] or 0) + 1)
end

--- Talent type level, sum of all raw levels of talents inside
function _M:getTalentTypeLevelRaw(tt)
	local nb = 0
	for tid, lev in pairs(self.talents) do
		local t = self:getTalentFromId(tid)
		if t.type[1] == tt then nb = nb + lev end
	end
	return nb
end

--- Return talent type mastery
function _M:getTalentTypeMastery(tt)
	return (self.talents_types_mastery[tt] or 0) + 1
end

--- Return talent type mastery for this talent
function _M:getTalentMastery(t)
	local tt = t.type[1]
	return self:getTalentTypeMastery(tt)
end

--- Sets talent type mastery
function _M:setTalentTypeMastery(tt, v)
	-- "v - 1" because a mastery is expressed as x + 1, not x, so that 0 is the default value (thus getting 1)
	self.talents_types_mastery[tt] = v - 1

	self:updateTalentTypeMastery(tt)
end

--- Recompute things that need recomputing
function _M:updateTalentTypeMastery(tt)
	for i, t in pairs(self.talents_types_def[tt] and self.talents_types_def[tt].talents or {}) do
		if t.auto_relearn_passive or t.passives then
			local lvl = self:getTalentLevelRaw(t)
			if lvl > 0 then
				self:unlearnTalent(t.id, lvl)
				self:learnTalent(t.id, true, lvl)
			end
		end
	end
end

--- Return talent definition from id
function _M:getTalentFromId(id)
	if type(id) == "table" then return id end
	return _M.talents_def[id]
end

--- Return talent definition from id
function _M:getTalentTypeFrom(id)
	return _M.talents_types_def[id]
end

--- Actor learns a talent type
-- @param t_id the id of the talent to learn
-- @return true if the talent was learnt, nil and an error message otherwise
function _M:learnTalentType(tt, v)
	if v == nil then v = true end
	if self.talents_types[tt] then return end
	self.talents_types[tt] = v
	self.talents_types_mastery[tt] = self.talents_types_mastery[tt] or 0
	self.changed = true
	return true
end

--- Actor forgets a talent type
-- @param t_id the id of the talent to learn
-- @return true if the talent was unlearnt, nil and an error message otherwise
function _M:unlearnTalentType(tt)
	self.talents_types[tt] = false
	self.changed = true
	return true
end

--- Gets a talent cooldown
-- @param t the talent to get cooldown
function _M:getTalentCooldown(t)
	if not t.cooldown then return end
	local cd = t.cooldown
	if type(cd) == "function" then cd = cd(self, t) end
	return cd
end

--- Starts a talent cooldown
-- @param t the talent to cooldown
function _M:startTalentCooldown(t)
	t = self:getTalentFromId(t)
	if not t.cooldown then return end
	local cd = t.cooldown
	if type(cd) == "function" then cd = cd(self, t) end
	self.talents_cd[t.id] = cd
	self.changed = true
end

--- Is talent in cooldown?
function _M:isTalentCoolingDown(t)
	t = self:getTalentFromId(t)
	if not t.cooldown then return false end
	if self.talents_cd[t.id] and self.talents_cd[t.id] > 0 then return self.talents_cd[t.id] else return false end
end

--- Returns the range of a talent
function _M:getTalentRange(t)
	if not t.range then return 1 end
	if type(t.range) == "function" then return t.range(self, t) end
	return t.range
end

--- Returns the radius of a talent
function _M:getTalentRadius(t)
	if not t.radius then return 0 end
	if type(t.radius) == "function" then return t.radius(self, t) end
	return t.radius
end

--- Returns the target type of a talent
function _M:getTalentTarget(t)
	if type(t.target) == "function" then return t.target(self, t) end
	return t.target
end

-- Returns whether the talent needs a target or not
function _M:getTalentRequiresTarget(t)
	if type(t.requires_target) == "function" then return t.requires_target(self, t) end
	return t.requires_target
end

--- Returns the projectile speed of a talent
function _M:getTalentProjectileSpeed(t)
	if not t.proj_speed then return nil end
	if type(t.proj_speed) == "function" then return t.proj_speed(self, t) end
	return t.proj_speed
end

--- Returns display name
function _M:getTalentDisplayName(t)
	if not t.display_name then return (t.kr_name or t.name) end
	if type(t.display_name) == "function" then return (t.kr_display_name and t.kr_display_name(self, t)) or t.display_name(self, t) end
	return (t.kr_display_name or t.display_name)
end

--- Cooldown all talents by one
-- This should be called in your actors "act()" method
function _M:cooldownTalents()
	for tid, c in pairs(self.talents_cd) do
		self.changed = true
		self.talents_cd[tid] = self.talents_cd[tid] - 1
		if self.talents_cd[tid] <= 0 then
			self.talents_cd[tid] = nil
			if self.onTalentCooledDown then self:onTalentCooledDown(tid) end
		end
	end
end

--- Setup the talent as autocast
function _M:setTalentAuto(tid, v)
	if type(tid) == "table" then tid = tid.id end
	if v then self.talents_auto[tid] = true
	else self.talents_auto[tid] = nil
	end
end

--- Setup the talent as autocast
function _M:isTalentAuto(tid)
	if type(tid) == "table" then tid = tid.id end
	return self.talents_auto[tid]
end

--- Try to auto use listed talents
-- This should be called in your actors "act()" method
function _M:automaticTalents()
	for tid, c in pairs(self.talents_auto) do
		local t = self.talents_def[tid]
		if not t.np_npc_use and (t.mode ~= "sustained" or not self.sustain_talents[tid]) and not self.talents_cd[tid] and self:preUseTalent(t, true, true) and (not t.auto_use_check or t.auto_use_check(self, t)) then
			self:useTalent(tid)
		end
	end
end

--- Set the talent confirmation
function _M:setTalentConfirmable(tid, v)
	if type(tid) == "table" then tid = tid.id end
	if v then self.talents_confirm_use[tid] = true
	else self.talents_confirm_use[tid] = nil
	end
end

--- Does the talent require confirmation to use?
function _M:isTalentConfirmable(tid)
	if type(tid) == "table" then tid = tid.id end
	if not self.talents_confirm_use then self.talents_confirm_use = {} end -- For compatibility with older versions, can be removed
	return self.player and self.talents_confirm_use[tid]
end

--- Show usage dialog
function _M:useTalents(add_cols)
	local d = require("engine.dialogs.UseTalents").new(self, add_cols)
	game:registerDialog(d)
end

--- Helper function to add temporary values and not have to remove them manualy
function _M:talentTemporaryValue(p, k, v)
	if not p.__tmpvals then p.__tmpvals = {} end
	p.__tmpvals[#p.__tmpvals+1] = {k, self:addTemporaryValue(k, v)}
end

--- Trigger a talent method
function _M:triggerTalent(tid, name, ...)
	if self:isTalentCoolingDown(tid) then return end

	local t = _M.talents_def[tid]
	name = name or "trigger"
	if t[name] then return t[name](self, t, ...) end
end

--- Trigger a talent method
function _M:callTalent(tid, name, ...)
	local t = _M.talents_def[tid]
	name = name or "trigger"
	if t[name] then return t[name](self, t, ...) end
end
