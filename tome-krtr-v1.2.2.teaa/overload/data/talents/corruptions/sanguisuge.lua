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

newTalent{
	name = "Drain",
	kr_name = "흡수",
	type = {"corruption/sanguisuge", 1},
	require = corrs_req1,
	points = 5,
	vim = 0,
	cooldown = 9,
	reflectable = true,
	proj_speed = 15,
	tactical = { ATTACK = {BLIGHT = 2}, VIM = 2 },
	requires_target = true,
	range = function(self, t) return math.floor(self:combatTalentScale(t, 5, 9)) end,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), talent=t, display={particle="bolt_slime"}}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:projectile(tg, x, y, DamageType.DRAIN_VIM, self:spellCrit(self:combatTalentSpellDamage(t, 25, 200)), {type="slime"})
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[황폐의 화살을 발사하여 %0.2f 황폐 속성 피해를 주고, 피해량의 20%% 만큼 원기를 회복합니다.
		원기 회복량은 대상의 등급과 비례합니다. (더 높은 등급일수록 더 많은 원기를 얻습니다)
		마법의 효과는 주문력의 영향을 받아 증가합니다.]]):
		format(damDesc(self, DamageType.BLIGHT, self:combatTalentSpellDamage(t, 25, 200)))
	end,
}

--[[
newTalent{
	name = "Blood Sacrifice",
	type = {"corruption/sanguisuge", 2},
	require = corrs_req2,
	points = 5,
	vim = 0,
	cooldown = 30,
	range = 10,
	tactical = { VIM = 1 },
	action = function(self, t)
		local amount = self.life * 0.5
		if self.life <= amount + 1 then
			game.logPlayer(self, "Doing this would kill you.")
			return
		end

		local seen = false
		-- Check for visible monsters, only see LOS actors, so telepathy wont prevent resting
		core.fov.calc_circle(self.x, self.y, game.level.map.w, game.level.map.h, 20, function(_, x, y) return game.level.map:opaque(x, y) end, function(_, x, y)
			local actor = game.level.map(x, y, game.level.map.ACTOR)
			if actor and self:reactionToward(actor) < 0 and self:canSee(actor) and game.level.map.seens(x, y) then
				seen = {x=x,y=y,actor=actor}
			end
		end, nil)
		if not seen then
			game.logPlayer(self, "There are no foes in sight.")
			return
		end

		self:incVim(30 + self:combatTalentSpellDamage(t, 5, 150))
		self:takeHit(amount, self)
		game:playSoundNear(self, "talents/spell_generic2")
		return true
	end,
	info = function(self, t)
		return ([=[Sacrifices 50%% of your current life to restore %d vim.
		This only works if there is at least one foe in sight.
		The effect will increase with your Magic stat.]=]):
		format(30 + self:combatTalentSpellDamage(t, 5, 150))
	end,
}
]]
newTalent{
	name = "Bloodcasting",
	kr_name = "피의 주문",
	type = {"corruption/sanguisuge", 2},
	require = corrs_req2,
	points = 5,
	vim = 0,
	cooldown = 18,
	no_energy = true,
	range = 10,
	no_npc_use = true,
	getDuration = function(self, t) return math.floor(self:combatTalentLimit(t, 18, 3, 7)) end, --Limit duration < 18
	action = function(self, t)
		self:setEffect(self.EFF_BLOODCASTING, t.getDuration(self,t), {})
		game:playSoundNear(self, "talents/spell_generic2")
		return true
	end,
	info = function(self, t)
		return ([[%d 턴 동안, 원기가 부족할 때 생명력으로 주문을 사용할 수 있게 됩니다.]]):
		format(t.getDuration(self,t))
	end,
}

newTalent{
	name = "Absorb Life",
	kr_name = "원기 강탈",
	type = {"corruption/sanguisuge", 3},
	mode = "sustained",
	require = corrs_req3,
	points = 5,
	sustain_vim = 5,
	cooldown = 30,
	range = 10,
	tactical = { BUFF = 2 },
	VimOnDeath = function(self, t) return self:combatTalentScale(t, 6, 16) end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/spell_generic2")
		local ret = {
			vim_regen = self:addTemporaryValue("vim_regen", -0.5),
			vim_on_death = self:addTemporaryValue("vim_on_death", t.VimOnDeath(self, t)),
		}
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("vim_regen", p.vim_regen)
		self:removeTemporaryValue("vim_on_death", p.vim_on_death)
		return true
	end,
	info = function(self, t)
		return ([[죽인 상대의 원기를 흡수합니다.
		마법이 활성화된 동안 매 턴마다 원기가 0.5 씩 소진되며, 언데드를 제외한 적을 죽일 때마다 원기가 %0.1f 회복됩니다.
		(최종 원기 회복량은 의지 능력치에 따른 기본 회복량과 더해져서 결정됩니다.)]]):
		format(t.VimOnDeath(self, t))
	end,
}

newTalent{
	name = "Life Tap",
	kr_name = "생명의 힘",
	type = {"corruption/sanguisuge", 4},
	require = corrs_req4,
	points = 5,
	vim = 40,
	cooldown = 20,
	range = 10,
	no_energy = true,
	tactical = { BUFF = 2 },
	getMult = function(self,t) return self:combatTalentScale(t, 8, 16) end,
	action = function(self, t)
		self:setEffect(self.EFF_LIFE_TAP, 7, {power=t.getMult(self,t)})
		game:playSoundNear(self, "talents/spell_generic2")
		return true
	end,
	info = function(self, t)
		return ([[원기를 소모하여, 강력한 힘을 끌어올립니다. 7 턴 동안 적에게 가하는 모든 피해량이 %0.1f%% 증가합니다.]]):
		format(t.getMult(self,t))
	end,
}
