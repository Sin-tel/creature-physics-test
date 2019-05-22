local M = {}

function M:new(speed,input)
	local new = {}
	setmetatable(new,self)
	self.__index = self
	new.input = input or 0
	new.output = 0

	new.s = speed or 1 
	new.prev = new.input
	return new
end
--self.output = lerp(self.output,self.input,self.s*dt)
function M:update(dt)
	--[[local n = self.output + self.prev - self.input
	
	self.output = lerp(n,0,self.s*dt)
	self.prev = self.input]]
	--self.output = lerp(self.output,self.input,self.s*dt)
	--[[local n = self.input - self.prev
	self.prev = self.input
	self.output = lerp(self.output,n,self.s*dt)]]
	--local n = self.output + self.prev - self.input
	
	self.output = self.input - self.prev

	self.prev = self.input
	return self.output
end

return M