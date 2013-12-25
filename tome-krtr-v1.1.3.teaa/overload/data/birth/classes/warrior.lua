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
	name = "Warrior",
	kr_name = "전사 (Warrior)",
	desc = {
		"전사는 여러 가지 물리적 전투법을 수련합니다. 양손 대검을 휘두르는 파괴의 전차가 될 수도 있고, 번쩍이는 방패를 들고 온몸을 철갑옷으로 두른 수호자가 될 수도 있습니다.",
	},
	descriptor_choices =
	{
		subclass =
		{
			__ALL__ = "disallow",
			Berserker = "allow",
			Bulwark = "allow",
			Archer= "allow",
			Brawler = "allow",
			["Arcane Blade"] = "allow",
		},
	},
	copy = {
		max_life = 120,
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Berserker",
	kr_name = "광전사 (Berserker)",
	desc = {
		"광전사는 거대한 양손 무기를 휘둘러 적을 둘로 쪼개며, 고통과 죽음을 선사합니다.",
		"방어를 포기하고, 그들이 가장 잘 할 수 있는 일인 살육에 집중합니다.",
		"가장 중요한 능력치는 힘과 체격입니다.",
		"#GOLD#능력치 변화 :",
		"#LIGHT_BLUE# * 힘+5, 민첩+1, 체격+3",
		"#LIGHT_BLUE# * 마법+0, 의지+0, 교활+0",
		"#GOLD#레벨 당 생명력 :#LIGHT_BLUE# +3",
	},
	power_source = {technique=true},
	stats = { str=5, con=3, dex=1, },
	talents_types = {
		["technique/archery-training"]={false, 0.1},
		["technique/shield-defense"]={false, -0.1},
		["technique/2hweapon-offense"]={true, 0.3},
		["technique/2hweapon-cripple"]={true, 0.3},
		["technique/combat-techniques-active"]={true, 0.3},
		["technique/combat-techniques-passive"]={true, 0.3},
		["technique/combat-training"]={true, 0.3},
		["technique/conditioning"]={true, 0.3},
		["technique/superiority"]={false, 0.3},
		["technique/warcries"]={false, 0.3},
		["technique/field-control"]={false, 0},
		["technique/bloodthirst"]={false, 0.2},
		["cunning/survival"]={true, 0},
		["cunning/dirty"]={false, 0},
	},
	talents = {
		[ActorTalents.T_DEATH_DANCE] = 1,
		[ActorTalents.T_STUNNING_BLOW] = 1,
		[ActorTalents.T_WEAPON_COMBAT] = 1,
		[ActorTalents.T_ARMOUR_TRAINING] = 1,
	},
	copy = {
		resolvers.equip{ id=true,
			{type="weapon", subtype="greatsword", name="iron greatsword", autoreq=true, ego_chance=-1000, ego_chance=-1000},
			{type="armor", subtype="heavy", name="iron mail armour", autoreq=true, ego_chance=-1000, ego_chance=-1000},
		},
	},
	copy_add = {
		life_rating = 3,
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Bulwark",
	kr_name = "기사 (Bulwark)",
	desc = {
		"기사는 다양한 방어기술을 구사하며, 무기와 방패를 이용한 전투에 특화되었습니다",
		"훌륭한 기사는 전방위에서 닥치는 무시무시한 공격을 방패로 견뎌낼 수 있으며, 반격의 기회가 오면 엄청난 힘으로 적에게 달려듭니다.",
		"가장 중요한 능력치는 힘과 민첩입니다.",
		"#GOLD#능력치 변화 :",
		"#LIGHT_BLUE# * 힘+5, 민첩+2, 체격+2",
		"#LIGHT_BLUE# * 마법+0, 의지+0, 교활함+0",
		"#GOLD#레벨 당 생명력 :#LIGHT_BLUE# +2",
	},
	power_source = {technique=true},
	stats = { str=5, con=2, dex=2, },
	talents_types = {
		["technique/archery-training"]={false, 0.1},
		["technique/shield-offense"]={true, 0.3},
		["technique/shield-defense"]={true, 0.3},
		["technique/2hweapon-offense"]={false, -0.1},
		["technique/combat-techniques-active"]={true, 0.3},
		["technique/combat-techniques-passive"]={true, 0.3},
		["technique/combat-training"]={true, 0.3},
		["technique/conditioning"]={true, 0.3},
		["technique/superiority"]={false, 0.3},
		["technique/warcries"]={false, 0.3},
		["technique/battle-tactics"]={false, 0.3},
		["technique/field-control"]={false, 0},
		["cunning/survival"]={true, 0},
		["cunning/dirty"]={false, 0},
	},
	talents = {
		[ActorTalents.T_SHIELD_PUMMEL] = 1,
		[ActorTalents.T_SHIELD_WALL] = 1,
		[ActorTalents.T_WEAPON_COMBAT] = 1,
		[ActorTalents.T_ARMOUR_TRAINING] = 2,
	},
	copy = {
		resolvers.equip{ id=true,
			{type="weapon", subtype="longsword", name="iron longsword", autoreq=true, ego_chance=-1000, ego_chance=-1000},
			{type="armor", subtype="shield", name="iron shield", autoreq=true, ego_chance=-1000, ego_chance=-1000},
			{type="armor", subtype="heavy", name="iron mail armour", autoreq=true, ego_chance=-1000, ego_chance=-1000}
		},
	},
	copy_add = {
		life_rating = 2,
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Archer",
	kr_name = "궁수 (Archer)",
	desc = {
		"궁수는 적의 발을 묶거나 화살비를 퍼부을 수 있는 민첩한 사격수입니다.",
		"숙련된 궁수는 적을 불구로 만들어버리고, 발을 묶거나 관통하는 특수한 사격을 할 수 있습니다.",
		"활을 사용할 수도 있고, 투석구를 사용할 수 도 있습니다.",
		"가장 중요한 능력치는, 활을 사용할 때는 민첩과 힘이며, 투석구를 사용할 때는 민첩과 교활함입니다.",
		"#GOLD#능력치 변화 :",
		"#LIGHT_BLUE# * 힘+2, 민첩+5, 체격+0",
		"#LIGHT_BLUE# * 마법+0, 의지+0, 교활함+2",
		"#GOLD#레벨 당 생명력 :#LIGHT_BLUE# +0",
	},
	power_source = {technique=true, technique_ranged=true},
	stats = { dex=5, str=2, cun=2, },
	talents_types = {
		["technique/archery-training"]={true, 0.3},
		["technique/archery-utility"]={true, 0.3},
		["technique/archery-bow"]={true, 0.3},
		["technique/archery-sling"]={true, 0.3},
		["technique/archery-excellence"]={false, 0.3},
		["technique/combat-techniques-active"]={false, -0.1},
		["technique/combat-techniques-passive"]={true, -0.1},
		["technique/combat-training"]={true, 0.3},
		["technique/field-control"]={true, 0},
		["cunning/trapping"]={false, 0.2},
		["cunning/survival"]={true, 0},
		["cunning/dirty"]={false, 0},
	},
	unlockable_talents_types = {
		["cunning/poisons"]={false, 0.2, "rogue_poisons"},
	},
	talents = {
		[ActorTalents.T_FLARE] = 1,
		[ActorTalents.T_STEADY_SHOT] = 1,
		[ActorTalents.T_BOW_MASTERY] = 1,
		[ActorTalents.T_SLING_MASTERY] = 1,
		[ActorTalents.T_WEAPON_COMBAT] = 1,
	},
	copy = {
		max_life = 110,
		resolvers.equip{ id=true,
			{type="weapon", subtype="longbow", name="elm longbow", autoreq=true, ego_chance=-1000},
			{type="ammo", subtype="arrow", name="quiver of elm arrows", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="light", name="rough leather armour", autoreq=true, ego_chance=-1000},
		},
		resolvers.inventory{ id=true, inven="QS_MAINHAND",
			{type="weapon", subtype="sling", name="rough leather sling", autoreq=true, ego_chance=-1000},
		},
		resolvers.inventory{ id=true, inven="QS_QUIVER",
			{type="ammo", subtype="shot", name="pouch of iron shots", autoreq=true, ego_chance=-1000},
		},
		resolvers.generic(function(e)
			e.auto_shoot_talent = e.T_SHOOT
		end),
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Arcane Blade",
	kr_name = "마법 검사 (Arcane Blade)",
	desc = {
		"마법 검사는 마법에 재능이 있는 전사입니다.",
		"그들의 마법능력은 습득한 것이 아닌 선천적인 능력이기 때문에, 자연적으로 마나를 재생할 수 없으며 회복을 위해서는 다른 수단을 써야 합니다.",
		"사용할 수 있는 주문은 한정적이지만, 근접 공격에 주문을 실어 보낼 수 있는 독특한 능력을 가지고 있습니다.",
		"그들은 주로 양손무기에 이를 적용하여, 그들이 가져올 수 있는 가장 순수한 파괴를 일으킵니다.",
		"가장 중요한 능력치는 힘과 교활함, 그리고 마법입니다.",
		"#GOLD#능력치 변화 :",
		"#LIGHT_BLUE# * 힘+3, 민첩+0, 체격+0",
		"#LIGHT_BLUE# * 마법+3, 의지+0, 교활함+3",
		"#GOLD#레벨 당 생명력 :#LIGHT_BLUE# +2",
	},
	power_source = {technique=true, arcane=true},
	stats = { mag=3, str=3, cun=3},
	talents_types = {
		["spell/fire"]={true, 0.2},
		["spell/air"]={true, 0.2},
		["spell/earth"]={true, 0.2},
		["spell/conveyance"]={true, 0.2},
		["spell/aegis"]={true, 0.1},
		["spell/enhancement"]={true, 0.2},
		["technique/battle-tactics"]={false, 0.2},
		["technique/superiority"]={false, 0.2},
		["technique/combat-techniques-active"]={true, 0.1},
		["technique/combat-techniques-passive"]={false, 0.1},
		["technique/combat-training"]={true, 0.1},
		["technique/magical-combat"]={true, 0.3},
		["technique/shield-offense"]={false, 0},
		["technique/2hweapon-cripple"]={false, 0},
		["technique/dualweapon-attack"]={false, 0},
		["cunning/survival"]={true, 0.1},
		["cunning/dirty"]={true, 0.2},
	},
	unlockable_talents_types = {
		["spell/stone"]={false, 0.1, "mage_geomancer"},
	},
	birth_example_particles = {
		function(actor) if core.shader.active(4) then
			local slow = rng.percent(50)
			local h1x, h1y = actor:attachementSpot("hand1", true) if h1x then actor:addParticles(Particles.new("shader_shield", 1, {img="fireball", a=0.7, size_factor=0.4, x=h1x, y=h1y-0.1}, {type="flamehands", time_factor=slow and 700 or 1000})) end
			local h2x, h2y = actor:attachementSpot("hand2", true) if h2x then actor:addParticles(Particles.new("shader_shield", 1, {img="fireball", a=0.7, size_factor=0.4, x=h2x, y=h2y-0.1}, {type="flamehands", time_factor=not slow and 700 or 1000})) end
		end end,
		function(actor) if core.shader.active(4) then
			local slow = rng.percent(50)
			local h1x, h1y = actor:attachementSpot("hand1", true) if h1x then actor:addParticles(Particles.new("shader_shield", 1, {img="lightningwings", a=0.7, size_factor=0.4, x=h1x, y=h1y-0.1}, {type="flamehands", time_factor=slow and 700 or 1000})) end
			local h2x, h2y = actor:attachementSpot("hand2", true) if h2x then actor:addParticles(Particles.new("shader_shield", 1, {img="lightningwings", a=0.7, size_factor=0.4, x=h2x, y=h2y-0.1}, {type="flamehands", time_factor=not slow and 700 or 1000})) end
		end end,
	},
	talents = {
		[ActorTalents.T_FLAME] = 1,
		[ActorTalents.T_ARCANE_COMBAT] = 1,
		[ActorTalents.T_DIRTY_FIGHTING] = 1,
		[ActorTalents.T_WEAPON_COMBAT] = 1,
	},
	copy = {
		max_life = 100,
--		talent_cd_reduction={[ActorTalents.T_FLAME]=-3, [ActorTalents.T_LIGHTNING]=-3, [ActorTalents.T_EARTHEN_MISSILES]=-3, },
		resolvers.equip{ id=true,
			{type="weapon", subtype="greatsword", name="iron greatsword", autoreq=true, ego_chance=-1000, ego_chance=-1000},
			{type="armor", subtype="light", name="rough leather armour", autoreq=true, ego_chance=-1000, ego_chance=-1000},
		},
		resolvers.inscription("RUNE:_MANASURGE", {cooldown=25, dur=10, mana=620}),
	},
	copy_add = {
		life_rating = 2,
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Brawler",
	kr_name = "격투가 (Brawler)",
	locked = function() return profile.mod.allow_build.warrior_brawler end,
	locked_desc = "수많은 적들과 홀로 맞설지라도, 죽을 때까지 싸움밖에 허용되지 않는 운명일지라도, 그대는 굴하지 않는다. 피에 젖은 투기장에서, 그대는 두 주먹으로 세계와 대적하는 법을 배웠다.",
	desc = {
		"마법폭발의 참상으로 인해 군대가 분산되어 많은 이들이 국가의 보호를 받지 못하게 되었으며, 무기를 구할 수 없었던 사람들도 많았습니다.",
		"그래서 가난한 이들은 자신의 몸을 지키기 위해, 무기에 의지하지 않고 육체를 단련하기 시작했습니다.",
		"지하 격투가나 권투사, 혹은 그저 초보자일 뿐이라도, 격투의 기술은 여전히 유용합니다.",
		"격투가는 다양한 기술을 통해 연계 점수를 얻어, 더 강력한 마무리 기술을 날릴 수 있습니다.",
		"맨손 전투 방식은 움직이기 편하고 두 손이 비어 있어야 하기 때문에, 판갑이나 무기, 방패를 장비하면 기술을 사용할 수 없습니다.",
		"가장 중요한 능력치는 힘과 민첩, 그리고 교활함입니다.",
		"#GOLD#능력치 변화 :",
		"#LIGHT_BLUE# * 힘+3, 민첩+3, 체격+0",
		"#LIGHT_BLUE# * 마법+0, 의지+0, 교활함+3",
		"#GOLD#레벨 당 생명력 :#LIGHT_BLUE# +2",
	},
	power_source = {technique=true},
	stats = { str=3, dex=3, cun=3},
	talents_types = {
		["cunning/dirty"]={false, 0},
		["cunning/tactical"]={true, 0.3},
		["cunning/survival"]={false, 0},
		["technique/combat-training"]={true, 0.1},
		["technique/field-control"]={true, 0},
		["technique/combat-techniques-active"]={true, 0.1},
		["technique/combat-techniques-passive"]={true, 0.1},
		["technique/pugilism"]={true, 0.3},
		["technique/finishing-moves"]={true, 0.3},
		["technique/grappling"]={false, 0.3},
		["technique/unarmed-discipline"]={false, 0.3},
		["technique/unarmed-training"]={true, 0.3},
		["technique/conditioning"]={true, 0.3},
		["technique/mobility"]={true, 0.2},
	},
	talents = {
		[ActorTalents.T_UPPERCUT] = 1,
		[ActorTalents.T_DOUBLE_STRIKE] = 1,
		[ActorTalents.T_WEAPON_COMBAT] = 1,
		[ActorTalents.T_ARMOUR_TRAINING] = 1,
	},
	copy = {
		resolvers.equip{ id=true,
			{type="armor", subtype="hands", name="iron gauntlets", autoreq=true, ego_chance=-1000, ego_chance=-1000},
			{type="armor", subtype="light", name="rough leather armour", autoreq=true, ego_chance=-1000, ego_chance=-1000},
		},
		resolvers.inventory{ id=true,
			{type="armor", subtype="hands", name="rough leather gloves", ego_chance=-1000, ego_chance=-1000},
		},
	},
	copy_add = {
		life_rating = 2,
	},
}
