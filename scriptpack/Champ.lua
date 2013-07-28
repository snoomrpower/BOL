--if GetGame().map.name == "Summoners Rift" then
----------------------------------------------------------
	if myHero.charName == "Annie" then
		--[[
		 
				-Full combo: Items -> Q -> W -> E -> R
		 
				-Supports Deathfire Grasp, Bilgewater Cutlass, Hextech Gunblade, Sheen, Trinity, Lich Bane, Ignite, Iceborn, Liandrys and Blackfire
		 
				-Target configuration, Press shift to configure
		 
			   
		 
				By burn, based on Trus sbtw annie script
		 
				Fixed by HeX
		 
		]]
		 
		 
		scriptActive = false
		 
		stunReadyFlag = false
		 
		existTibbers = false
		 
		ultiRange = 600        
		 
		ultiRadius = 230  
		 
		range = 620
		 
		killable = {}
		 
		local myObjectsTable = {}
		 
		local calculationenemy = 1
		 
		local waittxt = {}
		 
		local ts
		 
		local ignite = nil
		 
		local player = GetMyHero()
		 
		function OnLoad()
		 
				PrintChat(">> Annie Combo v1.0 loaded!")
		 
				if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then ignite = SUMMONER_1
		 
						elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then ignite = SUMMONER_2
		 
			else ignite = nil
		 
				end
		 
				AnnieConfig = scriptConfig("Annie Combo", "anniecombo")
		 
				AnnieConfig:addParam("scriptActive", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
		 
				AnnieConfig:addParam("harass", "Harass Enemy", SCRIPT_PARAM_ONKEYDOWN, false, 65) --a
		 
				AnnieConfig:addParam("autofarmQ", "Auto farm Q", SCRIPT_PARAM_ONKEYTOGGLE, false, 67)
		 
				AnnieConfig:addParam("drawcircles", "Draw Circles", SCRIPT_PARAM_ONOFF, true)
		 
				AnnieConfig:addParam("useE", "Use E", SCRIPT_PARAM_ONOFF, true)
		 
				AnnieConfig:permaShow("scriptActive")
		 
				AnnieConfig:permaShow("harass")
		 
				AnnieConfig:permaShow("autofarmQ")
		 
			   
		 
				ts = TargetSelector(TARGET_LOW_HP,range+30,DAMAGE_MAGIC,false)
		 
				ts.name = "Annie"
		 
				AnnieConfig:addTS(ts)
		 
			   
		 
				for i = 0, objManager.maxObjects, 1 do
		 
						local object = objManager:GetObject(i)
		 
						if objectIsValid(object) then table.insert(myObjectsTable, object) end
		 
				end
		 
		end
		 
		 
		 
		function OnTick()
		 
				ts:update()
		 
				--if existTibbers then
		 
				--PrintChat("Tibers ALIVE!")
		 
			--end  
		 
				--if existTibbers == false then
		 
				--PrintChat("NO tibers!")
		 
			--end  
		 
				DFGSlot, HXGSlot, BWCSlot, SheenSlot, TrinitySlot, LichBaneSlot = GetInventorySlotItem(3128), GetInventorySlotItem(3146), GetInventorySlotItem(3144), GetInventorySlotItem(3057), GetInventorySlotItem(3078), GetInventorySlotItem(3100)
		 
				IcebornSlot, LiandrysSlot, BlackfireSlot = GetInventorySlotItem(3025), GetInventorySlotItem(3151), GetInventorySlotItem(3188)  
		 
				QREADY = (myHero:CanUseSpell(_Q) == READY)
		 
				WREADY = (myHero:CanUseSpell(_W) == READY)
		 
				EREADY = (myHero:CanUseSpell(_E) == READY)
		 
				RREADY = (myHero:CanUseSpell(_R) == READY)
		 
				DFGREADY = (DFGSlot ~= nil and myHero:CanUseSpell(DFGSlot) == READY)
		 
				HXGREADY = (HXGSlot ~= nil and myHero:CanUseSpell(HXGSlot) == READY)
		 
				BWCREADY = (BWCSlot ~= nil and myHero:CanUseSpell(BWCSlot) == READY)
		 
				IREADY = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
		 
				DmgCalculation()
		 
			   
		 
				if AnnieConfig.autofarmQ and QREADY then
		 
						local myQ = math.floor((myHero:GetSpellData(_Q).level-1)*40 + 85 + myHero.ap * .7)
		 
						for i,object in ipairs(myObjectsTable) do
		 
								if objectIsValid(object) and object.health <= myHero:CalcDamage(object, myQ) and myHero:GetDistance(object) < 625 then 
		 
												CastSpell(_Q, object)
		 
								end
		 
						end
		 
				end
		 
				if AnnieConfig.harass and ts.target then
		 
						if QREADY and GetDistance(ts.target) <= range then CastSpell(_Q, ts.target) end
		 
						if WREADY and GetDistance(ts.target) < range then CastSpell(_W, ts.target.x, ts.target.z) end
		 
				end
		 
				if AnnieConfig.scriptActive and ts.target then
		 
						if DFGREADY then CastSpell(DFGSlot, ts.target) end
		 
						if HXGREADY then CastSpell(HXGSlot, ts.target) end
		 
						if BWCREADY then CastSpell(BWCSlot, ts.target) end
		 
						if stunReadyFlag then
		 
								if player:CanUseSpell(_R) == READY and myHero:GetDistance(ts.target) < 650 then
		 
										CastSpell(_R, ts.target.x, ts.target.z)
		 
								end
		 
		   end         
		 
						if QREADY and GetDistance(ts.target) <= range then CastSpell(_Q, ts.target) end  
		 
						if stunReadyFlag then
		 
								if player:CanUseSpell(_R) == READY and myHero:GetDistance(ts.target) < 650 then
		 
										CastSpell(_R, ts.target.x, ts.target.z)
		 
								end
		 
			end
		 
						if WREADY and GetDistance(ts.target) < range then CastSpell(_W, ts.target.x, ts.target.z) end
		 
						if EREADY and AnnieConfig.useE and not stunReadyFlag then CastSpell(_E) end    
		 
						if player:CanUseSpell(_R) == READY and myHero:GetDistance(ts.target) < 650 then
		 
								CastSpell(_R, ts.target.x, ts.target.z)
		 
						end
		 
						if myHero:GetDistance(ts.target) < 650 and existTibbers then
		 
								CastSpell(_R,ts.target)
		 
						end
		 
						 
		 
				end
		 
		end
		 
		 
		 
		function OnCreateObj(object)
		 
				if object.name == "StunReady.troy" then stunReadyFlag = true end
		 
				if object.name == "BearFire_foot.troy" then existTibbers = true end
		 
		end
		 
		 
		 
		function OnDeleteObj(object)
		 
				if object.name == "StunReady.troy" then stunReadyFlag = false end
		 
				if object.name == "BearFire_foot.troy" then existTibbers = false end   
		 
		end
		 
		 
		 
		function OnWndMsg(msg,key)
		 
		end
		 
		 
		 
		function OnSendChat(msg)
		 
				ts:OnSendChat(msg, "pri")
		 
		end
		 
		 
		 
		function DmgCalculation()
		 
						local enemy = heroManager:GetHero(calculationenemy)
		 
						if ValidTarget(enemy) then
		 
								local dfgdamage, hxgdamage, bwcdamage, ignitedamage, Sheendamage, Trinitydamage, LichBanedamage  = 0, 0, 0, 0, 0, 0, 0
		 
								local qdamage = getDmg("Q",enemy,myHero)
		 
								local wdamage = getDmg("W",enemy,myHero)
		 
								local rdamage = getDmg("R",enemy,myHero)
		 
								local dfgdamage = (DFGSlot and getDmg("DFG",enemy,myHero) or 0)
		 
								local hxgdamage = (HXGSlot and getDmg("HXG",enemy,myHero) or 0)
		 
								local bwcdamage = (BWCSlot and getDmg("BWC",enemy,myHero) or 0)
		 
								local ignitedamage = (ignite and getDmg("IGNITE",enemy,myHero) or 0)
		 
								local onhitdmg = (SheenSlot and getDmg("SHEEN",enemy,myHero) or 0)+(TrinitySlot and getDmg("TRINITY",enemy,myHero) or 0)+(LichBaneSlot and getDmg("LICHBANE",enemy,myHero) or 0)+(IcebornSlot and getDmg("ICEBORN",enemy,myHero) or 0)                                                 
		 
								local onspelldamage = (LiandrysSlot and getDmg("LIANDRYS",enemy,myHero) or 0)+(BlackfireSlot and getDmg("BLACKFIRE",enemy,myHero) or 0)
		 
								local combo1 = onspelldamage
		 
								local combo2 = onhitdmg + qdamage + wdamage + rdamage + dfgdamage + hxgdamage + bwcdamage + ignitedamage + onspelldamage
		 
								if QREADY then
		 
										combo1 = combo1 + qdamage
		 
								end
		 
								if WREADY then
		 
										combo1 = combo1 + wdamage
		 
								end
		 
								if (RREADY and not existTibbers) then
		 
										combo1 = combo1 + rdamage
		 
								end            
		 
								if HXGREADY then              
		 
										combo1 = combo1 + hxgdamage    
		 
								end
		 
								if BWCREADY then
		 
										combo1 = combo1 + bwcdamage
		 
								end
		 
								if DFGREADY then        
		 
										combo1 = combo1*1.2 + dfgdamage            
		 
								end                    
		 
								if IREADY then
		 
										combo1 = combo1 + ignitedamage
		 
								end
		 
								combo1 = combo1 + onhitdmg
		 
								if combo1 >= enemy.health then killable[calculationenemy] = 1
		 
								elseif combo2 >= enemy.health then killable[calculationenemy] = 2
		 
								else killable[calculationenemy] = 0 end
		 
						end    
		 
						if calculationenemy == 1 then
		 
								calculationenemy = heroManager.iCount
		 
						else
		 
								calculationenemy = calculationenemy-1
		 
						end
		 
		end
		 
		 
		 
		function OnDraw()
		 
				if AnnieConfig.drawcircles and not myHero.dead then
		 
						DrawCircle(myHero.x, myHero.y, myHero.z, range, 0x19A712)
		 
						if ts.target ~= nil then
		 
								for j=0, 5 do
		 
										DrawCircle(ts.target.x, ts.target.y, ts.target.z, 40 + j*1.5, 0x00FF00)
		 
								end
		 
						end
		 
						for i=1, heroManager.iCount do
		 
								local enemydraw = heroManager:GetHero(i)
		 
								if ValidTarget(enemydraw) then
		 
										if killable[i] == 2 then
		 
												for j=0, 20 do
		 
														DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 80 + j*1.5, 0x0000FF)
		 
												end
		 
												PrintFloatText(enemydraw,0,"Skills are not available")
		 
										elseif killable[i] == 1 then
		 
												for j=0, 10 do
		 
														DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 80 + j*1.5, 0xFF0000)
		 
														DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 110 + j*1.5, 0xFF0000)
		 
														DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 140 + j*1.5, 0xFF0000)
		 
												end
		 
												PrintFloatText(enemydraw,0,"Kill him!")
		 
										end
		 
								end
		 
						end
		 
				end
		 
		end
		 
		 
		 
		function objectIsValid(object)
		 
		   return object and object.valid and string.find(object.name,"Minion_") ~= nil and object.team ~= myHero.team and object.dead == false
		 
		end
		 
		 
		 
		function OnCreateObj(object)
		 
		   if objectIsValid(object) then table.insert(myObjectsTable, object) end
		 
		end
--------------------------------------------------------------------
	elseif myHero.charName == "Diana" then
		--[[
			Diana Combo 1.10 by eXtragoZ
				
					It requires the AllClass Library and Spell Damage Library

			-Full combo: items -> Q -> R -> W -> E
			-Supports Deathfire Grasp, Bilgewater Cutlass, Hextech Gunblade, Sheen, Trinity, Lich Bane and Ignite
			-Harass mode: Q
			-The ultimate only will be used if it will reset
			-Maximum and minimum range for E
			-Maximum range for W
			-You can press T or Q -> spacebar
			-Informs where will use Q / default off
			-Mark killable target with a combo
			-Target configuration
			-Press shift to configure

			Explanation of the marks:

			Green circle:  Marks the current target to which you will do the combo
			Blue circle:  Mark a target that can be killed with a combo, if all the skills were available
			Red circle:  Mark a target that can be killed using items + pasive + 2 hits + Q x2 + W (3 orbs) + R x2 + ignite
			2 Red circles:  Mark a target that can be killed using items + 1 hits + Q + W (2 orbs) + R + R (if q is not on cd) + ignite
			3 Red circles:  Mark a target that can be killed using items (without Sheen, Trinity and Lich Bane) + Q + W (1 orb) + R
		   
		]]
		--[[            Code            ]]
		local range = 900
		local qcastspeed = 600
		local tick = nil
		-- Active
		local moonlightenemy = {}
		local moonlightts = 0
		local moonlightdone = false
		-- draw
		local waittxt = {}
		local calculationenemy = 1
		local floattext = {"Skills are not available","Able to fight","Killable","Murder him!"}
		local killable = {}
		-- ts
		local ts
		--
		local ignite = nil
		local DFGSlot, HXGSlot, BWCSlot, SheenSlot, TrinitySlot, LichBaneSlot = nil, nil, nil, nil, nil, nil
		local QREADY, WREADY, EREADY, RREADY, DFGREADY, HXGREADY, BWCREADY, IREADY = false, false, false, false, false, false, false, false
		 
		function OnLoad()
			DCConfig = scriptConfig("Diana Combo 1.10", "dianacombo")
			DCConfig:addParam("scriptActive", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 84)
			DCConfig:addParam("harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("G"))
			DCConfig:addParam("drawcircles", "Draw Circles", SCRIPT_PARAM_ONOFF, true)
			DCConfig:addParam("drawtext", "Draw Text", SCRIPT_PARAM_ONOFF, true)
			DCConfig:addParam("drawprediction", "Draw Prediction", SCRIPT_PARAM_ONOFF, false)
			DCConfig:addParam("useE", "Use E", SCRIPT_PARAM_ONOFF, true)
			DCConfig:permaShow("scriptActive")
			DCConfig:permaShow("harass")
			ts = TargetSelector(TARGET_LOW_HP,range,DAMAGE_MAGIC)
			ts:SetPrediction(qcastspeed)
			ts.name = "Diana"
			DCConfig:addTS(ts)
			if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then ignite = SUMMONER_1
			elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then ignite = SUMMONER_2 end
			for i=1, heroManager.iCount do
				waittxt[i] = i*3
				moonlightenemy[i] = 0
			end
		end

		function OnTick()
			ts:update()
			Prediction__OnTick()
			DFGSlot, HXGSlot, BWCSlot, SheenSlot, TrinitySlot, LichBaneSlot = GetInventorySlotItem(3128), GetInventorySlotItem(3146), GetInventorySlotItem(3144), GetInventorySlotItem(3057), GetInventorySlotItem(3078), GetInventorySlotItem(3100)
			QREADY = (myHero:CanUseSpell(_Q) == READY)
			WREADY = (myHero:CanUseSpell(_W) == READY)
			EREADY = (myHero:CanUseSpell(_E) == READY)
			RREADY = (myHero:CanUseSpell(_R) == READY)
			DFGREADY = (DFGSlot ~= nil and myHero:CanUseSpell(DFGSlot) == READY)
			HXGREADY = (HXGSlot ~= nil and myHero:CanUseSpell(HXGSlot) == READY)
			BWCREADY = (BWCSlot ~= nil and myHero:CanUseSpell(BWCSlot) == READY)
			IREADY = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
			if tick == nil or GetTickCount()-tick >= 100 then
				tick = GetTickCount()
				DCDmgCalculation()
			end
			if ts.index ~= nil then moonlightts = moonlightenemy[ts.index] end
			if DCConfig.harass and ts.target then
				if QREADY and GetDistance(ts.target)<1100 then CastSpell(_Q, ts.nextPosition.x, ts.nextPosition.z) end
			end
			if DCConfig.scriptActive and ts.target then
				if DFGREADY then CastSpell(DFGSlot, ts.target) end
				if HXGREADY then CastSpell(HXGSlot, ts.target) end
				if BWCREADY then CastSpell(BWCSlot, ts.target) end
				if QREADY and GetDistance(ts.target)<1100 then CastSpell(_Q, ts.nextPosition.x, ts.nextPosition.z) end
				if RREADY and GetTickCount()-moonlightts < 3000 and not moonlightdone then
					moonlightdone = true
					CastSpell(_R,ts.target)
				end
				if WREADY and GetDistance(ts.target)<240 then CastSpell(_W,ts.target) end
				if EREADY and GetDistance(ts.target)>300 and GetDistance(ts.target)<410 and DCConfig.useE then CastSpell(_E,ts.target) end
			end
		end
		function DCDmgCalculation()
			local enemy = heroManager:GetHero(calculationenemy)
			if ValidTarget(enemy) then
				local dfgdamage, hxgdamage, bwcdamage, ignitedamage, Sheendamage, Trinitydamage, LichBanedamage  = 0, 0, 0, 0, 0, 0, 0
				local pdamage = getDmg("P",enemy,myHero) --Every third strike
				local qdamage = getDmg("Q",enemy,myHero)
				local wdamage = getDmg("W",enemy,myHero) --xOrb (3 orbs)
				local edamage = 0
				local rdamage = getDmg("R",enemy,myHero)
				local hitdamage = getDmg("AD",enemy,myHero)
				local dfgdamage = (DFGSlot and getDmg("DFG",enemy,myHero) or 0)
				local hxgdamage = (HXGSlot and getDmg("HXG",enemy,myHero) or 0)
				local bwcdamage = (BWCSlot and getDmg("BWC",enemy,myHero) or 0)
				local ignitedamage = (ignite and getDmg("IGNITE",enemy,myHero) or 0)
				local Sheendamage = (SheenSlot and getDmg("SHEEN",enemy,myHero) or 0)
				local Trinitydamage = (TrinitySlot and getDmg("TRINITY",enemy,myHero) or 0)
				local LichBanedamage = (LichBaneSlot and getDmg("LICHBANE",enemy,myHero) or 0)
				local combo1 = hitdamage*2 + pdamage + qdamage*2 + wdamage*3 + rdamage*2 + Sheendamage + Trinitydamage + LichBanedamage --0 cd
				local combo2 = hitdamage*2 + pdamage + Sheendamage + Trinitydamage + LichBanedamage
				local combo3 = hitdamage + Sheendamage + Trinitydamage + LichBanedamage
				local combo4 = 0
				if QREADY then
					combo2 = combo2 + qdamage*2
					combo3 = combo3 + qdamage
					combo4 = combo4 + qdamage
				end
				if WREADY then
					combo2 = combo2 + wdamage*3
					combo3 = combo3 + wdamage*2
					combo4 = combo4 + wdamage
				end
				if RREADY then
					combo2 = combo2 + rdamage*2
					if QREADY then
						combo3 = combo3 + rdamage*2
					else
						combo3 = combo3 + rdamage
					end
					combo4 = combo4 + rdamage
				end
				if DFGREADY then        
					combo1 = combo1 + dfgdamage            
					combo2 = combo2 + dfgdamage
					combo3 = combo3 + dfgdamage
					combo4 = combo4 + dfgdamage
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
				if IREADY then
					combo1 = combo1 + ignitedamage 
					combo2 = combo2 + ignitedamage
					combo3 = combo3 + ignitedamage
				end
				if combo4 >= enemy.health then killable[calculationenemy] = 4
				elseif combo3 >= enemy.health then killable[calculationenemy] = 3
				elseif combo2 >= enemy.health then killable[calculationenemy] = 2
				elseif combo1 >= enemy.health then killable[calculationenemy] = 1
				else killable[calculationenemy] = 0 end
			end
			if calculationenemy == 1 then calculationenemy = heroManager.iCount
			else calculationenemy = calculationenemy-1 end
		end
		function OnProcessSpell(unit, spell)
			if unit.isMe and spell.name == "DianaArc" then moonlightdone = false end
		end

		function OnCreateObj(moonlight)
			if moonlight.name:find("Diana_Q_moonlight_champ") then
				for i=1, heroManager.iCount do
					local enemy = heroManager:GetHero(i)
					if enemy.team ~= myHero.team and GetDistance(moonlight, enemy) < 80 then
						moonlightenemy[i] = GetTickCount()
					end
				end
			end
		end

		function OnDraw()
			if DCConfig.drawcircles and not myHero.dead then
				DrawCircle(myHero.x, myHero.y, myHero.z, range, 0x19A712)
				if ts.target ~= nil then
					for j=0, 10 do
						DrawCircle(ts.target.x, ts.target.y, ts.target.z, 40 + j*1.5, 0x00FF00)
					end
				end
			end
			if ts.target ~= nil and DCConfig.drawprediction then
				DrawCircle(ts.nextPosition.x, ts.target.y, ts.nextPosition.z, 200, 0x0000FF)
			end
			for i=1, heroManager.iCount do
				local enemydraw = heroManager:GetHero(i)
				if ValidTarget(enemydraw) then
					if DCConfig.drawcircles then
						if killable[i] == 1 then
							for j=0, 20 do
								DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 80 + j*1.5, 0x0000FF)
							end
						elseif killable[i] == 2 then
							for j=0, 10 do
								DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 80 + j*1.5, 0xFF0000)
							end
						elseif killable[i] == 3 then
							for j=0, 10 do
								DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 80 + j*1.5, 0xFF0000)
								DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 110 + j*1.5, 0xFF0000)
							end
						elseif killable[i] == 4 then
							for j=0, 10 do
								DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 80 + j*1.5, 0xFF0000)
								DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 110 + j*1.5, 0xFF0000)
								DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 140 + j*1.5, 0xFF0000)
							end
						end
					end
					if DCConfig.drawtext and waittxt[i] == 1 and killable[i] ~= 0 then
						PrintFloatText(enemydraw,0,floattext[killable[i]])
					end
				end
				if waittxt[i] == 1 then waittxt[i] = 30
				else waittxt[i] = waittxt[i]-1 end
			end
			SC__OnDraw()
		end
		function OnWndMsg(msg,key)
			SC__OnWndMsg(msg,key)
		end
		function OnSendChat(msg)
			TargetSelector__OnSendChat(msg)
			ts:OnSendChat(msg, "pri")
		end
		PrintChat(" >> Diana Combo 1.10 loaded!")
--------------------------------------------------------------------
	elseif myHero.charName == "FiddleSticks" then
		--[[
			FiddleSticks Combo 1.5
				by eXtragoZ

			Features:			
				- Full combo: Items -> E -> Q -> W
				- Supports: Deathfire Grasp, Liandry's Torment, Blackfire Torch, Bilgewater Cutlass, Hextech Gunblade, Blade of the Ruined King, Sheen, Trinity, Lich Bane, Iceborn Gauntlet, Shard of True Ice, Randuin's Omen and Ignite
				- Mark killable target with a combo
				- Target configuration
				- Press shift to configure

			Explanation of the marks:
				Green circle: Marks the current target to which you will do the combo
				Blue circle: Mark a target that can be killed with a combo, if all the skills were available
				Red circle: Mark a target that can be killed using items + 2 hits + W x5sec + E x2 + R x5sec + ignite
				2 Red circles: Mark a target that can be killed using items + 1 hits + W x4sec + E + R x2sec + ignite
				3 Red circles: Mark a target that can be killed using items + 1 hits + W x3sec + E
		]]

		--[[		Config		]]     
		local HK = 84 --spacebar
		--[[		Code		]]
		local qrange = 600 --575
		local wrange = 500 --475
		local erange = 775 --750
		local tick = nil
		-- Active
		local wactive = false
		local timew = 0
		-- draw
		local calculationenemy = 1
		local waittxt = {}
		local floattext = {"Skills are not available","Able to fight","Killable","Murder him!"}
		local killable = {}
		-- ts
		local ts
		local distancetstarget = 0
		--
		local ignite = nil
		local DFGSlot, HXGSlot, BWCSlot, SheenSlot, TrinitySlot, LBSlot, IGSlot, LTSlot, BTSlot, STISlot, ROSlot, BRKSlot = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
		local QREADY, WREADY, EREADY, RREADY, DFGREADY, HXGREADY, BWCREADY, STIREADY, ROREADY, BRKREADY, IREADY = false, false, false, false, false, false, false, false, false, false, false

		function OnLoad()
			FCConfig = scriptConfig("FiddleSticks Combo 1.5", "fiddlestickscombo")
			FCConfig:addParam("scriptActive", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, HK)
			FCConfig:addParam("drawcircles", "Draw Circles", SCRIPT_PARAM_ONOFF, true)
			FCConfig:addParam("drawtext", "Draw Text", SCRIPT_PARAM_ONOFF, true)
			FCConfig:permaShow("scriptActive")
			ts = TargetSelector(TARGET_LOW_HP,erange,DAMAGE_MAGIC)
			ts.name = "FiddleSticks"
			FCConfig:addTS(ts)
			if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then ignite = SUMMONER_1
			elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then ignite = SUMMONER_2 end
			for i=1, heroManager.iCount do waittxt[i] = i*3 end
			PrintChat(" >> FiddleSticks Combo 1.5 loaded!")
		end
			 
		function OnTick()
			ts:update()
			DFGSlot, HXGSlot, BWCSlot = GetInventorySlotItem(3128), GetInventorySlotItem(3146), GetInventorySlotItem(3144)
			SheenSlot, TrinitySlot, LBSlot = GetInventorySlotItem(3057), GetInventorySlotItem(3078), GetInventorySlotItem(3100)
			IGSlot, LTSlot, BTSlot = GetInventorySlotItem(3025), GetInventorySlotItem(3151), GetInventorySlotItem(3188)
			STISlot, ROSlot, BRKSlot = GetInventorySlotItem(3092),GetInventorySlotItem(3143),GetInventorySlotItem(3153)
			QREADY = (myHero:CanUseSpell(_Q) == READY)
			WREADY = (myHero:CanUseSpell(_W) == READY)
			EREADY = (myHero:CanUseSpell(_E) == READY)
			RREADY = (myHero:CanUseSpell(_R) == READY)
			DFGREADY = (DFGSlot ~= nil and myHero:CanUseSpell(DFGSlot) == READY)
			HXGREADY = (HXGSlot ~= nil and myHero:CanUseSpell(HXGSlot) == READY)
			BWCREADY = (BWCSlot ~= nil and myHero:CanUseSpell(BWCSlot) == READY)
			STIREADY = (STISlot ~= nil and myHero:CanUseSpell(STISlot) == READY)
			ROREADY = (ROSlot ~= nil and myHero:CanUseSpell(ROSlot) == READY)
			BRKREADY = (BRKSlot ~= nil and myHero:CanUseSpell(BRKSlot) == READY)
			IREADY = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
			if tick == nil or GetTickCount()-tick >= 100 then
				tick = GetTickCount()
				FCDmgCalculation()
			end
			if ts.target ~= nil then distancetstarget = GetDistance(ts.target) end
			wactive = (GetTickCount()-timew<500 or myHero.casting == 1) and not WREADY
			if FCConfig.scriptActive and ts.target ~= nil and not wactive then
				if DFGREADY then CastSpell(DFGSlot, ts.target) end
				if HXGREADY then CastSpell(HXGSlot, ts.target) end
				if BWCREADY then CastSpell(BWCSlot, ts.target) end
				if BRKREADY then CastSpell(BRKSlot, ts.target) end
				if STIREADY and distancetstarget<=380 then CastSpell(STISlot, myHero) end
				if ROREADY and distancetstarget<=500 then CastSpell(ROSlot) end
				if EREADY then CastSpell(_E, ts.target) end		
				if QREADY and distancetstarget<=qrange then CastSpell(_Q, ts.target) end			
				if WREADY and not QREADY and not EREADY and distancetstarget<=wrange then
					timew = GetTickCount()
					CastSpell(_W, ts.target)
				end			
			end
		end
		function FCDmgCalculation()
			local enemy = heroManager:GetHero(calculationenemy)
			if ValidTarget(enemy) then
				local pdamage = 0
				local qdamage = 0
				local wdamage = getDmg("W",enemy,myHero) --xsec (5 sec).
				local edamage = getDmg("E",enemy,myHero) --xbounce
				local rdamage = getDmg("R",enemy,myHero) --xsec (5 sec).
				local hitdamage = getDmg("AD",enemy,myHero)
				local dfgdamage = (DFGSlot and getDmg("DFG",enemy,myHero) or 0)--amplifies all magic damage they take by 20%
				local hxgdamage = (HXGSlot and getDmg("HXG",enemy,myHero) or 0)
				local bwcdamage = (BWCSlot and getDmg("BWC",enemy,myHero) or 0)
				local brkdamage = (BRKSlot and getDmg("RUINEDKING",enemy,myHero,2) or 0)
				local ignitedamage = (ignite and getDmg("IGNITE",enemy,myHero) or 0)
				local onhitdmg = (SheenSlot and getDmg("SHEEN",enemy,myHero) or 0)+(TrinitySlot and getDmg("TRINITY",enemy,myHero) or 0)+(LBSlot and getDmg("LICHBANE",enemy,myHero) or 0)+(IcebornSlot and getDmg("ICEBORN",enemy,myHero) or 0)
				local onspelldamage = (LTSlot and getDmg("LIANDRYS",enemy,myHero) or 0)+(BTSlot and getDmg("BLACKFIRE",enemy,myHero) or 0)
				local onspelldamage2 = 0
				
				local combo1 = hitdamage*2 + wdamage*2 + rdamage*3 + (wdamage*3 + edamage*2 + rdamage*2)*(DFGREADY and 1.2 or 1) + onhitdmg + onspelldamage*4 --0 cd
				local combo2 = hitdamage*2 + onhitdmg
				local combo3 = hitdamage + onhitdmg
				local combo4 = hitdamage + onhitdmg

				if WREADY then
					combo2 = combo2 + wdamage*(2+3*(DFGREADY and 1.2 or 1))
					combo3 = combo3 + wdamage*(2+2*(DFGREADY and 1.2 or 1))
					combo4 = combo4 + wdamage*(2+1*(DFGREADY and 1.2 or 1))
					onspelldamage2 = onspelldamage2+1.5
				end
				if EREADY then
					combo2 = combo2 + edamage*2*(DFGREADY and 1.2 or 1)
					combo3 = combo3 + edamage*(DFGREADY and 1.2 or 1)
					combo4 = combo4 + edamage*(DFGREADY and 1.2 or 1)
					onspelldamage2 = onspelldamage2+1
				end
				if RREADY then
					combo2 = combo2 + rdamage*(3+2*(DFGREADY and 1.2 or 1))
					combo3 = combo3 + rdamage*(1+2*(DFGREADY and 1.2 or 1))
					onspelldamage2 = onspelldamage2+1.5
				end
				if DFGREADY then		
					combo1 = combo1 + dfgdamage		
					combo2 = combo2 + dfgdamage
					combo3 = combo3 + dfgdamage
					combo4 = combo4 + dfgdamage
				end
				if HXGREADY then               
					combo1 = combo1 + hxgdamage*(DFGREADY and 1.2 or 1)
					combo2 = combo2 + hxgdamage*(DFGREADY and 1.2 or 1)
					combo3 = combo3 + hxgdamage*(DFGREADY and 1.2 or 1)
					combo4 = combo4 + hxgdamage
				end
				if BWCREADY then
					combo1 = combo1 + bwcdamage*(DFGREADY and 1.2 or 1)
					combo2 = combo2 + bwcdamage*(DFGREADY and 1.2 or 1)
					combo3 = combo3 + bwcdamage*(DFGREADY and 1.2 or 1)
					combo4 = combo4 + bwcdamage
				end
				if BRKREADY then
					combo1 = combo1 + brkdamage
					combo2 = combo2 + brkdamage
					combo3 = combo3 + brkdamage
					combo4 = combo4 + brkdamage
				end
				if IREADY then
					combo1 = combo1 + ignitedamage	
					combo2 = combo2 + ignitedamage
					combo3 = combo3 + ignitedamage
				end
				combo2 = combo2 + onspelldamage*onspelldamage2
				combo3 = combo3 + onspelldamage/2 + onspelldamage*onspelldamage2/2
				combo4 = combo4 + onspelldamage
				if combo4 >= enemy.health then killable[calculationenemy] = 4
				elseif combo3 >= enemy.health then killable[calculationenemy] = 3
				elseif combo2 >= enemy.health then killable[calculationenemy] = 2
				elseif combo1 >= enemy.health then killable[calculationenemy] = 1
				else killable[calculationenemy] = 0 end   
			end
			if calculationenemy == 1 then calculationenemy = heroManager.iCount
			else calculationenemy = calculationenemy-1 end
		end
		function OnDraw()
			if FCConfig.drawcircles and not myHero.dead then
				if QREADY then DrawCircle(myHero.x, myHero.y, myHero.z, qrange, 0x19A712)
				else DrawCircle(myHero.x, myHero.y, myHero.z, qrange, 0x992D3D) end
				if WREADY then DrawCircle(myHero.x, myHero.y, myHero.z, wrange, 0x19A712)
				else DrawCircle(myHero.x, myHero.y, myHero.z, wrange, 0x992D3D) end
				if EREADY then DrawCircle(myHero.x, myHero.y, myHero.z, erange, 0x19A712)
				else DrawCircle(myHero.x, myHero.y, myHero.z, erange, 0x992D3D) end
				if ts.target ~= nil then
					for j=0, 10 do
						DrawCircle(ts.target.x, ts.target.y, ts.target.z, 40 + j*1.5, 0x00FF00)
					end
				end
			end
			for i=1, heroManager.iCount do
				local enemydraw = heroManager:GetHero(i)
				if ValidTarget(enemydraw) then
					if FCConfig.drawcircles then
						if killable[i] == 1 then
							for j=0, 20 do
								DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 80 + j*1.5, 0x0000FF)
							end
						elseif killable[i] == 2 then
							for j=0, 10 do
								DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 80 + j*1.5, 0xFF0000)
							end
						elseif killable[i] == 3 then
							for j=0, 10 do
								DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 80 + j*1.5, 0xFF0000)
								DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 110 + j*1.5, 0xFF0000)
							end
						elseif killable[i] == 4 then
							for j=0, 10 do
								DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 80 + j*1.5, 0xFF0000)
								DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 110 + j*1.5, 0xFF0000)
								DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 140 + j*1.5, 0xFF0000)
							end
						end
					end
					if FCConfig.drawtext and waittxt[i] == 1 and killable[i] ~= 0 then
						PrintFloatText(enemydraw,0,floattext[killable[i]])
					end
				end
				if waittxt[i] == 1 then waittxt[i] = 30
				else waittxt[i] = waittxt[i]-1 end
			end
		end
		function OnSendChat(msg)
			ts:OnSendChat(msg, "pri")
		end
--------------------------------------------------------------------
	elseif myHero.charName == "Fizz" then
		--[[
				Fizz: Something's Fishy!
				by: Tux
				Made with Simple Minion Marker by Kilua
				Credits to Sida for helping with DamageCalc, as I was starting to get angry.
		--]]
		 
		local ts = TargetSelector(TARGET_LESS_CAST,700,DAMAGE_MAGIC,false)
		local rDelay = 242
		local rSpeed = 1.38
		local nextTick = 0
		local waitDelay = 400
		local DmgCalcItems =
		{
		Sheen = { id = 3057, slot = nil },
		Iceborn = { id = 3025, slot = nil },
		Liandrys = { id = 3151, slot = nil },
		LichBane = { id = 3100, slot = nil },
		Blackfire = { id = 3188, slot = nil }
		}
		local Items =
		{
		DFG = {id=3128, range = 750, reqTarget = true, slot = nil }
		}
		 
		function OnLoad()
				FizzConfig = scriptConfig("Something's Fishy", "FizzCombo")
				FizzConfig:addParam("Smart", "Smart Combo", SCRIPT_PARAM_ONKEYDOWN, false, 84)
				FizzConfig:addParam("Active", "Full Combo", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Y"))
				FizzConfig:addParam("Harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("G"))
				FizzConfig:addParam("MLH", "Minion Last Hit", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("A"))
				FizzConfig:addParam("KS", "Auto KS", SCRIPT_PARAM_ONOFF, true)
				FizzConfig:addParam("Ignite", "Ignite Killable Target", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte("Z"))
				FizzConfig:addParam("Marker", "Minion Marker", SCRIPT_PARAM_ONOFF, true)
				FizzConfig:addParam("UseE", "Use E in Combo", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte("C"))
				FizzConfig:addParam("DoubleIgnite", "Don't Double Ignite", SCRIPT_PARAM_ONOFF, true)
				FizzConfig:addParam("KillText", "Print Text on Target", SCRIPT_PARAM_ONOFF, true)
				FizzConfig:addParam("Movement", "Move to Mouse", SCRIPT_PARAM_ONOFF, true)
				FizzConfig:addParam("DrawCircles", "Draw Circles", SCRIPT_PARAM_ONOFF, true)
				FizzConfig:addParam("Ultimate", "Melee Range Ultimate", SCRIPT_PARAM_ONOFF, false)
				FizzConfig:permaShow("Active")
				FizzConfig:permaShow("Smart")
				FizzConfig:permaShow("Harass")
				FizzConfig:permaShow("UseE")
				FizzConfig:permaShow("Ultimate")
				FizzConfig:permaShow("Marker")
				FizzConfig:permaShow("Ignite")
				ts.name = "Fizz"
				FizzConfig:addTS(ts)
				PrintChat(">> Fizz - Something's Fishy! v1.4 loaded!")
				MinionMarkerOnLoad()
				if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then ign = SUMMONER_1
				elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then ign = SUMMONER_2
						else ign = nil
				end
		end
		 
		function OnCreateObj(obj)
				if FizzConfig.Marker then
						MinionMarkerOnCreateObj(obj)
				end
		end
		 
		function CanCast(Spell)
			return (player:CanUseSpell(Spell) == READY)
		end
		 
		function IReady()
				return (player:CanUseSpell(ign) == READY)
		end
		 
		function AutoIgnite()
				local iDmg = 0         
				if ign ~= nil and IReady and not myHero.dead then
						for i = 1, heroManager.iCount, 1 do
								local target = heroManager:getHero(i)
								if ValidTarget(target) then
										iDmg = 50 + 20 * myHero.level
										if target ~= nil and target.team ~= myHero.team and not target.dead and target.visible and GetDistance(target) < 600 and target.health < iDmg then
												if FizzConfig.DoubleIgnite and not TargetHaveBuff("SummonerDot", target) then
														CastSpell(ign, target)
														elseif not FizzConfig.DoubleIgnite then
																CastSpell(ign, target)
												end
										end
								end
						end
				end
		end
		 
		function getHitBoxRadius(target)
		 return GetDistance(target.minBBox, target.maxBBox)/2
		end
		 
		function UseItems(target)
				if target == nil then return end
						for _,item in pairs(Items) do
								item.slot = GetInventorySlotItem(item.id)
						if item.slot ~= nil then
								if item.reqTarget and GetDistance(target) < item.range then
										CastSpell(item.slot, target)
								elseif not item.reqTarget then
										if (GetDistance(target) - getHitBoxRadius(myHero) - getHitBoxRadius(target)) < 50 then
												CastSpell(item.slot)
										end
								end
						end
				end
		end
		 
		function AutoKS()
			for i=1, heroManager.iCount do
			target = heroManager:GetHero(i)
				wDmg = getDmg("W", target, player)
				qDmg = getDmg("Q", target, player)
						if target ~= nil and not target.dead and target.team ~= player.team and target.visible and GetDistance(target) < 550 then
								if target.health < wDmg + qDmg and CanCast(_W) and CanCast(_Q) then
										CastSpell(_W, target)
										CastSpell(_Q, target)
								end
						end
						if target ~= nil and not target.dead and target.team ~= player.team and target.visible and GetDistance(target) < 550 then
								if target.health < qDmg and CanCast(_Q) then
										CastSpell(_Q, target)
								end
						end
				end
		end
		 
		function OnTick()
				ts:update()
				if ts.target ~= nil then
						travelDuration = (rDelay + GetDistance(myHero, ts.target)/rSpeed)
				end
				local rPred = ts.nextPosition
				ts:SetPrediction(travelDuration)
				if FizzConfig.Ignite and AutoIgnite() then end
				if FizzConfig.KS and AutoKS() then end
				if FizzConfig.Active and ts.target ~= nil then
						if ValidTarget(ts.target, 550) and CanCast(_W) and CanCast(_Q) then
								UseItems(ts.target)
								CastSpell(_W, ts.target)
								CastSpell(_Q, ts.target)
								if ValidTarget(ts.target, 550) then
										myHero:Attack(ts.target)
								end
						end
				if FizzConfig.Ultimate and ValidTarget(ts.target, 725) and CanCast(_R) and rPred ~= nil then
						HeroPos = Vector(myHero.x,0,myHero.z)
						EnemyPos = Vector(ts.nextPosition.x,0, ts.nextPosition.z)                      
						LeadingPos = EnemyPos + ( EnemyPos - HeroPos ):normalized()*(-0.05)
						CastSpell(_R, LeadingPos.x,LeadingPos.z)
						if ValidTarget(ts.target, 550) then
										myHero:Attack(ts.target)
						end
				end
						if FizzConfig.UseE and ValidTarget(ts.target, 400) and CanCast(_E) then
								CastSpell(_E, ts.nextPosition.x, ts.nextPosition.z)
								if ValidTarget(ts.target, 550) then
										myHero:Attack(ts.target)
								end
						end
				end
				if FizzConfig.Smart and ts.target ~= nil then
						for i=1, heroManager.iCount do
								target = heroManager:GetHero(i)
								local qDmg = getDmg("Q", target, player)
								local wDmg = getDmg("W", target, player)
								local eDmg = getDmg("E", target, player)
								local rDmg = getDmg("R", target, player)
								local hitDmg = getDmg("AD",target, player)
								local enemyHealth = target.health
								local dfgDmg = (Items.DFG.slot and getDmg("DFG", target, player) or 0)
								local ignDmg = (ign and getDmg("IGNITE", target, player) or 0)
								local onhitDmg = (DmgCalcItems.Sheen.slot and getDmg("SHEEN", target, player) or 0)+(DmgCalcItems.LichBane.slot and getDmg("LICHBANE", target, player) or 0)+(DmgCalcItems.Iceborn.slot and getDmg("ICEBORN", target, player) or 0)
								local onspellDmg = (DmgCalcItems.Liandrys.slot and getDmg("LIANDRYS", target, player) or 0)+(DmgCalcItems.Blackfire.slot and getDmg("BLACKFIRE", target, player) or 0)
								if ValidTarget(ts.target, 550) and CanCast(_W) and CanCast(_Q) then
										if enemyHealth < wDmg + qDmg + (hitDmg*1) then
												CastSpell(_W, ts.target)
												CastSpell(_Q, ts.target)
												if ValidTarget(ts.target, 550) then
														myHero:Attack(ts.target)
												end
										elseif enemyHealth < wDmg + qDmg + dfgDmg + onhitDmg + onspellDmg + (hitDmg*1) then
												UseItems(ts.target)
												CastSpell(_W, ts.target)
												CastSpell(_Q, ts.target)
												if ValidTarget(ts.target, 550) then
														myHero:Attack(ts.target)
												end
										elseif enemyHealth < wDmg + qDmg + dfgDmg + onhitDmg + onspellDmg + ignDmg + (hitDmg*1) then
												UseItems(ts.target)
												CastSpell(_W, ts.target)
												CastSpell(_Q, ts.target)
												if ValidTarget(ts.target, 550) then
														myHero:Attack(ts.target)
												end
										end
								elseif FizzConfig.Ultimate and ValidTarget(ts.target, 175) and CanCast(_R) and rPred ~= nil then
										if enemyHealth < rDmg then
												HeroPos = Vector(myHero.x,0,myHero.z)
												EnemyPos = Vector(ts.nextPosition.x,0, ts.nextPosition.z)                      
												LeadingPos = EnemyPos + ( EnemyPos - HeroPos ):normalized()*(-0.05)
												CastSpell(_R, LeadingPos.x,LeadingPos.z)
												if ValidTarget(ts.target, 550) then
														myHero:Attack(ts.target)
												end
										elseif enemyHealth < rDmg + dfgDmg + onhitDmg + onspellDmg + (hitDmg*1) then
												UseItems(ts.target)
												HeroPos = Vector(myHero.x,0,myHero.z)
												EnemyPos = Vector(ts.nextPosition.x,0, ts.nextPosition.z)                      
												LeadingPos = EnemyPos + ( EnemyPos - HeroPos ):normalized()*(-0.05)
												CastSpell(_R, LeadingPos.x,LeadingPos.z)
												if ValidTarget(ts.target, 550) then
														myHero:Attack(ts.target)
												end
										elseif enemyHealth < rDmg + dfgDmg + onhitDmg + onspellDmg + ignDmg + (hitDmg*1) then
												UseItems(ts.target)
												HeroPos = Vector(myHero.x,0,myHero.z)
												EnemyPos = Vector(ts.nextPosition.x,0, ts.nextPosition.z)                      
												LeadingPos = EnemyPos + ( EnemyPos - HeroPos ):normalized()*(-0.05)
												CastSpell(_R, LeadingPos.x,LeadingPos.z)
												if ValidTarget(ts.target, 550) then
														myHero:Attack(ts.target)
												end
										end
								elseif FizzConfig.UseE and ValidTarget(ts.target, 400) and CanCast(_E) then
										if enemyHealth < eDmg + (hitDmg*1) then
												CastSpell(_E, ts.nextPosition.x, ts.nextPosition.z)
												if ValidTarget(ts.target, 550) then
														myHero:Attack(ts.target)
												end
										elseif enemyHealth < eDmg + dfgDmg + onhitDmg + onspellDmg + (hitDmg*1) then
												UseItems(ts.target)
												CastSpell(_E, ts.nextPosition.x, ts.nextPosition.z)
												if ValidTarget(ts.target, 550) then
														myHero:Attack(ts.target)
												end
										elseif enemyHealth < eDmg + dfgDmg + onhitDmg + onspellDmg + ignDmg + (hitDmg*1) then
												UseItems(ts.target)
												CastSpell(_E, ts.nextPosition.x, ts.nextPosition.z)
												if ValidTarget(ts.target, 550) then
														myHero:Attack(ts.target)
												end
										end
								elseif ValidTarget(ts.target, 550) and CanCast(_W) and CanCast(_Q) then
										if enemyHealth < wDmg + qDmg + eDmg + (hitDmg*1) then
												CastSpell(_W, ts.target)
												CastSpell(_Q, ts.target)
												if FizzConfig.UseE and ValidTarget(ts.target, 400) and CanCast(_E) then
														CastSpell(_E)
														if ValidTarget(ts.target, 550) then
																myHero:Attack(ts.target)
														end
												end
										elseif enemyHealth < wDmg + qDmg + eDmg + dfgDmg + onhitDmg + onspellDmg + (hitDmg*1) then
												UseItems(ts.target)
												CastSpell(_W, ts.target)
												CastSpell(_Q, ts.target)
												if FizzConfig.UseE and ValidTarget(ts.target, 400) and CanCast(_E) then
														CastSpell(_E)
														if ValidTarget(ts.target, 550) then
																myHero:Attack(ts.target)
														end
												end
										elseif enemyHealth < wDmg + qDmg + eDmg + dfgDmg + onhitDmg + onspellDmg + ignDmg + (hitDmg*1) then
												UseItems(ts.target)
												CastSpell(_W, ts.target)
												CastSpell(_Q, ts.target)
												if FizzConfig.UseE and ValidTarget(ts.target, 400) and CanCast(_E) then
														CastSpell(_E)
														if ValidTarget(ts.target, 550) then
																myHero:Attack(ts.target)
														end
												end
										end
								elseif ValidTarget(ts.target, 550) and CanCast(_W) and CanCast(_Q) then
										if enemyHealth < wDmg + qDmg + eDmg + rDmg + (hitDmg*1) then
												CastSpell(_W, ts.target)
												CastSpell(_Q, ts.target)
												if FizzConfig.Ultimate and ValidTarget(ts.target, 175) and CanCast(_R) and rPred ~= nil then
														HeroPos = Vector(myHero.x,0,myHero.z)
														EnemyPos = Vector(ts.nextPosition.x,0, ts.nextPosition.z)                      
														LeadingPos = EnemyPos + ( EnemyPos - HeroPos ):normalized()*(-0.05)
														CastSpell(_R, LeadingPos.x,LeadingPos.z)
														if FizzConfig.UseE and ValidTarget(ts.target, 400) and CanCast(_E) then
																CastSpell(_E, ts.nextPosition.x, ts.nextPosition.z)
																if ValidTarget(ts.target, 550) then
																		myHero:Attack(ts.target)
																end
														end
												end
										elseif enemyHealth < wDmg + qDmg + eDmg + rDmg + dfgDmg + onhitDmg + onspellDmg + (hitDmg*1) then
												UseItems(ts.target)
												CastSpell(_W, ts.target)
												CastSpell(_Q, ts.target)
												if FizzConfig.Ultimate and ValidTarget(ts.target, 175) and CanCast(_R) and rPred ~= nil then
														HeroPos = Vector(myHero.x,0,myHero.z)
														EnemyPos = Vector(ts.nextPosition.x, 0, ts.nextPosition.z)                      
														LeadingPos = EnemyPos + ( EnemyPos - HeroPos ):normalized()*(-0.05)
														CastSpell(_R, LeadingPos.x,LeadingPos.z)
														if FizzConfig.UseE and ValidTarget(ts.target, 400) and CanCast(_E) then
																CastSpell(_E, ts.nextPosition.x, ts.nextPosition.z)
																if ValidTarget(ts.target, 550) then
																		myHero:Attack(ts.target)
																end
														end
												end
										elseif enemyHealth < wDmg + qDmg + eDmg + rDmg + dfgDmg + onhitDmg + onspellDmg + ignDmg + (hitDmg*1) then
												UseItems(ts.target)
												CastSpell(_W, ts.target)
												CastSpell(_Q, ts.target)
												if FizzConfig.Ultimate and ValidTarget(ts.target, 175) and CanCast(_R) and rPred ~= nil then
														HeroPos = Vector(myHero.x, 0, myHero.z)
														EnemyPos = Vector(ts.nextPosition.x,0, ts.nextPosition.z)                      
														LeadingPos = EnemyPos + ( EnemyPos - HeroPos ):normalized()*(-0.05)
														CastSpell(_R, LeadingPos.x,LeadingPos.z)
														if FizzConfig.UseE and ValidTarget(ts.target, 400) and CanCast(_E) then
																CastSpell(_E, ts.nextPosition.x, ts.nextPosition.z)
																if ValidTarget(ts.target, 550) then
																		myHero:Attack(ts.target)
																end
														end
												end
										end
								end
						end
				end
				if FizzConfig.Harass then
						if ValidTarget(ts.target, 550) and CanCast(_W) and CanCast(_Q) then
								CastSpell(_W, ts.target)
								CastSpell(_Q, ts.target)
								myHero:Attack(ts.target)
						end
				end
				if FizzConfig.MLH then
						if GetTickCount() > nextTick then
								myHero:MoveTo(mousePos.x, mousePos.z)
								for i,minionObject in ipairs(minionTable) do
										if minionObject.valid and (minionObject.dead == true or minionObject.team == myHero.team) then
												table.remove(minionTable, i)
												i = i - 1
										elseif minionObject.valid and minionObject ~= nil and myHero:GetDistance(minionObject) ~= nil and myHero:GetDistance(minionObject) < 1500 and minionObject.health ~= nil and minionObject.health <= myHero:CalcDamage(minionObject, myHero.addDamage+myHero.damage) and minionObject.visible ~= nil and minionObject.visible == true then
												myHero:Attack(minionObject)
												nextTick = GetTickCount() + waitDelay
										end
								end
						end
				end
				if FizzConfig.Movement and (FizzConfig.Active or FizzConfig.Harass or FizzConfig.Smart) and ts.target == nil then myHero:MoveTo(mousePos.x, mousePos.z)
			end
		end
		 
		function FizzDamageCalc(enemy)
				for i=1, heroManager.iCount do
						local enemy = heroManager:GetHero(i)
						if ValidTarget(enemy) then
								local dfgDmg, ignDmg, SheenDmg, LichBaneDmg  = 0, 0, 0, 0
								local qDmg = getDmg("Q", enemy, myHero)
								local wDmg = getDmg("W", enemy, myHero)
								local eDmg = getDmg("E", enemy, myHero)
								local rDmg = getDmg("R", enemy, myHero)
								local hitDmg = getDmg("AD",enemy,myHero)
								local dfgDmg = (Items.DFG.slot and getDmg("DFG", target, player) or 0)
								local ignDmg = (ign and getDmg("IGNITE", target, player) or 0)
								local onhitDmg = (DmgCalcItems.Sheen.slot and getDmg("SHEEN", target, player) or 0)+(DmgCalcItems.LichBane.slot and getDmg("LICHBANE", target, player) or 0)+(DmgCalcItems.Iceborn.slot and getDmg("ICEBORN", target, player) or 0)
								local onspellDmg = (DmgCalcItems.Liandrys.slot and getDmg("LIANDRYS", target, player) or 0)+(DmgCalcItems.Blackfire.slot and getDmg("BLACKFIRE", target, player) or 0)
								local myDamage = 0
								local maxDamage = qDmg + wDmg + eDmg + rDmg + onspellDmg + onhitDmg + dfgDmg + ignDmg
								if CanCast(_Q) then myDamage = myDamage + qDmg end
								if CanCast(_W) then myDamage = myDamage + wDmg end
								if CanCast(_E) then myDamage = myDamage + eDmg end
								if CanCast(_R) then myDamage = myDamage + rDmg end
								if Items.DFG.slot ~= nil then myDamage = myDamage + dfgDmg end
								if IReady() and FizzConfig.Ignite then myDamage = myDamage + ignDmg end
										myDamage = myDamage + onspellDmg
										myDamage = myDamage + onhitDmg
										myDamage = myDamage + hitDmg
								if ts.target.health <= myDamage then
										PrintFloatText(ts.target, 0, "Murder")
								elseif ts.target.health <= maxDamage then
										PrintFloatText(ts.target, 0, "Wait for cooldowns")
								else
										PrintFloatText(ts.target, 0, "You are not strong enough")
								end
						end
				end
		end
		 
		function OnDraw()
				if FizzConfig.DrawCircles and not myHero.dead then
						DrawCircle(myHero.x,myHero.y,myHero.z,550,0xFFFF0000)
						DrawCircle(myHero.x,myHero.y,myHero.z,550,0xFFFF0000)
				end
				if FizzConfig.Marker then
						MinionMarkerOnDraw()
				end
				if ts.target ~= nil then
						FizzDamageCalc(ts.target)
				for j=0, 15 do
					DrawCircle(ts.target.x, ts.target.y, ts.target.z, 40 + j*1.5, 0x00FF00)
				end
			end
		end
		 
		--[[
				Simple Minion Marker
				by: Kilua
		--]]
		 
		function MinionMarkerOnLoad()
				minionTable = {}
				for i = 0, objManager.maxObjects do
						local obj = objManager:GetObject(i)
						if obj ~= nil and obj.type ~= nil and obj.type == "obj_AI_Minion" then
								table.insert(minionTable, obj)
						end
				end
		end
		 
		function MinionMarkerOnDraw()
				for i,minionObject in ipairs(minionTable) do
						if minionObject.valid and (minionObject.dead == true or minionObject.team == myHero.team) then
								table.remove(minionTable, i)
								i = i - 1
						elseif minionObject.valid and minionObject ~= nil and myHero:GetDistance(minionObject) ~= nil and myHero:GetDistance(minionObject) < 1500 and minionObject.health ~= nil and minionObject.health <= myHero:CalcDamage(minionObject, myHero.addDamage+myHero.damage) and minionObject.visible ~= nil and minionObject.visible == true then
								for g = 0, 6 do
										DrawCircle(minionObject.x, minionObject.y, minionObject.z,80 + g,255255255)
								end
				end
			end
		end
		 
		function MinionMarkerOnCreateObj(object)
				if object ~= nil and object.type ~= nil and object.type == "obj_AI_Minion" then table.insert(minionTable, object) end
		end
-------------------------------------------------------------------------------------------
	elseif myHero.charName == "Jax" then
		--[[Jax KillTime - The Real Weapon 1.3 By mr1r15h]]--
		 
		--Killable--
		local waittxt = {}
		local calculationenemy = 1
		local floattext = {"Full Combo","Combo","Quick Combo","KillTime!","Harass"}
		local killable = {}
		--Spells--
		local QReady, WReady, EReady, RReady = false, false, false, false
		 
		function OnLoad()
				--Range Values--
				QRange = 700
				ERange = 185
				ARange = 125
				--Spell Values--
				WProc, EProc, QLanded = false, false, false
				AACount, lastAA, qTimer, timer, eStart, eTimer, eWait, timeout = 0, 0, 0, 0, 0, 0, 0, 0, 0
				--Item Wait--
				itemStart, itemEnd = 0, 0
				itemWait = false
				--Health Check--
				hStart, hEnd, hCheck1, hCheck2 = 0, 0, 0, 0
				hWait = false
				rActivate = false
				--JaxConfig--
				JaxConfig = scriptConfig("JaxKillTime", "Jax Kill Time")
				JaxConfig:addParam("AutoKS", "Auto KS", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte("K"))
				JaxConfig:addParam("AutoW", "Auto W", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte("Z"))
				JaxConfig:addParam("IntelCombo", "Intelligent Combo Mode", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte("X"))
				JaxConfig:addParam("BurstCombo", "Burst Combo Mode", SCRIPT_PARAM_ONOFF, false)
				JaxConfig:addParam("EQCombo", "E >> Q", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte("C"))
				JaxConfig:addParam("QECombo", "Q >> E", SCRIPT_PARAM_ONOFF, false)
				JaxConfig:addParam("JaxCombo", "Jax Combo", SCRIPT_PARAM_ONKEYDOWN, false, 84)
				JaxConfig:addParam("AutoIgnite", "Auto Ignite", SCRIPT_PARAM_ONOFF, true)
				JaxConfig:addParam("AutoUlt", "Use Ult in Combo", SCRIPT_PARAM_ONOFF, true)
				JaxConfig:addParam("minChamps", "Min. Champ for Auto Ulti", SCRIPT_PARAM_SLICE, 1, 0, 4, 0)
				JaxConfig:addParam("ultSen", "Auto Ulti Sensitivity", SCRIPT_PARAM_SLICE, 2, 0, 4, 0)
				JaxConfig:addParam("moveMouse", "Move To Mouse", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte("C"))
				JaxConfig:addParam("qeJump", "Q+E Jump", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("A"))
				JaxConfig:addParam("drawcircles", "Draw Circles", SCRIPT_PARAM_ONOFF, true)
				JaxConfig:addParam("drawtext", "Draw Text", SCRIPT_PARAM_ONOFF, true)
				JaxConfig:permaShow("AutoKS")
				JaxConfig:permaShow("AutoW")
				JaxConfig:permaShow("JaxCombo")
				JaxConfig:permaShow("qeJump")
				JaxConfig:permaShow("IntelCombo")
				JaxConfig:permaShow("BurstCombo")
				JaxConfig:permaShow("EQCombo")
				JaxConfig:permaShow("QECombo")
				--Target Selector--
				ts = TargetSelector(TARGET_LOW_HP, QRange, DAMAGE_PHYSICAL, true)
				ts.name = "Jax"
				JaxConfig:addTS(ts)
				--Ignite--
				if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then
						ignite = SUMMONER_1
				elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then
						ignite = SUMMONER_2
				end
				for i=1, heroManager.iCount do
						waittxt[i] = i*3
				end
				PrintChat(" >> Jax KillTime - The Real Weapon 1.3 loaded!")
		end
		 
		function OnProcessSpell(unit, spell)
				if unit.isMe and spell.name ~= nil and not string.find(spell.name, "JaxBasicAttack" or "JaxBasicAttack2" or "jaxrelentlessattack"  or "CritAttack") then --check if not AA
						WProc = false
						elseif WProc == false and unit.isMe and spell.name ~= nil and string.find(spell.name, "JaxBasicAttack" or "JaxBasicAttack2" or "jaxrelentlessattack"  or "CritAttack") then --check if AA
						for i=1, heroManager.iCount do
								local enemy = heroManager:GetHero(i)
								if enemy ~= nil and enemy.visible and enemy.team ~= player.team and not enemy.dead and math.sqrt((enemy.x - spell.endPos.x)^2 + (enemy.z - spell.endPos.z)^2) < 1 then --checks if hit enemy champion
												setAW()
								end
						end
				end
				if unit.isMe and spell.name ~= nil and string.find(spell.name, "JaxCounterStrike") and not JaxConfig.JaxCombo then
						setE()
				end
		end
		 
		function OnTick()
				if JaxConfig.IntelCombo then
						JaxConfig.BurstCombo = false
				elseif JaxConfig.IntelCombo == false then
						JaxConfig.BurstCombo = true
				end
				if JaxConfig.EQCombo then
						JaxConfig.QECombo = false
				elseif JaxConfig.EQCombo == false then
						JaxConfig.QECombo = true
				end
				--if myHero.dead then return end
				--Target Selector Update--
				ts:update()
				--PrintChat(tostring(ts.target.charName))
				--Spells Ready--
				QReady = (myHero:CanUseSpell(_Q) == READY)
				WReady = (myHero:CanUseSpell(_W) == READY)
				EReady = (myHero:CanUseSpell(_E) == READY)
				RReady = (myHero:CanUseSpell(_R) == READY)
				--Items--
				BRKSlot, HXGSlot, BWCSlot = GetInventorySlotItem(3153), GetInventorySlotItem(3146), GetInventorySlotItem(3144)
				SheenSlot, TrinitySlot, LichBaneSlot = GetInventoryHaveItem(3057), GetInventoryHaveItem(3078), GetInventoryHaveItem(3100)
				TMatSlot, RHydraSlot, RANDSlot = GetInventorySlotItem(3077), GetInventorySlotItem(3074), GetInventorySlotItem(3143)
				HXGReady = (HXGSlot ~= nil and myHero:CanUseSpell(HXGSlot) == READY)
				BWCReady = (BWCSlot ~= nil and myHero:CanUseSpell(BWCSlot) == READY)
				BRKReady = (BRKSlot ~= nil and myHero:CanUseSpell(BRKSlot) == READY)
				RANDReady =(RANDSlot ~= nil and myHero:CanUseSpell(RANDSlot) == READY)
				TMatReady = (TMatSlot ~= nil and myHero:CanUseSpell(TMatSlot) == READY)
				RHydraReady = (RHydraSlot ~= nil and myHero:CanUseSpell(RHydraSlot) == READY)
				--Ignite--
				IReady = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
				--Functions--
				setHealth()
				calcDamage()
				killSteal()
				checkHealth()
				jaxCombo()
				autoEmpower()
				resetHealth()
				jump()
		end
		 
		function jump()
				if JaxConfig.qeJump then
						if JaxConfig.moveMouse and ts.target == nil then
								myHero:MoveTo(mousePos.x, mousePos.z)
						end
						if ts.target ~= nil then
								if QReady and GetDistance(ts.target) < QRange and GetDistance(ts.target) > ERange + 50 then
										CastSpell(_Q, ts.target)
										CastSpell(_E)
								end
								myHero:Attack(ts.target)
						end
				end
		end
		 
		function setAW()
				AACount = 1/(((0.625/(1-0.02)))*(1*myHero.attackSpeed)) --Auto Attacks per second
				lastAA = os.clock()
				timer = lastAA + (AACount/5.5)
				timeout = lastAA + AACount
				WProc, ItemProc = true, true
		end
		 
		function resetAW()
				lastAA, timer, timout = 0, 0, 0
				WProc, ItemProc = false, false
		end
		 
		function setE()
				eStart = os.clock()
				eTimer = eStart + 2
				eWait = eStart + 1
				CastSpell(_E)
				EProc = true
		end
		 
		function resetQE()
				qTimer, eStart, eTimer, EProc = 0, 0, 0, 0
				QLanded, EProc = false, false
		end
		 
		function setItem()
				itemStart = os.clock()
				itemEnd = itemStart + 1
				itemWait = true
		end
		 
		function resetItem()
				itemStart, itemEnd = 0, 0
				itemWait = false
		end
		 
		function setHealth()
				if hWait == false and RReady then
						hStart = os.clock()
						hEnd = hStart + 1
						hWait = true
						hCheck1 = myHero.health
				end
		end
		 
		function checkHealth()
				if hWait == true and os.clock() > hEnd then
						hCheck2 = myHero.health
						local sen = (JaxConfig.ultSen + 1)*0.05
						if (hCheck1 - (hCheck1*sen)) >= hCheck2 then
								rActivate = true
						end
				end
		end
		 
		function resetHealth()
				if hWait == true and os.clock() > hEnd then
						hStart, hEnd, hCheck1, hCheck2 = 0, 0, 0, 0
						hWait, rActivate = false, false
				elseif RReady == false then
						hStart, hEnd, hCheck1, hCheck2 = 0, 0, 0, 0
						hWait, rActivate = false, false
				end
		end
		 
		function autoEmpower()
				if JaxConfig.AutoW and WProc == true then
						if os.clock() < timeout then
								if os.clock() > timer then --checks to ensure efficiency of AA reset
										CastSpell(_W)
										resetAW()
								end
						elseif WProc == true and timeout <= os.clock() then
								resetAW()
						end
				end
		end
		 
		function killSteal()
				if JaxConfig.AutoKS then
						for i = 1, heroManager.iCount do
								local enemy = heroManager:getHero(i)
								local qKS = getDmg("Q", enemy, myHero)
								local wKS = getDmg("W", enemy, myHero)
								local aKS = getDmg("AD", enemy, myHero)
								local iKS = 50 + (20*myHero.level)
								if ValidTarget(enemy, ARange) and aKS > enemy.health then
										myHero:Attack(enemy)
								end
								if WReady then
										if ValidTarget(enemy, ARange) and (wKS + aKS) > enemy.health then
												CastSpell(_W)
												myHero:Attack(enemy)
										end
								end
								if QReady then
										if ValidTarget(enemy, QRange) and qKS > enemy.health then
												CastSpell(_Q, enemy)
										end
								end
								if QReady and WReady then
										if ValidTarget(enemy, QRange) and (qKS + wKS) > enemy.health then
												CastSpell(_W)
												CastSpell(_Q, enemy)
										end
								end
								if WReady and IReady and JaxConfig.AutoIgnite then
										if ValidTarget(enemy, ARange) and (wKS + aKS + iKS) > enemy.health then
												CastSpell(_W)
												myHero:Attack(enemy)
										end
								end
								if QReady and IReady and JaxConfig.AutoIgnite then
										if ValidTarget(enemy, QRange) and (qKS + iKS) > enemy.health then
												CastSpell(_Q, enemy)
										end
								end
								if QReady and WReady and IReady and JaxConfig.AutoIgnite then
										if ValidTarget(enemy, QRange) and (qKS + wKS + iKS) > enemy.health then
												CastSpell(_W)
												CastSpell(_Q, enemy)
										end
								end
								if IReady and JaxConfig.AutoIgnite and QReady == false and itemWait == false then
										if GetDistance(enemy) > (ERange*1.6) and GetDistance(enemy) < 600 and qTimer < os.clock() then
												if BRKReady == false and HXGReady == false and BWCReady == false and RANDReady == false then
														if ValidTarget(enemy, 600) and iKS > enemy.health then
																CastSpell(ignite, enemy)
														end
												end
										end
										if myHero.health < 250 and ValidTarget(enemy, 600) and iKS > enemy.health then
												CastSpell(ignite, enemy)
										end
								end
						end
				end
		end
		 
		function jaxCombo()
				if JaxConfig.JaxCombo then
						if JaxConfig.moveMouse and ts.target == nil then
								myHero:MoveTo(mousePos.x, mousePos.z)
						end
						if ts.target ~= nil then
								if eTimer ~= 0 and eTimer < os.clock() then
										resetQE()
								end
								if JaxConfig.AutoUlt and RReady then
										if rActivate == true then
												CastSpell(_R)
										else
												local champCount = 0
												for i = 1, heroManager.iCount do
														local enemy = heroManager:getHero(i)
														if ValidTarget(enemy, QRange) then
																champCount = champCount + 1
														end
												end
												if champCount >= (JaxConfig.minChamps + 1) then
														CastSpell(_R)
												end
										end
								end
								if JaxConfig.EQCombo then
										if EProc == true then
												if GetDistance(ts.target) < ERange then
														if ERange == GetDistance(ts.target) and eTimer > os.clock() and eWait < os.clock() then
																CastSpell(_E)
																resetQE()
														end
												end
												if QLanded == false and QReady and GetDistance(ts.target) < QRange and GetDistance(ts.target) > ERange then
														if eTimer > (os.clock() + 0.4) then
														elseif eWait > os.clock() then
														elseif eWait < os.clock() then
																CastSpell(_Q, ts.target)
																qTimer = os.clock() + 0.3
																QLanded = true
														end
												end
												if QLanded == true and qTimer < os.clock() and os.clock() < eTimer then
														CastSpell(_E)
														resetQE()                              
												end
										end
										if EProc == false then
												if EReady and GetDistance(ts.target) < ERange then
														setE()                
												elseif EReady and QReady and GetDistance(ts.target) < (QRange - (ts.target.ms - myHero.ms)) and GetDistance(ts.target) > ERange then
														setE()
												elseif QReady and EReady == false and GetDistance(ts.target) < QRange and GetDistance(ts.target) > (ERange * 2) then
														CastSpell(_Q, ts.target)
														qTimer = os.clock() + 0.3
												end
										end
								elseif JaxConfig.QECombo then
										if QReady and GetDistance(ts.target) < QRange and GetDistance(ts.target) > ERange + 50 then
												CastSpell(_Q, ts.target)
										end
										if EReady and EProc == false and GetDistance(ts.target) < ERange then
												setE()
										end
										if EProc == true and eWait < os.clock() and eTimer > os.clock() and GetDistance(ts.target) < ERange then
												CastSpell(_E)
												resetQE()
										end
								end
								if GetDistance(ts.target) < QRange then
										myHero:Attack(ts.target)
								end
						end
						if JaxConfig.BurstCombo and ts.target ~= nil then
								if JaxConfig.AutoIgnite and IReady and GetDistance(ts.target) < 600 then
										CastSpell(ignite, ts.target)
								end
								if BRKReady and GetDistance(ts.target) < 500 then
										CastSpell(BRKSlot, ts.target)
								end
								if GetDistance(ts.target) < ARange and ItemProc == true then
										if RHydraReady and ItemProc == true then
												if os.clock() < timeout then
														if os.clock() > timer then --checks to ensure efficiency of AA reset
																CastSpell(RHydraSlot, ts.target)
																resetAW()
														end
												end
										end
										if TMatReady and ItemProc == true then
												if os.clock() < timeout then
														if os.clock() > timer then --checks to ensure efficiency of AA reset
																CastSpell(TMatSlot, ts.target)
																resetAW()
														end
												end
										end
								elseif ItemProc == true and timeout <= os.clock() then
										resetAW()
								end
								if HXGReady and GetDistance(ts.target) < QRange then
										CastSpell(HXGSlot, ts.target)
								end
								if BWCReady and GetDistance(ts.target) < 500 then
										CastSpell(BWCSlot, ts.target)
								end
								if RANDReady then
										if GetDistance(ts.target) < 500 and GetDistance(ts.target) > (ERange*1.6) and QReady == false then
												CastSpell(RANDSlot, ts.target)
										end
								end
						end
					   
						if JaxConfig.IntelCombo and ts.target ~= nil and itemWait == false then
								if ItemProc == true and EReady == false and not ts.target.dead then
										if RHydraReady and ItemProc == true then
												if os.clock() < timeout then
														if os.clock() > timer then --checks to ensure efficiency of AA reset
																CastSpell(RHydraSlot, ts.target)
																setItem()
																resetAW()
														end
												end
										end
										if TMatReady and ItemProc == true then
												if os.clock() < timeout then
														if os.clock() > timer then --checks to ensure efficiency of AA reset
																CastSpell(TMatSlot, ts.target)
																setItem()
																resetAW()
														end
												end
										end
								elseif ItemProc == true and timeout <= os.clock() then
										resetAW()
								end
								if BRKReady then
										if myHero.maxHealth > (myHero.health*2) and GetDistance(ts.target) < 500 then
												CastSpell(BRKSlot, ts.target)
												setItem()
										end
										if GetDistance(ts.target) < 500 and GetDistance(ts.target) > (ERange*1.6) and QReady == false and BWCReady == false and HXGReady == false and qTimer < os.clock() then
												CastSpell(BRKSlot, ts.target)
												setItem()
										end
								end
								if HXGReady then
										if GetDistance(ts.target) < QRange and GetDistance(ts.target) > (ERange*1.6) and QReady == false and qTimer < os.clock() then
												CastSpell(HXGSlot, ts.target)
												setItem()
										end
								end
								if BWCReady then
										if GetDistance(ts.target) < 500 and GetDistance(ts.target) > (ERange*1.6) and QReady == false and qTimer < os.clock() then
												CastSpell(BWCSlot, ts.target)
												setItem()
										end
								end
								if RANDReady then
										if GetDistance(ts.target) < 500 and GetDistance(ts.target) > (ERange*1.6) and QReady == false and qTimer < os.clock() then
												CastSpell(RANDSlot, ts.target)
												setItem()
										end
								end
						end
						if itemWait == true and os.clock() > itemEnd then
								resetItem()
						end
				end
		end
		 
		function calcDamage()
				if not myHero.dead then
						for i=1, heroManager.iCount do
								local enemy = heroManager:GetHero(i)
								if ValidTarget(enemy) then
										local qDamage = getDmg("Q", enemy, myHero)
										local wDamage = getDmg("W", enemy, myHero)
										local eDamage = getDmg("E", enemy, myHero)
										local rDamage = getDmg("R", enemy, myHero)
										local aDamage = getDmg("AD", enemy, myHero)
										local hxgDamage = (HXGSlot and getDmg("HXG", enemy, myHero) or 0)
										local bwcDamage = (BWCSlot and getDmg("BWC", enemy, myHero) or 0)
										local brkDamage = (BRKSlot and getDmg("RUINEDKING", enemy, myHero) or 0)
										local tmatDamage = aDamage*0.6
										local rhydraDamage = aDamage*0.6
										local SheenDamage = (SheenSlot and getDmg("SHEEN", enemy, myHero) or 0)
										local TrinityDamage = (TrinitySlot and getDmg("TRINITY", enemy, myHero) or 0)
										local LichBaneDamage = (LichBaneSlot and getDmg("LICHBANE", enemy, myHero) or 0)
										local iDamage = 50 + (20*myHero.level)
										local myDamage = SheenDamage + TrinityDamage + LichBaneDamage + aDamage
										if QReady then
												myDamage = myDamage + qDamage
										end
										if WReady or WProc == true then
												myDamage = myDamage + wDamage + (aDamage*2)
										end
										if EReady or EProc == true then
												myDamage = myDamage + eDamage + ((1/(1/(((0.625/(1-0.02)))*(1*myHero.attackSpeed))))*aDamage)
										end
										if myHero.level >= 6 and (2.5/(1/(((0.625/(1-0.02)))*(1*myHero.attackSpeed)))) >= 3 then
												myDamage = myDamage + (rDamage*2) + (aDamage*2)
										elseif myHero.level >= 6 and (2.5/(1/(((0.625/(1-0.02)))*(1*myHero.attackSpeed)))) < 3 then
												myDamage = myDamage + rDamage + aDamage
										end
										if HXGReady then
												myDamage = myDamage + hxgDamage
										end
										if BWCReady then
												myDamage = myDamage + bwcDamage
										end
										if BRKReady then
												myDamage = myDamage + brkDamage
										end
										if IReady then
												myDamage = myDamage + iDamage
										end
										if TMatReady then
												myDamage = myDamage + tmatDamage + aDamage
										end
										if RHydraReady then
												myDamage = myDamage + rhydraDamage + aDamage
										end
										if myDamage < enemy.health then
												killable[i] = 5
										elseif (myDamage/4) >= enemy.health then
												killable[i] = 4
										elseif (myDamage/3) >= enemy.health then
												killable[i] = 3
										elseif (myDamage/2) >= enemy.health then
												killable[i] = 2
										elseif myDamage >= enemy.health then
												killable[i] = 1
										else
												killable[i] = 0
										end
								end
						end    
				elseif myHero.dead then
						resetAW()
						resetQE()
				end
		end
		 
		function OnDraw()
				if not myHero.dead then
						if JaxConfig.drawcircles then
								DrawCircle(myHero.x, myHero.y, myHero.z, QRange, 0xFF80FF00)
								--DrawCircle(myHero.x, myHero.y, myHero.z, (ERange*1.6), 0xFF80FF00)
						end
						if ValidTarget(ts.target) then
								if JaxConfig.drawcircles then
										DrawCircle(ts.target.x, ts.target.y, ts.target.z, 100, 0x099B2299)
								end
								if JaxConfig.drawtext then
										DrawText("Targetting: " .. ts.target.charName, 18, 650, 25, 0xFFFF0000)
								end
						end
				for i=1, heroManager.iCount do
						local enemydraw = heroManager:GetHero(i)
						if ValidTarget(enemydraw) then
								if JaxConfig.drawcircles then
										if killable[i] == 1 then
												for j=0, 20 do
														DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 80 + j*1.5, 0x0000FF)
												end
												elseif killable[i] == 2 then
														for j=0, 10 do
																DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 80 + j*1.5, 0xFF0000)
														end
												elseif killable[i] == 3 then
														for j=0, 10 do
																DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 80 + j*1.5, 0xFF0000)
																DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 110 + j*1.5, 0xFF0000)
														end
												elseif killable[i] == 4 then
														for j=0, 10 do
																DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 80 + j*1.5, 0xFF0000)
																DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 110 + j*1.5, 0xFF0000)
																DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 140 + j*1.5, 0xFF0000)
														end
												end
										end
										if JaxConfig.drawtext and waittxt[i] == 1 and killable[i] ~= 0 then
												PrintFloatText(enemydraw,0,floattext[killable[i]])
										end
								end
								if waittxt[i] == 1 then
										waittxt[i] = 30
								else
										waittxt[i] = waittxt[i]-1
								end
				end
				end
		end
-------------------------------------------------------------------------------------------
	elseif myHero.charName == "Jayce" then
--[[
				Jayce the Rapist Beta by jbman
				based on eXtragoZ scripts
		  Thanks to llama for his velocity calculation and Manciuszz for implementing it for Jayce
			   
				-Supports Deathfire Grasp, Bilgewater Cutlass, Hextech Gunblade, Sheen, Trinity, Lich Bane, Blade of thr Ruined King, Sword of the Devine, Tiamat, Ravenous Hydra and Ignite
				-Target configuration, Press shift to configure
				-Option to auto ignite when enemy is killable
			   
			   
		]]
		 
		--[[    Code    ]]
		 
		local CannonQ = false
		local Qtime = 0
		local MMtimer = 0
		local wcountdown = 0
		local ecountdown = 0
		local AAmove = true
		local KBPOS = nil
		local cancelMovt = false
		local EHowFarAway = 0
		local range = 1625
		local erange = 400
		local speed = 1600 --2100
		local delay = 0.285 --0.550
		local smoothness = 50
		local AArange = 0
		local hitPosition = nil
		local EnemyPos = nil
		local HeroPos = nil
		local GatePos = nil
		local EGatePos = nil
		local CanE = true
		local lastRW = 0
		local ignite = nil
		local ts
		local tp
		local tpVIP
		local lastBasicAttack = 0
		local swing = 0
		local lastdirection = 0
		local aahit = false
		 
		local targetSelected = true
		local YMGBSlot, TMATSlot, SotDSlot, DFGSlot, HXGSlot, BWCSlot, SheenSlot, TrinitySlot, LichBaneSlot, ROSlot, ENTSlot, LOCKSlot = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
		local QREADY, WREADY, EREADY, RREADY, YMGBREADY, TMATREADY, SotDREADY, DFGREADY, HXGREADY, BWCREADY, ROREADY, ENTREADY, LOCKREADY = false, false, false, false, false, false, false, false, false, false, false, false, false
		 
		function OnLoad()
		 
				JayceConfig = scriptConfig("Jayce The Rapist 2.0b", "jaycetherapist")
				JayceConfig:addParam("ESCAPE", "Escape", SCRIPT_PARAM_ONKEYDOWN, false, 192) -- ~/`    
				JayceConfig:addParam("scriptActive", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 88) -- X  
				JayceConfig:addParam("BURST", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Y")) -- C 
				JayceConfig:addParam("EASY", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 90) -- Z  
				JayceConfig:addParam("FREEQE", "FreeQE", SCRIPT_PARAM_ONKEYDOWN, false, 84) -- T       
		  JayceConfig:addParam("eBuffer", "Gate distance",SCRIPT_PARAM_SLICE, 100, 1, 500, 2)  
		  JayceConfig:addParam("drawprediction", "Draw Prediction", SCRIPT_PARAM_ONOFF, false)  
		  JayceConfig:addParam("VIP", "VIP TP", SCRIPT_PARAM_ONOFF, true)
		  JayceConfig:addParam("AutoMM", "Auto Muramana", SCRIPT_PARAM_ONOFF, true)
				JayceConfig:addParam("drawcircles", "Draw Circles", SCRIPT_PARAM_ONOFF, true)
				JayceConfig:addParam("drawtext", "Draw Text", SCRIPT_PARAM_ONOFF, true)
				JayceConfig:addParam("autoignite", "Auto Ignite", SCRIPT_PARAM_ONOFF, true)  
		  ts = TargetSelector(TARGET_LESS_CAST_PRIORITY,range+150,DAMAGE_PHYSICAL)
		  tpVIP = TargetPredictionVIP(range, speed, delay)
		  tp = TargetPrediction(range, speed/1000, delay*1000, smoothness)
		  ts.name = "Jayce"
				JayceConfig:addTS(ts)
				PrintChat(">> Jayce The Rapist 2.0b loaded!")
		end  
		 
		function OnProcessSpell(unit, spell) -- JayceAccelerationGate
		  if unit.isMe and spell and (spell.name:find("jayceaccelerationgate") ~= nil) then
			GatePos = nil
			hitPosition = nil
			cancelMovt = false
		  end
		  if unit.isMe and spell and (spell.name:find("JayceThunderingBlow") ~= nil) then
			KBPOS = nil
		  end
		  if unit.isMe and spell and (spell.name:find("jayceshockblast") ~= nil) then
			CannonQ = true
			Qtime = os.clock()
			if myHero:GetSpellData(_R).name == "jaycestancegth" and myHero:CanUseSpell(_E) == READY and VIP_USER == false and JayceConfig.scriptActive or JayceConfig.BURST or JayceConfig.FREEQE then
			  myHero:HoldPosition()
			end
			if myHero:GetSpellData(_R).name == "jaycestancegth" and myHero:CanUseSpell(_E) == READY and VIP_USER and JayceConfig.scriptActive or JayceConfig.BURST or JayceConfig.FREEQE then
			  cancelMovt = true
			end
		  end
		  if unit.isMe and spell and (spell.name:find("jaycepassive") ~= nil or spell.name:find("Attack") ~= nil or spell.name:find("Attack") ~= nil) then swing = 1 lastBasicAttack = os.clock() end --PrintChat("Hit")  
		  if unit.isMe and spell and (spell.name:find("jaycehypercharge") ~= nil) then CanE = False lastRW = os.clock() end --PrintChat("Hit")  
		end  
		 
		function OnCreateObj(obj)
		  if ts.target and obj and (obj.name:find("Jayce_Hex_Buff_Ready.troy") ~= nil) and GetDistance(obj) < 175 then
			CanE = false
		  end  
		  if ts.target and  obj and (obj.name:find("Jayce_Range_Basic_Mis.troy") ~= nil) and GetDistance(obj) < 175 then
			aahit = true
		  end    
		  if ts.target and obj and (obj.name:find("globalhit_bloodslash") ~= nil) and GetDistance(obj) > 1 and GetDistance(obj,ts.target) < 150 then
			aahit = true
		  end
		  if ts.target and obj and (obj.name:find("Jayce_Charged_Hit") ~= nil) and GetDistance(obj) > 1 and GetDistance(obj,ts.target) < 150 then
			aahit = true      
		  end
		  if CannonQ and obj and (obj.name:find("JayceOrbLightning.troy") ~= nil) and GetDistance(obj) < 500 then
			--PrintChat("ORB")
			if JayceConfig.FREEQE or JayceConfig.scriptActive or JayceConfig.BURST then
			  CastSpell(_E,obj.x,obj.z)
			end
		  end
		end
		 
		function OnDeleteObj(obj)
		  if ts.target and obj and (obj.name:find("Jayce_Hex_Buff_Ready.troy") ~= nil) and GetDistance(obj) < 175 then  
			CanE = true
		  end  
		end
		 
		function Items()
		  YMGBSlot, TMATSlot, SotDSlot, DFGSlot, HXGSlot, BWCSlot, SheenSlot, TrinitySlot, LichBaneSlot, ROSlot, ENTSlot, LOCKSlot = GetInventorySlotItem(3142), (GetInventorySlotItem(3077) or GetInventorySlotItem(3074)) , GetInventorySlotItem(3131), GetInventorySlotItem(3128), GetInventorySlotItem(3146), (GetInventorySlotItem(3144)or GetInventorySlotItem(3153)), GetInventorySlotItem(3057), GetInventorySlotItem(3078), GetInventorySlotItem(3100), GetInventorySlotItem(3143), GetInventorySlotItem(3184), GetInventorySlotItem(3190)
			   
		  DFGREADY = (DFGSlot ~= nil and myHero:CanUseSpell(DFGSlot) == READY)
		  HXGREADY = (HXGSlot ~= nil and myHero:CanUseSpell(HXGSlot) == READY)
		  BWCREADY = (BWCSlot ~= nil and myHero:CanUseSpell(BWCSlot) == READY)
		  TMATREADY = (TMATSlot ~= nil and myHero:CanUseSpell(TMATSlot) == READY)
		  SotDREADY = (SotDSlot ~= nil and myHero:CanUseSpell(SotDSlot) == READY)
		  YMGBREADY = (SotDSlot ~= nil and myHero:CanUseSpell(YMGBSlot) == READY)
		  ROREADY = (ROSlot ~= nil and myHero:CanUseSpell(ROSlot) == READY)
		  ENTREADY = (ENTSlot ~= nil and myHero:CanUseSpell(ENTSlot) == READY) -- , ENTSlot = GetInventorySlotItem(3184),
		  LOCKREADY = (LOCKSlot ~= nil and myHero:CanUseSpell(LOCKSlot) == READY)
		  if ts.target ~= nil then
			if DFGREADY then CastSpell(DFGSlot, ts.target) end
			if HXGREADY then CastSpell(HXGSlot, ts.target) end
			if BWCREADY and GetDistance(ts.target) <= 501 and ts.target.type == "obj_AI_Hero" then CastSpell(BWCSlot, ts.target) end      
			if ROREADY and GetDistance(ts.target) <= 485 and ts.target.type == "obj_AI_Hero" then CastSpell(ROSlot) end
			if LOCKREADY and GetDistance(ts.target) <= 485 and ts.target.type == "obj_AI_Hero" then CastSpell(LOCKSlot) end
			if swing == 1 then
			  if YMGBREADY then -- YMGB
				if ts.target.type == "obj_AI_Hero" and GetDistance(ts.target) < 400 then
				  CastSpell(YMGBSlot)
				end
			  end
			  if SotDREADY then
				if ts.target.type == "obj_AI_Hero" and GetDistance(ts.target) < 400 then
				  CastSpell(SotDSlot)
				end
			  end
			  if ENTREADY then -- YMGB
				if ts.target.type == "obj_AI_Hero" and GetDistance(ts.target) < 400 then
				  CastSpell(ENTSlot)
				end
			  end
			  if TMATREADY and GetDistance(ts.target) < 375 and aahit == true then -- If Q is ready and you have Tiamat/Hydra you will use the active after an AA
				CastSpell(TMATSlot)
				aahit = false
				swing = 0      
			  end
			end
		  end
		end
		 
		function QEcheck()
		  if (myHero:GetSpellData(_R).name == "jaycestancegth" and myHero:CanUseSpell(_Q) ~= COOLDOWN and myHero:CanUseSpell(_E) ~= COOLDOWN and ((player:GetSpellData(_Q).level == 1 and myHero.mana > 99) or
			(player:GetSpellData(_Q).level == 2 and myHero.mana > 104) or
			(player:GetSpellData(_Q).level == 3 and myHero.mana > 109) or
			(player:GetSpellData(_Q).level == 4 and myHero.mana > 114) or
			(player:GetSpellData(_Q).level == 5 and myHero.mana > 119))) then
			return true
		  else
			return false
		  end    
		end
		 
		function orbWalk()
				if ts.target ~= nil then
						if AAmove == true then                  
			  player:MoveTo(ts.target.x, ts.target.z)
			  --PrintChat("ORB!")
			  aahit = false          
			  swing = 0
						end
			myHero:Attack(ts.target)        
		  elseif ts.target == nil then
			swing = 0
			aahit = false
		  end
		end
		 
		function OnSendPacket(packet)  
		  if packet.header == 0x71 then
			--PrintChat("Moving!")
			packet.pos = 5    
			if cancelMovt == true then
			  --PrintChat("HALT!")
			  packet:Block()
			  packet:Block()
			  packet:Block()
			end
		  end
		end
		 
		function GateUpdate()
		  if myHero:GetSpellData(_R).name == "jaycestancegth" and myHero:CanUseSpell(_E) == READY then
			MPos = Vector(mousePos.x, mousePos.y, mousePos.z)
			HeroPos = Vector(myHero.x, myHero.y, myHero.z)
			GatePos = HeroPos + ( HeroPos - MPos )*(-EHowFarAway/GetDistance(mousePos))    
		  end
		end
		 
		--ONTICK
		--ONTICK
		--ONTICK
		--ONTICK
		--ONTICK
		--ONTICK
		--ONTICK
		--ONTICK
		--ONTICK
		--ONTICK
		--ONTICK
		--ONTICK
		--ONTICK
		--ONTICK
		--ONTICK
		--ONTICK
		--ONTICK
		--ONTICK
		--ONTICK
		--ONTICK
		 
		function OnTick()
		 
		  EHowFarAway = JayceConfig.eBuffer
		  AArange = ((myHero.range + (GetDistance(myHero.minBBox, myHero.maxBBox)/2))*1.1)
				if myHero.dead then
						return
				end
		  QEcheck()
		 
		  if QEcheck() == true then
		   -- PrintChat("QE!")
				end
		 
		  if myHero:GetSpellData(_R).name == "jaycestancegth" and myHero:CanUseSpell(_E) == READY then --(JayceConfig.scriptActive or JayceConfig.BURST or JayceConfig.ESCAPE or JayceConfig.FREEQE) then
			GateUpdate()
			QEcheck()
		  end
		 
		  if myHero:GetSpellData(_R).name == "jaycestancegth" then
			if myHero:CanUseSpell(_E) == READY then
			  if myHero:CanUseSpell(_Q) == READY then
				range = 1650        
			  elseif myHero:CanUseSpell(_Q) ~= READY then
				range = 650
			  end
			elseif myHero:CanUseSpell(_E) ~= READY then
			  if myHero:CanUseSpell(_Q) == READY then
				range = 1050
			  elseif myHero:CanUseSpell(_Q) ~= READY then
				range = 650
			  end
			end
		  elseif myHero:GetSpellData(_R).name == "JayceStanceHtG" then
			if myHero:CanUseSpell(_Q) == READY then
			  range = 750        
			elseif myHero:CanUseSpell(_Q) ~= READY then
			  range = 550
			end
		  end
		 
		  if CannonQ and os.clock() > Qtime + 0.5 then
			cancelMovt = false
			hitPosition = nil
			GatePos = nil
			CannonQ = false
			--PrintChat("CanE!")
		  end  
		 
		  ts:update()
		  if myHero:GetSpellData(_R).name == "jaycestancegth" and myHero:CanUseSpell(_E) == READY then
			MPos = Vector(mousePos.x, mousePos.y, mousePos.z)
			HeroPos = Vector(myHero.x, myHero.y, myHero.z)
			GatePos = HeroPos + ( HeroPos - MPos )*(-EHowFarAway/GetDistance(mousePos))
			if ts.target and ValidTarget(ts.target) and GetDistance(ts.target) < range+150 and ts.target.dead == false then      
			  if VIP_USER then
				hitPosition = tpVIP:GetPrediction(ts.target)      
			  elseif VIP_USER == false then
				hitPosition = tp:GetPrediction(ts.target)
			  end    
			end
		  end
		 
		  if ts.target == nil or (ts.target and hitPosition and ts.target == dead)  then
			KBPOS = nil
			hitPosition = nil
		  end
		 
		 
		  if (myHero:GetSpellData(_R).name == "jaycestancegth" and (myHero:CanUseSpell(_E) == COOLDOWN and myHero:CanUseSpell(_Q) == COOLDOWN)) or myHero:GetSpellData(_R).name ~= "jaycestancegth" then  
			hitPosition = nil
		  end
		 
		  if CanE == false and os.clock() > lastRW + 4 then
			--PrintChat("CanE!")
						--CanE = true    
		  end
		 
		  if swing == 1 and os.clock() > lastBasicAttack + 0.7 then
						swing = 0
			if aahit == true then
			  aahit = false
			end
				end
		 
				QREADY = (myHero:CanUseSpell(_Q) == READY)
				WREADY = (myHero:CanUseSpell(_W) == READY)
				EREADY = (myHero:CanUseSpell(_E) == READY)
				RREADY = (myHero:CanUseSpell(_R) == READY)
		  IREADY = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
		 
				HAMMER = (myHero:GetSpellData(_R).name == "JayceStanceHtG")
				CANNON = (myHero:GetSpellData(_R).name == "jaycestancegth")
		 
		  if JayceConfig.STANCE then
						if RREADY then
								CastSpell(_R)
						end    
				end
		 
		  --[[ MuramanaIsActive() Return true / false
		  MuramanaOn() Set Muramana On if possible
		  MuramanaOff() Set Muramana Off if possible
		  MuramanaToggle(range, extCondition)]]
		 
		  if JayceConfig.AutoMM then
			if MuramanaIsActive() == false then
			  if HAMMER and ts.target ~= nil and GetDistance(ts.target) < 450 then
				MuramanaOn()
				MMtimer = os.clock()
			  end
			  if CANNON and ts.target ~= nil and GetDistance(ts.target) < AArange+50 then
				MuramanaOn()
				MMtimer = os.clock()
			  end
			end
			if MuramanaIsActive() == true then
			  if HAMMER and ts.target ~= nil and GetDistance(ts.target) > 451 then
				MuramanaOff()
			  end      
			  if CANNON and ts.target ~= nil and GetDistance(ts.target) > AArange+51 then
				MuramanaOff()
			  end
			  if os.clock() > MMtimer + 5 and ts.target == nil then
				MuramanaOff()
			  end
			end
		  end
		 
		  if JayceConfig.FREEQE then
						if HAMMER then
								CastSpell(_R)
			end    
			if CANNON and QEcheck() == true and QREADY and EREADY then
			  CastSpell(_Q, mousePos.x, mousePos.z)        
			end
				end
		 
		-- ESCAPE
				if JayceConfig.ESCAPE then
			if HAMMER then                     
			  CastSpell(_R)                            
			elseif CANNON then
			  if GetTickCount()-lastdirection >= 500 then
				local absposxy = math.min(math.abs(mousePos.x-myHero.x),math.abs(mousePos.y-myHero.y))
				myHero:MoveTo(myHero.x+(mousePos.x-myHero.x)*100/absposxy,myHero.z+(mousePos.z-myHero.z)*100/absposxy)
				lastdirection = GetTickCount()
			  elseif GetTickCount()-lastdirection >= 100 then        
				myHero:MoveTo(mousePos.x,mousePos.z)
				if myHero:CanUseSpell(_E) == READY then          
				  EscapePos = Vector(mousePos.x, mousePos.y, mousePos.z)
				  HeroPos = Vector(myHero.x, myHero.y, myHero.z)
				  GatePos = HeroPos + ( HeroPos - EscapePos )*(-EHowFarAway/GetDistance(mousePos))
				  CastSpell(_E, GatePos.x, GatePos.z)                                          
				end        
			  end              
			end
		  end
		 
		  if JayceConfig.scriptActive and ts.target then
			if CANNON then
			  if HAMMER == false then
				--QEcheck()
				Items()
				if hitPosition and QEcheck() == true and QREADY and EREADY then          
				  CastSpell(_Q, hitPosition.x, hitPosition.z)          
				end
				if QREADY == false and EREADY == false then
				  GatePos = nil          
				  myHero:Attack(ts.target)
				end      
				if swing == 1 then
				  if QREADY == false and EREADY == false and aahit == true then
					orbWalk()
				  end
				end
			  end
			end  
			if HAMMER then    
			  if CANNON == false then        
				Items()      
				if QREADY and GetDistance(ts.target) < 750 then
				  myHero:Attack(ts.target)
				  CastSpell(_Q, ts.target)
				end
				if swing == 0 then
				  if GetDistance(ts.target) < AArange+150 then
					myHero:Attack(ts.target)
				  end    
				elseif swing == 1 then          
				  if QREADY == false and TMATREADY == false and aahit == true then
					orbWalk()          
				  end        
				end
			  end
			end
		  end
		 
		  if JayceConfig.BURST and ts.target then
			if CANNON then
			  if HAMMER == false then
				--QEcheck()
				Items()
				if hitPosition and QEcheck() == true and QREADY and EREADY then          
				  CastSpell(_Q, hitPosition.x, hitPosition.z)          
				end
				if QREADY == false and EREADY == false then
				  GatePos = nil    
				  if GetDistance(ts.target) < AArange then
					myHero:Attack(ts.target)
					if swing == 1 and aahit == true then
					  CastSpell(_W)
					  myHero:Attack(ts.target)      
					  CastSpell(_R)
					end
				  elseif (GetDistance(ts.target) < range and GetDistance(ts.target) > AArange) then
					CastSpell(_W)
					myHero:Attack(ts.target)      
					CastSpell(_R)
				  end
				end
				if QREADY == false and EREADY == false then          
				  myHero:Attack(ts.target)      
				end
			  end
			end    
			if HAMMER then      
			  if CANNON == false then      
				 Items()      
				if QREADY and GetDistance(ts.target) < 750 then
				  myHero:Attack(ts.target)
				  CastSpell(_W)  
				  CastSpell(_Q, ts.target)        
				end    
				if swing == 0 then
				  if EREADY and GetDistance(ts.target) < 450 and CanE == true then
					if EREADY and (GetDistance(ts.target) < erange and GetDistance(ts.target) > AArange-50) then            
					  CastSpell(_E, ts.target)
					end            
				  end          
				  if GetDistance(ts.target) < AArange + 125 then
					myHero:Attack(ts.target)
				  end
				end
				if swing == 1 then
				  if EREADY and aahit == true and CanE == true then
					CastSpell(_E, ts.target)
				  end
				  if QREADY == false and TMATREADY == false and aahit == true and CanE == false then
					orbWalk()
				  end
				  if QREADY == false and TMATREADY == false and EREADY == false and aahit == true then
					orbWalk()
				  end          
				end
			  end
			end
		  end  
			   
				if JayceConfig.EASY and ts.target then
			if HAMMER then    
			  if CANNON == false then      
				Items()      
				if swing == 0 then
				  if GetDistance(ts.target) < AArange+150 then
					myHero:Attack(ts.target)
				  end
				  if EREADY and GetDistance(ts.target) < 450 then
					if EREADY and (GetDistance(ts.target) < erange and GetDistance(ts.target) > AArange-50) then            
					  CastSpell(_E, ts.target)
					end            
				  end
				elseif swing == 1 then
				  if EREADY and aahit == true then
					CastSpell(_E, ts.target)
				  end
				  if QREADY == false and TMATREADY == false and EREADY == false and aahit == true then
					orbWalk()
				  end        
				end
			  end
			end
			if CANNON then
			  if HAMMER == false then    
				Items()
				if swing == 0 then
				  if GetDistance(ts.target) < AArange + 200 then
					myHero:Attack(ts.target)
				  end
				elseif swing == 1 then
				  if aahit == true then
					CastSpell(_W)
					myHero:Attack(ts.target)
					swing = 0
					aahit = false
				  end          
				  if WREADY == false and TMATREADY == false and aahit == true then
					orbWalk()    
				  end        
				end
			  end
			end
		  end
		-- Poop
		end
		 
		function OnDraw()
				if myHero.dead == false then    
			if JayceConfig.drawcircles and CANNON then
			  --DrawCircle(myHero.x, myHero.y, myHero.z, AArange, 0x992D3D)
								if EREADY and QREADY then DrawCircle(myHero.x, myHero.y, myHero.z, range, 0x992D3D) end
			  if WREADY then DrawCircle(myHero.x, myHero.y, myHero.z, AArange, 0x992D3D)  -- 0x992D3D
			  elseif WREADY == false then DrawCircle(myHero.x, myHero.y, myHero.z, AArange, 0x992D3D) end
				elseif JayceConfig.drawcircles and HAMMER then
								if QREADY then DrawCircle(myHero.x, myHero.y, myHero.z, 750, 0x992D3D) end
								if EREADY then DrawCircle(myHero.x, myHero.y, myHero.z, erange, 0x992D3D)
			  elseif EREADY == false then DrawCircle(myHero.x, myHero.y, myHero.z, AArange, 0x992D3D)end
						end
						if ts.target ~= nil then                       
								DrawCircle(ts.target.x, ts.target.y, ts.target.z, (GetDistance(ts.target.minBBox, ts.target.maxBBox)/2), 0x00FF00)
						end
				end
		  if ts.target ~= nil and hitPosition ~= nil and JayceConfig.drawprediction then
						DrawCircle(hitPosition.x, hitPosition.y, hitPosition.z, 100, 0xFFFFFF) -- hitPosition
				end
		end
		 
		function OnSendChat(msg)
				ts:OnSendChat(msg, "pri")
		end
-------------------------------------------------------------------------------------------
	elseif myHero.charName == "Khazix" then
		--[[
			KhaZix Combo 1.4
				by eXtragoZ

			Features:
				- Full combo: Items -> W -> E -> Q -> R
				- Supports: Deathfire Grasp, Liandry's Torment, Blackfire Torch, Bilgewater Cutlass, Hextech Gunblade, Blade of the Ruined King, Sheen, Trinity, Lich Bane, Iceborn Gauntlet, Shard of True Ice, Randuin's Omen and Ignite
				- Harass mode: W
				- Informs where will use W / E. Default: off
				- Checks minion collision for W
				- Mark killable target with a combo
				- Target configuration
				- Press shift to configure
			
			Explanation of the marks:
				Green circle:  Marks the current target to which you will do the combo
				Blue circle:  Mark a target that can be killed with a combo, if all the skills were available
				Red circle:  Mark a target that can be killed using items + pasive x2 + 4 hits + Q + Q (Isolated) + W + E + ignite
				2 Red circles:  Mark a target that can be killed using items + pasive + 3 hits + Q (Isolated) + W + E + ignite
				3 Red circles:  Mark a target that can be killed using items (without on hit items) + Q + W + E
		]]
		--[[		Config		]]     
		local HK = 84 --spacebar
		local HHK = string.byte("G") --T
		--[[		Code		]]
		local qrange = 380
		local wrange = 1000
		local erange = 600
		local eradius = 325
		local speed = 400
		local tick = nil
		-- Active
		-- draw
		local waittxt = {}
		local floattext = {"Skills are not available","Able to fight","Killable","Murder him!"}
		local killable = {}
		local calculationenemy = 1
		-- ts
		local ts
		local distancetstarget = 0
		--
		local ignite = nil
		local DFGSlot, HXGSlot, BWCSlot, SheenSlot, TrinitySlot, LBSlot, IGSlot, LTSlot, BTSlot, STISlot, ROSlot, BRKSlot = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
		local QREADY, WREADY, EREADY, RREADY, DFGREADY, HXGREADY, BWCREADY, STIREADY, ROREADY, BRKREADY, IREADY = false, false, false, false, false, false, false, false, false, false, false

		function OnLoad()
			KZCConfig = scriptConfig("KhaZix Combo 1.4", "khazixcombo")
			KZCConfig:addParam("scriptActive", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, HK)
			KZCConfig:addParam("harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, HHK)
			KZCConfig:addParam("drawcircles", "Draw Circles", SCRIPT_PARAM_ONOFF, true)
			KZCConfig:addParam("drawtext", "Draw Text", SCRIPT_PARAM_ONOFF, true)
			KZCConfig:addParam("drawprediction", "Draw Prediction", SCRIPT_PARAM_ONOFF, false)
			KZCConfig:addParam("useult", "Use Ult", SCRIPT_PARAM_ONOFF, true)
			KZCConfig:permaShow("scriptActive")
			KZCConfig:permaShow("harass")
			ts = TargetSelector(TARGET_LOW_HP,wrange,DAMAGE_PHYSICAL)
			ts:SetPrediction(speed)
			ts.name = "KhaZix"
			KZCConfig:addTS(ts)
			if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then ignite = SUMMONER_1
			elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then ignite = SUMMONER_2 end
			for i=1, heroManager.iCount do waittxt[i] = i*3 end
			PrintChat(" >> KhaZix Combo 1.4 loaded!")
		end

		function OnTick()
			ts:update()
			Prediction__OnTick()
			DFGSlot, HXGSlot, BWCSlot = GetInventorySlotItem(3128), GetInventorySlotItem(3146), GetInventorySlotItem(3144)
			SheenSlot, TrinitySlot, LBSlot = GetInventorySlotItem(3057), GetInventorySlotItem(3078), GetInventorySlotItem(3100)
			IGSlot, LTSlot, BTSlot = GetInventorySlotItem(3025), GetInventorySlotItem(3151), GetInventorySlotItem(3188)
			STISlot, ROSlot, BRKSlot = GetInventorySlotItem(3092),GetInventorySlotItem(3143),GetInventorySlotItem(3153)
			QREADY = (myHero:CanUseSpell(_Q) == READY)
			WREADY = (myHero:CanUseSpell(_W) == READY)
			EREADY = (myHero:CanUseSpell(_E) == READY)
			RREADY = (myHero:CanUseSpell(_R) == READY)
			DFGREADY = (DFGSlot ~= nil and myHero:CanUseSpell(DFGSlot) == READY)
			HXGREADY = (HXGSlot ~= nil and myHero:CanUseSpell(HXGSlot) == READY)
			BWCREADY = (BWCSlot ~= nil and myHero:CanUseSpell(BWCSlot) == READY)
			STIREADY = (STISlot ~= nil and myHero:CanUseSpell(STISlot) == READY)
			ROREADY = (ROSlot ~= nil and myHero:CanUseSpell(ROSlot) == READY)
			BRKREADY = (BRKSlot ~= nil and myHero:CanUseSpell(BRKSlot) == READY)
			IREADY = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
			if tick == nil or GetTickCount()-tick >= 100 then
				tick = GetTickCount()
				KZCDmgCalculation()
			end
			if myHero:GetSpellData(_Q).name == "khazixqlong" then qrange = 430 end
			if myHero:GetSpellData(_E).name == "khazixelong" then erange = 900 end
			if ts.target ~= nil then distancetstarget = GetDistance(ts.target) end
			if KZCConfig.harass and ts.target ~= nil then
				if WREADY and GetDistance(ts.nextPosition)<=wrange and not GetMinionCollision(myHero,ts.nextPosition, 200) then CastSpell(_W, ts.nextPosition.x, ts.nextPosition.z) end
			end
			if KZCConfig.scriptActive and ts.target ~= nil then
				if DFGREADY then CastSpell(DFGSlot, ts.target) end
				if HXGREADY then CastSpell(HXGSlot, ts.target) end
				if BWCREADY then CastSpell(BWCSlot, ts.target) end
				if BRKREADY then CastSpell(BRKSlot, ts.target) end
				if STIREADY and distancetstarget<=380 then CastSpell(STISlot, myHero) end
				if ROREADY and distancetstarget<=500 then CastSpell(ROSlot) end	
				if WREADY and GetDistance(ts.nextPosition)<=wrange and not GetMinionCollision(myHero,ts.nextPosition, 200) then CastSpell(_W, ts.nextPosition.x, ts.nextPosition.z) end
				if EREADY then CastSpell(_E, ts.nextPosition.x, ts.nextPosition.z) end
				if QREADY and distancetstarget<=qrange then CastSpell(_Q, ts.target) end
				if KZCConfig.useUlt and RREADY and not QREADY and not WREADY and not EREADY then CastSpell(_R, ts.target) end
			end
		end
		function KZCDmgCalculation()
			local enemy = heroManager:GetHero(calculationenemy)
			if ValidTarget(enemy) then
				local pdamage = getDmg("P",enemy,myHero) -- (bonus)
				local qdamage = getDmg("Q",enemy,myHero) --Normal
				local qdamage2 = getDmg("Q",enemy,myHero,2) --Evolved Enlarged Claws (Bonus)
				local qdamage3 = getDmg("Q",enemy,myHero,3) --to Isolated Target
				local wdamage = getDmg("W",enemy,myHero)
				local edamage = getDmg("E",enemy,myHero)
				local rdamage = 0
				local hitdamage = getDmg("AD",enemy,myHero)
				local dfgdamage = (DFGSlot and getDmg("DFG",enemy,myHero) or 0)
				local hxgdamage = (HXGSlot and getDmg("HXG",enemy,myHero) or 0)
				local bwcdamage = (BWCSlot and getDmg("BWC",enemy,myHero) or 0)
				local brkdamage = (BRKREADY and getDmg("RUINEDKING",enemy,myHero,2) or 0)
				local ignitedamage = (ignite and getDmg("IGNITE",enemy,myHero) or 0)
				local onhitdmg = (SheenSlot and getDmg("SHEEN",enemy,myHero) or 0)+(TrinitySlot and getDmg("TRINITY",enemy,myHero) or 0)+(LBSlot and getDmg("LICHBANE",enemy,myHero) or 0)+(IcebornSlot and getDmg("ICEBORN",enemy,myHero) or 0)
				local onspelldamage = (LTSlot and getDmg("LIANDRYS",enemy,myHero) or 0)+(BTSlot and getDmg("BLACKFIRE",enemy,myHero) or 0)
				local onspelldamage2 = 0
				
				if myHero:GetSpellData(_Q).name == "khazixqlong" then qdamage3 = qdamage2+qdamage3 end
				
				local combo1 = hitdamage*4 + pdamage*2 + qdamage + qdamage3 + wdamage + onhitdmg --0 cd
				local combo2 = hitdamage*4 + pdamage*2 + onhitdmg
				local combo3 = hitdamage*3 + pdamage + onhitdmg
				local combo4 = 0
			
				if QREADY then
					combo2 = combo2 + qdamage + qdamage3
					combo3 = combo3 + qdamage3
					combo4 = combo4 + qdamage
				end
				if WREADY then
					combo2 = combo2 + wdamage
					combo3 = combo3 + wdamage
					combo4 = combo4 + wdamage
				end
				if EREADY then
					combo2 = combo2 + edamage
					combo3 = combo3 + edamage
					combo4 = combo4 + edamage
				end
				if DFGREADY then		
					combo1 = combo1 + dfgdamage		
					combo2 = combo2 + dfgdamage
					combo3 = combo3 + dfgdamage
					combo4 = combo4 + dfgdamage
				end
				if HXGREADY then               
					combo1 = combo1 + hxgdamage*(DFGREADY and 1.2 or 1)
					combo2 = combo2 + hxgdamage*(DFGREADY and 1.2 or 1)
					combo3 = combo3 + hxgdamage*(DFGREADY and 1.2 or 1)
					combo4 = combo4 + hxgdamage
				end
				if BWCREADY then
					combo1 = combo1 + bwcdamage*(DFGREADY and 1.2 or 1)
					combo2 = combo2 + bwcdamage*(DFGREADY and 1.2 or 1)
					combo3 = combo3 + bwcdamage*(DFGREADY and 1.2 or 1)
					combo4 = combo4 + bwcdamage
				end
				if BRKREADY then
					combo1 = combo1 + brkdamage
					combo2 = combo2 + brkdamage
					combo3 = combo3 + brkdamage
					combo4 = combo4 + brkdamage
				end
				if IREADY then
					combo1 = combo1 + ignitedamage	
					combo2 = combo2 + ignitedamage
					combo3 = combo3 + ignitedamage
				end
				if combo4 >= enemy.health then killable[calculationenemy] = 4
				elseif combo3 >= enemy.health then killable[calculationenemy] = 3
				elseif combo2 >= enemy.health then killable[calculationenemy] = 2
				elseif combo1 >= enemy.health then killable[calculationenemy] = 1
				else killable[calculationenemy] = 0 end   
			end
			if calculationenemy == 1 then calculationenemy = heroManager.iCount
			else calculationenemy = calculationenemy-1 end
		end
		function OnDraw()
			if KZCConfig.drawcircles and not myHero.dead then
				if QREADY then DrawCircle(myHero.x, myHero.y, myHero.z, qrange, 0x19A712)
				else DrawCircle(myHero.x, myHero.y, myHero.z, qrange, 0x992D3D) end
				if WREADY then DrawCircle(myHero.x, myHero.y, myHero.z, wrange, 0x19A712)
				else DrawCircle(myHero.x, myHero.y, myHero.z, wrange, 0x992D3D) end
				if EREADY then DrawCircle(myHero.x, myHero.y, myHero.z, erange, 0x19A712)
				else DrawCircle(myHero.x, myHero.y, myHero.z, erange, 0x992D3D) end
				if ts.target ~= nil then
					for j=0, 10 do DrawCircle(ts.target.x, ts.target.y, ts.target.z, 40 + j*1.5, 0x00FF00) end
				end
			end
			if ts.target ~= nil and KZCConfig.drawprediction then
				DrawCircle(ts.nextPosition.x, ts.target.y, ts.nextPosition.z, 200, 0x0000FF)
			end
			for i=1, heroManager.iCount do
				local enemydraw = heroManager:GetHero(i)
				if ValidTarget(enemydraw) then
					if KZCConfig.drawcircles then
						if killable[i] == 1 then
							for j=0, 20 do
								DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 80 + j*1.5, 0x0000FF)
							end
						elseif killable[i] == 2 then
							for j=0, 10 do
								DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 80 + j*1.5, 0xFF0000)
							end
						elseif killable[i] == 3 then
							for j=0, 10 do
								DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 80 + j*1.5, 0xFF0000)
								DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 110 + j*1.5, 0xFF0000)
							end
						elseif killable[i] == 4 then
							for j=0, 10 do
								DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 80 + j*1.5, 0xFF0000)
								DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 110 + j*1.5, 0xFF0000)
								DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 140 + j*1.5, 0xFF0000)
							end
						end
					end
					if KZCConfig.drawtext and waittxt[i] == 1 and killable[i] ~= 0 then
						PrintFloatText(enemydraw,0,floattext[killable[i]])
					end
				end
				if waittxt[i] == 1 then waittxt[i] = 30
				else waittxt[i] = waittxt[i]-1 end
			end
		end
		function OnSendChat(msg)
			ts:OnSendChat(msg, "pri")
		end

-------------------------------------------------------------------------------------------
	elseif myHero.charName == "Renekton" then
		--[[
				RAPEKTON v1.1 by jbman
		]]
		--require 'TargetPrediction2'
		--require 'Packet'
		--[[            Code            ]]
		 
		local mousemoving = true
		local waitDelay = 450
		local scanAdditionalRange = 750
		local nextTick = 0
		 
		local moveAfterE = false
		local Ecast = false
		local lastEcast = 0
		 
		local Wcast = 0
		local lastWcast = 0
		local WDelay = 0.01
		 
		local AAmove = true
		 
		local AArange = 0
		local range = 500
		local speed = 2200
		local delay = 0.1
		local qrange = 400
		 
		local lastBasicAttack = 0
		--local swingDelay = 0
		local swingDelay = 0.15 --(0.4 - (GetLatency()/1000))
		local swing = 0
		local tick = nil
		local aahit = false
		 
		local targetSelected = true
		 
		local ts
		--local tp
		 
		local ignite = nil
		 
		local YMGBSlot, TMATSlot, SotDSlot BRKSlot, DFGSlot, HXGSlot, BWCSlot, SheenSlot, TrinitySlot, LichBaneSlot, ROSlot, ENTSlot, LOCKSlot = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
		local QREADY, WREADY, EREADY, RREADY, YMGBREADY, TMATREADY, SotDREADY, BRKREADY, DFGREADY, HXGREADY, BWCREADY, ROREADY, ENTREADY, LOCKREADY = false, false, false, false, false, false, false, false, false, false, false, false, false, false
		 
		 
		function OnLoad()
		   
				RCConfig = scriptConfig("Renekton the Rapist", "Renektontherapist v1.4")
				RCConfig:addParam("scriptActive", "ECombo", SCRIPT_PARAM_ONKEYDOWN, false, 67)
				RCConfig:addParam("scriptActive1", "WCombo", SCRIPT_PARAM_ONKEYDOWN, false, 90)
				RCConfig:addParam("scriptActive2", "QCombo", SCRIPT_PARAM_ONKEYDOWN, false, 88)
				RCConfig:addParam("escape", "Escape", SCRIPT_PARAM_ONKEYDOWN, false, 89)
				RCConfig:addParam("harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("G"))
		  RCConfig:addParam("alt", "Alternate", SCRIPT_PARAM_ONKEYDOWN, false, 17)
				RCConfig:addParam("drawcircles", "Draw Circles", SCRIPT_PARAM_ONOFF, true)
				RCConfig:addParam("drawtext", "Draw Text", SCRIPT_PARAM_ONOFF, true)
				RCConfig:addParam("autoAAFarm", "Auto AA Farm", SCRIPT_PARAM_ONKEYDOWN, false, 192) -- `~
				RCConfig:addParam("autoignite", "Auto Ignite", SCRIPT_PARAM_ONOFF, true)
		  RCConfig:addParam("autoQ", "Auto Q", SCRIPT_PARAM_ONKEYTOGGLE, false, 112)
		 
				RCConfig:permaShow("autoAAFarm")
		  RCConfig:permaShow("autoQ")
		 
		  ts = TargetSelector(TARGET_LOW_HP,range+250,DAMAGE_PHYSICAL,true)    
				--tp = TargetPrediction2(range, proj_speed, delay)
		  ts.name = "Renekton"
				RCConfig:addTS(ts)
		  enemyMinions = minionManager(MINION_ENEMY, range+150, player, MINION_SORT_HEALTH_ASC)
				if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then ignite = SUMMONER_1
				elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then ignite = SUMMONER_2
		  end  
		 
		end
		 
		 function sliceTarget(target)
			if Ecast == false and myHero:GetSpellData(_E).name == "RenektonSliceAndDice" and target ~= nil then
			  --predictedPos = tp:GetPrediction(ts.target)
			 -- CastSpell(_E,predictedPos.x,predictedPos.z)
			 CastSpell(_E,target.x, target.z)
			  myHero:HoldPosition()
			end      
		  end
		 
		  function diceTarget(target)
			if Ecast == true and myHero:GetSpellData(_E).name == "renektondice" and target ~= nil then
			  --predictedPos = tp:GetPrediction(ts.target)
			  --CastSpell(_E,predictedPos.x,predictedPos.z)
			  CastSpell(_E,target.x, target.z)
			  myHero:HoldPosition()
			end  
		  end
		 
		 
		  function sliceMouse() --target
			if myHero:GetSpellData(_E).name == "RenektonSliceAndDice" and myHero:CanUseSpell(_E) == READY then
			  CastSpell(_E,mousePos.x, mousePos.z)
			  player:MoveTo(mousePos.x, mousePos.z)
			end
		  end
		 
		  function diceMouse() --target
			if myHero:GetSpellData(_E).name == "renektondice" and myHero:CanUseSpell(_E) == READY then
			  CastSpell(_E,mousePos.x, mousePos.z)
			  player:MoveTo(mousePos.x, mousePos.z)
			end
		  end
		 
		  --[[function OnAnimation(unit,animation)
			if unit.isMe and animation ~= nil and (animation:find"Spell2") or (animation:find"Spell2b") then
			  TMATSlot = (GetInventorySlotItem(3077) or GetInventorySlotItem(3074)) TMATREADY = (TMATSlot ~= nil and myHero:CanUseSpell(TMATSlot) == READY)
			  PrintChat("Animation name:" ..animation)
			  if myHero:CanUseSpell(_W) ~= READY and TMATREADY then
				CastSpell(TMATSlot)              
			  end
			end
		  end]]
		 
				function OnProcessSpell(unit, spell)  
						if unit.isMe then
			  if spell and spell.name:find("RenektonExecute") then
				orbWalk()    
			  end      
								if spell and spell.name:find("RenektonBasicAttack" or "RenektonCritAttack") then
										swing = 1
										lastBasicAttack = os.clock()
								end
			  if spell and spell.name:find("RenektonSliceAndDice") then  
										Ecast = true
				lastEcast = os.clock()
								end
			  if spell and spell.name:find("renektondice") then
										moveAfterE = true
				Ecast = false
				lastEcast = 0
								end
			  if ts.target and spell and (spell.name:find("ItemTiamatCleave") ~= nil) then    
				orbWalk()  
			  end
						end
				end
		 
		  function ItemsReady()
			YMGBSlot = GetInventorySlotItem(3142)
			TMATSlot = (GetInventorySlotItem(3077) or GetInventorySlotItem(3074)) TMATREADY = (TMATSlot ~= nil and myHero:CanUseSpell(TMATSlot) == READY)
			SotDSlot = GetInventorySlotItem(3131) SotDREADY = (SotDSlot ~= nil and myHero:CanUseSpell(SotDSlot) == READY)
			DFGSlot = GetInventorySlotItem(3128) DFGREADY = (DFGSlot ~= nil and myHero:CanUseSpell(DFGSlot) == READY)
			HXGSlot = GetInventorySlotItem(3146) HXGREADY = (HXGSlot ~= nil and myHero:CanUseSpell(HXGSlot) == READY)
			BWCSlot = (GetInventorySlotItem(3144)or GetInventorySlotItem(3153)) BWCREADY = (BWCSlot ~= nil and myHero:CanUseSpell(BWCSlot) == READY)
			SheenSlot = GetInventorySlotItem(3057)
			TrinitySlot = GetInventorySlotItem(3078)
			LichBaneSlot = GetInventorySlotItem(3100)
			ROSlot = GetInventorySlotItem(3143)
			ENTSlot = GetInventorySlotItem(3184)
			LOCKSlot = GetInventorySlotItem(3190)
		   
			YMGBREADY = (SotDSlot ~= nil and myHero:CanUseSpell(YMGBSlot) == READY)
			ROREADY = (ROSlot ~= nil and myHero:CanUseSpell(ROSlot) == READY)
			ENTREADY = (ENTSlot ~= nil and myHero:CanUseSpell(ENTSlot) == READY) -- , ENTSlot = GetInventorySlotItem(3184),
			LOCKREADY = (LOCKSlot ~= nil and myHero:CanUseSpell(LOCKSlot) == READY)  
		  end
		 
		  function Items()    
			if ts.target ~= nil then      
			  if BWCREADY and GetDistance(ts.target) <= 501 then CastSpell(BWCSlot, ts.target) end  
			  if DFGREADY then CastSpell(DFGSlot, ts.target) end
			  if HXGREADY then CastSpell(HXGSlot, ts.target) end
			  if BWCREADY and GetDistance(ts.target) <= 501 then CastSpell(BWCSlot, ts.target) end      
			  if ROREADY and GetDistance(ts.target) <= 485 and ts.target.type == "obj_AI_Hero" then CastSpell(ROSlot) end
			  if LOCKREADY and GetDistance(ts.target) <= 485 and ts.target.type == "obj_AI_Hero" then CastSpell(LOCKSlot) end
			  if swing == 1 then
				if YMGBREADY then -- YMGB
				  if ts.target.type == "obj_AI_Hero" and GetDistance(ts.target) < 400 then
					CastSpell(YMGBSlot)
				  end
				end
				if SotDREADY then
				  if ts.target.type == "obj_AI_Hero" and GetDistance(ts.target) < 400 then
					CastSpell(SotDSlot)
				  end
				end
				if ENTREADY then -- YMGB
				  if ts.target.type == "obj_AI_Hero" and GetDistance(ts.target) < 400 then
					CastSpell(ENTSlot)
				  end
				end      
			  end
			end
		  end
		 
		  function OnCreateObj(obj)
			TMATSlot = (GetInventorySlotItem(3077) or GetInventorySlotItem(3074)) TMATREADY = (TMATSlot ~= nil and myHero:CanUseSpell(TMATSlot) == READY)
			if swing == 1 and ts.target and obj and (obj.name:find("globalhit_bloodslash") ~= nil) and GetDistance(obj) > 1 and GetDistance(obj,ts.target) < 150 then  
			  aahit = true
			  if RCConfig.harass or RCConfig.scriptActive1 or (myHero.mana < 50 or myHero.mana > 99) or (RCConfig.scriptActive and myHero:CanUseSpell(_E) ~= READY) or (RCConfig.scriptActive2 and myHero:CanUseSpell(_Q) ~= READY) then    
				CastSpell(_W)
				myHero:Attack(ts.target)
			  end
			  if myHero:CanUseSpell(_W) ~= READY and TMATREADY then
				CastSpell(TMATSlot)              
			  end
			end
		  end
		 
		  function OnDeleteObj(obj)
			TMATSlot = (GetInventorySlotItem(3077) or GetInventorySlotItem(3074)) TMATREADY = (TMATSlot ~= nil and myHero:CanUseSpell(TMATSlot) == READY)
			if ts.target and obj and (obj.name:find("Renekton_Weapon_Hot.troy") ~= nil) and GetDistance(obj) < 100 and GetDistance(ts.target) < 450 then    
			  if TMATREADY then
				CastSpell(TMATSlot)              
			  end
			  if myHero:CanUseSpell(_W) == COOLDOWN and TMATREADY == false then
				orbWalk()
			  end
			end    
			if swing == 1 and ts.target and obj and (obj.name:find("globalhit_bloodslash") ~= nil) and GetDistance(obj) > 1 and GetDistance(obj,ts.target) < 150 then  
			  aahit = true
			  if RCConfig.harass or RCConfig.scriptActive1 or (myHero.mana < 50 or myHero.mana > 99) or (RCConfig.scriptActive and myHero:CanUseSpell(_E) ~= READY) or (RCConfig.scriptActive2 and myHero:CanUseSpell(_Q) ~= READY) then  
				CastSpell(_W)
				myHero:Attack(ts.target)
			  end
			  if myHero:CanUseSpell(_W) ~= READY and TMATREADY then
				CastSpell(TMATSlot)              
			  end
			end    
		  end
		 
		  function orbWalk()
			if ts.target ~= nil then
			  if AAmove == true then                  
				player:MoveTo(ts.target.x, ts.target.z)
				--PrintChat("ORB!")
				aahit = false          
				swing = 0
			  end
			  myHero:Attack(ts.target)        
			elseif ts.target == nil then
			  swing = 0
			  aahit = false
			end
		  end
			   
		 
		 
		function OnTick()
		 
		  if myHero.dead then
						return
				end
		  ts:update()
		  ItemsReady()
		 
		  if myHero.level == 6 or myHero.level == 11 or myHero.level == 16 then
			LevelSpell(_R)
		  end
		   
				if swing == 1 and os.clock() > lastBasicAttack + 0.5 then
						swing = 0    
			if aahit == true then
			  aahit = false      
			end
				end
		 
		  if Wcast == 1 and os.clock() > lastWcast + 1 then
						Wcast = 0
				end
		 
			   
		  E1 = myHero:GetSpellData(_E).name == "RenektonSliceAndDice" and myHero:CanUseSpell(_E) == READY
		  E2 = myHero:GetSpellData(_E).name == "renektondice" and myHero:CanUseSpell(_E) == READY
		 
				QREADY = (myHero:CanUseSpell(_Q) == READY)
				WREADY = (myHero:CanUseSpell(_W) == READY)
				EREADY = (myHero:CanUseSpell(_E) == READY)
				RREADY = (myHero:CanUseSpell(_R) == READY)
				IREADY = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
		 
		 
		   
		  if E1 then
			moveAfterE = false
			Ecast = false
		  end
		 
		 
		 
		  if (RCConfig.autoQ or RCConfig.scriptActive1 or RCConfig.harass) then
			if QREADY then
			  for i = 1, heroManager.iCount, 1 do
				local hero = heroManager:getHero(i)
				if ValidTarget(hero) and GetDistance(hero) < qrange and hero.team ~= myHero.team then
				  CastSpell(_Q)        
				end
			  end
			end
		  end
		 
		 
		   
		  AArange = (myHero.range + (GetDistance(myHero.minBBox, myHero.maxBBox)/2))
		 
		   
		  if (RCConfig.scriptActive or RCConfig.scriptActive1 or RCConfig.scriptActive2 or RCConfig.harass) and ts.target ~= nil and RCConfig.autoignite and IREADY then    
						local QWEDmg = RENDmgCalculation(ts.target)
						local IDmg = getDmg("IGNITE",ts.target,myHero)    
						if GetDistance(ts.target) < 600 and ts.target.health > QWEDmg and ts.target.health <= IDmg+QWEDmg then CastSpell(ignite, ts.target) end
				end  
		 
		 
		 
		  if RCConfig.scriptActive then  
		   
			if Wcast == 1 then
			  if ts.target ~= nil then
				if AAmove == true then          
				  player:MoveTo(ts.target.x, ts.target.z)
				  myHero:Attack(ts.target)          
				end        
				if os.clock() - lastWcast > WDelay  then
				  myHero:Attack(ts.target)
				  Wcast = 0
				end      
			  end
			end
		   
			if RCConfig.alt == true then
			  if E1 then
				sliceMouse()
			  end
			  if E2 and Ecast == true and os.clock() - lastEcast > 1 then
				diceMouse()
			  end
			end
		   
			if (myHero.mana < 50 or myHero.mana > 99 or EREADY == false) and RCConfig.autoQ == false and QREADY then  -- and (myHero.mana < 50 or myHero.mana > 99 or EREADY == false)
			  for i = 1, heroManager.iCount, 1 do
				local hero = heroManager:getHero(i)
				if ValidTarget(hero) and GetDistance(hero) < qrange and hero.team ~= myHero.team then        
				  CastSpell(_Q)        
				end
			  end
			end
		   
			if ts.target ~= nil then
			  if (myHero.mana < 50 or myHero.mana > 99 or EREADY == false) and QREADY and GetDistance(ts.target) < qrange and ts.target.type ~= "obj_AI_Hero" then      
				CastSpell(_Q)
			  end
			  Items()
					 
			  if E1 and (GetDistance(ts.target) > AArange and GetDistance(ts.target) < range) then
				myHero:Attack(ts.target)
				sliceTarget(ts.target)
			  end      
			  if E2 and Ecast == true and os.clock() - lastEcast > 1 and (GetDistance(ts.target) > AArange and GetDistance(ts.target) < range) then
				myHero:Attack(ts.target)
				diceTarget(ts.target)
			  end
			  if swing == 0 then
				if EREADY and GetDistance(ts.target) <= range + 150 then
				  myHero:Attack(ts.target)
				end
				if GetDistance(ts.target) <= AArange then
				  myHero:Attack(ts.target)
				  if YMGBREADY and GetDistance(ts.target) > AArange + 250 then -- YMGB
					if ts.target.type == "obj_AI_Hero" then
					  CastSpell(YMGBSlot)
					end
				  end
				end
			  elseif swing == 1 then
				if E1 and aahit == true then        
				  if GetDistance(ts.target) < range then
					myHero:Attack(ts.target)
					sliceTarget(ts.target)
					swing = 0
					aahit = false
				  end
				end
				if E2 and aahit == true then        
				  if GetDistance(ts.target) < range then
					myHero:Attack(ts.target)
					diceTarget(ts.target)
					swing = 0
					aahit = false
				  end
				end
				if WREADY == false and TMATREADY == false and aahit == true then
				  orbWalk()
				end
			  end
			end    
				end
		 
		 
		  if RCConfig.scriptActive1 then    
		   
			if Wcast == 1 then
			  if ts.target ~= nil then
				if AAmove == true then          
				  player:MoveTo(ts.target.x, ts.target.z)
				  myHero:Attack(ts.target)          
				end        
				if os.clock() - lastWcast > WDelay  then
				  myHero:Attack(ts.target)
				  Wcast = 0
				end      
			  end
			end
			if swing == 1 then      
			  if (myHero.mana < 50 or myHero.mana > 99 or QREADY == false) and WREADY and aahit == true then
				CastSpell(_W)
				swing = 0    
				aahit = false
			  end
			end  
		   
		 
			if ts.target ~= nil then
			 
			  if QREADY and GetDistance(ts.target) < qrange and ts.target.type ~= "obj_AI_Hero" then
				myHero:Attack(ts.target)
				CastSpell(_Q)
			  end
			 
			  Items()
			 
			  if RCConfig.alt == true then
			 
				if E1 and (GetDistance(ts.target) > AArange and GetDistance(ts.target) < range) then
				  myHero:Attack(ts.target)
				  sliceTarget(ts.target)
				end
			   
			 
			 
				if E2 and Ecast == true and os.clock() - lastEcast > 1 and(myHero.mana < 50 or myHero.mana > 99 or (QREADY == false and WREADY == false)) and (GetDistance(ts.target) > AArange and GetDistance(ts.target) < range) then
				  myHero:Attack(ts.target)
				  diceTarget(ts.target)
				end
			 
			  end
		   
			  if swing == 0 then
				if EREADY and GetDistance(ts.target) <= range + 150 then
				  myHero:Attack(ts.target)
				end      
				if GetDistance(ts.target) <= AArange then
				  myHero:Attack(ts.target)
				  if YMGBREADY and GetDistance(ts.target) > AArange + 250 then -- YMGB
					if ts.target.type == "obj_AI_Hero" then
					  CastSpell(YMGBSlot)
					end
				  end
				end
			  elseif swing == 1 then
			   
				if RCConfig.alt == true then
				  if E1 and aahit == true then        
					if GetDistance(ts.target) < range then
					  myHero:Attack(ts.target)
					  sliceTarget(ts.target)
					  swing = 0
					  aahit = false
					end
				  end
			   
				  if E2 and aahit == true then        
					if GetDistance(ts.target) < range and QREADY == false and WREADY == false then
					  myHero:Attack(ts.target)
					  diceTarget(ts.target)
					  swing = 0
					  aahit = false
					end
				  end
				end
			   
				if WREADY == false and TMATREADY == false and aahit == true then
				  orbWalk()
				end        
			  end
			end    
				end
		 
		 
		 
		 
		  if RCConfig.scriptActive2 then
		   
			if Wcast == 1 then
			  if ts.target ~= nil then
				if AAmove == true then          
				  player:MoveTo(ts.target.x, ts.target.z)
				  myHero:Attack(ts.target)          
				end        
				if os.clock() - lastWcast > WDelay  then
				  myHero:Attack(ts.target)
				  Wcast = 0
				end      
			  end
			end    
		   
			if swing == 1 then          
			  if WREADY and aahit == true then
				CastSpell(_W)
				swing = 0  
				aahit = false
			  end
			end  
			 
			if (myHero.mana < 50 or myHero.mana > 99 or WREADY == false) and QREADY then
			  for i = 1, heroManager.iCount, 1 do
				local hero = heroManager:getHero(i)
				if ValidTarget(hero) and GetDistance(hero) < qrange and hero.team ~= myHero.team then          
				  myHero:Attack(ts.target)
				  CastSpell(_Q)        
				end
			  end
			end
		 
			if ts.target ~= nil then
			 
			 if (myHero.mana < 50 or myHero.mana > 99 or EREADY == false) and QREADY and GetDistance(ts.target) < qrange and ts.target.type ~= "obj_AI_Hero" then
				myHero:Attack(ts.target)
				CastSpell(_Q)
			  end
			 
			  Items()
			   
			  if RCConfig.alt == true then
			 
				if E1 and (GetDistance(ts.target) > AArange and GetDistance(ts.target) < range) then
				  myHero:Attack(ts.target)
				  sliceTarget(ts.target)
				end
			   
			 
			 
				if E2 and Ecast == true and os.clock() - lastEcast > 1 and(myHero.mana < 50 or myHero.mana > 99 or (QREADY == false and WREADY == false)) and (GetDistance(ts.target) > AArange and GetDistance(ts.target) < range) then
				  myHero:Attack(ts.target)
				  diceTarget(ts.target)
				end
			 
			  end
		   
			  if swing == 0 then
				if EREADY and GetDistance(ts.target) <= range + 150 then
				  myHero:Attack(ts.target)
				end
				if GetDistance(ts.target) <= AArange then
				  myHero:Attack(ts.target)
				  if YMGBREADY and GetDistance(ts.target) > AArange + 250 then -- YMGB
					if ts.target.type == "obj_AI_Hero" then
					  CastSpell(YMGBSlot)
					end
				  end
				end
			  elseif swing == 1 then
			   
				if RCConfig.alt == true then
				  if E1 and aahit == true then        
					if GetDistance(ts.target) < range then
					  myHero:Attack(ts.target)
					  sliceTarget(ts.target)
					  swing = 0
					  aahit = false
					end
				  end
				  if (myHero.mana < 50 or myHero.mana > 99 or (QREADY == false and WREADY == false)) and E2 and aahit == true then        
					if GetDistance(ts.target) < range and QREADY == false and WREADY == false then
					  myHero:Attack(ts.target)
					  diceTarget(ts.target)
					  swing = 0
					  aahit = false
					end
				  end
				end
			   
				if WREADY == false and EREADY == false and TMATREADY == false and aahit == true then
				  orbWalk()
				end        
			  end
			end      
				end
		 
		 
		 
		 
		 
				if RCConfig.harass then
		   
			if Wcast == 1 then
			  if ts.target ~= nil then
				if AAmove == true then          
				  player:MoveTo(ts.target.x, ts.target.z)
				  myHero:Attack(ts.target)          
				end        
				if os.clock() - lastWcast > WDelay  then
				  myHero:Attack(ts.target)
				  Wcast = 0
				end      
			  end
			end
		   
			if moveAfterE == true then
			  player:MoveTo(mousePos.x, mousePos.z)
			end
		   
			if RCConfig.alt == true then
			  if E1 then
				sliceMouse()
			  end
			  if E2 and Ecast == true and os.clock() - lastEcast > 1 then
				diceMouse()
			  end
			end
		 
			if RCConfig.autoQ == false and QREADY then
			  for i = 1, heroManager.iCount, 1 do
				local hero = heroManager:getHero(i)
				if ValidTarget(hero) and GetDistance(hero) < qrange and hero.team ~= myHero.team then
				  CastSpell(_Q)        
				end
			  end
			end    
		 
			if ts.target ~= nil then
			  if QREADY and GetDistance(ts.target) < qrange and ts.target.type ~= "obj_AI_Hero" then
				myHero:Attack(ts.target)
				CastSpell(_Q)
			  end
		   
			  if E1 and GetDistance(ts.target) > AArange and GetDistance(ts.target) < range then
				myHero:Attack(ts.target)
				sliceTarget(ts.target)
			  end    
			  if swing == 1 then
				if E1 and aahit == true then        
				  if GetDistance(ts.target) < range then
					sliceTarget(ts.target)
					swing = 0
					aahit = false
				  end
				end
				if E2 and aahit == true then        
				  if GetDistance(ts.target) < range and QREADY == false and WREADY == false then
					diceMouse()
					swing = 0
					aahit = false
				  end
				end
			  end          
			end
				end
			   
		 
		 
		  if RCConfig.escape then
			player:MoveTo(mousePos.x, mousePos.z)
			if E1 then
			  sliceMouse()
			end
			if E2 and Ecast == true then
			  if os.clock() - lastEcast > 0.5 then
				diceMouse()
			  end
			end
		  end
		   
		 
				if RCConfig.autoAAFarm then
			enemyMinions:update()
						if mousemoving and GetTickCount() > nextTick then
								player:MoveTo(mousePos.x, mousePos.z)
						end                                            
						local tick = GetTickCount()
						for index, minion in pairs(enemyMinions.objects) do
			  if minion and minion.dead == false then
				local myAA = getDmg("AD",minion,myHero)
				if minion and minion.health <= myAA and GetDistance(minion) <= (player.range + scanAdditionalRange) and GetTickCount() > nextTick then
				  player:Attack(minion)
				  nextTick = GetTickCount() + waitDelay          
										end
								end    
						end
				end
		   
		end
		 
		 
		 
		function RENDmgCalculation(enemy)
		  local hitdamage = getDmg("AD",enemy,myHero)
				local qdamage = getDmg("Q",enemy,myHero)
				local wdamage = getDmg("W",enemy,myHero)
				local edamage = getDmg("E",enemy,myHero)
				local combo5 = 0
		 
		  if GetDistance(enemy) < 350 then
			combo5 = hitdamage
		  end
		  if QREADY and GetDistance(enemy) < range then
			combo5 = combo5 + qdamage + hitdamage        
		  end
		  if WREADY and GetDistance(enemy) < range then
						combo5 = combo5 + wdamage
				end
				if E1 and GetDistance(enemy) < range then
						combo5 = combo5 + edamage
				end
		  if E2 and GetDistance(enemy) < range then
						combo5 = combo5 + edamage
				end
				return combo5
		end
		 
		 
		function OnDraw()
				if myHero.dead == false then
						if RCConfig.drawcircles and QREADY then DrawCircle(myHero.x, myHero.y, myHero.z, qrange, 0x992D3D) end
						if RCConfig.drawcircles and EREADY then DrawCircle(myHero.x, myHero.y, myHero.z, range, 0x992D3D) end
						if ts.target ~= nil then
								DrawCircle(ts.target.x, ts.target.y, ts.target.z, (GetDistance(ts.target.minBBox, ts.target.maxBBox)/2), 0x00FF00)
						end
				end
		end
		 
		function OnSendChat(msg)
				ts:OnSendChat(msg, "pri")
		end
		PrintChat(" >> RAPEKTON v1.4 loaded!")
-------------------------------------------------------------------------------------------
	elseif myHero.charName == "Vayne" then

		--[[
						 _.--""--._
						/  _    _  \
					 _  ( (_\  /_) )  _
					{ \._\   /\   /_./ }
					/_"=-.}______{.-="_\
					 _  _.=("""")=._  _
					(_'"_.-"`~~`"-._"'_)
					 {_"            "_}
		 
				 Vayne's Mighty Assistant
							by Manciuszz.
		 
				 » Auto-Condemn = Automatically condemns enemy into walls, structures(inhibitors, towers, nexus).
					• Prediction[VIP ONLY]/No Prediction mode
		 
				 » Manual Condemn-Assistant = Draws a circle of predicted position after condemn.
					• Draw Arrow/Simple circle
		 
				 » Disable Auto-Condemn on certain champions in-game.
		]]
		 
		--[[
			» Some data out of the game files:
			VayneCondemn(Spell E) projectileSpeed = 2200.0 units/s
			VayneCondemn(Spell E) projectileName = vayne_E_mis.troy
			VayneCondemn(Spell E) range at all lvls = 715+ units
			VayneCondemn(Spell E) max Knockback range at all lvls = 450 units
			VayneCondemn(Spell E) channel time at all lvls = 0.25 miliseconds(probably true, but feels to high)
		]]
		 
		if myHero.charName ~= "Vayne" then return end
		require "MapPosition"
		 
		local VayneAssistant
		 
		local mapPosition = MapPosition()
		local enemyTable = GetEnemyHeroes()
		local tp = TargetPredictionVIP(1000, 2200, 0.25)
		local AllClassKey = 16
		 
		-- Code -------------------------------------------
		 
		function OnLoad()
			VayneAssistant = scriptConfig("Vayne's Mighty Assistant", "VayneAssistant")
			VayneAssistant:addParam("autoCondemn", "Auto-Condemn OnHold:", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte("T"))
			VayneAssistant:addParam("switchKey", "Switch key mode:", SCRIPT_PARAM_ONOFF, true)
		 
			VayneAssistant:addParam("BLANKSPACE", "", SCRIPT_PARAM_INFO, "")
			VayneAssistant:addParam("FeaturesNSettings", "              Features & Settings", SCRIPT_PARAM_INFO, "")
			VayneAssistant:addParam("CondemnAssistant", "Condemn Visual Assistant:", SCRIPT_PARAM_ONOFF, true)
			VayneAssistant:addParam("pushDistance", "Push Distance", SCRIPT_PARAM_SLICE, 300, 0, 450, 0) -- Reducing this value means that the enemy has to be closer to the wall, so you could cast condemn.
			VayneAssistant:addParam("eyeCandy", "DrawArrow/Simple circle:", SCRIPT_PARAM_ONOFF, true)
			if not VIP_USER then
				VayneAssistant:addParam("shootingMode", "Currently: No prediction", SCRIPT_PARAM_INFO, "NOT VIP")
			else
				VayneAssistant:addParam("shootingMode", "Prediction/No prediction", SCRIPT_PARAM_ONOFF, false)
			end
			VayneAssistant:addParam("wallDetection", "Intersection/Inside wall:", SCRIPT_PARAM_ONOFF, true)
		 
			-- Override in case it's stuck.
		--    VayneAssistant.pushDistance = 300
			VayneAssistant.autoCondemn = true
		 
			VayneAssistant:addParam("BLANKSPACE2", "", SCRIPT_PARAM_INFO, "")
			VayneAssistant:addParam("BLANKSPACE3", "          Disable Auto-Condemn on", SCRIPT_PARAM_INFO, "")
			for i, enemy in ipairs(enemyTable) do
				VayneAssistant:addParam("disableCondemn"..i, " >> "..enemy.charName, SCRIPT_PARAM_ONOFF, false)
				VayneAssistant["disableCondemn"..i] = false -- Override
			end
			PrintChat(" >> Vayne's Mighty Assistant!")
		end
		 
		function OnDraw()
			if myHero.dead then return end
		 
			if IsKeyDown(AllClassKey) then
				if VayneAssistant.switchKey then
					VayneAssistant._param[1].pType = 3
					VayneAssistant._param[1].text = "Auto-Condemn Toggle:"
				else
					VayneAssistant._param[1].pType = 2
					VayneAssistant._param[1].text = "Auto-Condemn OnHold:"
				end
		 
				VayneAssistant._param[7].text = VayneAssistant.eyeCandy and "Currently: Drawing Arrows" or "Currently: Drawing Circles"
				VayneAssistant._param[8].text = VayneAssistant.shootingMode and VIP_USER and "Currently: Using Predictions" or "Currently: No prediction"
				VayneAssistant._param[9].text = VayneAssistant.wallDetection and "Currently: Using Intersection Method" or "Currently: Using Simple Wall Check"
				if not VIP_USER then VayneAssistant.shootingMode = "NOT VIP" end
			end
		 
			if VayneAssistant.autoCondemn and myHero:CanUseSpell(_E) == READY then
				local casted = false
				for i, enemyHero in ipairs(enemyTable) do
					if not VayneAssistant["disableCondemn"..i] then
						if not casted then
							if enemyHero ~= nil and enemyHero.valid and not enemyHero.dead and enemyHero.visible and GetDistance(enemyHero) <= 715 then
		 
								local enemyPosition = VayneAssistant.shootingMode and VIP_USER and tp:GetPrediction(enemyHero) or enemyHero
								local PushPos = GetDistance(enemyPosition) > 65 and enemyPosition + (Vector(enemyHero) - myHero):normalized()*(VayneAssistant.pushDistance) or nil
		 
								if PushPos ~= nil and enemyPosition ~= nil then
									local enemyHeroPoint     = Point(enemyPosition.x, enemyPosition.z)
									local condemnPoint       = Point(PushPos.x, PushPos.z)
									local condemnLineSegment = LineSegment(enemyHeroPoint, condemnPoint)
									local wallDetection      = VayneAssistant.wallDetection and mapPosition:intersectsWall(condemnLineSegment) or mapPosition:inWall(condemnPoint)
		 
									if PushPos ~= nil and VayneAssistant.eyeCandy then
										DrawArrows(enemyPosition, PushPos, 80, 0xFFFFFF, 0)
									else
										DrawCircle(PushPos.x, PushPos.y, PushPos.z, 65, 0xFFFF00)
									end
		 
									if wallDetection then
										CastSpell(_E, enemyHero)
										casted = true
									end
								end
							end
						end
					end
				end
			end
		end
	end
--end