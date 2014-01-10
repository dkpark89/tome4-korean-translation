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

--------------- Tutorial objectives
newAchievement{
	name = "Baby steps", id = "TUTORIAL_DONE",
	kr_name = "첫 걸음마",
	desc = [[ToME4 연습게임을 완료함.]],
	tutorial = true,
	no_difficulty_duplicate = true,
	on_gain = function(_, src, personal)
		game:setAllowedBuild("tutorial_done")
	end,
}

--------------- Main objectives
newAchievement{
	name = "Vampire crusher",
	image = "npc/the_master.png",
	show = "name", huge=true,
	kr_name = "흡혈귀 분쇄",
	desc = [[두려움의 영역에서 '주인' 을 파괴.]],
}
newAchievement{
	name = "A dangerous secret",
	show = "name",
	kr_name = "위험한 비밀",
	desc = [[신비한 지팡이를 찾아, '마지막 희망' 에 보고.]],
}
newAchievement{
	name = "The secret city",
	show = "none",
	kr_name = "숨겨진 도시",
	desc = [[마법사들에 대한 진실을 밝혀냄.]],
}
newAchievement{
	name = "Burnt to the ground", id="APPRENTICE_STAFF",
	show = "none",
	kr_name = "초토화",
	desc = [[견습 마법사에게 '흡수의 지팡이' 를 주고, 이후의 불꽃놀이를 감상.]],
}
newAchievement{
	name = "Against all odds", id = "KILL_UKRUK",
	show = "name", huge=true,
	kr_name = "불가능과 맞서다",
	desc = [[습격하는 우크룩 살해.]],
}
newAchievement{
	name = "Sliders",
	image = "object/artifact/orb_many_ways.png",
	show = "name",
	kr_name = "활주",
	desc = [['여러 장소로의 오브' 를 사용하여 관문 활성화.]],
	on_gain = function()
		game:onTickEnd(function() game.party:learnLore("first-farportal") end)
	end
}
newAchievement{
	name = "Destroyer's bane", id = "DESTROYER_BANE",
	show = "name",
	kr_name = "파괴자의 죽음",
	desc = [[파괴자 골부그를 살해.]],
}
newAchievement{
	name = "Brave new world", id = "STRANGE_NEW_WORLD",
	show = "name",
	kr_name = "용감하게 신세계로",
	desc = [[동대륙으로 가서 전투에 참여함.]],
}
newAchievement{
	name = "Race through fire", id = "CHARRED_SCAR_SUCCESS",
	show = "name",
	kr_name = "화염을 뚫고 질주",
	desc = [['검게 탄 상처' 의 화염을 뚫고 주술사들을 막기 위해 질주.]],
}
newAchievement{
	name = "Orcrist", id = "ORC_PRIDE",
	show = "name",
	kr_name = "오크 살해자",
	desc = [[오크 긍지의 지도자들을 살해.]],
}

--------------- Wins
newAchievement{
	name = "Evil denied", id = "WIN_FULL",
	show = "name", huge=true,
	kr_name = "악한 자는 사절입니다",
	desc = [[공허의 관문이 열리는 것을 방지하여 ToME 승리.]],
}
newAchievement{
	name = "The High Lady's destiny", id = "WIN_AERYN",
	show = "name", huge=true,
	kr_name = "고귀한 여인의 운명",
	desc = [[아에린을 희생하여 공허의 관문을 닫아 ToME 승리.]],
}
newAchievement{
	name = "The Sun Still Shines", id = "WIN_AERYN_SURVIVE",
	show = "name", huge=true,
	kr_name = "태양은 아직 빛나고 있다",
	desc = [[마지막 전투에서 아에린 생존.]], 
}
newAchievement{
	name = "Selfless", id = "WIN_SACRIFICE",
	show = "name", huge=true,
	kr_name = "이타심",
	desc = [[스스로를 희생하여 공허의 관문을 닫아 ToME 승리.]],
}
newAchievement{
	name = "Triumph of the Way", id = "YEEK_SACRIFICE",
	show = "name", huge=true,
	kr_name = "'한길' 의 승리",
	desc = [[스스로를 희생하여 ToME에서 승리함으로써, 에이알의 모든 지적 존재들에게 '한길' 의 영향력 확대.]],
}
newAchievement{
	name = "No Way!", id = "YEEK_SELFLESS",
	kr_name = "그 '길' 은 안돼!",
	show = "name", huge=true,
	desc = [[공허의 관문을 닫고 아에린이 자신을 죽이도록 하여, '한길' 이 에이알의 모든 지적 존재들을 지배하지 못하게 만들고 ToME 승리.]], 
}
newAchievement{
	name = "Tactical master", id = "SORCERER_NO_PORTAL",
	show = "name", huge=true,
	kr_name = "전략의 대가",
	desc = [[소환용 관문을 닫지 않고 두 주술사와 싸움.]],
}
newAchievement{
	name = "Portal destroyer", id = "SORCERER_ONE_PORTAL",
	show = "name", huge=true,
	kr_name = "관문 파괴자",
	desc = [[하나의 소환용 관문만 닫고 두 주술사와 싸움.]],
}
newAchievement{
	name = "Portal reaver", id = "SORCERER_TWO_PORTAL",
	show = "name", huge=true,
	kr_name = "관문 약탈자", --@ 일단, 여기만 그냥 둠. reaver를 약탈자로 변경시 marauder를 대체할 단어 필요 (둘다 캐릭터 직업, 현재 reaver:파괴자, marauder:약탈자)
	desc = [[두 개의 소환용 관문을 닫고 두 주술사와 싸움.]],
}
newAchievement{
	name = "Portal ender", id = "SORCERER_THREE_PORTAL",
	show = "name", huge=true,
	kr_name = "관문 폐지자",
	desc = [[세 개의 소환용 관문을 닫고 두 주술사와 싸움.]],
}
newAchievement{
	name = "Portal master", id = "SORCERER_FOUR_PORTAL",
	show = "name", huge=true,
	kr_name = "관문의 주인",
	desc = [[네 개의 소환용 관문을 닫고 두 주술사와 싸움.]],
}
newAchievement{
	name = "Never Look Back And There Again", id = "WIN_NEVER_WEST",
	show = "full", huge=true,
	kr_name = "'다시 또 그곳에' 따윈 필요없어",
	desc = [[마즈'에이알을 한 번도 밟지 않고 게임에서 승리.]],
}

-------------- Other quests
newAchievement{
	name = "Rescuer of the lost", id = "LOST_MERCHANT_RESCUE",
	show = "name",
	kr_name = "실종자 구출",
	desc = [['암살단 단장' 으로부터 상인을 구출함.]],
}
newAchievement{
	name = "Poisonous", id = "LOST_MERCHANT_EVIL",
	show = "name",
	kr_name = "맹독성",
	desc = [['암살단 단장' 편에 가담함.]],
}
newAchievement{
	name = "Destroyer of the creation", id = "SLASUL_DEAD",
	show = "name",
	kr_name = "창조의 파괴자",
	desc = [[슬라슐을 살해.]],
}
newAchievement{
	name = "Treacherous Bastard", id = "SLASUL_DEAD_PRODIGY_LEARNT",
	show = "name",
	kr_name = "이런 배반자 자식",
	desc = [[특수기술 '날로레의 유산' 을 배우기 위해 슬라슐의 편에 선 다음, 슬라슐을 죽임.]],
}
newAchievement{
	name = "Flooder", id = "UKLLMSWWIK_DEAD",
	show = "name",
	kr_name = "홍수를 부르는 자",
	desc = [[우클름스윅의 퀘스트를 진행하다가, 우클름스윅을 물리침.]],
}
newAchievement{
	name = "Gem of the Moon", id = "MASTER_JEWELER",
	show = "name", huge=true,
	kr_name = "달의 보석",
	desc = [[보석 세공의 명인 리미르의 퀘스트 완료.]],
}
newAchievement{
	name = "Curse Lifter", id = "CURSE_ERASER",
	show = "name",
	kr_name = "저주를 걷어낸 자",
	desc = [[저주받은 자 벤 크루스달을 죽임.]],
}
newAchievement{
	name = "Fast Curse Dispel", id = "CURSE_ALL",
	show = "name", huge=true,
	kr_name = "빠른 저주 해제",
	desc = [[모든 나무꾼을 살리면서, 저주받은 자 벤 크루스달을 죽임.]],
}
newAchievement{
	name = "Eye of the storm", id = "EYE_OF_THE_STORM",
	show = "name",
	kr_name = "폭풍의 눈",
	desc = [[미친 대기술사 우르키스를 죽이고 데르스를 복구.]],
}
newAchievement{
	name = "Antimagic!", id = "ANTIMAGIC",
	show = "name",
	kr_name = "반마법!",
	desc = [[지구르 추종자 부대에서 반마법 훈련 수료.]],
}
newAchievement{
	name = "Anti-Antimagic!", id = "ANTI_ANTIMAGIC",
	show = "name",
	kr_name = "반-반마법!",
	desc = [[랄로레 동료와 함께 지구르 추종자 부대를 파괴.]],
}
newAchievement{
	name = "There and back again", id = "WEST_PORTAL",
	show = "name", huge=true,
	kr_name = "또 다시 그 곳에",
	desc = [[동대륙에서 마즈'에이알로 가는 관문 열기.]],
}
newAchievement{
	name = "Back and there again", id = "EAST_PORTAL",
	kr_name = "다시 또 그 곳에",
	show = "name", huge=true,
	desc = [[마즈'에이알에서 동대륙으로 가는 관문 열기.]],
}
newAchievement{
	name = "Arachnophobia", id = "SPYDRIC_INFESTATION",
	show = "name",
	kr_name = "거미 공포증",
	desc = [[거미로부터의 위협을 제거.]],
}
newAchievement{
	name = "Clone War", id = "SHADOW_CLONE",
	show = "name",
	kr_name = "클론 전쟁",
	desc = [[자신의 그림자를 파괴.]],
}
newAchievement{
	name = "Home sweet home", id = "SHERTUL_FORTRESS",
	show = "name",
	kr_name = "아, 즐거운 나의 집",
	desc = [[불가사의한 짐승을 해치우고, 쉐르'툴 요새 이일크구르의 소유권 획득]],
}
newAchievement{
	name = "Squadmate", id = "NORGAN_SAVED",
	show = "name",
	kr_name = "팀원",
	desc = [[팀원 노르간과 함께 레크놀에서 탈출.]],
}
newAchievement{
	name = "Genocide", id = "GREATMOTHER_DEAD",
	show = "name", huge=true,
	kr_name = "대학살",
	desc = [[번식용 동굴의 오크 대모를 죽여, 오크들에게 엄청난 피해를 줌.]],
}
newAchievement{
	name = "Savior of the damsels in distress", id = "MELINDA_SAVED",
	show = "name",
	kr_name = "절망에 빠진 소녀의 구원자",
	desc = [[크릴-페이얀의 지하실에서 멜린다를 그녀의 끔찍한 운명에서 구함.]],
}
newAchievement{
	name = "Impossible Death", id = "PARADOX_NOW",
	show = "name",
	kr_name = "불가능한 죽음",
	desc = [[미래의 자신에게 죽음.]],
	on_gain = function(_, src, personal)
		if world:hasAchievement("PARADOX_FUTURE") then world:gainAchievement("PARADOX_FULL", src) end
	end,
}
newAchievement{
	name = "Self-killer", id = "PARADOX_FUTURE",
	show = "name",
	kr_name = "자신을 죽인 자",
	desc = [[미래의 자신을 죽임.]],
	on_gain = function(_, src, personal)
		if world:hasAchievement("PARADOX_NOW") then world:gainAchievement("PARADOX_FULL", src) end
	end,
}
newAchievement{
	name = "Paradoxology", id = "PARADOX_FULL",
	show = "name",
	kr_name = "괴리학",
	desc = [[미래의 자신과 현재의 자신이 동시에 죽음.]],
}
newAchievement{
	name = "Explorer", id = "EXPLORER",
	show = "name",
	kr_name = "탐험가",
	desc = [[같은 캐릭터로 쉐르'툴 요새의 탐험용 장거리 관문을 7 번 이상 이용.]],
}
newAchievement{
	name = "Orbituary", id = "ABASHED_EXPANSE",
	show = "name",
	kr_name = "궤도 안정자",
	desc = [[궤도 유지를 위해, '너무나 광활한 공간' 을 안정화.]],
}
newAchievement{
	name = "Wibbly Wobbly Timey Wimey Stuff", id = "UNHALLOWED_MORASS",
	show = "name",
	kr_name = "제멋대로 엉망진창인 물건", 
	desc = [[무당거미 여왕과 시간의 모독자를 죽임.]],
}
newAchievement{
	name = "Matrix style!", id = "ABASHED_EXPANSE_NO_BLAST",
	show = "full", huge=true,
	kr_name = "매트릭스 따라하기!",
	desc = [['너무나 광활한 공간' 에서 공허의 돌풍이나 마나 벌레에게 한 대도 맞지 않고 일을 마무리함. 피하는 것도 재미있지요!]],
	can_gain = function(self, who, zone)
		if not who:isQuestStatus("start-archmage", engine.Quest.DONE) then return false end
		if zone.void_blast_hits and zone.void_blast_hits == 0 then return true end
	end,
}
newAchievement{
	name = "The Right thing to do", id = "RING_BLOOD_KILL",
	show = "name",
	kr_name = "올바른 일",
	desc = [[피의 투기장에서 올바른 일을 수행하고, 피의 투기장 운영자를 처리함.]],
}
newAchievement{
	name = "Thralless", id = "RING_BLOOD_FREED",
	show = "full",
	kr_name = "노예 해방",
	mode = "player",
	desc = [[노예 수용소에서 30 명 이상의 매혹된 노예를 해방시킴.]],
	can_gain = function(self)
		self.nb = (self.nb or 0) + 1
		if self.nb >= 30 then return true end
	end,
	track = function(self) return tstring{tostring(self.nb or 0)," / 30"} end,
}
newAchievement{
	name = "Lost in translation", id = "SUNWALL_LOST",
	show = "name",
	kr_name = "평행 이동 중의 실종",
	desc = [[슬라지쉬 늪지의 나가 관문을 파괴하고, 그 여파에 휩쓸림.]],
}
newAchievement{
	name = "Dreaming my dreams", id = "ALL_DREAMS",
	show = "full",
	kr_name = "꿈 꾸기",
	desc = [[도그로스 화산분지에서 모든 꿈을 경험하고, 임무를 완수함.]],
	mode = "world",
	can_gain = function(self, who, kind)
		self[kind] = true
		if self.mice and self.lost then return true end
	end,
	track = function(self)
		return tstring{tostring(
			(self.mice and 1 or 0) +
			(self.lost and 1 or 0)
		)," / 2"}
	end,
	on_gain = function(_, src, personal)
		game:setAllowedBuild("psionic")
		game:setAllowedBuild("psionic_solipsist", true)
	end,
}
newAchievement{
	name = "Oozemancer", id = "OOZEMANCER",
	show = "name",
	kr_name = "점액술사",
	desc = [[타락한 점액술사를 죽임.]],
}
newAchievement{
	name = "Lucky Girl", id = "MELINDA_LUCKY",
	show = "name",
	kr_name = "운 좋은 소녀",
	desc = [[멜린다를 다시 구출하고, 요새로 초청하여 그녀를 치료할 것.]],
}