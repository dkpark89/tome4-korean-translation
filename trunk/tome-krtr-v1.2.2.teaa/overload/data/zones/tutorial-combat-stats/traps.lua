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

load("/data/general/traps/natural_forest.lua")

newEntity{ define_as = "TRAP_TUTORIAL",
	type = "tutorial", subtype="tutorial", id_by_type=true, unided_name = "tutorial",
	detect_power = 999999, disarm_power = 999999,
	kr_unided_name = "게임 배우기",
	desc = [[연습 게임으로 게임을 배웁니다.]],
	display = ' ', color=colors.WHITE,
	message = false,
	triggered = function(self, x, y, who)
		if who.player then
			game.player:runStop()
			local d = require("engine.dialogs.ShowText").new("게임 배우기: "..self.name, "tutorial/"..self.text)
			game:registerDialog(d)
		end
		return false, false
	end
}

newEntity{ define_as = "TRAP_TUTORIAL2",
	type = "tutorial", subtype="tutorial2", id_by_type=true, unided_name = "tutorial",
	detect_power = 999999, disarm_power = 999999,
	kr_unided_name = "게임 배우기",
	desc = [[연습 게임으로 게임을 배웁니다.]],
	display = ' ', color=colors.WHITE,
	message = false,
	triggered = function(self, x, y, who)
		if who.player then
			game.player:runStop()
			local d = require("engine.dialogs.ShowText").new("게임 배우기: "..self.name, "tutorial/stats/"..self.text)
			game:registerDialog(d)
		end
		return false, false
	end
}

newEntity{ define_as = "TRAP_TUTORIAL3",
	type = "tutorial", subtype="tutorial3", id_by_type=true, unided_name = "tutorial",
	detect_power = 999999, disarm_power = 999999,
	kr_unided_name = "게임 배우기",
	desc = [[연습 게임으로 게임을 배웁니다.]],
	display = ' ', color=colors.WHITE,
	message = false,
	triggered = function(self, x, y, who)
		if who.player then
			game.player:runStop()
			local d = require("engine.dialogs.ShowText").new("게임 배우기: "..self.name, "tutorial/stats-scale/"..self.text)
			game:registerDialog(d)
		end
		return false, false
	end
}

newEntity{ define_as = "TRAP_TUTORIAL4",
	type = "tutorial", subtype="tutorial4", id_by_type=true, unided_name = "tutorial",
	detect_power = 999999, disarm_power = 999999,
	kr_unided_name = "게임 배우기",
	desc = [[연습 게임으로 게임을 배웁니다.]],
	display = ' ', color=colors.WHITE,
	message = false,
	triggered = function(self, x, y, who)
		if who.player then
			game.player:runStop()
			local d = require("engine.dialogs.ShowText").new("게임 배우기: "..self.name, "tutorial/stats-calc/"..self.text)
			game:registerDialog(d)
		end
		return false, false
	end
}

newEntity{ define_as = "TRAP_TUTORIAL5",
	type = "tutorial", subtype="tutorial5", id_by_type=true, unided_name = "tutorial",
	detect_power = 999999, disarm_power = 999999,
	kr_unided_name = "게임 배우기",
	desc = [[연습 게임으로 게임을 배웁니다.]],
	display = ' ', color=colors.WHITE,
	message = false,
	triggered = function(self, x, y, who)
		if who.player then
			game.player:runStop()
			local d = require("engine.dialogs.ShowText").new("게임 배우기: "..self.name, "tutorial/stats-timed/"..self.text)
			game:registerDialog(d)
		end
		return false, false
	end
}

newEntity{ define_as = "TRAP_TUTORIAL6",
	type = "tutorial", subtype="tutorial6", id_by_type=true, unided_name = "tutorial",
	detect_power = 999999, disarm_power = 999999,
	kr_unided_name = "게임 배우기",
	desc = [[연습 게임으로 게임을 배웁니다.]],
	display = ' ', color=colors.WHITE,
	message = false,
	triggered = function(self, x, y, who)
		if who.player then
			game.player:runStop()
			local d = require("engine.dialogs.ShowText").new("Tutorial: "..self.name, "tutorial/stats-tier/"..self.text)
			game:registerDialog(d)
		end
		return false, false
	end
}

newEntity{ base = "TRAP_TUTORIAL", define_as = "TUTORIAL_MOVE",
	name = "Movement",
	kr_name = "이동",
	text = "move",
}

newEntity{ base = "TRAP_TUTORIAL", define_as = "TUTORIAL_MELEE",
	name = "Melee Combat",
	kr_name = "근접 공격",
	text = "melee",
}

newEntity{ base = "TRAP_TUTORIAL", define_as = "TUTORIAL_OBJECTS",
	name = "Objects",
	kr_name = "물건",
	text = "objects",
}

newEntity{ base = "TRAP_TUTORIAL", define_as = "TUTORIAL_TALENTS",
	name = "Talents",
	kr_name = "기술",
	text = "talents",
}

newEntity{ base = "TRAP_TUTORIAL", define_as = "TUTORIAL_LEVELUP",
	name = "Experience and Levels",
	kr_name = "경험치와 레벨",
	text = "levelup",
}

newEntity{ base = "TRAP_TUTORIAL", define_as = "TUTORIAL_TERRAIN",
	name = "Different terrains",
	kr_name = "여러가지 지형",
	text = "terrain",
}

newEntity{ base = "TRAP_TUTORIAL", define_as = "TUTORIAL_TACTICS1",
	name = "Basic tactic: Do not get surrounded",
	kr_name = "기본 전술: 포위되지 않기",
	text = "tactics1",
}

newEntity{ base = "TRAP_TUTORIAL", define_as = "TUTORIAL_TACTICS2",
	name = "Basic tactic: Take cover",
	kr_name = "기본 전술: 은폐/엄폐",
	text = "tactics2",
}

newEntity{ base = "TRAP_TUTORIAL", define_as = "TUTORIAL_RANGED",
	name = "Ranged Combat",
	kr_name = "원거리 공격",
	text = "ranged",
}

newEntity{ base = "TRAP_TUTORIAL", define_as = "TUTORIAL_QUESTS",
	name = "Quests",
	kr_name = "모험",
	text = "quests",
}

newEntity{ base = "TRAP_TUTORIAL", define_as = "TUTORIAL_MECHOPTION",
	name = "Mechanics tutorial",
	kr_name = "게임의 규칙",
	text = "mechoption",
}

--Guide to stats:

newEntity{ base = "TRAP_TUTORIAL2", define_as = "TUTORIAL_INTRO_MECHANICS_GUIDE",
	name = "Mechanics Tutorial",
	kr_name = "게임의 규칙",
	text = "mechintro",
}

newEntity{ base = "TRAP_TUTORIAL2", define_as = "TUTORIAL_STATS1",
	name = "Combat Stats",
	kr_name = "전투 능력치",
	text = "stats1",
}

newEntity{ base = "TRAP_TUTORIAL2", define_as = "TUTORIAL_STATS2",
	name = "Combat Stats",
	kr_name = "전투 능력치",
	text = "stats2",
}

newEntity{ base = "TRAP_TUTORIAL2", define_as = "TUTORIAL_STATS3",
	name = "Combat Stats",
	kr_name = "전투 능력치",
	text = "stats3",
}

newEntity{ base = "TRAP_TUTORIAL2", define_as = "TUTORIAL_STATS4",
	name = "Combat Stats",
	kr_name = "전투 능력치",
	text = "stats4",
}

newEntity{ base = "TRAP_TUTORIAL2", define_as = "TUTORIAL_STATS5",
	name = "Combat Stats",
	kr_name = "전투 능력치",
	text = "stats5",
}

newEntity{ base = "TRAP_TUTORIAL2", define_as = "TUTORIAL_STATS6",
	name = "Combat Stats",
	kr_name = "전투 능력치",
	text = "stats6",
}

newEntity{ base = "TRAP_TUTORIAL2", define_as = "TUTORIAL_STATS7",
	name = "Combat Stats",
	kr_name = "전투 능력치",
	text = "stats7",
}

newEntity{ base = "TRAP_TUTORIAL2", define_as = "TUTORIAL_STATS7.1",
	name = "Combat Stats",
	kr_name = "전투 능력치",
	text = "stats7.1",
}

newEntity{ base = "TRAP_TUTORIAL2", define_as = "TUTORIAL_STATS8",
	name = "Combat Stats",
	kr_name = "전투 능력치",
	text = "stats8",
}

newEntity{ base = "TRAP_TUTORIAL2", define_as = "TUTORIAL_STATS9",
	name = "Combat Stats",
	kr_name = "전투 능력치",
	text = "stats9",
}

--Guide to new stats scale
newEntity{ base = "TRAP_TUTORIAL3", define_as = "TUTORIAL_INFORMED1",
	name = "Combat Stat Tooltips",
	kr_name = "전투 능력치 정보",
	text = "informed1",
}

newEntity{ base = "TRAP_TUTORIAL3", define_as = "TUTORIAL_SCALE1",
	name = "Combat Stat Scale",
	kr_name = "전투 능력치 단계",
	text = "scale1",
}

newEntity{ base = "TRAP_TUTORIAL3", define_as = "TUTORIAL_SCALE2",
	name = "Combat Stat Scale",
	kr_name = "전투 능력치 단계",
	text = "scale2",
}

newEntity{ base = "TRAP_TUTORIAL3", define_as = "TUTORIAL_SCALE3",
	name = "Combat Stat Scale",
	kr_name = "전투 능력치 단계",
	text = "scale3",
}

newEntity{ base = "TRAP_TUTORIAL3", define_as = "TUTORIAL_SCALE4",
	name = "Combat Stat Scale",
	kr_name = "전투 능력치 단계",
	text = "scale4",
}

newEntity{ base = "TRAP_TUTORIAL3", define_as = "TUTORIAL_SCALE5",
	name = "Combat Stat Scale",
	kr_name = "전투 능력치 단계",
	text = "scale5",
}


newEntity{ base = "TRAP_TUTORIAL3", define_as = "TUTORIAL_SCALE6",
	name = "Combat Stat Scale",
	kr_name = "전투 능력치 단계",
	text = "scale6",
}

newEntity{ base = "TRAP_TUTORIAL3", define_as = "TUTORIAL_SCALE7",
	name = "Combat Stat Scale",
	kr_name = "전투 능력치 단계",
	text = "scale7",
}

newEntity{ base = "TRAP_TUTORIAL3", define_as = "TUTORIAL_SCALE8",
	name = "Combat Stat Scale",
	kr_name = "전투 능력치 단계",
	text = "scale8",
}

newEntity{ base = "TRAP_TUTORIAL3", define_as = "TUTORIAL_SCALE9",
	name = "Combat Stat Scale",
	kr_name = "전투 능력치 단계",
	text = "scale9",
}

newEntity{ base = "TRAP_TUTORIAL3", define_as = "TUTORIAL_SCALE10",
	name = "Combat Stat Scale",
	kr_name = "전투 능력치 단계",
	text = "scale10",
}

newEntity{ base = "TRAP_TUTORIAL3", define_as = "TUTORIAL_SCALE11",
	name = "Combat Stat Scale",
	kr_name = "전투 능력치 단계",
	text = "scale11",
}

newEntity{ base = "TRAP_TUTORIAL3", define_as = "TUTORIAL_SCALE12",
	name = "Combat Stat Scale",
	kr_name = "전투 능력치 단계",
	text = "scale12",
}

newEntity{ base = "TRAP_TUTORIAL4", define_as = "TUTORIAL_CALC0",
	name = "Combat Stat Calculations",
	kr_name = "전투 능력치 계산법",
	text = "calc0",
}

newEntity{ base = "TRAP_TUTORIAL4", define_as = "TUTORIAL_CALC1",
	name = "Combat Stat Calculations",
	kr_name = "전투 능력치 계산법",
	text = "calc1",
}

newEntity{ base = "TRAP_TUTORIAL4", define_as = "TUTORIAL_CALC2",
	name = "Combat Stat Calculations",
	kr_name = "전투 능력치 계산법",
	text = "calc2",
}

newEntity{ base = "TRAP_TUTORIAL4", define_as = "TUTORIAL_CALC3",
	name = "Combat Stat Calculations",
	kr_name = "전투 능력치 계산법",
	text = "calc3",
}

newEntity{ base = "TRAP_TUTORIAL4", define_as = "TUTORIAL_CALC4",
	name = "Combat Stat Calculations",
	kr_name = "전투 능력치 계산법",
	text = "calc4",
}

newEntity{ base = "TRAP_TUTORIAL4", define_as = "TUTORIAL_CALC5",
	name = "Combat Stat Calculations",
	kr_name = "전투 능력치 계산법",
	text = "calc5",
}

newEntity{ base = "TRAP_TUTORIAL4", define_as = "TUTORIAL_CALC6",
	name = "Combat Stat Calculations",
	kr_name = "전투 능력치 계산법",
	text = "calc6",
}

newEntity{ base = "TRAP_TUTORIAL4", define_as = "TUTORIAL_CALC7",
	name = "Combat Stat Calculations",
	kr_name = "전투 능력치 계산법",
	text = "calc7",
}

newEntity{ base = "TRAP_TUTORIAL4", define_as = "TUTORIAL_CALC8",
	name = "Combat Stat Calculations",
	kr_name = "전투 능력치 계산법",
	text = "calc8",
}

newEntity{ base = "TRAP_TUTORIAL4", define_as = "TUTORIAL_CALC9",
	name = "Combat Stat Calculations",
	kr_name = "전투 능력치 계산법",
	text = "calc9",
}

newEntity{ base = "TRAP_TUTORIAL4", define_as = "TUTORIAL_CALC10",
	name = "Combat Stat Calculations",
	kr_name = "전투 능력치 계산법",
	text = "calc10",
}

newEntity{ base = "TRAP_TUTORIAL4", define_as = "TUTORIAL_CALC11",
	name = "Combat Stat Calculations",
	kr_name = "전투 능력치 계산법",
	text = "calc11",
}

newEntity{ base = "TRAP_TUTORIAL5", define_as = "TUTORIAL_TIMED0",
	name = "Timed Effects",
	kr_name = "지속 효과",
	text = "timed0",
}

newEntity{ base = "TRAP_TUTORIAL5", define_as = "TUTORIAL_TIMED1",
	name = "Timed Effects",
	kr_name = "지속 효과",
	text = "timed1",
}

newEntity{ base = "TRAP_TUTORIAL5", define_as = "TUTORIAL_TIMED2",
	name = "Timed Effects",
	kr_name = "지속 효과",
	text = "timed2",
}

newEntity{ base = "TRAP_TUTORIAL5", define_as = "TUTORIAL_TIMED3",
	name = "Timed Effects",
	kr_name = "지속 효과",
	text = "timed3",
}

newEntity{ base = "TRAP_TUTORIAL5", define_as = "TUTORIAL_TIMED4",
	name = "Timed Effects",
	kr_name = "지속 효과",
	text = "timed4",
}

newEntity{ base = "TRAP_TUTORIAL5", define_as = "TUTORIAL_TIMED5",
	name = "Timed Effects",
	kr_name = "지속 효과",
	text = "timed5",
}

newEntity{ base = "TRAP_TUTORIAL5", define_as = "TUTORIAL_TIMED6",
	name = "Timed Effects",
	kr_name = "지속 효과",
	text = "timed6",
}

newEntity{ base = "TRAP_TUTORIAL5", define_as = "TUTORIAL_TIMED7",
	name = "Timed Effects",
	kr_name = "지속 효과",
	text = "timed7",
}

newEntity{ base = "TRAP_TUTORIAL5", define_as = "TUTORIAL_TIMED8",
	name = "Timed Effects",
	kr_name = "지속 효과",
	text = "timed8",
}

newEntity{ base = "TRAP_TUTORIAL6", define_as = "TUTORIAL_TIER0",
	name = "Cross-Tier Effects",
	kr_name = "단계 차이 효과",
	text = "tier0",
}

newEntity{ base = "TRAP_TUTORIAL6", define_as = "TUTORIAL_TIER1",
	name = "Cross-Tier Effects",
	kr_name = "단계 차이 효과",
	text = "tier1",
}

newEntity{ base = "TRAP_TUTORIAL6", define_as = "TUTORIAL_TIER2",
	name = "Cross-Tier Effects",
	kr_name = "단계 차이 효과",
	text = "tier2",
}

newEntity{ base = "TRAP_TUTORIAL6", define_as = "TUTORIAL_TIER3",
	name = "Cross-Tier Effects",
	kr_name = "단계 차이 효과",
	text = "tier3",
}

newEntity{ base = "TRAP_TUTORIAL6", define_as = "TUTORIAL_TIER4",
	name = "Cross-Tier Effects",
	kr_name = "단계 차이 효과",
	text = "tier4",
}

newEntity{ base = "TRAP_TUTORIAL6", define_as = "TUTORIAL_TIER5",
	name = "Cross-Tier Effects",
	kr_name = "단계 차이 효과",
	text = "tier5",
}

newEntity{ base = "TRAP_TUTORIAL6", define_as = "TUTORIAL_TIER6",
	name = "Cross-Tier Effects",
	kr_name = "단계 차이 효과",
	text = "tier6",
}

newEntity{ base = "TRAP_TUTORIAL6", define_as = "TUTORIAL_TIER7",
	name = "Cross-Tier Effects",
	kr_name = "단계 차이 효과",
	text = "tier7",
}

newEntity{ base = "TRAP_TUTORIAL6", define_as = "TUTORIAL_TIER8",
	name = "Cross-Tier Effects",
	kr_name = "단계 차이 효과",
	text = "tier8",
}

newEntity{ base = "TRAP_TUTORIAL6", define_as = "TUTORIAL_TIER9",
	name = "Cross-Tier Effects",
	kr_name = "단계 차이 효과",
	text = "tier9",
}

newEntity{ base = "TRAP_TUTORIAL6", define_as = "TUTORIAL_TIER10",
	name = "Cross-Tier Effects",
	kr_name = "단계 차이 효과",
	text = "tier10",
}

newEntity{ base = "TRAP_TUTORIAL6", define_as = "TUTORIAL_TIER11",
	name = "Dungeon of Adventurer Enlightenment Completed",
	kr_name = "모험가용 계몽의 지하미궁 완료",
	text = "tier11",
}

newEntity{ base = "TRAP_TUTORIAL6", define_as = "TUTORIAL_TIER12",
	name = "Cross-Tier Effects",
	kr_name = "단계 차이 효과",
	text = "tier12",
}
