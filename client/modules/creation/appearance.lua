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
