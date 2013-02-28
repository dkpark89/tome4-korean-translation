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

name = "The Arena"
kr_display_name = "투기장"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "부와 명예, 그리고 위대한 전투를 위해 당신은 투기장에 도전장을 내밀었습니다!"
	desc[#desc+1] = "과연 당신은 모든 적들을 물리치고 투기장의 지배자가 될 수 있을까요?"
	return table.concat(desc, "\n")
end

function win(self)
	game:playAndStopMusic("Lords of the Sky.ogg")

	game.player.winner = "arena"
	game:registerDialog(require("engine.dialogs.ShowText").new("Winner", "win", {playername=game.player.name, how="arena"}, game.w * 0.6))
end

function onWin(self, who)
	local desc = {}

	desc[#desc+1] = "#GOLD#잘하셨습니다! 당신은 '투기장 : 최강자가 되기 위한 도전'에서 승리하셨습니다!#WHITE#"
	desc[#desc+1] = ""
	desc[#desc+1] = "당신은 투기장에서 마주친 모든 적과 용맹하게 싸워, 승리를 쟁취했습니다!"
	desc[#desc+1] = "당신은 이제 영광스러운 투기장의 새로운 지배자이며, 다음 캐릭터는 당신을 꺾기 위해 투기장에 들어오게 될 것입니다."
	return 0, desc
end
