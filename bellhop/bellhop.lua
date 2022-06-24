local gotoroom = "A4"
local playername = nil

local signtext = "\nRoom " .. gotoroom
local inventoryslot = 1
local editsign = {{"up",1}, {"back",1}, {"up",1}}
local returnfromsign = {{"down",1}, {"forward",1}, {"down",1}}
local nav = require("nav")
local component = require("component")
local event = require("event")
local computer = require("computer")
local shell = require("shell")
local cereal = require("serialization")
if not component.isAvailable("navigation") then
  io.stderr:write("This program requires a navigation upgrade to function.")
  os.exit()
end
local sign = component.sign
local compass = component.navigation
local robot = require("robot")
local robotcomp = component.robot
local chat = component.chat
local radar = component.radar
local modem = component.modem
local dbfile = "/var/paths.db"
local addrfile = "/etc/serveraddress.cfg"

map = nav:new()

local function posNeg(NS)
  NS = 0 - NS
 return NS
end

local function convertFacing(facing)
  xdir = 0
  zdir = 0
  mfacing = 0
  if facing == 2 then
    xdir = 0
    zdir = -1
    mfacing = 0
  elseif facing == 3 then
    xdir = 0
    zdir = 1
    mfacing = 2
  elseif facing == 4 then
    xdir = -1
    zdir = 0
    mfacing = 3
  elseif facing == 5 then
    xdir = 1
    zdir = 0
    mfacing = 1
  else
    io.stderr:write("I don't understand what the navigation upgrade is telling me")
    os.exit()
  end
  return xdir , zdir, mfacing
end

local function setNavPosition(posx , posy , posz , facing)
  xdir , zdir, mfacing = convertFacing(facing)
  shell.execute("setLocation" , nil , posx , posy , posz , xdir , zdir)
  negz = posNeg(posz)
  map:setPos({negz , posx , posy , mfacing})
  return posx , posy , posz , facing
end

local function getNavPosition()
  local posx , posy , posz = compass.getPosition()
  if not posx then
    io.stderr:write("This robot is out of range of it's map. Please place it within range of it's map (the one in the navigation upgrade) and try again.")
    os.exit()
  end
  posx = posx - 0.5
  posy = posy - 0.5
  posz = posz - 0.5
  local facing = compass.getFacing()
  return posx , posy, posz , facing
end

local function parseCommand(command)
  local retry = true
  local retried = false
  while retry do
    if command == "forward" then
      move , reason = robot.forward()
    elseif command == "back" then
      move, reason = robot.back()
    elseif command == "up" then
      move, reason = robot.up()
    elseif command == "down" then
      move, reason = robot.down()
    elseif command == "turnLeft" then
      robot.turnLeft()
      move = true
    elseif command == "turnRight" then
      robot.turnRight()
      move = true
    elseif command == "turnAround" then
      robot.turnAround()
      move = true
    else
      return false
    end
    if move then
      retry = false
      if retried then
        chat.say("Thank you!")
      end
    else
      chat.say("Please move out of the way.")
      os.sleep(5)
      retried = true
    end
  end
  return true
end
 
function isPlayerIn(data, player)
  for i,t in ipairs(data) do
    if t["name"] == player then
      return true
    end
  end

  return false
end

local function commandLoop(commands,waitforplayer)
  for k, v in ipairs(commands) do
    local command = v[1]
    local loopnum = v[2]
    for i=loopnum,1,-1 do
      if waitforplayer then
        local players = radar.getPlayers(5)
        local found = false
        local waited = 0
        while not found and waited < 10 do
          if players["n"] > 0 then
            if isPlayerIn(players,waitforplayer) then
              found = true
            else
              waited = waited + 1
              chat.say("Please follow me, " .. waitforplayer .. ".")
              os.sleep(5)
              players = radar.getPlayers(5)
            end
          else
            waited = waited + 1
            chat.say("Please follow me, " .. waitforplayer .. ".")
            os.sleep(5)
            players = radar.getPlayers(5)
          end
        end
      end
      parseCommand(command)
    end
  end
end

print(setNavPosition(getNavPosition()))
local function checkPos()
  loc = map:getPos()
  print(loc["x"],loc["y"],loc["z"],loc["f"],loc["weight"])
  return
end
checkPos()
map:go({posNeg(13),-58,69,0})
chat.say("Hello!")
local file = io.open(addrfile,"r")
local srl = file:read("*a")
file:close()
local serveraddress = cereal.unserialize(srl)
modem.open(1212)
modem.send(serveraddress,1212,"bellhopinit")

local file = io.open(dbfile,"r")
local srl = file:read("*a")
file:close()
pathsdb = cereal.unserialize(srl)

local function mainLoop()
  while not mm do
    local mm,_,addr,_,_,command,room,username = event.pull(5,"modem_message")
    --print(mm,addr,command,room,username)
    if addr == serveraddress then
      if command == "reserve" then
        chat.say(username .. ", please follow me to your room.")
        commandLoop(pathsdb["To"][room],username)
        local inventoryslot = 1
        local signtext = "\nRoom " .. room .. "\nReserved by\n" .. username
        robotcomp.select(inventoryslot)
        robotcomp.swing(3)
        robotcomp.suck(1)
        robotcomp.place(3)
        commandLoop(editsign)
        sign.setValue(signtext)
        chat.say("Please enjoy your room!")
        modem.send(serveraddress,1212,"jobcomplete")
        commandLoop(returnfromsign)
        commandLoop(pathsdb["From"][room])
        mm = false
      elseif command == "unreserve" then
        commandLoop(pathsdb["To"][room])
        local inventoryslot = 2
        signtext = "\nRoom " .. room .. "\nNot Reserved"
        robotcomp.select(inventoryslot)
        robotcomp.swing(3)
        robotcomp.suck(1)
        robotcomp.place(3)
        commandLoop(editsign)
        sign.setValue(signtext)
        modem.send(serveraddress,1212,"jobcomplete")
        commandLoop(returnfromsign)
        commandLoop(pathsdb["From"][room])
        mm = false
      end
    else
      mm = false
    end
  end
end
mainLoop()
