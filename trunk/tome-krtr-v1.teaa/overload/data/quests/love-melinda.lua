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

name = "Melinda, lucky girl"
kr_display_name = "운 좋은 소녀, 멜린다"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "크릴-페이얀의 광신도로부터 멜린다를 구해준 뒤, 당신은 그녀를 마지막 희망에서 다시 만났습니다."
	if who.female then
		desc[#desc+1] = "당신은 그녀와 대화하면서, 그녀가 당신을 사랑하게 됐다는 것을 알았습니다. 당신이 여성인데도 말이지요."
	else
		desc[#desc+1] = "당신은 그녀와 대화하면서, 그녀가 당신을 사랑하게 됐다는 것을 알았습니다."
	end
	if self:isCompleted("moved-in") then
		desc[#desc+1] = "멜린다는 당신의 요새에서 당신과 함께 살기로 결심하였습니다."
	end
	return table.concat(desc, "\n")
end

function onWin(self, who)
	if who.dead then return end
	return 10, {
		"승리한 뒤, 당신은 마지막 희망으로 가서 멜린다와 다시 만났습니다. 그녀는 더 이상 악마 숭배로 인한 후유증을 겪지 않았습니다.",
		"당신은 그녀와 함께 살면서 행복한 삶을 살았습니다. 멜린다는 모험가의 기술들을 몇 개 배워 당신과 함께 여행을 다니기도 하였으며, 그녀는 당신과 함께 새로운 전설을 만들었습니다.",
	}
end

function spawnFortress(self, who) game:onTickEnd(function()
	local melinda = require("mod.class.NPC").new{
		name = "Melinda", define_as = "MELINDA_NPC",
		kr_display_name = "멜린다",
		type = "humanoid", subtype = "human", female=true,
		display = "@", color=colors.LIGHT_BLUE,
		image = "player/cornac_female_redhair.png",
		moddable_tile = "human_female",
		moddable_tile_base = "base_redhead_01.png",
		desc = [[당신은 그녀를 광신도들로부터 구해냈으며, 그녀와 사랑에 빠졌습니다. 그녀는 당신을 더 자주 보기 위해 요새에서 살기로 하였습니다.]],
		autolevel = "tank",
		ai = "none",
		stats = { str=8, dex=7, mag=8, con=12 },
		faction = who.faction,
		never_anger = true,

		resolvers.equip{ id=true,
			{defined="SIMPLE_GOWN", autoreq=true, ego_chance=-1000}
		},

		body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
		lite = 4,
		rank = 2,
		exp_worth = 0,

		max_life = 100, life_regen = 0,
		life_rating = 12,
		combat_armor = 3, combat_def = 3,

		on_die = function(self) game.player:setQuestStatus("love-melinda", engine.Quest.FAILED) end,
		can_talk = "melinda-fortress",
	}
	melinda:resolve() melinda:resolve(nil, true)
	local spot = game.level:pickSpot{type="spawn", subtype="melinda"}
	game.zone:addEntity(game.level, melinda, "actor", spot.x, spot.y)
	who:move(spot.x + 1, spot.y)

	who:setQuestStatus(self.id, self.COMPLETED, "moved-in")
end) end

function melindaCompanion(self, who, c, sc)
	for uid, e in pairs(game.level.entities) do if e.define_as == "MELINDA_NPC" then e:disappear() end end

	local melinda = require("mod.class.Player").new{name="Melinda"}
	local birth = require("mod.dialogs.Birther").new("", melinda, {}, function() end)
	birth:setDescriptor("sex", "Female")
	birth:setDescriptor("world", "Maj'Eyal")
	birth:setDescriptor("difficulty", "Normal")
	birth:setDescriptor("permadeath", "Roguelike")
	birth:setDescriptor("race", "Human")
	birth:setDescriptor("subrace", "Cornac")
	birth:setDescriptor("class", c)
	birth:setDescriptor("subclass", sc)
	birth.actor = melinda
	birth:apply()
	melinda.image = "player/cornac_female_redhair.png"
	melinda.moddable_tile_base = "base_redhead_01.png"

	melinda:resolve() melinda:resolve(nil, true)
	melinda:removeAllMOs()
	local spot = game.level:pickSpot{type="spawn", subtype="melinda"}
	game.zone:addEntity(game.level, melinda, "actor", spot.x, spot.y)
	melinda:forceLevelup(who.level)

	game.party:addMember(melinda, {
		control="full", type="companion", title="Melinda",
		orders = {target=true, leash=true, anchor=true, talents=true, behavior=true},
	})
end
