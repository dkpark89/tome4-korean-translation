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

local has_rod = function(npc, player) return player:findInAllInventoriesBy("define_as", "ROD_OF_RECALL") end
local q = game.player:hasQuest("shertul-fortress")
local ql = game.player:hasQuest("love-melinda")
local set = function(what) return function(npc, player) q:setStatus(q.COMPLETED, "chat-"..what) end end
local isNotSet = function(what) return function(npc, player) return not q:isCompleted("chat-"..what) end end

newChat{ id="welcome",
	text = [[*#LIGHT_GREEN#그 생명체가 천천히 당신에게 다가옵니다. 당신의 머리에 끔찍한 음성이 직접적으로 들려옵니다.#WHITE#*
어서오십시오, 주인님.]],
	answers = {
		{"너는 무엇이고, 이곳은 어디인가?", jump="what", cond=isNotSet"what", action=set"what"},
		{"주인님? 나는 네 주인님이 아니...", jump="master", cond=isNotSet"master", action=set"master"},
		{"어떻게 내가 네 말을 이해할 수 있는거지? 여기 있는 글씨들은 읽을 수 없는데 말이야.", jump="understand", cond=isNotSet"understand", action=set"understand"},
		{"나는 이곳에서 무엇을 할 수 있지?", jump="storage", cond=isNotSet"storage", action=set"storage"},
		{"이곳에는 또 어떤 기능이 있지?", jump="energy", cond=isNotSet"energy", action=set"energy"},
		{"내 기만의 망토를 강화해줄 수 있겠나? 망토를 걸치지 않아도 살아있는 존재로 보일 수 있게 말이야.", jump="permanent-cloak", 
			cond=function(npc, player)
				local cloak = player:findInAllInventoriesBy("define_as", "CLOAK_DECEPTION")
				return not q:isCompleted("permanent-cloak") and q:isCompleted("transmo-chest") and cloak
		end},
		{"네가 나를 불러서 왔다. 장거리 관문 때문이라고 했나?", jump="farportal", cond=function() return q:isCompleted("farportal") and not q:isCompleted("farportal-spawn") end},
		{"네가 나를 불러서 왔다. 되돌림의 장대 때문이라고 했나?", jump="recall", cond=function() return q:isCompleted("recall") and not q:isCompleted("recall-done") end},
		{"내 변환 상자가 자동적으로 보석을 추출해낼 수 있게 해줄 수 있나?", jump="transmo-gems", cond=function(npc, player) return not q:isCompleted("transmo-chest-extract-gems") and q:isCompleted("transmo-chest") and player:knowTalent(player.T_EXTRACT_GEMS) end},
		{"여기 연습을 위한 시설이 있나?", jump="training", cond=function() return not q:isCompleted("training") end},
		{"네 생김새를 보고 있자니 심기가 불편하군 그래. 외모를 바꿀 수 있겠나?", jump="changetile", cond=function() return q:isCompleted("recall-done") end},
		{"내가 우연히 정말 기묘한 일을 겪었어. #LIGHT_GREEN#[멜린다에 대한 이야기를 한다]", jump="cure-melinda", cond=function() return ql and ql:isStatus(engine.Quest.COMPLETED, "saved-beach") and not ql:isStatus(engine.Quest.FAILED) and not ql:isStatus(engine.Quest.COMPLETED, "can_come_fortress") end},
		{"[떠난다]"},
	}
}

newChat{ id="master",
	text = [[*#LIGHT_GREEN#그 생명체가 당신을 흘끗 봅니다.#WHITE#*
당신은 제어의 장대를 가지고 있습니다. 당신은 제 주인님입니다.]],
	answers = {
		{"으음... 알았어.", jump="welcome"},
	}
}
newChat{ id="understand",
	text = [[*#LIGHT_GREEN#그 생명체가 당신을 흘끗 봅니다.#WHITE#*
당신은 주인님입니다. 당신은 제어의 장대를 가지고 있습니다. 저는 주인님에게 말을 하기 위해 만들어졌습니다.]],
	answers = {
		{"으음... 알았어.", jump="welcome"},
	}
}

newChat{ id="what",
	text = [[*#LIGHT_GREEN#그 생명체가 당신을 진지하게 노려봅니다. 당신의 머리 속에서 갑자기 다양한 장면들이 '보이기' 시작합니다.
당신은 이제는 잊혀진 시대에 일어났던 대규모의 전쟁을 보고 있습니다. 당신은 마치 그림자와도 같은, 아마 쉐르'툴 종족으로 이루어졌다고 생각되는 군대를 보고 있습니다.
그들은 무기, 마법, 기타 다양한 것들을 사용하여 전투를 하였습니다. 그들은 신과 싸웠습니다. 그들은 신들을 사냥했습니다. 신들을 죽이거나 추방시켰습니다.
당신은 지금 당신이 있는 곳과도 같은 거대한 요새들을 보았습니다. 에이알 세계의 하늘을 떠다니는... 그것들은 마치 어린 태양처럼, 강렬한 힘으로 빛나고 있습니다.
당신은 신들이 패배하는 것을 보았습니다. 패배하고 죽는 것을 보았습니다. 단 하나를 제외하고...
그리고 당신은 어둠을 보았습니다. 아마 이 그림자도 이후에 어떤 일이 벌어졌는지는 모르는 것 같습니다.

당신은 머리를 흔들었고, 그러자 머리 속에 떠오르던 장면들도 흩어졌습니다. 천천히 당신의 원래 시야가 돌아왔습니다.
#WHITE#*
]],
	answers = {
		{"그들이 쉐르'툴 종족이였나? 그들은 신들과 싸웠다는건가?!", jump="godslayers"},
	}
}

newChat{ id="godslayers",
	text = [[그랬습니다. 그들은 전쟁을 위해 끔찍한 무기들을 만들었습니다. 그들은 이겼습니다.]],
	answers = {
		{"그 전쟁에서 이겼다면, 이제 그들은 어디에 있는거지?", jump="where"},
	}
}

newChat{ id="where",
	text = [[그들은 사라졌습니다. 그 이상은 말할 수 없습니다.]],
	answers = {
		{"하지만 나는 네 주인이라고!", jump="where"},
		{"알았어.", jump="welcome"},
	}
}

newChat{ id="storage",
	text = [[*#LIGHT_GREEN#그 생명체가 당신을 흘끗 봅니다.#WHITE#*
당신은 주인님입니다. 당신은 이 공간을 자유롭게 사용할 수 있습니다. 하지만, 대부분의 동력이 끊겨 몇 개의 방만 사용할 수 있는 상태입니다.
남쪽에 가면 창고를 발견할 수 있을 것입니다.]],
	answers = {
		{"그래, 고마워.", jump="welcome"},
	}
}

newChat{ id="energy",
	text = [[이 요새는 신을 사냥하기 위한 이동요새입니다. 물론 날아다닐 수도 있습니다.
또한 다양한 기능들이 탑재되어 있습니다. 탐험용 장거리 관문, 긴급 봉쇄 장막, 원거리 저장소, ...
하지만, 이 요새는 심각한 피해를 입었고 작동을 멈춘지 너무 오래 되었습니다. 요새의 동력이 거의 사라진 상태입니다.
이 변환 상자를 받으십시오. 이 상자는 요새와 연결된 장거리 관문이 영구적으로 작동합니다. 이 안에 들어간 물건들은 자연적으로 동력 중심부로 이동되며, 물건을 분해하여 에너지를 만들어냅니다.
이 과정에서 불필요한 부산물로 금속이 만들어집니다. '금' 이라고 불리는 금속으로, 요새에는 필요 없는 물질이기 때문에 당신에게 되돌아가게 됩니다.]],
	answers = {
		{"그러지, 고마워.", jump="welcome", action=function() q:spawn_transmo_chest() end, cond=function(npc, player) return not player:attr("has_transmo") end},
		{"여행중에 그런 상자를 발견했는데. 이걸 사용해도 되나?", jump="alreadychest", action=function() q:setStatus(q.COMPLETED, "transmo-chest") end, cond=function(npc, player) return player:attr("has_transmo") end},
	}
}

newChat{ id="alreadychest",
	text = [[물론, 가능합니다. 상자와 이 요새를 연결시켜 두겠습니다.
완료되었습니다.]],
	answers = {
		{"고마워.", jump="welcome"},
	}
}

newChat{ id="farportal",
	text = [[오래 전, 쉐르'툴 종족은 장거리 관문을 이미 알고 있는 곳으로 이동할 때 사용하는 것은 물론, 세계의 새로운 곳을 탐험하기 위해 쓰기도 하였습니다. 관문을 통해 나온 장소는 다른 세계일 때도 있었지요.
이 요새는 하나의 장거리 관문이 설치되어 있습니다. 그리고 이제 한 번의 사용이 가능할 만큼 에너지가 마련됐습니다. 장거리 관문은 사용할 때마다 에너지를 30 소모해서 우주의 무작위한 곳으로 당신을 이동시킵니다.
귀환용 관문이 상당히 멀리 떨어진 곳에 생길 수도 있으니, 조심해야 합니다. 이 경우 귀환용 관문은 직접 찾아야 합니다. 되돌림의 장대를 사용해서 긴급 귀환을 할 수도 있지만, 이 경우 높은 확률로 장거리 관문이 파괴되어 다시는 사용할 수 없게 됩니다.
이제 장거리 관문을 사용할 수 있지만, 조심하십시오. 장거리 관문이 설치된 곳에서 수상한 존재가 감지되었습니다.]],
	answers = {
		{"한번 확인해보는게 좋을 것 같군. 고마워.", action=function() q:spawn_farportal_guardian() end},
	}
}

newChat{ id="recall",
	text = [[이 되돌림의 장대는 쉐르'툴 시대의 물건은 아니지만, 기본적으로 쉐르'툴 종족들이 사용하던 구조를 따르고 있습니다.
이제 요새에 충분한 에너지가 모여, 되돌림의 장대를 사용하면 요새로 귀환할 수 있게 만들 수 있습니다.]],
	answers = {
		{"지금 방식이 더 마음에 드는군. 어쨌든 고마워."},
		{"꽤 유용하겠는걸. 그렇게 해줘.", action=function() q:upgrade_rod() end},
	}
}

newChat{ id="training",
	text = [[예 주인님, 연습용 시설은 북쪽에서 이용할 수 있습니다. 하지만 아직 기동되지 않고 있습니다.
그 것을 사용하기 위해서는 에너지가 50 만큼 필요합니다.]], --@@ 한글화 필요 : 145~149
	answers = {
		{"다음에 하도록 하지."},
		{"꽤 유용하겠는걸. 그렇게 해줘.", cond=function() return q.shertul_energy >= 50 end, action=function() q:open_training() end},
	}
}

newChat{ id="transmo-gems",
	text = [[아, 물론입니다. 연금술의 기초를 완전히 숙달하신 것 같군요. 상자가 자동적으로 당신의 힘을 사용하여, 자동적으로 보석으로 변환시키도록 하겠습니다. 보석으로 변환시키는 것이 더 많은 에너지를 만들어낼 수 있을 경우에만요.
하지만, 이를 위해서는 에너지가 25 만큼 필요합니다.]],
	answers = {
		{"다음에 하도록 하지."},
		{"꽤 유용하겠는걸. 그렇게 해줘.", cond=function() return q.shertul_energy >= 25 end, action=function() q:upgrade_transmo_gems() end},
	}
}

newChat{ id="changetile",
	text = [[요새의 홀로그램 발생기를 통해, 취향에 맞는 형상으로 외모를 변경할 수 있습니다. 하지만 이를 위해서는 에너지가 60 만큼 필요합니다.]],
	answers = {
		{"인간 여성의 외모로 부탁할게.", cond=function() return q.shertul_energy >= 60 end, action=function(npc, player)
			q.shertul_energy = q.shertul_energy - 60
			npc.replace_display = mod.class.Actor.new{
				add_mos={{image = "npc/humanoid_female_sluttymaid.png", display_y=-1, display_h=2}},
--				shader = "shadow_simulacrum",
--				shader_args = { color = {0.2, 0.1, 0.8}, base = 0.5, time_factor = 500 },
			}
			npc:removeAllMOs()
			game.level.map:updateMap(npc.x, npc.y)
			game.level.map:particleEmitter(npc.x, npc.y, 1, "demon_teleport")
		end},
		{"인간 남성의 외모로 부탁할게.", cond=function() return q.shertul_energy >= 60 end, action=function(npc, player)
			q.shertul_energy = q.shertul_energy - 60
			npc.replace_display = mod.class.Actor.new{
				image = "invis.png",
				add_mos={{image = "npc/humanoid_male_sluttymaid.png", display_y=-1, display_h=2}},
--				shader = "shadow_simulacrum",
--				shader_args = { color = {0.2, 0.1, 0.8}, base = 0.5, time_factor = 500 },
			}
			npc:removeAllMOs()
			game.level.map:updateMap(npc.x, npc.y)
			game.level.map:particleEmitter(npc.x, npc.y, 1, "demon_teleport")
		end},
		{"원래 모습으로 돌아와줘.", cond=function() return q.shertul_energy >= 60 end, action=function(npc, player)
			q.shertul_energy = q.shertul_energy - 60
			npc.replace_display = nil
			npc:removeAllMOs()
			game.level.map:updateMap(npc.x, npc.y)
			game.level.map:particleEmitter(npc.x, npc.y, 1, "demon_teleport")
		end},
		{"음, 지금 모습도 나쁘지 않은걸. 그냥 그대로 있어도 될 것 같아."},
	}
}

newChat{ id="permanent-cloak",
	text = [[알겠습니다, 주인님. 에너지 10 을 사용해서 망토에 힘을 주입시킬 수 있습니다. 이를 통해, 망토를 벗어도 그 효과가 유지되게 할 수 있습니다.
하지만, 그래도 망토는 가지고 다니는 것이 좋습니다. 이 세계에는 혹시라도 망토의 효과를 없애는 무언가가 있을지도 모릅니다.]],
	answers = {
		{"나중에 하지."},
		{"꽤 유용하겠는걸. 그렇게 해줘.", action=function(npc, player)
			local cloak = player:findInAllInventoriesBy("define_as", "CLOAK_DECEPTION")
			cloak.upgraded_cloak = true
			q.shertul_energy = q.shertul_energy - 10
			q:setStatus(engine.Quest.COMPLETED, "permanent-cloak")
		end},
	}
}

newChat{ id="cure-melinda",
	text = [[악마의 감염이로군요. 예, 기록을 살펴보니 제가 도울 방법이 있습니다. 하지만 이 방법은 긴 시간이 필요해서, 대상이 한동안 여기서 지낼 필요가 있습니다.
그녀는 재생 장치에서 매일 8 시간씩을 보내야 할 것입니다.]],
	answers = {
		{"대단한 소식이로군! 그녀에게 당장 말해줘야겠어.", action=function(npc, player)
		player:setQuestStatus("love-melinda", engine.Quest.COMPLETED, "can_come_fortress")
		end},
	}
}

return "welcome"
