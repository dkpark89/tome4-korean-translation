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

newTalent{
	name = "Wraithform",
	kr_name = "악령 변신",
	type = {"corruption/shadowflame", 1},
	require = corrs_req1,
	points = 5,
	vim = 20,
	cooldown = 30,
	tactical = { BUFF = 2, ESCAPE = 1, CLOSEIN = 1 },
	getDuration = function(self, t) return math.floor(self:combatTalentLimit(t, 30, 5, 9)) end, -- Limit < 30 (make sure they can't hide forever)
	action = function(self, t)
		self:setEffect(self.EFF_WRAITHFORM, t.getDuration(self, t), {def=self:combatTalentSpellDamage(t, 5, 19), armor=self:combatTalentSpellDamage(t, 5, 15)})
		return true
	end,
	info = function(self, t)
		return ([[악령으로 변신하여, %d 턴 동안 벽을 통과할 수 있게 됩니다. (단, 벽 안에서는 숨을 쉴 수 없습니다)
		또한 회피도가 %d / 방어도가 %d 상승합니다.
		If you are still in a wall when the effect ends you will randomly teleport.
		이 효과는 주문력의 영향을 받아 증가합니다.]]): --@@ 한글화 필요 : 윗줄
		format(t.getDuration(self, t), self:combatTalentSpellDamage(t, 5, 19), self:combatTalentSpellDamage(t, 5, 15))
	end,
}

newTalent{
	name = "Darkfire",
	kr_name = "어둠의 불꽃",
	type = {"corruption/shadowflame", 2},
	require = corrs_req2,
	points = 5,
	cooldown = 8,
	vim = 15,
	requires_target = true,
	range = 6,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 2, 6)) end,
	proj_speed = 4,
	tactical = { ATTACKAREA = {FIRE = 1, DARKNESS = 1} },
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=self:spellFriendlyFire(), talent=t, display={particle="bolt_fire", trail="firetrail"}}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:projectile(tg, x, y, DamageType.SHADOWFLAME, self:spellCrit(self:combatTalentSpellDamage(t, 28, 220)), function(self, tg, x, y, grids)
			game.level.map:particleEmitter(x, y, tg.radius, "fireflash", {radius=tg.radius, grids=grids, tx=x, ty=y})
			game.level.map:particleEmitter(x, y, tg.radius, "shadow_flash", {radius=tg.radius, grids=grids, tx=x, ty=y})
		end)
		game:playSoundNear(self, "talents/fireflash")
		return true
	end,
	info = function(self, t)
		return ([[어둠의 불꽃을 화살 형태로 발사하여, 대상과 주변 %d 칸 반경에 %0.2f 화염 피해와 %0.2f 어둠 피해를 줍니다.
		피해량은 주문력의 영향을 받아 증가합니다.]]):format(self:getTalentRadius(t), 
		damDesc(self, DamageType.FIRE, self:combatTalentSpellDamage(t, 28, 220) / 2), 
		damDesc(self, DamageType.DARKNESS, 
		self:combatTalentSpellDamage(t, 28, 220) / 2))
	end,
}

newTalent{
	name = "Flame of Urh'Rok",
	kr_name = "울흐'록의 불꽃",
	type = {"corruption/shadowflame", 3},
	require = corrs_req3,
	mode = "sustained",
	points = 5,
	sustain_vim = 90,
	cooldown = 30,
	tactical = { BUFF = 2 },
	getSpeed = function(self, t) return self:combatTalentScale(t, 0.03, 0.15, 0.75) end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/flame")
		self.__old_type = {self.type, self.subtype}
		self.type, self.subtype = "demon", "major"
		local power = t.getSpeed(self, t)
		return {
			demon = self:addTemporaryValue("demon", 1),
			speed = self:addTemporaryValue("global_speed_add", power),
			res = self:addTemporaryValue("resists", {[DamageType.FIRE]=self:combatTalentSpellDamage(t, 20, 30), [DamageType.DARKNESS]=self:combatTalentSpellDamage(t, 20, 35)}),
			particle = self:addParticles(Particles.new("shadowfire", 1)),
		}
	end,
	deactivate = function(self, t, p)
		self.type, self.subtype = unpack(self.__old_type)
		self.__old_type = nil
		self:removeTemporaryValue("resists", p.res)
		self:removeTemporaryValue("global_speed_add", p.speed)
		self:removeTemporaryValue("demon", p.demon)
		self:removeParticles(p.particle)
		return true
	end,
	info = function(self, t)
		return ([[강력한 악마의 군주 울흐'록의 정수를 불러와, 악마로 변신합니다.
		악마 상태에서는 %d%% 화염 저항력, %d%% 어둠 저항력을 얻으며, 전체 속도가 %d%% 상승합니다.
		또한, 공포의 영역에서 뿜어져나오는 불길이 오히려 생명력을 회복시켜주게 됩니다.
		마법의 효과는 주문력의 영향을 받아 증가합니다.]]):
		format(self:combatTalentSpellDamage(t, 20, 30), self:combatTalentSpellDamage(t, 20, 35), t.getSpeed(self, t)*100)
	end,
}

newTalent{
	name = "Fearscape", short_name = "DEMON_PLANE",
	kr_name = "공포의 영역",
	type = {"corruption/shadowflame", 4},
	require = corrs_req4,
	mode = "sustained",
	points = 5,
	sustain_vim = 90,
	remove_on_zero = true,
	cooldown = 60,
	no_sustain_autoreset = true,
	random_boss_rarity = 10,
	tactical = { DISABLE = function(self, t, target) if target and target.game_ender then return 3 else return 0 end end},
	range = 5,
	on_pre_use = function(self, t) return self:canBe("planechange") and self:getVim() >= 10 end,
	activate = function(self, t)
		if game.zone.is_demon_plane then
			game.logPlayer(self, "이 마법은 공포의 영역 안에서는 사용할 수 없습니다.")
			return
		end
		if game.zone.no_planechange then
			game.logPlayer(self, "이 마법은 여기서 사용할 수 없습니다.")
			return
		end

		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty or not target then return nil end
		local _ _, tx, ty = self:canProject(tg, tx, ty)
		if not tx or not ty or not target then return nil end
		target = game.level.map(tx, ty, Map.ACTOR)
		if not tx or not ty or not target then return nil end
		if not (target.player and target.game_ender) and not (self.player and self.game_ender) then return nil end
		if target == self then return end
		if target:attr("negative_status_effect_immune") or target:attr("status_effect_immune") then return nil end

		if not self:canBe("planechange") or target.summon_time or target.summon then
			game.logPlayer(self, "주문이 헛나갔습니다...")
			return
		end

		game:playSoundNear(self, "talents/flame")
		local dam = self:combatTalentSpellDamage(t, 12, 140)

		game:onTickEnd(function()
			if self:attr("dead") then return end
			local oldzone = game.zone
			local oldlevel = game.level

			-- Remove them before making the new elvel, this way party memebrs are not removed from the old
			if oldlevel:hasEntity(self) then oldlevel:removeEntity(self) end
			if oldlevel:hasEntity(target) then oldlevel:removeEntity(target) end

			oldlevel.no_remove_entities = true
			local zone = mod.class.Zone.new("demon-plane-spell")
			local level = zone:getLevel(game, 1, 0)
			oldlevel.no_remove_entities = nil
			level.demonfire_dam = dam
			level.plane_owner = self

			level:addEntity(self)
			level:addEntity(target)

			level.source_zone = oldzone
			level.source_level = oldlevel
			game.zone = zone
			game.level = level
			game.zone_name_s = nil

			local x1, y1 = util.findFreeGrid(4, 6, 20, true, {[Map.ACTOR]=true})
			if x1 then
				self:move(x1, y1, true)
				game.level.map:particleEmitter(x1, y1, 1, "demon_teleport")
			end
			local x2, y2 = util.findFreeGrid(8, 6, 20, true, {[Map.ACTOR]=true})
			if x2 then
				target:move(x2, y2, true)
				game.level.map:particleEmitter(x2, y2, 1, "demon_teleport")
			end

			target:setTarget(self)
			target.demon_plane_trapper = self
			target.demon_plane_on_die = target.on_die
			target.on_die = function(self, ...)
				self.demon_plane_trapper:forceUseTalent(self.T_DEMON_PLANE, {ignore_energy=true})
				local args = {...}
				game:onTickEnd(function()
					if self.demon_plane_on_die then self:demon_plane_on_die(unpack(args)) end
					self.on_die, self.demon_plane_on_die = self.demon_plane_on_die, nil
				end)
			end

			self.demon_plane_on_die = self.on_die
			self.on_die = function(self, ...)
				self:forceUseTalent(self.T_DEMON_PLANE, {ignore_energy=true})
				local args = {...}
				game:onTickEnd(function()
					if self.demon_plane_on_die then self:demon_plane_on_die(unpack(args)) end
					self.on_die, self.demon_plane_on_die = self.demon_plane_on_die, nil
					if not game.party:hasMember(self) then world:gainAchievement("FEARSCAPE", game:getPlayer(true)) end
				end)
			end

			game.logPlayer(game.player, "#LIGHT_RED#공포의 영역으로 끌려갔습니다!")
			game.party:learnLore("fearscape-entry")
			level.allow_demon_plane_damage = true
		end)

		local particle
		if core.shader.active(4) then
			local bx, by = self:attachementSpot("back", true)
			particle = self:addParticles(Particles.new("shader_wings", 1, {infinite=1, x=bx, y=by, img="bloodwings", flap=28, a=0.6}))
		end
		local ret = {
			vim = self:addTemporaryValue("vim_regen", -5),
			target = target,
			x = self.x, y = self.y,
			particle = particle,
		}
		return ret
	end,
	deactivate = function(self, t, p)
		-- If we're a clone of the original fearscapper, just deactivate
		if not self.on_die then return true end
		
		if p.particle then self:removeParticles(p.particle) end
		self:removeTemporaryValue("vim_regen", p.vim)

		game:onTickEnd(function()
			-- Collect objects
			local objs = {}
			for i = 0, game.level.map.w - 1 do for j = 0, game.level.map.h - 1 do
				for z = game.level.map:getObjectTotal(i, j), 1, -1 do
					objs[#objs+1] = game.level.map:getObject(i, j, z)
					game.level.map:removeObject(i, j, z)
				end
			end end

			local oldzone = game.zone
			local oldlevel = game.level
			local zone = game.level.source_zone
			local level = game.level.source_level

			if not self.dead then
				oldlevel:removeEntity(self, true)
				level:addEntity(self)
			end

			game.zone = zone
			game.level = level
			game.zone_name_s = nil

			local x1, y1 = util.findFreeGrid(p.x, p.y, 20, true, {[Map.ACTOR]=true})
			if x1 then
				if not self.dead then
					self:move(x1, y1, true)
					self.on_die, self.demon_plane_on_die = self.demon_plane_on_die, nil
					game.level.map:particleEmitter(x1, y1, 1, "demon_teleport")
				else
					self.x, self.y = x1, y1
				end
			end
			local x2, y2 = util.findFreeGrid(p.x, p.y, 20, true, {[Map.ACTOR]=true})
			if not p.target.dead then
				if x2 then
					p.target:move(x2, y2, true)
					p.target.on_die, p.target.demon_plane_on_die = p.target.demon_plane_on_die, nil
					game.level.map:particleEmitter(x2, y2, 1, "demon_teleport")
				end
				if oldlevel:hasEntity(p.target) then oldlevel:removeEntity(p.target, true) end
				level:addEntity(p.target)
			else
				p.target.x, p.target.y = x2, y2
			end

			-- Add objects back
			for i, o in ipairs(objs) do
				if self.dead then
					game.level.map:addObject(p.target.x, p.target.y, o)
				else
					game.level.map:addObject(self.x, self.y, o)
				end
			end

			-- Remove all npcs in the fearscape
			for uid, e in pairs(oldlevel.entities) do
				if e ~= self and e ~= p.target and e.die then e:die() end
			end

			-- Reload MOs
			game.level.map:redisplay()
			game.level.map:recreate()
			game.uiset:setupMinimap(game.level)

			game.logPlayer(game.player, "#LIGHT_RED#공포의 영역을 빠져나왔습니다!")
		end)

		return true
	end,
	info = function(self, t)
		return ([[공포의 영역으로 가는 교차점을 소환합니다. 
		오직 대상과 시전자 둘만이 공포의 영역으로 끌려가며, 둘 중 하나가 죽거나 마법이 끝날 때까지 나갈 수 없게 됩니다.
		공포의 영역에서는 열기가 끊임없이 올라오기 때문에, 대상과 시전자 모두 매 턴마다 %0.2f 화염 피해를 받습니다. (악마는 생명력을 회복합니다)
		마법이 끝나면 시전자와 (아직 살아있을 경우) 대상만이 원래 세계로 돌아가게 되며, 모든 소환수들은 공포의 영역에 남겨집니다.
		도구나 장비 등 물건들은 원래 세계로 돌아가며, 이미 공포의 영역에 들어왔을 경우에는 이 마법을 사용할 수 없습니다.
		이 강력한 주문은 매 턴마다 원기를 5씩 소모하며, 원기가 0이 되면 종료됩니다.
		피해량은 주문력의 영향을 받아 증가합니다.]]):format(damDesc(self, DamageType.FIRE, self:combatTalentSpellDamage(t, 12, 140)))
	end,
}
