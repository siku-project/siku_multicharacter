local FEMALE_MODEL <const> = joaat('mp_f_freemode_01')

local ZONE_SLOTS <const> = {
  { key = 'hair', zone = 'ZONE_HAIR' },
  { key = 'head', zone = 'ZONE_HEAD' },
  { key = 'neck', zone = 'ZONE_HEAD' },
  { key = 'torso', zone = 'ZONE_TORSO' },
  { key = 'back', zone = 'ZONE_TORSO' },
  { key = 'leftArm', zone = 'ZONE_LEFT_ARM' },
  { key = 'rightArm', zone = 'ZONE_RIGHT_ARM' },
  { key = 'leftLeg', zone = 'ZONE_LEFT_LEG' },
  { key = 'rightLeg', zone = 'ZONE_RIGHT_LEG' },
}

local catalogues = {}

--- Builds the tattoos of a zone available for a gender, skipping the
--- ones the config leaves empty for it.
---@param zone string The tattoo zone name.
---@param gender string 'm' for male, 'f' for female.
---@return table tattoos The available tattoos, each { collection, hash }.
local function buildZoneCatalogue(zone, gender)
  local source <const> = TattooConfig[zone] or {}
  local tattoos <const> = {}

  for i = 1, #source do
    local tattoo <const> = source[i]
    local hash <const> = gender == 'f' and tattoo.hashFemale or tattoo.hashMale

    if hash and hash ~= '' then
      tattoos[#tattoos + 1] = { collection = tattoo.collection, hash = hash }
    end
  end

  return tattoos
end

--- Gets the tattoo catalogue of a gender, building it on first use.
---@param gender string 'm' for male, 'f' for female.
---@return table catalogue The tattoos indexed by slot key.
local function getCatalogue(gender)
  if catalogues[gender] then
    return catalogues[gender]
  end

  local catalogue <const> = {}

  for i = 1, #ZONE_SLOTS do
    local slot <const> = ZONE_SLOTS[i]
    catalogue[slot.key] = buildZoneCatalogue(slot.zone, gender)
  end

  catalogues[gender] = catalogue

  return catalogue
end

--- Gets the gender a ped model draws its tattoos from.
---@param ped number The ped handle.
---@return string gender 'm' for male, 'f' for female.
local function getGender(ped)
  return GetEntityModel(ped) == FEMALE_MODEL and 'f' or 'm'
end

--- Sends the tattoo counts of the current ped to the NUI. Counts come
--- from the config, filtered by gender, and reserve their first slider
--- value for "none".
---@param ped number The ped handle.
---@return nil
function SendTattooLimits(ped)
  local catalogue <const> = getCatalogue(getGender(ped))
  local limits <const> = {}

  for i = 1, #ZONE_SLOTS do
    local slot <const> = ZONE_SLOTS[i]
    limits[slot.key .. 'Tattoo'] = #catalogue[slot.key] + 1
  end

  SendNUIMessage({
    action = 'siku_multicharacter:nui:setLimits',
    limits = limits,
  })
end

--- Applies a tattoo payload to the player ped.
---@param data table The tattoo payload, indexed by zone key.
---@return nil
function ApplyTattoos(data)
  if type(data) ~= 'table' then
    return
  end

  local ped <const> = PlayerPedId()
  local catalogue <const> = getCatalogue(getGender(ped))

  ClearPedDecorations(ped)

  for i = 1, #ZONE_SLOTS do
    local slot <const> = ZONE_SLOTS[i]
    local index <const> = (data[slot.key] or 1) - 1
    local tattoo <const> = index > 0 and catalogue[slot.key][index] or nil

    if tattoo then
      AddPedDecorationFromHashes(ped, joaat(tattoo.collection), joaat(tattoo.hash))
    end
  end
end

RegisterNUICallback('siku_multicharacter:nui:tattoosChanged', function(data, cb)
  cb({})
  ApplyTattoos(data)
end)
