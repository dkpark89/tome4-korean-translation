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

newBirthDescriptor{
	type = "class",
	name = "Adventurer",
	display_name = "모험가 (Adventurer)",
	desc = {
		"모험가는 모든 기술을 배워서 쓸 수 있습니다.",
		"#{bold}#모험가는 게임을 클리어하기 위해 추가된 특별 직업이며, 밸런싱이 되지 않았습니다.#{normal}#",
	},
	descriptor_choices =
	{
		subclass =
		{
			__ALL__ = "disallow",
			Adventurer = "allow",
		},
	},
	copy = {
		max_life = 100,
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Adventurer",
	display_name = "모험가 (Adventurer)",
	desc = {
		"모험가는 모든 기술을 배워서 쓸 수 있습니다.",
		"#{bold}#모험가는 게임을 클리어하기 위해 추가된 특별 직업이며, 밸런싱이 되지 않았습니다.#{normal}#",
		"가장 중요한 능력치는 어떤 진로로 갈지에 따라 다릅니다.",
		"#GOLD#능력치 변경:",
		"#LIGHT_BLUE# * 힘+2, 민첩+2, 체격+2",
		"#LIGHT_BLUE# * 마법+2, 의지+2, 교활함+2",
		"#GOLD#레벨 당 생명력:#LIGHT_BLUE# +0",
	},
	not_on_random_boss = true,
	stats = { str=2, con=2, dex=2, mag=2, wil=2, cun=2 },
	talents_types = function(birth)
		local tts = {}
		for _, class in ipairs(birth.all_classes) do
			for _, sclass in ipairs(class.nodes) do if sclass.id ~= "Adventurer" then
				if birth.birth_descriptor_def.subclass[sclass.id].talents_types then
					local tt = birth.birth_descriptor_def.subclass[sclass.id].talents_types
					if type(tt) == "function" then tt = tt(birth) end

					for t, _ in pairs(tt) do
						tts[t] = {false, 0}
					end
				end

				if birth.birth_descriptor_def.subclass[sclass.id].unlockable_talents_types then
					local tt = birth.birth_descriptor_def.subclass[sclass.id].unlockable_talents_types
					if type(tt) == "function" then tt = tt(birth) end

					for t, v in pairs(tt) do
						if profile.mod.allow_build[v[3]] then
							tts[t] = {false, 0}
						end
					end
				end
			end end
		end
		return tts
	end,
	copy_add = {
		unused_generics = 2,
		unused_talent_points = 3,
		unused_talents_types = 7,
	},
	copy = {
		resolvers.inventory{ id=true,
			{type="weapon", subtype="dagger", name="iron dagger", autoreq=true, ego_chance=-1000},
			{type="weapon", subtype="dagger", name="iron dagger", autoreq=true, ego_chance=-1000},
			{type="weapon", subtype="longsword", name="iron longsword", ego_chance=-1000, ego_chance=-1000},
			{type="weapon", subtype="staff", name="elm staff", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="light", name="rough leather armour", ego_chance=-1000, ego_chance=-1000},
			{type="armor", subtype="cloth", name="linen robe", autoreq=true, ego_chance=-1000},
		},
	},
}
