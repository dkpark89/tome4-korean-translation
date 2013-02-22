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

local function select(id)
	if id == 1 or id == 2 then
		game:chronoRestore("see_threads_"..id, true)
	end
	if game._chronoworlds then
		game._chronoworlds.see_threads_1 = nil
		game._chronoworlds.see_threads_2 = nil
		game._chronoworlds.see_threads_3 = nil
		game._chronoworlds.see_threads_base = nil
	end

	game.logPlayer(game.player, "#LIGHT_BLUE#당신이 고른 시간의 흐름으로, 세계의 시간축이 재배열됩니다!")
	game.level.map:particleEmitter(game.player.x, game.player.y, 1, "rewrite_universe")
	game._chronoworlds = nil
end

newChat{ id="welcome",
	text = [[당신은 ]]..turns..[[ 턴 동안 다른 시간의 흐름에서 시간을 보냈습니다. 어느 시간의 흐름을 '진짜' 시간으로 선택하시겠습니까?]],
	answers = {
		{"첫 번째 시간.", action=function(npc, player) select(1) end},
		{"두 번째 시간.", action=function(npc, player) select(2) end},
		{"세 번째 시간.", action=function(npc, player) select(3) end},
	}
}

return "welcome"
