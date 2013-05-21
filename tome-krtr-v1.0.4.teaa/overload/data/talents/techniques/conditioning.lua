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

require "engine.krtrUtils"

newTalent{
	name = "Vitality",
	kr_name = "활력",
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
		return ([[중독, 질병, 출혈 상태의 지속 시간이 %d%% 감소합니다.
		추가적으로, 현재 생명력이 최대 생명력의 50%% 밑으로 떨어지면 생명력 재생이 %0.2f, 치유 효율이 %d%% 올라가며, %d 턴 동안 유지됩니다.
		생명력 재생과 치유 효율 상승량은 체격 능력치의 영향을 받아 증가합니다.]]):
		format(wounds, regen, healmod, duration)
	end,
}

newTalent{
	name = "Daunting Presence",
	kr_name = "위협적인 존재감",
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
	on_pre_use = function(self, t, silent) if t.getMinimumLife(self, t) > self.life then if not silent then game.logPlayer(self, "부상이 심하여 적을 위협할 수 없습니다.") end return false end return true end,
	do_daunting_presence = function(self, t)
		local tg = {type="ball", range=0, radius=t.getRadius(self, t), friendlyfire=false, talent=t}
		self:project(tg, self.x, self.y, function(px, py)
			local target = game.level.map(px, py, engine.Map.ACTOR)
			if target then
				if target:canBe("fear") then
					target:setEffect(target.EFF_INTIMIDATED, 4, {apply_power=self:combatAttackStr(), power=t.getPenalty(self, t), no_ct_effect=true})
					game.level.map:particleEmitter(target.x, target.y, 1, "flame")
				else
					game.logSeen(target, "%s 주눅들지 않았습니다!", (target.kr_name or target.name):capitalize():addJosa("가"))
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
		return ([[어떠한 공격에도 꿈쩍하지 않는 당신을 보고, 적들이 두려움에 빠집니다. 
		최대 생명력의 5%% 이상에 해당하는 피해를 한 번에 받으면, 반경 %d 칸 이내의 적들이 두려움에 빠져 물리력, 정신력, 주문력을 4 턴 동안 %d 만큼 잃게 됩니다.
		현재 생명력이 %d 밑으로 떨어지면 위협적인 존재감이 사라져서, 기술을 유지할 수 없게 됩니다. 
		두려움 효과는 체격 능력치의 영향을 받아 증가합니다.]]):
		format(radius, penalty, min_life)
	end,
}

newTalent{
	name = "Unflinching Resolve",
	kr_name = "불굴의 의지",
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
			end
		end
	end,
	info = function(self, t)
		local chance = t.getChance(self, t)
		return ([[부정적인 상태 효과로부터 빠르게 회복할 수 있게 됩니다. 
		매 턴마다 %d%% 확률로 기절 효과에서 벗어날 수 있게 되며, 기술 레벨이 2 이상일 때는 실명, 3 이상일 때는 혼란, 4 이상일 때는 속박, 그리고 5 이상일 때는 감속 효과를 추가로 해제합니다. 
		매 턴마다 단 한 개의 효과만 해제할 수 있으며, 해제 확률은 체격 능력치의 영향을 받아 증가합니다.]]):
		format(chance)
	end,
}

newTalent{
	name = "Adrenaline Surge", -- no stamina cost; it's main purpose is to give the player an alternative means of using stamina based talents
	kr_name = "솟구치는 아드레날린",
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
		return ([[아드레날린 분비를 자극하여, 물리력을 %d 증가시키고 %d 턴 동안 육체의 한계를 넘어 전투를 지속할 수 있게 됩니다.
		체력이 바닥나도 유지형 기술들이 해제되지 않으며, 체력 대신 생명력을 소모하여 기술을 사용할 수 있게 됩니다.
		물리력은 체격 능력치의 영향을 받아 증가합니다.
		이 기술은 턴을 소모하지 않고 즉시 사용할 수 있습니다.]]):
		format(attack_power, duration)
	end,
}
