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

name = "The beast within"
kr_display_name = "공포의 기억"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "당신은 작은 마을에서 도망쳐 나온, 반쯤 미친 나무꾼을 만났습니다. 그는 어떤 말 못할 공포스러운 존재가 마을에서 사람들을 학살하고 있다고 횡설수설 거렸습니다."
	if self.lumberjacks_died > 0 then
		desc[#desc+1] = self.lumberjacks_died.." 명의 나무꾼이 죽었습니다."
	end

	return table.concat(desc, "\n")
end

on_grant = function(self, who)
	-- Reveal entrances
	local g = mod.class.Grid.new{
		show_tooltip=true, always_remember = true,
		name="Small lumberjack village",
		kr_display_name = "작은 나무꾼 마을",
		display='*', color=colors.WHITE,
		notice = true, image="terrain/grass.png", add_mos={{image="terrain/town1.png"}},
		change_level=1, glow=true, change_zone="town-lumberjack-village",
	}
	g:resolve() g:resolve(nil, true)
	local level = game.level
	local spot = level:pickSpot{type="zone-pop", subtype="lumberjack-town"}
	game.zone:addEntity(level, g, "terrain", spot.x, spot.y)

	game.logPlayer(game.player, "그는 북쪽에 있는 릴젝 숲 방향을 가리켰습니다.")

	self.lumberjacks_died = 0
end

on_status_change = function(self, who, status, sub)
	if self:isCompleted() then
		local money = math.max(0, (20 - self.lumberjacks_died) * 1.2)
		if money > 0 then
			who:incMoney(money)
			require("engine.ui.Dialog"):simplePopup("감사의 선물", ("생존한 나무꾼들이 금화를 모아 당신에게 주었습니다. (금화 %0.2f 개)"):format(money))
		end
		if self.lumberjacks_died < 7 then
			local o = game.zone:makeEntity(game.level, "object", {type="tool", subtype="digger", tome_drops="boss"}, nil, true)
			if o then
				game:addEntity(game.level, o, "object")
				o:identify(true)
				who:addObject(who.INVEN_INVEN, o)
				require("engine.ui.Dialog"):simplePopup("감사의 선물", ("당신은 저희 대부분을 살려주셨습니다. 부디 저희의 선물을 받아주십시오. (그들이 당신에게 선물을 주었습니다 : %s)"):format(o:getName{do_color=true}))
			end
		end
		who:setQuestStatus(self.id, engine.Quest.DONE)
		game:setAllowedBuild("afflicted")
		game:setAllowedBuild("afflicted_cursed", true)
		world:gainAchievement("CURSE_ERASER", game.player)
	end
end

lumberjack_dead = function(self)
	self.lumberjacks_died = self.lumberjacks_died + 1
	game.logSeen(game.player, "#LIGHT_RED#나무꾼이 땅에 쓰러졌습니다. 죽은 것 같습니다.")
end
