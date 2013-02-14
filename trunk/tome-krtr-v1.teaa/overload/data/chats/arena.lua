﻿-- ToME - Tales of Maj'Eyal
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

local entershop = function (self, player)
	local arenashop = game:getStore("ARENA_SHOP")
	arenashop:loadup(game.level, game.zone)
	arenashop:interact(player, "Gladiator's wares")
	arenashop = nil
end

newChat{ id="ryal-entry",
text = [[#LIGHT_GREEN#*A gigantic bone giant walks through the main gate.
#LIGHT_GREEN#Its shape is intricate and sharp, resembling a drake, but with countless
#LIGHT_GREEN#spikes instead of wings.
#LIGHT_GREEN#The massive undead stares at you with unusual...intellect.
#LIGHT_GREEN#You have heard of him. Ryal the Towering, your first obstacle!
#LIGHT_GREEN#As an eerie blue glow fills where its eyes should be, the undead giant
#LIGHT_GREEN#roars and multiple bones fly in your general direction!*
]],
	answers = {
		{"전방 경계!!"},
	}
}

newChat{ id="ryal-defeat",
text = [[#LIGHT_GREEN#*After taking several hits, the undead giant finally succumbs
#LIGHT_GREEN#to your attacks*
#LIGHT_GREEN#Suddenly, Ryal's body starts to regenerate!
#LIGHT_GREEN#Standing tall again, you can almost feel its emotionless skull staring
#LIGHT_GREEN#at you with...satisfaction.
#WHITE#Hehehe...well done, @playerdescriptor.race@.
#LIGHT_GREEN#*Ryal quietly turns towards the gate and leaves, seemingly unharmed*
]],
	answers = {
		{"재미있었어, 해골 거인!", action=entershop},
		{"...뭐야? 무사하다고?", action=entershop}
	}
}

newChat{ id="fryjia-entry",
text = [[#LIGHT_GREEN#*The wind chills as a young girl walks calmly through the gate.
#LIGHT_GREEN#She looks surprisingly young, with extremely pale skin and contrasting
#LIGHT_GREEN#long black hair. She examines you with eerie calmness*#WHITE#
I am known as Fryjia the Hailstorm. That's all you need to know, @playerdescriptor.race@. Let us begin.
#LIGHT_GREEN#*The whole arena starts to get colder as she speaks, and the audience
#LIGHT_GREEN#starts wearing their finest winter cloaks*]],
	answers = {
		{"자 와라!"},
	}
}

newChat{ id="fryjia-defeat",
text = [[#LIGHT_GREEN#*With your final blow, Fryjia falls, unable to continue*
#LIGHT_GREEN#*She awkwardly stands up, but doesn't seem critically injured*
#WHITE# I...I admit defeat.
#LIGHT_GREEN#*The audience "oooohs" in awe. Fryjia has turned her back to you*
#WHITE# @playerdescriptor.race@. You are not the person I am looking for...
#LIGHT_GREEN#*Leaving you wondering what she was talking about, the young girl walks
#LIGHT_GREEN#towards the gate. As it closes, you realize her eyes are wet with tears.
]],
	answers = {
		{"...", action=entershop},
		{"므... 뭐야 지금의 그건?", action=entershop}
	}
}

newChat{ id="riala-entry",
text = [[#LIGHT_GREEN#*The gate opens, revealing a mature human woman in crimson robes.
#LIGHT_GREEN#She looks at you with a wide smile*
#WHITE# My, my, what a fine @playerdescriptor.race@ you are. What was your name again, @playername@? I am soo delighted to be your rival today.
#LIGHT_GREEN#*She speaks quietly as if telling a secret* #WHITE#You know, so few get past the little one as of late, it's such a bore.#LIGHT_GREEN#*She giggles*#WHITE#
So! I am Reala, the Crimson. I came directly from Angolwen. Despite, you know, the whole thing with the Spellblaze, people still enjoy a few magic tricks!
#LIGHT_GREEN#*She snaps her fingers, and then flames start dancing around her!*#WHITE#
Fryjia told me about you, the poor thing, so I will not underestimate such a promising aspirant #LIGHT_GREEN#*She smiles warmly* #WHITE#So, let's make haste my dear!
There is a battle to fight here!]],
	answers = {
		{"자, 간다!"},
	}
}

newChat{ id="riala-defeat",
text = [[#LIGHT_GREEN#*With the final blow, Reala falls...to suddenly burst in flames!!
#LIGHT_GREEN#You stare at the blazing inferno with understandable confusion,
#LIGHT_GREEN#until you hear her voice from behind*#WHITE#
Oh, my dear! That was quite the fight, wasn't it? I concede you the honor of victory.
#LIGHT_GREEN#*She bows politely*
Fryjia was right about you: you seem to be a champion in the works!
Oh, and please forgive her behavior. You will understand when you meet her father.
And, if you keep fighting like this, it will be really soon.
So, it's been my pleasure, @playername@. #LIGHT_GREEN#*She vanishes in a spiral of flame*]],
	answers = {
		{"I am pumped up! 다음은 뭐냐?", action=entershop},
		{"Am I the only person with a name that can die here?", action=entershop}
	}
}

newChat{ id="valfren-entry",
text = [[#LIGHT_GREEN#*You suddenly realize everything has turned dark.
#LIGHT_GREEN#You look around searching for your rival. And then you notice it. Standing
#LIGHT_GREEN#right before you, a massive battle armor with an equally massive battle axe.
#LIGHT_GREEN#It wasn't there just a second ago. You step back and examine him better,
#LIGHT_GREEN#realizing it's actually a human inside that hulking, worn armor. You can't see
#LIGHT_GREEN#his eyes, but you know he's piercing your soul with his stare*
f...t...ma....ll...
#LIGHT_GREEN#*You hear a devilish voice, coming from everywhere at once!! But...you are
#LIGHT_GREEN#unable to understand anything! It doesn't seem like any language used in
#LIGHT_GREEN#Maj'Eyal!
#LIGHT_GREEN#And then...a piercing, demonic roar...you are overwhelmed by extreme
#LIGHT_GREEN#emotions invading your very soul!!*
]],
	answers = {
		{"#LIGHT_GREEN#*어둠에 맞서 당당히 일어난다.*"},
	}
}

newChat{ id="valfren-defeat",
text = [[#LIGHT_GREEN#*You valiantly deliver the finishing blow!*
#LIGHT_GREEN#*Valfren collapses as the light returns to this world.
#LIGHT_GREEN#You close your eyes for a brief instant. Fryjia is there when you open them*
Father... #LIGHT_GREEN#*She stands silent for a few seconds*#WHITE# You win, @playerdescriptor.race@.
You have done well. Prepare for your final battle... if you win, we will be at your service.
Good luck...
#LIGHT_GREEN#*After a few uncomfortable seconds, Valfren starts to move again.
#LIGHT_GREEN#He stands up and walks away with Fryjia. At the gates, Valfren turns his
#LIGHT_GREEN#head in your direction. You look at him, and then he looks above
#LIGHT_GREEN#the arena's walls. You follow his gaze... to meet the Master of the Arena*

#LIGHT_GREEN#*There it is. Your goal. Your heart beats fast, as the time has come*
#LIGHT_GREEN#*The Master of the Arena smiles proudly*
#RED#The final battle begins when the gate closes, just this final time!!
]],
	answers = {
		{"내가 널 쓰러뜨리겠다, Master of the Arena!!!", action=entershop},
		{"I will become Master of the Arena instead of the Master of the Arena!!", action=entershop},
		{"부와 영광을! 부와 영광을!", action=entershop},
	}
}

newChat{ id="master-entry",
text = [[#LIGHT_GREEN#*Finally, the master of the arena comes into the gates!
#LIGHT_GREEN#The public roars with excitement as he faces you with confidence!*
I applaud you, @playerdescriptor.race@! You have fought with might and courage!
And now...the time for the final showdown!
#LIGHT_GREEN#*The master assumes a fighting stance. The audience cheers!*
Like you, I started from nowhere. I won't underestimate someone with such potential.
#LIGHT_GREEN#*The master smirks, you assume your fighting stance as well, and the
#LIGHT_GREEN#audience cheers you as well, making the excitement grow inside you*
Can you hear it, the public cheering? That's what this is about.
Pursue glory with all your might, @playerdescriptor.race@!!
#LIGHT_GREEN#*The master steps forward into the sand*
]],
	answers = {
		{"부와 영광을!!!"},
	}
}

newChat{ id="master-defeat",
text = [[#LIGHT_GREEN#*영광스러운 전투의 이후, 승리자가 쓰러졌습니다!*
아...하하. 네가 해냈구나, @playerdescriptor.race@...
#LIGHT_GREEN#*아레나의 승리자가, 비록 패배했지만, 밝은 미소를 지으며 일어납니다.
#LIGHT_GREEN#승리자의 허락이 떨어짐을 느끼며, 당신은 무기를 집어들고, 이젠 피로 물든
#LIGHT_GREEN#모래 위에 쓰러집니다.*
모두들! 오늘 우승자가 나왔습니다!!
#LIGHT_GREEN#*관중들은 환호하며 당신의 이름을 계속해서 외칩니다*
축하한다, @playerdescriptor.race@. 너는 이제 승리자가 됐다..
이제부터 너는 우승자로써 너만의 공정한 자리를 차지하게 되겠지..
이것만 기억해...나처럼, 너도 언젠가는 쓰러지게 된다...
하지만 그때까진, 여긴 네 꺼야! 파라다이스에 온 걸 환영한다, @playerdescriptor.race@!
#LIGHT_GREEN#*당신은 여러 스폰서와 그리고 군의 스카우터들이 당신이 쓰러뜨린
#LIGHT_GREEN#마스터에게 다가와서, 여러가지 거래와 그리고 군에서의 좋은 자리를 제안하는 걸 봅니다.
#LIGHT_GREEN#당신은 미소짓습니다, 인생의 승리자로써, 이제부턴 당신 자신의 인생도 영광스럽다는 걸 알고 있으니까요.
#LIGHT_GREEN#왜냐하면 만약 당신이 미래에 패배하게 된다고 해도...
#LIGHT_GREEN#당신은 언제나 당신의 이미지를 팔며 융성하게 지낼 수 있기 떄문입니다.

#YELLOW#축하합니다!
#YELLOW#당신은 이제 아레나의 승리자가 되었습니다! 당신은 위대하고 매우 멋집니다!
#YELLOW#당신은 다른 자가 당신에게 도전하기 전까지는 계속 승리자로 남을 것입니다!
#YELLOW#다음에 플레이 하실 땐, 당신은 이 새로운 승리자와 싸우게 될 것입니다!
]],
	answers = {
		{"돈과!! 그리고!! 영광을!!", action=function(npc, player) player:hasQuest("arena"):win() end},
		{"이제부턴 광신도들에게서 여자들을 구하지 않아도 돼!", cond=function(npc, player) if player.female == true then return false else return true end end, action=function(npc, player) player:hasQuest("arena"):win() end},
		{"나는 이 승리에 의해, 아레나의 승리자로써 미래의 도전자들을 기다릴 것이다!", action=function(npc, player) player:hasQuest("arena"):win() end},
		{"#LIGHT_GREEN#*춤을 춘다*", action=function(npc, player) player:hasQuest("arena"):win() end},
	}
}