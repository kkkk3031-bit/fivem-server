local wasShown = false

CreateThread(function()
  while true do
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
      local veh = GetVehiclePedIsIn(ped, false)
      local kmh = math.floor(GetEntitySpeed(veh) * 3.6 + 0.5)
      SendNUIMessage({ show = true, speed = kmh })
      wasShown = true
      Wait(120)
    else
      if wasShown then
        SendNUIMessage({ show = false })
        wasShown = false
      end
      Wait(600)
    end
  end
end)
