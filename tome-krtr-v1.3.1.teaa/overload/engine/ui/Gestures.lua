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
local KeyBind = require "engine.KeyBind"

module(..., package.seeall, class.make)

function _M:init(text, key_source, force_all)
	assert(key_source, "no key source")
	self.text = text or "Gesture: "
	self.gesture = ""
	self.gestures = {}
	self.font = core.display.newFont("/data/font/DroidSans.ttf", 12)
	self.votex = nil
	-- self.votex = core.display.loadImage("/data/gfx/te4-icon.png"):glTexture()

	local gesttext = self.text.."WWWWW"
	self.fontmax_w, self.font_h = self.font:size(gesttext)
	self.timeout = 2
	self.lastupdate = os.time()
	self.gesturing = false
	self.mousebuttondown = false
	self.distance = 0
	self.lastgesture = ""
	self.lastgesturename = ""
	self.min_distance = core.display.size() * .030

	self:loadGestures(key_source, force_all)
end

function _M:loadGestures(key_source, force_all)
	local l = {}

	for virtual, t in pairs(KeyBind.binds_def) do
		if (force_all or key_source.virtuals[virtual]) and t.group ~= "debug" then
			l[#l+1] = t
		end
	end
	table.sort(l, function(a,b)
		if a.group ~= b.group then
			return a.group < b.group
		else
			return a.order < b.order
		end
	end)

	-- Makes up the list
	local tree = {}
	local groups = {}
	for _, k in ipairs(l) do
		local bind3 = KeyBind:getBindTable(k)[3]
		local gesture = KeyBind:formatKeyString(util.getval(bind3))
		if k.name ~= "" and k.name~= "--" then
			self:addGesture(gesture, function() key_source:triggerVirtual(k.type) end, k.name)
		end
	end
end

function _M:initGesturing()
	if self.gesturing then return end
	self.vo = core.display.newVO()
	self.gesturing = true
	self.gesture = ""
	self.lastupdate = os.time()
	self.distance = 0
	self.gx, self.gy = nil, nil
end

function _M:addGesturing(d, mx, my)
	if self.lastgesture == d then return end

	if not config.settings.has_gestured then
		game:saveSettings("has_gestured", ("has_gestured = true\n"))
		config.settings.has_gestured = true
		self:gestureTutorial()
		return
	end

	self.gesture = self.gesture..d
	self.lastgesture = d
	self.lastupdate = os.time()
	self.distance = 0
	self.omx = mx
	self.omy = my

	local x, y = self.gx or mx, self.gy or my

	local start, stop = 3, 1
	local a = 0.6
	if self.shader then start, stop = 8, 3 a = 1 end

	if d == "L" then
		local r, g, b = colors.hex1unpack("ed1515")
		self.vo:addQuad(r, g, b, a,
			{x, y - start, 0, 0},
			{x, y + start, 1, 0},
			{x - 200, y + stop, 1, 0},
			{x - 200, y - stop, 0, 1}
		)
		self.gx, self.gy = x - 200, y
	elseif d == "R" then
		local r, g, b = colors.hex1unpack("d6ed15")
		self.vo:addQuad(r, g, b, a,
			{x, y - start, 0, 0},
			{x, y + start, 1, 0},
			{x + 200, y + stop, 1, 0},
			{x + 200, y - stop, 0, 1}
		)
		self.gx, self.gy = x + 200, y
	elseif d == "U" then
		local r, g, b = colors.hex1unpack("15ed2f")
		self.vo:addQuad(r, g, b, a,
			{x - start, y, 0, 0},
			{x + start, y, 1, 0},
			{x + stop, y - 200, 1, 0},
			{x - stop, y - 200, 0, 1}
		)
		self.gx, self.gy = x, y - 200
	elseif d == "D" then
		local r, g, b = colors.hex1unpack("1576ed")
		self.vo:addQuad(r, g, b, a,
			{x - start, y, 0, 0},
			{x + start, y, 1, 0},
			{x + stop, y + 200, 1, 0},
			{x - stop, y + 200, 0, 1}
		)
		self.gx, self.gy = x, y + 200
	end
end

function _M:mouseMove(mx, my)
	if #self.gesture >= 10 then return end
	if self.omx and self.omy then
		self.distance = math.sqrt((self.omy - my)^2 + (self.omx - mx)^2)
		if self.distance > self.min_distance then
			if math.abs(self.omx - mx) > math.abs(self.omy - my) then
				self:initGesturing()
				if self.omx > mx then
					self:addGesturing("L", mx, my)
				else
					self:addGesturing("R", mx, my)
				end
			end
			if math.abs(self.omx - mx) < math.abs(self.omy - my) then
				self:initGesturing()
				if self.omy > my then
					self:addGesturing("U", mx, my)
				else
					self:addGesturing("D", mx, my)
				end
			end
		end
	else
		self.omx = mx
		self.omy = my
	end
end

function _M:isGesturing()
	return self.gesturing
end

function _M:isMouseButtonDown()
	return self.mousebuttondown
end

function _M:changeMouseButton(isDown)
	self.mousebuttondown = isDown
end

function _M:useGesture()
	if self.gestures[self.gesture] then
		self.gestures[self.gesture].func()
	end
end

function _M:reset()
	if self.vo then
		self.fading_vo = self.vo
		self.fading = 1
		if self.gestures[self.gesture] then self.fading_intensity = 1 else self.fading_intensity = 0.6 end
	end

	self.vo = nil
	self.gesturing = false
	self.omx = nil
	self.omy = nil
	self.gesture = ""
	self.lastgesture = ""
	self.distance = 0
end

function _M:addGesture(gesture, func, name)
	self.gestures[gesture] = {}
	self.gestures[gesture].func = func
	self.gestures[gesture].name = name
end

function _M:removeGesture(gesture)
	if not self.gestures[gesture] then return end
	self.gestures[gesture] = nil
end

function _M:empty()
	self.gestures = {}
	self:reset()
end

function _M:setTimeout(timeout)
	self.timeout = timeout
end

function _M:getLastGesture()
	return self.gesture
end

function _M:update()
	if self.gesturing == true then
		if os.difftime(os.time(),  self.lastupdate) >= self.timeout then
			self:reset()
		end
	end
end

function _M:display(display_x, display_y, nb_keyframes)
	if config.settings.hide_gestures or not nb_keyframes then return end

	local intensity = 0.6
	if self.gestures[self.gesture] then intensity = 1 end

	if self.shader then self.shader:use(true) end

	if self.vo then
		if self.shader then
			self.shader:uniIntensity(intensity)
			self.shader:uniFade(1)
		end
		self.vo:toScreen(display_x, display_y, self.votex, 1, 1, 1, self.shader and 1 or 1)
	end

	if self.fading_vo then
		if self.shader then
			self.shader:uniIntensity(self.fading_intensity)
			self.shader:uniFade(self.fading)
		end
		self.fading_vo:toScreen(display_x - (1 - self.fading) * 20, display_y - (1 - self.fading) * 20, self.votex, 1, 1, 1, self.shader and 1 or self.fading)
		self.fading = self.fading - nb_keyframes / 20
		if self.fading <= 0 then
			self.fading_vo = nil
		end
	end
	if self.shader then self.shader:use(false) end
end

function _M:gestureTutorial()
	local Dialog = require "engine.ui.Dialog"
	Dialog:simpleLongPopup("Mouse Gestures", [[
You have started to draw a mouse gesture for the first time!
Gestures allow you to use talents or keyboard action by a simple movement of the mouse. To draw one you simply #{bold}#hold right click + move#{normal}#.
By default no bindings are done for gesture so if you want to use them go to the Keybinds and add some, it's easy and fun!

Gestures movements are color coded to better display which movement to do:
#15ed2f##{italic}#green#{normal}##LAST#: moving up
#1576ed##{italic}#blue#{normal}##LAST#: moving down
#ed1515##{italic}#red#{normal}##LAST#: moving left
#d6ed15##{italic}#yellow#{normal}##LAST#: moving right

If you do not wish to see gestures anymore, you can hide them in the UI section of the Game Options.
]], 600)
end
