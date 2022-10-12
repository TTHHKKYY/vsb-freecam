local UserInput = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = owner

local GetModel = LocalPlayer.GetCameraModel
local UpdateModel = LocalPlayer.UpdateCameraModel
local UpdateFov = LocalPlayer.UpdateModelFieldOfView

local Camera = workspace.CurrentCamera
local CameraAngle = {x = 0,y = 0}
local CameraPosition = Vector3.new()

local MoveSpeed = 50
local Fov = 70

local LastFov = 0

local function GetCameraCFrame()
	return CFrame.fromEulerAnglesYXZ(math.rad(CameraAngle.y),math.rad(CameraAngle.x),0) + CameraPosition
end

local function GetMoveVector()
	local Vector = Vector3.new()
	
	if not UserInput:GetFocusedTextBox() then
		if UserInput:IsKeyDown(Enum.KeyCode.W) then
			Vector = Vector + Camera.CFrame.LookVector
		end
		if UserInput:IsKeyDown(Enum.KeyCode.A) then
			Vector = Vector - Camera.CFrame.RightVector
		end
		if UserInput:IsKeyDown(Enum.KeyCode.S) then
			Vector = Vector - Camera.CFrame.LookVector
		end
		if UserInput:IsKeyDown(Enum.KeyCode.D) then
			Vector = Vector + Camera.CFrame.RightVector
		end
		if UserInput:IsKeyDown(Enum.KeyCode.E) then
			Vector = Vector + Camera.CFrame.UpVector
		end
		if UserInput:IsKeyDown(Enum.KeyCode.Q) then
			Vector = Vector - Camera.CFrame.UpVector
		end
	end
	
	return Vector
end

local function LockCharacter(Locked)
	if LocalPlayer.Character then
		LocalPlayer.Character.PrimaryPart.Anchored = Locked
	end
end

local Model
local ModelExists = false
local ModelGetting = false

local function HideModel(Hidden)
	if ModelExists then
		Model.Head.LocalTransparencyModifier = Hidden and 1 or 0
		Model.Face.LocalTransparencyModifier = Hidden and 1 or 0
		Model.NameTag.PlayerToHideFrom = Hidden and LocalPlayer or nil
	end
end

local function CameraStep(RenderTime)
	local Delta = UserInput:GetMouseDelta() * (Fov / 360)
	
	CameraAngle.x = (CameraAngle.x - Delta.x) % 360
	CameraAngle.y = math.clamp(CameraAngle.y - Delta.y,-90,90)
	
	local Target = GetCameraCFrame()
	
	Camera.CFrame = Target
	Camera.Focus = Target
	Camera.FieldOfView = Fov
	
	CameraPosition = CameraPosition + GetMoveVector() * RenderTime * MoveSpeed
	
	if (not Model or not ModelExists) and not ModelGetting then
		ModelGetting = true
		Model = GetModel:InvokeServer()
		
		Model.Destroying:Connect(function()
			ModelExists = false
		end)
		
		ModelExists = true
		ModelGetting = false
		
		RunService.Heartbeat:Wait()
		
		HideModel(true)
	end
	
	UpdateModel:FireServer(Target * CFrame.new(0,0,1))
end

UserInput.InputChanged:Connect(function(Input,Focused)
	if not Focused then
		if Input.UserInputType == Enum.UserInputType.MouseWheel then
			if Input:IsModifierKeyDown(Enum.ModifierKey.Alt) then
				Fov = math.clamp(Fov - (Input.Position.z * 10),1,120)
				UpdateFov:FireServer(Fov)
			else
				MoveSpeed = math.clamp(MoveSpeed + (Input.Position.z * 5),5,500)
			end
		end
	end
end)

local Enabled = false
local Connection

UserInput.InputBegan:Connect(function(Input,Focused)
	if not Focused then
		if Input.KeyCode == Enum.KeyCode.F then
			Enabled = not Enabled
			
			if Enabled then
				HideModel(true)
				LockCharacter(true)
				
				LastFov = Camera.FieldOfView
				Connection = RunService.RenderStepped:Connect(CameraStep)
			else
				Connection:Disconnect()
				HideModel(false)
				LockCharacter(false)
				
				Camera.FieldOfView = LastFov
			end
		end
	end
end)
