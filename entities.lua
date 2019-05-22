local M = {}

local list = {}

function M.add(e)
	table.insert(list,e)
	e:event("init")
end	

function M.all()
	return ipairs(list)
end

function M.sort()
	table.sort(list, function(a,b) return a.z > b.z end)
end

return M