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

require "engine.krtrUtils" --@@

newTalent{
	name = "Create Alchemist Gems",
	kr_display_name = "연금술용 보석 생성",
	type = {"spell/stone-alchemy-base", 1},
	require = spells_req1,
	points = 1,
	mana = 30,
	no_npc_use = true,
	no_unlearn_last = true,
	make_gem = function(self, t, base_define)
		local nb = rng.range(40, 80)
		local gem = game.zone:makeEntityByName(game.level, "object", "ALCHEMIST_" .. base_define)
		if not gem then return end

		local s = {}
		while nb > 0 do
			s[#s+1] = gem:clone()
			nb = nb - 1
		end
		for i = 1, #s do gem:stack(s[i]) end

		return gem
	end,
	action = function(self, t)
		local d d = self:showEquipInven("어느 보석을 사용합니까?", function(o) return not o.unique and o.type == "gem" end, function(o, inven, item)
			if not o then return end
			local gem = t.make_gem(self, t, o.define_as)
			if not gem then return end
			self:addObject(self.INVEN_INVEN, gem)
			self:removeObject(inven, item)
			game.logPlayer(self, "%s 만들었습니다.", gem:getName{do_color=true, do_count=true}:addJosa("를"))
			self:sortInven()
			d.used_talent = true
			return true
		end)
		local co = coroutine.running()
		d.unload = function(self) coroutine.resume(co, self.used_talent) end
		if not coroutine.yield() then return nil end

		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		return ([[보석 하나를 세공하여, 40 에서 80 개의 연금술용 보석을 만들어냅니다.
		연금술용 보석은 다양한 마법에 사용되며, 보석의 종류에 따라 다양한 효과를 낼 수 있습니다.]]):format()
	end,
}

newTalent{
	name = "Extract Gems",
	kr_display_name = "보석 추출",
	type = {"spell/stone-alchemy", 1},
	require = spells_req1,
	points = 5,
	no_npc_use = true,
	no_unlearn_last = true,
	on_learn = function(self, t)
		if not self:knowTalent(self.T_CREATE_ALCHEMIST_GEMS) then
			self:learnTalent(self.T_CREATE_ALCHEMIST_GEMS, true)
		end
	end,
	on_unlearn = function(self, t)
		if self:getTalentLevelRaw(t) == 0 and self:knowTalent(self.T_CREATE_ALCHEMIST_GEMS) then
			self:unlearnTalent(self.T_CREATE_ALCHEMIST_GEMS)
		end
	end,
	filterGem = function(self, t, o) return o.metallic and (o.material_level or 1) <= self:getTalentLevelRaw(t) end,
	getGem = function(self, t, o)
		if not o then return end

		local level = o.material_level or 1
		local gem = game.zone:makeEntity(game.level, "object", {ingore_material_restriction=true, type="gem", special=function(e) return not e.unique and e.material_level == level end}, nil, true)
		if gem then return gem end
	end,
	extractGem = function(self, t, o, inven, item, d)
		if not o then return end
		self:removeObject(inven, item)

		local level = o.material_level or 1
		local gem = t.getGem(self, t, o)
		if gem then
			self:addObject(self.INVEN_INVEN, gem)
			game.logPlayer(self, "%s에서 %s 추출했습니다.", o:getName{do_color=true, do_count=true}, gem:getName{do_color=true, do_count=true}:addJosa("를")) --@@
			self:sortInven()
			if d then d.used_talent = true end
		end
		return true
	end,
	action = function(self, t)
		local d d = self:showEquipInven("어느 금속제 장비에서 보석을 추출합니까?", function(o) return t.filterGem(self, t, o) end, function(o, inven, item) return t.extractGem(self, t, o, inven, item, d) end)
		local co = coroutine.running()
		d.unload = function(self) coroutine.resume(co, self.used_talent) end
		if not coroutine.yield() then return nil end
		return true
	end,
	info = function(self, t)
		local material = ""
		if self:getTalentLevelRaw(t) >=1 then material=material.."	-무쇠(Iron)\n" end
		if self:getTalentLevelRaw(t) >=2 then material=material.."	-강철(Steel)\n" end
		if self:getTalentLevelRaw(t) >=3 then material=material.."	-드워프강철(Dwarven-steel)\n" end
		if self:getTalentLevelRaw(t) >=4 then material=material.."	-스트라라이트(Stralite)\n" end
		if self:getTalentLevelRaw(t) >=5 then material=material.."	-보라툰(Voratun)" end
		return ([[금속제 무기나 갑옷에서 보석을 추출해냅니다. 현재 기술 레벨에서 다룰 수 있는 재질은 다음과 같습니다 :
		%s]]):format(material)
	end,
}

newTalent{
	name = "Imbue Item",
	kr_display_name = "장비 강화",
	type = {"spell/stone-alchemy", 2},
	require = spells_req2,
	points = 5,
	mana = 80,
	cooldown = 100,
	no_npc_use = true,
	no_unlearn_last = true,
	action = function(self, t)
		local d d = self:showInventory("어느 보석을 사용합니까?", self:getInven("INVEN"), function(gem) return gem.type == "gem" and gem.imbue_powers and gem.material_level and gem.material_level <= self:getTalentLevelRaw(t) end, function(gem, gem_item)
			local nd = self:showInventory("어느 방어구를 강화합니까?", self:getInven("INVEN"), function(o) return o.type == "armor" and (o.slot == "BODY" or (self:knowTalent(self.T_CRAFTY_HANDS) and (o.slot == "HEAD" or o.slot == "BELT"))) and not o.been_imbued end, function(o, item)
				self:removeObject(self:getInven("INVEN"), gem_item)
				o.wielder = o.wielder or {}
				table.mergeAdd(o.wielder, gem.imbue_powers, true)
				o.been_imbued = true
				game.logPlayer(self, "%s %s 강화하였습니다.", gem:getName{do_colour=true, no_count=true}:addJosa("로"), o:getName{do_colour=true, no_count=true}:addJosa("를")) --@@
				o.name = o.name .. " ("..gem.name..")"
				o.kr_display_name = (o.kr_display_name or o.name) .. " ("..(gem.kr_display_name or gem.name)..")" --@@
				o.special = true
				d.used_talent = true
				game:unregisterDialog(d)
			end)
			nd.unload = function(self) game:unregisterDialog(d) end
			return true
		end)
		local co = coroutine.running()
		d.unload = function(self) coroutine.resume(co, self.used_talent) end
		if not coroutine.yield() then return nil end
		return true
	end,
	info = function(self, t)
		return ([[보석의 힘을 주입하여 더 강력한 장비를 만듭니다. 강화는 단 한 번만 가능하며, 영구적으로 지속됩니다.
		가능 장비 : %s 
		가능한 보석의 수준 : %d 단계]]):format(self:knowTalent(self.T_CRAFTY_HANDS) and "갑옷, 허리띠, 모자류" or "갑옷", self:getTalentLevelRaw(t))
	end,
}
newTalent{
	name = "Gem Portal",
	kr_display_name = "보석 관문",
	type = {"spell/stone-alchemy",3},
	require = spells_req3,
	cooldown = function(self, t) return math.max(5, 20 - (self:getTalentLevelRaw(t) * 2)) end,
	mana = 20,
	points = 5,
	range = 1,
	no_npc_use = true,
	getRange = function(self, t) return math.floor(4 + self:combatSpellpower(0.06) * self:getTalentLevel(t)) end,
	action = function(self, t)
		local ammo = self:hasAlchemistWeapon()
		if not ammo or ammo:getNumber() < 5 then
			game.logPlayer(self, "이 기술을 사용하려면 5개의 연금술용 보석을 손에 들고있어야 합니다.")
			return
		end

		local tg = {type="bolt", range=self:getTalentRange(t), nolock=true, talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)

		local ox, oy = self.x, self.y
		local l = line.new(self.x, self.y, x, y)
		local nextx, nexty = l()
		if not nextx or not game.level.map:checkEntity(nextx, nexty, Map.TERRAIN, "block_move", self) then return end

		self:probabilityTravel(x, y, t.getRange(self, t))

		if ox == self.x and oy == self.y then return end

		for i = 1, 5 do self:removeObject(self:getInven("QUIVER"), 1) end
		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		local range = t.getRange(self, t)
		return ([[5개의 연금술용 보석을 부숴, 그 가루로 통과할 수 없는 벽이나 지형에 특수한 표식을 새깁니다. 
		그 힘을 이용하여, 벽이나 지형을 %d 칸 까지 통과할 수 있습니다.]]):
		format(range)
	end,
}

newTalent{
	name = "Stone Touch",
	kr_display_name = "석화의 손길",
	type = {"spell/stone-alchemy",4},
	require = spells_req4,
	points = 5,
	mana = 45,
	cooldown = 15,
	tactical = { DISABLE = { stun = 1.5, instakill = 1.5 } },
	range = function(self, t)
		if self:getTalentLevel(t) < 3 then return 1
		else return math.floor(self:getTalentLevel(t)) end
	end,
	requires_target = true,
	target = function(self, t)
		local tg = {type="beam", range=self:getTalentRange(t), talent=t}
		if self:getTalentLevel(t) >= 3 then tg.type = "beam" end
		return tg
	end,
	getDuration = function(self, t) return math.floor((3 + self:getTalentLevel(t)) / 1.5) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(tx, ty)
			local target = game.level.map(tx, ty, Map.ACTOR)
			if not target then return end

			if target:canBe("stun") and target:canBe("stone") and target:canBe("instakill") then
				target:setEffect(target.EFF_STONED, t.getDuration(self, t), {apply_power=self:combatSpellpower()})
				game.level.map:particleEmitter(tx, ty, 1, "archery")
			end
		end)
		game:playSoundNear(self, "talents/earth")
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		return ([[대상에게 석화의 손길을 내밀어, %d 턴 동안 석화 상태로 만듭니다.
		석화된 대상은 이동이나 생명력 재생이 불가능해지며, 매우 불안정한 상태가 되어 최대 생명력의 30%% 이상에 해당하는 피해를 한 번에 입으면 산산조각나서 즉사합니다.
		그 대신 석화되었기 때문에 화염이나 전기 저항력이 매우 높아지며, 물리적 공격에도 상당한 저항력을 가집니다.
		기술 레벨이 3 이상이면 빔 형태로 석화의 기운을 발사할 수 있습니다.
		이 마법은 기절했거나 석화에 면역을 가지고 있는 적에게는 통하지 않으며, 몇몇 보스에게도 통하지 않습니다.]]):
		format(duration)
	end,
}
