-- aqui vai ficar tudo relacionado ao IN GAME

local gfx = playdate.graphics
local DT = GetDeltaTime
local updateEnemies = UpdateEnemies
local updateBullets = UpdateBullets
local updateShakeScreen = UpdateShakeScreen
local drawBelowParticles = DrawBelowParticles
local drawTopParticles = DrawTopParticles
local updateTimedFunctions = UpdateTimedFunctions
local checkCollisionCircles = math.checkCollisionCircles
local randomBetween = math.randomBetween
local createBullet = CreateBullet
local drawFPS = playdate.drawFPS

local showedGameOver = false
PLAYER = nil

local menu = playdate.getSystemMenu()

local showFPS = false

local menuItem, error = menu:addCheckmarkMenuItem("Show FPS", false, function()
	showFPS = not showFPS
end)

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

local sfxBullet = playdate.sound.sampleplayer.new("assets/sounds/shoot.wav")
sfxBullet:setVolume(0.1)

---comment
---@param angles table list of angles
---@param firerate number in seconds
---@param bulletSpeed number
---@param bulletSize number
function Weapon(angles, firerate, bulletSpeed, bulletSize)
	local self = {}

	self.fireRate = firerate
	self.cooldown = self.fireRate
	self.defaultFireRate = firerate
	self.angles = angles
	self.bulletSpeed = bulletSpeed
	self.size = bulletSize or 8
	function self.update(dt)
		self.cooldown = self.cooldown - dt
	end

	function self.tryToShoot(x, y, angle)

		if self.cooldown <= 0 then
			for i = 1, #self.angles, 1 do
				local aa = angle + self.angles[i]
				sfxBullet:play(1, randomBetween(0.7, 1))
				createBullet(1, x, y, aa, self.bulletSpeed, self.size, false)
			end
			self.cooldown = self.fireRate
		end

	end

	return self
end

local wDualPistol = Weapon(
	{
		math.rad(15),
		math.rad(-15),
	}, 0.3, 200, 8
)

local wLeftRight = Weapon(
	{ -- rapido
		math.rad(90),
		math.rad(-90),
	}, 0.22, 200, 8
)

local wFowardBackward = Weapon(
	{
		math.rad(0),
		math.rad(180),
	}, 0.1, 200, 8
)

local wTrident = Weapon(
	{
		math.rad(-45),
		math.rad(0),
		math.rad(45)
	}, 0.35, 200, 8
)

local wShotgun = Weapon(
	{
		math.rad(-20),
		math.rad(-10),
		math.rad(0),
		math.rad(10),
		math.rad(20),
	}, 0.65, 200, 8
)

local wCross = Weapon(
	{
		math.rad(-90),
		math.rad(0),
		math.rad(90),
		math.rad(180),
	}, 0.4, 200, 8
)

local w360 = Weapon(
	{
		math.rad(0),
		math.rad(45),
		math.rad(90),
		math.rad(135),
		math.rad(180),
		math.rad(225),
		math.rad(270),
		math.rad(315),
	}, 0.78, 200, 8
)

local weaponList = {
	wDualPistol, wShotgun, wTrident, wLeftRight, wCross, w360,
}

local sfxBox = playdate.sound.sampleplayer.new("assets/sounds/newWeapon.wav")
sfxBox:setVolume(0.4)

local weaponBox = {
	x = 0,
	y = 0,
	r = 8,
	enabled = false,
	weapon = weaponList[math.random(1, #weaponList)],
	image = playdate.graphics.image.new("assets/images/ammoCrate"),
	sound = sfxBox
}

local upgradeWeaponBox = {
	x = 0,
	y = 0,
	r = 8,
	enabled = false,
	image = playdate.graphics.image.new("assets/images/upgradeBox"),
	sound = sfxBox
}

local healthBox = {
	x = 0,
	y = 0,
	r = 8,
	enabled = false,
	image = playdate.graphics.image.new("assets/images/healthBox"),
	sound = sfxBox
}

local secretBoxImage = playdate.graphics.image.new("assets/images/secretBox")

function SpawnBoxes()
	upgradeWeaponBox.enabled = true
	upgradeWeaponBox.x = math.random() * 400
	upgradeWeaponBox.y = math.random() * 240

	healthBox.enabled = true
	healthBox.x = (math.random() * 400) - healthBox.r
	healthBox.y = (math.random() * 240) - healthBox.r

	weaponBox.weapon = weaponList[math.random(1, #weaponList)]
	weaponBox.x = math.random() * 400 - weaponBox.r
	weaponBox.y = math.random() * 240 - weaponBox.r
	weaponBox.enabled = true
end

function DisableBoxes()
	weaponBox.enabled = false
	upgradeWeaponBox.enabled = false
	healthBox.enabled = false
end

function NewGame()
	-- collectgarbage("stop")

	for i = 1, #weaponList, 1 do
		local w = weaponList[i]
		w.fireRate = w.defaultFireRate
	end

	collectgarbage("collect")

	DisableAllBullets()

	print("new game", collectgarbage("count"))
	PLAYER = Player()

	PLAYER.weapon = weaponList[math.random(1, #weaponList)]

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

	if weaponBox.enabled then
		secretBoxImage:drawCentered(weaponBox.x, weaponBox.y)
		-- weaponBox.image:drawCentered(weaponBox.x, weaponBox.y)
		if checkCollisionCircles(PLAYER.x, PLAYER.y, PLAYER.r, weaponBox.x, weaponBox.y, weaponBox.r) then
			PLAYER.weapon = weaponList[math.random(1, #weaponList)]
			weaponBox.sound:play(1)
			AddFlashParticle(weaponBox.x + weaponBox.r, weaponBox.y + weaponBox.r)
			-- weaponBox.enabled = false
			DisableBoxes()
		end
	end
	if healthBox.enabled then
		secretBoxImage:drawCentered(healthBox.x, healthBox.y)
		-- healthBox.image:drawCentered(healthBox.x, healthBox.y)
		if checkCollisionCircles(PLAYER.x, PLAYER.y, PLAYER.r, healthBox.x, healthBox.y, healthBox.r) then
			-- PLAYER.weapon = healthBox.weapon
			PLAYER.life = PLAYER.maxLife
			healthBox.sound:play(1)
			AddFlashParticle(healthBox.x + healthBox.r, healthBox.y + healthBox.r)
			DisableBoxes()
		end
	end

	updateTimedFunctions(dt)

	if showFPS then
		drawFPS(0, 0)
	end

end
