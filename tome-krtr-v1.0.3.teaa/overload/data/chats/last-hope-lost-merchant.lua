-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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

local p = game:getPlayer(true)

newChat{ id="welcome",
	text = [[아니, 제 #{italic}#친절한#{normal}# 친구, @playername@ 아니십니까!
당신 덕분에, 이 위대한 도시에 무사히 도착할 수 있었습니다! 이제 저는 이곳에서 가장 뛰어난 제품만을 취급하는 가게를 열 준비를 한창 하고 있습니다만, 당신에게 빚진 것도 있고 하니 당신만을 위해 가게를 미리 열도록 하지요. 희귀한 물건이 필요하시면 언제든지 오십시오.]]
..((p:knowTalent(p.T_TRAP_MASTERY) and not p:knowTalent(p.T_FLASH_BANG_TRAP)) and "\n아, 그리고 탈출하는 동안 제가 #YELLOW#섬광 폭발 함정#LAST# 설계도를 발견했습니다. 혹시 이것에 대해 관심이 있나요?" or "")
..((game.state:isAdvanced() and "\n오, 친구여. 좋은 소식이 있습니다! 제가 저번에 말했듯이, 이제 당신만을 위해 만들어지는 정말로 #{italic}#특별한#{normal}# 장비들을 주문할 수 있게 되었습니다. 물론 정말 특별한 가격표가 붙습니다만..." or "\n저는 정말 뛰어난 안목을 지닌 고객만을 위한 아주 특별한 서비스를 계획하고 있습니다. 그 준비가 다 끝날 때 쯤에, 다시 한번 이곳을 들러주십시오! 당신만을 위한, 정말로 굉장한 장비들을 구할 수 있을겁니다. 물론 정말로 #{italic}#그에 걸맞는#{normal}# 가격표가 붙겠지만요.")),
	answers = {
		{"아, 그럼 물건들을 좀 봐볼까요.", action=function(npc, player)
			npc.store:loadup(game.level, game.zone)
			npc.store:interact(player)
		end},
		{"특별한 장비?", cond=function(npc, player) return game.state:isAdvanced() end, jump="unique1"},
		{"섬광 폭발 함정이요? 쓸모 있을 것 같은데요.", cond=function(npc, player) return p:knowTalent(p.T_TRAP_MASTERY) and not p:knowTalent(p.T_FLASH_BANG_TRAP) end, jump="trap"}, --@@ 한글화 필요
		{"아니, 이만 가보겠습니다!"},
	}
}

hat{ id="trap",
	text = [[사실, 이곳저곳에 물어보니까 이 기묘한 도구 설계도는 아주 희귀한 물건이라고 하더군요...
하지만 당신은 저를 구해주셨으니, 아주 싼 가격에 드리겠습니다. 금화 3,000 개만 주세요!]],
	answers = {
		{"흠, 비싸군요. 그래도 사겠습니다.", cond=function(npc, player) return player.money >= 3000 end, jump="traplearn"},
		{"..."},
	}
}

newChat{ id="traplearn",
	text = [[친구와 거래하는 것은 즐거운 일이지요. 여기 있습니다!]],
	answers = {
		{"고마워요.", action=function(npc, player)
			p:learnTalent(p.T_FLASH_BANG_TRAP, 1, nil, {no_unlearn=true})
			game.log("#LIGHT_GREEN#설계도를 손에 얻었습니다. 이제부터 당신은 섬광 폭발 함정을 제작할 수 있습니다!")
		end},
	}
}


newChat{ id="unique1",
	text = [[일반적으로는 그에 맞는 응당한 가격을 청구하지만, 당신은 제 친구니 20% 할인을 해드리지요. - #{italic}#딱#{normal}# 금화 4,000 개만 주시면 원하시는 종류의 엄청나게 희귀한 장비를 만들어 드리겠습니다. 어떠신가요?]],
	answers = {
		{"오, 그거 너무 싼거 아니예요? 당장 주문을 하죠. 가능한 빨리 상품 준비를 해 주세요!", cond=function(npc, player) return player.money >= 10000 end, jump="make"},
		{"좋죠. 부탁할게요!", cond=function(npc, player) return player.money >= 4000 end, jump="make"},
		{"얼마라고?! 어, 잠깐 좀 도와줘요. 시... 신선한 공기가 필요해...", cond=function(npc, player) return player.money < 500 end},
		{"감사합니다만, 지금은 됐습니다."},
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
			o = game.zone:makeEntity(game.level, "object", {name=name, ignore_material_restriction=true, no_tome_drops=true, ego_filter={keep_egos=true, ego_chance=-1000}}, nil, true)
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
						game.log("#CRIMSON#이미 결정된 미래에 대해서, 시간여행은 아무런 영향도 주지 않습니다.")
						game._chronoworlds = nil
					end
					game:saveGame()

					newChat{ id="naming",
						text = "물건에 이름을 붙이시겠습니까?\n"..tostring(art:getTextualDesc()),
						answers = {
							{"네, 부탁드립니다.", action=function(npc, player)
								local d = require("engine.dialogs.GetText").new("이름을 정하세요", "이름", 2, 40, function(txt)
									art.name = txt:removeColorCodes():gsub("#", " ")
									art.kr_name = art.name --@@ 사용자가 결정한 이름은 한글 이름도 같도록 그냥 저장
									game.log("#LIGHT_BLUE#상인이 조심스럽게 물건을 건네줍니다. : %s", art:getName{do_color=true})
								end, function() game.log("#LIGHT_BLUE#상인이 조심스럽게 물건을 건네줍니다, : %s", art:getName{do_color=true}) end)
								game:registerDialog(d)
							end},
							{"아뇨, 됐습니다.", action=function() game.log("#LIGHT_BLUE#상인이 조심스럽게 물건을 건네줍니다. : %s", art:getName{do_color=true}) end},
						},
					}
					return "naming"
				else
					newChat{ id="oups",
						text = "오, 미안한 일이지만 당신의 요구에 맞는 물건은 만들 수 없을 것 같네요.",
						answers = {
							{"오, 그러면 다른 장비를 선택하도록 하죠.", jump="make"},
							{"오, 그러면 다음에 만들도록 하죠."},
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
	text = [[어떤 종류의 장비를 원하시는지요?]],
	answers = maker_list(),
}

else

newChat{ id="welcome",
	text = [[*상점의 문은 아직 굳게 닫힌 상태입니다.*]],
	answers = {
		{"[떠난다]"},
	}
}

end

return "welcome"
