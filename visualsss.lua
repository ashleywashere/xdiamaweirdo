    
-- Services
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local function Lerp(a, b, t)
    return a + (b - a) * t
end

local function LerpColor(color1, color2, t)
      return Color3.new(
        Lerp(color1.R, color2.R, t),
        Lerp(color1.G, color2.G, t),
        Lerp(color1.B, color2.B, t)
    )
end

-- VisualKit
local VisualKit = {}; VisualKit.__index = VisualKit; do
    function VisualKit:Round_V2(V2)
        return Vector2.new(math.floor(V2.X + 0.5), math.floor(V2.Y + 0.5))
    end
    function VisualKit:V3_To_V2(V3)
        return Vector2.new(V3.X, V3.Y)
    end
    function VisualKit:Draw(Object, Properties)
        Object = Drawing.new(Object)
        for Property, Value in pairs(Properties) do
          
            Object[Property] = Value
        end
        return Object
    end
    function VisualKit:Instance(Object, Properties)
        Object = Instance.new(Object)
        for Property, Value in pairs(Properties) do
            Object[Property] = Value
        end
        return Object
    end
    function VisualKit:Get_Bounding_Vectors(Part)
        local Part_CFrame, Part_Size = Part.CFrame, Part.Size 
        local X, Y, Z = Part_Size.X, Part_Size.Y, Part_Size.Z
        return {
            TBRC = Part_CFrame * CFrame.new(X, Y * 1.3, Z),
            TBLC = Part_CFrame * CFrame.new(-X, Y * 1.3, Z),
            TFRC = Part_CFrame * CFrame.new(X, Y * 1.3, -Z),
            TFLC = Part_CFrame * CFrame.new(-X, Y * 1.3, -Z),
            BBRC = Part_CFrame * CFrame.new(X, -Y * 1.6, Z),
            BBLC = Part_CFrame * CFrame.new(-X, -Y * 1.6, Z),
            BFRC = Part_CFrame * CFrame.new(X, -Y * 1.6, -Z),
            BFLC = Part_CFrame * CFrame.new(-X, -Y * 1.6, -Z),
        };
    end
    function VisualKit:Drawing_Transparency(Transparency)
        return 1 - Transparency
    end
end

local Images = {
    ["Wooden Bow"] = "https://raw.githubusercontent.com/ashleywashere/xdiamaweirdo/refs/heads/main/imgs/bow.png",
    ["Salvaged AK47"] = "https://raw.githubusercontent.com/ashleywashere/xdiamaweirdo/refs/heads/main/imgs/ak47.png",
    ["Sleeping Bag"] = "https://raw.githubusercontent.com/ashleywashere/xdiamaweirdo/refs/heads/main/imgs/SleepingBag.png",
    ["Hammer"] = "https://raw.githubusercontent.com/ashleywashere/xdiamaweirdo/refs/heads/main/imgs/Hammer.png",
    ["Blueprint"] = "https://raw.githubusercontent.com/ashleywashere/xdiamaweirdo/refs/heads/main/imgs/Blueprint.png",
    ["Crossbow"] = "https://raw.githubusercontent.com/ashleywashere/xdiamaweirdo/refs/heads/main/imgs/Crossbow.png",
    ["Military Barrett"] = "https://raw.githubusercontent.com/ashleywashere/xdiamaweirdo/refs/heads/main/imgs/MilitaryBarrett.png",
    ["Military M4A1"] = "https://raw.githubusercontent.com/ashleywashere/xdiamaweirdo/refs/heads/main/imgs/MilitaryM4A1.png",
    ["Salvaged AK74u"] = "https://raw.githubusercontent.com/ashleywashere/xdiamaweirdo/refs/heads/main/imgs/SalvagedAK74u.png",
    ["Salvaged SMG"] = "https://raw.githubusercontent.com/ashleywashere/xdiamaweirdo/refs/heads/main/imgs/SalvagedSMG.png",
    ["Small Medkit"] = "https://raw.githubusercontent.com/ashleywashere/xdiamaweirdo/refs/heads/main/imgs/SmallMedkit.png",
    ["Bandage"] = "https://raw.githubusercontent.com/ashleywashere/xdiamaweirdo/refs/heads/main/imgs/Bandage.png",
    ["Metal Barricade"] = "https://raw.githubusercontent.com/ashleywashere/xdiamaweirdo/refs/heads/main/imgs/MetalBarricade.png",
    ["Hands"] = "" -- No image for "Hands"
}

local CachedImages = {}
local LoadingQueue = {}

local function AsyncLoadImage(name, url)
    if url ~= "" then
        -- Add to loading queue
        table.insert(LoadingQueue, coroutine.create(function()
            local success, result = pcall(function() return game:HttpGet(url) end)
            if success then
                CachedImages[name] = result
            else
                CachedImages[name] = "" -- Fallback in case of error
            end
        end))
    else
        CachedImages[name] = "" -- No image for "Hands"
    end
end

-- Start loading all images asynchronously
for name, url in pairs(Images) do
    AsyncLoadImage(name, url)
end

-- Run the loading queue with slight delays to avoid freezing
spawn(function()
    while #LoadingQueue > 0 do
        local thread = table.remove(LoadingQueue, 1)
        coroutine.resume(thread)
        wait(0.05) -- Small delay between each load to prevent lag spikes
    end
end)

local ESP; ESP = {
    Settings = {
        Enabled = false,
        Bold_Text = false,
        Objects_Enabled = false,
        Team_Check = false,
        Improved_Visible_Check = false,
        Maximal_Distance = 1000,
        Object_Maximal_Distance = 1000,
        Highlight = {Enabled = false, Color = Color3.new(1, 0, 0), Target = ""},
        WeaponIcon = {Enabled = false, Position = "Bottom"},
        Skeleton = {Enabled = false, Outline = false},
        Box = {Enabled = false, Color = Color3.new(1, 1, 1), Transparency = 0},
        Box_Outline = {Enabled = false, Color = Color3.new(0, 0, 0), Transparency = 0, Outline_Size = 1},
        Healthbar = {Enabled = false, Position = "Left", ColorHigh = Color3.new(0, 1, 0), ColorLow = Color3.new(1, 0, 0)},
        Name = {Enabled = false, Position = "Top", Color = Color3.new(1, 1, 1), Transparency = 0, OutlineColor = Color3.new(0, 0, 0)},
        Distance = {Enabled = false, Position = "Bottom", Color = Color3.new(1, 1, 1), Transparency = 0, OutlineColor = Color3.new(0, 0, 0)},
        Tool = {Enabled = false, Position = "Right", Color = Color3.new(1, 1, 1), Transparency = 0, OutlineColor = Color3.new(0, 0, 0)},
        Health = {Enabled = false, Position = "Right", Transparency = 0, OutlineColor = Color3.new(0, 0, 0)},
        Image = {Enabled = false, Image = "Taxi"},
        China_Hat = {Enabled = false, Color = Color3.new(1, 1, 1), Transparency = 0.5, Height = 0.5, Radius = 1, Offset = 1}
    },
    Objects = {},
    Overrides = {},
    China_Hat = {},
    SkelParts = {
    "HeadTorso",
    "TorsoToRightLeg",
    "TorsoToLeftLeg",
    "LeftLegToFoot",
    "RightLegToFoot",
    "TorsoToRightArm",
    "RightArmToHand",
    "TorsoToLeftArm",
    "LeftArmToHand"
    },
    bodyjoint = {
        HeadTorso = {"Head", "LowerTorso"},
        TorsoToRightLeg = {"LowerTorso", "RightUpperLeg"},
        TorsoToLeftLeg = {"LowerTorso", "LeftUpperLeg"},
        LeftLegToFoot = {"LeftUpperLeg", "LeftFoot"},
        RightLegToFoot = {"RightUpperLeg", "RightFoot"},
        TorsoToRightArm = {"UpperTorso", "RightUpperArm"},
        RightArmToHand = {"RightUpperArm", "RightHand"},
        TorsoToLeftArm = {"UpperTorso", "LeftUpperArm"},
        LeftArmToHand = {"LeftUpperArm", "LeftHand"}
    }
}
ESP.__index = ESP

function ESP:UpdateImages()
    self.Settings.Image.Raw = Images[self.Settings.Image.Image]
    for _, Object in pairs(self.Objects) do
        for Index, Drawing in pairs(Object.Components) do
            if Index == "Image" then
                Drawing.Data = self.Settings.Image.Raw
            end
        end
    end
end

function ESP:GetObject(Object)
    return self.Objects[Object]
end


function ESP:Toggle(State)
    self.Settings.Enabled = State
end

function ESP:Get_Team(Player)
    if self.Overrides.Get_Team ~= nil then
        return self.Overrides.Get_Team(Player)
    end
    return Player.Team
end

function ESP:Get_Character(Player)
    if ESP.Overrides.Get_Character ~= nil then
        return ESP.Overrides.Get_Character(Player)
    end
    return Player.Character
end

function ESP:Get_Tool(Player, WeaponIcon)
    local toolName = "Hands"
    local toolIcon = CachedImages["Hands"] or "" -- Use cached image or fallback

    local Character = self:Get_Character(Player)
    if Character then
        for _, Tool in pairs(Character:GetChildren()) do
            if Tool:IsA("Model") then
                if CachedImages[Tool.Name] then
                    toolName, toolIcon = Tool.Name, CachedImages[Tool.Name]
                end
            end
        end
    end
    return toolName, toolIcon
end

function ESP:Get_Health(Player)
    if self.Overrides.Get_Character ~= nil then
        return self.Overrides.Get_Health(Player)
    end
    local Character = self:Get_Character(Player)
    if Character then
        local Humanoid = Character:FindFirstChildOfClass("Humanoid")
        if Humanoid then
            return Humanoid.Health
        end
    end
    return 100
end

local Passed = false
local function Pass_Through(From, Target, RaycastParams_, Ignore_Table)
    RaycastParams_.FilterDescendantsInstances = Ignore_Table
    local Result = Workspace:Raycast(From, (Target.Position - From).unit * 10000, RaycastParams_)
    if Result then
        local Instance_ = Result.Instance
        if Instance_:IsDescendantOf(Target.Parent) then
            Passed = true
            return true
        elseif Instance_.CanCollide == false or Instance_.Transparency == 1 then
            if Instance_.Name ~= "Head" and Instance_.Name ~= "HumanoidRootPart" then
                table.insert(Ignore_Table, Instance_)
                Pass_Through(Result.Position, Target, RaycastParams_, Ignore_Table)
            end
        end
    end
end

function ESP:Check_Visible(Target, FromHead)
    if self.Overrides.Check_Visible ~= nil then
        return self.Overrides.Check_Visible(Player)
    end
    local Character = LocalPlayer.Character
    if not Character then return false end
    local Head = Character:FindFirstChild("Head")
    if not Head then return false end
    local RaycastParams_ = RaycastParams.new();
    RaycastParams_.FilterType = Enum.RaycastFilterType.Blacklist;
    local Ignore_Table = {Camera, LocalPlayer.Character}
    RaycastParams_.FilterDescendantsInstances = Ignore_Table;
    RaycastParams_.IgnoreWater = true;
    local From = FromHead and Head.Position or Camera.CFrame.p
    local Result = Workspace:Raycast(From, (Target.Position - From).unit * 10000, RaycastParams_)
    Passed = false
    if Result then
        local Instance_ = Result.Instance
        if Instance_:IsDescendantOf(Target.Parent) then
            return true
        elseif ESP.Settings.Improved_Visible_Check and Instance_.CanCollide == false or Instance_.Transparency == 1 then
            if Instance_.Name ~= "Head" and Instance_.Name ~= "HumanoidRootPart" then
                table.insert(Ignore_Table, Instance_)
                Pass_Through(Result.Position, Target, RaycastParams_, Ignore_Table)
            end
        end
    end
    return Passed
end

local Player_Metatable = {}
do -- Player Metatable
    Player_Metatable.__index = Player_Metatable
    function Player_Metatable:Destroy()
        for Index, Component in pairs(self.Components) do
            Component.Visible = false
            Component:Remove()
            self.Components[Index] = nil
        end
        ESP.Objects[self.Player] = nil
    end
    function Player_Metatable:Update()
        local Box, Box_Outline = self.Components.Box, self.Components.Box_Outline
        local WeaponIcon = self.Components.WeaponIcon
        local Healthbar, Healthbar_Outline = self.Components.Healthbar, self.Components.Healthbar_Outline
        local Name, NameBold = self.Components.Name, self.Components.NameBold
        local Distance, DistanceBold = self.Components.Distance, self.Components.DistanceBold
        local Tool, ToolBold = self.Components.Tool, self.Components.ToolBold
        local Health, HealthBold = self.Components.Health, self.Components.HealthBold
        local Image = self.Components.Image
        local DisplayedHealth = self.Components.DisplayedHealth
        
        for _, partName in ipairs(ESP.SkelParts) do
        
        if self.Components[partName .. "Outline"] == nil then self:Destroy() end

        if self.Components[partName] == nil then self:Destroy() end

        end
        
        if Box == nil or WeaponIcon == nil or Box_Outline == nil or Healthbar == nil or Healthbar_Outline == nil or Name == nil or NameBold == nil or Distance == nil or DistanceBold == nil or Tool == nil or ToolBold == nil or Health == nil or HealthBold == nil then
            self:Destroy()
        end
        local Character = ESP:Get_Character(self.Player)
        if Character ~= nil then
            local Head, HumanoidRootPart, Humanoid = Character:FindFirstChild("Head"), Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChildOfClass("Humanoid")
            if not Humanoid then
                Box.Visible = false
                WeaponIcon.Visible = false
                Box_Outline.Visible = false
                Healthbar.Visible = false
                Healthbar_Outline.Visible = false
                Name.Visible = false
                NameBold.Visible = false
                Distance.Visible = false
                DistanceBold.Visible = false
                Tool.Visible = false
                ToolBold.Visible = false
                Health.Visible = false
                HealthBold.Visible = false
                Image.Visible = false
                for _, partName in ipairs(ESP.SkelParts) do
        
                    self.Components[partName .. "Outline"].Visible = false
                
                    self.Components[partName].Visible = false
                
                end
                return
            end
            local Current_Health, Health_Maximum = ESP:Get_Health(self.Player), Humanoid.MaxHealth
            if Head and HumanoidRootPart and Current_Health > 0 then
                local Dimensions = VisualKit:Get_Bounding_Vectors(HumanoidRootPart)
                local HRP_Position, On_Screen = Camera:WorldToViewportPoint(HumanoidRootPart.Position)
                local Stud_Distance, Meter_Distance = math.floor(HRP_Position.Z + 0.5), math.floor(HRP_Position.Z / 3.5714285714 + 0.5)

                self.Components.DisplayedHealth = Lerp(self.Components.DisplayedHealth, Current_Health, 0.1)

                local Y_Minimal, Y_Maximal = Camera.ViewportSize.X, 0
                local X_Minimal, X_Maximal = Camera.ViewportSize.X, 0

                for _, CF in pairs(Dimensions) do
                    local Vector = Camera:WorldToViewportPoint(CF.Position)
                    local X, Y = Vector.X, Vector.Y
                    if X < X_Minimal then 
                        X_Minimal = X
                    end
                    if X > X_Maximal then 
                        X_Maximal = X
                    end
                    if Y < Y_Minimal then 
                        Y_Minimal = Y
                    end
                    if Y > Y_Maximal then
                        Y_Maximal = Y
                    end
                end

                local Box_Size = VisualKit:Round_V2(Vector2.new(X_Minimal - X_Maximal, Y_Minimal - Y_Maximal))
                local Box_Position = VisualKit:Round_V2(Vector2.new(X_Maximal + Box_Size.X / X_Minimal, Y_Maximal + Box_Size.Y / Y_Minimal))
                local Good = false

                if ESP.Settings.Team_Check then
                    if ESP:Get_Team(self.Player) ~= ESP:Get_Team(LocalPlayer) then
                        Good = true
                    end
                else
                    Good = true
                end

                if ESP.Settings.Enabled and On_Screen and Meter_Distance < ESP.Settings.Maximal_Distance and Good then

                    local tool_name, tool_icon = ESP:Get_Tool(self.Player,WeaponIcon)

                    
                     if not self.Components.last_tool_icon then
                        self.Components.last_tool_icon = nil
                    end

                      if tool_icon ~= self.Components.last_tool_icon then
                            self.Components.last_tool_icon = tool_icon
                            WeaponIcon.Data = tool_icon
                        end
                    
                    local Highlight_Settings = ESP.Settings.Highlight
                    local Is_Highlighted = Highlight_Settings.Enabled and Highlight_Settings.Target == Character or false
                    local Highlight_Color = Highlight_Settings.Color

                    -- Offsets
                    local Top_Offset = 3
                    local Bottom_Offset = Y_Maximal + 2
                    local Left_Offset = 0
                    local Right_Offset = 0

                    -- Box
                    local Box_Settings = ESP.Settings.Box
                    Box.Size = Box_Size
                    Box.Position = Box_Position
                    Box.Color = Is_Highlighted and Highlight_Color or Box_Settings.Color
                    Box.Transparency = VisualKit:Drawing_Transparency(Box_Settings.Transparency)
                    Box.Visible = Box_Settings.Enabled

                    local Box_Outline_Settings = ESP.Settings.Box_Outline
                    Box_Outline.Size = Box_Size
                    Box_Outline.Position = Box_Position
                    Box_Outline.Color = Box_Outline_Settings.Color
                    Box_Outline.Thickness = Box_Outline_Settings.Outline_Size + 2
                    Box_Outline.Transparency = VisualKit:Drawing_Transparency(Box_Outline_Settings.Transparency)
                    Box_Outline.Visible = Box_Settings.Enabled and Box_Outline_Settings.Enabled or false

                    local Image_Settings = ESP.Settings.Image
                    local Image_Enabled = Image_Settings.Enabled
                    if Image_Enabled then
                        Image.Size = -Box_Size
                        Image.Position = Box_Position + Box_Size
                    end
                    Image.Visible = Image_Enabled

                    -- Healthbar

                    local Health_Percent = self.Components.DisplayedHealth / Health_Maximum
                    
                    local Health_Top_Size_Outline = Vector2.new(Box_Size.X - 4, 3)
                    local Health_Top_Pos_Outline = Box_Position + Vector2.new(2, Box_Size.Y - 6)
                    local Health_Top_Size_Fill = Vector2.new((Health_Percent * Health_Top_Size_Outline.X) + 2, 1)
                    local Health_Top_Pos_Fill = Health_Top_Pos_Outline + Vector2.new(1 + -(Health_Top_Size_Fill.X - Health_Top_Size_Outline.X),1);

                    local Health_Left_Size_Outline = Vector2.new(3, Box_Size.Y - 4)
                    local Health_Left_Pos_Outline = Vector2.new(X_Maximal + Box_Size.X - 6, Box_Position.Y + 2)
                    local Health_Left_Size_Fill = Vector2.new(1, (Health_Percent * Health_Left_Size_Outline.Y) + 2)
                    local Health_Left_Pos_Fill = Health_Left_Pos_Outline + Vector2.new(1,-1 + -(Health_Left_Size_Fill.Y - Health_Left_Size_Fill.Y));

                    local Healthbar_Settings = ESP.Settings.Healthbar
                    local Healthbar_Enabled = Healthbar_Settings.Enabled
                    local Healthbar_Position = Healthbar_Settings.Position

                    local Health_Lerp_Color = LerpColor(Color3.new(1, 0, 0), Color3.new(0, 1, 0), Health_Percent)

                    if Healthbar_Enabled then
                        if Healthbar_Position == "Left" then
                            Healthbar.Size = Health_Left_Size_Fill;
                            Healthbar.Position = Health_Left_Pos_Fill;
                            Healthbar_Outline.Size = Health_Left_Size_Outline;
                            Healthbar_Outline.Position = Health_Left_Pos_Outline;  
       
                        elseif Healthbar_Position == "Right" then
                            Healthbar.Size = Health_Left_Size_Fill;
                            Healthbar.Position = Vector2.new(X_Maximal + Box_Size.X + 4, Box_Position.Y + 1) - Vector2.new(Box_Size.X, 0)
                            Healthbar_Outline.Size = Health_Left_Size_Outline
                            Healthbar_Outline.Position = Vector2.new(X_Maximal + Box_Size.X + 3, Box_Position.Y + 2) - Vector2.new(Box_Size.X, 0)
                        elseif Healthbar_Position == "Top" then
                            Healthbar.Size = Health_Top_Size_Fill;
                            Healthbar.Position = Health_Top_Pos_Fill;
                            Healthbar_Outline.Size = Health_Top_Size_Outline;
                            Healthbar_Outline.Position = Health_Top_Pos_Outline;
                            Top_Offset = Top_Offset + 6
                        elseif Healthbar_Position == "Bottom" then
                            Healthbar.Size = Health_Top_Size_Fill
                            Healthbar.Position = Health_Top_Pos_Fill - Vector2.new(0, Box_Size.Y - 9)
                            Healthbar_Outline.Size = Health_Top_Size_Outline;
                            Healthbar_Outline.Position = Health_Top_Pos_Outline - Vector2.new(0, Box_Size.Y - 9)
                            Bottom_Offset = Bottom_Offset + 6
                        end
                        Healthbar.Color = Health_Lerp_Color
                    end
                    Healthbar.Visible = Healthbar_Enabled
                    Healthbar_Outline.Visible = Healthbar_Enabled
                    
                    -- Name
                    local Name_Settings = ESP.Settings.Name
                    local Name_Position = Name_Settings.Position
                    if Name_Position == "Top" and Name_Settings.Enabled then
                        Name.Position = Vector2.new(X_Maximal + Box_Size.X / 2, Box_Position.Y) - Vector2.new(0, Name.TextBounds.Y - Box_Size.Y + Top_Offset) 
                        Top_Offset = Top_Offset + 10
                    elseif Name_Position == "Bottom" and Name_Settings.Enabled then
                        Name.Position = Vector2.new(Box_Size.X / 2 + Box_Position.X, Bottom_Offset) 
                        Bottom_Offset = Bottom_Offset + 12
                    elseif Name_Position == "Left" then
                        if Healthbar_Position == "Left" and Name_Settings.Enabled then
                            Name.Position = Health_Left_Pos_Outline - Vector2.new(Name.TextBounds.X/2 - 2 + 4, -(100 * Health_Left_Size_Outline.Y / 100) + 2 - Left_Offset)
                        else
                            Name.Position = Health_Left_Pos_Outline - Vector2.new(Name.TextBounds.X/2 - 2, -(100 * Health_Left_Size_Outline.Y / 100) + 2 - Left_Offset)
                        end
                        Left_Offset = Left_Offset + 10
                    elseif Name_Position == "Right" and Name_Settings.Enabled then
                        if Healthbar_Position == "Right" then
                            Name.Position = Vector2.new(X_Maximal + Box_Size.X + 4 + 4 + Name.TextBounds.X / 2, Box_Position.Y + 2) - Vector2.new(Box_Size.X, -(100 * Health_Left_Size_Outline.Y / 100) + 2 - Right_Offset)
                        else
                            Name.Position = Vector2.new(X_Maximal + Box_Size.X + 3 + Name.TextBounds.X / 2, Box_Position.Y + 2) - Vector2.new(Box_Size.X, -(100 * Health_Left_Size_Outline.Y / 100) + 2 - Right_Offset)
                        end
                        Right_Offset = Right_Offset + 10
                    end
                    Name.Color = Is_Highlighted and Highlight_Color or Name_Settings.Color
                    Name.OutlineColor = Name_Settings.OutlineColor
                    Name.Transparency = VisualKit:Drawing_Transparency(Name_Settings.Transparency)
                    Name.Visible = Name_Settings.Enabled
                    NameBold.Color = Is_Highlighted and Highlight_Color or Name_Settings.Color
                    NameBold.OutlineColor = Name_Settings.OutlineColor
                    NameBold.Transparency = VisualKit:Drawing_Transparency(Name_Settings.Transparency)
                    NameBold.Position = Name.Position + Vector2.new(1, 0)
                    NameBold.Visible = Name.Visible and ESP.Settings.Bold_Text

                    -- Distance
                    local Distance_Settings = ESP.Settings.Distance
                    local Distance_Position = Distance_Settings.Position
                    if Distance_Position == "Top" and Distance_Settings.Enabled then 
                        Distance.Position = Vector2.new(X_Maximal + Box_Size.X / 2, Box_Position.Y) - Vector2.new(0, Distance.TextBounds.Y - Box_Size.Y + Top_Offset) 
                        Top_Offset = Top_Offset + 10
                    elseif Distance_Position == "Bottom" and Distance_Settings.Enabled then
                        Distance.Position = Vector2.new(Box_Size.X / 2 + Box_Position.X, Bottom_Offset) 
                        Bottom_Offset = Bottom_Offset + 12
                    elseif Distance_Position == "Left" and Distance_Settings.Enabled then
                        if Healthbar_Position == "Left" then
                            Distance.Position = Health_Left_Pos_Outline - Vector2.new(Distance.TextBounds.X/2 - 2 + 4, -(100 * Health_Left_Size_Outline.Y / 100) + 2 - Left_Offset)
                        else
                            Distance.Position = Health_Left_Pos_Outline - Vector2.new(Distance.TextBounds.X/2 - 2, -(100 * Health_Left_Size_Outline.Y / 100) + 2 - Left_Offset)
                        end
                        Left_Offset = Left_Offset + 10
                    elseif Distance_Position == "Right" and Distance_Settings.Enabled then 
                        if Healthbar_Position == "Right" then
                            Distance.Position = Vector2.new(X_Maximal + Box_Size.X + 4 + 4 + Distance.TextBounds.X / 2, Box_Position.Y + 2) - Vector2.new(Box_Size.X, -(100 * Health_Left_Size_Outline.Y / 100) + 2 - Right_Offset)
                        else
                            Distance.Position = Vector2.new(X_Maximal + Box_Size.X + 3 + Distance.TextBounds.X / 2, Box_Position.Y + 2) - Vector2.new(Box_Size.X, -(100 * Health_Left_Size_Outline.Y / 100) + 2 - Right_Offset)
                        end
                        Right_Offset = Right_Offset + 10
                    end
                    Distance.Text = Meter_Distance.."m"
                    Distance.Color = Is_Highlighted and Highlight_Color or Distance_Settings.Color
                    Distance.OutlineColor = Distance_Settings.OutlineColor
                    Distance.Transparency = VisualKit:Drawing_Transparency(Distance_Settings.Transparency)
                    Distance.Visible = Distance_Settings.Enabled
                    DistanceBold.Text = Meter_Distance.."m"
                    DistanceBold.Color = Is_Highlighted and Highlight_Color or Distance_Settings.Color
                    DistanceBold.OutlineColor = Distance_Settings.OutlineColor
                    DistanceBold.Transparency = VisualKit:Drawing_Transparency(Distance_Settings.Transparency)
                    DistanceBold.Position = Distance.Position + Vector2.new(1, 0)
                    DistanceBold.Visible = Distance.Visible and ESP.Settings.Bold_Text

                    -- Tool
                    local Tool_Settings = ESP.Settings.Tool
                    local Tool_Position = Tool_Settings.Position
                    if Tool_Position == "Top" and Tool_Settings.Enabled then 
                        Tool.Position = Vector2.new(X_Maximal + Box_Size.X / 2, Box_Position.Y) - Vector2.new(0, Tool.TextBounds.Y - Box_Size.Y + Top_Offset) 
                        Top_Offset = Top_Offset + 10
                    elseif Tool_Position == "Bottom" and Tool_Settings.Enabled then
                        Tool.Position = Vector2.new(Box_Size.X / 2 + Box_Position.X, Bottom_Offset) 
                        Bottom_Offset = Bottom_Offset + 12
                    elseif Tool_Position == "Left" and Tool_Settings.Enabled then
                        if Healthbar_Position == "Left" then
                            Tool.Position = Health_Left_Pos_Outline - Vector2.new(Tool.TextBounds.X/2 - 2 + 4, -(100 * Health_Left_Size_Outline.Y / 100) + 2 - Left_Offset)
                        else
                            Tool.Position = Health_Left_Pos_Outline - Vector2.new(Tool.TextBounds.X/2 - 2, -(100 * Health_Left_Size_Outline.Y / 100) + 2 - Left_Offset)
                        end
                        Left_Offset = Left_Offset + 10
                    elseif Tool_Position == "Right" and Tool_Settings.Enabled then
                        if Healthbar_Position == "Right" then
                            Tool.Position = Vector2.new(X_Maximal + Box_Size.X + 4 + 4 + Tool.TextBounds.X / 2, Box_Position.Y + 2) - Vector2.new(Box_Size.X, -(100 * Health_Left_Size_Outline.Y / 100) + 2 - Right_Offset)
                        else
                            Tool.Position = Vector2.new(X_Maximal + Box_Size.X + 3 + Tool.TextBounds.X / 2, Box_Position.Y + 2) - Vector2.new(Box_Size.X, -(100 * Health_Left_Size_Outline.Y / 100) + 2 - Right_Offset)
                        end
                        Right_Offset = Right_Offset + 10
                    end
                    Tool.Text = tool_name
                    Tool.Color = Is_Highlighted and Highlight_Color or Tool_Settings.Color
                    Tool.OutlineColor = Tool_Settings.OutlineColor
                    Tool.Transparency = VisualKit:Drawing_Transparency(Tool_Settings.Transparency)
                    Tool.Visible = Tool_Settings.Enabled
                    ToolBold.Text = tool_name
                    ToolBold.Color = Is_Highlighted and Highlight_Color or Tool_Settings.Color
                    ToolBold.OutlineColor = Tool_Settings.OutlineColor
                    ToolBold.Transparency = VisualKit:Drawing_Transparency(Tool_Settings.Transparency)
                    ToolBold.Position = Tool.Position + Vector2.new(1, 0)
                    ToolBold.Visible = Tool.Visible and ESP.Settings.Bold_Text
          
                    -- Health
                    local Health_Settings = ESP.Settings.Health
                    local Health_Position = Health_Settings.Position
                    local Health_Enabled = Health_Settings.Enabled
                    
                    if Health_Position == "Left" and Health_Enabled then
                        if Healthbar_Position == "Left" then
                            Health.Position = Healthbar.Position + Vector2.new(-9, Healthbar.Size.Y - Health.TextBounds.Y / 2)
                            Left_Offset = Left_Offset + 15
                        end
                   
                    end
                    
                    Health.Text = tostring(math.floor(Current_Health + 0.5))
                    Health.Color = Health_Lerp_Color
                    Health.OutlineColor = Health_Settings.OutlineColor
                    Health.Transparency = VisualKit:Drawing_Transparency(Health_Settings.Transparency)
                    Health.Visible = Health_Settings.Enabled
                    HealthBold.Text = tostring(math.floor(Current_Health + 0.5))
                    HealthBold.Color = Health_Lerp_Color
                    HealthBold.OutlineColor = Health_Settings.OutlineColor
                    HealthBold.Transparency = VisualKit:Drawing_Transparency(Health_Settings.Transparency)
                    HealthBold.Position = Health.Position + Vector2.new(1, 0)
                    HealthBold.Visible = Health.Visible and ESP.Settings.Bold_Text

                    -- WeaponIcon
                    local WeaponIcon_Settings = ESP.Settings.WeaponIcon
                    local WeaponIcon_Position = WeaponIcon_Settings.Position
                    if WeaponIcon_Position == "Top" and WeaponIcon_Settings.Enabled then 
                        WeaponIcon.Position = Vector2.new((Box_Size.X-40)/2 + Box_Position.X, Top_Offset) 
                        Top_Offset = Top_Offset + 10
                    elseif WeaponIcon_Position == "Bottom" and WeaponIcon_Settings.Enabled then
                        WeaponIcon.Position = Vector2.new((Box_Size.X-40)/2 + Box_Position.X, Bottom_Offset) 
                        Bottom_Offset = Bottom_Offset + 24
                    end
                    WeaponIcon.Visible = WeaponIcon_Settings.Enabled
                    WeaponIcon.Size = Vector2.new(35,35)
                
                    -- Skeleton

                    for partName, parts in pairs(ESP.bodyjoint) do
                        local part1, part2 = Character:FindFirstChild(parts[1]), Character:FindFirstChild(parts[2])
                        if part1 and part2 then
                            local pos1, vis1 = Camera:WorldToViewportPoint(part1.Position)
                            local pos2, vis2 = Camera:WorldToViewportPoint(part2.Position)
                
                            if vis1 and vis2 then
                                if ESP.Settings.Skeleton.Outline then
                                self.Components[partName .. "Outline"].Visible = true
                                self.Components[partName .. "Outline"].From = Vector2.new(pos1.X, pos1.Y)
                                self.Components[partName .. "Outline"].To = Vector2.new(pos2.X, pos2.Y)
                                else
                                self.Components[partName .. "Outline"].Visible = false
                                 end

                                if ESP.Settings.Skeleton.Enabled then
                                self.Components[partName].Visible = true
                                self.Components[partName].From = Vector2.new(pos1.X, pos1.Y)
                                self.Components[partName].To = Vector2.new(pos2.X, pos2.Y)
                                else
                                self.Components[partName].Visible = false
                                end
                            else
                                self.Components[partName .. "Outline"].Visible = false
                                self.Components[partName].Visible = false
                            end
                        else
                            self.Components[partName .. "Outline"].Visible = false
                            self.Components[partName].Visible = false
                        end
                    end
                    
                else
                    Box.Visible = false
                    Box_Outline.Visible = false
                    Healthbar.Visible = false
                    Healthbar_Outline.Visible = false
                    Name.Visible = false
                    NameBold.Visible = false
                    Distance.Visible = false
                    DistanceBold.Visible = false
                    Tool.Visible = false
                    ToolBold.Visible = false
                    WeaponIcon.Visible = false
                    Health.Visible = false
                    HealthBold.Visible = false
                    Image.Visible = false
                    for _, partName in ipairs(ESP.SkelParts) do
        
                        self.Components[partName .. "Outline"].Visible = false
                
                        self.Components[partName].Visible = false
                
                    end
                    return
                end
            else
                Box.Visible = false
                Box_Outline.Visible = false
                Healthbar.Visible = false
                Healthbar_Outline.Visible = false
                Name.Visible = false
                NameBold.Visible = false
                Distance.Visible = false
                DistanceBold.Visible = false
                Tool.Visible = false
                ToolBold.Visible = false
                WeaponIcon.Visible = false
                Health.Visible = false
                HealthBold.Visible = false
                Image.Visible = false
                  for _, partName in ipairs(ESP.SkelParts) do
    
                    self.Components[partName .. "Outline"].Visible = false
            
                    self.Components[partName].Visible = false
            
                end
                return
            end
        else
            Box.Visible = false
            Box_Outline.Visible = false
            Healthbar.Visible = false
            Healthbar_Outline.Visible = false
            Name.Visible = false
            NameBold.Visible = false
            Distance.Visible = false
            DistanceBold.Visible = false
            Tool.Visible = false
            ToolBold.Visible = false
            WeaponIcon.Visible = false
            Health.Visible = false
            HealthBold.Visible = false
            Image.Visible = false
              for _, partName in ipairs(ESP.SkelParts) do
    
                self.Components[partName .. "Outline"].Visible = false
            
                self.Components[partName].Visible = false
            
            end
            return
        end
    end
end
local Object_Metatable = {}
do  -- Object Metatable
    Object_Metatable.__index = Object_Metatable
    function Object_Metatable:Destroy()
        for Index, Component in pairs(self.Components) do
            Component.Visible = false
            Component:Remove()
            self.Components[Index] = nil
        end
        ESP.Objects[self.Object] = nil
    end
    function Object_Metatable:Update()
        local Name = self.Components.Name
        local Addition = self.Components.Addition

        if not ESP.Settings.Objects_Enabled then
            Name.Visible = false
            Addition.Visible = false
            return
        end

        local Vector, On_Screen = Camera:WorldToViewportPoint(self.PrimaryPart.Position + Vector3.new(0, 1, 0))
        local iconVector = Vector2.new(Vector.X-15,Vector.Y)
        
        local Meter_Distance = math.floor(Vector.Z / 3.5714285714 + 0.5)

        if On_Screen and Meter_Distance < ESP.Settings.Object_Maximal_Distance and Name then
            -- Name
            Name.Text = self.Name
            Name.Position = VisualKit:V3_To_V2(Vector - Vector3.new(0, -24, 0))
            Name.Visible = true

            if self.Components.Icon then
                self.Components.Icon.Position = VisualKit:V3_To_V2(iconVector)
                self.Components.Icon.Visible = true
            end
            
            -- Addition
            if self.Addition.Text ~= "" then
                Addition.Position = Name.Position + Vector2.new(0, Name.TextBounds.Y)
                Addition.Visible = true
            else
                Addition.Visible = false
            end
        else
            if not Name then return end
            Name.Visible = false
            Addition.Visible = false
            return
        end
    end
end
do -- ESP Functions
    function ESP:Player(Instance, Data)
        if Instance == nil then
        end
        if Data == nil or type(Data) ~= "table" then
            Data = {
                Player = Instance
            }
        end
        local Object = setmetatable({
            Player = Data.Player or Data.player or Data.Plr or Data.plr or Data.Ply or Data.ply or Instance,
            Components = {},
            Type = "Player"
        }, Player_Metatable)
        if self:GetObject(Instance) then
            self:GetObject(Instance):Destroy()
        end
        local Components = Object.Components
        Components.Box = VisualKit:Draw("Square", {Thickness = 1, ZIndex = 2})
        Components.Box_Outline = VisualKit:Draw("Square", {Thickness = 3, ZIndex = 1})
        Components.Healthbar = VisualKit:Draw("Square", {Thickness = 1, ZIndex = 2, Filled = true})
        Components.Healthbar_Outline = VisualKit:Draw("Square", {Thickness = 3, ZIndex = 1, Filled = true})
        Components.Name = VisualKit:Draw("Text", {Text = Instance.Name, Font = Drawing.Fonts.System, Size = 13, Outline = true, Center = true})
        Components.NameBold = VisualKit:Draw("Text", {Text = Instance.Name, Font = Drawing.Fonts.System, Size = 13, Center = true})
        Components.Distance = VisualKit:Draw("Text", {Font = Drawing.Fonts.System, Size = 13, Outline = true, Center = true})
        Components.DistanceBold = VisualKit:Draw("Text", {Font = Drawing.Fonts.System, Size = 13, Center = true})
        Components.Tool = VisualKit:Draw("Text", {Font = Drawing.Fonts.System, Size = 13, Outline = true, Center = true})
        Components.ToolBold = VisualKit:Draw("Text", {Font = Drawing.Fonts.System, Size = 13, Center = true})
        Components.Health = VisualKit:Draw("Text", {Font = Drawing.Fonts.System, Size = 13, Outline = true, Center = true})
        Components.HealthBold = VisualKit:Draw("Text", {Font = Drawing.Fonts.System, Size = 13, Center = true})
        Components.Image = VisualKit:Draw("Image", {Data = self.Settings.Image.Raw})
        Components.WeaponIcon = VisualKit:Draw("Image", {Data = Images["Hands"]})

        Components.DisplayedHealth = 69;
        
        for _, partName in ipairs(ESP.SkelParts) do
        
        Components[partName .. "Outline"] = VisualKit:Draw("Line", {Visible = false,Thickness = 3,Transparency = 1,Color = Color3.new(0, 0, 0)})

        Components[partName] = VisualKit:Draw("Line", {Visible = false,Thickness = 2,Transparency = 1,Color = Color3.new(1, 1, 1)})

        end
        
        self.Objects[Instance] = Object
        return Object
    end
    function ESP:Object(Instance, Data)
        if Data == nil or type(Data) ~= "table" then
            return warn("error: function ESP.Object argument #2 expected table, got nil")
        end
        local Addition = Data.Addition or Data.addition or Data.add or Data.Add or {}
        if Addition.Text == nil then
            Addition.Text = Addition.text or ""
        end
        if Addition.Color == nil then
            Addition.Color = Addition.Color or Addition.color or Addition.col or Addition.Col or Color3.new(1, 1, 1)
        end
        local obj = Data.Object or Data.object or Data.Obj or Data.obj or Instance
        local col = Data.Color or Data.color or Data.col or Data.Col or Color3.new(1, 1, 1)
        local out = Data.outline or Data.Outline or false
        local trans = Data.trans or Data.Trans or Data.Transparency or Data.transparency or Data.Alpha or Data.alpha or 1
        local iconUrl = Images[Instance.Name] or Images["Hands"] -- Get icon or default to "Hands"

        local Object = setmetatable({
            Object = obj,
            PrimaryPart = Data.PrimaryPart or Data.primarypart or Data.pp or Data.PP or Data.primpart or Data.PrimPart or Data.PPart or Data.ppart or Data.pPart or Data.Ppart or obj:IsA("Model") and obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart") or obj:IsA("BasePart") and obj or nil,
            Addition = Addition,
            Components = {},
            Type = Data.Type,
            Name = (Data.Name ~= nil and Data.Name) or Instance.Name
        }, Object_Metatable)
        if Object.PrimaryPart == nil then
            return
        end
        if self:GetObject(Instance) then
            self:GetObject(Instance):Destroy()
        end
        local Components = Object.Components
        Components.Name = VisualKit:Draw("Text", {Text = Object.Name, Color = col, Font = Drawing.Fonts.System, Size = 13, Outline = out, Center = true, Transparency = trans})
        Components.Addition = VisualKit:Draw("Text", {Text = Object.Addition.Text, Color = Object.Addition.Color, Font = Drawing.Fonts.System, Size = 13, Outline = out, Center = true, Transparency = trans})
        if iconUrl ~= Images["Hands"] then
        Components.Icon = VisualKit:Draw("Image", {Data = game:HttpGet(iconUrl), Size = Vector2.new(30, 30)}) -- Icon component
        else
        Components.Icon = VisualKit:Draw("Image", {Data = nil, Size = Vector2.new(30, 30)}) -- Icon component
        end
        self.Objects[Instance] = Object
        return Object
    end
    
end

-- China Hat
for i = 1, 30 do
    ESP.China_Hat[i] = {VisualKit:Draw('Line', {Visible = false}), VisualKit:Draw('Triangle', {Visible = false})}
    ESP.China_Hat[i][1].ZIndex = 2;
    ESP.China_Hat[i][1].Thickness = 2;
    ESP.China_Hat[i][2].ZIndex = 1;
    ESP.China_Hat[i][2].Filled = true;
end

-- Render Connection
local Connection = RunService.RenderStepped:Connect(function()
    -- Object Updating
    for i, Object in pairs(ESP.Objects) do
        Object:Update()
    end

    -- China Hat
    local China_Hat_Settings = ESP.Settings.China_Hat
    if ESP.Settings.China_Hat.Enabled then
        local China_Hat = ESP.China_Hat
        for i = 1, #ESP.China_Hat do
            local Line, Triangle = China_Hat[i][1], China_Hat[i][2];
            if LocalPlayer.Character ~= nil and LocalPlayer.Character:FindFirstChild('Head') and LocalPlayer.Character.Humanoid.Health > 0 then
                local Position = LocalPlayer.Character.Head.Position + Vector3.new(0, China_Hat_Settings.Offset, 0);
                local Last, Next = (i / 30) * math.pi*2, ((i + 1) / 30) * math.pi*2;
                local lastScreen, onScreenLast = Camera:WorldToViewportPoint(Position + (Vector3.new(math.cos(Last), 0, math.sin(Last)) * China_Hat_Settings.Radius));
                local nextScreen, onScreenNext = Camera:WorldToViewportPoint(Position + (Vector3.new(math.cos(Next), 0, math.sin(Next)) * China_Hat_Settings.Radius));
                local topScreen, onScreenTop = Camera:WorldToViewportPoint(Position + Vector3.new(0, China_Hat_Settings.Height, 0));
                if not onScreenLast or not onScreenNext or not onScreenTop then
                    Line.Transparency = 0
                    Triangle.Transparency = 0
                    continue
                end
                Line.From = Vector2.new(lastScreen.X, lastScreen.Y);
                Line.To = Vector2.new(nextScreen.X, nextScreen.Y);
                Line.Color = China_Hat_Settings.Color
                Line.Transparency = VisualKit:Drawing_Transparency(China_Hat_Settings.Transparency)
                Triangle.PointA = Vector2.new(topScreen.X, topScreen.Y);
                Triangle.PointB = Line.From;
                Triangle.PointC = Line.To;
                Triangle.Color = China_Hat_Settings.Color
                Triangle.Transparency = VisualKit:Drawing_Transparency(China_Hat_Settings.Transparency)
            end
        end
    end
end)

return ESP, Connection, VisualKit
