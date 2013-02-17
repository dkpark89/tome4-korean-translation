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

local default_eyal_descriptors = function(add)
	local base = {

	race =
	{
		__ALL__ = "disallow",
		Human = "allow",
		Elf = "allow",
		Dwarf = "allow",
		Halfling = "allow",
		Yeek = "allow",
		Undead = "allow",
		Construct = "allow",
	},

	class =
	{
		__ALL__ = "disallow",
		Psionic = "allow",
		Warrior = "allow",
		Archer = "allow",
		Rogue = "allow",
		Mage = "allow",
		Celestial = "allow",
		Wilder = "allow",
		Defiler = "allow",
		Afflicted = "allow",
		Chronomancer = "allow",
		Psionic = "allow",
		Adventurer = "allow",
	},
	subclass =
	{
		-- Nobody should be a sun paladin & anorithil but humans & elves
		['Sun Paladin'] = "nolore",
		Anorithil = "nolore",
		-- Nobody should be an archmage but human, elves, halflings and undeads
		Archmage = "nolore",
	},
}
	if add then table.merge(base, add) end
	return base
end

-- Player worlds/campaigns
newBirthDescriptor{
	type = "world",
	name = "Maj'Eyal",
	display_name = "Maj'Eyal: The Age of Ascendancy",
	kr_display_name = "마즈'에이알 : 주도의 시대",
	desc =
	{
		"마즈'에이알에 사는 종족은 인간, 하플링, 엘프, 그리고 드워프입니다.",
		"알려진 바에 의하면 세상은 100 년 넘게 평화를 유지해왔고, 여러 종족들은 다시 번영을 구가하고 있습니다.",
		"당신은 보물과 영광을 찾아 길을 떠난 모험가입니다.",
		"하지만 세상의 그늘 속에는 무엇이 도사리고 있을지...",
	},
	descriptor_choices = default_eyal_descriptors{},
	game_state = {
		campaign_name = "maj-eyal",
		__allow_rod_recall = true,
		__allow_transmo_chest = true,
	},
}

newBirthDescriptor{
	type = "world",
	name = "Infinite",
	display_name = "Infinite Dungeon: The Neverending Descent",
	kr_display_name = "무한의 던전 : 끝없는 내리막",
	locked = function() return profile.mod.allow_build.campaign_infinite_dungeon end,
	locked_desc = "더 깊게, 끝없이, 멈추지 않고, 내려가네. 옛 폐허속, 잠긴 문을 지나, 수수께끼가 풀리면, 그대의 운명과 마주하리.",
	desc =
	{
		"가장 마음에 드는 종족과 직업을 골라서 무한의 던전에 도전하십시오.",
		"얼마나 더 깊게 내려갈 수 있을지는 전적으로 당신의 실력에 달렸습니다!",
		"무한의 던전 내에서 당신에게 한계란 없습니다. 50 레벨을 넘어서도 계속 능력치와 기술 점수를 얻으며 성장할 수 있습니다.",
		"50 레벨 이후 레벨이 상승할 때마다, 능력치의 한계가 1 씩 증가합니다.",
		"50 레벨 이후 10 레벨이 상승할 때마다, 모든 기술의 한계 레벨이 1 씩 증가합니다.",
	},
	descriptor_choices = default_eyal_descriptors{ difficulty = { Tutorial = "never"} },
	copy = {
		-- Can levelup forever
		resolvers.generic(function(e) e.max_level = nil end),
		no_points_on_levelup = function(self)
			if self.level <= 50 then
				self.unused_stats = self.unused_stats + (self.stats_per_level or 3) + self:getRankStatAdjust()
				self.unused_talents = self.unused_talents + 1
				self.unused_generics = self.unused_generics + 1
				if self.level % 5 == 0 then self.unused_talents = self.unused_talents + 1 end
				if self.level % 5 == 0 then self.unused_generics = self.unused_generics - 1 end
				if self.level == 10 or self.level == 20 or self.level == 36 or self.level == 46 then
					self.unused_talents_types = self.unused_talents_types + 1
				end
				if self.level == 30 or self.level == 42 then
					self.unused_prodigies = self.unused_prodigies + 1
				end
				if self.level == 50 then
					self.unused_stats = self.unused_stats + 10
					self.unused_talents = self.unused_talents + 3
					self.unused_generics = self.unused_generics + 3
				end
			else
				self.unused_stats = self.unused_stats + 1
				if self.level % 2 == 0 then
					self.unused_talents = self.unused_talents + 1
				elseif self.level % 3 == 0 then
					self.unused_generics = self.unused_generics + 1
				end
			end
		end,

		resolvers.equip{ id=true, {name="iron pickaxe", ego_chance=-1000}},
		-- Override normal stuff
		before_starting_zone = function(self)
			self.starting_level = 1
			self.starting_level_force_down = nil
			self.starting_zone = "infinite-dungeon"
			self.starting_quest = "infinite-dungeon"
			self.starting_intro = "infinite-dungeon"
		end,
	},
	game_state = {
		campaign_name = "infinite-dungeon",
		__allow_transmo_chest = true,
		is_infinite_dungeon = true,
		ignore_prodigies_special_reqs = true,
	},
}

newBirthDescriptor{
	type = "world",
	name = "Arena",
	display_name = "The Arena: Challenge of the Master",
	kr_display_name = "투기장 : 최강자가 되기 위한 도전",
	locked = function() return profile.mod.allow_build.campaign_arena end,
	locked_desc = "피에 젖은 모래 위에선 강한 자만이 살아남는다. 자신에게 입장 자격이 있음을 증명하라.",
	desc =
	{
		"투기장에서, 밀려오는 도전에 맞서 싸우는 고독한 전투사로 플레이하게 됩니다!",
		"어떠한 종족이나 직업도 선택 가능합니다.",
		"언제까지 버틸 수 있을지 도전해보십시오! 당신이 투기장의 새로운 지배자가 될 수 있을까요?",
		"만약 투기장을 제패하는데 성공한다면, 다음 도전에서는 당신의 캐릭터와 맞붙게 될 것입니다!",
	},
	descriptor_choices = default_eyal_descriptors{ difficulty = { Tutorial = "never" }, permadeath = { Exploration = "never", Adventure = "never" } },
	copy = {
		death_dialog = "ArenaFinish",
		-- Override normal stuff
		before_starting_zone = function(self)
			self.starting_level = 1
			self.starting_level_force_down = nil
			self.starting_zone = "arena"
			self.starting_quest = "arena"
			self.starting_intro = "arena"
		end,
	},
	game_state = {
		campaign_name = "arena",
		is_arena = true,
		ignore_prodigies_special_reqs = true,
	},
}

