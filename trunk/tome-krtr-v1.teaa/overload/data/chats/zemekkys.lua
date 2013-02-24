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

local function remove_materials(npc, player)
	local gem_o, gem_item, gem_inven_id = player:findInAllInventories("Resonating Diamond")
	player:removeObject(gem_inven_id, gem_item, false)
	gem_o:removed()

	local athame_o, athame_item, athame_inven_id = player:findInAllInventories("Blood-Runed Athame")
	player:removeObject(athame_inven_id, athame_item, false)
	athame_o:removed()

	player:incMoney(-100)
end

local function check_materials(npc, player)
	local gem_o, gem_item, gem_inven_id = player:findInAllInventories("Resonating Diamond")
	local athame_o, athame_item, athame_inven_id = player:findInAllInventories("Blood-Runed Athame")
	return gem_o and athame_o and player.money >= 100
end

-----------------------------------------------------------------
-- Main dialog
-----------------------------------------------------------------

newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*문틈이 벌어지면서, 사나운 눈이 당신을 노려봅니다.*#WHITE#
원하는 것이 뭐지, @playerdescriptor.race@?]],
	answers = {
		{"태양의 기사 아에린이 말하길, 당신이 저를 도와줄 수 있다고 하더군요. 저는 마즈'에이알로 돌아가야 합니다.", jump="help", cond=function(npc, player) return game.state:isAdvanced() and not player:hasQuest("west-portal") end},
		{"피의 룬 제례단검을 찾았습니다. 하지만 그곳에 공명하는 다이아몬드는 없었습니다.", jump="athame", cond=function(npc, player) return player:hasQuest("west-portal") and player:hasQuest("west-portal"):isCompleted("athame") and not player:hasQuest("west-portal"):isCompleted("gem") end},
		{"공명하는 다이아몬드를 찾았습니다.", jump="complete", cond=function(npc, player) return player:hasQuest("west-portal") and player:hasQuest("west-portal"):isCompleted("gem") end},
		{"미안합니다, 이만 가볼게요!"},
	}
}

-----------------------------------------------------------------
-- Give quest
-----------------------------------------------------------------
newChat{ id="help",
	text = [[풋! 그녀의 인생의 목표는 내 시간을 낭비시키는 건가? 마즈'에이알? 왜, 나니아 대륙이나 시카고에 보내달라고 하지 차라리? 어짜피 마즈'에이알이나 저곳들이나 상상 속에 존재하는 곳인건 마찬가지니까 말이야. 꺼져버려.
#LIGHT_GREEN#*문이 쾅 소리를 내며 닫혔습니다.*#WHITE#]],
	answers = {
		{"저는 마즈'에이알에서 온 사람입니다. 그리고 오크들에게서 뺏은 마법의 오브 또한 있습니다. 한번 보시는게...", jump="offer"},
	}
}

newChat{ id="offer",
	text = [[#LIGHT_GREEN#*문틈이 열립니다.*#WHITE#
오브라고 했나? 그걸 사용해서 마즈'에이알에서 이곳으로 왔다고? 아무리 그래도 그 오브가 여러 장소로의 오브는 아니겠지? 그 오브는 없어진지 수없이 많은 세월이 지난거라고!]],
	answers = {
		{"[오브를 들어보인다]", jump="offer2"},
	}
}
newChat{ id="offer2",
	text = [[#LIGHT_GREEN#*그의 눈이 커집니다.*#WHITE#
아에린 년에게 축복 있기를! 진짜 그 오브잖아! 아마 너를 집으로 보내줄 수도 있겠군 그래. 물론 일이 잘못되면 천리 밑의 마그마에 쳐박힐 수도 있겠지만 말이야.]],
	answers = {
		{"들어가도 되겠습니까?", jump="offer3"},
	}
}

newChat{ id="offer3",
	text = [[내가 너같이 더러운 @playerdescriptor.race@ 종족과 여러 장소로의 오브를 집에 들어오게 해줄거라고 생각하나?
그런 것 없어도 내 집은 충분히 어지럽다고. 그러니 사양하겠네.
게다가, 관문을 새길 피의 룬 제례단검 없이는 너를 도와줄 수도 없어.
어... 그리고 그 관문은 공명하는 대리석 조각 위에 새겨야 제대로 작동을 해.
아침의 문에 있던 석판이 그 역할을 해왔지만... 여러... 사건들 때문에 수리비가 필요한 상황이 돼서 말이지.
그것을 수리하려면 공명하는 다이아몬드가 필요해. 아, 그리고 금화 100 개 정도도 필요하지.]],
	answers = {
		{"어디서 그것들을 찾을 수 있죠?", jump="quest"},
	}
}

newChat{ id="quest",
	text = [[일단 지갑에 금화 100 개가 있는지부터 확인하는게 좋을걸? 그리고 제례단검과 공명하는 다이아몬드는 오크들이 가지고 있을 거야. 그들이 관문을 만들고 오브를 가지고 있었으니 말이야. 보르 무기고를 뒤져보는게 좋을 것 같군. 내가 어쩌다보니 그곳의 뒷문을 알아냈으니 말이야. 어떻게 찾았는지는 묻지 말고.]],
	answers = {
		{"감사합니다.", action=function(npc, player)
			player:grantQuest("west-portal")
		end},
	}
}


-----------------------------------------------------------------
-- Return athame
-----------------------------------------------------------------
newChat{ id="athame",
	text = [[공명하는 다이아몬드는 당연히 없지. 브리가흐가 잠시라도 그것을 몸에서 떼놓고 있을거라 생각한거야?]],
	answers = {
		{"브리가흐?", jump="athame2"},
	}
}
newChat{ id="athame2",
	text = [[거대한 모래 용, 브리가흐 말이야. 대체 공명하는 다이아몬드가 어떻게 만들어진다고 생각한거지? 그것들은 다이아몬드가 브리가흐의 비늘에 끼인 상태로, 수 세기 동안 녀석의 생명의 힘을 주입받아야 만들어지는 것들이라고. 놈은 값비싼 보석과 금속 더미에서 잠을 청하니까, 딱 보면 알거야.]],
	answers = {
		{"브리가흐가 있는 곳은 어디입니까?", jump="athame3"},
	}
}
newChat{ id="athame3",
	text = [[태양의 장벽에서 남쪽으로 가면 있다. 내가 지도에 표시해주도록 하지.]],
	answers = {
		{"공명하는 다이아몬드를 가지고 돌아오겠습니다.", action=function(npc, player) player:hasQuest("west-portal"):wyrm_lair(player) end},
	}
}

-----------------------------------------------------------------
-- Return gem
-----------------------------------------------------------------
newChat{ id="complete",
	text = [[오? 제례단검과 보석, 금화 100 개를 가져왔나?]],
	answers = {
		{"[그에게 단검과 보석, 금화 100 개를 준다.]", jump="complete2", cond=check_materials, action=remove_materials},
		{"아뇨, 부족한 물건이 있는 것 같습니다. 잠시 후에 다시 오겠습니다."},
	}
}
newChat{ id="complete2",
	text = [[#LIGHT_GREEN#*문이 열리고, 초췌한 엘프가 나왔습니다.*#WHITE#
좋아! 이제 관문을 열 시간이로군!]],
	answers = {
		{"[그를 따라간다]", action=function(npc, player) player:hasQuest("west-portal"):create_portal(npc, player) end},
	}
}

return "welcome"
