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

-- Quest for Maze, Sandworm & Old Forest
name = "Into the darkness"
kr_name = "어둠 속으로"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "이제 새로운 지역들을 탐험할 시간입니다. 어둡고, 잊혀진, 위험한 곳들입니다."
	desc[#desc+1] = "오래된 숲은 데르스 마을의 바로 남동쪽에 있습니다."
	desc[#desc+1] = "미궁은 데르스 마을의 서쪽에 있습니다."
	desc[#desc+1] = "지렁이 굴은 데르스 마을에서 서쪽으로 멀리 떨어진 바다 근처에 있습니다."
	desc[#desc+1] = "다이카라는 탈로레의 숲 동쪽 경계선에 있습니다."
	if self:isCompleted("old-forest") then
		if self:isCompleted("old-forest-crystal") then
			desc[#desc+1] = "#LIGHT_GREEN#* You have explored the Old Forest and vanquished Shardskin.#WHITE#" --@@ 한글화 필요
		else
			desc[#desc+1] = "#LIGHT_GREEN#* 당신은 오래된 숲을 탐험하여, 분노의 뿌리를 물리쳤습니다.#WHITE#"
		end
	else
		desc[#desc+1] = "#SLATE#* 당신은 '오래된 숲' 을 탐험해, 그곳에 무슨 위험이 도사리고 있는지 밝혀내고 보물을 찾아내야 합니다!#WHITE#"
	end
	if self:isCompleted("maze") then
		if self:isCompleted("maze-horror") then
			desc[#desc+1] = "#LIGHT_GREEN#* You have explored the Maze and vanquished the Horned Horror.#WHITE#" --@@ 한글화 필요
		else
			desc[#desc+1] = "#LIGHT_GREEN#* 당신은 미궁을 탐험하여, 미노타우루스를 물리쳤습니다.#WHITE#"
		end
	else
		desc[#desc+1] = "#SLATE#* 당신은 '미궁' 을 탐험해, 그곳에 무슨 위험이 도사리고 있는지 밝혀내고 보물을 찾아내야 합니다!#WHITE#"
	end
	if self:isCompleted("sandworm-lair") then
		desc[#desc+1] = "#LIGHT_GREEN#* 당신은 지렁이 굴을 탐험하여, 그들의 여왕을 물리쳤습니다.#WHITE#"
	else
		desc[#desc+1] = "#SLATE#* 당신은 '지렁이 굴' 을 탐험해, 그곳에 무슨 위험이 도사리고 있는지 밝혀내고 보물을 찾아내야 합니다!#WHITE#"
	end
	if self:isCompleted("daikara") then
		if self:isCompleted("daikara-volcano") then
			desc[#desc+1] = "#LIGHT_GREEN#* You have explored the Daikara and vanquished the huge fire dragon that dwelled there.#WHITE#" --@@ 한글화 필요
		else
			desc[#desc+1] = "#LIGHT_GREEN#* You have explored the Daikara and vanquished the huge ice dragon that dwelled there.#WHITE#" --@@ 한글화 필요
		end
	else
		desc[#desc+1] = "#SLATE#* 당신은 '다이카라' 를 탐험해, 그곳에 무슨 위험이 도사리고 있는지 밝혀내고 보물을 찾아내야 합니다!#WHITE#"
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
