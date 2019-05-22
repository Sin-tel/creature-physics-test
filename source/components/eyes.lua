local Component = require "component"
--local S = require "signal"
local C = {}

function C:new()
	local new = Component:new("eyes")
	setmetatable(new, self)
	self.__index = self
	setmetatable(self, Component)

	return new
end

function C:event(e)
	return e
end



function C:draw()
	local o = self.owner
	local x,y = o:getPosition()
	local r = o.r

	--[[if(not shadows) then
		y = y+o.z*1.2
	end]]
	--[[love.graphics.setColor(210, 170, 170)
	love.graphics.circle("fill", x*tile, y*tile, r*tile*0.6)
	love.graphics.setColor(50, 20, 20)
	love.graphics.circle("fill", x*tile, y*tile, r*tile*0.3)]]


	
	

	love.graphics.setColor(o.color)

	local a = 1.3
	local ratio = 0.7
	love.graphics.circle("fill", (x+ratio*r*math.cos(o.a+a))*tile, (y+ratio*r*math.sin(o.a+a))*tile, r*tile*0.6)
	love.graphics.circle("fill", (x+ratio*r*math.cos(o.a-a))*tile, (y+ratio*r*math.sin(o.a-a))*tile, r*tile*0.6)
	love.graphics.setColor(210/255, 170/255, 170/255)
	love.graphics.circle("fill", (x+ratio*r*math.cos(o.a+a))*tile, (y+ratio*r*math.sin(o.a+a))*tile, r*tile*0.4)
	love.graphics.circle("fill", (x+ratio*r*math.cos(o.a-a))*tile, (y+ratio*r*math.sin(o.a-a))*tile, r*tile*0.4)
	love.graphics.setColor(50/255, 20/255, 20/255)
	love.graphics.circle("fill", (x+ratio*r*math.cos(o.a+a))*tile, (y+ratio*r*math.sin(o.a+a))*tile, r*tile*0.25)
	love.graphics.circle("fill", (x+ratio*r*math.cos(o.a-a))*tile, (y+ratio*r*math.sin(o.a-a))*tile, r*tile*0.25)

	--[[love.graphics.setColor(0, 0, 0)
	love.graphics.line(
		(x-0.3*r*math.cos(o.a+math.pi*0.5))*tile,
		(y-0.3*r*math.sin(o.a+math.pi*0.5))*tile,
		(x+0.3*r*math.cos(o.a+math.pi*0.5))*tile,
		(y+0.3*r*math.sin(o.a+math.pi*0.5))*tile)]]
end

return C

