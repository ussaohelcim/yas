function ToKillSprite(n)
	local i = playdate.graphics.image.new("assets/images/nextLevel")

	local r = playdate.graphics.image.new(400, 240)
	
	-- playdate.graphics.pushContext(r)
	-- i:draw(0, 0)
	-- playdate.graphics.drawLine(80,56)
	if n == 1 then
	elseif n == 2 then
	elseif n == 3 then
	elseif n == 4 then
	elseif n == 5 then
	end
	playdate.graphics.popContext()

	return r 
end