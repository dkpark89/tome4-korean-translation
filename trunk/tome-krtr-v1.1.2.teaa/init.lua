-- ToME - Tales of Maj'Eyal:
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

long_name = "Korean translation addon"
short_name = "krTr"
for_module = "tome"
version = {1,1,2}

weight = 10 -- 한글화가 먼저되고 다른 애드온이 실행되는게 애드온끼리의 충돌이 적을거 같아 무게를 가볍게 잡음 (100이 제일 나중인 듯)
tags = {'Korean','translation'}
author = { "nethackboard", "blank@blank.com" }
homepage = "http://tome.te4.org/"
description = [[ToME4 korean translation add-on by nethack board

우리말화(한글화) 애드온입니다!]]

overload = true
superload = false
hooks = false
data = false
