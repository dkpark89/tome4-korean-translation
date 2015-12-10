-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2015 Nicolas Casalini
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
축하합니다! 이제 #GOLD#전투 능력치#WHITE# 의 정확한 계산법을 알려드리겠습니다. 지금까지 한 경험들을 잘 떠올려보세요.

1) 공격자의 #GOLD#전투 능력치#WHITE# 와 방어자의 #GOLD#전투 능력치#WHITE# 를 비교할 때, 그 수치가 20 이상 차이가 난다면 공격은 무조건 성공 또는 실패하게 됩니다.
공격자의 정확도가 40 이고 방어자의 회피도가 20 이라면, 공격은 절대 빗나가지 않는다는 뜻이죠. 이는 단순한 공격은 물론, 기절이나 밀어내기 등 각종 상태효과의 성공 확률에도 똑같이 적용됩니다.

2) 공격자의 #GOLD#전투 능력치#WHITE# 와 방어자의 #GOLD#전투 능력치#WHITE# 가 서로 같다면, 공격이 성공할 확률은 50% 가 됩니다.

이 두 가지 사실을 종합하면, 결국 #GOLD#공격자와 방어자 사이의 전투 능력치가 1 차이날 때마다, 공격/상태효과의 성공 확률이 2.5% 씩 증감한다#WHITE# 는 것을 알 수 있죠.

#GOLD#전투 능력치#WHITE# 는 그 수치가 높아질수록 올리기 힘들어진다는 것을 잘 떠올려보면, 결국 적과 수치 차이를 20 이상 벌려서 '무조건 성공' 이나 '무조건 실패' 를 만들어내는 것은 굉장히 어려운 일이라는 사실도 추측해낼 수 있죠.
]]
