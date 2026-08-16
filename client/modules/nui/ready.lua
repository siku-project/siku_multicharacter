--- Loads the full translation table for the active language.
---@return table<string, string> translations The translation table.
local function loadTranslations()
  local file <const> =
    LoadResourceFile(GetCurrentResourceName(), ('translations/%s.lua'):format(TranslationConfig.language))
  if not file then
    return {}
  end

  local fn <const> = load(file)
  if not fn then
    return {}
  end

  return fn() or {}
end

RegisterNUICallback('siku_multicharacter:nui:ready', function(_, cb)
  SendNUIMessage({
    action = 'siku_multicharacter:nui:setLocale',
    locale = {
      language = TranslationConfig.language,
      translations = loadTranslations(),
    },
  })

  SendNUIMessage({
    action = 'siku_multicharacter:nui:setPeds',
    peds = {
      authorizeAll = PedsConfig.authorizePedwhileInCreator,
      basics = PedsConfig.pedList.basics,
      peds = PedsConfig.pedList.peds,
    },
  })

  cb({})
end)
