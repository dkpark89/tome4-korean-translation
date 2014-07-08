﻿-- ToME - Tales of Maj'Eyal
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

quickEntity('@', {show_tooltip=true, name="Statue of King Tolak the Fair", kr_name = "공평한 왕, 톨락 동상", display='@', image="terrain/grass.png", add_displays = {mod.class.Grid.new{image="terrain/statues/statue_tolak.png", z=18, display_y=-1, display_h=2}}, color=colors.LIGHT_BLUE, block_move=function(self, x, y, e, act, couldpass) if e and e.player and act then game.party:learnLore("last-hope-tolak-statue") end return true end})
quickEntity('Z', {show_tooltip=true, name="Statue of King Toknor the Brave", kr_name = "용감한 왕, 토크놀 동상", display='@', image="terrain/grass.png", add_displays = {mod.class.Grid.new{image="terrain/statues/statue_toknor.png", z=18, display_y=-1, display_h=2}}, color=colors.LIGHT_BLUE, block_move=function(self, x, y, e, act, couldpass) if e and e.player and act then game.party:learnLore("last-hope-toknor-statue") end return true end})
quickEntity('Y', {show_tooltip=true, name="Statue of Queen Mirvenia the Inspirer", kr_name = "자애로운 여왕, 미르베니아 동상", display='@', image="terrain/grass.png", add_displays = {mod.class.Grid.new{image="terrain/statues/statue_mirvenia.png", z=18, display_y=-1, display_h=2}}, color=colors.LIGHT_BLUE, block_move=function(self, x, y, e, act, couldpass) if e and e.player and act then game.party:learnLore("last-hope-mirvenia-statue") end return true end})
quickEntity('X', {show_tooltip=true, name="Declaration of the Unification of the Allied Kingdoms", kr_name = "왕국연합의 통합 포고문", display='@', image="terrain/grass.png", add_displays = {mod.class.Grid.new{image="terrain/statues/monument_allied_kingdoms.png", z=18, display_y=-1, display_h=2}}, color=colors.LIGHT_BLUE, block_move=function(self, x, y, e, act, couldpass) if e and e.player and act then game.party:learnLore("last-hope-allied-kingdoms-foundation") end return true end})

-- defineTile section
defineTile("<", "GRASS_UP_WILDERNESS")
defineTile("#", "HARDWALL")
defineTile("&", "HARDMOUNTAIN_WALL")
defineTile("~", "DEEP_WATER")
defineTile("_", "FLOOR_ROAD_STONE")
defineTile("-", "GRASS_ROAD_STONE")
defineTile(".", "GRASS")
defineTile("t", "TREE")
defineTile(" ", "FLOOR")

defineTile('1', "HARDWALL", nil, nil, "SWORD_WEAPON_STORE")
defineTile('2', "HARDWALL", nil, nil, "AXE_WEAPON_STORE")
defineTile('3', "HARDWALL", nil, nil, "KNIFE_WEAPON_STORE")
defineTile('4', "HARDWALL", nil, nil, "MAUL_WEAPON_STORE")
defineTile('5', "HARDWALL", nil, nil, "HEAVY_ARMOR_STORE")
defineTile('6', "HARDWALL", nil, nil, "LIGHT_ARMOR_STORE")
defineTile('7', "HARDWALL", nil, nil, "CLOTH_ARMOR_STORE")
defineTile('8', "HARDWALL", nil, nil, "HERBALIST")
defineTile('9', "HARDWALL", nil, nil, "RUNES")
defineTile('A', "HARDWALL", nil, nil, "ARCHER_WEAPON_STORE")
defineTile('B', "HARDWALL", nil, nil, "LIBRARY")

defineTile('E', "HARDWALL", nil, nil, "ELDER")
defineTile('T', "HARDWALL", nil, nil, "TANNEN")
defineTile('H', "HARDWALL", nil, nil, "ALCHEMIST")
defineTile('M', "HARDWALL", nil, nil, "RARE_GOODS")
defineTile('F', "HARDWALL", nil, nil, "MELINDA_FATHER")


startx = 25
starty = 0
endx = 25
endy = 0

-- addSpot section
addSpot({6, 20}, "pop-quest", "farportal")
addSpot({7, 19}, "pop-quest", "farportal-player")
addSpot({10, 19}, "pop-quest", "tannen-remove")
addSpot({6, 19}, "pop-quest", "farportal-npc")

-- addZone section

-- ASCII map section
return [[
ttttttttttttttttttttttttt<tttttttttttttttttttttttt
ttttttttttttttttttttt~~~X-X~~~tttttttttttttttttttt
ttttttttttttttttt~~~~~~~.-.~~~~~~~tttttttttttttttt
ttttttttttttttt~~~~~~~~~.-.~~~~~~~~~tttttttttttttt
ttttttttttttt~~~~~~~~####.####~~~~~~~~tttttttttttt
tttttttttttt~~~~~~####_______####~~~~~~ttttttttttt
tttttttttt~~~~~~###   _     _   ###~~~~~~ttttttttt
ttttttttt~~~~~###     _ ### _     ###~~~~~tttttttt
tttttttt~~~~~##       _ ### _       ##~~~~~ttttttt
ttttttt~~~~###      ___ ### ___      ###~~~~tttttt
tttttt~~~~##       __   ###   __       ##~~~~ttttt
tttttt~~~##    #  __  #######  __       ##~~~ttttt
ttttt~~~~#    ### _  ##5# 7###  _  #     #~~~~tttt
tttt~~~~##   ##A# _ #6#     ### _ ###    ##~~~~ttt
tttt~~~##   ###   _ #         # _ M###    ##~~~ttt
ttt~~~~#     1#   _  _________  _   ###    #~~~~tt
ttt~~~##          ____~~~_~~~____   ##     ##~~~tt
tt~~~~#  ###      __~~~##.##~~~__           #~~~~t
tt~~~##  ###     __~~###@.t###~~__          ##~~~t
tt~~~#   #T#    __~~##ttY-Ztt##~~__          #~~~t
tt~~~#       ## _~~##tt-----tt##~~_ ##       #~~~t
t~~~##      ## __~##t---&-&---t##~__ ##      ##~~~
t~~~#      ### _~~#tt-&&&-&&&-tt#~~_ ###      #~~~
t~~~#      ##  _~##t--&&---&&--t##~_  ##      #~~~
t~~~#  ######  _~#tt-&&-###-&&-tt#~_  ######  #~~~
t~~~#  #####   _~#tt-&&-#E#-&&-tt#~_   #####  #~~~
t~~~#  #8####  _~#tt-&&-----&&-tt#~_  ##3#4#  #~~~
t~~~#      ##  _~##t--&&---&&--t##~_  ##      #~~~
t~~~#      ### _~~#tt-&&&&&&&-tt#~~_ ###      #~~~
t~~~##      ## __~##t---&&&---t##~__ ##      ##~~~
tt~~~#       2# _~~##tt-----tt##~~_ ##       #~~~t
tt~~~#          __~~##ttttttt##~~__          #~~~t
tt~~~##          __~~###ttt###~~__          ##~~~t
tt~~~~#           __~~~#####~~~__           #~~~~t
ttt~~~##           ___~~~~~~~___     ##    ##~~~tt
ttt~~~~#     ##      _________       ###   #~~~~tt
tttt~~~##   ###     #         #    ####   ##~~~ttt
tttt~~~~##   ####   ###     ###    ##H   ##~~~~ttt
ttttt~~~~#    ###    #### ####      #    #~~~~tttt
tttttt~~~##    #      9####B#           ##~~~ttttt
tttttt~~~~##            ###            ##~~~~ttttt
ttttttt~~~~###          ###          ###~~~~tttttt
tttttttt~~~~~##         ###         ##~~~~~ttttttt
ttttttttt~~~~~###       #F#       ###~~~~~tttttttt
tttttttttt~~~~~~###             ###~~~~~~ttttttttt
tttttttttttt~~~~~~####       ####~~~~~~ttttttttttt
ttttttttttttt~~~~~~~~#########~~~~~~~~tttttttttttt
ttttttttttttttt~~~~~~~~~~~~~~~~~~~~~tttttttttttttt
ttttttttttttttttt~~~~~~~~~~~~~~~~~tttttttttttttttt
ttttttttttttttttttttt~~~~~~~~~tttttttttttttttttttt]]
