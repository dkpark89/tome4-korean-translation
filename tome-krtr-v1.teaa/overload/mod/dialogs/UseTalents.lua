-- TE4 - T-Engine 4
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
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

require "engine.krtrUtils" --@@
require "engine.class"
local Dialog = require "engine.ui.Dialog"
local TreeList = require "engine.ui.TreeList"
local ListColumns = require "engine.ui.ListColumns"
local Textzone = require "engine.ui.Textzone"
local TextzoneList = require "engine.ui.TextzoneList"
local Separator = require "engine.ui.Separator"

module(..., package.seeall, class.inherit(Dialog))

function _M:init(actor)
	self.actor = actor
	actor.hotkey = actor.hotkey or {}
	Dialog.init(self, "기술 사용: "..actor.name, game.w * 0.8, game.h * 0.8)

	self.c_tut = Textzone.new{width=math.floor(self.iw / 2 - 10), height=1, auto_height=true, no_color_bleed=true, text=[[
지속형이 아닌 기술은 선택후 원하는 단축키를 누르거나 우클릭을 해서 단축키로 연결할 수 있습니다.
게임 메뉴의 명령어 입력 설정에서 단축키로 사용할 명령어를 정할 수 있습니다 (기본은 숫자키와 '-'키, '='키에 컨트롤, 알트, 쉬프트 키가 조합됩니다).
우클릭을 하면 단축키 연결창을 볼 수 있습니다.
]]}
	self.c_desc = TextzoneList.new{width=math.floor(self.iw / 2 - 10), height=self.ih - self.c_tut.h - 20, scrollbar=true, no_color_bleed=true}

	self:generateList()

	local cols = {
		{name="", width={40,"fixed"}, display_prop="char"},
		{name="기술", width=80, display_prop="name"},
		{name="상태", width=20, display_prop="status"},
		{name="단축키", width={75,"fixed"}, display_prop="hotkey"},
		{name="마우스 클릭", width={60,"fixed"}, display_prop=function(item)
			if item.talent and item.talent == self.actor.auto_shoot_talent then return "클릭"
			elseif item.talent and item.talent == self.actor.auto_shoot_midclick_talent then return "중간클릭"
			else return "" end
		end},
	}
	self.c_list = TreeList.new{width=math.floor(self.iw / 2 - 10), height=self.ih - 10, all_clicks=true, scrollbar=true, columns=cols, tree=self.list, fct=function(item, sel, button) self:use(item, button) end, select=function(item, sel) self:select(item) end, on_drag=function(item, sel) self:onDrag(item) end}
	self.c_list.cur_col = 2

	self:loadUI{
		{left=0, top=0, ui=self.c_list},
		{right=0, top=self.c_tut.h + 20, ui=self.c_desc},
		{right=0, top=0, ui=self.c_tut},
		{hcenter=0, top=5, ui=Separator.new{dir="horizontal", size=self.ih - 10}},
	}
	self:setFocus(self.c_list)
	self:setupUI()

	self.key:addCommands{
		__TEXTINPUT = function(c)
			if c == '@' then
				self:use(self.cur_item, "right")
			end
			if self.list and self.list.chars[c] then
				self:use(self.list.chars[c])
			end
		end,
	}
	engine.interface.PlayerHotkeys:bindAllHotkeys(self.key, function(i) self:defineHotkey(i) end)
	self.key:addBinds{
		EXIT = function() game:unregisterDialog(self) end,
	}
end

function _M:on_register()
	game:onTickEnd(function() self.key:unicodeInput(true) end)
end

function _M:defineHotkey(id)
	if not self.actor.hotkey then return end
	local item = self.cur_item
	if not item or not item.talent then return end

	local t = self.actor:getTalentFromId(item.talent)
	if t.mode == "passive" then return end

	for i = 1, 12 * self.actor.nb_hotkey_pages do
		if self.actor.hotkey[i] and self.actor.hotkey[i][1] == "talent" and self.actor.hotkey[i][2] == item.talent then self.actor.hotkey[i] = nil end
	end

	self.actor.hotkey[id] = {"talent", item.talent}
	--@@
	local tn = t.kr_display_name or t.name
	self:simplePopup("단축키 "..id.." 설정", tn:capitalize():addJosa("가").." 단축키 "..("%d"):format(id):addJosa("로").." 설정되었습니다.")
	self.c_list:drawTree()
	self.actor.changed = true
end

function _M:onDrag(item)
	if item and item.talent then
		local t = self.actor:getTalentFromId(item.talent)
		if t.mode == "passive" then return end
		local s = t.display_entity:getEntityFinalSurface(nil, 64, 64)
		local x, y = core.mouse.get()
		game.mouse:startDrag(x, y, s, {kind="talent", id=t.id}, function(drag, used)
			local x, y = core.mouse.get()
			game.mouse:receiveMouse("drag-end", x, y, true, nil, {drag=drag})
			if drag.used then self.c_list:drawTree() end
		end)
	end
end

function _M:select(item)
	if item then
		self.c_desc:switchItem(item, item.desc)
		self.cur_item = item
	end
end

function _M:use(item, button)
	if not item or not item.talent then return end
	local t = self.actor:getTalentFromId(item.talent)
	if t.mode == "passive" then return end
	if button == "right" then
		local list = {
			{name="단축키 해제", what="unbind"},
			{name="(목표에게) 마우스 클릭으로 사용", what="left"},
			{name="(목표에게) 마우스 중간버튼 클릭으로 사용", what="middle"},
		}

		--local t = self.actor:getTalentFromId(item.talent)
		if self.actor:isTalentAuto(t) then table.insert(list, 1, {name="자동적 사용 비활성화", what="auto-dis"})
		else 
			table.insert(list, 1, {name="인접한 적이 있을때 항상 자동 사용", what="auto-en-4"})
			table.insert(list, 1, {name="적이 있을때 항상 자동 사용", what="auto-en-3"})
			table.insert(list, 1, {name="적이 없을때 항상 자동 사용", what="auto-en-2"})
			table.insert(list, 1, {name="가능한 경우 항상 자동 사용", what="auto-en-1"})
		end

		for i = 1, 12 * self.actor.nb_hotkey_pages do list[#list+1] = {name="단축키 "..i, what=i} end
		
		--@@
		local itn = item.kr_display_name or item.name:toString()
		local tn = (self.actor:getTalentFromId(item.talent).kr_display_name or self.actor:getTalentFromId(item.talent).name):capitalize()
		Dialog:listPopup("기술 연결: "..itn, "이 기술을 어디에 연결하겠습니까?", list, 400, 500, function(b)
			if not b then return end
			if type(b.what) == "number" then
				for i = 1, 12 * self.actor.nb_hotkey_pages do
					if self.actor.hotkey[i] and self.actor.hotkey[i][1] == "talent" and self.actor.hotkey[i][2] == item.talent then self.actor.hotkey[i] = nil end
				end
				self.actor.hotkey[b.what] = {"talent", item.talent}
				self:simplePopup("단축키 "..(b.what).." 설정", tn:addJosa("가").." 단축키 "..("%d"):format(b.what):addJosa("로").." 설정되었습니다.")
			elseif b.what == "middle" then
				self.actor.auto_shoot_midclick_talent = item.talent
				self:simplePopup("마우스 중간클릭 연결", tn:addJosa("가").." 목표에게 마우스 중간 클릭시 사용되도록 연결되었습니다.")
			elseif b.what == "left" then
				self.actor.auto_shoot_talent = item.talent
				self:simplePopup("마우스 클릭 연결", tn:addJosa("가").." 목표에게 마우스 클릭시 사용되도록 연결되었습니다.")
			elseif b.what == "unbind" then
				if self.actor.auto_shoot_talent == item.talent then self.actor.auto_shoot_talent = nil end
				if self.actor.auto_shoot_midclick_talent == item.talent then self.actor.auto_shoot_midclick_talent = nil end
				for i = 1, 12 * self.actor.nb_hotkey_pages do
					if self.actor.hotkey[i] and self.actor.hotkey[i][1] == "talent" and self.actor.hotkey[i][2] == item.talent then self.actor.hotkey[i] = nil end
				end
			elseif b.what == "auto-en-1" then
				self.actor:checkSetTalentAuto(item.talent, true, 1)
			elseif b.what == "auto-en-2" then
				self.actor:checkSetTalentAuto(item.talent, true, 2)
			elseif b.what == "auto-en-3" then
				self.actor:checkSetTalentAuto(item.talent, true, 3)
			elseif b.what == "auto-en-4" then
				self.actor:checkSetTalentAuto(item.talent, true, 4)
			elseif b.what == "auto-dis" then
				self.actor:checkSetTalentAuto(item.talent, false)
			end
			self.c_list:drawTree()
			self.actor.changed = true
		end)
		return
	end

	game:unregisterDialog(self)
	self.actor:useTalent(item.talent)
end

-- Display the player tile
function _M:innerDisplay(x, y, nb_keyframes)
	if self.cur_item and self.cur_item.entity then
		self.cur_item.entity:toScreen(game.uiset.hotkeys_display_icons.tiles, x + self.iw - 64, y + self.iy + self.c_tut.h - 32 + 10, 64, 64)
	end
end

function _M:generateList()
	-- Makes up the list
	local list = {}
	local letter = 1

--[[
	for i, tt in ipairs(self.actor.talents_types_def) do
		local cat = tt.type:gsub("/.*", "")
		local where = #list
		local added = false
		local nodes = {}

		-- Find all talents of this school
		for j, t in ipairs(tt.talents) do
			if self.actor:knowTalent(t.id) and t.mode ~= "passive" then
				local typename = "talent"
				local status = tstring{{"color", "LIGHT_GREEN"}, "Active"}
				if self.actor:isTalentCoolingDown(t) then status = tstring{{"color", "LIGHT_RED"}, self.actor:isTalentCoolingDown(t).." turns"}
				elseif t.mode == "sustained" then status = self.actor:isTalentActive(t.id) and tstring{{"color", "YELLOW"}, "Sustaining"} or tstring{{"color", "LIGHT_GREEN"}, "Sustain"} end
				nodes[#nodes+1] = {
					char=self:makeKeyChar(letter),
					name=t.name.." ("..typename..")",
					status=status,
					talent=t.id,
					desc=self.actor:getTalentFullDescription(t),
					color=function() return {0xFF, 0xFF, 0xFF} end,
					hotkey=function(item)
						for i = 1, 12 * self.actor.nb_hotkey_pages do if self.actor.hotkey[i] and self.actor.hotkey[i][1] == "talent" and self.actor.hotkey[i][2] == item.talent then
							return "H.Key "..i..""
						end end
						return ""
					end,
				}
				list.chars[self:makeKeyChar(letter)] = nodes[#nodes]
				added = true
				letter = letter + 1
			end
		end

		if added then
			table.insert(list, where+1, {
				char="",
				name=tstring{{"font","bold"}, cat:capitalize().." / "..tt.name:capitalize(), {"font","normal"}},
				type=tt.type,
				color=function() return {0x80, 0x80, 0x80} end,
				status="",
				desc=tt.description,
				nodes=nodes,
				hotkey="",
				shown=true,
			})
		end
	end
]]

	local actives, sustains, sustained, unavailables, cooldowns, passives = {}, {}, {}, {}, {}, {}
	local chars = {}

	-- Find all talents of this school
	for j, t in pairs(self.actor.talents_def) do
		if self.actor:knowTalent(t.id) and not (t.hide and t.mode == "passive") then
			local typename = "talent"
			local nodes = (t.mode == "sustained" and sustains) or (t.mode =="passive" and passives) or actives
			local status = tstring{{"color", "LIGHT_GREEN"}, "사용가능"}
			if self.actor:isTalentCoolingDown(t) then
				nodes = cooldowns
				status = tstring{{"color", "LIGHT_RED"}, self.actor:isTalentCoolingDown(t).." 턴"}
			elseif not self.actor:preUseTalent(t, true, true) then
				nodes = unavailables
				status = tstring{{"color", "GREY"}, "불가능"}
			elseif t.mode == "sustained" then
				if self.actor:isTalentActive(t.id) then nodes = sustained end
				status = self.actor:isTalentActive(t.id) and tstring{{"color", "YELLOW"}, "유지중"} or tstring{{"color", "LIGHT_GREEN"}, "유지가능"}
			elseif t.mode == "passive" then
				nodes = passives
				status = tstring{{"color", "LIGHT_BLUE"}, "지속"}
			end

			-- Pregenenerate icon with the Tiles instance that allows images
			if t.display_entity then t.display_entity:getMapObjects(game.uiset.hotkeys_display_icons.tiles, {}, 1) end

			nodes[#nodes+1] = {
				--@@
				name=((t.display_entity and t.display_entity:getDisplayString() or "")..(t.kr_display_name or t.name)):toTString(),
				cname = t.kr_display_name or t.name,
				oriname=t.name,
				
				status=status,
				entity=t.display_entity,
				talent=t.id,
				desc=self.actor:getTalentFullDescription(t),
				color=function() return {0xFF, 0xFF, 0xFF} end,
				hotkey=function(item)
					if t.mode == "passive" then return "" end
					for i = 1, 12 * self.actor.nb_hotkey_pages do if self.actor.hotkey[i] and self.actor.hotkey[i][1] == "talent" and self.actor.hotkey[i][2] == item.talent then
						return "단축 "..i..""
					end end
					return ""
				end,
			}
		end
	end
	table.sort(actives, function(a,b) return a.cname < b.cname end)
	table.sort(sustains, function(a,b) return a.cname < b.cname end)
	table.sort(sustained, function(a,b) return a.cname < b.cname end)
	table.sort(cooldowns, function(a,b) return a.cname < b.cname end)
	table.sort(unavailables, function(a,b) return a.cname < b.cname end)
	table.sort(passives, function(a,b) return a.cname < b.cname end)
	for i, node in ipairs(actives) do node.char = self:makeKeyChar(letter) chars[node.char] = node letter = letter + 1 end
	for i, node in ipairs(sustains) do node.char = self:makeKeyChar(letter) chars[node.char] = node letter = letter + 1 end
	for i, node in ipairs(sustained) do node.char = self:makeKeyChar(letter) chars[node.char] = node letter = letter + 1 end
	for i, node in ipairs(cooldowns) do node.char = self:makeKeyChar(letter) chars[node.char] = node letter = letter + 1 end
	for i, node in ipairs(unavailables) do node.char = self:makeKeyChar(letter) chars[node.char] = node letter = letter + 1 end
	for i, node in ipairs(passives) do node.char = "" end


	list = {
		{ char='', name=('#{bold}#사용가능 기술#{normal}#'):toTString(), status='', hotkey='', desc="모든 사용가능 기술은 현재 사용할 수 있습니다.", color=function() return colors.simple(colors.LIGHT_GREEN) end, nodes=actives, shown=true },
		{ char='', name=('#{bold}#유지가능 기술#{normal}#'):toTString(), status='', hotkey='', desc="모든 유지가능 기술은 현재 사용할 수 있습니다.", color=function() return colors.simple(colors.LIGHT_GREEN) end, nodes=sustains, shown=true },
		{ char='', name=('#{bold}#유지중 기술#{normal}#'):toTString(), status='', hotkey='', desc="모든 유지중 기술은 현재 유지상태로 사용중이고, 다시 사용하면 유지상태가 풀립니다.", color=function() return colors.simple(colors.YELLOW) end, nodes=sustained, shown=true },
		{ char='', name=('#{bold}#대기중 기술#{normal}#'):toTString(), status='', hotkey='', desc="기술을 사용하여 대기시간이 남아있는 기술입니다.", color=function() return colors.simple(colors.LIGHT_RED) end, nodes=cooldowns, shown=true },
		{ char='', name=('#{bold}#사용 불가능 기술#{normal}#'):toTString(), status='', hotkey='', desc="필요한 원천력이 부족하거나 다른 조건을 만족하지 못해 현재 사용이 불가능한 기술입니다.", color=function() return colors.simple(colors.GREY) end, nodes=unavailables, shown=true },
		{ char='', name=('#{bold}#지속형 기술#{normal}#'):toTString(), status='', hotkey='', desc="모든 지속형 기술은 항상 사용하고 있습니다.", color=function() return colors.simple(colors.WHITE) end, nodes=passives, shown=true },
		chars = chars,
	}
	self.list = list
end
