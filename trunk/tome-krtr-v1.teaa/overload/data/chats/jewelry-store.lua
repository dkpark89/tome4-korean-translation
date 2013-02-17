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

local imbue_ring = function(npc, player)
	player:showInventory("어떤 반지에 보석을 주입시키실 겁니까?", player:getInven("INVEN"), function(o) return o.type == "jewelry" and o.subtype == "ring" and not o.egoed and not o.unique and not o.rare end, function(ring, ring_item)
		player:showInventory("어떤 보석을 사용하실 겁니까?", player:getInven("INVEN"), function(gem) return gem.type == "gem" and (gem.material_level or 99) <= ring.material_level and gem.imbue_powers end, function(gem, gem_item)
			local price = 10 + gem.material_level * 5 + ring.material_level * 7
			if price > player.money then require("engine.ui.Dialog"):simplePopup("돈이 부족하군요", "골드가 "..price.." 정도가 되면 돌아오시지요, 아직 골드가 좀 부족하군요.") return end

			require("engine.ui.Dialog"):yesnoPopup("보석 주입 가격", "제가 보아하니 이건 "..price.." 골드 정도가 들겠군요, 보석을 주입하실겁니까?", function(ret) if ret then
				player:incMoney(-price)
				player:removeObject(player:getInven("INVEN"), gem_item)
				ring.wielder = ring.wielder or {}
				table.mergeAdd(ring.wielder, gem.imbue_powers, true)
				ring.name = gem.name .. " 반지"
				ring.been_imbued = true
				ring.egoed = true
				game.logPlayer(player, "%s 가 반지에 보석을 주입하여 만듬: %s", npc.name:capitalize(), ring:getName{do_colour=true, no_count=true})
			end end, "예", "아니오")
		end)
	end)
end

local artifact_imbue_amulet = function(npc, player)
	player:showInventory("어떤 목걸이에 보석을 주입시키실 겁니까?", player:getInven("INVEN"), function(o) return o.type == "jewelry" and o.subtype == "amulet" and not o.egoed and not o.unique and not o.rare end, function(amulet, amulet_item)
		player:showInventory("어떤 보석을 첫번째로 사용하실 겁니까?", player:getInven("INVEN"), function(gem1) return gem1.type == "gem" and (gem1.material_level or 99) <= amulet.material_level and gem1.imbue_powers end, function(gem1, gem1_item)
			player:showInventory("두번쨰 보석은 무엇으로 사용하실건지?", player:getInven("INVEN"), function(gem2) return gem2.type == "gem" and (gem2.material_level or 99) <= amulet.material_level and gem1.name ~= gem2.name and gem2.imbue_powers end, function(gem2, gem2_item)
				local price = 390
				if price > player.money then require("engine.ui.Dialog"):simplePopup("돈이 부족하군요", "리미르는 마법 도금을 위해서는 더욱 많은 돈이 필요합니다..") return end

				require("engine.ui.Dialog"):yesnoPopup("보석 주입 가격", "당신이 부탁한 도금을 하려면 골드가 "..price.." 정도는 있어야 합니다, 도금을 하실겁니까??", function(ret) if ret then
					player:incMoney(-price)
					local gem3, tries = nil, 10
					while gem3 == nil and tries > 0 do gem3 = game.zone:makeEntity(game.level, "object", {type="gem"}, nil, true) tries = tries - 1 end
					if not gem3 then gem3 = rng.percent(50) and gem1 or gem2 end
					print("Imbue third gem", gem3.name)

					if gem1_item > gem2_item then
						player:removeObject(player:getInven("INVEN"), gem1_item)
						player:removeObject(player:getInven("INVEN"), gem2_item)
					else
						player:removeObject(player:getInven("INVEN"), gem2_item)
						player:removeObject(player:getInven("INVEN"), gem1_item)
					end
					amulet.wielder = amulet.wielder or {}
					table.mergeAdd(amulet.wielder, gem1.imbue_powers, true)
					table.mergeAdd(amulet.wielder, gem2.imbue_powers, true)
					table.mergeAdd(amulet.wielder, gem3.imbue_powers, true)
					amulet.name = "Limmir's Amulet of the Moon"
					amulet.been_imbued = true
					amulet.unique = util.uuid()
					game.logPlayer(player, "%s 가 목걸이에 마법 도금을 하여 만듬: %s", npc.name:capitalize(), amulet:getName{do_colour=true, no_count=true})
				end end, "예", "아니오")
			end)
		end)
	end)
end

newChat{ id="welcome",
	text = [[제 상점에 오신걸 환영합니다, @playername@.]],
	answers = {
		{"당신이 가진 물건을 보여주시죠.", action=function(npc, player)
			npc.store:loadup(game.level, game.zone)
			npc.store:interact(player)
		end, cond=function(npc, player) return npc.store and true or false end},
		{"저는 좀 특수한 장신구들을 찾고 있습니다.", jump="jewelry"},
		{"여기서 목걸이에 보석 주입을 하는 일을 한다고 들었는데 사실입니까?", jump="artifact_jewelry", cond=function(npc, player) return npc.can_craft and player:hasQuest("master-jeweler") and player:isQuestStatus("master-jeweler", engine.Quest.COMPLETED, "limmir-survived") end},
		{"이런 큰 책을 찾았습니다만; 중요해 보이던데요.", jump="quest", cond=function(npc, player) return npc.can_quest and player:hasQuest("master-jeweler") and player:hasQuest("master-jeweler"):has_tome(player) end},
		{"미안하지만 난 가봐야 겠어!"},
	}
}

newChat{ id="jewelry",
	text = [[Then you are at the right place, for I am an expert jeweler.
If you bring me a gem and a non-magical ring, I can imbue the gem inside the ring for you.
There is a small fee dependent on the level of the ring, and you need a quality ring to use a quality gem.]],
	answers = {
		{"그럼 어디 한번 해 봅시다.", action=imbue_ring},
		{"고맙지만 지금은 됐네."},
	}
}

newChat{ id="artifact_jewelry",
	text = [[Yes! Thanks to you this place is now free from the corruption. I will stay on this island to study the magical aura, and as promised I can make you powerful amulets.
Bring me a non-magical amulet and two different gems and I will turn them into a powerful amulet.
I will not make you pay a fee for it since you helped me so much, but I am afraid the ritual requires a gold plating. This should be equal to about 390 gold pieces.]],
	answers = {
		{"그럼 어서 해 보죠.", action=artifact_imbue_amulet},
		{"고맙지만 지금은 됐습니다."},
	}
}

newChat{ id="quest",
	text = [[#LIGHT_GREEN#*He quickly looks at the tome and looks amazed.*#WHITE# This is an amazing find! Truly amazing!
With this knowledge I could create potent amulets. However, it requires a special place of power to craft such items.
There are rumours about a site of power in the southern mountains. Old legends tell about a place where a part of the Winterglow Moon melted when it got too close to the Sun and fell from the sky.
A lake formed in the crater of the crash. The water of this lake, soaked in intense Moonlight for eons, should be sufficient to forge powerful artifacts!
Go to the lake and then summon me with this scroll. I will retire to study the tome, awaiting your summon.]],
	answers = {
		{"제가 찾을 수 있는지 한번 알아보죠.", action=function(npc, player)
			game.level:removeEntity(npc)
			player:hasQuest("master-jeweler"):remove_tome(player)
			player:hasQuest("master-jeweler"):start_search(player)
		end},
	}
}

return "welcome"
