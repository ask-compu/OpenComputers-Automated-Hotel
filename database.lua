local cereal = require("serialization")
local component = require("component")
local event = require("event")
local fs = require("filesystem")
local dbfile = "/var/room.db"

local function loaddb()
  local mainDatabase = {A1={}, A2={}, A3={}, A4={}, A5={}, A6={}, B1={}, B2={}, B3={}, B4={}, B5={}, B6={}}
  if fs.exists(dbfile) then
    local file = io.open(dbfile,"r")
    local srl = file:read("*a")
    file:close()
    mainDatabase = cereal.unserialize(srl)
  else
    for k,v in pairs(mainDatabase) do
      for dk,dv in pairs({reserved=false, time=0, username=""}) do
        v[dk] = dv
      end
    end
  end
  return mainDatabase
end

local function savedb(mainDatabase)
  local file = io.open(dbfile,"w")
  local srl = cereal.serialize(mainDatabase)
  file:write(srl)
  file:close()
  return
end

local function handledb(_, write, room, data)
  mainDatabase = loaddb()
  if write then
    mainDatabase[room] = data
    savedb(mainDatabase)
    event.push("databaseSuccess")
  else
    event.push("databaseReply", mainDatabase[room])
  end
end

function start()
  event.listen("database", handledb)
end

function stop()
  event.ignore("database", handledb)
end