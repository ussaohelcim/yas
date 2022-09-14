import "bullets"

local checkCollisionCircles = math.checkCollisionCircles
local gfx = playdate.graphics
local aBTN = playdate.kButtonA
local bBTN = playdate.kButtonB
local upBTN = playdate.kButtonUp
local downBTN = playdate.kButtonDown
local leftBTN = playdate.kButtonLeft
local rightBTN = playdate.kButtonRight
local bisP = playdate.buttonIsPressed
local iff = math.iff
local remap = math.remap
local PI = math.pi
local TAU = math.TAU
local isInBetween = math.isInBetween
local tempVector = {}

local playerImage = playdate.graphics.image.new("assets/images/player")
local sfxHURT = playdate.sound.sampleplayer.new("assets/sounds/death.wav")
local sfxBullet = playdate.sound.sampleplayer.new("assets/sounds/shoot.wav")

local sfxDash = playdate.sound.sampleplayer.new("assets/sounds/dash.wav")

sfxDash:setVolume(0.3)
sfxBullet:setVolume(0.3)

local lowLifeSound = playdate.sound.sampleplayer.new("assets/sounds/lowLife.wav")
local midLifeSound = playdate.sound.sampleplayer.new("assets/sounds/midLife.wav")
local fullLifeSound = playdate.sound.sampleplayer.new("assets/sounds/fullLife.wav")

fullLifeSound:setVolume(0.2)
-- lowLifeSound:setVolume(0.2)
midLifeSound:setVolume(0.5)

local lifeSound = fullLifeSound

local dashRadius = 100
local dashRadiusImage = playdate.graphics.image.new(dashRadius * 2, dashRadius * 2)
local checkerBoardpattern = { 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55 }

gfx.pushContext(dashRadiusImage)
gfx.setPattern(checkerBoardpattern)
gfx.drawCircleInRect(0, 0, dashRadius * 2, dashRadius * 2)
gfx.setColor(gfx.kColorBlack)
gfx.popContext()



---comment
---@param angles table list of angles
---@param firerate number in seconds
---@param bulletSpeed number
---@param bulletSize number
function Weapon(angles, firerate, bulletSpeed, bulletSize)
	local self = {}

	self.fireRate = firerate
	self.cooldown = self.fireRate
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
				sfxBullet:play(1)
				CreateBullet(1, x, y, aa, self.bulletSpeed, self.size, false)
			end
			self.cooldown = self.fireRate
		end

	end

	return self
end

local wPistol = Weapon(
	{
		math.rad(0)
	}, 0.3, 200, 8
)

local wLeftRight = Weapon(
	{
		math.rad(90),
		math.rad(-90),
	}, 0.1, 200, 8
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
	}, 0.3, 200, 8
)

local wShotgun = Weapon(
	{
		math.rad(-20),
		math.rad(-10),
		math.rad(0),
		math.rad(10),
		math.rad(20),
	}, 0.6, 200, 8
)


local wCross = Weapon(
	{
		math.rad(-90),
		math.rad(0),
		math.rad(90),
		math.rad(180),
	}, 0.3, 200, 8
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
	}, 0.5, 200, 8
)

local weaponList = {
	w360, wCross, wShotgun, wTrident, wFowardBackward, wLeftRight
}

local weaponBox = {
	x = 0,
	y = 0,
	r = 8,
	enabled = false,
	weapon = weaponList[math.random(1, #weaponList)]
}

function SpawnWeaponBox()
	weaponBox.weapon = weaponList[math.random(1, #weaponList)]
	weaponBox.x = math.random() * 400
	weaponBox.y = math.random() * 240
	weaponBox.enabled = true
end

function DisableWeaponBox()
	weaponBox.enabled = false
end

function Player()
	local self = {}

	self.fireRate = 0.1
	self.cooldown = self.fireRate

	self.aimAngle = 0
	self.aimAngleCache = 0
	self.dashForce = dashRadius
	self.dashCooldownMax = 1
	self.dashCooldown = 1

	self.dpad = {
		up = false,
		down = false,
		left = false,
		right = false,
	}
	self.buttons = {
		a = false,
		b = false
	}
	self.life = 5
	self.maxLife = 5
	self.x = 400 / 2
	self.y = 240 / 2
	self.r = 16
	self.front = true
	self.speed = 100
	self.runSpeed = 200
	self.walkSpeed = 100
	self.invencible = false
	self.invencibleCooldown = 0.5
	self.bulletSpeed = 300

	self.weapon = weaponList[math.random(1, #weaponList)]

	lifeSound = fullLifeSound

	lifeSound:play(0)

	playdate.AButtonDown = function()
		self.buttons.a = true
	end
	playdate.AButtonUp = function()
		self.buttons.a = false
	end

	playdate.BButtonDown = function()
		self.buttons.b = true
	end
	playdate.BButtonUp = function()
		self.buttons.b = false
	end

	playdate.rightButtonDown = function()
		self.dpad.right = true
	end

	playdate.rightButtonUp = function()
		self.dpad.right = false
	end

	playdate.leftButtonDown = function()
		self.dpad.left = true
	end
	playdate.leftButtonUp = function()
		self.dpad.left = false
	end

	playdate.downButtonDown = function()
		self.dpad.down = true
	end
	playdate.downButtonUp = function()
		self.dpad.down = false
	end

	playdate.upButtonDown = function()
		self.dpad.up = true
	end

	playdate.upButtonUp = function()
		self.dpad.up = false
	end

	function self.update(dt)

		if self.x > 400 or self.x < 0 or self.y < 0 or self.y > 240 then
			self.takeDamage(1)
		end

		if self.life < self.maxLife * 0.3 and not lowLifeSound:isPlaying() then
			lifeSound:stop()
			lifeSound = lowLifeSound
			lifeSound:play(0)
		elseif isInBetween(self.life, self.maxLife * 0.3, self.maxLife * 0.7) and not midLifeSound:isPlaying() then
			lifeSound:stop()
			lifeSound = midLifeSound
			lifeSound:play(0)
		elseif self.life >= self.maxLife * 0.7 and not fullLifeSound:isPlaying() then
			lifeSound:stop()
			lifeSound = fullLifeSound
			lifeSound:play(0)
		end

		if self.life <= 0 then
			lifeSound:stop()
		end

		self.cooldown = self.cooldown - dt
		local dash = self.buttons.b
		if self.invencible then
			self.invencibleCooldown = self.invencibleCooldown - dt
			if self.invencibleCooldown < 0 then
				self.invencible = false
				self.invencibleCooldown = 0.5
			end
		end

		self.weapon.update(dt)
		if self.buttons.a then
			self.weapon.tryToShoot(self.x, self.y, self.aimAngle)
		end

		local x = iff(self.dpad.left, -1, iff(self.dpad.right, 1, 0))
		local y = iff(self.dpad.up, -1, iff(self.dpad.down, 1, 0))

		if not (y == 0 and x == 0) then

			self.aimAngle = math.normalizedVector2ToAngle(x, y)
			math.AngleToNormalizedVector(self.aimAngle, tempVector)

			self.x = self.x + (tempVector.x * self.speed * dt) --
			self.y = self.y + (tempVector.y * self.speed * dt) --
			-- else
			-- 	self.aimAngle = math.rad(playdate.getCrankPosition() - 90)
		end

		self.dashCooldown = self.dashCooldown - dt
		if dash and self.dashCooldown < 0 then

			sfxDash:play(1)

			self.dashCooldown = self.dashCooldownMax
			AddHitParticle(self.x, self.y)

			self.x = self.x + (tempVector.x * self.dashForce)
			self.y = self.y + (tempVector.y * self.dashForce)

			AddHitParticle(self.x, self.y)
		end

		if weaponBox.enabled then
			gfx.setPattern(checkerBoardpattern)
			gfx.fillCircleAtPoint(weaponBox.x, weaponBox.y, weaponBox.r)

			if checkCollisionCircles(self.x, self.y, self.r, weaponBox.x, weaponBox.y, weaponBox.r) then
				self.weapon = weaponBox.weapon
				--TODO add music when get new weapon

				weaponBox.enabled = false
			end
		end


	end

	function self.draw()
		gfx.setColor(gfx.kColorWhite)

		if self.dashCooldown <= 0 then
			dashRadiusImage:drawCentered(self.x, self.y)
		end

		self.drawHealthBar()
		if self.invencible then
			gfx.drawCircleAtPoint(self.x, self.y, self.r)
		else
			playerImage:drawCentered(self.x, self.y)
		end
		gfx.setColor(gfx.kColorBlack)
	end

	function self.drawHealthBar()
		gfx.drawRect(
			self.x - self.r, self.y + self.r,
			self.r * 2, 5
		)

		gfx.fillRect(
			self.x - self.r, self.y + self.r,
			(self.r * 2) * remap(self.life, 0, self.maxLife, 0, 1), 5
		)
	end

	function self.takeDamage(damage)
		if not self.invencible then
			sfxHURT:play(1)
			ShakeScreen(0.2)
			self.invencible = true
			self.life = self.life - damage
		end

		if self.life <= 0 then
			lifeSound:stop()
		end
	end

	return self
end
