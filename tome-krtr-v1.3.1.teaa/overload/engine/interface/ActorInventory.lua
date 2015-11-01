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
local Map = require "engine.Map"
local ShowInventory = require_first("mod.dialogs.ShowInventory", "engine.dialogs.ShowInventory")
local ShowEquipment = require_first("mod.dialogs.ShowEquipment", "engine.dialogs.ShowEquipment")
local ShowEquipInven = require_first("mod.dialogs.ShowEquipInven", "engine.dialogs.ShowEquipInven")
local ShowPickupFloor = require_first("mod.dialogs.ShowPickupFloor", "engine.dialogs.ShowPickupFloor")

--- Handles actors stats
module(..., package.seeall, class.make)

_M.inven_def = {}

--- Defines an Inventory slot
-- Static!
-- @param short_name = name for reference (required)
-- @param name = name used for messages (required)
-- @param is_worn = boolean true if equipment can be worn in this inventory
-- @param desc = description (required)
-- @param show_equip = boolean to show inventory when displaying equipment dialogs
-- @param infos = additional information (including default stack_limit)
function _M:defineInventory(short_name, name, is_worn, desc, show_equip, infos)
	assert(name, "no inventory slot name")
	assert(short_name, "no inventory slot short_name")
	assert(desc, "no inventory slot desc")
	table.insert(self.inven_def, {
		name = name,
		short_name = short_name,
		description = desc,
		is_worn = is_worn,
		is_shown_equip = show_equip,
		infos = infos,
		stack_limit = infos and infos.stack_limit,
	})
	self.inven_def[#self.inven_def].id = #self.inven_def
	self.inven_def[short_name] = self.inven_def[#self.inven_def]
	self["INVEN_"..short_name:upper()] = #self.inven_def
	print("[INVENTORY] define slot", #self.inven_def, self.inven_def[#self.inven_def].name)
end

-- Auto define the inventory
_M:defineInventory("INVEN", "In inventory", false, "") --INVEN_INVEN assumed to have no stacking limit

--- Initialises inventories with default values if needed
function _M:init(t)
	self.inven = t.inven or {}
	self:initBody()
end

--- generate inventories according to the body definition table
--	@param self.body = {SLOT_ID = max, ...}
--	@param max = number of slots if number or table of properties (max = , stack_limit = , ..) merged into definition
function _M:initBody()
	if self.body then
		local def
		for inven, max in pairs(self.body) do
			def = self.inven_def[self["INVEN_"..inven]]
			assert(def, "inventory slot undefined")
			self.inven[self["INVEN_"..inven]] = {worn=def.is_worn, id=self["INVEN_"..inven], name=inven, stack_limit = def.stack_limit}
			if type(max) == "table" then
				table.merge(self.inven[self["INVEN_"..inven]], max, true)
			else
				self.inven[self["INVEN_"..inven]].max = max
			end
		end
		self.body = nil
	end
end

--- Returns the content of an inventory as a table
function _M:getInven(id)
	if type(id) == "number" then
		return self.inven[id]
	elseif type(id) == "string" then
		return self.inven[self["INVEN_"..id]]
	else
		return id
	end
end

--- Tells if an inventory still has room left
function _M:canAddToInven(id)
	if type(id) == "number" then
		return #self.inven[id] < self.inven[id].max
	elseif type(id) == "string" then
		return #self.inven[self["INVEN_"..id]] < self.inven[self["INVEN_"..id]].max
	else
		return id
	end
end

--- Get stacking limit for an inventory
--  @param id inventory id or table (stack_limit in inventory table takes precedence)
function _M:invenStackLimit(id)
	local inven = self:getInven(id)
	return inven.stack_limit or self.inven_def[inven.id].stack_limit or math.huge
end

--- Adds an object to an inventory
-- @param inven_id = inventory id to add to
-- @param o = object to add
-- @param no_unstack = boolean to prevent unstacking the object to be added
-- @param force_item to add to the set position instead of to the end
-- @return false if the object could not be added or true, inventory index it was moved to, remaining stack if any or false
-- checks o:on_preaddobject(self, inven) (must return true to add to inventory)
function _M:addObject(inven_id, o, no_unstack, force_item)
	local inven = self:getInven(inven_id)
	local slot
	local stack, rs, ok
	local stackable, stack_limit = o and o:stackable(), self:invenStackLimit(inven_id)

	-- No room, stackable ?
	if #inven >= inven.max then
		if stackable and not no_unstack then -- try to find a stack to add to
			for i, obj in ipairs(inven) do
				if o:canStack(obj) and obj:getNumber() < stack_limit and (not force_item or force_item == i) then
					slot = i
					stack = obj break -- only room left
				end
			end
			if not stack then return false end
		else
			return false
		end
	end

	if o:check("on_preaddobject", self, inven) then return false end

	-- Add the object
	if stackable and not no_unstack then -- handle stackable objects
		local last = true
		rs = true
		if stack then -- add to stack already found
			ok, last = stack:stack(o, false, stack_limit - stack:getNumber())
		elseif o:getNumber() > stack_limit then -- stack too big - unstack some before adding
			stack, last = o:unstack(o:getNumber() - stack_limit)
			table.insert(inven, o)
		else
			table.insert(inven, o)
		end
		if last then rs = false	end
	else
		force_item = math.min(#inven + 1, force_item or #inven + 1)
		table.insert(inven, force_item, o)
	end

	-- Do whatever is needed when wearing this object
	if inven.worn then
		self:onWear(o, self.inven_def[inven.id].short_name)
	end

	self:onAddObject(o)

	-- Make sure the object is registered with the game, if need be
	if not game:hasEntity(o) then game:addEntity(o) end
	return true, slot or #inven, rs and stack
end

--- Returns the position of an item in the given inventory, or nil
-- @param inven = inventory or inventory id to search
-- @param o = object to look for
-- @param by_reference set true to match by exact (memory) reference, otherwise matches by o.name
-- @return nil or the inventory slot, stack position if stacked
function _M:itemPosition(inven, o, by_reference)
	inven = self:getInven(inven)
	local found, pos = nil, nil
	for i, p in ipairs(inven) do
		p:forAllStack(function(so, j)
			if (not by_reference and (so.name == o.name) or (so == o)) then
				found = i pos = j return true
			end
		end)
		if found then return found, pos end
	end
	return nil
end

--- Pick up an object from the floor
-- @param i = object position on map at self.x, self.y
-- @param vocal = boolean to post messages to log
-- @param no_sort = boolen to suppress automatic sorting of inventory
--	puts picked up objects in self.INVEN_INVEN
-- @return the object picked up (or stack added to), num picked up or true if o:on_prepickup(i) returns true (not "skip") or nil
--  checks obj:on_prepickup(self, i) (must return true to pickup)
--	checks obj:on_pickup(self, num) and self:on_pickup_object(obj, num) functions after pickup (includes stacks)
function _M:pickupFloor(i, vocal, no_sort)
	local inven = self:getInven(self.INVEN_INVEN)
	if not inven then return end
	local o = game.level.map:getObject(self.x, self.y, i)
	if o then
		local prepickup = o:check("on_prepickup", self, i)
		if not prepickup then
			local num = o:getNumber()
			local ok, slot, ro = self:addObject(self.INVEN_INVEN, o)
			if ok then
				local newo = inven[slot] -- get exact object added or stack (resolves duplicates)
				game.level.map:removeObject(self.x, self.y, i)
				if ro then -- return remaining stack to floor
					game.level.map:addObject(self.x, self.y, ro)
					num = num - ro:getNumber()
				end
				if not no_sort then self:sortInven(self.INVEN_INVEN) end
				-- Apply checks to whole stack (including already carried) assuming homogeneous stack
				-- num added passed to functions to allow checks on part of the stack
				newo:check("on_pickup", self, num)
				self:check("on_pickup_object", newo, num)

				slot = self:itemPosition(self.INVEN_INVEN, newo, true) or 1
				local letter = ShowPickupFloor:makeKeyChar(slot)

				if vocal then game.logSeen(self, "%s picks up (%s.): %s%s.", self.name:capitalize(), letter, num>1 and ("%d "):format(num) or "", o:getName{do_color=true, no_count = true}) end
				return inven[slot], num
			else
				if vocal then game.logSeen(self, "%s has no room for: %s.", self.name:capitalize(), o:getName{do_color=true}) end
				return
			end
		elseif prepickup == "skip" then
			return
		else
			return true
		end
	else
		if vocal then game.logSeen(self, "There is nothing to pick up here.") end
	end
end

--- Removes an object from inventory
-- @param inven the inventory to remove from
-- @param item inven slot of the item to remove
-- @param no_unstack = num items to remove into a new stack (set true to remove the original stack unchanged)
-- @return the object removed or nil if no item existed and a boolean saying if there is no more objects
--  checks obj:on_preremoveobject(self, inven) (return true to not remove)
function _M:removeObject(inven_id, item, no_unstack)
	local inven = self:getInven(inven_id)

	if not inven[item] then return nil, true end

	local o, finish = inven[item], true

	if o:check("on_preremoveobject", self, inven) then return nil, true end
	if no_unstack then
		if type(no_unstack) == "number" then
			o, finish = o:unstack(no_unstack)
		end
	else
		o, finish = o:unstack()
	end
	if finish then
		table.remove(inven, item)
	end

	-- Do whatever is needed when taking off this object
	if inven.worn then
		self:onTakeoff(o, self.inven_def[inven.id].short_name)
	end

	self:onRemoveObject(o)

	-- Make sure the object is registered with the game, if need be
	if not game:hasEntity(o) then game:addEntity(o) end

	return o, finish
end

--- Called upon adding an object
function _M:onAddObject(o)
	if self.__allow_carrier then
		-- Apply carrier properties
		o.carried = {}
		if o.carrier then
			for k, e in pairs(o.carrier) do
				o.carried[k] = self:addTemporaryValue(k, e)
			end
		end
	end
end

--- Called upon removing an object
function _M:onRemoveObject(o)
	if o.carried then
		for k, id in pairs(o.carried) do
			self:removeTemporaryValue(k, id)
		end
	end
	o.carried = nil
end

--- Called upon dropping an object
function _M:onDropObject(o)
end

--- Drop an object on the floor
-- @param inven the inventory to drop from
-- @param item the item id to drop
-- @param all set to remove part (if number) or all (if true) a stack
-- @return the object removed or nil if no item existed
--  checks obj:on_drop(self) (return true to not drop)
function _M:dropFloor(inven, item, vocal, all)
	local o = self:getInven(inven)[item]
	if not o then
		if vocal then game.logSeen(self, "There is nothing to drop.") end
		return
	end
	if o:check("on_drop", self) then return false end

	o = self:removeObject(inven, item, all)

	self:onDropObject(o)

	local ok, idx = game.level.map:addObject(self.x, self.y, o)

	if vocal then game.logSeen(self, "%s drops on the floor: %s.", self.name:capitalize(), o:getName{do_color=true}) end
	if ok and game.level.map.attrs(self.x, self.y, "on_drop") then
		game.level.map.attrs(self.x, self.y, "on_drop")(self, self.x, self.y, idx, o)
	end
	return o
end

--- Show combined equipment/inventory dialog
-- @param inven the inventory (from self:getInven())
-- @param filter nil or a function that filters the objects to list
-- @param action a function called when an object is selected
function _M:showEquipInven(title, filter, action, on_select)
	local d = ShowEquipInven.new(title, self, filter, action, on_select)
	game:registerDialog(d)
	return d
end

--- Show inventory dialog
-- @param inven the inventory (from self:getInven())
-- @param filter nil or a function that filters the objects to list
-- @param action a function called when an object is selected
function _M:showInventory(title, inven, filter, action)
	if not inven then return end
	local d = ShowInventory.new(title, inven, filter, action, self)
	game:registerDialog(d)
	return d
end

--- Show equipment dialog
-- @param filter nil or a function that filters the objects to list
-- @param action a function called when an object is selected
function _M:showEquipment(title, filter, action)
	local d = ShowEquipment.new(title, self, filter, action)
	game:registerDialog(d)
	return d
end

--- Show floor pickup dialog
-- @param filter nil or a function that filters the objects to list
-- @param action a function called when an object is selected
function _M:showPickupFloor(title, filter, action)
	local d = ShowPickupFloor.new(title, self.x, self.y, filter, action, nil, self)
	game:registerDialog(d)
	return d
end

--- Can we wear this item?
-- @param o = object to wear
-- @param try_slot = inventory slot to wear (override)
--  checks self:canWearObjectCustom(o, try_slot)  (return true to make unwearable)
function _M:canWearObject(o, try_slot)
	local req = rawget(o, "require")

	-- check if the slot matches dammit
	if try_slot and try_slot ~= o.slot and try_slot ~= self:getObjectOffslot(o) then
		return nil, "wrong equipment slot"
	end

	-- Check prerequisites
	if req then
		-- Obviously this requires the ActorStats interface
		if req.stat then
			for s, v in pairs(req.stat) do
				if self:getStat(s) < v then return nil, "not enough stat" end
			end
		end
		if req.level and self.level < req.level then
			return nil, "not enough levels"
		end
		if req.talent then
			for _, tid in ipairs(req.talent) do
				if type(tid) == "table" then
					if self:getTalentLevelRaw(tid[1]) < tid[2] then return nil, "missing dependency" end
				else
					if not self:knowTalent(tid) then return nil, "missing dependency" end
				end
			end
		end
	end

	-- Check forbidden slot
	if o.slot_forbid and self:slotForbidCheck(o, o.slot or try_slot) then
		local inven = self:getInven(o.slot_forbid)
		-- If the object cant coexist with that inventory slot and it exists and is not empty, refuse wearing
		if inven and #inven > 0 then
			return nil, "cannot use currently due to an other worn object"
		end
	end

	-- Check that we are not the forbidden slot of any other worn objects
	for id, inven in pairs(self.inven) do
		if self.inven_def[id].is_worn and (not self.inven_def[id].infos or not self.inven_def[id].infos.etheral) then
			for i, wo in ipairs(inven) do
				print("fight: ", o.name, wo.name, "::", wo.slot_forbid, try_slot or o.slot)
				if wo.slot_forbid and self:slotForbidCheck(wo, id) and wo.slot_forbid == (try_slot or o.slot) then
					print(" impossible => ", o.name, wo.name, "::", wo.slot_forbid, try_slot or o.slot)
					return nil, "cannot use currently due to an other worn object"
				end
			end
		end
	end

	-- Any custom checks
	local err = self:check("canWearObjectCustom", o, try_slot)
	if err then return nil, err end

	return true
end

--- Checks if the given item should respect its slot_forbid value
-- @param o the item to check
-- @param in_inven the inventory id in which the item is worn or tries to be worn
function _M:slotForbidCheck(o, in_inven_id)
	return true
end

--- Returns the possible offslot
function _M:getObjectOffslot(o)
	return o.offslot
end

--- Wear/wield an item
--	@param o = object to be worn
--	@param replace = boolean allow first object in wearable inventory to be removed to make space if needed
--	@vocal = boolean to post messages to game.logSeen(self, ....)
--  @force_inven = try to equip into this inventory only
--  @force_item = attempt to equip/replace into that slot
--	returns true or replaced object if succeeded or false if not, remaining stack of o if any
--  checks o:on_canwear(self, inven) (return true to prevent wearing)
function _M:wearObject(o, replace, vocal, force_inven, force_item)
	-- keep it cause stack might change later
	local o_name = o:getName{do_color=true}

	local inven_id = force_inven or o:wornInven()
	local inven = self:getInven(inven_id)
	if not inven_id then
		if vocal then game.logSeen(self, "%s is not wearable.", o_name) end
		return false
	end
	if not inven then
		if vocal then game.logSeen(self, "%s can not wear %s.", self.name, o_name) end
		return false
	end


	local ok, err = self:canWearObject(o, inven.name)
	if not ok then
		if vocal then game.logSeen(self, "%s can not wear (%s): %s (%s).", self.name:capitalize(), self.inven_def[inven.name].name:lower(), o_name, err) end
		return false
	end
	if o:check("on_canwear", self, inven) then return false end
	local offslot, stackable = self:getObjectOffslot(o), o:stackable()
	local added, slot, stack = self:addObject(inven_id, o, nil, force_item)

	if added then
		if vocal then game.logSeen(self, "%s wears: %s.", self.name:capitalize(), o_name) end
		return true, stack
	elseif not force_inven and offslot and self:getInven(offslot) and #(self:getInven(offslot)) < self:getInven(offslot).max and self:canWearObject(o, offslot) then
		if vocal then game.logSeen(self, "%s wears (offslot): %s.", self.name:capitalize(), o:getName{do_color=true}) end
		added, slot, stack = self:addObject(self:getInven(offslot), o)
		return added, stack
	elseif replace then -- no room but replacement is allowed
		local ro = self:takeoffObject(inven_id, force_item or 1)
		if not ro then return false end
		-- Check if we still can wear it, to prevent the replace-abuse
		local ok, err = self:canWearObject(o, inven.name)
		if not ok then
			if vocal then game.logSeen(self, "%s can not wear (%s): %s (%s).", self.name:capitalize(), self.inven_def[inven.name].name:lower(), o_name, err) end
			if ro then self:addObject(inven_id, ro, true, force_item) end
			return false
		end
		added, slot, stack = self:addObject(inven_id, o, nil, force_item)
		if vocal then game.logSeen(self, "%s wears (replacing %s): %s.", self.name:capitalize(), ro:getName{do_color=true}, o_name) end
		if stack and ro:stack(stack) then -- stack remaining stack with old if possible (ignores stack limits)
			stack = nil
		end
		return ro, stack -- caller handles the replaced object and remaining stack if any
	else
		if vocal then game.logSeen(self, "%s can not wear: %s.", self.name:capitalize(), o:getName{do_color=true}) end
		return false
	end
end

--- Takeoff item
-- @param inven_id = inventory id
-- @param item = slot to remove from
--  checks obj:on_cantakeoff(self, inven) (return true to prevent taking off)
function _M:takeoffObject(inven_id, item)
	inven = self:getInven(inven_id)
	if not inven then return false end

	local o = inven[item]
	if o:check("on_cantakeoff", self, inven) then return false end

	o = self:removeObject(inven, item, true)
	return o
end

--- Call when an object is worn
--  @param o = object being worn
--  @param inven_id = inventory id
--  checks o:on_wear(self, inven_id)
function _M:onWear(o, inven_id)
	-- Apply wielder properties
	o.wielded = {}
	o:check("on_wear", self, inven_id)
	if o.wielder then
		for k, e in pairs(o.wielder) do
			o.wielded[k] = self:addTemporaryValue(k, e)
		end
	end
end

--- Call when an object is taken off
--  @param o = object being taken off
--  @param inven_id = inventory id
--  checks o:on_takeoff(self, inven_id)
function _M:onTakeoff(o, inven_id)
	if o.wielded then
		for k, id in pairs(o.wielded) do
			if type(id) == "table" then
				self:removeTemporaryValue(id[1], id[2])
			else
				self:removeTemporaryValue(k, id)
			end
		end
	end
	o:check("on_takeoff", self, inven_id)
	o.wielded = nil
end

--- Re-order inventory, sorting and stacking it
-- sort order is type > subtype > name > getNumber()
function _M:sortInven(inven)
	if not inven then inven = self.inven[self.INVEN_INVEN] end
	inven = self:getInven(inven)
	if not inven then return end
--	local stacked, last, stacklimit = false, false, inven.stack_limit or math.huge
	local stacked, last, stacklimit = false, false, self:invenStackLimit(inven)

	-- First, stack objects from top
	for i = 1, #inven do
		if not inven[i] then break end
		-- If it is stackable, look for objects after it that can stack into it
		if inven[i]:stackable() then
			for j = #inven, i + 1, -1 do
			-- check stack limit
				stacked, last = inven[i]:stack(inven[j], false, stacklimit - inven[i]:getNumber())
				if stacked then
					if last then
						table.remove(inven, j)
					else
						break
					end
				end
			end
		end
	end

	-- Sort them
	table.sort(inven, function(a, b)
		local ta, tb = a:getTypeOrder(), b:getTypeOrder()
		local sa, sb = a:getSubtypeOrder(), b:getSubtypeOrder()
		if ta == tb then
			if sa == sb then
				if a.name == b.name then
					return a:getNumber() > b:getNumber()
				else
					return a.name < b.name
				end
			else
				return sa < sb
			end
		else
			return ta < tb
		end
	end)
	self.changed = true
end

--- Finds an object by name in an inventory
-- @param inven the inventory to look into
-- @param name the name to look for
-- @param getname the parameters to pass to getName(), if nil the default is {no_count=true, force_id=true}
-- @return object, position or nil if not found
function _M:findInInventory(inven, name, getname)
	getname = getname or {no_count=true, force_id=true}
	for item, o in ipairs(inven) do
		if o:getName(getname) == name then return o, item end
	end
end

--- Finds an object by name in all the actor's inventories
-- @param name the name to look for
-- @param getname the parameters to pass to getName(), if nil the default is {no_count=true, force_id=true}
-- @return object, position, inven_id or nil if not found
function _M:findInAllInventories(name, getname)
	for inven_id, inven in pairs(self.inven) do
		local o, item = self:findInInventory(inven, name, getname)
		if o and item then return o, item, inven_id end
	end
end

--- Finds an object by property in an inventory
-- @param inven the inventory to look into
-- @param prop the property to look for
-- @param value the value to look for, can be a function
-- @return object, position or nil if not found
function _M:findInInventoryBy(inven, prop, value)
	if type(value) == "function" then
		for item, o in ipairs(inven) do
			if value(o[prop]) then return o, item end
		end
	else
		for item, o in ipairs(inven) do
			if o[prop] == value then return o, item end
		end
	end
end

--- Finds an object by property in all the actor's inventories
-- @param prop the property to look for
-- @param value the value to look for, can be a function
-- @return object, position, inven_id or nil if not found
function _M:findInAllInventoriesBy(prop, value)
	for inven_id, inven in pairs(self.inven) do
		local o, item = self:findInInventoryBy(inven, prop, value)
		if o and item then return o, item, inven_id end
	end
end

--- Finds an object by reference in an inventory
-- @param inven the inventory to look into
-- @param so the object(reference) to look for
-- @return object, position or nil if not found
function _M:findInInventoryByObject(inven, so)
	for item, o in ipairs(inven) do
		if o == so then return o, item end
	end
end

--- Finds an object by reference in all the actor's inventories
-- @param inven the inventory to look into
-- @param so the object(reference) to look for
-- @return object, position, inven_id or nil if not found
function _M:findInAllInventoriesByObject(so)
	for inven_id, inven in pairs(self.inven) do
		local o, item = self:findInInventoryByObject(inven, so)
		if o and item then return o, item, inven_id end
	end
end

--- Applies fct over all items
-- @param inven the inventory to look into
-- @param fct the function to be called. It will receive three parameters: inven, item, object
function _M:inventoryApply(inven, fct)
	for item, o in ipairs(inven) do
		fct(inven, item, o)
	end
end

--- Applies fct over all items in all inventories
-- @param inven the inventory to look into
-- @param fct the function to be called. It will receive three parameters: inven, item, object
function _M:inventoryApplyAll(fct)
	for inven_id, inven in pairs(self.inven) do
		self:inventoryApply(inven, fct)
	end
end

--- Empties given inventory and marks items inside as never generated
function _M:forgetInven(inven)
	inven = self:getInven(inven)
	if not inven then return end

	for i = #inven, 1, -1 do
		local o = inven[i]

		self:removeObject(inven, i, true)
		o:removed()
	end
end
