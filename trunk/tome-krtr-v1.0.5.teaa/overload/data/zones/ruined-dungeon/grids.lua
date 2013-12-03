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

load("/data/general/grids/basic.lua")

local loreprefix = ""
if currentZone.clues_layout == "ALT1" then loreprefix = "alt1-" end

for i = 1, 3 do
newEntity{
	define_as = "LORE"..i,
	name = "inscription", image = "terrain/maze_floor.png",
	kr_name = "비문",
	display = '_', color=colors.GREEN, back_color=colors.DARK_GREY,
	add_displays = {class.new{image="terrain/signpost.png"}},
	always_remember = true,
	notice = true,
	lore = loreprefix.."infinite-dungeon-"..i,
	on_move = function(self, x, y, who)
		if not who.player then return end
		game.party:learnLore(self.lore)
	end,
}
end

newEntity{ --@@ 한글화 필요 #42~55, kr_name 추가 필요
	define_as = "LORE4",
	name = "inscription", image = "terrain/maze_floor.png",
	display = '_', color=colors.GREEN, back_color=colors.DARK_GREY,
	add_displays = {class.new{image="terrain/signpost.png"}},
	always_remember = true,
	notice = true,
	lore = "infinite-dungeon-4",
	on_move = function(self, x, y, who)
		if not who.player then return end
		game:setAllowedBuild("campaign_infinite_dungeon", true)
		game.party:learnLore(self.lore)
	end,
}

newEntity{
	define_as = "INFINITE",
	name = "way into the infinite dungeon", image = "terrain/maze_floor.png", add_mos={{image = "terrain/stair_down.png"}},
	kr_name = "무한의 던전으로의 길",
	display = '>', color=colors.VIOLET, back_color=colors.DARK_GREY,
	always_remember = true,
	on_move = function(self, x, y, who)
		if not who.player then return end
		local p = game:getPlayer(true)
		if p.winner then
			require("engine.ui.Dialog"):yesnoLongPopup("무한의 던전", "당신은 굉장한 일을 해냈습니다. 하지만 한번 무한의 던전으로 들어가면, 다시는 이곳으로 돌아올 수 없으며 영광스러운 죽음을 맞이할 때까지 계속 앞으로 나아가야 합니다.", 400, function(ret)
				if ret then
					game:changeLevel(math.ceil(game.player.level * 1.5), "infinite-dungeon")
				end
			end, "입장", "취소")
		else
			require("engine.ui.Dialog"):simplePopup("무한의 던전", "한번 무한의 던전으로 들어가면, 다시는 이곳으로 돌아올 수 없습니다. 이곳에 오기 전에, 해야만 하는 일들을 모두 끝내는 것이 좋을 것 같습니다.")
		end
	end,
}

newEntity{
	define_as = "LOCK",
	name = "sealed door", image = "terrain/sealed_door.png",
	kr_name = "봉인된 문",
	display = '+', color=colors.WHITE, back_color=colors.DARK_UMBER,
	notice = true,
	always_remember = true,
	block_sight = true,
	does_block_move = true,
}

newEntity{
	define_as = "PORTAL",
	name = "orb", image = "terrain/maze_floor.png", add_displays={class.new{z=18, image = "terrain/pedestal_orb_04.png", display_h=2, display_y=-1}},
	kr_name = "오브",
	display = '*', color=colors.VIOLET, back_color=colors.DARK_GREY,
	force_clone=true,
	always_remember = true,
	notice = true,
	block_move = function(self, x, y, who, act, couldpass)
		if not who or not who.player or not act then return true end
		if not game.level.data.touch_orb then return true end

		if not self.orb_allowed then
			require("engine.ui.Dialog"):simplePopup("신비한 오브", "이 오브는 비활성화 상태인 것 같습니다.")
			return true
		end

		local text = "???"
		if self.portal_type == "water" then text = "오브에서 물방울이 떨어지는 것 같습니다."
		elseif self.portal_type == "earth" then text = "오브에 먼지가 쌓여 있습니다."
		elseif self.portal_type == "wind" then text = "오브가 허공에 떠있습니다."
		elseif self.portal_type == "nature" then text = "오브 안쪽에 작은 씨앗이 자라고 있는 것 같습니다."
		elseif self.portal_type == "arcane" then text = "오브에서 마법의 에너지가 소용돌이칩니다."
		elseif self.portal_type == "fire" then text = "오브에서 불꽃이 튀고 있습니다."

		elseif self.portal_type == "darkness" then text = "The orb seems to absorb all light." --@@ 한글화 필요
		elseif self.portal_type == "blood" then text = "The orb is drips with thick blood." --@@ 한글화 필요
		elseif self.portal_type == "grave" then text = "The orb smells like a rotten corpse." --@@ 한글화 필요
		elseif self.portal_type == "time" then text = "Time seems to slow down around the orb." --@@ 한글화 필요
		elseif self.portal_type == "mind" then text = "Your mind is filled with strange thoughts as you approach the orb." --@@ 한글화 필요
		elseif self.portal_type == "blight" then text = "The orb seems to corrupt all it touches." --@@ 한글화 필요
		end
		require("engine.ui.Dialog"):yesnoLongPopup("신비한 오브", text.."\n건드려 봅니까?", 400, function(ret)
			if ret then
				game.level.data.touch_orb(self.portal_type, x, y)
			end
		end, "예", "아니오")
		return true
	end,
}
