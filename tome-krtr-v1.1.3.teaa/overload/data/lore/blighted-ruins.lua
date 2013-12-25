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

require "engine.krtrUtils"

--------------------------------------------------------------------------
-- Blighted Ruins
--------------------------------------------------------------------------
newLore{
	id = "blighted-ruins-note-1",
	category = "blighted ruins",
	name = "note from the Necromancer",
	kr_name = "사령술사의 쪽지",
	lore = [[나의 영광스러운 계획의 일정이 지연되고 있다. 날 불쾌하게 하는군. 근처 마을의 멍청이들이 내 존재를 의심하기 시작했고, 무덤과 묘지를 엄중하게 경비하기 시작했다. 이제 내가 훔쳐낼 수 있는 것들은 모두 빈약하고, 내 계획에 사용하기엔 너무 심하게 부패하거나 변변찮은 것들 뿐이다. 어쩔 수 없이 그것들을 사용해서 수준 미달의 아랫것들을 만드는 수밖에. 어쩌면 이것들을 사용해서 충분한 갈등이나 마찰을 심어줄 수 있을거야. 그러면 신선한 시체를 사용할 수 있겠지...]],
}

newLore{
	id = "blighted-ruins-note-2",
	category = "blighted ruins",
	name = "note from the Necromancer",
	kr_name = "사령술사의 쪽지",
	lore = [[기만의 망토가 완성되었다! 진정한 나의 걸작이야. 물론 내 위대한 계획에 비할 바는 안되지만, 이걸로 아랫것들이 전혀 의심받지 않은 채로 살아있는 것들 사이를 걸어다닐 수 있게 되었다. 이미 망토를 입힌 구울 노예를 근처 마을에 산책시켰지... 하! 멍청이들은 눈길 한번 안주더군! 이 망토만 있으면 내 계획을 위한 재료들을 모으는 것이 한층 더 간단해질거야.]],
}

newLore{
	id = "blighted-ruins-note-3",
	category = "blighted ruins",
	name = "note from the Necromancer",
	kr_name = "사령술사의 쪽지",
	lore = function() return [[운명이 나에게 미소짓는군. 오늘은 불행한 ]]..(game:getPlayer(true).descriptor.subclass):krClass()..[[의 시체를 찾았다. 실로 불행하게 죽은 시체지만, 내게는 더 없는 행운이야. 시체에 부패의 흔적이 전혀 보이지 않아...이 시체라면 완벽할거야! 이 부하와 기만의 망토라면 내 계획의 복잡함은 모두 해소될거야. 의식을 준비해야겠어...  내 어둠의 자식들에게 새로운 친구가 곧 생길거야.]] end,
}

newLore{
	id = "blighted-ruins-note-4",
	category = "blighted ruins",
	name = "note from the Necromancer",
	kr_name = "사령술사의 쪽지",
	lore = [[나의 걸작이 움직였다! 정말 영광스럽고, 아름답구나. 아직 완성되지 않았지만, 나의 보금자리를 지키는 역할을 수행하기엔 충분해. 영웅이 되고자 하는 것들은 내 피조물을 이길 수 없을거다. 완성되기만 한다면 거의 무적일테니! 이제 남은건 나의 새로운 부하들을 일으키고 나의 의지에 따르게 하는 것 뿐이다... 그러면 그들은 깨달을 것이다. 모두가 깨달을 수 있을 것이다. 누가 감히 나를 막을 수 있겠는가? 감히 나를!!]],
}
