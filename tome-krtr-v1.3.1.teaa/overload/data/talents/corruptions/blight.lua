-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2015 Nicolas Casalini
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
	name = "Dark Ritual",
	kr_name = "어둠의 의식",
	type = {"corruption/blight", 1},
	mode = "sustained",
	require = corrs_req1,
	points = 5,
	tactical = { ATTACK = 2 },
	sustain_vim = 20,
	cooldown = 30,
	activate = function(self, t)
		game:playSoundNear(self, "talents/slime")
		local ret = {
			per = self:addTemporaryValue("combat_critical_power", self:combatTalentSpellDamage(t, 20, 60)),
		}
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("combat_critical_power", p.per)
		return true
	end,
	info = function(self, t)
		return ([[주문 치명타의 피해량 배수를 %d%% 상승시켜, 더 강력한 치명타 공격을 할 수 있게 됩니다.
		상승량은 주문력의 영향을 받아 증가합니다.]]):
		format(self:combatTalentSpellDamage(t, 20, 60))
	end,
}

newTalent{
	name = "Corrupted Negation",
	kr_name = "타락한 금제",
	type = {"corruption/blight", 2},
	require = corrs_req2,
	points = 5,
	cooldown = 10,
	vim = 30,
	range = 10,
	radius = 3,
	tactical = { ATTACKAREA = {BLIGHT = 1}, DISABLE = 2 },
	requires_target = true,
	target = function(self, t)
		return {type="ball", radius=self:getTalentRadius(t), range=self:getTalentRange(t), talent=t}
	end,
	getRemoveCount = function(self, t) return math.floor(self:combatTalentScale(t, 1, 5, "log")) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local dam = self:spellCrit(self:combatTalentSpellDamage(t, 28, 120))
		local nb = t.getRemoveCount(self,t)
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end

			DamageType:get(DamageType.BLIGHT).projector(self, px, py, DamageType.BLIGHT, dam)

			local effs = {}

			-- Go through all spell effects
			for eff_id, p in pairs(target.tmp) do
				local e = target.tempeffect_def[eff_id]
				if e.type == "magical" or e.type == "physical" then
					effs[#effs+1] = {"effect", eff_id}
				end
			end

			-- Go through all sustained spells
			for tid, act in pairs(target.sustain_talents) do
				if act then
					effs[#effs+1] = {"talent", tid}
				end
			end

			for i = 1, nb do
				if #effs == 0 then break end
				local eff = rng.tableRemove(effs)

				if self:checkHit(self:combatSpellpower(), target:combatSpellResist(), 0, 95, 5) then
					target:crossTierEffect(target.EFF_SPELLSHOCKED, self:combatSpellpower())
					if eff[1] == "effect" then
						target:removeEffect(eff[2])
					else
						target:forceUseTalent(eff[2], {ignore_energy=true})
					end
				end
			end
		end)
		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(x, y, tg.radius, "circle", {zdepth=6, oversize=1, a=130, appear=8, limit_life=8, speed=5, img="green_demon_fire_circle", radius=tg.radius})
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[타락한 힘의 돌풍을 만들어내 전방 3 칸 반경에 %0.2f 황폐 속성 피해를 주고, 물리적 효과나 마법적 효과를 최대 %d 개 까지 없애버립니다.
		대상은 주문 내성으로 각각의 효과에 대해 저항할 확률이 있습니다.
		피해량은 주문력의 영향을 받아 증가합니다.]]):format(damDesc(self, DamageType.BLIGHT, self:combatTalentSpellDamage(t, 28, 120)), t.getRemoveCount(self, t))
	end,
}

newTalent{
	name = "Corrosive Worm",
	kr_name = "부식성 벌레",
	type = {"corruption/blight", 3},
	require = corrs_req3,
	points = 5,
	cooldown = 10,
	vim = 12,
	range = 10,
	tactical = { ATTACK = {ACID = 2} },
	requires_target = true,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end
			target:setEffect(target.EFF_CORROSIVE_WORM, 10, {src=self, dam=self:spellCrit(self:combatTalentSpellDamage(t, 10, 60)), explosion=self:spellCrit(self:combatTalentSpellDamage(t, 10, 230))})
		end)
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[대상에게 부식성 벌레를 감염시켜, 10 턴 동안 매 턴마다 %0.2f 산성 피해를 줍니다.
		감염된 도중에 대상이 죽을 경우, 폭발하여 주변 4 칸 반경에 %0.2f 산성 피해를 줍니다.
		피해량은 주문력의 영향을 받아 증가하며, 치명타 효과가 발생할 수 있습니다.]]):
		format(damDesc(self, DamageType.ACID, self:combatTalentSpellDamage(t, 10, 60)), damDesc(self, DamageType.ACID, self:combatTalentSpellDamage(t, 10, 230)))
	end,
}

newTalent{
	name = "Poison Storm",
	kr_name = "독성 폭풍",
	type = {"corruption/blight", 4},
	require = corrs_req4,
	points = 5,
	vim = 36,
	cooldown = 30,
	range = 0,
	radius = 4,
	tactical = { ATTACKAREA = {NATURE = 2} },
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 6, 10)) end,
	action = function(self, t)
		local duration = t.getDuration(self, t)
		local radius = self:getTalentRadius(t)
		local dam = self:spellCrit(self:combatTalentSpellDamage(t, 12, 130))
		local actor = self
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			self.x, self.y, duration,
			DamageType.POISON, {dam=dam, apply_power=actor:combatSpellpower()},
			radius,
			5, nil,
			MapEffect.new{color_br=20, color_bg=220, color_bb=70, effect_shader="shader_images/poison_effect.png"},
			function(e)
				e.x = e.src.x
				e.y = e.src.y
				return true
			end,
			false
		)
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[격렬한 독성 폭풍이 시전자 주변 반경 %d 칸 내에서 %d 턴 동안 일어납니다. 폭풍에 닿은 대상은 %0.2f 자연 피해를 6 턴에 걸쳐 받게 됩니다.
		이 독은 중첩되며, 중첩될수록 독성이 더 강해지고 더 오랫동안 지속됩니다.
		피해량은 주문력의 영향을 받아 증가하며, 치명타 효과가 발생할 수 있습니다.]]): 
		format(self:getTalentRadius(t), t.getDuration(self, t), damDesc(self, DamageType.NATURE, self:combatTalentSpellDamage(t, 12, 130)))
	end,
}
