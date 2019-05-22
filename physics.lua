local M = {}
 
function M.init()
	love.physics.setMeter(30)
	M.world = love.physics.newWorld(0, 0, true)

	M.ground = {}
	M.ground.body = love.physics.newBody(M.world, 0, 0)
	
	--[[M.edge = {}
	M.edge.body = love.physics.newBody(M.world, 0, 0) 
	M.edge.shape = love.physics.newChainShape( true, 1.0, 1.0, w-1.0, 1.0, w-1.0, h-1.0, 1.0, h-1.0 )
	M.edge.fixture = love.physics.newFixture(M.edge.body, M.edge.shape)]]
end

function M.newBall(x,y,id,r)
	x = x or 0
	y = y or 0
	local r = (r or 0.5)*0.95
	local d = 2.0
	local group = -id
	
	x = x + math.random()*0.1
	y = y + math.random()*0.1

	new = {}

	new.body = love.physics.newBody(M.world, x, y, "dynamic")
	
	new.shape = love.physics.newCircleShape(r) 
	new.fixture = love.physics.newFixture(new.body, new.shape, d) 
	new.fixture:setRestitution(0.2) 
	new.fixture:setFriction(0.2) 

	new.fixture:setGroupIndex(group) --negative groups never collide with themselves
	--new.friction = love.physics.newFrictionJoint( new.body, M.ground.body, x, y, false )
	local m = new.body:getMass( )
	--new.friction:setMaxForce(m*10)
	--new.friction:setMaxTorque(3)
	new.body:setLinearDamping(2.0)
	new.body:setAngularDamping(10.0)

	return new
end

function M.setId(p,id)
	p.fixture:setGroupIndex(-id)
end

function M.join(e1, e2, muscles)
	local body1 = e1.physics.body
	local body2 = e2.physics.body
	local r = (e1.r + e2.r)

	local m = body1:getMass() + body2:getMass()

	local a1 = body1:getAngle()
	local a2 = body2:getAngle()

	local x1,y1 = body1:getPosition()
	local x2,y2 = body2:getPosition()

	local dx,dy = x2-x1,y2-y1
	local l = length(dx,dy)
	if(l > 0) then
		dx = dx/l
		dy = dy/l
	end
	local dx1 = math.cos(a1)*e1.r
	local dy1 = math.sin(a1)*e1.r

	local dx2 = math.cos(a2)*e2.r
	local dy2 = math.sin(a2)*e2.r


	local j1  = love.physics.newRevoluteJoint(body1, body2, x1+dx1, y1+dy1,x2-dx2, y2-dy2, false, math.floor((a2-a1+math.pi)/(2*math.pi) )*2*math.pi)
	
	j1:setLimitsEnabled( true )
	j1:setLimits( -0.9, 0.9 )

	if(muscles) then
		local j2  = love.physics.newDistanceJoint(body1, body2, x1+dy1, y1-dx1, x2+dy2, y2-dx2, false )
		
		j2:setLength(r)
		j2:setDampingRatio(1.0)
		j2:setFrequency(7.0/r)

		local j3  = love.physics.newDistanceJoint(body1, body2, x1-dy1, y1+dx1, x2-dy2, y2+dx2, false )
		
		j3:setLength(r)
		j3:setDampingRatio(1.0)
		j3:setFrequency(7.0/r)
		return {j1,j2,j3}
	else
		return {j1}
	end
end

function M.moveJoint(e1,force)
	local body1 = e1.physics.body
	--local body2 = e1.parent.physics.body

	local j = love.physics.newMouseJoint(body1, body1:getX(), body1:getY())
	--love.physics.newRopeJoint(body1, body2, body1:getX(), body1:getY(),body2:getX(), body2:getY(),3.0, false)

	j:setMaxForce(force or 50)
	j:setTarget(body1:getX(), body1:getY())

	return j
end


return M