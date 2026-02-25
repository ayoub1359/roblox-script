-- تعريف الخدمات الأساسية
local player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- إنشاء الواجهة الأساسية (ScreenGui)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CustomMovementGUI"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

-- إنشاء الإطار الرئيسي (القائمة)
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 260, 0, 520) -- تم تعريض القائمة قليلاً لتتسع للزرين في السطر الأخير
Frame.Position = UDim2.new(0.4, 0, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

-- إضافة حواف دائرية للإطار
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = Frame

-- إضافة ترتيب تلقائي (UIListLayout)
local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = Frame
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.Padding = UDim.new(0, 8)

-- العنوان
local Title = Instance.new("TextLabel")
Title.Text = "قائمة التحكم بالحركة"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20
Title.Parent = Frame

-- ==========================================
-- مربع كتابة القوة / المسافة الأساسي
-- ==========================================
local PowerInput = Instance.new("TextBox")
PowerInput.Size = UDim2.new(1, -20, 0, 30)
PowerInput.Text = "50" 
PowerInput.PlaceholderText = "اكتب القوة أو المسافة هنا"
PowerInput.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
PowerInput.TextColor3 = Color3.fromRGB(0, 255, 100)
PowerInput.Font = Enum.Font.SourceSansBold
PowerInput.TextSize = 18
PowerInput.Parent = Frame

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 5)
InputCorner.Parent = PowerInput

-- دالة (Function) مخصصة لصنع الأزرار العادية
local function CreateButton(text)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 35)
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 16
    btn.Parent = Frame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = btn
    
    return btn
end

-- دالة لجلب الرقم من المربع الأساسي
local function GetPower()
    return tonumber(PowerInput.Text) or 50 
end

-- ==========================================
-- متغير لحفظ الاتجاه المُثبت
-- ==========================================
local lockedDirection = nil 

-- دالة تجلب الاتجاه المطلوب
local function GetActiveDirection(root)
    if lockedDirection then
        return lockedDirection
    else
        return root.CFrame.LookVector
    end
end

-- ==========================================
-- أزرار التحكم بالمجسم وتثبيت الاتجاه
-- ==========================================
local BtnToggle3D = CreateButton("👁️ إظهار المسار 3D: OFF")
BtnToggle3D.BackgroundColor3 = Color3.fromRGB(70, 70, 20)

local BtnLockDirection = CreateButton("🔓 تثبيت الاتجاه: OFF")
BtnLockDirection.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

local isPointerActive = false

-- إنشاء المجسم 3D
local pointer3D = Instance.new("Part")
pointer3D.Anchored = true
pointer3D.CanCollide = false
pointer3D.Material = Enum.Material.Neon
pointer3D.Color = Color3.fromRGB(0, 255, 0)
pointer3D.Transparency = 1 
pointer3D.Parent = workspace

-- برمجة زر إظهار المجسم
BtnToggle3D.MouseButton1Click:Connect(function()
    isPointerActive = not isPointerActive
    if isPointerActive then
        BtnToggle3D.Text = "👁️ إظهار المسار 3D: ON"
        BtnToggle3D.BackgroundColor3 = Color3.fromRGB(20, 70, 20)
        pointer3D.Transparency = 0.5
    else
        BtnToggle3D.Text = "👁️ إظهار المسار 3D: OFF"
        BtnToggle3D.BackgroundColor3 = Color3.fromRGB(70, 70, 20)
        pointer3D.Transparency = 1
    end
end)

-- برمجة زر تثبيت الاتجاه
BtnLockDirection.MouseButton1Click:Connect(function()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local root = char.HumanoidRootPart

    if lockedDirection == nil then
        lockedDirection = root.CFrame.LookVector
        BtnLockDirection.Text = "🔒 الاتجاه مُثبت: ON"
        BtnLockDirection.BackgroundColor3 = Color3.fromRGB(80, 20, 20) 
        pointer3D.Color = Color3.fromRGB(255, 0, 0) 
    else
        lockedDirection = nil
        BtnLockDirection.Text = "🔓 تثبيت الاتجاه: OFF"
        BtnLockDirection.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        pointer3D.Color = Color3.fromRGB(0, 255, 0) 
    end
end)

-- تحديث مكان المجسم 3D 
RunService.RenderStepped:Connect(function()
    if isPointerActive then
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local root = char.HumanoidRootPart
            local distance = GetPower()
            pointer3D.Size = Vector3.new(0.3, 0.3, distance)
            
            local activeDir = GetActiveDirection(root)
            local baseCFrame = CFrame.new(root.Position, root.Position + activeDir)
            pointer3D.CFrame = baseCFrame * CFrame.new(0, 0, -distance / 2)
        end
    end
end)

-- ==========================================
-- 1. زر الانتقال (كودك الأصلي كما طلبت تماماً)
-- ==========================================
local BtnTeleport = CreateButton("1. Teleport (الأصلي)")
BtnTeleport.MouseButton1Click:Connect(function()
    local char = player.Character or player.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    root.CFrame = CFrame.new(7e8, 7e8, 7e8)
end)

-- ==========================================
-- 2. رمي 
-- ==========================================
local BtnThrow = CreateButton("2. رمي (Throw)")
BtnThrow.MouseButton1Click:Connect(function()
    local char = player.Character or player.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    local power = GetPower()
    local dir = GetActiveDirection(root) 
    root.AssemblyLinearVelocity = (dir * power) + Vector3.new(0, power / 2, 0)
end)

-- ==========================================
-- 3. دفع 
-- ==========================================
local BtnPush = CreateButton("3. دفع (Push)")
BtnPush.MouseButton1Click:Connect(function()
    local char = player.Character or player.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    local power = GetPower()
    local dir = GetActiveDirection(root)
    
    local attachment = Instance.new("Attachment", root)
    local linearVelocity = Instance.new("LinearVelocity", root)
    linearVelocity.Attachment0 = attachment
    linearVelocity.MaxForce = 9999999
    linearVelocity.VectorVelocity = dir * power 
    
    task.delay(1, function()
        linearVelocity:Destroy()
        attachment:Destroy()
    end)
end)

-- ==========================================
-- 4. مشي 
-- ==========================================
local BtnWalk = CreateButton("4. مشي (Walk)")
BtnWalk.MouseButton1Click:Connect(function()
    local char = player.Character or player.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    local humanoid = char:WaitForChild("Humanoid")
    local distance = GetPower()
    local dir = GetActiveDirection(root)
    
    local targetPosition = root.Position + (dir * distance)
    humanoid:MoveTo(targetPosition)
end)

-- ==========================================
-- 5. طيران سلس 
-- ==========================================
local BtnTween = CreateButton("5. طيران سلس (Smooth Fly)")
BtnTween.MouseButton1Click:Connect(function()
    local char = player.Character or player.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    local distance = GetPower()
    local dir = GetActiveDirection(root)
    
    root.Anchored = true 
    local targetPosition = root.Position + (dir * distance)
    local targetCFrame = CFrame.new(targetPosition)
    local flightTime = math.max(1, distance / 50) 
    local tweenInfo = TweenInfo.new(flightTime, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(root, tweenInfo, {CFrame = targetCFrame})
    
    tween:Play()
    tween.Completed:Connect(function()
        root.Anchored = false
    end)
end)

-- ==========================================
-- إعداد السطر الخاص بالزر 6 (زرين يسار + مربع يمين)
-- ==========================================
local Row6Container = Instance.new("Frame")
Row6Container.Size = UDim2.new(1, -20, 0, 35)
Row6Container.BackgroundTransparency = 1
Row6Container.Parent = Frame

-- 6A. زر الانتقال للأعلى (بدون تعديل الوظيفة)
local BtnTeleportUp = Instance.new("TextButton")
BtnTeleportUp.Size = UDim2.new(0.35, -5, 1, 0)
BtnTeleportUp.Position = UDim2.new(0, 0, 0, 0)
BtnTeleportUp.Text = "⬆️ أعلى"
BtnTeleportUp.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
BtnTeleportUp.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnTeleportUp.Font = Enum.Font.SourceSansBold
BtnTeleportUp.TextSize = 16
BtnTeleportUp.Parent = Row6Container

local BtnCorner6A = Instance.new("UICorner")
BtnCorner6A.CornerRadius = UDim.new(0, 5)
BtnCorner6A.Parent = BtnTeleportUp

-- 6B. زر الانتقال للأمام (الزر الجديد)
local BtnTeleportForward = Instance.new("TextButton")
BtnTeleportForward.Size = UDim2.new(0.35, -5, 1, 0)
BtnTeleportForward.Position = UDim2.new(0.35, 5, 0, 0)
BtnTeleportForward.Text = "➡️ أمام"
BtnTeleportForward.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
BtnTeleportForward.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnTeleportForward.Font = Enum.Font.SourceSansBold
BtnTeleportForward.TextSize = 16
BtnTeleportForward.Parent = Row6Container

local BtnCorner6B = Instance.new("UICorner")
BtnCorner6B.CornerRadius = UDim.new(0, 5)
BtnCorner6B.Parent = BtnTeleportForward

-- المربع الرقمي المشترك للزرين
local SharedInput = Instance.new("TextBox")
SharedInput.Size = UDim2.new(0.3, 0, 1, 0)
SharedInput.Position = UDim2.new(0.7, 5, 0, 0)
SharedInput.Text = "10"
SharedInput.PlaceholderText = "الرقم"
SharedInput.BackgroundColor3 = Color3.fromRGB(30, 15, 15)
SharedInput.TextColor3 = Color3.fromRGB(255, 100, 100)
SharedInput.Font = Enum.Font.SourceSansBold
SharedInput.TextSize = 16
SharedInput.Parent = Row6Container

local SharedInputCorner = Instance.new("UICorner")
SharedInputCorner.CornerRadius = UDim.new(0, 5)
SharedInputCorner.Parent = SharedInput

-- برمجة زر الانتقال للأعلى (كما هو تماماً)
BtnTeleportUp.MouseButton1Click:Connect(function()
    local char = player.Character or player.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    
    local dist = tonumber(SharedInput.Text) or 10 
    root.CFrame = root.CFrame + Vector3.new(0, dist, 0)
end)

-- برمجة زر الانتقال للأمام (يأخذ الاتجاه المُثبت والمقدار من نفس المربع)
BtnTeleportForward.MouseButton1Click:Connect(function()
    local char = player.Character or player.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    
    local dist = tonumber(SharedInput.Text) or 10 
    local dir = GetActiveDirection(root) -- يجلب الاتجاه الحالي أو المُثبت
    
    -- انتقال لحظي (CFrame) في الاتجاه المحدد
    root.CFrame = root.CFrame + (dir * dist)
end)
