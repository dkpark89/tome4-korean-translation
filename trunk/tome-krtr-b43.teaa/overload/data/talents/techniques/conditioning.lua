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

newTalent{
	name = "Vitality",
	display_name = "활력",
	type = {"technique/conditioning", 1},
	require = techs_con_req1,
	mode = "passive",
	points = 5,
	getWoundReduction = function(self, t) return self:getTalentLevel(t)/10 end,
	getHealMod = function(self, t) return self:combatTalentStatDamage(t, "con", 10, 50) end,
	getLifeRegen = function(self, t) return math.decimals(self:combatTalentStatDamage(t, "con", 2, 20), 2) end,
	getDuration = function(self, t) return 2 + math.ceil(self:getTalentLevel(t)) end,
	do_vitality_recovery = function(self, t)
		self:setEffect(self.EFF_RECOVERY, t.getDuration(self, t), {heal_mod = t.getHealMod(self, t), regen = t.getLifeRegen(self, t)})
	end,
	info = function(self, t)
		local wounds = t.getWoundReduction(self, t) * 100
		local regen = t.getLifeRegen(self, t)
		local healmod = t.getHealMod(self, t)
		local duration = t.getDuration(self, t)
		return ([[중독, 질병, 출혈 상태에서 더 빠르게 회복합니다(지속 시간 %d%% 감소). 추가로 생명력이 50%% 밑으로 떨어지면, 생명력 재생이 %0.2f, 치유량 증가가 %d%% 증가되며 %d턴 동안 유지됩니다.
		치유량 증가와 생명력 재생 효과는 체격 능력치에 영향을 받아 감소됩니다.]]):
		format(wounds, regen, healmod, duration)
	end,
}

newTalent{
	name = "Daunting Presence",
	display_name = "위협적인 존재감",
	type = {"technique/conditioning", 2},
	require = techs_con_req2,
	points = 5,
	mode = "sustained",
	sustain_stamina = 20,
	cooldown = 8,
	tactical = { DEFEND = 2, DISABLE = 1, },
	range = 0,
	getRadius = function(self, t) return math.ceil(self:getTalentLevel(t)/2) end,
	getPenalty = function(self, t) return self:combatTalentStatDamage(t, "con", 5, 30) end,
	getMinimumLife = function(self, t)
		return self.max_life * (0.5 - (self:getTalentLevel(t)/20))
	end,
	on_pre_use = function(self, t, silent) if t.getMinimumLife(self, t) > self.life then if not silent then game.logPlayer(self, "이 기술을 사용하기엔 너무 심한 부상을 입었습니다.") end return false end return true end,
	do_daunting_presence = function(self, t)
		local tg = {type="ball", range=0, radius=t.getRadius(self, t), friendlyfire=false, talent=t}
		self:project(tg, self.x, self.y, function(px, py)
			local target = game.level.map(px, py, engine.Map.ACTOR)
			if target then
				if target:canBe("fear") then
					target:setEffect(target.EFF_INTIMIDATED, 4, {apply_power=self:combatAttackStr(), power=t.getPenalty(self, t), no_ct_effect=true})
					game.level.map:particleEmitter(target.x, target.y, 1, "flame")
				else
					game.logSeen(target, "%s에게 위협적인 존재감을 드러냈지만, 소용이 없었습니다!", (target.display_name or target.name):capitalize())
				end
			end
		end)
	end,
	activate = function(self, t)
		local ret = {	}
		return ret
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		local radius = t.getRadius(self, t)
		local penalty = t.getPenalty(self, t)
		local min_life = t.getMinimumLife(self, t)
		return ([[공격에도 꿈쩍하지 않는 당신을 보고 적들이 두려움에 빠집니다. 최대 생명력의 5%% 이상을 피해를 단번에 받으면, 반경 %d칸 이내의 적들이 두려움에 떨게 되어 물리력, 정신력, 주문력을 4턴 동안 %d만큼 잃게 됩니다.
		생명력이 %d 밑으로 떨어지면 위협적인 존재감이 사라져서, 기술 유지가 해제됩니다. 두려움 효과는 체격 능력치에 영향을 받아 증가됩니다.]]):
		format(radius, penalty, min_life)
	end,
}

newTalent{
	name = "Unflinching Resolve",
	display_name = "단호한 결의",
	type = {"technique/conditioning", 3},
	require = techs_con_req3,
	mode = "passive",
	points = 5,
	getChance = function(self, t) return self:combatTalentStatDamage(t, "con", 20, 80) end,
	do_unflinching_resolve = function(self, t)
		local effs = {}
		-- Go through all spell effects
		for eff_id, p in pairs(self.tmp) do
			local e = self.tempeffect_def[eff_id]
			if e.status == "detrimental" then
				if e.subtype.stun then 
					effs[#effs+1] = {"effect", eff_id}
				elseif e.subtype.blind and self:getTalentLevel(t) >=2 then
					effs[#effs+1] = {"effect", eff_id}
				elseif e.subtype.confusion and self:getTalentLevel(t) >=3 then
					effs[#effs+1] = {"effect", eff_id}
				elseif e.subtype.pin and self:getTalentLevel(t) >=4 then
					effs[#effs+1] = {"effect", eff_id}
				elseif e.subtype.slow and self:getTalentLevel(t) >=5 then
					effs[#effs+1] = {"effect", eff_id}
				end
			end
		end
		
		if #effs > 0 then
			local eff = rng.tableRemove(effs)
			if eff[1] == "effect" and rng.percent(t.getChance(self, t)) then
				self:removeEffect(eff[2])
				game.logSeen(self, "%s has recovered!", self.name:capitalize())
				game.logSeen(self, "%s 회복되었습니다!", (self.display_name or self.name):capitalize():addJosa("가"))
			end
		end
	end,
	info = function(self, t)
		local chance = t.getChance(self, t)
		return ([[여러가지 불리한 효과에서 빠르게 회복할 수 있게 됩니다. 매 턴마다 %d%% 확률로 기절 효과에서 벗어나며,
		기술 레벨이 2 이상일 때는 실명, 3 이상일 때는 혼란, 4 이상일 때는 속박, 그리고 5 이상일 때는 감속 효과를 추가로 해제합니다. 
		매 턴마다 단 한개의 효과만 해제할 수 있으며, 해제 확률은 체격 능력치에 영향을 받아 증가됩니다.]]):
		format(chance)
	end,
}

newTalent{
	name = "Adrenaline Surge", -- no stamina cost; it's main purpose is to give the player an alternative means of using stamina based talents
	display_name = "솟구치는 아드레날린",
	type = {"technique/conditioning", 4},
	require = techs_con_req4,
	points = 5,
	cooldown = 24,
	tactical = { STAMINA = 1, BUFF = 2 },
	getAttackPower = function(self, t) return self:combatTalentStatDamage(t, "con", 5, 25) end,
	getDuration = function(self, t) return 2 + math.ceil(self:getTalentLevel(t)) end,
	no_energy = true,
	action = function(self, t)
		self:setEffect(self.EFF_ADRENALINE_SURGE, t.getDuration(self, t), {power = t.getAttackPower(self, t)})
		return true
	end,
	info = function(self, t)
		local attack_power = t.getAttackPower(self, t)
		local duration = t.getDuration(self, t)
		return ([[아드레날린 분비를 자극하여, 물리력을 %d 증가시키며 %d턴 동안 피로의 한계를 넘어 전투를 지속할 수 있게 됩니다.
		체력이 바닥나도 유지형 기술들이 해제되지 않으며, 생명력을 체력 대신 소모하여 기술을 사용할 수 있게 됩니다.
		증가되는 물리력은 체격 능력치에 영향을 받습니다.
		이 기술은 턴을 소모하지 않고 즉시 사용할 수 있습니다.]]):
		format(attack_power, duration)
	end,
}
