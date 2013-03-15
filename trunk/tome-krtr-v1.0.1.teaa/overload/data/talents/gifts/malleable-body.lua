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

newTalent{
	name = "azdadazdazdazd",
	kr_name = "ㅁㅋㅇㅁㅋㅇㅁㅋ",
	type = {"wild-gift/malleable-body", 1},
	require = gifts_req1,
	points = 5,
	equilibrium = 10,
	cooldown = 30,
	no_energy = true,
	tactical = { BUFF = 2 },
	getDur = function(self, t) return math.max(5, math.floor(self:getTalentLevel(t) * 2)) end,
	action = function(self, t)

		return true
	end,
	info = function(self, t)
		local dur = t.getDur(self, t)
		return ([[몸이 점점 형체를 잃어, %d 턴 동안 둘로 나뉘어질 수 있게 됩니다.
		본체는 변하지 않으며, 또 다른 자신은 산성 속성을 가지게 됩니다.
		모든 끈적이는 칼날 계열의 기술들은 그에 맞는 산성 칼날 계열의 기술로 전환됩니다.
		둘 모두 자신의 실체이기 때문에, 생명력은 서로 공유됩니다.
		나뉘어진 동안, 전체 저항력이 %d%% 상승합니다. (둘 모두에게 적용됩니다)
		저항력은 정신력의 영향을 받아 증가합니다.]]):
		format(dur, 10 + self:combatTalentMindDamage(t, 5, 200) / 10)
	end,
}

newTalent{
	name = "ervevev",
	kr_name = "ㄷㄱㅍㄷㄱㅍ",
	type = {"wild-gift/malleable-body", 2},
	require = gifts_req2,
	points = 5,
	mode = "passive",
	getPower = function(self, t) return 20 + self:combatTalentMindDamage(t, 5, 500) / 10 end,

	info = function(self, t)
		local p = t.getPower(self, t)
		return ([[생명력을 회복할 때마다, 미생물의 도움으로 추가적인 생명력을 회복합니다.
		생명력을 회복할 때마다, 6 턴 동안 회복량의 %d%% 만큼이 추가로 재생됩니다.
		생명력 재생은 정신력의 영향을 받아 증가합니다.]]):
		format(p)
	end,
}

newTalent{
	name = "zeczczeczec", 
	kr_name = "ㅋㄷㅊㅋㄷㅊㅋ",
	type = {"wild-gift/malleable-body", 3},
	require = gifts_req3,
	points = 5,
	equilibrium = 5,
	cooldown = 8,

	action = function(self, t)

		return true
	end,
	info = function(self, t)
		return ([[또 다른 자신과 즉시 자리를 바꾸고, 적들이 서로 다른 자신을 공격하게 만듭니다.
		자리를 바꾸는 동안 잠깐 결합하여, 6 턴 동안 적에게 주는 모든 자연과 산성 피해가 %d%% 증가하며, 생명력이 %d 만큼 회복됩니다.
		피해량과 회복량은 정신력의 영향을 받아 증가합니다.]]):
		format(15 + self:combatTalentMindDamage(t, 5, 300) / 10, 40 + self:combatTalentMindDamage(t, 5, 300))
	end,
}

newTalent{
	name = "Indiscernible Anatomyblabla",
	kr_name = "알 수 없는 신체구조의 궁시렁궁시렁", --@@ 한글화 필요 (검수) : 기술 이름 변경에 따른 한글 이름 변경. 기존 이름은 다른 곳에서 사용함.
	type = {"wild-gift/malleable-body", 4},
	require = gifts_req4,
	points = 5,
	mode = "passive",
	on_learn = function(self, t)
		self:attr("ignore_direct_crits", 15)
	end,
	on_unlearn = function(self, t)
		self:attr("ignore_direct_crits", -15)
	end,
	info = function(self, t)
		return ([[몸 속의 장기들이 녹아내리고 마구 섞여, 치명타를 받지 않게 됩니다.
		적에게 받은 치명타가 %d%% 확률로 보통 공격이 되버립니다.]]):
		format(self:getTalentLevelRaw(t) * 15)
	end,
}
