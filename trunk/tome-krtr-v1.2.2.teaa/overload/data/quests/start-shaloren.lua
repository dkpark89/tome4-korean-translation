﻿-- ToME - Tales of Maj'Eyal
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
name = "Echoes of the Spellblaze"
kr_name = "마법폭발의 영향"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "당신은 번뜩이는 동굴 안에, 마법폭발의 기운이 깃든 기이한 수정들이 있다는 이야기를 들었습니다.\n"
	desc[#desc+1] = "그리고 서쪽에는 샬로레들의 방침에 반기를 든, 샬로레 이탈자들의 야영지가 있다는 소문이 돌고 있습니다.\n"
	if self:isCompleted("spellblaze") then
		desc[#desc+1] = "#LIGHT_GREEN#* 당신은 번뜩이는 동굴을 탐험하여, 마법폭발의 수정을 파괴했습니다.#WHITE#"
	else
		desc[#desc+1] = "#SLATE#* 당신은 '번뜩이는 동굴' 을 탐험해야 합니다.#WHITE#"
	end
	if self:isCompleted("rhaloren") then
		desc[#desc+1] = "#LIGHT_GREEN#* 당신은 랄로레 아영지를 탐험하여, 랄로레 심문관을 죽였습니다.#WHITE#"
	else
		desc[#desc+1] = "#SLATE#* 당신은 '샬로레 이탈자들의 야영지' 를 탐험해야 합니다.#WHITE#"
	end
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if sub then
		if self:isCompleted("spellblaze") and self:isCompleted("rhaloren") then
			who:setQuestStatus(self.id, engine.Quest.DONE)
			who:grantQuest("starter-zones")
		end
	end
end
