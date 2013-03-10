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

load("/data/general/objects/objects-maj-eyal.lua")

for i = 1, 4 do
newEntity{ base = "BASE_LORE",
	define_as = "NOTE"..i,
	name = "Song of the Sands", lore="sandworm-note-"..i,
	kr_display_name = "모래의 노래",
	desc = [[어떤 사람이 떠올린 가장 이상한 생각!]],
	rarity = false,
}
end

-- Artifact, dropped by the sandworm queen
newEntity{
	power_source = {nature=true},
	define_as = "SANDQUEEN_HEART",
	type = "corpse", subtype = "heart", image = "object/artifact/queen_heart.png",
	name = "Heart of the Sandworm Queen", unique=true, unided_name="pulsing organ",
	kr_display_name = "지렁이 여왕의 심장", kr_unided_name = "맥동하는 장기",
	display = "*", color=colors.VIOLET,
	desc = [[지렁이 여왕의 죽은 몸에서 떼어낸 심장입니다. 자신이 충분히 정신 나간 사람이라면, 한번 먹어볼 수도 있습니다...]],
	cost = 3000,
	quest = 1,

	use_simple = { name="consume the heart", kr_display_name="심장 먹기", use = function(self, who)
		game.logPlayer(who, "#00FFFF#당신이 심장을 먹자, 이 아주 오래된 생명체의 지식이 당신을 채우는 것이 느껴집니다!")
		who.unused_stats = who.unused_stats + 3
		who.unused_talents = who.unused_talents + 1
		who.unused_generics = who.unused_generics + 1
		game.logPlayer(who, "사용할 수 있는 능력치 점수 %d점이 있습니다. 'G' 키를 눌러 사용할 수 있습니다.", who.unused_stats)
		game.logPlayer(who, "사용할 수 있는 직업기술 점수 %d점이 있습니다. 'G' 키를 눌러 사용할 수 있습니다.", who.unused_talents)
		game.logPlayer(who, "사용할 수 있는 일반기술 점수 %d점이 있습니다. 'G' 키를 눌러 사용할 수 있습니다.", who.unused_generics)

		if not who:attr("forbid_nature") then
			if who:knowTalentType("wild-gift/harmony") then
				who:setTalentTypeMastery("wild-gift/harmony", who:getTalentTypeMastery("wild-gift/harmony") + 0.2)
			elseif who:knowTalentType("wild-gift/harmony") == false then
				who:learnTalentType("wild-gift/harmony", true)
			else
				who:learnTalentType("wild-gift/harmony", false)
			end
			-- Make sure a previous amulet didnt bug it out
			if who:getTalentTypeMastery("wild-gift/harmony") == 0 then who:setTalentTypeMastery("wild-gift/harmony", 1) end
			game.logPlayer(who, "여왕의 심장이 당신을 변화시켰습니다!")
			game.logPlayer(who, "#00FF00#당신은 자연과의 친화력을 얻어, 이제 새로운 기술계열 '조화' 를 배울 수 있습니다. ('G' 키를 눌러 확인할 수 있습니다)")

			who:attr("drake_touched", 1)
		end

		game:setAllowedBuild("wilder_wyrmic", true)

		return {used=true, id=true, destroy=true}
	end}
}

newEntity{
	power_source = {nature=true},
	define_as = "PUTRESCENT_POTION",
	type = "corpse", subtype = "blood",
	name = "Wyrm Bile", unique=true, unided_name="putrescent potion", image="object/artifact/vial_wyrm_bile.png",
	kr_display_name = "용의 담즙", kr_unided_name = "부패한 물약",
	display = "*", color=colors.VIOLET,
	desc = [[걸쭉하고 덩어리진 액체가 든 약병입니다. 이걸 마시면... 무슨 일이 생길까요?]],
	cost = 3000,
	quest = 1,

	use_simple = { name="drink the vile blood", kr_display_name="불결한 피 섭취", use = function(self, who)
		game.logPlayer(who, "#00FFFF#당신은 용의 담즙을 마셨고, 영원히 변화했음을 느낍니다!")
		who.unused_talents_types = who.unused_talents_types + 1
		game.log("사용할 수 있는 기술계열 점수 %d점이 있습니다. 'G' 키를 눌러 사용할 수 있습니다.", who.unused_talents_types)

		local str, dex, con, mag, wil, cun = rng.range(-3, 6), rng.range(-3, 6), rng.range(-3, 6), rng.range(-3, 6), rng.range(-3, 6), rng.range(-3, 6)
		who:incStat("str", str) if str >= 0 then str="+"..str end
		who:incStat("dex", dex) if dex >= 0 then dex="+"..dex end
		who:incStat("mag", mag) if mag >= 0 then mag="+"..mag end
		who:incStat("wil", wil) if wil >= 0 then wil="+"..wil end
		who:incStat("cun", cun) if cun >= 0 then cun="+"..cun end
		who:incStat("con", con) if con >= 0 then con="+"..con end
		game.logPlayer(who, "#00FF00#능력치가 변화했습니다! (힘 %s, 민첩 %s, 마법 %s, 의지 %s, 교활함 %s, 체격 %s)", str, dex, mag, wil, cun, con)

		who:attr("drake_touched", 1)

		return {used=true, id=true, destroy=true}
	end}
}

newEntity{ base = "BASE_GEM",
	define_as = "ATAMATHON_ACTIVATE",
	subtype = "red",
	name = "Atamathon's Lost Ruby Eye", color=colors.VIOLET, quest=true, unique=true, identified=true, image="object/artifact/atamathons_lost_ruby_eye.png",
	kr_display_name = "아타마쏜의 잃어버린 루비 눈",
	desc = [[전설적인 거대 골렘 아타마쏜의 한 쪽 눈입니다.
장작더미의 시대에, 하플링이 오크에 대항하기 위한 무기로 이 골렘을 만들었다고 알려져 있습니다. 하지만, 오크들의 지도자인 포식자 가르쿨의 목숨을 건 공격을 받아 파괴되었다고 합니다.]],
	material_level = 5,
	cost = 100,
	wielder = { inc_damage = {[DamageType.FIRE]=12} },
	imbue_powers = { inc_damage = {[DamageType.FIRE]=12} },
}
