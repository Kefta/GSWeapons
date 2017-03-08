-- This is the only machine gun in CS:S. It spreads like a rifle but kicks like an SMG
SWEP.Base = "weapon_csbase_rifle"

SWEP.Spawnable = true

SWEP.ViewModel = "models/weapons/v_mach_m249para.mdl"
SWEP.CModel = "models/weapons/cstrike/c_mach_m249para.mdl"
SWEP.WorldModel = "models/weapons/w_mach_m249para.mdl"

SWEP.Sounds = {
	shoot = "Weapon_M249.Single"
}

SWEP.Primary.Ammo = "556mm_Box"
SWEP.Primary.ClipSize = 100
SWEP.Primary.DefaultClip = 300
SWEP.Primary.Cooldown = 0.08
SWEP.Primary.Damage = 35
SWEP.Primary.Range = 8192
SWEP.Primary.RangeModifier = 0.97
SWEP.Primary.Spread = Vector(0.03, 0.03)
SWEP.Primary.SpreadAir = Vector(0.5, 0.5)
SWEP.Primary.SpreadMove = Vector(0.095, 0.095)
SWEP.Primary.SpreadAdditive = Vector(0.045, 0.045)

SWEP.WalkSpeed = 220/250

SWEP.Accuracy = {
	Divisor = 175,
	Offset = 0.4,
	Max = 0.9
}

SWEP.Kick = {
	Air = {
		UpBase = 1.8,
		LateralBase = 0.65,
		UpModifier = 0.45,
		LateralModifier = 0.125,
		UpMax = 5,
		LateralMax = 3.5,
		DirectionChange = 8
	},
	Move = {
		UpBase = 1.1,
		LateralBase = 0.5,
		UpModifier = 0.3,
		LateralModifier = 0.06,
		UpMax = 4,
		LateralMax = 3,
		DirectionChange = 8
	},
	Crouch = {
		UpBase = 0.75,
		LateralBase = 0.325,
		UpModifier = 0.25,
		LateralModifier = 0.025,
		UpMax = 3.5,
		LateralMax = 2.5,
		DirectionChange = 9
	},
	Base = {
		UpBase = 0.8,
		LateralBase = 0.35,
		UpModifier = 0.3,
		LateralModifier = 0.03,
		UpMax = 3.75,
		LateralMax = 3,
		DirectionChange = 9
	}
}

if (CLIENT) then
	SWEP.KillIcon = 'z'
	SWEP.SelectionIcon = 'z'
	
	SWEP.ViewModelFlip = false
	
	SWEP.CSSCrosshair = {
		Min = 6
	}
	
	SWEP.MuzzleFlashScale = 1.5
end

// GOOSEMAN : Kick the view..
function SWEP:Punch(bSecondary --[[= false]], iIndex --[[= 0]])
	local pPlayer = self:GetOwner()
	local tKick = self.Kick
	
	// Kick the gun based on the state of the player.
	-- Ground first, speed second
	if (not pPlayer:OnGround()) then
		tKick = tKick.Air
	elseif (pPlayer:_GetAbsVelocity():Length2DSqr() > (pPlayer:GetWalkSpeed() * tKick.Speed) ^ 2) then
		tKick = tKick.Move
	elseif (pPlayer:Crouching()) then
		tKick = tKick.Crouch
	else
		tKick = tKick.Base
	end
	
	local iShotsFired = self:GetShotsFired(iIndex)
	local aPunch = pPlayer:GetViewPunchAngles()
	
	aPunch[1] = aPunch[1] - (tKick.UpBase + iShotsFired * tKick.UpModifier)
	local flUpMin = -tKick.UpMax
	
	if (aPunch[1] < flUpMin) then
		aPunch[1] = flUpMin
	end
	
	local bDirection = code_gs.weapons.GetNWVar(pPlayer, "Bool", "PunchDirection")
	
	if (bDirection) then
		aPunch[2] = aPunch[2] + (tKick.LateralBase + iShotsFired * tKick.LateralModifier)
		local flLateralMax = tKick.LateralMax
		
		if (aPunch[2] > flLateralMax) then
			aPunch[2] = flLateralMax
		end
	else
		aPunch[2] = aPunch[2] - (tKick.LateralBase + iShotsFired * tKick.LateralModifier)
		local flLateralMin = -tKick.LateralMax
		
		if (aPunch[2] < flLateralMin) then
			aPunch[2] = flLateralMin
		end
	end
	
	if (code_gs.random:SharedRandomInt(pPlayer, "KickBack", 0, tKick.DirectionChange) == 0) then
		code_gs.weapons.SetNWVar(pPlayer, "Bool", "PunchDirection", not bDirection)
	end
	
	pPlayer:SetViewPunchAngles(aPunch)
end
