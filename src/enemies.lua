local gfx = playdate.graphics
local checkCollisionCircles = math.checkCollisionCircles
local enemiesList = {}

local addTextParticles = AddTextParticles
local rand = math.random
local angle = math.angle

local dumbImage = playdate.graphics.image.new("assets/images/burro")
local dumbWithTurretImage = playdate.graphics.image.new("assets/images/atiradorBurro")
local turretImage = playdate.graphics.image.new("assets/images/atirador")
local followerImage = playdate.graphics.image.new("assets/images/seguidor")
local sfxHURT = playdate.sound.sampleplayer.new("assets/sounds/enemyHit.wav")
local sfxDEATH = playdate.sound.sampleplayer.new("assets/sounds/enemyDeath.wav")

sfxDEATH:setVolume(0.5)

local spawnAlertImg = gfx.image.new("assets/images/spawnAlert")
-- enemiesList.followers.color =

-- playdate.graphics.kColorBlack
-- playdate.graphics.kColorWhite
-- playdate.graphics.kColorClear
-- playdate.graphics.kColorXOR


enemiesList.dumbsWithTurrets = {} -- they walk at random position and shoot
enemiesList.dumbs = {} -- they walk at random position
enemiesList.turrets = {} -- they shoot at player, type 3
enemiesList.spawners = {} -- they spawn little followers
enemiesList.followers = {} -- they walk into the player. fireRate, angle
enemiesList.statics = {}
enemiesList.aliveCount = 0

---comment
---@param x any
---@param y any
---@param type number 0 spawner, 1 = follower, 2 turret 
function CreateEnemy(x, y, type, life, speed, r)
	local e = {}

	enemiesList.aliveCount = enemiesList.aliveCount + 1
		
	e.x = x
	e.y = y
	e.life = life
	e.maxLife = life
	e.damageTime = 0.1
	e.freezeTime = 0.1
	e.stun = 0.1
	e.spawnTime = 3
	e.r = 16
	e.enabled = true

	if type == 2 then
		AddCooldownComponentInto(
			e, math.random(1, 3)
		)
		-- enemiesList.turrets[#enemiesList.turrets+1] = e

		ObjectPooling(enemiesList.turrets,e)
	elseif type == 1 then
		-- e.r = 8
		e.speed = speed or math.random(100, 200)
		e.speedTotal = e.speed
		-- enemiesList.followers[#enemiesList.followers + 1] = e

		ObjectPooling(enemiesList.followers,e)
	elseif type == 3 then
		--dumbsWithTurrets
		-- e.r = r or 5
		e.speed = speed or math.random(100, 200)
		e.speedTotal = e.speed

		AddCooldownComponentInto(
			e, math.random(1, 3)
		)
		-- e.angle = rand(0, math.TAU)
		e.NewPosition = function()
			e.targetX = rand(0,400)
			e.targetY = rand(0,240)
		end

		ObjectPooling(enemiesList.dumbsWithTurrets,e)
		-- enemiesList.dumbsWithTurrets[#enemiesList.dumbsWithTurrets + 1] = e
		e.NewPosition()
	elseif type == 0 then
		-- e.r = r
		e.Spawn = function()
			CreateEnemy(
				rand(e.x - e.r, e.x + e.r), rand(e.y - e.r, e.y + e.r),--x,y
				1,--type
				1,--life
				100,--speed
				5--r
			)
		end

		AddCooldownComponentInto(
			e, math.random(1, 3)
		)

		ObjectPooling(enemiesList.spawners, e)
	elseif type == 4 then
		-- e.r = r or 5
		e.speed = speed or math.random(100, 200)
		e.speedTotal = e.speed

		AddCooldownComponentInto(
			e, math.random(1, 5)
		)

		e.NewPosition = function()
			e.targetX = rand(0,400)
			e.targetY = rand(0,240)
		end

		ObjectPooling(enemiesList.dumbs, e)
		e.NewPosition()
	end

	-- print("followers",#enemiesList.followers)
	-- print("spawners",#enemiesList.spawners)
	-- print("dumbs", #enemiesList.dumbsWithTurrets)
	-- print("dumbsWithTurrets", #enemiesList.dumbsWithTurrets)
	-- print("turrets", #enemiesList.turrets)
end

local tempVector = {}

local checkerBoardpattern = { 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55 } 

local function handleEnemyHit(e)
	if e.damageTime <= 0 then
		for i = 1, #BulletList, 1 do
			local b = BulletList[i]

			if b.enabled and (not b.isEnemy) then
				if checkCollisionCircles(
					b.x,b.y,b.r,e.x,e.y,e.r
				) then
					e.life = e.life - 1
					e.damageTime = 0.3

					b.enabled = false
					sfxHURT:play(1)
					-- addTextParticles(e.x ,e.y,e.life,5)
					AddHitParticle(b.x, b.y)
					
					if e.life <= 0 and e.enabled then
						e.enabled = false
						AddBloodParticles(e.x, e.y)
						ShakeScreen(0.1)
						sfxDEATH:play(1)

						enemiesList.aliveCount = enemiesList.aliveCount - 1
					end
				end
			end
			end
	end
end

function GetEnemiesAliveCount()

	return enemiesList.aliveCount
end


local function drawEnemyOnDamage(e)
	gfx.setPattern(checkerBoardpattern)
	gfx.fillCircleAtPoint(e.x, e.y, e.r)
	gfx.setColor(gfx.kColorBlack)
end

local remap = math.remap

local function drawEnemy(e,img,dt)
	if e.damageTime > 0 then
		e.damageTime = e.damageTime - dt
		e.stun = e.stun - dt
		e.speed = 0
		
		drawEnemyOnDamage(e)

		gfx.setColor(gfx.kColorWhite)
		gfx.drawRect(
			e.x - e.r, e.y + e.r,
			e.r * 2, 5
		)
		gfx.fillRect(
			e.x - e.r, e.y + e.r,
			(e.r * 2) * remap(e.life, 0, e.maxLife, 0, 1), 5
		)
		gfx.setColor(gfx.kColorBlack)

	else
		e.speed = e.speedTotal
		img:drawCentered(e.x, e.y)
	end

end

function UpdateEnemies(player, dt)
	local turrets = enemiesList.turrets
	local followers = enemiesList.followers
	local dumbsWithTurrets = enemiesList.dumbsWithTurrets
	-- local spawners = enemiesList.spawners
	local dumbies = enemiesList.dumbs

	-- for i = 1, #spawners, 1 do
	-- 	local e = spawners[i]

	-- 	if e.life > 0 then
	-- 		e.cooldown = e.cooldown - dt

	-- 		if e.cooldown < 0 then
	-- 			e.cooldown = e.cooldownTotal
	-- 			e.Spawn()
	-- 		end

	-- 		if e.damageTime > 0 then
	-- 			e.damageTime = e.damageTime - dt
	-- 			e.stun = e.stun - dt
	-- 			e.speed = 0
	-- 			gfx.setPattern(checkerBoardpattern)
	-- 			-- gfx.drawCircleAtPoint(t.x, t.y, t.r)
	-- 			gfx.fillCircleAtPoint(e.x, e.y, e.r)
	-- 			playdate.graphics.setColor(playdate.graphics.kColorBlack)

	-- 		else
	-- 			e.speed = e.speedTotal

	-- 			gfx.drawCircleAtPoint(e.x,e.y,e.r)
	-- 		end

	-- 		handleEnemyHit(e)
	-- 	end
	-- end
	

	for i = 1, #turrets, 1 do
		local e = turrets[i]

		if e.spawnTime > 0 then
			e.spawnTime = e.spawnTime - dt
			-- gfx.drawText("?",e.x,e.y)
			spawnAlertImg:drawCentered(e.x,e.y)
			-- addTextParticles(t.x ,t.y,"!",20)
		else
			if e.life > 0 then

				e.cooldown = e.cooldown - dt
	
				if e.cooldown < 0 then
					e.cooldown = e.cooldownTotal
					CreateBullet(1,e.x,e.y,e.angle,100,5,true)
				end
	
				e.angle = angle(e.x,e.y,player.x,player.y)
	
				math.AngleToNormalizedVector(e.angle, tempVector)

				if e.damageTime <= 0 then
					gfx.setLineWidth(5)
					gfx.setColor(gfx.kColorWhite)
					gfx.drawLine(
						e.x, e.y,
						e.x + (tempVector.x * (e.r*2)), e.y + (tempVector.y * (e.r*2))
					)
					gfx.setLineWidth(1)
					gfx.setColor(gfx.kColorBlack)
				end

				drawEnemy(e, turretImage, dt)

				handleEnemyHit(e)	
			end
		end

		
	end

	gfx.setColor(gfx.kColorBlack)

	for i = 1, #dumbsWithTurrets, 1 do
		local e = dumbsWithTurrets[i]

		if e.spawnTime > 0 then
			e.spawnTime = e.spawnTime - dt
			-- gfx.drawText("?", e.x, e.y)
			spawnAlertImg:drawCentered(e.x,e.y)
			-- addTextParticles(e.x ,e.y,"!",20)
		else
			if e.life > 0 then
				e.cooldown = e.cooldown - dt
	
				if e.cooldown < 0 then
					e.cooldown = e.cooldownTotal
	
					e.NewPosition()
					local a = angle(e.x,e.y,player.x,player.y)
	
					CreateBullet(1,e.x,e.y,a,200,15,true)
				end

				e.angle = angle(e.x, e.y, e.targetX, e.targetY)
				math.AngleToNormalizedVector(e.angle, tempVector)
	
				e.x = e.x + (tempVector.x * e.speed * dt) 
				e.y = e.y + (tempVector.y * e.speed * dt)

				-- gfx.drawLine(e.x, e.y, e.targetX, e.targetY)
				drawEnemy(e, dumbWithTurretImage, dt)
								
				handleEnemyHit(e)
			end
		end
		
		
	end
	-- playdate.graphics.setColor(playdate.graphics.kColorBlack)
	

	for i = 1, #followers, 1 do
		local e = followers[i]

		if e.spawnTime > 0 then
			e.spawnTime = e.spawnTime - dt
			-- gfx.drawText("?",e.x,e.y)
			spawnAlertImg:drawCentered(e.x,e.y)
			-- addTextParticles(e.x, e.y, "!",20)
		else
			if e.life > 0 then
			
				e.angle = angle(e.x, e.y, player.x, player.y)
				math.AngleToNormalizedVector(e.angle, tempVector)
	
				e.x = e.x + (tempVector.x * e.speed * dt) 
				e.y = e.y + (tempVector.y * e.speed * dt)

				drawEnemy(e,followerImage,dt)
			
				if checkCollisionCircles(
					player.x,player.y,player.r,e.x,e.y,e.r
				) then
					player.takeDamage(1)
				end
	
				handleEnemyHit(e)
				
			end
		end
		
		
	end

	for i = 1, #dumbies, 1 do
		local e = dumbies[i]

		if e.spawnTime > 0 then
			e.spawnTime = e.spawnTime - dt
			spawnAlertImg:drawCentered(e.x,e.y)
			-- gfx.drawText("?",e.x,e.y)
			-- addTextParticles(e.x ,e.y,"!",20)
		else
			if e.life > 0 then

				MoveIntoRandomPosition(e,dt)

				-- e.cooldown = e.cooldown - dt
	
				-- if e.cooldown < 0 then
				-- 	e.cooldown = e.cooldownTotal
	
				-- 	e.NewPosition()
				-- end

				-- e.angle = angle(e.x,e.y,e.targetX,e.targetY)

				-- math.AngleToNormalizedVector(e.angle, tempVector)
	
				e.x = e.x + (tempVector.x * e.speed * dt) 
				e.y = e.y + (tempVector.y * e.speed * dt)

				drawEnemy(e,dumbImage,dt)
				
				if checkCollisionCircles(
					player.x,player.y,player.r,e.x,e.y,e.r
				) then
					player.takeDamage(1)
				end

				handleEnemyHit(e)
			end
		end
	end
end

---Needs x,y,targetX,targetY,angle,cooldown, cooldownTotal, NewPosition()
---@param e any enemie
---@param dt number
function MoveIntoRandomPosition(e,dt)
	e.cooldown = e.cooldown - dt
	
	if e.cooldown < 0 then
		e.cooldown = e.cooldownTotal

		e.NewPosition()
	end

	e.angle = angle(e.x,e.y,e.targetX,e.targetY)

	math.AngleToNormalizedVector(e.angle, tempVector)
end

--TODO separar os comportamentos dos inimigos em funcoes
