-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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

newChat{ id="ambush",
	text = [[#VIOLET#*두려움의 영역을 나오자, 당신은 한 무리의 오크들을 만났습니다.*#LAST#
너! 그 지팡이 당장 내놔! 그러면 고통 없이 죽여주지!]],
	answers = {
		{"무슨 얘기를 하는거지?", jump="what"},
		{"지팡이를 원하는 이유는?", jump="why"},
		{"#LIGHT_GREEN#[공격한다]"},
	}
}

newChat{ id="what",
	text = [[우크룩을 바보로 보는건가! 공격하라!]],
	answers = {
		{"#LIGHT_GREEN#[공격한다]"},
	}
}

newChat{ id="why",
	text = [[네가 상관할 일은 아니다! 공격하라!]],
	answers = {
		{"#LIGHT_GREEN#[공격한다]"},
	}
}

return "ambush"
