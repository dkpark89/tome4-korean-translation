-- ToME - Tales of Maj'Eyal
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

newTalent{
	name = "Telekinetic Grasp",
	kr_name = "염동적 악력",
	type = {"psionic/other", 1},
	points = 1,
	cooldown = 0,
	psi = 0,
	type_no_req = true,
	no_unlearn_last = true,
	no_npc_use = true,
	filter = function(o) return (o.type == "weapon" or o.type == "gem") and o.subtype ~= "sling" end,
	action = function(self, t)
		local inven = self:getInven("INVEN")
		local ret = self:talentDialog(self:showInventory("염동력으로 무엇을 쥡니까??", inven, t.filter, function(o, item)
			local pf = self:getInven("PSIONIC_FOCUS")
			if not pf then return end
			-- Put back the old one in inventory
			local old = self:removeObject(pf, 1, true)
			if old then
				self:addObject(inven, old)
			end
--Note: error with set items -- set_list, on_set_broken, on_set_complete
			-- Fix the slot_forbid bug
			if o.slot_forbid then
				-- Store any original on_takeoff function
				if o.on_takeoff then
					o._old_on_takeoff = o.on_takeoff
				end
				-- Save the original slot_forbid
				o._slot_forbid = o.slot_forbid
				o.slot_forbid = nil
				-- And prepare the resoration of everything
				o.on_takeoff = function(self)
					-- Remove the slot forbid fix
					self.slot_forbid = self._slot_forbid
					self._slot_forbid = nil
					-- Run the original on_takeoff
					if self._old_on_takeoff then
						self.on_takeoff = self._old_on_takeoff
						self._old_on_takeoff = nil
						self:on_takeoff()
					-- Or remove on_takeoff entirely
					else
						self.on_takeoff = nil
					end
				end
			end

			o = self:removeObject(inven, item)
			-- Force "wield"
			self:addObject(pf, o)
			game.logSeen(self, "%s %s 장비했습니다.", self.name:capitalize(), o:getName{do_color=true})
			
			self:sortInven()
			self:talentDialogReturn(true)
		end))
		if not ret then return nil end
		return true
	end,
	info = function(self, t)
	return ([[염력을 이용해서, 무기나 보석을 들어올립니다.]])
	end,
}

newTalent{
	name = "Beyond the Flesh",
	kr_name = "육신의 힘을 넘어",
	type = {"psionic/other", 1},
	points = 1,
	mode = "sustained",
	cooldown = 0,
	sustain_psi = 0,
	range = 1,
	direct_hit = true,
	no_energy = true,
	no_unlearn_last = true,
	tactical = { BUFF = 3 },
	do_tk_strike = function(self, t)
		local tkweapon = self:getInven("PSIONIC_FOCUS")[1]
		if type(tkweapon) == "boolean" then tkweapon = nil end
		if not tkweapon or tkweapon.type ~= "weapon" or tkweapon.subtype == "mindstar" then return end

		local targnum = 1
		if self:hasEffect(self.EFF_PSIFRENZY) then targnum = self:hasEffect(self.EFF_PSIFRENZY).power end
		local speed, hit = nil, false
		local sound, sound_miss = nil, nil
		--dam = self:getTalentLevel(t)
		local tgts = {}
		local grids = core.fov.circle_grids(self.x, self.y, targnum, true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local a = game.level.map(x, y, Map.ACTOR)
			if a and self:reactionToward(a) < 0 then
				tgts[#tgts+1] = a
			end
		end end

		-- Randomly pick a target
		local tg = {type="hit", range=1, talent=t}
		for i = 1, targnum do
			if #tgts <= 0 then break end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)

			if self:getInven(self.INVEN_PSIONIC_FOCUS) then
				for i, o in ipairs(self:getInven(self.INVEN_PSIONIC_FOCUS)) do
					if o.combat and not o.archery then
						print("[PSI ATTACK] attacking with", o.name)
						self:attr("use_psi_combat", 1)
						local s, h = self:attackTargetWith(a, o.combat, nil, 1)
						self:attr("use_psi_combat", -1)
						speed = math.max(speed or 0, s)
						hit = hit or h
						if hit and not sound then sound = o.combat.sound
						elseif not hit and not sound_miss then sound_miss = o.combat.sound_miss end
						if not o.combat.no_stealth_break then self:breakStealth() end
						self:breakStepUp()
					end
				end
			else
				return nil
			end

		end
		return hit
	end,
	do_mindstar_grab = function(self, t, p)
		local p = self.sustain_talents[t.id]

		if self:hasEffect(self.EFF_PSIFRENZY) then
			if p.mindstar_grab then
				self:project({type="ball", radius=p.mindstar_grab.range}, self.x, self.y, function(px, py)
					local a = game.level.map(px, py, Map.ACTOR)
					if a and self:reactionToward(a) < 0 then
						local dist = core.fov.distance(self.x, self.y, px, py)
						if dist > 1 and rng.percent(p.mindstar_grab.chance) then
							local tx, ty = util.findFreeGrid(self.x, self.y, 5, true, {[Map.ACTOR]=true})
							if tx and ty and a:canBe("knockback") then
								a:move(tx, ty, true)
							end
						end
					end
				end)
			elseif self:getInven("PSIONIC_FOCUS") and self:getInven("PSIONIC_FOCUS")[1] and self:getInven("PSIONIC_FOCUS")[1].type == "gem" then
				local list = {}
				local gem = self:getInven("PSIONIC_FOCUS")[1]
				self:project({type="ball", radius=6}, self.x, self.y, function(px, py)
					local a = game.level.map(px, py, Map.ACTOR)
					if a and self:reactionToward(a) < 0 then
						local dist = core.fov.distance(self.x, self.y, px, py)
						list[#list+1] = {dist=dist, a=a}
					end
				end)
				if #list <= 0 then return end

				local color = gem.color_attributes or {}
				local bolt = {color.damage_type or 'MIND', color.particle or 'light'}

				table.sort(list, "dist")
				local a = list[1].a
				self:project({type="ball", range=6, radius=0, selffire=false, talent=t}, a.x, a.y, bolt[1], self:mindCrit(self:hasEffect(self.EFF_PSIFRENZY).damage), {type=bolt[2]})

			end
			return
		end

		if not p.mindstar_grab then return end
		if not rng.percent(p.mindstar_grab.chance) then return end

		local list = {}
		self:project({type="ball", radius=p.mindstar_grab.range}, self.x, self.y, function(px, py)
			local a = game.level.map(px, py, Map.ACTOR)
			if a and self:reactionToward(a) < 0 then
				local dist = core.fov.distance(self.x, self.y, px, py)
				if dist > 1 then list[#list+1] = {dist=dist, a=a} end
			end
		end)
		if #list <= 0 then return end

		table.sort(list, "dist")
		local a = list[#list].a
		local tx, ty = util.findFreeGrid(self.x, self.y, 5, true, {[Map.ACTOR]=true})
		if tx and ty and a:canBe("knockback") then
			a:move(tx, ty, true)
			game.logSeen(a, "%s %s 염동적 악력으로 끌어옵니다!", self.name:capitalize(), a.name)
		end
	end,
	callbackOnActBase = function(self, t)
		t.do_tk_strike(self, t)
		t.do_mindstar_grab(self, t)
	end,
	callbackOnWear = function(self, t, p)
		if self.__to_recompute_beyond_the_flesh then return end
		self.__to_recompute_beyond_the_flesh = true
		game:onTickEnd(function()
			self.__to_recompute_beyond_the_flesh = nil
			local p = self.sustain_talents[t.id]
			self:forceUseTalent(t.id, {ignore_energy=true, ignore_cd=true, no_talent_fail=true})
			if t.on_pre_use(self, t) then self:forceUseTalent(t.id, {ignore_energy=true, ignore_cd=true, no_talent_fail=true, talent_reuse=true}) end
		end)
	end,
	callbackOnTakeoff = function(self, t, p)
		if self.__to_recompute_beyond_the_flesh then return end
		self.__to_recompute_beyond_the_flesh = true
		game:onTickEnd(function()
			self.__to_recompute_beyond_the_flesh = nil
			local p = self.sustain_talents[t.id]
			self:forceUseTalent(t.id, {ignore_energy=true, ignore_cd=true, no_talent_fail=true})
			if t.on_pre_use(self, t) then self:forceUseTalent(t.id, {ignore_energy=true, ignore_cd=true, no_talent_fail=true, talent_reuse=true}) end
		end)
	end,
	on_pre_use = function (self, t)
		if not self:getInven("PSIONIC_FOCUS") then return false end
		local tkweapon = self:getInven("PSIONIC_FOCUS")[1]
		if type(tkweapon) == "boolean" then tkweapon = nil end
		if not tkweapon or (tkweapon.type ~= "weapon" and tkweapon.type ~= "gem") then
			return false
		end
		return true
	end,
	activate = function (self, t)
		local tk = self:getInven("PSIONIC_FOCUS") and self:getInven("PSIONIC_FOCUS")[1]
		if not tk then return false end

		local ret = {}
		if tk.type == "gem" then
			local power = (tk.material_level or 1) * 3 + math.ceil(self:callTalent(self.T_RESONANT_FOCUS, "bonus") / 5)
			self:talentTemporaryValue(ret, "inc_stats", {
				[self.STAT_STR] = power,
				[self.STAT_DEX] = power,
				[self.STAT_MAG] = power,
				[self.STAT_WIL] = power,
				[self.STAT_CUN] = power,
				[self.STAT_CON] = power,
			})
		elseif tk.subtype == "mindstar" then
			ret.mindstar_grab = {
				chance = (tk.material_level or 1) * 5 + 5 + self:callTalent(self.T_RESONANT_FOCUS, "bonus"),
				range = 2 + (tk.material_level or 1),
			}
		else
			self:talentTemporaryValue(ret, "use_psi_combat", 1)
		end
		return ret
	end,
	deactivate =  function (self, t)
		return true
	end,
	info = function(self, t)
		local base = [[물리 근접 무기, 마석, 혹은 보석을 염동력으로 쥐어 특수한 효과를 얻습니다.
		보석은 단계 당 모든 능력치를 +3 만큼 증가시킵니다.
		마석은 염동력으로 멀리 떨어진 적을 근접 공격이 가능한 거리로 끌어옵니다. (1 단계 마석의 경우 5% 확률로 2 칸 떨어진 곳에 있는 적을 끌어오며, 단계가 상승할 때마다 확률이 +5% / 사거리가 1 칸 추가됨)
		물리 근접 무기는 거의 독립적으로 움직이며, 매 턴마다 근처의 적들을 자동으로 공격합니다. 또한 무기의 정확도와 피해량을 결정하는 힘과 민첩 능력치는 의지와 교활함 능력치로 대체됩니다.]] 

		local o = self:getInven("PSIONIC_FOCUS") and self:getInven("PSIONIC_FOCUS")[1]
		if type(o) == "boolean" then o = nil end
		if not o then return base end

		local atk = 0
		local dam = 0
		local apr = 0
		local crit = 0
		local speed = 1
		if o.type == "gem" then
			local ml = o.material_level or 1
			base = base..([[염동력으로 쥐고 있는 보석이 모든 능력치를 +%d 상승시킵니다.]]):format(ml * 3)
		elseif o.subtype == "mindstar" then
			local ml = o.material_level or 1
			base = base..([[염동력으로 쥐고 있는 마석이 %d%% 확률로 최대 %d 칸 떨어진 곳에 있는 적을 끌어옵니다.]]):format((ml + 1) * 5, ml + 2)
		else
			self:attr("use_psi_combat", 1)
			atk = self:combatAttack(o.combat)
			dam = self:combatDamage(o.combat)
			apr = self:combatAPR(o.combat)
			crit = self:combatCrit(o.combat)
			speed = self:combatSpeed(o.combat)
			self:attr("use_psi_combat", -1)
			base = base..([[무기의 피해량과 정확도는 힘과 민첩 능력치 대신 의지와 교활함 능력치로 결정됩니다.
			현재 염동력으로 쥐고 있는 무기의 능력치는 다음과 같습니다.
			- 정확도 : %d
			- 피해량: %d
			- 방어도 관통 : %d
			- 치명타율 : %0.2f
			- 공격 속도 : %0.2f]]):
			format(atk, dam, apr, crit, speed)
		end
		return base
	end,

}
