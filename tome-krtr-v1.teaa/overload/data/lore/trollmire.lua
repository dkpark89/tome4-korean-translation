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

--------------------------------------------------------------------------
-- Trollmire
--------------------------------------------------------------------------

newLore{
	id = "trollmire-note-1",
	category = "trollmire",
	name = "tattered paper scrap (trollmire)",
	kr_display_name = "트롤 늪에서 발견한 낡은 종이 조각",
	lore = [[부스러지기 직전인, 낡은 종이 조각을 발견하였다. 아마 누군가의 일기장에서 뜯어진 조각인 것 같다.
"...굉장히 멋진 숲 속의 공터다. 하지만 맹세컨데, 방금 전에 본 그건 분명 사람의 뼛조각이 분명하다.

...

엄청나게 거대한 트롤을 발견했다. 다행스럽게도, 트롤이 접근하기 전에 내가 여기 있다는 자취를 지우는데 성공했다."]],
}

newLore{
	id = "trollmire-note-2",
	category = "trollmire",
	name = "tattered paper scrap (trollmire)",
	kr_display_name = "트롤 늪에서 발견한 낡은 종이 조각",
	lore = [[부스러지기 직전인, 낡은 종이 조각을 발견하였다. 아마 누군가의 일기장에서 뜯어진 조각인 것 같다.
"...아왔다. 아무리 그래도 트롤은 트롤일 뿐이다. 내 발자취를 숨기는 것은 그리 어렵지 않을 것이다.

...

...롤이 쌓아놓은 보물을 발견하였지만, 이제는 여기서 빠져나가야 한다. 아무나 제발, 도와줘!"]],
}

newLore{
	id = "trollmire-note-3",
	category = "trollmire",
	name = "tattered paper scrap (trollmire)",
	kr_display_name = "트롤 늪에서 발견한 낡은 종이 조각",
	lore = [[부스러지기 직전인, 낡은 종이 조각을 발견하였다. 아마 누군가의 일기장에서 뜯어진 조각인 것 같다.
	
"...나무 위에서 이것을 쓴다. 그는 나무 아래에서 나를 기다리고 있다. 그의 몽둥이는 큰 드워프 만큼이나 크다. 여기서 빠져나갈 방법이 생각나지 않는다..."

주변에 마구 흩어진 피뭍은 종이 조각들이, 마치 이 늪의 일부인 것만 같다...]],
	bloodstains = 3,
	on_learn = function(who)
		local p = game:getPlayer(true)
		p:grantQuest("trollmire-treasure")
	end,
}
