---------------------#####################################################---------------------
---------------------##                                                                          Quinn                                                                                          ##---------------------
---------------------##                                                                 To the Skies                                                                            ##---------------------
---------------------#####################################################---------------------
if myHero.charName ~= "Quinn" then return end
 
function PluginOnLoad()
        AutoCarry.SkillsCrosshair.range = 1150
        --> Main Load
        mainLoad()
        --> Main Menu
        mainMenu()
        --> Velocity Load
        velocityLoad()
        --> Tower Table
        towersUpdate()
end
 
function PluginOnTick()
        Checks()
        if Target and (AutoCarry.MainMenu.AutoCarry or AutoCarry.MainMenu.MixedMode) then
                if myHero.range > 400 then
                        if QREADY and Menu.useQ and not Col(SkillQ, myHero, Target) then Cast(SkillQ, Target) end
                        if EREADY and Menu.useE then castE(Target) end
                        if Menu.gapE and EREADY then gapE() end
                        if Menu.qKS and QREADY then qKS() end
                elseif myHero.range < 400 then
                        if QREADY and Menu.useQ and GetDistance(Target) <= qRange2 then CastSpell(_Q) end
                        if EREADY and Menu.useE and GetDistance(Target) <= eRange and GetDistance(Target) > qRange2 then
                                CastSpell(_E, Target)
                        end
                        if Menu.rKS and RREADY then rKS() end
                        if Menu.qKS and QREADY then qKS2() end
                end
        end
end
 
function PluginOnDraw()
        if not Menu.drawMaster then
                --> Ranges
                if not myHero.dead then
                        if QREADY and Menu.drawQ then
                                if myHero.range > 400 then DrawCircle(myHero.x, myHero.y, myHero.z, qRange, 0x00FF00)
                                        else DrawCircle(myHero.x, myHero.y, myHero.z, qRange2, 0x00FF00)
                                end
                        end
                        if EREADY and Menu.drawE then
                                DrawCircle(myHero.x, myHero.y, myHero.z, eRange, 0x00FFFF)
                        end
                end
        end
end
 
--> Vault Cast
function castE(target)
        if not inTurretRange(target) then
                if GetDistance(target) >= 450 then
                        local W_Vuln = (Quinn_W_vulnerable and GetDistance(target, Quinn_W_vulnerable) < 40)
                        local W_Tar = (Quinn_W_tar and GetDistance(target, Quinn_W_tar) < 40)
                        if not W_Vuln and not W_Tar then
                                CastSpell(_E, target)
                        end
                elseif Menu.defE and (myHero.health <= myHero.maxHealth*0.25 or GetDistance(target) <= 200) then
                        CastSpell(_E, target)
                end
        end
end
 
--> Blinding Assault KS
function qKS()
        for i, enemy in ipairs(GetEnemyHeroes()) do
                local qDmg = getDmg("Q", enemy, myHero)
                if enemy and not enemy.dead and enemy.health < qDmg then
                        if not Col(SkillQ, myHero, Target) then Cast(SkillQ, enemy) end
                end
        end
end
 
function qKS2()
        for i, enemy in ipairs(GetEnemyHeroes()) do
                local qDmg = getDmg("Q", enemy, myHero)
                if enemy and not enemy.dead and enemy.health < qDmg and GetDistance(enemy) <= qRange then
                        CastSpell(_Q)
                end
        end
end
 
function rKS()
        for i, enemy in ipairs(GetEnemyHeroes()) do
                local rDmg = getDmg("R", enemy, myHero)
                if enemy and not enemy.dead and enemy.health < rDmg and GetDistance(enemy) <= 700 then
                        CastSpell(_R)
                end
        end
end
--> Anti Gapcloser
function gapE()
        for i = 1, heroManager.iCount, 1 do
                local hero = heroManager:getHero(i)
                if ValidTarget(hero, nil, true) then
                        if vTimer[hero.name] <= GetTickCount() and hero and hero.x and hero.z then
                                vTimer[hero.name] = GetTickCount() + vTimeOut
        findmyHeroVelocity(hero, pos[hero.name], t[hero.name])
        pos[hero.name].x = hero.x
        pos[hero.name].z = hero.z
        t[hero.name] = GetTickCount()
      end
                        if v[hero.name] > (hero.ms + vTrigger) and hero.ms > mSpeed and GetDistance(myHero, hero) < vRange then
                                CastSpell(_E, hero)
      end      
    end
  end
end
 
--> Mark Checks
function PluginOnCreateObj(object)
        if object.name == "Quinn_W_tar.troy" then Quinn_W_tar = object end
        if object.name == "Quinn_W_vulnerable.troy" then
                Quinn_W_vulnerable = object
        end
        if object.name == "Quinn_W_mis.troy" then
                Quinn_W_vulnerable = nil
                Quinn_W_tar = nil
        end
end
 
function PluginOnDeleteObj(object)
        if object.name == "Quinn_W_tar.troy" then Quinn_W_tar = nil end
        if object.name == "Quinn_W_vulnerable.troy" then Quinn_W_vulnerable = nil end
end
 
--> Checks
function Checks()
        Target = AutoCarry.GetAttackTarget()
        QREADY = (myHero:CanUseSpell(_Q) == READY)
        EREADY = (myHero:CanUseSpell(_E) == READY)
        RREADY = (myHero:CanUseSpell(_R) == READY)
end
 
--> Main Load
function mainLoad()
        Cast = AutoCarry.CastSkillshot
        Menu = AutoCarry.PluginMenu
        Col = AutoCarry.GetCollision
        qRange, qRange2, eRange = 1050, 375, 725
        QREADY, WREADY, RREADY = false, false, false
        towers = {}
        SkillQ = {spellKey = _Q, range = qRange, speed = 1.55, delay = 220, width = 90}
end
 
--> Main Menu
function mainMenu()
        Menu:addParam("sep", "-- Combo Options --", SCRIPT_PARAM_INFO, "")
        Menu:addParam("gapE", "Vault Gapclosers", SCRIPT_PARAM_ONOFF, true)
        Menu:addParam("defE", "Use Vault Defensively", SCRIPT_PARAM_ONOFF, false)
        Menu:addParam("rKS", "Kill with Tag Team(Melee Only)", SCRIPT_PARAM_ONOFF, true)
        Menu:addParam("qKS", "Kill with Blinding Assault", SCRIPT_PARAM_ONOFF, true)
        Menu:addParam("sep1", "-- Ability Options --", SCRIPT_PARAM_INFO, "")
        Menu:addParam("useQ", "Use - Blinding Assault", SCRIPT_PARAM_ONOFF, true)
        Menu:addParam("useE", "Use - Vault", SCRIPT_PARAM_ONOFF, true)
        Menu:addParam("sep3", "-- Draw Options --", SCRIPT_PARAM_INFO, "")
        Menu:addParam("drawMaster", "Disable Draw", SCRIPT_PARAM_ONOFF, false)
        Menu:addParam("drawQ", "Draw - Blinding Assault", SCRIPT_PARAM_ONOFF, false)
        Menu:addParam("drawE", "Draw - Vault", SCRIPT_PARAM_ONOFF, false)
end
 
--> Tower Checks
function towersUpdate()
        for i = 1, objManager.iCount, 1 do
                local obj = objManager:getObject(i)
                if obj ~= nil and string.find(obj.type, "obj_Turret") ~= nil and string.find(obj.name, "_A") == nil and obj.health > 0 then
                        if not string.find(obj.name, "TurretShrine") and obj.team ~= player.team then
                                table.insert(towers, obj)
                        end
                end
        end
end
 
function inTurretRange(unit)
        local check = false
        for i, tower in ipairs(towers) do
                if tower.health > 0 then
                        if math.sqrt((tower.x - unit.x) ^ 2 + (tower.z - unit.z) ^ 2) < 650 then
                                check = true
                        end
                else
                        table.remove(towers, i)
                end
        end
return check
end    
 
--> Special thanks to llama and Manciuszz for the Velocity calculations. I took this from jbman's Jayce script. I hope you don't mind me using it :3
--> Velocity Checks
function findmyHeroVelocity(target, pos, t)
  if pos.x and pos.z and target.x and target.z then
    local dis = math.sqrt((pos.x - target.x) ^ 2 + (pos.z - target.z) ^ 2)
    v[target.name] = (dis / (GetTickCount() - t)) * cFactor
  end
end
 
function velocityLoad()
  vTimer = {}
  pos = {}
  v = {}
  t = {}
       
  vTimeOut = 5
  cFactor = 975
  vTrigger = 375
  mSpeed = 300
  vRange = 450
 
        for i = 1, heroManager.iCount, 1 do
                local hero = heroManager:getHero(i)
    if hero.team == TEAM_ENEMY then
      pos[hero.name] = {}
                        t[hero.name] = {}
      v[hero.name] = 0
      vTimer[hero.name] = 0
    end
  end
end