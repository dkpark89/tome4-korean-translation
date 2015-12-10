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

require "engine.krtrUtils"
require "engine.class"
local Dialog = require "engine.ui.Dialog"
local ListColumns = require "engine.ui.ListColumns"
local Textzone = require "engine.ui.Textzone"
local TextzoneList = require "engine.ui.TextzoneList"
local Separator = require "engine.ui.Separator"
local GetQuantity = require "engine.dialogs.GetQuantity"

module(..., package.seeall, class.inherit(Dialog))

function _M:init(actor, def)
	self.actor = actor
	self.def = def
	Dialog.init(self, "전략적 기술 사용 정의", math.max(800, game.w * 0.8), math.max(600, game.h * 0.8))
	local vsep = Separator.new{dir="horizontal", size=self.ih - 10}
	local halfwidth = math.floor((self.iw - vsep.w)/2)
	self.c_tut = Textzone.new{width=halfwidth, height=1, auto_height=true, no_color_bleed=true, text=([[
%s 무슨 기술을 사용해도 괜찮은지를 알기 위해 주인의 말을 주의깊게 경청하고 있습니다.
당신은 여러 기술들의 중요도를 조정하여, 특정 기술을 더 자주 사용하거나 혹은 덜 사용하도록 만들 수 있습니다. 중요도는 상대적으로 적용됩니다. (중요도가 0 일 경우 해당 기술을 사용하지 않으며, 모든 기술의 중요도가 2 일 경우 중요도를 바꾸지 않은 것과 똑같습니다)
마즈'에이알에서는 소환수들 사이에 말이 매우 빨리 전달되어서, %s 소환수라면 앞으로 소환되는 같은 종류의 모든 소환수에게 이 기준이 적용됩니다.
]]):format((actor.kr_name or actor.name):capitalize():addJosa("는"), (actor.kr_name or actor.name):addJosa("가"))}
	self.c_desc = TextzoneList.new{width=halfwidth, height=self.ih, no_color_bleed=true}

	self.c_list = ListColumns.new{width=halfwidth, height=self.ih - 10, sortable=true, scrollbar=true, columns={
		{name="", width={20,"fixed"}, display_prop="char", sort="id"},
		{name="기술 이름", width=72, display_prop="kr_name", sort="kr_name"}, --@ 원문이름 name대신 한글이름 kr_name 사용하도록 수정
		{name="중요도", width=20, display_prop="multiplier", sort="multiplier"},
	}, list={}, fct=function(item) self:use(item) end, select=function(item, sel) self:select(item) end}

	self:generateList()

	self:loadUI{
		{left=0, top=0, ui=self.c_list},
		{right=0, top=self.c_tut.h + 20, ui=self.c_desc},
		{right=0, top=0, ui=self.c_tut},
		{hcenter=0, top=5, ui=vsep},
	}
	self:setFocus(self.c_list)
	self:setupUI()

	self.key:addCommands{
		__TEXTINPUT = function(c)
			if self.list and self.list.chars[c] then
				self:use(self.list[self.list.chars[c]])
			end
		end,
	}
	self.key:addBinds{
		EXIT = function()
			-- Store the ai_talents in the summoner
			if self.actor.summoner then
				self.actor.summoner.stored_ai_talents = self.actor.summoner.stored_ai_talents or {}
				self.actor.summoner.stored_ai_talents[self.actor.name] = self.actor.ai_talents
			end
			game:unregisterDialog(self)
		end,
	}
end

function _M:on_register()
	game:onTickEnd(function() self.key:unicodeInput(true) end)
end

function _M:use(item)
	if not item then return end

	-- Update the multiplier
	if not self.actor.ai_talents then
		self.actor.ai_talents = {}
	end
	game:registerDialog(GetQuantity.new("기술의 중요도를 입력하세요", "중요도가 0 일 경우 해당 기술을 사용하지 않습니다", item.multiplier, nil, function(qty)
			self.actor.ai_talents[item.tid] = qty
			self:generateList()
	end), 1)
end

function _M:select(item)
	if item then
		self.c_desc:switchItem(item, item.desc)
	end
end

function _M:generateList()
	local list = {}
	for tid, lvl in pairs(self.actor.talents) do
		local t = self.actor:getTalentFromId(tid)
		if t.mode ~= "passive" and t.hide ~= "true" then
			local multiplier = self.actor.ai_talents and self.actor.ai_talents[tid] or 1
			local tn = t.kr_name or t.name --@ 다음줄 사용 : 한글 이름 저장
			list[#list+1] = {id=#list+1, kr_name=tn:capitalize(), name=t.name:capitalize(), multiplier=multiplier, tid=tid, desc=self.actor:getTalentFullDescription(t)} --@ kr_name 추가하고 한글이름 저장
		end
	end

	local chars = {}
	for i, v in ipairs(list) do
		v.char = self:makeKeyChar(i)
		chars[self:makeKeyChar(i)] = i
	end
	list.chars = chars

	self.list = list
	self.c_list:setList(list)
end
