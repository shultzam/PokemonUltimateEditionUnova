local gymButtonPos = {-1.1, 0, 3.7}

local battleManager = "de7152"
local leadersData = {}

function onSave()
    saved_data = JSON.encode({saveLeadersData=leadersData})
    return saved_data
end

function onLoad(saved_data)
  if saved_data ~= "" then
      local loaded_data = JSON.decode(saved_data)
      if loaded_data.saveLeadersData ~= nil then
          leadersData = copyTable(loaded_data.saveLeadersData)
      end
  end

  self.createButton({ --Apply settings button
      label="+", click_function="battle",
      function_owner=self, tooltip="Start Team Plasma Battle",
      position= gymButtonPos, rotation={0,90,0}, height=800, width=800, font_size=20000
  })
end

function deleteSave() 
  leadersData = {}
end

function battle()

  if #leadersData == 0 then return end

  local leaderIndex = math.random(1, #leadersData)
  local leaderData = leadersData[leaderIndex]

  local params = {
    trainerName = leaderData.trainerName,
    trainerGUID = leaderData.guid,
    gymGUID = self.getGUID(),
    isGymLeader = false,
    isSilphCo = true,
    isRival = false,
    isElite4 = false,
    pokemon = leaderData.pokemon
  }

  local battleManager = getObjectFromGUID(battleManager)
  local sentToArena = battleManager.call("sendToArenaGym", params)

  if sentToArena then
    self.editButton({
        index=0, label="-", click_function="recall",
        function_owner=self, rotation={0,90,0}, tooltip="Recall Team Plasma Member"
    })
  end
end

function recall()

  local battleManager = getObjectFromGUID(battleManager)
  battleManager.call("recallGym")

  Global.call("PlayRouteMusic",{})

  self.editButton({ --Apply settings button
      index=0, label="+", click_function="battle",
      function_owner=self, rotation={0,90,0}, tooltip="Start Team Plasma Battle"
  })
end

function setLeaderGUID(params)
  leaderGUID = params[1]
  local gymData = Global.call("GetGymDataByGUID", {guid=leaderGUID})

  local leaderData = {guid= gymData.guid, trainerName= gymData.trainerName}
  local pokemonData = {}
  for i=1, #gymData.pokemon do
    local newPokemon = {}
    setNewPokemon(newPokemon, gymData.pokemon[i])
    table.insert(pokemonData, newPokemon)
  end
  leaderData.pokemon = pokemonData

  table.insert(leadersData, leaderData)
end

function setNewPokemon(data, newPokemonData)

  data.name = newPokemonData.name
  data.types = copyTable(newPokemonData.types)
  data.baseLevel = newPokemonData.level
  data.effects = {}

  data.moves = copyTable(newPokemonData.moves)
  local movesData = {}
  for i=1, #data.moves do
    moveData = copyTable(Global.call("GetMoveDataByName", data.moves[i]))
    moveData.status = DEFAULT
    moveData.isTM = false
    table.insert(movesData, moveData)
  end
  data.movesData = movesData
end


function copyTable (original)
  local copy = {}
	for k, v in pairs(original) do
		if type(v) == "table" then
			v = copyTable(v)
		end
		copy[k] = v
	end
	return copy
end