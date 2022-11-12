require "TimedAction/ISFitnessAction"

local default_update = ISFitnessAction.update
local default_stop = ISFitnessAction.stop
regNum = 0
saveregNum = 0
itsExercise = false
count = 0
sumAverage = 0
totAverage = 0
player = nil	
StrengthLvl = nil
FitnessLvl = nil
StrengthPerk = nil
FitnessPerk = nil

function calcMulExe(character, perkType, perkLvl, PercRegNum)

	if SandboxVars.FitnessIsALifestyle.Hardcore then
		local mulXP = math.floor(100*(((100^((PercRegNum/100)+0.002161)-1)*(SandboxVars.FitnessIsALifestyle.XPMultiplier*(perkLvl+1)))/100))/100 + 1
		character:getXp():addXpMultiplier(perkType,mulXP,perkLvl,10)
	else
		local mulXP = math.ceil(100*((PercRegNum*(SandboxVars.FitnessIsALifestyle.XPMultiplier*(perkLvl+1)))/100))/100 + 1
		character:getXp():addXpMultiplier(perkType,mulXP,perkLvl,10)
	end

end

function ISFitnessAction:update()
	default_update(self)
	itsExercise = true
	player = self.character
	local exerciseName = self.exercise
	StrengthLvl = player:getPerkLevel(Perks.Strength)
	FitnessLvl = player:getPerkLevel(Perks.Fitness)
	StrengthPerk = Perks.Strength
	FitnessPerk = Perks.Fitness

	if player then	
		
		regNum = math.ceil(player:getFitness():getRegularity(exerciseName)*100)/100
		print(regNum)

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
end

function ISFitnessAction:stop()	
	player = self.character	
	StrengthLvl = player:getPerkLevel(Perks.Strength)
	FitnessLvl = player:getPerkLevel(Perks.Fitness)
	StrengthPerk = Perks.Strength
	FitnessPerk = Perks.fitness

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