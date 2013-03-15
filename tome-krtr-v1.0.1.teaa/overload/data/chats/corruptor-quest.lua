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

newChat{ id="welcome",
	text = [[잠깐, @playerdescriptor.subclass@!
그대가 상당히 가치 있는 상대이며, 강력하다는 것은 잘 알았네. 나는 네 몸에서 나오는 신비한 힘을 보고, 느낄 수 있다네.
우리는 결국 같은 자들이야.]],
	answers = {
		{"'같다' 니, 무슨 뜻이지?", jump="quest"},
		{"나는 너와는 다르다. 죽어라!", quick_reply="그렇다면, 죽어라! 그리고 네 힘을 나에게 바쳐라!"},
	}
}

newChat{ id="quest",
	text = [[우리는 모두 마법의 힘을 알고 있다네. 우리는 모두 힘에 목말라 있지. 나는 수많은 것들을 발견했다네. 네게 가르쳐줄 것 또한 너무나 많지.
이곳은 특별한 곳일세. 마법폭발에 의해 영원히 폐허로 남게 될 이곳에서는, 현실의 장막이 엷어지지. 우리는 이곳에서 이득을 보고 있다네. 우리는 이곳의 힘을 끌어내고, 이곳의 힘을 우리 것으로 만들지, 
이를 통해 우리 자신을 더 강하게 만들고, 모든 것들을 우리의 발 아래에 꿇릴 수 있게 될거라네!]],
	answers = {
		{"이 세계는 이미 마법폭발로 인해 충분한 고통을 받았다. 마법은 사람을 위한 용도로 써야지, 그들을 복종시키는 용도로 쓰면 안 된다. 네 말은 더 이상 듣지 않겠다!", quick_reply="그렇다면, 죽어라! 그리고 네 힘을 나에게 바쳐라!"},
		{"그렇다면, 네 목적은 뭐지?", jump="quest2"},
	}
}

newChat{ id="quest2",
	text = [[이 싸움을 그만두고, 나를 풀어주게. 혹시 '지구르 추종자' 라는 사람들을 들어본 적이 있나?
이 정신 나간 놈들은 마법이 존재해서는 안된다고 생각하네! 그들은 우리를 두려워하네. 그들은 우리의 힘을 두려워하네.
힘을 합쳐 그 멍청한 놈들을 박살내세!]],
	answers = {
		{"마법은 승리할 것이다!", jump="quest3", action=function(npc, player)
			if npc:isTalentActive(npc.T_DEMON_PLANE) then npc:forceUseTalent(npc.T_DEMON_PLANE, {ignore_energy=true}) end
			if player:isTalentActive(player.T_DEMON_PLANE) then player:forceUseTalent(player.T_DEMON_PLANE, {ignore_energy=true}) end
			if player:hasEffect(player.EFF_DREAMSCAPE) then player:removeEffect(player.EFF_DREAMSCAPE, true) end
		end},
		{"마법 역시 존재하는 이유가 있을 것이다. 분명 그들은 틀렸지만, 너는 훨씬 더 악질이로군.", quick_reply="그렇다면... 이 세계에서 사라져라! 죽어라!"},
	}
}

newChat{ id="quest3",
	text = [[좋아. 준비가 되지 않았을지도 모르지만, 우리는 이미 지구르 추종자들이 모인 곳의 공격 준비를 마쳤네. 새쉬 해 남쪽 해안가에 있는 곳이지.
우리와 함께 그들을 파괴하세!
지구르로 관문을 열겠네. 학살을 시작하지!]],
	answers = {
		{"좋아, 준비 됐어!", action=function(npc, player)
			if game.zone.short_name ~= "mark-spellblaze" then return "quest3" end
			npc.invulnerable = 1
			player:grantQuest("anti-antimagic")
		end},
	}
}

return "welcome"
