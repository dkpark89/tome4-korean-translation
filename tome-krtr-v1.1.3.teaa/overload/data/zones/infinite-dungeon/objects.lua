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

require "engine.krtrUtils"

load("/data/general/objects/objects.lua")

newEntity{
	power_source = {technique=true},
	unique = true,
	type = "potion", subtype="potion",
	name = "Potion of Martial Prowess",
	unided_name = "phial filled with metallic liquid",
	kr_name = "호전적 역량의 물약", kr_unided_name = "금속빛 액체로 가득 찬 약병",
	level_range = {1, 50},
	display = '!', color=colors.VIOLET, image="object/elixir_of_stoneskin.png",
	encumber = 0.4,
	rarity = 150,
	desc = [[이 엘릭서는, 전투의 기본기를 무시한 불행한 이에게 호전적 전투에 대한 기본적인 식견을 제공합니다.]],
	cost = 500,

	use_simple = { name = "quaff the elixir", kr_name = "엘릭서 마시기", use = function(self, who)
		game.logSeen(who, "%s %s 마셨습니다!", (who.kr_name or who.name):capitalize():addJosa("가"), self:getName():addJosa("를"))

		local done = 0

		if not who:knowTalentType("technique/combat-training") then
			who:learnTalentType("technique/combat-training", true)
			game.logPlayer(who, "#VIOLET#당신은 기본적인 전투 수련법을 알게 되었습니다 (전투장비 수련 기술계열 습득).")
			done = done + 1
		end
		if not who:knowTalent(who.T_SHOOT) then
			who:learnTalent(who.T_SHOOT, true, nil, {no_unlearn=true})
			game.logPlayer(who, "#VIOLET#당신은 활과 투석구를 사용하는 방법을 알게 되었습니다.")
			done = done + 1
		end
		if not ( who:knowTalentType("spell/staff-combat") or who:knowTalentType("spell/staff-combat") == false ) then 
			who:learnTalentType("spell/staff-combat", false)
			game.logPlayer(who, "#VIOLET#지팡이를 사용하여 마음속에서 분출하는 당신의 상상으로 사람들을 공격할 수 있게 되었습니다 (지팡이 전투기술 기술계열 습득).")
			done = done + 1
		end
		if not ( who:knowTalentType("wild-gift/mindstar-mastery") or who:knowTalentType("wild-gift/mindstar-mastery") == false ) then 
			who:learnTalentType("wild-gift/mindstar-mastery", false)
			game.logPlayer(who, "#VIOLET#당신은 마석을 통해 정신력을 뿜어내는 방법을 알게 되었습니다 (마석 수련 기술계열 습득).")
			done = done + 1
		end

		if done == 0 then
			game.logPlayer(who, "#VIOLET#당신은 이미 이 엘릭서가 알려줄 수 있는 모든 것을 알고 있는 것 같습니다.")
		end

		return {used=true, id=true, destroy=true}
	end},
}

newEntity{
	power_source = {technique=true},
	unique = true,
	type = "potion", subtype="potion",
	name = "Antimagic Wyrm Bile Extract",
	unided_name = "phial filled with slimy liquid",
	kr_name = "반마법의 용 담즙 추출물", kr_unided_name = "끈적이는 액체로 가득 찬 약병",
	level_range = {10, 50},
	display = '!', color=colors.VIOLET, image="object/elixir_of_avoidance.png",
	encumber = 0.4,
	rarity = 150,
	desc = [[강력한 용에게서 추출해낸 이 엘릭서는, 모든 마법적인 힘을 제압하는 능력을 제공합니다.]],
	cost = 500,

	use_simple = { name = "quaff the elixir", kr_name = "엘릭서 마시기", use = function(self, who, inven, item)
		local d = require("engine.ui.Dialog"):yesnoLongPopup("반마법", [[이 물약을 마시면 당신은 반마법 기술을 사용할 수 있게 됩니다. 하지만 그 댓가로 룬과 마법의 힘이 담긴 물건, 그리고 주문을 모두 사용할 수 없게 됩니다.]], 500, function(ret)
			if ret then
				game.logSeen(who, "%s %s 마셨습니다!", (who.kr_name or who.name):capitalize():addJosa("가"), self:getName():addJosa("를"))

				who:removeObject(inven, item)

				for tid, _ in pairs(who.sustain_talents) do
					local t = who:getTalentFromId(tid)
					if t.is_spell then who:forceUseTalent(tid, {ignore_energy=true}) end
				end

				-- Remove equipment
				for inven_id, inven in pairs(who.inven) do
					for i = #inven, 1, -1 do
						local o = inven[i]
						if o.power_source and o.power_source.arcane then
							game.logPlayer(who, "당신은 더 이상 %s 사용할 수 없습니다. 그것은 마법으로 오염된 물건입니다.", o:getName{do_color=true}:addJosa("를"))
							local o = who:removeObject(inven, i, true)
							who:addObject(who.INVEN_INVEN, o)
							who:sortInven()
						end
					end
				end

				who:attr("forbid_arcane", 1)
				who:learnTalentType("wild-gift/antimagic", true)
				who:learnTalent(who.T_RESOLVE, true, nil, {no_unlearn=true})
			end
		end, "마신다", "취소")

		return {used=true, id=true}
	end},
}
