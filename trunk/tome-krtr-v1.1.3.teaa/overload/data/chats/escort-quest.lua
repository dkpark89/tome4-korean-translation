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

local Talents = require("engine.interface.ActorTalents")
local Stats = require("engine.interface.ActorStats")

local reward_types = {
	warrior = {
		types = {
			["technique/conditioning"] = 0.8,
		},
		talents = {
			[Talents.T_VITALITY] = 1,
			[Talents.T_UNFLINCHING_RESOLVE] = 1,
			[Talents.T_EXOTIC_WEAPONS_MASTERY] = 1,
		},
		stats = {
			[Stats.STAT_STR] = 2,
			[Stats.STAT_CON] = 1,
		},
	},
	divination = {
		types = {
			["spell/divination"] = 0.8,
		},
		talents = {
			[Talents.T_ARCANE_EYE] = 1,
			[Talents.T_PREMONITION] = 1,
			[Talents.T_VISION] = 1,
		},
		stats = {
			[Stats.STAT_MAG] = 2,
			[Stats.STAT_WIL] = 1,
		},
		antimagic = {
			types = {
				["wild-gift/call"] = 0.8,
			},
			saves = { mind = 4 },
			talents = {
				[Talents.T_NATURE_TOUCH] = 1,
				[Talents.T_EARTH_S_EYES] = 1,
			},
			stats = {
				[Stats.STAT_CUN] = 1,
				[Stats.STAT_WIL] = 2,
			},
		},
	},
	alchemy = {
		types = {
			["spell/staff-combat"] = 0.8,
			["spell/stone-alchemy"] = 0.8,
		},
		talents = {
			[Talents.T_CHANNEL_STAFF] = 1,
			[Talents.T_STAFF_MASTERY] = 1,
			[Talents.T_STONE_TOUCH] = 1,
		},
		stats = {
			[Stats.STAT_MAG] = 2,
			[Stats.STAT_DEX] = 1,
		},
		antimagic = {
			types = {
				["wild-gift/mindstar-mastery"] = 0.8,
			},
			talents = {
				[Talents.T_PSIBLADES] = 1,
				[Talents.T_THORN_GRAB] = 1,
			},
			saves = { spell = 4 },
			stats = {
				[Stats.STAT_WIL] = 1,
				[Stats.STAT_DEX] = 2,
			},
		},
	},
	survival = {
		types = {
			["cunning/survival"] = 0.8,
		},
		talents = {
			[Talents.T_HEIGHTENED_SENSES] = 1,
			[Talents.T_CHARM_MASTERY] = 1,
			[Talents.T_PIERCING_SIGHT] = 1,
		},
		stats = {
			[Stats.STAT_DEX] = 2,
			[Stats.STAT_CUN] = 1,
		},
	},
	sun_paladin = {
		types = {
			["celestial/chants"] = 0.8,
		},
		talents = {
			[Talents.T_CHANT_OF_FORTITUDE] = 1,
			[Talents.T_CHANT_OF_FORTRESS] = 1,
		},
		stats = {
			[Stats.STAT_STR] = 2,
			[Stats.STAT_MAG] = 1,
		},
		antimagic = {
			types = {
				["technique/mobility"] = 0.8,
			},
			talents = {
				[Talents.T_HACK_N_BACK] = 1,
				[Talents.T_LIGHT_OF_FOOT] = 1,
			},
			saves = { spell = 4, phys = 4 },
			stats = {
				[Stats.STAT_CUN] = 1,
				[Stats.STAT_WIL] = 2,
			},
		},
	},
	anorithil = {
		types = {
			["celestial/light"] = 0.8,
		},
		talents = {
			[Talents.T_BATHE_IN_LIGHT] = 1,
			[Talents.T_HEALING_LIGHT] = 1,
		},
		stats = {
			[Stats.STAT_CUN] = 2,
			[Stats.STAT_MAG] = 1,
		},
		antimagic = {
			types = {
				["technique/field-control"] = 0.8,
			},
			talents = {
				[Talents.T_TRACK] = 1,
				[Talents.T_HEAVE] = 1,
			},
			saves = { spell = 4, mind = 4 },
			stats = {
				[Stats.STAT_CUN] = 1,
				[Stats.STAT_WIL] = 2,
			},
		},
	},
	temporal = {
		types = {
			["chronomancy/chronomancy"] = 0.8,
		},
		talents = {
			[Talents.T_PRECOGNITION] = 1,
			[Talents.T_SPIN_FATE] = 1,
		},
		stats = {
			[Stats.STAT_MAG] = 2,
			[Stats.STAT_CUN] = 1,
		},
		antimagic = {
			types = {
				["psionic/dreaming"] = 0.8,
			},
			talents = {
				[Talents.T_SLEEP] = 1,
				[Talents.T_DREAM_WALK] = 1,
			},
			saves = { spell = 4 },
			stats = {
				[Stats.STAT_WIL] = 1,
				[Stats.STAT_CUN] = 2,
			},
		},
	},
	exotic = {
		talents = {
			[Talents.T_DISARM] = 1,
--			[Talents.T_WATER_JET] = 1,
			[Talents.T_SPIT_POISON] = 1,
			[Talents.T_MIND_SEAR] = 1,
		},
		stats = {
			[Stats.STAT_STR] = 2,
			[Stats.STAT_DEX] = 2,
			[Stats.STAT_MAG] = 2,
			[Stats.STAT_WIL] = 2,
			[Stats.STAT_CUN] = 2,
			[Stats.STAT_CON] = 2,
		},
	},
}

local hd = {"Quest:escort:reward", reward_types=reward_types}
if require("engine.class"):triggerHook(hd) then reward_types = hd.reward_types end

local reward = reward_types[npc.reward_type]
local quest = game.player:hasQuest(npc.quest_id)
if quest.to_zigur and reward.antimagic then reward = reward.antimagic reward.is_antimagic = true end

game.player:registerEscorts(quest.to_zigur and "zigur" or "saved")

local saves_name = { mind="mental", spell="spell", phys="physical"}
local kr_saves_name = { mind="정신", spell="주문", phys="물리"}
local saves_tooltips = { mind="MENTAL", spell="SPELL", phys="PHYS"}

local function generate_rewards()
	local answers = {}
	if reward.stats then
		for i = 1, #npc.stats_def do if reward.stats[i] then
			local doit = function(npc, player) game.party:reward("보상을 받을 동료를 고르시오 :", function(player)
				player.inc_stats[i] = (player.inc_stats[i] or 0) + reward.stats[i]
				player:onStatChange(i, reward.stats[i])
				player.changed = true
				player:hasQuest(npc.quest_id).reward_message = (" %s %d 만큼 향상되었습니다."):format(npc.stats_def[i].name:krStat():addJosa("가"), reward.stats[i])
			end) end
			answers[#answers+1] = {("[ %s %d 만큼 향상시킨다]"):format(npc.stats_def[i].name:krStat():addJosa("를"), reward.stats[i]),
				jump="done",
				action=doit,
				on_select=function(npc, player)
					game.tooltip_x, game.tooltip_y = 1, 1
					local TooltipsData = require("mod.class.interface.TooltipsData")
					game:tooltipDisplayAtMap(game.w, game.h, TooltipsData["TOOLTIP_"..npc.stats_def[i].short_name:upper()])
				end,
			}
		end end
	end
	if reward.saves then
		for save, v in pairs(reward.saves) do
			local doit = function(npc, player) game.party:reward("보상을 받을 동료를 고르시오 :", function(player)
				player:attr("combat_"..save.."resist", v)
				player.changed = true
				player:hasQuest(npc.quest_id).reward_message = (" %s 내성이 %d 만큼 향상되었습니다"):format(kr_saves_name[save], v)
			end) end
			answers[#answers+1] = {("[ %s 내성을 %d 만큼 향상시킨다]"):format(kr_saves_name[save], v),
				jump="done",
				action=doit,
				on_select=function(npc, player)
					game.tooltip_x, game.tooltip_y = 1, 1
					local TooltipsData = require("mod.class.interface.TooltipsData")
					game:tooltipDisplayAtMap(game.w, game.h, TooltipsData["TOOLTIP_"..saves_tooltips[save]:upper().."_SAVE"])
				end,
			}
		end
	end
	if reward.talents then
		for tid, level in pairs(reward.talents) do
			local t = npc:getTalentFromId(tid)
			level = math.min(t.points - game.player:getTalentLevelRaw(tid), level)
			if level > 0 then
				local doit = function(npc, player) game.party:reward("보상을 받을 동료를 고르시오 :", function(player)
					if game.player:knowTalentType(t.type[1]) == nil then player:setTalentTypeMastery(t.type[1], 0.8) end
					player:learnTalent(tid, true, level, {no_unlearn=true})
					if t.hide then player.__show_special_talents = player.__show_special_talents or {} player.__show_special_talents[tid] = true end
					player:hasQuest(npc.quest_id).reward_message = ("%s 기술을 %d 단계 %s습니다."):format((t.kr_name or t.name), level, game.player:knowTalent(tid) and "올렸" or "배웠") --@ 변수 순서 조정
				end) end
				answers[#answers+1] = {
					("[%s 기술 %d 단계 %s]"):format((t.kr_name or t.name), level, game.player:knowTalent(tid) and "향상" or "배움"), --@ 변수 순서 조정
						jump="done",
						action=doit,
						on_select=function(npc, player)
							game.tooltip_x, game.tooltip_y = 1, 1
							local mastery = nil
							if player:knowTalentType(t.type[1]) == nil then mastery = 0.8 end
							game:tooltipDisplayAtMap(game.w, game.h, "#GOLD#"..(t.kr_name or t.name).."#LAST#\n"..tostring(player:getTalentFullDescription(t, 1, nil, mastery)))
						end,
					}
			end
		end
	end
	if reward.types then
		for tt, mastery in pairs(reward.types) do if game.player:knowTalentType(tt) == nil then
			local tt_def = npc:getTalentTypeFrom(tt)
			local cat = tt_def.type:gsub("/.*", "")
			local doit = function(npc, player) game.party:reward("보상을 받을 동료를 고르시오 :", function(player)
				if player:knowTalentType(tt) == nil then player:setTalentTypeMastery(tt, mastery) end
				player:learnTalentType(tt, false)
				player:hasQuest(npc.quest_id).reward_message = ("기술 계열 %s의 숙련도를 %0.2f 만큼 향상시켰습니다."):format(cat:capitalize():krTalentType().." / "..tt_def.name:capitalize():krTalentType(), mastery)
			end) end
			answers[#answers+1] = {("[기술 계열을 훈련하여, %s의 숙련도를 %0.2f 만큼 향상시킨다]"):format(cat:capitalize():krTalentType().." / "..tt_def.name:capitalize():krTalentType(), mastery),
				jump="done",
				action=doit,
				on_select=function(npc, player)
					game.tooltip_x, game.tooltip_y = 1, 1
					game:tooltipDisplayAtMap(game.w, game.h, "#GOLD#"..(cat:capitalize():krTalentType().." / "..tt_def.name:capitalize():krTalentType()).."#LAST#\n"..tt_def.description)
				end,
			}
		end end
	end
	return answers
end

newChat{ id="welcome",
	text = reward.is_antimagic and [[마지막 순간에 당신은 자연의 힘을 사용합니다. 관문은 오작동하여 @npcname3@ 지구르로 순간이동시켜 버렸습니다.
당신은 자연이 당신에게 고마워하는 것을 느꼈습니다.]] or
	[[감사합니다. 당신이 없었다면 제가 어떻게 살아남았을지 상상도 되질 않는군요.
저에게 고마움을 표시할 기회를 주세요 :]],
	answers = generate_rewards(),
}

newChat{ id="done",
	text = [[수고하셨어요. 그럼 안녕히 가세요!]],
	answers = {
		{"그럼 안녕히."},
	},
}

return "welcome"
