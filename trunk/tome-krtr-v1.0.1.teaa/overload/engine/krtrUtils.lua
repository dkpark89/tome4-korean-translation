-- ToME4 korean Translation addon
-- utility functions for korean Translation 
-- 사용하려는 파일마다 상단부에 명령 추가 필요 : require "engine.krtrUtils"

-- 한글 글꼴 설정
--krFont = "/data/font/soya.ttf" -- 소야논8 글꼴(288kB), 글자 가독성이 좀 떨어짐
krFont = "/data/font/LexiSaebomR.ttf" -- 렉시새봄R 글꼴(1491kB)
--krFont = "/data/font/NanumGothicBold.ttf" -- 나눔고딕B 글꼴(4188kB)

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
		josa1 = "이"
		josa2 = ""
		index = 7
	else
		if type(temp) == string then return str .. temp
		else return str end 
	end

	local length = str:len()
	
	if length < 3 then
		return str .. josa1
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

function string.krSex(str)
	local ori = str:lower()
	if ori == "female" then return "여성"
	elseif ori == "male" then return "남성"
	else return str end
end

function string.krFontShape(str)
	-- 관련내용 /mod/dialogs/GameOptions.lua:174
	local ori = str:lower()
	if ori == "fantasy" then return "환상적"
	elseif ori == "basic" then return "기본"
	else return str end
end

function string.krHUDStyle(str)
	-- 관련내용 /mod/dialogs/GameOptions.lua:160
	local ori = str:lower()
	if ori == "minimalist" then return "깔끔"
	elseif ori == "classic" then return "기존"
	else return str end
end

function string.krUIStyle(str)
	-- 관련내용 /mod/dialogs/GameOptions.lua:148
	local ori = str:lower()
	if ori == "metal" then return "금속 예술품"
	elseif ori == "stone" then return "석기 도구"
	elseif ori == "simple" then return "가장 단순"
	else return str end
end

function string.krFontSize(str)
	-- 관련내용 /mod/dialogs/GameOptions.lua:186
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
	-- 관련내용 /data/general/objects/ 하위 파일들
	local ori = str:lower()
	if ori == "ammo" then return "탄환"
	elseif ori == "amulet" then return "목걸이"
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
	elseif ori == "digger" then return "곡괭이"
	elseif ori == "egg" then return "알"
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
	elseif ori == "light" then return "경갑"
	elseif ori == "lite" then return "조명"
	elseif ori == "longbow" then return "활"
	elseif ori == "longsword" then return "장검"
	elseif ori == "lore" then return "지식"
	elseif ori == "mace" then return "철퇴"
	elseif ori == "massive" then return "판갑"
	elseif ori == "mindstar" then return "마석"
	elseif ori == "misc" then return "기타"
	elseif ori == "money" then return "금화"
	elseif ori == "mount" then return "탈것"
	elseif ori == "multi-hued" then return "무지개빛"
	elseif ori == "mummy" then return "미이라붕대"
	elseif ori == "orb" then return "오브"
	elseif ori == "organic" then return "장기"
	elseif ori == "potion" then return "물약"
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
	elseif ori == "staff" then return "마법지팡이"
	elseif ori == "taint" then return "감염"
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
	---- celestial
	elseif ori == "guardian" then return "빛의 수호"
	elseif ori == "chants" then return "찬가"
	elseif ori == "light" then return "빛"
	elseif ori == "combat" then return "빛의 전투"
	elseif ori == "sun" then return "태양"
	elseif ori == "glyphs" then return "문양"
	elseif ori == "twilight" then return "황혼"
	elseif ori == "star fury" then return "별의 분노"
	elseif ori == "hymns" then return "달의 송가"
	elseif ori == "circles" then return "권역"
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
	elseif ori == "ooze" then return "진흙 덩어리"
	elseif ori == "moss" then return "이끼" --@@ 한글화 필요 (검수)
	elseif ori == "malleable body" then return "신체 변화"
	elseif ori == "oozing blades" then return "진흙 칼날" --@@ 한글화 필요 (검수)
	elseif ori == "corrosive blades" then return "부식성 칼날" --@@ 한글화 필요 (검수)
	-- misc 이 부분 모두 보강 필요
	elseif ori == "horror" then return "공포"
	elseif ori == "horror techniques" then return "공포들의 물리기술"
	elseif ori == "horror spells" then return "공포들의 주문"
	elseif ori == "horror powers" then return "공포들의 힘"
	elseif ori == "keepsake shadow" then return "'고통의 자취'의 그림자"
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
	elseif ori == "race" then return "종족"
	elseif ori == "class" then return "직업"
	elseif ori == "inscriptions" then return "각인"
	elseif ori == "infusions" then return "인퓨전"
	elseif ori == "runes" then return "룬"
	elseif ori == "taints" then return "감염"
	elseif ori == "objects" then return "물체"
	elseif ori == "other" then return "기타"
	-- psionic
	elseif ori == "absorption" then return "흡수"
	elseif ori == "projection" then return "발산"
	elseif ori == "psi-fighting" then return "염력 전투기술"
	elseif ori == "focus" then return "집중"
	elseif ori == "augmented mobility" then return "기동성 강화"
	elseif ori == "voracity" then return "탐욕"
	elseif ori == "finer energy manipulations" then return "염동력 미세 조작법"
	elseif ori == "mental discipline" then return "정신력 수련"
	elseif ori == "grip" then return "고급 : 염동적 악력"
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
	elseif ori == "stone alchemy" then return "연금술 : 암석"
	elseif ori == "staff combat" then return "지팡이 전투기술"
	elseif ori == "golem" then return "골렘"
	elseif ori == "fighting" then return "전투기술"
	elseif ori == "necrotic minions" then return "사령의 추종자"
	elseif ori == "advanced necrotic minions" then return "고급 사령의 추종자"
	elseif ori == "nightfall" then return "일몰"
	elseif ori == "shades" then return "그림자"
	elseif ori == "necrosis" then return "사령술"
	elseif ori == "grave" then return "묘지"
	-- techniques
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
	elseif ori == "pugilism" then return "타격기"
	elseif ori == "finishing moves" then return "마무리 공격"
	elseif ori == "grappling" then return "잡기기술"
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
	if ori == "3head" then return "머리3개"
	elseif ori == "air" then return "공기"
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
	elseif ori == "construct" then return "구조체"
	elseif ori == "cornac" then return "코르낙"
	elseif ori == "corrupted" then return "타락한자"
	elseif ori == "critter" then return "미생물"
	elseif ori == "crystal" then return "수정"
	elseif ori == "demon" then return "악마"
	elseif ori == "dragon" then return "용"
	elseif ori == "dwarf" then return "드워프"
	elseif ori == "eldritch" then return "섬뜩한자"
	elseif ori == "elemental" then return "정령"
	elseif ori == "elf" then return "엘프"
	elseif ori == "feline" then return "고양이과"
	elseif ori == "figment" then return "환상"
	elseif ori == "fire" then return "화염"
	elseif ori == "ghast" then return "가스트"
	elseif ori == "ghost" then return "유령"
	elseif ori == "ghoul" then return "구울"
	elseif ori == "giant" then return "거인"
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
	elseif ori == "hydra" then return "히드라"
	elseif ori == "ice" then return "얼음"
	elseif ori == "immovable" then return "부동생물"
	elseif ori == "insect" then return "곤충"
	elseif ori == "jelly" then return "젤리"
	elseif ori == "lich" then return "리치"
	elseif ori == "light" then return "빛"
	elseif ori == "lure" then return "미끼"
	elseif ori == "major" then return "상위"
	elseif ori == "minor" then return "하위"
	elseif ori == "minotaur" then return "미노타우르스"
	elseif ori == "molds" then return "곰팡이"
	elseif ori == "multihued" then return "무지개빛"
	elseif ori == "mummy" then return "미이라"
	elseif ori == "naga" then return "나가"
	elseif ori == "oozes" then return "진흙 덩어리"
	elseif ori == "orc pride" then return "오크 무리"
	elseif ori == "orc" then return "오크"
	elseif ori == "patrol" then return "순찰대"
	elseif ori == "plants" then return "식물"
	elseif ori == "ritch" then return "릿치"
	elseif ori == "rodent" then return "바퀴벌레"
	elseif ori == "runic golem" then return "룬 골렘"
	elseif ori == "sand" then return "모래"
	elseif ori == "sandworm" then return "지렁이"
	elseif ori == "shade" then return "그림자"
	elseif ori == "shalore" then return "샬로레"
	elseif ori == "sher'tul" then return "쉐르'툴"
	elseif ori == "skeleton" then return "스켈레톤"
	elseif ori == "snake" then return "뱀"
	elseif ori == "special" then return "특수"
	elseif ori == "spider" then return "거미"
	elseif ori == "spiderkin" then return "거미류"
	elseif ori == "stone" then return "돌"
	elseif ori == "storm" then return "폭풍"
	elseif ori == "sunwall" then return "태양의 장벽"
	elseif ori == "swarms" then return "날벌레"
	elseif ori == "temporal" then return "시간"
	elseif ori == "thalore" then return "탈로레"
	elseif ori == "thought-form" then return "생각의 구현"
	elseif ori == "totem" then return "토템"
	elseif ori == "treant" then return "나무 정령"
	elseif ori == "troll" then return "트롤"
	elseif ori == "turtle" then return "거북이"
	elseif ori == "tutorial base" then return "연습게임용 종족"
	elseif ori == "tutorial human" then return "연습게임용 인간"
	elseif ori == "tutorial stats" then return "연습게임용 능력자"
	elseif ori == "undead" then return "언데드"
	elseif ori == "unknown" then return "알수없음"
	elseif ori == "vampire" then return "흡혈귀"
	elseif ori == "venom" then return "독성"
	elseif ori == "vermin" then return "해충"
	elseif ori == "void" then return "공허"
	elseif ori == "water" then return "물"
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
	elseif ori == "shadowblade" then return "쉐도우 블레이드"
	elseif ori == "marauder" then return "약탈자"
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
	elseif ori == "oozemancer" then return "진흙술사" --@@ 한글화 필요 (검수)
	else return str end
end

function string.krSize(str)
	-- 관련내용 /mod/class/Actor.lua:1347~1357
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
	-- 관련내용 /mod/class/Actor.lua:1334~1345
	local ori = str:lower()
	if ori == "normal" then return "평범함"
	elseif ori == "critter" then return "모자람"
	elseif ori == "elite" then return "정예"
	elseif ori == "rare" then return "희귀함"
	elseif ori == "unique" then return "유일함"
	elseif ori == "boss" then return "보스"
	elseif ori == "elite boss" then return "정예 보스"
	else return str end
end

function string.krFaction(str)
	-- 관련내용 /data/factions.lua (한글화에는 제외되는 파일)
	local ori = str:lower()
	if ori == "rhalore" then return "랄로레"
	elseif ori == "fearscape" then return "공포의 영역"
	elseif ori == "orc pride" then return "오크 무리"
	elseif ori == "sunwall" then return "태양의 장벽"
	elseif ori == "zigur" then return "지구르"
	elseif ori == "angolwen" then return "앙골웬"
	elseif ori == "iron throne" then return "철의 왕좌"
	elseif ori == "undead" then return "언데드"
	elseif ori == "shalore" then return "샬로레"
	elseif ori == "thalore" then return "탈로레"
	elseif ori == "allied kingdoms" then return "왕국연합"
	elseif ori == "the way" then return "한길"
	elseif ori == "enemies" then return "적"
	elseif ori == "keepers of reality" then return "현실 감시원"
	elseif ori == "dreadfell" then return "두려움의 영역"
	elseif ori == "temple of creation" then return "창조의 사원"
	elseif ori == "water lair" then return "수중단"
	elseif ori == "assassin lair" then return "암살단"
	elseif ori == "vargh republic" then return "바르그 공화국"
	elseif ori == "sandworm burrowers" then return "굴 파는 지렁이"
	elseif ori == "victim" then return "제물"
	elseif ori == "slavers" then return "노예"
	elseif ori == "sorcerers" then return "주술사"
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
	-- 관련내용 /engine/Quest.lua:31~34 (한글화에는 제외되는 파일)
	local ori = str:lower()
	if ori == "active" then return "진행중"
	elseif ori == "completed" then return "완료"
	elseif ori == "done" then return "성공"
	elseif ori == "failed" then return "실패"
	else return str end
end

--@@ 아래 번역은 지형 이름들을 번역하에 그에 맞춰 바꿀 필요가 있음
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
	elseif ori == "high peak" then return "최고봉"
	elseif ori == "history of the sunwall" then return "태양의 장벽에 대한 역사"
	elseif ori == "infinite dungeon" then return "무한의 던전"
	elseif ori == "iron throne" then return "철의 왕좌"
	elseif ori == "keepsake" then return "유품"
	elseif ori == "kor'pul" then return "코르'풀"
	elseif ori == "last hope graveyard" then return "마지막 희망 공동묘지"
	elseif ori == "last hope" then return "마지막 희망"
	elseif ori == "maze" then return "미궁"
	elseif ori == "misc" then return "기타"
	elseif ori == "myths of creation" then return "창조 신화"
	elseif ori == "old forest" then return "오래된 숲"
	elseif ori == "orc prides" then return "오크 무리"
	elseif ori == "races" then return "종족"
	elseif ori == "rhaloren" then return "랄로레"
	elseif ori == "ruined dungeon" then return "파괴된 던전"
	elseif ori == "sandworm lair" then return "지렁이 굴"
	elseif ori == "scintillating caves" then return "번뜩이는 동굴"
	elseif ori == "shatur" then return "샤툴"
	elseif ori == "sher'tul" then return "쉐르'툴"
	elseif ori == "slazish fens" then return "슬라지쉬 늪지"
	elseif ori == "southspar" then return "남쪽스파" --@@?? spar의 뜻
	elseif ori == "spellblaze" then return "마법폭발"
	elseif ori == "temple of creation" then return "창조의 사원"
	elseif ori == "trollmire" then return "트롤 늪"
	elseif ori == "vault" then return "금고"
	elseif ori == "zigur" then return "지구르"
	else return str end
end

-- 새로운 물건의 랜덤 이름 생성시 확인되지 않은 이름의 접두사
function string.krUnIDPreName(str)
	-- 관련내용 /mod/class/GameState.lua:348
	local ori = str:lower()
	if ori == "glowing" then return "빛나는"
	elseif ori == "scintillating" then return "번뜩이는"
	elseif ori == "rune-covered" then return "룬으로 덮힌"
	elseif ori == "unblemished" then return "흠없는"
	elseif ori == "jewel-encrusted" then return "보석박힌"
	else return str end
end

function string.krBossName(str)
	-- 관련내용 /mod/class/GameState.lua:348
	local ori = str:lower()
	if ori == "the guardian" then return "수호자"
	elseif ori == "the invader" then return "침략자"
	elseif ori == "the tidebender" then return "조류 왜곡자"
	elseif ori == "the invoker" then return "호출자"
	elseif ori == "the bringer of doom" then return "파멸을 부르는 자"
	-- 아래 관련 내용 /data/zones/slime-tunnels/grid.lua:62, 82, 102, 122
	elseif ori == "the fearsome" then return "무서운"
	elseif ori == "the neverdead" then return "죽지않는"
	elseif ori == "the silent death" then return "조용한 죽음"
	elseif ori == "the crusher" then return "분쇄자"
	else return str end
end

function string.krZonename(str)
	-- 관련내용 /data/maps/wilderness/eyal.lua:454~463, /data/maps/zones/shertul-fortress.lua:62~66, /data/maps/zones/shertul-fortress-caldizar.lua:42~43 (모두 한글화에는 제외되는 파일) 
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
	else return str end
end

function string.krT_Reason(str)
	-- 관련내용 /engine/interface/ActorTalents.lua:471~520 canLearnTalent 함수의 두번째 반환 값 내용들
	-- 직접 번역하면 수정할 곳이 너무 많아 출력부분에만 이함수 사용해서 바꿈. 사용처 : /mod/dialpgs/LevelupDialog.lua:265
	local ori = str:lower()
	if ori == "not enough stat" then return "능력치 부족"
	elseif ori == "not enough levels" then return "낮은 레벨"
	elseif ori == "missing dependency" then return "선행조건 불만족"
	elseif ori == "unknown talent type" then return "알 수 없는 기술 종류"
	elseif ori == "not enough talents of this type known" then return "알고 있는 같은 종류의 기술 갯수 부족"
	else return str end
end
