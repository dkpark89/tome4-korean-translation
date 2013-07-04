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

local Object = require "mod.class.Object"

function DistortionCount(self)
	local distortion_count = 0
	for tid, lev in pairs(game.player.talents) do
		local t = game.player:getTalentFromId(tid)
		if t.type[1]:find("^psionic/") and t.type[1]:find("^psionic/distortion") then
			distortion_count = distortion_count + lev
		end
	end
	print("Distortion Count", distortion_count)
	return distortion_count
end

newTalent{
	name = "Distortion Bolt",
	kr_name = "왜곡의 화살",
	type = {"psionic/distortion", 1},
	points = 5, 
	require = psi_wil_req1,
	cooldown = 3,
	psi = 5,
	tactical = { ATTACKAREA = { PHYSICAL = 2} },
	range = 10,
	radius = function(self, t) return 1 + math.floor(self:getTalentLevel(t)/3) end,
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 10, 150) end,
	target = function(self, t)
		local friendlyfire = true
		if self:getTalentLevel(self.T_DISTORTION_BOLT) >= 5 then
			friendlyfire = false
		end
		return {type="ball", radius=self:getTalentRadius(t), friendlyfire=friendlyfire, range=self:getTalentRange(t), talent=t, display={trail="distortion_trail"}}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local damage = self:mindCrit(t.getDamage(self, t))
		tg.type = "bolt" -- switch our targeting to a bolt for the initial projectile
		self:projectile(tg, x, y, DamageType.DISTORTION, {dam=damage,  penetrate=true, explosion=damage*1.5, friendlyfire=tg.friendlyfire, distort=DistortionCount(self), radius=self:getTalentRadius(t)})
		game:playSoundNear(self, "talents/distortion")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local radius = self:getTalentRadius(t)
		local distort = DistortionCount(self)
		return ([[왜곡의 화살을 발사하여, 저항을 무시하고 %0.2f 물리 피해를 줍니다. 화살에 맞은 적은 왜곡되어 물리 저항력이 %d%% 감소하며, 왜곡 효과는 2 턴 동안 유지됩니다.
		이미 왜곡된 적에게 왜곡의 화살을 맞출 경우, 왜곡 폭발이 일어나 주변 %d 칸 반경에 원래 피해량의 150%% 에 해당하는 피해를 줍니다.
		왜곡의 화살 기술에 기술 점수를 투자할 때마다, 왜곡 효과의 물리 저항력 감소 효과가 1%% 상승하게 됩니다.
		기술 레벨이 5 이상이면, 왜곡의 형태를 조절하여 자신과 아군은 폭발에 휘말리지 않게 만들 수 있게 됩니다.
		피해량은 정신력의 영향을 받아 증가합니다.]]):format(damDesc(self, DamageType.PHYSICAL, damage), distort, radius) 
	end,
}

newTalent{
	name = "Distortion Wave",
	kr_name = "왜곡 파동",
	type = {"psionic/distortion", 2},
	points = 5, 
	require = psi_wil_req2,
	cooldown = 6,
	psi = 10,
	tactical = { ATTACKAREA = { PHYSICAL = 2}, ESCAPE = 2,
		DISABLE = function(self, t, target) if target and target:hasEffect(target.EFF_DISTORTION) then return 2 else return 0 end end,
	},
	range = 0,
	radius = function(self, t) return math.ceil(3 + self:getTalentLevel(t)) end,
	requires_target = true,
	direct_hit = true,
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 10, 150) end,
	getPower = function(self, t) return math.ceil(self:getTalentRadius(t)/2) end,
	target = function(self, t)
		local friendlyfire = true
		if self:getTalentLevel(self.T_DISTORTION_BOLT) >=5 then
			friendlyfire = false
		end
		return { type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), friendlyfire=friendlyfire, talent=t }
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.DISTORTION, {dam=self:mindCrit(t.getDamage(self, t)), knockback=t.getPower(self, t), stun=t.getPower(self, t), distort=DistortionCount(self)})
		game:playSoundNear(self, "talents/warp")
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "generic_wave", {radius=tg.radius, tx=x-self.x, ty=y-self.y, rm=255, rM=255, gm=180, gM=255, bm=180, bM=255, am=35, aM=90})
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local radius = self:getTalentRadius(t)
		local power = t.getPower(self, t)
		local distort = DistortionCount(self)
		return ([[전방 %d 칸 반경에 왜곡의 파동을 만들어내, %0.2f 물리 피해를 주고 적들을 뒤로 밀어냅니다.
		파동의 영향을 받은 적은 왜곡되어 물리 저항력이 %d%% 감소하며, 왜곡 효과는 2 턴 동안 유지됩니다.
		왜곡 파동 기술에 기술 점수를 투자할 때마다, 왜곡 효과의 물리 저항력 감소 효과가 1%% 상승하게 됩니다.
		이미 왜곡된 적에게 왜곡 파동을 맞출 경우, 대상은 %d 턴 동안 기절하게 됩니다.
		피해량은 정신력의 영향을 받아 증가합니다.]]):format(radius, damDesc(self, DamageType.PHYSICAL, damage), distort, power) 
	end,
}

newTalent{
	name = "Ravage",
	kr_name = "유린",
	type = {"psionic/distortion", 3},
	points = 5, 
	require = psi_wil_req3,
	cooldown = 12,
	psi = 20,
	tactical = { ATTACK = { PHYSICAL = 2},
		DISABLE = function(self, t, target) if target and target:hasEffect(target.EFF_DISTORTION) then return 4 else return 0 end end,
	},
	range = 10,
	requires_target = true,
	direct_hit = true,
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 10, 50) end,
	getDuration = function(self, t) return 4 + math.floor(self:getTalentLevel(t)) end,
	target = function(self, t)
		return {type="hit", range=self:getTalentRange(t), talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		local target = game.level.map(x, y, Map.ACTOR)
		if not target then return end
		
		local ravage = false
		if target:hasEffect(target.EFF_DISTORTION) then
			ravage = true
		end
		target:setEffect(target.EFF_RAVAGE, t.getDuration(self, t), {src=self, dam=self:mindCrit(t.getDamage(self, t)), ravage=ravage, distort=DistortionCount(self), apply_power=self:combatMindpower()})
		game:playSoundNear(self, "talents/echo")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		local distort = DistortionCount(self)
		return ([[왜곡의 힘으로 대상을 유린하여, 매 턴마다 %0.2f 물리 피해를 줍니다. (지속시간 : %d 턴)
		유린당한 대상은 왜곡되어 물리 저항력이 %d%% 감소하며, 왜곡 효과는 2 턴 동안 유지됩니다.
		이미 왜곡된 대상을 유린할 경우 피해량이 50%% 증가하며, 매 턴마다 대상의 이로운 물리적 상태효과나 유지형 기술이 해제됩니다.
		유린 기술에 기술 점수를 투자할 때마다, 왜곡 효과의 물리 저항력 감소 효과가 1%% 상승하게 됩니다.
		피해량은 정신력의 영향을 받아 증가합니다.]]):format(damDesc(self, DamageType.PHYSICAL, damage), duration, distort) 
	end,
}

newTalent{
	name = "Maelstrom",
	kr_name = "염력의 소용돌이",
	type = {"psionic/distortion", 4},
	points = 5, 
	require = psi_wil_req4,
	cooldown = 24,
	psi = 30,
	tactical = { ATTACK = { PHYSICAL = 2}, DISABLE = 2, ESCAPE=2 },
	range = 10,
	radius = function(self, t) return math.min(4, 1 + math.ceil(self:getTalentLevel(t)/3)) end,
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 10, 50) end,
	getDuration = function(self, t) return 4 + math.ceil(self:getTalentLevel(t)) end,
	target = function(self, t)
		return {type="ball", radius=self:getTalentRadius(t), range=self:getTalentRange(t), nolock=true, talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		local oe = game.level.map(x, y, Map.TERRAIN)
		if not oe or oe:attr("temporary") or oe.is_maelstrom or game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move") then return nil end
		
		local e = Object.new{
			old_feat = oe,
			type = oe.type, subtype = oe.subtype,
			name = "maelstrom", image = oe.image,
			kr_name = "염력의 소용돌이",
			display = oe.display, color=oe.color, back_color=oe.back_color,
			always_remember = true,
			temporary = t.getDuration(self, t),
			is_maelstrom = true,
			x = x, y = y,
			canAct = false,
			dam = self:mindCrit(t.getDamage(self, t)),
			radius = self:getTalentRadius(t),
			act = function(self)
				local tgts = {}
				local Map = require "engine.Map"
				local DamageType = require "engine.DamageType"
				local grids = core.fov.circle_grids(self.x, self.y, self.radius, true)
				for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
					local Map = require "engine.Map"
					local target = game.level.map(x, y, Map.ACTOR)
					local friendlyfire = true
					if self.summoner:getTalentLevel(self.summoner.T_DISTORTION_BOLT) >= 5 then
						friendlyfire = false
					end
					if target and not (friendlyfire == false and self.summoner:reactionToward(target) >= 0) then 
						tgts[#tgts+1] = {actor=target, sqdist=core.fov.distance(self.x, self.y, x, y)}
					end
				end end
				table.sort(tgts, "sqdist")
				for i, target in ipairs(tgts) do
					if target.actor:canBe("knockback") then
						target.actor:pull(self.x, self.y, 1)
						game.logSeen(target.actor, "%s %s에 의해 끌어당겨집니다!", (target.kr_name or target.actor.name):capitalize():addJosa("가"), (self.kr_name or self.name))
					end
					DamageType:get(DamageType.PHYSICAL).projector(self.summoner, target.actor.x, target.actor.y, DamageType.PHYSICAL, self.dam)
					target.actor:setEffect(target.actor.EFF_DISTORTION, 2, {power=DistortionCount(self)})
				end

				self:useEnergy()
				self.temporary = self.temporary - 1
				if self.temporary <= 0 then
					game.level.map:removeParticleEmitter(self.particles)	
					game.level.map(self.x, self.y, engine.Map.TERRAIN, self.old_feat)
					game.level:removeEntity(self)
					game.level.map:updateMap(self.x, self.y)
				end
			end,
			summoner_gain_exp = true,
			summoner = self,
		}
		
		e.particles = game.level.map:particleEmitter(x, y, e.radius, "generic_vortex", {radius=e.radius, rm=255, rM=255, gm=180, gM=255, bm=180, bM=255, am=35, aM=90})
		game.level:addEntity(e)
		game.level.map(x, y, Map.TERRAIN, e)
		--game.nicer_tiles:updateAround(game.level, x, y)
		game.level.map:updateMap(x, y)
		game:playSoundNear(self, "talents/lightning_loud")
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local damage = t.getDamage(self, t)
		local radius = self:getTalentRadius(t)
		local distort = DistortionCount(self)
		return ([[%d 턴 동안 강력한 소용돌이를 만들어냅니다. 매 턴마다 소용돌이는 주변 %d 칸 반경의 적들을 끌어당기며, %0.2f 물리 피해를 줍니다.
		소용돌이의 영향을 받은 적은 왜곡되어 물리 저항력이 %d%% 감소하며, 왜곡 효과는 2 턴 동안 유지됩니다.
		염력의 소용돌이 기술에 기술 점수를 투자할 때마다, 왜곡 효과의 물리 저항력 감소 효과가 1%% 상승하게 됩니다.
		피해량은 정신력의 영향을 받아 증가합니다.]]):format(duration, radius, damDesc(self, DamageType.PHYSICAL, damage), distort) 
	end,
}
