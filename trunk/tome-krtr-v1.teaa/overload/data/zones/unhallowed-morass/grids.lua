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
load("/data/general/grids/void.lua")

newEntity{
	define_as = "RIFT",
	name = "Temporal Rift", add_mos={{image="terrain/demon_portal2.png"}},
	kr_display_name = "시간의 틈",
	display = '&', color_r=255, color_g=0, color_b=220, back_color=colors.VIOLET,
	notice = true,
	always_remember = true,
	show_tooltip = true,
	desc = [[이 틈은 저습지의 다른 장소로 연결되어 있습니다.]],
	change_level = 1,
}

newEntity{
	define_as = "RIFT_HOME",
	name = "Temporal Rift", add_mos={{image="terrain/demon_portal2.png"}},
	kr_display_name = "시간의 틈",
	display = '&', color_r=255, color_g=0, color_b=220, back_color=colors.VIOLET,
	notice = true,
	always_remember = true,
	show_tooltip = true,
	desc = [[이 틈은 저습지의 다른 장소로 연결되어 있습니다.]],
	change_level = 1,
	change_zone = "town-point-zero",
	change_level_check = function()
		game:onLevelLoad("town-point-zero-1", function(zone, level)
			game:onTickEnd(function()
				local npc = game.zone:makeEntityByName(level, "actor", "TEMPORAL_DEFILER")
				local spot = level:pickSpot{type="pop", subtype="defiler"}
				game.zone:addEntity(level, npc, "actor", spot.x, spot.y)
				npc:setTarget(game.player)

				local spot = level:pickSpot{type="pop", subtype="player-attack"}
				game.player:move(spot.x, spot.y, true)
				require("engine.ui.Dialog"):simpleLongPopup("영점", "영점으로 돌아가는 틈이 부서져 있고, 이것이 소동의 원인이 되고 있습니다.\n시간의 모독자가 마을을 공격했고, 주변의 모든 감시자는 그를 공격 중입니다!", 400)

				for uid, e in pairs(game.level.entities) do
					if e.faction == "keepers-of-reality" or e.faction == "point-zero-guardians" then
						e:setEffect(e.EFF_KEEPER_OF_REALITY, 20, {})
					end
				end
			end)
		end)
	end,
}

local rift_editer = { method="sandWalls_def", def="rift"}
newEntity{
	define_as = "SPACETIME_RIFT",
	type = "wall", subtype = "rift",
	name = "crack in spacetime",
	kr_display_name = "시공간의 균열",
	display = '#', color=colors.YELLOW, image="terrain/rift/rift_inner_05_01.png",
	always_remember = true,
	block_sight = true,
	does_block_move = true,
	_noalpha = false,
	nice_editer = rift_editer,
}
