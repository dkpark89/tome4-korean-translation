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

require "engine.krtrUtils"

local Stats = require "engine.interface.ActorStats"
local Particles = require "engine.Particles"
local Entity = require "engine.Entity"
local Chat = require "engine.Chat"
local Map = require "engine.Map"
local Level = require "engine.Level"
local Astar = require "engine.Astar"

newEffect{
	name = "SILENCED", image = "effects/silenced.png",
	desc = "Silenced",
	kr_name = "침묵",
	long_desc = function(self, eff) return "침묵 : 모든 주문 시전 불가능 / 목소리를 사용하는 기술 사용 불가능" end,
	type = "mental",
	subtype = { silence=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target1# 침묵 상태가 됩니다!", "+침묵" end,
	on_lose = function(self, err) return "#Target1# 다시 말할 수 있게 되었습니다.", "-침묵" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("silence", 1)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("silence", eff.tmpid)
	end,
}

newEffect{
	name = "SUMMON_CONTROL", image = "talents/summon_control.png",
	desc = "Summon Control",
	kr_name = "제어되는 소환수",
	long_desc = function(self, eff) return ("전체 저항 +%d%% / 소환 지속시간 +%d 턴"):format(eff.res, eff.incdur) end,
	type = "mental",
	subtype = { focus=true },
	status = "beneficial",
	parameters = { res=10, incdur=10 },
	activate = function(self, eff)
		eff.resid = self:addTemporaryValue("resists", {all=eff.res})
		eff.durid = self:addTemporaryValue("summon_time", eff.incdur)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("resists", eff.resid)
		self:removeTemporaryValue("summon_time", eff.durid)
	end,
	on_timeout = function(self, eff)
		eff.dur = self.summon_time
	end,
}

newEffect{
	name = "CONFUSED", image = "effects/confused.png",
	desc = "Confused",
	kr_name = "혼란",
	long_desc = function(self, eff) return ("혼란 : %d%% 의 확률로 멋대로 행동 / 복잡한 행동 불가능"):format(eff.power) end,
	type = "mental",
	subtype = { confusion=true },
	status = "detrimental",
	parameters = { power=50 },
	on_gain = function(self, err) return "#Target1# 마구 두리번거립니다!", "+혼란" end,
	on_lose = function(self, err) return "#Target1# 다시 집중하기 시작했습니다.", "-혼란" end,
	activate = function(self, eff)
		eff.power = math.floor(math.max(eff.power - (self:attr("confusion_immune") or 0) * 100, 10))
		eff.power = util.bound(eff.power, 0, 50)
		eff.tmpid = self:addTemporaryValue("confused", eff.power)
		if eff.power <= 0 then eff.dur = 0 end
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("confused", eff.tmpid)
		if self == game.player and self.updateMainShader then self:updateMainShader() end
	end,
}

newEffect{
	name = "DOMINANT_WILL", image = "talents/yeek_will.png",
	desc = "Dominated",
	kr_name = "지배됨",
	long_desc = function(self, eff) return ("원래 정신은 부서지고, 육체는 지배되어 노예가 됨") end,
	type = "mental",
	subtype = { dominate=true },
	status = "detrimental",
	parameters = { },
	on_gain = function(self, err) return "#Target#의 정신이 부서졌습니다." end,
	on_lose = function(self, err) return "#Target1# 쓰러집니다." end,
	activate = function(self, eff)
		eff.pid = self:addTemporaryValue("inc_damage", {all=-15})
		self.faction = eff.src.faction
		self.ai_state = self.ai_state or {}
		self.ai_state.tactic_leash = 100
		self.remove_from_party_on_death = true
		self.no_inventory_access = true
		self.move_others = true
		self.summoner = eff.src
		self.summoner_gain_exp = true
		if self.dead then return end
		game.party:addMember(self, {
			control="full",
			type="thrall",
			title="Thrall",
			orders = {leash=true, follow=true},
			on_control = function(self)
				self:hotkeyAutoTalents()
			end,
		})
	end,
	deactivate = function(self, eff)
		self:die(eff.src)
	end,
}

newEffect{
	name = "BATTLE_SHOUT", image = "talents/battle_shout.png",
	desc = "Battle Shout",
	kr_name = "전장의 외침",
	long_desc = function(self, eff) return ("최대 생명력 +%d%% / 최대 체력 +%d%%"):format(eff.power, eff.power) end, --@@ 변수 조정
	type = "mental",
	subtype = { morale=true },
	status = "beneficial",
	parameters = { power=10 },
	activate = function(self, eff)
		eff.life = self:addTemporaryValue("max_life", self.max_life * eff.power / 100)
		eff.stamina = self:addTemporaryValue("max_stamina", self.max_stamina * eff.power / 100)
		self:heal(self.max_life * eff.power / 100)
		self:incStamina(self.max_stamina * eff.power / 100)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("max_life", eff.life)
		self:removeTemporaryValue("max_stamina", eff.stamina)
	end,
}

newEffect{
	name = "BATTLE_CRY", image = "talents/battle_cry.png",
	desc = "Battle Cry",
	kr_name = "전장의 포효",
	long_desc = function(self, eff) return ("전장의 포효로 인해 전투의지 상실 : 회피도 -%d"):format(eff.power) end,
	type = "mental",
	subtype = { morale=true },
	status = "detrimental",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target#의 전투의지가 무너졌습니다.", "+전장의 포효" end,
	on_lose = function(self, err) return "#Target1# 다시 정신을 다잡습니다.", "-전장의 포효" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("combat_def", -eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_def", eff.tmpid)
	end,
}

newEffect{
	name = "WILLFUL_COMBAT", image = "talents/willful_combat.png",
	desc = "Willful Combat",
	kr_name = "의지의 전투",
	long_desc = function(self, eff) return ("의지의 전투 : 공격시 피해량 +%d"):format(eff.power) end,
	type = "mental",
	subtype = { focus=true },
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target1# 순수한 의지력을 담아 공격하기 시작합니다." end,
	on_lose = function(self, err) return "#Target#의 의지력 쇄도가 끝났습니다." end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("combat_dam", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_dam", eff.tmpid)
	end,
}

newEffect{
	name = "GLOOM_WEAKNESS", image = "effects/gloom_weakness.png",
	desc = "Gloom Weakness",
	kr_name = "침울함의 약화",
	long_desc = function(self, eff) return ("침울함 : 공격시 피해 -%d%%"):format(-eff.incDamageChange) end,
	type = "mental",
	subtype = { gloom=true },
	status = "detrimental",
	parameters = { atk=10, dam=10 },
	on_gain = function(self, err) return "#F53CBE##Target1# 침울한 기운에 의해 약해졌습니다." end,
	on_lose = function(self, err) return "#F53CBE##Target#의 약화가 사라졌습니다." end,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("gloom_weakness", 1))
		eff.incDamageId = self:addTemporaryValue("inc_damage", {all = eff.incDamageChange})
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
		self:removeTemporaryValue("inc_damage", eff.incDamageId)
	end,
}

newEffect{
	name = "GLOOM_SLOW", image = "effects/gloom_slow.png",
	desc = "Slowed by the gloom",
	kr_name = "침울함의 감속",
	long_desc = function(self, eff) return ("침울함 : 모든 행동 속도 -%d%%"):format(eff.power * 100) end,
	type = "mental",
	subtype = { gloom=true, slow=true },
	status = "detrimental",
	parameters = { power=0.1 },
	on_gain = function(self, err) return "#F53CBE##Target1# 억지로 움직이기 시작합니다!", "+감속" end,
	on_lose = function(self, err) return "#Target1# 침울함을 극복했습니다.", "-감속" end,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("gloom_slow", 1))
		eff.tmpid = self:addTemporaryValue("global_speed_add", -eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("global_speed_add", eff.tmpid)
		self:removeParticles(eff.particle)
	end,
}

newEffect{
	name = "GLOOM_STUNNED", image = "effects/gloom_stunned.png",
	desc = "Stunned by the gloom",
	kr_name = "침울함의 기절",
	long_desc = function(self, eff) return ("침울함으로 인해 기절 : 공격시 피해량 -70%% / 이동 속도 -50%% / 50%% 확률로 임의의 기술이 대기상태로 변경 / 재사용 대기시간이 줄어들지 않음"):format() end,
	type = "mental",
	subtype = { gloom=true, stun=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#F53CBE##Target1# 공포로 기절했습니다!", "+기절" end,
	on_lose = function(self, err) return "#Target1# 침울함을 극복했습니다.", "-기절" end,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("gloom_stunned", 1))

		eff.tmpid = self:addTemporaryValue("stunned", 1)
		eff.tcdid = self:addTemporaryValue("no_talents_cooldown", 1)
		eff.speedid = self:addTemporaryValue("movement_speed", -0.5)

		local tids = {}
		for tid, lev in pairs(self.talents) do
			local t = self:getTalentFromId(tid)
			if t and not self.talents_cd[tid] and t.mode == "activated" and not t.innate and t.no_energy ~= true then tids[#tids+1] = t end
		end
		for i = 1, 4 do
			local t = rng.tableRemove(tids)
			if not t then break end
			self.talents_cd[t.id] = 1 -- Just set cooldown to 1 since cooldown does not decrease while stunned
		end
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)

		self:removeTemporaryValue("stunned", eff.tmpid)
		self:removeTemporaryValue("no_talents_cooldown", eff.tcdid)
		self:removeTemporaryValue("movement_speed", eff.speedid)
	end,
}

newEffect{
	name = "GLOOM_CONFUSED", image = "effects/gloom_confused.png",
	desc = "Confused by the gloom",
	kr_name = "침울함의 혼란",
	long_desc = function(self, eff) return ("침울함으로 인해 혼란 : %d%% 의 확률로 멋대로 행동 / 복잡한 행동 불가능"):format(eff.power) end,
	type = "mental",
	subtype = { gloom=true, confusion=true },
	status = "detrimental",
	parameters = { power = 10 },
	on_gain = function(self, err) return "#F53CBE##Target1# 절망에 빠집니다!", "+혼란" end,
	on_lose = function(self, err) return "#Target1# 침울함을 극복했습니다.", "-혼란" end,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("gloom_confused", 1))
		eff.power = math.floor(math.max(eff.power - (self:attr("confusion_immune") or 0) * 100, 10))
		eff.power = util.bound(eff.power, 0, 50)
		eff.tmpid = self:addTemporaryValue("confused", eff.power)
		if eff.power <= 0 then eff.dur = 0 end
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
		self:removeTemporaryValue("confused", eff.tmpid)
		if self == game.player then self:updateMainShader() end
	end,
}

newEffect{
	name = "DISMAYED", image = "talents/dismay.png",
	desc = "Dismayed",
	kr_name = "당황",
	long_desc = function(self, eff) return ("당황 : 대상이 받는 다음 근접 공격은 무조건 치명타 발생") end,
	type = "mental",
	subtype = { gloom=true, confusion=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#F53CBE##Target1# 당황에 빠졌습니다!", "+당황" end,
	on_lose = function(self, err) return "#Target1# 당황스러움을 극복했습니다.", "-당황" end,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("dismayed", 1))
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
	end,
}

newEffect{
	name = "STALKER", image = "talents/stalk.png",
	desc = "Stalking",
	kr_name = "추적자",
	display_desc = function(self, eff)
		return ([[%d 단계 추적중 (대상의 생명력 : %d / %d)]]):format(eff.bonus, eff.target.life, eff.target.max_life) --변수 순서 조정. 대상의 생명력이 맞는지 테스트 필요.
	end,
	long_desc = function(self, eff)
		local t = self:getTalentFromId(self.T_STALK)
		local effStalked = eff.target:hasEffect(eff.target.EFF_STALKED)
		local desc = ([[%s 추적중, %d 단계 추적 : 정확도 +%d / 물리 피해량 +%d%% / 추적 대상을 공격할 때마다 증오 회복 (+%0.2f / 턴)]]):format(
			(eff.target.kr_name or eff.target.name), eff.bonus, t.getAttackChange(self, t, eff.bonus), t.getStalkedDamageMultiplier(self, t, eff.bonus) * 100 - 100, t.getHitHateChange(self, t, eff.bonus))
		if effStalked and effStalked.damageChange and effStalked.damageChange > 0 then
			desc = desc..("추척 대상을 공격시 피해량 보정 : %d%%."):format(effStalked.damageChange)
		end
		return desc
	end,
	type = "mental",
	subtype = { veil=true },
	status = "beneficial",
	parameters = {},
	activate = function(self, eff)
		game.logSeen(self, "#F53CBE#%s %s의 추적을 받기 시작합니다!", (eff.target.kr_name or eff.target.name):capitalize():addJosa("가"), (self.kr_name or self.name))
	end,
	deactivate = function(self, eff)
		game.logSeen(self, "#F53CBE#%s 더이상 %s의 추적을 받지 않습니다.", (eff.target.kr_name or eff.target.name):capitalize():addJosa("는"), (self.kr_name or self.name))
	end,
	on_timeout = function(self, eff)
		if not eff.target or eff.target.dead or not eff.target:hasEffect(eff.target.EFF_STALKED) then
			self:removeEffect(self.EFF_STALKER)
		end
	end,
}

newEffect{
	name = "STALKED", image = "effects/stalked.png",
	desc = "Stalked",
	kr_name = "추적 대상",
	long_desc = function(self, eff)
		local effStalker = eff.source:hasEffect(eff.source.EFF_STALKER)
		if not effStalker then return "추적당함." end
		local t = self:getTalentFromId(eff.source.T_STALK)
		local desc = ([[%s에게 추적당하는 중, %d 단계 추적 : 추적자의 정확도 +%d / 추적자의 물리 피해량 +%d%% / 공격받을 때마다 추적자의 증오 회복 (+%0.2f / 턴)]]):format(
			(eff.source.kr_name or eff.source.name), effStalker.bonus, t.getAttackChange(eff.source, t, effStalker.bonus), t.getStalkedDamageMultiplier(eff.source, t, effStalker.bonus) * 100 - 100, t.getHitHateChange(eff.source, t, effStalker.bonus))
		if eff.damageChange and eff.damageChange > 0 then
			desc = desc..(" 추적자에게 받는 피해량 보정 : %d%%."):format(eff.damageChange)
		end
		return desc
	end,
	type = "mental",
	subtype = { veil=true },
	status = "detrimental",
	parameters = {},
	activate = function(self, eff)
		local effStalker = eff.source:hasEffect(eff.source.EFF_STALKER)
		eff.particleBonus = effStalker.bonus
		eff.particle = self:addParticles(Particles.new("stalked", 1, { bonus = eff.particleBonus }))
	end,
	deactivate = function(self, eff)
		if eff.particle then self:removeParticles(eff.particle) end
		if eff.damageChangeId then self:removeTemporaryValue("inc_damage", eff.damageChangeId) end
	end,
	on_timeout = function(self, eff)
		if not eff.source or eff.source.dead or not eff.source:hasEffect(eff.source.EFF_STALKER) then
			self:removeEffect(self.EFF_STALKED)
		else
			local effStalker = eff.source:hasEffect(eff.source.EFF_STALKER)
			if eff.particleBonus ~= effStalker.bonus then
				eff.particleBonus = effStalker.bonus
				self:removeParticles(eff.particle)
				eff.particle = self:addParticles(Particles.new("stalked", 1, { bonus = eff.particleBonus }))
			end
		end
	end,
	updateDamageChange = function(self, eff)
		if eff.damageChangeId then
			self:removeTemporaryValue("inc_damage", eff.damageChangeId)
			eff.damageChangeId = nil
		end
		if eff.damageChange and eff.damageChange > 0 then
			eff.damageChangeId = eff.target:addTemporaryValue("inc_damage", {all=eff.damageChange})
		end
	end,
}

newEffect{
	name = "BECKONED", image = "talents/beckon.png",
	desc = "Beckoned",
	kr_name = "목표 지정",
	long_desc = function(self, eff)
		local message = ("%s의 목표로 지정됨 : 매 턴마다 %d%% 확률로 사냥꾼 방향으로 끌려감"):format(eff.source.name, eff.chance)
		if eff.spellpowerChangeId and eff.mindpowerChangeId then
			message = message..(" / 주문력 : %d / 정신력 : %d"):format(eff.spellpowerChange, eff.mindpowerChange)
		end
		return message
	end,
	type = "mental",
	subtype = { dominate=true },
	status = "detrimental",
	parameters = { speedChange=0.5 },
	on_gain = function(self, err) return "#Target1# 목표로 지정되었습니다.", "+목표 지정" end,
	on_lose = function(self, err) return "#Target2# 더이상 목표가 아닙니다.", "-목표 지정" end,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("beckoned", 1))

		eff.spellpowerChangeId = self:addTemporaryValue("combat_spellpower", eff.spellpowerChange)
		eff.mindpowerChangeId = self:addTemporaryValue("combat_mindpower", eff.mindpowerChange)
	end,
	deactivate = function(self, eff)
		if eff.particle then self:removeParticles(eff.particle) end

		if eff.spellpowerChangeId then
			self:removeTemporaryValue("combat_spellpower", eff.spellpowerChangeId)
			eff.spellpowerChangeId = nil
		end
		if eff.mindpowerChangeId then
			self:removeTemporaryValue("combat_mindpower", eff.mindpowerChangeId)
			eff.mindpowerChangeId = nil
		end
	end,
	on_timeout = function(self, eff)
	end,
	do_act = function(self, eff)
		if eff.source.dead then
			self:removeEffect(self.EFF_BECKONED)
			return
		end
		if not self:enoughEnergy() then return nil end

		-- apply periodic timer instead of random chance
		if not eff.timer then
			eff.timer = rng.float(0, 100)
		end
		if not self:checkHit(eff.source:combatMindpower(), self:combatMentalResist(), 0, 95, 5) then
			eff.timer = eff.timer + eff.chance * 0.5
			game.logSeen(self, "#F53CBE#%s 목표 지정을 저항해냅니다.", (self.kr_name or self.name):capitalize():addJosa("가"))
		else
			eff.timer = eff.timer + eff.chance
		end

		if eff.timer > 100 then
			eff.timer = eff.timer - 100

			local distance = core.fov.distance(self.x, self.y, eff.source.x, eff.source.y)
			if math.floor(distance) > 1 and distance <= eff.range then
				-- in range but not adjacent

				-- add debuffs
				if not eff.spellpowerChangeId then eff.spellpowerChangeId = self:addTemporaryValue("combat_spellpower", eff.spellpowerChange) end
				if not eff.mindpowerChangeId then eff.mindpowerChangeId = self:addTemporaryValue("combat_mindpower", eff.mindpowerChange) end

				-- custom pull logic (adapted from move_dmap; forces movement, pushes others aside, custom particles)

				if not self:attr("never_move") then
					local source = eff.source
					local moveX, moveY = source.x, source.y -- move in general direction by default
					if not self:hasLOS(source.x, source.y) then
						local a = Astar.new(game.level.map, self)
						local path = a:calc(self.x, self.y, source.x, source.y)
						if path then
							moveX, moveY = path[1].x, path[1].y
						end
					end

					if moveX and moveY then
						local old_move_others, old_x, old_y = self.move_others, self.x, self.y
						self.move_others = true
						local old = rawget(self, "aiCanPass")
						self.aiCanPass = mod.class.NPC.aiCanPass
						mod.class.NPC.moveDirection(self, moveX, moveY, false)
						self.aiCanPass = old
						self.move_others = old_move_others
						if old_x ~= self.x or old_y ~= self.y then
							game.level.map:particleEmitter(self.x, self.y, 1, "beckoned_move", {power=power, dx=self.x - source.x, dy=self.y - source.y})
						end
					end
				end
			else
				-- adjacent or out of range..remove debuffs
				if eff.spellpowerChangeId then
					self:removeTemporaryValue("combat_spellpower", eff.spellpowerChangeId)
					eff.spellpowerChangeId = nil
				end
				if eff.mindpowerChangeId then
					self:removeTemporaryValue("combat_mindpower", eff.mindpowerChangeId)
					eff.mindpowerChangeId = nil
				end
			end
		end
	end,
	do_onTakeHit = function(self, eff, dam)
		eff.resistChance = (eff.resistChance or 0) + math.min(100, math.max(0, dam / self.max_life * 100))
		if rng.percent(eff.resistChance) then
			game.logSeen(self, "#F53CBE#%s 피해에 의한 충격으로 정신을 차렸습니다. 목표 지정이 해제됩니다.", (self.kr_name or self.name):capitalize():addJosa("가"))
			self:removeEffect(self.EFF_BECKONED)
		end

		return dam
	end,
}

newEffect{
	name = "OVERWHELMED", image = "talents/frenzy.png",
	desc = "Overwhelmed",
	kr_name = "압도됨",
	long_desc = function(self, eff) return ("압도됨 : 정확도 -%d"):format( -eff.attackChange) end,
	type = "mental",
	subtype = { fear=true },
	status = "detrimental",
	parameters = { damageChange=0.1 },
	on_gain = function(self, err) return "#Target1# 압도되었습니다.", "+압도됨" end,
	on_lose = function(self, err) return "#Target1# 압도된 상태에서 벗어났습니다.", "-압도됨" end,
	activate = function(self, eff)
		eff.attackChangeId = self:addTemporaryValue("combat_atk", eff.attackChange)
		eff.particle = self:addParticles(Particles.new("overwhelmed", 1))
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_atk", eff.attackChangeId)
		self:removeParticles(eff.particle)
	end,
}

newEffect{
	name = "HARASSED", image = "talents/harass_prey.png",
	desc = "Harassed",
	kr_name = "유린",
	long_desc = function(self, eff) return ("추적자에게 유린당함 : 공격시 피해량 -%d%%"):format( -eff.damageChange * 100) end,
	type = "mental",
	subtype = { fear=true },
	status = "detrimental",
	parameters = { damageChange=0.1 },
	on_gain = function(self, err) return "#Target1# 추적자에게 유린당합니다.", "+유린" end,
	on_lose = function(self, err) return "#Target1# 유린으로 인해 생겼던 불안감을 떨쳐냅니다.", "-유린" end,
	activate = function(self, eff)
		eff.damageChangeId = self:addTemporaryValue("inc_damage", {all=eff.damageChange})
		eff.particle = self:addParticles(Particles.new("harassed", 1))
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_damage", eff.damageChangeId)
		self:removeParticles(eff.particle)
	end,
}

newEffect{
	name = "DOMINATED", image = "talents/dominate.png",
	desc = "Dominated",
	kr_name = "지배됨",
	long_desc = function(self, eff) return ("지배됨 : 이동 불가능 / 방어도 -%d / 회피도 -%d / 지배자가 하는 공격은 저항을 %d%% 만큼 관통함"):format(-eff.armorChange, -eff.defenseChange, eff.resistPenetration) end,
	type = "mental",
	subtype = { dominate=true },
	status = "detrimental",
	on_gain = function(self, err) return "#F53CBE##Target1# 지배되었습니다!", "+지배됨" end,
	on_lose = function(self, err) return "#F53CBE##Target2# 지배에서 풀려났습니다.", "-지배됨" end,
	parameters = { armorChange = -3, defenseChange = -3, physicalResistChange = -0.1 },
	activate = function(self, eff)
		eff.neverMoveId = self:addTemporaryValue("never_move", 1)
		eff.armorId = self:addTemporaryValue("combat_armor", eff.armorChange)
		eff.defenseId = self:addTemporaryValue("combat_def", eff.armorChange)

		eff.particle = self:addParticles(Particles.new("dominated", 1))
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("never_move", eff.neverMoveId)
		self:removeTemporaryValue("combat_armor", eff.armorId)
		self:removeTemporaryValue("combat_def", eff.defenseId)

		self:removeParticles(eff.particle)
	end,
}

newEffect{
	name = "FEED", image = "talents/feed.png",
	desc = "Feeding",
	kr_name = "먹잇감 확보",
	long_desc = function(self, eff) return ("%s %s 먹이로 삼습니다."):format((self.kr_name or self.name):capitalize():addJosa("가"), (eff.target.kr_name or eff.target.name):addJosa("를")) end,
	type = "mental",
	subtype = { psychic_drain=true },
	status = "beneficial",
	parameters = { },
	activate = function(self, eff)
		eff.src = self

		-- hate
		if eff.hateGain and eff.hateGain > 0 then
			eff.hateGainId = self:addTemporaryValue("hate_regen", eff.hateGain)
		end

		-- health
		if eff.constitutionGain and eff.constitutionGain > 0 then
			eff.constitutionGainId = self:addTemporaryValue("inc_stats", { [Stats.STAT_CON] = eff.constitutionGain })
		end
		if eff.lifeRegenGain and eff.lifeRegenGain > 0 then
			eff.lifeRegenGainId = self:addTemporaryValue("life_regen", eff.lifeRegenGain)
		end

		-- power
		if eff.damageGain and eff.damageGain > 0 then
			eff.damageGainId = self:addTemporaryValue("inc_damage", {all=eff.damageGain})
		end

		-- strengths
		if eff.resistGain and eff.resistGain > 0 then
			local gainList = {}
			for id, resist in pairs(eff.target.resists) do
				if resist > 0 and id ~= "all" then
					gainList[id] = eff.resistGain * 0.01 * resist
				end
			end

			eff.resistGainId = self:addTemporaryValue("resists", gainList)
		end

		eff.target:setEffect(eff.target.EFF_FED_UPON, eff.dur, { src = eff.src, target = eff.target, constitutionLoss = -eff.constitutionGain, lifeRegenLoss = -eff.lifeRegenGain, damageLoss = -eff.damageGain, resistLoss = -eff.resistGain })
	end,
	deactivate = function(self, eff)
		-- hate
		if eff.hateGainId then self:removeTemporaryValue("hate_regen", eff.hateGainId) end

		-- health
		if eff.constitutionGainId then self:removeTemporaryValue("inc_stats", eff.constitutionGainId) end
		if eff.lifeRegenGainId then self:removeTemporaryValue("life_regen", eff.lifeRegenGainId) end

		-- power
		if eff.damageGainId then self:removeTemporaryValue("inc_damage", eff.damageGainId) end

		-- strengths
		if eff.resistGainId then self:removeTemporaryValue("resists", eff.resistGainId) end

		if eff.particles then
			-- remove old particle emitter
			game.level.map:removeParticleEmitter(eff.particles)
			eff.particles = nil
		end

		eff.target:removeEffect(eff.target.EFF_FED_UPON, false, true)
	end,
	updateFeed = function(self, eff)
		local source = eff.src
		local target = eff.target

		if source.dead or target.dead or not game.level:hasEntity(source) or not game.level:hasEntity(target) or not source:hasLOS(target.x, target.y) or core.fov.distance(self.x, self.y, target.x, target.y) > (eff.range or 10) then
			source:removeEffect(source.EFF_FEED)
			if eff.particles then
				game.level.map:removeParticleEmitter(eff.particles)
				eff.particles = nil
			end
			return
		end

		-- update particles position
		if not eff.particles or eff.particles.x ~= source.x or eff.particles.y ~= source.y or eff.particles.tx ~= target.x or eff.particles.ty ~= target.y then
			if eff.particles then
				game.level.map:removeParticleEmitter(eff.particles)
			end
			-- add updated particle emitter
			local dx, dy = target.x - source.x, target.y - source.y
			eff.particles = Particles.new("feed_hate", math.max(math.abs(dx), math.abs(dy)), { tx=dx, ty=dy })
			eff.particles.x = source.x
			eff.particles.y = source.y
			eff.particles.tx = target.x
			eff.particles.ty = target.y
			game.level.map:addParticleEmitter(eff.particles)
		end
	end
}

newEffect{
	name = "FED_UPON", image = "effects/fed_upon.png",
	desc = "Fed Upon",
	kr_name = "먹잇감",
	long_desc = function(self, eff) return ("%s %s의 먹잇감이 됩니다."):format((self.kr_name or self.name):capitalize():addJosa("는"), (eff.src.kr_name or eff.src.name)) end,
	type = "mental",
	subtype = { psychic_drain=true },
	status = "detrimental",
	remove_on_clone = true,
	no_remove = true,
	parameters = { },
	activate = function(self, eff)
		-- health
		if eff.constitutionLoss and eff.constitutionLoss < 0 then
			eff.constitutionLossId = self:addTemporaryValue("inc_stats", { [Stats.STAT_CON] = eff.constitutionLoss })
		end
		if eff.lifeRegenLoss and eff.lifeRegenLoss < 0 then
			eff.lifeRegenLossId = self:addTemporaryValue("life_regen", eff.lifeRegenLoss)
		end

		-- power
		if eff.damageLoss and eff.damageLoss < 0 then
			eff.damageLossId = self:addTemporaryValue("inc_damage", {all=eff.damageLoss})
		end

		-- strengths
		if eff.resistLoss and eff.resistLoss < 0 then
			local lossList = {}
			for id, resist in pairs(self.resists) do
				if resist > 0 and id ~= "all" then
					lossList[id] = eff.resistLoss * 0.01 * resist
				end
			end

			eff.resistLossId = self:addTemporaryValue("resists", lossList)
		end
	end,
	deactivate = function(self, eff)
		-- health
		if eff.constitutionLossId then self:removeTemporaryValue("inc_stats", eff.constitutionLossId) end
		if eff.lifeRegenLossId then self:removeTemporaryValue("life_regen", eff.lifeRegenLossId) end

		-- power
		if eff.damageLossId then self:removeTemporaryValue("inc_damage", eff.damageLossId) end

		-- strengths
		if eff.resistLossId then self:removeTemporaryValue("resists", eff.resistLossId) end
		
		if eff.target == self and eff.src:hasEffect(eff.src.EFF_FEED) then
			eff.src:removeEffect(eff.src.EFF_FEED)
		end
	end,
	on_timeout = function(self, eff)
		-- no_remove prevents targets from dispelling feeding, make sure this gets removed if something goes wrong
		if eff.dur <= 0 or eff.src.dead then
			self:removeEffect(eff.src.EFF_FED_UPON, false, true)
		end
	end,
}

newEffect{
	name = "AGONY", image = "talents/agony.png",
	desc = "Agony",
	kr_name = "고통",
	long_desc = function(self, eff) return ("%s 고통받음 : 매 턴마다 %d 에서 %d 사이의 피해"):format((self.kr_name or self.name):capitalize():addJosa("가"), eff.damage / eff.duration, eff.damage, eff.duration) end,
	type = "mental",
	subtype = { pain=true, psionic=true },
	status = "detrimental",
	parameters = { damage=10, mindpower=10, range=10, minPercent=10 },
	on_gain = function(self, err) return "#Target1# 고통으로 몸부림칩니다!", "+고통" end,
	on_lose = function(self, err) return "#Target1# 고통에서 벗어났습니다.", "-고통" end,
	activate = function(self, eff)
		eff.power = 0
	end,
	deactivate = function(self, eff)
		if eff.particle then self:removeParticles(eff.particle) end
	end,
	on_timeout = function(self, eff)
		eff.turn = (eff.turn or 0) + 1

		local damage = math.floor(eff.damage * (eff.turn / eff.duration))
		if damage > 0 then
			DamageType:get(DamageType.MIND).projector(eff.source, self.x, self.y, DamageType.MIND, { dam=damage, crossTierChance=25 })
			game:playSoundNear(self, "talents/fire")
		end

		if self.dead then
			if eff.particle then self:removeParticles(eff.particle) end
			return
		end

		if eff.particle then self:removeParticles(eff.particle) end
		eff.particle = nil
		eff.particle = self:addParticles(Particles.new("agony", 1, { power = 10 * eff.turn / eff.duration }))
	end,
}

newEffect{
	name = "HATEFUL_WHISPER", image = "talents/hateful_whisper.png",
	desc = "Hateful Whisper",
	kr_name = "증오의 속삭임",
	long_desc = function(self, eff) return ("%s 증오의 속삭임을 들었습니다."):format((self.kr_name or self.name):capitalize():addJosa("는")) end,
	type = "mental",
	subtype = { madness=true, psionic=true },
	status = "detrimental",
	parameters = { },
	on_gain = function(self, err) return "#Target2# 증오의 속삭임을 들었습니다!", "+증오의 속삭임" end,
	on_lose = function(self, err) return "#Target2# 더이상 증오의 속삭임이 들리지 않습니다.", "-증오의 속삭임" end,
	activate = function(self, eff)
		if not eff.source.dead and eff.source:knowTalent(eff.source.T_HATE_POOL) then
			eff.source:incHate(eff.hateGain)
		end
		DamageType:get(DamageType.MIND).projector(eff.source, self.x, self.y, DamageType.MIND, { dam=eff.damage, crossTierChance=25 })

		if self.dead then
			-- only spread on activate if the target is dead
			if eff.jumpCount > 0 then
				eff.jumpCount = eff.jumpCount - 1
				self.tempeffect_def[self.EFF_HATEFUL_WHISPER].doSpread(self, eff)
			end
		else
			eff.particle = self:addParticles(Particles.new("hateful_whisper", 1, { }))
		end

		game:playSoundNear(self, "talents/fire")

		eff.firstTurn = true
	end,
	deactivate = function(self, eff)
		if eff.particle then self:removeParticles(eff.particle) end
	end,
	on_timeout = function(self, eff)
		if self.dead then return false end

		if eff.firstTurn then
			-- pause a turn before infecting others
			eff.firstTurn = false
		elseif eff.jumpDuration > 0 then
			-- limit the total duration of all spawned effects
			eff.jumpDuration = eff.jumpDuration - 1

			if eff.jumpCount > 0 then
				-- guaranteed jump
				eff.jumpCount = eff.jumpCount - 1
				self.tempeffect_def[self.EFF_HATEFUL_WHISPER].doSpread(self, eff)
			elseif rng.percent(eff.jumpChance) then
				-- per turn chance of a jump
				self.tempeffect_def[self.EFF_HATEFUL_WHISPER].doSpread(self, eff)
			end
		end
	end,
	doSpread = function(self, eff)
		local targets = {}
		local grids = core.fov.circle_grids(self.x, self.y, eff.jumpRange, true)
		for x, yy in pairs(grids) do
			for y, _ in pairs(grids[x]) do
				local a = game.level.map(x, y, game.level.map.ACTOR)
				if a and eff.source:reactionToward(a) < 0 and self:hasLOS(a.x, a.y) then
					if not a:hasEffect(a.EFF_HATEFUL_WHISPER) then
						targets[#targets+1] = a
					end
				end
			end
		end

		if #targets > 0 then
			local target = rng.table(targets)
			target:setEffect(target.EFF_HATEFUL_WHISPER, eff.duration, {
				source = eff.source,
				duration = eff.duration,
				damage = eff.damage,
				mindpower = eff.mindpower,
				jumpRange = eff.jumpRange,
				jumpCount = 0, -- secondary effects do not get automatic spreads
				jumpChance = eff.jumpChance,
				jumpDuration = eff.jumpDuration,
				hateGain = eff.hateGain
			})

			game.level.map:particleEmitter(target.x, target.y, 1, "reproach", { dx = self.x - target.x, dy = self.y - target.y })
		end
	end,
}

newEffect{
	name = "MADNESS_SLOW", image = "effects/madness_slowed.png",
	desc = "Slowed by madness",
	kr_name = "감속의 광기",
	long_desc = function(self, eff) return ("광기로 인한 감속 : 모든 행동 속도 -%d%% / 정신 저항 -%d%%"):format(eff.power * 100, -eff.mindResistChange) end,
	type = "mental",
	subtype = { madness=true, slow=true },
	status = "detrimental",
	parameters = { power=0.1 },
	on_gain = function(self, err) return "#F53CBE##Target1# 광기에 빠져 느려집니다!", "+감속" end,
	on_lose = function(self, err) return "#Target1# 광기를 극복했습니다.", "-감속" end,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("gloom_slow", 1))
		eff.mindResistChangeId = self:addTemporaryValue("resists", { [DamageType.MIND]=eff.mindResistChange })
		eff.tmpid = self:addTemporaryValue("global_speed_add", -eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("resists", eff.mindResistChangeId)
		self:removeTemporaryValue("global_speed_add", eff.tmpid)
		self:removeParticles(eff.particle)
	end,
}

newEffect{
	name = "MADNESS_STUNNED", image = "effects/madness_stunned.png",
	desc = "Stunned by madness",
	kr_name = "기절의 광기",
	long_desc = function(self, eff) return ("광기로 인한 기절 : 공격시 피해량 -70%% / 정신 저항 -%d%% / 이동 속도 -50%% / 50%% 확률로 임의의 기술이 대기상태로 변경 / 재사용 대기시간이 줄어들지 않음"):format(eff.mindResistChange) end,
	type = "mental",
	subtype = { madness=true, stun=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#F53CBE##Target1# 광기에 의해 기절했습니다!", "+기절" end,
	on_lose = function(self, err) return "#Target1# 광기를 극복했습니다.", "-기절" end,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("gloom_stunned", 1))

		eff.mindResistChangeId = self:addTemporaryValue("resists", { [DamageType.MIND]=eff.mindResistChange })
		eff.tmpid = self:addTemporaryValue("stunned", 1)
		eff.tcdid = self:addTemporaryValue("no_talents_cooldown", 1)
		eff.speedid = self:addTemporaryValue("movement_speed", -0.5)

		local tids = {}
		for tid, lev in pairs(self.talents) do
			local t = self:getTalentFromId(tid)
			if t and not self.talents_cd[tid] and t.mode == "activated" and not t.innate then tids[#tids+1] = t end
		end
		for i = 1, 4 do
			local t = rng.tableRemove(tids)
			if not t then break end
			self.talents_cd[t.id] = 1 -- Just set cooldown to 1 since cooldown does not decrease while stunned
		end
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)

		self:removeTemporaryValue("resists", eff.mindResistChangeId)
		self:removeTemporaryValue("stunned", eff.tmpid)
		self:removeTemporaryValue("no_talents_cooldown", eff.tcdid)
		self:removeTemporaryValue("movement_speed", eff.speedid)
	end,
}

newEffect{
	name = "MADNESS_CONFUSED", image = "effects/madness_confused.png",
	desc = "Confused by madness",
	kr_name = "혼란의 광기",
	long_desc = function(self, eff) return ("광기로 인한 혼란 : 정신 저항 -%d%% / %d%% 의 확률로 멋대로 행동 / 복잡한 행동 불가능"):format(eff.mindResistChange, eff.power) end,
	type = "mental",
	subtype = { madness=true, confusion=true },
	status = "detrimental",
	parameters = { power=10 },
	on_gain = function(self, err) return "#F53CBE##Target1# 광기에 빠집니다!", "+혼란" end,
	on_lose = function(self, err) return "#Target1# 광기를 극복했습니다.", "-혼란" end,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("gloom_confused", 1))
		eff.mindResistChangeId = self:addTemporaryValue("resists", { [DamageType.MIND]=eff.mindResistChange })
		eff.power = math.floor(math.max(eff.power - (self:attr("confusion_immune") or 0) * 100, 10))
		eff.power = util.bound(eff.power, 0, 50)
		eff.tmpid = self:addTemporaryValue("confused", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("resists", eff.mindResistChangeId)
		self:removeParticles(eff.particle)
		self:removeTemporaryValue("confused", eff.tmpid)
		if self == game.player and self.updateMainShader then self:updateMainShader() end
	end,
}

newEffect{
	name = "MALIGNED", image = "talents/getsture_of_malice.png",
	desc = "Maligned",
	kr_name = "악성 작용",
	long_desc = function(self, eff) return ("악성 작용 : 전체 저항 -%d%%"):format(-eff.resistAllChange) end,
	type = "mental",
	subtype = { curse=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#F53CBE##Target1# 악의의 손짓에 의해, 악성 작용의 영향을 받습니다!", "+악성 작용" end,
	on_lose = function(self, err) return "#Target2# 더이상 악성 작용의 영향을 받지 않습니다", "-악성 작용" end,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("maligned", 1))
		eff.resistAllChangeId = self:addTemporaryValue("resists", { all=eff.resistAllChange })
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("resists", eff.resistAllChangeId)
		self:removeParticles(eff.particle)
	end,
	on_merge = function(self, old_eff, new_eff)
		old_eff.dur = new_eff.dur
		return old_eff
	end,
}

local function updateFearParticles(self)
	local hasParticles = false
	if self:hasEffect(self.EFF_PARANOID) then hasParticles = true end
	if self:hasEffect(self.EFF_DISPAIR) then hasParticles = true end
	if self:hasEffect(self.EFF_TERRIFIED) then hasParticles = true end
	if self:hasEffect(self.EFF_DISTRESSED) then hasParticles = true end
	if self:hasEffect(self.EFF_HAUNTED) then hasParticles = true end
	if self:hasEffect(self.EFF_TORMENTED) then hasParticles = true end

	if not self.fearParticlesId and hasParticles then
		self.fearParticlesId = self:addParticles(Particles.new("fear_blue", 1))
	elseif self.fearParticlesId and not hasParticles then
		self:removeParticles(self.fearParticlesId)
		self.fearParticlesId = nil
	end
end

newEffect{
	name = "PARANOID", image = "effects/paranoid.png",
	desc = "Paranoid",
	kr_name = "피해망상",
	long_desc = function(self, eff) return ("피해망상 : %d%% 확률로 피아를 무시하고 인접한 아무나 공격 - 이 공격에 맞을 경우, 맞은 대상도 피해망상에 걸릴 수 있음"):format(eff.attackChance) end,
	type = "mental",
	subtype = { fear=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#F53CBE##Target1# 피해망상에 빠졌습니다!", "+피해망상" end,
	on_lose = function(self, err) return "#Target1# 피해망상에서 빠져나왔습니다.", "-피해망상" end,
	activate = function(self, eff)
		updateFearParticles(self)
	end,
	deactivate = function(self, eff)
		updateFearParticles(self)

		local tInstillFear = self:getTalentFromId(self.T_INSTILL_FEAR)
		tInstillFear.endEffect(self, tInstillFear)
	end,
	do_act = function(self, eff)
		if not self:enoughEnergy() then return nil end

		-- apply periodic timer instead of random chance
		if not eff.timer then
			eff.timer = rng.float(0, 100)
		end
		if not self:checkHit(eff.source:combatMindpower(), self:combatMentalResist(), 0, 95, 5) then
			eff.timer = eff.timer + eff.attackChance * 0.5
			game.logSeen(self, "#F53CBE#%s 피해망상에 대응하여 버텨냅니다.", (self.kr_name or self.name):capitalize():addJosa("가"))
		else
			eff.timer = eff.timer + eff.attackChance
		end
		if eff.timer > 100 then
			eff.timer = eff.timer - 100

			local start = rng.range(0, 8)
			for i = start, start + 8 do
				local x = self.x + (i % 3) - 1
				local y = self.y + math.floor((i % 9) / 3) - 1
				if (self.x ~= x or self.y ~= y) then
					local target = game.level.map(x, y, Map.ACTOR)
					if target then
						game.logSeen(self, "#F53CBE#%s %s 공격하여, 피해망상에 빠뜨립니다.", (self.kr_name or self.name):capitalize():addJosa("가"), (target.kr_name or target.name):addJosa("를"))
						if self:attackTarget(target, nil, 1, false) and target ~= eff.source then
							if not target:canBe("fear") then
								game.logSeen(target, "#F53CBE#%s 공포를 무시했습니다!", (target.kr_name or target.name):capitalize():addJosa("가"))
							elseif not target:checkHit(eff.mindpower, target:combatMentalResist()) then
								game:logSeen(target, "%s 공포를 저항했습니다!", (target.kr_name or target.name):capitalize():addJosa("가"))
							else
								target:setEffect(target.EFF_PARANOID, eff.duration, { source=eff.source, attackChance=eff.attackChance, mindpower=eff.mindpower, duration=eff.duration })
							end
						end
						return
					end
				end
			end
		end
	end,
}

newEffect{
	name = "DISPAIR", image = "effects/despair.png",
	desc = "Despair",
	kr_name = "절망",
	long_desc = function(self, eff) return ("절망 : 전체 저항 %-d%% 감소"):format(-eff.resistAllChange) end,
	type = "mental",
	subtype = { fear=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#F53CBE##Target1# 절망에 빠졌습니다!", "+절망" end,
	on_lose = function(self, err) return "#Target1# 절망에서 벗어났습니다.", "-절망" end,
	activate = function(self, eff)
		eff.damageId = self:addTemporaryValue("resists", { all=eff.resistAllChange })
		updateFearParticles(self)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("resists", eff.damageId)
		updateFearParticles(self)

		local tInstillFear = self:getTalentFromId(self.T_INSTILL_FEAR)
		tInstillFear.endEffect(self, tInstillFear)
	end,
}

newEffect{
	name = "TERRIFIED", image = "effects/terrified.png",
	desc = "Terrified",
	kr_name = "두려움",
	long_desc = function(self, eff) return ("두려움 : 공격이나 기술 사용시 %d%% 확률로 실패"):format(eff.actionFailureChance) end,
	type = "mental",
	subtype = { fear=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#F53CBE##Target1# 두려움에 빠졌습니다!", "+두려움" end,
	on_lose = function(self, err) return "#Target1# 두려움에서 벗어났습니다.", "-두려움" end,
	activate = function(self, eff)
		eff.terrifiedId = self:addTemporaryValue("terrified", eff.actionFailureChance)
		updateFearParticles(self)
	end,
	deactivate = function(self, eff)
		eff.terrifiedId = self:removeTemporaryValue("terrified", eff.terrifiedId)
		updateFearParticles(self)

		local tInstillFear = self:getTalentFromId(self.T_INSTILL_FEAR)
		tInstillFear.endEffect(self, tInstillFear)
	end,
}

newEffect{
	name = "DISTRESSED", image = "effects/distressed.png",
	desc = "Distressed",
	kr_name = "괴로움",
	long_desc = function(self, eff) return ("괴로움 : 모든 내성 -%d"):format(-eff.saveChange) end,
	type = "mental",
	subtype = { fear=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#F53CBE##Target1# 괴로움에 빠졌습니다!", "+괴로움" end,
	on_lose = function(self, err) return "#Target1# 괴로움에서 벗어났습니다.", "-괴로움" end,
	activate = function(self, eff)
		eff.physicalId = self:addTemporaryValue("combat_physresist", eff.saveChange)
		eff.mentalId = self:addTemporaryValue("combat_mentalresist", eff.saveChange)
		eff.spellId = self:addTemporaryValue("combat_spellresist", eff.saveChange)
		updateFearParticles(self)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_physresist", eff.physicalId)
		self:removeTemporaryValue("combat_mentalresist", eff.mentalId)
		self:removeTemporaryValue("combat_spellresist", eff.spellId)
		updateFearParticles(self)

		local tInstillFear = self:getTalentFromId(self.T_INSTILL_FEAR)
		tInstillFear.endEffect(self, tInstillFear)
	end,
}

newEffect{
	name = "HAUNTED", image = "effects/haunted.png",
	desc = "Haunted",
	kr_name = "불안",
	long_desc = function(self, eff) return ("불안 : 다른 공포 효과에 추가적인 정신 피해 %d 발생"):format(eff.damage) end,
	type = "mental",
	subtype = { fear=true },
	status = "detrimental",
	parameters = {damage=10},
	on_gain = function(self, err) return "#F53CBE##Target1# 불안에 빠졌습니다!", "+불안" end,
	on_lose = function(self, err) return "#Target1# 불안에서 벗어났습니다.", "-불안" end,
	activate = function(self, eff)
		for e, p in pairs(self.tmp) do
			def = self.tempeffect_def[e]
			if def.subtype and def.subtype.fear then
				if not self.dead then
					game.logSeen(self, "#F53CBE#%s 공포 효과 '%s'에 의해 피해를 받습니다.", (self.kr_name or self.name):capitalize():addJosa("가"), (def.kr_name or def.desc))
					eff.source:project({type="hit", x=self.x,y=self.y}, self.x, self.y, DamageType.MIND, { dam=eff.damage,alwaysHit=true,criticals=false,crossTierChance=0 })
				end
			end
		end
		updateFearParticles(self)
	end,
	deactivate = function(self, eff)
		updateFearParticles(self)

		local tInstillFear = self:getTalentFromId(self.T_INSTILL_FEAR)
		tInstillFear.endEffect(self, tInstillFear)
	end,
	on_setFearEffect = function(self, e)
		local eff = self:hasEffect(self.EFF_HAUNTED)
		game.logSeen(self, "#F53CBE#%s 공포 효과 '%s'에 의해 피해를 받습니다.", (self.kr_name or self.name):capitalize():addJosa("는"), (util.getval(e.kr_name, self, e) or util.getval(e.desc, self, e)) ) --@@ 마지막 파라매터(공포 효과 이름) 에러 안 나는지 검사 필요
		eff.source:project({type="hit", x=self.x,y=self.y}, self.x, self.y, DamageType.MIND, { dam=eff.damage,alwaysHit=true,criticals=false,crossTierChance=0 })
	end,
}

newEffect{
	name = "TORMENTED", image = "effects/tormented.png",
	desc = "Tormented",
	kr_name = "격통",
	long_desc = function(self, eff) return ("격통 : %d 마리 환영이 나타남\n환영 : 사라지기 전까지 대상에게 정신 속성 공격 (%d 피해)"):format(eff.count, eff.damage) end,
	type = "mental",
	subtype = { fear=true },
	status = "detrimental",
	parameters = {count=1, damage=10},
	on_gain = function(self, err) return "#F53CBE##Target1# 격통에 빠졌습니다!", "+격통" end,
	on_lose = function(self, err) return "#Target1# 격통에서 벗어났습니다.", "-격통" end,
	activate = function(self, eff)
		updateFearParticles(self)
	end,
	deactivate = function(self, eff)
		updateFearParticles(self)

		local tInstillFear = self:getTalentFromId(self.T_INSTILL_FEAR)
		tInstillFear.endEffect(self, tInstillFear)
	end,
	npcTormentor = {
		name = "tormentor",
		kr_name = "격통을 주는 자",
		display = "h", color=colors.DARK_GREY, image="npc/horror_eldritch_nightmare_horror.png",
		blood_color = colors.BLACK,
		desc = "정신을 파괴하는 두려운 환영입니다.",
		type = "horror", subtype = "eldritch",
		rank = 2,
		size_category = 2,
		body = { INVEN = 10 },
		no_drops = true,
		autolevel = "summoner",
		level_range = {1, nil}, exp_worth = 0,
		ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=2, ai_move="move_ghoul", },
		stats = { str=10, dex=20, wil=20, con=10, cun=30 },
		infravision = 10,
		can_pass = {pass_wall=20},
		resists = { all = 100, [DamageType.MIND]=-100 },
		no_breath = 1,
		fear_immune = 1,
		blind_immune = 1,
		infravision = 10,
		see_invisible = 80,
		max_life = resolvers.rngavg(50, 80),
		combat_armor = 1, combat_def = 50,
		combat = { dam=1 },
		resolvers.talents{
		},
		on_act = function(self)
			local target = self.ai_target.actor
			if not target or target.dead then
				self:die()
			else
				game.logSeen(self, "%s 환영으로 인해 격통에 빠졌습니다!", (target.kr_name or target.name):capitalize():addJosa("가"))
				self:project({type="hit", x=target.x,y=target.y}, target.x, target.y, engine.DamageType.MIND, { dam=self.tormentedDamage,alwaysHit=true,crossTierChance=75 })
				self:die()
			end
		end,
	},
	on_timeout = function(self, eff)
		if eff.source.dead then return true end

		-- tormentors per turn are pre-calculated in a table, but ordered, so take a random one
		local count = rng.tableRemove(eff.counts)
		for c = 1, count do
			local start = rng.range(0, 8)
			for i = start, start + 8 do
				local x = self.x + (i % 3) - 1
				local y = self.y + math.floor((i % 9) / 3) - 1
				if game.level.map:isBound(x, y) and not game.level.map(x, y, Map.ACTOR) then
					local def = self.tempeffect_def[self.EFF_TORMENTED]
					local m = require("mod.class.NPC").new(def.npcTormentor)
					m.faction = eff.source.faction
					m.summoner = eff.source
					m.summoner_gain_exp = true
					m.summon_time = 3
					m.tormentedDamage = eff.damage
					m:resolve() m:resolve(nil, true)
					m:forceLevelup(self.level)
					m:setTarget(self)

					game.zone:addEntity(game.level, m, "actor", x, y)

					break
				end
			end
		end
	end,
}

newEffect{
	name = "PANICKED", image = "talents/panic.png",
	desc = "Panicked",
	kr_name = "공황",
	long_desc = function(self, eff) return ("%s 인한 공황 : %d%% 확률로 다른 행동을 하지 못하고 무조건 도망침"):format((eff.source.kr_name or eff.source.name):addJosa("로"), eff.chance) end,
	type = "mental",
	subtype = { fear=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#F53CBE##Target1# 공황에 빠졌습니다!", "+공황" end,
	on_lose = function(self, err) return "#Target1# 공황에서 벗어났습니다.", "-공황" end,
	activate = function(self, eff)
		eff.particlesId = self:addParticles(Particles.new("fear_violet", 1))
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particlesId)

		local tInstillFear = self:getTalentFromId(self.T_INSTILL_FEAR)
		tInstillFear.endEffect(self, tInstillFear)
	end,
	do_act = function(self, eff)
		if not self:enoughEnergy() then return nil end
		if eff.source.dead then return true end

		-- apply periodic timer instead of random chance
		if not eff.timer then
			eff.timer = rng.float(0, 100)
		end
		if not self:checkHit(eff.source:combatMindpower(), self:combatMentalResist(), 0, 95, 5) then
			eff.timer = eff.timer + eff.chance * 0.5
			game.logSeen(self, "#F53CBE#%s 공황에 대응하여 버텨냅니다.", (self.kr_name or self.name):capitalize())
		else
			eff.timer = eff.timer + eff.chance
		end
		if eff.timer > 100 then
			eff.timer = eff.timer - 100

			local distance = core.fov.distance(self.x, self.y, eff.source.x, eff.source.y)
			if distance <= eff.range then
				-- in range
				if not self:attr("never_move") then
					local sourceX, sourceY = eff.source.x, eff.source.y

					local bestX, bestY
					local bestDistance = 0
					local start = rng.range(0, 8)
					for i = start, start + 8 do
						local x = self.x + (i % 3) - 1
						local y = self.y + math.floor((i % 9) / 3) - 1

						if x ~= self.x or y ~= self.y then
							local distance = core.fov.distance(x, y, sourceX, sourceY)
							if distance > bestDistance
									and game.level.map:isBound(x, y)
									and not game.level.map:checkAllEntities(x, y, "block_move", self)
									and not game.level.map(x, y, Map.ACTOR) then
								bestDistance = distance
								bestX = x
								bestY = y
							end
						end
					end

					if bestX then
						self:move(bestX, bestY, false)
						game.logPlayer(self, "#F53CBE#공황에 빠져, %s에게서 도망칩니다.", (eff.source.kr_name or eff.source.name))
					else
						game.logSeen(self, "#F53CBE#%s 공황에 빠져, %s에게서 도망치려 노력합니다.", (self.kr_name or self.name):capitalize():addJosa("가"), (eff.source.kr_name or eff.source.name))
						self:useEnergy(game.energy_to_act * self:combatMovementSpeed(bestX, bestY))
					end
				end
			end
		end
	end,
}

newEffect{
	name = "QUICKNESS", image = "effects/quickness.png",
	desc = "Quick",
	kr_name = "신속", --@@ '가속'은 magical.lua의 Haste에 사용, '빠름'은 physical.lua의 Speed에 사용.
	long_desc = function(self, eff) return ("달리기 속도 +%d%%"):format(eff.power * 100) end,
	type = "mental",
	subtype = { telekinesis=true, speed=true },
	status = "beneficial",
	parameters = { power=0.1 },
	on_gain = function(self, err) return "#Target1# 빨라졌습니다.", "+신속" end,
	on_lose = function(self, err) return "#Target1# 느려졌습니다.", "-신속" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("movement_speed", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("movement_speed", eff.tmpid)
	end,
}
newEffect{
	name = "PSIFRENZY", image = "talents/frenzied_psifighting.png",
	desc = "Frenzied Psi-fighting",
	kr_name = "광란의 염동력 전투",
	long_desc = function(self, eff) return ("염동력으로 들고 있는 무기가 매 턴마다 %d 명의 적을 동시에 공격"):format(eff.power) end,
	type = "mental",
	subtype = { telekinesis=true, frenzy=true },
	status = "beneficial",
	parameters = {dam=10},
	on_gain = function(self, err) return "#Target1# 난도질을 시작합니다!", "+난도질" end, --@@ '광란'은 rampage가 사용중, frenzy는 '난도질'
	on_lose = function(self, err) return "#Target#의 난도질이 끝났습니다.", "-난도질" end,
}

newEffect{
	name = "KINSPIKE_SHIELD", image = "talents/kinetic_shield.png",
	desc = "Spiked Kinetic Shield",
	kr_name = "동역학적 보호막의 파편",
	long_desc = function(self, eff) return ("동역학적 보호막의 파편 : 물리 속성과 산성 속성 피해 %d 흡수 (흡수 한계량 : %d)"):format(self.kinspike_shield_absorb, eff.power) end,
	type = "mental",
	subtype = { telekinesis=true, shield=true },
	status = "beneficial",
	parameters = { power=100 },
	on_gain = function(self, err) return "#Target# 주변을 동역학적 보호막의 파편이 둘러쌉니다.", "+보호막" end,
	on_lose = function(self, err) return "#Target3# 둘러싸던 동역학적 보호막의 파편이 부서졌습니다.", "-보호막" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("kinspike_shield", eff.power)
		self.kinspike_shield_absorb = eff.power

		if core.shader.active(4) then
			eff.particle = self:addParticles(Particles.new("shader_shield", 1, {size_factor=1.1}, {type="shield", time_factor=-8000, llpow=1, aadjust=7, color={1, 0, 0.3}}))
		else
			eff.particle = self:addParticles(Particles.new("generic_shield", 1, {r=1, g=0, b=0.3, a=1}))
		end
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
		self:removeTemporaryValue("kinspike_shield", eff.tmpid)
		self.kinspike_shield_absorb = nil
	end,
}
newEffect{
	name = "THERMSPIKE_SHIELD", image = "talents/thermal_shield.png",
	desc = "Spiked Thermal Shield",
	kr_name = "열역학적 보호막의 파편",
	long_desc = function(self, eff) return ("열역학적 보호막의 파편 : 화염 속성과 냉기 속성 피해 %d 흡수 (흡수 한계량 : %d)"):format(self.thermspike_shield_absorb, eff.power) end,
	type = "mental",
	subtype = { telekinesis=true, shield=true },
	status = "beneficial",
	parameters = { power=100 },
	on_gain = function(self, err) return "#Target# 주변을 열역학적 보호막의 파편이 둘러쌉니다.", "+보호막" end,
	on_lose = function(self, err) return "#Target3# 둘러싸던 열역학적 보호막의 파편이 부서졌습니다.", "-보호막" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("thermspike_shield", eff.power)
		self.thermspike_shield_absorb = eff.power

		if core.shader.active(4) then
			eff.particle = self:addParticles(Particles.new("shader_shield", 1, {size_factor=1.1}, {type="shield", time_factor=-8000, llpow=1, aadjust=7, color={0.3, 1, 1}}))
		else
			eff.particle = self:addParticles(Particles.new("generic_shield", 1, {r=0.3, g=1, b=1, a=1}))
		end
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
		self:removeTemporaryValue("thermspike_shield", eff.tmpid)
		self.thermspike_shield_absorb = nil
	end,
}
newEffect{
	name = "CHARGESPIKE_SHIELD", image = "talents/charged_shield.png",
	desc = "Spiked Charged Shield",
	kr_name = "전하적 보호막의 파편",
	long_desc = function(self, eff) return ("전하적 보호막의 파편 : 전기 속성과 황폐 속성 피해 %d 흡수 (흡수 한계량 : %d)"):format(self.chargespike_shield_absorb, eff.power) end,
	type = "mental",
	subtype = { telekinesis=true, shield=true },
	status = "beneficial",
	parameters = { power=100 },
	on_gain = function(self, err) return "#Target# 주변을 전하적 보호막의 파편이 둘러쌉니다.", "+보호막" end,
	on_lose = function(self, err) return "#Target3# 둘러싸던 전하적 보호막의 파편이 부서졌습니다.", "-보호막" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("chargespike_shield", eff.power)
		self.chargespike_shield_absorb = eff.power

		if core.shader.active(4) then
			eff.particle = self:addParticles(Particles.new("shader_shield", 1, {size_factor=1.1}, {type="shield", time_factor=-8000, llpow=1, aadjust=7, color={0.8, 1, 0.2}}))
		else
			eff.particle = self:addParticles(Particles.new("generic_shield", 1, {r=0.8, g=1, b=0.2, a=1}))
		end
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
		self:removeTemporaryValue("chargespike_shield", eff.tmpid)
		self.chargespike_shield_absorb = nil
	end,
}

newEffect{
	name = "CONTROL", image = "talents/perfect_control.png",
	desc = "Perfect control",
	kr_name = "완벽한 제어",
	long_desc = function(self, eff) return ("정확도 +%d / 공격시 치명타율 +%d%%"):format(eff.power, 0.5*eff.power) end,
	type = "mental",
	subtype = { telekinesis=true, focus=true },
	status = "beneficial",
	parameters = { power=10 },
	activate = function(self, eff)
		eff.attack = self:addTemporaryValue("combat_atk", eff.power)
		eff.crit = self:addTemporaryValue("combat_physcrit", 0.5*eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_atk", eff.attack)
		self:removeTemporaryValue("combat_physcrit", eff.crit)
	end,
}

newEffect{
	name = "PSI_REGEN", image = "talents/matter_is_energy.png",
	desc = "Matter is energy",
	kr_name = "에너지 추출",
	long_desc = function(self, eff) return ("보석을 이루는 물질이 서서히 에너지로 변화 : 염력 재생 +%0.2f"):format(eff.power) end,
	type = "mental",
	subtype = { psychic_drain=true },
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "보석에서 에너지가 빠져나와, #Target#에게로 쇄도합니다.", "+에너지" end,
	on_lose = function(self, err) return "#Target#의 보석에서 나오던 에너지의 흐름이 사라졌습니다.", "-에너지" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("psi_regen", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("psi_regen", eff.tmpid)
	end,
}

newEffect{
	name = "MASTERFUL_TELEKINETIC_ARCHERY", image = "talents/masterful_telekinetic_archery.png",
	desc = "Telekinetic Archery",
	kr_name = "염동력 궁술",
	long_desc = function(self, eff) return ("매 턴마다 염동력으로 쥔 활을 가장 가까운 적에게 자동으로 발사") end,
	type = "mental",
	subtype = { telekinesis=true },
	status = "beneficial",
	parameters = {dam=10},
	on_gain = function(self, err) return "#Target1# 무아지경에 빠져 염동력 궁술을 펼칩니다!", "+염동력 궁술" end,
	on_lose = function(self, err) return "#Target1# 염동력 궁술의 무아지경에서 벗어났습니다.", "-염동력 궁술" end,
}

newEffect{
	name = "WEAKENED_MIND", image = "talents/taint__telepathy.png",
	desc = "Receptive Mind",
	kr_name = "수용적 정신",
	long_desc = function(self, eff) return ("정신 내성 -%d / 정신력 +%d"):format(eff.save, eff.power) end,
	type = "mental",
	subtype = { morale=true },
	status = "detrimental",
	parameters = { power=10, save=10 },
	activate = function(self, eff)
		eff.mindid = self:addTemporaryValue("combat_mentalresist", -eff.save)
		eff.powdid = self:addTemporaryValue("combat_mindpower", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_mentalresist", eff.mindid)
		self:removeTemporaryValue("combat_mindpower", eff.powid)
	end,
}

newEffect{
	name = "VOID_ECHOES", image = "talents/echoes_from_the_void.png",
	desc = "Void Echoes",
	kr_name = "공허의 메아리",
	long_desc = function(self, eff) return ("공허의 메아리 : 일정 시간마다 정신 피해 %0.2f / 일정 시간마다 정신 내성으로 저항 검사, 실패시 원천력 감소"):format(eff.power) end,
	type = "mental",
	subtype = { madness=true, psionic=true },
	status = "detrimental",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target1# 공허의 광기에 빠졌습니다.", "+공허의 메아리" end,
	on_lose = function(self, err) return "#Target1# 공허의 광기에서 벗어났습니다.", "-공허의 메아리" end,
	on_timeout = function(self, eff)
		local drain = DamageType:get(DamageType.MIND).projector(eff.src or self, self.x, self.y, DamageType.MIND, eff.power) / 2
		self:incMana(-drain)
		self:incVim(-drain * 0.5)
		self:incPositive(-drain * 0.25)
		self:incNegative(-drain * 0.25)
		self:incStamina(-drain * 0.65)
		self:incHate(-drain * 0.2)
		self:incPsi(-drain * 0.2)
	end,
}

newEffect{
	name = "WAKING_NIGHTMARE", image = "talents/waking_nightmare.png",
	desc = "Waking Nightmare",
	kr_name = "잠들지 못하는 악몽",
	long_desc = function(self, eff) return ("악몽 : 매 턴마다 정신 피해 %0.2f / %d%% 확률로 무작위하게 나쁜 상태이상 효과 발생"):format(eff.dam, eff.chance) end,
	type = "mental",
	subtype = { nightmare=true, darkness=true },
	status = "detrimental",
	parameters = { chance=10, dam = 10 },
	on_gain = function(self, err) return "#F53CBE##Target1# 악몽에 빠졌습니다.", "+밤의 공포" end,
	on_lose = function(self, err) return "#Target1# 악몽에서 벗어났습니다.", "-밤의 공포" end,
	on_timeout = function(self, eff)
		DamageType:get(DamageType.DARKNESS).projector(eff.src or self, self.x, self.y, DamageType.DARKNESS, eff.dam)
		local chance = eff.chance
		if self:attr("sleep") then chance = chance * 2 end
		if rng.percent(chance) then
			-- Pull random effect
			chance = rng.range(1, 3)
			if chance == 1 then
				if self:canBe("blind") then
					self:setEffect(self.EFF_BLINDED, 3, {})
				end
			elseif chance == 2 then
				if self:canBe("stun") then
					self:setEffect(self.EFF_STUNNED, 3, {})
				end
			elseif chance == 3 then
				if self:canBe("confusion") then
					self:setEffect(self.EFF_CONFUSED, 3, {power=50})
				end
			end
			game.logSeen(self, "#F53CBE#%s 악몽에 굴복했습니다!", (self.kr_name or self.name):capitalize():addJosa("가"))
		end
	end,
}

newEffect{
	name = "INNER_DEMONS", image = "talents/inner_demons.png",
	desc = "Inner Demons",
	kr_name = "내면의 악마",
	long_desc = function(self, eff) return ("매 턴마다 %d%% 확률로 내면의 악마가 나타남 / 이 효과는 대상이 죽거나 저항 성공시 즉시 종료됨"):format(eff.chance) end,
	type = "mental",
	subtype = { nightmare=true },
	status = "detrimental",
	remove_on_clone = true,
	parameters = {chance=0},
	on_gain = function(self, err) return "#F53CBE#내면의 악마가 #Target3# 괴롭히기 시작합니다!", "+내면의 악마" end,
	on_lose = function(self, err) return "#Target1# 내면의 악마에게서 벗어났습니다.", "-내면의 악마" end,
	on_timeout = function(self, eff)
		if eff.src.dead or not game.level:hasEntity(eff.src) then eff.dur = 0 return true end
		local t = eff.src:getTalentFromId(eff.src.T_INNER_DEMONS)
		local chance = eff.chance
		if self:attr("sleep") then chance = chance * 2 end
		if rng.percent(chance) then
			if self:attr("sleep") or self:checkHit(eff.src:combatMindpower(), self:combatMentalResist(), 0, 95, 5) then
				t.summon_inner_demons(eff.src, self, t)
			else
				eff.dur = 0
			end
		end
	end,
}

newEffect{
	name = "PACIFICATION_HEX", image = "talents/pacification_hex.png",
	desc = "Pacification Hex",
	kr_name = "진정의 매혹",
	long_desc = function(self, eff) return ("매혹됨 : 매 턴마다 %d%% 확률로 3 턴간 혼절"):format(eff.chance) end,
	type = "mental",
	subtype = { hex=true, dominate=true },
	status = "detrimental",
	parameters = {chance=10, power=10},
	on_gain = function(self, err) return "#Target1# 매혹되었습니다!", "+진정의 매혹" end,
	on_lose = function(self, err) return "#Target1# 매혹에서 벗어났습니다.", "-진정의 매혹" end,
	-- Damage each turn
	on_timeout = function(self, eff)
		if not self:hasEffect(self.EFF_DAZED) and rng.percent(eff.chance) and self:canBe("stun") then
			self:setEffect(self.EFF_DAZED, 3, {})
			if not self:checkHit(eff.power, self:combatSpellResist(), 0, 95, 15) then eff.dur = 0 end
		end
	end,
	activate = function(self, eff)
		if self:canBe("stun") then
			self:setEffect(self.EFF_DAZED, 3, {})
		end
	end,
}

newEffect{
	name = "BURNING_HEX", image = "talents/burning_hex.png",
	desc = "Burning Hex",
	kr_name = "화염의 매혹",
	long_desc = function(self, eff) return ("매혹됨 : 기술을 사용할 때마다 화염 피해 %0.2f"):format(eff.dam) end,
	type = "mental",
	subtype = { hex=true, fire=true },
	status = "detrimental",
	parameters = {dam=10},
	on_gain = function(self, err) return "#Target1# 매혹되었습니다!", "+화염의 매혹" end,
	on_lose = function(self, err) return "#Target1# 매혹에서 벗어났습니다.", "-화염의 매혹" end,
}

newEffect{
	name = "EMPATHIC_HEX", image = "talents/empathic_hex.png",
	desc = "Empathic Hex",
	kr_name = "공감의 매혹",
	long_desc = function(self, eff) return ("매혹됨 : 누군가를 공격시 자신도 피해량의 %d%% 만큼 피해"):format(eff.power) end,
	type = "mental",
	subtype = { hex=true, dominate=true },
	status = "detrimental",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target1# 매혹되었습니다!", "+공감의 매혹" end,
	on_lose = function(self, err) return "#Target1# 매혹에서 벗어났습니다.", "-공감의 매혹" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("martyrdom", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("martyrdom", eff.tmpid)
	end,
}

newEffect{
	name = "DOMINATION_HEX", image = "talents/domination_hex.png",
	desc = "Domination Hex",
	kr_name = "지배의 매혹",
	long_desc = function(self, eff) return ("매혹됨 : 잠시동안 소속 집단이 변경") end, --에러 걸려서 집단 보여주는 변수 빼버림. 별로 필요도 없고 해서...
	type = "mental",
	subtype = { hex=true, dominate=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target1# 매혹되었습니다!", "+지배의 매혹" end,
	on_lose = function(self, err) return "#Target1# 매혹에서 벗어났습니다.", "-지배의 매혹" end,
	activate = function(self, eff)
		eff.olf_faction = self.faction
		self.faction = eff.src.faction
	end,
	deactivate = function(self, eff)
		self.faction = eff.olf_faction
	end,
}


newEffect{
	name = "DOMINATE_ENTHRALL", image = "talents/yeek_will.png",
	desc = "Enthralled",
	kr_name = "노예 상태",
	long_desc = function(self, eff) return ("노예가 됨 : 잠시동안 소속 집단이 변경") end,-- to %s.")--:format(engine.Faction.factions[eff.faction].name) end,
	type = "mental",
	subtype = { dominate=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target2# 노예가 되었습니다.", "+노예 상태" end,
	on_lose = function(self, err) return "#Target1# 노예 상태에서 벗어났습니다.", "-노예 상태" end,
	activate = function(self, eff)
		eff.olf_faction = self.faction
		self.faction = eff.src.faction
	end,
	deactivate = function(self, eff)
		self.faction = eff.olf_faction
	end,
}

newEffect{
	name = "HALFLING_LUCK", image = "talents/halfling_luck.png",
	desc = "Halflings's Luck",
	kr_name = "하플링의 행운",
	long_desc = function(self, eff) return ("행운과 교활함의 조합 : 물리 치명타율 +%d%% / 정신 치명타율 +%d%% / 주문 치명타율 +%d%%"):format(eff.physical, eff.mind, eff.spell) end,
	type = "mental",
	subtype = { focus=true },
	status = "beneficial",
	parameters = { spell=10, physical=10 },
	on_gain = function(self, err) return "#Target#의 치명타율이 높아진 것 같습니다." end,
	on_lose = function(self, err) return "#Target#의 치명타율이 평범하게 되돌아 왔습니다." end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "combat_physcrit", eff.physical)
		self:effectTemporaryValue(eff, "combat_spellcrit", eff.spell)
		self:effectTemporaryValue(eff, "combat_mindcrit", eff.mind)
		self:effectTemporaryValue(eff, "combat_physresist", eff.physical)
		self:effectTemporaryValue(eff, "combat_spellresist", eff.spell)
		self:effectTemporaryValue(eff, "combat_mentalresist", eff.mind)
	end,
}

newEffect{
	name = "ATTACK", image = "talents/perfect_strike.png",
	desc = "Attack",
	kr_name = "완벽한 공격", --@@ '완벽한 공격(Perfect Strike)'과 '무결점 사격(Unerring Shot)' 기술로 발동되는 효과
	long_desc = function(self, eff) return ("정확도 +%d"):format(eff.power) end,
	type = "mental",
	subtype = { focus=true },
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target1# 신중하게 적을 노리기 시작합니다." end,
	on_lose = function(self, err) return "#Target#의 공격이 조금 덜 신중해졌습니다." end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("combat_atk", eff.power)
		eff.bid = self:addTemporaryValue("blind_fight", 1)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_atk", eff.tmpid)
		self:removeTemporaryValue("blind_fight", eff.bid)
	end,
}

newEffect{
	name = "DEADLY_STRIKES", image = "talents/deadly_strikes.png",
	desc = "Deadly Strikes",
	kr_name = "치명적 타격",
	long_desc = function(self, eff) return ("방어도 관통력 +%d"):format(eff.power) end,
	type = "mental",
	subtype = { focus=true },
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target1# 신중하게 적을 노리기 시작합니다." end,
	on_lose = function(self, err) return "#Target#의 공격이 조금 덜 신중해졌습니다.." end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("combat_apr", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_apr", eff.tmpid)
	end,
}

newEffect{
	name = "FRENZY", image = "effects/frenzy.png",
	desc = "Frenzy",
	kr_name = "난도질",
	long_desc = function(self, eff) return ("전체 행동 속도 +%d%% / 물리 치명타율 +%d%% / 생명력이 -%d%% 이하가 될 때까지 전투 지속"):format(eff.power * 100, eff.crit, eff.dieat * 100) end,
	type = "mental",
	subtype = { frenzy=true, speed=true },
	status = "beneficial",
	parameters = { power=0.1 },
	on_gain = function(self, err) return "#Target1# 살의에 빠져, 난도질을 시작합니다.", "+난도질" end,
	on_lose = function(self, err) return "#Target1# 차분해졌습니다.", "-난도질" end,
	on_merge = function(self, old_eff, new_eff)
		-- use on merge so reapplied frenzy doesn't kill off creatures with negative life
		old_eff.dur = new_eff.dur
		old_eff.power = new_eff.power
		old_eff.crit = new_eff.crit
		return old_eff
	end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("global_speed_add", eff.power)
		eff.critid = self:addTemporaryValue("combat_physcrit", eff.crit)
		eff.dieatid = self:addTemporaryValue("die_at", -self.max_life * eff.dieat)
	end,
	deactivate = function(self, eff)
		-- check negative life first incase the creature has healing
		if self.life <= 0 then
			local sx, sy = game.level.map:getTileToScreen(self.x, self.y)
			game.flyers:add(sx, sy, 30, (rng.range(0,2)-1) * 0.5, rng.float(-2.5, -1.5), "사망 상태!", {255,0,255})
			game.logSeen(self, "%s 난도질 상태가 끝나면 사망합니다!", (self.kr_name or self.name):capitalize():addJosa("는"))
			self:die(self)
		end
		self:removeTemporaryValue("global_speed_add", eff.tmpid)
		self:removeTemporaryValue("combat_physcrit", eff.critid)
		self:removeTemporaryValue("die_at", eff.dieatid)
	end,
}

newEffect{
	name = "BLOODBATH", image = "talents/bloodbath.png",
	desc = "Bloodbath",
	kr_name = "피바다",
	long_desc = function(self, eff) return ("전투의 전율 : 최대 생명력 +%d%% / 생명력 재생 +%0.2f / 체력 재생 +%0.2f"):format(eff.hp, eff.cur_regen or eff.regen, eff.cur_regen/5 or eff.regen/5) end,
	type = "mental",
	subtype = { frenzy=true, heal=true },
	status = "beneficial",
	parameters = { hp=10, regen=10, max=50 },
	on_gain = function(self, err) return nil, "+피바다" end,
	on_lose = function(self, err) return nil, "-피바다" end,
	on_merge = function(self, old_eff, new_eff)
		self:removeTemporaryValue("max_life", old_eff.life_id)
		self:removeTemporaryValue("life_regen", old_eff.life_regen_id)
		self:removeTemporaryValue("stamina_regen", old_eff.stamina_regen_id)

		-- Take the new values, dont heal, otherwise you get a free heal each crit .. which is totaly broken
		local v = new_eff.hp * self.max_life / 100
		new_eff.life_id = self:addTemporaryValue("max_life", v)
		new_eff.cur_regen = math.min(old_eff.cur_regen + new_eff.regen, new_eff.max)
		new_eff.life_regen_id = self:addTemporaryValue("life_regen", new_eff.cur_regen)
		new_eff.stamina_regen_id = self:addTemporaryValue("stamina_regen", new_eff.cur_regen/5)
		return new_eff
	end,
	activate = function(self, eff)
		local v = eff.hp * self.max_life / 100
		eff.life_id = self:addTemporaryValue("max_life", v)
		self:heal(v)
		eff.cur_regen = eff.regen
		eff.life_regen_id = self:addTemporaryValue("life_regen", eff.regen)
		eff.stamina_regen_id = self:addTemporaryValue("stamina_regen", eff.regen /5)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("max_life", eff.life_id)
		self:removeTemporaryValue("life_regen", eff.life_regen_id)
		self:removeTemporaryValue("stamina_regen", eff.stamina_regen_id)
	end,
}

newEffect{
	name = "BLOODRAGE", image = "talents/bloodrage.png",
	desc = "Bloodrage",
	kr_name = "피의 분노",
	long_desc = function(self, eff) return ("전투의 전율 : 힘 +%d"):format(eff.cur_inc) end,
	type = "mental",
	subtype = { frenzy=true },
	status = "beneficial",
	parameters = { inc=1, max=10 },
	on_merge = function(self, old_eff, new_eff)
		self:removeTemporaryValue("inc_stats", old_eff.tmpid)
		old_eff.cur_inc = math.min(old_eff.cur_inc + new_eff.inc, new_eff.max)
		old_eff.tmpid = self:addTemporaryValue("inc_stats", {[Stats.STAT_STR] = old_eff.cur_inc})

		old_eff.dur = new_eff.dur
		return old_eff
	end,
	activate = function(self, eff)
		eff.cur_inc = eff.inc
		eff.tmpid = self:addTemporaryValue("inc_stats", {[Stats.STAT_STR] = eff.inc})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_stats", eff.tmpid)
	end,
}

newEffect{
	name = "UNSTOPPABLE", image = "talents/unstoppable.png",
	desc = "Unstoppable",
	kr_name = "무쌍",
	long_desc = function(self, eff) return ("무쌍 : 죽지 않음 / 효과 종료시 생명력 %d 회복"):format(eff.kills * eff.hp_per_kill * self.max_life / 100) end,
	type = "mental",
	subtype = { frenzy=true },
	status = "beneficial",
	parameters = { hp_per_kill=2 },
	activate = function(self, eff)
		eff.kills = 0
		eff.tmpid = self:addTemporaryValue("unstoppable", 1)
		eff.healid = self:addTemporaryValue("no_life_regen", 1)
	end,
	deactivate = function(self, eff)
		self:heal(eff.kills * eff.hp_per_kill * self.max_life / 100)
		self:removeTemporaryValue("unstoppable", eff.tmpid)
		self:removeTemporaryValue("no_life_regen", eff.healid)
	end,
}

newEffect{
	name = "INCREASED_LIFE", image = "effects/increased_life.png",
	desc = "Increased Life",
	kr_name = "생명력 향상",
	long_desc = function(self, eff) return ("최대 생명력 +%d"):format(eff.life) end,
	type = "mental",
	subtype = { frenzy=true, heal=true },
	status = "beneficial",
	on_gain = function(self, err) return "#Target1# 추가적인 생명력을 얻었습니다.", "+생명력" end,
	on_lose = function(self, err) return "#Target의# 추가적인 생명력이 사라졌습니다.", "-생명력" end,
	parameters = { life = 50 },
	activate = function(self, eff)
		self.max_life = self.max_life + eff.life
		self.life = self.life + eff.life
		self.changed = true
	end,
	deactivate = function(self, eff)
		self.max_life = self.max_life - eff.life
		self.life = self.life - eff.life
		self.changed = true
		if self.life <= 0 then
			self.life = 1
			self:setEffect(self.EFF_STUNNED, 3, {})
			game.logSeen(self, "%s의 향상된 생명력이 사라지면서, 그 충격으로 %s 기절했습니다.", (self.kr_name or self.name):capitalize(), (self.kr_name or self.name):addJosa("가")) --@@ 변수 조정
		end
	end,
}

newEffect{
	name = "RAMPAGE", image = "talents/rampage.png",
	desc = "Rampaging",
	kr_name = "광란",
	long_desc = function(self, eff)
		local desc = ("광란 : 이동 속도 +%d%% / 공격 속도 +%d%%"):format(eff.movementSpeedChange * 100, eff.combatPhysSpeedChange * 100)
		if eff.physicalDamageChange > 0 then
			desc = desc..(" / 공격시 물리 피해량 +%d%% / 물리 내성 +%d / 정신 내성 +%d"):format(eff.physicalDamageChange, eff.combatPhysResistChange, eff.combatMentalResistChange)
		end
		if eff.damageShieldMax > 0 then
			desc = desc..(" / 현재 턴에 %d 만큼 피해 흡수 가능 (최대 흡수량 : %d)"):format(math.max(0, eff.damageShieldMax - eff.damageShield), eff.damageShieldMax)
		end
		--desc = desc..")" --@@ 필요없어져 주석 처리
		return desc
	end,
	type = "mental",
	subtype = { frenzy=true, speed=true, evade=true },
	status = "beneficial",
	parameters = { },
	on_gain = function(self, err) return "#F53CBE##Target1# 광란에 빠졌습니다!", "+광란" end,
	on_lose = function(self, err) return "#F53CBE##Target1# 광란에서 벗어났습니다.", "-광란" end,
	activate = function(self, eff)
		if eff.movementSpeedChange or 0 > 0 then eff.movementSpeedId = self:addTemporaryValue("movement_speed", eff.movementSpeedChange) end
		if eff.combatPhysSpeedChange or 0 > 0 then eff.combatPhysSpeedId = self:addTemporaryValue("combat_physspeed", eff.combatPhysSpeedChange) end
		if eff.physicalDamageChange or 0 > 0 then eff.physicalDamageId = self:addTemporaryValue("inc_damage", { [DamageType.PHYSICAL] = eff.physicalDamageChange }) end
		if eff.combatPhysResistChange or 0 > 0 then eff.combatPhysResistId = self:addTemporaryValue("combat_physresist", eff.combatPhysResistChange) end
		if eff.combatMentalResistChange or 0 > 0 then eff.combatMentalResistId = self:addTemporaryValue("combat_mentalresist", eff.combatMentalResistChange) end

		eff.particle = self:addParticles(Particles.new("rampage", 1))
	end,
	deactivate = function(self, eff)
		if eff.movementSpeedId then self:removeTemporaryValue("movement_speed", eff.movementSpeedId) end
		if eff.combatPhysSpeedId then self:removeTemporaryValue("combat_physspeed", eff.combatPhysSpeedId) end
		if eff.physicalDamageId then self:removeTemporaryValue("inc_damage", eff.physicalDamageId) end
		if eff.combatPhysResistId then self:removeTemporaryValue("combat_physresist", eff.combatPhysResistId) end
		if eff.combatMentalResistId then self:removeTemporaryValue("combat_mentalresist", eff.combatMentalResistId) end

		self:removeParticles(eff.particle)
	end,
	on_timeout = function(self, eff)
		-- restore damage shield
		if eff.damageShieldMax and eff.damageShield ~= eff.damageShieldMax and not self.dead then
			eff.damageShieldUsed = (eff.damageShieldUsed or 0) + eff.damageShieldMax - eff.damageShield
			game.logSeen(self, "%s 피해를 %d 흡수했으며, 더 흡수할 준비가 되었습니다.", (self.kr_name or self.name):capitalize():addJosa("가"), eff.damageShieldMax - eff.damageShield)
			eff.damageShield = eff.damageShieldMax

			if eff.damageShieldBonus and eff.damageShieldUsed >= eff.damageShieldBonus and eff.actualDuration < eff.maxDuration then
				eff.actualDuration = eff.actualDuration + 1
				eff.dur = eff.dur + 1
				eff.damageShieldBonus = nil

				game.logPlayer(self, "#F53CBE#격렬한 맹습으로 광란 상태가 고무됩니다! (지속시간 +1)")
			end
		end
	end,
	do_onTakeHit = function(self, eff, dam)
		if not eff.damageShieldMax or eff.damageShield <= 0 then return dam end

		local absorb = math.min(eff.damageShield, dam)
		eff.damageShield = eff.damageShield - absorb

		--game.logSeen(self, "%s shrugs off %d damage.", self.name:capitalize(), absorb)

		return dam - absorb
	end,
	do_postUseTalent = function(self, eff)
		if eff.dur > 0 then
			eff.dur = eff.dur - 1

			game.logPlayer(self, "#F53CBE#광란이 조금 가라앉습니다. (지속시간 -1)")
		end
	end,
}

newEffect{
	name = "PREDATOR", image = "effects/predator.png",
	desc = "Predator",
	kr_name = "포식자",
	no_stop_enter_worlmap = true,
	decrease = 0,
	no_remove = true,
	cancel_on_level_change = true,
	long_desc = function(self, eff)
		local desc = ([[현재 사냥감 : %s / %s, 사냥 효율 : %d%% 사냥한 횟수 : %d / %d, 추가 피해량 %+d%% / %+d%%]]):format(eff.type, eff.subtype, (eff.effectiveness * 100) or 0, eff.typeKills, eff.subtypeKills, (eff.typeDamageChange * 100) or 0, (eff.subtypeDamageChange * 100) or 0)
		if eff.subtypeAttackChange or 0 > 0 then
			desc = desc..([[, 정확도 추가 : %+d / %+d, 기절 확률 : -- / %0.1f%%, 의표 찌르기 확률 : %0.1f%% / %0.1f%%]]):format(eff.typeAttackChange or 0, eff.subtypeAttackChange or 0, eff.subtypeStunChance or 0, eff.typeOutmaneuverChance or 0, eff.subtypeOutmaneuverChance or 0)
		end
		return desc
	end,
	type = "mental",
	subtype = { predator=true },
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, eff) return ("#Target1# %s, 그 중에서도 %s 사냥감으로 지정합니다."):format(eff.type:krActorType():addJosa("를"), eff.subtype:krActorType():addJosa("를")) end,
	on_lose = function(self, eff) return ("#Target1# 더이상 %s나 %s 쫒지 않습니다."):format(eff.type:krActorType():addJosa(7), eff.subtype:krActorType():addJosa("를")) end,
	activate = function(self, eff)
		local e = self.tempeffect_def[self.EFF_PREDATOR]
		e.updateEffect(self, eff)
	end,
	deactivate = function(self, eff)
	end,
	addKill = function(self, target, e, eff)
		if target.type == eff.type then
			local isSubtype = (target.subtype == eff.subtype)
			if isSubtype then
				eff.subtypeKills = eff.subtypeKills + 1
				eff.killExperience = eff.killExperience + 1
			else
				eff.typeKills = eff.typeKills + 1
				eff.killExperience = eff.killExperience + 0.25
			end

			e.updateEffect(self, eff)

			-- apply hate bonus
			if isSubtype and self:knowTalent(self.T_HATE_POOL) then
				self:incHate(eff.hateBonus)
				game.logPlayer(self, "#F53CBE#사냥감을 죽여, 증오심을 키웠습니다. (증오 +%d)", eff.hateBonus)
			end

			-- apply mimic effect
			if isSubtype and self:knowTalent(self.T_MIMIC) then
				local tMimic = self:getTalentFromId(self.T_MIMIC)
				self:setEffect(self.EFF_MIMIC, 1, { target = target, maxIncrease = math.ceil(tMimic.getMaxIncrease(self, tMimic) * eff.effectiveness) })
			end
		end
	end,
	updateEffect = function(self, eff)
		local tMarkPrey = self:getTalentFromId(self.T_MARK_PREY)
		eff.maxKillExperience = tMarkPrey.getMaxKillExperience(self, tMarkPrey)
		eff.effectiveness = math.min(1, eff.killExperience / eff.maxKillExperience)
		eff.subtypeDamageChange = tMarkPrey.getSubtypeDamageChange(self, tMarkPrey) * eff.effectiveness
		eff.typeDamageChange = tMarkPrey.getTypeDamageChange(self, tMarkPrey) * eff.effectiveness

		local tAnatomy = self:getTalentFromId(self.T_ANATOMY)
		if tAnatomy and self:getTalentLevelRaw(tAnatomy) > 0 then
			eff.subtypeAttackChange = tAnatomy.getSubtypeAttackChange(self, tAnatomy) * eff.effectiveness
			eff.typeAttackChange = tAnatomy.getTypeAttackChange(self, tAnatomy) * eff.effectiveness
			eff.subtypeStunChance = tAnatomy.getSubtypeStunChance(self, tAnatomy) * eff.effectiveness
		else
			eff.subtypeAttackChange = 0
			eff.typeAttackChange = 0
			eff.subtypeStunChance = 0
		end

		local tOutmaneuver = self:getTalentFromId(self.T_OUTMANEUVER)
		if tOutmaneuver and self:getTalentLevelRaw(tOutmaneuver) > 0 then
			eff.typeOutmaneuverChance = tOutmaneuver.getTypeChance(self, tOutmaneuver) * eff.effectiveness
			eff.subtypeOutmaneuverChance = tOutmaneuver.getSubtypeChance(self, tOutmaneuver) * eff.effectiveness
		else
			eff.typeOutmaneuverChance = 0
			eff.subtypeOutmaneuverChance = 0
		end

		eff.hateBonus = tMarkPrey.getHateBonus(self, tMarkPrey)
	end,
}

newEffect{
	name = "OUTMANEUVERED", image = "talents/outmaneuver.png",
	desc = "Outmaneuvered",
	kr_name = "허를 찔림",
	long_desc = function(self, eff)
		local desc = ("허를 찔림 : 물리 저항 %d%% 감소"):format(eff.physicalResistChange) --@@ 변수가 음수인 경우 '감소' 삭제 필요
		--local first = true --@@ 필요없어져 주석 처리
		for id, value in pairs(eff.incStats) do
			--if not first then desc = desc.." / " end --@@ 필요없어져 주석 처리
			--first = false --@@ 필요없어져 주석 처리
			desc = desc..(" / %s %+d"):format(Stats.stats_def[id].name:capitalize():krStat(), value) --@@ 변수 순서 조정
		end
		--desc = desc..")" --@@ 필요없어져 주석 처리
		return desc
	end,
	type = "mental",
	subtype = { predator=true },
	status = "detrimental",
	on_gain = function(self, eff) return "#Target1# 허를 찔렸습니다." end,
	on_lose = function(self, eff) return "#Target2# 허가 찔린 상태에서 벗어났습니다." end,
	addEffect = function(self, eff)
		if eff.physicalResistId then self:removeTemporaryValue("resists", eff.physicalResistId) end
		eff.physicalResistId = self:addTemporaryValue("resists", { [DamageType.PHYSICAL]=eff.physicalResistChange })

		local maxId
		local maxValue = 0
		for id, def in ipairs(self.stats_def) do
			if def.id ~= self.STAT_LCK then
				local value = self:getStat(id, nil, nil, false)
				if value > maxValue then
					maxId = id
					maxValue = value
				end
			end
		end
		if eff.incStatsId then self:removeTemporaryValue("inc_stats", eff.incStatsId) end
		eff.incStats = eff.incStats or {}
		eff.incStats[maxId] = (eff.incStats[maxId] or 0) - eff.statReduction
		eff.incStatsId = self:addTemporaryValue("inc_stats", eff.incStats)
		game.logSeen(self, ("%s의 %s %d 만큼 감소했습니다."):format((self.kr_name or self.name):capitalize(), Stats.stats_def[maxId].name:capitalize():krStat():addJosa("가"), eff.statReduction)) --@@ 변수 순서 조정
	end,
	activate = function(self, eff)
		self.tempeffect_def[self.EFF_OUTMANEUVERED].addEffect(self, eff)
	end,
	deactivate = function(self, eff)
		if eff.physicalResistId then self:removeTemporaryValue("resists", eff.physicalResistId) end
		if eff.incStatsId then self:removeTemporaryValue("inc_stats", eff.incStatsId) end
	end,
	on_merge = function(self, old_eff, new_eff)
		-- spread old effects over new duration
		old_eff.physicalResistChange = math.min(50, new_eff.physicalResistChange + (old_eff.physicalResistChange * old_eff.dur / new_eff.dur))
		for id, value in pairs(old_eff.incStats) do
			old_eff.incStats[id] = math.ceil(value * old_eff.dur / new_eff.dur)
		end
		old_eff.dur = new_eff.dur

		-- add new effect
		self.tempeffect_def[self.EFF_OUTMANEUVERED].addEffect(self, old_eff)

		return old_eff
	end,
}

newEffect{
	name = "MIMIC", image = "talents/mimic.png",
	desc = "Mimic",
	kr_name = "흉내 내기",
	long_desc = function(self, eff)
		if not eff.incStatsId then return "이전 사냥감 흉내 내기 : 효과 없음" end

		local desc = "이전 사냥감 흉내 내기 : "
		local first = true
		for id, value in pairs(eff.incStats) do
			if not first then desc = desc.." / " end
			first = false
			desc = desc..("%s %+d"):format(Stats.stats_def[id].name:capitalize():krStat(), value) --@@ 변수 순서 조정
		end
		--desc = desc..")" --@@ 필요없어져 주석 처리
		return desc
	end,
	type = "mental",
	subtype = { predator=true },
	status = "beneficial",
	no_stop_enter_worlmap = true,
	decrease = 0,
	no_remove = true,
	cancel_on_level_change = true,
	parameters = { },
	on_lose = function(self, eff) return "#Target1# 더이상 사냥감의 흉내를 내지 않습니다." end,
	activate = function(self, eff)
		-- old version used difference from target stats and self stats; new version just uses target stats
		local sum = 0
		local values = {}
		for id, def in ipairs(self.stats_def) do
			if def.id and def.id ~= self.STAT_LCK then
				--local diff = eff.target:getStat(def.id, nil, nil, true) - self:getStat(def.id, nil, nil, true)
				local diff = eff.target:getStat(def.id, nil, nil, false)
				if diff > 0 then
					table.insert(values, { def.id, diff })
					sum = sum + diff
				end
			end
		end

		if sum > 0 then
			eff.incStats = {}
			if sum <= eff.maxIncrease then
				-- less than maximum; apply all stat differences
				for i, value in ipairs(values) do
					eff.incStats[value[1]] = value[2]
				end
			else
				-- distribute stats based on fractions and calculate what the remainder will be
				local sumIncrease = 0
				for i, value in ipairs(values) do
					value[2] = eff.maxIncrease * value[2] / sum
					sumIncrease = sumIncrease + math.floor(value[2])
				end
				local remainder = eff.maxIncrease - sumIncrease

				-- sort on fractional amount for distributing the remainder points
				table.sort(values, function(a,b) return a[2] % 1 > b[2] % 1 end)

				-- convert fractions to stat increases and apply remainder
				for i, value in ipairs(values) do
					eff.incStats[value[1]] = math.floor(value[2]) + (i <= remainder and 1 or 0)
				end
			end
			eff.incStatsId = self:addTemporaryValue("inc_stats", eff.incStats)
		end

		if not eff.incStatsId then
			game.logSeen(self, ("%s %s의 흉내를 내기 시작합니다. (효과 없음)"):format((self.kr_name or self.name):capitalize():addJosa("가"), (eff.target.kr_name or eff.target.name)))
		else
			local desc = ("%s %s의 흉내를 내기 시작합니다. ("):format( (self.kr_name or self.name):capitalize():addJosa("가"), (eff.target.kr_name or eff.target.name) )
			local first = true
			for id, value in pairs(eff.incStats) do
				if not first then desc = desc..", " end
				first = false
				desc = desc..("%s %+d"):format(Stats.stats_def[id].name:capitalize():krStat(), value) --@@ 변수 순서 조정
			end
			desc = desc..")"
			game.logSeen(self, desc)
		end
	end,
	deactivate = function(self, eff)
		if eff.incStatsId then self:removeTemporaryValue("inc_stats", eff.incStatsId) end
		eff.incStats = nil
	end,
	on_merge = function(self, old_eff, new_eff)
		if old_eff.incStatsId then self:removeTemporaryValue("inc_stats", old_eff.incStatsId) end
		old_eff.incStats = nil
		old_eff.incStatsId = nil

		self.tempeffect_def[self.EFF_MIMIC].activate(self, new_eff)

		return new_eff
	end
}

newEffect{
	name = "ORC_FURY", image = "talents/orc_fury.png",
	desc = "Orcish Fury",
	kr_name = "오크의 분노",
	long_desc = function(self, eff) return ("파괴적 분노 : 공격시 피해량 +%d%%"):format(eff.power) end,
	type = "mental",
	subtype = { frenzy=true },
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target1# 피에 굶주린 상태가 되었습니다." end,
	on_lose = function(self, err) return "#Target1# 차분해졌습니다." end,
	activate = function(self, eff)
		eff.pid = self:addTemporaryValue("inc_damage", {all=eff.power})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_damage", eff.pid)
	end,
}

newEffect{
	name = "INTIMIDATED",
	desc = "Intimidated",
	kr_name = "주눅", --@@ /data/talents/techniques/conditioning.lua:74번 줄의 내용과 매칭시킴
	long_desc = function(self, eff) return ("사기 저하 : 물리력 -%d / 정신력 -%d / 주문력 -%d"):format(eff.power, eff.power, eff.power) end, --@@ 변수 조정
	type = "mental",
	subtype = { fear=true },
	status = "detrimental",
	on_gain = function(self, err) return "#Target#의 사기가 저하되었습니다.", "+주눅" end,
	on_lose = function(self, err) return "#Target1# 자신감을 되찾았습니다.", "-주눅" end,
	parameters = { power=1 },
	activate = function(self, eff)
		eff.damid = self:addTemporaryValue("combat_dam", -eff.power)
		eff.spellid = self:addTemporaryValue("combat_spellpower", -eff.power)
		eff.mindid = self:addTemporaryValue("combat_mindpower", -eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_dam", eff.damid)
		self:removeTemporaryValue("combat_spellpower", eff.spellid)
		self:removeTemporaryValue("combat_mindpower", eff.mindid)
	end,
}

newEffect{
	name = "BRAINLOCKED",
	desc = "Brainlocked",
	kr_name = "정신 잠금",
	long_desc = function(self, eff) return ("임의의 기술을 사용 불가능 상태로 변경 / 모든 기술의 재사용 대기시간이 감소하지 않음"):format() end,
	type = "mental",
	subtype = { ["cross tier"]=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return nil, "+정신 잠금" end,
	on_lose = function(self, err) return nil, "-정신 잠금" end,
	activate = function(self, eff)
		eff.tcdid = self:addTemporaryValue("no_talents_cooldown", 1)
		local tids = {}
		for tid, lev in pairs(self.talents) do
			local t = self:getTalentFromId(tid)
			if t and not self.talents_cd[tid] and t.mode == "activated" and not t.innate then tids[#tids+1] = t end
		end
		for i = 1, 1 do
			local t = rng.tableRemove(tids)
			if not t then break end
			self.talents_cd[t.id] = 1
		end
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("no_talents_cooldown", eff.tcdid)
	end,
}

newEffect{
	name = "FRANTIC_SUMMONING", image = "talents/frantic_summoning.png",
	desc = "Frantic Summoning",
	kr_name = "광적 소환",
	long_desc = function(self, eff) return ("소환 지연 시간 -%d%%"):format(eff.power) end,
	type = "mental",
	subtype = { summon=true },
	status = "beneficial",
	on_gain = function(self, err) return "#Target1# 빠른 속도로 소환을 하기 시작합니다.", "+광적 소환" end,
	on_lose = function(self, err) return "#Target#의 광적 소환이 끝났습니다.", "-광적 소환" end,
	parameters = { power=20 },
	activate = function(self, eff)
		eff.failid = self:addTemporaryValue("no_equilibrium_summon_fail", 1)
		eff.speedid = self:addTemporaryValue("fast_summons", eff.power)

		-- Find a cooling down summon talent and enable it
		local list = {}
		for tid, dur in pairs(self.talents_cd) do
			local t = self:getTalentFromId(tid)
			if t.is_summon then
				list[#list+1] = t
			end
		end
		if #list > 0 then
			local t = rng.table(list)
			self.talents_cd[t.id] = nil
			if self.onTalentCooledDown then self:onTalentCooledDown(t.id) end
		end
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("no_equilibrium_summon_fail", eff.failid)
		self:removeTemporaryValue("fast_summons", eff.speedid)
	end,
}

newEffect{
	name = "WILD_SUMMON", image = "talents/wild_summon.png",
	desc = "Wild Summon",
	kr_name = "야생의 소환수",
	long_desc = function(self, eff) return ("%d%% 확률로 소환수가 더 강력해짐"):format(eff.chance) end,
	type = "mental",
	subtype = { summon=true },
	status = "beneficial",
	parameters = { chance=100 },
	activate = function(self, eff)
		eff.tid = self:addTemporaryValue("wild_summon", eff.chance)
	end,
	on_timeout = function(self, eff)
		eff.chance = eff.chance or 100
		eff.chance = math.floor(eff.chance * 0.66)
		self:removeTemporaryValue("wild_summon", eff.tid)
		eff.tid = self:addTemporaryValue("wild_summon", eff.chance)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("wild_summon", eff.tid)
	end,
}

newEffect{
	name = "LOBOTOMIZED", image = "talents/psychic_lobotomy.png",
	desc = "Lobotomized",
	kr_name = "사고 방해",
	long_desc = function(self, eff) return ("정신 능력 손상 : 혼란 발생 / %d%% 의 확률로 멋대로 행동 / 교활함 -%d"):format(eff.power, eff.power/2) end,
	type = "mental",
	subtype = { confusion=true },
	status = "detrimental",
	on_gain = function(self, err) return "#Target#의 정신 능력이 손상되었습니다.", "+사고 방해" end,
	on_lose = function(self, err) return "#Target#의 감각이 되돌아 왔습니다.", "-사고 방해" end,
	parameters = { power=1, dam=1 },
	activate = function(self, eff)
		DamageType:get(DamageType.MIND).projector(eff.src or self, self.x, self.y, DamageType.MIND, {dam=eff.dam, alwaysHit=true})
		eff.power = math.floor(math.max(eff.power - (self:attr("confusion_immune") or 0) * 100, 10))
		eff.power = util.bound(eff.power, 0, 50)
		eff.tmpid = self:addTemporaryValue("confused", eff.power)
		eff.cid = self:addTemporaryValue("inc_stats", {[Stats.STAT_CUN]=-eff.power/2})
		if eff.power <= 0 then eff.dur = 0 end
		eff.particles = self:addParticles(engine.Particles.new("generic_power", 1, {rm=100, rM=125, gm=100, gM=125, bm=100, bM=125, am=200, aM=255}))
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("confused", eff.tmpid)
		self:removeTemporaryValue("inc_stats", eff.cid)
		if eff.particles then self:removeParticles(eff.particles) end
		if self == game.player and self.updateMainShader then self:updateMainShader() end
	end,
}


newEffect{
	name = "PSIONIC_SHIELD", image = "talents/kinetic_shield.png",
	desc = "Psionic Shield",
	kr_name = "염동 보호막",
	display_desc = function(self, eff) return eff.kr_kind:capitalize().." 염동 보호막" end, --@@ kind를 kr_kind로 바꿈
	long_desc = function(self, eff) return ("%s 피해 -%d"):format(eff.kr_what, eff.power) end, --@@ what을 kr_what으로 바꿈
	type = "mental",
	subtype = { psionic=true, shield=true },
	status = "beneficial",
	parameters = { power=10, kind="kinetic" },
	activate = function(self, eff)
		if eff.kind == "kinetic" then
			eff.kr_kind = "동역학적"
			eff.sid = self:addTemporaryValue("flat_damage_armor", {[DamageType.PHYSICAL] = eff.power, [DamageType.ACID] = eff.power})
			eff.what = "physical and acid"
			eff.kr_what = "물리 속성과 산성 속성"
		elseif eff.kind == "thermal" then
			eff.kr_kind = "열역학적"
			eff.sid = self:addTemporaryValue("flat_damage_armor", {[DamageType.FIRE] = eff.power, [DamageType.COLD] = eff.power})
			eff.what = "fire and cold"
			eff.kr_what = "화염 속성과 냉기 속성"
		elseif eff.kind == "charged" then
			eff.kr_kind = "전하적"
			eff.sid = self:addTemporaryValue("flat_damage_armor", {[DamageType.LIGHTNING] = eff.power, [DamageType.BLIGHT] = eff.power})
			eff.what = "lightning and blight"
			eff.kr_what = "전기 속성과 황폐 속성"
		end
	end,
	deactivate = function(self, eff)
		if eff.sid then
			self:removeTemporaryValue("flat_damage_armor", eff.sid)
		end
	end,
}

newEffect{
	name = "CLEAR_MIND", image = "talents/mental_shielding.png",
	desc = "Clear Mind",
	kr_name = "맑은 정신",
	long_desc = function(self, eff) return ("지속시간 동안, 최대 %d 개의 나쁜 정신적 상태효과를 방어"):format(self.mental_negative_status_effect_immune) end,
	type = "mental",
	subtype = { psionic=true, },
	status = "beneficial",
	parameters = { power=2 },
	activate = function(self, eff)
		self.mental_negative_status_effect_immune = eff.power
		eff.particles = self:addParticles(engine.Particles.new("generic_power", 1, {rm=0, rM=0, gm=100, gM=180, bm=180, bM=255, am=200, aM=255}))
	end,
	deactivate = function(self, eff)
		self.mental_negative_status_effect_immune = nil
		self:removeParticles(eff.particles)
	end,
}

newEffect{
	name = "RESONANCE_FIELD", image = "talents/resonance_field.png",
	desc = "Resonance Field",
	kr_name = "공진 장막",
	long_desc = function(self, eff) return ("염동막 보호 : 모든 피해의 50%% 흡수 (남은 흡수량 : %d / 최대 흡수량 : %d)"):format(self.resonance_field_absorb, eff.power) end,
	type = "mental",
	subtype = { psionic=true, shield=true },
	status = "beneficial",
	parameters = { power=100 },
	on_gain = function(self, err) return "#Target# 주변을 염동막이 둘러쌉니다.", "+공진 장막" end,
	on_lose = function(self, err) return "#Target3# 둘러싼 염동막이 부서졌습니다.", "-공진 장막" end,
	damage_feedback = function(self, eff, src, value)
		if eff.particle and eff.particle._shader and eff.particle._shader.shad and src and src.x and src.y then
			local r = -rng.float(0.2, 0.4)
			local a = math.atan2(src.y - self.y, src.x - self.x)
			eff.particle._shader:setUniform("impact", {math.cos(a) * r, math.sin(a) * r})
			eff.particle._shader:setUniform("impact_tick", core.game.getTime())
		end
	end,
	activate = function(self, eff)
		self.resonance_field_absorb = eff.power
		eff.sid = self:addTemporaryValue("resonance_field", eff.power)
		if core.shader.active(4) then
			eff.particle = self:addParticles(Particles.new("shader_shield", 1, {size_factor=1.1}, {type="shield", time_factor=-8000, llpow=1, aadjust=7, color={1, 1, 0}}))
		--	eff.particle = self:addParticles(Particles.new("shader_shield", 1, {img="shield2", size_factor=1.25}, {type="shield", time_factor=6000, color={1, 1, 0}}))
		else
			eff.particle = self:addParticles(Particles.new("generic_shield", 1, {r=1, g=1, b=0, a=1}))
		end
	end,
	deactivate = function(self, eff)
		self.resonance_field_absorb = nil
		self:removeParticles(eff.particle)
		self:removeTemporaryValue("resonance_field", eff.sid)
	end,
}

newEffect{
	name = "MIND_LINK_TARGET", image = "talents/mind_link.png",
	desc = "Mind Link",
	kr_name = "정신 침해",
	long_desc = function(self, eff) return ("정신 침해 : %s 주는 정신 피해 +%d%%"):format((eff.src.kr_name or eff.src.name):capitalize():addJosa("가"), eff.power) end,
	type = "mental",
	subtype = { psionic=true },
	status = "detrimental",
	parameters = {power = 1, range = 5},
	remove_on_clone = true, decrease = 0,
	on_gain = function(self, err) return "#Target#의 정신이 침범당했습니다!", "+정신 침해" end,
	on_lose = function(self, err) return "#Target#의 정신 침해가 사라졌습니다.", "-정신 침해" end,
	on_timeout = function(self, eff)
		-- Remove the mind link when appropriate
		local p = eff.src:isTalentActive(eff.src.T_MIND_LINK)
		if not p or p.target ~= self or eff.src.dead or not game.level:hasEntity(eff.src) or core.fov.distance(self.x, self.y, eff.src.x, eff.src.y) > eff.range then
			self:removeEffect(self.EFF_MIND_LINK_TARGET)
		end
	end,
}

newEffect{
	name = "FEEDBACK_LOOP", image = "talents/feedback_loop.png",
	desc = "Feedback Loop",
	kr_name = "힘의 순환",
	long_desc = function(self, eff) return "반작용 획득" end,
	type = "mental",
	subtype = { psionic=true },
	status = "beneficial",
	parameters = { power = 1 },
	on_gain = function(self, err) return "#Target1# 반작용을 얻기 시작합니다.", "+힘의 순환" end,
	on_lose = function(self, err) return "#Target1# 더이상 반작용을 얻지 못하게 되었습니다.", "-힘의 순환" end,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("ultrashield", 1, {rm=255, rM=255, gm=180, gM=255, bm=0, bM=0, am=35, aM=90, radius=0.2, density=15, life=28, instop=40}))
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
	end,
}

newEffect{
	name = "FOCUSED_WRATH", image = "talents/focused_wrath.png",
	desc = "Focused Wrath",
	kr_name = "집중된 분노",
	long_desc = function(self, eff) return ("잠재의식이 %s에게 집중"):format((eff.target.kr_name or eff.target.name):capitalize()) end,
	type = "mental",
	subtype = { psionic=true },
	status = "beneficial",
	parameters = { power = 1 },
	on_gain = function(self, err) return "#Target#의 잠재의식이 집중하기 시작합니다.", "+집중된 분노" end,
	on_lose = function(self, err) return "#Target#의 잠재의식이 평범하게 돌아왔습니다.", "-집중된 분노" end,
	on_timeout = function(self, eff)
		if not eff.target or eff.target.dead or not game.level:hasEntity(eff.target) then
			self:removeEffect(self.EFF_FOCUSED_WRATH)
		end
	end,
}

newEffect{
	name = "SLEEP", image = "talents/sleep.png",
	desc = "Sleep",
	kr_name = "수면",
	long_desc = function(self, eff) return ("수면 : 모든 행동 불가능 /  %d 만큼 피해를 입을 때마다 수면 시간 한 턴씩 단축"):format(eff.power) end,
	type = "mental",
	subtype = { sleep=true },
	status = "detrimental",
	parameters = { power=1, insomnia=1, waking=0, contagious=0 },
	on_gain = function(self, err) return "#Target1# 잠들었습니다.", "+수면" end,
	on_lose = function(self, err) return "#Target1# 잠에서 깼습니다.", "-수면" end,
	on_timeout = function(self, eff)
		local dream_prison = false
		if eff.src and eff.src.isTalentActive and eff.src:isTalentActive(eff.src.T_DREAM_PRISON) then
			local t = eff.src:getTalentFromId(eff.src.T_DREAM_PRISON)
			if core.fov.distance(self.x, self.y, eff.src.x, eff.src.y) <= eff.src:getTalentRange(t) then
				dream_prison = true
			end
		end
		if dream_prison then
			eff.dur = eff.dur + 1
			if not eff.particle then
				if core.shader.active(4) then
					eff.particle = self:addParticles(Particles.new("shader_shield", 1, {img="shield2", size_factor=1.25}, {type="shield", time_factor=6000, aadjust=5, color={0, 1, 1}}))
				else
					eff.particle = self:addParticles(Particles.new("generic_shield", 1, {r=0, g=1, b=1, a=1}))
				end
			end
		elseif eff.contagious > 0 and eff.dur > 1 then
			local t = eff.src:getTalentFromId(eff.src.T_SLEEP)
			t.doContagiousSleep(eff.src, self, eff, t)
		end
		if eff.particle and not dream_prison then
			self:removeParticles(eff.particle)
		end
		-- Incriment Insomnia Duration
		if not self:attr("lucid_dreamer") then
			self:setEffect(self.EFF_INSOMNIA, 1, {power=eff.insomnia})
		end
	end,
	activate = function(self, eff)
		eff.sid = self:addTemporaryValue("sleep", 1)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("sleep", eff.sid)
		if not self:attr("sleep") and not self.dead and game.level:hasEntity(self) and eff.waking > 0 then
			local t = eff.src:getTalentFromId(self.T_RESTLESS_NIGHT)
			t.doRestlessNight(eff.src, self, eff.waking)
		end
		if eff.particle then
			self:removeParticles(eff.particle)
		end
	end,
}

newEffect{
	name = "SLUMBER", image = "talents/slumber.png",
	desc = "Slumber",
	kr_name = "숙면",
	long_desc = function(self, eff) return ("깊은 잠 : 모든 행동 불가능 / %d 만큼 피해를 입을 때마다 수면 시간 한 턴씩 단축"):format(eff.power) end,
	type = "mental",
	subtype = { sleep=true },
	status = "detrimental",
	parameters = { power=1, insomnia=1, waking=0 },
	on_gain = function(self, err) return "#Target1# 깊이 잠들었습니다.", "+숙면" end,
	on_lose = function(self, err) return "#Target1# 깊은 잠에서 깼습니다.", "-숙면" end,
	on_timeout = function(self, eff)
		local dream_prison = false
		if eff.src and eff.src.isTalentActive and eff.src:isTalentActive(eff.src.T_DREAM_PRISON) then
			local t = eff.src:getTalentFromId(eff.src.T_DREAM_PRISON)
			if core.fov.distance(self.x, self.y, eff.src.x, eff.src.y) <= eff.src:getTalentRange(t) then
				dream_prison = true
			end
		end
		if dream_prison then
			eff.dur = eff.dur + 1
			if not eff.particle then
				if core.shader.active(4) then
					eff.particle = self:addParticles(Particles.new("shader_shield", 1, {img="shield2", size_factor=1.25}, {type="shield", time_factor=6000, aadjust=5, color={0, 1, 1}}))
				else
					eff.particle = self:addParticles(Particles.new("generic_shield", 1, {r=0, g=1, b=1, a=1}))
				end
			end
		elseif eff.particle and not dream_prison then
			self:removeParticles(eff.particle)
		end
		-- Incriment Insomnia Duration
		if not self:attr("lucid_dreamer") then
			self:setEffect(self.EFF_INSOMNIA, 1, {power=eff.insomnia})
		end
	end,
	activate = function(self, eff)
		eff.sid = self:addTemporaryValue("sleep", 1)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("sleep", eff.sid)
		if not self:attr("sleep") and not self.dead and game.level:hasEntity(self) and eff.waking > 0 then
			local t = eff.src:getTalentFromId(self.T_RESTLESS_NIGHT)
			t.doRestlessNight(eff.src, self, eff.waking)
		end
		if eff.particle then
			self:removeParticles(eff.particle)
		end
	end,
}

newEffect{
	name = "NIGHTMARE", image = "talents/nightmare.png",
	desc = "Nightmare",
	kr_name = "악몽",
	long_desc = function(self, eff) return ("악몽 : 매 턴마다 정신 피해 %0.2f / 모든 행동 불가능 / %d 만큼 피해를 입을 때마다 수면 시간 한 턴씩 단축"):format(eff.dam, eff.power) end,
	type = "mental",
	subtype = { nightmare=true, sleep=true },
	status = "detrimental",
	parameters = { power=1, dam=0, insomnia=1, waking=0},
	on_gain = function(self, err) return "#F53CBE##Target1# 악몽에 빠졌습니다.", "+악몽" end,
	on_lose = function(self, err) return "#Target1# 악몽에서 벗어났습니다.", "-악몽" end,
	on_timeout = function(self, eff)
		local dream_prison = false
		if eff.src and eff.src.isTalentActive and eff.src:isTalentActive(eff.src.T_DREAM_PRISON) then
			local t = eff.src:getTalentFromId(eff.src.T_DREAM_PRISON)
			if core.fov.distance(self.x, self.y, eff.src.x, eff.src.y) <= eff.src:getTalentRange(t) then
				dream_prison = true
			end
		end
		if dream_prison then
			eff.dur = eff.dur + 1
			if not eff.particle then
				if core.shader.active(4) then
					eff.particle = self:addParticles(Particles.new("shader_shield", 1, {img="shield2", size_factor=1.25}, {type="shield", aadjust=5, color={0, 1, 1}}))
				else
					eff.particle = self:addParticles(Particles.new("generic_shield", 1, {r=0, g=1, b=1, a=1}))
				end
			end
		else
			-- Store the power for later
			local real_power = eff.temp_power or eff.power
			-- Temporarily spike the temp_power so the nightmare doesn't break it
			eff.temp_power = 10000
			DamageType:get(DamageType.DARKNESS).projector(eff.src or self, self.x, self.y, DamageType.DARKNESS, eff.dam)
			-- Set the power back to its baseline
			eff.temp_power = real_power
		end
		if eff.particle and not dream_prison then
			self:removeParticles(eff.particle)
		end
		-- Incriment Insomnia Duration
		if not self:attr("lucid_dreamer") then
			self:setEffect(self.EFF_INSOMNIA, 1, {power=eff.insomnia})
		end
	end,
	activate = function(self, eff)
		eff.sid = self:addTemporaryValue("sleep", 1)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("sleep", eff.sid)
		if not self:attr("sleep") and not self.dead and game.level:hasEntity(self) and eff.waking > 0 then
			local t = eff.src:getTalentFromId(self.T_RESTLESS_NIGHT)
			t.doRestlessNight(eff.src, self, eff.waking)
		end
		if eff.particle then
			self:removeParticles(eff.particle)
		end
	end,
}

newEffect{
	name = "RESTLESS_NIGHT", image = "talents/restless_night.png",
	desc = "Restless Night",
	kr_name = "쉴 수 없는 밤",
	long_desc = function(self, eff) return ("부족한 잠으로 인한 피로 : 매 턴마다 정신 피해 %0.2f"):format(eff.power) end,
	type = "mental",
	subtype = { psionic=true},
	status = "detrimental",
	parameters = { power=1 },
	on_gain = function(self, err) return "#Target1# 쉴 수 없는 밤을 보냈습니다.", "+쉴 수 없는 밤" end,
	on_lose = function(self, err) return "#Target1# 부족한 잠에서 회복되었습니다.", "-쉴 수 없는 밤" end,
	on_merge = function(self, old_eff, new_eff)
		-- Merge the flames!
		local olddam = old_eff.power * old_eff.dur
		local newdam = new_eff.power * new_eff.dur
		local dur = math.ceil((old_eff.dur + new_eff.dur) / 2)
		old_eff.dur = dur
		old_eff.power = (olddam + newdam) / dur
		return old_eff
	end,
	on_timeout = function(self, eff)
		DamageType:get(DamageType.MIND).projector(eff.src or self, self.x, self.y, DamageType.MIND, eff.power)
	end,
}

newEffect{
	name = "INSOMNIA", image = "effects/insomnia.png",
	desc = "Insomnia",
	kr_name = "불면증",
	long_desc = function(self, eff) return ("잠이 완전히 깸 : 수면 면역 +%d%%"):format(eff.cur_power) end,
	type = "mental",
	subtype = { psionic=true },
	status = "beneficial",
	parameters = { power=0 },
	on_gain = function(self, err) return "#Target1# 불면증에 시달립니다.", "+불면증" end,
	on_lose = function(self, err) return "#Target1# 더이상 불면증에 시달리지 않습니다.", "-불면증" end,
	on_merge = function(self, old_eff, new_eff)
		-- Add the durations on merge
		local dur = old_eff.dur + new_eff.dur
		old_eff.dur = math.min(10, dur)
		old_eff.cur_power = old_eff.power * old_eff.dur
		-- Need to remove and re-add the effect
		self:removeTemporaryValue("sleep_immune", old_eff.sid)
		old_eff.sid = self:addTemporaryValue("sleep_immune", old_eff.cur_power/100)
		return old_eff
	end,
	on_timeout = function(self, eff)
		-- Insomnia only ticks when we're awake
		if self:attr("sleep") and self:attr("sleep") > 0 then
			eff.dur = eff.dur + 1
		else
			-- Deincrement the power
			eff.cur_power = eff.power * eff.dur
			self:removeTemporaryValue("sleep_immune", eff.sid)
			eff.sid = self:addTemporaryValue("sleep_immune", eff.cur_power/100)
		end
	end,
	activate = function(self, eff)
		eff.cur_power = eff.power * eff.dur
		eff.sid = self:addTemporaryValue("sleep_immune", eff.cur_power/100)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("sleep_immune", eff.sid)
	end,
}

newEffect{
	name = "SUNDER_MIND", image = "talents/sunder_mind.png",
	desc = "Sundered Mind",
	kr_name = "정신 붕괴",
	long_desc = function(self, eff) return ("정신 능력 손상 : 정신 내성 -%d"):format(eff.cur_power or eff.power) end,
	type = "mental",
	subtype = { psionic=true },
	status = "detrimental",
	on_gain = function(self, err) return "#Target#의 정신 능력이 손상되었습니다.", "+정신 붕괴" end,
	on_lose = function(self, err) return "#Target1# 감각을 되찾았습니다.", "-정신 붕괴" end,
	parameters = { power=10 },
	on_merge = function(self, old_eff, new_eff)
		self:removeTemporaryValue("combat_mentalresist", old_eff.sunder)
		old_eff.cur_power = old_eff.cur_power + new_eff.power
		old_eff.sunder = self:addTemporaryValue("combat_mentalresist", -old_eff.cur_power)

		old_eff.dur = new_eff.dur
		return old_eff
	end,
	activate = function(self, eff)
		eff.cur_power = eff.power
		eff.sunder = self:addTemporaryValue("combat_mentalresist", -eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_mentalresist", eff.sunder)
	end,
}

newEffect{
	name = "BROKEN_DREAM", image = "effects/broken_dream.png",
	desc = "Broken Dream",
	kr_name = "부서진 꿈",
	long_desc = function(self, eff) return ("'꿈 속 대장간' 에 의해 부서진 꿈 : 정신 내성 -%d / 주문 시전 성공 확률 -%d%%"):format(eff.power, eff.power) end,
	type = "mental",
	subtype = { psionic=true, morale=true },
	status = "detrimental",
	on_gain = function(self, err) return "#Target#의 꿈이 부서졌습니다.", "+부서진 꿈" end,
	on_lose = function(self, err) return "#Target1# 희망을 되찾았습니다.", "-부서진 꿈" end,
	parameters = { power=10 },
	activate = function(self, eff)
		eff.silence = self:addTemporaryValue("spell_failure", eff.power)
		eff.sunder = self:addTemporaryValue("combat_mentalresist", -eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("spell_failure", eff.silence)
		self:removeTemporaryValue("combat_mentalresist", eff.sunder)
	end,
}

newEffect{
	name = "FORGE_SHIELD", image = "talents/block.png",
	desc = "Forge Shield",
	kr_name = "방패 연마",
	long_desc = function(self, eff)
		local e_string = ""
		if eff.number == 1 then
			e_string = DamageType.dam_def[next(eff.d_types)].kr_name or DamageType.dam_def[next(eff.d_types)].name
		else
			local list = table.keys(eff.d_types)
			for i = 1, #list do
				list[i] = DamageType.dam_def[list[i]].kr_name or DamageType.dam_def[list[i]].name
			end
			e_string = table.concat(list, ", ")
		end
		local function tchelper(first, rest)
		  return first:upper()..rest:lower()
		end
		return ("다음 번에 막을 수 있는 속성의 공격을 받으면, 피해 %d 흡수 / 현재 막기 속성 : %s"):format(eff.power, e_string:gsub("(%a)([%w_']*)", tchelper))
	end,
	type = "mental",
	subtype = { psionic=true },
	status = "beneficial",
	parameters = { power=1 },
	on_gain = function(self, eff) return nil, nil end,
	on_lose = function(self, eff) return nil, nil end,
		damage_feedback = function(self, eff, src, value)
		if eff.particle and eff.particle._shader and eff.particle._shader.shad and src and src.x and src.y then
			local r = -rng.float(0.2, 0.4)
			local a = math.atan2(src.y - self.y, src.x - self.x)
			eff.particle._shader:setUniform("impact", {math.cos(a) * r, math.sin(a) * r})
			eff.particle._shader:setUniform("impact_tick", core.game.getTime())
		end
	end,
	activate = function(self, eff)
		if core.shader.active(4) then
			eff.particle = self:addParticles(Particles.new("shader_shield", 1, {size_factor=1.1}, {type="shield", time_factor=-8000, llpow=1, aadjust=7, color={1, 0.5, 0}}))
		else
			eff.particle = self:addParticles(Particles.new("generic_shield", 1, {r=1, g=0.5, b=0.0, a=1}))
		end
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
	end,
}

newEffect{
	name = "DRACONIC_WILL", image = "talents/draconic_will.png",
	desc = "Draconic Will",
	kr_name = "용인의 의지",
	long_desc = function(self, eff) return "모든 나쁜 상태이상 효과 면역" end,
	type = "mental",
	subtype = { nature=true },
	status = "beneficial",
	on_gain = function(self, err) return "#Target#의 피부가 단단해졌습니다.", "+용인의 의지" end,
	on_lose = function(self, err) return "#Target#의 피부가 평범하게 되돌아왔습니다.", "-용인의 의지" end,
	parameters = { },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "negative_status_effect_immune", 1)
	end,
}

newEffect{
	name = "HIDDEN_RESOURCES", image = "talents/hidden_resources.png",
	desc = "Hidden Resources",
	kr_name = "숨겨진 원천력",
	long_desc = function(self, eff) return "모든 원천력을 소모하지 않음" end,
	type = "mental",
	subtype = { willpower=true },
	status = "beneficial",
	on_gain = function(self, err) return "#Target1# 집중하기 시작했습니다.", "+숨겨진 원천력" end,
	on_lose = function(self, err) return "#Target#의 집중이 조금 흩어졌습니다.", "-숨겨진 원천력" end,
	parameters = { },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "force_talent_ignore_ressources", 1)
	end,
}

newEffect{
	name = "SPELL_FEEDBACK", image = "talents/spell_feedback.png",
	desc = "Spell Feedback",
	kr_name = "주문 반작용",
	long_desc = function(self, eff) return ("%d%% 확률로 주문 시전 실패"):format(eff.power) end,
	type = "mental",
	subtype = { nature=true },
	status = "detrimental",
	on_gain = function(self, err) return "#Target1# 반마법의 힘으로 둘러싸였습니다.", "+주문 반작용" end,
	on_lose = function(self, err) return "#Target3# 둘러싼 반마법의 힘이 사라졌습니다.", "-주문 반작용" end,
	parameters = { power=40 },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "spell_failure", eff.power)
	end,
}

newEffect{
	name = "MIND_PARASITE", image = "talents/mind_parasite.png",
	desc = "Mind Parasite",
	kr_name = "정신의 기생충",
	long_desc = function(self, eff) return ("정신의 기생충으로 인한 괴로움 : 기술 사용시 %d%% 확률로 %d 가지의 임의의 기술이 %d 턴간 재사용 대기상태로 변함"):format(eff.chance, eff.nb, eff.turns) end,
	type = "mental",
	subtype = { nature=true, mind=true },
	status = "detrimental",
	on_gain = function(self, err) return "#Target1# 정신의 기생충에게 감염되었습니다.", "+정신의 기생충" end,
	on_lose = function(self, err) return "#Target1# 정신의 기생충으로부터 벗어났습니다.", "-정신의 기생충" end,
	parameters = { chance=40, nb=1, turns=2 },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "random_talent_cooldown_on_use", eff.chance)
		self:effectTemporaryValue(eff, "random_talent_cooldown_on_use_nb", eff.nb)
		self:effectTemporaryValue(eff, "random_talent_cooldown_on_use_turns", eff.turns)
	end,
}