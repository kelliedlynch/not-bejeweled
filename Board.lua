Board = Class("Board")
Board.tiles = {}
Board.tilesWide = 7
Board.tilesHigh = 7
Board.horizMargin = 4
Board.offset = (display.viewableContentWidth - (Board.horizMargin * 2)) / Board.tilesWide
Board.vertMargin = (display.viewableContentHeight - Board.offset * Board.tilesHigh) / 2
Board.inactiveTiles = {}

function Board:constructor()

end

function Board:coordsToPos(xcoord, ycoord)
	local x = self.horizMargin + Tile.radius + (self.offset * (xcoord - 1))
	local y = self.vertMargin + Tile.radius + (self.offset * (ycoord - 1))
	return x, y
end

function Board:getCoordsOfTile(tile)
	for x, column in ipairs(self.tiles) do
		for y, t in ipairs(column) do
			if t == tile then
				return x, y
			end
		end
	end
end

function Board:getAdjacentTiles(tile)
	local xcoord, ycoord = self:getCoordsOfTile(tile)

	local adjacentTiles = {}
	if ycoord > 1 then
		adjacentTiles.above = self.tiles[xcoord][ycoord - 1] -- above
	end
	if ycoord < self.tilesHigh then
		adjacentTiles["below"] = self.tiles[xcoord][ycoord + 1] -- below
	end
	if xcoord > 1 then
		adjacentTiles["left"] = self.tiles[xcoord - 1][ycoord]  -- left
	end
	if xcoord < self.tilesWide then
		adjacentTiles["right"] = self.tiles[xcoord + 1][ycoord] -- right
	end
	return adjacentTiles
end

function Board:drawBoard()
	for xcoord=1, self.tilesWide do
		table.insert(self.tiles, {})
		for ycoord=1, self.tilesHigh do
			local x, y = self:coordsToPos(xcoord, ycoord)
			local tile = Tile.new()			
			tile:drawTile(x, y)
			table.insert(self.tiles[xcoord], tile)
		end
	end
end

function Board:collapseOn(centerTile)
	local xcoord, ycoord = self:getCoordsOfTile(centerTile)
	local x, y = self:coordsToPos(xcoord, ycoord)
	local adj = self:getAdjacentTiles(centerTile)
	local matched = 0
	local highestTier = centerTile.tier
	for location, tile in pairs(adj) do
		if centerTile.color.name == tile.color.name then
			transition.to(tile.image, {time = 200, x = x, y = y, onComplete = function(obj) obj:removeSelf() end})
			transition.to(tile.text, {time = 200, x = x, y = y, onComplete = function(obj) obj:removeSelf() end})
			local newTile = Tile.new()
			if location == "above" then
				removeByValue(self.tiles[xcoord], tile)

				table.insert(self.tiles[xcoord], 1, newTile)
				local xx, yy = self:coordsToPos(xcoord, 0)
				newTile:drawTile(xx, yy)
				for i=ycoord-1, 1, -1 do
					local xxx, yyy = self:coordsToPos(xcoord, i)
					transition.to(self.tiles[xcoord][i].image, {time = 200, x = xxx, y = yyy})
					transition.to(self.tiles[xcoord][i].text, {time = 200, x = xxx, y = yyy})
				end
			elseif location == "below" then 
				removeByValue(self.tiles[xcoord], tile)
			
				table.insert(self.tiles[xcoord], newTile)
				local xx, yy = self:coordsToPos(xcoord, self.tilesHigh + 1)
				newTile:drawTile(xx, yy)				
				for i=ycoord + 1, self.tilesHigh do
					local xxx, yyy = self:coordsToPos(xcoord, i)
					transition.to(self.tiles[xcoord][i].image, {time = 200, x = xxx, y = yyy})
					transition.to(self.tiles[xcoord][i].text, {time = 200, x = xxx, y = yyy})
				end
			elseif location == "right" then
				removeByValue(self.tiles[xcoord + 1], tile)
				
				for i=xcoord + 1, self.tilesWide - 1 do
					local xxx, yyy = self:coordsToPos(i, ycoord)
					transition.to(self.tiles[i+1][ycoord].image, {time = 200, x = xxx, y = yyy})
					transition.to(self.tiles[i+1][ycoord].text, {time = 200, x = xxx, y = yyy})
					table.insert(self.tiles[i], ycoord, self.tiles[i+1][ycoord])
					table.remove(self.tiles[i+1], ycoord)
				end

				table.insert(self.tiles[self.tilesWide], ycoord, newTile)
				local xx, yy = self:coordsToPos(self.tilesWide + 1, ycoord)
				newTile:drawTile(xx, yy)
				xx, yy = self:coordsToPos(self.tilesWide, ycoord)
				transition.to(newTile.image, {time = 200, x = xx, y = yy})
				transition.to(newTile.text, {time = 200, x = xx, y = yy})
			elseif location == "left" then
				removeByValue(self.tiles[xcoord - 1], tile)
				
				for i=xcoord - 1, 2, -1 do
					local xxx, yyy = self:coordsToPos(i, ycoord)
					transition.to(self.tiles[i-1][ycoord].image, {time = 200, x = xxx, y = yyy})
					transition.to(self.tiles[i-1][ycoord].text, {time = 200, x = xxx, y = yyy})
					table.insert(self.tiles[i], ycoord, self.tiles[i-1][ycoord])
					table.remove(self.tiles[i-1], ycoord)
				end

				table.insert(self.tiles[1], ycoord, newTile)
				local xx, yy = self:coordsToPos(0, ycoord)
				newTile:drawTile(xx, yy)
				xx, yy = self:coordsToPos(1, ycoord)
				transition.to(newTile.image, {time = 200, x = xx, y = yy})
				transition.to(newTile.text, {time = 200, x = xx, y = yy})
			end
			matched = matched + 1
			print(tile.tier, highestTier)
			if tile.tier > centerTile.tier then
				centerTile:changeTier(tile.tier)
			end
		end
	end
	if matched == 4 then
		centerTile:changeTier()
	end

end