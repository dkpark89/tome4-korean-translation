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
				game.logPlayer(player, "당신은 이제 %s 더 이상 사용할 수 없습니다.; 이건 마법으로 더럽혀져 있습니다.", o:getName{do_color=true}:addJosa("를"))
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
	text = [[#LIGHT_GREEN#*A grim-looking Fighter stands there, clad in mail armour and a large olive cloak. He doesn't appear hostile - his sword is sheathed.*#WHITE#
]]..sex..[[, our guild has been watching you and we believe that you have potential.
We see that the hermetic arts have always been at the root of each and every trial this land has endured, and we also see that one day they will bring about our destruction. So we have decided to take action by calling upon Nature to help us combat those who wield the arcane.
We can train you, but you need to prove you are pure, untouched by the eldritch forces, and ready to fight them to the end.
You will be challenged against magical foes. Should you defeat them, we will teach you our ways, and never again will you be able to be tainted by magic, or use it.

#LIGHT_RED#노트:  이 퀘스트를 클리어 하면 캐릭터는 영구적으로 마법이나 마법에 관련된 물품들을 사용할 수 없게 됩니다.  대신 당신은 you'll be given access to a mindpower based generic talent tree, Anti-magic, and be able to unlock hidden properties in many arcane-disrupting items.]],
	answers = {
		{"자네의 도전을 받아들이지!", cond=function(npc, player) return player.level >= 10 end, jump="testok"},
		{"자네의 도전을 받아들이지!", cond=function(npc, player) return player.level < 10 end, jump="testko"},
		{"미안하지만 흥미는 없군.", jump="ko"},
	}
}

newChat{ id="ko",
	text = [[잘 알겠네. 좀 실망스럽기는 하지만, 그건 자네의 선택이니. 잘있게나.]],
	answers = {
		{"잘 있게."},
	}
}

newChat{ id="testko",
	text = [[아, 자네의 열망은 잘 알겠지만, 자네에게는 아직 조금 이른 듯 하군. 조금 더 성장한 이후에 돌아오도록 하게.]],
	answers = {
		{"알겠네."},
	}
}

newChat{ id="testok",
	text = [[잘 알겠네. 시작하기 전에, 아무런 마법도 자네를 도울 수 없도록 처리를 좀 해둬야겠네.:
- 당신은 이제부터 마법 또는 마법으로 작동하는 장치를 사용할 수 없습니다.
- 아케인으로 동작하는 장비들은 모두 장비해제가 됩니다.

준비가 되셨습니까, 아니면 시작하기 전에 준비할 시간이 더 필요하십니까?]],
	answers = {
		{"전 이제 준비가 다 되었습니다.", jump="test", action=remove_magic},
		{"준비할 시간이 좀 더 필요합니다."},
	}
}

newChat{ id="test",
	text = [[#VIOLET#*You are grabbed by two olive-clad warriors and thrown into a crude arena!*
#LIGHT_GREEN#*You hear the voice of the Fighter ring above you.*#WHITE#
]]..sex..[[! 자네의 수행이 시작되었네! 난 자네가 마법의 작품들보다 우월함을 증명하기를 기대하고 있네! 어서 싸우게!]],
	answers = {
		{"But wha.. [you notice your first opponent is already there]", action=function(npc, player)
			player:grantQuest("antimagic")
			player:hasQuest("antimagic"):start_event()
		end},
	}
}

return "welcome"
