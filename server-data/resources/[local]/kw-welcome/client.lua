-- Personal welcome with controls + links, once per session after first spawn
local welcomed = false

AddEventHandler('playerSpawned', function()
  if welcomed then return end
  welcomed = true
  Wait(4000)
  TriggerEvent('chat:addMessage', {
    color = { 255, 176, 33 },
    multiline = true,
    args = { '🏎 Welcome', "khaled's FiveM · Kuwait 🇰🇼 — press M for the menu (cars/weapons/teleport), N to talk" },
  })
  Wait(1500)
  TriggerEvent('chat:addMessage', {
    color = { 70, 224, 139 },
    multiline = true,
    args = { '🎮 New', 'F3 emotes · X hands up · Z crouch · B point · /hat /mask clothes · cars need fuel ⛽ · fun spots on map 🗺️' },
  })
  Wait(1500)
  TriggerEvent('chat:addMessage', {
    color = { 88, 101, 242 },
    args = { '💬 Links', 'Discord: discord.gg/zbHbSsCUua · X: x.com/KhaledQ84Ever' },
  })
end)
