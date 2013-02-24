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

local function check_materials_gave_orb(npc, player)
	local q = player:hasQuest("east-portal")
	if not q or not q:isCompleted("gotoreknor") or not q:isCompleted("gave-orb") then return false end

	local gem_o, gem_item, gem_inven_id = player:findInAllInventories("Resonating Diamond")
	local athame_o, athame_item, athame_inven_id = player:findInAllInventories("Blood-Runed Athame")
	return gem_o and athame_o
end

local function check_materials_withheld_orb(npc, player)
	local q = player:hasQuest("east-portal")
	if not q or not q:isCompleted("gotoreknor") or not q:isCompleted("withheld-orb") then return false end

	local gem_o, gem_item, gem_inven_id = player:findInAllInventories("Resonating Diamond")
	local athame_o, athame_item, athame_inven_id = player:findInAllInventories("Blood-Runed Athame")
	return gem_o and athame_o
end

if game.player:hasQuest("east-portal") and game.player:hasQuest("east-portal").wait_turn and game.player:hasQuest("east-portal").wait_turn > game.turn then
newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*아무도 응답하지 않습니다. 아마 탄넨은 오브를 연구하느라 바쁜 것 같습니다.*#WHITE#]],
	answers = {
		{"[떠난다]"},
	}
}
else
newChat{ id="welcome",
	text = [[@playerdescriptor.race@ 여행가여, 제가 무슨 도와드릴 일이라도?]],
	answers = {
		{"[지팡이와 여러 장소로의 오브, 그리고 관문에 대한 이야기를 그에게 필요한 만큼만 한다]", jump="east_portal1", cond=function(npc, player) local q = player:hasQuest("east-portal"); return q and q:isCompleted("talked-elder") and not q:isCompleted("gotoreknor") end},
		{"다이아몬드와 제례단검을 가져왔습니다. [그에게 다이아몬드와 제례단검을 넘겨준다]", jump="has_material_gave_orb", cond=check_materials_gave_orb},
		{"다이아몬드와 제례단검을 가져왔습니다. [그에게 다이아몬드와 제례단검을 넘겨준다]", jump="has_material_withheld_orb", cond=check_materials_withheld_orb},
		{"도둑놈, 죽어 마땅한 자식. 죽을 준비나 해라!", jump="fake_orb_end", cond=function(npc, player) local q = player:hasQuest("east-portal"); return q and q:isCompleted("tricked-demon") end},
		{"연구는 어떻게 진행되고 있습니까? 관문을 만들 준비가 되었나요?", jump="wait_end", cond=function(npc, player) local q = player:hasQuest("east-portal"); return q and q:isCompleted("open-telmur") end},
		{"아무 것도 아닙니다. 실례했습니다, 그럼 안녕히!"},
	}
}
end

---------------------------------------------------------------
-- Explain the situation and get quest going
---------------------------------------------------------------
newChat{ id="east_portal1",
	text = [[정말 굉장하군! 고대의 글과 전설로밖에는 들어본 적이 없는 그 오브라니! 잠깐 봐도 되겠는가?]],
	answers = {
		{"[그에게 여러 장소로의 오브를 보여준다]", jump="east_portal2"},
	}
}

newChat{ id="east_portal2",
	text = [[정말이군, 위대한 장인이 만든 물건이 분명해. 아마 리나니일 그녀도 이것의 제작에 손을 대지 않았나 싶군. 이것의 사용법에 대해서도 알아왔다고?]],
	answers = {
		{"그렇습니다. [제메키스가 적어준 쪽지를 보여준다]", jump="east_portal3"},
	}
}

newChat{ id="east_portal3",
	text = [[#LIGHT_GREEN#*그는 몇 분 동안 쪽지의 내용을 읽었습니다.*#WHITE# 아! 그렇군. 처음 봤을 때는 제메키스의 방법이 전혀 이해되지 않았지만, 이제 이해가 될 것 같군. 이런 식으로 적어놔서야 한번에 이해할 수가 있어야지 원. 여하튼 이제 여기서 그와 같은 방법을 통해 관문을 열 수 있게 됐지만, 그의 방법에 의하면 필요한 것들이 있다는군. 피의 룬 제례단검과 공명하는 다이아몬드가 필요하다네.]],
	answers = {
		{"어디서 그것들을 찾을 수 있을지 생각나는 곳이라도 있나요?", jump="east_portal4"},
	}
}

newChat{ id="east_portal4",
	text = [[만약 오크들이 레크놀 깊은 곳에 관문을 만들었다면, 그 물건들 역시 어떻게든 사용을 했겠지. 그리고 제례단검과 다이아몬드가 그들이 만들어낸 관문을 넘어오지 못한다면, 그것들 역시 이곳 마즈'에이알 대륙에 존재하겠지. 레크놀에 있는 관문 근처를 우선 조사해보는 것이 좋을 것 같네. 그들이 관문을 만들고 제례단검과 다이아몬드를 옮기지 않았을 수도 있으니 말이야.]],
	answers = {
		{"그곳을 찾아보겠습니다. 감사합니다.", jump="east_portal5"},
	}
}

newChat{ id="east_portal5",
	text = [[그리고 한 가지 더. 자네가 그것들을 찾아보는 동안 여러 장소로의 오브를 가지고 연구를 해도 되겠나? 나는 그 시공 제어사 제메키스만큼의 지식을 가지고 있지 않다네. 그의 발자취를 따라가기 위해서는 많은 연구가 필요하다만...]],
	answers = {
		{"[그에게 오브를 준다] ", action=function(npc, player) player:hasQuest("east-portal"):give_orb(player) end, jump="gave_orb"},
		{"일단은 제가 오브를 가지고 있겠습니다.", action=function(npc, player) player:hasQuest("east-portal"):withheld_orb(player) end, jump="withheld_orb"},
	}
}

newChat{ id="gave_orb",
	text = [[고맙네. 아주 조심스럽게 다루도록 하지.]],
	answers = {
		{"잘 있으십시오. 제례단검과 다이아몬드를 가지고 돌아오겠습니다.", action=function(npc, player) player:hasQuest("east-portal"):setStatus(engine.Quest.COMPLETED, "gotoreknor") end},
	}
}

newChat{ id="withheld_orb",
	text = [[괜찮네, 서두를 것 없으니 말일세. 하지만 관문을 만들기 전에, 며칠 정도는 오브를 연구할 시간이 필요하다는건 알아두게.]],
	answers = {
		{"알겠습니다. 제례단검과 다이아몬드를 가지고 돌아오겠습니다.", action=function(npc, player) player:hasQuest("east-portal"):setStatus(engine.Quest.COMPLETED, "gotoreknor") end},
	}
}

---------------------------------------------------------------
-- back with materials
---------------------------------------------------------------
newChat{ id="has_material_gave_orb",
	text = [[아주 좋네. 자네가 그것들을 찾는 동안, 나는 모든 준비를 마쳤다네. 오, 이것을 받게. #LIGHT_GREEN#*그가 열쇠 하나를 건네줍니다.*#WHITE# 이 열쇠는 텔무르의 폐허를 여는데 쓰인다네. 오랜 세월 동안 봉인된 한 남자가 있는 곳이지. 만약 그 폐허에서 "확률적 역장의 뒤집힘과 되돌아감" 이라는 제목의 글귀를 발견하게 되면, 그것을 가지고 와주게. 그러면 관문 이동에서 자네가 생존할 확률이 급격하게 올라가게 될 것이라네.]], --men of Sholtar 가 무슨 의미인지 몰라서 일단 '한 남자' 로 번역
	answers = {
		{"감사합니다. 그럼 이만.", action=function(npc, player) player:hasQuest("east-portal"):open_telmur(player) end},
	}
}

newChat{ id="has_material_withheld_orb",
	text = [[아주 좋네. 이제 그 오브를 연구할 수 있게 잠시 빌려줄 수 있겠나?]],
	answers = {
		{"죄송합니다, 잠시라도 이 오브를 눈에서 떼놓을 수는 없습니다.", jump="no_orb_loan"},
		{"여기 있습니다. 잘 간수해 주십시오. 곧 동대륙으로 돌아가봐야 하니까요.", jump="orb_loan"},
	}
}

newChat{ id="no_orb_loan",
	text = [[#LIGHT_GREEN#*늙은 남자가 웃습니다.*#WHITE# 아주 좋네. 그렇다면 자네의 감시 하에 오브에 대해 간단한 조사만 하도록 하겠네.]],
	answers = {
		{"[그에게 오브를 준다]", jump="no_orb_loan2"},
	}
}

newChat{ id="no_orb_loan2",
	text = [[고맙네. 몇 분만 기다리게나. #LIGHT_GREEN#*그는 멍하니 앞뒤로 움직이면서, 오브를 주시합니다.*#WHITE#]],
	answers = {
		{"[기다린다]", jump="no_orb_loan3"},
	}
}

newChat{ id="no_orb_loan3",
	text = [[#LIGHT_GREEN#*그는 걷는 것을 멈추고, 당신에게 오브를 돌려줍니다.*#WHITE# 자네에게 필요한 부분은 대부분 알아낸 것 같네. 하지만 완벽함을 위해서는 몇몇 세부적인 정보가 필요하네. 그 엘프 시공 제어사에게 돌아가서, 그에게 '뒤집한 확률적 역장' 과 '되돌아간 확률적 역장' 의 의미가 무엇인지 물어봐주게. 이 부분은 짐작조차 되지 않아, 자네에게 상당히 불편한 결과가 일어날지도 모르겠다네.]],
	answers = {
		{"답을 가지고 돌아오도록 하죠.", action=function(npc, player) player:hasQuest("east-portal"):ask_east(player) end},
	}
}

newChat{ id="orb_loan",
	text = [[걱정하지 말게. 며칠 뒤에 모든 준비를 끝내고 돌려주겠네. 오, 이것을 받게. #LIGHT_GREEN#*그가 열쇠 하나를 건네줍니다.*#WHITE# 이 열쇠는 텔무르의 폐허를 여는데 쓰인다네. 오랜 세월 동안 봉인된 한 남자가 있는 곳이지. 만약 그 폐허에서 "확률적 역장의 뒤집힘과 되돌아감" 이라는 제목의 글귀를 발견하게 되면, 그것을 가지고 와주게. 그러면 관문 이동에서 자네가 생존할 확률이 급격하게 올라가게 될 것이라네.]],
	answers = {
		{"감사합니다. 그럼 이만.", action=function(npc, player) player:hasQuest("east-portal"):open_telmur(player) end},
	}
}

---------------------------------------------------------------
-- Back to the treacherous bastard
---------------------------------------------------------------
newChat{ id="fake_orb_end",
	text = [[나는 그렇게 생각하지 않네, 멍청이여. 밑을 보게.
#LIGHT_GREEN#*당신은 자신이 관문 위에 서있는 것을 보았습니다.*#WHITE#]],
	answers = {
		{"이건 대체...", action=function(npc, player) player:hasQuest("east-portal"):tannen_tower(player) end},
	}
}

newChat{ id="wait_end",
	text = [[나는 준비가 끝났네. 자네는 그렇지 않지. 밑을 보게.
#LIGHT_GREEN#*당신은 자신이 관문 위에 서있는 것을 보았습니다.*#WHITE#]],
	answers = {
		{"이건 대체...", action=function(npc, player) player:hasQuest("east-portal"):tannen_tower(player) end},
	}
}

return "welcome"
