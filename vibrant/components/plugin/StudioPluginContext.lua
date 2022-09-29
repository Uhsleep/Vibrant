local Dependencies = require(script.Parent.Parent.Parent.dependencyPaths)
local Roact = require(Dependencies.Roact)

local StudioPluginContext = Roact.createContext(nil)

return StudioPluginContext