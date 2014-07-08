-- krTr AddOn

local _M = loadPrevious(...)

-- 바뀐 코드들과 원래 소스에서 그 위치(주석)
local base_randart_name_rules = _M.randart_name_rules -- #200~246 --@ 코드 변경된 곳은 없으나, generateRandart()에서 사용하는 local이어서 포함 필요
local base_generateRandart = _M.generateRandart -- #249~551
local base_spawnWorldAmbush = _M.spawnWorldAmbush -- #581~651
local base_random_zone_layouts = _M.random_zone_layouts -- #1416~1511
local base_random_zone_themes = _M.random_zone_themes -- #1513~1577
local base_createRandomZone = _M.createRandomZone -- #1579~1701
local base_createRandomBoss = _M.createRandomBoss -- #1832~1961

-- 기존 require들 포함 필요
require "engine.krtrUtils"
require "engine.class"
require "engine.Entity"
local Particles = require "engine.Particles"
local Shader = require "engine.Shader"
local Map = require "engine.Map"
local NameGenerator = require "engine.NameGenerator"
local NameGenerator2 = require "engine.NameGenerator2"
local Donation = require "mod.dialogs.Donation"

module(..., package.seeall, class.inherit(engine.Entity))


local randart_name_rules = {
	default2 = {
		phonemesVocals = "a, e, i, o, u, y",
		phonemesConsonants = "b, c, ch, ck, cz, d, dh, f, g, gh, h, j, k, kh, l, m, n, p, ph, q, r, rh, s, sh, t, th, ts, tz, v, w, x, z, zh",
		syllablesStart = "Aer, Al, Am, An, Ar, Arm, Arth, B, Bal, Bar, Be, Bel, Ber, Bok, Bor, Bran, Breg, Bren, Brod, Cam, Chal, Cham, Ch, Cuth, Dag, Daim, Dair, Del, Dr, Dur, Duv, Ear, Elen, Er, Erel, Erem, Fal, Ful, Gal, G, Get, Gil, Gor, Grin, Gun, H, Hal, Han, Har, Hath, Hett, Hur, Iss, Khel, K, Kor, Lel, Lor, M, Mal, Man, Mard, N, Ol, Radh, Rag, Relg, Rh, Run, Sam, Tarr, T, Tor, Tul, Tur, Ul, Ulf, Unr, Ur, Urth, Yar, Z, Zan, Zer",
		syllablesMiddle = "de, do, dra, du, duna, ga, go, hara, kaltho, la, latha, le, ma, nari, ra, re, rego, ro, rodda, romi, rui, sa, to, ya, zila",
		syllablesEnd = "bar, bers, blek, chak, chik, dan, dar, das, dig, dil, din, dir, dor, dur, fang, fast, gar, gas, gen, gorn, grim, gund, had, hek, hell, hir, hor, kan, kath, khad, kor, lach, lar, ldil, ldir, leg, len, lin, mas, mnir, ndil, ndur, neg, nik, ntir, rab, rach, rain, rak, ran, rand, rath, rek, rig, rim, rin, rion, sin, sta, stir, sus, tar, thad, thel, tir, von, vor, yon, zor",
		rules = "$s$v$35m$10m$e",
	},
	default = {
		phonemesVocals = "a, e, i, o, u, y",
		syllablesStart = "Ad, Aer, Ar, Bel, Bet, Beth, Ce'N, Cyr, Eilin, El, Em, Emel, G, Gl, Glor, Is, Isl, Iv, Lay, Lis, May, Ner, Pol, Por, Sal, Sil, Vel, Vor, X, Xan, Xer, Yv, Zub",
		syllablesMiddle = "bre, da, dhe, ga, lda, le, lra, mi, ra, ri, ria, re, se, ya",
		syllablesEnd = "ba, beth, da, kira, laith, lle, ma, mina, mira, na, nn, nne, nor, ra, rin, ssra, ta, th, tha, thra, tira, tta, vea, vena, we, wen, wyn",
		rules = "$s$v$35m$10m$e",
	},
	fire = {
		syllablesStart ="Phoenix, Stoke, Fire, Blaze, Burn, Bright, Sear, Heat, Scald, Hell, Hells, Inferno, Lava, Pyre, Furnace, Cinder, Singe, Flame, Scorch, Brand, Kindle, Flash, Smolder, Torch, Ash, Abyss, Char, Kiln, Sun, Magma, Flare",
		syllablesEnd = "arc, bane, bait, bile, biter, blast, bliss, blood, blow, bloom, butcher, blur, bolt, bone, bore, brace, braid, braze, breacher, breaker, breeze, brawn, burst, bringer, bearer, bender, blight, break, born, black, bright, crypt, crack, clash, clamor, cut, cast, cutter, dredge, dash, dream, dare, death, edge, envy, fury, fear, fame, foe, fiend, fist, gore, gash, gasher, grind, grinder, guile, grit, glean, glory, glamour, hack, hacker, hash, hue, hunger, hunt, hunter, ire, idol, immortal, justice, jeer, jam, kill, killer, kiss, 's kiss, karma, kin, king, knave, knight, lord, lore, lash, lace, lady, maim, mark, moon, master, mistress, mire, monster, might, marrow, mortal, minister, malice, naught, null, noon, nail, nigh, night, oath, order, oracle, oozer, obeisance, oblivion, onslaught, obsidian, peal, parry, power, python, prophet, pain, passion, pierce, piercer, pride, pulverizer, piety, panic, pain, punish, pall, quench, quencher, quake, quarry, queen, quell, queller, quick, quill, reaper, ravage, ravager, raze, razor, roar, rage, race, radiance, raider, rain, rot, ransom, rune, reign, rupture, ream, rebel, raven, river, ripper, rip, ripper, rock, reek, reeve, resolve, rigor, rend, raptor, shine, slice, slicer, spar, spawn, spawner, spitter, squall, steel, stoker, snake, sorrow, sage, stake, serpent, shear, sin, spire, stalker, shaper, strider, streak, streaker, saw, scar, schism, star, streak, sting, stinger, strike, striker, stun, sun, sweep, sweeper, swift, stone, seam, sever, smash, smasher, spike, spiker, thorn, terror, touch, tide, torrent, trial, typhoon, titan, tickler, tooth, treason, trencher, taint, trail, umbra, usher, valor, vagrant, vile, vein, veil, venom, viper, vault, vengeance, vortex, vice, wrack, walker, wake, waker, war, ward, warden, wasp, weeper, wedge, wend, well, whisper, wild, wilder, will, wind, wilter, wing, winnow, winter, wire, wisp, wish, witch, wolf, woe, wither, witherer, worm, wreath, worth, wreck, wrecker, wrest, writher, wyrd, zeal, zephyr",
		rules = "$s$e",
	},
	cold = {
		syllablesStart ="Frost, Ice, Freeze, Sleet, Snow, Chill, Shiver, Winter, Blizzard, Glacier, Tundra, Floe, Hail, Frozen, Frigid, Rime, Haze, Rain, Tide, Quench",
		syllablesEnd = "arc, bane, bait, bile, biter, blast, bliss, blood, blow, bloom, butcher, blur, bolt, bone, bore, brace, braid, braze, breacher, breaker, breeze, brawn, burst, bringer, bearer, bender, blight, brand, break, born, black, bright, crypt, crack, clash, clamor, cut, cast, cutter, dredge, dash, dream, dare, death, edge, envy, fury, fear, fame, foe, furnace, flash, fiend, fist, gore, gash, gasher, grind, grinder, guile, grit, glean, glory, glamour, hack, hacker, hash, hue, hunger, hunt, hunter, ire, idol, immortal, justice, jeer, jam, kill, killer, kiss, 's kiss, karma, kin, king, knave, knight, lord, lore, lash, lace, lady, maim, mark, moon, master, mistress, mire, monster, might, marrow, mortal, minister, malice, naught, null, noon, nail, nigh, night, oath, order, oracle, oozer, obeisance, oblivion, onslaught, obsidian, peal, pyre, parry, power, python, prophet, pain, passion, pierce, piercer, pride, pulverizer, piety, panic, pain, punish, pall, quench, quencher, quake, quarry, queen, quell, queller, quick, quill, reaper, ravage, ravager, raze, razor, roar, rage, race, radiance, raider, rain, rot, ransom, rune, reign, rupture, ream, rebel, raven, river, ripper, rip, ripper, rock, reek, reeve, resolve, rigor, rend, raptor, shine, slice, slicer, spar, spawn, spawner, spitter, squall, steel, stoker, snake, sorrow, sage, stake, serpent, shear, sin, sear, spire, stalker, shaper, strider, streak, streaker, saw, scar, schism, star, streak, sting, stinger, strike, striker, stun, sun, sweep, sweeper, swift, stone, seam, sever, smash, smasher, spike, spiker, thorn, terror, touch, tide, torrent, trial, typhoon, titan, tickler, tooth, treason, trencher, taint, trail, umbra, usher, valor, vagrant, vile, vein, veil, venom, viper, vault, vengeance, vortex, vice, wrack, walker, wake, waker, war, ward, warden, wasp, weeper, wedge, wend, well, whisper, wild, wilder, will, wind, wilter, wing, winnow, wire, wisp, wish, witch, wolf, woe, wither, witherer, worm, wreath, worth, wreck, wrecker, wrest, writher, wyrd, zeal, zephyr",
		rules = "$s$e",
	},
	lightning = {
		syllablesStart ="Tempest, Storm, Lightning, Arc, Shock, Thunder, Charge, Cloud, Air, Nimbus, Gale, Crackle, Shimmer, Flash, Spark, Blast, Blaze, Strike, Sky, Bolt",
		syllablesEnd = "bane, bait, bile, biter, blast, bliss, blood, blow, bloom, butcher, blur, bone, bore, brace, braid, braze, breacher, breaker, breeze, brawn, burst, bringer, bearer, bender, blight, brand, break, born, black, bright, crypt, crack, clash, clamor, cut, cast, cutter, dredge, dash, dream, dare, death, edge, envy, fury, fear, fame, foe, furnace, flash, fiend, fist, gore, gash, gasher, grind, grinder, guile, grit, glean, glory, glamour, hack, hacker, hash, hue, hunger, hunt, hunter, ire, idol, immortal, justice, jeer, jam, kill, killer, kiss, 's kiss, karma, kin, king, knave, knight, lord, lore, lash, lace, lady, maim, mark, moon, master, mistress, mire, monster, might, marrow, mortal, minister, malice, naught, null, noon, nail, nigh, night, oath, order, oracle, oozer, obeisance, oblivion, onslaught, obsidian, peal, pyre, parry, power, python, prophet, pain, passion, pierce, piercer, pride, pulverizer, piety, panic, pain, punish, pall, quench, quencher, quake, quarry, queen, quell, queller, quick, quill, reaper, ravage, ravager, raze, razor, roar, rage, race, radiance, raider, rain, rot, ransom, rune, reign, rupture, ream, rebel, raven, river, ripper, rip, ripper, rock, reek, reeve, resolve, rigor, rend, raptor, shine, slice, slicer, spar, spawn, spawner, spitter, squall, steel, stoker, snake, sorrow, sage, stake, serpent, shear, sin, sear, spire, stalker, shaper, strider, streak, streaker, saw, scar, schism, star, streak, sting, stinger, stun, sun, sweep, sweeper, swift, stone, seam, sever, smash, smasher, spike, spiker, thorn, terror, touch, tide, torrent, trial, typhoon, titan, tickler, tooth, treason, trencher, taint, trail, umbra, usher, valor, vagrant, vile, vein, veil, venom, viper, vault, vengeance, vortex, vice, wrack, walker, wake, waker, war, ward, warden, wasp, weeper, wedge, wend, well, whisper, wild, wilder, will, wind, wilter, wing, winnow, winter, wire, wisp, wish, witch, wolf, woe, wither, witherer, worm, wreath, worth, wreck, wrecker, wrest, writher, wyrd, zeal, zephyr",
		rules = "$s$e",
	},
	light = {
		syllablesStart ="Light, Shine, Day, Sun, Morning, Star, Blaze, Glow, Gleam, Bright, Prism, Dazzle, Glint, Dawn, Noon, Glare, Flash, Radiance, Blind, Glimmer, Splendour, Glitter, Kindle, Lustre",
		syllablesEnd = "arc, bane, bait, bile, biter, blast, bliss, blood, blow, bloom, butcher, blur, bolt, bone, bore, brace, braid, braze, breacher, breaker, breeze, brawn, burst, bringer, bearer, bender, blight, brand, break, born, black, bright, crypt, crack, clash, clamor, cut, cast, cutter, dredge, dash, dream, dare, death, edge, envy, fury, fear, fame, foe, furnace, fiend, fist, gore, gash, gasher, grind, grinder, guile, grit, glean, glory, glamour, hack, hacker, hash, hue, hunger, hunt, hunter, ire, idol, immortal, justice, jeer, jam, kill, killer, kiss, 's kiss, karma, kin, king, knave, knight, lord, lore, lash, lace, lady, maim, mark, moon, master, mistress, mire, monster, might, marrow, mortal, minister, malice, naught, null, nail, nigh, night, oath, order, oracle, oozer, obeisance, oblivion, onslaught, obsidian, peal, pyre, parry, power, python, prophet, pain, passion, pierce, piercer, pride, pulverizer, piety, panic, pain, punish, pall, quench, quencher, quake, quarry, queen, quell, queller, quick, quill, reaper, ravage, ravager, raze, razor, roar, rage, race, radiance, raider, rain, rot, ransom, rune, reign, rupture, ream, rebel, raven, river, ripper, rip, ripper, rock, reek, reeve, resolve, rigor, rend, raptor, shine, slice, slicer, spar, spawn, spawner, spitter, squall, steel, stoker, snake, sorrow, sage, stake, serpent, shear, sin, sear, spire, stalker, shaper, strider, streak, streaker, saw, scar, schism, streak, sting, stinger, strike, striker, stun, sweep, sweeper, swift, stone, seam, sever, smash, smasher, spike, spiker, thorn, terror, touch, tide, torrent, trial, typhoon, titan, tickler, tooth, treason, trencher, taint, trail, umbra, usher, valor, vagrant, vile, vein, veil, venom, viper, vault, vengeance, vortex, vice, wrack, walker, wake, waker, war, ward, warden, wasp, weeper, wedge, wend, well, whisper, wild, wilder, will, wind, wilter, wing, winnow, winter, wire, wisp, wish, witch, wolf, woe, wither, witherer, worm, wreath, worth, wreck, wrecker, wrest, writher, wyrd, zeal, zephyr",
		rules = "$s$e",
	},
	dark = {
		syllablesStart ="Night, Umbra, Void, Dark, Gloom, Woe, Dour, Shade, Dusk, Murk, Bleak, Dim, Soot, Pitch, Fog, Black, Coal, Ebony, Shadow, Obsidian, Raven, Jet, Demon, Duathel, Unlight, Eclipse, Blind, Deeps",
		syllablesEnd = "arc, bane, bait, bile, biter, blast, bliss, blood, blow, bloom, butcher, blur, bolt, bone, bore, brace, braid, braze, breacher, breaker, breeze, brawn, burst, bringer, bearer, bender, blight, brand, break, born, bright, crypt, crack, clash, clamor, cut, cast, cutter, dredge, dash, dream, dare, death, edge, envy, fury, fear, fame, foe, furnace, flash, fiend, fist, gore, gash, gasher, grind, grinder, guile, grit, glean, glory, glamour, hack, hacker, hash, hue, hunger, hunt, hunter, ire, idol, immortal, justice, jeer, jam, kill, killer, kiss, 's kiss, karma, kin, king, knave, knight, lord, lore, lash, lace, lady, maim, mark, moon, master, mistress, mire, monster, might, marrow, mortal, minister, malice, naught, null, noon, nail, nigh, oath, order, oracle, oozer, obeisance, oblivion, onslaught, obsidian, peal, pyre, parry, power, python, prophet, pain, passion, pierce, piercer, pride, pulverizer, piety, panic, pain, punish, pall, quench, quencher, quake, quarry, queen, quell, queller, quick, quill, reaper, ravage, ravager, raze, razor, roar, rage, race, radiance, raider, rain, rot, ransom, rune, reign, rupture, ream, rebel, raven, river, ripper, rip, ripper, rock, reek, reeve, resolve, rigor, rend, raptor, shine, slice, slicer, spar, spawn, spawner, spitter, squall, steel, stoker, snake, sorrow, sage, stake, serpent, shear, sin, sear, spire, stalker, shaper, strider, streak, streaker, saw, scar, schism, star, streak, sting, stinger, strike, striker, stun, sun, sweep, sweeper, swift, stone, seam, sever, smash, smasher, spike, spiker, thorn, terror, touch, tide, torrent, trial, typhoon, titan, tickler, tooth, treason, trencher, taint, trail, usher, valor, vagrant, vile, vein, veil, venom, viper, vault, vengeance, vortex, vice, wrack, walker, wake, waker, war, ward, warden, wasp, weeper, wedge, wend, well, whisper, wild, wilder, will, wind, wilter, wing, winnow, winter, wire, wisp, wish, witch, wolf, wither, witherer, worm, wreath, worth, wreck, wrecker, wrest, writher, wyrd, zeal, zephyr",
		rules = "$s$e",
	},
	nature = {
		syllablesStart ="Nature, Green, Loam, Earth, Heal, Root, Growth, Grow, Bark, Bloom, Satyr, Rain, Pure, Wild, Wind, Cure, Cleanse, Forest, Breeze, Oak, Willow, Tree, Balance, Flower, Ichor, Offal, Rot, Scab, Squalor, Taint, Undeath, Vile, Weep, Plague, Pox, Pus, Gore, Sepsis, Corruption, Filth, Muck, Fester, Toxin, Venom, Scorpion, Serpent, Viper, Cobra, Sulfur, Mire, Ooze, Wretch, Carrion, Bile, Bog, Sewer, Swamp, Corpse, Scum, Mold, Spider, Phlegm, Mucus, Morbus, Murk, Smear, Cyst",
		syllablesEnd = "arc, bane, bait, bile, biter, blast, bliss, blood, blow, bloom, butcher, blur, bolt, bone, bore, brace, braid, braze, breacher, breaker, brawn, burst, bringer, bearer, bender, blight, brand, break, born, black, bright, crypt, crack, clash, clamor, cut, cast, cutter, dredge, dash, dream, dare, death, edge, envy, fury, fear, fame, foe, furnace, flash, fiend, fist, gore, gash, gasher, grind, grinder, guile, grit, glean, glory, glamour, hack, hacker, hash, hue, hunger, hunt, hunter, ire, idol, immortal, justice, jeer, jam, kill, killer, kiss, 's kiss, karma, kin, king, knave, knight, lord, lore, lash, lace, lady, maim, mark, moon, master, mistress, mire, monster, might, marrow, mortal, minister, malice, naught, null, noon, nail, nigh, night, oath, order, oracle, oozer, obeisance, oblivion, onslaught, obsidian, peal, pyre, parry, power, python, prophet, pain, passion, pierce, piercer, pride, pulverizer, piety, panic, pain, punish, pall, quench, quencher, quake, quarry, queen, quell, queller, quick, quill, reaper, ravage, ravager, raze, razor, roar, rage, race, radiance, raider, rot, ransom, rune, reign, rupture, ream, rebel, raven, river, ripper, rip, ripper, rock, reek, reeve, resolve, rigor, rend, raptor, shine, slice, slicer, spar, spawn, spawner, spitter, squall, steel, stoker, snake, sorrow, sage, stake, serpent, shear, sin, sear, spire, stalker, shaper, strider, streak, streaker, saw, scar, schism, star, streak, sting, stinger, strike, striker, stun, sun, sweep, sweeper, swift, stone, seam, sever, smash, smasher, spike, spiker, thorn, terror, touch, tide, torrent, trial, typhoon, titan, tickler, tooth, treason, trencher, taint, trail, umbra, usher, valor, vagrant, vile, vein, veil, venom, viper, vault, vengeance, vortex, vice, wrack, walker, wake, waker, war, ward, warden, wasp, weeper, wedge, wend, well, whisper, wild, wilder, will, wind, wilter, wing, winnow, winter, wire, wisp, wish, witch, wolf, woe, wither, witherer, worm, wreath, worth, wreck, wrecker, wrest, writher, wyrd, zeal, zephyr,",
		rules = "$s$e",
	},
}

function _M:generateRandart(data)
	-- Setup level
	local lev = data.lev or rng.range(12, 50)
	local oldlev = game.level.level
	local oldclev = resolvers.current_level
	game.level.level = lev
	resolvers.current_level = math.ceil(lev * 1.4)

	-- Get a base object
	local base = data.base or game.zone:makeEntity(game.level, "object", data.base_filter or {ignore_material_restriction=true, no_tome_drops=true, ego_filter={keep_egos=true, ego_chance=-1000}, special=function(e)
		return (not e.unique and e.randart_able) and (not e.material_level or e.material_level >= 2) and true or false
	end}, nil, true)
	if not base then game.level.level = oldlev resolvers.current_level = oldclev return end
	local o = base:cloneFull()

	local powers_list = engine.Object:loadList(o.randart_able, nil, nil, function(e) if e.rarity then e.rarity = math.ceil(e.rarity / 5) end end)
	o.randart_able = nil
	
	local nb_themes = data.nb_themes
	if not nb_themes then -- Gradually increase number of themes at higher levels so there are enough powers to spend points on
		nb_themes = math.max(2,5*lev/(lev+50)) -- Maximum 5 themes possible
		nb_themes= math.floor(nb_themes) + (rng.percent((nb_themes-math.floor(nb_themes))*100) and 1 or 0)
	end
	local allthemes = {
		'physical', 'mental', 'spell', 'defense', 'misc', 'fire',
		'lightning', 'acid', 'mind', 'arcane', 'blight', 'nature',
		'temporal', 'light', 'dark', 'antimagic'
	}
	local themes = {}
	if data.force_themes then
		for i, v in ipairs(data.force_themes) do
			table.removeFromList(allthemes, v)
			themes[v] = true
			if v == 'antimagic' then table.removeFromList(allthemes, 'spell', 'arcane', 'blight', 'temporal') end
			if v == 'spell' or v == 'arcane' or v == 'blight' or v == 'temporal' then table.removeFromList(allthemes, 'antimagic') end
		end
	end
	for i = #themes + 1, (nb_themes or 2) do
		if #allthemes == 0 then break end
		local v = rng.tableRemove(allthemes)
		themes[v] = true
		if v == 'antimagic' then table.removeFromList(allthemes, 'spell', 'arcane', 'blight', 'temporal') end
		if v == 'spell' or v == 'arcane' or v == 'blight' or v == 'temporal' then table.removeFromList(allthemes, 'antimagic') end
	end
	local themes_fct = function(e)
		for theme, _ in pairs(e.theme) do if themes[theme] then return true end end
		return false
	end

	-----------------------------------------------------------
	-- Determine power
	-----------------------------------------------------------
	-- 	Note double diminishing returns when coupled with scaling factor in merger (below)
	-- Maintains randomness throughout level range ~50% variability in points
	local points = math.ceil(0.1*lev^0.75*(8 + rng.range(1, 7)) * (data.power_points_factor or 1))+(data.nb_points_add or 0)
	local nb_powers = 1 + rng.dice(math.max(1, math.ceil(0.281*lev^0.6)), 2) + (data.nb_powers_add or 0)
	local powers = {}
	print("Randart generation:", "level = ", lev, "points = ",points, "nb_powers = ",nb_powers)

	o.cost = o.cost + points * 7
	-- Select some powers
	local power_themes = {}
	local lst = game.zone:computeRarities("powers", powers_list, game.level, themes_fct) --Note: probabilities diminish as level exceeds 50 (limited to ~1000 by updated game.zone:computeRarities function)
	
	for i = 1, nb_powers do
		local p = game.zone:pickEntity(lst)
		if p then
			for t, _ in pairs(p.theme) do if themes[t] and randart_name_rules[t] then power_themes[t] = (power_themes[t] or 0) + 1 end end
			powers[p.name] = p:clone()
			powers[#powers+1] = powers[p.name]
		end
	end
--	print("Selected powers:") table.print(powers)
	power_themes = table.listify(power_themes)
	table.sort(power_themes, function(a, b) return a[2] < b[2] end)

	-----------------------------------------------------------
	-- Make up a name
	-----------------------------------------------------------
	--@ 새 물건 랜덤 이름 결정 부분 - 통채 kr_name도 조합하도록 수정 -> 실제 이름 덮어쓰는 부분은 200줄 뒤(현재 529)
	--@ 새로 랜덤하게 덧붙는 이름의 한글화시 이 부분 수정 필요
	local themename = power_themes[#power_themes]
	themename = themename and themename[1] or nil
	local ngd = NameGenerator.new(rng.chance(2) and randart_name_rules.default or randart_name_rules.default2)
	local ngt = (themename and randart_name_rules[themename] and NameGenerator.new(randart_name_rules[themename])) or ngd
	local name, krName --@ 한글이름 변수 생성
	local namescheme = data.namescheme or ((ngt ~= ngd) and rng.range(1, 4) or rng.range(1, 3))
	if namescheme == 1 then
		local ngtg = ngt:generate() --@ 랜덤한 이름을 일단 변수에 저장 (원문이름과 한글이름에 같은 단어가 들어 갈 수 있도록)
		name = o.name.." '"..ngtg.."'"
		krName = (o.kr_name or o.name).." '"..ngtg.."'" --@ 한글 이름 조합
	elseif namescheme == 2 then
		local ngtg = ngt:generate() --@ 랜덤한 이름을 일단 변수에 저장 (원문이름과 한글이름에 같은 단어가 들어 갈 수 있도록)
		name = ngtg.." the "..o.name
		krName = ngtg.." "..(o.kr_name or o.name) --@ 한글 이름 조합
	elseif namescheme == 3 then
		name = ngt:generate()
		krName = name --@ 한글 이름 조합
	elseif namescheme == 4 then
		local ngtg = ngt:generate() --@ 랜덤한 이름을 일단 변수에 저장 (원문이름과 한글이름에 같은 단어가 들어 갈 수 있도록)
		local ngdg = ngd:generate() --@ 랜덤한 이름을 일단 변수에 저장 (원문이름과 한글이름에 같은 단어가 들어 갈 수 있도록)
		name = ngdg.." the "..ngtg
		krName = ngdg.." "..ngtg --@ 한글 이름 조합
	end
	o.define_as = name:upper():gsub("[^A-Z]", "_")

	local rnts = rng.table{"glowing","scintillating","rune-covered","unblemished","jewel-encrusted","humming","gleaming","immaculate","flawless","crackling","glistening","plated","twisted","silvered","faceted","faded","sigiled","shadowy","laminated"} --@ 랜덤한 수식어를 변수로 저장 (원문과 한글이 같도록)
	o.kr_unided_name = rnts:krUnIDPreName().." "..(o.kr_unided_name or o.unided_name or o.kr_name or o.name) --@ 미감정시 한글이름 조합
	o.unided_name = rnts.." "..(o.unided_name or o.name)	
	o.unique = name --@ unique는 게임 도중에 사용하는 곳이 있나? 코드 번역 확인 필요
	o.randart = true
	o.no_unique_lore = true
	o.rarity = rng.range(200, 290)

	print("Creating randart "..name.."("..o.unided_name..") with "..(themename or "nil").." with level "..lev)
	print(" * using themes", table.concat(table.keys(themes), ','))

	-----------------------------------------------------------
	-- Add ego properties
	-----------------------------------------------------------
	local nb_egos = data.egos or 3
	local gr_egos = data.greater_egos_bias or math.floor(nb_egos*2/3) -- 2/3 greater egos by default
	if o.egos and nb_egos > 0 then
		local picked_egos = {}
		local legos = {}
		local been_greater = 0
		table.insert(legos, game.level:getEntitiesList("object/"..o.egos..":prefix"))
		table.insert(legos, game.level:getEntitiesList("object/"..o.egos..":suffix"))
		table.insert(legos, game.level:getEntitiesList("object/"..o.egos..":"))
		for i = 1, nb_egos or 3 do
			local egos = rng.table(legos)
			local list = {}
			local filter = nil
			if rng.percent(100*lev/(lev+50)) and been_greater < gr_egos then been_greater = been_greater + 1 filter = function(e) return e.greater_ego end end --RE Phase out (but don't eliminate) lesser egos with level
			for z = 1, #egos do list[#list+1] = egos[z].e end

			local ef = self:egoFilter(game.zone, game.level, "object", "randartego", o, {special=filter, forbid_power_source=data.forbid_power_source, power_source=data.power_source}, picked_egos, {})
			filter = ef.special

			local pick_egos = game.zone:computeRarities("object", list, game.level, filter, nil, nil)
			local ego = game.zone:pickEntity(pick_egos)
			if ego then
				table.insert(picked_egos, ego)
--				print(" ** selected ego", ego.name)
				ego = ego:clone()
				if ego.instant_resolve then ego:resolve(nil, nil, o) end -- Don't allow resolvers.generic here (conflict)
				ego.instant_resolve = nil
				ego.uid = nil
				ego.name = nil
				ego.unided_name = nil
				ego.kr_name = nil --@ 혹시 몰라 추가
				ego.kr_unided_name = nil --@ 혹시 몰라 추가

				-- OMFG this is ugly, there is a very rare combinaison that can result in a crash there, so we .. well, ignore it :/
				-- Sorry.
				local ok, err = pcall(table.mergeAddAppendArray, o, ego, true)
				if not ok then
					print("table.mergeAddAppendArray failed at creating a randart, retrying")
					game.level.level = oldlev
					resolvers.current_level = oldclev
					return self:generateRandart(data)
				end
			end
		end
		o.egos = nil o.egos_chance = nil o.force_ego = nil
	end
	-- Re-resolve with the (possibly) new resolvers
	o:resolve()
	o:resolve(nil, true)

	-----------------------------------------------------------
	-- Imbue powers in the randart
	-----------------------------------------------------------
	local function merger(dst, src, scale) --scale: factor to adjust power limits for levels higher than 50
		scale = scale or 1
		for k, e in pairs(src) do
			if type(e) == "table" then
				if e.__resolver and e.__resolver == "randartmax" then
					dst[k] = (dst[k] or 0) + e.v
					if e.max < 0 then
						if dst[k] < e.max * scale then --Adjust maximum values for higher levels
							dst[k] = math.floor(e.max * scale)
						end
					else
						if dst[k] > e.max * scale then --Adjust maximum values for higher levels
							dst[k] = math.floor(e.max * scale)
						end
					end
				else
					if not dst[k] then dst[k] = {} end
					merger(dst[k], e, scale)
				end
			elseif type(e) == "number" then
				dst[k] = (dst[k] or 0) + e
			else
				error("Type "..type(e).. " for randart property unsupported!")
			end
		end
	end

	-- Distribute points
	local hpoints = math.ceil(points / 2)
	local i = 0
	local fails = 0
	while hpoints > 0 and #powers >0 and fails <= #powers do
		i = util.boundWrap(i + 1, 1, #powers)
		local p = powers[i]
		if p and p.points <= hpoints*2 then -- Intentionally allow the budget to be exceeded slightly to guarantee powers at low levels
			local scaleup = math.max(1,(lev/(p.level_range[2] or 50))^0.5) --Adjust scaleup factor for each power based on lev and level_range max
--			print(" * adding power: "..p.name.."("..p.points.." points)")
			if p.wielder then
				o.wielder = o.wielder or {}
				merger(o.wielder, p.wielder, scaleup)
			end
			if p.combat then
				o.combat = o.combat or {}
				merger(o.combat, p.combat, scaleup)
			end
			if p.special_combat then
				o.special_combat = o.special_combat or {}
				merger(o.special_combat, p.special_combat, scaleup)
			end
			if p.copy then merger(o, p.copy, scaleup) end 
			hpoints = hpoints - p.points 
			p.points = p.points * 1.5 --increased cost (=diminishing returns) on extra applications of the same power
		else
			fails = fails + 1
		end
	end
	o:resolve() o:resolve(nil, true)

	-- Bias toward some powers
	local bias_powers = {}
	local nb_bias = math.max(1,rng.range(math.ceil(#powers/2), 20*lev /(lev+50))) --Limit bias powers to 20 (50/5 * 2) powers
	for i = 1, nb_bias do bias_powers[#bias_powers+1] = rng.table(powers) end
	local hpoints = math.ceil(points / 2)
	local i = 0
	fails = 0 
	while hpoints > 0 and fails <= #bias_powers do
		i = util.boundWrap(i + 1, 1, #bias_powers)

		local p = bias_powers[i] and bias_powers[i]
		if p and p.points <= hpoints * 2 then
			local scaleup = math.max(1,(lev/(p.level_range[2] or 50))^0.5) -- Adjust scaleup factor for each power based on lev and level_range max
			if p.wielder then
				o.wielder = o.wielder or {}
				merger(o.wielder, p.wielder, scaleup)
			end
			if p.combat then
				o.combat = o.combat or {}
				merger(o.combat, p.combat, scaleup)
			end
			if p.special_combat then
				o.special_combat = o.special_combat or {}
				merger(o.special_combat, p.special_combat, scaleup)
			end
			if p.copy then merger(o, p.copy, scaleup) end
--			print(" * adding bias power: "..p.name.."("..p.points.." points)")
			hpoints = hpoints - p.points
			p.points = p.points * 1.5 --increased cost (=diminishing returns) on extra applications of the same power
		else
			fails = fails + 1
		end
	end

	-- Power source if none
	if not o.power_source then
		local ps = {}
		if themes.physical or themes.defense then ps.technique = true end
		if themes.mental then ps[rng.percent(50) and 'nature' or 'psionic'] = true end
		if themes.spell or themes.arcane or themes.blight or themes.temporal then ps.arcane = true end
		if themes.nature then ps.nature = true end
		if themes.antimagic then ps.antimagic = true end
		if not next(ps) then ps[rng.table{'technique','nature','arcane','psionic','antimagic'}] = true end
		o.power_source = ps
	end

	-- Setup the name
	o.name = name
	o.kr_name = krName --@ 만들어진 한글 이름 저장

	local theme_map = {
		physical = engine.DamageType.PHYSICAL,
		--mental = engine.DamageType.MIND,
		fire = engine.DamageType.FIRE,
		lightning = engine.DamageType.LIGHTNING,
		acid = engine.DamageType.ACID,
		mind = engine.DamageType.MIND,
		arcane = engine.DamageType.ARCANE,
		blight = engine.DamageType.BLIGHT,
		nature = engine.DamageType.NATURE,
		temporal = engine.DamageType.TEMPORAL,
		light = engine.DamageType.LIGHT,
		dark = engine.DamageType.DARK,
	}

	local pickDamtype = function(themes_list)
		if not rng.percent(18) then return engine.DamageType.PHYSICAL end
			for k, v in pairs(themes_list) do
				if theme_map[k] then return theme_map[k] end
			end
		return engine.DamageType.PHYSICAL
	end

	if o and o.combat and not (o.subtype and o.subtype == "staff") and not (o.subtype and o.subtype == "mindstar") then o.combat.damtype = pickDamtype(themes) end

	if data.post then
		data.post(o)
	end

	if data.add_pool then self:addWorldArtifact(o) end

	game.level.level = oldlev
	resolvers.current_level = oldclev
	return o
end

function _M:spawnWorldAmbush(enc, dx, dy, kind)
	game:onTickEnd(function()

	local gen = { class = "engine.generator.map.Forest",
		edge_entrances = {4,6},
		sqrt_percent = 50,
		zoom = 10,
		floor = "GRASS",
		wall = "TREE",
		down = "DOWN",
		up = "GRASS_UP_WILDERNESS",
	}
	local g1 = game.level.map(dx, dy, engine.Map.TERRAIN)
	local g2 = game.level.map(game.player.x, game.player.y, engine.Map.TERRAIN)
	local g = g1
	if not g or not g.can_encounter then g = g2 end
	if not g or not g.can_encounter then return false end

	if g.can_encounter == "desert" then gen.floor = "SAND" gen.wall = "PALMTREE" end

	local terrains = mod.class.Grid:loadList{"/data/general/grids/basic.lua", "/data/general/grids/forest.lua", "/data/general/grids/sand.lua"}
	terrains[gen.up].change_level_shift_back = true

	local zone = mod.class.Zone.new("ambush", {
		name = "Ambush!",
		kr_name = "습격!",
		level_range = {game.player.level, game.player.level},
		level_scheme = "player",
		max_level = 1,
		actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
		width = enc.width or 20, height = enc.height or 20,
--		no_worldport = true,
		all_lited = true,
		ambient_music = "last",
		max_material_level = util.bound(math.ceil(game.player.level / 10), 1, 5),
		min_material_level = util.bound(math.ceil(game.player.level / 10), 1, 5) - 1,
		generator =  {
			map = gen,
			actor = { class = "mod.class.generator.actor.Random", nb_npc = enc.nb or {1,1}, filters=enc.filters },
		},

		reload_lists = false,
		npc_list = mod.class.NPC:loadList("/data/general/npcs/all.lua", nil, nil, function(e) e.make_escort=nil end),
		grid_list = terrains,
		object_list = mod.class.Object:loadList("/data/general/objects/objects.lua"),
		trap_list = {},
		post_process = function(level)
			-- Find a good starting location, on the opposite side of the exit
			local sx, sy = level.map.w-1, rng.range(0, level.map.h-1)
			level.spots[#level.spots+1] = {
				check_connectivity = "entrance",
				x = sx,
				y = sy,
			}
			level.default_down = level.default_up
			level.default_up = {x=sx, y=sy}
		end,
	})
	self.farm_factor = self.farm_factor or {}
	self.farm_factor[kind] = self.farm_factor[kind] or 1
	zone.objects_cost_modifier = self.farm_factor[kind]
	zone.exp_worth_mult = self.farm_factor[kind]

	self.farm_factor[kind] = self.farm_factor[kind] * 0.9

	game.player:runStop()
	game.player.energy.value = game.energy_to_act
	game.paused = true
	game:changeLevel(1, zone, {temporary_zone_shift=true})
	engine.ui.Dialog:simplePopup("습격!", "습격당했습니다!")

	end)
end

local random_zone_layouts = {
	-- Forest
	{ name="forest", kr_name="숲", rarity=3, gen=function(data) return {
		class = "engine.generator.map.Forest",
		edge_entrances = {data.less_dir, data.more_dir},
		zoom = rng.range(2,6),
		sqrt_percent = rng.range(20, 50),
		noise = "fbm_perlin",
		floor = data:getFloor(),
		wall = data:getWall(),
		up = data:getUp(),
		down = data:getDown(),
	} end },
	-- Cavern
	{ name="cavern", kr_name="동굴", rarity=3, gen=function(data)
		local floors = data.w * data.h * 0.4
		return {
		class = "engine.generator.map.Cavern",
		zoom = rng.range(10, 20),
		min_floor = rng.range(floors / 2, floors),
		floor = data:getFloor(),
		wall = data:getWall(),
		up = data:getUp(),
		down = data:getDown(),
	} end },
	-- Rooms
	{ name="rooms", kr_name="방", rarity=3, gen=function(data)
		local rooms = {"random_room"}
		if rng.percent(30) then rooms = {"forest_clearing"} end
		return {
		class = "engine.generator.map.Roomer",
		nb_rooms = math.floor(data.w * data.h / 250),
		rooms = rooms,
		lite_room_chance = rng.range(0, 100),
		['.'] = data:getFloor(),
		['#'] = data:getWall(),
		up = data:getUp(),
		down = data:getDown(),
		door = data:getDoor(),
	} end },
	-- Maze
	{ name="maze", kr_name="미로", rarity=3, gen=function(data)
		return {
		class = "engine.generator.map.Maze",
		floor = data:getFloor(),
		wall = data:getWall(),
		up = data:getUp(),
		down = data:getDown(),
		door = data:getDoor(),
	} end, guardian_alert=true },
	-- Sets
	{ name="sets", kr_name="시설", rarity=3, gen=function(data)
		local set = rng.table{
			{"3x3/base", "3x3/tunnel", "3x3/windy_tunnel"},
			{"5x5/base", "5x5/tunnel", "5x5/windy_tunnel", "5x5/crypt"},
			{"7x7/base", "7x7/tunnel"},
		}
		return {
		class = "engine.generator.map.TileSet",
		tileset = set,
		['.'] = data:getFloor(),
		['#'] = data:getWall(),
		up = data:getUp(),
		down = data:getDown(),
		door = data:getDoor(),
		["'"] = data:getDoor(),
	} end },
	-- Building
--[[ not yet	{ name="building", kr_name="건물", rarity=4, gen=function(data)
		return {
		class = "engine.generator.map.Building",
		lite_room_chance = rng.range(0, 100),
		max_block_w = rng.range(14, 20), max_block_h = rng.range(14, 20),
		max_building_w = rng.range(4, 8), max_building_h = rng.range(4, 8),
		floor = data:getFloor(),
		wall = data:getWall(),
		up = data:getUp(),
		down = data:getDown(),
		door = data:getDoor(),
	} end },
]]
	-- "Octopus"
	{ name="octopus", kr_name="문어", rarity=6, gen=function(data)
		return {
		class = "engine.generator.map.Octopus",
		main_radius = {0.3, 0.4},
		arms_radius = {0.1, 0.2},
		arms_range = {0.7, 0.8},
		nb_rooms = {5, 9},
		['.'] = data:getFloor(),
		['#'] = data:getWall(),
		up = data:getUp(),
		down = data:getDown(),
		door = data:getDoor(),
	} end },
}

local random_zone_themes = {
	-- Trees
	{ name="trees", kr_name="나무", rarity=3, gen=function() return {
		load_grids = {"/data/general/grids/forest.lua"},
		getDoor = function(self) return "GRASS" end,
		getFloor = function(self) return function() if rng.chance(20) then return "FLOWER" else return "GRASS" end end end,
		getWall = function(self) return "TREE" end,
		getUp = function(self) return "GRASS_UP"..self.less_dir end,
		getDown = function(self) return "GRASS_DOWN"..self.more_dir end,
	} end },
	-- Walls
	{ name="walls", kr_name="벽", rarity=2, gen=function() return {
		load_grids = {"/data/general/grids/basic.lua"},
		getDoor = function(self) return "DOOR" end,
		getFloor = function(self) return "FLOOR" end,
		getWall = function(self) return "WALL" end,
		getUp = function(self) return "UP" end,
		getDown = function(self) return "DOWN" end,
	} end },
	-- Underground
	{ name="underground", kr_name="지하", rarity=5, gen=function() return {
		load_grids = {"/data/general/grids/underground.lua"},
		getDoor = function(self) return "UNDERGROUND_FLOOR" end,
		getFloor = function(self) return "UNDERGROUND_FLOOR" end,
		getWall = function(self) return "UNDERGROUND_TREE" end,
		getUp = function(self) return "UNDERGROUND_LADDER_UP" end,
		getDown = function(self) return "UNDERGROUND_LADDER_DOWN" end,
	} end },
	-- Crystals
	{ name="crystal", kr_name="수정", rarity=4, gen=function() return {
		load_grids = {"/data/general/grids/underground.lua"},
		getDoor = function(self) return "CRYSTAL_FLOOR" end,
		getFloor = function(self) return "CRYSTAL_FLOOR" end,
		getWall = function(self) return {"CRYSTAL_WALL","CRYSTAL_WALL2","CRYSTAL_WALL3","CRYSTAL_WALL4","CRYSTAL_WALL5","CRYSTAL_WALL6","CRYSTAL_WALL7","CRYSTAL_WALL8","CRYSTAL_WALL9","CRYSTAL_WALL10","CRYSTAL_WALL11","CRYSTAL_WALL12","CRYSTAL_WALL13","CRYSTAL_WALL14","CRYSTAL_WALL15","CRYSTAL_WALL16","CRYSTAL_WALL17","CRYSTAL_WALL18","CRYSTAL_WALL19","CRYSTAL_WALL20",} end,
		getUp = function(self) return "CRYSTAL_LADDER_UP" end,
		getDown = function(self) return "CRYSTAL_LADDER_DOWN" end,
	} end },
	-- Sand
	{ name="sand", kr_name="모래밭", rarity=3, gen=function() return {
		load_grids = {"/data/general/grids/sand.lua"},
		getDoor = function(self) return "UNDERGROUND_SAND" end,
		getFloor = function(self) return "UNDERGROUND_SAND" end,
		getWall = function(self) return "SANDWALL" end,
		getUp = function(self) return "SAND_LADDER_UP" end,
		getDown = function(self) return "SAND_LADDER_DOWN" end,
	} end },
	-- Desert
	{ name="desert", kr_name="사막", rarity=3, gen=function() return {
		load_grids = {"/data/general/grids/sand.lua"},
		getDoor = function(self) return "SAND" end,
		getFloor = function(self) return "SAND" end,
		getWall = function(self) return "PALMTREE" end,
		getUp = function(self) return "SAND_UP"..self.less_dir end,
		getDown = function(self) return "SAND_DOWN"..self.more_dir end,
	} end },
	-- Slime
	{ name="slime", kr_name="슬라임", rarity=4, gen=function() return {
		load_grids = {"/data/general/grids/slime.lua"},
		getDoor = function(self) return "SLIME_DOOR" end,
		getFloor = function(self) return "SLIME_FLOOR" end,
		getWall = function(self) return "SLIME_WALL" end,
		getUp = function(self) return "SLIME_UP" end,
		getDown = function(self) return "SLIME_DOWN" end,
	} end },
}

function _M:createRandomZone(zbase)
	zbase = zbase or {}

	------------------------------------------------------------
	-- Select theme
	------------------------------------------------------------
	local themes = {}
	for i, theme in ipairs(random_zone_themes) do for j = 1, 100 / theme.rarity do themes[#themes+1] = theme end end
	local theme = rng.table(themes)
	print("[RANDOM ZONE] Using theme", theme.name)
	local data = theme.gen()

	local grids = {}
	for i, file in ipairs(data.load_grids) do
		mod.class.Grid:loadList(file, nil, grids)
	end

	------------------------------------------------------------
	-- Misc data
	------------------------------------------------------------
	data.depth = zbase.depth or rng.range(2, 4)
	data.min_lev, data.max_lev = zbase.min_lev or game.player.level, zbase.max_lev or game.player.level + 15
	data.w, data.h = zbase.w or rng.range(40, 60), zbase.h or rng.range(40, 60)
	data.max_material_level = util.bound(math.ceil(data.min_lev / 10), 1, 5)
	data.min_material_level = data.max_material_level - 1

	data.less_dir = rng.table{2, 4, 6, 8}
	data.more_dir = ({[2]=8, [8]=2, [4]=6, [6]=4})[data.less_dir]

	-- Give a random tint
	data.tint_s = {1, 1, 1, 1}
	if rng.percent(10) then
		local sr, sg, sb
		sr = rng.float(0.3, 1)
		sg = rng.float(0.3, 1)
		sb = rng.float(0.3, 1)
		local max = math.max(sr, sg, sb)
		data.tint_s[1] = sr / max
		data.tint_s[2] = sg / max
		data.tint_s[3] = sb / max
	end
	data.tint_o = {data.tint_s[1] * 0.6, data.tint_s[2] * 0.6, data.tint_s[3] * 0.6, 0.6}

	------------------------------------------------------------
	-- Select layout
	------------------------------------------------------------
	local layouts = {}
	for i, layout in ipairs(random_zone_layouts) do for j = 1, 100 / layout.rarity do layouts[#layouts+1] = layout end end
	local layout = rng.table(layouts)
	print("[RANDOM ZONE] Using layout", layout.name)

	------------------------------------------------------------
	-- Select Music
	------------------------------------------------------------
	local musics = {}
	for i, file in ipairs(fs.list("/data/music/")) do
		if file:find("%.ogg$") then musics[#musics+1] = file end
	end

	------------------------------------------------------------
	-- Create a boss
	------------------------------------------------------------
	local npcs = mod.class.NPC:loadList("/data/general/npcs/random_zone.lua")
	local list = {}
	for _, e in ipairs(npcs) do
		if e.rarity and e.level_range and e.level_range[1] <= data.min_lev and (not e.level_range[2] or e.level_range[2] >= data.min_lev) and e.rank > 1 and not e.unique then
			list[#list+1] = e
		end
	end
	local base = rng.table(list)
	local boss, boss_id = self:createRandomBoss(base, {level=data.min_lev + data.depth + rng.range(2, 4)})
	npcs[boss_id] = boss

	------------------------------------------------------------
	-- Entities
	------------------------------------------------------------
	local base_nb = math.sqrt(data.w * data.h)
	local nb_npc = { math.ceil(base_nb * 0.4), math.ceil(base_nb * 0.6) }
	local nb_trap = { math.ceil(base_nb * 0.1), math.ceil(base_nb * 0.2) }
	local nb_object = { math.ceil(base_nb * 0.06), math.ceil(base_nb * 0.12) }
	if rng.percent(20) then nb_trap = {0,0} end
	if rng.percent(10) then nb_object = {0,0} end

	------------------------------------------------------------
	-- Name
	------------------------------------------------------------
	local ngd = NameGenerator.new(randart_name_rules.default2)
	local name = ngd:generate()
	local short_name = name:lower():gsub("[^a-z]", "_")

	------------------------------------------------------------
	-- Final glue
	------------------------------------------------------------
	local zone = mod.class.Zone.new(short_name, {
		name = name,
		kr_name = kr_name or name, --@ 지역의 한글 이름 추가
		level_range = {data.min_lev, data.max_lev},
		level_scheme = "player",
		max_level = data.depth,
		actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
		width = data.w, height = data.h,
		color_shown = data.tint_s,
		color_obscure = data.tint_o,
		ambient_music = rng.table(musics),
		min_material_level = data.min_material_level,
		max_material_level = data.max_material_level,
		no_random_lore = true,
		persistent = "zone_temporary",
		reload_lists = false,
		generator =  {
			map = layout.gen(data),
			actor = { class = "mod.class.generator.actor.Random", nb_npc = nb_npc, guardian = boss_id, abord_no_guardian=true, guardian_alert=layout.guardian_alert },
			trap = { class = "engine.generator.trap.Random", nb_trap = nb_trap, },
			object = { class = "engine.generator.object.Random", nb_object = nb_object, },
		},
		levels = { [1] = { generator = { map = { up = data:getFloor() } } } },
		basic_floor = util.getval(data:getFloor()),
		npc_list = npcs,
		grid_list = grids,
		object_list = mod.class.Object:loadList("/data/general/objects/objects.lua"),
		trap_list = mod.class.Trap:loadList("/data/general/traps/alarm.lua"),
	})
	return zone, boss
end

function _M:createRandomBoss(base, data)
	local b = base:clone()
	data = data or {level=1}

	------------------------------------------------------------
	-- Basic stuff, name, rank, ...
	------------------------------------------------------------
	local ngd, name
	if base.random_name_def then
		ngd = NameGenerator2.new("/data/languages/names/"..base.random_name_def:gsub("#sex#", base.female and "female" or "male")..".txt")
		name = ngd:generate(nil, base.random_name_min_syllables, base.random_name_max_syllables)
	else
		ngd = NameGenerator.new(randart_name_rules.default)
		name = ngd:generate()
	end
	if data.name_scheme then
		local krTemp = data.name_scheme:gsub("#rng#", ""):gsub("#base#", ""):match("^%s*(.-)%s*$"):krBossName() --@ 직업부분 추출해서 한글로 변환
		local ri, bi
		ri = data.name_scheme:find("#rng#") --@ 랜덤이름 들어가는지 검사
		bi = data.name_scheme:find("#base#") --@ 종족명 들어가는지 검사
		b.kr_name = (bi and (b.kr_name or b.name).." " or "") .. krTemp .. (ri and " "..name or "") --@ 한글 이름 삽입: "<종족> <직업> <이름>"순
		
		b.name = data.name_scheme:gsub("#rng#", name):gsub("#base#", b.name)
	else
		b.kr_name = (b.kr_name and b.kr_name.." "..name) or (name.." the "..b.name) --@ 한글 종족이름이 존재할 경우 조합 순서 바꿈
		b.name = name.." the "..b.name
	end
	b.unique = b.name
	b.randboss = true
	local boss_id = "RND_BOSS_"..b.name:upper():gsub("[^A-Z]", "_")
	b.define_as = boss_id
	b.color = colors.VIOLET
	b.rank = data.rank or (rng.percent(30) and 4 or 3.5)
	b.level_range[1] = data.level
	b.fixed_rating = true
	if data.life_rating then
		b.life_rating = data.life_rating(b.life_rating)
	else
		b.life_rating = b.life_rating * 1.7 + rng.range(4, 9)
	end
	b.max_life = b.max_life or 150

	if b.can_multiply or b.clone_on_hit then
		b.clone_base = base:clone()
		b.clone_base:resolve()
		b.clone_base:resolve(nil, true)
	end

	-- Force resolving some stuff
	if type(b.max_life) == "table" and b.max_life.__resolver then b.max_life = resolvers.calc[b.max_life.__resolver](b.max_life, b, b, b, "max_life", {}) end

	-- All bosses have alll body parts .. yes snake bosses can use archery and so on ..
	-- This is to prevent them from having unusable talents
	b.inven = {}
	b.body = { INVEN = 1000, QS_MAINHAND = 1, QS_OFFHAND = 1, MAINHAND = 1, OFFHAND = 1, FINGER = 2, NECK = 1, LITE = 1, BODY = 1, HEAD = 1, CLOAK = 1, HANDS = 1, BELT = 1, FEET = 1, TOOL = 1, QUIVER = 1 }
	b:initBody()

	b:resolve()

	-- Start with sustains sustained
	b[#b+1] = resolvers.sustains_at_birth()

	-- Leveling stats
	b.autolevel = "random_boss"
	b.auto_stats = {}

	-- Always smart
	if data.ai then b.ai = data.ai
	else b.ai = (b.rank > 3) and "tactical" or b.ai
	end
	b.ai_state = { talent_in=1, ai_move=data.ai_move or "move_astar" }

	-- Remove default equipment, if any
	local todel = {}
	for k, resolver in pairs(b) do if type(resolver) == "table" and resolver.__resolver and (resolver.__resolver == "equip" or resolver.__resolver == "drops") then todel[#todel+1] = k end end
	for _, k in ipairs(todel) do b[k] = nil end

	-- Boss worthy drops
	b[#b+1] = resolvers.drops{chance=100, nb=data.loot_quantity or 3, {tome_drops=data.loot_quality or "boss"} }
	if not data.no_loot_randart then b[#b+1] = resolvers.drop_randart{} end

	-- On die
	if data.on_die then
		b.rng_boss_on_die = b.on_die
		b.rng_boss_on_die_custom = data.on_die
		b.on_die = function(self, src)
			self:check("rng_boss_on_die_custom", src)
			self:check("rng_boss_on_die", src)
		end
	end

	------------------------------------------------------------
	-- Apply talents from classes
	------------------------------------------------------------
	self:applyRandomClass(b, data)

	b.rnd_boss_on_added_to_level = b.on_added_to_level
	b._rndboss_resources_boost = data.resources_boost
	b._rndboss_talent_cds = data.talent_cds_factor
	b.on_added_to_level = function(self, ...)
		self:check("birth_create_alchemist_golem")
		for tid, lev in pairs(self.learn_tids) do
			if self:getTalentLevelRaw(tid) < lev then
				self:learnTalent(tid, true, lev - self:getTalentLevelRaw(tid))
			end
		end
		self:check("rnd_boss_on_added_to_level", ...)
		self.rnd_boss_on_added_to_level = nil
		self.learn_tids = nil
		self.on_added_to_level = nil

		-- Increase talent cds
		if self._rndboss_talent_cds then
			local fact = self._rndboss_talent_cds
			for tid, _ in pairs(self.talents) do
				local t = self:getTalentFromId(tid)
				if t.mode ~= "passive" then
					local bcd = self:getTalentCooldown(t) or 0
					self.talent_cd_reduction[tid] = (self.talent_cd_reduction[tid] or 0) - math.ceil(bcd * (fact - 1))
				end
			end
		end

		-- Cheat a bit with ressources
		self.max_mana = self.max_mana * (self._rndboss_resources_boost or 3) self.mana_regen = self.mana_regen + 1
		self.max_vim = self.max_vim * (self._rndboss_resources_boost or 3) self.vim_regen = self.vim_regen + 1
		self.max_stamina = self.max_stamina * (self._rndboss_resources_boost or 3) self.stamina_regen = self.stamina_regen + 1
		self.max_psi = self.max_psi * (self._rndboss_resources_boost or 3) self.psi_regen = self.psi_regen + 2
		self.equilibrium_regen = self.equilibrium_regen - 2
		self:resetToFull()
	end

	-- Anything else
	if data.post then data.post(b, data) end

	return b, boss_id
end

return _M
