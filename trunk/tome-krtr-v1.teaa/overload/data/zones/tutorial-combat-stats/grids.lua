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

load("/data/general/grids/basic.lua")
load("/data/general/grids/forest.lua")
load("/data/general/grids/water.lua")
load("/data/general/grids/lava.lua")
load("/data/general/grids/mountain.lua")
load("/data/general/grids/cave.lua")
load("/data/general/grids/fortress.lua")

newEntity{
	define_as = "PORTAL_BACK",
	name = "Lobby Portal", image = "terrain/grass.png", add_displays = {class.new{image = "trap/trap_teleport_01.png"}},
	kr_display_name = "로비로의 관문",
	display = '&', color_r=255, color_g=0, color_b=220, back_color=colors.VIOLET,
	notice = true,
	always_remember = true,
	show_tooltip = true,
	desc = [[This portal will bring you back to the Tutorial Lobby.]],

	on_move = function(self, x, y, who)
		if who == game.player then
			require("engine.ui.Dialog"):yesnoPopup("연습게임 로비로의 관문", "관문으로 들어가 로비로 돌아갑니까?", function(ret)
				if not ret then
					--game:onLevelLoad("wilderness-1", function(zone, level)
					--	local spot = level:pickSpot{type="farportal-end", subtype="demon-plane-arrival"}
					--	who.wild_x, who.wild_y = spot.x, spot.y
					--end)
					game:changeLevel(1, "tutorial")
					game.logPlayer(who, "#VIOLET#당신은 소용돌이치는 관문으로 들어갔고, 눈을 깜박이자 로비로 돌아온 것을 알아차립니다.")
				end
			end, "머물기", "들어가기")
		end
	end,
}

newEntity{
	define_as = "PORTAL_BACK_2",
	name = "Lobby Portal", image = "terrain/solidwall/solid_floor1.png", add_displays = {class.new{image = "trap/trap_teleport_01.png"}},
	kr_display_name = "로비로의 관문",
	display = '&', color_r=255, color_g=0, color_b=220, back_color=colors.VIOLET,
	notice = true,
	always_remember = true,
	show_tooltip = true,
	desc = [[This portal will bring you back to the Tutorial Lobby.]],

	on_move = function(self, x, y, who)
		if who == game.player then
			require("engine.ui.Dialog"):yesnoPopup("연습게임 로비로의 관문", "관문으로 들어가 로비로 돌아갑니까?", function(ret)
				if not ret then
					--game:onLevelLoad("wilderness-1", function(zone, level)
					--	local spot = level:pickSpot{type="farportal-end", subtype="demon-plane-arrival"}
					--	who.wild_x, who.wild_y = spot.x, spot.y
					--end)
					game:changeLevel(1, "tutorial")
					game.logPlayer(who, "#VIOLET#당신은 소용돌이치는 관문으로 들어갔고, 눈을 깜박이자 로비로 돌아온 것을 알아차립니다.")
				end
			end, "머물기", "들어가기")
		end
	end,
}

newEntity{
	define_as = "SQUARE_GRASS",
	type = "floor", subtype = "grass",
	name = "grass", image = "terrain/grass.png",
	kr_display_name = "풀밭",
	display = '.', color=colors.LIGHT_GREEN, back_color={r=44,g=95,b=43},
	grow = "TREE",
	--nice_tiler = { method="replace", base={"GRASS_PATCH", 70, 1, 12}},
	--nice_editer = grass_editer,
}

newEntity{ base="WATER_BASE",
	define_as = "TUTORIAL_WATER",
	image="terrain/water_grass_5_1.png",
	air_level = -5, air_condition="water",
	does_block_move = true,
	pass_projectile = true,
}

newEntity{
	define_as = "SIGN",
	name = "Sign",
	kr_display_name = "표지",
	desc = [[단편적인 ToME 지식을 담고 있습니다.]],
	image = "terrain/grass.png",
	display = '_', color=colors.UMBER, back_color=colors.DARK_GREEN,
	add_displays = {class.new{image="terrain/signpost.png"}},
	always_remember = true,
}


newEntity{
	define_as = "SIGN_FLOOR",
	name = "Sign",
	kr_display_name = "표지",
	desc = [[단편적인 ToME 지식을 담고 있습니다.]],
	image = "terrain/marble_floor.png",
	display = '_', color=colors.UMBER, back_color=colors.DARK_GREEN,
	add_displays = {class.new{image="terrain/signpost.png"}},
	always_remember = true,
}

newEntity{
	define_as = "SIGN_CAVE",
	name = "Sign",
	kr_display_name = "표지",
	desc = [[단편적인 ToME 지식을 담고 있습니다.]],
	image = "terrain/cave/cave_floor_1_01.png",
	display = '_', color=colors.UMBER, back_color=colors.DARK_GREEN,
	add_displays = {class.new{image="terrain/signpost.png"}},
	always_remember = true,
}

newEntity{
	define_as = "SIGN_SOLID_FLOOR",
	name = "Sign",
	kr_display_name = "표지",
	desc = [[단편적인 ToME 지식을 담고 있습니다.]],
	image = "terrain/solidwall/solid_floor1.png",
	display = '_', color=colors.UMBER, back_color=colors.DARK_GREEN,
	add_displays = {class.new{image="terrain/signpost.png"}},
	always_remember = true,
}

newEntity{
	define_as = "UNLEARN_ALL",
	name = "Rune of Enlightenment: Summer Vacation",
	kr_display_name = "깨달음의 룬: 여름 휴가",
	desc = [[캐릭터의 두뇌에서 최근에 획득한 지식을 모두 없애 버립니다.]],
	image = "terrain/cave/cave_floor_1_01.png",
	display = '*', color=colors.VIOLET, back_color=colors.DARK_GREEN,
	add_displays = {class.new{image = "trap/trap_lethargy_rune_01.png"}},
	always_remember = true,
	on_move = function(self, x, y, actor, forced)
		if not actor.player then return end
		if forced then return end
		game.level.map:particleEmitter(x, y, 1, "teleport")
		game.logPlayer(actor, "#VIOLET#당신의 머리가 비는것을 느낍니다.")
		if actor:knowTalent(actor.T_TUTORIAL_PHYS_KB) then
			actor:unlearnTalent(actor.T_TUTORIAL_PHYS_KB)
		end
		if actor:knowTalent(actor.T_TUTORIAL_SPELL_KB) then
			actor:unlearnTalent(actor.T_TUTORIAL_SPELL_KB)
		end
		if actor:knowTalent(actor.T_TUTORIAL_MIND_KB) then
			actor:unlearnTalent(actor.T_TUTORIAL_MIND_KB)
		end
		if actor:knowTalent(actor.T_TUTORIAL_SPELL_BLINK) then
			actor:unlearnTalent(actor.T_TUTORIAL_SPELL_BLINK)
		end
		if actor:knowTalent(actor.T_TUTORIAL_MIND_FEAR) then
			actor:unlearnTalent(actor.T_TUTORIAL_MIND_FEAR)
		end
		actor:unlearnTalent(actor.T_TUTORIAL_MIND_CONFUSION)
		actor:unlearnTalent(actor.T_TUTORIAL_SPELL_BLEED)

	end,
}


newEntity{
	define_as = "LEARN_PHYS_KB",
	name = "Rune of Enlightenment: Shove",
	kr_display_name = "깨달음의 룬: 밀치기",
	desc = [[캐릭터에게 '밀치기'를 가르쳐 줍니다.]],
	image = "terrain/cave/cave_floor_1_01.png",
	display = '*', color=colors.VIOLET, back_color=colors.DARK_GREEN,
	add_displays = {class.new{image = "trap/blast_acid01.png"}},
	always_remember = true,
	on_move = function(self, x, y, actor, forced)
		if not actor.player then return end
		if forced then return end
		local q = actor:hasQuest("tutorial-combat-stats")
		if q and not actor:knowTalent(actor.T_TUTORIAL_PHYS_KB) then
			actor:learnTalent(game.player.T_TUTORIAL_PHYS_KB, true, 1)
			game.level.map:particleEmitter(x, y, 1, "teleport")
			game.logPlayer(actor, "#VIOLET#당신은 밀치기 기술을 배웠습니다.")
			if actor:knowTalent(actor.T_TUTORIAL_SPELL_KB) then
				actor:unlearnTalent(actor.T_TUTORIAL_SPELL_KB)
			end
			if actor:knowTalent(actor.T_TUTORIAL_MIND_KB) then
				actor:unlearnTalent(actor.T_TUTORIAL_MIND_KB)
			end
			if actor:knowTalent(actor.T_TUTORIAL_SPELL_BLINK) then
				actor:unlearnTalent(actor.T_TUTORIAL_SPELL_BLINK)
			end
			if actor:knowTalent(actor.T_TUTORIAL_MIND_FEAR) then
				actor:unlearnTalent(actor.T_TUTORIAL_MIND_FEAR)
			end
			if q and not q:isCompleted("learn_phys_kb") then
				game.logPlayer(actor, "#VIOLET#고대의 문이 갈리면서 열리는 메아리 소리가 아래쪽 터널로 울립니다!")
				local spot = game.level:pickSpot{type="door", subtype="sealed"}
				local g = game.zone:makeEntityByName(game.level, "terrain", "DOOR_OPEN")
				game.zone:addEntity(game.level, g, "terrain", spot.x, spot.y)
				actor:setQuestStatus("tutorial-combat-stats", engine.Quest.COMPLETED, "learn_phys_kb")
			end
		end
	end,
}

newEntity{
	define_as = "LEARN_SPELL_KB",
	name = "Rune of Enlightenment: Mana Gale",
	kr_display_name = "깨달음의 룬: 마력 돌풍",
	desc = [[캐릭터에게 '마력 돌풍'을 가르쳐 줍니다.]],
	image = "terrain/cave/cave_floor_1_01.png",
	display = '*', color=colors.VIOLET, back_color=colors.DARK_GREEN,
	add_displays = {class.new{image = "trap/blast_fire01.png"}},
	always_remember = true,
	on_move = function(self, x, y, actor, forced)
		if not actor.player then return end
		if forced then return end
		local q = actor:hasQuest("tutorial-combat-stats")
		if q and not actor:knowTalent(actor.T_TUTORIAL_SPELL_KB) then
			actor:learnTalent(game.player.T_TUTORIAL_SPELL_KB, true, 1)
			game.level.map:particleEmitter(x, y, 1, "teleport")
			game.logPlayer(actor, "#VIOLET#당신은 마력 돌풍 기술을 배웠습니다.")
			if actor:knowTalent(actor.T_TUTORIAL_PHYS_KB) then
				actor:unlearnTalent(actor.T_TUTORIAL_PHYS_KB)
			end
			if actor:knowTalent(actor.T_TUTORIAL_MIND_KB) then
				actor:unlearnTalent(actor.T_TUTORIAL_MIND_KB)
			end
			if actor:knowTalent(actor.T_TUTORIAL_SPELL_BLINK) then
				actor:unlearnTalent(actor.T_TUTORIAL_SPELL_BLINK)
			end
			if actor:knowTalent(actor.T_TUTORIAL_MIND_FEAR) then
				actor:unlearnTalent(actor.T_TUTORIAL_MIND_FEAR)
			end
		end
	end,
}

newEntity{
	define_as = "LEARN_SPELL_KB3",
	name = "Rune of Enlightenment: Mana Gale",
	kr_display_name = "깨달음의 룬: 마력 돌풍",
	desc = [[캐릭터에게 '마력 돌풍'을 가르쳐 줍니다.]],
	image = "terrain/cave/cave_floor_1_01.png",
	display = '*', color=colors.VIOLET, back_color=colors.DARK_GREEN,
	add_displays = {class.new{image = "trap/blast_fire01.png"}},
	always_remember = true,
	on_move = function(self, x, y, actor, forced)
		if not actor.player then return end
		if forced then return end
		local q = actor:hasQuest("tutorial-combat-stats")
		if q and not actor:knowTalent(actor.T_TUTORIAL_SPELL_KB) then
			actor:learnTalent(game.player.T_TUTORIAL_SPELL_KB, true, 3)
			game.level.map:particleEmitter(x, y, 1, "teleport")
			game.logPlayer(actor, "#VIOLET#당신은 마력 돌풍 기술을 배웠습니다.")
			if actor:knowTalent(actor.T_TUTORIAL_PHYS_KB) then
				actor:unlearnTalent(actor.T_TUTORIAL_PHYS_KB)
			end
			if actor:knowTalent(actor.T_TUTORIAL_MIND_KB) then
				actor:unlearnTalent(actor.T_TUTORIAL_MIND_KB)
			end
			if actor:knowTalent(actor.T_TUTORIAL_SPELL_BLINK) then
				actor:unlearnTalent(actor.T_TUTORIAL_SPELL_BLINK)
			end
			if actor:knowTalent(actor.T_TUTORIAL_MIND_FEAR) then
				actor:unlearnTalent(actor.T_TUTORIAL_MIND_FEAR)
			end
		end
	end,
}

newEntity{
	define_as = "LEARN_MIND_KB",
	name = "Rune of Enlightenment: Telekinetic Punt",
	kr_display_name = "깨달음의 룬: 염동력 주먹",
	desc = [[캐릭터에게 '염동력 주먹'을 가르쳐 줍니다.]],
	image = "terrain/cave/cave_floor_1_01.png",
	display = '*', color=colors.VIOLET, back_color=colors.DARK_GREEN,
	add_displays = {class.new{image = "trap/blast_ice01.png"}},
	always_remember = true,
	on_move = function(self, x, y, actor, forced)
		if not actor.player then return end
		if forced then return end
		local q = actor:hasQuest("tutorial-combat-stats")
		if q and not actor:knowTalent(actor.T_TUTORIAL_MIND_KB) then
			actor:learnTalent(game.player.T_TUTORIAL_MIND_KB, true, 1)
			game.level.map:particleEmitter(x, y, 1, "teleport")
			game.logPlayer(actor, "#VIOLET#당신은 염동력 주먹 기술을 배웠습니다.")
			if actor:knowTalent(actor.T_TUTORIAL_PHYS_KB) then
				actor:unlearnTalent(actor.T_TUTORIAL_PHYS_KB)
			end
			if actor:knowTalent(actor.T_TUTORIAL_SPELL_KB) then
				actor:unlearnTalent(actor.T_TUTORIAL_SPELL_KB)
			end
			if actor:knowTalent(actor.T_TUTORIAL_SPELL_BLINK) then
				actor:unlearnTalent(actor.T_TUTORIAL_SPELL_BLINK)
			end
			if actor:knowTalent(actor.T_TUTORIAL_MIND_FEAR) then
				actor:unlearnTalent(actor.T_TUTORIAL_MIND_FEAR)
			end
		end
	end,
}


newEntity{
	define_as = "LEARN_SPELL_BLINK",
	name = "Rune of Enlightenment: Blink",
	kr_display_name = "깨달음의 룬: 단거리 순간이동",
	desc = [[캐릭터에게 '단거리 순간이동'을 가르쳐 줍니다.]],
	image = "terrain/cave/cave_floor_1_01.png",
	display = '*', color=colors.VIOLET, back_color=colors.DARK_GREEN,
	add_displays = {class.new{image = "trap/blast_lightning01.png"}},
	always_remember = true,
	on_move = function(self, x, y, actor, forced)
		if not actor.player then return end
		if forced then return end
		local q = actor:hasQuest("tutorial-combat-stats")
		if not actor:knowTalent(actor.T_TUTORIAL_SPELL_BLINK) then
			actor:learnTalent(game.player.T_TUTORIAL_SPELL_BLINK, true, 1)
			game.level.map:particleEmitter(x, y, 1, "teleport")
			game.logPlayer(actor, "#VIOLET#당신은 단거리 순간이동 기술을 배웠습니다.")
			if actor:knowTalent(actor.T_TUTORIAL_PHYS_KB) then
				actor:unlearnTalent(actor.T_TUTORIAL_PHYS_KB)
			end
			if actor:knowTalent(actor.T_TUTORIAL_SPELL_KB) then
				actor:unlearnTalent(actor.T_TUTORIAL_SPELL_KB)
			end
			if actor:knowTalent(actor.T_TUTORIAL_MIND_KB) then
				actor:unlearnTalent(actor.T_TUTORIAL_MIND_KB)
			end
			if actor:knowTalent(actor.T_TUTORIAL_MIND_FEAR) then
				actor:unlearnTalent(actor.T_TUTORIAL_MIND_FEAR)
			end
		end
	end,
}

newEntity{
	define_as = "LEARN_MIND_FEAR",
	name = "Rune of Enlightenment: Fear",
	kr_display_name = "깨달음의 룬: 공포",
	desc = [[캐릭터에게 '공포'를 가르쳐 줍니다.]],
	image = "terrain/cave/cave_floor_1_01.png",
	display = '*', color=colors.VIOLET, back_color=colors.DARK_GREEN,
	add_displays = {class.new{image = "trap/trap_poison_burst_01.png"}},
	always_remember = true,
	on_move = function(self, x, y, actor, forced)
		if not actor.player then return end
		if forced then return end
		local q = actor:hasQuest("tutorial-combat-stats")
		if not actor:knowTalent(actor.T_TUTORIAL_MIND_FEAR) then
			actor:learnTalent(game.player.T_TUTORIAL_MIND_FEAR, true, 1)
			game.level.map:particleEmitter(x, y, 1, "teleport")
			game.logPlayer(actor, "#VIOLET#당신은 공포 기술을 배웠습니다.")
			if actor:knowTalent(actor.T_TUTORIAL_PHYS_KB) then
				actor:unlearnTalent(actor.T_TUTORIAL_PHYS_KB)
			end
			if actor:knowTalent(actor.T_TUTORIAL_SPELL_KB) then
				actor:unlearnTalent(actor.T_TUTORIAL_SPELL_KB)
			end
			if actor:knowTalent(actor.T_TUTORIAL_MIND_KB) then
				actor:unlearnTalent(actor.T_TUTORIAL_MIND_KB)
			end
			if actor:knowTalent(actor.T_TUTORIAL_SPELL_BLINK) then
				actor:unlearnTalent(actor.T_TUTORIAL_SPELL_BLINK)
			end
		end
	end,
}

newEntity{
	define_as = "LEARN_SPELL_BLEED",
	name = "Rune of Enlightenment: Bleed",
	kr_display_name = "깨달음의 룬: 출혈",
	desc = [[캐릭터에게 '출혈'을 가르쳐 줍니다.]],
	image = "terrain/cave/cave_floor_1_01.png",
	display = '*', color=colors.VIOLET, back_color=colors.DARK_GREEN,
	add_displays = {class.new{image = "trap/trap_magical_disarm_01_64.png"}},
	always_remember = true,
	on_move = function(self, x, y, actor, forced)
		if not actor.player then return end
		if forced then return end
		if not actor:knowTalent(actor.T_TUTORIAL_SPELL_BLEED) then
			actor:learnTalent(game.player.T_TUTORIAL_SPELL_BLEED, true, 1)
			game.level.map:particleEmitter(x, y, 1, "teleport")
			game.logPlayer(actor, "#VIOLET#당신은 출혈 기술을 배웠습니다.")
		end
		if actor:knowTalent(actor.T_TUTORIAL_MIND_CONFUSION) then
			actor:unlearnTalent(actor.T_TUTORIAL_MIND_CONFUSION)
		end
	end,
}

newEntity{
	define_as = "LEARN_MIND_CONFUSION",
	name = "Rune of Enlightenment: Confusion",
	kr_display_name = "깨달음의 룬: 혼란",
	desc = [[캐릭터에게 '혼란'을 가르쳐 줍니다.]],
	image = "terrain/cave/cave_floor_1_01.png",
	display = '*', color=colors.VIOLET, back_color=colors.DARK_GREEN,
	add_displays = {class.new{image = "trap/trap_teleport_01.png"}},
	always_remember = true,
	on_move = function(self, x, y, actor, forced)
		if not actor.player then return end
		if forced then return end
		if not actor:knowTalent(actor.T_TUTORIAL_MIND_CONFUSION) then
			actor:learnTalent(game.player.T_TUTORIAL_MIND_CONFUSION, true, 1)
			game.level.map:particleEmitter(x, y, 1, "teleport")
			game.logPlayer(actor, "#VIOLET#당신은 혼란 기술을 배웠습니다.")
		end
		if actor:knowTalent(actor.T_TUTORIAL_SPELL_BLEED) then
			actor:unlearnTalent(actor.T_TUTORIAL_SPELL_BLEED)
		end
	end,
}

newEntity{
	define_as = "MAGIC_DOOR",
	type = "wall", subtype = "floor",
	name = "glowing door", image = "terrain/granite_door1.png",
	kr_display_name = "빛나는 문",
	display = '+', color_r=238, color_g=154, color_b=77, back_color=colors.DARK_UMBER,
	--nice_tiler = { method="door3d", north_south="DOOR_VERT", west_east="DOOR_HORIZ" },
	notice = true,
	always_remember = true,
	block_sight = true,
	does_block_move = true,
	is_door = true,
	
--[=[	on_move = function(self, x, y, actor, forced) 
		if not actor.player then return end
		if forced then return end
		local q = game.player:hasQuest("tutorial")
		if q and q:isCompleted("learn_phys_kb") then
			local f = game.zone:makeEntityByName(game.level, "terrain", "DOOR_OPEN")
			game.zone:addEntity(game.level, f, "terrain", x, y)
			game.nicer_tiles:updateAround(game.level, x, y)
		else
			game.logPlayer(game.player, "#VIOLET#여기를 지나가기 전에, 필요한 깨달음을 얻어야 합니다. 서쪽으로 가서 밀치기 기술을 찾아 보세요.")
		end
	end,]=]
	door_opened = function(self, x, y, actor, forced) 
		if not actor.player then return end
		if forced then return end
		local q = game.player:hasQuest("tutorial-combat-stats")
		if q and q:isCompleted("learn_phys_kb") then
			return "DOOR_OPEN"
		else
			game.logPlayer(game.player, "#VIOLET#여기를 지나가기 전에, 필요한 깨달음을 얻어야 합니다. 서쪽으로 가서 밀치기 기술을 찾아 보세요.")
		end
	end,
}

newEntity{
	define_as = "LOCK",
	name = "sealed door", image = "terrain/granite_door1.png",
	kr_display_name = "봉인된 문",
	display = '+', color=colors.WHITE, back_color=colors.DARK_UMBER,
	notice = true,
	always_remember = true,
	block_sight = true,
	does_block_move = true,
}

newEntity{
	define_as = "FINAL_LESSON",
	name = "Sign",
	kr_display_name = "표지",
	desc = [[단편적인 ToME 지식을 담고 있습니다.]],
	image = "terrain/cave/cave_floor_1_01.png",
	display = '_', color=colors.UMBER, back_color=colors.DARK_GREEN,
	add_displays = {class.new{image="terrain/signpost.png"}},
	always_remember = true,
	on_move = function(self, x, y, actor, forced)
		if not actor.player then return end
		if forced then return end
		local q = actor:hasQuest("tutorial-combat-stats")
		if q and not q:isCompleted("final-lesson") then
			actor:setQuestStatus("tutorial-combat-stats", engine.Quest.COMPLETED, "final-lesson")
		end
	end,
}

newEntity{
	define_as = "COMBAT_STATS_DONE",
	name = "Sign",
	kr_display_name = "표지",
	desc = [[단편적인 ToME 지식을 담고 있습니다.]],
	image = "terrain/solidwall/solid_floor1.png",
	display = '_', color=colors.UMBER, back_color=colors.DARK_GREEN,
	add_displays = {class.new{image="terrain/signpost.png"}},
	always_remember = true,
	on_move = function(self, x, y, actor, forced)
		if not actor.player then return end
		if forced then return end
		local q = actor:hasQuest("tutorial-combat-stats")
		if q and not q:isCompleted("finished-combat-stats") then
			actor:setQuestStatus("tutorial-combat-stats", engine.Quest.COMPLETED, "finished-combat-stats")
			--q:final_message()
		end
	end,
}
