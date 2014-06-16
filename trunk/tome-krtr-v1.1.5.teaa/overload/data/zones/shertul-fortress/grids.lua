﻿-- ToME - Tales of Maj'Eyal
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

load("/data/general/grids/basic.lua")
load("/data/general/grids/fortress.lua")

local energycount = function(self)
	if not self._mo then return end
	local tex, nblines, wline = nil
	local lastenergy = nil
	local shader = require("engine.Shader").default.textoutline and require("engine.Shader").default.textoutline.shad
	local font = core.display.newFont(krFont or "/data/font/DroidSansMono.ttf", 16) --@ 한글 글꼴 추가
	local UIBase = require "engine.ui.Base"
	local MyUI = require("engine.class").inherit(UIBase){}
	MyUI.ui = "metal"
	local frame = MyUI:makeFrame("ui/tooltip/", 50, 50)
	self._mo:displayCallback(function(x, y, w, h)
		local q = game.player:hasQuest("shertul-fortress")
		if not q then return end
		if not q:isCompleted("chat-energy") and q.shertul_energy <= 0 then return end
		if not tex or lastenergy ~= q.shertul_energy then 
			lastenergy = q.shertul_energy
			local text = ("에너지가 %0.2f 만큼 저장되었습니다"):format(q.shertul_energy)
			tex, nblines, wline = font:draw(text, text:toTString():maxWidth(font), 0, 255, 128)
		end

		y = y - tex[1].h * nblines
		x = x - (wline - w) / 2
		frame.w = wline + 16 frame.h = tex[1].h * nblines + 16
		MyUI:drawFrame(frame, x - 4, y - 4, 0, 0, 0, 0.3)
		MyUI:drawFrame(frame, x - 8, y - 8, 1, 1, 1, 0.6)
		for i = 1, #tex do
			local item = tex[i]
			if shader then
				shader:use(true)
				shader:uniOutlineSize(2, 2)
				shader:uniTextSize(item._tex_w, item._tex_h)
			else
				item._tex:toScreenFull(x+2, y+2, item.w, item.h, item._tex_w, item._tex_h, 0, 0, 0, 0.7)
			end
			item._tex:toScreenFull(x, y, item.w, item.h, item._tex_w, item._tex_h)
			if shader then shader:use(false) end
			y = y + item.h
		end
		return true
	end)
end

newEntity{ base = "UP",
	define_as = "LAKE_NUR",
	name = "stair back to the lake of Nur",
	kr_name = "누르 호수로 연결된 계단",
	display = '<', color_r=255, color_g=255, color_b=0,
	change_level = 3, change_zone = "lake-nur", force_down = true,
}

newEntity{
	define_as = "TELEPORT_OUT",
	name = "teleportation circle to the surface", image = "terrain/solidwall/solid_floor1.png", add_displays = {class.new{image="terrain/maze_teleport.png"}},
	kr_name = "지표면으로의 순간이동 장치",
	display = '>', color_r=255, color_g=0, color_b=255,
	notice = true, show_tooltip = true,
	change_level = 1, change_zone = "wilderness",
}

newEntity{
	define_as = "TELEPORT_OUT_MELINDA",
	name = "teleportation circle for Melinda", image = "terrain/solidwall/solid_floor1.png", add_displays = {class.new{image="terrain/maze_teleport.png"}},
	kr_name = "멜린다용 순간이동 장치",
	display = '>', color_r=255, color_g=0, color_b=255,
	notice = true, show_tooltip = true,
}

newEntity{
	define_as = "COMMAND_ORB",
	name = "Sher'Tul Control Orb", image = "terrain/solidwall/solid_floor1.png",
	kr_name = "쉐르'툴 제어 오브",
	add_displays = {class.new{image="terrain/shertul_control_orb_blue.png",
		defineDisplayCallback = energycount,
		z = 17,
	}},
	display = '*', color=colors.PURPLE,
	notice = true,
	always_remember = true,
	block_move = function(self, x, y, e, act, couldpass)
		if e and e.player and act then
			local chat = require("engine.Chat").new("shertul-fortress-command-orb", self, e, {player=e})
			chat:invoke()
		end
		return true
	end,
}

newEntity{
	define_as = "FARPORTAL",
	name = "Exploratory Farportal",
	kr_name = "탐험용 장거리 관문",
	display = '&', color_r=255, color_g=0, color_b=220, back_color=colors.VIOLET, image = "terrain/solidwall/solid_floor1.png",
	notice = true,
	always_remember = true,
	show_tooltip = true,
	desc = [[놀라운 거리를 눈 깜짝할 사이에 이동할 수 있는 장거리 관문으로, 강력한 쉐르'툴 종족이 남긴 것입니다.
이 장거리 관문은 다른 관문과 연결되어 있지 않습니다. 이 관문은 탐험을 위해 만들어진 것이며, 어디로 보내질 것인지 알 수 없습니다.
자동적으로 돌아오는 관문이 만들어지지만, 그 위치는 도착 지점에서 가까운 곳이 아닐 수도 있습니다.]],
	

	checkSpecialLocation = function(self, who, q)
		-- Caldizar space fortress
		if rng.percent(5) and not game.state:hasSeenSpecialFarportal("caldizar-space-fortress") then
			game:changeLevel(1, "shertul-fortress-caldizar", {direct_switch=true})
			q:exploratory_energy()
			game.log("#VIOLET#당신은 소용돌이 치는 관문으로 들어섰고, 눈 깜짝할 사이에 자신이 익숙한 장소의 장거리 관문 옆으로 이동했다는 것을 깨달았습니다. 분명 처음 보는 곳인데...")
			game.state:seenSpecialFarportal("caldizar-space-fortress")
			return true
		end
	end,

	on_move = function(self, x, y, who)
		if not who.player then return end
		local Dialog = require "engine.ui.Dialog"
		local q = who:hasQuest("shertul-fortress")
		if not q then Dialog:simplePopup("탐험용 장거리 관문", "이 장거리 관문은 비활성화 상태인 것 같습니다.") return end
		if not q:exploratory_energy(true) then Dialog:simplePopup("탐험용 장거리 관문", "요새의 에너지가 관문을 통해 여행할 수 있을만큼 충분하지 않습니다.") return end
		if q:isCompleted("farportal-broken") then Dialog:simplePopup("탐험용 장거리 관문", "장거리 관문이 부서져 있어, 더이상 사용할 수 없습니다.") return end

		Dialog:yesnoPopup("탐험용 장거리 관문", "장거리 관문을 통해 탐험하기를 원합니까? 어디에 도착할지 알 수 없습니다.", function(ret) if ret then
			if self:checkSpecialLocation(who, q) then return end

			local zone, boss = game.state:createRandomZone()
			zone.no_worldport = true
			zone.force_farportal_recall = true
			zone.generator.actor.abord_no_guardian = true
			zone.objects_cost_modifier = 0.1
			zone.make_back_portal = function(self)
				local p = game:getPlayer(true)
				local x, y = p.x, p.y
				local g = game.zone:makeEntityByName(game.level, "terrain", game.zone.basic_floor)
				if g.change_level then return end
				g = g:clone()
				g:removeAllMOs(true)
				g.nice_tiler = nil
				g.show_tooltip = true
				g.name = "Exploratory Farportal exit"
				g.kr_name = "탐험용 장거리 관문 출구"
				g.display = '&' g.color_r = colors.VIOLET.r g.color_g = colors.VIOLET.g g.color_b = colors.VIOLET.b
				g.add_displays = g.add_displays or {}
				g.add_displays[#g.add_displays+1] = mod.class.Grid.new{image="terrain/maze_teleport.png"}
				g.notice = true
				g.change_level = 1 g.change_zone = "shertul-fortress"
				game.zone:addEntity(game.level, g, "terrain", x, y)
				if self then game.logSeen(self, "#VIOLET#%s 떨어지면서, 근처에 관문이 나타나는 것을 발견했습니다.", (self.kr_name or self.name):addJosa("가"))
				else game.logSeen(p, "#VIOLET#되돌림의 장대가 진동하자, 관문이 당신 밑에 나타났습니다.") end
			end
			zone.on_turn = function(zone)
				if game.turn % 1000 == 0 and game.level.level == zone.max_level then
					for uid, e in pairs(game.level.entities) do
						if e.define_as == zone.generator.actor.guardian and not e.dead then return end
					end
					-- Not found!
					zone.make_back_portal()
				end
			end

			boss.explo_portal_on_die = boss.on_die
			boss.on_die = function(self, ...)
				game.zone.make_back_portal(self)

				self:check("explo_portal_on_die", ...)
				self.on_die = self.explo_portal_on_die
				self.explo_portal_on_die = nil
			end
			game:changeLevel(1, zone, {direct_switch=true})
			q:exploratory_energy()
			game.log("#VIOLET#당신은 소용돌이 치는 관문으로 들어섰고, 눈 깜짝할 사이에 자신이 관문의 흔적이 없는, 익숙하지 않은 장소로 이동했다는 것을 깨달았습니다...")
		end end, "예", "아니오")
	end,
}

newEntity{ base = "FARPORTAL", define_as = "CFARPORTAL",
	image = "terrain/solidwall/solid_floor1.png",
	add_displays = {
		class.new{image="terrain/farportal-base.png", display_x=-1, display_y=-1, display_w=3, display_h=3},
	},
	on_added = function(self, level, x, y)
		if core.shader.active(4) then
			level.map:particleEmitter(x, y, 3, "shader_shield", {size_factor=4}, {type="shield", shieldIntensity=0.1, ellipsoidalFactor=1, time_factor=8000, color={0.3, 0.4, 0.7}})
		end
		level.map:particleEmitter(x, y, 3, "farportal_lightning")
		level.map:particleEmitter(x, y, 3, "farportal_lightning")
		level.map:particleEmitter(x, y, 3, "farportal_lightning")
		level.map:particleEmitter(x, y, 3, "farportal_vortex")
	end,
}

newEntity{
	define_as = "LIBRARY",
	name = "Library of Lost Mysteries", image = "terrain/solidwall/solid_floor1.png", add_displays = {class.new{image="terrain/temporal_instability_blue.png"}},
	kr_name = "잊혀진 신비의 도서관",
	display = '*', color=colors.BLUE,
	notice = true,
	always_remember = true,
	block_move = function(self, x, y, e, act, couldpass)
		if e and e.player and act then
			local nb = 0
			if profile.mod.lore then for lore, _ in pairs(profile.mod.lore.lore) do nb = nb + 1 end end

			local popup = require("engine.ui.Dialog"):simpleWaiter("이일크구르의 잊혀진 신비의 도서관", "우주의 잊혀진 지식들을 받습니다...", nil, nil, nb)
			core.wait.enableManualTick(true)
			core.display.forceRedraw()

			profile:setConfigsBatch(true)
			if profile.mod.lore and profile.mod.lore.lore then
				for lore, _ in pairs(profile.mod.lore.lore) do
					game.party:learnLore(lore, true, true)
					core.wait.manualTick(1)
				end
			end
			profile:setConfigsBatch(false)

			popup:done()

			game:registerDialog(require("mod.dialogs.ShowLore").new("이일크구르의 잊혀진 신비의 도서관", game.party))
		end
		return true
	end,
}

for i = 1, 9 do
newEntity{ define_as = "MURAL_PAINTING"..i,
	type = "wall", subtype = "floor",
	name="mural painting", lore = "shertul-fortress-"..i,
	kr_name = "벽화",
	display='#', color=colors.LIGHT_RED,
	image="terrain/solidwall/solid_wall_mural_shertul"..i..".png",
	block_move=function(self, x, y, e, act, couldpass) if e and e.player and act then game.party:learnLore(self.lore) end return true end
}
end

newEntity{
	define_as = "TRAINING_ORB",
	name = "Training Control Orb", image = "terrain/solidwall/solid_floor1.png", add_displays = {class.new{image="terrain/pedestal_orb_02.png", display_h=2, display_y=-1}},
	kr_name = "연습 통제 오브",
	display = '*', color=colors.PURPLE,
	notice = true,
	always_remember = true,
	block_move = function(self, x, y, e, act, couldpass)
		if e and e.player and act then
			local chat = require("engine.Chat").new("shertul-fortress-training-orb", self, e, {player=e})
			chat:invoke()
		end
		return true
	end,
}

local dcb = function(self)
	if not self._mo then return end
	local tex, nblines, wline = nil
	local DamageType = require "engine.DamageType"
	local shader = require("engine.Shader").default.textoutline and require("engine.Shader").default.textoutline.shad
	local font = core.display.newFont(krFont or "/data/font/DroidSansMono.ttf", 16) --@ 한글 글꼴 추가
	local UIBase = require "engine.ui.Base"
	local MyUI = require("engine.class").inherit(UIBase){}
	MyUI.ui = "metal"
	local frame = MyUI:makeFrame("ui/tooltip/", 50, 50)
	self._mo:displayCallback(function(x, y, w, h)
		if not game.zone.training_dummies or not game.zone.training_dummies.start_turn then return end
		local data = game.zone.training_dummies
		if not tex or data.changed or data.damtypes.changed or data.last_turn ~= game.turn then 
			data.last_turn = game.turn
			local turns = (game.turn - data.start_turn) / 10
			local text
			if self.monitor_mode == "global" then
				text = ("턴 : %d\n총 피해량 : %d\n턴당 피해량 : %d"):format(turns, data.total, data.total / turns)
				data.changed = false
			else
				text = {}
				for damtype, value in pairs(data.damtypes) do if damtype ~= "changed" then
					local dt = DamageType:get(damtype)
					if dt then
						text[#text+1] = ("%s%s#WHITE#: %d (%d%%)"):format(dt.text_color or "#WHITE#", (dt.kr_name or dt.name), value, value / data.total * 100)
					end
				end end
				text = table.concat(text, "\n")
				data.damtypes.changed = false
			end
			tex, nblines, wline = font:draw(text, text:toTString():maxWidth(font), 255, 255, 255)
		end

		y = y - tex[1].h * nblines
		x = x - (wline - w) / 2
		frame.w = wline + 16 frame.h = tex[1].h * nblines + 16
		MyUI:drawFrame(frame, x - 4, y - 4, 0, 0, 0, 0.3)
		MyUI:drawFrame(frame, x - 8, y - 8, 1, 1, 1, 0.6)
		for i = 1, #tex do
			local item = tex[i]
			if shader then
				shader:use(true)
				shader:uniOutlineSize(2, 2)
				shader:uniTextSize(item._tex_w, item._tex_h)
			else
				item._tex:toScreenFull(x+2, y+2, item.w, item.h, item._tex_w, item._tex_h, 0, 0, 0, 0.7)
			end
			item._tex:toScreenFull(x, y, item.w, item.h, item._tex_w, item._tex_h)
			if shader then shader:use(false) end
			y = y + item.h
		end
		return true
	end)
end

newEntity{
	define_as = "MONITOR_ORB1",
	name = "Training Monitor Orb", image = "terrain/solidwall/solid_floor1.png",
	kr_name = "연습 관측 오브",
	add_displays = {class.new{
		image="terrain/shertul_control_orb_greenish.png", z=17,
		monitor_mode = "global",
		defineDisplayCallback = dcb,
	}},
	display = '*', color=colors.PURPLE,
	notice = true,
	always_remember = true,
	block_move = true,
}

newEntity{
	define_as = "MONITOR_ORB2",
	name = "Training Monitor Orb", image = "terrain/solidwall/solid_floor1.png",
	kr_name = "연습 관측 오브",
	add_displays = {class.new{
		image="terrain/shertul_control_orb_greenish.png", z=17,
		monitor_mode = "specific",
		defineDisplayCallback = dcb,
	}},
	display = '*', color=colors.PURPLE,
	notice = true,
	always_remember = true,
	block_move = true,
}
