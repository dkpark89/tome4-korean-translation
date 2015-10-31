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

local Particles = require "engine.Particles"

newBirthDescriptor{
	type = "class",
	name = "Chronomancer",
	locked = function() return profile.mod.allow_build.chronomancer end,
	locked_desc = "Some do not walk upon the straight road others follow. Seek the hidden paths outside the normal course of life.",
	desc = {
		"Exploiting a hole in the fabric of spacetime, Chronomancers learn to pull threads from other timelines into their own.",
		"Pulling these threads creates tension and the harder they pull the more tension is produced.",
		"Constantly they manage this tension, which they call Paradox, to avoid or control the anomalies they inevitably unleash on the world around them.",
	},
	descriptor_choices =
	{
		subclass =
		{
			__ALL__ = "disallow",
			["Paradox Mage"] = "allow",
			["Temporal Warden"] = "allow",
		},
	},
	copy = {
		-- Chronomancers start in Point Zero
		class_start_check = function(self)
			if self.descriptor.world == "Maj'Eyal" and (self.descriptor.race ~= "Undead" and self.descriptor.race ~= "Dwarf" and self.descriptor.race ~= "Yeek") and not self._forbid_start_override then
				self.chronomancer_race_start_quest = self.starting_quest
				self.default_wilderness = {"zone-pop", "angolwen-portal"}
				self.starting_zone = "town-point-zero"
				self.starting_quest = "start-point-zero"
				self.starting_intro = "chronomancer"
				self.faction = "keepers-of-reality"
				self:learnTalent(self.T_TELEPORT_POINT_ZERO, true, nil, {no_unlearn=true})
			end
			self:triggerHook{"BirthStartZone:chronomancer"}
		end,
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Paradox Mage",
	locked = function() return profile.mod.allow_build.chronomancer_paradox_mage end,
	locked_desc = "A hand may clap alone if it returns to clap itself. Search for the power in the paradox.",
	desc = {
		"A Paradox Mage studies the very fabric of spacetime, learning not just to bend it but shape it and remake it.",
		"Most Paradox Mages lack basic skills that others take for granted (like general fighting sense), but they make up for it through control of cosmic forces.",
		"Paradox Mages start off with knowledge of all but the most complex Chronomantic schools.",
		"Their most important stats are: Magic and Willpower",
		"#GOLD#Stat modifiers:",
		"#LIGHT_BLUE# * +0 Strength, +0 Dexterity, +2 Constitution",
		"#LIGHT_BLUE# * +5 Magic, +2 Willpower, +0 Cunning",
		"#GOLD#Life per level:#LIGHT_BLUE# +0",
	},
	power_source = {arcane=true},
	random_rarity = 2,
	stats = { mag=5, wil=2, con=2, },
	birth_example_particles = {
		function(actor)
			if core.shader.active(4) then
				actor:addParticles(Particles.new("shader_ring_rotating", 1, {rotation=-0.01, radius=1.2}, {type="stone", hide_center=1, zoom=0.6, color1={0.4, 0.4, 0, 1}, color2={0.5, 0.5, 0, 1}, xy={0, 0}}))
			else
				actor:addParticles(Particles.new("generic_shield", 1, {r=0.4, g=0.4, b=0, a=1}))
			end
		end,
		function(actor)
			if core.shader.allow("adv") then
				actor:addParticles3D("volumetric", {kind="transparent_cylinder", twist=1, shineness=10, density=10, radius=1.4, growSpeed=0.004, img="coggy_00"})
			else
				actor:addParticles(Particles.new("generic_shield", 1, {r=1, g=1, b=0, a=1}))
			end
		end,
		function(actor)
			if core.shader.allow("adv") then
				actor:addParticles3D("volumetric", {kind="fast_sphere", appear=10, radius=1.6, twist=30, density=30, growSpeed=0.004, scrollingSpeed=-0.004, img="continuum_01_3"})
			else
				actor:addParticles(Particles.new("generic_shield", 1, {r=1, g=0, b=0, a=0.5}))
			end
		end,
	},
	talents_types = {
		-- class
		["chronomancy/gravity"]={true, 0.3},
		["chronomancy/matter"]={true, 0.3},
		["chronomancy/spacetime-folding"]={true, 0.3},
		["chronomancy/speed-control"]={true, 0.3},
		["chronomancy/timetravel"]={true, 0.3},
		
		-- locked class
		["chronomancy/flux"]={false, 0.3},
		["chronomancy/spellbinding"]={false, 0.3},
		["chronomancy/stasis"]={false, 0.3},
		["chronomancy/timeline-threading"]={false, 0.3},

		-- generic
		["chronomancy/chronomancy"]={true, 0.3},
		["chronomancy/fate-weaving"]={true, 0.3},
		["chronomancy/spacetime-weaving"]={true, 0.3},

		-- locked generic
		["chronomancy/energy"]={false, 0.3},
		["cunning/survival"]={false, 0},	
	},
	talents = {
		[ActorTalents.T_TEMPORAL_BOLT] = 1,
		[ActorTalents.T_DIMENSIONAL_STEP] = 1,
		[ActorTalents.T_REPULSION_BLAST] = 1,
		[ActorTalents.T_PRECOGNITION] = 1,
	},
	copy = {
		max_life = 90,
		resolvers.equipbirth{ id=true,
			{type="weapon", subtype="staff", name="elm staff", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="cloth", name="linen robe", autoreq=true, ego_chance=-1000},
		},
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Temporal Warden",
	locked = function() return profile.mod.allow_build.chronomancer_temporal_warden end,
	locked_desc = "We preserve the past to protect the future. The hands of time are guarded by the arms of war.",
	desc = {
		"Their lifelines braided, Temporal Wardens have learned to work with their other selves across multiple timelines.",
		"Through their study of chronomancy, they learn to blend archery and dual-weapon fighting, seamlessly switching from one to the other.",
		"Their most important stats are: Magic, Dexterity, and Willpower",
		"#GOLD#Stat modifiers:",
		"#LIGHT_BLUE# * +0 Strength, +3 Dexterity, +0 Constitution",
		"#LIGHT_BLUE# * +4 Magic, +2 Willpower, +0 Cunning",
		"#GOLD#Life per level:#LIGHT_BLUE# +2",
	},
	power_source = {technique=true, arcane=true},
	random_rarity = 2,
	stats = { wil=2, dex=3, mag=4},
	birth_example_particles = {
		function(actor)
			if core.shader.allow("adv") then
				actor:addParticles3D("volumetric", {kind="fast_sphere", shininess=40, density=40, radius=1.4, scrollingSpeed=0.001, growSpeed=0.004, img="squares_x3_01"})
			else
				actor:addParticles(Particles.new("arcane_power", 1))
			end
		end,
		function(actor)
			if core.shader.active(4) then
				actor:addParticles(Particles.new("shader_shield", 1, {toback=true ,size_factor=1.5, y=-0.3, img="healparadox", life=25}, {type="healing", time_factor=3000, beamsCount=15, noup=2.0, beamColor1={0xb6/255, 0xde/255, 0xf3/255, 1}, beamColor2={0x5c/255, 0xb2/255, 0xc2/255, 1}}))
				actor:addParticles(Particles.new("shader_shield", 1, {toback=false,size_factor=1.5, y=-0.3, img="healparadox", life=25}, {type="healing", time_factor=3000, beamsCount=15, noup=1.0, beamColor1={0xb6/255, 0xde/255, 0xf3/255, 1}, beamColor2={0x5c/255, 0xb2/255, 0xc2/255, 1}}))
			end
		end,
	},
	talents_types = {
		-- class
		["chronomancy/blade-threading"]={true, 0.3},
		["chronomancy/bow-threading"]={true, 0.3},
		["chronomancy/guardian"]={true, 0.3},
		["chronomancy/spacetime-folding"]={true, 0.3},
		["chronomancy/speed-control"]={true, 0.3},
		["chronomancy/temporal-combat"]={true, 0.3},
		
		-- class locked
		["chronomancy/stasis"]={false, 0.1},
		["chronomancy/threaded-combat"]={false, 0.3},
		["chronomancy/temporal-hounds"]={false, 0.3},
		
		-- generic
		["technique/combat-training"]={true, 0.3},
		["chronomancy/chronomancy"]={true, 0.3},
		["chronomancy/spacetime-weaving"]={true, 0.3},
		
		-- generic locked
		["chronomancy/fate-weaving"]={false, 0.1},
		["cunning/survival"]={false, 0},
	},
	talents = {
		[ActorTalents.T_SHOOT] = 1,
		[ActorTalents.T_WEAPON_COMBAT] = 1,
		
		[ActorTalents.T_WARP_BLADE] = 1,
		[ActorTalents.T_ARROW_STITCHING] = 1,
		[ActorTalents.T_DIMENSIONAL_STEP] = 1,
		[ActorTalents.T_STRENGTH_OF_PURPOSE] = 1,
	},
	copy = {
		max_life = 100,
		resolvers.equipbirth{ id=true,
			{type="weapon", subtype="longbow", name="elm longbow", autoreq=true, ego_chance=-1000},
			{type="ammo", subtype="arrow", name="quiver of elm arrows", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="light", name="rough leather armour", autoreq=true, ego_chance=-1000}
		},
		resolvers.inventorybirth{ id=true, inven="QS_MAINHAND",
			{type="weapon", subtype="longsword", name="iron longsword", autoreq=true, ego_chance=-1000},
		},
		resolvers.inventorybirth{ id=true, inven="QS_OFFHAND",
			{type="weapon", subtype="dagger", name="iron dagger", autoreq=true, ego_chance=-1000},	
		},
		resolvers.generic(function(e)
			e.auto_shoot_talent = e.T_SHOOT
		end),
	},
	copy_add = {
		life_rating = 2,
	},
}
