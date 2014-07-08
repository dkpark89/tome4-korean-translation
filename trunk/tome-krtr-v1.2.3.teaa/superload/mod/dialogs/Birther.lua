-- krTr AddOn

local _M = loadPrevious(...)

-- 바뀐 코드들과 원래 소스에서 그 위치(주석)
local base_init = _M.init -- #45~182
local base_checkNew = _M.checkNew -- #184~193
local base_tutorial = _M.tutorial -- #340~369
local base_on_focus = _M.on_focus -- #452~466
local base_raceUse = _M.raceUse -- #515~533
local base_classUse = _M.classUse -- #535~551
local base_generateCampaigns = _M.generateCampaigns -- #645~664
local base_generateDifficulties = _M.generateDifficulties -- #666~696
local base_generatePermadeaths = _M.generatePermadeaths -- #698~728
local base_generateRaces = _M.generateRaces -- #730~782
local base_generateClasses = _M.generateClasses -- #784~845
local base_loadPremadeUI = _M.loadPremadeUI -- #934~978
local base_selectExplorationNoDonations = _M.selectExplorationNoDonations -- #1126~1142
local base_selectTileNoDonations = _M.selectTileNoDonations -- #1144~1158
local base_selectTile = _M.selectTile -- #1160~1417
local base_customizeOptions = _M.customizeOptions -- #1423~1446

-- 기존 require들 포함 필요
require "engine.krtrUtils"
require "engine.class"
local Dialog = require "engine.ui.Dialog"
local Birther = require "engine.Birther"
local List = require "engine.ui.List"
local TreeList = require "engine.ui.TreeList"
local Button = require "engine.ui.Button"
local Dropdown = require "engine.ui.Dropdown"
local Textbox = require "engine.ui.Textbox"
local Checkbox = require "engine.ui.Checkbox"
local Textzone = require "engine.ui.Textzone"
local ImageList = require "engine.ui.ImageList"
local TextzoneList = require "engine.ui.TextzoneList"
local Separator = require "engine.ui.Separator"
local NameGenerator = require "engine.NameGenerator"
local NameGenerator2 = require "engine.NameGenerator2"
local Savefile = require "engine.Savefile"
local Module = require "engine.Module"
local Tiles = require "engine.Tiles"
local Particles = require "engine.Particles"
local CharacterVaultSave = require "engine.CharacterVaultSave"
local Object = require "mod.class.Object"

module(..., package.seeall, class.inherit(Birther))


function _M:init(title, actor, order, at_end, quickbirth, w, h)
	self.quickbirth = quickbirth
	self.actor = actor:cloneFull()
	self.actor_base = actor
	self.order = order
	self.at_end = at_end
	self.selected_cosmetic_unlocks = {}
	self.tiles = Tiles.new(64, 64, nil, nil, true, nil)

	Dialog.init(self, title and title or "캐릭터 생성", w or 600, h or 400)

	self.obj_list = Object:loadList("/data/general/objects/objects.lua")
	self.obj_list_by_name = {}
	for i, e in ipairs(self.obj_list) do if e.name and (e.rarity or e.define_as) then self.obj_list_by_name[e.name] = e end end

	self.descriptors = {}
	self.descriptors_by_type = {}

	self.c_ok = Button.new{text="     시작!     ", fct=function() self:atEnd("created") end}
	self.c_random = Button.new{text="랜덤!", fct=function() self:randomBirth() end}
	self.c_premade = Button.new{text="기존 캐릭터", fct=function() self:loadPremadeUI() end}
	self.c_tile = Button.new{text="커스텀 타일 선택", fct=function() self:selectTile() end}
	self.c_cancel = Button.new{text="취소", fct=function() self:atEnd("quit") end}
	self.c_tut = Button.new{text="초보자용 연습게임", fct=function() self:tutorial() end}
	self.c_options = Button.new{text="생김새 설정", fct=function() self:customizeOptions() end}
	self.c_options.hide = true

	self.c_name = Textbox.new{title="이름 : ", text=(not config.settings.cheat and game.player_name == "player") and "" or game.player_name, chars=30, max_len=50, fct=function()
		if config.settings.cheat then self:makeDefault() end
	end, on_change=function() self:setDescriptor() end, on_mouse = function(button) if button == "right" then self:randomName() end end}

	self.c_female = Checkbox.new{title="여성", default=true,
		fct=function() end,
		on_change=function(s) self.c_male.checked = not s self:setDescriptor("sex", s and "Female" or "Male") end
	}
	self.c_male = Checkbox.new{title="남성", default=false,
		fct=function() end,
		on_change=function(s) self.c_female.checked = not s self:setDescriptor("sex", s and "Male" or "Female") end
	}

	self:generateCampaigns()
	self.c_campaign_text = Textzone.new{auto_width=true, auto_height=true, text="캠페인 : "}
	self.c_campaign = Dropdown.new{width=400, fct=function(item) self:campaignUse(item) end, on_select=function(item) self:updateDesc(item) end, list=self.all_campaigns, nb_items=#self.all_campaigns}

	self:generateDifficulties()
	self.c_difficulty_text = Textzone.new{auto_width=true, auto_height=true, text="난이도 : "}
	self.c_difficulty = Dropdown.new{width=100, fct=function(item) self:difficultyUse(item) end, on_select=function(item) self:updateDesc(item) end, list=self.all_difficulties, nb_items=#self.all_difficulties}

	self:generatePermadeaths()
	self.c_permadeath_text = Textzone.new{auto_width=true, auto_height=true, text="죽음 방식 : "}
	self.c_permadeath = Dropdown.new{width=150, fct=function(item) self:permadeathUse(item) end, on_select=function(item) self:updateDesc(item) end, list=self.all_permadeaths, nb_items=#self.all_permadeaths}

	self.c_desc = TextzoneList.new{width=math.floor(self.iw / 3 - 10), height=self.ih - self.c_female.h - self.c_ok.h - self.c_difficulty.h - self.c_campaign.h - 10, scrollbar=true, no_color_bleed=true}

	self:setDescriptor("base", "base")
	self:setDescriptor("world", self.default_campaign)
	self:setDescriptor("difficulty", self.default_difficulty)
	self:setDescriptor("permadeath", self.default_permadeath)
	self:setDescriptor("sex", "Female")

	self:generateRaces()
	self.c_race = TreeList.new{width=math.floor(self.iw / 3 - 10), height=self.ih - self.c_female.h - self.c_ok.h - self.c_difficulty.h - self.c_campaign.h - 10, scrollbar=true, columns={
		{width=100, display_prop="name"},
	}, tree=self.all_races,
		fct=function(item, sel, v) self:raceUse(item, sel, v) end,
		select=function(item, sel) self:updateDesc(item) end,
		on_expand=function(item) end,
		on_drawitem=function(item) end,
	}

	self:generateClasses()
	self.c_class = TreeList.new{width=math.floor(self.iw / 3 - 10), height=self.ih - self.c_female.h - self.c_ok.h - self.c_difficulty.h - self.c_campaign.h - 10, scrollbar=true, columns={
		{width=100, display_prop="name"},
	}, tree=self.all_classes,
		fct=function(item, sel, v) self:classUse(item, sel, v) end,
		select=function(item, sel) self:updateDesc(item) end,
		on_expand=function(item) end,
		on_drawitem=function(item) end,
	}

	self.cur_order = 1
	self.sel = 1

	self:loadUI{
		-- First line
		{left=0, top=0, ui=self.c_name},
		{left=self.c_name, top=0, ui=self.c_female},
		{left=self.c_female, top=0, ui=self.c_male},

		-- Second line
		{left=0, top=self.c_name, ui=self.c_campaign_text},
		{left=self.c_campaign_text, top=self.c_name, ui=self.c_campaign},

		-- Third line
		{left=0, top=self.c_campaign, ui=self.c_difficulty_text},
		{left=self.c_difficulty_text, top=self.c_campaign, ui=self.c_difficulty},
		{left=self.c_difficulty, top=self.c_campaign, ui=self.c_permadeath_text},
		{left=self.c_permadeath_text, top=self.c_campaign, ui=self.c_permadeath},
		{right=0, top=self.c_name, ui=self.c_tut},

		-- Lists
		{left=0, top=self.c_permadeath, ui=self.c_race},
		{left=self.c_race, top=self.c_permadeath, ui=self.c_class},
		{right=0, top=self.c_permadeath, ui=self.c_desc},

		-- Buttons
		{left=0, bottom=0, ui=self.c_ok, hidden=true},
		{left=self.c_ok, bottom=0, ui=self.c_random},
		{left=self.c_random, bottom=0, ui=self.c_premade},
		{left=self.c_premade, bottom=0, ui=self.c_tile},
		{left=self.c_tile, bottom=0, ui=self.c_options},
		{right=0, bottom=0, ui=self.c_cancel},
	}
	self:setupUI()

	if self.descriptors_by_type.difficulty == "Tutorial" then
		self:permadeathUse(self.all_permadeaths[1], 1)
		self:raceUse(self.all_races[1], 1)
		self:raceUse(self.all_races[1].nodes[1], 2)
		self:classUse(self.all_classes[1], 1)
		self:classUse(self.all_classes[1].nodes[1], 2)
	end
	for i, item in ipairs(self.c_campaign.c_list.list) do if self.default_campaign == item.id then self.c_campaign.c_list.sel = i break end end
	for i, item in ipairs(self.c_difficulty.c_list.list) do if self.default_difficulty == item.id then self.c_difficulty.c_list.sel = i break end end
	for i, item in ipairs(self.c_permadeath.c_list.list) do if self.default_permadeath == item.id then self.c_permadeath.c_list.sel = i break end end
	if config.settings.tome.default_birth and config.settings.tome.default_birth.sex then
		self.c_female.checked = config.settings.tome.default_birth.sex == "Female"
		self.c_male.checked = config.settings.tome.default_birth.sex ~= "Female"
		self:setDescriptor("sex", self.c_female.checked and "Female" or "Male")
	end
	self:setFocus(self.c_campaign)
	self:setFocus(self.c_name)

	if not profile.mod.allow_build.tutorial_done then
		self:setFocus(self.c_tut)
		self.c_tut.glow = 0.70
	end
end

function _M:checkNew(fct)
	local savename = self.c_name.text:gsub("[^a-zA-Z0-9_-.]", "_")
	if fs.exists(("/save/%s/game.teag"):format(savename)) then
		Dialog:yesnoPopup("캐릭터를 덮어쓰시겠습니까?", "이미 동일한 이름의 캐릭터가 있습니다. 덮어쓰시겠습니까?", function(ret)
			if not ret then fct() end
		end, "아니오", "예")
	else
		fct()
	end
end

function _M:tutorial()
	local run = function(t)
		self:setDescriptor("sex", "Female")
		self:setDescriptor("world", "Maj'Eyal")
		self:setDescriptor("difficulty", "Tutorial")
		self:setDescriptor("permadeath", "Adventure")
		self:setDescriptor("race", "Tutorial Human")
		self:setDescriptor("subrace", "Tutorial "..t)
		self:setDescriptor("class", "Tutorial Adventurer")
		self:setDescriptor("subclass", "Tutorial Adventurer")
		self:randomName()
		self:atEnd("created")
	end

	local d = Dialog.new("초보자 입문용 연습게임", 280, 100)
	local basic = Button.new{text="기본적인 게임진행 (기초)", fct=function() run("Basic") d.key:triggerVirtual("EXIT") end}
--	local stats = Button.new{text="능력치와 상태효과 (고급)", fct=function() run("Stats") d.key:triggerVirtual("EXIT") end}
	local cancel = Button.new{text="취소", fct=function() d.key:triggerVirtual("EXIT") end}
	local sep = Separator.new{dir="vertical", size=230}

	d:loadUI{
		{hcenter=0, top=0, ui=basic},
--		{hcenter=0, top=basic.h, ui=stats},
		{hcenter=0, bottom=cancel.h, ui=sep},
		{hcenter=0, bottom=0, ui=cancel},
	}
	d:setupUI(false, true)
	d.key:addBind("EXIT", function() game:unregisterDialog(d) end)
	game:registerDialog(d)
end

function _M:on_focus(id, ui)
	if self.focus_ui and self.focus_ui.ui == self.c_name then self.c_desc:switchItem(self.c_name, "이것은 당신의 캐릭터 이름입니다.\n마우스 우클릭을 하면 주어진 종족과 성별에 맞는 랜덤한 이름이 만들어 집니다.")
	elseif self.focus_ui and self.focus_ui.ui == self.c_female then self.c_desc:switchItem(self.c_female, self.birth_descriptor_def.sex.Female.desc)
	elseif self.focus_ui and self.focus_ui.ui == self.c_male then self.c_desc:switchItem(self.c_male, self.birth_descriptor_def.sex.Male.desc)
	elseif self.focus_ui and self.focus_ui.ui == self.c_campaign then
		local item = self.c_campaign.c_list.list[self.c_campaign.c_list.sel]
		self.c_desc:switchItem(item, item.desc)
	elseif self.focus_ui and self.focus_ui.ui == self.c_difficulty then
		local item = self.c_difficulty.c_list.list[self.c_difficulty.c_list.sel]
		self.c_desc:switchItem(item, item.desc)
	elseif self.focus_ui and self.focus_ui.ui == self.c_permadeath then
		local item = self.c_permadeath.c_list.list[self.c_permadeath.c_list.sel]
		self.c_desc:switchItem(item, item.desc)
	end
end

function _M:raceUse(item, sel, v)
	if not item then return end
	if item.nodes then
		for i, item in ipairs(self.c_race.tree) do if item.shown then self.c_race:treeExpand(false, item) end end
		self.c_race:treeExpand(nil, item)
	elseif not item.locked and item.basename then
		if self.sel_race then
			self.sel_race.name = self.sel_race.kr_basename or self.sel_race.basename
			self.c_race:drawItem(self.sel_race)
		end
		self:setDescriptor("race", item.pid)
		self:setDescriptor("subrace", item.id)
		self.sel_race = item
		self.sel_race.name = tstring{{"font","bold"}, {"color","LIGHT_GREEN"}, (self.sel_race.kr_basename or self.sel_race.basename):toString(), {"font","normal"}}
		self.c_race:drawItem(item)

		self:generateClasses()
	end
end

function _M:classUse(item, sel, v)
	if not item then return end
	if item.nodes then
		for i, item in ipairs(self.c_class.tree) do if item.shown then self.c_class:treeExpand(false, item) end end
		self.c_class:treeExpand(nil, item)
	elseif not item.locked and item.basename then
		if self.sel_class then
			self.sel_class.name = self.sel_class.kr_basename or self.sel_class.basename
			self.c_class:drawItem(self.sel_class)
		end
		self:setDescriptor("class", item.pid)
		self:setDescriptor("subclass", item.id)
		self.sel_class = item
		self.sel_class.name = tstring{{"font","bold"}, {"color","LIGHT_GREEN"}, (self.sel_class.kr_basename or self.sel_class.basename):toString(), {"font","normal"}}
		self.c_class:drawItem(item)
	end
end

function _M:generateCampaigns()
	local locktext = "\n\n#GOLD#이 캐릭터 생성 항목은 잠겨있습니다. 게임 내에서 어떤 행동이나 퀘스트를 수행함으로써, 잠겨진 게임 모드나 종족, 직업들을 해제할 수 있습니다."
	local list = {}

	for i, d in ipairs(self.birth_descriptor_def.world) do
		if self:isDescriptorAllowed(d, {difficulty=true, permadeath=true, race=true, subrace=true, class=true, subclass=true}) then
			local locked = self:getLock(d)
			if locked == true then
				list[#list+1] = { name = tstring{{"font", "italic"}, {"color", "GREY"}, "-- 잠겨있음 --", {"font", "normal"}}:toString(), id=d.name, locked=true, desc=d.locked_desc..locktext }
			elseif locked == false then
				local desc = d.desc
				if type(desc) == "table" then desc = table.concat(d.desc, "\n") end
				list[#list+1] = { name = tstring{d.kr_display_name or d.display_name}:toString(), id=d.name, desc=desc } --@ 한글 이름 저장
			end
		end
	end

	self.all_campaigns = list
	self.default_campaign = list[1].id
end

function _M:generateDifficulties()
	local locktext = "\n\n#GOLD#이 캐릭터 생성 항목은 잠겨있습니다. 게임 내에서 어떤 행동이나 퀘스트를 수행함으로써, 잠겨진 게임 모드나 종족, 직업들을 해제할 수 있습니다."
	local list = {}

	local oldsel = nil
	if self.c_difficulty then
		oldsel = self.c_difficulty.c_list.list[self.c_difficulty.c_list.sel].id
	end

	for i, d in ipairs(self.birth_descriptor_def.difficulty) do
		if self:isDescriptorAllowed(d, {permadeath=true, race=true, subrace=true, class=true, subclass=true}) then
			local locked = self:getLock(d)
			if locked == true then
				list[#list+1] = { name = tstring{{"font", "italic"}, {"color", "GREY"}, "-- 잠겨있음 --", {"font", "normal"}}:toString(), id=d.name, locked=true, desc=d.locked_desc..locktext }
			elseif locked == false then
				local desc = d.desc
				if type(desc) == "table" then desc = table.concat(d.desc, "\n") end
				list[#list+1] = { name = tstring{d.kr_display_name or d.display_name}:toString(), id=d.name, desc=desc } --@ 한글 이름 저장
				if oldsel == d.name then oldsel = #list end
				if util.getval(d.selection_default) then self.default_difficulty = d.name end
			end
		end
	end

	self.all_difficulties = list
	if self.c_difficulty then
		self.c_difficulty.c_list.list = self.all_difficulties
		self.c_difficulty.c_list:generate()
		if type(oldsel) == "number" then self.c_difficulty.c_list.sel = oldsel end
	end
end

function _M:generatePermadeaths()
	local locktext = "\n\n#GOLD#이 캐릭터 생성 항목은 잠겨있습니다. 게임 내에서 어떤 행동이나 퀘스트를 수행함으로써, 잠겨진 게임 모드나 종족, 직업들을 해제할 수 있습니다."
	local list = {}

	local oldsel = nil
	if self.c_permadeath then
		oldsel = self.c_permadeath.c_list.list[self.c_permadeath.c_list.sel].id
	end

	for i, d in ipairs(self.birth_descriptor_def.permadeath) do
		if self:isDescriptorAllowed(d, {race=true, subrace=true, class=true, subclass=true}) then
			local locked = self:getLock(d)
			if locked == true then
				list[#list+1] = { name = tstring{{"font", "italic"}, {"color", "GREY"}, "-- 잠겨있음 --", {"font", "normal"}}:toString(), id=d.name, locked=true, desc=d.locked_desc..locktext, locked_select=d.locked_select }
			elseif locked == false then
				local desc = d.desc
				if type(desc) == "table" then desc = table.concat(d.desc, "\n") end
				list[#list+1] = { name = tstring{d.kr_display_name or d.display_name}:toString(), id=d.name, desc=desc } --@ 한글 이름 저장
				if oldsel == d.name then oldsel = #list end
				if util.getval(d.selection_default) then self.default_permadeath = d.name end
			end
		end
	end

	self.all_permadeaths = list
	if self.c_permadeath then
		self.c_permadeath.c_list.list = self.all_permadeaths
		self.c_permadeath.c_list:generate()
		if type(oldsel) == "number" then self.c_permadeath.c_list.sel = oldsel end
	end
end

function _M:generateRaces()
	local locktext = "\n\n#GOLD#이 캐릭터 생성 항목은 잠겨있습니다. 게임 내에서 어떤 행동이나 퀘스트를 수행함으로써, 잠겨진 게임 모드나 종족, 직업들을 해제할 수 있습니다."

	local oldtree = {}
	for i, t in ipairs(self.all_races or {}) do oldtree[t.id] = t.shown end

	local tree = {}
	local newsel = nil
	for i, d in ipairs(self.birth_descriptor_def.race) do
		if self:isDescriptorAllowed(d, {class=true, subclass=true}) then
			local nodes = {}

			for si, sd in ipairs(self.birth_descriptor_def.subrace) do
				if d.descriptor_choices.subrace[sd.name] == "allow" then
					local locked = self:getLock(sd)
					if locked == true then
						nodes[#nodes+1] = { name = tstring{{"font", "italic"}, {"color", "GREY"}, "-- 잠겨있음 --", {"font", "normal"}}, id=sd.name, pid=d.name, locked=true, desc=sd.locked_desc..locktext }
					elseif locked == false then
						local desc = sd.desc
						if type(desc) == "table" then desc = table.concat(sd.desc, "\n") end
						nodes[#nodes+1] = { name = sd.kr_display_name or sd.display_name, kr_basename = sd.kr_display_name or sd.display_name, basename=sd.display_name, id=sd.name, pid=d.name, desc=desc } --@ 한글 이름 저장
						if self.sel_race and self.sel_race.id == sd.name then newsel = nodes[#nodes] end
					end
				end
			end

			local locked = self:getLock(d)
			if locked == true then
				tree[#tree+1] = { name = tstring{{"font", "italic"}, {"color", "GREY"}, "-- 잠겨있음 --", {"font", "normal"}}, id=d.name, shown = oldtree[d.name], nodes = nodes, locked=true, desc=d.locked_desc..locktext }
			elseif locked == false then
				local desc = d.desc
				if type(desc) == "table" then desc = table.concat(d.desc, "\n") end
				tree[#tree+1] = { name = tstring{{"font", "italic"}, {"color", "LIGHT_SLATE"}, d.kr_display_name or d.display_name, {"font", "normal"}}, id=d.name, shown = oldtree[d.name], nodes = nodes, desc=desc } --@ 한글 이름 저장
			end
		end
	end

	self.all_races = tree
	if self.c_race then
		self.c_race.tree = self.all_races
		self.c_race:generate()
		if newsel then self:raceUse(newsel)
		else
			self.sel_race = nil
			self:setDescriptor("race", nil)
			self:setDescriptor("subrace", nil)
		end
		if self.descriptors_by_type.difficulty == "Tutorial" then
			self:raceUse(tree[1], 1)
			self:raceUse(tree[1].nodes[1], 2)
		end
	end
end

function _M:generateClasses()
	local locktext = "\n\n#GOLD#이 캐릭터 생성 항목은 잠겨있습니다. 게임 내에서 어떤 행동이나 퀘스트를 수행함으로써, 잠겨진 게임 모드나 종족, 직업들을 해제할 수 있습니다."

	local oldtree = {}
	for i, t in ipairs(self.all_classes or {}) do oldtree[t.id] = t.shown end

	local tree = {}
	local newsel = nil
	for i, d in ipairs(self.birth_descriptor_def.class) do
		if self:isDescriptorAllowed(d, {subclass=true}) then
			local nodes = {}
			for si, sd in ipairs(self.birth_descriptor_def.subclass) do
				if (d.descriptor_choices.subclass[sd.name] == "allow" or d.descriptor_choices.subclass[sd.name] == "allow-nochange" or d.descriptor_choices.subclass[sd.name] == "nolore") and self:isDescriptorAllowed(sd, {subclass=true, class=true}) then
					local locked = self:getLock(sd)
					if locked == true then
						nodes[#nodes+1] = { name = tstring{{"font", "italic"}, {"color", "GREY"}, "-- 잠겨있음 --", {"font", "normal"}}, id=sd.name, pid=d.name, locked=true, desc=sd.locked_desc..locktext }
					elseif locked == false then
						local old = self.descriptors_by_type.subclass
						self.descriptors_by_type.subclass = nil
						local how = self:isDescriptorAllowed(sd, {class=true})
						self.descriptors_by_type.subclass = old
						local desc = sd.desc
						if type(desc) == "table" then desc = table.concat(sd.desc, "\n") end
						if how == "nolore" and self.descriptors_by_type.subrace then
							desc = "#CRIMSON#이 직업은 선택한 종족과 썩 어울려 보이지 않습니다. 게임이 불가능한 것은 아니지만, 특정 퀘스트를 수행하지 못할 수도 있습니다/...#WHITE#\n" .. desc
						end
						nodes[#nodes+1] = { name = sd.kr_display_name or sd.display_name, kr_basename= sd.kr_display_name or sd.display_name, basename=sd.display_name, id=sd.name, pid=d.name, desc=desc, def=sd }
						if self.sel_class and self.sel_class.id == sd.name then newsel = nodes[#nodes] end
					end
				end
			end

			local locked = self:getLock(d)
			if locked == true then
				tree[#tree+1] = { name = tstring{{"font", "italic"}, {"color", "GREY"}, "-- 잠겨있음 --", {"font", "normal"}}, id=d.name, shown=oldtree[d.name], nodes = nodes, locked=true, desc=d.locked_desc..locktext }
			elseif locked == false then
				local desc = d.desc
				if type(desc) == "table" then desc = table.concat(d.desc, "\n") end
				tree[#tree+1] = { name = tstring{{"font", "italic"}, {"color", "LIGHT_SLATE"}, d.kr_display_name or d.display_name, {"font", "normal"}}, id=d.name, shown=oldtree[d.name], nodes = nodes, desc=desc } --@ 한글 이름 저장
			end
		end
	end

	self.all_classes = tree
	if self.c_class then
		self.c_class.tree = self.all_classes
		self.c_class:generate()
		if newsel then self:classUse(newsel)
		else
			self.sel_class = nil
			self:setDescriptor("class", nil)
			self:setDescriptor("subclass", nil)
		end
		if self.descriptors_by_type.difficulty == "Tutorial" then
			self:classUse(tree[1], 1)
			self:classUse(tree[1].nodes[1], 2)
		elseif tree[1].id == "None" then
			self:classUse(tree[1], 1)
			self:classUse(tree[1].nodes[1], 2)
		end
	end
end

function _M:loadPremadeUI()
	local lss = Module:listVaultSavesForCurrent()
	local d = Dialog.new("캐릭터 저장소", 600, 550)

	local sel = nil
	local desc = TextzoneList.new{width=220, height=400}
	local list list = List.new{width=350, list=lss, height=400,
		fct=function(item)
			local oldsel, oldscroll = list.sel, list.scroll
			if sel == item then self:loadPremade(sel) game:unregisterDialog(d) end
			if sel then sel.color = nil end
			item.color = colors.simple(colors.LIGHT_GREEN)
			sel = item
			list:generate()
			list.sel, list.scroll = oldsel, oldscroll
		end,
		select=function(item) desc:switchItem(item, item.description) end
	}
	local sep = Separator.new{dir="horizontal", size=400}

	local load = Button.new{text="불러오기", fct=function() if sel then self:loadPremade(sel) game:unregisterDialog(d) end end}
	local del = Button.new{text="삭제", fct=function() if sel then
		self:yesnoPopup(sel.name, "만들었던 캐릭터를 삭제하시겠습니까? : "..sel.name, function(ret) if ret then
			local vault = CharacterVaultSave.new(sel.short_name)
			vault:delete()
			vault:close()
			lss = Module:listVaultSavesForCurrent()
			list.list = lss
			list:generate()
			sel = nil
		end end, "예", "아니오")
	end end}

	d:loadUI{
		{left=0, top=0, ui=list},
		{left=list.w, top=0, ui=sep},
		{right=0, top=0, ui=desc},

		{left=0, bottom=0, ui=load},
		{right=0, bottom=0, ui=del},
	}
	d:setupUI(true, true)
	d.key:addBind("EXIT", function() game:unregisterDialog(d) end)
	game:registerDialog(d)
end

function _M:selectExplorationNoDonations()
	Dialog:yesnoLongPopup("탐사 모드",
	[[탐사 모드에서는 부활에 제한이 없는 캐릭터를 제공합니다.
이 게임에서는, 죽음을 포함한 여러 실수들을 반복하면서 얻는 경험으로 플레이어의 실력이 향상됩니다.
하지만 수차례의 요청을 받은 뒤, 이런 반복된 플레이가 강제되는 것을 모두가 즐거워하는 것은 아니라는 것을 깨달았습니다. 그래서 이 게임을 위해 기부해주신 분(donator)들이 마음껏 모든 것을 경험해보실 수 있도록 탐사 모드를 제공하게 되었습니다.
무한한 생명을 지녔다고 해도 어려움이 경감되는 것은 아니지만, 그래도 처음부터 다시 시작해야만 하는 상황에서 벗어나 도전을 계속해볼 수 있지요.

만약 이 기능을 사용하고 싶으시고 이 게임이 마음에 드신다면, 기부를 부탁드립니다.
이 게임은 무료이고 취미삼아 만든 것이지만, 이 게임이 제 가족의 생계에 약간이나마 도움이 된다면 간혹 현실이 가혹해지더라도 불평 없이 기쁜 마음으로 제작을 계속할 수 있을 것입니다.
기부자 계정으로 온라인 접속중이라면, 탐사 모드를 선택하실 수 있습니다. 기부를 하셨다면 게임을 재시작하셔야 기부자 권한이 적용됩니다.

기부해주신 분들은 커스텀 캐릭터 타일도 사용하실 수 있습니다.]], 400, function(ret)
		if not ret then
			game:registerDialog(require("mod.dialogs.Donation").new("exploration-mode"))
		end
	end, "나중에요...", "기부할께요!")
end

function _M:selectTileNoDonations()
	Dialog:yesnoLongPopup("커스텀 캐릭터 타일",
	[[커스텀 캐릭터 타일은 ToME을 위해 기부해주신 분들께 감사를 드리기 위해 추가되었습니다.
게임상에서 흔히 본 것들에서부터 특별한 인간형 타일에서까지, 총 180 가지에 이르는 재미난 캐릭터 타일을 제공합니다. (계속 추가됩니다!)

만약 이 기능을 사용하고 싶으시고 이 게임이 마음에 드신다면, 기부를 부탁드립니다.
이 게임은 무료이고 취미삼아 만든 것이지만, 이 게임이 제 가족의 생계에 약간이나마 도움이 된다면 간혹 현실이 가혹해지더라도 불평 없이 기쁜 마음으로 제작을 계속할 수 있을 것입니다.
기부자 계정으로 온라인 접속중이라면, 커스텀 캐릭터 타일을 선택하실 수 있습니다. 기부를 하셨다면 게임을 재시작하셔야 기부자 권한이 적용됩니다.

기부해주신 분들은 탐사 모드도 사용하실 수 있습니다.]], 400, function(ret)
		if not ret then
			game:registerDialog(require("mod.dialogs.Donation").new("custom-tiles"))
		end
	end, "나중에요...", "기부할께요!")
end

function _M:selectTile()
	local d = Dialog.new("타일을 선택하세요", 600, 550)

	local list = {
		"npc/alchemist_golem.png",
		"npc/armored_skeleton_warrior.png",
		"npc/barrow_wight.png",
		"npc/construct_golem_alchemist_golem.png",
		"npc/degenerated_skeleton_warrior.png",
		"npc/elder_vampire.png",
		"npc/emperor_wight.png",
		"npc/forest_wight.png",
		"npc/golem.png",
		"npc/grave_wight.png",
		"npc/horror_corrupted_dremling.png",
		"npc/horror_corrupted_drem_master.png",
		"npc/horror_eldritch_headless_horror.png",
		"npc/horror_eldritch_luminous_horror.png",
		"npc/horror_eldritch_worm_that_walks.png",
		"npc/horror_temporal_cronolith_clone.png",
		"npc/humanoid_dwarf_dwarven_earthwarden.png",
		"npc/humanoid_dwarf_dwarven_guard.png",
		"npc/humanoid_dwarf_dwarven_paddlestriker.png",
		"npc/humanoid_dwarf_dwarven_summoner.png",
		"npc/humanoid_dwarf_lumberjack.png",
		"npc/humanoid_dwarf_norgan.png",
		"npc/humanoid_dwarf_ziguranth_warrior.png",
		"npc/humanoid_elenulach_thief.png",
		"npc/humanoid_elf_anorithil.png",
		"npc/humanoid_elf_elven_archer.png",
		"npc/humanoid_elf_elven_sun_mage.png",
		"npc/humanoid_elf_fillarel_aldaren.png",
		"npc/humanoid_elf_limmir_the_jeweler.png",
		"npc/humanoid_elf_star_crusader.png",
		"npc/humanoid_halfling_derth_guard.png",
		"npc/humanoid_halfling_halfling_citizen.png",
		"npc/humanoid_halfling_halfling_gardener.png",
		"npc/humanoid_halfling_halfling_guard.png",
		"npc/humanoid_halfling_halfling_slinger.png",
		"npc/humanoid_halfling_master_slinger.png",
		"npc/humanoid_halfling_protector_myssil.png",
		"npc/humanoid_halfling_sm_halfling.png",
		"npc/humanoid_human_alchemist.png",
		"npc/humanoid_human_aluin_the_fallen.png",
		"npc/humanoid_human_apprentice_mage.png",
		"npc/humanoid_human_arcane_blade.png",
		"npc/humanoid_human_argoniel.png",
		"npc/humanoid_human_assassin.png",
		"npc/humanoid_human_bandit_lord.png",
		"npc/humanoid_human_bandit.png",
		"npc/humanoid_human_ben_cruthdar__the_cursed.png",
		"npc/humanoid_human_blood_mage.png",
		"npc/humanoid_human_celia.png",
		"npc/humanoid_human_cryomancer.png",
		"npc/humanoid_human_cutpurse.png",
		"npc/humanoid_human_derth_guard.png",
		"npc/humanoid_human_enthralled_slave.png",
		"npc/humanoid_human_fallen_sun_paladin_aeryn.png",
		"npc/humanoid_human_fire_wyrmic.png",
		"npc/humanoid_human_fryjia_loren.png",
		"npc/humanoid_human_geomancer.png",
		"npc/humanoid_human_gladiator.png",
		"npc/humanoid_human_great_gladiator.png",
		"npc/humanoid_human_harno__herald_of_last_hope.png",
		"npc/humanoid_human_hexer.png",
		"npc/humanoid_human_high_gladiator.png",
		"npc/humanoid_human_high_slinger.png",
		"npc/humanoid_human_high_sun_paladin_aeryn.png",
		"npc/humanoid_human_high_sun_paladin_rodmour.png",
		"npc/humanoid_human_human_citizen.png",
		"npc/humanoid_human_human_farmer.png",
		"npc/humanoid_human_human_guard.png",
		"npc/humanoid_human_human_sun_paladin.png",
		"npc/humanoid_human_ice_wyrmic.png",
		"npc/humanoid_human_last_hope_guard.png",
		"npc/humanoid_human_linaniil_supreme_archmage.png",
		"npc/humanoid_human_lumberjack.png",
		"npc/humanoid_human_martyr.png",
		"npc/humanoid_human_master_alchemist.png",
		"npc/humanoid_human_multihued_wyrmic.png",
		"npc/humanoid_human_necromancer.png",
		"npc/humanoid_human_pyromancer.png",
		"npc/humanoid_human_reaver.png",
		"npc/humanoid_human_rej_arkatis.png",
		"npc/humanoid_human_riala_shalarak.png",
		"npc/humanoid_human_rogue.png",
		"npc/humanoid_human_sand_wyrmic.png",
		"npc/humanoid_human_shadowblade.png",
		"npc/humanoid_human_shady_cornac_man.png",
		"npc/humanoid_human_slave_combatant.png",
		"npc/humanoid_human_slinger.png",
		"npc/humanoid_human_spectator02.png",
		"npc/humanoid_human_spectator03.png",
		"npc/humanoid_human_spectator.png",
		"npc/humanoid_human_storm_wyrmic.png",
		"npc/humanoid_human_subject_z.png",
		"npc/humanoid_human_sun_paladin_guren.png",
		"npc/humanoid_human_tannen.png",
		"npc/humanoid_human_tempest.png",
		"npc/humanoid_human_thief.png",
		"npc/humanoid_human_trickster.png",
		"npc/humanoid_human_urkis__the_high_tempest.png",
		"npc/humanoid_human_valfred_loren.png",
		"npc/humanoid_human_ziguranth_wyrmic.png",
		"npc/humanoid_orc_brotoq_the_reaver.png",
		"npc/humanoid_orc_fiery_orc_wyrmic.png",
		"npc/humanoid_orc_golbug_the_destroyer.png",
		"npc/humanoid_orc_gorbat__supreme_wyrmic_of_the_pride.png",
		"npc/humanoid_orc_grushnak__battlemaster_of_the_pride.png",
		"npc/humanoid_orc_icy_orc_wyrmic.png",
		"npc/humanoid_orc_krogar.png",
		"npc/humanoid_orc_massok_the_dragonslayer.png",
		"npc/humanoid_orc_orc_archer.png",
		"npc/humanoid_orc_orc_assassin.png",
		"npc/humanoid_orc_orc_berserker.png",
		"npc/humanoid_orc_orc_blood_mage.png",
		"npc/humanoid_orc_orc_corruptor.png",
		"npc/humanoid_orc_orc_cryomancer.png",
		"npc/humanoid_orc_orc_elite_berserker.png",
		"npc/humanoid_orc_orc_elite_fighter.png",
		"npc/humanoid_orc_orc_fighter.png",
		"npc/humanoid_orc_orc_grand_master_assassin.png",
		"npc/humanoid_orc_orc_grand_summoner.png",
		"npc/humanoid_orc_orc_high_cryomancer.png",
		"npc/humanoid_orc_orc_high_pyromancer.png",
		"npc/humanoid_orc_orc_mage_hunter.png",
		"npc/humanoid_orc_orc_master_assassin.png",
		"npc/humanoid_orc_orc_master_wyrmic.png",
		"npc/humanoid_orc_orc_necromancer.png",
		"npc/humanoid_orc_orc_pyromancer.png",
		"npc/humanoid_orc_orc_soldier.png",
		"npc/humanoid_orc_orc_summoner.png",
		"npc/humanoid_orc_orc_warrior.png",
		"npc/humanoid_orc_rak_shor_cultist.png",
		"npc/humanoid_orc_rak_shor__grand_necromancer_of_the_pride.png",
		"npc/humanoid_orc_ukruk_the_fierce.png",
		"npc/humanoid_orc_vor__grand_geomancer_of_the_pride.png",
		"npc/humanoid_orc_warmaster_gnarg.png",
		"npc/humanoid_shalore_archmage_tarelion.png",
		"npc/humanoid_shalore_elandar.png",
		"npc/humanoid_shalore_elvala_guard.png",
		"npc/humanoid_shalore_elven_blood_mage.png",
		"npc/humanoid_shalore_elven_corruptor.png",
		"npc/humanoid_shalore_elven_cultist.png",
		"npc/humanoid_shalore_elven_elite_warrior.png",
		"npc/humanoid_shalore_elven_guard.png",
		"npc/humanoid_shalore_elven_mage.png",
		"npc/humanoid_shalore_elven_tempest.png",
		"npc/humanoid_shalore_elven_warrior.png",
		"npc/humanoid_shalore_grand_corruptor.png",
		"npc/humanoid_shalore_mean_looking_elven_guard.png",
		"npc/humanoid_shalore_rhaloren_inquisitor.png",
		"npc/humanoid_shalore_shalore_rune_master.png",
		"npc/humanoid_thalore_thalore_hunter.png",
		"npc/humanoid_thalore_thalore_wilder.png",
		"npc/humanoid_thalore_ziguranth_summoner.png",
		"npc/humanoid_yaech_blood_master.png",
		"npc/humanoid_yaech_murgol__the_yaech_lord.png",
		"npc/humanoid_yaech_slaver.png",
		"npc/humanoid_yaech_yaech_diver.png",
		"npc/humanoid_yaech_yaech_hunter.png",
		"npc/humanoid_yaech_yaech_mindslayer.png",
		"npc/humanoid_yaech_yaech_psion.png",
		"npc/humanoid_yeek_yeek_wayist.png",
		"npc/humanoid_yeek_yeek_summoner.png",
		"npc/humanoid_yeek_yeek_psionic.png",
		"npc/humanoid_yeek_yeek_mindslayer.png",
		"npc/humanoid_yeek_yeek_commoner_01.png",
		"npc/humanoid_yeek_yeek_commoner_02.png",
		"npc/humanoid_yeek_yeek_commoner_03.png",
		"npc/humanoid_yeek_yeek_commoner_04.png",
		"npc/humanoid_yeek_yeek_commoner_05.png",
		"npc/humanoid_yeek_yeek_commoner_06.png",
		"npc/humanoid_yeek_yeek_commoner_07.png",
		"npc/humanoid_yeek_yeek_commoner_08.png",
		"npc/jawa_01.png",
		"npc/lesser_vampire.png",
		"npc/master_skeleton_archer.png",
		"npc/master_skeleton_warrior.png",
		"npc/master_vampire.png",
		"npc/skeleton_archer.png",
		"npc/skeleton_mage.png",
		"npc/skeleton_warrior.png",
		"npc/undead_skeleton_cowboy.png",
		"npc/the_master.png",
		"npc/vampire_lord.png",
		"npc/vampire.png",
		"npc/undead_skeleton_filio_flightfond.png",
		"npc/undead_ghoul_borfast_the_broken.png",
		"npc/horror_eldritch_umbral_horror.png",
		"npc/demon_major_general_of_urh_rok.png",
		"npc/demon_major_shasshhiy_kaish.png",
		"npc/undead_vampire_arch_zephyr.png",
		"npc/undead_ghoul_rotting_titan.png",
		"npc/humanoid_human_townsfolk_aimless_looking_merchant01_64.png",
		"npc/humanoid_human_townsfolk_battlescarred_veteran01_64.png",
		"npc/humanoid_human_townsfolk_blubbering_idiot01_64.png",
		"npc/humanoid_human_townsfolk_boilcovered_wretch01_64.png",
		"npc/humanoid_human_townsfolk_farmer_maggot01_64.png",
		"npc/humanoid_human_townsfolk_filthy_street_urchin01_64.png",
		"npc/humanoid_human_townsfolk_mangy_looking_leper01_64.png",
		"npc/humanoid_human_townsfolk_meanlooking_mercenary01_64.png",
		"npc/humanoid_human_townsfolk_pitiful_looking_beggar01_64.png",
		"npc/humanoid_human_townsfolk_singing_happy_drunk01_64.png",
		"npc/humanoid_human_townsfolk_squinteyed_rogue01_64.png",
		"npc/humanoid_human_townsfolk_village_idiot01_64.png",
		"npc/humanoid_naga_lady_zoisla_the_tidebringer.png",
		"npc/humanoid_naga_naga_nereid.png",
		"npc/humanoid_naga_naga_tidecaller.png",
		"npc/humanoid_naga_naga_tidewarden.png",
		"npc/humanoid_naga_slasul.png",
		"npc/naga_myrmidon_2.png",
		"npc/naga_myrmidon_no_armor.png",
		"npc/naga_myrmidon.png",
		"npc/naga_psyren2_2.png",
		"npc/naga_psyren2.png",
		"npc/naga_psyren.png",
		"npc/naga_tide_huntress_2.png",
		"npc/naga_tide_huntress.png",
		"npc/snowman01.png",
		"npc/snaproot_pimp.png",
		"npc/R2D2_01.png",
		"npc/humanoid_female_sluttymaid.png",
		"npc/humanoid_male_sluttymaid.png",
		"player/ascii_player_dorfhelmet_01_64.png",
		"player/ascii_player_fedora_feather_04_64.png",
		"player/ascii_player_helmet_02_64.png",
		"player/ascii_player_mario_01_64.png",
		"player/ascii_player_rogue_cloak_01_64.png",
		"player/ascii_player_wizardhat_01_64.png",
		"player/ascii_player_gentleman_01_64.png",
		"player/ascii_player_red_hood_01.png",
		"player/ascii_player_pink_amazone_01.png",
		"player/ascii_player_bunny_01.png",
		"player/ascii_player_exotic_01.png",
		"player/ascii_player_shopper_01.png",
	}
	self:triggerHook{"Birther:donatorTiles", list=list}
	local remove = Button.new{text="기본 타일을 사용", width=500, fct=function()
		game:unregisterDialog(d)
		self.has_custom_tile = nil
		self:setTile()
	end}
	local list = ImageList.new{width=500, height=500, tile_w=64, tile_h=64, padding=10, scrollbar=true, list=list, fct=function(item)
		game:unregisterDialog(d)
		if not self:isDonator() then
			self:selectTileNoDonations()
		else
			self:setTile(item.f, item.w, item.h)
		end
	end}
	d:loadUI{
		{left=0, top=0, ui=list},
		{left=0, bottom=0, ui=remove},
	}
	d:setupUI(true, true)
	d.key:addBind("EXIT", function() game:unregisterDialog(d) end)
	game:registerDialog(d)
end

function _M:customizeOptions()
	local d = Dialog.new("생김새 설정", 600, 550)

	local sel = nil
	local list list = List.new{width=450, list=self.cosmetic_unlocks, height=400,
		fct=function(item)
			if not item.donator or self:isDonator() then
				self.selected_cosmetic_unlocks[item.name] = not self.selected_cosmetic_unlocks[item.name]
				item.color = self.selected_cosmetic_unlocks[item.name] and colors.simple(colors.LIGHT_GREEN) or nil
			end

			local oldsel, oldscroll = list.sel, list.scroll
			list:generate()
			list.sel, list.scroll = oldsel, oldscroll
			self:setTile()
		end,
	}
	d:loadUI{
		{left=0, top=0, ui=list},
	}
	d:setupUI(true, true)
	d.key:addBind("EXIT", function() game:unregisterDialog(d) end)
	game:registerDialog(d)
end

return _M
