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

require "engine.krtrUtils"

local imbue_ring = function(npc, player)
	player:showInventory("어떤 반지에 보석을 주입시킵니까?", player:getInven("INVEN"), function(o) return o.type == "jewelry" and o.subtype == "ring" and not o.egoed and not o.unique and not o.rare end, function(ring, ring_item)
		player:showInventory("어떤 보석을 사용합니까?", player:getInven("INVEN"), function(gem) return gem.type == "gem" and (gem.material_level or 99) <= ring.material_level and gem.imbue_powers end, function(gem, gem_item)
			local price = 10 + gem.material_level * 5 + ring.material_level * 7
			if price > player.money then require("engine.ui.Dialog"):simplePopup("돈이 부족합니다", "돈이 부족하시군요. 소지금이 금화 "..price.." 개 정도가 되면 그 때 오시지요.") return end

			require("engine.ui.Dialog"):yesnoPopup("보석 주입 가격", "비용으로 금화 "..price.."개가 필요합니다. 보석 주입을 하시겠습니까?", function(ret) if ret then
				player:incMoney(-price)
				player:removeObject(player:getInven("INVEN"), gem_item)
				ring.wielder = ring.wielder or {}
				table.mergeAdd(ring.wielder, gem.imbue_powers, true)
				if gem.talent_on_spell then
					ring.talent_on_spell = ring.talent_on_spell or {}
					table.append(ring.talent_on_spell, gem.talent_on_spell)
				end
				ring.name = gem.name .. " ring"
				ring.kr_name = (gem.kr_name or gem.name) .. "반지"
				ring.been_imbued = true
				ring.egoed = true
				game.logPlayer(player, "%s %s 만들었습니다", (npc.kr_name or npc.name):capitalize():addJosa("가"), ring:getName{do_colour=true, no_count=true}:addJosa("를"))
			end end, "예", "아니오")
		end)
	end)
end

local artifact_imbue_amulet = function(npc, player)
	player:showInventory("어떤 목걸이에 보석을 주입시킵니까?", player:getInven("INVEN"), function(o) return o.type == "jewelry" and o.subtype == "amulet" and not o.egoed and not o.unique and not o.rare end, function(amulet, amulet_item)
		player:showInventory("어떤 보석을 첫 번째로 사용합니까?", player:getInven("INVEN"), function(gem1) return gem1.type == "gem" and (gem1.material_level or 99) <= amulet.material_level and gem1.imbue_powers end, function(gem1, gem1_item)
			player:showInventory("두 번째 보석은 무엇을 사용합니까?", player:getInven("INVEN"), function(gem2) return gem2.type == "gem" and (gem2.material_level or 99) <= amulet.material_level and gem1.name ~= gem2.name and gem2.imbue_powers end, function(gem2, gem2_item)
				local price = 390
				if price > player.money then require("engine.ui.Dialog"):simplePopup("돈이 부족합니다", "리미르가 목걸이를 도금하기 위해서는 더 많은 금화가 필요합니다.") return end

				require("engine.ui.Dialog"):yesnoPopup("목걸이 도금 가격", "도금을 하려면 금화 "..price.." 개가 필요합니다, 목걸이를 만드시겠습니까?", function(ret) if ret then
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
					if gem1.talent_on_spell then
						amulet.talent_on_spell = amulet.talent_on_spell or {}
						table.append(amulet.talent_on_spell, gem1.talent_on_spell)
					end
					if gem2.talent_on_spell then
						amulet.talent_on_spell = amulet.talent_on_spell or {}
						table.append(amulet.talent_on_spell, gem2.talent_on_spell)
					end
					if gem3.talent_on_spell then
						amulet.talent_on_spell = amulet.talent_on_spell or {}
						table.append(amulet.talent_on_spell, gem3.talent_on_spell)
					end
					amulet.name = "Limmir's Amulet of the Moon"
					amulet.kr_name = "리미르제 달의 목걸이"
					amulet.been_imbued = true
					amulet.unique = util.uuid()
					game.logPlayer(player, "%s %s 만들었습니다.", (npc.kr_name or npc.name):capitalize():addJosa("가"), amulet:getName{do_colour=true, no_count=true}:addJosa("를"))
				end end, "예", "아니오")
			end)
		end)
	end)
end

newChat{ id="welcome",
	text = [[제 상점에 오신걸 환영합니다, @playername@씨.]],
	answers = {
		{"당신이 가진 물건을 보여주시죠.", action=function(npc, player)
			npc.store:loadup(game.level, game.zone)
			npc.store:interact(player)
		end, cond=function(npc, player) return npc.store and true or false end},
		{"저는 조금 특수한 장신구를 만들고 싶습니다.", jump="jewelry"},
		{"목걸이에 보석 주입을 하러 왔습니다.", jump="artifact_jewelry", cond=function(npc, player) return npc.can_craft and player:hasQuest("master-jeweler") and player:isQuestStatus("master-jeweler", engine.Quest.COMPLETED, "limmir-survived") end},
		{"이런 큰 책을 찾았습니다. 중요한 책으로 보이더군요.", jump="quest", cond=function(npc, player) return npc.can_quest and player:hasQuest("master-jeweler") and player:hasQuest("master-jeweler"):has_tome(player) end},
		{"아무 것도 아닙니다. 이만 가볼게요!"},
	}
}

newChat{ id="jewelry",
	text = [[그렇다면 제대로 찾아오셨습니다. 저는 보석과 장신구에는 일가견이 있으니까요.
저에게 마법적 능력이 없는 반지와 보석을 가져오시면, 반지에 보석의 힘을 주입시켜 드리겠습니다.
반지의 등급에 따라 소정의 비용이 필요하며, 고급 보석을 사용하시려면 그에 맞는 수준의 반지를 가져오셔야 합니다.]],
	answers = {
		{"그럼 어디 한번 해 봅시다.", action=imbue_ring},
		{"고맙지만, 지금은 됐습니다."},
	}
}

newChat{ id="artifact_jewelry",
	text = [[네! 당신 덕분에 이곳의 타락은 정화되었습니다. 저는 이곳에 머물면서 이곳의 마법적 힘을 연구하고 있겠습니다. 그리고 약속한대로, 강력한 목걸이를 만들어 드리겠습니다.
마법적 능력이 없는 목걸이와 두 가지 다른 종류의 보석을 가져오시면, 강력한 목걸이로 만들어 드리겠습니다.
저를 많이 도와주셨기 때문에 따로 요금은 받지 않겠습니다만, 이 의식을 위해서는 목걸이를 도금할 필요가 있습니다. 그래서 금화 390 개 정도가 필요할 것 같습니다.]],
	answers = {
		{"그럼 어서 해보도록 하죠.", action=artifact_imbue_amulet},
		{"고맙지만, 지금은 됐습니다."},
	}
}

newChat{ id="quest",
	text = [[#LIGHT_GREEN#*그는 빠르게 책을 훑어보더니, 놀란 표정을 지었습니다.*#WHITE# 이건 정말 굉장한 발견이로군! 정말로 굉장해!
이 지식이 있으면, 저는 강력한 목걸이를 만들어낼 수 있습니다. 하지만, 그것을 만들기 위해서는 특별한 장소가 필요합니다.
소문에 의하면, 남쪽 산맥의 어딘가에 강력한 힘이 모인 장소가 있다고 합니다. 오래된 전설에 의하면, 그 장소는 태양과 너무 가까이 있었기 때문에 녹아버린 겨울빛 달의 일부분이 떨어진 곳이라고 하더군요.
달이 떨어지면서 생긴 충격으로 인해, 주변에는 호수가 생겼다고 합니다. 그리고 그 호수의 물은 영겁의 시간 동안 달빛의 힘을 받아, 강력한 장비를 만들어낼 수 있다고 합니다.
그 호수를 발견하게 되면, 이 두루마리로 저를 소환해주십시오. 그동안 저는 이 책에 써진 내용을 더 연구하고 있겠습니다. 당신의 소환을 기다리겠습니다.]],
	answers = {
		{"제가 찾을 수 있을지는 모르겠지만, 한번 알아보죠.", action=function(npc, player)
			game.level:removeEntity(npc)
			player:hasQuest("master-jeweler"):remove_tome(player)
			player:hasQuest("master-jeweler"):start_search(player)
		end},
	}
}

return "welcome"
