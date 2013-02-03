﻿-- ToME - Tales of Maj'Eyal
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

newEntity{
	name = "Novice mage",
	kr_display_name = "풋내기 마법사",
	type = "harmless", subtype = "special", unique = true,
	immediate = {"world-encounter", "angolwen"},
	-- Spawn the novice mage near the player
	on_encounter = function(self, who)
		local x, y = self:findSpot(who)
		if not x then return end

		local g = mod.class.WorldNPC.new{
			name="Novice mage",
			type="humanoid", subtype="human", faction="angolwen",
			display='@', color=colors.RED,
			image = "npc/humanoid_human_apprentice_mage.png",
			can_talk = "mage-apprentice-quest",
			unit_power = 3000,
		}
		g:resolve() g:resolve(nil, true)
		game.zone:addEntity(game.level, g, "actor", x, y)
		return true
	end,
}

newEntity{
	name = "Lost merchant",
	kr_display_name = "길잃은 상인",
	type = "hostile", subtype = "special", unique = true,
	level_range = {10, 20},
	rarity = 7,
	min_level = 6,
	on_world_encounter = "merchant-quest",
	on_encounter = function(self, who)
		who.energy.value = game.energy_to_act
		game.paused = true
		who:runStop()
		engine.ui.Dialog:yesnoPopup("마주침", "당신은 숨겨진 문을 발견했고, 그 안에서 도움을 바라는 울음소리가 들립니다...", function(ok)
			if not ok then
				game.logPlayer(who, "#LIGHT_BLUE#당신은 소리나지 않게 조심히 물러났습니다.")
			else
				game:changeLevel(1, "thieves-tunnels")
				game.logPlayer(who, "#LIGHT_RED#당신은 조심스레 문을 열고 지하 터널의 입구로 들어섭니다...")
				game.logPlayer(who, "#LIGHT_RED#입구로 들어선후, 문의 안쪽에는 문을 다룰 손잡이 없는것을 발견했습니다. 당신은 여기 갖혔습니다!")
				who:grantQuest("lost-merchant")
			end
		end, "터널로 들어감", "조용히 떠남", true)
		return true
	end,
}

newEntity{
	name = "Sect of Kryl-Feijan",
	kr_display_name = "크릴-페이얀의 이교도",
	type = "hostile", subtype = "special", unique = true,
	level_range = {24, 35},
	rarity = 7,
	min_level = 24,
	coords = {{ x=0, y=0, w=100, h=100}},
	on_encounter = function(self, who)
		who.energy.value = game.energy_to_act
		game.paused = true
		who:runStop()
		engine.ui.Dialog:yesnoLongPopup("마주침", "당신은 오래된 지하실의 입구를 발견했습니다. 이 장소에서 무서운 사악한 오러가 뿜어져 나오고 있습니다. 당신은 거기 서있는것만으로도 위협을 당하는 느낌이 듭니다.\n그 안에서 알아듣기 힘든 여성의 울음소리가 들립니다.", 400, function(ok)
			if not ok then
				game.logPlayer(who, "#LIGHT_BLUE#당신은 소리나지 않게 조심히 물러났습니다.")
			else
				game:changeLevel(1, "crypt-kryl-feijan")
				game.logPlayer(who, "#LIGHT_RED#당신은 조심스레 문을 열고 지하실로 들어섭니다...")
				game.logPlayer(who, "#LIGHT_RED#입구로 들어선후, 문의 안쪽에는 문을 다룰 손잡이 없는것을 발견했습니다. 당신은 여기 갖혔습니다!")
			end
		end, "지하실로 들어감", "조용히 떠남", true)
		return true
	end,
}

newEntity{
	name = "Ancient Elven Ruins",
	kr_display_name = "고대 엘프의 폐허",
	type = "harmless", subtype = "special", unique = true,
	immediate = {"world-encounter", "maj-eyal"},
	on_encounter = function(self, who)
		local x, y = self:findSpot(who)
		if not x then return end

		local g = game.level.map(x, y, engine.Map.TERRAIN):cloneFull()
		g.__nice_tile_base = nil
		g.name = "Entrance to some ancient elven ruins"
		g.kr_display_name = "고대 엘프의 폐허로의 입구"
		g.display='>' g.color_r=0 g.color_g=255 g.color_b=255 g.notice = true
		g.change_level=1 g.change_zone="ancient-elven-ruins" g.glow=true
		g.add_displays = g.add_displays or {}
		g.add_displays[#g.add_displays+1] = mod.class.Grid.new{image="terrain/dungeon_entrance_closed02.png", z=5}
		g.nice_tiler = nil
		g:initGlow()
		game.zone:addEntity(game.level, g, "terrain", x, y)
		print("[WORLDMAP] Elven ruins at", x, y)
		return true
	end,
}

newEntity{
	name = "Cursed Village",
	kr_display_name = "저주받은 마을",
	type = "harmless", subtype = "special", unique = true,
	level_range = {5, 15},
	rarity = 8,
	on_world_encounter = "lumberjack-cursed",
	on_encounter = function(self, who)
		who.energy.value = game.energy_to_act
		game.paused = true
		who:runStop()
		local Chat = require "engine.Chat"
		local chat = Chat.new("lumberjack-quest", {name="Half-dead lumberjack"}, who)
		chat:invoke()
		return true
	end,
}

newEntity{
	name = "Ruined Dungeon",
	kr_display_name = "파괴된 던전",
	type = "harmless", subtype = "special", unique = true,
	immediate = {"world-encounter", "maj-eyal"},
	on_encounter = function(self, who)
		local x, y = self:findSpot(who)
		if not x then return end

		local g = game.level.map(x, y, engine.Map.TERRAIN):cloneFull()
		g.__nice_tile_base = nil
		g.name = "Entrance to a ruined dungeon"
		g.kr_display_name = "파괴된 던전으로의 입구"
		g.display='>' g.color_r=255 g.color_g=0 g.color_b=0 g.notice = true
		g.change_level=1 g.change_zone="ruined-dungeon" g.glow=true
		g.add_displays = g.add_displays or {}
		g.add_displays[#g.add_displays+1] = mod.class.Grid.new{image="terrain/ruin_entrance_closed01.png", z=5}
		g.nice_tiler = nil
		g:initGlow()
		game.zone:addEntity(game.level, g, "terrain", x, y)
		print("[WORLDMAP] Ruined dungeon at", x, y)
		return true
	end,
}

newEntity{
	name = "Mark of the Spellblaze",
	kr_display_name = "마법폭발의 흔적",
	type = "harmless", subtype = "special", unique = true,
	immediate = {"world-encounter", "mark-spellblaze"},
	on_encounter = function(self, who)
		local x, y = self:findSpot(who)
		if not x then return end

		local g = game.level.map(x, y, engine.Map.TERRAIN):cloneFull()
		g.__nice_tile_base = nil
		g.name = "Mark of the Spellblaze"
		g.kr_display_name = "마법폭발의 흔적"
		g.display='>' g.color_r=0 g.color_g=200 g.color_b=0 g.notice = true
		g.change_level=1 g.change_zone="mark-spellblaze" g.glow=true
		g.add_displays = g.add_displays or {}
		g.add_displays[#g.add_displays+1] = mod.class.Grid.new{image="terrain/floor_pentagram.png", z=8}
		g.nice_tiler = nil
		g:initGlow()
		game.zone:addEntity(game.level, g, "terrain", x, y)
		print("[WORLDMAP] Mark of the spellblaze at", x, y)
		return true
	end,
}

newEntity{
	name = "Golem Graveyard",
	kr_display_name = "골렘 공동묘지",
	type = "harmless", subtype = "special", unique = true,
	immediate = {"world-encounter", "maj-eyal"},
	on_encounter = function(self, who)
		local x, y = self:findSpot(who)
		if not x then return end

		local g = game.level.map(x, y, engine.Map.TERRAIN):cloneFull()
		g.__nice_tile_base = nil
		g.name = "Golem Graveyard"
		g.kr_display_name = "골렘 공동묘지"
		g.display='>' g.color_r=0 g.color_g=200 g.color_b=0 g.notice = true
		g.change_level=1 g.change_zone="golem-graveyard" g.glow=true
		g.add_displays = g.add_displays or {}
		g.add_displays[#g.add_displays+1] = mod.class.Grid.new{image="npc/alchemist_golem.png", z=5}
		g.nice_tiler = nil
		g:initGlow()
		game.zone:addEntity(game.level, g, "terrain", x, y)
		print("[WORLDMAP] Golem Graveyard at", x, y)
		return true
	end,
}

newEntity{
	name = "Agrimley the Hermit",
	kr_display_name = "은둔자 아그림레이",
	type = "harmless", subtype = "special", unique = true,
	immediate = {"world-encounter", "brotherhood-alchemist"},
	-- Spawn the hermit
	on_encounter = function(self, who)
		local x, y = self:findSpot(who)
		if not x then return end

		local g = mod.class.WorldNPC.new{
			name="Agrimley the Hermit",
			kr_display_name = "은둔자 아그림레이",
			type="humanoid", subtype="human", faction="neutral",
			display='@', color=colors.BLUE,
			can_talk = "alchemist-hermit",
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
	kr_display_name = "피의 경기장",
	type = "harmless", subtype = "special", unique = true,
	immediate = {"world-encounter", "maj-eyal"},
	on_encounter = function(self, who)
		local x, y = self:findSpot(who)
		if not x then return end

		local g = game.level.map(x, y, engine.Map.TERRAIN):cloneFull()
		g.__nice_tile_base = nil
		g.name = "Hidden compound"
		g.kr_display_name = "숨겨진 수용소"
		g.display='>' g.color_r=200 g.color_g=0 g.color_b=0 g.notice = true
		g.change_level=1 g.change_zone="ring-of-blood" g.glow=true
		g.add_displays = g.add_displays or {}
		g.add_displays[#g.add_displays+1] = mod.class.Grid.new{image="terrain/cave_entrance_closed02.png", z=5}
		g.nice_tiler = nil
		g:initGlow()
		game.zone:addEntity(game.level, g, "terrain", x, y)
		print("[WORLDMAP] Hidden compound at", x, y)
		return true
	end,
}

newEntity{
	name = "Tranquil Meadow",
	kr_display_name = "고요한 목초지",
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
		g.__nice_tile_base = nil
		g.name = "tranquil meadow"
		g.kr_display_name = "고요한 목초지"
		g.display='>' g.color_r=0 g.color_g=255 g.color_b=128 g.notice = true
		g.change_level=1 g.change_zone="keepsake-meadow" g.glow=true
		g.add_displays = g.add_displays or {}
		g.add_displays[#g.add_displays+1] = mod.class.Grid.new{image="terrain/meadow.png", z=5}
		g.nice_tiler = nil
		g:initGlow()
		game.zone:addEntity(game.level, g, "terrain", x, y)
		print("[WORLDMAP] Keepsake: Tranquil Meadow at", x, y)
		return true
	end,
}
