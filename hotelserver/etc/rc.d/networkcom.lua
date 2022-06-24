local component = require("component")
local event = require("event")
local modem = component.modem
local cereal = require("serialization")
local unixtime = require("unixtime")
local bellhopaddress = "/etc/bellhopaddress.cfg"
local frontdeskaddress = "/etc/frontdeskaddress.cfg"

local function loadaddr()
  local bellhop = ""
  local frontdesk = ""
  local file = io.open(bellhopaddress)
  local srl = file:read("*a")
  file:close()
  bellhop = cereal.unserialize(srl)
  local file = io.open(frontdeskaddress)
  local srl = file:read("*a")
  file:close()
  frontdesk = cereal.unserialize(srl)
  return bellhop,frontdesk
end

local function handleBellhop(message,message2,message3)
  event.push("dispatch",message)
end

local function handleFrontdesk(message,message2,message3)
  if message == "dbrequest" then
    event.push("database",false,message2)
    local _,db = event.pull("databaseReply")
    local _,frontdesk = loadaddr()
    modem.send(frontdesk,1212,"dbreply",cereal.serialize(db))
  elseif message == "dbwrite" then
    db = cereal.unserialize(message3)
    if db["reserved"] then
      db["time"] = unixtime()
      event.push("dispatch","reserve",message2,db["username"])
    else
      event.push("dispatch","unreserve",message2)
    end
    event.push("database",true,message2,db)
  end
end

local function handleModem(_,_,addr,port,_,message,message2,message3)
  local bellhop,frontdesk = loadaddr()
  if addr == bellhop then
    handleBellhop(message,message2,message3)
  elseif addr == frontdesk then
    handleFrontdesk(message,message2,message3)
  else
    return false
  end
end

function start()
  modem.open(1212)
  event.listen("modem_message",handleModem)
end

function stop()
  modem.close(1212)
  event.ignore("modem_message", handleModem)
end
