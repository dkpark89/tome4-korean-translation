-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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



local Dialog = require "engine.ui.Dialog"
local DamageType = require "engine.DamageType"
local o = version
local src = game.player

if o.factory_settings then
	print("Just started the chat, and we apparently have o.factory_settings.")
else
	print("Just started the chat, and there's no o.factory_settings")
	o.factory_settings = o.wielder
	o.unused_stats = 0
	o.factory_settings.mins = {
		combat_spellpower = math.max(o.factory_settings.combat_spellpower - 5 * (o.material_level or 1), 1),
		combat_spellcrit = math.max(o.factory_settings.combat_spellcrit - 5 * (o.material_level or 1), 1),
	}
	o.factory_settings.maxes = {
		combat_spellpower = o.factory_settings.combat_spellpower + 5 * (o.material_level or 1),
		combat_spellcrit = o.factory_settings.combat_spellcrit + 5 * (o.material_level or 1),
	}
end

-- Alot of this code is unused, telos is the only sentient staff in the game right now
local function intro(o)
	local sentient_responses = {
		default = [[어서오게. 도와줄 것이라도 있는가?]],
		aggressive = [[빨리 적들을 박살내자고.]],
		fawning = [[오 현명한 착용자시여, 제게 지식을 알려주시면 더욱 더 당신을 잘 모실 수 있을 것입니다.]],
		penitent = [[배상을 하십시오, 마법 사용자여. 그대가 끼친 손해는 비교할 수 없는 것이니.]],
		telos = [[나를 위해 정말 좋은 곳을 골랐군 그래. 이 수정 안에 있으니 정말 행복해. 지팡이에서는 내 겨드랑이 냄새가 나는 것 같군.]],
		telos_full = [[텔로스의 힘 앞에 무릎 꿇으라!]],
	}
	if o.no_command then
		return [[It is not yet your place to command such a staff as this. To do so invites obliteration.]]
	end
	if o.combat.sentient then
		return sentient_responses[o.combat.sentient] or sentient_responses["default"]
	else
		return [[Call on which aspect of the staff?]]
	end
end

local function how_speak(o)
	if not o.combat.sentient then return [[error!]] end
	local sentient_responses = {
		default = [[Oh, I was once a mighty Eldritch Channeler. Mighty and absentminded, as it turns out. Had a bit of a mishap with an Inverted Kugala's Soul-infusion technique. Long story short, my soul is now stuck in this stick, and the soul I was working with... well, I don't rightly know where he got to. But I hope we never meet him.]],
		aggressive = [[Argh! Bollocksed up a tricky bit of soul magic and the fool that I was supposed to be imprisoning for all eternity flitted away. My body, like all the targets of my spells, intended or otherwise, got reduced to elementary particles. Fortunately, I had this soul-cage of a staff all prepped and ready for a stray soul, so I'm not completely gone. But enough chit-chat. Let's fry somebody.]],
		fawning = [[My old master-- who, though a powerful enchanter, did not compare to you and your glory-- saw fit to imprison me in this fine staff to aid him in his work. Alas, he is long gone, but I despair not, for I have found a mighty new master.]],
		penitent = [[I am a portion of the very spirit of the world that was ripped free during the Spellblaze. I speak that I might enlighten those who bear me.]],
		telos = [[What's the good of immortality if you can't even speak? No archmage worth his salt is going to concoct some immoral life-after-death scheme without including some sort of capacity for making his opinions known. And, by the way, your energy manipulation techniques are on the same level as those of my average pair of shoes. Best study up if you don't want to die forgotten and incompetent.]],
		telos_full = [[What's the good of immortality if you can't even speak? No archmage worth his salt is going to concoct some immoral life-after-death scheme without including some sort of capacity for making his opinions known. And, by the way, your energy manipulation techniques are on the same level as those of my average pair of shoes. Best study up if you don't want to die forgotten and incompetent.]],
	}
	return sentient_responses[o.combat.sentient] or sentient_responses["default"]
end

local function which_aspect(o)
	if not o.combat.sentient then return [[error!]] end
	local sentient_responses = {
		default = [[Of course. Which aspect?]],
		aggressive = [[I highly recommend the mage aspect and the fire element. You're not going to find anything better for turning a piece of meat into a cloud of vapor.]],
		fawning = [[I live to serve-- though my use of the word 'live' is perhaps loose here.]],
		penitent = [[Choose wisely. Powers beyond your comprehension will tolerate only so much interference in their carefully-laid natural order.]],
		telos = [[Back in my day, we didn't need to go changing our staves around willy-nilly. We picked an element and stuck with it, by the gods.]],
		telos_full = [[Back in my day, we didn't need to go changing our staves around willy-nilly. We picked an element and stuck with it, by the gods.]],
	}
	return sentient_responses[o.combat.sentient] or sentient_responses["default"]
end

--unused for now:
local function alter_combat(o)
	if not o.combat.sentient then return [[error!]] end
	local sentient_responses = {
		default = [[Certainly. You should be impressed, by the way, that I can do such a thing. Most lesser practitioners of my art would have difficulties with this. What shall I change?]],
		aggressive = [[Fine, as long as it leads to blasting something soon. What do you want me to change?]],
	}
	return sentient_responses[o.combat.sentient] or sentient_responses["default"]
end

local function is_sentient()
	return o.combat.sentient
end

local function update_table(d_table_old, d_table_new, old_element, new_element, tab, v, is_greater)
	if is_greater then
		for i = 1, #d_table_old do
			o.wielder[tab][d_table_old[i]] = o.wielder[tab][d_table_old[i]] - v
			if o.wielder[tab][d_table_old[i]] == 0 then o.wielder[tab][d_table_old[i]] = nil end
		end
		for i = 1, #d_table_new do
			o.wielder[tab][d_table_new[i]] = (o.wielder[tab][d_table_new[i]] or 0) + v
		end
	else
		o.wielder[tab][old_element] = o.wielder[tab][old_element] - v
		o.wielder[tab][new_element] = (o.wielder[tab][new_element] or 0) + v
		if o.wielder[tab][old_element] == 0 then o.wielder[tab][old_element] = nil end
	end

end

local function set_element(element, new_flavor, player)
	state.set_element = true
	player.no_power_reset_on_wear = true

	local prev_name = o:getName{no_count=true, force_id=true, no_add_name=true}
	
	local dam = o.combat.dam
	local inven = player:getInven("MAINHAND")
	local o = player:takeoffObject(inven, 1)
	local dam_tables = {
		magestaff = {engine.DamageType.FIRE, engine.DamageType.COLD, engine.DamageType.LIGHTNING, engine.DamageType.ARCANE},
		starstaff = {engine.DamageType.LIGHT, engine.DamageType.DARKNESS, engine.DamageType.TEMPORAL, engine.DamageType.PHYSICAL},
		vilestaff = {engine.DamageType.DARKNESS, engine.DamageType.BLIGHT, engine.DamageType.ACID, engine.DamageType.FIRE}, -- yes it overlaps, it's okay
	}

	update_table(dam_tables[o.flavor_name], dam_tables[new_flavor], o.combat.damtype, element, "inc_damage", dam, o.combat.is_greater)
	if o.combat.of_warding then update_table(dam_tables[o.flavor_name], dam_tables[new_flavor], o.combat.damtype, element, "wards", 2, o.combat.is_greater) end
	if o.combat.of_greater_warding then update_table(dam_tables[o.flavor_name], dam_tables[new_flavor], o.combat.damtype, element, "wards", 3, o.combat.is_greater) end
	if o.combat.of_breaching then update_table(dam_tables[o.flavor_name], dam_tables[new_flavor], o.combat.damtype, element, "resists_pen", dam/2, o.combat.is_greater) end
	if o.combat.of_protection then update_table(dam_tables[o.flavor_name], dam_tables[new_flavor], o.combat.damtype, element, "resists", dam/2, o.combat.is_greater) end

	o.combat.damtype = element
	if not o.unique then o.name = o.name:gsub(o.flavor_name, new_flavor) end
	o.flavor_name = new_flavor
	o:resolve()
	o:resolve(nil, true)	

	local next_name = o:getName{no_count=true, force_id=true, no_add_name=true}

	if player.hotkey then
		local pos = player:isHotkeyBound("inventory", prev_name)
		if pos then
			player.hotkey[pos] = {"inventory", next_name}
		end
	end

	player:addObject(inven, o)	
	player.no_power_reset_on_wear = nil
	print("(in chat's set_element) state.set_element is ", state.set_element)

	coroutine.resume(co, true)

end

newChat{ id="welcome",
	text = intro(o),
	answers = {
		{"대체 어떻게 말을 할 수 있는거지?", cond = function() return is_sentient() and not o.no_command end, jump="how_speak"},
		{"다른 속성을 불러내고 싶은데.", cond = function() return is_sentient() and not o.no_command end, jump="which_aspect"},
		{"기본 특성을 바꾸고 싶어.", cond = function() return is_sentient() and not o.no_command end, 
			action = function()
				coroutine.resume(co, true)
				local SentientWeapon = require "mod.dialogs.SentientWeapon"
				local ds = SentientWeapon.new({actor=game.player, o=o})
				game:registerDialog(ds)
			end,
		},
		{"[마법사]", cond = function() return not is_sentient() and not o.no_command end, jump="element_mage"},
		{"[별]", cond = function() return not is_sentient() and not o.no_command end, jump="element_star"},
		{"[독성]", cond = function() return not is_sentient() and not o.no_command end, jump="element_vile"},
		{"아무 것도 아냐."},
	}
}

newChat{ id="element_mage",
	text = [[어떤 속성을 불러냅니까?]],
	answers = {
		{"[화염]", 
			action = function()
				set_element(DamageType.FIRE, "magestaff", game.player) 
				game.level.map:particleEmitter(game.player.x, game.player.y, 1, "teleport") 
			end,
		},
		{"[전격]", 
			action = function() 
				set_element(DamageType.LIGHTNING, "magestaff", game.player) 
				game.level.map:particleEmitter(game.player.x, game.player.y, 1, "teleport") 
			end,
		},
		{"[냉기]", 
			action = function() 
				set_element(DamageType.COLD, "magestaff", game.player) 
				game.level.map:particleEmitter(game.player.x, game.player.y, 1, "teleport") 
			end,
		},
		{"[마법]", 
			action = function() 
				set_element(DamageType.ARCANE, "magestaff", game.player) 
				game.level.map:particleEmitter(game.player.x, game.player.y, 1, "teleport") 
			end,
		},
		{"[다른 속성을 고른다]", jump="welcome"},
		{"아무 것도 아냐."},
	}
}

newChat{ id="element_star",
	text = [[어떤 속성을 불러냅니까?]],
	answers = {
		{"[빛]", 
			action = function() 
				set_element(DamageType.LIGHT, "starstaff", game.player) 
				game.level.map:particleEmitter(game.player.x, game.player.y, 1, "temporal_teleport") 
			end,
		},
		{"[어둠]", 
			action = function() 
				set_element(DamageType.DARKNESS, "starstaff", game.player) 
				game.level.map:particleEmitter(game.player.x, game.player.y, 1, "temporal_teleport") 
			end,
		},
		{"[시간]", 
			action = function() 
				set_element(DamageType.TEMPORAL, "starstaff", game.player) 
				game.level.map:particleEmitter(game.player.x, game.player.y, 1, "temporal_teleport") 
			end,
		},
		{"[물리]", 
			action = function() 
				set_element(DamageType.PHYSICAL, "starstaff", game.player) 
				game.level.map:particleEmitter(game.player.x, game.player.y, 1, "temporal_teleport") 
			end,
		},
		{"[다른 속성을 고른다]", jump="welcome"},
		{"아무 것도 아냐."},
	}
}


newChat{ id="element_vile",
	text = [[어떤 속성을 불러냅니까?]],
	answers = {
		{"[어둠]", 
			action = function() 
				set_element(DamageType.DARKNESS, "vilestaff", game.player) 
				game.level.map:particleEmitter(game.player.x, game.player.y, 1, "demon_teleport") 
			end,
		},
		{"[황폐]", 
			action = function() 
				set_element(DamageType.BLIGHT, "vilestaff", game.player) 
				game.level.map:particleEmitter(game.player.x, game.player.y, 1, "demon_teleport") 
			end,
		},
		{"[산성]", 
			action = function() 
				set_element(DamageType.ACID, "vilestaff", game.player) 
				game.level.map:particleEmitter(game.player.x, game.player.y, 1, "demon_teleport") 
			end,
		},
		{"[화염]", 
			action = function() 
				set_element(DamageType.FIRE, "vilestaff", game.player) 
				game.level.map:particleEmitter(game.player.x, game.player.y, 1, "demon_teleport") 
			end,
		},
		{"[다른 속성을 고른다]", jump="welcome"},
		{"아무 것도 아냐."},
	}
}

newChat{ id="how_speak",
	text = how_speak(o),
	answers = {
		{"그러죠.", jump="welcome"},
	}
}

newChat{ id="which_aspect",
	text = which_aspect(o),
	answers = {
		{"[마법사]", jump="element_mage"},
		{"[별]", jump="element_star"},
		{"[독성]", jump="element_vile"},
		{"조금 전으로 돌아가지.", jump="welcome"},
		{"아무 것도 아냐."},
	}
}

return "welcome"

