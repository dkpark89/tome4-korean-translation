-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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

local Stats = require "engine.interface.ActorStats"

newEntity{
	define_as = "BASE_GEM",
	type = "gem", subtype="white",
	display = "*", color=colors.YELLOW,
	encumber = 0, slot = "GEM", use_no_wear = true,
	identified = true,
	stacking = true,
	auto_pickup = true, pickup_sound = "actions/gem",
	desc = [[보석은 돈을 마련하기 위해 팔 수도 있고, 다양한 마법에 사용할 수도 있습니다.]],
}

local gem_color_attributes = {
	black = {
		damage_type = 'ACID',
		alt_damage_type = 'ACID_DISARM',
		particle = 'acid',},
	blue = {
		damage_type = 'LIGHTNING',
		alt_damage_type = 'LIGHTNING_DAZE',
		particle = 'lightning_explosion',},
	green = {
		damage_type = 'NATURE',
		alt_damage_type = 'SPYDRIC_POISON',
		particle = 'slime',},
	red = {
		damage_type = 'FIRE',
		alt_damage_type = 'FLAMESHOCK',
		particle = 'flame',},
	violet = {
		damage_type = 'ARCANE',
		alt_damage_type = 'ARCANE_SILENCE',
		particle = 'manathrust',},
	white = {
		damage_type = 'COLD',
		alt_damage_type = 'ICE',
		particle = 'freeze',},
	yellow = {
		damage_type = 'LIGHT',
		alt_damage_type = 'LIGHT_BLIND',
		particle = 'light',},}

-- Let addons alter colors before the gems are created. This is weird,
-- since there's no base class to call it for, since it's just a
-- table. To bind:
-- class.bindHook('GemColorAttributes', function(gem_color_attributes) ... end)
class.triggerHook(gem_color_attributes, {'GemColorAttributes',})

local function newGem(name, kr_name, image, cost, rarity, color, min_level, max_level, tier, power, imbue, bomb)
	-- Gems, randomly lootable
	newEntity{ base = "BASE_GEM", define_as = "GEM_"..name:gsub(" ", "_"):upper(),
		name = name:lower(), subtype = color,
		kr_name = kr_name,
		color = colors[color:upper()], image=image,
		level_range = {min_level, max_level},
		rarity = rarity, cost = cost * 10,
		material_level = tier,
		imbue_powers = imbue,
		wielder = imbue,
		attack_type = gem_color_attributes[color].damage_type, -- deprecated, hopefully nothing's still using it.
		color_attributes = gem_color_attributes[color],
	}
	-- Alchemist gems, not lootable, only created by talents
	newEntity{ base = "BASE_GEM", define_as = "ALCHEMIST_GEM_"..name:gsub(" ", "_"):upper(),
		kr_name = "연금술 "..(kr_name or name):lower(),
		name = "alchemist "..name:lower(), type='alchemist-gem', subtype = color, --@ kr_name 작업을 위해 일부러 줄 바꿈
		slot = "QUIVER",
		moddable_tile = "gembag",
		use_no_wear = false,
		color = colors[color:upper()], image=image,
		cost = cost * 0.01,
		material_level = tier,
		alchemist_power = power,
		alchemist_bomb = bomb,
	}
end

newGem("Diamond",	"다이아몬드",	"object/diamond.png",5,		18,	"white",	40,	50, 5, 70,
	{ inc_stats = { [Stats.STAT_STR] = 5, [Stats.STAT_DEX] = 5, [Stats.STAT_MAG] = 5, [Stats.STAT_WIL] = 5, [Stats.STAT_CUN] = 5, [Stats.STAT_CON] = 5, } },
	{ power=25 }
)
newGem("Pearl",	"진주",	"object/pearl.png",	5,		18,	"white",	40,	50, 5, 70,
	{ resists = {all=5}, combat_armor = 5 },
	{ splash={type="LITE", dam=100, desc = "지형 밝히기 (세기 100)"} }
)
newGem("Moonstone",	"월장석",	"object/moonstone.png",5,	18,	"white",	40,	50, 5, 70,
	{ combat_def=10, combat_mentalresist=10, combat_spellresist=10, combat_physresist=10, },
	{ stun={chance=20, dur=3} }
)
newGem("Fire Opal",	"화단백석",	"object/fireopal.png",5,	18,	"red",		40,	50, 5, 70,
	{ inc_damage = {all=10}, combat_physcrit=5, combat_mindcrit=5, combat_spellcrit=5,  },
	{ splash={type="FIRE", dam=40} }
)
newGem("Bloodstone",	"혈석",	"object/bloodstone.png",5,	18,	"red",		40,	50, 5, 70,
	{ stun_immune=0.6 },
	{ leech=10 }
)
newGem("Ruby",	"루비",		"object/ruby.png",	4,	16,	"red",		30,	40, 4, 65,
	{ inc_stats = { [Stats.STAT_STR] = 4, [Stats.STAT_DEX] = 4, [Stats.STAT_MAG] = 4, [Stats.STAT_WIL] = 4, [Stats.STAT_CUN] = 4, [Stats.STAT_CON] = 4, } },
	{ power=20 }
)
newGem("Amber",	"호박",		"object/amber.png",	4,	16,	"yellow",	30,	40, 4, 65,
	{ inc_damage = {all=8}, combat_physcrit=4, combat_mindcrit=4, combat_spellcrit=4, },
	{ stun={chance=10, dur=2} }
)
newGem("Turquoise",	"터키옥",	"object/turquoise.png",4,	16,	"green",	30,	40, 4, 65,
	{ see_invisible=10, see_stealth=10 },
	{ splash={type="ACID", dam=30} }
)
newGem("Jade",	"비취",		"object/jade.png",	4,	16,	"green",	30,	40, 4, 65,
	{ resists = {all=4}, combat_armor = 4 },
	{ splash={type="SLOW", dam= 1 - 1 / (1 + 0.20), desc = "17% 감속"} }
)
newGem("Sapphire",	"사파이어",	"object/sapphire.png",4,	16,	"blue",		30,	40, 4, 65,
	{ combat_def=8, combat_mentalresist=8, combat_spellresist=8, combat_physresist=8, },
	{ splash={type="ICE", dam=30} }
)
newGem("Quartz",	"석영",	"object/quartz.png",3,	12,	"white",	20,	30, 3, 50,
	{ stun_immune=0.3 },
	{ splash={type="SPELLKNOCKBACK", dam=10} }
)
newGem("Emerald",	"에메랄드",	"object/emerald.png",3,	12,	"green",	20,	30, 3, 50,
	{ resists = {all=3}, combat_armor = 3 },
	{ splash={type="POISON", dam=50} }
)
newGem("Lapis Lazuli",	"청금석",	"object/lapis_lazuli.png",3,	12,	"blue",		20,	30, 3, 50,
	{ combat_def=6, combat_mentalresist=6, combat_spellresist=6, combat_physresist=6, },
	{ mana=30 }
)
newGem("Garnet",	"석류석",	"object/garnet.png",3,	12,	"red",		20,	30, 3, 50,
	{ inc_damage = {all=6}, combat_physcrit=3, combat_mindcrit=3, combat_spellcrit=3, },
	{ leech=5 }
)
newGem("Onyx",	"오닉스",		"object/onyx.png",	3,	12,	"black",	20,	30, 3, 50,
	{ inc_stats = { [Stats.STAT_STR] = 3, [Stats.STAT_DEX] = 3, [Stats.STAT_MAG] = 3, [Stats.STAT_WIL] = 3, [Stats.STAT_CUN] = 3, [Stats.STAT_CON] = 3, } },
	{ power=15 }
)
newGem("Amethyst",	"자수정",	"object/amethyst.png",2,	10,	"violet",	10,	20, 2, 35,
	{ inc_damage = {all=4}, combat_physcrit=2, combat_mindcrit=2, combat_spellcrit=2, },
	{ splash={type="ARCANE", dam=25}}
)
newGem("Opal",	"오팔",		"object/opal.png",	2,	10,	"blue",		10,	20, 2, 35,
	{ inc_stats = { [Stats.STAT_STR] = 2, [Stats.STAT_DEX] = 2, [Stats.STAT_MAG] = 2, [Stats.STAT_WIL] = 2, [Stats.STAT_CUN] = 2, [Stats.STAT_CON] = 2, } },
	{ power=10 }
)
newGem("Topaz",	"황옥",		"object/topaz.png",	2,	10,	"blue",		10,	20, 2, 35,
	{ combat_def=4, combat_mentalresist=4, combat_spellresist=4, combat_physresist=4, },
	{ range=3 }
)
newGem("Aquamarine",	"남옥",	"object/aquamarine.png",2,	10,	"blue",		10,	20, 2, 35,
	{ resists = {all=2}, combat_armor = 2 },
	{ mana=20 }
)
newGem("Ametrine",	"아메트린",	"object/ametrine.png",1,	8,	"yellow",	1,	10, 1, 20,
	{ inc_damage = {all=2}, combat_physcrit=1, combat_mindcrit=1, combat_spellcrit=1, },
	{ splash={type="LITE", dam=10, desc = "지형 밝히기 (세기 10)"} }
)
newGem("Zircon",	"지르콘",	"object/zircon.png",1,	8,	"yellow",	1,	10, 1, 20,
	{ resists = {all=1}, combat_armor = 1 },
	{ daze={chance=20, dur=3} }
)
newGem("Spinel",	"첨정석",	"object/spinel.png",1,	8,	"green",	1,	10, 1, 20,
	{ combat_def=2, combat_mentalresist=2, combat_spellresist=2, combat_physresist=2, },
	{ mana=10 }
)
newGem("Citrine",	"황수정",	"object/citrine.png",1,	8,	"yellow",	1,	10, 1, 20,
	{ lite=1, infravision=2, },
	{ range=1 }
)
newGem("Agate",	"마노",		"object/agate.png",	1,	8,	"black",	1,	10, 1, 20,
	{ inc_stats = { [Stats.STAT_STR] = 1, [Stats.STAT_DEX] = 1, [Stats.STAT_MAG] = 1, [Stats.STAT_WIL] = 1, [Stats.STAT_CUN] = 1, [Stats.STAT_CON] = 1, } },
	{ power=5 }
)
