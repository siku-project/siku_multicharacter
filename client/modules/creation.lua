Creation = {}

local MODEL_BY_GENDER <const> = {
  male = 'mp_m_freemode_01',
  female = 'mp_f_freemode_01',
}

local identity = nil

function Creation.open()
  local ped <const> = Stage.enter()

  Camera.placeSelection(ped)
  Nui.show('creation')
  DoScreenFadeIn(800)
end

Nui.on('identitySubmitted', function(data)
  identity = data

  Nui.hide()
  Stage.fadeOut()
  Camera.clearSelection()

  local ped <const> = Stage.place(MODEL_BY_GENDER[data.gender] or MODEL_BY_GENDER.male, nil)

  Look.sendAllLimits(ped)
  Camera.playIntro(ped)
  Nui.show('appearance')

  TriggerServerEvent('siku_multicharacter:server:stage', 'appearance')
end)

Nui.on('pedSelected', function(data)
  if type(data.model) ~= 'string' or data.model == '' then
    return
  end

  local ped <const> = Stage.place(data.model, nil)

  Look.sendAllLimits(ped)
  Camera.focusScene(ped)
end)

Nui.on('appearanceValidated', function(data)
  if not identity then
    return
  end

  Pose.reset()
  Nui.hide()
  Stage.fadeOut()

  TriggerServerEvent('siku_multicharacter:server:createCharacter', {
    identity = identity,
    pedModel = data.pedModel,
    appearance = data.appearance,
  })

  identity = nil
end)
