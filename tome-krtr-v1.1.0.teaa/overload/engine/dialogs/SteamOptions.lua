-- TE4 - T-Engine 4
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

require "engine.class"
local Dialog = require "engine.ui.Dialog"
local TreeList = require "engine.ui.TreeList"
local Textzone = require "engine.ui.Textzone"
local Separator = require "engine.ui.Separator"
local GetQuantity = require "engine.dialogs.GetQuantity"

module(..., package.seeall, class.inherit(Dialog))

function _M:init()
	Dialog.init(self, "스팀 설정", game.w * 0.8, game.h * 0.8)

	self.c_desc = Textzone.new{width=math.floor(self.iw / 2 - 10), height=self.ih, text=""}

	self:generateList()

	self.c_list = TreeList.new{width=math.floor(self.iw / 2 - 10), height=self.ih - 10, scrollbar=true, columns={
		{width=60, display_prop="name"},
		{width=40, display_prop="status"},
	}, tree=self.list, fct=function(item) end, select=function(item, sel) self:select(item) end}

	self:loadUI{
		{left=0, top=0, ui=self.c_list},
		{right=0, top=0, ui=self.c_desc},
		{hcenter=0, top=5, ui=Separator.new{dir="horizontal", size=self.ih - 10}},
	}
	self:setFocus(self.c_list)
	self:setupUI()

	self.key:addBinds{
		EXIT = function() game:unregisterDialog(self) end,
	}
end

function _M:select(item)
	if item and self.uis[2] then
		self.uis[2].ui = item.zone
	end
end

function _M:purgeCloud()
	local oldns = core.steam.getFileNamespace()
	core.steam.setFileNamespace("")
	local list = core.steam.listFilesEndingWith("")
	for _, file in ipairs(list) do
		core.steam.deleteFile(file)
	end
	core.steam.setFileNamespace(oldns)
end

function _M:generateList()
	-- Makes up the list
	local list = {}
	local i = 0

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"스팀 클라우드 저장 사용\n스팀 클라우드 서비스를 사용해서, 어디서나 세이브 파일을 불러올 수 있게 됩니다.\n종량제 등으로 인해 인터넷 사용량에 한계가 있다면, 설정을 바꾸세요.#WHITE#\n\nEnable Steam Cloud saves.\nYour saves will be put on steam cloud and always be availwable everywhere.\nDisable if you have bandwidth limitations.#WHITE#"}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#스팀 클라우드 저장#WHITE##{normal}#", status=function(item)
		return tostring(core.steam.isCloudEnabled(true) and "사용" or "사용하지 않음")
	end, fct=function(item)
		core.steam.cloudEnable(not core.steam.isCloudEnabled(true))
		self.c_list:drawItem(item)
	end,}

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"스팀 클라우드 저장 초기화\n스팀 클라우드에 있는 모든 세이브 파일을 삭제합니다. (자신의 컴퓨터에 저장된 세이브 파일은 삭제되지 않습니다) 스팀 클라우드 저장에 문제가 있을 경우에만 사용하세요. (보통은 게임이 자동적으로 설정을 해줍니다)#WHITE#\n\nPurge all Steam Cloud saves.\nThis will remove all saves from the cloud cloud (but not your local copy). Only use if you somehow encounter storage problems on it (which should not happen, the game automatically manages it for you).#WHITE#"}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#클라우드 저장 초기화#WHITE##{normal}#", status=function(item)
		return "purge"
	end, fct=function(item)
		Dialog:yesnoPopup("스팀 클라우드 초기화", "정말로 초기화합니까?", function(ret) if ret then
			self:purgeCloud()
			Dialog:simplePopup("스팀 클라우드 초기화", "클라우드에 있는 모든 세이브 파일이 삭제되었습니다.")
		end end)
	end,}

	self.list = list
end
