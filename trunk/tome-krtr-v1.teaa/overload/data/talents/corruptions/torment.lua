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
	name = "Willful Tormenter",
	kr_display_name = "의욕 넘치는 고문 기술자",
	type = {"corruption/torment", 1},
	require = corrs_req1,
	mode = "sustained",
	points = 5,
	cooldown = 20,
	tactical = { BUFF = 2 },
	activate = function(self, t)
		game:playSoundNear(self, "talents/flame")
		return {
			vim = self:addTemporaryValue("max_vim", self:getTalentLevel(t) * 15),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("max_vim", p.vim)

		while self:getMaxVim() < 0 do
			local l = {}
			for tid, _ in pairs(self.sustain_talents) do
				local t = self:getTalentFromId(tid)
				if t.sustain_vim then l[#l+1] = tid end
			end
			if #l == 0 then break end
			self:forceUseTalent(rng.table(l), {ignore_energy=true, no_equilibrium_fail=true, no_paradox_fail=true})
		end

		return true
	end,
	info = function(self, t)
		return ([['모든 적들의 파괴' 라는, 단 하나의 목표에 모든 정신을 집중합니다.
		최대 보유 가능한 원기의 양이 %d 상승합니다.]]):
		format(self:getTalentLevel(t) * 15)
	end,
}

newTalent{
	name = "Blood Lock",
	kr_display_name = "피의 고정",
	type = {"corruption/torment", 2},
	require = corrs_req2,
	points = 5,
	cooldown = 16,
	vim = 12,
	range = 10,
	radius = 2,
	tactical = { DISABLE = 1 },
	direct_hit = true,
	no_energy = true,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(tx, ty)
			local target = game.level.map(tx, ty, Map.ACTOR)
			if not target or target == self then return end
			target:setEffect(target.EFF_BLOOD_LOCK, 2 + math.ceil(self:getTalentLevel(t) * 2), {src=self, dam=self:combatTalentSpellDamage(t, 4, 90), power=1+(self:getTalentLevel(t) / 10), apply_power=self:combatSpellpower()})
		end)
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[적들의 피와 생명력에 손을 뻗어, 주변 2 칸 이내의 모든 적들이 %d 턴 동안 생명력 회복을 할 수 없게 됩니다.]]):
		format(2 + math.ceil(self:getTalentLevel(t) * 2))
	end,
}

newTalent{
	name = "Overkill",
	kr_display_name = "과잉 피해",
	type = {"corruption/torment", 3},
	require = corrs_req3,
	points = 5,
	mode = "sustained",
	cooldown = 20,
	sustain_vim = 18,
	tactical = { BUFF = 2 },
	activate = function(self, t)
		game:playSoundNear(self, "talents/flame")
		return {
			ov = self:addTemporaryValue("overkill", 20 + self:combatTalentSpellDamage(t, 10, 70)),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("overkill", p.ov)
		return true
	end,
	info = function(self, t)
		return ([[무언가를 죽일 때, 쓸데없이 남는 피해량을 더이상 낭비하지 않게 됩니다. 남는 피해량의 %d%% 만큼이 폭발하여, 주변 2 칸 반경에 황폐화 피해를 줍니다.
		피해량은 주문력의 영향을 받아 증가합니다.]]):format(20 + self:combatTalentSpellDamage(t, 10, 70))
	end,
}

newTalent{
	name = "Blood Vengeance",
	kr_display_name = "피의 복수",
	type = {"corruption/torment", 4},
	require = corrs_req4,
	points = 5,
	mode = "sustained",
	cooldown = 20,
	getPower = function(self, t) return math.max(2, 10 - self:getTalentLevelRaw(t)), util.bound(40 + self:combatTalentSpellDamage(t, 10, 90), 0, 100) end,
	sustain_vim = 22,
	tactical = { BUFF = 2 },
	activate = function(self, t)
		local l, c = t.getPower(self, t)
		game:playSoundNear(self, "talents/flame")
		return {
			l = self:addTemporaryValue("reduce_spell_cooldown_on_hit", l),
			c = self:addTemporaryValue("reduce_spell_cooldown_on_hit_chance", c),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("reduce_spell_cooldown_on_hit", p.l)
		self:removeTemporaryValue("reduce_spell_cooldown_on_hit_chance", p.c)
		return true
	end,
	info = function(self, t)
		local l, c = t.getPower(self, t)
		return ([[최대 생명력의 %d%% 이상을 한번에 잃으면, %d%% 확률로 모든 기술들의 재사용 대기시간이 1 감소합니다.
		감소 확률은 주문력의 영향을 받아 증가합니다.]]):
		format(l, c)
	end,
}
