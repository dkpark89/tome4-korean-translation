﻿-- TE4 - T-Engine 4
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

require "engine.krtrUtils"
require "engine.class"
local Shader = require "engine.Shader"
local Dialog = require "engine.ui.Dialog"
local Image = require "engine.ui.Image"
local Textzone = require "engine.ui.Textzone"

module(..., package.seeall, class.inherit(Dialog))

function _M:init(title, a)
	local c_frame = Image.new{file="achievement-ui/runes_inner.png", width=154, height=154}
	local c_image = Image.new{file=a.image or "trophy_gold.png", width=128, height=128}
	local color = a.huge and "#GOLD#" or "#LIGHT_GREEN#"
	local c_desc = Textzone.new{width=500, auto_height=true, text=color..(a.kr_name or a.name).."#LAST#\n"..a.desc, font={krFont or "/data/font/DroidSans-Bold.ttf", 26}} --@ 한글 글꼴 추가
	c_desc:setTextShadow(1)
	c_desc:setShadowShader(Shader.default.textoutline and Shader.default.textoutline.shad, 1.2)
	self.ui = "achievement"

	Dialog.init(self, title, 10, 10)

	self:loadUI{
		{left=10, vcenter=0, ui=c_frame},
		{left=10 + (154-128)/2, vcenter=0, ui=c_image},
		{left=c_frame.w+20, vcenter=0, ui=c_desc},
	}
	self:setupUI(true, true, nil, nil, math.max(c_image.h, c_desc.h))

	self.key:addBinds{
		ACCEPT = "EXIT",
		EXIT = function()
			game:unregisterDialog(self)
			if on_exit then on_exit() end
		end,
	}
end
