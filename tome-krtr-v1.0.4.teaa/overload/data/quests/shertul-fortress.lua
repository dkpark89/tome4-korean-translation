-- ToME - Tales of Maj'Eyal
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

name = "Sher'Tul Fortress"
kr_name = "쉐르'툴 요새"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "당신은 오래된 숲에서 한 모험가가 남긴 쪽지들을 찾았습니다. 그는 쪽지를 통해, 쉐르'툴 종족의 유적이 숲 중심부에 있는 누르 호수 밑에 가라앉아 있다고 했습니다."
	desc[#desc+1] = "그가 작성한 쪽지들 중 하나에서, 마치 열쇠처럼 보이는 작은 보석을 발견했습니다."
	if self:isCompleted("entered") then
		desc[#desc+1] = "#LIGHT_GREEN#* 당신은 열쇠를 사용해서 누르 호수 안에 있는 유적의 문을 열었고, 오래된 요새로 가는 길을 발견했습니다.#WHITE#"
	end
	if self:isCompleted("weirdling") then
		desc[#desc+1] = "#LIGHT_GREEN#* 불가사의한 짐승을 죽이자, 요새 안으로 들어갈 수 있게 되었습니다.#WHITE#"
	end
	if self:isCompleted("butler") then
		desc[#desc+1] = "#LIGHT_GREEN#* 당신은 되돌림의 장대를 통해, 마치 집사와 비슷한 행동을 하는 무언가...를 불러냈습니다.#WHITE#"
	end
	if self:isCompleted("transmo-chest") then
		desc[#desc+1] = "#LIGHT_GREEN#* 당신은 요새의 동력 장치와 연결된, 변환 상자를 받았습니다.#WHITE#"
	end
	if self:isCompleted("transmo-chest-extract-gems") then
		desc[#desc+1] = "#LIGHT_GREEN#* 당신은 변환 상자를 강화시켜, 변환 상자가 금속 장비들을 보석으로 자동 변환시킬 수 있게 만들었습니다.#WHITE#"
	end
	if self:isCompleted("recall") then
		if self:isCompleted("recall-done") then
			desc[#desc+1] = "#LIGHT_GREEN#* 당신은 되돌림의 장대를 강화시켜, 되돌림의 장대를 사용하면 바로 요새로 이동할 수 있게 만들었습니다.#WHITE#"
		else
			desc[#desc+1] = "#SLATE#* 요새의 그림자가, 가능한 빨리 요새에 와달라는 요청을 했습니다.#WHITE#"
		end
	end
	if self:isCompleted("farportal") then
		if self:isCompleted("farportal-broken") then
			desc[#desc+1] = "#RED#* 당신은 탐험용 장거리 관문을 사용하던 중에 강제적으로 귀환을 했습니다. 이 과정에서 장거리 관문이 고장나 사용하지 못하게 되었습니다.#WHITE#"
		elseif self:isCompleted("farportal-done") then
			desc[#desc+1] = "#LIGHT_GREEN#* 당신은 탐험용 장거리 관문이 있는 방에 들어가 그곳에 있는 공포를 해치웠습니다. 이제 장거리 관문을 사용할 수 있게 되었습니다.#WHITE#"
		else
			desc[#desc+1] = "#SLATE#* 요새의 그림자가, 가능한 빨리 요새에 와달라는 요청을 했습니다.#WHITE#"
		end
	end
	if self:isCompleted("flight") then
		if self:isCompleted("flight-done") then
			desc[#desc+1] = "#LIGHT_GREEN#* 당신은 요새의 비행 체계를 재가동 시켰습니다. 이제 요새를 사용해서 날아다닐 수 있습니다!#WHITE#"
		else
			desc[#desc+1] = "#SLATE#* 요새의 그림자가 당신에게 고대의 폭풍 사파이어를 찾아줄 것을 요청했습니다. 이것과 250 에너지가 있으면, 요새의 비행 체계를 재가동 시킬 수 있다고 합니다.#WHITE#"
		end
	end
	if self.shertul_energy > 0 then
		desc[#desc+1] = ("\n요새가 지금까지 모은 에너지의 총량 : #LIGHT_GREEN#%d#WHITE#."):format(self.shertul_energy)
	end
	return table.concat(desc, "\n")
end

on_grant = function(self, who)
	self.shertul_energy = 0
	self.explored = 0
end

break_farportal = function(self)
	game.player:setQuestStatus(self.id, self.COMPLETED, "farportal-broken")
end

spawn_butler = function(self)
	local spot = game.level:pickSpot{type="spawn", subtype="butler"}
	local butler = game.zone:makeEntityByName(game.level, "actor", "BUTLER")
	game.zone:addEntity(game.level, butler, "actor", spot.x, spot.y)
	game.level.map:particleEmitter(spot.x, spot.y, 1, "demon_teleport")

	game.player:setQuestStatus(self.id, self.COMPLETED, "butler")

	world:gainAchievement("SHERTUL_FORTRESS", game.player)
end

spawn_transmo_chest = function(self, energy)
	local spot = game.level:pickSpot{type="spawn", subtype="butler"}
	local chest = game.zone:makeEntityByName(game.level, "object", "TRANSMO_CHEST", true)
	game.zone:addEntity(game.level, chest, "object", spot.x + 1, spot.y)
	game.level.map:particleEmitter(spot.x, spot.y, 1, "demon_teleport")
	game.player:setQuestStatus(self.id, self.COMPLETED, "transmo-chest")

	game:setAllowedBuild("birth_transmo_chest", true)
end

gain_energy = function(self, energy)
	self.shertul_energy = self.shertul_energy + energy

	if self.shertul_energy >= 15 and not self:isCompleted("recall") then
		game.player:setQuestStatus(self.id, self.COMPLETED, "recall")
		local Dialog = require "engine.ui.Dialog"
		Dialog:simpleLongPopup("요새의 그림자", "주인님, 요새에 충분한 에너지가 모여 되돌림의 장대를 강화시킬 수 있게 되었습니다. 요새로 돌아와주십시오.", 400)
	end

	if self.shertul_energy >= 45 and not self:isCompleted("farportal") then
		game.player:setQuestStatus(self.id, self.COMPLETED, "farportal")
		local Dialog = require "engine.ui.Dialog"
		Dialog:simpleLongPopup("요새의 그림자", "주인님, 요새에 충분한 에너지가 모여 탐험용 장거리 관문을 활성화시킬 수 있게 되었습니다.\n하지만, 관문이 있는 방에 뭔가 알 수 없는 존재가 있습니다. 가능한 빨리 요새로 돌아와주십시오.", 400)
	end

	if self.shertul_energy >= 250 and not self:isCompleted("flight") then
--		game.player:setQuestStatus(self.id, self.COMPLETED, "flight")
--		local Dialog = require "engine.ui.Dialog"
--		Dialog:simpleLongPopup("Fortress Shadow", "Master, you have sent enough energy to activate the flight systems.\nHowever, one control crystal is broken. You need to find an #GOLD#Ancient Storm Saphir#WHITE#.", 400)
	end
end

exploratory_energy = function(self, check_only)
	if self.shertul_energy < 45 then return false end
	if not self:isCompleted("farportal-done") then return false end
	if check_only then return true end

	self.shertul_energy = self.shertul_energy - 45
	self.explored = self.explored + 1
	if self.explored == 7 then world:gainAchievement("EXPLORER", game.player) end
	return true
end

spawn_farportal_guardian = function(self)
	game.player:setQuestStatus("shertul-fortress", self.COMPLETED, "farportal-spawn")

	-- Pop a random boss
	local spot = game.level:pickSpot{type="spawn", subtype="farportal"}
	local boss = game.zone:makeEntity(game.level, "actor", {type="horror", not_properties={"unique"}, random_boss=true}, nil, true)
	boss.shertul_on_die = boss.on_die
	boss.on_die = function(self, ...)
		game.player:setQuestStatus("shertul-fortress", engine.Quest.COMPLETED, "farportal-done")
		self:check("shertul_on_die", ...)
	end
	game.zone:addEntity(game.level, boss, "actor", spot.x, spot.y)

	-- Open the door, destroy the stairs
	local g = game.zone:makeEntityByName(game.level, "terrain", "OLD_FLOOR")
	local spot = game.level:pickSpot{type="door", subtype="farportal"}
	game.zone:addEntity(game.level, g, "terrain", spot.x, spot.y)
end

upgrade_rod = function(self)
	if self.shertul_energy < 15 then
		local Dialog = require "engine.ui.Dialog"
		Dialog:simplePopup("요새의 그림자", "에너지가 부족합니다. 최소 15 에너지가 필요합니다.")
		return
	end
	self.shertul_energy = self.shertul_energy - 15

	local rod = game.player:findInAllInventoriesBy("define_as", "ROD_OF_RECALL")
	if not rod then return end

	game.player:setQuestStatus("shertul-fortress", self.COMPLETED, "recall-done")
	rod.shertul_fortress = true
	game.log("#VIOLET#되돌림의 장대가 잠시 밝게 빛났습니다.")
end

upgrade_transmo_gems = function(self)
	if self.shertul_energy < 25 then
		local Dialog = require "engine.ui.Dialog"
		Dialog:simplePopup("요새의 그림자", "에너지가 부족합니다. 최소 25 에너지가 필요합니다.")
		return
	end
	self.shertul_energy = self.shertul_energy - 25

	game.player:setQuestStatus("shertul-fortress", self.COMPLETED, "transmo-chest-extract-gems")
	game.log("#VIOLET#변환 상자가 잠시 밝게 빛났습니다.")
end

fly = function(self)
	if self:isStatus(self.COMPLETED, "flying") then
		game:changeLevel(1, "wilderness", {direct_switch=true})

		local f = nil
		for uid, e in pairs(game.level.entities) do
			if e.is_fortress then f = e break end
		end

		if not f then
			game.log("요새를 찾을 수 없습니다!")
			return
		end

		f:takeControl(game.player)
	else
		game.party:learnLore("shertul-fortress-takeoff")

		local f = require("mod.class.FortressPC").new{}
		game:changeLevel(1, "wilderness", {direct_switch=true})
		game.party:addMember(f, {temporary_level=1, control="full"})
		f.x = game.player.x
		f.y = game.player.y
		game.party:setPlayer(f, true)
		game.level:addEntity(f)
		game.level.map:remove(f.x, f.y, engine.Map.ACTOR)
		f:move(f.x, f.y, true)

		game.player:setQuestStatus("shertul-fortress", self.COMPLETED, "flying")
	end
end
