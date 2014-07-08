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

if not game.player.tutored_levels then
	game.player:learnTalent(game.player.T_SHIELD_PUMMEL, true, 1, {no_unlearn=true})
	game.player:learnTalent(game.player.T_SHIELD_WALL, true, 1, {no_unlearn=true})
	game.player.tutored_levels = true
end

return [[이제 '방패 치기' 와 '방패의 벽' 기술을 사용할 수 있게 되었습니다.
배운 기술들은 하단에 표시되며, 순서대로 단축키가 지정됩니다.
마우스 오른쪽 버튼을 클릭하여 기술 목록에서 원하지 않는 기술을 제거할 수 있으며, 'm' 키를 누르면 나오는 기술 설정 창을 통해 기술 목록에 기술을 추가하고 단축키를 설정할 수 있습니다.
단축키는 기본적으로 1 부터 9 까지 배치되며, 각종 도구 역시 단축키로 지정할 수 있습니다.

기술은 단축키를 누르거나, 기술 목록에서 원하는 기술을 선택하거나, 기술 설정 창에서 고르거나, 기술을 사용하고 싶은 곳에 마우스 오른쪽 버튼을 누르는 등의 방법으로 사용할 수 있습니다.

기술의 종류는 다음의 세 가지로 분류할 수 있습니다.

* #GOLD#사용형 (액티브)#WHITE#: 사용하면 그 즉시 특정한 효과를 일으키는 기술입니다.
* #GOLD#지속형 (패시브)#WHITE#: 한번 배우면 영구적으로 효과가 나타나는 기술입니다.
* #GOLD#유지형 (스위치)#WHITE#: 기술을 유지하는 동안 반영구적으로 효과가 지속됩니다.
#LIGHT_GREEN#* 유지형 기술은 기술이 유지되는 동안 원천력 (지금은 체력) 최대치를 사용합니다!#WHITE#

몇몇 기술들은 사용할 때 대상이 필요합니다. 이런 기술들을 사용하면, 대상을 선택할 수 있는 상태가 됩니다.
* #GOLD#키보드 사용#WHITE# : 화살표 키를 눌러 대상을 자동으로 선택합니다. Shift + 방향키를 눌러 한 칸씩 움직일 수 있습니다. Enter 나 Space 키를 눌러 선택합니다.
* #GOLD#마우스 사용#WHITE# : 마우스로 대상을 정한 뒤, 왼쪽 마우스 버튼을 클릭하여 선택합니다.

이제 각종 기술들을 직접 사용해보세요.
* #GOLD#방패 치기#WHITE#: 대상을 방패로 공격해, 기절시키는 기술입니다. 기절한 적은 잠시 동안 속도와 공격력이 대폭 감소하게 됩니다.
* #GOLD#방패의 벽#WHITE#: 기술을 유지하는 동안 회피도와 방어도가 올라가지만, 피해량이 줄어드는 기술입니다. 이 기술은  #GOLD#유지형 (스위치)#WHITE# 기술이기 때문에, 기술을 유지하는 동안 체력 최대치가 일정량 감소합니다. 기술 유지를 해제하면 체력 최대치도 복구됩니다.
* #GOLD#막기#WHITE#: 방패로 공격을 막고, 공격을 완전히 막아낸 뒤에는 치명적인 반격을 날릴 수 있는 기술입니다.
]]
