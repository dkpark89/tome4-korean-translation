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

-- Explore the far east
name = "The wild wild east"
kr_name = "거칠고도 거친 동쪽 대륙"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "골부그가 있던 곳에는 동대륙으로 통하는 길이 있을 것입니다. 알려지지 않은 대륙인 동대륙을 탐험하여, 지팡이를 추적해야 합니다."
	return table.concat(desc, "\n")
end
