﻿-- TE4 - T-Engine 4
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

require "engine.class"
local Dialog = require "engine.ui.Dialog"
local List = require "engine.ui.List"
local Textzone = require "engine.ui.Textzone"

module(..., package.seeall, class.inherit(Dialog))

function _M:init()
	Dialog.init(self, "대화창에서 무시할 사항", 500, 400)

	local list = {}
	for l, _ in pairs(config.settings.chat.ignores) do if _ then list[#list+1] = {name=l} end end

	local c_list = List.new{width=self.iw - 10, height=400, scrollbar=true, list=list, fct=function(item) 
		Dialog:yesnoPopup("무시하기 중단", "정말 다음 사항들을 무시하지 않습니까? : "..(item.kr_name or item.name), function(ret) if ret then
			config.settings.chat.ignores[item.name] = nil
			self:regen()
		end end, "예", "아니오")
	end}

	local c_desc = Textzone.new{width=self.iw - 10, height=1, auto_height=true, text="특정 상대의 메세지를 무시하려면 클릭하세요."}
	local uis = { 
		{left=0, top=0, ui=c_desc},
		{left=0, top=c_desc.h+5, ui=c_list},
	}
	self:loadUI(uis)
	self:setupUI(false, true)

	self.key:addBinds{
		EXIT = function() game:unregisterDialog(self) end,
	}
end

function _M:unload()
	profile.chat:saveIgnores()
end

function _M:regen()
	local d = new()
	d.__showup = false
	game:replaceDialog(self, d)
	self.next_dialog = d
end
