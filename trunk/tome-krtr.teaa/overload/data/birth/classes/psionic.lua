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

local Particles = require "engine.Particles"

newBirthDescriptor{
	type = "class",
	name = "Psionic",
	display_name = "초능력자 (Psionic)",
	locked = function() return profile.mod.allow_build.psionic end,
	locked_desc = "비록 육체가 약하더라도 정신의 단련으로 극복할 수 있다. '길'을 찾고 '길'을 위해 싸워 너의 정신을 개방하라.",
	desc = {
		"초능력자는 자신의 내면에서 힘을 끌어냅니다. 고도의 수련을 거친 정신력으로 다양한 대상에서 에너지를 끌어내 물리적 효과로 변환하여 방출할 수 있습니다.",
	},
	descriptor_choices =
	{
		subclass =
		{
			__ALL__ = "disallow",
			Mindslayer = "allow",
			Psion = "allow",
			Solipsist = "allow",
		},
	},
	copy = {
		psi_regen = 0.2,
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Mindslayer",
	display_name = "정신 파괴자 (Mindslayer)",
	locked = function() return profile.mod.allow_build.psionic_mindslayer end,
	locked_desc = "생각으로 감화시킬 수도 있으며, 생각으로 죽일 수도 있다. 억압과 구속의 세월이 끝나고, 생각이 우리를 자유롭게 할 것이며 우리의 어두운 꿈 속에서 복수가 몰아치리라.",
	desc = {
		"정신 파괴자는 정신력으로 주변을 잔혹하게 파괴하는 일에 특화되어 있습니다.",
		"전투에 돌입하게 되면, 전장의 중심에서 막대한 에너지를 휘두르며 지체없이 주변의 적들을, 염동력으로 제어하는 무기로 베어 넘깁니다.",
		"가장 중요한 능력치는 의지와 교활함입니다.",
		"#GOLD#능력치 변경:",
		"#LIGHT_BLUE# * 힘+1, 민첩+0, 체격+0",
		"#LIGHT_BLUE# * 마법+0, 의지+4, 교활함+4",
		"#GOLD#레벨 당 생명력:#LIGHT_BLUE# -4",
	},
	power_source = {psionic=true},
	stats = { str=1, wil=4, cun=4, },
	birth_example_particles = {
		function(actor)
			if core.shader.active(4) then actor:addParticles(Particles.new("shader_shield", 1, {size_factor=1.1}, {type="shield", time_factor=-10000, llpow=1, aadjust=3, color={1, 0, 0.3}}))
			else actor:addParticles(Particles.new("generic_shield", 1, {r=1, g=0, b=0.3, a=0.5}))
			end
		end,
		function(actor)
			if core.shader.active(4) then actor:addParticles(Particles.new("shader_shield", 1, {size_factor=1.1}, {type="shield", time_factor=-10000, llpow=1, aadjust=3, color={0.3, 1, 1}}))
			else actor:addParticles(Particles.new("generic_shield", 1, {r=0.3, g=1, b=1, a=0.5}))
			end
		end,
		function(actor)
			if core.shader.active(4) then actor:addParticles(Particles.new("shader_shield", 1, {size_factor=1.1}, {type="shield", time_factor=-10000, llpow=1, aadjust=3, color={0.8, 1, 0.2}}))
			else actor:addParticles(Particles.new("generic_shield", 1, {r=0.8, g=1, b=0.2, a=0.5}))
			end
		end,
	},
	talents_types = {
		--Level 0 trees:
		["psionic/absorption"]={true, 0.3},
		["psionic/projection"]={true, 0.3},
		["psionic/psi-fighting"]={true, 0.3},
		["psionic/focus"]={true, 0.3},
		["psionic/mental-discipline"]={true, 0.3},
		["psionic/voracity"]={true, 0.3},
		--Level 10 trees:
		["psionic/finer-energy-manipulations"]={false, 0},
--		["psionic/psi-archery"]={false, 0.3},
		["psionic/grip"]={false, 0},
		["psionic/augmented-mobility"]={false, 0},
		--Miscellaneous trees:
		["cunning/survival"]={true, 0},
		["technique/combat-training"]={true, 0},
	},
	talents = {
		[ActorTalents.T_KINETIC_SHIELD] = 1,
		[ActorTalents.T_KINETIC_AURA] = 1,
		[ActorTalents.T_KINETIC_LEECH] = 1,
		[ActorTalents.T_BEYOND_THE_FLESH] = 1,
		[ActorTalents.T_TELEKINETIC_GRASP] = 1,
		[ActorTalents.T_TELEKINETIC_SMASH] = 1,
	},
	body = { PSIONIC_FOCUS = 1, QS_PSIONIC_FOCUS = 1,},
	copy = {
		max_life = 110,
		resolvers.equip{ id=true,
			{type="armor", subtype="cloth", name="linen robe", autoreq=true, ego_chance=-1000},
			{type="weapon", subtype="greatsword", name="iron greatsword", autoreq=true, ego_chance=-1000},
		},
		resolvers.generic(function(self)
			-- Make and wield some alchemist gems
			local gs = game.zone:makeEntity(game.level, "object", {type="weapon", subtype="greatsword", name="iron greatsword", ego_chance=-1000}, nil, true)
			if gs then
				local pf = self:getInven("PSIONIC_FOCUS")
				if pf then
					self:addObject(pf, gs)
					gs:identify(true)
				end
			end
		end),
	},
	copy_add = {
		life_rating = -4,
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Psion",
	locked = function() return profile.mod.allow_build.psionic_psion and true or "hide"  end,
	locked_desc = "TODO",
	desc = {
		"blahblah",
		"Their most important stats are: Willpower and Cunning",
		"#GOLD#Stat modifiers:",
		"#LIGHT_BLUE# * +1 Strength, +0 Dexterity, +0 Constitution",
		"#LIGHT_BLUE# * +0 Magic, +4 Willpower, +4 Cunning",
		"#GOLD#Life per level:#LIGHT_BLUE# -4",
	},
	not_on_random_boss = true,
	power_source = {psionic=true},
	stats = { str=0, wil=5, cun=4, },
	talents_types = {
		["psionic/possession"]={true, 0.3},
	},
	talents = {
		[ActorTalents.T_POSSESS] = 1,
	},
	copy = {
		max_life = 90,
		resolvers.equip{ id=true,
			{type="armor", subtype="cloth", name="linen robe", autoreq=true, ego_chance=-1000},
			{type="weapon", subtype="mindstar", name="mossy mindstar", autoreq=true, ego_chance=-1000},
			{type="weapon", subtype="mindstar", name="mossy mindstar", autoreq=true, ego_chance=-1000},
		},
	},
	copy_add = {
		life_rating = -4,
	},
}
-- Edge TODO: Unlock stuff
newBirthDescriptor{
	type = "subclass",
	name = "Solipsist",
	display_name = "유아론자 (Solipsist)",
	locked = function() return profile.mod.allow_build.psionic_solipsist end,
	locked_desc = "세계가 그저 그곳에 거하는 자들이 꾸는 꿈의 퇴적에 지나지 않는다 믿는 자도 있다. 잠자는 자를 깨워 꿈의 잠재력을 개방하라.",
	desc = {
		"유아론자는 현실이 그저 경험을 바탕으로한 망상의 축적에 지나지 않으며 조작할 수 있는 것이라고 믿습니다.",
		"그들은 타인의 정신을 침범하거나 꿈을 조작하기 위해 이 지식으로 창조와 파괴를 행합니다.",
		"이 지식의 대가는 크기 때문에, 세계가 자신의 망상일 뿐이라는 생각에 빠지지 않으려면 반드시 정신을 보호해야 합니다.",
		"가장 중요한 능력치는 의지와 교활함입니다.",
		"#GOLD#능력치 변경:",
		"#LIGHT_BLUE# * 힘+0, 민첩+0, 체격+0",
		"#LIGHT_BLUE# * 마법+0, 의지+5, 교활함+4",
		"#GOLD#레벨 당 생명력:#LIGHT_BLUE# -4 (*특수*)",
	},
	power_source = {psionic=true},
	stats = { str=0, wil=5, cun=4, },
	birth_example_particles = {
		function(actor)
			if core.shader.active(4) then actor:addParticles(Particles.new("shader_shield", 1, {size_factor=1.1}, {type="shield", time_factor=-8000, llpow=1, aadjust=7, color={1, 1, 0}}))
			else actor:addParticles(Particles.new("generic_shield", 1, {r=1, g=1, b=0, a=1}))
			end
		end,
	},
	talents_types = {
		-- class
		["psionic/distortion"]={true, 0.3},
		["psionic/dream-smith"]={true, 0.3},
		["psionic/psychic-assault"]={true, 0.3},
		["psionic/slumber"]={true, 0.3},
		["psionic/solipsism"]={true, 0.3},
		["psionic/thought-forms"]={true, 0.3},

		-- generic
		["psionic/dreaming"]={true, 0.3},
		["psionic/feedback"]={true, 0.3},
		["psionic/mentalism"]={true, 0.3},
		["cunning/survival"]={true, 0},

		-- locked trees
		["psionic/discharge"]={false, 0.3},
		["psionic/dream-forge"]={false, 0.3},
		["psionic/nightmare"]={false, 0.3},
	},
	talents = {
		[ActorTalents.T_SLEEP] = 1,

		[ActorTalents.T_MIND_SEAR] = 1,
		[ActorTalents.T_SOLIPSISM] = 1,
		[ActorTalents.T_THOUGHT_FORMS] = 1,
	},
	copy = {
		max_life = 90,
		resolvers.equip{ id=true,
			{type="armor", subtype="cloth", name="linen robe", autoreq=true, ego_chance=-1000},
			{type="weapon", subtype="mindstar", name="mossy mindstar", autoreq=true, ego_chance=-1000},
			{type="weapon", subtype="mindstar", name="mossy mindstar", autoreq=true, ego_chance=-1000},
		},
	},
	copy_add = {
		life_rating = -4,
	},
}
