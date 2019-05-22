function draw_connection(o,ratio)
	ratio = ratio or 0.9
	--love.graphics.setColor(0,100,200)
	local p = o.parent
	if(p) then
		if(o.r < p.r) then
			p,o=o,p
		end

		local x1, y1 = o:getPosition()
		local x2, y2 = p:getPosition()
		--[[if(not shadows) then
			y1 = y1 + o.z
			y2 = y2 + p.z
		end]]

		local tangent = (o.r-p.r)/dist(x1,y1,x2,y2)

		local th = math.atan2(y2-y1,x2-x1)
		local off = math.acos(tangent)
		

		ax1 = x1 + o.r*math.cos(th + off)*ratio
		ay1 = y1 + o.r*math.sin(th + off)*ratio
		bx1 = x1 + o.r*math.cos(th - off)*ratio
		by1 = y1 + o.r*math.sin(th - off)*ratio

		ax2 = x2 + p.r*math.cos(th + off)*ratio
		ay2 = y2 + p.r*math.sin(th + off)*ratio
		bx2 = x2 + p.r*math.cos(th - off)*ratio
		by2 = y2 + p.r*math.sin(th - off)*ratio

		local t = {ax1,ay1,ax2,ay2, 
				   bx2,by2,bx1,by1}
		for i in ipairs(t) do
			t[i] = tile*t[i]
		end
		love.graphics.polygon( "fill", t )
	end
end