-- ToME - Tales of Middle-Earth
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
	name = "Instill Fear",
	kr_name = "공포 주입",
	type = {"cursed/fears", 1},
	require = cursed_wil_req1,
	points = 5,
	random_ego = "attack",
	cooldown = 6,
	hate = 8,
	range = 8,
	radius = function(self, t) return 2 end,
	tactical = { DISABLE = 2 },
	getDuration = function(self, t)
		return 8
	end,
	getParanoidAttackChance = function(self, t)
		return math.min(60, self:combatTalentMindDamage(t, 30, 50))
	end,
	getDespairResistAllChange = function(self, t)
		return -self:combatTalentMindDamage(t, 15, 40)
	end,
	hasEffect = function(self, t, target)
		if not target then return false end
		if target:hasEffect(target.EFF_PARANOID) then return true end
		if target:hasEffect(target.EFF_DISPAIR) then return true end
		if target:hasEffect(target.EFF_TERRIFIED) then return true end
		if target:hasEffect(target.EFF_DISTRESSED) then return true end
		if target:hasEffect(target.EFF_HAUNTED) then return true end
		if target:hasEffect(target.EFF_TORMENTED) then return true end
		return false
	end,
	applyEffect = function(self, t, target)
		if not target:canBe("fear") then
			game.logSeen(target, "#F53CBE#%s 공포를 무시합니다!", (target.kr_name or target.name):capitalize():addJosa("가"))
			return true
		end
		
		local tHeightenFear = nil
		if self:knowTalent(self.T_HEIGHTEN_FEAR) then tHeightenFear = self:getTalentFromId(self.T_HEIGHTEN_FEAR) end
		local tTyrant = nil
		if self:knowTalent(self.T_TYRANT) then tTyrant = self:getTalentFromId(self.T_TYRANT) end
		local mindpowerChange = tTyrant and tTyrant.getMindpowerChange(self, tTyrant) or 0
		
		local mindpower = self:combatMindpower(1, mindpowerChange)
		if not target:checkHit(mindpower, target:combatMentalResist()) then
			game.logSeen(target, "%s 공포를 이겨냈습니다!", (target.kr_name or target.name):capitalize():addJosa("가"))
			return nil
		end
		
		local effects = {}
		if not target:hasEffect(target.EFF_PARANOID) then table.insert(effects, target.EFF_PARANOID) end
		if not target:hasEffect(target.EFF_DISPAIR) then table.insert(effects, target.EFF_DISPAIR) end
		if tHeightenFear and not target:hasEffect(target.EFF_TERRIFIED) then table.insert(effects, target.EFF_TERRIFIED) end
		if tHeightenFear and not target:hasEffect(target.EFF_DISTRESSED) then table.insert(effects, target.EFF_DISTRESSED) end
		if tTyrant and not target:hasEffect(target.EFF_HAUNTED) then table.insert(effects, target.EFF_HAUNTED) end
		if tTyrant and not target:hasEffect(target.EFF_TORMENTED) then table.insert(effects, target.EFF_TORMENTED) end
		
		if #effects == 0 then return nil end
		local effectId = rng.table(effects)
		
		local duration = t.getDuration(self, t)
		local eff = { source=self, duration=duration }
		if effectId == target.EFF_PARANOID then
			eff.attackChance = t.getParanoidAttackChance(self, t)
			eff.mindpower = mindpower
		elseif effectId == target.EFF_DISPAIR then
			eff.resistAllChange = t.getDespairResistAllChange(self, t)
		elseif effectId == target.EFF_TERRIFIED then
			eff.actionFailureChance = tHeightenFear.getTerrifiedActionFailureChance(self, tHeightenFear)
		elseif effectId == target.EFF_DISTRESSED then
			eff.saveChange = tHeightenFear.getDistressedSaveChange(self, tHeightenFear)
		elseif effectId == target.EFF_HAUNTED then
			eff.damage = tTyrant.getHauntedDamage(self, tTyrant)
		elseif effectId == target.EFF_TORMENTED then
			eff.count = tTyrant.getTormentedCount(self, tTyrant)
			eff.damage = tTyrant.getTormentedDamage(self, tTyrant)
			eff.counts = {}
			for i = 1, duration do
				eff.counts[i] = math.floor(eff.count / duration) + ((eff.count % duration >= i) and 1 or 0)
			end
		else
			print("* fears: failed to get effect", effectId)
		end
		
		target:setEffect(effectId, duration, eff)
		
		-- heightened fear
		if tHeightenFear and not target:hasEffect(target.EFF_HEIGHTEN_FEAR) then
			local turnsUntilTrigger = tHeightenFear.getTurnsUntilTrigger(self, tHeightenFear)
			target:setEffect(target.EFF_HEIGHTEN_FEAR, 1, { source=self, range=self:getTalentRange(tHeightenFear), turns=turnsUntilTrigger, turns_left=turnsUntilTrigger })
		end
		
		return effectId
	end,
	endEffect = function(self, t)
		local tHeightenFear = nil
		if self:knowTalent(self.T_HEIGHTEN_FEAR) then tHeightenFear = self:getTalentFromId(self.T_HEIGHTEN_FEAR) end
		if tHeightenFear then
			if not t.hasEffect(self, t) then
				-- no more fears
				self:removeEffect(self.EFF_HEIGHTEN_FEAR)
			end
		end
	end,
	requires_target = true,
	target = function(self, t) return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t} end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target or core.fov.distance(self.x, self.y, x, y) > self:getTalentRange(t) then return nil end
		
		self:project(
			tg, x, y,
			function(px, py)
				local actor = game.level.map(px, py, engine.Map.ACTOR)
				if actor and self:reactionToward(actor) < 0 and actor ~= self then
					if actor == target or rng.percent(25) then
						local tInstillFear = self:getTalentFromId(self.T_INSTILL_FEAR)
						tInstillFear.applyEffect(self, tInstillFear, actor)
					end
				end
			end,
			nil, nil)

		return true
	end,
	info = function(self, t)
		return ([[대상에게 공포를 심어, 공포 효과 중 무작위한 하나를 %d 턴 동안 겁니다. 25%% 확률로 %d 칸 반경 안에 있는 다른 적에게도 공포를 겁니다. 
		적들은 정신 내성으로 공포를 저항하려 하며, 여러 공포 효과가 한번에 걸릴 수도 있습니다.
		그리고, 두 가지 공포 효과를 사용할 수 있게 됩니다.
		- 피해망상 : %d%% 확률로, 대상이 피아를 가리지 않고 근처에 있는 개체를 근접 공격하게 만듭니다. 공격이 명중할 경우, 그 개체 역시 피해망상에 빠지게 됩니다. 
		- 절망 : 대상의 전체 저항력을 %d%% 감소시킵니다.
		공포 효과는 정신력 능력치의 영향을 받아 증가합니다.]]):format(t.getDuration(self, t), self:getTalentRadius(t),
		t.getParanoidAttackChance(self, t),
		-t.getDespairResistAllChange(self, t))
	end,
}

newTalent{
	name = "Heighten Fear",
	kr_name = "고조된 공포",
	type = {"cursed/fears", 2},
	require = cursed_wil_req2,
	mode = "passive",
	points = 5,
	range = function(self, t)
		return math.sqrt(self:getTalentLevel(t)) * 3
	end,
	getTurnsUntilTrigger = function(self, t)
		return 5
	end,
	getTerrifiedActionFailureChance = function(self, t)
		return math.min(50, self:combatTalentMindDamage(t, 20, 45))
	end,
	getDistressedSaveChange = function(self, t)
		return -self:combatTalentMindDamage(t, 15, 30)
	end,
	tactical = { DISABLE = 2 },
	info = function(self, t)
		local tInstillFear = self:getTalentFromId(self.T_INSTILL_FEAR)
		local range = self:getTalentRange(t)
		local turnsUntilTrigger = t.getTurnsUntilTrigger(self, t)
		local duration = tInstillFear.getDuration(self, tInstillFear)
		return ([[주변에 있는 모든 적들의 공포를 고조시킵니다. 대상이 하나 이상의 공포 효과에 걸려있으며, %d 턴 동안 시전자 시야 내의 %d 칸 반경에 대상이 있었을 경우 대상은 %d 턴 동안 새로운 공포 효과에 걸립니다.
		적들은 정신 내성으로 공포를 저항하려 하며, 고조된 공포를 통해 걸린 공포 효과 하나 당 다른 공포 효과에 걸릴 확률을 10%% 씩 감소시킵니다.
		그리고, 두 가지 새로운 공포 효과를 사용할 수 있게 됩니다.
		- 두려움 : %d%% 확률로 대상의 기술이나 공격이 실패하게 됩니다. 
		- 괴로움 : 대상의 모든 내성을 %d 감소시킵니다.
		공포 효과는 정신력 능력치의 영향을 받아 증가합니다.]]):format(turnsUntilTrigger, range, duration,
		t.getTerrifiedActionFailureChance(self, t),
		-t.getDistressedSaveChange(self, t))
	end,
}

newTalent{
	name = "Tyrant",
	kr_name = "폭군",
	type = {"cursed/fears", 3},
	mode = "passive",
	require = cursed_wil_req3,
	points = 5,
	on_learn = function(self, t)
	end,
	on_unlearn = function(self, t)
	end,
	getMindpowerChange = function(self, t)
		return math.floor(math.sqrt(self:getTalentLevel(t)) * 7)
	end,
	getHauntedDamage = function(self, t)
		return self:combatTalentMindDamage(t, 40, 60)
	end,
	getTormentedCount = function(self, t)
		return 4 + math.min(5, math.floor(math.pow(self:getTalentLevelRaw(t), 0.7)))
	end,
	getTormentedDamage = function(self, t)
		return self:combatTalentMindDamage(t, 40, 60)
	end,
	info = function(self, t)
		return ([[공포에 질린 적들을 지배합니다. 적이 공포 상태를 저항할 경우, 그 적을 상대로 할 때 한정으로 정신력이 %d 상승하게 됩니다.
		그리고, 두 가지 새로운 공포 효과를 사용할 수 있게 됩니다.
		- 불안 : 다른 공포에 걸릴 때마다, 불안에 빠져 %d 정신 피해를 받습니다. 이전에 걸려있던 공포에도 적용됩니다.
		- 격통 : %d 마리의 '격통을 주는 자' 가 나타나 대상을 공격합니다. 이들은 사라지기 전까지 %d 정신 피해를 줍니다.
		공포 효과는 정신력 능력치의 영향을 받아 증가합니다.]]):format(t.getMindpowerChange(self, t),
		t.getHauntedDamage(self, t),
		t.getTormentedCount(self, t), t.getTormentedDamage(self, t))
	end,
}

newTalent{
	name = "Panic",
	kr_name = "공황",
	type = {"cursed/fears", 4},
	require = cursed_wil_req4,
	points = 5,
	random_ego = "attack",
	cooldown = 20,
	hate =  1,
	range = 4,
	tactical = { DISABLE = 4 },
	getDuration = function(self, t)
		return 3 + math.floor(math.pow(self:getTalentLevel(t), 0.5) * 2.2)
	end,
	getChance = function(self, t)
		return math.min(60, math.floor(30 + (math.sqrt(self:getTalentLevel(t)) - 1) * 22))
	end,
	action = function(self, t)
		local range = self:getTalentRange(t)
		local duration = t.getDuration(self, t)
		local chance = t.getChance(self, t)
		self:project(
			{type="ball", radius=range}, self.x, self.y,
			function(px, py)
				local actor = game.level.map(px, py, engine.Map.ACTOR)
				if actor and self:reactionToward(actor) < 0 and actor ~= self then
					if not actor:canBe("fear") then
						game.logSeen(actor, "#F53CBE#%s 공황 상태를 무시합니다!", (actor.kr_name or actor.name):capitalize():addJosa("가"))
					elseif actor:checkHit(self:combatMindpower(), actor:combatMentalResist(), 0, 95) then
						actor:setEffect(actor.EFF_PANICKED, duration, {source=self,range=10,chance=chance})
					else
						game.logSeen(actor, "#F53CBE#%s 공황 상태를 저항합니다!", (actor.kr_name or actor.name):capitalize():addJosa("가"))
					end
				end
			end,
			nil, nil)
		return true
	end,
	info = function(self, t)
		local range = self:getTalentRange(t)
		local duration = t.getDuration(self, t)
		local chance = t.getChance(self, t)
		return ([[주변 %d 칸 반경의 적들을 %d 턴 동안 공황 상태에 빠트립니다. 정신 내성을 통한 저항에 실패한 적들은 매 턴마다 %d%% 확률로 정상적인 행동을 하지 못하고, 시전자에게서 멀어지려 하게 됩니다.]]):format(range, duration, chance)
	end,
}
