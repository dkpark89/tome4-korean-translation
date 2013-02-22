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

newChat{ id="welcome",
	text = [[제가 도와드릴 일이라도?]],
	answers = {
		{"아에린이시여, 드디어 이곳으로 돌아오는 것에 성공했습니다! [그녀에게 자신의 이야기를 한다]", jump="return", cond=function(npc, player) return player:hasQuest("start-sunwall") and player:isQuestStatus("start-sunwall", engine.Quest.COMPLETED, "slazish") and not player:isQuestStatus("start-sunwall", engine.Quest.COMPLETED, "return") end, action=function(npc, player) player:setQuestStatus("start-sunwall", engine.Quest.COMPLETED, "return") end},
		{"'아침의 문' 에 대한 설명을 더 듣고 싶습니다.", jump="explain-gates", cond=function(npc, player) return player.faction ~= "sunwall" end},
		{"이곳에 도착하기 전에, 마즈'에이알 대륙에서 이곳의 사람들을 몇 명 본 적이 있습니다. 어떻게 된 일인지 아십니까?", jump="sunwall_west", cond=function(npc, player) return game.state.found_sunwall_west and not npc.been_asked_sunwall_west end, action=function(npc, player) npc.been_asked_sunwall_west = true end},
		{"제가 잃어버린 지팡이를 찾을 수 있는 단서를 찾고 있습니다. 도와주십시오.", jump="clues", cond=function(npc, player) return game.state:isAdvanced() and not player:hasQuest("orc-pride") end},
		{"오크 무리의 지도자들을 모두 없애고 왔습니다.", jump="prides-dead", cond=function(npc, player) return player:isQuestStatus("orc-pride", engine.Quest.COMPLETED) end},
		{"오크들이 지팡이를 가져갔던, 검게 탄 상처에서 돌아왔습니다.", jump="charred-scar", cond=function(npc, player) return player:hasQuest("charred-scar") and player:hasQuest("charred-scar"):isCompleted() end},
		{"아닙니다, 이만 가볼게요!"},
	}
}

newChat{ id="return",
	text = [[@playername@! 우리는 당신이 관문 폭발로 인해 죽었다고 생각했습니다. 우리가 틀렸다는 사실이 기쁘군요. 당신이 이곳 태양의 장벽을 구했습니다.
그 지팡이에 대한 소문이 골칫거리지만 말이죠. 어쨌건, 최소한 이곳에서 잠시라도 편히 쉬시길.]],
	answers = {
		{"그러겠습니다. 감사합니다.", jump="welcome"},
	},
}

newChat{ id="explain-gates",
	text = [[이곳의 인구는 주로 두 종류로 나뉩니다. 인간과 엘프들로요.
인간들은 장작더미의 시대 때 이곳으로 건너왔습니다. 우리의 조상들은 마드로프 탐험대의 일부였습니다. 날로레들의 땅이 바다 속으로 가라앉은 이유가 무엇인지 찾기 위한 탐험대였죠. 하지만 그들의 배는 중간에 침몰하였고, 생존자들이 이 대륙에 발을 내딛게 된 것입니다.
그들은 이곳에서 엘프 무리들을 발견하였습니다. 그들은 이곳의 원래 주민들로 보이는 엘프들과 이내 친구가 되었죠. 태양의 장벽을 찾고 아침의 문을 만들면서요.
그 후 오크 무리가 왔고, 우리는 그때부터 지금까지 생존을 위해 그것들과 싸우고 있습니다.]],
	answers = {
		{"감사합니다.", jump="welcome"},
	},
}

newChat{ id="sunwall_west",
	text = [[아아, 그들이 살아있었나요? 좋은 소식이군요...]],
	answers = {
		{"계속 얘기하시죠.", jump="sunwall_west2"},
		{"뭐, 그렇죠... *죽지 않고* 잘 살아있죠...", jump="sunwall_west2", cond=function(npc, player) return game.state.found_sunwall_west_died end},
	},
}

newChat{ id="sunwall_west2",
	text = [[당신이 본 그 사람들은 제메키스의 '장거리 관문 초기 실험' 에 자원한 자들입니다.
그는 이곳 태양의 장벽에 사는 마법사로, 괴짜긴 하지만 숙련된 마법사이지요. 그리고 마즈'에이알로 가는 새로운 장거리 관문을 만들 수 있다고 생각하는 사람이기도 합니다.
그가 초기에 한 몇몇 실험들은 의문스러운 결과만을 도출해냈지만, 아마 그의 불운함도 오늘로 끝을 맺을 것 같군요. 그는 그의 실험에 자원할 사람이 아직 남아있다는 말을 들으면 기뻐할 겁니다. 우리는 모두 하나의 태양 아래 있는 존재이니, 어디서 온 사람인지는 중요하지 않을 것입니다.

그러니... 제메키스를 만나보는 것이 좋을 것 같습니다. 당신이 가지고 있는 여러 장소의 오브를 보면 분명 그는 엄청난 관심을 보일겁니다. 그는 바로 북쪽에 있는 작은 집에서 살고 있습니다.]],
	answers = {
		{"그를 만나보도록 하죠. 감사합니다.", jump="welcome"},
	},
}

newChat{ id="prides-dead",
	text = [[저도 그 소식을 들었습니다. 하지만 지금도 믿을 수가 없군요. 우리는 정말 오랫동안 그들과 전쟁을 치뤄왔는데...
그들의 지도자들이 죽었다? 그것도 단 한명의 @playerdescriptor.race@ 손에? 당신은 정말 놀라울 정도로 강하군요.
당신이 오크들을 학살하느라 바쁜 동안, 우리는 사로잡은 오크로부터 약간의 정보를 얻을 수 있었습니다.
그가 말하길 최고봉으로 가는 곳은 특수한 방법으로 보호되고 있다고 하더군요. 이 보호는 오크 무리의 지배자들이 가지고 있는 "지배의 오브" 로 해제할 수 있다고 했습니다.
만약 지배의 오브를 가지고 있지 않다면, 다시 오크들의 서식지에 가서 찾아보세요.
그리고 그는 최고봉으로 가는 길이 "슬라임 굴"에 있다고 했습니다. 오크 서식지 중 어딘가, 아마 그루쉬낙 무리들이 있던 곳의 어딘가에 있다는군요.
]],
	answers = {
		{"감사합니다. 슬라임 굴을 찾아, 최고봉으로 가보겠습니다.", action=function(npc, player)
			player:setQuestStatus("orc-pride", engine.Quest.DONE)
			player:grantQuest("high-peak")
		end},
	},
}

newChat{ id="clues",
	text = [[저도 당신을 최대한 도와드리고 싶지만, 이미 우리의 힘은 너무나 분산되어 있어 직접적인 지원은 힘들 것 같습니다.
하지만 오크 무리들이 있는 곳 정도는 말해드릴 수 있을 것 같군요.
최근 저희들은 오크들의 새로운 '지배자', 혹은 지배자들이 나타나 그들의 오크 세력의 중심에 있다고 하는 소문을 들었습니다. 아마 그 '지배자' 가 당신이 찾는 신비한 지팡이를 가지고 있지 않을까 싶습니다.
우리는 그들이 '최고봉' 에 있을 것으로 예측하고 있습니다. 이 대륙의 정중앙에 있는 곳이지만, 알 수 없는 보호막 때문에 지금은 접근할 수가 없는 곳이죠.
아무래도 오크 무리들의 서식지를 살펴볼 필요가 있을 것 같군요. 최고봉에 대한 정보를 더 얻을 수도 있을 것이고, 또한 당신이 죽인 하나의 오크는 우리를 공격할 오크 하나를 줄여주는 것과 같으니까요.
알려진 오크 무리의 서식지는 다음과 같습니다.
- 락'쇼르 무리, 남쪽 사막 9 시 방향
- 고르뱃 무리, 남쪽 사막에 있는 산 근처
- 보르 무리, 북동쪽 지역
- 그루쉬낙 무리, 최고봉의 동쪽 사면]],
-- - A group of corrupted humans live in Eastport on the southern coastline; they have contact with the Pride
	answers = {
		{"그들을 조사해보고 오겠습니다.", jump="relentless", action=function(npc, player)
			player:setQuestStatus("orc-hunt", engine.Quest.DONE)
			player:grantQuest("orc-pride")
			game.logPlayer(game.player, "아에린이 당신의 지도에 위치들을 표시해줬습니다.")
		end},
	},
}

newChat{ id="relentless",
	text = [[가기 전에, 약간이나마 더 도움을 드리겠습니다. 당신의 이야기는 감동적이었습니다. 그대의 꺾이지 않는 의지는 밤하늘의 별처럼 빛나보였습니다. 별들의 축복을 받으세요. 당신의 임무를 그 누구도 멈추지 못하게 하세요.
	#LIGHT_GREEN#*그녀는 시원한 손으로 당신의 이마를 만졌습니다. 당신은 갑자기 차오르는 힘을 느꼈습니다.*
	]],
	answers = {
		{"단 하나의 오크도 이 땅에 서지 못하게 만들겠습니다.", jump="welcome", action=function(npc, player)
			player:learnTalent(player.T_RELENTLESS_PURSUIT, true, 1, {no_unlearn=true})
			game.logPlayer(game.player, "#VIOLET#당신은 '끈질긴 추구' 기술을 배웠습니다.")
		end},
	},
}

newChat{ id="charred-scar",
	text = [[저도 그 소식에 대해 들었습니다. 좋은 사람들이 그것을 위해 목숨을 바쳤죠. 그것이 가치 있는 죽음이었으면 하는 바람입니다.]],
	answers = {
		{"그렇습니다, 그들이 오크들을 막았고, 그 덕분에 화산의 중심부로 들어갈 수 있었습니다. *#LIGHT_GREEN#그곳에서 일어난 일을 얘기한다#WHITE#*", jump="charred-scar-success",
			cond=function(npc, player) return player:isQuestStatus("charred-scar", engine.Quest.COMPLETED, "stopped") end,
		},
		{"안타깝게도, 너무 늦고 말았습니다. 하지만 적어도, 중요한 정보를 알아내는 것에는 성공했습니다. *#LIGHT_GREEN#그곳에서 일어난 일을 얘기한다#WHITE#*", jump="charred-scar-fail",
			cond=function(npc, player) return player:isQuestStatus("charred-scar", engine.Quest.COMPLETED, "not-stopped") end,
		},
	},
}

newChat{ id="charred-scar-success",
	text = [[주술사? 그들에 대해서는 들어본 적이 없군요. 오크 무리의 새로운 지배자가 나타났다는 소문을 들었지만, 사실은 지배자'들' 이였던 것 같군요.
당신이 해낸 모든 일에 감사드립니다. 이제 당신이 찾고자 하는 것을 위해 계속 노력해주세요.]],
	answers = {
		{"그들에게 복수를 해주겠습니다.", action=function(npc, player) player:setQuestStatus("charred-scar", engine.Quest.DONE) end}
	},
}

newChat{ id="charred-scar-fail",
	text = [[주술사? 그들에 대해서는 들어본 적이 없군요. 오크 무리의 새로운 지배자가 나타났다는 소문을 들었지만, 사실은 지배자'들' 이였던 것 같군요.
그들이 얻은 힘을 어디에 쓸지 두려워지는군요. 이제 그들을 멈추기는 더욱 힘들어졌지만, 그렇다고 우리가 선택할 수 있는 다른 선택지는 없을테지요.]],
	answers = {
		{"그들에게 복수를 해주겠습니다.", action=function(npc, player) player:setQuestStatus("charred-scar", engine.Quest.DONE) end}
	},
}


return "welcome"
