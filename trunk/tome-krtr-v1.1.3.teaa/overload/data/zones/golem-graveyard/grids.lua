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
load("/data/general/grids/forest.lua")
load("/data/general/grids/water.lua")

newEntity{base="HARDWALL", define_as = "ATAMATHON_BROKEN",
	nice_tiler = false,
	display = 'g', color = colors.RED,
	image = "npc/atamathon_broken.png",
	resolvers.nice_tile{image="terrain/grass.png", add_displays = {class.new{z=18,image="npc/construct_golem_athamathon_the_giant_golem.png", display_y=-1, display_h=2}}},
	name = "the remains of Atamathon",
	kr_name = "아타마쏜의 잔해",
	show_tooltip = true,
	desc = [[이 거대 골렘은 장작더미의 시대 때 오크들과 전쟁을 하던 하플링들이 만들었지만, 포식자 가르쿨에 의해 파괴되었습니다.
몸은 대리석으로 만들었으며, 관절 부분은 보라툰을, 그 눈에는 가장 순수한 루비를 박아넣었지만, 눈 하나는 이미 사라지고 없는 것 같습니다. 골렘의 키는 12 미터에 육박합니다.
몇몇 어리석은 자들이 골렘의 재구축을 시도하였지만, 잃어버린 눈 없이는 진정으로 완성된 골렘을 만들어낼 수 없었습니다.]],
	dig = false,
	block_move = function(self, x, y, e, act, couldpass)
		if e and e.player and act then
			game.party:learnLore("broken-atamathon")
			local eye, eye_item = e:findInInventoryBy(e:getInven("INVEN"), "define_as", "ATAMATHON_ACTIVATE")
			if eye then
				require("engine.ui.Dialog"):yesnoPopup("아타마쏜", "당신이 가진 "..eye:getName{do_color=true}:addJosa("가").." 아타마쏜의 빈 눈에 딱 맞을 것 같아 보입니다. 아마 굉장히 어리석은 행동이겠지만...", function(ret)
					if not ret then return end
					if game.difficulty == game.DIFFICULTY_NIGHTMARE then
						game.zone.base_level = 50 * 1.5 + 3
					elseif game.difficulty == game.DIFFICULTY_INSANE then
						game.zone.base_level = 50 * 2.2 + 5
					elseif game.difficulty == game.DIFFICULTY_MADNESS then
						game.zone.base_level = 50 * 2.5 + 10
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

					game.log("#LIGHT_RED#보석을 집어넣자, 골렘이 흔들리기 시작합니다. 골렘의 모든 시스템과 마법이 다시 활성화됩니다.")
					game.log("#LIGHT_RED#아타마쏜이 다시 움직이기 시작하였지만, 통제가 되지 않습니다!")
					game.zone:addEntity(game.level, grass, "terrain", x, y)
					game.zone:addEntity(game.level, atamathon, "actor", x, y)
					atamathon:doEmote("방어 활성화. 공격 목표 설정. **파괴**!", 60)
					atamathon:setTarget(e)
				end, "보석을 넣어본다", "취소")
			end
		end
		return true
	end
}
