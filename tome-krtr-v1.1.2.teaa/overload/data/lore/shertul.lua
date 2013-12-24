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

--------------------------------------------------------------------------
-- Sher'Tul
--------------------------------------------------------------------------

newLore{
	id = "shertul-fortress-1",
	category = "sher'tul",
	name = "first mural painting", always_pop = true,
	kr_name = "벽에 걸린 첫 번째 그림",
	image = "shertul_fortress_lore1.png",
	lore = function() return [[어둡고 고통받는 세계가 그려진 벽화를 발견하였습니다. 거대한, 신을 닮은 형상들이 강력한 기운을 두른 채 서로 싸우고 있습니다. 그들의 발 밑에서, 땅이 찢어지고 갈라집니다.
그림 밑에 글귀가 있습니다. ]]..(not game.player:attr("speaks_shertul") and [[무슨 말인지는 전혀 모르겠지만... : #{italic}#'Sho ch'zun Eyal mor donuth, ik ranaheli donoth trun ze.'#{normal}#]] or [[#{italic}#'세계의 처음에는 어둠 밖에 없었으며, 저 하찮은 신들은 그들의 파괴된 땅 위에서 싸우고 또 싸웠다.'#{normal}#]])
	end,
}

newLore{
	id = "shertul-fortress-2",
	category = "sher'tul",
	name = "second mural painting", always_pop = true,
	kr_name = "벽에 걸린 두 번째 그림",
	image = "shertul_fortress_lore2.png",
	lore = function() return [[빛나는 눈을 가진 거대한 신이 땅 위에 굳건하게 서 있으며, 그의 높게 치켜든 오른손에는 태양이 들려 있습니다. 다른 신들은 그에게서 달아나고 있으며, 빛을 두려워하는 것 같습니다.
그림 밑에 글귀가 있습니다. ]]..(not game.player:attr("speaks_shertul") and [[무슨 말인지는 전혀 모르겠지만... : #{italic}#'Fa AMAKTHEL tabak, ik koru bazan tro yu, ik ranaheli tobol don schek ruun. Ik blana dem Soli as banafel ik goriz uf Eyal ik blod, "Tro fasa goru domus asam, ik goru domit tro Eyal."'#{normal}#]] or [[#{italic}#'그러나 아마크텔이 왔다. 그의 힘은 다른 모든 존재들을 압도하였다. 다른 하찮은 신들은 그의 영광스러운 모습을 보고 달아났다. 그는 그의 숨결로 태양을 만들어 세계의 위에 걸어둔 뒤 말했다. "이 빛이 어루만지는 모든 것은 나의 것이 될 것이다. 그리고, 이 빛은 온 세계를 어루만지게 될 것이다."'#{normal}#]])
	end,
}

newLore{
	id = "shertul-fortress-3",
	category = "sher'tul",
	name = "third mural painting", always_pop = true,
	kr_name = "벽에 걸린 세 번째 그림",
	image = "shertul_fortress_lore3.png",
	lore = function() return [[거대한 신이 더 작은 형체를 가진 자들을 자신의 손 위에 올려둔 채, 대륙 너머를 가리키고 있습니다. 아마 이 작은 형체를 가진 자들이 쉐르'툴 종족일 것 같습니다.
그림 밑에 글귀가 있습니다. ]]..(not game.player:attr("speaks_shertul") and [[무슨 말인지는 전혀 모르겠지만... : #{italic}#'Ik AMAKTHEL cosio SHER'TUL, ik baladath peris furko masa bren doth benna zi, ik blod is "Fen makel ath goru domus ik denz tro ala fron."'#{normal}#]] or [[#{italic}#'그리고 아마크텔은 쉐르'툴을 만들었다. 그리고 우리들의 의지를 마음껏 펼칠 수 있을 정도의 힘을 주었다. 그리고 우리에게 말하였다. "저 빛이 닿는 곳으로 가라. 그리고 자유롭게 그곳에서 살아라."'#{normal}#]])
	end,
}

newLore{
	id = "shertul-fortress-4",
	category = "sher'tul",
	name = "fourth mural painting", always_pop = true,
	kr_name = "벽에 걸린 네 번째 그림",
	image = "shertul_fortress_lore4.png",
	lore = function() return [[수정으로 만들어진 거대한 도시가 그려져 있으며, 그 뒤에는 돌로 이루어진 작은 섬들이 하늘에 떠있습니다. 그림 앞부분에는 앉아 있는 쉐르'툴이 있으며, 하늘을 향해 손을 뻗은 모습을 하고 있습니다.
그림 밑에 글귀가 있습니다. ]]..(not game.player:attr("speaks_shertul") and [[무슨 말인지는 전혀 모르겠지만... : #{italic}#'Batialatoth ro Eyal, ik rinsi akan fronseth sumit kurameth ik linnet pora gasios aeren. Ach nen beswar goreg.'#{normal}#]] or [[#{italic}#'우리는 세계를 정복하였다. 그리고 수정으로 거대한 탑과 도시를 만들었다. 그리고 하늘을 여행하였다. 하지만 우리들 중 몇몇은 그에 만족하지 않았다...'#{normal}#]])
	end,
}

newLore{
	id = "shertul-fortress-5",
	category = "sher'tul",
	name = "fifth mural painting", always_pop = true,
	kr_name = "벽에 걸린 다섯 번째 그림",
	image = "shertul_fortress_lore5.png",
	lore = function() return [[각각 어둠의 무기를 하나씩 들고 있는, 아홉 명의 쉐르'툴이 나란히 서 있는 그림입니다. 당신의 눈이 중앙에 있는 붉은 로브를 입은 형체가 들고 있는, 룬이 새겨진 마법지팡이에 머무릅니다. 어디선가 많이 본 지팡이 같습니다...
그림 밑에 글귀가 있습니다. ]]..(not game.player:attr("speaks_shertul") and [[무슨 말인지는 전혀 모르겠지만... : #{italic}#'Zubadon koref noch hesen, ik dorudon koref noch pasor. Cosief maro dondreth karatu - Ranaduzil - ik jein belsan ovrienis.'#{normal}#]] or [[#{italic}#'자만한 우리들은 평등을 원치 않았고, 탐욕스러운 우리들은 노예 상태를 원치 않았다. 우리들은 우리 자신을 위해 끔찍한 무기들을 만들었다. - 신을 살해하는 자 - 그리고 선택받은 아홉 사람들이 그 무기들을 들었다.'#{normal}#]])
	end,
}

newLore{
	id = "shertul-fortress-6",
	category = "sher'tul",
	name = "sixth mural painting", always_pop = true,
	kr_name = "벽에 걸린 여섯 번째 그림",
	image = "shertul_fortress_lore6.png",
	lore = function() return [[엄청난 전투가 벌어지는 모습을 그린 그림입니다. 쉐르'툴 전사들이 그들보다 족히 열 배는 커보이는, 신을 닮은 형체들과 싸우고 있습니다.
그림 밑에 글귀가 있습니다. ]]..(not game.player:attr("speaks_shertul") and [[무슨 말인지는 전혀 모르겠지만... : #{italic}#'Ranaheli meth dondruil ik duzin, ik leisif konru as neremin. Eyal matath bre sun. Ach unu rana soriton...'#{normal}#]] or [[#{italic}#'그 하찮은 신들은 사냥당하고 살해당했다. 그리고 그들의 영혼은 무의 존재가 되어 사라졌다. 대지는 온전히 우리들의 것이 되었다. 하지만 하나의 신이 아직 남아있다...'#{normal}#]])
	end,
}

newLore{
	id = "shertul-fortress-7",
	category = "sher'tul",
	name = "seventh mural painting", always_pop = true,
	kr_name = "벽에 걸린 일곱 번째 그림",
	image = "shertul_fortress_lore7.png",
	lore = function() return [[붉은 로브를 입은 쉐르'툴이 거대한 신에게 검은, 룬이 새겨진 마법지팡이를 휘두르고 있습니다. 그들의 주위에는 찢겨진 신체들이 흩어져 있으며, 그들의 뒤에 있는 금빛 왕좌는 피범벅이 된 상태입니다. 신의 눈에서 나는 빛이 흐려지는 것 같습니다.
그림 밑에 글귀가 있습니다. ]]..(not game.player:attr("speaks_shertul") and [[무슨 말인지는 전혀 모르겠지만... : #{italic}#'Trobazan AMAKTHEL konruata as va aurin leas, ik mab peli zort akan hun, penetar dondeberoth.'#{normal}#]] or [[#{italic}#'절대자 아마크텔은 그의 금빛 왕좌 위에서 기습을 받았다. 그의 발 밑에서 많은 자들이 죽어나갔지만, 마침내 그는 쓰러졌다.'#{normal}#]])
	end,
}

newLore{
	id = "shertul-fortress-8",
	category = "sher'tul",
	name = "eighth mural painting", always_pop = true,
	kr_name = "벽에 걸린 여덟 번째 그림",
	image = "shertul_fortress_lore8.png",
	lore = function() return [[거대한 신이 땅 위에 쓰러져 있으며, 검은 마법지팡이가 그의 가슴에 꽂혀 있습니다. 몇몇 쉐르'툴이 그의 주위에서 그의 팔다리를 도끼로 내려치고, 그의 혀를 자르고, 그를 사슬로 묶고 있습니다. 키 큰 쉐르'툴 전사가 그의 눈을 검은 날을 가진 도끼창으로 구멍내고 있으며, 그로 인해 빛이 뿜어져 나오고 있습니다. 그리고 한 쉐르'툴 마법사가 대지에 난 커다란 틈에 손짓을 하고 있습니다.
그림 밑에는 짧은 글귀가 있습니다. ]]..(not game.player:attr("speaks_shertul") and [[#{italic}#'Meas Abar.'#{normal}#]] or [[#{italic}#'원죄.'#{normal}#]])
	end,
}

newLore{
	id = "shertul-fortress-9",
	category = "sher'tul",
	name = "ninth mural painting", always_pop = true,
	kr_name = "벽에 걸린 아홉 번째 그림",
	image = "shertul_fortress_lore9.png",
	lore = function() return [[마지막 벽화는 훼손되었습니다. 수십 개의 깊게 파인 흔적들이 가득합니다. 이 벽화에서 유일하게 짐작할 수 있는 것은, 벽화가 불타오르는 모습을 그렸을 것이라는 사실입니다.]] end,
}

newLore{
	id = "shertul-fortress-takeoff",
	category = "sher'tul",
	name = "Yiilkgur raising toward the sky", always_pop = true,
	kr_name = "하늘 위로 날아오르는 이일크구르",
	image = "fortress_takeoff.png",
	lore = [[쉐르'툴 요새, 이일크구르가 누르 호수의 깊은 물 속에서 떠올라, 재작동되었습니다. 요새가 하늘 위로 솟아오릅니다.]],
}

newLore{
	id = "shertul-fortress-caldizar",
	category = "sher'tul",
	name = "a living Sher'Tul?!", always_pop = true,
	kr_name = "살아있는 쉐르'툴 종족?!",
	image = "inside_caldizar_fortress.png",
	lore = [[알 수 없는 이유로, 당신은 다른 쉐르'툴 요새로 전송되었습니다. 이 굉장히 낯선 장소에서, 당신은 살아 있는 쉐르'툴을 발견하였습니다.]],
}

newLore{
	id = "first-farportal",
	category = "sher'tul",
	name = "lost farportal", always_pop = true,
	kr_name = "잊혀진 장거리 관문",
	image = "farportal_entering.png",
	lore = function() return game.player.name:addJosa("는")..[[ 대담하게 쉐르'툴 장거리 관문 안으로 들어갔습니다.]] end,
}
