local gymButtonPos = {-6.8, 0, 10.7}

local gymData = nil
local pokemonData = nil
local battleManager = "de7152"

function onSave()
    saved_data = JSON.encode({saveGymData=gymData, savePokemonData=pokemonData})
    return saved_data
end

function onLoad(saved_data)
  if saved_data ~= "" then
      local loaded_data = JSON.decode(saved_data)
      if loaded_data.saveGymData ~= nil and loaded_data.savePokemonData ~= nil then
        gymData = copyTable(loaded_data.saveGymData)
        pokemonData = copyTable(loaded_data.savePokemonData)
      end
  end

  self.createButton({ --Apply settings button
      label="+", click_function="battle",
      function_owner=self, tooltip="Start Gym Battle",
      position= gymButtonPos, rotation={0,0,0}, height=800, width=800, font_size=20000
  })
end

function battle()

  if gymData == nil then return end

  local params = {
    trainerName = gymData.trainerName,
    trainerGUID = gymData.guid,
    gymGUID = self.getGUID(),
    isGymLeader = true,
    isSilphCo = false,
    isRival = false,
    isElite4 = false,
    pokemon = pokemonData
  }

  local battleManager = getObjectFromGUID(battleManager)
  local sentToArena = battleManager.call("sendToArenaGym", params)

  if sentToArena then
    self.editButton({
        index=0, label="-", click_function="recall",
        function_owner=self, tooltip="Recall Gym Leader",
        position= gymButtonPos, rotation={0,0,0}, height=800, width=800, font_size=20000
    })
  end
end

function recall()

  local params = {gymGUID = self.getGUID()}

  local battleManager = getObjectFromGUID(battleManager)
  battleManager.call("recallGym", params)

  Global.call("PlayRouteMusic",{})

  self.editButton({ --Apply settings button
      index=0, label="+", click_function="battle",
      function_owner=self, tooltip="Start Gym Battle",
      position= gymButtonPos, rotation={0,0,0}, height=800, width=800, font_size=20000
  })
end

function setLeaderGUID(params)

  --print("setting gym leader guid")
  --print(params[1])
  leaderGUID = params[1]
  gymData = Global.call("GetGymDataByGUID", {guid=leaderGUID})

  pokemonData = {}
  for i=1, #gymData.pokemon do
    local newPokemon = {}
    setNewPokemon(newPokemon, gymData.pokemon[i])
    table.insert(pokemonData, newPokemon)
  end
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