function Cinematic(sceneList, endCallback)
	local self = {}

	self.cursorPosition = 1
	self.image = sceneList[1].image
	self.sound = sceneList[1].sound

	if not (self.sound == nil) then
		print("tem som, e era pra estar tocando")
		self.sound:play(1)
	end

	function self.changeSound(sound)
		if not (self.sound == nil) then
			if self.sound:isPlaying() then
				self.sound:stop()
			end
		end

		if not (sound == nil) then
			self.sound = sound
			self.sound:play(1)
		end
		
	end

	function self.nextScene()
		self.cursorPosition = self.cursorPosition + 1
		local i = sceneList[self.cursorPosition]

		if i == nil then
			endCallback()
		else
			self.image = i.image

			self.changeSound(i.sound or nil)
		end
	end

	function self.previousScene()
		local n = self.cursorPosition - 1
		local i = sceneList[n]

		if not(i == nil) then
			self.image = i.image

			self.changeSound(i.sound or nil)

			self.cursorPosition = n
		end
	end

	function self.draw()
		self.image:draw(0, 0)
		-- playdate.graphics.drawText("Ⓐ",0,0)
	end

	function self.update()

		self.draw()

		if playdate.buttonJustPressed("a") then
			self.nextScene()
		elseif playdate.buttonJustPressed("b") then
			self.previousScene()
		end
	end

	return self
end