-- Subclass inheritance function from lua-users wiki
function Class( baseClass )
	local new_class = {}
	local class_mt = { __index = new_class }

	function new_class.new(...)
		local newinst = {}
		setmetatable( newinst, class_mt )
		newinst:constructor(...)
		return newinst
	end

	if baseClass then
		setmetatable( new_class, { __index = baseClass } )
	end

	return new_class
end