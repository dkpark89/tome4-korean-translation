-- ToME - Tales of Maj'Eyal
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
local Dialog = require "engine.ui.Dialog"
local TreeList = require "engine.ui.TreeList"
local Textzone = require "engine.ui.Textzone"
local Separator = require "engine.ui.Separator"
local GetQuantity = require "engine.dialogs.GetQuantity"
local Tabs = require "engine.ui.Tabs"

module(..., package.seeall, class.inherit(Dialog))

function _M:init()
	Dialog.init(self, "게임 설정", game.w * 0.8, game.h * 0.8)

	self.c_desc = Textzone.new{width=math.floor(self.iw / 2 - 10), height=self.ih, text=""}

	local tabs = {
		{title="UI", kind="ui"},
		{title="게임진행", kind="gameplay"},
		{title="온라인", kind="online"},
		{title="기타", kind="misc"}
	}
	self:triggerHook{"GameOptions:tabs", tab=function(title, fct)
		local id = #tabs+1
		tabs[id] = {title=title, kind="hooktab"..id}
		self['generateListHooktab'..id] = fct
	end}

	self.c_tabs = Tabs.new{width=self.iw - 5, tabs=tabs, on_change=function(kind) self:switchTo(kind) end}

	self:loadUI{
		{left=0, top=0, ui=self.c_tabs},
		{left=0, top=self.c_tabs.h, ui=self.c_list},
		{right=0, top=self.c_tabs.h, ui=self.c_desc},
		{hcenter=0, top=5+self.c_tabs.h, ui=Separator.new{dir="horizontal", size=self.ih - 10}},
	}
	self:setFocus(self.c_list)
	self:setupUI()

	self.key:addBinds{
		EXIT = function() game:unregisterDialog(self) end,
	}
end

function _M:select(item)
	if item and self.uis[3] then
		self.uis[3].ui = item.zone
	end
end

function _M:switchTo(kind)
	self['generateList'..kind:capitalize()](self)
	self:triggerHook{"GameOptions:generateList", list=self.list, kind=kind}

	self.c_list = TreeList.new{width=math.floor(self.iw / 2 - 10), height=self.ih - 10, scrollbar=true, columns={
		{width=60, display_prop="name"},
		{width=40, display_prop="status"},
	}, tree=self.list, fct=function(item) end, select=function(item, sel) self:select(item) end}
	if self.uis and self.uis[2] then
		self.c_list.mouse.delegate_offset_x = self.uis[2].ui.mouse.delegate_offset_x
		self.c_list.mouse.delegate_offset_y = self.uis[2].ui.mouse.delegate_offset_y
		self.uis[2].ui = self.c_list
	end
end

function _M:generateListUi()
	-- Makes up the list
	local list = {}
	local i = 0

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"어떤 존재나 발사체가 '부드럽게' 이동하도록 화면을 보여줍니다. 이 설정을 0 으로 하면, 이동 애니메이션을 보여주지 않게 됩니다.\n이 수치가 높을수록, 움직임이 천천히 보이게 됩니다.\n\n주의 : 이 설정은 게임 내부의 시간과는 무관합니다. 기존 이동 화면이 끝나지 않았을 때 새로운 명령을 입력하면, 현재의 움직임을 즉시 끝내고 새로운 이동화면을 보여주게 됩니다.\n\nMake the movement of creatures and projectiles 'smooth'. When set to 0 movement will be instantaneous.\nThe higher this value the slower the movements will appear.\n\nNote: This does not affect the turn-based idea of the game. You can move again while your character is still moving, and it will correctly update and compute a new animation."}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#부드러운 이동화면#WHITE##{normal}#", status=function(item)
		return tostring(config.settings.tome.smooth_move)
	end, fct=function(item)
		game:registerDialog(GetQuantity.new("이동 속도 입력 (낮을수록 빠름)", "0 에서 60 사이", config.settings.tome.smooth_move, 60, function(qty)
			game:saveSettings("tome.smooth_move", ("tome.smooth_move = %d\n"):format(qty))
			config.settings.tome.smooth_move = qty
			engine.Map.smooth_scroll = qty
			self.c_list:drawItem(item)
		end))
	end,}

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"'약한 흔들림' 현상의 사용을 결정합니다.\n사용하면 이동하거나 공격할 때 개체들이 더 생동감 있게 움직입니다.\n\nEnables or disables 'twitch' movement.\nWhen enabled creatures will do small bumps when moving and attacking.#WHITE#"}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#약한 흔들림 현상#WHITE##{normal}#", status=function(item)
		return tostring(config.settings.tome.twitch_move and "사용" or "사용하지 않음")
	end, fct=function(item)
		config.settings.tome.twitch_move = not config.settings.tome.twitch_move
		game:saveSettings("tome.twitch_move", ("tome.twitch_move = %s\n"):format(tostring(config.settings.tome.twitch_move)))
		self.c_list:drawItem(item)
	end,}

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"부드러운 연기 효과를 사용합니다.\n사용하지 않으면 연기가 칸마다 '네모' 모양으로 보이지만, 컴퓨터에 부담을 조금 덜 주게 됩니다.\n\nEnables smooth fog-of-war.\nDisabling it will make the fog of war look 'blocky' but might gain a slight performance increase.#WHITE#"}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#부드러운 연기 효과#WHITE##{normal}#", status=function(item)
		return tostring(config.settings.tome.smooth_fov and "사용" or "사용하지 않음")
	end, fct=function(item)
		config.settings.tome.smooth_fov = not config.settings.tome.smooth_fov
		game:saveSettings("tome.smooth_fov", ("tome.smooth_fov = %s\n"):format(tostring(config.settings.tome.smooth_fov)))
		self.c_list:drawItem(item)
	end,}

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"게임 인터페이스를 얼마나 화려하게 만들지 결정합니다. 기본은 '금속 예술품' 방식입니다. '가장 단순' 방식은 장식을 완전히 없애버리며, 장식이 없기 때문에 게임 화면을 덜 가립니다.\n이 설정의 효과는 게임을 다시 시작해야 적용됩니다.\n\nSelect the interface look. Metal is the default one. Simple is basic but takes less screen space.\nYou must restart the game for the change to take effect."}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#게임화면 형식#WHITE##{normal}#", status=function(item)
		return tostring(config.settings.tome.ui_theme2):capitalize():krUIStyle()
	end, fct=function(item)
		local uis = {{name="금속 예술품", ui="metal"}, {name="석기 도구", ui="stone"}, {name="가장 단순", ui="simple"}}
		self:triggerHook{"GameOptions:UIs", uis=uis}
		Dialog:listPopup("게임화면 형식", "원하는 형식을 고르시오.", uis, 300, 200, function(sel)
			if not sel or not sel.ui then return end
			game:saveSettings("tome.ui_theme2", ("tome.ui_theme2 = %q\n"):format(sel.ui))
			config.settings.tome.ui_theme2 = sel.ui
			self.c_list:drawItem(item)
		end)
	end,}

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"HUD를 어떤방식으로 보여줄지 결정합니다. 기본은 '깔끔' 방식입니다.\n#LIGHT_RED#이 설정의 효과는 게임을 다시 시작해야 적용됩니다.#WHITE#\n\nSelect the HUD look. 'Minimalist' is the default one.\n#LIGHT_RED#This will take effect on next restart.#WHITE#"}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#HUD 형식#WHITE##{normal}#", status=function(item)
		return tostring(config.settings.tome.uiset_mode):capitalize():krHUDStyle()
	end, fct=function(item)
		local huds = {{name="깔끔", ui="Minimalist"}, {name="고전", ui="Classic"}}
		self:triggerHook{"GameOptions:HUDs", huds=huds}
		Dialog:listPopup("HUD 형식", "원하는 형식을 고르시오.", huds, 300, 200, function(sel)
			if not sel or not sel.ui then return end
			game:saveSettings("tome.uiset_mode", ("tome.uiset_mode = %q\n"):format(sel.ui))
			config.settings.tome.uiset_mode = sel.ui
			self.c_list:drawItem(item)
		end)
	end,}

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"원래는 글꼴을 선택하는 메뉴입니다. 하지만 한글화와 한글글꼴 적용으로 인해, 현재 이 메뉴는 적용되지 않습니다. 설정을 바꿔도 게임에 영향을 주지 않습니다.\n\nSelect the fonts look. Fantasy is the default one. Basic is simplified and smaller.\nYou must restart the game for the change to take effect."}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#글꼴 모양#WHITE##{normal}#", status=function(item)
		return tostring(config.settings.tome.fonts.type):capitalize():krFontShape()
	end, fct=function(item)
		Dialog:listPopup("글꼴 모양", "글꼴을 선택하시오", {{name="환상적", type="fantasy"}, {name="기본", type="basic"}}, 300, 200, function(sel)
			if not sel or not sel.type then return end
			game:saveSettings("tome.fonts", ("tome.fonts = { type = %q, size = %q }\n"):format(sel.type, config.settings.tome.fonts.size))
			config.settings.tome.fonts.type = sel.type
			self.c_list:drawItem(item)
		end)
	end,}

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"글꼴의 크기를 선택합니다.\n#LIGHT_RED#이 설정의 효과는 게임을 다시 시작해야 적용됩니다.#WHITE#\n\nSelect the fonts size.\nYou must restart the game for the change to take effect."}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#글끌 크기#WHITE##{normal}#", status=function(item)
		return tostring(config.settings.tome.fonts.size):capitalize():krFontSize()
	end, fct=function(item)
		Dialog:listPopup("글골 크기", "크기를 선택하시오", {{name="보통", size="normal"},{name="작음", size="small"},{name="큼", size="big"},}, 300, 200, function(sel)
			if not sel or not sel.size then return end
			game:saveSettings("tome.fonts", ("tome.fonts = { type = %q, size = %q }\n"):format(config.settings.tome.fonts.type, sel.size))
			config.settings.tome.fonts.size = sel.size
			self.c_list:drawItem(item)
		end)
	end,}

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"기록과 대화가 흐려지기 시작하는 시간을 결정합니다.\n만약 0 으로 설정하면 기록이 흐려지지 않게 됩니다.\n\nHow many seconds before log and chat lines begin to fade away.\nIf set to 0 the logs will never fade away."}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#기록의 흐려짐 시간#WHITE##{normal}#", status=function(item)
		return tostring(config.settings.tome.log_fade)
	end, fct=function(item)
		game:registerDialog(GetQuantity.new("기록이 흐려지기 시작하는 시간 (초)", "0 에서 20 사이", config.settings.tome.log_fade, 20, function(qty)
			qty = util.bound(qty, 0, 20)
			game:saveSettings("tome.log_fade", ("tome.log_fade = %d\n"):format(qty))
			config.settings.tome.log_fade = qty
			game.uiset.logdisplay:enableFading(config.settings.tome.log_fade)
			profile.chat:enableFading(config.settings.tome.log_fade)
			self.c_list:drawItem(item)
		end, 0))
	end,}

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"말풍선을 화면에 보여줄 시간을 결정합니다.\n설정 범위는 1 (아주 짧음)에서 100 (10배로 김) 사이이고, 보통의 속도는 10 입니다. 각각의 말풍선마다 따로 적용이 됩니다.\n\nHow long will flying text messages be visible on screen.\nThe range is 1 (very short) to 100 (10x slower) than the normal duration, which varies with each individual message."}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#말풍선을 보여줄 시간#WHITE##{normal}#", status=function(item)
		return tostring((config.settings.tome.flyers_fade_time or 10) )
	end, fct=function(item)
		game:registerDialog(GetQuantity.new("상대적 보여줄 시간 (보통이 10)", "1 에서 100 사이", (config.settings.tome.flyers_fade_time or 10), 100, function(qty)
			qty = util.bound(qty, 1, 100)
			config.settings.tome.flyers_fade_time = qty
			game:saveSettings("tome.flyers_fade_time", ("tome.flyers_fade_time = %d\n"):format(qty))
			self.c_list:drawItem(item)
		end, 1))
	end,}

	if game.uiset:checkGameOption("icons_temp_effects") then
		local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"상태 효과를 글자 대신 아이콘으로 표시합니다.\n\nUses the icons for status effects instead of text.#WHITE#"}
		list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#상태 아이콘 표시#WHITE##{normal}#", status=function(item)
			return tostring(config.settings.tome.effects_icons and "사용" or "사용하지 않음")
		end, fct=function(item)
			config.settings.tome.effects_icons = not config.settings.tome.effects_icons
			game:saveSettings("tome.effects_icons", ("tome.effects_icons = %s\n"):format(tostring(config.settings.tome.effects_icons)))
			game.player.changed = true
			self.c_list:drawItem(item)
		end,}
	end

	if game.uiset:checkGameOption("icons_hotkeys") then
		local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"단축 기술창에 글자 대신 아이콘으로 표시합니다.\n\nUses the icons hotkeys toolbar or the textual one.#WHITE#"}
		list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#단축 기술창 아이콘 표시#WHITE##{normal}#", status=function(item)
			return tostring(config.settings.tome.hotkey_icons and "사용" or "사용하지 않음")
		end, fct=function(item)
			config.settings.tome.hotkey_icons = not config.settings.tome.hotkey_icons
			game:saveSettings("tome.hotkey_icons", ("tome.hotkey_icons = %s\n"):format(tostring(config.settings.tome.hotkey_icons)))
			game.player.changed = true
			game:resizeIconsHotkeysToolbar()
			self.c_list:drawItem(item)
		end,}
	end

	if game.uiset:checkGameOption("hotkeys_rows") then
		local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"단축 기술창이 보여줄 줄 수를 결정합니다.\nHUD가 '깔끔' 방식이라면 이 설정 변경 후 '인터페이스 초기화'를 해야 줄 수가 바뀝니다.\n(단, 이렇게 할 경우 사용자가 설정한 다른 인터페이스의 위치와 크기도 모두 초기화 되어버리니 주의하세요)\n인터페이스의 잠금을 풀고 기술창 크기를 직접 변경하실 수도 있습니다.\n(원래는 이 방식을 사용하라는 의미로 '깔끔' 방식에서는 이 설정이 보이지 않았습니다)\n\nNumber of rows to show in the icons hotkeys toolbar.#WHITE#"}
		list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#단축 기술창 줄 수#WHITE##{normal}#", status=function(item)
			return tostring(config.settings.tome.hotkey_icons_rows)
		end, fct=function(item)
			game:registerDialog(GetQuantity.new("기술창 줄 수", "1에서 4 사이", config.settings.tome.hotkey_icons_rows, 4, function(qty)
				qty = util.bound(qty, 1, 4)
				game:saveSettings("tome.hotkey_icons_rows", ("tome.hotkey_icons_rows = %d\n"):format(qty))
				config.settings.tome.hotkey_icons_rows = qty
				game:resizeIconsHotkeysToolbar()
				self.c_list:drawItem(item)
			end, 1))
		end,}
	end

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"단축 기술창에 보여줄 아이콘의 크기를 결정합니다.\n\nSize of the icons in the hotkeys toolbar.#WHITE#"}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#단축 기술창 아이콘 크기#WHITE##{normal}#", status=function(item)
		return tostring(config.settings.tome.hotkey_icons_size)
	end, fct=function(item)
		game:registerDialog(GetQuantity.new("아이콘 크기", "32 에서 64 사이", config.settings.tome.hotkey_icons_size, 64, function(qty)
			qty = util.bound(qty, 32, 64)
			game:saveSettings("tome.hotkey_icons_size", ("tome.hotkey_icons_size = %d\n"):format(qty))
			config.settings.tome.hotkey_icons_size = qty
			game:resizeIconsHotkeysToolbar()
			self.c_list:drawItem(item)
		end, 32))
	end,}
	
	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"이 설정을 사용하지 않으면, 모든 게임을 통틀어 처음으로 알게 된 지식만 보여줍니다.\n이 설정을 사용하면, 캐릭터마다 처음으로 알게 된 지식을 보여줍니다.\n\nIf disabled lore popups will only appear the first time you see the lore on your profile.\nIf enabled it will appear the first time you see it with each character.#WHITE#"}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#항상 지식 보여주기#WHITE##{normal}#", status=function(item)
		return tostring(config.settings.tome.lore_popup and "사용" or "사용하지 않음")
	end, fct=function(item)
		config.settings.tome.lore_popup = not config.settings.tome.lore_popup
		game:saveSettings("tome.lore_popup", ("tome.lore_popup = %s\n"):format(tostring(config.settings.tome.lore_popup)))
		self.c_list:drawItem(item)
	end,}

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"이 설정을 사용하지 않으면, 장비에 포함된 기술이 자동으로 단축키에 연결되지 않게 됩니다. 일반적인 물건에 포함된 기술은 소지품 목록 창에서 마우스 드래그나 단축키를 눌러 연결시킬 수 있습니다.\n\nIf disabled items with activations will not be auto-added to your hotkeys, you will need to manualty drag them from the inventory screen.#WHITE#"}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#항상 물건을 단축키로 연결#WHITE##{normal}#", status=function(item)
		return tostring(config.settings.tome.auto_hotkey_object and "사용" or "사용하지 않음")
	end, fct=function(item)
		config.settings.tome.auto_hotkey_object = not config.settings.tome.auto_hotkey_object
		game:saveSettings("tome.auto_hotkey_object", ("tome.auto_hotkey_object = %s\n"):format(tostring(config.settings.tome.auto_hotkey_object)))
		self.c_list:drawItem(item)
	end,}

	self.list = list
end

function _M:generateListGameplay()
	-- Makes up the list
	local list = {}
	local i = 0

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"스크롤을 시작할 플레이어와 화면 가장자리 사이의 최소거리입니다. 이 수치가 충분히 높으면, 플레이어 캐릭터는 항상 게임 화면의 가운데에 있게 됩니다.\n\nDefines the distance from the screen edge at which scrolling will start. If set high enough the game will always center on the player.#WHITE#"}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#스크롤 거리#WHITE##{normal}#", status=function(item)
		return tostring(config.settings.tome.scroll_dist)
	end, fct=function(item)
		game:registerDialog(GetQuantity.new("스크롤 거리", "1 에서 30 사이", config.settings.tome.scroll_dist, 30, function(qty)
			qty = util.bound(qty, 1, 30)
			game:saveSettings("tome.scroll_dist", ("tome.scroll_dist = %d\n"):format(qty))
			config.settings.tome.scroll_dist = qty
			self.c_list:drawItem(item)
		end, 1))
	end,}

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"특정 지역에서 날씨 효과를 보여줄지 결정합니다.\n사용하지 않으면 컴퓨터에 부담을 조금 덜 주게 됩니다. 기존에 이미 방문한 지역에는 영향을 주지 않습니다.\n\nEnables or disables weather effects in some zones.\nDisabling it can gain some performance. It will not affect previously visited zones.#WHITE#"}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#날씨 효과#WHITE##{normal}#", status=function(item)
		return tostring(config.settings.tome.weather_effects and "사용" or "사용하지 않음")
	end, fct=function(item)
		config.settings.tome.weather_effects = not config.settings.tome.weather_effects
		game:saveSettings("tome.weather_effects", ("tome.weather_effects = %s\n"):format(tostring(config.settings.tome.weather_effects)))
		self.c_list:drawItem(item)
	end,}

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"낮과 밤에 따른 여러 가지 조명 효과를 보여줄지 결정합니다.\n\nEnables or disables day/night light variations effects..#WHITE#"}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#낮/밤 조명 변화#WHITE##{normal}#", status=function(item)
		return tostring(config.settings.tome.daynight and "사용" or "사용하지 않음")
	end, fct=function(item)
		config.settings.tome.daynight = not config.settings.tome.daynight
		game:saveSettings("tome.daynight", ("tome.daynight = %s\n"):format(tostring(config.settings.tome.daynight)))
		self.c_list:drawItem(item)
	end,}

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"지도에서 마우스를 클릭하는 곳으로 이동할 것인지 결정합니다.\n\nEnables easy movement using the mouse by left-clicking on the map.#WHITE#"}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#마우스를 사용한 이동#WHITE##{normal}#", status=function(item)
		return tostring(config.settings.mouse_move and "사용" or "사용하지 않음")
	end, fct=function(item)
		config.settings.mouse_move = not config.settings.mouse_move
		game:saveSettings("mouse_move", ("mouse_move = %s\n"):format(tostring(config.settings.mouse_move)))
		self.c_list:drawItem(item)
	end,}

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"빠른 근접 목표 지정 방식을 사용할 것인지 결정합니다.\n인접한 목표를 필요로 하는 기술 사용시, 방향키를 누르면 따로 확인받지 않고 해당하는 방향의 존재가 자동으로 목표로 지정됩니다.\n\nEnables quick melee targetting.\nTalents that require a melee target will automatically target when pressing a direction key instead of requiring a confirmation.#WHITE#"}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#빠른 근접 목표 지정#WHITE##{normal}#", status=function(item)
		return tostring(config.settings.tome.immediate_melee_keys and "사용" or "사용하지 않음")
	end, fct=function(item)
		config.settings.tome.immediate_melee_keys = not config.settings.tome.immediate_melee_keys
		game:saveSettings("tome.immediate_melee_keys", ("tome.immediate_melee_keys = %s\n"):format(tostring(config.settings.tome.immediate_melee_keys)))
		self.c_list:drawItem(item)
	end,}
	
	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"빠른 근접 목표 자동 공격 방식을 사용할 것인지 결정합니다.\n인접한 목표를 필요로 하는 기술 사용시, 시야 주변에 인접한 적 하나만이 존재할 경우 자동으로 기술이 사용됩니다.\n\nEnables quick melee targetting auto attacking.\nTalents that require a melee target will automatically target and confirm if there is only one hostile creatue around.#WHITE#"}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#근접 목표 자동 공격 사용#WHITE##{normal}#", status=function(item)
		return tostring(config.settings.tome.immediate_melee_keys_auto and "사용" or "사용하지 않음")
	end, fct=function(item)
		config.settings.tome.immediate_melee_keys_auto = not config.settings.tome.immediate_melee_keys_auto
		game:saveSettings("tome.immediate_melee_keys_auto", ("tome.immediate_melee_keys_auto = %s\n"):format(tostring(config.settings.tome.immediate_melee_keys_auto)))
		self.c_list:drawItem(item)
	end,}

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"새로운 게임을 시작할 때, 캐릭터의 기본 기술을 자동으로 배운 상태에서 시작할지 결정합니다.\n\nNew games begin with some talent points auto-assigned.#WHITE#"}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#캐릭터 생성시 기본 기술 할당#WHITE##{normal}#", status=function(item)
		return tostring(config.settings.tome.autoassign_talents_on_birth and "사용" or "사용하지 않음")
	end, fct=function(item)
		config.settings.tome.autoassign_talents_on_birth = not config.settings.tome.autoassign_talents_on_birth
		game:saveSettings("tome.autoassign_talents_on_birth", ("tome.autoassign_talents_on_birth = %s\n"):format(tostring(config.settings.tome.autoassign_talents_on_birth)))
		self.c_list:drawItem(item)
	end,}

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"자동탐험을 하기 전에, 자동으로 충분한 휴식을 취할지 결정합니다.\n\nAlways rest to full before auto-exploring.#WHITE#"}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#자동탐험시 휴식사용#WHITE##{normal}#", status=function(item)
		return tostring(config.settings.tome.rest_before_explore and "사용" or "사용하지 않음")
	end, fct=function(item)
		config.settings.tome.rest_before_explore = not config.settings.tome.rest_before_explore
		game:saveSettings("tome.rest_before_explore", ("tome.rest_before_explore = %s\n"):format(tostring(config.settings.tome.rest_before_explore)))
		self.c_list:drawItem(item)
	end,}

self.list = list
end

function _M:generateListOnline()
	-- Makes up the list
	local list = {}
	local i = 0

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"화면에 보여줄 대화 메세지 종류를 결정합니다.\n\nConfigure the chat filters to select what kind of messages to see.#WHITE#"}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#대화창에서 보여줄 사항#WHITE##{normal}#", status=function(item)
		return "설정을 선택"
	end, fct=function(item)
		game:registerDialog(require("engine.dialogs.ChatFilter").new({
			{name="죽음", kind="death"},
			{name="물건 및 생물체 링크", kind="link"},
		}))
	end,}

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"대화창에서 무시할 사항을 설정합니다.\n\nConfigure the chat ignore filter.#WHITE#"}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#대화창에서 무시할 사항#WHITE##{normal}#", status=function(item)
		return "설정을 선택"
	end, fct=function(item)	game:registerDialog(require("engine.dialogs.ChatIgnores").new()) end,}

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"이야기를 들을 대화창 채널을 설정합니다.\n\nConfigure the chat channels to listen to.#WHITE#"}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#대화창 채널#WHITE##{normal}#", status=function(item)
		return "설정을 선택"
	end, fct=function(item)	game:registerDialog(require("engine.dialogs.ChatChannels").new()) end,}

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"온라인으로 게임 진행 중 서버에서 보내는 여러가지 이벤트 사용여부를 설정합니다.\n사용하지 않으면 멋지고 재미있는 지역들을 놓치게 됩니다.#WHITE#\n\nAllow various events that are pushed by the server when playing online\nDisabling this will make you miss cool and fun zones.#WHITE#"}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#온라인 이벤트 허용#WHITE##{normal}#", status=function(item) --@@ 한글화 필요
		return tostring(config.settings.tome.allow_online_events and "사용" or "사용하지 않음")
	end, fct=function(item)
		config.settings.tome.allow_online_events = not config.settings.tome.allow_online_events
		game:saveSettings("tome.allow_online_events", ("tome.allow_online_events = %s\n"):format(tostring(config.settings.tome.allow_online_events)))
		self.c_list:drawItem(item)
	end,}

	self.list = list
end

function _M:generateListMisc()
	-- Makes up the list
	local list = {}
	local i = 0

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"백그라운드 방식으로 저장하면서, 계속 게임을 할 수 있습니다.\n#LIGHT_RED#'사용하지 않음'을 선택하는 것을 권장하지 않습니다.#WHITE#\n\nSaves in the background, allowing you to continue playing.\n#LIGHT_RED#Disabling it is not recommended.#WHITE#"}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#백그라운드 방식 저장#WHITE##{normal}#", status=function(item)
		return tostring(config.settings.background_saves and "사용" or "사용하지 않음")
	end, fct=function(item)
		config.settings.background_saves = not config.settings.background_saves
		game:saveSettings("background_saves", ("background_saves = %s\n"):format(tostring(config.settings.background_saves)))
		self.c_list:drawItem(item)
	end,}

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"지역 정보를 지역별로 저장을 하는 대신, 지역의 모든 층마다 별도로 저장합니다.\n이 방식은 저장을 더 자주 하지만, 깊은 던전에서 메모리 사용량을 줄일 수 있습니다.\n\n#LIGHT_RED#이미 방문한 지역정보는 변경되지 않습니다.\n*층이 바뀔 때마다 자동으로 저장을 하지는 않습니다*\n#LIGHT_RED#'사용하지 않음'을 선택하는 것을 권장하지 않습니다.#WHITE#\n\nForces the game to save each level instead of each zone.\nThis makes it save more often but the game will use less memory when deep in a dungeon.\n\n#LIGHT_RED#Changing this option will not affect already visited zones.\n*THIS DOES NOT MAKE A FULL SAVE EACH LEVEL*.\n#LIGHT_RED#Disabling it is not recommended#WHITE#"}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#지역의 층마다 따로 저장#WHITE##{normal}#", status=function(item)
		return tostring(config.settings.tome.save_zone_levels and "사용" or "사용하지 않음")
	end, fct=function(item)
		config.settings.tome.save_zone_levels = not config.settings.tome.save_zone_levels
		game:saveSettings("tome.save_zone_levels", ("tome.save_zone_levels = %s\n"):format(tostring(config.settings.tome.save_zone_levels)))
		self.c_list:drawItem(item)
	end,}

	self.list = list
end
