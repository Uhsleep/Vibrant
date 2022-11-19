local Dependencies = require(script.Parent.Parent.Parent.DependencyPaths)
local Roact = require(Dependencies.Roact)

local StudioToolbarContext = Roact.createContext(nil)

return StudioToolbarContext