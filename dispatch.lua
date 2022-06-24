local component = require("component")
local event = require("event")
local modem = component.modem
local cereal = require("serialization")
local fs = require("filesystem")

local bellhopaddress = "/etc/bellhopaddress.cfg"
local currentjobfile = "/etc/currentjob.cfg"

local function loadaddr()
  local bellhop = ""
  local file = io.open(bellhopaddress)
  local srl = file:read("*a")
  file:close()
  bellhop = cereal.unserialize(srl)
  return bellhop
end

local function currentjobwrite(command,room,username)
  local file = io.open(currentjobfile,"w")
  local srl = cereal.serialize({command=command,room=room,username=username})
  file:write(srl)
  file:close()
  return
end

local function currentjobread()
  local currentjob = {}
  if fs.exists(currentjobfile) then
    local file = io.open(currentjobfile)
    local srl = file:read("*a")
    file:close()
    currentjob = cereal.unserialize(srl)
    return currentjob["command"],currentjob["room"],currentjob["username"]
  end
  return nil, nil, nil
end

local function handleDispatch(_,command,room,username)
  if command == "reserve" then
    modem.send(loadaddr(),1212,command,room,username)
    currentjobwrite(command,room,username)
  elseif command == "unreserve" then
    modem.send(loadaddr(),1212,command,room)
    currentjobwrite(command,room,nil)
  elseif command == "bellhopinit" then
    local command, room, username = currentjobread()
    if command then
      modem.send(loadaddr(),1212,command,room,username)
    end
  elseif command == "jobcomplete" then
    currentjobwrite(nil,nil,nil)
  end
end

function start()
  event.listen("dispatch",handleDispatch)
end

function stop()
  event.ignore("dispatch", handleDispatch)
end