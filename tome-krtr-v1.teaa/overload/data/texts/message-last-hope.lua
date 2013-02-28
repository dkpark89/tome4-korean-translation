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

local delivered_staff = game.player:resolveSource():isQuestStatus("staff-absorption", engine.Quest.COMPLETED, "survived-ukruk")

if delivered_staff then
return [[@playername7@여, 이 전갈은 매우 중요한 내용을 담고 있네.

자네가 마지막 희망에 남겨 둔 지팡이가 사라졌네. 오크들의 무리가 나타나 지팡이를 비밀 창고로 옮기던 경비들을 습격하였다네.
그러나 우리의 병사들이 간신히 오크들 중 한명을 붙잡아 심문하여 정보를 실토하게 하는데 성공했네.
그는 아는 게 별로 없는 듯 했지만, 그러나 동대륙의 '지배자'에 대해서 말했다네.
그가 레크놀의 전투 지휘자로 추정되는 골부그에 대해서 말했었다네. 골부그는 무리들을 이끌고 관문을 통해 '소포'를 보내려고 하는 듯 싶다네.

이 명령은 매우 중요하네. 가능한 한 빨리 이 골부그나 관문을 찾고, 조사해주기를 바라네.

               #GOLD#-- 왕국연합의 국왕 톨락]]

else

return [[@playername7@여, 이 전갈은 매우 중요한 내용을 담고 있네.

그동안 우리들의 장로들이 자네가 말했던 지팡이에 대한 단서를 찾기 위해 고대 문서들의 내용을 살펴보고 있었다네.
그 지팡이는 물론 강력한 물건으로 밝혀졌다네, 현재 우리가 알아낸 것으론 장소와, 그리고 존재들의 힘을 흡수할 수 있는 것으로 보이네.
이 지팡이가 잘못된 손에 떨어지게 둬서는 안되네, 매우 당연한 거겠지만 오크들의 손도 포함해서 말이지.
자네가 떠나있는 사이, 우리들의 순찰자들중 하나가 우크룩이 이끌던 오크 무리와 조우했다네. 우리들은 그들을 멈출 수 없었지만, 그들 중 한 명을 붙잡는 데에는 성공했다네.
그는 아는 게 별로 없는 듯 했지만, 그러나 먼 동쪽의 '지배자'에 대해서 말했다네.
그는 레크놀의 전투 지휘자로 추정되는 골부그를 만났던 이야기를 말했다네. 골부그는 관문을 통해 '소포'를 보내려고 하는 듯 싶다네.

이 명령은 매우 중요하네. 가능한 한 빨리 이 골부그나 관문을 찾고, 조사해주기를 바라네.

               #GOLD#-- 왕국연합의 국왕, 톨락]]
end
