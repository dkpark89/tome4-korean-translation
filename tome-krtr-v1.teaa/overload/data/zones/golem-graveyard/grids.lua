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

load("/data/general/grids/basic.lua")
load("/data/general/grids/forest.lua")
load("/data/general/grids/water.lua")

newEntity{base="HARDWALL", define_as = "ATAMATHON_BROKEN",
	nice_tiler = false,
	display = 'g', color = colors.RED,
	image = "npc/atamathon_broken.png",
	resolvers.nice_tile{image="terrain/grass.png", add_displays = {class.new{z=18,image="npc/construct_golem_athamathon_the_giant_golem.png", display_y=-1, display_h=2}}},
	name = "the remains of Atamathon",
	kr_display_name = "아타마쏜의 잔해",
	show_tooltip = true,
	desc = [[이 거인 골렘은 장작더미의 시대에 하플링이 오크에 대항하기 위한 무기로 만들었지만 포식자 가르쿨에게 파괴되었다고 알려져 있습니다.
대리석으로 만들어진 몸에 단단한 보라툰으로 관절부위가 연결되고, 가장 순수한 루비가 눈으로 사용되었습니다. 다만, 한쪽 눈이 사라진 상태로 보입니다. 12미터가 넘는 키를 가졌습니다.
어떤 어리석은 이가 다시 재건하려 했지만, 한쪽 눈이 사라져 완성되지 못한 상태인 것 같습니다.]],
	dig = false,
	block_move = function(self, x, y, e, act, couldpass)
		if e and e.player and act then
			game.party:learnLore("broken-atamathon")
			local eye, eye_item = e:findInInventoryBy(e:getInven("INVEN"), "define_as", "ATAMATHON_ACTIVATE")
			if eye then
				require("engine.ui.Dialog"):yesnoPopup("아타마쏜", "당신이 가진 "..eye:getName{do_color=true}:addJosa("가").." 아타마쏜의 빈 눈에 딱 맞을 것 같아 보입니다. 이것은 아마 매우 어리석은 행동입니다.", function(ret)
					if not ret then return end
					if game.difficulty == game.DIFFICULTY_NIGHTMARE then
						game.zone.base_level = 50 * 1.5 + 3
					elseif game.difficulty == game.DIFFICULTY_INSANE then
						game.zone.base_level = 50 * 2.2 + 5
					else
						game.zone.base_level = 50
					end
					game.zone.min_material_level = 5
					game.zone.max_material_level = 5
					game.level.data.no_worldport = true
					local grass = game.zone:makeEntityByName(game.level, "terrain", "GRASS")
					local atamathon = game.zone:makeEntityByName(game.level, "actor", "ATAMATHON")
					if not grass or not atamathon then game.log("구멍이 망가져 있습니다.") return end

					e:removeObject(e:getInven("INVEN"), eye_item)

					game.log("#LIGHT_RED#보석을 집어넣자 골렘이 흔들리기 시작합니다. 그 모든 시스템과 마법이 다시 활성화됩니다.")
					game.log("#LIGHT_RED#아타마쏜이 다시 걷기 시작하지만, 제어는 되지 않습니다.")
					game.zone:addEntity(game.level, grass, "terrain", x, y)
					game.zone:addEntity(game.level, atamathon, "actor", x, y)
					atamathon:doEmote("방어 활성화. 공격 목표 설정. **파괴**!", 60)
					atamathon:setTarget(e)
				end, "삽입", "취소")
			end
		end
		return true
	end
}
