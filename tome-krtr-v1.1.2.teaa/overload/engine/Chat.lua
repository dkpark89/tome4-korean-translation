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

require "engine.krtrUtils"
require "engine.class"
require "engine.dialogs.Chat"

--- Handle chats between the player and NPCs
module(..., package.seeall, class.make)

function _M:init(name, npc, player, data)
	self.quick_replies = 0
	self.chats = {}
	self.npc = npc
	self.player = player
	self.name = name
	data = setmetatable(data or {}, {__index=_G})

	local f, err = loadfile("/data/chats/"..name..".lua")
	if not f and err then error(err) end
	setfenv(f, setmetatable({
		newChat = function(c) self:addChat(c) end,
	}, {__index=data}))
	self.default_id = f()

	self:triggerHook{"Chat:load", data=data}
end

--- Switch the NPC talking
function _M:switchNPC(npc)
	local old = self.npc
	self.npc = npc
	return old
end

--- Adds a chat to the list of possible chats
function _M:addChat(c)
	self:triggerHook{"Chat:add", c=c}

	assert(c.id, "no chat id")
	assert(c.text, "no chat text")
	assert(c.answers, "no chat answers")
	self.chats[c.id] = c
	print("[CHAT] loaded", c.id, c)

	-- Parse answers looking for quick replies
	for i, a in ipairs(c.answers) do
		if a.quick_reply then
			a.jump = "quick_reply"..self.quick_replies
			self:addChat{id="quick_reply"..self.quick_replies, text=a.quick_reply, answers={{"[떠난다]"}}}
			self.quick_replies = self.quick_replies + 1
		end
	end
end

--- Invokes a chat
-- @param id the id of the first chat to run, if nil it will use the default one
function _M:invoke(id)
	if self.npc.onChat then self.npc:onChat() end
	if self.player.onChat then self.player:onChat() end

	local d = engine.dialogs.Chat.new(self, id or self.default_id)
	game:registerDialog(d)
	return d
end

--- Gets the chat with the given id
function _M:get(id)
	return self.chats[id]
end

--- Replace some keywords in the given text
function _M:replace(text)
	local pn = (self.player.kr_name or self.player.name) --@ 두줄뒤 반복 사용, 플레이어 이름
	local nn = (self.npc.kr_name or self.npc.name) --@ 다음줄 반복 사용, npc이름
	text = text:gsub("@playername@", pn):gsub("@playername1@", pn:addJosa("가")):gsub("@playername2@", pn:addJosa("는")):gsub("@playername3@", pn:addJosa("를")):gsub("@playername4@", pn:addJosa("로")):gsub("@playername5@", pn:addJosa("다")):gsub("@playername6@", pn:addJosa("과")):gsub("@playername7@", pn:addJosa(7)):gsub("@npcname@", nn):gsub("@npcname1@", nn:addJosa("가")):gsub("@npcname2@", nn:addJosa("는")):gsub("@npcname3@", nn:addJosa("를")):gsub("@npcname4@", nn:addJosa("로")):gsub("@npcname5@", nn:addJosa("다")):gsub("@npcname6@", nn:addJosa("과")):gsub("@npcname7@", nn:addJosa(7)) --@ 한글이름, 조사 삽입
	text = text:gsub("@playerdescriptor1.(.-)@", function(what) return (self.player.descriptor["fake_"..what] or self.player.descriptor[what]):krActorType():addJosa("가") end) --@ 한글이름으로 변환, 조사 추가
	text = text:gsub("@playerdescriptor2.(.-)@", function(what) return (self.player.descriptor["fake_"..what] or self.player.descriptor[what]):krActorType():addJosa("는") end) --@ 한글이름으로 변환, 조사 추가
	text = text:gsub("@playerdescriptor3.(.-)@", function(what) return (self.player.descriptor["fake_"..what] or self.player.descriptor[what]):krActorType():addJosa("를") end) --@ 한글이름으로 변환, 조사 추가
	text = text:gsub("@playerdescriptor4.(.-)@", function(what) return (self.player.descriptor["fake_"..what] or self.player.descriptor[what]):krActorType():addJosa("로") end) --@ 한글이름으로 변환, 조사 추가
	text = text:gsub("@playerdescriptor5.(.-)@", function(what) return (self.player.descriptor["fake_"..what] or self.player.descriptor[what]):krActorType():addJosa("다") end) --@ 한글이름으로 변환, 조사 추가
	text = text:gsub("@playerdescriptor6.(.-)@", function(what) return (self.player.descriptor["fake_"..what] or self.player.descriptor[what]):krActorType():addJosa("과") end) --@ 한글이름으로 변환, 조사 추가
	text = text:gsub("@playerdescriptor7.(.-)@", function(what) return (self.player.descriptor["fake_"..what] or self.player.descriptor[what]):krActorType():addJosa(7) end) --@ 한글이름으로 변환, 조사 추가
	text = text:gsub("@playerdescriptor.(.-)@", function(what) return (self.player.descriptor["fake_"..what] or self.player.descriptor[what]):krActorType() end) --@ 한글이름으로 변환, 1~7보다 뒤에 있어야 오류 발생하지 않음
	return text
end
