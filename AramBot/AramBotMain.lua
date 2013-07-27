--[[
	Aram bot by Levrondvu
	---------------------------------
	 No idea who is the author of target selector, but still credits go to him
	---------------------------------------
	 following system copied from Λnonymous
	------------------------------------
	Auto Level Spells
	v1.05

	Levels the abilities of every single Champion
	Written by grey
	added some champs.
	
	Dont forget to check the abilitySequence of your champion
	Thanks to Zynox and PedobearIGER who gave me some ideas and tipps.
	Some of the default ability sequences are from mobafire, some from solomid (thx@crazy) :)
]]


local ts = TargetSelector(TARGET_LOW_HP,1000,false)
local nextdelay = 0
local Allies = {}
local Towers = {}
local follow = nil
local startTime 
local currentTime

local info

local blueInhibitor={x=3333,y=3333}
local blueTurret1={x=3900,y=3900}
local blueTurret2={x=5055,y=5055}
local redTurret2={x=7777,y=7777}
local redTurret1={x=8888,y=8888}
local redInhibitor={x=9588,y=9588}

local myTurret1, myTurret2, myInhibitor, enemyTurret1, enemyTurret2, enemyInhibitor, moveBackX, moveBackY

local priorityTable = {
 
    AP = {
        "Ahri", "Akali", "Anivia", "Annie", "Brand", "Cassiopeia", "Diana", "Evelynn", "FiddleSticks", "Fizz", "Gragas", "Heimerdinger", "Karthus",
        "Kassadin", "Katarina", "Kayle", "Kennen", "Leblanc", "Lissandra", "Lux", "Malzahar", "Mordekaiser", "Morgana", "Nidalee", "Orianna",
        "Rumble", "Ryze", "Sion", "Swain", "Syndra", "Teemo", "TwistedFate", "Veigar", "Viktor", "Vladimir", "Xerath", "Ziggs", "Zyra", "MasterYi",
    },
    Support = {
        "Blitzcrank", "Janna", "Karma", "Leona", "Lulu", "Nami", "Sona", "Soraka", "Taric", "Thresh", "Zilean",
    },
 
    Tank = {
        "Amumu", "Chogath", "DrMundo", "Galio", "Hecarim", "Malphite", "Maokai", "Nasus", "Rammus", "Sejuani", "Shen", "Singed", "Skarner", "Volibear",
        "Warwick", "Yorick", "Zac", "Nunu", "Alistar"
    },
 
    AD_Carry = {
        "Ashe", "Caitlyn", "Corki", "Draven", "Ezreal", "Graves", "Jayce", "KogMaw", "MissFortune", "Pantheon", "Quinn", "Shaco", "Sivir",
        "Talon", "Tristana", "Twitch", "Urgot", "Varus", "Vayne", "Zed", "Lucian"
 
    },
 
    Bruiser = {
        "Darius", "Elise", "Fiora", "Gangplank", "Garen", "Irelia", "JarvanIV", "Jax", "Khazix", "LeeSin", "Nautilus", "Nocturne", "Olaf", "Poppy",
        "Renekton", "Rengar", "Riven", "Shyvana", "Trundle", "Tryndamere", "Udyr", "Vi", "MonkeyKing", "XinZhao", "Aatrox"
    },
 
}

local function ReturnNearestEnemyTower(Towers)
	local closestObject, minDist = nil, math.huge
	for i, tower in pairs(Towers) do
		if tower and tower.team ~= myHero.team then
			local currDist = GetDistance(myHero, tower.object)
			if currDist < minDist then
				closestObject = tower.object
				minDist = currDist
			end
		end
	end
	return closestObject
end

function isUnderTurret()
	local closesttowers = ReturnNearestEnemyTower(Towers)
	if ts.target ~= nil then
		if GetDistance(ts.target, closesttowers) < 650 then
			return true
		else
			return false
		end
	else
		return false
	end
end

local function CountAllyHeroInRange(range)
	local allyInRange = 0
	for i = 1, heroManager.iCount, 1 do
		local heros = heroManager:getHero(i)
		if heros.dead == false and GetDistance(heros) < range then
			allyInRange = allyInRange + 1
		end
	end
	return allyInRange
end

local function GetAlly()
	Allies = {}
	for d=1, heroManager.iCount, 1 do
		TargetAlly = heroManager:getHero(d)
		if TargetAlly.afk == nil or TargetAlly.afk == false then
			if TargetAlly.team == player.team and TargetAlly.name ~= player.name and GetDistance(OurSpawn, TargetAlly) > 2000 then
				table.insert(Allies, TargetAlly)
			end
		end
	end
end

function SetPriority(table, hero, priority)
    for i=1, #table, 1 do
        if hero.charName:find(table[i]) ~= nil then
            TS_SetHeroPriority(priority, hero.charName)
        end
    end
end
 
function arrangePrioritys()
    for i, enemy in ipairs(GetEnemyHeroes()) do
        SetPriority(priorityTable.AD_Carry, enemy, 1)
        SetPriority(priorityTable.AP,       enemy, 2)
        SetPriority(priorityTable.Support,  enemy, 3)
        SetPriority(priorityTable.Bruiser,  enemy, 4)
        SetPriority(priorityTable.Tank,     enemy, 5)
    end
end

function nextAction()
	--------------------------full
	if CountEnemyHeroInRange(400) == 0 and  CountAllyHeroInRange(1000) == 1 and state() == "full" then 
		return "follow" 
	elseif CountEnemyHeroInRange(1000) == CountAllyHeroInRange(1000) and state() == "full" then 
		return "attackPlayer" 
	elseif CountEnemyHeroInRange(1000) < CountAllyHeroInRange(1000) and state() == "full" then 
		return "attackPlayer" 
	elseif CountEnemyHeroInRange(1000)-1 == CountAllyHeroInRange(1000) and state() == "full" then 
		return "follow" 
	elseif CountEnemyHeroInRange(1000)-2 == CountAllyHeroInRange(1000) and state() == "full" then 
		return "back"
		----------high
	elseif CountEnemyHeroInRange(1000) == CountAllyHeroInRange(1000) and state() == "high" then 
		return "attackPlayer" 
	elseif CountEnemyHeroInRange(1000) < CountAllyHeroInRange(1000) and state() == "high" then 
		return "attackPlayer" 
	elseif CountEnemyHeroInRange(1000)-1 == CountAllyHeroInRange(1000) and state() == "high" then 
		return "follow" 
	elseif CountEnemyHeroInRange(1000)-2 == CountAllyHeroInRange(1000) and state() == "high" then 
		return "back"
		----------med
	elseif CountEnemyHeroInRange(1000) == CountAllyHeroInRange(1000) and state() == "med" then 
		return "attackPlayer" 
	elseif CountEnemyHeroInRange(1000) < CountAllyHeroInRange(1000) and state() == "med" then 
		return "attackPlayer" 
	elseif CountEnemyHeroInRange(1000)-1 == CountAllyHeroInRange(1000) and state() == "med" then 
		return "follow" 
	elseif CountEnemyHeroInRange(1000)-2 == CountAllyHeroInRange(1000) and state() == "med" then 
		return "back"
	----------------low
	elseif CountEnemyHeroInRange(1000) == CountAllyHeroInRange(1000) and state() == "low" then 
		return "follow" 
	elseif CountEnemyHeroInRange(1000) < CountAllyHeroInRange(1000) and state() == "low" then 
		return "attackPlayer" 
	elseif CountEnemyHeroInRange(1000)-1 == CountAllyHeroInRange(1000) and state() == "low" then 
		return "back" 
	elseif CountEnemyHeroInRange(1000)-2 == CountAllyHeroInRange(1000) and state() == "low" then 
		return "back"
	-- def turret
	elseif CountAllyHeroInRange == 1 then
		currentTime= os.clock()
		if currentTime - startingTime < 6000 then
			return "moveToTurret2"
		else
			return "moveToTurret1"
		end
	end
	
end

function back()
local x=player.x+moveBackX
local y=player.y+moveBackY
	player:MoveTo(x,y)
end

function state()
	if player.health > (player.maxHealth*0.90) then
		return "full"
	elseif player.health > (player.maxHealth*0.70) then
		return "high"
	elseif player.health > (player.maxHealth*0.45) then
		return "med"
	else
		return "low"
	end
end

function follow()
		if os.clock() > nextdelay then
			for i, folows in pairs(Allies) do
				if currentfolows == nil then
					currentfolows = folows
				else
					if GetDistance(currentfolows) > GetDistance(folows)  and folows.health > (folows.maxHealth*0.5) then
						currentfolows = folows
					end
				end
				if GetDistance(currentfolows) < 400 then
					player:HoldPosition()
				else
					player:MoveTo(currentfolows.x, currentfolows.z)
				end
			end
			nextdelay = os.clock() + 1
		end
end

attackInRange()
	if ts.target ~= nil then
		myHero.range >= myHero.getDistance(ts.target)
		myHero:Attack(ts.target)
	end
end


function attack()
	autoBurstDown()
	if ts.target ~= nil then
		myHero:Attack(ts.target)
	end
end

local autoBurstDown()
	local combo
	local qDmg = getDmg("Q",ts.target,myHero)
	local wDmg = getDmg("W",ts.target,myHero)
	local eDmg = getDmg("E",ts.target,myHero)
	local rDmg = getDmg("R",ts.target,myHero)
	local aaDmg = getDmg("AD",ts.target,myHero)
	combo = qDmg + wDmg + eDmg + rDmg + aaDmg
	if combo >= ts.target.health and myHero.range >= myHero.getDistance(ts.target) then
		useSpell(ts, _Q)
		useSpell(ts, _E)
		useSpell(ts, _W)
		useSpell(ts, _R)
		attackInRange()
	end
end

function teamLogic()
		if player == TEAM_RED then
			myTurret1= redTurret1
			myTurret2=redTurret2
			myInhibitor=redInhibitor
			enemyTurret1= blueTurret1
			enemyTurret2= blueTurret2
			enemyInhibitor=blueInhibitor
			--PrintChat("Red team logic")
			moveBackX=500
			moveBackY=500
		else
			myTurret1= blueTurret1
			myTurret2=blueTurret2
			myInhibitor=blueInhibitor
			enemyTurret1= redTurret1
			enemyTurret2= redTurret2
			enemyInhibitor=redInhibitor
			--PrintChat("Blue team logic")
			moveBackX=-500
			moveBackY=-500
		end
end

lvlspells()
    if player:GetSpellData(_Q).level + player:GetSpellData(_W).level + player:GetSpellData(_E).level + player:GetSpellData(_R).level < player.level then
        local spellSlot = { SPELL_1, SPELL_2, SPELL_3, SPELL_4, }
        local level = { 0, 0, 0, 0 }
        for i = 1, player.level, 1 do
            level[abilitySequence[i]] = level[abilitySequence[i]] + 1
        end
        for i, v in ipairs({ player:GetSpellData(_Q).level, player:GetSpellData(_W).level, player:GetSpellData(_E).level, player:GetSpellData(_R).level }) do
            if v < level[i] then LevelSpell(spellSlot[i]) end
        end
    end
end

--[[ 		Globals		]]
local abilitySequence
local player = GetMyHero()
--[[ 		Functions	]]
function OnTick()
	--auto level spells.
	lvlspells()
	-- action
	attackInRange()
	if nextAction() == "moveToTurret2" then
		player:MoveTo(myTurret2.x,myTurret2.y)
		PrintChat("moving to the first turret")
	elseif nextAction() == "moveToTurret1" then
		player:MoveTo(myTurret1.x,myTurret1.y)
		PrintChat("moving to the second turret")
	elseif nextAction() == "follow" then
		--PrintChat("follow")
		follow()
	elseif nextAction() == "attackPlayer" then
		attack()
	elseif nextAction() == "back" then
		back()
	end
end

function OnLoad()
	startTime = os.clock()
	Allies = GetAllyHeroes()
	teamLogic()
    if heroManager.iCount < 10 then
        PrintChat("Playing a custom game, can't arrange priority's!")
    else
        TargetSelector(TARGET_LESS_CAST_PRIORITY, 0) -- Create a dummy target selector
        arrangePrioritys()
        PrintChat(" >> Arranged priority's!")
    end
    local champ = player.charName
    --[[
     In this section you can adjust the ability sequence of champions.

     To turn off the script for a particular champion,
     you have to comment out this line with two dashes.
     ]]
    if champ == "Aatrox" then abilitySequence = { 1, 2, 3, 2, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 2, 2, }
    elseif champ == "Ahri" then abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 2, 2, }
    elseif champ == "Akali" then abilitySequence = { 1, 2, 1, 3, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
    elseif champ == "Alistar" then abilitySequence = { 1, 3, 2, 1, 3, 4, 1, 3, 1, 3, 4, 1, 3, 2, 2, 4, 2, 2, }
    elseif champ == "Amumu" then abilitySequence = { 2, 3, 3, 1, 3, 4, 3, 1, 3, 1, 4, 1, 1, 2, 2, 4, 2, 2, }
    elseif champ == "Anivia" then abilitySequence = { 1, 3, 1, 3, 3, 4, 3, 2, 3, 2, 4, 1, 1, 1, 2, 4, 2, 2, }
    elseif champ == "Annie" then abilitySequence = { 2, 1, 1, 3, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
    elseif champ == "Ashe" then abilitySequence = { 2, 3, 2, 1, 2, 4, 2, 1, 2, 1, 4, 1, 1, 3, 3, 4, 3, 3, }
    elseif champ == "Blitzcrank" then abilitySequence = { 1, 3, 2, 3, 2, 4, 3, 2, 3, 2, 4, 3, 2, 1, 1, 4, 1, 1, }
    elseif champ == "Brand" then abilitySequence = { 2, 3, 2, 1, 2, 4, 2, 3, 2, 3, 4, 3, 3, 1, 1, 4, 1, 1, }
    elseif champ == "Caitlyn" then abilitySequence = { 2, 1, 1, 3, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
    elseif champ == "Cassiopeia" then abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
    elseif champ == "Chogath" then abilitySequence = { 1, 3, 2, 2, 2, 4, 2, 3, 2, 3, 4, 3, 3, 1, 1, 4, 1, 1, }
    elseif champ == "Corki" then abilitySequence = { 1, 2, 1, 3, 1, 4, 1, 3, 1, 3, 4, 3, 2, 3, 2, 4, 2, 2, }
    elseif champ == "Diana" then abilitySequence = { 2, 1, 2, 3, 1, 4, 1, 1, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
    elseif champ == "DrMundo" then abilitySequence = { 2, 1, 3, 2, 2, 4, 2, 3, 2, 3, 4, 3, 3, 1, 1, 4, 1, 1, }
    elseif champ == "Evelynn" then abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
    elseif champ == "Ezreal" then abilitySequence = { 1, 3, 2, 2, 2, 4, 2, 1, 2, 1, 4, 1, 1, 3, 3, 4, 3, 3, }
    elseif champ == "FiddleSticks" then abilitySequence = { 3, 2, 2, 1, 2, 4, 2, 1, 2, 1, 4, 1, 1, 3, 3, 4, 3, 3, }
    elseif champ == "Fizz" then abilitySequence = { 3, 1, 2, 1, 2, 4, 1, 1, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
    elseif champ == "Galio" then abilitySequence = { 1, 2, 1, 3, 1, 4, 1, 2, 1, 2, 4, 3, 3, 2, 2, 4, 3, 3, }
    elseif champ == "Gangplank" then abilitySequence = { 1, 2, 1, 3, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
    elseif champ == "Garen" then abilitySequence = { 1, 2, 3, 3, 3, 4, 3, 1, 3, 1, 4, 1, 1, 2, 2, 4, 2, 2, }
    elseif champ == "Gragas" then abilitySequence = { 1, 3, 2, 1, 1, 4, 1, 2, 1, 2, 4, 2, 3, 2, 3, 4, 3, 3, }
    elseif champ == "Graves" then abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 2, 1, 3, 4, 3, 3, 3, 2, 4, 2, 2, }
    elseif champ == "Hecarim" then abilitySequence = { 1, 2, 1, 3, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
    elseif champ == "Heimerdinger" then abilitySequence = { 1, 2, 2, 1, 1, 4, 3, 2, 2, 2, 4, 1, 1, 3, 3, 4, 1, 1, }
    elseif champ == "Irelia" then abilitySequence = { 3, 1, 2, 2, 2, 4, 2, 3, 2, 3, 4, 1, 1, 3, 1, 4, 3, 1, }
    elseif champ == "Janna" then abilitySequence = { 3, 1, 3, 2, 3, 4, 3, 2, 3, 2, 1, 2, 2, 1, 1, 1, 4, 4, }
    elseif champ == "JarvanIV" then abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 3, 2, 1, 4, 3, 3, 3, 2, 4, 2, 2, }
    elseif champ == "Jax" then abilitySequence = { 3, 2, 1, 2, 2, 4, 2, 3, 2, 3, 4, 1, 3, 1, 1, 4, 3, 1, }
    elseif champ == "Jayce" then abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
    elseif champ == "Karma" then abilitySequence = { 1, 3, 1, 2, 3, 1, 3, 1, 3, 1, 3, 1, 3, 2, 2, 2, 2, 2, }
    elseif champ == "Karthus" then abilitySequence = { 1, 3, 2, 1, 1, 4, 1, 1, 3, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
    elseif champ == "Kassadin" then abilitySequence = { 1, 2, 1, 3, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
    elseif champ == "Katarina" then abilitySequence = { 1, 3, 2, 2, 2, 4, 2, 3, 2, 1, 4, 1, 1, 1, 3, 4, 3, 3, }
    elseif champ == "Kayle" then abilitySequence = { 3, 2, 3, 1, 3, 4, 3, 2, 3, 2, 4, 2, 2, 1, 1, 4, 1, 1, }
    elseif champ == "Kennen" then abilitySequence = { 1, 3, 2, 2, 2, 4, 2, 1, 2, 1, 4, 1, 1, 3, 3, 4, 3, 3, }
    elseif champ == "KogMaw" then abilitySequence = { 2, 3, 2, 1, 2, 4, 2, 1, 2, 1, 4, 1, 1, 3, 3, 4, 3, 3, }
    elseif champ == "Leblanc" then abilitySequence = { 1, 2, 3, 1, 1, 4, 1, 2, 1, 2, 4, 2, 3, 2, 3, 4, 3, 3, }
    elseif champ == "Lucian" then abilitySequence = { 1, 2, 3, 1, 1, 4, 1, 2, 1, 2, 4, 2, 3, 2, 3, 4, 3, 3, }
    elseif champ == "LeeSin" then abilitySequence = { 3, 1, 2, 1, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
    elseif champ == "Leona" then abilitySequence = { 1, 3, 2, 2, 2, 4, 2, 3, 2, 3, 4, 3, 3, 1, 1, 4, 1, 1, }
    elseif champ == "Lulu" then abilitySequence = { 3, 2, 1, 3, 3, 4, 3, 2, 3, 2, 4, 2, 2, 1, 1, 4, 1, 1, }
    elseif champ == "Lux" then abilitySequence = { 3, 1, 3, 2, 3, 4, 3, 1, 3, 1, 4, 1, 1, 2, 2, 4, 2, 2, }
    elseif champ == "Malphite" then abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 3, 1, 3, 4, 3, 2, 3, 2, 4, 2, 2, }
    elseif champ == "Malzahar" then abilitySequence = { 1, 3, 3, 2, 3, 4, 1, 3, 1, 3, 4, 2, 1, 2, 1, 4, 2, 2, }
    elseif champ == "Maokai" then abilitySequence = { 3, 1, 2, 3, 3, 4, 3, 2, 3, 2, 4, 2, 2, 1, 1, 4, 1, 1, }
    elseif champ == "MasterYi" then abilitySequence = { 1, 2, 3, 1, 1, 4, 3, 1, 3, 1, 4, 3, 3, 2, 2, 4, 2, 2, }
    elseif champ == "MissFortune" then abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
    elseif champ == "MonkeyKing" then abilitySequence = { 3, 1, 2, 1, 1, 4, 3, 1, 3, 1, 4, 3, 3, 2, 2, 4, 2, 2, }
    elseif champ == "Mordekaiser" then abilitySequence = { 3, 1, 3, 2, 3, 4, 3, 1, 3, 1, 4, 1, 1, 2, 2, 4, 2, 2, }
    elseif champ == "Morgana" then abilitySequence = { 1, 2, 2, 3, 2, 4, 2, 1, 2, 1, 4, 1, 1, 3, 3, 4, 3, 3, }
    elseif champ == "Nasus" then abilitySequence = { 1, 2, 1, 3, 1, 4, 1, 2, 1, 2, 4, 2, 3, 2, 3, 4, 3, 3, }
    elseif champ == "Nautilus" then abilitySequence = { 2, 3, 2, 1, 2, 4, 2, 3, 2, 3, 4, 3, 3, 1, 1, 4, 1, 1, }
    elseif champ == "Nidalee" then abilitySequence = { 2, 3, 1, 3, 1, 4, 3, 2, 3, 1, 4, 3, 1, 1, 2, 4, 2, 2, }
    elseif champ == "Nocturne" then abilitySequence = { 1, 2, 1, 3, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
    elseif champ == "Nunu" then abilitySequence = { 3, 1, 3, 2, 1, 4, 3, 1, 3, 1, 4, 1, 3, 2, 2, 4, 2, 2, }
    elseif champ == "Olaf" then abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
    elseif champ == "Orianna" then abilitySequence = { 1, 3, 2, 1, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
    elseif champ == "Pantheon" then abilitySequence = { 1, 2, 3, 1, 1, 4, 1, 3, 1, 3, 4, 3, 2, 3, 2, 4, 2, 2, }
    elseif champ == "Poppy" then abilitySequence = { 3, 2, 1, 1, 1, 4, 1, 2, 1, 2, 2, 2, 3, 3, 3, 3, 4, 4, }
    elseif champ == "Rammus" then abilitySequence = { 1, 2, 3, 3, 3, 4, 3, 2, 3, 2, 4, 2, 2, 1, 1, 4, 1, 1, }
    elseif champ == "Renekton" then abilitySequence = { 2, 1, 3, 1, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
    elseif champ == "Rengar" then abilitySequence = { 1, 3, 2, 1, 1, 4, 2, 1, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
    elseif champ == "Riven" then abilitySequence = { 1, 2, 3, 2, 2, 4, 2, 3, 2, 3, 4, 3, 3, 1, 1, 4, 1, 1, }
    elseif champ == "Rumble" then abilitySequence = { 3, 1, 1, 2, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
    elseif champ == "Ryze" then abilitySequence = { 1, 2, 1, 3, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
    elseif champ == "Sejuani" then abilitySequence = { 2, 1, 3, 3, 2, 4, 3, 2, 3, 3, 4, 2, 1, 2, 1, 4, 1, 1, }
    elseif champ == "Shaco" then abilitySequence = { 2, 3, 1, 3, 3, 4, 3, 2, 3, 2, 4, 2, 2, 1, 1, 4, 1, 1, }
    elseif champ == "Shen" then abilitySequence = { 1, 2, 3, 1, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
    elseif champ == "Shyvana" then abilitySequence = { 2, 1, 2, 3, 2, 4, 2, 3, 2, 3, 4, 3, 1, 3, 1, 4, 1, 1, }
    elseif champ == "Singed" then abilitySequence = { 1, 3, 1, 3, 1, 4, 1, 2, 1, 2, 4, 3, 2, 3, 2, 4, 2, 3, }
    elseif champ == "Sion" then abilitySequence = { 1, 3, 3, 2, 3, 4, 3, 1, 3, 1, 4, 1, 1, 2, 2, 4, 2, 2, }
    elseif champ == "Sivir" then abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 2, 1, 2, 4, 2, 3, 2, 3, 4, 3, 3, }
    elseif champ == "Skarner" then abilitySequence = { 1, 2, 1, 2, 1, 4, 1, 2, 1, 2, 4, 2, 3, 3, 3, 4, 3, 3, }
    elseif champ == "Sona" then abilitySequence = { 1, 2, 3, 1, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
    elseif champ == "Soraka" then abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 2, 1, 3, 4, 2, 3, 2, 3, 4, 2, 3, }
    elseif champ == "Swain" then abilitySequence = { 2, 3, 3, 1, 3, 4, 3, 1, 3, 1, 4, 1, 1, 2, 2, 4, 2, 2, }
    elseif champ == "Talon" then abilitySequence = { 2, 3, 1, 2, 2, 4, 2, 1, 2, 1, 4, 1, 1, 3, 3, 4, 3, 3, }
    elseif champ == "Taric" then abilitySequence = { 3, 2, 1, 2, 2, 4, 1, 2, 2, 1, 4, 1, 1, 3, 3, 4, 3, 3, }
    elseif champ == "Teemo" then abilitySequence = { 1, 3, 2, 3, 1, 4, 3, 3, 3, 1, 4, 2, 2, 1, 2, 4, 2, 1, }
    elseif champ == "Tristana" then abilitySequence = { 3, 2, 2, 3, 2, 4, 2, 1, 2, 1, 4, 1, 1, 1, 3, 4, 3, 3, }
	elseif champ == "Thresh" then abilitySequence = { 3, 2, 2, 3, 2, 4, 2, 1, 2, 1, 4, 1, 1, 1, 3, 4, 3, 3, }
    elseif champ == "Trundle" then abilitySequence = { 1, 2, 1, 3, 1, 4, 1, 2, 1, 3, 4, 2, 3, 2, 3, 4, 2, 3, }
    elseif champ == "Tryndamere" then abilitySequence = { 3, 1, 2, 1, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
    elseif champ == "TwistedFate" then abilitySequence = { 2, 1, 1, 3, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
    elseif champ == "Twitch" then abilitySequence = { 1, 3, 3, 2, 3, 4, 3, 1, 3, 1, 4, 1, 1, 2, 2, 1, 2, 2, }
    elseif champ == "Udyr" then abilitySequence = { 4, 2, 3, 4, 4, 2, 4, 2, 4, 2, 2, 1, 3, 3, 3, 3, 1, 1, }
    elseif champ == "Urgot" then abilitySequence = { 3, 1, 1, 2, 1, 4, 1, 2, 1, 3, 4, 2, 3, 2, 3, 4, 2, 3, }
    elseif champ == "Varus" then abilitySequence = { 1, 2, 3, 1, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
    elseif champ == "Vayne" then abilitySequence = { 1, 3, 2, 1, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
    elseif champ == "Veigar" then abilitySequence = { 1, 3, 1, 2, 1, 4, 2, 2, 2, 2, 4, 3, 1, 1, 3, 4, 3, 3, }
    elseif champ == "Viktor" then abilitySequence = { 3, 2, 3, 1, 3, 4, 3, 1, 3, 1, 4, 1, 2, 1, 2, 4, 2, 2, }
    elseif champ == "Vladimir" then abilitySequence = { 1, 2, 1, 3, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
    elseif champ == "Volibear" then abilitySequence = { 2, 3, 2, 1, 2, 4, 3, 2, 1, 2, 4, 3, 1, 3, 1, 4, 3, 1, }
    elseif champ == "Warwick" then abilitySequence = { 2, 1, 1, 2, 1, 4, 1, 3, 1, 3, 4, 3, 3, 3, 2, 4, 2, 2, }
    elseif champ == "Xerath" then abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
    elseif champ == "XinZhao" then abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
    elseif champ == "Yorick" then abilitySequence = { 2, 3, 1, 3, 3, 4, 3, 2, 3, 1, 4, 2, 1, 2, 1, 4, 2, 1, }
    elseif champ == "Ziggs" then abilitySequence = { 1, 2, 3, 1, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
    elseif champ == "Zilean" then abilitySequence = { 1, 2, 1, 3, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
    elseif champ == "Zyra" then abilitySequence = { 3, 2, 1, 1, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
    else PrintChat(string.format(" >> AutoLevelSpell Script disabled for %s", champ))
    end
    if abilitySequence and #abilitySequence == 18 then
        PrintChat(" >> AutoLevelSpell Script loaded!")
    else
        PrintChat(" >> AutoLevelSpell Ability Sequence Error")
        OnTick = function() end
        return
    end
end