-- ============================================================
-- Muscle Legends | APEX PREMIUM V4
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
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- ==================== STATE ====================
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
    RepRate = 10000, -- reps por segundo
    RebirthDelay = 1,
    WalkSpeed = 16,
    JumpPower = 50,
    HatchCrystal = "Blue Crystal",
}

-- ==================== HELPERS ====================
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

-- ==================== REBIRTH REMOTE ROBUSTO ====================
local function getRebirthRemote()
    local candidates = {}
    -- Buscar en rEvents
    local rEvents = ReplicatedStorage:FindFirstChild("rEvents")
    if rEvents then
        table.insert(candidates, rEvents:FindFirstChild("rebirthRemote"))
        table.insert(candidates, rEvents:FindFirstChild("RebirthRemote"))
    end
    -- Buscar en Remotes
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if remotes then
        table.insert(candidates, remotes:FindFirstChild("rebirthRemote"))
        table.insert(candidates, remotes:FindFirstChild("RebirthRemote"))
    end
    -- Buscar en todo ReplicatedStorage
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

-- ==================== ANTI-KICK ====================
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

-- ==================== ULTRA FAST REP (10,000 / SEGUNDO) ====================
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
        end
