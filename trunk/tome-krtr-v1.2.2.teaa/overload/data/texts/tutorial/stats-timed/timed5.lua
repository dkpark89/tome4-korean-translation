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

return [[
방법을 알더라도 운이 나쁘면 통과하기 힘든 곳이였죠. 고생하셨습니다. 이제 지속 효과의 지속시간 계산법을 알려드리겠습니다.

#GOLD#방어자의 전투 능력치가 공격자보다 1 높을 때마다, 상태효과의 지속시간이 5% 씩 감소합니다. (소수점 버림)#WHITE#

조금 전에 사용했던 출혈 기술을 예로 들어보겠습니다. 공격자의 #GOLD#전투 능력치#WHITE#, 즉 자신의 #LIGHT_GREEN#주문력#WHITE# 수치는 56 입니다. 이제 #LIGHT_GREEN#물리 내성#WHITE# 수치가 71 인 트롤에게 출혈을 걸어보겠습니다.

우선 상태효과의 성공 확률을 계산해야겠죠? 위층에서 했던 내용의 복습입니다.

1) 공격자와 방어자의 #GOLD#전투 능력치#WHITE# 차이는 71-56=15 만큼 납니다.

2) #GOLD#전투 능력치#WHITE# 의 수치 차이가 1 날 때마다 성공률이 2.5% 증감한다고 했으니까, 15*2.5%=37.5%.

3) 공격자와 방어자의 #GOLD#전투 능력치#WHITE# 가 같으면 성공 확률이 50% 라고 했으니까, 결국 출혈의 성공 확률은 50-37.5=12.5% 가 되네요.]]

