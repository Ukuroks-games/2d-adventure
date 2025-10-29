local stdlib = require(script.Parent.Parent.stdlib)

--[=[
	@class Audio
	@since v0.6.0
]=]
local Audio = {}

--[=[
	@prop Folder Folder
	@within Audio
	@since v0.6.0
]=]
Audio.Folder = stdlib.utility.CreateOrFindInstance(
	"Adventure2dAudio",
	"Folder",
	workspace
) :: Folder

--[=[
	@prop DefaultGroup string
	@within Audio
	@since v0.6.2
]=]
Audio.DefaultGroup = "Adventure2dAudio"

return Audio
