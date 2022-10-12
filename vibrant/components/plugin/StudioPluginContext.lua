local Dependencies = require(script.Parent.Parent.Parent.DependencyPaths)
local Roact = require(Dependencies.Roact)

local StudioPluginContext = Roact.createContext(nil)

return StudioPluginContext