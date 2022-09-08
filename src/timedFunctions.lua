local functionList = {}

---comment
---@param callback any
---@param time number time to call this function in seconds
---@param isLoop boolean 
function AddTimedFunction(callback,time,isLoop)
	ObjectPooling(functionList, {
		ttl = time,
		time = time,
		callback = callback,
		loop = isLoop,
		enabled = true
	})
end

function UpdateTimedFunctions(dt)
	for i = 1, #functionList, 1 do
		local f = functionList[i]
		if f.enabled then
			f.ttl = f.ttl - dt
			if f.ttl <= 0 then
				f.callback()
				if f.loop then
					f.ttl = f.time
				else
					f.enabled = false
				end
			end
		end
	end
end