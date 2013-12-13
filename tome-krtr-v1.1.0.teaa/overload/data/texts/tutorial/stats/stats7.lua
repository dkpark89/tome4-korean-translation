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

return [[
이번에는 마도사가 되어, 적의 머리통을 화염 망치로 후려갈기는 상황을 상상해봅시다.

화염 망치니까, 당연히 적에게 화염 피해를 주겠죠? 이런 마법은 자신의 #LIGHT_GREEN#주문력#WHITE# 에 따라 공격력이 달라집니다. 그리고 지금껏 우리가 살펴본 #GOLD#전투 능력치#WHITE# 로는 이 공격을 막을 수 없죠. 이 공격을 막기 위해서는 화염에 대한 저항력을 따로 갖춰야만 합니다. (나중에 나오는 내용이니, 지금은 신경쓰지 마세요)

공격력과는 별개로, 망치로 머리를 후려갈기는 이 마법 역시 적을 기절시킬 수 있습니다. 조금 전에 '기절은 물리적 상태효과' 라는 것을 배웠으니, 적이 #LIGHT_GREEN#물리 내성#WHITE# 을 사용해서 기절하지 않으려는 것은 알겠죠? 하지만 조금 전과는 달리 이 기절 상태는 '손에 든 무기' 가 아닌, '마법의 화염 망치' 로 일으키는 효과입니다. 그래서 적을 기절시킬 확률 역시 자신의 #LIGHT_GREEN#주문력#WHITE# 에 달렸죠.

즉, 이번 경우에는 자신의 #LIGHT_GREEN#주문력#WHITE# 과 적의 #LIGHT_GREEN#물리 내성#WHITE# 을 비교하여 기절의 성공 확률을 가리게 됩니다.
]]
