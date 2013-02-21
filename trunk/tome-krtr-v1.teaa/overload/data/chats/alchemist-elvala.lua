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

local art_list = mod.class.Object:loadList("/data/general/objects/brotherhood-artifacts.lua")
local alchemist_num = 2
local other_alchemist_nums = {1, 3, 4}
local q = game.player:hasQuest("brotherhood-of-alchemists")
local final_reward = "ELIXIR_INVULNERABILITY"
local e = {
	{
	short_name = "mysticism",
	name = "elixir of mysticism",
	kr_display_name = "신비주의의 엘릭서",
	id = "ELIXIR_MYSTICISM",
	start = "mysticism_start",
	almost = "mysticism_almost_done",
	full = "elixir_of_mysticism",
	full_2 = "elixir_of_the_savior",
	full_3 = "elixir_of_mastery",
	poached = "mysticism_poached",
	},
	{
	short_name = "savior",
	name = "elixir of the savior",
	kr_display_name = "구원자의 엘릭서",
	id = "ELIXIR_SAVIOR",
	start = "savior_start",
	almost = "savior_almost_done",
	full = "elixir_of_the_savior",
	full_2 = "elixir_of_mysticism",
	full_3 = "elixir_of_mastery",
	poached = "savior_poached",
	},
	{
	short_name = "mastery",
	name = "elixir of mastery",
	kr_display_name = "숙련의 엘릭서",
	id = "ELIXIR_MASTERY",
	start = "mastery_start",
	almost = "mastery_almost_done",
	full = "elixir_of_mastery",
	full_2 = "elixir_of_mysticism",
	full_3 = "elixir_of_the_savior",
	poached = "mastery_poached",
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
		return ([[너무 늦었어! 아아, 너무 늦었어. %s 놈이 벌써 입단 심사를 끝냈다. 그래도 약속했던 엘릭서는 만들어주도록 하지. 형제단 놈들은 단원이 아닌 연금술사가 사람을 속이면, 그 연금술사의 손가락을 부러뜨리거든. 반면에 단원끼리는...]]):format(other_alch)
	else
		return ([[그거나 빨리 내놔. 네가 충분히 시간을 끌어준 덕분에, %s 놈이 %s 벌써 만들었다고 한다. 다음에는 조금 더 서두르는 편이 좋을거야. 아니면 네게 줄 엘릭서를 만들다가 '실수' 를 할지도 모르니까 말야.]]):format(other_alch, other_elixir:addJosa("를"))
	end
end

if not q or (q and not q:isCompleted(e[1].start) and not q:isCompleted(e[2].start) and not q:isCompleted(e[3].start)) then

-- Here's the dialog that pops up if the player has never worked for this alchemist before:
newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*누더기 옷을 입은 엘프가 문을 열더니, 어리둥절한 표정을 지으며 자신의 머리를 긁습니다.*#WHITE#
또 다른 모험가? 아니, 우리 만난 적 있나? 밝은 색깔의 머리띠라도 두른 사람이 아니면 사람들을 구분할 수가 없어서 말이지. 나를 좀 도와주겠나?]],
	answers = {
		{"어쨌든, 저는 모험가입니다. 하고 싶은 말을 하시죠.", jump="ominous"},
		{"[떠난다]"},
	}
}

newChat{ id="ominous",
	text = [[나와 연금술사 형제단에 입단하는 것 사이에는 세 엘릭서가 있지. 그 전의 과정은 전부 내가 했고. 확신할 수는 없지만, 가능할 것 같군. 나에게 재료를 가져다줘.]],
	answers = {
		{"엘릭서? 재료? 대체 무슨 말을 하는거죠?", jump="proposal"},
	}
}

newChat{ id="proposal",
	text = [[다른 연금술사들이 가져가기 전에 내가 가져야할 것들 말야. 그 멍청이들이 형제단에 들어가는 것은 볼 수 없어.]],
	answers = {
		{"그 말로는 별로 설명이 안됩니다만...", jump="help"},
	}
}

newChat{ id="help",
	text = [[#LIGHT_GREEN#*그가 목소리를 높이고, 과장된 몸짓을 취하기 시작했습니다. 당신을 바보로 취급하는 것 같습니다.*#WHITE#
나는 좋은 음료수를 만들어. 그러려면 무서운 괴물들의 몸에서 잘라낸 조각들이 필요해. 너는 나한테 이 조각들을 가져다주면 돼. 그리고 너는 괴물들에게 잡아먹히겠지. 나는 너같은 멍청이들을 위해 또 이런 대화를 하고 있고 말이지.]],
	answers = {
		{"특정한 괴물을 죽이는 것 정도는 할 수 있습니다. 제게 돌아올 이득은 뭐가 있죠?", jump="competition"},
	}
}

newChat{ id="competition",
	text = [[드디어 이해했군! 나를 도와주면 내가 만든 엘릭서를 너에게도 하나 주도록 하지. 그리고 내가 연금술사 형제단에 최종적으로 들어가게 되면, 잠시 동안 무적이 되는 '불사신의 엘릭서'도 절반 주도록 하지. 다만 이 엘릭서를 먹고 허튼 짓 할 생각은 하지 말고. 나머지 절반은 나에게 있으니까.]],
	answers = {
		{"좋아요.", jump="choice", action = function(npc, player) player:grantQuest("brotherhood-of-alchemists") end,},
		{"지금은 도와줄 수 없을 것 같군요."},
	}
}

newChat{ id="choice",
	text = [[여기 내가 만들 세 엘릭서의 목록이다. 한번에 하나의 엘릭서 재료를 알려주도록 하지. 신비주의의 엘릭서, 구원자의 엘릭서, 숙련의 엘릭서 중에 관심가는 엘릭서를 선택하면 된다.]],
	answers = {
		{""..e[1].kr_display_name.."", jump="list",
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
		{""..e[2].kr_display_name.."", jump="list",
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
		{""..e[3].kr_display_name.."", jump="list",
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
	text = [[내가 필요한 괴물들의 신체 조각들이다. 다른 멍청이들을 수없이 많이 보내놨으니, 서두르는게 좋을걸? 적어도 그놈들은 머리라도 달려 있고, 나도 여기서 더 이상 제정신으로 있을 수는 없을 것 같으니 말야.]],
	answers = {
		{"그러시겠죠. 그럼 이만."},
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
	text = [[#LIGHT_GREEN#*누더기 옷을 입은 엘프가 문을 엽니다.*#WHITE#
너 나 알아?]],
	answers = {
		-- If not the final elixir:
		{""..e[1].kr_display_name.."에 필요한 재료를 모두 가져왔습니다.", jump="complete",
			cond = function(npc, player) return turn_in(npc, player, 1) end,
			action = function(npc, player)
				q:on_turnin(player, alch_picked, e_picked, false)
			end,
		},
		{""..e[2].kr_display_name.."에 필요한 재료를 모두 가져왔습니다.", jump="complete",
			cond = function(npc, player) return turn_in(npc, player, 2) end,
			action = function(npc, player)
				q:on_turnin(player, alch_picked, e_picked, false)
			end,
		},
		{""..e[3].kr_display_name.."에 필요한 재료를 모두 가져왔습니다.", jump="complete",
			cond = function(npc, player) return turn_in(npc, player, 3) end,
			action = function(npc, player)
				q:on_turnin(player, alch_picked, e_picked, false)
			end,
		},

		-- If the final elixir:
		{""..e[1].kr_display_name.."에 필요한 재료를 모두 가져왔습니다.", jump="totally-complete",
			cond = function(npc, player) return turn_in_final(npc, player, 1) end,
		},
		{""..e[2].kr_display_name.."에 필요한 재료를 모두 가져왔습니다.", jump="totally-complete",
			cond = function(npc, player) return turn_in_final(npc, player, 2) end,
		},
		{""..e[3].kr_display_name.."에 필요한 재료를 모두 가져왔습니다.", jump="totally-complete",
			cond = function(npc, player) return turn_in_final(npc, player, 3) end,
		},

		-- If the elixir got made while you were out:
		{""..e[1].kr_display_name.."에 필요한 재료를 모두 가져왔습니다.", jump="poached",
			cond = function(npc, player) return turn_in_poached(npc, player, 1) end,
		},
		{""..e[2].kr_display_name.."에 필요한 재료를 모두 가져왔습니다.", jump="poached",
			cond = function(npc, player) return turn_in_poached(npc, player, 2) end,
		},
		{""..e[3].kr_display_name.."에 필요한 재료를 모두 가져왔습니다.", jump="poached",
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
	text = [[#LIGHT_GREEN#*엘프가 자신의 흉터가 있는 손으로 박수를 칩니다.*#WHITE#
정말 잘 했다, 멍청아! 마지막 엘릭서가 기다린다! 오, 그래. 형제단도 들어갈 수 있겠군. 그리고 복수도 말이지. 오오오오오 좋아.]],
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
	text = [[내가 준비하는 동안, 여기서 참을성이나 좀 길러봐라. 한 시간 이내로 돌아올테니.]],
	answers = {
		{"[기다린다]", jump="complete3"},

	}
}

--Final Elixir:
newChat{ id="totally-complete2",
	text = [[완벽해. 여기서 기다려라.]],
	answers = {
		{"[기다린다]", jump="totally-complete3"},

	}
}

--Not final elixir:
newChat{ id="complete3",
	text = [[#LIGHT_GREEN#*잠시 기다리자, 엘프가 돌아와서 당신에게 작은 유리 약병을 던집니다.*#WHITE#
부작용으로 살짝 정신적 불균형이 생길거다.]],
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
	text = [[#LIGHT_GREEN#*잠시 기다리자, 연금술사가 두 약병을 들고 돌아왔습니다.*#WHITE#
네가 누군지는 모르겠지만, 나를 도와주는 사람에게는 보상으로 이걸 약속했다는 것만은 확실해. 뭐, 만약 다른 모험가가 너를 죽이고 이걸 가져간다면, 너는 나를 도와준 사람이 아니게 되는걸테고 말야.]],
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
	text = [[어떤 엘릭서에 관심이 가는데?]],
	answers = {
		{""..e[1].kr_display_name.."", jump="list",
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
		{""..e[2].kr_display_name.."", jump="list",
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
		{""..e[3].kr_display_name.."", jump="list",
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
	text = [[내가 필요한 재료들의 목록이다. 설명을 잘 읽어보고 구해와라. 아니면 결과로 나온 엘릭서가 예상보다 훨씬 더 치명적인 결과를 불러오게 될테니까.]],
	answers = {
		{"그럼 이만."},
	}
}

-- If the elixir got made while you were out:
newChat{ id="poached",
	text = [[이미 만든 엘릭서다. 다음에는 더 서두르는게 좋을거야, 모험가.]],
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
