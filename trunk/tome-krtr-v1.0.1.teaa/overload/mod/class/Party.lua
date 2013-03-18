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
require "engine.class"
require "engine.Entity"
local Map = require "engine.Map"
local Dialog = require "engine.ui.Dialog"
local GetQuantity = require "engine.dialogs.GetQuantity"
local PartyOrder = require "mod.dialogs.PartyOrder"
local PartyIngredients = require "mod.class.interface.PartyIngredients"
local PartyLore = require "mod.class.interface.PartyLore"
local PartyRewardSelector = require "mod.dialogs.PartyRewardSelector"

module(..., package.seeall, class.inherit(
	engine.Entity, PartyIngredients, PartyLore
))

function _M:init(t, no_default)
	t.name = t.name or "party"
	engine.Entity.init(self, t, no_default)
	PartyIngredients.init(self, t)
	PartyLore.init(self, t)

	self.members = {}
	self.m_list = {}
	self.energy = {value = 0, mod=100000} -- "Act" every tick
	self.on_death_show_achieved = {}
end

function _M:addMember(actor, def)
	if self.members[actor] then
		print("[PARTY] error trying to add existing actor: ", actor.uid, actor.name)
		return false
	end
	if type(def.control) == "nil" then def.control = "no" end
	def.title = def.title or "Party member"
	self.members[actor] = def
	self.m_list[#self.m_list+1] = actor
	def.index = #self.m_list

	if #self.m_list >= 6 then
		game:getPlayer(true):attr("huge_party", 1)
	end

	actor.ai_state = actor.ai_state or {}
	actor.ai_state.tactic_leash_anchor = actor.ai_state.tactic_leash_anchor or game.player
	actor.ai_state.tactic_leash = actor.ai_state.tactic_leash or 10

	actor.addEntityOrder = function(self, level)
		print("[PARTY] New member, add after", self.name, game.party.m_list[1].name)
		return game.party.m_list[1] -- Make the sure party is always consecutive in the level entities list
	end

	-- Turn NPCs into party members
	if not actor.no_party_class then
		local uid = actor.uid
		actor.replacedWith = false
		actor:replaceWith(require("mod.class.PartyMember").new(actor))
		actor.uid = uid
		__uids[uid] = actor
		actor.replacedWith = nil
	end

	-- Notify the UI
	if game.player then game.player.changed = true end
end

function _M:removeMember(actor, silent)
	if not self.members[actor] then
		if not silent then
			print("[PARTY] error trying to remove non-existing actor: ", actor.uid, actor.name)
		end
		return false
	end
	table.remove(self.m_list, self.members[actor].index)
	self.members[actor] = nil

	actor.addEntityOrder = nil

	-- Update indexes
	for i = 1, #self.m_list do
		self.members[self.m_list[i]].index = i
	end

	-- Notify the UI
	game.player.changed = true
end

function _M:leftLevel()
	local todel = {}
	local newplayer = false
	for i, actor in ipairs(self.m_list) do
		local def = self.members[actor]
		if def.temporary_level then
			todel[#todel+1] = actor
			if actor == game.player then newplayer = true end
		end
	end
	for i = 1, #todel do
		self:removeMember(todel[i])
		todel[i]:disappear()
	end
	self:findSuitablePlayer()
end

function _M:hasMember(actor)
	return self.members[actor]
end

function _M:findMember(filter)
	for i, actor in ipairs(self.m_list) do
		local ok = true
		local def = self.members[actor]

		if filter.main and not def.main then ok = false end
		if filter.type and def.type ~= filter.type then ok = false end

		if ok then return actor end
	end
end

function _M:countInventoryAble()
	local nb = 0
	for i, actor in ipairs(self.m_list) do
		if not actor.no_inventory_access and actor:getInven(actor.INVEN_INVEN) then nb = nb + 1 end
	end
	return nb
end

function _M:setDeathTurn(actor, turn)
	local def = self.members[actor]
	if not def then return end
	def.last_death_turn = turn
end

function _M:findLastDeath()
	local max_turn = -9999
	local last = nil

	for i, actor in ipairs(self.m_list) do
		local def = self.members[actor]

		if def.last_death_turn and def.last_death_turn > max_turn then max_turn = def.last_death_turn; last = actor end
	end
	return last or self:findMember{main=true}
end

function _M:canControl(actor, vocal)
	if not actor then return false end
	if actor == game.player then
		print("[PARTY] error trying to set player, same")
		return false
	end

	if game.player and game.player.no_leave_control then
		print("[PARTY] error trying to set player but current player is modal")
		return false
	end
	if not self.members[actor] then
		print("[PARTY] error trying to set player, not a member of party: ", actor.uid, actor.name)
		return false
	end
	if self.members[actor].control ~= "full" then
		print("[PARTY] error trying to set player, not controlable: ", actor.uid, actor.name)
		return false
	end
	if actor.dead or (game.level and not game.level:hasEntity(actor)) then
		if vocal then game.logPlayer(game.player, "이 존재의 제어권을 가져올수 없습니다.") end
		print("[PARTY] error trying to set player, no entity or dead")
		return false
	end
	if actor.on_can_control and not actor:on_can_control(vocal) then
		print("[PARTY] error trying to set player, forbade")
		return false
	end
	return true
end

function _M:setPlayer(actor, bypass)
	if type(actor) == "number" then actor = self.m_list[actor] end

	if not bypass then
		local ok, err = self:canControl(actor, true)
		if not ok then return nil, err end
	end

	if actor == game.player then return true end

	-- Stop!!
	if game.player and game.player.runStop then game.player:runStop("제어권 변경") end
	if game.player and game.player.restStop then game.player:restStop("제어권 변경") end

	local def = self.members[actor]
	local oldp = self.player
	self.player = actor

	-- Convert the class to always be a player
	if actor.__CLASSNAME ~= "mod.class.Player" and not actor.no_party_class then
		actor.__PREVIOUS_CLASSNAME = actor.__CLASSNAME
		local uid = actor.uid
		actor.replacedWith = false
		actor:replaceWith(mod.class.Player.new(actor))
		actor.replacedWith = nil
		actor.uid = uid
		__uids[uid] = actor
		actor.changed = true
	end

	-- Setup as the curent player
	actor.player = true
	game.paused = actor:enoughEnergy()
	game.player = actor
	game.uiset.hotkeys_display.actor = actor
	Map:setViewerActor(actor)
	if game.target then game.target.source_actor = actor end
	if game.level and actor.x and actor.y then game.level.map:moveViewSurround(actor.x, actor.y, 8, 8) end
	actor._move_others = actor.move_others
	actor.move_others = true

	-- Change back the old actor to a normal actor
	if oldp and oldp ~= actor then
		if self.members[oldp] and self.members[oldp].on_uncontrol then self.members[oldp].on_uncontrol(oldp) end

		if oldp.__PREVIOUS_CLASSNAME then
			local uid = oldp.uid
			oldp.replacedWith = false
			oldp:replaceWith(require(oldp.__PREVIOUS_CLASSNAME).new(oldp))
			oldp.replacedWith = nil
			oldp.uid = uid
			__uids[uid] = oldp
		end

		actor.move_others = actor._move_others
		oldp.changed = true
		oldp.player = nil
		if game.level and oldp.x and oldp.y then oldp:move(oldp.x, oldp.y, true) end
	end

	if def.on_control then def.on_control(actor) end

	if game.level and actor.x and actor.y then actor:move(actor.x, actor.y, true) end

	if not actor.hotkeys_sorted then actor:sortHotkeys() end

	game.logPlayer(actor, "#MOCCASIN#캐릭터 제어를 %s에게로 바꿉니다.", (actor.kr_name or actor.name))

	return true
end

function _M:findSuitablePlayer(type)
	for i, actor in ipairs(self.m_list) do
		local def = self.members[actor]
		if def.control == "full" and (not type or def.type == type) and not actor.dead and game.level:hasEntity(actor) then
			if self:setPlayer(actor, true) then
				return true
			end
		end
	end
	return false
end

function _M:canOrder(actor, order, vocal)
	if not actor then return false end
	if actor == game.player then return false end

	if not self.members[actor] then
		print("[PARTY] error trying to order, not a member of party: ", actor.uid, actor.name)
		return false
	end
	if (self.members[actor].control ~= "full" and self.members[actor].control ~= "order") or not self.members[actor].orders then
		print("[PARTY] error trying to order, not controlable: ", actor.uid, actor.name)
		return false
	end
	if actor.dead or (game.level and not game.level:hasEntity(actor)) then
		if vocal then game.logPlayer(game.player, "이 존재에게는 명령을 내릴수 없습니다.") end
		return false
	end
	if actor.on_can_order and not actor:on_can_order(vocal) then
		print("[PARTY] error trying to order, can order forbade")
		return false
	end
	if order and not self.members[actor].orders[order] then
		print("[PARTY] error trying to order, unknown order: ", actor.uid, actor.name)
		return false
	end
	return true
end

function _M:giveOrders(actor)
	if type(actor) == "number" then actor = self.m_list[actor] end

	local ok, err = self:canOrder(actor, nil, true)
	if not ok then return nil, err end

	local def = self.members[actor]

	game:registerDialog(PartyOrder.new(actor, def))

	return true
end

function _M:giveOrder(actor, order)
	if type(actor) == "number" then actor = self.m_list[actor] end

	local ok, err = self:canOrder(actor, order, true)
	if not ok then return nil, err end

	local def = self.members[actor]

	if order == "leash" then
		game:registerDialog(GetQuantity.new("행동 반경 설정: "..(actor.kr_name or actor.name), "동료의 대표로부터 떨어질수 있는 최대 거리를 설정합니다", actor.ai_state.tactic_leash, actor.ai_state.tactic_leash_max or 100, function(qty)
			actor.ai_state.tactic_leash = util.bound(qty, 1, actor.ai_state.tactic_leash_max or 100)
			game.logPlayer(game.player, "%s의 최대 행동 반경이 %d으로 설정되었습니다..", (actor.kr_name or actor.name):capitalize(), actor.ai_state.tactic_leash)
		end), 1)
	elseif order == "anchor" then
		local co = coroutine.create(function()
			local x, y, act = game.player:getTarget({type="hit", range=10, nowarning=true})
			local anchor
			if x and y then
				if act then
					anchor = act
				else
					anchor = {x=x, y=y, name="that location"}
				end
				actor.ai_state.tactic_leash_anchor = anchor
				game.logPlayer(game.player, "%s %s의 주변에 머뭅니다.", (actor.kr_name or actor.name):capitalize():addJosa("가"), (anchor.kr_name or anchor.name))
			end
		end)
		local ok, err = coroutine.resume(co)
		if not ok and err then print(debug.traceback(co)) error(err) end
	elseif order == "target" then
		local co = coroutine.create(function()
			local x, y, act = game.player:getTarget({type="hit", range=10})
			if act then
				actor:setTarget(act)
				game.logPlayer(game.player, "%s %s 목표로 합니다.", (actor.kr_name or actor.name):capitalize():addJosa("가"), (act.kr_name or act.name):addJosa("를"))
			end
		end)
		local ok, err = coroutine.resume(co)
		if not ok and err then print(debug.traceback(co)) error(err) end
	elseif order == "behavior" then
		game:registerDialog(require("mod.dialogs.orders."..order:capitalize()).new(actor, def))
	elseif order == "talents" then
		game:registerDialog(require("mod.dialogs.orders."..order:capitalize()).new(actor, def))

	-------------------------------------------
	-- Escort specifics
	-------------------------------------------
	elseif order == "escort_rest" then
		-- Rest for a few turns
		if actor.ai_state.tactic_escort_rest then actor:doEmote("안돼요, 우린 좀 서둘러야 해요!", 40) return true end
		actor.ai_state.tactic_escort_rest = rng.range(6, 10)
		actor:doEmote("알겠어요, 하지만 너무 오래는 안 돼요.", 40)
	elseif order == "escort_portal" then
		local dist = core.fov.distance(actor.escort_target.x, actor.escort_target.y, actor.x, actor.y)
		if dist < 8 then dist = "아주 가까이"
		elseif dist < 16 then dist = "가까이"
		else dist = "아직 멀리"
		end

		local dir = game.level.map:compassDirection(actor.escort_target.x - actor.x, actor.escort_target.y - actor.y)
		actor:doEmote(("관문은 %s 방향으로 %s 있어요."):format(dir or "알 수 없는", dist), 45) --@@ 변수 순서 조정
	end

	return true
end

function _M:select(actor)
	if not actor then return false end
	if type(actor) == "number" then actor = self.m_list[actor] end
	if actor == game.player then print("[PARTY] control fail, same", actor, game.player) return false end

	if self:canControl(actor) then return self:setPlayer(actor)
	elseif self:canOrder(actor) then return self:giveOrders(actor)
	end
	return false
end

function _M:canReward(actor)
	if not actor then return false end

	if not self.members[actor] then
		return false
	end
	if self.members[actor].control ~= "full" then
		return false
	end
	if actor.dead or (game.level and not game.level:hasEntity(actor)) then
		return false
	end
	if actor.summon_time then
		return false
	end
	return true
end

function _M:reward(title, action)
	local d = PartyRewardSelector.new(title, action)
	if #d.list == 1 then
		action(d.list[1].actor)
		return
	end
	game:registerDialog(d)
end

function _M:findInAllPartyInventoriesBy(prop, value)
	local o, item, inven_id
	for i, mem in ipairs(game.party.m_list) do
		o, item, inven_id = mem:findInAllInventoriesBy(prop, value)
		if o then return mem, o, item, inven_id  end
	end
end
