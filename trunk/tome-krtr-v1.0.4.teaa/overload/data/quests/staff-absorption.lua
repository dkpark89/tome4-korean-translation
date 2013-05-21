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

-- Main quest: the Staff of Absorption
name = "A mysterious staff"
kr_name = "신비한 지팡이"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "두려움의 영역 깊은 곳에서, 당신은 강력한 흡혈귀인 '주인' 과 싸워 이겼습니다."
	if self:isCompleted("ambush") then
		desc[#desc+1] = "두려움의 영역을 나오던 도중에, 당신은 오크 부대의 습격을 받았습니다."
		desc[#desc+1] = "그들은 지팡이의 행방에 대해 물어봤습니다."
	elseif self:isCompleted("ambush-finished") and not self:isCompleted("survived-ukruk") then
		desc[#desc+1] = "두려움의 영역을 나오던 도중에, 당신은 오크 부대의 습격을 받아 죽음의 위기를 간신히 넘겼습니다."
		desc[#desc+1] = "그들은 지팡이의 행방에 대해 물어봤으며, 당신에게서 지팡이를 훔쳐갔습니다."
		desc[#desc+1] = "#LIGHT_GREEN#마지막 희망에 가서, 이 사실을 빨리 알려야 합니다!"
	elseif self:isCompleted("ambush-finished") and self:isCompleted("survived-ukruk") then
		desc[#desc+1] = "마지막 희망으로 가던 도중에, 당신은 오크 부대의 습격을 받았습니다."
		desc[#desc+1] = "그들은 지팡이의 행방에 대해 물어봤으며, 당신에게서 지팡이를 훔쳐가려고 했습니다."
		desc[#desc+1] = "하지만 당신은 그들에게 아무 말도 해주지 않았으며, 그들을 물리쳤습니다."
		desc[#desc+1] = "#LIGHT_GREEN#빨리 마지막 희망으로 가서, 이 사실을 알려야 합니다!"
	else
		desc[#desc+1] = "그의 시체에서, 당신은 이상한 지팡이를 발견했습니다. 지팡이에서 엄청난 힘이 뿜어져 나와, 당신은 이것을 사용해서는 안되겠다는 생각이 들었습니다."
		desc[#desc+1] = "이 지팡이를 남동쪽에 있는 마지막 희망의 장로에게 보여줘야 할 것 같습니다."
	end
	return table.concat(desc, "\n")
end

on_grant = function(self, who)
	game.party:learnLore("master-slain")
	game.logPlayer(who, "#00FFFF#가지고 있는 것만으로도 지팡이에서 힘이 흘러나오는 것을 느낄 수 있습니다. 이 지팡이는 고대의, 위험한 물건이 분명합니다.")
	game.logPlayer(who, "#00FFFF#마지막 희망의 현명한 장로에게 보여줘야 할 것 같습니다!")
end

start_ambush = function(self, who)
	game.logPlayer(who, "#VIOLET#당신이 두려움의 영역을 빠져나옴과 동시에, 오크 부대가 당신을 덮쳤습니다!")
	who:setQuestStatus("staff-absorption", engine.Quest.COMPLETED, "ambush")

	-- Next time the player dies (and he WILL die) he wont really die
	who.die = function(self)
		self.dead = false
		self.die = nil
		self.life = 1
		for _, e in pairs(game.level.entities) do
			if e ~= self and self:reactionToward(e) < 0 then
				game.level:removeEntity(e)
				e.dead = true
			end
		end

		-- Go through all effects and disable them
		local effs = {}
		for eff_id, p in pairs(self.tmp) do
			local e = self.tempeffect_def[eff_id]
			effs[#effs+1] = {"effect", eff_id}
		end
		while #effs > 0 do
			local eff = rng.tableRemove(effs)
			self:removeEffect(eff[2])
		end

		-- Protect from other hits on the same turn
		self:setEffect(self.EFF_DAMAGE_SHIELD, 3, {power=1000000})

		local o, item, inven_id = self:findInAllInventoriesBy("define_as", "STAFF_ABSORPTION")
		if o then
			self:removeObject(inven_id, item, true)
			o:removed()
		end

		require("engine.ui.Dialog"):simpleLongPopup("습격", [[몇 시간 뒤, 당신은 깨어났습니다. 자신이 살아있다는 사실에 놀라움을 느꼈지만, 지팡이가 사라졌다는 것을 깨달았습니다!
#VIOLET#마지막 희망에 가서, 이 사실을 빨리 알려야 합니다!]], 600)
		
		local oe = game.level.map(self.x, self.y, engine.Map.TERRAIN)
		if oe:attr("temporary") and oe.old_feat then 
			oe.old_feat = game.level.map(self.x, self.y, game.level.map.TERRAIN, game.zone.grid_list.GRASS_UP_WILDERNESS)
		else
			game.level.map(self.x, self.y, game.level.map.TERRAIN, game.zone.grid_list.GRASS_UP_WILDERNESS)
		end

		self:setQuestStatus("staff-absorption", engine.Quest.COMPLETED, "ambush-finish")
	end

	local Chat = require("engine.Chat")
	local chat = Chat.new("dreadfell-ambush", {name="Ukruk the Fierce", kr_name="난폭한 자, 우크룩"}, who)
	chat:invoke()
end

killed_ukruk = function(self, who)
	game.player.die = nil

	require("engine.ui.Dialog"):simpleLongPopup("습격", [[자신이 아직도 살아있다는 사실에, 놀라움을 느꼈습니다.
#VIOLET#마지막 희망에 가서, 이 사실을 빨리 알려야 합니다!]], 600)

	local oe = game.level.map(who.x, who.y, engine.Map.TERRAIN)
	if oe:attr("temporary") and oe.old_feat then 
		oe.old_feat = game.level.map(who.x, who.y, game.level.map.TERRAIN, game.zone.grid_list.GRASS_UP_WILDERNESS)
	else
		game.level.map(who.x, who.y, game.level.map.TERRAIN, game.zone.grid_list.GRASS_UP_WILDERNESS)
	end
	
	who:setQuestStatus("staff-absorption", engine.Quest.COMPLETED, "survived-ukruk")
end
