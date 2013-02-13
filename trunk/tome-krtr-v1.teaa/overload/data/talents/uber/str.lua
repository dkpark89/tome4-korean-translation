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

uberTalent{
	name = "Flexible Combat",
	kr_display_name = "유연한 전투기술",
	mode = "passive",
	on_learn = function(self, t)
		self:attr("unharmed_attack_on_hit", 1)
		self:attr("show_gloves_combat", 1)
	end,
	on_unlearn = function(self, t)
		self:attr("unharmed_attack_on_hit", -1)
		self:attr("show_gloves_combat", -1)
	end,
	info = function(self, t)
		return ([[근접 공격을 할 때마다, 60%% 확률로 추가적인 맨손 공격을 할 수 있게 됩니다.]])
		:format()
	end,
}

uberTalent{
	name = "You Shall Be My Weapon!", short_name="TITAN_S_SMASH", image = "talents/titan_s_smash.png",
	kr_display_name = "나의 무기가 되어라!",
	mode = "activated",
	require = { special={desc="신체 크기가 '거대함' 이상일 것", fct=function(self) return self.size_category and self.size_category >= 5 end} },
	requires_target = true,
	tactical = { ATTACK = 4 },
	on_pre_use = function(self, t) return self.size_category and self.size_category >= 5 end,
	cooldown = 12,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		local hit = self:attackTarget(target, nil, 3.5, true)

		if target:attr("dead") or not hit then return end

		local dx, dy = (target.x - self.x), (target.y - self.y)
		local dir = util.coordToDir(dx, dy, 0)
		local sides = util.dirSides(dir, 0)

		target:knockback(self.x, self.y, 5, function(t2)
			local d = rng.chance(2) and sides.hard_left or sides.hard_right
			local sx, sy = util.coordAddDir(t2.x, t2.y, d)
			local ox, oy = t2.x, t2.y
			t2:knockback(sx, sy, 2, function(t3) return true end)
			if t2:canBe("stun") then t2:setEffect(t2.EFF_STUNNED, 3, {}) end
		end)
		if target:canBe("stun") then target:setEffect(target.EFF_STUNNED, 3, {}) end
	end,
	info = function(self, t)
		return ([[적에게 강력한 일격을 날려, 350%% 무기 피해를 주고 6 칸 뒤로 밀어냅니다.
		밀려나면서 다른 적과 부딪힐 때마다, 부딪힌 적이 3 턴간 기절하게 됩니다.]])
		:format()
	end,
}

uberTalent{
	name = "Massive Blow",
	kr_display_name = "*강력한* 일격",
	mode = "activated",
	require = { special={desc="30 번 이상의 굴착 경험이 있으며, 양손무기로 적에게 총 50,000 이상의 피해를 가할 것", fct=function(self) return 
		self.dug_times and self.dug_times >= 30 and 
		self.damage_log and self.damage_log.weapon.twohanded and self.damage_log.weapon.twohanded >= 50000
	end} },
	requires_target = true,
	tactical = { ATTACK = 4 },
	cooldown = 12,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		local destroyed = false
		target:knockback(self.x, self.y, 4, nil, function(g, x, y)
			if g:attr("dig") and not destroyed then
				DamageType:get(DamageType.DIG).projector(self, x, y, DamageType.DIG, 1)
				destroyed = true
			end
		end)

		self:attackTarget(target, nil, 1.5 + (destroyed and 3.5 or 0), true)
		return true
	end,
	info = function(self, t)
		return ([[적에게 강력한 일격을 날려, 150%% 무기 피해를 주고 4 칸 뒤로 밀어냅니다.
		밀려난 적이 벽과 부딪힐 경우, 벽이 파괴되고 350%% 무기 피해를 추가로 받습니다.]])
		:format()
	end,
}

uberTalent{
	name = "Steamroller",
	kr_display_name = "강압",
	mode = "passive",
	require = { special={desc="돌진 기술을 알고 있을 것", fct=function(self) return self:knowTalent(self.T_RUSH) end} },
	info = function(self, t)
		return ([[적에게 돌진 기술을 사용하면, 적에게 표식이 생깁니다. 다음 2 턴 이내에 표식이 생긴 적을 죽이면, 돌진 기술의 재사용 대기시간이 사라져 다시 사용할 수 있게 됩니다.
		이 효과가 발생할 때마다 적에게 주는 피해가 20%% 증가하며. 최대 100%% 까지 증가합니다.]])
		:format()
	end,
}

uberTalent{
	name = "Irresistible Sun",
	kr_display_name = "저항할 수 없는 태양의 힘",
	cooldown = 25,
	requires_target = true,
	range = 5,
	tactical = { ATTACK = 4, CLOSEIN = 2 },
	require = { special={desc="화염이나 빛 속성으로 적에게 총 50,000 이상의 피해를 가할 것", fct=function(self) return
		self.damage_log and (
			(self.damage_log[DamageType.FIRE] and self.damage_log[DamageType.FIRE] >= 50000) or
			(self.damage_log[DamageType.LIGHT] and self.damage_log[DamageType.LIGHT] >= 50000)
		)
	end} },
	action = function(self, t)
		self:setEffect(self.EFF_IRRESISTIBLE_SUN, 6, {dam=50 + self:getStr() * 2})
		return true
	end,
	info = function(self, t)
		local dam = (50 + self:getStr() * 2) / 3
		return ([[6 턴 동안 강력한 별의 힘을 빌어, 주변 5 칸 이내의 모든 적들을 끌어와 %0.2f 화염 피해, %0.2f 전기 피해, %0.2f 물리 피해를 동시에 줍니다.
		시전자와 붙어있는 적에게는 피해량이 200%% 증가합니다.
		피해량은 힘 능력치의 영향을 받아 증가합니다.]])
		:format(damDesc(self, DamageType.FIRE, dam), damDesc(self, DamageType.LIGHT, dam), damDesc(self, DamageType.PHYSICAL, dam))
	end,
}

uberTalent{
	name = "I Can Carry The World!", short_name = "NO_FATIGUE",
	kr_display_name = "세상을 짊어질 자",
	mode = "passive",
	require = { special={desc="판갑을 입을 수 있을 것", fct=function(self) return self:getTalentLevelRaw(self.T_ARMOUR_TRAINING) >= 3 end} },
	on_learn = function(self, t)
		self:attr("max_encumber", 500)
	end,
	info = function(self, t)
		return ([[몸에 힘이 넘쳐흘러, 피로도가 0 이 되고 무게 제한이 500 늘어납니다.]])
		:format()
	end,
}

uberTalent{
	name = "Legacy of the Naloren",
	kr_display_name = "날로레의 유산",
	mode = "passive",
	require = { special={desc="슬라슐의 편에 서서, 우클름스윅을 죽일 것", fct=function(self)
		if game.state.birth.ignore_prodigies_special_reqs then return true end
		local q = self:hasQuest("temple-of-creation")
		return q and not q:isCompleted("kill-slasul") and q:isCompleted("kill-drake")
	end} },
	on_learn = function(self, t)
		self:learnTalent(self.T_SPIT_POISON, true, 5)
		self:learnTalent(self.T_EXOTIC_WEAPONS_MASTERY, true, 5)
		self.__show_special_talents = self.__show_special_talents or {}
		self.__show_special_talents[self.T_EXOTIC_WEAPONS_MASTERY] = true
		self.can_breath = self.can_breath or {}
		self.can_breath.water = (self.can_breath.water or 0) + 1

		require("engine.ui.Dialog"):simplePopup("날로렌의 유산", "당신의 신념이 그의 영향을 받았음을 알게되면, 슬라슐이 기뻐할 것입니다. 당신은 슬라슐에게 돌아가 이 이야기를 해줘야 합니다.")
	end,
	info = function(self, t)
		return ([[슬라슐을 도와, 우클름스윅을 격퇴시켰습니다. 물 속에서 숨을 쉴 수 있게 되며, 삼지창을 포함한 각종 이형 무기들을 손쉽게 다룰 수 있게 됩니다. (이형 무기 수련 기술을 배우고, 기술 레벨이 5 가 됩니다)
		또한 나가처럼 독을 뱉을 수 있게 되며, 슬라슐이 감사의 표시로 또 다른 보상을 줄지도 모릅니다.]])
		:format()
	end,
}

uberTalent{
	name = "Superpower",
	kr_display_name = "의지의 힘, 힘의 의지",
	mode = "passive",
	info = function(self, t)
		return ([[강한 정신은 강한 육체에서 오는 법입니다. 그리고 강한 정신은 강한 육체를 만드는 법이죠.
		힘 능력치의 25%% 만큼 정신력이 올라가며, 무기의 적용 능력치에 의지 능력치의 30%% 만큼이 추가됩니다.]])
		:format()
	end,
}
