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

local p = game.party:findMember{main=true}
if p:attr("forbid_arcane") and not npc.antimagic_ok then

newChat{ id="welcome",
	text = text,
	answers =
	{
		{"#LIGHT_GREEN#[지금은 도와주는 척을 하지만, 때가 되면 당신은 지구르의 기술을 써서 관문의 작동이 실패하도록 만들 것입니다. @npcname2@ 지구르로 보내져서 제대로 '처리' 될 것입니다.]#WHITE#\n안내하게. 어느 정도 지켜는 주겠어.", action=function(npc, player)
			player:hasQuest(npc.quest_id).to_zigur = true
			npc.ai_state.tactic_leash = 100
			game.party:addMember(npc, {
				control="order",
				type="escort",
				title="Escort",
				orders = {escort_portal=true, escort_rest=true},
			})
		end},
		{"저리 꺼져. 난 더러운 마법 사용자들 따위는 돕지 않아!", action=function(npc, player)
			game.player:registerEscorts("lost")
			npc:disappear()
			npc:removed()
			player:hasQuest(npc.quest_id).abandoned = true
			player:setQuestStatus(npc.quest_id, engine.Quest.FAILED)
		end},
	},
}

else

if not npc.antimagic_ok and profile.mod.allow_build.birth_zigur_sacrifice and not p:attr("has_arcane_knowledge") then

newChat{ id="welcome",
	text = text,
	answers =
	{
		{"안내하게. 내가 보호해주지.", action=function(npc, player)
			npc.ai_state.tactic_leash = 100
			game.party:addMember(npc, {
				control="order",
				type="escort",
				title="Escort",
				orders = {escort_portal=true, escort_rest=true},
			})
		end},
		{"#LIGHT_GREEN#[지금은 도와주는 척을 하지만, 때가 되면 당신은 지구르의 기술을 써서 관문의 작동이 실패하도록 할 것입니다. @npcname2@ 지구르로 보내져서 제대로 '처리' 될 것입니다.]#WHITE#\n안내하게. 어느 정도 지켜는 주겠어.", action=function(npc, player)
			player:hasQuest(npc.quest_id).to_zigur = true
			npc.ai_state.tactic_leash = 100
			game.party:addMember(npc, {
				control="order",
				type="escort",
				title="Escort",
				orders = {escort_portal=true, escort_rest=true},
			})
		end},
		{"저리 가라. 난 약한 자들에는 관심 없다.", action=function(npc, player)
			game.player:registerEscorts("lost")
			npc:disappear()
			npc:removed()
			player:hasQuest(npc.quest_id).abandoned = true
			player:setQuestStatus(npc.quest_id, engine.Quest.FAILED)
		end},
	},
}

else

newChat{ id="welcome",
	text = text,
	answers =
	{
		{"안내하게. 내가 보호해주지.", action=function(npc, player)
			npc.ai_state.tactic_leash = 100
			game.party:addMember(npc, {
				control="order",
				type="escort",
				title="Escort",
				orders = {escort_portal=true, escort_rest=true},
			})
		end},
		{"저리 가라. 난 약한 자들에는 관심 없다.", action=function(npc, player)
			game.player:registerEscorts("lost")
			npc:disappear()
			npc:removed()
			player:hasQuest(npc.quest_id).abandoned = true
			player:setQuestStatus(npc.quest_id, engine.Quest.FAILED)
		end},
	},
}

end

end

return "welcome"
