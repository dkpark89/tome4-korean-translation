﻿-- ToME - Tales of Maj'Eyal
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

newAchievement{
	name = "Tales of the Spellblaze", id = "SPELLBLAZE_LORE",
	kr_display_name = "스펠블레이즈의 이야기",
	desc = [[Learned the eight chapters of the Spellblaze Chronicles.]],
	show = "full",
	mode = "player",
	can_gain = function(self, who, obj)
		if not game.party:knownLore("spellblaze-chronicles-1") then return false end
		if not game.party:knownLore("spellblaze-chronicles-2") then return false end
		if not game.party:knownLore("spellblaze-chronicles-3") then return false end
		if not game.party:knownLore("spellblaze-chronicles-4") then return false end
		if not game.party:knownLore("spellblaze-chronicles-5") then return false end
		if not game.party:knownLore("spellblaze-chronicles-6") then return false end
		if not game.party:knownLore("spellblaze-chronicles-7") then return false end
		if not game.party:knownLore("spellblaze-chronicles-8") then return false end
		return true
	end
}

newAchievement{
	name = "The Legend of Garkul", id = "GARKUL_LORE",
	kr_display_name = "가쿨의 전설",
	desc = [[Learned the five chapters of the Legend of Garkul.]],
	show = "full",
	mode = "player",
	can_gain = function(self, who, obj)
		if not game.party:knownLore("garkul-history-1") then return false end
		if not game.party:knownLore("garkul-history-2") then return false end
		if not game.party:knownLore("garkul-history-3") then return false end
		if not game.party:knownLore("garkul-history-4") then return false end
		if not game.party:knownLore("garkul-history-5") then return false end
		return true
	end
}

newAchievement{
	name = "A different point of view", id = "ORC_LORE",
	kr_display_name = "다른 시점에서의 이야기",
	desc = [[Learned the five chapters of Orc history through loremaster Hadak's tales.]],
	show = "full",
	mode = "player",
	can_gain = function(self, who, obj)
		if not game.party:knownLore("orc-history-1") then return false end
		if not game.party:knownLore("orc-history-2") then return false end
		if not game.party:knownLore("orc-history-3") then return false end
		if not game.party:knownLore("orc-history-4") then return false end
		if not game.party:knownLore("orc-history-5") then return false end
		return true
	end
}
