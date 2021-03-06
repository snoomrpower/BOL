--[[
Auto Carry Plugin - Ezreal Edition - Puze
--]]
if myHero.charName ~= "Ezreal" then return end
 
-- Constants
local QRange = 1100
local WRange = 1050
local RRange = 2000
 
local QSpeed = 2.0
local WSpeed = 1.6
local RSpeed = 1.7
 
local QDelay = 251
local WDelay = 250
local RDelay = 1000
 
local QWidth = 80
 
-- Prediction
local SkillQ = {spellKey = _Q, range = QRange, speed = QSpeed, delay = QDelay, width = QWidth}
local SkillW = {spellKey = _W, range = WRange, speed = WSpeed, delay = WDelay}
local SkillR = {spellKey = _R, range = RRange, speed = RSpeed, delay = RDelay}
 
function PluginOnLoad()
        AutoCarry.PluginMenu:addParam("combo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
        AutoCarry.PluginMenu:addParam("harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, 65)
        AutoCarry.PluginMenu:addParam("ultimate", "Use ultimate in combo", SCRIPT_PARAM_ONOFF, false)
        AutoCarry.PluginMenu:addParam("wcombo", "Use W in combo", SCRIPT_PARAM_ONOFF, true)
        AutoCarry.PluginMenu:addParam("draw", "Draw circles", SCRIPT_PARAM_ONOFF, true)
        AutoCarry.PluginMenu:permaShow("harass")
end
 
function PluginOnTick()
        Target = AutoCarry.GetAttackTarget()
 
        if AutoCarry.PluginMenu.combo then
                Combo()
        end
 
        if AutoCarry.PluginMenu.harass then
                Harass()
        end
end
 
function Combo()
        if Target ~= nil then
 
                if AutoCarry.PluginMenu.ultimate then
                        if myHero:CanUseSpell(_R) == READY and GetDistance(Target) <= RRange then
                                AutoCarry.CastSkillshot(SkillR, Target)
                        end
                end
 
 
                if myHero:CanUseSpell(_Q) == READY and GetDistance(Target) <= QRange then
                        if not AutoCarry.GetCollision(SkillQ, myHero, Target) then
                                AutoCarry.CastSkillshot(SkillQ, Target)
                        end
                end
 
 
                if AutoCarry.PluginMenu.w then
                        if myHero:CanUseSpell(_W) == READY and GetDistance(Target) <= WRange then
                                AutoCarry.CastSkillshot(SkillW, Target)
                        end
                end
 
        end
end
 
function Harass()
        if Target ~= nil then
                if myHero:CanUseSpell(_Q) == READY and GetDistance(Target) <= QRange then
                        if not AutoCarry.GetCollision(SkillQ, myHero, Target) then
                                AutoCarry.CastSkillshot(SkillQ, Target)
                        end
                end
        end
end
 
function PluginOnDraw()
        if AutoCarry.PluginMenu.draw then
                if myHero:CanUseSpell(_Q) then
                        DrawCircle(myHero.x, myHero.y, myHero.z, 1100, 0xFF0000)
                end
        end
end