local Component = require "component"
--local S = require "signal"
local C = {}

function C:new()
	local new = Component:new("spine")
	setmetatable(new, self)
	self.__index = self
	setmetatable(self, Component)

	new.dx = 0
	new.dy = 0

	new.curve = 0

	return new
end

function C:event(e)
	if(e.id == "init") then
		--
	elseif(e.id == "move") then
		local dx,dy = e.dx, e.dy
		local x,y = self.owner:getPosition()
		if(self.owner.parent) then
			if(length(dx,dy) > 0.9) then
				self:setTarget(e)
			else
				self.dx, self.dy = 0,0
			end
		else
			local c = self.owner.child[1]
			self.dx, self.dy = dx, dy
			if(c) then
				local a = self.owner.a
				
				if(math.cos(a)*dx+math.sin(a)*dy < -0.3) then
					e.reverse = true
				end
			
			end
		end

		for k,v in ipairs(self.owner.child) do
			v:event(e)
		end
	end
	return e
end

function C:update(dt)
	local o = self.owner
	if(self.owner.dead) then
		self.dx,self.dy = 0,0
	end

	if(self.owner.parent) then
		

		local x1,y1 = o:getPosition()
		local x2,y2 = o.parent:getPosition()
		self.muscleLength = math.sqrt(dist(x1,y1,x2,y2)^2 + (o.r-o.parent.r)^2)
		
		local curve = self.curve
		curve = math.exp(curve)
		self.owner.parentJoint[2]:setLength(self.muscleLength*(curve))
		self.owner.parentJoint[3]:setLength(self.muscleLength*(1/curve))
	end

	self.owner.a = self.owner.physics.body:getAngle( )%(math.pi*2)


	local w = 1.0*length(self.owner:getVelocity())*dt/self.owner.r
end

function C:setTarget(e)
	local o = self.owner

	local x,y = o:getPosition()
	local p_x,p_y = o.parent:getPosition()

	local r = o.r + o.parent.r

	local dx = p_x - x
	local dy = p_y - y 

	local l = math.sqrt((dx*dx)+(dy*dy))
	local a = math.atan2(dy,dx)
	if(l > 0.1) then
		dx = dx/l
		dy = dy/l
	end

	--dx = (l-r)*math.cos(a)
	--dy = (l-r)*math.sin(a)
	
	if(e.reverse) then
		dx = -math.cos(o.a)
		dy = -math.sin(o.a)
	end
	
	self.dx = dx
	self.dy = dy

	
	local c = 0.7*cross(math.cos(o.parent.a),math.sin(o.parent.a),e.dx,e.dy) 
	
	if(o.tail) then
		c = c*0--0.2
	end

	if(e.reverse) then
		c = 0
	end

	if(left) then
		c = 0.5
	elseif right then
		c = -0.5
	end
	self.curve = c
end

function C:draw_first()
	local o = self.owner
	local x,y = o:getPosition()
	local r = o.r
	
	love.graphics.setColor(o.color)
	
	
	draw_connection(o,1.0)
end

function C:draw()
	local o = self.owner
	local x,y = o:getPosition()
	local r = o.r

	--[[if(not shadows) then
		y = y+o.z
	end]]
	
	love.graphics.setColor(o.color)
	love.graphics.circle("fill", x*tile, y*tile, r*tile*1.0,24)

end

return C

