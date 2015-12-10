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

require "engine.krtrUtils"

local Stats = require "engine.interface.ActorStats"
local Particles = require "engine.Particles"
local Shader = require "engine.Shader"
local Entity = require "engine.Entity"
local Chat = require "engine.Chat"
local Map = require "engine.Map"
local Level = require "engine.Level"

---------- Item specific 
newEffect{
	name = "ITEM_NUMBING_DARKNESS", image = "effects/bane_blinded.png",
	desc = "Numbing Darkness",
	kr_desc = "마비의 어둠",
	long_desc = function(self, eff) return ("희망을 잃음 : 전체 공격력 %d%% 감소."):format(eff.reduce) end,
	type = "magical",
	subtype = { darkness=true,}, no_ct_effect = true,
	status = "detrimental",
	parameters = {power=10, reduce=5},
	on_gain = function(self, err) return "#Target1# 어둠에 의해 약해졌습니다!", "+마비형 독" end, --@ 아래줄과 원래 다름
	on_lose = function(self, err) return "#Target1# 다시 힘을 되찾았습니다.", "-어둠" end, --@ 윗줄과 원래 다름
	on_timeout = function(self, eff)

	end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("numbed", eff.reduce)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("numbed", eff.tmpid)
	end,
}

-- Use a word other than disease because diseases are associated with damage
-- Add dummy power/dam parameters to try to stay in line with other diseases for subtype checks
newEffect{
	name = "ITEM_BLIGHT_ILLNESS", image = "talents/decrepitude_disease.png",
	desc = "Illness",
	kr_desc = "병",
	long_desc = function(self, eff) return ("질병 감염 : 민첩 %d 감소 / 힘 %d 감소 / 체격 %d 감소."):format(eff.reduce, eff.reduce, eff.reduce) end, --@ 변수 조정
	type = "magical",
	subtype = {disease=true, blight=true},
	status = "detrimental",
	parameters = {reduce = 1, dam = 0, power = 0},
	on_gain = function(self, err) return "#Target1# 심하게 병에 걸렸습니다!" end,
	on_lose = function(self, err) return "#Target1# 병으로부터 회복되었습니다." end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("inc_stats", {
			[Stats.STAT_DEX] = -eff.reduce,
			[Stats.STAT_STR] = -eff.reduce,
			[Stats.STAT_CON] = -eff.reduce,
		})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_stats", eff.tmpid)
	end,
}


newEffect{
	name = "ITEM_ACID_CORRODE", image = "talents/acidic_skin.png",
	desc = "Armor Corroded",
	kr_desc = "갑옷 부식",
	long_desc = function(self, eff) return ("산에 적셔짐 : 방어도 %d%% 감소 (#RED#%d#LAST#)."):format(eff.pct*100 or 0, eff.reduce or 0) end,
	type = "magical",
	subtype = { acid=true, sunder=true },
	status = "detrimental",
	parameters = {pct = 0.3},
	on_gain = function(self, err) return "#Target#의 갑옷이 부식되었습니다!" end,
	on_lose = function(self, err) return "#Target#의 갑옷이 재정비 되었습니다." end,
	on_timeout = function(self, eff)
	end,
	activate = function(self, eff)
		local armor = self.combat_armor * eff.pct
		eff.reduce = armor
		self:effectTemporaryValue(eff, "combat_armor", -armor)
	end,
	deactivate = function(self, eff)

	end,
}

newEffect{
	name = "MANASURGE", image = "talents/rune__manasurge.png",
	desc = "Surging mana",
	kr_desc = "마나 쇄도",
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
	kr_desc = "마나 범람",
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
	kr_desc = "석화",
	long_desc = function(self, eff) return "석화 : 큰 피해를 받으면 확률적으로 부서져 즉사 / 물리 저항 +20% / 화염 저항 +80% / 전기 저항 +50%" end,
	type = "magical",
	subtype = { earth=true, stone=true, stun = true},
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
	on_timeout = function(self, eff)
		if eff.dur > 7 then eff.dur = 7 end -- instakilling players is dumb and this is still lethal at 7s
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("stoned", eff.tmpid)
		self:removeTemporaryValue("resists", eff.resistsid)
	end,
}

newEffect{
	name = "ARCANE_STORM", image = "talents/disruption_shield.png",
	desc = "Arcane Storm",
	kr_desc = "마법 폭풍",
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
	kr_desc = "대지의 보호",
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
	kr_desc = "용해된 피부",
	long_desc = function(self, eff) return ("화염 피해 %d%% 감소"):format(eff.power) end,
	type = "magical",
	subtype = { fire=true, earth=true },
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target#의 피부가 용해된 용암으로 변했습니다.", "+용해된 피부" end,
	on_lose = function(self, err) return "#Target#의 피부가 보통의 상태로 되돌아 왔습니다.", "-용해된 피부" end,
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
	kr_desc = "반발성 피부",
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
	kr_desc = "원혼의 기운",
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
	kr_desc = "투명화",
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
		if not self.shader then
			eff.set_shader = true
			self.shader = "invis_edge"
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
	kr_desc = "예리한 감각",
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
	kr_desc = "실명의 맹독",
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
	kr_desc = "혼란의 맹독",
	long_desc = function(self, eff) return ("혼란 : %d%% 확률로 멋대로 행동 / 복잡한 행동 불가능 / 매 턴마다 어둠 피해 %0.2f"):format(eff.power, eff.dam) end,
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
	kr_desc = "과충전된 골렘",
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
		if core.shader.active(4) then
			eff.particle1 = self:addParticles(Particles.new("shader_shield", 1, {toback=true,  size_factor=1.5, y=-0.3, img="healarcane"}, {type="healing", time_factor=4000, noup=2.0, beamColor1={0x8e/255, 0x2f/255, 0xbb/255, 1}, beamColor2={0xe7/255, 0x39/255, 0xde/255, 1}, circleColor={0,0,0,0}, beamsCount=5}))
			eff.particle2 = self:addParticles(Particles.new("shader_shield", 1, {toback=false, size_factor=1.5, y=-0.3, img="healarcane"}, {type="healing", time_factor=4000, noup=1.0, beamColor1={0x8e/255, 0x2f/255, 0xbb/255, 1}, beamColor2={0xe7/255, 0x39/255, 0xde/255, 1}, circleColor={0,0,0,0}, beamsCount=5}))
		end
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle1)
		self:removeParticles(eff.particle2)
		self:removeTemporaryValue("inc_damage", eff.pid)
		self:removeTemporaryValue("life_regen", eff.lid)
	end,
}

newEffect{
	name = "POWER_OVERLOAD",
	desc = "Power Overload",
	kr_desc = "넘치는 힘",
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
	kr_desc = "생명의 힘",
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
	kr_desc = "마법의 눈 사용",
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
	kr_desc = "마법의 눈 부착됨",
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
	kr_desc = "모든 능력치 상승",
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
	kr_desc = "왜곡의 보호막",
	long_desc = function(self, eff) return ("주변 공간 왜곡 : %d%% 확률로, 받은 피해를 %s에게 전가 / 유지되는 동안 피해 %d 흡수 (흡수 한계량 : %d)"):format(eff.chance, eff.target and (eff.target.kr_name or eff.target.name) or "누군가", self.displacement_shield, eff.power) end,
	type = "magical",
	subtype = { teleport=true, shield=true },
	status = "beneficial",
	parameters = { power=10, target=nil, chance=25 },
	on_gain = function(self, err) return "#Target# 주변의 공간 구조가 변화했습니다.", "+왜곡의 보호막" end,
	on_lose = function(self, err) return "#Target# 주변의 공간 구조가 안정되어 평범해졌습니다.", "-왜곡의 보호막" end,
	on_aegis = function(self, eff, aegis)
		self.displacement_shield = self.displacement_shield + eff.power * aegis / 100
		if core.shader.active(4) then
			self:removeParticles(eff.particle)
			eff.particle = self:addParticles(Particles.new("shader_shield", 1, {size_factor=1.3, img="runicshield"}, {type="runicshield", shieldIntensity=0.14, ellipsoidalFactor=1.2, time_factor=4000, bubbleColor={0.5, 1, 0.2, 1.0}, auraColor={0.4, 1, 0.2, 1}}))
		end		
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
		self.displacement_shield = eff.power
		self.displacement_shield_max = eff.power
		self.displacement_shield_chance = eff.chance
		--- Warning there can be only one time shield active at once for an actor
		self.displacement_shield_target = eff.target
		if core.shader.active(4) then
			eff.particle = self:addParticles(Particles.new("shader_shield", 1, {img="shield6"}, {type="shield", shieldIntensity=0.08, horizontalScrollingSpeed=-1.2, time_factor=6000, color={0.5, 1, 0.2}}))
		else
			eff.particle = self:addParticles(Particles.new("displacement_shield", 1))
		end
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
	kr_desc = "피해 보호막",
	long_desc = function(self, eff) return ("마법 보호막 : 유지되는 동안 피해 %d 흡수 (흡수 한계량 : %d)"):format(self.damage_shield_absorb, eff.power) end,
	type = "magical",
	subtype = { arcane=true, shield=true },
	status = "beneficial",
	parameters = { power=100 },
	charges = function(self, eff) return math.ceil(self.damage_shield_absorb) end,
	on_gain = function(self, err) return "보호막이 #Target3# 감쌌습니다.", "+보호막" end,
	on_lose = function(self, err) return "#Target3# 둘러싼 보호막이 사라졌습니다.", "-보호막" end,
	on_aegis = function(self, eff, aegis)
		self.damage_shield_absorb = self.damage_shield_absorb + eff.power * aegis / 100
		if core.shader.active(4) then
			self:removeParticles(eff.particle)
			local bc = {0.4, 0.7, 1.0, 1.0}
			local ac = {0x21/255, 0x9f/255, 0xff/255, 1}
			if eff.color then
				bc = table.clone(eff.color) bc[4] = 1
				ac = table.clone(eff.color) ac[4] = 1
			end
			eff.particle = self:addParticles(Particles.new("shader_shield", 1, {size_factor=1.3, img="runicshield"}, {type="runicshield", shieldIntensity=0.14, ellipsoidalFactor=1.2, time_factor=5000, bubbleColor=bc, auraColor=ac}))
		end		
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
		self:removeEffect(self.EFF_PSI_DAMAGE_SHIELD)
		if self:attr("shield_factor") then eff.power = eff.power * (100 + self:attr("shield_factor")) / 100 end
		if self:attr("shield_dur") then eff.dur = eff.dur + self:attr("shield_dur") end
		eff.tmpid = self:addTemporaryValue("damage_shield", eff.power)
		if eff.reflect then eff.refid = self:addTemporaryValue("damage_shield_reflect", eff.reflect) end
		--- Warning there can be only one time shield active at once for an actor
		self.damage_shield_absorb = eff.power
		self.damage_shield_absorb_max = eff.power
		if core.shader.active(4) then
			eff.particle = self:addParticles(Particles.new("shader_shield", 1, nil, {type="shield", shieldIntensity=0.2, color=eff.color or {0.4, 0.7, 1.0}}))
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
	kr_desc = "고난",
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

-- This only exists to mark a timer for Radiance being consumed
newEffect{
	name = "RADIANCE_DIM", image = "talents/curse_of_vulnerability.png",
	desc = "Radiance Lost",
	kr_desc = "잃어버린 광휘",
	long_desc = function(self, eff) return ("일시적인 광휘 반경 1 감소 : 능력 확장."):format() end,
	type = "other",
	subtype = { radiance=true },
	parameters = { },
	on_gain = function(self, err) return "#Target#의 오러가 흐릿해졌습니다.", "+흐릿해짐" end,
	on_lose = function(self, err) return "#Target1# 새로워진 빛으로 밝게 빛납니다.", "-흐릿해짐" end,
	activate = function(self, eff)
		self:callTalent(self.T_SEARING_SIGHT, "updateParticle")
	end,
	deactivate = function(self, eff)
		self:callTalent(self.T_SEARING_SIGHT, "updateParticle")
	end,
}

newEffect{
	name = "CURSE_VULNERABILITY", image = "talents/curse_of_vulnerability.png",
	desc = "Curse of Vulnerability",
	kr_desc = "약화의 저주",
	long_desc = function(self, eff) return ("저주 : 전체 저항 -%d%%"):format(eff.power) end,
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
	kr_desc = "무기력의 저주",
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
	kr_desc = "무저항의 저주",
	long_desc = function(self, eff) return ("저주 : 회피도 -%d / 모든 내성 -%d"):format(eff.power, eff.power) end, --@ 변수 조정
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
	kr_desc = "죽음의 저주",
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
	kr_desc = "증오의 저주",
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
	kr_desc = "피의 굶주림",
	long_desc = function(self, eff) return ("주문력 +%d"):format(eff.power) end,
	type = "magical",
	subtype = { frenzy=true },
	status = "beneficial",
	parameters = { power=1 },
	on_timeout = function(self, eff)
		if eff.refresh_turn + 10 < game.turn then -- Decay only if it's not refreshed
			eff.power = math.max(0, eff.power*(100-eff.decay)/100)
		end
	end,
	on_merge = function(self, old_eff, new_eff)
		local dur = new_eff.dur
		local max_turn, maxDur = self:callTalent(self.T_BLOODLUST, "getParams")
		local maxSP = max_turn * 6 -- max total sp
		local power = new_eff.power

		if old_eff.last_turn + 10 <= game.turn then -- clear limits every game turn (10 ticks)
			old_eff.used_this_turn = 0
			old_eff.last_turn = game.turn
		end
		if old_eff.used_this_turn >= max_turn then
			dur = 0
			power = 0
		else
			power = math.min(max_turn-old_eff.used_this_turn, power)
			old_eff.power = math.min(old_eff.power + power, maxSP)
			old_eff.used_this_turn = old_eff.used_this_turn + power
		end

		old_eff.decay = 100/maxDur
		old_eff.dur = math.min(old_eff.dur + dur, maxDur)
		old_eff.refresh_turn = game.turn
		return old_eff
	end,
	activate = function(self, eff)
		eff.last_turn = game.turn
		local SPbonus, maxDur = self:callTalent(self.T_BLOODLUST, "getParams")
		eff.used_this_turn = eff.power
		eff.decay = 100/maxDur
		eff.refresh_turn = game.turn
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "ACID_SPLASH", image = "talents/acidic_skin.png",
	desc = "Acid Splash",
	kr_desc = "산성 뒤덮힘",
	long_desc = function(self, eff) return ("산성 뒤덮힘 : 매 턴마다 산성 피해 %0.2f / 방어도 -%d / 정확도 -%d"):format(eff.dam, eff.armor or 0, eff.atk) end,
	type = "magical",
	subtype = { acid=true, sunder=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target1# 산으로 뒤덮혔습니다!" end,
	on_lose = function(self, err) return "#Target3# 뒤덮은 산이 사라졌습니다." end,
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
	kr_desc = "피의 분노",
	long_desc = function(self, eff) return ("피의 분노: 황폐 공격시 피해량 +%d%% / 산성 공격시 피해량 +%d%%"):format(eff.power, eff.power) end, --@ 변수 조정
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
	kr_desc = "불사조의 부활",
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
		if core.shader.active(4) then
			eff.particle1 = self:addParticles(Particles.new("shader_shield", 1, {toback=true,  size_factor=1.5, y=-0.3, img="healarcane"}, {type="healing", time_factor=2000, noup=2.0, beamColor1={0xff/255, 0xd1/255, 0x22/255, 1}, beamColor2={0xfd/255, 0x94/255, 0x3f/255, 1}, circleColor={0,0,0,0}, beamsCount=12}))
			eff.particle2 = self:addParticles(Particles.new("shader_shield", 1, {toback=false, size_factor=1.5, y=-0.3, img="healarcane"}, {type="healing", time_factor=2000, noup=1.0, beamColor1={0xff/255, 0xd1/255, 0x22/255, 1}, beamColor2={0xfd/255, 0x94/255, 0x3f/255, 1}, circleColor={0,0,0,0}, beamsCount=12}))
		end
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle1)
		self:removeParticles(eff.particle2)
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
	kr_desc = "허리케인",
	long_desc = function(self, eff) return ("허리케인 : 자신을 포함한 주변의 모두에게 매 턴마다 전기 피해 %0.2f - %0.2f"):format(eff.dam / 3, eff.dam) end,
	type = "magical",
	subtype = { lightning=true },
	status = "detrimental",
	parameters = { dam=10, radius=2 },
	on_gain = function(self, err) return "#Target1# 허리케인에 갇혔습니다.", "+허리케인" end,
	on_lose = function(self, err) return "#Target3# 감싸던 허리케인이 사라졌습니다.", "-허리케인" end,
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
	kr_desc = "복귀",
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
	kr_desc = "순간이동: 앙골웬",
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
	kr_desc = "시공간이동: 영점",
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
			if actor and actor ~= self then 
				if actor.summoner and actor.summoner == self then
					seen = false
				else
					seen = true
				end
			end
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
	kr_desc = "예감의 보호막",
	long_desc = function(self, eff) return ("%s 피해 %d%% 감소"):format((DamageType:get(eff.damtype).kr_name or DamageType:get(eff.damtype).name), eff.resist) end,
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
	kr_desc = "부식성 벌레",
	long_desc = function(self, eff) return ("부식성 벌레 : 매 턴마다 산성 피해 %0.2f"):format(eff.dam) end,
	type = "magical",
	subtype = { acid=true },
	status = "detrimental",
	parameters = { dam=1, explosion=10 },
	on_gain = function(self, err) return "#Target1# 부식성 벌레에 오염되었습니다.", "+부식성 벌레" end,
	on_lose = function(self, err) return "#Target3# 오염시키던 부식성 벌레가 사라졌습니다.", "-부식성 벌레" end,
	on_timeout = function(self, eff)
		DamageType:get(DamageType.ACID).projector(eff.src or self, self.x, self.y, DamageType.ACID, eff.dam)
	end,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("circle", 1, {base_rot=0, oversize=0.7, a=255, appear=8, speed=0, img="blight_worms", radius=0}))
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
	end,
}

newEffect{
	name = "WRAITHFORM", image = "talents/wraithform.png",
	desc = "Wraithform",
	kr_desc = "악령 변신",
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
		if not self.shader then
			eff.set_shader = true
			self.shader = "moving_transparency"
			self.shader_args = { a_min=0.3, a_max=0.8, time_factor = 3000 }
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
		self:removeTemporaryValue("can_pass", eff.tmpid)
		self:removeTemporaryValue("combat_def", eff.defid)
		self:removeTemporaryValue("combat_armor", eff.armid)
		if not self:canMove(self.x, self.y, true) then
			self:teleportRandom(self.x, self.y, 50)
		end
	end,
}

newEffect{
	name = "EMPOWERED_HEALING", image = "effects/empowered_healing.png",
	desc = "Empowered Healing",
	kr_desc = "향상된 치료",
	long_desc = function(self, eff) return ("치유 효율 +%d%%"):format(eff.power * 100) end,
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
	kr_desc = "빛의 섭리",
	long_desc = function(self, eff) return ("매 턴마다 나쁜 상태이상 효과 한 가지 제거 / 생명력 재생 +%d"):format(eff.power) end,
	type = "magical",
	subtype = { light=true, shield=true },
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
		if core.shader.active(4) then
			eff.particle1 = self:addParticles(Particles.new("shader_shield", 1, {toback=true,  size_factor=1.5, y=-0.3, img="healcelestial"}, {type="healing", time_factor=4000, noup=2.0, beamColor1={0xd8/255, 0xff/255, 0x21/255, 1}, beamColor2={0xf7/255, 0xff/255, 0x9e/255, 1}, circleColor={0,0,0,0}, beamsCount=5}))
			eff.particle2 = self:addParticles(Particles.new("shader_shield", 1, {toback=false, size_factor=1.5, y=-0.3, img="healcelestial"}, {type="healing", time_factor=4000, noup=1.0, beamColor1={0xd8/255, 0xff/255, 0x21/255, 1}, beamColor2={0xf7/255, 0xff/255, 0x9e/255, 1}, circleColor={0,0,0,0}, beamsCount=5}))
		end
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle1)
		self:removeParticles(eff.particle2)
		self:removeTemporaryValue("life_regen", eff.tmpid)
	end,
}

newEffect{
	name = "TOTALITY", image = "talents/totality.png",
	desc = "Totality",
	kr_desc = "개기 일월식",
	long_desc = function(self, eff) return ("빛 저항 관통 +%d%% / 어둠 저항 관통 +%d%%"):format(eff.power, eff.power) end, --@ 변수 조정
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
	kr_desc = "고결함",
	long_desc = function(self, eff) return ("침묵 완전 면역") end,
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
	kr_desc = "흐르는 그림자",
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
	kr_desc = "타오르는 빛",
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
	kr_desc = "보호",
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
	kr_desc = "시간 되돌리기",
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
	kr_desc = "시간 낭비",
	long_desc = function(self, eff) return ("시간 낭비 : 매 턴마다 시간 피해 %0.2f"):format(eff.power) end,
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
	kr_desc = "통찰",
	long_desc = function(self, eff) return ("인식력 최고조 : 은신감지 +%d / 투명감지 +%d / 회피도 +%d / 정확도 +%d"):format(eff.power, eff.power, eff.power, eff.power) end, --@ 변수 조정
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
	kr_desc = "활성화",
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
				if t and not t.fixed_cooldown then
					self.talents_cd[tid] = self.talents_cd[tid] - 1
				end
			end
		end
	end,
	activate = function(self, eff)
		eff.regenid = self:addTemporaryValue("life_regen", eff.power)
		if core.shader.active(4) then
			eff.particle1 = self:addParticles(Particles.new("shader_shield", 1, {toback=true,  size_factor=1.5, y=-0.3, img="healcelestial"}, {type="healing", time_factor=4000, noup=2.0, beamColor1={0xd8/255, 0xff/255, 0x21/255, 1}, beamColor2={0xf7/255, 0xff/255, 0x9e/255, 1}, circleColor={0,0,0,0}, beamsCount=5}))
			eff.particle2 = self:addParticles(Particles.new("shader_shield", 1, {toback=false, size_factor=1.5, y=-0.3, img="healcelestial"}, {type="healing", time_factor=4000, noup=1.0, beamColor1={0xd8/255, 0xff/255, 0x21/255, 1}, beamColor2={0xf7/255, 0xff/255, 0x9e/255, 1}, circleColor={0,0,0,0}, beamsCount=5}))
		end
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle1)
		self:removeParticles(eff.particle2)
		self:removeTemporaryValue("life_regen", eff.regenid)
	end,
}

newEffect{
	name = "GATHER_THE_THREADS", image = "talents/gather_the_threads.png",
	desc = "Gather the Threads",
	kr_desc = "시간의 흐름 - 수집",
	long_desc = function(self, eff) return ("주문력 +%d / 매 턴마다 추가적인 주문력 +%d"):
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
	kr_desc = "잘못된 설계",
	long_desc = function(self, eff) return ("과거의 변경 : 전체 저항 -%d%%"):format(eff.power) end,
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
	kr_desc = "마나 벌레",
	long_desc = function(self, eff) return ("마나 벌레 오염 : 매 턴마다 마나 -%0.2f / 매 턴마다 마법 피해 %0.2f"):format(eff.power, eff.power) end, --@ 변수 조정
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
	kr_desc = "죽지 못하는 자들의 분노",
	long_desc = function(self, eff) return ("공격시 피해량 +%d / 주문력 +%d / 정확도 +%d / 방어도 관통력 +%d / 물리 치명타율 +%d%% / 주문 치명타율 +%d%%"):format(eff.power, eff.power, eff.power, eff.apr, eff.crit, eff.crit) end, --@ 변수 조정
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
	kr_desc = "뼈의 방패",
	long_desc = function(self, eff) return ("현재 생명력의 %d%% 이상 피해 발생시, 피해 -%d%%"):format(eff.power, eff.power) end,
	type = "magical",
	subtype = { arcane=true, shield=true },
	status = "beneficial",
	parameters = { power=30 },
	on_gain = function(self, err) return "#Target1# 부유하는 뼈로 보호되었습니다.", "+뼈의 방패" end,
	on_lose = function(self, err) return "#Target#의 부유하는 뼈가 부서졌습니다.", "-뼈의 방패" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("flat_damage_cap", {all=eff.power})
		if core.shader.active(4) then
			eff.particle = self:addParticles(Particles.new("shader_shield", 1, {size_factor=1.4, img="runicshield"}, {type="runicshield", shieldIntensity=0.2, ellipsoidalFactor=1, scrollingSpeed=1, time_factor=10000, bubbleColor={0.3, 0.3, 0.3, 1.0}, auraColor={0.1, 0.1, 0.1, 1}}))
		else
			eff.particle = self:addParticles(Particles.new("time_shield_bubble", 1))
		end
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("flat_damage_cap", eff.tmpid)
		self:removeParticles(eff.particle)
	end,
}

newEffect{
	name = "REDUX", image = "talents/redux.png",
	desc = "Redux",
	kr_desc = "재현",
	long_desc = function(self, eff) return "다음에 사용하는 시공 기술을 두 번 연속 사용" end,
	type = "magical",
	subtype = { temporal=true },
	status = "beneficial",
	parameters = { max_cd=1},
	activate = function(self, eff)
		if core.shader.allow("adv") then
			eff.particle1, eff.particle2 = self:addParticles3D("volumetric", {kind="transparent_cylinder", twist=1, shineness=10, density=10, radius=1.4, growSpeed=0.004, img="coggy_00"})
		end
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle1)
		self:removeParticles(eff.particle2)
	end,
}

newEffect{
	name = "TEMPORAL_DESTABILIZATION_START", image = "talents/destabilize.png",
	desc = "Temporal Destabilization",
	kr_desc = "시간적 불안정",
	long_desc = function(self, eff) return ("불안정 : %d턴간 매 턴마다 시간 피해 %0.2f / 효과 지속 중 대상이 죽으면 폭발"):format(eff.dur, eff.dam) end,
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
	kr_desc = "시간적 불안정",
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
	name = "CELERITY", image = "talents/celerity.png",
	desc = "Celerity",
	kr_desc = "기민함",
	long_desc = function(self, eff) return ("목표물이  %d%% 만큼 빨라졌습니다."):format(eff.speed * 100 * eff.charges) end,
	type = "magical",
	display_desc = function(self, eff) return eff.charges.." 기민함" end,
	charges = function(self, eff) return eff.charges end,
	subtype = { speed=true, temporal=true },
	status = "beneficial",
	parameters = {speed=0.1, charges=1, max_charges=3},
	on_merge = function(self, old_eff, new_eff)
		-- remove the old value
		self:removeTemporaryValue("movement_speed", old_eff.tmpid)
		
		-- add a charge
		old_eff.charges = math.min(old_eff.charges + 1, new_eff.max_charges)
		
		-- and apply the current values	
		old_eff.tmpid = self:addTemporaryValue("movement_speed", old_eff.speed * old_eff.charges)
		
		old_eff.dur = new_eff.dur
		return old_eff
	end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("movement_speed", eff.speed * eff.charges)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("movement_speed", eff.tmpid)
	end,
}

newEffect{
	name = "TIME_DILATION", image = "talents/time_dilation.png",
	desc = "Time Dilation",
	kr_desc = "시간팽창",
	long_desc = function(self, eff) return ("공격, 주문, 정신공격 등의 속도가 %d%% 만큼 빨라진다."):format(eff.speed * 100 * eff.charges) end,
	type = "magical",
	display_desc = function(self, eff) return eff.charges.." 시간팽창" end,
	charges = function(self, eff) return eff.charges end,
	subtype = { speed=true, temporal=true },
	status = "beneficial",
	parameters = {speed=0.1, charges=1, max_charges=3},
	on_merge = function(self, old_eff, new_eff)
		-- remove the old value
		self:removeTemporaryValue("combat_physspeed", old_eff.physid)
		self:removeTemporaryValue("combat_spellspeed", old_eff.spellid)
		self:removeTemporaryValue("combat_mindspeed", old_eff.mindid)
		
		-- add a charge
		old_eff.charges = math.min(old_eff.charges + 1, new_eff.max_charges)
		
		-- and apply the current values	
		old_eff.physid = self:addTemporaryValue("combat_physspeed", old_eff.speed * old_eff.charges)
		old_eff.spellid = self:addTemporaryValue("combat_spellspeed", old_eff.speed * old_eff.charges)
		old_eff.mindid = self:addTemporaryValue("combat_mindspeed", old_eff.speed * old_eff.charges)
		
		old_eff.dur = new_eff.dur
		return old_eff
	end,
	activate = function(self, eff)
		eff.physid = self:addTemporaryValue("combat_physspeed", eff.speed * eff.charges)
		eff.spellid = self:addTemporaryValue("combat_spellspeed", eff.speed * eff.charges)
		eff.mindid = self:addTemporaryValue("combat_mindspeed", eff.speed * eff.charges)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_physspeed", eff.physid)
		self:removeTemporaryValue("combat_spellspeed", eff.spellid)
		self:removeTemporaryValue("combat_mindspeed", eff.mindid)
	end,
}

newEffect{
	name = "HASTE", image = "talents/haste.png",
	desc = "Haste",
	kr_desc = "가속",
	long_desc = function(self, eff) return ("모든 행동 속도 +%d%%"):format(eff.power * 100) end,
	type = "magical",
	subtype = { temporal=true, speed=true },
	status = "beneficial",
	parameters = { move=0.1, speed=0.1 },
	on_gain = function(self, err) return "#Target1# 빨라졌습니다.", "+가속" end,
	on_lose = function(self, err) return "#Target1# 느려졌습니다.", "-가속" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("global_speed_add", eff.power)
		if not self.shader then
			eff.set_shader = true
			self.shader = "shadow_simulacrum"
			self.shader_args = { color = {0.4, 0.4, 0}, base = 1, time_factor = 3000 }
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
		self:removeTemporaryValue("global_speed_add", eff.tmpid)
		self:removeParticles(eff.particle1)
		self:removeParticles(eff.particle2)
	end,
}

newEffect{
	name = "CEASE_TO_EXIST", image = "talents/cease_to_exist.png",
	desc = "Cease to Exist",
	kr_desc = "중단된 실존",
	long_desc = function(self, eff) return ("시간의 흐름에서 사라짐 : 전체 저항 -%d%%"):format(eff.power) end,
	type = "magical",
	subtype = { temporal=true },
	status = "detrimental",
	parameters = { power = 1, damage=1 },
	on_gain = function(self, err) return "#Target1# 시간의 흐름에서 사라졌습니다.", "+중단된 실존" end,
	activate = function(self, eff)
		eff.phys = self:addTemporaryValue("resists", { [DamageType.PHYSICAL] = -eff.power})
		eff.temp = self:addTemporaryValue("resists", { [DamageType.TEMPORAL] = -eff.power})
	end,
	deactivate = function(self, eff)
		if game._chronoworlds then
			game._chronoworlds = nil
		end
		self:removeTemporaryValue("resists", eff.phys)
		self:removeTemporaryValue("resists", eff.temp)
	end,
}

newEffect{
	name = "IMPENDING_DOOM", image = "talents/impending_doom.png",
	desc = "Impending Doom",
	kr_desc = "임박한 운명",
	long_desc = function(self, eff) return ("임박한 마지막 운명 : 치유 효율 100%% 감소 / 매 턴마다 마법 피해 %0.2f\n대상이 죽으면 효과 중단"):format(eff.dam) end,
	type = "magical",
	subtype = { arcane=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target#의 운명이 임박했습니다!", "+임박한 운명" end,
	on_lose = function(self, err) return "#Target1# 임박한 운명에서 벗어났습니다.", "-임박한 운명" end,
	activate = function(self, eff)
		eff.healid = self:addTemporaryValue("healing_factor", -1)
	end,
	on_timeout = function(self, eff)
		if eff.src.dead or not game.level:hasEntity(eff.src) then return true end
		DamageType:get(DamageType.ARCANE).projector(eff.src, self.x, self.y, DamageType.ARCANE, eff.dam)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("healing_factor", eff.healid)
	end,
}

newEffect{
	name = "RIGOR_MORTIS", image = "talents/rigor_mortis.png",
	desc = "Rigor Mortis",
	kr_desc = "사후 경직",
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
	kr_desc = "심연의 장막",
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
	kr_desc = "실타래",
	long_desc = function(self, eff) return ("목표물의 방어력 및 내성이 %d 만큼 상승한다."):format(eff.save_bonus * eff.spin) end,
	display_desc = function(self, eff) return eff.spin.." 실타래" end,
	charges = function(self, eff) return eff.spin end,
	type = "magical",
	subtype = { temporal=true },
	status = "beneficial",
	parameters = { save_bonus=0, spin=0, max_spin=3},
	on_gain = function(self, err) return "#Target# 운명을 잣습니다", "+Spin Fate" end,
	on_lose = function(self, err) return "#Target# 운명을 잣는 것을 멈춥니다.", "-Spin Fate" end,
	on_merge = function(self, old_eff, new_eff)
		-- remove the four old values
		self:removeTemporaryValue("combat_def", old_eff.defid)
		self:removeTemporaryValue("combat_physresist", old_eff.physid)
		self:removeTemporaryValue("combat_spellresist", old_eff.spellid)
		self:removeTemporaryValue("combat_mentalresist", old_eff.mentalid)
		
		-- add some spin
		old_eff.spin = math.min(old_eff.spin + 1, new_eff.max_spin)
	
		-- and apply the current values
		old_eff.defid = self:addTemporaryValue("combat_def", old_eff.save_bonus * old_eff.spin)
		old_eff.physid = self:addTemporaryValue("combat_physresist", old_eff.save_bonus * old_eff.spin)
		old_eff.spellid = self:addTemporaryValue("combat_spellresist", old_eff.save_bonus * old_eff.spin)
		old_eff.mentalid = self:addTemporaryValue("combat_mentalresist", old_eff.save_bonus * old_eff.spin)

		old_eff.dur = new_eff.dur
		
		return old_eff
	end,
	activate = function(self, eff)
		-- apply current values
		eff.defid = self:addTemporaryValue("combat_def", eff.save_bonus * eff.spin)
		eff.physid = self:addTemporaryValue("combat_physresist", eff.save_bonus * eff.spin)
		eff.spellid = self:addTemporaryValue("combat_spellresist", eff.save_bonus * eff.spin)
		eff.mentalid = self:addTemporaryValue("combat_mentalresist", eff.save_bonus * eff.spin)
		
		if core.shader.allow("adv") then
			eff.particle1, eff.particle2 = self:addParticles3D("volumetric", {kind="conic_cylinder", radius=1.4, base_rotation=180, growSpeed=0.004, img="squares_x3_01"})
		else
			eff.particle1 = self:addParticles(Particles.new("arcane_power", 1))
		end
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_def", eff.defid)
		self:removeTemporaryValue("combat_physresist", eff.physid)
		self:removeTemporaryValue("combat_spellresist", eff.spellid)
		self:removeTemporaryValue("combat_mentalresist", eff.mentalid)
		self:removeParticles(eff.particle1)
		self:removeParticles(eff.particle2)
	end,
}

newEffect{
	name = "SPELLSHOCKED",
	desc = "Spellshocked",
	kr_desc = "주문 충격",
	long_desc = function(self, eff) return string.format("주문에 압도됨 : 전체 저항 -%d%%", eff.power) end,
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
	kr_desc = "부패성 질병",
	long_desc = function(self, eff) return ("질병 감염 : 체격 -%d / 매 턴마다 황폐 피해 %0.2f"):format(eff.con, eff.dam) end,
	type = "magical",
	subtype = {disease=true, blight=true},
	status = "detrimental",
	parameters = {con = 1, dam = 0},
	on_gain = function(self, err) return "#Target1# 부패성 질병에 감염되었습니다!" end,
	on_lose = function(self, err) return "#Target1# 부패성 질병으로부터 회복되었습니다." end,
	-- Damage each turn
	on_timeout = function(self, eff)
		if self:attr("purify_disease") then self:heal(eff.dam, eff.src)
		else if eff.dam > 0 then DamageType:get(DamageType.BLIGHT).projector(eff.src, self.x, self.y, DamageType.BLIGHT, eff.dam, {from_disease=true})
		end end
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
	kr_desc = "노화성 질병",
	long_desc = function(self, eff) return ("질병 감염 : 민첩 -%d / 매 턴마다 황폐 피해 %0.2f"):format(eff.dex, eff.dam) end,
	type = "magical",
	subtype = {disease=true, blight=true},
	status = "detrimental",
	parameters = {dex = 1, dam = 0},
	on_gain = function(self, err) return "#Target1# 노화성 질병에 감염되었습니다!" end,
	on_lose = function(self, err) return "#Target1# 노화성 질병으로부터 회복되었습니다." end,
	-- Damage each turn
	on_timeout = function(self, eff)
		if self:attr("purify_disease") then self:heal(eff.dam, eff.src)
		else if eff.dam > 0 then DamageType:get(DamageType.BLIGHT).projector(eff.src, self.x, self.y, DamageType.BLIGHT, eff.dam, {from_disease=true})
		end end
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
	kr_desc = "약화성 질병",
	long_desc = function(self, eff) return ("질병 감염 : 힘 -%d / 매 턴마다 황폐 피해 %0.2f"):format(eff.str, eff.dam) end,
	type = "magical",
	subtype = {disease=true, blight=true},
	status = "detrimental",
	parameters = {str = 1, dam = 0},
	on_gain = function(self, err) return "#Target1# 약화성 질병에 감염되었습니다!" end,
	on_lose = function(self, err) return "#Target1# 약화성 질병으로부터 회복되었습니다." end,
	-- Damage each turn
	on_timeout = function(self, eff)
		if self:attr("purify_disease") then self:heal(eff.dam, eff.src)
		else if eff.dam > 0 then DamageType:get(DamageType.BLIGHT).projector(eff.src, self.x, self.y, DamageType.BLIGHT, eff.dam, {from_disease=true})
		end end
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
	kr_desc = "유행성 질병",
	long_desc = function(self, eff) return ("질병 감염 : 매 턴마다 황폐 피해 %0.2f / 치유 효율 -%d%%\n질병 이외의 황폐 피해시 질병 확산"):format(eff.dam, eff.heal_factor) end,
	type = "magical",
	subtype = {disease=true, blight=true},
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target1# 유행성 질병에 감염되었습니다!" end,
	on_lose = function(self, err) return "#Target1# 유행성 질병으로부터 회복되었습니다." end,
	-- Damage each turn
	on_timeout = function(self, eff)
		if self:attr("purify_disease") then self:heal(eff.dam, eff.src)
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
	kr_desc = "부패 벌레",
	long_desc = function(self, eff) return ("부패 벌레에게 감염 : 매 턴마다 좋은 물리적 상태 효과 한가지 제거 / 매 턴마다 황폐 피해 %0.2f / 매 턴마다 산성 피해 %0.2f\n5턴 이후: 황폐 피해 %0.2f / 부패 벌레가 변태하여 '썩은 고기를 먹는 벌레 덩어리' 생성"):format(eff.dam, eff.dam, eff.burst) end, --@ 변수 조정
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
			self:heal(eff.dam, eff.src)
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
			game.logSeen(self, "#LIGHT_RED#'썩은 고기를 먹는 벌레 덩어리'가 %s부터 퍼져 나옵니다!", (self.kr_name or self.name):capitalize():addJosa("로"))
			self:removeEffect(self.EFF_WORM_ROT)
		end
	end,
}

newEffect{
	name = "GHOUL_ROT", image = "talents/gnaw.png",
	desc = "Ghoul Rot",
	kr_desc = "구울의 부패",
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
		if self:attr("purify_disease") then self:heal(eff.dam, eff.src)
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
	kr_desc = "피의 주문",
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
	kr_desc = "지고의 마법",
	long_desc = function(self, eff) return ("주문력 +%d / 주문내성 +%d"):format(eff.power, eff.power) end, --@ 변수 조정
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
	kr_desc = "보호",
	long_desc = function(self, eff) return ("%s 피해 %d 흡수"):format((DamageType.dam_def[eff.d_type].kr_name or DamageType.dam_def[eff.d_type].name), #eff.particles) end, --@ 변수 순서 조정, 변수 조정:단수 복수 구분 변수 삭제
	type = "magical",
	subtype = { arcane=true },
	status = "beneficial",
	parameters = { nb=3 },
	on_gain = function(self, eff) return ("#Target1# %s부터 보호받습니다!"):format((DamageType.dam_def[eff.d_type].kr_name or DamageType.dam_def[eff.d_type].name):addJosa("로")), "+보호" end,
	on_lose = function(self, eff) return ("#Target#의 %s 보호가 사라졌습니다."):format(DamageType.dam_def[eff.d_type].kr_name or DamageType.dam_def[eff.d_type].name), "-보호" end,
	absorb = function(type, dam, eff, self, src)
		if eff.d_type ~= type then return dam end
		game.logPlayer(self, "%s 보호가 피해를 흡수했습니다!", (DamageType.dam_def[eff.d_type].kr_name or DamageType.dam_def[eff.d_type].name):capitalize())
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
	kr_desc = "쇄도하는 주문",
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
	kr_desc = "탈상",
	long_desc = function(self, eff) return ("현실 밖으로 위상변화 : 회피도 +%d / 전체 저항 +%d%% / 나쁜 상태이상 지속시간 -%d%%"):
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
		eff.durid = self:addTemporaryValue("reduce_detrimental_status_effects_time", eff.effect_reduction)
		eff.particle = self:addParticles(Particles.new("phantasm_shield", 1))
	end,
	on_merge = function(self, old_eff, new_eff)
		old_eff.defense = math.min(50, math.max(old_eff.defense, new_eff.defense)) or 0
		old_eff.resists = math.min(40, math.max(old_eff.resists, new_eff.resists)) or 0
		old_eff.effect_reduction = math.min(60, math.max(old_eff.effect_reduction, new_eff.effect_reduction)) or 0

		self:removeTemporaryValue("combat_def", old_eff.defid)
		self:removeTemporaryValue("resists", old_eff.resid)
		self:removeTemporaryValue("reduce_detrimental_status_effects_time", old_eff.durid)

		old_eff.defid = self:addTemporaryValue("combat_def", old_eff.defense)
		old_eff.resid= self:addTemporaryValue("resists", {all=old_eff.resists})
		old_eff.durid = self:addTemporaryValue("reduce_detrimental_status_effects_time", old_eff.effect_reduction)
		old_eff.dur = math.max(old_eff.dur, new_eff.dur)
		return old_eff
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_def", eff.defid)
		self:removeTemporaryValue("resists", eff.resid)
		self:removeTemporaryValue("reduce_detrimental_status_effects_time", eff.durid)
		self:removeParticles(eff.particle)
	end,
}

newEffect{
	name = "BLOOD_LOCK", image = "talents/blood_lock.png",
	desc = "Blood Lock",
	kr_desc = "피의 고정",
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
	kr_desc = "얼어붙은 시간",
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
	kr_desc = "마법의 소용돌이",
	long_desc = function(self, eff) return ("마법의 소용돌이 : 매 턴마다 임의의 적에게 마나를 분출하여 마법 피해 %0.2f (주변에 적이 없다면 대상에게 마법 피해 150%%) / 대상이 죽으면 잔여 피해량이 2칸 반경으로 마법 폭발"):format(eff.dam) end,
	type = "magical",
	subtype = { arcane=true },
	status = "detrimental",
	parameters = { dam=10 },
	on_gain = function(self, err) return "마법의 소용돌이가 #Target#에게 휘몰아칩니다!.", "+마법의 소용돌이" end,
	on_lose = function(self, err) return "#Target1# 마법의 소용돌이로부터 벗어났습니다.", "-마법의 소용돌이" end,
	on_timeout = function(self, eff)
		if not self.x then return end
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
	kr_desc = "에테르 파괴",
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
		game.level.map:particleEmitter(spot.x, spot.y, 2, "generic_sploom", {rm=150, rM=180, gm=20, gM=60, bm=180, bM=200, am=80, aM=150, radius=2, basenb=120})

		game:playSoundNear(self, "talents/arcane")
	end,
	activate = function(self, eff)
		eff.particle = Particles.new("circle", eff.radius, {a=150, speed=0.15, img="aether_breach", radius=eff.radius})
		eff.particle.zdepth = 6
		game.level.map:addParticleEmitter(eff.particle, eff.x, eff.y)
	end,
	deactivate = function(self, eff)
		if game.zone.short_name.."-"..game.level.level ~= eff.level then return end
		game.level.map:removeParticleEmitter(eff.particle)
	end,
}

newEffect{
	name = "AETHER_AVATAR", image = "talents/aether_avatar.png",
	desc = "Aether Avatar",
	kr_desc = "에테르의 화신",
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
	kr_desc = "속성 고조: 마법",
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
	kr_desc = "속성 고조: 냉기",
	long_desc = function(self, eff) return ("얼음 피부 : 근접 공격을 당할 경우 물리 피해 -30% / 방어도 +%d / 공격자에게 얼어붙은 냉기 피해 %d"):format(eff.armor, eff.dam) end,
	type = "magical",
	subtype = { arcane=true },
	status = "beneficial",
	parameters = {physresist=30, armor=0, dam=100 },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "resists", {[DamageType.PHYSICAL]=eff.physresist})
		self:effectTemporaryValue(eff, "combat_armor", eff.armor)
		self:effectTemporaryValue(eff, "on_melee_hit", {[DamageType.ICE]=eff.dam})
	end,
}

newEffect{
	name = "ELEMENTAL_SURGE_LIGHTNING", image = "talents/elemental_surge.png",
	desc = "Elemental Surge: Lightning",
	kr_desc = "속성 고조: 전기",
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
	kr_desc = "약화형 독",
	long_desc = function(self, eff) return ("중독 : 매 턴마다 마법 피해 %0.2f / 전체 저항 -%d%%"):format(eff.power, eff.res) end,
	type = "magical",
	subtype = { poison=true, arcane=true },
	status = "detrimental",
	parameters = {power=10, res=15},
	on_gain = function(self, err) return "#Target1# 중독되었습니다!", "+약화형 독" end,
	on_lose = function(self, err) return "#Target1# 중독으로부터 회복되었습니다.", "-약화형 독" end,
	-- Damage each turn
	on_timeout = function(self, eff)
		if self:attr("purify_poison") then self:heal(eff.power, eff.src)
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
	kr_desc = "저항할 수 없는 태양의 힘",
	long_desc = function(self, eff) return ("주변의 모두에게 : 끌어당김 / 매 턴마다 화염 피해 / 매 턴마다 빛 피해 / 매 턴마다 물리 피해"):format() end,
	type = "magical",
	subtype = { sun=true },
	status = "beneficial",
	parameters = {dam=100},
	on_gain = function(self, err) return "#Target1# 주변의 모든 존재를 끌어당깁니다!", "+저항할 수 없는 태양의 힘" end,
	on_lose = function(self, err) return "#Target1# 더이상 존재들을 당겨오지 못합니다.", "-저항할 수 없는 태양의 힘" end,
	activate = function(self, eff)
		local particle = Particles.new("generic_vortex", 5, {rm=230, rM=230, gm=20, gM=250, bm=250, bM=80, am=80, aM=150, radius=5, density=50})
		if core.shader.allow("distort") then particle:setSub("vortex_distort", 5, {radius=5}) end
		eff.particle = self:addParticles(particle)
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
	end,
	on_timeout = function(self, eff)
		local tgts = {}
		self:project({type="ball", range=0, friendlyfire=false, radius=5}, self.x, self.y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end
			if not tgts[target] then
				tgts[target] = true
				if not target:attr("ignore_irresistible_sun") then
					local ox, oy = target.x, target.y
					target:pull(self.x, self.y, 1)
					if target.x ~= ox or target.y ~= oy then 
						game.logSeen(target, "%s 끌려갑니다!", (target.kr_name or target.name):capitalize():addJosa("가"))
					end

					if self:reactionToward(target) < 0 then
						local dam = eff.dam * (1 + (5 - core.fov.distance(self.x, self.y, target.x, target.y)) / 8)
						DamageType:get(DamageType.FIRE).projector(self, target.x, target.y, DamageType.FIRE, dam/3)
						DamageType:get(DamageType.LIGHT).projector(self, target.x, target.y, DamageType.LIGHT, dam/3)
						DamageType:get(DamageType.PHYSICAL).projector(self, target.x, target.y, DamageType.PHYSICAL, dam/3)
					end
				end
			end
		end)
	end,
}

newEffect{
	name = "TEMPORAL_FORM", image = "talents/temporal_form.png",
	desc = "Temporal Form",
	kr_desc = "시간의 모습",
	long_desc = function(self, eff) return ("텔루고로스로 변신"):format() end,
	type = "magical",
	subtype = { temporal=true },
	status = "beneficial",
	parameters = {},
	on_gain = function(self, err) return "#Target1# 시간의 흐름을 모아 껍질을 만듭니다!", "+시간의 모습" end,
	on_lose = function(self, err) return "더이상 시간이 #Target3# 감싸주지 않습니다.", "-시간의 모습" end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "all_damage_convert", DamageType.TEMPORAL)
		self:effectTemporaryValue(eff, "all_damage_convert_percent", 50)
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
		self.auto_highest_inc_damage = self.auto_highest_inc_damage or {}
		self:effectTemporaryValue(eff, "auto_highest_inc_damage", {[DamageType.TEMPORAL] = 30})
		self:effectTemporaryValue(eff, "inc_damage", {[DamageType.TEMPORAL] = 0.00001}) -- 0 so that it shows up in the UI
		self:effectTemporaryValue(eff, "resists", {[DamageType.TEMPORAL] = 30})
		self:effectTemporaryValue(eff, "resists_pen", {[DamageType.TEMPORAL] = 20})
		self:effectTemporaryValue(eff, "talent_cd_reduction", {[self.T_ANOMALY_REARRANGE] = -4, [self.T_ANOMALY_TEMPORAL_STORM] = -4})
		self:learnTalent(self.T_ANOMALY_REARRANGE, true)
		self:learnTalent(self.T_ANOMALY_TEMPORAL_STORM, true)

		self.replace_display = mod.class.Actor.new{
			image = "npc/elemental_temporal_telugoroth.png",
			shader = "shadow_simulacrum",
			shader_args = { color = {0.2, 0.1, 0.8}, base = 0.5, time_factor = 500 },
		}
		self:removeAllMOs()
		game.level.map:updateMap(self.x, self.y)
	end,
	deactivate = function(self, eff)
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
	kr_desc = "타락한 로스고로스 변신",
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
	kr_desc = "쉬브고로스 변신",
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
		self:effectTemporaryValue(eff, "is_shivgoroth", 1)

		if self.hotkey and self.isHotkeyBound then
			local pos = self:isHotkeyBound("talent", self.T_SHIVGOROTH_FORM)
			if pos then
				self.hotkey[pos] = {"talent", self.T_ICE_STORM}
			end
		end

		local ohk = self.hotkey
		self.hotkey = nil -- Prevent assigning hotkey, we just did
		self:learnTalent(self.T_ICE_STORM, true, eff.lvl, {no_unlearn=true})
		self.hotkey = ohk

		self.replace_display = mod.class.Actor.new{
			image="invis.png", add_mos = {{image = "npc/elemental_ice_greater_shivgoroth.png", display_y = -1, display_h = 2}},
		}
		self:removeAllMOs()
		game.level.map:updateMap(self.x, self.y)
	end,
	deactivate = function(self, eff)
		if self.hotkey and self.isHotkeyBound then
			local pos = self:isHotkeyBound("talent", self.T_ICE_STORM)
			if pos then
				self.hotkey[pos] = {"talent", self.T_SHIVGOROTH_FORM}
			end
		end

		self:unlearnTalent(self.T_ICE_STORM, eff.lvl, nil, {no_unlearn=true})
		self.replace_display = nil
		self:removeAllMOs()
		game.level.map:updateMap(self.x, self.y)
	end,
}

--Duplicate for Frost Lord's Chain
newEffect{
	name = "SHIVGOROTH_FORM_LORD", image = "talents/shivgoroth_form.png",
	desc = "Shivgoroth Form",
	kr_desc = "쉬브고로스 변신",
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
		self:effectTemporaryValue(eff, "is_shivgoroth", 1)

		if self.hotkey and self.isHotkeyBound then
			local pos = self:isHotkeyBound("talent", self.T_SHIV_LORD)
			if pos then
				self.hotkey[pos] = {"talent", self.T_ICE_STORM}
			end
		end

		local ohk = self.hotkey
		self.hotkey = nil -- Prevent assigning hotkey, we just did
		self:learnTalent(self.T_ICE_STORM, true, eff.lvl, {no_unlearn=true})
		self.hotkey = ohk

		self.replace_display = mod.class.Actor.new{
			image="invis.png", add_mos = {{image = "npc/elemental_ice_greater_shivgoroth.png", display_y = -1, display_h = 2}},
		}
		self:removeAllMOs()
		game.level.map:updateMap(self.x, self.y)
	end,
	deactivate = function(self, eff)
		if self.hotkey and self.isHotkeyBound and self:knowTalent(self.T_SHIV_LORD) then
			local pos = self:isHotkeyBound("talent", self.T_ICE_STORM)
			if pos then
				self.hotkey[pos] = {"talent", self.T_SHIV_LORD}
			end
		end

		self:unlearnTalent(self.T_ICE_STORM, eff.lvl, nil, {no_unlearn=true})
		self.replace_display = nil
		self:removeAllMOs()
		game.level.map:updateMap(self.x, self.y)
	end,
}

newEffect{
	name = "KEEPER_OF_REALITY", image = "effects/continuum_destabilization.png",
	desc = "Keepers of Reality Rally Call",
	kr_desc = "현실 감시원의 집회",
	long_desc = function(self, eff) return "영점 수호를 위한 현실 감시원 집회 : 최대 생명력 +5000 / 공격시 피해량 +300%" end,
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

newEffect{
	name = "RECEPTIVE_MIND", image = "talents/rune__vision.png",
	desc = "Receptive Mind",
	kr_desc = "수용적 정신",
	long_desc = function(self, eff) return ("주변의 모든 %s 감지"):format(eff.what:addJosa("를")) end,
	type = "magical",
	subtype = { rune=true },
	status = "beneficial",
	parameters = { what="humanoid" },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "esp", {[eff.what]=1})
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "BORN_INTO_MAGIC", image = "talents/born_into_magic.png",
	desc = "Born into Magic",
	kr_desc = "마법과 함께 태어난 자",
	long_desc = function(self, eff) return ("%s 속성 피해량 15%% 증가"):format((DamageType:get(eff.damtype).kr_name or DamageType:get(eff.damtype).name):capitalize()) end,
	type = "magical",
	subtype = { race=true },
	status = "beneficial",
	parameters = { eff=DamageType.ARCANE },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "inc_damage", {[eff.damtype]=15})
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{ 
	name = "ESSENCE_OF_THE_DEAD", image = "talents/essence_of_the_dead.png",
	kr_desc = "죽은 자의 정수",
	desc = "Essence of the Dead",
	long_desc = function(self, eff) return ("원혼을 흡수하여 새로운 힘 획득. 다음에 사용할 주문 %d 개 강화."):format(eff.nb) end,
	type = "magical",
	decrease = 0,
	subtype = { necrotic=true },
	status = "beneficial",
	parameters = { nb=1 },
	charges = function(self, eff) return eff.nb end,
	activate = function(self, eff)
		self:addShaderAura("essence_of_the_dead", "awesomeaura", {time_factor=4000, alpha=0.6}, "particles_images/darkwings.png")
	end,
	deactivate = function(self, eff)
		self:removeShaderAura("essence_of_the_dead")
	end,
}

newEffect{
	name = "ICE_ARMOUR", image = "talents/ice_armour.png",
	desc = "Ice Armour",
	kr_desc = "얼음 갑옷",
	long_desc = function(self, eff) return ("한 층의 얼음으로 덮힘 : 방어도 %d 증가 / 근접공격 피해시 공격자에게 %0.1f 냉기 속성 피해 부여 / 공격시 모든 피해의 50%% 가 냉기 속성으로 변환."):format(eff.armor, self:damDesc(DamageType.COLD, eff.dam)) end,
	type = "magical",
	subtype = { cold=true, armour=true, },
	status = "beneficial",
	parameters = {armor=10, dam=10},
	on_gain = function(self, err) return "#Target1# 얼음 갑옷으로 덮혔습니다!" end,
	on_lose = function(self, err) return "#Target#의 얼음 갑옷이 부서졌습니다." end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "combat_armor", eff.armor)
		self:effectTemporaryValue(eff, "on_melee_hit", {[DamageType.COLD]=eff.dam})
		self:effectTemporaryValue(eff, "all_damage_convert", DamageType.COLD)
		self:effectTemporaryValue(eff, "all_damage_convert_percent", 50)
		self:addShaderAura("ice_armour", "crystalineaura", {}, "particles_images/spikes.png")
		eff.particle = self:addParticles(Particles.new("snowfall", 1))
	end,
	deactivate = function(self, eff)
		self:removeShaderAura("ice_armour")
		self:removeParticles(eff.particle)
	end,
}

newEffect{
	name = "CAUSTIC_GOLEM", image = "talents/caustic_golem.png",
	desc = "Caustic Golem",
	kr_desc = "부식성 골렘",
	long_desc = function(self, eff) return ("산성막으로 덮힘 : 근접공격 피해시 %d%% 확률로 공격자 방향으로 %0.1f 피해를 주는 산성 분사 공격."):format(eff.chance, self:damDesc(DamageType.ACID, eff.dam)) end,
	type = "magical",
	subtype = { acid=true, coating=true, },
	status = "beneficial",
	parameters = {chance=10, dam=10},
	on_gain = function(self, err) return "#Target1# 산성막으로 덮혔습니다!" end,
	on_lose = function(self, err) return "#Target#의 산성막이 희석되었습니다." end,
	callbackOnMeleeHit = function(self, eff, src)
		if self.turn_procs.caustic_golem then return end
		if not rng.percent(eff.chance) then return end
		self.turn_procs.caustic_golem = true

		self:project({type="cone", cone_angle=25, range=0, radius=4}, src.x, src.y, DamageType.ACID, eff.dam)
		game.level.map:particleEmitter(self.x, self.y, 4, "breath_acid", {radius=4, tx=src.x-self.x, ty=src.y-self.y, spread=20})
	end,
}

newEffect{
	name = "SUN_VENGEANCE", image = "talents/sun_vengeance.png",
	desc = "Sun's Vengeance",
	kr_desc = "태양의 복수",
	long_desc = function(self, eff) return ("태양의 분노로 가득참 : 다음번 태양 광선 사용시 턴을 소모하지 않음."):format() end, --@ "Sun Beam"으로 적혀있지만 코드를 봐서는 기술 "Sun Ray"임 
	type = "magical",
	subtype = { sun=true, },
	status = "beneficial",
	parameters = {},
	on_gain = function(self, err) return "#Target1# 태양의 분노로 가득찼습니다!", "+태양의 복수" end,
	on_lose = function(self, err) return "#Target1# 가지고 있던 태양의 분노가 가라앉았습니다.", "-태양의 복수" end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "amplify_sun_beam", 25)
	end
}

newEffect{
	name = "PATH_OF_THE_SUN", image = "talents/path_of_the_sun.png",
	desc = "Path of the Sun",
	kr_desc = "태양의 길",
	long_desc = function(self, eff) return ("태양의 길을 따라 순간적인 이동 가능."):format() end,
	type = "magical",
	subtype = { sun=true, },
	status = "beneficial",
	parameters = {},
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "walk_sun_path", 1)
	end
}

newEffect{
	name = "SUNCLOAK", image = "talents/suncloak.png",
	desc = "Suncloak",
	kr_desc = "태양 망토",
	long_desc = function(self, eff) return ("태양으로부터의 보호 : 주문 시전 속도 %d%% 증가 / 주문 지연시간 %d%% 감소 / 한 번의 공격 당 최대 생명력 %d%% 이상의 피해 방지."):
		format(eff.haste*100, eff.cd*100, eff.cap) end,
	type = "magical",
	subtype = { light=true, },
	status = "beneficial",
	parameters = {cap = 1, haste = 0.1, cd = 0.1},
	on_gain = function(self, err) return "#Target# is energized and protected by the Sun!", "+태양 망토" end,
	on_lose = function(self, err) return "#Target#'s solar fury subsides.", "-태양 망토" end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "flat_damage_cap", {all=eff.cap})
		self:effectTemporaryValue(eff, "combat_spellspeed", eff.haste)
		self:effectTemporaryValue(eff, "spell_cooldown_reduction", eff.cd)
		eff.particle = self:addParticles(Particles.new("suncloak", 1))
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
	end,
}

newEffect{
	name = "MARK_OF_LIGHT", image = "talents/mark_of_light.png",
	desc = "Mark of Light",
	kr_desc = "빛의 표식",
	long_desc = function(self, eff) return ("빛의 표식 : 근접공격 피해시 피해량의 %d%% 만큼 생명력 회복."):format(eff.power) end,
	type = "magical",
	subtype = { light=true, },
	status = "detrimental",
	parameters = { power = 10 },
	on_gain = function(self, err) return "#Target#에게 빛에 의한 표식이 생겼습니다!", "+빛의 표식" end,
	on_lose = function(self, err) return "#Target#의 표식이 사라졌습니다.", "-빛의 표식" end,
	callbackOnMeleeHit = function(self, eff, src, dam)
		if eff.src == src then
			src:heal(dam * eff.power / 100, self)
			if core.shader.active(4) then
				eff.src:addParticles(Particles.new("shader_shield_temp", 1, {toback=true, size_factor=1.5, y=-0.3, img="healcelestial", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=2.0, beamColor1={0xd8/255, 0xff/255, 0x21/255, 1}, beamColor2={0xf7/255, 0xff/255, 0x9e/255, 1}, circleDescendSpeed=3}))
				eff.src:addParticles(Particles.new("shader_shield_temp", 1, {toback=false,size_factor=1.5, y=-0.3, img="healcelestial", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=1.0, beamColor1={0xd8/255, 0xff/255, 0x21/255, 1}, beamColor2={0xf7/255, 0xff/255, 0x9e/255, 1}, circleDescendSpeed=3}))
			end
		end
	end,
}

newEffect{
	name = "RIGHTEOUS_STRENGTH", image = "talents/righteous_strength.png",
	desc = "Righteous Strength",
	kr_desc = "올바른 힘",
	long_desc = function(self, eff) return ("공격시 빛 속성 피해 %d%% 증가 / 공격시 물리 속성 피해 %d%% 증가."):format(eff.power, eff.power) end, --@ 변수 조정
	type = "magical",
	subtype = { sun=true, },
	status = "beneficial",
	parameters = { power = 10 },
	on_gain = function(self, err) return "#Target1# 밝게 빛나기 시작합니다!", "+올바른 힘" end,
	on_lose = function(self, err) return "#Target#의 빛이 사라집니다.", "-올바른 힘" end,
	charges = function(self, eff) return eff.charges end,
	on_merge = function(self, old_eff, new_eff)
		new_eff.charges = math.min(old_eff.charges + 1, 3)
		new_eff.power = math.min(new_eff.power + old_eff.power, new_eff.max_power)
		self:removeTemporaryValue("inc_damage", old_eff.tmpid)
		new_eff.tmpid = self:addTemporaryValue("inc_damage", {[DamageType.PHYSICAL] = new_eff.power, [DamageType.LIGHT] = new_eff.power})
		return new_eff
	end,
	activate = function(self, eff)
		eff.charges = 1
		eff.tmpid = self:addTemporaryValue("inc_damage", {[DamageType.PHYSICAL] = eff.power, [DamageType.LIGHT] = eff.power})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_damage", eff.tmpid)
	end,
}

newEffect{
	name = "LIGHTBURN", image = "talents/righteous_strength.png",
	desc = "Lightburn",
	kr_desc = "빛에 의한 화상",
	long_desc = function(self, eff) return ("빛에 의한 화상 : 매 턴 마다 빛 속성 피해 %0.2f 발생 / 방어도 %d 감소."):format(eff.dam, eff.armor) end,
	type = "magical",
	subtype = { sun=true, },
	status = "detrimental",
	parameters = { armor = 10, dam = 10 },
	on_gain = function(self, err) return "#Target1# 빛에 의해 화상을 입습니다!", "+빛에 의한 화상" end,
	on_lose = function(self, err) return "#Target#의 화상이 나았습니다.", "-빛에 의한 화상" end,
	on_merge = function(self, old_eff, new_eff)
		-- Merge the flames!
		local olddam = old_eff.dam * old_eff.dur
		local newdam = new_eff.dam * new_eff.dur
		local dur = math.ceil((old_eff.dur + new_eff.dur) / 2)
		old_eff.dur = dur
		old_eff.dam = (olddam + newdam) / dur
		return old_eff
	end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "combat_armor", -eff.armor)
	end,
	on_timeout = function(self, eff)
		DamageType:get(DamageType.LIGHT).projector(eff.src, self.x, self.y, DamageType.LIGHT, eff.dam)
	end,
}

newEffect{
	name = "ILLUMINATION",
	desc = "Illumination ", image = "talents/illumination.png",
	kr_desc = "조명",
	long_desc = function(self, eff) return ("빛남 : 은신 수치 %d 감소 / 투명화 수치 %d 감소 / 회피도 %d 감소 / 보이지 않음으로 발생하는 모든 회피 능력 상실."):format(eff.power, eff.power, eff.def) end, --@ 변수 조정
	type = "magical",
	subtype = { sun=true },
	status = "detrimental",
	parameters = { power=20, def=20 },
	on_gain = function(self, err) return nil, "+조명" end,
	on_lose = function(self, err) return nil, "-조명" end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "inc_stealth", -eff.power)
		if self:attr("invisible") then self:effectTemporaryValue(eff, "invisible", -eff.power) end
		self:effectTemporaryValue(eff, "combat_def", -eff.def)
		self:effectTemporaryValue(eff, "blind_fighted", 1)
	end,
}

newEffect{
	name = "LIGHT_BURST",
	desc = "Light Burst ", image = "talents/light_burst.png",
	kr_desc = "폭발하는 빛",
	long_desc = function(self, eff) return ("'타오르는 시선'으로 공격시 고무됨."):format() end,
	type = "magical",
	subtype = { sun=true },
	status = "beneficial",
	parameters = { max=1 },
	on_gain = function(self, err) return nil, "+폭발하는 빛" end,
	on_lose = function(self, err) return nil, "-폭발하는 빛" end,
}

newEffect{
	name = "LIGHT_BURST_SPEED",
	desc = "Light Burst Speed", image = "effects/light_burst_speed.png",
	kr_desc = "폭발하는 빛의 속도",
	long_desc = function(self, eff) return ("'타오르는 시선'으로 고무됨 : 이동 속도 %d%% 증가."):format(eff.charges * 10) end,
	type = "magical",
	subtype = { sun=true },
	status = "beneficial",
	parameters = {},
	charges = function(self, eff) return eff.charges end,
	on_gain = function(self, err) return nil, "+폭발하는 빛의 속도" end,
	on_lose = function(self, err) return nil, "-폭발하는 빛의 속도" end,
	on_merge = function(self, old_eff, new_eff)
		local p = self:hasEffect(self.EFF_LIGHT_BURST)
		if not p then p = {max=1} end

		new_eff.charges = math.min(old_eff.charges + 1, p.max)
		self:removeTemporaryValue("movement_speed", old_eff.tmpid)
		new_eff.tmpid = self:addTemporaryValue("movement_speed", new_eff.charges * 0.1)
		return new_eff
	end,
	activate = function(self, eff)
		eff.charges = 1
		eff.tmpid = self:addTemporaryValue("movement_speed", eff.charges * 0.1)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("movement_speed", eff.tmpid)
	end,
}

newEffect{
	name = "HEALING_INVERSION",
	desc = "Healing Inversion", image = "talents/healing_inversion.png",
	kr_desc = "회복 반전",
	long_desc = function(self, eff) return ("대상의 모든 생명력 회복이 %d%% 황폐 피해로 변환."):format(eff.power) end,
	type = "magical",
	subtype = { heal=true },
	status = "detrimental",
	parameters = { power=10 },
	on_gain = function(self, err) return nil, "+회복 반전" end,
	on_lose = function(self, err) return nil, "-회복 반전" end,
	callbackOnHeal = function(self, eff, value, src)
		local dam = value * eff.power / 100
		DamageType:get(DamageType.BLIGHT).projector(eff.src or self, self.x, self.y, DamageType.BLIGHT, dam)
		return {value=0}
	end,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("circle", 1, {oversize=0.7, a=90, appear=8, speed=-2, img="necromantic_circle", radius=0}))
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
	end,
}

newEffect{
	name = "SHOCKED",
	desc = "Shocked",
	kr_desc = "전기 충격",
	long_desc = function(self, eff) return ("전기 충격을 받음 : 기절 면역력 절반 감소 / 속박 면역력 절반 감소."):format() end,
	type = "magical",
	subtype = { lightning=true },
	status = "detrimental",
	on_gain = function(self, err) return nil, "+전기 충격" end,
	on_lose = function(self, err) return nil, "-전기 충격" end,
	activate = function(self, eff)
		if self:attr("stun_immune") then
			self:effectTemporaryValue(eff, "stun_immune", -self:attr("stun_immune") / 2)
		end
		if self:attr("pin_immune") then
			self:effectTemporaryValue(eff, "pin_immune", -self:attr("pin_immune") / 2)
		end
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "WET",
	desc = "Wet",
	kr_desc = "젖음",
	long_desc = function(self, eff) return ("마법적 물에 빠짐 : 기절 면역력 절반 감소."):format() end,
	type = "magical",
	subtype = { water=true, ice=true },
	status = "detrimental",
	on_gain = function(self, err) return nil, "+젖음" end,
	on_lose = function(self, err) return nil, "-젖음" end,
	on_merge = function(self, old_eff, new_eff)
		old_eff.dur = new_eff.dur
		return old_eff
	end,
	activate = function(self, eff)
		if self:attr("stun_immune") then
			self:effectTemporaryValue(eff, "stun_immune", -self:attr("stun_immune") / 2)
		end
		eff.particle = self:addParticles(Particles.new("circle", 1, {shader=true, oversize=0.7, a=155, appear=8, speed=0, img="water_drops", radius=0}))
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
	end,
}

newEffect{
	name = "PROBABILITY_TRAVEL", image = "talents/anomaly_probability_travel.png",
	desc = "Probability Travel",
	kr_desc = "마법 확률 이동",
	long_desc = function(self, eff) return ("대상은 위상에서 벗어나 있으며 벽을 통과 할 수 있습니다"):format() end,
	type = "magical",
	subtype = { teleport=true },
	status = "beneficial",
	parameters = { power=0 },
	on_gain = function(self, err) return nil, "+Probability Travel" end,
	on_lose = function(self, err) return nil, "-Probability Travel" end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "prob_travel", eff.power)
		self:effectTemporaryValue(eff, "prob_travel_penalty", eff.power)
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "BLINK", image = "talents/anomaly_blink.png",
	desc = "Blink",
	kr_desc = "점멸",
	long_desc = function(self, eff) return ("목표는 매턴 무작위로 순간이동 합니다"):format() end,
	type = "magical",
	subtype = { teleport=true },
	status = "detrimental",
	on_gain = function(self, err) return nil, "+Blink" end,
	on_lose = function(self, err) return nil, "-Blink" end,
	on_timeout = function(self, eff)
		if self:teleportRandom(self.x, self.y, eff.power) then
			game.level.map:particleEmitter(self.x, self.y, 1, "temporal_teleport")
		end
	end,
}

newEffect{
	name = "DIMENSIONAL_ANCHOR", image = "talents/dimensional_anchor.png",
	desc = "Dimensional Anchor",
	kr_desc = "차원의 닻",
	long_desc = function(self, eff) return ("목표는 순간이동 할 수 없고, 만약 시도한다면 %0.2f 시간 피해와, %0.2f 물리 피해를 입습니다."):format(eff.damage, eff.damage) end,
	type = "magical",
	subtype = { temporal=true, slow=true },
	status = "detrimental",
	parameters = { damage=0 },
	on_gain = function(self, err) return "#Target# is anchored.", "+Anchor" end,
	on_lose = function(self, err) return "#Target# is no longer anchored.", "-Anchor" end,
	onTeleport = function(self, eff)
		DamageType:get(DamageType.WARP).projector(eff.src or self, self.x, self.y, DamageType.WARP, eff.damage)
	end,
	activate = function(self, eff)
		-- Reduce teleport saves to zero so our damage will trigger
		eff.effid = self:addTemporaryValue("continuum_destabilization", -1000)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("continuum_destabilization", eff.effid)
	end,
}

newEffect{
	name = "BREACH", image = "talents/breach.png",
	desc = "Breach",
	kr_desc = "관통",
	long_desc = function(self, eff) return ("목표의 방어는 관통당하였습니다. 방어율, 기절, 속박, 실명, 혼란 저항이 50%% 만큼 떨어집니다."):format() end,
	type = "magical",
	subtype = { temporal=true },
	status = "detrimental",
	on_gain = function(self, err) return nil, "+Breach" end,
	on_lose = function(self, err) return nil, "-Breach" end,
	on_merge = function(self, old_eff, new_eff)
		old_eff.dur = new_eff.dur
		return old_eff
	end,
	activate = function(self, eff)
		if self:attr("stun_immune") then
			self:effectTemporaryValue(eff, "stun_immune", -self:attr("stun_immune") / 2)
		end
		if self:attr("confusion_immune") then
			self:effectTemporaryValue(eff, "confusion_immune", -self:attr("confusion_immune") / 2)
		end
		if self:attr("blind_immune") then
			self:effectTemporaryValue(eff, "blind_immune", -self:attr("blind_immune") / 2)
		end
		if self:attr("pin_immune") then
			self:effectTemporaryValue(eff, "pin_immune", -self:attr("pin_immune") / 2)
		end
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "BRAIDED", image = "talents/braid_lifelines.png",
	desc = "Braided",
	kr_desc = "엮임",
	long_desc = function(self, eff) return ("목표는 엮여 있는 다른 목표에게 가해지는 피해의 %d%% 만큼 피해를 입습니다."):format(eff.power) end,
	type = "magical",
	subtype = { temporal=true },
	status = "detrimental",
	parameters = { power=0 },
	on_gain = function(self, err) return "#Target#의 생명선이 엮입니다.", "+Braided" end,
	on_lose = function(self, err) return "#Target#의 생명선은 더이상 엮여있지 않습니다.", "-Braided" end,
	doBraid = function(self, eff, dam)
		local braid_damage = dam * eff.power/ 100
		for i = 1, #eff.targets do
			local target = eff.targets[i]
			if target ~= self and not target.dead then
				game:delayedLogMessage(eff.src, target, "braided", "#CRIMSON##Source# 의 피해를 #Target# 도 생명선을 통해 입습니다!")
				game:delayedLogDamage(eff.src, target, braid_damage, ("#PINK#%d 엮여짐 #LAST#"):format(braid_damage), false)
				target:takeHit(braid_damage, eff.src)
			end
		end
	end,
	on_timeout = function(self, eff)
		local alive = false
		for i = 1, #eff.targets do
			local target = eff.targets[i]
			if target ~=self and not target.dead then
				alive = true
				break
			end
		end
		if not alive then
			self:removeEffect(self.EFF_BRAIDED)
		end
	end,
}

newEffect{
	name = "PRECOGNITION", image = "talents/precognition.png",
	desc = "Precognition",
	kr_desc = "예지",
	long_desc = function(self, eff) return ("미래를 엿보아,적들을 감지하고, 회피도를 %d 만큼 얻고, %d%% 만큼의 치명타 피해 무시를 얻습니다."):format(eff.defense, eff.crits) end,
	type = "magical",
	subtype = { sense=true },
	status = "beneficial",
	parameters = { range=10, actor=1, trap=1, defense=0, crits=0 },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "detect_range", eff.range)
		self:effectTemporaryValue(eff, "detect_actor", eff.actor)
		self:effectTemporaryValue(eff, "detect_trap", eff.actor)
		self:effectTemporaryValue(eff, "ignore_direct_crits", eff.crits)
		self:effectTemporaryValue(eff, "combat_def", eff.defense)
		self.detect_function = eff.on_detect
		game.level.map.changed = true
	end,
	deactivate = function(self, eff)
		self.detect_function = nil
	end,
}

newEffect{
	name = "WEBS_OF_FATE", image = "talents/webs_of_fate.png",
	desc = "Webs of Fate",
	kr_desc = "운명의 거미줄",
	long_desc = function(self, eff) return ("모든 피해의 %d%% 만큼을 주변의 적에게 옮깁니다."):format(eff.power*100) end,
	type = "magical",
	subtype = { temporal=true },
	status = "beneficial",
	on_gain = function(self, err) return nil, "+Webs of Fate" end,
	on_lose = function(self, err) return nil, "-Webs of Fate" end,
	parameters = { power=0.1 },
	callbackOnTakeDamage = function(self, eff, src, x, y, type, dam, state)
		-- Displace Damage?
		local t = eff.talent
		if dam > 0 and src ~= self and not state.no_reflect then
		
			-- Spin Fate?
			if self.turn_procs and self:knowTalent(self.T_SPIN_FATE) and not self.turn_procs.spin_webs then
				self.turn_procs.spin_webs = true
				self:callTalent(self.T_SPIN_FATE, "doSpin")
			end
		
			-- find available targets
			local tgts = {}
			local grids = core.fov.circle_grids(self.x, self.y, 10, true)
			for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
				local a = game.level.map(x, y, Map.ACTOR)
				if a and self:reactionToward(a) < 0 then
					tgts[#tgts+1] = a
				end
			end end

			-- Displace the damage
			local a = rng.table(tgts)
			if a then
				local displace = dam * eff.power
				state.no_reflect = true
				DamageType.defaultProjector(self, a.x, a.y, type, displace, state)
				state.no_reflect = nil
				dam = dam - displace
				game:delayedLogDamage(src, self, 0, ("%s(%d webs of fate)#LAST#"):format(DamageType:get(type).text_color or "#aaaaaa#", displace), false)
			end
		end
		
		return {dam=dam}
	end,
	activate = function(self, eff)
		if core.shader.allow("adv") then
			eff.particle1, eff.particle2 = self:addParticles3D("volumetric", {kind="fast_sphere", shininess=40, density=40, radius=1.4, scrollingSpeed=0.001, growSpeed=0.004, img="squares_x3_01"})
		end
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle1)
		self:removeParticles(eff.particle2)
	end,
}

newEffect{
	name = "SEAL_FATE", image = "talents/seal_fate.png",
	desc = "Seal Fate",
	kr_desc = "운명 날인",
	long_desc = function(self, eff)
		local chance = eff.chance
		local spin = self:hasEffect(self.EFF_SPIN_FATE)
		if spin then
			chance = chance * (1 + spin.spin/3)
		end
		return ("피해를 가할 때 마다 %d%% 의 확률로 목표의 해로운 효과 하나의 지속 시간을 1 턴 늘립니다"):format(chance) 
	end,
	type = "magical",
	subtype = { focus=true },
	status = "beneficial",
	parameters = { procs=1 },
	on_gain = function(self, err) return nil, "+Seal Fate" end,
	on_lose = function(self, err) return nil, "-Seal Fate" end,
	callbackOnDealDamage = function(self, eff, dam, target)
		if dam <=0 then return end
		
		-- Spin Fate?
		if self.turn_procs and self:knowTalent(self.T_SPIN_FATE) and not self.turn_procs.spin_seal then
			self.turn_procs.spin_seal = true
			self:callTalent(self.T_SPIN_FATE, "doSpin")
		end
	
	
		if self.turn_procs and target.tmp then
			if self.turn_procs.seal_fate and self.turn_procs.seal_fate >= eff.procs then return end
			local chance = eff.chance
			local spin = self:hasEffect(self.EFF_SPIN_FATE)
			if spin then
				chance = chance * (1 + spin.spin/3)
			end
			
			if rng.percent(chance) then
				-- Grab a random effect
				local eff_ids = target:effectsFilter({status="detrimental", ignore_crosstier=true}, 1)
				for _, eff_id in ipairs(eff_ids) do
					local eff = target:hasEffect(eff_id)
					eff.dur = eff.dur +1
				end
			
				self.turn_procs.seal_fate = (self.turn_procs.seal_fate or 0) + 1
			end
			
		end
	end,
	activate = function(self, eff)
		if core.shader.allow("adv") then
			eff.particle1, eff.particle2 = self:addParticles3D("volumetric", {kind="no_idea_but_looks_cool", shininess=60, density=40, scrollingSpeed=0.0002, radius=1.6, growSpeed=0.004, img="squares_x3_01"})
		end
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle1)
		self:removeParticles(eff.particle2)
	end,
}


newEffect{
	name = "UNRAVEL", image = "talents/temporal_vigour.png",
	desc = "Unravel",
	kr_desc = "언레이블",
	long_desc = function(self, eff)
		return ("목표는 모든 피해에 면역이지만, %d%% 만큼 낮은 피해를 입힙니다."):format(eff.power)
	end,
	on_gain = function(self, err) return "#Target# has started to unravel.", "+Unraveling" end,
	type = "magical",
	subtype = {time=true},
	status = "beneficial",
	parameters = {power=50, die_at=50},
	on_timeout = function(self, eff)
		if self.life > 0 then
			self:removeEffect(self.EFF_UNRAVEL)
		end
	end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "die_at", eff.die_at)
		self:effectTemporaryValue(eff, "generic_damage_penalty", eff.power)
		self:effectTemporaryValue(eff, "invulnerable", 1)
	end,
	deactivate = function(self, eff)
		-- check negative life first incase the creature has healing
		if self.life <= (self.die_at or 0) then
			local sx, sy = game.level.map:getTileToScreen(self.x, self.y)
			game.flyers:add(sx, sy, 30, (rng.range(0,2)-1) * 0.5, rng.float(-2.5, -1.5), "Unravels!", {255,0,255})
			game.logSeen(self, "%s has unraveled!", self.name:capitalize())
			self:die(self)
		end
	end,
}

newEffect{
	name = "ENTROPY", image = "talents/entropy.png",
	desc = "Entropy",
	kr_desc = "엔트로피",
	long_desc = function(self, eff) return "목표는 하나의 유지 기술을 매턴 잃습니다." end,
	on_gain = function(self, err) return "#Target# 엔트로피장에 갇혔습니다!", "+Entropy" end,
	on_lose = function(self, err) return "#Target# 는 엔트로피에서 풀려났습니다.", "-Entropy" end,
	type = "magical",
	subtype = { temporal=true },
	status = "detrimental",
	parameters = {},
	on_timeout = function(self, eff)
		self:removeSustainsFilter(nil, 1)
	end,
	activate = function(self, eff)
		if core.shader.allow("adv") then
			eff.particle1, eff.particle2 = self:addParticles3D("volumetric", {kind="fast_sphere", twist=2, base_rotation=90, radius=1.4, density=40,  scrollingSpeed=-0.0002, growSpeed=0.004, img="miasma_01_01"})
		end
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle1)
		self:removeParticles(eff.particle2)
	end,
}

newEffect{
	name = "REGRESSION", image = "talents/turn_back_the_clock.png",
	desc = "Regression",
	kr_desc = "퇴행",
	long_desc = function(self, eff)	return ("당신의 가장 높은 세 능력치를 %d 만큼 깎습니다."):format(eff.power) end,
	on_gain = function(self, err) return "#Target# 퇴행하였습니다", "+Regression" end,
	on_lose = function(self, err) return "#Target# 원래 상태로 돌아 왔습니다", "-Regression" end,
	type = "physical",
	subtype = { temporal=true },
	status = "detrimental",
	parameters = { power=1},
	activate = function(self, eff)
		local l = { {Stats.STAT_STR, self:getStat("str")}, {Stats.STAT_DEX, self:getStat("dex")}, {Stats.STAT_CON, self:getStat("con")}, {Stats.STAT_MAG, self:getStat("mag")}, {Stats.STAT_WIL, self:getStat("wil")}, {Stats.STAT_CUN, self:getStat("cun")}, }
		table.sort(l, function(a,b) return a[2] > b[2] end)
		local inc = {}
		for i = 1, 3 do inc[l[i][1]] = -eff.power end
		self:effectTemporaryValue(eff, "inc_stats", inc)
	end,
}

newEffect{
	name = "ATTENUATE_DET", image = "talents/attenuate.png",
	desc = "Attenuate",
	kr_desc = "희석",
	long_desc = function(self, eff) return ("목표는 시간선에서 제거되어 매턴 %0.2f 만큼의 시간 피해를 입습니다."):format(eff.power) end,
	type = "magical",
	subtype = { temporal=true },
	status = "detrimental",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# 시간선에서 제거 되고 있습니다!", "+Attenuate" end,
	on_lose = function(self, err) return "#Target# 희석으로부터 살아남았습니다.", "-Attenuate" end,
	on_merge = function(self, old_eff, new_eff)
		-- Merge the flames!
		local olddam = old_eff.power * old_eff.dur
		local newdam = new_eff.power * new_eff.dur
		local dur = math.ceil((old_eff.dur + new_eff.dur) / 2)
		old_eff.dur = dur
		old_eff.power = (olddam + newdam) / dur
		return old_eff
	end,
	callbackOnHit = function(self, eff, cb, src)
		if cb.value <= 0 then return cb.value end
		
		-- Kill it!!
		if not self.dead and not self:isTalentActive(self.T_REALITY_SMEARING) and self:canBe("instakill") and self.life > 0 and self.life < self.max_life * 0.2 then
			game.logSeen(self, "%s 시간선에서 제거되었습니다!", self.name:capitalize())
			self:die(src)
		end
		
		return cb.value
	end,
	on_timeout = function(self, eff)
		if self:isTalentActive(self.T_REALITY_SMEARING) then
			self:heal(eff.power * 0.4, eff)
		else
			DamageType:get(DamageType.TEMPORAL).projector(eff.src, self.x, self.y, DamageType.TEMPORAL, eff.power)
		end
	end,
}

newEffect{
	name = "ATTENUATE_BEN", image = "talents/attenuate.png",
	desc = "Attenuate",
	kr_desc = "희석",
	long_desc = function(self, eff) return ("목표는 시간선에 고정되고 있어 매턴 %0.2f 만큼 생명력이 회복됩니다."):format(eff.power) end,
	type = "magical",
	subtype = { temporal=true },
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# 는 시간선에 고정되고 있습니다!", "+Attenuate" end,
	on_lose = function(self, err) return "#Target# 는 더이상 시간선에 고정되고 있지 않습니다.", "-Attenuate" end,
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
		self:heal(eff.power, eff)
	end,
}

newEffect{
	name = "OGRIC_WRATH", image = "talents/ogre_wrath.png",
	desc = "Ogric Wrath",
	kr_desc = "오우거의 분노",
	long_desc = function(self, eff) return ("저항하려 하지 마라!"):format() end,
	type = "magical",
	subtype = { runic=true },
	status = "beneficial",
	parameters = { power=1 },
	on_gain = function(self, err) return "#Target# 오우거의 분노에 접어듭니다.", "+Ogric Wrath" end,
	on_lose = function(self, err) return "#Target# 진정합니다.", "-Ogric Wrath" end,
	callbackOnDealDamage = function(self, eff, val, target, dead, death_note)
		if not death_note or not death_note.initial_dam then return end
		if val >= death_note.initial_dam then return end
		if self:reactionToward(target) >= 0 then return end
		if self.turn_procs.ogric_wrath then return end

		self.turn_procs.ogric_wrath = true
		self:setEffect(self.EFF_OGRE_FURY, 7, {})
	end,
	callbackOnMeleeAttack = function(self, eff, target, hitted, crit, weapon, damtype, mult, dam)
		if hitted then return true end
		if self:reactionToward(target) >= 0 then return end
		if self.turn_procs.ogric_wrath then return end

		self.turn_procs.ogric_wrath = true
		self:setEffect(self.EFF_OGRE_FURY, 1, {})
	end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "stun_immune", 0.2)
		self:effectTemporaryValue(eff, "pin_immune", 0.2)
		self:effectTemporaryValue(eff, "inc_damage", {all=10})

		self.moddable_tile_ornament, eff.old_mod = {female="runes_red_glow_01", male="runes_red_glow_01"}, self.moddable_tile_ornament
		self.moddable_tile_ornament_shader, eff.old_mod_shader = "runes_glow", self.moddable_tile_ornament_shader
		self:updateModdableTile()
	end,
	deactivate = function(self, eff)
		self.moddable_tile_ornament = eff.old_mod
		self.moddable_tile_ornament_shader = eff.old_mod_shader
		self:updateModdableTile()
	end,
}

newEffect{
	name = "OGRE_FURY", image = "effects/ogre_fury.png",
	desc = "Ogre Fury",
	kr_desc = "오우거의 격노",
	long_desc = function(self, eff) return ("치명타 확율을 %d%% 만큼 상승시키고, 치명타 피해량은 %d%% 만큼 상승합니다. 현재 %d 중첩."):format(eff.stacks * 5, eff.stacks * 20, eff.stacks) end,
	type = "magical",
	subtype = { runic=true },
	status = "beneficial",
	parameters = { stacks=1, max_stacks=5 },
	charges = function(self, eff) return eff.stacks end,
	do_effect = function(self, eff, add)
		if eff.cdam then self:removeTemporaryValue("combat_critical_power", eff.cdam) eff.cdam = nil end
		if eff.crit then self:removeTemporaryValue("combat_generic_crit", eff.crit) eff.crit = nil end
		if add then
			eff.cdam = self:addTemporaryValue("combat_critical_power", eff.stacks * 20)
			eff.crit = self:addTemporaryValue("combat_generic_crit", eff.stacks * 5)
		end
	end,
	callbackOnCrit = function(self, eff)
		eff.stacks = eff.stacks - 1
		if eff.stacks == 0 then
			self:removeEffect(self.EFF_OGRE_FURY)
		else
			local e = self:getEffectFromId(self.EFF_OGRE_FURY)
			e.do_effect(self, eff, true)
		end
	end,
	on_merge = function(self, old_eff, new_eff, e)
		old_eff.dur = new_eff.dur
		old_eff.stacks = util.bound(old_eff.stacks + 1, 1, new_eff.max_stacks)
		e.do_effect(self, old_eff, true)
		return old_eff
	end,
	activate = function(self, eff, e)
		e.do_effect(self, eff, true)
	end,
	deactivate = function(self, eff, e)
		e.do_effect(self, eff, false)
	end,
	on_timeout = function(self, eff, e)
		if eff.stacks > 1 and eff.dur <= 1 then
			eff.stacks = eff.stacks - 1
			eff.dur = 7
			e.do_effect(self, eff, true)
		end
	end
}

newEffect{
	name = "WRIT_LARGE", image = "talents/writ_large.png",
	desc = "Writ Large",
	kr_desc = "강화",
	long_desc = function(self, eff) return ("각인의 재사용 대기시간이 두배로 빠르게 줄어듭니다."):format(eff.power) end,
	type = "magical",
	subtype = { runic=true },
	status = "beneficial",
	parameters = { power=1 },
	on_gain = function(self, err) return nil, "+Writ Large" end,
	on_lose = function(self, err) return nil, "-Writ Large" end,
	callbackOnActBase = function(self, eff)
		if not self:attr("no_talents_cooldown") then
			for tid, c in pairs(self.talents_cd) do
				local t = self:getTalentFromId(tid)
				if t and t.is_inscription then
					self.changed = true
					self.talents_cd[tid] = self.talents_cd[tid] - eff.power
					if self.talents_cd[tid] <= 0 then
						self.talents_cd[tid] = nil
						if self.onTalentCooledDown then self:onTalentCooledDown(tid) end
						if t.cooldownStop then t.cooldownStop(self, t) end
					end
				end
			end
		end
	end,
}

newEffect{
	name = "STATIC_HISTORY", image = "talents/static_history.png",
	desc = "Static History",
	kr_desc = "고정된 역사",
	long_desc = function(self, eff) return ("목표가 시전하는 시공계열의 주문이 비주요 이상현상을 일으키지 않습니다."):format() end,
	type = "magical",
	subtype = { time=true },
	status = "beneficial",
	parameters = { power=0.1 },
	on_gain = function(self, err) return "#Target# 주변의 시공간이 안정됩니다.", "+Static History" end,
	on_lose = function(self, err) return "#Target# 주변의 시공간의 흐름이 정상으로 돌아옵니다.", "-Static History" end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "no_minor_anomalies", 1)
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "ARROW_ECHOES", image = "talents/arrow_echoes.png",
	desc = "Arrow Echoes",
	kr_desc = "화살의 메아리",
	long_desc = function(self, eff) return ("매턴 %s 에게 화살을 쏩니다."):format(eff.target.name) end,
	type = "magical",
	subtype = { time=true },
	status = "beneficial",
	remove_on_clone = true,
	on_gain = function(self, err) return nil, "+Arrow Echoes" end,
	on_lose = function(self, err) return nil, "-Arrow Echoes" end,
	parameters = { shots = 1 },
	on_timeout = function(self, eff)
		if eff.shots <= 0 or eff.target.dead or not game.level:hasEntity(self) or not game.level:hasEntity(eff.target) or core.fov.distance(self.x, self.y, eff.target.x, eff.target.y) > 10 then
			self:removeEffect(self.EFF_ARROW_ECHOES)
		else
			self:callTalent(self.T_ARROW_ECHOES, "doEcho", eff)
		end
	end,
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "WARDEN_S_FOCUS", image = "talents/warden_s_focus.png",
	desc = "Warden's Focus",
	kr_desc = "감시자의 주목",
	long_desc = function(self, eff) 
		return ("%s 에게 집중하여, 이 목표에게 가하는 공격은 +%d%% 만큼 치명타 피해를 더 입히고, +%d%% 만큼 치명타 확율이 오릅니다."):format(eff.target.name, eff.power, eff.power)
	end,
	type = "magical",
	subtype = { tactic=true },
	status = "beneficial",
	on_gain = function(self, err) return nil, "+Warden's Focus" end,
	on_lose = function(self, err) return nil, "-Warden's Focus" end,
	parameters = { power=0},
	callbackOnTakeDamage = function(self, eff, src, x, y, type, dam, tmp)
		local eff = self:hasEffect(self.EFF_WARDEN_S_FOCUS)
		if eff and dam > 0 and eff.target ~= src and src ~= self and (src.rank and eff.target.rank and src.rank < eff.target.rank) then
			-- Reduce damage
			local reduction = dam * eff.power/100
			dam = dam -  reduction
			game:delayedLogDamage(src, self, 0, ("%s(%d focus)#LAST#"):format(DamageType:get(type).text_color or "#aaaaaa#", reduction), false)
		end
		return {dam=dam}
	end,
	on_timeout = function(self, eff)
		if eff.target.dead or not game.level:hasEntity(self) or not game.level:hasEntity(eff.target) or core.fov.distance(self.x, self.y, eff.target.x, eff.target.y) > 10 then
			self:removeEffect(self.EFF_WARDEN_S_FOCUS)
		end
	end,
	activate = function(self, eff)	
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "FATEWEAVER", image = "talents/fateweaver.png",
	desc = "Fateweaver",
	kr_desc = "운명의 방직자",
	long_desc = function(self, eff) return ("목표의 정확도와 물리력, 정신력, 주문력이 %d 만큼 오릅니다."):format(eff.power_bonus * eff.spin) end,
	display_desc = function(self, eff) return eff.spin.." Fateweaver" end,
	charges = function(self, eff) return eff.spin end,
	type = "magical",
	subtype = { temporal=true },
	status = "beneficial",
	parameters = { power_bonus=0, spin=0, max_spin=3},
	on_gain = function(self, err) return "#Target# weaves fate.", "+Fateweaver" end,
	on_lose = function(self, err) return "#Target# stops weaving fate.", "-Fateweaver" end,
	on_merge = function(self, old_eff, new_eff)
		-- remove the four old values
		self:removeTemporaryValue("combat_atk", old_eff.atkid)
		self:removeTemporaryValue("combat_dam", old_eff.physid)
		self:removeTemporaryValue("combat_spellpower", old_eff.spellid)
		self:removeTemporaryValue("combat_mindpower", old_eff.mentalid)
		
		-- add some spin
		old_eff.spin = math.min(old_eff.spin + 1, new_eff.max_spin)
	
		-- and apply the current values
		old_eff.atkid = self:addTemporaryValue("combat_atk", old_eff.power_bonus * old_eff.spin)
		old_eff.physid = self:addTemporaryValue("combat_dam", old_eff.power_bonus * old_eff.spin)
		old_eff.spellid = self:addTemporaryValue("combat_spellpower", old_eff.power_bonus * old_eff.spin)
		old_eff.mentalid = self:addTemporaryValue("combat_mindpower", old_eff.power_bonus * old_eff.spin)

		old_eff.dur = new_eff.dur
		
		return old_eff
	end,
	activate = function(self, eff)
		-- apply current values
		eff.atkid = self:addTemporaryValue("combat_atk", eff.power_bonus * eff.spin)
		eff.physid = self:addTemporaryValue("combat_dam", eff.power_bonus * eff.spin)
		eff.spellid = self:addTemporaryValue("combat_spellpower", eff.power_bonus * eff.spin)
		eff.mentalid = self:addTemporaryValue("combat_mindpower", eff.power_bonus * eff.spin)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_atk", eff.atkid)
		self:removeTemporaryValue("combat_dam", eff.physid)
		self:removeTemporaryValue("combat_spellpower", eff.spellid)
		self:removeTemporaryValue("combat_mindpower", eff.mentalid)
	end,
}

newEffect{
	name = "FOLD_FATE", image = "talents/fold_fate.png",
	desc = "Fold Fate",
	kr_desc = "운명 폴딩",
	long_desc = function(self, eff) return ("목표는 끝에 다다르었습니다, 목표의 물리, 시간 저항이 %d%% 만큼 감소됩니다."):format(eff.power) end,
	type = "magical",
	subtype = { temporal=true },
	status = "detrimental",
	parameters = { power = 1 },
	on_gain = function(self, err) return "#Target# 끝에 다다르었습니다.", "+Fold Fate" end,
	activate = function(self, eff)
		eff.phys = self:addTemporaryValue("resists", { [DamageType.PHYSICAL] = -eff.power})
		eff.temp = self:addTemporaryValue("resists", { [DamageType.TEMPORAL] = -eff.power})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("resists", eff.phys)
		self:removeTemporaryValue("resists", eff.temp)
	end,
}

-- These are cosmetic so they can be cleared or clicked off
newEffect{
	name = "BEN_TETHER", image = "talents/spatial_tether.png",
	desc = "Spatial Tether",
	kr_desc = "공간의 사슬",
	long_desc = function(self, eff) 
		local chance = eff.chance * core.fov.distance(self.x, self.y, eff.x, eff.y)
		return ("목표는 특정 장소에 묶였습니다. %d%% 확율로 묶인 장소로 되돌아오며, 시작점과 도착점에 폭발을 일으켜 %0.2f 의 물리 피해와 %0.2f 의 시간 왜곡 피해를 입힙니다."):format(chance, eff.dam/2, eff.dam/2)
	end,
	type = "magical",
	subtype = { teleport=true, temporal=true },
	status = "beneficial",
	parameters = { chance = 1 },
	on_gain = function(self, err) return "#Target# 사슬에 묶입니다!", "+Tether" end,
	on_lose = function(self, err) return "#Target# 사슬에서 풀려납니다.", "-Tether" end,
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "DET_TETHER", image = "talents/spatial_tether.png",
	desc = "Spatial Tether",
	kr_desc = "공간의 사슬",
	long_desc = function(self, eff) 
		local chance = eff.chance * core.fov.distance(self.x, self.y, eff.x, eff.y)
		return ("목표는 특정 장소에 묶였습니다. %d%% 확율로 묶인 장소로 되돌아오며, 시작점과 도착점에 폭발을 일으켜 %0.2f 의 물리 피해와 %0.2f 의 시간 왜곡 피해를 입힙니다."):format(chance, eff.dam/2, eff.dam/2)
	end,
	type = "magical",
	subtype = { teleport=true, temporal=true },
	status = "detrimental",
	parameters = { chance = 1 },
	on_gain = function(self, err) return "#Target# has been tethered!", "+Tether" end,
	on_lose = function(self, err) return "#Target# is no longer tethered.", "-Tether" end,
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
	end,
}
