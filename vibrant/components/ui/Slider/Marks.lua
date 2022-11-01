local Vibrant = script:FindFirstAncestor("vibrant")
local Dependencies = require(Vibrant.DependencyPaths)
local Roact = require(Dependencies.Roact)

local e = Roact.createElement
-----------------------------------------------------------------------------

local Marks = function(props)
    local marks = {}

    for index, markInfo in ipairs(props.marks) do
        marks["Mark" .. index] = e("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = markInfo.color,
            BackgroundTransparency = 0.1,
            BorderSizePixel = 0,
            Position = UDim2.new(markInfo.position, 0, 0, 3),
            Size = UDim2.new(0, 3, 0, 3),
            ZIndex = 2
        })
    end

    return Roact.createFragment(marks)
end

return Marks