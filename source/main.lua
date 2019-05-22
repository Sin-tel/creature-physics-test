--[[
food:
- herbivore: plants, pellet food
- carnivore: sometimes eats smaller creatures, also pellet food
- detritivore/filter feeder: ignores hunger


toys:
- ball variations: balls, tiny gear, donut, stick
- ball on stick, bell?
- food that doubles as toy: candy, 
- laser pointer
- pinball shit

chill zones??

]]

local physics = require "physics"
local entities = require "entities"
local factory = require "factory"
local map = require "map"

require "help"
require "draw_f"

debug = false
--print console directly
io.stdout:setvbuf("no")

w = 80
h = 45

scale = 2
tile = 8
zoom = 1.0
zoomGoal = 1.0


width = w*scale*tile
height = h*scale*tile

love.window.setMode(width,height,{vsync=true,fullscreen=false})
canvas = love.graphics.newCanvas(w*tile,h*tile)
canvas_entities = love.graphics.newCanvas(w*tile,h*tile)
--canvas_shadows = love.graphics.newCanvas(w*tile,h*tile)

diag = math.sqrt(2)

mouseX = 5
mouseY = 5

time = 0

selected = nil

ai_angle = 0

camx,camy = w/2,h/2
overview = true

function love.load()
	--for k, v in pairs(os.date("*t")) do print(k, v) end
	--print(os.getenv("USERNAME"))
	math.randomseed(os.time())
	--initial graphics setup
	love.graphics.setBackgroundColor(20/255,20/255, 20/255) 
	love.graphics.setLineStyle( "rough" )
	love.graphics.setLineJoin("bevel")
	love.graphics.setDefaultFilter("nearest", "nearest")
	love.graphics.setLineWidth(1)
	canvas:setFilter("nearest", "nearest")
	canvas_entities:setFilter("nearest", "nearest")
	--canvas_debug:setFilter("nearest", "nearest")

	physics.init()
	map.load()

	player = factory.worm(w/2,h/2)

	--camx,camy = player:getPosition()

	worm = {}
	local i = 0
	while i < 10 do
		local x,y = math.random()*w,math.random()*h
		x,y = math.floor(x),math.floor(y)
		
		if(map.getFree(x,y) and map.getFree(x+1,y) and map.getFree(x-1,y) and map.getFree(x,y+1) and map.getFree(x,y-1)) then
			table.insert(worm,factory.worm(x+0.5,y+0.5))
			i=i+1
		end
	end
end

function love.keypressed(key, isrepeat)

	if (key == "g") then
		debug = not debug
	elseif (key == "z") then
		overview = not overview
		if(overview) then
			--camx = h/2
			--camy = w/2
			zoomGoal = 1.0
		else
			zoomGoal = 1/player.r
		end
	elseif( key == "n") then
		map.load()
	elseif( key == "m") then
		map.runCA()
		map.refresh()
	elseif (key == "escape") then 
		love.event.quit()
	end
end

function love.mousepressed(x, y, button, istouch)
	selected = nil
	for k,v in entities.all() do
		local x,y = v:getPosition()
		if(dist(x,y,mouseX,mouseY) <= v.r ) then
			selected = v
		end
	end
	if(button == 2 and selected and selected.parent) then
		selected:separate()
	end

	if(selected) then
		mouseJoint = physics.moveJoint(selected,30000)
	end

	if(button == 1) then
		--map:refresh()
	end
end

function love.mousereleased(x, y, button, istouch)
	if(mouseJoint) then
		mouseJoint:destroy()
		mouseJoint = nil
	end


	local prev = selected
	selected = nil
	for k,v in entities.all() do
		local x,y = v:getPosition()
		if(dist(x,y,mouseX,mouseY) <= v.r ) then
			selected = v
		end
	end

	if(button == 2 and prev and selected and prev.root ~= selected.root) then
		prev:setParent(selected,true)
		selected.root:init(selected.root)
		--player = selected.root
	end
end

function love.wheelmoved(x, y)
    if y > 0 then
        zoomGoal = zoomGoal*1.2
    elseif y < 0 then
        zoomGoal = zoomGoal/1.2
    end
    zoomGoal = math.max(1.0,zoomGoal)
end

 
function love.update(dt)
	--mouseX = (love.mouse.getX()/(tile*scale) + camx - w/2 )/zoom
	--mouseY = (love.mouse.getY()/(tile*scale) + camy - h/2 )/zoom
	mouseX = (love.mouse.getX()-width/2)/(tile*scale*zoom) + camx
	mouseY = (love.mouse.getY()-height/2)/(tile*scale*zoom) + camy


	if(mouseJoint) then
		mouseJoint:setTarget(mouseX,mouseY)
	end

	if(love.keyboard.isDown("space")) then
		space = true
	else
		space = false
	end

	if(love.keyboard.isDown("lshift")) then
		slowmo = true
	else
		slowmo = false
	end

	local dx,dy = 0,0

	if(love.keyboard.isDown("a") or love.keyboard.isDown("left")) then
		dx = -1
	elseif(love.keyboard.isDown("d") or love.keyboard.isDown("right")) then
		dx = 1
	end
	if(love.keyboard.isDown("w") or love.keyboard.isDown("up")) then
		dy = -1
	elseif(love.keyboard.isDown("s") or love.keyboard.isDown("down")) then
		dy = 1
	end
	if(dx~=0 and dy~=0) then
		dx = dx/diag
		dy = dy/diag
	end

	--[[dx,dy = player:getPosition()
	dx,dy = -dx + mouseX, -dy + mouseY
	local l = length(dx,dy)
	if(l > 1.0) then
		dx = dx/l
		dy = dy/l
	end]]

	if love.keyboard.isDown("q") then
		left = true
	else
		left = false
	end
	if love.keyboard.isDown("e") then
		right = true
	else
		right = false
	end


	local input = dx ~= 0 or dy ~= 0 or left or right or space 
	player:event("move", {dx = dx, dy = dy})

	for k,v in ipairs(worm) do
		local a = ai_angle*math.sin(k)*3+k--
		local dx = math.cos(a)
		local dy = math.sin(a)

		--[[dx, dy = v:getPosition()
		px, py = player:getPosition()
		dx, dy = px - dx, py - dy
		dx, dy = norm(dx, dy)]]
		--local rdx,rdy = rotateVector(dx,dy,k)
		v:event("move", {dx = dx, dy = dy})
	end

	if(not love.mouse.isDown(2)) then
		updateWorld(dt)
	end
end
 
function updateWorld(dt)
	dt = 1/60
	if(slowmo) then
		dt = dt/5
	end
	time = time + dt


	for k,v in entities.all() do
		v:update(dt)
	end
	
	physics.world:update(dt) 

	ai_angle = ai_angle + 0.2*dt

	local px,py = player:getPosition()
	if(overview) then
		px,py = w/2,h/2
	end

	zoom = lerp(zoom,zoomGoal,dt*2*zoom)
	camx = lerp(camx,px,dt*2*zoom)
	camy = lerp(camy,py,dt*2*zoom)

end

function love.draw()
	entities.sort()

	--if(not overview) then
		love.graphics.translate(w*tile/2,h*tile/2)
		love.graphics.scale(zoom)
		love.graphics.translate(-camx*tile,-camy*tile)
		--love.graphics.translate(math.floor(-camx*tile*zoom)/zoom,math.floor(-camy*tile*zoom)/zoom)
	--end
	--love.graphics.translate((-camx*tile*zoom)/zoom,(-camy*tile*zoom)/zoom)

	love.graphics.setCanvas(canvas_entities)
	love.graphics.clear()

	for k,v in entities.all() do
		v:draw_first()
	end
	for k,v in entities.all() do
		v:draw()
	end

	if(debug) then



		--[[love.graphics.setLineWidth(1/zoom)
		love.graphics.setColor(0, 255, 0,10)
		for x = 1,w do
			love.graphics.line(x*tile,0,x*tile,h*tile)
		end
		for y = 1,h do
			love.graphics.line(0,y*tile,w*tile,y*tile)
		end]]
		love.graphics.setColor(100/255, 100/255, 100/255)
		for k,v in entities.all() do
			local x,y = v:getPosition()
			local r = v.r
			local a = v.a
			--love.graphics.setColor(150, 100, 100)
			love.graphics.setColor(1, 1, 1,100/255)
			love.graphics.circle("line", (x)*tile, (y)*tile, r*tile)
			love.graphics.line(x*tile,y*tile,(x+r*math.cos(a))*tile,(y+r*math.sin(a))*tile)
			if(v.spine) then
				love.graphics.setColor(200/255, 200/255, 200/255)
				love.graphics.line(x*tile,y*tile,(x+v.spine.dx)*tile,(y+v.spine.dy)*tile)
			end
		end

		love.graphics.setColor(255/255, 0, 255/255, 200/255)
		for k,v in ipairs(physics.world:getJointList()) do
			if(v:getType( ) ~= "friction") then
				local x1, y1, x2, y2 = v:getAnchors()
				
				love.graphics.line(x1*tile, y1*tile, x2*tile, y2*tile)
			end 
		end
	
		love.graphics.print("FPS: "..tostring(love.timer.getFPS( )), 4, 2)
	end
	map.draw()
	--love.graphics.setCanvas(canvas)
	--love.graphics.clear(30,30,30)


	love.graphics.origin()

	love.graphics.setCanvas()
	love.graphics.clear(30/255,30/255,30/255)

	love.graphics.setColor(0, 0, 0,128/255)
	--love.graphics.draw(canvas_entities,-0.005*width*scale,-0.005*height*scale,0,1.02*scale)	
	love.graphics.draw(canvas_entities,1*zoom,4*zoom,0,scale)	
	love.graphics.setColor(255/255, 255/255, 255/255)
	love.graphics.draw(canvas_entities,0,0,0,scale)
end