local newLevelSound = playdate.sound.sampleplayer.new("assets/sounds/highscore.wav")

local tokill = {
	playdate.graphics.image.new("assets/images/toKill0"),
	playdate.graphics.image.new("assets/images/toKill1"),
	playdate.graphics.image.new("assets/images/toKill2"),
	playdate.graphics.image.new("assets/images/toKill3"),
	playdate.graphics.image.new("assets/images/toKill4"),
	playdate.graphics.image.new("assets/images/toKill5")
}

local thatWasEasy = playdate.sound.sampleplayer.new("assets/sounds/thatWasEasy.wav")
local thatWasHard = playdate.sound.sampleplayer.new("assets/sounds/thatWasHard.wav")
local itsTimeToKill = playdate.sound.sampleplayer.new("assets/sounds/itsTimeToKil.wav")

local function CreateLevel()
	local self = {}
	self.waves = {}
	self.waveNumber = 1
	self.finished = false
	self.callbackCalled = false

	function self.addWave(enemyList)
		self.waves[#self.waves + 1] = enemyList
	end

	function self.addEndlevelCallback(callback)
		self.endLevelCallback = callback
	end

	function self.nextWave()
		if self.waveNumber <= #self.waves then
			local list = self.waves[self.waveNumber]
			print("starting wave", self.waveNumber)
			for i = 1, #list, 1 do
				local e = list[i]
				CreateEnemy(
					e.x or math.random(0, 400), e.y or math.random(0, 240),
					e.enemyType,
					e.enemyLife,
					e.speed,
					e.r
				)
			end

			self.waveNumber = self.waveNumber + 1
		else
			self.finished = true
		end
	end

	function self.checkWave()
		if GetEnemiesAliveCount() <= 0 then
			self.nextWave()
		end

		if self.finished and (not self.callbackCalled) then
			SpawnWeaponBox()

			self.finished = false
			AddTimedFunction(self.endLevelCallback, 5, false)
			self.callbackCalled = true
		end
	end

	return self
end

local function LevelFromJson(jsonPath)
	local j = json.decodeFile(jsonPath)

	local level = CreateLevel()
	for i = 1, #j.waves, 1 do
		level.addWave(j.waves[i])
	end

	return level
end

CurrentLevel = nil
LevelNumber = 1

function StartLevel()
	DisableWeaponBox()

	print("starting level", LevelNumber)

	CurrentLevel.addEndlevelCallback(NextLevel)

	playdate.update = GameScreen

end

function NextLevel()
	LevelNumber = LevelNumber + 1

	CurrentLevel = LevelsList[LevelNumber]

	if CurrentLevel == nil then
		--TELA de vitoria
		local endGameCinematic = Cinematic(
			{
				{
					image = playdate.graphics.image.new("assets/images/toKill5")
				},
				{
					image = playdate.graphics.image.new("assets/images/final1")
					-- TODO add audio "its done"
				},
				{
					image = playdate.graphics.image.new("assets/images/final2")
				},
				{
					image = playdate.graphics.image.new("assets/images/final")
				}

			}, MainMenu
		)
		playdate.update = endGameCinematic.update
	else
		local c =
		Cinematic(
			{
				{
					image = tokill[LevelNumber],
					sound = itsTimeToKill
				}
			},
			StartLevel
		)

		playdate.update = c.update
	end
end

local enemyTypes = {
	follower = 1,
	turret = 2,
	dumbWithTurret = 3,
	dumbs = 4,
	spawner = 0
}

LevelNumber = 0

function RefreshLevels()
	for i = 1, #LevelsList, 1 do
		LevelsList[i].waveNumber = 1
		LevelsList[i].callbackCalled = false
		LevelsList[i].finished = false
	end
end

LevelsList = {
	LevelFromJson("assets/levels/level1.json"),
	LevelFromJson("assets/levels/level2.json"),
	LevelFromJson("assets/levels/level3.json"),
	LevelFromJson("assets/levels/level4.json"), --FIXME too much hard
	LevelFromJson("assets/levels/level5.json")
}
