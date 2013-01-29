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

require "engine.krtrUtils"

newTalent{
	name = "Ghoul",
	kr_display_name = "구울",
	type = {"undead/ghoul", 1},
	mode = "passive",
	require = undeads_req1,
	points = 5,
	on_learn = function(self, t)
		self.inc_stats[self.STAT_STR] = self.inc_stats[self.STAT_STR] + 2
		self:onStatChange(self.STAT_STR, 2)
		self.inc_stats[self.STAT_CON] = self.inc_stats[self.STAT_CON] + 2
		self:onStatChange(self.STAT_CON, 2)
	end,
	on_unlearn = function(self, t)
		self.inc_stats[self.STAT_STR] = self.inc_stats[self.STAT_STR] - 2
		self:onStatChange(self.STAT_STR, -2)
		self.inc_stats[self.STAT_CON] = self.inc_stats[self.STAT_CON] - 2
		self:onStatChange(self.STAT_CON, -2)
	end,
	info = function(self, t)
		return ([[구울의 신체를 개선하여, 힘과 체격 능력치를 %d 만큼 증가시킵니다.]]):format(2 * self:getTalentLevelRaw(t))
	end,
}

newTalent{
	name = "Ghoulish Leap",
	kr_display_name = "구울의 도약",
	type = {"undead/ghoul", 2},
	require = undeads_req2,
	points = 5,
	cooldown = 20,
	tactical = { CLOSEIN = 3 },
	direct_hit = true,
	range = function(self, t) return math.floor(4 + self:getTalentLevel(t) * 1.2) end,
	requires_target = true,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		if core.fov.distance(self.x, self.y, x, y) > self:getTalentRange(t) then return nil end

		local block_actor = function(_, bx, by) return game.level.map:checkEntity(bx, by, Map.TERRAIN, "block_move", self) end
		local l = self:lineFOV(x, y, block_actor)
		local lx, ly, is_corner_blocked = l:step()
		local tx, ty, _ = lx, ly
		while lx and ly do
			if is_corner_blocked or block_actor(_, lx, ly) then break end
			tx, ty = lx, ly
			lx, ly, is_corner_blocked = l:step()
		end

		-- Find space
		if block_actor(_, tx, ty) then return nil end
		local fx, fy = util.findFreeGrid(tx, ty, 5, true, {[Map.ACTOR]=true})
		if not fx then
			return
		end
		self:move(fx, fy, true)

		return true
	end,
	info = function(self, t)
		return ([[목표 지점으로 도약합니다.]])
	end,
}

newTalent{
	name = "Retch",
	kr_display_name = "구역질",
	type = {"undead/ghoul",3},
	require = undeads_req3,
	points = 5,
	cooldown = 25,
	tactical = { ATTACK = { BLIGHT = 1 }, HEAL = 1 },
	range=1,
	requires_target = true,
	action = function(self, t)
		local duration = self:getTalentLevelRaw(t) * 2 + 5
		local radius = 3
		local dam = 10 + self:combatTalentStatDamage(t, "con", 10, 60)
		local tg = {type="ball", range=self:getTalentRange(t), radius=radius}
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			self.x, self.y, duration,
			DamageType.RETCH, dam,
			radius,
			5, nil,
			engine.Entity.new{alpha=100, display='', color_br=30, color_bg=180, color_bb=60},
			nil, self:spellFriendlyFire()
		)
		game:playSoundNear(self, "talents/cloud")
		return true
	end,
	info = function(self, t)
		local dam = 10 + self:combatTalentStatDamage(t, "con", 10, 60)
		return ([[주변의 땅에 토하여, 해당 지역의 언데드에게는 치료 효과를 주고 생명체에게는 피해를 줍니다.
		%d 턴간 지속되며, 황폐속성의 %d 피해를 주거나 생명력을 %d 만큼 치료합니다.]]):format(self:getTalentLevelRaw(t) * 2 + 5, damDesc(self, DamageType.BLIGHT, dam), dam * 1.5)
	end,
}

newTalent{
	name = "Gnaw",
	kr_display_name = "물어뜯기",
	type = {"undead/ghoul", 4},
	require = undeads_req4,
	points = 5,
	cooldown = 15,
	tactical = { ATTACK = {BLIGHT = 2} },
	range = 1,
	requires_target = true,
	getDamage = function(self, t) return 0.2 + self:getTalentLevel(t) / 12 end,
	getDuration = function(self, t) return 3 + math.ceil(self:getTalentLevel(t)) end,
	getDiseaseDamage = function(self, t) return self:combatTalentStatDamage(t, "con", 5, 50) end,
	getStatDamage = function(self, t) return self:combatTalentStatDamage(t, "con", 5, 20) end,
	spawn_ghoul = function (self, target, t)
		local x, y = util.findFreeGrid(target.x, target.y, 10, true, {[Map.ACTOR]=true})
		if not x then return nil end

		local list = mod.class.NPC:loadList("/data/general/npcs/ghoul.lua")
		local m = list.GHOUL:clone()
		if not m then return nil end

		m:resolve() m:resolve(nil, true)
		m.ai = "summoned"
		m.ai_real = "dumb_talented_simple"
		m.faction = self.faction
		m.summoner = self
		m.summoner_gain_exp = true
		m.summon_time = 20
		m.exp_worth = 0
		m.no_drops = true
		if self:knowTalent(self.T_BLIGHTED_SUMMONING) then 
			m:incIncStat("mag", self:getMag()) 
			m:learnTalent(m.T_REND, true, 3)
		end
		self:attr("summoned_times", 1)
		
		game.zone:addEntity(game.level, m, "actor", target.x, target.y)
		game.level.map:particleEmitter(target.x, target.y, 1, "slime")
		game:playSoundNear(target, "talents/slime")
		game.logPlayer(game.player, "%s의 시체가 #DARK_GREEN#구울#LAST#이 되어 일어납니다.", (target.kr_display_name or target.name):capitalize())
	end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		local hitted = self:attackTarget(target, nil, t.getDamage(self, t), true)

		-- Damage Stats?
		local str_damage, con_damage, dex_damage = 0
		if self:getTalentLevel(t) >=2 then str_damage = t.getStatDamage(self, t) end
		if self:getTalentLevel(t) >=3 then dex_damage = t.getStatDamage(self, t) end
		if self:getTalentLevel(t) >=4 then con_damage = t.getStatDamage(self, t) end
		
		-- Ghoulify??
		local ghoulify = 0
		if self:getTalentLevel(t) >=5 then ghoulify = 1 end
		
		if hitted then
			if target:canBe("disease") then
				if target.dead and ghoulify > 0 then
					t.spawn_ghoul(self, target, t)
				end
				target:setEffect(target.EFF_GHOUL_ROT, 3 + math.ceil(self:getTalentLevel(t)), {src=self, apply_power=self:combatPhysicalpower(), dam=t.getDiseaseDamage(self, t), str=str_damage, con=con_damage, dex=dex_damage, make_ghoul=ghoulify})
			else
				game.logSeen(target, "%s 질병을 저항했습니다!", (target.kr_display_name or target.name):capitalize():addJosa("가"))
			end
		end

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		local disease_damage = t.getDiseaseDamage(self, t)
		local stat_damage = t.getStatDamage(self, t)
		return ([[목표를 물어뜯어 피해량의 %d%% 만큼 피해를 줍니다. 공격이 성공하면, 목표는 %d 턴간 '구울의 부패'에 감염됩니다.
		'구울의 부패'에 감염되면 매턴마다 %0.2f 만큼의 황폐속성 피해릅 입습니다. 기술 레벨이 2가 되면 '구울의 부패'는 힘을 %d 만큼 감소시키고, 기술 레벨 3부터는 민첩도 %d 만큼 감소시키며, 기술 레벨 4부터는 체격도 %d 만큼 감소시킵니다.
		기술 레벨이 5가 되면, '구울의 부패'에 감염된 채로 죽은 대상은 동료 구울로 되살아나게 됩니다.
		황폐속성 피해량과 능력치 감소량은 체격 능력치의 영향을 받아 증가합니다.]]):
		format(100 * damage, duration, damDesc(self, DamageType.BLIGHT, disease_damage), stat_damage, stat_damage, stat_damage)
	end,
}

