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
load("/data/general/objects/scrolls.lua")
load("/data/general/objects/gem.lua")

local Stats = require "engine.interface.ActorStats"
local Talents = require "engine.interface.ActorTalents"

-- This file describes the twelve elixirs and three artifacts obtainable through the Brotherhood of Alchemists quest

newEntity{
	power_source = {nature=true},
	define_as = "ELIXIR_FOX",
	type = "potion", subtype="potion", image = "object/elixir_of_the_fox.png",
	name = "Elixir of the Fox", unique=true, unided_name="vial of pink fluid",
	display = "!", color=colors.VIOLET,
	kr_name = "여우의 엘릭서", kr_unided_name = "분홍색 액체가 든 약병",
	desc = [[분홍색의 가벼워 보이는 액체가 든 약병입니다.]],
	no_unique_lore = true,
	cost = 1000,
	quest = 1,

	use_simple = { name="permanently increase your dexterity and cunning by three", kr_name="민첩과 교활함 능력치가 각각 3 씩 영구적으로 증가", use = function(self, who)
		game.logPlayer(who, "#00FFFF#당신은 엘릭서를 마셨습니다. 신체가 영구적으로 변화되었습니다!")
		who.inc_stats[who.STAT_DEX] = who.inc_stats[who.STAT_DEX] + 3
		who:onStatChange(who.STAT_DEX, 3)
		who.inc_stats[who.STAT_CUN] = who.inc_stats[who.STAT_CUN] + 3
		who:onStatChange(who.STAT_CUN, 3)
		game.logPlayer(who, "#00FF00#이 엘릭서는 당신에게 물리적, 정신적으로 여우와 같은 민첩함을 줍니다!")
		return {used=true, id=true, destroy=true}
	end}
}

newEntity{
	power_source = {nature=true},
	define_as = "ELIXIR_AVOIDANCE",
	type = "potion", subtype="potion", image = "object/elixir_of_avoidance.png",
	name = "Elixir of Avoidance", unique=true, unided_name="vial of green fluid",
	display = "!", color=colors.GREEN,
	kr_name = "회피의 엘릭서", kr_unided_name = "초록색 액체가 든 약병",
	desc = [[불투명한 초록색 액체가 든 약병입니다.]],
	no_unique_lore = true,
	cost = 1000,
	quest = 1,

	use_simple = { name="permanently increase your defense and ranged defense by six", kr_name="회피도와 장거리 회피도가 각각 6 씩 영구적으로 증가", use = function(self, who)
		game.logPlayer(who, "#00FFFF#당신은 엘릭서를 마셨습니다. 신체가 영구적으로 변화되었습니다!")
		who.combat_def = who.combat_def + 6
		game.logPlayer(who, "#00FF00#이 엘릭서는 당신의 회피 본능을 향상시킵니다!")
		return {used=true, id=true, destroy=true}
	end}
}

newEntity{
	power_source = {nature=true},
	define_as = "ELIXIR_PRECISION",
	type = "potion", subtype="potion", image = "object/elixir_of_precision.png",
	name = "Elixir of Precision", unique=true, unided_name="vial of red fluid",
	display = "!", color=colors.RED,
	kr_name = "정밀함의 엘릭서", kr_unided_name = "붉은색 액체가 든 약병",
	desc = [[덩어리진 붉은색 액체가 든 약병입니다.]],
	no_unique_lore = true,
	cost = 1000,
	quest = 1,

	use_simple = { name="permanently increase your physical critical strike chance by 4%", kr_name="물리적 치명타율이 영구적으로 4% 증가", use = function(self, who)
		game.logPlayer(who, "#00FFFF#당신은 엘릭서를 마셨습니다. 신체가 영구적으로 변화되었습니다!")
		who.combat_physcrit = who.combat_physcrit + 4
		game.logPlayer(who, "#00FF00#이 엘릭서는 당신의 눈이 적의 약점을 더 잘 찾아낼 수 있도록 만듭니다!")
		return {used=true, id=true, destroy=true}
	end}
}

newEntity{
	power_source = {nature=true},
	define_as = "ELIXIR_MYSTICISM",
	type = "potion", subtype="potion", image = "object/elixir_of_mysticism.png",
	name = "Elixir of Mysticism", unique=true, unided_name="vial of cyan fluid",
	display = "!", color=colors.AQUAMARINE,
	kr_name = "신비주의의 엘릭서", kr_unided_name = "하늘색 액체가 든 약병",
	desc = [[빛나는 하늘색 액체가 든 약병입니다.]],
	no_unique_lore = true,
	cost = 1000,
	quest = 1,

	use_simple = { name="permanently increase your magic and willpower by three", kr_name="마법과 의지 능력치가 각각 3 씩 영구적으로 증가", use = function(self, who)
		game.logPlayer(who, "#00FFFF#당신은 엘릭서를 마셨습니다. 신체가 영구적으로 변화되었습니다!")
		who.inc_stats[who.STAT_MAG] = who.inc_stats[who.STAT_MAG] + 3
		who:onStatChange(who.STAT_MAG, 3)
		who.inc_stats[who.STAT_WIL] = who.inc_stats[who.STAT_WIL] + 3
		who:onStatChange(who.STAT_WIL, 3)
		game.logPlayer(who, "#00FF00#이 엘릭서는 당신의 마법적, 정신적 수용력을 높여줍니다!")
		return {used=true, id=true, destroy=true}
	end}
}

newEntity{
	power_source = {nature=true},
	define_as = "ELIXIR_SAVIOR",
	type = "potion", subtype="potion", image = "object/elixir_of_the_saviour.png",
	name = "Elixir of the Savior", unique=true, unided_name="vial of grey fluid",
	display = "!", color=colors.GREY,
	kr_name = "구원자의 엘릭서", kr_unided_name = "회색 액체가 든 약병",
	desc = [[거품이 이는 회색 액체가 든 약병입니다.]],
	no_unique_lore = true,
	cost = 1000,
	quest = 1,

	use_simple = { name="permanently increase all your saving throws by 4", kr_name="모든 내성을 각각 4 씩 영구적으로 증가", use = function(self, who)
		game.logPlayer(who, "#00FFFF#당신은 엘릭서를 마셨습니다. 신체가 영구적으로 변화되었습니다!")
		who.combat_physresist = who.combat_physresist + 4
		who.combat_spellresist = who.combat_spellresist + 4
		who.combat_mentalresist = who.combat_mentalresist + 4
		game.logPlayer(who, "#00FF00#이 엘릭서는 당신의 부정적인 상태효과에 대한 면역력을 높여줍니다!")
		return {used=true, id=true, destroy=true}
	end}
}

newEntity{
	power_source = {nature=true},
	define_as = "ELIXIR_MASTERY",
	type = "potion", subtype="potion", image = "object/elixir_of_mastery.png",
	name = "Elixir of Mastery", unique=true, unided_name="vial of maroon fluid",
	display = "!", color=colors.DARK_RED,
	kr_name = "숙련의 엘릭서", kr_unided_name = "밤색 액체가 든 약병",
	desc = [[걸쭉한 밤색 액체가 든 약병입니다.]],
	no_unique_lore = true,
	cost = 1000,
	quest = 1,

	use_simple = { name="grant you four additional stat points", kr_name="능력치 점수 4 점 부여", use = function(self, who)
		game.logPlayer(who, "#00FFFF#당신은 엘릭서를 마셨습니다. 신체가 영구적으로 변화되었습니다!")
		who.unused_stats = who.unused_stats + 4
		game.logPlayer(who, "#00FF00#이 엘릭서는 당신의 육체나 정신을 향상시킬 수 있는 수용력을 넓혀줍니다.")
		game.logPlayer(who, "당신은 %d 점의 능력치 점수를 사용할 수 있습니다. 사용하려면 'p' 키를 누르세요.", who.unused_stats)
		return {used=true, id=true, destroy=true}
	end}
}

newEntity{
	power_source = {nature=true},
	define_as = "ELIXIR_FORCE",
	type = "potion", subtype="potion", image = "object/elixir_of_explosive_force.png",
	name = "Elixir of Explosive Force", unique=true, unided_name="vial of orange fluid",
	display = "!", color=colors.ORANGE,
	kr_name = "폭발력의 엘릭서", kr_unided_name = "주황색의 액체가 든 약병",
	desc = [[부글거리는 주황색 액체가 든 약병입니다.]],
	no_unique_lore = true,
	cost = 1000,
	quest = 1,

	use_simple = { name="permanently increase your chance to critically strike with spells by 4%", kr_name="주문 치명타율이 영구적으로 4% 증가", use = function(self, who)
		game.logPlayer(who, "#00FFFF#당신은 엘릭서를 마셨습니다. 신체가 영구적으로 변화되었습니다!")
		who.combat_spellcrit = who.combat_spellcrit + 4
		game.logPlayer(who, "#00FF00#이 엘릭서는 당신의 눈이 적의 마법적 약점을 더 잘 찾아낼 수 있도록 만듭니다!")
		return {used=true, id=true, destroy=true}
	end}
}

newEntity{
	power_source = {nature=true},
	define_as = "ELIXIR_SERENDIPITY",
	type = "potion", subtype="potion", image = "object/elixir_of_serendipity.png",
	name = "Elixir of Serendipity", unique=true, unided_name="vial of yellow fluid",
	display = "!", color=colors.YELLOW,
	kr_name = "행운의 엘릭서", kr_unided_name = "노란색의 액체가 든 약병",
	desc = [[생동하는 노란색 액체가 든 약병입니다.]],
	no_unique_lore = true,
	cost = 1000,
	quest = 1,

	use_simple = { name="permanently increase your luck by 5", kr_name="행운이 영구적으로 5 상승", use = function(self, who)
		game.logPlayer(who, "#00FFFF#당신은 엘릭서를 마셨습니다. 신체가 영구적으로 변화되었습니다!")
		who.inc_stats[who.STAT_LCK] = who.inc_stats[who.STAT_LCK] + 5
		who:onStatChange(who.STAT_LCK, 5)
		game.logPlayer(who, "#00FF00#이 엘릭서는 당신 주변의 현실 구성을 묘하게 바꿔, 더 운이 좋게 만들어줍니다!")
		return {used=true, id=true, destroy=true}
	end}
}

newEntity{
	power_source = {nature=true},
	define_as = "ELIXIR_FOCUS",
	type = "potion", subtype="potion", image = "object/elixir_of_focus.png",
	name = "Elixir of Focus", unique=true, unided_name="vial of clear fluid",
	display = "!", color=colors.WHITE,
	kr_name = "집중의 엘릭서", kr_unided_name = "투명한 액체가 든 약병",
	desc = [[김이 나는 투명한 액체가 든 약병입니다.]],
	no_unique_lore = true,
	cost = 1000,
	quest = 1,

	use_simple = { name="grant you two additional class talent points", kr_name="직업 기술점수 2 점 부여", use = function(self, who)
		game.logPlayer(who, "#00FFFF#당신은 엘릭서를 마셨습니다. 신체가 영구적으로 변화되었습니다!")
		who.unused_talents = who.unused_talents + 2
		game.logPlayer(who, "#00FF00#이 엘릭서는 당신의 주요 기술의 훈련도를 향상시킵니다.")
		return {used=true, id=true, destroy=true}
	end}
}

newEntity{
	power_source = {nature=true},
	define_as = "ELIXIR_BRAWN",
	type = "potion", subtype="potion", image = "object/elixir_of_brawn.png",
	name = "Elixir of Brawn", unique=true, unided_name="vial of tan fluid",
	display = "!", color=colors.TAN,
	kr_name = "완력의 엘릭서", kr_unided_name = "황갈색 액체가 든 약병",
	desc = [[굳은 황갈색 액체가 든 약병입니다.]],
	no_unique_lore = true,
	cost = 1000,
	quest = 1,

	use_simple = { name="permanently increase your strength and constitution by three", kr_name="힘과 체격 능력치가 각각 3 씩 영구적으로 증가", use = function(self, who)
		game.logPlayer(who, "#00FFFF#당신은 엘릭서를 마셨습니다. 신체가 영구적으로 변화되었습니다!")
		who.inc_stats[who.STAT_STR] = who.inc_stats[who.STAT_STR] + 3
		who:onStatChange(who.STAT_STR, 3)
		who.inc_stats[who.STAT_CON] = who.inc_stats[who.STAT_CON] + 3
		who:onStatChange(who.STAT_CON, 3)
		game.logPlayer(who, "#00FF00#이 엘릭서는 당신의 물리적 힘과 활력을 향상시킵니다!")
		return {used=true, id=true, destroy=true}
	end}
}

newEntity{
	power_source = {nature=true},
	define_as = "ELIXIR_STONESKIN",
	type = "potion", subtype="potion", image = "object/elixir_of_stoneskin.png",
	name = "Elixir of Stoneskin", unique=true, unided_name="vial of iron-colored fluid",
	display = "!", color=colors.SLATE,
	kr_name = "단단한 피부의 엘릭서", kr_unided_name = "은빛 액체가 든 약병",
	desc = [[알갱이 몇 개와 은빛 액체가 든 약병입니다.]],
	no_unique_lore = true,
	cost = 1000,
	quest = 1,

	use_simple = { name="permanently increase your armor by four", kr_name="방어도가 영구적으로 4 상승", use = function(self, who)
		game.logPlayer(who, "#00FFFF#당신은 엘릭서를 마셨습니다. 신체가 영구적으로 변화되었습니다!")
		who.combat_armor = who.combat_armor + 4
		game.logPlayer(who, "#00FF00#이 엘릭서는 당신의 육체를 강화시킵니다!")
		return {used=true, id=true, destroy=true}
	end}
}

newEntity{
	power_source = {nature=true},
	define_as = "ELIXIR_FOUNDATIONS",
	type = "potion", subtype="potion", image = "object/elixir_of_foundations.png",
	name = "Elixir of Foundations", unique=true, unided_name="vial of white fluid",
	display = "!", color=colors.WHITE,
	kr_name = "기반의 엘릭서", kr_unided_name = "하얀색 액체가 든 약병",
	desc = [[흐릿한 하얀색 액체가 든 약병입니다.]],
	no_unique_lore = true,
	cost = 1000,
	quest = 1,

	use_simple = { name="grant you two additional generic talent points", kr_name="일반 기술점수 2 점 부여", use = function(self, who)
		game.logPlayer(who, "#00FFFF#당신은 엘릭서를 마셨습니다. 신체가 영구적으로 변화되었습니다!")
		who.unused_generics = who.unused_generics + 2
		game.logPlayer(who, "#00FF00#이 엘릭서는 당신의 일반 기술의 훈련도를 향상시킵니다.")
		return {used=true, id=true, destroy=true}
	end}
}

-- The four possible final rewards for the Brotherhood of Alchemists quest:

newEntity{ base = "BASE_TAINT",
	name = "Taint of Telepathy",
	kr_name = "투시의 감염체",
	define_as = "TAINT_TELEPATHY", image = "object/taint_of_telepathy.png",
	unique = true,
	identified = true,
	cost = 200,
	material_level = 3,
	quest = 1,

	inscription_kind = "utility",
	inscription_data = {
		cooldown = 15,
		dur = 5,
	},
	inscription_talent = "TAINT:_TELEPATHY",
}

newEntity{ base = "BASE_INFUSION",
	name = "Infusion of Wild Growth",
	kr_name = "야생의 주입물",
	define_as = "INFUSION_WILD_GROWTH", image = "object/infusion_of_wild_growth.png",
	unique = true,
	identified = true,
	cost = 200,
	material_level = 3,
	quest = 1,

	inscription_kind = "utility",
	inscription_data = {
		cooldown = 15,
		dur = 10, -- to 10 from 5, because this should be really good
		armor = 50,
		hard = 30,
	},
	inscription_talent = "INFUSION:_WILD_GROWTH",
}

newEntity{ base = "BASE_GEM",
	define_as = "LIFEBINDING_EMERALD",
	power_source = {nature=true},
	unique = true,
	unided_name = "cloudy, heavy emerald",
	name = "Lifebinding Emerald", subtype = "green", image = "object/lifebinding_emerald.png",
	color = colors.GREEN,
	kr_name = "생명력이 묶인 에메랄드", kr_unided_name = "흐릿하고 무거운 에메랄드",
	desc = [[무거운 에메랄드로, 흐릿하게 보이는 녹색 연기가 보석 안쪽에서 느리게 감돌고 있습니다.]],
	cost = 200,
	quest = 1,
	material_level = 5,
	wielder = {
		inc_stats = {[Stats.STAT_CON] = 15, },
		healing_factor = 0.3,
		life_regen = 2,
		resists = {
			[DamageType.BLIGHT] = 10,
		},
		damage_affinity = {
			[DamageType.NATURE] = 15,
		},
	},
	imbue_powers = {
		inc_stats = {[Stats.STAT_CON] = 15, },
		healing_factor = 0.3,
		life_regen = 2,
		stun_immune = 0.3,
		resists = {
			[DamageType.BLIGHT] = 10,
		},
		damage_affinity = {
			[DamageType.NATURE] = 15,
		},
	},
}

newEntity{
	power_source = {nature=true},
	define_as = "ELIXIR_INVULNERABILITY",
	encumber = 2,
	type = "potion", subtype="potion", image = "object/elixir_of_invulnerability.png",
	name = "Elixir of Invulnerability", unique=true, unided_name="vial of black fluid",
	display = "!", color=colors.SLATE,
	kr_name = "불사신의 엘릭서", kr_unided_name = "검은색 액체가 든 약병",
	desc = [[탁하고 금속 빛을 내며, 빛을 반사하는 액체가 든 약병입니다. 다른 약병보다 훨씬 무겁습니다.]],
	cost = 200,
	quest = 1,

	use_simple = { name="grant you complete invulnerability for five turns", kr_name="5 턴 동안 절대적인 불사의 상태 부여", use = function(self, who)
		who:setEffect(who.EFF_DAMAGE_SHIELD, 5, {power=1000000})
		game.logPlayer(who, "#00FF00#당신은 불멸의 상태가 되었음을 느낍니다!")
		return {used=true, id=true, destroy=true}
	end}
}
