local DEFAULT_PED <const> = 'mp_m_freemode_01'

local FREEMODE_GENDERS <const> = {
  mp_m_freemode_01 = 'm',
  mp_f_freemode_01 = 'f',
}

--- Swaps the player to a ped model and restores the staging transform
--- the model change resets.
---@param model string The ped model name.
---@param staging vector4 Where the ped belongs.
---@return number ped The restaged ped handle.
local function applyModel(model, staging)
  local modelHash <const> = Siku.streaming.requestModel(model)

  SetPlayerModel(PlayerId(), modelHash)
  SetModelAsNoLongerNeeded(modelHash)

  local ped <const> = PlayerPedId()

  SetEntityCoords(ped, staging.x, staging.y, staging.z, false, false, false, true)
  SetEntityHeading(ped, staging.w)
  FreezeEntityPosition(ped, true)
  SetEntityInvincible(ped, true)
  SetPlayerControl(PlayerId(), false, 0)

  return ped
end

--- Dresses the player ped with a saved character look, or with the
--- configured default one when no appearance was saved.
---@param model string|nil The ped model name, defaulting to the male freemode.
---@param appearance table|nil The saved appearance { heritage, physical, clothing, accessories, tattoos }.
---@param staging vector4 Where the ped belongs.
---@return number ped The dressed ped handle.
function ApplyCharacterLook(model, appearance, staging)
  local pedModel <const> = model and model ~= '' and model or DEFAULT_PED
  local ped <const> = applyModel(pedModel, staging)
  local gender <const> = FREEMODE_GENDERS[pedModel]

  if type(appearance) ~= 'table' then
    if gender then
      ApplyDefaultCharacter(ped, gender)
    end

    return ped
  end

  if gender then
    ApplyDefaultCharacter(ped, gender)
  end

  ApplyHeritage(appearance.heritage)
  ApplyPhysical(appearance.physical)
  ApplyClothing(appearance.clothing)
  ApplyAccessories(appearance.accessories)
  ApplyTattoos(appearance.tattoos)

  return ped
end
