-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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

-- Keepsake
name = "Keepsake"
kr_display_name = "고통의 자취"
id = "keepsake"

desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "당신은 자신에게 걸린 저주를 극복할 수 있는 방법을 찾고 있습니다."
	if self:isCompleted("berethh-killed-good") then
		desc[#desc+1] = "당신은 과거의 기억과 연관된 것으로 보이는, 작은 무쇠 도토리를 찾았습니다."
		desc[#desc+1] = "당신은 한때 가족으로 여기던, 대상 행렬 상인들을 도륙했습니다."
		desc[#desc+1] = "저주를 불러온 자인 킬레스는 당신의 손에 의해 죽음을 맞이했습니다."
		desc[#desc+1] = "베레쓰는 죽었습니다. 그는 평화롭게 잠들 수 있을 것입니다."
		desc[#desc+1] = "당신의 저주는 작은 무쇠 도토리를 변화시켰으며, 이제 이 도토리는 당신의 잔인한 과거와 현재를 상기시키고 있습니다."
	elseif self:isCompleted("berethh-killed-evil") then
		desc[#desc+1] = "당신은 과거의 기억과 연관된 것으로 보이는, 작은 무쇠 도토리를 찾았습니다."
		desc[#desc+1] = "당신은 한때 가족으로 여기던, 대상 행렬 상인들을 도륙했습니다."
		desc[#desc+1] = "저주를 불러온 자인 킬레스는 당신의 손에 의해 죽음을 맞이했습니다."
		desc[#desc+1] = "베레쓰는 죽었습니다. 그는 평화롭게 잠들 수 있을 것입니다."
		desc[#desc+1] = "당신의 저주는 작은 무쇠 도토리를 변화시켰으며, 이제 이 도토리는 당신의 흉폭한 본성을 상기시키고 있습니다."
	elseif self:isCompleted("kyless-killed") then
		desc[#desc+1] = "당신은 과거의 기억과 연관된 것으로 보이는, 작은 무쇠 도토리를 찾았습니다."
		desc[#desc+1] = "당신은 한때 가족으로 여기던, 대상 행렬 상인들을 도륙했습니다."
		desc[#desc+1] = "저주를 불러온 자인 킬레스는 당신의 손에 의해 죽음을 맞이했습니다."
		desc[#desc+1] = "#LIGHT_GREEN#당신은 당신을 도와줄 수 있는 마지막 사람인, 베레쓰를 찾아야 합니다."
	elseif self:isCompleted("caravan-destroyed") then
		desc[#desc+1] = "당신은 과거의 기억과 연관된 것으로 보이는, 작은 무쇠 도토리를 찾았습니다."
		desc[#desc+1] = "당신은 한때 가족으로 여기던, 대상 행렬 상인들을 도륙했습니다."
		desc[#desc+1] = "#LIGHT_GREEN#목초지의 북쪽에 있는, 킬레스가 있는 동굴을 찾아 그를 죽여야 합니다. 아마 저주가 그와 함께 끝나게 될 것입니다."
	elseif self:isCompleted("acorn-found") then
		desc[#desc+1] = "당신은 과거의 기억과 연관된 것으로 보이는, 작은 무쇠 도토리를 찾았습니다."
		desc[#desc+1] = "#LIGHT_GREEN#이 도토리와 꿈에 담긴 의미를 찾아야 합니다."
	else
		desc[#desc+1] = "#LIGHT_GREEN#당신은 과거의 장소를 다시 들러, 그곳에 묻힌 비밀을 찾아내야 합니다."
	end
	return table.concat(desc, "\n")
end

on_grant = function(self, who)
	game.logPlayer(who, "#VIOLET#당신의 저주에 담긴 진정한 본성을 깨달을 시간이 왔습니다.")
	game.player:incHate(-100)
	
	if who:knowTalent(who.T_DEFILING_TOUCH) then
		self.balance = -1
	else
		self.balance = 0
	end
end

on_enter_meadow = function(self, who)
	if self.return_from_dream then
		self:on_return_from_dream(who)
	elseif self.spawn_companions then
		self:on_spawn_companions(who)
	end
end

on_enter_cave_entrance = function(self, who)
	if self.spawn_berethh then
		self:on_spawn_berethh(who)
	end
end

on_start_dream = function(self, who)
	game.party:learnLore("keepsake-dream")
	game.logPlayer(who, "#VIOLET#당신은 꿈 속에서 자기 자신을 찾았습니다.")
	
	-- make sure waking up returns to the same spot
	game.level.default_down.x = who.x
	game.level.default_down.y = who.y
	
	-- move to dream
	game:changeLevel(2, nil, {direct_switch=true})
	game:playSound("ambient/forest/wind1")
	
	-- make yourself immortal
	who.old_die = who.die
	who.die = function(self)
		local old_heal_factor = healing_factor
		self.healing_factor = 1
		self:heal(math.max(0, self.life) + self.max_life * 0.5)
		self.healing_factor = old_heal_factor
		
		self:incHate(25)
		
		self.dead = false
		game.logPlayer(who, "#VIOLET#당신의 증오심이 불타오르기 시작했습니다. 당신은 죽음을 거부했습니다!")
	end
end

on_pickup_acorn = function(self, who)
	game.party:learnLore("keepsake-acorn")
	game.logPlayer(who, "#VIOLET#당신은 당신의 과거와 연결된 물건인, 작은 무쇠 도토리를 찾았습니다.")
	
	who:setQuestStatus("keepsake", engine.Quest.COMPLETED, "acorn-found")
end

on_find_caravan = function(self, who)
	game.party:learnLore("keepsake-caravan")
	game.logPlayer(who, "#VIOLET#과거에서 온 대상 행렬 상인들이 꿈 속에서 나타났습니다.")
	
	-- turn the caravaneers hostile
	engine.Faction:setFactionReaction(who.faction, "merchant-caravan", -100, true)
end

on_caravan_destroyed = function(self, who)
	local Chat = require "engine.Chat"
	local chat = Chat.new("keepsake-caravan-destroyed", {name="Last of the Caravan", kr_display_name="대상 행렬의 마지막 남은 상인"}, game.player)
	chat:invoke()
end

on_caravan_destroyed_chat_over = function(self, who)
	who:setQuestStatus("keepsake", engine.Quest.COMPLETED, "caravan-destroyed")
	
	-- return to the meadow and create the cave exit
	game:changeLevel(1, nil, {direct_switch=true})
	local g = mod.class.Grid.new{
		show_tooltip=true, always_remember = true,
		type="floor", subtype="grass",
		name="secret path to the cave",
		kr_display_name="동굴로 가는 숨겨진 길",
		image = "terrain/grass.png", add_mos = {{image="terrain/way_next_8.png"}},
		display = '>', color_r=255, color_g=255, color_b=0,
		notice = true, always_remember = true,
		change_level=2
	}
	g:resolve() g:resolve(nil, true)
	local spot = game.level:pickSpot{type="level", subtype="down"}
	game.zone:addEntity(game.level, g, "terrain", spot.x, spot.y)
	-- move location where you appear from dream wakeup spot to the new stairs
	game.level.default_down.x = spot.x
	game.level.default_down.y = spot.y
	
	-- make yourself mortal again
	game.player:heal(10000)
	game.player:incHate(10000)
	who.die = who.old_die
	who.old_die = nil
	
	game.party:learnLore("keepsake-dreams-end")
	game.logPlayer(who, "#VIOLET#당신은 킬레스를 사냥하기 시작했습니다!")
end

on_cave_marker = function(self, who)
	game.party:learnLore("keepsake-cave-marker")
	game.logPlayer(who, "#VIOLET#당신은 킬레스의 동굴 입구로 가는 표식을 발견했습니다!")
end

on_cave_entrance = function(self, who)
	game.party:learnLore("keepsake-cave-entrance")
	game.logPlayer(who, "#VIOLET#당신은 킬레스의 동굴 입구를 발견했습니다!")
end

on_cave_description = function(self, who)
	game.party:learnLore("keepsake-cave-description")
	
	-- spawn the guards
	spot = game.level:pickSpot{type="guards", subtype="wardog"}
	x, y = util.findFreeGrid(spot.x, spot.y, 2, true, {[engine.Map.ACTOR]=true})
	m = game.zone:makeEntityByName(game.level, "actor", "CORRUPTED_WAR_DOG")
	if m and x and y then game.zone:addEntity(game.level, m, "actor", x, y) end
	
	for i = 1, 2 do
		spot = game.level:pickSpot{type="guards", subtype="claw"}
		x, y = util.findFreeGrid(spot.x, spot.y, 2, true, {[engine.Map.ACTOR]=true})
		m = game.zone:makeEntityByName(game.level, "actor", "SHADOW_CLAW")
		if m and x and y then game.zone:addEntity(game.level, m, "actor", x, y) end
	end
end

on_vault_entrance = function(self, who)
	game.party:learnLore("keepsake-vault-entrance")
	game.logPlayer(who, "#VIOLET#당신은 금고 입구를 발견하였습니다!")
end

on_vault_trigger = function(self, who)
	for i = 1, 7 do
		spot = game.level:pickSpot{type="vault1", subtype="encounter"}
		x, y = util.findFreeGrid(spot.x, spot.y, 2, true, {[engine.Map.ACTOR]=true})
		m = game.zone:makeEntity(game.level, "actor", {special_rarity="vault_rarity"}, nil, true)
		if m and x and y then game.zone:addEntity(game.level, m, "actor", x, y) end
	end
	game.logPlayer(who, "#VIOLET#그림자가 당신의 존재를 인지했습니다!")
end

on_dog_vault = function(self, who)
	require("engine.ui.Dialog"):simplePopup("두 번째 창고", "당신은 이 문이 두 번째 창고로 통하는 문이라는 것을 깨달았습니다. 문을 통해 휙휙거리는 소리와 큰 숨소리가 들려옵니다.")
end

on_kyless_encounter = function(self, who)
	game.party:learnLore("keepsake-kyless-encounter")
	game.logPlayer(who, "#VIOLET#당신은 킬레스를 발견했습니다. 그를 반드시 죽여야 합니다.")
end

on_kyless_death = function(self, who, kyless)
	local Chat = require "engine.Chat"
	local chat = Chat.new("keepsake-kyless-death", {name="Death of Kyless", kr_display_name="킬레스의 죽음"}, game.player)
	chat:invoke()

	who:setQuestStatus("keepsake", engine.Quest.COMPLETED, "kyless-killed")
	game.logPlayer(who, "#VIOLET#킬레스가 죽었습니다.")
	self.spawn_berethh = true
end

on_keep_book = function(self, who)
	local o = game.zone:makeEntityByName(game.level, "object", "KYLESS_BOOK")
	if o then
		game.zone:addEntity(game.level, o, "object")
		who:addObject(who.INVEN_INVEN, o)
		o:added()
		who:sortInven()
	end
end

on_spawn_berethh = function(self, who)
	spot = game.level:pickSpot{type="berethh", subtype="encounter"}
	x, y = util.findFreeGrid(spot.x, spot.y, 5, true, {[engine.Map.ACTOR]=true})
	m = game.zone:makeEntityByName(game.level, "actor", "BERETHH")
	if m and x and y then
		game.zone:addEntity(game.level, m, "actor", x, y)
		self.spawn_berethh = nil
	end
end

on_berethh_encounter = function(self, who, berethh)
	local Chat = require "engine.Chat"
	local chat = Chat.new("keepsake-berethh-encounter", {name="Berethh", kr_display_name="베레쓰"}, game.player)
	chat:invoke()
end

on_berethh_death = function(self, who, berethh)
	game.logPlayer(who, "#VIOLET#베레쓰는 죽음을 맞이했습니다.")
	
	if self.balance > 0 then
		who:setQuestStatus("keepsake", engine.Quest.COMPLETED, "berethh-killed-good")
		game.party:learnLore("keepsake-berethh-death-good")
	else
		who:setQuestStatus("keepsake", engine.Quest.COMPLETED, "berethh-killed-evil")
		game.party:learnLore("keepsake-berethh-death-evil")
	end
	self.spawn_companions = true
	
	who:setQuestStatus("keepsake", engine.Quest.DONE)
	
	local o, item, inven_id = who:findInAllInventoriesBy("define_as", "IRON_ACORN_BASIC")
	if o then
		who:removeObject(inven_id, item, true)
		o:removed()
		
		local o
		if self.balance > 0 then
			o = game.zone:makeEntityByName(game.level, "object", "IRON_ACORN_GOOD")
		else
			o = game.zone:makeEntityByName(game.level, "object", "IRON_ACORN_EVIL")
		end
		if o then
			game.zone:addEntity(game.level, o, "object")
			who:addObject(who.INVEN_INVEN, o)
			o:added()
			who:sortInven()
		end
	end
end

on_spawn_companions = function(self, who)
	self.spawn_companions = nil
	for i = 1, 2 do
		spot = game.level:pickSpot{type="companions", subtype="wardog"}
		x, y = util.findFreeGrid(spot.x, spot.y, 2, true, {[engine.Map.ACTOR]=true})
		m = game.zone:makeEntityByName(game.level, "actor", "WAR_DOG")
		if m and x and y then game.zone:addEntity(game.level, m, "actor", x, y) end
	end
	for i = 1, 2 do
		spot = game.level:pickSpot{type="companions", subtype="warrior"}
		x, y = util.findFreeGrid(spot.x, spot.y, 2, true, {[engine.Map.ACTOR]=true})
		m = game.zone:makeEntityByName(game.level, "actor", "BERETHH_WARRIOR")
		if m and x and y then game.zone:addEntity(game.level, m, "actor", x, y) end
	end
	for i = 1, 2 do
		spot = game.level:pickSpot{type="companions", subtype="archer"}
		x, y = util.findFreeGrid(spot.x, spot.y, 2, true, {[engine.Map.ACTOR]=true})
		m = game.zone:makeEntityByName(game.level, "actor", "BERETHH_ARCHER")
		if m and x and y then game.zone:addEntity(game.level, m, "actor", x, y) end
	end
end

on_good_choice = function(self, who)
	self.balance = (self.balance or 0) + 1
end

on_evil_choice = function(self, who)
	self.balance = (self.balance or 0) - 1
end
