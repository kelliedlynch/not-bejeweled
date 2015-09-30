Tile = Class("Tile")
Tile.radius = 20
Tile.colors = {
	{
		name = "red",
		rgba = {1, 0, 0, .2}
	},
	{
		name = "green",
		rgba = {0, 1, 0, .2}
	},
	{
		name = "blue",
		rgba = {0, 0, 1, .2}
	},
	-- {
	-- 	name = "purple",
	-- 	rgba = {.8, 0, 1, .2}
	-- }
}
Tile.tierAlphaStep = .2


function Tile:constructor()
	local i = math.random(1, #self.colors)
	-- self.color = self.colors[i]
	-- self:setColor(unpack(self.colors[i].rgba))
	self.tier = 1
	self.color = {name = nil, rgba = {}}
	local c = self.colors[i].rgba
	self:setColor(c[1], c[2], c[3], c[4], self.colors[i].name)
end

function Tile:setColor(r, g, b, a, name)
	if name then self.color.name = name end
	local alpha
	if not a then
		a = self.color.rgba[4]
	end
	self.color.rgba = {r, g, b, a}
	if self.image then
		self.image:setFillColor(unpack(self.color.rgba))
	end
end

function Tile:changeTier(tier)
	local newTier
	if not tier then newTier = self.tier + 1 else newTier = tier end
	self.tier = newTier
	local newAlpha = newTier * self.tierAlphaStep
	local c = self.color.rgba
	local newAlpha = c[4] + self.tierAlphaStep
	self:setColor(c[1], c[2], c[3], newAlpha)
	self.text.text = self.tier
end

function Tile:drawTile(x, y)
	self.image = display.newCircle(x, y, self.radius)
	self.image:setFillColor(unpack(self.color.rgba))
	self.image:setStrokeColor(1,1,1)
	self.image:addEventListener("touch", self)
	self.text = display.newText(self.tier, x, y, native.systemFont, 18 )

end

function Tile:touch(event)
	local adjacentTiles = gameBoard:getAdjacentTiles(self)
	local phase = event.phase
	if "began" == phase then
		self.image.strokeWidth = 1		
		for _, tile in pairs(adjacentTiles) do
			tile.image.strokeWidth = 1
		end
	elseif "ended" == phase then
		self.image.strokeWidth = 0
		for _, tile in pairs(adjacentTiles) do
			tile.image.strokeWidth = 0
		end
		gameBoard:collapseOn(self)
	end
end

