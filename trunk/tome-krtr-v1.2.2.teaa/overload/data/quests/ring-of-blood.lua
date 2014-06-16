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

name = "Till the Blood Runs Clear"
kr_name = "다시 피가 흐를 때까지"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "당신은 노예 수용소를 찾아, 그곳에 들어갔습니다."
	if self:isCompleted("won-fight") then
		desc[#desc+1] = ""
		desc[#desc+1] = "당신은 노예들을 가지고 벌이는 그들의 게임에 참가하기로 했습니다. 당신은 피의 투기장에서 승리를 거머쥐었습니다!"
	end
	if self:isCompleted("killall") then
		desc[#desc+1] = ""
		desc[#desc+1] = "당신은 노예들을 가지고 벌이는 그들의 더러운 일을 용납하지 않았고, 그들을 처치했습니다!"
	end
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if self:isCompleted() then
		who:setQuestStatus(self.id, engine.Quest.DONE)
		if self:isCompleted("won-fight") then
			game:setAllowedBuild("warrior_brawler", true)
		elseif self:isCompleted("killall") then
			world:gainAchievement("RING_BLOOD_KILL", who)
		end
	end
end

find_master = function(self)
	for uid, e in pairs(game.level.entities) do
		if e.define_as and e.define_as == "RING_MASTER" then return e end
	end
	return nil
end

start_game = function(self)
	if not self:find_master() then
		game.log("피의 투기장 운영자가 없어서, 오브가 작동하지 않습니다.")
		return
	end

	local p = game.party:findMember{main=true}

	local slave = game.zone:makeEntityByName(game.level, "actor", "PLAYER_SLAVE")
	local spot = game.level:pickSpot{type="arena", subtype="player"}
	game.zone:addEntity(game.level, slave, "actor", spot.x, spot.y)

	game.party:addMember(slave, {
		control="full", type="slave", title=p.name.."'s slave", kr_title=(p.kr_name or p.name).."의 노예",
		orders = {target=true, leash=true, anchor=true, talents=true, behavior=true},
	})
	game.party:setPlayer(slave)
	game.player.__no_save_json = true
	game.player:hotkeyAutoTalents()
	game.party.members[p].control = "no"
	p.slaver_old_ai = p.ai
	p.ai = "none"

	slave.on_die = function(self)
		game.player:hasQuest("ring-of-blood"):stop_game(false)
		game.log("#CRIMSON#관중들이 소리칩니다 : '이 패배자!'")
	end

	game.log("#LIGHT_GREEN#당신이 오브에 손을 대자, 당신의 의지가 노예의 몸에 차오릅니다. 당신은 그의 행동을 마음대로 조종할 수 있게 되었습니다!")
	self.inside_ring = 0
	self.inside_kills = 0
end

on_turn = function(self)
	if not self.inside_ring then return end

	if self.inside_ring > 0 and not rng.percent(5) then return end
	if self.inside_ring > 3 then return end
	if self.inside_kills >= 10 then
		if self.inside_ring <= 0 then
			self:stop_game(true)
		end
		return
	end

	local oldlev = game.zone.base_level
	game.zone.base_level = 10
	local filter = {type=rng.table{"animal", "humanoid"}, max_ood=3, special_rarity="slaver_rarity"}
	local foe = game.zone:makeEntity(game.level, "actor", filter, nil, true)
	local spot = game.level:pickSpot{type="arena", subtype="npc"}
	local x, y = util.findFreeGrid(spot.x, spot.y, 20, true, {[engine.Map.ACTOR]=true})
	if not x or not foe then return end
	game.zone:addEntity(game.level, foe, "actor", x, y)
	game.log("#CRIMSON#새로운 적이 피의 투기장에 나타났습니다!")
	game.zone.base_level = oldlev

	foe.is_ring_foe = true
	foe.faction = "neutral"
	foe.arena_old_on_die = foe.on_die
	foe.no_drops = true
	foe.on_die = function(self, ...)
		local q = game.player:hasQuest("ring-of-blood")
		q.inside_kills = q.inside_kills + 1
		q.inside_ring = q.inside_ring - 1
		if self.arena_old_on_die then self:arena_old_on_die(...) end
	end
	foe:checkAngered(game.player, true, -200)

	self.inside_ring = self.inside_ring + 1
end

stop_game = function(self, win)
	local p = game.party:findMember{main=true}
	local slave = game.player
	p.ai = p.slaver_old_ai
	game.party.members[p].control = "full"
	game.party:setPlayer(p)
	game.party:removeMember(slave)
	slave:disappear()

	self.inside_ring = nil
	local todel = {}
	for uid, e in pairs(game.level.entities) do if e.is_ring_foe then todel[#todel+1] = e end end
	for _, e in ipairs(todel) do e:disappear() end

	if win then
		p:setQuestStatus(self.id, engine.Quest.COMPLETED, "won-fight")
		game.log("#CRIMSON#관중들이 소리칩니다 : '피! 피! 피! 피!'")
		local chat = require("engine.Chat").new("ring-of-blood-win", self:find_master(), p)
		chat:invoke()
	end
end

reward = function(self, who)
	local o = game.zone:makeEntityByName(game.level, "object", "RING_OF_BLOOD")
	if not o then return end
	o:identify(true)
	game.zone:addEntity(game.level, o, "object")
	who:addObject(who:getInven("INVEN"), o)
	who:setQuestStatus(self.id, engine.Quest.COMPLETED)
	game.logPlayer(who, "#LIGHT_BLUE#피의 투기장 운영자가 당신에게 %s 주었습니다.", o:getName{do_color=true}:addJosa("를"))
end
