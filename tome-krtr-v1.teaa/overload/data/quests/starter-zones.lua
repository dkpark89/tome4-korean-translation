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

-- Quest for Maze, Sandworm & Old Forest
name = "Into the darkness"
kr_display_name = "어둠속으로"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "이제 새로운 지역들을 탐험할 시간입니다. 어둡고 잊혀진 위험한 곳들입니다."
	desc[#desc+1] = "The Old Forest는 Derth 마을의 바로 남동쪽에 있습니다."
	desc[#desc+1] = "The Maze는 Derth의 서쪽에 있습니다."
	desc[#desc+1] = "The Sandworm Lair는 Derth에서 서쪽으로 멀리떨어진 바다 근처에 있습니다."
	desc[#desc+1] = "The Daikara는 the Thaloren forest의 동쪽 경계선에 있습니다."
	if self:isCompleted("old-forest") then
		desc[#desc+1] = "#LIGHT_GREEN#* 당신은 the Old Forest를 탐험해 Warthroot를 물리쳤습니다.#WHITE#"
	else
		desc[#desc+1] = "#SLATE#* 당신은 the Old Forest를 탐험해 그곳에 무슨 위험이 도사리고 있는지 밝혀내고 보물을 찾아내야 합니다!#WHITE#"
	end
	if self:isCompleted("maze") then
		desc[#desc+1] = "#LIGHT_GREEN#* 당신은 the Maze를 탐험해 the Minotaur를 물리쳤습니다.#WHITE#"
	else
		desc[#desc+1] = "#SLATE#* 당신은 the Maze를 탐험해 그곳에 무슨 위험이 도사리고 있는지 밝혀내고 보물을 찾아내야 합니다!#WHITE#"
	end
	if self:isCompleted("sandworm-lair") then
		desc[#desc+1] = "#LIGHT_GREEN#* 당신은 the Sandworm Lair를 탐험해 their Queen을 물리쳤습니다.#WHITE#"
	else
		desc[#desc+1] = "#SLATE#* 당신은 the Sandworm Lair를 탐험해 그곳에 무슨 위험이 도사리고 있는지 밝혀내고 보물을 찾아내야 합니다!#WHITE#"
	end
	if self:isCompleted("daikara") then
		desc[#desc+1] = "#LIGHT_GREEN#* 당신은 the Daikara를 탐험해 the Dragon을 물리쳤습니다.#WHITE#"
	else
		desc[#desc+1] = "#SLATE#* 당신은 the Daikara를 탐험해 그곳에 무슨 위험이 도사리고 있는지 밝혀내고 보물을 찾아내야 합니다!#WHITE#"
	end
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if sub then
		if self:isCompleted("old-forest") and self:isCompleted("maze") and self:isCompleted("sandworm-lair") and self:isCompleted("daikara") then
			who:setQuestStatus(self.id, engine.Quest.DONE)
			who:grantQuest("dreadfell")
		end
	end
end
