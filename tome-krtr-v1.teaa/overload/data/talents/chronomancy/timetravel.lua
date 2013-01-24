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
	name = "Static History",
	kr_display_name = "고정된 역사",
	type = {"chronomancy/timetravel", 1},
	require = chrono_req1,
	points = 5,
	message = "@Source1@ 역사를 재배열합니다.",
	cooldown = 24,
	tactical = { PARADOX = 2 },
	getDuration = function(self, t)
		local duration = 1 + math.floor(self:getTalentLevel(t)/2)

		if self:knowTalent(self.T_PARADOX_MASTERY) then
			duration = 1 + math.floor((self:getTalentLevel(t)/2) + (self:getTalentLevel(self.T_PARADOX_MASTERY)/2))
		end

		return duration
	end,
	getReduction = function(self, t) return self:combatTalentSpellDamage(t, 20, 200) end,
	action = function(self, t)
		self:incParadox (- t.getReduction(self, t))
		game:playSoundNear(self, "talents/spell_generic")
		self:setEffect(self.EFF_SPACETIME_STABILITY, t.getDuration(self, t), {})
		return true
	end,
	info = function(self, t)
		local reduction = t.getReduction(self, t)
		local duration = t.getDuration(self, t)
		return ([[역사를 살짝 바꿔, 괴리 수치를 %d 감소시키고 시공간을 안정화시킵니다. 이를 통해 시공 계열 마법의 실패 확률을 %d 턴 동안 0%% 로 만듭니다. (이상 현상이나 역효과 확률은 바뀌지 않습니다)
		괴리 수치 감소량은 주문력 능력치의 영향을 받아 증가합니다.]]):
		format(reduction, duration)
	end,
}

newTalent{
	name = "Time Skip",
	kr_display_name = "시간 지우기",
	type = {"chronomancy/timetravel",2},
	require = chrono_req2,
	points = 5,
	cooldown = 6,
	paradox = 5,
	tactical = { ATTACK = {TEMPORAL = 1}, DISABLE = 2 },
	range = 6,
	direct_hit = true,
	reflectable = true,
	requires_target = true,
	target = function(self, t)
		return {type="hit", range=self:getTalentRange(t), talent=t}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 25, 250) * getParadoxModifier(self, pm) end,
	getDuration = function(self, t) return 2 + math.ceil(self:getTalentLevel(t) / 2 * getParadoxModifier(self, pm)) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		local target = game.level.map(x, y, Map.ACTOR)
		if not target then return end

		if target:attr("timetravel_immune") then
			game.logSeen(target, "%s 시간을 지울 수 없습니다!", (target.kr_display_name or target.name):capitalize():addJosa("는"))
			return
		end

		local hit = self:checkHit(self:combatSpellpower(), target:combatSpellResist() + (target:attr("continuum_destabilization") or 0))
		if not hit then game.logSeen(target, "%s 저항했습니다!", (target.kr_display_name or target.name):capitalize():addJosa("가")) return true end
		
		self:project(tg, x, y, DamageType.TEMPORAL, self:spellCrit(t.getDamage(self, t)))
		game.level.map:particleEmitter(x, y, 1, "temporal_thrust")
		game:playSoundNear(self, "talents/arcane")
		if target.dead or target.player then return true end
		target:setEffect(target.EFF_CONTINUUM_DESTABILIZATION, 100, {power=self:combatSpellpower(0.3)})
		
		-- Replace the target with a temporal instability for a few turns
		local oe = game.level.map(target.x, target.y, engine.Map.TERRAIN)
		if not oe or oe:attr("temporary") then return true end
		local e = mod.class.Object.new{
			old_feat = oe, type = oe.type, subtype = oe.subtype,
			name = "temporal instability", image = oe.image, add_mos = {{image="object/temporal_instability.png"}},
			kr_display_name = "불안정한 시공간",
			display = '&', color=colors.LIGHT_BLUE,
			temporary = t.getDuration(self, t),
			canAct = false,
			target = target,
			act = function(self)
				self:useEnergy()
				self.temporary = self.temporary - 1
				-- return the rifted actor
				if self.temporary <= 0 then
					game.level.map(self.target.x, self.target.y, engine.Map.TERRAIN, self.old_feat)
					game.level:removeEntity(self)
					local mx, my = util.findFreeGrid(self.target.x, self.target.y, 20, true, {[engine.Map.ACTOR]=true})
					local old_levelup = self.target.forceLevelup
					self.target.forceLevelup = function() end
					game.zone:addEntity(game.level, self.target, "actor", mx, my)
					self.target.forceLevelup = old_levelup
				end
			end,
			summoner_gain_exp = true, summoner = self,
		}
		
		game.logSeen(target, "%s 시간의 흐름에서 벗어났습니다!", (target.kr_display_name or target.name):capitalize():addJosa("가"))
		game.level:removeEntity(target, true)
		game.level:addEntity(e)
		game.level.map(x, y, Map.TERRAIN, e)
		game.nicer_tiles:updateAround(game.level, x, y)
		game.level.map:updateMap(x, y)
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		return ([[대상이 주문 내성으로 저항에 실패했을 경우, %0.2f 시간 피해를 주고 %d 턴 동안 시간의 흐름에서 벗어나게 만듭니다.
		지속시간은 괴리 수치에 따라, 피해량은 괴리 수치와 주문력 능력치에 따라 증가합니다.]]):format(damDesc(self, DamageType.TEMPORAL, damage), duration)
	end,
}

newTalent{
	name = "Echoes From The Past",
	kr_display_name = "과거의 메아리",
	type = {"chronomancy/timetravel", 3},
	require = chrono_req3,
	points = 5,
	paradox = 10,
	cooldown = 6,
	tactical = { ATTACKAREA = {TEMPORAL = 2} },
	range = 0,
	radius = function(self, t)
		return 1 + self:getTalentLevelRaw(t)
	end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	direct_hit = true,
	requires_target = true,
	getDamage = function(self, t) return (self:combatTalentSpellDamage(t, 18, 160)*getParadoxModifier(self, pm)) end,
	getPercent = function(self, t) return (10 + (self:combatTalentSpellDamage(t, 1, 10))) / 100 end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, DamageType.TEMPORAL, self:spellCrit(t.getDamage(self, t)))
		self:project(tg, self.x, self.y, DamageType.TEMPORAL_ECHO, t.getPercent(self, t))
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "ball_temporal", {radius=tg.radius})
		game:playSoundNear(self, "talents/teleport")
		return true
	end,
	info = function(self, t)
		local percent = t.getPercent(self, t) * 100
		local radius = self:getTalentRadius(t)
		local damage = t.getDamage(self, t)
		return ([[%d 칸 반경에 시간의 메아리를 만들어 범위 내의 적들에게 %0.2f 시간 피해를 주고, 최대 생명력에서 현재 생명력을 뺀 값의 %d%% 에 해당하는 시간 피해를 추가로 줍니다.
		생명력 비율과 피해량은 괴리 수치와 주문력 능력치의 영향을 받아 증가합니다.]]):
		format(radius, damage, percent)
	end,
}

newTalent{
	name = "Temporal Reprieve",
	kr_display_name = "시간의 유예",
	type = {"chronomancy/timetravel", 4},
	require = chrono_req4,
	points = 5,
	paradox = 20,
	cooldown = 50,
	tactical = { BUFF = 0.5, CURE = 0.5 },
	message = "@Source1@ 시간의 흐름을 조종합니다.",
	getCooldownReduction = function(self, t) return 1 + math.floor(self:getTalentLevel(t) * getParadoxModifier(self, pm)) end,
	action = function(self, t)
		-- update cooldowns
		for tid, cd in pairs(self.talents_cd) do
			self.talents_cd[tid] = cd - t.getCooldownReduction(self, t)
		end

		local target = self
		local todel = {}
		for eff_id, p in pairs(target.tmp) do
			local e = target.tempeffect_def[eff_id]
			if e.type ~= "other" then
				p.dur = p.dur - t.getCooldownReduction(self, t)
				if p.dur <= 0 then todel[#todel+1] = eff end
			end
		end
		while #todel > 0 do
			target:removeEffect(table.remove(todel))
		end

		return true
	end,
	info = function(self, t)
		local reduction = t.getCooldownReduction(self, t)
		return ([[시간의 흐름을 조작하여 모든 재사용 대기시간을 %d 턴 줄이고, 모든 상태효과의 지속시간을 %d 턴 줄입니다.
		좋은 상태효과의 지속시간도 줄어들며, 기술의 효과는 괴리 수치의 영향을 받아 증가합니다.]]):
		format(reduction, reduction)
	end,
}

--[=[
newTalent{
	name = "Door to the Past",
	kr_display_name = "과거로의 문",
	type = {"chronomancy/timetravel", 4},
	require = chrono_req4, no_sustain_autoreset = true,
	points = 5,
	mode = "sustained",
	sustain_paradox = 150,
	cooldown = 25,
	no_npc_use = true,
	getAnomalyCount = function(self, t) return math.ceil(self:getTalentLevel(t)) end,
	on_learn = function(self, t)
		if not self:knowTalent(self.T_REVISION) then
			self:learnTalent(self.T_REVISION, nil, nil, {no_unlearn=true})
		end
	end,
	on_unlearn = function(self, t)
		if not self:knowTalent(t) then
			self:unlearnTalent(self.T_REVISION)
		end
	end,
	do_anomalyCount = function(self, t)
		if self.dttp_anomaly_count == 0 then
			-- check for anomaly
			if not game.zone.no_anomalies and not self:attr("no_paradox_fail") and self:paradoxAnomalyChance() then
				-- Random anomaly
				local ts = {}
				for id, t in pairs(self.talents_def) do
					if t.type[1] == "chronomancy/anomalies" then ts[#ts+1] = id end
				end
				if not silent then game.logPlayer(self, "과거로의 문이 이상 현상을 발생시켰습니다!") end
				self:forceUseTalent(rng.table(ts), {ignore_energy=true})
			end
			-- reset count
			self.dttp_anomaly_count = t.getAnomalyCount(self, t)
		else
			self.dttp_anomaly_count = self.dttp_anomaly_count - 1
		end
	end,
	activate = function(self, t)
		if checkTimeline(self) == true then
			return
		end

		-- set the counter
		self.dttp_anomaly_count = t.getAnomalyCount(self, t)

		game:playSoundNear(self, "talents/arcane")
		return {
			game:onTickEnd(function()
				game:chronoClone("revision")
			end),
			particle = self:addParticles(Particles.new("temporal_aura", 1)),
		}
	end,
	deactivate = function(self, t, p)
		if game._chronoworlds then game._chronoworlds = nil end
		self.dttp_anomaly_count = nil
		self:removeParticles(p.particle)
		return true
	end,
	info = function(self, t)
		local count = t.getAnomalyCount(self, t)
		return ([[이 강력한 주문은 이후 '교정'을 사용하여 되돌아갈 시간에 표시를 해 둘 수 있도록 만듭니다 (이 기술을 배우면 '교정'도 자동적으로 배우게 됩니다). 이 통로를 유지하면 지속적으로 시공간 연속의 긴장을 발생시키고, 매 %d 턴 마다 (현재 이상 현상 확률에 따라) 이상 현상을 일으킬 수도 있습니다.
		이 마법은 시간의 흐름을 분절시키기 때문에, 이 마법을 사용하는 도중에는 시간의 흐름을 나누는 다른 마법을 사용할 수 없습니다.
		기술 레벨이 높아지면 이상 현상 발생 검사 사이의 시간 간격을 늘려줍니다.]]):
		format(count)
	end,
}

newTalent{
	name = "Revision",
	kr_display_name = "교정",
	type = {"chronomancy/other", 1},
	type_no_req = true,
	points = 1,
	message = "@Source1@ 역사를 수정합니다.",
	cooldown = 50,
	paradox = 25,
	no_npc_use = true,
	on_pre_use = function(self, t, silent) if not self:isTalentActive(self.T_DOOR_TO_THE_PAST) then if not silent then game.logPlayer(self, "이 기술을 사용하기 위해서는 '과거로의 문'이 사용중이어야 합니다.") end return false end return true end,
	action = function(self, t)

		-- Prevent Revision After Death
		if game._chronoworlds == nil then
			game.logPlayer(game.player, "#LIGHT_RED#주문이 피식거리며 사라집니다.")
			return
		end

		game:onTickEnd(function()
			if not game:chronoRestore("revision", true) then
				game.logSeen(self, "#LIGHT_RED#주문이 피식거리며 사라집니다.")
				return
			end
			game.logPlayer(game.player, "#LIGHT_BLUE#당신은 시공간 연속을 이전 단계로 펼쳤습니다!")

			-- Manualy start the cooldown of the "old player"
			game.player:startTalentCooldown(t)
			game.player:incParadox(t.paradox * (1 + (game.player.paradox / 300)))
			game.player:forceUseTalent(game.player.T_DOOR_TO_THE_PAST, {ignore_energy=true})
			-- remove anomaly count
			if self.dttp_anomaly_count then self.dttp_anomaly_count = nil end
			if game._chronoworlds then game._chronoworlds = nil end
		end)

		return true
	end,
	info = function(self, t)
		return ([[교정을 사용하면 '과거로의 문'을 사용하여 시간의 표시를 한 시점으로 되돌아갑니다.]])
		:format()
	end,
}]=]
