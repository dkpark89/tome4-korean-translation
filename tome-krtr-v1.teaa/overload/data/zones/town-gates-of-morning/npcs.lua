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

load("/data/general/npcs/sunwall-town.lua", rarity(0))
--load("/data/general/npcs/.lua", function(e) e.faction = "sunwall" end)

local Talents = require("engine.interface.ActorTalents")

newEntity{ define_as = "HIGH_SUN_PALADIN_AERYN",
	type = "humanoid", subtype = "human",
	display = "p",
	faction = "sunwall",
	name = "High Sun Paladin Aeryn", color=colors.VIOLET, unique = true,
	kr_idsplay_name = "고위 태양의 기사 아에린",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/humanoid_human_high_sun_paladin_aeryn.png", display_h=2, display_y=-1}}},
	desc = [[빛나는 판갑을 입은 아름다운 여성입니다. 그녀로부터 힘이 퍼져나갑니다.]],
	level_range = {50, nil}, exp_worth = 2,
	rank = 4,
	size_category = 3,
	female = true,
	max_life = 250, life_rating = 24, fixed_rating = true,
	infravision = 10,
	stats = { str=15, dex=10, cun=12, mag=16, con=14 },
	instakill_immune = 1,
	teleport_immune = 1,
	move_others=true,

	open_door = true,

	resolvers.racial(),

	autolevel = "warriormage",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"melee",
	resolvers.inscriptions(3, {}),

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },

	resolvers.equip{
		{type="weapon", subtype="mace", forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="shield", forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="massive", forbid_power_source={antimagic=true}, autoreq=true},
	},
	resolvers.talents{
		[Talents.T_ARMOUR_TRAINING]=5,
		[Talents.T_CHANT_OF_LIGHT]=5,
		[Talents.T_SEARING_LIGHT]=5,
		[Talents.T_MARTYRDOM]=5,
		[Talents.T_BARRIER]=5,
		[Talents.T_WEAPON_OF_LIGHT]=5,
		[Talents.T_IRRESISTIBLE_SUN]=1,
	},
	resolvers.sustains_at_birth(),

	on_die = function(self)
		if not game.player:hasQuest("orc-pride") then
			game.player:setQuestStatus("orc-hunt", engine.Quest.DONE)
			game.player:grantQuest("orc-pride")
			game.logPlayer(game.player, "아에린의 육체에서 오크의 자부심의 위치가 적현 종이를 발견했습니다.")
		end
	end,

	can_talk = "gates-of-morning-welcome",
}
