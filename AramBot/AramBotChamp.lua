if GetGame().map.name == "Howling Abyss" then
	if GetMyHero().charName == "MasterYi"
		--[[
				Master Yi Combo 1.6 by burn
				updated season 3
		 
				-Full combo: Items -> R -> Q -> E
				-Supports Deathfire Grasp, Bilgewater Cutlass, Hextech Gunblade, Sheen, Trinity, Lich Bane, Ignite, Iceborn, Liandrys, Blackfire, || Ravenous Hydra, EXEC, YOGH, RANO and BRK (this part only item activation)
				-Mark killable target with a combo
				-Target configuration, Press shift to configure
				-Mana managament system
				-Option to auto ignite when enemy is killable (this affect also for damage calculation)
							-Option to Auto R-Q on killable enemy
		 
				Explanation of the marks:
		 
				Green circle: Marks the current target to which you will do the combo
				Blue circle: Mark a target that can be killed with a combo, if all the skills were available
				Red circle: Mark a target that can be killed using Items + 10 hits + Q x2 + ignite
				2 Red circles: Mark a target that can be killed using Items + 5 hit + Q + ignite
				3 Red circles: Mark a target that can be killed using Items (without Sheen, Trinity and Lich Bane) + Q + ignite
		]]    
		--[[            Code            ]]
		local range = 600
		local tick = nil
			local WujuStyleActive = false
			local UltimateActive = false
		-- draw
		local waittxt = {}
		local calculationenemy = 1
		local floattext = {"Skills are not available","Able to fight","Killable","Murder him!"}
		local killable = {}
		-- ts
		local ts
		--
		local ignite = nil
		local WeHaveMana = false
		local DFGSlot, HXGSlot, BWCSlot, SheenSlot, TrinitySlot, LichBaneSlot, YomumusGhostbladeSlot = nil, nil, nil, nil, nil, nil, nil
		local QREADY, EREADY, RREADY, DFGREADY, HXGREADY, BWCREADY, IREADY, YomumusGhostbladeReady = false, false, false, false, false, false, false, false
		 
		function OnLoad()
				PrintChat(">> MasterYi Combo 1.6 loaded!")
				MYiConfig = scriptConfig("Master Yi Combo", "yicombo")
				MYiConfig:addParam("scriptActive", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
				MYiConfig:addParam("drawcircles", "Draw Range", SCRIPT_PARAM_ONOFF, true)
				MYiConfig:addParam("drawenemy", "Draw Enemy Circles", SCRIPT_PARAM_ONOFF, false)
				MYiConfig:addParam("drawtext", "Draw Text", SCRIPT_PARAM_ONOFF, true)
				MYiConfig:addParam("autoignite", "Auto Ignite", SCRIPT_PARAM_ONOFF, true)
				MYiConfig:permaShow("scriptActive")
				ts = TargetSelector(TARGET_LOW_HP,range+100,DAMAGE_MAGIC,false)
				ts.name = "MasterYi"
				MYiConfig:addTS(ts)
				if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then ignite = SUMMONER_1
				elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then ignite = SUMMONER_2 end
				for i=1, heroManager.iCount do waittxt[i] = i*3 end
		end
		 
		function OnTick()
				ts:update()
				DFGSlot, HXGSlot, BWCSlot, SheenSlot, TrinitySlot, LichBaneSlot, YomumusGhostbladeSlot = GetInventorySlotItem(3128), GetInventorySlotItem(3146), GetInventorySlotItem(3144), GetInventorySlotItem(3057), GetInventorySlotItem(3078), GetInventorySlotItem(3100), GetInventorySlotItem(3142)
							EXECSlot = GetInventorySlotItem(3123)
							RANOSlot = GetInventorySlotItem(3143)
							BRKSlot = GetInventorySlotItem(3153)
							RavenousHydraSlot = GetInventorySlotItem(3074)
							IcebornSlot, LiandrysSlot, BlackfireSlot = GetInventorySlotItem(3025), GetInventorySlotItem(3151), GetInventorySlotItem(3188)
							--
				QREADY = (myHero:CanUseSpell(_Q) == READY)
				EREADY = (myHero:CanUseSpell(_E) == READY)
				RREADY = (myHero:CanUseSpell(_R) == READY)
				DFGREADY = (DFGSlot ~= nil and myHero:CanUseSpell(DFGSlot) == READY)
				HXGREADY = (HXGSlot ~= nil and myHero:CanUseSpell(HXGSlot) == READY)
				BWCREADY = (BWCSlot ~= nil and myHero:CanUseSpell(BWCSlot) == READY)
							YomumusGhostbladeReady = (YomumusGhostbladeSlot ~= nil and myHero:CanUseSpell(YomumusGhostbladeSlot) == READY)
							EXECReady = (EXECSlot ~= nil and myHero:CanUseSpell(EXECSlot) == READY)
							RANOReady = (RANOSlot ~= nil and myHero:CanUseSpell(RANOSlot) == READY)
							BRKReady = (BRKSlot ~= nil and myHero:CanUseSpell(BRKSlot) == READY)
							RavHydraReady = (RavenousHydraSlot ~= nil and myHero:CanUseSpell(RavenousHydraSlot) == READY)                  
				IREADY = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
				if tick == nil or GetTickCount()-tick >= 100 then
						tick = GetTickCount()
						YiDmgCalculation()
				end
							if ts.target and QREADY then
											--mana check managament:
						local SpellDataQ2 = myHero:GetSpellData(_Q)
						local totalCost2 = 100 + (60+10*SpellDataQ2.level) --total cost of mana necessary to do a R+Q
						if myHero.mana >= totalCost2 then
								WeHaveMana2 = true
						else
								WeHaveMana2 = false
						end
											--end mana check
											local qdmg = getDmg("Q",ts.target,myHero)
						if WeHaveMana2 and QREADY and ts.target.health < qdmg then
								if RREADY and not UltimateActive and GetDistance(ts.target) <= (range-100) then CastSpell(_R) end
								if GetDistance(ts.target) <= (range-100) then CastSpell(_Q, ts.target) end
						end
											if not WeHaveMana2 and QREADY and ts.target.health < qdmg then
								if GetDistance(ts.target) <= (range-100) then CastSpell(_Q, ts.target) end
						end                        
							end
				if MYiConfig.scriptActive and ts.target then
				--mana check managament:
						local SpellDataQ = myHero:GetSpellData(_Q)
						local totalCost = 100 + (60+10*SpellDataQ.level) --total cost of mana necessary to do a R+Q
						if myHero.mana >= totalCost then
								WeHaveMana = true
						else
								WeHaveMana = false
						end
				--end mana check
						if DFGREADY then CastSpell(DFGSlot, ts.target) end
											if YomumusGhostbladeReady then CastSpell(YomumusGhostbladeSlot, ts.target) end
											if EXECReady then CastSpell(EXECSlot, ts.target) end
											if BRKReady then CastSpell(BRKSlot, ts.target) end
											if RavHydraReady then CastSpell(RavenousHydraSlot, ts.target) end
											if RANOReady then CastSpell(RANOSlot, ts.target) end                                   
						if HXGREADY then CastSpell(HXGSlot, ts.target) end
						if BWCREADY then CastSpell(BWCSlot, ts.target) end
						if WeHaveMana then
								if RREADY and QREADY and not UltimateActive then CastSpell(_R) end --QREADY for avoid use only ultimate if Q is on Cooldown
								if QREADY and GetDistance(ts.target) <= range then CastSpell(_Q, ts.target) end
						else
								if QREADY and GetDistance(ts.target) <= range then CastSpell(_Q, ts.target) end
						end
						if EREADY and not WujuStyleActive then CastSpell(_E) end
						myHero:Attack(ts.target)
				end
				if MYiConfig.autoignite then  
						if IREADY then
								local ignitedmg = 0    
								for j = 1, heroManager.iCount, 1 do
										local enemyhero = heroManager:getHero(j)
										if ValidTarget(enemyhero,600) then
												ignitedmg = 50 + 20 * myHero.level
												if enemyhero.health <= ignitedmg then
														CastSpell(ignite, enemyhero)
												end
										end
								end
						end
				end
		end
		function YiDmgCalculation()
				local enemy = heroManager:GetHero(calculationenemy)
				if ValidTarget(enemy) then
						local dfgdamage, hxgdamage, bwcdamage, ignitedamage, Sheendamage, Trinitydamage, LichBanedamage  = 0, 0, 0, 0, 0, 0, 0
						local qdamage = getDmg("Q",enemy,myHero)
						local hitdamage = getDmg("AD",enemy,myHero)
						local dfgdamage = (DFGSlot and getDmg("DFG",enemy,myHero) or 0)
						local hxgdamage = (HXGSlot and getDmg("HXG",enemy,myHero) or 0)
						local bwcdamage = (BWCSlot and getDmg("BWC",enemy,myHero) or 0)
						local ignitedamage = (ignite and getDmg("IGNITE",enemy,myHero) or 0)
											local onhitdmg = (SheenSlot and getDmg("SHEEN",enemy,myHero) or 0)+(TrinitySlot and getDmg("TRINITY",enemy,myHero) or 0)+(LichBaneSlot and getDmg("LICHBANE",enemy,myHero) or 0)+(IcebornSlot and getDmg("ICEBORN",enemy,myHero) or 0)
						local onspelldamage = (LiandrysSlot and getDmg("LIANDRYS",enemy,myHero) or 0)+(BlackfireSlot and getDmg("BLACKFIRE",enemy,myHero) or 0)
											local combo1 = qdamage*2 + onspelldamage
						local combo2 = onspelldamage
						local combo3 = onspelldamage
						local combo4 = onspelldamage
						if QREADY then
								combo2 = combo2 + qdamage*2
								combo3 = combo3 + qdamage
								combo4 = combo4 + qdamage
						end
						if HXGREADY then              
								combo1 = combo1 + hxgdamage    
								combo2 = combo2 + hxgdamage
								combo3 = combo3 + hxgdamage
								combo4 = combo4 + hxgdamage
						end
						if BWCREADY then
								combo1 = combo1 + bwcdamage
								combo2 = combo2 + bwcdamage
								combo3 = combo3 + bwcdamage
								combo4 = combo4 + bwcdamage
						end
						if DFGREADY then        
								combo1 = combo1*1.2 + dfgdamage            
								combo2 = combo2*1.2 + dfgdamage
								combo3 = combo3*1.2 + dfgdamage
								combo4 = combo4*1.2 + dfgdamage
						end                                
						if IREADY and MYiConfig.autoignite then
								combo1 = combo1 + ignitedamage
								combo2 = combo2 + ignitedamage
								combo3 = combo3 + ignitedamage
								combo4 = combo4 + ignitedamage
						end
						combo1 = combo1 + hitdamage*10 + onhitdmg    
						combo2 = combo2 + hitdamage*10 + onhitdmg
						combo3 = combo3 + hitdamage*5 + onhitdmg   
						if combo4 >= enemy.health then killable[calculationenemy] = 4
						elseif combo3 >= enemy.health then killable[calculationenemy] = 3
						elseif combo2 >= enemy.health then killable[calculationenemy] = 2
						elseif combo1 >= enemy.health then killable[calculationenemy] = 1
						else killable[calculationenemy] = 0 end
				end
				if calculationenemy == 1 then
						calculationenemy = heroManager.iCount
				else
						calculationenemy = calculationenemy-1
				end
		end
		function OnDraw()
				if MYiConfig.drawcircles and not myHero.dead then
						DrawCircle(myHero.x, myHero.y, myHero.z, range, 0x19A712)
						if ts.target ~= nil then
							DrawCircle(ts.target.x, ts.target.y, ts.target.z, 50, 0x00FF00)
						end
				end
				for i=1, heroManager.iCount do
						local enemydraw = heroManager:GetHero(i)
						if ValidTarget(enemydraw) then
								if MYiConfig.drawenemy then
										if killable[i] == 1 then
												DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 80, 0x0000FF)
										elseif killable[i] == 2 then
							  
												DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 80, 0xFF0000)
										elseif killable[i] == 3 then
												DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 80, 0xFF0000)
												DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 110, 0xFF0000)
										elseif killable[i] == 4 then
												DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 80, 0xFF0000)
												DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 110, 0xFF0000)
												DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 140, 0xFF0000)
										end
								end
								if MYiConfig.drawtext and waittxt[i] == 1 and killable[i] ~= 0 then
										PrintFloatText(enemydraw,0,floattext[killable[i]])
								end
						end
						if waittxt[i] == 1 then waittxt[i] = 30
						else waittxt[i] = waittxt[i]-1 end
				end
		end
		   
			function OnCreateObj(object)
					if object.name == "WujustyleSC_buf.troy" then WujuStyleActive = true end
					if object.name == "Highlander_buf.troy" then UltimateActive = true end
			end
	 
			function OnDeleteObj(object)
					if object.name == "WujustyleSC_buf.troy" then WujuStyleActive = false end
					if object.name == "Highlander_buf.troy" then UltimateActive = false end
			end

-----------------------------------------------------------------------------
	elseif GetMyHero().charName == "Nami"
	--[[
	Author: Puze
	Script: AesNami
	Version: 0.1
	--]]
	 
	--Prediction
	if VIP_USER then
			QPredic = TargetPredictionVIP(QRange, math.huge, 0.4)
			RPredic = TargetPredictionVIP(RRange, 1200, 0.5)
	else
			QPredic = TargetPrediction(850, 2.0, 500)
			RPredic = TargetPrediction(1000, 1.2, 500)
	end
	 
	--Constants
	local QRange = 850
	local WRange = 725
	local RRange = 1000
	 
	 
	function OnLoad()
			PrintChat(">> AesNami loaded!")
			Config = scriptConfig("AesNami", "config")
			Config:addParam("combo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
			Config:addParam("harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("A"))
			Config:addParam("ult", "Use ultimate", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("S"))
			Config:permaShow("combo")
			Config:permaShow("harass")
	 
			ts = TargetSelector(TARGET_PRIORITY, QRange, DAMAGE_PHYSICAL)
			ts.name = "Nami"
			Config:addTS(ts)
	end
	 
	function OnTick()
			ts:update()
	 
			if ts.target ~= nil then
					qPred = QPredic:GetPrediction(ts.target)
					rPred = RPredic:GetPrediction(ts.target)
			end
	 
					Combo()
	 
					Ultimate()
	end
	 
	function Combo()
			if ts.target ~= nil then
					if qPred ~= nil then
							if myHero:CanUseSpell(_Q) == READY and GetDistance(qPred) <= QRange then
									if VIP_USER and QPredic:GetHitChance(ts.target) > 0.6 then
											CastSpell(_Q, qPred.x, qPred.z)
									elseif not VIP_USER then
											CastSpell(_Q, qPred.x, qPred.z)
									end
							end
					end
	 
					if myHero:CanUseSpell(_W) == READY and GetDistance(ts.target) <= WRange then
							CastSpell(_W, ts.target)
					end
			end
	end
	 
	function Harass()
			if ts.target ~= nil then
					if myHero:CanUseSpell(_W) == READY and GetDistance(ts.target) <= WRange then
							CastSpell(_W, ts.target)
					end
			end
	end
	 
	function Ultimate()
			if ts.target ~= nil then
					if rPred ~= nil then
							if myHero:CanUseSpell(_R) == READY and GetDistance(rPred) <= RRange then
									if VIP_USER and RPredic:GetHitChance(ts.target) > 0.6 then
											CastSpell(_R, rPred.x, rPred.z)
									elseif not VIP_USER then
											CastSpell(_R, rPred.x, rPred.z)
									end
							end
					end
			end
	end
------------------------------------------------------------------------------------------------------
	elseif GetMyHero().charName == "Sona" then
		--[[
			Based on Soraka Slack
			By Ivan[russia]
			Credits To Zynox/grey autolvl spell/ikita autosilence/nanja taric/wee Ward Scanner
			I Learned From Their Previous Scripts
			v7: script heal ignited too, but now it preffer unignated targets
			
			ikita's Sona Slack v1
		--]]

		------------------------------- SETTINGS -------------------------------
		-- you can change true to false and false to true
		-- false means turn off
		-- true means turn on

		require "AllClass"

		SetupAutoUlt= true -- Auto Ult
		SetupUltEffect=2 -- (between 1-5)  

		SetupAutoHeal= true -- Auto Heal
		SetupHealGiveRate= 3 -- At which rate you should heal.      	Example: your usual heal gives 100 hp , SetupHealGiveRate=3 means 100x3, so script heals when target miss 300 hp

		SetupDistance= 900 -- How much distance to use spells

		SetupTogleKey= 117	--Key to Togle script. [ F6 - 117 ] default
							--key codes
							--http://www.indigorose.com/webhelp/ams/Program_Reference/Misc/Virtual_Key_Codes.htm 

		SetupAutoLvLSpell= true -- AutoLvL Spells of soraka
		abilitySequence = {2,1,2,3,1,4,2,2,2,1,4,1,1,3,3,4,3,3} -- list for SetupAutoLvLSpell

		SetupDrawInfo = true -- Drawing usefull info on screen
		SetupDrawX = 0.8 
		SetupDrawY = 0.2 -- Position of info, minimum = 0, maximum = 1, SetupDrawX - width, SetupDrawY - height

		SetupValorLimit = 250
		SetupAutoValor = true

		SetupAutoCelerity = true
		SetupCelerityLimit = 0.5

		------------------------------- GLOBALS [Do Not Change] -------------------------------
		SetupDebug= false --Debug Mode
		abilityLevel = 0
		Sona_SWITCH = true
		player = GetMyHero()

		--info table
		info = {}

		-- ultimate info
		info[1] = {} 
		info[1][1] = false -- state
		info[1][2] = 0 -- number
		info[1][3] = "" -- text
		info[1][4] = 0 -- RED
		info[1][5] = 255 -- GREEN
		info[1][6] = 0 -- BLUE

		-- gold info
		info[2] = {} 
		info[2][1] = false -- state
		info[2][2] = 0 -- number
		info[2][3] = "gold/10sec: " -- text
		info[2][4] = 255 -- RED
		info[2][5] = 255 -- GREEN
		info[2][6] = 51 -- BLUE


		-- gold/10 info
		gold10SecAgo = 0
		GoldRefreshTick = 0

		-- spawn
		allySpawn = nil
		enemySpawn = nil

		recallStartTime = 0
		recallDetected = false

		-- disable name list from Barasia283
		disableArray = {
						"CaitlynAceintheHole", "Crowstorm", "Drain", "ReapTheWhirlwind", "FallenOne", "KatarinaR", "AlZaharNetherGrasp", 
						"GalioIdolOfDurand", "Meditate", "MissFortuneBulletTime", "AbsoluteZero", "Pantheon_Heartseeker", "Pantheon_GrandSkyfall_Jump", 
						"ShenStandUnited", "gate", "UrgotSwap2", "InfiniteDuress", "VarusQ"
						}

		recentrecallTarget = player

		------------------------------- MATH SPELLS -------------------------------

		-- HEAL
		function calcHeal(ignited)
			local rank = player:GetSpellData(1).level
			if rank == 0 then return nil end
			if ignited == false then
				if     rank == 1 then return math.floor(40  + player.ap * 0.25 + 0.5) 
				elseif rank == 2 then return math.floor(60 + player.ap * 0.25 + 0.5) 
				elseif rank == 3 then return math.floor(80 + player.ap * 0.25 + 0.5) 
				elseif rank == 4 then return math.floor(100 + player.ap * 0.25 + 0.5) 
				elseif rank == 5 then return math.floor(120 + player.ap * 0.25 + 0.5) end
			else
				if     rank == 1 then return math.floor((40   + player.ap * 0.25)/2 + 0.5) 
				elseif rank == 2 then return math.floor((60  + player.ap * 0.25)/2 + 0.5) 
				elseif rank == 3 then return math.floor((80  + player.ap * 0.25)/2 + 0.5) 
				elseif rank == 4 then return math.floor((100  + player.ap * 0.25)/2 + 0.5) 
				elseif rank == 5 then return math.floor((120  + player.ap * 0.25)/2 + 0.5) end
			end
		end

		------------------------------- ABSTRACTION-METHODS -------------------------------
		-- return players table
		function GetPlayers(team, includeDead, includeSelf)
			local players = {}
			for i=1, heroManager.iCount, 1 do
				local member = heroManager:getHero(i)
				if member ~= nil and member.type == "obj_AI_Hero" and member.team == team then
					if member.charName ~= player.charName or includeSelf then 
						if includeDead then
							table.insert(players,member)
						elseif member.dead == false then
							table.insert(players,member)
						end
					end
				end
			end
			return players
		end

		-- return towers table
		function GetTowers(team)
			local towers = {}
			for i=1, objManager.maxObjects, 1 do
				local tower = objManager:getObject(i)
				if tower ~= nil and tower.type == "obj_AI_Turret" and tower.visible and tower.team == team then
					table.insert(towers,tower)
				end
			end
			if #towers > 0 then
				return towers
			else
				return false
			end
		end

		-- here get close tower
		function GetCloseTower(hero, team)
			local towers = GetTowers(team)
			if #towers > 0 then
				local candidate = towers[1]
				for i=2, #towers, 1 do
					if (towers[i].health/towers[i].maxHealth > 0.1) and  hero:GetDistance(candidate) > hero:GetDistance(towers[i]) then candidate = towers[i] end
				end
				return candidate
			else
				return false
			end
		end

		-- here get close player
		function GetClosePlayer(hero, team)
			local players = GetPlayers(team,false)
			if #players > 0 then
				local candidate = players[1]
				for i=2, #players, 1 do
					if hero:GetDistance(candidate) > hero:GetDistance(players[i]) then candidate = players[i] end
				end
				return candidate
			else
				return false
			end
		end

		-- return count of champs near hero
		function cntOfChampsNear(hero,team,distance)
			local cnt = 0 -- default count of champs near HERO
			local players = GetPlayers(team,false)
			for i=1, #players, 1 do
				if hero:GetDistance(players[i]) < distance then cnt = cnt + 1 end
			end
			return cnt
		end

		-- return %hp of champs near hero
		function hpOfChampsNear(hero,team,distance)
			local percent = 0 -- default %hp of champs near HERO
			local players = GetPlayers(team,false)
			for i=1, #players, 1 do
				if hero:GetDistance(players[i]) < distance then percent = percent + players[i].health/players[i].maxHealth end
			end
			return percent
		end

		-- is recall, return true/false
		function isRecall(hero)
			if GetTickCount() - recallStartTime > 8000 then
				return false
			else
				if recentrecallTarget.name == hero.name then
					return true
				end
				return false
			end
		end

		function OnCreateObj(object)
			if object.name == "TeleportHomeImproved.troy" or object.name == "TeleportHome.troy" then
				for i = 1, heroManager.iCount do
					local target = heroManager:GetHero(i)
					if GetDistance(target, object) < 100 then
						recentrecallTarget = target
					end
				end
				recallStartTime = GetTickCount()
			end
		end


		-- CHECK IS HERO IGNITED
		 function isIgnited(hero)
			if detectBuffs(hero,{"SummonerDot","grievouswound"}) then return 1 else return 0 end
		 end

		 -- DETECT BUFFS IN TABLE buffs ON HERO
		 function detectBuffs(hero,buffs)
			for j = 1, hero.buffCount, 1 do
				buff = hero:getBuff(j)
				for i = 1, #buffs, 1 do
					if buff == buffs[i] then return true end
				end
			end
			return false
		 end
		 
		-- CHECK IS HERO IN SPAWN
		function isInSpawn(hero)
			if  math.sqrt((allySpawn.x - hero.x) ^ 2 + (allySpawn.z - hero.z) ^ 2) < 1000 then return true end
			return false
		end

		------------------------------- CORE -------------------------------
		function AutoUlt()
			if player:GetSpellData(3).level > 0 and player:CanUseSpell(_R) == READY then
				if CountEnemyHeroInRange(900) > SetupUltEffect - 1 then
					for i = 1, heroManager.iCount, 1 do
					local hero = heroManager:getHero(i)
						if hero.team ~= player.team and GetDistance(hero) < 900 then
							CastSpell(_R, hero.x, hero.z)
						end
					end
				end
			end
		end

		function AutoValor()
			if player:GetSpellData(0).level > 0 and player:CanUseSpell(_Q) == READY then
				for i = 1, heroManager.iCount do
					local target = heroManager:GetHero(i)
					if target ~= nil and target.team ~= player.team and target.dead == false and target.visible and GetDistance(target, player) < 700 and player.mana > SetupValorLimit then
						CastSpell(_Q)
					end
				end
			end
		end

		function AutoCelerity()
			if player.mana/player.maxMana > SetupCelerityLimit then
				for i = 1, player.buffCount, 1 do
					if player:getBuff(i) == "sonaariaofperseveranceaura" then
						CastSpell(_E)
					end
				end
				for i = 1, heroManager.iCount do
					local target = heroManager:GetHero(i)
					if target ~= nil and target.team ~= player.team and target.dead == false and GetDistance(target, player) < 500 then
						for i = 1, player.buffCount, 1 do
							if player:getBuff(i) == "sonapowerchord" then
								player:Attack(target)
							end
						end
					end
				end
			end
		end

		function AutoHeal()
			if SetupDebug == true then PrintChat("debug >> AutoHeal()") end
			--check is heal lvled and ready
			if player:GetSpellData(1).level > 0 and player:CanUseSpell(_W) == READY then
				local healTarget = nil
				local players = GetPlayers(player.team, false, true)
				-- check is need heal and select target
				for i=1, #players, 1 do
					if player:GetDistance(players[i]) < SetupDistance and isRecall(players[i]) == false and isInSpawn(players[i]) == false then
						-- calculate is need heal to target
						if healTarget ~= nil and ((players[i].maxHealth - players[i].health) / (isIgnited(players[i]) + 1)) > ((healTarget.maxHealth - healTarget.health) / (isIgnited(healTarget) + 1)) then healTarget = players[i]
						elseif  healTarget == nil and (players[i].maxHealth - players[i].health) > (calcHeal(isIgnited(players[i])) * SetupHealGiveRate) then healTarget = players[i] end
					end
				end
				--heal targets
				if  healTarget ~= nil then CastSpell(_W) end
			end
		end


		--get info to draw
		--called every TimerCallback
		function GetInfo()
			--ultimate info
			if player:GetSpellData(3).level > 0 --[[and player:GetSpellState(_R) == STATE_READY]] then
				info[1][2] = ""
				info[1][1] = true
			else info[1][1] = false end
			--gold / 10 info
			if GetTickCount() - GoldRefreshTick > 9999 then
				if (player.gold - gold10SecAgo) > 0 and (player.gold - gold10SecAgo) < 84 then
					info[2][1] = true
					
					info[2][2] = string.format("%.02f", (player.gold - gold10SecAgo))
				end
				gold10SecAgo = player.gold
				GoldRefreshTick = GetTickCount()
			end
			
		end

		--draw info
		--called every frame
		function OnDraw()
			if SetupDrawInfo then
				local curString = 0
				for i=1, #info, 1 do
					if info[i][1] then
							--    text 
						DrawText(info[i][3]..tostring(info[i][2]),
							-- size   			x      					   				y                                   
								20 , (WINDOW_W - WINDOW_X) * SetupDrawX,  (WINDOW_H - WINDOW_Y) * SetupDrawY + curString, 0xFF00FF00)
						curString = curString + 20
					end
				end
			end
		end

		--turn off - on
		function OnWndMsg(msg, keycode)
			if keycode == SetupTogleKey and msg == KEY_DOWN then
				if SetupDebug == true then PrintChat("debug >> Toggle(msg, keycode == SetupTogleKey )") end
				if Sona_SWITCH == true then
					Sona_SWITCH = false
					PrintChat("<font color='#FF0000'> SONA SLACK >> Run Sona, RUN </font>")
				else
					Sona_SWITCH = true
					PrintChat("<font color='#00FF00'> SONA SLACK >> Heal Sona, HEAL </font>")
				end
			end
		end

		-- TIMER and BRAIN
		function OnTick() --Need 200ms interval
			if SetupDebug then PrintChat("debug >> Timer(tick)") end
			if player.dead == false and isRecall(player) == false then
				if Sona_SWITCH then
					if SetupAutoUlt then AutoUlt() end
					if SetupAutoValor then AutoValor() end
					if SetupAutoHeal then AutoHeal() end
					if SetupAutoCelerity then AutoCelerity() end
				end
			end
			if SetupAutoLvLSpell and player.level > abilityLevel then
				abilityLevel=abilityLevel+1
				if abilitySequence[abilityLevel] == 1 then LevelSpell(_Q)
				elseif abilitySequence[abilityLevel] == 2 then LevelSpell(_W)
				elseif abilitySequence[abilityLevel] == 3 then LevelSpell(_E)
				elseif abilitySequence[abilityLevel] == 4 then LevelSpell(_R) end
			end
			if SetupDrawInfo then GetInfo() end
		end
		-- LOAD --
		function OnLoad()
			player = GetMyHero()
			PrintChat("SONA SLACK >> SONA SLACKER v1 loaded!")	
			-- numerate spawn
			for i=1, objManager.maxObjects, 1 do
				local candidate = objManager:getObject(i)
				if candidate ~= nil and candidate.type == "obj_SpawnPoint" then 
					if candidate.x < 3000 then 
						if player.team == TEAM_BLUE then allySpawn = candidate else enemySpawn = candidate end
					else 
						if player.team == TEAM_BLUE then enemySpawn = candidate else allySpawn = candidate end
					end
				end
			end
		end
	end
    ------------------------------------------------------------------------------------------------------------------------------------------------------------
	elseif GetMyHero().charName == "Soraka" then
		--[[
			SORAKA SLACKER v8
			By Ivan[russia]
			Credits To Zynox/grey autolvl spell/ikita autosilence/nanja taric/wee Ward Scanner
			I Learned From Their Previous Scripts
			v7: script heal ignited too, but now it preffer unignated targets
			
			Updated for BoL by ikita v8.3
			Credits to Barasia283 for everything on auto silence
		--]]

		------------------------------- SETTINGS -------------------------------
		-- you can change true to false and false to true
		-- false means turn off
		-- true means turn on
		SetupAutoUlt= true -- Auto Ult
		SetupUltEffect=2 -- (between 1-5), script use ult when (Full_Ult_Heal_Possible_Value) > (One_Man_Ult_Heal_Possible_Value * SetupUltEffect)  

		SetupAutoHeal= true -- Auto Heal
		SetupHealGiveRate= 1 -- At which rate you should heal.      	Example: your usual heal gives 100 hp , SetupHealGiveRate=3 means 100x3, so script heals when target miss 300 hp

		SetupAutoMana= true -- Auto Mana
		SetupManaGiveRate= 3 -- At which rate you should give mana. 	Example: your usual mana gives 50 mana, SetupManaGiveRate=2 means 50x2, so script gives mana when target miss 100 mana. Check 1 rate if you want give mana often

		SetupAutoSilence= true -- Auto Silence --in development
		SetupAntiKarthus= true -- Soraka AutoUlt KarthusUlt on low hp targets

		SetupAutoStarcall= true -- Auto Starcall
		SetupStarcallLimit = 200 -- Does not cast Starcall when mana falls below this level

		SetupDistance= 850 -- How much distance to use spells

		SetupTogleKey= 117	--Key to Togle script. [ F6 - 117 ] default
							--key codes
							--http://www.indigorose.com/webhelp/ams/Program_Reference/Misc/Virtual_Key_Codes.htm 

		SetupAutoLvLSpell= true -- AutoLvL Spells of soraka
		abilitySequence = {2,3,2,3,2,4,2,3,2,3,4,3,1,1,1,4,1,1} -- list for SetupAutoLvLSpell

		SetupDrawInfo = true -- Drawing usefull info on screen
		SetupDrawX = 0.8 
		SetupDrawY = 0.2 -- Position of info, minimum = 0, maximum = 1, SetupDrawX - width, SetupDrawY - height

		recentrecallTarget = player



		------------------------------- GLOBALS [Do Not Change] -------------------------------
		SetupDebug= false --Debug Mode
		abilityLevel = 0
		Soraka_SWITCH = true
		player = GetMyHero()

		--info table
		info = {}

		-- ultimate info
		info[1] = {} 
		info[1][1] = false -- state
		info[1][2] = 0 -- number
		info[1][3] = "ultimate: " -- text
		info[1][4] = 0 -- RED
		info[1][5] = 255 -- GREEN
		info[1][6] = 0 -- BLUE

		-- gold info
		info[2] = {} 
		info[2][1] = false -- state
		info[2][2] = 0 -- number
		info[2][3] = "gold/10sec: " -- text
		info[2][4] = 255 -- RED
		info[2][5] = 255 -- GREEN
		info[2][6] = 51 -- BLUE


		-- gold/10 info
		gold10SecAgo = 0
		GoldRefreshTick = 0

		-- spawn
		allySpawn = nil
		enemySpawn = nil

		recallStartTime = 0
		recallDetected = false

		-- disable name list from Barasia283
		disableArray = {
						"CaitlynAceintheHole", "Crowstorm", "Drain", "ReapTheWhirlwind", "FallenOne", "KatarinaR", "AlZaharNetherGrasp", 
						"GalioIdolOfDurand", "Meditate", "MissFortuneBulletTime", "AbsoluteZero", "Pantheon_Heartseeker", "Pantheon_GrandSkyfall_Jump", 
						"ShenStandUnited", "gate", "UrgotSwap2", "InfiniteDuress", "VarusQ"
						}

		------------------------------- MATH SPELLS -------------------------------

		-- HEAL
		function calcHeal(ignited)
			local rank = player:GetSpellData(1).level
			if rank == 0 then return nil end
			if ignited == false then
				if     rank == 1 then return math.floor(70  + player.ap * 0.45 + 0.5) 
				elseif rank == 2 then return math.floor(140 + player.ap * 0.45 + 0.5) 
				elseif rank == 3 then return math.floor(210 + player.ap * 0.45 + 0.5) 
				elseif rank == 4 then return math.floor(280 + player.ap * 0.45 + 0.5) 
				elseif rank == 5 then return math.floor(350 + player.ap * 0.45 + 0.5) end
			else
				if     rank == 1 then return math.floor((70   + player.ap * 0.45)/2 + 0.5) 
				elseif rank == 2 then return math.floor((140  + player.ap * 0.45)/2 + 0.5) 
				elseif rank == 3 then return math.floor((210  + player.ap * 0.45)/2 + 0.5) 
				elseif rank == 4 then return math.floor((280  + player.ap * 0.45)/2 + 0.5) 
				elseif rank == 5 then return math.floor((350  + player.ap * 0.45)/2 + 0.5) end
			end
		end

		function calcHealResult(hero)
			local healValue = calcHeal(isIgnited(hero))
			if healValue == nil then return nil end
			-- return healed value
			if (hero.maxHealth - hero.health) < healValue then return hero.maxHealth - hero.health else return healValue end
		end

		-- MANA
		function calcMana()
			local rank = player:GetSpellData(2).level
			if rank == 0 then return nil
			elseif rank == 1 then return 40
			elseif rank == 2 then return 80
			elseif rank == 3 then return 120
			elseif rank == 4 then return 160
			elseif rank == 5 then return 200 end
		end

		function calcManaResult(hero)
			local manaValue = calcMana()
			if manaValue == nil then return nil end
			-- return mana'ed value
			if (hero.maxMana - hero.mana) < manaValue then return hero.maxMana - hero.mana else return manaValue end
		end

		-- ULT
		function calcUlt(ignited)
			local rank = player:GetSpellData(3).level
			if rank == 0 then return nil end
			if ignited == false then
				if 	   rank == 1 then return math.floor(200 + player.ap * 0.7 + 0.5) 
				elseif rank == 2 then return math.floor(320 + player.ap * 0.7 + 0.5)
				elseif rank == 3 then return math.floor(440 + player.ap * 0.7 + 0.5) end
			else
				if 	   rank == 1 then return math.floor((200 + player.ap * 0.7)/2 + 0.5) 
				elseif rank == 2 then return math.floor((320 + player.ap * 0.7)/2 + 0.5)
				elseif rank == 3 then return math.floor((440 + player.ap * 0.7)/2 + 0.5) end
			end
		end

		function calcUltResult()
			if calcUlt(false) == nil then return nil end
			--calc ult for players
			local ultResult = 0
			local players = GetPlayers(player.team , false, true)
			for i=1, #players, 1 do
				-- dont count targets at Spawn
				if isInSpawn(players[i]) == false and isRecall(players[i]) == false then
					if (players[i].maxHealth - players[i].health) < calcUlt(isIgnited(players[i])) then 
						ultResult = ultResult +  players[i].maxHealth - players[i].health 
					else 
						ultResult = ultResult + calcUlt(isIgnited(players[i]))
					end
				end
			end
			--return total result
			return math.floor(ultResult + 0.5)
		end

		------------------------------- ABSTRACTION-METHODS -------------------------------
		-- return players table
		function GetPlayers(team, includeDead, includeSelf)
			local players = {}
			for i=1, heroManager.iCount, 1 do
				local member = heroManager:getHero(i)
				if member ~= nil and member.type == "obj_AI_Hero" and member.team == team then
					if member.charName ~= player.charName or includeSelf then 
						if includeDead then
							table.insert(players,member)
						elseif member.dead == false then
							table.insert(players,member)
						end
					end
				end
			end
			return players
		end

		-- return towers table
		function GetTowers(team)
			local towers = {}
			for i=1, objManager.maxObjects, 1 do
				local tower = objManager:getObject(i)
				if tower ~= nil and tower.type == "obj_AI_Turret" and tower.visible and tower.team == team then
					table.insert(towers,tower)
				end
			end
			if #towers > 0 then
				return towers
			else
				return false
			end
		end

		-- here get close tower
		function GetCloseTower(hero, team)
			local towers = GetTowers(team)
			if #towers > 0 then
				local candidate = towers[1]
				for i=2, #towers, 1 do
					if (towers[i].health/towers[i].maxHealth > 0.1) and  hero:GetDistance(candidate) > hero:GetDistance(towers[i]) then candidate = towers[i] end
				end
				return candidate
			else
				return false
			end
		end

		-- here get close player
		function GetClosePlayer(hero, team)
			local players = GetPlayers(team,false)
			if #players > 0 then
				local candidate = players[1]
				for i=2, #players, 1 do
					if hero:GetDistance(candidate) > hero:GetDistance(players[i]) then candidate = players[i] end
				end
				return candidate
			else
				return false
			end
		end

		-- return count of champs near hero
		function cntOfChampsNear(hero,team,distance)
			local cnt = 0 -- default count of champs near HERO
			local players = GetPlayers(team,false)
			for i=1, #players, 1 do
				if hero:GetDistance(players[i]) < distance then cnt = cnt + 1 end
			end
			return cnt
		end

		-- return %hp of champs near hero
		function hpOfChampsNear(hero,team,distance)
			local percent = 0 -- default %hp of champs near HERO
			local players = GetPlayers(team,false)
			for i=1, #players, 1 do
				if hero:GetDistance(players[i]) < distance then percent = percent + players[i].health/players[i].maxHealth end
			end
			return percent
		end

		-- is recall, return true/false
		function isRecall(hero)
			if GetTickCount() - recallStartTime > 8000 then
				return false
			else
				if recentrecallTarget.name == hero.name then
					return true
				end
				return false
			end
		end

		function OnCreateObj(object)
			if object.name == "TeleportHomeImproved.troy" or object.name == "TeleportHome.troy" then
				for i = 1, heroManager.iCount do
					local target = heroManager:GetHero(i)
					if GetDistance(target, object) < 100 then
						recentrecallTarget = target
					end
				end
				recallStartTime = GetTickCount()
			end
		end


		-- CHECK IS HERO IGNITED
		 function isIgnited(hero)
			if detectBuffs(hero,{"SummonerDot","grievouswound"}) then return 1 else return 0 end
		 end

		 -- DETECT BUFFS IN TABLE buffs ON HERO
		 function detectBuffs(hero,buffs)
			for j = 1, hero.buffCount, 1 do
				buff = hero:getBuff(j)
				for i = 1, #buffs, 1 do
					if buff == buffs[i] then return true end
				end
			end
			return false
		 end
		 
		-- CHECK IS HERO IN SPAWN
		function isInSpawn(hero)
			if  math.sqrt((allySpawn.x - hero.x) ^ 2 + (allySpawn.z - hero.z) ^ 2) < 1000 then return true end
			return false
		end

		------------------------------- CORE -------------------------------
		function AutoUlt()
			if SetupDebug == true then PrintChat("debug >> AutoUlt()") end
			--check is ult lvled and ready
			if player:GetSpellData(3).level > 0 and  player:CanUseSpell(_R) == READY then
				if  calcUltResult() > (calcUlt(false) * SetupUltEffect) then
					CastSpell(_R)
				end
			end
		end

		--if SetupAutoSilence or SetupAntiKarthus then script.createObjectCallback = "AutoSilence" end
		function AutoSilence(object) --Working on it
		--[[	if object ~= nil and object.name == "Data\Particles\FallenOne_nova.troy" and object.team == TEAM_ENEMY then 
				if player:GetSpellLevel(3) > 0 and  player:GetSpellState(_R) == STATE_READY and SetupAntiKarthus  then
					players = GetPlayers(player.team, false, true)
					for i=1,#players,1 do
						if karthus:CalculateMagicDamage(players[i],(400 * karthus.level/11 + karthus.ap * 0.6) *  1.2)  > players[i].health then
							player:UseSpell(_R)
							PrintChat("SORAKA SLACK >> AntiKarthus Ultimate!")
						end
					end
				end
			end]]
		end

		function OnProcessSpell(object,spellProc)
			if player:GetSpellData(2).level > 0 and player:CanUseSpell(_E) == READY and SetupAutoSilence == true and Soraka_SWITCH == true and object.team ~= player.team then
				for i = 1, #disableArray, 1 do
					if GetDistance(object, player) < 725 then
						if spellProc.name == disableArray[i] then
							CastSpell(_E, object)
						end
					end
				end
			end
		end


		function AutoHeal()
			if SetupDebug == true then PrintChat("debug >> AutoHeal()") end
			--check is heal lvled and ready
			if player:GetSpellData(1).level > 0 and player:CanUseSpell(_W) == READY then
				local healTarget = nil
				local players = GetPlayers(player.team, false, true)
				-- check is need heal and select target
				for i=1, #players, 1 do
					if player:GetDistance(players[i]) < SetupDistance and isRecall(players[i]) == false and isInSpawn(players[i]) == false then
						-- calculate is need heal to target
						if healTarget ~= nil and ((players[i].maxHealth - players[i].health) / (isIgnited(players[i]) + 1)) > ((healTarget.maxHealth - healTarget.health) / (isIgnited(healTarget) + 1)) then healTarget = players[i]
						elseif  healTarget == nil and (players[i].maxHealth - players[i].health) > (calcHeal(isIgnited(players[i])) * SetupHealGiveRate) then healTarget = players[i] end
					end
				end
				--heal targets
				if  healTarget ~= nil then CastSpell(_W, healTarget) end
			end
		end

		function AutoStarcall()
			--check Q lvled and ready
			if player:GetSpellData(0).level > 0 and player:CanUseSpell(_Q) == READY then
				for i = 1, heroManager.iCount do
					local target = heroManager:GetHero(i)
					if target ~= nil and target.team ~= player.team and GetDistance(target, player) < 500 and player.mana > SetupStarcallLimit then
						CastSpell(_Q)
					end
				end
			end
		end
			

		function AutoMana() --Champion check seems bugged ?
			if SetupDebug == true then PrintChat("debug >> AutoMana()") end
			--check is E lvled and ready
			if player:GetSpellData(2).level > 0 and player:CanUseSpell(_E) == READY then
				local manaTarget = nil
				local players = GetPlayers(player.team, false, false)
				-- check is need mana and select target
				for i=1, #players, 1 do
					if isRecall(players[i]) == false and isInSpawn(players[i]) == false and players[i].charName ~= "Mordekaiser" and player:GetDistance(players[i]) < SetupDistance and players[i].maxMana > 201 then
						-- calculate is need mana to target
						if manaTarget ~= nil and (players[i].maxMana - players[i].mana) > (manaTarget.maxMana - manaTarget.mana) then manaTarget = players[i]
						elseif manaTarget == nil and (players[i].maxMana - players[i].mana) > (calcMana() * SetupManaGiveRate) then manaTarget = players[i] end
					end
				end
				--mana targets
				if  manaTarget ~= nil then CastSpell(_E, manaTarget) end
			end
		end

		--get info to draw
		--called every TimerCallback
		function GetInfo()
			--ultimate info
			if player:GetSpellData(3).level > 0 --[[and player:GetSpellState(_R) == STATE_READY]] then
				info[1][2] = calcUltResult()
				info[1][1] = true
			else info[1][1] = false end
			--gold / 10 info
			if GetTickCount() - GoldRefreshTick > 9999 then
				if (player.gold - gold10SecAgo) > 0 and (player.gold - gold10SecAgo) < 84 then
					info[2][1] = true
					
					info[2][2] = string.format("%.02f", (player.gold - gold10SecAgo))
				end
				gold10SecAgo = player.gold
				GoldRefreshTick = GetTickCount()
			end
			
		end

		--draw info
		--called every frame
		function OnDraw()
			if SetupDrawInfo then
				local curString = 0
				for i=1, #info, 1 do
					if info[i][1] then
							--    text 
						DrawText(info[i][3]..tostring(info[i][2]),
							-- size   			x      					   				y                                   
								20 , (WINDOW_W - WINDOW_X) * SetupDrawX,  (WINDOW_H - WINDOW_Y) * SetupDrawY + curString, 0xFF00FF00)
						curString = curString + 20
					end
				end
			end
		end

		--turn off - on
		function OnWndMsg(msg, keycode)
			if keycode == SetupTogleKey and msg == KEY_DOWN then
				if SetupDebug == true then PrintChat("debug >> Toggle(msg, keycode == SetupTogleKey )") end
				if Soraka_SWITCH == true then
					Soraka_SWITCH = false
					PrintChat("<font color='#FF0000'> SORAKA SLACK >> Run Soraka, RUN </font>")
				else
					Soraka_SWITCH = true
					PrintChat("<font color='#00FF00'> SORAKA SLACK >> Heal Soraka, HEAL </font>")
				end
			end
		end

		-- TIMER and BRAIN
		function OnTick() --Need 200ms interval
			if SetupDebug then PrintChat("debug >> Timer(tick)") end
			if player.dead == false and isRecall(player) == false then
				if Soraka_SWITCH then
					if SetupAutoUlt then AutoUlt() end
					if SetupAutoStarcall then AutoStarcall() end
					if SetupAutoHeal then AutoHeal() end
					if SetupAutoMana then AutoMana() end
				end
			end
			if SetupAutoLvLSpell and player.level > abilityLevel then
				abilityLevel=abilityLevel+1
				if abilitySequence[abilityLevel] == 1 then LevelSpell(_Q)
				elseif abilitySequence[abilityLevel] == 2 then LevelSpell(_W)
				elseif abilitySequence[abilityLevel] == 3 then LevelSpell(_E)
				elseif abilitySequence[abilityLevel] == 4 then LevelSpell(_R) end
			end
			if SetupDrawInfo then GetInfo() end
		end
		-- LOAD --
		function OnLoad()
			player = GetMyHero()
			PrintChat("SORAKA SLACK >> SORAKA SLACKER v8.3 loaded!")	
			-- numerate spawn
			for i=1, objManager.maxObjects, 1 do
				local candidate = objManager:getObject(i)
				if candidate ~= nil and candidate.type == "obj_SpawnPoint" then 
					if candidate.x < 3000 then 
						if player.team == TEAM_BLUE then allySpawn = candidate else enemySpawn = candidate end
					else 
						if player.team == TEAM_BLUE then enemySpawn = candidate else allySpawn = candidate end
					end
				end
			end
		end
	-------------------------------------------------------------------------------------------------------------		
	elseif GetMyHero().charName == "Taric" then
		--[[
				TARIC HEALER v0.01
			   
				Modified by Gatugeniet
		 
				Originalscript SORAKA SLACKER
				By Ivan[russia]
				Credits To Zynox/grey autolvl spell/ikita autosilence/nanja taric/wee Ward Scanner
				I Learned From Their Previous Scripts
				v7: script heal ignited too, but now it preffer unignated targets
			   
				Updated for BoL by ikita v8.3
				Credits to Barasia283 for everything on auto silence
		--]]
		 
		------------------------------- SETTINGS -------------------------------
		-- you can change true to false and false to true
		-- false means turn off
		-- true means turn on
		 
		SetupAutoHeal= true -- Auto Heal
		SetupHealGiveRate= 1 -- At which rate you should heal.          Example: your usual heal gives 100 hp , SetupHealGiveRate=3 means 100x3, so script heals when target miss 300 hp
		 
		SetupAutoSilence= true -- Auto Silence --in development
		 
		SetupDistance= 850 -- How much distance to use spells
		 
		SetupTogleKey= 117      --Key to Togle script. [ F6 - 117 ] default
												--key codes
												--http://www.indigorose.com/webhelp/ams/Program_Reference/Misc/Virtual_Key_Codes.htm
		 
		SetupAutoLvLSpell= false -- AutoLvL Spells of Taric
		abilitySequence = {3,2,1,2,2,4,2,1,2,1,4,1,1,3,3,4,3,3} -- list for SetupAutoLvLSpell
		 
		SetupDrawInfo = true -- Drawing usefull info on screen
		SetupDrawX = 0.8
		SetupDrawY = 0.2 -- Position of info, minimum = 0, maximum = 1, SetupDrawX - width, SetupDrawY - height
		 
		recentrecallTarget = player
		 
		 
		 
		------------------------------- GLOBALS [Do Not Change] -------------------------------
		SetupDebug= false --Debug Mode
		abilityLevel = 0
		TARIC_SWITCH = true
		player = GetMyHero()
		 
		--info table
		info = {}
		 
		-- ultimate info
		info[1] = {}
		info[1][1] = false -- state
		info[1][2] = 0 -- number
		info[1][3] = "ultimate: " -- text
		info[1][4] = 0 -- RED
		info[1][5] = 255 -- GREEN
		info[1][6] = 0 -- BLUE
		 
		-- gold info
		info[2] = {}
		info[2][1] = false -- state
		info[2][2] = 0 -- number
		info[2][3] = "gold/10sec: " -- text
		info[2][4] = 255 -- RED
		info[2][5] = 255 -- GREEN
		info[2][6] = 51 -- BLUE
		 
		 
		-- gold/10 info
		gold10SecAgo = 0
		GoldRefreshTick = 0
		 
		-- spawn
		allySpawn = nil
		enemySpawn = nil
		 
		recallStartTime = 0
		recallDetected = false
		 
		-- disable name list from Barasia283
		disableArray = {
										"CaitlynAceintheHole", "Crowstorm", "Drain", "ReapTheWhirlwind", "FallenOne", "KatarinaR", "AlZaharNetherGrasp",
										"GalioIdolOfDurand", "Meditate", "MissFortuneBulletTime", "AbsoluteZero", "Pantheon_Heartseeker", "Pantheon_GrandSkyfall_Jump",
										"ShenStandUnited", "gate", "UrgotSwap2", "InfiniteDuress", "VarusQ"
										}
		 
		------------------------------- MATH SPELLS -------------------------------
		 
		-- HEAL
		function calcHeal(ignited)
				local rank = player:GetSpellData(0).level
				local healAmount = 0
			   
				if rank == 0 then return nil end
				if     rank == 1 then healAmount = math.floor(60  + player.ap * 0.6 + 0.5)
				elseif rank == 2 then healAmount = math.floor(100 + player.ap * 0.6 + 0.5)
				elseif rank == 3 then healAmount = math.floor(140 + player.ap * 0.6 + 0.5)
				elseif rank == 4 then healAmount = math.floor(180 + player.ap * 0.6 + 0.5)
				elseif rank == 5 then healAmount = math.floor(220 + player.ap * 0.6 + 0.5)
				end
		 
				if ignited == true then healAmount = math.floor(healAmount * 0.5 + 0.5) end
		 
				return healAmount
		end
		 
		function calcHealResult(hero)
				local healValue = calcHeal(isIgnited(hero))
				if hero == player then
						local healValueSelf
						local rank = player:GetSpellData(0).level
					   
						if rank == 0 then return nil end
						if     rank == 1 then healValueSelf = math.floor(84  + player.ap * 0.84 + 0.5)
						elseif rank == 2 then healValueSelf = math.floor(140 + player.ap * 0.84 + 0.5)
						elseif rank == 3 then healValueSelf = math.floor(196 + player.ap * 0.84 + 0.5)
						elseif rank == 4 then healValueSelf = math.floor(252 + player.ap * 0.84 + 0.5)
						elseif rank == 5 then healValueSelf = math.floor(308 + player.ap * 0.84 + 0.5)
						end
		 
						healValue = healValueSelf
				end
		 
				if healValue == nil then return nil end
				-- return healed value
				if (hero.maxHealth - hero.health) < healValue then return hero.maxHealth - hero.health else return healValue end
		end
		 
		------------------------------- ABSTRACTION-METHODS -------------------------------
		-- return players table
		function GetPlayers(team, includeDead, includeSelf)
				local players = {}
				for i=1, heroManager.iCount, 1 do
						local member = heroManager:getHero(i)
						if member ~= nil and member.type == "obj_AI_Hero" and member.team == team then
								if member.charName ~= player.charName or includeSelf then
										if includeDead then
												table.insert(players,member)
										elseif member.dead == false then
												table.insert(players,member)
										end
								end
						end
				end
				return players
		end
		 
		-- return towers table
		function GetTowers(team)
				local towers = {}
				for i=1, objManager.maxObjects, 1 do
						local tower = objManager:getObject(i)
						if tower ~= nil and tower.type == "obj_AI_Turret" and tower.visible and tower.team == team then
								table.insert(towers,tower)
						end
				end
				if #towers > 0 then
						return towers
				else
						return false
				end
		end
		 
		-- here get close tower
		function GetCloseTower(hero, team)
				local towers = GetTowers(team)
				if #towers > 0 then
						local candidate = towers[1]
						for i=2, #towers, 1 do
								if (towers[i].health/towers[i].maxHealth > 0.1) and  hero:GetDistance(candidate) > hero:GetDistance(towers[i]) then candidate = towers[i] end
						end
						return candidate
				else
						return false
				end
		end
		 
		-- here get close player
		function GetClosePlayer(hero, team)
				local players = GetPlayers(team,false)
				if #players > 0 then
						local candidate = players[1]
						for i=2, #players, 1 do
								if hero:GetDistance(candidate) > hero:GetDistance(players[i]) then candidate = players[i] end
						end
						return candidate
				else
						return false
				end
		end
		 
		-- return count of champs near hero
		function cntOfChampsNear(hero,team,distance)
				local cnt = 0 -- default count of champs near HERO
				local players = GetPlayers(team,false)
				for i=1, #players, 1 do
						if hero:GetDistance(players[i]) < distance then cnt = cnt + 1 end
				end
				return cnt
		end
		 
		-- return %hp of champs near hero
		function hpOfChampsNear(hero,team,distance)
				local percent = 0 -- default %hp of champs near HERO
				local players = GetPlayers(team,false)
				for i=1, #players, 1 do
						if hero:GetDistance(players[i]) < distance then percent = percent + players[i].health/players[i].maxHealth end
				end
				return percent
		end
		 
		-- is recall, return true/false
		function isRecall(hero)
				if GetTickCount() - recallStartTime > 8000 then
						return false
				else
						if recentrecallTarget.name == hero.name then
								return true
						end
						return false
				end
		end
		 
		function OnCreateObj(object)
				if object.name == "TeleportHomeImproved.troy" or object.name == "TeleportHome.troy" then
						for i = 1, heroManager.iCount do
								local target = heroManager:GetHero(i)
								if GetDistance(target, object) < 100 then
										recentrecallTarget = target
								end
						end
						recallStartTime = GetTickCount()
				end
		end
		 
		 
		-- CHECK IS HERO IGNITED
		 function isIgnited(hero)
				if detectBuffs(hero,{"SummonerDot","grievouswound"}) then return 1 else return 0 end
		 end
		 
		 -- DETECT BUFFS IN TABLE buffs ON HERO
		 function detectBuffs(hero,buffs)
				for j = 1, hero.buffCount, 1 do
						buff = hero:getBuff(j)
						for i = 1, #buffs, 1 do
								if buff == buffs[i] then return true end
						end
				end
				return false
		 end
		 
		-- CHECK IS HERO IN SPAWN
		function isInSpawn(hero)
				if  math.sqrt((allySpawn.x - hero.x) ^ 2 + (allySpawn.z - hero.z) ^ 2) < 1000 then return true end
				return false
		end
		 
		------------------------------- CORE -------------------------------
		 
		 
		--if SetupAutoSilence or SetupAntiKarthus then script.createObjectCallback = "AutoSilence" end
		function AutoSilence(object) --Working on it
		--[[    if object ~= nil and object.name == "Data\Particles\FallenOne_nova.troy" and object.team == TEAM_ENEMY then
						if player:GetSpellLevel(3) > 0 and  player:GetSpellState(_R) == STATE_READY and SetupAntiKarthus  then
								players = GetPlayers(player.team, false, true)
								for i=1,#players,1 do
										if karthus:CalculateMagicDamage(players[i],(400 * karthus.level/11 + karthus.ap * 0.6) *  1.2)  > players[i].health then
												player:UseSpell(_R)
												PrintChat("TARIC SLACK >> AntiKarthus Ultimate!")
										end
								end
						end
				end]]
		end
		 
		function OnProcessSpell(object,spellProc)
				if player:GetSpellData(3).level > 0 and player:CanUseSpell(_E) == READY and SetupAutoSilence == true and TARIC_SWITCH == true and object.team ~= player.team then
						for i = 1, #disableArray, 1 do
								if GetDistance(object, player) < 725 then
										if spellProc.name == disableArray[i] then
												CastSpell(_E, object)
										end
								end
						end
				end
		end
		 
		 
		function AutoHeal()
				if SetupDebug == true then PrintChat("debug >> AutoHeal()") end
				--check is heal lvled and ready
				if player:GetSpellData(0).level > 0 and player:CanUseSpell(_Q) == READY then
						local healTarget = nil
						local players = GetPlayers(player.team, false, true)
						-- check is need heal and select target
						for i=1, #players, 1 do
								if player:GetDistance(players[i]) < SetupDistance and isRecall(players[i]) == false and isInSpawn(players[i]) == false then
										-- calculate is need heal to target
										if healTarget ~= nil and ((players[i].maxHealth - players[i].health) / (isIgnited(players[i]) + 1)) > ((healTarget.maxHealth - healTarget.health) / (isIgnited(healTarget) + 1)) then healTarget = players[i]
										elseif  healTarget == nil and (players[i].maxHealth - players[i].health) > (calcHeal(isIgnited(players[i])) * SetupHealGiveRate) then healTarget = players[i] end
								end
						end
						--heal targets
						if  healTarget ~= nil then CastSpell(_Q, healTarget) end
				end
		end
		 
		 
		--get info to draw
		--called every TimerCallback
		function GetInfo()
				--gold / 10 info
				if GetTickCount() - GoldRefreshTick > 9999 then
						if (player.gold - gold10SecAgo) > 0 and (player.gold - gold10SecAgo) < 84 then
								info[2][1] = true
							   
								info[2][2] = string.format("%.02f", (player.gold - gold10SecAgo))
						end
						gold10SecAgo = player.gold
						GoldRefreshTick = GetTickCount()
				end
			   
		end
		 
		--draw info
		--called every frame
		function OnDraw()
				if SetupDrawInfo then
						local curString = 0
						for i=1, #info, 1 do
								if info[i][1] then
												--    text
										DrawText(info[i][3]..tostring(info[i][2]),
												-- size                         x                                                                       y                                  
														20 , (WINDOW_W - WINDOW_X) * SetupDrawX,  (WINDOW_H - WINDOW_Y) * SetupDrawY + curString, 0xFF00FF00)
										curString = curString + 20
								end
						end
				end
		end
		 
		--turn off - on
		function OnWndMsg(msg, keycode)
				if keycode == SetupTogleKey and msg == KEY_DOWN then
						if SetupDebug == true then PrintChat("debug >> Toggle(msg, keycode == SetupTogleKey )") end
				if TARIC_SWITCH == true then
					TARIC_SWITCH = false
								PrintChat("<font color='#FF0000'> TARIC HEALER >> Run Taric, RUN </font>")
				else
					TARIC_SWITCH = true
								PrintChat("<font color='#00FF00'> TARIC HEALER >> Heal Taric, HEAL </font>")
				end
			end
		end
		 
		-- TIMER and BRAIN
		function OnTick() --Need 200ms interval
				if SetupDebug then PrintChat("debug >> Timer(tick)") end
				if player.dead == false and isRecall(player) == false then
						if TARIC_SWITCH then
								if SetupAutoHeal then AutoHeal() end
						end
				end
			if SetupAutoLvLSpell and player.level > abilityLevel then
						abilityLevel=abilityLevel+1
						if abilitySequence[abilityLevel] == 1 then LevelSpell(_Q)
						elseif abilitySequence[abilityLevel] == 2 then LevelSpell(_W)
						elseif abilitySequence[abilityLevel] == 3 then LevelSpell(_E)
						elseif abilitySequence[abilityLevel] == 4 then LevelSpell(_R) end
				end
				if SetupDrawInfo then GetInfo() end
		end
		-- LOAD --
		function OnLoad()
				player = GetMyHero()
				PrintChat("TARIC AUTOHEAL >> TARIC HEALER v0.01 loaded!")      
				-- numerate spawn
				for i=1, objManager.maxObjects, 1 do
						local candidate = objManager:getObject(i)
						if candidate ~= nil and candidate.type == "obj_SpawnPoint" then
								if candidate.x < 3000 then
										if player.team == TEAM_BLUE then allySpawn = candidate else enemySpawn = candidate end
								else
										if player.team == TEAM_BLUE then enemySpawn = candidate else allySpawn = candidate end
								end
						end
				end
		end
	else
		local ts = TargetSelector(TARGET_LOW_HP,1000,false)
		function OnTick()
			ts:update()
			if ts.target ~= nil and ts.target.dead == false then
				QReady = (myHero:CanUseSpell(_Q) == READY )
				WReady = (myHero:CanUseSpell(_W) == READY )
				EReady = (myHero:CanUseSpell(_E) == READY )
				RReady = (myHero:CanUseSpell(_R) == READY )
				if QReady then CastSpell(_Q, ts.target) end
				if EReady then CastSpell(_E, ts.target) end
				if WReady then CastSpell(_W) end
				if RReady then CastSpell(_R) end
			end
		end
	end
end