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

load("/data/general/objects/objects-maj-eyal.lua")

local Stats = require "engine.interface.ActorStats"

newEntity{ base = "BASE_GEM",
	define_as = "RESONATING_DIAMOND_WEST2",
	name = "Resonating Diamond", color=colors.VIOLET, quest=true, unique="Resonating Diamond West2", identified=true, no_unique_lore=true,
	kr_name = "공명하는 다이아몬드",
	image = "object/artifact/resonating_diamond.png",
	material_level = 5,

	on_drop = function(self, who)
		if who == game.player then
			game.logPlayer(who, "당신은 %s 버릴 수 없습니다", self:getName():addJosa("를"))
			return true
		end
	end,
	on_pickup = function(self, who)
		if who == game.player then
			game.player:resolveSource():setQuestStatus("east-portal", engine.Quest.COMPLETED, "diamon-back")
		end
	end,
}

newEntity{ define_as = "ATHAME_WEST2",
	quest=true, unique="Blood-Runed Athame West2", identified=true, no_unique_lore=true,
	type = "misc", subtype="misc",
	unided_name = "athame",
	name = "Blood-Runed Athame", image = "object/artifact/blood_runed_athame.png",
	kr_name = "피의 룬 제례단검", kr_unided_name = "제례단검",
	level_range = {50, 50},
	display = "|", color=colors.VIOLET,
	encumber = 1,
	desc = [[피의 룬이 새겨진 제례단검입니다. 힘을 내뿜고 있습니다.]],

	on_drop = function(self, who)
		if who == game.player then
			game.logPlayer(who, "당신은 %s 버릴 수 없습니다", self:getName():addJosa("를"))
			return true
		end
	end,
	on_pickup = function(self, who)
		if who == game.player then
			game.player:resolveSource():setQuestStatus("east-portal", engine.Quest.COMPLETED, "athame-back")
		end
	end,
}

-- The orb of many ways, allows usage of Farportals
newEntity{ define_as = "ORB_MANY_WAYS2",
	power_source = {unknown=true},
	unique = "Orb of Many Ways2", quest=true, no_unique_lore=true,
	type = "jewelry", subtype="orb",
	unided_name = "swirling orb",
	name = "Orb of Many Ways",
	kr_name = "여러 장소로의 오브", kr_unided_name = "소용돌이 오브",
	level_range = {30, 30},
	display = "*", color=colors.VIOLET, image = "object/artifact/orb_many_ways.png",
	encumber = 1,
	desc = [[이 오브는 멀리 떨어진 곳의 형상들을 보여주는 물건입니다. 어떤 장소는 이 세상과는 동떨어진 장소처럼 보이기도 하며, 빠르게 형상들이 바뀌고 있습니다.
관문 근처에서 사용하면, 관문을 활성화시킬 수 있을 것 같습니다.]],

	max_power = 30, power_regen = 1,
	use_power = { name = "activate a portal", kr_name = "관문 활성화", power = 10,
		use = function(self, who)
			self:identify(true)
			local g = game.level.map(who.x, who.y, game.level.map.TERRAIN)
			if g and g.orb_portal then
				world:gainAchievement("SLIDERS", who:resolveSource())
				who:useOrbPortal(g.orb_portal)
			else
				game.logPlayer(who, "여기에는 활성화시킬 관문이 없습니다.")
			end
			return {id=true, used=true}
		end
	},

	on_drop = function(self, who)
		if who == game.player then
			game.logPlayer(who, "당신은 %s 버릴 수 없습니다", self:getName():addJosa("를"))
			return true
		end
	end,
	on_pickup = function(self, who)
		if who == game.player then
			game.player:resolveSource():setQuestStatus("east-portal", engine.Quest.COMPLETED, "orb-back")
		end
	end,
}
