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

newTalent{
	name = "Sleep",
	kr_display_name = "재우기",
	type = {"psionic/dreaming", 1},
	points = 5, 
	require = psi_wil_req1,
	cooldown = function(self, t) return math.max(4, 9 - self:getTalentLevelRaw(t)) end,
	psi = 5,
	tactical = { DISABLE = {sleep = 1} },
	direct_hit = true,
	requires_target = true,
	range = 7,
	radius = function(self, t) return 1 + math.floor(self:getTalentLevel(t)/4) end,
	target = function(self, t) return {type="ball", radius=self:getTalentRadius(t), range=self:getTalentRange(t), talent=t} end,
	getDuration = function(self, t) return 2 + math.ceil(self:getTalentLevel(t)/3) end,
	getInsomniaPower= function(self, t)
		local t = self:getTalentFromId(self.T_SANDMAN)
		local reduction = t.getInsomniaPower(self, t)
		return 20 - reduction
	end,
	getSleepPower = function(self, t) 
		local power = self:combatTalentMindDamage(t, 5, 25)
		if self:knowTalent(self.T_SANDMAN) then
			local t = self:getTalentFromId(self.T_SANDMAN)
			power = power * t.getSleepPowerBonus(self, t)
		end
		return math.ceil(power)
	end,
	doContagiousSleep = function(self, target, p, t)
		local tg = {type="ball", radius=1, talent=t}
		self:project(tg, target.x, target.y, function(tx, ty)
			local t2 = game.level.map(tx, ty, Map.ACTOR)
			if t2 and t2 ~= target and rng.percent(p.contagious) and t2:canBe("sleep") and not t2:hasEffect(t2.EFF_SLEEP) then
				t2:setEffect(t2.EFF_SLEEP, p.dur, {src=self, power=p.power, waking=p.waking, insomnia=p.insomnia, no_ct_effect=true, apply_power=self:combatMindpower()})
				game.level.map:particleEmitter(target.x, target.y, 1, "generic_charge", {rm=0, rM=0, gm=100, gM=200, bm=200, bM=255, am=35, aM=90})
			end
		end)
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		--Contagious?
		local is_contagious = 0
		if self:getTalentLevel(t) >= 5 then
			is_contagious = 25
		end
		--Restless?
		local is_waking =0
		if self:knowTalent(self.T_RESTLESS_NIGHT) then
			local t = self:getTalentFromId(self.T_RESTLESS_NIGHT)
			is_waking = t.getDamage(self, t)
		end

		local power = self:mindCrit(t.getSleepPower(self, t))
		self:project(tg, x, y, function(tx, ty)
			local target = game.level.map(tx, ty, Map.ACTOR)
			if target then
				if target:canBe("sleep") then
					target:setEffect(target.EFF_SLEEP, t.getDuration(self, t), {src=self, power=power,  contagious=is_contagious, waking=is_waking, insomnia=t.getInsomniaPower(self, t), no_ct_effect=true, apply_power=self:combatMindpower()})
					game.level.map:particleEmitter(target.x, target.y, 1, "generic_charge", {rm=0, rM=0, gm=180, gM=255, bm=180, bM=255, am=35, aM=90})
				else
					game.logSeen(self, "%s 잠들지 않았습니다!", target.name:capitalize())
				end
			end
		end)
		game:playSoundNear(self, "talents/dispel")
		return true
	end,
	info = function(self, t)
		local radius = self:getTalentRadius(t)
		local duration = t.getDuration(self, t)
		local power = t.getSleepPower(self, t)
		local insomnia = t.getInsomniaPower(self, t)
		return([[주변 %d 칸 반경의 적들을 %d 턴 동안 재웁니다. 수면 중에는 행동할 수 없게 되며, %d 피해를 받을 때마다 수면의 지속시간이 1 턴씩 줄어들게 됩니다.
		수면이 끝나면, 대상은 불면증 상태가 되어 잠든 시간 동안 %d%% 수면 저항력을 얻게 됩니다. (최대 10 턴)
		기술 레벨이 5 이상이면 수면이 전염성을 띄게 되어, 매 턴마다 25%% 확률로 잠든 대상 근처의 잠들지 않은 적이 잠들게 됩니다.
		피해 한계량은 정신력 능력치의 영향을 받아 증가합니다.]]):format(radius, duration, power, insomnia)
	end,
}

newTalent{
	name = "Lucid Dreamer",
	kr_display_name = "자각몽",
	type = {"psionic/dreaming", 2},
	points = 5,
	require = psi_wil_req2,
	mode = "sustained",
	sustain_psi = 20,
	cooldown = 12,
	tactical = { BUFF=2 },
	getPower = function(self, t) return self:combatTalentMindDamage(t, 5, 25) end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/heal")
		local power = t.getPower(self, t)
		local ret = {
			phys = self:addTemporaryValue("combat_physresist", power),
			mental = self:addTemporaryValue("combat_mentalresist", power),
			spell = self:addTemporaryValue("combat_spellresist", power),
			dreamer = self:addTemporaryValue("lucid_dreamer", power),
			sleep = self:addTemporaryValue("sleep", 1),
		}
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("combat_physresist", p.phys)
		self:removeTemporaryValue("combat_mentalresist", p.mental)
		self:removeTemporaryValue("combat_spellresist", p.spell)
		self:removeTemporaryValue("lucid_dreamer", p.dreamer)
		self:removeTemporaryValue("sleep", p.sleep)
		return true
	end,
	info = function(self, t)
		local power = t.getPower(self, t)
		return ([[자각몽에 빠져, 수면 상태이면서 행동할 수 있는 상태가 됩니다. 불면증 상태에 면역이 되고, 불면증 상태의 적에게 %d%% 더 많은 피해를 줄 수 있으며, 물리 내성, 주문 내성, 정신 내성이 %d 증가합니다.
		잠든 상대에게 더욱 치명적인 기술들에는 취약해집니다. (내면의 악마, 잠들지 못하는 공포, 밤의 공포 등)
		내성 증가량은 정신력 능력치의 영향을 받아 증가합니다.]]):format(power, power)
	end,
}

newTalent{
	name = "Dream Walk",
	kr_display_name = "꿈 속을 걷는 자",
	type = {"psionic/dreaming", 3},
	points = 5, 
	require = psi_wil_req3,
	psi= 10,
	cooldown = 10,
	tactical = { ESCAPE = 1, CLOSEIN = 1 },
	range = 7,
	radius = function(self, t) return math.max(0, 7 - math.floor(self:getTalentLevel(t))) end,
	requires_target = true,
	target = function(self, t)
		return {type="hit", range=self:getTalentRange(t)}
	end,
	direct_hit = true,
	is_teleport = true,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		if not self:hasLOS(x, y) or game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move") then
			game.logPlayer(self, "보이지 않는 곳입니다.")
			return nil
		end
		local __, x, y = self:canProject(tg, x, y)
		local teleport = self:getTalentRadius(t)
		target = game.level.map(x, y, Map.ACTOR)
		if (target and target:attr("sleep")) or game.zone.is_dream_scape then
			teleport = 0
		end
		
		game.level.map:particleEmitter(x, y, 1, "generic_teleport", {rm=0, rM=0, gm=180, gM=255, bm=180, bM=255, am=35, aM=90})

		-- since we're using a precise teleport we'll look for a free grid first
		local tx, ty = util.findFreeGrid(x, y, 5, true, {[Map.ACTOR]=true})
		if tx and ty then
			if not self:teleportRandom(tx, ty, teleport) then
				game.logSeen(self, "꿈 속의 세계로 이동하지 못했습니다!")
			end
		end

		game.level.map:particleEmitter(self.x, self.y, 1, "generic_teleport", {rm=0, rM=0, gm=180, gM=255, bm=180, bM=255, am=35, aM=90})
		game:playSoundNear(self, "talents/teleport")

		return true
	end,
	info = function(self, t)
		local radius = self:getTalentRadius(t)
		return ([[꿈 속의 세계를 통해 이동하여, 선택 지역 근처로 순간이동 합니다. (순간이동 정확도 : %d)
		대상이 수면 중이라면, 무조건 수면 중인 대상 근처로 순간이동 합니다.]]):format(radius)
	end,
}

newTalent{
	name = "Dream Prison",
	kr_display_name = "꿈의 감옥",
	type = {"psionic/dreaming", 4},
	points = 5,
	require = psi_wil_req4,
	mode = "sustained",
	sustain_psi = 40,
	cooldown = function(self, t) return 50 - self:getTalentLevelRaw(t) * 5 end,
	tactical = { DISABLE = function(self, t, target) if target and target:attr("sleep") then return 4 else return 0 end end},
	range = 7,
	requires_target = true,
	target = function(self, t)
		return {type="ball", radius=self:getTalentRange(t), range=0}
	end,
	direct_hit = true,
	getDrain = function(self, t) return 5 - math.min(4, self:getTalentLevel(t)/2) end,
	remove_on_zero = true,
	activate = function(self, t)
		game:playSoundNear(self, "talents/spell_generic")
		local drain = self:getMaxPsi() * t.getDrain(self, t) / 100
		local ret = {
			drain = self:addTemporaryValue("psi_regen", -drain),
		}
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("psi_regen", p.drain)
		return true
	end,
	info = function(self, t)
		local drain = t.getDrain(self, t)
		return ([[범위 내의 모든 수면 중인 적들을 꿈의 감옥에 가둬, 감옥의 지속시간 동안 깨어나지 못하게 만듭니다.
		지속시간 동안 매 턴마다 최대 염력의 %0.2f%% 에 해당하는 염력이 소진되며, 염력 집중이 필요합니다. (이동하거나, 1 턴 이상 걸리는 기술을 사용하거나, 도구를 사용하면 집중이 깨집니다)
		악몽의 지속 피해나 재우기의 수면 전염 등 매 턴마다 적용되는 효과들은, 이 기술을 사용해도 그 지속시간이 늘어나지 않습니다.]]):format(drain)
	end,
}
