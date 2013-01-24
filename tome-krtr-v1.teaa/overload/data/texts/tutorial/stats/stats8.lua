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

return [[
즉, 상태효과와 관련된 능력치는 네 개의 공격적인 #GOLD#전투 능력치#WHITE# 와...
#LIGHT_GREEN#정확도#WHITE#
#LIGHT_GREEN#물리력#WHITE#
#LIGHT_GREEN#주문력#WHITE#
#LIGHT_GREEN#정신력#WHITE#

...네 개의 방어적인 #GOLD#전투 능력치#WHITE#... 안 쓰는 능력치가 없네요.
#LIGHT_GREEN#회피도#WHITE#
#LIGHT_GREEN#물리 내성#WHITE#
#LIGHT_GREEN#주문 내성#WHITE#
#LIGHT_GREEN#정신 내성#WHITE#

그래도 걱정할 필요는 없습니다. 다음 두 가지 이유 덕분에, 상태효과에 걸릴 확률을 계산할 때 어떤 능력치를 사용할지 금방 알 수 있거든요.

#GOLD#1)#WHITE#  상태효과를 저항할 때 쓰이는 #GOLD#전투 능력치#WHITE# 는 언제나 일정합니다. 공격 수단에 상관없이 물리적 상태효과는 언제나 #LIGHT_GREEN#물리 내성#WHITE# 으로, 마법적 상태효과는 언제나 #LIGHT_GREEN#주문 내성#WHITE# 으로, 정신적 상태효과는 언제나 #LIGHT_GREEN#정신 내성#WHITE# 으로 저항한다... 이것만 알면 되니까요.

#GOLD#2)#WHITE#  하나의 직업은 대부분 하나의 공격적인 #GOLD#전투 능력치#WHITE# 만을 사용합니다, 광전사는 보통 주문을 외우거나 적의 꿈 속 세계에 들어가거나 하지는 않으니까요. 광전사가 일으키는 상태효과는 #LIGHT_GREEN#물리력#WHITE# 으로! 마법사가 일으키는 상태효과는 #LIGHT_GREEN#주문력#WHITE# 으로! 간단하죠?
]]
