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

name = "The fall of Zigur"
kr_display_name = "지구르의 몰락"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "당신은 위대한 타락자의 편에 서서, 지구르 추종자들이 모인 집결지를 공격하기로 했습니다."
	if self:isStatus(self.FAILED) then
		desc[#desc+1] = "위대한 타락자는 지구르를 공격하던 중에 죽음을 맞이하여, 당신에게 그의 길을 전수해주지 못했습니다."
	elseif self:isStatus(self.DONE) then
		desc[#desc+1] = "지구르의 수호자들은 무릎을 꿇었으며, 지구르 추종자들은 흩어지고 약해졌습니다."
	end
	if self:isStatus(self.COMPLETED, "grand-corruptor-treason") then
		desc[#desc+1] = "지구르를 파괴한 당신은, 위대한 타락자를 배신하여 그를 해치웠습니다."
	end

	return table.concat(desc, "\n")
end

on_grant = function(self, who)
	engine.Faction:setFactionReaction(game.player.faction, "rhalore", 100, true)
	engine.Faction:setFactionReaction(game.player.faction, "zigur", -100, true)
	game:changeLevel(1, "town-zigur", {direct_switch=true})
	game.zone.base_level = game.player.level

	-- Clean up the player of bad effects
	game.player:resetToFull()
	local effs = {}
	for eff_id, p in pairs(game.player.tmp) do
		local e = game.player.tempeffect_def[eff_id]
		if e.status == "detrimental" then effs[#effs+1] = {"effect", eff_id} end
	end
	while #effs > 0 do
		local eff = rng.tableRemove(effs)
		game.player:removeEffect(eff[2])
	end

	local spot, x, y, m

	-- Summon the ziguranth defenders
	for uid, e in pairs(game.level.entities) do
		if e.define_as == "PROTECTOR_MYSSIL" then
			e:setTarget(who)
			break
		end
	end

	for i = 1, 7 do
		spot = game.level:pickSpot{type="arrival", subtype="ziguranth"}
		x, y = util.findFreeGrid(spot.x, spot.y, 5, true, {[engine.Map.ACTOR]=true})
		m = game.zone:makeEntity(game.level, "actor", {special_rarity="ziguranth_rarity"}, nil, true)
		if m and x and y then game.zone:addEntity(game.level, m, "actor", x, y) end
	end

	-- Summon the rhaloren army
	spot = game.level:pickSpot{type="arrival", subtype="rhaloren"}
	x, y = util.findFreeGrid(spot.x, spot.y, 5, true, {[engine.Map.ACTOR]=true})
	if x and y then game.player:move(x, y, true) game.level.map:particleEmitter(x, y, 1, "demon_teleport") end

	spot = game.level:pickSpot{type="arrival", subtype="rhaloren"}
	x, y = util.findFreeGrid(spot.x, spot.y, 5, true, {[engine.Map.ACTOR]=true})
	m = game.zone:makeEntityByName(game.level, "actor", "GRAND_CORRUPTOR")
	if m and x and y then game.zone:addEntity(game.level, m, "actor", x, y) game.level.map:particleEmitter(x, y, 1, "demon_teleport") end

	for i = 1, 3 do
		spot = game.level:pickSpot{type="arrival", subtype="rhaloren"}
		x, y = util.findFreeGrid(spot.x, spot.y, 5, true, {[engine.Map.ACTOR]=true})
		m = game.zone:makeEntity(game.level, "actor", {special_rarity="corruptor_rarity"}, nil, true)
		if m and x and y then game.zone:addEntity(game.level, m, "actor", x, y) game.level.map:particleEmitter(x, y, 1, "demon_teleport") end
	end
end

on_status_change = function(self, who, status, sub)
	if self:isCompleted() then
		who:setQuestStatus(self.id, engine.Quest.DONE)
		world:gainAchievement("ANTI_ANTIMAGIC", game.player)

		game.party:reward("일반 기술 계열인 매혹술을 익힐 동료를 고르시오 :", function(player)
			if who:knowTalentType("corruption/hexes") then
				who:setTalentTypeMastery("corruption/hexes", who:getTalentTypeMastery("corruption/hexes") + 0.2)
			elseif who:knowTalentType("corruption/hexes") == false then
				who:learnTalentType("corruption/hexes", true)
			else
				who:learnTalentType("corruption/hexes", false)
			end
		end)

		require("engine.ui.Dialog"):simplePopup("Grand Corruptor", "#LIGHT_GREEN#위대한 타락자가 당신에게 시선을 집중했습니다. 당신의 마음 속에 지식이 흘러들어오는 것이 느껴졌습니다. 이제 당신은 타락한 힘을 수련할 수 있게 되었습니다.")
		game:setAllowedBuild("corrupter")
		game:setAllowedBuild("corrupter_corruptor", true)
	end
end

corruptor_dies = function(self)
	if self:isStatus(engine.Quest.DONE) then 
		game.player:setQuestStatus(self.id, self.COMPLETED, "grand-corruptor-treason")
		return 
	end
	game.player:setQuestStatus(self.id, self.FAILED)
end

myssil_dies = function(self)
	if self:isEnded() then return end

	local corr = nil
	for uid, e in pairs(game.level.entities) do
		if e.faction == "rhalore" then e:setEffect(e.EFF_VICTORY_RUSH_ZIGUR, 20, {}) end
		if e.define_as and e.define_as == "GRAND_CORRUPTOR" then corr = e end
	end
	if not corr then return end

	corr:doEmote("Victory is mine!", 60)
	corr.never_angry = nil
	game.player:setQuestStatus(self.id, self.COMPLETED)
end

function onWin(self, who)
	if not self:isStatus(self.DONE) then return end
	if self:isStatus(self.COMPLETED, "grand-corruptor-treason") then return end
	return 10, {
		"당신이 동대륙에 있는 동안, 위대한 타락자는 마즈'에이알 대륙에서 바쁜 일상을 보냈습니다.",
		"지구르의 몰락과 함께 그는 샬로레들의 수도인 엘벨라를 공격하여, 그곳을 지배하게 되었습니다.",
		"하지만 그의 계획은 거기서 끝나지 않을 것 같습니다.",
	}
end
