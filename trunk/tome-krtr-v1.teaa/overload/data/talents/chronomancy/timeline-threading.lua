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

require "engine.krtrUtils" --@@

newTalent{
	name = "Gather the Threads",
	kr_display_name = "시간의 흐름 - 수집",
	type = {"chronomancy/timeline-threading", 1},
	require = chrono_req_high1,
	points = 5,
	paradox = 5,
	cooldown = 12,
	tactical = { BUFF = 2 },
	getThread = function(self, t) return  6 * self:getTalentLevel(t) end,
	getReduction = function(self, t) return 3 * self:getTalentLevel(t) end,
	action = function(self, t)
		self:setEffect(self.EFF_GATHER_THE_THREADS, 5, {power=t.getThread(self, t), reduction=t.getReduction(self, t)})
		game:playSoundNear(self, "talents/spell_generic2")
		return true
	end,
	info = function(self, t)
		local primary = t.getThread(self, t)
		local reduction = t.getReduction(self, t)
		return ([[다른 시간축에서 에너지를 모아 주문력이 %0.2f 상승하며, 매 턴마다 주문력이 %0.2f 만큼 추가로 상승합니다.
		이 효과는 주문을 시전하거나, 5 턴이 지나면 사라집니다.
		이 효과가 활성화된 동안, 매 턴마다 괴리 수치가 %d 감소합니다.
		이 마법은 시공간 조율의 효과를 깨뜨리지 않으며, 그 반대도 마찬가지입니다.]]):format(primary + (primary/5), primary/5, reduction)
	end,
}

newTalent{
	name = "Rethread",
	kr_display_name = "시간의 흐름 - 조정",
	type = {"chronomancy/timeline-threading", 2},
	require = chrono_req_high2,
	points = 5,
	paradox = 5,
	cooldown = 4,
	tactical = { ATTACK = {TEMPORAL = 2} },
	range = 10,
	direct_hit = true,
	reflectable = true,
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 200)*getParadoxModifier(self, pm) end,
	getReduction = function(self, t) return math.ceil(self:getTalentLevel(t)) end,
	action = function(self, t)
		local tg = {type="beam", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y, t.paradox)
		x, y = checkBackfire(self, x, y)
		self:project(tg, x, y, DamageType.RETHREAD, {dam=self:spellCrit(t.getDamage(self, t)), reduction = t.getReduction(self, t)})
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "temporalbeam", {tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local reduction = t.getReduction(self, t)
		return ([[시간 에너지의 파동을 일으켜, 파동의 궤도에 있는 적들에게 %0.2f 피해를 주고 시간축을 조정합니다.
		공격에 맞은 대상은 3 턴 동안 기절, 실명, 속박, 혼란 중 하나의 상태효과에 걸립니다.
		공격에 맞은 적 1 명 마다 괴리 수치가 %d 씩 줄어듭니다.
		피해량은 괴리 수치와 주문력 능력치의 영향을 받아 증가합니다.]]):
		format(damDesc(self, DamageType.TEMPORAL, damage), reduction)
	end,
}

newTalent{
	name = "Temporal Clone",
	kr_display_name = "시간의 흐름 - 복제",
	type = {"chronomancy/timeline-threading", 3},
	require = chrono_req_high3,
	points = 5,
	cooldown = 30,
	paradox = 15,
	tactical = { ATTACK = 2, DISABLE = 2 },
	requires_target = true,
	range = 6,
	no_npc_use = true,
	getDuration = function(self, t) return 3 + math.ceil(self:getTalentLevel(t)* getParadoxModifier(self, pm)) end,
	getSize = function(self, t) return 2 + math.ceil(self:getTalentLevelRaw(t) / 2 ) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty then return nil end
		if not target or self:reactionToward(target) >= 0 then return end

		-- Find space
		local x, y = util.findFreeGrid(tx, ty, 1, true, {[Map.ACTOR]=true})
		if not x then
			game.logPlayer(self, "소환할 공간이 없습니다!")
			return
		end

		allowed = t.getSize(self, t)

		if target.rank >= 3.5 or -- No boss
			target:reactionToward(self) >= 0 or -- No friends
			target.size_category > allowed
			then
			game.logPlayer(self, "%s 저항했습니다!", (target.kr_display_name or target.name):capitalize():addJosa("가"))
			return true
		end

		local m = target:clone{
			no_drops = true,
			faction = self.faction,
			summoner = self, summoner_gain_exp=true,
			summon_time = t.getDuration(self, t),
			ai_target = {actor=target},
			ai = "summoned", ai_real = target.ai,
		}
		m:removeAllMOs()
		m.make_escort = nil
		m.on_added_to_level = nil
		
		m.energy.value = 0
		m.life = m.life
		m.forceLevelup = function() end
		-- Handle special things
		m.on_die = nil
		m.on_acquire_target = nil
		m.seen_by = nil
		m.can_talk = nil
		m.clone_on_hit = nil
		if m.talents.T_SUMMON then m.talents.T_SUMMON = nil end
		if m.talents.T_MULTIPLY then m.talents.T_MULTIPLY = nil end

		game.zone:addEntity(game.level, m, "actor", x, y)
		game.level.map:particleEmitter(x, y, 1, "temporal_teleport")

		-- force target to attack double
		local a = game.level.map(tx, ty, Map.ACTOR)
		if a and self:reactionToward(a) < 0 then
			a:setTarget(m)
		end

		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local allowed = t.getSize(self, t)
		if allowed < 4 then
			size = "중간"
		elseif allowed < 5 then
			size = "큼"
		else
			size = "거대함"
		end
		return ([[다른 시간축에서 '%s' 크기 이하인 대상의 '사본'을 끌어옵니다. '사본'은 %d 턴 동안 존재할 수 있으며, '원본'과 '사본'은 서로를 보는 즉시 공격합니다.
		지속시간은 괴리 수치의 영향을 받아 증가합니다.]]):
		format(size, duration)
	end,
}

newTalent{
	name = "See the Threads",
	kr_display_name = "시간의 흐름 - 예견",
	type = {"chronomancy/timeline-threading", 4},
	require = chrono_req_high4,
	points = 5,
	paradox = 50,
	cooldown = 50,
	no_npc_use = true,
	no_energy = true,
	getDuration = function(self, t) return 4 + math.floor(self:getTalentLevel(t) * getParadoxModifier(self, pm)) end,
	action = function(self, t)
		if checkTimeline(self) == true then
			return
		end
		self:setEffect(self.EFF_SEE_THREADS, t.getDuration(self, t), {})
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		return ([[세 가지 미래를 엿봐, 각각 %d 턴 동안 미래에 일어날 일을 직접 체험할 수 있게 됩니다. 지속시간이 끝나면, 세 가지 미래 중 어떤 미래를 고를지 결정하게 됩니다. 
		결정된 미래가 자신의 미래가 되며, 이 마법으로 자신의 죽음을 체험해버리면 치명적인 결과가 일어날 수 있습니다.
		이 마법은 시간의 흐름을 분절시키기 때문에, 이 마법을 사용하는 도중에는 시간의 흐름을 나누는 다른 마법을 사용할 수 없습니다.
		이 마법은 시전시간 없이 즉시 사용할 수 있습니다.]])
		:format(duration)
	end,
}
