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

-------------------------------------------------------------------
-- For alchemist quests
-------------------------------------------------------------------

newIngredient{ id = "TROLL_INTESTINE",
	type = "organic",
	icon = "object/troll_intestine.png",
	name = "length of troll intestine",
	kr_display_name = "트롤의 창자",
	desc = [[기다란 트롤의 창자입니다. 다행스럽게도, 트롤은 요근래 먹은게 없는 모양입니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "되돌려 주기 전에 친절히 속을 비워주게.",
}

newIngredient{ id = "SKELETON_MAGE_SKULL",
	type = "organic",
	icon = "object/skeleton_mage_skull.png",
	name = "skeleton mage skull",
	kr_display_name = "해골 마법사 두개골",
	desc = [[이 것은 해골 마법사의 두개골입니다. 눈은 빛나지 않고 있습니다... 지금은요.]],
	min = 0, max = INFINITY,
	alchemy_text = "만약 눈이 아직도 빛나고 있다면, 희미해질때까지 여기저기 두들겨. 난 또다른 놈이 살아나서 내 연구실에서 소동을 피우길 바라지 않네.",
}

newIngredient{ id = "RITCH_STINGER",
	type = "organic",
	icon = "object/ritch_stinger.png",
	name = "ritch stinger",
	kr_display_name = "릿치 가시",
	desc = [[릿치 가시는 아직도 독액으로 번들거립니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "가능한한 독액을 보존해주게.",
}

newIngredient{ id = "ORC_HEART",
	type = "organic",
	icon = "object/orc_heart.png",
	name = "orc heart",
	kr_display_name = "오크의 심장",
	desc = [[오크의 심장입니다. 어쩌면 놀랍겠지만, 녹색이 아닙니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "만약 당신이 아직 뛰고있는 오크 심장을 가져온다면, 더 좋아. 하지만 내눈에 당신이 고위 사령술사로 보이진 않는구먼.",
}

newIngredient{ id = "NAGA_TONGUE",
	type = "organic",
	icon = "object/naga_tongue.png",
	name = "naga tongue",
	kr_display_name = "나가의 혀",
	desc = [[잘라낸 나가의 혀입니다. 소금물 같은 악취가 납니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "최고의 결과는 불경한 말로 오염된 적이 없는 혀라네. 그러니 만약 성스러운 나가를 알게된다면...",
}

newIngredient{ id = "GREATER_DEMON_BILE",
	type = "organic",
	icon = "object/phial_demon_blood.png",
	name = "vial of greater demon bile",
	kr_display_name = "고위 악마의 담즙이 담긴 약병",
	desc = [[고위 악마의 담즙이 담긴 약병입니다. 약병의 마개가 제자리에 단단히 고정되어 있어도 당신의 코를 상하게 만듭니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "그게 그러라고 말하더라도, 마시면 안 돼.",
}

newIngredient{ id = "BONE_GOLEM_DUST",
	type = "organic",
	icon = "object/pouch_bone_giant_dust.png",
	name = "pouch of bone giant dust",
	kr_display_name = "뼈거인의 먼지 주머니",
	desc = [[일단 마법으로 뼈거인이 움직이면 도망가십시오, 그것이 먼지로 부서져 남아있을 것입니다. 상상력이 조금 더해지면, 그건 가끔씩 자체적으로 약간 움직이는 것처럼 보입니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "절대로, 마늘 가루와 착각하지 말게나. 날 믿어.",
}

newIngredient{ id = "FROST_ANT_STINGER",
	type = "organic",
	icon = "object/ice_ant_stinger.png",
	name = "ice ant stinger",
	kr_display_name = "얼음 개미 침",
	desc = [[심술궂게 날카롭고 아직도 빙점의 냉기가 남아있습니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "독액을 없애야하는 문제점이 남아있긴 하지만, 이것은 놀랍게도 즉석으로 음료를 차갑게 마실수 있는 빨대로 쓸수있다구.",
}

newIngredient{ id = "MINOTAUR_NOSE",
	type = "organic",
	icon = "object/minotaur_nose.png",
	name = "minotaur nose",
	kr_display_name = "미노타우루스의 코",
	desc = [[고리가 달린, 미노타우루스의 잘린 코의 앞쪽입니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "되도록이면 비싸도록, 고리가 붙어있는 놈으로 찾아야 하네.",
}

newIngredient{ id = "ELDER_VAMPIRE_BLOOD",
	type = "organic",
	icon = "object/vial_elder_vampire_blood.png",
	name = "vial of elder vampire blood",
	kr_display_name = "흡혈귀 장로의 피가 담긴 약병",
	desc = [[짙고 응고되었으며 악취가 납니다. 약병을 만지는 것만으로도 냉기가 전해져옵니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "그걸 얻는다면, 길을 돌려 흐르는 물을 건너야해.",
}

newIngredient{ id = "MULTIHUED_WYRM_SCALE",
	type = "organic",
	icon = "object/dragon_scale_multihued.png",
	name = "multi-hued wyrm scale",
	kr_display_name = "여러색의 용 비늘",
	desc = [[아릅답고 거의 난공불락입니다. 용에게서 그걸 분리하는 것은 아주 힘든일입니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "만약 이것들을 모으는게 힘들다고 생각한다면, 한번 용해시켜보게나.",
}

newIngredient{ id = "SPIDER_SPINNERET",
	type = "organic",
	icon = "object/spider_spinnarets.png",
	name = "giant spider spinneret",
	kr_display_name = "거인거미의 방젹돌기",
	desc = [[이상하게 생긴, 거인거미에서 찢어낸 한 부분입니다. 구멍으로부터 약간의 명주실이 튀어나와 있습니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "너네 헛간에 있는 거미는 아냐. 마즈'에이알에 희귀하지만, 딱보면 저게 거인거미인줄 알수 있을거야.",
}

newIngredient{ id = "HONEY_TREE_ROOT",
	type = "organic",
	icon = "object/honey_tree_root.png",
	name = "honey tree root",
	kr_display_name = "벌꿀나무 뿌리",
	desc = [[벌꿀나무 뿌리의 끝부분을 잘라낸 것입니다. 가끔씩 꿈틀거리고, 언뜻보기에는 죽은것 같아 보이지 않습니다... 그리고 *식물*입니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "단단히 잡고 있게. 바닥에 두면 이 놈들은 알아서 땅을 파고 들어가버린다구.",
}

newIngredient{ id = "BLOATED_HORROR_HEART",
	type = "organic",
	icon = "object/bloated_horror_heart.png",
	name = "bloated horror heart",
	kr_display_name = "부풀어오른 무서운자의 심장",
	desc = [[질병의 근원으로 보이고 악취가 납니다. 보이는만큼 부패하고 있습니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "터져도 걱정할거 없어. 그냥 닿지만 않으면 돼.",
}

newIngredient{ id = "ELECTRIC_EEL_TAIL",
	type = "organic",
	icon = "object/electric_eel_tail.png",
	name = "electric eel tail",
	kr_display_name = "전기뱀장어 꼬리",
	desc = [[미끈미끈하고 꿈틀거리며 전기가 파직거리고 있습니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "아네, 안다구. 뱀장어의 꼬리가 어디부터인지 말이지? 그건 중요치 않아. 마지막 10인치 이상만 가져오라구.",
}

newIngredient{ id = "SQUID_INK",
	type = "organic",
	icon = "object/vial_squid_ink.png",
	name = "vial of squid ink",
	kr_display_name = "오징어 먹물이 든 약병",
	desc = [[짙고 시커멓고 불투명합니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "그걸 모으느라 짜증났다는걸 알겠지만, 거기서 나는 악취가 연구실에 가득차서 난 더 짜증난다네.",
}

newIngredient{ id = "BEAR_PAW",
	type = "organic",
	icon = "object/bear_paw.png",
	name = "bear paw",
	kr_display_name = "곰 발",
	desc = [[크고 털이 무성하며 살을 찢는 발톱이 달려있습니다. 물고기 냄새가 조금 납니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "내가 마을의 사냥꾼에게서 이걸 구할수 있다고 생각하는가 본데, 그들은 그런 운이 없다네. 잡혀 먹히지 말게나.",
}

newIngredient{ id = "ICE_WYRM_TOOTH",
	type = "organic",
	icon = "object/frost_wyrm_tooth.png",
	name = "ice wyrm tooth",
	kr_display_name = "얼음 이무기 이빨",
	desc = [[이 이빨은 조금 닳았지만, 아직도 그 역할을 충분히 할 수 있을것 같습니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "얼음 이무기는 이빨이 자주 빠지니까, 운이 좋으면 싸우지 않고도 구할수 있을게야. 하지만 옷은 따뜻하게 준비해가야 하네.",
}

newIngredient{ id = "RED_CRYSTAL_SHARD",
	type = "organic",
	icon = "object/red_crystal_shard.png",
	name = "red crystal shard",
	kr_display_name = "붉은 수정 파편",
	desc = [[그 열기가 점차 사그라듦에도 불구하고, 투명한 수정속에 작은 불꽃이 아직 천상의 춤을 추고있습니다...]],
	min = 0, max = INFINITY,
	alchemy_text = "엘발라 주변의 동굴에서 찾을수 있다고 들었네. 또한 그건 자연연소된다고 알고있으니, 심한 자국이 남아있다면 왜 그런지 설명을 해야 하네.",
}

newIngredient{ id = "FIRE_WYRM_SALIVA",
	type = "organic",
	icon = "object/vial_fire_wyrm_saliva.png",
	name = "vial of fire wyrm saliva",
	kr_display_name = "화염 이무기 타액이 든 약병",
	desc = [[투명하고 물보다 조금 짙습니다. 흔들면 거품이 납니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "불을 피울때 그 물건과는 거리를 두게, 안그러면 새로운 살아있는 모험가를 만날지도 몰라.",
}

newIngredient{ id = "GHOUL_FLESH",
	type = "organic",
	icon = "object/ghoul_flesh.png",
	name = "chunk of ghoul flesh",
	kr_display_name = "구울 살점 조각",
	desc = [[썩고 악취가 납니다. 아직도 가끔씩 실룩거립니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "자네에겐 불행하겠지만, 구울에게서 자연적으로 떨어져 나간 살점은 필요없네. 싱싱한 놈에게서 잘라낸게 필요하다네.",
}

newIngredient{ id = "MUMMY_BONE",
	type = "organic",
	icon = "object/mummified_bone.png",
	name = "mummified bone",
	kr_display_name = "미이라화된 뼈",
	desc = [[이 고대의 뼈에는 마른 피부가 약간 붙어있습니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "미이라화가 진행되고 있는 시체의 뼈라네. 사실, 약간의 피부도 붙어있지만, 미이라를 걷어차서 찾을 수 있는건 거의 뼈밖에 없어. 저주받지 않은 놈으로 구해오는걸 추천하네.",
}

newIngredient{ id = "SANDWORM_TOOTH",
	type = "organic",
	icon = "object/sandworm_tooth.png",
	name = "sandworm tooth",
	kr_display_name = "지렁이 이빨",
	desc = [[작고 어두운 회색이며 심술궂게 뾰족합니다. 뼈라기보다는 돌같아 보입니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "그래, 지렁이도 이빨이 있지. 아주 작고, 자네가 여태껏 보아온 것들과는 많이 다르겠지만 말야.",
}

newIngredient{ id = "BLACK_MAMBA_HEAD",
	type = "organic",
	icon = "object/black_mamba_head.png",
	name = "black mamba head",
	kr_display_name = "검은 맘바 머리",
	desc = [[검은 맘바의 다른 부분과는 다르게, 잘린 머리는 움직이지 않습니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "그놈한테 물려도, 머리를 갖고 돌아오면 내가 살릴 수 있다네... 단지 일분안에 나한테 보여줘야 되겠지만말야. 행운을 비네.",
}

newIngredient{ id = "SNOW_GIANT_KIDNEY",
	type = "organic",
	icon = "object/snow_giant_kidney.png",
	name = "snow giant kidney",
	kr_display_name = "설원 거인 신장",
	desc = [[일반적인 노출된 장기와 같이 보기 불쾌합니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "설원 거인을 찔러 신장을 꺼내지만 죽이지는 말도록 하게. 다른 놈을 또 찾아야 될지도 몰라.",
}

newIngredient{ id = "STORM_WYRM_CLAW",
	type = "organic",
	icon = "object/storm_wyrm_claw.png",
	name = "storm wyrm claw",
	kr_display_name = "폭풍 이무기 발톱",
	desc = [[푸르스름하고 사납도록 날카롭습니다. 닿으면 팔의 털이 곤두섭니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "며느리발톱을 잘라오는걸 추천하네. 제일 작고 뽑기도 쉬운데다 사용하지않아 무디지도 않거든. 그러니 찔리지않게 주의하게. 참, 잡아 먹히지도 말아야지.",
}

newIngredient{ id = "GREEN_WORM",
	type = "organic",
	icon = "object/green_worm.png",
	name = "green worm",
	kr_display_name = "녹색 벌레",
	desc = [[힘들게 엉켜있는 무리에서 분리한 죽은 녹색 벌레입니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "건네주기 전에 얽힌 부분이 없도록 만들어 주게. 장갑을 써야 하네.",
}

newIngredient{ id = "WIGHT_ECTOPLASM",
	type = "organic",
	icon = "object/vial_wight_ectoplasm.png",
	name = "vial of wight ectoplasm",
	kr_display_name = "와이트 외형질이 든 약병",
	desc = [[탁하고 짙습니다. 병에 집에 넣어야 증발하는 것을 막을수 있습니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "조금이라도 몸에 흡수했다면, 절대 여기로 돌아오지 말게나. 부탁이네.",
}

newIngredient{ id = "XORN_FRAGMENT",
	type = "organic",
	icon = "object/xorn_fragment.png",
	name = "xorn fragment",
	kr_display_name = "쏜 파편",
	desc = [[다른 돌과 정말 비슷하게 보이지만, 이것은 최근까지 감각이 있었고 당신을 죽이려하던 것입니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "쏜의 파편과 눈은 다른곳에 보관해야 하네. 연금술재료가 쳐다보고 있는 불쾌함은 말로 설명못한다구.",
}

newIngredient{ id = "WARG_CLAW",
	type = "organic",
	icon = "object/warg_claw.png",
	name = "warg claw",
	kr_display_name = "와그르 발톱",
	desc = [[불쾌하도록 크고 개과의 발톱치고는 날카롭습니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "보통 연금술재료를 모아주는 이들은 와르그 사냥에서는 물러서더군. 돌아오는 길에 그들을 비웃어도 좋을걸세.",
}

newIngredient{ id = "FAEROS_ASH",
	type = "organic",
	icon = "object/pharao_ash.png",
	name = "pouch of faeros ash",
	kr_display_name = "파에로스 재를 넣은 주머니",
	desc = [[평범한 회색 재입니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "다른 외부차원에서 유래된 것들과 마찬가지로 그들은 순수한 불꽃의 존재들이지만, 그들의 불이 태운 물체의 재는 눈에 띄는 특성을 가진다네.",
}

newIngredient{ id = "WRETCHLING_EYE",
	type = "organic",
	icon = "object/wretchling_eyeball.png",
	name = "wretchling eyeball",
	kr_display_name = "렛츨링 눈알",
	desc = [[작고 충혈되어 있습니다. 그 죽음의 시선은 아직도 피부에 불을 붙입니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "사악하고 조그만 렛츨링이라는 놈이지. 죽일수 있는만큼 죽여도 좋지만, 난 온전한 눈알 하나만 있으면 된다네.",
}

newIngredient{ id = "FAERLHING_FANG",
	type = "organic",
	icon = "object/faerlhing_fang.png",
	name = "faerlhing fang",
	kr_display_name = "파에를힝 송곳니",
	desc = [[아직도 독액이 흐르고, 마법적 에너지가 튀어나옵니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "이놈에게 많은 모험가를 잃었지만, 당신은 괜찮을거라 생각하네.",
}

newIngredient{ id = "VAMPIRE_LORD_FANG",
	type = "organic",
	icon = "object/vampire_lord_fang.png",
	name = "vampire lord fang",
	kr_display_name = "흡혈귀 군주 송곳니",
	desc = [[눈부시게 하얗지만, 가장 어두운 마법으로 둘서쌓여 있습니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "찔리지 않게 정말 조심해야 하네.",
}

newIngredient{ id = "HUMMERHORN_WING",
	type = "organic",
	icon = "object/hummerhorn_wing.png",
	name = "hummerhorn wing",
	kr_display_name = "허밍뿔의 날개",
	desc = [[투명하고 가냘프게 생겼지만, 놀랍도록 튼튼합니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "허밍뿔을 전에 만나본 적이 없다면, 그건 말벌처럼 생겼다고 생각하게. 다만 아주 크고 치명적이라네..",
}

newIngredient{ id = "LUMINOUS_HORROR_DUST",
	type = "organic",
	icon = "object/pouch_luminous_horror_dust.png",
	name = "pouch of luminous horror dust",
	kr_display_name = "야광 무서운자의 먼지 주머니",
	desc = [[무게가 느껴지지 않고, 다른 먼지와는 다르게 빛이 납니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "발광 무서운자와 혼동하지 말게나. 만약 그렇다면, 난 다른 모험가도 많이 있다는걸 알아두게.",
}
