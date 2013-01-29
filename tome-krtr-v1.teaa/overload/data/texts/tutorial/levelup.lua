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

game.player:forceLevelup(2)

return [[ToME4 에서, 캐릭터의 강함은 각자의 레벨로 구분합니다. 플레이어는 캐릭터를 50 레벨까지 키울 수 있습니다.

레벨이 오를 때마다 생명력과 원천력 (체력, 마나 등) 의 최대치가 늘어나며, 캐릭터에 따라 다양한 기술 점수를 얻게 됩니다.

* #GOLD#능력치 점수#WHITE# : 여섯 가지 주요 능력치 (힘, 민첩, 마법, 교활함, 체격, 의지) 를 올릴 때 사용합니다. 레벨이 오를 때마다 3 점을 얻습니다.
* #GOLD#직업기술 점수#WHITE# : 현재 직업의 핵심 기술을 배울 때 사용합니다. 레벨이 오를 때마다 1 점을 얻으며, 레벨이 5의 배수일 경우에는 1 점의 점수를 추가로 얻습니다.
* #GOLD#일반기술 점수#WHITE# : 일반적인 보조 기술, 종족 고유의 기술 등을 배울 때 사용합니다. 레벨이 오를 때마다 1 점을 얻지만, 레벨이 5 의 배수일 경우에는 점수를 얻지 못합니다.
* #GOLD#기술 계열 점수#WHITE# : 새로운 기술 계열을 배우거나, 현재 배운 기술 계열의 적성을 높이고자 할 때 사용합니다. 10 레벨, 20 레벨, 36 레벨에 1 점씩 얻습니다.

레벨은 경험치를 100% 모으면 오르며, 경험치는 비슷한 레벨의 적을 해치우면 얻을 수 있습니다.

캐릭터의 레벨 상승 창은 'p' 키를 누르거나, 마우스 오른쪽 버튼으로 캐릭터를 클릭한 뒤 '레벨 상승' 을 선택하면 열 수 있습니다.

레벨 상승 창을 열고, 기술 점수를 분배해보세요.
]]
