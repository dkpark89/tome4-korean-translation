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
	desc[#desc+1] = "오래된 숲(The Old Forest)은 데르쓰(Derth) 마을의 바로 남동쪽에 있습니다."
	desc[#desc+1] = "미궁(The Maze)은 데르쓰(Derth) 마을의 서쪽에 있습니다."
	desc[#desc+1] = "지렁이 굴(The Sandworm Lair)은 데르쓰(Derth) 마을에서 서쪽으로 멀리떨어진 바다 근처에 있습니다."
	desc[#desc+1] = "다이카라(The Daikara)는 탈로레의 숲(the Thaloren forest)의 동쪽 경계선에 있습니다."
	if self:isCompleted("old-forest") then
		desc[#desc+1] = "#LIGHT_GREEN#* 당신은 오래된 숲(the Old Forest)을 탐험해 왈쓰룻(Warthroot)을 물리쳤습니다.#WHITE#"
	else
		desc[#desc+1] = "#SLATE#* 당신은 오래된 숲(the Old Forest)을 탐험해 그곳에 무슨 위험이 도사리고 있는지 밝혀내고 보물을 찾아내야 합니다!#WHITE#"
	end
	if self:isCompleted("maze") then
		desc[#desc+1] = "#LIGHT_GREEN#* 당신은 미궁(the Maze)을 탐험해 미노타우루스(the Minotaur)를 물리쳤습니다.#WHITE#"
	else
		desc[#desc+1] = "#SLATE#* 당신은 미궁(the Maze)을 탐험해 그곳에 무슨 위험이 도사리고 있는지 밝혀내고 보물을 찾아내야 합니다!#WHITE#"
	end
	if self:isCompleted("sandworm-lair") then
		desc[#desc+1] = "#LIGHT_GREEN#* 당신은 지렁이 굴(the Sandworm Lair)을 탐험해 그들의 여왕(their Queen)을 물리쳤습니다.#WHITE#"
	else
		desc[#desc+1] = "#SLATE#* 당신은 지렁이 굴(the Sandworm Lair)을 탐험해 그곳에 무슨 위험이 도사리고 있는지 밝혀내고 보물을 찾아내야 합니다!#WHITE#"
	end
	if self:isCompleted("daikara") then
		desc[#desc+1] = "#LIGHT_GREEN#* 당신은 다이카라(the Daikara)를 탐험해 용(the Dragon)을 물리쳤습니다.#WHITE#"
	else
		desc[#desc+1] = "#SLATE#* 당신은 다이카라(the Daikara)를 탐험해 그곳에 무슨 위험이 도사리고 있는지 밝혀내고 보물을 찾아내야 합니다!#WHITE#"
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
