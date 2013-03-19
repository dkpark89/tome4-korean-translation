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
	text = [[#LIGHT_GREEN#*'주인'이 당신 앞에서 부서짐으로써 그는 패배했습니다. 그러나 눈을 깜박이자, 먼지로부터 그의 형체가 다시 재생되었습니다. 전혀 피해를 입지 않은 모습으로 '주인'은 다시 싸울 준비가 되었습니다!*#WHITE#
아하하 멍청한 놈! 내게 죽음 따위는 아무런 의미도 없다구. 난 주인이고, 넌 내 장난감일 뿐이지. 지금도 그렇고 앞으로도 영원히 말이지.]],
	answers = {
		{"Never! Die!"},
	}
}

return "welcome"
