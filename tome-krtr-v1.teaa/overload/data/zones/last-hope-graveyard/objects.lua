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

local Talents = require "engine.interface.ActorTalents"
local Stats = require "engine.interface.ActorStats"
local DamageType = require "engine.DamageType"

load("/data/general/objects/objects-maj-eyal.lua")

newEntity{ base = "BASE_LORE",
	define_as = "CELIA_NOTE",
	name = "creased letter", lore="celia-letter",
	kr_display_name = "접혀진 편지", --@@ lore 번역시 수정 필요
	desc = [[편지입니다.]],
	rarity = false,
	encumberance = 0,
}

newEntity{ define_as = "CELIA_HEART",
	power_source = {arcane=true},
	unique = true,
	type = "misc", subtype="heart",
	unided_name = "bloody heart",
	name = "Celia's Still Beating Heart",
	kr_display_name = "셀리아의 아직도 뛰는 심장", kr_unided_name = "핏빛 심장",
	level_range = {20, 35},
	rarity = false,
	display = "*", color=colors.RED,  image = "object/artifact/celias_heart.png",
	encumber = 2,
	not_in_stores = true,
	desc = [[사령술사 셀리아의 살아있는 심장입니다. 그녀의 가슴에서 떼어냈지만, 마법으로 보존되고 있습니다.]],

	max_power = 75, power_regen = 1,
	use_sound = "talents/slime",
	use_power = { name = "extract a tiny part of Celia's soul", kr_display_name = "셀리아의 영혼 일부를 추출", power = 75, use = function(self, who)
		local p = who:isTalentActive(who.T_NECROTIC_AURA)
		if not p then return end
		p.souls = util.bound(p.souls + 1, 0, p.souls_max)
		who.changed = true
		game.logPlayer(who, "당신은 손으로 셀리아의 심장을 짜내어, 그녀의 영혼 일부분을 당신이 가진 사령술의 기운으로 흡수했습니다.")
		self.max_power = self.max_power + 5
		self.use_power.power = self.use_power.power + 5
		return {id=true, used=true}
	end },
}
