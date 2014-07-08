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

newAI("summoned", function(self)
	-- Run out of time ?
	if self.summon_time then
		self.summon_time = self.summon_time - 1
		if self.summon_time <= 0 then
			if not self.summon_quiet then
				game.logPlayer(self.summoner, "#PINK#당신의 소환수 %s 사라집니다.", (self.kr_name or self.name):addJosa("가"))
			end
			self:die()
		end
	end

	if self:runAI(self.ai_state.ai_target or "target_simple") then
		return self:runAI(self.ai_real)
	end
end)
