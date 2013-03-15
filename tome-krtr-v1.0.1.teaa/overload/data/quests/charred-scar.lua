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

-- Ruysh Charred scar
name = "The Doom of the World!"
kr_name = "세계의 종말!"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "당신은 거대한 화산 중심에 있는 '검게 탄 상처' 에 보내졌습니다. 장작더미의 시대에, 화산에 의해 이곳에 있던 고대의 쉐르'툴 유적이 파괴되었다고 합니다."
	desc[#desc+1] = "이곳에는 아직도 쉐르'툴 유적이 품고 있던 잠재된 마력과 힘으로 가득 차 있으며, 이제 오크들이 흡수의 지팡이로 이곳의 힘을 흡수해가려 합니다."
	desc[#desc+1] = "그들의 계획이 무엇이건 간에, 어떤 대가를 치뤄서라도 그들을 반드시 멈춰야 합니다."
	desc[#desc+1] = "이 화산은 오크의 공격을 받고 있습니다. 몇몇 태양의 기사들이 당신에게 약간의 시간을 주기 위해, 목숨을 바쳐 오크들의 공격을 막고 있습니다."
	desc[#desc+1] = "그들의 희생을 헛되게 만들어서는 안됩니다. 오크들이 그들의 일을 끝내지 못하도록 만들어야 합니다!"
	if self:isCompleted("not-stopped") then
		desc[#desc+1] = ""
		desc[#desc+1] = "당신은 너무 늦었습니다. 이곳의 힘은 모두 흡수당했고 주술사들은 자리를 떠났습니다."
		desc[#desc+1] = "관문을 사용해서 동대륙으로 돌아가십시오. 당신은 그 어떤 대가를 치뤄서라도, 그들을 *반드시* 멈춰야 합니다."
	elseif self:isCompleted("stopped") then
		desc[#desc+1] = ""
		desc[#desc+1] = "당신은 제때에 도착하여, 의식을 방해했습니다. 주술사들은 도망쳤습니다."
		desc[#desc+1] = "관문을 사용해서 동대륙으로 돌아가십시오. 당신은 그 어떤 대가를 치뤄서라도, 그들을 *반드시* 멈춰야 합니다."
	end
	return table.concat(desc, "\n")
end

start_fyrk = function(self)
	game.zone.on_turn = nil
	game.level.turn_counter = nil

	local elandar, argoniel
	for uid, e in pairs(game.level.entities) do
		if e.define_as == "ELANDAR" then elandar = e
		elseif e.define_as == "ARGONIEL" then argoniel = e end
	end

	if elandar then game.level:removeEntity(elandar) elandar.dead = true end
	if argoniel then game.level:removeEntity(argoniel) argoniel.dead = true end

	local portal = game.zone:makeEntityByName(game.level, "grid", "FAR_EAST_PORTAL")
	game.zone:addEntity(game.level, portal, "grid", 5, 455) game.nicer_tiles:updateAround(game.level, 5, 455)
	game.zone:addEntity(game.level, portal, "grid", 6, 455) game.nicer_tiles:updateAround(game.level, 6, 455)
	game.zone:addEntity(game.level, portal, "grid", 7, 455) game.nicer_tiles:updateAround(game.level, 7, 455)
	game.zone:addEntity(game.level, portal, "grid", 5, 454) game.nicer_tiles:updateAround(game.level, 6, 454)
	game.zone:addEntity(game.level, portal, "grid", 7, 454) game.nicer_tiles:updateAround(game.level, 7, 454)
	game.zone:addEntity(game.level, portal, "grid", 5, 453) game.nicer_tiles:updateAround(game.level, 5, 453)
	game.zone:addEntity(game.level, portal, "grid", 6, 453) game.nicer_tiles:updateAround(game.level, 6, 453)
	game.zone:addEntity(game.level, portal, "grid", 7, 453) game.nicer_tiles:updateAround(game.level, 7, 453)
	local portal = game.zone:makeEntityByName(game.level, "grid", "CFAR_EAST_PORTAL")
	game.zone:addEntity(game.level, portal, "grid", 6, 454)

	local fyrk = game.zone:makeEntityByName(game.level, "actor", "FYRK")
	game.zone:addEntity(game.level, fyrk, "actor", 6, 452)

	if self:isCompleted("not-stopped") then
		game.logPlayer(game.player, "#VIOLET#근처에서 관문이 작동했습니다. 당신은 오크들이 외치는 소리를 들었습니다. '주술사들이 자리를 떴다! 그들을 따르라!'")
	else
		game.logPlayer(game.player, "#VIOLET#주술사들은 관문을 사용해서 도망쳤습니다. 당신이 그들을 쫓으려 하자, 거대한 패로스가 나타나 당신의 길을 막습니다.")
		world:gainAchievement("CHARRED_SCAR_SUCCESS", game.player)
	end
	game.player:setQuestStatus("charred-scar", engine.Quest.COMPLETED)
	game.state:storesRestock()
end
