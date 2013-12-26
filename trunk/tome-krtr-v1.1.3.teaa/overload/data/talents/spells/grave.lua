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

local Object = require "mod.class.Object"

newTalent{
	name = "Chill of the Tomb",
	kr_name = "묘지의 냉기",
	type = {"spell/grave",1},
	require = spells_req1,
	points = 5,
	mana = 30,
	cooldown = 8,
	tactical = { ATTACKAREA = { COLD = 2 } },
	range = 7,
	radius = function(self, t)
		return math.floor(self:combatTalentScale(t, 2, 6, 0.5, 0, 0, true))
	end,
	proj_speed = 4,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=self:spellFriendlyFire(), talent=t, display={particle="bolt_ice", trail="icetrail"}}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 28, 280) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:projectile(tg, x, y, DamageType.COLD, self:spellCrit(t.getDamage(self, t)), function(self, tg, x, y, grids)
			game.level.map:particleEmitter(x, y, tg.radius, "iceflash", {radius=tg.radius, tx=x, ty=y})
		end)
		game:playSoundNear(self, "talents/ice")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local radius = self:getTalentRadius(t)
		return ([[대상 지역에 죽음의 기운이 실린 냉기 덩어리를 발사합니다. 냉기 덩어리는 천천히 이동하며, 폭발하여 주변 %d 칸 반경에 %0.2f 냉기 피해를 줍니다.
		피해량은 주문력의 영향을 받아 증가합니다.]]):
		format(radius, damDesc(self, DamageType.COLD, damage)) --@ 변수 순서 조정
	end,
}

newTalent{
	name = "Will o' the Wisp",
	kr_name = "윌 오 위습",
	type = {"spell/grave",2},
	require = spells_req2,
	mode = "sustained",
	points = 5,
	sustain_mana = 60,
	cooldown = 30,
	tactical = { BUFF = 3 },
	getParams = function(self, t) return util.bound(30 + self:getTalentLevel(t) * 10, 30, 100), 20 + self:combatTalentSpellDamage(t, 25, 300) end,
	summon = function(self, t, dam, src, killer)
		if not killer or not killer.faction or self:reactionToward(killer) >= 0 or self.dead then return end
		local minion = require("mod.class.NPC").new{
			name = "will o' the wisp",
			kr_name = "윌 오 위습",
			type = "undead", subtype = "ghost",
			blood_color = colors.GREY,
			display = "G", color=colors.WHITE,
			combat = { dam=1, atk=1, apr=1 },
			autolevel = "warriormage",
			ai = "dumb_talented_simple", ai_state = { talent_in=1, },
			dont_pass_target = true,
			movement_speed = 2,
			stats = { str=14, dex=18, mag=20, con=12 },
			rank = 2,
			size_category = 1,
			infravision = 10,
			can_pass = {pass_wall=70},
			resists = {all = 35, [DamageType.LIGHT] = -70, [DamageType.COLD] = 65, [DamageType.DARKNESS] = 65},
			no_breath = 1,
			stone_immune = 1,
			confusion_immune = 1,
			fear_immune = 1,
			teleport_immune = 0.5,
			disease_immune = 1,
			poison_immune = 1,
			stun_immune = 1,
			blind_immune = 1,
			cut_immune = 1,
			see_invisible = 80,
			undead = 1,
			will_o_wisp_dam = dam,
			talents = {T_WILL_O__THE_WISP_EXPLODE = 1},
		}
		local x, y = util.findFreeGrid(src.x or self.x, src.y or self.y, 5, true, {[Map.ACTOR]=true})
		if minion and x and y then
			necroSetupSummon(self, minion, x, y, lev, true)
			minion.on_die = nil
			minion.on_act = nil
			minion:setTarget(killer)
		end
	end,
	activate = function(self, t)
		local chance, dam = t.getParams(self, t)
		game:playSoundNear(self, "talents/spell_generic2")
		local ret = {
			chance = chance,
			dam = dam,
		}
		return ret
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		local chance, dam = t.getParams(self, t)
		return ([[주변에 언데드의 기운을 흩뿌립니다. 언데드 추종자가 이 범위 내에서 파괴되었을 경우, %d%% 확률로 윌 오 위습이 만들어집니다.
		윌 오 위습은 시야 내의 무작위한 적에게 접근하여 폭발하며, 적에게 %0.2f 냉기 피해를 줍니다.
		피해량은 주문량 능력치의 영향을 받아 증가합니다.]]):
		format(chance, damDesc(self, DamageType.COLD, dam))
	end,
}

-- Kinda copied from Creeping Darkness
newTalent{
	name = "Cold Flames",
	kr_name = "차가운 불꽃",
	type = {"spell/grave",3},
	require = spells_req3,
	points = 5,
	mana = 40,
	cooldown = 22,
	range = 5,
	radius = 3,
	tactical = { ATTACK = { COLD = 2 }, DISABLE = { stun = 1 } },
	requires_target = true,
	-- implementation of creeping darkness..used in various locations, but stored here
	canCreep = function(x, y, ignoreCreepingDark)
		-- not on map
		if not game.level.map:isBound(x, y) then return false end
		 -- already dark
		if not ignoreCreepingDark then
			if game.level.map:checkAllEntities(x, y, "coldflames") then return false end
		end
		 -- allow objects and terrain to block, but not actors
		if game.level.map:checkAllEntities(x, y, "block_move") and not game.level.map(x, y, Map.ACTOR) then return false end

		return true
	end,
	doCreep = function(tCreepingDarkness, self, useCreep)
		local start = rng.range(0, 8)
		for i = start, start + 8 do
			local x = self.x + (i % 3) - 1
			local y = self.y + math.floor((i % 9) / 3) - 1
			if not (x == self.x and y == self.y) and tCreepingDarkness.canCreep(x, y) then
				-- add new dark
				local newCreep
				if useCreep then
					 -- transfer some of our creep to the new dark
					newCreep = math.ceil(self.creep / 2)
					self.creep = self.creep - newCreep
				else
					-- just clone our creep
					newCreep = self.creep
				end
				tCreepingDarkness.createDark(self.summoner, x, y, self.damage, self.originalDuration, newCreep, self.creepChance, 0)
				return true
			end

			-- nowhere to creep
			return false
		end
	end,
	createDark = function(summoner, x, y, damage, duration, creep, creepChance, initialCreep)
		local e = Object.new{
			name = "cold flames",
			kr_name = "차가운 불꽃",
			canAct = false,
			canCreep = true,
			x = x, y = y,
			damage = damage,
			originalDuration = duration,
			duration = duration,
			creep = creep,
			creepChance = creepChance,
			summoner = summoner,
			summoner_gain_exp = true,
			act = function(self)
				local Map = require "engine.Map"

				self:useEnergy()

				-- apply damage to anything inside the darkness
				local actor = game.level.map(self.x, self.y, Map.ACTOR)
				if actor and actor ~= self.summoner and (not actor.summoner or actor.summoner ~= self.summoner) then
					self.summoner:project(actor, actor.x, actor.y, engine.DamageType.ICE, self.damage)
					--DamageType:get(DamageType.DARKNESS).projector(self.summoner, actor.x, actor.y, DamageType.DARKNESS, damage)
				end

				if self.duration <= 0 then
					-- remove
					if self.particles then game.level.map:removeParticleEmitter(self.particles) end
					game.level.map:remove(self.x, self.y, Map.TERRAIN+3)
					game.level:removeEntity(self)
					self.coldflames = nil
					--game.level.map:redisplay()
				else
					self.duration = self.duration - 1

					local tCreepingDarkness = self.summoner:getTalentFromId(self.summoner.T_COLD_FLAMES)

					if self.canCreep and self.creep > 0 and rng.percent(self.creepChance) then
						if not tCreepingDarkness.doCreep(tCreepingDarkness, self, true) then
							-- doCreep failed..pass creep on to a neighbor and stop creeping
							self.canCreep = false
							local start = rng.range(0, 8)
							for i = start, start + 8 do
								local x = self.x + (i % 3) - 1
								local y = self.y + math.floor((i % 9) / 3) - 1
								if not (x == self.x and y == self.y) and tCreepingDarkness.canCreep(x, y) then
									local dark = game.level.map:checkAllEntities(x, y, "coldflames")
									if dark and dark.canCreep then
										-- transfer creep
										dark.creep = dark.creep + self.creep
										self.creep = 0
										return
									end
								end
							end
						end
					end
				end
			end,
		}
		e.coldflames = e -- used for checkAllEntities to return the dark Object itself
		game.level:addEntity(e)
		game.level.map(x, y, Map.TERRAIN+3, e)

		-- add particles
		e.particles = Particles.new("coldflames", 1, { })
		e.particles.x = x
		e.particles.y = y
		game.level.map:addParticleEmitter(e.particles)

		-- do some initial creeping
		if initialCreep > 0 then
			local tCreepingDarkness = self.summoner:getTalentFromId(summoner.T_COLD_FLAMES)
			while initialCreep > 0 do
				if not tCreepingDarkness.doCreep(tCreepingDarkness, e, false) then
					e.canCreep = false
					e.initialCreep = 0
					break
				end
				initialCreep = initialCreep - 1
			end
		end
	end,

	getDarkCount = function(self, t) return math.floor(self:combatTalentScale(t, 6, 10)) end,
	getDamage = function(self, t)
		return self:combatTalentSpellDamage(t, 10, 90)
	end,
	action = function(self, t)
		local range = self:getTalentRange(t)
		local radius = self:getTalentRadius(t)
		local damage = {dam=t.getDamage(self, t), chance=25}
		local darkCount = t.getDarkCount(self, t)

		local tg = {type="ball", nolock=true, pass_terrain=false, nowarning=true, friendly_fire=true, default_target=self, range=range, radius=radius, talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, _, _, x, y = self:canProject(tg, x, y)

		-- get locations in line of movement from center
		local locations = {}
		local grids = core.fov.circle_grids(x, y, radius, true)
		for darkX, yy in pairs(grids) do for darkY, _ in pairs(grids[darkX]) do
			local l = line.new(x, y, darkX, darkY)
			local lx, ly = l()
			while lx and ly do
				if game.level.map:checkAllEntities(lx, ly, "block_move") then break end

				lx, ly = l()
			end
			if not lx and not ly then lx, ly = darkX, darkY end

			if lx == darkX and ly == darkY and t.canCreep(darkX, darkY) then
				locations[#locations+1] = {darkX, darkY}
			end
		end end

		darkCount = math.min(darkCount, #locations)
		if darkCount == 0 then return false end

		local empower = necroEssenceDead(self)
		if empower then
			damage.chance = 100
			empower()
		end
		for i = 1, darkCount do
			local location, id = rng.table(locations)
			table.remove(locations, id)
			t.createDark(self, location[1], location[2], damage, 8, 4, 70, 0)
		end

		game:playSoundNear(self, "talents/breath")
		return true
	end,
	info = function(self, t)
		local radius = self:getTalentRadius(t)
		local damage = t.getDamage(self, t)
		local darkCount = t.getDarkCount(self, t)
		return ([[대상 지역의 %d 칸 반경에, 차가운 불꽃이 서서히 일어나기 시작합니다. 차가운 불꽃은 턴 당 %d 개씩 생겨나면서 해당 지역에 %0.2f 냉기 피해를 주며, 적에게 빙결 상태효과를 가할 확률이 있습니다.
		피해량은 주문력의 영향을 받아 증가합니다.]]):format(radius, darkCount, damDesc(self, DamageType.COLD, damage)) --@ 변수 순서 조정
	end,
}

newTalent{
	name = "Vampiric Gift",
	kr_name = "흡혈 본능",
	type = {"spell/grave",4},
	require = spells_req4,
	points = 5,
	mode = "sustained",
	sustain_mana = 250,
	cooldown = 30,
	tactical = { BUFF = 3 },
	getParams = function(self, t) return self:combatTalentLimit(t, 100, 25, 45), self:combatLimit(self:combatTalentSpellDamage(t, 5, 30), 100, 0, 0, 18.65, 18.65) end, -- Limit chance and life leach to <100% each
	activate = function(self, t)
		local chance, val = t.getParams(self, t)
		game:playSoundNear(self, "talents/spell_generic2")
		local particle
		if core.shader.active(4) then
			local bx, by = self:attachementSpot("back", true)
			particle = self:addParticles(Particles.new("shader_wings", 1, {infinite=1, x=bx, y=by, img="darkwings"}))
		end
		local ret = {
			chance = self:addTemporaryValue("life_leech_chance", chance),
			val = self:addTemporaryValue("life_leech_value", val),
			particle = particle,
		}
		return ret
	end,
	deactivate = function(self, t, p)
		if p.particle then self:removeParticles(p.particle) end
		self:removeTemporaryValue("life_leech_chance", p.chance)
		self:removeTemporaryValue("life_leech_value", p.val)
		return true
	end,
	info = function(self, t)
		local chance, val = t.getParams(self, t)
		return ([[흡혈귀의 기운이 흘러, 적에게 피해를 줄 때마다 %d%% 확률로 피해량의 %d%% 만큼 생명력을 회복합니다.
		회복 확률은 주문력의 영향을 받아 증가합니다.]]):
		format(chance, val)
	end,
}
