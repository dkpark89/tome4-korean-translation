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

newChat{ id="welcome",
	text = [[#VIOLET#*문을 열자, 저 멀리에 거대한 오크가 있는 것을 발견했습니다. 그 오크의 몸에는 화염과 얼음에 동시에 덮여있습니다.*#LAST#
@playerdescriptor.race@! 이곳에 온 것을 후회하게 될 것이다! 너의 종말이 기다리고 있다!
오크 긍지는 그 누구에게도 지지 않는다! 우리에게는 강력한 지도자가 있고, 네가 할 수 있는 것은 아무 것도 없다!]],
	answers = {
		{"오크 무리가 주인을 따른다고? 겨우 오크 주제에 '무리' 하는거 아냐?", jump="mock"},
		{"#LIGHT_GREEN#[공격한다]"},
	}
}

newChat{ id="mock",
	text = [[긍지는 동료를 선택할 뿐이다. 주인 따위는 섬기지 않는다! 공격하라!]],
	answers = {
		{"#LIGHT_GREEN#[공격한다]"},
	}
}

return "welcome"
