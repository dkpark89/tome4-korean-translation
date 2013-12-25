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

require "engine.krtrUtils"

local art_list = mod.class.Object:loadList("/data/general/objects/brotherhood-artifacts.lua")
local alchemist_num = 1
local other_alchemist_nums = {2, 3, 4}
local q = game.player:hasQuest("brotherhood-of-alchemists")
local final_reward = "LIFEBINDING_EMERALD"
local e = {
	{
	short_name = "fox",
	name = "elixir of the fox",
	kr_name = "여우의 엘릭서",
	id = "ELIXIR_FOX",
	start = "fox_start",
	almost = "fox_almost_done",
	full = "elixir_of_the_fox",
	full_2 = "elixir_of_avoidance",
	full_3 = "elixir_of_precision",
	poached = "fox_poached",
	},
	{
	short_name = "avoidance",
	name = "elixir of avoidance",
	kr_name = "회피의 엘릭서",
	id = "ELIXIR_AVOIDANCE",
	start = "avoidance_start",
	almost = "avoidance_almost_done",
	full = "elixir_of_avoidance",
	full_2 = "elixir_of_the_fox",
	full_3 = "elixir_of_precision",
	poached = "avoidance_poached",
	},
	{
	short_name = "precision",
	name = "elixir of precision",
	kr_name = "정밀함의 엘릭서",
	id = "ELIXIR_PRECISION",
	start = "precision_start",
	almost = "precision_almost_done",
	full = "elixir_of_precision",
	full_2 = "elixir_of_the_fox",
	full_3 = "elixir_of_avoidance",
	poached = "precision_poached",
	},
}

--cond function for turning in non-final elixirs
--checks that player has quest and elixir ingredients, hasn't completed it yet, has started that elixir, and hasn't completed both other elixirs since that would make this the last one:
local function turn_in(npc, player, n) -- n is the index of the elixir we're checking on
	return q and q:check_ingredients(player, e[n].short_name, n) -- make sure we have the quest and the elixir's ingredients
	and not q:isCompleted(e[n].almost) and not q:isCompleted(e[n].full) --make sure we haven't finished the quest already
	and q:isCompleted(e[n].start) --make sure we've been given the task to make this elixir
	and not (q:isCompleted(e[n].full_2) and q:isCompleted(e[n].full_3)) --make sure we haven't already finished both the other elixirs, since that would make this the final one which requires a special dialog.
end

--cond function for turning in final elixir with index n
--checks that player has quest and elixir ingredients, hasn't completed it yet, has started that elixir, and both the other elixirs are done
local function turn_in_final(npc, player, n) -- n is the index of the elixir we're checking on
	return q and q:check_ingredients(player, e[n].short_name, n) -- make sure we have the quest and the elixir's ingredients
	and not q:isCompleted(e[n].almost) and not q:isCompleted(e[n].full) --make sure we haven't finished the quest already
	and q:isCompleted(e[n].start) --make sure we've been given the task to make this elixir
	and (q:isCompleted(e[n].full_2) and q:isCompleted(e[n].full_3)) --make sure the other two elixirs are made, thus making this the final turn-in
end

--cond function for turning in poached (completed by somebody besides you) elixirs
--checks that the player has the quest and elixir ingredients, hasn't turned it in, the task is complete anyway, the task has actually been started, and that it's been poached
local function turn_in_poached(npc, player, n) -- n is the index of the elixir we're checking on
	return q and q:check_ingredients(player, e[n].short_name, n) -- make sure we have the quest and the elixir's ingredients
	and not q:isCompleted(e[n].almost) --make sure we haven't turned it in already
	and q:isCompleted(e[n].full) --make sure that, even though we haven't turned it in, the elixir has been made for this alchemist
	and q:isCompleted(e[n].start) --make sure we've been given the task to make this elixir
	and q:isCompleted(e[n].poached)  --make sure this task has been poached
end

local function more_aid(npc, player)
	return not (q:isCompleted(e[1].full) and q:isCompleted(e[2].full) and q:isCompleted(e[3].full)) --make sure all the elixirs aren't already made
	--Next, for each of the three elixirs, make sure it's not the case that we're still working on it
	and not (q:isCompleted(e[1].start) and not q:isCompleted(e[1].full))
	and not (q:isCompleted(e[2].start) and not q:isCompleted(e[2].full))
	and not (q:isCompleted(e[3].start) and not q:isCompleted(e[3].full))
end

local function give_bits(npc, player, n) -- n is the index of the elixir we're checking on
	return q and q:check_ingredients(player, e[n].short_name) -- make sure we have the quest and the elixir's ingredients
	and q:isCompleted(e[n].start) --make sure we've started the task
	and not q:isCompleted(e[n].full) --... but not finished
end

local function empty_handed(npc, player, n) -- n is the index of the elixir we're checking on
	return q and q:check_ingredients(player, e[n].short_name, n) -- make sure we have the quest and the elixir's ingredients
	and q:isCompleted(e[n].start) --make sure we've started the task
	and not q:isCompleted(e[n].almost) --make sure we've not turned the stuff in before...
	and q:isCompleted(e[n].full)  --... and yet the elixir is already made (poached!)
end

--Make the alchemist's reaction to your turn-in vary depending on whether he lost.
local function alchemist_reaction_complete(npc, player, lose, other_alch, other_elixir)
	if lose == true then
		return ([[후... 너무 늦었다네. %s 놈이 벌써 입단 심사를 끝냈다는군. 뭐, 그래도 엘릭서는 만들어주도록 하지. 자네에게는 과분한 보상이겠지만 말이야.]]):format(other_alch)
	else
		return ([[아, 좋군 그래. 이리 주게나. 하지만 자네가 오랫동안 자리를 비운 동안, %s 놈이 %s 만들었다는 소식을 들었다네. 그놈이 내 자리를 뺏는걸 볼 바에야, 차라리 내 목숨을 끊고 말테니 그리 알게.]]):format(other_alch, other_elixir:addJosa("를"))
	end
end

if not q or (q and not q:isCompleted(e[1].start) and not q:isCompleted(e[2].start) and not q:isCompleted(e[3].start)) then

-- Here's the dialog that pops up if the player has never worked for this alchemist before:
newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*아주 깔끔한 흰색 비단 로브를 입은 남자가 문을 열고, 당신을 살펴봅니다.*#WHITE#
아, 모험가인가. 마침 새로운 모험가가 하나 필요했던 참인데.]],
	answers = {
		{"그것 참 반가우면서도... 불길한 말이군요.", jump="ominous"},
		{"[떠난다]"},
	}
}

newChat{ id="ominous",
	text = [[그렇다네. 보상은 크지만 대가도 만만찮은 일이지. 자네가 훌륭하게 일을 해낸다면, 나 역시 훌륭한 보상을 줄 수 있다네. 하지만, 자네를 사지에 몰아넣을 수도 있는 일이지. 벌써 세 명째라네. 일을 맡겼다가 다시는 돌아오지 못하게 된 모험가가 말일세.]],
	answers = {
		{"무슨 일이길래...?", jump="proposal"},
	}
}

newChat{ id="proposal",
	text = [[좋은 질문이네, 모험가여. 나는 연금술사, 아주 뛰어난 연금술사라네. 그리고 올해, 처음으로, 저 위대한 '연금술사 형제단' 이 나를 입단 후보로 승인해주었네. 자세한 입단 승인 절차를 설명해주면 자네 머리에 쥐가 날테니, 간단하게 얘기하지. *아주 힘든* 일이라네. 운이 좋게도, 나와 입단 사이에는 이제 간단한 세 가지 일만이 남아있는 상태지.]],
	answers = {
		{"제가 도와드릴 일은?", jump="help"},
	}
}

newChat{ id="help",
	text = [[세 가지 일, 즉 세 가지 엘릭서를 만들기 위한 재료가 필요하다네. 당연한 말이지만, 내가 자네의 도움이 필요하다는 뜻은 그 재료들이 이곳의 약초상에게서는 구할 수 없는 재료라는 뜻이겠지. 내가 필요한 재료들은 그 재료의 소유자에게서 강제적으로 가져와야 하는 것들이고, 그러려면 그 소유자들과 싸울 수밖에 없네. 적어도 나는 부탁한다고 자기 혀를 뽑아주는 나가는 만나본 적이 없으니까 말일세! 하! 오, 나도 가끔은 이런 농담도 할 줄 안다네.]],
	answers = {
		{"괴물들에게서 장기를 잘라내는 것 하나는 자신있습니다. 그 일에 대한 대가는?", jump="competition"},
	}
}

newChat{ id="competition",
	text = [[아, 내 노력의 결실을 나눠주겠다네! 세 가지 재료로 엘릭서를 만들면, 한번에 세 병 정도는 만들어낼 수 있으니 말일세. 하나는 내가 가지고, 하나는 그 빌어먹을 입단 심사를 위해 쓰고... 나머지 하나는 자네가 가지게 되는거지. 이제 이 일의 핵심을 말해줄 시간이로군. 올해 연금술사 형제단의 초대를 받은 것은 나 혼자가 아니라네. 하지만 빈 자리는 딱 하나 뿐이지... 입단 심사를 먼저 마친 사람이 그 자리에 앉게 되는거고. 내가 알기로는 3 명 정도의 다른 경쟁자들이 나를 위해 마련된 자리에 앉으려고 고군분투 중이라고 들었네. 자네가 나의 진정한 가치를 꿰뚫어볼 수 있다면, 나를 도와주게. 만약 내가 최종적으로 입단 심사를 통과하게 된다면, 저 엘릭서들보다도 더 엄청난걸 주지. 바로 위대한 힘과 건강과 생명력을 주는 고대의 보석 '생명력이 묶인 에메랄드'라네. 물론 보석을 사용할 줄 모르면 한낱 돌덩어리에 불과하겠지만 말일세. 어떤가? 나를 도와주겠나?]],
	answers = {
		{"그러죠.", jump="choice", action = function(npc, player) player:grantQuest("brotherhood-of-alchemists") end,},
		{"지금은 도와드릴 수 없을 것 같군요."},
	}
}

newChat{ id="choice",
	text = [[좋아. 나는 이제 세 가지 엘릭서를 만들기 위한 기본 작업을 시작하겠네. 자네는 한 번에 하나의 엘릭서 재료만 구해주면 되네. 나는 모험가들의 뇌 용량을 과신하면 어떤 참상이 일어나는지 충분히 알고 있으니 말일세. 자네에게 선택할 기회를 주지. 여우의 엘릭서는 자네의 몸놀림과 교활함을 여우와 같이 만들어준다네. 회피의 엘릭서는 자네의 자연적 기질을 끌어올려 위험한 상황에서 공격을 피할 수 있게 되지. 정밀함의 엘릭서는 적의 가장 민감한 부위를 직감적으로 이해할 수 있는 능력을 준다네. 어떤 엘릭서를 만들고 싶은가?]],
	answers = {
		{""..e[1].kr_name.."", jump="list",
			cond = function(npc, player) return not game.player:hasQuest("brotherhood-of-alchemists"):isCompleted(e[1].full) end,
			action = function(npc, player)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, e[1].start)
				game.player:hasQuest("brotherhood-of-alchemists"):update_needed_ingredients(player)
			end,
			on_select=function(npc, player)
				local o = art_list[e[1].id]
				o:identify(true)
				game.tooltip_x, game.tooltip_y = 1, 1
				game:tooltipDisplayAtMap(game.w, game.h, tostring(o:getDesc()))
			end,
		},
		{""..e[2].kr_name.."", jump="list",
			cond = function(npc, player) return not game.player:hasQuest("brotherhood-of-alchemists"):isCompleted(e[2].full) end,
			action = function(npc, player)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, e[2].start)
				game.player:hasQuest("brotherhood-of-alchemists"):update_needed_ingredients(player)
			end,
			on_select=function(npc, player)
				local o = art_list[e[2].id]
				o:identify(true)
				game.tooltip_x, game.tooltip_y = 1, 1
				game:tooltipDisplayAtMap(game.w, game.h, tostring(o:getDesc()))
			end,
		},
		{""..e[3].kr_name.."", jump="list",
			cond = function(npc, player) return not game.player:hasQuest("brotherhood-of-alchemists"):isCompleted(e[3].full) end,
			action = function(npc, player)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, e[3].start)
				game.player:hasQuest("brotherhood-of-alchemists"):update_needed_ingredients(player)
			end,
			on_select=function(npc, player)
				local o = art_list[e[3].id]
				o:identify(true)
				game.tooltip_x, game.tooltip_y = 1, 1
				game:tooltipDisplayAtMap(game.w, game.h, tostring(o:getDesc()))
			end,
		},
		{"[떠난다]"},
	}
}

newChat{ id="list",
	text = [[내가 필요한 재료들의 목록이라네. 재료를 찾다가 죽어버리지는 말게나. 올해의 기회를 놓치느니 차라리 내가 죽고 말테니까. 오, 그리고 이미 몇몇 모험가들이 재료를 찾기 위해 세계의 불쾌한 지역들을 돌아다니고 있다는 사실을 말해줘야겠군. 자네가 미적거린다면, 다른 모험가가 먼저 와서 엘릭서를 마셔버릴지도 모른다네.]],
	answers = {
		{"그럼 이만."},
	}
}

-- Quest is complete; nobody answers the door
elseif q and q:isStatus(q.DONE) then
newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*문은 잠겨 있고, 아무도 당신의 노크에 응답하지 않습니다.*#WHITE#]],
	answers = {
		{"[떠난다]"},
	}
}


else -- Here's the dialog that pops up if the player *has* worked with this alchemist before (either done quests or is in the middle of one):

local other_alch, other_elixir, player_loses, alch_picked, e_picked = q:competition(player, other_alchemist_nums)

newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*연금술사가 문을 열었습니다.*#WHITE#
아, 자네인가.]],
	answers = {
		-- If not the final elixir:
		{""..e[1].kr_name.."에 필요한 재료를 모두 가져왔습니다.", jump="complete",
			cond = function(npc, player) return turn_in(npc, player, 1) end,
			action = function(npc, player)
				q:on_turnin(player, alch_picked, e_picked, false)
			end,
		},
		{""..e[2].kr_name.."에 필요한 재료를 모두 가져왔습니다.", jump="complete",
			cond = function(npc, player) return turn_in(npc, player, 2) end,
			action = function(npc, player)
				q:on_turnin(player, alch_picked, e_picked, false)
			end,
		},
		{""..e[3].kr_name.."에 필요한 재료를 모두 가져왔습니다.", jump="complete",
			cond = function(npc, player) return turn_in(npc, player, 3) end,
			action = function(npc, player)
				q:on_turnin(player, alch_picked, e_picked, false)
			end,
		},

		-- If the final elixir:
		{""..e[1].kr_name.."에 필요한 재료를 모두 가져왔습니다.", jump="totally-complete",
			cond = function(npc, player) return turn_in_final(npc, player, 1) end,
		},
		{""..e[2].kr_name.."에 필요한 재료를 모두 가져왔습니다.", jump="totally-complete",
			cond = function(npc, player) return turn_in_final(npc, player, 2) end,
		},
		{""..e[3].kr_name.."에 필요한 재료를 모두 가져왔습니다.", jump="totally-complete",
			cond = function(npc, player) return turn_in_final(npc, player, 3) end,
		},

		-- If the elixir got made while you were out:
		{""..e[1].kr_name.."에 필요한 재료를 모두 가져왔습니다.", jump="poached",
			cond = function(npc, player) return turn_in_poached(npc, player, 1) end,
		},
		{""..e[2].kr_name.."에 필요한 재료를 모두 가져왔습니다.", jump="poached",
			cond = function(npc, player) return turn_in_poached(npc, player, 2) end,
		},
		{""..e[3].kr_name.."에 필요한 재료를 모두 가져왔습니다.", jump="poached",
			cond = function(npc, player) return turn_in_poached(npc, player, 3) end,
		},

		--Don't let player work on multiple elixirs for the same alchemist.
		--See comments in more_aid function above for all the gory detail
		{"당신을 조금 더 도와드리기 위해 왔습니다.", jump="choice",
			cond = function(npc, player) return more_aid(npc, player) end,
		},
		{"[떠난다]"},
	}
}

--Not final elixir:
newChat{ id="complete",
	text = alchemist_reaction_complete(npc, player, player_loses, other_alch, other_elixir),
	answers = {
		{"[그에게 모아온 재료들을 준다]", jump="complete2",
			cond = function(npc, player) return give_bits(npc, player, 1) end,
			action = function(npc, player)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, e[1].almost)
				q:remove_ingredients(player, e[1].short_name, 1)
			end
		},
		{"[그에게 모아온 재료들을 준다]", jump="complete2",
			cond = function(npc, player) return give_bits(npc, player, 2) end,
			action = function(npc, player)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, e[2].almost)
				q:remove_ingredients(player, e[2].short_name, 2)
			end
		},
		{"[그에게 모아온 재료들을 준다]", jump="complete2",
			cond = function(npc, player) return give_bits(npc, player, 3) end,
			action = function(npc, player)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, e[3].almost)
				q:remove_ingredients(player, e[3].short_name, 3)
			end
		},
--		{"Sorry, it seems I lack some stuff. I will be back."},
	}
}

--Final elixir:
newChat{ id="totally-complete",
	text = [[#LIGHT_GREEN#*연금술사가 활짝 웃으면서, 재료들을 빨리 가져가고 싶다는 태도를 취합니다.*#WHITE#
굉장해, 정말 굉장해! 마지막 한 발짝을 내딛는 순간! 자, 빨리 그 재료들을 주게나!]],
	answers = {
		{"[그에게 모아온 재료들을 준다]", jump="totally-complete2",
			cond = function(npc, player) return give_bits(npc, player, 1) end,
			action = function(npc, player)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, e[1].almost)
				q:remove_ingredients(player, e[1].short_name, 1)
			end
		},
		{"[그에게 모아온 재료들을 준다]", jump="totally-complete2",
			cond = function(npc, player) return give_bits(npc, player, 2) end,
			action = function(npc, player)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, e[2].almost)
				q:remove_ingredients(player, e[2].short_name, 2)
			end
		},
		{"[그에게 모아온 재료들을 준다]", jump="totally-complete2",
			cond = function(npc, player) return give_bits(npc, player, 3) end,
			action = function(npc, player)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, e[3].almost)
				q:remove_ingredients(player, e[3].short_name, 3)
			end
		},
		--{"Sorry, it seems I lack some stuff. I will be back."},
	}
}

--Not final elixir:
newChat{ id="complete2",
	text = [[여기서 내 예술적인 작품이 완성되기까지 잠깐 기다리게나. 한 시간 내로는 끝날테니 말일세.]],
	answers = {
		{"[기다린다]", jump="complete3"},

	}
}

--Final Elixir:
newChat{ id="totally-complete2",
	text = [[마지막으로 잠시만 기다려주게, 친절한 모험가여. 두 가지 답례를 가져다줄테니 말일세! 하하, 드디어 끝이 나는구나!]],
	answers = {
		{"[기다린다]", jump="totally-complete3"},

	}
}

--Not final elixir:
newChat{ id="complete3",
	text = [[#LIGHT_GREEN#*잠시 기다리자, 연금술사가 작은 유리 약병을 들고 돌아왔습니다. 연금술사가 당신에게 약병을 건네줍니다.*#WHITE#
보상일세. 마음껏 즐기게나.]],
	answers = {
		{"감사합니다. 그럼 이만.",
			cond = function(npc, player) return q and q:isCompleted(e[1].almost) and not q:isCompleted(e[1].full) end,
			action = function(npc, player)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, e[1].full)
				q:reward(player, e[1].id)
				q:update_needed_ingredients(player)
			end
		},
		{"감사합니다. 그럼 이만.",
			cond = function(npc, player) return q and q:isCompleted(e[2].almost) and not q:isCompleted(e[2].full) end,
			action = function(npc, player)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, e[2].full)
				q:reward(player, e[2].id)
				q:update_needed_ingredients(player)
			end
		},
		{"감사합니다. 그럼 이만.",
			cond = function(npc, player) return q and q:isCompleted(e[3].almost) and not q:isCompleted(e[3].full) end,
			action = function(npc, player)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, e[3].full)
				q:reward(player, e[3].id)
				q:update_needed_ingredients(player)
			end
		},
	}
}

--Final elixir:
newChat{ id="totally-complete3",
	text = [[#LIGHT_GREEN#*잠시 기다리자, 연금술사가 작은 유리 약병과 초록색 보석을 들고 돌아왔습니다.*#WHITE#
노력의 결실을 즐기게나, 모험가여. 내 이렇게 될 줄 알았다네. 이 감사를 담아, 내 첫째 아이의 이름을... 어, 자네 이름이 어떻게 되더라? 하하, 농담일세. 너무 기분이 좋아서 별 헛소리가 다 나오는군. 잘 지내게나.]],
	answers = {
		{"감사합니다. 그럼 이만.",
			cond = function(npc, player) return q and q:isCompleted(e[1].almost) and not q:isCompleted(e[1].full) end,
			action = function(npc, player)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, e[1].full)
				q:reward(player, e[1].id)
				q:reward(player, final_reward)
				q:update_needed_ingredients(player)
				q:winner_is(player, alchemist_num)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.DONE)

			end
		},
		{"감사합니다. 그럼 이만.",
			cond = function(npc, player) return q and q:isCompleted(e[2].almost) and not q:isCompleted(e[2].full) end,
			action = function(npc, player)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, e[2].full)
				q:reward(player, e[2].id)
				q:reward(player, final_reward)
				q:update_needed_ingredients(player)
				q:winner_is(player, alchemist_num)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.DONE)
			end
		},
		{"감사합니다. 그럼 이만.",
			cond = function(npc, player) return q and q:isCompleted(e[3].almost) and not q:isCompleted(e[3].full) end,
			action = function(npc, player)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, e[3].full)
				q:reward(player, e[3].id)
				q:reward(player, final_reward)
				q:update_needed_ingredients(player)
				q:winner_is(player, alchemist_num)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.DONE)
			end
		},
	}
}

newChat{ id="choice",
	text = [[아주 좋지. 어떤 엘릭서의 제조를 도와주고 싶은가?]],
	answers = {
		{""..e[1].kr_name.."", jump="list",
			cond = function(npc, player) return not q:isCompleted(e[1].full) end,
			action = function(npc, player)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, e[1].start)
				q:update_needed_ingredients(player)
			end,
			on_select=function(npc, player)
				local o = art_list[e[1].id]
				o:identify(true)
				game.tooltip_x, game.tooltip_y = 1, 1
				game:tooltipDisplayAtMap(game.w, game.h, tostring(o:getDesc()))
			end,
		},
		{""..e[2].kr_name.."", jump="list",
			cond = function(npc, player) return not q:isCompleted(e[2].full) end,
			action = function(npc, player)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, e[2].start)
				q:update_needed_ingredients(player)
			end,
			on_select=function(npc, player)
				local o = art_list[e[2].id]
				o:identify(true)
				game.tooltip_x, game.tooltip_y = 1, 1
				game:tooltipDisplayAtMap(game.w, game.h, tostring(o:getDesc()))
			end,
		},
		{""..e[3].kr_name.."", jump="list",
			cond = function(npc, player) return not q:isCompleted(e[3].full) end,
			action = function(npc, player)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, e[3].start)
				q:update_needed_ingredients(player)
			end,
			on_select=function(npc, player)
				local o = art_list[e[3].id]
				o:identify(true)
				game.tooltip_x, game.tooltip_y = 1, 1
				game:tooltipDisplayAtMap(game.w, game.h, tostring(o:getDesc()))
			end,
		},
		{"[떠난다]"},
	}
}

newChat{ id="list",
	text = [[내가 필요한 재료들의 목록이라네. 재료를 찾다가 죽어버리지는 말게나. 올해의 기회를 놓치느니 차라리 내가 죽고 말테니까.]],
	answers = {
		{"그럼 이만."},
	}
}

-- If the elixir got made while you were out:
newChat{ id="poached",
	text = [[미안하게 됐군. 자네의 도움 없이 이미 엘릭서를 만들었다네. 자네에게 줄 보상은 없다네. 나 역시 자네에게 보상을 줄 이유가 없어졌고.]],
	answers = {
		{"흐으음...",
			cond = function(npc, player) return empty_handed(npc, player, 1) end,
			action = function(npc, player)
				q:remove_ingredients(player, e[1].short_name, 1)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, e[1].almost)
				q:update_needed_ingredients(player)
			end,
		},
		{"흐으음...",
			cond = function(npc, player) return empty_handed(npc, player, 2) end,
			action = function(npc, player)
				q:remove_ingredients(player, e[2].short_name, 2)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, e[2].almost)
				q:update_needed_ingredients(player)
			end,
		},
		{"흐으음...",
			cond = function(npc, player) return empty_handed(npc, player, 3) end,
			action = function(npc, player)
				q:remove_ingredients(player, e[3].short_name, 3)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, e[3].almost)
				q:update_needed_ingredients(player)
			end,
		},
	}
}

end

return "welcome"
