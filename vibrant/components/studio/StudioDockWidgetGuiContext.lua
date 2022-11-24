local Dependencies = require(script.Parent.Parent.Parent.DependencyPaths)
local Roact = require(Dependencies.Roact)

local StudioDockWidgetGuiContext = Roact.createContext(nil)

return StudioDockWidgetGuiContext