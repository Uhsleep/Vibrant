local Dependencies = require(script.Parent.Parent.Parent.dependencyPaths)
local Roact = require(Dependencies.Roact)

local StudioToolbarContext = Roact.createContext(nil)

return StudioToolbarContext