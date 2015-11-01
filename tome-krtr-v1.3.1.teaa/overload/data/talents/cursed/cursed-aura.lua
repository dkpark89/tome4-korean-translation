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

local Object = require "engine.Object"
local Entity = require "engine.Entity"
local Dialog = require "engine.ui.Dialog"
local Stats = require "engine.interface.ActorStats"

local curses_detrimental
local curses_beneficial
local curses_weapon

newTalent{
	name = "Defiling Touch",
	type = {"cursed/cursed-aura", 1},
	require = cursed_lev_req1,
	points = 5,
	cooldown = 0,
	no_energy = true,
	no_npc_use = true,
	--no_unlearn_last = true,
	-- list of all curses
	getCurses = function(self, t)
		return { self.EFF_CURSE_OF_CORPSES, self.EFF_CURSE_OF_MADNESS, self.EFF_CURSE_OF_MISFORTUNE, self.EFF_CURSE_OF_NIGHTMARES, self.EFF_CURSE_OF_SHROUDS }
	end,
	cursePenalty = function(self, t)
		return self:combatTalentLimit(math.max(1, self:getTalentLevel(t)-4), 0, 1, 0.64)
	end,
	-- tests whether or not an item can be cursed (takes into account current talent level unless ignoreLevel = true)
	canCurseItem = function(self, t, item, level)
		if not item:wornInven() then return false end

		-- Godslayers are far too powerful to be affected
		if item.godslayer then return false end
		if item.no_curses then return false end

		-- possible slots:
		-- body, head, feet, hands, cloak, belt (armor)
		-- mainhand (weapon), offhand (weapon/armor;shield), psionic (weapon)
		-- finger (X2), neck (jewelry)
		-- lite (lite), tool (tool), quiver (ammo), gem (alchemist-gem)
		level = level or self:getTalentLevel(t)
		if level >= 1 and item.type == "weapon" then return true end
		if level >= 2 and item.type == "armor" and (item.slot == "BODY" or item.slot == "CLOAK")  then return true end
		if level >= 3 and item.type == "armor" and (item.slot == "HEAD" or item.slot == "OFFHAND")  then return true end
		if level >= 4 and item.type == "armor" and (item.slot == "HANDS" or item.slot == "FEET" or item.slot == "BELT")  then return true end
		if level >=6 and item.type == "jewelry" and item.slot == "FINGER" then return true end
		if level >=7 and item.type == "jewelry" and item.slot == "NECK" then return true end
		if level >=8 and item.type == "lite" and item.slot == "LITE" then return true end
		if level >=9 and (item.type == "charm" or item.type == "tool") and item.slot == "TOOL" then return true end
		if level >=10 and item.slot == "QUIVER" and (item.type == "alchemist-gem" or item.type == "ammo")  then return true end

		return false
	end,
	-- curses an item
	curseItem = function(self, t, item)
		if item.curse then return end
		if not t.canCurseItem(self, t, item) then return end

		local curse
		-- apply the curse
		if item.define_as == "CLOAK_DECEPTION" then
			-- cloak of deception is always Corpses..
			curse = self.EFF_CURSE_OF_CORPSES
		else
			local curses = t.getCurses(self, t)
			curse = rng.table(curses)
		end

		local def = self.tempeffect_def[curse]
		local ego = Entity.new{
			name = "curse",
			display_string = " ("..def.short_desc..")",
			curse = curse,
			fake_ego = true, unvault_ego = true,
		}
		game.zone:applyEgo(item, ego, "object")
	end,
	-- curses all items on the floor
	curseFloor = function(self, t, x, y)
		local i = 1
		local item = game.level.map:getObject(x, y, i)
		while item do
			t.curseItem(self, t, item)

			i = i + 1
			item = game.level.map:getObject(x, y, i)
		end
	end,
	-- curses all items in inventory
	curseInventory = function(self, t)
		for id, inven in pairs(self.inven) do
			for i, item in ipairs(inven) do
				t.curseItem(self, t, item)
			end
		end
	end,
	-- sets a cursed aura (+2 curse bonus)
	setCursedAura = function(self, t, curse)
		self.cursed_aura = curse
		t.updateCurses(self, t)
	end,
	-- gets the name of the currently set cursed aura
	getCursedAuraName = function(self, t)
		if not self.cursed_aura then
			return "None"
		else
			return self.tempeffect_def[self.cursed_aura].desc
		end
	end,
	on_onWear = function(self, t, o)
		t.updateCurses(self, t)
	end,
	on_onTakeOff = function(self, t, o)
		t.updateCurses(self, t)
	end,

	-- chooses whether the player accepts the cursed aura tree when a cursable item is found. only offered once for Afflicted classes
	chooseCursedAuraTree = function(self, t)
		local choose = false
		local x, y, i = self.x, self.y, 1
		local item = game.level.map:getObject(x, y, i)
		while item and not choose do
			if t.canCurseItem(self, t, item, 1) then
				choose = true
			else
				i = i + 1
				item = game.level.map:getObject(x, y, i)
			end
		end

		if choose then
			game.player:runStop()
			game.player:restStop()

			-- don't bother the player when there is an enemy near
			local grids = core.fov.circle_grids(self.x, self.y, 10, true)
			for x, yy in pairs(grids) do
				for y, _ in pairs(grids[x]) do
					local actor = game.level.map(x, y, Map.ACTOR)
					if actor and self:reactionToward(actor) < 0 and self:hasLOS(actor.x, actor.y) then
						choose = false
					end
				end
			end

			if choose then
				Dialog:yesnoLongPopup(
					"Cursed Fate",
					("The %s lying nearby catches your attention. What draws you to it is not the thing itself, but something burning inside you. You feel contempt for it and all worldly things. This feeling is not new but the power of it overwhelms you. You reach out to touch the object, to curse it, to defile it. And you notice it begin to change. The colors of it begin to fade and are replaced with an insatiable hate. For a moment you hesitate. You know you must choose to resist this manifestation of your curse now and forever, or fall further into your madness."):format(item.name),
					300,
					function(ret)
						if ret then
							Dialog:simpleLongPopup("Cursed Fate", ("The %s lies defiled at your feet. An aura of hatred surrounds you and you now feel truly cursed. You have gained the Cursed Aura talent tree and 1 point in Defiling Touch, but at the cost of 2 Willpower."):format(item.name), 300)
							self:learnTalentType("cursed/cursed-aura", true)
							self:learnTalent(self.T_DEFILING_TOUCH, true, 1, {no_unlearn=true})
							self:incIncStat(Stats.STAT_WIL, -2)
							t.curseItem(self, t, item)
							t.curseInventory(self, t)
							t.curseFloor(self, t, self.x, self.y)
							t.updateCurses(self, t, false)
						else
							Dialog:simplePopup("Cursed Fate", ("The %s returns to normal and your hate subsides."):format(item.name))
						end
					end,
					"Release your hate upon the object",
					"Suppress your affliction")
			end
			return choose
		end
	end,
	-- updates the state of all curse effects
	updateCurses = function(self, t, forceUpdateEffects)
		local curses = t.getCurses(self, t)
		local itemCounts = {}
		local armorCount = 0

		-- count curses in worn items, but only if we can still curse that type of item
		for id, inven in pairs(self.inven) do
			if self.inven_def[id].is_worn then
				for i, item in ipairs(inven) do
					if item.curse and t.canCurseItem(self, t, item) then
						if item.type == "armor" then armorCount = armorCount + 1 end

						itemCounts[item.curse] = (itemCounts[item.curse] or 0) + 1
					end
				end
			end
		end

		-- add cursed aura
		if self.cursed_aura then
			itemCounts[self.cursed_aura] = (itemCounts[self.cursed_aura] or 0) + 2
		end

		-- update cursed effect levels
		local tDarkGifts = self:getTalentFromId(self.T_DARK_GIFTS)
		for i, curse in ipairs(curses) do
			local eff = self:hasEffect(curse)
			local level = itemCounts[curse] and (itemCounts[curse] + self:callTalent(self.T_DARK_GIFTS, "curseBonusLevel")) or 0
			local penalty = t.cursePenalty(self, t)
			local currentLevel = eff and eff.level or 0
			local currentPenalty = eff and eff.Penalty or 1
			--print("* curse:", self.tempeffect_def[curse].desc, currentLevel, "->", level, eff)
			if currentLevel ~= level or currentPenalty ~= penalty or forceUpdateEffects then
				if eff then
					self:removeEffect(curse, false, true)
				end

				-- preserve the old eff values when re-starting the effect
				if level > 0 then
					if not eff then
						eff = { }
					end
					eff.level = level
					eff.Penalty = penalty
					eff.BonusPower = BonusPower
					eff.unlockLevel = math.min(5, tDarkGifts and self:getTalentLevelRaw(tDarkGifts) or 0)
					self:setEffect(curse, 1, eff)
				end

				self.changed = true
			end
		end
	end,
	passives = function(self, t, p) -- force update on talent mastery changes
	end,
	on_learn = function(self, t)
		t.curseInventory(self, t)
		t.curseFloor(self, t, self.x, self.y)
		t.updateCurses(self, t)
	end,
	on_unlearn = function(self, t)
		-- turn off cursed aura (which gets disabled, but does not turn off)
		t.setCursedAura(self, t, nil)
	end,
	on_pre_use = function(self, t, silent)
		return self:getTalentLevelRaw(t) >= 5
	end,
	-- selects a new cursed aura (+2 curse bonus)
	action = function(self, t)
		local cursedAuraSelect = require("mod.dialogs.CursedAuraSelect").new(self)
		game:registerDialog(cursedAuraSelect)
	end,
	info = function(self, t)
		return ([[Your defiling touch permeates everything around you, permanently imparting a random curse on each item you find. When you equip a cursed item, you gain the effects of that curse (shown as a beneficial effect). Each item with the same curse that is equipped increases the curse's power.  Initially curses are harmful, but powerful benefits accumulate as the power of the curse increases.
		The Dark Gifts talent unlocks higher level curse effects and increases their power.
		Your aura permeates your equipment more thoroughly with talent level and can affect items as follows:
		Level 1  -- weapons
		Level 2  -- body armor and cloaks
		Level 3  -- shields and helmets
		Level 4  -- gloves, boots and belts
		Level 6  -- rings
		Level 7  -- amulets/necklaces
		Level 8  -- lites
		Level 9  -- tools/totems/torques/wands
		level 10 -- ammunition
		At level 5, you can activate this talent to surround yourself with an aura that adds 2 levels to a curse of your choosing. (%s chosen)
		Also, talent levels above 5 reduce the negative effects of your curses (currently %d%% reduction).]]):
		format(t.getCursedAuraName(self, t), (1-t.cursePenalty(self, t))*100)
	end,
}

newTalent{
	name = "Dark Gifts",
	type = {"cursed/cursed-aura", 2},
	mode = "passive",
	require = cursed_lev_req2,
	no_unlearn_last = true,
	points = 5,
	curseBonusLevel = function(self, t)
		return self:combatTalentScale(math.max(0,self:getTalentLevel(t)-5), 1, 2.5) 
	end,
	on_learn = function(self, t)
		local tDefilingTouch = self:getTalentFromId(self.T_DEFILING_TOUCH)
		tDefilingTouch.updateCurses(self, tDefilingTouch, true)
	end,
	on_unlearn = function(self, t)
		local tDefilingTouch = self:getTalentFromId(self.T_DEFILING_TOUCH)
		tDefilingTouch.updateCurses(self, tDefilingTouch, true)
	end,
	info = function(self, t)
		local level = math.min(4, self:getTalentLevelRaw(t))
		local xs = t.curseBonusLevel(self,t)
		return ([[Your curses bring you dark gifts. Unlocks bonus level %d effects on all of your curses, allowing you to gain that effect when the power level of your curse reaches that level. At talent level 5, the luck penalty of cursed effects is reduced to 1.
		Talent levels above 5 add bonus power levels to your curses, increasing their effects (currently %0.1f).]]):
		format(level, xs)
	end,
}

newTalent{
	name = "Ruined Earth",
	type = {"cursed/cursed-aura", 3},
	require = cursed_lev_req3,
	points = 5,
	cooldown = 30,
	range = function(self, t)
		return math.min(8, 2 + math.floor(self:getTalentLevel(t)))
	end,
	random_ego = "defensive",
	tactical = { DEFEND = 2 },
	getDuration = function(self, t)
		return math.min(8, 3 + math.floor(self:getTalentLevel(t)))
	end,
	getIncDamage = function(self, t)
		return math.floor(math.min(60, 22 + (math.sqrt(self:getTalentLevel(t)) - 1) * 23))
	end,
	getPowerPercent = function(self, t)
		return math.floor((math.sqrt(self:getTalentLevel(t)) - 1) * 20)
	end,
	action = function(self, t)
		local range = self:getTalentRange(t)
		local duration = t.getDuration(self, t)
		local incDamage = t.getIncDamage(self, t)

		-- project first to immediately start the effect
		local tg = {type="ball", radius=range}
		self:project(tg, self.x, self.y, DamageType.WEAKNESS, { incDamage=incDamage, dur=3 })

		game.level.map:addEffect(self,
			self.x, self.y, duration,
			DamageType.WEAKNESS, { incDamage=incDamage, dur=3 },
			range,
			5, nil,
			engine.MapEffect.new{alpha=100, color_br=120, color_bg=120, color_bb=120, effect_shader="shader_images/darkness_effect.png"}
		)

		return true
	end,
	info = function(self, t)
		local range = self:getTalentRange(t)
		local duration = t.getDuration(self, t)
		local incDamage = t.getIncDamage(self, t)

		return ([[Curse the earth around you in a radius of %d for %d turns. Any who stand upon it are weakened, reducing the damage they inflict by %d%%]]):format(range, duration, incDamage)
	end,
}

newTalent{
	name = "Choose Cursed Sentry",
	type = {"cursed/curses", 1},
	points = 1,
	no_energy = true,
	action = function(self, t)
		local ct = self:getTalentFromId(self.T_CURSED_SENTRY)
		local inven = self:getInven("INVEN")
		local d = self:showInventory("Which weapon will be your sentry?", inven, function(o) return ct.filterObject(self, ct, o) end, nil)
		d.action = function(o, item) self:talentDialogReturn(true, o, item) return false end
		local ret, o, item = self:talentDialog(d)
		if not ret then return nil end
		self.cursed_sentry = o
		return true
	end,
	info = function(self, t) return [[Choose a sentry to instill your affliction into.]] end,
}

newTalent{
	name = "Cursed Sentry",
	type = {"cursed/cursed-aura", 4},
	require = cursed_lev_req4,
	points = 5,
	cooldown = 40,
	range = 5,
	no_npc_use = true,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 8, 16))	end,
	getAttackSpeed = function(self, t) return self:combatTalentScale(t, 0.6, 1.4) end,
	filterObject = function(self, t, o)
		local tl = self:getTalentLevel(t)
		local power = (tl >= 5 and 3) or (tl >= 3 and 2) or 1
		return o.type == "weapon" and o:getPowerRank() <= power
	end,
	target = function(self, t) return {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, talent=t} end,
	autolearn_talent = Talents.T_CHOOSE_CURSED_SENTRY,
	action = function(self, t)
		local inven = self:getInven("INVEN")
		local found = false
		for i, obj in pairs(inven) do
			if type(obj) == "table" and obj.type == "weapon" then
				found = true
				break
			end
		end
		if not found then
			game.logPlayer(self, "You cannot use %s without a weapon in your inventory!", t.name)
			return false
		end

		-- select the location
		local tg = self:getTalentTarget(t)
		local tx, ty = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, _, _, x, y = self:canProject(tg, tx, ty)
		if game.level.map(x, y, Map.ACTOR) or game.level.map:checkEntity(x, y, game.level.map.TERRAIN, "block_move") then return nil end

		-- select the item
		if not self.cursed_sentry or not self:findInInventoryByObject(inven, self.cursed_sentry) or not t.filterObject(self, t, self.cursed_sentry) then
			-- save compat
			if not self:knowTalent(self.T_CHOOSE_CURSED_SENTRY) then
				self:checkPool(t.id, self.T_CHOOSE_CURSED_SENTRY)
			end
			local ct = self:getTalentFromId(self.T_CHOOSE_CURSED_SENTRY)
			-- xx HACK cannot forceUse a talent that shows a dialog
			local ret = ct.action(self, ct)
			if not ret then return end
		end
		local o, item = self:findInInventoryByObject(inven, self.cursed_sentry)

		local result = self:removeObject(inven, item)

		local NPC = require "mod.class.NPC"
		local sentry = NPC.new {
			type = "construct", subtype = "weapon",
			display = o.display, color=o.color, image = o.image, blood_color = colors.GREY,
			name = "animated "..o:getName(), -- bug fix
			faction = self.faction,
			desc = "A weapon imbued with a living curse. It seems to be searching for its next victim.",
			faction = self.faction,
			body = { INVEN = 10, MAINHAND=1, QUIVER=1 },
			rank = 2,
			size_category = 1,

			autolevel = o.combat.wil_attack and "summoner" or "warrior",
			ai = "summoned", ai_real = "tactical", ai_state = { talent_in=1, },

			max_life = 50 + self.max_life*self:combatTalentLimit(t, 1, 0.04, 0.17),  -- Add % of summoner's life < 100%
			life_rating = 3,
			stats = o.combat.wil_attack and {wil= 20, cun = 20, mag=10, con=10} or {str=20, dex=20, mag=10, con=10},
			combat = { dam=1, atk=1, apr=1 },
			combat_armor = math.max(100,50 + self.level),
			combat_armor_hardiness = math.min(70,5*self:getTalentLevel(t)),
			combat_def = math.max(50,self.level),
			inc_damage = table.clone(self.inc_damage or {}, true),
			resists_pen = table.clone(self.resists_pen or {}, true),
			
			combat_physspeed = t.getAttackSpeed(self, t),
			infravision = 10,

			resists = { all = self:combatTalentLimit(t, 100, 71, 75), },
			cut_immune = 1,
			blind_immune = 1,
			fear_immune = 1,
			poison_immune = 1,
			disease_immune = 1,
			stone_immune = 1,
			see_invisible = 30,
			no_breath = 1,
			disarm_immune = 1,
			never_move = 1,
			--no_drops = true, -- remove to drop the weapon

			resolvers.talents{
				[Talents.T_WEAPON_COMBAT]={base=1, every=10},
				[Talents.T_WEAPONS_MASTERY]={base=1, every=10},
				[Talents.T_KNIFE_MASTERY]={base=1, every=10},
				[Talents.T_EXOTIC_WEAPONS_MASTERY]={base=1, every=10},
				[Talents.T_STAFF_MASTERY]={base=1, every=10},
				[Talents.T_BOW_MASTERY]={base=1, every=10},
				[Talents.T_SLING_MASTERY]={base=1, every=10},
				[Talents.T_PSIBLADES]=o.combat.wil_attack and {base=1, every=10},
				[Talents.T_SHOOT]=1,
			},
			o.combat.wil_attack and resolvers.sustains_at_birth(),
			summoner = self,
			summoner_gain_exp=true,
			summon_time = t.getDuration(self, t),
			summon_quiet = true,
			on_die = function(self, who)
				game.logSeen(self, "#F53CBE#%s drops to the ground.", self.name:capitalize())
			end,
		}

		sentry:resolve()
		sentry:resolve(nil, true)
		sentry:forceLevelup(self.level)

		-- Auto alloc some stats to be able to wear it
		if rawget(o, "require") and rawget(o, "require").stat then
			for s, v in pairs(rawget(o, "require").stat) do
				if sentry:getStat(s) < v then
					sentry.unused_stats = sentry.unused_stats - (v - sentry:getStat(s))
					sentry:incStat(s, v - sentry:getStat(s))
				end
			end
		end

		o.__special_boss_drop = nil  -- lol @ artifact transmutation
		o.old_auto_pickup = o.auto_pickup
		o.auto_pickup = true  -- allow to reautopickup
		o.old_on_pickup = o.on_pickup
		o.on_pickup = function(self, who)
			self.auto_pickup = self.old_auto_pickup
			self.on_pickup = self.old_on_pickup
			if self.old_on_pickup then self.old_on_pickup(self, who) end
		end
		result = sentry:wearObject(o, true, false)
		if not result then
			game.logPlayer(self, "Your animated sentry struggles for a moment and then drops to the ground inexplicably.")
			game.level.map:addObject(x, y, o)
			return nil
		end
		local qo = nil
		if o.archery then
			local level = o.material_level or 1
			-- Trying to replicate the ego pattern on the weapon. Kinky.
			local egos = o.egos_number or (o.ego_list and #o.ego_list) or (e.egoed and 1) or 0
			local greater = o.greater_ego or 0
			local double_greater = (o.unique and egos == 0) or greater > 1  -- artifact or purple
			local greater_normal = (o.unique and egos > 2) or greater == 1 and egos > 1 -- randart or blue
			local greater = (o.unique and egos > 0) or greater == 1 and egos == 1  -- rare or blue
			local double_ego = not o.unique and greater == 0 and egos > 1
			local ego = not o.unique and greater == 0 and egos == 1
			local filter = {type="ammo", ignore_material_restriction=true, tome={double_greater=double_greater and 1, greater_normal=greater_normal and 1,
			greater = greater and 1, double_ego = double_ego and 1, ego = ego and 1}, special = function(e) return not e.unique and e.material_level == level end}
			if o.archery == "bow" then filter.subtype = "arrow"
			elseif o.archery == "sling" then filter.subtype = "shot"
			end
			qo = game.zone:makeEntity(game.level, "object", filter, nil, true)
			if qo then qo.no_drop = true sentry:wearObject(qo, true, false) end
		end


		-- level stats up for MAXIMUM DAMAGE
		local stats = sentry.unused_stats
		local use_stats = {}
		local total = 0
		local dammod = sentry:getDammod(o.combat.dammod or {})
		if qo then
			for stat, mod in pairs(sentry:getDammod(qo.combat.dammod or {})) do
				dammod[stat] = (dammod[stat] or 0) + mod
			end
		end
		dammod.str = (dammod.str or 0) + 1  -- physical power
		for stat, mod in pairs(dammod) do total = total + mod end
		for stat, mod in pairs(dammod) do
			local inc = math.floor(mod * stats / total)
			sentry:incStat(stat, inc)
			sentry.unused_stats = sentry.unused_stats - inc
		end
		-- put the rest into Con
		sentry:incStat("con", sentry.unused_stats)

		game.zone:addEntity(game.level, sentry, "actor", x, y)

		sentry.no_party_ai = true
		sentry.unused_stats = 0
		sentry.unused_talents = 0
		sentry.unused_generics = 0
		sentry.unused_talents_types = 0
		sentry.no_points_on_levelup = true
		if game.party:hasMember(self) then
			sentry.remove_from_party_on_death = true
			game.party:addMember(sentry, { control="no", type="summon", title="Summon"})
		end

		game:playSoundNear(self, "talents/spell_generic")

		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local attackSpeed = t.getAttackSpeed(self, t)*100

		return ([[Instill a part of your living curse into a weapon in your inventory, and toss it nearby. This nearly impervious sentry will attack all nearby enemies for %d turns. When the curse ends, the weapon will drop to the ground.
			Cursed Sentry attack speed (currently %d%%) will improve with talent level.
			When you first select a weapon, it will be remembered and used as long as it's in your inventory. Use Choose Cursed Sentry talent to alter your selection.
			At talent level 3, you get the ability to afflict powerful mundane objects (greater egos).
			At talent level 5, you can corrupt artifacts.]]):format(duration, attackSpeed)
	end,
}
