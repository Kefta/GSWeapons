AddCSLuaFile()
DEFINE_BASECLASS( "basecsgrenade" )

--- GSBase
ENT.PrintName = "#CStrike_HEGrenade"
ENT.Model = "models/weapons/w_eq_fraggrenade_thrown.mdl"

if ( CLIENT ) then
	ENT.KillIcon = 'h'
end
