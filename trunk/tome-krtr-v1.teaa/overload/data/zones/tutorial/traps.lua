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

load("/data/general/traps/natural_forest.lua")

newEntity{ define_as = "TRAP_TUTORIAL",
	type = "tutorial", subtype="tutorial", id_by_type=true, unided_name = "tutorial",
	kr_unided_name = "게임 배우기",
	detect_power = 999999, disarm_power = 999999,
	desc = [[연습 게임을 통해, 게임을 배웁니다.]],
	display = ' ', color=colors.WHITE,
	message = false,
	triggered = function(self, x, y, who)
		if who.player then
			game.player:runStop()
			local d = require("engine.dialogs.ShowText").new("게임 배우기: "..(self.kr_display_name or self.name), "tutorial/"..self.text)
			game:registerDialog(d)
		end
		return false, false
	end
}

newEntity{ base = "TRAP_TUTORIAL", define_as = "TUTORIAL_MOVE",
	name = "Movement",
	kr_display_name = "이동",
	text = "move",
}

newEntity{ base = "TRAP_TUTORIAL", define_as = "TUTORIAL_MELEE",
	name = "Melee Combat",
	kr_display_name = "근접 공격",
	text = "melee",
}

newEntity{ base = "TRAP_TUTORIAL", define_as = "TUTORIAL_OBJECTS",
	name = "Objects",
	kr_display_name = "물건",
	text = "objects",
}

newEntity{ base = "TRAP_TUTORIAL", define_as = "TUTORIAL_TALENTS",
	name = "Talents",
	kr_display_name = "기술",
	text = "talents",
}

newEntity{ base = "TRAP_TUTORIAL", define_as = "TUTORIAL_LEVELUP",
	name = "Experience and Levels",
	kr_display_name = "경험치와 레벨",
	text = "levelup",
}

newEntity{ base = "TRAP_TUTORIAL", define_as = "TUTORIAL_TERRAIN",
	name = "Different terrains",
	kr_display_name = "여러가지 지형",
	text = "terrain",
}

newEntity{ base = "TRAP_TUTORIAL", define_as = "TUTORIAL_TACTICS1",
	name = "Basic tactic: Do not get surrounded",
	kr_display_name = "기본 전술: 포위되지 않기",
	text = "tactics1",
}

newEntity{ base = "TRAP_TUTORIAL", define_as = "TUTORIAL_TACTICS2",
	name = "Basic tactic: Take cover",
	kr_display_name = "기본 전술: 은폐/엄폐",
	text = "tactics2",
}

newEntity{ base = "TRAP_TUTORIAL", define_as = "TUTORIAL_RANGED",
	name = "Ranged Combat",
	kr_display_name = "원거리 공격",
	text = "ranged",
}

newEntity{ base = "TRAP_TUTORIAL", define_as = "TUTORIAL_QUESTS",
	name = "Quests",
	kr_display_name = "모험",
	text = "quests",
}
