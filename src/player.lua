import "bullets"

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

local tempVector = {}

local playerImage = playdate.graphics.image.new("assets/images/player")
local sfxHURT = playdate.sound.sampleplayer.new("assets/sounds/death.wav")
local sfxBullet = playdate.sound.sampleplayer.new("assets/sounds/shoot.wav")

sfxBullet:setVolume(0.3)

function Player()
	
	local self = {}

	self.fireRate = 0.1
	self.cooldown = self.fireRate

	self.aimAngle = 0
	self.aimAngleCache = 0

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
	self.invencible = false
	self.invencibleCooldown = 0.5
	self.bulletSpeed = 300
	
	playdate.AButtonDown = function()
		self.buttons.a = true
	end
	playdate.AButtonUp = function ()
		self.buttons.a = false
	end

	playdate.BButtonDown = function ()
		self.buttons.b = true
	end
	playdate.BButtonUp = function ()
		self.buttons.b = false
	end

	playdate.rightButtonDown = function()
		self.dpad.right = true
	end

	playdate.rightButtonUp = function ()
		self.dpad.right = false
	end

	playdate.leftButtonDown = function ()
		self.dpad.left = true
	end
	playdate.leftButtonUp = function ()
		self.dpad.left = false
	end

	playdate.downButtonDown = function ()
		self.dpad.down = true
	end
	playdate.downButtonUp = function ()
		self.dpad.down = false
	end

	playdate.upButtonDown = function ()
		self.dpad.up = true
	end

	playdate.upButtonUp = function()
		self.dpad.up = false
	end

	function self.update(dt)
		self.cooldown = self.cooldown - dt

		if self.invencible then
			self.invencibleCooldown = self.invencibleCooldown - dt
			if self.invencibleCooldown < 0 then
				self.invencible = false
				self.invencibleCooldown = 0.5
			end
		end

		if self.cooldown < 0 then
			local a = self.aimAngle
			local a2 = 0
			local shoot = false
			self.cooldown = self.fireRate
			
			if self.buttons.a then
				local c = a
				a = a - (PI * (0.25*0.5))
				a2 = c + (PI * (0.25*0.5))
				shoot = true
			elseif self.buttons.b then
				a = a + (PI * 0.5)
				a2 = a + PI
				shoot = true
			end

			if shoot then
				AddFlashParticle(self.x,self.y)
				CreateBullet(1, self.x, self.y, a, self.bulletSpeed, 5, false)
				CreateBullet(1, self.x, self.y, a2, self.bulletSpeed, 5, false)
				sfxBullet:play(1)
			end

		end

		local x = iff(self.dpad.left,-1,iff(self.dpad.right,1,0))
		local y = iff(self.dpad.up, -1, iff(self.dpad.down, 1, 0))

		if not (y == 0 and x == 0) then

			self.aimAngle = math.normalizedVector2ToAngle(x, y)
			math.AngleToNormalizedVector(self.aimAngle, tempVector)

			self.x = self.x + (tempVector.x * self.speed * dt)-- 
			self.y = self.y + (tempVector.y * self.speed * dt)-- 
		end

	end

	function self.draw()
		gfx.setColor(gfx.kColorWhite)
		
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
	end
	return self
end


