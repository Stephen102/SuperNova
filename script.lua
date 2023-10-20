while not workspace.Balls:GetChildren()[2] do 
wait(0.1)
end

-- Variables
local ReplicatedStorage = game:GetService"ReplicatedStorage"
local Players = game:GetService"Players"
local RunService = game:GetService"RunService"

local Velos = 0
local Camera = workspace:FindFirstChild"Camera"
local Balls = workspace:FindFirstChild"Balls"
local Alive = workspace:FindFirstChild"Alive"
local Dead = workspace:FindFirstChild"Dead"
local DefaultChatSystemChatEvents = ReplicatedStorage.DefaultChatSystemChatEvents
local Remotes = ReplicatedStorage.Remotes
local LocalPlayer = Players.LocalPlayer
local Newborn = false

local PlayerScripts = LocalPlayer.PlayerScripts
local Ball = Balls:GetChildren()[2]
local Character = LocalPlayer.Character
local Parry = Remotes.ParryButtonPress
local SayMessageRequest = DefaultChatSystemChatEvents.SayMessageRequest
local Freeze = Remotes.Freeze

local EffectScripts = PlayerScripts.EffectScripts
local ClientFX = EffectScripts.ClientFX

local Shake = ClientFX.Shake

local Config = {
  AutoParrying = {
    AutoParryEnabled = false,
    MinRange = 25,
    ShowHitbox = false
  },
  AutoMove = {
    AutoMoveEnabled = false,
    ReactionTime = 0.5
  },
  WinAction = {
    WinActionEnabled = false,
    WinActionMessage = "",
    WinActionDelay = 1
  },
  Other = {
      AutoClick = false,
      ChatSpamMessage = "",
      ChatSpamDelay = 0.6,
      ChatSpamEnabled = false,
      InfiniteJump = false
  },
  Troll = {
      FreezeBall = false,
      FreezeDelay = 1,
      BugBall = false,
  }
}

if Camera:FindFirstChild"BallDetector" then
    Camera:FindFirstChild"BallDetector":Destroy()
end

-- Setup

local Rayfield = loadstring(game:HttpGet'https://sirius.menu/rayfield')()

local Window = Rayfield:CreateWindow({
   Name = "Super Nova",
   LoadingTitle = "A Blade Ball Script",
   LoadingSubtitle = "by Stephen",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "SuperNovaHUB",
      FileName = "settings"
   }
})

local Hitbox = Instance.new("Part",Camera)
Hitbox.Name = "BallDetector"
Hitbox.CastShadow = false
Hitbox.Size = Vector3.new(15,15,15)
Hitbox.Position = Character.PrimaryPart.Position
Hitbox.Transparency = Config.AutoParrying["ShowHitbox"] and 0.6 or 1
Hitbox.Material = Enum.Material.ForceField
Hitbox.Shape = Enum.PartType.Ball
Hitbox.Color = Color3.fromRGB(255,255,255)
Hitbox.CanCollide = false

-- Events

spawn(function()
    while Hitbox and Character.PrimaryPart do
        Hitbox.Position = Character.PrimaryPart.Position
         Hitbox.Velocity = Vector3.new(0, 0, 0)
        RunService.Stepped:Wait()
    end
end)

spawn(function()
    while Hitbox and Ball do
        local OnePos = Ball.Position
        RunService.Heartbeat:Wait()
        local TwoPos = Ball.Position
        Velos = (OnePos-TwoPos).Magnitude+LocalPlayer:GetNetworkPing()*6
        Velos *= 12
    end
end)

Balls.ChildAdded:Connect(function()
    spawn(function()
        Newborn = true
        wait(0.1)
        Newborn = false
    end)
    while not workspace.Balls:GetChildren()[2] do 
       wait()
    end
    Velos = 0
    Ball = Balls:GetChildren()[2]
    Ball.Changed:Connect(function()
    	if Hitbox then
            Hitbox.Size = Vector3.new(Config.AutoParrying.MinRange+Velos*2,Config.AutoParrying.MinRange+Velos*2,Config.AutoParrying.MinRange+Velos*2)
        end
    end)
end)

Ball.Changed:Connect(function()
	if Hitbox then
        Hitbox.Size = Vector3.new(Config.AutoParrying.MinRange+Velos*2,Config.AutoParrying.MinRange+Velos*2,Config.AutoParrying.MinRange+Velos*2)
    end
end)

Character:FindFirstChild"Humanoid".Changed:Connect(function(property)
   if property == "Jump" and Character:FindFirstChild"Humanoid".Jump == true and Config.Other["InfiniteJump"] then
       Character:FindFirstChild"Humanoid":ChangeState("Jumping")
   end
end)

LocalPlayer.CharacterAdded:Connect(function(Char)
    wait(2)
    Character = Char
    Character:FindFirstChild"Humanoid".Changed:Connect(function(property)
   if property == "Jump" and Character:FindFirstChild"Humanoid".Jump == true and Config.Other["InfiniteJump"] then
       Character:FindFirstChild"Humanoid":ChangeState("Jumping")
   end
end)
spawn(function()

       local function findTarget()
	local target
	for i, v in pairs(Players:GetPlayers()) do
		if v.Character and v.Character:FindFirstChild"Highlight" then
            target = v.Character.PrimaryPart
        end
	end
	return target
end

           while Config.AutoMove["AutoMoveEnabled"] do
               local target = findTarget()
           
            if target and Character.PrimaryPart and Character.PrimaryPart ~= target and Character.Parent == Alive then
               local Near = target.Position + Vector3.new(math.random(-20,20),0,math.random(-20,20))
                              repeat
                                 Near = target.Position + Vector3.new(math.random(-20,20),0,math.random(-20,20))
                              until (target.Position - Near).Magnitude > 19
                              if math.random(1,3)%2==0  and Character:FindFirstChild"Humanoid".FloorMaterial ~= Enum.Material.Air  then
                                  Character:FindFirstChild"Humanoid":ChangeState("Jumping")
                              end
                              wait(Config.AutoMove["ReactionTime"])
                              Character:FindFirstChild"Humanoid":MoveTo(Near)
               else if Character.PrimaryPart then
                    local Near = Ball.Position + Vector3.new(math.random(-10,10),0,math.random(-10,10))
                              repeat
                                 Near = Ball.Position + Vector3.new(math.random(-10,10),0,math.random(-10,10))
                              until (Ball.Position - Near).Magnitude > 9
                              wait(Config.AutoMove["ReactionTime"])
                              Character:FindFirstChild"Humanoid":MoveTo(Near)
                    if math.random(1,10)%2==0 and Character:FindFirstChild"Humanoid".FloorMaterial ~= Enum.Material.Air then
                        Character:FindFirstChild"Humanoid":ChangeState("Jumping")
                    end
        	    	Character:FindFirstChild"Humanoid".MoveToFinished:Wait(2)
               end
           end
           if Character.Parent == Dead then
               Character:FindFirstChild"Humanoid":MoveTo(Character.PrimaryPart.Position + Vector3.new(math.random(-50, 50), 0, math.random(-50, 50)))
           end
           wait(0.2)
           end
       end)
    if Camera:FindFirstChild"BallDetector" then
        Hitbox = Instance.new("Part",Camera)
        Hitbox.Name = "BallDetector"
        Hitbox.Size = Vector3.new(15,15,15)
        Hitbox.Position = Char.PrimaryPart.Position
        Hitbox.Transparency = Config.AutoParrying["ShowHitbox"] and 0.6 or 1
        Hitbox.Material = Enum.Material.ForceField
        Hitbox.Shape = Enum.PartType.Ball
        Hitbox.CastShadow = false
        Hitbox.Color = Color3.fromRGB(255,255,255)
        Hitbox.CanCollide = false
        Hitbox.Anchored = false

        Hitbox.Touched:Connect(function(P)
	        if not Newborn and P.Parent == Balls and Config.AutoParrying["AutoParryEnabled"] and Character:FindFirstChild"Highlight" then
	        	Parry:Fire()
                if Config.Troll["BugBall"] then
                    Shake:Fire(P.Position)
                end
	        end
        end)

        spawn(function()
          while Hitbox and Character.PrimaryPart do
              Hitbox.Position = Character.PrimaryPart.Position
               Hitbox.Velocity = Vector3.new(0, 0, 0)
              RunService.Stepped:Wait()
          end
       end)
        
        spawn(function()
    while Hitbox do
        local OnePos = Ball.Position
        wait()
        local TwoPos = Ball.Position
        Velos = (OnePos-TwoPos).Magnitude+LocalPlayer:GetNetworkPing()*2
    end
end)
    end
end)

Alive.ChildRemoved:Connect(function()
   if Alive:FindFirstChild(LocalPlayer.Name) and Config.WinAction["WinActionEnabled"] then
       wait(Config.WinAction["WinActionDelay"])
       SayMessageRequest:FireServer(Config.WinAction["WinActionMessage"],"All")
   end
end)

Hitbox.Touched:Connect(function(P)
	        if Ball and P.Parent == Balls and Config.AutoParrying["AutoParryEnabled"] and Character:FindFirstChild"Highlight" then
	        	Parry:Fire()
	        end
        end)

local AUTOBOT = Window:CreateTab("AutoBot", 7733765307)

AUTOBOT:CreateSection"Auto Parry"

AUTOBOT:CreateToggle({
   Name = "Auto Parry",
   CurrentValue = false,
   Flag = "AutoParryEnabled",
   Callback = function(Value)
       Config.AutoParrying["AutoParryEnabled"] = Value
       Rayfield:Notify({
            Title = Value and "Auto Parrying is now Enabled!" or "Auto Parrying is now Disabled!",
            Content = Value and "Every time the ball is on your range, you will parry it!" or "Now, everytime a ball enters your range it doesn't block automatically.",
            Duration = 4,
            Image = Value and "7733715400" or "7743878857"
       })
   end,
})

AUTOBOT:CreateSlider({
   Name = "Parry Additional Range",
   Range = {15, 30},
   Increment = 1,
   Suffix = "Range",
   CurrentValue = 25,
   Flag = "MinRange",
   Callback = function(Value)
       Config.AutoParrying["MinRange"] = Value
       Hitbox.Size = Vector3.new(Value+Velos*2,Value+Velos*2,Value+Velos*2)
   end,
})

AUTOBOT:CreateToggle({
   Name = "Show Parry Range",
   CurrentValue = false,
   Flag = "ShowHitbox",
   Callback = function(Value)
       Config.AutoParrying["ShowHitbox"] = Value
       Hitbox.Transparency = Value and 0.6 or 1
   end,
})

AUTOBOT:CreateSection"Auto Movement"

AUTOBOT:CreateToggle({
   Name = "Movement",
   CurrentValue = false,
   Flag = "AutoMoveEnabled",
   Callback = function(Value)
       Config.AutoMove["AutoMoveEnabled"] = Value
       spawn(function()

       local function findTarget()
	local target
	for i, v in pairs(Players:GetPlayers()) do
		if v.Character and v.Character:FindFirstChild"Highlight" then
            target = v.Character.PrimaryPart
        end
	end
	return target
end

           while Config.AutoMove["AutoMoveEnabled"] do
               local target = findTarget()
           
            if target and Character.PrimaryPart and Character.PrimaryPart ~= target and Character.Parent == Alive then
               local Near = target.Position + Vector3.new(math.random(-20,20),0,math.random(-20,20))
                              repeat
                                 Near = target.Position + Vector3.new(math.random(-20,20),0,math.random(-20,20))
                              until (target.Position - Near).Magnitude > 19
                              if math.random(1,20)%2==0  and Character:FindFirstChild"Humanoid".FloorMaterial ~= Enum.Material.Air  then
                                  Character:FindFirstChild"Humanoid":ChangeState("Jumping")
                              end
                              wait(Config.AutoMove["ReactionTime"])
                              Character:FindFirstChild"Humanoid":MoveTo(Near)
               else if Character.PrimaryPart then
                    local Near = Ball.Position + Vector3.new(math.random(-10,10),0,math.random(-10,10))
                              repeat
                                 Near = Ball.Position + Vector3.new(math.random(-10,10),0,math.random(-10,10))
                              until (Ball.Position - Near).Magnitude > 9
                              wait(Config.AutoMove["ReactionTime"])
                              Character:FindFirstChild"Humanoid":MoveTo(Near)
                    if math.random(1,10)%2==0 and Character:FindFirstChild"Humanoid".FloorMaterial ~= Enum.Material.Air then
                        Character:FindFirstChild"Humanoid":ChangeState("Jumping")
                    end
        	    	Character:FindFirstChild"Humanoid".MoveToFinished:Wait(2)
               end
           end
           if Character.Parent == Dead then
               Character:FindFirstChild"Humanoid":MoveTo(Character.PrimaryPart.Position + Vector3.new(math.random(-50, 50), 0, math.random(-50, 50)))
           end
           wait(0.2)
           end
       end)
       Rayfield:Notify({
            Title = Value and "Auto Movement is now Enabled!" or "Auto Movement is now Disabled!",
            Content = Value and "Now you will move automatically targeting people!" or "Now you should move manually.",
            Duration = 4,
            Image = Value and "7733715400" or "7743878857"
       })
   end,
})

AUTOBOT:CreateSlider({
   Name = "Reaction Time",
   Range = {0, 1},
   Increment = 0.05,
   Suffix = "Reaction Speed",
   CurrentValue = 0.5,
   Flag = "ReactionTime",
   Callback = function(Value)
       Config.AutoMove["ReactionTime"] = Value
   end,
})

AUTOBOT:CreateParagraph({Title = "DISCLAIMER", Content = "Walking cancels the auto movement, reactivate it to work again."})

AUTOBOT:CreateSection"Win Action"

AUTOBOT:CreateInput({
   Name = "Win Message",
   PlaceholderText = "gg.",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
       Config.WinAction["WinActionMessage"] = Text
   end,
})

AUTOBOT:CreateSlider({
   Name = "Win Action Delay",
   Range = {0.5, 2},
   Increment = 0.05,
   Suffix = "Delay",
   CurrentValue = 1,
   Flag = "WinActionDelay",
   Callback = function(Value)
       Config.WinAction["WinActionDelay"] = Value
   end,
})

AUTOBOT:CreateToggle({
   Name = "Win Message Enabled",
   CurrentValue = false,
   Flag = "WinActionEnabled",
   Callback = function(Value)
       Config.WinACtion["WinActionEnabled"] = Value
   end,
})

local MISC = Window:CreateTab("Misc", 7734110220)

MISC:CreateSection"Troll"

MISC:CreateToggle({
   Name = "Freeze Ball",
   CurrentValue = false,
   Flag = "FreezeBall",
   Callback = function(Value)
       Config.Troll["FreezeBall"] = Value

       while Config.Troll["FreezeBall"] do
           Freeze:FireServer()
           wait(Config.Troll["FreezeDelay"])
       end

       Rayfield:Notify({
            Title = Value and "Freeze Ball is now Enabled!" or "Freeze Ball is now Disabled!",
            Content = Value and "Now the ball will be stunlocked!" or "Now the ball won't be stunlocked.",
            Duration = 4,
            Image = Value and "7733715400" or "7743878857"
       })
   end,
})

MISC:CreateSlider({
   Name = "Freeze Delay",
   Range = {0, 1},
   Increment = 0.05,
   Suffix = "Delay",
   CurrentValue = 1,
   Flag = "FreezeDelay",
   Callback = function(Value)
       Config.Troll["FreezeDelay"] = Value
   end,
})

MISC:CreateParagraph({Title = "DISCLAIMER", Content = "Freeze Ball needs \"Freeze\" Ability to work."})

MISC:CreateToggle({
   Name = "Bug Ball",
   CurrentValue = false,
   Flag = "BugBall",
   Callback = function(Value)
       Config.Troll["BugBall"] = Value

       Rayfield:Notify({
            Title = Value and "Bug Ball is now Enabled!" or "Bug Ball is now Disabled!",
            Content = Value and "Now the ball will be bugged" or "Now the ball won't be bugged.",
            Duration = 4,
            Image = Value and "7733715400" or "7743878857"
       })
   end,
})

MISC:CreateSection"Other"

MISC:CreateToggle({
   Name = "Infinite Jump",
   CurrentValue = false,
   Flag = "InfiniteJump",
   Callback = function(Value)
       Config.Other["InfiniteJump"] = Value

       Rayfield:Notify({
            Title = Value and "Infinite Jump is now Enabled!" or "Infinite Jump is now Disabled!",
            Content = Value and "Now you can Jump Infinitely!" or "Now you won't jump infinitely.",
            Duration = 4,
            Image = Value and "7733715400" or "7743878857"
       })
   end,
})

MISC:CreateToggle({
   Name = "Auto Clicker",
   CurrentValue = false,
   Flag = "AutoClick",
   Callback = function(Value)
       Config.Other["AutoClick"] = Value
       spawn(function()
       while Config.Other["AutoClick"] do
            Parry:Fire()
            RunService.Stepped:Wait()
       end
       end)
       Rayfield:Notify({
            Title = Value and "Auto Clicker is now Enabled!" or "Auto Clicker is now Disabled!",
            Content = Value and "Now you will start endlessly parry" or "Now you won't endlessly parry.",
            Duration = 4,
            Image = Value and "7733715400" or "7743878857"
       })
   end,
})
MISC:CreateInput({
   Name = "Spam Message",
   PlaceholderText = "haha you losers.",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
       Config.Other["ChatSpamMessage"] = Text
   end,
})

MISC:CreateSlider({
   Name = "Spam Delay",
   Range = {0, 3},
   Increment = 0.05,
   Suffix = "Delay",
   CurrentValue = 0.6,
   Flag = "ChatSpamDelay",
   Callback = function(Value)
       Config.Other["ChatSpamDelay"] = Value
   end,
})

local ChatSpamToggle = MISC:CreateToggle({
   Name = "Spam",
   CurrentValue = false,
   Flag = "ChatSpamEnabled",
   Callback = function(Value)
       Config.Other["ChatSpamEnabled"] = Value
       Rayfield:Notify({
            Title = Value and "Chat Spam is now Enabled!" or "Chat Spam is now Disabled!",
            Content = Value and "Now you will spam messages!" or "Now you won't spam messages.",
            Duration = 4,
            Image = Value and "7733715400" or "7743878857"
       })
        while Config.Other["ChatSpamEnabled"] do
            SayMessageRequest:FireServer(Config.Other["ChatSpamMessage"],"All")
            wait(Config.Other["ChatSpamDelay"])
       end
   end,
})
