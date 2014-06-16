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
이제 앞의 예에서 출혈 상태효과의 지속시간이 얼마나 감소하는지 알아봅시다.

1) 공격자와 방어자의 #GOLD#전투 능력치#WHITE# 차이는 71-56=15 만큼 납니다.

2) 방어자의 #GOLD#전투 능력치#WHITE# 가 공격자보다 1 높을 때마다 상태효과의 지속시간이 5% 씩 감소한다고 했으니, 15*5%=75%

3) 원래 출혈 기술은 적에게 10 턴 동안 상태효과를 주는 기술입니다. 하지만 그 지속시간이 75% 감소되는거죠. 즉 10 의 75%, 7.5 턴이 감소됩니다.

4) 그런데 소수점은 버린다고 했죠? 결국 7.5 에서 소수점 수치는 버려, 출혈의 지속시간은 7 턴 감소됩니다. 그래서 이 트롤은 출혈 상태에 딱 3 턴 동안 걸리게 되는 것입니다.

12.5% 의 확률을 뚫고 출혈 상태효과를 트롤에게 걸었지만, 이제 출혈의 지속시간이 줄어들어서 제 효과를 발휘하지 못하게 되는거죠. 결국 이 지속시간 감소 계산은 #LIGHT_GREEN#'훨씬 약한 적을 상대하던 도중에, 어쩌다 한번 상태효과 제대로 걸려서 역습을 허용하는' 상황을 막기 위해서#WHITE# 나온겁니다.
]]
