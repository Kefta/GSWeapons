DEFINE_BASECLASS( "weapon_basecsgrenade" )

--- GSBase
SWEP.PrintName = "#CStrike_HEGrenade"
SWEP.Spawnable = true

SWEP.ViewModel = "models/weapons/v_eq_fraggrenade.mdl"
SWEP.WorldModel = "models/weapons/w_eq_fraggrenade.mdl"

SWEP.Primary.Ammo = "HEGrenade"

if ( SERVER ) then
	SWEP.Grenade = {
		Class = "hegrenade_projectile",
		Radius = 350
	}
else
	SWEP.Category = "Counter-Strike: Source"
	SWEP.SelectionIcon = 'h'
	
	SWEP.CSSCrosshair = {
		Min = 8
	}
end
