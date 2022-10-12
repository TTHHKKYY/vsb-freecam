local Http = game:GetService("HttpService")

local Repository = "https://raw.githubusercontent.com/TTHHKKYY/vsb-freecam/master/src/"

local function Include(File)
	NS(Http:GetAsync(Repository .. File,true),workspace)
end

local function AddCSLuaFile(File)
	NLS(Http:GetAsync(Repository .. File,true),owner.PlayerGui)
end

Include("server.lua")
AddCSLuaFile("client.lua")
