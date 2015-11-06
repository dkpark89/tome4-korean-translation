-- ToME -  Tales of Maj'Eyal
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

local Object = require "mod.class.Object"

newTalent{
	name = "Dust to Dust",
	kr_name = "먼지는 먼지로",
	type = {"chronomancy/matter",1},
	require = chrono_req1,
	points = 5,
	paradox = function (self, t) return getParadoxCost(self, t, 10) end,
	cooldown = 3,
	tactical = { ATTACKAREA = {TEMPORAL = 1, PHYSICAL = 1} },
	range = 10,
	direct_hit = true,
	reflectable = true,
	requires_target = true,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 1.25, 3.25)) end,
	target = function(self, t)
		return {type="beam", range=self:getTalentRange(t), talent=t, nowarning=true}
	end,
	getAshes = function(self, t) return {type="ball", range=0, radius=self:getTalentRadius(t), selffire=false} end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 230, getParadoxSpellpower(self, t)) end,
	action = function(self, t)
		-- Check for digs first
		local digs = self:isTalentActive(self.T_DISINTEGRATION) and self:callTalent(self.T_DISINTEGRATION, "getDigs")
		local tg = self:getTalentTarget(t)
		
		-- Just for targeting change to pass terrain
		if digs then tg.pass_terrain = true end
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		
		-- Change back pass terrain
		tg.pass_terrain = nil
			
		-- Ashes to Ashes
		local target = game.level.map(x, y, Map.ACTOR)
		if target and target == self then
			tg = t.getAshes(self, t)
			-- We do our digs seperatly and first so we can damage stuff on the other side
			if digs then
				game.level.map:addEffect(self,
					self.x, self.y, 3,
					DamageType.DIG, digs,
					tg.radius,
					5, nil,
					nil,
					function(e)
						e.x = e.src.x
						e.y = e.src.y
						return true
					end,
					tg.selffire
				)
			end
			game.level.map:addEffect(self,
				self.x, self.y, 3,
				DamageType.WARP, self:spellCrit(t.getDamage(self, t)/3),
				tg.radius,
				5, nil,
				engine.MapEffect.new{alpha=100, color_br=75, color_bg=75, color_bb=25, effect_shader="shader_images/paradox_effect.png"},
				function(e)
					e.x = e.src.x
					e.y = e.src.y
					return true
				end,
				tg.selffire
			)
			
			game:playSoundNear(self, "talents/cloud")
		else
			-- and Dust to Dust
			if digs then for i = 1, digs do self:project(tg, x, y, DamageType.DIG, 1) end end
		
			self:project(tg, x, y, DamageType.WARP, self:spellCrit(t.getDamage(self, t)))
			local _ _, _, _, x, y = self:canProject(tg, x, y)
			if core.shader.active() then
				game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "matter_beam", {tx=x-self.x, ty=y-self.y}, {type="lightning"})
			else
				game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "matter_beam", {tx=x-self.x, ty=y-self.y})
			end
			game:playSoundNear(self, "talents/arcane")
		end
		
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local radius = self:getTalentRadius(t)
		return ([[물질을 먼지로 바꾸어 버리는 빛줄기를 발사하여 %0.2f 의 시간피해와 %0.2f의 물리(왜곡)피해를 가합니다.
		혹은, 목표로 당신을 지정한다면, 당신의 %d 범위 주위에 역장을 만들어 같은 피해를 3 턴에 나누어 입힙니다.
		피해량은 주문력에 비례하여 상승합니다.]]):
		format(damDesc(self, DamageType.TEMPORAL, damage / 2), damDesc(self, DamageType.PHYSICAL, damage / 2), radius)
	end,
}

newTalent{
	name = "Matter Weaving",
	kr_name = "물질 엮기",
	type = {"chronomancy/matter",2},
	require = chrono_req2,
	points = 5,
	sustain_paradox = 24,
	mode = "sustained",
	cooldown = 10,
	tactical = { BUFF = 2 },
	getImmunity = function(self, t) return self:combatTalentLimit(t, 1, 0.15, 0.50) end, -- Limit <100%
	getArmor = function(self, t) return self:combatTalentStatDamage(t, "mag", 10, 50) end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/earth")
		
		local ret = {
			stun = self:addTemporaryValue("stun_immune", t.getImmunity(self, t)),
			cut = self:addTemporaryValue("cut_immune", t.getImmunity(self, t)),
			armor = self:addTemporaryValue("combat_armor", t.getArmor(self, t)),
		}
		
		if not self:addShaderAura("stone_skin", "crystalineaura", {time_factor=1000, spikeOffset=0.123123, spikeLength=0.6, spikeWidth=4, growthSpeed=2, color={150/255, 150/255, 50/255}}, "particles_images/spikes.png") then
			ret.particle = self:addParticles(Particles.new("stone_skin", 1))
		end
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeShaderAura("stone_skin")
		self:removeTemporaryValue("stun_immune", p.stun)
		self:removeTemporaryValue("cut_immune", p.cut)
		self:removeTemporaryValue("combat_armor", p.armor)
		
		self:removeParticles(p.particle)
		return true
	end,
	info = function(self, t)
		local armor = t.getArmor(self, t)
		local immune = t.getImmunity(self, t) * 100
		return ([[물질을 당신의 피부 내부에 엮어, 피해에 대해 강력한 내구성을 가지게 합니다. 유지되고 있는 동안 당신은 %d 만큼의 방어도와 %d%% 만큼의 기절 저항, %d%% 만큼의 출혈 저항을 얻습니다.]]):
		format(armor, immune, immune)
	end,
}

newTalent{
	name = "Materialize Barrier",
	kr_name = "장벽 물질화",
	type = {"chronomancy/matter",3},
	require = chrono_req3,
	points = 5,
	paradox = function (self, t) return getParadoxCost(self, t, 15) end,
	cooldown = 14,
	tactical = { DISABLE = 2 },
	range = 10,
	direct_hit = true,
	requires_target = true,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 1, 2)) end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 200, getParadoxSpellpower(self, t)) end,
	getDuration = function(self, t) return getExtensionModifier(self, t, 4) end,
	getLength = function(self, t) return 3 end,
	target = function(self, t)
		local halflength = math.floor(t.getLength(self,t)/2)
		local block = function(_, lx, ly)
			return game.level.map:checkAllEntities(lx, ly, "block_move")
		end
		return {type="wall", range=self:getTalentRange(t), nolock=true, halflength=halflength, talent=t, halfmax_spots=halflength+1, block_radius=block}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, _, _, x, y = self:canProject(tg, x, y)
		if game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move") then return nil end

		self:project(tg, x, y, function(px, py, tg, self)
			local oe = game.level.map(px, py, Map.TERRAIN)
			if not oe or oe.special then return end
			if not oe or oe:attr("temporary") or game.level.map:checkAllEntities(px, py, "block_move") then return end
				local e = Object.new{
					old_feat = oe,
					name = "materialize barrier", image = "terrain/rocky_mountain.png",
					display = '#', color_r=255, color_g=255, color_b=255, back_color=colors.GREY,
					shader = "shadow_simulacrum",
					shader_args = { color = {0.6, 0.6, 0.2}, base = 0.9, time_factor = 1500 },
					desc = "a summoned wall of stone",
					type = "wall", --subtype = "floor",
					always_remember = true,
					can_pass = {pass_wall=1},
					does_block_move = true,
					show_tooltip = true,
					block_move = true,
					block_sight = true,
					temporary = t.getDuration(self, t),
					x = px, y = py,
					canAct = false,
					act = function(self)
						self:useEnergy()
						self.temporary = self.temporary - 1
						if self.temporary <= 0 then
							game.level.map(self.x, self.y, engine.Map.TERRAIN, self.old_feat)
							game.nicer_tiles:updateAround(game.level, self.x, self.y)
							game.level:removeEntity(self)
							game.level.map:scheduleRedisplay()
						end
					end,
					dig = function(src, x, y, old)
						-- Explode!
						local self = game.level.map(x, y, engine.Map.TERRAIN)
						local t = self.summoner:getTalentFromId(self.summoner.T_MATERIALIZE_BARRIER)
						local tg = {type="ball", range=0, radius = self.summoner:getTalentRadius(t), talent=t, x=self.x, y=self.y}
						self.summoner.__project_source = self
						self.summoner:project(tg, self.x, self.y, engine.DamageType.BLEED, self.summoner:spellCrit(t.getDamage(self.summoner, t)))
						self.summoner.__project_source = nil
						game.level.map:particleEmitter(x, y, tg.radius, "ball_earth", {radius=tg.radius})
						
						game.level:removeEntity(old, true)
						game.level.map:scheduleRedisplay()
						return nil, old.old_feat
					end,
					summoner_gain_exp = true,
					summoner = self,
				}
			e.tooltip = mod.class.Grid.tooltip
			game.level:addEntity(e)
			game.level.map(px, py, Map.TERRAIN, e)
		end)
		
		game:playSoundNear(self, "talents/earth")
		
		-- Update so we don't see things move on the otherside of the wall...  at least not without precog >:)
		game:onTickEnd(function()
			if game.level then
				self:resetCanSeeCache()
				if self.player then for uid, e in pairs(game.level.entities) do if e.x then game.level.map:updateMap(e.x, e.y) end end game.level.map.changed = true end
			end
		end)
		
		return true
	end,
	info = function(self, t)
		local length = t.getLength(self, t)
		local duration = t.getDuration(self, t)
		local damage = t.getDamage(self, t)
		local radius = self:getTalentRadius(t)
		return ([[%d 길이의 잘 짜여진 물질 장벽을 %d 턴 동안 만들어 냅니다.
		만약 물질 장벽의 어떠한 부분이라도 파여진다면, 폭발하여 주변 %d 반경에 있는 목표들에게 %0.2f 의 물리 피해를 6 턴간 나누어 주는 출혈을 일으킵니다..]])
		:format(length, duration, radius, damDesc(self, DamageType.PHYSICAL, damage))
	end,
}

newTalent{
	name = "Disintegration",
	kr_name = "분해",
	type = {"chronomancy/matter",4},
	require = chrono_req4,
	points = 5,
	sustain_paradox = 24,
	mode = "sustained",
	cooldown = 10,
	tactical = { BUFF = 2 },
	getDigs = function(self, t) return math.floor(self:combatTalentScale(t, 1, 5, "log")) end,
	getChance = function(self, t) return self:combatTalentLimit(t, 50, 10, 40) end, -- Limit < 50%end,
	doStrip = function(self, t, target, type)
		local what = type == "PHYSICAL" and "physical" or "magical"
		local p = self:isTalentActive(self.T_DISINTEGRATION)
		
		if what == "physical" and p.physical[target] then return end
		if what == "magical" and p.magical[target] then return end
		
		if rng.percent(t.getChance(self, t)) then
			local effs = {}
			-- Go through all spell effects
			for eff_id, p in pairs(target.tmp) do
				local e = target.tempeffect_def[eff_id]
				if e.type == what and e.status == "beneficial" then
					effs[#effs+1] = {"effect", eff_id}
				end
			end
	
			if #effs > 0 then
				local eff = rng.tableRemove(effs)
				if eff[1] == "effect" then
					target:removeEffect(eff[2])
					game.logSeen(self, "#CRIMSON#%s's beneficial effect was stripped!#LAST#", target.name:capitalize())
					if what == "physical" then p.physical[target] = true end
					if what == "magical" then p.magical[target] = true end
					
					-- The Cure achievement
					local acheive = self.player and not target.training_dummy and target ~= self
					if acheive then
						world:gainAchievement("THE_CURE", self)
					end
				end
			end
		end
	end,
	callbackOnActBase = function(self, t)
		-- reset our targets
		local p = self:isTalentActive(self.T_DISINTEGRATION)
		if p then
			p.physical = {}
			p.magical = {}
		end
	end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/earth")

		local ret = { 
			physical = {}, magical ={}
		}
		if core.shader.active(4) then
			ret.particle = self:addParticles(Particles.new("shader_ring_rotating", 1, {rotation=-0.01, radius=1.2}, {type="stone", hide_center=1, zoom=0.6, color1={0.4, 0.4, 0, 1}, color2={0.5, 0.5, 0, 1}, xy={self.x, self.y}}))
		end
		return ret
	end,
	deactivate = function(self, t, p)
		if p.particle then self:removeParticles(p.particle) end
		return true
	end,
	info = function(self, t)
		local digs = t.getDigs(self, t)
		local chance = t.getChance(self, t)
		return ([[이 기술이 유지되는 동안 당신의 물리, 시간 속성의 피해는, 이제 당신이 피해를 입힌 목표의 물리적 혹은 마법적인 이로운 일시적 효과를 %d%% 확률로 하나 지워냅니다.
		한 턴에는 한 목표당 하나의 물리적 효과와 하나의 마법적 효과만을 지울 수 있습니다.
		또한 이제 당신의 먼지는 먼지로 마법이 %d 칸만큼 벽을 파낼 수 있습니다.]]):
		format(chance, digs)
	end,
}
