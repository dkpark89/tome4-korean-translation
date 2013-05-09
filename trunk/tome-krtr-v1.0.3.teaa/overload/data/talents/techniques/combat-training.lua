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

newTalent{
	name = "Thick Skin",
	kr_name = "튼튼한 피부",
	type = {"technique/combat-training", 1},
	mode = "passive",
	points = 5,
	require = { stat = { con=function(level) return 14 + level * 9 end }, },
	getRes = function(self, t) return 3 * self:getTalentLevelRaw(t) end,
	on_learn = function(self, t)
		self.resists.all = (self.resists.all or 0) + 3
	end,
	on_unlearn = function(self, t)
		self.resists.all = (self.resists.all or 0) - 3
	end,
	info = function(self, t)
		local res = t.getRes(self, t)
		return ([[피부가 튼튼해져 피해를 약간 덜 입게 됩니다. 전체 저항력이 %d%% 증가합니다.]]):
		format(res)
	end,
}

newTalent{
	name = "Armour Training",
	kr_name = "방어구 수련",
	type = {"technique/combat-training", 1},
	mode = "passive",
	no_unlearn_last = true,
	points = 5,
	require = {stat = {str = function(level) return 16 + (level + 2) * (level - 1) end}},
	on_unlearn = function(self, t)
		for inven_id, inven in pairs(self.inven) do if inven.worn then
			for i = #inven, 1, -1 do
				local o = inven[i]
				local ok, err = self:canWearObject(o)
				if not ok and err == "missing dependency" then
					game.logPlayer(self, "당신은 더이상 %s 다룰 수 없게 되었습니다.", o:getName{do_color=true}:addJosa("를"))
					local o = self:removeObject(inven, i, true)
					self:addObject(self.INVEN_INVEN, o)
					self:sortInven()
				end
			end
		end end
	end,
	getArmorHardiness = function(self, t) return self:getTalentLevel(t) * 10 end,
	getArmor = function(self, t) return self:getTalentLevel(t) * 2.8 end,
	getCriticalChanceReduction = function(self, t) return self:getTalentLevel(t) * 3.8 end,
	info = function(self, t)
		local hardiness = t.getArmorHardiness(self, t)
		local armor = t.getArmor(self, t)
		local criticalreduction = t.getCriticalChanceReduction(self, t)
		local classrestriction = ""
		if self.descriptor and self.descriptor.subclass == "Brawler" then
			classrestriction = "(격투가는 판갑을 입으면 대다수의 기술을 사용할 수 없습니다)"
		end
		if self:knowTalent(self.T_STEALTH) then
			classrestriction = "(중갑이나 판갑은 은신할 때 방해가 됩니다)"
		end
		return ([[방어구를 더 능숙하게 다룰 수 있게 됩니다. 
		중갑이나 판갑 착용시 방어도가 %d 상승하고, 방어 효율이 %d%% 증가하며, 적에게 치명타를 맞을 확률이 %d%% 줄어듭니다.
		1 레벨에는 중갑과 갑옷용 장갑, 투구, 중장화를 착용할 수 있게 되며,
		2 레벨에는 방패를 들 수 있게 되고,
		3 레벨에는 판갑을 착용할 수 있게 됩니다.
		%s]]):format(armor, hardiness, criticalreduction, classrestriction)
	end,
}

newTalent{
	name = "Combat Accuracy", short_name = "WEAPON_COMBAT",
	kr_name = "정확도 수련",
	type = {"technique/combat-training", 1},
	points = 5,
	require = { level=function(level) return (level - 1) * 4 end },
	mode = "passive",
	getAttack = function(self, t) return self:getTalentLevel(t) * 10 end,
	info = function(self, t)
		local attack = t.getAttack(self, t)
		return ([[맨손 전투나 근접, 원거리 무기 중 하나를 사용하면 정확도가 %d 증가합니다.]]):
		format(attack)
	end,
}

newTalent{
	name = "Weapons Mastery",
	kr_name = "무기 수련",
	type = {"technique/combat-training", 1},
	points = 5,
	require = { stat = { str=function(level) return 12 + level * 6 end }, },
	mode = "passive",
	getDamage = function(self, t) return self:getTalentLevel(t) * 10 end,
	getPercentInc = function(self, t) return math.sqrt(self:getTalentLevel(t) / 5) / 2 end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local inc = t.getPercentInc(self, t)
		return ([[장검, 대검, 도끼, 둔기 중 하나를 사용하면 물리력이 %d 증가합니다. 또한 해당 무기의 피해량이 %d%% 증가합니다.]]):
		format(damage, 100*inc)
	end,
}


newTalent{
	name = "Dagger Mastery", short_name = "KNIFE_MASTERY",
	kr_name = "단검 수련",
	type = {"technique/combat-training", 1},
	points = 5,
	require = { stat = { dex=function(level) return 10 + level * 6 end }, },
	mode = "passive",
	getDamage = function(self, t) return self:getTalentLevel(t) * 10 end,
	getPercentInc = function(self, t) return math.sqrt(self:getTalentLevel(t) / 5) / 2 end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local inc = t.getPercentInc(self, t)
		return ([[단검을 사용하면 물리력이 %d 증가합니다. 또한 단검의 피해량이 %d%% 증가합니다.]]):
		format(damage, 100*inc)
	end,
}

newTalent{
	name = "Exotic Weapons Mastery",
	kr_name = "이형 무기 수련",
	type = {"technique/combat-training", 1},
	hide = true,
	points = 5,
	require = { stat = { str=function(level) return 10 + level * 6 end, dex=function(level) return 10 + level * 6 end }, },
	mode = "passive",
	getDamage = function(self, t) return self:getTalentLevel(t) * 10 end,
	getPercentInc = function(self, t) return math.sqrt(self:getTalentLevel(t) / 5) / 2 end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local inc = t.getPercentInc(self, t)
		return ([[이형 무기를 사용하면 물리력이 %d 증가합니다. 또한 이형 무기의 피해량이 %d%% 증가합니다.]]):
		format(damage, 100*inc)
	end,
}
