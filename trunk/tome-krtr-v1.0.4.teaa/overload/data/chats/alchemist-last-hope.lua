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
local alchemist_num = 4
local other_alchemist_nums = {1, 2, 3}
local q = game.player:hasQuest("brotherhood-of-alchemists")
local final_reward = "TAINT_TELEPATHY"
local e = {
	{
	short_name = "brawn",
	name = "elixir of brawn",
	kr_name = "완력의 엘릭서",
	id = "ELIXIR_BRAWN",
	start = "brawn_start",
	almost = "brawn_almost_done",
	full = "elixir_of_brawn",
	full_2 = "elixir_of_stoneskin",
	full_3 = "elixir_of_foundations",
	poached = "brawn_poached",
	},
	{
	short_name = "stoneskin",
	name = "elixir of stoneskin",
	kr_name = "단단한 피부의 엘릭서",
	id = "ELIXIR_STONESKIN",
	start = "stoneskin_start",
	almost = "stoneskin_almost_done",
	full = "elixir_of_stoneskin",
	full_2 = "elixir_of_brawn",
	full_3 = "elixir_of_foundations",
	poached = "stoneskin_poached",
	},
	{
	short_name = "foundations",
	name = "elixir of foundations",
	kr_name = "기반의 엘릭서",
	id = "ELIXIR_FOUNDATIONS",
	start = "foundations_start",
	almost = "foundations_almost_done",
	full = "elixir_of_foundations",
	full_2 = "elixir_of_brawn",
	full_3 = "elixir_of_stoneskin",
	poached = "foundations_poached",
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
		return ([[이런 제길. 너무 늦었다네. %s 놈이 벌써 끝을 냈다는군. 그래도 자네가 최선을 다해줬으니, 내 마지막 작품도 만들어주도록 하지.]]):format(other_alch)
	else
		return ([[수고했다네! 그리고 아직도 멀쩡해보이는군 그래. 아주 좋아보여. 특별히 까다로운 혼합물을 안전하게 만들고나면 나도 그런 기분을 느낀다네. 오, 그리고 자네가 잠깐 나가있는 동안, 작은 새가 와서 말해주길 %s 녀석이 %s 만들었다고 하더군. 그가 나보다 먼저 일을 끝내지 않게 해주게나!]]):format(other_alch, other_elixir:addJosa("를"))
	end
end

if not q or (q and not q:isCompleted(e[1].start) and not q:isCompleted(e[2].start) and not q:isCompleted(e[3].start)) then

-- Here's the dialog that pops up if the player has never worked for this alchemist before:
newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*얼룩 투성이의 낡은 갑옷을 입은 드워프가 문을 열었습니다.*#WHITE#
이봐 자네, 혹시 뭔가를 해체하고 보수를 받는 일에 관심 있는가?]],
	answers = {
		{"물론이죠.", jump="ominous"},
		{"[떠난다]"},
	}
}

newChat{ id="ominous",
	text = [[시체의 신이시여, 내가 이래서 모험가를 좋아한다니깐. 나도 한때는 모험가가 될 뻔 했었지. 그 놈이 날 갑자기 때릴 때마다 말이야. 여기서 "그 놈"은 물론 "내 마누라"를 말하는거야. 하핫!]],
	answers = {
		{"무슨 일을 시킬건가요?", jump="proposal"},
	}
}

newChat{ id="proposal",
	text = [[자네가 잘라올 괴물들의 신체 조각들을 적어서 줄 계획이네. 그러면 자네는 가서 조각들을 잘라오면 되는거고, 그러면 나는 그 괴물들의 조각을 증류해서 엄청나게 뛰어난 술을 만드는거지. 그러면 나는 연금술사 형제단에 들어갈 수 있는거고.]],
	answers = {
		{"꽤 계획적으로 들리는군요.", jump="help"},
	}
}

newChat{ id="help",
	text = [[나는 최고의 계획을 만들어내지. 그리고 술도 마찬가지고. 아마 형제단도 내가 만든 술을 거기서는 '엘릭서' 라고 부르는 데에 이의를 제기하지 못할걸세. 뭐, 그들에게는 그들이 원하는 방법이라는게 있으니 '엘릭서' 라고 불러주는게 맞겠지. 그런데, 우리 지금 무슨 얘기 하고있었더라?]],
	answers = {
		{"당신이 형제단에 들어가는 것을 도와주겠다고 하는 얘기까지요. 제가 얻을 보상은 뭐죠?", jump="competition"},
	}
}

newChat{ id="competition",
	text = [[아, 간단하네. 자네에게도 술 한 병씩을 주겠네. 한 병만 마셔도 자네의 머리카락이 가슴팍까지 자라고, 아마 눈꺼풀과 손톱도 그만큼 자라게 될걸세. 그리고 내가 형제단에 들어가는 데 결정적인 도움을 준다면, 특별한 보상을 주도록 하지. 아마 이 마즈'에이알 대륙에서 마지막으로 남았을, 투시의 감염체를 말일세.]],
	answers = {
		{"좋아요.", jump="choice", action = function(npc, player) player:grantQuest("brotherhood-of-alchemists") end,},
		{"지금은 도와드릴 수 없을 것 같군요."},
	}
}

newChat{ id="choice",
	text = [[그리고 마지막으로, 나와 같이 형제단의 자리를 노리는 녀석들이 몇 명 있다네. 우리가 일하는 동안 그 녀석들도 마냥 쉬고만 있지는 않을테니, 되도록이면 빨리 일을 끝마쳐주게. 자, 그럼 첫 번째로 도와주고 싶은 것을 선택해보게나. 완력의 술인가, 단단한 피부의 술인가, 기반의 술인가? 아니, '엘릭서' 였지... 미리 습관을 들여놓는 편이 좋을 것 같군 그래.]],
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

if npc.errand_given then
newChat{ id="list",
	text = [[좋아, 여기 목록이라네. 오, 그리고 한 가지 더. 이미 몇몇 사람들에게도 방금과 같은 일을 맡겨놓은 상태라네. 나는 편파적인 사람이 아니기 때문에, 그들 중 한 명이 자네보다 먼저 나에게 재료들을 가져다주면 자네는 불운한 사람이 되고 말걸세. 가급적 빨리 돌아오시게나.]],
	answers = {
		{"그럼 이만."},
	}
}
else
newChat{ id="list",
	text = [[좋아, 여기 목록이라네. 오, 그리고 한 가지 더. 이미 몇몇 사람들에게도 방금과 같은 일을 맡겨놓은 상태라네. 나는 편파적인 사람이 아니기 때문에, 그들 중 한 명이 자네보다 먼저 나에게 재료들을 가져다주면 자네는 불운한 사람이 되고 말걸세. 가급적 빨리 돌아오시게나.

오, 그리고 마지막으로... 혹시 다른 일도 좀 해줄 수 있겠나? 비록 내가 줄 수 있는 보상은 없지만 말일세.]],
	answers = {
		{"음, 할 수 있다면 해보죠.", jump="errand", action=function(npc, player) npc.errand_given = true end},
		{"저는 이득을 위해서 왔지, 심부름 하려고 온 건 아닙니다. 목록은 받았고, 받은 일을 할 뿐입니다. 부업은 다른 곳에 치워놓으시죠.", action=function(npc, player) npc.errand_given = true end},
	}
}
end

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
	text = [[#LIGHT_GREEN#*갑옷 입은 드워프가 문을 열었습니다.*#WHITE#
아하, 저번에 봤던 그 친절한 모험가로군.]],
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
	text = [[#LIGHT_GREEN#*그가 당신의 어깨를 유쾌하게 내려칩니다.*#WHITE#
하하하! 이걸로 마지막이로군! 스티르와 마루스와 그 빌어먹을 은둔자 놈은 내 턱수염이나 빨라고 하게! 그리고 내 마누라도 말이지! #{bold}#그래, 당신한테도 내 말 들리는거 알고 있어!#{normal}# 잘 했네, 친구여. 이제 같이 술이나 한 잔 하지.]],
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
	text = [[한 시간 정도, 연금술을 사용할 시간을 주게. 다른데 가지 말게나.]],
	answers = {
		{"[기다린다]", jump="complete3"},

	}
}

--Final Elixir:
newChat{ id="totally-complete2",
	text = [[자네가 기다리는 동안 집 안에 초대라도 해주고 싶지만, '그녀' 가 안에 있어서 말이지. 내가 자네를 좋아하는 것 알지?]],
	answers = {
		{"[기다린다]", jump="totally-complete3"},

	}
}

--Not final elixir:
newChat{ id="complete3",
	text = [[#LIGHT_GREEN#*잠시 기다리자, 드워프가 약병을 들고 돌아왔습니다.*#WHITE#
악마 울흐'록의 오줌 맛이 나지만, 어쨌든 일은 끝났다네. 여기 받게나.]],
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
	text = [[#LIGHT_GREEN#*잠시 기다리자, 드워프가 약병과 작은 주머니를 들고 돌아왔습니다.*#WHITE#
안에 좋은 것을 넣어뒀다네. 내일 아침에 소원을 들어주는 그런건 아니지만 말일세. '투시의 감염체'를 다룰 때는 조심하게나. 특히 문을 두드렸는데 마누라가 대답할 때는 말이지. 하핫!]],
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
	text = [[자네의 여행길에 축복 있기를. 무엇을 도와줄텐가?]],
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

if npc.errand_given then
newChat{ id="list",
	text = [[여기 필요한 신체 조각들의 목록이라네. 살육에 행운이 깃들기를!]],
	answers = {
		{"그럼 이만."},
	}
}
else
newChat{ id="list",
	text = [[여기 필요한 신체 조각들의 목록이라네. 살육에 행운이 깃들기를!

오, 그리고 마지막으로... 혹시 다른 일도 좀 해줄 수 있겠나? 비록 내가 줄 수 있는 보상은 없지만 말일세.]],
	answers = {
		{"음, 할 수 있다면 해보죠.", jump="errand", action=function(npc, player) npc.errand_given = true end},
		{"저는 이득을 위해서 왔지, 심부름 하려고 온 건 아닙니다. 목록은 받았고, 받은 일을 할 뿐입니다. 부업은 다른 곳에 치워놓으시죠.", action=function(npc, player) npc.errand_given = true end},
	}
}
end

-- If the elixir got made while you were out:
newChat{ id="poached",
	text = [[으음... 자네가 없는 사이에 누군가 와서, 나에게 재료들을 가져다주었다네. 자네에게 줄 보수는 없다는 말이지. 미안하게 됐네. 하지만 이렇게 시간이 중요할 때에는, '선착순' 만이 진리라는 것 정도는 잘 알고 있지 않은가.]],
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

newChat{ id="errand",
	text = [[음, 이런 일이라네. 내 아내의 친구들 중 한 명이 최근 실종돼서 보이지 않고 있다네. 젊은 견습 연금술사였던, '셀리아' 라는 친구지. 사실 그녀의 남편이 최근 죽었고, 그 비탄으로 인해 그녀는 반쯤 미쳐버렸다네. 그녀는 매일 남편의 묘비에서 살다시피 했지. 그녀가 보이지 않게 된 바로 전날까지 말일세. 아마 그녀는 남편 없이는 살아갈 수 없는 몸이였던 것 같네. 그 둘은 마치 한몸같은 사이였거든. 여행 중에 기회가 닿는다면, 동쪽에 있는 공동묘지에 가서 확인을 해주게나... 이정도면 이해했을거라 믿네.

죽음이라는게 사람들에게 미치는 영향이란 참으로 기묘한 것일세. 어떻게 그들의 마음을 앗아가고, 심지어는 그들이 살아갈 의지마저 잊게 만드는지... 혹시 그녀가 죽어있더라도, 부디 경의를 담아 다뤄주게. 부탁일세.]],
	answers = {
		{"할 수 있는 것까지는 해보도록 하죠.", action=function(npc, player)
			game:onLevelLoad("wilderness-1", function(zone, level)
				local g = game.zone:makeEntityByName(level, "terrain", "LAST_HOPE_GRAVEYARD")
				local spot = level:pickSpot{type="zone-pop", subtype="last-hope-graveyard"}
				game.zone:addEntity(level, g, "terrain", spot.x, spot.y)
				game.nicer_tiles:updateAround(game.level, spot.x, spot.y)
				game.state:locationRevealAround(spot.x, spot.y)
			end)
			game.log("그는 당신의 지도에 공동묘지의 위치를 표시해줬습니다.")
			player:grantQuest("grave-necromancer")
		end},
	}
}

return "welcome"
