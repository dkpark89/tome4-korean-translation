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

uberTalent{
	name = "Draconic Will",
	kr_display_name = "용인의 의지",
	cooldown = 15,
	no_energy = true,
	requires_target = true,
	range = 10,
	tactical = { BUFF = 2 },
	action = function(self, t)
		self:setEffect(self.EFF_DRACONIC_WILL, 5, {})
		return true
	end,
	require = { special={desc="용인들의 세계와 가까워질 것", fct=function(self) return game.state.birth.ignore_prodigies_special_reqs or (self:attr("drake_touched") and self:attr("drake_touched") >= 2) end} },
	info = function(self, t)
		return ([[용인의 의지를 이어받아, 부정적인 상태효과를 저항해냅니다.
		5 턴 동안, 부정적인 상태효과에 걸리지 않게 됩니다.]])
		:format()
	end,
}

uberTalent{
	name = "Meteoric Crash",
	kr_display_name = "유성 충돌",
	mode = "passive",
	cooldown = 15,
	getDamage = function(self, t) return math.max(100 + self:combatSpellpower() * 5, 100 + self:combatMindpower() * 5) end,
	require = { special={desc="유성 충돌을 목격했을 것", fct=function(self) return game.state.birth.ignore_prodigies_special_reqs or self:attr("meteoric_crash") end} },
	trigger = function(self, t, target)
		self:startTalentCooldown(t)
		local terrains = t.terrains or mod.class.Grid:loadList("/data/general/grids/lava.lua")
		t.terrains = terrains -- cache

		local meteor = function(src, x, y, dam)
			game.level.map:particleEmitter(x, y, 10, "meteor", {x=x, y=y}).on_remove = function(self)
				local x, y = self.args.x, self.args.y
				game.level.map:particleEmitter(x, y, 10, "ball_fire", {radius=2})
				game:playSoundNear(game.player, "talents/fireflash")

				for i = x-1, x+1 do for j = y-1, y+1 do
					local oe = game.level.map(i, j, Map.TERRAIN)
					if oe and not oe:attr("temporary") and
					(core.fov.distance(x, y, i, j) < 1 or rng.percent(40)) and (game.level.map:checkEntity(i, j, engine.Map.TERRAIN, "dig") or game.level.map:checkEntity(i, j, engine.Map.TERRAIN, "grow")) then
						local g = terrains.LAVA_FLOOR:clone()
						g:resolve() g:resolve(nil, true)
						g.temporary = 8
						g.x = i g.y = j
						g.canAct = false
						g.energy = { value = 0, mod = 1 }
						g.old_feat = game.level.map(i, j, engine.Map.TERRAIN)
						g.useEnergy = mod.class.Trap.useEnergy
						g.act = function(self)
							self:useEnergy()
							self.temporary = self.temporary - 1
							if self.temporary <= 0 then
								game.level.map(self.x, self.y, engine.Map.TERRAIN, self.old_feat)
								game.level:removeEntity(self)
								game.nicer_tiles:updateAround(game.level, self.x, self.y)
							end
						end
						game.zone:addEntity(game.level, g, "terrain", i, j)
						game.level:addEntity(g)
					end
				end end
				for i = x-1, x+1 do for j = y-1, y+1 do
					game.nicer_tiles:updateAround(game.level, i, j)
				end end

				src:project({type="ball", radius=2, selffire=false}, x, y, engine.DamageType.FIRE, dam/2)
				src:project({type="ball", radius=2, selffire=false}, x, y, engine.DamageType.PHYSICAL, dam/2)
				src:project({type="ball", radius=2, selffile=false}, x, y, function(px, py)
					local target = game.level.map(px, py, Map.ACTOR)
					if target then
						if target:canBe("stun") then
							target:setEffect(target.EFF_STUNNED, 3, {apply_power=src:combatSpellpower()})
						else
							game.logSeen(target, "%s 기절하지 않았습니다!", (target.kr_display_name or target.name):capitalize():addJosa("가"))
						end
					end
				end)
				game:getPlayer(true):attr("meteoric_crash", 1)
			end
		end

		meteor(self, target.x, target.y, t.getDamage(self, t))

		return true
	end,
	info = function(self, t)
		local dam = t.getDamage(self, t)/2
		return ([[공격적인 마법이나 정신 공격을 할 때, 의지의 힘으로 운석을 불러낼 수 있게 됩니다.
		운석이 떨어진 곳은 8 턴 동안 용암 지형이 되며, %0.2f 물리 피해와 %0.2f 화염 피해를 주게 됩니다.
		운석에 맞은 적은 3 턴 동안 기절하게 되며, 피해량은 주문력이나 정신력의 영향을 받아 증가합니다.]])
		:format(damDesc(self, DamageType.FIRE, dam), damDesc(self, DamageType.PHYSICAL, dam))
	end,
}

uberTalent{
	name = "Garkul's Revenge",
	kr_display_name = "가르쿨의 복수",
	mode = "passive",
	on_learn = function(self, t)
		self.inc_damage_actor_type = self.inc_damage_actor_type or {}
		self.inc_damage_actor_type.construct = (self.inc_damage_actor_type.construct or 0) + 1000
		self.inc_damage_actor_type.humanoid = (self.inc_damage_actor_type.humanoid or 0) + 20
	end,
	on_unlearn = function(self, t)
		self.inc_damage_actor_type.construct = (self.inc_damage_actor_type.construct or 0) - 1000
		self.inc_damage_actor_type.humanoid = (self.inc_damage_actor_type.humanoid or 0) - 20
	end,
	require = { special={desc="가르쿨과 관련된 물건 2 가지를 모으고, 가르쿨의 일생에 대해 알게 될 것", fct=function(self)
		local o1 = self:findInAllInventoriesBy("define_as", "SET_GARKUL_TEETH")
		local o2 = self:findInAllInventoriesBy("define_as", "HELM_OF_GARKUL")
		return o1 and o2 and o1.wielded and o2.wielded and (game.state.birth.ignore_prodigies_special_reqs or (
			game.party:knownLore("garkul-history-1") and
			game.party:knownLore("garkul-history-2") and
			game.party:knownLore("garkul-history-3") and
			game.party:knownLore("garkul-history-4") and
			game.party:knownLore("garkul-history-5")
			))
	end} },
	info = function(self, t)
		return ([[가르쿨의 의지가 함께합니다. 구조물에 1000%% 추가 피해를, 인간형 적에게 20%% 추가 피해를 주게 됩니다.]])
		:format()
	end,
}

uberTalent{
	name = "Hidden Resources",
	kr_display_name = "숨겨진 원천력",
	cooldown = 15,
	no_energy = true,
	tactical = { BUFF = 2 },
	action = function(self, t)
		self:setEffect(self.EFF_HIDDEN_RESOURCES, 5, {})
		return true
	end,
	require = { special={desc="죽다 살아날 것 (생명력 1 이하인 상황에서 적을 죽일 것)", fct=function(self) return self:attr("barely_survived") end} },
	info = function(self, t)
		return ([[호랑이 굴에 들어가도 정신만 차리면 산다고 하였습니다. 정신을 집중하여, 5 턴 동안 원천력 소모 없이 기술을 사용할 수 있게 됩니다.]])
		:format()
	end,
}


uberTalent{
	name = "Lucky Day",
	kr_display_name = "행운의 날",
	mode = "passive",
	require = { special={desc="운이 좋은 상태일 것 (다른 수단으로 5 이상의 행운을 올렸을 것)", fct=function(self) return self:getLck() >= 55 end} },
	on_learn = function(self, t)
		self.inc_stats[self.STAT_LCK] = (self.inc_stats[self.STAT_LCK] or 0) + 40
		self:onStatChange(self.STAT_LCK, 40)
	end,
	on_unlearn = function(self, t)
		self.inc_stats[self.STAT_LCK] = (self.inc_stats[self.STAT_LCK] or 0) - 40
		self:onStatChange(self.STAT_LCK, -40)
	end,
	info = function(self, t)
		return ([[언제나 행운이 함께합니다! 행운이 40 증가합니다.]])
		:format()
	end,
}

uberTalent{
	name = "Unbreakable Will",
	kr_display_name = "불굴의 의지",
	mode = "passive",
	cooldown = 7,
	trigger = function(self, t)
		self:startTalentCooldown(t)
		game.logSeen(self, "#LIGHT_BLUE#%s 꺾을 수 없는 의지로 정신 상태효과에 걸리지 않았습니다!", (self.kr_display_name or self.name):capitalize():addJosa("가"))
		return true
	end,
	info = function(self, t)
		return ([[극한의 의지로, 정신 상태효과를 무시할 수 있게 됩니다.
		주의 : 한 가지 정신 상태효과를 무시한 뒤에는, 7 턴 동안 정신 상태효과를 무시할 수 없게 됩니다.]])
		:format()
	end,
}

uberTalent{
	name = "Spell Feedback",
	kr_display_name = "주문 반작용",
	mode = "passive",
	cooldown = 3,
	require = { special={desc="마법을 증오할 것", fct=function(self) return self:knowTalentType("wild-gift/antimagic") end} },
	trigger = function(self, t, target, source_t)
		self:startTalentCooldown(t)
		game.logSeen(self, "#LIGHT_BLUE#%s %s에게 주문 시전에 대한 징벌을 내립니다!", (self.kr_display_name or self.name):capitalize():addJosa("가"), (target.kr_display_name or target.name) )
		DamageType:get(DamageType.MIND).projector(self, target.x, target.y, DamageType.MIND, 20 + self:getWil() * 2)

		local dur = target:getTalentCooldown(source_t)
		if dur and dur > 0 then
			target:setEffect(target.EFF_SPELL_FEEDBACK, dur, {power=35})
		end
		return true
	end,
	info = function(self, t)
		return ([[저 정신나간 마법사들의 공격 하에서, 꺾이지 않는 의지를 보여줍니다.
		마법 피해를 입을 때마다, %0.2f 정신 피해를 되돌려줄 수 있게 됩니다.
		또한 자신을 공격한 마법사는, 방금 전에 시전한 마법의 재사용 대기시간 동안 35%% 확률로 주문 시전에 실패하게 됩니다.]])
		:format(damDesc(self, DamageType.MIND, 20 + self:getWil() * 2))
	end,
}

uberTalent{
	name = "Mental Tyranny",
	kr_display_name = "정신적 압제",
	mode = "sustained",
	require = { },
	cooldown = 20,
	tactical = { BUFF = 2 },
	require = { special={desc="정신 속성으로 적에게 총 50,000 이상의 피해를 가할 것", fct=function(self) return 
		self.damage_log and (
			(self.damage_log[DamageType.MIND] and self.damage_log[DamageType.MIND] >= 50000)
		)
	end} },
	activate = function(self, t)
		game:playSoundNear(self, "talents/distortion")
		return {
			converttype = self:addTemporaryValue("all_damage_convert", DamageType.MIND),
			convertamount = self:addTemporaryValue("all_damage_convert_percent", 100),
			dam = self:addTemporaryValue("inc_damage", {[DamageType.MIND] = 10}),
			resist = self:addTemporaryValue("resists_pen", {[DamageType.MIND] = 30}),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("all_damage_convert", p.converttype)
		self:removeTemporaryValue("all_damage_convert_percent", p.convertamount)
		self:removeTemporaryValue("inc_damage", p.dam)
		self:removeTemporaryValue("resists_pen", p.resist)
		return true
	end,
	info = function(self, t)
		return ([[강철의 의지를 통해, 물리적 법칙을 초월합니다.
		기술이 유지되는 동안, 자신이 가하는 모든 피해가 정신 피해로 전환됩니다.
		또한 적의 정신 저항을 30%% 무시할 수 있게 되며, 자신이 가하는 정신 피해량이 10%% 증가하게 됩니다.]]):
		format()
	end,
}
