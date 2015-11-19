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

local entershop = function (self, player)
	local arenashop = game:getStore("ARENA_SHOP")
	arenashop:loadup(game.level, game.zone)
	arenashop:interact(player, "검투사 장비점")
	arenashop = nil
end

newChat{ id="ryal-entry",
text = [[#LIGHT_GREEN#*거대한 해골 거인이 관문을 통해 걸어오고 있습니다.
#LIGHT_GREEN#해골 거인의 생김새는 복잡하고 날카롭습니다, 드레이크와 매우 유사하지만, 날개 대신 셀 수 없는 수의 가시가 몸에 나 있습니다.
#LIGHT_GREEN#이 거대한 언데드는 당신을... 유별나게도 지성적인 눈빛으로 주시하고 있습니다.
#LIGHT_GREEN#당신은 이전에 그에 대한 이야기를 들은 적이 있습니다. 우뚝 선 리얄, 투기장의 첫 번째 관문!
#LIGHT_GREEN#두 개의 기분 나쁜 파란 빛이 눈이 있어야 할 자리를 채우고 있습니다. 해골 거인이 울부짖자, 다수의 뼈들이 당신이 있는 곳으로 날아오기 시작합니다!*
]],
	answers = {
		{"#WHITE#전방 경계!!"},
	}
}

newChat{ id="ryal-defeat",
text = [[#LIGHT_GREEN#*몇 번의 공격을 받은 끝에, 언데드 거인은 드디어 당신의 공격에 쓰러졌습니다.*
#LIGHT_GREEN#그런데 갑자기, 리얄의 몸이 재생되기 시작합니다!
#LIGHT_GREEN#이내 멀쩡하게 일어난 그것의 눈을 보고, 당신은 감정따위 느껴지지 않는 그 해골이 만족의 눈빛을 보내고 있다는 사실을 느꼈습니다.
#WHITE#헤헤헤... 잘 했어, @playerdescriptor.race@.
#LIGHT_GREEN#*리얄은 조용히 관문 쪽으로 몸을 돌린 후, 경기장을 떠났습니다, 겉보기엔 완전히 멀쩡해진 것 같습니다.*
]],
	answers = {
		{"#WHITE#재미있었어, 해골 거인!", action=entershop},
		{"#WHITE#...뭐야? 멀쩡하다고?", action=entershop}
	}
}

newChat{ id="fryjia-entry",
text = [[#LIGHT_GREEN#*어린 소녀가 조용히 관문을 통해 들어오자, 갑자기 찬바람이 불기 시작합니다.
#LIGHT_GREEN#그녀는 정말로 어려보이고, 엄청나게 창백한 피부와 그에 대비되는 길고 검은 머리카락을 가지고 있습니다.
#LIGHT_GREEN#그녀는 으스스할 정도로 고요하게 당신을 살펴보고 있습니다.*
#WHITE#나는 우박의 프리지아. 당신이 알아둬야 할 것은 그것 뿐. 자, @playerdescriptor.race@. 시작해볼까요.
#LIGHT_GREEN#*그녀의 말과 동시에, 투기장 전체가 더 추워지기 시작했습니다. 관중들은 그들의 가장 좋은 겨울용 방한 망토를 입기 시작합니다.*]],

	answers = {
		{"#WHITE#자, 와라!"},
	}
}

newChat{ id="fryjia-defeat",
text = [[#LIGHT_GREEN#*당신이 마지막 일격을 날리자, 프리지아가 쓰러졌습니다. 더 이상 싸울 수 없는 상태인 것 같습니다.*
#LIGHT_GREEN#*그녀가 부자연스럽게 일어났습니다. 그렇게 치명적인 부상을 입지는 않은 것 같습니다.*
#WHITE#패...패배를 인정합니다.
#LIGHT_GREEN#*관중들이 경외심을 담아 "오오오오" 하는 함성을 질렀습니다. 프리지아는 뒤를 돌아 당신에게 등을 보입니다.*
#WHITE#하지만 @playerdescriptor.race@, 당신도 제가 찾던 사람은 아니에요...
#LIGHT_GREEN#*그녀가 남긴 말에 머리 속이 복잡해지는 당신을 놔두고, 소녀는 관문을 향해 걷기 시작했습니다. 가까이서 그녀를 보자, 당신은 그녀의 눈에 눈물이 맺혀 있는 것을 깨달았습니다.*
]],
	answers = {
		{"#WHITE#...", action=entershop},
		{"#WHITE#뭐... 뭐였지 방금 그건?", action=entershop}
	}
}

newChat{ id="riala-entry",
text = [[#LIGHT_GREEN#*관문이 열리고, 핏빛 로브를 입은 성숙한 인간 여성이 모습을 드러냈습니다. 그녀는 당신을 보자 함박웃음을 지었습니다.*
#WHITE#이런, 이런, 정말 멋진 @playerdescriptor7.race@네요. 이름이 뭐였죠, 아, @playername@? 오늘 당신의 상대를 하게 되어 저어엉말 기쁘네요.
#LIGHT_GREEN#*그녀는 비밀 이야기를 하는 것처럼, 조용하게 말하기 시작합니다.* #WHITE#당신도 알겠지만, 여기까지 오는 사람은 정말 별로 없거든요. 지루해 죽을 뻔 했다니까요. #LIGHT_GREEN#*그녀가 피식 웃습니다.*
#WHITE#여하튼! 제 이름은 '핏빛' 리알라에요. 앙골웬에서 곧장 이곳으로 왔죠. 당신도 알겠지만, 마법폭발이 불러온 참극에도 불구하고 사람들은 마법 놀이를 여전히 좋아하죠!
#LIGHT_GREEN#*그녀가 손가락으로 딱 소리를 내자, 불꽃이 그녀의 주변에서 춤을 추기 시작합니다!*#WHITE#
프리지아가 당신 얘기를 하더군요. 가여운 것... 그래도 나는 당신 같은 전도유망한 도전자를 과소평가하진 않을거에요. #LIGHT_GREEN#*그녀가 따뜻한 미소를 지었습니다.*
#WHITE#내 사랑, 한번 화끈하게 달려볼까요? 이곳에서 싸움 빼면 뭐가 남겠어요!]],
	answers = {
		{"#WHITE#자, 간다!"},
	}
}

newChat{ id="riala-defeat",
text = [[#LIGHT_GREEN#*당신이 마지막 일격을 날리자, 리알라가 쓰러졌습니다...가 갑자기 그녀의 몸이 불타오릅니다!!
#LIGHT_GREEN#당신은 타오르는 불기둥을 멍하니 보며, 이해할 수 없는 혼란에 빠졌습니다.*
#LIGHT_GREEN#*갑자기 그녀의 목소리가 등 뒤에서 들려, 당신은 정신을 차렸습니다.*#WHITE#
오, 내 사랑! 꽤 좋은 싸움이였어요, 그렇지 않았나요? 아무래도 당신의 승리를 인정해야 할 것 같네요.
#LIGHT_GREEN#*그녀가 정중하게 고개를 숙입니다.*
#LIGHT_GREEN#*당신은 반대 방향에 프리지아가 있는 것을 발견했습니다. 당신은 최강자의 길에 한 걸음 더 가까워진 것 같습니다!*
#WHITE#오, 그녀의 태도는 제가 대신 사과드릴게요. 그녀의 아버지를 만나보신다면 다 이해할 수 있을거에요.
그리고, 지금처럼만 싸워준다면요. 정말 곧 그렇게 될거에요.
그럼 이만. 즐거웠어요, @playername@. #LIGHT_GREEN#*그녀는 한 줄기 불기둥이 되어 사라졌습니다.*]],
	answers = {
		{"#WHITE#다음은 누구냐!", action=entershop},
		{"#WHITE#내가 바로 여기서 죽을 때 이름을 새길 수 있는, 유일한 사람이라는건가?", action=entershop}
	}
}

newChat{ id="valfren-entry",
text = [[#LIGHT_GREEN#*갑자기 주변이 어두워지기 시작했습니다.
#LIGHT_GREEN#당신은 적수를 찾아 두리번거리기 시작했습니다. 그러자 갑자기, 당신의 바로 앞에 두꺼운 판갑 거대한 도끼를 든 형상이 나타났습니다.
#LIGHT_GREEN#분명 1 초 전까지만 해도 보이지 않았던 것입니다. 당신은 뒤로 물러나, 이것을 더 자세히 관찰하기 시작했습니다.
#LIGHT_GREEN#자세히 보니, 그 거대한 갑옷 안에 사람이 들어있는 것을 발견할 수 있었습니다. 그리고 비록 그의 눈은 보이지 않았지만, 그가 마치 당신의 영혼을 꿰뚫어 보는 듯한 느낌을 받았습니다.*
#WHITE#파...트...마....으...
#LIGHT_GREEN#*당신은 악마와 같으면서도, 모든 곳에서 동시에 울려 퍼지는 목소리를 들었습니다!! 하지만... 당신은 그 어떤 말도 알아들을 수 없었습니다! 마즈'에이알에서 쓰이는 그 어떤 언어도 아닌 것 같습니다!
#LIGHT_GREEN#그리고... 날카로운, 악마의 울음소리가 들립니다... 당신은 영혼이 지배당할 것 같은 극도의 감정적 폭압을 느꼈습니다!*
]],
	answers = {
		{"#LIGHT_GREEN#*어둠에 맞서, 용맹하게 버텨낸다.*"},
	}
}

newChat{ id="valfren-defeat",
text = [[
#LIGHT_GREEN#*당신은 용맹하게 마지막 일격을 날렸습니다!*
#LIGHT_GREEN#*발프렌이 쓰러지자, 주변에 빛이 돌아오기 시작했습니다.
#LIGHT_GREEN#당신은 눈이 부셔 잠깐 눈을 감았고, 눈을 뜨자 프리지아가 앞에 있는 것을 발견했습니다.*
#WHITE#아빠... #LIGHT_GREEN#*그녀는 몇 초 동안 아무 말도 하지 않았습니다.* 
#WHITE#당신이 이겼습니다, @playerdescriptor.race@. 지금까지 잘 해내셨어요.
#WHITE#이제 마지막 싸움을 준비하세요... 만약 당신이 승리한다면, 우리는 당신을 위해 뭐든지 할테니까요.
#WHITE#행운을 빌게요...
#LIGHT_GREEN#*몇 초 동안 불편한 시간이 흐른 뒤, 발프렌이 다시 움직이기 시작했습니다.
#LIGHT_GREEN#그는 일어나더니, 프리지아와 함께 관문 쪽으로 걸어나가기 시작했습니다.
#LIGHT_GREEN#관문에 서자, 발프렌은 당신이 있는 곳으로 고개를 돌렸습니다. 당신은 그를 보았고, 그가 투기장의 벽 너머를 보고 있다는 것을 알았습니다.
#LIGHT_GREEN#당신은 그가 보고 있는 곳을 따라보았습니다... 그리고 이 투기장의 지배자와 눈을 마주쳤습니다.*

#LIGHT_GREEN#*바로 저곳이, 당신의 목적지입니다. 당신의 심장이 요동치기 시작합니다.*
#LIGHT_GREEN#*투기장의 지배자가 위풍당당하게 웃습니다.*
#RED#관문이 닫히고, 마지막 싸움이 시작됩니다! 최종 쇄도!!
]],
	answers = {
		{"너를 쓰러뜨리고 말겠다, 투기장의 지배자!!!", action=entershop},
		{"나는 투기장의 지배자를 대신하여, 새로운 투기장의 지배자가 되겠다!!", action=entershop},
		{"부와 영광을! 부와 영광을!", action=entershop},
	}
}

newChat{ id="master-entry",
text = [[#LIGHT_GREEN#*드디어, 이 투기장의 지배자가 관문 앞에 모습을 드러냈습니다!
#LIGHT_GREEN#관중들이 기쁨의 환호를 내지르고 있으며, 그의 얼굴은 자신감에 차있습니다!*
#WHITE#자네에게 박수를 보내네, @playerdescriptor.race@! 정말 굉장한 힘과 용기였다네!
#WHITE#그리고 이제... 마지막 결전을 치를 시간일세!
#LIGHT_GREEN#*지배자가 전투 자세를 잡기 시작합니다. 관중들이 지배자에게 응원을 보냅니다!*
#WHITE#그대처럼, 나 역시 처음에는 아무 것도 아니였다네. 그렇기 때문에, 나 역시 그대 같이 잠재력을 가진 사람을 과소평가할 생각이 없다네.
#LIGHT_GREEN#*지배자가 히죽거리며 웃었습니다. 당신은 전투 자세를 잡기 시작합니다. 그리고 관중들이 당신 역시 응원하기 시작합니다. 당신의 가슴 속에 희열이 차오릅니다.*
#WHITE#이 관중들의 환호성이 들리는가? 바로 이런 의미지. 그 힘으로 영광을 쟁취해보아라, @playerdescriptor.race@!!
#LIGHT_GREEN#*지배자가 모래를 박차고 앞으로 달려듭니다!*
]],
	answers = {
		{"부와 영광을!!!"},
	}
}

newChat{ id="master-defeat",
text = [[#LIGHT_GREEN#*영광스러운 전투가 끝나고, 지배자가 쓰러졌습니다!*
#WHITE#아...하하. 네가 해냈구나, @playerdescriptor.race@...
#LIGHT_GREEN#*투기장의 지배자가, 비록 패배했지만, 밝은 미소를 지으며 일어납니다.
#LIGHT_GREEN#지배자가 패배를 인정했다는 것을 느낀 당신은, 피로 물든 모래 위에 놓여 있던 무기를 집어듭니다.*
#WHITE#모두들! 오늘 우승자가 나왔습니다!!
#LIGHT_GREEN#*관중들은 환호하며 당신의 이름을 계속해서 외칩니다.*
#WHITE#축하한다, @playerdescriptor.race@. 너는 이제 지배자가 되었다.
#WHITE#이제부터 너는 지배자로서, 너만을 위해 허락된 자리에 앉게 되겠지.
#WHITE#하지만 기억해라... 바로 나처럼, 너도 언젠가는 쓰러지게 될 것이다...
#WHITE#물론 반대로 말하자면, 그 때까지 이곳은 네 것이다! 천국에 온 것을 환영한다, @playerdescriptor.race@!
#LIGHT_GREEN#*당신은 여러 후원자들과 군대의 모집원들이, 쓰러진 지배자에게 다가가서 여러 가지 거래와 군에서의 좋은 자리를 제안하는 것을 봤습니다.
#LIGHT_GREEN#당신은 미소지었습니다, 승리자로서, 이제부터는 당신의 인생도 영광스럽게 빛나게 될 것을 알게 되었으니까요. 
#LIGHT_GREEN#언젠가 당신이 패배하게 되는 날이 오게 되더라도, 당신은 언제나 당신의 경력을 통해 융성하게 지낼 수 있을 것입니다.

#YELLOW#축하합니다!
#YELLOW#당신은 이제 투기장의 새로운 지배자가 되었습니다! 정말 위대하고 멋진 일이죠!
#YELLOW#당신은 다른 자가 당신에게 도전하기 전까지는, 계속 지배자로 남게 될 것입니다!
#YELLOW#다음에 플레이 하실 때는, 이 새로운 승리자와 싸우게 될 것입니다!
]],
	answers = {
		{"돈과!! 그리고!! 영광을!!", action=function(npc, player) player:hasQuest("arena"):win() end},
		{"이제부턴 광신도들에게서 여자들을 구하지 않아도 된다!", cond=function(npc, player) if player.female == true then return false else return true end end, action=function(npc, player) player:hasQuest("arena"):win() end},
		{"나는 이 투기장의 지배자로 남아, 미래의 도전자들을 기다릴 것이다!", action=function(npc, player) player:hasQuest("arena"):win() end},
		{"#LIGHT_GREEN#*춤을 춘다*", action=function(npc, player) player:hasQuest("arena"):win() end},
	}
}