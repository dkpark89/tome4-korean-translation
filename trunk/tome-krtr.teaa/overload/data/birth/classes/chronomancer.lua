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

newBirthDescriptor{
	type = "class",
	name = "Chronomancer",
	display_name = "시공 제어사 (Chronomancer)",
	locked = function() return profile.mod.allow_build.chronomancer end,
	locked_desc = "평범히 인생을 시간에 흘려보내지 않고, 시간의 샛길을 거니는 자들도 있다.",
	desc = {
		"말 그대로 한쪽 발은 과거를, 다른쪽 발은 미래를 딛고 있는 시공 제어사는, 멋대로 현실을 주무르며 섭리의 자정작용에만 복종하는 힘으로 무장했습니다. 그들이 시공에 남긴 괴리는 시간을 제어하는 힘을 더욱 강대하고 제어하기 어렵게 만듭니다. 현명한 시공 제어사는 자신의 힘을 증폭시키기 위해 시공에 낸 구멍이 자신을 삼켜버릴 구멍이 될 수도 있다는 것을 알기에, 힘에 대한 갈망과, 섭리를 수호하기 위한 대우주의 의지 사이에서 균형을 유지하는 방법을 배웁니다.",
	},
	descriptor_choices =
	{
		subclass =
		{
			__ALL__ = "disallow",
			["Paradox Mage"] = "allow",
			["Temporal Warden"] = "allow",
		},
	},
	copy = {
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Paradox Mage",
	display_name = "괴리 마법사 (Paradox Mage)",
	locked = function() return profile.mod.allow_build.chronomancer_paradox_mage end,
	locked_desc = "일시에 반대방향으로도 힘을 가할 수 있다면 한손만 가지고도 박수를 칠 수 있으니, 괴리에서 힘을 구하라.",
	desc = {
		"괴리 마법사는 시공간의 구조를 연구하여 시공을 구부리는 것만이 아니라, 형성하기도하고 재구성하기도 합니다.",
		"괴리 마법사는 기본적인 전투기술이 떨어지지만, 대신 시공을 제어하는 강력한 힘을 지녔습니다.",
		"괴리 마법사는 정교한 시공 제어 마법 이외엔 아는 것이 거의 없습니다.",
		"가장 중요한 능력치는 마법과 의지입니다.",
		"#GOLD#능력치 변경:",
		"#LIGHT_BLUE# * 힘+0, 민첩+0, 체격+0",
		"#LIGHT_BLUE# * 마법+5, 의지+3, 교활함+1",
		"#GOLD#레벨 당 생명력:#LIGHT_BLUE# -4",
	},
	power_source = {arcane=true},
	stats = { mag=5, wil=3, cun=1, },
	talents_types = {
		["chronomancy/age-manipulation"]={true, 0.3},
	--	["chronomancy/anomalies"]={true, 0},
		["chronomancy/chronomancy"]={true, 0.3},
		["chronomancy/energy"]={true, 0.3},
		["chronomancy/gravity"]={true, 0.3},
		["chronomancy/matter"]={true, 0.3},
		["chronomancy/paradox"]={false, 0.3},
		["chronomancy/speed-control"]={true, 0.3},
		["chronomancy/timeline-threading"]={false, 0.3},
		["chronomancy/timetravel"]={true, 0.3},
		["chronomancy/spacetime-weaving"]={true, 0.3},
		["cunning/survival"]={false, 0},
	},
	talents = {
		[ActorTalents.T_SPACETIME_TUNING] = 1,
		[ActorTalents.T_STATIC_HISTORY] = 1,
		[ActorTalents.T_DIMENSIONAL_STEP] = 1,
		[ActorTalents.T_DUST_TO_DUST] = 1,
		[ActorTalents.T_TURN_BACK_THE_CLOCK] = 1,
	},
	copy = {
		max_life = 90,
		resolvers.equip{ id=true,
			{type="weapon", subtype="staff", name="elm staff", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="cloth", name="linen robe", autoreq=true, ego_chance=-1000},
		},
	},
	copy_add = {
		life_rating = -4,
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Temporal Warden",
	display_name = "시간의 감시자 (Temporal Warden)",
	locked = function() return profile.mod.allow_build.chronomancer_temporal_warden end,
	locked_desc = "우리는 미래를 위해 과거를 수호한다. 시간의 손길을 보호하는 것은 전투의 병기일지니.",
	desc = {
		"시간의 감시자는 사격술과 쌍수 무기술, 그리고 시공 제어 마법을 조합하여 엄청난 결과를 만들어냈습니다.",
		"적들에게 화살을 퍼붓고 근접전을 벌이면서, 시공 제어 마법으로 전장을 다스립니다.",
		"시공 제어 마법을 연구하여, 신체와 마법능력을 증폭시키고 자신과 다른이들의 속도를 제어할 수 있게 되었습니다.",
		"가장 중요한 능력치는 힘과 민첩, 의지, 그리고 마법입니다.",
		"#GOLD#능력치 변경:",
		"#LIGHT_BLUE# * 힘+2, 민첩+3, 체격+0",
		"#LIGHT_BLUE# * 마법+2, 의지+2, 교활함+0",
		"#GOLD#레벨 당 생명력:#LIGHT_BLUE# +0",
	},
	power_source = {technique=true, arcane=true},
	stats = { str=2, wil=2, dex=3, mag=2},
	talents_types = {
		["technique/archery-bow"]={true, 0},
		["technique/archery-utility"]={false, 0},
		["technique/dualweapon-attack"]={true, 0},
		["technique/dualweapon-training"]={false, 0},
		["technique/combat-training"]={true, 0.1},
		["cunning/survival"]={false, 0},
		["chronomancy/chronomancy"]={true, 0.1},
		["chronomancy/speed-control"]={true, 0.1},
	--	["chronomancy/temporal-archery"]={true, 0.3},
		["chronomancy/temporal-combat"]={true, 0.3},
		["chronomancy/timetravel"]={false, 0},
		["chronomancy/spacetime-weaving"]={true, 0},
		["chronomancy/spacetime-folding"]={true, 0.3},
	},
	birth_example_particles = "temporal_focus",
	talents = {
		[ActorTalents.T_SHOOT] = 1,
		[ActorTalents.T_SPACETIME_TUNING] = 1,
		[ActorTalents.T_WEAPON_COMBAT] = 1,
		[ActorTalents.T_DUAL_STRIKE] = 1,
		[ActorTalents.T_CELERITY] = 1,
		[ActorTalents.T_STRENGTH_OF_PURPOSE] = 1,
	},
	copy = {
		max_life = 100,
		resolvers.equip{ id=true,
			{type="weapon", subtype="longsword", name="iron longsword", autoreq=true, ego_chance=-1000},
			{type="weapon", subtype="dagger", name="iron dagger", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="light", name="rough leather armour", autoreq=true, ego_chance=-1000},
		},
		resolvers.inventory{ id=true, inven="QS_MAINHAND",
			{type="weapon", subtype="longbow", name="elm longbow", autoreq=true, ego_chance=-1000},
		},
		resolvers.inventory{ id=true, inven="QS_QUIVER",
			{type="ammo", subtype="arrow", name="quiver of elm arrows", autoreq=true, ego_chance=-1000},
		},
	},
}
