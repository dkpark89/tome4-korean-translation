-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2015 Nicolas Casalini
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
	kr_name = "마법폭발의 이야기",
	desc = [[여덟 장의 마법폭발 연대기를 모음.]],
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
	kr_name = "가르쿨의 전설",
	desc = [[다섯 장의 가르쿨의 전설을 모음.]],
	show = "full",
	mode = "player",
	can_gain = function(self, who, obj)
		if not game.party:knownLore("garkul-history-1") then return false end
		if not game.party:knownLore("garkul-history-2") then return false end
		if not game.party:knownLore("garkul-history-3") then return false end
		if not game.party:knownLore("garkul-history-4") then return false end
		if not game.party:knownLore("garkul-history-5") then return false end
		return true
	end,
	on_gain = function()
		game:unlockBackground("garkul", "Garkul")
	end,
}

newAchievement{
	name = "A different point of view", id = "ORC_LORE",
	kr_name = "다른 시점",
	desc = [[지식의 대가 하닥의 이야기가 작성한, 다섯 장의 오크 역사를 모음.]],
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
