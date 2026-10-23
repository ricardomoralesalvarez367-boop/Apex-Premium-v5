-- ============================================================
-- Muscle Legends | APEX PREMIUM V4 - FIXED FINAL
-- Fast Rep: 10,000 reps/segundo (Heartbeat-based)
-- Auto Rebirth: Remoto robusto + Fallback GUI
-- UI: WindUI (Premium)
-- ============================================================

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")

local State = {
    UltraFastRep = false,
    AutoEquipWeight = false,
    AutoTrainGeneral = false,
    AutoPunch = false,
    AutoRebirth = false,
    AutoClaim = false,
    AutoTreadmill = false,
    AutoHatch = false,
    AntiAFK = true,
    Fullbright = false,
    AntiKick = false,
    KillAura = false,
    RepRate = 10000,
    RebirthDelay = 1,
    WalkSpeed = 16,
    JumpPower = 50,
    HatchCrystal = "Blue Crystal",
}

local function getCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

local function getHumanoid()
    local char = getCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function applyWalkSpeed()
    local hum = getHumanoid()
    if hum then hum.WalkSpeed = State.WalkSpeed end
end

local function applyJumpPower()
    local hum = getHumanoid()
    if hum then
        hum.JumpPower = State.JumpPower
        hum.UseJumpPower = true
    end
end

local function applyFullbright()
    if State.Fullbright then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 2
        Lighting.ClockTime = 12
        Lighting.GlobalShadows = false
    else
        Lighting.Ambient = Color3.fromRGB(0, 0, 0)
        Lighting.OutdoorAmbient = Color3.fromRGB(0, 0, 0)
        Lighting.Brightness = 1
        Lighting.GlobalShadows = true
    end
end

local function getMuscleEvent()
    return player:FindFirstChild("MuscleEvent")
        or player:FindFirstChild("muscleEvent")
        or (getCharacter() and (getCharacter():FindFirstChild("MuscleEvent") or getCharacter():FindFirstChild("muscleEvent")))
        or player:WaitForChild("MuscleEvent", 5)
end

local function getRebirthRemote()
    local candidates = {}
    local rEvents = ReplicatedStorage:FindFirstChild("rEvents")
    if rEvents then
        table.insert(candidates, rEvents:FindFirstChild("rebirthRemote"))
        table.insert(candidates, rEvents:FindFirstChild("RebirthRemote"))
    end
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if remotes then
        table.insert(candidates, remotes:FindFirstChild("rebirthRemote"))
        table.insert(candidates, remotes:FindFirstChild("RebirthRemote"))
    end
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj.Name:lower():find("rebirth") and (obj:IsA("RemoteFunction") or obj:IsA("RemoteEvent")) then
            table.insert(candidates, obj)
        end
    end
    for _, remote in ipairs(candidates) do
        if remote then return remote end
    end
    return nil
end

local function enableAntiKick()
    if State.AntiKick then return end
    local ok = pcall(function()
        local mt = getrawmetatable(game)
        local old = mt.__namecall
        local new = newcclosure(function(self, ...)
            if getnamecallmethod() == "Kick" and self == player then return end
            return old(self, ...)
        end)
        setreadonly(mt, false)
        mt.__namecall = new
        setreadonly(mt, true)
    end)
    if ok then State.AntiKick = true end
end

local function startUltraFastRep()
    if State.UltraFastRep then return end
    State.UltraFastRep = true
    local targetRate = State.RepRate
    local accumulated = 0
    local conn
    conn = RunService.Heartbeat:Connect(function(dt)
        if not State.UltraFastRep then
            conn:Disconnect()
            return
        end
        accumulated = accumulated + dt * targetRate
        local repsThisFrame = math.floor(accumulated)
        accumulated = accumulated - repsThisFrame
        local ev = getMuscleEvent()
        if ev then
            for i = 1, repsThisFrame do
                pcall(function()
                    ev:FireServer("punch", "leftHand")
                    ev:FireServer("punch", "rightHand")
                end)
            end
        end
    end)
end

local function autoEquipWeight()
    local hum = getHumanoid()
    if not hum then return end
    local backpack = player:FindFirstChild("Backpack")
    if not backpack then return end
    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local n = string.lower(tool.Name)
            if string.find(n, "weight") or string.find(n, "dumbbell") or string.find(n, "barbell") then
                pcall(function() hum:EquipTool(tool) end)
                break
            end
        end
    end
end

local function fireProximityPrompts()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local txt = string.lower(obj.ActionText)
            if string.find(txt, "push") or string.find(txt, "sit") or string.find(txt, "hand") then
                pcall(function() fireproximityprompt(obj) end)
            end
        end
    end
end

local function autoPunch()
    task.spawn(function()
        while State.AutoPunch do
            pcall(function()
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            end)
            task.wait(0.05)
        end
    end)
end

local function startAutoRebirth()
    if State.AutoRebirth then return end
    State.AutoRebirth = true
    task.spawn(function()
        while State.AutoRebirth do
            local remote = getRebirthRemote()
            if remote then
                pcall(function()
                    if remote:IsA("RemoteFunction") then
                        remote:InvokeServer("rebirthRequest")
                    elseif remote:IsA("RemoteEvent") then
                        remote:FireServer("rebirthRequest")
                    end
                end)
            end
            pcall(function()
                local gui = player:FindFirstChild("PlayerGui")
                if gui then
                    for _, obj in ipairs(gui:GetDescendants()) do
                        if obj:IsA("TextButton") or obj:IsA("ImageButton") then
                            local t = string.lower(obj.Text or obj.Name)
                            if string.find(t, "rebirth") then
                                obj:Activate()
                                break
                            end
                        end
                    end
                end
            end)
            task.wait(State.RebirthDelay)
        end
    end)
end

local function startAutoClaim()
    if State.AutoClaim then return end
    State.AutoClaim = true
    task.spawn(function()
        while State.AutoClaim do
            local gui = player:FindFirstChild("PlayerGui")
            if gui then
                for _, obj in ipairs(gui:GetDescendants()) do
                    if obj:IsA("TextButton") or obj:IsA("ImageButton") then
                        local t = string.lower(obj.Text or obj.Name)
                        if string.find(t, "claim") or string.find(t, "collect") or string.find(t, "reward") then
                            pcall(function() obj:Activate() end)
                        end
                    end
                end
            end
            task.wait(1)
        end
    end)
end

local function startAutoTreadmill()
    if State.AutoTreadmill then return end
    State.AutoTreadmill = true
    task.spawn(function()
        while State.AutoTreadmill do
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") then
                    local txt = string.lower(obj.ActionText)
                    if string.find(txt, "tread") or string.find(txt, "run") then
                        pcall(function() fireproximityprompt(obj) end)
                        break
                    end
                end
            end
            task.wait(0.5)
        end
    end)
end

local function startAutoHatch()
    if State.AutoHatch then return end
    State.AutoHatch = true
    task.spawn(function()
        while State.AutoHatch do
            local rEvents = ReplicatedStorage:FindFirstChild("rEvents")
            local remote = rEvents and rEvents:FindFirstChild("openCrystalRemote")
            if remote then
                pcall(function()
                    remote:InvokeServer("openCrystalRequest", State.HatchCrystal)
                end)
            end
            task.wait(1)
        end
    end)
end

local function startKillAura()
    if State.KillAura then return end
    State.KillAura = true
    task.spawn(function()
        while State.KillAura do
            for _, v in ipairs(Players:GetPlayers()) do
                if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (player.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
                    if dist < 30 then
                        local ev = getMuscleEvent()
                        if ev then
                            pcall(function()
                                ev:FireServer("punch", "leftHand")
                                ev:FireServer("punch", "rightHand")
                            end)
                        end
                    end
                end
            end
            task.wait(0.1)
        end
    end)
end

local function startAntiAFK()
    player.Idled:Connect(function()
        if State.AntiAFK then
            pcall(function()
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
            end)
        end
    end)
end

local function teleportToCFrame(cf)
    local char = getCharacter()
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.CFrame = cf end
end

local function teleportToPart(name)
    local target = Workspace:FindFirstChild(name, true)
    if target and target:IsA("BasePart") then
        teleportToCFrame(target.CFrame + Vector3.new(0, 5, 0))
    end
end

player.CharacterAdded:Connect(function()
    task.wait(1)
    applyWalkSpeed()
    applyJumpPower()
    if State.Fullbright then applyFullbright() end
end)

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "APEX PREMIUM V4 | Muscle Legends",
    Subtitle = "10,000 Reps/s + Auto Rebirth Robusto",
    Icon = "dumbbell",
    Theme = "Dark",
    Size = UDim2.fromOffset(600, 480),
    Transparent = true,
    Resizable = true,
})

local FarmTab = Window:Tab({ Title = "Farm", Icon = "swords" })
local RebirthTab = Window:Tab({ Title = "Rebirth", Icon = "refresh-cw" })
local TeleportTab = Window:Tab({ Title = "Teleports", Icon = "map-pin" })
local CombatTab = Window:Tab({ Title = "Combat", Icon = "crosshair" })
local UtilTab = Window:Tab({ Title = "Utilities", Icon = "settings" })

local FarmSection = FarmTab:Section({ Title = "Strength Training", Opened = true })

FarmSection:Toggle({
    Title = "Ultra Fast Rep (10,000/s)",
    Description = "Dispara 10,000 repeticiones por segundo usando Heartbeat.",
    Value = false,
    Callback = function(v)
        State.UltraFastRep = v
        if v then startUltraFastRep() end
    end,
})

FarmSection:Slider({
    Title = "Rep Rate (reps/segundo)",
    Value = { Min = 100, Max = 20000, Default = 10000 },
    Step = 100,
    Callback = function(v) State.RepRate = v end,
})

FarmSection:Toggle({
    Title = "Auto Equip Weight",
    Value = false,
    Callback = function(v)
        State.AutoEquipWeight = v
        if v then
            task.spawn(function()
                while State.AutoEquipWeight do
                    autoEquipWeight()
                    task.wait(0.5)
                end
            end)
        end
    end,
})

FarmSection:Toggle({
    Title = "Auto Train General",
    Value = false,
    Callback = function(v)
        State.AutoTrainGeneral = v
        if v then
            task.spawn(function()
                while State.AutoTrainGeneral do
                    fireProximityPrompts()
                    task.wait(0.1)
                end
           
