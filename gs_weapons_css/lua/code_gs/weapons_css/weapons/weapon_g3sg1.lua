SWEP.Base = "weapon_csbase_autosniper"

SWEP.Spawnable = true

SWEP.ViewModel = "models/weapons/v_snip_g3sg1.mdl"
SWEP.CModel = "models/weapons/cstrike/c_snip_g3sg1.mdl"
SWEP.WorldModel = "models/weapons/w_snip_g3sg1.mdl"

SWEP.Sounds = {
	shoot = "Weapon_G3SG1.Single"
}

SWEP.Primary.Ammo = "762mm"
SWEP.Primary.ClipSize = 20
SWEP.Primary.DefaultClip = 110
SWEP.Primary.Damage = 80
SWEP.Primary.Spread = Vector(0.055, 0.055)
SWEP.Primary.SpreadCrouch = Vector(0.035, 0.035)

SWEP.Penetration = 3

SWEP.Accuracy = {
	Additive = 0.55,
	Time = 0.3
}

SWEP.PunchRand = {
	Name = "G3SG1",
	XMin = 0.75,
	XMax = 1.75
}

if (CLIENT) then
	SWEP.KillIcon = 'i'
	SWEP.SelectionIcon = 'i'
	
	SWEP.CSSCrosshair = {
		Min = 6,
		Delta = 4
	}
	
	SWEP.MuzzleFlashScale = 1.5
end
