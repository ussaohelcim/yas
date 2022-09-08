
function MainMenu(newGameCallback)
	local self = {}

	self.m = UIRow(10, 0)

	self.m.addItem("new game", newGameCallback)
	self.m.addItem("achievements",AchievementsScreen)

	function self.updateCallback()
		playdate.graphics.clear()
		self.m.update()
		self.m.draw()
	end

	return self
	
end

-- function UICollumn(x,y,w,h)
-- 	local self = {}
-- 	self.items = {}
-- 	self.cursorPosition = 1
-- 	self.x = x
-- 	self.y = y

-- 	function self.addItem(txt,callback)
-- 		self.items[#self.items + 1] = {
-- 			txt = txt,
-- 			callback = callback
-- 		}
-- 	end

-- 	function self.draw()
-- 		local lastX = self.x
		
-- 		for i = 1, #self.items, 1 do

-- 			local txt = self.items[i].txt
-- 			local width, height = playdate.graphics.getTextSize(txt)

-- 			-- playdate.graphics.drawRect(0,0,100,100)
			

-- 			playdate.graphics.drawText(txt, self.x, lastX)

-- 			-- if self.cursorPosition == i then
-- 			-- 	playdate.graphics.drawText(" Ⓐ", self.x + w, lastX)
-- 			-- end
-- 			-- playdate.graphics.drawCircleAtPoint(self.x,lastY,5)
			

-- 			lastX = lastX + width
-- 		end
-- 	end

-- 	function self.update()
-- 		if playdate.buttonJustPressed("up") then
-- 			self.select(-1)
-- 		elseif playdate.buttonJustPressed("down") then
-- 			self.select(1)
		
-- 		end

-- 		if playdate.buttonJustPressed("a") then
-- 			self.items[self.cursorPosition].callback()
-- 		end

-- 	end

-- 	function self.getRect()
-- 		local width = 0
-- 		local heigth = 0

-- 		for i = 1, #self.items, 1 do

-- 			local txt = self.items[i].txt
-- 			local w, h = gfx.getTextSize(txt)

-- 			width = width + w
-- 			heigth = heigth + h

-- 		end

-- 		return self.x, self.y, width, heigth
-- 	end

-- 	function self.select(y)
-- 		self.cursorPosition = self.cursorPosition + y
-- 		if self.cursorPosition <=0 then
-- 			self.cursorPosition = 1
-- 		elseif self.cursorPosition > #self.items then
-- 			self.cursorPosition = #self.items
-- 		end
-- 	end

-- 	return self
-- end

-- function UIContainer()
-- 	local self = {}

-- 	function self.add()
		
-- 	end

-- 	function self.addRow(txt,callback)
		
-- 	end

-- 	function self.addCollumn(txt,callback)
		
-- 	end
-- 	--x position
-- 	--y position

-- 	return self
-- end