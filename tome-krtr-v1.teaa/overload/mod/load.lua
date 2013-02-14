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

require "engine.krtrUtils"

-- Configure Map
--dofile("/mod/map_config.lua")

-- Entities that are ASCII are outline
local Entity = require "engine.Entity"
Entity.ascii_outline = {x=2, y=2, r=0, g=0, b=0, a=0.8}

-- This file loads the game module, and loads data
local Savefile = require "engine.Savefile"
local KeyBind = require "engine.KeyBind"
local DamageType = require "engine.DamageType"
local Faction = require "engine.Faction"
local Map = require "engine.Map"
local Level = require "engine.Level"
local Tiles = require "engine.Tiles"
local InventoryUI = require "engine.ui.Inventory"
local ActorStats = require "engine.interface.ActorStats"
local ActorResource = require "engine.interface.ActorResource"
local ActorTalents = require "engine.interface.ActorTalents"
local ActorTemporaryEffects = require "engine.interface.ActorTemporaryEffects"
local ActorAI = require "engine.interface.ActorAI"
local ActorInventory = require "engine.interface.ActorInventory"
local ActorLevel = require "engine.interface.ActorLevel"
local Birther = require "engine.Birther"
local Store = require "mod.class.Store"
local WorldAchievements = require "mod.class.interface.WorldAchievements"
local PartyLore = require "mod.class.interface.PartyLore"
local PartyIngredients = require "mod.class.interface.PartyIngredients"
local PlayerHotkeys = require "engine.interface.PlayerHotkeys"
local Quest = require "engine.Quest"
local UIBase = require "engine.ui.Base"

Savefile:setSaveMD5Type("game")
Savefile:setSaveMD5Type("level")
Savefile:setSaveMD5Type("zone")

-- Init settings
config.settings.tome = config.settings.tome or {}
profile.mod.allow_build = profile.mod.allow_build or {}
--if type(config.settings.tome.autosave) == "nil" then
config.settings.tome.autosave = true
--end
if not config.settings.tome.smooth_move then config.settings.tome.smooth_move = 3 end
if type(config.settings.tome.twitch_move) == "nil" then config.settings.tome.twitch_move = true end
if not config.settings.tome.gfx then
	local w, h = core.display.size()
	if w >= 1000 then config.settings.tome.gfx = {size="64x64", tiles="shockbolt"}
	else config.settings.tome.gfx = {size="48x48", tiles="shockbolt"}
	end
end
if config.settings.tome.gfx.tiles == "mushroom" then config.settings.tome.gfx.tiles="shockbolt" end
if type(config.settings.tome.weather_effects) == "nil" then config.settings.tome.weather_effects = true end
if type(config.settings.tome.smooth_fov) == "nil" then config.settings.tome.smooth_fov = true end
if type(config.settings.tome.daynight) == "nil" then config.settings.tome.daynight = true end
if type(config.settings.tome.hotkey_icons) == "nil" then config.settings.tome.hotkey_icons = true end
if type(config.settings.tome.effects_icons) == "nil" then config.settings.tome.effects_icons = true end
if type(config.settings.tome.autoassign_talents_on_birth) == "nil" then config.settings.tome.autoassign_talents_on_birth = true end
if type(config.settings.tome.chat_log) == "nil" then config.settings.tome.chat_log = true end
if type(config.settings.tome.actor_based_movement_mode) == "nil" then config.settings.tome.actor_based_movement_mode = true end
if type(config.settings.tome.rest_before_explore) == "nil" then config.settings.tome.rest_before_explore = true end
if type(config.settings.tome.lore_popup) == "nil" then config.settings.tome.lore_popup = true end
if type(config.settings.tome.auto_hotkey_object) == "nil" then config.settings.tome.auto_hotkey_object = true end
if not config.settings.tome.fonts then config.settings.tome.fonts = {type="fantasy", size="normal"} end
if not config.settings.tome.ui_theme2 then config.settings.tome.ui_theme2 = "metal" end
if not config.settings.tome.uiset_mode then config.settings.tome.uiset_mode = "Minimalist" end
if not config.settings.tome.log_lines then config.settings.tome.log_lines = 5 end
if not config.settings.tome.log_fade then config.settings.tome.log_fade = 3 end
if not config.settings.tome.scroll_dist then config.settings.tome.scroll_dist = 20 end
if not config.settings.tome.hotkey_icons_rows then config.settings.tome.hotkey_icons_rows = 1 end
if not config.settings.tome.hotkey_icons_size then config.settings.tome.hotkey_icons_size = 48 end
Map.smooth_scroll = config.settings.tome.smooth_move
Map.faction_danger2 = "tactical_danger.png"
Map.faction_danger1 = "tactical_enemy_strong.png"
Map.faction_danger_check = function(self, e, max) return (not max and e.rank > 3) or (max and e.rank >= 3.5) end
Level.remove_old_entity_on_duplicate = true

-- Dialog UI
UIBase.ui = config.settings.tome.ui_theme2
UIBase:setTextShadow(0.6)

-- Dialogs fonts
if config.settings.tome.fonts.type == "fantasy" then
	local size = ({normal=16, small=12, big=18})[config.settings.tome.fonts.size]
	UIBase.font = core.display.newFont(krFont or "/data/font/DroidSans.ttf", size) --@@ 한글 글꼴 추가
	UIBase.font_bold = core.display.newFont(krFont or "/data/font/DroidSans.ttf", size) --@@ 한글 글꼴 추가
	UIBase.font_mono = core.display.newFont(krFont or "/data/font/DroidSansMono.ttf", size) --@@ 한글 글꼴 추가
	UIBase.font_bold:setStyle("bold")
	UIBase.font_h = UIBase.font:lineSkip()
	UIBase.font_bold_h = UIBase.font_bold:lineSkip()
	UIBase.font_mono_w = UIBase.font_mono:size(" ")
	UIBase.font_mono_h = UIBase.font_mono:lineSkip()+2
else
	local size = ({normal=12, small=10, big=14})[config.settings.tome.fonts.size]
	UIBase.font = core.display.newFont(krFont or "/data/font/Vera.ttf", size) --@@ 한글 글꼴 추가
	UIBase.font_mono = core.display.newFont(krFont or "/data/font/VeraMono.ttf", size) --@@ 한글 글꼴 추가
	UIBase.font_bold = core.display.newFont(krFont or "/data/font/VeraBd.ttf", size) --@@ 한글 글꼴 추가
	UIBase.font_h = 	UIBase.font:lineSkip()
	UIBase.font_mono_w = 	UIBase.font_mono:size(" ")
	UIBase.font_mono_h = 	UIBase.font_mono:lineSkip()
	UIBase.font_bold_h = 	UIBase.font_bold:lineSkip()
end

-- Define how quick hotkeys are saved
PlayerHotkeys.quickhotkeys_specifics = {
	function(a)
		local race = ((a.descriptor and a.descriptor.race) and a.descriptor.race or (a.type and a.type:capitalize() or "No Race"))
		local subrace = ((a.descriptor and a.descriptor.subrace) and (" (%s)"):format(a.descriptor.subrace) or (a.type and "" or " (No Subrace)"))
		return ("%s"):format(race .. subrace)
	end,
	function(a)
		local class = ((a.descriptor and a.descriptor.class) and a.descriptor.class or (a.subtype and a.subtype:capitalize() or "No Class"))
		local subclass = ((a.descriptor and a.descriptor.subclass) and (" (%s)"):format(a.descriptor.subclass) or (a.subtype and "" or " (No Subclass)"))
		return ("%s"):format(class .. subclass)
	end,
}


-- Create some noise textures
local n = core.noise.new(3)
_3DNoise = n:makeTexture3D(64, 64, 64)
local n = core.noise.new(2)
_2DNoise = n:makeTexture2D(64, 64)
--local n = core.noise.new(3)
--_2DNoise = n:makeTexture2DStack(64, 64, 64)

-- Achievements
WorldAchievements:loadDefinition("/data/achievements/")

-- Lore
PartyLore:loadDefinition("/data/lore/lore.lua")

-- Useful keybinds
KeyBind:load("move,hotkeys,inventory,actions,interface,tome,debug")

-- Additional entities resolvers
dofile("/mod/resolvers.lua")

-- Body parts
ActorInventory:defineInventory("MAINHAND", "In main hand", true, "대부분의 무기는 편한쪽 손으로 쥡니다.", nil, {equipdoll_back="ui/equipdoll/mainhand_inv.png"})
ActorInventory:defineInventory("OFFHAND", "In off hand", true, "해당하는 기술이 있는 경우, 반대쪽 손으로는 방패를 잡거나 보조 무기를 듭니다.", nil, {equipdoll_back="ui/equipdoll/offhand_inv.png"})
ActorInventory:defineInventory("PSIONIC_FOCUS", "Psionic focus", true, "염동력으로 물체를 잡을 수 있습니다. 여기에는 전투를 위해 무기를 들 수도 있고, 물건이 주는 혜택을 받기 위해 다른 물건을 잡을 수도 있습니다.", nil, {equipdoll_back="ui/equipdoll/psionic_inv.png"})
ActorInventory:defineInventory("FINGER", "On fingers", true, "손가락에는 반지를 끼울 수 있습니다.", nil, {equipdoll_back="ui/equipdoll/ring_inv.png"})
ActorInventory:defineInventory("NECK", "Around neck", true, "목 주변에 장신구를 걸칠 수 있습니다.", nil, {equipdoll_back="ui/equipdoll/amulet_inv.png"})
ActorInventory:defineInventory("LITE", "Light source", true, "광원은 세상의 어두운 장소를 볼 수 있도록 도와줍니다.", nil, {equipdoll_back="ui/equipdoll/light_inv.png"})
ActorInventory:defineInventory("BODY", "Main armor", true, "갑옷은 물리적 공격으로부터 보호해 줍니다. 갑옷이 무거울수록 기술이나 주문을 사용하는데 더 많이 방해됩니다.", nil, {equipdoll_back="ui/equipdoll/body_inv.png"})
ActorInventory:defineInventory("CLOAK", "Cloak", true, "망토는 체온을 유지할수 있게 도와줍니다. 마법이 걸린 것을 찾는다면 엄청난 힘을 제공하는 것도 있습니다.", nil, {equipdoll_back="ui/equipdoll/cloak_inv.png"})
ActorInventory:defineInventory("HEAD", "On head", true, "머리에는 모자나 투구 혹은 왕관을 쓸 수 있습니다.", nil, {equipdoll_back="ui/equipdoll/head_inv.png"})
ActorInventory:defineInventory("BELT", "Around waist", true, "허리에는 허리끈을 걸칩니다.", nil, {equipdoll_back="ui/equipdoll/belt_inv.png"})
ActorInventory:defineInventory("HANDS", "On hands", true, "손에는 여러가지 장갑을 낄 수 있습니다.", nil, {equipdoll_back="ui/equipdoll/hands_inv.png"})
ActorInventory:defineInventory("FEET", "On feet", true, "발에는 신발을 신을 수 있습니다.", nil, {equipdoll_back="ui/equipdoll/boots_inv.png"})
ActorInventory:defineInventory("TOOL", "Tool", true, "여기에는 언제든 바로 쓸 수 있도록 도구를 준비해 둡니다.", nil, {equipdoll_back="ui/equipdoll/tool_inv.png"})
ActorInventory:defineInventory("QUIVER", "Quiver", true, "준비된 탄환입니다.", nil, {equipdoll_back="ui/equipdoll/ammo_inv.png"})
ActorInventory:defineInventory("GEM", "Socketed Gems", true, "보석이 들어갈 구멍입니다.", nil, {equipdoll_back="ui/equipdoll/gem_inv.png"})
ActorInventory:defineInventory("QS_MAINHAND", "Second weapon set: In main hand", false, "두번째 무장: 대부분의 무기는 편한쪽 손으로 쥡니다. 'x'를 누르면 준비된 무장을 바꿀 수 있습니다.", true)
ActorInventory:defineInventory("QS_OFFHAND", "Second weapon set: In off hand", false, "두번째 무장: 반대쪽 손으로는 방패를 잡거나 보조 무기를 듭니다. 'x'를 누르면 준비된 무장을 바꿀 수 있습니다.", true)
ActorInventory:defineInventory("QS_PSIONIC_FOCUS", "Second weapon set: psionic focus", false, "두번째 무장: 염동력으로 물체를 잡을 수 있습니다. 여기에는 전투를 위해 무기를 들 수도 있고, 물건이 주는 혜택을 받기 위해 다른 물건을 잡을 수도 있습니다. 'x'를 누르면 준비된 무장을 바꿀 수 있습니다.", true)
ActorInventory:defineInventory("QS_QUIVER", "Second weapon set: Quiver", false, "두번째 무장: 준비된 탄환입니다.", true)
ActorInventory.equipdolls = {
	default = { w=48, h=48, itemframe="ui/equipdoll/itemframe48.png", itemframe_sel="ui/equipdoll/itemframe-sel48.png", ix=3, iy=3, iw=42, ih=42, doll_x=116, doll_y=168+64, list={
		PSIONIC_FOCUS = {{weight=1, x=48, y=48}},
		MAINHAND = {{weight=2, x=48, y=120}},
		OFFHAND = {{weight=3, x=48, y=192}},
		BODY = {{weight=4, x=48, y=264}},
		QUIVER = {{weight=5, x=48, y=336}},
		FINGER = {{weight=6, x=48, y=408}, {weight=7, x=120, y=408, text="bottom"}},
		LITE = {{weight=8, x=192, y=408}},
		TOOL = {{weight=9, x=264, y=408, text="bottom"}},
		FEET = {{weight=10, x=264, y=336}},
		BELT = {{weight=11, x=264, y=264}},
		HANDS = {{weight=12, x=264, y=192}},
		CLOAK = {{weight=13, x=264, y=120}},
		NECK = {{weight=14, x=192, y=48, text="topright"}},
		HEAD = {{weight=15, x=120, y=48, text="topleft"}},
	}},
	alchemist_golem = { w=48, h=48, itemframe="ui/equipdoll/itemframe48.png", itemframe_sel="ui/equipdoll/itemframe-sel48.png", ix=3, iy=3, iw=42, ih=42, doll_x=116, doll_y=168+64, list={
		MAINHAND = {{weight=1, x=48, y=120}},
		OFFHAND = {{weight=2, x=48, y=192}},
		BODY = {{weight=3, x=48, y=264}},
		GEM = {{weight=4, x=264, y=120}, {weight=5, x=264, y=192}},
	}},
}

-- Ingredients
PartyIngredients:loadDefinition("/data/ingredients.lua")

-- Damage types
DamageType:loadDefinition("/data/damage_types.lua")

-- Talents
ActorTalents:loadDefinition("/data/talents.lua")

-- Timed Effects
ActorTemporaryEffects:loadDefinition("/data/timed_effects.lua")

-- Actor resources
ActorResource:defineResource("Air", "air", nil, "air_regen", "폐활량을 의미합니다. 숨쉴 필요가 없는 자에게는 영향을 끼치지 않습니다.")
ActorResource:defineResource("Stamina", "stamina", ActorTalents.T_STAMINA_POOL, "stamina_regen", "체력은 물리적 피로도를 표현합니다. 물리적 능력을 사용할 때 줄어듭니다.")
ActorResource:defineResource("Mana", "mana", ActorTalents.T_MANA_POOL, "mana_regen", "마나는 마법 에너지의 축적량을 나타냅니다. 사용형 주문을 시전하면 마나가 감소되고, 유지형 주문을 시전하면 마나의 최대치가 감소됩니다.")
ActorResource:defineResource("Equilibrium", "equilibrium", ActorTalents.T_EQUILIBRIUM_POOL, "equilibrium_regen", "평정은 위대한 자연의 조화를 따르는 정도를 나타냅니다. 0에 가까울수록 평온한 상태를 의미합니다. 평온하지 못할수록 자연의 권능을 제대로 쓸 수 없게 됩니다.", 0, false)
ActorResource:defineResource("Vim", "vim", ActorTalents.T_VIM_POOL, "vim_regen", "원기는 타인에게서 빼앗은 생명의 기운과 영혼의 양을 나타냅니다. 타락한 기술이 필요로 합니다.")
ActorResource:defineResource("Positive", "positive", ActorTalents.T_POSITIVE_POOL, "positive_regen", "양기는 보유한 빚의 에너지를 나타냅니다. 시간에 따라 천천히 감소합니다.")
ActorResource:defineResource("Negative", "negative", ActorTalents.T_NEGATIVE_POOL, "negative_regen", "음기는 보유한 어둠의 에너지를 나타냅니다. 시간에 따라 천천히 감소합니다.")
ActorResource:defineResource("Hate", "hate", ActorTalents.T_HATE_POOL, "hate_regen", "증오심은 저주받은 영혼이 광란하는 정도를 나타냅니다.")
ActorResource:defineResource("Paradox", "paradox", ActorTalents.T_PARADOX_POOL, "paradox_regen", "괴리는 당신이 시공 연속체에 입힌 손상 정도를 나타냅니다. 괴리가 심해질수록 주문은 강력해지지만, 동시에 신뢰하기 힘들어지고 더욱 위험해집니다.", 0, false)
ActorResource:defineResource("Psi", "psi", ActorTalents.T_PSI_POOL, "psi_regen", "염력은 정신이 다룰 수 있는 힘의 세기를 나타냅니다.")

-- Actor stats

ActorStats:defineStat("Strength",	"str", 10, 1, 100, "힘은 케릭터의 물리력을 의미합니다. 운반 가능한 무게와, 근력을 사용하는 무기(장검, 철퇴, 도끼 등)의 피해량, 그리고 물리 내성을 상승시킵니다.")
ActorStats:defineStat("Dexterity",	"dex", 10, 1, 100, "민첩은 케릭터가 얼마나 재빠르고 반사신경이 좋은지를 나타냅니다. 공격이 성공할 확률과, 적의 공격을 회피할 확률, 그리고 단검이나 채찍같은 가벼운 무기의 피해량을 상승시킵니다.")
ActorStats:defineStat("Magic",		"mag", 10, 1, 100, "마법은 케릭터가 마력을 얼마나 잘 제어하는지를 나타냅니다. 주문력과 주문 내성, 그리고 다른 마법 물건의 효과를 상승시킵니다.")
ActorStats:defineStat("Willpower",	"wil", 10, 1, 100, "의지는 케릭터의 집중력을 나타냅니다. 마나와 체력, 그리고 염력 수치를 늘려주며, 정신력과 주문, 정신 내성을 상승시킵니다.")
ActorStats:defineStat("Cunning",	"cun", 10, 1, 100, "교활함은 치명적인 공격을 가할 기회와, 정신력, 그리고 정신 내성을 상승시킵니다.")
ActorStats:defineStat("Constitution",	"con", 10, 1, 100, "체격은 케릭터가 얼마나 적의 공격에 잘 버티는지를 나타냅니다. 최대 생명력과 물리 내성을 상승시킵니다.")
-- Luck is hidden and starts at half max value (50) which is considered the standard
ActorStats:defineStat("Luck",		"lck", 50, 1, 100, "행운은 케릭터가 예상치못한 사태에 대처하는 상황에서의 운을 나타냅니다. 치명타 기회와 돌반 사건의 발생 빈도등 여러가지 요소에 영향을 줍니다. ")

-- Actor leveling, player is restricted to 50 but npcs can go higher
ActorLevel:defineMaxLevel(nil)
ActorLevel.exp_chart = function(level)
	local exp = 10
	local mult = 8.5
	local min = 3
	for i = 2, level do
		exp = exp + level * mult
		if level < 30 then
			mult = util.bound(mult - 0.2, min, mult)
		else
			mult = util.bound(mult - 0.1, min, mult)
		end
	end
	return math.ceil(exp)
end
--[[
local tnb, tznb = 0, 0
for i = 2, 50 do
	local nb = math.ceil(ActorLevel.exp_chart(i) / i)
	local znb = math.ceil(nb/25)
	tnb = tnb + nb
	tznb = tznb + znb
	print("level", i, "::", ActorLevel.exp_chart(i), "must kill", nb, "actors of same level; which is about ", znb, "zone levels")
end
print("total", tnb, "::", tznb)
os.exit()
--]]

-- Load tilesets, to speed up image loads
--Tiles:loadTileset("/data/gfx/ts-shockbolt-all.lua")

-- Factions
dofile("/data/factions.lua")

-- Actor autolevel schemes
dofile("/data/autolevel_schemes.lua")

-- Actor AIs
ActorAI:loadDefinition("/engine/ai/")
ActorAI:loadDefinition("/mod/ai/")

-- Birther descriptor
Birther:loadDefinition("/data/birth/descriptors.lua")

-- Stores
Store:loadStores("/data/general/stores/basic.lua")

-- Configure chat dialogs
require("engine.dialogs.Chat").show_portraits = true

-- Inventory tabs
InventoryUI.default_tabslist = function(self)
	local tabslist = {
		{image="metal-ui/inven_tabs/weapons.png", 	kind="weapons",		desc="무기류",		filter=function(o) return not o.__transmo and (o.type == "weapon") end},
		{image="metal-ui/inven_tabs/armors.png", 	kind="armors",		desc="방어구류",		filter=function(o) return not o.__transmo and (o.type == "armor") end},
		{image="metal-ui/inven_tabs/jewelry.png", 	kind="jewelry",		desc="장신구류",		filter=function(o) return not o.__transmo and (o.type == "jewelry") end},
		{image="metal-ui/inven_tabs/gems.png", 		kind="gems",		desc="보석류"		,		filter=function(o) return not o.__transmo and (o.type == "gem" or o.type == "alchemist-gem") end},
		{image="metal-ui/inven_tabs/inscriptions.png", 	kind="inscriptions",	desc="각인",		filter=function(o) return not o.__transmo and (o.type == "scroll") end},
		{image="metal-ui/inven_tabs/misc.png", 		kind="misc",		desc="기타",			filter="others"},
		{image="metal-ui/inven_tabs/quests.png", 	kind="quests",		desc="퀘스트나 게임 진행에 관련된 물품",	filter=function(o) return not o.__transmo and (o.plot or o.quest) end},
	}
	if self.actor:attr("has_transmo") then tabslist[#tabslist+1] = {image="metal-ui/inven_tabs/chest.png", kind="transmo", desc="변환 상자", filter=function(o) return o.__transmo end} end
	tabslist[#tabslist+1] = {image="metal-ui/inven_tabs/all.png", kind="all", desc="전부", filter="all"}
	return tabslist
end

class:triggerHook{"ToME:load"}

------------------------------------------------------------------------
-- Count the number of talents per types
------------------------------------------------------------------------
--[[
local type_tot = {}
for i, t in pairs(ActorTalents.talents_def) do
	type_tot[t.type[1] ] = (type_tot[t.type[1] ] or 0) + t.points
	local b = t.type[1]:gsub("/.*", "")
	type_tot[b] = (type_tot[b] or 0) + t.points
end
local stype_tot = {}
for tt, nb in pairs(type_tot) do
	stype_tot[#stype_tot+1] = {tt,nb}
end
table.sort(stype_tot, function(a, b) return a[1] < b[1] end)
for i, t in ipairs(stype_tot) do
	print("[SCHOOL TOTAL]", t[2], t[1])
end
]]
------------------------------------------------------------------------
return {require "mod.class.Game", require "mod.class.World"}
