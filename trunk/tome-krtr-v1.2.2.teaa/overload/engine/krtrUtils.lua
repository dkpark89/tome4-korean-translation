-- ToME4 korean Translation addon
-- utility functions for korean Translation 
-- 사용하려는 파일마다 상단부에 명령 추가 필요 : require "engine.krtrUtils"

-- 한글 글꼴 설정
--krFont = "/data/font/soya.ttf" -- 소야논8 글꼴(288kB), 글자 가독성이 좀 떨어짐
krFont = "/data/font/LexiSaebomR.ttf" -- 렉시새봄R 글꼴(1491kB)

local function findJosaType(str)
	local length = str:len()
	
	local c1, c2
	local c3 = str:lower():byte(length)
	
	local last = 0
	if ( length < 3 ) or ( c3 < 128 ) then
		--@ 여기오면 일단 한글은 아님

		--@ 여기에 숫자나 알파벳인지 검사해서 아니면 마지막 글자 빼고 재귀호출하는 코드 삽입 필요
		
		if ( c3 == '1' or c3 == '7' or c3 == '8' or c3 == 'l' or c3 == 'r' ) then
			last = 8 --@ 한글이 아니고, josa2를 사용하지만 '로'가 맞는 경우
		elseif ( c3 == '3' or c3 == '6' or c3 == '0' or c3 == 'm' or c3 == 'n' ) then
			last = 100 --@ 한글이 아니고, josa2를 사용하는 경우
		end  
	else --@ 한글로 추정 (정확히는 더 검사가 필요하지만..)
		c1 = str:byte(length-2)
		c2 = str:byte(length-1)
		
		last = ( (c1-234)*4096 + (c2-128)*64 + (c3-128) - 3072 )%28
	end
	
	return last
end

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
	elseif temp == 7 then
		josa1 = ""
		josa2 = "이"
		index = 7
	else
		if type(temp) == string then return str .. temp
		else return str end 
	end
	
	local type = findJosaType(str)
	
	if type == 0 or ( index == 4 and type == 8 ) then
		return str .. josa1
	else
		return str .. josa2
	end
end

function string.krSex(str)
	local ori = str:lower()
	if ori == "female" then return "여성"
	elseif ori == "male" then return "남성"
	else return str end
end

function string.krFontShape(str)
	-- 관련내용 /mod/dialogs/GameOptions.lua #162
	local ori = str:lower()
	if ori == "fantasy" then return "환상적"
	elseif ori == "basic" then return "기본"
	else return str end
end

function string.krHUDStyle(str)
	-- 관련내용 /mod/dialogs/GameOptions.lua #148
	local ori = str:lower()
	if ori == "minimalist" then return "깔끔"
	elseif ori == "classic" then return "고전"
	else return str end
end

function string.krUIStyle(str)
	-- 관련내용 /mod/dialogs/GameOptions.lua #134
	local ori = str:lower()
	if ori == "metal" then return "금속 예술품"
	elseif ori == "stone" then return "석기 도구"
	elseif ori == "simple" then return "가장 단순"
	else return str end
end

function string.krFontSize(str)
	-- 관련내용 /mod/dialogs/GameOptions.lua #174
	local ori = str:lower()
	if ori == "small" then return "작음"
	elseif ori == "normal" then return "보통"
	elseif ori == "big" then return "큼"
	else return str end
end

function string.krStat(str)
	local ori = str:lower()
	if ori == "strength" or ori == "str" then return "힘"
	elseif ori == "dexterity" or ori == "dex" then return "민첩"
	elseif ori == "constitution" or ori == "con" then return "체격"
	elseif ori == "magic" or ori == "mag" then return "마법"
	elseif ori == "willpower" or ori == "wil" then return "의지"
	elseif ori == "cunning" then return "교활함"
	elseif ori == "cun" then return "교활"
	elseif ori == "luck" or ori == "lck" then return "행운"
	else return str end
end

function string.krItemType(str)
	-- 관련내용 /data/general/objects/ 하위 파일들의 type, subtype
	local ori = str:lower()
	if ori == "alchemist-gem" then return "연금술 보석"
	elseif ori == "ammo" then return "탄환"
	elseif ori == "amulet" then return "목걸이"
	elseif ori == "analysis" then return "분석"
	elseif ori == "ankh" then return "성물"
	elseif ori == "armor" then return "갑옷"
	elseif ori == "arrow" then return "화살"
	elseif ori == "battleaxe" then return "대형도끼"
	elseif ori == "belt" then return "허리띠"
	elseif ori == "black" then return "검은색"
	elseif ori == "blue" then return "파란색"
	elseif ori == "charm" then return "부적"
	elseif ori == "chest" then return "상자"
	elseif ori == "cloak" then return "망토"
	elseif ori == "cloth" then return "의류"
	elseif ori == "corpse" then return "시체"
	elseif ori == "dagger" then return "단검"
	elseif ori == 'demonic' then return "악마"
	elseif ori == "digger" then return "곡괭이"
	elseif ori == "egg" then return "알"
	elseif ori == "fang" then return "이빨"
	elseif ori == "feet" then return "신발"
	elseif ori == "gem" then return "보석"
	elseif ori == "golem" then return "골렘"
	elseif ori == "greatmaul" then return "대형망치"
	elseif ori == "greatsword" then return "대검"
	elseif ori == "green" then return "녹색"
	elseif ori == "hands" then return "장갑"
	elseif ori == "head" then return "모자"
	elseif ori == "heart" then return "심장"
	elseif ori == "heavy" then return "중갑"
	elseif ori == "infusion" then return "주입물"
	elseif ori == "ingredient" then return "연금술재료"
	elseif ori == "inscription" then return "각인"
	elseif ori == "jewelry" then return "장신구"
	elseif ori == "last hope foundation" then return "마지막 희망의 역사"
	elseif ori == "lecture on humility" then return "강의:겸손"
	elseif ori == "light" then return "경갑"
	elseif ori == "lite" then return "조명"
	elseif ori == "longbow" then return "활"
	elseif ori == "longsword" then return "장검"
	elseif ori == "lore" then return "지식"
	elseif ori == "mace" then return "철퇴"
	elseif ori == "magic teaching" then return "강의:마법"
	elseif ori == "massive" then return "판갑"
	elseif ori == "mindstar" then return "마석"
	elseif ori == "misc" then return "기타"
	elseif ori == "money" then return "금화"
	elseif ori == "mount" then return "탈것"
	elseif ori == "multi-hued" then return "무지개빛"
	elseif ori == "mummy" then return "미이라붕대"
	elseif ori == "oceans" then return "해양"
	elseif ori == "orb" then return "오브"
	elseif ori == "organic" then return "장기"
	elseif ori == "potion" then return "물약"
	elseif ori == "projectile" then return "발사체"
	elseif ori == "red" then return "붉은색"
	elseif ori == "ring" then return "반지"
	elseif ori == "rod" then return "장대"
	elseif ori == "rune" then return "룬"
	elseif ori == "scroll" then return "두루마리"
	elseif ori == "sher'tul" then return "쉐르'툴"
	elseif ori == "shield" then return "방패"
	elseif ori == "shot" then return "투석"
	elseif ori == "skull" then return "두개골"
	elseif ori == "sling" then return "투석구"
	elseif ori == "southspar" then return "남쪽스파"
	elseif ori == "spellblaze" then return "마법폭발"
	elseif ori == "staff" then return "마법지팡이"
	elseif ori == "taint" then return "감염"
	elseif ori == "the great evil" then return "진정한 악"
	elseif ori == "tome" then return "서적"
	elseif ori == "tool" then return "도구"
	elseif ori == "torque" then return "주술고리"
	elseif ori == "totem" then return "토템"
	elseif ori == "trident" then return "삼지창"
	elseif ori == "trinket" then return "방울"
	elseif ori == "violet" then return "보라색"
	elseif ori == "wand" then return "마법봉"
	elseif ori == "waraxe" then return "전투도끼"
	elseif ori == "weapon" then return "무기"
	elseif ori == "whip" then return "채찍"
	elseif ori == "white" then return "흰색"
	elseif ori == "yellow" then return "노란색"
	else return str end
end

function string.krTalentType(str)
	-- 관련내용 /data/talents/ 하위 파일들
	local ori = str:lower()
	if ori == "technique" then return "물리"
	elseif ori == "celestial" then return "천공"
	elseif ori == "chronomancy" then return "시공"
	elseif ori == "corruption" then return "타락"
	elseif ori == "cunning" then return "교활"
	elseif ori == "cursed" then return "저주"
	elseif ori == "wild-gift" then return "자연의 권능"
	elseif ori == "base" then return "기본"
	elseif ori == "inscriptions" then return "각인"
	elseif ori == "race" then return "종족"
	elseif ori == "class" then return "직업"
	elseif ori == "tutorial" then return "입문"
	elseif ori == "psionic" then return "초능력"
	elseif ori == "spell" then return "주문"
	elseif ori == "undead" then return "언데드"
	elseif ori == "misc" then return "기타"
	elseif ori == "other" then return "기타"
	-- celestial
	elseif ori == "guardian" then return "고급 : 빛의 수호"
	elseif ori == "chants" then return "찬가"
	elseif ori == "light" then return "빛"
	elseif ori == "combat" then return "빛의 전투"
	elseif ori == "radiance" then return "광휘"
	elseif ori == "crusader" then return "성전사"
	elseif ori == "sunlight" then return "햇빛"
	elseif ori == "sun" then return "태양"
	elseif ori == "glyphs" then return "고급 : 문양"
	elseif ori == "twilight" then return "황혼"
	elseif ori == "star fury" then return "별의 분노"
	elseif ori == "hymns" then return "달의 송가"
	elseif ori == "circles" then return "고급 : 권역"
	elseif ori == "eclipse" then return "금환식"
	-- chronomancy
	elseif ori == "age manipulation" then return "시간 조작"
	elseif ori == "chronomancy" then return "시공"
	elseif ori == "energy" then return "에너지"
	elseif ori == "gravity" then return "중력"
	elseif ori == "matter" then return "물질"
	elseif ori == "paradox" then return "고급 : 괴리"
	elseif ori == "speed control" then return "속도 조절"
	elseif ori == "temporal combat" then return "시간 전투기술"
	elseif ori == "timeline threading" then return "고급 : 시간의 흐름"
	elseif ori == "time travel" then return "시간 여행"
	elseif ori == "spacetime folding" then return "시공간 접기"
	elseif ori == "spacetime weaving" then return "시공간 엮기"
	elseif ori == "temporal archery" then return "시간 사격기술"
	elseif ori == "anomalies" then return "이상현상"
	-- corruptions
	elseif ori == "sanguisuge" then return "거머리"
	elseif ori == "torment" then return "고문"
	elseif ori == "vim" then return "원혼과 원기"
	elseif ori == "bone" then return "해골"
	elseif ori == "hexes" then return "매혹술"
	elseif ori == "curses" then return "저주"
	elseif ori == "vile life" then return "불결한 생명력"
	elseif ori == "plague" then return "질병"
	elseif ori == "scourge" then return "재앙"
	elseif ori == "reaving combat" then return "오염된 전투"
	elseif ori == "blood" then return "선혈"
	elseif ori == "blight" then return "황폐"
	elseif ori == "shadowflame" then return "어둠의 열화"
	-- cunning
	elseif ori == "stealth" then return "은신"
	elseif ori == "trapping" then return "함정"
	elseif ori == "traps" then return "함정"
	elseif ori == "poisons" then return "고급 : 독"
	elseif ori == "dirty fighting" then return "비열한 전투"
	elseif ori == "lethality" then return "치명"
	elseif ori == "shadow magic" then return "그림자 마법"
	elseif ori == "ambush" then return "고급 : 그림자 습격"
	elseif ori == "survival" then return "생존"
	elseif ori == "tactical" then return "전략"
	elseif ori == "scoundrel" then return "무뢰배"
	elseif ori == "called shots" then return "착탄점"
	-- cursed
	elseif ori == "slaughter" then return "대학살"
	elseif ori == "endless hunt" then return "끝없는 사냥"
	elseif ori == "strife" then return "투쟁"
	elseif ori == "gloom" then return "침울한 기운"
	elseif ori == "rampage" then return "난폭"
	elseif ori == "predator" then return "포식자"
	elseif ori == "dark sustenance" then return "어둠의 생명유지"
	elseif ori == "force of will" then return "의지의 힘"
	elseif ori == "darkness" then return "어둠"
	elseif ori == "shadows" then return "그림자"
	elseif ori == "punishments" then return "처단"
	elseif ori == "one with shadows" then return "고급 : 그림자 합일" 
	elseif ori == "gestures" then return "저주받은 손짓"
	elseif ori == "cursed form" then return "저주받은 형상"
	elseif ori == "cursed aura" then return "저주받은 기운"
	elseif ori == "curses" then return "저주"
	elseif ori == "fears" then return "공포"
	-- wild gifts
	elseif ori == "call of the wild" then return "자연의 부름"
	elseif ori == "harmony" then return "조화"
	elseif ori == "antimagic" then return "반마법"
	elseif ori == "summoning (melee)" then return "소환 : 근거리"
	elseif ori == "summoning (distance)" then return "소환 : 원거리"
	elseif ori == "summoning (utility)" then return "소환 : 다용도"
	elseif ori == "summoning (augmentation)" then return "소환 : 강화"
	elseif ori == "summoning (advanced)" then return "소환 : 고급"
	elseif ori == "slime" then return "슬라임"
	elseif ori == "fungus" then return "미생물"
	elseif ori == "sand drake aspect" then return "모래 드레이크"
	elseif ori == "fire drake aspect" then return "화염 드레이크"
	elseif ori == "cold drake aspect" then return "냉기 드레이크"
	elseif ori == "storm drake aspect" then return "폭풍 드레이크"
	elseif ori == "venom drake aspect" then return "독 드레이크"
	elseif ori == "higher draconic abilities" then return "고급 : 용의 능력"
	elseif ori == "mindstar mastery" then return "마석 수련"
	elseif ori == "mucus" then return "점액"
	elseif ori == "ooze" then return "진흙"
	elseif ori == "moss" then return "이끼"
	elseif ori == "malleable body" then return "신체 변화"
	elseif ori == "oozing blades" then return "고급 : 점액 칼날"
	elseif ori == "corrosive blades" then return "고급 : 산성 칼날"
	elseif ori == "eyal's fury" then return "에이알의 분노"
	-- misc
	elseif ori == "horror" then return "공포"
	elseif ori == "horror techniques" then return "공포들의 물리기술"
	elseif ori == "horror spells" then return "공포들의 주문"
	elseif ori == "horror powers" then return "공포들의 힘"
	elseif ori == "inscriptions" then return "각인"
	elseif ori == "class" then return "직업"
	elseif ori == "race" then return "종족"
	elseif ori == "infusions" then return "인퓨전"
	elseif ori == "runes" then return "룬"
	elseif ori == "taints" then return "감염"
	elseif ori == "keepsake shadow" then return "'고통의 자취' 의 그림자"
	elseif ori == "objects" then return "물체"
	elseif ori == "sher'tul" then return "쉐르'툴"
	elseif ori == "fortress" then return "요새"
	elseif ori == "object spells" then return "물체 부여 주문"
	elseif ori == "object techniques" then return "물체 부여 기술"
	elseif ori == "higher" then return "하이어"
	elseif ori == "shalore" then return "샬로레"
	elseif ori == "thalore" then return "탈로레"
	elseif ori == "dwarf" then return "드워프"
	elseif ori == "halfling" then return "하플링"
	elseif ori == "orc" then return "오크"
	elseif ori == "yeek" then return "이크"
	elseif ori == "tutorial" then return "연습게임 전용 기술"
	-- psionic
	elseif ori == "absorption" then return "흡수"
	elseif ori == "projection" then return "발산"
	elseif ori == "psi-fighting" then return "염력 전투기술"
	elseif ori == "focus" then return "집중"
	elseif ori == "augmented mobility" then return "고급 : 기동성 강화"
	elseif ori == "augmented striking" then return "고급 : 타격"
	elseif ori == "voracity" then return "탐욕"
	elseif ori == "finer energy manipulations" then return "고급 : 염동력 미세 조작법"
	elseif ori == "mental discipline" then return "정신력 수련"
	elseif ori == "grip" then return "고급 : 염동적 악력"
	elseif ori == "kinetic mastery" then return "수련 : 동역학"
	elseif ori == "thermal mastery" then return "수련 : 열역학"
	elseif ori == "charged mastery" then return "수련 : 전하"
	elseif ori == "psi-archery" then return "고급 : 염동력 궁술"
	elseif ori == "greater psi-fighting" then return "고급 : 염력 전투기술"
	elseif ori == "brainstorm" then return "고급 : 창조적 발상"
	elseif ori == "discharge" then return "방출"
	elseif ori == "distortion" then return "왜곡"
	elseif ori == "dream forge" then return "꿈 속 대장간"
	elseif ori == "dream smith" then return "꿈의 망치"
	elseif ori == "nightmare" then return "악몽"
	elseif ori == "psychic assault" then return "정신적 타격"
	elseif ori == "slumber" then return "수면"
	elseif ori == "solipsism" then return "유아론"
	elseif ori == "thought-forms" then return "생각의 구현"
	elseif ori == "dreaming" then return "꿈"
	elseif ori == "mentalism" then return "심리주의"
	elseif ori == "feedback" then return "반작용"
	elseif ori == "trance" then return "최면"
	elseif ori == "possession" then return "소유"
	-- spells
	elseif ori == "arcane" then return "비술"
	elseif ori == "aether" then return "고급 비술 : 에테르"
	elseif ori == "fire" then return "화염"
	elseif ori == "wildfire" then return "고급 화염마법 : 열화"
	elseif ori == "earth" then return "땅"
	elseif ori == "stone" then return "고급 땅마법 : 암석"
	elseif ori == "water" then return "물"
	elseif ori == "ice" then return "고급 물마법 : 얼음"
	elseif ori == "air" then return "대기"
	elseif ori == "storm" then return "고급 대기마법 : 폭풍"
	elseif ori == "meta" then return "기초"
	elseif ori == "temporal" then return "시간"
	elseif ori == "phantasm" then return "환영"
	elseif ori == "enhancement" then return "강화"
	elseif ori == "conveyance" then return "이동"
	elseif ori == "divination" then return "예견"
	elseif ori == "aegis" then return "보호"
	elseif ori == "explosive admixtures" then return "폭발성 혼합물"
	elseif ori == "infusion" then return "주입"
	elseif ori == "golemancy" then return "골렘학"
	elseif ori == "advanced-golemancy" then return "고급 골렘학"
	elseif ori == "fire alchemy" then return "연금술 : 화염"
	elseif ori == "acid alchemy" then return "연금술 : 산성"
	elseif ori == "frost alchemy" then return "연금술 : 서리"
	elseif ori == "energy alchemy" then return "연금술 : 에너지"
	elseif ori == "stone alchemy" then return "연금술 : 암석"
	elseif ori == "staff combat" then return "지팡이 전투기술"
	elseif ori == "fighting" then return "전투기술"
	elseif ori == "golem" then return "골렘"
	elseif ori == "drolem" then return "드롤렘"
	elseif ori == "necrotic minions" then return "사령의 추종자"
	elseif ori == "advanced necrotic minions" then return "고급 사령의 추종자"
	elseif ori == "nightfall" then return "일몰"
	elseif ori == "shades" then return "고급 : 그림자"
	elseif ori == "necrosis" then return "사령술"
	elseif ori == "grave" then return "묘지"
	elseif ori == "animus" then return "증오"
	-- techniques
	elseif ori == "two-handed assault" then return "양손무기 타격기술"
	elseif ori == "berserker's strength" then return "광전사의 힘"
	elseif ori == "two-handed weapons" then return "양손무기 공격기술"
	elseif ori == "two-handed maiming" then return "양손무기 제압기술"
	elseif ori == "shield offense" then return "방패 공격기술"
	elseif ori == "shield defense" then return "방패 방어기술"
	elseif ori == "dual weapons" then return "쌍수 무기 수련"
	elseif ori == "dual techniques" then return "쌍수 무기 공격기술"
	elseif ori == "archery - base" then return "기본 사격기술"
	elseif ori == "archery - bows" then return "활 사격기술"
	elseif ori == "archery - slings" then return "투석구 사격기술"
	elseif ori == "archery training" then return "사격기술 수련"
	elseif ori == "archery prowess" then return "특수 사격기술"
	elseif ori == "archery excellence" then return "고급 사격기술"
	elseif ori == "superiority" then return "고급 전투기술 : 압도"
	elseif ori == "battle tactics" then return "고급 전투기술 : 전술"
	elseif ori == "warcries" then return "고급 전투기술 : 전투 함성"
	elseif ori == "bloodthirst" then return "고급 전투기술 : 피의 갈망"
	elseif ori == "field control" then return "전장 제어"
	elseif ori == "combat techniques" then return "일반 전투기술"
	elseif ori == "combat veteran" then return "베테랑의 전투기술"
	elseif ori == "combat training" then return "전투장비 수련"
	elseif ori == "magical combat" then return "마법 전투기술"
	elseif ori == "mobility" then return "기동성"
	elseif ori == "thuggery" then return "폭력"
	elseif ori == "acrobatics" then return "곡예"
	elseif ori == "buckler training" then return "방패 수련"
	elseif ori == "skirmisher - slings" then return "척후병 - 투석구"
	elseif ori == "tireless combatant" then return "지치지않는 전투원"
	elseif ori == "pugilism" then return "타격기"
	elseif ori == "finishing moves" then return "마무리 공격"
	elseif ori == "grappling" then return "잡기 기술"
	elseif ori == "unarmed discipline" then return "맨손전투 기본기 "
	elseif ori == "unarmed training" then return "맨손전투 수련"
	elseif ori == "conditioning" then return "신체 조절"
	elseif ori == "unarmed other" then return "기타 맨손 기술"
	-- uber
	elseif ori == "strength" then return "힘"
	elseif ori == "dexterity" then return "민첩"
	elseif ori == "constitution" then return "체격"
	elseif ori == "magic" then return "마법"
	elseif ori == "willpower" then return "의지"
	elseif ori == "cunning" then return "교활함"
	-- undeads
	elseif ori == "ghoul" then return "구울"
	elseif ori == "skeleton" then return "스켈레톤"
	elseif ori == "vampire" then return "흡혈귀"
	elseif ori == "lich" then return "리치"

	else return str end
end

function string.krActorType(str)
	local temp = str:krRace()
	if temp ~= str then return temp end 
	temp = str:krClass() 
	if temp ~= str then return temp else return str:krFaction() end
end

function string.krRace(str)
	-- 관련내용 /data/birth/races/ 하위 파일들, /data/general/npcs/ 하위 파일들, /data/zones/ 하위 파일 중 추가 생명체 정보, 기타 여러곳
	local ori = str:lower()
	if ori == "3head" then return "삼두형"
	elseif ori == "air" then return "공기"
	elseif ori == "all" then return "전체"
	elseif ori == "animal" then return "동물"
	elseif ori == "ant" then return "개미"
	elseif ori == "antimagic" then return "반마법"
	elseif ori == "aquatic" then return "수중생물"
	elseif ori == "bear" then return "곰"
	elseif ori == "bird" then return "조류"
	elseif ori == "bloated horror" then return "부풀어오른 공포"
	elseif ori == "blood" then return "피"
	elseif ori == "bone giant" then return "해골 거인"
	elseif ori == "canine" then return "갯과"
	elseif ori == "cold" then return "냉기"
	elseif ori == "companion" then return "동행"
	elseif ori == "construct" then return "구조체"
	elseif ori == "cornac" then return "코르낙"
	elseif ori == "corrupted" then return "타락한자"
	elseif ori == "critter" then return "미생물"
	elseif ori == "crystal" then return "수정"
	elseif ori == "demon" then return "악마"
	elseif ori == "dragon" then return "용"
	elseif ori == "drolem" then return "드롤렘"
	elseif ori == "dummy" then return "허수아비"
	elseif ori == "dwarf" then return "드워프"
	elseif ori == "eldritch" then return "섬뜩한자"
	elseif ori == "elemental" then return "정령"
	elseif ori == "elf" then return "엘프"
	elseif ori == "escort" then return "호위대상"
	elseif ori == "eyal" then return "에이알"
	elseif ori == "feline" then return "고양이과"
	elseif ori == "figment" then return "환상"
	elseif ori == "fire" then return "화염"
	elseif ori == "garkul spirit" then return "가르쿨의 영혼"
	elseif ori == "ghast" then return "가스트"
	elseif ori == "ghost" then return "유령"
	elseif ori == "ghoul" then return "구울"
	elseif ori == "giant" then return "거인"
	elseif ori == "girlfriend" then return "여자친구"
	elseif ori == "god" then return "신"
	elseif ori == "golem" then return "골렘"
	elseif ori == "guardian" then return "수호자"
	elseif ori == "halfling" then return "하플링"
	elseif ori == "harmless" then return "무해함"
	elseif ori == "higher" then return "하이어"
	elseif ori == "horror" then return "공포"
	elseif ori == "hostile" then return "적"
	elseif ori == "human" then return "인간"
	elseif ori == "humanoid" then return "영장류"
	elseif ori == "husk" then return "하수인"
	elseif ori == "hydra" then return "히드라"
	elseif ori == "ice" then return "얼음"
	elseif ori == "immovable" then return "부동생물"
	elseif ori == "insect" then return "곤충"
	elseif ori == "jelly" then return "젤리"
	elseif ori == "lich" then return "리치"
	elseif ori == "light" then return "빛"
	elseif ori == "lure" then return "미끼"
	elseif ori == "major" then return "상위"
	elseif ori == "minion" then return "부하"
	elseif ori == "minor" then return "하위"
	elseif ori == "minotaur" then return "미노타우르스"
	elseif ori == "molds" then return "곰팡이"
	elseif ori == "multihued" then return "무지개빛"
	elseif ori == "mummy" then return "미이라"
	elseif ori == "naga" then return "나가"
	elseif ori == "nightmare" then return "악몽"
	elseif ori == "oozes" then return "점액"
	elseif ori == "orb" then return "오브"
	elseif ori == "orc pride" then return "오크 긍지"
	elseif ori == "orc" then return "오크"
	elseif ori == "patrol" then return "순찰대"
	elseif ori == "plants" then return "식물"
	elseif ori == "player" then return "플레이어"
	elseif ori == "possesed" then return "소유"
	elseif ori == "projection" then return "투영체"
	elseif ori == "ritch" then return "릿치"
	elseif ori == "rodent" then return "설치류"
	elseif ori == "runic golem" then return "룬 골렘"
	elseif ori == "sand" then return "모래"
	elseif ori == "sandworm" then return "지렁이"
	elseif ori == "shade" then return "그림자"
	elseif ori == "shadow" then return "그림자"
	elseif ori == "shalore" then return "샬로레"
	elseif ori == "sher'tul" then return "쉐르'툴"
	elseif ori == "skeleton" then return "스켈레톤"
	elseif ori == "slave" then return "노예"
	elseif ori == "snake" then return "뱀"
	elseif ori == "special" then return "특수"
	elseif ori == "spider" then return "거미"
	elseif ori == "spiderkin" then return "거미류"
	elseif ori == "squadmate" then return "동료"
	elseif ori == "stone" then return "돌"
	elseif ori == "storm" then return "폭풍"
	elseif ori == "sunwall" then return "태양의 장벽"
	elseif ori == "swarms" then return "날벌레"
	elseif ori == "temporal" then return "시간"
	elseif ori == "terror" then return "공포"
	elseif ori == "thalore" then return "탈로레"
	elseif ori == "thought-form" then return "생각의 구현"
	elseif ori == "thrall" then return "노예"
	elseif ori == "totem" then return "토템"
	elseif ori == "training" then return "연습대상"
	elseif ori == "treant" then return "나무 정령"
	elseif ori == "troll" then return "트롤"
	elseif ori == "turtle" then return "거북이"
	elseif ori == "tutorial base" then return "연습게임용 종족"
	elseif ori == "tutorial basic" then return "연습게임용 종족"
	elseif ori == "tutorial human" then return "연습게임용 인간"
	elseif ori == "tutorial stats" then return "연습게임용 능력자"
	elseif ori == "undead" then return "언데드"
	elseif ori == "unknown" then return "알수없음"
	elseif ori == "vampire" then return "흡혈귀"
	elseif ori == "venom" then return "독성"
	elseif ori == "vermin" then return "해충"
	elseif ori == "void" then return "공허"
	elseif ori == "water" then return "물"
	elseif ori == "weapon" then return "무기"
	elseif ori == "wight" then return "와이트"
	elseif ori == "wild" then return "야생"
	elseif ori == "worms" then return "벌레"
	elseif ori == "xorn" then return "쏜"
	elseif ori == "yaech" then return "야크"
	elseif ori == "yeek" then return "이크"
	else return str end
end

function string.krClass(str)
	-- 관련내용 /data/birth/classes/ 하위 파일들, /data/general/npcs/ 하위 파일들, /data/zones/ 하위 파일 중 추가 생명체 정보
	local ori = str:lower()
	if ori == "higher" then return "하이어"
	elseif ori == "adventurer" then return "모험가"
	elseif ori == "afflicted" then return "고통받는 자"
	elseif ori == "cursed" then return "저주받은 자"
	elseif ori == "doomed" then return "파멸당한 자"
	elseif ori == "celestial" then return "천공의 사도"
	elseif ori == "sun paladin" then return "태양의 기사"
	elseif ori == "anorithil" then return "아노리실"
	elseif ori == "chronomancer" then return "시공 제어사"
	elseif ori == "paradox mage" then return "괴리 마법사"
	elseif ori == "temporal warden" then return "시간의 감시자"
	elseif ori == "defiler" then return "모독자"
	elseif ori == "reaver" then return "파괴자"
	elseif ori == "corruptor" then return "타락자"
	elseif ori == "mage" then return "마법사"
	elseif ori == "alchemist" then return "연금술사"
	elseif ori == "archmage" then return "마도사"
	elseif ori == "necromancer" then return "사령술사"
	elseif ori == "none" then return "없음"
	elseif ori == "psionic" then return "초능력자"
	elseif ori == "mindslayer" then return "정신 파괴자"
	elseif ori == "solipsist" then return "유아론자"
	elseif ori == "rogue" then return "도적"
	elseif ori == "shadowblade" then return "그림자 칼잡이"
	elseif ori == "marauder" then return "약탈자"
	elseif ori == "skirmisher" then return "척후병"
	elseif ori == "tutorial adventurer" then return "초보자 입문용 모험가"
	elseif ori == "warrior" then return "전사"
	elseif ori == "berserker" then return "광전사"
	elseif ori == "bulwark" then return "기사"
	elseif ori == "archer" then return "궁수"
	elseif ori == "arcane blade" then return "마법 전사"
	elseif ori == "brawler" then return "격투가"
	elseif ori == "wilder" then return "자연의 추종자"
	elseif ori == "summoner" then return "소환술사"
	elseif ori == "wyrmic" then return "용인"
	elseif ori == "oozemancer" then return "점액술사"
	else return str end
end

function string.krSize(str)
	-- 관련내용 /mod/class/Actor.lua #1675~1681
	local ori = str:lower()
	if ori == "tiny" then return "조그마함"
	elseif ori == "small" then return "작음"
	elseif ori == "medium" then return "평균적"
	elseif ori == "big" then return "큼"
	elseif ori == "huge" then return "거대함"
	elseif ori == "gargantuan" then return "어마어마함"
	else return str end
end

function string.krRank(str)
	-- 관련내용 /mod/class/Actor.lua #1661~1669
	local ori = str:lower()
	if ori == "normal" then return "평범함"
	elseif ori == "critter" then return "모자람"
	elseif ori == "elite" then return "정예"
	elseif ori == "rare" then return "희귀함"
	elseif ori == "unique" then return "유일함"
	elseif ori == "boss" then return "보스"
	elseif ori == "elite boss" then return "정예 보스"
	elseif ori == "god" then return "신"
	else return str end
end

function string.krFaction(str)
	-- 관련내용 /data/factions.lua (한글화에는 제외되는 파일)
	local ori = str:lower()
	if ori == "enemies" then return "적"
	elseif ori == "undead" then return "언데드"
	elseif ori == "allied kingdoms" then return "왕국연합"
	elseif ori == "shalore" then return "샬로레"
	elseif ori == "thalore" then return "탈로레"
	elseif ori == "iron throne" then return "철의 왕좌"
	elseif ori == "the way" then return "한길"
	elseif ori == "angolwen" then return "앙골웬"
	elseif ori == "keepers of reality" then return "현실 감시원"
	elseif ori == "dreadfell" then return "두려움의 영역"
	elseif ori == "temple of creation" then return "창조의 사원"
	elseif ori == "water lair" then return "수중단"
	elseif ori == "assassin lair" then return "암살단"
	elseif ori == "rhalore" then return "랄로레"
	elseif ori == "zigur" then return "지구르"
	elseif ori == "vargh republic" then return "바르그 공화국"
	elseif ori == "sunwall" then return "태양의 장벽"
	elseif ori == "orc pride" then return "오크 긍지"
	elseif ori == "orc-pride" then return "오크 긍지"
	elseif ori == "sandworm burrowers" then return "굴 파는 지렁이"
	elseif ori == "victim" then return "제물"
	elseif ori == "slavers" then return "노예"
	elseif ori == "sorcerers" then return "주술사"
	elseif ori == "fearscape" then return "공포의 영역"
	elseif ori == "sher'tul" then return "쉐르'툴"
	elseif ori == "neutral" then return "중립"
	elseif ori == "unaligned" then return "비동맹"
	elseif ori == "merchant caravan" then return "대상인"
	elseif ori == "point zero onslaught" then return "영점 맹습자"
	elseif ori == "point zero guardians" then return "영점 수호자"
	else return str end
end

function string.krMonth(str)
	-- 관련내용 /data/calendar_allied.lua, /data/calendar_dwarf.lua (둘다 한글화에는 제외되는 파일)
	local ori = str:lower()
	if ori == "wintertide" then return "밀려오는 겨울의 달"
	elseif ori == "allure" then return "매혹의 달"
	elseif ori == "regrowth" then return "재성장의 달"
	elseif ori == "time of balance" then return "균형의 달"
	elseif ori == "pyre" then return "장작더미의 달"
	elseif ori == "mirth" then return "환희의 달"
	elseif ori == "summertide" then return "밀려오는 여름의 달"
	elseif ori == "flare" then return "타오름의 달"
	elseif ori == "dusk" then return "황혼의 달"
	elseif ori == "time of equilibrium" then return "평정의 달"
	elseif ori == "haze" then return "아지랑이의 달"
	elseif ori == "decay" then return "부패의 달"
	-- 위는 동맹 연합 달력, 아래는 드워프 달력
	elseif ori == "iron" then return "철의 달"
	elseif ori == "steel" then return "강철의 달"
	elseif ori == "gold" then return "금의 달"
	elseif ori == "stralite" then return "스트라라이트의 달"
	elseif ori == "voratun" then return "보라툰의 달"
	elseif ori == "acquisition" then return "습득의 달"
	elseif ori == "profit" then return "이익의 달"
	elseif ori == "wealth" then return "재산의 달"
	elseif ori == "dearth" then return "결핍의 달"
	elseif ori == "loss" then return "손실의 달"
	elseif ori == "shortage" then return "부족의 달"
	else return str end
end

function string.krQuestStatus(str)
	-- 관련내용 /engine/Quest.lua #31~34 (한글화에는 제외되는 파일)
	local ori = str:lower()
	if ori == "active" then return "진행중"
	elseif ori == "completed" then return "완료"
	elseif ori == "done" then return "성공"
	elseif ori == "failed" then return "실패"
	else return str end
end

--@ 아래 번역은 지형 이름이 바뀌면 그에 맞춰 바꿀 필요가 있음
function string.krLoreCategory(str)
	-- 관련내용 /data/lore 하위 파일들 전체, /data/general/ 하위 일부, /data/quests/ 하위 일부, /data/zones/ 하위 일부
	local ori = str:lower()
	if ori == "adventures" then return "모험"
	elseif ori == "age of allure" then return "매혹의 시대"
	elseif ori == "age of dusk" then return "황혼의 시대"
	elseif ori == "age of pyre" then return "장작더미의 시대"
	elseif ori == "analysis" then return "분석"
	elseif ori == "ancient elven ruins" then return "고대 엘프의 폐허 "
	elseif ori == "angolwen" then return "앙골웬"
	elseif ori == "ardhungol" then return "알드훈골"
	elseif ori == "arena" then return "투기장"
	elseif ori == "artifacts" then return "아티팩트"
	elseif ori == "blighted ruins" then return "황폐화된 폐허"
	elseif ori == "boss" then return "보스"
	elseif ori == "daikara" then return "다이카라"
	elseif ori == "dogroth caldera" then return "도그로스 화산분지"
	elseif ori == "dreadfell" then return "두려움의 영역"
	elseif ori == "dreamscape" then return "꿈 속 여행"
	elseif ori == "eyal" then return "에이알"
	elseif ori == "fearscape" then return "공포의 영역"
	elseif ori == "highfin" then return "하이핀"
	elseif ori == "high peak" then return "최고봉"
	elseif ori == "history of the sunwall" then return "태양의 장벽에 대한 역사"
	elseif ori == "infinite dungeon" then return "무한의 던전"
	elseif ori == "iron throne" then return "철의 왕좌"
	elseif ori == "keepsake" then return "유품"
	elseif ori == "kor'pul" then return "코르'풀"
	elseif ori == "lake of nur" then return "누르 호수"
	elseif ori == "last hope graveyard" then return "마지막 희망 공동묘지"
	elseif ori == "last hope" then return "마지막 희망"
	elseif ori == "magic" then return "마법"
	elseif ori == "maze" then return "미궁"
	elseif ori == "misc" then return "기타"
	elseif ori == "myths of creation" then return "창조 신화"
	elseif ori == "old forest" then return "오래된 숲"
	elseif ori == "orc prides" then return "오크 긍지"
	elseif ori == "races" then return "종족"
	elseif ori == "rhaloren" then return "랄로레"
	elseif ori == "ruined dungeon" then return "파괴된 던전"
	elseif ori == "sandworm lair" then return "지렁이 굴"
	elseif ori == "scintillating caves" then return "번뜩이는 동굴"
	elseif ori == "shatur" then return "샤툴"
	elseif ori == "sher'tul" then return "쉐르'툴"
	elseif ori == "slazish fens" then return "슬라지쉬 늪지"
	elseif ori == "southspar" then return "남쪽스파"
	elseif ori == "spellblaze" then return "마법폭발"
	elseif ori == "temple of creation" then return "창조의 사원"
	elseif ori == "trollmire" then return "트롤 늪"
	elseif ori == "valley of the moon" then return "달의 계곡"
	elseif ori == "vault" then return "금고"
	elseif ori == "zigur" then return "지구르"
	else return str end
end

-- 새로운 물건의 랜덤 이름 생성시 확인되지 않은 이름의 접두사
function string.krUnIDPreName(str)
	-- 관련내용 /mod/class/GameState.lua #356
	local ori = str:lower()
	if ori == "glowing" then return "빛나는"
	elseif ori == "scintillating" then return "번뜩이는"
	elseif ori == "rune-covered" then return "룬으로 덮힌"
	elseif ori == "unblemished" then return "흠없는"
	elseif ori == "jewel-encrusted" then return "보석박힌"
	elseif ori == "humming" then return "웅웅거리는"
	elseif ori == "gleaming" then return "어슴푸레한"
	elseif ori == "immaculate" then return "티없는"
	elseif ori == "flawless" then return "흠없는"
	elseif ori == "crackling" then return "파직거리는"
	elseif ori == "glistening" then return "반짝이는"
	elseif ori == "plated" then return "도금된"
	elseif ori == "twisted" then return "꼬인"
	elseif ori == "silvered" then return "은색의"
	elseif ori == "faceted" then return "가공된"
	elseif ori == "faded" then return "바랜"
	elseif ori == "sigiled" then return "인장의"
	elseif ori == "shadowy" then return "어두운"
	elseif ori == "laminated" then return "박편의"
	else return str end
end

function string.krBossName(str)
	-- 관련내용 "#rng#"로 검색
	local ori = str:lower()
	if ori == "the invader" then return "침략자"
	elseif ori == "the tidebender" then return "조류 왜곡자"
	elseif ori == "the invoker" then return "호출자"
	elseif ori == "the bringer of doom" then return "파멸을 부르는 자"
	elseif ori == "the witherer" then return "시들어 버린 자"
	elseif ori == "the guardian" then return "수호자"
	elseif ori == "the fearsome" then return "무서운"
	elseif ori == "the neverdead" then return "죽지않는"
	elseif ori == "the silent death" then return "조용한 죽음"
	elseif ori == "the crusher" then return "분쇄자"
	else return str end
end

function string.krZonename(str)
	-- 관련내용 /data/maps/wilderness/eyal.lua #460~469, /data/maps/zones/shertul-fortress.lua #110~115, /data/maps/zones/shertul-fortress-caldizar.lua #42~43 (모두 한글화에는 제외되는 파일) 
	local ori = str:lower()
	if ori == "charred scar" then return "검게 탄 상처"
	elseif ori == "far east" then return "동대륙"
	elseif ori == "island of rel" then return "렐 섬"
	elseif ori == "maj'eyal" then return "마즈'에이알"
	elseif ori == "tar'eyal" then return "타르'에이알"
	-- 위는 세계지도, 아래는 쉐르'툴 요새
	elseif ori == "control room" then return "제어실"
	elseif ori == "portal room" then return "관문의 방"
	elseif ori == "storage room" then return "창고"
	elseif ori == "exploratory farportal" then return "탐험용 장거리 관문"
	elseif ori == "library of lost mysteries" then return "잊혀진 신비의 도서관"
	elseif ori == "temporal locked vault" then return "잠겨있는 시간의 금고"
	elseif ori == "experimentation room" then return "연습실"
	else return str end
end

function string.krT_Reason(str)
	-- 관련내용 /engine/interface/ActorTalents.lua #501~550 canLearnTalent 함수의 두번째 반환 값 내용들
	-- 직접 번역하면 수정할 곳이 너무 많아 출력부분에만 이함수 사용해서 바꿈. 사용처 : /mod/dialpgs/LevelupDialog.lua #268
	local ori = str:lower()
	if ori == "not enough stat" then return "능력치 부족"
	elseif ori == "not enough levels" then return "낮은 레벨"
	elseif ori == "missing dependency" then return "선행조건 불만족"
	elseif ori == "unknown talent type" then return "알 수 없는 기술 종류"
	elseif ori == "not enough talents of this type known" then return "알고 있는 같은 종류의 기술 갯수 부족"
	else return str end
end

function string.krRunningExplore(str)
	-- 관련내용 <running.explore>로 검색해서 나오는 단어들 - /mod/class/interface/PlayerExplore.lua #2100~2540
	local ori = str:lower()
	if ori == "door" then return "문"
	elseif ori == "exit" then return "출구"
	elseif ori == "item" then return "물건"
	elseif ori == "object" then return "물체"
	elseif ori == "portal" then return "관문"
	elseif ori == "special" then return "흥미로운 것"
	elseif ori == "unseen" then return "알수 없는 것"
	else return str end 
end

function string.krDifficulty(str)
	-- 관련내용 /data/birth/descriptors.lua 
	local ori = str:lower()
	if ori == "tutorial" then return "연습게임"
	elseif ori == "easy" then return "쉬움"
	elseif ori == "normal" then return "보통"
	elseif ori == "nightmare" then return "악몽"
	elseif ori == "insane" then return "정신나간"
	elseif ori == "madness" then return "미치광이"
	else return str end 
end

function string.krPermaDeath(str)
	-- 관련내용 /data/birth/descriptors.lua
	local ori = str:lower()
	if ori == "exploration" then return "탐사 모드"
	elseif ori == "adventure" then return "모험 모드"
	elseif ori == "roguelike" then return "로그라이크 모드"
	else return str end 
end

function string.krCampaign(str)
	-- 관련내용 /data/birth/worlds.lua
	local ori = str:lower()
	if ori == "maj'eyal" then return "마즈'에이알"
	elseif ori == "infinite" then return "무한의 던전"
	elseif ori == "arena" then return "투기장"
	else return str end 
end

function string.krItemShortName(str)
	-- 관련내용 /data/general/objects/에 있는 일반 아이템들의 short_name 들
	-- 장비창에서의 짧은 아이템 설명에 사용. /mod/class/Object.lua #417번 줄에서 사용
	local ori = str:lower()
	if ori == "alchemist" then return "연금술사"
	elseif ori == "ash" then return "물푸레나무"
	elseif ori == "b.steel" then return "푸른강철"
	elseif ori == "brass" then return "놋쇠"
	elseif ori == "cashmere" then return "캐시미어"
	elseif ori == "copper" then return "구리"
	elseif ori == "coral" then return "산호"
	elseif ori == "cured" then return "가공"
	elseif ori == "d.steel" then return "D.강철" --@ 현재 드워프강철(dwarven steel)과 심해강철(deep steel)이 둘다 d.steel로 표시됨
	elseif ori == "dragonbone" then return "용뼈"
	elseif ori == "drakeskin" then return "용가죽"
	elseif ori == "dwarven" then return "드워프"
	elseif ori == "e.silk" then return "엘프비단"
	elseif ori == "e.wood" then return "엘프나무"
	elseif ori == "elm" then return "느릅나무"
	elseif ori == "gold" then return "황금"
	elseif ori == "hardened" then return "경화"
	elseif ori == "iron" then return "무쇠"
	elseif ori == "linen" then return "리넨"
	elseif ori == "living" then return "생명"
	elseif ori == "mossy" then return "이끼"
	elseif ori == "mummy" then return "미이라"
	elseif ori == "orihalcum" then return "오리하르콘"
	elseif ori == "orite" then return "오라이트"
	elseif ori == "pulsing" then return "활력"
	elseif ori == "reinforced" then return "강화"
	elseif ori == "rough" then return "거친"
	elseif ori == "silk" then return "비단"
	elseif ori == "steel" then return "강철"
	elseif ori == "stralite" then return "스트라라이트"
	elseif ori == "thorny" then return "가시"
	elseif ori == "vined" then return "덩굴"
	elseif ori == "voratun" then return "보라툰"
	elseif ori == "woollen" then return "양모"
	elseif ori == "yew" then return "주목"
	else return str end 
end

function string.krKeywords(str)
	-- 관련내용 /data/general/objects/egos/에 있는 일반 아이템들의 keywords 들
	-- 장비창에서의 짧은 아이템 설명에 사용. 이 파일의 바로 다음에 있는 함수 table.krKeywordKeys() 에서 사용
	local ori = str:lower()
	local firstCh = ori:sub(1, 1) -- 속도를 위해 첫번자 글자만 떼서 먼저 검사
	if firstCh == "'" then
		if ori == "'acid res'" then return "산성저항"
		elseif ori == "'cold res'" then return "냉기저항"
		elseif ori == "'fire res'" then return "화염저항"
		elseif ori == "'fortif.'" then return "강화"
		elseif ori == "'g.warding'" then return "고급보호"
		elseif ori == "'implac.'" then return "확고함"
		elseif ori == "'invigor.'" then return "기운남"
		elseif ori == "'iron.throne'" then return "철의왕좌"
		elseif ori == "'lightning res'" then return "전기저항"
		elseif ori == "'overpower'" then return "압도적"
		elseif ori == "'serend.'" then return "운좋음"
		elseif ori == "'super.c'" then return "과충전"
		elseif ori == "'temporal res'" then return "시간저항"
		elseif ori == "'u.dodge'" then return "뛰어난회피"
		elseif ori == "'v.walkers'" then return "공허걸음"
		end
	elseif firstCh == 'a' then
		if ori == "absorb" then return "흡수"
		elseif ori == "accuracy" then return "정밀공격"
		elseif ori == "acid" then return "산성"
		elseif ori == "acid res" then return "산성저항"
		elseif ori == "acidic" then return "산성"
		elseif ori == "aegis" then return "수호"
		elseif ori == "aether" then return "에테르"
		elseif ori == "aetheric" then return "에테르적"
		elseif ori == "ailments" then return "질환"
		elseif ori == "alacrity" then return "기민함"
		elseif ori == "alchemist" then return "연금술사"
		elseif ori == "alchemy" then return "연금술"
		elseif ori == "amnesia" then return "망각"
		elseif ori == "ancient" then return "고대"
		elseif ori == "angolwen" then return "앙골웬"
		elseif ori == "annihilation" then return "섬멸"
		elseif ori == "arcana" then return "마력"
		elseif ori == "arcane" then return "마법"
		elseif ori == "archer" then return "궁수"
		elseif ori == "archmage" then return "마도사"
		elseif ori == "arcing" then return "전격"
		elseif ori == "augment" then return "증대"
		end
	elseif firstCh == 'b' then
		if ori == "backstab" then return "암습"
		elseif ori == "balance" then return "균형"
		elseif ori == "balanced" then return "균형"
		elseif ori == "balancing" then return "균형"
		elseif ori == "banishment" then return "추방"
		elseif ori == "barbed" then return "가시박힘"
		elseif ori == "battle" then return "전장"
		elseif ori == "battlemaster" then return "전장지배자"
		elseif ori == "bladed" then return "날카로움"
		elseif ori == "blasting" then return "폭발"
		elseif ori == "blaze" then return "방화범"
		elseif ori == "blight" then return "황폐"
		elseif ori == "blighted" then return "황폐"
		elseif ori == "blood" then return "핏빛마법"
		elseif ori == "bloodhexed" then return "핏빛매혹"
		elseif ori == "bloodlich" then return "핏빛리치"
		elseif ori == "blooming" then return "꽃피움"
		elseif ori == "blurring" then return "희미함"
		elseif ori == "bounder" then return "망나니"
		elseif ori == "brawler" then return "격투가"
		elseif ori == "breaching" then return "저항불가"
		elseif ori == "bright" then return "밝음"
		elseif ori == "brotherhood" then return "조직원"
		elseif ori == "brutal" then return "잔혹"
		elseif ori == "burglar" then return "강도"
		elseif ori == "burglary" then return "강도"
		elseif ori == "butchering" then return "도살자"
		end
	elseif firstCh == 'c' then
		if ori == "callers" then return "소환수"
		elseif ori == "capacity" then return "대용량"
		elseif ori == "carrying" then return "짐꾼"
		elseif ori == "catburglar" then return "밤도둑"
		elseif ori == "caustic" then return "부식성"
		elseif ori == "champion" then return "투사"
		elseif ori == "channeling" then return "공급"
		elseif ori == "chargedshield" then return "전하보호막"
		elseif ori == "chilling" then return "얼어붙음"
		elseif ori == "chosen" then return "선택받은자"
		elseif ori == "cinder" then return "타고남은"
		elseif ori == "clairvoyance" then return "천리안"
		elseif ori == "clarifying" then return "명석"
		elseif ori == "clarity" then return "명석함"
		elseif ori == "cleanse" then return "깨끗함"
		elseif ori == "cleansing" then return "깨끗함"
		elseif ori == "clearmind" then return "맑은정신"
		elseif ori == "cold" then return "냉기"
		elseif ori == "cold res" then return "냉기저항"
		elseif ori == "command" then return "명령"
		elseif ori == "con" then return "체격"
		elseif ori == "conjure" then return "요술"
		elseif ori == "conjurer" then return "요술사"
		elseif ori == "conjuring" then return "요술"
		elseif ori == "constitution" then return "체격"
		elseif ori == "containment" then return "억제"
		elseif ori == "corpselight" then return "시쳇빛"
		elseif ori == "corrosion" then return "부식"
		elseif ori == "corrosive" then return "부식성"
		elseif ori == "corruption" then return "타락"
		elseif ori == "coruscating" then return "번쩍임"
		elseif ori == "cosmic" then return "우주"
		elseif ori == "crackling" then return "파직거림"
		elseif ori == "crippling" then return "무력화"
		elseif ori == "cruel" then return "잔인함"
		elseif ori == "crushing" then return "파쇄"
		elseif ori == "crystal" then return "수정"
		elseif ori == "cun" then return "교활함"
		elseif ori == "cunning" then return "교활함"
		end
	elseif firstCh == 'd' then
		if ori == "dampening" then return "마력약화"
		elseif ori == "darkness" then return "어둠"
		elseif ori == "daylight" then return "태양빛"
		elseif ori == "deadly" then return "치명적"
		elseif ori == "decomp" then return "분해"
		elseif ori == "deep" then return "심해"
		elseif ori == "deeplife" then return "어두운삶"
		elseif ori == "defender" then return "수비수"
		elseif ori == "defiled" then return "모독"
		elseif ori == "deflection" then return "굴절"
		elseif ori == "delving" then return "탐구"
		elseif ori == "depths" then return "깊이"
		elseif ori == "detect" then return "탐정"
		elseif ori == "dex" then return "민첩"
		elseif ori == "dexterity" then return "민첩"
		elseif ori == "disengage" then return "철수"
		elseif ori == "dispeller" then return "떨쳐냄"
		elseif ori == "dispersion" then return "분산"
		elseif ori == "disruption" then return "방해"
		elseif ori == "dragon" then return "용"
		elseif ori == "dragonslayer" then return "용사냥꾼"
		elseif ori == "dreamer" then return "몽상가"
		elseif ori == "dreamers" then return "몽상가"
		elseif ori == "dwarven" then return "드워프"
		end
	elseif firstCh == 'e' then
		if ori == "earth" then return "대지"
		elseif ori == "earthen" then return "대지"
		elseif ori == "earthrunes" then return "대지룬"
		elseif ori == "eclipse" then return "일식"
		elseif ori == "eldoral" then return "엘도랄"
		elseif ori == "eldritch" then return "섬뜩함"
		elseif ori == "elemental" then return "다속성"
		elseif ori == "endurance" then return "인내"
		elseif ori == "enlight" then return "깨우침"
		elseif ori == "enraging" then return "격분"
		elseif ori == "enveloping" then return "감쌈"
		elseif ori == "epiphanous" then return "꿈에서깬"
		elseif ori == "erosion" then return "침식"
		elseif ori == "ethereal" then return "에테르"
		elseif ori == "evasion" then return "회피"
		elseif ori == "evisc" then return "내장적출"
		elseif ori == "eyal" then return "에이알"
		end
	elseif firstCh == 'f' then
		if ori == "fate" then return "숙명"
		elseif ori == "fearforged" then return "공포연마"
		elseif ori == "fearwoven" then return "공포엮음"
		elseif ori == "fiery" then return "타오름"
		elseif ori == "fire" then return "화염"
		elseif ori == "fire res" then return "화염저항"
		elseif ori == "firewall" then return "화염장벽"
		elseif ori == "flames" then return "불꽃"
		elseif ori == "flaming" then return "불꽃"
		elseif ori == "flight" then return "비행"
		elseif ori == "focus" then return "집중"
		elseif ori == "fog" then return "안개"
		elseif ori == "force" then return "힘찬"
		elseif ori == "forgotten" then return "망각"
		elseif ori == "fortif." then return "강화"
		elseif ori == "fortune" then return "행운"
		elseif ori == "frost" then return "냉기"
		elseif ori == "fungal" then return "균사체"
		end
	elseif firstCh == 'g' then
		if ori == "g.warding" then return "고급보호"
		elseif ori == "giant" then return "거인"
		elseif ori == "gifted" then return "천부적"
		elseif ori == "glacial" then return "얼어붙음"
		elseif ori == "gladiator" then return "검투사"
		elseif ori == "gloomy" then return "침울"
		elseif ori == "gravity" then return "중력"
		elseif ori == "greater" then return "대단함"
		elseif ori == "ground" then return "접지"
		elseif ori == "grounding" then return "접지"
		elseif ori == "guardian" then return "수호자"
		elseif ori == "guide" then return "몽상가"
		end
	elseif firstCh == 'h' then
		if ori == "halfling" then return "하플링"
		elseif ori == "hardened" then return "단단함"
		elseif ori == "harmonious" then return "조화"
		elseif ori == "hate" then return "증오"
		elseif ori == "hateful" then return "증오"
		elseif ori == "heal" then return "치료"
		elseif ori == "healing" then return "치료"
		elseif ori == "health" then return "생명력"
		elseif ori == "heaving" then return "괴력"
		elseif ori == "hero" then return "영웅"
		elseif ori == "heroic" then return "용맹"
		elseif ori == "horrifying" then return "무시무시함"
		elseif ori == "hungering" then return "갈망"
		elseif ori == "hunter" then return "사냥꾼"
		end
	elseif firstCh == 'i' then
		if ori == "icy" then return "냉기"
		elseif ori == "illumination" then return "조명"
		elseif ori == "illusion" then return "환상"
		elseif ori == "impenetrable" then return "뚫리지않음"
		elseif ori == "impervious" then return "불침투성"
		elseif ori == "implac." then return "확고함"
		elseif ori == "implacable" then return "확고함"
		elseif ori == "inertial" then return "관성"
		elseif ori == "infernal" then return "지옥"
		elseif ori == "inquisitors" then return "종교재판"
		elseif ori == "insid" then return "잠식형"
		elseif ori == "insulate" then return "단열"
		elseif ori == "insulating" then return "단열"
		elseif ori == "invasion" then return "침략"
		elseif ori == "invigor." then return "기운남"
		elseif ori == "invocation" then return "발동"
		elseif ori == "ire" then return "분노"
		elseif ori == "iron" then return "강철손"
		elseif ori == "iron.throne" then return "철의왕좌"
		end
	elseif firstCh == 'j' then
		if ori == "juggernaut" then return "저돌적전투"
		end
	elseif firstCh == 'k' then
		if ori == "kinesis" then return "염동력"
		elseif ori == "kinshield" then return "동역학보호막"
		elseif ori == "knowledge" then return "지식"
		end
	elseif firstCh == 'l' then
		if ori == "learwalker" then return "잎사귀걸음"
		elseif ori == "leech" then return "강탈"
		elseif ori == "life" then return "생명"
		elseif ori == "lifebinding" then return "생명이 얽힌"
		elseif ori == "light" then return "빛"
		elseif ori == "lightning" then return "전기"
		elseif ori == "lightning res" then return "전기저항"
		elseif ori == "linaniil" then return "리나니일"
		elseif ori == "living" then return "살아있음"
		end
	elseif firstCh == 'm' then
		if ori == "madness" then return "광기"
		elseif ori == "magehunters" then return "마법사냥꾼"
		elseif ori == "magelord" then return "마법군주"
		elseif ori == "magery" then return "마법사용자"
		elseif ori == "magewarrior" then return "전투마법사"
		elseif ori == "magic" then return "마법"
		elseif ori == "manaburning" then return "마나태움"
		elseif ori == "manastream" then return "마나흐름"
		elseif ori == "marauder" then return "약탈자"
		elseif ori == "marksman" then return "저격수"
		elseif ori == "marshal" then return "사령관"
		elseif ori == "marskman" then return "저격수"
		elseif ori == "massacre" then return "학살"
		elseif ori == "massive" then return "커다람"
		elseif ori == "mastery" then return "숙련"
		elseif ori == "mental" then return "정신력"
		elseif ori == "miasmic" then return "유해성"
		elseif ori == "might" then return "완력"
		elseif ori == "mighty" then return "강력"
		elseif ori == "mind" then return "정신"
		elseif ori == "mindblast" then return "염동력폭발"
		elseif ori == "mindcage" then return "정신보호"
		elseif ori == "mindcraft" then return "정신기술"
		elseif ori == "mindweaver" then return "마음엮음"
		elseif ori == "mindwoven" then return "정신엮임"
		elseif ori == "miner" then return "광부"
		elseif ori == "misery" then return "고통"
		elseif ori == "mitotic" then return "분열"
		elseif ori == "monstrous" then return "괴물"
		elseif ori == "moons" then return "달"
		elseif ori == "mountain" then return "산맥"
		elseif ori == "mule" then return "노새"
		elseif ori == "multihued" then return "무지개빛"
		elseif ori == "murder" then return "살인자"
		elseif ori == "murderer" then return "살인자"
		elseif ori == "mystic" then return "신비"
		end
	elseif firstCh == 'n' then
		if ori == "natural" then return "자연적"
		elseif ori == "nature" then return "자연"
		elseif ori == "natural resilience" then return "자연적활력"
		elseif ori == "natural_resilience" then return "자연적활력"
		elseif ori == "nightfall" then return "황혼"
		elseif ori == "nighthunter" then return "밤사냥꾼"
		elseif ori == "nightruned" then return "밤의룬"
		elseif ori == "nightwalker" then return "밤걸음"
		elseif ori == "nimble" then return "민첩함"
		elseif ori == "noble" then return "귀족"
		end
	elseif firstCh == 'o' then
		if ori == "overpower" then return "압도적"
		end
	elseif firstCh == 'p' then
		if ori == "painweaver" then return "고통엮음"
		elseif ori == "paradox" then return "괴리"
		elseif ori == "patience" then return "인내"
		elseif ori == "penetrating" then return "관통"
		elseif ori == "perfection" then return "완벽"
		elseif ori == "persecution" then return "박해"
		elseif ori == "perseverance" then return "불굴"
		elseif ori == "phase" then return "위상"
		elseif ori == "phasing" then return "위상"
		elseif ori == "physical" then return "물리"
		elseif ori == "piercing" then return "관통"
		elseif ori == "pilfering" then return "좀도둑"
		elseif ori == "pixie" then return "요정"
		elseif ori == "plague" then return "질병"
		elseif ori == "polar" then return "극지방"
		elseif ori == "potent" then return "잠재적"
		elseif ori == "power" then return "강력함"
		elseif ori == "precog" then return "예지"
		elseif ori == "predation" then return "포식"
		elseif ori == "preserve" then return "지킴"
		elseif ori == "primatic" then return "프리즘"
		elseif ori == "prismatic" then return "프리즘"
		elseif ori == "projection" then return "사출"
		elseif ori == "prot" then return "보호"
		elseif ori == "protect" then return "보호"
		elseif ori == "protection" then return "보호력"
		elseif ori == "psi" then return "염동술사"
		elseif ori == "psion" then return "염동력자"
		elseif ori == "psionic" then return "염동술사"
		elseif ori == "psychic" then return "초능력자"
		elseif ori == "psyport" then return "시공간변화"
		elseif ori == "purging" then return "정화"
		elseif ori == "purity" then return "정화"
		end
	elseif firstCh == 'q' then
		if ori == "quick" then return "빠름"
		elseif ori == "quickening" then return "빠른속도"
		elseif ori == "quiet" then return "조용함"
		end
	elseif firstCh == 'r' then
		if ori == "radiance" then return "광휘"
		elseif ori == "radiant" then return "빛남"
		elseif ori == "rage" then return "분노"
		elseif ori == "ranger" then return "순찰대"
		elseif ori == "ravager" then return "파괴자"
		elseif ori == "reckless" then return "무모함"
		elseif ori == "recursion" then return "재귀"
		elseif ori == "reflection" then return "반사"
		elseif ori == "regal" then return "당당함"
		elseif ori == "regen" then return "재생"
		elseif ori == "reinforced" then return "보강"
		elseif ori == "rejuv" then return "활기"
		elseif ori == "reknor" then return "레크놀"
		elseif ori == "resilience" then return "활력"
		elseif ori == "resilient" then return "활력"
		elseif ori == "resistance" then return "저항"
		elseif ori == "resonating" then return "공명"
		elseif ori == "restful" then return "편안함"
		elseif ori == "restorative" then return "회복"
		elseif ori == "rogue" then return "도둑"
		elseif ori == "ruin" then return "파멸"
		elseif ori == "runic" then return "룬"
		elseif ori == "rushing" then return "돌진"
		end
	elseif firstCh == 's' then
		if ori == "sanctity" then return "신성함"
		elseif ori == "sand" then return "모래"
		elseif ori == "sapper" then return "공병"
		elseif ori == "savage" then return "야만적"
		elseif ori == "savior" then return "구원자"
		elseif ori == "scholar" then return "학자"
		elseif ori == "scorching" then return "뜨거움"
		elseif ori == "scouring" then return "세척"
		elseif ori == "searing" then return "타는듯함"
		elseif ori == "seduction" then return "유혹"
		elseif ori == "seeing" then return "관측"
		elseif ori == "self" then return "자동장전"
		elseif ori == "sensing" then return "탐지"
		elseif ori == "sentry" then return "파수꾼"
		elseif ori == "serend." then return "운좋음"
		elseif ori == "shadow" then return "그림자"
		elseif ori == "shaloren" then return "샬로레"
		elseif ori == "shattering" then return "분쇄"
		elseif ori == "shearing" then return "절단"
		elseif ori == "shield" then return "방어"
		elseif ori == "shielding" then return "방어"
		elseif ori == "shimmering" then return "희미한빛"
		elseif ori == "shocking" then return "전기충격"
		elseif ori == "short" then return "짧은"
		elseif ori == "skylord" then return "천공군주"
		elseif ori == "slime" then return "끈적임"
		elseif ori == "slimeburst" then return "폭발형슬라임"
		elseif ori == "slimy" then return "끈적임"
		elseif ori == "smiths" then return "꿈만들기"
		elseif ori == "sneakthief" then return "은밀한도둑"
		elseif ori == "soldier" then return "병사"
		elseif ori == "solipsist" then return "유아론자"
		elseif ori == "sorcery" then return "주술"
		elseif ori == "sorrow" then return "슬픔"
		elseif ori == "soulsear" then return "시든영혼"
		elseif ori == "speed" then return "속도"
		elseif ori == "spellbinding" then return "마법집중"
		elseif ori == "spellcowled" then return "마법두건"
		elseif ori == "spellplated" then return "주문입힘"
		elseif ori == "spellstream" then return "주문흐름"
		elseif ori == "spellwoven" then return "주문엮임"
		elseif ori == "spiked" then return "가시돋음"
		elseif ori == "spiritwalk" then return "영혼인도"
		elseif ori == "stabilize" then return "안정됨"
		elseif ori == "stabilizing" then return "안정됨"
		elseif ori == "stable" then return "안정성"
		elseif ori == "stargazer" then return "점성가"
		elseif ori == "starlit" then return "점성가"
		elseif ori == "starseeker" then return "점성술사"
		elseif ori == "steady" then return "정밀함"
		elseif ori == "stealth" then return "은밀"
		elseif ori == "stone" then return "돌"
		elseif ori == "storm" then return "폭풍"
		elseif ori == "storms" then return "폭풍"
		elseif ori == "strength" then return "힘"
		elseif ori == "strikes" then return "공격"
		elseif ori == "striking" then return "타격"
		elseif ori == "summoners" then return "소환술사"
		elseif ori == "sun" then return "태양"
		elseif ori == "sunseal" then return "태양력"
		elseif ori == "super.c" then return "과충전"
		elseif ori == "surging" then return "쇄도"
		elseif ori == "survivor" then return "생존자"
		elseif ori == "swiftstrike" then return "빠른공격"
		end
	elseif firstCh == 't' then
		if ori == "telekinetic" then return "염력"
		elseif ori == "teleport" then return "순간이동"
		elseif ori == "tempestuous" then return "흉포"
		elseif ori == "temporal" then return "시간"
		elseif ori == "temporal res" then return "시간저항"
		elseif ori == "tenacity" then return "끈질김"
		elseif ori == "tentacled" then return "촉수"
		elseif ori == "thaloren" then return "탈로레"
		elseif ori == "thermshield" then return "열역학보호막"
		elseif ori == "thick" then return "두꺼움"
		elseif ori == "thorny" then return "가시돋음"
		elseif ori == "thought" then return "사색"
		elseif ori == "throat" then return "침묵"
		elseif ori == "thunder" then return "천둥"
		elseif ori == "time" then return "시간"
		elseif ori == "tireless" then return "끈기"
		elseif ori == "titan" then return "타이탄"
		elseif ori == "toknor" then return "토크놀"
		elseif ori == "torment" then return "고문"
		elseif ori == "tormentor" then return "고문함"
		elseif ori == "transcend" then return "초월"
		elseif ori == "trap" then return "함정파괴"
		elseif ori == "traveler" then return "여행자"
		elseif ori == "treant" then return "나무정령"
		elseif ori == "trickery" then return "책략"
		elseif ori == "troll" then return "트롤"
		elseif ori == "tundral" then return "툰드라"
		end
	elseif firstCh == 'u' then
		if ori == "u.dodge" then return "뛰어난회피"
		elseif ori == "umbral" then return "어두움"
		elseif ori == "undeterred" then return "저해되지않음"
		elseif ori == "unlife" then return "언데드"
		end
	elseif firstCh == 'v' then
		if ori == "v.walkers" then return "공허걸음"
		elseif ori == "vagrant" then return "부랑자"
		elseif ori == "valiance" then return "용기"
		elseif ori == "verdant" then return "파릇파릇함"
		elseif ori == "verdant avenger" then return "신록의 복수자"
		elseif ori == "verdant_avenger" then return "신록의 복수자"
		elseif ori == "vile" then return "혐오"
		elseif ori == "vision" then return "심안"
		elseif ori == "vitalizing" then return "활기참"
		elseif ori == "void" then return "공허"
		elseif ori == "voidstriker" then return "공허추격자"
		elseif ori == "volcanic" then return "화산"
		end
	elseif firstCh == 'w' then
		if ori == "wanderer" then return "방랑자"
		elseif ori == "war" then return "전투"
		elseif ori == "warbringer" then return "전투유발자"
		elseif ori == "ward" then return "보호"
		elseif ori == "wardens" then return "감시자"
		elseif ori == "warding" then return "보호"
		elseif ori == "warlord" then return "전투지휘자"
		elseif ori == "warlust" then return "전투욕구"
		elseif ori == "warmaker" then return "전투유발"
		elseif ori == "warrior" then return "전사"
		elseif ori == "watchleader" then return "감시통솔자"
		elseif ori == "webbed" then return "거미줄"
		elseif ori == "werebeast" then return "수인"
		elseif ori == "willpower" then return "의지"
		elseif ori == "wind" then return "바람"
		elseif ori == "wintry" then return "차가움"
		elseif ori == "wizard" then return "마법사"
		elseif ori == "wizardry" then return "마법"
		elseif ori == "woodsman" then return "나무꾼"
		elseif ori == "wrath" then return "격노"
		elseif ori == "wreckage" then return "잔해"
		elseif ori == "wyrms" then return "용"
		elseif ori == "wyrmwaxed" then return "용밀랍"
		end
	--elseif firstCh == 'x' then --@ 현재 없어 주석처리
	--elseif firstCh == 'y' then --@ 현재 없어 주석처리
	elseif firstCh == 'z' then
		if ori == "zealot" then return "광신도"
		end
	end
	return str  
end

function table.krKeywordKeys(t)
	-- 장비창에서의 짧은 아이템 설명에 사용. /mod/class/Object.lua #422번 줄에서 사용
	local tt = {}
	for k, e in pairs(t) do tt[#tt+1] = k:krKeywords() end
	return tt
end

function string.krBreath(str)
	-- 관련내용 "can_breath"로 검색해서 나오는 것들
	-- 사용장소 /mod/class/Object.lua #1040, #1262 - 숨쉬기 가능 장소 설명
	local ori = str:lower()
	if ori == "water" then return "물"
	--elseif ori == "" then return "" --@ 현재 'water'만 사용되고 있음
	else return str end 
end

function string.krEffectType(str)
	-- 관련내용 /data/timed_effects/하위에서 "type = "으로 검색해서 나오는 것들
	-- 상태 효과의 속성들. /mod/class/uiset/Minimalist.lua #1307, #1309, /mod/class/PalyerDisplay.lua #172, #174에서 사용
	local ori = str:lower()
	if ori == "physical" then return "물리적 효과"
	elseif ori == "magical" then return "마법적 효과"
	elseif ori == "mental" then return "정신적 효과"
	elseif ori == "other" then return "기타 효과"
	else return str end 
end

function string.krSaveType(str)
	-- /mod/class/uiset/Minimalist.lua #1307, /mod/class/PalyerDisplay.lua #172에서 사용
	local ori = str:lower()
	if ori == "physical save" then return "물리 내성"
	elseif ori == "spell save" then return "마법 내성"
	elseif ori == "mental save" then return "정신 내성"
	else return str end 
end

function string.krEffectSubtype(str)
	-- 관련내용 /data/timed_effects/하위에서 "subtype"으로 검색해서 나오는 것들
	-- 상태 효과의 속성들. 이 파일의 바로 아래 함수 table.krEffectKeys() 에서 사용
	local ori = str:lower()
	if ori == '"cross tier"' then return "단계 차이"
	elseif ori == 'acid' then return "산성"
	elseif ori == 'antimagic' then return "반마법"
	elseif ori == 'arcane' then return "마법"
	elseif ori == 'armour' then return "방어구"
	elseif ori == 'aura' then return "오러"
	elseif ori == 'bane' then return "맹독"
	elseif ori == 'blight' then return "황폐"
	elseif ori == 'blind' then return "실명"
	elseif ori == 'blood' then return "피"
	elseif ori == 'circle' then return "장치"
	elseif ori == 'coating' then return "코팅"
	elseif ori == 'cold' then return "냉기"
	elseif ori == 'concussion' then return "뇌진탕"
	elseif ori == 'confusion' then return "혼란"
	elseif ori == 'cooldown' then return "지연시간"
	elseif ori == 'corruption' then return "타락"
	elseif ori == 'cross tier' then return "단계 차이"
	elseif ori == 'curse' then return "저주"
	elseif ori == 'cut' then return "출혈"
	elseif ori == 'darkness' then return "어둠"
	elseif ori == 'disarm' then return "무장해제"
	elseif ori == 'disease' then return "질병"
	elseif ori == 'distortion' then return "왜곡"
	elseif ori == 'dominate' then return "지배"
	elseif ori == 'earth' then return "대지"
	elseif ori == 'eidolon' then return "에이돌론"
	elseif ori == 'evade' then return "회피"
	elseif ori == 'fear' then return "공포"
	elseif ori == 'fire' then return "화염"
	elseif ori == 'floor' then return "지형"
	elseif ori == 'focus' then return "집중"
	elseif ori == 'frenzy' then return "광란"
	elseif ori == 'gloom' then return "침울함"
	elseif ori == 'golem' then return "골렘"
	elseif ori == 'grapple' then return "잡기"
	elseif ori == 'heal' then return "치료"
	elseif ori == 'healing' then return "치료"
	elseif ori == 'hex' then return "매혹"
	elseif ori == 'ice' then return "얼음"
	elseif ori == 'infusion' then return "주입"
	elseif ori == 'light' then return "빛"
	elseif ori == 'lightning' then return "전기"
	elseif ori == 'madness' then return "광기"
	elseif ori == 'mind' then return "정신"
	elseif ori == 'miscellaneous' then return "기타"
	elseif ori == 'morale' then return "사기"
	elseif ori == 'moss' then return "이끼"
	elseif ori == 'mucus' then return "점액"
	elseif ori == 'nature' then return "자연"
	elseif ori == 'necrotic' then return "사령술"
	elseif ori == 'nightmare' then return "악몽"
	elseif ori == 'pain' then return "고통"
	elseif ori == 'phantasm' then return "환상"
	elseif ori == 'physical' then return "물리"
	elseif ori == 'pin' then return "속박"
	elseif ori == 'poison' then return "독"
	elseif ori == 'possess' then return "소유"
	elseif ori == 'predator' then return "포식자"
	elseif ori == 'prodigy' then return "특수기술"
	elseif ori == 'psionic' then return "초능력"
	elseif ori == 'psychic_drain' then return "정신적 흡수"
	elseif ori == 'race' then return "종족"
	elseif ori == 'radiance' then return "광휘"
	elseif ori == 'rune' then return "룬"
	elseif ori == 'sense' then return "감지"
	elseif ori == 'shield' then return "보호막"
	elseif ori == 'silence' then return "침묵"
	elseif ori == 'sleep' then return "수면"
	elseif ori == 'slow' then return "감속"
	elseif ori == 'space' then return "공간"
	elseif ori == 'spacetime' then return "시공간"
	elseif ori == 'speed' then return "가속"
	elseif ori == 'status' then return "상태"
	elseif ori == 'stone' then return "암석"
	elseif ori == 'stun' then return "기절"
	elseif ori == 'suffocating' then return "숨막힘"
	elseif ori == 'summon' then return "소환"
	elseif ori == 'sun' then return "태양"
	elseif ori == 'sunder' then return "손상"
	elseif ori == 'superiority' then return "압도"
	elseif ori == 'tactic' then return "전술"
	elseif ori == 'taint' then return "감염"
	elseif ori == 'telekinesis' then return "염동력"
	elseif ori == 'teleport' then return "순간이동"
	elseif ori == 'tempo' then return "전투적응"
	elseif ori == 'temporal' then return "시간"
	elseif ori == 'time' then return "시간왜곡"
	elseif ori == 'timeport' then return "시공간이동"
	elseif ori == 'undead' then return "언데드"
	elseif ori == 'unknown' then return "알수없음"
	elseif ori == 'vault' then return "금고"
	elseif ori == 'veil' then return "은폐"
	elseif ori == 'water' then return "물"
	elseif ori == 'willpower' then return "의지"
	elseif ori == 'wound' then return "상처"
	else return str end 
end

function table.krEffectKeys(t)
	-- 상태 효과의 속성들. /data/talents/misc/inscriptions.lua #277, #282, /mod/class/uiset/Minimalist.lua #1304, /mod/class/PlayerDisplay.lua #169 에서 사용
	local tt = {}
	for k, e in pairs(t) do tt[#tt+1] = k:krEffectSubtype() end
	return tt
end

function string.krRWKind(str)
	-- /mod/class/interface/Archery.lua #56번 줄에서 사용
	local ori = str:lower()
	if ori == "bow" then return "활"
	elseif ori == "sling" then return "투석구"
	else return str end 
end

function string.krHisHer(str)
	-- /data/timed_effects/mental.lua #3137, physical.lua #2126, #2679, /engine/interface/ActorTalents.lua #283, /mod/class/Actor.lua #2125, /mod/class/interface/Combat.lua #404 에서 사용
	local ori = str:lower()
	if ori == "her" then return "그녀"
	elseif ori == "his" then return "그"
	elseif ori == "it" then return "그것"
	else return str end 
end

function string.krMountainName(str)
	-- 전체 지도상의 산맥의 세부 이름들. /data/zones/wilderness/grids.lua #380 에서 사용
	local ori = str:lower()
	if ori == "mountain chain" then return "산맥"
	elseif ori == "daikara" then return "다이카라"
	elseif ori == "iron throne" then return "철의 왕좌"
	elseif ori == "volcanic mountains" then return "화산 지형"
	else return str end 
end

function string.krMerchantKind(str)
	-- /data/chat/last-hope-lost-merchant.lua #119번 줄에서 사용
	local ori = str:lower()
	if ori == "armours" then return "갑옷류"
	elseif ori == "weapons" then return "무기류"
	elseif ori == "misc" then return "기타 장구류"
	else return str end 
end
