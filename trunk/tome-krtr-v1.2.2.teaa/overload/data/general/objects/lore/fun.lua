-- ToME - Tales of Maj'Eyal
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

newEntity{ base = "BASE_LORE_RANDOM",
	name = "trollish poem", lore="troll-poem", unique=true,
	kr_name = "트롤의 시",
	desc = [[이 시를 쓴 건... 트롤인가?]],
	level_range = {1, 50},
	rarity = 40,
	encumber = 0,
}

newEntity{ base = "BASE_LORE_RANDOM",
	name = "necromancer poem", lore="necromancer-poem", unique=true,
	kr_name = "사령술사의 시",
	desc = [[이 시를 쓴 건... 사령술사인가?]],
	level_range = {15, 50},
	rarity = 40,
	encumber = 0,
}

newEntity{ base = "BASE_LORE_RANDOM",
	name = "rogues do it from behind", lore="rogue-poem", unique=true,
	kr_name = "도적은 숨어 있다네",
	desc = [[이 시는 도둑을 위해 쓴 것인지?]],
	level_range = {15, 50},
	rarity = 40,
	encumber = 0,
}

for i = 1, 4 do
newEntity{ base = "BASE_LORE_RANDOM",
	name = "how to become a necromancer, part "..i, lore="necromancer-primer-"..i, unique=true,
	kr_name = "사령술사가 되는 방법, "..i.."부",
	desc = [[강력한 사령술가가 되는 방법!]],
	level_range = {15, 50},
	rarity = 40,
}
end

newEntity{ base = "BASE_LORE_RANDOM",
	name = [["Dust to Dust", an undead hunter's guide, by Aslabor Borys]], lore="dust-to-dust", unique=true,
	kr_name = [[언데드 사냥꾼 안내서 "먼지에서 먼지로" - 아슬라보르 보리스.]],
	desc = [[아슬라보르 보리스의 언데드 사냥꾼을 위한 안내서]],
	level_range = {15, 50},
	rarity = 60,
}

for i = 1, 5 do
local who
if i == 1 then who = "Rolf" nb = 1 krWho = "롤프"
elseif i == 2 then who = "Weisman" nb = 1 krWho = "웨이스만"
elseif i == 3 then who = "Rolf" nb = 2 krWho = "롤프"
elseif i == 4 then who = "Weisman" nb = 2 krWho = "웨이스만"
elseif i == 5 then who = "Weisman" nb = 3 krWho = "웨이스만"
end
newEntity{ base = "BASE_LORE_RANDOM",
	name = "letter to "..who.."("..nb..")", lore="adventurer-letter-"..i, unique=true,
	kr_name = krWho.."에게 보내는 편지 ("..nb..")",
	desc = [[두 모험사 사이의 일부 편지 왕래.]],
	level_range = {1, 20},
	rarity = 20,
	bloodstains = (i == 5) and 2 or nil,
}
end

newEntity{ base = "BASE_LORE_RANDOM",
	name = "of halfling feet", lore="halfling-feet", unique=true,
	kr_name = "하플링의 발",
	desc = [[적혀 있는 내용은 .. 하플링의 발 ??]],
	level_range = {10, 30},
	rarity = 40,
	encumber = 0,
}
