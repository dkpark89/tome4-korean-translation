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

require "engine.krtrUtils" --@@
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
		src = src or {name="unknown"}
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
			if dt and dt.death_message then death_mean = rng.table(dt.death_message) end
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
			msg = "%s 레벨 %d %s %s - %s%s의 %s%s 죽음 : %s 지역의 %s 층."
			local srcname = src.kr_display_name or src.name --@@
			local killermsg = (src.killer_message and src.killer_message:addJosa("와").." " or ""):gsub("#sex#", "스스로의") --@@
			if src.name == game.player.name then
				srcname = "스스로" --@@
				killermsg = rng.table{
					"(멍청한) ",
					"극단적으로 무능한 행동으로 ",
					"극도의 굴욕을 넘어 ",
					"우연한 ",
					"어떤 종류의 집착적인 엇나간 실험에서 ",
					"야생으로 공짜 고기를 제공하기 위한 ",
					"(당황스러운) ",
				}
			end
			msg = msg:format(
				game.player.name, game.player.level, game.player.descriptor.subrace:lower():krRace(), game.player.descriptor.subclass:lower():krClass(), --@@
				src.name == top_killer and "(또다시) " or "", --@@
				srcname,
				killermsg, --@@
				(death_mean or "학대"):addJosa("로"), --@@
				(game.zone.kr_display_name or game.zone.name), game.level.level --@@ 
			)
		else
			msg = "%s 레벨 %d %s %s - %s : %s 지역의 %s 층."
			msg = msg:format(
				game.player.name, game.player.level, game.player.descriptor.subrace:lower():krRace(), game.player.descriptor.subclass:lower():krClass(), --@@
				death_note.special_death_msg,
				(game.zone.kr_display_name or game.zone.name), game.level.level --@@
			)
		end

		game:playSound("actions/death")
		game.delayed_death_message = "#{bold}#"..msg.."#{normal}#"
		if (not game.player.easy_mode_lifes or game.player.easy_mode_lifes <= 0) and not game.player.infinite_lifes then
			profile.chat.uc_ext:sendKillerLink(msg, src)
		end
	end
end
