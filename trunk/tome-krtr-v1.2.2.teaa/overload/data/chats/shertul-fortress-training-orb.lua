﻿-- ToME - Tales of Maj'Eyal
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

local function dummies(nb) return function()
	local _, list = game.level:pickSpot{type="training", subtype="training"}
	list = table.clone(list, true)

	for i = 1, nb do
		local dummy = game.zone:makeEntityByName(game.level, "actor", "TRAINING_DUMMY")
		local spot = rng.tableRemove(list)
		game.zone:addEntity(game.level, dummy, "actor", spot.x, spot.y)
		game.level.map:particleEmitter(spot.x, spot.y, 1, "teleport")
	end
	local camera = game.level:pickSpot{type="camera", subtype="trainingroom"}
	game.level.map:centerViewAround(camera.x, camera.y)

	game.zone.training_dummies = game.zone.training_dummies or {
		total = 0,
		damtypes = {},
	}
end end

local function remove_dummies()
	game.zone.training_dummies = nil

	local todel = {}
	for uid, e in pairs(game.level.entities) do
		if e.define_as == "TRAINING_DUMMY" then todel[#todel+1] = e end
	end
	for i, e in ipairs(todel) do
		e:disappear()
	end
end

local function resist_dummies()
	local GetQuantity = require "engine.dialogs.GetQuantity"
	game:registerDialog(GetQuantity.new("전체 저항력", "0에서 100까지", 0, 100, function(qty)
		qty = util.bound(qty, 0, 100)
		for uid, e in pairs(game.level.entities) do
			if e.define_as == "TRAINING_DUMMY" then e.resists.all = qty end
		end
	end, 1))
end

local function armor_dummies()
	local GetQuantity = require "engine.dialogs.GetQuantity"
	game:registerDialog(GetQuantity.new("방어 효율", "0에서 100까지", 0, 100, function(qty)
		qty = util.bound(qty, 0, 100)
		for uid, e in pairs(game.level.entities) do
			if e.define_as == "TRAINING_DUMMY" then e.combat_armor_hardiness = qty - 30 end
		end

		game:registerDialog(GetQuantity.new("방어도", "0에서 1000까지", 0, 1000, function(qty)
			qty = util.bound(qty, 0, 1000)
			for uid, e in pairs(game.level.entities) do
				if e.define_as == "TRAINING_DUMMY" then e.combat_armor = qty end
			end
		end, 1))
	end, 1))
end

newChat{ id="welcome",
	text = [[*#LIGHT_GREEN#이 오브는 연습 설비를 통제할 때 사용됩니다.#WHITE#*]],
	answers = {
		{"[연습용 허수아비 한 개 생성]", action=dummies(1)},
		{"[연습용 허수아비 두 개 생성]", action=dummies(2)},
		{"[연습용 허수아비 세 개 생성]", action=dummies(3)},
		{"[연습용 허수아비 다섯 개 생성]", action=dummies(5)},
		{"[연습용 허수아비 열 개 생성]", action=dummies(10)},
		{"[연습용 허수아비의 방어 수준 설정]", action=armor_dummies},
		{"[연습용 허수아비의 저항력 설정]", action=resist_dummies},
		{"[초기화]", action=remove_dummies},
		{"[오브를 놔두고 떠난다]"},
	}
}

return "welcome"
