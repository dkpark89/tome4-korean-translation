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

local Particles = require "engine.Particles"

newBirthDescriptor{
	type = "class",
	name = "Wilder",
	kr_name = "자연의 추종자 (Wilder)",
	locked = function() return profile.mod.allow_build.wilder_wyrmic or profile.mod.allow_build.wilder_summoner or profile.mod.allow_build.wilder_stone_warden end,
	locked_desc = "자연의 힘은 단순한 기술을 능가하는 위력을 지녔으니, 자연의 진정한 힘을 경험하고 놀라운 은총을 배우라.",
	desc = {
		"자연의 추종자들은 여러 방법으로 자연과 하나가 된 자들입니다. 자연이 보여주는 여러 모습만큼이나 다양한 추종자들이 존재합니다.",
		"어떤 생물의 능력을 흉내내거나, 자신의 곁으로 소환할 수도 있습니다.",
	},
	descriptor_choices =
	{
		subclass =
		{
			__ALL__ = "disallow",
			Summoner = "allow",
			Wyrmic = "allow",
			Oozemancer = "allow",
		},
	},
	copy = {
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Summoner",
	kr_name = "소환술사 (Summoner)",
	locked = function() return profile.mod.allow_build.wilder_summoner end,
	locked_desc = "모든 힘이 몸 안에서 나오는 것은 아니다. 자연의 기도를 들어보라, 그 힘을 느껴보라. 우리의 진정한 힘을 찾을 수 없을 때에는 두 눈으로 직접 보고 배우라.",
	desc = {
		"소환술사는 결코 혼자 싸우지 않습니다. 그들은 자신의 곁에서 싸울 부하를 부를 준비가 항상 되어 있습니다.",
		"전투용 개에서부터 화염 비룡까지도 소환할 수 있습니다.",
		"가장 중요한 능력치는 의지와 교활함입니다.",
		"#GOLD#능력치 변화 :",
		"#LIGHT_BLUE# * 힘+0, 민첩+1, 체격+0",
		"#LIGHT_BLUE# * 마법+0, 의지+5, 교활함+3",
		"#GOLD#레벨 당 생명력 :#LIGHT_BLUE# +0",
	},
	power_source = {nature=true},
	getStatDesc = function(stat, actor)
		if stat == actor.STAT_CUN then
			return "최대 소환수 : "..math.floor(actor:getCun()/10)
		end
	end,
	stats = { wil=5, cun=3, dex=1, },
	birth_example_particles = {
		function(actor)
			if actor:addShaderAura("master_summoner", "awesomeaura", {time_factor=6200, alpha=0.7, flame_scale=0.8}, "particles_images/naturewings.png") then
			elseif core.shader.active(4) then actor:addParticles(Particles.new("shader_ring_rotating", 1, {radius=1.1}, {type="flames", zoom=2, npow=4, time_factor=4000, color1={0.2,0.7,0,1}, color2={0,1,0.3,1}, hide_center=0, xy={self.x, self.y}}))
			else actor:addParticles(Particles.new("master_summoner", 1))
			end
		end,
	},
	talents_types = {
		["wild-gift/call"]={true, 0.2},
		["wild-gift/harmony"]={false, 0.1},
		["wild-gift/summon-melee"]={true, 0.3},
		["wild-gift/summon-distance"]={true, 0.3},
		["wild-gift/summon-utility"]={true, 0.3},
		["wild-gift/summon-augmentation"]={false, 0.3},
		["wild-gift/summon-advanced"]={false, 0.3},
		["wild-gift/mindstar-mastery"]={false, 0.1},
		["cunning/survival"]={true, 0},
		["technique/combat-techniques-active"]={false, 0},
		["technique/combat-techniques-passive"]={false, 0},
		["technique/combat-training"]={true, 0},
	},
	talents = {
		[ActorTalents.T_WAR_HOUND] = 1,
		[ActorTalents.T_RITCH_FLAMESPITTER] = 1,
		[ActorTalents.T_MEDITATION] = 1,
		[ActorTalents.T_HEIGHTENED_SENSES] = 1,
	},
	copy = {
		max_life = 90,
		resolvers.equip{ id=true,
			{type="weapon", subtype="mindstar", name="mossy mindstar", autoreq=true, ego_chance=-1000},
			{type="weapon", subtype="mindstar", name="mossy mindstar", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="light", name="rough leather armour", autoreq=true, ego_chance=-1000},
		},
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Wyrmic",
	kr_name = "용인 (Wyrmic)",
	locked = function() return profile.mod.allow_build.wilder_wyrmic end,
	locked_desc = " 우리는 용의 길을 걸으며, 그들의 숨결은 우리의 숨결이다. 그들의 맥동하는 심장을 보고, 이빨로 그들의 위엄을 맛보라.",
	desc = {
		"용인은 용의 능력을 흉내내는 법을 배운 전사입니다.",
		"그들은 다양한 종류의 용들이 가진 능력을 사용할 수 있습니다.",
		"가장 중요한 능력치는 힘과 의지입니다.",
		"#GOLD#능력치 변화 :",
		"#LIGHT_BLUE# * 힘+5, 민첩+0, 체격+1",
		"#LIGHT_BLUE# * 마법+0, 의지+3, 교활함+0",
		"#GOLD#레벨 당 생명력 :#LIGHT_BLUE# +2",
	},
	birth_example_particles = {
		function(actor) if core.shader.active(4) then local x, y = actor:attachementSpot("back", true) actor:addParticles(Particles.new("shader_wings", 1, {x=x, y=y, life=18, fade=-0.006, deploy_speed=14})) end end,
		function(actor) if core.shader.active(4) then local x, y = actor:attachementSpot("back", true) actor:addParticles(Particles.new("shader_wings", 1, {x=x, y=y, img="lightningwings", life=18, fade=-0.006, deploy_speed=14})) end end,
		function(actor) if core.shader.active(4) then local x, y = actor:attachementSpot("back", true) actor:addParticles(Particles.new("shader_wings", 1, {x=x, y=y, img="poisonwings", life=18, fade=-0.006, deploy_speed=14})) end end,
		function(actor) if core.shader.active(4) then local x, y = actor:attachementSpot("back", true) actor:addParticles(Particles.new("shader_wings", 1, {x=x, y=y, img="acidwings", life=18, fade=-0.006, deploy_speed=14})) end end,
		function(actor) if core.shader.active(4) then local x, y = actor:attachementSpot("back", true) actor:addParticles(Particles.new("shader_wings", 1, {x=x, y=y, img="sandwings", life=18, fade=-0.006, deploy_speed=14})) end end,
		function(actor) if core.shader.active(4) then local x, y = actor:attachementSpot("back", true) actor:addParticles(Particles.new("shader_wings", 1, {x=x, y=y, img="icewings", life=18, fade=-0.006, deploy_speed=14})) end end,
	},
	power_source = {nature=true, technique=true},
	stats = { str=5, wil=3, con=1, },
	talents_types = {
		["wild-gift/call"]={true, 0.2},
		["wild-gift/harmony"]={false, 0.1},
		["wild-gift/sand-drake"]={true, 0.3},
		["wild-gift/fire-drake"]={true, 0.3},
		["wild-gift/cold-drake"]={true, 0.3},
		["wild-gift/storm-drake"]={true, 0.3},
		["wild-gift/venom-drake"]={true, 0.3},
		["wild-gift/higher-draconic"]={false, 0.3},
		["wild-gift/fungus"]={true, 0.1},
		["cunning/survival"]={false, 0},
		["technique/shield-offense"]={true, 0.1},
		["technique/2hweapon-offense"]={true, 0.1},
		["technique/combat-techniques-active"]={false, 0},
		["technique/combat-techniques-passive"]={true, 0},
		["technique/combat-training"]={true, 0},
	},
	talents = {
		[ActorTalents.T_ICE_CLAW] = 1,
		[ActorTalents.T_MEDITATION] = 1,
		[ActorTalents.T_WEAPONS_MASTERY] = 1,
		[ActorTalents.T_WEAPON_COMBAT] = 1,
	},
	copy = {
		drake_touched = 2,
		max_life = 110,
		resolvers.equip{ id=true,
			{type="weapon", subtype="battleaxe", name="iron battleaxe", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="light", name="rough leather armour", autoreq=true, ego_chance=-1000}
		},
	},
	copy_add = {
		life_rating = 2,
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Oozemancer",
	kr_name = "점액술사 (Oozemancer)",
	locked = function() return profile.mod.allow_build.wilder_oozemancer end,
	locked_desc = "마법은 실패해야 하고, 마법은 사라져야 한다. 그 어떤 마법도 점액 앞에서는 고개를 들지 못할 것일지...",
	desc = {
		"점액술사들은 스스로 일반적인 문명과 거리를 두어, 자신과 자연이 더욱 조화되도록 만듭니다. 이들은 마법적 힘을 욕하며, 야생과의 자연적인 감응력을 통해 저 존재 자체가 모욕이나 마찬가지인 마법 사용자들과 대등하게 싸워나갑니다.",
		"이들은 점액을 내뿜어 자신을 보호하며, 마석과 염동 칼의 힘을 사용하여 멀리 떨어진 적까지 공격할 수 있니다.",
		"가장 중요한 능력치는 의지와 교활함입니다.",
		"#GOLD#능력치 변화 :",
		"#LIGHT_BLUE# * 힘+0, 민첩+0, 체격+0",
		"#LIGHT_BLUE# * 마법+0, 의지+5, 교활함+4",
		"#GOLD#레벨 당 생명력 :#LIGHT_BLUE# -3",
	},
	power_source = {nature=true},
	random_rarity = 3,
	getStatDesc = function(stat, actor)
		if stat == actor.STAT_CUN then
			return "최대 소환수 : "..math.floor(actor:getCun()/10)
		end
	end,
	birth_example_particles = {
		function(actor)
			if core.shader.active(4) then actor:addParticles(Particles.new("shader_ring_rotating", 1, {additive=true, radius=1.1}, {type="flames", zoom=5, npow=2, time_factor=9000, color1={0.5,0.7,0,1}, color2={0.3,1,0.3,1}, hide_center=0, xy={0,0}}))
			else actor:addParticles(Particles.new("master_summoner", 1))
			end
		end,
		function(actor)
			if core.shader.active(4) then actor:addParticles(Particles.new("shader_ring_rotating", 1, {additive=true, radius=1.1}, {type="flames", zoom=0.5, npow=4, time_factor=2000, color1={0.5,0.7,0,1}, color2={0.3,1,0.3,1}, hide_center=0, xy={0,0}}))
			else actor:addParticles(Particles.new("master_summoner", 1))
			end
		end,
	},
	stats = { wil=5, cun=4, },
	talents_types = {
		["cunning/survival"]={true, 0.1},
		["wild-gift/call"]={true, 0.3},
		["wild-gift/antimagic"]={true, 0.3},
		["wild-gift/mindstar-mastery"]={true, 0.3},
		["wild-gift/mucus"]={true, 0.3},
		["wild-gift/ooze"]={true, 0.3},
		["wild-gift/fungus"]={false, 0.3},
		["wild-gift/oozing-blades"]={false, 0.3},
		["wild-gift/corrosive-blades"]={false, 0.3},
		["wild-gift/moss"]={true, 0.3},
--		["wild-gift/malleable-body"]={true, 0.3},
		["wild-gift/slime"]={true, 0.3},
	},
	talents = {
		[ActorTalents.T_PSIBLADES] = 1,
		[ActorTalents.T_MITOSIS] = 1,
		[ActorTalents.T_MUCUS] = 1,
		[ActorTalents.T_SLIME_SPIT] = 1,
	},
	copy = {
		forbid_arcane = 2,
		max_life = 90,
		resolvers.equip{ id=true,
			{type="weapon", subtype="mindstar", name="mossy mindstar", autoreq=true, ego_chance=-1000},
			{type="weapon", subtype="mindstar", name="mossy mindstar", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="cloth", name="linen robe", autoreq=true, ego_chance=-1000},
		},
	},
	copy_add = {
		life_rating = -3,
	},
}
