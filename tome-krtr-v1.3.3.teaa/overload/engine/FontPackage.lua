-- TE4 - T-Engine 4
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

require "engine.class"

--- Configure sets of fonts
module(..., package.seeall, class.make)

local packages = {}

--- Loads lore
function _M:loadDefinition(file, env)
	local f, err = loadfile(file)
	if not f and err then error(err) end
	setfenv(f, setmetatable(env or {
		newPackage = function(t) self.new(t) end,
		load = function(f) self:loadDefinition(f, getfenv(2)) end
	}, {__index=_G}))
	f()
end

local cur_size = "normal"
function _M:setDefaultSize(size)
	cur_size = size
end

local cur_id = "default"
function _M:setDefaultId(id)
	if not packages[id] then id = "basic" end
	cur_id = id
end

function _M:resolveFont(name, orname)
	local font = packages[cur_id]
	local size = cur_size
	if not font[name] then name = orname end
	if not font[name] then name = "default" end
	if not font[name][size] then size = "normal" end
	return font[name], size
end

function _M:getFont(name, orname)
	local font, size = self:resolveFont(name, orname)
	return font.font, font[size]
end

function _M:get(name, force)
	local font, size = self:resolveFont(name, orname)
	local f = core.display.newFont(font.font, font[size], font.bold or force)
	if font.bold then f:setStyle("bold") end
	return f
end

function _M:list()
	local list = {}
	for _, f in pairs(packages) do list[#list+1] = f end
	table.sort(list, function(a, b) return a.weight > b.weight end)
	return list
end

function _M:init(t)
	assert(t.id, "no font package id")
	assert(t.default, "no font package default")

	for k, e in pairs(t) do self[k] = e end

	packages[t.id] = self
end
