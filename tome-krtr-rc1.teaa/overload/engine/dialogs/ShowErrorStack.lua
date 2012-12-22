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

require "engine.class"
local Dialog = require "engine.ui.Dialog"
local Button = require "engine.ui.Button"
local Textzone = require "engine.ui.Textzone"
local Textbox = require "engine.ui.Textbox"

module(..., package.seeall, class.inherit(Dialog))

function _M:init(errs)
	errs = table.concat(errs, "\n")
	self.errs = errs
	Dialog.init(self, "루아 오류", 700, 500)

	local md5 = require "md5"
	local errmd5 = md5.sumhexa(errs)
	self.errmd5 = errmd5

	fs.mkdir("/error-reports")
	local errdir = "/error-reports/"..game.__mod_info.short_name.."-"..game.__mod_info.version_name
	self.errdir = errdir
	fs.mkdir(errdir)
	local infos = {}
	local f, err = loadfile(errdir.."/"..errmd5)
	if f then
		setfenv(f, infos)
		if pcall(f) then infos.loaded = true end
	end

	local reason = "이미 오류 보고서를 보냈다면, (그리고 같은 상황이라 생각된다면) 또 보낼 필요는 없습니다."
	if infos.loaded then
		if infos.reported then reason = "#LIGHT_GREEN#보고한 적 있는#WHITE# 오류네요, (같은 상황이라 생각된다면) 또 보낼 필요는 없습니다."
		else reason = "이 오류를 경험한 적은 있지만 #LIGHT_RED#보고된 적은 없는#WHITE# 오류네요, 보고서를 보내주시기 바랍니다."
		end
	else reason = "#LIGHT_RED#처음 보는#WHITE# 오류네요, 보고서를 보내주시기 바랍니다."
	end

	self:saveError(true, infos.reported)

	local errmsg = Textzone.new{text=[[#{bold}#이런! 여기에 오류가 있는것 같습니다!
게임은 여전히 동작하지만 이 상황은 오류로 의심되므로, 현재 상황을 (영어로) 입력해주신다음 "보내기"로 오류 보고서를 제작자에게 보내주십시오.
(한글화하면서 발생한 문제일수도 있으니, 가능하면 한글화 애드온을 비활성화한 뒤 다시 테스트해 주십시오. 한글화시 발생한 오류는 제작자에게 보내지 말고 한글화팀에게 연락해주세요.)
현재 인터넷에 연결이 안 되는 상황이라면, 오류 보고서를 공식 웹 포럼( http://forums.te4.org/ )에 작성해 주십시오.
(한글화시 발생한 문제는 한글화팀이 있는 게시판( http://nethack.byus.net )에 올려주십시오.)

]]..reason..[[#{normal}#]], width=690, auto_height=true}
	local errzone = Textzone.new{text=errs, width=690, height=400}
	self.what = Textbox.new{title="무슨 일이지?: ", text="", chars=60, max_len=1000, fct=function(text) self:send() end}
	local ok = require("engine.ui.Button").new{text="보내기", fct=function() self:send() end}
	local cancel = require("engine.ui.Button").new{text="닫기", fct=function() game:unregisterDialog(self) end}
	local cancel_all = require("engine.ui.Button").new{text="모두 닫기", fct=function()
		for i = #game.dialogs, 1, -1 do
			local d = game.dialogs[i]
			if d.__CLASSNAME == "engine.dialogs.ShowErrorStack" then
				game:unregisterDialog(d)
			end
		end
	end}

	local many_errs = false
	for i = #game.dialogs, 1, -1 do local d = game.dialogs[i] if d.__CLASSNAME == "engine.dialogs.ShowErrorStack" then many_errs = true break end end

	local uis = {
		{left=0, top=0, padding_h=10, ui=errmsg},
		{left=0, top=errmsg.h + 10, padding_h=10, ui=errzone},
		{left=0, bottom=ok.h, ui=self.what},
		{left=0, bottom=0, ui=ok},
		{right=0, bottom=0, ui=cancel},
	}
	if many_errs then
		table.insert(uis, #uis, {right=cancel.w, bottom=0, ui=cancel_all})
	end
	self:loadUI(uis)
	self:setFocus(self.what)
	self:setupUI(false, true)

	self.key:addBinds{
		EXIT = function() game:unregisterDialog(self) end,
	}
end

function _M:saveError(seen, reported)
	local f = fs.open(self.errdir.."/"..self.errmd5, "w")
	f:write(("error = %q\n"):format(self.errs))
	f:write(("seen = %s\n"):format(seen and "true" or "false"))
	f:write(("reported = %s\n"):format(reported and "true" or "false"))
	f:close()
end

function _M:send()
	game:unregisterDialog(self)
	profile:sendError(self.what.text, self.errs)
	game.log("#YELLOW#오류 보고서를 보냈습니다, 고맙습니다.")
	self:saveError(true, true)
end
