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

function string.krStat(engStat)
	local ori = engStat:lower()
	if ori == "strength" or ori == "str" then return "힘"
	elseif ori == "dexterity" or ori == "dex" then return "민첩"
	elseif ori == "constitution" or ori == "con" then return "체격"
	elseif ori == "magic" or ori == "mag" then return "마법"
	elseif ori == "willpower" or ori == "wil" then return "의지"
	elseif ori == "cunning" then return "교활함"
	elseif ori == "cun" then return "교활"
	elseif ori == "luck" or ori == "lck" then return "행운"
	else return engStat end
end

function string.krDamageType(str)
	local ori = str:lower()
	if ori == "physical" then return "물리"
	elseif ori == "arcane" then return "마법"
	elseif ori == "fire" then return "화염"
	elseif ori == "cold" then return "추위"
	elseif ori == "lightning" then return "전기"
	elseif ori == "acid" then return "산성"
	elseif ori == "nature" then return "자연"
	elseif ori == "blight" then return "황폐"
	elseif ori == "light" then return "빛"
	elseif ori == "darkness" then return "어둠"
	elseif ori == "mind" then return "정신"
	elseif ori == "temporal" then return "시간"
	elseif ori == "lite" then return "조명"
	elseif ori == "silence" then return "침묵"
	elseif ori == "poison" then return "중독"
	elseif ori == "inferno" then return "열화"
	elseif ori == "bleed" then return "출혈"
	elseif ori == "slime" then return "슬라임"
	elseif ori == "dig" then return "굴착"
	elseif ori == "slow" then return "감속"
	elseif ori == "confusion" then return "혼돈"
	elseif ori == "sand" then return "수면"
	elseif ori == "pinning" then return "속박"
	elseif ori == "blindness" then return "실명"
	elseif ori == "ice" then return "냉동"
	elseif ori == "freeze" then return "빙결"
	elseif ori == "healing" then return "회복"
	elseif ori == "matter" then return "물질"
	elseif ori == "void" then return "공허"
	elseif ori == "gravity" then return "중력"
	
	elseif ori == "temporalstun" then return "시간적 기절"
	elseif ori == "break stealth" then return "은신해제"
	elseif ori == "arcane silence" then return "마법적 침묵"
	elseif ori == "% chance to silence target" then return "% 확률적 침묵"
	elseif ori == "blinding ink" then return "눈가리기"
	elseif ori == "bright light" then return "빛의 조명"
	elseif ori == "fire burn" then return "지속형 화염"
	elseif ori == "fireburn" then return "지속형 화염"
	elseif ori == "shadowflame" then return "어두운 화염"
	elseif ori == "darkstun" then return "암흑의 기절"
	elseif ori == "minions darkness" then return "어둠의 소환수"
	elseif ori == "firey no friends" then return "화염"
	elseif ori == "coldstun" then return "추위로 기절"
	elseif ori == "flameshock" then return "뜨거운 기절"
	elseif ori == "coldnevermove" then return "얼림"
	elseif ori == "sticky smoke" then return "끈적이는 연기"
	elseif ori == "acid blind" then return "신성 실명"
	elseif ori == "blinding darkness" then return "실명의 어둠"
	elseif ori == "lightning daze" then return "전기로 혼절"
	elseif ori == "wave" then return "파동"
	elseif ori == "fire knockback" then return "밀어내기 화염"
	elseif ori == "fire knockback mind" then return "정신적 밀어내기 화염"
	elseif ori == "darkness knockback" then return "밀어내기 어둠"
	elseif ori == "spell knockback" then return "밀어내기 주문"
	elseif ori == "mind knockback" then return "밀어내기 정신"
	elseif ori == "physknockback" then return "밀어내기 물리"
	elseif ori == "fear knockback" then return "밀어내기 공포"
	elseif ori == "spydric poison" then return "속박형 중독"
	elseif ori == "crippling poison" then return "장애형 중독"
	elseif ori == "insidious poison" then return "반회복형 중독"
	elseif ori == "physical + bleeding" then return "물리 + 출혈"
	elseif ori == "congeal time" then return "시간 멈춤"
	elseif ori == "time prison" then return "시간의 감옥"
	elseif ori == "% chances to confuse" then return "% 확률적 혼돈"
	elseif ori == "% chances to cause a gloom effect" then return "% 확률적 침울"
	elseif ori == "% chances to blind" then return "% 확률적 실명"
	elseif ori == "drain experience" then return "경험치 감소"
	elseif ori == "drain life" then return "생명력 감소"
	elseif ori == "drain vim" then return "정력 감소"
	elseif ori == "demonfire" then return "악마의 불길"
	elseif ori == "retch" then return "구역질"
	elseif ori == "holy light" then return "성스런 빛"
	elseif ori == "healing power" then return "회복력"
	elseif ori == "healing nature" then return "자연적 회복"
	elseif ori == "corrupted blood" then return "타락한 피"
	elseif ori == "blood boil" then return "끓는 피"
	elseif ori == "life leech" then return "생명력 강탈"
	elseif ori == "physical stun" then return "물리적 기절"
	elseif ori == "split bleed" then return "피 튀기기"
	elseif ori == "gravity pin" then return "중력적 속박"
	elseif ori == "repulsion" then return "혐오"
	elseif ori == "grow" then return "성장"
	elseif ori == "sanctity" then return "신성"
	elseif ori == "shiftingshadows" then return "그림자변형"
	elseif ori == "blazinglight" then return "타오르는 빛"
	elseif ori == "warding" then return "보호"
	elseif ori == "mindslow" then return "정신적 감속"
	elseif ori == "mindfreeze" then return "정신적 빙결"
	elseif ori == "implosion" then return "파열"
	elseif ori == "reverse aging" then return "젊어짐"
	elseif ori == "wasting" then return "낭비"
	elseif ori == "stop" then return "멈춤"
	elseif ori == "rethread" then return "재구축"
	elseif ori == "temporal echo" then return "시간의 메아리"
	elseif ori == "devour life" then return "생명력 먹어치우기"
	elseif ori == "chronoslow" then return "시간의 느려짐"
	elseif ori == "molten rock" then return "녹아내리는 바위"
	elseif ori == "entangle" then return "얽힘"
	elseif ori == "manaworm" then return "마나벌레"
	elseif ori == "void blast" then return "공허의 돌풍"
	elseif ori == "circle of death" then return "죽음의 고리"
	elseif ori == "rigor mortis" then return "사후 경직"
	elseif ori == "abyssal shroud" then return "심연의 덮개"
	elseif ori == "% chance to summon an orc spirit" then return "% 확률적 오크 정신체 소환"
	elseif ori == "nightmare" then return "악몽"
	elseif ori == "weakness" then return "허약"
	elseif ori == "temp effect" then return "일시적 효과"
	elseif ori == "manaburn" then return "마나태우기"
	elseif ori == "leaves" then return "나뭇잎"
	elseif ori == "distortion" then return "왜곡"
	elseif ori == "dreamforge" then return "꿈의 제조"
	elseif ori == "mucus" then return "점액"
	elseif ori == "acid disarm" then return "산성 무장해제"
	elseif ori == "corrosive acid" then return "산성 부식"
	elseif ori == "bouncing slime" then return "활발한 슬라임"
	else return str end
end

function string.krItemType(str)
	local ori = str:lower()
	if ori == "weapon" then return "무기"
	elseif ori == "armor" then return "갑옷"
	elseif ori == "tool" then return "도구"
	elseif ori == "misc" then return "기타"
	elseif ori == "gem" then return "보석"
	elseif ori == "jewelry" then return "장신구"
	elseif ori == "lite" then return "조명"
	elseif ori == "money" then return "금화"
	elseif ori == "mount" then return "탈것"
	elseif ori == "potion" then return "물약"
	elseif ori == "charm" then return "부적"
	elseif ori == "scroll" then return "마법기"
	elseif ori == "orb" then return "오브"
	elseif ori == "chest" then return "상자"
	elseif ori == "inscription" then return "각인"
	-- 위는 type, 아래는 subtype
	elseif ori == "battleaxe" then return "대형도끼"
	elseif ori == "greatmaul" then return "대형망치"
	elseif ori == "greatsword" then return "대검"
	elseif ori == "trident" then return "삼지창"
	elseif ori == "waraxe" then return "도끼"
	elseif ori == "longbow" then return "활"
	elseif ori == "cloak" then return "망토"
	elseif ori == "cloth" then return "의류"
	elseif ori == "digger" then return "곡괭이"
	elseif ori == "ingredient" then return "연금술재료"
	elseif ori == "hands" then return "장갑"
	elseif ori == "white" then return "흰색"
	elseif ori == "red" then return "붉은색"
	elseif ori == "yellow" then return "노란색"
	elseif ori == "green" then return "녹색"
	elseif ori == "blue" then return "파란색"
	elseif ori == "black" then return "검은색"
	elseif ori == "violet" then return "보라색"
	elseif ori == "heavy" then return "중갑"
	elseif ori == "feet" then return "신발"
	elseif ori == "head" then return "모자"
	elseif ori == "ring" then return "반지"
	elseif ori == "amulet" then return "목걸이"
	elseif ori == "dagger" then return "단검"
	elseif ori == "belt" then return "허리띠"
	elseif ori == "light" then return "경갑"
	elseif ori == "mace" then return "철퇴"
	elseif ori == "massive" then return "판갑"
	elseif ori == "mindstar" then return "마석"
	elseif ori == "golem" then return "골렘"
	elseif ori == "mummy" then return "미라붕대"
	elseif ori == "shield" then return "방패"
	elseif ori == "sling" then return "투석구"
	elseif ori == "staff" then return "마법지팡이"
	elseif ori == "longsword" then return "장검"
	elseif ori == "rod" then return "장대"
	elseif ori == "torque" then return "주술고리"
	elseif ori == "totem" then return "토템"
	elseif ori == "wand" then return "마법막대"
	elseif ori == "whip" then return "채찍"
	elseif ori == "infusion" then return "주입"
	elseif ori == "rune" then return "룬"
	elseif ori == "taint" then return "얼룩"
	elseif ori == "sher'tul" then return "쉐르툴"
	else return str end
end