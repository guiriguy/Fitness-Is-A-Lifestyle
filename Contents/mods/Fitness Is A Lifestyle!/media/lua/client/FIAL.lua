require "TimedActions/ISFitnessAction"

--Check Mods for compatibility
local CompMods = {
    ["MoreSimpleTraitsVanilla"] = "MSTVanillaFitnessAction",
    ["MoreSimpleTraits"] = "MSTFitnessAction",
    ["DynamicTraits"] = "DTnewMechanics",
    ["DynamicTraits"] = "DTexpandedActionsEffects"
}
local ISModLoaded = {}
local LookModName = getActivatedMods()
for i = 1, LookModName:size() do
    local modID = LookModName:get(i-1)
    if CompMods[modID] and not ISModLoaded[modID] then
        require (CompMods[modID])
        ISModLoaded[modID] = true
        print("FIAL: Added compatibility to: "..tostring(modID))
    end
end
-- Compatibilities
--Modification for Compatibilities
-- DynamicTraits
local original_DTexerciseMultiplierIfMaxRegularity
local function new_DTexerciseMultiplierIfMaxRegularity()
    print("FIAL: Disabled DT OG code")
end
if ISModLoaded["DynamicTraits"] then
    Events.OnGameBoot.Add(function()
        original_DTexerciseMultiplierIfMaxRegularity = exerciseMultiplierIfMaxRegularity
        exerciseMultiplierIfMaxRegularity = new_DTexerciseMultiplierIfMaxRegularity
        print("FIAL: Changed a bit of Dynamic Traits' code to be compatible ")
    end)
end

-- Variables
-- Game TimedActions
local OGISFA_start = ISFitnessAction.start
local OGISFA_exeLooped = ISFitnessAction.exeLooped
local OGISFA_stop = ISFitnessAction.stop
-- Exercise Info
local isExercising
local _getRegularityExercise
local FitnessPerk = Perks.Fitness
local StrengthPerk = Perks.Strength
-- Maths to Exercise
local _sumAvgRegularity
local NumberOfExercises
local _totalAvgRegularity
local subtract = false
--Options
--Base Options
local XPHardcore
local SLM1
local SLM10
--Extra Vanilla XP Mod Options
local modXPEnable
local SVLM1
local SVLM10
--Extra Multiplier per Level Options
local mulXPxLevel
local mulLvl0
local mulLvl1
local mulLvl2
local mulLvl3
local mulLvl4
local mulLvl5
local mulLvl6
local mulLvl7
local mulLvl8
local mulLvl9
--Extra Vanilla XP Mod per Level Modifiers Options
local modXPxLevel
local modLvl0
local modLvl1
local modLvl2
local modLvl3
local modLvl4
local modLvl5
local modLvl6
local modLvl7
local modLvl8
local modLvl9
--[[Possible addons
local ExIsStrength --(Boolean) Indicates that the perk exercised is Strength
local ExIsFitness --(Boolean) Indicates that the perk exercised is Fitness]]--
-- Functions
local Starter = function()
    XPHardcore = SandboxVars.FitnessIsALifestyle.Hardcore
    SLM1 = SandboxVars.FitnessIsALifestyle.SLM1
    SLM10 = SandboxVars.FitnessIsALifestyle.SLM10
    modXPEnable = SandboxVars.FitnessIsALifestyle.VanillaMod
    SVLM1 = SandboxVars.FitnessIsALifestyle.SVLM1
    SVLM10 = SandboxVars.FitnessIsALifestyle.SVLM10
    mulXPxLevel = SandboxVars.FitnessIsALifestyleXLvl.XPPerLevel
    mulLvl0 = SandboxVars.FitnessIsALifestyleXLvl.XPLvl1
    mulLvl1 = SandboxVars.FitnessIsALifestyleXLvl.XPLvl2
    mulLvl2 = SandboxVars.FitnessIsALifestyleXLvl.XPLvl3
    mulLvl3 = SandboxVars.FitnessIsALifestyleXLvl.XPLvl4
    mulLvl4 = SandboxVars.FitnessIsALifestyleXLvl.XPLvl5
    mulLvl5 = SandboxVars.FitnessIsALifestyleXLvl.XPLvl6
    mulLvl6 = SandboxVars.FitnessIsALifestyleXLvl.XPLvl7
    mulLvl7 = SandboxVars.FitnessIsALifestyleXLvl.XPLvl8
    mulLvl8 = SandboxVars.FitnessIsALifestyleXLvl.XPLvl9
    mulLvl9 = SandboxVars.FitnessIsALifestyleXLvl.XPLvl10
    modXPxLevel = SandboxVars.FitnessIsALifestyleXLvl.XPModPerLevel
    modLvl0 = SandboxVars.FitnessIsALifestyleXLvl.XPModLvl1
    modLvl1 = SandboxVars.FitnessIsALifestyleXLvl.XPModLvl2
    modLvl2 = SandboxVars.FitnessIsALifestyleXLvl.XPModLvl3
    modLvl3 = SandboxVars.FitnessIsALifestyleXLvl.XPModLvl4
    modLvl4 = SandboxVars.FitnessIsALifestyleXLvl.XPModLvl5
    modLvl5 = SandboxVars.FitnessIsALifestyleXLvl.XPModLvl6
    modLvl6 = SandboxVars.FitnessIsALifestyleXLvl.XPModLvl7
    modLvl7 = SandboxVars.FitnessIsALifestyleXLvl.XPModLvl8
    modLvl8 = SandboxVars.FitnessIsALifestyleXLvl.XPModLvl9
    modLvl9 = SandboxVars.FitnessIsALifestyleXLvl.XPModLvl10
    _sumAvgRegularity = 0
    NumberOfExercises = 0
    _totalAvgRegularity = 0
    _getRegularityExercise = 0
    isExercising = false
end
local mathsUp00 = function(x)
    x = math.ceil(x*100)/100
    return x
end
local XPGiven = function(_player, _perk, _float)
    if _player and _float > 0 and isExercising then
        if subtract and (_perk == Perks.Fitness or _perk == Perks.Strength) then
            _player:getXp():AddXP(_perk, _float * -1, true, false, false)
            subtract = false
            if modXPxLevel then
                _player:getXp():AddXP(_perk, _float * (_G["modLvl"..tostring(_player:getPerkLevel(_perk))]),true,false,false)
            else
                _player:getXp():AddXP(_perk,(_float * (SVLM1+((SVLM10-SVLM1)*((_player:getPerkLevel(_perk))/10)))),true,false,false)
            end
            subtract = true
        end
    end
end
local mathMulXP =  function(character, perk, perkLvl, RegNum)
    local RegNumBool = 0
    local mulXP = 0
    local fixedRegNum = 0
    local playerLevel = character:getPerkLevel(perk)
    if RegNum > 0 then
        RegNumBool = 0.01
        fixedRegNum = RegNum /100
    end
    if mulXPxLevel then
        if XPHardcore then
            mulXP = mathsUp00(((100^(fixedRegNum))*RegNumBool)*((_G["mulLvl"..tostring(perkLvl)])-1)) + 1
        else
            mulXP = mathsUp00(fixedRegNum*((_G["mulLvl"..tostring(perkLvl)])-1)) + 1
        end
    else
        if XPHardcore then
            mulXP = mathsUp00(((100^(fixedRegNum))*RegNumBool)*((SLM1-1)+((SLM10-SLM1)*((perkLvl)/10)))) + 1
        else
            mulXP = mathsUp00(fixedRegNum*((SLM1-1)+((SLM10-SLM1)*((perkLvl)/10)))) + 1
        end
    end
    if mulXP > 1 and playerLevel < 10 then
        character:getXp():addXpMultiplier(perk,mulXP,perkLvl,10)
    else
        character:getXp():addXpMultiplier(perk,0,perkLvl,10)
    end
end
local CheckRegularity = function ()
    for i = 0,getNumActivePlayers()-1 do
        local _player = getSpecificPlayer(i)
        if _player and not _player:isDead() then
            if not isExercising then
                for k in pairs(FitnessExercises.exercisesType) do
                    NumberOfExercises = NumberOfExercises + 1
                    _sumAvgRegularity = mathsUp00((_sumAvgRegularity + _player:getFitness():getRegularity(k)))
                end
                _totalAvgRegularity = mathsUp00((_sumAvgRegularity/ NumberOfExercises))
                mathMulXP(_player, StrengthPerk, _player:getPerkLevel(StrengthPerk), _totalAvgRegularity)
                mathMulXP(_player, FitnessPerk, _player:getPerkLevel(FitnessPerk), _totalAvgRegularity)
                NumberOfExercises = 0
                _sumAvgRegularity = 0
            end
        end
    end
end
--[[local ModifyXP = function(_type, _xp)
end]]--
--Code
--Start of Exercise
function ISFitnessAction:start()
    local _player = self.character
    if not _player:isNPC() and not _player:isDead() then
        isExercising = true
        if modXPEnable then
            subtract = true
        end
        OGISFA_start(self)
        _getRegularityExercise = mathsUp00(_player:getFitness():getRegularity(self.exercise))
        if _getRegularityExercise then
            mathMulXP(_player, StrengthPerk, _player:getPerkLevel(StrengthPerk), _getRegularityExercise)
            mathMulXP(_player, FitnessPerk, _player:getPerkLevel(FitnessPerk), _getRegularityExercise)
        end
    end
end
--Loop of Exercise
function ISFitnessAction:exeLooped()
    local _player = self.character
    if not _player:isNPC() and not _player:isDead() then
        isExercising = true
        if modXPEnable then
            subtract = true
        end
        OGISFA_exeLooped(self)
        subtract = false
        _getRegularityExercise = mathsUp00(_player:getFitness():getRegularity(self.exercise))
        if _getRegularityExercise then
            mathMulXP(_player, StrengthPerk, _player:getPerkLevel(StrengthPerk), _getRegularityExercise)
            mathMulXP(_player, FitnessPerk, _player:getPerkLevel(FitnessPerk), _getRegularityExercise)
        end
    end
end
--End of Exercise
function ISFitnessAction:stop()
    OGISFA_stop(self)
    local _player = self.character
    if not _player:isNPC() and not _player:isDead() then
        isExercising = false
        _getRegularityExercise = 0
        _sumAvgRegularity = 0
        _totalAvgRegularity = 0
        subtract = false
        CheckRegularity()
    end
end
--Events
Events.AddXP.Add(XPGiven)
Events.OnLoad.Add(Starter)
Events.EveryTenMinutes.Add(CheckRegularity)