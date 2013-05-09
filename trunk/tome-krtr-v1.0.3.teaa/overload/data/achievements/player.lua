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

newAchievement{
	name = "Level 10",
	show = "full",
	kr_name = "레벨 10",
	desc = [[캐릭터가 레벨 10 이 됨.]],
}
newAchievement{
	name = "Level 20",
	show = "full",
	kr_name = "레벨 20",
	desc = [[캐릭터가 레벨 20 이 됨.]],
}
newAchievement{
	name = "Level 30",
	show = "full",
	kr_name = "레벨 30",
	desc = [[캐릭터가 레벨 30 이 됨.]],
}
newAchievement{
	name = "Level 40",
	show = "full",
	kr_name = "레벨 40",
	desc = [[캐릭터가 레벨 40 이 됨.]],
}
newAchievement{
	name = "Level 50",
	show = "full",
	kr_name = "레벨 50",
	desc = [[캐릭터가 레벨 50 이 됨.]],
}

newAchievement{
	name = "Unstoppable",
	show = "full",
	kr_name = "무쌍",
	desc = [[부활.]],
}

newAchievement{
	name = "Utterly Destroyed", id = "EIDOLON_DEATH",
	show = "name",
	kr_name = "완전히 파괴됨",
	desc = [[에이돌론의 차원에서 사망.]],
}

newAchievement{
	name = "Fool of a Took!", id = "HALFLING_SUICIDE",
	show = "name",
	kr_name = "야 이 멍청아!",
	desc = [[하플링 캐릭터로 자살.]],
	can_gain = function(self, who)
		if who.descriptor and who.descriptor.race == "Halfling" then return true end
	end
}

newAchievement{
	name = "Emancipation", id = "EMANCIPATION",
	image = "npc/alchemist_golem.png",
	show = "name",
	kr_name = "해방",
	desc = [[연금술사 주인이 죽은 상태에서, 골렘이 보스를 죽임.]],
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
	kr_name = "물귀신 작전",
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
	kr_name = "날 좀 봐, 난 로그라이크 게임을 하고 있다고!",
	desc = [[채팅창에 자신의 캐릭터를 연결함.]],
}

newAchievement{
	name = "Fear me not!", id = "FEARSCAPE",
	show = "full",
	kr_name = "겁도 안나!",
	desc = [[공포의 영역에서 생환!]],
}
