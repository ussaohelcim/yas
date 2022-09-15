-- aqui vai ficar tudo relacionado ao IN GAME

local gfx = playdate.graphics
local DT = GetDeltaTime
local updateEnemies = UpdateEnemies
local updateBullets = UpdateBullets
local updateShakeScreen = UpdateShakeScreen
local drawBelowParticles = DrawBelowParticles
local drawTopParticles = DrawTopParticles
local updateTimedFunctions = UpdateTimedFunctions

local showedGameOver = false
PLAYER = nil

local bg = playdate.graphics.image.new(400, 240)

local blood = playdate.graphics.image.new(400, 240)

local checkerBoardpattern = { 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55 }

gfx.pushContext(bg)
gfx.fillRect(-50, -50, 500, 340)
gfx.popContext()

playdate.graphics.sprite.setBackgroundDrawingCallback(
	function(x, y, width, height)
		bg:draw(0, 0)
	end
)

gfx.setPattern(checkerBoardpattern)
gfx.pushContext(blood)
gfx.fillRect(0, 0, 400, 240)
playdate.graphics.popContext()
playdate.graphics.setColor(playdate.graphics.kColorClear)

function NewGame()
	-- collectgarbage("stop")

	collectgarbage("collect")

	DisableAllBullets()

	print("new game", collectgarbage("count"))
	PLAYER = Player()

	LevelNumber = 0
	showedGameOver = false
	print("created player", collectgarbage("count"))

	KillAllEnemies()
	print("disabled all enemies", collectgarbage("count"))
	RefreshLevels()
	print("levels refreshed", collectgarbage("count"))
	NextLevel()
	print("next level", collectgarbage("count"))
end

function GameOverScreen()
	local cinematic = Cinematic(
		{
			{
				image = playdate.graphics.image.new("assets/images/deathScreen"),
				sound = playdate.sound.sampleplayer.new("assets/sounds/gameOver.wav")
			},
		},
		MainMenu
	)

	playdate.update = cinematic.update
end

function GameScreen()
	local dt = DT()
	playdate.graphics.sprite.update()


	drawBelowParticles()

	if PLAYER.invencible then
		blood:draw(0, 0)
	end

	if PLAYER.life > 0 then
		PLAYER.update(dt)
		PLAYER.draw()
	end

	updateEnemies(PLAYER, dt)
	updateBullets(dt, PLAYER)


	updateShakeScreen(dt)

	drawTopParticles()

	CurrentLevel.checkWave()

	if PLAYER.life <= 0 and not showedGameOver then
		showedGameOver = true
		AddTimedFunction(
			GameOverScreen, 3, false
		)
	end

	updateTimedFunctions(dt)

end
