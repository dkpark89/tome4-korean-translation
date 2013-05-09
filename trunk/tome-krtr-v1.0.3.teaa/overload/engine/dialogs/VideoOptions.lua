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
	Dialog.init(self, "화면 설정", game.w * 0.8, game.h * 0.8)

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

function _M:generateList()
	-- Makes up the list
	local list = {}
	local i = 0

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text="화면의 해상도를 설정합니다.\n\nDisplay resolution."}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#해상도 설정#WHITE##{normal}#", status=function(item)
		return config.settings.window.size
	end, fct=function(item)
		local menu = require("engine.dialogs.DisplayResolution").new(function() self.c_list:drawItem(item) end)
		game:registerDialog(menu)
	end,}

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"화면의 재생 빈도를 설정합니다.\n이 수치가 낮으면 CPU의 부하가 적게 걸리고, 높으면 게임의 반응 속도가 좋아집니다.\n\nRequest this display refresh rate.\nSet it lower to reduce CPU load, higher to increase interface responsiveness.#WHITE#"}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#FPS 설정#WHITE##{normal}#", status=function(item)
		return tostring(config.settings.display_fps)
	end, fct=function(item)
		game:registerDialog(GetQuantity.new("재생 빈도를 입력하시오", "5 에서 60 사이", config.settings.display_fps, 60, function(qty)
			qty = util.bound(qty, 5, 60)
			game:saveSettings("display_fps", ("display_fps = %d\n"):format(qty))
			config.settings.display_fps = qty
			core.game.setFPS(qty)
			self.c_list:drawItem(item)
		end), 5)
	end,}

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"입자 효과의 밀도를 결정합니다.\n이 설정은 게임 내부의 여러가지 입자 효과들이 얼마나 자세하게 표현될지를 결정합니다.\n주문 효과 등의 표현시 게임이 너무 느려진다면 이 설정치를 낮추세요.\n\nControls the particle effects density.\nThis option allows to change the density of the many particle effects in the game.\nIf the game is slow when displaying spell effects try to lower this setting.#WHITE#"}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#입자 효과 밀도#WHITE##{normal}#", status=function(item)
		return tostring(config.settings.particles_density)
	end, fct=function(item)
		game:registerDialog(GetQuantity.new("밀도를 입력하시오", "0 에서 100 사이", config.settings.particles_density, 100, function(qty)
			game:saveSettings("particles_density", ("particles_density = %d\n"):format(qty))
			config.settings.particles_density = qty
			self.c_list:drawItem(item)
		end))
	end,}

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"글자들을 매끄럽게 보여줄지 결정합니다.\n글자들이 보기 좋아지지만, 게임 속도가 조금 느려질 수 있습니다.\n\n#LIGHT_RED#이 설정의 효과는 게임을 다시 시작해야 적용됩니다.#WHITE#\n\nActivates antialiased texts.\nTexts will look nicer but it can be slower on some computers.\n\n#LIGHT_RED#You must restart the game for it to take effect.#WHITE#"}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#부드러운 글자#WHITE##{normal}#", status=function(item)
		return tostring(core.display.getTextBlended() and "사용" or "사용하지 않음")
	end, fct=function(item)
		local state = not core.display.getTextBlended()
		core.display.setTextBlended(state)
		game:saveSettings("aa_text", ("aa_text = %s\n"):format(tostring(state)))
		self.c_list:drawItem(item)
	end,}

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"화면의 프레임 버퍼를 사용할지 결정합니다.\n이 설정을 사용하면 몇몇 특별한 화면 효과를 볼 수 있습니다.\n만약 화면에 이상한 변화나 에러(glitch)가 발생한다면 이 설정을 '사용하지 않음' 으로 바꿔보십시오.\n\n#LIGHT_RED#이 설정의 효과는 게임을 다시 시작해야 적용됩니다.#WHITE#\n\nActivates framebuffers.\nThis option allows for some special graphical effects.\nIf you encounter weird graphical glitches try to disable it.\n\n#LIGHT_RED#You must restart the game for it to take effect.#WHITE#"}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#프레임버퍼#WHITE##{normal}#", status=function(item)
		return tostring(config.settings.fbo_active and "사용" or "사용하지 않음")
	end, fct=function(item)
		config.settings.fbo_active = not config.settings.fbo_active
		game:saveSettings("fbo_active", ("fbo_active = %s\n"):format(tostring(config.settings.fbo_active)))
		self.c_list:drawItem(item)
	end,}

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"OpenGL의 그림자 효과를 사용할지 결정합니다.\n이 설정을 사용하면 몇몇 특별한 화면 효과를 볼 수 있습니다.\n만약 화면이 이상한 변화나 에러(glitch)가 발생한다면 이 설정을 '사용하지 않음' 으로 바꿔보십시오.\n\n#LIGHT_RED#이 설정의 효과는 게임을 다시 시작해야 적용됩니다.#WHITE#\n\nActivates OpenGL Shaders.\nThis option allows for some special graphical effects.\nIf you encounter weird graphical glitches try to disable it.\n\n#LIGHT_RED#You must restart the game for it to take effect.#WHITE#"}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#OpenGL 그림자효과#WHITE##{normal}#", status=function(item)
		return tostring(config.settings.shaders_active and "사용" or "사용하지 않음")
	end, fct=function(item)
		config.settings.shaders_active = not config.settings.shaders_active
		game:saveSettings("shaders_active", ("shaders_active = %s\n"):format(tostring(config.settings.shaders_active)))
		self.c_list:drawItem(item)
	end,}

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"게임에서 제공하는 마우스 커서를 사용할지 결정합니다.\n사용하지 않으면 운영체제에서 제공하는 마우스 커서가 사용됩니다.\n\n#LIGHT_RED#이 설정의 효과는 게임을 다시 시작해야 적용됩니다.#WHITE#\n\nUse the custom cursor.\nDisabling it will use your normal operating system cursor.#WHITE#"}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#마우스 커서#WHITE##{normal}#", status=function(item)
		return tostring(config.settings.mouse_cursor and "사용" or "사용하지 않음")
	end, fct=function(item)
		config.settings.mouse_cursor = not config.settings.mouse_cursor
		game:updateMouseCursor()
		game:saveSettings("mouse_cursor", ("mouse_cursor = %s\n"):format(tostring(config.settings.mouse_cursor)))
		self.c_list:drawItem(item)
	end,}

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"감마 보정값을 설정합니다.\n밝은 화면을 원한다면, 높은 값으로 설정하세요.\n\nGamma correction setting.\nIncrease this to get a brighter display.#WHITE#"}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#감마 보정값 설정#WHITE##{normal}#", status=function(item)
		return tostring(config.settings.gamma_correction)
	end, fct=function(item)
		game:registerDialog(GetQuantity.new("감마 보정값 설정", "50 에서 300 사이", config.settings.gamma_correction, 300, function(qty)
			qty = util.bound(qty, 50, 300)
			game:saveSettings("gamma_correction", ("gamma_correction = %d\n"):format(qty))
			config.settings.gamma_correction = qty
			game:setGamma(config.settings.gamma_correction / 100)
			self.c_list:drawItem(item)
		end), 50)
	end,}

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"게임을 불러올 때 사용되는 그림 중에서, '공격적' 일 수 있는 것을 허용하지 않게 됩니다.\n\nDisallow boot images that could be fuond 'offensive'.#WHITE#"}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#시동 검열#WHITE##{normal}#", status=function(item)
		return tostring(config.settings.censor_boot and "사용" or "사용하지 않음")
	end, fct=function(item)
		config.settings.censor_boot = not config.settings.censor_boot
		game:saveSettings("censor_boot", ("censor_boot = %s\n"):format(tostring(config.settings.censor_boot)))
		self.c_list:drawItem(item)
	end,}

	self.list = list
end
