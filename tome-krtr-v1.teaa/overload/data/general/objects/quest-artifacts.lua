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

require "engine.krtrUtils"

local Stats = require "engine.interface.ActorStats"

-- The staff of absorption, the reason the game exists!
newEntity{ define_as = "STAFF_ABSORPTION",
	power_source = {unknown=true},
	unique = true, quest=true, no_curses=true,
	slot = "MAINHAND",
	slot_forbid = "OFFHAND",
	type = "weapon", subtype="staff",
	unided_name = "dark runed staff",
	name = "Staff of Absorption",
	kr_display_name = "흡수의 지팡이", kr_unided_name = "어두룬 룬 지팡이",
	flavor_name = "magestaff",
	level_range = {30, 30},
	display = "\\", color=colors.VIOLET, image = "object/artifact/staff_absorption.png",
	encumber = 7,
	plot = true, quest = true,
	desc = [[힘을 내장한 룬이 새겨진 이 지팡이는 아주 오래전에 만들어진 것으로 보입니다. 하지만 아직도 변색된 흔적이 보이지 않습니다.
주변에 희미하게 빛이 나고, 살짝만 건드려도 그 안에 엄청난 힘이 들어있음을 느낄 수 있습니다.]],

	require = { stat = { mag=60 }, },
	combat = {
		dam = 30,
		apr = 4,
		dammod = {mag=1},
		damtype = DamageType.ARCANE,
		talented = "staff",
	},
	wielder = {
		combat_atk = 20,
		combat_spellpower = 20,
		combat_spellcrit = 10,
	},

	max_power = 1000, power_regen = 1,
	use_power = { name = "absorb energies", power = 1000,
		use = function(self, who)
			game.logPlayer(who, "이 힘은 사용하기에는 너무 강력해서, 그것이 당신을 흡수해버릴까 두렵습니다.")
			return {used=true}
		end
	},

	on_pickup = function(self, who)
		if who == game.player then
			who:grantQuest("staff-absorption")
		end
	end,
	on_drop = function(self, who)
		if who == game.player then
			game.logPlayer(who, "당신은 %s 버릴 수 없습니다.", self:getName():addJosa("를"))
			return true
		end
	end,
}

-- The orb of many ways, allows usage of Farportals
newEntity{ define_as = "ORB_MANY_WAYS",
	power_source = {unknown=true},
	unique = true, quest=true,
	type = "orb", subtype="orb",
	unided_name = "swirling orb",
	name = "Orb of Many Ways",
	kr_display_name = "여러 장소로의 오브", kr_unided_name = "소용돌이 오브",
	level_range = {30, 30},
	display = "*", color=colors.VIOLET, image = "object/artifact/orb_many_ways.png",
	encumber = 1,
	plot = true, quest = true,
	desc = [[이 오브는 계속 바뀌면서 먼 곳을 보여줍니다. 어떤 장소는 이 세상이 아닌듯 보이기도 합니다.
포탈 근처에서 사용하면, 활성화할 수 있을것 같습니다.]],

	auto_hotkey = 1,

	max_power = 30, power_regen = 1,
	use_power = { name = "activate a portal", power = 10,
		use = function(self, who)
			self:identify(true)
			local g = game.level.map(who.x, who.y, game.level.map.TERRAIN)
			if g and g.orb_portal then
				world:gainAchievement("SLIDERS", who:resolveSource())
				who:useOrbPortal(g.orb_portal)
			else
				game.logPlayer(who, "여기는 활성화하기 위한 포탈이 없습니다.")
			end
			return {id=true, used=true}
		end
	},

	on_drop = function(self, who)
		if who == game.player then
			game.logPlayer(who, "당신은 %s 버릴 수 없습니다.", self:getName():addJosa("를"))
			return true
		end
	end,
}

-- The orb of many ways, allows usage of Farportals
newEntity{ define_as = "ORB_MANY_WAYS_DEMON",
	power_source = {unknown=true},
	unique = "Orb of Many Ways Demon", quest=true, no_unique_lore=true,
	type = "orb", subtype="orb",
	unided_name = "swirling orb", identified=true,
	name = "Orb of Many Ways",
	kr_display_name = "여러 장소로의 오브", kr_unided_name = "소용돌이 오브",
	level_range = {30, 30},
	display = "*", color=colors.VIOLET, image = "object/artifact/orb_many_ways.png",
	encumber = 1,
	plot = true, quest = true,
	desc = [[이 오브는 계속 바뀌면서 먼 곳을 보여줍니다. 어떤 장소는 이 세상이 아닌듯 보이기도 합니다.
포탈 근처에서 사용하면, 활성화할 수 있을것 같습니다.]],

	max_power = 30, power_regen = 1,
	use_power = { name = "포탈 활성화", power = 10,
		use = function(self, who)
			local g = game.level.map(who.x, who.y, game.level.map.TERRAIN)
			if g and g.orb_portal then
				world:gainAchievement("SLIDERS", who:resolveSource())
				who:useOrbPortal{
					change_level = 1,
					change_zone = "demon-plane",
					message = "#VIOLET#주변 세상이 토할 정도로 빙빙 돌고 당신은 원하지 않았던 장소에 와있음을 발견합니다! 지난번에 여러 장소로의 오브를 사용했을 때와는 전혀 다릅니다. 탄넨이 오브를 가짜와 바꿔치기했음이 틀림없습니다!",
					on_use = function(self, who)
						who:setQuestStatus("east-portal", engine.Quest.COMPLETED, "tricked-demon")
						local orb = who:findInAllInventoriesBy("define_as", "ORB_MANY_WAYS_DEMON")
						if orb then orb.name = "Demonic Orb of Many Ways" orb.kr_display_name = "악마의 여러 장소로의 오브" end
						require("engine.ui.Dialog"):simplePopup("악마의 여러 장소로의 오브", "지난번에 여러 장소로의 오브를 사용했을 때와는 전혀 다릅니다. 탄넨이 오브를 가짜와 바꿔치기 했음이 틀림 없습니다!")
					end,
				}
			else
				game.logPlayer(who, "여기는 활성화하기 위한 포탈이 없습니다.")
			end
			return {id=true, used=true}
		end
	},

	on_drop = function(self, who)
		if who == game.player then
			game.logPlayer(who, "당신은 %s 버릴 수 없습니다.", self:getName():addJosa("를"))
			return true
		end
	end,
}

-------------------- The four orbs of command

-- Rak'shor Pride
newEntity{ define_as = "ORB_UNDEATH",
	power_source = {unknown=true},
	unique = true, quest=true,
	type = "orb", subtype="orb",
	unided_name = "orb of command",
	name = "Orb of Undeath (Orb of Command)",
	kr_display_name = "역생의 오브 (지배의 오브)", kr_unided_name = "지배의 오브",
	level_range = {50, 50},
	display = "*", color=colors.VIOLET, image = "object/artifact/orb_undeath.png",
	encumber = 1,
	plot = true, quest = true,
	desc = [[당신이 이 오브를 들자 어두운 심안이 당신의 마음을 채웁니다. 닿으면 매우 차갑습니다.]],

	on_drop = function(self, who)
		if who == game.player then
			game.logPlayer(who, "당신은 %s 버릴 수 없습니다.", self:getName():addJosa("를"))
			return true
		end
	end,

	max_power = 1, power_regen = 1,
	use_power = { name = "오브 사용", power = 1,
		use = function(self, who) who:useCommandOrb(self) return {id=true, used=true} end
	},

	carrier = {
		inc_stats = { [Stats.STAT_DEX] = 6, },
	},
}

-- Gorbat Pride
newEntity{ define_as = "ORB_DRAGON",
	power_source = {unknown=true},
	unique = true, quest=true,
	type = "orb", subtype="orb",
	unided_name = "orb of command",
	name = "Dragon Orb (Orb of Command)",
	kr_display_name = "용의 오브 (지배의 오브)", kr_unided_name = "지배의 오브",
	level_range = {50, 50},
	display = "*", color=colors.VIOLET, image = "object/artifact/orb_dragon.png",
	encumber = 1,
	plot = true, quest = true,
	desc = [[이 오브에 닿으면 따뜻합니다.]],

	on_drop = function(self, who)
		if who == game.player then
			game.logPlayer(who, "당신은 %s 버릴 수 없습니다.", self:getName():addJosa("를"))
			return true
		end
	end,

	max_power = 1, power_regen = 1,
	use_power = { name = "오브 사용", power = 1,
		use = function(self, who) who:useCommandOrb(self) return {id=true, used=true} end
	},

	carrier = {
		inc_stats = { [Stats.STAT_CUN] = 6, },
	},
}

-- Vor Pride
newEntity{ define_as = "ORB_ELEMENTS",
	power_source = {unknown=true},
	unique = true, quest=true,
	type = "orb", subtype="orb",
	unided_name = "orb of command",
	name = "Elemental Orb (Orb of Command)",
	kr_display_name = "정령 오브 (지배의 오브)", kr_unided_name = "지배의 오브",
	level_range = {50, 50},
	display = "*", color=colors.VIOLET, image = "object/artifact/elemental_orb.png",
	encumber = 1,
	plot = true, quest = true,
	desc = [[이 오브의 표면은 얼음이 씌워져 있고, 그 주위로 불꽃이 소용돌이 칩니다.]],

	on_drop = function(self, who)
		if who == game.player then
			game.logPlayer(who, "당신은 %s 버릴 수 없습니다.", self:getName():addJosa("를"))
			return true
		end
	end,

	max_power = 1, power_regen = 1,
	use_power = { name = "오브 사용", power = 1,
		use = function(self, who) who:useCommandOrb(self) return {id=true, used=true} end
	},

	carrier = {
		inc_stats = { [Stats.STAT_MAG] = 6, },
	},
}

-- Grushnak Pride
newEntity{ define_as = "ORB_DESTRUCTION",
	power_source = {unknown=true},
	unique = true, quest=true,
	type = "orb", subtype="orb",
	unided_name = "orb of command",
	name = "Orb of Destruction (Orb of Command)",
	kr_display_name = "파괴의 오브 (지배의 오브)", kr_unided_name = "지배의 오브",
	level_range = {50, 50},
	display = "*", color=colors.VIOLET, image = "object/artifact/orb_destruction.png",
	encumber = 1,
	plot = true, quest = true,
	desc = [[이 오브를 들자 당신의 마음이 죽음과 파괴에 대한 심안으로 채워집니다.]],

	on_drop = function(self, who)
		if who == game.player then
			game.logPlayer(who, "당신은 %s 버릴 수 없습니다.", self:getName():addJosa("를"))
			return true
		end
	end,

	max_power = 1, power_regen = 1,
	use_power = { name = "오브 사용", power = 1,
		use = function(self, who) who:useCommandOrb(self) return {id=true, used=true} end
	},

	carrier = {
		inc_stats = { [Stats.STAT_STR] = 6, },
	},
}

-- Scrying
newEntity{ define_as = "ORB_SCRYING",
	power_source = {unknown=true},
	unique = true, quest=true, no_unique_lore=true,
	type = "orb", subtype="orb",
	unided_name = "orb of scrying",
	name = "Orb of Scrying",
	kr_display_name = "점술사의 오브", kr_unided_name = "점술사의 오브", --@@ 여기의 kr_display_name으로 종족 시작 아이템 단축키 이름 변경 필요(/data/birth/races/하위 모든 파일) :기존은 완료, 새 종족 추가시 작업필요 
	display = "*", color=colors.VIOLET, image = "object/artifact/orb_scrying.png",
	encumber = 1,
	plot = true, quest = true,
	save_hotkey = true,
	desc = [[이 오브는 하플링 점술사 엘리사에게 받은 것입니다. 이것은 자동으로 일반 아이템이나 희귀한 아이템을 감정해 줍니다. 매우 희귀한 아이템을 감정하기 위해서는 오브를 사용하여 엘리사와 연락을 취해야 합니다.]],

	on_drop = function(self, who)
		if who == game.player then
			game.logPlayer(who, "당신은 %s 버릴 수 없습니다.", self:getName():addJosa("를"))
			return true
		end
	end,

	max_power = 1, power_regen = 1,
	use_power = { name = "오브 사용", power = 1,
		use = function(self, who)
			local Chat = require("engine.Chat")
			local chat = Chat.new("elisa-orb-scrying", {name="점술사 엘리사"}, who, {version="elisa"})
			chat:invoke()
			return {id=true, used=true}
		end
	},

	carrier = {
		auto_id = 2,
	},
}

newEntity{ base = "BASE_ROD",
	power_source = {unknown=true, arcane=false},
	define_as = "ROD_OF_RECALL",
	unided_name = "unstable rod", identified=true, force_lore_artifact=true,
	name = "Rod of Recall", color=colors.LIGHT_BLUE, unique=true, image = "object/artifact/rod_of_recall.png",
	kr_display_name = "되돌림의 장대", kr_unided_name = "불안정한 장대",
	desc = [[이 장대는 보라툰만으로 만들어졌고, 가공되지 않은 마법의 힘이 주입되어 주변의 공간을 휠 수 있게 만들어 졌습니다.
당신은 기존에 이런 종류의 아이템을 들어본 적이 있습니다. 그것들은 빠른 이동을 할 수 있게 만들어 줌으로, 모험가에게 매우 유용합니다.]],
	cost = 0, quest=true,

	auto_hotkey = 1,

	max_power = 400, power_regen = 1,
	use_power = { name = "사용자를 세계지도로 되돌림", power = 202,
		use = function(self, who)
			if who:hasEffect(who.EFF_RECALL) then
				who:removeEffect(who.EFF_RECALL)
				game.logPlayer(who, "장대가 이상한 소음을 내고 빛을 내다가 정상적으로 돌아왔습니다.")
				return {id=true, used=true}
			end
			if not who:attr("never_move") then
				if who:canBe("worldport") then
					who:setEffect(who.EFF_RECALL, 40, { where = self.shertul_fortress and "shertul-fortress" or nil })
					game.logPlayer(who, "주변의 공간이 사라지기 시작합니다...")
					return {id=true, used=true}
				elseif game.zone.force_farportal_recall then
					require("engine.ui.Dialog"):yesnoLongPopup("소환의 힘", "돌아오는 포탈을 찾지 않고 되돌림의 힘을 사용하면 탐험용 장거리포탈이 영원히 부서질 수도 있다고 요새의 그림자가 경고합니다.", 500, function(ret)
						if not ret then
							who:setEffect(who.EFF_RECALL, 40, { where = self.shertul_fortress and "shertul-fortress" or nil, allow_override=true })
							game.logPlayer(who, "주변의 공간이 사라지기 시작합니다...")
							if rng.percent(90) and who:hasQuest("shertul-fortress") then
								who:hasQuest("shertul-fortress"):break_farportal()
							end
						end
					end, "취소", "소환")
				end
			end
			game.logPlayer(who, "장대가 이상한 소음을 내고 빛을 내다가 정상적으로 돌아왔습니다.")
			return {id=true, used=true}
		end
	},

	on_drop = function(self, who)
		if who == game.player then
			game.logPlayer(who, "당신은 %s 버릴 수 없습니다.", self:getName():addJosa("를"))
			return true
		end
	end,

	on_pickup = function(self, who)
		if who == game.player then
			require("engine.ui.Dialog"):simplePopup("되돌림의 장대", "당신은 되돌림의 장대를 찾았습니다. 이것을 사용하면 현재 지역을 빠르게 벗어나 세계지도 상으로 돌아갈 수 있습니다.")
		end
	end,
}

newEntity{ base = "BASE_ROD",
	power_source = {unknown=true, arcane=false},
	type = "chest", subtype = "sher'tul",
	define_as = "TRANSMO_CHEST",
	add_name = false,
	identified=true, force_lore_artifact=true,
	name = "Transmogrification Chest", display = '~', color=colors.GOLD, unique=true, image = "object/chest4.png",
	kr_display_name = "변형상자",
	desc = [[이 상자는 이일크구르와 연결되어, 그 속에 있는 아이템을 요새로 운반하고, 파괴한 뒤 에너지를 추출합니다.
이 작업의 부산물로 금화가 만들어지는데, 이것은 요새에서는 쓸모없는 것이므로, 금화는 당신에게 돌아옵니다.

이 상자를 가지고 있다면, 바닥에서 자동으로 줍는 모든 물건이 일단 상자속으로 들어가고, 해당층을 벗어날 때 변형작업을 시작합니다.
상자 속에 있는 물건 중 계속 가지고 있기를 원하는 것은 상자 밖으로 꺼내 놓으십시오.
상자 속에 있는 물건들은 당신에게 무거움을 느끼게 하지 않습니다.]],
	cost = 0, quest=true,

	carrier = {
		has_transmo = 1,
	},

	max_power = 1000, power_regen = 1,
	use_power = { name = "상자속의 모든 아이템을 변화 (층이 바뀔때에 자동으로 수행됨)", power = 0,
		use = function(self, who)
			local inven = who:getInven("INVEN")
			local nb = 0
			for i = #inven, 1, -1 do
				local o = inven[i]
				if o.__transmo then nb = nb + 1 end
			end
			if nb <= 0 then
				local floor = game.level.map:getObjectTotal(who.x, who.y)
				if floor == 0 then
					require("engine.ui.Dialog"):simplePopup("변형상자", "상자 속이나 바닥에 변화시킬 아이템이 없습니다.")
				else
					require("engine.ui.Dialog"):yesnoPopup("변형상자", "바닥에 있는 "..floor.."개의 아이템을 모두 바꿉니까?", function(ret)
						if not ret then return end
						for i = floor, 1, -1 do
							local o = game.level.map:getObject(who.x, who.y, i)
							if who:transmoFilter(o) then
								game.level.map:removeObject(who.x, who.y, i)
								who:transmoInven(nil, nil, o)
							end
						end
					end, "예", "아니오")
				end
				return {id=true, used=true}
			end

			require("engine.ui.Dialog"):yesnoPopup("변형상자", "상자 속에 있는 "..nb.."개의 아이템을 모두 바꿉니까?", function(ret)
				if not ret then return end
				for i = #inven, 1, -1 do
					local o = inven[i]
					if o.__transmo then
						who:transmoInven(inven, i, o)
					end
				end
			end, "예", "아니오")
			return {id=true, used=true}
		end
	},

	on_pickup = function(self, who)
		require("engine.ui.Dialog"):simpleLongPopup("변형상자", [[이 상자는 이일크구르와 연결되어, 그 속에 있는 아이템을 요새로 운반하고, 파괴한 뒤 에너지를 추출합니다.
이 작업의 부산물로 금화가 만들어지는데, 이것은 요새에서는 쓸모없는 것이므로, 금화는 당신에게 돌아옵니다.

이 상자를 가지고 있다면, 바닥에서 자동으로 줍는 모든 물건이 일단 상자속으로 들어가고, 해당층을 벗어날 때 변형작업을 시작합니다.
상자 속에 있는 물건 중 계속 가지고 있기를 원하는 것은 상자 밖으로 꺼내 놓으십시오.
상자 속에 있는 물건들은 당신에게 무거움을 느끼게 하지 않습니다.]], 500)
	end,
	on_drop = function(self, who)
		if who == game.player then
			game.logPlayer(who, "당신은 %s 버릴 수 없습니다.", self:getName():addJosa("를"))
			return true
		end
	end,
}
