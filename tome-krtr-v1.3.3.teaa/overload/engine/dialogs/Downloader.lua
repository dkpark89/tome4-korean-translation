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

require "engine.class"
local Base = require "engine.ui.Base"
local Focusable = require "engine.ui.Focusable"

--- A web browser
module(..., package.seeall, class.inherit(Base, Focusable))

function _M:init(t)
	self.w = 50
	self.h = 50
	self.title = t.title
	self.co = assert(t.co, "no downloader coroutine")
	self.url = assert(t.url, "no downloader url")
	self.dest = assert(t.dest, "no downloader dest")

	if fs.exists(self.dest) then
		self.dest = fs.getRealPath(self.dest)
	else
		local _, _, dir, name = self.dest:find("(.+)/([^/]+)$")
		if dir then
			self.dest = fs.getRealPath(dir)..fs.getPathSeparator()..name
		end
	end

	print("[DOWNLOADER] downloading", self.url, "to", self.dest)

	self.allow_downloads = t.allow_downloads or {}
	self.allow_login = t.allow_login
	self.custom_calls = t.custom_calls or {}
	if self.allow_login == nil then self.allow_login = true end

	if self.allow_login and self.url:find("^http://te4%.org/") and profile.auth then
		local param = "_te4ah="..profile.auth.hash.."&_te4ad="..profile.auth.drupid

		local first = self.url:find("?", 1, 1)
		if first then self.url = self.url.."&"..param
		else self.url = self.url.."?"..param end
	end

	if self.url:find("^http://te4%.org/")  then
		local param = "_te4"

		local first = self.url:find("?", 1, 1)
		if first then self.url = self.url.."&"..param
		else self.url = self.url.."?"..param end
	end

	print("Creating Downloader with url", self.url)

	Base.init(self, t)
end

function _M:generate()
	self.mouse:reset()
	self.key:reset()

	local handlers = {
		on_crash = function()
			print("WebView crashed, closing C view")
			self.view = nil
		end,
	}
	if self.allow_downloads then self:onDownload(handlers) end
	self.view = core.webview.new(self.w, self.h, handlers)
	if not self.view:usable() then
		self.unusable = true
		return
	end

	self.custom_calls._nextDownloadName = function(name)
		if name then self._next_download_name = {name=name, time=os.time()}
		else self._next_download_name = nil
		end
	end

	for name, fct in pairs(self.custom_calls) do 
		handlers[name] = fct
		self.view:setMethod(name)
	end
	self.view:loadURL(self.url)
	self.loading = 0
	self.loading_rotation = 0
	self.scroll_inertia = 0
end

function _M:makeDownloadbox(downid, file)
	local Dialog = require "engine.ui.Dialog"
	local Waitbar = require "engine.ui.Waitbar"
	local Button = require "engine.ui.Button"

	local d = Dialog.new(self.title or "Download: "..file, 600, 100)
	local b = Button.new{text="Cancel", fct=function() self.view:downloadAction(downid, false) game:unregisterDialog(d) end}
	local w = Waitbar.new{size=600, text=file}
	d:loadUI{
		{left=0, top=0, ui=w},
		{right=0, bottom=0, ui=b},
	}
	d:setupUI(true, true)
	function d:updateFill(...) w:updateFill(...) end
	return d
end

function _M:finish()
	if not self.never_clean then
		self.downloader = nil
		self.view = nil
	end
end

function _M:onDownload(handlers)
	local Dialog = require "engine.ui.Dialog"

	handlers.on_download_request = function(downid, url, file, mime)
		if mime == "application/t-engine-addon" and self.allow_downloads.addons and url:find("^http://te4%.org/") then
			local name = file
			if self._next_download_name and os.time() - self._next_download_name.time <= 3 then name = self._next_download_name.name self._next_download_name = nil end
			print("Accepting addon download to:", self.dest)
			self.download_dialog = self:makeDownloadbox(downid, file)
			self.download_dialog.install_kind = "Addon"
			game:registerDialog(self.download_dialog)
			self.view:downloadAction(downid, self.dest)
			return
		elseif mime == "application/t-engine-module" and self.allow_downloads.modules and url:find("^http://te4%.org/") then
			local name = file
			if self._next_download_name and os.time() - self._next_download_name.time <= 3 then name = self._next_download_name.name self._next_download_name = nil end
			print("Accepting module download to:", self.dest)
			self.download_dialog = self:makeDownloadbox(downid, file)
			self.download_dialog.install_kind = "Game Module"
			game:registerDialog(self.download_dialog)
			self.view:downloadAction(downid, self.dest)
			return
		end
		self.view:downloadAction(downid, false)
	end

	handlers.on_download_update = function(downid, cur_size, total_size, percent, speed)
		if not self.download_dialog then return end
		self.download_dialog:updateFill(cur_size, total_size, ("%d%% - %d KB/s"):format(cur_size * 100 / total_size, speed / 1024))
	end

	handlers.on_download_finish = function(downid)
		if not self.download_dialog then return end
		game:unregisterDialog(self.download_dialog)
		local kind = self.download_dialog.install_kind
		self.download_dialog = nil
		self:finish()
		coroutine.resume(self.co, true, kind)
	end
end

function _M:start()
	return coroutine.yield()
end