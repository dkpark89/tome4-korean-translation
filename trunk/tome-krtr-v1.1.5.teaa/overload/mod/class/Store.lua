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
local Store = require "engine.Store"
local Dialog = require "engine.ui.Dialog"

module(..., package.seeall, class.inherit(Store))

_M.stores_def = {}

function _M:loadStores(f)
	self.stores_def = self:loadList(f)
end

function _M:init(t, no_default)
	t.store.buy_percent = t.store.buy_percent or function(self, o) if o.type == "gem" then return 40 else return 5 end end
	t.store.sell_percent = t.store.sell_percent or function(self, o) -- Store prices goes up with item level
			return mod.class.interface.Combat:combatTalentScale(math.max(1, o.__store_level or 1), 123, 135, "log") 
		end
	t.store.nb_fill = t.store.nb_fill or 10
	t.store.purse = t.store.purse or 20
	Store.init(self, t, no_default)

	self.kr_name = (self.kr_name or self.name) .. (" (금화 %0.2f 개 이상의 물건만 취급)"):format(self.store.purse)
	self.name = self.name .. (" (금화 %0.2f 개 이상의 물건만 취급)"):format(self.store.purse)

	if not self.store.actor_filter then
		self.store.actor_filter = function(o)
			return not o.quest and not o.lore and o.cost and o.cost > 0
		end
	end
end

--- Caleld when a new object is stocked
function _M:stocked_object(o)
	o.__store_level = game.zone.base_level + game.level.level - 1
end

--- Restock based on player level
function _M:canRestock()
	local s = self.store
	if self.last_filled and self.last_filled >= game.state.stores_restock then
		print("[STORE] not restocking yet [stores_restock]", game.state.stores_restock, s.restock_every, self.last_filled)
		return false
	end
	return true
end

--- Fill the store with goods
-- @param level the level to generate for (instance of type engine.Level)
-- @param zone the zone to generate for
function _M:loadup(level, zone)
	local oldlev = zone.base_level

	if zone.store_levels_by_restock then
		zone.base_level = zone.store_levels_by_restock[game.state.stores_restock] or zone.base_level
	end

	if Store.loadup(self, level, zone, self.store.nb_fill) then
		self.last_filled = game.state.stores_restock
	end

	zone.base_level = oldlev

	-- clear chrono worlds and their various effects
	if game._chronoworlds then
		game.log("#CRIMSON#당신의 시간여행은 이와 같이 미리 결정된 결과에는 영향을 주지 못합니다.")
		game._chronoworlds = nil
	end
end

--- Checks if the given entity is allowed
function _M:allowStockObject(e)
	local price = self:getObjectPrice(e, "buy")
	return price > 0
end

--- Called on object purchase try
-- @param who the actor buying
-- @param o the object trying to be purchased
-- @param item the index in the inventory
-- @param nb number of items (if stacked) to buy
-- @return true if allowed to buy
function _M:tryBuy(who, o, item, nb)
	local price = self:getObjectPrice(o, "buy")
	if who.money >= price * nb then
		return nb, price * nb
	else
		Dialog:simplePopup("금화 부족", "가지고 있는 금화가 부족합니다!")
	end
end

--- Called on object sale try
-- @param who the actor selling
-- @param o the object trying to be sold
-- @param item the index in the inventory
-- @param nb number of items (if stacked) to sell
-- @return true if allowed to sell
function _M:trySell(who, o, item, nb)
	local price = self:getObjectPrice(o, "sell")
	if price <= 0 or nb <= 0 then return end
	price = math.min(price * nb, self.store.purse * nb)
	return nb, price
end

--- Called on object purchase
-- @param who the actor buying
-- @param o the object trying to be purchased
-- @param item the index in the inventory
-- @param nb number of items (if stacked) to buy
-- @param before true if this happens before removing the item
-- @return true if allowed to buy
function _M:onBuy(who, o, item, nb, before)
	if before then return end
	local price = self:getObjectPrice(o, "buy")
	if who.money >= price * nb then
		who:incMoney(- price * nb)
		game.log("구입 : %s 금화 %0.2f 개에 구입.", (o:getName{do_color=true}):addJosa("를"), price * nb)
	end
end

--- Called on object sale
-- @param who the actor selling
-- @param o the object trying to be sold
-- @param item the index in the inventory
-- @param nb number of items (if stacked) to sell
-- @param before true if this happens before removing the item
-- @return true if allowed to sell
function _M:onSell(who, o, item, nb, before)
	if before then o:identify(true) return end

	local price = self:getObjectPrice(o, "sell")
	if price <= 0 or nb <= 0 then return end
	price = math.min(price * nb, self.store.purse * nb)
	who:incMoney(price)
	o:forAllStack(function(so) so.__force_store_forget = true end) -- Make sure the store does forget about it when it restocks
	game.log("판매 : %s 금화 %0.2f개에 판매.", (o:getName{do_color=true}):addJosa("를"), price)
end

--- Override the default
function _M:doBuy(who, o, item, nb, store_dialog)
	nb = math.min(nb, o:getNumber())
	local price
	nb, price = self:tryBuy(who, o, item, nb)
	if nb then
		Dialog:yesnoPopup("구입", ("%d 개의 %s 금화 %0.2f 개에 사시겠습니까?"):format(nb, (o:getName{do_color=true, no_count=true}):addJosa("를"), price), function(ok) if ok then
			self:onBuy(who, o, item, nb, true)
			-- Learn lore ?
			if who.player and o.lore then
				self:removeObject(self:getInven("INVEN"), item)
				game.party:learnLore(o.lore)
			else
				self:transfer(self, who, item, nb)
			end
			self:onBuy(who, o, item, nb, false)
			if store_dialog then store_dialog:updateStore() end
		end end, "구입", "취소")
	end
end

--- Override the default
function _M:doSell(who, o, item, nb, store_dialog)
	nb = math.min(nb, o:getNumber())
	local price
	nb, price = self:trySell(who, o, item, nb)
	if nb then
		Dialog:yesnoPopup("판매", ("%d 개의 %s 금화 %0.2f 개에 파시겠습니까?"):format(nb, (o:getName{do_color=true, no_count=true}):addJosa("를"), price), function(ok) if ok then
			self:onSell(who, o, item, nb, true)
			self:transfer(who, self, item, nb)
			self:onSell(who, o, item, nb, false)
			if store_dialog then store_dialog:updateStore() end
		end end, "판매", "취소")
	end
end

--- Called to describe an object, being to sell or to buy
-- @param who the actor
-- @param what either "sell" or "buy"
-- @param o the object
-- @return a string (possibly multiline) describing the object
function _M:descObject(who, what, o)
	if what == "buy" then
		local desc = tstring({"font", "bold"}, {"color", "GOLD"}, ("구입 금액 : %0.2f (소지금 %0.2f)"):format(self:getObjectPrice(o, "buy"), who.money), {"font", "normal"}, {"color", "LAST"}, true, true)
		desc:merge(o:getDesc())
		return desc
	else
		local desc = tstring({"font", "bold"}, {"color", "GOLD"}, ("판매 금액 : %0.2f (소지금 %0.2f)"):format(self:getObjectPrice(o, "sell"), who.money), {"font", "normal"}, {"color", "LAST"}, true, true)
		desc:merge(o:getDesc())
		return desc
	end
end

function _M:getObjectPrice(o, what)
	local v = o:getPrice() * util.getval(what == "buy" and self.store.sell_percent or self.store.buy_percent, self, o) / 100
	return math.ceil(v * 10) / 10
end

--- Called to describe an object's price, being to sell or to buy
-- @param who the actor
-- @param what either "sell" or "buy"
-- @param o the object
-- @return a string describing the price
function _M:descObjectPrice(who, what, o)
	return self:getObjectPrice(o, what), who.money
end

--- Actor interacts with the store
-- @param who the actor who interacts
function _M:interact(who, name)
	who:sortInven()
	Store.interact(self, who, name)
end
