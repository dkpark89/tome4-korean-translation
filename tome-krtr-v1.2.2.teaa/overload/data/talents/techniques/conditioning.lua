-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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
	getHealValues = function(self, t)  --base, fraction of max life
		return (self.life_rating or 10) + self:combatTalentStatDamage(t, "con", 2, 20), self:combatTalentLimit(t, 0.5, 0.2, 0.3)
	end,
	getWoundReduction = function(self, t) return self:combatTalentLimit(t, 1, 0.17, 0.5) end, -- Limit <100%
	getDuration = function(self, t) return 8 end,
	do_vitality_recovery = function(self, t)
		local baseheal, percent = t.getHealValues(self, t)
		self:setEffect(self.EFF_RECOVERY, t.getDuration(self, t), {power = baseheal, pct = percent / t.getDuration(self, t)})
	end,
	info = function(self, t)
		local wounds = t.getWoundReduction(self, t) * 100
		local baseheal, healpct = t.getHealValues(self, t)
		local duration = t.getDuration(self, t)
		local totalheal = baseheal + self.max_life*healpct/duration
		return ([[중독, 질병, 출혈 상태의 지속 시간이 %d%% 감소합니다.
		또한 생명력이 50%% 밑으로 떨어질 경우 기본적으로 %0.1f 생명력, 그리고 추가적으로 최대 생명력의 %0.1f%% 만큼을 (총합 : %0.1f 생명력) %d 턴 동안 매 턴마다 회복하게 됩니다.
		기본 생명력 회복량은 체격 능력치의 영향을 받아 증가합니다.]]): 
		format(wounds, baseheal, healpct/duration*100, totalheal, duration)
	end,
}

newTalent{
	name = "Unflinching Resolve",
	kr_name = "불굴의 의지",
	type = {"technique/conditioning", 2},
	require = techs_con_req2,
	mode = "passive",
	points = 5,
	getChance = function(self, t) return self:combatStatLimit("con", 1, .28, .745)*self:combatTalentLimit(t,100, 28,74.8) end, -- Limit < 100%
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
				elseif (e.subtype.slow or e.subtype.wound) and self:getTalentLevel(t) >=5 then
					effs[#effs+1] = {"effect", eff_id}
				end
			end
		end
		
		if #effs > 0 then
			local eff = rng.tableRemove(effs)
			if eff[1] == "effect" and rng.percent(t.getChance(self, t)) then
				self:removeEffect(eff[2])
				game.logSeen(self, "#ORCHID#%s 회복 되었습니다!#LAST#", (self.kr_name or self.name):capitalize():addJosa("가"))
			end
		end
	end,
	info = function(self, t)
		local chance = t.getChance(self, t)
		return ([[부정적인 상태 효과로부터 빠르게 회복할 수 있게 됩니다. 
		매 턴마다 %d%% 확률로 기절 효과에서 벗어날 수 있게 되며, 기술 레벨이 2 이상일 때는 실명, 3 이상일 때는 혼란, 4 이상일 때는 속박, 그리고 5 이상일 때는 감속이나 상처 효과를 추가로 해제합니다. 
		매 턴마다 단 한 개의 효과만 해제할 수 있으며, 해제 확률은 체격 능력치의 영향을 받아 증가합니다.]]):
		format(chance)
	end,
}

newTalent{
	name = "Daunting Presence",
	kr_name = "위협적인 존재감",
	type = {"technique/conditioning", 3},
	require = techs_con_req3,
	points = 5,
	mode = "sustained",
	sustain_stamina = 20,
	cooldown = 8,
	tactical = { DEFEND = 2, DISABLE = 1, },
	range = 0,
	getRadius = function(self, t) return math.ceil(self:combatTalentScale(t, 0.25, 2.3)) end,
	getPenalty = function(self, t) return self:combatTalentPhysicalDamage(t, 5, 36) end,
	getMinimumLife = function(self, t)
		return self.max_life * self:combatTalentLimit(t, 0.1, 0.45, 0.25) -- Limit > 10% life
	end,
	on_pre_use = function(self, t, silent) if t.getMinimumLife(self, t) > self.life then if not silent then game.logPlayer(self, "You are too injured to use this talent.") end return false end return true end,
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
		두려움 효과는 물리력의 영향을 받아 증가하고, 적들이 두려움에 빠질 확률은 힘 능력치의 영향을 받아 증가합니다.]]):
		format(radius, penalty, min_life)
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
	getDuration = function(self, t) return math.floor(self:combatTalentLimit(t, 24, 3, 7)) end, -- Limit < 24
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
