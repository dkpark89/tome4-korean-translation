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
	name = "Disperse Magic",
	kr_name = "마법 흩뜨리기",
	type = {"spell/meta",1},
	require = spells_req1,
	points = 5,
	random_ego = "utility",
	mana = 40,
	cooldown = 7,
	tactical = { DISABLE = 2 },
	direct_hit = true,
	requires_target = function(self, t) return self:getTalentLevel(t) >= 3 end,
	range = 10,
	getRemoveCount = function(self, t) return math.floor(self:getTalentLevel(t)) end,
	action = function(self, t)
		local target = self

		if self:getTalentLevel(t) >= 3 then
			local tg = {type="hit", range=self:getTalentRange(t)}
			local tx, ty = self:getTarget(tg)
			if tx and ty and game.level.map(tx, ty, Map.ACTOR) then
				local _ _, tx, ty = self:canProject(tg, tx, ty)
				if not tx then return nil end
				target = game.level.map(tx, ty, Map.ACTOR)
				if not target then return nil end

				target = game.level.map(tx, ty, Map.ACTOR)
			else return nil
			end
		end

		local effs = {}

		-- Go through all spell effects
		if self:reactionToward(target) < 0 then
			for eff_id, p in pairs(target.tmp) do
				local e = target.tempeffect_def[eff_id]
				if e.type == "magical" and e.status == "beneficial" then
					effs[#effs+1] = {"effect", eff_id}
				end
			end

			-- Go through all sustained spells
			for tid, act in pairs(target.sustain_talents) do
				if act then
					local talent = target:getTalentFromId(tid)
					if talent.is_spell then effs[#effs+1] = {"talent", tid} end
				end
			end
		else
			for eff_id, p in pairs(target.tmp) do
				local e = target.tempeffect_def[eff_id]
				if e.type == "magical" and e.status == "detrimental" then
					effs[#effs+1] = {"effect", eff_id}
				end
			end
		end

		for i = 1, t.getRemoveCount(self, t) do
			if #effs == 0 then break end
			local eff = rng.tableRemove(effs)

			if eff[1] == "effect" then
				target:removeEffect(eff[2])
			else
				target:forceUseTalent(eff[2], {ignore_energy=true})
			end
		end
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local count = t.getRemoveCount(self, t)
		return ([[시전자의 마법적 효과를 %d 개 제거합니다. 
		기술 레벨이 3 이상이면 대상을 지정할 수 있게 되며, 적에게 사용하면 좋은 효과를, 아군에게 사용하면 나쁜 효과를 제거할 수 있습니다.]]):
		format(count)
	end,
}

newTalent{
	name = "Spellcraft",
	kr_name = "정교한 주문",
	type = {"spell/meta",2},
	require = spells_req2,
	points = 5,
	sustain_mana = 70,
	cooldown = 30,
	mode = "sustained",
	tactical = { BUFF = 2 },
	getChance = function(self, t) return self:getTalentLevelRaw(t) * 20 end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/spell_generic")
		return {
			cd = self:addTemporaryValue("spellshock_on_damage", self:combatTalentSpellDamage(t, 10, 320) / 4),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("spellshock_on_damage", p.cd)
		return true
	end,
	info = function(self, t)
		local chance = t.getChance(self, t)
		return ([[공격 마법들의 주문을 더 정교화시켜, %d%% 확률로 자신이 사용한 공격 마법에 자신은 피해를 입지 않게 됩니다.
		또한, 적들의 주문 내성을 뚫고 주문 충격을 주기 위한 목적으로 %d 만큼 강화된 주문력이 적용됩니다. (실제 주문력 상승은 일어나지 않으며, 피해량 상승 등의 효과 역시 일어나지 않습니다)
		이를 통해 주문 충격이 일어난 대상은 피해 저항력이 20%% 감소하게 됩니다.]]):
		format(chance, self:combatTalentSpellDamage(t, 10, 320) / 4)
	end,
}

newTalent{
	name = "Quicken Spells",
	kr_name = "재빠른 주문",
	type = {"spell/meta",3},
	require = spells_req3,
	points = 5,
	mode = "sustained",
	sustain_mana = 80,
	cooldown = 30,
	tactical = { BUFF = 2 },
	getCooldownReduction = function(self, t) return util.bound(self:getTalentLevelRaw(t) / 15, 0.05, 0.3) end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/spell_generic")
		return {
			cd = self:addTemporaryValue("spell_cooldown_reduction", t.getCooldownReduction(self, t)),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("spell_cooldown_reduction", p.cd)
		return true
	end,
	info = function(self, t)
		local cooldownred = t.getCooldownReduction(self, t)
		return ([[모든 마법들의 지연시간이 %d%% 줄어듭니다.]]):
		format(cooldownred * 100)
	end,
}

newTalent{
	name = "Metaflow",
	kr_name = "마력의 흐름",
	type = {"spell/meta",4},
	require = spells_req4,
	points = 5,
	mana = 70,
	cooldown = 50,
	tactical = { BUFF = 2 },
	getTalentCount = function(self, t) return math.ceil(self:getTalentLevel(t) + 2) end,
	getMaxLevel = function(self, t) return self:getTalentLevelRaw(t) end,
	action = function(self, t)
		local tids = {}
		for tid, _ in pairs(self.talents_cd) do
			local tt = self:getTalentFromId(tid)
			if tt.type[2] <= t.getMaxLevel(self, t) and tt.is_spell then
				tids[#tids+1] = tid
			end
		end
		for i = 1, t.getTalentCount(self, t) do
			if #tids == 0 then break end
			local tid = rng.tableRemove(tids)
			self.talents_cd[tid] = nil
		end
		self.changed = true
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local talentcount = t.getTalentCount(self, t)
		local maxlevel = t.getMaxLevel(self, t)
		return ([[마력의 흐름에 대한 깊은 이해를 통해, 마법의 지연시간을 초기화시킵니다. %d 레벨 이하의 마법 %d 개를 바로 사용할 수 있도록 만듭니다.]]):
		format(maxlevel, talentcount)
	end,
}
