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

name = "The Infinite Dungeon"
kr_display_name = "무한의 던전"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "당신은 무한의 던전에 들어왔습니다. 이곳에 돌아가는 길은 없습니다."
	desc[#desc+1] = "더 깊은 곳을 향해, 싸우고, 승리하거나, 영광을 불태우며 죽으십시오!"
	return table.concat(desc, "\n")
end
