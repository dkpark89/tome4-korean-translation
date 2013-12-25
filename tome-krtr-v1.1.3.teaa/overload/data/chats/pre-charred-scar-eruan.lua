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
	text = [[@playername@, 저는 아에린이 보낸 태양의 기사 중 하나입니다. 우리는 오크들을 쫓아 이곳에 도착했습니다.
그들은 이 관문을 통해 사라졌습니다. 그리고 동료 기사들 몇 명도 그들을 따라갔습니다.
관문에 도착하기 전에, 우리는 오크를 하나 사로잡았었습니다. 그 오크는 당신이 말한 지팡이를 사용해, 주변의 힘을 흡수하고 어둠의 의식을 치를 것이라고 하더군요.
만약 당신이 이 관문을 사용할 수 있다면, 부디 가서 오크들을 멈춰주십시오.]],
	answers = {
		{"관문은 사용할 수 있습니다. 걱정 마십시오!"},
	}
}

return "welcome"
