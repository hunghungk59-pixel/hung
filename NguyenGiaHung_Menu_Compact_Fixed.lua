-- NGUYỄN GIA HƯNG | MENU GỌN - ROBLOX STUDIO
-- LocalScript: StarterPlayer > StarterPlayerScripts
--
-- BẢN NÀY:
-- 1) Menu nhỏ gọn hơn.
-- 2) Không còn dùng Demo để chặn nút MUA/REBIRTH/UPGRADE.
-- 3) Có bảng RemoteConfig để nối đúng RemoteEvent/RemoteFunction của game.
--
-- QUAN TRỌNG:
-- Tên Remote và tham số của game bạn chưa được cung cấp nên không thể
-- đoán chính xác. Hãy điền đúng đường dẫn ở RemoteConfig bên dưới.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

--==================================================
-- REMOTE CONFIG
--==================================================
-- Ví dụ nếu game có:
-- ReplicatedStorage.Remotes.Buy
-- thì đặt:
-- Buy = {"Remotes", "Buy"}
--
-- Nếu dùng RemoteFunction thay RemoteEvent, code bên dưới cũng hỗ trợ.
local RemoteConfig = {
    Buy = nil,       -- {"Remotes", "Buy"}
    Sell = nil,      -- {"Remotes", "Sell"}
    SellAll = nil,   -- {"Remotes", "SellAll"}
    Rebirth = nil,   -- {"Remotes", "Rebirth"}
    Upgrade = nil,   -- {"Remotes", "Upgrade"}
}

local function getRemote(path)
    if type(path) ~= "table" or #path == 0 then
        return nil
    end

    local obj = ReplicatedStorage
    for _, name in ipairs(path) do
        obj = obj:FindFirstChild(name)
        if not obj then
            return nil
        end
    end

    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
        return obj
    end
    return nil
end

local function callRemote(key, ...)
    local remote = getRemote(RemoteConfig[key])

    if not remote then
        warn("[NGH MENU] Chưa cấu hình RemoteConfig." .. key)
        return false
    end

    local args = table.pack(...)

    local ok, result = pcall(function()
        if remote:IsA("RemoteEvent") then
            remote:FireServer(table.unpack(args, 1, args.n))
            return true
        else
            return remote:InvokeServer(table.unpack(args, 1, args.n))
        end
    end)

    if not ok then
        warn("[NGH MENU] " .. key .. " lỗi: " .. tostring(result))
        return false
    end

    return true, result
end

--==================================================
-- DATA
--==================================================
local Config = {
    WalkSpeed = 32,
    AimFov = 90,
    AimStrength = 0.18,
}

local State = {
    Speed = false,
    ESP = false,
    AimAssist = false,
    AutoBuy = false,
    AutoSell = false,
    AutoRebirth = false,
    AutoUpgrade = false,
}

local Items = {
    {"Máy tính xách tay cũ", 500},
    {"Máy tính văn phòng", 2500},
    {"PC CHƠI GAME", 10000},
    {"Máy đào tiền điện tử", 25000},
    {"Kết nối đường lên vệ tinh", 75000},
    {"Máy phát dữ liệu tổng hợp", 150000},
    {"Mảng anten quỹ đạo", 500000},
}

--==================================================
-- GUI HELPERS
--==================================================
local function New(class, props, parent)
    local x = Instance.new(class)
    for k, v in pairs(props or {}) do x[k] = v end
    x.Parent = parent
    return x
end

local function Round(x, r)
    New("UICorner", {CornerRadius = UDim.new(0, r or 8)}, x)
end

local function Line(x)
    New("UIStroke", {
        Color = Color3.fromRGB(70,72,84),
        Thickness = 1,
        Transparency = 0.25
    }, x)
end

local function Label(parent, text, size, pos, fontSize)
    return New("TextLabel", {
        Size = size,
        Position = pos or UDim2.new(),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Color3.fromRGB(235,235,240),
        TextSize = fontSize or 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center
    }, parent)
end

local function Button(parent, text, size, pos)
    local b = New("TextButton", {
        Size = size,
        Position = pos or UDim2.new(),
        BackgroundColor3 = Color3.fromRGB(34,35,44),
        Text = text,
        TextColor3 = Color3.fromRGB(245,245,250),
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        BorderSizePixel = 0,
        AutoButtonColor = true
    }, parent)
    Round(b, 7)
    Line(b)
    return b
end

local old = PG:FindFirstChild("NguyenGiaHungMenu")
if old then old:Destroy() end

local Gui = New("ScreenGui", {
    Name = "NguyenGiaHungMenu",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}, PG)

--==================================================
-- MAIN COMPACT WINDOW
--==================================================
local Main = New("Frame", {
    Size = UDim2.new(0, 560, 0, 350),
    Position = UDim2.new(0.5, -280, 0.5, -175),
    BackgroundColor3 = Color3.fromRGB(18,19,25),
    BorderSizePixel = 0
}, Gui)
Round(Main, 12)
Line(Main)

local Top = New("Frame", {
    Size = UDim2.new(1,0,0,44),
    BackgroundColor3 = Color3.fromRGB(24,25,32),
    BorderSizePixel = 0
}, Main)
Round(Top, 12)

Label(Top, "NGUYỄN GIA HƯNG", UDim2.new(0,210,1,0), UDim2.new(0,14,0,0), 16)
local Min = Button(Top, "—", UDim2.new(0,30,0,28), UDim2.new(1,-68,0,8))
local Close = Button(Top, "×", UDim2.new(0,30,0,28), UDim2.new(1,-34,0,8))

local Side = New("Frame", {
    Size = UDim2.new(0,118,1,-54),
    Position = UDim2.new(0,8,0,50),
    BackgroundColor3 = Color3.fromRGB(22,23,30),
    BorderSizePixel = 0
}, Main)
Round(Side, 9)

local Content = New("Frame", {
    Size = UDim2.new(1,-134,1,-54),
    Position = UDim2.new(0,126,0,50),
    BackgroundTransparency = 1
}, Main)

local Pages = {}
local Tabs = {}

local function Page(name)
    local p = New("ScrollingFrame", {
        Name = name,
        Size = UDim2.fromScale(1,1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new()
    }, Content)
    New("UIPadding", {
        PaddingTop = UDim.new(0,4),
        PaddingBottom = UDim.new(0,4),
        PaddingLeft = UDim.new(0,4),
        PaddingRight = UDim.new(0,4)
    }, p)
    Pages[name] = p
    return p
end

local function Switch(name)
    for n,p in pairs(Pages) do p.Visible = n == name end
    for n,b in pairs(Tabs) do
        b.BackgroundColor3 = n == name
            and Color3.fromRGB(42,82,62)
            or Color3.fromRGB(30,31,39)
    end
end

local function Tab(name, icon, order)
    local b = Button(Side, icon.." "..name, UDim2.new(1,-12,0,34),
        UDim2.new(0,6,0,6 + (order-1)*38))
    Tabs[name] = b
    b.MouseButton1Click:Connect(function() Switch(name) end)
end

local Home = Page("Trang chủ")
local Market = Page("Thị trường")
local Sell = Page("Bán")
local Rebirth = Page("Tái sinh")
local Upgrade = Page("Nâng cấp")
local Settings = Page("Cài đặt")

Tab("Trang chủ","⌂",1)
Tab("Thị trường","$",2)
Tab("Bán","↗",3)
Tab("Tái sinh","R",4)
Tab("Nâng cấp","+",5)
Tab("Cài đặt","⚙",6)

--==================================================
-- HOME
--==================================================
Label(Home, "BẢNG ĐIỀU KHIỂN", UDim2.new(1,-8,0,28), UDim2.new(0,4,0,0), 15).Font = Enum.Font.GothamBold

local function Toggle(parent, text, key)
    local row = New("Frame", {
        Size = UDim2.new(1,-8,0,38),
        BackgroundColor3 = Color3.fromRGB(27,28,36),
        BorderSizePixel = 0
    }, parent)
    Round(row,7)

    Label(row,text,UDim2.new(1,-72,1,0),UDim2.new(0,10,0,0),12).Font = Enum.Font.GothamBold

    local b = Button(row,"OFF",UDim2.new(0,55,0,28),UDim2.new(1,-63,0.5,-14))
    local function refresh()
        b.Text = State[key] and "ON" or "OFF"
        b.BackgroundColor3 = State[key]
            and Color3.fromRGB(40,105,70)
            or Color3.fromRGB(34,35,44)
    end
    b.MouseButton1Click:Connect(function()
        State[key] = not State[key]
        refresh()
    end)
    refresh()
end

Toggle(Home,"🏃 Speed","Speed")
Toggle(Home,"👤 ESP","ESP")
Toggle(Home,"🎯 Aim Assist","AimAssist")
Toggle(Home,"🛒 Auto Buy","AutoBuy")
Toggle(Home,"💰 Auto Sell","AutoSell")
Toggle(Home,"♻ Auto Rebirth","AutoRebirth")
Toggle(Home,"⚡ Auto Upgrade","AutoUpgrade")

--==================================================
-- MARKET
--==================================================
Label(Market,"THỊ TRƯỜNG",UDim2.new(1,-8,0,28),UDim2.new(0,4,0,0),15).Font = Enum.Font.GothamBold

for _, item in ipairs(Items) do
    local row = New("Frame", {
        Size = UDim2.new(1,-8,0,44),
        BackgroundColor3 = Color3.fromRGB(27,28,36),
        BorderSizePixel = 0
    }, Market)
    Round(row,7)

    Label(row,item[1],UDim2.new(0.68,0,1,0),UDim2.new(0,9,0,0),11).Font = Enum.Font.GothamBold
    Label(row,"$"..item[2],UDim2.new(0.15,0,1,0),UDim2.new(0.68,0,0,0),11)

    local buy = Button(row,"MUA",UDim2.new(0,58,0,28),UDim2.new(1,-66,0.5,-14))
    buy.MouseButton1Click:Connect(function()
        -- Không sửa tiền client nữa. Server quyết định giao dịch.
        callRemote("Buy", item[1])
    end)
end

--==================================================
-- SELL
--==================================================
Label(Sell,"BÁN",UDim2.new(1,-8,0,28),UDim2.new(0,4,0,0),15).Font = Enum.Font.GothamBold

local sellAll = Button(Sell,"BÁN TẤT CẢ",UDim2.new(1,-8,0,42),UDim2.new(0,4,0,36))
sellAll.MouseButton1Click:Connect(function()
    callRemote("SellAll")
end)

local sellOne = Button(Sell,"BÁN 1",UDim2.new(1,-8,0,42),UDim2.new(0,4,0,84))
sellOne.MouseButton1Click:Connect(function()
    callRemote("Sell","CurrentItem")
end)

--==================================================
-- REBIRTH
--==================================================
Label(Rebirth,"TÁI SINH",UDim2.new(1,-8,0,28),UDim2.new(0,4,0,0),15).Font = Enum.Font.GothamBold

local rb = Button(Rebirth,"♻ REBIRTH",UDim2.new(1,-8,0,48),UDim2.new(0,4,0,38))
rb.BackgroundColor3 = Color3.fromRGB(42,82,62)
rb.MouseButton1Click:Connect(function()
    callRemote("Rebirth")
end)

Label(Rebirth,
    "Điều kiện và phần thưởng được xử lý ở Server.",
    UDim2.new(1,-8,0,40),UDim2.new(0,4,0,90),11).TextColor3 =
    Color3.fromRGB(150,153,165)

--==================================================
-- UPGRADE
--==================================================
Label(Upgrade,"NÂNG CẤP",UDim2.new(1,-8,0,28),UDim2.new(0,4,0,0),15).Font = Enum.Font.GothamBold

local UpgradeTypes = {
    {"💰 TIỀN","Money"},
    {"⚔ TẤN CÔNG MẠNG","Attack"},
    {"🛡 BẢO VỆ","Defense"},
    {"📡 DỮ LIỆU","Data"},
}

for i, data in ipairs(UpgradeTypes) do
    local y = 34 + (i-1)*55
    local row = New("Frame", {
        Size = UDim2.new(1,-8,0,48),
        Position = UDim2.new(0,4,0,y),
        BackgroundColor3 = Color3.fromRGB(27,28,36),
        BorderSizePixel = 0
    }, Upgrade)
    Round(row,7)

    Label(row,data[1],UDim2.new(0.42,0,1,0),UDim2.new(0,9,0,0),10).Font = Enum.Font.GothamBold

    local b1 = Button(row,"+1",UDim2.new(0,45,0,28),UDim2.new(1,-150,0.5,-14))
    local b10 = Button(row,"+10",UDim2.new(0,45,0,28),UDim2.new(1,-100,0.5,-14))
    local bm = Button(row,"MAX",UDim2.new(0,45,0,28),UDim2.new(1,-50,0.5,-14))

    b1.MouseButton1Click:Connect(function()
        callRemote("Upgrade",data[2],1)
    end)
    b10.MouseButton1Click:Connect(function()
        callRemote("Upgrade",data[2],10)
    end)
    bm.MouseButton1Click:Connect(function()
        callRemote("Upgrade",data[2],"MAX")
    end)
end

--==================================================
-- SETTINGS
--==================================================
Label(Settings,"CÀI ĐẶT",UDim2.new(1,-8,0,28),UDim2.new(0,4,0,0),15).Font = Enum.Font.GothamBold

local function InputRow(parent, text, value, y, callback)
    local row = New("Frame", {
        Size = UDim2.new(1,-8,0,46),
        Position = UDim2.new(0,4,0,y),
        BackgroundColor3 = Color3.fromRGB(27,28,36),
        BorderSizePixel = 0
    }, parent)
    Round(row,7)

    Label(row,text,UDim2.new(0.55,0,1,0),UDim2.new(0,9,0,0),11).Font = Enum.Font.GothamBold

    local box = New("TextBox", {
        Size = UDim2.new(0,90,0,30),
        Position = UDim2.new(1,-99,0.5,-15),
        BackgroundColor3 = Color3.fromRGB(34,35,44),
        TextColor3 = Color3.fromRGB(255,255,255),
        Text = tostring(value),
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        ClearTextOnFocus = false
    }, row)
    Round(box,7)
    Line(box)

    box.FocusLost:Connect(function()
        local n = tonumber(box.Text)
        if n then
            callback(n)
        end
        box.Text = tostring(value)
    end)
end

InputRow(Settings,"Tốc độ",Config.WalkSpeed,34,function(n)
    Config.WalkSpeed = math.clamp(n,8,100)
end)

InputRow(Settings,"Aim FOV 1-180",Config.AimFov,86,function(n)
    Config.AimFov = math.clamp(n,1,180)
end)

Label(Settings,
    "Nếu MUA/REBIRTH/NÂNG CẤP báo 'chưa cấu hình RemoteConfig',\n"
    .."hãy điền đúng đường dẫn Remote của game.",
    UDim2.new(1,-8,0,60),UDim2.new(0,4,0,140),10).TextColor3 =
    Color3.fromRGB(150,153,165)

--==================================================
-- SPEED
--==================================================
RunService.Heartbeat:Connect(function()
    if State.Speed then
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = Config.WalkSpeed end
    end
end)

--==================================================
-- ESP
--==================================================
local ESPFolder = New("Folder",{Name="NGH_ESP"},Gui)

local function ClearESP()
    ESPFolder:ClearAllChildren()
end

local function UpdateESP()
    ClearESP()
    if not State.ESP then return end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local h = Instance.new("Highlight")
            h.Adornee = p.Character
            h.FillColor = Color3.fromRGB(0,255,100)
            h.OutlineColor = Color3.fromRGB(0,255,100)
            h.FillTransparency = 0.8
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            h.Parent = ESPFolder
        end
    end
end

task.spawn(function()
    while Gui.Parent do
        if State.ESP then UpdateESP() end
        task.wait(0.5)
    end
end)

--==================================================
-- AIM ASSIST
--==================================================
local function ClosestTarget()
    local cam = workspace.CurrentCamera
    if not cam then return nil end

    local center = cam.ViewportSize/2
    local best, bestDist = nil, math.huge

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            local head = p.Character:FindFirstChild("Head")

            if hum and head and hum.Health > 0 then
                local screen, visible = cam:WorldToViewportPoint(head.Position)
                if visible and screen.Z > 0 then
                    local d = (Vector2.new(screen.X,screen.Y)-center).Magnitude
                    if d < bestDist and d <= Config.AimFov*4 then
                        bestDist = d
                        best = head
                    end
                end
            end
        end
    end
    return best
end

RunService.RenderStepped:Connect(function()
    if State.AimAssist then
        local cam = workspace.CurrentCamera
        local target = ClosestTarget()
        if cam and target then
            cam.CFrame = cam.CFrame:Lerp(
                CFrame.lookAt(cam.CFrame.Position,target.Position),
                Config.AimStrength
            )
        end
    end
end)

--==================================================
-- AUTO ACTIONS
--==================================================
task.spawn(function()
    while Gui.Parent do
        if State.AutoBuy then
            callRemote("Buy",Items[1][1])
        end

        if State.AutoSell then
            callRemote("SellAll")
        end

        if State.AutoRebirth then
            callRemote("Rebirth")
        end

        if State.AutoUpgrade then
            callRemote("Upgrade","Money",1)
        end

        task.wait(2)
    end
end)

--==================================================
-- DRAG
--==================================================
local dragging = false
local dragStart
local startPosition

Top.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = Main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

--==================================================
-- MINIMIZE / CLOSE
--==================================================
local minimized = false

Min.MouseButton1Click:Connect(function()
    minimized = not minimized
    Side.Visible = not minimized
    Content.Visible = not minimized
    Main.Size = minimized
        and UDim2.new(0,260,0,44)
        or UDim2.new(0,560,0,350)
end)

Close.MouseButton1Click:Connect(function()
    ClearESP()
    Gui:Destroy()
end)

Switch("Trang chủ")
print("[NGH MENU] Compact menu loaded.")
