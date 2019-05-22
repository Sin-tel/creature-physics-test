local physics = require "physics"
local entities = require "entities"

local Entity = {}

Entity.id = 1
local newId
local Event

function Entity:new(x,y,r)
	local new = {}
	setmetatable(new,self)
	self.__index = self

	--new.dead = false
	new.id = newId()
	new.components = {}
	new.r = r or 0.5
	new.a = 0
	new.physics = physics.newBall(x,y,new.id,r)
	new.z = -r*0.6 +math.random()*0.01

	--new.depth = 0
	new.parent = nil
	new.parentJoint = {}
	new.root = new
	new.child = {}

	new.color = {math.random()*32/255,(math.random()*32+120)/255,(math.random()*32+80)/255}

	return new
end

function Entity:addComponent(c)
	c.owner = self
	
	table.insert(self.components,c)
	assert(not self[c.name],"Trying to add two components with same name!")
	self[c.name] = c
end

function Entity:setParent(p,join)
	if(join) then
		self.parentJoint = physics.join(self,p,true)
	end

	self.parent = p
	table.insert(p.child,self)
end

function Entity:separate()
	for k,v in ipairs(self.parent.child) do
		if(v == self) then
			table.remove(self.parent.child,k)
			break
		end
	end
	self.parent = nil
	self.root = self


	
	for k,v in ipairs(self.parentJoint) do
		v:destroy()
	end
	self.parentJoint = {}

	self:init(self)
	for k,v in ipairs(self:getTree()) do
		v:event("dead")
		v.dead = true
	end
end

function Entity:getPosition()
	return self.physics.body:getPosition()
end

function Entity:getVelocity()
	return self.physics.body:getLinearVelocity()
end

function Entity:event( id, parameters )
	if(type(id) == "string") then
		e = Event:new( id, parameters, self )
	else
		e = id
	end
	
	for i,v in ipairs(self.components) do
		e = v:event(e)
	end
	
	return e
end

function Entity:add()
	assert(self.root == self)
	entities.add(self)
	for i,v in ipairs(self.child) do
		v:add()
	end
end

function Entity:init(root)
	root = root or self

	self.root = root
	physics.setId(self.physics,self.root.id)

	self.dead = false

	for i,v in ipairs(self.components) do
		v:event("init")
	end
	for i,v in ipairs(self.child) do
		v:init(root)
	end
end

function Entity:update(dt)
	for i,v in ipairs(self.components) do
		v:update(dt)
	end
end

function Entity:draw_first()
	for i,v in ipairs(self.components) do
		v:draw_first()
	end
end

function Entity:draw()
	for i,v in ipairs(self.components) do
		v:draw()
	end
end



function Entity:getTree(list)
	list = list or {}
	table.insert(list,self)
	for k,v in ipairs(self.child) do
		v:getTree(list)
	end
	return list
end

function newId()
	local id = Entity.id 
	Entity.id = Entity.id + 1
	return id
end

Event = {}

function Event:new( id, parameters, entity )
	local new = {}	
	setmetatable(new, self)
	self.__index = self

	
	new.id = id
	parameters = parameters or {}
	for k,v in pairs(parameters) do 
		new[k] = v
	end
	new.entity = entity

	return new
end

return Entity