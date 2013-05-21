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
local List = require "engine.ui.List"

module(..., package.seeall, class.inherit(Dialog))

function _M:init(actions)
	self:generateList(actions)

	Dialog.init(self, "게임 메뉴", 300, 20)

	self.c_list = List.new{width=self.iw, nb_items=#self.list, list=self.list, fct=function(item) self:use(item) end}

	self:loadUI{
		{left=0, top=0, ui=self.c_list},
	}
	self:setFocus(self.c_list)
	self:setupUI(false, true)

	self.key:addBinds{
		EXIT = function() game:unregisterDialog(self) end,
	}
end

function _M:use(item)
	item.fct()
end

function _M:generateList(actions)
	local default_actions = {
		resume = { "게임 계속하기", function() game:unregisterDialog(self) end },
		keybinds = { "명령어 입력 설정", function()
			game:unregisterDialog(self)
			local menu = require("engine.dialogs.KeyBinder").new(game.normal_key, nil, game.gestures)
			game:registerDialog(menu)
		end },
		keybinds_all = { "명령어 입력 설정", function()
			game:unregisterDialog(self)
			local menu = require("engine.dialogs.KeyBinder").new(game.normal_key, true, game.gestures)
			game:registerDialog(menu)
		end },
		video = { "화면 설정", function()
			game:unregisterDialog(self)
			local menu = require("engine.dialogs.VideoOptions").new()
			game:registerDialog(menu)
		end },
		resolution = { "화면 해상도 설정", function()
			game:unregisterDialog(self)
			local menu = require("engine.dialogs.DisplayResolution").new()
			game:registerDialog(menu)
		end },
		achievements = { "달성한 업적 보기", function()
			game:unregisterDialog(self)
			local menu = require("engine.dialogs.ShowAchievements").new(nil, game:getPlayer())
			game:registerDialog(menu)
		end },
		sound = { "소리 설정", function()
			game:unregisterDialog(self)
			local menu = require("engine.dialogs.AudioOptions").new()
			game:registerDialog(menu)
		end },
		highscores = { "고득점 기록 보기", function()
			game:unregisterDialog(self)
			local menu = require("engine.dialogs.ViewHighScores").new()
			game:registerDialog(menu)
	 	end },
		save = { "저장하기", function() game:unregisterDialog(self) game:saveGame() end },
		quit = { "메인 메뉴로 나가기", function() game:unregisterDialog(self) game:onQuit() end },
		exit = { "게임 끝내기", function() game:unregisterDialog(self) game:onExit() end },
	}

	-- Makes up the list
	local list = {}
	local i = 0
	for _, act in ipairs(actions) do
		if type(act) == "string" then
			local a = default_actions[act]
			list[#list+1] = { name=a[1], fct=a[2] }
			i = i + 1
		else
			local a = act
			list[#list+1] = { name=a[1], fct=a[2] }
			i = i + 1
		end
	end
	self.list = list
end
