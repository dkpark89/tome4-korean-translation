-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2015 Nicolas Casalini
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
	template = [[#LIGHT_GREEN#*방에 들어가니, 두 명의 거대한 오우거 막아서고 있는 것이 보입니다. 오우거들은 오랜 잠에서 깨어난 듯이 눈을 깜빡이고 있다가, 당신을 보더니 바로 말을 겁니다. 오른 쪽에 서있는 오우거가 말 하길:*#WHITE#
	너! 관등성명. 당장!
]],
	answers = {
		{"내 뭐?"},
		{"[공격한다]"},
	}
}

newChat{ id="nargol-scum",
	template = [[#LIGHT_GREEN#*방에 들어가니, 두 명의 거대한 오우거 막아서고 있는 것이 보입니다. 오우거들은 오랜 잠에서 깨어난 듯이 눈을 깜빡이고 있다가, 당신을 보더니 바로 무기를 들어올립니다.]],
	answers = {
		{"[공격한다]", action=function(npc, player) npc:doEmote("#CRIMSON#나르골의 쓰레기구나! 적의 공격이다!", 120) end},
	}
}

newChat{ id="conclave",
	template = [[#LIGHT_GREEN#*방에 들어가니, 두 명의 거대한 오우거 막아서고 있는 것이 보입니다. 오우거들은 오랜 잠에서 깨어난 듯이 눈을 깜빡이고 있다가, 당신을 보더니 바로 말을 겁니다. 오른 쪽에 서있는 오우거가 말 하길:*#WHITE#
	아! 지원병력! 도대체 내가 여기에 얼마나 있었는지는 모르지만, 아스테리드를 불러올테... 잠깐만, 나머지 녀석들은 어디있지? #LIGHT_GREEN#*그가 눈살을 찌푸립니다*#WHITE# 너 인식번호를 어떻게 되지?
]],
	answers = {
		{"기다려! 전쟁은 끝났다! 몇 천년이나 지났다고, 콘클라베는 더이상 존재하지 않아!", jump="angry-conclave"},
		{"[attack]"},
	}
}

newChat{ id="angry-conclave",
	text = [[#LIGHT_GREEN#*그들은 서로를 쳐다보더니 무기를 들어올리고 사납게 쳐다보았습니다. 왼 쪽에 있는 오우거가 으르렁 거리며:*#WHITE#
거짓말! 콘클라베는 사라질 수 없다! 네가 누군지는 몰라도 목격자를 남겨둘 수는 없다!
]],
	answers = {
		{"[공격한다]"},
	}
}

if (player.descriptor.race == "Halfling") then
	return "nargol-scum"
elseif (player:findInAllInventoriesBy('define_as', 'CONCLAVE_ROBE') and player:findInAllInventoriesBy('define_as', 'CONCLAVE_ROBE').wielded and (player.descriptor.race == "Human" or player.descriptor.subrace == "Ogre")) then
	return "conclave"
else
	return "welcome"
end
