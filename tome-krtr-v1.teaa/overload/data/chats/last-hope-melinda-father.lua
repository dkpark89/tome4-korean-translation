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
		{"안녕하십니까, 멜린다와 이야기를 하고 싶어서 왔습니다.", jump="home1", switch_npc={name="Melinda"}, cond=function(npc, player) return ql and not ql:isCompleted("moved-in") end},
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
				game.logPlayer(player, "멜린다의 아버지가 당신에게 준 물건은 %s입니다.", ro:getName{do_color=true})
				game.zone:addEntity(game.level, ro, "object")
				player:addObject(player:getInven("INVEN"), ro)
			end
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
newChat{ id="scars",
	text = [[#LIGHT_GREEN#*그녀는 아랫배를 도발적으로 만지기 시작합니다.*#WHITE#
봐, 만져봐도 괜찮아. 더 이상 아프지 않으니까! 이건 너에게 하는 감사의 표시야, 너는 내... 친한 친구니까.]],
	answers = {
		{"아... 미안. 너희 아버지가 탐탁해 하지 않아할 것 같아. 잘 있어.", quick_reply="아버지라면 허락해주실거라 생각하지만, 네 생각이 그렇다면야... 잘 있어."},
		{"#LIGHT_GREEN#[그녀가 가리킨 곳을 만져본다] 그래, 이제 괜찮아진 것 같네.", jump="touch_male", cond=function(npc, player) return player.male end},
		{"#LIGHT_GREEN#[그녀가 가리킨 곳을 만져본다] 그래, 이제 괜찮아진 것 같네.", jump="touch_female", cond=function(npc, player) return player.female end},
	}
}

newChat{ id="touch_male",
	text = [[#LIGHT_GREEN#*그녀가 살짝 얼굴을 붉힙니다.*#WHITE#
당신의 손길은 부드러우면서도, 정말 엄청난 힘이 잠재되어 있다는걸 느낄 수 있네요.
기분 좋았어요. 다른 남자들이... 저에게 했던 짓을... 잊는데 도움이 될 것 같아요.]],
	answers = {
		{"네가 대화를 하고 싶다면, 여기에 내가 있어. 나는 그들을 보았고, 그들이 무엇을 하는지 보았어. 나는 너를 이해할 수 있어.", jump="request_explain"},
		{"나는 악마 숭배자가 아냐. 나는 너를 다치게 하지 않을거야.", jump="reassurance"},
		{"너는 이겨낼 수 있을거야. 걱정하지 마. 안녕, 멜린다. 잘 있어.", quick_reply="어려운 일이겠지만, 언젠가는 이겨낼 수 있겠죠. 잘 있어요."},
	}
}

newChat{ id="touch_female",
	text = [[#LIGHT_GREEN#*그녀가 살짝 얼굴을 붉힙니다.*#WHITE#
나는... 다른 여자의 손길이 이렇게... 부드러운 것인지 몰랐어요.
기분 좋았어요. 다른 남자들이... 저에게 했던 짓을... 잊는데 도움이 될 것 같아요.]],
	answers = {
		{"네가 대화를 하고 싶다면, 여기에 내가 있어. 나는 그들을 보았고, 그들이 무엇을 하는지 보았어. 나는 너를 이해할 수 있어.", jump="request_explain"},
		{"나는 악마 숭배자가 아냐. 나는 너를 다치게 하지 않을거야.", jump="reassurance"},
		{"너는 이겨낼 수 있을거야. 걱정하지 마. 안녕, 멜린다. 잘 있어.", quick_reply="어려운 일이겠지만, 언젠가는 이겨낼 수 있겠죠. 잘 있어요."},
	}
}

newChat{ id="request_explain",
	text = [[#LIGHT_GREEN#*그녀는 생각을 떠올리느라 잠시 동안 눈에 초점을 잃었습니다. 그녀의 눈에는 그 때의 공포가 다시 떠오릅니다.*#WHITE#
당신은 친절한 사람이군요, 고마워요. 하지만 아직은 그에 대한 이야기는 하고 싶지 않아요. 아직도 내 마음 속에 너무나도 선명하게 남아있는걸요!
#LIGHT_GREEN#*그녀가 울기 시작합니다.*#WHITE#]],
	answers = {
		{"#LIGHT_GREEN#[팔로 그녀를 안습니다] 이제 다 괜찮아. 너는 이제 안전해.", jump="hug"},
		{"울지 마! 너는 이제 안전하다니까!", quick_reply="응, 저도 알아요. 고마워요. 안녕히."},
	}
}

newChat{ id="reassurance",
	text = [[#LIGHT_GREEN#*그녀는 당신의 눈을 지긋이 쳐다봅니다.*#WHITE#
당신이 악마 숭배자가 아니라는 것은 저도 알아요. 당신이 그 공포에서 저를 구해주러 왔던 바로 그 순간, 당신은 믿을 수 있는 사람이라는걸 알았는걸요. 비록 그 광경이 공포스러웠을지는 모르지만, 그래도 저는 당신이 저를 보고 사랑에 빠졌다는 생각을 하는걸 좋아해요. 저는 당신을 보고 사랑에 빠진거구요.]],
	answers = {
		{"#LIGHT_GREEN#[팔로 그녀를 안습니다] 이제 다 괜찮아. 너는 이제 안전해.", jump="hug"},
		{"와, 잠깐만. 분명 너를 구해줘서 나는 기쁘지만, 그것 뿐이라고.", quick_reply="오, 미안해요. 잠깐 제정신이 아니였나봐요. 잘 있어요."},
	}
}

newChat{ id="hug",
	text = [[#LIGHT_GREEN#*당신은 멜린다를 강하게 끌어안았습니다. 그녀의 온기가 당신의 심장을 밝힙니다.*#WHITE#
당신의 팔에 안겨있으니 안전하다는 생각이 드네요. 부탁할게요, 당신이 떠나야한다는건 알아요. 하지만 언젠가는 이곳에 돌아와서, 저를 다시 안아주세요.]],
	answers = {
		{"아주 기쁘게 받아들이도록 하지. #LIGHT_GREEN#[그녀에게 키스한다]#WHITE#", action=function(npc, player) player:grantQuest("love-melinda") end},
		{"어두운 길을 걸어갈 때, 그 생각만 하면 힘이 날 것 같군. #LIGHT_GREEN#[그녀에게 키스한다]#WHITE#", action=function(npc, player) player:grantQuest("love-melinda") end},
		{"오, 미안해요. 오해하고 있는 것 같은데, 저는 그저 당신을 안심시키려고 했던거에요.", quick_reply="오, 미안해요. 제가 제정신이 아니였나봐요. 그럼 안녕히, 잘 있어요."},
	}
}

------------------------------------------------------------------
-- Moving in
------------------------------------------------------------------
newChat{ id="home1",
	text = [[#LIGHT_GREEN#*멜린다가 문을 열고 나타나, 당신에게 키스를 합니다.*#WHITE#
@playername@! 보고싶었어요!]],
	answers = {
		{"미안해요, 저 지금 조금 바빠서요. 뭐, 당신도 알잖아요. 언제나처럼 광신도들을 죽이고, 오래된 보물들을 찾는 일 말이에요."},
		{"사실, 우리를 위해서 하나 생각하고 있는게 있어, 얼마 전에, 굉장히 특별한 집을 하나 가지게 됐거든... #LIGHT_GREEN#[그녀에게 요새에 대한 이야기를 한다]#WHITE#", jump="home2", cond=function(npc, player) return ql and qs and qs:isCompleted("farportal") and not ql:isCompleted("moved-in") end},
	}
}

newChat{ id="home2",
	text = [[신비의 종족이 남긴 고대의 요새? 정말 #{bold}#흥미로운데요#{normal}#!]],
	answers = {
		{"정말 그렇지. 아마 나는 거기서 많은 시간을 쓰게 될거야. 그리고 아마, 혹시라도, 네가 거기서 나와 같이 살게된다면 말이지. 거기는 빈 방도 훨씬 많고...", jump="home3"},
		{"하지만 굉장히 위험한 곳이지... 어찌 됐건, 나는 이제 가봐야해. 시간 나면 다시 올게. #LIGHT_GREEN#[그녀에게 키스한다]#WHITE#"},
	}
}

newChat{ id="home3",
	text = [[#LIGHT_GREEN#*멜린다가 당신을 격렬하게 껴안더니, 키스를 하고 상점 안으로 달려갑니다. 그녀가 달려가면서 하는 말을 들었습니다.*#WHITE#
아빠, 더 이상 내 걱정은 하지 않아도 돼! 난 이제 이분과 함께 다른 데서 살거니까!]],
	answers = {
		{"승낙한걸로 생각할게. #LIGHT_GREEN#[그녀가 돌아오기를 기다렸다가, 요새로 이동합니다]#WHITE#", action=function(npc, player)
			game:changeLevel(1, "shertul-fortress", {direct_switch=true})
			player:hasQuest("love-melinda"):spawnFortress(player)
		end},
	}
}


end

return "welcome"
