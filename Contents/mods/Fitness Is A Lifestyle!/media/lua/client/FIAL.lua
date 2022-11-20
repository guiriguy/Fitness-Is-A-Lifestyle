require "TimedActions/ISFitnessAction"

-- Variables
-- Game TimedActions
local default_start = ISFitnessAction.start
local default_exeLooped = ISFitnessAction.exeLooped
local default_stop = ISFitnessAction.stop
-- Strength Info
local _PerkStrength
local _LvlPerkStrength
local _TypePerkStrength
local fOfStrength --(Float) Indicates the amount of XP that Strength has received (vanilla)
-- Fitness Info
local _PerkFitness
local _LvlPerkFitness
local _TypePerkFitness
local fOfFitness --(Float) Indicates the amount of XP that Fitness has received (vanilla)
-- Exercise Info
local _ExerciseName
local isExercising
local _getRegularityExercise
-- Maths to Exercise
local _sumAvgRegularity
local NumberOfExercises
local _totalAvgRegularity
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
--[[Posible addons
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
    if _player then
        if tostring(_perk) == "Strength" then
            _PerkStrength = _perk
            _LvlPerkStrength = _player:getPerkLevel(_perk)
            _TypePerkStrength = _PerkStrength:getType()
            if _float >= 0 then
                fOfStrength = _float
            end
        elseif tostring(_perk) == "Fitness" then
            _PerkFitness = _perk
            _LvlPerkFitness = _player:getPerkLevel(_perk)
            _TypePerkFitness = _PerkFitness:getType()
            if _float >= 0 then
                fOfFitness = _float
            end
        end
    end
end
local KeyTextTalk = function(_KeyPressed)
    for playerIndex=0,getNumActivePlayers()-1 do
        local _player = getSpecificPlayer(playerIndex)
        if _player and not _player:isDead() then
            if isShiftKeyDown() and _KeyPressed == 60 then
                _player:Say("I'm TEZTING")
                _player:Say("So my player is:")
                _player:Say(tostring(_player))
            end
        end
    end

end
local mathMulXP =  function(character, perkType, perkLvl, RegNum)
    local RegNumBool = 0
    local mulXP = 0
    local fixedRegNum = 0
    if RegNum > 0 then
        RegNumBool = 0.01
        fixedRegNum = RegNum /100
    end
    if XPHardcore then
        if mulXPxLevel then
            mulXP = mathsUp00(((100^(fixedRegNum))*RegNumBool)*((_G["mulLvl"..tostring(perkLvl)])-1)) + 1
            character:getXp():addXpMultiplier(perkType,mulXP,perkLvl,10)
        else
            mulXP = mathsUp00(((100^(fixedRegNum))*RegNumBool)*((SLM1-1)+((SLM10-SLM1)*((perkLvl+1)/10)))) + 1
            character:getXp():addXpMultiplier(perkType,mulXP,perkLvl,10)
        end
    else
        if mulXPxLevel then
            mulXP = mathsUp00(fixedRegNum*((_G["mulLvl"..tostring(perkLvl)])-1)) + 1
            character:getXp():addXpMultiplier(perkType,mulXP,perkLvl,10)
        else
            mulXP = mathsUp00(fixedRegNum*((SLM1-1)+((SLM10-SLM1)*((perkLvl+1)/10)))) + 1
            character:getXp():addXpMultiplier(perkType,mulXP,perkLvl,10)
        end
    end
end
local CheckRegularity = function ()
    for playerIndex=0,getNumActivePlayers()-1 do
        local _player = getSpecificPlayer(playerIndex)
        if _player and not _player:isDead() then
            if not itsExercise then
                if _PerkFitness and _PerkStrength and _LvlPerkFitness and _LvlPerkStrength then
                    for k,v in pairs(FitnessExercises.exercisesType) do
                        NumberOfExercises = NumberOfExercises + 1
                        _sumAvgRegularity = mathsUp00((_sumAvgRegularity + _player:getFitness():getRegularity(k)))
                    end
                    _totalAvgRegularity = mathsUp00((_sumAvgRegularity/ NumberOfExercises))

                    mathMulXP(_player, _PerkStrength, _LvlPerkStrength, _totalAvgRegularity)
                    mathMulXP(_player, _PerkFitness, _LvlPerkFitness, _totalAvgRegularity)

                    NumberOfExercises = 0
                    _sumAvgRegularity = 0
                end

            end
        end
    end
end
--[[local ModifyXP = function(_type, _xp)

end]]--
--Code
--Check Mods for compatibilty
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

local original_DTexerciseMultiplierIfMaxRegularity
local function new_DTexerciseMultiplierIfMaxRegularity()
    --print("Disabled DT OG code")
end
-- Compatibilities
-- DynamicTraits
if ISModLoaded["DynamicTraits"] then
    Events.OnGameBoot.Add(function()
        original_DTexerciseMultiplierIfMaxRegularity = exerciseMultiplierIfMaxRegularity
        exerciseMultiplierIfMaxRegularity = new_DTexerciseMultiplierIfMaxRegularity
        print("Supposedly added compatibility")
    end)
end
--Start of Exercise
function ISFitnessAction:start()
    default_start(self)
    local _player = self.character
    if _player and not _player:isDead() then
        isExercising = true
        _ExerciseName = self.exercise
        --print(_ExerciseName)
        if _ExerciseName then
            _getRegularityExercise = mathsUp00(_player:getFitness():getRegularity(_ExerciseName))
        end
    end
end
--Loop of Exercise
function ISFitnessAction:exeLooped()
    default_exeLooped(self)
    local _player = self.character
    if _player and not _player:isDead() then
        if not isExercising or not _ExerciseName then
            isExercising = true
            _ExerciseName = self.exercise
            --print(_ExerciseName)
        end
        --[[print(FitnessExercises.exercisesType[tostring(_ExerciseName)]["xpMod"])
        FitnessExercises.exercisesType[tostring(_ExerciseName)]["xpMod"] = 1000
        print(FitnessExercises.exercisesType[tostring(_ExerciseName)]["xpMod"])
        print(self.exeData["xpMod"])
        StoreDataTest = _player:getModData().LastTimeExercise
        if StoreDataTest then
            _player:getModData().LastTimeExercise = StoreDataTest + 10
            print("Added 10")
            print(_player:getModData().LastTimeExercise)
        else
            print("Created LastTimeExercise")
            _player:getModData().LastTimeExercise = 0
        end]]--
        --print("Looping")
        -- Works! print(_G["modLvl"..tostring(_LvlPerkFitness)])
        _getRegularityExercise = mathsUp00(_player:getFitness():getRegularity(_ExerciseName))
        if _getRegularityExercise then
            mathMulXP(_player, _PerkStrength, _LvlPerkStrength, _getRegularityExercise)
            mathMulXP(_player, _PerkFitness, _LvlPerkFitness, _getRegularityExercise)
        end
        if modXPEnable then
            if fOfFitness then
                if not modXPxLevel then
                    _player:getXp():AddXP(_TypePerkFitness, (fOfFitness * -1))
                    _player:getXp():AddXP(_TypePerkFitness, (mathsUp00((fOfFitness * (SVLM1+((SVLM10-SVLM1)*((_LvlPerkFitness+1)/10)))))))
                    if ISModLoaded["DynamicTraits"] and _player:HasTrait("Prodigy") then
                        _player:getXp():AddXP(_TypePerkFitness, ((self.exeData.xpMod * 20) * -1))
                        _player:getXp():AddXP(_TypePerkFitness, mathsUp00((self.exeData.xpMod * 20) * (SVLM1+((SVLM10-SVLM1)*((_LvlPerkFitness+1)/10)))))
                    end
                else
                    _player:getXp():AddXP(_TypePerkFitness, (fOfFitness * -1))
                    _player:getXp():AddXP(_TypePerkFitness, (mathsUp00((fOfFitness * (_G["modLvl"..tostring(_LvlPerkFitness)])))))
                    if ISModLoaded["DynamicTraits"] and _player:HasTrait("Prodigy") then
                        _player:getXp():AddXP(_TypePerkFitness, ((self.exeData.xpMod * 20) * -1))
                        _player:getXp():AddXP(_TypePerkFitness, mathsUp00((self.exeData.xpMod * 20) * (_G["modLvl"..tostring(_LvlPerkFitness)])))
                    end
                end
            end
            if fOfStrength then
                if not modXPxLevel then
                    _player:getXp():AddXP(_TypePerkStrength, (fOfStrength * -1))
                    _player:getXp():AddXP(_TypePerkStrength, (mathsUp00((fOfStrength * (SVLM1+((SVLM10-SVLM1)*((_LvlPerkStrength+1)/10)))))))
                    if ISModLoaded["DynamicTraits"] and _player:HasTrait("Prodigy") then
                        _player:getXp():AddXP(_TypePerkStrength, ((self.exeData.xpMod * 20) * -1))
                        _player:getXp():AddXP(_TypePerkStrength, mathsUp00((self.exeData.xpMod * 20) * (SVLM1+((SVLM10-SVLM1)*((_LvlPerkStrength+1)/10)))))
                    end
                else
                    _player:getXp():AddXP(_TypePerkStrength, (fOfStrength * -1))
                    _player:getXp():AddXP(_TypePerkStrength, (mathsUp00((fOfStrength * (_G["modLvl"..tostring(_LvlPerkStrength)])))))
                    if ISModLoaded["DynamicTraits"] and _player:HasTrait("Prodigy") then
                        _player:getXp():AddXP(_TypePerkStrength, ((self.exeData.xpMod * 20) * -1))
                        _player:getXp():AddXP(_TypePerkStrength, mathsUp00((self.exeData.xpMod * 20) * (_G["modLvl"..tostring(_LvlPerkStrength)])))
                    end
                end
            end
        end
    end
end
--End of Exercise
function ISFitnessAction:stop()
    local _player = self.character
    if _player then
        isExercising = false
        _ExerciseName = nil
        _getRegularityExercise = 0
        _sumAvgRegularity = 0
        _totalAvgRegularity = 0
        fOfStrength = 0
        fOfFitness = 0
    end
    default_stop(self)
end
--Events
Events.OnKeyPressed.Add(KeyTextTalk)
Events.AddXP.Add(XPGiven)
Events.OnLoad.Add(Starter)
Events.EveryTenMinutes.Add(CheckRegularity)
--Events.OnCharacterDeath.Add(ResetPlayer)

--[[Legacy//for references

--local _saveRegularityExercise
--local maths
local mathMulXP =  function(character, perkType, perkLvl, RegNum)
    local RegNumBool = 0
    local mulXP = 0
    local fixedRegNum = 0
    --print("MathMulXP Called")
    if RegNum > 0 then
        RegNumBool = 0.01
        fixedRegNum = RegNum /100
    end
    if XPHardcore then
if not SimpleLevelMultiplier and not mulXPxLevel then
            local mulXP = mathsUp00((((100^((PercRegNum/100)+0.002161)-1)*(XPMultiplier*(perkLvl+1)))/100)) + 1
            character:getXp():addXpMultiplier(perkType,mulXP,perkLvl,10)
        else
if mulXPxLevel then
    mulXP = mathsUp00(((100^(fixedRegNum))*RegNumBool)*((_G["mulLvl"..tostring(perkLvl)])-1)) + 1
    --mulXP = mathsUp00((((100^((PercRegNum/100)+0.002161)-1)*(_G["mulLvl"..tostring(perkLvl)]))/100)) + 1 // Legacy
    character:getXp():addXpMultiplier(perkType,mulXP,perkLvl,10)
else
    mulXP = mathsUp00(((100^(fixedRegNum))*RegNumBool)*((SLM1-1)+((SLM10-SLM1)*((perkLvl+1)/10)))) + 1
    --mulXP = mathsUp00((((100^((PercRegNum/100)+0.002161)-1)*(SLM1+((SLM10-SLM1)*((perkLvl+1)/10))))/100)) + 1 // Legacy
    character:getXp():addXpMultiplier(perkType,mulXP,perkLvl,10)
end
else
if not SimpleLevelMultiplier and not mulXPxLevel then
    mulXP = mathsUp00(((PercRegNum*(XPMultiplier*(perkLvl+1)))/100)) + 1
    character:getXp():addXpMultiplier(perkType,mulXP,perkLvl,10)
else
if mulXPxLevel then
mulXP = mathsUp00(fixedRegNum*((_G["mulLvl"..tostring(perkLvl)])-1)) + 1
--mulXP = mathsUp00(((PercRegNum*(_G["mulLvl"..tostring(perkLvl)]))/100)) + 1 // Legacy
character:getXp():addXpMultiplier(perkType,mulXP,perkLvl,10)
else
mulXP = mathsUp00(fixedRegNum*((SLM1-1)+((SLM10-SLM1)*((perkLvl+1)/10)))) + 1
--mulXP = mathsUp00(((PercRegNum*(SLM1+((SLM10-SLM1)*((perkLvl+1)/10))))/100)) + 1 // Legacy
character:getXp():addXpMultiplier(perkType,mulXP,perkLvl,10)
end
end
end

local default_update = ISFitnessAction.update

function ISFitnessAction:update()
	default_update(self)
	itsExercise = true
	player = self.character
	local exerciseName = self.exercise
	StrengthPerk = Perks.Strength
	FitnessPerk = Perks.Fitness
	StrengthLvl = player:getPerkLevel(StrengthPerk)
	FitnessLvl = player:getPerkLevel(FitnessPerk)

	if player then

		regNum = math.ceil(player:getFitness():getRegularity(exerciseName)*100)/100

		if not itsExercise then
			itsExercise = true
			totAverage = 0
		end

		if regNum ~= saveregNum then
			saveregNum = regNum
			calcMulExe(player, StrengthPerk, StrengthLvl, saveregNum)
			calcMulExe(player, FitnessPerk, FitnessLvl, saveregNum)
		end
	end

function ISFitnessAction:stop()
	player = self.character
	StrengthPerk = Perks.Strength
	FitnessPerk = Perks.Fitness
	StrengthLvl = player:getPerkLevel(StrengthPerk)
	FitnessLvl = player:getPerkLevel(FitnessPerk)
	--print("type")
	--print(FitnessPerk:getType())

	for k,v in pairs(FitnessExercises.exercisesType) do
		count = count + 1
		sumAverage = (math.ceil((sumAverage + player:getFitness():getRegularity(k))*100))/100
	end

	totAverage = math.ceil((sumAverage/count)*100)/100

	calcMulExe(player, StrengthPerk, StrengthLvl, totAverage)
	calcMulExe(player, FitnessPerk, FitnessLvl, totAverage)

	count = 0
	sumAverage = 0
	regNum = 0
	saveregNum = 0
	itsExercise = false
	default_stop(self)

end

RequireISFA = function()
    ISFACall = require "TimedActions/ISFitnessAction"
end

if pcall(ISFACall) then
    print("it's working")
    print(ISFACall)
else
    print("it's not working")
    pcall(RequireISFA)
    print("Recalled")
end

gettin player

                for playerIndex=0,getNumActivePlayers()-1 do
                    local character = getSpecificPlayer(playerIndex)
                    if character and not character:isDead() then
                    end
                end

]]--