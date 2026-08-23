RegisterNUICallback('siku_multicharacter:nui:ready', function(_, cb)
  SendNUIMessage({
    action = 'siku_multicharacter:nui:setInterface',
    interface = {
      theme = InterfaceConfig.theme,
    },
  })

  SendNUIMessage({
    action = 'siku_multicharacter:nui:setLocale',
    locale = {
      language = TranslationConfig.language,
      translations = Siku.locale.translations(),
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

  SendNUIMessage({
    action = 'siku_multicharacter:nui:setHeritage',
    heritage = {
      fathers = HeritageConfig.fathers,
      mothers = HeritageConfig.mothers,
    },
  })

  cb({})
end)
