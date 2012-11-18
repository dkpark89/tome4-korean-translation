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

newTalent{
	name = "Necrotic Aura", image = "talents/aura_mastery.png",
	type = {"spell/other", 1},
	points = 1,
	mode = "sustained",
	cooldown = 10,
	sustain_mana = 10,
	no_unlearn_last = true,
	tactical = { BUFF = 2 },
	die_speach = function(self, t)
		if rng.percent(90) then return end
		self:doEmote(rng.table{
			"Noooooo!",
			"Save me, Master, save meeee---",
			"Aaaauuuggghhh!",
			"Did I do good?",
			"Bwuh? Nwaaah!",
			"Why, Master, whyyyyy---?",
			"I thought you loved me! I thought-",
			"For Master's glory!",
			"Bye... bye....",
			"We love you, Master!",
			"EeeeeeeaaaAAAAAUUUUUGGGGGHHHHH!!!!",
			"The pain, the PAAAAAIN!",
			"Please, no, nooo--",
			"Unlife no more for this dead matter, the time comes for my flesh to splatter.",
			"You gave back life, you gave back dreams, but now I'm bursting at the seams...",
			"Remember meeeee!",
			"My tummy hurts...",
			"Whu..?",
			"Ahahahahaha!",
			"Me go boom, me go BOOM!",
			"Grave circumstances, Master....",
			"I see the light.. I see, oh.. just a wisp....",
			"Master, wait... I thought I saw a....Master? ..",
			"I'm not.. so sure my spine is supposed to bend this way....",
			"I told you I could Dash 100 yards and back in time! You owe me 10 gol....",
		}, 40)
	end,
	getDecay = function(self, t) return math.max(3, 10 - self:getTalentLevelRaw(self.T_AURA_MASTERY)) end,
	getRadius = function(self, t) return 2 + self:getTalentLevelRaw(self.T_AURA_MASTERY) end,
	activate = function(self, t)
		local radius = t.getRadius(self, t)
		local decay = t.getDecay(self, t)
		game:playSoundNear(self, "talents/spell_generic2")
		local ret = {
			souls = self:attr("necrotic_aura_base_souls") or 0,
			souls_max = 10,
			rad = self:addTemporaryValue("necrotic_aura_radius", radius),
			decay = self:addTemporaryValue("necrotic_aura_decay", decay),
			retch = self:addTemporaryValue("retch_heal", 1),
			particle = self:addParticles(Particles.new("necrotic-aura", 1, {radius=radius})),
		}
		self.necrotic_aura_base_souls = nil
		return ret
	end,
	deactivate = function(self, t, p)
		self.necrotic_aura_base_souls = p.souls
		self:removeParticles(p.particle)
		self:removeTemporaryValue("retch_heal", p.retch)
		self:removeTemporaryValue("necrotic_aura_radius", p.rad)
		self:removeTemporaryValue("necrotic_aura_decay", p.decay)
		return true
	end,
	info = function(self, t)
		local radius = t.getRadius(self, t)
		local decay = t.getDecay(self, t)
		return ([[Emits a necrotic aura, sustaining your undead minions in a radius of %d. Minions outside the radius will lose %d%% life per turn.
		Any creature you or your minions kill within your aura will be absorbed and can be used to raise minions.
		Retch from your ghouls will also heal you even if you are not undead.]]):
		format(radius, decay)
	end,
}


local minions_list = {
	d_skel_warrior = {
		type = "undead", subtype = "skeleton",
		name = "degenerated skeleton warrior", color=colors.WHITE, image="npc/degenerated_skeleton_warrior.png",
		blood_color = colors.GREY,
		display = "s",
		combat = { dam=1, atk=1, apr=1 },
		level_range = {1, nil}, exp_worth = 0,
		body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
		infravision = 10,
		rank = 2,
		size_category = 3,
		autolevel = "warrior",
		ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=4, },
		stats = { str=14, dex=12, mag=10, con=12 },
		resolvers.racial(),
		resolvers.tmasteries{ ["technique/other"]=0.3, ["technique/2hweapon-offense"]=0.3, ["technique/2hweapon-cripple"]=0.3 },
		open_door = true,
		cut_immune = 1,
		blind_immune = 1,
		poison_immune = 1,
		fear_immune = 1,
		see_invisible = 2,
		undead = 1,
		rarity = 1,

		resolvers.equip{ {type="weapon", subtype="greatsword", autoreq=true} },
		max_life = resolvers.rngavg(40,50),
		combat_armor = 5, combat_def = 1,
	},
	skel_warrior = {
		type = "undead", subtype = "skeleton",
		name = "skeleton warrior", color=colors.SLATE, image="npc/skeleton_warrior.png",
		blood_color = colors.GREY,
		display = "s", color=colors.SLATE,
		combat = { dam=1, atk=1, apr=1 },
		level_range = {1, nil}, exp_worth = 0,
		body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
		infravision = 10,
		rank = 2,
		size_category = 3,
		autolevel = "warrior",
		ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=4, },
		stats = { str=14, dex=12, mag=10, con=12 },
		resolvers.racial(),
		resolvers.tmasteries{ ["technique/other"]=0.3, ["technique/2hweapon-offense"]=0.3, ["technique/2hweapon-cripple"]=0.3 },
		open_door = true,
		cut_immune = 1,
		blind_immune = 1,
		fear_immune = 1,
		see_invisible = 2,
		poison_immune = 1,
		undead = 1,
		rarity = 1,

		max_life = resolvers.rngavg(90,100),
		combat_armor = 5, combat_def = 1,
		resolvers.equip{ {type="weapon", subtype="greatsword", autoreq=true} },
		resolvers.talents{ T_STUNNING_BLOW={base=1, every=7, max=5}, T_WEAPON_COMBAT={base=1, every=7, max=10}, T_WEAPONS_MASTERY={base=1, every=7, max=10}, },
		ai_state = { talent_in=1, },
	},
	a_skel_warrior = {
		type = "undead", subtype = "skeleton",
		name = "armoured skeleton warrior", color=colors.STEEL_BLUE, image="npc/armored_skeleton_warrior.png",
		blood_color = colors.GREY,
		display = "s", color=colors.STEEL_BLUE,
		combat = { dam=1, atk=1, apr=1 },
		level_range = {1, nil}, exp_worth = 0,
		body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
		infravision = 10,
		rank = 2,
		size_category = 3,
		autolevel = "warrior",
		ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=4, },
		stats = { str=14, dex=12, mag=10, con=12 },
		resolvers.racial(),
		resolvers.tmasteries{ ["technique/other"]=0.3, ["technique/2hweapon-offense"]=0.3, ["technique/2hweapon-cripple"]=0.3 },
		open_door = true,
		cut_immune = 1,
		blind_immune = 1,
		fear_immune = 1,
		poison_immune = 1,
		see_invisible = 2,
		undead = 1,
		rarity = 1,

		resolvers.inscriptions(1, "rune"),
		resolvers.talents{
			T_WEAPON_COMBAT={base=1, every=7, max=10},
			T_WEAPONS_MASTERY={base=1, every=7, max=10},
			T_ARMOUR_TRAINING={base=4, every=7, max=8},
			T_SHIELD_PUMMEL={base=1, every=7, max=5},
			T_RIPOSTE={base=3, every=7, max=7},
			T_OVERPOWER={base=1, every=7, max=5},
			T_DISARM={base=3, every=7, max=7},
		},
		resolvers.equip{ {type="weapon", subtype="longsword", autoreq=true}, {type="armor", subtype="shield", autoreq=true}, {type="armor", subtype="heavy", autoreq=true} },
		ai_state = { talent_in=1, },
	},
	skel_archer = {
		type = "undead", subtype = "skeleton",
		name = "skeleton archer", color=colors.UMBER, image="npc/skeleton_archer.png",
		blood_color = colors.GREY,
		display = "s",
		combat = { dam=1, atk=1, apr=1 },
		level_range = {1, nil}, exp_worth = 0,
		body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
		infravision = 10,
		rank = 2,
		size_category = 3,
		autolevel = "warrior",
		ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=4, },
		stats = { str=14, dex=12, mag=10, con=12 },
		resolvers.racial(),
		resolvers.tmasteries{ ["technique/other"]=0.3, ["technique/2hweapon-offense"]=0.3, ["technique/2hweapon-cripple"]=0.3 },
		open_door = true,
		cut_immune = 1,
		blind_immune = 1,
		fear_immune = 1,
		poison_immune = 1,
		see_invisible = 2,
		undead = 1,
		rarity = 1,

		max_life = resolvers.rngavg(70,80),
		combat_armor = 5, combat_def = 1,
		resolvers.talents{ T_BOW_MASTERY={base=1, every=7, max=10}, T_WEAPON_COMBAT={base=1, every=7, max=10}, T_SHOOT=1, },
		ai_state = { talent_in=1, },
		autolevel = "archer",
		resolvers.equip{ {type="weapon", subtype="longbow", autoreq=true}, {type="ammo", subtype="arrow", autoreq=true} },
	},
	skel_m_archer = {
		type = "undead", subtype = "skeleton",
		name = "skeleton master archer", color=colors.LIGHT_UMBER, image="npc/master_skeleton_archer.png",
		blood_color = colors.GREY,
		display = "s",
		combat = { dam=1, atk=1, apr=1 },
		level_range = {1, nil}, exp_worth = 0,
		body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
		infravision = 10,
		rank = 2,
		size_category = 3,
		autolevel = "warrior",
		ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=4, },
		stats = { str=14, dex=12, mag=10, con=12 },
		resolvers.racial(),
		resolvers.tmasteries{ ["technique/other"]=0.3, ["technique/2hweapon-offense"]=0.3, ["technique/2hweapon-cripple"]=0.3 },
		open_door = true,
		cut_immune = 1,
		blind_immune = 1,
		fear_immune = 1,
		poison_immune = 1,
		see_invisible = 2,
		undead = 1,
		rarity = 1,

		max_life = resolvers.rngavg(70,80),
		combat_armor = 5, combat_def = 1,
		resolvers.talents{ T_BOW_MASTERY={base=1, every=7, max=10}, T_WEAPON_COMBAT={base=1, every=7, max=10}, T_SHOOT=1, T_PINNING_SHOT=3, T_CRIPPLING_SHOT=3, },
		ai_state = { talent_in=1, },
		rank = 3,
		autolevel = "archer",
		resolvers.equip{ {type="weapon", subtype="longbow", autoreq=true}, {type="ammo", subtype="arrow", autoreq=true} },
	},
	skel_mage = {
		type = "undead", subtype = "skeleton",
		name = "skeleton mage", color=colors.LIGHT_RED, image="npc/skeleton_mage.png",
		blood_color = colors.GREY,
		display = "s",
		combat = { dam=1, atk=1, apr=1 },
		level_range = {1, nil}, exp_worth = 0,
		body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
		infravision = 10,
		rank = 2,
		size_category = 3,
		autolevel = "warrior",
		ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=4, },
		stats = { str=14, dex=12, mag=10, con=12 },
		resolvers.racial(),
		resolvers.tmasteries{ ["technique/other"]=0.3, ["technique/2hweapon-offense"]=0.3, ["technique/2hweapon-cripple"]=0.3 },
		open_door = true,
		cut_immune = 1,
		blind_immune = 1,
		fear_immune = 1,
		poison_immune = 1,
		see_invisible = 2,
		undead = 1,
		rarity = 1,

		max_life = resolvers.rngavg(50,60),
		max_mana = resolvers.rngavg(70,80),
		combat_armor = 3, combat_def = 1,
		stats = { str=10, dex=12, cun=14, mag=14, con=10 },
		resolvers.talents{ T_FLAME={base=1, every=7, max=5}, T_MANATHRUST={base=2, every=7, max=5} },
		resolvers.equip{ {type="weapon", subtype="staff", autoreq=true} },
		autolevel = "caster",
		ai_state = { talent_in=1, },
	},
	ghoul = {
		type = "undead", subtype = "ghoul",
		display = "z",
		body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
		autolevel = "ghoul",
		level_range = {1, nil}, exp_worth = 0,
		ai = "dumb_talented_simple", ai_state = { talent_in=2, ai_move="move_ghoul", },
		stats = { str=14, dex=12, mag=10, con=12 },
		rank = 2,
		size_category = 3,
		infravision = 10,
		resolvers.racial(),
		resolvers.tmasteries{ ["technique/other"]=1, },
		open_door = true,
		blind_immune = 1,
		see_invisible = 2,
		undead = 1,
		name = "ghoul", color=colors.TAN,
		max_life = resolvers.rngavg(90,100),
		combat_armor = 2, combat_def = 7,
		resolvers.talents{
			T_STUN={base=1, every=10, max=5},
			T_BITE_POISON={base=1, every=10, max=5},
			T_ROTTING_DISEASE={base=1, every=10, max=5},
		},
		ai_state = { talent_in=4, },
		combat = { dam=resolvers.levelup(10, 1, 1), atk=resolvers.levelup(5, 1, 1), apr=3, dammod={str=0.6} },
	},
	ghast = {
		type = "undead", subtype = "ghoul",
		display = "z",
		body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
		level_range = {1, nil}, exp_worth = 0,
		autolevel = "ghoul",
		ai = "dumb_talented_simple", ai_state = { talent_in=2, ai_move="move_ghoul", },
		stats = { str=14, dex=12, mag=10, con=12 },
		rank = 2,
		size_category = 3,
		infravision = 10,
		resolvers.racial(),
		resolvers.tmasteries{ ["technique/other"]=1, },
		open_door = true,
		blind_immune = 1,
		see_invisible = 2,
		undead = 1,
		name = "ghast", color=colors.UMBER,
		max_life = resolvers.rngavg(90,100),
		combat_armor = 2, combat_def = 7,
		resolvers.talents{
			T_STUN={base=1, every=10, max=5},
			T_BITE_POISON={base=1, every=10, max=5},
			T_ROTTING_DISEASE={base=1, every=10, max=5},
		},
		ai_state = { talent_in=4, },
		combat = { dam=resolvers.levelup(10, 1, 1), atk=resolvers.levelup(5, 1, 1), apr=3, dammod={str=0.6} },
	},
	ghoulking = {
		type = "undead", subtype = "ghoul",
		display = "z",
		body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
		level_range = {1, nil}, exp_worth = 0,
		autolevel = "ghoul",
		ai = "dumb_talented_simple", ai_state = { talent_in=2, ai_move="move_ghoul", },
		stats = { str=14, dex=12, mag=10, con=12 },
		rank = 2,
		size_category = 3,
		infravision = 10,
		resolvers.racial(),
		resolvers.tmasteries{ ["technique/other"]=1, },
		open_door = true,
		blind_immune = 1,
		see_invisible = 2,
		undead = 1,
		name = "ghoulking", color={0,0,0},
		max_life = resolvers.rngavg(90,100),
		combat_armor = 3, combat_def = 10,
		ai_state = { talent_in=2, ai_pause=20 },
		rank = 3,
		combat = { dam=resolvers.levelup(30, 1, 1.2), atk=resolvers.levelup(8, 1, 1), apr=4, dammod={str=0.6} },
		resolvers.talents{
			T_STUN={base=3, every=9, max=7},
			T_BITE_POISON={base=3, every=9, max=7},
			T_ROTTING_DISEASE={base=4, every=9, max=7},
			T_DECREPITUDE_DISEASE={base=3, every=9, max=7},
			T_WEAKNESS_DISEASE={base=3, every=9, max=7},
		},
	},

	-- Advanced minions
	vampire = {
		type = "undead", subtype = "vampire",
		display = "V",
		combat = { dam=resolvers.levelup(resolvers.mbonus(30, 10), 1, 0.8), atk=10, apr=9, damtype=DamageType.DRAINLIFE, dammod={str=1.9} },
		level_range = {1, nil}, exp_worth = 0,
		body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
		autolevel = "warriormage",
		ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=9, },
		stats = { str=12, dex=12, mag=12, con=12 },
		infravision = 10,
		life_regen = 3,
		size_category = 3,
		rank = 2,
		open_door = true,
		resolvers.inscriptions(1, "rune"),
		resolvers.sustains_at_birth(),
		resists = { [DamageType.COLD] = 80, [DamageType.NATURE] = 80, [DamageType.LIGHT] = -50,  },
		blind_immune = 1,
		confusion_immune = 1,
		see_invisible = 5,
		undead = 1,
		name = "vampire", color=colors.SLATE, image = "npc/vampire.png",
		desc=[[It is a humanoid with an aura of power. You notice a sharp set of front teeth.]],
		max_life = resolvers.rngavg(70,80),
		combat_armor = 9, combat_def = 6,
		resolvers.talents{ T_STUN={base=1, every=7, max=5}, T_BLUR_SIGHT={base=1, every=7, max=5}, T_ROTTING_DISEASE={base=1, every=7, max=5}, },
	},
	m_vampire = {
		type = "undead", subtype = "vampire",
		display = "V",
		combat = { dam=resolvers.levelup(resolvers.mbonus(30, 10), 1, 0.8), atk=10, apr=9, damtype=DamageType.DRAINLIFE, dammod={str=1.9} },
		level_range = {1, nil}, exp_worth = 0,
		body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
		autolevel = "warriormage",
		ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=9, },
		stats = { str=12, dex=12, mag=12, con=12 },
		infravision = 10,
		life_regen = 3,
		size_category = 3,
		rank = 2,
		open_door = true,
		resolvers.inscriptions(1, "rune"),
		resolvers.sustains_at_birth(),
		resists = { [DamageType.COLD] = 80, [DamageType.NATURE] = 80, [DamageType.LIGHT] = -50,  },
		blind_immune = 1,
		confusion_immune = 1,
		see_invisible = 5,
		undead = 1,
		name = "master vampire", color=colors.GREEN, image = "npc/master_vampire.png",
		resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/master_vampire.png", display_h=2, display_y=-1}}},
		desc=[[It is a humanoid form dressed in robes. Power emanates from its chilling frame.]],
		max_life = resolvers.rngavg(80,90),
		combat_armor = 10, combat_def = 8,
		ai = "dumb_talented_simple", ai_state = { talent_in=1, },
		resolvers.talents{ T_STUN={base=1, every=7, max=5}, T_BLUR_SIGHT={base=2, every=7, max=5}, T_PHANTASMAL_SHIELD={base=1, every=7, max=5}, T_ROTTING_DISEASE={base=2, every=7, max=5}, },
	},
	g_wight = {
		type = "undead", subtype = "wight",
		display = "W",
		combat = { dam=resolvers.mbonus(30, 10), atk=10, apr=9, damtype=DamageType.DRAINEXP },
		body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
		level_range = {1, nil}, exp_worth = 0,
		autolevel = "caster",
		ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=4, },
		stats = { str=11, dex=11, mag=15, con=12 },
		infravision = 10,
		rank = 2,
		size_category = 3,
		open_door = true,
		resolvers.sustains_at_birth(),
		resists = { [DamageType.COLD] = 80, [DamageType.FIRE] = 20, [DamageType.LIGHTNING] = 40, [DamageType.PHYSICAL] = 35, [DamageType.LIGHT] = -50, },
		poison_immune = 1,
		blind_immune = 1,
		see_invisible = 7,
		undead = 1,
		name = "grave wight", color=colors.SLATE, image="npc/grave_wight.png",
		desc=[[It is a ghostly form with eyes that haunt you.]],
		max_life = resolvers.rngavg(70,80),
		combat_armor = 9, combat_def = 6,
		resolvers.talents{ T_FLAMESHOCK={base=2, every=5, max=6}, T_LIGHTNING={base=2, every=5, max=6}, T_GLACIAL_VAPOUR={base=2, every=5, max=6},
			T_MIND_DISRUPTION={base=2, every=5, max=6},
		},
	},
	b_wight = {
		type = "undead", subtype = "wight",
		display = "W",
		combat = { dam=resolvers.mbonus(30, 10), atk=10, apr=9, damtype=DamageType.DRAINEXP },
		body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
		level_range = {1, nil}, exp_worth = 0,
		autolevel = "caster",
		ai = "dumb_talented_simple", ai_state = { ai_move="move_dmap", talent_in=4, },
		stats = { str=11, dex=11, mag=15, con=12 },
		infravision = 10,
		rank = 2,
		size_category = 3,
		open_door = true,
		resolvers.sustains_at_birth(),
		resists = { [DamageType.COLD] = 80, [DamageType.FIRE] = 20, [DamageType.LIGHTNING] = 40, [DamageType.PHYSICAL] = 35, [DamageType.LIGHT] = -50, },
		poison_immune = 1,
		blind_immune = 1,
		see_invisible = 7,
		undead = 1,
		name = "barrow wight", color=colors.LIGHT_RED, image="npc/barrow_wight.png",
		resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/barrow_wight.png", display_h=2, display_y=-1}}},
		desc=[[It is a ghostly nightmare of an entity.]],
		max_life = resolvers.rngavg(80,90),
		combat_armor = 10, combat_def = 8,
		resolvers.talents{ T_FLAMESHOCK={base=3, every=5, max=7}, T_LIGHTNING={base=3, every=5, max=7}, T_GLACIAL_VAPOUR={base=3, every=5, max=7},
			T_MIND_DISRUPTION={base=3, every=5, max=7},
		},
	},
	dread = {
		type = "undead", subtype = "ghost",
		blood_color = colors.GREY,
		display = "G",
		body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
		autolevel = "warriormage",
		ai = "dumb_talented_simple", ai_state = { talent_in=2, },
		stats = { str=14, dex=18, mag=20, con=12 },
		rank = 2,
		size_category = 3,
		infravision = 10,
		can_pass = {pass_wall=70},
		resists = {all = 35, [DamageType.LIGHT] = -70, [DamageType.DARKNESS] = 65},
		no_breath = 1,
		stone_immune = 1,
		confusion_immune = 1,
		fear_immune = 1,
		teleport_immune = 0.5,
		disease_immune = 1,
		poison_immune = 1,
		stun_immune = 1,
		blind_immune = 1,
		cut_immune = 1,
		see_invisible = 80,
		undead = 1,
		resolvers.sustains_at_birth(),
		name = "dread", color=colors.ORANGE, image="npc/dread.png",
		desc = [[It is a form that screams its presence against the eye. Death incarnate, its hideous black body seems to struggle against reality as the universe itself strives to banish it.]],
		level_range = {1, nil}, exp_worth = 0,
		max_life = resolvers.rngavg(90,100),
		combat_armor = 0, combat_def = resolvers.mbonus(10, 50),
		invisibility = resolvers.mbonus(5, 10),
		ai_state = { talent_in=4, },
		combat = { dam=resolvers.mbonus(45, 45), atk=resolvers.mbonus(25, 45), apr=100, dammod={str=0.5, mag=0.5} },
		resolvers.talents{
			T_BURNING_HEX={base=3, every=5, max=7},
			T_BLUR_SIGHT={base=4, every=6, max=8},
		},
	},
	lich = {
		type = "undead", subtype = "lich",
		display = "L",
		rank = 3, size = 3,
		combat = { dam=resolvers.rngavg(16,27), atk=16, apr=9, damtype=DamageType.DARKSTUN, dammod={mag=0.9} },
		body = { INVEN = 10, MAINHAND = 1, OFFHAND = 1, FINGER = 2, NECK = 1, LITE = 1, BODY = 1, HEAD = 1, CLOAK = 1, HANDS = 1, BELT = 1, FEET = 1},
		equipment = resolvers.equip{
			{type="armor", subtype="cloth", ego_chance=75, autoreq=true},
			{type="armor", subtype="head", ego_chance=75, autoreq=true},
			{type="armor", subtype="feet", ego_chance=75, autoreq=true},
			{type="armor", subtype="cloak", ego_chance=75, autoreq=true},
			{type="jewelry", subtype="amulet", ego_chance=100, autoreq=true},
			{type="jewelry", subtype="ring", ego_chance=100, autoreq=true},
			{type="jewelry", subtype="ring", ego_chance=100, autoreq=true},
		},
		autolevel = "caster",
		ai = "tactical", ai_state = { talent_in=1, },
		ai_tactic = resolvers.tactic"ranged",
		stats = { str=8, dex=15, mag=20, wil=18, con=10, cun=18 },
		resists = { [DamageType.NATURE] = 90, [DamageType.FIRE] = 20, [DamageType.MIND] = 100, [DamageType.LIGHT] = -60, [DamageType.DARKNESS] = 95, [DamageType.BLIGHT] = 90 },
		resolvers.inscriptions(3, "rune"),
		instakill_immune = 1,
		stun_immune = 1,
		poison_immune = 1,
		undead = 1,
		blind_immune = 1,
		see_invisible = 100,
		infravision = 10,
		silence_immune = 0.7,
		fear_immune = 1,
		negative_regen = 0.4,	-- make their negative energies slowly increase
		mana_regen = 0.3,
		hate_regen = 2,
		open_door = 1,
		combat_spellpower = resolvers.mbonus(20, 10),
		combat_spellcrit = resolvers.mbonus(5, 5),
		resolvers.sustains_at_birth(),
		name = "lich", color=colors.DARK_BLUE,
		desc=[[Having thought to discover life eternal, these beings have allowed undeath to rob them of the joys of life. Now they seek to destroy it as well.]],
		resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/undead_lich_lich.png", display_h=2, display_y=-1}}},
		level_range = {1, nil}, exp_worth = 0,
		rarity = 20,
		max_life = resolvers.rngavg(70,80),
		combat_armor = 10, combat_def = 20,
		resolvers.talents{
			T_HYMN_OF_SHADOWS=4,
			T_MOONLIGHT_RAY=5,
			T_SHADOW_BLAST=5,
			T_TWILIGHT_SURGE=3,
			T_STARFALL=3,
			T_FREEZE=3,
			T_MANATHRUST=5,
			T_CONGEAL_TIME=5,
--			T_CREEPING_DARKNESS=4,
			T_DARK_VISION=4,
			T_DARK_TORRENT=4,
--			T_DARK_TENDRILS=4,
			T_BONE_GRAB=4,
			T_BONE_SPEAR=4,
			-- Utility spells
			T_PHASE_DOOR=5,
			T_TELEPORT=5,
			T_STONE_SKIN=5,

			T_CALL_SHADOWS=3,
			T_FOCUS_SHADOWS=3,
			T_SHADOW_MAGES=1,
			T_SHADOW_WARRIORS=1,
		},
	},
}

function getAdvancedMinionChances(self)
	local cl = math.floor(self:getTalentLevel(self.T_MINION_MASTERY))
	if cl <= 1 then
		return { vampire=4, m_vampire=0, g_wight=0, b_wight=0, dread=0, lich=0 }
	elseif cl == 2 then
		return { vampire=4, m_vampire=2, g_wight=0, b_wight=0, dread=2, lich=0 }
	elseif cl == 3 then
		return { vampire=6, m_vampire=2, g_wight=2, b_wight=0, dread=2, lich=0 }
	elseif cl == 4 then
		return { vampire=6, m_vampire=4, g_wight=2, b_wight=2, dread=4, lich=2 }
	elseif cl == 5 then
		return { vampire=6, m_vampire=4, g_wight=4, b_wight=2, dread=4, lich=2 }
	elseif cl >= 6 then
		return { vampire=4, m_vampire=4, g_wight=4, b_wight=4, dread=6, lich=4 }
	end
end

local function getMinionChances(self)
	local cl = math.floor(self:getTalentLevel(self.T_CREATE_MINIONS))
	if cl <= 1 then
		return { d_skel_warrior=55, skel_warrior=10, a_skel_warrior=0, skel_archer=10, skel_m_archer=0, skel_mage=5,   ghoul=20, ghast=0, ghoulking=0 }
	elseif cl == 2 then
		return { d_skel_warrior=31, skel_warrior=15, a_skel_warrior=2, skel_archer=15, skel_m_archer=2, skel_mage=10,  ghoul=20, ghast=5, ghoulking=0 }
	elseif cl == 3 then
		return { d_skel_warrior=24, skel_warrior=15, a_skel_warrior=5, skel_archer=20, skel_m_archer=4, skel_mage=10,  ghoul=15, ghast=5, ghoulking=2 }
	elseif cl == 4 then
		return { d_skel_warrior=9, skel_warrior=20, a_skel_warrior=10, skel_archer=15, skel_m_archer=6, skel_mage=10,  ghoul=15, ghast=10, ghoulking=5 }
	elseif cl == 5 then
		return { d_skel_warrior=9, skel_warrior=20, a_skel_warrior=10, skel_archer=10, skel_m_archer=8, skel_mage=15,  ghoul=10, ghast=10, ghoulking=8 }
	elseif cl >= 6 then
		return { d_skel_warrior=0, skel_warrior=25, a_skel_warrior=15, skel_archer=10, skel_m_archer=10, skel_mage=15, ghoul=5, ghast=10, ghoulking=10 }
	end
end

local function makeMinion(self, lev)
	if self:knowTalent(self.T_MINION_MASTERY) then
		local adv = getAdvancedMinionChances(self)
		local tot = 0
		local list = {}
		for k, e in pairs(adv) do for i = 1, e do list[#list+1] = k end tot = tot + e end
		local sel = list[rng.range(1, 100)]
		if sel then return require("mod.class.NPC").new(minions_list[sel]) end
	end

	local chances = getMinionChances(self)
	local tot = 0
	local list = {}
	for k, e in pairs(chances) do for i = 1, e do list[#list+1] = k end tot = tot + e end

	local m = require("mod.class.NPC").new(minions_list[rng.table(list)])
	return m
end

newTalent{
	name = "Create Minions",
	type = {"spell/necrotic-minions",1},
	require = spells_req1,
	points = 5,
	mana = 5,
	cooldown = 14,
	tactical = { ATTACK = 10 },
	requires_target = true,
	range = 0,
	radius = function(self, t)
		local aura = self:getTalentFromId(self.T_NECROTIC_AURA)
		return aura.getRadius(self, aura)
	end,
	target = function(self, t)
		return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	on_pre_use = function(self, t)
		local p = self:isTalentActive(self.T_NECROTIC_AURA)
		if not p then return end
		if p.souls < 1 then return end

		local nb = t.getMax(self, t)
		if math.min(nb, p.souls) < 1 then return end
		return true
	end,
	getMax = function(self, t) return math.floor(self:getTalentLevel(t)) - necroGetNbSummon(self) end,
	getLevel = function(self, t)
		local raw = self:getTalentLevelRaw(t)
		if raw <= 0 then return -8 end
		if raw > 8 then return 8 end
		return ({-6, -4, -2, 0, 2, 4, 6, 8})[raw]
	end,
	action = function(self, t)
		local p = self:isTalentActive(self.T_NECROTIC_AURA)
		local nb = t.getMax(self, t)
		nb = math.min(nb, p.souls)
		local lev = t.getLevel(self, t)

		-- Summon minions in a cone
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local possible_spots = {}
		self:project(tg, x, y, function(px, py)
			if not game.level.map:checkAllEntities(px, py, "block_move") then
				possible_spots[#possible_spots+1] = {x=px, y=py}
			end
		end)
		for i = 1, nb do
			local minion = makeMinion(self, self:getTalentLevel(t))
			local pos = rng.tableRemove(possible_spots)
			if minion and pos then
				p.souls = p.souls - 1
				necroSetupSummon(self, minion, pos.x, pos.y, lev, true)
			end
		end

		game:playSoundNear(self, "talents/spell_generic2")
		return true
	end,
	info = function(self, t)
		local nb = t.getMax(self, t)
		local lev = t.getLevel(self, t)
		local c = getMinionChances(self)
		return ([[Fires powerful undead energies through your necrotic aura. For each recent death that happened inside your aura you will raise an undead minion (up to %d minions). These minions will be raised within a cone that extends to the edge of your necrotic aura.
		The minions level is your level %+d.
		Each minion has a chance to be:
		Degenerated skeleton warrior: %d%%
		Skeleton warrior: %d%%
		Armoured skeleton warrior: %d%%
		Skeleton archer: %d%%
		Skeleton master archer: %d%%
		Skeleton mage: %d%%
		Ghoul: %d%%
		Ghast: %d%%
		Ghoulking: %d%%
		]]):
		format(nb, lev, c.d_skel_warrior, c.skel_warrior, c.a_skel_warrior, c.skel_archer, c.skel_m_archer, c.skel_mage, c.ghoul, c.ghast, c.ghoulking)
	end,
}

newTalent{
	name = "Aura Mastery",
	type = {"spell/necrotic-minions",2},
	require = spells_req2,
	points = 5,
	mode = "passive",
	on_learn = function(self, t)
		self:forceUseTalent(self.T_NECROTIC_AURA, {ignore_energy=true, ignore_cd=true, no_equilibrium_fail=true, no_paradox_fail=true})
		self:forceUseTalent(self.T_NECROTIC_AURA, {ignore_energy=true, ignore_cd=true, no_equilibrium_fail=true, no_paradox_fail=true})
	end,
	on_unlearn = function(self, t)
		self:forceUseTalent(self.T_NECROTIC_AURA, {ignore_energy=true, ignore_cd=true, no_equilibrium_fail=true, no_paradox_fail=true})
		self:forceUseTalent(self.T_NECROTIC_AURA, {ignore_energy=true, ignore_cd=true, no_equilibrium_fail=true, no_paradox_fail=true})
	end,
	info = function(self, t)
		return ([[Your dark power radiates further as you grow stronger. Increases the radius of your necrotic aura by %d and reduces the decay rate of your minions outside the aura by %d%%.]]):
		format(self:getTalentLevelRaw(t), self:getTalentLevelRaw(t))
	end,
}

newTalent{
	name = "Surge of Undeath",
	type = {"spell/necrotic-minions",3},
	require = spells_req3,
	points = 5,
	mana = 45,
	cooldown = 20,
	tactical = { ATTACKAREA = 2 },
	getPower = function(self, t) return self:combatTalentSpellDamage(t, 10, 60) end,
	getCrit = function(self, t) return self:combatTalentSpellDamage(t, 6, 25) end,
	getAPR = function(self, t) return self:combatTalentSpellDamage(t, 10, 50) end,
	action = function(self, t)
		local apply = function(a)
			a:setEffect(a.EFF_SURGE_OF_UNDEATH, 6, {power=t.getPower(self, t), apr=t.getAPR(self, t), crit=t.getCrit(self, t)})
		end

		if game.party and game.party:hasMember(self) then
			for act, def in pairs(game.party.members) do
				if act.summoner and act.summoner == self and act.necrotic_minion then apply(act) end
			end
		else
			for uid, act in pairs(game.level.entities) do
				if act.summoner and act.summoner == self and act.necrotic_minion then apply(act) end
			end
		end

		game:playSoundNear(self, "talents/spell_generic2")
		return true
	end,
	info = function(self, t)
		return ([[A surge of power radiates to all your minions, increasing their physical power, spellpower and accuracy by %d, their armour penetration by %d and their critical hit chance by %d for 6 turns.
		The effects will increase with your Spellpower.]]):
		format(t.getPower(self, t), t.getAPR(self, t), t.getCrit(self, t))
	end,
}

newTalent{
	name = "Dark Empathy",
	type = {"spell/necrotic-minions",4},
	require = spells_req4,
	points = 5,
	mode = "passive",
	getPerc = function(self, t) return self:combatTalentSpellDamage(t, 15, 80) end,
	info = function(self, t)
		return ([[You share your powers with your minions, granting them %d%% of your resistances and saves.
		The effect will increase with your Spellpower.]]):
		format(t.getPerc(self, t))
	end,
}
