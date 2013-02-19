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

local art_list = mod.class.Object:loadList("/data/general/objects/brotherhood-artifacts.lua")
local alchemist_num = 3
local other_alchemist_nums = {1, 2, 4}
local q = game.player:hasQuest("brotherhood-of-alchemists")
local final_reward = "INFUSION_WILD_GROWTH"
local e = {
	{
	short_name = "force",
	name = "elixir of explosive force",
	kr_display_name = "폭발력의 엘릭서",
	cap_name = "ELIXIR OF EXPLOSIVE FORCE",
	id = "ELIXIR_FORCE",
	start = "force_start",
	almost = "force_almost_done",
	full = "elixir_of_explosive_force",
	full_2 = "elixir_of_serendipity",
	full_3 = "elixir_of_focus",
	poached = "force_poached",
	},
	{
	short_name = "serendipity",
	name = "elixir of serendipity",
	kr_display_name = "행운의 엘릭서",
	cap_name = "ELIXIR OF SERENDIPITY",
	id = "ELIXIR_SERENDIPITY",
	start = "serendipity_start",
	almost = "serendipity_almost_done",
	full = "elixir_of_serendipity",
	full_2 = "elixir_of_explosive_force",
	full_3 = "elixir_of_focus",
	poached = "serendipity_poached",
	},
	{
	short_name = "focus",
	name = "elixir of focus",
	kr_display_name = "집중의 엘릭서",
	cap_name = "ELIXIR OF FOCUS",
	id = "ELIXIR_FOCUS",
	start = "focus_start",
	almost = "focus_almost_done",
	full = "elixir_of_focus",
	full_2 = "elixir_of_explosive_force",
	full_3 = "elixir_of_serendipity",
	poached = "focus_poached",
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
		return ([[#{bold}#이 릿치 자식! 어떤 머저리가 엘릭서를 완성해서 형제단에 들어갔다는 소식을 들은지 정확히 10 분 후에 모습을 드러내다니! 대체 이렇게 젠장맞게 늦게 온 이유가 뭐야? 미르베니아 여왕의 젖통같으니... 일단 재료를 가져왔으니 엘릭서는 만들어주겠어. 다만 이건 내가 약속을 어기면 죽는 저주에 걸렸기 때문이라는걸 알아둬. 그리고 혹시 엘릭서에서 오줌 맛이 나더라도, 네 상상일 뿐일테니 그리 아라고.#{normal}#]])
	else
		return ([[#LIGHT_GREEN#*하플링이 당신에게 쪽지를 건내줬습니다. 쪽지에는 '네가 빈둥거리는 동안, %s 녀석이 %s를 만들었다는군. 다음 번에는 더 서두르라고, 젠장.' 이라고 적혀있습니다.*#WHITE#
#{bold}#이 빌어먹을 귀는 아직도 들리지 않는군. 그나마 다행인건, 내가 볼때 너는 그다지 흥미로운 대화 상대가 아닐 것 같다는 거야.#{normal}#]]):format(other_alch, other_elixir)
	end
end

if not q or (q and not q:isCompleted(e[1].start) and not q:isCompleted(e[2].start) and not q:isCompleted(e[3].start)) then

-- Here's the dialog that pops up if the player has never worked for this alchemist before:
newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*수없이 많은 노크 끝에, 검게 타서 연기가 나는 로브를 걸친 하플링이 문을 열었습니다. 그는 짜증이 난 상태인 것 같습니다.*#WHITE#
#{bold}#아침 내내 만든 물약이 폭발해서 나를 날려버렸으면 됐지, 이제는 왠 멍청이가 내 빌어먹을 앞문을 공성 망치로 두들기는 것 마냥 두들겨? 그래, 네가 두들기는 소리 다 들었다. 이 피흘리고 뇌진탕까지 일어나서 거의 아무 것도 들리지 않는 귀로도 들릴 만큼 말이지. 대체 뭘 원하는데?#{normal}#]],
	answers = {
		{"어... 제가 도와드릴 일이 있나요?", jump="ominous"},
		{"[떠난다]"},
	}
}

newChat{ id="ominous",
	text = [[#{bold}#이봐, 더 크게 말할 수는 없나? 방금 전 그 빌어먹을 '불-이-야' 물약 때문에 고막이 터져버린 것 같다고. 벌써 까먹었나? 그 3 번 연속으로 저주받을 물약은 아주 그냥 완벽했지. 이런 토크놀 왕의 거시기같으니!#{normal}#]],
	answers = {
		{"#{bold}#말했지만, 제가 도와드릴 일이 있냐구요!#{normal}#", jump="proposal"},
	}
}

newChat{ id="proposal",
	text = [[#{bold}#아직도 안들리는군. 내 얘기나 좀 들어봐. 연금술사 형제단이 설립된 이래 처음으로 신규 단원을 받고 있어. 이를 위해서는 다른 것보다도, 세 가지 아주 특별하고 복잡한 엘릭서가 필요하지. 물론 나는 그런 썩은 대가리들이 모인 집단에는 들어가고 싶지 않아. 하지만 참으로 우연스럽게도, 연금술사 형제단 놈들은 원래대로라면 젠장맞을 불치병인 것들도 치료할 수 있는 비밀의 연금술을 알고 있다고 하더군. 이건 그래도 제법 관심이 가는 이야기였지.#{normal}#]],
	answers = {
		{"#{bold}#그래서, 제가 도울 일이라도...#{normal}#", jump="help"},
	}
}

newChat{ id="help",
	text = [[#{bold}#형제단 역시 연금술의 발전이 현존하는 문명사회에서 갖는 의미를 젠장맞게도 잘 알고 있고는 있겠지. 하지만 그놈들은 몇몇 가치 있는 비밀들을 마치 지렁이마냥 자기들끼리만 파먹고 있어. 제길, 사실 나도 그 엿같은 치료법은 필요 없다고. 나는 형제단에서 그들이 숨기고 있는 비밀들을 모조리 훔쳐서, 베껴서, 수백 개의 사본을 만들어서, 마즈'에이알에 있는 모든 도시의 나무에다가 하나씩 걸어둘거야.#{normal}#]],
	answers = {
		{"#{bold}#'은둔자' 가 주로 취하는 태도는 아니군요.#{normal}#", jump="competition"},
	}
}

newChat{ id="competition",
	text = [[#{bold}#그렇게 되면 그들은 어떤 행동을 취할까? 그들의 귀중한 비밀들이 공공의 것으로 변한다면 말이야. 그런 치료법은 사실 존재하지 않는다는 비밀이건, 아니면 저 날아다니는 오리 엘릭서의 제조법 같은 비밀이건 말이야.  저 똥싸개들의 형제단은 세상의 멸시와 자기들의 눈물로 만든 엘릭서밖에 만들지 못하게 되겠지. 이제 좀 더 크게 말해보라고. 할거야, 안할거야?#{normal}#]],
	answers = {
		{"#{bold}#물론, 합니다.#{normal}#", jump="choice", action = function(npc, player) player:grantQuest("brotherhood-of-alchemists") end,},
		{"#{bold}#지금은 도와줄 수 없을 것 같군요.#{normal}#"},
	}
}

newChat{ id="choice",
	text = [[#LIGHT_GREEN#*그는 당신에게 엘릭서의 이름과 효능이 적힌 작은 종이를 건네주었습니다.*#WHITE#
#{bold}#이 엿같은 것들을 만들기 위한 재료 목록은 일종의 거래 비밀이야. 그래서 한번에 하나씩만 말해줄거고, 네가 일을 잘 해내는지 보겠어. 오, 물론 엘릭서를 만들 때 네것도 하나 만들어줄 수 있으니 걱정은 말고. 무슨 엘릭서를 원해? 이 빌어먹을 목록에 손가락으로 표시만 해. 아직 네가 말한 것들을 하나도 듣지 못했으니 말이야. 네놈이 내게 뭔가를 팔러 온 잡상인이 아니기만을 빌지.#{normal}#]],
	answers = {
		{"["..e[1].kr_display_name.."를 가리킨다]", jump="list",
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
		{"["..e[2].kr_display_name.."를 가리킨다]", jump="list",
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
		{"["..e[3].kr_display_name.."를 가리킨다]", jump="list",
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
	text = [[#{bold}#내가 필요한 재료들의 목록이다. 분명 재료들의 주인은 너를 죽이려 들테니, 네가 무능력하게 당하지 않았으면 좋겠군. 무능력자는 충분히 겪어봤으니 더 이상은 필요 없어. 부디 네가 그것들보다 빠르고 똑똑하길 빈다.#{normal}#]],
	answers = {
		{"#{bold}#그럼 이만.#{normal}#"},
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
	text = [[#LIGHT_GREEN#*아직도 몸에서 연기가 나는 하플링이 문을 엽니다.*#WHITE#
#{bold}#여기 틀어박혀 사는 것도 다 이유가 있어서 그렇다고, 이 개... 오, 자네였군.#{normal}#]],
	answers = {
		-- If not the final elixir:
		{"#{bold}#"..e[1].cap_name.."에 필요한 재료를 모두 가져왔습니다.#{normal}#", jump="complete",
			cond = function(npc, player) return turn_in(npc, player, 1) end,
			action = function(npc, player)
				q:on_turnin(player, alch_picked, e_picked, false)
			end,
		},
		{"#{bold}#"..e[2].cap_name.."에 필요한 재료를 모두 가져왔습니다.#{normal}#", jump="complete",
			cond = function(npc, player) return turn_in(npc, player, 2) end,
			action = function(npc, player)
				q:on_turnin(player, alch_picked, e_picked, false)
			end,
		},
		{"#{bold}#"..e[3].cap_name.."에 필요한 재료를 모두 가져왔습니다.#{normal}#", jump="complete",
			cond = function(npc, player) return turn_in(npc, player, 3) end,
			action = function(npc, player)
				q:on_turnin(player, alch_picked, e_picked, false)
			end,
		},

		-- If the final elixir:
		{"#{bold}#"..e[1].cap_name.."에 필요한 재료를 모두 가져왔습니다.#{normal}#", jump="totally-complete",
			cond = function(npc, player) return turn_in_final(npc, player, 1) end,
		},
		{"#{bold}#"..e[2].cap_name.."에 필요한 재료를 모두 가져왔습니다.#{normal}#", jump="totally-complete",
			cond = function(npc, player) return turn_in_final(npc, player, 2) end,
		},
		{"#{bold}#"..e[3].cap_name.."에 필요한 재료를 모두 가져왔습니다.#{normal}#", jump="totally-complete",
			cond = function(npc, player) return turn_in_final(npc, player, 3) end,
		},

		-- If the elixir got made while you were out:
		{"#{bold}#"..e[1].cap_name.."에 필요한 재료를 모두 가져왔습니다.#{normal}#", jump="poached",
			cond = function(npc, player) return turn_in_poached(npc, player, 1) end,
		},
		{"#{bold}#"..e[2].cap_name.."에 필요한 재료를 모두 가져왔습니다.#{normal}#", jump="poached",
			cond = function(npc, player) return turn_in_poached(npc, player, 2) end,
		},
		{"#{bold}#"..e[3].cap_name.."에 필요한 재료를 모두 가져왔습니다.#{normal}#", jump="poached",
			cond = function(npc, player) return turn_in_poached(npc, player, 3) end,
		},

		--Don't let player work on multiple elixirs for the same alchemist.
		--See comments in more_aid function above for all the gory detail
		{"#{bold}#당신을 조금 더 도와드리기 위해 왔습니다.#{normal}#", jump="choice",
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
	text = [[#LIGHT_GREEN#*처음으로, 진정한 기쁨이 그의 검댕 묻은 얼굴에서 드러났습니다.*#WHITE#
#{bold}#잘 해냈다, 누군지는 모르겠지만 말야. 마즈'에이알의 모두가 너에게 빚을 지게 되었군. 네 몸을 갈기갈기 찢어버리고 싶을 연금술사 형제단의 인원들을 빼고 말이지. 자네에게는 다행스럽게도, 그들은 대부분 무해한 놈들이라네.#{normal}#]],
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
	text = [[#{bold}#잠깐, 여기서 기다리게. 이 건물 안으로 들어왔다가는 잘 갈린 모험가 개밥이 될 수도 있을테니까. 내 로브와 정신나간 연금술적 보호대책이 없었다면, 나도 한순간에 증발해버렸을 거라고.#{normal}#]],
	answers = {
		{"[기다린다]", jump="complete3"},

	}
}

--Final Elixir:
newChat{ id="totally-complete2",
	text = [[#{bold}#잠깐 시간을 주게. 기다리는 동안 저 형제단에 관련된 불쾌한 생각들이나 떠올리고 있으라고. 그리고 혹시 폭발음이라도 들리면, 와서 나를 구해주고. 이 건물이 독성 구름과 불덩어리로 지옥이 됐다고 해도 말이야.#{normal}#]],
	answers = {
		{"[기다린다]", jump="totally-complete3"},

	}
}

--Not final elixir:
newChat{ id="complete3",
	text = [[#LIGHT_GREEN#*다행히도, 재앙은 일어나지 않았습니다. 잠시 기다리자, 하플링이 그을음이 묻은 유리 약병을 들고 와 건네줍니다.*#WHITE#
#{bold}#한 잔 들게. 비슷한 일에 관심이 있으면 언제든 다시 오고. 다만 나는 아직 원하는 것을 얻지 못했고, 네가 오래 기다릴수록 연기나는 구멍과 한 명의 격분한 하플링을 볼 수 있을거라는 것만 알아두게나.#{normal}#]],
	answers = {
		{"#{bold}#감사합니다. 그럼 이만.#{normal}#",
			cond = function(npc, player) return q and q:isCompleted(e[1].almost) and not q:isCompleted(e[1].full) end,
			action = function(npc, player)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, e[1].full)
				q:reward(player, e[1].id)
				q:update_needed_ingredients(player)
			end
		},
		{"#{bold}#감사합니다. 그럼 이만.#{normal}#",
			cond = function(npc, player) return q and q:isCompleted(e[2].almost) and not q:isCompleted(e[2].full) end,
			action = function(npc, player)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, e[2].full)
				q:reward(player, e[2].id)
				q:update_needed_ingredients(player)
			end
		},
		{"#{bold}#감사합니다. 그럼 이만.#{normal}#",
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
	text = [[#LIGHT_GREEN#*잠시 기다리자, 하플링이 유리 약병과 작은 주머니를 들고 돌아왔습니다.*#WHITE#
#{bold}#네가 고른 엘릭서에, 덤으로 하나 더 붙여주지. 이 주입물은 뭣같이 구하기 힘든 거니까, 낭비하지 말라고.#{normal}#]],
	answers = {
		{"#{bold}#감사합니다. 그럼 이만.#{normal}#",
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
		{"#{bold}#감사합니다. 그럼 이만.#{normal}#",
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
		{"#{bold}#감사합니다. 그럼 이만.#{normal}#",
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
	text = [[#{bold}#무슨 엘릭서를 도와줄건지 골라보게. 엘릭서 때문에 온거 맞지? 설마 최음제 따위를 구하려고 온 바보 천치는 아닐거라고 믿네.#{normal}#]],
	answers = {
		{"["..e[1].kr_display_name.."를 가리킨다]", jump="list",
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
		{"["..e[2].kr_display_name.."를 가리킨다]", jump="list",
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
		{"["..e[3].kr_display_name.."를 가리킨다]", jump="list",
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
	text = [[#{bold}#여기 필요한 재료 목록이네. 알았으면 빨리 가서 구해오라고.#{normal}#]],
	answers = {
		{"#{bold}#그럼 이만.#{normal}#"},
	}
}

-- If the elixir got made while you were out:
newChat{ id="poached",
	text = [[#{bold}#너무 늦어, 멍청아. 엘릭서는 이미 만들었어. 그리고 누군가가 와서 보상을 챙겨갔지. 너 자신이 부끄럽다면, 오늘 아침에 네 몸이 폭발해서 해부학 재료로 쓰일 적당한 시체가 되는 것이 더 좋을지 안좋을지 생각해보게. 알았지? 잘가게나.#{normal}#]],
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
