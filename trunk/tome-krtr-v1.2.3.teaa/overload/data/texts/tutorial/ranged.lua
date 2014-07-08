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

if not game.player.tutored_levels2 then
	game.player:learnTalent(game.player.T_SHOOT, true, 1, {no_unlearn=true})
	game.player.tutored_levels2 = true
end

return [[원거리 공격은 화살을 쏘거나, 투석구로 돌을 던지거나, 마법으로 공격하는 것 등을 말합니다.
지금은 활을 얻은 상태이며, 활은 양손으로 사용하는 무기입니다.
화살뭉치만 있으면 화살의 개수에 제한은 없지만, 가끔 재장전 기술을 통해 재장전을 할 필요가 있습니다.
화살을 발사하려면 발사 기술을 사용하면 됩니다.

활과 화살을 장비하기 위해서는...

* 소지품 창을 엽니다.
* 보조 장비 버튼을 클릭하여, 무장을 바꿉니다.
* 소지 중인 활과 화살을 선택한 뒤, 장비합니다.

서쪽에는 트롤들이 있습니다. 활과 화살을 사용해서 트롤을 퇴치하세요!
]]
