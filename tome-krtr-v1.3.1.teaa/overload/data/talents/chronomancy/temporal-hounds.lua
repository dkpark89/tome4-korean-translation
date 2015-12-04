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

-- Ode to Angband/Tome 2 and all the characters I lost to Time Hounds
summonTemporalHound = function(self, t)  
	if game.zone.wilderness then return false end
	if self.summoner then return false end
	
	local x, y = util.findFreeGrid(self.x, self.y, 8, true, {[Map.ACTOR]=true})
	if not x then
		return false
	end
	
	local m = require("mod.class.NPC").new{
		type = "animal", subtype = "canine",
		display = "C", color=colors.LIGHT_DARK, image = ("npc/temp_hound_0%d.png"):format(rng.range(1, 12)),
		shader = "shadow_simulacrum", shader_args = { color = {0.4, 0.4, 0.1}, base = 0.8, time_factor = 1500 },
		name = "temporal hound",
		kr_name = "시간의 사냥개", 
		faction = self.faction,
		desc = [[조그마한 새끼 강아지의 모습도, 이빨이 빠진 늙은 개의 모습도 동시에 가진 훈련 된 사냥개입니다.]],
		sound_moam = {"creatures/wolves/wolf_hurt_%d", 1, 2}, sound_die = {"creatures/wolves/wolf_hurt_%d", 1, 1},
		
		autolevel = "none",
		ai = "summoned", ai_real = "tactical", ai_state = { ai_move="move_complex", talent_in=5, }, -- Temporal Hounds are smart but have no talents of their own
		stats = {str=0, dex=0, con=0, cun=0, wil=0, mag=0},
		inc_stats = t.incStats(self, t),
		level_range = {self.level, self.level}, exp_worth = 0,
		global_speed_base = 1.2,
		
		no_auto_resists = true,

		max_life = 50,
		life_rating = 12,
		infravision = 10,

		combat_armor = 2, combat_def = 4,
		combat = { dam=self:getTalentLevel(t) * 10, atk=10, apr=10, dammod={str=0.8, mag=0.8}, damtype=DamageType.WARP, sound="creatures/wolves/wolf_attack_1" },
		
		summoner = self, summoner_gain_exp=true,
		resolvers.sustains_at_birth(),
	}
	
	m.unused_stats = 0
	m.unused_talents = 0
	m.unused_generics = 0
	m.unused_talents_types = 0
	m.no_inventory_access = true
	m.no_points_on_levelup = true
	
	m:resolve()
	m:resolve(nil, true)
	
	-- Gain damage, resistances, and immunities
	m.inc_damage = table.clone(self.inc_damage, true)
	m.resists = { [DamageType.PHYSICAL] = t.getResists(self, t)/2, [DamageType.TEMPORAL] = math.min(100, t.getResists(self, t)*2) }
	if self:knowTalent(self.T_COMMAND_BLINK) then
		m:attr("defense_on_teleport", self:callTalent(self.T_COMMAND_BLINK, "getDefense"))
		m:attr("resist_all_on_teleport", self:callTalent(self.T_COMMAND_BLINK, "getDefense"))
	end
	if self:knowTalent(self.T_TEMPORAL_VIGOUR) then
		m:attr("stun_immune", self:callTalent(self.T_TEMPORAL_VIGOUR, "getImmunities"))
		m:attr("blind_immune", self:callTalent(self.T_TEMPORAL_VIGOUR, "getImmunities"))
		m:attr("pin_immune", self:callTalent(self.T_TEMPORAL_VIGOUR, "getImmunities"))
		m:attr("confusion_immune", self:callTalent(self.T_TEMPORAL_VIGOUR, "getImmunities"))
	end
	if self:knowTalent(self.T_COMMAND_BREATHE) then
		m.damage_affinity = { [DamageType.TEMPORAL] = self:callTalent(self.T_COMMAND_BREATHE, "getResists") }
	end
	
	-- Quality of life stuff
	m.life_regen = 1
	m.lite = 1
	m.no_breath = 1
	m.move_others = true
	
	-- Hounds are immune to hostile teleports, mostly so they don't get in the way of banish
	m.teleport_immune = 1
	
	-- Make sure to update sustain counter when we die
	m.on_die = function(self)
		local p = self.summoner:isTalentActive(self.summoner.T_TEMPORAL_HOUNDS)
		local tid = self.summoner:getTalentFromId(self.summoner.T_TEMPORAL_HOUNDS)
		if p then
			p.hounds = p.hounds - 1
			if p.rest_count == 0 then p.rest_count = self.summoner:getTalentCooldown(tid) end
		end
	end
	-- Make sure hounds stay close
	m.on_act = function(self)
		local x, y = self.summoner.x, self.summoner.y
		if game.level:hasEntity(self.summoner) and core.fov.distance(self.x, self.y, x, y) > 10 then
			-- Clear it's targeting on teleport
			if self:teleportRandom(x, y, 0) then
				game.level.map:particleEmitter(x, y, 1, "temporal_teleport")
				self:setTarget(nil)
			end
		end
		-- clean up
		if self.summoner.dead or not game.level:hasEntity(self.summoner) then
			self:die(self)
		end
	end
	-- Unravel?
	m.on_takehit = function(self, value, src)
		if value >= self.life and self.summoner:knowTalent(self.summoner.T_TEMPORAL_VIGOUR) then
			self.summoner:callTalent(self.summoner.T_TEMPORAL_VIGOUR, "doUnravel", self, value)
		end
		return value
	end,
	
	-- Make it look and sound nice :)
	game.zone:addEntity(game.level, m, "actor", x, y)
	game.level.map:particleEmitter(x, y, 1, "temporal_teleport")
	game:playSoundNear(self, "creatures/wolves/wolf_howl_3")
	
	-- And add them to the party
	if game.party:hasMember(self) then
		m.remove_from_party_on_death = true
		game.party:addMember(m, {
			control="no",
			type="hound",
			title="temporal-hound",
			orders = {target=true, leash=true, anchor=true, talents=true},
		})
	end
	
	self:attr("summoned_times", 1)
end

newTalent{
	name = "Temporal Hounds",
	kr_name = "시간의 사냥개",
	type = {"chronomancy/temporal-hounds", 1},
	require = chrono_req_high1,
	mode = "sustained",
	points = 5,
	sustain_paradox = 48,
	no_sustain_autoreset = true,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 10, 45, 15)) end, -- Limit >10
	tactical = { BUFF = 2 },
	callbackOnActBase = function(self, t)
		local p = self:isTalentActive(t.id)
		if p.rest_count > 0 then p.rest_count = p.rest_count - 1 end
		if p.rest_count == 0 and p.hounds < p.max_hounds then
			summonTemporalHound(self, t)
			p.rest_count = self:getTalentCooldown(t)
			p.hounds = p.hounds + 1
		end
	end,
	iconOverlay = function(self, t, p)
		local val = p.rest_count or 0
		if val <= 0 then return "" end
		local fnt = "buff_font"
		return tostring(math.ceil(val)), fnt
	end,
	incStats = function(self, t,fake)
		local mp = self:combatTalentStatDamage(t, "mag", 10, 150) -- Uses magic to avoid Paradox cheese
		return {
			str=10 + (fake and mp or mp),
			dex=10 + (fake and mp or mp),
			con=10 + (fake and mp or mp),
			mag=10 + (fake and mp or mp),
			wil=10 + (fake and mp or mp),
			cun=10 + (fake and mp or mp),
		}
	end,
	getResists = function(self, t)
		return self:combatTalentLimit(t, 100, 15, 50) -- Limit <100%
	end,
	activate = function(self, t)
		-- Let loose the hounds of war!
		summonTemporalHound(self, t)
		
		return {
			rest_count = self:getTalentCooldown(t), 
			hounds = 1, max_hounds = 3
		}
	end,
	deactivate = function(self, t, p)
		-- unsummon the hounds :(
		if game.party:hasMember(self) then
			for i=1, p.hounds do
				local e = game.party:findMember({type="hound"})
				if e and  e.summoner and e.summoner == self and e.name == "temporal hound" then
					e.summon_time = 0
					game.party:removeMember(e, true)
				end
			end
		else
			for _, e in pairs(game.level.entities) do
				if e and e.summoner and e.summoner == self and e.name == "temporal hound" then
					e.summon_time = 0
				end
			end
		end
		return true
	end,
	info = function(self, t)
		local incStats = t.incStats(self, t, true)
		local cooldown = self:getTalentCooldown(t)
		local resists = t.getResists(self, t)
		return ([[유지되는 동안 시간의 사냥개를 소환합니다. 매 %d 턴 마다 다른 사냥개가 소환 될 것입니다(최대 3마리). 
		당신의 사냥개는 당신의 피해량 증가를 물려 받으며, %d%% 의 물리 저항력과 %d%% 의 시간 저항력을 가지고, 순간이동 효과에 면역입니다.
		사냥개는 힘 능력치 %d , 민첩 능력치 %d , 체격 능력치 %d , 마법 능력치 %d , 의지 능력치 %d , 교활 능력치 %d 를 당신의 마법 능력치에 따라 가집니다.]])
		:format(cooldown, cooldown, resists/2, math.min(100, resists*2), incStats.str + 1, incStats.dex + 1, incStats.con + 1, incStats.mag + 1, incStats.wil +1, incStats.cun + 1)
	end
}

newTalent{
	name = "Command Hounds: Blink", short_name="COMMAND_BLINK",
	kr_name = "명령전달: 점멸",
	type = {"chronomancy/temporal-hounds", 2},
	require = chrono_req_high2,
	points = 5,
	paradox = function (self, t) return getParadoxCost(self, t, 10) end,
	cooldown = 10,
	tactical = { ATTACK=2 },
	range = function(self, t) return math.floor(self:combatTalentScale(t, 5, 10, 0.5, 0, 1)) end,
	requires_target = true,
	on_pre_use = function(self, t, silent)
		local p = self:isTalentActive(self.T_TEMPORAL_HOUNDS)
		if not p then
			if not silent then
				game.logPlayer(self, "이 기술을 사용하기 위해서는 시간의 사냥개 기술이 유지되고 있어야 합니다.")
			end
			return false
		end
		return true
	end,
	target = function(self, t)
		return {type="hit", range=self:getTalentRange(t), nolock=true, nowarning=true}
	end,
	direct_hit = true,
	getDefense = function(self, t)
		return self:combatTalentSpellDamage(t, 10, 40, getParadoxSpellpower(self, t))
	end,
	action = function(self, t)
		-- Pick our target
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		if not self:hasLOS(x, y) or game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move") then
			game.logPlayer(self, "당신의 시야 안에 없습니다.")
			return nil
		end
		local __, x, y = self:canProject(tg, x, y)
	
		-- Summon a new Hound
		if self:getTalentLevel(t) >=5 then
			local p = self:isTalentActive(self.T_TEMPORAL_HOUNDS)
			local talent = self:getTalentFromId(self.T_TEMPORAL_HOUNDS)
			if p.hounds < p.max_hounds then
				summonTemporalHound(self, talent)
				p.hounds = p.hounds + 1
			end
		end
	
		-- Find our hounds
		local hnds = {}
		for _, e in pairs(game.level.entities) do
			if e.summoner and e.summoner == self and e.name == "temporal hound" then
				hnds[#hnds+1] = e
			end
		end
		
		-- Blink our hounds
		for i = 1, #hnds do
			if #hnds <= 0 then return nil end
			local a, id = rng.table(hnds)
			table.remove(hnds, id)
			
			game.level.map:particleEmitter(a.x, a.y, 1, "temporal_teleport")
			
			if a:teleportRandom(x, y, 0) then
				if self:knowTalent(self.T_TEMPORAL_VIGOUR) then
					self:callTalent(self.T_TEMPORAL_VIGOUR, "doBlink", a)
				end
				
				game.level.map:particleEmitter(a.x, a.y, 1, "temporal_teleport")
			else
				game.logSeen(self, "주문이 실패하였습니다!")
			end
			
			-- Set the target so we feel like a wolf pack
			if target and self:reactionToward(target) < 0 then
				a:setTarget(target)
			else
				a:setTarget(nil)
			end
			
		end
		game:playSoundNear(self, "talents/teleport")
		
		return true
	end,
	info = function(self, t)
		local defense = t.getDefense(self, t)
		return ([[당신의 사냥개들에게 목표 지점으로 순간이동 하기를 명령합니다. 만약 적을 목표로 한다면 당신의 사냥개들은 이제 그 적을 그들의 목표로 설정 할 것입니다.
		이 기술을 배움으로서, 당신의 사냥개는 순간이동 후에 %d 의 회피율과 %d%% 의 모든 속성 저항력을 추가로 가지게 됩니다.
		기술 레벨이 5에 도달했을 때, 당신이 만약 이 주문을 사냥개를 모두 소환 하지 않은 채로 사용한다면, 새로운 사냥개가 한 마리 소환 될 것입니다.
		순간이동시 추가 회피율과 저항력은 당신의 주문력에 비례하여 상승합니다.]]):format(defense, defense, defense/2, defense/2)
	end,
}

newTalent{
	name = "Temporal Vigour",
	kr_name = "시간의 활력",
	type = {"chronomancy/temporal-hounds", 3},
	require = chrono_req_high3,
	points = 5,
	mode = "passive",
	getImmunities = function(self, t)
		return self:combatTalentLimit(t, 1, 0.15, 0.50) -- Limit <100%
	end,
	getRegen = function(self, t) return self:combatTalentSpellDamage(t, 10, 50, getParadoxSpellpower(self, t)) end,
	getHaste = function(self, t) return self:combatTalentLimit(t, 80, 20, 50)/100 end,
	getDuration = function(self, t) return getExtensionModifier(self, t, math.floor(self:combatTalentScale(t, 1, 3))) end,
	doBlink = function(self, t, hound)  -- Triggered when the hounds is hit
		local regen, haste = t.getRegen(self, t), t.getHaste(self, t)
		if hound:hasEffect(hound.EFF_UNRAVEL) then
			regen = regen * 2
			haste = haste * 2
		end
		hound:setEffect(hound.EFF_REGENERATION, 5, {power=regen}) 
		hound:setEffect(hound.EFF_SPEED, 5, {power=haste})
	end,
	doUnravel = function(self, t, hound, value)
		local die_at = hound.life - value -1
		print("Unravel", die_at)
		hound:setEffect(hound.EFF_UNRAVEL, t.getDuration(self, t), {power=50, die_at=die_at})
		return
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local regen = t.getRegen(self, t)
		local haste = t.getHaste(self, t) * 100
		local immunities = t.getImmunities(self, t) * 100
		return ([[당신의 사냥개는 이제 최대 %d 턴 동안 생명력이 1 미만으로 떨어졌을 때에도 살아남을 수 있습니다. 이 상태에서 사냥개들은 50%% 낮은 피해를 입히지만 모든 피해에 면역 상태가 됩니다.
		이 기술을 배움으로서, 명령전달: 점멸 은 5 턴간 당신의 사냥개들의 생명력을 매턴 %d 만큼 회복시킬 것이며, 그들의 전체 속도를 %d%% 만큼 상승시킵니다. 이 효과가 발동 할 때 사냥개가 생명력이 1 미만이었다면, 이 효과는 두배가 됩니다.
		또한 당신의 사냥개들은 %d%% 의 기절, 실명, 혼란, 속박 면역을 가지게 됩니다.
		
		회복량은 당신의 주문력에 비례하여 상승합니다.]]):format(duration, regen, haste, immunities)
	end
}

newTalent{
	name = "Command Hounds: Breathe", short_name= "COMMAND_BREATHE",  -- Turn Back the Clock multi-breath attack
	kr_name = "명령전달: 숨결",
	type = {"chronomancy/temporal-hounds", 4},
	require = chrono_req_high4,
	points = 5,
	paradox = function (self, t) return getParadoxCost(self, t, 10) end,
	cooldown = 10,
	tactical = { ATTACKAREA = {TEMPORAL = 2}, DISABLE = 2 },
	range = 10,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 4.5, 6.5)) end,
	requires_target = true,
	direct_hit = true,
	on_pre_use = function(self, t, silent)
		local p = self:isTalentActive(self.T_TEMPORAL_HOUNDS)
		if not p or p.hounds < 1 then
			if not silent then
				game.logPlayer(self, "이 기술을 사용하기 위해서는 시간의 사냥개 기술을 유지해야 합니다.")
			end
			return false
		end
		return true
	end,
	getResists = function(self, t)
		return self:combatTalentLimit(t, 100, 15, 50) -- Limit <100%
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 200, getParadoxSpellpower(self, t)) end,
	getDamageStat = function(self, t) return 2 + math.ceil(t.getDamage(self, t) / 15) end,
	getDuration = function(self, t) return getExtensionModifier(self, t, 3) end,
	target = function(self, t)
		return {type="cone", range=0, radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	action = function(self, t)
		-- Grab our hounds and build our multi-targeting display; thanks grayswandir for making this possible
		local tg = {multiple=true}
		local hounds = {}
		local grids = core.fov.circle_grids(self.x, self.y, self:getTalentRange(t), true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local a = game.level.map(x, y, Map.ACTOR)
			if a and a.summoner == self and a.name == "temporal hound" then
				hounds[#hounds+1] = a
				tg[#tg+1] = {type="cone", range=0, radius=self:getTalentRadius(t), start_x=a.x, start_y=a.y, selffire=false, talent=t}
			end
		end end
		
		-- Pick a target
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		
		-- Switch our targeting type back
		local tg = self:getTalentTarget(t)
		
		-- Now...  we breath time >:)
		for i = 1, #hounds do
			if #hounds <= 0 then break end
			local a, id = rng.table(hounds)
			table.remove(hounds, id)
			
			tg.start_x, tg.start_y = a.x, a.y
			local dam = a:spellCrit(t.getDamage(self, t)) -- hound crit but our spellpower, mostly so it looks right
			
			a:project(tg, x, y, function(px, py)
				local target = game.level.map(px, py, Map.ACTOR)
				if target and target ~= a.summoner then
					DamageType:get(DamageType.TEMPORAL).projector(a, px, py, DamageType.TEMPORAL, dam)
					-- Don't turn back the clock other hounds
					if target.name ~= "temporal hound" then
						target:setEffect(target.EFF_REGRESSION, t.getDuration(self, t), {power=t.getDamageStat(self, t), apply_power=a:combatSpellpower(),  min_dur=1, no_ct_effect=true})	
					end
				end
			end)
			
			game.level.map:particleEmitter(a.x, a.y, tg.radius, "breath_time", {radius=tg.radius, tx=x-a.x, ty=y-a.y})
		end
		
		game:playSoundNear(self, "talents/breath")
		
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local radius = self:getTalentRadius(t)
		local stat_damage = t.getDamageStat(self, t)
		local duration =t.getDuration(self, t)
		local affinity = t.getResists(self, t)
		return ([[당신의 사냥개들에게 시간의 숨결을 내뿜게 명령합니다. 시간의 숨결은 %0.2f 의 시간 피해를 %d 원뿔 모양으로 입히며, 공격 당한 목표들은 가장 높은 세가지의 능력치가 감소 됩니다. 능력치들은 %d 만큼 %d 턴 동안 감소됩니다.
		당신은 당신의 사냥개로 부터의 숨결에 대해 면역이고, 사냥개들은 능력치 감소에 대해 면역입니다.
		당신이 이 기술을 배움으로서, 당신의 사냥개들은 이제 %d%% 시간 피해 친화를 얻습니다.]]):format(damDesc(self, DamageType.TEMPORAL, damage), radius, stat_damage, duration, affinity)
	end,
}
