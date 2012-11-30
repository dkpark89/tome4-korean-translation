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
local q = game.player:hasQuest("lost-merchant")
if q and q:isStatus(q.COMPLETED, "saved") then

newChat{ id="welcome",
	text = [[Ah, my #{italic}#good#{normal}# friend @playername@!
Thanks to you I made it safely to this great city! I am planning to open my most excellent boutique soon, but since I am in your debt, perhaps I could open early for you if you are in need of rare goods.]]
..(game.state:isAdvanced() and "\nOh my friend, good news! As I told you I can now request a truly #{italic}#unique#{normal}# object to be crafted just for you. For a truly unique price..." or "\nI eventually plan to arrange a truly unique service for the most discerning of customers. If you come back later when I'm fully set up I shall be able to order for you something quite marvellous. For a perfectly #{italic}#suitable#{normal}# price, of course."),
	answers = {
		{"Yes please, let me see your wares.", action=function(npc, player)
			npc.store:loadup(game.level, game.zone)
			npc.store:interact(player)
		end},
		{"What about the unique object?", cond=function(npc, player) return game.state:isAdvanced() end, jump="unique1"},
		{"Sorry, I have to go!"},
	}
}

newChat{ id="unique1",
	text = [[I normally offer this service only for a truly deserved price, but for you my friend I am willing to offer a 20% discount - #{italic}#only#{normal}# 4000 gold to make an utterly unique item of your choice.  What do you say?]],
	answers = {
		{"Why, 'tis a paltry sum - take my order, man, and be quick about it!", cond=function(npc, player) return player.money >= 10000 end, jump="make"},
		{"Yes please!", cond=function(npc, player) return player.money >= 4000 end, jump="make"},
		{"HOW MUCH?! Please, excuse me, I- I need some fresh air...", cond=function(npc, player) return player.money < 500 end},
		{"Not now, thank you."},
	}
}

local maker_list = function()
	local bases = {
		"elven-silk robe",
		"drakeskin leather armour",
		"voratun mail armour",
		"voratun plate armour",
		"elven-silk cloak",
		"drakeskin leather gloves",
		"voratun gauntlets",
		"elven-silk wizard hat",
		"drakeskin leather cap",
		"voratun helm",
		"pair of drakeskin leather boots",
		"pair of voratun boots",
		"drakeskin leather belt",
		"voratun ring",
		"voratun amulet",
		"dwarven lantern",
		"voratun battleaxe",
		"voratun greatmaul",
		"voratun greatsword",
		"voratun waraxe",
		"voratun mace",
		"voratun longsword",
		"voratun dagger",
		"dragonbone longbow",
		"drakeskin leather sling",
		"voratun shield",
		"dragonbone staff",
		"living mindstar",
	}
	local l = {}
	for i, name in ipairs(bases) do
		local not_ps = player:attr("forbid_arcane") and {arcane=true} or {antimagic=true}
		local force_themes = player:attr("forbid_arcane") and {'antimagic'} or nil

		local o, ok
		repeat
			o = game.zone:makeEntity(game.level, "object", {name=name, ingore_material_restriction=true, no_tome_drops=true, ego_filter={keep_egos=true, ego_chance=-1000}}, nil, true)
			if o then ok = true end
			if o and o.power_source and player:attr("forbid_arcane") and o.power_source.arcane then ok = false end
		until ok
		if o then
			l[#l+1] = {o:getName{force_id=true, do_color=true, no_count=true}, action=function(npc, player)
				local art, ok
				local nb = 0
				repeat
					art = game.state:generateRandart{base=o, lev=70, egos=4, force_themes=force_themes, forbid_power_source=not_ps}
					if art then ok = true end
					if art and art.power_source and player:attr("forbid_arcane") and art.power_source.arcane then ok = false end
					nb = nb + 1
					if nb == 40 then break end
				until ok
				if art and nb < 40 then
					art:identify(true)
					player:addObject(player.INVEN_INVEN, art)
					player:incMoney(-4000)
					-- clear chrono worlds and their various effects
					if game._chronoworlds then
						game.log("#CRIMSON#Your timetravel has no effect on pre-determined outcomes such as this.")
						game._chronoworlds = nil
					end
					game:saveGame()

					newChat{ id="naming",
						text = "Do you want to name your item?\n"..tostring(art:getTextualDesc()),
						answers = {
							{"Yes please.", action=function(npc, player)
								local d = require("engine.dialogs.GetText").new("Name your item", "Name", 2, 40, function(txt)
									art.name = txt:removeColorCodes():gsub("#", " ")
									game.log("#LIGHT_BLUE#The merchant carefully hands you: %s", art:getName{do_color=true})
								end, function() game.log("#LIGHT_BLUE#The merchant carefully hands you: %s", art:getName{do_color=true}) end)
								game:registerDialog(d)
							end},
							{"No thanks.", action=function() game.log("#LIGHT_BLUE#The merchant carefully hands you: %s", art:getName{do_color=true}) end},
						},
					}
					return "naming"
				else
					newChat{ id="oups",
						text = "Oh I am sorry, it seems we could not make the item your require.",
						answers = {
							{"Oh, let's try something else then.", jump="make"},
							{"Oh well, maybe later then."},
						},
					}
					return "oups"
				end
			end}
		end
	end

	return l
end

newChat{ id="make",
	text = [[Which kind of item would you like ?]],
	answers = maker_list(),
}

else

newChat{ id="welcome",
	text = [[*This store does not appear to be open yet*]],
	answers = {
		{"[leave]"},
	}
}

end

return "welcome"
