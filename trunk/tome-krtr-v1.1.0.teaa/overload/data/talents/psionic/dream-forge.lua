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

newTalent{
	name = "Forge Shield",
	kr_name = "방패 연마",
	type = {"psionic/dream-forge", 1},
	points = 5, 
	require = psi_wil_high1,
	cooldown = 12,
	sustain_psi = 50,
	mode = "sustained",
	tactical = { DEFEND = 2, },
	getPower = function(self, t) return self:combatTalentMindDamage(t, 5, 30) end,
	getDuration = function(self,t) return math.floor(self:combatTalentScale(t, 1, 2)) end,
	doForgeShield = function(type, dam, t, self, src)
		-- Grab our damage threshold
		local dam_threshold = self.max_life * 0.15
		if self:knowTalent(self.T_SOLIPSISM) then
			local t = self:getTalentFromId(self.T_SOLIPSISM)
			local ratio = t.getConversionRatio(self, t)
			local psi_percent =  self:getMaxPsi() * t.getConversionRatio(self, t)
			dam_threshold = (self.max_life * (1 - ratio) + psi_percent) * 0.15
		end

		local dur = t.getDuration(self,t)
		local blocked
		local amt = dam
		local eff = self:hasEffect(self.EFF_FORGE_SHIELD)
		if not eff and dam > dam_threshold then
			self:setEffect(self.EFF_FORGE_SHIELD, dur, {power=t.getPower(self, t), number=1, d_types={[type]=true}})
			amt = util.bound(dam - t.getPower(self, t), 0, dam)
			blocked = t.getPower(self, t)
			game.logSeen(self, "#ORANGE#%s 꿈의 방패를 만들어 적의 공격에 대항합니다!", (self.kr_name or self.name):capitalize():addJosa("가"))
		elseif eff and eff.d_types[type] then
			amt = util.bound(dam - eff.power, 0, dam)
			blocked = eff.power
		elseif eff and dam > dam_threshold * (1 + eff.number) then
			eff.number = eff.number + 1
			eff.d_types[type] = true
			amt = util.bound(dam - eff.power, 0, dam)
			blocked = eff.power
			game.logSeen(self, "#ORANGE#%s의 꿈의 방패가 공격에 의해 강화되었습니다!", (self.kr_name or self.name):capitalize())
		end

		if blocked then
			print("[Forge Shield] blocked", math.min(blocked, dam), DamageType.dam_def[type].name, "damage")
		end
		
		if amt == 0 and src.life then src:setEffect(src.EFF_COUNTERSTRIKE, 1, {power=t.getPower(self, t), no_ct_effect=true, src=self, nb=1}) end
		return amt
	end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/spell_generic")
		local ret ={
		}
		if self:knowTalent(self.T_FORGE_ARMOR) then
			local t = self:getTalentFromId(self.T_FORGE_ARMOR)
			ret.def = self:addTemporaryValue("combat_def", t.getDefense(self, t))
			ret.armor = self:addTemporaryValue("combat_armor", t.getArmor(self, t))
			ret.psi = self:addTemporaryValue("psi_regen_when_hit", t.getPsiRegen(self, t))
		end
		return ret
	end,
	deactivate = function(self, t, p)
		if p.def then self:removeTemporaryValue("combat_def", p.def) end
		if p.armor then self:removeTemporaryValue("combat_armor", p.armor) end
		if p.psi then self:removeTemporaryValue("psi_regen_when_hit", p.psi) end
	
		return true	
	end,
	info = function(self, t)
		local power = t.getPower(self, t)
		local dur = t.getDuration(self, t)
		return ([[최대 생명력의 15%%에 해당하는 피해를 한 번에 받으면, 꿈의 방패를 만들어 스스로를 보호합니다. 다음 %d 턴 동안 해당 속성의 모든 공격 피해량을 %0.2f 만큼 덜 받게 됩니다.
		한번에 여러 공격 속성을 막아낼 수 있지만, 속성이 하나 추가될 때마다 방패를 만들기 위해 받아야 하는 피해량이 15%% 증가하게 됩니다.
		꿈의 방패로 공격을 완전히 막아내면, 1 턴 동안 공격자가 반격에 취약해지게 됩니다. (근접공격이나 활, 투석구를 사용한 원거리 공격 시 피해량 2 배)
		기술 레벨이 5 이상이면, 방패가 2 턴 동안 지속됩니다.
		피해 감소량는 정신력의 영향을 받아 증가합니다.]]):format(dur, power) --@@ 변수 순서 조정
	end,
}

newTalent{
	name = "Forge Bellows",
	kr_name = "연마의 굉음",
	type = {"psionic/dream-forge", 2},
	points = 5, 
	require = psi_wil_high2,
	cooldown = 24,
	psi = 30,
	tactical = { ATTACKAREA = { FIRE = 2, MIND = 2}, ESCAPE = 2, },
	range = 0,
	radius = function(self, t) return math.min(7, 2 + math.ceil(self:getTalentLevel(t)/2)) end,
	requires_target = true,
	target = function(self, t)
		return {type="cone", range=self:getTalentRange(t), friendlyfire=false, radius = self:getTalentRadius(t), talent=t}
	end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 2.5, 4.5)) end,
	getBlastDamage = function(self, t) return self:combatTalentMindDamage(t, 10, 100) end,
	getForgeDamage = function(self, t) return self:combatTalentMindDamage(t, 0, 10) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		local blast_damage = self:mindCrit(t.getBlastDamage(self, t))
		local forge_damage = self:mindCrit(t.getForgeDamage(self, t))
		
		-- Do our blast first
		self:project(tg, x, y, DamageType.DREAMFORGE, {dam=blast_damage, dist=math.ceil(tg.radius/2)})
		
		-- Now build our Barrier
		self:project(tg, x, y, function(px, py, tg, self)
			local oe = game.level.map(px, py, Map.TERRAIN)
			if rng.percent(50) or not oe or oe:attr("temporary") or game.level.map:checkAllEntities(px, py, "block_move") then return end
			
			local e = Object.new{
				old_feat = oe,
				type = oe.type, subtype = oe.subtype,
				name = self.name:capitalize().."'s forge barrier",
				kr_name = (self.kr_name or self.name):capitalize().."의 연마된 방벽",
				image = "terrain/lava/lava_mountain5.png",
				display = '#', color=colors.RED, back_color=colors.DARK_GREY,
				shader = "shadow_simulacrum",
				shader_args = { color = {0.6, 0.0, 0.0}, base = 0.9, time_factor = 1500 },
				always_remember = true,
				desc = "소환된 정신의 벽", 
				type = "wall",
				can_pass = {pass_wall=1},
				does_block_move = true,
				show_tooltip = true,
				block_move = true,
				block_sight = true,
				temporary = t.getDuration(self, t),
				x = px, y = py,
				canAct = false,
				dam = forge_damage,
				radius = self:getTalentRadius(t),
				act = function(self)
					local tg = {type="ball", range=0, friendlyfire=false, radius = 1, talent=t, x=self.x, y=self.y,}
					self.summoner.__project_source = self
					self.summoner:project(tg, self.x, self.y, engine.DamageType.DREAMFORGE, self.dam)
					self.summoner.__project_source = nil
					self:useEnergy()
					self.temporary = self.temporary - 1
					if self.temporary <= 0 then
						game.level.map(self.x, self.y, engine.Map.TERRAIN, self.old_feat)
						game.level:removeEntity(self)
						game.level.map:updateMap(self.x, self.y)
					end
				end,
				dig = function(src, x, y, old)
					game.level:removeEntity(old)
					return nil, old.old_feat
				end,
				summoner_gain_exp = true,
				summoner = self,
			}
			e.tooltip = mod.class.Grid.tooltip
			game.level:addEntity(e)
			game.level.map(px, py, Map.TERRAIN, e)
			game.nicer_tiles:updateAround(game.level, px, py)
			game.level.map:updateMap(px, py)
		end)
		game:playSoundNear(self, "talents/fireflash")
		return true
	end,
	info = function(self, t)
		local blast_damage = t.getBlastDamage(self, t)/2
		local radius = self:getTalentRadius(t)
		local duration = t.getDuration(self, t)
		local forge_damage = t.getForgeDamage(self, t)/2
		return ([[전방 %d 칸 반경에 연마의 굉음을 뿜어내 %0.2f 정신 피해, %0.2f 화염 피해를 주고 적들을 밀어냅니다.
		적이 없는 곳에는 50%% 확률로 %d 턴 동안 벽이 생성되어 이동을 막고, 주변의 적들에게 %0.2f 정신 피해, %0.2f 화염 피해를 줍니다.
		피해량과 밀어내기 확률은 정신력의 영향을 받아 증가합니다.]]):
		format(radius, damDesc(self, DamageType.MIND, blast_damage), damDesc(self, DamageType.FIRE, blast_damage), duration, damDesc(self, DamageType.MIND, forge_damage), damDesc(self, DamageType.FIRE, forge_damage))
	end,
}

newTalent{
	name = "Forge Armor",
	kr_name = "갑옷 연마",
	type = {"psionic/dream-forge", 3},
	points = 5,
	require = psi_wil_high3,
	mode = "passive",
	getArmor = function(self, t) return self:combatTalentMindDamage(t, 1, 15) end,
	getDefense = function(self, t) return self:combatTalentMindDamage(t, 1, 15) end,
	getPsiRegen = function(self, t) return self:combatTalentMindDamage(t, 1, 10) end,
	info = function(self, t)
		local armor = t.getArmor(self, t)
		local defense = t.getDefense(self, t)
		local psi = t.getPsiRegen(self, t)
		return([[꿈의 갑옷을 연마하여 방어도가 %d / 회피도가 %d 증가하며, 공격을 받을 때마다 %0.2f 염력을 회복하게 됩니다.
		기술의 효과는 정신력의 영향을 받아 증가합니다.]]):format(armor, defense, psi)
	end,
}

newTalent{
	name = "Dreamforge",
	kr_name = "꿈 속 대장간",
	type = {"psionic/dream-forge", 4},
	points = 5, 
	require = psi_wil_high4,
	cooldown = 12,
	sustain_psi = 50,
	mode = "sustained",
	no_sustain_autoreset = true,
	tactical = { ATTACKAREA = { FIRE = 2, MIND = 2}, DEBUFF = 2, },
	range = 0,
	radius = function(self, t) return math.min(5, 1 + math.ceil(self:getTalentLevel(t)/3)) end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), friendlyfire=false, radius = self:getTalentRadius(t), talent=t}
	end,
	getDamage = function(self, t) return math.ceil(self:combatTalentMindDamage(t, 5, 30)) end,
	getPower = function(self, t) return math.floor(self:combatTalentMindDamage(t, 5, 25)) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 1.5, 3.5)) end,
	getChance = function(self, t) return self:combatTalentLimit(t, 100, 5, 25) end, --Limit < 100%
	getFailChance = function(self, t) return self:combatLimit(self:combatTalentMindDamage(t, 5, 25), 67, 0, 0, 16.34, 16.34) end, -- Limit to <67%
	
	doForgeStrike = function(self, t, p)
		-- If we moved reset the forge
		if self.x ~= p.x or self.y ~= p.y or p.new then
			p.x = self.x; p.y=self.y; p.radius=0; p.damage=0; p.power=0; p.new = nil;
		-- Otherwise we strike the forge
		elseif not self.resting then
			local max_radius = self:getTalentRadius(t)
			local max_damage = t.getDamage(self, t)
			local power = t.getPower(self, t)
			p.radius = math.min(p.radius + 1, max_radius)

			if p.damage < max_damage then
				p.radius = math.min(p.radius + 1, max_radius)
				p.damage = math.min(max_damage/4 + p.damage, max_damage)
				game.logSeen(self, "#GOLD#%s 꿈의 연마를 시작합니다!", (self.kr_name or self.name):capitalize():addJosa("가"))
			elseif p.power == 0 then
				p.power = power
				game.logSeen(self, "#GOLD#%s 꿈을 깨뜨렸습니다!", (self.kr_name or self.name):capitalize():addJosa("가"))
				game:playSoundNear(self, "talents/lightning_loud")
			end
			local tg = {type="ball", range=self:getTalentRange(t), friendlyfire=false, radius=p.radius, talent=t}
			-- Spell failure handled under "DREAMFORGE" damage type in data\damage_types.lua and transferred to "BROKEN_DREAM" effect in data\timed_effects\mental.lua
			self:project(tg, self.x, self.y, engine.DamageType.DREAMFORGE, {dam=self:combatMindCrit(p.damage), power=p.power, fail=t.getFailChance(self,t), dur=p.dur, chance=p.chance, do_particles=true })
		end
	end,
	activate = function(self, t)
		local ret ={
			x = self.x, y=self.y, radius=0, damage=0, power=0, new = true, dur=t.getDuration(self, t), chance=t.getChance(self, t)
		}
		game:playSoundNear(self, "talents/devouringflame")
		return ret
	end,
	deactivate = function(self, t, p)
		return true	
	end,
	info = function(self, t)
		local radius = self:getTalentRadius(t)
		local damage = t.getDamage(self, t)/2
		local power = t.getPower(self, t)
		local duration = t.getDuration(self, t)
		local chance = t.getChance(self, t)
		local fail = t.getFailChance(self,t)
		return ([[머리 속에 그리던 대장간의 풍경이 현실 세계에 영향을 미치게 됩니다. 시전자가 이동하지 않은 매 턴마다, 꿈의 연마를 통해 주변의 적들에게 정신 피해와 화염 피해를 줍니다.
		이 효과는 5 턴에 걸쳐 완성되며, 주변 %d 칸 반경에 영향을 줄 때까지 지속되고 최대 %0.2f 정신 피해, %0.2f 화염 피해를 줍니다.
		효과가 완성되면 스스로 꿈을 깨뜨려, %d 턴 동안 주변에 있는 적들의 정신 내성을 %d 낮추고 %d%% 확률로 주문 시전을 실패하게 만듭니다.
		꿈을 깨뜨릴 때 %d%% 확률로 적들에게 정신잠금 효과를 줍니다.
		피해량과 꿈을 깨뜨릴 때의 효과는 정신력의 영향을 받아 증가합니다.]]):
		format(radius, damDesc(self, DamageType.MIND, damage), damDesc(self, DamageType.FIRE, damage), duration, power, fail, chance) --@@ 변수 순서 조정
	end,
}
