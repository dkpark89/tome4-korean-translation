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

load("/data/general/grids/basic.lua")
load("/data/general/grids/jungle.lua")
load("/data/general/grids/slime.lua")

local orb_activate = function(self, x, y, who, act, couldpass)
	if not who or not who.player or not act then return false end
	if self.orbed then return false end

	local owner, orb = game.party:findInAllPartyInventoriesBy("define_as", self.define_as)

	if not orb then
		require("engine.ui.Dialog"):simplePopup("이상한 받침대", "이 받침대는 오래된 것으로 보입니다. 그 표면에 어떤 모양의 오브가 새겨져 있는 것이 보입니다.")
	else
		require("engine.ui.Dialog"):yesnoLongPopup("이상한 받침대", "받침대는 당신의 가방 속에 있는 어떤 소지품과 반응하고 있는 것 같습니다. 몇가지 실험 결과로 이 것이 "..tostring(orb:getName{do_color=true}:addJosa("와")).." 반응하고 있는 것을 발견했습니다.\n오브를 받침대에 사용합니까?", 400, function(ret)
			if ret then game.player:useCommandOrb(orb, x, y) end
		end, "예", "아니오")
	end
	return false
end

local orb_summon = function(self, who)
	local filter = self.summon
	local npc = game.zone:makeEntity(game.level, "actor", filter, nil, true)
	local nx, ny = util.findFreeGrid(who.x, who.y, 10, true, {[engine.Map.ACTOR]=true})
	if npc and nx then
		game.zone:addEntity(game.level, npc, "actor", nx, ny)
	end
end

newEntity{
	define_as = "ORB_DRAGON",
	name = "orb pedestal (dragon)", special = true, image = "terrain/slime/slime_floor_01.png", add_displays={class.new{image = "terrain/pedestal_01.png", display_h=2, display_y=-1}},
	kr_name = "오브의 받침대 (용)",
	display = '_', color_r=255, color_g=255, color_b=255, back_color=colors.LIGHT_RED,
	always_remember = true,
	notice = true,
	once_used_image = "terrain/pedestal_orb_03.png",
	orb_command = {
		continue = true,
		summon = {
			base_list="mod.class.NPC:/data/general/npcs/multihued-drake.lua",
			type="dragon", subtype="multihued", name="greater multi-hued wyrm", --@ 번역하는 부분 아님
			random_boss = {name_scheme="#rng# the Fearsome", class_filter=function(d) return d.name == "Archmage" end}, --@ 번역하는 부분 아님
			add_levels = 12,
		},
		special = orb_summon,
	},
	block_move = orb_activate,
}
newEntity{
	define_as = "ORB_UNDEATH",
	name = "orb pedestal (undeath)", special = true, image = "terrain/slime/slime_floor_01.png", add_displays={class.new{image = "terrain/pedestal_01.png", display_h=2, display_y=-1}},
	kr_name = "오브의 받침대 (역생)",
	display = '_', color_r=255, color_g=255, color_b=255, back_color=colors.LIGHT_RED,
	always_remember = true,
	notice = true,
	once_used_image = "terrain/pedestal_orb_05.png",
	orb_command = {
		continue = true,
		summon = {
			base_list="mod.class.NPC:/data/general/npcs/lich.lua",
			type="undead", subtype="lich", name="archlich", --@ 번역하는 부분 아님
			random_boss = {name_scheme="#rng# the Neverdead", class_filter=function(d) return d.name == "Necromancer" end}, --@ 번역하는 부분 아님
			add_levels = 12,
		},
		special = orb_summon,
	},
	block_move = orb_activate,
}
newEntity{
	define_as = "ORB_ELEMENTS",
	name = "orb pedestal (elements)", special = true, image = "terrain/slime/slime_floor_01.png", add_displays={class.new{image = "terrain/pedestal_01.png", display_h=2, display_y=-1}},
	kr_name = "오브의 받침대 (정령)",
	display = '_', color_r=255, color_g=255, color_b=255, back_color=colors.LIGHT_RED,
	always_remember = true,
	notice = true,
	once_used_image = "terrain/pedestal_orb_04.png",
	orb_command = {
		continue = true,
		summon = {
			base_list="mod.class.NPC:/data/general/npcs/gwelgoroth.lua",
			type="elemental", subtype="air", name="ultimate gwelgoroth", --@ 번역하는 부분 아님
			random_boss = {name_scheme="#rng# the Silent Death", class_filter=function(d) return d.name == "Shadowblade" end}, --@ 번역하는 부분 아님
			add_levels = 12,
		},
		special = orb_summon,
	},
	block_move = orb_activate,
}
newEntity{
	define_as = "ORB_DESTRUCTION",
	name = "orb pedestal (destruction)", special = true, image = "terrain/slime/slime_floor_01.png", add_displays={class.new{image = "terrain/pedestal_01.png", display_h=2, display_y=-1}},
	kr_name = "오브의 받침대 (파괴)",
	display = '_', color_r=255, color_g=255, color_b=255, back_color=colors.LIGHT_RED,
	always_remember = true,
	notice = true,
	once_used_image = "terrain/pedestal_orb_02.png",
	orb_command = {
		continue = true,
		summon = {
			base_list="mod.class.NPC:/data/general/npcs/major-demon.lua",
			type="demon", subtype="major", name="forge-giant", --@ 번역하는 부분 아님
			random_boss = {name_scheme="#rng# the Crusher", class_filter=function(d) return d.name == "Corruptor" end}, --@ 번역하는 부분 아님
			add_levels = 12,
		},
		special = orb_summon,
	},
	block_move = orb_activate,
}

newEntity{ base = "SLIME_DOOR_VERT",
	define_as = "PEAK_DOOR",
	name = "sealed door",
	kr_name = "봉인된 문",
	is_door = true,
	door_opened = false,
	nice_tiler = false,
	does_block_move = true,
}

newEntity{
	define_as = "PEAK_STAIR",
	always_remember = true,
	show_tooltip=true,
	name="Entrance to the High Peak",
	kr_name = "최고봉으로의 입구",
	display='>', color=colors.VIOLET, image = "terrain/stair_up_wild.png",
	notice = true,
	change_level=1, change_zone="high-peak",
	change_level_check = function()
		require("engine.ui.Dialog"):yesnoLongPopup("최고봉", '계단에 올라서자, 이 것은 "성공이나 죽음"을 향한 일방통행임이 느껴집니다. 들어가면 돌아나올 수 있는 길이 없습니다.\n들어갑니까?', 500, function(ret) if ret then
			game:changeLevel(1, "high-peak")
		end end, "예", "아니오")
		return true
	end,
}

newEntity{ base = "SLIME_UP",
	define_as = "UP_GRUSHNAK",
	name = "exit to Grushnak Pride",
	kr_name = "그루쉬낙 긍지로의 출구",
	change_level = 6,
	change_zone = "grushnak-pride",
	force_down = true,
}
