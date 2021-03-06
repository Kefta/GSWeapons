if (SERVER) then
	local tSkillConVars = {}

	local function UpdateSkillConVars(iLevel)
		for sVar, tVal in pairs(tSkillConVars) do
			local Val = tVal[iLevel]

			while (Val == nil and iLevel ~= 0) do
				iLevel = iLevel - 1
				Val = tVal[iLevel]
			end

			if (Val ~= nil) then
				RunConsoleCommand(sVar, tostring(Val))
			end
		end
	end

	local fSetSkillLevel = game.SetSkillLevel

	function game.SetSkillLevel(iLevel)
		UpdateSkillConVars(iLevel)
		fSetSkillLevel(iLevel)
	end

	function game.RegisterSkillConVar(sConVar, ...)
		tSkillConVars[sConVar] = {...}
	end

	hook.Add("InitPostEntity", "GSLib-Update skill convars", function()
		UpdateSkillConVars(game.GetSkillLevel())
	end)
end

local iCurPower = 2

function game.AddCustomDamageType(sName)
	_G["DMG_" .. sName:upper()] = bit.lshift(DMG_BUCKSHOT, iCurPower)
	
	iCurPower = iCurPower + 1
end

-- Counter-Strike: Source damage flag
game.AddCustomDamageType("HEADSHOT")

-- Day of Defeat: Source damage flags
game.AddCustomDamageType("MACHINEGUN")
game.AddCustomDamageType("BOMB")

---------------------------------------------


-- Half-Life 2 damage types
DMG_SNIPER = bit.lshift( DMG_BUCKSHOT, 1 )
DMG_MISSILEDEFENSE = bit.lshift( DMG_BUCKSHOT, 2 ) // The only kind of damage missiles take. (special missile defense)

-- Ammo flags
AMMO_FORCE_DROP_IF_CARRIED = 0x1
AMMO_INTERPRET_PLRDAMAGE_AS_DAMAGE_TO_PLAYER = 0x2

--[[
	Called by modders to add a new ammo type.
	Ammo types aren't something you can add on the fly. You have one
 	opportunity during loadtime. The ammo types should also be IDENTICAL on 
 	server and client. 
 	If they're not you will receive errors and maybe even crashes.

		game.AddAmmoType({
			name		=	"customammo",
			displayname	=	"Custom Ammo",
			dmgtype		=	DMG_BULLET,
			tracer		=	TRACER_LINE_AND_WHIZ,
			plydmg		=	20,
			npcdmg		=	20,
			force		=	100,
			minsplash	=	10,
			maxsplash	=	100,
			maxcarry	=	9999,
			flags		=	0
	})
]]

local AmmoTypes = {}
local AmmoNames = {}
--local HasBuilt = false

function game.AddAmmoType( ammo )
	if ( not ammo.name ) then
		MsgN( "Ammo attempted to be registered with no name!" )
	--[[elseif ( HasBuilt ) then
		MsgN( "BuildAmmoTypes already called! Ammo type \"" .. (ammo.name or "No Name") .. "\" will not be registered" )]]
	else
		local name = ammo.name:lower()
		
		if ( isstring( ammo.plydmg ) ) then
			ammo.plydmg_convar = ammo.plydmg
			ammo.plydmg = GetConVarNumber( ammo.plydmg )
		end
		
		if ( isstring( ammo.npcdmg ) ) then
			ammo.npcdmg_convar = ammo.npcdmg
			ammo.npcdmg = GetConVarNumber( ammo.npcdmg )
		end
		
		if ( isstring( ammo.maxcarry ) ) then
			ammo.maxcarry_convar = ammo.maxcarry
			ammo.maxcarry = GetConVarNumber( ammo.maxcarry )
		end
		
		if ( CLIENT and ammo.displayname ) then
			language.Add( ammo.name .. "_ammo", ammo.displayname )
		end
		
		if ( AmmoNames[ name ] ) then
			MsgN( "Ammo \"" .. name .. "\" registered twice; giving priority to later registration" )
			ammo._id = AmmoNames[ name ]._id or #AmmoTypes + 1
			AmmoTypes[ ammo._id ] = ammo
			AmmoNames[ name ] = ammo
		else
			local i = #AmmoTypes + 1
			ammo._id = i
			AmmoTypes[ i ] = ammo
			AmmoNames[ name ] = ammo
		end
	end
end

-- Called by the engine to retrieve the ammo types
-- You should never have to call this manually
function game.BuildAmmoTypes()
	-- Sort the table by name here to assure that the ammo types
	-- are inserted in the same order on both server and client
	--HasBuilt = true
	table.SortByMember( AmmoTypes, "name" )
	
	return AmmoTypes
end

function game.GetAmmoTable()
	return table.Copy( AmmoTypes )
end

function game.GetAmmoDamageType( ammo )
	ammo = ammo:lower()
	return AmmoNames[ ammo ] and (AmmoNames[ ammo ].dmgtype or DMG_BULLET) or 0
end

function game.GetAmmoFlags( ammo )
	ammo = ammo:lower()
	return AmmoNames[ ammo ] and AmmoNames[ ammo ].flags or 0
end

function game.GetAmmoForce( ammo )
	ammo = ammo:lower()
	return AmmoNames[ ammo ] and (AmmoNames[ ammo ].force or 1000) or 0
end

function game.GetAmmoMaxCarry( ammo )
	local ammotype = AmmoNames[ ammo:lower() ]
	
	if ( ammotype ) then
		return ammotype.maxcarry_convar and GetConVarNumber( ammotype.maxcarry_convar ) or ammotype.maxcarry or 9999
	end
	
	return 0
end

function game.GetAmmoMaxSplash( ammo )
	ammo = ammo:lower()
	return AmmoNames[ ammo ] and AmmoNames[ ammo ].maxsplash or 0
end

function game.GetAmmoMinSplash( ammo )
	ammo = ammo:lower()
	return AmmoNames[ ammo ] and AmmoNames[ ammo ].minsplash or 0
end

function game.GetAmmoNPCDamage( ammo )
	local ammotype = AmmoNames[ ammo:lower() ]
	
	if ( ammotype ) then
		return ammotype.npcdmg_convar and GetConVarNumber( ammotype.npcdmg_convar ) or ammotype.npcdmg or 10
	end
	
	return 0
end

function game.GetAmmoPlayerDamage( ammo )
	local ammotype = AmmoNames[ ammo:lower() ]
	
	if ( ammotype ) then
		return ammotype.plydmg_convar and GetConVarNumber( ammotype.plydmg_convar ) or ammotype.plydmg or 10
	end
	
	return 0
end

function game.GetAmmoTracerType( ammo )
	ammo = ammo:lower()
	return AmmoNames[ ammo ] and AmmoNames[ ammo ].tracer or TRACER_NONE
end

-- For custom ammo keys!
function game.GetAmmoKey( ammo, key, default )
	ammo = ammo:lower()
	
	if ( AmmoNames[ ammo ] and AmmoNames[ ammo ][ key ] ~= nil ) then
		return AmmoNames[ ammo ][ key ]
	end
	
	return default
end

local function AddDefaulammotypeType( name, damagetype, tracer, plydmg, npcdmg, maxcarry, force, flags, minsplash, maxsplash )
	local tbl = {
		dmgtype = damagetype,
		tracer = tracer,
		maxcarry = maxcarry,
		force = force,
		flags = flags,
		minsplash = minsplash or 4,
		maxsplash = maxsplash or 8
	}
	
	if ( isstring( plydmg ) ) then
		tbl.plydmg_convar = plydmg
	else
		tbl.plydmg = plydmg
	end
	
	if ( isstring( npcdmg ) ) then
		tbl.npcdmg_convar = npcdmg
	else
		tbl.npcdmg = npcdmg
	end
	
	if ( isstring( maxcarry ) ) then
		tbl.maxcarry_convar = maxcarry
	else
		tbl.maxcarry = maxcarry
	end
	
	AmmoNames[ name:lower() ] = tbl
end

local function BulletImpulse( grains, ftpersec, impulse )
	return ftpersec * 12 * 0.002285 * (grains / 16) * (1/2.2) * impulse
end

-- Half-Life 2/Deathmatch/Portal ammo types
AddDefaulammotypeType("AR2",DMG_BULLET,TRACER_LINE_AND_WHIZ,"sk_plr_dmg_ar2","sk_npc_dmg_ar2","sk_max_ar2",BulletImpulse(200,1225,3.5),0)
AddDefaulammotypeType("AR2shoot2",DMG_DISSOLVE,TRACER_NONE,0,0,"sk_max_ar2_shoot2",0,0)
AddDefaulammotypeType("Pistol",DMG_BULLET,TRACER_LINE_AND_WHIZ,"sk_plr_dmg_pistol","sk_npc_dmg_pistol","sk_max_pistol",BulletImpulse(200,1225,3.5),0)
AddDefaulammotypeType("SMG1",DMG_BULLET,TRACER_LINE_AND_WHIZ,"sk_plr_dmg_smg1","sk_npc_dmg_smg1","sk_max_smg1",BulletImpulse(200,1225,3.5),0)
AddDefaulammotypeType("357",DMG_BULLET,TRACER_LINE_AND_WHIZ,"sk_plr_dmg_357","sk_npc_dmg_357","sk_max_357",BulletImpulse(800,5000,3.5),0)
AddDefaulammotypeType("XBowBolt",DMG_BULLET,TRACER_LINE,"sk_plr_dmg_crossbow","sk_npc_dmg_crossbow","sk_max_crossbow",BulletImpulse(800,8000,3.5),0)
AddDefaulammotypeType("Buckshot",bit.bor(DMG_BULLET,DMG_BUCKSHOT),TRACER_LINE,"sk_plr_dmg_buckshot","sk_npc_dmg_buckshot","sk_max_buckshot",BulletImpulse(400,1200,3.5),0)
AddDefaulammotypeType("RPG_Round",DMG_BURN,TRACER_NONE,"sk_plr_dmg_rpg_round","sk_npc_dmg_rpg_round","sk_max_rpg_round",0,0)
AddDefaulammotypeType("SMG1_Grenade",DMG_BURN,TRACER_NONE,"sk_plr_dmg_smg1_grenade","sk_npc_dmg_smg1_grenade","sk_max_smg1_grenade",0,0)
AddDefaulammotypeType("Grenade",DMG_BURN,TRACER_NONE,"sk_plr_dmg_grenade","sk_npc_dmg_grenade","sk_max_grenade",0,0)
AddDefaulammotypeType("slam",DMG_BURN,TRACER_NONE,0,0,5,0,0)

-- Half-Life 2/Portal ammo types
AddDefaulammotypeType("AlyxGun",DMG_BULLET,TRACER_LINE,"sk_plr_dmg_alyxgun","sk_npc_dmg_alyxgun","sk_max_alyxgun",BulletImpulse(200,1225,3.5),0)
AddDefaulammotypeType("SniperRound",bit.bor(DMG_BULLET,DMG_SNIPER),TRACER_NONE,"sk_plr_dmg_sniper_round","sk_npc_dmg_sniper_round","sk_max_sniper_round",BulletImpulse(650,6000,3.5),0)
AddDefaulammotypeType("SniperPenetratedRound",bit.bor(DMG_BULLET,DMG_SNIPER),TRACER_NONE,"sk_dmg_sniper_penetrate_plr","sk_dmg_sniper_penetrate_npc","sk_max_sniper_round",BulletImpulse(150,6000,3.5),0)
AddDefaulammotypeType("Thumper",DMG_SONIC,TRACER_NONE,10,10,2,0,0)
AddDefaulammotypeType("Gravity",DMG_CLUB,TRACER_NONE,0,0,8,0,0)
AddDefaulammotypeType("Battery",DMG_CLUB,TRACER_NONE,0,0,0,0,0)
AddDefaulammotypeType("GaussEnergy",DMG_SHOCK,TRACER_NONE,"sk_jeep_gauss_damage","sk_jeep_gauss_damage","sk_max_gauss_round",BulletImpulse(650,8000,3.5),0) // hit like a 10kg weight at 750 ft/s
AddDefaulammotypeType("CombineCannon",DMG_BULLET,TRACER_LINE,"sk_npc_dmg_gunship_to_plr","sk_npc_dmg_gunship",0,1.5*750*12,0) // hit like a 1.5kg weight at 750 ft/s
AddDefaulammotypeType("AirboatGun",DMG_AIRBOAT,TRACER_LINE,"sk_plr_dmg_airboat","sk_npc_dmg_airboat",0,BulletImpulse(10,600,3.5),0)

//=====================================================================
// STRIDER MINIGUN DAMAGE - Pull up a chair and I'll tell you a tale.
//
// When we shipped Half-Life 2 in 2004, we were unaware of a bug in
// CAmmoDef::NPCDamage() which was returning the MaxCarry field of
// an ammotype as the amount of damage that should be done to a NPC
// by that type of ammo. Thankfully, the bug only affected Ammo Types 
// that DO NOT use ConVars to specify their parameters. As you can see,
// all of the important AmmoTypes use ConVars, so the effect of the bug
// was limited. The Strider Minigun was affected, though.
//
// According to my perforce Archeology, we intended to ship the Strider
// Minigun ammo type to do 15 points of damage per shot, and we did. 
// To achieve this we, unaware of the bug, set the Strider Minigun ammo 
// type to have a maxcarry of 15, since our observation was that the 
// number that was there before (8) was indeed the amount of damage being
// done to NPC's at the time. So we changed the field that was incorrectly
// being used as the NPC Damage field.
//
// The bug was fixed during Episode 1's development. The result of the 
// bug fix was that the Strider was reduced to doing 5 points of damage
// to NPC's, since 5 is the value that was being assigned as NPC damage
// even though the code was returning 15 up to that point.
//
// Now as we go to ship Orange Box, we discover that the Striders in 
// Half-Life 2 are hugely ineffective against citizens, causing big
// problems in maps 12 and 13. 
//
// In order to restore balance to HL2 without upsetting the delicate 
// balance of ep2_outland_12, I have chosen to build Episodic binaries
// with 5 as the Strider->NPC damage, since that's the value that has
// been in place for all of Episode 2's development. Half-Life 2 will
// build with 15 as the Strider->NPC damage, which is how HL2 shipped
// originally, only this time the 15 is located in the correct field
// now that the AmmoDef code is behaving correctly.
//
//=====================================================================
--AddDefaulammotypeType("StriderMinigun",DMG_BULLET,TRACER_LINE,5,5,15,1*750*12,AMMO_FORCE_DROP_IF_CARRIED) // hit like a 1kg weight at 750 ft/s
AddDefaulammotypeType("StriderMinigun",DMG_BULLET,TRACER_LINE,5,15,15,1*750*12,AMMO_FORCE_DROP_IF_CARRIED) // hit like a 1kg weight at 750 ft/s
AddDefaulammotypeType("HelicopterGun",DMG_BULLET,TRACER_LINE_AND_WHIZ,"sk_npc_dmg_helicopter_to_plr","sk_npc_dmg_helicopter","sk_max_smg1",BulletImpulse(400,1225,3.5),bit.bor(AMMO_FORCE_DROP_IF_CARRIED,AMMO_INTERPRET_PLRDAMAGE_AS_DAMAGE_TO_PLAYER))

-- Half-Life 1 ammo types
AddDefaulammotypeType("9mmRound",bit.bor(DMG_BULLET,DMG_NEVERGIB),TRACER_LINE,0,0,0,BulletImpulse(500,1325,3),0)
AddDefaulammotypeType("MP5_Grenade",bit.bor(DMG_BURN,DMG_BLAST),TRACER_NONE,0,0,0,0,0)
AddDefaulammotypeType("Hornet",DMG_BULLET,TRACER_NONE,0,0,0,BulletImpulse(100,1200,3),0)

-- One more Half-Life 2 ammo type
AddDefaulammotypeType("StriderMinigunDirect",DMG_BULLET,TRACER_LINE,2,2,15,1*750*12,AMMO_FORCE_DROP_IF_CARRIED) // hit like a 1kg weight at 750 ft/s

-- Half-Life 2: Episodic ammo type
AddDefaulammotypeType("CombineHeavyCannon",DMG_BULLET,TRACER_LINE,40,40,0,10*750*12,AMMO_FORCE_DROP_IF_CARRIED) // hit like a 10kg weight at 750 ft/s
