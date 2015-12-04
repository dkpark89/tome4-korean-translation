-- ToME - Tales of Maj'Eyal
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

require "engine.krtrUtils"

newEntity{ define_as = "TRAP_ALARM",
	type = "annoy", subtype="alarm", id_by_type=true, unided_name = "trap", kr_unided_name = "함정",
	display = '^',
	triggered = function() end,
}

newEntity{ base = "TRAP_ALARM",
	name = "intruder alarm", auto_id = true, image = "trap/trap_intruder_alarm_01.png",
	kr_name = "침입 감지 경보",
	detect_power = resolvers.clscale(20,50,8),
	disarm_power = resolvers.clscale(36,50,8),
	rarity = 3, level_range = {1, 50},
	color=colors.UMBER,
	message = "@Target1@ 경보 장치를 밟았습니다!",
	pressure_trap = true,
	triggered = function(self, x, y, who)
		for i = x - 20, x + 20 do for j = y - 20, y + 20 do if game.level.map:isBound(i, j) then
			local actor = game.level.map(i, j, game.level.map.ACTOR)
			if actor and not actor.player then
				if who:reactionToward(actor) > 0 then
					local tx, ty, a = who:getTarget()
					if a then
						actor:setTarget(a)
					end
				elseif who:reactionToward(actor) < 0 then
					actor:setTarget(who)
				end
			end
		end end end
		return true, true
	end
}

newEntity{ base = "TRAP_ALARM",
	name = "summoning alarm", auto_id = true, image = "trap/trap_summoning_alarm_01.png",
	kr_name = "소환 경보",
	detect_power = resolvers.clscale(8,50,8),
	disarm_power = resolvers.clscale(2,50,8),
	rarity = 3, level_range = {10, 50},
	color=colors.DARK_UMBER,
	nb_summon = resolvers.mbonus(3, 2),
	message = "경보가 울립니다!",
	triggered = function(self, sx, sy, who)
		for i = 1, self.nb_summon do
			-- Find space
			local x, y = util.findFreeGrid(sx, sy, 10, true, {[game.level.map.ACTOR]=true})
			if not x then
				break
			end

			-- Find an actor with that filter
			local m = game.zone:makeEntity(game.level, "actor")
			if m then
				game.zone:addEntity(game.level, m, "actor", x, y)
				game.logSeen(who, "%s 어디선가 갑자기 나타납니다!", (m.kr_name or m.name):capitalize():addJosa("가"))
			end
		end
		return true, true
	end
}
