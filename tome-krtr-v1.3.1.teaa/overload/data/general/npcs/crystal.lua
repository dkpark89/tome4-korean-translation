local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_CRYSTAL",
	type = "immovable", subtype = "crystal", image = "npc/crystal_npc.png",
	display = "%", color=colors.WHITE,
	blood_color = colors.GREY,
	desc = "마법의 힘을 지닌, 빛나는 수정입니다.",
	body = { INVEN = 10 },
	autolevel = "caster",
	ai = "dumb_talented_simple", ai_state = { talent_in=1, },

	resolvers.drops{chance=15, nb=1, {type="jewelry"}},

	max_life = resolvers.rngavg(12,34),
	stats = { str=1, dex=5, mag=20, con=1 },
	global_speed_base = 0.7,
	infravision = 10,
	combat_def = 1,
	never_move = 1,
	slow_projectiles_outgoing = 50,
	blind_immune = 1,
	cut_immune = 1,
	fear_immune = 1,
	rank = 2,
	size_category = 2,
	poison_immune = 1,
	disease_immune = 1,
	no_breath = 1,
	confusion_immune = 1,
	disease_immune = 1,
	poison_immune = 1,
	see_invisible = 25,
	resolvers.talents{
		[Talents.T_PHASE_DOOR]=1,
	},

	lite = 2,
	not_power_source = {nature=true, technique=true},
}

newEntity{ name = "wisp",
	kr_name = "위습",
	type = "elemental", subtype = "light",
	display = "*", color=colors.YELLOW, tint=colors.YELLOW,
	desc = [[마법의 힘으로 이루어진 오브입니다. 밝은 빛을 내뿜으면서 부유하고 있으며, 닿으면 폭발합니다.]],
	combat = { dam=10, atk=5, apr=10, physspeed=1 },
	blood_color = colors.YELLOW,
	level_range = {1, nil},
	exp_worth = 1,
	max_life = 10,
	body = { INVEN = 1, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	no_drops = true, open_door = false,
	infravision = 10,
	rarity = false,
	rarity_summoned_crystal = 1,
	lite = 4,
	life_rating = 1, rank = 1, size_category = 1,
	autolevel = "caster",
	ai = "dumb_talented_simple", ai_state = { ai_move = "move_astar", talent_in = 1 },
	global_speed_base = 1,
	stats = { str = 9, dex = 20, mag = 20 },
	resolvers.talents{
		[Talents.T_EXPLODE] = 3,
	},
	no_breath = 1,
	blind_immune = 1,
	fear_immune = 1,
	rank = 2,
	size_category = 1,
	poison_immune = 1,
	disease_immune = 1,
	poison_immune = 1,
	stun_immune = 1,
	resolvers.sustains_at_birth(),
}

newEntity{ base = "BASE_NPC_CRYSTAL",
	name = "red crystal", color=colors.RED, tint=colors.RED, image = "npc/crystal_red.png",
	kr_name = "붉은 수정",
	desc = "붉은 수정입니다. 밝고 뜨거운 빛을 내뿜고 있습니다.",
	level_range = {1, nil}, exp_worth = 1,
	rarity = 1,
	resists = { [DamageType.FIRE] = 100, [DamageType.COLD] = -100 },
	resolvers.talents{
		[Talents.T_FLAME_BOLT]={base=1, every=1, max=20},
	},
	ingredient_on_death = "RED_CRYSTAL_SHARD",
}

newEntity{ base = "BASE_NPC_CRYSTAL",
	name = "white crystal", color=colors.WHITE, tint=colors.WHITE,
	kr_name = "흰 수정",
	desc = "흰 수정입니다. 밝고 차가운 빛을 내뿜고 있습니다.",
	level_range = {1, nil}, exp_worth = 1,
	rarity = 1,
	resists = { [DamageType.COLD] = 100, [DamageType.FIRE] = -100 },
	resolvers.talents{
		[Talents.T_ICE_BOLT]={base=1, every=1, max=20},
	}
}

newEntity{ base = "BASE_NPC_CRYSTAL",
	name = "black crystal", color=colors.BLACK, tint=colors.BLACK, image = "npc/crystal_black.png",
	kr_name = "검은 수정",
	desc = "검은 수정입니다. 주변의 모든 빛을 흡수하고 있습니다.",
	level_range = {3, nil}, exp_worth = 1,
	rarity = 2,
	resists = { [DamageType.LIGHT] = 100 ,[DamageType.DARKNESS] = -100 },
	resolvers.talents{
		[Talents.T_BLIGHT_BOLT]={base=1, every=1, max=20},
	}
}

newEntity{ base = "BASE_NPC_CRYSTAL",
	name = "crimson crystal", color=colors.DARK_RED, tint=colors.DARK_RED, image = "npc/crystal_darkred.png",
	kr_name = "핏빛 수정",
	desc = "핏빛 수정입니다. 피를 연상시키는 빛을 내뿜고 있습니다.",
	level_range = {3, nil}, exp_worth = 1,
	rarity = 3,
	resists = { [DamageType.LIGHT] = -100 },
	resolvers.talents{
		[Talents.T_BLOOD_GRASP]={base=1, every=7, max=5},
	}
}

newEntity{ base = "BASE_NPC_CRYSTAL",
	name = "blue crystal", color=colors.BLUE, tint=colors.BLUE, image = "npc/crystal_blue.png",
	kr_name = "푸른 수정",
	desc = "푸른 수정입니다. 대양의 파도같이 반짝이는 빛을 내고 있습니다.",
	level_range = {3, nil}, exp_worth = 1,
	rarity = 4,
	resists = { [DamageType.COLD] = -100 },
	resolvers.talents{
		[Talents.T_TIDAL_WAVE]={base=3, every=9, max=5},
	}
}

newEntity{ base = "BASE_NPC_CRYSTAL",
	name = "multi-hued crystal", color=colors.VIOLET, tint=colors.VIOLET, image = "npc/crystal_violet.png",
	kr_name = "무지개빛 수정",
	shader = "quad_hue",
	desc = "무지개빛 수정입니다. 다양한 색으로 반짝이고 있습니다.",
	level_range = {10, nil}, exp_worth = 1,
	rarity = 4,
	resists = { [DamageType.LIGHT] = 100 },
	resolvers.talents{
		[Talents.T_ELEMENTAL_BOLT]={base=1, every=7, max=5},
	},
	talent_cd_reduction={
		[Talents.T_ELEMENTAL_BOLT]=2,
	}
}

newEntity{ base = "BASE_NPC_CRYSTAL",
	name = "shimmering crystal", color=colors.GREEN, tint=colors.GREEN,
	kr_name = "어른거리는 수정",
	shader = "quad_hue",
	desc = "어른거리는 수정입니다. 빛의 오브가 주변을 맴돌고 있습니다.",
	level_range = {10, nil}, exp_worth = 1,
	rarity = 5,
	resists = { [DamageType.LIGHT] = 100 },
	summon = {{name = "wisp", number=3, hasxp=false, special_rarity="rarity_summoned_crystal"}},
	resolvers.talents{
		[Talents.T_SUMMON]=1,
	}
}
