-- kw-hands: hands up (X), crouch (Z), point (B). Standalone, no deps.
local handsUp, crouched, pointing = false, false, false

local function loadDict(dict)
  RequestAnimDict(dict)
  local tries = 0
  while not HasAnimDictLoaded(dict) and tries < 100 do Wait(10); tries = tries + 1 end
  return HasAnimDictLoaded(dict)
end

RegisterCommand('handsup', function()
  local ped = PlayerPedId()
  handsUp = not handsUp
  if handsUp then
    if loadDict('missminuteman_1ig_2') then
      TaskPlayAnim(ped, 'missminuteman_1ig_2', 'handsup_base', 8.0, 8.0, -1, 49, 0, false, false, false)
    end
  else
    ClearPedTasks(ped)
  end
end, false)

RegisterCommand('crouch', function()
  local ped = PlayerPedId()
  if not IsPedHuman(ped) or IsPedInAnyVehicle(ped, true) then return end
  crouched = not crouched
  if crouched then
    RequestClipSet('move_ped_crouched')
    local tries = 0
    while not HasClipSetLoaded('move_ped_crouched') and tries < 100 do Wait(10); tries = tries + 1 end
    SetPedMovementClipset(ped, 'move_ped_crouched', 0.5)
  else
    ResetPedMovementClipset(ped, 0.5)
  end
end, false)

RegisterCommand('point', function()
  local ped = PlayerPedId()
  pointing = not pointing
  if pointing then
    SetPedConfigFlag(ped, 36, true)
    SetPedCurrentWeaponVisible(ped, false, true, true, true)
    if loadDict('anim@mp_point') then
      TaskMoveNetworkByName(ped, 'task_mp_pointing', 0.5, false, 'anim@mp_point', 24)
    end
  else
    RequestTaskMoveNetworkStateTransition(ped, 'Stop')
    ClearPedSecondaryTask(ped)
    SetPedCurrentWeaponVisible(ped, true, true, true, true)
    SetPedConfigFlag(ped, 36, false)
  end
end, false)

RegisterKeyMapping('handsup', 'Hands up', 'keyboard', 'X')
RegisterKeyMapping('crouch', 'Crouch', 'keyboard', 'Z')
RegisterKeyMapping('point', 'Finger point', 'keyboard', 'B')
