-- ToME - Tales of Maj'Eyal
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
local Dialog = require "engine.ui.Dialog"
local Tab = require "engine.ui.Tab"
local Mouse = require "engine.Mouse"
local Slider = require "engine.ui.Slider"

module(..., package.seeall, class.inherit(Dialog))

function _M:init(title, shadow, log, chat)
	local w = math.floor(game.w * 0.9)
	local h = math.floor(game.h * 0.9)
	Dialog.init(self, title, w, h)
	if shadow then self.shadow = shadow end

	self.log, self.chat = log, chat

	self.event_fct = function(e) self:onTalkEvent(e) end
	chat:registerTalkEvents(self.event_fct)

	local tabs = {}

	local order = {}
	local list = {}
	for name, data in pairs(chat.channels) do list[#list+1] = name end
	table.sort(list, function(a,b) if a == "global" then return 1 elseif b == "global" then return nil else return a < b end end)

	tabs[#tabs+1] = {top=0, left=0, ui = Tab.new{title="게임 기록", fct=function() end, on_change=function() local i = #tabs self:switchTo(tabs[1]) end, default=true}, tab_channel="__log", timestamp=log:getLogLast()}
	for i, name in ipairs(list) do
		local oname = name
		local nb_users = 0
		for _, _ in pairs(chat.channels[name].users) do nb_users = nb_users + 1 end
		name = name:capitalize().." ("..nb_users..")"

		local ii = i
		tabs[#tabs+1] = {top=0, left=(#tabs==0) and 0 or tabs[#tabs].ui, ui = Tab.new{title=name, fct=function() end, on_change=function() local i = ii+1 self:switchTo(tabs[i]) end, default=false}, tab_channel=oname, timestamp=chat:getLogLast(oname)}
	end

	self.start_y = tabs[1].ui.h + 5

	self:loadUI(tabs)
	self.tabs = tabs
	self:setupUI()

	self.scrollbar = Slider.new{size=self.h - 20, max=0}
	self.line_size = setmetatable({}, {__mode='k'})

	self:switchTo(self.last_tab or "__log")
end

function _M:unload()
	self.chat:unregisterTalkEvents(self.event_fct)
end

function _M:onTalkEvent(e)
	if not e.channel then return end
	if e.channel ~= self.last_tab then return end
	self:switchTo(self.last_tab)
end

function _M:generate()
	Dialog.generate(self)

	-- Add UI controls
	local tabs = self.tabs
	self.key:addBinds{
		MOVE_UP = function() self:setScroll(self.scroll - 1) end,
		MOVE_DOWN = function() self:setScroll(self.scroll + 1) end,
		ACCEPT = "EXIT",
		EXIT = function() game:unregisterDialog(self) end,
	}
	self.key:addCommands{
		_TAB = function() local sel = 1 for i=1, #tabs do if tabs[i].ui.selected then sel = i break end end self:switchTo(tabs[util.boundWrap(sel+1, 1, #tabs)]) end,
		_HOME = function() self:setScroll(0) end,
		_END = function() self:setScroll(self.scrollbar.max) end,
		_PAGEUP = function() self:setScroll(self.scroll - self.max_display) end,
		_PAGEDOWN = function() self:setScroll(self.scroll + self.max_display) end,
	}

	for i, tab in ipairs(tabs) do
		local tab = tab
		tab.ui.key:addBind("USERCHAT_TALK", function()
			local type, name = profile.chat:getCurrentTarget()
			if type == "channel" and self.last_tab ~= "__log" then profile.chat:setCurrentTarget(true, self.last_tab) end
			profile.chat:talkBox()
		end)
	end
end

function _M:mouseEvent(button, x, y, xrel, yrel, bx, by, event)
	Dialog.mouseEvent(self, button, x, y, xrel, yrel, bx, by, event)

	if button == "wheelup" and event == "button" then self.key:triggerVirtual("MOVE_UP")
	elseif button == "wheeldown" and event == "button" then self.key:triggerVirtual("MOVE_DOWN")
	else
		if not self.dlist then return end
		local citem, gitem = nil, nil
		for i = #self.dlist, 1, -1 do
			local item = self.dlist[i]
			if item.dh and by >= item.dh then citem = self.dlist[i].src gitem = self.dlist[i].d break end
		end

		if event == "motion" then
			local tooltip = nil
			if citem and citem.extra_data and citem.extra_data.mode == "tooltip" then
				tooltip = citem.extra_data.tooltip
				tooltip = tooltip:toTString()
			end

			if gitem then
				local sub_es = {}
				for e, _ in pairs(gitem.dduids) do sub_es[#sub_es+1] = e end
				if sub_es and #sub_es > 0 then
					if not tooltip then tooltip = tstring{} end
					for i, e in ipairs(sub_es) do
						if e.tooltip then
							tooltip:merge(e:tooltip())
							if e:getEntityKind() == "actor" then tooltip:add(true, "우클릭 : 생명체 조사", true) end
							if i < #sub_es then tooltip:add(true, "---", true)
							else tooltip:add(true) end
						end
					end
				end
			end

			if tooltip then
				game:tooltipDisplayAtMap(game.w, game.h, tooltip)
			else
				game.tooltip_x, game.tooltip_y = nil, nil
			end
		elseif event == "button" then
			if citem and citem.url and button == "left" then
				util.browserOpenUrl(citem.url, {is_external=true})
			end

			if gitem and button == "right" then
				local sub_es = {}
				for e, _ in pairs(gitem.dduids) do sub_es[#sub_es+1] = e end
				if sub_es and #sub_es > 0 then
					if not tooltip then tooltip = tstring{} end
					for i, e in ipairs(sub_es) do
						if e:getEntityKind() == "actor" then
							game:registerDialog(require("mod.dialogs.CharacterSheet").new(e))
						end
					end
				end
			end

			if citem and citem.login then
				local data = profile.chat:getUserInfo(citem.login)
				if data then
					local list = {
						{name="정보 보기", ui="show"},
						{name="귓속말", ui="whisper"},
						{name="무시하기", ui="ignore"},
						{name="프로파일 열기 (웹 브라우저로)", ui="profile"},
						{name="나쁜 행동 보고하기", ui="report"}
					}
					if data.char_link then table.insert(list, 3, {name="캐릭터 상태창 열기 (웹 브라우저로)", ui="charsheet"}) end
					Dialog:listPopup("사용자 : "..citem.login, "행동", list, 300, 200, function(sel)
						if not sel or not sel.ui then return end
						if sel.ui == "show" then
							local UserInfo = require "engine.dialogs.UserInfo"
							game:registerDialog(UserInfo.new(data))
						elseif sel.ui == "profile" then
							util.browserOpenUrl(data.profile, {is_external=true})
						elseif sel.ui == "charsheet" then
							util.browserOpenUrl(data.char_link, {is_external=true})
						elseif sel.ui == "whisper" then
							profile.chat:setCurrentTarget(false, citem.login)
							profile.chat:talkBox()
						elseif sel.ui == "ignore" then
							Dialog:yesnoPopup("사용자 무시하기", "다음 사용자로부터의 모든 메세지를 정말로 무시합니까? : "..citem.login, function(ret) if ret then profile.chat:ignoreUser(citem.login) end end, "예", "아니오")
						elseif sel.ui == "report" then
							game:registerDialog(require('engine.dialogs.GetText').new("보고서 작성 이유 : "..citem.login, "이유 (영어로 작성할 것)", 4, 500, function(text)
								profile.chat:reportUser(citem.login, text)
								game.log("#VIOLET#", "보고서를 제출했습니다.")
							end))							
						end
					end)
				end
			end
		end
	end
end

-- This might seem a little wierd all in all...
-- What's happening is, we assume all incoming lines are the one (line), until otherwise proven.
-- When otherwise proven in setScroll, we readjust.
function _M:loadLog(log, oldscroll)
	self.lines = {}
	self.max = 0
	for i = #log, 1, -1 do
		if type(log[i]) == "string" then
			self.lines[#self.lines+1] = {str=log[i]}
		else
			self.lines[#self.lines+1] = log[i]
		end
		self.max = self.max + (self.line_size[self.lines[#self.lines].str] or 1)
	end

	self.max_h = self.ih - self.iy
	self.max_display = math.floor(self.max_h / self.font_h)

	self.scrollbar.max = math.max(0, self.max - self.max_display)
	self.scroll = nil
	self:setScroll(oldscroll or self.scrollbar.max, not oldscroll)
end

function _M:switchTo(ui)
	if type(ui) == "string" then for i, tab in ipairs(self.tabs) do if tab.tab_channel == ui then ui = tab end end end
	if type(ui) == "string" then ui = self.tabs[1] end

	for i, ui in ipairs(self.tabs) do ui.ui.selected = false end
	ui.ui.selected = true
	if ui.tab_channel == "__log" then
		self:loadLog(self.log:getLog(true))
	else
		local s = nil
		if _M.last_tab == ui.tab_channel and self.max and self.max_display and self.scroll < self.scrollbar.max then
			s = self.scroll
		end
		self:loadLog(self.chat:getLog(ui.tab_channel, true), s)
	end
	-- Set it on the class to persist between invocations
	_M.last_tab = ui.tab_channel
end

function _M:setScroll(i, do_shifty_thing)
	local old = self.scroll
	self.scroll = util.bound(i, 0, self.scrollbar.max)

	if self.scroll == old then return end
	self.dlist = {}
	local cur = 0
	local shift = 0
	for i = 1, #self.lines do
		local str = self.lines[i].str
		local size = self.line_size[str] or 1
		if cur + size > self.scroll then
			local gen = self.font:draw(str, self.iw - 10, 255, 255, 255, false, true)
			if size ~= #gen then
				self.line_size[str] = #gen
				shift = shift + #gen - size
				if do_shifty_thing then
					-- drop lines!
					local delta = #gen - size
					if delta > 0 then
						for i = 1, #self.dlist do self.dlist[i] = self.dlist[i + delta] end -- this fills the end with nils, too
					end
				end
				size = #gen
			end
			local stop
			for _, tex in pairs(gen) do
				if cur >= self.scroll then
					local dtex = {t=tex._tex, w=tex.w, h=tex.h, tw = tex._tex_w, th = tex._tex_h, dduids = tex._dduids}
					self.dlist[#self.dlist+1] = {d=dtex, src=self.lines[i].src}
					if #self.dlist > self.max_display then stop=true break end
				end
				cur = cur + 1
			end
			if stop then break end
		else
			cur = cur + size
		end
	end
	self.max = self.max + shift
	if do_shifty_thing then self.scroll = self.scroll + shift end
	self.scrollbar.max = math.max(0, self.max - self.max_display)
end

function _M:innerDisplay(x, y, nb_keyframes, tx, ty)
	local h = y + self.iy + self.start_y
	for i = 1, #self.dlist do
		local item = self.dlist[i].d
		if self.shadow then self:textureToScreen(item, x+2, h+2, 0, 0, 0, self.shadow, false) end
		self:textureToScreen(item, x, h, 1, 1, 1, 1, true)

		self.dlist[i].dh = h - y
--		print("<<",i,"::",h + ty)
		h = h + self.font_h
	end

	self.scrollbar.pos = self.scroll
	self.scrollbar:display(x + self.iw - self.scrollbar.w, y)
end
