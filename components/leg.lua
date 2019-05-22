local Component = require "component"
local physics = require "physics"
local C = {}

function C:new(right)
	local new = Component:new("leg")
	setmetatable(new, self)
	self.__index = self
	setmetatable(self, Component)

	new.phase = math.random()*2
	new.phaseShift = 0
	
	new.right = right
	--new.speed = math.random()*2 + 2
	return new
end

function C:event(e)
	if(e.id == "init") then
		self.force = 20*self.owner.parent.physics.body:getMass() 
		if(not self.move) then
			self.move = physics.moveJoint(self.owner,10) --200
		end
		self.length = 1.8*self.owner.parent.r
		--self.owner.z = 0
	end
	return e
end

function C:update(dt)
	local p = self.owner.parent
	--local o = self.owner

	if(not self.owner.dead) then
		self.phase = self.phase+dt
	end
	

	local x,y = p:getPosition()
	local dx,dy = p.spine.dx, p.spine.dy
	local r = self.length

	local ox,oy = self.owner:getPosition()

	local stopped = false

	if(dx == 0 and dy ==0 ) then
		stopped = true
		dx = math.cos(p.a)
		dy = math.sin(p.a)
	end

	--grabbed
	self.move:setTarget(ox,oy)
	if(self.phase < 0.25 and not stopped) then
		local a = math.pi*0.5
		if(self.right) then
			a = -math.pi*0.5
		end
		local tx, ty = rotateVector(dx, dy, a*0.4)
		local vx, vy = self.owner.physics.body:getLinearVelocity()

		local x1 = x+r*tx
		local y1 = y+r*ty
		self.move:setTarget(x1+vx/60,y1+vy/60)
	else
		local a = -0.5
		if(self.right) then
			a = 0.5
		end
		--TODO rotate opposite when reversing!


		dx,dy = rotateVector(dx,dy,a)
		if(not stopped) then
			p.physics.body:applyForce( self.force*dx, self.force*dy)
		end
	end

	

	local x1,y1 = self.owner:getPosition()
	if(dist(x1,y1,x,y) > self.length*1.1 and self.phase > 0.5) then
		self.phase = 0
	end

	if(dist(x1,y1,x,y) > self.length*2.0) then
		self.phase = 0
	end

	if(dist(x1,y1,x,y) > self.length*3.0) then
		self.owner.physics.body:setPosition(x,y)
		self.owner.physics.body:setLinearVelocity(0,0)
	end

	--[[if( - dot(x1-x,y1-y,dx,dy)>self.length ) then  --or self.phase>2
		self.phase = 0
	end]]

	self.owner.a = math.atan2(y1-y,x1-x)
end

function C:draw_first()
	
	local o = self.owner
	local x,y = o:getPosition()
	local r = o.r
	
	love.graphics.setColor(o.color)

	--[[if(not shadows) then
		y = y+o.z
	end]]
	love.graphics.circle("fill", x*tile, y*tile, r*tile*1.1)
	--love.graphics.setColor(80, 20, 10)

	draw_connection(o,0.9)
end

return C

