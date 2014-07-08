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

local p = game.party:findMember{main=true}
if p:attr("forbid_arcane") then

newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*당신 앞에 젊은 남성이 서있습니다. 외관상 초보 마법사로 보입니다.*#WHITE#
좋은 날입니... #LIGHT_GREEN#*그는 당신을 쳐다보더니, 빠르게 도망가기 시작합니다!*#WHITE#
죽이지는 말아주세요! 제발!]],
	answers = {
		{"...", action = function(npc, player) npc:die() end,
},
	}
}
return "welcome"

end

newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*당신 앞에 젊은 남성이 서있습니다. 외관상 초보 마법사로 보입니다.*#WHITE#
좋은 날입니다, 여행자님!]],
	answers = {
		{"견습 마법사가 이런 곳에 나와 있는 이유를 물어도 될까요?", jump="quest", cond=function(npc, player) return not player:hasQuest("mage-apprentice") end},
		{"이런 물건을 찾았습니다. 강력한 마법의 힘이 주입된 것 같은데, 이정도면 되는지요?",
			jump="unique",
			cond=function(npc, player) return player:hasQuest("mage-apprentice") and player:hasQuest("mage-apprentice"):can_offer_unique(player) end,
			action=function(npc, player, dialog) player:hasQuest("mage-apprentice"):collect_staff_unique(npc, player, dialog) end
		},
		-- Reward for non-mages: access to Angolwen
		{"이제 마법이 깃든 물건은 충분히 모았나요?",
			jump="thanks",
			cond=function(npc, player) return player:hasQuest("mage-apprentice") and player:hasQuest("mage-apprentice"):isCompleted() and not player:knowTalent(player.T_TELEPORT_ANGOLWEN) end,
		},
		-- Reward for mages: upgrade a talent mastery
		{"이제 마법이 깃든 물건은 충분히 모았나요?",
			jump="thanks_mage",
			cond=function(npc, player) return player:hasQuest("mage-apprentice") and player:hasQuest("mage-apprentice"):isCompleted() and player:knowTalent(player.T_TELEPORT_ANGOLWEN) end,
		},
--		{"Do you have any items to sell?", jump="store"},
		{"미안합니다, 이만 가볼게요!"},
	}
}

newChat{ id="quest",
	text = [[아아, 제 이야기는 슬픈 이야기입니다... 당신에게 폐를 끼치고 싶지는 않군요, 친구여.]],
	answers = {
		{"폐를 끼치다니 무슨 소리! 무슨 일인지 말만 해주십시오!", jump="quest2"},
		{"알았어요. 그럼 안녕!"},
	}
}
newChat{ id="quest2",
	text = [[음, 그렇게 말하신다면야...
저는 초보 마법사입니다. 당신도 눈치를 채셨겠지만요. 그리고 제 목표는 앙골웬의 사람들에게 인정을 받아 마법의 비밀을 전수받는 것이죠.]],
	answers = {
		{"앙골웬의 사람들?", jump="quest3", cond=function(npc, player) return player.faction ~= "angolwen" end,},
		{"아, 앙골웬. 아주 오랜 시간 동안 그곳은 제 고향이였죠...", jump="quest3_mage", cond=function(npc, player) return player.faction == "angolwen" end,},
		{"음, 행운을 빌게요. 안녕!"},
	}
}
newChat{ id="quest3",
	text = [[수호자들입니다. 마버... 으흠, 그들에 대해 이야기하면 안 될 사정이 있습니다... 미안해요, 친구여...
어찌 됐건, 저는 많은 물건들을 모아야 합니다. 이미 어느 정도는 모았지만, 아직 마법의 힘이 깃든 고대의 유물이 하나 부족합니다. 당신에게도 없겠지요, 아마... 혹시, 가지고 있다면, 저에게 말해주세요!]],
	answers = {
		{"그 말, 기억하고 있도록 하죠!", action=function(npc, player) player:grantQuest("mage-apprentice") end},
		{"싫어요. 안녕!"},
	}
}
newChat{ id="quest3_mage",
	text = [[저도 그랬으면 좋겠네요...
어찌 됐건, 저는 많은 물건들을 모아야 합니다. 이미 어느 정도는 모았지만, 아직 마법의 힘이 깃든 고대의 유물이 하나 부족합니다. 당신에게도 없겠지요, 아마... 혹시, 가지고 있다면, 저에게 말해주세요!]],
	answers = {
		{"그 말, 기억하고 있도록 하죠!", action=function(npc, player) player:grantQuest("mage-apprentice") end},
		{"싫어요. 안녕!"},
	}
}

newChat{ id="unique",
	text = [[잠깐 확인을 해볼게요.
오, 맞아요, 친구여. 정말 강력한 고대의 유물이 맞아요! 이제 제 임무를 충족시킬 수 있을 것 같아요! 정말 고맙습니다!]],
	answers = {
		{"뭐, 어짜피 못 쓰는 물건이였어요.", jump="welcome"},
	}
}

newChat{ id="thanks",
	text = [[아, 맞아요! 정말 기쁘네요! 이제 앙골웨... 으으... 음, 좋아요. 저를 도와주셨으니, 이정도는 말해도 되겠죠.
수천 년 전, 마법사냥의 시기 동안, 칼'크룰의 위대한 마법사였던 리나니일은 그녀의 대에 마법이 사라져 필멸자들이 마법이 다시 필요하게 될 때 쓰지 못하게 될까봐 걱정을 하였습니다.
그래서 그녀는 비밀리에 계획을 세워, 실행에 옮겼죠. 마법이 유지될 수 있는 비밀의 장소를 만든 거에요.
그녀의 계획은 서쪽 산에 앙골웬이라는 마을을 만드는 것이였죠. #LIGHT_GREEN#*그가 당신의 지도에 앙골웬으로 가는 마법 관문을 표시해줍니다.*#WHITE#
그곳에 살도록 허락받은 사람들은 그리 많지 않지만, 당신은 이곳에 올 수 있도록 제가 준비를 해놓겠습니다.]],
	answers = {
		{"오! 어떻게 이 오랜 세월 동안 이런 곳이 비밀을 지켜올 수 있었는지... 정말 흥미롭군요. 저를 믿어줘서 감사합니다!",
			action = function(npc, player)
				player:hasQuest("mage-apprentice"):access_angolwen(player)
				npc:die()
			end,
		},
	}
}

newChat{ id="thanks_mage",
	text = [[아, 맞아요! 정말 기쁘네요! 이제 앙골웬으로 돌아갈 수 있을 것 같습니다. 아마 우리도 그곳에서 다시 보게 되겠죠.
이 반지를 드릴게요. 저를 잘 지켜주던 반지입니다.]],
	answers = {
		{"감사합니다. 마법을 배울 때 행운이 함께 하시길!",
			action = function(npc, player)
				player:hasQuest("mage-apprentice"):ring_gift(player)
				npc:die()
			end,
		},
	}
}

return "welcome"
