-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2015 Nicolas Casalini
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

-- EDGE TODO: Particles, Timed Effect Particles

newTalent{
	name = "Precognition",
	kr_name = "예지",
	type = {"chronomancy/chronomancy",1},
	require = chrono_req1,
	points = 5,
	paradox = function (self, t) return getParadoxCost(self, t, 10) end,
	cooldown = 20,
	no_npc_use = true,
	getDuration = function(self, t) return getExtensionModifier(self, t, math.floor(self:combatTalentScale(t, 2, 10))) end,
	range = function(self, t) return 10 + math.floor(self:combatTalentScale(t, 2, 14)) end,
	action = function(self, t)
		-- Foresight bonuses
		local defense = 0
		local crits = 0
		if self:knowTalent(self.T_FORESIGHT) then
			defense = self:callTalent(self.T_FORESIGHT, "getDefense")
			crits = self:callTalent(self.T_FORESIGHT, "getCritDefense")
		end
		
		self:setEffect(self.EFF_PRECOGNITION, t.getDuration(self, t), {range=self:getTalentRange(t), actor=1, traps=1, defense=defense, crits=crits})
		
		return true
	end,
	info = function(self, t)
		local range = self:getTalentRange(t)
		local duration = t.getDuration(self, t)
		return ([[당신은 미래를 들여다 보아, %d 칸 범위 내의 있는 존재들과 함정들을 %d 턴 동안 감지합니다.
		만약 당신이 예견을 알고 있다면, 당신은 예지가 활성화 되어 있는 동안 회피율과 치명타 피해 무시 확율을 추가로 얻습니다(예견의 추가량 만큼). ]]):format(range, duration)
	end,
}

newTalent{
	name = "Foresight",
	kr_name = "예견",
	type = {"chronomancy/chronomancy",2},
	mode = "passive",
	require = chrono_req2,
	points = 5,
	getDefense = function(self, t) return self:combatTalentStatDamage(t, "mag", 10, 50) end,
	getCritDefense = function(self, t) return self:combatTalentStatDamage(t, "mag", 2, 10) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "combat_def", t.getDefense(self, t))
		self:talentTemporaryValue(p, "ignore_direct_crits", t.getCritDefense(self, t))
	end,
	callbackOnStatChange = function(self, t, stat, v)
		if stat == self.STAT_MAG then
			self:updateTalentPassives(t)
		end
	end,
	info = function(self, t)
		local defense = t.getDefense(self, t)
		local crits = t.getCritDefense(self, t)
		return ([[%d 회피율과 %d%% 만큼의 치명타 피해 무시 확율을 얻습니다. 
		당신이 예지나 시간선 관측 기술을 사용했을 때의 추가량은 이 수치만큼 한 번 더 더해집니다. 
		이 추가량은 당신의 마법 능력치에 비례합니다.]]):
		format(defense, crits)
	end,
}

newTalent{
	name = "Contingency",
	kr_name = "긴급",
	type = {"chronomancy/chronomancy", 3},
	require = chrono_req3,
	points = 5,
	sustain_paradox = 36,
	mode = "sustained",
	no_sustain_autoreset = true,
	cooldown = 50,
	getTrigger= function(self, t) return self:combatTalentScale(t, 0.25, 0.45, 0.6) end,
	tactical = { DEFEND = 2 },
	no_npc_use = true,  -- so rares don't learn useless talents
	allow_temporal_clones = true,  -- let clones copy it anyway so they can benefit from the effects
	on_pre_use = function(self, t, silent) if self ~= game.player and not self:isTalentActive(t) then return false end return true end,  -- but don't let them cast it
	callbackOnHit = function(self, t, cb, src)
		if src == self then return cb.value end
	
		local p = self:isTalentActive(t.id)
		local life_after = self.life - cb.value
		local cont_trigger = self.max_life * t.getTrigger(self, t)
		
		-- Cast our contingent spell
		if p and p.rest_count <= 0 and cont_trigger > life_after then
			local cont_t = p.talent
			local cont_id = self:getTalentFromId(cont_t)
			local t_level = math.min(self:getTalentLevel(t), self:getTalentLevel(cont_t))
			
			-- Make sure we still know the talent and that the pre-use conditions apply
			if t_level == 0 or not self:knowTalent(cont_id) or not self:preUseTalent(cont_id, true, true) then
				game.logPlayer(self, "#LIGHT_RED#Your Contingency has failed to cast %s!", self:getTalentFromId(cont_t).name)
			else
				game.logPlayer(self, "#STEEL_BLUE#Your Contingency triggered %s!", self:getTalentFromId(cont_t).name)
				p.rest_count = self:getTalentCooldown(t)
				game:onTickEnd(function()
					if not self.dead then
						self:forceUseTalent(cont_t, {ignore_ressources=true, ignore_cd=true, ignore_energy=true, force_target=self, force_level=t_level})
					end
				end)
			end
		end
		
		return cb.value
	end,
	callbackOnActBase = function(self, t)
		local p = self:isTalentActive(t.id)
		if p.rest_count > 0 then p.rest_count = p.rest_count - 1 end
	end,
	iconOverlay = function(self, t, p)
		local val = p.rest_count or 0
		if val <= 0 then return "" end
		local fnt = "buff_font"
		return tostring(math.ceil(val)), fnt
	end,
	activate = function(self, t)
		local talent = self:talentDialog(require("mod.dialogs.talents.ChronomancyContingency").new(self))
		if not talent then return nil end

		local ret = {
			talent = talent, rest_count = 0
		}
		
		if core.shader.active(4) then
			ret.particle = self:addParticles(Particles.new("shader_shield", 1, {size_factor=1.2, img="runicshield_teal"}, {type="runicshield", shieldIntensity=0.10, ellipsoidalFactor=1, scrollingSpeed=1, time_factor=12000, bubbleColor={0.5, 1, 0.8, 0.2}, auraColor={0.5, 1, 0.8, 0.5}}))
		end

		return ret
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		return true
	end,
	info = function(self, t)
		local trigger = t.getTrigger(self, t) * 100
		local cooldown = self:getTalentCooldown(t)
		local talent = self:isTalentActive(t.id) and self:getTalentFromId(self:isTalentActive(t.id).talent).name or "None"
		return ([[당신에게만 영향을 끼치고 목표가 필요하지 않은 마법을 하나 고릅니다. 만약 당신이 당신의 생명력을 %d%% 아래로 떨어트리는 공격을 받는다면 선택 된 마법이 자동으로 시전 됩니다.
		선택 된 마법은 재사용 대기 시간 중에서도 발동이 되며, 턴이나 자원을 소모하지 않고, 기술 레벨은 긴급이나 그 마법의 레벨 중 낮은 쪽으로 선택 됩니다.
		이 효과는 매 %d 턴마다 한번만 일어날 수 있으며 피해를 받은 후에 발동 됩니다.
		
		현재 긴급 마법: %s]]):
		format(trigger, cooldown, talent)
	end,
}

newTalent{
	name = "See the Threads",
	kr_name = "시간선 관측",
	type = {"chronomancy/chronomancy", 4},
	require = chrono_req4,
	points = 5,
	paradox = function (self, t) return getParadoxCost(self, t, 24) end,
	cooldown = 50,
	no_npc_use = true,  -- so rares don't learn useless talents
	getDuration = function(self, t) return getExtensionModifier(self, t, math.floor(self:combatTalentScale(t, 4, 16))) end,
	on_pre_use = function(self, t, silent)
		if checkTimeline(self) then
			if not silent then
				game.logPlayer(self, "이 기술을 사용하기에는 시간선이 너무 불안정 합니다.")
			end
			return false
		end
		if game.level and game.level.data and game.level.data.see_the_threads_done then
			if not silent then
				game.logPlayer(self, "당신은 당신이 할 수 있는 만큼 모두 관측하였습니다.")
			end
			return false
		end
		return true
	end,
	action = function(self, t)
		-- Foresight Bonuses
		local defense = 0
		local crits = 0
		if self:knowTalent(self.T_FORESIGHT) then
			defense = self:callTalent(self.T_FORESIGHT, "getDefense")
			crits = self:callTalent(self.T_FORESIGHT, "getCritDefense")
		end
		
		if game.level and game.level.data then
			game.level.data.see_the_threads_done = true
		end
		
		self:setEffect(self.EFF_SEE_THREADS, t.getDuration(self, t), {defense=defense, crits=crits})
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		return ([[당신은 세 가지의 미래를 들여다 보아, 그것들을 %d 턴 동안 탐험 할 수 있습니다. 효과가 끝났을 때, 당신은 세 가지의 미래 중 현재가 되고 싶은 미래를 선택합니다. 
		만약 당신이 예견을 알고 있다면 시간선 관측이 유지 되는 동안 추가적인 회피율과 치명타 피해 무시 확율을 얻습니다. 
		이 마법은 시간선을 나눕니다. 이 마법이 유지되는 동안 다른 시간선을 나누려는 마법은 실패 할 것입니다.
		만약 당신이 미래의 시간선에서 죽음을 경험한다면 당신은 시간선을 되감아 이 마법을 시전 하였을 때로 되돌아 온 후, 효과를 끝냅니다.
		이 마법은 한 지역 레벨에서 한 번만 사용 될 수 있습니다.]])
		:format(duration)
	end,
}
