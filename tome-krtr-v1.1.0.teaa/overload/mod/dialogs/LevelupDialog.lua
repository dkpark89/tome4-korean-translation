-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even th+e implied warranty of
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
require "mod.class.interface.TooltipsData"

local Dialog = require "engine.ui.Dialog"
local Button = require "engine.ui.Button"
local Textzone = require "engine.ui.Textzone"
local TextzoneList = require "engine.ui.TextzoneList"
local UIContainer = require "engine.ui.UIContainer"
local TalentTrees = require "mod.dialogs.elements.TalentTrees"
local Separator = require "engine.ui.Separator"
local DamageType = require "engine.DamageType"

module(..., package.seeall, class.inherit(Dialog, mod.class.interface.TooltipsData))

local function backup(original)
	local bak = original:clone()
	bak.uid = original.uid -- Yes ...
	return bak
end

local function restore(dest, backup)
	local bx, by = dest.x, dest.y
	backup.replacedWith = false
	dest:replaceWith(backup)
	dest.replacedWith = nil
	dest.x, dest.y = bx, by
	dest.changed = true
	dest:removeAllMOs()
	if game.level and dest.x then game.level.map:updateMap(dest.x, dest.y) end
end

function _M:init(actor, on_finish, on_birth)
	self.on_birth = on_birth
	actor.no_last_learnt_talents_cap = true
	self.actor = actor
	self.unused_stats = self.actor.unused_stats
	self.new_stats_changed = false
	self.new_talents_changed = false

	self.talents_changed = {}
	self.on_finish = on_finish
	self.running = true
	self.prev_stats = {}
	self.font_h = self.font:lineSkip()
	self.talents_learned = {}
	self.talent_types_learned = {}
	self.stats_increased = {}

	self.font = core.display.newFont(krFont or "/data/font/DroidSansMono.ttf", 12) --@@ 한글 글꼴 추가
	self.font_h = self.font:lineSkip()

	self.actor.__hidden_talent_types = self.actor.__hidden_talent_types or {}
	self.actor.__increased_talent_types = self.actor.__increased_talent_types or {}

	actor.last_learnt_talents = actor.last_learnt_talents or { class={}, generic={} }
	self.actor_dup = backup(actor)
	if actor.alchemy_golem then self.golem_dup = backup(actor.alchemy_golem) end

	if actor.descriptor then
		for _, v in pairs(game.engine.Birther.birth_descriptor_def) do
			if v.type == "subclass" and v.name == actor.descriptor.subclass then self.desc_def = v break end
		end
	end

	Dialog.init(self, "레벨 상승 : "..actor.name, game.w * 0.9, game.h * 0.9, game.w * 0.05, game.h * 0.05)
	if game.w * 0.9 >= 1000 then
		self.no_tooltip = true
	end

	self:generateList()

	self:loadUI(self:createDisplay())
	self:setupUI()

	self.key:addCommands{
		__TEXTINPUT = function(c)
			if self.focus_ui.ui.last_mz then
				if c == "+" and self.focus_ui and self.focus_ui.ui.onUse then
					self.focus_ui.ui:onUse(self.focus_ui.ui.last_mz.item, true)
				elseif c == "-" then
					self.focus_ui.ui:onUse(self.focus_ui.ui.last_mz.item, false)
				end
			end
		end,
	}
	self.key:addBinds{
		EXIT = function()
			local changed = #self.actor.last_learnt_talents.class ~= #self.actor_dup.last_learnt_talents.class or #self.actor.last_learnt_talents.generic ~= #self.actor_dup.last_learnt_talents.generic
			for i = 1, #self.actor.last_learnt_talents.class do if self.actor.last_learnt_talents.class[i] ~= self.actor_dup.last_learnt_talents.class[i] then changed = true end end
			for i = 1, #self.actor.last_learnt_talents.generic do if self.actor.last_learnt_talents.generic[i] ~= self.actor_dup.last_learnt_talents.generic[i] then changed = true end end

			if self.actor.unused_stats~=self.actor_dup.unused_stats or self.actor.unused_talents_types~=self.actor_dup.unused_talents_types or
			self.actor.unused_talents~=self.actor_dup.unused_talents or self.actor.unused_generics~=self.actor_dup.unused_generics or self.actor.unused_prodigies~=self.actor_dup.unused_prodigies or changed then
				self:yesnocancelLongPopup("완료","변경사항을 적용합니까?\n", 300, function(yes, cancel)
				if cancel then
					return nil
				else
					if yes then ok = self:finish() else ok = true self:cancel() end
				end
				if ok then
					game:unregisterDialog(self)
					self.actor_dup = {}
					if self.on_finish then self.on_finish() end
				end
				end, "예", "아니오", "취소")
			else
				game:unregisterDialog(self)
				self.actor_dup = {}
				if self.on_finish then self.on_finish() end
			end
		end,
	}
end

function _M:on_register()
	game:onTickEnd(function() self.key:unicodeInput(true) end)
end

function _M:unload()
	self.actor.no_last_learnt_talents_cap = nil
	self.actor:capLastLearntTalents("class")
	self.actor:capLastLearntTalents("generic")
end

function _M:cancel()
	restore(self.actor, self.actor_dup)
	if self.golem_dup then restore(self.actor.alchemy_golem, self.golem_dup) end
end

function _M:getMaxTPoints(t)
	if t.points == 1 then return 1 end
	return t.points + math.max(0, math.floor((self.actor.level - 50) / 10)) + (self.actor.talents_inc_cap and self.actor.talents_inc_cap[t.id] or 0)
end

function _M:finish()
	local ok, dep_miss = self:checkDeps(true)
	if not ok then
		self:simpleLongPopup("불가능", "이 기술을 배울 수 없습니다 : "..dep_miss, game.w * 0.4)
		return nil
	end

	local txt = "#LIGHT_BLUE#경고 : 당신의 능력치나 기술이 변화했지만, 아직 전에 사용한 기술이 유지 중입니다 : \n%s 이 기술들 중 바뀐 능력치의 영향을 받는 기술들이 있다면, 바뀐 능력치의 효과를 보기 위해서는 해당 기술을 다시 사용해야 합니다."
	local talents = ""
	local reset = {}
	for tid, act in pairs(self.actor.sustain_talents) do
		if act then
			local t = self.actor:getTalentFromId(tid)
			if t.no_sustain_autoreset and self.actor:knowTalent(tid) then
				talents = talents.."#GOLD# - "..(t.kr_name or t.name).."#LAST#\n"
			else
				reset[#reset+1] = tid
			end
		end
	end
	if talents ~= "" then
		game.logPlayer(self.actor, txt:format(talents))
	end
	for i, tid in ipairs(reset) do
		self.actor:forceUseTalent(tid, {ignore_energy=true, ignore_cd=true, no_talent_fail=true})
		if self.actor:knowTalent(tid) then self.actor:forceUseTalent(tid, {ignore_energy=true, ignore_cd=true, no_talent_fail=true, talent_reuse=true}) end
	end

	-- Prodigies
	if self.on_finish_prodigies then
		for tid, ok in pairs(self.on_finish_prodigies) do if ok then self.actor:learnTalent(tid, true, nil, {no_unlearn=true}) end end
	end

	if not self.on_birth then
		for t_id, _ in pairs(self.talents_learned) do
			local t = self.actor:getTalentFromId(t_id)
			if not self.actor:isTalentCoolingDown(t) and not self.actor_dup:knowTalent(t_id) then self.actor:startTalentCooldown(t) end
		end
	end
	return true
end

function _M:incStat(sid, v)
	if v == 1 then
		if self.actor.unused_stats <= 0 then
			self:simpleLongPopup("능력치 점수 부족", "남아있는 능력치 점수가 없습니다!", 300)
			return
		end
		if self.actor:getStat(sid, nil, nil, true) >= self.actor.level * 1.4 + 20 then
			self:simpleLongPopup("레벨 한계치", "레벨이 더 올라야 이 능력치를 올릴 수 있습니다.", 300)
			return
		end
		if self.actor:isStatMax(sid) or self.actor:getStat(sid, nil, nil, true) >= 60 + math.max(0, (self.actor.level - 50)) then
			self:simpleLongPopup("최대 능력치 도달", "더 이상 이 능력치는 올릴 수 없습니다!", 300)
			return
		end
	else
		if self.actor_dup:getStat(sid, nil, nil, true) == self.actor:getStat(sid, nil, nil, true) then
			self:simpleLongPopup("불가능", "점수를 더 반환할 수 없습니다!", 300)
			return
		end
	end

	self.actor:incStat(sid, v)
	self.actor.unused_stats = self.actor.unused_stats - v

	self.stats_increased[sid] = (self.stats_increased[sid] or 0) + v
	self:updateTooltip()
end

function _M:computeDeps(t)
	local d = {}
	self.talents_deps[t.id] = d

	-- Check prerequisites
	if rawget(t, "require") then
		local req = t.require
		if type(req) == "function" then req = req(self.actor, t) end

		if req.talent then
			for _, tid in ipairs(req.talent) do
				if type(tid) == "table" then
					d[tid[1]] = true
--					print("Talent deps: ", t.id, "depends on", tid[1])
				else
					d[tid] = true
--					print("Talent deps: ", t.id, "depends on", tid)
				end
			end
		end
	end

	-- Check number of talents
	for id, nt in pairs(self.actor.talents_def) do
		if nt.type[1] == t.type[1] then
			d[id] = true
--			print("Talent deps: ", t.id, "same category as", id)
		end
	end
end

function _M:checkDeps(simple)
	local talents = ""
	local stats_ok = true

	local checked = {}

	local function check(t_id, force)
		if checked[t_id] then return end
		checked[t_id] = true

		local t = self.actor:getTalentFromId(t_id)
		local ok, reason = self.actor:canLearnTalent(t, 0)
		if not ok and (self.actor:knowTalent(t) or force) then talents = talents.."\n#GOLD##{bold}#    - "..(t.kr_name or t.name).."#{normal}##LAST#("..reason:krT_Reason()..")" end
		if reason == "not enough stat" then
			stats_ok = false
		end

		local dlist = self.talents_deps[t_id]
		if dlist and not simple then for dtid, _ in pairs(dlist) do check(dtid) end end
	end

	for t_id, _ in pairs(self.talents_changed) do check(t_id) end

	-- Prodigies
	if self.on_finish_prodigies then
		for tid, ok in pairs(self.on_finish_prodigies) do if ok then check(tid, true) end end
	end

	if talents ~="" then
		return false, talents, stats_ok
	else
		return true, "", stats_ok
	end
end

function _M:isUnlearnable(t, limit)
	if not self.actor.last_learnt_talents then return end
	if self.on_birth and self.actor:knowTalent(t.id) and not t.no_unlearn_last then return 1 end -- On birth we can reset any talents except a very few
	local list = self.actor.last_learnt_talents[t.generic and "generic" or "class"]
	local max = self.actor:lastLearntTalentsMax(t.generic and "generic" or "class")
	local min = 1
	if limit then min = math.max(1, #list - (max - 1)) end
	for i = #list, min, -1 do
		if list[i] == t.id then return i end
	end
	return nil
end

function _M:learnTalent(t_id, v)
	self.talents_learned[t_id] = self.talents_learned[t_id] or 0
	local t = self.actor:getTalentFromId(t_id)
	local t_type, t_index = "직업", "unused_talents"
	if t.generic then t_type, t_index = "일반", "unused_generics" end
	if v then
		if self.actor[t_index] < 1 then
			self:simpleLongPopup(""..t_type.."기술 점수 부족", "남아있는 "..t_type.."기술 점수가 없습니다!", 300)
			return
		end
		if not self.actor:canLearnTalent(t) then
			self:simpleLongPopup("기술을 배울 수 없음", "선행조건에 부합하지 않아 배울 수 없습니다!", 300)
			return
		end
		if self.actor:getTalentLevelRaw(t_id) >= self:getMaxTPoints(t) then
			self:simpleLongPopup("이미 습득한 기술", "이미 이 기술은 완벽히 배웠습니다!", 300)
			return
		end
		self.actor:learnTalent(t_id, true)
		self.actor[t_index] = self.actor[t_index] - 1
		self.talents_changed[t_id] = true
		self.talents_learned[t_id] = self.talents_learned[t_id] + 1
		self.new_talents_changed = true
	else
		if not self.actor:knowTalent(t_id) then
			self:simpleLongPopup("불가능", "이 기술은 배우지 않았습니다!", 300)
			return
		end
		if not self:isUnlearnable(t, true) and self.actor_dup:getTalentLevelRaw(t_id) >= self.actor:getTalentLevelRaw(t_id) then
			self:simpleLongPopup("불가능", "기술 습득을 취소할 수 없습니다!", 300)
			return
		end
		self.actor:unlearnTalent(t_id, nil, true, {no_unlearn=true})
		self.talents_changed[t_id] = true
		local _, reason = self.actor:canLearnTalent(t, 0)
		local ok, dep_miss, stats_ok = self:checkDeps()
		self.actor:learnTalent(t_id, true, nil, {no_unlearn=true})
		if ok or reason == "not enough stat" or not stats_ok then
			self.actor:unlearnTalent(t_id)
			self.actor[t_index] = self.actor[t_index] + 1
			self.talents_learned[t_id] = self.talents_learned[t_id] - 1
			self.new_talents_changed = true
		else
			self:simpleLongPopup("불가능", "다음 기술 때문에 이 기술 습득을 취소할 수 없습니다 : "..dep_miss, game.w * 0.4)
			return
		end
	end
	self:updateTooltip()
end

function _M:learnType(tt, v)
	self.talent_types_learned[tt] = self.talent_types_learned[tt] or {}
	if v then
		if self.actor:knowTalentType(tt) and self.actor.__increased_talent_types[tt] and self.actor.__increased_talent_types[tt] >= 1 then
			self:simpleLongPopup("불가능", "기술계열 숙련은 한 번만 가능합니다!", 300)
			return
		end
		if self.actor.unused_talents_types <= 0 then
			self:simpleLongPopup("기술계열 점수 부족", "남아있는 기술계열 점수가 없습니다!", 300)
			return
		end
		if not self.actor.talents_types_def[tt] or (self.actor.talents_types_def[tt].min_lev or 0) > self.actor.level then
			self:simpleLongPopup("미숙한 레벨", ("이 기술계열은 레벨 %d 부터 사용할 수 있습니다. 지금 이 기술계열을 익히는 것은 쓸모가 없습니다."):format(self.actor.talents_types_def[tt].min_lev), 400)
			return
		end
		if not self.actor:knowTalentType(tt) then
			self.actor:learnTalentType(tt)
			self.talent_types_learned[tt][1] = true
		else
			self.actor.__increased_talent_types[tt] = (self.actor.__increased_talent_types[tt] or 0) + 1
			self.actor:setTalentTypeMastery(tt, self.actor:getTalentTypeMastery(tt) + 0.2)
			self.talent_types_learned[tt][2] = true
		end
		self:triggerHook{"PlayerLevelup:addTalentType", actor=self.actor, tt=tt}
		self.actor.unused_talents_types = self.actor.unused_talents_types - 1
		self.new_talents_changed = true
	else
		if self.actor_dup:knowTalentType(tt) == true and self.actor:knowTalentType(tt) == true and (self.actor_dup.__increased_talent_types[tt] or 0) >= (self.actor.__increased_talent_types[tt] or 0) then
			self:simpleLongPopup("불가능", "점수를 더 반환할 수 없습니다!", 300)
			return
		end
		if self.actor_dup:knowTalentType(tt) == true and self.actor:knowTalentType(tt) == true and (self.actor.__increased_talent_types[tt] or 0) == 0 then
			self:simpleLongPopup("불가능", "기술계열 숙련을 취소할 수 없습니다!", 300)
			return
		end
		if not self.actor:knowTalentType(tt) then
			self:simpleLongPopup("불가능", "이 기술계열은 배우지도 않았습니다!", 300)
			return
		end

		if (self.actor.__increased_talent_types[tt] or 0) > 0 then
			self.actor.__increased_talent_types[tt] = (self.actor.__increased_talent_types[tt] or 0) - 1
			self.actor:setTalentTypeMastery(tt, self.actor:getTalentTypeMastery(tt) - 0.2)
			self.actor.unused_talents_types = self.actor.unused_talents_types + 1
			self.new_talents_changed = true
			self.talent_types_learned[tt][2] = nil
		else
			self.actor:unlearnTalentType(tt)
			local ok, dep_miss = self:checkDeps()
			if ok then
				self.actor.unused_talents_types = self.actor.unused_talents_types + 1
				self.new_talents_changed = true
				self.talent_types_learned[tt][1] = nil
			else
				self:simpleLongPopup("불가능", "다음 이유로 이 기술계열 숙련을 취소할 수 없습니다 : "..dep_miss, game.w * 0.4)
				self.actor:learnTalentType(tt)
				return
			end
		end
		self:triggerHook{"PlayerLevelup:subTalentType", actor=self.actor, tt=tt}
	end
	self:updateTooltip()
end

function _M:generateList()
	self.actor.__show_special_talents = self.actor.__show_special_talents or {}

	-- Makes up the list
	local ctree = {}
	local gtree = {}
	self.talents_deps = {}
	for i, tt in ipairs(self.actor.talents_types_def) do
		if not tt.hide and not (self.actor.talents_types[tt.type] == nil) then
			local cat = tt.type:gsub("/.*", "")
			local ttknown = self.actor:knowTalentType(tt.type)
			local isgeneric = self.actor.talents_types_def[tt.type].generic
			local tshown = (self.actor.__hidden_talent_types[tt.type] == nil and ttknown) or (self.actor.__hidden_talent_types[tt.type] ~= nil and not self.actor.__hidden_talent_types[tt.type])
			local node = {
				name=function(item) return tstring{{"font", "bold"}, cat:capitalize():krTalentType().." / "..tt.name:capitalize():krTalentType() ..(" (%s)"):format((isgeneric and "일반" or "직업")), {"font", "normal"}} end, --@@ 기술계열이름 한글로 변경 
				rawname=function(item) return cat:capitalize():krTalentType().." / "..tt.name:capitalize():krTalentType()..(" (x%.2f)"):format(self.actor:getTalentTypeMastery(item.type)) end,
				oriname=function(item) return cat:capitalize().." / "..tt.name:capitalize() end, --@@ 변수 추가하여 원문이름 저장
				
				type=tt.type,
				color=function(item) return ((self.actor:knowTalentType(item.type) ~= self.actor_dup:knowTalentType(item.type)) or ((self.actor.__increased_talent_types[item.type] or 0) ~= (self.actor_dup.__increased_talent_types[item.type] or 0))) and {255, 215, 0} or self.actor:knowTalentType(item.type) and {0,200,0} or {175,175,175} end,
				shown = tshown,
				status = function(item) return self.actor:knowTalentType(item.type) and tstring{{"font", "bold"}, ((self.actor.__increased_talent_types[item.type] or 0) >=1) and {"color", 255, 215, 0} or {"color", 0x00, 0xFF, 0x00}, ("%.2f"):format(self.actor:getTalentTypeMastery(item.type)), {"font", "normal"}} or tstring{{"color",  0xFF, 0x00, 0x00}, "unknown"} end,
				nodes = {},
				isgeneric = isgeneric and 0 or 1,
				order_id = i,
			}
			if isgeneric then gtree[#gtree+1] = node
			else ctree[#ctree+1] = node end

			local list = node.nodes

			-- Find all talents of this school
			for j, t in ipairs(tt.talents) do
				if not t.hide or self.actor.__show_special_talents[t.id] then
					self:computeDeps(t)
					local isgeneric = self.actor.talents_types_def[tt.type].generic

					local tdn = t.kr_name or t.name --@@ 기술 한글이름 저장

					-- Pregenenerate icon with the Tiles instance that allows images
					if t.display_entity then t.display_entity:getMapObjects(game.uiset.hotkeys_display_icons.tiles, {}, 1) end

					list[#list+1] = {
						__id=t.id,
						name=tdn:toTString(), --@@ 기술이름 한글로 변경
						rawname= tdn, --@@ 소팅용 이름 한글로 변경
						oriname = t.name, --@@ 변수 추가하여 원문이름 저장
						entity=t.display_entity,
						talent=t.id,
						break_line=t.levelup_screen_break_line,
						isgeneric=isgeneric and 0 or 1,
						_type=tt.type,
						do_shadow = function(item) if not self.actor:canLearnTalent(t) then return true else return false end end,
						color=function(item)
							if ((self.actor.talents[item.talent] or 0) ~= (self.actor_dup.talents[item.talent] or 0)) then return {255, 215, 0}
							elseif self:isUnlearnable(t, true) then return colors.simple(colors.LIGHT_BLUE)
							elseif self.actor:knowTalentType(item._type) then return {255,255,255}
							else return {175,175,175}
							end
						end,
					}
					list[#list].status = function(item)
						local t = self.actor:getTalentFromId(item.talent)
						local ttknown = self.actor:knowTalentType(item._type)
						if self.actor:getTalentLevelRaw(t.id) == self:getMaxTPoints(t) then
							return tstring{{"color", 0x00, 0xFF, 0x00}, self.actor:getTalentLevelRaw(t.id).."/"..self:getMaxTPoints(t)}
						else
							if not self.actor:canLearnTalent(t) then
								return tstring{(ttknown and {"color", 0xFF, 0x00, 0x00} or {"color", 0x80, 0x80, 0x80}), self.actor:getTalentLevelRaw(t.id).."/"..self:getMaxTPoints(t)}
							else
								return tstring{(ttknown and {"color", "WHITE"} or {"color", 0x80, 0x80, 0x80}), self.actor:getTalentLevelRaw(t.id).."/"..self:getMaxTPoints(t)}
							end
						end
					end
				end
			end
		end
	end
	table.sort(ctree, function(a, b)
		if self.actor:knowTalentType(a.type) and not self.actor:knowTalentType(b.type) then return 1
		elseif not self.actor:knowTalentType(a.type) and self.actor:knowTalentType(b.type) then return nil
		else return a.order_id < b.order_id end
	end)
	self.ctree = ctree
	table.sort(gtree, function(a, b)
		if self.actor:knowTalentType(a.type) and not self.actor:knowTalentType(b.type) then return 1
		elseif not self.actor:knowTalentType(a.type) and self.actor:knowTalentType(b.type) then return nil
		else return a.order_id < b.order_id end
	end)
	self.gtree = gtree

	-- Makes up the stats list
	local stats = {}
	self.tree_stats = stats

	for i, sid in ipairs{self.actor.STAT_STR, self.actor.STAT_DEX, self.actor.STAT_CON, self.actor.STAT_MAG, self.actor.STAT_WIL, self.actor.STAT_CUN } do
		local s = self.actor.stats_def[sid]
		local e = engine.Entity.new{image="stats/"..s.name:lower()..".png", is_stat=true}
		e:getMapObjects(game.uiset.hotkeys_display_icons.tiles, {}, 1)

		stats[#stats+1] = {shown=true, nodes={{
			name=s.name,
			rawname=s.name,
			entity=e,
			stat=sid,
			desc=s.description,
			color=function(item)
				if self.actor:getStat(sid, nil, nil, true) ~= self.actor_dup:getStat(sid, nil, nil, true) then return {255, 215, 0}
				elseif self.actor:getStat(sid, nil, nil, true) >= self.actor.level * 1.4 + 20 or
				   self.actor:isStatMax(sid) or
				   self.actor:getStat(sid, nil, nil, true) >= 60 + math.max(0, (self.actor.level - 50)) then
					return {0, 255, 0}
				else
					return {175,175,175}
				end
			end,
			status = function(item)
				if self.actor:getStat(sid, nil, nil, true) >= self.actor.level * 1.4 + 20 or
				   self.actor:isStatMax(sid) or
				   self.actor:getStat(sid, nil, nil, true) >= 60 + math.max(0, (self.actor.level - 50)) then
					return tstring{{"color", 175, 175, 175}, ("%d (%d)"):format(self.actor:getStat(sid), self.actor:getStat(sid, nil, nil, true))}
				else
					return tstring{{"color", 0x00, 0xFF, 0x00}, ("%d (%d)"):format(self.actor:getStat(sid), self.actor:getStat(sid, nil, nil, true))}
				end
			end,
		}}}
	end
end

-----------------------------------------------------------------
-- UI Stuff
-----------------------------------------------------------------

local _points_left = [[
남아있는 능력치 점수: #00FF00#%d#LAST#
남아있는 기술계열 점수: #00FF00#%d#LAST#
남아있는 직업기술 점수: #00FF00#%d#LAST#
남아있는 일반기술 점수: #00FF00#%d#LAST#]]

local desc_stats = ([[능력치 점수로 당신의 기본 능력치를 올릴 수 있습니다.
레벨이 오를 때마다 3 점의 능력치 점수를 얻습니다.

각각의 능력치는 자연적 최대치인 60 이나, (당신의 레벨에 따라 정해지는) 일정 수준까지만 올릴 수 있습니다.]]):toTString()

local desc_class = ([[직업기술 점수로 새로운 직업기술을 익히거나, 기존의 직업기술을 향상시킬 수 있습니다.
직업기술은 당신의 직업에 따라 정해지며, 훈련으로 새롭게 익힐 수 없습니다.

레벨이 오를 때마다 1 점의 직업기술 점수를 얻습니다.
레벨이 5 의 배수가 될 때마다, 직업기술 점수를 1 점 더 얻을 수 있습니다.
]]):toTString()

local desc_generic = ([[일반기술 점수로 새로운 일반기술을 익히거나, 기존의 일반기술을 향상시킬 수 있습니다.
일반기술은 당신의 직업이나 종족에 따라 얻는 것도 있고, 모험을 하는 과정에서 다양한 훈련을 통해 얻을 수도 있습니다.

기본적으로는 레벨이 오를 때마다 1 점의 일반기술 점수를 얻습니다.
하지만, 레벨이 5 의 배수가 될 때마다 일반기술 점수를 얻지 못하게 됩니다.
]]):toTString()

local desc_types = ([[기술계열 점수로는 다음 중 하나를 할 수 있습니다 :
- 새로운 (직업, 일반) 기술 계열을 익힙니다. (잠겨진 기술계열 활성화)
- 이미 익힌 기술 계열의 숙련도를 0.2 향상시킵니다. (기술 계열당 한 번씩만 가능)
- 각인의 갯수를 늘립니다. (최대 각인의 갯수는 5 개로 한정)

레벨이 10, 20, 36 이 될 때 기술계열 점수를 1 점 얻을 수 있습니다.
어떤 종족은 기술계열 점수를 가지고 시작하며, 희귀하지만 기술계열 점수를 높여주는 물건도 있습니다.]]):toTString()

local desc_prodigies = ([[특수기술은 캐릭터가 얻을 수 있는 가장 강력하며 특별한 기술입니다.
모든 특수기술을 배우기 위해서는 주요 능력치가 50 을 넘어야 하며, 그 외에도 기술에 따른 특별한 조건을 갖추어야 배울 자격이 주어집니다. 새로운 특수기술은 30 레벨에 한 번, 42 레벨에 한 번 배울 수 있습니다.]]):toTString()

local desc_inscriptions = ([[기술계열 점수를 하나 사용하여, 새로운 각인을 새길 수 있게 됩니다. (각인은 최대 5 개 새길 수 있음)]]):toTString()

function _M:createDisplay()
	self.b_prodigies = Button.new{text="특수기술", fct=function()
			self.on_finish_prodigies = self.on_finish_prodigies or {}
			local d = require("mod.dialogs.UberTalent").new(self.actor, self.on_finish_prodigies)
			game:registerDialog(d)
		end, on_select=function()
		local str = desc_prodigies
		if self.no_tooltip then
			self.c_desc:erase()
			self.c_desc:switchItem(str, str, true)
		else
			game:tooltipDisplayAtMap(self.b_stat.last_display_x + self.b_stat.w, self.b_stat.last_display_y, str)
		end
	end}

	if self.actor.inscriptions_slots_added < 2 then
		self.b_inscriptions = Button.new{text="각인 슬롯", fct=function()
				if self.actor.inscriptions_slots_added >= 2 then
					Dialog:simplePopup("각인 슬롯", "당신은 더 이상 각인 슬롯을 늘릴 수 없습니다. 이미 최대치입니다.")
				else
					if self.actor.unused_talents_types > 0 then
					Dialog:yesnoPopup("각인 슬롯", ("당신은 %d 개의 새 각인 슬롯을 얻을 수 있습니다. 지금 기술계열 점수를 사용하여 새 각인 슬롯을 얻으시겠습니까?"):format(2 - self.actor.inscriptions_slots_added), function(ret) if ret then
							self.actor.unused_talents_types = self.actor.unused_talents_types - 1
							self.actor.max_inscriptions = self.actor.max_inscriptions + 1
							self.actor.inscriptions_slots_added = self.actor.inscriptions_slots_added + 1
						self.b_types.text = "기술계열 점수: "..self.actor.unused_talents_types
							self.b_types:generate()
						end end, "예", "아니오")
					else
						Dialog:simplePopup("각인", ("당신은 아직 %d 개의 새 각인 슬롯을 얻을 수 있지만, 이를 위해서는 기술계열 점수가 필요합니다."):format(2 - self.actor.inscriptions_slots_added))
					end
				end
			end, on_select=function()
			local str = desc_inscriptions
			if self.no_tooltip then
				self.c_desc:erase()
				self.c_desc:switchItem(str, str, true)
			else
				game:tooltipDisplayAtMap(self.b_stat.last_display_x + self.b_stat.w, self.b_stat.last_display_y, str)
			end
		end}
	end

	if self.actor.unused_prodigies > 0 then self.b_prodigies.glow = 0.6 end
	if self.actor.unused_talents_types > 0 and self.b_inscriptions then self.b_inscriptions.glow = 0.6 end

	self.c_ctree = TalentTrees.new{
		font = core.display.newFont(krFont or "/data/font/DroidSans.ttf", 14), --@@ 한글 글꼴 추가
		tiles=game.uiset.hotkeys_display_icons,
		tree=self.ctree,
		width=320, height=self.ih-50,
		tooltip=function(item)
			local x = self.display_x + self.uis[5].x - game.tooltip.max
			if self.display_x + self.w + game.tooltip.max <= game.w then x = self.display_x + self.w end
			local ret = self:getTalentDesc(item), x, nil
			if self.no_tooltip then
				self.c_desc:erase()
				self.c_desc:switchItem(ret, ret)
			end
			return ret
		end,
		on_use = function(item, inc) self:onUseTalent(item, inc) end,
		on_expand = function(item) self.actor.__hidden_talent_types[item.type] = not item.shown end,
		scrollbar = true, no_tooltip = self.no_tooltip,
	}

	self.c_gtree = TalentTrees.new{
		font = core.display.newFont(krFont or "/data/font/DroidSans.ttf", 14), --@@ 한글 글꼴 추가
		tiles=game.uiset.hotkeys_display_icons,
		tree=self.gtree,
		width=320, height=self.ih-50 - math.max((not self.b_prodigies and 0 or self.b_prodigies.h + 5), (not self.b_inscriptions and 0 or self.b_inscriptions.h + 5)),
		tooltip=function(item)
			local x = self.display_x + self.uis[8].x - game.tooltip.max
			if self.display_x + self.w + game.tooltip.max <= game.w then x = self.display_x + self.w end
			local ret = self:getTalentDesc(item), x, nil
			if self.no_tooltip then
				self.c_desc:erase()
				self.c_desc:switchItem(ret, ret)
			end
			return ret
		end,
		on_use = function(item, inc) self:onUseTalent(item, inc) end,
		on_expand = function(item) self.actor.__hidden_talent_types[item.type] = not item.shown end,
		scrollbar = true, no_tooltip = self.no_tooltip,
	}

	self.c_stat = TalentTrees.new{
		font = core.display.newFont(krFont or "/data/font/DroidSans.ttf", 14), --@@ 한글 글꼴 추가
		tiles=game.uiset.hotkeys_display_icons,
		tree=self.tree_stats, no_cross = true,
		width=50, height=self.ih,
		dont_select_top = true,
		tooltip=function(item)
			local x = self.display_x + self.uis[2].x + self.uis[2].ui.w
			if self.display_x + self.w + game.tooltip.max <= game.w then x = self.display_x + self.w end
			local ret = self:getStatDesc(item), x, nil
			if self.no_tooltip then
				self.c_desc:erase()
				self.c_desc:switchItem(ret, ret)
			end
			return ret
		end,
		on_use = function(item, inc) self:onUseTalent(item, inc) end,
		no_tooltip = self.no_tooltip,
	}

	local vsep1 = Separator.new{dir="horizontal", size=self.ih - 20}
	local vsep2 = Separator.new{dir="horizontal", size=self.ih - 20}
	local hsep = Separator.new{dir="vertical", size=180}

	self.b_stat = Button.new{can_focus = false, can_focus_mouse=true, text="능력치: "..self.actor.unused_stats, fct=function() end, on_select=function()
		local str = desc_stats
		if self.no_tooltip then
			self.c_desc:erase()
			self.c_desc:switchItem(str, str, true)
		elseif self.b_stat.last_display_x then
			game:tooltipDisplayAtMap(self.b_stat.last_display_x + self.b_stat.w, self.b_stat.last_display_y, str)
		end
	end}
	self.b_class = Button.new{can_focus = false, can_focus_mouse=true, text="직업기술 점수: "..self.actor.unused_talents, fct=function() end, on_select=function()
		local str = desc_class
		if self.no_tooltip then
			self.c_desc:erase()
			self.c_desc:switchItem(str, str, true)
		elseif self.b_stat.last_display_x then
			game:tooltipDisplayAtMap(self.b_stat.last_display_x + self.b_stat.w, self.b_stat.last_display_y, str)
		end
	end}
	self.b_generic = Button.new{can_focus = false, can_focus_mouse=true, text="일반기술 점수: "..self.actor.unused_generics, fct=function() end, on_select=function()
		local str = desc_generic
		if self.no_tooltip then
			self.c_desc:erase()
			self.c_desc:switchItem(str, str, true)
		elseif self.b_stat.last_display_x then
			game:tooltipDisplayAtMap(self.b_stat.last_display_x + self.b_stat.w, self.b_stat.last_display_y, str)
		end
	end}
	self.b_types = Button.new{can_focus = false, can_focus_mouse=true, text="기술계열 점수: "..self.actor.unused_talents_types, fct=function() end, on_select=function()
		local str = desc_types
		if self.no_tooltip then
			self.c_desc:erase()
			self.c_desc:switchItem(str, str, true)
		elseif self.b_stat.last_display_x then
			game:tooltipDisplayAtMap(self.b_stat.last_display_x + self.b_stat.w, self.b_stat.last_display_y, str)
		end
	end}


	local ret = {
		{left=-10, top=0, ui=self.b_stat},
		{left=0, top=self.b_stat.h+10, ui=self.c_stat},

		{left=self.c_stat, top=40, ui=vsep1},

		{left=vsep1, top=0, ui=self.b_class},
		{left=vsep1, top=self.b_class.h + 10, ui=self.c_ctree},

		{left=self.c_ctree, top=40, ui=vsep2},

		{left=580, top=0, ui=self.b_generic},
		{left=vsep2, top=self.b_generic.h + 10, ui=self.c_gtree},

		{left=330, top=0, ui=self.b_types},

		{right=0, bottom=0, ui=self.b_prodigies},
	}
	if self.b_inscriptions then table.insert(ret, {right=self.b_prodigies.w, bottom=0, ui=self.b_inscriptions}) end

	if self.no_tooltip then
		local vsep3 = Separator.new{dir="horizontal", size=self.ih - 20}
		self.c_desc = TextzoneList.new{ focus_check = true, scrollbar = true, width=self.iw - 200 - 530 - 40, height = self.ih - (self.b_prodigies and 0 or self.b_prodigies.h + 5), dest_area = { h = self.ih } }
		ret[#ret+1] = {right=0, top=0, ui=self.c_desc}
		ret[#ret+1] = {right=self.c_desc.w + 5, top=40, ui=vsep3}
	end

	return ret
end

function _M:getStatDesc(item)
	local stat_id = item.stat
	if not stat_id then return item.desc end
	local text = tstring{}
	text:merge(item.desc:toTString())
	text:add(true, true)
	local diff = self.actor:getStat(stat_id, nil, nil, true) - self.actor_dup:getStat(stat_id, nil, nil, true)
	local color = diff >= 0 and {"color", "LIGHT_GREEN"} or {"color", "RED"}
	local dc = {"color", "LAST"}

	text:add("현재 값 : ", {"color", "LIGHT_GREEN"}, ("%d"):format(self.actor:getStat(stat_id)), dc, true)
	text:add("기본 값 : ", {"color", "LIGHT_GREEN"}, ("%d"):format(self.actor:getStat(stat_id, nil, nil, true)), dc, true, true)

	text:add({"color", "LIGHT_BLUE"}, "능력치 상승시 : ", dc, true)
	if stat_id == self.actor.STAT_CON then
		local multi_life = 4 + (self.actor.inc_resource_multi.life or 0)
		text:add("최대 생명력 : ", color, ("%0.2f"):format(diff * multi_life), dc, true)
		text:add("물리 내성 : ", color, ("%0.2f"):format(diff * 0.35), dc, true)
	elseif stat_id == self.actor.STAT_WIL then
		if self.actor:knowTalent(self.actor.T_MANA_POOL) then
			local multi_mana = 5 + (self.actor.inc_resource_multi.mana or 0)
			text:add("최대 마나 : ", color, ("%0.2f"):format(diff * multi_mana), dc, true)
		end
		if self.actor:knowTalent(self.actor.T_STAMINA_POOL) then
			local multi_stamina = 2.5 + (self.actor.inc_resource_multi.stamina or 0)
			text:add("최대 체력 : ", color, ("%0.2f"):format(diff * multi_stamina), dc, true)
		end
		if self.actor:knowTalent(self.actor.T_PSI_POOL) then
			local multi_psi = 1 + (self.actor.inc_resource_multi.psi or 0)
			text:add("최대 염력 : ", color, ("%0.2f"):format(diff * multi_psi), dc, true)
		end
		text:add("정신력 : ", color, ("%0.2f"):format(diff * 0.7), dc, true)
		text:add("정신 내성 : ", color, ("%0.2f"):format(diff * 0.35), dc, true)
		text:add("주문 내성 : ", color, ("%0.2f"):format(diff * 0.35), dc, true)
		if self.actor.use_psi_combat then
			text:add("정확도 : ", color, ("%0.2f"):format(diff * 0.35), dc, true)
		end
	elseif stat_id == self.actor.STAT_STR then
		text:add("물리력 : ", color, ("%0.2f"):format(diff), dc, true)
		text:add("최대 소지 무게 : ", color, ("%0.2f"):format(diff * 1.8), dc, true)
		text:add("물리 내성 : ", color, ("%0.2f"):format(diff * 0.35), dc, true)
	elseif stat_id == self.actor.STAT_CUN then
		text:add("치명타 확률 : ", color, ("%0.2f"):format(diff * 0.3), dc, true)
		text:add("정신 내성 : ", color, ("%0.2f"):format(diff * 0.35), dc, true)
		text:add("정신력 : ", color, ("%0.2f"):format(diff * 0.4), dc, true)
		if self.actor.use_psi_combat then
			text:add("정확도 : ", color, ("%0.2f"):format(diff * 0.35), dc, true)
		end
	elseif stat_id == self.actor.STAT_MAG then
		text:add("주문 내성 : ", color, ("%0.2f"):format(diff * 0.35), dc, true)
		text:add("주문력 : ", color, ("%0.2f"):format(diff * 1), dc, true)
	elseif stat_id == self.actor.STAT_DEX then
		text:add("회피도 : ", color, ("%0.2f"):format(diff * 0.35), dc, true)
		text:add("장거리 회피 : ", color, ("%0.2f"):format(diff * 0.35), dc, true)
		text:add("정확도 : ", color, ("%0.2f"):format(diff), dc, true)
		text:add("치명타 피해 무시 : ", color, ("%0.2f%%"):format(diff * 0.3), dc, true)
	end

	if self.actor.player and self.desc_def and self.desc_def.getStatDesc and self.desc_def.getStatDesc(stat_id, self.actor) then
		text:add({"color", "LIGHT_BLUE"}, "직업 능력 : ", dc, true)
		text:add(self.desc_def.getStatDesc(stat_id, self.actor))
	end
	return text
end


function _M:getTalentDesc(item)
	local text = tstring{}

 	text:add({"color", "GOLD"}, {"font", "bold"}, util.getval(item.rawname, item), "\n[", util.getval(item.oriname, item), "]", {"color", "LAST"}, {"font", "normal"}) --@@ 기술 설명에 '한글이름[원문이름]'이 나오도록 추가
	text:add(true, true)

	if item.type then
		text:add({"color",0x00,0xFF,0xFF}, "기술계열", true)
		text:add({"color",0x00,0xFF,0xFF}, "하나의 기술계열에는 여러 개의 습득할 수 있는 기술들이 포함되어 있습니다.\n10, 20, 36 레벨 마다 1점씩 받을 수 있는 기술계열 점수를 통해, 새로운 기술계열을 배우거나 기존의 기술계열을 강화시킬 수 있습니다.", true, true, {"color", "WHITE"})

		if self.actor.talents_types_def[item.type].generic then
			text:add({"color",0x00,0xFF,0xFF}, "일반기술 계통", true)
			text:add({"color",0x00,0xFF,0xFF}, "일반기술로는 캐릭터의 기본적인 능력을 향상시키거나, 여러 가지 유용한 기술들을 사용할 수 있습니다. 일반기술은 누구나 배울 수 있는 기술들을 의미하며 레벨 상승시 1 점을 받지만, 5 의 배수 레벨에는 일반기술 점수를 받지 못합니다. 일반기술 점수를 추가로 획득할 수 있는 물건이나 기회를 발견할 수도 있습니다.", true, true, {"color", "WHITE"})
		else
			text:add({"color",0x00,0xFF,0xFF}, "직업기술 계통", true)
			text:add({"color",0x00,0xFF,0xFF}, "직업기술은 당신이 선택한 직업의 핵심적인 능력들을 나타내며, 새로운 전투법이나 주문, 강화효과 등을 얻을 수 있습니다. 레벨 상승시 1 점을 받으며, 5 의 배수 레벨에서는 2 점을 받습니다. 직업기술 점수를 추가로 획득할 수 있는 물건이나 기회를 발견할 수도 있습니다.", true, true, {"color", "WHITE"})
		end

		text:add(self.actor:getTalentTypeFrom(item.type).description)

	else
		local t = self.actor:getTalentFromId(item.talent)

		if self:isUnlearnable(t, true) then
			local max = tostring(self.actor:lastLearntTalentsMax(t.generic and "generic" or "class"))
			text:add({"color","LIGHT_BLUE"}, "이 기술은 최근에 습득했으므로, 아직 습득을 취소할 수 있습니다.", true, "최근에 배운 ", t.generic and "일반" or "직업", "기술 ", max, " 가지는 습득 취소가 가능합니다.", {"color","LAST"}, true, true)
		elseif t.no_unlearn_last then
			text:add({"color","YELLOW"}, "이 기술은 영구적으로 세계에 영향을 끼치기에, 한번 배우면 다시는 습득을 취소할 수 없습니다.", {"color","LAST"}, true, true)
		end

		local traw = self.actor:getTalentLevelRaw(t.id)
		local diff = function(i2, i1, res)
			res:add({"color", "LIGHT_GREEN"}, i1, {"color", "LAST"}, " [->", {"color", "YELLOW_GREEN"}, i2, {"color", "LAST"}, "]")
		end
		if traw == 0 then
			local req = self.actor:getTalentReqDesc(item.talent, 1):toTString():tokenize(" ()[]")
			text:add{"color","WHITE"}
			text:add({"font", "bold"}, "처음 기술 레벨 : ", tostring(traw+1), {"font", "normal"})
			text:add(true)
			text:merge(req)
			text:merge(self.actor:getTalentFullDescription(t, 1))
		elseif traw < self:getMaxTPoints(t) then
			local req = self.actor:getTalentReqDesc(item.talent):toTString():tokenize(" ()[]")
			local req2 = self.actor:getTalentReqDesc(item.talent, 1):toTString():tokenize(" ()[]")
			text:add{"color","WHITE"}
			text:add({"font", "bold"}, traw == 0 and "다음 기술 레벨" or "현재 기술 레벨 : ", tostring(traw), " [-> ", tostring(traw + 1), "]", {"font", "normal"})
			text:add(true)
			text:merge(req2:diffWith(req, diff))
			text:merge(self.actor:getTalentFullDescription(t, 1):diffWith(self.actor:getTalentFullDescription(t), diff))
		else
			local req = self.actor:getTalentReqDesc(item.talent)
			text:add({"font", "bold"}, "현재 기술 레벨 : "..traw, {"font", "normal"})
			text:add(true)
			text:merge(req)
			text:merge(self.actor:getTalentFullDescription(t))
		end
	end

	return text
end

function _M:onUseTalent(item, inc)
	if item.type then
		self:learnType(item.type, inc)
		item.shown = (self.actor.__hidden_talent_types[item.type] == nil and self.actor:knowTalentType(item.type)) or (self.actor.__hidden_talent_types[item.type] ~= nil and not self.actor.__hidden_talent_types[item.type])
		local t = (item.isgeneric==0 and self.c_gtree or self.c_ctree)
		item.shown = not item.shown t:onExpand(item, inc)
		t:redrawAllItems()
	elseif item.talent then
		self:learnTalent(item.talent, inc)
		local t = (item.isgeneric==0 and self.c_gtree or self.c_ctree)
		t:redrawAllItems()
	elseif item.stat then
		self:incStat(item.stat, inc and 1 or -1)
		self.c_stat:redrawAllItems()
		self.c_ctree:redrawAllItems()
		self.c_gtree:redrawAllItems()
	end

	self.b_stat.text = "능력치: "..self.actor.unused_stats
	self.b_stat:generate()
	self.b_class.text = "직업기술 점수: "..self.actor.unused_talents
	self.b_class:generate()
	self.b_generic.text = "일반기술 점수: "..self.actor.unused_generics
	self.b_generic:generate()
	self.b_types.text = "기술계열 점수: "..self.actor.unused_talents_types
	self.b_types:generate()
end

function _M:updateTooltip()
	self.c_gtree:updateTooltip()
	self.c_ctree:updateTooltip()
	self.c_stat:updateTooltip()
	if self.focus_ui and self.focus_ui.ui and self.focus_ui.ui.updateTooltip then self.focus_ui.ui:updateTooltip() end
end
