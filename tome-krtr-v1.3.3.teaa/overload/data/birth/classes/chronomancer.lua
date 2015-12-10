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
	kr_name = "시공 제어사 (Chronomancer)",
	locked = function() return profile.mod.allow_build.chronomancer end,
	locked_desc = "남들과 같은 인생을 따라가지 않고, 시간의 샛길을 거니는 자들도 있다. 평범한 일상에서 벗어나, 숨겨진 길을 찾으라.",
	desc = {
		"말 그대로 한 쪽 발은 과거를, 다른 쪽 발은 미래를 딛고 있는 시공 제어사는, 멋대로 현실을 주무를 수 있으며 섭리의 자정작용에만 복종하는 힘으로 무장했습니다. 그들이 시공에 남긴 괴리는 시간을 제어하는 힘을 더욱 강대하고 제어하기 어렵게 만듭니다. 현명한 시공 제어사는 자신의 힘을 증폭시키기 위해 시공에 낸 구멍이 자신을 삼켜버릴 구멍이 될 수도 있다는 것을 알기에, 힘에 대한 갈망과 섭리를 수호하기 위한 대우주의 의지 사이에서 균형을 유지하는 방법을 배웁니다.",
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
	kr_name = "괴리 마법사 (Paradox Mage)",
	locked = function() return profile.mod.allow_build.chronomancer_paradox_mage end,
	locked_desc = "한 손을 두고 시간을 되돌려 그 손을 치면, 한 손으로도 박수를 칠 수 있다. 괴리에서 힘을 구하라.",
	desc = {
		"괴리 마법사는 시공간의 구조를 연구하여, 시공을 구부리는 것 뿐만이 아니라 형성하기도 하고 재구성하기도 합니다.",
		"괴리 마법사는 기본적인 전투기술이 떨어지지만, 대신 시공을 제어하는 강력한 힘을 지녔습니다.",
		"괴리 마법사는 정교한 시공 제어 마법 이외엔 아는 것이 거의 없습니다.",
		"가장 중요한 능력치는 마법과 의지입니다.",
		"#GOLD#능력치 변화 :",
		"#LIGHT_BLUE# * 힘+0, 민첩+0, 체격+2",
		"#LIGHT_BLUE# * 마법+5, 의지+2, 교활함+0",
		"#GOLD#레벨 당 생명력 :#LIGHT_BLUE# +0",
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
	kr_name = "시간의 감시자 (Temporal Warden)",
	locked = function() return profile.mod.allow_build.chronomancer_temporal_warden end,
	locked_desc = "우리는 미래를 위해 과거를 수호한다. 시간의 손길을 보호하는 것은 전투의 병기일지니.",
	desc = {
		"시간의 감시자는 사격술과 쌍수 무기술, 그리고 시공 제어 마법을 조합하여 엄청난 결과를 만들어냈습니다.",
		"적들에게 화살을 퍼붓고 근접전을 벌이면서, 시공 제어 마법으로 전장을 다스립니다.",
		"시공 제어 마법을 연구하여, 신체와 마법능력을 증폭시키고 자신과 다른 이들의 속도를 제어할 수 있게 되었습니다.",
		"가장 중요한 능력치는 힘과 민첩, 의지, 그리고 마법입니다.",
		"#GOLD#능력치 변화 :",
		"#LIGHT_BLUE# * 힘+0, 민첩+0, 체격+0",
		"#LIGHT_BLUE# * 마법+4, 의지+2, 교활함+0",
		"#GOLD#레벨 당 생명력 :#LIGHT_BLUE# +2",
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
