﻿-- ToME - Tales of Maj'Eyal
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

load("/data/general/npcs/yaech.lua")

local Talents = require("engine.interface.ActorTalents")

newEntity{
	name = "Melinda", define_as = "MELINDA_BEACH",
	kr_name = "멜린다",
	type = "humanoid", subtype = "human", female=true,
	display = "@", color=colors.LIGHT_BLUE,
	image = "player/cornac_female_redhair.png",
	moddable_tile = "human_female",
	moddable_tile_base = "base_redhead_01.png",
	desc = [[해변에서의 사랑스러운 시간을 즐기고 있습니다.]],
	autolevel = "tank",
	ai = "move_complex", ai_state = { ai_target="target_player", talent_in=4, },
	stats = { str=8, dex=7, mag=8, con=12 },
	level_range = {10, 10},
	faction = "allied-kingdoms",
	never_anger = true,
	resists = {all=86},

	moddable_tile_nude = 1,
	moddable_tile_ornament = {female="braid_redhead_01"},
	resolvers.equip{ id=true,
		{defined="MELINDA_BIKINI", autoreq=true, ego_chance=-1000}
	},

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	lite = 4,
	rank = 2,
	exp_worth = 0,

	max_life = 100, life_regen = 0,
	life_rating = 45,
	combat_armor = 3, combat_def = 3,

	on_resurrect = function(self)
		game.level.data.blight_start_in = nil
		game.level.map:particleEmitter(self.x, self.y, 10, "ball_blight", {radius=10})
		local list = {}
		for uid, e in pairs(game.level.entities) do
			if e.type == "humanoid" and e.subtype == "yaech" then list[#list+1] = e end
		end
		for _, e in ipairs(list) do
			local DamageType = require "engine.DamageType"
			DamageType:get(DamageType.BLIGHT).projector(self, e.x, e.y, DamageType.BLIGHT, 10000)
		end
		self:doEmote("뭐..! 부탁이니 도망가!", 120)
		game.player:setQuestStatus("love-melinda", engine.Quest.COMPLETED, "saved-beach")
		game.bignews:say(120, "#DARK_GREEN#그녀에게서 나오는 강력한 황폐의 파동 때문에, 멜린다가 곧 죽어버릴 것 같습니다!")
	end,

	on_die = function(self)
		game.player:setQuestStatus("love-melinda", engine.Quest.COMPLETED, "death-beach")
		game.player:setQuestStatus("love-melinda", engine.Quest.FAILED)
	end,
}
