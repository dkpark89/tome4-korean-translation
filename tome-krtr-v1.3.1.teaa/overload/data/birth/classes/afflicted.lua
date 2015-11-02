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

local Particles = require "engine.Particles"

newBirthDescriptor{
	type = "class",
	name = "Afflicted",
	kr_name = "고통받는 자 (Afflicted)",
	locked = function() return profile.mod.allow_build.afflicted end,
	locked_desc = "사랑받지도 못하고, 아무도 원하지 않는 자가 외로이 그림자 속을 걷는다. 휘두르는 힘이 강대할지는 모르나, 그 이름은 영원히 저주받으리라.",
	desc = {
		"고통받는 자들은 사악한 힘에 의존한 탓으로 미쳐버렸습니다.",
		"비록 그 힘은 강력하며 유용하게 사용할 수도 있겠지만, 그 대가는...",
	},
	descriptor_choices =
	{
		subclass =
		{
			__ALL__ = "disallow",
			Cursed = "allow",
			Doomed = "allow",
		},
	},
	copy = {
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Cursed",
	kr_name = "저주받은 자 (Cursed)",
	locked = function() return profile.mod.allow_build.afflicted_cursed end,
	locked_desc = "고통은 영혼에까지 이를 수 있으며, 누군가를 증오로 가득 채울 수도 있다. 타인의 증오 서린 저주를 제압하여, 그 섬뜩한 의미를 알라.",
	desc = {
		"무지, 탐욕, 어리석음으로 인해 저주받은 자들은 어둠의 세력을 섬겼었고, 결국 자신이 지은 죄의 대가로 파멸하였습니다.",
		"이제 그 몸을 지배하는 것은 모든 생명체에 대한 증오 뿐입니다.",
		"이들과 마주친 자들의 죽음에서 끌어낸 힘으로, 저주받은 자들은 끔찍한 살육자가 됩니다.",
		"더 나쁜 사실은, 저주받은 자들에게 다가선 자는 누구라도 그 끔찍한 기운에 홀려 미쳐버린다는 것입니다.",
		"가장 중요한 능력치는 힘과 의지입니다",
		"#GOLD#능력치 변화 :",
		"#LIGHT_BLUE# * 힘+5, 민첩+0, 체격+0",
		"#LIGHT_BLUE# * 마법+0, 의지+4, 교활함+0",
		"#GOLD#레벨 당 생명력 :#LIGHT_BLUE# +2",
	},
	power_source = {psionic=true, technique=true},
	stats = { wil=4, str=5, },
	birth_example_particles = {
		function(actor)
			if not actor:addShaderAura("rampage", "awesomeaura", {time_factor=5000, alpha=0.7}, "particles_images/bloodwings.png") then
				actor:addParticles(Particles.new("rampage", 1))
			end
		end,
	},
	talents_types = {
		["cursed/gloom"]={true, 0.3},
		["cursed/slaughter"]={true, 0.3},
		["cursed/endless-hunt"]={true, 0.3},
		["cursed/strife"]={true, 0.3},
		["cursed/cursed-form"]={true, 0.0},
		["cursed/unyielding"]={true, 0.0},
		["technique/combat-training"]={true, 0.3},
		["cunning/survival"]={false, 0.0},
		["cursed/rampage"]={false, 0.0},
		["cursed/predator"]={false, 0.0},
		["cursed/fears"]={false, 0.0},
	},
	talents = {
		[ActorTalents.T_UNNATURAL_BODY] = 1,
		[ActorTalents.T_GLOOM] = 1,
		[ActorTalents.T_SLASH] = 1,
		[ActorTalents.T_WEAPONS_MASTERY] = 1,
		[ActorTalents.T_WEAPON_COMBAT] = 1,
		[ActorTalents.T_ARMOUR_TRAINING] = 1,
	},
	copy = {
		max_life = 110,
		resolvers.equipbirth{ id=true,
			{type="weapon", subtype="battleaxe", name="iron battleaxe", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="heavy", name="iron mail armour", autoreq=true, ego_chance=-1000, ego_chance=-1000}
		},
		chooseCursedAuraTree = true
	},
	copy_add = {
		life_rating = 2,
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Doomed",
	kr_name = "파멸당한 자 (Doomed)",
	locked = function() return profile.mod.allow_build.afflicted_doomed end,
	locked_desc = "미지의 땅, 그늘진 곳에서 그대는 그 자신을 제압하고 그 자신의 파멸을 두 눈으로 지켜봐야 하리라.",
	desc = {
		"파멸당한 자들은 야심과 어둠의 계약으로 얻은 강력한 마법을 휘두르던, 타락한 마법사였습니다.",
		"그들이 섬기던 어둠의 힘에 의해 마법을 빼앗긴 뒤로는, 마음 속에 불타오르는 증오심을 이용하는 방법을 배워야 했습니다.",
		"새로운 길을 선택할 수 있을지, 아니면 영원히 파멸당한 채로 남아있을지는 시간이 지나야 알 수 있을 것입니다.",
		"파멸당한 자들은 어둠의 장막 뒤에 숨어 적을 공격하거나, 그림자의 주인이 될 수 있습니다.",
		"정신력을 적에게 퍼부어서, 그들과 대적하는 모든 자들을 포식하기도 합니다.",
		"가장 중요한 능력치는 의지와 교활함입니다",
		"#GOLD#능력치 변화 :",
		"#LIGHT_BLUE# * 힘+0, 민첩성+0, 체격+0",
		"#LIGHT_BLUE# * 마법+0, 의지+4, 교활함+5",
		"#GOLD#레벨 당 생명력 :#LIGHT_BLUE# +0",
	},
	power_source = {psionic=true},
	random_rarity = 2,
	stats = { wil=4, cun=5, },
	talents_types = {
		["cursed/dark-sustenance"]={true, 0.3},
		["cursed/force-of-will"]={true, 0.3},
		["cursed/gestures"]={true, 0.3},
		["cursed/punishments"]={true, 0.3},
		["cursed/shadows"]={true, 0.3},
		["cursed/darkness"]={true, 0.3},
		["cursed/cursed-form"]={true, 0.0},
		["cunning/survival"]={false, 0.0},
		["cursed/fears"]={false, 0.0},
		["cursed/one-with-shadows"]={false, 0.3},
	},
	talents = {
		[ActorTalents.T_UNNATURAL_BODY] = 1,
		[ActorTalents.T_FEED] = 1,
		[ActorTalents.T_GESTURE_OF_PAIN] = 1,
		[ActorTalents.T_WILLFUL_STRIKE] = 1,
		[ActorTalents.T_CALL_SHADOWS] = 1,
	},
	copy = {
		max_life = 90,
		resolvers.equipbirth{ id=true,
			{type="weapon", subtype="mindstar", name="mossy mindstar", autoreq=true, ego_chance=-1000},
			{type="weapon", subtype="mindstar", name="mossy mindstar", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="cloth", name="linen robe", autoreq=true, ego_chance=-1000},
		},
		chooseCursedAuraTree = true
	},
	copy_add = {
	},
}
