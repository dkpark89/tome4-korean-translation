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

local Map = require "engine.Map"

newTalent{
	name = "Psychometry",
	kr_display_name = "사이코메트리",
	type = {"psionic/mentalism", 1},
	points = 5, 
	require = psi_wil_req1,
	mode = "passive",
	getPsychometryCap = function(self, t) return self:getTalentLevelRaw(t)/2 end,
	updatePsychometryCount = function(self, t)
		-- Update psychometry power
		local psychometry_count = 0
		for inven_id, inven in pairs(self.inven) do
			if inven.worn then
				for item, o in ipairs(inven) do
					if o and item and o.power_source and (o.power_source.psionic or o.power_source.nature or o.power_source.antimagic) then
						psychometry_count = psychometry_count + math.min((o.material_level or 1) / 2, t.getPsychometryCap(self, t))
					end
				end
			end
		end
		self:attr("psychometry_power", psychometry_count, true)
	end,
	on_learn = function(self, t)
		t.updatePsychometryCount(self, t)
	end,	
	on_unlearn = function(self, t)
		if not self:knowTalent(t) then
			self.psychometry_power = nil
		else
			t.updatePsychometryCount(self, t)
		end
	end,
	info = function(self, t)
		local max = t.getPsychometryCap(self, t)
		return ([[염력, 자연의 힘, 반마법 속성의 무기와 공명하여, 물리력과 정신력이 %0.2f 혹은 장비 등급의 절반만큼 상승합니다. (둘 중 낮은 쪽이 적용됩니다)
		이 효과는 모든 종류의 장비에 적용되며, 누적됩니다.]]):format(max)
	end,
}

newTalent{
	name = "Mental Shielding",
	kr_display_name = "정신 방어",
	type = {"psionic/mentalism", 2},
	points = 5,
	require = psi_wil_req2,
	psi = 15,
	cooldown = function(self, t) return math.max(10, 20 - self:getTalentLevelRaw(t) * 2) end,
	tactical = { BUFF = 1, CURE = function(self, t, target)
		local nb = 0
		for eff_id, p in pairs(self.tmp) do
			local e = self.tempeffect_def[eff_id]
			if e.status == "detrimental" and e.type == "mental" then
				nb = nb + 1
			end
		end
		return nb
	end,},
	no_energy = true,
	getRemoveCount = function(self, t) return math.ceil(self:getTalentLevel(t)) end,
	action = function(self, t)
		local effs = {}
		local count = t.getRemoveCount(self, t)

		-- Go through all mental effects
		for eff_id, p in pairs(self.tmp) do
			local e = self.tempeffect_def[eff_id]
			if e.type == "mental" and e.status == "detrimental" then
				effs[#effs+1] = {"effect", eff_id}
			end
		end

		for i = 1, t.getRemoveCount(self, t) do
			if #effs == 0 then break end
			local eff = rng.tableRemove(effs)

			if eff[1] == "effect" then
				self:removeEffect(eff[2])
				count = count - 1
			end
		end
		
		if count >= 1 then
			self:setEffect(self.EFF_CLEAR_MIND, 6, {power=count})
		end
		
		game.logSeen(self, "%s 마음이 정화되었습니다!", self.name:capitalize())
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		local count = t.getRemoveCount(self, t)
		return ([[마음을 정화하여 최대 %d 개의 정신 상태효과를 제거하고, 6 턴 동안 하나의 정신 상태효과를 추가로 막습니다.
		이 기술은 턴 소모 없이 사용할 수 있습니다.]]):format(count)
	end,
}

newTalent{
	name = "Projection",
	kr_display_name = "투영",
	type = {"psionic/mentalism", 3},
	points = 5, 
	require = psi_wil_req3,
	psi = 20,
	cooldown = function(self, t) return 20 - self:getTalentLevelRaw(t) * 2 end,
	no_npc_use = true, -- this can be changed if the AI is improved.  I don't trust it to be smart enough to leverage this effect.
	getPower = function(self, t) return math.ceil(self:combatTalentMindDamage(t, 5, 40)) end,
	getDuration = function(self, t) return 4 + math.ceil(self:getTalentLevel(t)*2) end,
	action = function(self, t)
		if self:attr("is_psychic_projection") then return true end
		local x, y = util.findFreeGrid(self.x, self.y, 1, true, {[Map.ACTOR]=true})
		if not x then
			game.logPlayer(self, "마음을 형상화할 공간이 부족합니다!")
			return
		end
		
		local m = self:clone{
			no_drops = true,
			faction = self.faction,
			summoner = self, summoner_gain_exp=true,
			summon_time = t.getDuration(self, t),
			ai_target = {actor=nil},
			ai = "summoned", ai_real = "tactical",
			subtype = "ghost", is_psychic_projection = 1,
			name = "Projection of "..self.name,
			desc = [[꼭 유령과 같은 모습입니다.]],
		}
		m:removeAllMOs()
		m.make_escort = nil
		m.on_added_to_level = nil
		m._rst_full = true

		m.energy.value = 0
		m.player = nil
		m.max_life = m.max_life
		m.life = util.bound(m.life, 0, m.max_life)
		m.forceLevelup = function() end
		m.die = nil
		m.on_die = nil
		m.on_acquire_target = nil
		m.seen_by = nil
		m.puuid = nil
		m.on_takehit = nil
		m.can_talk = nil
		m.clone_on_hit = nil
		m.exp_worth = 0
		m.no_inventory_access = true
		m.can_change_level = false
		m.remove_from_party_on_death = true
		for i = 1, 10 do
			m:unlearnTalent(m.T_AMBUSCADE)	-- no recurssive projections
			m:unlearnTalent(m.T_PROJECTION)		
		end
				
		m.can_pass = {pass_wall=70}
		m.no_breath = 1
		m.invisible = (m.invisible or 0) + t.getPower(self, t)/2
		m.see_invisible = (m.see_invisible or 0) + t.getPower(self, t)
		m.see_stealth = (m.see_stealth or 0) + t.getPower(self, t)
		m.lite = 0
		m.infravision = (m.infravision or 0) + 10
		m.avoid_pressure_traps = 1
		
		
		-- Connection to the summoner functions
		local summon_time = t.getDuration(self, t)
		--summoner takes hit
		m.on_takehit = function(self, value, src) self.summoner:takeHit(value, src) return value end
		--pass actors targeting us back to the summoner to prevent super cheese
		m.on_die = function(self)
			local tg = {type="ball", radius=10}
			self:project(tg, self.x, self.y, function(tx, ty)
				local target = game.level.map(tx, ty, Map.ACTOR)
				if target and target.ai_target.actor == self then
					target.ai_target.actor = self.summoner
				end
			end)
		end				
		
		game.zone:addEntity(game.level, m, "actor", x, y)
		game.level.map:particleEmitter(m.x, m.y, 1, "generic_teleport", {rm=0, rM=0, gm=100, gM=180, bm=180, bM=255, am=35, aM=90})
		game:playSoundNear(self, "talents/teleport")
	
		if game.party:hasMember(self) then
			game.party:addMember(m, {
				control="full",
				type = m.type, subtype="ghost",
				title="Projection of "..self.name,
				temporary_level=1,
				orders = {target=true},
				on_control = function(self)
					self.summoner.projection_ai = self.summoner.ai
					self.summoner.ai = "none"
				end,
				on_uncontrol = function(self)
					game:onTickEnd(function() 
						self.summoner.ai = self.summoner.projection_ai
						self.energy.value = 0
						self.summon_time = 0
						game.party:removeMember(self)
						game.level.map:particleEmitter(self.summoner.x, self.summoner.y, 1, "generic_teleport", {rm=0, rM=0, gm=100, gM=180, bm=180, bM=255, am=35, aM=90})
					end)
				end,
			})
		end
		game:onTickEnd(function() 
			game.party:setPlayer(m)
			self:resetCanSeeCache()
		end)
		
		return true
	end,
	info = function(self, t)
		local power = t.getPower(self, t)
		local duration = t.getDuration(self, t)
		return ([[%d 턴 동안 정신을 형상화하여, 일종의 유체이탈을 합니다. 지속시간 동안 투명해지며 (투명 수치 +%d), 은신 감지와 투명체 감지력이 %d 증가합니다. 또한 벽을 넘어다닐 수 있게 되며, 호흡이 불필요해지게 됩니다.
		형상화된 정신이 받는 모든 피해는 육신과 나눠받게 되며, 오직 '유령' 형태의 적만 공격할 수 있습니다. (단, 정신 연결이 걸린 적에게는 정신 속성 공격을 할 수 있습니다)
		육신으로 돌아가려면, 통제의 주도권을 육신에게 넘겨주면 됩니다.]]):format(duration, power/2, power)
	end,
}

newTalent{
	name = "Mind Link",
	kr_display_name = "정신 연결",
	type = {"psionic/mentalism", 4},
	points = 5, 
	require = psi_wil_req4,
	sustain_psi = 50,
	mode = "sustained",
	no_sustain_autoreset = true,
	cooldown = function(self, t) return 52 - self:getTalentLevelRaw(t) * 8 end,
	tactical = { BUFF = 2, ATTACK = {MIND = 2}},
	range = 7,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="hit", range=self:getTalentRange(t), talent=t}
	end,
	getBonusDamage = function(self, t) return self:combatTalentMindDamage(t, 5, 30) end,
	activate = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		local target = game.level.map(x, y, Map.ACTOR)
		if not target or target == self then return end
		
		target:setEffect(target.EFF_MIND_LINK_TARGET, 10, {power=t.getBonusDamage(self, t), src=self, range=self:getTalentRange(t)*2})
		
		game.level.map:particleEmitter(self.x, self.y, 1, "generic_discharge", {rm=0, rM=0, gm=100, gM=180, bm=180, bM=255, am=35, aM=90})
		game.level.map:particleEmitter(target.x, target.y, 1, "generic_discharge", {rm=0, rM=0, gm=100, gM=180, bm=180, bM=255, am=35, aM=90})
		game:playSoundNear(self, "talents/echo")
		
		local ret = {
			target = target,
			esp = self:addTemporaryValue("esp", {[target.type] = 1}),
		}
		
		-- Update for ESP
		game:onTickEnd(function() 
			self:resetCanSeeCache()
		end)
		
		return ret
	end,
	deactivate = function(self, t, p)
		-- Break 'both' mind links if we're projecting
		if self:attr("is_psychic_projection") and self.summoner:isTalentActive(self.summoner.T_MIND_LINK) then
			self.summoner:forceUseTalent(self.summoner.T_MIND_LINK, {ignore_energy=true})
		end
		self:removeTemporaryValue("esp", p.esp)

		return true
	end,
	info = function(self, t)
		local damage = t.getBonusDamage(self, t)
		local range = self:getTalentRange(t) * 2
		return ([[대상과 정신을 공유합니다. 정신이 공유된 동안 대상에게 %d%% 정신 피해를 더 줄 수 있게 되며, 대상의 종족에 대한 텔레파시 능력을 얻을 수 있게 됩니다.
		한번에 하나의 대상만 정신을 공유할 수 있으며, 대상이 사망하거나 %d 칸 이상 멀어지면 공유가 중지됩니다.
		정신 피해 증가량은 정신력 능력치의 영향을 받아 증가합니다.]]):format(damage, range)
	end,
}
