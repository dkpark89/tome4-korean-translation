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

newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*후드를 걸친 키 큰 남자가 당신을 빤히 쳐다봅니다.*#WHITE#
좋아... 좋아... 정말 장래가 유망한 전사로 보이는군 그래... 이봐 @playerdescriptor.race@, 내가 제안 하나 하지. 너도 보면 알겠지만... 나는 투기장에서 일하는 중개인이야. 나는 우리 관중들을 위해 장래가 유망한 전사들을 공급하고 있지. 너라면 충분히 투기장에 들어올 수 있을만큼 강해보이는데, 어때? 조건은 간단해. 내 밑에 있는 세 명의 부하들과 연속으로 싸워 이기면 끝. 보상도 충분히 주도록 하지.
*당신은 이 비밀스러운, 후드를 걸친 남자가 한 제안을 잠시 고민합니다.*
]],
	answers = {
		{"재밌어보이는군. 투기장에 대해 조금 더 자세히 알고싶은데.", jump="more_ex",
			action = function (self, player) self.talked_to = 1 end,
			cond=function(npc, player) return not profile.mod.allow_build.campaign_arena end},
		{"물론 나는 강하지! 어떤 보상이 있는지 말해보실까?", jump="more",
			action = function (self, player) self.talked_to = 1 end,
			cond=function(npc, player) return profile.mod.allow_build.campaign_arena end},
		{"당신 같은 수상한 남자와는 거래하지 않겠어.", jump="refuse",
		action = function (self, player) self.talked_to = 1 end},
	}
}

newChat{ id="more",
	text = [[#LIGHT_GREEN#*당신은 남자가 후드 안에서 웃고 있다는 것을 느꼈습니다.*#WHITE#
부와 명예를 약속하마. 그리고 지금 내 제안을 받아들이면 아주 유용한 #YELLOW#전투 경험#WHITE#을 전수해주도록 하지...
그래서, 네 결정은? 이제 할 마음이 생겼나?]],
	answers = {
		{"싸울 준비는 끝났다. 시작하지!", jump="accept", action = function (self, player) self.talked_to = 2 end },
		{"나에게 노닥거릴 시간 따위는 없다네, 코르낙이여.", jump="refuse"},
	}
}

newChat{ id="more_ex",
	text = [[#LIGHT_GREEN#*당신은 남자가 후드 안에서 웃고 있다는 것을 느꼈습니다.*#WHITE#
투기장은 용감한 자들이 다른 모든 것들과 싸우는 장소다. 우리는 계속 그 규모를 확장시키고 있고, 그래서 언제나 도전자가 부족하지... 간단하게, 도박이라고 보면 편할거다. 돈 대신 네 전투력을 사용할 뿐이지. 이해되나?
우리는 좋은 구경거리를 만들어주는 자가 필요하다는 얘기지. 물론 그런 자에게는 보답으로... 그 자식 세대까지 전해질 부와 명예를 얻을 수 있는거고.
내가 주는 간단한 시험을 통과한다면... 너를 투기장에 들어갈 수 있게 해주지. 물론 지금 당장 투기장에 들어갈 필요는 없네. 네 모험을 끝내고, 그때 와도 상관 없다네. 
거기에 내 제안을 받아들인다면, 네가 필요할 #YELLOW#전투 경험#WHITE#까지 전수해주도록 하지...
그래서, 네 결정은? 이제 할 마음이 생겼나?]],
	answers = {
		{"싸울 준비는 끝났다. 시작하지!", jump="accept", action = function (self, player) self.talked_to = 2 end },
		{"나에게 노닥거릴 시간 따위는 없다네, 코르낙이여.", jump="refuse"},
	}
}

newChat{ id="refuse",
	text = [[#LIGHT_GREEN#*남자가 실망한 듯한 한숨을 내쉽니다.*#WHITE#
그것 참 불행한 일이로군. 너같은 사람이 필요했는데 말이야. 너는 정말 관중들이 좋아하는 타입이야. 너라면 충분히 투기장의 지배자가 될 수 있을텐데.
아아, 네가 그렇게 결정한다면, 우리는 다시 만날 수 없을거야. 하지만, 만약 마음이 바뀐다면... #YELLOW#데르스에 조금 더 오래 머물러 있도록 하지.#WHITE#
내가 이 주변에 있는 동안에는, 아직 거래의 여지는 남아있는거야. 잘 생각해보라고, @playerdescriptor.race@.]],

	answers = {
		{"다시 보자고. [떠난다]"},
	}
}

newChat{ id="accept",
	text = [[#LIGHT_GREEN#*남자가 조금 더 드러나 보이게 웃습니다.*#WHITE#
좋아! 진정한 싸움꾼은 언제나 싸울 준비가 되어 있는 법이지. 우리를 만난 것을 절대 후회하지 않게 될거야...
그래, 싸울 준비는 됐지?
]],
	answers = {
		{"좋아, 준비 됐어!", jump="go"},
		{"잠깐, 아직 준비는 안됐어.", jump="ok"},
	}
}

newChat{ id="go",
	text = "#LIGHT_GREEN#*남자가 조용히 걷기 시작합니다. 당신을 향해 따라오라는 손짓을 보내고 있습니다.*",
	answers = {
		{"[그를 따라간다]",
		action = function (self, player)
			self:die()
			player:grantQuest("arena-unlock")
			game:changeLevel(1, "arena-unlock", {direct_switch=true})
			require("engine.ui.Dialog"):simpleLongPopup("준비!", "세 명의 적을 해치우십시오!", 400)
		end
		},
	}
}


newChat{ id="win",
	action = function(npc, player) player:attr("invulnerable", 1) end,
	text = [[#LIGHT_GREEN#*그 남자, 코르낙 도적이 그림자에서 나왔습니다.*#WHITE#
잘 했네, @playerdescriptor.race@! 내 가능성이 있을줄 알았지.
#LIGHT_GREEN#*그 남자가 자신의 후드를 벗자, 꽤 젊지만 전투로 단련됐음이 확실한 몸이 드러났습니다.#WHITE#
내 이름은 '레즈' 라고 하네. 나는 투기장에서 좋은 볼거리를 만들어줄 뛰어난 싸움꾼들을 고용하고 있지... 두 방 맞고 죽어버리지 않을 그런 녀석들 말이야. 그리고 너 역시 이제 그들 중 하나가 된거고!
나는 네 모험을 방해할 생각은 없어. 나 역시 모험가였거든, 오래 전에는 말이지. 하지만 우리는 너를 진정한 챔피언으로 만들어줄 수 있어. 많은 자들의 사랑을 받고 다이아몬드로 목욕할 수 있는 사람으로 말이지.

#LIGHT_GREEN#*당신이 도적과 함께 데르스로 돌아오는 동안, 당신은 방금 전에 있었던 전투에 대해 이야기를 나눴습니다. 그는 당신에게 전투 기술에 대한 더 넓은 통찰력을 제공해주었습니다. (#WHITE#일반 기술 점수 +2#LIGHT_GREEN#)+
#WHITE#좋아, @playername@. 이제 나는 가봐야 할 시간이야. 그대의 모험에 행운이 있기를. 그리고 모험이 끝나면 언제든지 우리 투기장에 들러주게!
]],
	answers = {
		{ "그러죠. 그동안 잘 지내시길.", action = function (self, player)
			player:attr("invulnerable", -1)

			local g = game.zone:makeEntityByName(game.level, "terrain", "SAND_UP_WILDERNESS")
			g.change_level = 1
			g.change_zone = "town-derth"
			g.name = "exit to Derth"
			g.kr_name = "데르스로의 출구"
			game.zone:addEntity(game.level, g, "terrain", player.x, player.y)

			game.party:reward("일반 기술 점수 2점을 받을 동료를 고르세요:", function(player)
				player.unused_generics = player.unused_generics + 2
			end)
			game:setAllowedBuild("campaign_arena", true)
			game.player:setQuestStatus("arena-unlock", engine.Quest.COMPLETED)
			world:gainAchievement("THE_ARENA", game.player)
		end
		},
	}
}

newChat{ id="ok",
	text = "#WHITE#좋아, 기다리고 있지... #YELLOW#너무 오래 기다리게 하지는 말라고.",
	answers = {
		{ "그럼 이만."},
	}
}

newChat{ id="back",
	text = [[#LIGHT_GREEN#*코르낙 도적이 환영의 미소를 얼굴에 띄웁니다.*#WHITE#
돌아온 것을 환영하네, @playerdescriptor.race@. 내 아낌 없는 제안에 대해 다시 생각해보았는가?
]],
	answers = {
		{ "그래, 조금 더 자세히 말해주겠나?", jump = "accept", action = function (self, player) self.talked_to = 2 end },
		{ "아니, 잘있으라고."},
	}
}

newChat{ id="back2",
	text = [[
돌아온 것을 환영하네, @playerdescriptor.race@. 이제 준비는 끝났나?
]],
	answers = {
		{ "이제 가지, 코르낙.", jump = "go" },
		{ "잠깐만 더. 장비의 준비가 덜 끝났어."},
	}
}

if npc.talked_to then
	if npc.talked_to == 1 then return "back"
	elseif npc.talked_to >= 2 then return "back2"
	end
else return "welcome" end
