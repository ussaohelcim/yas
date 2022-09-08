import "mathExtensions"

local timeDT = playdate.getCurrentTimeMilliseconds
local _lastDT = timeDT()
local gfx = playdate.graphics

COLORS = {
	black = gfx.kColorBlack,
	white = gfx.kColorWhite,
	transparent = gfx.kColorClear,
	xor = gfx.kColorXOR
}

---Returns the delta time in seconds.
---@return number
function GetDeltaTime()
	local now = timeDT()
	local dt = now - _lastDT
	_lastDT = now

	return dt * 0.001
end


---Adds a .cooldown and .cooldownTotal member into table with coolDown
---@param table any
---@param coolDown any
function AddCooldownComponentInto(table,coolDown)
	table.cooldown = coolDown
	table.cooldownTotal = coolDown
end

local shakeTime = 0
local shakeStrength = 2
local checkerBoardpattern = { 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55 }

local blood = gfx.image.new(20, 20)
gfx.setColor(gfx.kColorWhite)
gfx.pushContext(blood)
gfx.drawLine(0,0,20,20)
gfx.drawLine(20,0,0,20)
gfx.popContext()
gfx.setColor(gfx.kColorBlack)

function UpdateShakeScreen(dt)
	if shakeTime > 0 then
		shakeTime = shakeTime - dt
		gfx.setDrawOffset(
			math.random() * 5,math.random() * 5
		)
		-- playdate.display.setInverted(false)
	end
end

function ShakeScreen(time)
	shakeTime = time

end

local particles = {}

particles.top = {} -- particles that get draw on top of everything
particles.top.textParticles = {}
particles.top.explosions = {}
particles.top.hitParticles = {}
particles.top.flashes = {}

particles.below = {} -- particles that get drew on below everything
particles.below.blood = {}
particles.below.spawnAlerts = {}


function DrawTopParticles()

	DrawHitParticles()
end

function DrawBelowParticles()
	gfx.setPattern(checkerBoardpattern)

	for i = 1, #particles.top.flashes, 1 do
		local p = particles.top.flashes[i]

		if p.ttl > 0 then
			p.ttl = p.ttl - 1

			gfx.fillCircleAtPoint(p.x, p.y, p.r)

			if p.ttl <= 0 then
				p.enabled = false
			end
		end
	end
	gfx.setColor(gfx.kColorBlack)


	for i = 1, #particles.below.blood, 1 do
		local bloodP = particles.below.blood[i]

		if bloodP.ttl > 0 then
			bloodP.ttl = bloodP.ttl - 1
			
			blood:drawCentered(bloodP.x,bloodP.y)

			if bloodP.ttl <= 0 then
				bloodP.enabled = false
			end
		end
	end
	-- gfx.setColor(gfx.kColorClear)
end

---Add objectToAdd into list
---@param list table table list
---@param objectToAdd table needs a "enabled" key
function ObjectPooling(list, objectToAdd)
	local found = false

	for i = 1, #list, 1 do
		local o = list[i]
		if not o.enabled then
			
			list[i] = objectToAdd
			found = true

			break
		end
	end

	if not found then
		list[#list+1] = objectToAdd
	end
end

local objectPoolingTemplate = ObjectPooling
local tempVector = {}
local random = math.random

function AddBloodParticles(x, y)
	
	objectPoolingTemplate(particles.below.blood, {
		x = x,
		y = y,
		ttl = 60,
		enabled = true
	})

end

function AddSpawnAlert(x,y)
	objectPoolingTemplate(particles.below.spawnAlerts, {
		x = x,
		y = y,
		ttl = 60,
		enabled = true
	})
end

function AddTextParticles(x, y, txt, ttl,speedY)
	objectPoolingTemplate(particles.top.textParticles, {
		x = x,
		y = y,
		txt = txt,
		ttl = ttl,
		speedY = speedY or 0,
		enabled = true
	})

end

function AddFlashParticle(x,y)
	objectPoolingTemplate(particles.top.flashes, {
		x = x,
		y = y,
		enabled = true,
		ttl = 5,
		r = 30
	})
end

function AddExplosionParticles(x,y,ttl)
	local found = false
	local list = particles.top.explosions

	for i = 1, #list, 1 do
		local explosion = list[i]
		if explosion.ttl < 0 then
			explosion.x = x
			explosion.y = y
			explosion.ttl = ttl
			
			found = true

			break
		end
	end

	if not found then
		list[#list + 1] = {
			x = x,
			y = y,
			ttl = ttl
		}
	end
end

function UIRow(x,y)
	local self = {}
	self.items = {}
	self.cursorPosition = 1
	self.x = x
	self.y = y

	function self.addItem(txt,callback)
		self.items[#self.items + 1] = {
			txt = txt,
			callback = callback
		}
	end

	function self.draw()
		local lastY = self.y
		
		for i = 1, #self.items, 1 do

			local txt = self.items[i].txt
			local w, h = gfx.getTextSize(txt)

			-- gfx.drawRect(0,0,100,100)
			
			gfx.drawText(txt, self.x, lastY)

			if self.cursorPosition == i then
				gfx.drawText(" Ⓐ", self.x + w, lastY)
			end
			-- gfx.drawCircleAtPoint(self.x,lastY,5)
			

			lastY = lastY + h
		end
	end

	function self.update()
		if playdate.buttonJustPressed("up") then
			self.select(-1)
		elseif playdate.buttonJustPressed("down") then
			self.select(1)
		
		end

		if playdate.buttonJustPressed("a") then
			self.items[self.cursorPosition].callback()
		end

	end

	function self.getRect()
		local width = 0
		local heigth = 0

		for i = 1, #self.items, 1 do

			local txt = self.items[i].txt
			local w, h = gfx.getTextSize(txt)

			width = width + w
			heigth = heigth + h

		end

		return self.x, self.y, width, heigth
	end

	function self.select(y)
		self.cursorPosition = self.cursorPosition + y
		if self.cursorPosition <=0 then
			self.cursorPosition = 1
		elseif self.cursorPosition > #self.items then
			self.cursorPosition = #self.items
		end
	end

	return self
end

local hitParticleImage = playdate.graphics.image.new("assets/images/hitParticle")

function AddHitParticle(x,y)
	objectPoolingTemplate(particles.top.hitParticles, {
		x = x,
		y = y,
		ttl = 10,
		enabled = true
	})
end

function DrawHitParticles()
	for i = 1, #particles.top.hitParticles, 1 do
		local p = particles.top.hitParticles[i]

		if p.ttl > 0 then
			p.ttl = p.ttl - 1
			hitParticleImage:drawRotated(p.x,p.y,math.random()*360)

			if p.ttl <= 0 then
				p.enabled = false
			end
		end
	end
end

function memoize(f)
	local mem = {} -- memoizing table
	setmetatable(mem, {__mode = "kv"}) -- make it weak
	return function (x) -- new version of ’f’, with memoizing
		local r = mem[x]
		if r == nil then -- no previous result?
			r = f(x) -- calls original function
			mem[x] = r -- store result for reuse
		end
		return r
	end
	-- Given any function f, memoize(f) returns a new function that returns the same
-- results as f but memoizes them. For instance, we can redefine loadstring with
-- a memoizing version:
-- loadstring = memoize(loadstring)
-- We use this new function exactly like the old one, but if there are many repeated
-- strings among those we are loading, we can have a substantial performance
-- gain
end

