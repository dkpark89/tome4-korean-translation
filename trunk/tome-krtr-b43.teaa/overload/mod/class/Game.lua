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

require "engine.class"
require "engine.GameTurnBased"
require "engine.interface.GameMusic"
require "engine.interface.GameSound"
require "engine.interface.GameTargeting"
local KeyBind = require "engine.KeyBind"
local Savefile = require "engine.Savefile"
local DamageType = require "engine.DamageType"
local Zone = require "mod.class.Zone"
local Tiles = require "engine.Tiles"
local Map = require "engine.Map"
local Level = require "engine.Level"
local Birther = require "mod.dialogs.Birther"
local Astar = require "engine.Astar"
local DirectPath = require "engine.DirectPath"
local Shader = require "engine.Shader"
local HighScores = require "engine.HighScores"

local NicerTiles = require "mod.class.NicerTiles"
local GameState = require "mod.class.GameState"
local Store = require "mod.class.Store"
local Trap = require "mod.class.Trap"
local Grid = require "mod.class.Grid"
local Actor = require "mod.class.Actor"
local Party = require "mod.class.Party"
local Player = require "mod.class.Player"
local NPC = require "mod.class.NPC"

local DebugConsole = require "engine.DebugConsole"
local FlyingText = require "engine.FlyingText"
local Tooltip = require "mod.class.Tooltip"
local BigNews = require "mod.class.BigNews"

local Calendar = require "engine.Calendar"
local Gestures = require "engine.ui.Gestures"

local Dialog = require "engine.ui.Dialog"
local MapMenu = require "mod.dialogs.MapMenu"

module(..., package.seeall, class.inherit(engine.GameTurnBased, engine.interface.GameMusic, engine.interface.GameSound, engine.interface.GameTargeting))

-- Difficulty settings
DIFFICULTY_EASY = 1
DIFFICULTY_NORMAL = 2
DIFFICULTY_NIGHTMARE = 3
DIFFICULTY_INSANE = 4
PERMADEATH_INFINITE = 1
PERMADEATH_MANY = 2
PERMADEATH_ONE = 3

-- Tell the engine that we have a fullscreen shader that supports gamma correction
support_shader_gamma = true

function _M:init()
	engine.GameTurnBased.init(self, engine.KeyBind.new(), 1000, 100)
	engine.interface.GameMusic.init(self)
	engine.interface.GameSound.init(self)

	-- Pause at birth
	self.paused = true

	-- Same init as when loaded from a savefile
	self:loaded()

	self.visited_zones = {}
end

function _M:run()
	self.delayed_log_damage = {}
	self.calendar = Calendar.new("/data/calendar_allied.lua", "Today is the %s %s of the %s year of the Age of Ascendancy of Maj'Eyal.\nThe time is %02d:%02d.", 122, 167, 11)

	self.uiset:activate()

	local flysize = ({normal=14, small=12, big=16})[config.settings.tome.fonts.size]
	self.tooltip = Tooltip.new(self.uiset.init_font_mono, self.uiset.init_size_mono, {255,255,255}, {30,30,30,230})
	self.tooltip2 = Tooltip.new(self.uiset.init_font_mono, self.uiset.init_size_mono, {255,255,255}, {30,30,30,230})
	self.flyers = FlyingText.new("/data/font/INSULA__.ttf", flysize, "/data/font/INSULA__.ttf", flysize + 3)
	self.flyers:enableShadow(0.6)
	game:setFlyingText(self.flyers)

	self.bignews = BigNews.new("/data/font/DroidSansMono.ttf", 30)

	self.nicer_tiles = NicerTiles.new()

	-- Ok everything is good to go, activate the game in the engine!
	self:setCurrent()

	-- Start time
	self.real_starttime = os.time()

	self:setupDisplayMode(false, "postinit")
	if self.level and self.level.data.day_night then self.state:dayNightCycle() end
	if self.level and self.player then self.calendar = Calendar.new("/data/calendar_"..(self.player.calendar or "allied")..".lua", "Today is the %s %s of the %s year of the Age of Ascendancy of Maj'Eyal.\nThe time is %02d:%02d.", 122, 167, 11) end

	-- Setup inputs
	self:setupCommands()
	self:setupMouse()

	-- Starting from here we create a new game
	if self.player and self.player.dead then
		print("Player is dead, rebooting")
		util.showMainMenu()
		return
	end
	if not self.player then self:newGame() end

	engine.interface.GameTargeting.init(self)

	self.uiset.hotkeys_display.actor = self.player
	self.uiset.npcs_display.actor = self.player

	-- Run the current music if any
	self:onTickEnd(function()
		self:playMusic()
		if self.level then
			self.level.map:moveViewSurround(self.player.x, self.player.y, config.settings.tome.scroll_dist, config.settings.tome.scroll_dist)
		end
	end)

	-- Create the map scroll text overlay
	local lfont = core.display.newFont("/data/font/DroidSans.ttf", 30)
	lfont:setStyle("bold")
	local s = core.display.drawStringBlendedNewSurface(lfont, "<Scroll mode, press keys to scroll, caps lock to exit>", unpack(colors.simple(colors.GOLD)))
	lfont:setStyle("normal")
	self.caps_scroll = {s:glTexture()}
	self.caps_scroll.w, self.caps_scroll.h = s:getSize()

	self.zone_font = core.display.newFont("/data/font/DroidSans.ttf", 12)

	self.inited = true
end

--- Resize the hotkeys
function _M:resizeIconsHotkeysToolbar()
	self.uiset:resizeIconsHotkeysToolbar()
end

--- Checks if the current character is "tainted" by cheating
function _M:isTainted()
	if config.settings.cheat then return true end
	return (game.player and game.player.__cheated) and true or false
end

--- Sets the player name
function _M:setPlayerName(name)
	name = name:removeColorCodes():gsub("#", " "):sub(1, 25)
	self.save_name = name
	self.player_name = name
	if self.party and self.party:findMember{main=true} then
		self.party:findMember{main=true}.name = name
	end
end

function _M:newGame()
	self.party = Party.new{}
	local player = Player.new{name=self.player_name, game_ender=true}
	self.party:addMember(player, {
		control="full",
		type="player",
		title="Main character",
		main=true,
		orders = {target=true, anchor=true, behavior=true, leash=true, talents=true},
	})
	self.party:setPlayer(player)

	-- Create the entity to store various game state things
	self.state = GameState.new{}
	local birth_done = function()
		if self.state.birth.__allow_rod_recall then game.state:allowRodRecall(true) self.state.birth.__allow_rod_recall = nil end
		if self.state.birth.__allow_transmo_chest and profile.mod.allow_build.birth_transmo_chest then
			self.state.birth.__allow_transmo_chest = nil
			local chest = game.zone:makeEntityByName(game.level, "object", "TRANSMO_CHEST")
			if chest then
				game.zone:addEntity(game.level, chest, "object")
				self.player:addObject(self.player:getInven("INVEN"), chest)
			end
		end

		for i = 1, 50 do
			local o = self.state:generateRandart{add_pool=true}
			self.zone.object_list[#self.zone.object_list+1] = o
		end

		if config.settings.cheat then self.player.__cheated = true end

		self.player:recomputeGlobalSpeed()

		-- Force the hotkeys to be sorted.
		self.player:sortHotkeys()

		-- Register the character online if possible
		self.player:getUUID()
		self:updateCurrentChar()
	end

	self.always_target = true
	local nb_unlocks, max_unlocks = self:countBirthUnlocks()
	self.creating_player = true
	local birth; birth = Birther.new("Character Creation ("..nb_unlocks.."/"..max_unlocks.." unlocked birth options)", self.player, {"base", "world", "difficulty", "permadeath", "race", "subrace", "sex", "class", "subclass" }, function(loaded)
		if not loaded then
			self.calendar = Calendar.new("/data/calendar_"..(self.player.calendar or "allied")..".lua", "Today is the %s %s of the %s year of the Age of Ascendancy of Maj'Eyal.\nThe time is %02d:%02d.", 122, 167, 11)
			self.player:check("make_tile")
			self.player.make_tile = nil
			self.player:check("before_starting_zone")
			self.player:check("class_start_check")

			-- Configure & create the worldmap
			self.player.last_wilderness = self.player.default_wilderness[3] or "wilderness"
			game:onLevelLoad(self.player.last_wilderness.."-1", function(zone, level)
				game.player.wild_x, game.player.wild_y = game.player.default_wilderness[1], game.player.default_wilderness[2]
				if type(game.player.wild_x) == "string" and type(game.player.wild_y) == "string" then
					local spot = level:pickSpot{type=game.player.wild_x, subtype=game.player.wild_y} or {x=1,y=1}
					game.player.wild_x, game.player.wild_y = spot.x, spot.y
				end
			end)

			-- Generate
			if self.player.__game_difficulty then self:setupDifficulty(self.player.__game_difficulty) end
			self:setupPermadeath(self.player)
			self:changeLevel(self.player.starting_level or 1, self.player.starting_zone, {force_down=self.player.starting_level_force_down})

			print("[PLAYER BIRTH] resolve...")
			self.player:resolve()
			self.player:resolve(nil, true)
			self.player.energy.value = self.energy_to_act
			Map:setViewerFaction(self.player.faction)
			self.player:updateModdableTile()

			self.paused = true
			print("[PLAYER BIRTH] resolved!")
			local birthend = function()
				local d = require("engine.dialogs.ShowText").new("Welcome to ToME", "intro-"..self.player.starting_intro, {name=self.player.name}, nil, nil, function()
					self.player:resetToFull()
					self.player:registerCharacterPlayed()
					self.player:onBirth(birth)
					-- For quickbirth
					savefile_pipe:push(self.player.name, "entity", self.party, "engine.CharacterVaultSave")
					self.creating_player = false

					self.player:grantQuest(self.player.starting_quest)

					birth_done()
					self.player:check("on_birth_done")

					if __module_extra_info.birth_done_script then loadstring(__module_extra_info.birth_done_script)() end
				end, true)
				self:registerDialog(d)
				if __module_extra_info.no_birth_popup then d.key:triggerVirtual("EXIT") end
			end

			if self.player.no_birth_levelup or __module_extra_info.no_birth_popup then birthend()
			else self.player:playerLevelup(birthend, true) end

		-- Player was loaded from a premade
		else
			self.calendar = Calendar.new("/data/calendar_"..(self.player.calendar or "allied")..".lua", "Today is the %s %s of the %s year of the Age of Ascendancy of Maj'Eyal.\nThe time is %02d:%02d.", 122, 167, 11)
			Map:setViewerFaction(self.player.faction)
			if self.player.__game_difficulty then self:setupDifficulty(self.player.__game_difficulty) end
			self:setupPermadeath(self.player)

			-- Configure & create the worldmap
			self.player.last_wilderness = self.player.default_wilderness[3] or "wilderness"
			game:onLevelLoad(self.player.last_wilderness.."-1", function(zone, level)
				game.player.wild_x, game.player.wild_y = game.player.default_wilderness[1], game.player.default_wilderness[2]
				if type(game.player.wild_x) == "string" and type(game.player.wild_y) == "string" then
					local spot = level:pickSpot{type=game.player.wild_x, subtype=game.player.wild_y} or {x=1,y=1}
					game.player.wild_x, game.player.wild_y = spot.x, spot.y
				end
			end)

			-- Tell the level gen code to add all the party
			self.to_re_add_actors = {}
			for act, _ in pairs(self.party.members) do if self.player ~= act then self.to_re_add_actors[act] = true end end

			self:changeLevel(self.player.starting_level or 1, self.player.starting_zone, {force_down=self.player.starting_level_force_down})
			self.player:grantQuest(self.player.starting_quest)
			self.creating_player = false

			-- Add all items so they regen correctly
			self.player:inventoryApplyAll(function(inven, item, o) game:addEntity(o) end)

			birth_done()
			self.player:check("on_birth_done")
		end
	end, quickbirth, 800, 600)
	self:registerDialog(birth)
end

function _M:setupDifficulty(d)
	self.difficulty = d
end
function _M:setupPermadeath(p)
	if p:attr("infinite_lifes") then self.permadeath = PERMADEATH_INFINITE
	elseif p:attr("easy_mode_lifes") then self.permadeath = PERMADEATH_MANY
	else self.permadeath = PERMADEATH_ONE
	end
end

function _M:loaded()
	engine.GameTurnBased.loaded(self)
	engine.interface.GameMusic.loaded(self)
	engine.interface.GameSound.loaded(self)
	Zone:setup{
		npc_class="mod.class.NPC", grid_class="mod.class.Grid", object_class="mod.class.Object", trap_class="mod.class.Trap",
		on_setup = function(zone)
			-- Increases zone level for higher difficulties
			if not zone.__applied_difficulty then
				zone.__applied_difficulty = true
				if self.difficulty == self.DIFFICULTY_INSANE then
					zone.base_level_range = table.clone(zone.level_range, true)
					zone.specific_base_level.object = -10 -zone.level_range[1]
					zone.level_range[1] = zone.level_range[1] * 2 + 10
					zone.level_range[2] = zone.level_range[2] * 2 + 10
				end
			end
		end,
	}
	Zone.check_filter = function(...) return self.state:entityFilter(...) end
	Zone.default_prob_filter = true
	Zone.default_filter = function(...) return self.state:defaultEntityFilter(...) end
	Zone.alter_filter = function(...) return self.state:entityFilterAlter(...) end
	Zone.post_filter = function(...) return self.state:entityFilterPost(...) end
	Zone.ego_filter = function(...) return self.state:egoFilter(...) end

	self.uiset = (require("mod.class.uiset."..(config.settings.tome.uiset_mode or "Minimalist"))).new()

	Map:setViewerActor(self.player)
	self:setupDisplayMode(false, "init")
	self:setupDisplayMode(false, "postinit")
	if self.player then self.player.changed = true end
	self.key = engine.KeyBind.new()

	if self.always_target == true then Map:setViewerFaction(self.player.faction) end
	if self.player and config.settings.cheat then self.player.__cheated = true end
	self:updateCurrentChar()
end

function _M:setupDisplayMode(reboot, mode)
	if not mode or mode == "init" then
		local gfx = config.settings.tome.gfx
		self:saveSettings("tome.gfx", ('tome.gfx = {tiles=%q, size=%q, tiles_custom_dir=%q, tiles_custom_moddable=%s, tiles_custom_adv=%s}\n'):format(gfx.tiles, gfx.size, gfx.tiles_custom_dir or "", gfx.tiles_custom_moddable and "true" or "false", gfx.tiles_custom_adv and "true" or "false"))

		if reboot then
			self.change_res_dialog = true
			self:saveGame()
			util.showMainMenu(false, nil, nil, self.__mod_info.short_name, self.save_name, false)
		end

		Map:resetTiles()
	end

	if not mode or mode == "postinit" then
		local gfx = config.settings.tome.gfx

		-- Select tiles
		Tiles.prefix = "/data/gfx/"..gfx.tiles.."/"
		if config.settings.tome.gfx.tiles == "customtiles" then
			Tiles.prefix = "/data/gfx/"..config.settings.tome.gfx.tiles_custom_dir.."/"
		end
		print("[DISPLAY MODE] Tileset: "..gfx.tiles)
		print("[DISPLAY MODE] Size: "..gfx.size)

		local do_bg = gfx.tiles == "ascii_full"
		local _, _, tw, th = gfx.size:find("^([0-9]+)x([0-9]+)$")
		tw, th = tonumber(tw), tonumber(th)
		if not tw then tw, th = 64, 64 end
		local pot_th = math.pow(2, math.ceil(math.log(th-0.1) / math.log(2.0)))
		local fsize = math.floor( pot_th/th*(0.7 * th + 5) )

		local map_x, map_y, map_w, map_h = self.uiset:getMapSize()
		if th <= 20 then
			Map:setViewPort(map_x, map_y, map_w, map_h, tw, th, "/data/font/FSEX300.ttf", pot_th, do_bg)
		else
			Map:setViewPort(map_x, map_y, map_w, map_h, tw, th, nil, fsize, do_bg)
		end

		-- Show a count for stacked objects
		Map.object_stack_count = true

		Map.tiles.use_images = true
		if gfx.tiles == "ascii" then
			Map.tiles.use_images = false
			Map.tiles.force_back_color = {r=0, g=0, b=0, a=255}
			Map.tiles.no_moddable_tiles = true
		elseif gfx.tiles == "ascii_full" then
			Map.tiles.use_images = false
			Map.tiles.no_moddable_tiles = true
		elseif gfx.tiles == "shockbolt" then
			Map.tiles.nicer_tiles = true
		elseif gfx.tiles == "oldrpg" then
			Map.tiles.nicer_tiles = true
		elseif gfx.tiles == "customtiles" then
			Map.tiles.no_moddable_tiles = not config.settings.tome.gfx.tiles_custom_moddable
			Map.tiles.nicer_tiles = config.settings.tome.gfx.tiles_custom_adv
		end

		if self.level then
			if self.level.map.finished then
				self.level.map:recreate()
				self.level.map:moveViewSurround(self.player.x, self.player.y, 8, 8)
			end
			engine.interface.GameTargeting.init(self)
		end
		self:setupMiniMap()

		self:createFBOs()
	end
end

function _M:createFBOs()
	-- Create the framebuffer
	self.fbo = core.display.newFBO(Map.viewport.width, Map.viewport.height)
	if self.fbo then self.fbo_shader = Shader.new("main_fbo") if not self.fbo_shader.shad then self.fbo = nil self.fbo_shader = nil end end
	if self.player then self.player:updateMainShader() end

	self.full_fbo = core.display.newFBO(self.w, self.h)
	if self.full_fbo then self.full_fbo_shader = Shader.new("full_fbo") if not self.full_fbo_shader.shad then self.full_fbo = nil self.full_fbo_shader = nil end end

--	self.mm_fbo = core.display.newFBO(200, 200)
--	if self.mm_fbo then self.mm_fbo_shader = Shader.new("mm_fbo") if not self.mm_fbo_shader.shad then self.mm_fbo = nil self.mm_fbo_shader = nil end end
end

function _M:resizeMapViewport(w, h)
	w = math.floor(w)
	h = math.floor(h)

	Map.viewport.width = w
	Map.viewport.height = h
	Map.viewport.mwidth = math.floor(w / Map.tile_w)
	Map.viewport.mheight = math.floor(h / Map.tile_h)

	self:createFBOs()

	if self.level then
		self.level.map:makeCMap()
		self.level.map:redisplay()
		if self.player then
			self.player:updateMainShader()
			self.level.map:moveViewSurround(self.player.x, self.player.y, config.settings.tome.scroll_dist, config.settings.tome.scroll_dist)
		end
	end
end

function _M:setupMiniMap()
	if self.level and self.level.map and self.level.map.finished then self.uiset:setupMinimap(self.level) end
end

function _M:save()
	self.total_playtime = (self.total_playtime or 0) + (os.time() - (self.last_update or self.real_starttime))
	self.last_update = os.time()
	return class.save(self, self:defaultSavedFields{difficulty=true, permadeath=true, to_re_add_actors=true, party=true, _chronoworlds=true, total_playtime=true, on_level_load_fcts=true, visited_zones=true, bump_attack_disabled=true, show_npc_list=true}, true)
end

function _M:updateCurrentChar()
	if not self.party then return end
	local player = self.party:findMember{main=true}
	profile:currentCharacter(self.__mod_info.full_version_string, ("%s the level %d %s %s"):format(player.name, player.level, player.descriptor.subrace, player.descriptor.subclass), player.__te4_uuid)
end

function _M:getSaveDescription()
	local player = self.party:findMember{main=true}

	return {
		name = player.name,
		description = ([[%s the level %d %s %s.
Difficulty: %s / %s
Campaign: %s
Exploring level %d of %s.]]):format(
		player.name, player.level, player.descriptor.subrace, player.descriptor.subclass,
		player.descriptor.difficulty, player.descriptor.permadeath,
		player.descriptor.world,
		self.level.level, self.zone.name
		),
	}
end

function _M:getVaultDescription(e)
	e = e:findMember{main=true} -- Because vault "chars" are actualy parties for tome
	return {
		name = ([[%s the %s %s]]):format(e.name, e.descriptor.subrace, e.descriptor.subclass),
		descriptors = e.descriptor,
		description = ([[%s the %s %s.
Difficulty: %s / %s
Campaign: %s]]):format(
		e.name, e.descriptor.subrace, e.descriptor.subclass,
		e.descriptor.difficulty, e.descriptor.permadeath,
		e.descriptor.world
		),
	}
end

function _M:getStore(def)
	return Store.stores_def[def]:clone()
end

function _M:leaveLevel(level, lev, old_lev)
	self.to_re_add_actors = self.to_re_add_actors or {}

	if level:hasEntity(self.player) then
		level.exited = level.exited or {}
		if lev > old_lev then
			level.exited.down = {x=self.player.x, y=self.player.y}
		else
			level.exited.up = {x=self.player.x, y=self.player.y}
		end
	end

	if level.no_remove_entities then return end

	level.last_turn = self.turn
	for act, _ in pairs(self.party.members) do
		if self.player ~= act and level:hasEntity(act) then
			level:removeEntity(act)
			self.to_re_add_actors[act] = true
		end
	end
	if level:hasEntity(self.player) then level:removeEntity(self.player) end
end

function _M:onLevelLoad(id, fct, data)
	if self.zone and self.level and id == self.zone.short_name.."-"..self.level.level then
		print("Direct execute of on level load", id, fct, data)
		fct(self.zone, self.level, data)
		return
	end

	self.on_level_load_fcts = self.on_level_load_fcts or {}
	self.on_level_load_fcts[id] = self.on_level_load_fcts[id] or {}
	local l = self.on_level_load_fcts[id]
	l[#l+1] = {fct=fct, data=data}
	print("Registering on level load", id, fct, data)
end

function _M:changeLevel(lev, zone, params)
	params = params or {}
	if not self.player.can_change_level then
		self.logPlayer(self.player, "#LIGHT_RED#You may not change level without your own body!")
		return
	end
	if zone and not self.player.can_change_zone then
		self.logPlayer(self.player, "#LIGHT_RED#You may not leave the zone with this character!")
		return
	end
	if self.player:hasEffect(self.player.EFF_PARADOX_CLONE) or self.player:hasEffect(self.player.EFF_IMMINENT_PARADOX_CLONE) then
		self.logPlayer(self.player, "#LIGHT_RED#You cannot escape your fate by leaving the level!")
		return
	end

	-- Transmo!
	local p = self:getPlayer(true)
	if not params.direct_switch and p:attr("has_transmo") and p:transmoGetNumberItems() > 0 then
		local d
		local titleupdator = self.player:getEncumberTitleUpdator("Transmogrification Chest")
		d = self.player:showEquipInven(titleupdator(), nil, function(o, inven, item, button, event)
			if not o then return end
			local ud = require("mod.dialogs.UseItemDialog").new(event == "button", self.player, o, item, inven, function(_, _, _, stop)
				d:generate()
				d:generateList()
				d:updateTitle(titleupdator())
				if stop then self:unregisterDialog(d) end
			end)
			self:registerDialog(ud)
		end)
		d.unload = function()
			local inven = p:getInven("INVEN")
			for i = #inven, 1, -1 do
				local o = inven[i]
				if o.__transmo then
					p:transmoInven(inven, i, o)
				end
			end
			self:changeLevelReal(lev, zone, params)
		end
		-- Select the chest tab
		d.c_inven.dont_update_last_tabs = true
		d.c_inven:switchTab{kind="transmo"}
		d:simplePopup("Transmogrification Chest", "When you close the inventory window, all items in the chest will be transmogrified.")
	else
		self:changeLevelReal(lev, zone, params)
	end
end

function _M:changeLevelReal(lev, zone, params)
	-- Unlock first!
	if not params.temporary_zone_shift_back and self.level and self.level.temp_shift_zone then
		self:changeLevelReal(1, "useless", {temporary_zone_shift_back=true})
	end

	local st = core.game.getTime()
	local sti = 1

	-- Finish stuff registered for the previous level
	self:onTickEndExecute()

	if self.zone and self.level then self.party:leftLevel() end

	if self.player:isTalentActive(self.player.T_JUMPGATE) then
		self.player:forceUseTalent(self.player.T_JUMPGATE, {ignore_energy=true})
	end

	if self.player:isTalentActive(self.player.T_JUMPGATE_TWO) then
		self.player:forceUseTalent(self.player.T_JUMPGATE_TWO, {ignore_energy=true})
	end

	-- clear chrono worlds and their various effects
	if self._chronoworlds then self._chronoworlds = nil end

	local left_zone = self.zone
	local old_lev = (self.level and not zone) and self.level.level or -1000
	if params.keep_old_lev then old_lev = self.level.level end

	local force_recreate = false
	local recreate_nothing = false
	local popup = nil
	local afternicer = nil

	-- We only switch temporarily, keep the old one around
	if params.temporary_zone_shift then
		self:leaveLevel(self.level, lev, old_lev)

		local oz, ol = self.zone, self.level
		if type(zone) == "string" then
			self.zone = Zone.new(zone)
		else
			self.zone = zone
		end
		if type(self.zone.save_per_level) == "nil" then self.zone.save_per_level = config.settings.tome.save_zone_levels and true or false end

		self.zone:getLevel(self, lev, old_lev, true)
		self.visited_zones[self.zone.short_name] = true

		self.level.temp_shift_zone = oz
		self.level.temp_shift_level = ol
	-- We switch back
	elseif params.temporary_zone_shift_back then
		popup = Dialog:simpleWaiter("Loading level", "Please wait while loading the level...", nil, 10000)
		core.display.forceRedraw()

		local old = self.level

		if self.zone and self.zone.on_leave then
			local nl, nz, stop = self.zone.on_leave(lev, old_lev, zone)
			if stop then return end
			if nl then lev = nl end
			if nz then zone = nz end
		end

		if self.zone and self.level then self.player:onLeaveLevel(self.zone, self.level) end
		if self.zone then
			self.zone:leaveLevel(false, lev, old_lev)
			self.zone:leave()
		end

		self.zone = old.temp_shift_zone
		self.level = old.temp_shift_level

		self.visited_zones[self.zone.short_name] = true
--		if self.level.map.closed then
			force_recreate = true
--		else
--			print("Reloading back map without having it closed")
--			recreate_nothing = true
--		end
	-- We move to a new zone as normal
	elseif not params.temporary_zone_shift then
		if self.zone and self.zone.on_leave then
			local nl, nz, stop = self.zone.on_leave(lev, old_lev, zone)
			if stop then return end
			if nl then lev = nl end
			if nz then zone = nz end
		end

		if self.zone and self.level then self.player:onLeaveLevel(self.zone, self.level) end

		if zone then
			if self.zone then
				self.zone:leaveLevel(false, lev, old_lev)
				self.zone:leave()
			end
			if type(zone) == "string" then
				self.zone = Zone.new(zone)
			else
				self.zone = zone
			end
			if self.zone.tier1 then
				if lev == 1 and game.state:tier1Killed(3) then
					lev = self.zone.max_level
					self.zone.tier1 = nil
					Dialog:simplePopup("Easy!", "This zone is so easy for you that you stroll to the last area with ease.")
				end
			end
			if type(self.zone.save_per_level) == "nil" then self.zone.save_per_level = config.settings.tome.save_zone_levels and true or false end
		end
		local _, new_level = self.zone:getLevel(self, lev, old_lev)
		self.visited_zones[self.zone.short_name] = true

		if new_level then
			afternicer = self.state:startEvents()
		end
	end

	-- Post process walls
	self.nicer_tiles:postProcessLevelTiles(self.level)

	-- Post process if needed once the nicer tiles are done
	if self.level.data and self.level.data.post_nicer_tiles then self.level.data.post_nicer_tiles(self.level) end

	-- After ? events ?
	if afternicer then afternicer() end

	-- Check if we need to switch the current guardian
	self.state:zoneCheckBackupGuardian()

	-- Check if we must do some special things on load of this level
	self.on_level_load_fcts = self.on_level_load_fcts or {}
	print("Running on level loads", self.zone.short_name.."-"..self.level.level)
	for i, fct in ipairs(self.on_level_load_fcts[self.zone.short_name.."-"..self.level.level] or {}) do
		fct.fct(self.zone, self.level, fct.data)
	end
	self.on_level_load_fcts[self.zone.short_name.."-"..self.level.level] = nil

	-- Decay level ?
	if self.level.last_turn and self.level.data.decay and self.level.last_turn + self.level.data.decay[1] * 10 < self.turn then
		local only = self.level.data.decay.only or nil
		if not only or only.actor then
--			local nb_actor, remain_actor = self.level:decay(Map.ACTOR, function(e) return not e.unique and not e.lore and not e.quest and self.level.last_turn + rng.range(self.level.data.decay[1], self.level.data.decay[2]) < self.turn * 10 end)
--			if not self.level.data.decay.no_respawn then
--				local gen = self.zone:getGenerator("actor", self.level)
--				if gen.regenFrom then gen:regenFrom(remain_actor) end
--			end
		end

		if not only or only.object then
			local nb_object, remain_object = self.level:decay(Map.OBJECT, function(e) return not e.unique and not e.lore and not e.quest and self.level.last_turn + rng.range(self.level.data.decay[1], self.level.data.decay[2]) < self.turn * 10 end)
--			if not self.level.data.decay.no_respawn then
--				local gen = self.zone:getGenerator("object", self.level)
--				if gen.regenFrom then gen:regenFrom(remain_object) end
--			end
		end
	end

	-- Move back to old wilderness position
	if self.zone.wilderness then
		self.player:move(self.player.wild_x, self.player.wild_y, true)
		self.player.last_wilderness = self.zone.short_name
	else
		local x, y = nil, nil
		if params.auto_zone_stair and left_zone then
			-- Dirty but quick
			local list = {}
			for i = 0, self.level.map.w - 1 do for j = 0, self.level.map.h - 1 do
				local idx = i + j * self.level.map.w
				if self.level.map.map[idx][Map.TERRAIN] and self.level.map.map[idx][Map.TERRAIN].change_zone == left_zone.short_name then
					list[#list+1] = {i, j}
				end
			end end
			if #list > 0 then x, y = unpack(rng.table(list)) end
		end

		-- Default to stairs
		if not x then
			if lev > old_lev and not params.force_down then x, y = self.level.default_up.x, self.level.default_up.y
			else x, y = self.level.default_down.x, self.level.default_down.y
			end
		end

		-- Check if there is already an actor at that location, if so move it
		x = x or 1 y = y or 1
		local blocking_actor = self.level.map(x, y, engine.Map.ACTOR)
		if blocking_actor then
			local newx, newy = util.findFreeGrid(x, y, 20, true, {[Map.ACTOR]=true})
			if newx and newy then blocking_actor:move(newx, newy, true)
			else blocking_actor:teleportRandom(x, y, 200) end
		end
		self.player:move(x, y, true)
	end
	self.player.changed = true
	if self.to_re_add_actors and not self.zone.wilderness then for act, _ in pairs(self.to_re_add_actors) do
		local x, y = util.findFreeGrid(self.player.x, self.player.y, 20, true, {[Map.ACTOR]=true})
		if x then act:move(x, y, true) end
	end end

	-- Re add entities
	self.level:addEntity(self.player)
	if self.to_re_add_actors and not self.zone.wilderness then
		for act, _ in pairs(self.to_re_add_actors) do
			self.level:addEntity(act)
			act:setTarget(nil)
			if act.ai_state and act.ai_state.tactic_leash_anchor then
				act.ai_state.tactic_leash_anchor = self.player
			end
		end
		self.to_re_add_actors = nil
	end

	if self.zone.on_enter then
		self.zone.on_enter(lev, old_lev, zone)
	end

	self.player:onEnterLevel(self.zone, self.level)
	self.player:resetMoveAnim()

	local musics = {}
	local keep_musics = false
	if self.level.data.ambient_music then
		if self.level.data.ambient_music ~= "last" then
			if type(self.level.data.ambient_music) == "string" then musics[#musics+1] = self.level.data.ambient_music
			elseif type(self.level.data.ambient_music) == "table" then for i, name in ipairs(self.level.data.ambient_music) do musics[#musics+1] = name end
			elseif type(self.level.data.ambient_music) == "function" then for i, name in ipairs{self.level.data.ambient_music()} do musics[#musics+1] = name end
			end
		elseif self.level.data.ambient_music == "last" then
			keep_musics = true
		end
	end
	if not keep_musics then self:playAndStopMusic(unpack(musics)) end

	-- Update the minimap
	self:setupMiniMap()

	-- Tell the map to use path strings to speed up path calculations
	for uid, e in pairs(self.level.entities) do
		if e.getPathString then
			self.level.map:addPathString(e:getPathString())
		end
	end
	self.zone_name_s = nil

	-- Special stuff
	for uid, act in pairs(self.level.entities) do
		if act.setEffect then
			if self.level.data.zero_gravity then act:setEffect(act.EFF_ZERO_GRAVITY, 1, {})
			else act:removeEffect(act.EFF_ZERO_GRAVITY, nil, true) end
		end
	end

	-- Level feeling
	local feeling
	if self.level.special_feeling then
		feeling = self.level.special_feeling
	else
		local lev = self.zone.base_level + self.level.level - 1
		if self.zone.level_adjust_level then lev = self.zone:level_adjust_level(self.level) end
		local diff = lev - self.player.level
		if diff >= 5 then feeling = "You feel a thrill of terror and your heart begins to pound in your chest. You feel terribly threatened upon entering this area."
		elseif diff >= 2 then feeling = "You feel mildly anxious, and walk with caution."
		elseif diff >= -2 then feeling = nil
		elseif diff >= -5 then feeling = "You feel very confident walking into this place."
		else feeling = "You stride into this area without a second thought, while stifling a yawn. You feel your time might be better spent elsewhere."
		end
	end
	if feeling then self.log("#TEAL#%s", feeling) end

	-- Autosave
--	if config.settings.tome.autosave and not config.settings.cheat and ((left_zone and left_zone.short_name ~= "wilderness") or self.zone.save_per_level) and (left_zone and left_zone.short_name ~= self.zone.short_name) then self:saveGame() end

	self.player:onEnterLevelEnd(self.zone, self.level)

	-- Day/Night cycle
	if self.level.data.day_night then self.state:dayNightCycle() end

	if not recreate_nothing then
		self.level.map:redisplay()
		self.level.map:reopen()
		if force_recreate then self.level.map:recreate() end
	end

	-- Anti stairscum
	if self.level.last_turn and self.level.last_turn < self.turn then
		local perc = util.bound(math.floor((self.turn - self.level.last_turn) / 10), 0, 10)
		for uid, target in pairs(self.level.entities) do
			if target.life and target.max_life and self.player:reactionToward(target) < 0 then
				target.life = util.bound(target.life + target.max_life * perc / 10, 0, target.max_life)
				target.changed = true
				target.talents_cd = {}

				local todel = {}
				for eff_id, p in pairs(target.tmp) do
					local e = target.tempeffect_def[eff_id]
					if e.status == "detrimental" then todel[#todel+1] = eff_id end
				end
				while #todel > 0 do
					target:removeEffect(table.remove(todel))
				end
			end
		end
	end

	if popup then popup:done() end

	self:dieClonesDie()
end

function _M:dieClonesDie()
	if not self.level then return end
	local p = self:getPlayer(true)
	if not p.puuid then return end
	for uid, e in pairs(self.level.entities) do
		if p.puuid == e.puuid and e ~= p then self.level:removeEntity(e) end
	end
end

function _M:getPlayer(main)
	if main then
		return self.party:findMember{main=true}
	else
		return self.player
	end
end

--- Says if this savefile is usable or not
function _M:isLoadable()
	return not self:getPlayer(true).dead
end

--- Clones the game world for chronomancy spells
function _M:chronoClone(name)
	self:getPlayer(true):attr("time_travel_times", 1)

	local d = Dialog:simpleWaiter("Chronomancy", "Folding the space time structure...")

	local to_reload = {}
	for uid, e in pairs(self.level.entities) do
		if type(e.project) == "table" and e.project.def and e.project.def.typ and e.project.def.typ.line_function then
			e.project.def.typ.line_function.line = { game.level.map.w, game.level.map.h, e.project.def.typ.line_function:export() }
			to_reload[#to_reload + 1] = e
		end
	end

	local ret = self:cloneFull()

	for uid, e in pairs(to_reload) do e:loaded() end

	if name then
		self._chronoworlds = self._chronoworlds or {}
		self._chronoworlds[name] = ret
		ret = nil
	end
	d:done()
	return ret
end

--- Restores a chronomancy clone
function _M:chronoRestore(name, remove)
	local ngame
	if type(name) == "string" then
		ngame = self._chronoworlds[name]
		if remove then self._chronoworlds[name] = nil end
	else ngame = name end
	if not ngame then return false end

	local d = Dialog:simpleWaiter("Chronomancy", "Unfolding the space time structure...")

	ngame:cloneReloaded()
	_G.game = ngame

	game.inited = nil
	game:run()
	game.key:setupRebootKeys() -- engine does it for us but not on chronoworld reload
	game.key:setCurrent()
	game.mouse:setCurrent()
	profile.chat:setupOnGame()

	core.wait.disable() -- "game" changed, we cant just unload the dialog, it doesnt exist anymore
	return true
end

--- Update the zone name, if needed
function _M:updateZoneName()
	local name
	if self.zone.display_name then
		name = self.zone.display_name()
	else
		local lev = self.level.level
		if self.level.data.reverse_level_display then lev = 1 + self.level.data.max_level - lev end
		if self.zone.max_level == 1 then
			name = self.zone.name
		else
			name = ("%s (%d)"):format(self.zone.name, lev)
		end
	end
	if self.zone_name_s and self.old_zone_name == name then return end

	self.zone_font:setStyle("bold")
	local s = core.display.drawStringBlendedNewSurface(self.zone_font, name, unpack(colors.simple(colors.GOLD)))
	self.zone_font:setStyle("normal")
	self.zone_name_w, self.zone_name_h = s:getSize()
	self.zone_name_s, self.zone_name_tw, self.zone_name_th = s:glTexture()
	self.old_zone_name = name
	print("Updating zone name", name)
end

function _M:tick()
	if self.level then
		self:targetOnTick()

		engine.GameTurnBased.tick(self)
		-- Fun stuff: this can make the game realtime, although calling it in display() will make it work better
		-- (since display is on a set FPS while tick() ticks as much as possible
		-- engine.GameEnergyBased.tick(self)
	else
		engine.Game.tick(self)
	end

	-- Check damages to log
	self:displayDelayedLogDamage()

	if self.tick_loopback then
		self.tick_loopback = nil
		return self:tick()
	end

	if savefile_pipe.saving then self.player.changed = true end
	if self.paused and not savefile_pipe.saving then return true end
--	if self.on_tick_end and #self.on_tick_end > 0 then return true end
end

function _M:displayDelayedLogDamage()
	for src, tgts in pairs(self.delayed_log_damage) do
		for target, dams in pairs(tgts) do
			if #dams.descs > 1 then
				self.logSeen(target, "%s hits %s for %s damage (total %0.2f).", src.name:capitalize(), target.name, table.concat(dams.descs, ", "), dams.total)
			else
				self.logSeen(target, "%s hits %s for %s damage.", src.name:capitalize(), target.name, table.concat(dams.descs, ", "))
			end

			local rsrc = src.resolveSource and src:resolveSource() or src
			local rtarget = target.resolveSource and target:resolveSource() or target
			local x, y = target.x or -1, target.y or -1
			local sx, sy = self.level.map:getTileToScreen(x, y)
			if target.dead then
				if self.level.map.seens(x, y) and (rsrc == self.player or rtarget == self.player or self.party:hasMember(rsrc) or self.party:hasMember(rtarget)) then
					self.flyers:add(sx, sy, 30, (rng.range(0,2)-1) * 0.5, rng.float(-2.5, -1.5), ("Kill (%d)!"):format(dams.total), {255,0,255}, true)
					game.logSeen(target, "#{bold}#%s killed %s!#{normal}#", src.name:capitalize(), target.name)
				end
			else
				if self.level.map.seens(x, y) and (rsrc == self.player or self.party:hasMember(rsrc)) then
					self.flyers:add(sx, sy, 30, (rng.range(0,2)-1) * 0.5, rng.float(-3, -2), tostring(-math.ceil(dams.total)), {0,255,0})
				elseif self.level.map.seens(x, y) and (rtarget == self.player or self.party:hasMember(rtarget)) then
					self.flyers:add(sx, sy, 30, (rng.range(0,2)-1) * 0.5, -rng.float(-3, -2), tostring(-math.ceil(dams.total)), {255,0,0})
				end
			end
		end
	end
	if self.delayed_death_message then game.log(self.delayed_death_message) end
	self.delayed_death_message = nil
	self.delayed_log_damage = {}
end

function _M:delayedLogDamage(src, target, dam, desc)
	self.delayed_log_damage[src] = self.delayed_log_damage[src] or {}
	self.delayed_log_damage[src][target] = self.delayed_log_damage[src][target] or {total=0, descs={}}
	local t = self.delayed_log_damage[src][target]
	t.descs[#t.descs+1] = desc
	t.total = t.total + dam
end

--- Called every game turns
-- Does nothing, you can override it
function _M:onTurn()
	if self.zone then
		if self.zone.on_turn then self.zone:on_turn() end
	end

	-- The following happens only every 10 game turns (once for every turn of 1 mod speed actors)
	if self.turn % 10 ~= 0 then return end

	-- Day/Night cycle
	if self.level.data.day_night then self.state:dayNightCycle() end

	-- Process overlay effects
	self.level.map:processEffects()

	if not self.day_of_year or self.day_of_year ~= self.calendar:getDayOfYear(self.turn) then
		self.log(self.calendar:getTimeDate(self.turn))
		self.day_of_year = self.calendar:getDayOfYear(self.turn)
	end

	if self.turn % 500 ~= 0 then return end
	self:dieClonesDie()
end

function _M:updateFOV()
	self.player:playerFOV()
end

function _M:displayMap(nb_keyframes)
	-- Now the map, if any
	if self.level and self.level.map and self.level.map.finished then
		local map = self.level.map

		-- Display the map and compute FOV for the player if needed
		local changed = map.changed
		if changed then self:updateFOV() end

		-- Display using Framebuffer, so that we can use shaders and all
		if self.fbo then
			self.fbo:use(true)
				if self.level.data.background then self.level.data.background(self.level, 0, 0, nb_keyframes) end
				map:display(0, 0, nb_keyframes, config.settings.tome.smooth_fov)
				if self.level.data.foreground then self.level.data.foreground(self.level, 0, 0, nb_keyframes) end
				if self.level.data.weather_particle then self.state:displayWeather(self.level, self.level.data.weather_particle, nb_keyframes) end
				if self.level.data.weather_shader then self.state:displayWeatherShader(self.level, self.level.data.weather_shader, map.display_x, map.display_y, nb_keyframes) end
				if config.settings.tome.smooth_fov then map._map:drawSeensTexture(0, 0, nb_keyframes) end
			self.fbo:use(false, self.full_fbo)

			_2DNoise:bind(1, false)
			self.fbo:toScreen(map.display_x, map.display_y, map.viewport.width, map.viewport.height, self.fbo_shader.shad)
			if self.target then self.target:display() end

		-- Basic display; no FBOs
		else
			if self.level.data.background then self.level.data.background(self.level, map.display_x, map.display_y, nb_keyframes) end
			map:display(nil, nil, nb_keyframes, config.settings.tome.smooth_fov)
			if self.target then self.target:display() end
			if self.level.data.foreground then self.level.data.foreground(self.level, map.display_x, map.display_y, nb_keyframes) end
			if self.level.data.weather_particle then self.state:displayWeather(self.level, self.level.data.weather_particle, nb_keyframes) end
			if self.level.data.weather_shader then self.state:displayWeatherShader(self.level, self.level.data.weather_shader, map.display_x, map.display_y, nb_keyframes) end
			if config.settings.tome.smooth_fov then map._map:drawSeensTexture(map.display_x, map.display_y, nb_keyframes) end
		end

		-- Handle ambient sounds
		if self.level.data.ambient_bg_sounds then self.state:playAmbientSounds(self.level, self.level.data.ambient_bg_sounds, nb_keyframes) end

		if not self.zone_name_s then self:updateZoneName() end

		-- emotes display
		map:displayEmotes(nb_keyframe or 1)

		-- Mouse gestures
		self.gestures:update()
		self.gestures:display(map.display_x, map.display_y + map.viewport.height - self.gestures.font_h - 5)

		-- Inform the player that map is in scroll mode
		if core.key.modState("caps") then
			local w = map.viewport.width * 0.5
			local h = w * self.caps_scroll.h / self.caps_scroll.w
			self.caps_scroll[1]:toScreenFull(
				map.display_x + (map.viewport.width - w) / 2,
				map.display_y + (map.viewport.height - h) / 2,
				w, h,
				self.caps_scroll[2] * w / self.caps_scroll.w, self.caps_scroll[3] * h / self.caps_scroll.h,
				1, 1, 1, 0.5
			)
		end
	end
end

--- Called when screen resolution changes
function _M:checkResolutionChange(w, h, ow, oh)
	self:createFBOs()

	return self.uiset:handleResolutionChange(w, h, ow, oh)
end

function _M:display(nb_keyframes)
	-- If switching resolution, blank everything but the dialog
	if self.change_res_dialog then engine.GameTurnBased.display(self, nb_keyframes) return end

	if self.full_fbo then self.full_fbo:use(true) end

	-- Now the ui
	self.uiset:display(nb_keyframes)

	-- "Big News"
	self.bignews:display(nb_keyframes)

	if self.player then self.player.changed = false end

	engine.GameTurnBased.display(self, nb_keyframes)

	-- Tooltip is displayed over all else, even dialogs but before FBO
	local mx, my, button = core.mouse.get()

	self.old_ctrl_state = self.ctrl_state
	self.ctrl_state = core.key.modState("ctrl")

	-- if tooltip is in way of mouse and its not locked then move it
	if self.tooltip.w and mx > self.w - self.tooltip.w and my > Tooltip:tooltip_bound_y2() - self.tooltip.h and not self.tooltip.locked then
		self:targetDisplayTooltip(Map.display_x, self.h, self.old_ctrl_state~=self.ctrl_state, nb_keyframes )
	else
		self:targetDisplayTooltip(self.w, self.h, self.old_ctrl_state~=self.ctrl_state, nb_keyframes )
	end

	if self.full_fbo then
		self.full_fbo:use(false)
		self.full_fbo:toScreen(0, 0, self.w, self.h, self.full_fbo_shader.shad)
	end

end

--- Called when a dialog is registered to appear on screen
function _M:onRegisterDialog(d)
	-- Clean up tooltip
	self.tooltip_x, self.tooltip_y = nil, nil
	self.tooltip2_x, self.tooltip2_y = nil, nil
	if self.player then self.player:updateMainShader() end
end
function _M:onUnregisterDialog(d)
	-- Clean up tooltip
	self.tooltip_x, self.tooltip_y = nil, nil
	self.tooltip2_x, self.tooltip2_y = nil, nil
	if self.player then self.player:updateMainShader() self.player.changed = true end
end

function _M:setupCommands()
	-- Make targeting work
	self.normal_key = self.key
	self:targetSetupKey()

	-- Activate profiler keybinds
	self.key:setupProfiler()

	-- Activate mouse gestures
	self.gestures = Gestures.new("Gesture: ", self.key, true)

	-- Helper function to not allow some actions on the wilderness map
	local not_wild = function(f) return function(...) if self.zone and not self.zone.wilderness then f(...) else self.logPlayer(self.player, "You cannot do that on the world map.") end end end

	-- Debug mode
	self.key:addCommands{
		[{"_d","ctrl"}] = function() if config.settings.cheat then
			local g = self.level.map(self.player.x, self.player.y, Map.TERRAIN)
			print(g.define_as, g.image, g.z)
			for i, a in ipairs(g.add_mos or {}) do print(" => ", a.image) end
			local add = g.add_displays
			if add then for i, e in ipairs(add) do
				print(" -", e.image, e.z)
				for i, a in ipairs(e.add_mos or {}) do print("   => ", a.image) end
			end end
		end end,
		[{"_g","ctrl"}] = function() if config.settings.cheat then
			local x, y = game.player.x + 5, game.player.y
			--game.level.map:particleEmitter(game.player.x, game.player.y, math.max(math.abs(x-game.player.x), math.abs(y-game.player.y)), "lightning_beam", {tx=x-game.player.x, ty=y-game.player.y}, {type="lightning"})
			game.level.map:particleEmitter(game.player.x, game.player.y, math.max(math.abs(-5), math.abs(y-game.player.y)), "lightning_beam", {tx=-5, ty=y-game.player.y}, {type="lightning"})
--			game.level.map:particleEmitter(game.player.x, game.player.y, 3, "lightning_shield", {radius=2}, {type="lightning"})
--			game.level.map:particleEmitter(game.player.x, game.player.y, math.max(math.abs(-5), math.abs(y-game.player.y)), "lightning_beam", {tx=-5, ty=y-game.player.y})
			
do return end
			local f, err = loadfile("/data/general/events/glowing-chest.lua")
			print(f, err)
			setfenv(f, setmetatable({level=self.level, zone=self.zone}, {__index=_G}))
			print(pcall(f))
do return end
			self:registerDialog(require("mod.dialogs.DownloadCharball").new())
		end end,
		[{"_f","ctrl"}] = function() if config.settings.cheat then
			self.player.quests["love-melinda"] = nil
			self.player:grantQuest("love-melinda")
			self.player:hasQuest("love-melinda"):melindaCompanion(self.player, "Defiler", "Corruptor")
		end end,
		[{"_UP","ctrl"}] = function()
			game.tooltip.container.scrollbar.pos = util.minBound(game.tooltip.container.scrollbar.pos - 1, 0, game.tooltip.container.scrollbar.max)
		end,
		[{"_DOWN","ctrl"}] = function()
			game.tooltip.container.scrollbar.pos = util.minBound(game.tooltip.container.scrollbar.pos + 1, 0, game.tooltip.container.scrollbar.max)
		end,
		[{"_HOME","ctrl"}] = function()
			game.tooltip.container.scrollbar.pos = 0
		end,
		[{"_END","ctrl"}] = function()
			game.tooltip.container.scrollbar.pos = game.tooltip.container.scrollbar.max
		end,
	}

	self.key.any_key = function(sym)
		-- Control resets the tooltip
		if sym == self.key._LCTRL or sym == self.key._RCTRL then
			self.player.changed = true
			self.tooltip.old_tmx = nil
		elseif sym == self.key._LSHIFT or sym == self.key._RSHIFT then
			self.player.changed = true
		end
	end
	self.key:unicodeInput(true)
	self.key:addBinds
	{
		-- Movements
		MOVE_LEFT = function() if core.key.modState("caps") and self.level then self.level.map:scrollDir(4) else self.player:moveDir(4) end end,
		MOVE_RIGHT = function() if core.key.modState("caps") and self.level then self.level.map:scrollDir(6) else self.player:moveDir(6) end end,
		MOVE_UP = function() if core.key.modState("caps") and self.level then self.level.map:scrollDir(8) else self.player:moveDir(8) end end,
		MOVE_DOWN = function() if core.key.modState("caps") and self.level then self.level.map:scrollDir(2) else self.player:moveDir(2) end end,
		MOVE_LEFT_UP = function() if core.key.modState("caps") and self.level then self.level.map:scrollDir(7) else self.player:moveDir(7) end end,
		MOVE_LEFT_DOWN = function() if core.key.modState("caps") and self.level then self.level.map:scrollDir(1) else self.player:moveDir(1) end end,
		MOVE_RIGHT_UP = function() if core.key.modState("caps") and self.level then self.level.map:scrollDir(9) else self.player:moveDir(9) end end,
		MOVE_RIGHT_DOWN = function() if core.key.modState("caps") and self.level then self.level.map:scrollDir(3) else self.player:moveDir(3) end end,
		MOVE_STAY = function() if core.key.modState("caps") and self.level then self.level.map:centerViewAround(self.player.x, self.player.y) else if self.player:enoughEnergy() then self.player:describeFloor(self.player.x, self.player.y) self.player:useEnergy() end end end,

		RUN = function()
			self.log("Run in which direction?")
			local co = coroutine.create(function()
				local x, y = self.player:getTarget{type="hit", no_restrict=true, range=1, immediate_keys=true, default_target=self.player}
				if x and y then self.player:runInit(util.getDir(x, y, self.player.x, self.player.y)) end
			end)
			local ok, err = coroutine.resume(co)
			if not ok and err then print(debug.traceback(co)) error(err) end
		end,

		RUN_AUTO = function()
			local ae = function() if self.level and self.zone then
				local seen = {}
				-- Check for visible monsters.  Only see LOS actors, so telepathy wont prevent it
				core.fov.calc_circle(self.player.x, self.player.y, self.level.map.w, self.level.map.h, self.player.sight or 10,
					function(_, x, y) return self.level.map:opaque(x, y) end,
					function(_, x, y)
						local actor = self.level.map(x, y, self.level.map.ACTOR)
						if actor and actor ~= self.player and self.player:reactionToward(actor) < 0 and
							self.player:canSee(actor) and self.level.map.seens(x, y) then seen[#seen + 1] = {x=x, y=y, actor=actor} end
					end, nil)
				if self.zone.no_autoexplore or self.level.no_autoexplore then
					self.log("You may not auto-explore this level.")
				elseif #seen > 0 then
					self.log("You may not auto-explore with enemies in sight!")
					for _, node in ipairs(seen) do
						node.actor:addParticles(engine.Particles.new("notice_enemy", 1))
					end
				elseif not self.player:autoExplore() then
					self.log("There is nowhere left to explore.")
				end
			end end

			if config.settings.tome.rest_before_explore then
				local ok = false
				self.player:restInit(nil, nil, nil, function() ok = self.player.resting.rested_fully end, function() if ok then self:onTickEnd(ae) self.tick_loopback = true end end)
			else
				ae()
			end
		end,

		RUN_LEFT = function() self.player:runInit(4) end,
		RUN_RIGHT = function() self.player:runInit(6) end,
		RUN_UP = function() self.player:runInit(8) end,
		RUN_DOWN = function() self.player:runInit(2) end,
		RUN_LEFT_UP = function() self.player:runInit(7) end,
		RUN_LEFT_DOWN = function() self.player:runInit(1) end,
		RUN_RIGHT_UP = function() self.player:runInit(9) end,
		RUN_RIGHT_DOWN = function() self.player:runInit(3) end,

		ATTACK_OR_MOVE_LEFT = function() self.player:attackOrMoveDir(4) end,
		ATTACK_OR_MOVE_RIGHT = function() self.player:attackOrMoveDir(6) end,
		ATTACK_OR_MOVE_UP = function() self.player:attackOrMoveDir(8) end,
		ATTACK_OR_MOVE_DOWN = function() self.player:attackOrMoveDir(2) end,
		ATTACK_OR_MOVE_LEFT_UP = function() self.player:attackOrMoveDir(7) end,
		ATTACK_OR_MOVE_LEFT_DOWN = function() self.player:attackOrMoveDir(1) end,
		ATTACK_OR_MOVE_RIGHT_UP = function() self.player:attackOrMoveDir(9) end,
		ATTACK_OR_MOVE_RIGHT_DOWN = function() self.player:attackOrMoveDir(3) end,

		-- Hotkeys
		-- bindings done after
		HOTKEY_PREV_PAGE = not_wild(function() self.player:prevHotkeyPage() self.log("Hotkey page %d is now displayed.", self.player.hotkey_page) end),
		HOTKEY_NEXT_PAGE = not_wild(function() self.player:nextHotkeyPage() self.log("Hotkey page %d is now displayed.", self.player.hotkey_page) end),

		-- Party commands
		SWITCH_PARTY_1 = not_wild(function() self.party:select(1) end),
		SWITCH_PARTY_2 = not_wild(function() self.party:select(2) end),
		SWITCH_PARTY_3 = not_wild(function() self.party:select(3) end),
		SWITCH_PARTY_4 = not_wild(function() self.party:select(4) end),
		SWITCH_PARTY_5 = not_wild(function() self.party:select(5) end),
		SWITCH_PARTY_6 = not_wild(function() self.party:select(6) end),
		SWITCH_PARTY_7 = not_wild(function() self.party:select(7) end),
		SWITCH_PARTY_8 = not_wild(function() self.party:select(8) end),
		SWITCH_PARTY = not_wild(function() self:registerDialog(require("mod.dialogs.PartySelect").new()) end),
		ORDER_PARTY_1 = not_wild(function() self.party:giveOrders(1) end),
		ORDER_PARTY_2 = not_wild(function() self.party:giveOrders(2) end),
		ORDER_PARTY_3 = not_wild(function() self.party:giveOrders(3) end),
		ORDER_PARTY_4 = not_wild(function() self.party:giveOrders(4) end),
		ORDER_PARTY_5 = not_wild(function() self.party:giveOrders(5) end),
		ORDER_PARTY_6 = not_wild(function() self.party:giveOrders(6) end),
		ORDER_PARTY_7 = not_wild(function() self.party:giveOrders(7) end),
		ORDER_PARTY_8 = not_wild(function() self.party:giveOrders(8) end),

		-- Actions
		CHANGE_LEVEL = function()
			local e = self.level.map(self.player.x, self.player.y, Map.TERRAIN)
			if self.player:enoughEnergy() and e.change_level then
				if self.player:attr("never_move") then self.log("You cannot currently leave the level.") return end

				local stop = {}
				for eff_id, p in pairs(self.player.tmp) do
					local e = self.player.tempeffect_def[eff_id]
					if e.status == "detrimental" and not e.no_stop_enter_worlmap then stop[#stop+1] = e.desc end
				end

				if e.change_zone and #stop > 0 and e.change_zone:find("^wilderness") then
					self.log("You cannot go into the wilds with the following effects: %s", table.concat(stop, ", "))
				else
					-- Do not unpause, the player is allowed first move on next level
					if e.change_level_check and e:change_level_check(self.player) then return end
					self:changeLevel(e.change_zone and e.change_level or self.level.level + e.change_level, e.change_zone, {keep_old_lev=e.keep_old_lev, force_down=e.force_down, auto_zone_stair=e.change_zone_auto_stairs, temporary_zone_shift_back=e.change_level_shift_back})
				end
			else
				self.log("There is no way out of this level here.")
			end
		end,

		REST = function()
			self.player:restInit()
		end,

		PICKUP_FLOOR = not_wild(function()
			if self.player.no_inventory_access then return end
			self.player:playerPickup()
		end),
		DROP_FLOOR = function()
			if self.player.no_inventory_access then return end
			self.player:playerDrop()
		end,
		SHOW_INVENTORY = function()
			if self.player.no_inventory_access then return end
			local d
			local titleupdator = self.player:getEncumberTitleUpdator("Inventory")
			d = self.player:showEquipInven(titleupdator(), nil, function(o, inven, item, button, event)
				if not o then return end
				local ud = require("mod.dialogs.UseItemDialog").new(event == "button", self.player, o, item, inven, function(_, _, _, stop)
					d:generate()
					d:generateList()
					d:updateTitle(titleupdator())
					if stop then self:unregisterDialog(d) end
				end)
				self:registerDialog(ud)
			end)
		end,
		SHOW_EQUIPMENT = "SHOW_INVENTORY",
		WEAR_ITEM = function()
			if self.player.no_inventory_access then return end
			self.player:playerWear()
		end,
		TAKEOFF_ITEM = function()
			if self.player.no_inventory_access then return end
			self.player:playerTakeoff()
		end,
		USE_ITEM = not_wild(function()
			if self.player.no_inventory_access then return end
			self.player:playerUseItem()
		end),

		QUICK_SWITCH_WEAPON = function()
			if self.player.no_inventory_access then return end
			self.player:quickSwitchWeapons()
		end,

		USE_TALENTS = not_wild(function()
			self:registerDialog(require("mod.dialogs.UseTalents").new(self.player))
		end),

		LEVELUP = function()
			self.player:playerLevelup(nil, false)
		end,

		SAVE_GAME = function()
			self:saveGame()
		end,

		SHOW_QUESTS = function()
			self:registerDialog(require("engine.dialogs.ShowQuests").new(self.party:findMember{main=true}))
		end,

		SHOW_CHARACTER_SHEET = function()
			self:registerDialog(require("mod.dialogs.CharacterSheet").new(self.player))
		end,

		SHOW_MESSAGE_LOG = function()
			self:registerDialog(require("mod.dialogs.ShowChatLog").new("Message Log", 0.6, self.uiset.logdisplay, profile.chat))
		end,

		-- Show time
		SHOW_TIME = function()
			self.log(self.calendar:getTimeDate(self.turn))
		end,
		-- Exit the game
		QUIT_GAME = function()
			self:onQuit()
		end,
		-- Lua console
		LUA_CONSOLE = function()
			if config.settings.cheat then
				self:registerDialog(DebugConsole.new())
			end
		end,
		-- Debug dialog
		DEBUG_MODE = function()
			if config.settings.cheat then
				self:registerDialog(require("mod.dialogs.debug.DebugMain").new())
			end
		end,

		-- Toggle monster list
		TOGGLE_NPC_LIST = function()
			self.show_npc_list = not self.show_npc_list
			self.player.changed = true

			if (self.show_npc_list) then
				self.log("Displaying creatures.")
			else
				self.log("Displaying talents.")
			end
		end,

		SCREENSHOT = function() self:saveScreenshot() end,

		HELP = "EXIT",
		EXIT = function()
			if self.tooltip.locked then
				self.tooltip.locked = false
				self.tooltip.container.focused = self.tooltip.locked
				game.log("Tooltip %s", self.tooltip.locked and "locked" or "unlocked")
			end
			local menu
			local l = {
				"resume",
				"achievements",
				{ "Show known Lore", function() self:unregisterDialog(menu) self:registerDialog(require("mod.dialogs.ShowLore").new("Tales of Maj'Eyal Lore", self.player)) end },
				{ "Show ingredients", function() self:unregisterDialog(menu) self:registerDialog(require("mod.dialogs.ShowIngredients").new(self.party)) end },
				"highscores",
				{ "Inventory", function() self:unregisterDialog(menu) self.key:triggerVirtual("SHOW_INVENTORY") end },
				{ "Character Sheet", function() self:unregisterDialog(menu) self.key:triggerVirtual("SHOW_CHARACTER_SHEET") end },
				"keybinds",
				{"Graphic Mode", function() self:unregisterDialog(menu) self:registerDialog(require("mod.dialogs.GraphicMode").new()) end},
				{"Game Options", function() self:unregisterDialog(menu) self:registerDialog(require("mod.dialogs.GameOptions").new()) end},
				"video",
				"sound",
				"save",
				"quit"
			}
			local adds = self.uiset:getMainMenuItems()
			for i = #adds, 1, -1 do table.insert(l, 10, adds[i]) end
			self:triggerHook{"Game:alterGameMenu", menu=l, unregister=function() self:unregisterDialog(menu) end}
			menu = require("engine.dialogs.GameMenu").new(l)
			self:registerDialog(menu)
		end,

		TACTICAL_DISPLAY = function()
			if self.always_target == true then
				self.always_target = "health"
				Map:setViewerFaction(nil)
				self.log("Showing healthbars only.")
			elseif self.always_target == nil then
				self.always_target = true
				Map:setViewerFaction(self.player.faction)
				self.log("Showing healthbars and tactical borders.")
			elseif self.always_target == "health" then
				self.always_target = nil
				Map:setViewerFaction(nil)
				self.log("Showing no tactical information.")
			end
		end,

		LOOK_AROUND = function()
			self.log("Looking around... (direction keys to select interesting things, shift+direction keys to move freely)")
			local co = coroutine.create(function()
				local x, y = self.player:getTarget{type="hit", no_restrict=true, range=2000}
				if x and y then
					local tmx, tmy = self.level.map:getTileToScreen(x, y)
					self:registerDialog(MapMenu.new(tmx, tmy, x, y))
				end
			end)
			local ok, err = coroutine.resume(co)
			if not ok and err then print(debug.traceback(co)) error(err) end
		end,

		LOCK_TOOLTIP = function()
			if not self.tooltip.empty then
				self.tooltip.locked = not self.tooltip.locked
				self.tooltip.container.focused = self.tooltip.locked
				game.log("Tooltip %s", self.tooltip.locked and "locked" or "unlocked")
			end
		end,

		LOCK_TOOLTIP_COMPARE = function()
			if not self.tooltip.empty then
				self.tooltip.locked = not self.tooltip.locked
				self.tooltip.container.focused = self.tooltip.locked
				game.log("Tooltip %s", self.tooltip.locked and "locked" or "unlocked")
			end
		end,

		SHOW_MAP = function()
			if config.settings.tome.uiset_mode == "Minimalist" then
				self.uiset.mm_mode = util.boundWrap((self.uiset.mm_mode or 2) + 1, 1, 3)
				if self.uiset.mm_mode == 1 then
					self.uiset.no_minimap = true
				elseif self.uiset.mm_mode == 2 then
					self.uiset.no_minimap = false
				elseif self.uiset.mm_mode == 3 then
					game:registerDialog(require("mod.dialogs.ShowMap").new(function() self.uiset.mm_mode = 1 self.uiset.no_minimap = true end))
				end
			else
				game:registerDialog(require("mod.dialogs.ShowMap").new())
			end
		end,

		USERCHAT_SHOW_TALK = function()
			self.show_userchat = not self.show_userchat
		end,

		TOGGLE_UI = function()
			self.uiset:toggleUI()
		end,

		TOGGLE_BUMP_ATTACK = function()
			local game_or_player = not config.settings.tome.actor_based_movement_mode and self or game.player

			if game_or_player.bump_attack_disabled then
				self.log("Movement Mode: #LIGHT_GREEN#Default#LAST#.")
				game_or_player.bump_attack_disabled = false
			else
				self.log("Movement Mode: #LIGHT_RED#Passive#LAST#.")
				game_or_player.bump_attack_disabled = true
			end
		end
	}
	engine.interface.PlayerHotkeys:bindAllHotkeys(self.key, not_wild(function(i) self.player:activateHotkey(i) end))

	self.key:setCurrent()
end

function _M:setupMouse(reset)
	if reset == nil or reset then self.mouse:reset() end
	self.mouse:registerZone(Map.display_x, Map.display_y, Map.viewport.width, Map.viewport.height, function(button, mx, my, xrel, yrel, bx, by, event, extra)
		self.tooltip.add_map_str = extra and extra.log_str

		if game.tooltip.locked then
			if button == "wheelup" and event == "button" then
				game.tooltip.container.scrollbar.pos = util.minBound(game.tooltip.container.scrollbar.pos - 1, 0, game.tooltip.container.scrollbar.max)
			elseif button == "wheeldown" and event == "button" then
				game.tooltip.container.scrollbar.pos = util.minBound(game.tooltip.container.scrollbar.pos + 1, 0, game.tooltip.container.scrollbar.max)
			end
			if button == "middle" then
				if not game.tooltip.container.draging then
					game.tooltip.container.draging = true
					game.tooltip.container.drag_x_start = mx
					game.tooltip.container.drag_y_start = my
				else
					game.tooltip.container.scrollbar.pos = util.minBound(game.tooltip.container.scrollbar.pos + my - game.tooltip.container.drag_y_start, 0, game.tooltip.container.scrollbar.max)
					game.tooltip.container.drag_x_start = mx
					game.tooltip.container.drag_y_start = my
				end
			else
				game.tooltip.container.draging = false
			end
		end

		-- Handle targeting
		if self:targetMouse(button, mx, my, xrel, yrel, event) then return end

		-- Cheat kill
		if config.settings.cheat and button == "right" and core.key.modState("ctrl") and core.key.modState("shift") and not xrel and not yrel and event == "button" and self.zone and not self.zone.wilderness then
			local tmx, tmy = game.level.map:getMouseTile(mx, my)
			local target = game.level.map(tmx, tmy, Map.ACTOR)
			target:die(game.player)
			return
		end

		-- Handle Use menu
		if button == "right" then
			if event == "motion" then
				self.gestures:changeMouseButton(true)
				self.gestures:mouseMove(mx, my)
			elseif event == "button" then
				if not self.gestures:isGesturing() then
					if not xrel and not yrel then
						-- Handle Use menu
						self:mouseRightClick(mx, my, extra)
						return
					end
				else
					self.gestures:changeMouseButton(false)
					self.gestures:useGesture()
					self.gestures:reset()
				end
			end
		end

		-- Default left button action
		if button == "left" and not xrel and not yrel and event == "button" and self.zone and not self.zone.wilderness then if self:mouseLeftClick(mx, my) then return end end

		-- Default middle button action
		if button == "middle" and not xrel and not yrel and event == "button" and self.zone and not self.zone.wilderness then if self:mouseMiddleClick(mx, my) then return end end

		-- Handle the mouse movement/scrolling
		self.player:mouseHandleDefault(self.key, self.key == self.normal_key, button, mx, my, xrel, yrel, event)
	end, nil, "playmap")

	self.uiset:setupMouse(self.mouse)

	if not reset then self.mouse:setCurrent() end
end

--- Left mouse click on the map
function _M:mouseLeftClick(mx, my)
	if not self.level then return end
	local tmx, tmy = self.level.map:getMouseTile(mx, my)
	local p = self.player
	local a = self.level.map(tmx, tmy, Map.ACTOR)
	if not p:canSee(a) then return end
	if not p.auto_shoot_talent then return end
	local t = p:getTalentFromId(p.auto_shoot_talent)
	if not t then return end

	local target_dist = core.fov.distance(p.x, p.y, a.x, a.y)

	if p:enoughEnergy() and p:reactionToward(a) < 0 and not p:isTalentCoolingDown(t) and p:preUseTalent(t, true, true) and target_dist <= p:getTalentRange(t) and p:canProject({type="hit"}, a.x, a.y) then
		p:useTalent(t.id, nil, nil, nil, a)
		return true
	end
end

--- Middle mouse click on the map
function _M:mouseMiddleClick(mx, my)
	if not self.level then return end
	local tmx, tmy = self.level.map:getMouseTile(mx, my)
	local p = self.player
	local a = self.level.map(tmx, tmy, Map.ACTOR)
	if not p:canSee(a) then return end
	if not p.auto_shoot_midclick_talent then return end
	local t = p:getTalentFromId(p.auto_shoot_midclick_talent)
	if not t then return end

	local target_dist = core.fov.distance(p.x, p.y, a.x, a.y)

	if p:enoughEnergy() and p:reactionToward(a) < 0 and not p:isTalentCoolingDown(t) and p:preUseTalent(t, true, true) and target_dist <= p:getTalentRange(t) and p:canProject({type="hit"}, a.x, a.y) then
		p:useTalent(t.id, nil, nil, nil, a)
		return true
	end
end

--- Right mouse click on the map
function _M:mouseRightClick(mx, my, extra)
	if not self.level then return end
	local tmx, tmy = self.level.map:getMouseTile(mx, my)
	self:registerDialog(MapMenu.new(mx, my, tmx, tmy, extra and extra.add_map_action))
end

--- Ask if we really want to close, if so, save the game first
function _M:onQuit()
	self.player:runStop("quitting")
	self.player:restStop("quitting")

	if not self.quit_dialog and not self.player.dead and not self:hasDialogUp() then
		self.quit_dialog = Dialog:yesnoPopup("Save and exit?", "Save and exit?", function(ok)
			if ok then
				-- savefile_pipe is created as a global by the engine
				self:saveGame()
				util.showMainMenu()
			end
			self.quit_dialog = nil
		end)
	end
end

--- Called when we leave the module
function _M:onDealloc()
	local time = os.time() - self.real_starttime
	print("Played ToME for "..time.." seconds")
end

--- When a save is being made, stop running/resting
function _M:onSavefilePush()
	self.player:runStop("saving")
	self.player:restStop("saving")
end

--- When a save has been done, if it's a zone or level, also save the main game
function _M:onSavefilePushed(savename, type, object, class)
	if config.settings.cheat then return end -- Dont annoy debug
	if type == "zone" or type == "level" then self:onTickEnd(function() self:saveGame() end) end
end

--- Saves the highscore of the current char
function _M:registerHighscore()
	local player = self:getPlayer(true)
	local campaign = player.descriptor.world

	local details = {
		world = player.descriptor.world,
		subrace = player.descriptor.subrace,
		subclass = player.descriptor.subclass,
		difficulty = player.descriptor.difficulty,
		level = player.level,
		name = player.name,
		where = self.zone and self.zone.name or "???",
		dlvl = self.level and self.level.level or 1
	}
	if campaign == 'Arena' then
		details.score = self.level.arena.score
	else
		-- fallback score based on xp, this is a placeholder
		details.score = math.floor(10 * (player.level + (player.exp / player:getExpChart(player.level)))) + math.floor(player.money / 100)
	end

	if player.dead then
		details.killedby = player.killedBy and player.killedBy.name or "???"
		HighScores.registerScore(campaign, details)
	else
		HighScores.noteLivingScore(campaign, player.name, details)
	end
end

--- Requests the game to save
function _M:saveGame()
	self:registerHighscore()

	if self.party then for actor, _ in pairs(self.party.members) do engine.interface.PlayerHotkeys:updateQuickHotkeys(actor) end end

	-- savefile_pipe is created as a global by the engine
	local clone = savefile_pipe:push(self.save_name, "game", self)
	world:saveWorld()
	if not self.creating_player then
		local oldplayer = self.player
		self.party:setPlayer(self:getPlayer(true), true)

		_G.game = clone
		pcall(function()
			local party = game.party:cloneFull()
			party.__te4_uuid = game:getPlayer(true).__te4_uuid
			for m, _ in pairs(party.members) do
				m:stripForExport()
			end
			party:stripForExport()
			game.player:saveUUID(party)
		end)
		_G.game = self

		self.party:setPlayer(oldplayer, true)
	end
	self.log("Saving game...")
end

--- Take a screenshot of the game
-- @param for_savefile The screenshot will be used for savefile display
function _M:takeScreenshot(for_savefile)
	if for_savefile then
		self.suppressDialogs = true
		core.display.forceRedraw()

		local x, y = self.w / 4, self.h / 4
		if self.level then
			x, y = self.level.map:getTileToScreen(self.player.x, self.player.y)
			x, y = x - self.w / 4, y - self.h / 4
			x, y = util.bound(x, 0, self.w / 2), util.bound(y, 0, self.h / 2)
		end
		local sc = core.display.getScreenshot(x, y, self.w / 2, self.h / 2)

		self.suppressDialogs = nil
		core.display.forceRedraw()

		return sc
	else
		return core.display.getScreenshot(0, 0, self.w, self.h)
	end
end

function _M:setAllowedBuild(what, notify)
	-- Do not unlock things in easy mode
	--if self.difficulty == self.DIFFICULTY_EASY then return end

	local old = profile.mod.allow_build[what]
	profile:saveModuleProfile("allow_build", {name=what})

	if old then return end

	if notify then
		self.state:checkDonation() -- They gained someting nice, they could be more receptive
		self:registerDialog(require("mod.dialogs.UnlockDialog").new(what))

		if type(unlocks_list[what]) == "string" then self.party.on_death_show_achieved[#self.party.on_death_show_achieved+1] = "Unlocked: "..unlocks_list[what] end
	end

	return true
end

function _M:playSoundNear(who, name)
	if who and self.level.map.seens(who.x, who.y) then
		local pos = {x=0,y=0,z=0}
		if self.player and self.player.x then pos.x, pos.y = who.x - self.player.x, who.y - self.player.y end
		self:playSound(name, pos)
	end
end

--- Create a random lore object and place it
function _M:placeRandomLoreObjectScale(base, nb, level)
	local dist = ({
		[5] = { {1}, {2,3}, {4,5} }, -- 5 => 3
		korpul = { {1,2}, {3,4} }, -- 5 => 3
		maze = { {1,2,3,4},{5,6,7} }, -- 5 => 3
		daikara = { {1}, {2}, {3}, {4,5} },
		[7] = { {1,2}, {3,4}, {5,6}, {7} }, -- 7 => 4
	})[nb][level]
	if not dist then return end
	for _, i in ipairs(dist) do self:placeRandomLoreObject(base..i) end
end

--- Create a random lore object and place it
function _M:placeRandomLoreObject(define, zone)
	if type(define) == "table" then define = rng.table(define) end
	local o = self.zone:makeEntityByName(self.level, "object", define)
	if not o then return end
	if o.checkFilter and not o:checkFilter({}) then return end

	local x, y = rng.range(0, self.level.map.w-1), rng.range(0, self.level.map.h-1)
	local tries = 0
	while (self.level.map:checkEntity(x, y, Map.TERRAIN, "block_move") or self.level.map(x, y, Map.OBJECT) or self.level.map.room_map[x][y].special) and tries < 100 do
		x, y = rng.range(0, self.level.map.w-1), rng.range(0, self.level.map.h-1)
		tries = tries + 1
	end
	if tries < 100 then
		self.zone:addEntity(self.level, o, "object", x, y)
		print("Placed lore", o.name, x, y)
		o:identify(true)
	end
end

unlocks_list = {
	birth_transmo_chest = "Birth option: Transmogrification Chest",
	birth_zigur_sacrifice = "Birth option: Zigur sacrifice",

	campaign_infinite_dungeon = "Campaign: Infinite Dungeon",
	campaign_arena = "Campaign: The Arena",

	undead_ghoul = "Race: Ghoul",
	undead_skeleton = "Race: Skeleton",
	yeek = "Race: Yeek",

	mage = "Class: Archmage",
	mage_tempest = "Class tree: Storm",
	mage_geomancer = "Class tree: Stone",
	mage_pyromancer = "Class tree: Wildfire",
	mage_cryomancer = "Class tree: uttercold",
	mage_necromancer = "Class: Necromancer",

	rogue_marauder = "Class: Marauder",
	rogue_poisons = "Class tree: Poisons",

	divine_anorithil = "Class: Anorithil",
	divine_sun_paladin = "Class: Sun Paladin",

	wilder_wyrmic = "Class: Wyrmic",
	wilder_summoner = "Class: Summoner",

	corrupter_reaver = "Class: Reaver",
	corrupter_corruptor = "Class: Corruptor",

	afflicted_cursed = "Class: Cursed",
	afflicted_doomed = "Class: Doomed",

	chronomancer_temporal_warden = "Class: Temporal Warden",
	chronomancer_paradox_mage = "Class: Paradox Mage",

	psionic_mindslayer = "Class: Mindslayer",
	psionic_solipsist = "Class: Solipsist",

	warrior_brawler = "Class: Brawler",

	adventurer = "Class: Adventurer",
}

--- Returns the current number of birth unlocks and the max
function _M:countBirthUnlocks()
	local nb = 0
	local max = 0

	for name, _ in pairs(self.unlocks_list) do
		max = max + 1
		if profile.mod.allow_build[name] then nb = nb + 1 end
	end
	return nb, max
end
