if GetGame().map.name == "Howling Abyss" then

	if GetMyHero().charName == "Ashe" or GetMyHero().charName == "Caitlyn" or GetMyHero().charName == "Corki" or GetMyHero().charName == "Draven" or GetMyHero().charName == "Ezreal" or GetMyHero().charName == "Caitlyn" or GetMyHero().charName == "Graves" or GetMyHero().charName == "Kogmaw" or GetMyHero().charName == "Miss Fortune" or GetMyHero().charName == "Quinn" or GetMyHero().charName == "Sivir" or GetMyHero().charName == "Tristana" or GetMyHero().charName == "Twitch" or GetMyHero().charName == "Varus" or GetMyHero().charName == "Vayne" or GetMyHero().charName == "Lucian" then





		--[[
						Sida's Auto Carry: Revamped
										v4.9
		]]--
		 
		--[[ Configuration ]]--
		 
		local AutoCarryKey = 32
		local LastHitKey = string.byte("X")
		local MixedModeKey = string.byte("C")
		local LaneClearKey = string.byte("V")

		------------ > Don't touch anything below here < --------------
		 
		--[[ Vars ]] --
		local projSpeed = 0
		local startAttackSpeed = 0.665
		local attackDelayOffset = 600
		local lastAttack = 0
		local projAt = 0
		local Skills
		local enemyMinions
		local allyMinions
		local lastEnemy
		local lastRange
		local killableMinion
		local pluginMinion
		local minionInfo = {}
		local incomingDamage = {}
		local jungleMobs = {}
		local turretMinion = {timeToHit = 0, obj = nil}
		local isMelee = myHero.range < 300
		local movementStopped = false
		local hasPlugin = false
		local nextClick = 500
		local TimedMode = false
		local Tristana = false
		local hudDisabled = false
		local ChampInfo = {}
		local useVIPCol = false
		local lastAttacked = nil
		local previousWindUp = 0
		local previousAttackCooldown = 0
		_G.AutoCarry = _G

		 
		--[[ Global Vars : Can be used by plugins ]]--
		AutoCarry.Orbwalker = nil
		AutoCarry.SkillsCrosshair = nil
		AutoCarry.CanMove = true
		AutoCarry.CanAttack = true
		AutoCarry.MainMenu = nil
		AutoCarry.PluginMenu = nil
		AutoCarry.EnemyTable = nil
		AutoCarry.shotFired = false
		AutoCarry.OverrideCustomChampionSupport = false
		 
		--[[ Global Functions ]]--
		function getTrueRange()
			return myHero.range + GetDistance(myHero.minBBox)
		end
		 
		function attackEnemy(enemy)
			if CustomAttackEnemy then CustomAttackEnemy(enemy) return end
			if enemy.dead or not enemy.valid or not AutoCarry.CanAttack then return end
			myHero:Attack(enemy)
			lastAttacked = enemy
			AutoCarry.shotFired = true
		end
		 
		function getHitBoxRadius(target)
			return GetDistance(target.minBBox, target.maxBBox)/2
		end
		 
		function timeToShoot()
			return (GetTickCount() + GetLatency()/2 > lastAttack + previousAttackCooldown)
		end
		 
		function attackedSuccessfully()
			projAt = GetTickCount()
			if OnAttacked then OnAttacked() end
		end
		 
		function heroCanMove()
			return (GetTickCount() + GetLatency()/2 > lastAttack + previousWindUp + 20 + 30)
		end
		 
		function setMovement()
			if GetDistance(mousePos) <= AutoCarry.MainMenu.HoldZone and (AutoCarry.MainMenu.AutoCarry or AutoCarry.MainMenu.LastHit or AutoCarry.MainMenu.MixedMode or AutoCarry.MainMenu.LaneClear) then
				if not movementStopped then
					myHero:HoldPosition()
					movementStopped = true
				end
				AutoCarry.CanMove = false
			else
				movementStopped = false
				AutoCarry.CanMove = true
			end
		end
		 
		function moveToCursor(range)
			if not disableMovement and AutoCarry.CanMove then
				local moveDist = 480 + (GetLatency()/10)
				if not range then
					if isMelee and AutoCarry.Orbwalker.target and AutoCarry.Orbwalker.target.type == myHero.type and GetDistance(AutoCarry.Orbwalker.target) < 80 then 
						attackEnemy(AutoCarry.Orbwalker.target)
						return
					elseif GetDistance(mousePos) < moveDist and GetDistance(mousePos) > 100 then 
						moveDist = GetDistance(mousePos) 
					end
				end
				local moveSqr = math.sqrt((mousePos.x - myHero.x)^2+(mousePos.z - myHero.z)^2)
				local moveX = myHero.x + (range and range or moveDist)*((mousePos.x - myHero.x)/moveSqr)
				local moveZ = myHero.z + (range and range or moveDist)*((mousePos.z - myHero.z)/moveSqr)
				if StreamingMenu.MinRand > StreamingMenu.MaxRand then
					PrintChat("You must set Max higher than Min in streaming menu")
				elseif StreamingMenu.ShowClick and GetTickCount() > nextClick then
					if StreamingMenu.Colour == 0 then
						ShowGreenClick(mousePos)
					else
						ShowRedClick(mousePos)
					end
					nextClick = GetTickCount() + math.random(StreamingMenu.MinRand, StreamingMenu.MaxRand)
				end
				myHero:MoveTo(moveX, moveZ)
			end
		end
		 
		--[[ Orbwalking ]]--
		 
		function OrbwalkingOnLoad()
			AutoCarry.Orbwalker = TargetSelector(TARGET_LOW_HP_PRIORITY, getTrueRange(), DAMAGE_PHYSICAL, false)
			AutoCarry.Orbwalker:SetBBoxMode(true)
			AutoCarry.Orbwalker:SetDamages(0, myHero.totalDamage, 0)
			AutoCarry.Orbwalker.name = "AutoCarry"
			lastRange = getTrueRange()
			if ChampInfo ~= nil then
				 if ChampInfo.projSpeed ~= nil then
					 projSpeed = ChampInfo.projSpeed
				 end
			end
		end
		 
		function OrbwalkingOnTick()
			AutoCarry.Orbwalker.targetSelected = AutoCarry.MainMenu.Focused
			if GetTickCount() + GetLatency()/2 > lastAttack + previousWindUp + 20 and GetTickCount() + GetLatency()/2 < lastAttack + previousWindUp + 400 then attackedSuccessfully() end
			isMelee = myHero.range < 300
			if myHero.range ~= lastRange then
					AutoCarry.Orbwalker.range = myHero.range
					lastRange = myHero.range
			end
			AutoCarry.Orbwalker:update()
		end
		 
		function OrbwalkingOnProcessSpell(unit, spell)
			if myHero.dead then return end
			
			if unit.isMe and (spell.name:lower():find("attack") or isSpellAttack(spell.name)) and not isNotAttack(spell.name) then
				lastAttack = GetTickCount() - GetLatency()/2
				previousWindUp = spell.windUpTime*1000
				previousAttackCooldown = spell.animationTime*1000
			elseif unit.isMe and refreshAttack(spell.name) then
				lastAttack = GetTickCount() - GetLatency()/2 - previousAttackCooldown
			end
		end

		function refreshAttack(spellName)
			return (
				--Blitzcrank
				spellName == "PowerFist"
				--Darius
				or spellName == "DariusNoxianTacticsONH"
				--Nidalee
				or spellName == "Takedown"
				--Sivir
				or spellName == "Ricochet"
				--Teemo
				or spellName == "BlindingDart"
				--Vayne
				or spellName == "VayneTumble"
				--Jax
				or spellName == "JaxEmpowerTwo"
				--Mordekaiser
				or spellName == "MordekaiserMaceOfSpades"
				--Nasus
				or spellName == "SiphoningStrikeNew"
				--Rengar
				or spellName == "RengarQ"
				--Wukong
				or spellName == "MonkeyKingDoubleAttack"
				--Yorick
				or spellName == "YorickSpectral"
				--Vi
				or spellName == "ViE"
				--Garen
				or spellName == "GarenSlash3"
				--Hecarim
				or spellName == "HecarimRamp"
				--XinZhao
				or spellName == "XenZhaoComboTarget"
				--Leona
				or spellName == "LeonaShieldOfDaybreak"
				--Shyvana
				or spellName == "ShyvanaDoubleAttack"
				or spellName == "shyvanadoubleattackdragon"
				--Talon
				or spellName == "TalonNoxianDiplomacy"
				--Trundle
				or spellName == "TrundleTrollSmash"
				--Volibear
				or spellName == "VolibearQ"
				--Poppy
				or spellName == "PoppyDevastatingBlow"
			)
		end

		function isSpellAttack(spellName)
			return (
				--Ashe
				spellName == "frostarrow"
				--Caitlyn
				or spellName == "CaitlynHeadshotMissile"
				--Quinn
				or spellName == "QuinnWEnhanced"
				--Trundle
				or spellName == "TrundleQ"
				--XinZhao
				or spellName == "XenZhaoThrust"
				or spellName == "XenZhaoThrust2"
				or spellName == "XenZhaoThrust3"
				--Garen
				or spellName == "GarenSlash2"
				--Renekton
				or spellName == "RenektonExecute"
				or spellName == "RenektonSuperExecute"
			)
		end
		function isNotAttack(spellName)
			return (
				--Shyvana
				spellName == "shyvanadoubleattackdragon"
				or spellName == "ShyvanaDoubleAttack"
				--MonkeyKing
				or spellName == "MonkeyKingDoubleAttack"
				--JarvanIV
				--or spellName == "JarvanIVCataclysmAttack"
				--or spellName == "jarvanivcataclysmattack"
			)
		end
		 
		function OrbwalkingOnDraw()
				if DisplayMenu.target and AutoCarry.Orbwalker.target ~= nil then
						for j=0, 5 do
								DrawCircle(AutoCarry.Orbwalker.target.x, AutoCarry.Orbwalker.target.y, AutoCarry.Orbwalker.target.z, 100 + j, 0x00FF00)
						end
						DrawCircle(AutoCarry.Orbwalker.target.x, AutoCarry.Orbwalker.target.y, AutoCarry.Orbwalker.target.z, GetDistance(AutoCarry.Orbwalker.target, AutoCarry.Orbwalker.target.minBBox), 0xFFFFFF)
				elseif DisplayMenu.target and AutoCarry.SkillsCrosshair.target then
						for j=0, 5 do
								DrawCircle(AutoCarry.SkillsCrosshair.target.x, AutoCarry.SkillsCrosshair.target.y, AutoCarry.SkillsCrosshair.target.z, 100 + j, 0x990000)
						end
						DrawCircle(AutoCarry.SkillsCrosshair.target.x, AutoCarry.SkillsCrosshair.target.y, AutoCarry.SkillsCrosshair.target.z, GetDistance(AutoCarry.SkillsCrosshair.target, AutoCarry.SkillsCrosshair.target.minBBox), 0xFFFFFF)
				end
		end
		 
		function EnemyInRange(enemy)
				if ValidBBoxTarget(enemy, getTrueRange()) then
						return true
				end
			return false
		end
		 
		--[[ Last Hitting ]]--
		 
		function LastHitOnLoad()
			minionInfo[(myHero.team == 100 and "Blue" or "Red").."_Minion_Basic"] =      { aaDelay = 400, projSpeed = 0    }
			minionInfo[(myHero.team == 100 and "Blue" or "Red").."_Minion_Caster"] =     { aaDelay = 484, projSpeed = 0.68 }
			minionInfo[(myHero.team == 100 and "Blue" or "Red").."_Minion_Wizard"] =     { aaDelay = 484, projSpeed = 0.68 }
			minionInfo[(myHero.team == 100 and "Blue" or "Red").."_Minion_MechCannon"] = { aaDelay = 365, projSpeed = 1.18 }
			minionInfo.obj_AI_Turret =                                         { aaDelay = 150, projSpeed = 1.14 }
		   
			for i = 0, objManager.maxObjects do
				local obj = objManager:getObject(i)
				for _, mob in pairs(getJungleMobs()) do
					if obj and obj.valid and obj.name:find(mob) then
						table.insert(jungleMobs, obj)
					end
				end
			end
		end
		 
		function LastHitOnTick()
			if AutoCarry.MainMenu.LastHit or AutoCarry.MainMenu.MixedMode or AutoCarry.MainMenu.LaneClear then
				enemyMinions:update()
				allyMinions:update()
			end
		end
		 
		function LastHitOnProcessSpell(object, spell)
			if not isMelee and isAllyMinionInRange(object) then
				for i,minion in pairs(enemyMinions.objects) do
					if ValidTarget(minion) and minion ~= nil and GetDistance(minion, spell.endPos) < 3 then
						if object ~= nil and (minionInfo[object.charName] or object.type == "obj_AI_turret") then
							incomingDamage[object.name] = getNewAttackDetails(object, minion)
						end
						--if object.type == "obj_AI_Turret" and object.team == myHero.team then
							--if FarmMenu.Predict then
									--handleTurretShot(object, minion)
							--end
						--end
					end
				end
			end
		end
		 
		function LastHitOnCreateObj(obj)
			for _, mob in pairs(getJungleMobs()) do
				if obj.name:find(mob) then
					table.insert(jungleMobs, obj)
				end
			end
		end
		 
		function LastHitOnDeleteObj(obj)
			for i, mob in pairs(getJungleMobs()) do
				if obj and obj.valid and mob and mob.valid and obj.name:find(mob.name) then
					table.remove(jungleMobs, i)
				end
			end
		end
		 
		function getJungleMinion()
			for _, mob in pairs(jungleMobs) do
				if ValidTarget(mob) and GetDistance(mob) <= getTrueRange() then return mob end
			end
			return nil
		end
		 
		function LastHitOnDraw()
			if DisplayMenu.minion and enemyMinions.objects[1] and ValidTarget(enemyMinions.objects[1]) and not isMelee then
				DrawCircle(enemyMinions.objects[1].x, enemyMinions.objects[1].y, enemyMinions.objects[1].z, 100, 0x19A712)
			end
		end
		 
		function getTimeToHit(enemy, speed)
			return (( GetDistance(enemy) / speed ) + GetLatency()/2)
		end
		 
		function isAllyMinionInRange(minion)
			if minion ~= nil and minion.team == myHero.team
				and (minion.type == "obj_AI_Minion" or minion.type == "obj_AI_Turret")
				and GetDistance(minion) <= 2000 then return true
			else return false end
		end
		 
		function getMinionDelay(minion)
			return ( minion.type == "obj_AI_Turret" and minionInfo.obj_AI_Turret.aaDelay or minionInfo[minion.charName].aaDelay )
		end
		 
		function getMinionProjSpeed(minion)
			return ( minion.type == "obj_AI_Turret" and minionInfo.obj_AI_Turret.projSpeed or minionInfo[minion.charName].projSpeed )
		end
		 
		function minionSpellStillViable(attack)
			if attack == nil then return false end
			local sourceMinion = getAllyMinion(attack.sourceName)
			local targetMinion = getEnemyMinion(attack.targetName)
			if sourceMinion == nil or targetMinion == nil then return false end
			if sourceMinion.dead or targetMinion.dead or GetDistance(sourceMinion, attack.origin) > 3 then return false else return true end
		end
		 
		function getAllyMinion(name)
			for i, minion in pairs(allyMinions.objects) do
				if minion ~= nil and minion.valid and minion.name == name then
					return minion
				end
			end
			return nil
		end
		 
		function getEnemyMinion(name)
			for i, minion in pairs(enemyMinions.objects) do
				if minion ~= nil and ValidTarget(minion) and minion.name == name then
					return minion
				end
			end
			return nil
		end
		 
		function isSameMinion(minion1, minion2)
			if minion1.networkID == minion2.networkID then return true
			else return false end
		end
		 
		function getMinionTimeToHit(minion, attack)
			local sourceMinion = getAllyMinion(attack.sourceName)
			return ( attack.speed == 0 and ( attack.delay ) or ( attack.delay + GetDistance(sourceMinion, minion) / attack.speed ) )
		end
		 
		function getNewAttackDetails(source, target)
			return  {
					sourceName = source.name,
					targetName = target.name,
					damage = source:CalcDamage(target),
					started = GetTickCount(),
					origin = { x = source.x, z = source.z },
					delay = getMinionDelay(source),
					speed = getMinionProjSpeed(source),
					sourceType = source.type}
		end
			
		function getPredictedDamage(counter, minion, attack)
			if not minionSpellStillViable(attack) then
				incomingDamage[counter] = nil
			elseif isSameMinion(minion, getEnemyMinion(attack.targetName)) then
				local myTimeToHit = getTimeToHit(minion, projSpeed)
				minionTimeToHit = getMinionTimeToHit(minion, attack)
				if GetTickCount() >= (attack.started + minionTimeToHit) then
					incomingDamage[counter] = nil
				elseif GetTickCount() + myTimeToHit > attack.started + minionTimeToHit then
					return attack.damage
				end
			end
			return 0
		end
		 
		function getKillableCreep(iteration)
			if isMelee then return meleeLastHit() end
			local minion = enemyMinions.objects[iteration]
			if minion ~= nil then
				local distanceToMinion = GetDistance(minion)
				local predictedDamage = 0
				if distanceToMinion < getTrueRange() then
					if FarmMenu.Predict then
						for l, attack in pairs(incomingDamage) do
							predictedDamage = predictedDamage + getPredictedDamage(l, minion, attack)
						end
					end
					local myDamage = myHero:CalcDamage(minion, myHero.totalDamage) + getBonusLastHitDamage(minion) + LastHitPassiveDamage()
					myDamage = (MasteryMenu.Executioner and myDamage * 1.05 or myDamage)
					myDamage = myDamage - 10
					--if minion.health - predictedDamage <= 0 then
							--return getKillableCreep(iteration + 1)
					if minion.health + 1.2 - predictedDamage < myDamage then
							return minion
					--elseif minion.health + 1.2 - predictedDamage < myDamage + (0.5 * predictedDamage) then
					--		return nil
					end
				end
			end
			return nil
		end

		function getBonusLastHitDamage(minion)
			if PluginBonusLastHitDamage then 
				return PluginBonusLastHitDamage(minion)
			elseif BonusLastHitDamage then
				return BonusLastHitDamage(minion)
			else
				return 0
			end
		end
		 
		function meleeLastHit()
				for _, minion in pairs(enemyMinions.objects) do
						local aDmg = getDmg("AD", minion, myHero)
						if GetDistance(minion) <= (myHero.range + 75) then
								if minion.health < aDmg then
										return minion
								end            
						end
				end
		end
		 
		function LastHitPassiveDamage(minion)
				if PluginLastHitPassiveDamage then return PluginLastHitPassiveDamage(minion) end
				local bonus = 0
				if GetInventoryHaveItem(3153) then
						if ValidTarget(minion) then
								bonus = minion.health / 20
								if bonus >= 60 then
										bonus = 60
								end
						end
				end
				bonus = bonus + (MasteryMenu.Butcher * 2)
				bonus = (MasteryMenu.Spellblade and bonus + (myHero.ap * 0.05) or 0)
				return bonus
		end
		 
		function getHighestMinion()
			if GetTarget() ~= nil then
				local currentTarget = GetTarget()
				local validTarget = false
				validTarget = ValidTarget(currentTarget, getTrueRange(), player.enemyTeam)
				if validTarget and (currentTarget.type == "obj_BarracksDampener" or currentTarget.type == "obj_HQ" or currentTarget.type == "obj_AI_Turret") then
					return currentTarget
				end
			end

			local highestHp = {obj = nil, hp = 0}
			for _, tMinion in pairs(enemyMinions.objects) do
				if GetDistance(tMinion) <= getTrueRange() and tMinion.health > highestHp.hp then
						highestHp = {obj = tMinion, hp = tMinion.health}
				end
			end
			return highestHp.obj
		end
		 
		function getPredictedDamageOnMinion(minion)
				local predictedDamage = 0
				if minion ~= nil then
						local distanceToMinion = GetDistance(minion)
						if distanceToMinion < getTrueRange() then
								for l, attack in pairs(incomingDamage) do
										if attack.sourceType ~= "obj_AI_Turret" then
												predictedDamage = predictedDamage + getPredictedDamage(l, minion, attack)
										end
								end
						end
				end
				return predictedDamage
		end
		 
		function handleTurretShot(turret, minion)
				local dmg = turret:CalcDamage(minion)
				local myDmg = myHero:CalcDamage(minion, myHero.totalDamage) + (BonusLastHitDamage and BonusLastHitDamage(minion) or 0) + LastHitPassiveDamage()
				myDmg = (MasteryMenu.Executioner and myDmg * 1.05 or myDmg)
				local predic = getPredictedDamageOnMinion(minion)
				if minion.health > myDmg + dmg + predic and minion.health < (myDmg * 2) + dmg + predic then
						turretMinion = {timeToHit = minionInfo.obj_AI_Turret.aaDelay + GetDistance(turret, minion) / minionInfo.obj_AI_Turret.projSpeed, obj = minion }
				end
		end
		 
		--[[ Abilities ]]--
		function SkillsOnLoad()
				Skills = getSpellList()
				if Skills == nil then
						AutoCarry.SkillsCrosshair = TargetSelector(TARGET_LOW_HP_PRIORITY, 0, DAMAGE_PHYSICAL, false)
						return
				end
				local maxRange = 0
				for _, skill in pairs(Skills) do
						if skill.range > maxRange then maxRange = skill.range end
				end
				AutoCarry.SkillsCrosshair = TargetSelector(TARGET_LOW_HP_PRIORITY, maxRange, DAMAGE_PHYSICAL, false)
		end
		 
		function SkillsOnTick()
				if Skills == nil then return end
				local target = AutoCarry.GetAttackTarget()
				if ValidTarget(target) and target.type == myHero.type then
						for _, skill in pairs(Skills) do
						if  (AutoCarry.MainMenu.AutoCarry and SkillsMenu[skill.configName.."AutoCarry"]) or
								(AutoCarry.MainMenu.MixedMode and SkillsMenu[skill.configName.."MixedMode"]) then
										if not skill.reset or (skill.reset and GetTickCount() < projAt + 400) then
												if skill.skillShot then
														AutoCarry.CastSkillshot(skill, target)
												elseif skill.reqTarget == false and not skill.atMouse then
														CastSelf(skill, target)
												elseif skill.reqTarget == false and skill.atMouse then
														CastMouse(skill)
												else
														CastTargettedSpell(skill, target)
												end
										end
								end
						end
				end
		end
		 
		AutoCarry.GetCollision = function (skill, source, destination)
			if VIP_USER and useVIPCol then
				local col = Collision(skill.range, skill.speed*1000, skill.delay/1000, skill.width)
				return col:GetMinionCollision(source, destination)
			else
				return willHitMinion(destination, skill.width)
			end
		end
		 
		AutoCarry.CastSkillshot = function (skill, target)
			if VIP_USER then
				pred = TargetPredictionVIP(skill.range, skill.speed*1000, skill.delay/1000, skill.width)
			elseif not VIP_USER then
				pred = TargetPrediction(skill.range, skill.speed, skill.delay, skill.width)
			end
			local predPos = pred:GetPrediction(target)
			if predPos and GetDistance(predPos) <= skill.range then
				if VIP_USER and pred:GetHitChance(target) > SkillsMenu.hitChance/100 then
					if not skill.minions or not AutoCarry.GetCollision(skill, myHero, predPos) then
						CastSpell(skill.spellKey, predPos.x, predPos.z)
					end
				elseif not VIP_USER then
					if not skill.minions or not AutoCarry.GetCollision(skill, myHero, predPos) then
						CastSpell(skill.spellKey, predPos.x, predPos.z)
					end
				end
			end
		end

		AutoCarry.GetPrediction = function(skill, target)
			if VIP_USER then
				pred = TargetPredictionVIP(skill.range, skill.speed*1000, skill.delay/1000, skill.width)
			elseif not VIP_USER then
				pred = TargetPrediction(skill.range, skill.speed, skill.delay, skill.width)
			end
			return pred:GetPrediction(target)
		end

		AutoCarry.IsValidHitChance = function(skill, target)
			if VIP_USER then
				pred = TargetPredictionVIP(skill.range, skill.speed*1000, skill.delay/1000, skill.width)
				return pred:GetHitChance(target) > SkillsMenu.hitChance/100 and true or false
			elseif not VIP_USER then
				return true
			end
		end

		AutoCarry.GetNextAttackTime = function()
			return (lastAttack + previousAttackCooldown) - GetLatency()/2
		end
		 
		function CastTargettedSpell(skill, target)
				if GetDistance(target) <= skill.range then
						CastSpell(skill.spellKey, target)
				end
		end
		 
		function CastMouse(skill)
				CastSpell(skill.spellKey, mousePos.x, mousePos.z)
		end
		 
		function CastSelf(skill, target)
				if not skill.forceRange or (skill.forceRange and GetDistance(target) - (skill.forceToHitBox and GetDistance(target, target.minBBox) or 0) <= skill.range) then
						CastSpell(skill.spellKey)
				end
		end
		 
		function getPrediction(speed, delay, target)
				if target == nil then return nil end
				local travelDuration = (delay + GetDistance(myHero, target)/speed)
				travelDuration = (delay + GetDistance(GetPredictionPos(target, travelDuration))/speed)
				travelDuration = (delay + GetDistance(GetPredictionPos(target, travelDuration))/speed)
				travelDuration = (delay + GetDistance(GetPredictionPos(target, travelDuration))/speed)  
				return GetPredictionPos(target, travelDuration)
		end
		 
		function willHitMinion(predic, width)
			for _, minion in pairs(enemyMinions.objects) do
				if minion ~= nil and minion.valid and string.find(minion.name,"Minion_") == 1 and minion.team ~= player.team and minion.dead == false then
					if predic ~= nil then
						ex = player.x
						ez = player.z
						tx = predic.x
						tz = predic.z
						dx = ex - tx
						dz = ez - tz
						if dx ~= 0 then
							m = dz/dx
							c = ez - m*ex
						end
						mx = minion.x
						mz = minion.z
						distanc = (math.abs(mz - m*mx - c))/(math.sqrt(m*m+1))
						if distanc < width and math.sqrt((tx - ex)*(tx - ex) + (tz - ez)*(tz - ez)) > math.sqrt((tx - mx)*(tx - mx) + (tz - mz)*(tz - mz)) then
							return true
						end
					end
				end
			end
			return false
		end
		 
		--[[ Champion Specific ]]--
		 
		function LoadCustomChampionSupport()
					-- >> Vayne << --
			if myHero.charName == "Vayne" then
					function BonusLastHitDamage()
							if myHero:GetSpellData(_Q).level > 0 and myHero:CanUseSpell(_Q) == SUPRESSED then
						return math.round( ((0.05*myHero:GetSpellData(_Q).level) + 0.25 )*myHero.totalDamage )
					end
							return 0
					end
				   
					-- >> Teemo << --
			elseif myHero.charName == "Teemo" then
					function BonusLastHitDamage()
							if myHero:GetSpellData(_E).level > 0 then
						return math.floor( (myHero:GetSpellData(_E).level * 10) + (myHero.ap * 0.3) )
					end
							return 0
					end    
					-- >> Corki << --
			elseif myHero.charName == "Corki" then
					function BonusLastHitDamage()
							return myHero.totalDamage/10
					end
					 
					-- >> Miss Fortune << --
			elseif myHero.charName == "MissFortune" then
					function BonusLastHitDamage()
							if myHero:GetSpellData(_W).level > 0 then
									return (4+2*myHero:GetSpellData(_W).level) + (myHero.ap/20)
							end
							return 0
					end
				   
					-- >> Varus << --
			elseif myHero.charName == "Varus" then
					function BonusLastHitDamage()
							if myHero:GetSpellData(_W).level > 0 then
									return (6 + (myHero:GetSpellData(_W).level * 4) + (myHero.ap * 0.25))
							end
							return 0
					end
			 
					-- >> Caitlyn << --
			elseif myHero.charName == "Caitlyn" then
					local headShotPart
					function CustomOnCreateObj(obj)
							if GetDistance(obj) < 100 and obj.name:lower():find("caitlyn_headshot_rdy") then
									headShotPart = obj
							end
					end
				   
					function BonusLastHitDamage(minion)
							if headShotPart and headShotPart.valid and minion and ValidTarget(minion) then
									return myHero:CalcDamage(minion, myHero.totalDamage) * 1.5
							end
							return 0
					end
			 
					-- >> Tristana << --
			elseif myHero.charName == "Tristana" then
					function CustomOnTick()
							Skills[2].range = myHero.range
					end
				   
					-- >> KogMaw << --
			elseif myHero.charName == "KogMaw" then
					function CustomOnTick()
							Skills[2].range = getTrueRange() + 110 + (myHero:GetSpellData(_W).level * 20)
							if myHero:GetSpellData(_R).level == 1 then
									Skills[4].range = 1400
							elseif myHero:GetSpellData(_R).level == 2 then
									Skills[4].range = 1700
							elseif myHero:GetSpellData(_R).level == 3 then
									Skills[4].range = 2200
							end
					end
				   
					-- >> Twisted Fate << --
			elseif myHero.charName == "TwistedFate" then
					local tfLastUse = 0
					TFConfig = scriptConfig("Sida's Auto Carry: Twisted Fate Edition", "autocarrytf")
					TFConfig:addParam("selectgold", "Select Gold", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("W"))
					TFConfig:addParam("selectblue", "Select Blue", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("E"))
					TFConfig:addParam("selectred", "Select Red", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("V"))
					TFConfig:addParam("qStunned", "Auto Q Stunned Enemies", SCRIPT_PARAM_ONOFF, true)
				   
					function CustomOnTick()
							PickACard()
							if TFConfig.qStunned then
									for _, enemy in pairs(AutoCarry.EnemyTable) do
											if ValidTarget(enemy) and not enemy.canMove and GetDistance(enemy) < 1350 then
													CastSpell(_Q, enemy.x, enemy.z)
											end
									end
							end
					end
				   
					function PickACard()
							if myHero:CanUseSpell(_W) == READY and GetTickCount()-tfLastUse <= 2300 then
									if myHero:GetSpellData(_W).name == selected then CastSpellEx(_W) end
							end
							if myHero:CanUseSpell(_W) == READY and GetTickCount()-tfLastUse >= 2400 then
									if TFConfig.selectgold then selected = "goldcardlock"
									elseif TFConfig.selectblue then selected = "bluecardlock"
									elseif TFConfig.selectred then selected = "redcardlock"
									else return end
									CastSpellEx(_W)
									tfLastUse = GetTickCount()
							end
					end
			 
					-- >> Draven << --
			elseif myHero.charName == "Draven" then
					local reticles = {}
					local qStacks = 0
					local closestReticle
					local qBuff = 0
					local stopped = false
					local qRad = 150
					disableRangeDraw = true
					local qParticles = {"Draven_Q_mis",
													"Draven_Q_mis_bloodless",
													"Draven_Q_mis_shadow",
													"Draven_Q_mis_shadow_bloodless",
													"Draven_Qcrit_mis",
													"Draven_Qcrit_mis_bloodless",
													"Draven_Qcrit_mis_shadow",
													"Draven_Qcrit_mis_shadow_bloodless" }
												   
					DravenConfig = scriptConfig("Sida's Auto Carry: Draven Edition", "autocarrdraven")
					DravenConfig:addParam("HoldRange", "Stand Zone", SCRIPT_PARAM_SLICE, 130, 0, 450, 0)
					DravenConfig:addParam("CatchRange", "Catch Axe Range", SCRIPT_PARAM_SLICE, 575, 0, 2000, 0)
					DravenConfig:addParam("AutoW", "Keep W Buff Active Against Enemy", SCRIPT_PARAM_ONOFF, true)
					DravenConfig:addParam("AutoCarry", "Use / Catch Axes: Auto Carry Mode", SCRIPT_PARAM_ONOFF, true)
					DravenConfig:addParam("LastHit", "Use / Catch Axes: Last Hit Mode", SCRIPT_PARAM_ONOFF, true)
					DravenConfig:addParam("LaneClear", "Use / Catch Axes: Lane Clear Mode", SCRIPT_PARAM_ONOFF, true)
					DravenConfig:addParam("MixedMode", "Use / Catch Axes: Mixed Mode Mode", SCRIPT_PARAM_ONOFF, true)
					DravenConfig:addParam("Reminder", "Display Reminder Text", SCRIPT_PARAM_ONOFF, true)
				   
					function Move(pos)
							local moveSqr = math.sqrt((pos.x - myHero.x)^2+(pos.z - myHero.z)^2)
							local moveX = myHero.x + 200*((pos.x - myHero.x)/moveSqr)
							local moveZ = myHero.z + 200*((pos.z - myHero.z)/moveSqr)
							myHero:MoveTo(moveX, moveZ)
					end
				   
					function CustomOnProcessSpell(unit, spell)
							if unit.isMe and spell.name == "dravenspinning" then
									qStacks = qStacks + 1
							end
					end
												   
					function CustomOnCreateObj(obj)
							if obj.name == "Draven_Q_buf.troy" then
									qBuff = qBuff + 1
							end
				   
							for _, particle in pairs(qParticles) do
									 if obj ~= nil and obj.valid and obj.name:lower():find(particle:lower()) and GetDistance(obj) < 333 then
											attackedSuccessfully()
									 end
							end
						   
							if obj ~= nil and obj.name ~= nil and obj.x ~= nil and obj.z ~= nil then
						if obj.name == "Draven_Q_reticle_self.troy" then
							table.insert(reticles, {object = obj, created = GetTickCount()})
						elseif obj.name == "draven_spinning_buff_end_sound.troy" then
							qStacks = 0
						end
					end
					end
				   
					function CustomOnDeleteObj(obj)
							if obj.name == "Draven_Q_reticle_self.troy" then
									if GetDistance(obj) > qRad then
											qStacks = qStacks - 1
									end
									for i, reticle in ipairs(reticles) do
											if obj and obj.valid and reticle.object and reticle.object.valid and obj.x == reticle.object.x and obj.z == reticle.object.z then
													table.remove(reticles, i)
											end
									end
							elseif obj.name == "Draven_Q_buf.troy" then
									qBuff = qBuff - 1                      
							end
					end
				   
					function axesActive()
							if (AutoCarry.MainMenu.AutoCarry and DravenConfig.AutoCarry)
							or (AutoCarry.MainMenu.LastHit and DravenConfig.LastHit)
							or (AutoCarry.MainMenu.MixedMode and DravenConfig.MixedMode)
							or (AutoCarry.MainMenu.LaneClear and DravenConfig.LaneClear) then
									return true
							end
							return false
					end
				   
					function CustomAttackEnemy(enemy)
							if enemy.dead or not enemy.valid or disableAttacks then return end
							if axesActive() and GetDistance(mousePos) <= DravenConfig.CatchRange then
									if qStacks < 2 then CastSpell(_Q) end
							end
							myHero:Attack(enemy)
							AutoCarry.shotFired = true
					end
				   
					function CustomOnTick()
							if myHero.dead then return end
							if (AutoCarry.MainMenu.AutoCarry or AutoCarry.MainMenu.MixedMode) and DravenConfig.AutoW and ValidTarget(AutoCarry.Orbwalker.target) and not TargetHaveBuff("dravenfurybuff" , myHero) then
									CastSpell(_W)
							end
						   
							for _, particle in pairs(reticles) do
									if closestReticle and closestReticle.object.valid and particle.object and particle.object.valid then
											if GetDistance(particle.object) > GetDistance(closestReticle.object) then
													closestReticle = particle
											end
									else
											closestReticle = particle
									end
							end    
			 
							if GetDistance(mousePos) <= DravenConfig.HoldRange and axesActive() then
									if not stopped then
											myHero:HoldPosition()
											stopped = true
									end
									disableMovement = true
							else
									stopped = false
							end
						   
							function doMovement()
									disableMovement = true
									disableAttacks = true
									if myHero.canMove then Move({x = closestReticle.object.x, z = closestReticle.object.z}) end
							end
						   
							if axesActive() and closestReticle and closestReticle.object and closestReticle.object.valid then
									if GetDistance(mousePos) <= DravenConfig.CatchRange and ((AutoCarry.MainMenu.AutoCarry and ShouldCatch(closestReticle.object)) or (not AutoCarry.MainMenu.AutoCarry)) then
											if GetDistance(closestReticle.object) > qRad then
													doMovement()
											else
													disableMovement = true
													disableAttacks = false
											end
									else
											disableMovement = false
											disableAttacks = false
									end
							elseif GetDistance(mousePos) <= DravenConfig.HoldRange then
									disableMovement = true
									disableAttacks = false
							else
									disableMovement = false
									disableAttacks = false
							end
					end
						   
					function ShouldCatch(reticle)
							local enemy
							if AutoCarry.Orbwalker.target ~= nil then enemy = AutoCarry.Orbwalker.target
							elseif AutoCarry.SkillsCrosshair.target ~= nil then enemy = AutoCarry.SkillsCrosshair.target
							else return true end
							if not reticle then return false end
							if GetDistance(mousePos, enemy) > GetDistance(enemy) then
									if GetDistance(reticle, enemy) < GetDistance(enemy) then
											return false
									end
									return true
							else
									local closestEnemy
									for _, thisEnemy in pairs(AutoCarry.EnemyTable) do
											if not closestEnemy then closestEnemy = thisEnemy
											elseif GetDistance(thisEnemy) < GetDistance(closestEnemy) then closestEnemy = thisEnemy end
									end
									if closestEnemy then
											local predPos = getPrediction(1.9, 100, closestEnemy)
											if not predPos then return true end
											if GetDistance(reticle, predPos) > getTrueRange() + getHitBoxRadius(closestEnemy) then
													return false
											end
											return true
									else
											return true
									end
							end
					end
				   
					function BonusLastHitDamage(minion)
							if myHero:GetSpellData(_Q).level > 0 and qBuff > 0 then
								return ((myHero.damage + myHero.addDamage) * (0.35 + (0.1 * myHero:GetSpellData(_Q).level)))
							end
							return 0
					end
				   
					function CustomOnDraw()
							DrawCircle(myHero.x, myHero.y, myHero.z, DravenConfig.HoldRange, 0xFFFFFF)
							DrawCircle(myHero.x, myHero.y, myHero.z, DravenConfig.HoldRange-1, 0xFFFFFF)
							DrawCircle(myHero.x, myHero.y, myHero.z, DravenConfig.CatchRange-1, 0x19A712)
						   
							if axesActive() and DravenConfig.Reminder then
									if GetDistance(mousePos) <= DravenConfig.HoldRange then
											DrawText("Holding Position & Catching",16,100, 100, 0xFF00FF00)
									elseif GetDistance(mousePos) <= DravenConfig.CatchRange then
											DrawText("Orbwalking & Catching",16,100, 100, 0xFF00FF00)
									else
											DrawText("Only Orbwalking",16,100, 100, 0xFF00FF00)
									end
							end
					end
			 
			end
		end 
		--[[ Items ]]--
		local items =
			{
				{name = "Blade of the Ruined King", menu = "BRK", id=3153, range = 500, reqTarget = true, slot = nil },
				{name = "Bilgewater Cutlass", menu = "BWC", id=3144, range = 500, reqTarget = true, slot = nil },
				{name = "Deathfire Grasp", menu = "DFG", id=3128, range = 750, reqTarget = true, slot = nil },
				{name = "Hextech Gunblade", menu = "HGB", id=3146, range = 400, reqTarget = true, slot = nil },
				{name = "Ravenous Hydra", menu = "RSH", id=3074, range = 350, reqTarget = false, slot = nil},
				{name = "Sword of the Divine", menu = "STD", id=3131, range = 350, reqTarget = false, slot = nil},
				{name = "Tiamat", menu = "TMT", id=3077, range = 350, reqTarget = false, slot = nil},
				{name = "Entropy", menu = "ETR", id=3184, range = 350, reqTarget = false, slot = nil},
				{name = "Youmuu's Ghostblade", menu = "YGB", id=3142, range = 350, reqTarget = false, slot = nil}
			}
			   
		function UseItemsOnTick()
			if AutoCarry.Orbwalker.target then
				for _,item in pairs(items) do
					item.slot = GetInventorySlotItem(item.id)
					if item.slot ~= nil then
						if item.reqTarget and GetDistance(AutoCarry.Orbwalker.target) <= item.range and item.menu ~= "BRK" then
							CastSpell(item.slot, AutoCarry.Orbwalker.target)
						elseif item.reqTarget and GetDistance(AutoCarry.Orbwalker.target) <= item.range and item.menu == "BRK" then
							if myHero.health <= myHero.maxHealth*0.65 or GetDistance(AutoCarry.Orbwalker.target) > 400 then
								CastSpell(item.slot, AutoCarry.Orbwalker.target)
							end
						elseif not item.reqTarget then
							CastSpell(item.slot)
						end
					end
				end
			end
		end
		 
		function SetMuramana()
			if AutoCarry.Orbwalker.target ~= nil and ItemMenu.muraMana and not MuramanaIsActive() and (AutoCarry.MainMenu.AutoCarry or AutoCarry.MainMenu.MixedMode) then
				MuramanaOn()
			elseif AutoCarry.Orbwalker.target == nil and ItemMenu.muraMana and MuramanaIsActive() then
				MuramanaOff()
			end
		end
		 
		--[[ Summoner Spells ]]--
		 local ignite, barrier, healthBefore, healthBeforeTimer, nextUpdate, nextCheck = nil, nil, 0, 0, 0, 0, 0
		 
		 function SummonerOnLoad()
				 ignite = (player:GetSpellData(SUMMONER_1).name == "SummonerDot" and SUMMONER_1 or (player:GetSpellData(SUMMONER_2).name == "SummonerDot" and SUMMONER_2 or nil))
				 barrier = (player:GetSpellData(SUMMONER_1).name == "SummonerBarrier" and SUMMONER_1 or (player:GetSpellData(SUMMONER_2).name == "SummonerBarrier" and SUMMONER_2 or nil))
		 end
		 
		function SummonerOnTick()
				if ignite and SummonerMenu.Ignite and myHero:CanUseSpell(ignite) == READY then
						for _, enemy in pairs(GetEnemyHeroes()) do
								if ValidTarget(enemy, 600) and enemy.health <= 50 + (20 * player.level) then
										CastSpell(ignite, enemy)
								end
						end
				end
				if barrier and SummonerMenu.Barrier and myHero:CanUseSpell(barrier) == READY then
						if GetTickCount() >= nextCheck then
								local co = ((myHero.health / myHero.maxHealth * 100) - 20)*(0.3-0.1)/(100-20)+0.1
								local proc = myHero.maxHealth * co
								if healthBefore - myHero.health > proc and myHero.health < myHero.maxHealth * 0.3 then
										CastSpell(barrier)
								end
								nextCheck = GetTickCount() + 100
								if GetTickCount() >= nextUpdate then
										healthBefore = myHero.health
										healthBeforeTimer = GetTickCount()
										nextUpdate = GetTickCount() + 1000
								end
						end
				end
		end
		 
		--[[ Plugins ]]--
		if FileExist(LIB_PATH .."SidasAutoCarryPlugin - "..myHero.charName..".lua") then
				hasPlugin = true
		end

		AutoCarry.GetAttackTarget = function(isCaster)
			if not isCaster and ValidTarget(AutoCarry.Orbwalker.target) then
				return AutoCarry.Orbwalker.target
			else
				AutoCarry.SkillsCrosshair:update()
				return AutoCarry.SkillsCrosshair.target
			end
		end

		AutoCarry.GetKillableMinion = function()
			return killableMinion
		end

		AutoCarry.GetMinionTarget = function()
			if killableMinion then
				return killableMinion
			elseif pluginMinion then
				return pluginMinion
			else
				return nil
			end
		end

		AutoCarry.EnemyMinions = function()
			return enemyMinions
		end

		AutoCarry.AllyMinions = function()
			return allyMinions
		end

		AutoCarry.GetJungleMobs = function()
			return jungleMobs
		end

		AutoCarry.GetLastAttacked = function()
			return lastAttacked
		end

		function OnApplyParticle(Unit, Particle)
			if PluginOnApplyParticle then PluginOnApplyParticle(Unit, Particle) end
		end
		 
		--[[ Callbacks ]]--
		function OnLoad()
				enemyMinions = minionManager(MINION_ENEMY, 2000, player, MINION_SORT_HEALTH_ASC)
				allyMinions = minionManager(MINION_ALLY, 2000, player, MINION_SORT_HEALTH_ASC)
				if getChampTable()[myHero.charName] then
					ChampInfo = getChampTable()[myHero.charName]
				end
				OrbwalkingOnLoad()
				SkillsOnLoad()
				LastHitOnLoad()
				SummonerOnLoad()
				AutoCarry.EnemyTable = GetEnemyHeroes()
				PriorityOnLoad()
				setMenus()
				StreamingMenu.DisableDrawing = false 
				if VIP_USER and PerformanceMenu.VipCol then
					require "Collision" 
					PrintChat(">> Sida's Auto Carry: VIP Collision Enabled")  
					useVIPCol = true 
				end
				if PluginOnLoad then PluginOnLoad() end
				if not AutoCarry.OverrideCustomChampionSupport then LoadCustomChampionSupport() end
				if CustomOnLoad then CustomOnLoad() end
				PrintChat(">> Sida's Auto Carry: Revamped!")
		end
		 
		function OnTick()
				OrbwalkingOnTick()
				LastHitOnTick()
				SkillsOnTick()
				SummonerOnTick()
				setMovement()
				SetMuramana()
				if PluginOnTick then PluginOnTick() end
				if StreamingMenu.DisableDrawing and not hudDisabled then 
					for i = 0, 10 do
						PrintChat("")
					end
					hudDisabled = true 
					DisableOverlay() 
				end
				if (AutoCarry.MainMenu.AutoCarry and ItemMenu.UseItemsAC) or (AutoCarry.MainMenu.LastHit and ItemMenu.UseItemsLastHit) or (AutoCarry.MainMenu.MixedMode and ItemMenu.UseItemsMixed) then
						 UseItemsOnTick()
				end
			   
				if AutoCarry.MainMenu.AutoCarry then
						if AutoCarry.Orbwalker.target ~= nil and EnemyInRange(AutoCarry.Orbwalker.target) then
								if timeToShoot() and AutoCarry.CanAttack then
										attackEnemy(AutoCarry.Orbwalker.target)
								elseif heroCanMove() then
										moveToCursor()
								end
						elseif heroCanMove() then
								moveToCursor()
						end
				end
			   
				if AutoCarry.MainMenu.LastHit then
						if not ValidTarget(killableMinion) then killableMinion = getKillableCreep(1) end
						if ValidTarget(killableMinion) and timeToShoot() and AutoCarry.CanAttack then
								attackEnemy(killableMinion)
						--elseif ValidTarget(turretMinion.obj) and timeToShoot() and AutoCarry.CanAttack and turretMinion.timeToHit > getTimeToHit(turretMinion.obj, projSpeed) then
						  --      attackEnemy(turretMinion.obj)
						elseif heroCanMove() and FarmMenu.moveLastHit then
								moveToCursor()
						end
				end
			   
				if AutoCarry.MainMenu.MixedMode then
						if AutoCarry.Orbwalker.target ~= nil and EnemyInRange(AutoCarry.Orbwalker.target) then
								if timeToShoot() and AutoCarry.CanAttack then
										attackEnemy(AutoCarry.Orbwalker.target)
								elseif heroCanMove() then
										moveToCursor()
								end
						else
								if not ValidTarget(killableMinion) then killableMinion = getKillableCreep(1) end
								if ValidTarget(killableMinion) and timeToShoot() and AutoCarry.CanAttack then
										attackEnemy(killableMinion)
								elseif heroCanMove() and FarmMenu.moveMixed then
										moveToCursor()
								end
						end
				end
			   
				if AutoCarry.MainMenu.LaneClear then
					if not ValidTarget(killableMinion) then killableMinion = getKillableCreep(1) end
					if ValidTarget(killableMinion) and timeToShoot() and AutoCarry.CanAttack then
							attackEnemy(killableMinion)
					else
						local tMinion = getHighestMinion()
						if tMinion and ValidTarget(tMinion) and timeToShoot() and AutoCarry.CanAttack then
							pluginMinion = tMinion
							attackEnemy(tMinion)
						else
							if PerformanceMenu.JungleFarm then
								local tMinion = getJungleMinion()
								if tMinion and ValidTarget(tMinion) and timeToShoot() and AutoCarry.CanAttack then
									pluginMinion = tMinion
									attackEnemy(tMinion)
								elseif heroCanMove() and FarmMenu.moveClear then
									moveToCursor()
								end	
							elseif heroCanMove() and FarmMenu.moveClear then
									moveToCursor()
							end
						end
					end
				end
			   
				 if CustomOnTick then CustomOnTick() end
		end
		 
		function OnProcessSpell(unit, spell)
			OrbwalkingOnProcessSpell(unit, spell)
			LastHitOnProcessSpell(unit, spell)
			if CustomOnProcessSpell then CustomOnProcessSpell(unit, spell) end
			if PluginOnProcessSpell then PluginOnProcessSpell(unit, spell) end
		end
		 
		function OnCreateObj(obj)    
			if myHero.dead or ChampInfo == nil then return end
				if PerformanceMenu.JungleFarm then LastHitOnCreateObj(obj) end
				if CustomOnCreateObj then CustomOnCreateObj(obj) end
				if PluginOnCreateObj then PluginOnCreateObj(obj) end
		end
		 
		function OnDeleteObj(obj)
				if PerformanceMenu.JungleFarm then LastHitOnDeleteObj(obj) end
				if CustomOnDeleteObj then CustomOnDeleteObj(obj) end
				if PluginOnDeleteObj then PluginOnDeleteObj(obj) end
		end

		function OnAnimation(unit, animation)    
			if PluginOnAnimation then PluginOnAnimation(unit, animation) end
		end		

		--function OnSendPacket(packet)
		--	if PluginOnSendPacket then PluginOnSendPacket(packet) end
		--end		
		 
		function OnDraw()
				if DisplayMenu.myRange and not disableRangeDraw then
						DrawCircle(myHero.x, myHero.y, myHero.z, getTrueRange(), 0x19A712)
				end
				DrawCircle(myHero.x, myHero.y, myHero.z, AutoCarry.MainMenu.HoldZone, 0xFFFFFF)
				OrbwalkingOnDraw()
				LastHitOnDraw()
				if CustomOnDraw then CustomOnDraw() end
				if PluginOnDraw then PluginOnDraw() end
		end

		function OnWndMsg(msg, key)
			if PluginOnWndMsg then PluginOnWndMsg(msg, key) end
		end

		--[[ Data ]]--
		function getChampTable()
			return {
				Ahri         = { projSpeed = 1.6},
				Anivia       = { projSpeed = 1.05},
				Annie        = { projSpeed = 1.0},
				Ashe         = { projSpeed = 2.0},
				Brand        = { projSpeed = 1.975},
				Caitlyn      = { projSpeed = 2.5},
				Cassiopeia   = { projSpeed = 1.22},
				Corki        = { projSpeed = 2.0},
				Draven       = { projSpeed = 1.4},
				Ezreal       = { projSpeed = 2.0},
				FiddleSticks = { projSpeed = 1.75},
				Graves       = { projSpeed = 3.0},
				Heimerdinger = { projSpeed = 1.4},
				Janna        = { projSpeed = 1.2},
				Jayce        = { projSpeed = 2.2},
				Karma        = { projSpeed = 1.2},
				Karthus      = { projSpeed = 1.25},
				Kayle        = { projSpeed = 1.8},
				Kennen       = { projSpeed = 1.35},
				KogMaw       = { projSpeed = 1.8},
				Leblanc      = { projSpeed = 1.7},
				Lulu         = { projSpeed = 2.5},
				Lux          = { projSpeed = 1.55},
				Malzahar     = { projSpeed = 1.5},
				MissFortune  = { projSpeed = 2.0},
				Morgana      = { projSpeed = 1.6},
				Nidalee      = { projSpeed = 1.7},
				Orianna      = { projSpeed = 1.4},
				Quinn        = { projSpeed = 1.85},
				Ryze         = { projSpeed = 2.4},
				Sivir        = { projSpeed = 1.4},
				Sona         = { projSpeed = 1.6},
				Soraka       = { projSpeed = 1.0},
				Swain        = { projSpeed = 1.6},
				Syndra       = { projSpeed = 1.2},
				Teemo        = { projSpeed = 1.3},
				Tristana     = { projSpeed = 2.25},
				TwistedFate  = { projSpeed = 1.5},
				Twitch       = { projSpeed = 2.5},
				Urgot        = { projSpeed = 1.3},
				Vayne        = { projSpeed = 2.0},
				Varus        = { projSpeed = 2.0},
				Veigar       = { projSpeed = 1.05},
				Viktor       = { projSpeed = 2.25},
				Vladimir     = { projSpeed = 1.4},
				Xerath       = { projSpeed = 1.2},
				Ziggs        = { projSpeed = 1.5},
				Zilean       = { projSpeed = 1.25},
				Zyra         = { projSpeed = 1.7},
			}
		end
		 
		function getSpellList()
				local spellArray = nil
				if myHero.charName == "Ezreal" then
						spellArray = {
						{ spellKey = _Q, range = 1100, speed = 2.0, delay = 250, width = 70, configName = "mysticShot", displayName = "Q (Mystic Shot)", enabled = true, skillShot = true, minions = true, reset = false, reqTarget = true },
						{ spellKey = _W, range = 1050, speed = 1.6, delay = 250, width = 90, configName = "essenceFlux", displayName = "W (Essence Flux)", enabled = true, skillShot = true, minions = false, reset = false, reqTarget = true },
						}
				elseif myHero.charName == "KogMaw" then
						spellArray = {
						{ spellKey = _Q, range = 625, speed = 1.3, delay = 260, width = 200, configName = "causticSpittle", displayName = "Q (Caustic Spittle)", enabled = true, skillShot = false, minions = false, reset = true, reqTarget = true },
						{ spellKey = _W, range = 625, speed = 1.3, delay = 260, width = 200, configName = "bioArcaneBarrage", displayName = "W (Bio-Arcane Barrage)", enabled = true, forceRange = true, forceToHitBox = true, skillShot = false, minions = false, reset = false, reqTarget = false },
						{ spellKey = _E, range = 850, speed = 1.3, delay = 260, width = 200, configName = "voidOoze", displayName = "E (Void Ooze)", enabled = true, skillShot = true, minions = false, reset = false, reqTarget = true },
						{ spellKey = _R, range = 1700, speed = math.huge, delay = 1000, width = 200, configName = "livingArtillery", displayName = "R (Living Artillery)", enabled = true, skillShot = true, minions = false, reset = false, reqTarget = true },
						}
				elseif myHero.charName == "Sivir" then
						spellArray = {
						{ spellKey = _Q, range = 1000, speed = 1.33, delay = 250, width = 120, configName = "boomerangBlade", displayName = "Q (Boomerang Blade)", enabled = true, skillShot = true, minions = false, reset = false, reqTarget = true },
						{ spellKey = _W, range = getTrueRange(), speed = 1, delay = 0, width = 200, configName = "Ricochet", displayName = "W (Ricochet)", enabled = true, skillShot = false, minions = false, reset = true, reqTarget = true },
						}
				elseif myHero.charName == "Graves" then
						spellArray = {
						{ spellKey = _Q, range = 750, speed = 2, delay = 250, width = 200, configName = "buckShot", displayName = "Q (Buck Shot)", enabled = true, skillShot = true, minions = false, reset = false, reqTarget = true },
						{ spellKey = _W, range = 700, speed = 1400, delay = 300, width = 500, configName = "smokeScreen", displayName = "W (Smoke Screen)", enabled = false, skillShot = true, minions = false, reset = false, reqTarget = true },
						{ spellKey = _E, range = 580, speed = 1450, delay = 250, width = 200, configName = "quickDraw", displayName = "E (Quick Draw)", enabled = true, skillShot = false, minions = false, reset = true, reqTarget = false, atMouse = true },
						}
				elseif myHero.charName == "Caitlyn" then
						spellArray = {
						{ spellKey = _Q, range = 1300, speed = 2.1, delay = 625, width = 100, configName = "piltoverPeacemaker", displayName = "Q (Piltover Peacemaker)", enabled = true, skillShot = true, minions = true, reset = false, reqTarget = true },
						}
				elseif myHero.charName == "Corki" then
						spellArray = {
						{ spellKey = _Q, range = 600, speed = 2, delay = 200, width = 500, configName = "phosphorusBomb", displayName = "Q (Phosphorus Bomb)", enabled = true, skillShot = true, minions = false, reset = false, reqTarget = true },
						{ spellKey = _R, range = 1225, speed = 2, delay = 200, width = 50, configName = "missileBarrage", displayName = "R (Missile Barrage)", enabled = true, skillShot = true, minions = true, reset = false, reqTarget = true },
						}
				elseif myHero.charName == "Teemo" then
						spellArray = {
						{ spellKey = _Q, range = 580, speed = 2, delay = 0, width = 200, configName = "blindingDart", displayName = "Q (Blinding Dart)", enabled = true, skillShot = false, minions = false, reset = false, reqTarget = true },
						}
				elseif myHero.charName == "TwistedFate" then
						spellArray = {
						{ spellKey = _Q, range = 1200, speed = 1.45, delay = 250, width = 200, configName = "wildCards", displayName = "Q (Wild Cards)", enabled = true, skillShot = true, minions = false, reset = false, reqTarget = true },
						}
				elseif myHero.charName == "Vayne" then
						spellArray = {
						{ spellKey = _Q, range = 580, speed = 1.45, delay = 250, width = 200, configName = "tumble", displayName = "Q (Tumble)", enabled = true, skillShot = false, minions = false, reset = true, reqTarget = false, atMouse = true },
						{ spellKey = _R, range = 580, speed = 1.45, delay = 250, width = 200, configName = "finalHour", displayName = "R (Final Hour)", enabled = true, skillShot = false, minions = false, reset = false, reqTarget = false},
						}
				elseif myHero.charName == "MissFortune" then
						spellArray = {
						{ spellKey = _Q, range = 650, speed = 1.45, delay = 250, width = 200, configName = "doubleUp", displayName = "Q (Double Up)", enabled = true, skillShot = false, minions = false, reset = true, reqTarget = true},
						{ spellKey = _W, range = 580, speed = 1.45, delay = 250, width = 200, configName = "impureShots", displayName = "W (Impure Shots)", enabled = true, skillShot = false, minions = false, reset = false, reqTarget = false},
						{ spellKey = _E, range = 800, speed = math.huge, delay = 500, width = 500, configName = "makeItRain", displayName = "E (Make It Rain)", enabled = false, skillShot = true, minions = false, reset = false, reqTarget = true },
						}
				elseif myHero.charName == "Tristana" then
						spellArray = {
						{ spellKey = _Q, range = 580, speed = 1.45, delay = 250, width = 200, configName = "rapidFire", displayName = "Q (Rapid Fire)", enabled = true, skillShot = false, minions = false, reset = false, reqTarget = false},
						{ spellKey = _E, range = 550, speed = 1.45, delay = 250, width = 200, configName = "explosiveShot", displayName = "E (Explosive Shot)", enabled = true, skillShot = false, minions = false, reset = false, reqTarget = true},
						}
				elseif myHero.charName == "Draven" then
						spellArray = {
						{ spellKey = _E, range = 950, speed = 1.37, delay = 300, width = 130, configName = "standAside", displayName = "E (Stand Aside)", enabled = true, skillShot = true, minions = false, reset = false, reqTarget = true},
						}
				--[[    Added Champs    ]]
				elseif myHero.charName == "Kennen" then
						spellArray = {
						{ spellKey = _Q, range = 1050, speed = 1.65, delay = 180, width = 80, configName = "thunderingShuriken", displayName = "Q (Thundering Shuriken)", enabled = true, skillShot = true, minions = true, reset = false, reqTarget = true },
						}
				elseif myHero.charName == "Ashe" then
						spellArray = {
						{ spellKey = _W, range = 1200, speed = 2.0, delay = 120, width = 85, configName = "Volley", displayName = "W (Volley)", enabled = true, skillShot = true, minions = true, reset = false, reqTarget = true },
						}
				elseif myHero.charName == "Syndra" then
						spellArray = {
						{ spellKey = _Q, range = 800, speed = math.huge, delay = 400, width = 100, configName = "darkSphere", displayName = "Q (Dark Sphere)", enabled = true, skillShot = true, minions = false, reset = false, reqTarget = true },
						}
				elseif myHero.charName == "Jayce" then
						spellArray = {
						{ spellKey = _Q, range = 1600, speed = 2.0, delay = 350, width = 90, configName = "shockBlast", displayName = "Q (Shock Blast)", enabled = true, skillShot = true, minions = true, reset = false, reqTarget = true },
						}
				elseif myHero.charName == "Nidalee" then
						spellArray = {
						{ spellKey = _Q, range = 1500, speed = 1.3, delay = 125, width = 80, configName = "javelinToss", displayName = "Q (Javelin Toss)", enabled = true, skillShot = true, minions = true, reset = false, reqTarget = true },
						}
				--[[elseif myHero.charName == "Varus" then
						spellArray = {
						{ spellKey = _E, range = 925, speed = 1.75, delay = 240, width = 235, configName = "hailofArrows", displayName = "E (Hail of Arrows)", enabled = true, skillShot = true, minions = false, reset = false, reqTarget = true },
						}]]
				elseif myHero.charName == "Quinn" then
						spellArray = {
						{ spellKey = _Q, range = 1050, speed = 1.55, delay = 220, width = 90, configName = "blindingAssault", displayName = "Q (Blinding Assault)", enabled = true, skillShot = true, minions = true, reset = false, reqTarget = true },
						--{ spellKey = _E, range = 725, speed = 1.45, delay = 250, width = nil, configName = "vault", displayName = "E (Vault)", enabled = true, skillShot = false, minions = false, reset = true, reqTarget = true},
						}
				elseif myHero.charName == "LeeSin" then
						spellArray = {
						{ spellKey = _Q, range = 975, speed = 1.5, delay = 250, width = 70, configName = "sonicWave", displayName = "Q (Sonic Wave)", enabled = true, skillShot = true, minions = true, reset = false, reqTarget = true },
						}
				elseif myHero.charName == "Gangplank" then
						spellArray = {
						{ spellKey = _Q, range = 625, speed = 1.45, delay = 250, width = 200, configName = "parley", displayName = "Q (Parley)", enabled = true, skillShot = false, minions = false, reset = false, reqTarget = true},
						}
				elseif myHero.charName == "Twitch" then
						spellArray = {
						{ spellKey = _W, range = 950, speed = 1.4, delay = 250, width = 275, configName = "venomCask", displayName = "W (Venom Cask)", enabled = false, skillShot = true, minions = false, reset = false, reqTarget = true },
						}
				elseif myHero.charName == "Darius" then
					spellArray = {
					{ spellKey = _W, range = 300, speed = 2, delay = 0, width = 200, configName = "cripplingStrike", displayName = "W (Crippling Strike)", enabled = true, skillShot = false, minions = true, reset = true, reqTarget = false },
					}	
				elseif myHero.charName == "Hecarim" then
					spellArray = {
					{ spellKey = _Q, range = 300, speed = 2, delay = 0, width = 200, configName = "rampage", displayName = "Q (Rampage)", enabled = true, skillShot = false, minions = true, reset = true, reqTarget = false },
					}			
				elseif myHero.charName == "Warwick" then
					spellArray = {
					{ spellKey = _Q, range = 300, speed = 2, delay = 0, width = 200, configName = "hungeringStrike", displayName = "Q (Hungering Strike)", enabled = true, skillShot = false, minions = true, reset = true, reqTarget = true },
					}	
				elseif myHero.charName == "MonkeyKing" then
					spellArray = {
					{ spellKey = _Q, range = 300, speed = 2, delay = 0, width = 200, configName = "crushingBlow", displayName = "Q (Crushing Blow)", enabled = true, skillShot = false, minions = true, reset = true, reqTarget = false },
					}		
				elseif myHero.charName == "Poppy" then
					spellArray = {
					{ spellKey = _Q, range = 300, speed = 2, delay = 0, width = 200, configName = "devastatingBlow", displayName = "Q (Devastating Blow)", enabled = true, skillShot = false, minions = true, reset = true, reqTarget = false },
					}	
				elseif myHero.charName == "Talon" then
					spellArray = {
					{ spellKey = _Q, range = 300, speed = 2, delay = 0, width = 200, configName = "noxianDiplomacy", displayName = "Q (Noxian Diplomacy)", enabled = true, skillShot = false, minions = true, reset = true, reqTarget = false },
					}			
				elseif myHero.charName == "Nautilus" then
					spellArray = {
					{ spellKey = _W, range = 300, speed = 2, delay = 0, width = 200, configName = "titansWrath", displayName = "W (Titans Wrath)", enabled = true, skillShot = false, minions = true, reset = true, reqTarget = false },
					}		
				elseif myHero.charName == "Gangplank" then
					spellArray = {
					{ spellKey = _Q, range = 300, speed = 2, delay = 0, width = 200, configName = "parlay", displayName = "Q (Parlay)", enabled = true, skillShot = false, minions = true, reset = true, reqTarget = true },
					}		
				elseif myHero.charName == "Vi" then
					spellArray = {
					{ spellKey = _E, range = 300, speed = 2, delay = 0, width = 200, configName = "excessiveForce", displayName = "E (Excessive Force)", enabled = true, skillShot = false, minions = true, reset = true, reqTarget = false },
					}			
				elseif myHero.charName == "Rengar" then
					spellArray = {
					{ spellKey = _Q, range = 300, speed = 2, delay = 0, width = 200, configName = "savagery", displayName = "Q (Savagery)", enabled = true, skillShot = false, minions = true, reset = true, reqTarget = false },
					}			
				elseif myHero.charName == "Trundle" then
					spellArray = {
					{ spellKey = _Q, range = 300, speed = 2, delay = 0, width = 200, configName = "chomp", displayName = "Q (Chomp)", enabled = true, skillShot = false, minions = true, reset = true, reqTarget = false },
					}					
				elseif myHero.charName == "Leona" then
					spellArray = {
					{ spellKey = _Q, range = 300, speed = 2, delay = 0, width = 200, configName = "shieldOfDaybreak", displayName = "Q (Shield Of Daybreak)", enabled = true, skillShot = false, minions = true, reset = true, reqTarget = false },
					}			
				elseif myHero.charName == "Fiora" then
					spellArray = {
					{ spellKey = _E, range = 300, speed = 2, delay = 0, width = 200, configName = "burstOfSpeed", displayName = "E (Burst Of Speed)", enabled = true, skillShot = false, minions = true, reset = true, reqTarget = false },
					}		
				elseif myHero.charName == "Blitzcrank" then
					spellArray = {
					{ spellKey = _E, range = 300, speed = 2, delay = 0, width = 200, configName = "powerFist", displayName = "E (Power Fist)", enabled = true, skillShot = false, minions = true, reset = true, reqTarget = false },
					}			
				elseif myHero.charName == "Shyvana" then
					spellArray = {
					{ spellKey = _Q, range = 300, speed = 2, delay = 0, width = 200, configName = "twinBlade", displayName = "Q (Twin Blade)", enabled = true, skillShot = false, minions = true, reset = true, reqTarget = false },
					}			
				elseif myHero.charName == "Renekton" then
					spellArray = {
					{ spellKey = _W, range = 300, speed = 2, delay = 0, width = 200, configName = "ruthless Predator", displayName = "W (Ruthless Predator)", enabled = true, skillShot = false, minions = true, reset = true, reqTarget = false },
					}			
				elseif myHero.charName == "Jax" then
					spellArray = {
					{ spellKey = _W, range = 300, speed = 2, delay = 0, width = 200, configName = "empower", displayName = "W (Empower)", enabled = true, skillShot = false, minions = true, reset = true, reqTarget = false },
					}		
				elseif myHero.charName == "XinZhao" then
					spellArray = {
					{ spellKey = _Q, range = 300, speed = 2, delay = 0, width = 200, configName = "threeTalonStrike", displayName = "Q (Three Talon Strike)", enabled = true, skillShot = false, minions = true, reset = true, reqTarget = false },
					}		
				elseif myHero.charName == "Nunu" then
					spellArray = {
					{ spellKey = _E, range = GetSpellData(_E).range, speed = 1.45, delay = 250, width = 200, configName = "showball", displayName = "E (Snowball)", enabled = true, skillShot = false, minions = false, reset = false, reqTarget = true},
					}
				elseif myHero.charName == "Khazix" then
					spellArray = {
					{ spellKey = _Q, range = GetSpellData(_Q).range, speed = 1.45, delay = 250, width = 200, configName = "tasteTheirFear", displayName = "Q (Taste Their Fear)", enabled = true, skillShot = false, minions = false, reset = true, reqTarget = true},
					}
				elseif myHero.charName == "Shen" then
					spellArray = {
					{ spellKey = _Q, range = GetSpellData(_Q).range, speed = 1.45, delay = 250, width = 200, configName = "vorpalBlade", displayName = "Q (Vorpal Blade)", enabled = true, skillShot = false, minions = false, reset = false, reqTarget = true},
					}
				end
		return spellArray
		end
		 
		local priorityTable = {
		 
			AP = {
				"Annie", "Ahri", "Akali", "Anivia", "Annie", "Brand", "Cassiopeia", "Diana", "Evelynn", "FiddleSticks", "Fizz", "Gragas", "Heimerdinger", "Karthus",
				"Kassadin", "Katarina", "Kayle", "Kennen", "Leblanc", "Lissandra", "Lux", "Malzahar", "Mordekaiser", "Morgana", "Nidalee", "Orianna",
				"Rumble", "Ryze", "Sion", "Swain", "Syndra", "Teemo", "TwistedFate", "Veigar", "Viktor", "Vladimir", "Xerath", "Ziggs", "Zyra", "MasterYi",
			},
			Support = {
				"Alistar", "Blitzcrank", "Janna", "Karma", "Leona", "Lulu", "Nami", "Nunu", "Sona", "Soraka", "Taric", "Thresh", "Zilean",
			},
		 
			Tank = {
				"Amumu", "Chogath", "DrMundo", "Galio", "Hecarim", "Malphite", "Maokai", "Nasus", "Rammus", "Sejuani", "Shen", "Singed", "Skarner", "Volibear",
				"Warwick", "Yorick", "Zac",
			},
		 
			AD_Carry = {
				"Ashe", "Caitlyn", "Corki", "Draven", "Ezreal", "Graves", "Jayce", "KogMaw", "MissFortune", "Pantheon", "Quinn", "Shaco", "Sivir",
				"Talon", "Tristana", "Twitch", "Urgot", "Varus", "Vayne", "Zed",
		 
			},
		 
			Bruiser = {
				"Aatrox", "Darius", "Elise", "Fiora", "Gangplank", "Garen", "Irelia", "JarvanIV", "Jax", "Khazix", "LeeSin", "Nautilus", "Nocturne", "Olaf", "Poppy",
				"Renekton", "Rengar", "Riven", "Shyvana", "Trundle", "Tryndamere", "Udyr", "Vi", "MonkeyKing", "XinZhao",
			},
		 
		}
		 
		function SetPriority(table, hero, priority)
				for i=1, #table, 1 do
						if hero.charName:find(table[i]) ~= nil then
								TS_SetHeroPriority(priority, hero.charName)
						end
				end
		end
		 
		function arrangePrioritys()
				for i, enemy in ipairs(AutoCarry.EnemyTable) do
						SetPriority(priorityTable.AD_Carry, enemy, 1)
						SetPriority(priorityTable.AP,       enemy, 2)
						SetPriority(priorityTable.Support,  enemy, 3)
						SetPriority(priorityTable.Bruiser,  enemy, 4)
						SetPriority(priorityTable.Tank,     enemy, 5)
				end
		end
		 
		function PriorityOnLoad()
				if heroManager.iCount < 10 then
						PrintChat(" >> Too few champions to arrange priority")
				else
						TargetSelector(TARGET_LOW_HP_PRIORITY, 0)
						arrangePrioritys()
				end
		end
		 
		function getJungleMobs()
				return {"Dragon6.1.1", "Worm12.1.1", "GiantWolf8.1.3", "wolf8.1.1", "wolf8.1.2", "AncientGolem7.1.1", "YoungLizard7.1.2", "YoungLizard7.1.3", "Wraith9.1.3", "LesserWraith9.1.1", "LesserWraith9.1.2",
				"LesserWraith9.1.4", "LizardElder10.1.1", "YoungLizard10.1.2", "YoungLizard10.1.3", "Golem11.1.2", "SmallGolem11.1.1", "GiantWolf2.1.3", "wolf2.1.1",
				"wolf2.1.2", "AncientGolem1.1.1", "YoungLizard1.1.2", "YoungLizard1.1.3", "Wraith3.1.3", "LesserWraith3.1.1", "LesserWraith3.1.2", "LesserWraith3.1.4",
				"LizardElder4.1.1", "YoungLizard4.1.2", "YoungLizard4.1.3", "Golem5.1.2", "SmallGolem5.1.1"}
		end
		 
		--[[ Menus ]]--
		function setMenus()
			mainMenu()
			skillsMenu()
			itemMenu()
			displayMenu()
			permaMenu()
			masteryMenu()
			farmMenu()
			summonerMenu()
			streamingMenu()
			performanceMenu()
			pluginMenu()
		end
		 
		function itemMenu()
			ItemMenu = scriptConfig("Sida's Auto Carry: Items", "sidasacitems")
			ItemMenu:addParam("sep", "-- Settings --", SCRIPT_PARAM_INFO, "")
			ItemMenu:addParam("UseItemsAC", "Use Items With AutoCarry", SCRIPT_PARAM_ONOFF, true)
			ItemMenu:addParam("UseItemsLastHit", "Use Items With Harass", SCRIPT_PARAM_ONOFF, true)
			ItemMenu:addParam("UseItemsMixed", "Use Items With Mixed Mode", SCRIPT_PARAM_ONOFF, true)
			ItemMenu:addParam("sep2", "-- Items --", SCRIPT_PARAM_INFO, "")
			for _, item in ipairs(items) do
					ItemMenu:addParam(item.menu, "Use "..item.name, SCRIPT_PARAM_ONOFF, true)
			end
			ItemMenu:addParam("muraMana", "Use Muramana", SCRIPT_PARAM_ONOFF, true)
		end
		 
		function mainMenu()
			AutoCarry.MainMenu = scriptConfig("Sida's Auto Carry: Settings", "sidasacmain")
			AutoCarry.MainMenu:addParam("AutoCarry", "Auto Carry", SCRIPT_PARAM_ONKEYDOWN, false, AutoCarryKey)
			AutoCarry.MainMenu:addParam("LastHit", "Last Hit", SCRIPT_PARAM_ONKEYDOWN, false, LastHitKey)
			AutoCarry.MainMenu:addParam("MixedMode", "Mixed Mode", SCRIPT_PARAM_ONKEYTOGGLE, true, MixedModeKey)
			AutoCarry.MainMenu:addParam("LaneClear", "Lane Clear", SCRIPT_PARAM_ONKEYDOWN, false, LaneClearKey)
			AutoCarry.MainMenu:addParam("Focused", "Prioritise Selected Target", SCRIPT_PARAM_ONOFF, false)
			AutoCarry.MainMenu:addParam("HoldZone", "Stand Still And Shoot Range", SCRIPT_PARAM_SLICE, 0, 0, getTrueRange(), 0)
			AutoCarry.MainMenu:addTS(AutoCarry.Orbwalker)
		end
		 
		function skillsMenu()
			SkillsMenu = scriptConfig("Sida's Auto Carry: Skills", "sidasacskills")
			if Skills then
				SkillsMenu:addParam("sep", "-- Auto Carry Skills --", SCRIPT_PARAM_INFO, "")
				for _, skill in ipairs(Skills) do
					SkillsMenu:addParam(skill.configName.."AutoCarry", "Use "..skill.displayName, SCRIPT_PARAM_ONOFF, true)
				end
				SkillsMenu:addParam("sep2", "-- Mixed Mode Skills --", SCRIPT_PARAM_INFO, "")
				for _, skill in ipairs(Skills) do
					SkillsMenu:addParam(skill.configName.."MixedMode", "Use "..skill.displayName, SCRIPT_PARAM_ONOFF, true)
				end
			else
				SkillsMenu:addParam("sep", myHero.charName.." does not have any supported skills", SCRIPT_PARAM_INFO, "")
			end
			if VIP_USER then
				SkillsMenu:addParam("hitChance", "Ability Hitchance", SCRIPT_PARAM_SLICE, 60, 0, 100, 0)
			end
		end
		 
		function displayMenu()
			DisplayMenu = scriptConfig("Sida's Auto Carry: Display", "sidasacdisplay")
			DisplayMenu:addParam("myRange", "Attack Range Circle", SCRIPT_PARAM_ONOFF, true)
			DisplayMenu:addParam("target", "Circle Around Target", SCRIPT_PARAM_ONOFF, true)
			DisplayMenu:addParam("minion", "Circle Next Minion To Last Hit", SCRIPT_PARAM_ONOFF, true)
			DisplayMenu:addParam("sep", "-- Always Display (Requires Reload) --", SCRIPT_PARAM_INFO, "")
			DisplayMenu:addParam("AutoCarry", "Auto Carry Hotkey Status", SCRIPT_PARAM_ONOFF, true)
			DisplayMenu:addParam("LastHit", "Last Hit Hotkey Status", SCRIPT_PARAM_ONOFF, true)
			DisplayMenu:addParam("MixedMode", "Mixed Mode Hotkey Status", SCRIPT_PARAM_ONOFF, true)
			DisplayMenu:addParam("LaneClear", "Lane Clear Hotkey Status", SCRIPT_PARAM_ONOFF, true)
		end
		 
		function permaMenu()
			if DisplayMenu.AutoCarry then AutoCarry.MainMenu:permaShow("AutoCarry") end
			if DisplayMenu.LastHit then AutoCarry.MainMenu:permaShow("LastHit") end
			if DisplayMenu.MixedMode then AutoCarry.MainMenu:permaShow("MixedMode") end
			if DisplayMenu.LaneClear then AutoCarry.MainMenu:permaShow("LaneClear") end
		end
		 
		function masteryMenu()
			MasteryMenu = scriptConfig("Sida's Auto Carry: Masteries", "sidasacmasteries")
			MasteryMenu:addParam("Butcher", "Butcher", SCRIPT_PARAM_SLICE, 0, 0, 2, 0)
			MasteryMenu:addParam("Spellblade", "Spellblade", SCRIPT_PARAM_ONOFF, false)
			MasteryMenu:addParam("Executioner", "Executioner", SCRIPT_PARAM_ONOFF, false)
		end
		 
		function farmMenu()
			FarmMenu = scriptConfig("Sida's Auto Carry: Farming", "sidasacfarming")
			FarmMenu:addParam("Predict", "Predict Minion Damage", SCRIPT_PARAM_ONOFF, true)
			FarmMenu:addParam("moveLastHit", "Move To Mouse Last Hit Farming", SCRIPT_PARAM_ONOFF, true)
			FarmMenu:addParam("moveMixed", "Move To Mouse Mixed Mode Farming", SCRIPT_PARAM_ONOFF, true)
			FarmMenu:addParam("moveClear", "Move To Mouse Lane Clear Farming", SCRIPT_PARAM_ONOFF, true)
		end
		 
		function summonerMenu()
			SummonerMenu = scriptConfig("Sida's Auto Carry: Summoner Spells", "sidasacsummoner")
			SummonerMenu:addParam("Ignite", "Ignite Killable Enemies", SCRIPT_PARAM_ONOFF, true)
			SummonerMenu:addParam("Barrier", "Auto Barrier Upon High Damage", SCRIPT_PARAM_ONOFF, true)
		end

		function streamingMenu()
			StreamingMenu = scriptConfig("Sida's Auto Carry: Streaming", "sidasacstreaming")
			StreamingMenu:addParam("ShowClick", "Show Click Marker", SCRIPT_PARAM_ONOFF, true)
			StreamingMenu:addParam("MinRand", "Minimum Time Between Clicks", SCRIPT_PARAM_SLICE, 150, 0, 1000, 0)
			StreamingMenu:addParam("MaxRand", "Maximum Time Between Clicks", SCRIPT_PARAM_SLICE, 650, 0, 1000, 0)
			StreamingMenu:addParam("Colour", "0 = Green, 1 = Red", SCRIPT_PARAM_SLICE, 0, 0, 1, 0)
			StreamingMenu:addParam("DisableDrawing", "Streaming Mode", SCRIPT_PARAM_ONOFF, true)
		end

		function performanceMenu()
			PerformanceMenu = scriptConfig("Sida's Auto Carry: Performance", "sidasacperformance")
			PerformanceMenu:addParam("sep", "-- Can Cause FPS Lag! --", SCRIPT_PARAM_INFO, "")
			PerformanceMenu:addParam("VipCol", "Use VIP Collision (Requires Reload!)", SCRIPT_PARAM_ONOFF, false)
			PerformanceMenu:addParam("JungleFarm", "Enable Jungle Clearing", SCRIPT_PARAM_ONOFF, false)
		end
		 
		function pluginMenu()
			if hasPlugin then
				AutoCarry.PluginMenu = scriptConfig("Sida's Auto Carry: "..myHero.charName.." Plugin", "sidasacplugin"..myHero.charName)
				require("SidasAutoCarryPlugin - "..myHero.charName)
				PrintChat(">> Sida's Auto Carry: Loaded "..myHero.charName.." plugin!")
			end
		end








----------------------------------------------------------------------------
	elseif GetMyHero().charName == "Aatrox" then
		--[["Demon Reaper" Made by Pain]]--
		--[[Credits]]--
		--Burn (I stole his auto ignite code :))
		--HunteR (His W Helper script)


		local qp = TargetPredictionVIP(780, 1800, 0.25, 80) 
		local qpe = TargetPredictionVIP(800, 1500, 0.25, 30)
		local	LastCast = nil

		local minPercents = 0.35
		local maxPercents = 0.75
		local delay, raz = 0

		function OnLoad()

		--levelSequence = {1,2,3,2,2,4,2,3,2,3,4,3,3,1,1,4,1,1}



		if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then 
			ignite = SUMMONER_1
		elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then 
			ignite = SUMMONER_2 
		end
		ts = TargetSelector(TARGET_NEAR_MOUSE, 1400, DAMAGE_PHYSICAL, false)
		ts.name = "Aatrox"
		AatroxConfig:addTS(ts)
		raz = maxPercents - minPercents
		end
		
		
		function OnTick()
		--autoLevelSetSequence(levelSequence)

		ts:update()
		if ValidTarget(ts.target) then
			--[[Aatrox W, Damage or Life Steal]]--
		if myHero.dead or myHero:CanUseSpell(_W) ~= READY or GetTickCount() < delay then
						return
		end
			   
		local percentLevel = (myHero.level - 1) / 17
		local addedPerc = minPercents + (raz - (raz * percentLevel))
	   
		local nameSpell = myHero:GetSpellData(_W).name
		if myHero:CanUseSpell(_W) == READY and ts.target ~= nil and GetDistance(ts.target) <= 550 then
		if (myHero.health / myHero.maxHealth) < addedPerc then
				if nameSpell == "aatroxw2" then
						CastSpell(_W)
				end
		elseif nameSpell == "AatroxW" then
				CastSpell(_W)
		end
				end
						
		--[[End of Aatrox W, Damage or Life Steal]]--

			predictQ = qp:GetPrediction(ts.target)
			predictE = qpe:GetPrediction(ts.target)
			AutoUlti()
			if not VIP_USER then
				FreeCombo() 
			elseif VIP_USER then
				Combo()
			end
		end
	end
		function FreeCombo()
			
			if GetDistance(ts.target) <= 800 then
				CastSpell(_E, ts.target.x, ts.target.z)
			end
				if GetDistance(ts.target) <= 800 then
					CastSpell(_Q, ts.target.x, ts.target.z)
				end
		end

		function Combo()
			myHero:Attack(ts.target)
			if predictE ~= nil and GetDistance(ts.target) <= 800 then
				CastSpell(_E, predictE.x, predictE.z)
			end
					if predictQ ~= nil and GetDistance(ts.target) <= 800 then
					CastSpell(_Q, predictQ.x, predictQ.z)
				end
			end



		function AutoUlti()
			if GetDistance(ts.target) <= 450 then
				CastSpell(_R)
			end
		end


		function AutoIgnite()
				if string.find(sums[i], "SummonerDot") ~= nil then
					local igniteDamage = 50 + 20 * player.level
					if player:CanUseSpell(10+i) == READY then
						for j = 1, heroManager.iCount do
							local target = heroManager:GetHero(j)
							if ts.target ~= nil and ts.target.visible == true and ts.target.team ~= player.team and ts.target.dead == false and player:GetDistance(ts.target) < 600 then
								if target.health < igniteDamage then
									CastSpell(10+i, ts.target)
								end
							end
						end
					end
				end
		end

		function getMyTrueRange()
			return myHero.range + GetDistance(myHero, myHero.minBBox)
		end

--------------------------------------------------------------------------------
	elseif GetMyHero().charName == "Ahri" then
		--[[    Ahri Helper by HeX 1.3.1 VIP Prediction
		 
		Hot Keys:
				-Basic Combo: Space
				-Harass(Toggle): Z
		 
		Features:
				-Basic Combo: Items-> R-> E-> Q-> W-> R*2
				-Harass: Q
				-Use ulti in combo ON/OFF option in ingame menu.
				-Use E in combo ON/OFF option in ingame menu.
				-Mark killable target with a combo.
				-Target configuration, Press shift to configure.
				-Auto ignite and/or Ulti killable enemy ON/OFF option in ingame menu.
				-Item Support: DFG, Hextech Gunblade, Bligewater Cutlass, Blade of the Ruined King.
				-Basic orb walking ON/OFF option in ingame menu. It will follow your mouse so you can kite targets if you want.
			   
		Explanation of the marks:
				-Green circle: Marks the current target to which you will do the combo
				-Blue circle: Killed with a combo, if all the skills were available
				-Red circle: Killed using Items + Q + W + E + R + Ignite(if available)
				-2 Red circles: Killed using Items + Q + W + E + Ignite(if available)
				-3 Red circles: Killed using Q + W     
		]]--
		 
		--[[    Settings        ]]--
		local rBuffer = 300 --Wont use R unless they are further than this.
		--[[ Ranges     ]]--
		local qRange = 800
		local wRange = 800
		local eRange = 975
		local rRange = 1000
		--[[    Damage Calculation      ]]--
		local calculationenemy = 1
		local killable = {}
		--[[    Prediction      ]]--
		if VIP_USER then
				qp = TargetPredictionVIP(880, 1700, 0.25)
				ep = TargetPredictionVIP(975, 1600, 0.1, 90)
				PrintChat("Ahri Helper - VIP Prediction Used")
		else
				qp = TargetPrediction(880, 1.7, 250)
				ep = TargetPrediction(975, 1.6, 100)
				PrintChat("Ahri Helper - Basic Prediction Used")
		end
		--[[    Attacks ]]--
		local lastBasicAttack = 0
		local swing = 0
		local startAttackSpeed = 0.625
		local nextTick = 0
		--[[    Items   ]]--
		local ignite = nil
		local QREADY, WREADY, EREADY, RREADY = false, false, false, false
		local BRKSlot, DFGSlot, HXGSlot, BWCSlot = nil, nil, nil, nil
		local BRKREADY, DFGREADY, HXGREADY, BWCREADY = false, false, false, false
		 
		function OnLoad()
				ts = TargetSelector(TARGET_LOW_HP, wRange+100, DAMAGE_MAGIC)
				ts.name = "Ahri"
				AHConfig:addTS(ts)
			   
				lastBasicAttack = os.clock()
				enemyMinions = minionManager(MINION_ENEMY, 1200, player)
			   
				if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then ignite = SUMMONER_1
						elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then ignite = SUMMONER_2
				end
		end
		 
		function OnProcessSpell(unit, spell)
				if unit.isMe and (spell.name:find("Attack") ~= nil) then
						swing = 1
						lastBasicAttack = os.clock()
				end
		end
		 
		function OnTick()
				ts:update()
				enemyMinions:update()
				enemyMinions = minionManager(MINION_ENEMY, 1200, player)
			   
				AttackDelay = 1/(myHero.attackSpeed*startAttackSpeed)
				if swing == 1 and os.clock() > lastBasicAttack + AttackDelay then
						swing = 0
				end
		 
				BRKSlot, DFGSlot, HXGSlot, BWCSlot = GetInventorySlotItem(3153), GetInventorySlotItem(3128), GetInventorySlotItem(3146), GetInventorySlotItem(3144)
				DFGREADY = (DFGSlot ~= nil and myHero:CanUseSpell(DFGSlot) == READY)
				HXGREADY = (HXGSlot ~= nil and myHero:CanUseSpell(HXGSlot) == READY)
				BWCREADY = (BWCSlot ~= nil and myHero:CanUseSpell(BWCSlot) == READY)
				BRKREADY = (BRKSlot ~= nil and myHero:CanUseSpell(BRKSlot) == READY)
				IREADY = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
				QREADY = (myHero:CanUseSpell(_Q) == READY)
				WREADY = (myHero:CanUseSpell(_W) == READY)
				EREADY = (myHero:CanUseSpell(_E) == READY)
				RREADY = (myHero:CanUseSpell(_R) == READY)
		 
				if ts.target ~= nil then
						qPred = qp:GetPrediction(ts.target)
						ePred = ep:GetPrediction(ts.target)
				end
				if tick == nil or GetTickCount()-tick>=100 then
						tick = GetTickCount()
						DmgCalculation()
				end
			   
				--[[    Auto Ignite     ]]-- 
						if IREADY then
								local ignitedmg = 0    
								for i = 1, heroManager.iCount, 1 do
										local enemyhero = heroManager:getHero(i)
										if ValidTarget(enemyhero,600) then
												ignitedmg = 50 + 20 * myHero.level
												if enemyhero.health <= ignitedmg then
														CastSpell(ignite, enemyhero)
												end
										end
								end
						end
		 
				--[[    Harass  ]]--
				if ts.target ~= nil then
						if qPred ~= nil and GetDistance(ts.target) < qRange then
								if VIP_USER and qp:GetHitChance(ts.target) > 0.5 then
										CastSpell(_Q, qPred.x, qPred.z)
								elseif not VIP_USER then
										CastSpell(_Q, qPred.x, qPred.z)
								end
						end
				end
			   
				--[[    Charm   ]]--
						if EREADY and findClosestEnemy() ~= nil then
								ePred2 = ep:GetPrediction(findClosestEnemy())
								if ePRed2 and not ep:GetCollision(findClosestEnemy()) and GetDistance(ePred2) < eRange then
										if VIP_USER and qp:GetHitChance(findClosestEnemy()) > 0.5 then
												CastSpell(_E, ePred2.x, ePred2.z)
										elseif not VIP_USER then
												CastSpell(_E, ePred2.x, ePred2.z)
										end
								end
						end
			   
				--[[    Combo   ]]--
						--[[    Items   ]]--
						if GetDistance(ts.target) < 600 then
								if DFGREADY then CastSpell(DFGSlot, ts.target) end
								if HXGREADY then CastSpell(HXGSlot, ts.target) end
								if BWCREADY then CastSpell(BWCSlot, ts.target) end
								if BRKREADY then CastSpell(BRKSlot, ts.target) end
						end
						--[[    Combo   ]]--
						if RREADY and GetDistance(ts.target) > rBuffer and GetDistance(ts.target) < rRange then
								CastSpell(_R, ts.target.x, ts.target.z)
						end
						if EREADY and ePred ~= nil and GetDistance(ts.target) < eRange then
								if not ep:GetCollision(ts.target) then
										if VIP_USER and qp:GetHitChance(ts.target) > 0.5 then
												CastSpell(_E, ePred.x, ePred.z)
										elseif not VIP_USER then
												CastSpell(_E, ePred.x, ePred.z)
										end
								end
						end
						if QREADY and qPred ~= nil and GetDistance(ts.target) < qRange then
								if VIP_USER and qp:GetHitChance(ts.target) > 0.5 then
										CastSpell(_Q, qPred.x, qPred.z)
								elseif not VIP_USER then
										CastSpell(_Q, qPred.x, qPred.z)
								end
						end
						if WREADY and GetDistance(ts.target) < wRange then
								CastSpell(_W)
						end
						--[[    Attacks ]]--
						if swing == 0 then
								if GetDistance(ts.target) < (myHero.range+100) and GetTickCount() > nextTick and AHConfig.attacks then
										myHero:Attack(ts.target)
										nextTick = GetTickCount()
								end
								elseif swing == 1 then
								if AHConfig.movement and GetTickCount() > (nextTick + 250) then
										myHero:MoveTo(mousePos.x, mousePos.z)
								end
						end
		end
		 
		--[[
		Explanation of the marks:
				-Green circle: Marks the current target to which you will do the combo
				-Blue circle: Killed with a combo, if all the skills were available
				-Red circle: Killed using Items + Q + W + E + R + Ignite(if available)
				-2 Red circles: Killed using Items + Q + W + E + Ignite(if available)
				-3 Red circles: Killed using Q + W     
		]]
		function DmgCalculation()
				local enemy = heroManager:GetHero(calculationenemy)
				if ValidTarget(enemy) then
						local ignitedamage, dfgdamage, hxgdamage, bwcdamage, brkdamage = 0, 0, 0, 0, 0
						local qdamage = getDmg("Q",enemy,myHero)
						local wdamage = getDmg("W",enemy,myHero)
						local edamage = getDmg("E",enemy,myHero)
						local rdamage = getDmg("R",enemy,myHero,1)
						local ignitedamage = (ignite and getDmg("IGNITE",enemy,myHero) or 0)
						local dfgdamage = (DFGSlot and getDmg("DFG",enemy,myHero) or 0)
						local hxgdamage = (HXGSlot and getDmg("HXG",enemy,myHero) or 0)
						local bwcdamage = (BWCSlot and getDmg("BWC",enemy,myHero) or 0)
						local brkdamage = (BRKSlot and getDmg("RUINEDKING",enemy,myHero) or 0)
						local combo1 = qdamage + wdamage + edamage + rdamage
						local combo2 = 0
						local combo3 = 0
						local combo4 = 0
				if QREADY then
						combo2 = combo2 + qdamage
						combo3 = combo3 + qdamage
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
				end
				if RREADY then
						combo2 = combo2 + rdamage
				end
				if DFGREADY then
						combo1 = combo1 + dfgdamage
						combo2 = combo2 + dfgdamage
						combo3 = combo3 + dfgdamage
				end
				if HXGREADY then
						combo1 = combo1 + hxgdamage
						combo2 = combo2 + hxgdamage
						combo3 = combo3 + hxgdamage
				end
				if BWCREADY then
						combo1 = combo1 + bwcdamage
						combo2 = combo2 + bwcdamage
						combo3 = combo3 + bwcdamage
				end
				if BRKREADY then
						combo1 = combo1 + brkdamage
						combo2 = combo2 + brkdamage
						combo3 = combo3 + brkdamage
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
								else calculationenemy = calculationenemy-1
						end
		end
		 
		function findClosestEnemy()
				local closestEnemy = nil
				local currentEnemy = nil
				for i=1, heroManager.iCount do
						currentEnemy = heroManager:GetHero(i)
						if currentEnemy.team ~= myHero.team and not currentEnemy.dead and currentEnemy.visible then
								if closestEnemy == nil then
										closestEnemy = currentEnemy
										elseif GetDistance(currentEnemy) < GetDistance(closestEnemy) then
												closestEnemy = currentEnemy
								end
						end
				end
		return closestEnemy
		end
		 
		function minionCollision(predic, width, range)
				for _, minionObjectE in pairs(enemyMinions.objects) do
						if predic ~= nil and player:GetDistance(minionObjectE) < range then
								ex = player.x
								ez = player.z
								tx = predic.x
								tz = predic.z
								dx = ex - tx
								dz = ez - tz
								if dx ~= 0 then
										m = dz/dx
										c = ez - m*ex
								end
								mx = minionObjectE.x
								mz = minionObjectE.z
								distanc = (math.abs(mz - m*mx - c))/(math.sqrt(m*m+1))
								if distanc < width and math.sqrt((tx - ex)*(tx - ex) + (tz - ez)*(tz - ez)) > math.sqrt((tx - mx)*(tx - mx) + (tz - mz)*(tz - mz)) then
										return true
								end
						end
				end
		return false
		end
----------------------------------------------------------------------------
	elseif GetMyHero().charName == "Alistar" then
		--[[
			Alistar Combo v1.3 by eXtragoZ
		  
				It requires AllClass

			-Full combo: W -> Q
			-Marks the target
			-Target configuration
			-Press shift to configure
		]]
		--[[		Code		]]
		local range = 600
		-- Active
		-- draw
		-- ts
		local ts
		--

		function OnLoad()
			ts = TargetSelector(TARGET_LOW_HP,range,DAMAGE_MAGIC)
			ts.name = "Alistar"
		end

		function OnTick()
			ts:update()
			if ts.target ~= nil and myHero:CanUseSpell(_Q) == READY and myHero:CanUseSpell(_W) == READY and GetDistance(ts.target)<=range then
				CastSpell(_W,ts.target)
				CastSpell(_Q)
			end
		end

		function OnWndMsg(msg,key)
			SC__OnWndMsg(msg,key)
		end
		function OnSendChat(msg)
			TargetSelector__OnSendChat(msg)
			ts:OnSendChat(msg, "pri")
		end
		PrintChat(" >> Alistar Combo 1.3 loaded!")
------------------------------------------------------------------------------------
	elseif GetMyHero().charName == "Evelynn" then
			--[[
					Evelynn Combo 1.6 by burn
					updated season 3 items
					Auto farm lag fixed and MEC requirement removed by HeX
			 
					-Full combo: Items -> R -> E -> Q
					-Supports Deathfire Grasp, Bilgewater Cutlass, Hextech Gunblade, Sheen, Trinity, Lich Bane, Ignite, Iceborn, Liandrys and Blackfire
					-Mark killable target with a combo
					-Target configuration, Press shift to configure
					-Option to auto ignite when enemy is killable (this affect also for damage calculation)
					-MEC calculation for Ulti
					-C toogle auto farm
					-Harass with Q
			 
					Explanation of the marks:
			 
					Green circle: Marks the current target to which you will do the combo
					Blue circle: Mark a target that can be killed with a combo, if all the skills were available
					Red circle: Mark a target that can be killed using Items + 2 hit + R + E + Q x3 + ignite
					2 Red circles: Mark a target that can be killed using Items + 1 hit + R + E + Q x2 + ignite
					3 Red circles: Mark a target that can be killed using Items (without Sheen, Trinity and Lich Bane) + R + E + Q
			]]
			--[[            Code            ]]
			local myObjectsTable = {}
			local range = 600
			local tick = nil
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
			local QREADY, EREADY, RREADY, DFGREADY, HXGREADY, BWCREADY, IREADY = false, false, false, false, false, false, false
			 
			function OnLoad()
					ts = TargetSelector(TARGET_LOW_HP,range+50,DAMAGE_MAGIC)
					ts.name = "Evelynn"
					if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then ignite = SUMMONER_1
					elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then ignite = SUMMONER_2 end
					for i=1, heroManager.iCount do waittxt[i] = i*3 end
				   
					for i = 0, objManager.maxObjects, 1 do
							local object = objManager:GetObject(i)
							if objectIsValid(object) then table.insert(myObjectsTable, object) end
					end
			end
			 
			function objectIsValid(object)
			   return object and object.valid and string.find(object.name,"Minion_") ~= nil and object.team ~= myHero.team and object.dead == false
			end
			 
			function OnTick()
					ts:update()
					DFGSlot, HXGSlot, BWCSlot, SheenSlot, TrinitySlot, LichBaneSlot = GetInventorySlotItem(3128), GetInventorySlotItem(3146), GetInventorySlotItem(3144), GetInventorySlotItem(3057), GetInventorySlotItem(3078), GetInventorySlotItem(3100)
					IcebornSlot, LiandrysSlot, BlackfireSlot = GetInventorySlotItem(3025), GetInventorySlotItem(3151), GetInventorySlotItem(3188)
					QREADY = (myHero:CanUseSpell(_Q) == READY)
					EREADY = (myHero:CanUseSpell(_E) == READY)
					RREADY = (myHero:CanUseSpell(_R) == READY)
					DFGREADY = (DFGSlot ~= nil and myHero:CanUseSpell(DFGSlot) == READY)
					HXGREADY = (HXGSlot ~= nil and myHero:CanUseSpell(HXGSlot) == READY)
					BWCREADY = (BWCSlot ~= nil and myHero:CanUseSpell(BWCSlot) == READY)
					IREADY = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
					if tick == nil or GetTickCount()-tick > 150 then
							tick = GetTickCount()
							DmgCalculation()
					end
					if ts.target and myHero:GetDistance(ts.target) < 500 then
							if QREADY then CastSpell(_Q, ts.target) end 
					end
					if ts.target then
							if DFGREADY then CastSpell(DFGSlot, ts.target) end
							if HXGREADY then CastSpell(HXGSlot, ts.target) end
							if BWCREADY then CastSpell(BWCSlot, ts.target) end
							if RREADY then CastSpell(_R, ts.target) end
							if EREADY then CastSpell(_E, ts.target) end
							if QREADY then CastSpell(_Q, ts.target) end
					end
							local myQ = math.floor((myHero:GetSpellData(_Q).level-1)*20 + 40 + myHero.ap * .4)
									for i,object in ipairs(myObjectsTable) do
											if objectIsValid(object) and object.health <= myHero:CalcDamage(object, myQ) and myHero:GetDistance(object) < 500 then
															CastSpell(_Q, object)
													else
											end
									end
			   
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
			 
			function DmgCalculation()
					local enemy = heroManager:GetHero(calculationenemy)
					if ValidTarget(enemy) then
							local dfgdamage, hxgdamage, bwcdamage, ignitedamage, Sheendamage, Trinitydamage, LichBanedamage  = 0, 0, 0, 0, 0, 0, 0
							local qdamage = getDmg("Q",enemy,myHero)
							local edamage = getDmg("E",enemy,myHero)
							local rdamage = getDmg("R",enemy,myHero)
							local hitdamage = getDmg("AD",enemy,myHero)
							local dfgdamage = (DFGSlot and getDmg("DFG",enemy,myHero) or 0)
							local hxgdamage = (HXGSlot and getDmg("HXG",enemy,myHero) or 0)
							local bwcdamage = (BWCSlot and getDmg("BWC",enemy,myHero) or 0)
							local ignitedamage = (ignite and getDmg("IGNITE",enemy,myHero) or 0)
							local onhitdmg = (SheenSlot and getDmg("SHEEN",enemy,myHero) or 0)+(TrinitySlot and getDmg("TRINITY",enemy,myHero) or 0)+(LichBaneSlot and getDmg("LICHBANE",enemy,myHero) or 0)+(IcebornSlot and getDmg("ICEBORN",enemy,myHero) or 0)                                                
							local onspelldamage = (LiandrysSlot and getDmg("LIANDRYS",enemy,myHero) or 0)+(BlackfireSlot and getDmg("BLACKFIRE",enemy,myHero) or 0)
							local combo1 = qdamage*3 + edamage + rdamage + onspelldamage --0 cd
							local combo2 = onspelldamage
							local combo3 = onspelldamage
							local combo4 = onspelldamage
							if QREADY then
									combo2 = combo2 + qdamage*3
									combo3 = combo3 + qdamage*2
									combo4 = combo4 + qdamage
							end
							if EREADY then
									combo2 = combo2 + edamage
									combo3 = combo3 + edamage
									combo4 = combo4 + edamage
							end
							if RREADY then
									combo2 = combo2 + rdamage
									combo3 = combo3 + rdamage
									combo4 = combo4 + rdamage
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
							if IREADY and EvelynnConfig.autoignite then
									combo1 = combo1 + ignitedamage
									combo2 = combo2 + ignitedamage
									combo3 = combo3 + ignitedamage
							end
							combo1 = combo1 + hitdamage*2 + onhitdmg    
							combo2 = combo2 + hitdamage*2 + onhitdmg
							combo3 = combo3 + hitdamage + onhitdmg        
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
			 
			function OnCreateObj(object)
			   if objectIsValid(object) then table.insert(myObjectsTable, object) end
			end
-------------------------------------------------------------------------------------
	elseif GetMyHero().charName == "Darius" then
			--champ by Λnonymous	
		local drawQrange = true        -- Draw the range of Q
		local useExecutioner = true     -- calculate Executioner or not? True / False
		local havocPoints = 3           -- how many points in Havoc? 0 / 1 / 2 / 3
		local drawUltiInfo = true
		local smoothMultR = 1.0
		local smoothStaticR = -2
		local smoothStaticPerLvl = true
		local smoothDisabledBeforeLvl = 12
		local targetFindRange = 80        -- This is a distance between targeted spell coordinates and your real target's coordinates.
		local qBladeRange = 270
		local qRange = 425
		local eRange = 500 -- lowered since most of the times enemies goes out of the E range while you're casting it
		local rRange = 475
		local wDmgRatioPerLvl = 0.2
		local rDmgRatioPerHemo = 0.2
		local hemoTimeOut = 5000
		local enemyToAttack = nil
		local enemyTable = {}
		local hemoTable = {
			[1] = "darius_hemo_counter_01.troy",
			[2] = "darius_hemo_counter_02.troy",
			[3] = "darius_hemo_counter_03.troy",
			[4] = "darius_hemo_counter_04.troy",
			[5] = "darius_hemo_counter_05.troy",
		}
		local damageTable = {
			Q = { base = 35, baseScale = 35, adRatio = 0.7, },
			R = { base = 70, baseScale = 90, adRatio = 0.75, },
		}
		local checkBuffForUlti = {
			{name="Tryndamere", spellName="undyingRage", enabled=false, spellType=0, spellLevel=1, duration=5000, spellParticle="undyingrage_glow"},
			{name="Kayle", spellName="eyeForEye", enabled=false, spellType=0, spellLevel=1, duration=3000, spellParticle="eyeforaneye"},
			{name="Zilean", spellName="nickOfTime", enabled=false, spellType=0, spellLevel=1, duration=7000, spellParticle="nickoftime_tar"},
			{name="Nocturne", spellName="shroudOfDarkness", enabled=false, spellType=0, spellLevel=1,duration=1500,spellParticle="nocturne_shroudofdarkness_shield_cas_02"},
			{name="Blitzcrank", spellName="manaBarrier", enabled=false, spellType=1, spellLevel=1, duration=10000, spellParticle="manabarrier"},
			{name="Sivir", spellName="spellShield", enabled=false, spellType=0, spellLevel=1, duration=3000, spellParticle="spellblock_eff"}
		}
		for i=0, heroManager.iCount, 1 do
			local playerObj = heroManager:GetHero(i)
			if playerObj and playerObj.team ~= player.team then
				playerObj.hemo = { tick = 0, count = 0, }
				playerObj.pauseTickQ = 0
				playerObj.pauseTickR = 0
				playerObj.canBeUlted = true
				playerObj.immuneTimeout = 0
				playerObj.shield = 0
				table.insert(enemyTable,playerObj)
				for i=1, #checkBuffForUlti, 1 do
					if checkBuffForUlti[i].name == playerObj.charName then
						checkBuffForUlti[i].enabled = true
						PrintChat(checkBuffForUlti[i].spellName.." check enabled")
					end
				end
			end
		end

		function OnCreateObj(obj)
			if obj then
				if string.find(string.lower(obj.name),"darius_hemo_counter") then
					for i, enemy in pairs(enemyTable) do
						if enemy and not enemy.dead and enemy.visible and GetDistance2D(enemy,obj) <= targetFindRange then
							for k, hemo in pairs(hemoTable) do
								if obj.name == hemo then 
									enemy.hemo.tick = GetTickCount()
									enemy.hemo.count = k
									--PrintFloatText(enemy,21,k .. " Bleedings")
								end
							end
						end
					end
				end
			end
		end

		function ChampionInfo(champion)
			local results = {}
			for i=1, #checkBuffForUlti, 1 do
				if checkBuffForUlti[i].name == champion or checkBuffForUlti[i].name == "*" then
					table.insert(results, checkBuffForUlti[i])
				end
			end
			return results
		end

		function CanUltiEnemy(target)
			for i, enemy in pairs(enemyTable) do
				if target.networkID == enemy.networkID then
					if enemy.canBeUlted == false and enemy.immuneTimeout < GetTickCount() then
						enemy.canBeUlted = true
						enemy.immuneTimeout = 0
					end
					return enemy.canBeUlted
				end
			end
		end

		function GetShieldValue(enemy,spellName)
			if spellName == "manaBarrier" then
				return enemy.mana*0.5
			end
		end

		function GetDuration(spellName,spellLevel)
			if spellName == "undyingRage" then return 5000 end
			if spellName == "eyeForEye" then return 1500+500*spellLevel end
			if spellName == "nickOfTime" then return 7000 end
			if spellName == "shroudOfDarkness" then return 1500 end
		end

		function OnTick()
			local rDmg = (damageTable.R.base + (damageTable.R.baseScale*player:GetSpellData(_R).level) +
					damageTable.R.adRatio*player.addDamage) * smoothMultR
			if player.level > smoothDisabledBeforeLvl then
				local rDmgInc = smoothStaticR
				if smoothStaticPerLvl == true then
					rDmgInc = rDmgInc * player.level
				end
				rDmg = rDmg + rDmgInc
			end
			local qDmg = damageTable.Q.base + (damageTable.Q.baseScale*player:GetSpellData(_Q).level) +
					damageTable.Q.adRatio*player.addDamage
			for i, enemy in pairs(enemyTable) do
				local enemyHP = enemy.health + enemy.shield
				if (GetTickCount() - enemy.hemo.tick > hemoTimeOut) or (enemy and enemy.dead) then enemy.hemo.count = 0 end
				if enemy and not enemy.dead and enemy.visible == true and enemy.bTargetable then
					WReady = (myHero:CanUseSpell(_W) == READY and GetDistance(enemy) < 200)
					if WReady then CastSpell(_W) end
					local scale = 1 + havocPoints*0.005
					if useExecutioner and enemyHP < enemy.maxHealth*0.4 then scale = scale + 0.06 end
					qDmg = player:CalcDamage(enemy,qDmg)
					if player:CanUseSpell(_Q) == READY and GetDistance(enemy) < qRange then CastSpell(_Q) end
					if player:CanUseSpell(_E) == READY and GetDistance(enemy) < eRange then CastSpell(_E,enemy.x,enemy.z) end
					--if player:CanUseSpell(_E) == READY and GetDistance(enemy) < eRange then CastSpell(_W) end
					--if GetTickCount() - enemy.pauseTickQ >= 500 and GetTickCount() - enemy.pauseTickR >= 200 then
						if qDmg * scale > enemyHP and player:CanUseSpell(_Q) == READY and GetDistance(enemy) < qRange then
							CastSpell(_Q)
							--enemy.pauseTickQ = GetTickCount()
						elseif ( qDmg * 1.5 ) * scale > enemyHP and player:CanUseSpell(_Q) == READY and GetDistance(enemy) < qRange and GetDistance(enemy) >= qBladeRange then
							CastSpell(_Q)
							--enemy.pauseTickQ = GetTickCount()
						elseif rDmg * ( 1.0 + rDmgRatioPerHemo * enemy.hemo.count ) > enemyHP and player:CanUseSpell(_R) == READY and GetDistance(enemy) < rRange and CanUltiEnemy(enemy) == true then
							CastSpell(_R,enemy)
							--enemy.pauseTickR = GetTickCount()
						end
							if player:GetSpellData(_R).level > 0 and player:GetDistance(enemy) < 3500 and drawUltiInfo == true then
							if CanUltiEnemy(enemy) == false then
								--PrintFloatText(enemy,0,"IMMUNE")
							elseif rDmg * ( 1.0 + rDmgRatioPerHemo * enemy.hemo.count ) > enemyHP then
								--PrintFloatText(enemy,0,"DUNK")
							else
								--PrintFloatText(enemy,0,"" .. math.ceil(enemyHP - (rDmg * ( 1.0 + rDmgRatioPerHemo * enemy.hemo.count ))) .. " hp" .. " - " .. enemy.hemo.count)
							end
						end
					--end
				end
			end
		end	
-----------------------------------------------------------------------------------
	elseif GetMyHero().charName == "MasterYi" then
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
				ts = TargetSelector(TARGET_LOW_HP,range+100,DAMAGE_MAGIC,false)
				ts.name = "MasterYi"
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
				elseif ts.target then
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
		   
			function OnCreateObj(object)
					if object.name == "WujustyleSC_buf.troy" then WujuStyleActive = true end
					if object.name == "Highlander_buf.troy" then UltimateActive = true end
			end
	 
			function OnDeleteObj(object)
					if object.name == "WujustyleSC_buf.troy" then WujuStyleActive = false end
					if object.name == "Highlander_buf.troy" then UltimateActive = false end
			end

-----------------------------------------------------------------------------
	elseif GetMyHero().charName == "Nami" then
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
-------------------------------------------------------------------------------------------------
	elseif myHero.charName == "XinZhao" then
			--champ by Λnonymous
		local ts = TargetSelector(TARGET_LOW_HP,1000,false)
		function OnTick()
			ts:update()
			if ts.target ~= nil and ts.target.dead == false and CountEnemyHeroInRange(1500) <= 3 then
				QReady = (myHero:CanUseSpell(_Q) == READY and GetDistance(ts.target) < 200)
				WReady = (myHero:CanUseSpell(_W) == READY and GetDistance(ts.target) < 200)
				EReady = (myHero:CanUseSpell(_E) == READY and GetDistance(ts.target) < 600)
				RReady = (myHero:CanUseSpell(_R) == READY and GetDistance(ts.target) < 185)
				if EReady then CastSpell(_E, ts.target) end
				if WReady then CastSpell(_W) end
				if QReady then CastSpell(_Q) end
				if RReady then CastSpell(_R) end
			end
		end
		PrintChat("<font color='#E97FA5'>>> XINZHAO DETECTED! LOGIC V1.</font>")
--------------------------------------------------------------------------------------------------		
	else
		local ts = TargetSelector(TARGET_LOW_HP,1000,false)
		function useSpell(ts, spell) -- Yes TRUS, its from your code ( your idea ). Thanks :p
			if ts.target ~= nil and myHero:CanUseSpell(spell) == READY then
				CastSpell(spell, ts.target)
				CastSpell(spell, ts.target.x, ts.target.z)
			end
		end
		function OnTick()
			ts:update()
			useSpell(ts, _Q)
			useSpell(ts, _E)
			useSpell(ts, _W)
		end
	end
end