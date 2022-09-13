-- function math.lerp(value, src, dst)
-- 	return src * (1 - value) + dst * value
-- end

-- function math.remap(v, old_min, old_max, new_min, new_max)
-- 	return ((v - old_min) / (old_max - old_min)) * (new_max - new_min) + new_min
-- end

-- function ObjectPooling(list, objectToAdd)
-- 	local found = false

-- 	for i = 1, #list, 1 do
-- 		local o = list[i]
-- 		if not o.enabled then

-- 			list[i] = objectToAdd
-- 			found = true

-- 			break
-- 		end
-- 	end

-- 	if not found then
-- 		list[#list + 1] = objectToAdd
-- 	end
-- end

local remap = math.remap
local lerp = math.lerp
local objectPooling = ObjectPooling

---Creates a particle system with this img
---@param img image playdate image
---@return table
function PARTY(img)
	local self = {}
	self.particles = {}
	self.image = img

	---Creates this particle at x,y
	---@param x number
	---@param y number
	---@param ttl number Time to live, in seconds.
	---@param gravityX number
	---@param gravityY number
	function self.createParticle(
	  x, y,
	  ttl,
	  gravityX, gravityY
	  -- scaleStart, scaleEnd
	  -- opacityStart, opacityEnd
	)
		local p = {}
		p.x = x
		p.y = y

		p.ttl = ttl
		p.maxttl = ttl

		p.gravityX = gravityX or 0
		p.gravityY = gravityY or 0

		-- p.initialScale = scaleStart or 1
		-- p.finalScale = scaleEnd or 1
		-- p.scale = 0

		objectPooling(self.particles, p)

	end

	function self.updateAndDraw(dt)
		for i = 1, #self.particles, 1 do
			local p = self.particles[i]
			if p.ttl > 0 then
				p.ttl = p.ttl - dt

				-- local progress = 1 - remap(p.ttl, 0, p.maxttl, 0, 1)

				-- print("progress", progress)

				-- p.scale = lerp(progress, p.initialScale, p.finalScale)

				p.x = p.x + p.gravityX
				p.y = p.y + p.gravityY

				self.image:draw(p.x, p.y)

			end
		end
	end

	return self
end
