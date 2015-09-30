-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here

function removeByValue(t, v)
	for i,c in ipairs(t) do
		if c == v then
			table.remove(t, i)
			return
		end
	end
end

math.randomseed( os.time() )

require "Class"
require "Board"
require "Tile"

gameBoard = Board.new()
gameBoard:drawBoard()