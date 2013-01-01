﻿-- ToME - Tales of Maj'Eyal
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

local Particles = require "engine.Particles"

newBirthDescriptor{
	type = "class",
	name = "Mage",
	kr_display_name = "마법사 (Mage)",
	desc = {
		"마법사들은 강력한 파괴 주문을 시전하거나 생각만으로도 상처를 치유할 수 있는 신비한 힘을 사용합니다.",
	},
	descriptor_choices =
	{
		subclass =
		{
			__ALL__ = "disallow",
			Alchemist = "allow",
			Archmage = "allow-nochange",
			Necromancer = "allow-nochange",
		},
	},
	copy = {
		mana_regen = 0.5,
		mana_rating = 7,
		resolvers.inscription("RUNE:_MANASURGE", {cooldown=25, dur=10, mana=620}),
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Alchemist",
	kr_display_name = "연금술사 (Alchemist)",
	desc = {
		"연금술사는 마법으로 물질을 조작하는 자들입니다.",
		"스펠블레이즈 이후로는, 자연을 어지럽히는 금지된 옛 마법들을 수련하면 따돌림을 받거나 잡혀죽을 수도 있기 때문에 그런 마법은 사용하지 않습니다.",
		"연금술사는 보석을 변환하여 불덩어리로 만들어 날리거나, 산성액체로 바꿔 쏟아내는 등의 원소 효과를 일으킬 수 있습니다. 또한, 갑옷에 보석을 박아서 마법효과를 부여하거나, 마법 지팡이로 에너지를 방출 할 수도 있습니다.",
		"신체적으로는 약하지만, 마법으로 만든 골렘을 호위로 삼아 데리고 다닙니다. 이 고렘은 주인의 의지를 따르며, 주인의 기예가 향상됨에 따라 강력해집니다.",
		"가장 중요한 능력치는 마법과 체격입니다.",
		"#GOLD#능력치 변경:",
		"#LIGHT_BLUE# * 힘+0, 민첩+0, 체격+3",
		"#LIGHT_BLUE# * 마법+5, 의지+1, 교활함+0",
		"#GOLD#레벨 당 생명력:#LIGHT_BLUE# -1",
	},
	power_source = {arcane=true},
	stats = { mag=5, con=3, wil=1, },
	talents_types = {
		["spell/explosives"]={true, 0.3},
		["spell/infusion"]={true, 0.3},
		["spell/golemancy"]={true, 0.3},
		["spell/advanced-golemancy"]={false, 0.3},
		["spell/stone-alchemy"]={true, 0.3},
		["spell/fire-alchemy"]={false, 0.3},
		["spell/staff-combat"]={true, 0.3},
		["cunning/survival"]={false, -0.1},
	},
	talents = {
		[ActorTalents.T_CREATE_ALCHEMIST_GEMS] = 1,
		[ActorTalents.T_REFIT_GOLEM] = 1,
		[ActorTalents.T_THROW_BOMB] = 1,
		[ActorTalents.T_FIRE_INFUSION] = 1,
		[ActorTalents.T_CHANNEL_STAFF] = 1,
	},
	copy = {
		max_life = 90,
		resolvers.equip{ id=true,
			{type="weapon", subtype="staff", name="elm staff", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="cloth", name="linen robe", autoreq=true, ego_chance=-1000}
		},
		resolvers.inventory{ id=true,
			{type="gem",},
			{type="gem",},
			{type="gem",},
		},
		resolvers.generic(function(self) self:birth_create_alchemist_golem() end),
		innate_alchemy_golem = true,
		birth_create_alchemist_golem = function(self)
			-- Make and wield some alchemist gems
			local t = self:getTalentFromId(self.T_CREATE_ALCHEMIST_GEMS)
			local gem = t.make_gem(self, t, "GEM_AGATE")
			self:wearObject(gem, true, true)
			self:sortInven()

			-- Invoke the golem
			if not self.alchemy_golem then
				local t = self:getTalentFromId(self.T_REFIT_GOLEM)
				t.invoke_golem(self, t)
			end
		end,
	},
	copy_add = {
		life_rating = -1,
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Archmage",
	kr_display_name = "마도사 (Archmage)",
	locked = function() return profile.mod.allow_build.mage end,
	locked_desc = "증오받고, 꺼려지며, 사냥당하고, 숨는다... 우리의 기예는 금지당했지만, 우리의 이유는 정당하다. 감춰진 계곡에서 우리는 세상의 분노로부터 도망쳐 안식을 구하며, 기예를 연마한다. 호의와 우정으로만 우리에게 신뢰받으리라.",
	desc = {
		"마도사는 오로지 마법 연구에만 일생을 바칩니다.",
		"기본적인 전투기술이 떨어지지만, 대신 강력한 마력을 지녔습니다.",
		"마도사는 다양한 마법학파에 대한 지식을 지녔지만, 사령 마법에는 절대로 손을 대지 않습니다.",
		"산 속에 숨겨진 마을인 앙골웬에서 수련하며, 그곳으로 곧장 이동할 수 있는 마법을 가지고 있습니다.",
		"가장 중요한 능력치는 마법과 의지입니다.",
		"#GOLD#능력치 변경:",
		"#LIGHT_BLUE# * 힘+0, 민첩+0, 체격+0",
		"#LIGHT_BLUE# * 마법+5, 의지+3, 교활함+1",
		"#GOLD#레벨 당 생명력:#LIGHT_BLUE# -4",
	},
	power_source = {arcane=true},
	stats = { mag=5, wil=3, cun=1, },
	birth_example_particles = {
		function(actor)
			if core.shader.active(4) then actor:addParticles(Particles.new("shader_ring_rotating", 1, {radius=1.1}, {type="flames", hide_center=0, xy={0, 0}}))
			else actor:addParticles(Particles.new("wildfire", 1))
			end
		end,
		function(actor)
			if core.shader.active(4) then actor:addParticles(Particles.new("shader_ring_rotating", 1, {radius=1.1}, {type="flames", hide_center=0, time_factor=1700, zoom=0.3, npow=1, color1={0.6, 0.3, 0.8, 1}, color2={0.8, 0, 0.8, 1}, xy={0,0}}))
			else actor:addParticles(Particles.new("ultrashield", 1, {rm=180, rM=220, gm=10, gM=50, bm=190, bM=220, am=120, aM=200, radius=0.4, density=100, life=8, instop=20}))
			end
		end,
		function(actor)
			if core.shader.active(4) then actor:addParticles(Particles.new("shader_ring_rotating", 1, {rotation=-0.2, radius=1.1}, {type="sparks", hide_center=0, time_factor=40000, color1={0, 0, 1, 1}, color2={0, 1, 1, 1}, zoom=0.5, xy={0, 0}}))
			else actor:addParticles(Particles.new("uttercold", 1))
			end
		end,
		function(actor)
			if core.shader.active(4) then actor:addParticles(Particles.new("shader_ring_rotating", 1, {rotation=-0.01, radius=1.1}, {type="stone", hide_center=1, xy={0, 0}}))
			else actor:addParticles(Particles.new("crystalline_focus", 1))
			end
		end,
		function(actor)
			if core.shader.active(4) then actor:addParticles(Particles.new("shader_ring_rotating", 1, {radius=1.1}, {type="sparks", hide_center=0, zoom=3, xy={0, 0}}))
			else actor:addParticles(Particles.new("tempest", 1))
			end
		end,
	},
	talents_types = {
		["spell/arcane"]={true, 0.3},
		["spell/aether"]={false, 0.3},
		["spell/fire"]={true, 0.3},
		["spell/earth"]={true, 0.3},
		["spell/water"]={true, 0.3},
		["spell/air"]={true, 0.3},
		["spell/phantasm"]={true, 0.3},
		["spell/temporal"]={false, 0.3},
		["spell/meta"]={false, 0.3},
		["spell/divination"]={true, 0.3},
		["spell/conveyance"]={true, 0.3},
		["spell/aegis"]={true, 0.3},
		["cunning/survival"]={false, -0.1},
	},
	unlockable_talents_types = {
		["spell/wildfire"]={false, 0.3, "mage_pyromancer"},
		["spell/ice"]={false, 0.3, "mage_cryomancer"},
		["spell/stone"]={false, 0.3, "mage_geomancer"},
		["spell/storm"]={false, 0.3, "mage_tempest"},
	},
	talents = {
		[ActorTalents.T_ARCANE_POWER] = 1,
		[ActorTalents.T_FLAME] = 1,
		[ActorTalents.T_LIGHTNING] = 1,
		[ActorTalents.T_PHASE_DOOR] = 1,
	},
	copy = {
		-- Mages start in angolwen
		class_start_check = function(self)
			if self.descriptor.world == "Maj'Eyal" and (self.descriptor.race == "Human" or self.descriptor.race == "Elf" or self.descriptor.race == "Halfling") then
				self.archmage_race_start_quest = self.starting_quest
				self.default_wilderness = {"zone-pop", "angolwen-portal"}
				self.starting_zone = "town-angolwen"
				self.starting_quest = "start-archmage"
				self.starting_intro = "archmage"
				self.faction = "angolwen"
				self:learnTalent(self.T_TELEPORT_ANGOLWEN, true, nil, {no_unlearn=true})
			end
		end,

		max_life = 90,
		resolvers.equip{ id=true,
			{type="weapon", subtype="staff", name="elm staff", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="cloth", name="linen robe", autoreq=true, ego_chance=-1000},
		},
	},
	copy_add = {
		life_rating = -4,
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Necromancer",
	kr_display_name = "사령술사 (Necromancer)",
	locked = function() return profile.mod.allow_build.mage_necromancer end,
	locked_desc = "사자와 동행하며 부정한 지식을 들이킬지니, 사령 마법은 실로 죽음의 길이로다.",
	desc = {
		"스펠블레이즈 이후로 마법에 대한 의혹의 눈초리가 희번덕거렸지만, 사령 마법의 부정한 기예는 훨씬 더 오래전부터 낙인찍혔었습니다.",
		"이 어둠의 마법사들은 힘에 대한 욕망과 궁극의 목적인 '영생'을 위해, 생명의 불꽃을 꺼뜨리며, 죽음을 기만하고, 사자의 군대를 일으킵니다.",
		"가장 중요한 능력치는 마법과 의지입니다.",
		"#GOLD#능력치 변경:",
		"#LIGHT_BLUE# * 힘+0, 민첩+0, 체격+0",
		"#LIGHT_BLUE# * 마법+5, 의지+3, 교활함+1",
		"#GOLD#레벨 당 생명력:#LIGHT_BLUE# -3",
	},
	power_source = {arcane=true},
	stats = { mag=5, wil=3, cun=1, },
	talents_types = {
		["spell/conveyance"]={true, 0.2},
		["spell/divination"]={true, 0.2},
		["spell/necrotic-minions"]={true, 0.3},
		["spell/advanced-necrotic-minions"]={false, 0.3},
		["spell/shades"]={false, 0.3},
		["spell/necrosis"]={true, 0.3},
		["spell/nightfall"]={true, 0.3},
		["spell/grave"]={true, 0.3},
		["cunning/survival"]={true, -0.1},
	},
	unlockable_talents_types = {
		["spell/ice"]={false, 0.2, "mage_cryomancer"},
	},
	birth_example_particles = {
		"necrotic-aura",
		function(actor)
			actor:addParticles(Particles.new("ultrashield", 1, {rm=0, rM=0, gm=0, gM=0, bm=10, bM=100, am=70, aM=180, radius=0.4, density=60, life=14, instop=20}))
		end,
	},
	talents = {
		[ActorTalents.T_NECROTIC_AURA] = 1,
		[ActorTalents.T_CREATE_MINIONS] = 1,
		[ActorTalents.T_ARCANE_EYE] = 1,
		[ActorTalents.T_INVOKE_DARKNESS] = 1,
		[ActorTalents.T_BLURRED_MORTALITY] = 1,
	},
	copy = {
		necrotic_aura_base_souls = 1,
		max_life = 90,
		resolvers.equip{ id=true,
			{type="weapon", subtype="staff", name="elm staff", autoreq=true, ego_chance=-1000},
--			{type="weapon", subtype="dagger", name="iron dagger", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="cloth", name="linen robe", autoreq=true, ego_chance=-1000},
		},
	},
	copy_add = {
		life_rating = -3,
	},
}
