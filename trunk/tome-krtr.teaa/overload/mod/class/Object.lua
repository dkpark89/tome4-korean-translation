-- ToME - Tales of Maj'Eyal
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

-- TODO: Update prices

require "engine.class"
require "engine.Object"
require "engine.interface.ObjectActivable"
require "engine.interface.ObjectIdentify"

local Stats = require("engine.interface.ActorStats")
local Talents = require("engine.interface.ActorTalents")
local DamageType = require("engine.DamageType")

module(..., package.seeall, class.inherit(
	engine.Object,
	engine.interface.ObjectActivable,
	engine.interface.ObjectIdentify,
	engine.interface.ActorTalents
))

_M.projectile_class = "mod.class.Projectile"

function _M:init(t, no_default)
	t.encumber = t.encumber or 0

	engine.Object.init(self, t, no_default)
	engine.interface.ObjectActivable.init(self, t)
	engine.interface.ObjectIdentify.init(self, t)
	engine.interface.ActorTalents.init(self, t)
end

--- Can this object act at all
-- Most object will want to answer false, only recharging and stuff needs them
function _M:canAct()
	if (self.power_regen or self.use_talent or self.sentient) and not self.talent_cooldown then return true end
	return false
end

--- Do something when its your turn
-- For objects this mostly is to recharge them
-- By default, does nothing at all
function _M:act()
	self:regenPower()
	self:cooldownTalents()
	self:useEnergy()
end

--- Use the object (quaff, read, ...)
function _M:use(who, typ, inven, item)
	inven = who:getInven(inven)

	if self.use_no_blind and who:attr("blind") then
		game.logPlayer(who, "You cannot see!")
		return
	end
	if self.use_no_silence and who:attr("silence") then
		game.logPlayer(who, "You are silenced!")
		return
	end
	if self:wornInven() and not self.wielded and not self.use_no_wear then
		game.logPlayer(who, "You must wear this object to use it!")
		return
	end
	if who:hasEffect(self.EFF_UNSTOPPABLE) then
		game.logPlayer(who, "You can not use items during a battle frenzy!")
		return
	end

	local types = {}
	if self:canUseObject() then types[#types+1] = "use" end

	if not typ and #types == 1 then typ = types[1] end

	if typ == "use" then
		local ret = self:useObject(who, inven, item)
		if ret.used then
			if self.charm_on_use then
				for fct, d in pairs(self.charm_on_use) do
					if rng.percent(d[1]) then fct(self, who) end
				end
			end

			if self.use_sound then game:playSoundNear(who, self.use_sound) end
			if not self.use_no_energy then
				who:useEnergy(game.energy_to_act * (inven.use_speed or 1))
			end
		end
		return ret
	end
end

--- Returns a tooltip for the object
function _M:tooltip(x, y)
	local str = self:getDesc({do_color=true}, game.player:getInven(self:wornInven()))
	if config.settings.cheat then str:add(true, "UID: "..self.uid, true, self.image) end
	local nb = game.level.map:getObjectTotal(x, y)
	if nb == 2 then str:add(true, "---", true, "You see one more object.")
	elseif nb > 2 then str:add(true, "---", true, "You see "..(nb-1).." more objects.")
	end
	return str
end

--- Describes an attribute, to expand object name
function _M:descAttribute(attr)
	if attr == "MASTERY" then
		local tms = {}
		for ttn, i in pairs(self.wielder.talents_types_mastery) do
			local tt = Talents.talents_types_def[ttn]
			local cat = tt.type:gsub("/.*", "")
			local name = cat:capitalize().." / "..tt.name:capitalize()
			tms[#tms+1] = ("%0.2f %s"):format(i, name)
		end
		return table.concat(tms, ",")
	elseif attr == "STATBONUS" then
		local stat, i = next(self.wielder.inc_stats)
		return i > 0 and "+"..i or tostring(i)
	elseif attr == "DAMBONUS" then
		local stat, i = next(self.wielder.inc_damage)
		return (i > 0 and "+"..i or tostring(i)).."%"
	elseif attr == "RESIST" then
		local stat, i = next(self.wielder.resists)
		return (i and i > 0 and "+"..i or tostring(i)).."%"
	elseif attr == "REGEN" then
		local i = self.wielder.mana_regen or self.wielder.stamina_regen or self.wielder.life_regen or self.wielder.hate_regen or self.wielder.positive_regen
		return ("%s%0.2f/turn"):format(i > 0 and "+" or "-", math.abs(i))
	elseif attr == "COMBAT" then
		local c = self.combat
		return c.dam.."-"..(c.dam*(c.damrange or 1.1)).." power, "..(c.apr or 0).." apr"
	elseif attr == "COMBAT_AMMO" then
		local c = self.combat
		return c.shots_left.."/"..math.floor(c.capacity)..", "..c.dam.."-"..(c.dam*(c.damrange or 1.1)).." power, "..(c.apr or 0).." apr"
	elseif attr == "COMBAT_DAMTYPE" then
		local c = self.combat
		return c.dam.."-"..(c.dam*(c.damrange or 1.1)).." power, "..(c.apr or 0).." apr, "..DamageType:get(c.damtype).name.." damage"
	elseif attr == "SHIELD" then
		local c = self.special_combat
		if c and (game.player:knowTalentType("technique/shield-offense") or game.player:knowTalentType("technique/shield-defense") or game.player:attr("show_shield_combat")) then
			return c.dam.." dam, "..c.block.." block"
		else
			return c.block.." block"
		end
	elseif attr == "ARMOR" then
		return (self.wielder and self.wielder.combat_def or 0).." def, "..(self.wielder and self.wielder.combat_armor or 0).." armour"
	elseif attr == "ATTACK" then
		return (self.wielder and self.wielder.combat_atk or 0).." accuracy, "..(self.wielder and self.wielder.combat_apr or 0).." apr, "..(self.wielder and self.wielder.combat_dam or 0).." power"
	elseif attr == "MONEY" then
		return ("worth %0.2f"):format(self.money_value / 10)
	elseif attr == "USE_TALENT" then
		return self:getTalentFromId(self.use_talent.id).name:lower()
	elseif attr == "DIGSPEED" then
		return ("dig speed %d turns"):format(self.digspeed)
	elseif attr == "CHARM" then
		return (" [power %d]"):format(self:getCharmPower())
	elseif attr == "CHARGES" then
		if self.talent_cooldown and (self.use_power or self.use_talent) then
			local cd = game.player.talents_cd[self.talent_cooldown]
			if cd and cd > 0 then
				return " ("..cd.."/"..(self.use_power or self.use_talent).power.." cooldown)"
			else
				return " ("..(self.use_power or self.use_talent).power.." cooldown)"
			end
		elseif self.use_power or self.use_talent then
			return (" (%d/%d)"):format(math.floor(self.power / (self.use_power or self.use_talent).power), math.floor(self.max_power / (self.use_power or self.use_talent).power))
		else
			return ""
		end
	elseif attr == "INSCRIPTION" then
		game.player.__inscription_data_fake = self.inscription_data
		local t = self:getTalentFromId("T_"..self.inscription_talent.."_1")
		local desc = t.short_info(game.player, t)
		game.player.__inscription_data_fake = nil
		return ("%s"):format(desc)
	end
end

--- Gets the "power rank" of an object
-- Possible values are 0 (normal, lore), 1 (ego), 2 (greater ego), 3 (artifact)
function _M:getPowerRank()
	if self.godslayer then return 10 end
	if self.unique then return 3 end
	if self.egoed and self.greater_ego then return 2 end
	if self.egoed or self.rare then return 1 end
	return 0
end

--- Gets the color in which to display the object in lists
function _M:getDisplayColor()
	if not self:isIdentified() then return {180, 180, 180}, "#B4B4B4#" end
	if self.lore then return {0, 128, 255}, "#0080FF#"
	elseif self.unique then
		if self.randart then
			return {255, 0x77, 0}, "#FF7700#"
		elseif self.godslayer then
			return {0xAA, 0xD5, 0x00}, "#AAD500#"
		else
			return {255, 215, 0}, "#FFD700#"
		end
	elseif self.rare then
		return {250, 128, 114}, "#SALMON#"
	elseif self.egoed then
		if self.greater_ego then
			if self.greater_ego > 1 then
				return {0x8d, 0x55, 0xff}, "#8d55ff#"
			else
				return {0, 0x80, 255}, "#0080FF#"
			end
		else
			return {0, 255, 128}, "#00FF80#"
		end
	else return {255, 255, 255}, "#FFFFFF#"
	end
end

--- Gets the full name of the object
function _M:getName(t)
	t = t or {}
	local qty = self:getNumber()
	local name = self.name

	if not self:isIdentified() and not t.force_id and self:getUnidentifiedName() then name = self:getUnidentifiedName() end

	-- To extend later
	name = name:gsub("~", ""):gsub("&", "a"):gsub("#([^#]+)#", function(attr)
		return self:descAttribute(attr)
	end)

	if not t.no_add_name and self.add_name and self:isIdentified() then
		name = name .. self.add_name:gsub("#([^#]+)#", function(attr)
			return self:descAttribute(attr)
		end)
	end

	if not t.do_color then
		if qty == 1 or t.no_count then return name
		else return qty.." "..name
		end
	else
		local _, c = self:getDisplayColor()
		local ds = t.no_image and "" or self:getDisplayString()
		if qty == 1 or t.no_count then return c..ds..name.."#LAST#"
		else return c..qty.." "..ds..name.."#LAST#"
		end
	end
end

--- Gets the short name of the object
function _M:getShortName(t)
	if not self.short_name then return self:getName(t) end

	t = t or {}
	local qty = self:getNumber()
	local name = self.short_name

	if not self:isIdentified() and not t.force_id and self:getUnidentifiedName() then name = self:getUnidentifiedName() end

	if self.keywords and next(self.keywords) then
		local k = table.keys(self.keywords)
		table.sort(k)
		name = name..","..table.concat(k, ',')
	end

	if not t.do_color then
		if qty == 1 or t.no_count then return name
		else return qty.." "..name
		end
	else
		local _, c = self:getDisplayColor()
		local ds = t.no_image and "" or self:getDisplayString()
		if qty == 1 or t.no_count then return c..ds..name.."#LAST#"
		else return c..qty.." "..ds..name.."#LAST#"
		end
	end
end

--- Gets the full textual desc of the object without the name and requirements
function _M:getTextualDesc(compare_with)
	compare_with = compare_with or {}
	local desc = tstring{}

	if self.quest then desc:add({"color", "VIOLET"},"[Plot Item]", {"color", "LAST"}, true) end

	desc:add(("Type: %s / %s"):format(rawget(self, 'type') or "unknown", rawget(self, 'subtype') or "unknown"))
	if self.material_level then desc:add(" ; tier ", tostring(self.material_level)) end
	desc:add(true)
	if self.slot_forbid == "OFFHAND" then desc:add("It must be held with both hands.", true) end
	desc:add(true)

	if self.set_list then
		desc:add({"color","GREEN"}, "It is part of a set of items.", {"color","LAST"}, true)
		if self.set_complete then desc:add({"color","LIGHT_GREEN"}, "The set is complete.", {"color","LAST"}, true) end
	end

	-- Stop here if unided
	if not self:isIdentified() then return desc end

	local compare_fields = function(item1, items, infield, field, outformat, text, mod, isinversed, isdiffinversed, add_table)
		add_table = add_table or {}
		mod = mod or 1
		isinversed = isinversed or false
		isdiffinversed = isdiffinversed or false
		local ret = tstring{}
		local added = 0
		local add = false
		ret:add(text)
		if isinversed then
			ret:add(((item1[field] or 0) + (add_table[field] or 0)) > 0 and {"color","RED"} or {"color","LIGHT_GREEN"}, outformat:format(((item1[field] or 0) + (add_table[field] or 0)) * mod), {"color", "LAST"})
		else
			ret:add(((item1[field] or 0) + (add_table[field] or 0)) < 0 and {"color","RED"} or {"color","LIGHT_GREEN"}, outformat:format(((item1[field] or 0) + (add_table[field] or 0)) * mod), {"color", "LAST"})
		end
		if item1[field] then
			add = true
		end
		for i=1, #items do
			if items[i][infield] and items[i][infield][field] then
				if added == 0 then
					ret:add(" (")
				elseif added > 1 then
					ret:add(" / ")
				end
				added = added + 1
				add = true
				if items[i][infield][field] ~= (item1[field] or 0) then
					if isdiffinversed then
						ret:add(items[i][infield][field] < (item1[field] or 0) and {"color","RED"} or {"color","LIGHT_GREEN"}, outformat:format(((item1[field] or 0) - items[i][infield][field]) * mod), {"color", "LAST"})
					else
						ret:add(items[i][infield][field] > (item1[field] or 0) and {"color","RED"} or {"color","LIGHT_GREEN"}, outformat:format(((item1[field] or 0) - items[i][infield][field]) * mod), {"color", "LAST"})
					end
				else
					ret:add("-")
				end
			end
		end
		if added > 0 then
			ret:add(")")
		end
		if add then
			desc:merge(ret)
			desc:add(true)
		end
	end

	local compare_table_fields = function(item1, items, infield, field, outformat, text, kfunct, mod, isinversed)
		mod = mod or 1
		isinversed = isinversed or false
		local ret = tstring{}
		local added = 0
		local add = false
		ret:add(text)
		local tab = {}
		if item1[field] then
			for k, v in pairs(item1[field]) do
				tab[k] = {}
				tab[k][1] = v
			end
		end
		for i=1, #items do
			if items[i][infield] and items[i][infield][field] then
				for k, v in pairs(items[i][infield][field]) do
					tab[k] = tab[k] or {}
					tab[k][i + 1] = v
				end
			end
		end
		local count1 = 0
		for k, v in pairs(tab) do
			local count = 0
			if isinversed then
				ret:add(("%s"):format((count1 > 0) and " / " or ""), (v[1] or 0) > 0 and {"color","RED"} or {"color","LIGHT_GREEN"}, outformat:format((v[1] or 0)), {"color","LAST"})
			else
				ret:add(("%s"):format((count1 > 0) and " / " or ""), (v[1] or 0) < 0 and {"color","RED"} or {"color","LIGHT_GREEN"}, outformat:format((v[1] or 0)), {"color","LAST"})
			end
			count1 = count1 + 1
			if v[1] then
				add = true
			end
			for kk, vv in pairs(v) do
				if kk > 1 then
					if count == 0 then
						ret:add("(")
					elseif count > 0 then
						ret:add(" / ")
					end
					if vv ~= (v[1] or 0) then
						if isinversed then
							ret:add((v[1] or 0) > vv and {"color","RED"} or {"color","LIGHT_GREEN"}, outformat:format((v[1] or 0) - vv), {"color","LAST"})
						else
							ret:add((v[1] or 0) < vv and {"color","RED"} or {"color","LIGHT_GREEN"}, outformat:format((v[1] or 0) - vv), {"color","LAST"})
						end
					else
						ret:add("-")
					end
					add = true
					count = count + 1
				end
			end
			if count > 0 then
				ret:add(")")
			end
			ret:add(kfunct(k))
		end

		if add then
			desc:merge(ret)
			desc:add(true)
		end
	end

	local desc_combat = function(combat, compare_with, field, add_table)
		add_table = add_table or {}
		add_table.dammod = add_table.dammod or {}
		combat = combat[field] or {}
		compare_with = compare_with or {}
		local dm = {}
		for stat, i in pairs(combat.dammod or {}) do
			dm[#dm+1] = ("%d%% %s"):format((i + (add_table.dammod[stat] or 0)) * 100, Stats.stats_def[stat].short_name:capitalize())
		end
		if #dm > 0 or combat.dam then
			local power_diff = ""
			local diff_count = 0
			local any_diff = false
			for i, v in ipairs(compare_with) do
				if v[field] then
					local base_power_diff = ((combat.dam or 0) + (add_table.dam or 0)) - ((v[field].dam or 0) + (add_table.dam or 0))
					local multi_diff = (((combat.damrange or 1.1) + (add_table.damrange or 0)) * ((combat.dam or 0) + (add_table.dam or 0))) - (((v[field].damrange or (1.1 - (add_table.damrange or 0))) + (add_table.damrange or 0)) * ((v[field].dam or 0) + (add_table.dam or 0)))
					power_diff = power_diff..("%s%s%+.1f#LAST# - %s%+.1f#LAST#"):format(diff_count > 0 and " / " or "", base_power_diff > 0 and "#00ff00#" or "#ff0000#", base_power_diff, multi_diff > 0 and "#00ff00#" or "#ff0000#", multi_diff)
					diff_count = diff_count + 1
					if base_power_diff ~= 0 or multi_diff ~= 0 then
						any_diff = true
					end
				end
			end
			if any_diff == false then
				power_diff = ""
			else
				power_diff = ("(%s)"):format(power_diff)
			end
			desc:add(("Base power: %.1f - %.1f"):format((combat.dam or 0) + (add_table.dam or 0), ((combat.damrange or (1.1 - (add_table.damrange or 0))) + (add_table.damrange or 0)) * ((combat.dam or 0) + (add_table.dam or 0))))
			desc:merge(power_diff:toTString())
			desc:add(true)
			desc:add(("Uses stat%s: %s"):format(#dm > 1 and "s" or "",table.concat(dm, ', ')), true)
			local col = (combat.damtype and DamageType:get(combat.damtype) and DamageType:get(combat.damtype).text_color or "#WHITE#"):toTString()
			desc:add("Damage type: ", col[2],DamageType:get(combat.damtype or DamageType.PHYSICAL).name:capitalize(),{"color","LAST"}, true)
		end

		if combat.wil_attack then
			desc:add("Accuracy is based on willpower for this weapon.", true)
		end

		compare_fields(combat, compare_with, field, "atk", "%+d", "Accuracy: ", 1, false, false, add_table)
		compare_fields(combat, compare_with, field, "apr", "%+d", "Armour Penetration: ", 1, false, false, add_table)
		compare_fields(combat, compare_with, field, "physcrit", "%+.1f%%", "Physical crit. chance: ", 1, false, false, add_table)
		compare_fields(combat, compare_with, field, "physspeed", "%.0f%%", "Attack speed: ", 100, false, true, add_table)

		compare_fields(combat, compare_with, field, "block", "%+d", "Block value: ", 1, false, true, add_table)

		compare_fields(combat, compare_with, field, "range", "%+d", "Firing range: ", 1, false, false, add_table)
		compare_fields(combat, compare_with, field, "capacity", "%d", "Capacity: ", 1, false, false, add_table)
		compare_fields(combat, compare_with, field, "shots_reloaded_per_turn", "%+d", "Reload speed: ", 1, false, false, add_table)
		compare_fields(combat, compare_with, field, "ammo_every", "%d", "Turns elapse between self-loadings: ", 1, false, false, add_table)

		local talents = {}
		if combat.talent_on_hit then
			for tid, data in pairs(combat.talent_on_hit) do
				talents[tid] = {data.chance, data.level}
			end
		end
		for i, v in ipairs(compare_with or {}) do
			for tid, data in pairs(v[field] and (v[field].talent_on_hit or {})or {}) do
				if not talents[tid] or talents[tid][1]~=data.chance or talents[tid][2]~=data.level then
					desc:add({"color","RED"}, ("When this weapon hits: %s (%d%% chance level %d)."):format(self:getTalentFromId(tid).name, data.chance, data.level), {"color","LAST"}, true)
				else
					talents[tid][3] = true
				end
			end
		end
		for tid, data in pairs(talents) do
			desc:add(talents[tid][3] and {"color","WHITE"} or {"color","GREEN"}, ("When this weapon hits: %s (%d%% chance level %d)."):format(self:getTalentFromId(tid).name, talents[tid][1], talents[tid][2]), {"color","LAST"}, true)
		end

		local special = ""
		if combat.special_on_hit then
			special = combat.special_on_hit.desc
		end
		local found = false
		for i, v in ipairs(compare_with or {}) do
			if v[field] and v[field].special_on_hit then
				if special ~= v[field].special_on_hit.desc then
					desc:add({"color","RED"}, "Special effect when this weapon hits: "..v[field].special_on_hit.desc, {"color","LAST"}, true)
				else
					found = true
				end
			end
		end
		if special ~= "" then
			desc:add(found and {"color","WHITE"} or {"color","GREEN"}, "Special effect when this weapon hits: "..special, {"color","LAST"}, true)
		end

		special = ""
		if combat.special_on_crit then
			special = combat.special_on_crit.desc
		end
		found = false
		for i, v in ipairs(compare_with or {}) do
			if v[field] and v[field].special_on_crit then
				if special ~= v[field].special_on_crit.desc then
					desc:add({"color","RED"}, "Special effect when this weapon crits: "..v[field].special_on_crit.desc, {"color","LAST"}, true)
				else
					found = true
				end
			end
		end
		if special ~= "" then
			desc:add(found and {"color","WHITE"} or {"color","GREEN"}, "Special effect when this weapon crits: "..special, {"color","LAST"}, true)
		end

		local special = ""
		if combat.special_on_kill then
			special = combat.special_on_kill.desc
		end
		local found = false
		for i, v in ipairs(compare_with or {}) do
			if v[field] and v[field].special_on_kill then
				if special ~= v[field].special_on_kill.desc then
					desc:add({"color","RED"}, "Special effect when this weapon kills: "..v[field].special_on_kill.desc, {"color","LAST"}, true)
				else
					found = true
				end
			end
		end
		if special ~= "" then
			desc:add(found and {"color","WHITE"} or {"color","GREEN"}, "Special effect when this weapon kills: "..special, {"color","LAST"}, true)
		end

		found = false
		for i, v in ipairs(compare_with or {}) do
			if v[field] and v[field].no_stealth_break then
				found = true
			end
		end

		if combat.no_stealth_break then
			desc:add(found and {"color","WHITE"} or {"color","GREEN"},"When used from stealth a simple attack with it will not break stealth.", {"color","LAST"}, true)
		elseif found then
			desc:add({"color","RED"}, "When used from stealth a simple attack with it will not break stealth.", {"color","LAST"}, true)
		end

		compare_fields(combat, compare_with, field, "travel_speed", "%+d%%", "Travel speed: ", 100, false, false, add_table)

		compare_fields(combat, compare_with, field, "phasing", "%+d%%", "Damage Shield penetration (this weapon only): ", 1, false, false, add_table)

		if combat.tg_type and combat.tg_type == "beam" then
			desc:add({"color","YELLOW"}, ("Shots beam through all targets."), {"color","LAST"}, true)
		end

		compare_table_fields(combat, compare_with, field, "melee_project", "%+d", "Damage when this weapon hits: ", function(item)
				local col = (DamageType.dam_def[item] and DamageType.dam_def[item].text_color or "#WHITE#"):toTString()
				return col[2], (" %s"):format(DamageType.dam_def[item].name),{"color","LAST"}
			end)

		compare_table_fields(combat, compare_with, field, "ranged_project", "%+d", "Damage when this weapon hits(ranged): ", function(item)
				local col = (DamageType.dam_def[item] and DamageType.dam_def[item].text_color or "#WHITE#"):toTString()
				return col[2], (" %s"):format(DamageType.dam_def[item].name),{"color","LAST"}
			end)

		compare_table_fields(combat, compare_with, field, "burst_on_hit", "%+d", "Burst (radius 1) on hit: ", function(item)
				local col = (DamageType.dam_def[item] and DamageType.dam_def[item].text_color or "#WHITE#"):toTString()
				return col[2], (" %s"):format(DamageType.dam_def[item].name),{"color","LAST"}
			end)

		compare_table_fields(combat, compare_with, field, "burst_on_crit", "%+d", "Burst (radius 2) on crit: ", function(item)
				local col = (DamageType.dam_def[item] and DamageType.dam_def[item].text_color or "#WHITE#"):toTString()
				return col[2], (" %s"):format(DamageType.dam_def[item].name),{"color","LAST"}
			end)

		compare_table_fields(combat, compare_with, field, "convert_damage", "%d%%", "Damage conversion: ", function(item)
				local col = (DamageType.dam_def[item] and DamageType.dam_def[item].text_color or "#WHITE#"):toTString()
				return col[2], (" %s"):format(DamageType.dam_def[item].name),{"color","LAST"}
			end)

		compare_table_fields(combat, compare_with, field, "inc_damage_type", "%+d%% ", "Damage against: ", function(item)
				local _, _, t, st = item:find("^([^/]+)/?(.*)$")
				if st and st ~= "" then
					return st:capitalize()
				else
					return t:capitalize()
				end
			end)

		self:triggerHook{"Object:descCombat", compare_with=compare_with, compare_fields=compare_fields, compare_table_fields=compare_table_fields, desc=desc, combat=combat}
	end

	local desc_wielder = function(w, compare_with, field)
		w = w or {}
		w = w[field] or {}
		compare_fields(w, compare_with, field, "combat_atk", "%+d", "Accuracy: ")
		compare_fields(w, compare_with, field, "combat_apr", "%+d", "Armour penetration: ")
		compare_fields(w, compare_with, field, "combat_physcrit", "%+.1f%%", "Physical crit. chance: ")
		compare_fields(w, compare_with, field, "combat_dam", "%+d", "Physical power: ")

		compare_fields(w, compare_with, field, "combat_armor", "%+d", "Armour: ")
		compare_fields(w, compare_with, field, "combat_armor_hardiness", "%+d%%", "Armour Hardiness: ")
		compare_fields(w, compare_with, field, "combat_def", "%+d", "Defense: ")
		compare_fields(w, compare_with, field, "combat_def_ranged", "%+d", "Ranged Defense: ")

		compare_fields(w, compare_with, field, "fatigue", "%+d%%", "Fatigue: ", 1, true, true)

		compare_fields(w, compare_with, field, "ammo_reload_speed", "%+d", "Ammo reloads per turns: ")

		compare_table_fields(w, compare_with, field, "inc_stats", "%+d", "Changes stats: ", function(item)
				return (" %s"):format(Stats.stats_def[item].short_name:capitalize())
			end)

		compare_table_fields(w, compare_with, field, "melee_project", "%d", "Damage when the wearer hits(melee): ", function(item)
				local col = (DamageType.dam_def[item] and DamageType.dam_def[item].text_color or "#WHITE#"):toTString()
				return col[2],(" %s"):format(DamageType.dam_def[item].name),{"color","LAST"}
			end)

		compare_table_fields(w, compare_with, field, "ranged_project", "%d", "Damage when the wearer hits(ranged): ", function(item)
				local col = (DamageType.dam_def[item] and DamageType.dam_def[item].text_color or "#WHITE#"):toTString()
				return col[2],(" %s"):format(DamageType.dam_def[item].name),{"color","LAST"}
			end)

		compare_table_fields(w, compare_with, field, "on_melee_hit", "%d", "Damage when the wearer is hit: ", function(item)
				local col = (DamageType.dam_def[item] and DamageType.dam_def[item].text_color or "#WHITE#"):toTString()
				return col[2],(" %s"):format(DamageType.dam_def[item].name),{"color","LAST"}
			end)

		compare_table_fields(w, compare_with, field, "resists", "%+d%%", "Changes resistances: ", function(item)
				local col = (DamageType.dam_def[item] and DamageType.dam_def[item].text_color or "#WHITE#"):toTString()
				return col[2], (" %s"):format(item == "all" and "all" or DamageType.dam_def[item].name), {"color","LAST"}
			end)

		compare_table_fields(w, compare_with, field, "resists_cap", "%+d%%", "Changes resistances cap: ", function(item)
				local col = (DamageType.dam_def[item] and DamageType.dam_def[item].text_color or "#WHITE#"):toTString()
				return col[2], (" %s"):format(item == "all" and "all" or DamageType.dam_def[item].name), {"color","LAST"}
			end)

		compare_table_fields(w, compare_with, field, "wards", "%+d", "Maximum wards: ", function(item)
				local col = (DamageType.dam_def[item] and DamageType.dam_def[item].text_color or "#WHITE#"):toTString()
				return col[2], (" %s"):format(item == "all" and "all" or DamageType.dam_def[item].name), {"color","LAST"}
			end)

		compare_table_fields(w, compare_with, field, "resists_pen", "%+d%%", "Changes resistances penetration: ", function(item)
				local col = (DamageType.dam_def[item] and DamageType.dam_def[item].text_color or "#WHITE#"):toTString()
				return col[2], (" %s"):format(item == "all" and "all" or DamageType.dam_def[item].name), {"color","LAST"}
			end)

		compare_table_fields(w, compare_with, field, "inc_damage", "%+d%%", "Changes damage: ", function(item)
				local col = (DamageType.dam_def[item] and DamageType.dam_def[item].text_color or "#WHITE#"):toTString()
				return col[2], (" %s"):format(item == "all" and "all" or DamageType.dam_def[item].name), {"color","LAST"}
			end)

		compare_table_fields(w, compare_with, field, "damage_affinity", "%+d%%", "Damage affinity(heal): ", function(item)
				local col = (DamageType.dam_def[item] and DamageType.dam_def[item].text_color or "#WHITE#"):toTString()
				return col[2], (" %s"):format(item == "all" and "all" or DamageType.dam_def[item].name), {"color","LAST"}
			end)

		compare_fields(w, compare_with, field, "esp_range", "%+d", "Change telepathy range by : ")

		local any_esp = false
		local esps_compare = {}
		for i, v in ipairs(compare_with or {}) do
			if v[field] and v[field].esp_all then
				esps_compare["All"] = esps_compare["All"] or {}
				esps_compare["All"][1] = true
				any_esp = true
			end
			for type, i in pairs(v[field] and (v[field].esp or {}) or {}) do
				local _, _, t, st = type:find("^([^/]+)/?(.*)$")
				local esp = ""
				if st and st ~= "" then
					esp = t:capitalize().."/"..st:capitalize()
				else
					esp = t:capitalize()
				end
				esps_compare[esp] = esps_compare[esp] or {}
				esps_compare[esp][1] = true
				any_esp = true
			end
		end

		local esps = {}
		if w.esp_all then
			esps[#esps+1] = "All"
			esps_compare[esps[#esps]] = esps_compare[esps[#esps]] or {}
			esps_compare[esps[#esps]][2] = true
			any_esp = true
		end
		for type, i in pairs(w.esp or {}) do
			local _, _, t, st = type:find("^([^/]+)/?(.*)$")
			if st and st ~= "" then
				esps[#esps+1] = t:capitalize().."/"..st:capitalize()
			else
				esps[#esps+1] = t:capitalize()
			end
			esps_compare[esps[#esps]] = esps_compare[esps[#esps]] or {}
			esps_compare[esps[#esps]][2] = true
			any_esp = true
		end
		if any_esp then
			desc:add("Grants telepathy: ")
			for esp, isin in pairs(esps_compare) do
				if isin[2] then
					desc:add(isin[1] and {"color","WHITE"} or {"color","GREEN"}, ("%s "):format(esp), {"color","LAST"})
				else
					desc:add({"color","RED"}, ("%s "):format(esp), {"color","LAST"})
				end
			end
			desc:add(true)
		end

		local any_mastery = 0
		local masteries = {}
		for i, v in ipairs(compare_with or {}) do
			if v[field] and v[field].talents_types_mastery then
				for ttn, mastery in pairs(v[field].talents_types_mastery) do
					masteries[ttn] = masteries[ttn] or {}
					masteries[ttn][1] = mastery
					any_mastery = any_mastery + 1
				end
			end
		end
		for ttn, i in pairs(w.talents_types_mastery or {}) do
			masteries[ttn] = masteries[ttn] or {}
			masteries[ttn][2] = i
			any_mastery = any_mastery + 1
		end
		if any_mastery > 0 then
			desc:add(("Talent master%s: "):format(any_mastery > 1 and "ies" or "y"))
			for ttn, ttid in pairs(masteries) do
				local tt = Talents.talents_types_def[ttn]
				local cat = tt.type:gsub("/.*", "")
				local name = cat:capitalize().." / "..tt.name:capitalize()
				local diff = (ttid[2] or 0) - (ttid[1] or 0)
				if diff ~= 0 then
					if ttid[1] then
						desc:add(("%+.2f"):format(ttid[2] or 0), diff < 0 and {"color","RED"} or {"color","LIGHT_GREEN"}, ("(%+.2f) "):format(diff), {"color","LAST"}, ("%s "):format(name))
					else
						desc:add({"color","LIGHT_GREEN"}, ("%+.2f"):format(ttid[2] or 0),  {"color","LAST"}, (" %s "):format(name))
					end
				else
					desc:add({"color","WHITE"}, ("%+.2f(-) %s "):format(ttid[2] or ttid[1], name), {"color","LAST"})
				end
			end
			desc:add(true)
		end

		local any_cd_reduction = 0
		local cd_reductions = {}
		for i, v in ipairs(compare_with or {}) do
			if v[field] and v[field].talent_cd_reduction then
				for tid, cd in pairs(v[field].talent_cd_reduction) do
					cd_reductions[tid] = cd_reductions[tid] or {}
					cd_reductions[tid][1] = cd
					any_cd_reduction = any_cd_reduction + 1
				end
			end
		end
		for tid, cd in pairs(w.talent_cd_reduction or {}) do
			cd_reductions[tid] = cd_reductions[tid] or {}
			cd_reductions[tid][2] = cd
			any_cd_reduction = any_cd_reduction + 1
		end
		if any_cd_reduction > 0 then
			desc:add(("Talent%s cooldown:"):format(any_cd_reduction > 1 and "s" or ""))
			for tid, cds in pairs(cd_reductions) do
				local diff = (cds[2] or 0) - (cds[1] or 0)
				if diff ~= 0 then
					if cds[1] then
						desc:add((" %s ("):format(Talents.talents_def[tid].name), ("(%+d"):format(-(cds[2] or 0)), diff < 0 and {"color","RED"} or {"color","LIGHT_GREEN"}, ("(%+d) "):format(-diff), {"color","LAST"}, ("turn%s)"):format(((cds[2] or 0) > 1) and "s" or ""))
					else
						desc:add((" %s ("):format(Talents.talents_def[tid].name), {"color","LIGHT_GREEN"}, ("%+d"):format(-(cds[2] or 0)), {"color","LAST"}, (" turn%s)"):format((cds[2] > 1) and "s" or ""))
					end
				else
					desc:add({"color","WHITE"}, (" %s (%+d(-) turn%s)"):format(Talents.talents_def[tid].name, -(cds[2] or cds[1]), ((cds[2] or 0) > 1) and "s" or ""), {"color","LAST"})
				end
			end
			desc:add(true)
		end

		-- Display learned talents
		local any_learn_talent = 0
		local learn_talents = {}
		for i, v in ipairs(compare_with or {}) do
			if v[field] and v[field].learn_talent then
				for tid, tl in pairs(v[field].learn_talent) do
					learn_talents[tid] = learn_talents[tid] or {}
					learn_talents[tid][1] = tl
					any_learn_talent = any_learn_talent + 1
				end
			end
		end
		for tid, tl in pairs(w.learn_talent or {}) do
			learn_talents[tid] = learn_talents[tid] or {}
			learn_talents[tid][2] = tl
			any_learn_talent = any_learn_talent + 1
		end
		if any_learn_talent > 0 then
			desc:add(("Talent%s granted: "):format(any_learn_talent > 1 and "s" or ""))
			for tid, tl in pairs(learn_talents) do
				local diff = (tl[2] or 0) - (tl[1] or 0)
				local name = Talents.talents_def[tid].name
				if diff ~= 0 then
					if tl[1] then
						desc:add(("+%d"):format(tl[2] or 0), diff < 0 and {"color","RED"} or {"color","LIGHT_GREEN"}, ("(+%d) "):format(diff), {"color","LAST"}, ("%s "):format(name))
					else
						desc:add({"color","LIGHT_GREEN"}, ("+%d"):format(tl[2] or 0),  {"color","LAST"}, (" %s "):format(name))
					end
				else
					desc:add({"color","WHITE"}, ("%+.2f(-) %s "):format(tl[2] or tl[1], name), {"color","LAST"})
				end
			end
			desc:add(true)
		end

		local any_breath = 0
		local breaths = {}
		for i, v in ipairs(compare_with or {}) do
			if v[field] and v[field].can_breath then
				for what, _ in pairs(v[field].can_breath) do
					breaths[what] = breaths[what] or {}
					breaths[what][1] = true
					any_breath = any_breath + 1
				end
			end
		end
		for what, _ in pairs(w.can_breath or {}) do
			breaths[what] = breaths[what] or {}
			breaths[what][2] = true
			any_breath = any_breath + 1
		end
		if any_breath > 0 then
			desc:add("Allows you to breathe in: ")
			for what, isin in pairs(breaths) do
				if isin[2] then
					desc:add(isin[1] and {"color","WHITE"} or {"color","GREEN"}, ("%s "):format(what), {"color","LAST"})
				else
					desc:add({"color","RED"}, ("%s "):format(what), {"color","LAST"})
				end
			end
			desc:add(true)
		end

		compare_fields(w, compare_with, field, "combat_critical_power", "%+.2f%%", "Critical mult.: ")
		compare_fields(w, compare_with, field, "combat_crit_reduction", "%-d%%", "Reduces opponents crit chance: ")

		compare_fields(w, compare_with, field, "disarm_bonus", "%+d", "Trap disarming bonus: ")
		compare_fields(w, compare_with, field, "inc_stealth", "%+d", "Stealth bonus: ")
		compare_fields(w, compare_with, field, "max_encumber", "%+d", "Maximum encumberance: ")

		compare_fields(w, compare_with, field, "combat_physresist", "%+d", "Physical save: ")
		compare_fields(w, compare_with, field, "combat_spellresist", "%+d", "Spell save: ")
		compare_fields(w, compare_with, field, "combat_mentalresist", "%+d", "Mental save: ")

		compare_fields(w, compare_with, field, "blind_immune", "%+d%%", "Blindness immunity: ", 100)
		compare_fields(w, compare_with, field, "poison_immune", "%+d%%", "Poison immunity: ", 100)
		compare_fields(w, compare_with, field, "disease_immune", "%+d%%", "Disease immunity: ", 100)
		compare_fields(w, compare_with, field, "cut_immune", "%+d%%", "Cut immunity: ", 100)

		compare_fields(w, compare_with, field, "silence_immune", "%+d%%", "Silence immunity: ", 100)
		compare_fields(w, compare_with, field, "disarm_immune", "%+d%%", "Disarm immunity: ", 100)
		compare_fields(w, compare_with, field, "confusion_immune", "%+d%%", "Confusion immunity: ", 100)
		compare_fields(w, compare_with, field, "pin_immune", "%+d%%", "Pinning immunity: ", 100)

		compare_fields(w, compare_with, field, "stun_immune", "%+d%%", "Stun/Freeze immunity: ", 100)
		compare_fields(w, compare_with, field, "fear_immune", "%+d%%", "Fear immunity: ", 100)
		compare_fields(w, compare_with, field, "knockback_immune", "%+d%%", "Knockback immunity: ", 100)
		compare_fields(w, compare_with, field, "instakill_immune", "%+d%%", "Instant-death immunity: ", 100)
		compare_fields(w, compare_with, field, "teleport_immune", "%+d%%", "Teleport immunity: ", 100)

		compare_fields(w, compare_with, field, "life_regen", "%+.2f", "Life regen: ")
		compare_fields(w, compare_with, field, "stamina_regen", "%+.2f", "Stamina each turn: ")
		compare_fields(w, compare_with, field, "mana_regen", "%+.2f", "Mana each turn: ")
		compare_fields(w, compare_with, field, "hate_regen", "%+.2f", "Hate each turn: ")
		compare_fields(w, compare_with, field, "psi_regen", "%+.2f", "Psi each turn: ")
		compare_fields(w, compare_with, field, "positive_regen", "%+.2f", "P.Energy each turn: ")

		compare_fields(w, compare_with, field, "stamina_regen_when_hit", "%+.2f", "Stamina when hit: ")
		compare_fields(w, compare_with, field, "mana_regen_when_hit", "%+.2f", "Mana when hit: ")
		compare_fields(w, compare_with, field, "equilibrium_regen_when_hit", "%+.2f", "Equilibrium when hit: ")
		compare_fields(w, compare_with, field, "psi_regen_when_hit", "%+.2f", "Psi when hit: ")
		compare_fields(w, compare_with, field, "hate_regen_when_hit", "%+.2f", "Hate when hit: ")

		compare_fields(w, compare_with, field, "mana_on_crit", "%+.2f", "Mana when firing critical spell: ")
		compare_fields(w, compare_with, field, "vim_on_crit", "%+.2f", "Vim when firing critical spell: ")
		compare_fields(w, compare_with, field, "spellsurge_on_crit", "%+d", "Spellpower on spell critical (stacks up to 3 times): ")

		compare_fields(w, compare_with, field, "hate_on_crit", "%+.2f", "Hate when firing a critical mind attack: ")
		compare_fields(w, compare_with, field, "psi_on_crit", "%+.2f", "Psi when firing a critical mind attack: ")
		compare_fields(w, compare_with, field, "equilibrium_on_crit", "%+.2f", "Equilibrium when firing a critical mind attack: ")

		compare_fields(w, compare_with, field, "hate_per_kill", "+%0.2f", "Hate per kill: ")
		compare_fields(w, compare_with, field, "psi_per_kill", "+%0.2f", "Psi per kill: ")

		compare_fields(w, compare_with, field, "die_at", "%+.2f life", "Only die when reaching: ", 1, true, true)
		compare_fields(w, compare_with, field, "max_life", "%+.2f", "Maximum life: ")
		compare_fields(w, compare_with, field, "max_mana", "%+.2f", "Maximum mana: ")
		compare_fields(w, compare_with, field, "max_stamina", "%+.2f", "Maximum stamina: ")
		compare_fields(w, compare_with, field, "max_hate", "%+.2f", "Maximum hate: ")
		compare_fields(w, compare_with, field, "max_psi", "%+.2f", "Maximum psi: ")
		compare_fields(w, compare_with, field, "max_vim", "%+.2f", "Maximum vim: ")
		compare_fields(w, compare_with, field, "max_air", "%+.2f", "Maximum air capacity: ")

		compare_fields(w, compare_with, field, "combat_spellpower", "%+d", "Spellpower: ")
		compare_fields(w, compare_with, field, "combat_spellcrit", "%+d%%", "Spell crit. chance: ")
		compare_fields(w, compare_with, field, "spell_cooldown_reduction", "%d%%", "Lowers spell cool-downs by: ", 100)

		compare_fields(w, compare_with, field, "combat_mindpower", "%+d", "Mindpower: ")
		compare_fields(w, compare_with, field, "combat_mindcrit", "%+d%%", "Mental crit. chance: ")

		compare_fields(w, compare_with, field, "lite", "%+d", "Light radius: ")
		compare_fields(w, compare_with, field, "infravision", "%+d", "Infravision radius: ")
		compare_fields(w, compare_with, field, "heightened_senses", "%+d", "Heightened senses radius: ")

		compare_fields(w, compare_with, field, "see_invisible", "%+d", "See invisible: ")
		compare_fields(w, compare_with, field, "invisible", "%+d", "Invisibility: ")

		compare_fields(w, compare_with, field, "global_speed_add", "%+d%%", "Global speed: ", 100)
		compare_fields(w, compare_with, field, "movement_speed", "%+d%%", "Movement speed: ", 100)
		compare_fields(w, compare_with, field, "combat_physspeed", "%+d%%", "Combat speed: ", 100)
		compare_fields(w, compare_with, field, "combat_spellspeed", "%+d%%", "Casting speed: ", 100)

		compare_fields(w, compare_with, field, "healing_factor", "%+d%%", "Healing mod.: ", 100)
		compare_fields(w, compare_with, field, "heal_on_nature_summon", "%+d", "Heals friendly targets nearby when you use a nature summon: ")

		compare_fields(w, compare_with, field, "life_leech_chance", "%+d%%", "Life leech chance: ")
		compare_fields(w, compare_with, field, "life_leech_value", "%+d%%", "Life leech: ")

		compare_fields(w, compare_with, field, "resource_leech_chance", "%+d%%", "Resource leech chance: ")
		compare_fields(w, compare_with, field, "resource_leech_value", "%+d", "Resource leech: ")

		compare_fields(w, compare_with, field, "damage_shield_penetrate", "%+d%%", "Damage Shield penetration: ")

		compare_fields(w, compare_with, field, "defense_on_teleport", "%+d", "Defense after a teleport: ")
		compare_fields(w, compare_with, field, "resist_all_on_teleport", "%+d%%", "Resist all after a teleport: ")
		compare_fields(w, compare_with, field, "effect_reduction_on_teleport", "%+d%%", "Effect duration reduction after a teleport: ")

		compare_fields(w, compare_with, field, "damage_resonance", "%+d%%", "Damage Resonance (when hit): ")

		compare_fields(w, compare_with, field, "size_category", "%+d", "Size category: ")

		compare_fields(w, compare_with, field, "nature_summon_max", "%+d", "Max wilder summons: ")
		compare_fields(w, compare_with, field, "nature_summon_regen", "%+.2f", "Life regen bonus (wilder-summons): ")

		compare_fields(w, compare_with, field, "slow_projectiles", "%+d%%", "Slows Projectiles: ")

		if w.undead then
			desc:add("The wearer is treated as an undead.", true)
		end

		if w.demon then
			desc:add("The wearer is treated as a demon.", true)
		end

		if w.blind then
			desc:add("The wearer is blinded.", true)
		end

		if w.blind_fight then
			desc:add({"color", "YELLOW"}, "Blind-Fight:", {"color", "LAST"}, "This item allows the wearer to attack unseen targets without any penalties.", true)
		end

		if w.quick_weapon_swap then
			desc:add({"color", "YELLOW"}, "Quick Weapon Swap:", {"color", "LAST"}, "This item allows the wearer to swap to their secondary weapon without spending a turn.", true)
		end

		if w.avoid_pressure_traps then
			desc:add({"color", "YELLOW"}, "Avoid Pressure Traps: ", {"color", "LAST"}, "The wearer never triggers traps that require pressure.", true)
		end

		if w.speaks_shertul then
			desc:add("Allows you to speak and read the old Sher'Tul language.", true)
		end

		self:triggerHook{"Object:descWielder", compare_with=compare_with, compare_fields=compare_fields, compare_table_fields=compare_table_fields, desc=desc, w=w}

		local can_combat_unarmed = false
		local compare_unarmed = {}
		for i, v in ipairs(compare_with) do
			if v.wielder and v.wielder.combat then
				can_combat_unarmed = true
			end
			compare_unarmed[i] = compare_with[i].wielder or {}
		end

		if (w and w.combat or can_combat_unarmed) and game.player:knowTalent(game.player.T_EMPTY_HAND) then
			desc:add({"color","YELLOW"}, "When used to modify unarmed attacks:", {"color", "LAST"}, true)
			compare_tab = { dam=1, atk=1, apr=0, physcrit=0, physspeed =0.6, dammod={str=1}, damrange=1.1 }
			desc_combat(w, compare_unarmed, "combat", compare_tab)
		end
	end
	local can_combat = false
	local can_special_combat = false
	local can_wielder = false
	local can_carrier = false
	local can_imbue_powers = false

	for i, v in ipairs(compare_with) do
		if v.combat then
			can_combat = true
		end
		if v.special_combat then
			can_special_combat = true
		end
		if v.wielder then
			can_wielder = true
		end
		if v.carrier then
			can_carrier = true
		end
		if v.imbue_powers then
			can_imbue_powers = true
		end
	end

	if self.combat or can_combat then
		desc_combat(self, compare_with, "combat")
	end

	if (self.special_combat or can_special_combat) and (game.player:knowTalentType("technique/shield-offense") or game.player:knowTalentType("technique/shield-defense") or game.player:attr("show_shield_combat")) then
		desc:add({"color","YELLOW"}, "When used to attack (with talents):", {"color", "LAST"}, true)
		desc_combat(self, compare_with, "special_combat")
	end

	local found = false
	for i, v in ipairs(compare_with or {}) do
		if v[field] and v[field].no_teleport then
			found = true
		end
	end

	if self.no_teleport then
		desc:add(found and {"color","WHITE"} or {"color","GREEN"}, "It is immune to teleportation, if you teleport it will fall on the ground.", {"color", "LAST"}, true)
	elseif found then
		desc:add({"color","RED"}, "It is immune to teleportation, if you teleport it will fall on the ground.", {"color", "LAST"}, true)
	end

	if self.wielder or can_wielder then
		desc:add({"color","YELLOW"}, "When wielded/worn:", {"color", "LAST"}, true)
		desc_wielder(self, compare_with, "wielder")
		if self:attr("skullcracker_mult") and game.player:knowTalent(game.player.T_SKULLCRACKER) then
			compare_fields(self, compare_with, "wielder", "skullcracker_mult", "%+d", "Skullcracker multiplicator: ")
		end
	end

	if self.carrier or can_carrier then
		desc:add({"color","YELLOW"}, "When carried:", {"color", "LAST"}, true)
		desc_wielder(self, compare_with, "carrier")
	end

	if self.imbue_powers or can_imbue_powers then
		desc:add({"color","YELLOW"}, "When used to imbue an object:", {"color", "LAST"}, true)
		desc_wielder(self, compare_with, "imbue_powers")
	end

	if self.alchemist_bomb then
		local a = self.alchemist_bomb
		desc:add({"color","YELLOW"}, "When used as an alchemist bomb:", {"color", "LAST"}, true)
		if a.power then desc:add(("Bomb damage +%d%%"):format(a.power), true) end
		if a.range then desc:add(("Bomb thrown range +%d"):format(a.range), true) end
		if a.mana then desc:add(("Mana regain %d"):format(a.mana), true) end
		if a.daze then desc:add(("%d%% chance to daze for %d turns"):format(a.daze.chance, a.daze.dur), true) end
		if a.stun then desc:add(("%d%% chance to stun for %d turns"):format(a.stun.chance, a.stun.dur), true) end
		if a.splash then desc:add(("Additional %d %s damage"):format(a.splash.dam, DamageType:get(DamageType[a.splash.type]).name), true) end
		if a.leech then desc:add(("Life regen %d%% of max life"):format(a.leech), true) end
	end

	if self.inscription_data and self.inscription_talent then
		game.player.__inscription_data_fake = self.inscription_data
		local t = self:getTalentFromId("T_"..self.inscription_talent.."_1")
		local tdesc = game.player:getTalentFullDescription(t)
		game.player.__inscription_data_fake = nil
		desc:add({"color","YELLOW"}, "When inscribed on your body:", {"color", "LAST"}, true)
		desc:merge(tdesc)
		desc:add(true)
	end

	local talents = {}
	if self.talent_on_spell then
		for _, data in ipairs(self.talent_on_spell) do
			talents[data.talent] = {data.chance, data.level}
		end
	end
	for i, v in ipairs(compare_with or {}) do
		for _, data in ipairs(v[field] and (v[field].talent_on_spell or {})or {}) do
			local tid = data.talent
			if not talents[tid] or talents[tid][1]~=data.chance or talents[tid][2]~=data.level then
				desc:add({"color","RED"}, ("Talent on hit(spell): %s (%d%% chance level %d)."):format(self:getTalentFromId(tid).name, data.chance, data.level), {"color","LAST"}, true)
			else
				talents[tid][3] = true
			end
		end
	end
	for tid, data in pairs(talents) do
		desc:add(talents[tid][3] and {"color","GREEN"} or {"color","WHITE"}, ("Talent on hit(spell): %s (%d%% chance level %d)."):format(self:getTalentFromId(tid).name, talents[tid][1], talents[tid][2]), {"color","LAST"}, true)
	end

	local talents = {}
	if self.talent_on_wild_gift then
		for _, data in ipairs(self.talent_on_wild_gift) do
			talents[data.talent] = {data.chance, data.level}
		end
	end
	for i, v in ipairs(compare_with or {}) do
		for _, data in ipairs(v[field] and (v[field].talent_on_wild_gift or {})or {}) do
			local tid = data.talent
			if not talents[tid] or talents[tid][1]~=data.chance or talents[tid][2]~=data.level then
				desc:add({"color","RED"}, ("Talent on hit(nature): %s (%d%% chance level %d)."):format(self:getTalentFromId(tid).name, data.chance, data.level), {"color","LAST"}, true)
			else
				talents[tid][3] = true
			end
		end
	end
	for tid, data in pairs(talents) do
		desc:add(talents[tid][3] and {"color","GREEN"} or {"color","WHITE"}, ("Talent on hit(nature): %s (%d%% chance level %d)."):format(self:getTalentFromId(tid).name, talents[tid][1], talents[tid][2]), {"color","LAST"}, true)
	end

	if self.curse then
		local t = game.player:getTalentFromId(game.player.T_DEFILING_TOUCH)
		if t and t.canCurseItem(game.player, t, self) then
			desc:add({"color",0xf5,0x3c,0xbe}, game.player.tempeffect_def[self.curse].desc, {"color","LAST"}, true)
		end
	end

	self:triggerHook{"Object:descMisc", compare_with=compare_with, compare_fields=compare_fields, compare_table_fields=compare_table_fields, desc=desc, object=self}

	local use_desc = self:getUseDesc()
	if use_desc then desc:merge(use_desc:toTString()) end
	return desc
end

function _M:getUseDesc()
	local ret = tstring{}
	if self.use_power then
		if self.show_charges then
			ret = tstring{{"color","YELLOW"}, ("It can be used to %s, with %d charges out of %d."):format(util.getval(self.use_power.name, self), math.floor(self.power / self.use_power.power), math.floor(self.max_power / self.use_power.power)), {"color","LAST"}}
		elseif self.talent_cooldown then
			ret = tstring{{"color","YELLOW"}, ("It can be used to %s, placing all other charms into a %d cooldown."):format(util.getval(self.use_power.name, self):format(self:getCharmPower()), self.use_power.power), {"color","LAST"}}
		else
			ret = tstring{{"color","YELLOW"}, ("It can be used to %s, costing %d power out of %d/%d."):format(util.getval(self.use_power.name, self), self.use_power.power, self.power, self.max_power), {"color","LAST"}}
		end
	elseif self.use_simple then
		ret = tstring{{"color","YELLOW"}, ("It can be used to %s."):format(self.use_simple.name), {"color","LAST"}}
	elseif self.use_talent then
		local t = game.player:getTalentFromId(self.use_talent.id)
		local desc = game.player:getTalentFullDescription(t, nil, {force_level=self.use_talent.level, ignore_cd=true, ignore_ressources=true, ignore_use_time=true, ignore_mode=true, custom=self.use_talent.power and tstring{{"color",0x6f,0xff,0x83}, "Power cost: ", {"color",0x7f,0xff,0xd4},("%d out of %d/%d."):format(self.use_talent.power, self.power, self.max_power)}})
		if self.talent_cooldown then
			ret = tstring{{"color","YELLOW"}, "It can be used to activate talent ", t.name,", placing all other charms into a ", tostring(math.floor(self.use_talent.power)) ," cooldown :", {"color","LAST"}, true}
		else
			ret = tstring{{"color","YELLOW"}, "It can be used to activate talent ", t.name," (costing ", tostring(math.floor(self.use_talent.power)), " power out of ", tostring(math.floor(self.power)), "/", tostring(math.floor(self.max_power)), ") :", {"color","LAST"}, true}
		end
		ret:merge(desc)
	end

	if self.charm_on_use then
		ret:add(true, "When used:", true)
		for fct, d in pairs(self.charm_on_use) do
			ret:add(tostring(d[1]), "% chances to ", d[2](self, game.player), ".", true)
		end
	end

	return ret
end

--- Gets the full desc of the object
function _M:getDesc(name_param, compare_with, never_compare)
	local desc = tstring{}

	if self.__new_pickup then
		desc:add({"font","bold"},{"color","LIGHT_BLUE"},"Newly picked up",{"font","normal"},{"color","LAST"},true)
	end
	if self.__transmo then
		desc:add({"font","bold"},{"color","YELLOW"},"This item will automatically be transmogrified when you leave the level.",{"font","normal"},{"color","LAST"},true)
	end

	name_param = name_param or {}
	name_param.do_color = true
	compare_with = compare_with or {}

	desc:merge(self:getName(name_param):toTString())
	desc:add({"color", "WHITE"}, true)
	local reqs = self:getRequirementDesc(game.player)
	if reqs then
		desc:merge(reqs)
	end

	if self.power_source then
		if self.power_source.arcane then desc:add("Powered by ", {"color", "VIOLET"}, "arcane forces", {"color", "LAST"}, true) end
		if self.power_source.nature then desc:add("Infused by ", {"color", "OLIVE_DRAB"}, "nature", {"color", "LAST"}, true) end
		if self.power_source.antimagic then desc:add("Infused by ", {"color", "ORCHID"}, "arcane disrupting forces", {"color", "LAST"}, true) end
		if self.power_source.technique then desc:add("Crafted by ", {"color", "LIGHT_UMBER"}, "a master", {"color", "LAST"}, true) end
		if self.power_source.psionic then desc:add("Infused by ", {"color", "YELLOW"}, "psionic forces", {"color", "LAST"}, true) end
		if self.power_source.unknown then desc:add("Powered by ", {"color", "CRIMSON"}, "unknown forces", {"color", "LAST"}, true) end
	end

	if self.encumber then
		desc:add({"color",0x67,0xAD,0x00}, ("%0.2f Encumbrance."):format(self.encumber), {"color", "LAST"})
	end
	if self.ego_bonus_mult then
		desc:add(true, {"color",0x67,0xAD,0x00}, ("%0.2f Ego Multiplier."):format(1 + self.ego_bonus_mult), {"color", "LAST"})
	end

	local could_compare = false
	if not name_param.force_compare and not core.key.modState("ctrl") then
		if compare_with[1] then could_compare = true end
		compare_with = {}
	end

	desc:add(true, true)
	desc:merge(self:getTextualDesc(compare_with))

	if self:isIdentified() then
		desc:add(true, true, {"color", "ANTIQUE_WHITE"})
		desc:merge(self.desc:toTString())
		desc:add({"color", "WHITE"})
	end

	if could_compare and not never_compare then desc:add(true, {"font","italic"}, {"color","GOLD"}, "Press <control> to compare", {"color","LAST"}, {"font","normal"}) end

	return desc
end

local type_sort = {
	potion = 1,
	scroll = 1,
	jewelry = 3,
	weapon = 100,
	armor = 101,
}

--- Sorting by type function
-- By default, sort by type name
function _M:getTypeOrder()
	if self.type and type_sort[self.type] then
		return type_sort[self.type]
	else
		return 99999
	end
end

--- Sorting by type function
-- By default, sort by subtype name
function _M:getSubtypeOrder()
	return self.subtype or ""
end

--- Gets the item's flag value
function _M:getPriceFlags()
	local price = 0

	local function count(w)
		--status immunities
		if w.stun_immune then price = price + w.stun_immune * 80 end
		if w.knockback_immune then price = price + w.knockback_immune * 80 end
		if w.disarm_immune then price = price + w.disarm_immune * 80 end
		if w.teleport_immune then price = price + w.teleport_immune * 80 end
		if w.blind_immune then price = price + w.blind_immune * 80 end
		if w.confusion_immune then price = price + w.confusion_immune * 80 end
		if w.poison_immune then price = price + w.poison_immune * 80 end
		if w.disease_immune then price = price + w.disease_immune * 80 end
		if w.cut_immune then price = price + w.cut_immune * 80 end
		if w.pin_immune then price = price + w.pin_immune * 80 end
		if w.silence_immune then price = price + w.silence_immune * 80 end

		--saves
		if w.combat_physresist then price = price + w.combat_physresist * 0.15 end
		if w.combat_mentalresist then price = price + w.combat_mentalresist * 0.15 end
		if w.combat_spellresist then price = price + w.combat_spellresist * 0.15 end

		--resource-affecting attributes
		if w.max_life then price = price + w.max_life * 0.1 end
		if w.max_stamina then price = price + w.max_stamina * 0.1 end
		if w.max_mana then price = price + w.max_mana * 0.2 end
		if w.max_vim then price = price + w.max_vim * 0.4 end
		if w.max_hate then price = price + w.max_hate * 0.4 end
		if w.life_regen then price = price + w.life_regen * 10 end
		if w.stamina_regen then price = price + w.stamina_regen * 100 end
		if w.mana_regen then price = price + w.mana_regen * 80 end
		if w.psi_regen then price = price + w.psi_regen * 100 end
		if w.stamina_regen_when_hit then price = price + w.stamina_regen_when_hit * 3 end
		if w.equilibrium_regen_when_hit then price = price + w.equilibrium_regen_when_hit * 3 end
		if w.mana_regen_when_hit then price = price + w.mana_regen_when_hit * 3 end
		if w.psi_regen_when_hit then price = price + w.psi_regen_when_hit * 3 end
		if w.hate_regen_when_hit then price = price + w.hate_regen_when_hit * 3 end
		if w.mana_on_crit then price = price + w.mana_on_crit * 3 end
		if w.vim_on_crit then price = price + w.vim_on_crit * 3 end
		if w.psi_on_crit then price = price + w.psi_on_crit * 3 end
		if w.hate_on_crit then price = price + w.hate_on_crit * 3 end
		if w.psi_per_kill then price = price + w.psi_per_kill * 3 end
		if w.hate_per_kill then price = price + w.hate_per_kill * 3 end
		if w.resource_leech_chance then price = price + w.resource_leech_chance * 10 end
		if w.resource_leech_value then price = price + w.resource_leech_value * 10 end

		--combat attributes
		if w.combat_def then price = price + w.combat_def * 1 end
		if w.combat_def_ranged then price = price + w.combat_def_ranged * 1 end
		if w.combat_armor then price = price + w.combat_armor * 1 end
		if w.combat_physcrit then price = price + w.combat_physcrit * 1.4 end
		if w.combat_critical_power then price = price + w.combat_critical_power * 2 end
		if w.combat_atk then price = price + w.combat_atk * 1 end
		if w.combat_apr then price = price + w.combat_apr * 0.3 end
		if w.combat_dam then price = price + w.combat_dam * 3 end
		if w.combat_physspeed then price = price + w.combat_physspeed * -200 end
		if w.combat_spellpower then price = price + w.combat_spellpower * 0.8 end
		if w.combat_spellcrit then price = price + w.combat_spellcrit * 0.4 end

		--shooter attributes
		if w.ammo_regen then price = price + w.ammo_regen * 10 end
		if w.ammo_reload_speed then price = price + w.ammo_reload_speed *10 end
		if w.travel_speed then price = price +w.travel_speed * 10 end

		--miscellaneous attributes
		if w.inc_stealth then price = price + w.inc_stealth * 1 end
		if w.see_invisible then price = price + w.see_invisible * 0.2 end
		if w.infravision then price = price + w.infravision * 1.4 end
		if w.trap_detect_power then price = price + w.trap_detect_power * 1.2 end
		if w.disarm_bonus then price = price + w.disarm_bonus * 1.2 end
		if w.healing_factor then price = price + w.healing_factor * 0.8 end
		if w.heal_on_nature_summon then price = price + w.heal_on_nature_summon * 1 end
		if w.nature_summon_regen then price = price + w.nature_summon_regen * 5 end
		if w.max_encumber then price = price + w.max_encumber * 0.4 end
		if w.movement_speed then price = price + w.movement_speed * 100 end
		if w.fatigue then price = price + w.fatigue * -1 end
		if w.lite then price = price + w.lite * 10 end
		if w.size_category then price = price + w.size_category * 25 end
		if w.esp_all then price = price + w.esp_all * 25 end
		if w.esp_range then price = price + w.esp_range * 15 end
		if w.can_breath then for t, v in pairs(w.can_breath) do price = price + v * 30 end end
		if w.esp_all then price = price + w.esp_all * 25 end
		if w.damage_shield_penetrate then price = price + w.damage_shield_penetrate * 1 end
		if w.spellsurge_on_crit then price = price + w.spellsurge_on_crit * 5 end
		if w.quick_weapon_swap then price = price + w.quick_weapon_swap * 50 end

		--on teleport abilities
		if w.resist_all_on_teleport then price = price + w.resist_all_on_teleport * 4 end
		if w.defense_on_teleport then price = price + w.defense_on_teleport * 3 end
		if w.effect_reduction_on_teleport then price = price + w.effect_reduction_on_teleport * 2 end

		--resists
		if w.resists then for t, v in pairs(w.resists) do price = price + v * 0.15 end end

		--resist penetration
		if w.resists_pen then for t, v in pairs(w.resists_pen) do price = price + v * 1 end end

		--resist cap
		if w.resists_cap then for t, v in pairs(w.resists_cap) do price = price + v * 5 end end

		--stats
		if w.inc_stats then for t, v in pairs(w.inc_stats) do price = price + v * 3 end end

		--percentage damage increases
		if w.inc_damage then for t, v in pairs(w.inc_damage) do price = price + v * 0.8 end end
		if w.inc_damage_type then for t, v in pairs(w.inc_damage_type) do price = price + v * 0.8 end end

		--damage auras
		if w.on_melee_hit then for t, v in pairs(w.on_melee_hit) do price = price + v * 0.6 end end

		--projected damage
		if w.melee_project then for t, v in pairs(w.melee_project) do price = price + v * 0.7 end end
		if w.ranged_project then for t, v in pairs(w.ranged_project) do price = price + v * 0.7 end end
		if w.burst_on_hit then for t, v in pairs(w.burst_on_hit) do price = price + v * 0.8 end end
		if w.burst_on_crit then for t, v in pairs(w.burst_on_crit) do price = price + v * 0.8 end end

		--damage conversion
		if w.convert_damage then for t, v in pairs(w.convert_damage) do price = price + v * 1 end end

		--talent mastery
		if w.talent_types_mastery then for t, v in pairs(w.talent_types_mastery) do price = price + v * 100 end end

		--talent cooldown reduction
		if w.talent_cd_reduction then for t, v in pairs(w.talent_cd_reduction) do if v > 0 then price = price + v * 5 end end end
	end

	if self.carrier then count(self.carrier) end
	if self.wielder then count(self.wielder) end
	if self.combat then count(self.combat) end
	return price
end

--- Get item cost
function _M:getPrice()
	local base = self.cost or 0
	if self.egoed then
		base = base + self:getPriceFlags()
	end
	return base
end

--- Called when trying to pickup
function _M:on_prepickup(who, idx)
	if self.quest and who ~= game.party:findMember{main=true} then
		return "skip"
	end
	if who.player and self.lore then
		game.level.map:removeObject(who.x, who.y, idx)
		who:learnLore(self.lore)
		return true
	end
	if who.player and self.force_lore_artifact then
		game.player:additionalLore(self.unique, self:getName(), "artifacts", self.desc)
		game.player:learnLore(self.unique)
	end
end

--- Can it stacks with others of its kind ?
function _M:canStack(o)
	-- Can only stack known things
	if not self:isIdentified() or not o:isIdentified() then return false end
	return engine.Object.canStack(self, o)
end

--- On identification, add to lore
function _M:on_identify()
	if self.on_id_lore then
		game.player:learnLore(self.on_id_lore, false, false, true)
	end
	if self.unique and self.desc and not self.no_unique_lore then
		game.player:additionalLore(self.unique, self:getName{no_add_name=true, do_color=false, no_count=true}, "artifacts", self.desc)
		game.player:learnLore(self.unique, false, false, true)
	end
end

--- Add some special properties right before wearing it
function _M:specialWearAdd(prop, value)
	self._special_wear = self._special_wear or {}
	self._special_wear[prop] = self:addTemporaryValue(prop, value)
end

--- Add some special properties right when completting a set
function _M:specialSetAdd(prop, value)
	self._special_set = self._special_set or {}
	self._special_set[prop] = self:addTemporaryValue(prop, value)
end

function _M:getCharmPower(raw)
	if raw then return self.charm_power or 1 end
	local def = self.charm_power_def or {add=0, max=100}
	local v = def.add + ((self.charm_power or 1) * def.max / 100)
	if def.floor then v = math.floor(v) end
	return v
end
