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

name = "Falling Toward Apotheosis"
kr_display_name = "신에 이르는 길"
desc = function(self, who)
	local desc = {}

	if not self:isCompleted() then
		desc[#desc+1] = "당신은 오크 무리를 통솔하는 네 명의 오크들을 무찔렀습니다. 이제 당신은 이 세계에서 가장 위험한 곳인, 최고봉을 탐험해야 합니다."
		desc[#desc+1] = "그곳에서 세계를 마음대로 주무르려고 하는 주술사들을 찾아, 그들을 막아야 합니다."
		desc[#desc+1] = "최고봉에 있는 보호막을 해제하고 그곳에 들어가기 위해서는, 지배의 오브가 4 개 필요합니다."
		desc[#desc+1] = "최고봉의 입구와 연결된 길은 '슬라임 굴' 이라고 불리는 곳에 있으며, 이곳은 그루쉬낙 무리 어딘가에 있다고 합니다."
	else
		desc[#desc+1] = "당신은 최고봉의 꼭대기에 올라, 주술사들의 성소에 도착했습니다. 이제 주술사들을 파괴하고, 이 세계를 악의 위협으로부터 구원할 시간입니다."
		desc[#desc+1] = "당신은 게임에서 승리하셨습니다!"
	end

	if self:isCompleted("killed-aeryn") then desc[#desc+1] = "#LIGHT_GREEN#* 당신은 태양의 장벽의 패배가 당신 때문에 일어났다고 비난하는 태양의 기사 아에린과 마주치게 되었습니다. 당신은 어쩔 수 없이 그녀를 죽였습니다.#LAST#" end
	if self:isCompleted("spared-aeryn") then desc[#desc+1] = "#LIGHT_GREEN#* 당신은 태양의 장벽의 패배가 당신 때문에 일어났다고 비난하는 태양의 기사 아에린과 마주치게 되었습니다. 하지만 당신은 그녀의 목숨을 앗아가지 않았습니다.#LAST#" end

	if game.winner and game.winner == "full" then desc[#desc+1] = "#LIGHT_GREEN#* 당신은 주술사들을 해치웠으며, 공허의 관문이 열리는 것도 막아냈습니다.#LAST#" end
	if game.winner and game.winner == "aeryn-sacrifice" then desc[#desc+1] = "#LIGHT_GREEN#* 당신은 주술사들을 해치웠지만, 공허의 관문을 닫기 위해 아에린 스스로가 희생했습니다.#LAST#" end
	if game.winner and game.winner == "self-sacrifice" then desc[#desc+1] = "#LIGHT_GREEN#* 당신은 주술사들을 해치웠지만, 공허의 관문을 닫기 위해 자신을 희생했습니다.#LAST#" end

	return table.concat(desc, "\n")
end

on_grant = function(self, who)
end

on_status_change = function(self, who, status, sub)
	if sub then
		if self:isCompleted("elandar-dead") and self:isCompleted("argoniel-dead") and not who:isQuestStatus("high-peak", engine.Quest.DONE) then
			who:setQuestStatus(self.id, engine.Quest.DONE)

			-- Remove all remaining hostiles
			for i = #game.level.e_array, 1, -1 do
				local e = game.level.e_array[i]
				if game.player:reactionToward(e) < 0 then game.level:removeEntity(e) end
			end

			local Chat = require"engine.Chat"
			local chat = Chat.new("sorcerer-end", {name="Endgame", kr_display_name="대단원"}, game:getPlayer(true))
			chat:invoke()

			self:end_end_combat()
		end
	end
end

function start_end_combat(self)
	local p = game.party:findMember{main=true}
	game.level.allow_portals = true
end

function end_end_combat(self)
	local floor = game.zone:makeEntityByName(game.level, "terrain", "FLOOR")
	for i = 8, 13 do
		game.level.map(i, 11, engine.Map.TERRAIN, floor)
	end
	for i = 36, 41 do
		game.level.map(i, 11, engine.Map.TERRAIN, floor)
	end
	game.level.allow_portals = false

	local nb_portal = 0
	if self:isCompleted("closed-portal-demon") then nb_portal = nb_portal + 1 end
	if self:isCompleted("closed-portal-dragon") then nb_portal = nb_portal + 1 end
	if self:isCompleted("closed-portal-elemental") then nb_portal = nb_portal + 1 end
	if self:isCompleted("closed-portal-undead") then nb_portal = nb_portal + 1 end
	if nb_portal == 0 then world:gainAchievement("SORCERER_NO_PORTAL", game.player)
	elseif nb_portal == 1 then world:gainAchievement("SORCERER_ONE_PORTAL", game.player)
	elseif nb_portal == 2 then world:gainAchievement("SORCERER_TWO_PORTAL", game.player)
	elseif nb_portal == 3 then world:gainAchievement("SORCERER_THREE_PORTAL", game.player)
	elseif nb_portal == 4 then world:gainAchievement("SORCERER_FOUR_PORTAL", game.player)
	end
end

function failed_charred_scar(self, level)
	if not game.state:isUniqueDead("High Sun Paladin Aeryn") then
		local aeryn = game.zone:makeEntityByName(level, "actor", "FALLEN_SUN_PALADIN_AERYN")
		game.zone:addEntity(level, aeryn, "actor", level.default_down.x, level.default_down.y)
		game.logPlayer(game.player, "#LIGHT_RED#당신이 이곳에 도착하자, 친숙한 목소리가 들렸습니다.")
		game.logPlayer(game.player, "#LIGHT_RED#패배한 태양의 기사 아에린이 외칩니다. '%s, 네가 태양의 장벽에 가져다준 것은 파괴 뿐이다! 너는 그 대가를 치르게 될 것이다!'", game.player.name:upper())
	end

	game:onLevelLoad("wilderness-1", function(zone, level)
		local spot = level:pickSpot{type="zone-pop", subtype="ruined-gates-of-morning"}
		local wild = level.map(spot.x, spot.y, engine.Map.TERRAIN)
		wild.name = "Ruins of the Gates of Morning"
		wild.kr_display_nmae = "파괴된 아침의 문"
		wild.desc = "당신이 최고봉에 갇혀 있는 동안, 태양의 장벽은 파괴되었습니다."
		wild.change_level = nil
		wild.change_zone = nil
	end)
	game.player:setQuestStatus(self.id, engine.Quest.COMPLETED, "gates-of-morning-destroyed")
end

function win(self, how)
	game:playAndStopMusic("Lords of the Sky.ogg")
	game.party:learnLore("closing-farportal")

	if how == "full" then world:gainAchievement("WIN_FULL", game.player)
	elseif how == "aeryn-sacrifice" then world:gainAchievement("WIN_AERYN", game.player)
	elseif how == "self-sacrifice" then world:gainAchievement("WIN_SACRIFICE", game.player)
	elseif how == "yeek-sacrifice" then world:gainAchievement("YEEK_SACRIFICE", game.player)
	end

	game:setAllowedBuild("adventurer", true)
	if game.difficulty == game.DIFFICULTY_NIGHTMARE then game:setAllowedBuild("difficulty_insane", true) end

	local p = game:getPlayer(true)
	p.winner = how
	game:registerDialog(require("engine.dialogs.ShowText").new("Winner", "win", {playername=p.name, how=how}, game.w * 0.6))
	game:saveGame()
end

function onWin(self, who)
	local desc = {}

	desc[#desc+1] = "#GOLD#축하합니다! 당신은 마즈'에이알 : 주도의 시대 게임에서 승리하셨습니다!#WHITE#"
	desc[#desc+1] = ""
	desc[#desc+1] = "당신의 노력 덕분에 주술사들은 죽었으며, 오크 무리들은 파괴되었습니다."
	desc[#desc+1] = ""

	-- Yeeks are special
	if who:isQuestStatus("high-peak", engine.Quest.COMPLETED, "yeek") then
		desc[#desc+1] = "당신의 희생은 성과가 있었습니다. 당신의 정신력은 장거리 관문의 힘에 주입되었으며, '한길' 은 최고봉에서 에이알 세계의 끝자락까지 닿는 정신력의 파도를 방출했습니다."
		desc[#desc+1] = "에이알 세계에 있는 모든 이성 있는 생명체들은 이제 '한길' 의 일원입니다. 평화와 행복이 모두에게 강제되었습니다."
		desc[#desc+1] = "오직 앙골웬의 마법사들만이 정신적 충격에서 버텨내었고, 이제 그들만이 아직 '안전하지 못한' 사람들이 되었습니다. 하지만 '한길' 의 위대함 앞에서 그들이 무엇을 할 수 있을까요?"
		return 0, desc
	end

	if who.winner == "full" then
		desc[#desc+1] = "당신은 공허의 관문이 열리는 것을 막아내었으며, 이를 통해 창조자가 이 세계의 종말을 불러오지 못하도록 만들었습니다."
	elseif who.winner == "aeryn-sacrifice" then
		desc[#desc+1] = "이타적인 마음으로, 고위 태양의 기사 아에린은 그녀 스스로를 희생하여 공허의 관문이 열리는 것을 막아내었습니다. 창조자가 공허의 관문을 타고 넘어와 이 세계의 종말을 불러오지 못하도록 만든 것입니다."
	elseif who.winner == "self-sacrifice" then
		desc[#desc+1] = "이타적인 마음으로, 당신은 스스로를 희생하여 공허의 관문이 열리는 것을 막아내었습니다. 창조자가 공허의 관문을 타고 넘어와 이 세계의 종말을 불러오지 못하도록 만든 것입니다."
	end

	if who:isQuestStatus("high-peak", engine.Quest.COMPLETED, "gates-of-morning-destroyed") then
		desc[#desc+1] = ""
		desc[#desc+1] = "아침의 문은 파괴되었고, 태양의 장벽은 패배했습니다. 동대륙에 있던 마지막 자유민들은 완전히 절멸했으며, 곧 오크들이 이 땅을 지배하게 될 것입니다."
	else
		desc[#desc+1] = ""
		desc[#desc+1] = "주술사들이 사라지고 그들의 지도자들이 사망하자, 동대륙에서의 오크 세력은 그 힘이 급격하게 줄어들기 시작했습니다. 태양의 장벽의 자유민들은 이제 이 땅에서 번영하고 번창하게 될 것입니다."
	end

	desc[#desc+1] = ""
	desc[#desc+1] = "마즈'에이알은 다시 한번 평화를 되찾았습니다. 대부분의 사람들은 세계가 멸망할 수 있었다는 사실조차 모르고 평소와 같이 살아가겠지만, '아무도 알아주지 않더라도 옳은 길을 걷는' 당신이 바로 진정한 영웅이라는 사실은 변하지 않을 것입니다."

	if who.winner ~= "self-sacrifice" then
		desc[#desc+1] = ""
		desc[#desc+1] = "이제 자유롭게 이 세계를 여행하고, 즐기실 수 있습니다."
	end
	return 0, desc
end
