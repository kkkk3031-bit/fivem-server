local AMBER = { 255, 176, 33 }
local BLURPLE = { 88, 101, 242 }

AddEventHandler('playerJoining', function()
  local name = GetPlayerName(source) or 'someone'
  TriggerClientEvent('chat:addMessage', -1, {
    color = AMBER,
    args = { '🏎 Server', ('%s is joining — welcome! · حياك الله'):format(name) },
  })
end)

AddEventHandler('playerDropped', function(reason)
  local name = GetPlayerName(source) or 'someone'
  TriggerClientEvent('chat:addMessage', -1, {
    color = { 138, 148, 166 },
    args = { '👋 Server', ('%s left · مع السلامة'):format(name) },
  })
end)

-- Discord + X reminder every 20 minutes
CreateThread(function()
  while true do
    Wait(20 * 60 * 1000)
    TriggerClientEvent('chat:addMessage', -1, {
      color = BLURPLE,
      args = { '💬 Discord', 'discord.gg/zbHbSsCUua · follow @KhaledQ84Ever on X 𝕏' },
    })
  end
end)
