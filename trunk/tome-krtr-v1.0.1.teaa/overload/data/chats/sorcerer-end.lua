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

local p = game.party:findMember{main=true}

local function void_portal_open(npc, player)
	-- Charred scar was successful
	if player:hasQuest("charred-scar") and player:hasQuest("charred-scar"):isCompleted("stopped") then return false end
	return true
end
local function aeryn_alive(npc, player)
	for uid, e in pairs(game.level.entities) do
		if e.define_as and e.define_as == "HIGH_SUN_PALADIN_AERYN" then return e end
	end
end


--------------------------------------------------------
-- Yeeks have a .. plan
--------------------------------------------------------
if p.descriptor.race == "Yeek" then
newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*두 주술사들은 당신 앞에서 죽음을 맞이하였습니다.*#WHITE#
#LIGHT_GREEN#*그들의 몸은 작은 먼지구름이 되어, 빠르게 소멸했습니다.*#WHITE#
#LIGHT_GREEN#*당신은 '한길' 에 속한 모든 이크들이 당신에게 말하는 것을 느꼈습니다.*#WHITE#
정말 굉장한 일을 해내었네, ]]..(p.female and "자매" or "형제")..[[여! 자네는 이크 종족을 위한 유일한 기회를 만들었네!
이 장거리 관문이 담고 있는 힘은 정말 굉장하다네. 이것을 이용하면, 우리는 '한길' 의 세력을 에이알 세계 전체로 확장시켜, 다른 종족들에게도 '한길' 이 가져다주는 평화와 행복을 누리게 해줄 수 있다네.
자네는 이제 장거리 관문에 들어가, 자신을 희생할 필요가 있다네. 자네의 정신은 장거리 관문과 연결되어, '한길' 의 힘을 전세계에 퍼뜨리게 될 것이라네!
비록 자네는 죽겠지만 자네의 의지는 세상에 남아, 이크에게 궁극의 평화를 가져다 줄 것이라네.
'한길' 은 결코 자네를 잊지 않을 것이라네. 이제 가서 역사를 만들게!
]],
	answers = {
		{"#LIGHT_GREEN#[자신을 희생하여 '한길'을 모든 이성 있는 생명체들에게 퍼뜨린다]", action=function(npc, player)
			player.no_resurrect = true
			player:die(player, {special_death_msg="자신을 희생하여 '한길'을 모두에게 퍼뜨린다"})
			player:setQuestStatus("high-peak", engine.Quest.COMPLETED, "yeek")
			player:hasQuest("high-peak"):win("yeek-sacrifice")
		end},
		{"하지만... 나는 이미 많은 일을 했습니다. 나는 살아있는 동안 '한길' 을 위해 더 많은 일을 할 수 있습니다!", jump="yeek-unsure"},
	}
}

newChat{ id="yeek-unsure",
	text = [[#LIGHT_GREEN#*당신은 '한길' 이 당신의 몸과 마음의 통제권을 뺏어가는 것을 느낍니다.*#WHITE#
모든 이크들을 위해, 시키는대로 하게! '한길' 은 언제나 옳다네!
]],
	answers = {
		{"#LIGHT_GREEN#[자신을 희생하여 '한길'을 모든 이성 있는 생명체들에게 퍼뜨린다]", action=function(npc, player)
			player.no_resurrect = true
			player:die(player, {special_death_msg="자신을 희생하여 '한길'을 모두에게 퍼뜨린다"})
			player:setQuestStatus("high-peak", engine.Quest.COMPLETED, "yeek")
			player:hasQuest("high-peak"):win("yeek-sacrifice")
		end},
	}
}

return "welcome"
end

--------------------------------------------------------
-- Default
--------------------------------------------------------

---------- If the void portal has been opened
if void_portal_open(nil, p) then
newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*두 주술사들은 당신 앞에서 죽음을 맞이하였습니다.*#WHITE#
#LIGHT_GREEN#*그들의 몸은 작은 먼지구름이 되어, 빠르게 소멸했습니다.*#WHITE#
하지만 공허로 통하는 관문은 이미 열리고 말았습니다. 곧 창조자가 강림해, 모든 것이 허사가 되버릴 것입니다!
주술사들의 잔해를 뒤져본 결과, 당신은 관문을 닫기 위해서는 이성 있는 생명체의 희생이 필요하다는 내용이 적힌 쪽지를 발견하였습니다.]],
	answers = {
		{"아에린, 미안하지만 우리 둘 중 하나는 이 세계를 위해 희생해야 합니다. #LIGHT_GREEN#[세계의 평화를 위해, 아에린을 희생시킨다]", jump="aeryn-sacrifice", cond=aeryn_alive},
		{"제가 관문을 닫죠. #LIGHT_GREEN#[세계의 평화를 위해, 자신을 희생한다]", action=function(npc, player)
			player.no_resurrect = true
			player:die(player, {special_death_msg="세계의 평화를 위해 자신을 희생한다"})
			player:hasQuest("high-peak"):win("self-sacrifice")
		end},
	}
}

newChat{ id="aeryn-sacrifice",
	text = [[저는 우리가 성공할 것이라는 생각조차 하지 않았었습니다. 죽을 준비를 하고 왔으며, 이제 제가 죽어야 할 때인가 보군요. 하지만, 적어도 제 희생을 헛되게 하지는 말아주십시오.
부탁드립니다. 이 세상을 안전하게 지켜주십시오.]],
	answers = {
		{"당신은 영원히 잊혀지지 않을 것입니다.", action=function(npc, player)
			local aeryn = aeryn_alive(npc, player)
			game.level:removeEntity(aeryn, true)
			player:hasQuest("high-peak"):win("aeryn-sacrifice")
		end},
	}
}

----------- If the void portal is still closed
else
newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*두 주술사들은 당신 앞에서 죽음을 맞이하였습니다.*#WHITE#
#LIGHT_GREEN#*그들의 몸은 작은 먼지구름이 되어, 빠르게 소멸했습니다.*#WHITE#
당신은 승리했습니다!
마즈'에이알 대륙과 동대륙은 주술사들과 그들의 신이 뻗친 마수를 벗어나, 평화를 되찾았습니다.]],
	answers = {
		{"아에린, 몸은 괜찮으십니까?", jump="aeryn-ok", cond=aeryn_alive},
		{"[떠난다]", action=function(npc, player) player:hasQuest("high-peak"):win("full") end},
	}
}

newChat{ id="aeryn-ok",
	text = [[우리가 성공할 것이라는 생각은 하지 않았었습니다. 죽을 준비를 하고 이곳에 왔지만, 아직도 저는 살아있군요.
당신을 과소평가했던 것 같습니다. 당신은 우리가 예상한 것 이상의 일을 해주셨습니다!]],
	answers = {
		{"아뇨, 우리 둘이 해낸 일입니다.", action=function(npc, player) player:hasQuest("high-peak"):win("full") end},
	}
}
end


return "welcome"
