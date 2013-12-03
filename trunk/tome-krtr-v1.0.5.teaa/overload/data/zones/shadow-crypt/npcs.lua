﻿-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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

load("/data/general/npcs/shade.lua", rarity(0))
load("/data/general/npcs/orc-rak-shor.lua", rarity(10))

load("/data/general/npcs/all.lua", function(e) if e.rarity then e.shade_rarity, e.rarity = e.rarity, nil end end)

local Talents = require("engine.interface.ActorTalents")

newEntity{ base="BASE_NPC_ORC_RAK_SHOR", define_as = "CULTIST_RAK_SHOR",
	name = "Rak'Shor Cultist", color=colors.VIOLET, unique = true,
	kr_name = "락'쇼르 광신도",
	desc = [[검은 로브를 입은, 늙은 오크입니다. 그림자를 만들어낸 원흉으로 보입니다.]],
	killer_message = "하지만 누구도 왜 갑자기 #sex# 악인이 되었는지 알지 못했습니다.",
	level_range = {35, nil}, exp_worth = 2,
	rank = 4,
	max_life = 150, life_rating = 17, fixed_rating = true,
	infravision = 10,
	stats = { str=15, dex=10, cun=42, mag=16, con=14 },
	move_others=true,

	instakill_immune = 1,
	disease_immune = 1,
	confusion_immune = 1,
	combat_armor = 10, combat_def = 10,

	open_door = true,

	autolevel = "caster",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"ranged",
	resolvers.inscriptions(3, "rune"),

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },

	resolvers.equip{
		{type="weapon", subtype="staff", force_drop=true, tome_drops="boss", forbid_power_source={antimagic=true}, autoreq=true},
	},
	resolvers.drops{chance=20, nb=1, {defined="JEWELER_TOME"} },
	resolvers.drops{chance=100, nb=1, {defined="LIFE_DRINKER", random_art_replace={chance=75}} },
	resolvers.drops{chance=100, nb=5, {tome_drops="boss"} },

	inc_damage = {[DamageType.BLIGHT] = -30},

	resolvers.talents{
		[Talents.T_SOUL_ROT]=5,
		[Talents.T_BLOOD_GRASP]=5,
		[Talents.T_BONE_SHIELD]=5,
		[Talents.T_EVASION]=5,
		[Talents.T_VIRULENT_DISEASE]=5,
		[Talents.T_CYST_BURST]=3,
		[Talents.T_EPIDEMIC]=4,
		[Talents.T_WORM_ROT]=4,
	},
	resolvers.sustains_at_birth(),

	on_takehit = function(self, value, src)
		local p = self.sustain_talents[self.T_BONE_SHIELD]

		-- When the bone shield is taken down, copy the player
		if p and #p.particles <= 0 and not self.copied_player then
			local a = mod.class.NPC.new{}
			a:replaceWith(game.player:resolveSource():cloneFull())
			mod.class.NPC.castAs(a)
			engine.interface.ActorAI.init(a, a)
			a.no_drops = true
			a.energy.value = 0
			a.player = nil
			a.rank = 4
			a.kr_name = (a.kr_name or a.name).."의 파멸한 그림자"
			a.name = "Doomed Shade of "..a.name
			a.killer_message = "하지만 누구도 왜 갑자기 #sex#가 악인이 되었는지 알지 못했습니다."
			a.color_r = 150 a.color_g = 150 a.color_b = 150
			a:removeAllMOs()
			a.ai = "tactical"
			a.puuid = nil
			a.ai_state = {talent_in=1}
			a.faction = self.faction
			a.inc_damage.all = (a.inc_damage.all or 0) - 40
			a.max_life = a.max_life * 1.2
			a.life = a.max_life
			a.on_die = function(self)
				world:gainAchievement("SHADOW_CLONE", game.player)
				game:setAllowedBuild("afflicted")
				game:setAllowedBuild("afflicted_doomed", true)
				game.level.map(self.x, self.y, game.level.map.TERRAIN, game.zone.grid_list.UP_WILDERNESS)
				game.logSeen(self, "당신의 그림자가 소멸하자, 마법의 장막이 사라지고 계단이 나타납니다.")
			end

			-- Remove some talents
			local tids = {}
			for tid, _ in pairs(a.talents) do
				local t = a:getTalentFromId(tid)
				if t.no_npc_use then tids[#tids+1] = t end
			end
			for i, t in ipairs(tids) do
				if t.mode == "sustained" and a:isTalentActive(t.id) then a:forceUseTalent(t.id, {ignore_energy=true}) end
				a.talents[t.id] = nil
			end

			-- Add some
			a.talents[a.T_UNNATURAL_BODY] = 7
			a.talents[a.T_RELENTLESS] = 7
			a.talents[a.T_FEED_POWER] = 5
			a.talents[a.T_FEED_STRENGTHS] = 5
			a.talents[a.T_DARK_TENDRILS] = 5
			a.talents[a.T_WILLFUL_STRIKE] = 7
			a.talents[a.T_REPROACH] = 5
			a.talents[a.T_CALL_SHADOWS] = 5
			a:incStat("wil", a.level)

			local x, y = util.findFreeGrid(self.x, self.y, 10, true, {[engine.Map.ACTOR]=true})
			if x and y then
				game.zone:addEntity(game.level, a, "actor", x, y)

				game.logPlayer(game.player, "#GREY#광신도는 당신의 눈을 깊이 쳐다봅니다. 당시은 찢겨지는 것 같은 느낌을 받습니다!")
				self:doEmote("락'크 코르 메르크 주르!!!", 120)
				self.copied_player = true
			end

			if a.alchemy_golem then
				a.alchemy_golem = nil
				local t = a:getTalentFromId(a.T_REFIT_GOLEM)
				t.action(a, t)
			end
		end
		return value
	end,
}
