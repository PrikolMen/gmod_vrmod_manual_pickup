-- aw, yes, it's called localisation, I don't mean translation but localisation of variables, it speeds up lua functions and some things a lot, so use it whenever you can, it won't make it worse
local hook_Add = hook.Add

-- I used this for hooks and other things like that
local addonName = 'VRMod Manual Pickup'

-- Server-side convar (it is not needed on the client)
local cvar = CreateConVar( 'vrmod_manual_pickup', 1, { FCVAR_ARCHIVE, FCVAR_REPLICATED }, '- Enables manual VRMod Pickup', 0, 1 )

do
	
	local table_Empty = table.Empty
	local istable = istable

	-- Reset the list of picked up entites on player spawn, this list is necessary because player has two hands (in theory could be even four or more), so we must save all discarded objects in it, so that no errors would happen
	hook_Add('PlayerSpawn', addonName, function( ply, trans )
		if istable( ply.VRModManualPickup ) then
			table_Empty( ply.VRModManualPickup )
		else
			ply.VRModManualPickup = {}
		end
	end)

end

do
	
	local timer_Simple = timer.Simple
	local IsValid = IsValid
	
	-- Called after the player has dropped an object in vr (entity and player are 100% valid here)
	hook_Add('VRMod_Drop', addonName, function( ply, ent )
		if cvar:GetBool() then
			if (ent:GetClass() == 'item_suit') then return end
			local index = ent:EntIndex()
			ply.VRModManualPickup[ index ] = true
	
			timer_Simple(0.25, function()
				if IsValid( ply ) then
					ply.VRModManualPickup[ index ] = nil
				end
			end)
		end
	end)

end

do
	
	local vrmod_IsPlayerInVR = vrmod.IsPlayerInVR

	-- Called after any player tries to pick up an item (an item like armor, health, ammo, etc.)
	hook_Add('PlayerCanPickupItem', addonName, function( ply, item )
		if vrmod_IsPlayerInVR( ply ) and ply:Alive() and cvar:GetBool() then
			local index = ent:EntIndex()
			if ply.VRModManualPickup[ index ] then
				ply.VRModManualPickup[ index ] = nil
				return
			end

			return false
		end
	end)

	-- Called when any player attempts to pick up any weapon
	hook_Add('PlayerCanPickupWeapon', addonName, function( ply, wep )
		if vrmod_IsPlayerInVR( ply ) and ply:Alive() and cvar:GetBool() then
			local index = ent:EntIndex()
			if ply.VRModManualPickup[ index ] then
				ply.VRModManualPickup[ index ] = nil
				return
			end

			return false
		end
	end)

end