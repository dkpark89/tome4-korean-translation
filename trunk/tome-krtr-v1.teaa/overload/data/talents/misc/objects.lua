-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
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

newTalentType{ no_silence=true, is_spell=true, type="sher'tul/fortress", name = "fortress", description = "이일크구르의 능력입니다." }
newTalentType{ no_silence=true, is_spell=true, type="spell/objects", name = "object spells", description = "세상에 있는 여러가지 물건들에 부여되어 있는 주문입니다." }
newTalentType{ type="technique/objects", name = "object techniques", description = "세상에 있는 여러가지 물건들에 부여되어 있는 물리적 기술입니다." }
newTalentType{ type="wild-gift/objects", name = "object techniques", description = "세상에 있는 여러가지 물건들에 부여되어 있는 자연의 권능입니다." }

--local oldTalent = newTalent
--local newTalent = function(t) if type(t.hide) == "nil" then t.hide = true end return oldTalent(t) end

newTalent{
	name = "charms", short_name = "GLOBAL_CD",
	kr_display_name = "부적",
	type = {"spell/objects",1},
	points = 1,
	cooldown = 1,
	no_npc_use = true,
	hide = true,
	action = function(self, t)
		return true
	end,
	info = function(self, t)
		return ""
	end,
}


newTalent{
	name = "Arcane Supremacy",
	kr_display_name = "지고의 마법",
	type = {"spell/objects",1},
	points = 1,
	mana = 40,
	cooldown = 12,
	tactical = {
		BUFF = function(self, t, target)
			local nb = 0
			for eff_id, p in pairs(self.tmp) do
				local e = self.tempeffect_def[eff_id]
				if e.type == "magical" and e.status == "detrimental" then
					nb = nb + 1
				end
			end
			return nb
		end,
		CURE = function(self, t, target)
			local nb = 0
			for eff_id, p in pairs(self.tmp) do
				local e = self.tempeffect_def[eff_id]
				if e.type == "magical" and e.status == "detrimental" then
					nb = nb + 1
				end
			end
			return nb
		end
	},
	getRemoveCount = function(self, t) return math.floor(self:getTalentLevel(t)) end,
	action = function(self, t)
		local effs = {}
		local power = 5

		-- Go through all spell effects
		for eff_id, p in pairs(self.tmp) do
			local e = self.tempeffect_def[eff_id]
			if e.type == "magical" and e.status == "detrimental" then
				effs[#effs+1] = {"effect", eff_id}
			end
		end

		for i = 1, t.getRemoveCount(self, t) do
			if #effs == 0 then break end
			local eff = rng.tableRemove(effs)

			if eff[1] == "effect" then
				self:removeEffect(eff[2])
				power = power + 5
			end
		end

		self:setEffect(self.EFF_ARCANE_SUPREMACY, 10, {power=power})

		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local count = t.getRemoveCount(self, t)
		return ([[%d 개의 나쁜 마법적 상태효과를 제거하고, 10 턴 동안 마력을 강화하여 주문력과 주문 내성을 5 올립니다.
		제거한 상태효과 1 개 마다 주문력과 주문 내성이 5 만큼 추가로 상승합니다.]]):
		format(count)
	end,
}

newTalent{
	name = "Command Staff",
	kr_display_name = "지팡이 다루기",
	type = {"spell/objects", 1},
	cooldown = 5,
	points = 5,
	no_npc_use = true,
	no_unlearn_last = true,
	action = function(self, t)
		local staff = self:hasStaffWeapon()
		if not staff or not staff.wielder or not staff.wielder.learn_talent or not staff.wielder.learn_talent[self.T_COMMAND_STAFF] then
			game.logPlayer(self, "지팡이를 들고 있어야 합니다.")
			return
		end
		local state = {}
		local Chat = require("engine.Chat")
		local chat = Chat.new("command-staff", {name="Command Staff", kr_display_name="지팡이 다루기"}, self, {version=staff, state=state, co=coroutine.running()})
		local d = chat:invoke()
		if not coroutine.yield() then return nil end
		return true
	end,
	info = function(self, t)
		return ([[지팡이에 흐르는 마력을 전환합니다.]])
	end,
}

newTalent{
	name = "Ward",
	kr_display_name = "보호구역",
	type = {"spell/objects", 1},
	cooldown = function(self, t)
		return math.max(10, 28 - 3 * self:getTalentLevel(t))
	end,
	points = 5,
	hard_cap = 5,
	no_npc_use = true,
	action = function(self, t)
		local state = {}
		local Chat = require("engine.Chat")
		local chat = Chat.new("ward", {name="Ward", kr_display_name="보호"}, self, {version=self, state=state})
		local d = chat:invoke()
		local co = coroutine.running()
		--print("before d.unload, state.set_ward is ", state.set_ward)
		d.unload = function() coroutine.resume(co, state.set_ward) end
		--print("state.set_ward is ", state.set_ward)
		if not coroutine.yield() then return nil end
		return true
	end,
	info = function(self, t)
		return ([[시전자 주변에 특수한 속성 피해를 막아내는 보호구역을 만들어냅니다. 보호구역은 도구의 충전량만큼 해당 속성 공격을 무효화시킵니다.]])
	end,
}

newTalent{
	name = "Teleport to the ground", short_name = "YIILKGUR_BEAM_DOWN",
	kr_display_name = "지표면으로 순간이동",
	type = {"sher'tul/fortress", 1},
	points = 1,
	no_npc_use = true,
	action = function(self, t)
		return true
	end,
	info = function(self, t)
		return ([[이일크구르의 순간이동기를 사용하여, 지표면으로 이동합니다.]])
	end,
}

newTalent{
	name = "Block",
	kr_display_name = "막기",
	type = {"technique/objects", 1},
	cooldown = function(self, t)
		return 8 - util.bound(self:getTalentLevelRaw(t), 1, 5)
	end,
	points = 5,
	hard_cap = 5,
	range = 1,
	tactical = { ATTACK = 3, DEFEND = 3 },
	on_pre_use = function(self, t, silent) if not self:hasShield() then if not silent then game.logPlayer(self, "방패가 없으면 이 기술을 사용할 수 없습니다.") end return false end return true end,
	getProperties = function(self, t)
		local shield = self:hasShield()
		--if not shield then return nil end
		local p = {
			sp = (shield and shield.special_combat and shield.special_combat.spellplated or false),
			ref = (shield and shield.special_combat and shield.special_combat.reflective or false),
			br = (shield and shield.special_combat and shield.special_combat.bloodruned or false),
		}
		return p
	end,
	getBlockValue = function(self, t)
		local val = 0
		local shield1 = self:hasShield()
		if shield1 then val = val + (shield1.special_combat and shield1.special_combat.block or 0) end

		if not self:getInven("MAINHAND") then return val end
		local shield2 = self:getInven("MAINHAND")[1]
		if shield2 then val = val + (shield2.special_combat and shield2.special_combat.block or 0) end
		return val
	end,
	getBlockedTypes = function(self, t)
		local shield = self:hasShield()
		local bt = {[DamageType.PHYSICAL]=true}
		if not shield then return bt, "error!" end
		local shield2 = self:getInven("MAINHAND") and self:getInven("MAINHAND")[1]
		shield2 = shield2 and shield2.special_combat and shield2 or nil

		if not self:attr("spectral_shield") then
			if shield.wielder.resists then for res, v in pairs(shield.wielder.resists) do if v > 0 then bt[res] = true end end end
			if shield.wielder.on_melee_hit then for res, v in pairs(shield.wielder.on_melee_hit) do if v > 0 then bt[res] = true end end end
			if shield2 and shield2.wielder.resists then for res, v in pairs(shield2.wielder.resists) do if v > 0 then bt[res] = true end end end
			if shield2 and shield2.wielder.on_melee_hit then for res, v in pairs(shield2.wielder.on_melee_hit) do if v > 0 then bt[res] = true end end end
		else
			bt[DamageType.FIRE] = true
			bt[DamageType.LIGHTNING] = true
			bt[DamageType.COLD] = true
			bt[DamageType.ACID] = true
			bt[DamageType.NATURE] = true
			bt[DamageType.BLIGHT] = true
			bt[DamageType.LIGHT] = true
			bt[DamageType.DARKNESS] = true
			bt[DamageType.ARCANE] = true
			bt[DamageType.MIND] = true
			bt[DamageType.TEMPORAL] = true
		end

		local n = 0
		for t, _ in pairs(bt) do n = n + 1 end

		if n < 1 then return "(error 2)" end
		local e_string = ""
		if n == 1 then
			e_string = DamageType.dam_def[next(bt)].name
		else
			local list = table.keys(bt)
			for i = 1, #list do
				list[i] = DamageType.dam_def[list[i]].name
			end
			e_string = table.concat(list, ", ")
		end
		return bt, e_string
	end,
	action = function(self, t)
		local properties = t.getProperties(self, t)
		local bt, bt_string = t.getBlockedTypes(self, t)
		self:setEffect(self.EFF_BLOCKING, 1 + (self:knowTalent(self.T_ETERNAL_GUARD) and 1 or 0), {power = t.getBlockValue(self, t), d_types=bt, properties=properties})
		return true
	end,
	info = function(self, t)
		local properties = t.getProperties(self, t)
		local sp_text = ""
		local ref_text = ""
		local br_text = ""
		if properties.sp then
			sp_text = ("그리고, 공격을 막아내는 동안 주문 내성이 %d 증가합니다."):format(t.getBlockValue(self, t))
		end
		if properties.ref then
			ref_text = "그리고, 막아낸 모든 피해를 적에게 되돌려줍니다."
		end
		if properties.br then
			br_text = "그리고, 막아낸 피해만큼 생명력이 회복합니다."
		end
		local bt, bt_string = t.getBlockedTypes(self, t)
		return ([[방패를 들어, 공격을 1 턴 동안 막아냅니다. 모든 %s 공격을 %d 만큼 막아낼 수 있습니다.
		공격을 완벽하게 막아냈을 경우, 적이 1 턴 동안 반격에 취약해집니다. (일반 공격의 피해량이 200%% 로 증가)
		%s
		%s
		%s]]):format(bt_string, t.getBlockValue(self, t), sp_text, ref_text, br_text)
	end,
}

newTalent{
	short_name = "BLOOM_HEAL", image = "talents/regeneration.png",
	name = "Bloom Heal",
	kr_display_name = "꽃의 치료",
	type = {"wild-gift/objects", 1},
	points = 1,
	no_energy = true,
	cooldown = function(self, t) return 50 end,
	tactical = { HEAL = 2 },
	on_pre_use = function(self, t) return not self:hasEffect(self.EFF_REGENERATION) end,
	action = function(self, t)
		self:setEffect(self.EFF_REGENERATION, 6, {power=7 + self:getWil() * 0.5})
		return true
	end,
	info = function(self, t)
		return ([[자연의 힘을 불러내, 6 턴 동안 매 턴마다 %d 생명력을 회복합니다.
		생명력 회복량은 의지 능력치의 영향을 받아 증가합니다.]]):format(7 + self:getWil() * 0.5)
	end,
}

newTalent{
	image = "talents/mana_clash.png",
	name = "Destroy Magic",
	kr_display_name = "마법 파괴",
	type = {"wild-gift/objects", 1},
	points = 5,
	no_energy = true,
	tactical = { ATTACK = { ARCANE = 3 } },
	cooldown = function(self, t) return 50 end,
	tactical = { HEAL = 2 },
	target = function(self, t)
		return {type="hit", range=1, talent=t}
	end,
	action = function(self, t)
	self:getTalentLevel(t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(px, py)
			target:setEffect(target.EFF_SPELL_DISRUPTION, 8, {src=self, power = 8, max = 45+self:getTalentLevel(t)*5, apply_power=self:combatMindpower()})
			if rng.percent(30) and self:getTalentLevel(t)>2 then

			local effs = {}

			-- Go through all spell effects
				for eff_id, p in pairs(target.tmp) do
					local e = target.tempeffect_def[eff_id]
					if e.type == "magical" then
						effs[#effs+1] = {"effect", eff_id}
					end
				end
			if self:getTalentLevel(t) > 3 then --only do sustains at level 3+
				-- Go through all sustained spells
				for tid, act in pairs(target.sustain_talents) do
					if act then
						local talent = target:getTalentFromId(tid)
						if talent.is_spell then effs[#effs+1] = {"talent", tid} end
					end
				end
			end
				local eff = rng.tableRemove(effs)
				if eff then
					if eff[1] == "effect" then
						target:removeEffect(eff[2])
					else
						target:forceUseTalent(eff[2], {ignore_energy=true})
					end
				end
			end
				if self:getTalentLevel(t)>4 then
					if target.undead or target.construct then
						self:project({type="hit"}, target.x, target.y, engine.DamageType.ARCANE, 40+self:combatMindpower())
						if target:canBe("stun") then target:setEffect(target.EFF_STUNNED, 5, {apply_power=self:combatMindpower()}) end
						game.logSeen(self, "%s 시전 중이던 마법이 방해받았습니다!", (target.kr_display_name or target.name):capitalize():addJosa("가"))
					end
				end
		end, nil, {type="slime"})
		return true
	end,
	info = function(self, t)
		return ([[레벨에 따라, 대상에게 다양한 상태효과를 일으킵니다.]]):format(7 + self:getWil() * 0.5)
	end,
}

