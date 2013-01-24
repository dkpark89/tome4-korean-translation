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
	name = "Paradox Mastery",
	kr_display_name = "괴리 수련",
	type = {"chronomancy/paradox", 1},
	mode = "passive",
	require = chrono_req_high1,
	points = 5,
	on_learn = function(self, t)
		self.resists[DamageType.TEMPORAL] = (self.resists[DamageType.TEMPORAL] or 0) + 7
	end,
	on_unlearn = function(self, t)
		self.resists[DamageType.TEMPORAL] = self.resists[DamageType.TEMPORAL] - 7
	end,
	info = function(self, t)
		local resist = self:getTalentLevelRaw(t) * 7
		local stability = math.floor(self:getTalentLevel(t)/2)
		return ([[시공간 연속체에 대한 제어 방법을 익히고, 이상 현상을 억누르는 방법을 배웁니다. 시간 저항력이 %d%% 상승하고, '고정된 역사' 의 지속시간이 %d 턴 증가합니다.
		또한 시공 계열 마법들의 실패 확률, 이상 현상 발생 확률, 역효과 확률을 계산할 때, %d 만큼 상승된 의지 능력치가 적용됩니다. (실제로 의지 능력치가 상승하지는 않습니다)]]):
		format(resist, stability, self:getTalentLevel(t) * 10)
	end,
}

newTalent{
	name = "Cease to Exist",
	kr_display_name = "중단된 실존",
	type = {"chronomancy/paradox", 2},
	require = chrono_req_high2,
	points = 5,
	cooldown = 24,
	paradox = 20,
	range = 10,
	tactical = { ATTACK = 2 },
	requires_target = true,
	direct_hit = true,
	no_npc_use = true,
	getDuration = function(self, t) return 4 + math.floor(self:getTalentLevel(t) * getParadoxModifier(self, pm)) end,
	getPower = function(self, t) return self:combatTalentSpellDamage(t, 10, 50) * getParadoxModifier(self, pm) end,
	do_instakill = function(self, t)
		-- search for target because it's ID will change when the chrono restore takes place
		local tg = false
		local grids = core.fov.circle_grids(self.x, self.y, 10, true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local a = game.level.map(x, y, Map.ACTOR)
			if a and a:hasEffect(a.EFF_CEASE_TO_EXIST) then
				tg = a
			end
		end end
		
		if tg then
			game:onTickEnd(function()
				tg:removeEffect(tg.EFF_CEASE_TO_EXIST)
				game.logSeen(tg, "#LIGHT_BLUE#%s 따위는 원래부터 없었던 존재였습니다!", (tg.kr_display_name or tg.name):capitalize())
				tg:die(self)
			end)
		end
	end,
	action = function(self, t)
		-- check for other chrono worlds
		if checkTimeline(self) == true then
			return
		end
		
		-- get our target
		local tg = {type="hit", range=self:getTalentRange(t)}
		local tx, ty = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, tx, ty = self:canProject(tg, tx, ty)
		
		local target = game.level.map(tx, ty, Map.ACTOR)
		if not target then return end

		if target == self then
			game.logSeen(self, "#LIGHT_STEEL_BLUE#%s 자기 자신의 존재를 지우려고 합니다!", (self.kr_display_name or self.name):addJosa("는")) --@@
			self:incParadox(400)
			game.level.map:particleEmitter(self.x, self.y, 1, "ball_temporal", {radius=1, tx=self.x, ty=self.y})
			return true
		end
		
		-- does the spell hit?  if not nothing happens
		if not self:checkHit(self:combatSpellpower(), target:combatSpellResist()) then
			game.logSeen(target, "%s 저항했습니다!", (target.kr_display_name or target.name):capitalize():addJosa("가"))
			return true
		end
	
		-- Manualy start cooldown before the chronoworld is made
		game.player:startTalentCooldown(t)
		
		-- set up chronoworld next, we'll load it when the target dies in class\actor
		game:onTickEnd(function()
			game:chronoClone("cease_to_exist")
		end)
			
		target:setEffect(target.EFF_CEASE_TO_EXIST, t.getDuration(self,t), {power=t.getPower(self, t)})
				
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local power = t.getPower(self, t)
		return ([[%d 턴 동안, 대상을 시공간에서 없애버리려고 시도합니다. 지속시간 동안 대상의 모든 저항력이 %d%% 감소합니다. 
		지속시간 내에 대상을 죽이면 처음 마법을 시전했던 순간으로 돌아가며, 이 때 대상은 시공간에서 사라져버립니다.
		이 마법은 시간의 흐름을 분절시키기 때문에, 이 마법을 사용하는 도중에는 시간의 흐름을 나누는 다른 마법을 사용할 수 없습니다.
		지속시간은 괴리 수치, 저항력 감소는 괴리 수치와 주문력 능력치의 영향을 받아 증가합니다.]])
		:format(duration, power)
	end,
}

newTalent{
	name = "Fade From Time",
	kr_display_name = "시간에서 흐려진 자",
	type = {"chronomancy/paradox", 3},
	require = chrono_req_high3,
	points = 5,
	paradox = 10,
	cooldown = 24,
	tactical = { DEFEND = 2, CURE = 2 },
	getResist = function(self, t) return self:combatTalentSpellDamage(t, 10, 50) * getParadoxModifier(self, pm) end,
	action = function(self, t)
		self:setEffect(self.EFF_FADE_FROM_TIME, 10, {power=t.getResist(self, t)})
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		local resist = t.getResist(self, t)
		return ([[10 턴 동안 시공간에서 자신의 일부분을 없애 모든 피해 저향력이 %d%% 상승하고, 모든 효과의 지속시간이 %d%%, 적에게 가하는 모든 공격의 피해량이 20%% 감소합니다.
		마법의 효과는 지속시간이 지나면서 점점 그 힘을 잃게 됩니다.
		마법의 효과는 괴리 수치와 주문력 능력치의 영향을 받아 증가합니다.]]):
		format(resist, resist, resist/10)
	end,
}

newTalent{
	name = "Paradox Clone",
	kr_display_name = "모순된 복제",
	type = {"chronomancy/paradox", 4},
	require = chrono_req_high4,
	points = 5,
	paradox = 25,
	cooldown = 50,
	tactical = { ATTACK = 1, DISABLE = 2 },
	range = 2,
	requires_target = true,
	no_npc_use = true,
	getDuration = function(self, t) return 3 + math.ceil(self:getTalentLevel(t)*getParadoxModifier(self, pm)) end,
	getModifier = function(self, t) return rng.range(t.getDuration(self,t)*2, t.getDuration(self, t)*4) end,
	action = function (self, t)
		if checkTimeline(self) == true then
			return
		end

		local tg = {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, talent=t}
		local tx, ty = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, tx, ty = self:canProject(tg, tx, ty)
		if not tx or not ty then return nil end
		
		local x, y = util.findFreeGrid(tx, ty, 2, true, {[Map.ACTOR]=true})
		if not x then
			game.logPlayer(self, "소환할 공간이 없습니다!")
			return
		end

		local sex = game.player.female and "그녀" or "그"
		local m = require("mod.class.NPC").new(self:clone{
			no_drops = true,
			faction = self.faction,
			summoner = self, summoner_gain_exp=true,
			summon_time = t.getDuration(self, t),
			ai_target = {actor=nil},
			ai = "summoned", ai_real = "tactical",
			ai_tactic = resolvers.tactic("ranged"), ai_state = { talent_in=1, ally_compassion=10},
			desc = [[진짜 '자기 자신' 입니다... 혹은 ]]..sex..[[는 그렇게 말합니다.]]
		})
		m:removeAllMOs()
		m.make_escort = nil
		m.on_added_to_level = nil
		
		m.energy.value = 0
		m.player = nil
		m.puuid = nil
		m.max_life = m.max_life
		m.life = util.bound(m.life, 0, m.max_life)
		m.forceLevelup = function() end
		m.die = nil
		m.on_die = nil
		m.on_acquire_target = nil
		m.seen_by = nil
		m.can_talk = nil
		m.on_takehit = nil
		m.no_inventory_access = true
		m.clone_on_hit = nil
		m.remove_from_party_on_death = true
		
		-- Remove some talents
		local tids = {}
		for tid, _ in pairs(m.talents) do
			local t = m:getTalentFromId(tid)
			if t.no_npc_use then tids[#tids+1] = t end
		end
		for i, t in ipairs(tids) do
			m.talents[t.id] = nil
		end
		
		game.zone:addEntity(game.level, m, "actor", x, y)
		game.level.map:particleEmitter(x, y, 1, "temporal_teleport")
		game:playSoundNear(self, "talents/teleport")

		if game.party:hasMember(self) then
			game.party:addMember(m, {
				control="no",
				type="minion",
				title="Paradox Clone",
				orders = {target=true},
			})
		end

		self:setEffect(self.EFF_IMMINENT_PARADOX_CLONE, t.getDuration(self, t) + t.getModifier(self, t), {})
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		return ([[미래의 자신을 %d 턴 동안 소환하여 자신을 돕게 만듭니다. 이 효과가 끝나고 난 뒤의 어떤 순간에, 이번에는 자신이 과거에 끌려가 과거의 자신을 도와줘야 하는 상황이 오게 됩니다.
		이 마법은 시간의 흐름을 분절시키기 때문에, 이 마법을 사용하는 도중에는 시간의 흐름을 나누는 다른 마법을 사용할 수 없습니다.
		지속시간은 괴리 수치의 영향을 받아 증가합니다.]]):format(duration)
	end,
}
