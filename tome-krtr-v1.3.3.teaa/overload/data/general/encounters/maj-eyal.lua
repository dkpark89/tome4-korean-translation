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

newEntity{
	name = "Novice mage",
	kr_name = "풋내기 마법사",
	type = "harmless", subtype = "special", unique = true,
	immediate = {"world-encounter", "angolwen"},
	-- Spawn the novice mage near the player
	on_encounter = function(self, who)
		local x, y = self:findSpot(who)
		if not x then return end

		local g = mod.class.WorldNPC.new{
			name="Novice mage",
			kr_name = "풋내기 마법사",
			type="humanoid", subtype="human", faction="angolwen",
			display='@', color=colors.RED,
			image = "npc/humanoid_human_apprentice_mage.png",
			can_talk = "mage-apprentice-quest",
			cant_be_moved = false,
			unit_power = 3000,
		}
		g:resolve() g:resolve(nil, true)
		game.zone:addEntity(game.level, g, "actor", x, y)
		return true
	end,
}

newEntity{
	name = "Lost merchant",
	kr_name = "길 잃은 상인",
	type = "hostile", subtype = "special", unique = true,
	level_range = {10, 20},
	rarity = 7,
	min_level = 6,
	on_world_encounter = "merchant-quest",
	on_encounter = function(self, who)
		who.energy.value = game.energy_to_act
		game.paused = true
		who:runStop()
		engine.ui.Dialog:yesnoPopup("마주침", "당신은 숨겨진 문을 발견했습니다. 안에서 도움을 바라는 울음소리가 들립니다...", function(ok)
			if not ok then
				game.logPlayer(who, "#LIGHT_BLUE#당신은 소리나지 않게 조심히 물러났습니다.")
			else
				game:changeLevel(1, "thieves-tunnels")
				game.logPlayer(who, "#LIGHT_RED#당신은 조심스레 문을 열고 지하 터널의 입구로 들어섭니다...")
				game.logPlayer(who, "#LIGHT_RED#입구로 들어선 뒤 문을 안쪽을 보자, 문을 다룰 손잡이가 없는 것을 발견했습니다. 당신은 이곳에 갇혔습니다!")
				who:grantQuest("lost-merchant")
			end
		end, "터널로 들어감", "조용히 떠남", true)
		return true
	end,
}

newEntity{
	name = "Sect of Kryl-Feijan",
	kr_name = "크릴-페이얀의 이교도",
	type = "hostile", subtype = "special", unique = true,
	level_range = {24, 35},
	rarity = 7,
	min_level = 24,
	coords = {{ x=0, y=0, w=100, h=100}},
	on_encounter = function(self, who)
		who.energy.value = game.energy_to_act
		game.paused = true
		who:runStop()
		engine.ui.Dialog:yesnoLongPopup("마주침", "당신은 오래된 지하실의 입구를 발견했습니다. 무서울 정도로 사악한 기운이 뿜어져 나오고 있어, 당신은 문 앞에 서 있는 것만으로도 위협 당하는 듯한 느낌이 듭니다.\n알아듣기는 힘들지만, 안에서 여성의 울음소리가 들리는 것 같습니다.", 400, function(ok)
			if not ok then
				game.logPlayer(who, "#LIGHT_BLUE#당신은 소리나지 않게 조심히 물러났습니다.")
			else
				game:changeLevel(1, "crypt-kryl-feijan")
				game.logPlayer(who, "#LIGHT_RED#당신은 조심스레 문을 열고 지하실로 들어섭니다...")
				game.logPlayer(who, "#LIGHT_RED#입구로 들어선 뒤 문을 안쪽을 보자, 문을 다룰 손잡이가 없는 것을 발견했습니다. 당신은 이곳에 갇혔습니다!")
			end
		end, "지하실로 들어감", "조용히 떠남", true)
		return true
	end,
}

newEntity{
	name = "Lost kitten", 
	kr_name = "길 잃은 고양이",
	type = "harmless", subtype = "special", unique = true,
	level_range = {15, 35},
	rarity = 100,
	min_level = 15,
	on_world_encounter = "merchant-quest",
	on_encounter = function(self, who)
		who.energy.value = game.energy_to_act
		game.paused = true
		who:runStop()
		local Chat = require "engine.Chat"
		local chat = Chat.new("sage-kitty", mod.class.NPC.new{name="Lost Kitty", kr_name="길 잃은 고양이", image="npc/sage_kitty.png"}, who) 
		chat:invoke()
		return true
	end,
}

newEntity{
	name = "Ancient Elven Ruins",
	kr_name = "고대 엘프의 폐허",
	type = "harmless", subtype = "special", unique = true,
	immediate = {"world-encounter", "maj-eyal"},
	on_encounter = function(self, who)
		local x, y = self:findSpot(who)
		if not x then return end

		local g = game.level.map(x, y, engine.Map.TERRAIN):cloneFull()
		g.name = "Entrance to some ancient elven ruins"
		g.kr_name = "고대 엘프의 폐허로의 입구"
		g.display='>' g.color_r=0 g.color_g=255 g.color_b=255 g.notice = true
		g.change_level=1 g.change_zone="ancient-elven-ruins" g.glow=true
		g.add_displays = g.add_displays or {}
		g.add_displays[#g.add_displays+1] = mod.class.Grid.new{image="terrain/dungeon_entrance_closed02.png", z=5}
		g:altered()
		g:initGlow()
		game.zone:addEntity(game.level, g, "terrain", x, y)
		print("[WORLDMAP] Elven ruins at", x, y)
		return true
	end,
}

newEntity{
	name = "Cursed Village",
	kr_name = "저주받은 마을",
	type = "harmless", subtype = "special", unique = true,
	level_range = {5, 15},
	rarity = 8,
	on_world_encounter = "lumberjack-cursed",
	on_encounter = function(self, who)
		who.energy.value = game.energy_to_act
		game.paused = true
		who:runStop()
		local Chat = require "engine.Chat"
		local chat = Chat.new("lumberjack-quest", {name="Half-dead lumberjack", kr_name="반 죽은 나무꾼"}, who)
		chat:invoke()
		return true
	end,
}

newEntity{
	name = "Ruined Dungeon",
	kr_name = "파괴된 던전",
	type = "harmless", subtype = "special", unique = true,
	immediate = {"world-encounter", "maj-eyal"},
	on_encounter = function(self, who)
		local x, y = self:findSpot(who)
		if not x then return end

		local g = game.level.map(x, y, engine.Map.TERRAIN):cloneFull()
		g.name = "Entrance to a ruined dungeon"
		g.kr_name = "파괴된 던전으로 가는 입구"
		g.display='>' g.color_r=255 g.color_g=0 g.color_b=0 g.notice = true
		g.change_level=1 g.change_zone="ruined-dungeon" g.glow=true
		g.add_displays = g.add_displays or {}
		g.add_displays[#g.add_displays+1] = mod.class.Grid.new{image="terrain/ruin_entrance_closed01.png", z=5}
		g:altered()
		g:initGlow()
		game.zone:addEntity(game.level, g, "terrain", x, y)
		print("[WORLDMAP] Ruined dungeon at", x, y)
		return true
	end,
}

newEntity{
	name = "Mark of the Spellblaze",
	kr_name = "마법폭발의 흔적",
	type = "harmless", subtype = "special", unique = true,
	immediate = {"world-encounter", "mark-spellblaze"},
	on_encounter = function(self, who)
		local x, y = self:findSpot(who)
		if not x then return end

		local g = game.level.map(x, y, engine.Map.TERRAIN):cloneFull()
		g.name = "Mark of the Spellblaze"
		g.kr_name = "마법폭발의 흔적"
		g.display='>' g.color_r=0 g.color_g=200 g.color_b=0 g.notice = true
		g.change_level=1 g.change_zone="mark-spellblaze" g.glow=true
		g.add_displays = g.add_displays or {}
		g.add_displays[#g.add_displays+1] = mod.class.Grid.new{image="terrain/floor_pentagram.png", z=8}
		g:altered()
		g:initGlow()
		game.zone:addEntity(game.level, g, "terrain", x, y)
		print("[WORLDMAP] Mark of the spellblaze at", x, y)
		return true
	end,
}

newEntity{
	name = "Golem Graveyard",
	kr_name = "골렘의 묘지",
	type = "harmless", subtype = "special", unique = true,
	immediate = {"world-encounter", "maj-eyal"},
	on_encounter = function(self, who)
		local x, y = self:findSpot(who)
		if not x then return end

		local g = game.level.map(x, y, engine.Map.TERRAIN):cloneFull()
		g.name = "Golem Graveyard"
		g.kr_name = "골렘의 묘지"
		g.display='>' g.color_r=0 g.color_g=200 g.color_b=0 g.notice = true
		g.change_level=1 g.change_zone="golem-graveyard" g.glow=true
		g.add_displays = g.add_displays or {}
		g.add_displays[#g.add_displays+1] = mod.class.Grid.new{image="npc/alchemist_golem.png", z=5}
		g:altered()
		g:initGlow()
		game.zone:addEntity(game.level, g, "terrain", x, y)
		print("[WORLDMAP] Golem Graveyard at", x, y)
		return true
	end,
}

newEntity{
	name = "Agrimley the Hermit",
	kr_name = "은둔자 아그림레이",
	type = "harmless", subtype = "special", unique = true,
	immediate = {"world-encounter", "brotherhood-alchemist"},
	-- Spawn the hermit
	on_encounter = function(self, who)
		local x, y = self:findSpot(who)
		if not x then return end

		local g = mod.class.WorldNPC.new{
			name="Agrimley the Hermit",
			kr_name = "은둔자 아그림레이",
			type="humanoid", subtype="halfling", faction="neutral",
			display='@', color=colors.BLUE,
			can_talk = "alchemist-hermit",
			cant_be_moved = false,
			unit_power = 3000,
		}
		g:resolve() g:resolve(nil, true)
		game.zone:addEntity(game.level, g, "actor", x, y)
		print("[WORLDMAP] Agrimley at", x, y)
		return true
	end,
}

newEntity{
	name = "Ring of Blood",
	kr_name = "피의 투기장",
	type = "harmless", subtype = "special", unique = true,
	immediate = {"world-encounter", "maj-eyal"},
	on_encounter = function(self, who)
		local x, y = self:findSpot(who)
		if not x then return end

		local g = game.level.map(x, y, engine.Map.TERRAIN):cloneFull()
		g.name = "Hidden compound"
		g.kr_name = "숨겨진 노예 수용소"
		g.display='>' g.color_r=200 g.color_g=0 g.color_b=0 g.notice = true
		g.change_level=1 g.change_zone="ring-of-blood" g.glow=true
		g.add_displays = g.add_displays or {}
		g.add_displays[#g.add_displays+1] = mod.class.Grid.new{image="terrain/cave_entrance_closed02.png", z=5}
		g:altered()
		g:initGlow()
		game.zone:addEntity(game.level, g, "terrain", x, y)
		print("[WORLDMAP] Hidden compound at", x, y)
		return true
	end,
}

newEntity{
	name = "Tranquil Meadow",
	kr_name = "고요한 목초지",
	type = "harmless", subtype = "special", unique = true,
	immediate = {"world-encounter", "angolwen"},
	on_encounter = function(self, where)
		-- where contains x, y of random location based on .immediate as defined in eyal map
		if not where then return end
		if not game:getPlayer(true).descriptor or game:getPlayer(true).descriptor.subclass ~= "Cursed" then return end
		
		-- make sure "where" is ok
		local x, y = self:findSpot(where)
		if not x then return end

		local g = game.level.map(x, y, engine.Map.TERRAIN):cloneFull()
		g.name = "tranquil meadow"
		g.kr_name = "고요한 목초지"
		g.display='>' g.color_r=0 g.color_g=255 g.color_b=128 g.notice = true
		g.change_level=1 g.change_zone="keepsake-meadow" g.glow=true
		g.add_displays = g.add_displays or {}
		g.add_displays[#g.add_displays+1] = mod.class.Grid.new{image="terrain/meadow.png", z=5}
		g:altered()
		g:initGlow()
		game.zone:addEntity(game.level, g, "terrain", x, y)
		print("[WORLDMAP] Keepsake: Tranquil Meadow at", x, y)
		return true
	end,
}
