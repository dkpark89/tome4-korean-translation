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

local q = game.player:hasQuest("kryl-feijan-escape")
local qs = game.player:hasQuest("shertul-fortress")
local ql = game.player:hasQuest("love-melinda")

if not q or not q:isStatus(q.DONE) then

newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*한 남자가 문을 절반만 연 채, 안에서 슬픈 목소리로 말했습니다.*#WHITE#
미안합니다, 이곳은 휴업 중입니다.]],
	answers = {
		{"[떠난다]"},
	}
}

else

------------------------------------------------------------------
-- Saved
------------------------------------------------------------------

newChat{ id="welcome",
	text = [[@playername@! 내 딸을 구해준 은인이여!]],
	answers = {
		{"안녕하십니까, 그냥 멜린다가 괜찮은지 확인하러 왔습니다.", jump="reward", cond=function(npc, player) return not npc.rewarded_for_saving_melinda end, action=function(npc, player) npc.rewarded_for_saving_melinda = true end},
		{"안녕하십니까, 멜린다와 이야기를 하고 싶어서 왔습니다.", jump="rewelcome", switch_npc={name="Melinda"}, cond=function(npc, player) return ql and not ql:isCompleted("moved-in") and not ql.inlove end},
		{"안녕하십니까, 멜린다와 이야기를 하고 싶어서 왔습니다.", jump="rewelcome-love", switch_npc={name="Melinda"}, cond=function(npc, player) return ql and not ql:isCompleted("moved-in") and ql.inlove end},
		{"미안합니다, 이만 가보겠습니다!"},
	}
}

newChat{ id="reward",
	text = [[이걸 받아주게. 내 아이의 생명에 비하면 아무 것도 아니지만 말일세. 오, 그리고 그녀가 개인적으로 당신에게 감사를 표하고 싶다는군. 그녀를 불러오겠네.]],
	answers = {
		{"감사합니다.", jump="melinda", switch_npc={name="Melinda"}, action=function(npc, player)
			local ro = game.zone:makeEntity(game.level, "object", {unique=true, not_properties={"lore"}}, nil, true)
			if ro then
				ro:identify(true)
				game.logPlayer(player, "멜린다의 아버지가 당신에게 %s 건네 줬습니다.", ro:getName{do_color=true}:addJosa("를"))
				game.zone:addEntity(game.level, ro, "object")
				player:addObject(player:getInven("INVEN"), ro)
			end
			player:grantQuest("love-melinda")
			ql = player:hasQuest("love-melinda")
		end},
	}
}
newChat{ id="melinda",
	text = [[@playername@! #LIGHT_GREEN#*그녀는 기뻐하며 당신에게 뛰어들어 안깁니다. 그녀의 아버지는 가게를 보러 돌아갔습니다.*#WHITE#]],
	answers = {
		{"건강한 것을 보니 나도 기분이 좋군 그래. 몸에 난 흉터들도 빨리 회복되길.", jump="scars", cond=function(npc, player)
			if player:attr("undead") then return false end
			return true
		end,},
		{"다시 보게되어 반갑군. 몸 관리 잘하길."},
	}
}

------------------------------------------------------------------
-- Flirting
------------------------------------------------------------------
--@@ 한글화 필요 #84~181 : 내용 대부분 변경됨 (중간의 hug 부분만 그대로임)
newChat{ id="scars",
	text = [[Yes it has mostly healed, though I still do nightmares. I feel like something is still lurking.
Ah well, the bad dreams are still better than the fate you saved me from!]],
	answers = {
		{"Should I come across a way to help you during my travels, I will try to help.", quick_reply="Thank you, you are most welcome."},
		{"Most certainly, so what are your plans now?", jump="plans"},
	}
}
newChat{ id="rewelcome",
	text = [[Hi @playername@! I am feeling better now, even starting to grow restless...]],
	answers = {
		{"So what are your plans now?", jump="plans"},
		{"About that, I was thinking that maybe you'd like to go out with me sometime ...", jump="hiton", cond=function() return not ql.inlove and not ql.nolove end},
	}
}
newChat{ id="rewelcome-love",
	text = [[#LIGHT_GREEN#*Melinda appears at the door and kisses you*#WHITE#
Hi my dear, I'm so happy to see you!]],
	answers = {
		{"I am still looking out for an explanation of what happened at the beach."},
		{"About what happened on the beach, I think I have found something.", jump="home1", cond=function() return ql:isStatus(engine.Quest.COMPLETED, "can_come_fortress") end},
	}
}

local p = game:getPlayer(true)
local is_am = p:attr("forbid_arcane")
local is_mage = (p.faction == "angolwen") or p:isQuestStatus("mage-apprentice", engine.Quest.DONE)
newChat{ id="plans",
	text = [[I do not know yet, my father won't let me out until I'm fully healed. I've always wanted to do so many things.
That is why I got stuck in that crypt, I want to see the world.
My father gave me some funds so that I can take my future into my own hands. I have some friends in Derth, maybe I will open my own little shop there. ]]..(
is_am and
	[[I have seen how you fought those corruptors, the way you destroyed their magic. I want to learn to do the same, so that such horrors never happen again. To anyone.]]
or (is_mage and
	[[Or maybe, well I suppose I can trust you with this, I've always secretly dreamt of learning magic. Real magic I mean not alchemist tricks!
I've learnt about a secret place, Angolwen, where I could learn it.]]
or [[]])),
	answers = (not is_am and not is_mage) and {
		{"Derth has its up and downs but I think they could do with a smart girl yes.", action=function() ql.wants_to = "derth" end, quick_reply="Thanks!"},
	} or {
		{"Derth has its up and downs but I think they could do with a smart girl yes.", action=function() ql.wants_to = "derth" end, quick_reply="Thanks!"},
		{"You wish to join our noble crusade against magic? Wonderful! I will talk to them for you.", action=function() ql.wants_to = "antimagic" end, cond=function() return is_am end, quick_reply="That would be very nice!"},
		{"I happen to be welcome among the people of Angolwen, I could say a word for you.", action=function() ql.wants_to = "magic" end, cond=function() return is_mage end, quick_reply="That would be very nice!"},
	}
}

newChat{ id="hiton",
	text = [[What?!?  Just because you rescued me from a moderately-to-extremely gruesome death, you think that entitles you to take liberties?!]],
	answers = {
		{"WHY AREN'T WOMEN ATTRACTED TO ME I'M A NICE "..(p.female and "GIRL" or "GUY")..".", quick_reply="Uhh, sorry I hear my father calling, see you.", action=function() ql.nolove = true end},
		{"Just a minute, I was just ...", jump="reassurance"},
	}
}

newChat{ id="reassurance",
	text = [[#LIGHT_GREEN#*She looks at you cheerfully.*#WHITE#
Just kidding. I would love that!]],
	answers = {
		{"#LIGHT_GREEN#[walk away with her]#WHITE#What about a little trip to the south, from the coastline we can see the Charred Scar Volcano, it is a wonderous sight.", action=function() ql.inlove = true ql:toBeach() end},
		{"Joke's on you really, goodbye!", quick_reply="But... ok goodbye.", action=function() ql.nolove = true end},
	}
}

newChat{ id="hug",
	text = [[#LIGHT_GREEN#*당신은 멜린다를 강하게 끌어안았습니다. 그녀의 온기가 당신의 심장을 밝힙니다.*#WHITE#
당신의 팔에 안겨있으니 안전하다는 생각이 드네요. 부탁할게요, 당신이 떠나야한다는건 알아요. 하지만 언젠가는 이곳에 돌아와서, 저를 다시 안아주세요.]],
	answers = {
		{"아주 기쁘게 받아들이도록 하지. #LIGHT_GREEN#[그녀에게 키스한다]#WHITE#", action=function(npc, player)  end},
		{"어두운 길을 걸어갈 때, 그 생각만 하면 힘이 날 것 같군. #LIGHT_GREEN#[그녀에게 키스한다]#WHITE#", action=function(npc, player) player:grantQuest("love-melinda") end},
		{"오, 미안해요. 오해하고 있는 것 같은데, 저는 그저 당신을 안심시키려고 했던거에요.", quick_reply="오, 미안해요. 제가 제정신이 아니였나봐요. 그럼 안녕히, 잘 있어요."},
	}
}

------------------------------------------------------------------
-- Moving in
------------------------------------------------------------------
newChat{ id="home1",
	text = [[#LIGHT_GREEN#*Melinda looks worried*#WHITE#
Please tell me you can help!]],
	answers = {
		{"Yes, I think so. 얼마 전에, 굉장히 특별한 집을 하나 가지게 됐거든... #LIGHT_GREEN#[그녀에게 요새에 대한 이야기를 한다]#WHITE#", jump="home2"},
	}
}

newChat{ id="home2",
	text = [[신비의 종족이 남긴 고대의 요새? 정말 #{bold}#흥미로운데요#{normal}#!
And you say it could cure me?]],
	answers = {
		{"The Fortress seems to think so. I know this might sound a bit .. inappropriate .. but you would need to come live there, at least for a while.", jump="home3"},
	}
}

newChat{ id="home3",
	text = [[#LIGHT_GREEN#*She looks at you cheerfully*#WHITE#
Ah the plan to sleep with me is finally revealed!
Shhh you dummy, I thought we were past such silliness, I will come, both for my health and because I want to be with you.
#LIGHT_GREEN#*She kisses you tenderly*#WHITE#]],
	answers = {
		{"Then my lady, if you will follow me. #LIGHT_GREEN#[take her to the Fortress]", action=function(npc, player)
			game:changeLevel(1, "shertul-fortress", {direct_switch=true})
			player:hasQuest("love-melinda"):spawnFortress(player)
		end},
	}
}

end

return "welcome"
