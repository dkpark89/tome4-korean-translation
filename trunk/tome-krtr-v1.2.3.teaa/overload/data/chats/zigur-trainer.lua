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

require "engine.krtrUtils"

if game.player:isQuestStatus("antimagic", engine.Quest.DONE) then
newChat{ id="welcome",
	text = [[잘 왔네, 친구여.]],
	answers = {
		{"안녕하신가."},
	}
}
return "welcome"
end

local sex = game.player.female and "자매여" or "형제여"

local remove_magic = function(npc, player)
	for tid, _ in pairs(player.sustain_talents) do
		local t = player:getTalentFromId(tid)
		if t.is_spell then player:forceUseTalent(tid, {ignore_energy=true}) end
	end

	-- Remove equipment
	for inven_id, inven in pairs(player.inven) do
		for i = #inven, 1, -1 do
			local o = inven[i]
			if o.power_source and o.power_source.arcane then
				game.logPlayer(player, "당신은 더 이상 %s 사용할 수 없습니다. 마법으로 더럽혀진 장비는 사용할 수 없습니다.", o:getName{do_color=true}:addJosa("를"))
				local o = player:removeObject(inven, i, true)
				player:addObject(player.INVEN_INVEN, o)
				player:sortInven()
			end
		end
	end
	player:attr("forbid_arcane", 1)
	player.changed = true
end

newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*갑옷을 입고 올리브색 큰 망토를 걸친, 엄격한 표정의 전사가 서 있습니다. 그는 적대적이지 않은 것 같으며, 그의 검은 검집에 들어있습니다.*#WHITE#
]]..sex..[[, 우리 모임은 자네를 주시한 결과, 자네가 가능성이 있다는 결론을 내었네.
우리는 저 사악한 마법들이 이 땅이 견디고 있는 모든 시련들의 근원이며, 언젠가 그들이 우리 모두를 파멸로 몰아넣을 것이라고 보고 있네. 그래서 우리는 자연의 힘을 통해, 마법을 사용하는 자들과 싸우고 있지.
우리는 자네를 훈련시켜줄 수 있다네. 하지만 이를 위해서는, 자네는 저 끔찍한 힘에 오염되지 않았으며 끝까지 싸울 준비가 되었는지를, 즉 자네의 순수함을 보여주어야 한다네.
자네는 마법을 사용하는 적들과 전투를 하게 될걸세. 자네가 모든 적들을 물리친다면, 우리의 길을 걷는 방법에 대해 알려주도록 하지. 그리고 다시는 자네가 마법에 오염되거나, 실수로라도 마법을 사용하지 않을 수 있게 만들어주겠네.

#LIGHT_RED#주의 : 이 퀘스트를 클리어하면, 캐릭터는 영구적으로 마법이나 마법에 관련된 물품들을 사용할 수 없게 됩니다.  대신 당신은 정신력을 사용하는 일반 기술 계열인 '반마법' 계열을 익히게 되며, 마법에 오염된 물건들을 처리할 수 있는 숨겨진 방법을 알게 될 수도 있습니다.]],
	answers = {
		{"그 도전, 받아들이겠습니다!", cond=function(npc, player) return player.level >= 10 end, jump="testok"},
		{"그 도전, 받아들이겠습니다!", cond=function(npc, player) return player.level < 10 end, jump="testko"},
		{"관심 없습니다.", jump="ko"},
	}
}

newChat{ id="ko",
	text = [[잘 알겠네. 실망스러운 일이지만, 자네의 선택을 존중해주도록 하지. 잘 있게나.]],
	answers = {
		{"그럼 안녕히."},
	}
}

newChat{ id="testko",
	text = [[아, 자네의 열정은 잘 알겠네. 하지만 자네에게는 아직 조금 이른 듯 하군. 조금 더 성장한 이후에 돌아오도록 하게.]],
	answers = {
		{"알겠습니다."},
	}
}

newChat{ id="testok",
	text = [[잘 알겠네. 시작하기 전에, 그 어떤 마법도 자네를 도울 수 없도록 처리를 좀 해둬야겠네.
- 당신은 이제부터 마법 또는 마법적인 도구들을 사용할 수 없습니다.
- 마법의 힘이 주입된 장비들은 모두 장비해제가 됩니다.

준비는 끝났는가? 아니면 준비할 시간이 조금 더 필요한가?]],
	answers = {
		{"준비는 끝났습니다.", jump="test", action=remove_magic},
		{"준비할 시간이 조금 더 필요합니다."},
	}
}

newChat{ id="test",
	text = [[#VIOLET#*당신은 두 명의 올리브색 옷을 입은 전사들에게 붙잡혀, 투박하게 생긴 투기장으로 던져졌습니다!*
#LIGHT_GREEN#*당신은 투기장 위에서 그 전사의 목소리를 들었습니다.*#WHITE#
]]..sex..[[! 자네의 수련이 시작되었네! 나는 자네가 모든 마법의 힘을 뛰어넘기를 기대하고 있겠네! 어서 싸우게!]],
	answers = {
		{"하지만 대체... [당신은 첫 번째 적이 이미 당신 앞에 있는 것을 발견하였습니다]", action=function(npc, player)
			player:grantQuest("antimagic")
			player:hasQuest("antimagic"):start_event()
		end},
	}
}

return "welcome"
