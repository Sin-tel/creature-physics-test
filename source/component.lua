local Component = {}

function Component:new(name)
	local new = {}	
	--setmetatable(new, self)
	self.__index = self

	new.name = name
	return new
end

function Component:event(e)
	return e
end

function Component:update(dt)

end

function Component:draw_first()

end

function Component:draw()

end

return Component