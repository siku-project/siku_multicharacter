local OVERLAY_TARGETS <const> = {
  { id = 0, key = 'blemishes' },
  { id = 1, key = 'beard', colorType = 1 },
  { id = 2, key = 'eyebrows', colorType = 1 },
  { id = 3, key = 'ageing' },
  { id = 4, key = 'makeup', colorType = 2 },
  { id = 5, key = 'blush', colorType = 2 },
  { id = 7, key = 'sunDamage' },
  { id = 8, key = 'lipstick', colorType = 2 },
  { id = 9, key = 'moles' },
  { id = 10, key = 'chestHair', colorType = 1 },
}

local FEATURE_TARGETS <const> = {
  [0] = 'noseWidth', [1] = 'noseHeight', [2] = 'noseLength',
  [3] = 'noseBridgeHeight', [4] = 'noseTipHeight', [5] = 'noseBridgeTwist',
  [6] = 'browHeight', [7] = 'browDepth',
  [8] = 'cheekboneHeight', [9] = 'cheekboneWidth', [10] = 'cheekWidth',
  [11] = 'eyesOpening', [12] = 'lipThickness',
  [13] = 'jawWidth', [14] = 'jawLength',
  [15] = 'chinPosition', [16] = 'chinLength', [17] = 'chinWidth', [18] = 'chinHollow',
  [19] = 'neckThickness',
}

--- Sends the server-side customization limits to the NUI, so every
--- style slider matches what this server actually streams.
---@param ped number The ped handle.
---@return nil
function SendAppearanceLimits(ped)
  SendNUIMessage({
    action = 'siku_multicharacter:nui:setLimits',
    limits = {
      hairStyles = GetNumberOfPedDrawableVariations(ped, 2),
      eyebrows = GetNumHeadOverlayValues(2),
      beard = GetNumHeadOverlayValues(1),
      chestHair = GetNumHeadOverlayValues(10),
      ageing = GetNumHeadOverlayValues(3),
      lipstick = GetNumHeadOverlayValues(8),
      makeup = GetNumHeadOverlayValues(4),
      blush = GetNumHeadOverlayValues(5),
      sunDamage = GetNumHeadOverlayValues(7),
      moles = GetNumHeadOverlayValues(9),
      blemishes = GetNumHeadOverlayValues(0),
    },
  })
end

RegisterNUICallback('siku_multicharacter:nui:heritageChanged', function(data, cb)
  cb({})

  if type(data) ~= 'table' then
    return
  end

  local ped <const> = PlayerPedId()
  local mother <const> = data.mother or 21
  local father <const> = data.father or 0

  SetPedHeadBlendData(
    ped,
    mother, father, 0,
    mother, father, 0,
    (data.resemblance or 0.5) + 0.0, (data.skinTone or 0.5) + 0.0, 0.0, false
  )
end)

RegisterNUICallback('siku_multicharacter:nui:physicalChanged', function(data, cb)
  cb({})

  if type(data) ~= 'table' then
    return
  end

  local ped <const> = PlayerPedId()
  local hair <const> = data.hair or {}

  SetPedComponentVariation(ped, 2, (hair.style or 1) - 1, 0, 0)
  SetPedHairTint(ped, hair.color or 0, hair.highlight or 0)
  SetPedEyeColor(ped, data.eyeColor or 0)

  local overlays <const> = data.overlays or {}

  for i = 1, #OVERLAY_TARGETS do
    local target <const> = OVERLAY_TARGETS[i]
    local entry <const> = overlays[target.key]

    if entry then
      SetPedHeadOverlay(ped, target.id, (entry.style or 1) - 1, (entry.opacity or 0.5) + 0.0)

      if target.colorType then
        SetPedHeadOverlayColor(ped, target.id, target.colorType, entry.color or 0, entry.secondary or 0)
      end
    end
  end

  local features <const> = data.features or {}

  for index, key in pairs(FEATURE_TARGETS) do
    SetPedFaceFeature(ped, index, (features[key] or 0) + 0.0)
  end
end)
