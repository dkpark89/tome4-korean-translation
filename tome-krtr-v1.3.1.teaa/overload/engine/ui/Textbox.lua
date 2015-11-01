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
local Base = require "engine.ui.Base"
local Focusable = require "engine.ui.Focusable"

--- A generic UI textbox
module(..., package.seeall, class.inherit(Base, Focusable))

function _M:init(t)
	self.title = assert(t.title, "no textbox title")
	self.text = t.text or ""
	self.size_title = t.size_title or t.title
	self.old_text = self.text
	self.on_mouse = t.on_mouse
	self.hide = t.hide
	self.on_change = t.on_change
	self.max_len = t.max_len or 999
	self.fct = assert(t.fct, "no textbox fct")
	self.chars = assert(t.chars, "no textbox chars")
	self.filter = t.filter or function(c) return c end

	self.tmp = {}
	for i = 1, #self.text do self.tmp[#self.tmp+1] = self.text:sub(i, i) end
	self.cursor = #self.tmp + 1
	self.scroll = 1

	Base.init(self, t)
end

function _M:on_focus(v)
	game:onTickEnd(function() self.key:unicodeInput(v) end)
end

function _M:generate()
	self.mouse:reset()
	self.key:reset()

	-- Draw UI
	local title_w = self.font:size(self.size_title)
	self.title_w = title_w
	local frame_w = self.chars * self.font_mono_w + 12
	self.w = title_w + frame_w
	local font_height = self.font_mono:height()
	self.h = font_height + 6

	self.texcursor = self:getUITexture("ui/textbox-cursor.png")
	self.frame = self:makeFrame("ui/textbox", frame_w, self.h)
	self.frame_sel = self:makeFrame("ui/textbox-sel", frame_w, self.h)

	local w, h = self.w, self.h
	local fw, fh = frame_w - 12, font_height
	self.fw, self.fh = fw, fh
	self.text_x = 6 + title_w
	self.text_y = (h - fh) / 2
	self.cursor_y = (h - self.texcursor.h) / 2
	self.max_display = math.floor(fw / self.font_mono_w)
	self:updateText()

	if title_w > 0 then
		self.tex = self:drawFontLine(self.font, self.title, title_w)
	end

	-- Add UI controls
	self.mouse:registerZone(title_w + 6, 0, fw, h, function(button, x, y, xrel, yrel, bx, by, event)
		if event == "button" and button == "left" then
			self.cursor = util.bound(math.floor(bx / self.font_mono_w) + self.scroll, 1, #self.tmp+1)
			self:updateText()
		elseif event == "button" and self.on_mouse then
			self.on_mouse(button, x, y, xrel, yrel, bx, by, event)
		end
	end)
	self.key:addBind("ACCEPT", function() self.fct(self.text) end)
	self.key:addIgnore("_ESCAPE", true)
	self.key:addIgnore("_TAB", true)
	self.key:addIgnore("_UP", true)
	self.key:addIgnore("_DOWN", true)

	self.key:addCommands{
		_LEFT = function() self.cursor = util.bound(self.cursor - 1, 1, #self.tmp+1) self.scroll = util.scroll(self.cursor, self.scroll, self.max_display) self:updateText() end,
		_RIGHT = function() self.cursor = util.bound(self.cursor + 1, 1, #self.tmp+1) self.scroll = util.scroll(self.cursor, self.scroll, self.max_display) self:updateText() end,
		_DELETE = function()
			if self.cursor <= #self.tmp then
				table.remove(self.tmp, self.cursor)
				self:updateText()
			end
		end,
		_BACKSPACE = function()
			if self.cursor > 1 then
				table.remove(self.tmp, self.cursor - 1)
				self.cursor = self.cursor - 1
				self.scroll = util.scroll(self.cursor, self.scroll, self.max_display)
				self:updateText()
			end
		end,
		_HOME = function()
			self.cursor = 1
			self.scroll = util.scroll(self.cursor, self.scroll, self.max_display)
			self:updateText()
		end,
		_END = function()
			self.cursor = #self.tmp + 1
			self.scroll = util.scroll(self.cursor, self.scroll, self.max_display)
			self:updateText()
		end,
		__TEXTINPUT = function(c)
			if #self.tmp < self.max_len then
				if self.filter(c) then
					table.insert(self.tmp, self.cursor, self.filter(c))
					self.cursor = self.cursor + 1
					self.scroll = util.scroll(self.cursor, self.scroll, self.max_display)
					self:updateText()
				end
			end
		end,
		[{"_v", "ctrl"}] = function(c)
			local s = core.key.getClipboard()
			if s then
				for i = 1, #s do
					if #self.tmp >= self.max_len then break end
					local c = string.sub(s, i, i)
					table.insert(self.tmp, self.cursor, self.filter(c))
					self.cursor = self.cursor + 1
					self.scroll = util.scroll(self.cursor, self.scroll, self.max_display)
				end
				self:updateText()
			end
		end,
	}
end

function _M:setText(text)
	self.text = text
	self.tmp = {}
	for i = 1, #self.text do self.tmp[#self.tmp+1] = self.text:sub(i, i) end
	self.cursor = #self.tmp + 1
	self.scroll = 1
	self:updateText()
end

function _M:updateText()
	if not self.tmp[1] then self.tmp = {} end
	self.text = table.concat(self.tmp)
	local text
	local b, e = self.scroll, math.min(self.scroll + self.max_display - 1, #self.tmp)
	if not self.hide then text = table.concat(self.tmp, nil, b, e)
	else text = string.rep("*", e - b + 1) end

	self.text_tex = self:drawFontLine(self.font_mono, text, self.fw)

	if self.on_change and self.old_text ~= self.text then self.on_change(self.text) end
	self.old_text = self.text
end

function _M:display(x, y, nb_keyframes)
	local text_x, text_y = self.text_x, self.text_y
	if self.tex then
		if self.text_shadow then self:textureToScreen(self.tex, x+1, y+text_y+1, 0, 0, 0, self.text_shadow) end
		self:textureToScreen(self.tex, x, y+text_y)
	end
	if self.focused then
		self:drawFrame(self.frame_sel, x + self.title_w, y)
		local cursor_x = self.font_mono:size(self.text:sub(self.scroll, self.cursor - 1))
		self:textureToScreen(self.texcursor, x + self.text_x + cursor_x - (self.texcursor.w / 2) + 2, y + self.cursor_y)
	else
		self:drawFrame(self.frame, x + self.title_w, y)
		if self.focus_decay then
			self:drawFrame(self.frame_sel, x + self.title_w, y, 1, 1, 1, self.focus_decay / self.focus_decay_max_d)
			self.focus_decay = self.focus_decay - nb_keyframes
			if self.focus_decay <= 0 then self.focus_decay = nil end
		end
	end
	if self.text_shadow then self:textureToScreen(self.text_tex, x+1 + self.text_x, y+1 + self.text_y, 0, 0, 0, self.text_shadow) end
	self:textureToScreen(self.text_tex, x+1 + self.text_x, y+1 + self.text_y)
end
