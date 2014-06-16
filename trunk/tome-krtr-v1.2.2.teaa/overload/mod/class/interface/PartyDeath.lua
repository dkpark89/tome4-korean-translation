-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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
require "engine.class"
local Dialog = require "engine.ui.Dialog"
local DamageType = require "engine.DamageType"

module(..., package.seeall, class.make)

function _M:onPartyDeath(src, death_note)
	if self.dead then return true end

	-- Remove from the party if needed
	if self.remove_from_party_on_death then
		game.party:removeMember(self, true)
	-- Overwise note the death turn
	else
		game.party:setDeathTurn(self, game.turn)
	end

	-- Die
	death_note = death_note or {}
	mod.class.Actor.die(self, src, death_note)

	-- Was not the current player, just die
	if game.player ~= self then return end

	-- Check for any survivor that can be controlled
	local game_ender = not game.party:findSuitablePlayer()

	-- No more player found! Switch back to main and die
	if game_ender then
		if self == src then world:gainAchievement("HALFLING_SUICIDE", self) end
		game.party:setPlayer(game.party:findMember{main=true}, true)
		game.paused = true
		game.player.energy.value = game.energy_to_act
		src = src or {name="알 수 없는 자"}
		game.player.killedBy = src
		game.player.died_times[#game.player.died_times+1] = {name=src.name, level=game.player.level, turn=game.turn}
		game.player:registerDeath(game.player.killedBy)
		local dialog = require("mod.dialogs."..(game.player.death_dialog or "DeathDialog")).new(game.player)
		if not dialog.dont_show then
			game:registerDialog(dialog)
		end
		game.player:saveUUID()

		local death_mean = nil
		if death_note and death_note.damtype then
			local dt = DamageType:get(death_note.damtype)
			if dt and dt.death_message then death_mean = rng.table(dt.death_message).." " end --@ 빈칸 추가
		end

		local top_killer = nil
		if profile.mod.deaths then
			local l = {}
			for _, names in pairs(profile.mod.deaths.sources or {}) do
				for name, nb in pairs(names) do l[name] = (l[name] or 0) + nb end
			end
			l = table.listify(l)
			if #l > 0 then
				table.sort(l, function(a,b) return a[2] > b[2] end)
				top_killer = l[1][1]
			end
		end

		local msg
		if not death_note.special_death_msg then
			msg = "%s : 레벨 %d %s %s - '%s' 의 %s 층에서, %s%s에게 %s죽었습니다. %s"
			local srcname = src.kr_name or ( src.unique and src.name or src.name:a_an() )
			local killermsg = (src.killer_message and " "..src.killer_message or ""):gsub("#sex#", game.player.female and "그녀" or "그")
			if src.name == game.player.name then
				srcname = "자기 자신" --@ 성별 차이 제거 - 원래 코드 : game.player.female and "herself" or "himself"
				killermsg = rng.table{
					"(멍청이)",
					"극도로 바보 같은 행동이었죠.",
					"절정의 굴욕감이 들겁니다.",
					"당연히 사고였겠지만요.",
					"어떤 잘못된 집착적 실험 도중이었죠.",
					"야생의 동물들에게 식량을 제공해주기 위해서 죽었습니다.",
					"(얼마나 부끄러울까)",
				}
			end
			msg = msg:format(
				(game.player.kr_name or game.player.name), game.player.level, game.player.descriptor.subrace:lower():krRace(), game.player.descriptor.subclass:lower():krClass(),
				(game.zone.kr_name or game.zone.name), game.level.level,
				src.name == top_killer and "(또 다시) " or "",
				srcname,
				death_mean or "공격받아 ",
				killermsg
			) --@ 변수 순서 조정
		else
			msg = "%s : 레벨 %d %s %s - '%s' 의 %s 층에서 %s."
			msg = msg:format(
				(game.player.kr_name or game.player.name), game.player.level, game.player.descriptor.subrace:lower():krRace(), game.player.descriptor.subclass:lower():krClass(),
				(game.zone.kr_name or game.zone.name), game.level.level,
				death_note.special_death_msg
			) --@ 변수 순서 조정
		end

		game:playSound("actions/death")
		game.delayed_death_message = "#{bold}#"..msg.."#{normal}#"
		if (not game.player.easy_mode_lifes or game.player.easy_mode_lifes <= 0) and not game.player.infinite_lifes then
			profile.chat.uc_ext:sendKillerLink(msg, src)
		end
	end
end
