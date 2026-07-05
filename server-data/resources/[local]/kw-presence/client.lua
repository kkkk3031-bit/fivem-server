-- Shows in players' Discord profiles while they play
CreateThread(function()
  while true do
    SetRichPresence(("🏎 khaled's FiveM · Kuwait 🇰🇼 · %d online · @KhaledQ84Ever"):format(#GetActivePlayers()))
    Wait(60000)
  end
end)
