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
자신이 광전사가 됐다고 생각하시고... 자, 지금 당신은 무기로 적을 기절시키려고 합니다. 만약 적이 기절했다면, 두 가지 일이 반드시 일어나야만 합니다.

우선, 공격이 적에게 맞아야겠죠! 이것은 즉, 자신의 #LIGHT_GREEN#정확도#WHITE# 와 적의 #LIGHT_GREEN#회피도#WHITE# 를 비교한다는 의미입니다.

다음에는, '기절 상태효과' 가 적에게 일어나야겠죠. 이 기절 상태는 분노한 광전사가 휘두른 무기로 일으키는 거니까, 적이 기절할 확률은 자신의 #LIGHT_GREEN#물리력#WHITE# 에 달려있습니다.
'기절' 은 보통 무언가에 머리를 얻어맞았을 때 하게되죠? 즉, '기절' 은 물리적 상태효과입니다. 그래서 적은 #LIGHT_GREEN#물리 내성#WHITE# 을 사용해서 기절하지 않으려고 하죠. 결국 기절 상태효과는 자신의 #LIGHT_GREEN#물리력#WHITE# 과 적의 #LIGHT_GREEN#물리 내성#WHITE# 을 비교해서 성공 여부를 가리게 되죠.

흠... 꽤 간단하네요. 기절은 공격자의 #LIGHT_GREEN#물리력#WHITE# 과 방어자의 #LIGHT_GREEN#물리 내성#WHITE# 을 비교하여 높은 쪽이 이긴다!

...라고 생각하고 계셨다면, 이번에는 다른 상황을 한번 볼까요.
]]
