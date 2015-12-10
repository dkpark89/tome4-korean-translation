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

-- EDGE TODO: Particles, Timed Effect Particles

newTalent{
	name = "Dimensional Step",
	kr_name = "차원의 발걸음",
	type = {"chronomancy/spacetime-weaving", 1},
	require = chrono_req1,
	points = 5,
	paradox = function (self, t) return getParadoxCost(self, t, 10) end,
	cooldown = 10,
	tactical = { CLOSEIN = 2, ESCAPE = 2 },
	range = function(self, t) return math.floor(self:combatTalentScale(t, 5, 9, 0.5, 0, 1)) end,
	requires_target = true,
	target = function(self, t)
		return {type="hit", nolock=true, range=self:getTalentRange(t)}
	end,
	direct_hit = true,
	no_energy = true,
	is_teleport = true,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		if not self:hasLOS(x, y) or game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move") then -- To prevent teleporting through walls
			game.logSeen(self, "당신의 시야 내가 아닙니다.")
			return nil
		end
		local _ _, x, y = self:canProject(tg, x, y)
		
		-- Swap?
		if self:getTalentLevel(t) >= 5 and target then
			-- Hit?
			if target:canBe("teleport") and self:checkHit(getParadoxSpellpower(self, t), target:combatSpellResist() + (target:attr("continuum_destabilization") or 0)) then
				-- Grab the caster's location
				local ox, oy = self.x, self.y
			
				-- Remove the target so the destination tile is empty
				game.level.map:remove(target.x, target.y, Map.ACTOR)
				
				-- Try to teleport to the target's old location
				if self:teleportRandom(x, y, 0) then
					-- Move the target to our old location
					target:move(ox, oy, true)
					
					game.level.map:particleEmitter(target.x, target.y, 1, "temporal_teleport")
					game.level.map:particleEmitter(self.x, self.y, 1, "temporal_teleport")
				else
					-- If we can't teleport, return the target
					game.level.map(target.x, target.y, Map.ACTOR, target)
					game.logSeen(self, "주문이 실패하였습니다!")
				end
			else
				game.logSeen(target, "%s 자리 바꿈을 저항했습니다!", target.name:capitalize())
			end
		else
			game.level.map:particleEmitter(self.x, self.y, 1, "temporal_teleport")
			if not self:teleportRandom(x, y, 0) then
				game.logSeen(self, "주문이 실패하였습니다!")
			else
				game.level.map:particleEmitter(self.x, self.y, 1, "temporal_teleport")
			end
		end
		
		game:playSoundNear(self, "talents/teleport")
		return true
	end,
	info = function(self, t)
		local range = self:getTalentRange(t)
		return ([[당신의 시야 안에 있는 최대 %d 칸 거리내로 순간이동합니다.
		기술 레벨이 5 이상이라면 당신은 목표 존재와 위치를 바꿀 수 있습니다.]]):format(range)
	end,
}

newTalent{
	name = "Dimensional Shift",
	kr_name = "차원 전환",
	type = {"chronomancy/spacetime-weaving", 2},
	mode = "passive",
	require = chrono_req2,
	points = 5,
	getReduction = function(self, t) return math.ceil(self:getTalentLevel(t)) end,
	callbackOnTeleport = function(self, t, teleported)
		if not teleported then return end
		
		-- Grab a random sample of timed effects
		local eff_id = self:effectsFilter({status="detrimental", ignore_crosstier=true}, 1)
		if eff_id[1] then
			local eff = self:hasEffect(eff_id[1])
			eff.dur = eff.dur - t.getReduction(self, t)
			if eff.dur <= 0 then
				self:removeEffect(eff_id[1])
			end
		end

		-- Make sure we update the display for blind and such
		game:onTickEnd(function()
			if game.level then
				self:resetCanSeeCache()
				if self.player then for uid, e in pairs(game.level.entities) do if e.x then game.level.map:updateMap(e.x, e.y) end end game.level.map.changed = true end
			end
		end)

	end,
	info = function(self, t)
		local reduction = t.getReduction(self, t)
		return ([[당신이 순간이동 할때, 당신의 해로운 상태효과 중 하나의 지속시간을 %d 턴 줄입니다.]]):
		format(reduction)
	end,
}

newTalent{
	name = "Wormhole",
	kr_name = "웜홀",
	type = {"chronomancy/spacetime-weaving", 3},
	require = chrono_req3,
	points = 5,
	paradox = function (self, t) return getParadoxCost(self, t, 10) end,
	cooldown = 10,
	tactical = { ESCAPE = 2 },
	range = 10,
	radius = function(self, t) return math.floor(self:combatTalentLimit(t, 1, 5, 2)) end, -- Limit to radius 1
	requires_target = true,
	getDuration = function (self, t) return getExtensionModifier(self, t, math.floor(self:combatTalentScale(t, 6, 10))) end,
	no_npc_use = true,
	action = function(self, t)
		-- Target the entrance location
		local tg = {type="bolt", nowarning=true, range=1, nolock=true, simple_dir_request=true, talent=t}
		local entrance_x, entrance_y = self:getTarget(tg)
		if not entrance_x or not entrance_y then return nil end
		local _ _, entrance_x, entrance_y = self:canProject(tg, entrance_x, entrance_y)
		local trap = game.level.map(entrance_x, entrance_y, engine.Map.TRAP)
		if trap or game.level.map:checkEntity(entrance_x, entrance_y, Map.TERRAIN, "block_move") then game.logPlayer(self, "여기에 웜홀 입구를 만들 수 없습니다.") return end

		-- Target the exit location
		local tg = {type="hit", nolock=true, pass_terrain=true, nowarning=true, range=self:getTalentRange(t)}
		local exit_x, exit_y = self:getTarget(tg)
		if not exit_x or not exit_y then return nil end
		local _ _, exit_x, exit_y = self:canProject(tg, exit_x, exit_y)
		local trap = game.level.map(exit_x, exit_y, engine.Map.TRAP)
		if trap or game.level.map:checkEntity(exit_x, exit_y, Map.TERRAIN, "block_move") or core.fov.distance(entrance_x, entrance_y, exit_x, exit_y) < 2 then game.logPlayer(self, "여기에 웜홀 출구를 만들 수 없습니다.") return end

		-- Wormhole values
		local power = getParadoxSpellpower(self, t)
		local dest_power = getParadoxSpellpower(self, t, 0.3)
		
		-- Our base wormhole
		local function makeWormhole(x, y, dest_x, dest_y)
			local wormhole = mod.class.Trap.new{
				name = "wormhole",
				type = "annoy", subtype="teleport", id_by_type=true, unided_name = "trap",
				image = "terrain/wormhole.png",
				display = '&', color_r=255, color_g=255, color_b=255, back_color=colors.STEEL_BLUE,
				message = "@Target@ 웜홀로 들어갔습니다.",
				temporary = t.getDuration(self, t),
				x = x, y = y, dest_x = dest_x, dest_y = dest_y,
				radius = self:getTalentRadius(t),
				canAct = false,
				energy = {value=0},
				disarm = function(self, x, y, who) return false end,
				power = power, dest_power = dest_power,
				summoner = self, beneficial_trap = true, faction=self.faction,
				triggered = function(self, x, y, who)
					local hit = who:checkHit(self.power, who:combatSpellResist()+(who:attr("continuum_destabilization") or 0), 0, 95) and who:canBe("teleport") -- Bug fix, Deprecrated checkhit call
					if hit or (who.reactionToward and who:reactionToward(self) >= 0) then
						game.level.map:particleEmitter(who.x, who.y, 1, "temporal_teleport")
						if not who:teleportRandom(self.dest_x, self.dest_y, self.radius, 1) then
							game.logSeen(who, "%s 들어가려고 시도했지만 난폭한 힘이 밖으로 밀어내었습니다", who.name:capitalize())
						else
							if who ~= self.summoner then who:setEffect(who.EFF_CONTINUUM_DESTABILIZATION, 100, {power=self.dest_power}) end
							game.level.map:particleEmitter(who.x, who.y, 1, "temporal_teleport")
							game:playSoundNear(self, "talents/teleport")
						end
					else
						game.logSeen(who, "%s 웜홀을 무시했습니다.", who.name:capitalize())
					end
					return true
				end,
				act = function(self)
					self:useEnergy()
					self.temporary = self.temporary - 1
					if self.temporary <= 0 then
						game.logSeen(self, "현실의 힘이 밀려들어와 웜홀이 강제로 닫혔습니다.")
						if game.level.map(self.x, self.y, engine.Map.TRAP) == self then game.level.map:remove(self.x, self.y, engine.Map.TRAP) end
						game.level:removeEntity(self)
					end
				end,
			}
			
			return wormhole
		end
		
		-- Adding the entrance wormhole
		local entrance = makeWormhole(entrance_x, entrance_y, exit_x, exit_y)
		game.level:addEntity(entrance)
		entrance:identify(true)
		entrance:setKnown(self, true)
		game.zone:addEntity(game.level, entrance, "trap", entrance_x, entrance_y)
		game:playSoundNear(self, "talents/heal")

		-- Adding the exit wormhole
		local exit = makeWormhole(exit_x, exit_y, entrance_x, entrance_y)
		exit.x = exit_x
		exit.y = exit_y
		game.level:addEntity(exit)
		exit:identify(true)
		exit:setKnown(self, true)
		game.zone:addEntity(game.level, exit, "trap", exit_x, exit_y)

		-- Linking the wormholes
		entrance.dest = exit
		exit.dest = entrance

		game.logSeen(self, "%s 두 지점 사이의 공간을 접습니다.", self.name)
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local radius = self:getTalentRadius(t)
		local range = self:getTalentRange(t)
		return ([[당신은 당신이 있는 공간과 %d 내의 거리에 있는 다른 점을 접어 웜홀 한쌍을 만들어 냅니다. 웜홀에 발을 들이는 모든 존재들은 반대 쪽의 웜홀로 순간이동 됩니다 (범위 %d 칸의 정확도로). 
		웜홀은 %d 턴간 유지 되며, 최소한 2 칸 이상은 떨어져 있어야 합니다.
		적을 순간이동 시킬 확율은 주문력에 비례하여 상승합니다.]])
		:format(range, radius, duration)
	end,
}

newTalent{
	name = "Phase Pulse",
	kr_name = "위상 파동",
	type = {"chronomancy/spacetime-weaving", 4},
	require = chrono_req4,
	tactical = { DISABLE = 2 },
	mode = "sustained",
	sustain_paradox = 36,
	cooldown = 10,
	points = 5,
	range = 0,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 1, 2)) end,
	target = function(self, t)
		return {type="ball", range=100, radius=self:getTalentRadius(t), friendlyfire=false, talent=t}  -- range 100, this triggers when you teleport at both ends
	end,
	getDuration = function(self, t) return getExtensionModifier(self, t, math.floor(self:combatTalentScale(t, 2, 4))) end,
	getChance = function(self, t) return 2 + math.floor(self:combatTalentScale(t, 2, 10)) end,
	callbackOnTeleport = function(self, t, teleported, ox, oy, x, y)
		if not teleported then return end
		local tg = self:getTalentTarget(t)
		local distance = core.fov.distance(self.x, self.y, ox, oy)
		local chance = distance * t.getChance(self, t)
		
		
		-- Project our status effects at the end of the turn
		game:onTickEnd(function()
			-- Project at both the entrance and exit
			self:project(tg, self.x, self.y, function(px, py)
				local target = game.level.map(px, py, Map.ACTOR)
				if target and rng.percent(chance) then
					DamageType:get(DamageType.RANDOM_WARP).projector(self, px, py, DamageType.RANDOM_WARP, {dur=t.getDuration(self, t), apply_power=getParadoxSpellpower(self, t)})
				end
			end)
			self:project(tg, ox, oy, function(px, py)
				local target = game.level.map(px, py, Map.ACTOR)
				if target and rng.percent(chance) then
					DamageType:get(DamageType.RANDOM_WARP).projector(self, px, py, DamageType.RANDOM_WARP, {dur=t.getDuration(self, t), apply_power=getParadoxSpellpower(self, t)})
				end
			end)
		end)
	end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/spell_generic")
		return {}
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		local chance = t.getChance(self, t)
		local radius = self:getTalentRadius(t)
		local duration = t.getDuration(self, t)
		return ([[당신이 텔레포트 할때, 시작 지점과 도착 지점에 %d 범위의 강력한 파동이 일어나 적들을 다른 위상으로 내쫓습니다.
		영향을 받은 목표들은 당신이 이동한 타일 한 칸마다 %d%% 의 확률로 %d 턴간 기절, 실명, 혼란, 속박 될 수 있습니다.]]):
		format(radius, chance, duration)
	end,
}
