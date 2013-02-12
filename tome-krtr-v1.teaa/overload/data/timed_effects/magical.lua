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

local Stats = require "engine.interface.ActorStats"
local Particles = require "engine.Particles"
local Shader = require "engine.Shader"
local Entity = require "engine.Entity"
local Chat = require "engine.Chat"
local Map = require "engine.Map"
local Level = require "engine.Level"

newEffect{
	name = "MANASURGE", image = "talents/rune__manasurge.png",
	desc = "Surging mana",
	kr_display_name = "마나 쇄도",
	long_desc = function(self, eff) return ("마나 쇄도 : 마나 재생 +%0.2f"):format(eff.power) end,
	type = "magical",
	subtype = { arcane=true },
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target#에게 마나가 쇄도하기 시작합니다.", "+마나 쇄도" end,
	on_lose = function(self, err) return "#Target#에게로의 마나 쇄도가 멈췄습니다.", "-마나 쇄도" end,
	on_merge = function(self, old_eff, new_eff)
		-- Merge the mana
		local olddam = old_eff.power * old_eff.dur
		local newdam = new_eff.power * new_eff.dur
		local dur = math.ceil((old_eff.dur + new_eff.dur) / 2)
		old_eff.dur = dur
		old_eff.power = (olddam + newdam) / dur

		self:removeTemporaryValue("mana_regen", old_eff.tmpid)
		old_eff.tmpid = self:addTemporaryValue("mana_regen", old_eff.power)
		return old_eff
	end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("mana_regen", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("mana_regen", eff.tmpid)
	end,
}

newEffect{
	name = "MANA_OVERFLOW", image = "talents/aegis.png",
	desc = "Mana Overflow",
	kr_display_name = "마나 범람",
	long_desc = function(self, eff) return ("마나 범람 : 최대 마나 +%d%%"):format(eff.power) end,
	type = "magical",
	subtype = { arcane=true },
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target#에게 마나가 범람합니다.", "+마나 범람" end,
	on_lose = function(self, err) return "#Target#에게로의 마나 범람이 멈췄습니다.", "-마나 범람" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("max_mana", eff.power * self:getMaxMana() / 100)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("max_mana", eff.tmpid)
	end,
}

newEffect{
	name = "STONED", image = "talents/stone_touch.png",
	desc = "Stoned",
	kr_display_name = "석화",
	long_desc = function(self, eff) return "석화 : 큰 피해를 받으면 확률적으로 부서져 즉사 / 물리 저항 +20% / 화염 저항 +80% / 전기 저항 +50%" end,
	type = "magical",
	subtype = { earth=true, stone=true},
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target1# 석화되었습니다!", "+석화" end,
	on_lose = function(self, err) return "#Target#의 석화가 풀렸습니다.", "-석화" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("stoned", 1)
		eff.resistsid = self:addTemporaryValue("resists", {
			[DamageType.PHYSICAL]=20,
			[DamageType.FIRE]=80,
			[DamageType.LIGHTNING]=50,
		})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("stoned", eff.tmpid)
		self:removeTemporaryValue("resists", eff.resistsid)
	end,
}

newEffect{
	name = "ARCANE_STORM", image = "talents/disruption_shield.png",
	desc = "Arcane Storm",
	kr_display_name = "마법 폭풍",
	long_desc = function(self, eff) return ("마법 폭풍 : 마법 저항 +%d%%"):format(eff.power) end,
	type = "magical",
	subtype = { arcane=true},
	status = "beneficial",
	parameters = {power=50},
	activate = function(self, eff)
		eff.resistsid = self:addTemporaryValue("resists", {
			[DamageType.ARCANE]=eff.power,
		})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("resists", eff.resistsid)
	end,
}

newEffect{
	name = "EARTHEN_BARRIER", image = "talents/earthen_barrier.png",
	desc = "Earthen Barrier",
	kr_display_name = "대지의 보호",
	long_desc = function(self, eff) return ("물리 피해 %d%% 감소"):format(eff.power) end,
	type = "magical",
	subtype = { earth=true },
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target#의 피부가 단단해졌습니다.", "+대지의 보호" end,
	on_lose = function(self, err) return "#Target#의 피부가 보통의 상태로 되돌아 왔습니다.", "-대지의 보호" end,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("stone_skin", 1, {density=4}))
		eff.tmpid = self:addTemporaryValue("resists", {[DamageType.PHYSICAL]=eff.power})
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
		self:removeTemporaryValue("resists", eff.tmpid)
	end,
}

newEffect{
	name = "MOLTEN_SKIN", image = "talents/golem_molten_skin.png",
	desc = "Molten Skin",
	kr_display_name = "용해된 피부",
	long_desc = function(self, eff) return ("화염 피해 %d%% 감소"):format(eff.power) end,
	type = "magical",
	subtype = { fire=true, earth=true },
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target#의 피부가 용해된 용암으로 변했습니다.", "+용해된 피부" end,
	on_lose = function(self, err) return "#Target#의 비푸가 보통의 상태로 되돌아 왔습니다.", "-용해된 피부" end,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("wildfire", 1))
		eff.tmpid = self:addTemporaryValue("resists", {[DamageType.FIRE]=eff.power})
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
		self:removeTemporaryValue("resists", eff.tmpid)
	end,
}

newEffect{
	name = "REFLECTIVE_SKIN", image = "talents/golem_reflective_skin.png",
	desc = "Reflective Skin",
	kr_display_name = "반발성 피부",
	long_desc = function(self, eff) return ("공격자에게 피해의 %d%% 반사"):format(eff.power) end,
	type = "magical",
	subtype = { arcane=true },
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target#의 피부가 어른거립니다.", "+반발성 피부" end,
	on_lose = function(self, err) return "#Target#의 피부가 보통의 상태로 되돌아 왔습니다.", "-반발성 피부" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("reflect_damage", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("reflect_damage", eff.tmpid)
	end,
}

newEffect{
	name = "VIMSENSE", image = "talents/vimsense.png",
	desc = "Vimsense",
	kr_display_name = "원혼의 기운",
	long_desc = function(self, eff) return ("황폐 저항 -%d%%"):format(eff.power) end,
	type = "magical",
	subtype = { blight=true },
	status = "detrimental",
	parameters = { power=10 },
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("resists", {[DamageType.BLIGHT]=-eff.power})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("resists", eff.tmpid)
	end,
}

newEffect{
	name = "INVISIBILITY", image = "effects/invisibility.png",
	desc = "Invisibility",
	kr_display_name = "투명화",
	long_desc = function(self, eff) return ("투명화 부여 (이미 투명화 중일 경우 투명 강도 향상) (투명 강도 : %d)."):format(eff.power) end,
	type = "magical",
	subtype = { phantasm=true },
	status = "beneficial",
	parameters = { power=10, penalty=0, regen=false },
	on_gain = function(self, err) return "#Target1# 시야에서 사라집니다.", "+투명화" end,
	on_lose = function(self, err) return "#Target1# 더이상 투명하지 않습니다.", "-투명화" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("invisible", eff.power)
		eff.penaltyid = self:addTemporaryValue("invisible_damage_penalty", eff.penalty)
		if eff.regen then
			eff.regenid = self:addTemporaryValue("no_life_regen", 1)
			eff.healid = self:addTemporaryValue("no_healing", 1)
		end
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("invisible", eff.tmpid)
		self:removeTemporaryValue("invisible_damage_penalty", eff.penaltyid)
		if eff.regen then
			self:removeTemporaryValue("no_life_regen", eff.regenid)
			self:removeTemporaryValue("no_healing", eff.healid)
		end
		self:resetCanSeeCacheOf()
	end,
}

newEffect{
	name = "SENSE_HIDDEN", image = "talents/keen_senses.png",
	desc = "Sense Hidden",
	kr_display_name = "예리한 감각",
	long_desc = function(self, eff) return ("투명체 및 은신체 감지력 부여 (이미 감지 중일 경우 감지력 향상) (감지력 : %d)."):format(eff.power) end,
	type = "magical",
	subtype = { sense=true },
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target#의 눈에서 빛이 납니다." end,
	on_lose = function(self, err) return "#Target#의 눈이 보통으로 돌아옵니다." end,
	activate = function(self, eff)
		eff.invisid = self:addTemporaryValue("see_invisible", eff.power)
		eff.stealthid = self:addTemporaryValue("see_stealth", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("see_invisible", eff.invisid)
		self:removeTemporaryValue("see_stealth", eff.stealthid)
	end,
}

newEffect{
	name = "BANE_BLINDED", image = "effects/bane_blinded.png",
	desc = "Bane of Blindness",
	kr_display_name = "실명의 맹독",
	long_desc = function(self, eff) return ("실명 : 아무것도 볼 수 없음 / 매 턴마다 어둠 피해 %0.2f"):format(eff.dam) end,
	type = "magical",
	subtype = { bane=true, blind=true },
	status = "detrimental",
	parameters = { dam=10},
	on_gain = function(self, err) return "#Target#의 눈이 보이지 않습니다!", "+실명" end,
	on_lose = function(self, err) return "#Target#의 눈이 다시 보입니다.", "-실명" end,
	on_timeout = function(self, eff)
		DamageType:get(DamageType.DARKNESS).projector(eff.src, self.x, self.y, DamageType.DARKNESS, eff.dam)
	end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("blind", 1)
		if game.level then
			self:resetCanSeeCache()
			if self.player then for uid, e in pairs(game.level.entities) do if e.x then game.level.map:updateMap(e.x, e.y) end end game.level.map.changed = true end
		end
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("blind", eff.tmpid)
		if game.level then
			self:resetCanSeeCache()
			if self.player then for uid, e in pairs(game.level.entities) do if e.x then game.level.map:updateMap(e.x, e.y) end end game.level.map.changed = true end
		end
	end,
}

newEffect{
	name = "BANE_CONFUSED", image = "effects/bane_confused.png",
	desc = "Bane of Confusion",
	kr_display_name = "혼란의 맹독",
	long_desc = function(self, eff) return ("혼란 : %d%%로 임의의 행동 수행 / 복잡한 행동 불가능 / 매 턴마다 어둠 피해 %0.2f"):format(eff.power, eff.dam) end,
	type = "magical",
	subtype = { bane=true, confusion=true },
	status = "detrimental",
	parameters = { power=50, dam=10 },
	on_gain = function(self, err) return "#Target1# 마구 두리번거립니다!.", "+혼란" end,
	on_lose = function(self, err) return "#Target1# 다시 집중하기 시작합니다.", "-혼란" end,
	on_timeout = function(self, eff)
		DamageType:get(DamageType.DARKNESS).projector(eff.src, self.x, self.y, DamageType.DARKNESS, eff.dam)
	end,
	activate = function(self, eff)
		eff.power = math.floor(math.max(eff.power - (self:attr("confusion_immune") or 0) * 100, 10))
		eff.power = util.bound(eff.power, 0, 50)
		eff.tmpid = self:addTemporaryValue("confused", eff.power)
		if eff.power <= 0 then eff.dur = 0 end
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("confused", eff.tmpid)
	end,
}

newEffect{
	name = "SUPERCHARGE_GOLEM", image = "talents/supercharge_golem.png",
	desc = "Supercharge Golem",
	kr_display_name = "과충전된 골렘",
	long_desc = function(self, eff) return ("과충전 : 생명력 재생 +%0.2f / 공격시 피해량 +20%%"):format(eff.regen) end,
	type = "magical",
	subtype = { arcane=true },
	status = "beneficial",
	parameters = { regen=10 },
	on_gain = function(self, err) return "#Target1# 과충전되었습니다.", "+과충전" end,
	on_lose = function(self, err) return "#Target1# 조금 덜 위험한 존재가 되었습니다.", "-과충전" end,
	activate = function(self, eff)
		eff.pid = self:addTemporaryValue("inc_damage", {all=25})
		eff.lid = self:addTemporaryValue("life_regen", eff.regen)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_damage", eff.pid)
		self:removeTemporaryValue("life_regen", eff.lid)
	end,
}

newEffect{
	name = "POWER_OVERLOAD",
	desc = "Power Overload",
	kr_display_name = "넘치는 힘",
	long_desc = function(self, eff) return ("넘치는 힘 : 공격시 피해량 +%d%%"):format(eff.power) end,
	type = "magical",
	subtype = { arcane=true },
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target#의 힘이 넘치기 시작합니다.", "+넘치는 힘" end,
	on_lose = function(self, err) return "#Target1# 조금 덜 위험한 존재가 되었습니다.", "-넘치는 힘" end,
	activate = function(self, eff)
		eff.pid = self:addTemporaryValue("inc_damage", {all=eff.power})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_damage", eff.pid)
	end,
}

newEffect{
	name = "LIFE_TAP", image = "talents/life_tap.png",
	desc = "Life Tap",
	kr_display_name = "생명의 힘",
	long_desc = function(self, eff) return ("생명의 힘 : 공격시 피해량 +%d%%"):format(eff.power) end,
	type = "magical",
	subtype = { blight=true },
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target#의 힘이 넘치기 시작합니다.", "+생명력 전이" end,
	on_lose = function(self, err) return "#Target1# 조금 덜 위험한 존재가 되었습니다.", "-생명력 전이" end,
	activate = function(self, eff)
		eff.pid = self:addTemporaryValue("inc_damage", {all=eff.power})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_damage", eff.pid)
	end,
}

newEffect{
	name = "ARCANE_EYE", image = "talents/arcane_eye.png",
	desc = "Arcane Eye",
	kr_display_name = "마법의 눈 사용",
	long_desc = function(self, eff) return ("마법의 눈 사용 : 주변 %d 칸 범위"):format(eff.radius) end,
	type = "magical",
	subtype = { sense=true },
	status = "beneficial",
	cancel_on_level_change = true,
	parameters = { range=10, actor=1, object=0, trap=0 },
	activate = function(self, eff)
		game.level.map.changed = true
		eff.particle = Particles.new("image", 1, {image="shockbolt/npc/arcane_eye", size=64})
		eff.particle.x = eff.x
		eff.particle.y = eff.y
		eff.particle.always_seen = true
		game.level.map:addParticleEmitter(eff.particle)
	end,
	on_timeout = function(self, eff)
		-- Track an actor if it's not dead
		if eff.track and not eff.track.dead then
			eff.x = eff.track.x
			eff.y = eff.track.y
			eff.particle.x = eff.x
			eff.particle.y = eff.y
			game.level.map.changed = true
		end
	end,
	deactivate = function(self, eff)
		game.level.map:removeParticleEmitter(eff.particle)
		game.level.map.changed = true
	end,
}

newEffect{
	name = "ARCANE_EYE_SEEN", image = "talents/arcane_eye.png",
	desc = "Seen by Arcane Eye",
	kr_display_name = "마법의 눈 부착됨",
	long_desc = function(self, eff) return "타인에 의해 마법의 눈이 부착됨" end,
	type = "magical",
	subtype = { sense=true },
	no_ct_effect = true,
	status = "detrimental",
	parameters = {},
	activate = function(self, eff)
		if eff.true_seeing then
			eff.inv = self:addTemporaryValue("invisible", -(self:attr("invisible") or 0))
			eff.stealth = self:addTemporaryValue("stealth", -((self:attr("stealth") or 0) + (self:attr("inc_stealth") or 0)))
		end
	end,
	deactivate = function(self, eff)
		if eff.inv then self:removeTemporaryValue("invisible", eff.inv) end
		if eff.stealth then self:removeTemporaryValue("stealth", eff.stealth) end
	end,
}

newEffect{
	name = "ALL_STAT", image = "effects/all_stat.png",
	desc = "All stats increase",
	kr_display_name = "모든 능력치 상승",
	long_desc = function(self, eff) return ("모든 능력치 +%d"):format(eff.power) end,
	type = "magical",
	subtype = { arcane=true },
	status = "beneficial",
	parameters = { power=1 },
	activate = function(self, eff)
		eff.stat = self:addTemporaryValue("inc_stats",
		{
			[Stats.STAT_STR] = eff.power,
			[Stats.STAT_DEX] = eff.power,
			[Stats.STAT_MAG] = eff.power,
			[Stats.STAT_WIL] = eff.power,
			[Stats.STAT_CUN] = eff.power,
			[Stats.STAT_CON] = eff.power,
		})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_stats", eff.stat)
	end,
}

newEffect{
	name = "DISPLACEMENT_SHIELD", image = "talents/displacement_shield.png",
	desc = "Displacement Shield",
	kr_display_name = "왜곡의 보호막",
	long_desc = function(self, eff) return ("주변 공간 왜곡 : %d%% 확률로, 받은 피해를 %s에게 전가 / 유지되는 동안 피해 %d 흡수 (흡수 한계량 : %d)"):format(eff.chance, eff.target and (eff.target.kr_display_name or eff.target.name) or "누군가", self.displacement_shield, eff.power) end,
	type = "magical",
	subtype = { teleport=true, shield=true },
	status = "beneficial",
	parameters = { power=10, target=nil, chance=25 },
	on_gain = function(self, err) return "#Target# 주변의 공간 구조가 변화했습니다.", "+왜곡의 보호막" end,
	on_lose = function(self, err) return "#Target# 주변의 공간 구조가 안정되어 평범해졌습니다.", "-왜곡의 보호막" end,
	activate = function(self, eff)
		if self:attr("shield_factor") then eff.power = eff.power * (100 + self:attr("shield_factor")) / 100 end
		if self:attr("shield_dur") then eff.dur = eff.dur + self:attr("shield_dur") end
		self.displacement_shield = eff.power
		self.displacement_shield_max = eff.power
		self.displacement_shield_chance = eff.chance
		--- Warning there can be only one time shield active at once for an actor
		self.displacement_shield_target = eff.target
		if core.shader.active(4) then
			eff.particle = self:addParticles(Particles.new("shader_shield", 1, {img="shield3"}, {type="shield", time_factor=6000, color={0.5, 1, 0.2}}))
		else
			eff.particle = self:addParticles(Particles.new("displacement_shield", 1))
		end
	end,
	on_aegis = function(self, eff, aegis)
		self.displacement_shield = self.displacement_shield + eff.power * aegis / 100
	end,
	on_timeout = function(self, eff)
		if not eff.target or eff.target.dead then
			eff.target = nil
			return true
		end
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
		self.displacement_shield = nil
		self.displacement_shield_max = nil
		self.displacement_shield_chance = nil
		self.displacement_shield_target = nil
	end,
}

newEffect{
	name = "DAMAGE_SHIELD", image = "talents/barrier.png",
	desc = "Damage Shield",
	kr_display_name = "피해 보호막",
	long_desc = function(self, eff) return ("마법 보호막 : 유지되는 동안 피해 %d 흡수 (흡수 한계량 : %d)"):format(self.damage_shield_absorb, eff.power) end,
	type = "magical",
	subtype = { arcane=true, shield=true },
	status = "beneficial",
	parameters = { power=100 },
	on_gain = function(self, err) return "보호막이 #target2# 감쌌습니다.", "+보호막" end,
	on_lose = function(self, err) return "#Target2# 둘러싼 보호막이 사라졌습니다.", "-보호막" end,
	on_aegis = function(self, eff, aegis)
		self.damage_shield_absorb = self.damage_shield_absorb + eff.power * aegis / 100
	end,
	damage_feedback = function(self, eff, src, value)
		if eff.particle and eff.particle._shader and eff.particle._shader.shad and src and src.x and src.y then
			local r = -rng.float(0.2, 0.4)
			local a = math.atan2(src.y - self.y, src.x - self.x)
			eff.particle._shader:setUniform("impact", {math.cos(a) * r, math.sin(a) * r})
			eff.particle._shader:setUniform("impact_tick", core.game.getTime())
		end
	end,
	activate = function(self, eff)
		if self:attr("shield_factor") then eff.power = eff.power * (100 + self:attr("shield_factor")) / 100 end
		if self:attr("shield_dur") then eff.dur = eff.dur + self:attr("shield_dur") end
		eff.tmpid = self:addTemporaryValue("damage_shield", eff.power)
		if eff.reflect then eff.refid = self:addTemporaryValue("damage_shield_reflect", eff.reflect) end
		--- Warning there can be only one time shield active at once for an actor
		self.damage_shield_absorb = eff.power
		self.damage_shield_absorb_max = eff.power
		if core.shader.active(4) then
			eff.particle = self:addParticles(Particles.new("shader_shield", 1, nil, {type="shield", color={0.4, 0.7, 1.0}}))
		else
			eff.particle = self:addParticles(Particles.new("damage_shield", 1))
		end
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
		self:removeTemporaryValue("damage_shield", eff.tmpid)
		if eff.refid then self:removeTemporaryValue("damage_shield_reflect", eff.refid) end
		self.damage_shield_absorb = nil
		self.damage_shield_absorb_max = nil
	end,
}

newEffect{
	name = "MARTYRDOM", image = "talents/martyrdom.png",
	desc = "Martyrdom",
	kr_display_name = "고난",
	long_desc = function(self, eff) return ("대상이 피해를 받으면, 공격자에게도 %d%%만큼 피해"):format(eff.power) end,
	type = "magical",
	subtype = { light=true },
	status = "detrimental",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target1# 고난의 길을 걷습니다.", "+고난" end,
	on_lose = function(self, err) return "#Target#의 고난이 끝났습니다.", "-고난" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("martyrdom", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("martyrdom", eff.tmpid)
	end,
}

newEffect{
	name = "CURSE_VULNERABILITY", image = "talents/curse_of_vulnerability.png",
	desc = "Curse of Vulnerability",
	kr_display_name = "약화의 저주",
	long_desc = function(self, eff) return ("저주 : 모든 피해 저항 -%d%%"):format(eff.power) end,
	type = "magical",
	subtype = { curse=true },
	status = "detrimental",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target1# 저주받았습니다.", "+저주" end,
	on_lose = function(self, err) return "#Target#의 저주가 사라졌습니다.", "-저주" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("resists", {
			all = -eff.power,
		})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("resists", eff.tmpid)
	end,
}

newEffect{
	name = "CURSE_IMPOTENCE", image = "talents/curse_of_impotence.png",
	desc = "Curse of Impotence",
	kr_display_name = "무기력의 저주",
	long_desc = function(self, eff) return ("저주 : 공격시 피해량 -%d%%"):format(eff.power) end,
	type = "magical",
	subtype = { curse=true },
	status = "detrimental",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target1# 저주받았습니다.", "+저주" end,
	on_lose = function(self, err) return "#Target#의 저주가 사라졌습니다.", "-저주" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("inc_damage", {
			all = -eff.power,
		})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_damage", eff.tmpid)
	end,
}

newEffect{
	name = "CURSE_DEFENSELESSNESS", image = "talents/curse_of_defenselessness.png",
	desc = "Curse of Defenselessness",
	kr_display_name = "무저항의 저주",
	long_desc = function(self, eff) return ("저주 : 회피도 -%d / 모든 내성 -%d"):format(eff.power, eff.power) end, --@@ 변수 조정
	type = "magical",
	subtype = { curse=true },
	status = "detrimental",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target1# 저주받았습니다.", "+저주" end,
	on_lose = function(self, err) return "#Target#의 저주가 사라졌습니다.", "-저주" end,
	activate = function(self, eff)
		eff.def = self:addTemporaryValue("combat_def", -eff.power)
		eff.mental = self:addTemporaryValue("combat_mentalresist", -eff.power)
		eff.spell = self:addTemporaryValue("combat_spellresist", -eff.power)
		eff.physical = self:addTemporaryValue("combat_physresist", -eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_def", eff.def)
		self:removeTemporaryValue("combat_mentalresist", eff.mental)
		self:removeTemporaryValue("combat_spellresist", eff.spell)
		self:removeTemporaryValue("combat_physresist", eff.physical)
	end,
}

newEffect{
	name = "CURSE_DEATH", image = "talents/curse_of_death.png",
	desc = "Curse of Death",
	kr_display_name = "죽음의 저주",
	long_desc = function(self, eff) return ("저주 : 매 턴마다 %0.2f 어둠 피해 / 자연적인 생명력 재생 중지"):format(eff.dam) end,
	type = "magical",
	subtype = { curse=true, darkness=true },
	status = "detrimental",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target1# 저주받았습니다.", "+저주" end,
	on_lose = function(self, err) return "##Target#의 저주가 사라졌습니다.", "-저주" end,
	-- Damage each turn
	on_timeout = function(self, eff)
		DamageType:get(DamageType.DARKNESS).projector(eff.src, self.x, self.y, DamageType.DARKNESS, eff.dam)
	end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("no_life_regen", 1)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("no_life_regen", eff.tmpid)
	end,
}

newEffect{
	name = "CURSE_HATE", image = "talents/curse_of_the_meek.png",
	desc = "Curse of Hate",
	kr_display_name = "증오의 저주",
	long_desc = function(self, eff) return ("저주 : 5 칸 반경에 있는 모든 적 도발") end,
	type = "magical",
	subtype = { curse=true },
	status = "detrimental",
	parameters = { },
	on_gain = function(self, err) return "#Target1# 저주받았습니다.", "+저주" end,
	on_lose = function(self, err) return "#Target#의 저주가 사라졌습니다.", "-저주" end,
	on_timeout = function(self, eff)
		if self.dead or not self.x then return end
		local tg = {type="ball", range=0, radius=5, friendlyfire=false}
		self:project(tg, self.x, self.y, function(tx, ty)
			local a = game.level.map(tx, ty, Map.ACTOR)
			if a and not a.dead and a:reactionToward(self) < 0 then a:setTarget(self) end
		end)
	end,
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "BLOODLUST", image = "talents/bloodlust.png",
	desc = "Bloodlust",
	kr_display_name = "피의 굶주림",
	long_desc = function(self, eff) return ("주문력 +%d"):format(eff.dur) end,
	type = "magical",
	subtype = { frenzy=true },
	status = "beneficial",
	parameters = { power=1 },
	on_merge = function(self, old_eff, new_eff)
		local dur = new_eff.dur
		local max = math.floor(6 * self:getTalentLevel(self.T_BLOODLUST))
		local max_turn = math.floor(self:getTalentLevel(self.T_BLOODLUST))

		if old_eff.last_turn < game.turn then old_eff.used_this_turn = 0 end
		if old_eff.used_this_turn > max_turn then dur = 0 end

		old_eff.dur = math.min(old_eff.dur + dur, max)
		old_eff.last_turn = game.turn
		return old_eff
	end,
	activate = function(self, eff)
		eff.last_turn = game.turn
		eff.used_this_turn = 0
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "ACID_SPLASH", image = "talents/acidic_skin.png",
	desc = "Acid Splash",
	kr_display_name = "산성 뒤덮힘",
	long_desc = function(self, eff) return ("산성 뒤덮힘 : 매 턴마다 산성 피해 %0.2f / 방어도 -%d / 정확도 -%d"):format(eff.dam, eff.armor or 0, eff.atk) end,
	type = "magical",
	subtype = { acid=true, sunder=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target1# 산으로 뒤덮혔습니다!" end,
	on_lose = function(self, err) return "#Target2# 뒤덮은 산이 사라졌습니다." end,
	-- Damage each turn
	on_timeout = function(self, eff)
		DamageType:get(DamageType.ACID).projector(eff.src, self.x, self.y, DamageType.ACID, eff.dam)
	end,
	activate = function(self, eff)
		eff.atkid = self:addTemporaryValue("combat_atk", -eff.atk)
		if eff.armor then eff.armorid = self:addTemporaryValue("combat_armor", -eff.armor) end
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_atk", eff.atkid)
		if eff.armorid then self:removeTemporaryValue("combat_armor", eff.armorid) end
	end,
}

newEffect{
	name = "BLOOD_FURY", image = "talents/blood_fury.png",
	desc = "Bloodfury",
	kr_display_name = "피의 분노",
	long_desc = function(self, eff) return ("피의 분노: 황폐 공격시 피해량 +%d%% / 산성 공격시 피해량 +%d%%"):format(eff.power, eff.power) end, --@@ 변수 조정
	type = "magical",
	subtype = { frenzy=true },
	status = "beneficial",
	parameters = { power=10 },
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("inc_damage", {[DamageType.BLIGHT] = eff.power, [DamageType.ACID] = eff.power})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_damage", eff.tmpid)
	end,
}

newEffect{
	name = "PHOENIX_EGG", image = "effects/phoenix_egg.png",
	desc = "Reviving Phoenix",
	kr_display_name = "불사조의 부활",
	long_desc = function(self, eff) return "죽으면 부활" end,
	type = "magical",
	subtype = { fire=true },
	status = "beneficial",
	parameters = { life_regen = 25, mana_regen = -9.75, never_move = 1, silence = 1 },
	on_gain = function(self, err) return "#Target#의 몸이 불타올라 사라지고, 그 자리에 불꽃의 알이 생겼습니다.", "+불사조" end,
	on_lose = function(self, err) return "알에서 #Target1# 튀어 나왔습니다.", "-불사조" end,
	activate = function(self, eff)
		self.display = "O"						             -- change the display of the phoenix to an egg, maybe later make it a fiery orb image
		eff.old_image = self.image
		self.image = "object/egg_dragons_egg_06_64.png"
		self:removeAllMOs()
		eff.life_regen = self:addTemporaryValue("life_regen", 25)	         -- gives it a 10 life regen, should I increase this?
		eff.mana_regen = self:addTemporaryValue("mana_regen", -9.75)          -- makes the mana regen realistic
		eff.never_move = self:addTemporaryValue("never_move", 1)	 -- egg form should not move
		eff.silence = self:addTemporaryValue("silence", 1)		          -- egg should not cast spells
		eff.combat = self.combat
		self.combat = nil						               -- egg shouldn't melee
	end,
	deactivate = function(self, eff)
		self.display = "B"
		self.image = eff.old_image
		self:removeAllMOs()
		self:removeTemporaryValue("life_regen", eff.life_regen)
		self:removeTemporaryValue("mana_regen", eff.mana_regen)
		self:removeTemporaryValue("never_move", eff.never_move)
		self:removeTemporaryValue("silence", eff.silence)
		self.combat = eff.combat
	end,
}

newEffect{
	name = "HURRICANE", image = "effects/hurricane.png",
	desc = "Hurricane",
	kr_display_name = "허리케인",
	long_desc = function(self, eff) return ("허리케인 : 자신을 포함한 주변의 모두에게 매 턴마다 전기 피해 %0.2f - %0.2f"):format(eff.dam / 3, eff.dam) end,
	type = "magical",
	subtype = { lightning=true },
	status = "detrimental",
	parameters = { dam=10, radius=2 },
	on_gain = function(self, err) return "#Target1# 허리케인에 갇혔습니다.", "+허리케인" end,
	on_lose = function(self, err) return "#Target2# 감싸던 허리케인이 사라졌습니다.", "-허리케인" end,
	on_timeout = function(self, eff)
		local tg = {type="ball", x=self.x, y=self.y, radius=eff.radius, selffire=false}
		local dam = eff.dam
		eff.src:project(tg, self.x, self.y, DamageType.LIGHTNING, rng.avg(dam / 3, dam, 3))

		if core.shader.active() then game.level.map:particleEmitter(self.x, self.y, tg.radius, "ball_lightning_beam", {radius=tg.radius}, {type="lightning"})
		else game.level.map:particleEmitter(self.x, self.y, tg.radius, "ball_lightning_beam", {radius=tg.radius}) end

		game:playSoundNear(self, "talents/lightning")
	end,
}

newEffect{
	name = "RECALL", image = "effects/recall.png",
	desc = "Recalling",
	kr_display_name = "복귀",
	long_desc = function(self, eff) return "세계지도 상으로 순간이동 대기중" end,
	type = "magical",
	subtype = { unknown=true },
	status = "beneficial",
	cancel_on_level_change = true,
	parameters = { },
	activate = function(self, eff)
		eff.leveid = game.zone.short_name.."-"..game.level.level
	end,
	deactivate = function(self, eff)
		if (eff.allow_override or (self:canBe("worldport") and not self:attr("never_move"))) and eff.dur <= 0 then
			game:onTickEnd(function()
				if eff.leveid == game.zone.short_name.."-"..game.level.level and game.player.can_change_zone then
					game.logPlayer(self, "밖으로 튕겨져 나갑니다!")
					game:changeLevel(1, eff.where or game.player.last_wilderness)
				end
			end)
		else
			game.logPlayer(self, "주변의 공간이 다시 안정적으로 변했습니다.")
		end
	end,
}

newEffect{
	name = "TELEPORT_ANGOLWEN", image = "talents/teleport_angolwen.png",
	desc = "Teleport: Angolwen",
	kr_display_name = "순간이동: 앙골웬",
	long_desc = function(self, eff) return "앙골웬으로 순간이동 대기중" end,
	type = "magical",
	subtype = { teleport=true },
	status = "beneficial",
	cancel_on_level_change = true,
	parameters = { },
	activate = function(self, eff)
		eff.leveid = game.zone.short_name.."-"..game.level.level
	end,
	deactivate = function(self, eff)
		local seen = false
		-- Check for visible monsters, only see LOS actors, so telepathy wont prevent it
		core.fov.calc_circle(self.x, self.y, game.level.map.w, game.level.map.h, 20, function(_, x, y) return game.level.map:opaque(x, y) end, function(_, x, y)
			local actor = game.level.map(x, y, game.level.map.ACTOR)
			if actor and actor ~= self then seen = true end
		end, nil)
		if seen then
			game.log("누군가 당신을 보고 있습니다. 섣부른 순간이동으로 앙골웬의 위치를 노출시킬 수는 없습니다.")
			return
		end

		if self:canBe("worldport") and not self:attr("never_move") and eff.dur <= 0 then
			game:onTickEnd(function()
				if eff.leveid == game.zone.short_name.."-"..game.level.level and game.player.can_change_zone then
					game.logPlayer(self, "앙골웬으로 이동합니다!")
					game:changeLevel(1, "town-angolwen")
				end
			end)
		else
			game.logPlayer(self, "주변의 공간이 다시 안정적으로 변했습니다.")
		end
	end,
}

newEffect{
	name = "TELEPORT_POINT_ZERO", image = "talents/teleport_point_zero.png",
	desc = "Timeport: Point Zero",
	kr_display_name = "시공간이동: 영점",
	long_desc = function(self, eff) return "영점으로 시공간이동 대기중" end,
	type = "magical",
	subtype = { timeport=true },
	status = "beneficial",
	cancel_on_level_change = true,
	parameters = { },
	activate = function(self, eff)
		eff.leveid = game.zone.short_name.."-"..game.level.level
	end,
	deactivate = function(self, eff)
		local seen = false
		-- Check for visible monsters, only see LOS actors, so telepathy wont prevent it
		core.fov.calc_circle(self.x, self.y, game.level.map.w, game.level.map.h, 20, function(_, x, y) return game.level.map:opaque(x, y) end, function(_, x, y)
			local actor = game.level.map(x, y, game.level.map.ACTOR)
			if actor and actor ~= self then seen = true end
		end, nil)
		if seen then
			game.log("누군가 당신을 보고 있습니다. 섣부른 시공간이동으로 영점의 위치를 노출시킬 수는 없습니다.")
			return
		end

		if self:canBe("worldport") and not self:attr("never_move") and eff.dur <= 0 then
			game:onTickEnd(function()
				if eff.leveid == game.zone.short_name.."-"..game.level.level and game.player.can_change_zone then
					game.logPlayer(self, "영점으로 이동합니다!")
					game:changeLevel(1, "town-point-zero")
				end
			end)
		else
			game.logPlayer(self, "주변의 시간이 다시 안정적으로 변했습니다.")
		end
	end,
}

newEffect{
	name = "PREMONITION_SHIELD", image = "talents/premonition.png",
	desc = "Premonition Shield",
	kr_display_name = "예감의 보호막",
	long_desc = function(self, eff) return ("%s 피해 %d%% 감소"):format((DamageType:get(eff.damtype).kr_display_name or DamageType:get(eff.damtype).name), eff.resist) end,
	type = "magical",
	subtype = { sense=true },
	status = "beneficial",
	parameters = { },
	on_gain = function(self, err) return "#Target1# 순간적으로 보호막을 시전했습니다!", "+예감의 보호막" end,
	on_lose = function(self, err) return "#Target#의 보호막이 사라졌습니다.", "-예감의 보호막" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("resists", {[eff.damtype]=eff.resist})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("resists", eff.tmpid)
	end,
}

newEffect{
	name = "CORROSIVE_WORM", image = "talents/corrosive_worm.png",
	desc = "Corrosive Worm",
	kr_display_name = "부식성 벌레",
	long_desc = function(self, eff) return ("부식성 벌레 : 매 턴마다 산성 피해 %0.2f"):format(eff.dam) end,
	type = "magical",
	subtype = { acid=true },
	status = "detrimental",
	parameters = { dam=1, explosion=10 },
	on_gain = function(self, err) return "#Target1# 부식성 벌레에 오염되었습니다.", "+부식성 벌레" end,
	on_lose = function(self, err) return "#Target2# 오염시키던 부식성 벌레가 사라졌습니다.", "-부식성 벌레" end,
	on_timeout = function(self, eff)
		DamageType:get(DamageType.ACID).projector(eff.src or self, self.x, self.y, DamageType.ACID, eff.dam)
	end,
}

newEffect{
	name = "WRAITHFORM", image = "talents/wraithform.png",
	desc = "Wraithform",
	kr_display_name = "악령 변신",
	long_desc = function(self, eff) return ("악령으로 변신 : 벽 통과 가능 (다른 자연적 장애물에는 불가능) / 회피도 +%d / 방어도 +%d"):format(eff.def, eff.armor) end,
	type = "magical",
	subtype = { darkness=true },
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target1# 악령으로 변신했습니다.", "+악령 변신" end,
	on_lose = function(self, err) return "#Target1# 원래의 모습으로 돌아왔습니다.", "-악령 변신" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("can_pass", {pass_wall=20})
		eff.defid = self:addTemporaryValue("combat_def", eff.def)
		eff.armid = self:addTemporaryValue("combat_armor", eff.armor)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("can_pass", eff.tmpid)
		self:removeTemporaryValue("combat_def", eff.defid)
		self:removeTemporaryValue("combat_armor", eff.armid)
	end,
}

newEffect{
	name = "EMPOWERED_HEALING", image = "effects/empowered_healing.png",
	desc = "Empowered Healing",
	kr_display_name = "향상된 치료",
	long_desc = function(self, eff) return ("치유 증가율 +%d%%"):format(eff.power * 100) end,
	type = "magical",
	subtype = { light=true },
	status = "beneficial",
	parameters = { power = 0.1 },
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("healing_factor", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("healing_factor", eff.tmpid)
	end,
}

newEffect{
	name = "PROVIDENCE", image = "talents/providence.png",
	desc = "Providence",
	kr_display_name = "빛의 섭리",
	long_desc = function(self, eff) return ("매 턴마다 나쁜 상태이상 효과 한 가지 제거 / 생명력 재생 +%d"):format(eff.power) end,
	type = "magical",
	subtype = { light=true },
	status = "beneficial",
	parameters = {},
	on_timeout = function(self, eff)
		local effs = {}
		-- Go through all spell effects
		for eff_id, p in pairs(self.tmp) do
			local e = self.tempeffect_def[eff_id]
			if e.status == "detrimental" and e.type ~= "other" then
				effs[#effs+1] = {"effect", eff_id}
			end
		end

		if #effs > 0 then
			local eff = rng.tableRemove(effs)
			if eff[1] == "effect" then
				self:removeEffect(eff[2])
			end
		end
	end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("life_regen", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("life_regen", eff.tmpid)
	end,
}

newEffect{
	name = "TOTALITY", image = "talents/totality.png",
	desc = "Totality",
	kr_display_name = "개기 일월식",
	long_desc = function(self, eff) return ("빛 저항 관통 +%d%% / 어둠 저항 관통 +%d%%"):format(eff.power, eff.power) end, --@@ 변수 조정
	type = "magical",
	subtype = { darkness=true, light=true },
	status = "beneficial",
	parameters = { power=10 },
	activate = function(self, eff)
		eff.penet = self:addTemporaryValue("resists_pen", {
			[DamageType.DARKNESS] = eff.power,
			[DamageType.LIGHT] = eff.power,
		})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("resists_pen", eff.penet)
	end,
}

-- Circles
newEffect{
	name = "SANCTITY", image = "talents/circle_of_sanctity.png",
	desc = "Sanctity",
	kr_display_name = "고결함",
	long_desc = function(self, eff) return ("침묵 면역") end,
	type = "magical",
	subtype = { circle=true },
	status = "beneficial",
	parameters = { power=10 },
	activate = function(self, eff)
		eff.silence = self:addTemporaryValue("silence_immune", 1)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("silence_immune", eff.silence)
	end,
}

newEffect{
	name = "SHIFTING_SHADOWS", image = "talents/circle_of_shifting_shadows.png",
	desc = "Shifting Shadows",
	kr_display_name = "흐르는 그림자",
	long_desc = function(self, eff) return ("회피도 +%d"):format(eff.power) end,
	type = "magical",
	subtype = { circle=true, darkness=true },
	status = "beneficial",
	parameters = {power = 1},
	activate = function(self, eff)
		eff.defense = self:addTemporaryValue("combat_def", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_def", eff.defense)
	end,
}

newEffect{
	name = "BLAZING_LIGHT", image = "talents/circle_of_blazing_light.png",
	desc = "Blazing Light",
	kr_display_name = "타오르는 빛",
	long_desc = function(self, eff) return ("양기 재생 +%d"):format(eff.power) end,
	type = "magical",
	subtype = { circle=true, light=true },
	status = "beneficial",
	parameters = {power = 1},
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "positive_regen_ref", -eff.power)
		self:effectTemporaryValue(eff, "positive_at_rest_disable", 1)
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "WARDING", image = "talents/circle_of_warding.png",
	desc = "Warding",
	kr_display_name = "보호",
	long_desc = function(self, eff) return ("대상을 목표로한 발사체 속도 -%d%%"):format (eff.power) end,
	type = "magical",
	subtype = { circle=true, light=true, darkness=true },
	status = "beneficial",
	parameters = {power = 1},
	activate = function(self, eff)
		eff.ward = self:addTemporaryValue("slow_projectiles", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("slow_projectiles", eff.ward)
	end,
}

newEffect{
	name = "TURN_BACK_THE_CLOCK", image = "talents/turn_back_the_clock.png",
	desc = "Turn Back the Clock",
	kr_display_name = "시간 되돌리기",
	long_desc = function(self, eff) return ("어린 상태로 시간 되돌리기 : 모든 능력치 -%d"):format(eff.power) end,
	type = "magical",
	subtype = { temporal=true },
	status = "detrimental",
	parameters = { },
	on_gain = function(self, err) return "#Target#의 상태가 훨씬 어릴 때로 되돌아갔습니다!", "+시간 되돌리기" end,
	on_lose = function(self, err) return "#Target1# 자연적인 나이의 상태로 되돌아갔습니다.", "-시간 되돌리기" end,
	activate = function(self, eff)
		eff.stat = self:addTemporaryValue("inc_stats", {
				[Stats.STAT_STR] = -eff.power,
				[Stats.STAT_DEX] = -eff.power,
				[Stats.STAT_CON] = -eff.power,
				[Stats.STAT_MAG] = -eff.power,
				[Stats.STAT_WIL] = -eff.power,
				[Stats.STAT_CUN] = -eff.power,
		})
		-- Make sure the target doesn't have more life then it should
		if self.life > self.max_life then
			self.life = self.max_life
		end
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_stats", eff.stat)
	end,
}

newEffect{
	name = "WASTING", image = "talents/ashes_to_ashes.png",
	desc = "Wasting",
	kr_display_name = "낭비",
	long_desc = function(self, eff) return ("낭비 : 매 턴마다 시간 피해 %0.2f"):format(eff.power) end,
	type = "magical",
	subtype = { temporal=true },
	status = "detrimental",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target1# 시간을 낭비합니다!", "+낭비" end,
	on_lose = function(self, err) return "#Target1# 더이상 시간을 낭비하지 않습니다.", "-낭비" end,
	on_merge = function(self, old_eff, new_eff)
		-- Merge the flames!
		local olddam = old_eff.power * old_eff.dur
		local newdam = new_eff.power * new_eff.dur
		local dur = math.ceil((old_eff.dur + new_eff.dur) / 2)
		old_eff.dur = dur
		old_eff.power = (olddam + newdam) / dur
		return old_eff
	end,
	on_timeout = function(self, eff)
		DamageType:get(DamageType.TEMPORAL).projector(eff.src, self.x, self.y, DamageType.TEMPORAL, eff.power)
	end,
}

newEffect{
	name = "PRESCIENCE", image = "talents/moment_of_prescience.png",
	desc = "Prescience",
	kr_display_name = "통찰",
	long_desc = function(self, eff) return ("인식력 최고조 : 은신감지 +%d / 투명감지 +%d / 회피도 +%d / 정확도 +%d"):format(eff.power, eff.power, eff.power, eff.power) end, --@@ 변수 조정
	type = "magical",
	subtype = { sense=true, temporal=true },
	status = "beneficial",
	parameters = { power = 1 },
	on_gain = function(self, err) return "#Target#의 인식력이 최고조의 상태가 됩니다!", "+통찰" end,
	on_lose = function(self, err) return "#Target#의 인식력이 보통으로 되돌아왔습니다.", "-통찰" end,
	activate = function(self, eff)
		eff.defid = self:addTemporaryValue("combat_def", eff.power)
		eff.atkid = self:addTemporaryValue("combat_atk", eff.power)
		eff.invis = self:addTemporaryValue("see_invisible", eff.power)
		eff.stealth = self:addTemporaryValue("see_stealth", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("see_invisible", eff.invis)
		self:removeTemporaryValue("see_stealth", eff.stealth)
		self:removeTemporaryValue("combat_def", eff.defid)
		self:removeTemporaryValue("combat_atk", eff.atkid)
	end,
}

newEffect{
	name = "INVIGORATE", image = "talents/invigorate.png",
	desc = "Invigorate",
	kr_display_name = "활성화",
	long_desc = function(self, eff) return ("체력 재생 +%d / 모든 기술의 재사용 대기시간이 두 배 빨리 감소"):format(eff.power) end,
	type = "magical",
	subtype = { temporal=true },
	status = "beneficial",
	parameters = {power = 10},
	on_gain = function(self, err) return "#Target1# 활성화 되었습니다.", "+활성화" end,
	on_lose = function(self, err) return "#Target#의 활성화가 사라졌습니다.", "-활성화" end,
	on_timeout = function(self, eff)
		if not self:attr("no_talents_cooldown") then
			for tid, _ in pairs(self.talents_cd) do
				local t = self:getTalentFromId(tid)
				if t and t.name ~= "Invigorate" then
					self.talents_cd[tid] = self.talents_cd[tid] - 1
				end
			end
		end
	end,
	activate = function(self, eff)
		self.stamina_regen = self.stamina_regen + eff.power
	end,
	deactivate = function(self, eff)
		self.stamina_regen = self.stamina_regen - eff.power
	end,
}

newEffect{
	name = "GATHER_THE_THREADS", image = "talents/gather_the_threads.png",
	desc = "Gather the Threads",
	kr_display_name = "시간의 흐름 - 수집",
	long_desc = function(self, eff) return ("주문력 +%d / 매턴마다 추가적인 주문력 +%d"):
	format(eff.cur_power or eff.power, eff.power/5) end,
	type = "magical",
	subtype = { temporal=true },
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target1# 시간의 흐름으로부터 에너지를 수집합니다.", "+시간의 흐름 수집" end,
	on_lose = function(self, err) return "#Target1# 시간의 흐름에 대한 제어를 잃어버렸습니다.", "-시간의 흐름 수집" end,
	on_merge = function(self, old_eff, new_eff)
		self:removeTemporaryValue("combat_spellpower", old_eff.tmpid)
		old_eff.cur_power = (old_eff.cur_power + new_eff.power)
		old_eff.tmpid = self:addTemporaryValue("combat_spellpower", old_eff.cur_power)

		old_eff.dur = old_eff.dur
		return old_eff
	end,
	on_timeout = function(self, eff)
		local threads = eff.power / 5
		self:incParadox(- eff.reduction)
		self:setEffect(self.EFF_GATHER_THE_THREADS, 1, {power=threads})
	end,
	activate = function(self, eff)
		eff.cur_power = eff.power
		eff.tmpid = self:addTemporaryValue("combat_spellpower", eff.power)
		eff.particle = self:addParticles(Particles.new("time_shield", 1))
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_spellpower", eff.tmpid)
		self:removeParticles(eff.particle)
	end,
}

newEffect{
	name = "FLAWED_DESIGN", image = "talents/flawed_design.png",
	desc = "Flawed Design",
	kr_display_name = "잘못된 설계",
	long_desc = function(self, eff) return ("과거의 변경 : 모든 피해 저항 -%d%%"):format(eff.power) end,
	type = "magical",
	subtype = { temporal=true },
	status = "detrimental",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target1# 약화되었습니다.", "+약화" end,
	on_lose = function(self, err) return "#Target#의 약화가 사라졌습니다.", "-약화" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("resists", {
			all = -eff.power,
		})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("resists", eff.tmpid)
	end,
}

newEffect{
	name = "MANAWORM", image = "effects/manaworm.png",
	desc = "Manaworm",
	kr_display_name = "마나 벌레",
	long_desc = function(self, eff) return ("마나 벌레 오염 : 매 턴마다 마나 -%0.2f / 매 턴마다 마법 피해 %0.2f"):format(eff.power, eff.power) end, --@@ 변수 조정
	type = "magical",
	subtype = { arcane=true },
	status = "detrimental",
	parameters = {power=10},
	on_gain = function(self, err) return "#Target1# 마나 벌레에게 오염되었습니다!", "+마나 벌레" end,
	on_lose = function(self, err) return "#Target1# 오염에서 회복되었습니다.", "-마나 벌레" end,
	on_timeout = function(self, eff)
		local dam = eff.power
		if dam > self:getMana() then dam = self:getMana() end
		self:incMana(-dam)
		DamageType:get(DamageType.ARCANE).projector(eff.src, self.x, self.y, DamageType.ARCANE, dam)
	end,
}

newEffect{
	name = "SURGE_OF_UNDEATH", image = "talents/surge_of_undeath.png",
	desc = "Surge of Undeath",
	kr_display_name = "죽지 못하는 자들의 분노",
	long_desc = function(self, eff) return ("공격시 피해량 +%d / 주문력 +%d / 정확도 +%d / 방어도 관통력 +%d / 물리 치명타율 +%d%% / 주문 치명타율 +%d%%"):format(eff.power, eff.power, eff.power, eff.apr, eff.crit, eff.crit) end, --@@ 변수 조정
	type = "magical",
	subtype = { frenzy=true },
	status = "beneficial",
	parameters = { power=10, crit=10, apr=10 },
	on_gain = function(self, err) return "#Target1# 어둠의 힘에 삼켜졌습니다.", "+죽지 못하는 자들의 분노" end,
	on_lose = function(self, err) return "#Target1# 조금 약해진 것 같습니다.", "-죽지 못하는 자들의 분노" end,
	activate = function(self, eff)
		eff.damid = self:addTemporaryValue("combat_dam", eff.power)
		eff.spellid = self:addTemporaryValue("combat_spellpower", eff.power)
		eff.accid = self:addTemporaryValue("combat_atk", eff.power)
		eff.aprid = self:addTemporaryValue("combat_apr", eff.apr)
		eff.pcritid = self:addTemporaryValue("combat_physcrit", eff.crit)
		eff.scritid = self:addTemporaryValue("combat_spellcrit", eff.crit)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_dam", eff.damid)
		self:removeTemporaryValue("combat_spellpower", eff.spellid)
		self:removeTemporaryValue("combat_atk", eff.accid)
		self:removeTemporaryValue("combat_apr", eff.aprid)
		self:removeTemporaryValue("combat_physcrit", eff.pcritid)
		self:removeTemporaryValue("combat_spellcrit", eff.scritid)
	end,
}

newEffect{
	name = "BONE_SHIELD", image = "talents/bone_shield.png",
	desc = "Bone Shield",
	kr_display_name = "뼈의 방패",
	long_desc = function(self, eff) return ("현재 생명력의 %d%% 이상 피해 발생시, 피해 -%d%%"):format(eff.power, eff.power) end,
	type = "magical",
	subtype = { arcane=true },
	status = "beneficial",
	parameters = { power=30 },
	on_gain = function(self, err) return "#Target1# 부유하는 뼈로 보호되었습니다.", "+뼈의 방패" end,
	on_lose = function(self, err) return "#Target#의 부유하는 뼈가 부서졌습니다.", "-뼈의 방패" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("flat_damage_cap", {all=eff.power})
		eff.particle = self:addParticles(Particles.new("time_shield_bubble", 1))
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("flat_damage_cap", eff.tmpid)
		self:removeParticles(eff.particle)
	end,
}

newEffect{
	name = "REDUX", image = "talents/redux.png",
	desc = "Redux",
	kr_display_name = "재현",
	long_desc = function(self, eff) return "다음에 사용하는 시공 기술을 두 번 연속 사용" end,
	type = "magical",
	subtype = { temporal=true },
	status = "beneficial",
	parameters = { power=1},
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "TEMPORAL_DESTABILIZATION_START", image = "talents/destabilize.png",
	desc = "Temporal Destabilization",
	kr_display_name = "시간적 불안정",
	long_desc = function(self, eff) return ("불안정 : %d턴간 매턴마다 시간 피해 %0.2f / 효과 지속 중 대상이 죽으면 폭발"):format(eff.dur, eff.dam) end,
	type = "magical",
	subtype = { temporal=true },
	status = "detrimental",
	parameters = { dam=1, explosion=10 },
	on_gain = function(self, err) return "#Target1# 불안정해졌습니다.", "+시간적 불안정" end,
	on_lose = function(self, err) return "#Target#의 안정성이 회복되었습니다.", "-시간적 불안정" end,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("destabilized", 1))
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
		self:setEffect(self.EFF_TEMPORAL_DESTABILIZATION, 5, {src=eff.src, dam=eff.dam, explosion=eff.explosion})
	end,
}

newEffect{
	name = "TEMPORAL_DESTABILIZATION", image = "talents/destabilize.png",
	desc = "Temporal Destabilization",
	kr_display_name = "시간적 불안정",
	long_desc = function(self, eff) return ("불안정 : 매 턴마다 시간 피해 %0.2f / 효과 지속 중 대상이 죽으면 폭발"):format(eff.dam) end,
	type = "magical",
	subtype = { temporal=true },
	status = "detrimental",
	parameters = { dam=1, explosion=10 },
	on_gain = function(self, err) return "#Target1# 불안정해졌습니다.", "+시간적 불안정" end,
	on_lose = function(self, err) return "#Target#의 안정성이 회복되었습니다.", "-시간적 불안정" end,
	on_timeout = function(self, eff)
		DamageType:get(DamageType.TEMPORAL).projector(eff.src or self, self.x, self.y, DamageType.TEMPORAL, eff.dam)
	end,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("destabilized", 1))
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
	end,
}

newEffect{
	name = "HASTE", image = "talents/haste.png",
	desc = "Haste",
	kr_display_name = "가속",
	long_desc = function(self, eff) return ("모든 행동 속도 +%d%%"):format(eff.power * 100) end,
	type = "magical",
	subtype = { temporal=true },
	status = "beneficial",
	parameters = { power=0.1 },
	on_gain = function(self, err) return "#Target1# 빨라졌습니다.", "+가속" end,
	on_lose = function(self, err) return "#Target1# 느려졌습니다.", "-가속" end,
	activate = function(self, eff)
		eff.glbid = self:addTemporaryValue("global_speed_add", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("global_speed_add", eff.glbid)
	end,
}

newEffect{
	name = "CEASE_TO_EXIST", image = "talents/cease_to_exist.png",
	desc = "Cease to Exist",
	kr_display_name = "중단된 실존",
	long_desc = function(self, eff) return ("시간의 흐름에서 사라짐 : 매 턴마다 시간 피해 %d"):format(eff.dam) end,
	type = "magical",
	subtype = { temporal=true },
	status = "detrimental",
	parameters = { power = 1 },
	on_gain = function(self, err) return "#Target1# 시간의 흐름에서 사라졌습니다.", "+중단된 실존" end,
	activate = function(self, eff)
		eff.resists = self:addTemporaryValue("resists", { all = -eff.power})
	end,
	deactivate = function(self, eff)
		if game._chronoworlds then
			game._chronoworlds = nil
		end
		self:removeTemporaryValue("resists", eff.resists)
	end,
}

newEffect{
	name = "IMPENDING_DOOM", image = "talents/impending_doom.png",
	desc = "Impending Doom",
	kr_display_name = "임박한 운명",
	long_desc = function(self, eff) return ("임박한 마지막 운명 : 치료 불가능 / 생명력 재생 불가능 / 매 턴마다 마법 피해 %0.2f\n대상이 죽으면 효과 중단"):format(eff.dam) end,
	type = "magical",
	subtype = { arcane=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target#의 운명이 임박했습니다!", "+임박한 운명" end,
	on_lose = function(self, err) return "#Target1# 임박한 운명에서 벗어났습니다.", "-임박한 운명" end,
	activate = function(self, eff)
		eff.healid = self:addTemporaryValue("no_healing", 1)
		eff.regenid = self:addTemporaryValue("no_life_regen", 1)
	end,
	on_timeout = function(self, eff)
		if eff.src.dead or not game.level:hasEntity(eff.src) then return true end
		DamageType:get(DamageType.ARCANE).projector(eff.src, self.x, self.y, DamageType.ARCANE, eff.dam)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("no_healing", eff.healid)
		self:removeTemporaryValue("no_life_regen", eff.regenid)
	end,
}

newEffect{
	name = "RIGOR_MORTIS", image = "talents/rigor_mortis.png",
	desc = "Rigor Mortis",
	kr_display_name = "사후 경직",
	long_desc = function(self, eff) return ("사령의 추종자로부터 받는 피해 +%d%%"):format(eff.power) end,
	type = "magical",
	subtype = { arcane=true },
	status = "detrimental",
	parameters = {power=20},
	on_gain = function(self, err) return "#Target#의 죽음이 임박했습니다!", "+사후 경직" end,
	on_lose = function(self, err) return "#Target1# 사후 경직에서 풀려났습니다.", "-사후 경직" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("inc_necrotic_minions", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_necrotic_minions", eff.tmpid)
	end,
}

newEffect{
	name = "ABYSSAL_SHROUD", image = "talents/abyssal_shroud.png",
	desc = "Abyssal Shroud",
	kr_display_name = "심연의 장막",
	long_desc = function(self, eff) return ("조명 반경 -%d / 어둠 저항 -%d%%"):format(eff.lite, eff.power) end,
	type = "magical",
	subtype = { darkness=true },
	status = "detrimental",
	parameters = {power=20},
	on_gain = function(self, err) return "#Target1# 심연에 더욱 가까워졌습니다!", "+심연의 장막" end,
	on_lose = function(self, err) return "#Target1# 심연으로부터 자유를 되찾았습니다.", "-심연의 장막" end,
	activate = function(self, eff)
		eff.liteid = self:addTemporaryValue("lite", -eff.lite)
		eff.darkid = self:addTemporaryValue("resists", { [DamageType.DARKNESS] = -eff.power })
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("lite", eff.liteid)
		self:removeTemporaryValue("resists", eff.darkid)
	end,
}

newEffect{
	name = "SPIN_FATE", image = "talents/spin_fate.png",
	desc = "Spin Fate",
	kr_display_name = "운명 왜곡",
	long_desc = function(self, eff) return ("모든 내성 +%d"):
	format(eff.cur_save_bonus or eff.save_bonus) end,
	type = "magical",
	subtype = { temporal=true },
	status = "beneficial",
	parameters = { save_bonus, max_bonus = 10},
	on_gain = function(self, err) return "#Target1# 운명을 손아귀에 쥡니다.", "+운명 왜곡" end,
	on_lose = function(self, err) return "#Target1# 더이상 운명을 왜곡하지 못합니다.", "-운명 왜곡" end,
	on_merge = function(self, old_eff, new_eff)
		-- remove the four old values
		self:removeTemporaryValue("combat_physresist", old_eff.physid)
		self:removeTemporaryValue("combat_spellresist", old_eff.spellid)
		self:removeTemporaryValue("combat_mentalresist", old_eff.mentalid)
		-- combine the old and new values
		old_eff.cur_save_bonus = math.min(new_eff.max_bonus, old_eff.cur_save_bonus + new_eff.save_bonus)
		-- and apply the current values
		old_eff.physid = self:addTemporaryValue("combat_physresist", old_eff.cur_save_bonus)
		old_eff.spellid = self:addTemporaryValue("combat_spellresist", old_eff.cur_save_bonus)
		old_eff.mentalid = self:addTemporaryValue("combat_mentalresist", old_eff.cur_save_bonus)

		old_eff.dur = new_eff.dur
		return old_eff
	end,
	activate = function(self, eff)
		-- track the current values
		eff.cur_save_bonus = eff.save_bonus
		-- apply current values
		eff.physid = self:addTemporaryValue("combat_physresist", eff.save_bonus)
		eff.spellid = self:addTemporaryValue("combat_spellresist", eff.save_bonus)
		eff.mentalid = self:addTemporaryValue("combat_mentalresist", eff.save_bonus)
		eff.particle = self:addParticles(Particles.new("arcane_power", 1))
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_physresist", eff.physid)
		self:removeTemporaryValue("combat_spellresist", eff.spellid)
		self:removeTemporaryValue("combat_mentalresist", eff.mentalid)
		self:removeParticles(eff.particle)
	end,
}


newEffect{
	name = "SPELLSHOCKED",
	desc = "Spellshocked",
	kr_display_name = "주문 충격",
	long_desc = function(self, eff) return string.format("주문에 압도됨 : 모든 피해 저항 -%d%%", eff.power) end,
	type = "magical",
	subtype = { ["cross tier"]=true },
	status = "detrimental",
	parameters = { power=20 },
	on_gain = function(self, err) return nil, "+주문 충격" end,
	on_lose = function(self, err) return nil, "-주문 충격" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("resists", {
			all = -eff.power,
		})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("resists", eff.tmpid)
	end,
}

newEffect{
	name = "ROTTING_DISEASE", image = "talents/rotting_disease.png",
	desc = "Rotting Disease",
	kr_display_name = "부패성 질병",
	long_desc = function(self, eff) return ("질병 감염 : 체격 -%d / 매 턴마다 황폐 피해 %0.2f"):format(eff.con, eff.dam) end,
	type = "magical",
	subtype = {disease=true, blight=true},
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target1# 부패성 질병에 감염되었습니다!" end,
	on_lose = function(self, err) return "#Target1# 부패성 질병으로부터 회복되었습니다." end,
	-- Damage each turn
	on_timeout = function(self, eff)
		if self:attr("purify_disease") then self:heal(eff.dam)
		else DamageType:get(DamageType.BLIGHT).projector(eff.src, self.x, self.y, DamageType.BLIGHT, eff.dam, {from_disease=true})
		end
	end,
	-- Lost of CON
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("inc_stats", {[Stats.STAT_CON] = -eff.con})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_stats", eff.tmpid)
	end,
}

newEffect{
	name = "DECREPITUDE_DISEASE", image = "talents/decrepitude_disease.png",
	desc = "Decrepitude Disease",
	kr_display_name = "노화성 질병",
	long_desc = function(self, eff) return ("질병 감염 : 민첩 -%d / 매 턴마다 황폐 피해 %0.2f"):format(eff.dex, eff.dam) end,
	type = "magical",
	subtype = {disease=true, blight=true},
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target1# 노화성 질병에 감염되었습니다!" end,
	on_lose = function(self, err) return "#Target1# 노화성 질병으로부터 회복되었습니다." end,
	-- Damage each turn
	on_timeout = function(self, eff)
		if self:attr("purify_disease") then self:heal(eff.dam)
		else DamageType:get(DamageType.BLIGHT).projector(eff.src, self.x, self.y, DamageType.BLIGHT, eff.dam, {from_disease=true})
		end
	end,
	-- Lost of CON
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("inc_stats", {[Stats.STAT_DEX] = -eff.dex})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_stats", eff.tmpid)
	end,
}

newEffect{
	name = "WEAKNESS_DISEASE", image = "talents/weakness_disease.png",
	desc = "Weakness Disease",
	kr_display_name = "약화성 질병",
	long_desc = function(self, eff) return ("질병 감염 : 힘 -%d / 매 턴마다 황폐 피해 %0.2f"):format(eff.str, eff.dam) end,
	type = "magical",
	subtype = {disease=true, blight=true},
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target1# 약화성 질병에 감염되었습니다!" end,
	on_lose = function(self, err) return "#Target1# 약화성 질병으로부터 회복되었습니다." end,
	-- Damage each turn
	on_timeout = function(self, eff)
		if self:attr("purify_disease") then self:heal(eff.dam)
		else DamageType:get(DamageType.BLIGHT).projector(eff.src, self.x, self.y, DamageType.BLIGHT, eff.dam, {from_disease=true})
		end
	end,
	-- Lost of CON
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("inc_stats", {[Stats.STAT_STR] = -eff.str})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_stats", eff.tmpid)
	end,
}

newEffect{
	name = "EPIDEMIC", image = "talents/epidemic.png",
	desc = "Epidemic",
	kr_display_name = "유행성 질병",
	long_desc = function(self, eff) return ("질병 감염 : 매 턴마다 황폐 피해 %0.2f / 치유 증가율 -%d%%\n질병 이외의 황폐 피해시 질병 확산"):format(eff.dam, eff.heal_factor) end,
	type = "magical",
	subtype = {disease=true, blight=true},
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target1# 유행성 질병에 감염되었습니다!" end,
	on_lose = function(self, err) return "#Target1# 유행성 질병으로부터 회복되었습니다." end,
	-- Damage each turn
	on_timeout = function(self, eff)
		if self:attr("purify_disease") then self:heal(eff.dam)
		else DamageType:get(DamageType.BLIGHT).projector(eff.src, self.x, self.y, DamageType.BLIGHT, eff.dam, {from_disease=true})
		end
	end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("diseases_spread_on_blight", 1)
		eff.healid = self:addTemporaryValue("healing_factor", -eff.heal_factor / 100)
		eff.immid = self:addTemporaryValue("disease_immune", -eff.resist / 100)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("diseases_spread_on_blight", eff.tmpid)
		self:removeTemporaryValue("healing_factor", eff.healid)
		self:removeTemporaryValue("disease_immune", eff.immid)
	end,
}

newEffect{
	name = "WORM_ROT", image = "talents/worm_rot.png",
	desc = "Worm Rot",
	kr_display_name = "부패 벌레",
	long_desc = function(self, eff) return ("부패 벌레에게 감염 : 매 턴마다 좋은 물리적 상태 효과 한가지 제거 / 매 턴마다 황폐 피해 %0.2f / 매 턴마다 산성 피해 %0.2f\n5턴 이후: 황폐 피해 %0.2f / 부패 벌레가 변태하여 '썩은 고기를 먹는 벌레 덩어리' 생성"):format(eff.dam, eff.dam, eff.burst) end, --@@ 변수 조정
	type = "magical",
	subtype = {disease=true, blight=true, acid=true},
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target1# 끔찍한 부패 벌레에게 감염되었습니다!" end,
	on_lose = function(self, err) return "#Target1# 부패 벌레로부터 회복되었습니다." end,
	-- Damage each turn
	on_timeout = function(self, eff)
		eff.rot_timer = eff.rot_timer - 1

		-- disease damage
		if self:attr("purify_disease") then
			self:heal(eff.dam)
		else
			DamageType:get(DamageType.BLIGHT).projector(eff.src, self.x, self.y, DamageType.BLIGHT, eff.dam, {from_disease=true})
		end
		-- acid damage from the larvae
		DamageType:get(DamageType.ACID).projector(eff.src, self.x, self.y, DamageType.ACID, eff.dam)

		local effs = {}
		-- Go through all physical effects
		for eff_id, p in pairs(self.tmp) do
			local e = self.tempeffect_def[eff_id]
			if e.status == "beneficial" and e.type == "physical" then
				effs[#effs+1] = {"effect", eff_id}
			end
		end
		-- remove a random physical effect
		if #effs > 0 then
			local eff = rng.tableRemove(effs)
			if eff[1] == "effect" then
				self:removeEffect(eff[2])
			end
		end

		-- burst and spawn a worm mass
		if eff.rot_timer == 0 then
			DamageType:get(DamageType.BLIGHT).projector(eff.src, self.x, self.y, DamageType.BLIGHT, eff.burst, {from_disease=true})
			local t = eff.src:getTalentFromId(eff.src.T_WORM_ROT)
			t.spawn_carrion_worm(eff.src, self, t)
			game.logSeen(self, "#LIGHT_RED#'썩은 고기를 먹는 벌레 덩어리'가 %s부터 퍼져 나옵니다!", (self.kr_display_name or self.name):capitalize():addJosa("로"))
			self:removeEffect(self.EFF_WORM_ROT)
		end
	end,
}

newEffect{
	name = "GHOUL_ROT", image = "talents/gnaw.png",
	desc = "Ghoul Rot",
	kr_display_name = "구울의 부패",
	long_desc = function(self, eff)
		local ghoulify = ""
		if eff.make_ghoul > 0 then ghoulify = "\n구울의 부패에 감염된 존재 사망시, 구울이 됨" end
		return ("질병 감염 : 힘 -%d / 민첩 -%d / 체격 -%d / 매 턴마다 황폐 피해 %0.2f%s"):format(eff.str, eff.dex, eff.con, eff.dam, ghoulify)
	end,
	type = "magical",
	subtype = {disease=true, blight=true},
	status = "detrimental",
	parameters = {str = 0, con = 0, dex = 0, make_ghoul = 0},
	on_gain = function(self, err) return "#Target1# 구울의 부패에 감염되었습니다!" end,
	on_lose = function(self, err) return "#Target1# 구울의 부패로부터 회복되었습니다." end,
	-- Damage each turn
	on_timeout = function(self, eff)
		if self:attr("purify_disease") then self:heal(eff.dam)
		else DamageType:get(DamageType.BLIGHT).projector(eff.src, self.x, self.y, DamageType.BLIGHT, eff.dam, {from_disease=true})
		end
	end,
	-- Lost of CON
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("inc_stats", {[Stats.STAT_STR] = -eff.str, [Stats.STAT_DEX] = -eff.dex, [Stats.STAT_CON] = -eff.con})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_stats", eff.tmpid)
	end,
}

newEffect{
	name = "BLOODCASTING", image = "talents/bloodcasting.png",
	desc = "Bloodcasting",
	kr_display_name = "피의 주문",
	long_desc = function(self, eff) return ("타락 기술 사용할 때 원기 부족시, 생명력으로 대체") end,
	type = "magical",
	subtype = {corruption=true},
	status = "beneficial",
	parameters = {},
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("bloodcasting", 1)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("bloodcasting", eff.tmpid)
	end,
}

newEffect{
	name = "ARCANE_SUPREMACY", image = "talents/arcane_supremacy.png",
	desc = "Arcane Supremacy",
	kr_display_name = "지고의 마법",
	long_desc = function(self, eff) return ("주문력 +%d / 주문내성 +%d"):format(eff.power, eff.power) end, --@@ 변수 조정
	type = "magical",
	subtype = { arcane=true },
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target#에게로 마법 에너지가 쇄도합니다.", "+지고의 마법" end,
	on_lose = function(self, err) return "#Target# 주변의 마법 에너지가 흩어졌습니다.", "-지고의 마법" end,
	activate = function(self, eff)
		eff.spell_save = self:addTemporaryValue("combat_spellresist", eff.power)
		eff.spell_power = self:addTemporaryValue("combat_spellpower", eff.power)
		eff.particle = self:addParticles(Particles.new("arcane_power", 1))
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_spellpower", eff.spell_power)
		self:removeTemporaryValue("combat_spellresist", eff.spell_save)
		self:removeParticles(eff.particle)
	end,
}

newEffect{
	name = "WARD", image = "talents/ward.png",
	desc = "Ward",
	kr_display_name = "보호",
	long_desc = function(self, eff) return ("%s 피해 %d 흡수"):format(DamageType.dam_def[eff.d_type].name, #eff.particles) end, --@@ 변수 조정
	type = "magical",
	subtype = { arcane=true },
	status = "beneficial",
	parameters = { nb=3 },
	on_gain = function(self, eff) return ("#Target1# %s부터 보호받습니다!"):format((DamageType.dam_def[eff.d_type].kr_display_name or DamageType.dam_def[eff.d_type].name):addJosa("로")), "+보호" end,
	on_lose = function(self, eff) return ("#Target#의 %s 보호가 사라졌습니다."):format(DamageType.dam_def[eff.d_type].kr_display_name or DamageType.dam_def[eff.d_type].name), "-보호" end,
	absorb = function(type, dam, eff, self, src)
		if eff.d_type ~= type then return dam end
		game.logPlayer(self, "%s 보호가 피해를 흡수했습니다!", (DamageType.dam_def[eff.d_type].kr_display_name or DamageType.dam_def[eff.d_type].name):capitalize())
		local pid = table.remove(eff.particles)
		if pid then self:removeParticles(pid) end
		if #eff.particles <= 0 then
			--eff.dur = 0
			self:removeEffect(self.EFF_WARD)
		end
		return 0
	end,
	activate = function(self, eff)
		local nb = eff.nb
		local ps = {}
		for i = 1, nb do ps[#ps+1] = self:addParticles(Particles.new("ward", 1, {color=DamageType.dam_def[eff.d_type].color})) end
		eff.particles = ps
	end,
	deactivate = function(self, eff)
		for i, particle in ipairs(eff.particles) do self:removeParticles(particle) end
	end,
}

newEffect{
	name = "SPELLSURGE", image = "talents/gather_the_threads.png",
	desc = "Spellsurge",
	kr_display_name = "쇄도하는 주문",
	long_desc = function(self, eff) return ("주문력 +%d"):
	format(eff.cur_power or eff.power) end,
	type = "magical",
	subtype = { arcane=true },
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target#에게로 마법의 힘이 쇄도합니다.", "+쇄도하는 주문" end,
	on_lose = function(self, err) return "#Target#에게 더이상 마법의 힘이 쇄도하지 않습니다.", "-쇄도하는 주문" end,
	on_merge = function(self, old_eff, new_eff)
		self:removeTemporaryValue("combat_spellpower", old_eff.tmpid)
		old_eff.cur_power = math.min(old_eff.cur_power + new_eff.power, new_eff.max)
		old_eff.tmpid = self:addTemporaryValue("combat_spellpower", old_eff.cur_power)

		old_eff.dur = new_eff.dur
		return old_eff
	end,
	activate = function(self, eff)
		eff.cur_power = eff.power
		eff.tmpid = self:addTemporaryValue("combat_spellpower", eff.power)
		eff.particle = self:addParticles(Particles.new("arcane_power", 1))
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_spellpower", eff.tmpid)
		self:removeParticles(eff.particle)
	end,
}

newEffect{
	name = "OUT_OF_PHASE", image = "talents/phase_door.png",
	desc = "Out of Phase",
	kr_display_name = "탈상",
	long_desc = function(self, eff) return ("현실 밖으로 위상변화 : 회피도 +%d / 모든 피해 저항 +%d%% / 모든 상태효과 지속시간 +%d%%"):
	format(eff.defense or 0, eff.resists or 0, eff.effect_reduction or 0) end,
	type = "magical",
	subtype = { teleport=true },
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target1# 현실 밖으로 벗어납니다.", "+탈상" end,
	on_lose = function(self, err) return "#Target1# 현실로 돌아왔습니다.", "-탈상" end,
	activate = function(self, eff)
		eff.defid = self:addTemporaryValue("combat_def", eff.defense)
		eff.resid= self:addTemporaryValue("resists", {all=eff.resists})
		eff.durid = self:addTemporaryValue("reduce_status_effects_time", eff.effect_reduction)
		eff.particle = self:addParticles(Particles.new("phantasm_shield", 1))
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_def", eff.defid)
		self:removeTemporaryValue("resists", eff.resid)
		self:removeTemporaryValue("reduce_status_effects_time", eff.durid)
		self:removeParticles(eff.particle)
	end,
}

newEffect{
	name = "BLOOD_LOCK", image = "talents/blood_lock.png",
	desc = "Blood Lock",
	kr_display_name = "피의 고정",
	long_desc = function(self, eff) return ("생명력이 %d 이상으로 오르지 않음"):format(eff.power) end,
	type = "magical",
	subtype = { blood=true },
	status = "detrimental",
	parameters = { },
	on_gain = function(self, err) return "#Target#의 피가 고정되었습니다.", "+피의 고정" end,
	on_lose = function(self, err) return "#Target#의 피가 더이상 고정되지 않습니다.", "-피의 고정" end,
	activate = function(self, eff)
		eff.power = self.life
		eff.tmpid = self:addTemporaryValue("blood_lock", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("blood_lock", eff.tmpid)
	end,
}

newEffect{
	name = "CONGEAL_TIME", image = "talents/congeal_time.png",
	desc = "Congeal Time",
	kr_display_name = "얼어붙은 시간",
	long_desc = function(self, eff) return ("모든 행동 속도 -%d%% / 대상이 생성한 모든 발사체 속도 -%d%%"):format(eff.slow * 100, eff.proj) end,
	type = "magical",
	subtype = { temporal=true, slow=true },
	status = "detrimental",
	parameters = { slow=0.1, proj=15 },
	on_gain = function(self, err) return "#Target1# 느려졌습니다.", "+얼어붙은 시간" end,
	on_lose = function(self, err) return "#Target1# 빨라졌습니다.", "-얼어붙은 시간" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("global_speed_add", -eff.slow)
		eff.prjid = self:addTemporaryValue("slow_projectiles_outgoing", eff.proj)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("global_speed_add", eff.tmpid)
		self:removeTemporaryValue("slow_projectiles_outgoing", eff.prjid)
	end,
}

newEffect{
	name = "ARCANE_VORTEX", image = "talents/arcane_vortex.png",
	desc = "Arcane Vortex",
	kr_display_name = "마법의 소용돌이",
	long_desc = function(self, eff) return ("마법의 소용돌이 : 매 턴마다 임의의 적에게 마나를 분출하여 마법 피해 %0.2f (주변에 적이 없다면 대상에게 마법 피해 150%%) / 대상이 죽으면 잔여 피해량이 2칸 반경으로 마법 폭발"):format(eff.dam) end,
	type = "magical",
	subtype = { arcane=true },
	status = "detrimental",
	parameters = { dam=10 },
	on_gain = function(self, err) return "마법의 소용돌이가 #Target#에게 휘몰아칩니다!.", "+마법의 소용돌이" end,
	on_lose = function(self, err) return "#Target1# 마법의 소용돌이로부터 벗어났습니다.", "-마법의 소용돌이" end,
	on_timeout = function(self, eff)
		local l = {}
		self:project({type="ball", x=self.x, y=self.y, radius=7, selffire=false}, self.x, self.y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if target and target ~= self and eff.src:reactionToward(target) < 0 then l[#l+1] = target end
		end)

		if #l == 0 then
			DamageType:get(DamageType.ARCANE).projector(eff.src, self.x, self.y, DamageType.ARCANE, eff.dam * 1.5)
		else
			DamageType:get(DamageType.ARCANE).projector(eff.src, self.x, self.y, DamageType.ARCANE, eff.dam)
			local act = rng.table(l)
			eff.src:project({type="beam", x=self.x, y=self.y}, act.x, act.y, DamageType.ARCANE, eff.dam, nil)
			game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(act.x-self.x), math.abs(act.y-self.y)), "mana_beam", {tx=act.x-self.x, ty=act.y-self.y})
		end

		game:playSoundNear(self, "talents/arcane")
	end,
	on_die = function(self, eff)
		local tg = {type="ball", radius=2, selffire=false, x=self.x, y=self.y}
		eff.src:project(tg, self.x, self.y, DamageType.ARCANE, eff.dam * eff.dur)
		if core.shader.active(4) then
			game.level.map:particleEmitter(self.x, self.y, 2, "shader_ring", {radius=4, life=12}, {type="sparks", zoom=1, time_factor=400, hide_center=0, color1={0.6, 0.3, 0.8, 1}, color2={0.8, 0, 0.8, 1}})
		else
			game.level.map:particleEmitter(self.x, self.y, 2, "generic_ball", {rm=150, rM=180, gm=20, gM=60, bm=180, bM=200, am=80, aM=150, radius=2})
		end
	end,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("arcane_vortex", 1))
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
	end,
}

newEffect{
	name = "AETHER_BREACH", image = "talents/aether_breach.png",
	desc = "Aether Breach",
	kr_display_name = "에테르 파괴",
	long_desc = function(self, eff) return ("매 턴마다 마법 피해를 %0.2f 만큼 주는 1칸 반경의 폭발 발생"):format(eff.dam) end,
	type = "magical",
	subtype = { arcane=true },
	status = "beneficial",
	parameters = { dam=10 },
	on_timeout = function(self, eff)
		if game.zone.short_name.."-"..game.level.level ~= eff.level then return end

		local spot = rng.table(eff.list)
		if not spot or not spot.x then return end

		self:project({type="ball", x=spot.x, y=spot.y, radius=2, selffire=self:spellFriendlyFire()}, spot.x, spot.y, DamageType.ARCANE, eff.dam)
		if core.shader.active(4) then
			game.level.map:particleEmitter(spot.x, spot.y, 2, "shader_ring", {radius=4, life=12}, {type="sparks", zoom=1, time_factor=400, hide_center=0, color1={0.6, 0.3, 0.8, 1}, color2={0.8, 0, 0.8, 1}})
		else
			game.level.map:particleEmitter(spot.x, spot.y, 2, "generic_ball", {rm=150, rM=180, gm=20, gM=60, bm=180, bM=200, am=80, aM=150, radius=2})
		end

		game:playSoundNear(self, "talents/arcane")
	end,
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "AETHER_AVATAR", image = "talents/aether_avatar.png",
	desc = "Aether Avatar",
	kr_display_name = "에테르의 화신",
	long_desc = function(self, eff) return ("순수한 에테르의 힘이 가득 차오릅니다!") end,
	type = "magical",
	subtype = { arcane=true },
	status = "beneficial",
	parameters = { },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "inc_damage", {[DamageType.ARCANE]=25})
		self:effectTemporaryValue(eff, "max_mana", self:getMaxMana() * 0.33)
		self:effectTemporaryValue(eff, "use_only_arcane", (self:isTalentActive(self.T_PURE_AETHER) and self:getTalentLevel(self.T_PURE_AETHER) >= 5) and 2 or 1)
		self:effectTemporaryValue(eff, "arcane_cooldown_divide", 3)

		if not self.shader then
			eff.set_shader = true
			self.shader = "shadow_simulacrum"
			self.shader_args = { color = {0.5, 0.1, 0.8}, base = 0.5, time_factor = 500 }
			self:removeAllMOs()
			game.level.map:updateMap(self.x, self.y)
		end
	end,
	deactivate = function(self, eff)
		if eff.set_shader then
			self.shader = nil
			self:removeAllMOs()
			game.level.map:updateMap(self.x, self.y)
		end
	end,
}

newEffect{
	name = "ELEMENTAL_SURGE_ARCANE", image = "talents/elemental_surge.png",
	desc = "Elemental Surge: Arcane",
	kr_display_name = "속성 고조: 마법",
	long_desc = function(self, eff) return ("주문 시전속도 +20%") end,
	type = "magical",
	subtype = { arcane=true },
	status = "beneficial",
	parameters = { },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "combat_spellspeed", 0.2)
	end,
}

newEffect{
	name = "ELEMENTAL_SURGE_COLD", image = "talents/elemental_surge.png",
	desc = "Elemental Surge: Cold",
	kr_display_name = "속성 고조: 냉기",
	long_desc = function(self, eff) return ("근접 공격을 당할 경우: 물리 피해 -30% / 공격자에게 얼어붙은 냉기 피해 100") end,
	type = "magical",
	subtype = { arcane=true },
	status = "beneficial",
	parameters = { },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "resists", {[DamageType.PHYSICAL]=30})
		self:effectTemporaryValue(eff, "on_melee_hit", {[DamageType.ICE]=100})
	end,
}

newEffect{
	name = "ELEMENTAL_SURGE_LIGHTNING", image = "talents/elemental_surge.png",
	desc = "Elemental Surge: Lightning",
	kr_display_name = "속성 고조: 전기",
	long_desc = function(self, eff) return ("공격을 당하면 순수한 번개로 변신하여 다른 장소로 순간이동 (피해 무시)") end,
	type = "magical",
	subtype = { arcane=true },
	status = "beneficial",
	parameters = { },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "phase_shift", 1)
	end,
}

newEffect{
	name = "VULNERABILITY_POISON", image = "talents/vulnerability_poison.png",
	desc = "Vulnerability Poison",
	kr_display_name = "약화형 독",
	long_desc = function(self, eff) return ("중독 : 매 턴마다 마법 피해 %0.2f / 모든 피해 저항 -%d%%"):format(eff.power, eff.res) end,
	type = "magical",
	subtype = { poison=true, arcane=true },
	status = "detrimental",
	parameters = {power=10, res=15},
	on_gain = function(self, err) return "#Target1# 중독되었습니다!", "+약화형 독" end,
	on_lose = function(self, err) return "#Target1# 중독으로부터 회복되었습니다.", "-약화형 독" end,
	-- Damage each turn
	on_timeout = function(self, eff)
		if self:attr("purify_poison") then self:heal(eff.power)
		else DamageType:get(DamageType.ARCANE).projector(eff.src, self.x, self.y, DamageType.ARCANE, eff.power)
		end
	end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("resists", {all=-eff.res})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("resists", eff.tmpid)
	end,
}

newEffect{
	name = "IRRESISTIBLE_SUN", image = "talents/irresistible_sun.png",
	desc = "Irresistible Sun",
	kr_display_name = "저항할 수 없는 태양의 힘",
	long_desc = function(self, eff) return ("주변의 모두에게 : 끌어당김 / 매 턴마다 화염 피해 / 매 턴마다 빛 피해 / 매 턴마다 물리 피해"):format() end,
	type = "magical",
	subtype = { sun=true },
	status = "beneficial",
	parameters = {dam=100},
	on_gain = function(self, err) return "#Target1# 주변의 모든 존재를 끌어당깁니다!", "+저항할 수 없는 태양의 힘" end,
	on_lose = function(self, err) return "#Target1# 더이상 존재들을 당겨오지 못합니다.", "-저항할 수 없는 태양의 힘" end,
	on_timeout = function(self, eff)
		local tgts = {}
		self:project({type="ball", range=0, friendlyfire=false, radius=5}, self.x, self.y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end
			if not tgts[target] then
				tgts[target] = true
				local ox, oy = target.x, target.y
				target:pull(self.x, self.y, 1)
				if target.x ~= ox or target.y ~= oy then 
					game.logSeen(target, "%s 끌려갑니다!", (target.kr_display_name or target.name):capitalize():addJosa("가")) 
				end

				if self:reactionToward(target) < 0 then
					local dam = eff.dam * (1 + (5 - core.fov.distance(self.x, self.y, target.x, target.y)) / 5)
					DamageType:get(DamageType.FIRE).projector(self, target.x, target.y, DamageType.FIRE, dam/3)
					DamageType:get(DamageType.LIGHT).projector(self, target.x, target.y, DamageType.LIGHT, dam/3)
					DamageType:get(DamageType.PHYSICAL).projector(self, target.x, target.y, DamageType.PHYSICAL, dam/3)
				end
			end
		end)
	end,
}

newEffect{
	name = "TEMPORAL_FORM", image = "talents/temporal_form.png",
	desc = "Temporal Form",
	kr_display_name = "시간의 모습",
	long_desc = function(self, eff) return ("텔루고로스로 변신"):format() end,
	type = "magical",
	subtype = { temporal=true },
	status = "beneficial",
	parameters = {},
	on_gain = function(self, err) return "#Target1# 시간의 흐름을 모아 껍질을 만듭니다!", "+시간의 모습" end,
	on_lose = function(self, err) return "더이상 시간이 #Target2# 감싸주지 않습니다.", "-시간의 모습" end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "all_damage_convert", DamageType.TEMPORAL)
		self:effectTemporaryValue(eff, "all_damage_convert_percent", 100)
		self:effectTemporaryValue(eff, "stun_immune", 1)
		self:effectTemporaryValue(eff, "pin_immune", 1)
		self:effectTemporaryValue(eff, "cut_immune", 1)
		self:effectTemporaryValue(eff, "blind_immune", 1)

		local highest = self.inc_damage.all or 0
		for kind, v in pairs(self.inc_damage) do
			if kind ~= "all" then
				local inc = (self.inc_damage.all or 0) + v
				highest = math.max(highest, inc)
			end
		end
		self:effectTemporaryValue(eff, "inc_damage", {[DamageType.TEMPORAL] = 30 + highest - (self.inc_damage[DamageType.TEMPORAL] or 0) - (self.inc_damage.all or 0)})
		self:effectTemporaryValue(eff, "resists", {[DamageType.TEMPORAL] = 30})
		self:effectTemporaryValue(eff, "resists_pen", {[DamageType.TEMPORAL] = 20})
		self:effectTemporaryValue(eff, "talent_cd_reduction", {[self.T_ANOMALY_REARRANGE] = -4, [self.T_ANOMALY_TEMPORAL_STORM] = -4})
		self:learnTalent(self.T_ANOMALY_REARRANGE, true)
		self:learnTalent(self.T_ANOMALY_TEMPORAL_STORM, true)
		self:incParadox(600)

		self.replace_display = mod.class.Actor.new{
			image = "npc/elemental_temporal_telugoroth.png",
			shader = "shadow_simulacrum",
			shader_args = { color = {0.2, 0.1, 0.8}, base = 0.5, time_factor = 500 },
		}
		self:removeAllMOs()
		game.level.map:updateMap(self.x, self.y)
	end,
	deactivate = function(self, eff)
		self:incParadox(-600)
		self:unlearnTalent(self.T_ANOMALY_REARRANGE)
		self:unlearnTalent(self.T_ANOMALY_TEMPORAL_STORM)
		self.replace_display = nil
		self:removeAllMOs()
		game.level.map:updateMap(self.x, self.y)
	end,
}

newEffect{
	name = "CORRUPT_LOSGOROTH_FORM", image = "shockbolt/npc/elemental_void_losgoroth_corrupted.png",
	desc = "Corrupted Losgoroth Form",
	kr_display_name = "타락한 로스고로스 변신",
	long_desc = function(self, eff) return ("타락한 로스고로스로 변신"):format() end,
	type = "magical",
	subtype = { blight=true, arcane=true },
	status = "beneficial",
	parameters = {},
	on_gain = function(self, err) return "#Target1# 로스고로스로 변신합니다!", "+타락한 로스고로스 변신" end,
	on_lose = function(self, err) return "#Target#의 변신이 풀렸습니다.", "-타락한 로스고로스 변신" end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "all_damage_convert", DamageType.DRAINLIFE)
		self:effectTemporaryValue(eff, "all_damage_convert_percent", 50)
		self:effectTemporaryValue(eff, "no_breath", 1)
		self:effectTemporaryValue(eff, "poison_immune", 1)
		self:effectTemporaryValue(eff, "disease_immune", 1)
		self:effectTemporaryValue(eff, "cut_immune", 1)
		self:effectTemporaryValue(eff, "confusion_immune", 1)

		self.replace_display = mod.class.Actor.new{
			image = "npc/elemental_void_losgoroth_corrupted.png",
		}
		self:removeAllMOs()
		game.level.map:updateMap(self.x, self.y)

		eff.particle = self:addParticles(Particles.new("blight_power", 1, {density=4}))
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
		self.replace_display = nil
		self:removeAllMOs()
		game.level.map:updateMap(self.x, self.y)
	end,
}

newEffect{
	name = "SHIVGOROTH_FORM", image = "talents/shivgoroth_form.png",
	desc = "Shivgoroth Form",
	kr_display_name = "쉬브고로스 변신",
	long_desc = function(self, eff) return ("쉬브고로스로 변신"):format() end,
	type = "magical",
	subtype = { ice=true },
	status = "beneficial",
	parameters = {},
	on_gain = function(self, err) return "#Target1# 쉬브고로스로 변신합니다!", "+쉬브고로스 변신" end,
	on_lose = function(self, err) return "#Target#의 변신이 풀렸습니다.", "-쉬브고로스 변신" end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "damage_affinity", {[DamageType.COLD]=50 + 100 * eff.power})
		self:effectTemporaryValue(eff, "resists", {[DamageType.COLD]=100 * eff.power / 2})
		self:effectTemporaryValue(eff, "no_breath", 1)
		self:effectTemporaryValue(eff, "cut_immune", eff.power)
		self:effectTemporaryValue(eff, "stun_immune", eff.power)

		if self.hotkey then
			local pos = self:isHotkeyBound("talent", self.T_SHIVGOROTH_FORM)
			if pos then
				self.hotkey[pos] = {"talent", self.T_ICE_STORM}
			end
		end

		local ohk = self.hotkey
		self.hotkey = nil -- Prevent assigning hotkey, we just did
		self:learnTalent(self.T_ICE_STORM, true, eff.lvl)
		self.hotkey = ohk

		self.replace_display = mod.class.Actor.new{
			image="invis.png", add_mos = {{image = "npc/elemental_ice_greater_shivgoroth.png", display_y = -1, display_h = 2}},
		}
		self:removeAllMOs()
		game.level.map:updateMap(self.x, self.y)
	end,
	deactivate = function(self, eff)
		if self.hotkey then
			local pos = self:isHotkeyBound("talent", self.T_ICE_STORM)
			if pos then
				self.hotkey[pos] = {"talent", self.T_SHIVGOROTH_FORM}
			end
		end

		self:unlearnTalent(self.T_ICE_STORM, eff.lvl)
		self.replace_display = nil
		self:removeAllMOs()
		game.level.map:updateMap(self.x, self.y)
	end,
}

newEffect{
	name = "KEEPER_OF_REALITY", image = "effects/continuum_destabilization.png",
	desc = "Keepers of Reality Rally Call",
	kr_display_name = "현실 감시원의 집회",
	long_desc = function(self, eff) return "영점 수호를 위한 현실 감시원 집회 : 최대 생명력 +5000 / 공격시 피해량 +300%." end,
	type = "magical",
	decrease = 0,
	subtype = { temporal=true },
	status = "beneficial",
	cancel_on_level_change = true,
	parameters = { },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "max_life", 5000)
		self:heal(5000)
		self:effectTemporaryValue(eff, "inc_damage", {all=300})
	end,
	deactivate = function(self, eff)
		self:heal(1)
	end,
}
