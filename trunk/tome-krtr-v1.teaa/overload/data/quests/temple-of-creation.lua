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

name = "The Temple of Creation"
kr_display_name = "창조의 사원"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "우클름스윅이 그가 만든 관문을 통해, 창조의 사원으로 가서 미쳐버린 슬라슐을 죽여줄 것을 요구했습니다."
	if self:isCompleted("slasul-story") then
		desc[#desc+1] = "슬라슐은 그의 이야기를 당신에게 들려주었습니다. 이제 당신이 선택해야 할 차례입니다. 둘 중 타락한 쪽은 누구?"
	end
	if self:isCompleted("legacy-naloren") then
		desc[#desc+1] = "슬라슐이 자신의 생명력을 당신과 연결시켰습니다. 그리고 보답으로 당신에게 강력한 삼지창을 선물하였습니다."
	end

	if self:isCompleted("kill-slasul") and self:isCompleted("kill-drake") then
		desc[#desc+1] = "#LIGHT_GREEN#* 당신은 우클름스윅과 슬라슐을 모두 배신하여, 둘 다 죽였습니다.#WHITE#"
	elseif self:isCompleted("kill-slasul") and not self:isCompleted("kill-drake") then
		desc[#desc+1] = "#LIGHT_GREEN#* 당신은 우클름스윅의 편에 서서, 슬라슐을 죽였습니다.#WHITE#"
	elseif not self:isCompleted("kill-slasul") and self:isCompleted("kill-drake") then
		desc[#desc+1] = "#LIGHT_GREEN#* 당신은 슬라슐의 편에 서서, 우크림스윅을 죽였습니다.#WHITE#"
	end
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if sub and (sub == "kill-slasul" or sub == "kill-drake") then
		who:setQuestStatus(self.id, engine.Quest.DONE)
		if sub == "kill-slasul" then 
			world:gainAchievement("SLASUL_DEAD", game.player)
			if game:getPlayer(true):knowTalent(game.player.T_LEGACY_OF_THE_NALOREN) then world:gainAchievement("SLASUL_DEAD_PRODIGY_LEARNT", game.player) end
		elseif sub == "kill-drake" then world:gainAchievement("UKLLMSWWIK_DEAD", game.player) end
	end
end

on_grant = function(self, who)
	local g = mod.class.Grid.new{
		show_tooltip=true,
		name="Portal to the Temple of Creation",
		kr_display_name="창조의 사원으로 가는 관문",
		display='>', color=colors.VIOLET,
		notice = true,
		change_level=1, change_zone="temple-of-creation",
		image = "terrain/underwater/subsea_floor_02.png",
		add_displays = {mod.class.Grid.new{z=18, image="terrain/naga_portal.png", display_h=2, display_y=-1, embed_particles = {
			{name="naga_portal_smoke", rad=2, args={smoke="particles_images/smoke_whispery_bright"}},
			{name="naga_portal_smoke", rad=2, args={smoke="particles_images/smoke_heavy_bright"}},
			{name="naga_portal_smoke", rad=2, args={smoke="particles_images/smoke_dark"}},
		}}},
	}
	g:resolve() g:resolve(nil, true)
	game.zone:addEntity(game.level, g, "terrain", 34, 6)

	game.logPlayer(game.player, "우클름스윅의 근처에 관문이 열렸습니다.")
end

portal_back = function(self, who)
	if self:isCompleted("portal-back") then return end
	-- Do it on the quests object directly to not trigger a message to the player
	self:setStatus(engine.Quest.COMPLETED, "portal-back", who)

	local g = mod.class.Grid.new{
		show_tooltip=true,
		name="Portal to the Flooded Cave",
		kr_display_name="수중 동굴로 가는 관문",
		display='>', color=colors.VIOLET,
		notice = true,
		change_level=2, change_zone="flooded-cave",
		image = "terrain/underwater/subsea_floor_02.png",
		add_displays = {mod.class.Grid.new{z=18, image="terrain/naga_portal.png", display_h=2, display_y=-1, embed_particles = {
			{name="naga_portal_smoke", rad=2, args={smoke="particles_images/smoke_whispery_bright"}},
			{name="naga_portal_smoke", rad=2, args={smoke="particles_images/smoke_heavy_bright"}},
			{name="naga_portal_smoke", rad=2, args={smoke="particles_images/smoke_dark"}},
		}}},
	}
	g:resolve() g:resolve(nil, true)
	game.zone:addEntity(game.level, g, "terrain", 15, 13)

	game.logPlayer(game.player, "수중 동굴로 가는 관문이 열렸습니다.")
end
