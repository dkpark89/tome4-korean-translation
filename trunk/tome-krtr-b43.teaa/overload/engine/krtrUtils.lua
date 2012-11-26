-- ToME4 korean Translation addon
-- utility functions for korean Translation 
-- 사용하려는 파일마다 상단부에 명령 추가 필요 : require "engine.krtrUtils" 

function string.addJosa(str, temp)
	local josa1, josa2, index

	if temp == 1 or temp == "가" or temp == "이" then
		josa1 = "가"
		josa2 = "이"
		index = 1
	elseif temp == 2 or temp == "는" or temp == "은" then
		josa1 = "는"
		josa2 = "은"
		index = 2
	elseif temp == 3 or temp == "를" or temp == "을" then
		josa1 = "를"
		josa2 = "을"
		index = 3
	elseif temp == 4 or temp == "로" or temp == "으로" then
		josa1 = "로"
		josa2 = "으로"
		index = 4
	elseif temp == 5 or temp == "다" or temp == "이다" then
		josa1 = "다"
		josa2 = "이다"
		index = 5
	elseif temp == 6 or temp == "와" or temp == "과" then
		josa1 = "와"
		josa2 = "과"
		index = 6
	else
		if type(temp) == string then return str .. temp
		else return str end 
	end

	local length = str:len()
	
	if length < 3 then
		return str .. josa2
	end
	
	local c1 = str:byte(length-2)
	local c2 = str:byte(length-1)
	local c3 = str:byte(length)
	
	local last = ( (c1-234)*4096 + (c2-128)*64 + (c3-128) - 3072 )%28
	
	if last == 0 or ( index == 4 and last == 8 ) then
		return str .. josa1
	else
		return str .. josa2
	end
end
