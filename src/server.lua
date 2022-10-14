local LocalPlayer = owner

local function GetObject(Parent,Name,Class)
	local Object = Parent:FindFirstChild(Name)
	
	if Object then
		Object:Destroy()
	end
	
	Object = Instance.new(Class)
	Object.Name = Name
	Object.Parent = Parent
	
	return Object
end

local GetModel = GetObject(LocalPlayer,"GetCameraModel","RemoteFunction")
local UpdateModel = GetObject(LocalPlayer,"UpdateCameraModel","RemoteEvent")
local UpdateFov = GetObject(LocalPlayer,"UpdateModelFieldOfView","RemoteEvent")
local AddMessage = GetObject(LocalPlayer,"ModelAddMessage","RemoteEvent")

local Model
local ModelExists = false

function GetModel.OnServerInvoke(Player)
	if Player == LocalPlayer then
		if ModelExists then
			return Model
		end
		
		Model = Instance.new("Model")
		
		local Head = Instance.new("Part")
		
		Head.Name = "Head"
		Head.Locked = true
		Head.Anchored = true
		--Head.CanCollide = false
		Head.Size = Vector3.new(2,2,2)
		Head.TopSurface = Enum.SurfaceType.Smooth
		Head.BottomSurface = Enum.SurfaceType.Smooth
		Head.Parent = Model
		
		local Face = Instance.new("Part")
		
		Face.Name = "Face"
		Face.Locked = true
		Face.Anchored = true
		--Face.CanCollide = false
		Face.Size = Vector3.new(2,1,1)
		Face.Rotation = Vector3.new(90,0,90)
		Face.Position = Vector3.new(0,0,-0.1)
		Face.BrickColor = BrickColor.new("Dark stone grey")
		Face.Shape = Enum.PartType.Cylinder
		Face.TopSurface = Enum.SurfaceType.Smooth
		Face.BottomSurface = Enum.SurfaceType.Smooth
		Face.Parent = Model
		
		local Tag = Instance.new("BillboardGui")
		
		Tag.Name = "NameTag"
		Tag.ResetOnSpawn = false
		Tag.MaxDistance = 120
		Tag.Size = UDim2.new(4,0,1,0)
		Tag.StudsOffset = Vector3.new(0,2,0)
		Tag.Adornee = Head
		Tag.Parent = Model
		
		local Label = Instance.new("TextLabel")
		
		Label.Name = "Label"
		Label.BackgroundTransparency = 1
		Label.TextStrokeTransparency = 0
		Label.Size = UDim2.new(1,0,1,0)
		Label.TextColor3 = Color3.new(1,1,1)
		Label.TextStrokeColor3 = Color3.new(0,0,0)
		Label.Text = LocalPlayer.Name
		Label.Parent = Tag
		
		local Chat = Instance.new("BillboardGui")
		
		Chat.Name = "ChatHistory"
		Chat.ResetOnSpawn = false
		Chat.MaxDistance = 120
		Chat.Size = UDim2.new(4,0,15,0)
		Chat.StudsOffset = Vector3.new(0,10,0)
		Chat.Adornee = Head
		Chat.Parent = Model
		
		local ChatLayout = Instance.new("UIListLayout")
		
		ChatLayout.Name = "Layout"
		ChatLayout.FillDirection = Enum.FillDirection.Vertical
		ChatLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
		ChatLayout.Parent = Chat
		
		Model.Destroying:Connect(function()
			ModelExists = false
		end)
		
		ModelExists = true
		
		Model.PrimaryPart = Head
		Model.Parent = workspace
		
		return Model
	end
end

UpdateModel.OnServerEvent:Connect(function(Player,CFrame)
	if Player == LocalPlayer and ModelExists then
		Model:SetPrimaryPartCFrame(CFrame)
	end
end)

UpdateFov.OnServerEvent:Connect(function(Player,Fov)
	if Player == LocalPlayer and ModelExists then
		local Aperture = (Fov - 70) / 120
		
		Model.Face.Size = Vector3.new(2,1 + Aperture,1 + Aperture)
	end
end)

AddMessage.OnServerEvent:Connect(function(Player,Text)
	if Player == LocalPlayer and ModelExists then
		local Label = Instance.new("TextLabel")
		
		Label.BackgroundTransparency = 1
		Label.TextStrokeTransparency = 0
		Label.Size = UDim2.new(1,0,0,25)
		Label.TextColor3 = Color3.new(1,1,1)
		Label.TextStrokeColor3 = Color3.new(0,0,0)
		Label.Text = Text
		Label.Parent = Model.ChatHistory
		
		task.wait(5)
		
		for i=1,100 do
			Label.TextTransparency = i / 100
			task.wait()
		end
		
		Label:Destroy()
	end
end)
