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

local newInscription = function(t)
	-- Warning, up that if more than 5 inscriptions are ever allowed
	for i = 1, 6 do
		local tt = table.clone(t)
		tt.short_name = tt.name:upper():gsub("[ ]", "_").."_"..i
		tt.display_name = function(self, t)
			local data = self:getInscriptionData(t.short_name)
			if data.item_name then
				local n = tstring{t.name, " ["}
				n:merge(data.item_name)
				n:add("]")
				return n
			else
				return t.name
			end
		end
		tt.kr_display_name_f = function(self, t)
			local data = self:getInscriptionData(t.short_name)
			if data.item_name then
				local n = tstring{(t.kr_display_name or t.name), " ["}
				n:merge(data.item_name)
				n:add("]")
				return n
			else
				return (t.kr_display_name or t.name)
			end
		end
		if tt.type[1] == "inscriptions/infusions" then tt.auto_use_check = function(self, t) return not self:hasEffect(self.EFF_INFUSION_COOLDOWN) end
		elseif tt.type[1] == "inscriptions/runes" then tt.auto_use_check = function(self, t) return not self:hasEffect(self.EFF_RUNE_COOLDOWN) end
		elseif tt.type[1] == "inscriptions/taints" then tt.auto_use_check = function(self, t) return not self:hasEffect(self.EFF_TAINT_COOLDOWN) end
		end
		tt.auto_use_warning = "- 포화 상태가 아닐 경우에만, 자동으로 사용합니다"
		tt.cooldown = function(self, t)
			local data = self:getInscriptionData(t.short_name)
			return data.cooldown
		end
		tt.old_info = tt.info
		tt.info = function(self, t)
			local ret = t.old_info(self, t)
			local data = self:getInscriptionData(t.short_name)
			if data.use_stat and data.use_stat_mod then
				ret = ret..("\n 효과는 %s 능력치의 영향을 받아 증가합니다."):format(self.stats_def[data.use_stat].name:krStat())
			end
			return ret
		end
		if not tt.image then
			tt.image = "talents/"..(t.short_name or t.name):lower():gsub("[^a-z0-9_]", "_")..".png"
		end
		tt.no_unlearn_last = true
		tt.is_inscription = true
		newTalent(tt)
	end
end

-----------------------------------------------------------------------
-- Infusions
-----------------------------------------------------------------------
newInscription{
	name = "Infusion: Regeneration",
	kr_display_name = "주입 : 재생",
	type = {"inscriptions/infusions", 1},
	points = 1,
	tactical = { HEAL = 2 },
	on_pre_use = function(self, t) return not self:hasEffect(self.EFF_REGENERATION) end,
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		self:setEffect(self.EFF_REGENERATION, data.dur, {power=(data.heal + data.inc_stat) / data.dur})
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[주입된 힘을 사용하여, %d 턴 동안 총 %d 생명력을 회복합니다.]]):format(data.dur, data.heal + data.inc_stat)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[%d 턴 동안 총 %d 생명력 회복]]):format(data.dur, data.heal + data.inc_stat)
	end,
}

newInscription{
	name = "Infusion: Healing",
	kr_display_name = "주입 : 치료",
	type = {"inscriptions/infusions", 1},
	points = 1,
	tactical = { HEAL = 2 },
	is_heal = true,
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		self:attr("allow_on_heal", 1)
		self:heal(data.heal + data.inc_stat)
		self:attr("allow_on_heal", -1)
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[주입된 힘을 사용하여, %d 생명력을 즉시 회복합니다.]]):format(data.heal + data.inc_stat)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[생명력 %d 회복]]):format(data.heal + data.inc_stat)
	end,
}

newInscription{
	name = "Infusion: Wild",
	kr_display_name = "주입 : 자연",
	type = {"inscriptions/infusions", 1},
	points = 1,
	no_energy = true,
	tactical = {
		DEFEND = 3,
		CURE = function(self, t, target)
			local nb = 0
			local data = self:getInscriptionData(t.short_name)
			for eff_id, p in pairs(self.tmp) do
				local e = self.tempeffect_def[eff_id]
				if data.what[e.type] and e.status == "detrimental" then
					nb = nb + 1
				end
			end
			return nb
		end
	},
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)

		local target = self
		local effs = {}
		local force = {}
		local known = false

		-- Go through all temporary effects
		for eff_id, p in pairs(target.tmp) do
			local e = target.tempeffect_def[eff_id]
			if data.what[e.type] and e.status == "detrimental" and e.subtype["cross tier"] then
				force[#force+1] = {"effect", eff_id}
			elseif data.what[e.type] and e.status == "detrimental" then
				effs[#effs+1] = {"effect", eff_id}
			end
		end

		-- Cross tier effects are always removed and not part of the random game, otherwise it is a huge nerf to wild infusion
		for i = 1, #force do
			local eff = force[i]
			if eff[1] == "effect" then
				target:removeEffect(eff[2])
				known = true
			end
		end

		for i = 1, 1 do
			if #effs == 0 then break end
			local eff = rng.tableRemove(effs)

			if eff[1] == "effect" then
				target:removeEffect(eff[2])
				known = true
			end
		end
		if known then
			game.logSeen(self, "%s 치료되었습니다!", (self.kr_display_name or self.name):capitalize():addJosa("가"))
		end
		self:setEffect(self.EFF_PAIN_SUPPRESSION, data.dur, {power=data.power + data.inc_stat})
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local what = table.concat(table.keys(data.what), ", ")
		return ([[주입된 힘을 사용하여 나쁜 %s 상태효과를 제거하고, %d 턴 동안 시전자가 받는 피해량이 %d%% 감소합니다.]]):format(what:krWildType(), data.dur, data.power+data.inc_stat) --@@ 변수 순서 조정
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local what = table.concat(table.keys(data.what), ", ")
		return ([[피해량 %d%% 감소, %s 상태효과 치료]]):format(data.power + data.inc_stat, what)
	end,
}

newInscription{
	name = "Infusion: Movement",
	kr_display_name = "주입 : 이동",
	type = {"inscriptions/infusions", 1},
	points = 1,
	no_energy = true,
	tactical = { DEFEND = 1 },
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		self:setEffect(self.EFF_FREE_ACTION, data.dur, {power=1})
		game:onTickEnd(function() self:setEffect(self.EFF_WILD_SPEED, 1, {power=data.speed + data.inc_stat}) end)
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[주입된 힘을 사용하여, 이동 속도가 %d%% 증가합니다.
		이동 속도가 굉장히 빨라지기 때문에, 상대적으로 게임의 전체적인 턴은 느리게 진행됩니다.
		이 효과는 게임의 전체적인 턴으로 1 턴이 지나거나, 이동을 제외한 다른 행동을 하면 사라집니다.
		그리고, %d 턴 동안 기절, 혼절, 속박 상태효과에 걸리지 않게 됩니다.]]):format(data.speed + data.inc_stat, data.dur)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[%d%% 이동 속도, 상태효과 면역 %d 턴]]):format(data.speed + data.inc_stat, data.dur)
	end,
}

newInscription{
	name = "Infusion: Sun",
	kr_display_name = "주입 : 태양",
	type = {"inscriptions/infusions", 1},
	points = 1,
	tactical = { ATTACKAREA = 1, DISABLE = { blind = 2 } },
	range = 0,
	radius = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return data.range
	end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), selffire=false, radius=self:getTalentRadius(t), talent=t}
	end,
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, engine.DamageType.BLINDCUSTOMMIND, {power=data.power + data.inc_stat, turns=data.turns})
		self:project(tg, self.x, self.y, engine.DamageType.BREAK_STEALTH, {power=(data.power + data.inc_stat)/2, turns=data.turns})
		tg.selffire = true
		self:project(tg, self.x, self.y, engine.DamageType.LITE, data.power >= 19 and 100 or 1)
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[주입된 힘을 사용하여, 주변 %d 칸을 밝게 비춥니다. 빛에 의해 은신 중인 적의 은신 수치가 %d 감소하여, 은신이 해제될 수도 있습니다. %s
		빛에 노출된 적들은 %d 턴 동안 실명 상태효과에 걸립니다. (실명 수치 +%d)]]):
		format(data.range, (data.power + data.inc_stat)/2, data.power >= 19 and "\n이 강렬한 빛은 마법적인 어둠마저 없애버릴 수 있습니다." or "", data.turns, data.power + data.inc_stat)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[범위 %d, 위력 %d, %d 턴 유지%s]]):format(data.range, data.power + data.inc_stat, data.turns, data.power >= 19 and ",마법적 어둠 제거" or "")
	end,
}

newInscription{
	name = "Infusion: Heroism",
	kr_display_name = "주입 : 영웅",
	type = {"inscriptions/infusions", 1},
	points = 1,
	no_energy = true,
	tactical = { BUFF = 2 },
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		self:setEffect(self.EFF_HEROISM, data.dur, {power=data.power + data.inc_stat, die_at=data.die_at + data.inc_stat * 30})
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[주입된 힘을 사용하여, 시전자의 세 가지 주요 능력치 (가장 높은 능력치) 를 %d 턴 동안 %d 만큼 올립니다.
		영웅 효과가 지속되는 동안에는 생명력이 0 이 되도 죽지 않으며, -%d 생명력이 되어야 사망합니다. 
		하지만 생명력이 0 이하로 떨어지면 남은 생명력을 알 수 없게 되며, 영웅 효과가 끝나기 전에 반드시 회복을 해야 합니다.]]):format(data.power + data.inc_stat, data.dur, data.die_at + data.inc_stat * 30)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[능력치 +%d, %d 턴 유지, 생명력 하한 -%d]]):format(data.power + data.inc_stat, data.dur, data.die_at + data.inc_stat * 30)
	end,
}

newInscription{
	name = "Infusion: Insidious Poison",
	kr_display_name = "주입 : 잠식형 독",
	type = {"inscriptions/infusions", 1},
	points = 1,
	tactical = { ATTACK = { NATURE = 1 }, DISABLE=1 },
	requires_target = true,
	range = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return data.range
	end,
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local tg = {type="bolt", range=self:getTalentRange(t), talent=t, display={particle="bolt_slime", trail="slimetrail"}}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:projectile(tg, x, y, DamageType.INSIDIOUS_POISON, {dam=data.power + data.inc_stat, dur=7, heal_factor=data.heal_factor}, {type="slime"})
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[주입된 힘을 사용하여, 독을 뱉습니다. 독에 맞은 대상은 7 턴 동안 총 %0.2f 자연 피해를 입으며, 회복 효율이 %d%% 감소합니다.]]):format(damDesc(self, DamageType.COLD, data.power + data.inc_stat) / 7, data.heal_factor)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[%d 자연 피해, 회복 효율 %d%% 감소]]):format(damDesc(self, DamageType.NATURE, data.power + data.inc_stat) / 7, data.heal_factor)
	end,
}

newInscription{
	name = "Infusion: Wild Growth",
	kr_display_name = "주입 : 야생",
	type = {"inscriptions/infusions", 1},
	points = 1,
	tactical = { ATTACKAREA = { PHYSICAL = 1, NATURE = 1 }, DISABLE = 3 },
	range = 0,
	radius = 5,
	direct_hit = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	getDamage = function(self, t) return 10 + self:combatMindpower() * 0.4 end,
	action = function(self, t)
		local dam = t.getDamage(self, t)
		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, function(tx, ty)
			DamageType:get(DamageType.ENTANGLE).projector(self, tx, ty, DamageType.ENTANGLE, dam)
		end)
		game:playSoundNear(self, "talents/earth")
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local damage = t.getDamage(self, t)
		return ([[땅에서 덩굴이 솟아나 %d 턴 동안 주변 %d 칸 반경에 있는 적들의 발을 묶고, 매 턴마다 %0.2f 물리 피해, %0.2f 자연 피해를 줍니다.]]):
		format(self:getTalentRadius(t), data.dur, damDesc(self, DamageType.PHYSICAL, damage)/3, damDesc(self, DamageType.NATURE, 2*damage)/3)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[주변 %d 칸 속박, %d 턴 유지]]):format(self:getTalentRadius(t), data.dur)
	end,
}

-----------------------------------------------------------------------
-- Runes
-----------------------------------------------------------------------
newInscription{
	name = "Rune: Phase Door",
	kr_display_name = "룬 : 근거리 순간이동",
	type = {"inscriptions/runes", 1},
	points = 1,
	is_spell = true,
	is_teleport = true,
	tactical = { ESCAPE = 2 },
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		game.level.map:particleEmitter(self.x, self.y, 1, "teleport")
		self:teleportRandom(self.x, self.y, data.range + data.inc_stat)
		game.level.map:particleEmitter(self.x, self.y, 1, "teleport")
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[룬을 발동하여, %d 칸 주변의 무작위한 곳으로 순간이동합니다.]]):format(data.range + data.inc_stat)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[주변 %d 칸 무작위 순간이동]]):format(data.range + data.inc_stat)
	end,
}

newInscription{
	name = "Rune: Controlled Phase Door",
	kr_display_name = "룬 : 제어된 근거리 순간이동",
	type = {"inscriptions/runes", 1},
	points = 1,
	is_spell = true,
	is_teleport = true,
	tactical = { CLOSEIN = 2 },
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local tg = {type="ball", nolock=true, pass_terrain=true, nowarning=true, range=data.range + data.inc_stat, radius=3, requires_knowledge=false}
		x, y = self:getTarget(tg)
		if not x then return nil end
		-- Target code does not restrict the target coordinates to the range, it lets the project function do it
		-- but we cant ...
		local _ _, x, y = self:canProject(tg, x, y)

		-- Check LOS
		local rad = 3
		if not self:hasLOS(x, y) and rng.percent(35 + (game.level.map.attrs(self.x, self.y, "control_teleport_fizzle") or 0)) then
			game.logPlayer(self, "순간이동 제어에 실패하여, 무작위한 곳으로 이동됩니다!")
			x, y = self.x, self.y
			rad = tg.range
		end

		game.level.map:particleEmitter(self.x, self.y, 1, "teleport")
		self:teleportRandom(x, y, rad)
		game.level.map:particleEmitter(self.x, self.y, 1, "teleport")
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[룬을 발동하여, %d 칸 주변의 원하는 곳에 순간이동합니다.]]):format(data.range + data.inc_stat)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[주변 %d 칸 제어된 순간이동]]):format(data.range + data.inc_stat)
	end,
}

newInscription{
	name = "Rune: Teleportation",
	kr_display_name = "룬 : 순간이동",
	type = {"inscriptions/runes", 1},
	points = 1,
	is_spell = true,
	is_teleport = true,
	tactical = { ESCAPE = 3 },
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		game.level.map:particleEmitter(self.x, self.y, 1, "teleport")
		self:teleportRandom(self.x, self.y, data.range + data.inc_stat, 15)
		game.level.map:particleEmitter(self.x, self.y, 1, "teleport")
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[룬을 발동하여, 최소 %d 칸 이상의 무작위한 곳으로 순간이동합니다.]]):format(data.range + data.inc_stat)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[최소 %d 칸 이상 무작위 순간이동]]):format(data.range + data.inc_stat)
	end,
}

newInscription{
	name = "Rune: Shielding",
	kr_display_name = "룬 : 보호막",
	type = {"inscriptions/runes", 1},
	points = 1,
	is_spell = true,
	allow_autocast = true,
	no_energy = true,
	tactical = { DEFEND = 2 },
	on_pre_use = function(self, t)
		return not self:hasEffect(self.EFF_DAMAGE_SHIELD)
	end,
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		self:setEffect(self.EFF_DAMAGE_SHIELD, data.dur, {power=data.power + data.inc_stat})
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[룬을 발동하여, %d 턴 동안 최대 %d 피해량을 막아주는 보호막을 만들어냅니다.]]):format(data.dur, data.power + data.inc_stat)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[%d 피해 흡수, %d 턴 유지]]):format(data.power + data.inc_stat, data.dur)
	end,
}

newInscription{
	name = "Rune: Reflection Shield", image = "talents/rune__shielding.png",
	kr_display_name = "룬 : 반사 보호막",
	type = {"inscriptions/runes", 1},
	points = 1,
	is_spell = true,
	allow_autocast = true,
	no_energy = true,
	tactical = { DEFEND = 2 },
	on_pre_use = function(self, t)
		return not self:hasEffect(self.EFF_DAMAGE_SHIELD)
	end,
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		self:setEffect(self.EFF_DAMAGE_SHIELD, 5, {power=100+1.5*self:getMag(), reflect=100})
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[룬을 발동하여, %d 턴 동안 최대 %d 피해량을 반사하는 보호막을 만들어냅니다.
		반사량은 마법 능력치의 영향을 받아 증가합니다.]]):format(5, 100+1.5*self:getMag())
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[%d 피해 반사, %d 턴 유지]]):format(100+1.5*self:getMag(), 5)
	end,
}

newInscription{
	name = "Rune: Invisibility",
	kr_display_name = "룬 : 투명화",
	type = {"inscriptions/runes", 1},
	points = 1,
	is_spell = true,
	tactical = { DEFEND = 3, ESCAPE = 2 },
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		self:setEffect(self.EFF_INVISIBILITY, data.dur, {power=data.power + data.inc_stat, penalty=0.4, regen=true})
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[룬을 발동하여, %d 턴 동안 투명해집니다. (투명 수치 +%d)
		투명해지면 현실에서의 존재감이 떨어져 적에게 원래 피해량의 40%% 밖에 줄 수 없게 되며, 생명력 재생이나 회복 또한 불가능해집니다.]]):format(data.dur, data.power + data.inc_stat)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[투명화 (투명 수치 +%d), %d 턴 유지]]):format(data.power + data.inc_stat, data.dur)
	end,
}

newInscription{
	name = "Rune: Speed",
	kr_display_name = "룬 : 가속",
	type = {"inscriptions/runes", 1},
	points = 1,
	is_spell = true,
	no_energy = true,
	tactical = { BUFF = 4 },
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		self:setEffect(self.EFF_SPEED, data.dur, {power=(data.power + data.inc_stat) / 100})
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[룬을 발동하여, %d 턴 동안 전체 속도를 %d%% 증가시킵니다.]]):format(data.dur, data.power + data.inc_stat)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[전체 속도 +%d%%, %d 턴 유지]]):format(data.power + data.inc_stat, data.dur)
	end,
}

newInscription{
	name = "Rune: Vision",
	kr_display_name = "룬 : 시야",
	type = {"inscriptions/runes", 1},
	points = 1,
	is_spell = true,
	no_npc_use = true,
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		self:magicMap(data.range, self.x, self.y, function(x, y)
			local g = game.level.map(x, y, Map.TERRAIN)
			if g and (g.always_remember or g:check("block_move")) then
				for _, coord in pairs(util.adjacentCoords(x, y)) do
					local g2 = game.level.map(coord[1], coord[2], Map.TERRAIN)
					if g2 and not g2:check("block_move") then return true end
				end
			end
		end)
		self:setEffect(self.EFF_SENSE_HIDDEN, data.dur, {power=data.power + data.inc_stat})
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[룬을 발동하여, 주변 %d 칸 반경의 시야를 %d 턴 동안 밝힙니다. 투명한 적과 은신한 적도 발견할 수 있게 됩니다. (투명, 은신 감지력 +%d)]]):
		format(data.range, data.dur, data.power + data.inc_stat) --@@ 변수 순서 조정
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[주변 %d 칸 시야 확보 및 탐지]]):format(data.range)
	end,
}

local function attack_rune(self, btid)
	for tid, lev in pairs(self.talents) do
		if tid ~= btid and self.talents_def[tid].is_attack_rune and not self.talents_cd[tid] then
			self.talents_cd[tid] = 1
		end
	end
end

newInscription{
	name = "Rune: Heat Beam",
	kr_display_name = "룬 : 열기 발산",
	type = {"inscriptions/runes", 1},
	points = 1,
	is_attack_rune = true,
	no_energy = true,
	is_spell = true,
	tactical = { ATTACK = { FIRE = 1 } },
	requires_target = true,
	direct_hit = true,
	range = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return data.range
	end,
	target = function(self, t)
		return {type="beam", range=self:getTalentRange(t), talent=t}
	end,
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.FIREBURN, {dur=5, initial=0, dam=data.power + data.inc_stat})
		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "flamebeam", {tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/fire")
		attack_rune(self, t.id)
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[룬을 발동하여, 적에게 5 턴 동안 %0.2f 화염 피해를 줍니다.]]):format(damDesc(self, DamageType.FIRE, data.power + data.inc_stat))
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[%d 화염 피해]]):format(damDesc(self, DamageType.FIRE, data.power + data.inc_stat))
	end,
}

newInscription{
	name = "Rune: Frozen Spear",
	kr_display_name = "룬 : 빙결의 창",
	type = {"inscriptions/runes", 1},
	points = 1,
	is_attack_rune = true,
	no_energy = true,
	is_spell = true,
	tactical = { ATTACK = { COLD = 1 }, DISABLE = { stun = 1 } },
	requires_target = true,
	range = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return data.range
	end,
	target = function(self, t)
		return {type="bolt", range=self:getTalentRange(t), talent=t, display={particle="bolt_ice", trail="icetrail"}}
	end,
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.ICE, data.power + data.inc_stat, {type="freeze"})
		game:playSoundNear(self, "talents/ice")
		attack_rune(self, t.id)
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[룬을 발동하여, 적에게 %0.2f 냉기 피해를 줍니다. 대상을 얼릴 확률이 있습니다.]]):format(damDesc(self, DamageType.COLD, data.power + data.inc_stat))
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[%d 냉기 피해]]):format(damDesc(self, DamageType.COLD, data.power + data.inc_stat))
	end,
}

newInscription{
	name = "Rune: Acid Wave",
	kr_display_name = "룬 : 산성 파동",
	type = {"inscriptions/runes", 1},
	points = 1,
	is_attack_rune = true,
	no_energy = true,
	is_spell = true,
	tactical = { ATTACKAREA = { ACID = 1 } },
	requires_target = true,
	direct_hit = true,
	range = 0,
	radius = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return data.range
	end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, DamageType.ACID, data.power + data.inc_stat)
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "ball_acid", {radius=tg.radius})
		game:playSoundNear(self, "talents/slime")
		attack_rune(self, t.id)
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[룬을 발동하여, 주변 %d 칸 반경에 %0.2f 산성 피해를 줍니다.]]):format(self:getTalentRadius(t), damDesc(self, DamageType.ACID, data.power + data.inc_stat))
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[%d 산성 피해]]):format(damDesc(self, DamageType.ACID, data.power + data.inc_stat))
	end,
}

newInscription{
	name = "Rune: Lightning",
	kr_display_name = "룬 : 번개",
	type = {"inscriptions/runes", 1},
	points = 1,
	is_attack_rune = true,
	no_energy = true,
	is_spell = true,
	tactical = { ATTACK = { LIGHTNING = 1 } },
	requires_target = true,
	direct_hit = true,
	range = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return data.range
	end,
	target = function(self, t)
		return {type="beam", range=self:getTalentRange(t), talent=t}
	end,
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local dam = data.power + data.inc_stat
		self:project(tg, x, y, DamageType.LIGHTNING, rng.avg(dam / 3, dam, 3))
		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "lightning", {tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/lightning")
		attack_rune(self, t.id)
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local dam = damDesc(self, DamageType.LIGHTNING, data.power + data.inc_stat)
		return ([[룬을 발동하여, 적에게 %0.2f - %0.2f 전기 피해를 줍니다.]]):format(dam / 3, dam)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[%d 전기 피해]]):format(damDesc(self, DamageType.LIGHTNING, data.power + data.inc_stat))
	end,
}

newInscription{
	name = "Rune: Manasurge",
	kr_display_name = "룬 : 마나의 급류",
	type = {"inscriptions/runes", 1},
	points = 1,
	is_spell = true,
	tactical = { MANA = 1 },
	on_pre_use = function(self, t)
		return self:knowTalent(self.T_MANA_POOL) and not self:hasEffect(self.EFF_MANASURGE)
	end,
	on_learn = function(self, t)
		self.mana_regen_on_rest = (self.mana_regen_on_rest or 0) + 0.5
	end,
	on_unlearn = function(self, t)
		self.mana_regen_on_rest = (self.mana_regen_on_rest or 0) - 0.5
	end,
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		self:incMana((data.mana + data.inc_stat) / 20)
		if self.mana_regen > 0 then
			self:setEffect(self.EFF_MANASURGE, data.dur, {power=self.mana_regen * (data.mana + data.inc_stat) / 100})
		else
			if self.mana_regen < 0 then
				game.logPlayer(self, "시간이 지날수록 마나가 감소하고 있기 때문에, 룬의 효과가 없습니다.")
			else
				game.logPlayer(self, "마나가 존재하지 않기 때문에, 룬의 효과가 없습니다.")
			end
		end
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[룬을 발동하여, 마나를 빠르게 회복합니다. 사용 즉시 %d 마나가 회복되며, 추가로 %d%% 턴에 걸쳐 최대 마나의 %d%% 에 해당하는 마나가 회복됩니다.
		그리고, 휴식하는 동안 매 턴마다 마나가 0.5 씩 회복됩니다.]]):format((data.mana + data.inc_stat) / 20, data.dur, data.mana + data.inc_stat)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[%d 턴 동안 %d%% 마나 회복, 사용 즉시 %d 마나 회복]]):format(data.dur, data.mana + data.inc_stat, (data.mana + data.inc_stat) / 20)
	end,
}

-- This is mostly a copy of Time Skip :P
newInscription{
	name = "Rune of the Rift",
	kr_display_name = "균열의 룬",
	type = {"inscriptions/runes", 1},
	points = 1,
	is_spell = true,
	tactical = { DISABLE = 2, ATTACK = { TEMPORAL = 1 } },
	direct_hit = true,
	reflectable = true,
	requires_target = true,
	range = 4,
	target = function(self, t)
		return {type="hit", range=self:getTalentRange(t), talent=t}
	end,
	getDamage = function(self, t) return 150 + self:getWil() * 4 end,
	getDuration = function(self, t) return 4 end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		local target = game.level.map(x, y, Map.ACTOR)
		if not target then return end

		if target:attr("timetravel_immune") then
			game.logSeen(target, "%s 적용 대상이 아닙니다!", (target.kr_display_name or target.name):capitalize():addJosa("는"))
			return
		end

		local hit = self:checkHit(self:combatSpellpower(), target:combatSpellResist() + (target:attr("continuum_destabilization") or 0))
		if not hit then game.logSeen(target, "%s 저항했습니다!", (target.kr_display_name or target.name):capitalize():addJosa("가")) return true end

		self:project(tg, x, y, DamageType.TEMPORAL, self:spellCrit(t.getDamage(self, t)))
		game.level.map:particleEmitter(x, y, 1, "temporal_thrust")
		game:playSoundNear(self, "talents/arcane")
		self:incParadox(-60)
		if target.dead or target.player then return true end
		target:setEffect(target.EFF_CONTINUUM_DESTABILIZATION, 100, {power=self:combatSpellpower(0.3)})
		
		-- Replace the target with a temporal instability for a few turns
		local oe = game.level.map(target.x, target.y, engine.Map.TERRAIN)
		if not oe or oe:attr("temporary") then return true end
		local e = mod.class.Object.new{
			old_feat = oe, type = oe.type, subtype = oe.subtype,
			name = "temporal instability", image = oe.image, add_mos = {{image="object/temporal_instability.png"}},
			kr_display_name = "불안정한 시공간",
			display = '&', color=colors.LIGHT_BLUE,
			temporary = t.getDuration(self, t),
			canAct = false,
			target = target,
			act = function(self)
				self:useEnergy()
				self.temporary = self.temporary - 1
				-- return the rifted actor
				if self.temporary <= 0 then
					game.level.map(self.target.x, self.target.y, engine.Map.TERRAIN, self.old_feat)
					game.level:removeEntity(self)
					local mx, my = util.findFreeGrid(self.target.x, self.target.y, 20, true, {[engine.Map.ACTOR]=true})
					local old_levelup = self.target.forceLevelup
					self.target.forceLevelup = function() end
					game.zone:addEntity(game.level, self.target, "actor", mx, my)
					self.target.forceLevelup = old_levelup
				end
			end,
			summoner_gain_exp = true, summoner = self,
		}
		
		game.logSeen(target, "%s 미래로 보내졌습니다!", (target.kr_display_name or target.name):capitalize():addJosa("가"))
		game.level:removeEntity(target)
		game.level:addEntity(e)
		game.level.map(x, y, Map.TERRAIN, e)
		game.nicer_tiles:updateAround(game.level, x, y)
		game.level.map:updateMap(x, y)
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		return ([[대상에게 %0.2f 시간 피해를 줍니다. 대상이 죽지 않았다면, 대상을 %d 턴 뒤의 미래로 보내버립니다.
		이 룬을 사용하면 괴리 수치가 60 감소합니다. (괴리 원천력을 사용할 때 한정)
		시공간의 흐름을 지나치게 어지럽히면, 가끔 예상치 못한 결과가 일어날 수도 있습니다.]]):format(damDesc(self, DamageType.TEMPORAL, damage), duration)
	end,
	short_info = function(self, t)
		return ("%0.2f 시간 피해, %d 턴 미래로 이동"):format(t.getDamage(self, t), t.getDuration(self, t))
	end,
}

-----------------------------------------------------------------------
-- Taints
-----------------------------------------------------------------------
newInscription{
	name = "Taint: Devourer",
	kr_display_name = "감염 : 포식자",
	type = {"inscriptions/taints", 1},
	points = 1,
	is_spell = true,
	tactical = { ATTACK = 1, HEAL=1 },
	requires_target = true,
	direct_hit = true,
	no_energy = true,
	range = 5,
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end

			local effs = {}

			-- Go through all spell effects
			for eff_id, p in pairs(target.tmp) do
				local e = target.tempeffect_def[eff_id]
				if e.type == "magical" or e.type == "physical" then
					effs[#effs+1] = {"effect", eff_id}
				end
			end

			-- Go through all sustained spells
			for tid, act in pairs(target.sustain_talents) do
				if act then
					effs[#effs+1] = {"talent", tid}
				end
			end

			local nb = data.effects
			for i = 1, nb do
				if #effs == 0 then break end
				local eff = rng.tableRemove(effs)

				if eff[1] == "effect" then
					target:removeEffect(eff[2])
				else
					target:forceUseTalent(eff[2], {ignore_energy=true})
				end
				self:heal(data.heal + data.inc_stat)
			end

			game.level.map:particleEmitter(px, py, 1, "shadow_zone")
		end)
		game:playSoundNear(self, "talents/fire")
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[감염으로 생긴 능력을 사용하여 적의 상태효과 %d 개를 먹어치우고, 먹어치운 상태효과 1 개마다 %d 생명력을 회복합니다.]]):format(data.effects, data.heal + data.inc_stat)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[%d 상태효과 제거 / %d 생명력 회복]]):format(data.effects, data.heal + data.inc_stat)
	end,
}


newInscription{
	name = "Taint: Telepathy",
	kr_display_name = "감염 : 감지",
	type = {"inscriptions/taints", 1},
	points = 1,
	is_spell = true,
	range = 10,
	action = function(self, t)
		local rad = self:getTalentRange(t)
		self:setEffect(self.EFF_SENSE, 5, {
			range = rad,
			actor = 1,
		})
		self:setEffect(self.EFF_WEAKENED_MIND, 10, {power=20})
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[마음의 장벽을 %d 턴 동안 벗어던져 %d 칸 반경의 적들을 감지할 수 있게 되지만, 10 턴 동안 정신 내성이 %d 감소하게 됩니다.]]):format(data.dur, self:getTalentRange(t), 20)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[주변 %d 칸 적 감지, %d 턴 유지]]):format(self:getTalentRange(t), data.dur)
	end,
}

