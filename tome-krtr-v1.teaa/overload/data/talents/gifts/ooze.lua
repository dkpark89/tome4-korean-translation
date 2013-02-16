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

newTalent{
	name = "Mitosis",
	kr_display_name = "유사 분열",
	type = {"wild-gift/ooze", 1},
	require = gifts_req1,
	mode = "sustained",
	cooldown = 10,
	sustain_equilibrium = 10,
	getDur = function(self, t) return math.max(5, math.floor(self:getTalentLevel(t) * 2)) end,
	getMax = function(self, t) return math.floor(self:getCun() / 10) end,
	spawn = function(self, t, life)
		if checkMaxSummon(self, true) or not self:canBe("summon") then return end

		-- Find space
		local x, y = util.findFreeGrid(self.x, self.y, 5, true, {[Map.ACTOR]=true})
		if not x then
			game.logPlayer(self, "소환할 공간이 없습니다!")
			return
		end

		local m = mod.class.NPC.new{
			type = "vermin", subtype = "oozes",
			display = "j", color=colors.GREEN, image = "npc/vermin_oozes_green_ooze.png",
			name = "bloated ooze",
			kr_display_name = "진흙 덩어리",
			desc = "당신의 살점으로 만들어진 진흙 덩어리입니다.",
			sound_moam = {"creatures/jelly/jelly_%d", 1, 3},
			sound_die = {"creatures/jelly/jelly_die_%d", 1, 2},
			sound_random = {"creatures/jelly/jelly_%d", 1, 3},
			body = { INVEN = 10 },
			autolevel = "tank",
			ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=1, },
			stats = { wil=10, dex=10, mag=3, str=self:getTalentLevel(t) / 5 * 4, con=self:getWil(), cun=self:getCun() },
			global_speed_base = 0.5,
			combat = {sound="creatures/jelly/jelly_hit"},
			combat_armor = self:getTalentLevel(t) * 5, combat_def = self:getTalentLevel(t) * 5,
			rank = 1,
			size_category = 3,
			infravision = 10,
			cut_immune = 1,
			blind_immune = 1,

			resists = { [DamageType.LIGHT] = -50, [DamageType.COLD] = -50 },
			fear_immune = 1,

			blood_color = colors.GREEN,
			level_range = {self.level, self.level}, exp_worth = 0,
			max_life = 30,

			combat = { dam=5, atk=0, apr=5, damtype=DamageType.POISON },

			summoner = self, summoner_gain_exp=true, wild_gift_summon=true, is_mucus_ooze = true,
			summon_time = math.ceil(self:getTalentLevel(t)) + 5,
			max_summon_time = math.ceil(self:getTalentLevel(t)) + 5,
		}
		if self:knowTalent(self.T_BLIGHTED_SUMMONING) then m:learnTalent(m.T_BONE_SHIELD, true, 2) end
		setupSummon(self, m, x, y)
		m.max_life = life
		m.life = life

		game:playSoundNear(self, "talents/spell_generic2")

		return true
	end,
	info = function(self, t)
		return ([[신체가 진흙 덩어리처럼 변화합니다. 공격을 받을 때마다, %d%% 확률로 받은 피해량 만큼의 생명력을 지닌 진흙 덩어리가 만들어집니다. (진흙 덩어리의 최대 생명력 : %d)
		자신이 받는 모든 피해량은 자신과 진흙 덩어리가 나눠서 받게 됩니다.
		최대 %d 개의 진흙 덩어리까지 만들어낼 수 있습니다. (교활함 능력치에 기반하여 최대 개수가 증가합니다)]]):
		format(t.getChance(self, t), t.getMax(self, t))
	end,
}

newTalent{
	name = "Reabsorb",
	kr_display_name = "재흡수",
	type = {"wild-gift/ooze", 2},
	require = gifts_req2,
	points = 5,
	mode = "passive",
	getPower = function(self, t) return 20 + self:combatTalentMindDamage(t, 5, 500) / 10 end,
	on_pre_use = function(self, t)
		if not game.party:findMember{type="mitosis"} then return end
		return true
	end,
	info = function(self, t)
		local p = t.getPower(self, t)
		return ([[자기 주변의 미생물들이 치료 효과를 향상시키도록 만듭니다.
		자신이 치료될 때마다, 치료되는 양의 %d%% 만큼 6 턴간 생명력이 재생됩니다.
		기술의 효과는 정신력의 영향을 받아 증가합니다.]]):
		format(p)
	end,
}

newTalent{
	name = "Swap", short_name = "MITOSIS_SWAP",
	kr_display_name = "위치 교체",
	type = {"wild-gift/ooze", 3},
	require = gifts_req3,
	points = 5,
	equilibrium = 5,
	cooldown = 8,
	on_pre_use = function(self, t)
		if not game.party:findMember{type="mitosis"} then return end
		return true
	end,
	action = function(self, t)
		local target = game.party:findMember{type="mitosis"}

		local dur = 1 + self:getTalentLevel(t)
		self:setEffect(self.EFF_MITOSIS_SWAP, 6, {power=15 + self:combatTalentMindDamage(t, 5, 300) / 10})
		target:setEffect(target.EFF_MITOSIS_SWAP, 6, {power=15 + self:combatTalentMindDamage(t, 5, 300) / 10})

		self:heal(40 + self:combatTalentMindDamage(t, 5, 300))

		-- Displace
		game.level.map:remove(self.x, self.y, Map.ACTOR)
		game.level.map:remove(target.x, target.y, Map.ACTOR)
		game.level.map(self.x, self.y, Map.ACTOR, target)
		game.level.map(target.x, target.y, Map.ACTOR, self)
		self.x, self.y, target.x, target.y = target.x, target.y, self.x, self.y

		game:playSoundNear(self, "talents/teleport")
		return true
	end,
	info = function(self, t)
		return ([[공격당하면 상대의 공격목표가 바뀌도록, 분열된 자신과 위치를 즉시 바꿉니다.
		위치를 바꾸는 동안 자신끼리 잠시 결합하여, 자연 피해량과 산성 피해량을 6 턴간 %d%% 증가시키고 생명력을 %d 만큼 치료합니다.
		피해량과 치유량은 정신력의 영향을 받아 증가합니다.]]):
		format(15 + self:combatTalentMindDamage(t, 5, 300) / 10, 40 + self:combatTalentMindDamage(t, 5, 300))
	end,
}

newTalent{
	name = "One With The Ooze",
	kr_display_name = "진흙과의 교감",
	type = {"wild-gift/ooze", 4},
	require = gifts_req4,
	points = 5,
	mode = "passive",
	on_learn = function(self, t)
		self:attr("blind_immune", 0.2)
		self:attr("poison_immune", 0.2)
		self:attr("disease_immune", 0.2)
		self:attr("cut_immune", 0.2)
		self:attr("confusion_immune", 0.2)
	end,
	on_unlearn = function(self, t)
		self:attr("blind_immune", -0.2)
		self:attr("poison_immune", -0.2)
		self:attr("disease_immune", -0.2)
		self:attr("cut_immune", -0.2)
		self:attr("confusion_immune", -0.2)
	end,
	info = function(self, t)
		return ([[신체가 더욱 진흙처럼 변화하여 질병, 독, 출혈, 혼란, 실명 면역력이 %d%% 상승하게 됩니다.]]):
		format(self:getTalentLevelRaw(t) * 20)
	end,
}
