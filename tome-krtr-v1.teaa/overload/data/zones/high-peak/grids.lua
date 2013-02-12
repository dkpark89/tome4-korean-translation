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

load("/data/general/grids/basic.lua")
load("/data/general/grids/water.lua")
load("/data/general/grids/forest.lua")
load("/data/general/grids/lava.lua")
load("/data/general/grids/cave.lua")

newEntity{
	define_as = "FAR_EAST_PORTAL",
	name = "Farportal: the Far East",
	kr_display_name = "장거리 관문 : 동대륙",
	display = '&', color_r=255, color_g=0, color_b=220, back_color=colors.VIOLET, image = "terrain/marble_floor.png",
	notice = true,
	always_remember = true,
	show_tooltip = true,
	desc = [[장거리 관문은 눈 깜짝할 사이에 놀랄만큼 먼 거리를 이동하는 수단입니다. 이것을 사용하기 위해서는 보통 어떤 물건이 필요하며, 이 관문이 썅방향으로 사용이 가능한 것인지조차도 알 수 없습니다.
이 관문은 동대륙과 연결된 것으로 보입니다...]],

	orb_portal = {
		change_level = 1,
		change_zone = "wilderness",
		change_wilderness = {
			spot = {type="farportal-end", subtype="fareast"},
		},
		message = "#VIOLET#당신이 소용돌이 치는 관문으로 들어서자,  눈 깜짝할 사이에 자신이 동대륙으로 이동했다는 것을 알아차립니다...",
		on_use = function(self, who)
		end,
	},
}
newEntity{ base = "FAR_EAST_PORTAL", define_as = "CFAR_EAST_PORTAL",
	image = "terrain/marble_floor.png",
	add_displays = {class.new{image="terrain/farportal-base.png", display_x=-1, display_y=-1, display_w=3, display_h=3}},
	on_added = function(self, level, x, y)
		level.map:particleEmitter(x, y, 3, "farportal_vortex")
		level.map:particleEmitter(x, y, 3, "farportal_lightning")
		level.map:particleEmitter(x, y, 3, "farportal_lightning")
		level.map:particleEmitter(y, y, 3, "farportal_lightning")
	end,
}

newEntity{
	define_as = "WEST_PORTAL",
	name = "Farportal: Iron Throne",
	kr_display_name = "장거리 관문 : 철의 왕좌",
	display = '&', color_r=255, color_g=0, color_b=220, back_color=colors.VIOLET, image = "terrain/marble_floor.png",
	notice = true,
	always_remember = true,
	show_tooltip = true,
	desc = [[장거리 관문은 눈 깜짝할 사이에 놀랄만큼 먼 거리를 이동하는 수단입니다. 이것을 사용하기 위해서는 보통 어떤 물건이 필요하며, 이 관문이 썅방향으로 사용이 가능한 것인지조차도 알 수 없습니다.
이 관문은 서쪽의 철의 왕좌와 연결된 것으로 보입니다...]],

	orb_portal = {
		change_level = 1,
		change_zone = "wilderness",
		change_wilderness = {
			spot = {type="farportal-end", subtype="iron-throne"},
		},
		message = "#VIOLET#당신은 소용돌이 치는 관문으로 들어섰습니다. 눈 깜짝할 사이에 관문의 흔적은 없어지고, 자신이 철의 왕좌의 언덕에 있는 것을 알아차렸습니다...",
		on_use = function(self, who)
		end,
	},
}
newEntity{ base = "WEST_PORTAL", define_as = "CWEST_PORTAL",
	image = "terrain/marble_floor.png",
	add_displays = {class.new{image="terrain/farportal-base.png", display_x=-1, display_y=-1, display_w=3, display_h=3}},
	on_added = function(self, level, x, y)
		level.map:particleEmitter(x, y, 3, "farportal_vortex")
		level.map:particleEmitter(x, y, 3, "farportal_lightning")
		level.map:particleEmitter(x, y, 3, "farportal_lightning")
		level.map:particleEmitter(x, y, 3, "farportal_lightning")
	end,
}

newEntity{
	define_as = "VOID_PORTAL",
	name = "Farportal: the Void",
	kr_display_name = "장거리 관문 : 공허",
	display = '&', color=colors.DARK_GREY, back_color=colors.VIOLET, image = "terrain/marble_floor.png",
	notice = true,
	always_remember = true,
	show_tooltip = true,
	desc = [[장거리 관문은 눈 깜짝할 사이에 놀랄만큼 먼 거리를 이동하는 수단입니다. 이것을 사용하기 위해서는 보통 어떤 물건이 필요하며, 이 관문이 썅방향으로 사용이 가능한 것인지조차도 알 수 없습니다.
이 관문은 이 세계가 아닌, 다른 알 수 없는 장소와 연결된 것으로 보입니다. 감히 사용할 엄두가 나지 않습니다.]],
}
newEntity{ base = "VOID_PORTAL", define_as = "CVOID_PORTAL",
	image = "terrain/marble_floor.png",
	add_displays = {class.new{image="terrain/farportal-base.png", display_x=-1, display_y=-1, display_w=3, display_h=3}},
	on_added = function(self, level, x, y)
		level.map:particleEmitter(x, y, 3, "farportal_vortex", {vortex="shockbolt/terrain/farportal-void-vortex"})
		level.map:particleEmitter(x, y, 3, "farportal_lightning")
		level.map:particleEmitter(x, y, 3, "farportal_lightning")
		level.map:particleEmitter(y, y, 3, "farportal_lightning")
	end,
}

local invocation_close = function(self, who)
	if not who:hasQuest("high-peak") or who:hasQuest("high-peak"):isEnded() then return end
	-- Remove the level spot
	local spot = game.level:pickSpot{type="portal", subtype=self.summon}
	if not spot then return end
	game.logPlayer(who, "#LIGHT_BLUE#당신은 오브를 사용하여 쉽게 관문을 닫았습니다.")
	for i = 1, #game.level.spots do if game.level.spots[i] == spot then table.remove(game.level.spots, i) break end end
	local g = game.level.map(spot.x, spot.y, engine.Map.TERRAIN)
	g.name = g.name .. " (disabled)"
	g.color_r = colors.WHITE.r
	g.color_g = colors.WHITE.g
	g.color_b = colors.WHITE.b
	g:removeAllMOs()
	game.level.map:updateMap(spot.x, spot.y)
	who:setQuestStatus("high-peak", engine.Quest.COMPLETED, "closed-portal-"..self.summon)
end

newEntity{
	define_as = "ORB_UNDEATH",
	name = "Invocation Portal: Undeath", image = "terrain/marble_floor.png", add_mos = {{image="terrain/demon_portal4.png"}},
	kr_display_name = "소환용 관문 : 언데드",
	display = '&', color=colors.GREY, back_color=colors.PURPLE,
	notice = true,
	always_remember = true,
	show_tooltip = true,
	desc = [[끊임없이 소환수가 나오는, 소환용 관문입니다.]],
	orb_command = {
		summon = "undead",
		special = invocation_close,
	},
}

newEntity{
	define_as = "ORB_ELEMENTS",
	name = "Invocation Portal: Elements", image = "terrain/marble_floor.png", add_mos = {{image="terrain/demon_portal4.png"}},
	kr_display_name = "소환용 관문 : 정령",
	display = '&', color=colors.LIGHT_RED, back_color=colors.PURPLE,
	notice = true,
	always_remember = true,
	show_tooltip = true,
	desc = [[끊임없이 소환수가 나오는, 소환용 관문입니다.]],
	orb_command = {
		summon = "elemental",
		special = invocation_close,
	},
}

newEntity{
	define_as = "ORB_DRAGON",
	name = "Invocation Portal: Dragons", image = "terrain/marble_floor.png", add_mos = {{image="terrain/demon_portal4.png"}},
	kr_display_name = "소환용 관문 : 용",
	display = '&', color=colors.LIGHT_BLUE, back_color=colors.PURPLE,
	notice = true,
	always_remember = true,
	show_tooltip = true,
	desc = [[끊임없이 소환수가 나오는, 소환용 관문입니다.]],
	orb_command = {
		summon = "dragon",
		special = invocation_close,
	},
}

newEntity{
	define_as = "ORB_DESTRUCTION",
	name = "Invocation Portal: Destruction",  image = "terrain/marble_floor.png", add_mos = {{image="terrain/demon_portal4.png"}},
	kr_display_name = "소환용 관문 : 파괴자",
	display = '&', color=colors.WHITE, back_color=colors.PURPLE,
	notice = true,
	always_remember = true,
	show_tooltip = true,
	desc = [[끊임없이 소환수가 나오는, 소환용 관문입니다.]],
	orb_command = {
		summon = "demon",
		special = invocation_close,
	},
}

newEntity{
	define_as = "PORTAL_BOSS",
	name = "Portal: The Sanctum", image = "terrain/marble_floor.png", add_mos = {{image="terrain/demon_portal4.png"}},
	kr_display_name = "관문 : 성소",
	display = '&', color=colors.LIGHT_BLUE, back_color=colors.PURPLE,
	notice = true,
	always_remember = true,
	show_tooltip = true,
	desc = [[이 관문은 이 지역에 있는 특별한 장소와 연결되어 있는 것 같습니다.]],
	orb_portal = {
		nothing = true,
		message = "#VIOLET#당신이 소용돌이 치는 관문으로 들어서자, 다른 관문들과 두 명의 마법사가 있는 커다란 방이 나타났습니다.",
		on_use = function()
			game:changeLevel(11, nil, {direct_switch=true}) -- Special level, can not get to it any other way
			if game.player:hasQuest("high-peak"):isCompleted("sanctum-chat") then return end
			local Chat = require "engine.Chat"
			local chat = Chat.new("sorcerer-fight", {name="Elandar", kr_display_name="엘란다르"}, game.player)
			chat:invoke()
			game.player:hasQuest("high-peak"):setStatus(engine.Quest.COMPLETED, "sanctum-chat")
			game.player:hasQuest("high-peak"):start_end_combat()
		end,
	},
}

newEntity{
	define_as = "HIGH_PEAK_UP", image = "terrain/marble_floor.png", add_mos = {{image = "terrain/stair_up.png"}},
	name = "next level",
	kr_display_name = "다음 층",
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
}

newEntity{
	define_as = "CAVE_HIGH_PEAK_UP", image = "terrain/cave/cave_floor_1_01.png", add_displays = {class.new{image="terrain/cave/cave_stairs_up_2_01.png"}},
	name = "next level",
	kr_display_name = "다음 층",
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
}
