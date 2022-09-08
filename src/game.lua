-- aqui vai ficar tudo relacionado ao IN GAME

local gfx = playdate.graphics
local DT = GetDeltaTime
local updateEnemies = UpdateEnemies
local updateBullets = UpdateBullets
local updateShakeScreen = UpdateShakeScreen

local showedGameOver = false
PLAYER = nil

local bg = playdate.graphics.image.new(400, 240)

local blood = playdate.graphics.image.new(400, 240)

local checkerBoardpattern = { 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55 } 

gfx.pushContext(bg)
gfx.fillRect(0,0,400,240)
gfx.popContext()

playdate.graphics.sprite.setBackgroundDrawingCallback(
	function( x, y, width, height )
		bg:draw( 0, 0 )
	end
)

gfx.setPattern(checkerBoardpattern)
	gfx.pushContext(blood)
	gfx.fillRect(0,0,400,240)
	playdate.graphics.popContext()
playdate.graphics.setColor(playdate.graphics.kColorClear)
-- gfx.setImageDrawMode(playdate.graphics.kDrawModeXOR)

function NewGame()
	LevelNumber = 0
	showedGameOver = false

	NextLevel()
end

function ChamaFimDePartida()
	AddTimedFunction(GameOverScreen,5,false)
end

function GameOver()
	local cinematic = Cinematic(
		{
			{
				image = playdate.graphics.image.new("assets/images/deathScreen")
			},
		},
		MainMenu
	)

	playdate.update = cinematic.update
end

function GameOverScreen()
	GameOver()
end

function GameScreen()
	local dt = DT()
	playdate.graphics.sprite.update()

	DrawBelowParticles()

	if PLAYER.invencible then
		blood:draw(0,0)
	end

	
	if PLAYER.life > 0 then
		PLAYER.update(dt)
		PLAYER.draw()
	end

	updateEnemies(PLAYER,dt)
	updateBullets(dt,PLAYER)
	
	
	updateShakeScreen(dt)

	DrawTopParticles()

	CurrentLevel.checkWave()

	if PLAYER.life <= 0 and not showedGameOver then
		AddTimedFunction(
			GameOverScreen, 3,false
		)
	end

	UpdateTimedFunctions(dt)

end



