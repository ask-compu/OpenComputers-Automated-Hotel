local component = require("component")
local cereal = require("serialization")
local event = require("event")
local modem = component.modem
local roomnum = "B4"

local addrfile = "/etc/serveraddress.cfg"

local file = io.open(addrfile,"r")
local srl = file:read("*a")
file:close()
local serveraddress = cereal.unserialize(srl)

modem.open(1212)
modem.send(serveraddress,1212,"dbrequest",roomnum)
local _,_,_,_,_,type,srl = event.pull(5,"modem_message")
modem.close(1212)
print(srl)
local db = cereal.unserialize(srl)
db["reserved"] = false
db["username"] = ""
db["time"] = 0
local srl = cereal.serialize(db)
modem.send(serveraddress,1212,"dbwrite",roomnum,srl)
print(srl)