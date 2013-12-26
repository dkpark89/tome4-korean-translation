-- ToME - Tales of Middle-Earth
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

local Emote = require "engine.Emote"

newTalent{
	name = "Shadow Senses",
	kr_name = "그림자 감각",
	type = {"cursed/one-with-shadows", 1},
	require = cursed_cun_req_high1,
	mode = "passive",
	points = 5,
	no_npc_use = true,
	range = function(self, t) return math.floor(self:combatTalentScale(t, 1, 5, 1)) end,
	info = function(self, t)
		return ([[자신의 감각이 그림자에게까지 확장됩니다.
		언제나 그림자의 정확한 위치를 알 수 있게 되며, 그림자의 시야 반경 %d 칸의 적들을 감지할 수 있게 됩니다.]])
		:format(self:getTalentRange(t))
	end,
}

newTalent{
	name = "Shadow Empathy",
	kr_name = "그림자 공감",
	type = {"cursed/one-with-shadows", 2},
	require = cursed_cun_req_high2,
	points = 5,
	hate = 10,
	cooldown = 25,
	getRandomShadow = function(self, t)
		local shadows = {}
		if game.party and game.party:hasMember(self) then
			for act, def in pairs(game.party.members) do
				if act.summoner and act.summoner == self and act.is_doomed_shadow and not act.dead then
					shadows[#shadows+1] = act
				end
			end
		else
			for uid, act in pairs(game.level.entities) do
				if act.summoner and act.summoner == self and act.is_doomed_shadow and not act.dead then
					shadows[#shadows+1] = act
				end
			end
		end
		return #shadows > 0 and rng.table(shadows)
	end,
	getDur = function(self, t) return math.floor(self:combatTalentScale(t, 3, 10)) end,
	getPower = function(self, t) return 5 + self:combatTalentMindDamage(t, 0, 300) / 8 end,
	action = function(self, t)
		self:setEffect(self.EFF_SHADOW_EMPATHY, t.getDur(self, t), {power=t.getPower(self, t)})
		return true
	end,
	info = function(self, t)
		local power = t.getPower(self, t)
		local duration = t.getDur(self, t)
		return ([[자신의 그림자들과 %d 턴 동안 연결되어, 자신이 받는 피해량의 %d%% 만큼을 무작위한 그림자가 대신 받게됩니다.
		기술의 효과는 정신력의 영향을 받아 증가합니다.]]):
		format(duration, power)
	end,
}

newTalent{
	name = "Shadow Transposition",
	kr_name = "그림자 치환",
	type = {"cursed/one-with-shadows", 3},
	require = cursed_cun_req_high3,
	points = 5,
	hate = 6,
	cooldown = 10,
	no_npc_use = true,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 1, 15, 1)) end,
	getNb = function(self, t) return math.floor(self:combatTalentScale(t, 1, 3, 1)) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRadius(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, target.x, target.y) > self:getTalentRadius(t) then return nil end
		if target.summoner ~= self or not target.is_doomed_shadow then return end

		-- Displace
		local tx, ty, sx, sy = target.x, target.y, self.x, self.y
		target.x = nil target.y = nil
		self.x = nil self.y = nil
		target:move(sx, sy, true)
		self:move(tx, ty, true)

		self:removeEffectsFilter(function(t) return (t.type == "physical" or t.type == "magical") and t.status == "detrimental" end, t.getNb(self, t))

		return true
	end,
	info = function(self, t)
		return ([[관찰자들은 이제 당신과 그림자들이 떨어져 있다고 말할 수 없게 될 것입니다.
		반경 %d 칸 내에 있는 그림자를 하나 정해서, 즉시 자신과 자리를 바꿀 수 있게 됩니다.
		%d 개의 무작위한 물리적&마법적인 효과들 역시 선택된 그림자에게로 옮겨지게 됩니다.]])
		:format(self:getTalentRadius(t), t.getNb(self, t))
	end,
}

newTalent{
	name = "Shadow Decoy",
	kr_name = "그림자 분신",
	type = {"cursed/one-with-shadows", 4},
	require = cursed_cun_req_high4,
	mode = "sustained",
	cooldown = 10,
	points = 5,
	cooldown = 50,
	sustain_hate = 40,
	getPower = function(self, t) return 10 + self:combatTalentMindDamage(t, 0, 300) end,
	onDie = function(self, t, value, src)
		local shadow = self:callTalent(self.T_SHADOW_EMPATHY, "getRandomShadow")
		if not shadow then return false end

		game:delayedLogDamage(src, self, 0, ("#GOLD#(%d 분신)#LAST#"):format(value), false)
		game:delayedLogDamage(src, shadow, value, ("#GOLD#%d 분신#LAST#"):format(value), false)
		shadow:takeHit(value, src)
		self:setEffect(self.EFF_SHADOW_DECOY, 4, {power=t.getPower(self, t)})
		self:forceUseTalent(t.id, {ignore_energy=true})

		if self.player then self:setEmote(Emote.new("어리석구나, 너는 절대 나를 죽일 수 없다. 그것은 나의 그림자였을 뿐이니!", 45)) end
		return true
	end,
	activate = function(self, t)
		return {}
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		return ([[그림자들이 목숨을 바쳐 자신을 보호하게 됩니다.
		목숨을 잃을만한 치명적인 타격을 받게 되면, 무작위한 그림자와 위치를 바꾸고 대신 피해를 받게 만듭니다.
		이후 4 턴 동안 자신의 생명력이 -%d 만큼 떨어지기 전까지 죽지 않게 되지만, 0 이하로 생명력이 떨어지게 될 경우 자신의 생명력 수치를 알 수 없게 됩니다.
		효과가 발동되면 기술의 재사용 대기시간동안 효과를 다시 사용할 수 없게 되며, 기술의 효과는 정신력의 영영향을 받아 증가합니다.]]):
		format(t.getPower(self, t))
	end,
}
