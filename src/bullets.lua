local cos = math.cos
local sin = math.sin
local abs = math.abs
local atan = math.atan
local gfx = playdate.graphics
local checkCollisionCircles = math.checkCollisionCircles
local random = math.random
local objectPoolingTemplate = ObjectPooling

BulletList = {} --circle bullets [i]x,y,angle,speed,r,type,enabled
local laserList = {} --line bullets
local screen = {x=0,y=0,w=400,h=240}

local bulletEnemy = playdate.graphics.image.new("assets/images/bulletEnemy")
local bulletPlayer = playdate.graphics.image.new("assets/images/bulletPlayer")

function CreateBullet(type, x,y, angle, speed, size, isEnemy)

	objectPoolingTemplate(BulletList, {
		enabled = true,
		x = x,
		y = y,
		angle = angle or (random() * (math.TAU)),
		speed = speed,
		r = 8,
		isEnemy = isEnemy
	})

end


local function checkCollisionCircleRect(center,rec)
	local collision = false

	local recCenterX = (rec.x + rec.w/2);
	local recCenterY = (rec.y + rec.h/2);

	local dx = abs(center.x - recCenterX);
	local dy = abs(center.y - recCenterY);

	if (dx > (rec.w/2 + center.r)) then
		return false
	end 

	if (dy > (rec.h/2 + center.r)) then
		return false
	end 

	if (dx <= (rec.w/2)) then
		return true
	end 
	if (dy <= (rec.h/2)) then
		return true
	end 

	local cornerDistanceSq = (dx - rec.w/2)*(dx - rec.w/2) +
														(dy - rec.h/2)*(dy - rec.h/2);

	collision = (cornerDistanceSq <= (center.r*center.r));

	return collision;
end


---@param angle number in radians
local function AngleToNormalizedVector(angle, out)
	out.x = cos(angle)
	out.y = sin(angle)
end

function UpdateBullets(dt,player)
	local v = {}
	playdate.graphics.setColor(playdate.graphics.kColorBlack)

	for i = 1, #BulletList, 1 do
		local b = BulletList[i]

		if b.enabled then

			AngleToNormalizedVector(b.angle, v)

			b.x = b.x + (v.x * b.speed * dt)
			b.y = b.y + (v.y * b.speed * dt)

			if b.isEnemy then
				if checkCollisionCircles(
					player.x,player.y,player.r,b.x,b.y,b.r
				) then
					player.takeDamage(1)
					b.enabled = false
				end
				bulletEnemy:drawCentered(b.x,b.y)
				-- gfx.fillCircleAtPoint(b.x,b.y,b.r)
			else
				bulletPlayer:drawCentered(b.x,b.y)
				-- gfx.drawCircleAtPoint(b.x,b.y,b.r)
			end

			-- gfx.setLineWidth(1)
			--if not inside screen
			if not checkCollisionCircleRect(b, screen) then
				b.enabled = false
			end
		end
	end
end

