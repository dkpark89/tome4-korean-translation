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

local ffi = require "ffi"
local _M = require "engine.Map"
setfenv(1, _M)

--- Updates the map on the given spot
-- This updates many things, from the C map object, the FOV caches, the minimap if it exists, ...
function _M:updateMap(x, y)
	if not x or not y or x < 0 or y < 0 or x >= self.w or y >= self.h then return end

	-- Update minimap if any
	local mos = {}

	self._map:setImportant(x, y, false)
	if not self.updateMapDisplay then
		local g = self(x, y, TERRAIN)
		local o = self(x, y, OBJECT)
		local a = self(x, y, ACTOR)
		local t = self(x, y, TRAP)
		local p = self(x, y, PROJECTILE)

		if g then
			-- Update path caches from path strings
			for i = 1, #self.path_strings do
				local ps = self.path_strings[i]
				self._fovcache.path_caches[ps]:set(x, y, g:check("block_move", x, y, self.path_strings_computed[ps] or ps, false, true))
			end

			g:getMapObjects(self.tiles, mos, 1)
			g:setupMinimapInfo(g._mo, self)
		end
		if t then
			-- Handles trap being known
			if not self.actor_player or t:knownBy(self.actor_player) then
				t:getMapObjects(self.tiles, mos, 1)
				t:setupMinimapInfo(t._mo, self)
			else
				t = nil
			end
		end
		if o then
			o:getMapObjects(self.tiles, mos, 1)
			o:setupMinimapInfo(o._mo, self)
			if self.object_stack_count then
				local mo = o:getMapStackMO(self, x, y)
				if mo then mos[9] = mo end
			end
		end
		if a then
			-- Handles invisibility and telepathy and other such things
			if not self.actor_player or self.actor_player:canSee(a) then
				a:getMapObjects(self.tiles, mos, 1)
				a:setupMinimapInfo(a._mo, self)

--				self._map:setImportant(x, y, true)
			end
		end
		if p then
			p:getMapObjects(self.tiles, mos, 2)
			p:setupMinimapInfo(p._mo, self)
		end
	else
		self:updateMapDisplay(x, y, mos)
	end

	-- Update entities checker for this spot
	-- This is to improve speed, we create a function for each spot that checks entities it knows are there
	-- This avoid a costly for iteration over a pairs() and this allows luajit to compile only code that is needed
	local ce, sort = {}, {}
	local fstr = [[if m[%s] then p = m[%s]:check(what, x, y, ...) if p then return p end end ]]
	ce[#ce+1] = [[return function(self, x, y, what, ...) local p local m = self.map[x + y * self.w] ]]
	for idx, e in pairs(self.map[x + y * self.w]) do sort[#sort+1] = idx end
	table.sort(sort, searchOrderSort)
	for i = 1, #sort do ce[#ce+1] = fstr:format(sort[i], sort[i]) end
	ce[#ce+1] = [[end]]
	local ce = table.concat(ce)
	self._check_entities[x + y * self.w] = self._check_entities_store[ce] or loadstring(ce)()
	self._check_entities_store[ce] = self._check_entities[x + y * self.w]

	-- Cache the map objects in the C map
	self._map:setGrid(x, y, mos)

	-- Update FOV caches
	if self:checkAllEntities(x, y, "block_sight", self.actor_player) then self._fovcache.block_sight:set(x, y, true)
	else self._fovcache.block_sight:set(x, y, false) end
	if self:checkAllEntities(x, y, "block_esp", self.actor_player) then self._fovcache.block_esp:set(x, y, true)
	else self._fovcache.block_esp:set(x, y, false) end
	if self:checkAllEntities(x, y, "block_sense", self.actor_player) then self._fovcache.block_sense:set(x, y, true)
	else self._fovcache.block_sense:set(x, y, false) end
end
