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

local delivered_staff = game.player:resolveSource():isQuestStatus("staff-absorption", engine.Quest.COMPLETED, "survived-ukruk")

if delivered_staff then
return [[@playername7@여, 이 전갈은 매우 중요한 내용을 담고 있네.

자네가 마지막 희망에 남겨둔 지팡이가 사라졌네. 오크들의 무리가 나타나, 지팡이를 비밀 창고로 옮기던 경비들을 습격하였다네.
그러나 우리의 병사들이 간신히 오크 하나를 붙잡는데 성공했고, 이 오크를 심문하여 정보를 얻어내었네.
그 오크도 아는 것은 별로 없었지만, 그는 동대륙에 '지배자들' 이 있다는 말을 했다네.
그는 골부그라는 자 -- 레크놀에 있는 강력한 오크로 추정된다네 -- 에 대해서도 말을 했다네. 그는 무리들을 이끌고 어떤 '물건' 을 관문을 통해 보낸다고 하더군.

긴급 상황일세. 가능한 한 빨리 골부그나 관문을 찾고, 조사해주기를 바라네.

               #GOLD#-- 왕국연합의 국왕, 톨락]]

else

return [[@playername7@여, 이 전갈은 매우 중요한 내용을 담고 있네.

자네가 말했던 지팡이에 대한 단서를 찾기 위해, 원로들이 고대 문서를 샅샅이 살펴보았네.
그 결과, 자네가 말했던 지팡이는 실로 강력한 물건으로 밝혀졌다네. 한 장소나, 존재의 힘을 흡수하는 능력이 있는 것으로 보이네.
이 지팡이가 악인의 손에 들어가게 해서는 안되네. 특히 오크들의 손에 들어가는 일만은 더더욱 있어서는 안될 것이라네.
자네가 떠나 있던 사이, 순찰병들이 우크룩이 이끄는 오크 무리와 조우했다네. 우리는 그들을 멈출 수 없었지만, 그들 중 하나를 붙잡는 것에는 성공했다네.
그 오크도 아는 것은 별로 없었지만, 그는 동대륙에 '지배자들' 이 있다는 말을 했다네.
그는 골부그라는 자 -- 레크놀에 있는 강력한 오크로 추정된다네 -- 에 대해서도 말을 했다네. 그는 무리들을 이끌고 어떤 '물건' 을 관문을 통해 보낸다고 하더군.

긴급 상황일세. 가능한 한 빨리 골부그나 관문을 찾고, 조사해주기를 바라네.

               #GOLD#-- 왕국연합의 국왕, 톨락]]
end
