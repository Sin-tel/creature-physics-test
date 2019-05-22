local physics = require "physics"

local map = {}

local addsquarevector
local newChain
local getList
local simplfyvectors
local equals
local remove
local newVector

function map.load()
	--map.imgd = map.imgd or love.image.newImageData( "map.png")
	map.chain = map.chain or {}
	--map.img = love.graphics.newImage(map.imgd)

	map.tiles = {}
	for x=0,w-1 do
		map.tiles[x] = {} 
		for y=0,h-1 do
			local p = 0.0--0.45
			local r = math.max(math.abs(x/w - 0.5),math.abs(y/h - 0.5))*2
			if( r <= 0.2) then
				p = 0.0
			elseif( r >= 0.85) then
				p = 0.6--0.65
			end
			map.tiles[x][y]= math.random()<p--map.imgd:getPixel(x,y) > 0
		end
	end
	for i = 1,8 do
		map.runCA()
	end
	
	map.refresh()
end

function map.getFree(x,y)
	--if(x < 0 or x >= w or y <0 or y >= h) then
	--	return false
	--else
		return not map.tiles[x][y]
	--end
end

function map.runCA(fill)
	local new = {}	
	for x=0,w-1 do
		new[x] = {} 
		for y=0,h-1 do
			local n = 0
			local m = 0
			for i = -1,1 do
				for j = -1,1 do
					if(x+i < 0 or x+i >= w or y+j < 0 or y+j >= h ) then
						n = n + 1
					elseif(map.tiles[x+i][y+j]) then
						n = n + 1
					end
				end
			end
			if fill then
				for i = -2,2 do
					for j = -2,2 do
						if(x+i < 0 or x+i >= w or y+j < 0 or y+j >= h ) then
							m = m + 1
						elseif(map.tiles[x+i][y+j]) then
							m = m + 1
						end
					end
				end
				new[x][y] = (n >= 5) or (m <= 1)
			else
				new[x][y] = (n >= 5) 
			end
		end
	end

	for x=0,w-1 do
		new[x][0] = true
		new[x][h-1] = true
	end
	for y=0,h-1 do
		new[0][y] = true
		new[w-1][y] = true
	end

	map.tiles = new

end

function map.refresh()
	--map.img = map.img or love.graphics.newImage(map.imgd)
	for k,v in ipairs(map.chain) do
		v.body:destroy()
	end
	map.chain = {}
	
	local n = 0

	local start = love.timer.getTime()
	local list = {}
	for x=0,w-1 do
		for y=0,h-1 do
			if(map.tiles[x][y]) then
				addsquarevector(list,x,y)
				n = n + 1
			end
		end
	end

	--should be between 46 - 50%
	print(math.floor(n/(w*h)*1000)/10 .. "% filled")

	
	simplfyvectors(list)


	

	local clist = {}
	while(true) do
		local l = getList(list)
	
		if(l) then
			local chain = newChain(l)
			table.insert(map.chain,chain)
		else
			break
		end
	end
	local result = love.timer.getTime() - start
	print( string.format( "It took %.3f milliseconds to make map!", result * 1000 ))
end

function map.draw()
	if(debug) then
		love.graphics.setColor(255,255,255)
		for x=0,map.imgd:getWidth()-1 do
			for y=0,map.imgd:getHeight()-1 do
				if(map.tiles[x][y]) then
					love.graphics.rectangle("fill",x*tile,y*tile,tile,tile)
				end
			end
		end
	end
	--love.graphics.setLineWidth(1.0/zoom)
	love.graphics.setLineWidth(1.0)
	love.graphics.setColor(100, 100, 100) 
	for k,v in ipairs(map.chain) do
		local list = {v.body:getWorldPoints(v.shape:getPoints())}
		for k,v in ipairs(list) do
			list[k] = tile*v
			--if(k%2 == 0) then
			--	list[k] = tile*(v-1)
				--love.graphics.line(list[k-1],list[k]+tile,list[k-1],list[k])
			--end
		end
		love.graphics.line(list)
	end
	
end

function newChain(list)
	local new = {}
	new.body = love.physics.newBody(physics.world, 0, 0) 
	new.shape = love.physics.newChainShape( true, list)
	new.fixture = love.physics.newFixture(new.body, new.shape)
	new.fixture:setFriction( 0.2 )
	new.fixture:setRestitution( 0.2 )

	return new
end

function getList(list)
	for i = #list,1,-1 do
		if(list[i].dead) then
			table.remove(list,i)
		end
	end
	if(#list>0) then
		local clist = {}

		local first = list[1]
		table.insert(clist,first.sx*0.5+first.ex*0.5)
		table.insert(clist,first.sy*0.5+first.ey*0.5)
		first.dead = true
		local v = first.next
		while v~=first do
			table.insert(clist,v.sx*0.5+v.ex*0.5)
			table.insert(clist,v.sy*0.5+v.ey*0.5)
			v.dead = true
			v = v.next
		end

		return clist
	else
		return nil
	end
end

function addsquarevector(list,x,y)
	a = newVector(x  ,y  ,x+1,y  )
	b = newVector(x+1,y  ,x+1,y+1)
	c = newVector(x+1,y+1,x  ,y+1)
	d = newVector(x  ,y+1,x  ,y  )
	a.next = b
	b.next = c
	c.next = d
	d.next = a

	a.prev = d
	d.prev = c
	c.prev = b
	b.prev = a 

	table.insert(list,a)
	table.insert(list,b)
	table.insert(list,c)
	table.insert(list,d)
end

function simplfyvectors(list)
	--prune neighboring vectors
	for i = 1, #list do
		local a = list[i]
		local b = list[i+2]
		if(a and b and equals(a,b)) then
			remove(a,b)
		end
	end
	for i = #list,1,-1 do
		if(list[i] and list[i].dead) then
			table.remove(list,i)
		end
	end
	
	for i = 1, #list do
		for j = i+1, i+1+h*3 do -- i+1, #list
			local a = list[i]
			local b = list[j]

			if(not b) then
				break
			end
			
			if(equals(a,b)) then
				remove(a,b)
				break
			end
		end
	end
end

function equals(a,b)
	if(not a.dead and not b.dead) then
		if(a.sx == b.sx) and (a.sy == b.sy) and (a.ex == b.ex) and (a.ey == b.ey) then
			return true
		elseif(a.sx == b.ex) and (a.sy == b.ey) and (a.ex == b.sx) and (a.ey == b.sy) then
			return true
		else
			return false
		end
	else
		return false
	end
end

function remove(a,b)
	--if(not a.dead and not b.dead) then
		a.dead = true
		b.dead = true

		join(a,b)
		join(b,a)
	--end
end

function join(a,b)
	--[[
	
	->-o  o->-          ->-o->-
	   v  ^        =>    
	-<-o  o-<-          -<-o-<-

	]]
	local p = a.prev
	p.next = b.next

	local n = b.next
	n.prev = p
end

function newVector(x1,y1,x2,y2)
	local new = {}
	new.sx = x1
	new.sy = y1
	new.ex = x2
	new.ey = y2
	return new
end

return map