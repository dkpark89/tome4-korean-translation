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

--load("/data/general/npcs/telugoroth.lua", rarity(0))
--load("/data/general/npcs/horror.lua", function(e) if e.rarity then e.horror_rarity, e.rarity = e.rarity, nil end end)

local Talents = require("engine.interface.ActorTalents")

newEntity{ define_as = "GOD_GERLYK",
	type = "god", subtype = "eyal", unique = true,
	name = "Gerlyk, the Creator",
	kr_name = "창조자, 게를릭",
	display = "P", color=colors.VIOLET,
	desc = [[아지랑이의 시대동안, 쉐르'툴 종족의 신 살해자들에 의해 거의 모든 신들이 파괴되었습니다. 하지만 몇몇 신들은 도망칠 수 있었습니다.
인류의 창조자, 게를릭은 죽음을 맞이하는 대신 별 사이의 공허로 도망치는 것을 선택했습니다. 그 이후로, 그는 이곳에 갇혀있었습니다.
'주술사' 들이 그를 불러오려 노력했었고, 거의 성공할 뻔 했었습니다.
이제 쉐르'툴의 주인으로서, 당신이 모든 일의 마무리를 지어야 합니다. 신 살해자가 되어 보세요.]],
	level_range = {100, nil}, exp_worth = 3,
	max_life = 900, life_rating = 100, fixed_rating = true,
	life_regen = 70,
	max_stamina = 10000,
	max_mana = 10000,
	max_positive = 10000,
	max_negative = 10000,
	max_vim = 10000,
	stats = { str=100, dex=100, con=100, mag=100, wil=100, cun=100 },
	inc_stats = { str=80, dex=80, con=80, mag=80, wil=80, cun=80 },
	rank = 10,
	size_category = 5,
	infravision = 10,

	instakill_immune = 1,
	stun_immune = 1,
	blind_immune = 1,
	confusion_immune = 1,
	move_others=true,
	see_invisible = 150,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.equip{
	},
	resolvers.drops{chance=100, nb=10, {tome_drops="boss"} },

-- give him a special shield talent that only the staff of absorption can remove
	resolvers.talents{
		[Talents.T_GLOOM]=3,
		[Talents.T_WEAKNESS]=3,
		[Talents.T_DISMAY]=3,
		[Talents.T_UNNATURAL_BODY]=4,
		[Talents.T_DOMINATE]=1,
		[Talents.T_BLINDSIDE]=3,
		[Talents.T_SLASH]=3,
		[Talents.T_RECKLESS_CHARGE]=1,

		[Talents.T_DAMAGE_SMEARING]=5,
		[Talents.T_HASTE]=3,
	},
	resolvers.sustains_at_birth(),

	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
--	ai_tactic = resolvers.tactic"melee",
	resolvers.inscriptions(6, {"healing infusion", "regeneration infusion", "shielding rune", "invisibility rune", "movement infusion", "wild infusion"}),

	on_die = function(self, who)
		game.player:resolveSource():setQuestStatus("void-gerlyk", engine.Quest.COMPLETED)
	end,
}
