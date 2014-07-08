﻿-- ToME - Tales of Maj'Eyal
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

return {
	name = "The Arena",
	kr_name = "투기장",
	level_range = {1, 50},
	level_scheme = "player",
	max_level = 1,
	actor_adjust_level = function(zone, level, e)
		local val = 0
		if level.arena.bonusMultiplier >= 7 then
			val = math.floor(level.arena.bonusMultiplier * 0.3)
		end
	return game.player.level + rng.range(-2 + val, 2 + val)
	end,
	width = 15, height = 15,
	all_remembered = true,
	all_lited = true,
	no_worldport = true,
	ambient_music = "a_lomos_del_dragon_blanco.ogg",

	generator =  {
		map = {
			class = "engine.generator.map.Static",
			map = "zones/arena",
			zoom = 5,
		},
		actor = { },
		--object = { },
		--trap = { },

	},


	on_turn = function(self)
		if game.turn % 10 ~= 0 or game.level.arena.event == 4 then return end
		game.level.arena.checkPinch()
		require("mod.class.generator.actor.Arena").new(self, game.level.map, game.level, {}):tick()
		if game.level.turn_counter then
			if game.level.turn_counter > 0 then game.level.turn_counter = game.level.turn_counter - 10
			else
				--Clear up items and do gold bonus if applicable.
				--The wave starts at this point.
				game.level.turn_counter = nil
				if game.level.arena.event == 1 then game.log("#GOLD#중간보스 시합 시작!!")
				elseif game.level.arena.event == 2 then game.log("#VIOLET#보스 시합 시작!!!")
				elseif game.level.arena.event == 3 then game.log("#LIGHT_RED#최종 시합 시작!!!!")
				end
				game.level.arena.removeStuff()
				game.level.arena.openGates()
			end
		end
		if game.level.arena.bonus > 0 then game.level.arena.bonus = game.level.arena.bonus - 10  end
		if game.level.arena.bonus < 0 then game.level.arena.bonus = 0 end
		if game.level.arena.delay > 0 then game.level.arena.delay = game.level.arena.delay - 1  end
		--Only raise danger level while you can raise bonus multiplier.
		if game.level.arena.dangerMod < 1.5 and game.level.arena.pinch == false
		and game.level.arena.delay  <= 0 and not game.level.turn_counter then
			game.level.arena.dangerMod = game.level.arena.dangerMod + 0.05
		end
		--Reset kill counter
		if game.level.arena.kills > 0 then
			game.level.arena.checkCombo(game.level.arena.kills)
			game.level.arena.totalKills = game.level.arena.totalKills + game.level.arena.kills
		 end
		game.level.arena.kills = 0
	end,


	post_process = function(level)
		game.player.money = 100
		game.player.no_resurrect = true
		game.player.on_die = function (self, src)
			local rank = math.floor(game.level.arena.rank)
			local drank
			if rank < 0 then drank = "투기장의 지배자" else drank = game.level.arena.ranks[rank] or "아무 것도 아님" end
			local lastScore = {
				name = game.player.name.." - "..drank, --@ 점수 기록이라 일단 그냥 둠
				score = game.level.arena.score,
				wave = game.level.arena.currentWave,
				sex = game.player.descriptor.sex,
				race = game.player.descriptor.subrace,
				class = game.player.descriptor.subclass,
			}
			game.level.arena.updateScores(lastScore)
		end

		--Allow players to shoot bows and stuff by default. Move it back to perks if too powerful.
		game.player:learnTalent(game.player.T_SHOOT, true, nil, {no_unlearn=true})
		game.player.changed = true
		level.turn_counter = 60 --5 turns before action starts.
		level.max_turn_counter = 60 --5 turns before action starts.
		level.turn_counter_desc = ""

--TODO(Hetdegon@2012-12-11):Finish display, add shop, enforce enemy drops to be more regular.
--TODO(Hetdegon@2012-12-11):Drops on high combo.


		--world.arena = nil
		if not world.arena or not world.arena.ver then
			local emptyScore = {name = nil, score = 0, wave = 1, sex = nil, race = nil, class = nil}
			world.arena = {
				master30 = nil,
				master60 = nil,
				lastScore = emptyScore,
				bestWave = 1,
				ver = 1
			}
			world.arena.scores = {[1] = emptyScore}
			local o = game.zone:makeEntityByName(game.level, "object", "ARENA_SCORING")
			if o then game.zone:addEntity(game.level, o, "object", 7, 3) end
		end
		level.arena = {
			ranks = { "무명", "생쥐 학살자", "곰 몰이꾼", "전사 지망생", "전사", "용감한 전사", "검투사", "용맹한 검투사", "위험한 자", "장래가 촉망되는 자", "강력한 자", "떠오르는 별", "파괴자", "말살자", "재앙을 불러오는 자", "위대한 자", "영예로운 자", "승리자", "궁극에 달한 자", "궁극에 달한 자", "궁극에 달한 자", "궁극에 달한 자", "궁극에 달한 자", "궁극의 끝에 다다른 자" },
			rank = 1,
			event = 0,
			initEvent = false,
			lockEvent = false,
			display = nil,
			kills = 0,
			totalKills = 0,
			currentWave = 1,
			eventWave = 5,
			finalWave = 61,
			modeString = "60",
			danger = 0,
			dangerTop = 12,
			dangerMod = 0,
			score = 0,
			delay = 0,
			pinch = false,
			pinchValue = 0,
			bonus = 0,
			clearItems = false,
			bonusMultiplier = 1,
			bonusMin = 1,
			entry = {
				--The physical doors
				door = {
					max = 5,
					function () return 0, 1 end,
					function () return 1, 14 end,
					function () return 14, 1 end,
					function () return 13, 14 end,
					function () return 7, 0 end
				},
				--Main gate
				main = {
					max = 4,
					function () return 7, 0 end,
					function () return 7, 1 end,
					function () return 8, 1 end,
					function () return 6, 1 end
				},
				--Corner gates
				corner = {
					max = 12,
					function () return 1, 1 end,
					function () return 2, 1 end,
					function () return 1, 2 end,

					function () return 13, 13 end,
					function () return 12, 13 end,
					function () return 13, 12 end,

					function () return 1, 13 end,
					function () return 2, 13 end,
					function () return 1, 12 end,

					function () return 13, 1 end,
					function () return 12, 1 end,
					function () return 13, 2 end,
				},
				--Crystal gates
				crystal = {
					max = 8,
					function () return 4, 2 end,
					function () return 10, 2 end,
					function () return 10, 12 end,
					function () return 4, 12 end,

					function () return 1, 4 end,
					function () return 12, 4 end,
					function () return 1, 10 end,
					function () return 12, 10 end,
				}
			},

			clear = function()
				game.player:setQuestStatus("arena", engine.Quest.COMPLETED)
				local master = game.player:cloneFull()
				game.level.arena.rank = -1
--				game.player:die(game.player)
				master.version = game.__mod_info.version
				master.no_drops = true
				master.energy.value = 0
				master.player = nil
				master.rank = 5
				master.color_r = 255
				master.color_g = 0
				master.color_b = 255
				master:removeAllMOs()
				master.ai = "tactical"
				master.ai_state = {talent_in=1, ai_move="move_astar"}
				master.faction="enemies"
				master.life = master.max_life
				-- Remove some talents
				local tids = {}
				for tid, _ in pairs(master.talents) do
					local t = master:getTalentFromId(tid)
					if t.no_npc_use then tids[#tids+1] = t end
				end
				game.level.arena.event = 4
				if game.level.arena.finalWave > 60 then
					world:gainAchievement("MASTER_OF_ARENA", game.player)
					world.arena.master60 = master
				else
					world:gainAchievement("ALMOST_MASTER_OF_ARENA", game.player)
					world.arena.master30 = master
				end
			end,

			printRankings = function (val)
				local scores = world.arena.scores
				if not scores or not scores[1] or not scores[1].name then return "#LIGHT_GREEN#...하지만 최근 누군가에 의해 지워진 것 같습니다."
				else
					local text = ""
					local tmp = ""
					local line = function (txt, col) return " "..col..txt.."\n" end
					local stri = "%s (%s %s %s)\n Score %d) - 쇄도 : %d"
					local i = 1
					while(scores[i] and scores[i].name) do
						p = scores[i]
						tmp = stri:format((p.kr_name or p.name):capitalize(), p.sex and p.sex:krSex() or "???", p.race and p.race:krActorType() or "???", p.class and p.class:krActorType() or "???", p.score or 0, p.wave or 0)
						text = text..line(tmp, "#LIGHT_BLUE#")
						i = i + 1
					end
					p = world.arena.lastScore
					tmp = "\n#YELLOW#최종 점수:"..stri:format((p.kr_name or p.name):capitalize(), p.sex and p.sex:krSex() or "알 수 없음", p.race and p.race:krActorType() or "알 수 없음", p.class and p.class:krActorType() or "알 수 없음", p.score or 0, p.wave or 0)
					return text..line(tmp, "#YELLOW#")
				end
			end,

			printRank = function (r, ranks)
				local rank = math.floor(r)
				if rank > #ranks then rank = #ranks end
				return ranks[rank]
			end,

			updateScores = function(l)
				local scores = world.arena.scores or {}
				table.insert(scores, l)
				table.sort(scores, function(a,b) return a.score > b.score end)
				if #scores > 10 then table.remove(scores) end
				world.arena.scores = scores
				if l.wave > world.arena.bestWave then world.arena.bestWave = l.wave end
				world.arena.lastScore = l
			end,

			openGates = function()
				local gates = game.level.arena.entry.door
				local g = game.zone:makeEntityByName(game.level, "terrain", "LOCK_OPEN")
				local x, y = 0, 0
				for i = 1, gates.max do
					x, y = gates[i]()
					game.zone:addEntity(game.level, g, "terrain", x, y)
					game.nicer_tiles:updateAround(game.level, x, y)
				end
				game:playSoundNear(game.player, "talents/earth")
				game.log("#YELLOW#관문이 열렸습니다!")
			end,

			closeGates = function()
				local gates = game.level.arena.entry.door
				local g = game.zone:makeEntityByName(game.level, "terrain", "LOCK")
				local x, y = 0, 0
				for i = 1, gates.max do
					x, y = gates[i]()
					game.zone:addEntity(game.level, g, "terrain", x, y)
					game.level.map:particleEmitter(x, y, 0.5, "arena_gate")
					game.nicer_tiles:updateAround(game.level, x, y)
				end
				game:playSoundNear(game.player, "talents/earth")
				game.log("#LIGHT_RED#관문이 닫혔습니다!")
			end,

			raiseRank = function (val)
				if game.level.arena.rank >= 24 then return end
				local currentRank = math.floor(game.level.arena.rank)
				game.level.arena.rank = game.level.arena.rank + val
				if game.level.arena.rank >= #game.level.arena.ranks then game.level.arena.rank = #game.level.arena.ranks end
				local newRank = math.floor(game.level.arena.rank)
				if currentRank < newRank then --Player's rank increases!
					local x, y = game.level.map:getTileToScreen(game.player.x, game.player.y)
					if newRank == 13 then world:gainAchievement("XXX_THE_DESTROYER", game.player)
					elseif newRank == 24 then world:gainAchievement("GRAND_MASTER", game.player)
					end
					game.flyers:add(x, y, 90, 0, -0.5, "등급 상승!!", { 2, 57, 185 }, true)
					game.log("#LIGHT_GREEN#관객들이 당신의 성과에 기뻐합니다! 당신의 등급은 이제 #WHITE#"..game.level.arena.ranks[newRank].."#LIGHT_GREEN# 입니다!")
				end
			end,

			checkCombo = function (k)
				if k >= 10 then world:gainAchievement("TEN_AT_ONE_BLOW", game.player) end
				if k > 2 then
					local x, y = game.level.map:getTileToScreen(game.player.x, game.player.y)
					local b = (k * 0.035) + 0.04
					game.level.arena.raiseRank(b)
					game.flyers:add(x, y, 90, 0.5, 0, k.."명 살해!", { 2, 57, 185 }, false)
					game.log("#YELLOW#당신은 한 턴에 "..k.." 명의 적을 죽였습니다! 관객들이 흥분합니다!")
					if k >= 4 and k < 6 then
						local drop = game.zone:makeEntity(game.level, "object", {tome = { ego=30, double_ego=15, greater=7, greater_normal=1 }}, nil, true)
						game.zone:addEntity(game.level, drop, "object", game.player.x, game.player.y)
					elseif k >= 6 and k < 8 then
						local drop = game.zone:makeEntity(game.level, "object", {tome = { ego=60, double_ego=30, greater=15, greater_normal=10, double_greater=1 }}, nil, true)
						game.zone:addEntity(game.level, drop, "object", game.player.x, game.player.y)
					elseif k >= 8 and k < 10 then
						local drop = game.zone:makeEntity(game.level, "object", {tome = { double_ego=60, greater=35, greater_normal=20, double_greater=5 }}, nil, true)
						game.zone:addEntity(game.level, drop, "object", game.player.x, game.player.y)
					elseif k >= 10 then
						local drop = game.zone:makeEntity(game.level, "object", {tome = { greater=70, greater_normal=40, double_greater=25 }}, nil, true)
						game.zone:addEntity(game.level, drop, "object", game.player.x, game.player.y)
					end

				else return
				end
			end,

			initWave = function (val) --Clean up and start a new wave.
				if val > 20 then --If the player has more than 20 turns of rest, clean up all items lying around.
					game.level.arena.clearItems = true
					game.log("#YELLOW##WHITE#"..val.."#YELLOW#턴 뒤에는 투기장에 있는 물건들이 사라집니다!#LAST#")
				end
				game.level.arena.dangerTop = game.level.arena.dangerTop + (2 + math.floor(game.level.arena.currentWave * 0.05))
				game.level.arena.currentWave = game.level.arena.currentWave + 1
				game.level.arena.dangerMod = 0.7 + (game.level.arena.currentWave * 0.005)
				game.level.arena.bonus = 0
				game.level.level = game.level.arena.currentWave
				game.level.arena.bonusMultiplier = game.level.arena.bonusMin
				game.level.arena.pinchValue = 0
				game.level.arena.pinch = false
				if game.level.arena.display then game.level.arena.display = nil end
				--NOTE(Hetdegon@2012-10-02):Replace this to an event table.
				if game.level.arena.currentWave % game.level.arena.eventWave == 0 then
					if game.level.arena.currentWave % (game.level.arena.eventWave * 3) == 0 then --Boss round!
						game.log("#VIOLET#보스 시합!!")
						game.level.arena.event = 2
					else --Miniboss round!
						game.log("#GOLD#중간보스 시합!")
						game.level.arena.event = 1
					end
				elseif game.level.arena.currentWave == game.level.arena.finalWave then --Final round!
					game.level.arena.event = 3
					game.log("#LIGHT_RED#최종 시합!!!")
				else --Regular stuff.
					game.level.arena.event = 0
				end
				game.level.arena.initEvent = false
				game.level.arena.lockEvent = false
				if game.level.arena.currentWave == 21 then world:gainAchievement("ARENA_BATTLER_20", game.player)
				elseif game.level.arena.currentWave == 51 then world:gainAchievement("ARENA_BATTLER_50", game.player)
				end
			end,

			removeStuff = function ()
				for i = 0, game.level.map.w - 1 do
					for j = 0, game.level.map.h - 1 do
						local nb = game.level.map:getObjectTotal(i, j)
						for z = nb, 1, -1 do game.level.map:removeObject(i, j, z) end
					end
				end
			end,

			doReward = function (val)
				local col = "#ROYAL_BLUE#"
				local hgh = "#WHITE#"
				local dangerBonus = val * 0.5
				local scoreBonus = game.level.arena.bonus * 0.2
				local clearBonus = math.ceil(game.level.arena.currentWave ^ 1.85)
				local rankBonus = math.floor(game.level.arena.rank) * 20
				local expAward = (dangerBonus + scoreBonus + clearBonus + rankBonus) * game.level.arena.bonusMultiplier
				local x, y = game.level.map:getTileToScreen(game.player.x, game.player.y)
				game.player:gainExp(expAward)
				game.player:incMoney(game.level.arena.bonusMultiplier)
				game.level.arena.score = game.level.arena.score + game.level.arena.bonus
				game.flyers:add(x, y, 90, 0, -1, "시합 완료! 경험치 +"..expAward.."!", { 2, 57, 185 }, true)
				game.log(col.."쇄도 완료!")
				game.log(col.."완료 보너스: "..hgh..clearBonus..col.."! 점수 보너스: "..hgh..scoreBonus..col.."! 위험 보너스: "..hgh..dangerBonus..col.."! 등급 보너스: "..hgh..rankBonus..col.."!")
				game.log(col.."경험치가 "..hgh..expAward..col.." 상승하였습니다!")
				game.log(col.."승리의 결과, 금화 "..game.level.arena.bonusMultiplier.." 개를 얻었습니다!")
				game.player.changed = true
			end,

			clearRound = function () --Relax and give rewards.
				--Do rewarding.
				local val = game.level.arena.pinchValue
				local plvl = game.player.level
				game.level.arena.doReward(val)
				--Set rest time.
				local rest_time = val
				if not plvl == game.player.level then --If bonuses made the player level up, give minimal time.
					if rest_time > 30 then rest_time = 30 end
				else
					if rest_time < 25 then rest_time = 25
					elseif rest_time > 80 then rest_time = 80
					end
				end
				game.level.turn_counter = rest_time * 10
				game.level.max_turn_counter = rest_time * 10
				game.level.arena.initWave(rest_time)
			end,

			checkPinch = function ()
				if game.level.arena.danger > game.level.arena.dangerTop and game.level.arena.pinch == false then --The player is in a pinch!
					if game.level.arena.danger - game.level.arena.dangerTop < 10 then return end --Ignore minimal excess of power.
					game.level.arena.pinch = true
					game.level.arena.pinchValue = game.level.arena.danger - game.level.arena.dangerTop
					game.level.arena.bonus = (game.level.arena.pinchValue * 20) + 200
					game.level.arena.closeGates()
				elseif game.level.arena.danger <= 0 and game.level.arena.pinch == true then --The player cleared the round.
					if game.level.arena.event == 0 then
						game.level.arena.clearRound()
					elseif game.level.arena.lockEvent == false then --Call minibosses or boss next turn.
						game.level.arena.initEvent = true
					else --Round is clear
						game.level.arena.clearRound()
					end
				end
			end,
		}
		local Chat = require "engine.Chat"
		local chat = Chat.new("arena-start", {name="Arena mode", kr_name="투기장 모드"}, game.player, {text = level.arena.printRankings()})
		chat:invoke()
	end
}