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
		{"건강한 것을 보니 나도 기분이 좋군 그래. 몸에 난 흉터들은 이제 괜찮아?", jump="scars", cond=function(npc, player)
			if player:attr("undead") then return false end
			return true
		end,},
		{"다시 보게되어 반갑군. 그럼 이만, 몸 관리 잘하길."},
	}
}

------------------------------------------------------------------
-- Flirting
------------------------------------------------------------------
--@@ 한글화 필요 #84~181 : 내용 대부분 변경됨 (중간의 hug 부분만 그대로임)
newChat{ id="scars",
	text = [[네, 많이 괜찮아졌어요. 가끔 악몽에 시달리기는 하지만요. 아직 무언가가 제 몸 속에 숨어있는 것 같아요.
	그래도, 제가 겪었던 운명에 비하면 악몽 정도는 아무 것도 아니죠! 정말 구해주셔서 감사해요.]],
	answers = {
		{"여행하는 동안 당신을 도울 방법을 찾게 된다면, 이곳에 다시 오도록 하지.", quick_reply="고마워요. 당신의 방문은 언제나 환영이에요."},
		{"확실히 그렇지. 그래서, 앞으로의 계획이라도 있어?", jump="plans"},
	}
}
newChat{ id="rewelcome",
	text = [[안녕하세요, @playername@! 이제 제법 괜찮아지긴 했지만, 요즘 제대로 잠에 들지 못하고 있어요...]],
	answers = {
		{"그래서, 앞으로의 계획이라도 있어?", jump="plans"},
		{"그렇다면, 가끔 나와 함께 밖에 나가서 기분 전환이라도 하는건...", jump="hiton", cond=function() return not ql.inlove and not ql.nolove end},
	}
}
newChat{ id="rewelcome-love",
	text = [[#LIGHT_GREEN#*멜린다가 문에서 나와, 당신에게 키스합니다*#WHITE#
안녕, 나의 연인. 당신을 보게 되어 정말 기뻐요!]],
	answers = {
		{"나는 아직 그 해변에서 무슨 일이 일어났는지에 대해 알아보고 있어."},
		{"해변에서 일어난 일에 대해, 뭔가 알아낸 것 같아.", jump="home1", cond=function() return ql:isStatus(engine.Quest.COMPLETED, "can_come_fortress") end},
	}
}

local p = game:getPlayer(true)
local is_am = p:attr("forbid_arcane")
local is_mage = (p.faction == "angolwen") or p:isQuestStatus("mage-apprentice", engine.Quest.DONE)
newChat{ id="plans",
	text = [[이유는 잘 모르겠지만, 제 아버지는 제가 완전히 회복되기 전까지 저를 내보내려 하지 않으세요. 저는 정말 다양한 것들을 해보고 싶은데 말이죠.
	제가 지하실에 갇혔던 것도 그 때문이었죠, 저는 제 눈으로 세계를 둘러보고 싶었어요.
	제 아버지가 저에게 자금을 약간 주셔서, 저는 제 손으로 제 미래를 개척해나갈 수 있어요. 데르스에 친구가 몇 있으니, 그곳에서 제 작은 상점을 열 수도 있겠지요. ]]..(
is_am and
	[[아니면, 저는 당신이 어떻게 그 오염된 자들과 싸우는지 보았어요. 당신이 마법을 파괴하던 그 장면을요. 저도 그와 같은 것을 배우고 싶어요. 그 끔찍한 공포가 다시는, 누구에게도 일어나지 않도록 말이죠.]]
or (is_mage and
	[[아니면, 당신이라면 믿을 수 있으니 말하는 것이지만, 저는 언제나 마법을 배우고 싶다는 생각을 비밀스럽게 해왔어요. 연금술 같은 가짜가 아닌, 진짜 마법요!
	저는 비밀스러운 장소에 대한 장소에 대해 들었어요. 앙골웬, 그곳에서 마법을 배울 수 있다고 해요.]]
or [[]])),
	answers = (not is_am and not is_mage) and {
		{"데르스에도 장단점이 있긴 하지만, 당신 같은 똑똑한 여자라면 그들도 반길 것 같아.", action=function() ql.wants_to = "derth" end, quick_reply="네, 고마워요!"},
	} or {
		{"데르스에도 장단점이 있긴 하지만, 당신 같은 똑똑한 여자라면 그들도 반길 것 같아.", action=function() ql.wants_to = "derth" end, quick_reply="네, 고마워요!"},
		{"우리의 마법에 대한 성전의 일원이 되고싶다고? 좋아! 그들에게 당신에 대한 이야기를 해볼게.", action=function() ql.wants_to = "antimagic" end, cond=function() return is_am end, quick_reply="정말로 친절하시군요!"},
		{"나는 앙골웬의 사람들에게 환영 받는 사람이니, 당신에 대한 이야기를 해볼 수 있을 것 같아.", action=function() ql.wants_to = "magic" end, cond=function() return is_mage end, quick_reply="정말로 친절하시군요!"},
	}
}

newChat{ id="hiton",
	text = [[네?!? 그 섬뜩한 죽음으로부터 위험을 무릅쓰고 저를 구해주신 것 뿐만이 아닌, 저에게 자유를 주시겠다고요?!]],
	answers = {
		{"그래, 역시 나 같은 멋진 "..(p.female and "여자" or "남자").."에게 매혹되지 않는 여자 따위는 없...", quick_reply="어어, 죄송하지만 제 아버지가 부르세요. 그럼 다음에 뵈요.", action=function() ql.nolove = true end},
		{"잠깐 잠깐, 나는 그저...", jump="reassurance"},
	}
}

newChat{ id="reassurance",
	text = [[#LIGHT_GREEN#*그녀는 쾌활하게 당신을 쳐다봤습니다.*#WHITE#
농담이에요. 정말 좋은 생각 같아요!]],
	answers = {
		{"#LIGHT_GREEN#[그녀와 함께 걷는다]#WHITE#남쪽으로 잠깐 여행을 떠나는건 어때? 해안가에 가면 검게 탄 상처 화산지대도 볼 수 있어. 정말 멋진 광경이라고.", action=function() ql.inlove = true ql:toBeach() end},
		{"사실 나도 농담이었지. 그럼 안녕!", quick_reply="하지만... 네, 그럼 안녕.", action=function() ql.nolove = true end},
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
	text = [[#LIGHT_GREEN#*멜린다는 걱정된다는 듯이 당신을 쳐다봅니다*#WHITE#
부디 저를 도울 수 있다고 말해주세요!]],
	answers = {
		{"응, 그럴 수 있을 것 같아. 그게 얼마 전에, 굉장히 특별한 집을 하나 가지게 됐거든... #LIGHT_GREEN#[그녀에게 요새에 대한 이야기를 한다]#WHITE#", jump="home2"},
	}
}

newChat{ id="home2",
	text = [[신비의 종족이 남긴 고대의 요새? 정말 #{bold}#흥미로운데요#{normal}#!
게다가 요새에서 제 치료가 가능하다고요?]],
	answers = {
		{"요새에서는 그럴 수 있다고 해. 조금 .. 부적절한 .. 말이라는 건 알지만, 치료를 위해 그곳에서 잠시 살 필요가 있을 것 같아.", jump="home3"},
	}
}

newChat{ id="home3",
	text = [[#LIGHT_GREEN#*그녀는 쾌활하게 당신을 쳐다봤습니다*#WHITE#
	아, 드디어 저와 같이 침대에 들어가려는 계획이 드러났군요!
	쉿, 이 바보. 그런 말 하지 않아도 저는 갈거에요. 제 건강을 위해서, 그리고 당신과 함께 있기 위해서.
	#LIGHT_GREEN#*그녀가 다정하게 당신과 키스합니다*#WHITE#]],
	answers = {
		{"그렇다면 나의 숙녀여, 저를 따라와주시겠습니까. #LIGHT_GREEN#[그녀를 요새로 데리고 간다]", action=function(npc, player)
			game:changeLevel(1, "shertul-fortress", {direct_switch=true})
			player:hasQuest("love-melinda"):spawnFortress(player)
		end},
	}
}

end

return "welcome"
