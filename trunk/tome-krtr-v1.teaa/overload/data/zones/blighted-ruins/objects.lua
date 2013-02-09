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

load("/data/general/objects/objects-maj-eyal.lua")

-- Allows undeads to pass as normal humans
newEntity{ define_as = "CLOAK_DECEPTION",
	power_source = {arcane=true},
	unique = true, quest=true,
	slot = "CLOAK",
	type = "armor", subtype="cloak",
	unided_name = "black cloak", image = "object/artifact/black_cloak.png",
	moddable_tile = "cloak_%s_05", moddable_tile_hood = true,
	name = "Cloak of Deception",
	kr_display_name = "기만의 망토", kr_unided_name = "검은 망토",
	display = ")", color=colors.DARK_GREY,
	encumber = 1,
	desc = [[착용자를 인간처럼 보이게 만드는 환영이 부여된, 잘 짜여진 검은 망토입니다.]],

	wielder = {
		combat_spellpower = 5,
		combat_mindpower = 5,
		combat_dam = 5,
	},

	on_wear = function(self, who)
		if game.party:hasMember(who) then
			for m, _ in pairs(game.party.members) do
				m:setEffect(m.EFF_CLOAK_OF_DECEPTION, 1, {})
			end
			game.logPlayer(who, "#LIGHT_BLUE#%s의 환영이 나타나, 인간의 모습처럼 보이게 되었습니다.", (who.kr_display_name or who.name):capitalize())
		end
	end,
	on_takeoff = function(self, who)
		if self.upgraded_cloak then return end
		if game.party:hasMember(who) then
			for m, _ in pairs(game.party.members) do
				m:removeEffect(m.EFF_CLOAK_OF_DECEPTION, true, true)
			end
			game.logPlayer(who, "#LIGHT_BLUE#%s 감싸던 환영이 사라집니다.", (who.kr_display_name or who.name):capitalize():addJosa("를"))
		end
	end,
	on_pickup = function(self, who)
		who:setQuestStatus("start-undead", engine.Quest.COMPLETED, "black-cloak")
	end,
}

for i = 1, 4 do
newEntity{ base = "BASE_LORE",
	define_as = "NOTE"..i,
	name = "journal page", lore="blighted-ruins-note-"..i,
	kr_display_name = "일지의 한 페이지", --@@ lore 번역후 수정 필요
	desc = [[사령술사가 남긴 종이 조각입니다.]],
	rarity = false,
	encumberance = 0,
}
end
