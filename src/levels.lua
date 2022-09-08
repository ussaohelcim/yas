--TODO criar um editor de waves interativo
--FIXME Criar nova musica para cinematic inicio de nivel
--TODO implementar o fim de jogo(vitoria)

local newLevelSound = playdate.sound.sampleplayer.new("assets/sounds/highscore.wav")

local tokill = {
	playdate.graphics.image.new("assets/images/toKill0"),
	playdate.graphics.image.new("assets/images/toKill1"),
	playdate.graphics.image.new("assets/images/toKill2"),
	playdate.graphics.image.new("assets/images/toKill3"),
	playdate.graphics.image.new("assets/images/toKill4"),
	playdate.graphics.image.new("assets/images/toKill5")
}

local endGameSprite = playdate.graphics.image.new("assets/images/theEnd")

local function CreateLevel()
	local self = {}
	self.waves = {}
	self.waveNumber = 1
	self.finished = false
	self.callbackCalled = false

	function self.addWave(enemyList)
		self.waves[#self.waves+1] = enemyList
	end

	function self.addEndlevelCallback(callback)
		self.endLevelCallback = callback
	end

	function self.nextWave()
		
		if self.waveNumber <= #self.waves then
			local list = self.waves[self.waveNumber]
			for i = 1, #list, 1 do
				local e = list[i]
				CreateEnemy(
					e.x or math.random(0,400), e.y or math.random(0,240),
					e.enemyType,e.enemyLife,e.speed,e.r
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
			AddTimedFunction(self.endLevelCallback,3,false)
			-- self.endLevelCallback()
			self.callbackCalled = true
		end
	end

	return self
end

CurrentLevel = nil
LevelNumber = 1

function ChangeToNextLevel()
	
end

function StartLevel()
	local l = 0

	if PLAYER ~= nil then
		
		l = PLAYER.life + math.floor(PLAYER.life * 0.5)

		if l > PLAYER.maxLife then
			PLAYER.maxLife = l
		end
	end

	PLAYER = Player()

	if l ~= 0 then
		PLAYER.life = l 
		
	end

	CurrentLevel = LevelsList[LevelNumber]
	CurrentLevel.addEndlevelCallback(NextLevel)

	playdate.update = GameScreen

	
	
	print("botou o gamescreen no update")
end

function NextLevel()
	LevelNumber = LevelNumber + 1

	-- if CurrentLevel ~= nil then
		
	-- else
	-- 	local c = Cinematic(
	-- 		{
	-- 			{
	-- 				image = endGameSprite,
	-- 				--TODO adicionar musica fim do jogo
	-- 				--TODO criar imagens dos creditos
	-- 			}
	-- 		},NewGame
	-- 	)

	-- 	playdate.update = c.update
	-- end

	

	local c = Cinematic(
		{
			{
				image = tokill[LevelNumber],
				sound = newLevelSound
			}
		}
		, StartLevel
	)

	playdate.update = c.update

end



local enemyTypes = {
	follower = 1,
	turret = 2,
	dumbWithTurret = 3,
	dumbs= 4,
}


--#region level 1

Level1 = CreateLevel()

Level1.addWave(
	{
		{
			enemyType = enemyTypes.dumbs,
			enemyLife = 1,
			speed = 50,
		},
		{
			enemyType = enemyTypes.dumbs,
			enemyLife = 1,
			speed = 50,
		},
	}
)

Level1.addWave(
	{
		{
			enemyType = enemyTypes.dumbs,
			enemyLife = 3,
			speed = 100,
		},
		{
			enemyType = enemyTypes.dumbs,
			enemyLife = 3,
			speed = 100,
		},
		{
			enemyType = enemyTypes.dumbs,
			enemyLife = 3,
			speed = 100,
		},
	}
)

-- Level1.addWave(
-- 	{
-- 		{
-- 			enemyType = enemyTypes.dumbs,
-- 			enemyLife = 3,
-- 			speed = 100,
-- 		},
-- 		{
-- 			enemyType = enemyTypes.dumbs,
-- 			enemyLife = 3,
-- 			speed = 100,
-- 		},
-- 		{
-- 			enemyType = enemyTypes.follower,
-- 			enemyLife = 5,
-- 			speed = 50,
-- 		},
-- 		{
-- 			enemyType = enemyTypes.follower,
-- 			enemyLife = 5,
-- 			speed = 50,
-- 		},
-- 	}
-- )

-- Level1.addWave(
-- 	{
-- 		{
-- 			enemyType = enemyTypes.follower,
-- 			enemyLife = 5,
-- 			speed = 50,
-- 		},{
-- 			enemyType = enemyTypes.follower,
-- 			enemyLife = 5,
-- 			speed = 50,
-- 		},{
-- 			enemyType = enemyTypes.follower,
-- 			enemyLife = 5,
-- 			speed = 50,
-- 		},
-- 		{
-- 			enemyType = enemyTypes.dumbs,
-- 			enemyLife = 9,
-- 			speed = 300,
-- 		},
-- 		{
-- 			enemyType = enemyTypes.dumbs,
-- 			enemyLife = 9,
-- 			speed = 300,
-- 		},
-- 	}
-- )

-- Level1.addWave(
-- 	{
-- 		{
-- 			enemyType = enemyTypes.follower,
-- 			enemyLife = 1,
-- 			speed = 100,
-- 		},{
-- 			enemyType = enemyTypes.follower,
-- 			enemyLife = 1,
-- 			speed = 100,
-- 		},{
-- 			enemyType = enemyTypes.follower,
-- 			enemyLife = 1,
-- 			speed = 100,
-- 		},{
-- 			enemyType = enemyTypes.follower,
-- 			enemyLife = 1,
-- 			speed = 100,
-- 		},{
-- 			enemyType = enemyTypes.follower,
-- 			enemyLife = 1,
-- 			speed = 100,
-- 		},{
-- 			enemyType = enemyTypes.follower,
-- 			enemyLife = 1,
-- 			speed = 100,
-- 		},
-- 	}
-- )

Level1.addEndlevelCallback(	function ()
	
	NextLevel()
end )

--#endregion


--#region level2

Level2 = CreateLevel()

Level2.addWave(
	{
		{
			enemyType = enemyTypes.dumbs,
			enemyLife = 9,
			speed = 300,
		},
		{
			enemyType = enemyTypes.dumbs,
			enemyLife = 9,
			speed = 300,
		},
		{
			enemyType = enemyTypes.turret,
			enemyLife = 9,
			speed = 1,
		},
		{
			enemyType = enemyTypes.turret,
			enemyLife = 9,
			speed = 1,
		},
		{
			enemyType = enemyTypes.turret,
			enemyLife = 9,
			speed = 1,
		}
	}
)

--#endregion


LevelNumber = 0

LevelsList = {
	Level1,
	Level2
}
