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

name = "In the void, no one can hear you scream"
kr_name = "공허 속에서, 아무도 당신의 비명을 듣지 못하네"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "당신은 주술사들을 물리쳤습니다. 하지만 슬프게도 공허의 관문은 여전히 열려있으며, 창조자가 곧 강림하게 됩니다."
	desc[#desc+1] = "절대로 창조자를 강림시켜서는 안됩니다. 수천 년 동안 별들 사이의 공허에 갇혀있었던 창조자 게를릭은, 분명 분노로 미쳐버린 상태일 것이기 때문입니다."
	desc[#desc+1] = "당신은 쉐르'툴 종족이 시작했던 일을 끝낼 필요가 있습니다. 흡수의 지팡이를 들고, 스스로 '신 살해자'가 되십시오."
	return table.concat(desc, "\n")
end
