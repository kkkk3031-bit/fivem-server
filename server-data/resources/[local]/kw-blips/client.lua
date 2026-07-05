-- kw-blips: fun meetup spots on the map. Standalone.
-- sprite ids: https://docs.fivem.net/docs/game-references/blips/
local spots = {
  { name = 'LSIA Airport (planes)',      x = -1034.6, y = -2733.6, z = 20.2,  sprite = 90,  color = 3 },
  { name = 'Diamond Casino',             x = 925.3,   y = 46.2,    z = 81.1,  sprite = 679, color = 46 },
  { name = 'Drift Lot — Docks',          x = 1201.0,  y = -2985.0, z = 5.9,   sprite = 147, color = 1 },
  { name = 'Drift — Vinewood Hills rd',  x = -1731.0, y = 142.0,   z = 64.4,  sprite = 147, color = 17 },
  { name = 'LS Customs (tune cars)',     x = -337.4,  y = -136.9,  z = 39.0,  sprite = 72,  color = 5 },
  { name = 'Ammu-Nation',                x = 21.7,    y = -1107.4, z = 29.8,  sprite = 110, color = 1 },
  { name = 'Maze Bank Tower (jump!)',    x = -75.5,   y = -818.9,  z = 326.2, sprite = 445, color = 2 },
  { name = 'Mount Chiliad (offroad)',    x = 501.8,   y = 5604.5,  z = 797.9, sprite = 306, color = 25 },
  { name = 'Sandy Shores Airfield',      x = 1747.0,  y = 3273.7,  z = 41.1,  sprite = 90,  color = 17 },
  { name = 'Meet Spot — Legion Square',  x = 195.2,   y = -933.9,  z = 30.7,  sprite = 280, color = 47 },
}

CreateThread(function()
  for _, s in ipairs(spots) do
    local blip = AddBlipForCoord(s.x, s.y, s.z)
    SetBlipSprite(blip, s.sprite)
    SetBlipColour(blip, s.color)
    SetBlipScale(blip, 0.85)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(s.name)
    EndTextCommandSetBlipName(blip)
  end
end)
