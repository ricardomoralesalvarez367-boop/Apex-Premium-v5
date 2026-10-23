-- APEX V4 FULL FIXED
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local VIM = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer

local State = {UltraFastRep=false, AutoRebirth=false, RepRate=10000, RebirthDelay=1}

local function getCharacter() return player.Character or player.CharacterAdded:Wait() end
local function getHumanoid() local c=getCharacter() return c and c:FindFirstChildOfClass("Humanoid") end
local function getMuscleEvent() return player:FindFirstChild("MuscleEvent") or getCharacter():FindFirstChild("MuscleEvent") end
local function getRebirthRemote()
    for _,obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj.Name:lower():find("rebirth") and (obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction")) then return obj end
    end
    return nil
end
local function teleportToCFrame(cf) local hrp=getCharacter():FindFirstChild("HumanoidRootPart") if hrp then hrp.CFrame=cf end end

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Window = WindUI:CreateWindow({Title="APEX PREMIUM V4 | Muscle Legends", Icon="dumbbell", Theme="Dark", Size=UDim2.fromOffset(600,480), Transparent=true})

local FarmTab = Window:Tab({Title="Farm", Icon="swords"})
local RebirthTab = Window:Tab({Title="Rebirth", Icon="refresh-cw"})
local TeleportTab = Window:Tab({Title="Teleports", Icon="map-pin"})
local UtilTab = Window:Tab({Title="Utilities", Icon="settings"})

FarmTab:Section({Title="Strength Training", Opened=true}):Toggle({
    Title="Ultra Fast Rep (10,000/s)", Value=false,
    Callback=function(v) State.UltraFastRep=v if v then local acc=0 RunService.Heartbeat:Connect(function(dt) if not State.UltraFastRep then return end acc=acc+dt*State.RepRate local reps=math.floor(acc) acc=acc-reps local ev=getMuscleEvent() if ev then for i=1,reps do pcall(function() ev:FireServer("punch","leftHand") end) end end end) end end
})

RebirthTab:Section({Title="Rebirth", Opened=true}):Toggle({
    Title="Auto Rebirth (Robusto)", Value=false,
    Callback=function(v) State.AutoRebirth=v if v then task.spawn(function() while State.AutoRebirth do local r=getRebirthRemote() if r then pcall(function() if r:IsA("RemoteFunction") then r:InvokeServer("rebirthRequest") else r:FireServer("rebirthRequest") end end) end task.wait(State.RebirthDelay) end end) end end
})

TeleportTab:Section({Title="Gym Teleports", Opened=true}):Button({Title="Frost Gym", Callback=function() teleportToCFrame(CFrame.new(915,37,349)) end})
TeleportTab:Section({Title="", Opened=true}):Button({Title="Mythical Gym", Callback=function() teleportToCFrame(CFrame.new(2289,37,1072)) end})

UtilTab:Section({Title="Player Mods", Opened=true}):Slider({Title="WalkSpeed", Value={Min=16,Max=250,Default=16}, Callback=function(v) local h=getHumanoid() if h then h.WalkSpeed=v end end})

WindUI:Notify({Title="APEX V4", Content="Full Version Loaded!", Duration=3})
