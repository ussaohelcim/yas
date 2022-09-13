--this sucks

local sqrt = math.sqrt

local function checkCollisionCircles(c1x, c1y, c1r, c2x, c2y, c2r)
	local dx = c2x - c1x
	local dy = c2y - c1y
	local distance = sqrt(dx * dx + dy * dy)

	return distance <= (c1r + c2r)
end

local function objectPooling(list, objectToAdd)
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
		list[#list + 1] = objectToAdd
	end
end

function PhysicsComponent()
	local self = {}

	function self.updatePhysics()

	end

	return self
end

function WorldPhysics(gravityX, gravityY)
	local self = {}
	self.bodies = {}
	self.x = gravityX
	self.y = gravityY

	function self.addBody(circle)
		circle.dx = circle.dx or 0
		circle.dy = circle.dy or 0
		circle.id = #self.bodies + 1
		self.bodies[#self.bodies + 1] = circle
	end

	function self.update(dt)
		for i = 1, #self.bodies, 1 do
			local c = self.bodies[i]

			c.dx = c.dx + self.x * dt
			-- dy =  5 + 0
			c.dy = c.dy + self.y * dt

			for x = 1, #self.bodies, 1 do
				local cc = self.bodies[x]

				if checkCollisionCircles(c.y, c.y, c.r, cc.x, cc.y, cc.r) and cc.id ~= c.id then
					if c.dx ~= cc.dx or c.dy ~= cc.dy then
						local cy = c.dy + cc.dy
						local cx = c.dx + cc.dx

						print("colidiu: " .. c.id .. " com " .. cc.id, "forca", cy)

						-- c.x = c.x + c.dx - c.r
						-- c.y = c.y + c.dy - c.r
						-- cc.x = cc.x + cc.dx - cc.r
						-- cc.y = cc.y + cc.dy - cc.r

						c.dx = cx
						c.dy = cy

						cc.dx = cx
						cc.dy = cy
					end

				end
			end



			c.x = c.x + c.dx
			c.y = c.y + c.dy

		end
	end

	return self
end

local w = WorldPhysics(0, 0)

local c1 = {
	x = 0,
	y = 5,
	r = 5,
	dy = -5
}

local c2 = {
	x = 0,
	y = -10,
	r = 5,
	dy = 5
}

w.addBody(c1)
w.addBody(c2)

for i = 1, 12, 1 do
	print("y", c1.y, "dy", c1.dy, "|", "y", c2.y, "dy", c2.dy)
	w.update(1)
	-- print("depois", "y", c1.y, "dy", c1.dy, "|", "y", c2.y, "dy", c2.dy)
end
