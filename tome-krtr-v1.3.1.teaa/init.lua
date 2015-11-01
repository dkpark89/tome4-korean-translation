-- ToME - Tales of Maj'Eyal:
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

long_name = "Korean translation addon"
short_name = "koreanTr"
for_module = "tome"
version = {1,3,1}

weight = 10 -- 한글화가 먼저되고 다른 애드온이 실행되는게 애드온끼리의 충돌이 적을거 같아 무게를 가볍게 잡음 (100이 제일 나중인 듯)
tags = {'Korean','translation'}
author = { "nethackboard", "blank@blank.com" }
homepage = "http://nethack.byus.net/"
description = [[ToME4 korean translation add-on by nethack board

This is Korean Translation addon.
Many system(engine/mod) files are overloaded.
So can be conflict with other addon which modify system files.
And DO NOT USE when version is different.

우리말화(한글화) 애드온입니다!
이 애드온은 많은 시스템(engine/mod) 파일들을 덮어 씌웁니다 (현재 번역을 위해서는 이렇게 할 수 밖에 없습니다).
따라서 시스템 파일을 수정하는 다른 애드온과는 충돌이 발생할 확률이 높습니다. (대부분의 시스템 파일을 수정하지 않고 데이타만 추가하는 애드온과는 문제가 없습니다)
그리고, 버전이 다른 경우에는 사용하지 마십시오 (한글 애드온 버전 이후의 변경사항이 다시 덮어씌워져 에러가 날 수도 있고, 에러가 나지 않는다 해도 달라진 점이 적용되지 않는 경우가 많습니다). 
]]

overload = true
superload = true
hooks = false
data = false
