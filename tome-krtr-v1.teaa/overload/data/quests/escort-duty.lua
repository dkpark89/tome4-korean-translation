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

require "engine.krtrUtils"

local Talents = require("engine.interface.ActorTalents")
local Stats = require("engine.interface.ActorStats")
local NameGenerator = require("engine.NameGenerator")
local Astar = require("engine.Astar")

--------------------------------------------------------------------------------
-- Quest data
--------------------------------------------------------------------------------
local name_rules = {
	male = {
		phonemesVocals = "a, e, i, o, u, y",
		phonemesConsonants = "b, c, ch, ck, cz, d, dh, f, g, gh, h, j, k, kh, l, m, n, p, ph, q, r, rh, s, sh, t, th, ts, tz, v, w, x, z, zh",
		syllablesStart = "Aer, Al, Am, An, Ar, Arm, Arth, B, Bal, Bar, Be, Bel, Ber, Bok, Bor, Bran, Breg, Bren, Brod, Cam, Chal, Cham, Ch, Cuth, Dag, Daim, Dair, Del, Dr, Dur, Duv, Ear, Elen, Er, Erel, Erem, Fal, Ful, Gal, G, Get, Gil, Gor, Grin, Gun, H, Hal, Han, Har, Hath, Hett, Hur, Iss, Khel, K, Kor, Lel, Lor, M, Mal, Man, Mard, N, Ol, Radh, Rag, Relg, Rh, Run, Sam, Tarr, T, Tor, Tul, Tur, Ul, Ulf, Unr, Ur, Urth, Yar, Z, Zan, Zer",
		syllablesMiddle = "de, do, dra, du, duna, ga, go, hara, kaltho, la, latha, le, ma, nari, ra, re, rego, ro, rodda, romi, rui, sa, to, ya, zila",
		syllablesEnd = "bar, bers, blek, chak, chik, dan, dar, das, dig, dil, din, dir, dor, dur, fang, fast, gar, gas, gen, gorn, grim, gund, had, hek, hell, hir, hor, kan, kath, khad, kor, lach, lar, ldil, ldir, leg, len, lin, mas, mnir, ndil, ndur, neg, nik, ntir, rab, rach, rain, rak, ran, rand, rath, rek, rig, rim, rin, rion, sin, sta, stir, sus, tar, thad, thel, tir, von, vor, yon, zor",
		rules = "$s$v$35m$10m$e",
	},
	female = {
		phonemesVocals = "a, e, i, o, u, y",
		syllablesStart = "Ad, Aer, Ar, Bel, Bet, Beth, Ce'N, Cyr, Eilin, El, Em, Emel, G, Gl, Glor, Is, Isl, Iv, Lay, Lis, May, Ner, Pol, Por, Sal, Sil, Vel, Vor, X, Xan, Xer, Yv, Zub",
		syllablesMiddle = "bre, da, dhe, ga, lda, le, lra, mi, ra, ri, ria, re, se, ya",
		syllablesEnd = "ba, beth, da, kira, laith, lle, ma, mina, mira, na, nn, nne, nor, ra, rin, ssra, ta, th, tha, thra, tira, tta, vea, vena, we, wen, wyn",
		rules = "$s$v$35m$10m$e",
	},
}

local possible_types = {
	{ name="lost warrior", random="male", chance=70, kr_display_name="길 잃은 전사",
		text = [[저를 도와주십시오! 저는 아무래도 이곳에서 길을 잃어버린 것 같습니다. 이 근처에 제 친구가 만든 귀환용 관문이 있다는 것은 알고 있지만, 도저히 혼자서 이 길을 헤쳐나가지는 못할 것 같습니다. 저를 도와주실 수 있으십니까?]],
		actor = {
			type = "humanoid", subtype = "human", image = "player/higher_male.png",
			display = "@", color=colors.UMBER,
			name = "%s, the lost warrior",
			kr_display_name = "길 잃은 전사 %s",
			desc = [[그는 지쳤으며, 부상 당한 상태입니다.]],
			autolevel = "warrior",
			ai = "escort_quest", ai_state = { talent_in=4, },
			stats = { str=18, dex=13, mag=5, con=15 },

			body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
			resolvers.equip{ {type="weapon", subtype="greatsword", autoreq=true} },
			resolvers.talents{ [Talents.T_STUNNING_BLOW]=1, },
			lite = 4,
			rank = 2,
			exp_worth = 1,
			antimagic_ok = true,

			max_life = 50, life_regen = 0,
			life_rating = 12,
			combat_armor = 3, combat_def = 3,
			inc_damage = {all=-50},

			reward_type = "warrior",
		},
	},
	{ name="injured seer", random="female", chance=70, kr_display_name="부상당한 탐시자",
		text = [[저를 도와주십시오! 저는 아무래도 이곳에서 길을 잃어버린 것 같습니다. 이 근처에 제 친구가 만든 귀환용 관문이 있다는 것은 알고 있지만, 도저히 혼자서 이 길을 헤쳐나가지는 못할 것 같습니다. 저를 도와주실 수 있으십니까?]],
		actor = {
			name = "%s, the injured seer",
			kr_display_name = "부상당한 탐시자 %s",
			type = "humanoid", subtype = "elf", female=true, image = "player/halfling_female.png",
			display = "@", color=colors.LIGHT_BLUE,
			desc = [[그녀는 지쳤으며, 부상 당한 상태입니다.]],
			autolevel = "caster",
			ai = "escort_quest", ai_state = { talent_in=4, },
			stats = { str=8, dex=7, mag=18, con=12 },

			body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
			resolvers.equip{ {type="weapon", subtype="staff", autoreq=true} },
			resolvers.talents{ [Talents.T_MANATHRUST]=1, },
			lite = 4,
			rank = 2,
			exp_worth = 1,

			max_life = 50, life_regen = 0,
			life_rating = 11,
			combat_armor = 3, combat_def = 3,
			inc_damage = {all=-50},

			reward_type = "divination",
		},
	},
	{ name="repented thief", random="male", chance=70, kr_display_name="회개한 도적",
		text = [[저를 도와주십시오! 저는 아무래도 이곳에서 길을 잃어버린 것 같습니다. 이 근처에 제 친구가 만든 귀환용 관문이 있다는 것은 알고 있지만, 저는 이미 너무나 많은 전투를 치른 상태입니다. 저를 도와주실 수 있으십니까?]],
		actor = {
			name = "%s, the repented thief",
			kr_display_name = "회개한 도적 %s",
			type = "humanoid", subtype = "halfling", image = "player/cornac_male.png",
			display = "@", color=colors.BLUE,
			desc = [[그는 지쳤으며, 부상 당한 상태입니다.]],
			autolevel = "rogue",
			ai = "escort_quest", ai_state = { talent_in=4, },
			stats = { str=8, dex=7, mag=18, con=12 },

			body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
			resolvers.equip{ {type="weapon", subtype="dagger", autoreq=true}, {type="weapon", subtype="dagger", autoreq=true} },
			resolvers.talents{ [Talents.T_DIRTY_FIGHTING]=1, },
			lite = 4,
			rank = 2,
			exp_worth = 1,
			antimagic_ok = true,

			max_life = 50, life_regen = 0,
			life_rating = 11,
			combat_armor = 3, combat_def = 3,
			inc_damage = {all=-50},

			reward_type = "survival",
		},
	},
	{ name="lone alchemist", random="male", chance=70, kr_display_name="외로운 연금술사",
		text = [[저를 도와주십시오! 저는 아무래도 이곳에서 길을 잃어버린 것 같습니다. 이 근처에 제 친구가 만든 귀환용 관문이 있다는 것은 알고 있지만, 저는 이미 너무나 많은 전투를 치른 상태입니다. 저를 도와주실 수 있으십니까?]],
		actor = {
			name = "%s, the lone alchemist",
			kr_display_name = "외로운 연금술사 %s",
			type = "humanoid", subtype = "human", image = "player/shalore_male.png",
			display = "@", color=colors.AQUAMARINE,
			desc = [[그는 지쳤으며, 부상 당한 상태입니다.]],
			autolevel = "rogue",
			ai = "escort_quest", ai_state = { talent_in=4, },
			stats = { str=8, dex=7, mag=18, con=12 },

			body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
			resolvers.equip{ {type="weapon", subtype="staff", autoreq=true} },
			resolvers.talents{ [Talents.T_HEAT]=1, },
			lite = 4,
			rank = 2,
			exp_worth = 1,

			max_life = 50, life_regen = 0,
			life_rating = 11,
			combat_armor = 3, combat_def = 3,
			inc_damage = {all=-50},

			reward_type = "alchemy",
		},
	},
	{ name="lost sun paladin", random="female", chance=70, kr_display_name="길 잃은 태양의 기사",
		text = [[저를 도와주십시오! 저는 아무래도 이곳에서 길을 잃어버린 것 같습니다. 이 근처에 제 친구가 만든 귀환용 관문이 있다는 것은 알고 있지만, 저는 이미 너무나 많은 전투를 치른 상태입니다. 저를 도와주실 수 있으십니까?]],
		actor = {
			name = "%s, the lost sun paladin",
			kr_display_name = "길 잃은 태양의 기사 %s",
			type = "humanoid", subtype = "human", female=true, image = "player/higher_female.png",
			display = "@", color=colors.GOLD,
			desc = [[그녀는 지쳤으며, 부상 당한 상태입니다.]],
			autolevel = "warriormage",
			ai = "escort_quest", ai_state = { talent_in=4, },
			stats = { str=18, dex=7, mag=18, con=12 },

			body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
			resolvers.equip{ {type="weapon", subtype="mace", autoreq=true} },
			resolvers.talents{ [Talents.T_CHANT_OF_FORTRESS]=1, },
			lite = 4,
			rank = 2,
			exp_worth = 1,

			max_life = 50, life_regen = 0,
			life_rating = 12,
			combat_armor = 3, combat_def = 3,
			inc_damage = {all=-50},

			reward_type = "sun_paladin",
			sunwall_query = true,
		},
	},
	{ name="lost anorithil", random="female", chance=70, kr_display_name="길 잃은 아노리실",
		text = [[저를 도와주십시오! 저는 아무래도 이곳에서 길을 잃어버린 것 같습니다. 이 근처에 제 친구가 만든 귀환용 관문이 있다는 것은 알고 있지만, 저는 이미 너무나 많은 전투를 치른 상태입니다. 저를 도와주실 수 있으십니까?]],
		actor = {
			name = "%s, the lost anorithil",
			kr_display_name = "길 잃은 아노리실 %s",
			type = "humanoid", subtype = "human", female=true, image = "player/higher_female.png",
			display = "@", color=colors.YELLOW,
			desc = [[그녀는 지쳤으며, 부상 당한 상태입니다.]],
			autolevel = "caster",
			ai = "escort_quest", ai_state = { talent_in=4, },
			stats = { str=8, dex=7, mag=18, con=12 },

			body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
			resolvers.equip{ {type="weapon", subtype="staff", autoreq=true} },
			resolvers.talents{ [Talents.T_HYMN_OF_PERSEVERANCE]=1, },
			lite = 4,
			rank = 2,
			exp_worth = 1,

			max_life = 50, life_regen = 0,
			life_rating = 11,
			combat_armor = 3, combat_def = 3,
			inc_damage = {all=-50},

			reward_type = "anorithil",
			sunwall_query = true,
		},
	},
	{ name="temporal explorer", random="player", portal="temporal portal", chance=30, kr_display_name="시간의 여행자",
		text = [[오, 하지만 너는... 정말 너야?! 나?!
내가 맞았군. 이곳은 내가 있어야 할 시간의 흐름이 아냐!
나를 좀 도와줘! 아무래도 이곳에서 길을 잃어버린 것 같아. 이 근처에 친구가 만든 시간의 관문이 있다는 것은 알고 있지만, 나는 이미 너무나 많은 전투를 치른 상태거든. 더 이상은 무리라고. 나를 도와줄 수 있겠어? 아니... 너 자신을... 돕는 거라고 이건.]],
		actor = {
			name = "%s, temporal explorer",
			kr_display_name = "시간의 여행자 %s",
			type = "humanoid", subtype = "human", female=true, image = "player/higher_female.png",
			display = "@", color=colors.YELLOW,
			desc = [[이 자는 지쳤으며, 부상 당한 상태입니다. 이 자는 당신과 상당히 닮았지만, 완전히 다르기도 합니다. 기묘한 일이군요.]],
			autolevel = "caster",
			ai = "escort_quest", ai_state = { talent_in=4, },
			stats = { str=8, dex=7, mag=18, con=12 },

			body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
			resolvers.equip{ {type="weapon", subtype="staff", autoreq=true} },
			resolvers.talents{ [Talents.T_DUST_TO_DUST]=1, },
			lite = 4,
			rank = 2,
			exp_worth = 1,

			max_life = 50, life_regen = 0,
			life_rating = 11,
			combat_armor = 3, combat_def = 3,
			inc_damage = {all=-50},

			reward_type = "temporal",
		},
	},
	{ name="worried loremaster", random="female", chance=30, kr_display_name="근심하는 지식 전달자",
		text = [[저를 도와주십시오! 저는 아무래도 이곳에서 길을 잃어버린 것 같습니다. 이 근처에 제 친구가 만든 귀환용 관문이 있다는 것은 알고 있지만, 저는 이미 너무나 많은 전투를 치른 상태입니다. 저를 도와주실 수 있으십니까?]],
		actor = {
			name = "%s, the worried loremaster",
			kr_display_name = "근심하는 지식 전달자 %s",
			type = "humanoid", subtype = "human", female=true, image = "player/thalore_female.png",
			display = "@", color=colors.LIGHT_GREEN,
			desc = [[그녀는 지쳤으며, 부상 당한 상태입니다.]],
			autolevel = "wildcaster",
			ai = "escort_quest", ai_state = { talent_in=4, },
			stats = { str=8, dex=7, mag=18, con=12 },

			body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
			resolvers.equip{ {type="weapon", subtype="staff", autoreq=true} },
			resolvers.talents{ [Talents.T_MIND_SEAR]=1, },
			lite = 4,
			rank = 2,
			exp_worth = 1,
			antimagic_ok = true,

			max_life = 50, life_regen = 0,
			life_rating = 10,
			combat_armor = 3, combat_def = 3,
			inc_damage = {all=-50},

			reward_type = "exotic",
		},
	},
}

--------------------------------------------------------------------------------
-- Quest code
--------------------------------------------------------------------------------

-- Random escort
id = "escort-duty-"..game.zone.short_name.."-"..game.level.level

kind = {}

name = ""
desc = function(self, who)
	local desc = {}
	if self:isStatus(engine.Quest.DONE) then
		desc[#desc+1] = "당신은 성공적으로 "..(self.kind.kr_display_name or self.kind.name).."의 호위를 해냈습니다. ("..self.level_name..")"
		if self.reward_message then
			desc[#desc+1] = ("보상을 얻었습니다 : %s"):format(self.reward_message)
		end
	elseif self:isStatus(engine.Quest.FAILED) then
		if self.abandoned then
			desc[#desc+1] = "당신은 "..(self.kind.kr_display_name or self.kind.name).."의 호위를 하지 않고, 죽게 내버려뒀습니다."
		else
			desc[#desc+1] = "당신은 "..(self.kind.kr_display_name or self.kind.name).."의 호위에 실패했습니다. ("..(self.killing_npc or "???")..")"
		end
	else
		desc[#desc+1] = ""..(self.kind.kr_display_name or self.kind.name).."의 호위를 하고 있습니다. ("..self.level_name..")"
	end
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if status == self.FAILED then
		-- Remove the actor is we failed
		for uid, e in pairs(game.level.entities) do
			if e.quest_id and e.quest_id == self.id then
				game.party:removeMember(e, true)
				e:disappear()
				e:removed()
			end
		end
	end
end

local function getPortalSpot(npc, dist, min_dist)
	local astar = Astar.new(game.level.map, npc)
	local poss = {}
	dist = math.floor(dist)
	min_dist = math.floor(min_dist or 0)

	for i = npc.x - dist, npc.x + dist do
		for j = npc.y - dist, npc.y + dist do
			if game.level.map:isBound(i, j) and
			   core.fov.distance(npc.x, npc.y, i, j) <= dist and
			   core.fov.distance(npc.x, npc.y, i, j) >= min_dist and
			   game.level.map(i, j, engine.Map.TERRAIN) and not game.level.map(i, j, engine.Map.TERRAIN).change_level and
			   npc:canMove(i, j) then
				poss[#poss+1] = {i,j}
			end
		end
	end

	while #poss > 0 do
		local pos = rng.tableRemove(poss)
		if astar:calc(npc.x, npc.y, pos[1], pos[2]) then
			print("Placing portal at ", pos[1], pos[2])
			return pos[1], pos[2]
		end
	end
end

on_grant = function(self, who)
	local x, y = util.findFreeGrid(who.x, who.y, 10, true, {[engine.Map.ACTOR]=true})
	if not x then return true end

	self.on_grant = nil

	local hd = {"Quest:escort:assign", possible_types=possible_types}
	if self:triggerHook(hd) then possible_types = hd.possible_types end

	while true do
		self.kind = rng.table(possible_types)
		if rng.percent(self.kind.chance) then break end
	end

	if self.kind.random == "player" then
		self.kind.actor.name = self.kind.actor.name:format(game.player.name)
		self.kind.actor.kr_display_name = (self.kind.actor.kr_display_name or self.kind.actor.name):format(game.player.kr_display_name or game.player.name) --@@ 한글 이름 수정
	else
		local ng = NameGenerator.new(name_rules[self.kind.random])
		local rndName = ng:generate() --@@ 영어 이름과 한글 이름에 같은 이름이 들어가도록 일단 저장, 랜덤한 이름은 아직(?) 한글화하지 않음 
		self.kind.actor.name = self.kind.actor.name:format(rndName)
		self.kind.actor.kr_display_name = self.kind.actor.kr_display_name:format(rndName) --@@ 한글 이름 수정 
	end

	self.kind.actor.level_range = {game.player.level, game.player.level}
	self.kind.actor.faction = who.faction
	self.kind.actor.summoner = who
	self.kind.actor.quest_id = self.id
	self.kind.actor.escort_quest = true
	self.kind.actor.remove_from_party_on_death = true
	self.kind.actor.on_die = function(self, who)
		if self.sunwall_query then game.state.found_sunwall_west_died = true end
		game.logPlayer(game.player, "#LIGHT_RED#%s 죽었습니다. 호위에 실패했습니다!", (self.kr_display_name or self.name):capitalize():addJosa("이"))
		game.player:setQuestStatus(self.quest_id, engine.Quest.FAILED)
		game.player:hasQuest(self.quest_id).killing_npc = (who and (who.kr_display_name or who.name)) or "무언가"
		if who.resolveSource and who:resolveSource().player then
			world:gainAchievement("ESCORT_KILL", game.player)
			game.player:registerEscorts("betrayed")
		else
			world:gainAchievement("ESCORT_LOST", game.player)
			game.player:registerEscorts("lost")
		end
	end

	-- Spawn actor
	local npc = mod.class.NPC.new(self.kind.actor)
	npc:resolve() npc:resolve(nil, true)
	npc.x, npc.y = x, y
	self.kind.actor = nil

	-- Spawn the portal, far enough from the escort
	local gx, gy = getPortalSpot(npc, 150, 10)
	if not gx then return true end
	local g = game.level.map(gx, gy, engine.Map.TERRAIN)
	g = g:cloneFull()
	g.__nice_tile_base = nil
	g.show_tooltip = true
	g.name = (self.kind.portal or "Recall Portal").." : "..npc.name
	g.kr_display_name = (self.kind.portal or "귀환용 관문").." : "..(npc.kr_display_name or npc.name)
	g.display = '&'
	g.color_r = colors.VIOLET.r
	g.color_g = colors.VIOLET.g
	g.color_b = colors.VIOLET.b
	g.add_displays = g.add_displays or {}
	g.add_displays[#g.add_displays+1] = mod.class.Grid.new{image="terrain/maze_teleport.png"}
	g.notice = true
	g.escort_portal = true
	g.nice_tiler = nil
	g.on_move = function(self, x, y, who)
		if not who.escort_quest then return end
		game.player:setQuestStatus(who.quest_id, engine.Quest.DONE)
		local Chat = require "engine.Chat"
		Chat.new("escort-quest", who, game.player, {npc=who}):invoke()
		world:gainAchievement("ESCORT_SAVED", game.player)
		who:disappear()
		who:removed()
		game.party:removeMember(who, true)
	end
	g:removeAllMOs()

	g:resolve() g:resolve(nil, true)
	game.zone:addEntity(game.level, g, "terrain", gx, gy)
	npc.escort_target = {x=gx, y=gy}
	npc.x, npc.y = nil, nil
	game.zone:addEntity(game.level, npc, "actor", x, y)

	-- Setup quest
	self.level_name = (game.zone.kr_display_name or game.zone.name).." "..game.level.level.."층"
	self.name = "Escort: "..self.kind.name.." (level "..self.level_name..")"
	self.kr_display_name = "호위 : "..(self.kind.kr_display_name or self.kind.name).." (장소 : "..self.level_name..")"

	local Chat = require "engine.Chat"
	Chat.new("escort-quest-start", npc, game.player, {text=self.kind.text, npc=npc}):invoke()

	-- Check if we found sunpaladins/anorithils before going east
	if npc.sunwall_query then
		game.state.found_sunwall_west = true
	end
end
