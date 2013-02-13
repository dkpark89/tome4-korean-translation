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

newAchievement{
	name = "Level 10",
	show = "full",
	kr_display_name = "레벨 10",
	desc = [[캐릭터가 레벨 10이 됨.]],
}
newAchievement{
	name = "Level 20",
	show = "full",
	kr_display_name = "레벨 20",
	desc = [[캐릭터가 레벨 20이 됨.]],
}
newAchievement{
	name = "Level 30",
	show = "full",
	kr_display_name = "레벨 30",
	desc = [[캐릭터가 레벨 30이 됨.]],
}
newAchievement{
	name = "Level 40",
	show = "full",
	kr_display_name = "레벨 40",
	desc = [[캐릭터가 레벨 40이 됨.]],
}
newAchievement{
	name = "Level 50",
	show = "full",
	kr_display_name = "레벨 50",
	desc = [[캐릭터가 레벨 50이 됨.]],
}

newAchievement{
	name = "Unstoppable",
	show = "full",
	kr_display_name = "멈출 수 없다",
	desc = [[저승에서 다시 돌아온다.]], -- 기억상으로는 아이템으로 부활하는 것일텐데...
}

newAchievement{
	name = "Utterly Destroyed", id = "EIDOLON_DEATH",
	show = "name",
	kr_display_name = "완전히 작살남",
	desc = [[에이돌론 평원(Eidolon Plane)에서 사망함.]],
}

newAchievement{
	name = "Fool of a Took!", id = "HALFLING_SUICIDE",
	show = "name",
	kr_display_name = "야 이 멍청아!",
	-- 사실 어떻게 번역해야 할지 답이 안나옴. 확실한 건 이거 반지의 제왕에서 간달프가 한 대사 인용임. 자세한 건 http://bit.ly/12eaaQo 로.
	desc = [[하프링으로 자신을 죽임.]], -- 말 그대로 자살...
	can_gain = function(self, who)
		if who.descriptor and who.descriptor.race == "Halfling" then return true end
	end
}

newAchievement{
	name = "Emancipation", id = "EMANCIPATION",
	image = "npc/alchemist_golem.png",
	show = "name",
	kr_display_name = "해방됨",
	desc = [[마스터가 이미 죽은 상태에서 골램이 보스를 죽임.]],
	mode = "player",
	can_gain = function(self, who, target)
		local p = game.party:findMember{main=true}
		if target.rank >= 3.5 and p.dead and p.descriptor.subclass == "Alchemist" and p.alchemy_golem and game.level:hasEntity(p.alchemy_golem) and not p.alchemy_golem.dead then
			return true
		end
	end,
	on_gain = function(_, src, personal)
--		game:setAllowedBuild("construct")
--		game:setAllowedBuild("construct_runic_golem", true)
	end,
}

newAchievement{
	name = "Take you with me", id = "BOSS_REVENGE",
	show = "full",
	kr_display_name = "넌 나랑 같이 간다",
	desc = [[이미 죽은 상태에서 보스를 죽임.]],
	mode = "player",
	can_gain = function(self, who, target)
		local p = game.party:findMember{main=true}
		if target.rank >= 3.5 and p.dead then
			return true
		end
	end,
}

newAchievement{
	name = "Look at me, I'm playing a roguelike!", id = "SELF_CENTERED",
	show = "name",
	kr_display_name = "날 좀 봐, 난 로그라이크 게임을 플레이 한다고!",
	desc = [[인게임 챗에서 자신의 캐릭터를 링크시킴.]],
}

newAchievement{
	name = "Fear me not!", id = "FEARSCAPE",
	show = "full",
	kr_display_name = "겁내지 마!",
	desc = [[피어스케이프(Fearscape)에서 살아남았음!]],
}
