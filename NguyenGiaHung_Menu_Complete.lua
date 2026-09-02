--==============================================================
-- NGUYỄN GIA HƯNG • COMPLETE CONTROL MENU
-- Roblox Studio LocalScript
-- Đặt tại: StarterPlayer > StarterPlayerScripts
--
-- Bản này hoàn thiện phần MENU + logic demo phía client.
-- Mua/Bán/Tái sinh/Nâng cấp không tự ý gọi Remote của game khác.
-- Khi dùng trong game của bạn, thay các hàm Server.* bằng RemoteEvent
-- của hệ thống server chính thức của game.
--==============================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--==============================================================
-- CONFIG
--==============================================================

local CFG = {
    Title = "NGUYỄN GIA HƯNG",
    Width = 760,
    Height = 480,
    Speed = 32,
    AimFov = 45,
    AimSmooth = 0.18,
    AutoInterval = 1,
}

--==============================================================
-- DEMO STATE
--==============================================================

local State = {
    Money = 2500,
    Level = 1,
    Rebirth = 0,
    Inventory = 0,

    Speed = false,
    ESP = false,
    AimAssist = false,

    AutoBuy = false,
    AutoSell = false,
    AutoRebirth = false,
    AutoUpgrade = false,

    Upgrades = {
        Money = 0,
        Cyber = 0,
        Defense = 0,
        Data = 0,
    }
}

--==============================================================
-- SERVER API PLACEHOLDER
--==============================================================

local Server = {}

function Server:Buy(itemName, amount)
    -- Nối RemoteEvent/RemoteFunction của GAME CỦA BẠN tại đây.
    State.Inventory += amount or 1
    State.Money = math.max(0, State.Money - 100 * (amount or 1))
end

function Server:Sell(itemName, amount)
    local n = math.min(State.Inventory, amount or 1)
    State.Inventory -= n
    State.Money += n * 150
end

function Server:SellAll()
    State.Money += State.Inventory * 150
    State.Inventory = 0
end

function Server:Rebirth()
    local cost = 5000 * (State.Rebirth + 1)
    if State.Money >= cost then
        State.Money = 0
        State.Level = 1
        State.Rebirth += 1
        State.Inventory = 0
    end
end

function Server:Upgrade(name, amount)
    local costPer = 250
    local count = amount == "MAX" and 999 or amount

    local key = ({
        ["💰 TIỀN"] = "Money",
        ["⚔️ TẤN CÔNG MẠNG"] = "Cyber",
        ["🛡️ BẢO VỆ"] = "Defense",
        ["📡 DỮ LIỆU"] = "Data",
    })[name]

    if not key then return end

    if amount == "MAX" then
        count = math.floor(State.Money / costPer)
    end

    count = math.max(0, math.floor(count))
    local cost = count * costPer

    if State.Money >= cost and count > 0 then
        State.Money -= cost
        State.Upgrades[key] += count
    end
end

--==============================================================
-- HELPERS
--==============================================================

local function New(className, props, parent)
    local obj = Instance.new(className)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    obj.Parent = parent
    return obj
end

local function Corner(parent, radius)
    New("UICorner", {CornerRadius = UDim.new(0, radius)}, parent)
end

local function Stroke(parent, color, thickness, transparency)
    New("UIStroke", {
        Color = color,
        Thickness = thickness or 1,
        Transparency = transparency or 0
    }, parent)
end

local function Tween(obj, props, duration)
    TweenService:Create(
        obj,
        TweenInfo.new(duration or .15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        props
    ):Play()
end

local function FormatNumber(n)
    n = tonumber(n) or 0
    if n >= 1e9 then return string.format("%.1fB", n / 1e9) end
    if n >= 1e6 then return string.format("%.1fM", n / 1e6) end
    if n >= 1e3 then return string.format("%.1fK", n / 1e3) end
    return tostring(math.floor(n))
end

--==============================================================
-- COLORS
--==============================================================

local C = {
    Background = Color3.fromRGB(18, 20, 26),
    Sidebar = Color3.fromRGB(24, 27, 34),
    Panel = Color3.fromRGB(30, 34, 43),
    Panel2 = Color3.fromRGB(40, 44, 55),
    Hover = Color3.fromRGB(51, 56, 69),
    Text = Color3.fromRGB(245, 246, 250),
    Muted = Color3.fromRGB(164, 169, 183),
    Blue = Color3.fromRGB(48, 143, 235),
    Green = Color3.fromRGB(52, 190, 92),
    Red = Color3.fromRGB(224, 66, 76),
    Purple = Color3.fromRGB(145, 76, 220),
    Orange = Color3.fromRGB(236, 148, 47),
}

--==============================================================
-- GUI
--==============================================================

local old = playerGui:FindFirstChild("NguyenGiaHungMenu")
if old then old:Destroy() end

local gui = New("ScreenGui", {
    Name = "NguyenGiaHungMenu",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, playerGui)

local main = New("Frame", {
    Name = "Main",
    Size = UDim2.fromOffset(CFG.Width, CFG.Height),
    Position = UDim2.new(.5, -CFG.Width/2, .5, -CFG.Height/2),
    BackgroundColor3 = C.Background,
    BorderSizePixel = 0,
    ClipsDescendants = true,
}, gui)
Corner(main, 15)
Stroke(main, Color3.fromRGB(70, 76, 91), 1)

local uiScale = New("UIScale", {Scale = 1}, main)

local function UpdateScale()
    local camera = workspace.CurrentCamera
    if not camera then return end
    local vp = camera.ViewportSize
    uiScale.Scale = math.clamp(math.min(vp.X / (CFG.Width + 35), vp.Y / (CFG.Height + 35)), .58, 1)
end

UpdateScale()
if workspace.CurrentCamera then
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateScale)
end

--==============================================================
-- HEADER
--==============================================================

local header = New("Frame", {
    Size = UDim2.new(1, 0, 0, 62),
    BackgroundColor3 = C.Panel,
    BorderSizePixel = 0,
}, main)

local title = New("TextLabel", {
    Size = UDim2.new(1, -170, 0, 30),
    Position = UDim2.fromOffset(18, 7),
    BackgroundTransparency = 1,
    Text = CFG.Title,
    Font = Enum.Font.GothamBold,
    TextSize = 20,
    TextColor3 = C.Text,
    TextXAlignment = Enum.TextXAlignment.Left,
}, header)

local subtitle = New("TextLabel", {
    Size = UDim2.new(1, -170, 0, 20),
    Position = UDim2.fromOffset(18, 35),
    BackgroundTransparency = 1,
    Text = "CONTROL PANEL  •  READY",
    Font = Enum.Font.Gotham,
    TextSize = 10,
    TextColor3 = C.Muted,
    TextXAlignment = Enum.TextXAlignment.Left,
}, header)

local minBtn = New("TextButton", {
    Size = UDim2.fromOffset(38, 34),
    Position = UDim2.new(1, -88, 0, 14),
    BackgroundColor3 = C.Panel2,
    Text = "—",
    Font = Enum.Font.GothamBold,
    TextSize = 17,
    TextColor3 = C.Text,
    AutoButtonColor = false,
}, header)
Corner(minBtn, 8)

local closeBtn = New("TextButton", {
    Size = UDim2.fromOffset(38, 34),
    Position = UDim2.new(1, -44, 0, 14),
    BackgroundColor3 = C.Red,
    Text = "×",
    Font = Enum.Font.GothamBold,
    TextSize = 20,
    TextColor3 = C.Text,
    AutoButtonColor = false,
}, header)
Corner(closeBtn, 8)

--==============================================================
-- SIDEBAR + CONTENT
--==============================================================

local sidebar = New("Frame", {
    Size = UDim2.new(0, 178, 1, -62),
    Position = UDim2.fromOffset(0, 62),
    BackgroundColor3 = C.Sidebar,
    BorderSizePixel = 0,
}, main)

New("UIPadding", {
    PaddingTop = UDim.new(0, 12),
    PaddingBottom = UDim.new(0, 12),
    PaddingLeft = UDim.new(0, 11),
    PaddingRight = UDim.new(0, 11),
}, sidebar)

New("UIListLayout", {
    Padding = UDim.new(0, 7),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, sidebar)

local content = New("Frame", {
    Size = UDim2.new(1, -178, 1, -62),
    Position = UDim2.new(0, 178, 0, 62),
    BackgroundColor3 = C.Background,
    BorderSizePixel = 0,
}, main)

local pages = {}
local tabButtons = {}

local function CreatePage(name)
    local page = New("ScrollingFrame", {
        Name = name,
        Size = UDim2.new(1, -20, 1, -18),
        Position = UDim2.fromOffset(10, 9),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(),
        Visible = false,
    }, content)

    New("UIListLayout", {
        Padding = UDim.new(0, 9),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, page)

    pages[name] = page
    return page
end

local function CreateTab(text, pageName, accent)
    local b = New("TextButton", {
        Size = UDim2.new(1, 0, 0, 41),
        BackgroundColor3 = C.Panel2,
        Text = text,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = C.Text,
        AutoButtonColor = false,
    }, sidebar)
    Corner(b, 9)
    tabButtons[pageName] = b

    b.MouseEnter:Connect(function()
        if not pages[pageName].Visible then
            Tween(b, {BackgroundColor3 = C.Hover}, .1)
        end
    end)

    b.MouseLeave:Connect(function()
        if not pages[pageName].Visible then
            Tween(b, {BackgroundColor3 = C.Panel2}, .1)
        end
    end)

    b.MouseButton1Click:Connect(function()
        for n, p in pairs(pages) do
            p.Visible = (n == pageName)
        end
        for n, btn in pairs(tabButtons) do
            Tween(btn, {
                BackgroundColor3 = (n == pageName) and accent or C.Panel2
            }, .12)
        end
    end)

    return b
end

--==============================================================
-- UI HELPERS
--==============================================================

local function Section(parent, heading, desc)
    local box = New("Frame", {
        Size = UDim2.new(1, 0, 0, 67),
        BackgroundColor3 = C.Panel,
        BorderSizePixel = 0,
    }, parent)
    Corner(box, 10)
    Stroke(box, Color3.fromRGB(57, 62, 74), 1)

    New("TextLabel", {
        Size = UDim2.new(1, -20, 0, 27),
        Position = UDim2.fromOffset(10, 7),
        BackgroundTransparency = 1,
        Text = heading,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextColor3 = C.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, box)

    New("TextLabel", {
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.fromOffset(10, 36),
        BackgroundTransparency = 1,
        Text = desc or "",
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextColor3 = C.Muted,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, box)

    return box
end

local function Button(parent, text, color, callback, width)
    width = width or 110

    local b = New("TextButton", {
        Size = UDim2.fromOffset(width, 36),
        BackgroundColor3 = color,
        Text = text,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextColor3 = C.Text,
        AutoButtonColor = false,
    }, parent)
    Corner(b, 8)

    b.MouseEnter:Connect(function()
        Tween(b, {BackgroundColor3 = color:Lerp(Color3.new(1,1,1), .10)}, .1)
    end)

    b.MouseLeave:Connect(function()
        Tween(b, {BackgroundColor3 = color}, .1)
    end)

    b.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)

    return b
end

local function Toggle(parent, text, initial, callback)
    local row = New("Frame", {
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundColor3 = C.Panel,
        BorderSizePixel = 0,
    }, parent)
    Corner(row, 8)

    New("TextLabel", {
        Size = UDim2.new(1, -135, 1, 0),
        Position = UDim2.fromOffset(12, 0),
        BackgroundTransparency = 1,
        Text = text,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = C.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, row)

    local value = initial == true

    local b = New("TextButton", {
        Size = UDim2.fromOffset(96, 30),
        Position = UDim2.new(1, -108, .5, -15),
        BackgroundColor3 = value and C.Green or C.Panel2,
        Text = value and "BẬT" or "TẮT",
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        TextColor3 = C.Text,
        AutoButtonColor = false,
    }, row)
    Corner(b, 8)

    local function Set(v)
        value = v
        b.Text = v and "BẬT" or "TẮT"
        Tween(b, {BackgroundColor3 = v and C.Green or C.Panel2}, .12)
        if callback then callback(v) end
    end

    b.MouseButton1Click:Connect(function()
        Set(not value)
    end)

    return row, Set
end

local function Stat(parent, name, value, accent)
    local box = New("Frame", {
        BackgroundColor3 = C.Panel,
        BorderSizePixel = 0,
    }, parent)
    Corner(box, 9)
    Stroke(box, accent or C.Panel2, 1)

    New("TextLabel", {
        Size = UDim2.new(1, -18, 0, 19),
        Position = UDim2.fromOffset(9, 7),
        BackgroundTransparency = 1,
        Text = name,
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextColor3 = C.Muted,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, box)

    local val = New("TextLabel", {
        Size = UDim2.new(1, -18, 0, 29),
        Position = UDim2.fromOffset(9, 27),
        BackgroundTransparency = 1,
        Text = value,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextColor3 = C.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, box)

    return val
end

--==============================================================
-- PAGES
--==============================================================

local home = CreatePage("TRANG CHỦ")
local market = CreatePage("THỊ TRƯỜNG")
local sell = CreatePage("BÁN")
local rebirth = CreatePage("TÁI SINH")
local upgrade = CreatePage("NÂNG CẤP")
local settings = CreatePage("CÀI ĐẶT")

--==============================================================
-- HOME
--==============================================================

Section(home, "🏠 TRANG CHỦ", "Tổng quan người chơi và thao tác nhanh")

local statGrid = New("Frame", {
    Size = UDim2.new(1, 0, 0, 150),
    BackgroundTransparency = 1,
}, home)

New("UIGridLayout", {
    CellSize = UDim2.new(.485, 0, 0, 68),
    CellPadding = UDim2.new(.03, 0, 0, 8),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, statGrid)

local moneyLabel = Stat(statGrid, "💰 TIỀN", "$0", C.Green)
local levelLabel = Stat(statGrid, "⭐ LEVEL", "1", C.Blue)
local rebirthLabel = Stat(statGrid, "🔄 TÁI SINH", "0", C.Purple)
local inventoryLabel = Stat(statGrid, "🎒 KHO", "0", C.Orange)

Section(home, "⚡ THAO TÁC NHANH", "Bật/tắt các tính năng của menu")

Toggle(home, "⚡ SPEED", false, function(v)
    State.Speed = v
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = v and CFG.Speed or 16
    end
end)

--==============================================================
-- ESP - Highlight hợp lệ cho game Studio
--==============================================================

local espFolder = Instance.new("Folder")
espFolder.Name = "NGH_ESP"
espFolder.Parent = workspace

local function ClearESP()
    for _, obj in ipairs(espFolder:GetChildren()) do
        obj:Destroy()
    end
end

local function ApplyESP()
    ClearESP()
    if not State.ESP then return end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            local h = Instance.new("Highlight")
            h.Name = "PlayerESP_" .. plr.UserId
            h.Adornee = plr.Character
            h.FillColor = Color3.fromRGB(30, 210, 90)
            h.FillTransparency = .72
            h.OutlineColor = Color3.fromRGB(255, 255, 255)
            h.OutlineTransparency = 0
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            h.Parent = espFolder
        end
    end
end

Toggle(home, "👁 ESP", false, function(v)
    State.ESP = v
    ApplyESP()
end)

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        task.wait(.5)
        ApplyESP()
    end)
end)

for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= player then
        plr.CharacterAdded:Connect(function()
            task.wait(.5)
            ApplyESP()
        end)
    end
end

--==============================================================
-- AIM ASSIST
--==============================================================

local camera = workspace.CurrentCamera

local function GetClosestTarget()
    if not camera then return nil end

    local bestPart
    local bestAngle = math.rad(State.AimFov)

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            local head = plr.Character:FindFirstChild("Head")
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")

            if head and hum and hum.Health > 0 then
                local direction = (head.Position - camera.CFrame.Position).Unit
                local angle = math.acos(math.clamp(camera.CFrame.LookVector:Dot(direction), -1, 1))

                if angle < bestAngle then
                    bestAngle = angle
                    bestPart = head
                end
            end
        end
    end

    return bestPart
end

Toggle(home, "🎯 AIM ASSIST", false, function(v)
    State.AimAssist = v
end)

local aimLabel = New("TextLabel", {
    Size = UDim2.new(1, 0, 0, 28),
    BackgroundTransparency = 1,
    Text = "🎯 FOV: " .. CFG.AimFov .. "°",
    Font = Enum.Font.GothamBold,
    TextSize = 11,
    TextColor3 = C.Muted,
    TextXAlignment = Enum.TextXAlignment.Left,
}, home)

--==============================================================
-- AUTO SYSTEM TOGGLES
--==============================================================

Section(home, "🤖 TỰ ĐỘNG", "Các chế độ tự động dùng API Server của game bạn")

Toggle(home, "🛒 AUTO BUY", false, function(v)
    State.AutoBuy = v
end)

Toggle(home, "💰 AUTO SELL", false, function(v)
    State.AutoSell = v
end)

Toggle(home, "🔄 AUTO REBIRTH", false, function(v)
    State.AutoRebirth = v
end)

Toggle(home, "⬆️ AUTO UPGRADE", false, function(v)
    State.AutoUpgrade = v
end)

--==============================================================
-- MARKET
--==============================================================

Section(market, "🛒 THỊ TRƯỜNG", "Mua vật phẩm theo danh sách")

local items = {
    {"Máy tính xách tay cũ", "0.15/s", 25},
    {"Máy tính văn phòng", "0.3/s", 120},
    {"PC chơi game", "0.8/s", 650},
    {"Máy đào tiền điện tử", "2.5/s", 2000},
    {"Kết nối vệ tinh", "6.5 MB/s", 1300000},
    {"Máy phát dữ liệu", "17 MB/s", 5000000},
    {"Mảng anten quỹ đạo", "35 MB/s", 16000000},
}

for _, item in ipairs(items) do
    local card = New("Frame", {
        Size = UDim2.new(1, 0, 0, 68),
        BackgroundColor3 = C.Panel,
        BorderSizePixel = 0,
    }, market)
    Corner(card, 9)

    New("TextLabel", {
        Size = UDim2.new(1, -190, 0, 24),
        Position = UDim2.fromOffset(11, 7),
        BackgroundTransparency = 1,
        Text = item[1],
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = C.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, card)

    New("TextLabel", {
        Size = UDim2.new(1, -190, 0, 19),
        Position = UDim2.fromOffset(11, 34),
        BackgroundTransparency = 1,
        Text = "⚡ " .. item[2] .. "   •   Giá $" .. FormatNumber(item[3]),
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextColor3 = C.Muted,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, card)

    local b = Button(card, "MUA", C.Green, function()
        if State.Money >= item[3] then
            State.Money -= item[3]
            State.Inventory += 1
        end
    end, 88)
    b.Position = UDim2.new(1, -100, .5, -18)
end

--==============================================================
-- SELL
--==============================================================

Section(sell, "💰 BÁN", "Bán từng món hoặc bán toàn bộ")

local sellBox = New("Frame", {
    Size = UDim2.new(1, 0, 0, 65),
    BackgroundColor3 = C.Panel,
    BorderSizePixel = 0,
}, sell)
Corner(sellBox, 9)

New("TextLabel", {
    Size = UDim2.new(1, -160, 1, 0),
    Position = UDim2.fromOffset(12, 0),
    BackgroundTransparency = 1,
    Text = "Bán tất cả vật phẩm trong kho",
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    TextColor3 = C.Text,
    TextXAlignment = Enum.TextXAlignment.Left,
}, sellBox)

local sellAllBtn = Button(sellBox, "BÁN TẤT CẢ", C.Red, function()
    State.Money += State.Inventory * 150
    State.Inventory = 0
end, 120)
sellAllBtn.Position = UDim2.new(1, -132, .5, -18)

for _, item in ipairs(items) do
    local row = New("Frame", {
        Size = UDim2.new(1, 0, 0, 54),
        BackgroundColor3 = C.Panel,
        BorderSizePixel = 0,
    }, sell)
    Corner(row, 8)

    New("TextLabel", {
        Size = UDim2.new(1, -130, 1, 0),
        Position = UDim2.fromOffset(12, 0),
        BackgroundTransparency = 1,
        Text = item[1],
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextColor3 = C.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, row)

    local b = Button(row, "BÁN", C.Orange, function()
        if State.Inventory > 0 then
            Server:Sell(item[1], 1)
        end
    end, 82)
    b.Position = UDim2.new(1, -94, .5, -18)
end

--==============================================================
-- REBIRTH
--==============================================================

Section(rebirth, "🔄 TÁI SINH", "Yêu cầu tiền để thực hiện tái sinh")

local rbCard = New("Frame", {
    Size = UDim2.new(1, 0, 0, 175),
    BackgroundColor3 = C.Panel,
    BorderSizePixel = 0,
}, rebirth)
Corner(rbCard, 10)

local rbTitle = New("TextLabel", {
    Size = UDim2.new(1, -24, 0, 30),
    Position = UDim2.fromOffset(12, 12),
    BackgroundTransparency = 1,
    Text = "REBIRTH",
    Font = Enum.Font.GothamBold,
    TextSize = 21,
    TextColor3 = C.Text,
    TextXAlignment = Enum.TextXAlignment.Left,
}, rbCard)

local rbInfo = New("TextLabel", {
    Size = UDim2.new(1, -24, 0, 45),
    Position = UDim2.fromOffset(12, 48),
    BackgroundTransparency = 1,
    Text = "Chi phí hiện tại: $5,000",
    Font = Enum.Font.Gotham,
    TextSize = 12,
    TextColor3 = C.Muted,
    TextXAlignment = Enum.TextXAlignment.Left,
}, rbCard)

local rbDo = Button(rbCard, "🔄 REBIRTH", C.Purple, function()
    Server:Rebirth()
end, 150)
rbDo.Position = UDim2.fromOffset(12, 110)

--==============================================================
-- UPGRADE
--==============================================================

Section(upgrade, "⬆️ NÂNG CẤP", "4 nhóm nâng cấp — +1 / +10 / TỐI ĐA")

local upgradeNames = {
    {"💰 TIỀN", "Money"},
    {"⚔️ TẤN CÔNG MẠNG", "Cyber"},
    {"🛡️ BẢO VỆ", "Defense"},
    {"📡 DỮ LIỆU", "Data"},
}

for _, data in ipairs(upgradeNames) do
    local box = New("Frame", {
        Size = UDim2.new(1, 0, 0, 70),
        BackgroundColor3 = C.Panel,
        BorderSizePixel = 0,
    }, upgrade)
    Corner(box, 9)

    New("TextLabel", {
        Size = UDim2.new(1, -260, 1, 0),
        Position = UDim2.fromOffset(12, 0),
        BackgroundTransparency = 1,
        Text = data[1],
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = C.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, box)

    local b1 = Button(box, "+1", C.Blue, function()
        Server:Upgrade(data[1], 1)
    end, 60)
    b1.Position = UDim2.new(1, -220, .5, -18)

    local b10 = Button(box, "+10", C.Blue, function()
        Server:Upgrade(data[1], 10)
    end, 60)
    b10.Position = UDim2.new(1, -152, .5, -18)

    local bm = Button(box, "TỐI ĐA", C.Purple, function()
        Server:Upgrade(data[1], "MAX")
    end, 82)
    bm.Position = UDim2.new(1, -62, .5, -18)
end

--==============================================================
-- SETTINGS
--==============================================================

Section(settings, "⚙️ CÀI ĐẶT", "Tùy chỉnh menu")

Toggle(settings, "📌 Giữ menu sau khi respawn", true)
Toggle(settings, "✨ Hiệu ứng nút", true)
Toggle(settings, "📱 Tự điều chỉnh mobile", true)

local reset = New("Frame", {
    Size = UDim2.new(1, 0, 0, 58),
    BackgroundColor3 = C.Panel,
    BorderSizePixel = 0,
}, settings)
Corner(reset, 8)

New("TextLabel", {
    Size = UDim2.new(1, -150, 1, 0),
    Position = UDim2.fromOffset(12, 0),
    BackgroundTransparency = 1,
    Text = "Đặt lại dữ liệu DEMO",
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    TextColor3 = C.Text,
    TextXAlignment = Enum.TextXAlignment.Left,
}, reset)

local resetBtn = Button(reset, "RESET", C.Red, function()
    State.Money = 2500
    State.Level = 1
    State.Rebirth = 0
    State.Inventory = 0
    for k in pairs(State.Upgrades) do
        State.Upgrades[k] = 0
    end
end, 90)
resetBtn.Position = UDim2.new(1, -102, .5, -18)

--==============================================================
-- TABS
--==============================================================

CreateTab("🏠  TRANG CHỦ", "TRANG CHỦ", C.Green)
CreateTab("🛒  THỊ TRƯỜNG", "THỊ TRƯỜNG", C.Blue)
CreateTab("💰  BÁN", "BÁN", C.Red)
CreateTab("🔄  TÁI SINH", "TÁI SINH", C.Purple)
CreateTab("⬆️  NÂNG CẤP", "NÂNG CẤP", C.Orange)
CreateTab("⚙️  CÀI ĐẶT", "CÀI ĐẶT", C.Panel2)

pages["TRANG CHỦ"].Visible = true
tabButtons["TRANG CHỦ"].BackgroundColor3 = C.Green

--==============================================================
-- UPDATE LABELS
--==============================================================

local function UpdateStats()
    moneyLabel.Text = "$" .. FormatNumber(State.Money)
    levelLabel.Text = tostring(State.Level)
    rebirthLabel.Text = tostring(State.Rebirth)
    inventoryLabel.Text = tostring(State.Inventory)

    local cost = 5000 * (State.Rebirth + 1)
    rbInfo.Text = "Chi phí hiện tại: $" .. FormatNumber(cost)
end

--==============================================================
-- AUTO LOOP
--==============================================================

task.spawn(function()
    while gui.Parent do
        task.wait(CFG.AutoInterval)

        if State.AutoBuy then
            -- Demo: mua món rẻ nhất nếu đủ tiền.
            if State.Money >= items[1][3] then
                State.Money -= items[1][3]
                State.Inventory += 1
            end
        end

        if State.AutoSell and State.Inventory > 0 then
            Server:SellAll()
        end

        if State.AutoRebirth then
            Server:Rebirth()
        end

        if State.AutoUpgrade then
            Server:Upgrade("💰 TIỀN", 1)
        end

        UpdateStats()
    end
end)

--==============================================================
-- AIM LOOP
--==============================================================

RunService:BindToRenderStep(
    "NGH_AimAssist",
    Enum.RenderPriority.Camera.Value + 1,
    function()
        if not State.AimAssist then return end
        camera = workspace.CurrentCamera
        local target = GetClosestTarget()

        if target and camera then
            local targetCF = CFrame.lookAt(camera.CFrame.Position, target.Position)
            camera.CFrame = camera.CFrame:Lerp(targetCF, CFG.AimSmooth)
        end
    end
)

--==============================================================
-- DRAG / TOUCH
--==============================================================

local dragging = false
local dragStart
local startPosition

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = main.Position
    end
end)

header.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then return end

    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then

        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

--==============================================================
-- MINIMIZE / CLOSE
--==============================================================

local minimized = false

minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    sidebar.Visible = not minimized
    content.Visible = not minimized

    if minimized then
        Tween(main, {Size = UDim2.fromOffset(CFG.Width, 62)}, .2)
        minBtn.Text = "+"
    else
        Tween(main, {Size = UDim2.fromOffset(CFG.Width, CFG.Height)}, .2)
        minBtn.Text = "—"
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    gui.Enabled = false
end)

--==============================================================
-- RESPAWN
--==============================================================

player.CharacterAdded:Connect(function(character)
    task.wait(.25)

    local hum = character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = State.Speed and CFG.Speed or 16
    end

    task.wait(.5)
    ApplyESP()
end)

--==============================================================
-- CLEANUP
--==============================================================

gui.Destroying:Connect(function()
    pcall(function()
        RunService:UnbindFromRenderStep("NGH_AimAssist")
    end)

    if espFolder then
        espFolder:Destroy()
    end
end)

UpdateStats()
print("NGUYỄN GIA HƯNG • COMPLETE MENU LOADED")
