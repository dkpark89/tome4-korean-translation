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

name = "The Brotherhood of Alchemists"
kr_display_name = "연금술사 형제단"

desc = function(self, player, who)
	local desc = {}

	if self:isStatus(self.DONE) and self.player_won == true then
		desc[#desc+1] = "#LIGHT_GREEN#당신의 도움 덕분에, 연금술사 형제단의 새로운 단원은 "..self.winner:addJosa("로").." 결정되었습니다.#WHITE#"
	elseif self:isStatus(self.DONE) and self.player_won == false then
		desc[#desc+1] = "#RED#당신은 마즈'에이알에 있는 여러 연금술사들을 도와주었지만, 연금술사 형제단에 입단시킬 결정적인 도움은 주지 못했습니다. 올해의 새로운 단원은 "..self.winner:addJosa("로").." 결정되었습니다.#WHITE#"
	else
		desc[#desc+1] = "#LIGHT_BLUE#마즈'에이알에 있는 여러 연금술사들은 연금술사 형제단에 들어가기 위해 서로 경쟁하고 있습니다. 그리고 한 명 이상의 연금술사가 당신의 도움을 받았습니다.#WHITE#"
	end
	--e (for elixir) is the name of the table listing all the elixirs and their various strings and ingredients and such. self.e[2][3], for example, refers to the table containing all the information for the second alchemist's third elixir. self.e[2][3].ingredients[1] refers to the first ingredient of the third elixir of the second alchemist. This saves a ton of work in making the desc function, since it's messy and it would suck to copy/paste twelve of them (one for each elixir).
	for i = 1, 4 do --run through list of four alchemists
		for j = 1, 3 do --run through each alchemist's list of three elixirs
			if self:isCompleted(self.e[i][j].full) and not self:isCompleted(self.e[i][j].poached) then
				desc[#desc+1] = "#GREEN#당신은 "..(self.e[i][j].kr_alchemist or self.e[i][j].alchemist).."의 작업을 도와, "..(self.e[i][j].kr_display_name or self.e[i][j].name):addJosa("를").." 만들었습니다.#WHITE#"
			elseif self:isCompleted(self.e[i][j].full) and self:isCompleted(self.e[i][j].poached) then
				desc[#desc+1] = "#RED#당신의 도움을 받지 않고, "..(self.e[i][j].kr_alchemist or self.e[i][j].alchemist):addJosa("는").." "..(self.e[i][j].kr_display_name or self.e[i][j].name):addJosa("를").." 만들었습니다.#WHITE#"
			elseif self:isCompleted(self.e[i][j].start) and not self:isCompleted(self.e[i][j].full) and self:isStatus(self.DONE) then
				desc[#desc+1] = "#SLATE#연금술사 형제단에 입단할 수 없게 됐기 때문에, "..(self.e[i][j].kr_alchemist or self.e[i][j].alchemist):addJosa("는").." 더 이상 당신에게 "..(self.e[i][j].kr_display_name or self.e[i][j].name):addJosa("를").." 만들어줄 이유가 없어졌습니다."
			elseif self:isCompleted(self.e[i][j].start) and not self:isCompleted(self.e[i][j].full) then
				desc[#desc+1] = ""..(self.e[i][j].kr_alchemist or self.e[i][j].alchemist):addJosa("는").." "..(self.e[i][j].kr_display_name or self.e[i][j].name):addJosa("를").." 만들기 위해 당신의 도움을 필요로 합니다. 그는 당신에게 필요한 재료들에 대한 정보를 주었습니다."
				if not self:check_i(player, self.e[i][j].ingredients[1]) then
					desc[#desc+1] = "#SLATE#  * '필요한 재료 : "..(self.e[i][j].ingredients[1].kr_display_name or self.e[i][j].ingredients[1].name).." 하나. "..game.party:getIngredient(self.e[i][j].ingredients[1].id).alchemy_text.."'#WHITE#"
				else
					desc[#desc+1] = "#LIGHT_GREEN#  * 당신은 "..(self.e[i][j].ingredients[1].kr_display_name or self.e[i][j].ingredients[1].name).." 하나를 찾았습니다.#WHITE#"
				end
				if not self:check_i(player, self.e[i][j].ingredients[2]) then
					desc[#desc+1] = "#SLATE#  * '필요한 재료 : "..(self.e[i][j].ingredients[2].kr_display_name or self.e[i][j].ingredients[2].name)e.." 하나. "..game.party:getIngredient(self.e[i][j].ingredients[2].id).alchemy_text.."'#WHITE#"
				else
					desc[#desc+1] = "#LIGHT_GREEN#  * 당신은 "..(self.e[i][j].ingredients[2].kr_display_name or self.e[i][j].ingredients[2].name).." 하나를 찾았습니다.#WHITE#"
				end
				if not self:check_i(player, self.e[i][j].ingredients[3]) then
					desc[#desc+1] = "#SLATE#  * 필요한 재료 : "..(self.e[i][j].ingredients[3].kr_display_name or self.e[i][j].ingredients[3].name).." 하나. "..game.party:getIngredient(self.e[i][j].ingredients[3].id).alchemy_text.."'#WHITE#"
				else
					desc[#desc+1] = "#LIGHT_GREEN#  * 당신은 "..(self.e[i][j].ingredients[3].kr_display_name or self.e[i][j].ingredients[3].name).." 하나를 찾았습니다.#WHITE#"
				end
			end
		end
	end
	return table.concat(desc, "\n")
end

on_grant = function(self, who)
	self.cookbook, self.elixirs, self.alchemists, self.e = self:recipes()
	self.recipes = nil
	self.needed_ingredients = {}
	self.player_loses = false
	game.log("#VIOLET#Esc 키를 누른 뒤, '연금술 재료 보기' 를 선택하면 현재 가지고 있는 연금술 재료를 확인할 수 있습니다.")
end

-- called whenever getting the task for or turning in an elixir. Wipes the shopping list and rewrites it.
update_needed_ingredients = function(self, player)
	self.needed_ingredients = {}
	for i = 1, 4 do
		for j = 1, 3 do
			if self:isCompleted(self.e[i][j].start) and not self:isCompleted(self.e[i][j].full) then
				for k = 1, 3 do
					table.insert(self.needed_ingredients, self.e[i][j].ingredients[k])
					--game.logPlayer(player, "Supposedly added one %s", self.e[i][j].ingredients[k].name)
				end
			end
		end
	end
	local list = self.needed_ingredients
--	game.logPlayer(player, "List updated. Now needed:")
--	for l = 1, #list do
--		game.logPlayer(player, "one %s", self.needed_ingredients[l].name)
--	end

	--game.logPlayer(player, "Hey! %s", self.needed_ingredients[2].name)
end

--only used in the desc function
check_i = function(self, player, ingredient)
	return game.party:hasIngredient(ingredient.id)
end

--called in various chat cond functions
check_ingredients = function(self, player, elixir, n)
	local o = {self.cookbook[elixir][1], self.cookbook[elixir][2], self.cookbook[elixir][3]}
	local first_o = game.party:hasIngredient(o[1].id)
	local second_o = game.party:hasIngredient(o[2].id)
	local third_o = game.party:hasIngredient(o[3].id)
	return first_o and second_o and third_o
end

--called in various chat cond functions
remove_ingredients = function(self, player, elixir, n)
	local o = {self.cookbook[elixir][1], self.cookbook[elixir][2], self.cookbook[elixir][3]}
	for i = 1, 3 do
		game.party:useIngredient(o[i].id, 1)
	end
end

--called both when handing out elixirs and when handing out the final reward (if any)
reward = function(self, player, reward)
	local art_list = mod.class.Object:loadList("/data/general/objects/brotherhood-artifacts.lua")
	local o = art_list[reward]:clone()
	o:resolve()
	o:resolve(nil, true)
	if o then
		player:addObject(player.INVEN_INVEN, o)
		game.logPlayer(player, "%s 받았습니다.", o:getName{do_color=true}:addJosa("를"))
	end
	game:onTickEnd(function() game:saveGame() end)
end

--reward = function(self, player, reward)
--	local o = game.zone:makeEntityByName(game.level, "object", reward)
--	if o then
--		player:addObject(player.INVEN_INVEN, o)
--		game.logPlayer(player, "You receive: %s", o:getName{do_color=true})
--	end
--end

--elixirs_finished isn't used, but it probably should be. Likely some of the cond functions in the chats could be much improved.
elixirs_finished = function(self, player, alchemist_num)
	local total = 0
	for i = 1, 3 do
		if self:isCompleted(self.e[alchemist_num][i].full) then
			total = total + 1
		end
	end
	return total
end

--called in chats. It doesn't change quest status at all. It mainly supplies chats with the names and indices of alchemists and the elixirs they're making off stage.
competition = function(self, player, other_alchemist_nums)
	local alch_picked = rng.table(other_alchemist_nums)
	local player_loses = false
	--game.logPlayer(player, "Alchemist picked: %s", alch_picked)
	local e_picked
	local set = {1, 2, 3}
	for j = 1, 3 do
		e_picked = rng.tableRemove(set)
		if not self:isCompleted(self.e[alch_picked][e_picked].full) then break end
	end

	if e_picked == 1 and self:isCompleted(self.e[alch_picked][2].full) and self:isCompleted(self.e[alch_picked][3].full) then
		player_loses = true
	elseif e_picked == 2 and self:isCompleted(self.e[alch_picked][1].full) and self:isCompleted(self.e[alch_picked][3].full) then
		player_loses = true
	elseif e_picked == 3 and self:isCompleted(self.e[alch_picked][1].full) and self:isCompleted(self.e[alch_picked][2].full) then
		player_loses = true
	else
		player_loses = false
	end

	self.other_alch = self.e[alch_picked][e_picked].kr_alchemist or self.e[alch_picked][e_picked].alchemist --@@ 한글이름 사용
	self.alch_picked = alch_picked
	self.other_elixir = self.e[alch_picked][e_picked].kr_display_name or self.e[alch_picked][e_picked].name --@@ 한글이름 사용
	self.e_picked = e_picked
	self.player_loses = player_loses
	return self.other_alch, self.other_elixir, self.player_loses, self.alch_picked, self.e_picked
end

--called in chats to force completion of the random alchemist+elixir picked in competition above.
on_turnin = function(self, player, alch_picked, e_picked, player_last_elixir)
	player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, self.e[alch_picked][e_picked].full)
	player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, self.e[alch_picked][e_picked].poached)
	-- clear chrono worlds and their various effects
	if game._chronoworlds then
		game.log("#CRIMSON#이미 결정된 일이기 때문에, 시간여행을 해도 의미가 없습니다.")
		game._chronoworlds = nil
		if player:isTalentActive(player.T_DOOR_TO_THE_PAST) then
			player:forceUseTalent(player.T_DOOR_TO_THE_PAST, {ignore_energy=true})
		end
	end
	if player_last_elixir == false and self:isCompleted(self.e[alch_picked][1].full) and self:isCompleted(self.e[alch_picked][2].full) and self:isCompleted(self.e[alch_picked][3].full) then
		player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.DONE)
		self.winner = self.e[alch_picked][1].kr_alchemist --@@ 한글 이름으로 수정
		self.player_won = false
	end
end

--sets the name of the winner. Only called in the case of the player turning in an alchemist's final potion. An alchemist that completes his third potion without the player's aid gets named the winner in the on_turning function above.
winner_is = function(self, player, alchemist_num)
	self.winner = self.e[alchemist_num][1].kr_alchemist --@@ 한글 이름으로 수정
	self.player_won = true
end

recipes = function(self)
	local ing_list = {}
	for id, d in pairs(game.party.__ingredients_def) do if d.alchemy_text then ing_list[#ing_list+1] = {id=id, name=d.name} end end
	local e = {
		{
			{
			short_name = "fox",
			name = "elixir of the fox",
			id = "ELIXIR_FOX",
			start = "fox_start",
			almost = "fox_almost_done",
			full = "elixir_of_the_fox",
			full_2 = "elixir_of_avoidance",
			full_3 = "elixir_of_precision",
			poached = "fox_poached",
			alchemist = "Stire of Derth",
			kr_display_name = "여우의 엘릭서",
			kr_alchemist = "데르스의 스티르",
			ingredients = {
				rng.tableRemove(ing_list),
				rng.tableRemove(ing_list),
				rng.tableRemove(ing_list),
				},
			},
			{
			short_name = "avoidance",
			name = "elixir of avoidance",
			id = "ELIXIR_AVOIDANCE",
			start = "avoidance_start",
			almost = "avoidance_almost_done",
			full = "elixir_of_avoidance",
			full_2 = "elixir_of_the_fox",
			full_3 = "elixir_of_precision",
			poached = "avoidance_poached",
			alchemist = "Stire of Derth",
			kr_display_name = "회피의 엘릭서",
			kr_alchemist = "데르스의 스티르",
			ingredients = {
				rng.tableRemove(ing_list),
				rng.tableRemove(ing_list),
				rng.tableRemove(ing_list),
				},
			},
			{
			short_name = "precision",
			name = "elixir of precision",
			id = "ELIXIR_PRECISION",
			start = "precision_start",
			almost = "precision_almost_done",
			full = "elixir_of_precision",
			full_2 = "elixir_of_the_fox",
			full_3 = "elixir_of_avoidance",
			poached = "precision_poached",
			alchemist = "Stire of Derth",
			kr_display_name = "정밀함의 엘릭서",
			kr_alchemist = "데르스의 스티르",
			ingredients = {
				rng.tableRemove(ing_list),
				rng.tableRemove(ing_list),
				rng.tableRemove(ing_list),
				},
			},
		},
		{
			{
			short_name = "mysticism",
			name = "elixir of mysticism",
			id = "ELIXIR_MYSTICISM",
			start = "mysticism_start",
			almost = "mysticism_almost_done",
			full = "elixir_of_mysticism",
			full_2 = "elixir_of_the_savior",
			full_3 = "elixir_of_mastery",
			poached = "mysticism_poached",
			alchemist = "Marus of Elvala",
			kr_display_name = "신비주의의 엘릭서",
			kr_alchemist = "엘발라의 마루스",
			ingredients = {
				rng.tableRemove(ing_list),
				rng.tableRemove(ing_list),
				rng.tableRemove(ing_list),
				},
			},
			{
			short_name = "savior",
			name = "elixir of the savior",
			id = "ELIXIR_SAVIOR",
			start = "savior_start",
			almost = "savior_almost_done",
			full = "elixir_of_the_savior",
			full_2 = "elixir_of_mysticism",
			full_3 = "elixir_of_mastery",
			poached = "savior_poached",
			alchemist = "Marus of Elvala",
			kr_display_name = "구원자의 엘릭서",
			kr_alchemist = "엘발라의 마루스",
			ingredients = {
				rng.tableRemove(ing_list),
				rng.tableRemove(ing_list),
				rng.tableRemove(ing_list),
				},
			},
			{
			short_name = "mastery",
			name = "elixir of mastery",
			id = "ELIXIR_MASTERY",
			start = "mastery_start",
			almost = "mastery_almost_done",
			full = "elixir_of_mastery",
			full_2 = "elixir_of_mysticism",
			full_3 = "elixir_of_the_savior",
			poached = "mastery_poached",
			alchemist = "Marus of Elvala",
			kr_display_name = "숙련의 엘릭서",
			kr_alchemist = "엘발라의 마루스",
			ingredients = {
				rng.tableRemove(ing_list),
				rng.tableRemove(ing_list),
				rng.tableRemove(ing_list),
				},
			},
		},
		{
			{
			short_name = "force",
			name = "elixir of explosive force",
			id = "ELIXIR_FORCE",
			start = "force_start",
			almost = "force_almost_done",
			full = "elixir_of_explosive_force",
			full_2 = "elixir_of_serendipity",
			full_3 = "elixir_of_focus",
			poached = "force_poached",
			alchemist = "Agrimley the hermit",
			kr_display_name = "폭발력의 엘릭서",
			kr_alchemist = "은둔자 아그림레이",
			ingredients = {
				rng.tableRemove(ing_list),
				rng.tableRemove(ing_list),
				rng.tableRemove(ing_list),
				},
			},
			{
			short_name = "serendipity",
			name = "elixir of serendipity",
			id = "ELIXIR_SERENDIPITY",
			start = "serendipity_start",
			almost = "serendipity_almost_done",
			full = "elixir_of_serendipity",
			full_2 = "elixir_of_explosive_force",
			full_3 = "elixir_of_focus",
			poached = "serendipity_poached",
			alchemist = "Agrimley the hermit",
			kr_display_name = "행운의 엘릭서",
			kr_alchemist = "은둔자 아그림레이",
			ingredients = {
				rng.tableRemove(ing_list),
				rng.tableRemove(ing_list),
				rng.tableRemove(ing_list),
				},
			},
			{
			short_name = "focus",
			name = "elixir of focus",
			id = "ELIXIR_FOCUS",
			start = "focus_start",
			almost = "focus_almost_done",
			full = "elixir_of_focus",
			full_2 = "elixir_of_explosive_force",
			full_3 = "elixir_of_serendipity",
			poached = "focus_poached",
			alchemist = "Agrimley the hermit",
			kr_display_name = "집중의 엘릭서",
			kr_alchemist = "은둔자 아그림레이",
			ingredients = {
				rng.tableRemove(ing_list),
				rng.tableRemove(ing_list),
				rng.tableRemove(ing_list),
				},
			},
		},
		{
			{
			short_name = "brawn",
			name = "elixir of brawn",
			id = "ELIXIR_BRAWN",
			start = "brawn_start",
			almost = "brawn_almost_done",
			full = "elixir_of_brawn",
			full_2 = "elixir_of_stoneskin",
			full_3 = "elixir_of_foundations",
			poached = "brawn_poached",
			alchemist = "Ungrol of Last Hope",
			kr_display_name = "완력의 엘릭서",
			kr_alchemist = "마지막 희망의 운그롤",
			ingredients = {
				rng.tableRemove(ing_list),
				rng.tableRemove(ing_list),
				rng.tableRemove(ing_list),
				},
			},
			{
			short_name = "stoneskin",
			name = "elixir of stoneskin",
			id = "ELIXIR_STONESKIN",
			start = "stoneskin_start",
			almost = "stoneskin_almost_done",
			full = "elixir_of_stoneskin",
			full_2 = "elixir_of_brawn",
			full_3 = "elixir_of_foundations",
			poached = "stoneskin_poached",
			alchemist = "Ungrol of Last Hope",
			kr_display_name = "단단한 피부의 엘릭서",
			kr_alchemist = "마지막 희망의 운그롤",
			ingredients = {
				rng.tableRemove(ing_list),
				rng.tableRemove(ing_list),
				rng.tableRemove(ing_list),
				},
			},
			{
			short_name = "foundations",
			name = "elixir of foundations",
			id = "ELIXIR_FOUNDATIONS",
			start = "foundations_start",
			almost = "foundations_almost_done",
			full = "elixir_of_foundations",
			full_2 = "elixir_of_brawn",
			full_3 = "elixir_of_stoneskin",
			poached = "foundations_poached",
			alchemist = "Ungrol of Last Hope",
			kr_display_name = "기반의 엘릭서",
			kr_alchemist = "마지막 희망의 운그롤",
			ingredients = {
				rng.tableRemove(ing_list),
				rng.tableRemove(ing_list),
				rng.tableRemove(ing_list),
				},
			},
		},
	}
	-- cookbook is redundant with the completeness of e, but going through the chat and quest code and changing all the cookbook reference seemed like more trouble than just keeping this around
	local cookbook = {
		fox = e[1][1].ingredients,
		avoidance = e[1][2].ingredients,
		precision = e[1][3].ingredients,
		mysticism = e[2][1].ingredients,
		savior = e[2][2].ingredients,
		mastery = e[2][3].ingredients,
		force = e[3][1].ingredients,
		serendipity = e[3][2].ingredients,
		focus = e[3][3].ingredients,
		brawn = e[4][1].ingredients,
		stoneskin = e[4][2].ingredients,
		foundations = e[4][3].ingredients,
	}
	-- elixirs table is a relic from an earlier version of the code. Keeping it around because it sums things up nicely for anybody reading this
	local elixirs = {
		derth = {"elixir_of_the_fox", "elixir_of_avoidance", "elixir_of_precision"},
		elvala = {"elixir_of_mysticism", "elixir_of_the_savior", "elixir_of_mastery"},
		hermit = {"elixir_of_explosive_force", "elixir_of_serendipity", "elixir_of_focus"},
		hope = {"elixir_of_brawn", "elixir_of_stoneskin", "elixir_of_foundations"},
	}

	-- another relic from the pre-e days.
	local alchemists = {"Stire of Derth", "Marus of Elvala", "Agrimley the hermit", "Ungrol of Last Hope", }

	return cookbook, elixirs, alchemists, e
end
