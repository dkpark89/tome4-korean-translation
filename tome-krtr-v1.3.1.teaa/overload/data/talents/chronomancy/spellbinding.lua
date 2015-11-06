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
	name = "Empower",
	kr_name = "강화",
	type = {"chronomancy/spellbinding", 1},
	require = chrono_req_high1,
	points = 5,
	sustain_paradox = 24,
	mode = "sustained",
	no_sustain_autoreset = true,
	cooldown = 10,
	no_npc_use = true,
	allow_temporal_clones = true,
	getPower = function(self, t) return self:combatTalentLimit(t, 1, 0.1, 0.5) end,
	on_pre_use = function(self, t, silent) if self ~= game.player and not self:isTalentActive(t) then return false end return true end,  -- but don't let them cast it
	activate = function(self, t)
		local talent = self:talentDialog(require("mod.dialogs.talents.ChronomancyEmpower").new(self))
		if not talent then return nil end
		
		game:playSoundNear(self, "talents/spell_generic")

		return {
			talent = talent, rest_count = 0
		}
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		local power = t.getPower(self, t) * 100
		local talent = self:isTalentActive(t.id) and self:getTalentFromId(self:isTalentActive(t.id).talent).name or "None"
		return ([[선택한 시공계열 주문을 강화하여, 그 주문을 사용 할때 적용 되는 주문력을 %d%% 만큼 상승시킵니다.
		각각의 주문은 두 개 이상의 주문묶기에 영향을 받을 수 없습니다.
		
		현재 강화된 주문: %s]]):
		format(power, talent)
	end,
}

newTalent{
	name = "Extension",
	kr_nmae = "연장",
	type = {"chronomancy/spellbinding", 1},
	require = chrono_req_high1,
	points = 5,
	sustain_paradox = 24,
	mode = "sustained",
	no_sustain_autoreset = true,
	cooldown = 10,
	no_npc_use = true,
	allow_temporal_clones = true,
	getPower = function(self, t) return self:combatTalentLimit(t, 0.5, 0.05, 0.25) end,
	on_pre_use = function(self, t, silent) if self ~= game.player and not self:isTalentActive(t) then return false end return true end,  -- but don't let them cast it
	activate = function(self, t)
		local talent = self:talentDialog(require("mod.dialogs.talents.ChronomancyExtension").new(self))
		if not talent then return nil end
		
		game:playSoundNear(self, "talents/spell_generic")
				
		return {
			talent = talent, rest_count = 0
		}
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		local power = t.getPower(self, t) * 100
		local talent = self:isTalentActive(t.id) and self:getTalentFromId(self:isTalentActive(t.id).talent).name or "None"
		return ([[선택한 시공 계열 주문을 연장하여, 그 주문의 지속시간을 %d%% 만큼 늘립니다.
		각각의 주문은 두 개 이상의 주문묶기에 영향을 받을 수 없습니다.
		
		현재 연장된 주문: %s]]):
		format(power, talent)
	end,
}

newTalent{
	name = "Matrix",
	kr_name = "거푸집",
	type = {"chronomancy/spellbinding", 1},
	require = chrono_req_high1,
	points = 5,
	sustain_paradox = 24,
	mode = "sustained",
	no_sustain_autoreset = true,
	cooldown = 10,
	no_npc_use = true,
	allow_temporal_clones = true,
	getPower = function(self, t) return self:combatTalentLimit(t, 0.5, 0.05, 0.25) end,
	on_pre_use = function(self, t, silent) if self ~= game.player and not self:isTalentActive(t) then return false end return true end,  -- but don't let them cast it
	activate = function(self, t)
		local talent = self:talentDialog(require("mod.dialogs.talents.ChronomancyMatrix").new(self))
		if not talent then return nil end
		
		game:playSoundNear(self, "talents/spell_generic")
		
		return {
			talent = talent, rest_count = 0
		}
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		local power = t.getPower(self, t) * 100
		local talent = self:isTalentActive(t.id) and self:getTalentFromId(self:isTalentActive(t.id).talent).name or "None"
		return ([[선택한 시공 계열 주문의 재사용 대기 시간을 %d%% 만큼 줄입니다.
		각각의 주문은 두 개 이상의 주문묶기에 영향을 받을 수 없습니다.
		
		현재 거푸집이 짜여진 주문: %s]]):
		format(power, talent)
	end,
}

newTalent{
	name = "Quicken",
	kr_name = "촉진",
	type = {"chronomancy/spellbinding", 1},
	require = chrono_req_high1,
	points = 5,
	sustain_paradox = 24,
	mode = "sustained",
	no_sustain_autoreset = true,
	cooldown = 10,
	no_npc_use = true,  -- so rares don't learn useless talents
	allow_temporal_clones = true,  -- let clones copy it anyway so they can benefit from the effects
	on_pre_use = function(self, t, silent) if self ~= game.player and not self:isTalentActive(t) then return false end return true end,  -- but don't let them cast it
	getPower = function(self, t) return self:combatTalentLimit(t, 1, 0.1, 0.5) end,
	activate = function(self, t)
		local talent = self:talentDialog(require("mod.dialogs.talents.ChronomancyQuicken").new(self))
		if not talent then return nil end
		
		game:playSoundNear(self, "talents/spell_generic")
				
		return {
			talent = talent, rest_count = 0
		}
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		local power = t.getPower(self, t) * 100
		local talent = self:isTalentActive(t.id) and self:getTalentFromId(self:isTalentActive(t.id).talent).name or "None"
		return ([[선택한 시공 계열 주문의 시전 속도를 %d%% 만큼 상승 시킵니다.
		각각의 주문은 두 개 이상의 주문묶기에 영향을 받을 수 없습니다.
		
		현재 촉진된 주문: %s]]):
		format(power, talent)
	end,
}
