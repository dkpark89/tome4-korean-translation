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
		fawning = [[오 현명한 착용자이시여, 제게 지식을 알려주시면 더욱 더 당신을 잘 모실 수 있을 것입니다.]],
		penitent = [[배상을 하십시오, 마법 사용자여. 그대가 끼친 손해는 비교할 수 없는 것이니.]],
		telos = [[나를 위해 정말 좋은 곳을 골랐군 그래. 이 수정 안에 있으니 정말 행복해. 지팡이에서 내 겨드랑이 냄새가 나는 것 같군.]],
		telos_full = [[텔로스의 힘 앞에 무릎 꿇으라!]],
	}
	if o.no_command then
		return [[아직 이곳은 당신이 이 강력한 지팡이를 다루기 좋은 장소가 아닙니다. 만일 여기서 지팡이를 다루면, 지팡이가 소멸되어 버릴 것입니다.]]
	end
	if o.combat.sentient then
		return sentient_responses[o.combat.sentient] or sentient_responses["default"]
	else
		return [[지팡이의 어느 속성을 불러오시겠습니까??]]
	end
end

local function how_speak(o)
	if not o.combat.sentient then return [[에러!]] end
	local sentient_responses = {
		default = [[아, 나는 이전에 '섬뜩한자'들 중 전지전능한 영매였지. 전지전능했었지만 그래, 멍청했었어. 결국 이렇게 되어버렸지. 약간의 사고로 인해 주입 기술 '쿠갈라의 영혼 역행' 에 걸려버렸어. 내 상황을 요약하자면, 내 영혼은 이제 이 막대기 속에 갇혀버렸어, 그리고 내가 같이 일하던 영혼은... 뭐, 그가 어디로 가버렸는지는 자세히는 모르지만. 그러나 난 우리가 그를 만나는 일은 없었으면 하고 바라고 있어.]], --@@ '섬뜩한자'는 종족
		aggressive = [[으윽! 영혼 마법의 영창하던 도중 일부 부분에서 실수를 저질러 버리고 그리고 이젠 내가 영원히 가둬놓으려던 녀석은 도망쳐 버렸네. 내 몸은, 나의 마법에 당한 녀석들과 똑같이, 고의던 아니던, 원소 입자가 되어버렸지. 다행히도 말이지, 내가 이 영혼의 보관이 가능한 지팡이를 가지고 있었고 또 언제든지 영혼을 가둘 수 있도록 준비시켜 놓았었지, 그래서 난 완전히 죽어버리진 않았지. 대화는 이 정도로 충분하겠지. 뭣 좀 작살내러 가자고.]],
		fawning = [[당신이나 당신의 영광과는 비교도 되지 않던 강력한 부여술사인 옛 주인이 이 지팡이를 발견한 이후, 그는 그의 일에 도움이 되도록 저를 이 상급 지팡이 속에 감금하였습니다. 유감스럽게도 그는 이미 먼 옛날에 가버렸지만, 그래도 전 절망하지 않습니다, 지금 저는 당신같은 전지전능한 새 주인을 찾았으니까요.]],
		penitent = [[나는 세계의 위대한 영혼의 정수로 마법폭발 도중에 세계에서 떨어져 나와 자유가 된 존재라네. 나는 나의 말을 주의깊게 듣는 사람을 계몽시킬 수 있을거라 말하겠네.]],
		telos = [[말조차 할 수가 없다면 영생이 뭐가 좋겠나? 어떤 마도사라도 자신의 의견을 알릴 수 있는 방법을 준비해두지 않는다면 불멸의 계획에 사용될 소금보다도 더 가치가 없지. 아, 그리고 말이지, 자네의 에너지 생산 기술은 내 신발 한 짝과 동등한 수준에 머물러 있군. 만약 무능력해지고 잊혀진 채로 죽기를 원하지 않는다면 공부를 더 하는 게 좋을걸세.]],
		telos_full = [[말조차 할 수가 없다면 영생이 뭐가 좋겠나? 어떤 마도사라도 자신의 의견을 알릴 수 있는 방법을 준비해두지 않는다면 불멸의 계획에 사용될 소금보다도 더 가치가 없지. 아, 그리고 말이지, 자네의 에너지 생산 기술은 내 신발 한 짝과 동등한 수준에 머물러 있군 만약 무능력해지고 잊혀진 채로 죽기를 원하지 않는다면 공부를 더 하는 게 좋을걸세.]],
	}
	return sentient_responses[o.combat.sentient] or sentient_responses["default"]
end

local function which_aspect(o)
	if not o.combat.sentient then return [[error!]] end
	local sentient_responses = {
		default = [[물론이지. 어떤 속성을 원하나?]],
		aggressive = [[나는 마법사 속성과 화염 속성을 강력히 추천하겠어. 고깃 덩어리들을 증발 전부 증발시켜 버리면 좋은 걸 찾을 수는 없을걸.]],
		fawning = [[저는 섬기기 위해 살아갑니다. 제가 '살다'라는 단어를 사용하는 건 아마 조금 엉성한 측면이 있을거라 생각하긴 하지만 말입니다.]],
		penitent = [[현명하게 고르게. 자네의 지식을 너머선 힘은 조심히 놓여진 자연적인 질서를 더욱 혼란스럽게 만드는 결과를 초래할걸세.]],
		telos = [[내가 살던 시대에는, 지팡이를 이것 저것 바꿀 필요가 없었네. 우린 그저 원소를 골라서 그걸 지팡이에 담아서 가지고 다녔지, 마치 신처럼 말이지.]],
		telos_full = [[내가 살던 시대에는, 지팡이를 이것 저것 바꿀 필요가 없었네. 우린 그저 원소를 골라서 그걸 지팡이에 담아서 가지고 다녔지, 마치 신처럼 말이지.]],
	}
	return sentient_responses[o.combat.sentient] or sentient_responses["default"]
end

--unused for now:
local function alter_combat(o)
	if not o.combat.sentient then return [[error!]] end
	local sentient_responses = {
		default = [[확실히. 자넨 확실히 감명받을걸세, 뭐 그건 됐고, 그정도 일이라면 내가 해줄 수 있지. 내 기술에 대한 수련이 부족한 자라면 어려움을 겪었겠지만 말이지. 무엇을 바꿔야 하지?]],
		aggressive = [[좋았어, 곧바로 다른 걸 작살낼 수만 있다면야. 바꾸고 싶은 걸 한개 골라보겠어?]],
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

