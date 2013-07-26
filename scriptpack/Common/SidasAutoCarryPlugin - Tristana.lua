--[[ Auto Carry Plugin: Tristana ]]--
 
local spellW = {spellKey = _W, range = 900, speed = 1500, delay = 250, width = 200, minions = false }
 
AutoCarry.PluginMenu:addParam("KillStealW", "Killsteal - Rocket Jump", SCRIPT_PARAM_ONOFF, true)    
AutoCarry.PluginMenu:addParam("KillStealR", "Killsteal - Buster Shot", SCRIPT_PARAM_ONOFF, true)
 
 
 
 
function PluginOnTick()
 
if AutoCarry.PluginMenu.KillStealW then
                KillStealW()
end
 
if AutoCarry.PluginMenu.KillStealR then
        KillStealR()
 end
 
end
 
 
 
function KillStealR()
 
        local RRange = 645
 
      for _, enemy in pairs(AutoCarry.EnemyTable) do
 
      if ValidTarget(enemy, RRange) and enemy.health < getDmg("R", enemy, myHero) then
 
         CastSpell(_R, enemy)
 
      end
 
   end
 
end
 
function KillStealW()
 
        local WRange = 900
 
        for _, enemy in pairs(AutoCarry.EnemyTable) do
 
                if ValidTarget(enemy, WRange)  and not enemy.dead then
 
                        if enemy.health < getDmg("W", enemy, myHero) then
 
                                AutoCarry.CastSkillshot(spellW, enemy)
 
                        end
 
                end
 
        end
 
end