SWEP.Base = "weapon_csbase_sniper"

SWEP.Spawnable = true

SWEP.ViewModel = "models/weapons/v_snip_scout.mdl"
SWEP.CModel = "models/weapons/cstrike/c_snip_scout.mdl"
SWEP.WorldModel = "models/weapons/w_snip_scout.mdl"

SWEP.Sounds = {
	shoot = "Weapon_Scout.Single"
}

SWEP.Primary.Ammo = "762mm"
SWEP.Primary.DefaultClip = 100
SWEP.Primary.Cooldown = 1.25
SWEP.Primary.Damage = 75
SWEP.Primary.Spread = Vector(0.007, 0.007)
SWEP.Primary.SpreadAir = Vector(0.2, 0.2)
SWEP.Primary.SpreadSprint = Vector(0.075, 0.075)
SWEP.Primary.SpreadMove = Vector(0.075, 0.075)

local vSpreadAdditive = Vector(0.025, 0.025)
SWEP.Primary.SpreadAdditive = function(self)
	return self:GetZoomLevel() == 0 and vSpreadAdditive or vector_origin
end

SWEP.WalkSpeed = 260/250

SWEP.Zoom = {
	FOV = {
		[2] = 15
	},
	Times = {
		Fire = 0.05,
		[0] = 0.05,
		[2] = 0.05
	}
}

SWEP.Accuracy = {
	Sprint = 170/250,
	Speed = 170/250
}

if (CLIENT) then
	SWEP.KillIcon = 'n'
	SWEP.SelectionIcon = 'n'
	
	SWEP.CSSCrosshair = {
		Min = 5
	}
	
	SWEP.MuzzleFlashScale = 1.1
end

function SWEP:GetWalkSpeed()
	return self.WalkSpeed * (self:GetZoomLevel() == 0 and 1 or 11/13)
end
