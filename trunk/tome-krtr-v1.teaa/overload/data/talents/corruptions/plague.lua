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
	name = "Virulent Disease",
	kr_display_name = "악성 질병",
	type = {"corruption/plague", 1},
	require = corrs_req1,
	points = 5,
	vim = 8,
	cooldown = 3,
	random_ego = "attack",
	tactical = { ATTACK = {BLIGHT = 2} },
	requires_target = true,
	no_energy = true,
	range = function(self, t) return 4 + math.floor(self:getTalentLevel(t)) end,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t)}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		local diseases = {{self.EFF_WEAKNESS_DISEASE, "str"}, {self.EFF_ROTTING_DISEASE, "con"}, {self.EFF_DECREPITUDE_DISEASE, "dex"}}
		local disease = rng.table(diseases)

		-- Try to rot !
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, engine.Map.ACTOR)
			if not target then return end
			if target:canBe("disease") then
				local str, dex, con = not target:hasEffect(self.EFF_WEAKNESS_DISEASE) and target:getStr() or 0, not target:hasEffect(self.EFF_DECREPITUDE_DISEASE) and target:getDex() or 0, not target:hasEffect(self.EFF_ROTTING_DISEASE) and target:getCon() or 0

				if str >= dex and str >= con then
					disease = {self.EFF_WEAKNESS_DISEASE, "str"}
				elseif dex >= str and dex >= con then
					disease = {self.EFF_DECREPITUDE_DISEASE, "dex"}
				elseif con > 0 then
					disease = {self.EFF_ROTTING_DISEASE, "con"}
				end

				target:setEffect(disease[1], 6, {src=self, dam=self:spellCrit(7 + self:combatTalentSpellDamage(t, 6, 65)), [disease[2]]=self:combatTalentSpellDamage(t, 5, 35), apply_power=self:combatSpellpower()})
			else
				game.logSeen(target, "%s 질병에 걸리지 않았습니다!", target.name:capitalize())
			end
			game.level.map:particleEmitter(px, py, 1, "slime")
		end)
		game:playSoundNear(self, "talents/slime")

		return true
	end,
	info = function(self, t)
		return ([[순수한 오염물질의 화살을 발사하여 6 턴 동안 대상에게 매 턴마다 %0.2f 황폐화 피해를 주고, 힘, 체격, 민첩 능력치 중 하나를 %d 감소시키는 질병에 걸리게 만듭니다.
		질병은 3 번까지 중첩되고, 똑같은 질병이 중첩되서 걸리지는 않습니다. 또한, 대상에게 가장 중요한 능력치를 우선적으로 감소시킵니다.
		이 효과는 주문력 능력치의 영향을 받아 증가합니다.]]):
		format(damDesc(self, DamageType.BLIGHT, 7 + self:combatTalentSpellDamage(t, 6, 65)), self:combatTalentSpellDamage(t, 5, 35))
	end,
}

newTalent{
	name = "Cyst Burst",
	kr_display_name = "종양 터뜨리기",
	type = {"corruption/plague", 2},
	require = corrs_req2,
	points = 5,
	vim = 18,
	cooldown = 9,
	range = 7,
	radius = function(self, t)
		return 1 + math.floor(self:getTalentLevelRaw(t) / 2)
	end,
	tactical = { ATTACK = function(self, t, target)
		-- Count the number of diseases on the target
		local val = 0
		for eff_id, p in pairs(target.tmp) do
			local e = target.tempeffect_def[eff_id]
			if e.subtype.disease then
				val = val + 1
			end
		end
		return val
	end },
	requires_target = true,
	target = function(self, t)
		-- Target trying to combine the bolt and the ball disease spread
		return {type="ballbolt", radius=self:getTalentRadius(t), range=self:getTalentRange(t)}
	end,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t)}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		local dam = self:spellCrit(self:combatTalentSpellDamage(t, 15, 85))
		local diseases = {}

		-- Try to rot !
		local source = nil
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, engine.Map.ACTOR)
			if not target then return end

			for eff_id, p in pairs(target.tmp) do
				local e = target.tempeffect_def[eff_id]
				if e.subtype.disease then
					diseases[#diseases+1] = {id=eff_id, params=p}
				end
			end

			if #diseases > 0 then
				DamageType:get(DamageType.BLIGHT).projector(self, px, py, DamageType.BLIGHT, dam * #diseases)
				game.level.map:particleEmitter(px, py, 1, "slime")
			end
			source = target
		end)

		if #diseases > 0 then
			self:project({type="ball", radius=self:getTalentRadius(t), range=self:getTalentRange(t)}, x, y, function(px, py)
				local target = game.level.map(px, py, engine.Map.ACTOR)
				if not target or target == source or target == self or (self:reactionToward(target) >= 0) then return end

				for _, disease in ipairs(diseases) do
					if disease.id == self.EFF_WEAKNESS_DISEASE or disease.id == self.EFF_DECREPITUDE_DISEASE or disease.id == self.EFF_ROTTING_DISEASE or disease.id == self.EFF_EPIDEMIC then
						target:setEffect(disease.id, 6, {src=self, dam=disease.params.dam, str=disease.params.str, dex=disease.params.dex, con=disease.params.con, heal_factor=disease.params.heal_factor, resist=disease.params.resist, apply_power=self:combatSpellpower()})
					end
				end
				game.level.map:particleEmitter(px, py, 1, "slime")
			end)
		end
		game:playSoundNear(self, "talents/slime")

		return true
	end,
	info = function(self, t)
		return ([[대상의 질병을 더욱 활성화시켜, 대상이 가지고 있는 질병마다 %0.2f 황폐화 피해를 줍니다.
		또한 주변 %d 칸 반경의 적들에게 노화성, 심약성, 부패성, 전염성 질병들을 옮깁니다.
		피해량은 주문력 능력치의 영향을 받아 증가합니다.]]):
		format(damDesc(self, DamageType.BLIGHT, self:combatTalentSpellDamage(t, 15, 85)), self:getTalentRadius(t))
	end,
}

newTalent{
	name = "Catalepsy",
	kr_display_name = "경직성 질병",
	type = {"corruption/plague", 3},
	require = corrs_req3,
	points = 5,
	vim = 20,
	cooldown = 15,
	range = 6,
	tactical = { DISABLE = function(self, t, target)
		-- Make sure the target has a disease
		for eff_id, p in pairs(target.tmp) do
			local e = target.tempeffect_def[eff_id]
			if e.subtype.disease then
				return 2
			end
		end
	end },
	direct_hit = true,
	requires_target = true,
	getDamage = function(self, t) return (100 + self:combatTalentSpellDamage(t, 0, 50)) / 100 end,
	getDuration = function(self, t) return math.floor(2 + self:getTalentLevel(t) / 2) end,
	getRadius = function(self, t) return 2 + math.floor(self:getTalentLevel(t)/3) end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=t.getRadius(self, t)}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		local source = nil
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, engine.Map.ACTOR)
			if not target then return end

			-- List all diseases
			local diseases = {}
			for eff_id, p in pairs(target.tmp) do
				local e = target.tempeffect_def[eff_id]
				if e.subtype.disease then
					diseases[#diseases+1] = {id=eff_id, params=p}
				end
			end
			-- Make them EXPLODE !!!
			for i, d in ipairs(diseases) do
				target:removeEffect(d.id)
				DamageType:get(DamageType.BLIGHT).projector(self, px, py, DamageType.BLIGHT, d.params.dam * d.params.dur * t.getDamage(self, t))
			end

			if #diseases > 0 and target:canBe("stun") then
				target:setEffect(target.EFF_STUNNED, t.getDuration(self, t), {apply_power=self:combatSpellpower()})
			elseif #diseases > 0 then
				game.logSeen(target, "%s 기절하지 않았습니다!", target.name:capitalize())
			end
			game.level.map:particleEmitter(px, py, 1, "slime")
		end)
		game:playSoundNear(self, "talents/slime")

		return true
	end,
	info = function(self, t)
		local radius = t.getRadius(self, t)
		local duration = t.getDuration(self, t)
		local damage = t.getDamage(self, t)
		return ([[주변 %d 칸 반경의 적들이 근육 경직성 질병에 감염되어 %d 턴 동안 기절하고, 질병에 의해 서서히 받아야 했던 피해량의 %d%% 만큼을 한번에 받습니다.]]):
		format(radius, duration, damage * 100)
	end,
}

newTalent{
	name = "Epidemic",
	kr_display_name = "유행성 질병",
	type = {"corruption/plague", 4},
	require = corrs_req4,
	points = 5,
	vim = 20,
	cooldown = 13,
	range = 6,
	radius = 2,
	tactical = { ATTACK = {BLIGHT = 2} },
	requires_target = true,
	do_spread = function(self, t, carrier)
		-- List all diseases
		local diseases = {}
		for eff_id, p in pairs(carrier.tmp) do
			local e = carrier.tempeffect_def[eff_id]
			if e.subtype.disease then
				diseases[#diseases+1] = {id=eff_id, params=p}
			end
		end

		if #diseases == 0 then return end
		self:project({type="ball", radius=self:getTalentRadius(t)}, carrier.x, carrier.y, function(px, py)
			local target = game.level.map(px, py, engine.Map.ACTOR)
			if not target or target == carrier or target == self then return end

			local disease = rng.table(diseases)
			local params = disease.params
			params.src = self
			local disease_spread = {
				src=self, dam=disease.params.dam, str=disease.params.str, dex=disease.params.dex, con=disease.params.con, apply_power=self:combatSpellpower(),
				heal_factor=disease.params.heal_factor, burst=disease.params.burst, rot_timer=disease.params.rot_timer, resist=disease.params.resist, make_ghoul=disease.params.make_ghoul,
			}
			if target:canBe("disease") then
				target:setEffect(disease.id, 6, disease_spread)
			else
				game.logSeen(target, "%s 질병을 저항했습니다!", target.name:capitalize())
			end
			game.level.map:particleEmitter(px, py, 1, "slime")
		end)
	end,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t)}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		-- Try to rot !
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, engine.Map.ACTOR)
			if not target or (self:reactionToward(target) >= 0) then return end
			target:setEffect(self.EFF_EPIDEMIC, 6, {src=self, dam=self:spellCrit(self:combatTalentSpellDamage(t, 15, 70)), heal_factor=40 + self:getTalentLevel(t) * 4, resist=30 + self:getTalentLevel(t) * 6, apply_power=self:combatSpellpower()})
			game.level.map:particleEmitter(px, py, 1, "slime")
		end)
		game:playSoundNear(self, "talents/slime")

		return true
	end,
	info = function(self, t)
		return ([[대상에게 전염성이 강한 질병을 감염시켜, 6 턴 동안 매 턴마다 %0.2f 피해를 줍니다.
		이 질병에 의한 것을 제외한 황폐화 피해를 받을 때마다, 2 칸 반경의 다른 적들에게 질병이 전염됩니다.
		이 질병에 감염된 적들은 생명력 회복 효율이 %d%% 감소하며, 질병 저항력이 %d%% 감소합니다.
		이 질병은 엄청나게 강력하기 때문에, 대상의 질병 저항력을 완전히 무시합니다.
		피해량은 주문력 능력치, 전염될 확률은 대상에게 가한 황폐화 피해량의 영향을 받아 증가합니다.]]):
		format(damDesc(self, DamageType.BLIGHT, self:combatTalentSpellDamage(t, 15, 70)), 40 + self:getTalentLevel(t) * 4, 30 + self:getTalentLevel(t) * 6)
	end,
}
