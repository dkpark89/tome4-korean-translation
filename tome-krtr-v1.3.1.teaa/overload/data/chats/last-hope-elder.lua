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

newChat{ id="welcome",
	text = [[마지막 희망에 온 것을 환영하네, @playername@. 그리고 여행자여, 용무가 있으면 빨리 말하게나. 시간은 소중한 것이라네.]],
	answers = {
		{"여행 중에 기묘한 지팡이를 발견했습니다. (#LIGHT_GREEN#*그 생김새를 설명했습니다.*#LAST#) 아주 오래됐지만, 강력해 보이는 지팡이였습니다. 감히 사용할 엄두도 내지 못했습니다.", jump="found_staff", cond=function(npc, player) return player:isQuestStatus("staff-absorption", engine.Quest.PENDING) end},
		{"지팡이를 찾다가, 저는 장거리 관문을 통해서만 갈 수 있는 동쪽 대륙에 가게 되었습니다. 그리고 방금 전에 그와 비슷한 관문을 통해 이곳으로 돌아오게 되었고, 돌아오면서 관문의 설치법 역시 알아오게 되었습니다. 이제 이곳 마지막 희망에 그 장거리 관문을 설치하여, 여행을 계속하고자 합니다. 아마 그곳에 있는 엘프들도 서대륙과의 거래를 기쁘게 받아들일 것입니다.", jump="east_portal", cond=function(npc, player) local q = player:hasQuest("east-portal"); return q and not q:isCompleted("talked-elder") end},
		{"아무 것도 아닙니다. 실례했습니다, 그럼 이만!"},
	}
}

newChat{ id="found_staff",
	text = [[#LIGHT_GREEN#*그는 잠시 침묵을 지켰습니다.*#WHITE# 이곳에 온 것은 참으로 잘한 선택이오.
그대가 말해준 지팡이의 생김새는 고대에 존재했던 아주 강력한 유물을 떠올리게 하는구료. 잠시 보여줄 수 있겠소?]],
	answers = {
		{"여기 있습니다. #LIGHT_GREEN#*그에게 오크들의 습격에 대해 말했습니다.*#LAST# 당신이 가지고 있어주십시오. 이 강력한 힘은 왕국의 군대가 수호하는 편이 더 안전할 것 같습니다.",
		 jump="given_staff", cond=function(npc, player) return game.party:findInAllPartyInventoriesBy("define_as", "STAFF_ABSORPTION") and player:isQuestStatus("staff-absorption", engine.Quest.COMPLETED, "survived-ukruk") or false end},
		{"사실 지팡이를 잃어버려, 걱정이 됩니다. #LIGHT_GREEN#*그에게 오크들의 습격에 대해 말했습니다.*",
		 jump="lost_staff", cond=function(npc, player) return player:isQuestStatus("staff-absorption", engine.Quest.COMPLETED, "ambush-died") end},
		{"저는 잠시 그것을 가지고 있었지만, 여하튼 잃어버렸지요. 아마 제가 만났던 오크들의 짓인것 같습니다...",
		 jump="lost_staff", fallback=true, cond=function(npc, player) return player:hasQuest("staff-absorption") end},
	}
}

newChat{ id="given_staff",
	text = [[그대의 힘은 정말 놀랍구료. 그만한 오크들의 습격에서 살아남다니.
그리고 오크들이라, 정말 큰 문제가 아닐 수 없소. 그것들이 보이지 않게 된지 벌써 80 년이 흘렀건만... 그들이 저 멀리 동쪽에서 오지는 않았을까 싶소.
어쨌건, 다시 한번 고맙다는 말을 해야 할 것 같구료, @playername@. 큰 도움이 되었소.]],
	answers = {
		{"저야말로 감사하기 이를 데 없습니다.", action=function(npc, player)
			local mem, o, item, inven_id = game.party:findInAllPartyInventoriesBy("define_as", "STAFF_ABSORPTION")
			if mem and o then
				mem:removeObject(inven_id, item, true)
				o:removed()
			end

			player:setQuestStatus("staff-absorption", engine.Quest.DONE)
			world:gainAchievement("A_DANGEROUS_SECRET", player)
		end, jump="orc_hunt"},
	}
}

newChat{ id="lost_staff",
	text = [[오크? 이곳 서대륙에?! 이건 정말 비상사태로군! 벌써 그것들이 보이지 않게 된지 80 년 가까운 세월이 흘렀지만... 그들이 저 멀리 동쪽에서 오지는 않았을까 싶소.
하지만 너무 걱정하지는 마시오. 그대는 이렇게 중요한 소식을 전해주었고, 그 습격에서 죽지 않고 살아남았으니 말이오.]],
	answers = {
		{"저야말로 감사하기 이를 데 없습니다.", action=function(npc, player)
			player:setQuestStatus("staff-absorption", engine.Quest.DONE)
			world:gainAchievement("A_DANGEROUS_SECRET", player)
		end, jump="orc_hunt"},
	}
}

newChat{ id="orc_hunt",
	text = [[그러고 보니, 드워프들 사이에서 도는 소문을 들은 적이 있소. 철의 왕좌 안에 있는 오래된 왕국 레크놀에, 아직도 오크가 존재하고 있다는 소문을 말이오.
이미 소식을 들어 알고 있겠지만, 우리는 그것들이 지팡이와 어떤 관련이 있는지 조사할 사람이 필요하다오.]],
	answers = {
		{"제가 그 광산을 조사해보죠.", action=function(npc, player)
			player:grantQuest("orc-hunt")
		end},
	}
}

newChat{ id="east_portal",
	text = [[정말 놀라운 일이로군! 몇몇 대상인들이 이 새로 만들어질 무역로에 침을 흘리게 되겠군 그래. 하지만 그것보다도, 그 지팡이에 대한 수색 성과는 있나?]],
	answers = {
		{"지팡이는 되찾았고, 문제를 일으킨 장본인들은 제거되었습니다. 그들은 더 이상 우리를 괴롭히지 못할 것입니다. [그에게 지금까지 일어난 일을 알려줍니다]", jump="east_portal_winner", cond=function(npc, player) return player:isQuestStatus("high-peak", engine.Quest.DONE) end},
		{"수색은 계속되고 있습니다. 이 관문을 만들면 지팡이를 되찾는데 큰 도움이 될 것입니다.", jump="east_portal_hunt", cond=function(npc, player) return not player:isQuestStatus("high-peak", engine.Quest.DONE) end},
	}
}

newChat{ id="east_portal_winner",
	text = [[완벽하군! 그렇다면, 이 매력적인 관문에 대해 생각해봄세. 하지만 그런 위대한 고대의 마법은 이미 대부분의 사람들에게서 잊혀지고 말았다는 점이 마음에 걸리는군. 내가 알기로는 자네를 도와줄 수 있는 사람은 이 땅에서 딱 한 명 뿐일세. 최근 이곳 마지막 희망을 찾은 현자, 탄넨이 바로 그일세. 그는 마법과 주술을 사용하는 자들의 안식처인 앙골웬에서 온 사람이라고 자신을 소개했다네. 그는 몇 달 전에 막대한 부를 가진 채 이곳에 왔고, 벌써 그의 탑을 도시 북쪽에 세운 상태라네. 내가 그에 대해 알고 있는 것은 별로 없네만, 그는 믿을만한 사람으로 보이네. 아마 그가 자네의 가장 큰 희망이 될걸세.]],
	answers = {
		{"감사합니다.", action=function(npc, player) player:setQuestStatus("east-portal", engine.Quest.COMPLETED, "talked-elder") end},
	}
}

newChat{ id="east_portal_hunt",
	text = [[그렇다면, 최대한 빨리 이 일을 해결하는게 좋겠군. 이제 이 매력적인 관문에 대해 생각해봄세. 하지만 그런 위대한 고대의 마법은 이미 대부분의 사람들에게서 잊혀지고 말았다는 점이 마음에 걸리는군. 내가 알기로는 자네를 도와줄 수 있는 사람은 이 땅에서 딱 한 명 뿐일세. 최근 이곳 마지막 희망을 찾은 현자, 탄넨이 바로 그일세. 그는 마법과 주술을 사용하는 자들의 안식처인 앙골웬에서 온 사람이라고 자신을 소개했다네. 그는 몇 달 전에 막대한 부를 가진 채 이곳에 왔고, 벌써 그의 탑을 도시 북쪽에 세운 상태라네. 내가 그에 대해 알고 있는 것은 별로 없네만, 그는 믿을만한 사람으로 보이네. 아마 그가 자네의 가장 큰 희망이 될걸세.]],
	answers = {
		{"감사합니다.", action=function(npc, player) player:setQuestStatus("east-portal", engine.Quest.COMPLETED, "talked-elder") end},
	}
}

return "welcome"
