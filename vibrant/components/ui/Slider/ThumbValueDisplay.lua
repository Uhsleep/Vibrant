local TextService = game:GetService("TextService")

local Vibrant = script:FindFirstAncestor("vibrant")
local Dependencies = require(Vibrant.DependencyPaths)
local Roact = require(Dependencies.Roact)

local e = Roact.createElement
-----------------------------------------------------------------------------

local function formatValue(value)
    -- TODO: Describe the logic behind this
    local epsilon = math.pow(10, -6)

    if value % 1 < epsilon then
        value = ("%d"):format(value)
    else
        value = ("%.2f"):format(value)
    end

    return value
end

local function calculateValueBackgroundWidth(value, fontFamily, fontWeight, fontStyle, textSize, padding)
    local params = Instance.new("GetTextBoundsParams")
    params.Text = value
    params.Font = Font.new(fontFamily, fontWeight, fontStyle)
    params.Size = textSize
    params.Width = math.huge

    return TextService:GetTextBoundsAsync(params).X + 2 * padding
end

-----------------------------------------------------------------------------

local ThumbValueDisplay = function(props)
    -- TextLabel properties
    local fontFamily = "rbxasset://fonts/families/RobotoCondensed.json"
    local fontWeight = Enum.FontWeight.Regular
    local fontStyle = Enum.FontStyle.Normal
    local textSize = 14 -- TODO: calculate the correct text size based on the height of the parent/thumb


    props.value = formatValue(props.value)
    local padding = 5
    local thumbValueBackgroundWidth = calculateValueBackgroundWidth(props.value, fontFamily, fontWeight, fontStyle, textSize, padding)

    local localProps = {
        thumbValueBackground = {
            AnchorPoint = Vector2.new(0.5, 1),
            BackgroundColor3 = Color3.fromRGB(35, 35, 35),
            BackgroundTransparency = 0.4,
            Position = UDim2.new(0.5, 0, 0, -3),
            Size = UDim2.new(0, thumbValueBackgroundWidth, 1, 0),
            Visible = props.visible
        },

        thumbValueContainer = {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(1, 0, 1, 0)
        },

        thumbValue = {
            -- Data
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),

            -- Text
            FontFace = Font.new(fontFamily, fontWeight, fontStyle),
            Text = props.value,
            TextColor3 = Color3.fromRGB(229, 229, 229),
            TextScaled = false,
            TextSize = 14,
            TextWrapped = false,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center
        }
    }

    return e("Frame", localProps.thumbValueBackground, {
        UICorner = e("UICorner", {
            CornerRadius = UDim.new(0, 5)
        }),

        Padding = e("UIPadding", {
            PaddingBottom = UDim.new(0, padding),
            PaddingLeft = UDim.new(0, padding),
            PaddingRight = UDim.new(0, padding),
            PaddingTop = UDim.new(0, padding)
        }),

        ThumbValueContainer = e("Frame", localProps.thumbValueContainer, {
            ThumbValue = e("TextLabel", localProps.thumbValue)
        })
    })
end

return ThumbValueDisplay