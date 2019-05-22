local Entity = require "entity"
local entities = require "entities"
local Spine = require "components/spine"
local Leg = require "components/leg"
local Eyes = require "components/eyes"

local factory = {}

function factory.worm_piece(x,y,r,legs)
	
	--legs = math.random()<0.6 and legs
	--[[if(r%0.5 < 0.15 and r>0.5) then
		r = r-(r%0.5)
	end]]


	
	local new = Entity:new(x,y,r)
	new:addComponent(Spine:new())
	if(legs) then
		local leg = Entity:new(x,y,r*0.3)
		leg:addComponent(Leg:new(false))
		leg:setParent(new)
		if(math.random()>0.05) then
			leg = Entity:new(x,y,r*0.3)
			leg:addComponent(Leg:new(true))
			leg:setParent(new)
		end
	end

	return new
end

function factory.worm(x,y)
	local n = math.floor(10*math.exp(love.math.randomNormal(0.2, 0)))
	local s = love.math.randomNormal(0.1, 0.8)

	local head = factory.worm_piece(x,y,s*(0.4+math.random()*0.2),false)

	head:addComponent(Eyes:new())


	local last = head
	for i = 1,n do
		local p = i/n
		local r = (p*(1-p)*1.4) + 0.3 + love.math.randomNormal(0.2, 0)
		r = r*s

		r = clamp(r,0.2,10)
		
		local e = factory.worm_piece(x,y,r,i < n-1 and i > 1 and i%2 == 0) 
		if(i > n*0.6) then
			e.tail = true
		end
		e:setParent(last,true)
		last = e
	end

	head:add()
	head:init()


	return head
end

return factory