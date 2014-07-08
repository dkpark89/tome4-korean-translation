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
require "engine.class"
local ActorAI = require "engine.interface.ActorAI"
local Faction = require "engine.Faction"
local Emote = require("engine.Emote")
local Map = require("engine.Map")
require "mod.class.Actor"

module(..., package.seeall, class.inherit(mod.class.Actor, engine.interface.ActorAI))

function _M:init(t, no_default)
	if type(t.cant_be_moved) == "nil" then t.cant_be_moved = true end
	mod.class.Actor.init(self, t, no_default)
	ActorAI.init(self, t)

	-- Grab default image name if none is set
	if not self.image and self.name ~= "unknown actor" then self.image = "npc/"..tostring(self.type or "unknown").."_"..tostring(self.subtype or "unknown"):lower():gsub("[^a-z0-9]", "_").."_"..(self.name or "unknown"):lower():gsub("[^a-z0-9]", "_")..".png" end

	self.unit_power = self.unit_power or 0
	self.max_unit_power = self.max_unit_power or self.unit_power
end

--- Checks what to do with the target
-- Talk ? attack ? displace ?
function _M:bumpInto(target, x, y)
	local reaction = self:reactionToward(target)
	if reaction < 0 then
		return self:encounterAttack(target, x, y)
	elseif reaction >= 0 then
		-- Talk ?
		if target.player and self.can_talk then
			local chat = Chat.new(self.can_talk, self, target)
			chat:invoke()
			if self.can_talk_only_once then self.can_talk = nil end
		elseif target.cant_be_moved and self.cant_be_moved and target.x and target.y and self.x and self.y then
			-- Displace
			local tx, ty, sx, sy = target.x, target.y, self.x, self.y
			target.x = nil target.y = nil
			self.x = nil self.y = nil
			target:move(sx, sy, true)
			self:move(tx, ty, true)
		end
	end
end

function _M:takeHit()
	return nil, 0
end

--- Attach or remove a display callback
-- Defines particles to display
function _M:defineDisplayCallback()
	if not self._mo then return end

	-- Cunning trick here!
	-- the callback we give to mo:displayCallback is a function that references self
	-- but self contains mo so it would create a cyclic reference and prevent GC'ing
	-- thus we store a reference to a weak table and put self into it
	-- this way when self dies the weak reference dies and does not prevent GC'ing
	local weak = setmetatable({[1]=self}, {__mode="v"})

	local ps = self:getParticlesList()

	self._mo:displayCallback(function(x, y, w, h, zoom, on_map)
		local self = weak[1]
		if not self then return end

		if game.level and game.level.map.view_faction and game.always_target and game.always_target ~= "old" then
			local map = game.level.map
			if on_map then
				self:smallTacticalFrame(game.level.map, x, y, w, h, zoom, on_map, tlx, tly)
			end
		else
			self:bigTacticalFrame(x, y, w, h, zoom, on_map, tlx, tly)
		end

		local e
		for i = 1, #ps do
			e = ps[i]
			e:checkDisplay()
			if e.ps:isAlive() then e.ps:toScreen(x + w / 2, y + h / 2, true, w / (game.level and game.level.map.tile_w or w))
			else self:removeParticles(e)
			end
		end

		return true
	end)
end

function _M:takePowerHit(val, src)
	self.unit_power = (self.unit_power or 0) - val
	if self.unit_power <= 0 then
		self.logCombat(src, self, "#Source1# #Target3# 죽였습니다.")
		self:die(src)
	end
end

function _M:encounterAttack(target, x, y)
	if target.player then target:onWorldEncounter(self, self.x, self.y) return end

	self.unit_power = self.unit_power or 0
	target.unit_power = target.unit_power or 0

	if self.unit_power > target.unit_power then
		self.unit_power = self.unit_power - target.unit_power
		target.unit_power = 0
	elseif self.unit_power < target.unit_power then
		target.unit_power = target.unit_power - self.unit_power
		self.unit_power = 0
	else
		self.unit_power, target.unit_power = self.unit_power - target.unit_power, target.unit_power - self.unit_power
	end

	if self.unit_power <= 0 then
		self:logCombat(target, "#Target1# #Source3# 죽였습니다.")
		self:die(target)
	end
	if target.unit_power <= 0 then
		self:logCombat(target, "#Source1# #Target3# 죽었습니다.")
		target:die(src)
	end
end

function _M:act()
	while self:enoughEnergy() and not self.dead do
		-- Do basic actor stuff
		if not mod.class.Actor.act(self) then return end

		-- Compute FOV, if needed
		self:doFOV()

		-- Let the AI think .... beware of Shub !
		-- If AI did nothing, use energy anyway
		self:doAI()

		if not self.energy.used then self:useEnergy() end
	end
end

function _M:doFOV()
	self:computeFOV(self.sight or 4, "block_sight", nil, nil, nil, true)
end

function _M:tooltip(x, y, seen_by)
	if seen_by and not seen_by:canSee(self) then return end
	local factcolor, factstate, factlevel = "#ANTIQUE_WHITE#", "중립", self:reactionToward(game.player)
	if factlevel < 0 then factcolor, factstate = "#LIGHT_RED#", "적대"
	elseif factlevel > 0 then factcolor, factstate = "#LIGHT_GREEN#", "우호"
	end

	local rank, rank_color = self:TextRank()

	local ts = tstring{}
	ts:add({"uid",self.uid}) ts:merge(rank_color:toTString()) ts:add(self.kr_name and self.kr_name.." ["..self.name.."]" or self.name, {"color", "WHITE"}, true) --@ 한글 이름에 원래 이름 덧붙이기
	ts:add(self.type:capitalize():krActorType(), " / ", self.subtype:capitalize():krActorType(), true) --@ 종족/직업 이름 한글화
	ts:add("등급 : ") ts:merge(rank_color:toTString()) ts:add(rank:krRank(), {"color", "WHITE"}, true) --@ 등급 이름 한글화
	ts:add(self.desc, true)
	ts:add("소속 : ") ts:merge(factcolor:toTString()) ts:add(("%s (%s, %d)"):format(Faction.factions[self.faction].name:krFaction(), factstate, factlevel), {"color", "WHITE"}, true) --@ 소속 이름 한글화
	ts:add(
		("당신에게 죽은 횟수 : "):format(killed), true,
		"목표: ", self.ai_target.actor and (self.ai_target.actor.kr_name or self.ai_target.actor.name) or "없음", true, 
		"UID: "..self.uid
	)

	return ts
end

function _M:die(src)
	engine.interface.ActorLife.die(self, src)
end
