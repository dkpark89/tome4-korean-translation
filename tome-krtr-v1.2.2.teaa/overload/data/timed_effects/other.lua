-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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
local Combat = require "mod.class.interface.Combat"

newEffect{
	name = "FLASH_SHIELD", image = "talents/flash_of_the_blade.png",
	desc = "Protected by the Sun",
	kr_desc = "태양의 보호",
	long_desc = function(self, eff) return "태양으로부터 잠시 모든 피해 면역 부여." end,
	type = "other",
	subtype = { },
	status = "beneficial",
	on_gain = function(self, err) return "#Target#의 주변이 광휘의 보호막으로 둘러싸였습니다!", "+신성 보호막" end,
	parameters = {},
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "cancel_damage_chance", 100)
	end,
	deactivate = function(self, eff)

	end,
}

-- type other because this is a core defensive mechanic in debuff form, it should not interact with saves
newEffect{
	name = "ABSORPTION_STRIKE", image = "talents/absorption_strike.png",
	desc = "Absorption Strike",
	kr_desc = "타격 흡수",
	long_desc = function(self, eff) return ("대상은 빛을 빼앗김 : 빛 속성 저항 %d%% 감소 / 공격력 %d%% 감소."):format(eff.power, eff.numb) end,
	type = "other",
	subtype = { sun=true, },
	status = "detrimental",
	parameters = { power = 10, numb = 1 },
	on_gain = function(self, err) return "#Target1# 빛을 빼았겼습니다!", "+타격 흡수" end,
	on_lose = function(self, err) return "#Target#의 빛이 되돌아왔습니다.", "-타격 흡수" end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "resists", {[DamageType.LIGHT]=-eff.power})
		self:effectTemporaryValue(eff, "numbed", eff.numb)
	end,
}

-- Design:  Temporary immobility in exchange for a large stat buff.
newEffect{
	name = "TREE_OF_LIFE", image = "shockbolt/object/artifact/tree_of_life.png",
	desc = "You have taken root!",
	kr_desc = "뿌리 내리기",
	long_desc = function(self, eff) return "지면에 뿌리를 내려 자연과 하나가 됨 : 생명력 향상 / 방어도 향상 / 방어 효율 향상 / 이동할 수 없음." end,
	type = "other",
	subtype = { nature=true },
	--status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#LIGHT_BLUE##Target1# 뿌리를 내렸습니다.", "+속박" end,
	on_lose = function(self, err) return "#LIGHT_BLUE##Target#의 뿌리가 사라졌습니다.", "-속박" end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "never_move", 1)
		self:effectTemporaryValue(eff, "max_life", 300)
		self:effectTemporaryValue(eff, "combat_armor", 20)
		self:effectTemporaryValue(eff, "combat_armor_hardiness", 20)
		
		self.replace_display = mod.class.Actor.new{
			image="invis.png", 
			add_mos = {{image = "npc/giant_treant_wrathroot.png", 
			display_y = -1, 
			display_h = 2}},
        }
		
		self:removeAllMOs()
		game.level.map:updateMap(self.x, self.y)

	end,
	deactivate = function(self, eff)
		self.replace_display = nil
		self:removeAllMOs()
		game.level.map:updateMap(self.x, self.y)
	end,
}

newEffect{
	name = "INFUSION_COOLDOWN", image = "effects/infusion_cooldown.png",
	desc = "Infusion Saturation",
	kr_desc = "주입 포화",
	long_desc = function(self, eff) return ("주입 능력을 많이 사용할수록, 사용한 주입물의 재사용 대기시간이 길어짐 (+%d 턴)"):format(eff.power) end,
	type = "other",
	subtype = { infusion=true },
	status = "detrimental",
	no_stop_enter_worlmap = true, no_stop_resting = true,
	parameters = { power=1 },
	on_merge = function(self, old_eff, new_eff)
		old_eff.dur = new_eff.dur
		old_eff.power = old_eff.power + new_eff.power
		return old_eff
	end,
}

newEffect{
	name = "RUNE_COOLDOWN", image = "effects/rune_cooldown.png",
	desc = "Runic Saturation",
	kr_desc = "룬 포화",
	long_desc = function(self, eff) return ("룬을 많이 사용할수록, 사용한 룬의 재사용 대기시간이 길어짐 (+%d 턴)"):format(eff.power) end,
	type = "other",
	subtype = { rune=true },
	status = "detrimental",
	no_stop_enter_worlmap = true, no_stop_resting = true,
	parameters = { power=1 },
	on_merge = function(self, old_eff, new_eff)
		old_eff.dur = new_eff.dur
		old_eff.power = old_eff.power + new_eff.power
		return old_eff
	end,
}

newEffect{
	name = "TAINT_COOLDOWN", image = "effects/tainted_cooldown.png",
	desc = "Tainted",
	kr_desc = "감염",
	long_desc = function(self, eff) return ("감염을 많이 사용할수록, 사용한 감염의 재사용 대기시간이 길어짐 (+%d 턴)"):format(eff.power) end,
	type = "other",
	subtype = { taint=true },
	status = "detrimental",
	no_stop_enter_worlmap = true, no_stop_resting = true,
	parameters = { power=1 },
	on_merge = function(self, old_eff, new_eff)
		old_eff.dur = new_eff.dur
		old_eff.power = old_eff.power + new_eff.power
		return old_eff
	end,
}

newEffect{
	name = "TIME_PRISON", image = "talents/time_prison.png",
	desc = "Time Prison",
	kr_desc = "시간의 감옥",
	long_desc = function(self, eff) return "시간의 흐름에서 대상 제거 : 행동 불가능 / 모든 피해 완전 면역 / 이 대상에게는 시간이 흐르지 않음" end,
	type = "other",
	subtype = { time=true },
	status = "detrimental",
	tick_on_timeless = true,
	parameters = {},
	on_gain = function(self, err) return "#Target1# 시간으로부터 지워졌습니다!", "+시간의 감옥" end,
	on_lose = function(self, err) return "#Target1# 보통의 시간으로 돌아왔습니다.", "-시간의 감옥" end,
	activate = function(self, eff)
		eff.iid = self:addTemporaryValue("invulnerable", 1)
		eff.sid = self:addTemporaryValue("time_prison", 1)
		eff.tid = self:addTemporaryValue("no_timeflow", 1)
		eff.imid = self:addTemporaryValue("status_effect_immune", 1)
		if core.shader.active(4) then
			eff.particle1 = self:addParticles(Particles.new("shader_ring_rotating", 1, {rotation=0, radius=1.1, img="arcanegeneric"}, {type="circular_flames", ellipsoidalFactor={1,2}, time_factor=3000, noup=2.0}))
			eff.particle1.toback = true
			eff.particle2 = self:addParticles(Particles.new("shader_ring_rotating", 1, {rotation=0, radius=1.1, img="arcanegeneric"}, {type="circular_flames", ellipsoidalFactor={1,2}, time_factor=3000, noup=1.0}))
		else
			eff.particle1 = self:addParticles(Particles.new("time_prison", 1))
		end
		self.energy.value = 0
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("invulnerable", eff.iid)
		self:removeTemporaryValue("time_prison", eff.sid)
		self:removeTemporaryValue("no_timeflow", eff.tid)
		self:removeTemporaryValue("status_effect_immune", eff.imid)
		if eff.particle1 then self:removeParticles(eff.particle1) end
		if eff.particle2 then self:removeParticles(eff.particle2) end
	end,
}

newEffect{
	name = "TIME_SHIELD", image = "talents/time_shield.png",
	desc = "Time Shield",
	kr_desc = "시간의 보호막",
	long_desc = function(self, eff) return ("시간 왜곡 : 피해를 흡수 %d (%d) / 흡수된 피해는 미래로 보냄 / 새로운 상태효과 지속시간 -%d%%"):format(self.time_shield_absorb, eff.power, eff.time_reducer) end,
	type = "other",
	subtype = { time=true, shield=true },
	status = "beneficial",
	parameters = { power=10, dot_dur=5, time_reducer=20 },
	on_gain = function(self, err) return "#Target# 주변의 시간 구조가 변했습니다.", "+시간의 보호막" end,
	on_lose = function(self, err) return "#Target# 주변의 시간 구조가 안정적으로 되돌아왔습니다.", "-시간의 보호막" end,
	on_aegis = function(self, eff, aegis)
		self.time_shield_absorb = self.time_shield_absorb + eff.power * aegis / 100
		if core.shader.active(4) then
			self:removeParticles(eff.particle)
			eff.particle = self:addParticles(Particles.new("shader_shield", 1, {size_factor=1.3, img="runicshield"}, {type="runicshield", shieldIntensity=0.14, ellipsoidalFactor=1.2, scrollingSpeed=-2, time_factor=4000, bubbleColor={1, 1, 0.3, 1.0}, auraColor={1, 0.8, 0.2, 1}}))
		end		
	end,
	damage_feedback = function(self, eff, src, value)
		if eff.particle and eff.particle._shader and eff.particle._shader.shad and src and src.x and src.y then
			local r = -rng.float(0.2, 0.4)
			local a = math.atan2(src.y - self.y, src.x - self.x)
			eff.particle._shader:setUniform("impact", {math.cos(a) * r, math.sin(a) * r})
			eff.particle._shader:setUniform("impact_tick", core.game.getTime())
		end
	end,
	activate = function(self, eff)
		if self:attr("shield_factor") then eff.power = eff.power * (100 + self:attr("shield_factor")) / 100 end
		if self:attr("shield_dur") then eff.dur = eff.dur + self:attr("shield_dur") end
		eff.durid = self:addTemporaryValue("reduce_detrimental_status_effects_time", eff.time_reducer)
		eff.tmpid = self:addTemporaryValue("time_shield", eff.power)
		--- Warning there can be only one time shield active at once for an actor
		self.time_shield_absorb = eff.power
		self.time_shield_absorb_max = eff.power
		if core.shader.active(4) then
			eff.particle = self:addParticles(Particles.new("shader_shield", 1, {img="shield3"}, {type="shield", shieldIntensity=0.1, horizontalScrollingSpeed=-0.2, verticalScrollingSpeed=-1, time_factor=2000, color={1, 1, 0.3}}))
		else
			eff.particle = self:addParticles(Particles.new("time_shield_bubble", 1))
		end
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("reduce_detrimental_status_effects_time", eff.durid)

		self:removeParticles(eff.particle)
		
		-- Time shield ends, setup a restoration field if needed
		if eff.power - self.time_shield_absorb > 0 then
			local val = (eff.power - self.time_shield_absorb) / eff.dot_dur / 2
			if self:attr("shield_factor") then val = val * (100 + self:attr("shield_factor")) / 100 end
			print("Time shield restoration field", eff.power - self.time_shield_absorb, val)
			self:setEffect(self.EFF_TIME_DOT, eff.dot_dur, {power=val})
		end

		self:removeTemporaryValue("time_shield", eff.tmpid)
		self.time_shield_absorb = nil
		self.time_shield_absorb_max = 0
	end,
}

newEffect{
	name = "TIME_DOT",
	desc = "Temporal Restoration Field",
	kr_desc = "시간 회복막",
	long_desc = function(self, eff) return ("시간 왜곡으로 회복막 생성 : %d 턴 동안 매 턴마다 치료 효과"):format(eff.power) end,
	type = "other",
	subtype = { time=true },
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "강력한 시간 변화의 힘으로 #target#에게 회복막이 생성되었습니다.", "+시간 회복막" end,
	on_lose = function(self, err) return "#Target# 주위의 시간 구조가 정상적으로 돌아왔습니다.", "-시간 회복막" end,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("time_shield", 1))
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
	end,
	on_timeout = function(self, eff)
		self:heal(eff.power, eff)
	end,
}

newEffect{
	name = "GOLEM_OFS",
	desc = "Golem out of sight",
	kr_desc = "시야를 벗어난 골렘",
	long_desc = function(self, eff) return "골렘이 연금술사의 시야에서 벗어나, 직접적인 제어가 곧 불가능해집니다!" end,
	type = "other",
	subtype = { miscellaneous=true },
	status = "detrimental",
	parameters = { },
	on_gain = function(self, err) return "#LIGHT_RED##Target1# 주인의 시야 밖으로 벗어나, 직접적인 제어가 곧 끊어집니다!", "+시야를 벗어난 골렘" end,
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
	end,
	on_timeout = function(self, eff)
		if game.player ~= self then return true end

		if eff.dur <= 1 then
			game:onTickEnd(function()
				game.logPlayer(self, "#LIGHT_RED#오랫동안 골렘이 시야 내에서 보이지 않아, 직접적인 제어가 끊어졌습니다!")
				game.player:runStop("시야를 벗어난 골렘")
				game.player:restStop("시야를 벗어난 골렘")
				game.party:setPlayer(self.summoner)
			end)
		end
	end,
}

newEffect{
	name = "AMBUSCADE_OFS", image = "talents/ambuscade.png",
	desc = "Shadow out of sight",
	kr_desc = "시야를 벗어난 그림자",
	long_desc = function(self, eff) return "그림자가 주인의 시야에서 벗어나, 직접적인 제어가 곧 불가능해집니다!" end,
	type = "other",
	subtype = { miscellaneous=true },
	status = "detrimental",
	parameters = { },
	on_gain = function(self, err) return "#LIGHT_RED##Target1# 주인의 시야 밖으로 벗어나, 직접적인 제어가 곧 끊어집니다!", "+시야 벗어남" end,
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
	end,
	on_timeout = function(self, eff)
		if game.player ~= self then return true end

		if eff.dur <= 1 then
			game:onTickEnd(function()
				game.logPlayer(self, "#LIGHT_RED#오랫동안 그림자가 시야 내에서 보이지 않아, 직접적인 제어가 끊어졌습니다!")
				game.player:runStop("시야를 벗어난 그림자")
				game.player:restStop("시야를 벗어난 그림자")
				game.party:setPlayer(self.summoner)
			end)
		end
	end,
}

newEffect{ 
	name = "HUSK_OFS", image = "talents/animus_purge.png",
	desc = "Husk out of sight",
	kr_desc = "시야를 벗어난 하수인",
	long_desc = function(self, eff) return "하수인이 주인의 시야에서 벗어나, 직접적인 제어가 곧 불가능해집니다!" end,
	type = "other",
	subtype = { miscellaneous=true },
	status = "detrimental",
	parameters = { },
	on_gain = function(self, err) return "#LIGHT_RED##Target1# 주인의 시야 밖으로 벗어나, 직접적인 제어가 곧 끊어집니다!", "+시야 벗어남" end,
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
	end,
	on_timeout = function(self, eff)
		if game.player ~= self then return true end

		if eff.dur <= 1 then
			game:onTickEnd(function()
				game.logPlayer(self, "#LIGHT_RED#오랫동안 하수인이 시야 내에서 보이지 않아, 직접적인 제어가 끊어졌습니다!")
				game.player:runStop("시야를 벗어난 하수인")
				game.player:restStop("시야를 벗어난 하수인")
				game.party:setPlayer(self.summoner)
				self:die(self)
			end)
		end
	end,
}

newEffect{
	name = "CONTINUUM_DESTABILIZATION",
	desc = "Continuum Destabilization",
	kr_desc = "연속체 불안정화",
	long_desc = function(self, eff) return ("시공간 조작의 영향 : 시공간에 대한 저항 +%d"):format(eff.power) end,
	type = "other",
	subtype = { time=true },
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target#의 가장자리 부분이 조금 희미하게 보입니다.", "+불안정" end,
	on_lose = function(self, err) return "#Target1# 현실에 단단히 자리잡았습니다.", "-불안정" end,
	on_merge = function(self, old_eff, new_eff)
		-- Merge the continuum_destabilization
		local olddam = old_eff.power * old_eff.dur
		local newdam = new_eff.power * new_eff.dur
		local dur = math.ceil((old_eff.dur + new_eff.dur) / 2)
		old_eff.dur = dur
		old_eff.power = (olddam + newdam) / dur
		-- Need to remove and re-add the continuum_destabilization
		self:removeTemporaryValue("continuum_destabilization", old_eff.effid)
		old_eff.effid = self:addTemporaryValue("continuum_destabilization", old_eff.power)
		return old_eff
	end,
	activate = function(self, eff)
		eff.effid = self:addTemporaryValue("continuum_destabilization", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("continuum_destabilization", eff.effid)
	end,
}

newEffect{
	name = "SUMMON_DESTABILIZATION",
	desc = "Summoning Destabilization",
	kr_desc = "불안정한 소환",
	long_desc = function(self, eff) return ("현재 소환수가 많을수록, 새로운 소환을 위해서는 더 많은 시간이 필요 (+%d 턴)"):format(eff.power) end,
	type = "other", -- Type "other" so that nothing can dispel it
	subtype = { miscellaneous=true },
	status = "detrimental",
	parameters = { power=10 },
	on_merge = function(self, old_eff, new_eff)
		-- Merge the destabilizations
		old_eff.dur = new_eff.dur
		old_eff.power = old_eff.power + new_eff.power
		-- Need to remove and re-add the talents CD
		self:removeTemporaryValue("talent_cd_reduction", old_eff.effid)
		old_eff.effid = self:addTemporaryValue("talent_cd_reduction", { [self.T_SUMMON] = -old_eff.power })
		return old_eff
	end,
	activate = function(self, eff)
		eff.effid = self:addTemporaryValue("talent_cd_reduction", { [self.T_SUMMON] = -eff.power })
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("talent_cd_reduction", eff.effid)
	end,
}

newEffect{
	name = "DAMAGE_SMEARING", image = "talents/damage_smearing.png",
	desc = "Damage Smearing",
	kr_desc = "피해 분산",
	long_desc = function(self, eff) return ("현재의 피해를 미래로 보냄"):format(eff.power) end,
	type = "other",
	subtype = { time=true },
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# 주변의 시간 구조가 변했습니다.", "+피해 분산" end,
	on_lose = function(self, err) return "#Target# 주변의 시간 구조가 안정적으로 되돌아왔습니다.", "-피해 분산" end,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("time_shield", 1))
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
	end,
}

newEffect{
	name = "SMEARED",
	desc = "Smeared",
	kr_desc = "분산된 피해",
	long_desc = function(self, eff) return ("분산된 과거의 피해 : 매 턴마다 시간 피해 %0.2f"):format(eff.power) end,
	type = "other",
	subtype = { time=true },
	status = "detrimental",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target1# 분산된 과거의 피해를 받습니다!", "+분산된 피해" end,
	on_lose = function(self, err) return "#Target#에게 전해지던 분산된 과거의 피해가 멈췄습니다.", "-분산된 피해" end,
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
		DamageType:get(DamageType.TEMPORAL).projector(eff.src, self.x, self.y, DamageType.TEMPORAL, eff.power)
	end,
}

newEffect{
	name = "PRECOGNITION", image = "talents/precognition.png",
	desc = "Precognition",
	kr_desc = "예지",
	long_desc = function(self, eff) return "미래 체험 : 효과가 끝날 때까지 사망하지 않았다면, 과거로 되돌아감" end,
	type = "other",
	subtype = { time=true },
	status = "beneficial",
	parameters = { power=10 },
	cancel_on_level_change = function(self, eff)
		game.logPlayer(game.player, "#LIGHT_BLUE#Precognition fizzles and dissipates.")
		game._chronoworlds = nil
	end,
	activate = function(self, eff)
		game:onTickEnd(function()
			game:chronoClone("precognition")
		end)
	end,
	deactivate = function(self, eff)
		game:onTickEnd(function()
			-- Update the shader of the original player
			self:updateMainShader()
			if game._chronoworlds == nil then
				game.logSeen(self, "#LIGHT_RED#주문이 헛나갔습니다.")
				return
			end
			game.logPlayer(game.player, "#LIGHT_BLUE#시공간 연속체를 펼쳐, 이전 상태로 되돌아 갑니다!")
			game:chronoRestore("precognition", true)
			game.player.tmp[self.EFF_PRECOGNITION] = nil
			if game._chronoworlds then game._chronoworlds = nil end
			if game.player:knowTalent(game.player.T_FORESIGHT) then
				local t = game.player:getTalentFromId(game.player.T_FORESIGHT)
				t.do_precog_foresight(game.player, t)
			end
			game.player.energy.value = game.energy_to_act
			game.paused = true
		end)
	end,
}

newEffect{
	name = "SEE_THREADS", image = "talents/see_the_threads.png",
	desc = "See the Threads",
	kr_desc = "시간의 흐름 - 예견",
	long_desc = function(self, eff) return ("세 가지 시간의 흐름 체험 : 종료 후 세 가지 흐름 중에서 원하는 현실을 선택 (현재 체험 : %d)"):format(eff.thread) end,
	type = "other",
	subtype = { time=true },
	status = "beneficial",
	parameters = { power=10 },
	activate = function(self, eff)
		eff.thread = 1
		eff.max_dur = eff.dur
		game:onTickEnd(function()
			game:chronoClone("see_threads_base")
		end)
	end,
	deactivate = function(self, eff)
		game:onTickEnd(function()

			if game._chronoworlds == nil then
				game.logSeen(self, "#LIGHT_RED#시간의 흐름 - 예견 주문이 헛나갔습니다. 현재의 시간이 그대로 유지됩니다.")
				return
			end

			if eff.thread < 3 then
				local worlds = game._chronoworlds

				-- Clone but not the subworlds
				game._chronoworlds = nil
				local clone = game:chronoClone()

				-- Restore the base world and resave it
				game._chronoworlds = worlds
				game:chronoRestore("see_threads_base", true)

				-- Setup next thread
				local eff = game.player:hasEffect(game.player.EFF_SEE_THREADS)
				eff.thread = eff.thread + 1
				game.logPlayer(game.player, "#LIGHT_BLUE#시공간 연속체를 펼쳐, 시간이 갈라진 시작점으로 되돌아 갑니다!")

				game._chronoworlds = worlds
				game:chronoClone("see_threads_base")

				-- Add the previous thread
				game._chronoworlds["see_threads_"..(eff.thread-1)] = clone
				game.level.map:particleEmitter(game.player.x, game.player.y, 1, "rewrite_universe")
				return
			else
				game._chronoworlds.see_threads_base = nil
				local chat = Chat.new("chronomancy-see-threads", {name="See the Threads", kr_name="시간의 흐름 예견"}, self, {turns=eff.max_dur})
				chat:invoke()
			end
		end)
	end,
}

newEffect{
	name = "IMMINENT_PARADOX_CLONE",
	desc = "Imminent Paradox Clone",
	kr_desc = "일촉즉발의 모순된 복제",
	long_desc = function(self, eff) return "효과 종료시 과거로 회귀" end,
	type = "other",
	subtype = { time=true },
	status = "detrimental",
	parameters = { power=10 },
	activate = function(self, eff)
			game:onTickEnd(function()
			game:chronoClone("paradox_past")
		end)
	end,
	deactivate = function(self, eff)
		local t = self:getTalentFromId(self.T_PARADOX_CLONE)
		local base = t.getDuration(self, t) - 2
		game:onTickEnd(function()
			if game._chronoworlds == nil then
				game.logSeen(self, "#LIGHT_RED#운명이 바뀌어, 과거로의 회귀가 발생하지 않게 되었습니다.")
				return
			end

			local worlds = game._chronoworlds
			-- save the players health so we can reload it
			local oldplayer = game.player

			-- Clone but not the subworlds
			game._chronoworlds = nil
			local clone = game:chronoClone()
			game._chronoworlds = worlds

			-- Move back in time, but keep the paradox_future world stored
			game:chronoRestore("paradox_past", true)
			game._chronoworlds = game._chronoworlds or {}
			game._chronoworlds["paradox_future"] = clone
			game.logPlayer(self, "#LIGHT_BLUE#과거로 회귀합니다!")
			-- pass health and resources into the new timeline
			game.player.life = oldplayer.life
			for i, r in ipairs(game.player.resources_def) do
				game.player[r.short_name] = oldplayer[r.short_name]
			end

			-- Hack to remove the IMMINENT_PARADOX_CLONE effect in the past
			-- Note that we have to use game.player now since self refers to self from the future!
			game.player.tmp[self.EFF_IMMINENT_PARADOX_CLONE] = nil

			-- Setup the return effect
			game.player:setEffect(self.EFF_PARADOX_CLONE, base, {})
		end)
	end,
}

newEffect{
	name = "PARADOX_CLONE", image = "talents/paradox_clone.png",
	desc = "Paradox Clone",
	kr_desc = "모순된 복제",
	long_desc = function(self, eff) return "과거로 회귀" end,
	type = "other",
	subtype = { time=true },
	status = "detrimental",
	parameters = { power=10 },
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
		-- save the players rescources so we can reload it
		local oldplayer = game.player
		game:onTickEnd(function()
			game:chronoRestore("paradox_future")
			-- Reload the player's health and resources
			game.logPlayer(game.player, "#LIGHT_BLUE#현재로 돌아왔습니다!")
			game.player.life = oldplayer.life
			for i, r in ipairs(game.player.resources_def) do
				game.player[r.short_name] = oldplayer[r.short_name]
			end
		end)
	end,
}

newEffect{
	name = "MILITANT_MIND", image = "talents/militant_mind.png",
	desc = "Militant Mind",
	kr_desc = "투쟁 정신",
	long_desc = function(self, eff) return ("물리력 +%d / 주문력 +%d / 정신력 +%d / 모든 내성 +%d"):format(eff.power, eff.power, eff.power, eff.power) end, --@ 변수 조정
	type = "other",
	subtype = { miscellaneous=true },
	status = "beneficial",
	parameters = { power=10 },
	activate = function(self, eff)
		eff.damid = self:addTemporaryValue("combat_dam", eff.power)
		eff.spellid = self:addTemporaryValue("combat_spellpower", eff.power)
		eff.mindid = self:addTemporaryValue("combat_mindpower", eff.power)
		eff.presid = self:addTemporaryValue("combat_physresist", eff.power)
		eff.sresid = self:addTemporaryValue("combat_spellresist", eff.power)
		eff.mresid = self:addTemporaryValue("combat_mentalresist", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_dam", eff.damid)
		self:removeTemporaryValue("combat_spellpower", eff.spellid)
		self:removeTemporaryValue("combat_mindpower", eff.mindid)
		self:removeTemporaryValue("combat_physresist", eff.presid)
		self:removeTemporaryValue("combat_spellresist", eff.sresid)
		self:removeTemporaryValue("combat_mentalresist", eff.mresid)
	end,
}

newEffect{
	name = "SEVER_LIFELINE", image = "talents/sever_lifeline.png",
	desc = "Sever Lifeline",
	kr_desc = "생명선 절단",
	long_desc = function(self, eff) return ("생명선 절단 : 효과 종료시 시간 피해 %0.2f"):format(eff.power) end,
	type = "other",
	subtype = { time=true },
	status = "detrimental",
	parameters = {power=10000},
	on_gain = function(self, err) return "#Target#의 생명선이 잘렸습니다!", "+생명선 절단" end,
	deactivate = function(self, eff)
		if not eff.src or eff.src.dead then return end
		if not eff.src:hasLOS(self.x, self.y) then return end
		if eff.dur >= 1 then return end
		DamageType:get(DamageType.TEMPORAL).projector(eff.src, self.x, self.y, DamageType.TEMPORAL, eff.power)
	end,
}

newEffect{
	name = "SPACETIME_STABILITY",
	desc = "Spacetime Stability",
	kr_desc = "시공간 안정화",
	long_desc = function(self, eff) return "시전하는 시공 계열 주문이 항상 성공" end,
	type = "other",
	subtype = { time=true },
	status = "beneficial",
	parameters = { power=0.1 },
	on_gain = function(self, err) return "#Target# 주변의 시공간이 안정화됩니다.", "+시공간 안정화" end,
	on_lose = function(self, err) return "#Target# 주변의 시공간 구조가 평범하게 되돌아 왔습니다.", "-시공간 안정화" end,
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "FADE_FROM_TIME", image = "talents/fade_from_time.png",
	desc = "Fade From Time",
	kr_desc = "시간에서 흐려진 자",
	long_desc = function(self, eff) return ("시간의 흐름에서 일부 벗어남 : 공격시 피해량 -%d%% / 전체 저항 +%d%% / 나쁜 상태이상 효과 지속시간 -%d%%"):
	format(math.min(20,eff.dur * 2 + 2), eff.cur_power or eff.power, eff.cur_dur or eff.durred) end,
	type = "other",
	subtype = { time=true },
	status = "beneficial",
	parameters = { power=10 ,durred = 15 },
	on_gain = function(self, err) return "#Target1# 시간의 흐름에서 약간 빠져나갑니다.", "+시간에서 흐려진 자" end,
	on_lose = function(self, err) return "#Target1# 시간의 흐름 속으로 완전히 되돌아 왔습니다.", "-시간에서 흐려진 자" end,
	on_merge = function(self, old_eff, new_eff)
		self:removeTemporaryValue("inc_damage", old_eff.dmgid)
		self:removeTemporaryValue("resists", old_eff.rstid)
		self:removeTemporaryValue("reduce_detrimental_status_effects_time", old_eff.durid)		
		old_eff.cur_power = (new_eff.power)
		old_eff.cur_dur = new_eff.durred
		old_eff.dmgid = self:addTemporaryValue("inc_damage", {all = - old_eff.dur * 2})
		old_eff.rstid = self:addTemporaryValue("resists", {all = old_eff.cur_power})
		old_eff.durid = self:addTemporaryValue("reduce_detrimental_status_effects_time", old_eff.cur_dur)
		old_eff.dur = old_eff.dur
		return old_eff
	end,
	on_timeout = function(self, eff)
		local current = eff.power * eff.dur/10
		local currentdur = eff.durred * eff.dur/10
		self:setEffect(self.EFF_FADE_FROM_TIME, 1, {power = current, durred=currentdur})
	end,
	activate = function(self, eff)
		eff.cur_power = eff.power
		eff.rstid = self:addTemporaryValue("resists", { all = eff.power})
		eff.durid = self:addTemporaryValue("reduce_detrimental_status_effects_time", eff.durred)
		eff.dmgid = self:addTemporaryValue("inc_damage", {all = -20})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("reduce_detrimental_status_effects_time", eff.durid)
		self:removeTemporaryValue("resists", eff.rstid)
		self:removeTemporaryValue("inc_damage", eff.dmgid)
	end,
}

newEffect{
	name = "SHADOW_VEIL", image = "talents/shadow_veil.png",
	desc = "Shadow Veil",
	kr_desc = "그림자의 장막",
	long_desc = function(self, eff) return ("그림자의 장막에게 제어권 넘김 : 나쁜 상태이상 효과에 완전 면역 / 전체 저항 +%d%% / 매 턴마다 %d칸 내의 적에게 순간이동하여 공격 (어둠 피해 %d%%) / 사망하지 않는 한 멈추지 않음 / 제어 불가능"):format(eff.res, eff.range, eff.dam * 100) end,
	type = "other",
	subtype = { darkness=true },
	status = "beneficial",
	parameters = { res=10, dam=1.5, range=5},
	on_gain = function(self, err) return "#Target1# 그림자의 장막으로 둘러싸입니다!", "+습격" end,
	on_lose = function(self, err) return "#Target#의 그림자 장막이 사라졌습니다.", "-습격" end,
	activate = function(self, eff)
		eff.sefid = self:addTemporaryValue("negative_status_effect_immune", 1)
		eff.resid = self:addTemporaryValue("resists", {all=eff.res})
	end,
	on_timeout = function(self, eff)
		local maxdist = self:callTalent(self.T_SHADOW_VEIL,"getBlinkRange")
		self.never_act = true
		repeat
			local acts = {}
			local act

			self:doFOV() -- update actors seen
			for i = 1, #self.fov.actors_dist do
				act = self.fov.actors_dist[i]
				if act and self:reactionToward(act) < 0 and not act.dead and self:isNear(act.x,act.y,maxdist) then
					local sx, sy = util.findFreeGrid(act.x, act.y, 1, true, {[engine.Map.ACTOR]=true})
					if sx then acts[#acts+1] = {act, sx, sy} end
				end
			end
			if #acts == 0 then self.never_act = nil return end

			act = rng.table(acts)
			self:move(act[2], act[3], true)
			game.level.map:particleEmitter(act[2], act[3], 1, "dark")
			self:attackTarget(act[1], DamageType.DARKNESS, eff.dam) -- Attack *and* use energy
		until self.energy.value < 0  -- keep blinking and attacking until out of energy (since on_timeout is only once per turn)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("negative_status_effect_immune", eff.sefid)
		self:removeTemporaryValue("resists", eff.resid)
		self.never_act = nil
	end,
}

newEffect{
	name = "ZERO_GRAVITY", image = "effects/zero_gravity.png",
	desc = "Zero Gravity",
	kr_desc = "무중력",
	no_stop_enter_worlmap = true,
	long_desc = function(self, eff) return ("무중력 : 부유 / 이동 속도 3 배 느려짐 / 물리 공격시 밀어내기 효과 추가 / 최대 소지무게 20 배 증가") end,
	decrease = 0, no_remove = true,
	type = "other",
	subtype = { spacetime=true },
	status = "detrimental",
	zone_wide_effect = true,
	parameters = {},
	on_merge = function(self, old_eff, new_eff)
		return old_eff
	end,
	activate = function(self, eff)
		eff.encumb = self:addTemporaryValue("max_encumber", self:getMaxEncumbrance() * 20),
		self:checkEncumbrance()
		game.logPlayer(self, "#LIGHT_BLUE#무중력인 지역으로 들어섰습니다. 조심하십시오!")
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("max_encumber", eff.encumb)
		self:checkEncumbrance()
	end,
}

newEffect{
	name = "CURSE_OF_CORPSES",
	desc = "Curse of Corpses",
	kr_desc = "시체의 저주", kr_short_desc = "시체",
	short_desc = "Corpses",
	type = "other",
	subtype = { curse=true },
	status = "beneficial",
	no_stop_enter_worlmap = true,
	decrease = 0,
	no_remove = true,
	cancel_on_level_change = true,
	parameters = {Penalty = 1},
	getResistsUndead = function(eff, level) return -2 * level * (eff.Penalty or 1) end,
	getIncDamageUndead = function(level) return 2 + level * 2 end,
	getLckChange = function(eff, level)
		if eff.unlockLevel >= 5 or level <= 2 then return -1 end
		if level <= 3 then return -2 else return -3 end
	end,
	getStrChange = function(level) return level end,
	getMagChange = function(level) return level end,
	getCorpselightRadius = function(level) return math.floor(level + 1) end,
	getReprieveChance = function(level) return Combat:combatLimit(level-4, 100, 35, 0, 50, 5)  end, -- Limit < 100%
	display_desc = function(self, eff) return ([[시체의 저주 %0.1f 단계]]):format(eff.level) end,
	long_desc = function(self, eff)
		local def, level, bonusLevel = self.tempeffect_def[self.EFF_CURSE_OF_CORPSES], eff.level, math.min(eff.unlockLevel, eff.level)

		return ([[죽음의 기운이 주변을 감돌기 시작합니다.
#CRIMSON#불이익  : #WHITE#죽음의 공포 : 언데드에게 받는 공격일 경우, 피해 저항 %+d%%
#CRIMSON#단계 1+ : %s죽음을 극복한 힘 : 언데드 공격시 피해량 %+d%%
#CRIMSON#단계 2+ : %s행운 %+d / 힘 %+d / 마법 %+d
#CRIMSON#단계 3+ : %s시체의 빛 : 적을 살해할 때마다, 적의 시체에서 섬뜩한 빛 발산 (주변 %d 칸 반경)
#CRIMSON#단계 4+ : %s죽음의 집행유예 : 인간형 적 살해시, %d%% 확률로 6 턴간 적의 시체가 동료 구울로 되살아남]]):format(
		def.getResistsUndead(eff, level),
		bonusLevel >= 1 and "#WHITE#" or "#GREY#", def.getIncDamageUndead(math.max(level, 1)),
		bonusLevel >= 2 and "#WHITE#" or "#GREY#", def.getLckChange(eff, math.max(level, 2)), def.getStrChange(math.max(level, 2)), def.getMagChange(math.max(level, 2)),
		bonusLevel >= 3 and "#WHITE#" or "#GREY#", def.getCorpselightRadius(math.max(level, 3)),
		bonusLevel >= 4 and "#WHITE#" or "#GREY#", def.getReprieveChance(math.max(level, 4)))
	end,
	activate = function(self, eff)
		local def, level, bonusLevel = self.tempeffect_def[self.EFF_CURSE_OF_CORPSES], eff.level, math.min(eff.unlockLevel, eff.level)

		-- penalty: Fear of Death
		eff.resistsUndeadId = self:addTemporaryValue("resists_actor_type", { ["undead"] = def.getResistsUndead(eff,level) })

		-- level 1: Power over Death
		if bonusLevel < 1 then return end
		eff.incDamageUndeadId = self:addTemporaryValue("inc_damage_actor_type", { ["undead"] = def.getIncDamageUndead(level) })

		-- level 2: stats
		if bonusLevel < 2 then return end
		eff.incStatsId = self:addTemporaryValue("inc_stats", {
			[Stats.STAT_LCK] = def.getLckChange(eff, level),
			[Stats.STAT_STR] = def.getStrChange(level),
			[Stats.STAT_MAG] = def.getMagChange(level),
		})

		-- level 3: Corpselight
		-- level 4: Reprieve from Death
	end,
	deactivate = function(self, eff)
		if eff.resistsUndeadId then self:removeTemporaryValue("resists_actor_type", eff.resistsUndeadId) end
		if eff.incDamageUndeadId then self:removeTemporaryValue("inc_damage_actor_type", eff.incDamageUndeadId) end
		if eff.incStatsId then self:removeTemporaryValue("inc_stats", eff.incStatsId) end
	end,
	on_merge = function(self, old_eff, new_eff) return old_eff end,
	doCorpselight = function(self, eff, target)
		if math.min(eff.unlockLevel, eff.level) >= 3 then
			local def = self.tempeffect_def[self.EFF_CURSE_OF_CORPSES]
			local tg = {type="ball", 10, radius=def.getCorpselightRadius(eff.level), talent=t}
			self:project(tg, target.x, target.y, DamageType.LITE, 1)
			game.logSeen(target, "#F53CBE#%s의 유해에서 섬뜩한 빛이 나기 시작합니다.", (target.kr_name or target.name):capitalize())
		end
	end,
	npcWalkingCorpse = {
		name = "walking corpse",
		kr_name = "걸어다니는 시체",
		display = "z", color=colors.GREY, image="npc/undead_ghoul_ghoul.png",
		type = "undead", subtype = "ghoul",
		desc = [[방금 전까지 살아있던 적의 시체입니다. 자신의 몸이 움직이는 것을 신기해 하는 것 같습니다.]],
		body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
		no_drops = true,
		autolevel = "ghoul",
		level_range = {1, nil}, exp_worth = 0,
		ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=2, ai_move="move_ghoul", },
		stats = { str=14, dex=12, mag=10, con=12 },
		rank = 2,
		size_category = 3,
		infravision = 10,
		resolvers.racial(),
		resolvers.tmasteries{ ["technique/other"]=1, },
		open_door = true,
		blind_immune = 1,
		see_invisible = 2,
		undead = 1,
		max_life = resolvers.rngavg(90,100),
		combat_armor = 2, combat_def = 7,
		resolvers.talents{
			T_STUN={base=1, every=10, max=5},
			T_BITE_POISON={base=1, every=10, max=5},
			T_ROTTING_DISEASE={base=1, every=10, max=5},
		},
		combat = { dam=resolvers.levelup(10, 1, 1), atk=resolvers.levelup(5, 1, 1), apr=3, dammod={str=0.6} },
	},
	doReprieveFromDeath = function(self, eff, target)
		local def = self.tempeffect_def[self.EFF_CURSE_OF_CORPSES]
		if math.min(eff.unlockLevel, eff.level) >= 4 and target.type == "humanoid" and rng.percent(def.getReprieveChance(eff.level)) then
			if not self:canBe("summon") then return end

			game:onTickEnd(function()
				local x, y = util.findFreeGrid(target.x, target.y,1)
				if not x then return end
				local m = require("mod.class.NPC").new(def.npcWalkingCorpse)
				m.faction = self.faction
				m.summoner = self
				m.summoner_gain_exp = true
				m.summon_time = 6
				m:resolve() m:resolve(nil, true)
				m:forceLevelup(math.max(1, self.level - 2))
				game.zone:addEntity(game.level, m, "actor", x, y)
				-- Add to the party
				if self.player then
					m.remove_from_party_on_death = true
					game.party:addMember(m, {control="no", type="summon", title="Summon", kr_title="소환수"})
				end

				game.level.map:particleEmitter(x, y, 1, "slime")

				game.logSeen(m, "#F53CBE#%s의 시체가 일어나, 당신을 위해 싸우기 시작합니다.", (target.kr_name or target.name):capitalize())
				game:playSoundNear(who, "talents/slime")
			end)
			return true
		else
			return false
		end
	end,
}

newEffect{
	name = "CURSE_OF_MADNESS",
	desc = "Curse of Madness",
	kr_desc = "광기의 저주", kr_short_desc = "광기",
	short_desc = "Madness",
	type = "other",
	subtype = { curse=true },
	status = "beneficial",
	no_stop_enter_worlmap = true,
	decrease = 0,
	no_remove = true,
	cancel_on_level_change = true,
	parameters = {Penalty = 1},
	getMindResistChange = function(eff, level) return -level * 3 * (eff.Penalty or 1) end,
	getConfusionImmuneChange = function(eff, level) return -level * 0.04 * (eff.Penalty or 1) end,
	getCombatCriticalPowerChange = function(level) return level * 3 end,
	-- called by _M:getOffHandMult in mod.class.interface.Combat.lua
	getOffHandMultChange = function(level) return Combat:combatTalentLimit(level, 50, 4, 20) end, -- Limit < 50%
	getLckChange = function(eff, level)
		if eff.unlockLevel >= 5 or level <= 2 then return -1 end
		if level <= 3 then return -2 else return -3 end
	end,
	getDexChange = function(level) return -1 + level * 2 end,
	getManiaDamagePercent = function(level) 
		return Combat:combatLimit(level - 4, 5, 13, 1, 8, 5) -- Limit > 5%
	end,
	display_desc = function(self, eff) return ([[광기의 저주 %0.1f 단계]]):format(eff.level) end,
	long_desc = function(self, eff)
		local def, level, bonusLevel = self.tempeffect_def[self.EFF_CURSE_OF_MADNESS], eff.level, math.min(eff.unlockLevel, eff.level)

		return ([[이성이 약해지기 시작합니다.
#CRIMSON#불이익  : #WHITE#이성의 균열 : 정신 저항 %+d%% / 혼란 면역력 %+d%%
#CRIMSON#단계 1+ : %s통제 불가 : 치명타 피해량 %+d%% / 보조무기 피해량 %+d%%
#CRIMSON#단계 2+ : %s행운 %+d / 민첩 %+d
#CRIMSON#단계 3+ : %s공모자 : 자신이 혼란에 걸릴 때, 자신을 공격한 적과 자신이 근접공격한 모든 적에게도 혼란 상태 부여
#CRIMSON#단계 4+ : %s열광 : 한 턴에 최대 생명력의 %0.1f%% 이상에 해당하는 생명력을 잃으면, 지연 중인 기술 하나의 재사용 대기시간 1 턴 감소]]):format(
		def.getMindResistChange(eff, level), def.getConfusionImmuneChange(eff, level) * 100,
		bonusLevel >= 1 and "#WHITE#" or "#GREY#", def.getCombatCriticalPowerChange(math.max(level, 1)), def.getOffHandMultChange(math.max(level, 1)),
		bonusLevel >= 2 and "#WHITE#" or "#GREY#", def.getLckChange(eff, math.max(level, 2)), def.getDexChange(math.max(level, 2)),
		bonusLevel >= 3 and "#WHITE#" or "#GREY#",
		bonusLevel >= 4 and "#WHITE#" or "#GREY#", def.getManiaDamagePercent(math.max(level, 4)))
	end,
	activate = function(self, eff)
		local def, level, bonusLevel = self.tempeffect_def[self.EFF_CURSE_OF_MADNESS], eff.level, math.min(eff.unlockLevel, eff.level)

		-- reset stored values
		eff.last_life = self.life

		-- penalty: Fractured Sanity
		eff.mindResistId = self:addTemporaryValue("resists", { [DamageType.MIND] = def.getMindResistChange(eff, level) })
		eff.confusionImmuneId = self:addTemporaryValue("confusion_immune", def.getConfusionImmuneChange(eff, level) )

		-- level 1: Twisted Mind
		if bonusLevel < 1 then return end
		eff.getCombatCriticalPowerChangeId = self:addTemporaryValue("combat_critical_power", def.getCombatCriticalPowerChange(level) )

		-- level 2: stats
		if bonusLevel < 2 then return end
		eff.incStatsId = self:addTemporaryValue("inc_stats", {
			[Stats.STAT_LCK] = def.getLckChange(eff, level),
			[Stats.STAT_DEX] = def.getDexChange(level),
		})

		-- level 3: Conspirator
		-- level 4: Mania
	end,
	deactivate = function(self, eff)
		if eff.mindResistId then self:removeTemporaryValue("resists", eff.mindResistId) end
		if eff.confusionImmuneId then self:removeTemporaryValue("confusion_immune", eff.confusionImmuneId) end
		if eff.getCombatCriticalPowerChangeId then self:removeTemporaryValue("combat_critical_power", eff.getCombatCriticalPowerChangeId) end
		if eff.incStatsId then self:removeTemporaryValue("inc_stats", eff.incStatsId) end
	end,
	on_timeout = function(self, eff)
		-- mania
		if math.min(eff.unlockLevel, eff.level) >= 4 and eff.life ~= eff.last_life then
			-- occurs pretty close to actual cooldowns in Actor.Act
			local def = self.tempeffect_def[self.EFF_CURSE_OF_MADNESS]
			if not self:attr("stunned") and eff.last_life and 100 * (eff.last_life - self.life) / self.max_life >= def.getManiaDamagePercent(eff.level) then
				-- perform mania
				local list = {}
				for tid, cd in pairs(self.talents_cd) do
					if cd and cd > 0 then
						list[#list + 1] = tid
					end
				end
				if #list == 0 then return end

				local tid = rng.table(list)
				local t = self:getTalentFromId(tid)

				self.changed = true
				self.talents_cd[tid] = self.talents_cd[tid] - 1
				if self.talents_cd[tid] <= 0 then
					self.talents_cd[tid] = nil
					if self.onTalentCooledDown then self:onTalentCooledDown(tid) end
				end
				game.logSeen(self, "#F53CBE#%s 열광하여, %s 기술의 재사용 대기시간이 촉진됩니다.", (self.kr_name or self.name):capitalize():addJosa("이"), (t.kr_name or t.name))
			end
			eff.last_life = self.life
		end
	end,
	on_merge = function(self, old_eff, new_eff) return old_eff end,
	doConspirator = function(self, eff, target)
		if math.min(eff.unlockLevel, eff.level) >= 3 and self:attr("confused") and target:canBe("confusion") then
			target:setEffect(target.EFF_CONFUSED, 3, {power=50})
			self:logCombat(target, "#F53CBE##Source1# #Target#에게 혼란을 퍼뜨립니다.")
		end
	end,
}

newEffect{
	name = "CURSE_OF_SHROUDS",
	desc = "Curse of Shrouds",
	kr_desc = "장막의 저주", kr_short_desc = "장막",
	short_desc = "Shrouds",
	type = "other",
	subtype = { curse=true },
	status = "beneficial",
	no_stop_enter_worlmap = true,
	decrease = 0,
	no_remove = true,
	cancel_on_level_change = true,
	parameters = {Penalty = 1},
	getShroudIncDamageChange = function(eff, level) return -(4 + level * 2) * (eff.Penalty or 1) end,
	getResistsDarknessChange = function(level) return level * 4 end,
	getResistsCapDarknessChange = function(level) return Combat:combatTalentLimit(level, 30, 4, 12) end, -- Limit < 30%
	getSeeInvisible = function(level) return 2 + level * 2 end,
	getLckChange = function(eff, level)
		if eff.unlockLevel >= 5 or level <= 2 then return -1 end
		if level <= 3 then return -2 else return -3 end
	end,
	getConChange = function(level) return -1 + level * 2 end,
	getShroudResistsAllChange = function(level) return (level - 1) * 5 end,
	display_desc = function(self, eff) return ([[장막의 저주 %0.1f 단계]]):format(eff.level) end,
	long_desc = function(self, eff)
		local def, level, bonusLevel = self.tempeffect_def[self.EFF_CURSE_OF_SHROUDS], eff.level, math.min(eff.unlockLevel, eff.level)

		return ([[자신의 길 앞에 어둠의 장막이 펼쳐집니다.
#CRIMSON#불이익  : #WHITE#약화의 장막 : 가끔씩, 4 턴간 유지되는 약화의 장막에 둘러싸임 (공격시 피해량 -%d%%)
#CRIMSON#단계 1+ : %s밤에 걷는 자 : 어둠 저항 %+d / 최대 어둠 저항 %+d%% / 투명 감지 %+d
#CRIMSON#단계 2+ : %s행운 %+d / 체격 %+d
#CRIMSON#단계 3+ : %s흐려짐의 장막: 이동할 때 몸이 흐릿해져, 이동한 뒤 1 턴 동안 받는 피해량 -%d%% 감소
#CRIMSON#단계 4+ : %s죽음의 장막 : 적을 살해할 때마다 장막이 강화되어, 3 턴 동안 받는 피해량 -%d%% 감소]]):format(
		-def.getShroudIncDamageChange(eff, level),
		bonusLevel >= 1 and "#WHITE#" or "#GREY#", def.getResistsDarknessChange(math.max(level, 1)), def.getResistsCapDarknessChange(math.max(level, 1)), def.getSeeInvisible(math.max(level, 1)),
		bonusLevel >= 2 and "#WHITE#" or "#GREY#", def.getLckChange(eff, math.max(level, 2)), def.getConChange(math.max(level, 2)),
		bonusLevel >= 3 and "#WHITE#" or "#GREY#", def.getShroudResistsAllChange(math.max(level, 3)),
		bonusLevel >= 4 and "#WHITE#" or "#GREY#", def.getShroudResistsAllChange(math.max(level, 4)))
	end,
	activate = function(self, eff)
		local def, level, bonusLevel = self.tempeffect_def[self.EFF_CURSE_OF_SHROUDS], eff.level, math.min(eff.unlockLevel, eff.level)

		-- penalty: Shroud of Weakness

		-- level 1: Nightwalker
		if bonusLevel < 1 then return end
		eff.resistsDarknessId = self:addTemporaryValue("resists", { [DamageType.DARKNESS] = def.getResistsDarknessChange(level) })
		eff.resistsCapDarknessId = self:addTemporaryValue("resists_cap", { [DamageType.DARKNESS]= def.getResistsCapDarknessChange(level) })
		eff.seeInvisibleId = self:addTemporaryValue("see_invisible", def.getSeeInvisible(level))

		-- level 2: stats
		if bonusLevel < 2 then return end
		eff.incStatsId = self:addTemporaryValue("inc_stats", {
			[Stats.STAT_LCK] = def.getLckChange(eff, level),
			[Stats.STAT_CON] = def.getConChange(level),
		})

		-- level 3: Shroud of Passing
		-- level 4: Shroud of Death
	end,
	deactivate = function(self, eff)
		if eff.resistsDarknessId then self:removeTemporaryValue("resists", eff.resistsDarknessId) end
		if eff.resistsCapDarknessId then self:removeTemporaryValue("resists_cap", eff.resistsCapDarknessId) end
		if eff.seeInvisibleId then self:removeTemporaryValue("see_invisible", eff.seeInvisibleId) end
		if eff.incStatsId then self:removeTemporaryValue("inc_stats", eff.incStatsId) end

		if self:hasEffect(self.EFF_SHROUD_OF_WEAKNESS) then self:removeEffect(self.EFF_SHROUD_OF_WEAKNESS) end
		if self:hasEffect(self.EFF_SHROUD_OF_PASSING) then self:removeEffect(self.EFF_SHROUD_OF_PASSING) end
		if self:hasEffect(self.EFF_SHROUD_OF_DEATH) then self:removeEffect(self.EFF_SHROUD_OF_DEATH) end
	end,
	on_merge = function(self, old_eff, new_eff) return old_eff end,
	on_timeout = function(self, eff)
		-- Shroud of Weakness
		if rng.chance(100) then
			local def = self.tempeffect_def[self.EFF_CURSE_OF_SHROUDS]
			self:setEffect(self.EFF_SHROUD_OF_WEAKNESS, 4, { power=def.getShroudIncDamageChange(eff, eff.level) })
		end
	end,
	doShroudOfPassing = function(self, eff)
		-- called after energy is used; eff.moved may be set from movement
		local effShroud = self:hasEffect(self.EFF_SHROUD_OF_PASSING)
		if math.min(eff.unlockLevel, eff.level) >= 3 and eff.moved then
			local def = self.tempeffect_def[self.EFF_CURSE_OF_SHROUDS]
			if not effShroud then self:setEffect(self.EFF_SHROUD_OF_PASSING, 1, { power=def.getShroudResistsAllChange(eff.level) }) end
		else
			if effShroud then self:removeEffect(self.EFF_SHROUD_OF_PASSING) end
		end
		eff.moved = false
	end,
	doShroudOfDeath = function(self, eff)
		if math.min(eff.unlockLevel, eff.level) >= 4 and not self:hasEffect(self.EFF_SHROUD_OF_DEATH) then
			local def = self.tempeffect_def[self.EFF_CURSE_OF_SHROUDS]
			self:setEffect(self.EFF_SHROUD_OF_DEATH, 3, { power=def.getShroudResistsAllChange(eff.level) })
		end
	end,
}

newEffect{
	name = "SHROUD_OF_WEAKNESS",
	desc = "Shroud of Weakness",
	kr_desc = "약화의 장막",
	long_desc = function(self, eff) return ("굉장히 무겁게 느껴지는 장막에 둘러싸임 : 공격시 피해량 -%d%%"):format(-eff.power) end,
	type = "other",
	subtype = { time=true },
	status = "detrimental",
	no_stop_enter_worlmap = true,
	no_stop_resting = true,
	parameters = { power=10 },
	activate = function(self, eff)
		eff.incDamageId = self:addTemporaryValue("inc_damage", {all = eff.power})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_damage", eff.incDamageId)
	end,
}

newEffect{
	name = "SHROUD_OF_PASSING",
	desc = "Shroud of Passing",
	kr_desc = "흐려짐의 장막",
	long_desc = function(self, eff) return ("육체가 흐릿해짐 : 전체 저항 +%d%%"):format(eff.power) end,
	type = "other",
	subtype = { time=true },
	status = "beneficial",
	decrease = 0,
	parameters = { power=10 },
	activate = function(self, eff)
		eff.resistsId = self:addTemporaryValue("resists", { all = eff.power })
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("resists", eff.resistsId)
	end,
}

newEffect{
	name = "SHROUD_OF_DEATH",
	desc = "Shroud of Death",
	kr_desc = "죽음의 장막",
	long_desc = function(self, eff) return ("육체가 흐릿해짐 : 전체 저항 +%d%%"):format(eff.power) end,
	type = "other",
	subtype = { time=true },
	status = "beneficial",
	parameters = { power=10 },
	activate = function(self, eff)
		eff.resistsId = self:addTemporaryValue("resists", { all = eff.power })
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("resists", eff.resistsId)
	end,
}

newEffect{
	name = "CURSE_OF_NIGHTMARES",
	desc = "Curse of Nightmares",
	kr_desc = "악몽의 저주", kr_short_desc = "악몽",
	short_desc = "Nightmares",
	type = "other",
	subtype = { curse=true },
	status = "beneficial",
	no_stop_enter_worlmap = true,
	decrease = 0,
	no_remove = true,
	cancel_on_level_change = true,
	parameters = {Penalty = 1},
	-- called by _M:combatMentalResist in mod.class.interface.Combat.lua
	getVisionsReduction = function(eff, level)
		return Combat:combatTalentLimit(level, 100, 9, 25) * (eff.Penalty or 1) -- Limit < 100%
	end,
	getResistsPhysicalChange = function(level) return 1 + level end,
	getResistsCapPhysicalChange = function(level) return Combat:combatTalentLimit(level, 30, 1, 5) end, -- Limit < 30%
	getLckChange = function(eff, level)
		if eff.unlockLevel >= 5 or level <= 2 then return -1 end
		if level <= 3 then return -2 else return -3 end
	end,
	getWilChange = function(level) return -1 + level * 2 end,
	getBaseSuffocateAirChange = function(level) return Combat:combatTalentLimit(level, 50, 4, 16) end, -- Limit < 50 to take >2 hits to kill most monsters
	getSuffocateAirChange = function(level) return Combat:combatTalentLimit(level, 10, 0, 7) end, -- Limit < 10
	getNightmareChance = function(level) return Combat:combatTalentLimit(math.max(0, level-4), 25, 3, 10) end, -- Limit < 25%
	getNightmareRadius = function(level) return 5 + (level - 4) * 2 end,
	display_desc = function(self, eff)
		if math.min(eff.unlockLevel, eff.level) >= 4 then
			return ([[악몽의 저주 %0.1f 단계 : 악몽 확률 %d%%]]):format(eff.level, eff.nightmareChance or 0)
		else
			return ([[악몽의 저주 %0.1f 단계]]):format(eff.level)
		end
	end,
	long_desc = function(self, eff)
		local def, level, bonusLevel = self.tempeffect_def[self.EFF_CURSE_OF_NIGHTMARES], eff.level, math.min(eff.unlockLevel, eff.level)

		return ([[끔찍한 형상이 마음 속을 채웁니다.
#CRIMSON#불이익  : #WHITE#괴로운 정신 : 정신 내성으로 저항할 때, 20%% 확률로 -%d%% 만큼 감소된 정신 내성 적용
#CRIMSON#단계 1+ : %s비현실화 : 물리 저항 %+d / 최대 물리 저항 %+d
#CRIMSON#단계 2+ : %s행운 %+d / 의지 %+d
#CRIMSON#단계 3+ : %s숨막힘 : 자신을 공격하거나 자신이 근접공격한 적을 공포로 질식시킴. (정예 등급 미만인 적에게만 적용) 적이 잃는 호흡 : -%d * (자신의 레벨-적의 레벨-2) (0 이상의 값이 나올 경우, 모두 0 이 됩니다)
#CRIMSON#단계 4+ : %s악몽 : 적에게 피해를 받을 때마다, %d%% 확률로 8 턴간 주변 %d 칸 반경에 악몽 유발 (느려짐 / 증오의 속삭임 / 공포 소환) (악몽 발생 확률은 피해를 받을 때마다 증가)]]):format(
		def.getVisionsReduction(eff, level),
		bonusLevel >= 1 and "#WHITE#" or "#GREY#", def.getResistsPhysicalChange(math.max(level, 1)), def.getResistsCapPhysicalChange(math.max(level, 1)),
		bonusLevel >= 2 and "#WHITE#" or "#GREY#", def.getLckChange(eff, math.max(level, 2)), def.getWilChange(math.max(level, 2)),
		bonusLevel >= 3 and "#WHITE#" or "#GREY#", def.getBaseSuffocateAirChange(math.max(level, 3)), --@ 변수 조정
		bonusLevel >= 4 and "#WHITE#" or "#GREY#", eff.nightmareChance or 0, def.getNightmareRadius(math.max(level, 4)), def.getNightmareChance(math.max(level, 4)))
	end,
	activate = function(self, eff)
		local def, level, bonusLevel = self.tempeffect_def[self.EFF_CURSE_OF_NIGHTMARES], eff.level, math.min(eff.unlockLevel, eff.level)

		-- penalty: Plagued by Visions

		-- level 1: Removed from Reality
		if bonusLevel < 1 then return end
		eff.resistsPhysicalId = self:addTemporaryValue("resists", { [DamageType.PHYSICAL]= def.getResistsPhysicalChange(level) })
		eff.resistsCapPhysicalId = self:addTemporaryValue("resists_cap", { [DamageType.PHYSICAL]= def.getResistsCapPhysicalChange(level) })

		-- level 2: stats
		if bonusLevel < 2 then return end
		eff.incStatsId = self:addTemporaryValue("inc_stats", {
			[Stats.STAT_LCK] = def.getLckChange(eff, level),
			[Stats.STAT_WIL] = def.getWilChange(level),
		})

		-- level 3: Suffocate
		-- level 4: Nightmare
	end,
	deactivate = function(self, eff)
		if eff.resistsPhysicalId then self:removeTemporaryValue("resists", eff.resistsPhysicalId); end
		if eff.resistsCapPhysicalId then self:removeTemporaryValue("resists_cap", eff.resistsCapPhysicalId) end
		if eff.incStatsId then self:removeTemporaryValue("inc_stats", eff.incStatsId) end
	end,
	on_merge = function(self, old_eff, new_eff) return old_eff end,
	doSuffocate = function(self, eff, target)
		if math.min(eff.unlockLevel, eff.level) >= 3 then
			if target and target.rank <= 2 and target.level <= self.level - 3 and not target:attr("no_breath") and not target:attr("invulnerable") then
				local def = self.tempeffect_def[self.EFF_CURSE_OF_NIGHTMARES]
				local airLoss = def.getBaseSuffocateAirChange(eff.level) + Combat:combatTalentScale(self.level - target.level - 3, 1, 5) * def.getSuffocateAirChange(eff.level)
				game.logSeen(self, "#F53CBE#%s 저주로 인해 숨이 막힙니다 (호흡 -%d).", (target.kr_name or target.name):capitalize():addJosa("가"), airLoss)
				target:suffocate(airLoss, self, "저주로 인한 숨막힘")
			end
		end
	end,
	npcTerror = {
		name = "terror",
		kr_name = "공포",
		display = "h", color=colors.DARK_GREY, image="npc/horror_eldritch_nightmare_horror.png",
		blood_color = colors.BLUE,
		desc = "형체가 없는 공포로, 희생자를 포함한 모든 것을 베어버립니다.",
		type = "horror", subtype = "eldritch",
		rank = 2,
		size_category = 2,
		body = { INVEN = 10 },
		no_drops = true,
		autolevel = "warrior",
		level_range = {1, nil}, exp_worth = 0,
		ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=2, ai_move="move_ghoul", },
		stats = { str=16, dex=20, wil=15, con=15 },
		infravision = 10,
		can_pass = {pass_wall=20},
		resists = {[DamageType.LIGHT] = -50, [DamageType.DARKNESS] = 100},
		silent_levelup = true,
		no_breath = 1,
		fear_immune = 1,
		blind_immune = 1,
		infravision = 10,
		see_invisible = 80,
		max_life = resolvers.rngavg(50, 80),
		combat_armor = 1, combat_def = 10,
		combat = { dam=resolvers.levelup(resolvers.rngavg(15,20), 1, 1.1), atk=resolvers.rngavg(5,15), apr=5, dammod={str=1} },
		resolvers.talents{
		},
	},
	on_timeout = function(self, eff) -- Chance for nightmare fades over time
		if eff.nightmareChance then eff.nightmareChance = math.max(0, eff.nightmareChance-1) end
	end,
	-- called by _M:onTakeHit function in in mod.class.Actor.lua
	doNightmare = function(self, eff)
		if math.min(eff.unlockLevel, eff.level) >= 4 then
			-- build chance for a nightmare
			local def = self.tempeffect_def[self.EFF_CURSE_OF_NIGHTMARES]
			eff.nightmareChance = (eff.nightmareChance or 0) + def.getNightmareChance(eff.level)

			-- invoke the nightmare
			if rng.percent(eff.nightmareChance) then
				local radius = def.getNightmareRadius(eff.level)

				-- make sure there is at least one creature to torment
				local seen = false
				core.fov.calc_circle(self.x, self.y, game.level.map.w, game.level.map.h, radius,
					function(_, x, y) return game.level.map:opaque(x, y) end,
					function(_, x, y)
						local actor = game.level.map(x, y, game.level.map.ACTOR)
						if actor and actor ~= self and self:reactionToward(actor) < 0 then seen = true end
					end, nil)
				if not seen then return false end

				-- start the nightmare: slow, hateful whisper, random Terrors (minor horrors)
				eff.nightmareChance = 0
				game.level.map:addEffect(self,
					self.x, self.y, 8,
					DamageType.NIGHTMARE, 1,
					radius,
					5, nil,
					engine.MapEffect.new{alpha=100, color_br=134, color_bg=60, color_bb=134, effect_shader="shader_images/darkness_effect.png"},
					function(e)
						-- attempt one summon per turn
						if not e.src:canBe("summon") then return end

						local def = e.src.tempeffect_def[e.src.EFF_CURSE_OF_NIGHTMARES]

						-- random location nearby..not too picky and these things can move through walls but won't start there
						local locations = {}
						local grids = core.fov.circle_grids(e.x, e.y, e.radius, true)
						for lx, yy in pairs(grids) do for ly, _ in pairs(grids[lx]) do
							if not game.level.map:checkAllEntities(lx, ly, "block_move") then
								locations[#locations+1] = {lx, ly}
							end
						end end
						if #locations == 0 then return true end
						local location = rng.table(locations)

						local m = require("mod.class.NPC").new(def.npcTerror)
						m.faction = e.src.faction
						m.summoner = e.src
						m.summoner_gain_exp = true
						m.summon_time = 3
						m:resolve() m:resolve(nil, true)
						m:forceLevelup(e.src.level)

						-- Add to the party
						if e.src.player then
							m.remove_from_party_on_death = true
							game.party:addMember(m, {control="no", type="nightmare", title="Nightmare", kr_title="악몽"})
						end

						game.zone:addEntity(game.level, m, "actor", location[1], location[2])

						return true
					end,
					false, false)

				game.logSeen(self, "#F53CBE#%s 주변의 공기가 차가워지고, 끔찍한 형체가 생겨납니다. 악몽이 시작됩니다...", (self.kr_name or self.name):capitalize())
				game:playSoundNear(self, "talents/cloud")
			end
		end
	end,
}

newEffect{
	name = "CURSE_OF_MISFORTUNE",
	desc = "Curse of Misfortune",
	kr_desc = "불운의 저주", kr_short_desc = "불운",
	short_desc = "Misfortune",
	type = "other",
	subtype = { curse=true },
	status = "beneficial",
	no_stop_enter_worlmap = true,
	decrease = 0,
	no_remove = true,
	cancel_on_level_change = true,
	parameters = {Penalty = 1},
	getMoneyMult = function(eff, level) return Combat:combatTalentLimit(level, 1, 0.15, 0.35) * (eff.Penalty or 1)end, -- Limit < 1 bug fix

	getCombatDefChange = function(level) return level * 2 end,
	getCombatDefRangedChange = function(level) return level end,
	getLckChange = function(eff, level)
		if eff.unlockLevel >= 5 or level <= 2 then return -1 end
		if level <= 3 then return -2 else return -3 end
	end,
	getCunChange = function(level) return -1 + level * 2 end,
	getDeviousMindChange = function(level) return Combat:combatTalentLimit(math.max(1,level-3), 100, 35, 55) end, -- Limit < 100%
	getUnfortunateEndChance = function(level) return Combat:combatTalentLimit(math.max(1, level-3), 100, 30, 40) end, -- Limit < 50%
	getUnfortunateEndIncrease = function(level) return Combat:combatTalentLimit(math.max(1, level-3), 50, 30, 40) end, -- Limit < 50%
	display_desc = function(self, eff) return ([[불운의 저주 %0.1f 단계]]):format(eff.level) end,
	long_desc = function(self, eff)
		local def, level, bonusLevel = self.tempeffect_def[self.EFF_CURSE_OF_MISFORTUNE], eff.level, math.min(eff.unlockLevel, eff.level)

		return ([[혼란과 파괴가 당신을 뒤따릅니다.
#CRIMSON#불이익  : #WHITE#잃어버린 부 : 금화 발견 확률 감소
#CRIMSON#단계 1+ : %s빗나간 행운 : 회피도 %+d / 장거리 회피 +%d
#CRIMSON#단계 2+ : %s행운 %+d / 교활함 %+d
#CRIMSON#단계 3+ : %s사악한 마음 : 타인의 계획이 틀어지는 것을 즐김 (함정 회피 확률 +%d%%)
#CRIMSON#단계 4+ : %s불행한 최후 : 지금보다 공격력이 %d%% 더 증가하면 적을 일격사시킬 수 있을 경우, %d%% 확률로 증가한 공격력을 이용해 공격]]):format(
		bonusLevel >= 1 and "#WHITE#" or "#GREY#", def.getCombatDefChange(math.max(level, 1)), def.getCombatDefRangedChange(math.max(level, 1)),
		bonusLevel >= 2 and "#WHITE#" or "#GREY#", def.getLckChange(eff, math.max(level, 2)), def.getCunChange(math.max(level, 2)),
		bonusLevel >= 3 and "#WHITE#" or "#GREY#", def.getDeviousMindChange(math.max(level, 3)),
		bonusLevel >= 4 and "#WHITE#" or "#GREY#", def.getUnfortunateEndIncrease(math.max(level, 4)), def.getUnfortunateEndChance(math.max(level, 4))) --@ 변수 순서 조정
	end,
	activate = function(self, eff)
		local def, level, bonusLevel = self.tempeffect_def[self.EFF_CURSE_OF_MISFORTUNE], eff.level, math.min(eff.unlockLevel, eff.level)

		-- penalty: Lost Fortune
		eff.moneyValueMultiplierId = self:addTemporaryValue("money_value_multiplier", -def.getMoneyMult(eff, level))

		-- level 1: Missed Shot
		if bonusLevel < 1 then return end
		eff.combatDefId = self:addTemporaryValue("combat_def", def.getCombatDefChange(level))
		eff.combatDefRangedId = self:addTemporaryValue("combat_def_ranged", def.getCombatDefRangedChange(level))

		-- level 2: stats
		if bonusLevel < 2 then return end
		eff.incStatsId = self:addTemporaryValue("inc_stats", {
			[Stats.STAT_LCK] = def.getLckChange(eff, level),
			[Stats.STAT_CUN] = def.getCunChange(level),
		})

		-- level 3: Devious Mind
		if bonusLevel < 3 then return end
		eff.trapAvoidanceId = self:addTemporaryValue("trap_avoidance", def.getDeviousMindChange(level))

		-- level 4: Unfortunate End
	end,
	deactivate = function(self, eff)
		if eff.moneyValueMultiplierId then self:removeTemporaryValue("money_value_multiplier", eff.moneyValueMultiplierId) end
		if eff.combatDefId then self:removeTemporaryValue("combat_def", eff.combatDefId) end
		if eff.combatDefRangedId then self:removeTemporaryValue("combat_def_ranged", eff.combatDefRangedId) end
		if eff.incStatsId then self:removeTemporaryValue("inc_stats", eff.incStatsId) end
		if eff.trapAvoidanceId then self:removeTemporaryValue("trap_avoidance", eff.trapAvoidanceId) end
	end,
	on_merge = function(self, old_eff, new_eff) return old_eff end,
	
	-- called by default projector in mod.data.damage_types.lua
	doUnfortunateEnd = function(self, eff, target, dam)
		if math.min(eff.unlockLevel, eff.level) >=4 then
			local def = self.tempeffect_def[self.EFF_CURSE_OF_MISFORTUNE]
			if target.life - dam > 0 and rng.percent(def.getUnfortunateEndChance(eff.level)) then
				local multiplier = 1 + def.getUnfortunateEndIncrease(eff.level) / 100
				if target.life - dam * multiplier <= 0 then
					-- unfortunate end! note that this does not kill if target.die_at < 0
					dam = dam * multiplier
					if target.life - dam <= target.die_at then
						game.logSeen(target, "#F53CBE#%s 불행한 최후를 맞이합니다.", (target.kr_name or target.name):capitalize():addJosa("가"))
					else
						game.logSeen(target, "#F53CBE#%s 불행한 일격으로 고통스러워 합니다.", (target.kr_name or target.name):capitalize():addJosa("가"))
					end
				end
			end
		end

		return dam
	end,
}

newEffect{
	name = "RELOADING", image = "talents/reload.png",
	desc = "Reloading",
	kr_desc = "재장전",
	long_desc = function(self, eff) return ("재장전 중...") end,
	decrease = 0,
	type = "other",
	subtype = { miscellaneous=true },
	status = "beneficial",
	parameters = {},
	activate = function(self, eff) game.logSeen(self, "#LIGHT_BLUE#%s 재장전을 시작합니다.", (self.kr_name or self.name):capitalize():addJosa("가")) end,
	deactivate = function(self, eff)
	end,
	on_timeout = function(self, eff)
		for i = 1, eff.shots_per_turn do
			eff.ammo.combat.shots_left = eff.ammo.combat.shots_left + 1
			if eff.ammo.combat.shots_left >= eff.ammo.combat.capacity then
				game.logPlayer(self, "%s 안의 내용물이 가득 찼습니다.", (eff.ammo.kr_name or eff.ammo.name))
				self:breakReloading()
				break
			end
		end
	end,
}

newEffect{
	name = "PROB_TRAVEL_UNSTABLE", image = "talents/probability_travel.png",
	desc = "Unstable Probabilites",
	kr_desc = "불안정한 확률",
	long_desc = function(self, eff) return "최근 마법 확률 이동을 사용하여 벽을 통과한 적이 있음" end,
	type = "other",
	subtype = { time=true, space=true },
	status = "detrimental",
	parameters = {},
	activate = function(self, eff)
		eff.iid = self:addTemporaryValue("prob_travel_deny", 1)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("prob_travel_deny", eff.iid)
	end,
}

newEffect{
	name = "HEIGHTEN_FEAR", image = "talents/heighten_fear.png",
	desc = "Heighten Fear",
	kr_desc = "고조된 공포",
	long_desc = function(self, eff) return ("공포 고조 : 공포의 시전자인 %s 의 시야 범위, 혹은 %d 칸 이내에 %d 턴 동안 더 있을 경우, 또 다른 공포에 걸림"): 
	format((eff.src.kr_name or eff.src.name), eff.turns_left, eff.range) end, --@ 변수 순서 조정
	type = "other",
	subtype = { fear=true },
	status = "detrimental",
	decrease = 0,
	no_remove = true,
	cancel_on_level_change = true,
	parameters = { },
	on_merge = function(self, old_eff, new_eff)
		old_eff.src = new_eff.src
		old_eff.range = new_eff.range

		return old_eff
	end,
	on_timeout = function(self, eff)
		local tInstillFear = self:getTalentFromId(self.T_INSTILL_FEAR)
		if tInstillFear.hasEffect(eff.src, tInstillFear, self) then
			if core.fov.distance(self.x, self.y, eff.src.x, eff.src.y) <= eff.range and self:hasLOS(eff.src.x, eff.src.y) then
				eff.turns_left = eff.turns_left - 1
			end
			if eff.turns_left <= 0 then
				eff.turns_left = eff.turns
				if rng.percent(eff.chance or 100) then
					eff.chance = (eff.chance or 100) - 10
					game.logSeen(self, "%s 고조된 공포에 빠집니다!", (self.kr_name or self.name):capitalize():addJosa("가"))
					tInstillFear.applyEffect(eff.src, tInstillFear, self)
				else
					game.logSeen(self, "%s의 두려움이 줄어들었습니다!", (self.kr_name or self.name):capitalize())
				end
			end
		else
			-- no more fears
			self:removeEffect(self.EFF_HEIGHTEN_FEAR, false, true)
		end
	end,
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "CURSED_FORM", image = "talents/seethe.png",
	desc = "Cursed Form",
	kr_desc = "저주받은 신체",
	type = "other",
	subtype = { curse=true },
	status = "beneficial",
	decrease = 0,
	no_remove = true,
	cancel_on_level_change = true,
	parameters = {},
	long_desc = function(self, eff)
		local desc = "저주받은 신체가 피해에 반응"
		if (eff.incDamageChange or 0) > 0 then
			desc = desc..(" : 공격시 피해량 +%d%%"):format(eff.incDamageChange)
		end
		if (eff.statChange or 0) > 0 then
			desc = desc..(" : 힘 +%d / 의지 +%d / 매 턴마다 %d%% 확률로 중독과 질병 치료"):format(eff.statChange, eff.statChange, eff.neutralizeChance) --@ 변수 조정
		end
		return desc
	end,
	activate = function(self, eff)
		-- first on_timeout is ignored because it is applied immediately
		eff.firstHit = true
		eff.increase = 1
		self.tempeffect_def[self.EFF_CURSED_FORM].updateEffect(self, eff)

		game.level.map:particleEmitter(self.x, self.y, 1, "cursed_form", {power=eff.increase})
	end,
	deactivate = function(self, eff)
		if eff.incDamageId then
			self:removeTemporaryValue("inc_damage", eff.incDamageId)
			eff.incDamageId = nil
		end
		if eff.incStatsId then
			self:removeTemporaryValue("inc_stats", eff.incStatsId)
			eff.incStatsId = nil
		end
	end,
	do_onTakeHit = function(self, eff, dam)
		eff.hit = true
	end,
	updateEffect = function(self, eff)
		local tSeethe = self:getTalentFromId(self.T_SEETHE)
		local tGrimResolve = self:getTalentFromId(self.T_GRIM_RESOLVE)
		if tSeethe then
			eff.incDamageChange = tSeethe.getIncDamageChange(self, tSeethe, eff.increase)
		end
		if tGrimResolve then
			eff.statChange = tGrimResolve.getStatChange(self, tGrimResolve, eff.increase)
			eff.neutralizeChance = tGrimResolve.getNeutralizeChance(self, tGrimResolve)
		end

		if eff.incDamageId then
			self:removeTemporaryValue("inc_damage", eff.incDamageId)
			eff.incDamageId = nil
		end
		if eff.incDamageChange > 0 then
			eff.incDamageId = self:addTemporaryValue("inc_damage", {all = eff.incDamageChange})
		end
		if eff.incStatsId then
			self:removeTemporaryValue("inc_stats", eff.incStatsId)
			eff.incStatsId = nil
		end
		if eff.statChange > 0 then
			eff.incStatsId = self:addTemporaryValue("inc_stats", { [Stats.STAT_STR] = eff.statChange, [Stats.STAT_WIL] = eff.statChange })
		end
	end,
	on_timeout = function(self, eff)
		if eff.firstHit then
			eff.firstHit = nil
			eff.hit = false
		elseif eff.hit then
			if eff.increase < 5 then
				eff.increase = eff.increase + 1
				self.tempeffect_def[self.EFF_CURSED_FORM].updateEffect(self, eff)

				game.level.map:particleEmitter(self.x, self.y, 1, "cursed_form", {power=eff.increase})
			end
			eff.hit = false
		else
			eff.increase = eff.increase - 1
			if eff.increase == 0 then
				self:removeEffect(self.EFF_CURSED_FORM, false, true)
			else
				self.tempeffect_def[self.EFF_CURSED_FORM].updateEffect(self, eff)
			end
		end
		if (eff.statChange or 0)>0 and eff.neutralizeChance then -- Remove poisons/disease (w/Grim Resolve)
			local efdef
			for efid, ef in pairs(self.tmp) do
				efdef = self.tempeffect_def[efid]
				if efdef.subtype and (efdef.subtype.poison or efdef.subtype.disease) and rng.percent(eff.neutralizeChance) then
					self:removeEffect(efid)
				end
			end
		end
	end,
}

newEffect{
	name = "FADED", image = "talents/shadow_fade.png",
	desc = "Faded",
	kr_desc = "흐려짐",
	long_desc = function(self, eff) return "흐려짐 : 피해를 입지 않음" end,
	type = "other",
	subtype = { },
	status = "beneficial",
	on_gain = function(self, err) return "#Target#의 형체가 흐릿해집니다!", "+흐려짐" end,
	parameters = {},
	activate = function(self, eff)
		eff.iid = self:addTemporaryValue("invulnerable", 1)
		eff.imid = self:addTemporaryValue("status_effect_immune", 1)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("invulnerable", eff.iid)
		self:removeTemporaryValue("status_effect_immune", eff.imid)
	end,
	on_timeout = function(self, eff)
		-- always remove
		return true
	end,
}

newEffect{
	name = "POSSESSION", image = "talents/possess.png",
	desc = "Psionic Consume",
	kr_desc = "잡아먹힌 정신",
	long_desc = function(self, eff) return "정신이 파괴되었으며, 육신은 조종당하고 있음. 하지만 강렬한 염동력이 육체를 불태우고 있어, 곧 육체도 붕괴됨" end,
	type = "other",
	subtype = { psionic=true, possess=true },
	status = "detrimental",
	no_stop_resting = true,
	parameters = { },
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
		self.summoner = nil
		self:die(self)
	end,
}

-- Borrowed Time and the Borrowed Time stun effect
newEffect{
	name = "HIGHBORN_S_BLOOM", image = "talents/highborn_s_bloom.png",
	desc = "Highborn's Bloom",
	kr_desc = "잠재된 마력 발현",
	long_desc = function(self, eff) return "원천력 소모 없이 기술 사용 가능" end,
	type = "other",
	subtype = { arcane=true },
	status = "beneficial",
	parameters = { power=10 },
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("zero_resource_cost", 1)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("zero_resource_cost", eff.tmpid)
	end,
}

newEffect{
	name = "VICTORY_RUSH_ZIGUR", image = "talents/arcane_destruction.png",
	desc = "Victory Rush",
	kr_desc = "승리의 돌진",
	long_desc = function(self, eff) return "승리의 전율 : 무적 상태" end,
	type = "other",
	subtype = { arcane=true },
	status = "beneficial",
	parameters = { },
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("invulnerable", 1)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("invulnerable", eff.tmpid)
	end,
}

newEffect{
	name = "SOLIPSISM", image = "talents/solipsism.png",
	desc = "Solipsism",
	kr_desc = "유아론",
	long_desc = function(self, eff) return ("유아론적 상태에 빠져, 자존적 사고에 지나치게 몰두 : 모든 행동 속도 -%d%%"):format(eff.power * 100) end,
	type = "other",
	subtype = { psionic=true },
	status = "detrimental",
	decrease = 0,
	no_stop_enter_worlmap = true, no_stop_resting = true,
	parameters = { },
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("global_speed_add", -eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("global_speed_add", eff.tmpid)
	end,
}

newEffect{
	name = "CLARITY", image = "talents/clarity.png",
	desc = "Clarity",
	kr_desc = "깨달음",
	long_desc = function(self, eff) return ("깨달음이 찾아와, 세상의 원리 이해 : 모든 행동 속도 +%d%%"):format(eff.power * 100) end,
	type = "other",
	subtype = { psionic=true },
	status = "beneficial",
	decrease = 0,
	no_stop_enter_worlmap = true, no_stop_resting = true,
	parameters = { },
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("global_speed_add", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("global_speed_add", eff.tmpid)
	end,
}

newEffect{
	name = "DREAMSCAPE", image = "talents/dreamscape.png",
	desc = "Dreamscape",
	kr_desc = "꿈 속 여행",
	long_desc = function(self, eff) return ("%s의 꿈 : 공격시 피해량 +%d%%"):format((eff.target.kr_name or eff.target.name), eff.power) end,
	type = "other",
	subtype = { psionic=true },
	status = "beneficial",
	parameters = { power=1, projections_killed=0 },
	on_timeout = function(self, eff)
		-- Clone protection
		if not self.on_die then return end
		-- Dreamscape doesn't cooldown in the dreamscape
		self.talents_cd[self.T_DREAMSCAPE] = self.talents_cd[self.T_DREAMSCAPE] + 1
		-- Spawn every three turns, or every two for lucid dreamers
		local spawn_time = 2
		if eff.dur%spawn_time == 0 then
			local x, y = util.findFreeGrid(eff.target.x, eff.target.y, 1, true, {[Map.ACTOR]=true})
			if not x then
				game.logPlayer(self, "소환할 장소가 없습니다!")
				return
			end
			-- Create a clone for later spawning
			local m = require("mod.class.NPC").new(eff.target:cloneFull{
				shader = "shadow_simulacrum",
				shader_args = { color = {0.0, 1, 1}, base = 0.6 },
				no_drops = true,
				faction = eff.target.faction,
				summoner = eff.target, summoner_gain_exp=true,
				ai_target = {actor=nil},
				ai = "summoned", ai_real = "tactical",
				ai_state = eff.target.ai_state or { ai_move="move_complex", talent_in=1 },
				name = eff.target.name.."'s dream projection",
				kr_name = (eff.target.kr_name or eff.target.name).."의 투영된 꿈",
			})
			m.ai_state.ally_compassion = 10
			m:removeAllMOs()
			m.make_escort = nil
			m.on_added_to_level = nil
			m._rst_full = true

			m.energy.value = 0
			m.player = nil
			m.max_life = m.max_life
			m.life = util.bound(m.life, 0, m.max_life)
			if not eff.target:attr("lucid_dreamer") then
				m.inc_damage.all = (m.inc_damage.all or 0) - 50
			end
			m.forceLevelup = function() end
			m.die = nil
			m.on_die = nil
			m.on_acquire_target = nil
			m.seen_by = nil
			m.can_talk = nil
			m.puuid = nil
			m.on_takehit = nil
			m.exp_worth = 0
			m.no_inventory_access = true
			m.clone_on_hit = nil
			m.remove_from_party_on_death = true
			m.is_psychic_projection = true
			-- remove imprisonment
			m.invulnerable = m.invulnerable - 1
			m.time_prison = m.time_prison - 1
			m.no_timeflow = m.no_timeflow - 1
			m.status_effect_immune = m.status_effect_immune - 1
			m:removeParticles(eff.particle)
			m:removeTimedEffectsOnClone()

			-- track number killed
			m.on_die = function(self, who)
				local p = (who and who:hasEffect(who.EFF_DREAMSCAPE)) or (who and who.summoner and who.summoner:hasEffect(who.summoner.EFF_DREAMSCAPE))
				if p then -- For the rare instance we die after the effect ends but before the dreamscape instance closes
					p.projections_killed = p.projections_killed + 1
					game.logSeen(p.target, "#LIGHT_RED#%s의 정신을 일부 파괴하였습니다. 대상이 고통에 몸부림치기 시작합니다!", (p.target.kr_name or p.target.name):capitalize())
				end
			end

			game.zone:addEntity(game.level, m, "actor", x, y)
			game.level.map:particleEmitter(x, y, 1, "generic_teleport", {rm=0, rM=0, gm=180, gM=255, bm=180, bM=255, am=35, aM=90})
			game.logSeen(eff.target, "#LIGHT_BLUE#%s 정신을 보호하기 위해, 꿈의 투영체를 만들어냅니다!", (eff.target.kr_name or eff.target.name):capitalize():addJosa("가"))

			if game.party:hasMember(eff.target) then
				game.party:addMember(m, {
					control="full",
					type="projection",
					title="Dream Self", kr_title="스스로의 꿈",
					orders = {target=true},
				})
				if eff.target == game.player then
					game.party:setPlayer(m)
					m:resetCanSeeCache()
				end
			end

			-- Try to insure the AI isn't attacking the invulnerable actor
			if self.ai_target and self.ai_target.actor and self.ai_target.actor:attr("invulnerable") then
				self:setTarget(nil)
			end
		end
		-- End the effect early if we've killed enough projections
		if eff.projections_killed/10 >= eff.target.life/eff.target.max_life then
			game:onTickEnd(function()
				eff.target:die(self)
				game.logSeen(eff.target, "#LIGHT_RED#%s의 정신이 %d 개의 작은 파편들로 부서집니다!", (eff.target.kr_name or eff.target.name):capitalize(), eff.target.max_life)
				eff.projections_killed = 0 -- clear this out to prevent closing messages
			end)
		end
	end,
	activate = function(self, eff)
		-- Make the target invulnerable
		eff.iid = eff.target:addTemporaryValue("invulnerable", 1)
		eff.sid = eff.target:addTemporaryValue("time_prison", 1)
		eff.tid = eff.target:addTemporaryValue("no_timeflow", 1)
		eff.imid = eff.target:addTemporaryValue("status_effect_immune", 1)
		eff.target.energy.value = 0
		if core.shader.active(4) then
			eff.particle = eff.target:addParticles(Particles.new("shader_shield", 1, {img="shield2", size_factor=1.25}, {type="shield", shieldIntensity=0.25, time_factor=6000, aadjust=5, color={0, 1, 1}}))
		else
			eff.particle = eff.target:addParticles(Particles.new("generic_shield", 1, {r=0, g=1, b=1, a=1}))
		end

		-- Make the invader deadly
		eff.pid = self:addTemporaryValue("inc_damage", {all=eff.power})
		eff.did = self:addTemporaryValue("lucid_dreamer", 1)
	end,
	deactivate = function(self, eff)
		-- Clone protection
		if not self.on_die then return end
		-- Remove the target's invulnerability
		eff.target:removeTemporaryValue("invulnerable", eff.iid)
		eff.target:removeTemporaryValue("time_prison", eff.sid)
		eff.target:removeTemporaryValue("no_timeflow", eff.tid)
		eff.target:removeTemporaryValue("status_effect_immune", eff.imid)
		eff.target:removeParticles(eff.particle)
		-- Remove the invaders damage bonus
		self:removeTemporaryValue("inc_damage", eff.pid)
		self:removeTemporaryValue("lucid_dreamer", eff.did)
		-- Return from the dreamscape
		game:onTickEnd(function()
			-- Collect objects
			local objs = {}
			for i = 0, game.level.map.w - 1 do for j = 0, game.level.map.h - 1 do
				for z = game.level.map:getObjectTotal(i, j), 1, -1 do
					objs[#objs+1] = game.level.map:getObject(i, j, z)
					game.level.map:removeObject(i, j, z)
				end
			end end

			local oldzone = game.zone
			local oldlevel = game.level
			local zone = game.level.source_zone
			local level = game.level.source_level

			if not self.dead then
				oldlevel:removeEntity(self)
				level:addEntity(self)
			end

			game.zone = zone
			game.level = level
			game.zone_name_s = nil

			local x1, y1 = util.findFreeGrid(eff.x, eff.y, 20, true, {[Map.ACTOR]=true})
			if x1 then
				if not self.dead then
					self:move(x1, y1, true)
					self.on_die, self.dream_plane_on_die = self.dream_plane_on_die, nil
					game.level.map:particleEmitter(x1, y1, 1, "generic_teleport", {rm=0, rM=0, gm=180, gM=255, bm=180, bM=255, am=35, aM=90})
				else
					self.x, self.y = x1, y1
				end
			end
			local x2, y2 = util.findFreeGrid(eff.tx, eff.ty, 20, true, {[Map.ACTOR]=true})
			if not eff.target.dead then
				if x2 then
					eff.target:move(x2, y2, true)
					eff.target.on_die, eff.target.dream_plane_on_die = eff.target.dream_plane_on_die, nil
				end
				if oldlevel:hasEntity(eff.target) then oldlevel:removeEntity(eff.target) end
				level:addEntity(eff.target)
			else
				eff.target.x, eff.target.y = x2, y2
			end

			-- Add objects back
			for i, o in ipairs(objs) do
				if self.dead then
					game.level.map:addObject(eff.target.x, eff.target.y, o)
				else
					game.level.map:addObject(self.x, self.y, o)
				end
			end

			-- Remove all npcs in the dreamscape
			for uid, e in pairs(oldlevel.entities) do
				if e ~= self and e ~= eff.target and e.die then e:die() end
			end

			-- Reload MOs
			game.level.map:redisplay()
			game.level.map:recreate()
			game.uiset:setupMinimap(game.level)
			game.nicer_tiles:postProcessLevelTilesOnLoad(game.level)

			game.logPlayer(game.player, "#LIGHT_BLUE#꿈 속 여행에서 돌아왔습니다!")

			-- Apply Dreamscape hit
			if eff.projections_killed > 0 then
				local kills = eff.projections_killed
				eff.target:takeHit(eff.target.max_life/10 * kills, self)
				eff.target:setEffect(eff.target.EFF_BRAINLOCKED, kills, {})

				local loss = "손상으로"
				if kills >= 10 then loss = "약간 위험한 수준의 손상으로" elseif kills >=8 then loss = "통렬한 손상으로" elseif kills >=6 then loss = "엄청난 손상으로" elseif kills >=4 then loss = "끔찍한 손상으로" end
				game.logSeen(eff.target, "#LIGHT_RED#%s 꿈 속 여행에서 입은 %s 괴로워합니다!", (eff.target.kr_name or eff.target.name):capitalize():addJosa("가"), loss)
			end
		end)
	end,
}

newEffect{
	name = "REVISIONIST_HISTORY", image = "talents/revisionist_history.png",
	desc = "Revisionist History",
	kr_desc = "수정론자의 역사 기록법",
	long_desc = function(self, eff) return "최근에 발생한 사건의 무효화 가능" end,
	type = "other",
	subtype = { time=true },
	status = "beneficial",
	parameters = { },
	activate = function(self, eff)
		if self.hotkey and self.isHotkeyBound then
			local pos = self:isHotkeyBound("talent", self.T_REVISIONIST_HISTORY)
			if pos then
				self.hotkey[pos] = {"talent", self.T_REVISIONIST_HISTORY_BACK}
			end
		end

		local ohk = self.hotkey
		self.hotkey = nil -- Prevent assigning hotkey, we just did
		self:learnTalent(self.T_REVISIONIST_HISTORY_BACK, true, 1, {no_unlearn=true})
		self.hotkey = ohk
		self:startTalentCooldown(self.T_REVISIONIST_HISTORY)
	end,
	deactivate = function(self, eff)
		if eff.back_in_time then game:onTickEnd(function()
			-- Update the shader of the original player
			self:updateMainShader()
			if game._chronoworlds == nil then
				game.logSeen(self, "#LIGHT_RED#주문이 헛나갔습니다.")
				self:startTalentCooldown(self.T_REVISIONIST_HISTORY)
				return
			end
			game.logPlayer(game.player, "#LIGHT_BLUE#시간을 되돌려, 역사를 새로 적습니다!")
			game:chronoRestore("revisionist_history", true)
			game._chronoworlds = nil
			game.player.talents_cd[self.T_REVISIONIST_HISTORY] = nil
			game.player:startTalentCooldown(self.T_REVISIONIST_HISTORY)
		end) else
			game._chronoworlds = nil
			game.player.talents_cd[self.T_REVISIONIST_HISTORY] = nil
			self:startTalentCooldown(self.T_REVISIONIST_HISTORY)
			
			if self.hotkey and self.isHotkeyBound then
				local pos = self:isHotkeyBound("talent", self.T_REVISIONIST_HISTORY_BACK)
				if pos then
					self.hotkey[pos] = {"talent", self.T_REVISIONIST_HISTORY}
				end
			end

			self:unlearnTalent(self.T_REVISIONIST_HISTORY_BACK, 1, nil, {no_unlearn=true})
		end
	end,
}

newEffect{
	name = "ZONE_AURA_FIRE",
	desc = "Oil mist",
	kr_desc = "기름 안개",
	no_stop_enter_worlmap = true,
	long_desc = function(self, eff) return ("해당 지역 효과 : 화염 공격 피해량 +10% / 화염 저항 -10% / 방어도 -10% / 시야 거리 -2") end,
	decrease = 0, no_remove = true,
	type = "other",
	subtype = { aura=true },
	status = "detrimental",
	zone_wide_effect = true,
	parameters = {},
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "resists", {[DamageType.FIRE]=-10})
		self:effectTemporaryValue(eff, "inc_damage", {[DamageType.FIRE]=10})
		self:effectTemporaryValue(eff, "sight", -2)
		self:effectTemporaryValue(eff, "combat_armor", -math.ceil(self:combatArmor() * 0.1))
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "ZONE_AURA_COLD",
	desc = "Grave chill",
	kr_desc = "묘지의 냉기",
	no_stop_enter_worlmap = true,
	long_desc = function(self, eff) return ("해당 지역 효과 : 냉기 공격 피해량 +10% / 냉기 저항 -10% / 물리내성 -10% / 혼란 면역력 -20%") end,
	decrease = 0, no_remove = true,
	type = "other",
	subtype = { aura=true },
	status = "detrimental",
	zone_wide_effect = true,
	parameters = {},
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "resists", {[DamageType.COLD]=-10})
		self:effectTemporaryValue(eff, "inc_damage", {[DamageType.COLD]=10})
		self:effectTemporaryValue(eff, "confusion_immune", -0.2)
		self:effectTemporaryValue(eff, "combat_physresist", -math.ceil(self:combatPhysicalResist(true) * 0.1))
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "ZONE_AURA_LIGHTNING",
	desc = "Static discharge",
	kr_desc = "정전기 방출",
	no_stop_enter_worlmap = true,
	long_desc = function(self, eff) return ("해당 지역 효과 : 전기 공격 피해량 +10% / 전기 저항 -10% / 물리력 -10% / 기절 면역력 -20%") end,
	decrease = 0, no_remove = true,
	type = "other",
	subtype = { aura=true },
	status = "detrimental",
	zone_wide_effect = true,
	parameters = {},
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "resists", {[DamageType.LIGHTNING]=-10})
		self:effectTemporaryValue(eff, "inc_damage", {[DamageType.LIGHTNING]=10})
		self:effectTemporaryValue(eff, "stun_immune", -0.2)
		self:effectTemporaryValue(eff, "combat_dam", -math.ceil(self:combatPhysicalpower() * 0.1))
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "ZONE_AURA_ACID",
	desc = "Noxious fumes",
	kr_desc = "유독한 연기",
	no_stop_enter_worlmap = true,
	long_desc = function(self, eff) return ("해당 지역 효과 : 산성 공격 피해량 +10% / 산성 저항 -10% / 회피도 -10% / 무장 해제 면역력 -20%") end,
	decrease = 0, no_remove = true,
	type = "other",
	subtype = { aura=true },
	status = "detrimental",
	zone_wide_effect = true,
	parameters = {},
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "resists", {[DamageType.ACID]=-10})
		self:effectTemporaryValue(eff, "inc_damage", {[DamageType.ACID]=10})
		self:effectTemporaryValue(eff, "disarm_immune", -0.2)
		self:effectTemporaryValue(eff, "combat_def", -math.ceil(self:combatDefense(true) * 0.1))
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "ZONE_AURA_DARKNESS",
	desc = "Echoes of the void",
	kr_desc = "공허로부터의 메아리",
	no_stop_enter_worlmap = true,
	long_desc = function(self, eff) return ("해당 지역 효과 : 어둠 공격 피해량 +10% / 어둠 저항 -10% / 정신내성 -10% / 공포 면역력 -20%") end,
	decrease = 0, no_remove = true,
	type = "other",
	subtype = { aura=true },
	status = "detrimental",
	zone_wide_effect = true,
	parameters = {},
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "resists", {[DamageType.DARKNESS]=-10})
		self:effectTemporaryValue(eff, "inc_damage", {[DamageType.DARKNESS]=10})
		self:effectTemporaryValue(eff, "fear_immune", -0.2)
		self:effectTemporaryValue(eff, "combat_mentalresist", -math.ceil(self:combatMentalResist(true) * 0.1))
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "ZONE_AURA_MIND",
	desc = "Eerie silence",
	kr_desc = "으스스한 침묵",
	no_stop_enter_worlmap = true,
	long_desc = function(self, eff) return ("해당 지역 효과 : 정신 공격 피해량 +10% / 정신 저항 -10% / 주문력 -10% / 침묵 면역력 -20%") end,
	decrease = 0, no_remove = true,
	type = "other",
	subtype = { aura=true },
	status = "detrimental",
	zone_wide_effect = true,
	parameters = {},
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "resists", {[DamageType.MIND]=-10})
		self:effectTemporaryValue(eff, "inc_damage", {[DamageType.MIND]=10})
		self:effectTemporaryValue(eff, "silence_immune", -0.2)
		self:effectTemporaryValue(eff, "combat_spellpower", -math.ceil(self:combatSpellpower() * 0.1))
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "ZONE_AURA_LIGHT",
	desc = "Aura of light",
	kr_desc = "빛의 기운",
	no_stop_enter_worlmap = true,
	long_desc = function(self, eff) return ("해당 지역 효과 : 빛 공격 피해량 +10% / 빛 저항 -10% / 정확도 -10% / 실명 면역력 -20%") end,
	decrease = 0, no_remove = true,
	type = "other",
	subtype = { aura=true },
	status = "detrimental",
	zone_wide_effect = true,
	parameters = {},
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "resists", {[DamageType.LIGHT]=-10})
		self:effectTemporaryValue(eff, "inc_damage", {[DamageType.LIGHT]=10})
		self:effectTemporaryValue(eff, "blind_immune", -0.2)
		self:effectTemporaryValue(eff, "combat_atk", -math.ceil(self:combatAttack() * 0.1))
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "ZONE_AURA_ARCANE",
	desc = "Aether residue",
	kr_desc = "에테르 잔여물",
	no_stop_enter_worlmap = true,
	long_desc = function(self, eff) return ("해당 지역 효과 : 마법 공격 피해량 +10% / 마법 저항 -10% / 방어 효율 -10% / 석화 면역력 -20%") end,
	decrease = 0, no_remove = true,
	type = "other",
	subtype = { aura=true },
	status = "detrimental",
	zone_wide_effect = true,
	parameters = {},
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "resists", {[DamageType.ARCANE]=-10})
		self:effectTemporaryValue(eff, "inc_damage", {[DamageType.ARCANE]=10})
		self:effectTemporaryValue(eff, "stone_immune", -0.2)
		self:effectTemporaryValue(eff, "combat_armor_hardiness", -math.ceil(self:combatArmorHardiness() * 0.1))
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "ZONE_AURA_TEMPORAL",
	desc = "Impossible geometries",
	kr_desc = "불가능한 지형",
	no_stop_enter_worlmap = true,
	long_desc = function(self, eff) return ("해당 지역 효과 : 시간 공격 피해량 +10% / 시간 저항 -10% / 주문내성 -10% / 속박 면역력 -20%") end,
	decrease = 0, no_remove = true,
	type = "other",
	subtype = { aura=true },
	status = "detrimental",
	zone_wide_effect = true,
	parameters = {},
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "resists", {[DamageType.TEMPORAL]=-10})
		self:effectTemporaryValue(eff, "inc_damage", {[DamageType.TEMPORAL]=10})
		self:effectTemporaryValue(eff, "pin_immune", -0.2)
		self:effectTemporaryValue(eff, "combat_spellresist", -math.ceil(self:combatSpellResist(true) * 0.1))
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "ZONE_AURA_PHYSICAL",
	desc = "Uncontrolled anger",
	kr_desc = "억제되지 않는 분노",
	no_stop_enter_worlmap = true,
	long_desc = function(self, eff) return ("해당 지역 효과 : 물리 공격 피해량 +10% / 물리 저항 -10% / 정신력 -10% / 밀어내기 면역력 -20%") end,
	decrease = 0, no_remove = true,
	type = "other",
	subtype = { aura=true },
	status = "detrimental",
	zone_wide_effect = true,
	parameters = {},
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "resists", {[DamageType.PHYSICAL]=-10})
		self:effectTemporaryValue(eff, "inc_damage", {[DamageType.PHYSICAL]=10})
		self:effectTemporaryValue(eff, "knockback_immune", -0.2)
		self:effectTemporaryValue(eff, "combat_mindpower", -math.ceil(self:combatMindpower() * 0.1))
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "ZONE_AURA_BLIGHT",
	desc = "Miasma",
	kr_desc = "독기",
	no_stop_enter_worlmap = true,
	long_desc = function(self, eff) return ("해당 지역 효과 : 황폐 공격 피해량 +10% / 황폐 저항 -10% / 치유 효율 -20% / 질병 면역력 -20%") end,
	decrease = 0, no_remove = true,
	type = "other",
	subtype = { aura=true },
	status = "detrimental",
	zone_wide_effect = true,
	parameters = {},
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "resists", {[DamageType.BLIGHT]=-10})
		self:effectTemporaryValue(eff, "inc_damage", {[DamageType.BLIGHT]=10})
		self:effectTemporaryValue(eff, "disease_immune", -0.2)
		self:effectTemporaryValue(eff, "healing_factor", -0.2)
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "ZONE_AURA_NATURE",
	desc = "Slimy floor",
	kr_desc = "질척한 바닥",
	no_stop_enter_worlmap = true,
	long_desc = function(self, eff) return ("해당 지역 효과 : 지연 공격 피해량 +10% / 자연 저항 -10% / 장거리 회피 -10% / 중독 면역력 -20%") end,
	decrease = 0, no_remove = true,
	type = "other",
	subtype = { aura=true },
	status = "detrimental",
	zone_wide_effect = true,
	parameters = {},
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "resists", {[DamageType.NATURE]=-10})
		self:effectTemporaryValue(eff, "inc_damage", {[DamageType.NATURE]=10})
		self:effectTemporaryValue(eff, "poison_immune", -0.2)
		self:effectTemporaryValue(eff, "combat_def_ranged", -math.ceil(self:combatDefenseRanged(true) * 0.1))
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "VAULTED", image = "talents/time_prison.png",
	desc = "In Vault",
	kr_desc = "금고 내부",
	long_desc = function(self, eff) return "금고 경비 : 문이 열릴 때까지 행동 불가능" end,
	decrease = 0, no_remove = true,
	type = "other",
	subtype = { vault=true },
	status = "neutral",
	parameters = {},
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "invulnerable", 1)
		self:effectTemporaryValue(eff, "dont_act", 1)
		self:effectTemporaryValue(eff, "no_timeflow", 1)
		self:effectTemporaryValue(eff, "status_effect_immune", 1)
		self.energy.value = 0
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "CAUTERIZE", image = "talents/cauterize.png",
	desc = "Cauterize",
	kr_desc = "지져짐",
	long_desc = function(self, eff) return ("지져짐 : 매 턴마다 화염 피해 %0.2f"):format(eff.dam) end,
	type = "other",
	subtype = { fire=true },
	status = "detrimental",
	parameters = { dam=10 },
	on_gain = function(self, err) return "#CRIMSON##Target1# 죽음의 순간, 불꽃으로 상처를 지져 위기를 넘깁니다!", "+지져짐" end,
	on_lose = function(self, err) return "#CRIMSON##Target# 주변의 불꽃이 사그러들었습니다.", "-지져짐" end,
	on_merge = function(self, old_eff, new_eff)
		old_eff.dur = new_eff.dur
		old_eff.dam = old_eff.dam + new_eff.dam
		return old_eff
	end,
	activate = function(self, eff)
		self.life = self.old_life or 10
		eff.invulnerable = true
		eff.particle1 = self:addParticles(Particles.new("inferno", 1))
		eff.particle2 = self:addParticles(Particles.new("inferno", 1))
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle1)
		self:removeParticles(eff.particle2)
	end,
	on_timeout = function(self, eff)
		if eff.invulnerable then
			eff.dur = eff.dur + 1
			return
		end
		local dead, val = self:takeHit(eff.dam, self, {special_death_msg="당신은 과격한 응급치료의 불꽃에 타죽었습니다."})

		local srcname = self.x and self.y and game.level.map.seens(self.x, self.y) and self.name:capitalize() or "Something"
		local dtn = DamageType:get(DamageType.FIRE).kr_name or DamageType:get(DamageType.FIRE).name --@ 다음줄 사용 - 너무 길어서 변수로 뺌
		game:delayedLogDamage(eff, self, val, ("%s%d %s#LAST#"):format(DamageType:get(DamageType.FIRE).text_color or "#aaaaaa#", math.ceil(val), dtn), false)
	end,
}

newEffect{
	name = "EIDOLON_PROTECT", image = "shockbolt/npc/unknown_unknown_the_eidolon.png",
	desc = "Protected by the Eidolon",
	kr_desc = "에이돌론의 보호",
	long_desc = function(self, eff) return "에이돌론의 보호 : (스스로를 제외한) 그 어떤 존재도 해를 끼칠 수 없음" end,
	zone_wide_effect = true,
	decrease = 0, no_remove = true,
	type = "other",
	subtype = { eidolon=true },
	status = "neutral",
	parameters = {},
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "invulnerable_others", 1)
	end,
	deactivate = function(self, eff)
	end,
}


newEffect{
	name = "CLOAK_OF_DECEPTION", image = "shockbolt/object/artifact/black_cloak.png",
	desc = "Cloak of Deception",
	kr_desc = "기만의 망토",
	long_desc = function(self, eff) return "기만의 망토 효과 : 살아있는 존재로 보임" end,
	decrease = 0, no_remove = true,
	type = "other",
	subtype = { undead=true },
	status = "neutral",
	parameters = {},
	activate = function(self, eff)
		self.old_faction_cloak = self.faction
		self.faction = "allied-kingdoms"
		if self.descriptor and self.descriptor.race and self:attr("undead") then self.descriptor.fake_race = "Human" end
		if self.descriptor and self.descriptor.subrace and self:attr("undead") then self.descriptor.fake_subrace = "Cornac" end
		if self.player then engine.Map:setViewerFaction(self.faction) end
	end,
	deactivate = function(self, eff)
		self.faction = self.old_faction_cloak
		if self.descriptor and self.descriptor.race and self:attr("undead") then self.descriptor.fake_race = nil end
		if self.descriptor and self.descriptor.subrace and self:attr("undead") then self.descriptor.fake_subrace = nil end
		if self.player then engine.Map:setViewerFaction(self.faction) end
	end,
}

newEffect{
	name = "SUFFOCATING",
	desc = "Suffocating",
	kr_desc = "숨막힘",
	long_desc = function(self, eff) return ("숨막힘! : 매 턴마다 생명력 감소 (현재 : 최대 생명력의 %d%%) / 매 턴마다 생명력 감소량이 증가"):format(eff.dam) end,
	type = "other",
	subtype = { suffocating=true },
	status = "detrimental",
	decrease = 0, no_remove = true,
	parameters = { dam=20 },
	on_gain = function(self, err) return "#Target1# 숨을 쉬지 못하게 되었습니다.", "+숨막힘" end,
	on_lose = function(self, err) return "#Target1# 다시 숨을 쉬기 시작합니다.", "-숨막힘" end,
	on_timeout = function(self, eff)
		if self.air > self.air_regen then -- We must be over our natural regen
			self:removeEffect(self.EFF_SUFFOCATING, false, true)
			return
		end

		-- Bypass all shields & such
		local old = self.onTakeHit
		self.onTakeHit = nil
		mod.class.interface.ActorLife.takeHit(self, self.max_life * eff.dam / 100, self, {special_death_msg="당신은 숨이 막혀 죽었습니다."})
		eff.dam = util.bound(eff.dam + 5, 20, 100)
		self.onTakeHit = old
	end,
}

newEffect{
	name = "ANTIMAGIC_DISRUPTION",
	desc = "Antimagic Disruption",
	kr_desc = "마법 방해",
	long_desc = function(self, eff) return ("착용한 반마법 장비에 의해, 마법의 힘이 방해받음"):format() end,
	type = "other",
	subtype = { antimagic=true },
	no_stop_enter_worlmap = true,
	status = "detrimental",
	decrease = 0, no_remove = true,
	parameters = { },
	on_timeout = function(self, eff)
		if not self:attr("has_arcane_knowledge") or not self:attr("spellpower_reduction") then
			self:removeEffect(self.EFF_ANTIMAGIC_DISRUPTION, true, true)
		end
	end,
}

newEffect{
	name = "SWIFT_HANDS_CD", image = "talents/swift_hands.png",
	desc = "Swift Hands",
	kr_desc = "빠른 손놀림",
	long_desc = function(self, eff) return "이번 턴에 시간 소모 없이 장비를 교체했습니다." end,
	type = "other",
	subtype = { prodigy=true },
	status = "neutral",
	parameters = { },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "quick_wear_takeoff_disable", 1)
	end,
}

newEffect{
	name = "HUNTER_PLAYER", image = "talents/hunted_player.png",
	desc = "Hunter!",
	kr_desc = "사냥꾼!",
	long_desc = function(self, eff) return "네가 어디 있는지 알라!" end,
	type = "other",
	subtype = { madness=true },
	status = "beneficial",
	parameters = { },
	activate = function(self, eff)
		if not self.ai_state then return end
		self:effectTemporaryValue(eff, {"ai_state","ai_move"}, "move_astar")
		self:setTarget(eff.src)
	end,
}

newEffect{
	name = "THROUGH_THE_CROWD", image = "talents/through_the_crowd.png",
	desc = "Through The Crowd",
	kr_desc = "군중 속으로",
	long_desc = function(self, eff) return ("모든 내성 %d 증가"):format(eff.power) end,
	type = "other",
	subtype = { miscellaneous=true },
	status = "beneficial",
	parameters = { power=10 },
	activate = function(self, eff)
		eff.presid = self:addTemporaryValue("combat_physresist", eff.power)
		eff.sresid = self:addTemporaryValue("combat_spellresist", eff.power)
		eff.mresid = self:addTemporaryValue("combat_mentalresist", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_physresist", eff.presid)
		self:removeTemporaryValue("combat_spellresist", eff.sresid)
		self:removeTemporaryValue("combat_mentalresist", eff.mresid)
	end,
}

newEffect{
	name = "RELOAD_DISARMED", image = "talents/disarm.png",
	desc = "Reloading",
	kr_desc = "재장전",
	long_desc = function(self, eff) return "탄환 재장전." end,
	type = "other",
	subtype = { disarm=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target2# 무장해제 되었습니다!", "+무장해제" end,
	on_lose = function(self, err) return "#Target1# 재무장 하였습니다.", "-무장해제" end,
	activate = function(self, eff)
		self:removeEffect(self.EFF_COUNTER_ATTACKING) -- Cannot parry or counterattack while disarmed
		self:removeEffect(self.EFF_DUAL_WEAPON_DEFENSE) 
		eff.tmpid = self:addTemporaryValue("disarmed", 1)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("disarmed", eff.tmpid)
	end,
}

newEffect{
	name = "SPACETIME_TUNING", image = "talents/spacetime_tuning.png",
	desc = "Spacetime Tuning",
	kr_desc = "시공간 조율",
	long_desc = function(self, eff) return ("매 턴마다 %d 씩 괴리 수치 조율."):format(eff.power) end,
	type = "other",
	subtype = { time=true },
	status = "beneficial",
	parameters = { power=10},
	on_gain = function(self, err) return "#Target1# 시공간의 구조를 재조정합니다.", "+시공간 조율" end,
	on_timeout = function(self, eff)
		if not self.resting then
			self:removeEffect(self.EFF_SPACETIME_TUNING)
		else
			self:incParadox(eff.power)
		end
	end,
}
