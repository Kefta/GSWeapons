include("shared.lua")

ENT.Category = "GS Source"

net.Receive("GS-Weapons-Detonate", function()
	local pGrenade = net.ReadEntity()
	
	if (pGrenade:IsValid()) then
		pGrenade:Detonate()
	end
end)
