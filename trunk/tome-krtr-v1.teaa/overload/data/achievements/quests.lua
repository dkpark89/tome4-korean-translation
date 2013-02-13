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

--------------- Tutorial objectives
newAchievement{
	name = "Baby steps", id = "TUTORIAL_DONE",
	kr_display_name = "첫 걸음마",
	desc = [[ToME4 연습게임를 완료.]],
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
	show = "name",
	kr_display_name = "흡혈귀 분쇄",
	desc = [[Destroyed the Master in its lair of the Dreadfell.]],
}
newAchievement{
	name = "A dangerous secret",
	show = "name",
	kr_display_name = "위험한 비밀",
	desc = [[Found the mysterious staff and told Last Hope about it.]],
}
newAchievement{
	name = "The secret city",
	show = "none",
	kr_display_name = "숨겨진 도시",
	desc = [[Discovered the truth about mages.]],
}
newAchievement{
	name = "Burnt to the ground", id="APPRENTICE_STAFF",
	show = "none",
	kr_display_name = "불타올라 대지로",
	desc = [[Gave the staff of absorption to the apprentice mage and watched the fireworks.]],
}
newAchievement{
	name = "Against all odds", id = "KILL_UKRUK",
	show = "name",
	kr_display_name = "기괴한 놈들과 맞섬",
	desc = [[Killed Ukruk in the ambush.]],
}
newAchievement{
	name = "Sliders",
	image = "object/artifact/orb_many_ways.png",
	show = "name",
	kr_display_name = "활주",
	desc = [[Activated a portal using the Orb of Many Ways.]],
	on_gain = function()
		game:onTickEnd(function() game.party:learnLore("first-farportal") end)
	end
}
newAchievement{
	name = "Destroyer's bane", id = "DESTROYER_BANE",
	show = "name",
	kr_display_name = "파괴자의 죽음",
	desc = [[Killed Golbug the Destroyer.]],
}
newAchievement{
	name = "Brave new world", id = "STRANGE_NEW_WORLD",
	show = "name",
	kr_display_name = "용감하게 신세계로",
	desc = [[Went to the Far East and took part in the war.]],
}
newAchievement{
	name = "Race through fire", id = "CHARRED_SCAR_SUCCESS",
	show = "name",
	kr_display_name = "화염을 뚫고 질주",
	desc = [[Raced through the fires of the Charred Scar to stop the Sorcerers.]],
}
newAchievement{
	name = "Orcrist", id = "ORC_PRIDE",
	show = "name",
	kr_display_name = "오크 살해자",
	desc = [[Killed the leaders of the Orc Pride.]],
}

--------------- Wins
newAchievement{
	name = "Evil denied", id = "WIN_FULL",
	show = "name",
	kr_display_name = "악마는 사절입니다",
	desc = [[Won ToME by preventing the Void portal from opening.]],
}
newAchievement{
	name = "The High Lady's destiny", id = "WIN_AERYN",
	show = "name",
	kr_display_name = "고귀한 여인의 운명",
	desc = [[Won ToME by closing the Void portal using Aeryn as a sacrifice.]],
}
newAchievement{
	name = "Selfless", id = "WIN_SACRIFICE",
	show = "name",
	kr_display_name = "희생",
	desc = [[Won ToME by closing the Void portal using yourself as a sacrifice.]],
}
newAchievement{
	name = "Triumph of the Way", id = "YEEK_SACRIFICE",
	show = "name",
	kr_display_name = "'한길'의 승리",
	desc = [[Won ToME by sacrificing yourself to forcefully spread the Way to every other sentient being on Eyal.]],
}
newAchievement{
	name = "Tactical master", id = "SORCERER_NO_PORTAL",
	show = "name",
	kr_display_name = "전략의 대가",
	desc = [[Fought the two Sorcerers without closing any invocation portals.]],
}
newAchievement{
	name = "Portal destroyer", id = "SORCERER_ONE_PORTAL",
	show = "name",
	kr_display_name = "관문 파괴자",
	desc = [[Fought the two Sorcerers and closed one invocation portal.]],
}
newAchievement{
	name = "Portal reaver", id = "SORCERER_TWO_PORTAL",
	show = "name",
	kr_display_name = "관문 약탈자", --@@ 일단, 여기만 그냥 둠. reaver를 약탈자로 변경시 marauder를 대체할 단어 필요 (둘다 캐릭터 직업, 현재 reaver:파괴자, marauder:약탈자)
	desc = [[Fought the two Sorcerers and closed two invocation portals.]],
}
newAchievement{
	name = "Portal ender", id = "SORCERER_THREE_PORTAL",
	show = "name",
	kr_display_name = "관문 폐지자",
	desc = [[Fought the two Sorcerers and closed three invocation portals.]],
}
newAchievement{
	name = "Portal master", id = "SORCERER_FOUR_PORTAL",
	show = "name",
	kr_display_name = "관문의 주인",
	desc = [[Fought the two Sorcerers and closed four invocation portals.]],
}

-------------- Other quests
newAchievement{
	name = "Rescuer of the lost", id = "LOST_MERCHANT_RESCUE",
	show = "name",
	kr_display_name = "실종자 구출",
	desc = [[Rescued the merchant from the assassin lord.]],
}
newAchievement{
	name = "Poisonous", id = "LOST_MERCHANT_EVIL",
	show = "name",
	kr_display_name = "맹독성",
	desc = [[Sided with the assassin lord.]],
}
newAchievement{
	name = "Destroyer of the creation", id = "SLASUL_DEAD",
	show = "name",
	kr_display_name = "창조의 파괴자",
	desc = [[Killed Slasul.]],
}
newAchievement{
	name = "Treacherous Bastard", id = "SLASUL_DEAD_PRODIGY_LEARNT",
	show = "name",
	kr_display_name = "이런 배반자 자식",
	desc = [[Killed Slasul even though you sided with him to learn the Legacy of the Naloren prodigy.]],
}
newAchievement{
	name = "Flooder", id = "UKLLMSWWIK_DEAD",
	show = "name",
	kr_display_name = "홍수를 부르는자",
	desc = [[Defeated Ukllmswwik while doing his own quest.]],
}
newAchievement{
	name = "Gem of the Moon", id = "MASTER_JEWELER",
	show = "name",
	kr_display_name = "달의 보석",
	desc = [[Completed the Master Jeweler quest with Limmir.]],
}
newAchievement{
	name = "Curse Lifter", id = "CURSE_ERASER",
	show = "name",
	kr_display_name = "저주를 걷어낸 자",
	desc = [[Killed Ben Cruthdar the Cursed.]],
}
newAchievement{
	name = "Eye of the storm", id = "EYE_OF_THE_STORM",
	show = "name",
	kr_display_name = "폭풍의 눈",
	desc = [[Freed Derth from the onslaught of the mad Tempest, Urkis.]],
}
newAchievement{
	name = "Antimagic!", id = "ANTIMAGIC",
	show = "name",
	kr_display_name = "반마법!",
	desc = [[Completed antimagic training in the Ziguranth camp.]],
}
newAchievement{
	name = "Anti-Antimagic!", id = "ANTI_ANTIMAGIC",
	show = "name",
	kr_display_name = "반-반마법!",
	desc = [[Destroyed the Ziguranth camp with your Rhaloren allies.]],
}
newAchievement{
	name = "There and back again", id = "WEST_PORTAL",
	show = "name",
	kr_display_name = "그 곳에서 돌아옴",
	desc = [[Opened a portal to Maj'Eyal from the Far East.]],
}
newAchievement{
	name = "Back and there again", id = "EAST_PORTAL",
	kr_display_name = "다시 또 그 곳에",
	show = "name",
	desc = [[Opened a portal to the Far East from Maj'Eyal.]],
}
newAchievement{
	name = "Arachnophobia", id = "SPYDRIC_INFESTATION",
	show = "name",
	kr_display_name = "거미 공포증",
	desc = [[Destroyed the spydric menace.]],
}
newAchievement{
	name = "Clone War", id = "SHADOW_CLONE",
	show = "name",
	kr_display_name = "클론 전쟁",
	desc = [[Destroyed your own Shade.]],
}
newAchievement{
	name = "Home sweet home", id = "SHERTUL_FORTRESS",
	show = "name",
	kr_display_name = "아, 즐거운 나의 집",
	desc = [[Dispatched the Weirdling Beast and took possession of Yiilkgur, the Sher'Tul Fortress for your own usage.]],
}
newAchievement{
	name = "Squadmate", id = "NORGAN_SAVED",
	show = "name",
	kr_display_name = "팀원",
	desc = [[Escaped from Reknor alive with your squadmate Norgan.]],
}
newAchievement{
	name = "Genocide", id = "GREATMOTHER_DEAD",
	show = "name",
	kr_display_name = "대학살",
	desc = [[Killed the Orc Greatmother in the breeding pits, thus dealing a terrible blow to the orc race.]],
}
newAchievement{
	name = "Savior of the damsels in distress", id = "MELINDA_SAVED",
	show = "name",
	kr_display_name = "절망에 빠진 소녀의 구원자",
	desc = [[Saved Melinda from her terrible fate in the Crypt of Kryl-Feijan.]],
}
newAchievement{
	name = "Impossible Death", id = "PARADOX_NOW",
	show = "name",
	kr_display_name = "불가능한 죽음",
	desc = [[Got killed by your future self.]],
	on_gain = function(_, src, personal)
		if world:hasAchievement("PARADOX_FUTURE") then world:gainAchievement("PARADOX_FULL", src) end
	end,
}
newAchievement{
	name = "Self-killer", id = "PARADOX_FUTURE",
	show = "name",
	kr_display_name = "자신-살인자",
	desc = [[Killed your future self.]],
	on_gain = function(_, src, personal)
		if world:hasAchievement("PARADOX_NOW") then world:gainAchievement("PARADOX_FULL", src) end
	end,
}
newAchievement{
	name = "Paradoxology", id = "PARADOX_FULL",
	show = "name",
	kr_display_name = "괴리학",
	desc = [[Both killed your future self and got killed by your future self.]],
}
newAchievement{
	name = "Explorer", id = "EXPLORER",
	show = "name",
	kr_display_name = "탐험가",
	desc = [[Used the Sher'Tul fortress exploratory farportal at least 7 times with the same character.]],
}
newAchievement{
	name = "Orbituary", id = "ABASHED_EXPANSE",
	show = "name",
	kr_display_name = "궤도 안정자",
	desc = [[Stabilized the Abashed Expanse to maintain it in orbit.]],
}
newAchievement{
	name = "Wibbly Wobbly Timey Wimey Stuff", id = "UNHALLOWED_MORASS",
	show = "name",
	kr_display_name = "제멋대로 엉망진창인 물건", --@@ 이스터애그 "Wibbly Wobbly Timey Wimey"는 드라마 doctor who에 나온 대사임 
	desc = [[Killed the weaver queen and the temporal defiler.]],
}
newAchievement{
	name = "Matrix style!", id = "ABASHED_EXPANSE_NO_BLAST",
	show = "full",
	kr_display_name = "매트릭스 따라하기!",
	desc = [[Finished the whole Abashed Expanse zone without being hit by a single void blast or manaworm. Dodging's fun!]],
	can_gain = function(self, who, zone)
		if not who:isQuestStatus("start-archmage", engine.Quest.DONE) then return false end
		if zone.void_blast_hits and zone.void_blast_hits == 0 then return true end
	end,
}
newAchievement{
	name = "The Right thing to do", id = "RING_BLOOD_KILL",
	show = "name",
	kr_display_name = "올바른 일",
	desc = [[Did the righteous thing in the ring of blood and disposed of the Blood Master.]],
}
newAchievement{
	name = "Thralless", id = "RING_BLOOD_FREED",
	show = "full",
	kr_display_name = "노예 해방",
	mode = "player",
	desc = [[Freed at least 30 enthralled slaves in the slavers compound.]],
	can_gain = function(self)
		self.nb = (self.nb or 0) + 1
		if self.nb >= 30 then return true end
	end,
	track = function(self) return tstring{tostring(self.nb or 0)," / 30"} end,
}
newAchievement{
	name = "Lost in translation", id = "SUNWALL_LOST",
	show = "name",
	kr_display_name = "평행 이동 중의 실종",
	desc = [[Destroyed the naga portal in the slazish fens and got caught in the after-effect.]],
}
newAchievement{
	name = "Dreaming my dreams", id = "ALL_DREAMS",
	show = "full",
	kr_display_name = "꿈 꾸기",
	desc = [[Experienced and completed all the dreams in the Dogroth Caldera.]],
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
