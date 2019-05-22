function rotateVector(x,y , a)
	local rx = x*math.cos(a) - y*math.sin(a)
	local ry = x*math.sin(a) + y*math.cos(a)

	return rx,ry
end

function lerp(a, b, k) --smooth transitions
    return a * (1-k) + b * k 
end

function dist(x1,y1,x2,y2) 
	local dx,dy = x1-x2, y1-y2
	return math.sqrt((dx*dx)+(dy*dy))

end

function dot(x1,y1,x2,y2) 
	return x1*x2 + y1*y2
end

function cross(x1,y1,x2,y2) 
	return x1*y2 - y1*x2
end

function length(x1,y1)
	return math.sqrt((x1*x1)+(y1*y1))
end

function dist(x1,y1,x2,y2) 
	local dx,dy = x1-x2,y2-y1
	return math.sqrt((dx*dx)+(dy*dy))
end

function norm(x, y)
	local l = length(x,y)
	if( l == 0) then
		return 0,1
	else
		return x/l,y/l
	end
end

--[[function project(x1,y1,x2,y2) 
	local l = length(x2,y2)
	if(l>0) then
		x2 = x2/l
		y2 = y2/l
	end
	local s = dot(x1,y1,x2,y2)
	return s*x2,s*y2
end]]


function clamp(v,min,max)
	min = min or 0
	max = max or 1
	return math.min(math.max(v,min),max)
end