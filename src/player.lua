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
local createBullet = CreateBullet
local tempVector = {}

local playerImage = playdate.graphics.image.new("assets/images/player")
local sfxHURT = playdate.sound.sampleplayer.new("assets/sounds/death.wav")
local sfxDash = playdate.sound.sampleplayer.new("assets/sounds/dash.wav")
local lowLifeSound = playdate.sound.sampleplayer.new("assets/sounds/lowLife.wav")
local midLifeSound = playdate.sound.sampleplayer.new("assets/sounds/midLife.wav")
local fullLifeSound = playdate.sound.sampleplayer.new("assets/sounds/fullLife.wav")

fullLifeSound:setVolume(0.2)
-- lowLifeSound:setVolume(0.2)
midLifeSound:setVolume(0.5)
sfxHURT:setVolume(0.5)
sfxDash:setVolume(0.2)


local lifeSound = fullLifeSound

local dashRadius = 100
local dashRadiusImage = playdate.graphics.image.new(dashRadius * 2, dashRadius * 2)
local checkerBoardpattern = { 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55 }

gfx.pushContext(dashRadiusImage)
gfx.setPattern(checkerBoardpattern)
gfx.drawCircleInRect(0, 0, dashRadius * 2, dashRadius * 2)
gfx.setColor(gfx.kColorBlack)
gfx.popContext()


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
	self.r = 12
	self.front = true
	self.speed = 100
	self.runSpeed = 200
	self.walkSpeed = 100
	self.invencible = false
	self.invencibleCooldown = 0.5
	self.bulletSpeed = 300

	self.inControl = false

	self.weapon = nil

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

			self.x = self.x + (tempVector.x * self.speed * dt)
			self.y = self.y + (tempVector.y * self.speed * dt)
		end

		self.dashCooldown = self.dashCooldown - dt
		if dash and self.dashCooldown < 0 then
			local x1, y1 = self.x, self.y

			if self.life <= self.maxLife * 0.3 then
				createBullet(0, self.x, self.y, 0, 100, 8, false)
				createBullet(0, self.x, self.y, math.rad(90), 100, 8, false)
				createBullet(0, self.x, self.y, math.rad(180), 100, 8, false)
				createBullet(0, self.x, self.y, math.rad(-90), 100, 8, false)
				createBullet(0, self.x, self.y, math.rad(45), 100, 8, false)
				createBullet(0, self.x, self.y, math.rad(-45), 100, 8, false)
				createBullet(0, self.x, self.y, math.rad(180 + 45), 100, 8, false)
				createBullet(0, self.x, self.y, math.rad(180 - 45), 100, 8, false)
			end

			sfxDash:play(1)

			self.dashCooldown = self.dashCooldownMax

			self.x = self.x + (tempVector.x * self.dashForce)
			self.y = self.y + (tempVector.y * self.dashForce)

			local x2, y2 = self.x, self.y

			for i = 0, 1, 0.25 do

				local x = math.lerp(i, x1, x2)
				local y = math.lerp(i, y1, y2)

				AddHitParticle(x, y)
			end
		end

	end

	function self.stopSounds()
		lifeSound:stop()
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
			self.x - self.r, self.y + 16,
			self.r * 2, 5
		)

		gfx.fillRect(
			self.x - self.r, self.y + 16,
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
