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

--local Object = require "engine.Object"

newTalent{
	name = "Twilight",
	type = {"celestial/twilight", 1},
	require = divi_req1,
	points = 5,
	cooldown = 6,
	positive = 15,
	tactical = { BUFF = 1 },
	range = 10,
	getRestValue = function(self, t) return self:combatTalentLimit(t, 50, 20.5, 34.5) end, -- Limit < 50%
	getNegativeGain = function(self, t) return math.max(0, self:combatScale(self:getTalentLevel(t) * self:getCun(40, true), 24, 4, 220, 200, nil, nil, 40)) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "positive_at_rest", t.getRestValue(self, t))
		self:talentTemporaryValue(p, "negative_at_rest", t.getRestValue(self, t))
	end,
	action = function(self, t)
		if self:isTalentActive(self.T_DARKEST_LIGHT) then
			game.logPlayer(self, "'가장 어두운 빛' 이 활성화된 상태에서는 황혼 기술을 사용할 수 없습니다.")
			return
		end
		self:incNegative(t.getNegativeGain(self, t))
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		return ([[어둠과 빛의 사이에 선 자의 권능으로, 15 의 양기를 %d 의 음기로 전환합니다. 
51 		이 기술을 배우면 양기와 음기의 기본값이 최대치의 %d%% 에 해당하는 값으로 변경됩니다. 0 대신, 이 기본값을 향하여 매 턴마다 양기와 음기가 조금씩 변화합니다. 
52 		획득하는 음기의 양은 교활함 능력치의 영향을 받아 증가합니다.]]): 
		format(t.getNegativeGain(self, t), t.getRestValue(self, t))
	end,
}

newTalent{
	name = "Jumpgate: Teleport To", short_name = "JUMPGATE_TELEPORT",
	kr_name = "도약문 : 이동",
	type = {"celestial/other", 1},
	points = 1,
	cooldown = 7,
	negative = 14,
	type_no_req = true,
	tactical = { ESCAPE = 2 },
	no_npc_use = true,
	no_unlearn_last = true,
	getRange = function(self, t) return math.floor(self:combatTalentScale(t, 13, 18)) end,
	-- Check distance in preUseTalent to grey out the talent
	on_pre_use = function(self, t)
		local eff = self.sustain_talents[self.T_JUMPGATE]
		return eff and core.fov.distance(self.x, self.y, eff.jumpgate_x, eff.jumpgate_y) <= t.getRange(self, t)
	end,
	is_teleport = true,
	action = function(self, t)
		local eff = self.sustain_talents[self.T_JUMPGATE]
		if not eff then
			game.logPlayer(self, "순간이동을 하려면, 도약문 기술이 유지된 상태여야 합니다.")
			return
		end
		game.level.map:particleEmitter(self.x, self.y, 1, "teleport")
		self:teleportRandom(eff.jumpgate_x, eff.jumpgate_y, 1)
		game.level.map:particleEmitter(eff.jumpgate_x, eff.jumpgate_y, 1, "teleport")
		game:playSoundNear(self, "talents/teleport")
		return true
	end,
	info = function(self, t)
		return ([[%d 칸 내에 있는 도약문으로 즉시 이동합니다.]]):format(t.getRange(self, t))
 	end,
}

newTalent{
	name = "Jumpgate",
	kr_name = "도약문",
	type = {"celestial/twilight", 2},
	require = divi_req2,
	mode = "sustained", no_sustain_autoreset = true,
	points = 5,
	cooldown = function(self, t)
		local tl = self:getTalentLevelRaw(t)
		if tl < 4 then
			return math.ceil(self:combatLimit(tl, 0, 20, 1, 8, 4))
		else
			return math.ceil(self:combatLimit(tl, 0, 8, 4, 4, 5)) --I5 Limit >0
		end
	end,
	sustain_negative = 20,
	no_npc_use = true,
	tactical = { ESCAPE = 2 },
	iconOverlay = function(self, t, p)
		if not self.x or not self.y or not p.jumpgate_x or not p.jumpgate_y then return "" end
		local val = math.floor(core.fov.distance(self.x, self.y, p.jumpgate_x, p.jumpgate_y))
		local jt = self:getTalentFromId(self.T_JUMPGATE_TELEPORT)
		local max = jt.getRange(self, jt)
		local fnt = "buff_font_small"
		if val >= 1000 then fnt = "buff_font_smaller" end
		if val <= max then
			return "#LIGHT_GREEN#"..tostring(math.ceil(val)), fnt
		else
			return "#LIGHT_RED#"..tostring(math.ceil(val)), fnt
		end
	end,
 	on_learn = function(self, t)
		if self:getTalentLevel(t) >= 4 and not self:knowTalent(self.T_JUMPGATE_TWO) then
			self:learnTalent(self.T_JUMPGATE_TWO, nil, nil, {no_unlearn=true})
 		end
			self:learnTalent(self.T_JUMPGATE_TELEPORT, nil, nil, {no_unlearn=true})
	end,
 	on_unlearn = function(self, t)
		if self:getTalentLevel(t) < 4 and self:knowTalent(self.T_JUMPGATE_TWO) then
 			self:unlearnTalent(self.T_JUMPGATE_TWO)
 		end
			self:unlearnTalent(self.T_JUMPGATE_TELEPORT)
 	end,
	activate = function(self, t)
		local oe = game.level.map(self.x, self.y, engine.Map.TERRAIN)
		if not oe or oe:attr("temporary") then return false end
		local e = mod.class.Object.new{
			old_feat = oe, type = oe.type, subtype = oe.subtype,
			name = "jumpgate", image = oe.image, add_mos = {{image = "terrain/wormhole.png"}},
			display = '&', color=colors.PURPLE,
			temporary = 1, -- This prevents overlapping of terrain changing effects; as this talent is a sustain it does nothing else
		}
		game.level.map(game.player.x, game.player.y, engine.Map.TERRAIN, e)
		
		local ret = {
			jumpgate = e, jumpgate_x = game.player.x, jumpgate_y = game.player.y,
			jumpgate_level = game.zone.short_name .. "-" .. game.level.level,
			particle = self:addParticles(Particles.new("time_shield", 1))
		}
		return ret
	end,
	deactivate = function(self, t, p)
		-- Reset the terrain tile
		game.level.map(p.jumpgate_x, p.jumpgate_y, engine.Map.TERRAIN, p.jumpgate.old_feat)
		game.nicer_tiles:updateAround(game.level, p.jumpgate_x, p.jumpgate_y)
		self:removeParticles(p.particle)
		return true
	end,
	info = function(self, t)
		local jumpgate_teleport = self:getTalentFromId(self.T_JUMPGATE_TELEPORT)
		local range = jumpgate_teleport.getRange(self, jumpgate_teleport)
		return ([[현재 위치에 그림자 도약문을 생성합니다. 이 기술이 유지되는 동안, '도약문 : 이동' 기술을 사용하여 %d 칸 내에 있는 도약문으로 즉시 이동할 수 있습니다. 
164 		도약문을 계단이 있는 곳에 만들었을 경우, 계단은 사용할 수 없게 됩니다. 계단을 이용하려면 도약문 기술을 해제해야 합니다. 
165 		기술 레벨이 4 이상이면, 두번째 도약문을 생성할 수 있습니다.]]):format(range) 
 	end,
 }


newTalent{
	name = "Mind Blast",
	kr_name = "정신 붕괴",
	type = {"celestial/twilight",3},
	require = divi_req3,
	points = 5,
	random_ego = "attack",
	cooldown = 15,
	negative = 15,
	tactical = { DISABLE = 3 },
	radius = 3,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t, selffire=false}
	end,
	getConfuseDuration = function(self, t) return math.floor(self:combatScale(self:getTalentLevel(t) + self:getCun(5), 2, 0, 12, 10)) end,
	getConfuseEfficency = function(self, t) return self:combatTalentLimit(t, 60, 15, 45) end, -- Limit < 60% (slightly better than most confusion effects)
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, DamageType.CONFUSION, {
			dur = t.getConfuseDuration(self, t),
			dam = t.getConfuseEfficency(self, t)
		})
		game:playSoundNear(self, "talents/flame")
		return true
	end,
	info = function(self, t)
		local duration = t.getConfuseDuration(self, t)
		return ([[마음의 절규를 내질러, 주변 3 칸 반경에 있는 적들의 의지를 꺾습니다. 영향을 받은 적은 혼란 상태가 되어 %d%% 확률로 무작위한 행동을 하게 되며, 이는 %d 턴 동안 지속됩니다. 
200 		지속시간은 교활함 능력치의 영향을 받아 증가합니다.]]): 
		format(t.getConfuseEfficency(self,t),duration)
	end,
}

newTalent{
	name = "Shadow Simulacrum",
	kr_name = "그림자 환영",
	type = {"celestial/twilight", 4},
	require = divi_req4,
	random_ego = "attack",
	points = 5,
	cooldown = 30,
	negative = 10,
	tactical = { DISABLE = 2 },
	requires_target = true,
	range = 5,
	no_npc_use = true,
	getDuration = function(self, t) return math.floor(self:combatScale(self:getTalentLevel(t)+self:getCun(10), 3, 0, 18, 15)) end,
	getPercent = function(self, t) return self:combatScale(self:getCun(10, true) * self:getTalentLevel(t), 0, 0, 50, 50) end,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), talent=t}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, tx, ty = self:canProject(tg, tx, ty)
		local target = game.level.map(tx, ty, Map.ACTOR)
		if not target or self:reactionToward(target) >= 0 then return end

		-- Find space
		local x, y = util.findFreeGrid(tx, ty, 1, true, {[Map.ACTOR]=true})
		if not x then
			game.logPlayer(self, "소환할 공간이 부족합니다!")
			return
		end

		if target:attr("summon_time") then
			game.logPlayer(self, "잘못된 대상입니다!")
			return
		end

		local allowed = 2 + math.ceil(self:getTalentLevelRaw(t) / 2 )

		if target.rank >= 3.5 or -- No boss
			target:reactionToward(self) >= 0 or -- No friends
			target.size_category > allowed
			then
			game.logSeen(target, "%s 저항했습니다!", target.name:capitalize())
			return true
		end

		local modifier = t.getPercent(self, t)

		local m = target:cloneFull{
			shader = "shadow_simulacrum",
			no_drops = true, keep_inven_on_death = false,
			faction = self.faction,
			summoner = self, summoner_gain_exp=true,
			summon_time = t.getDuration(self, t),
			ai_target = {actor=target},
			ai = "summoned", ai_real = target.ai,
			resists = { all = modifier, [DamageType.DARKNESS] = 50, [DamageType.LIGHT] = - 50, },
			desc = [[어두운 그림자로, 본체의 모습을 닮아있습니다. 다만 완벽한 복제품은 아니며, 바라보고 있으면 불편한 감정이 생겨납니다.]],  
262 		} 
		m:removeAllMOs()
		m.make_escort = nil
		m.on_added_to_level = nil

		m.energy.value = 0
		m.life = m.life*modifier/100
		m.forceLevelup = function() end
		-- Handle special things
		m.on_die = nil
		m.puuid = nil
		m.on_acquire_target = nil
		m.seen_by = nil
		m.can_talk = nil
		m.exp_worth = 0
		m.clone_on_hit = nil
		if m.talents.T_SUMMON then m.talents.T_SUMMON = nil end
		if m.talents.T_MULTIPLY then m.talents.T_MULTIPLY = nil end

		game.zone:addEntity(game.level, m, "actor", x, y)
		game.level.map:particleEmitter(x, y, 1, "shadow")

		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local allowed = 2 + math.ceil(self:getTalentLevelRaw(t) / 2 )
		local size = "어마어마함"
		if allowed < 4 then
			size = "중간"
		elseif allowed < 5 then
			size = "큼"
		elseif allowed < 6 then
			size = "거대함"
		end
		return ([[크기가 '%s' 이하인 적의 그림자 분신을 만들어냅니다. 그림자 분신은 생성 즉시 자신의 본체를 공격하기 시작하며, %d 턴 동안 유지됩니다. 
299 		그림자는 대상 생명력의 %d%% 만큼을 생명력으로 가집니다. 전체 저항력은 %d%% 이며, 여기에 어둠 저항력은 +50%%, 빛 저항력은 -50%% 만큼이 더해집니다. 
300 		분신의 지속시간과 생명력 그리고 전체 저항력은 교활함 능력치의 영향을 받아 증가합니다. 보스에게는 이 능력을 사용해도 효과가 없습니다.]]): 
301 		format(size, duration, t.getPercent(self, t), t.getPercent(self, t))  
	end,
}

-- Extra Jumpgates

newTalent{
	name = "Jumpgate Two",
	kr_name = "두번째 도약문",
	type = {"celestial/other", 1},
	mode = "sustained", no_sustain_autoreset = true,
	points = 1,
	cooldown = 20,
	sustain_negative = 20,
	no_npc_use = true,
	type_no_req = true,
	tactical = { ESCAPE = 2 },
	no_unlearn_last = true,
	on_learn = function(self, t)
		if not self:knowTalent(self.T_JUMPGATE_TELEPORT_TWO) then
			self:learnTalent(self.T_JUMPGATE_TELEPORT_TWO, nil, nil, {no_unlearn=true})
		end
	end,
	on_unlearn = function(self, t)
		if not self:knowTalent(t) then
			self:unlearnTalent(self.T_JUMPGATE_TELEPORT_TWO)
		end
	end,
	iconOverlay = function(self, t, p)
		if not self.x or not self.y or not p.jumpgate2_x or not p.jumpgate2_y then return "" end
		local val = math.floor(core.fov.distance(self.x, self.y, p.jumpgate2_x, p.jumpgate2_y))
		local jt = self:getTalentFromId(self.T_JUMPGATE_TELEPORT_TWO)
		local max = jt.getRange(self, jt)
		local fnt = "buff_font_small"
		if val >= 1000 then fnt = "buff_font_smaller" end
		if val <= max then
			return "#LIGHT_GREEN#"..tostring(math.ceil(val)), fnt
		else
			return "#LIGHT_RED#"..tostring(math.ceil(val)), fnt
		end
	end,
	activate = function(self, t)
		local oe = game.level.map(self.x, self.y, engine.Map.TERRAIN)
		if not oe or oe:attr("temporary") then return false end
		local e = mod.class.Object.new{
			old_feat = oe, type = oe.type, subtype = oe.subtype,
			name = "jumpgate", image = oe.image, add_mos = {{image = "terrain/wormhole.png"}},
			display = '&', color=colors.PURPLE,
			temporary = 1, -- This prevents overlapping of terrain changing effects; as this talent is a sustain it does nothing else
		}
		
		game.level.map(game.player.x, game.player.y, engine.Map.TERRAIN, e)
		local ret = {
			jumpgate2 = e, jumpgate2_x = game.player.x,	jumpgate2_y = game.player.y,
			jumpgate2_level = game.zone.short_name .. "-" .. game.level.level,
			particle = self:addParticles(Particles.new("time_shield", 1))
		}
		return ret
	end,
	deactivate = function(self, t, p)
		-- Reset the terrain tile
		game.level.map(p.jumpgate2_x, p.jumpgate2_y, engine.Map.TERRAIN, p.jumpgate2.old_feat)
		game.nicer_tiles:updateAround(game.level, p.jumpgate2_x, p.jumpgate2_y)
		self:removeParticles(p.particle)
		return true
	end,
	info = function(self, t)
		local jumpgate_teleport = self:getTalentFromId(self.T_JUMPGATE_TELEPORT_TWO)
		local range = jumpgate_teleport.getRange(self, jumpgate_teleport)
		return ([[현재 위치에 두번째 그림자 도약문을 생성합니다. 이 기술이 유지되는 동안, '두번째 도약문 : 이동' 기술을 사용하여 %d 칸 내에 있는 도약문으로 즉시 이동할 수 있습니다. 
371 		도약문을 계단이 있는 곳에 만들었을 경우, 계단은 사용할 수 없게 됩니다. 계단을 이용하려면 두번째 도약문 기술을 해제해야 합니다.]]):format(range) 
372 	end, 
}

newTalent{
	name = "Jumpgate Two: Teleport To", short_name = "JUMPGATE_TELEPORT_TWO",
	kr_name = "두번째 도약문 : 이동",
	type = {"celestial/other", 1},
	points = 1,
	cooldown = 7,
	negative = 14,
	type_no_req = true,
	tactical = { ESCAPE = 2 },
	no_npc_use = true,
	getRange = function(self, t) return self:callTalent(self.T_JUMPGATE_TELEPORT, "getRange") end,
	-- Check distance in preUseTalent to grey out the talent
	is_teleport = true,
	no_unlearn_last = true,
	on_pre_use = function(self, t)
		local eff = self.sustain_talents[self.T_JUMPGATE_TWO]
		return eff and core.fov.distance(self.x, self.y, eff.jumpgate2_x, eff.jumpgate2_y) <= t.getRange(self, t)
	end,
	action = function(self, t)
		local eff = self.sustain_talents[self.T_JUMPGATE_TWO]
		if not eff then
			game.logPlayer(self, "순간이동을 하려면, 두번째 도약문 기술이 유지된 상태여야 합니다.")
			return
		end
		game.level.map:particleEmitter(self.x, self.y, 1, "teleport")
		self:teleportRandom(eff.jumpgate2_x, eff.jumpgate2_y, 1)
		game.level.map:particleEmitter(eff.jumpgate2_x, eff.jumpgate2_y, 1, "teleport")
		game:playSoundNear(self, "talents/teleport")
		return true
	end,
	info = function(self, t)
		return ([[%d 칸 내에 있는 두번째 도약문으로 즉시 이동합니다.]]):format(t.getRange(self, t))
	end,
}
