require("process").info().data.signal = function() end
local fgui = require("fgui")
local unixtime = require("unixtime")
local computer = require("computer")
local component = require("component")
local cereal = require("serialization")
local event = require("event")
local term = require("term")
local modem = component.modem
local gpu = component.gpu
local width, height = gpu.getViewport()
local input = false
local roomlist1 = {"A1","A2","A3","A4","A5","A6"}
local roomlist2 = {"B1","B2","B3","B4","B5","B6"}
local hotelname = "Hôtel Robotique"
local headercolor = 0xFFD700
local green = 0x008000
local red = 0xFF0000
local headertext = 0x000000
local frontpagecolor = 0x000000
local frontpagetext = 0xFFD700
local headerbuttoncolor = 0x008000
local headerbuttontext = 0xFFFFFF
local roombuttontext = 0xFFFFFF
local password = "nya"
local passinput = ""
local addrfile = "/etc/serveraddress.cfg"

local file = io.open(addrfile,"r")
local srl = file:read("*a")
file:close()
local serveraddress = cereal.unserialize(srl)

fgui.deleteAllButtons()

local function Quit()
  fgui.deleteAllButtons()
  gpu.setBackground(0x000000)
  gpu.setForeground(0xFFFFFF)
  term.clear()
  os.exit()
end

local function header()
  gpu.setBackground(headercolor)
  gpu.fill(1, 1, 160, 3, " ")
  gpu.setForeground(headertext)
  fgui.writeTextCentered(hotelname, 2)
  gpu.setBackground(0x000000)
  gpu.setForeground(0xFFFFFF)
end

local function frontpage()
  fgui.deleteAllButtons()
  term.clear()
  gpu.setForeground(frontpagetext)
  gpu.setBackground(frontpagecolor)
  gpu.fill(1, 1, 160, 50, " ")
  header()
  gpu.setForeground(frontpagetext)
  gpu.setBackground(frontpagecolor)
  fgui.writeTextCentered("Welcome",height/2)
  fgui.writeTextCentered("Click anywhere to begin.",height/2+1)
  gpu.setBackground(0x000000)
  gpu.setForeground(0xFFFFFF)
end

local function loadingscreen()
  term.clear()
  header()
  fgui.writeTextCentered("Loading...",height/2)
end

local function getEntry(room)
  modem.open(1212)
  modem.send(serveraddress,1212,"dbrequest",room)
  local _,_,_,_,_,type,srl = event.pull(5,"modem_message")
  modem.close(1212)
  if not srl then
    computer.shutdown(true)
  end
  local db = cereal.unserialize(srl)
  return db
end

local function parsedb(username,floor)
  local userReserved = false
  local userdbA = {}
  local userdbB = {}
  for i,v in ipairs(roomlist1) do
    local db = getEntry(v)
    if username == db["username"] then
      userReserved = v
      userTime = db["time"]
    end
    userdbA[v:gsub('A', '')] = db["reserved"]
    os.sleep(0.1)
  end
  for i,v in ipairs(roomlist2) do
    local db = getEntry(v)
    if username == db["username"] then
      userReserved = v
      userTime = db["time"]
    end
    userdbB[v:gsub('B', '')] = db["reserved"]
    os.sleep(0.1)
  end
  return userdbA, userdbB, userReserved, userTime
end

local function colorFromStatus(status)
  if status then
    return red
  else
    return green
  end
end

local function handleButton(id, player, button)
  event.push("buttonpush",id,player)
end

local function writeDB(room,username,status)
  modem.open(1212)
  modem.send(serveraddress,1212,"dbrequest",room)
  local _,_,_,_,_,type,srl = event.pull(5,"modem_message")
  modem.close(1212)
  local db = cereal.unserialize(srl)
  if status then
    db["reserved"] = true
    db["username"] = username
  else
    db["reserved"] = false
    db["username"] = ""
    db["time"] = 0
  end
  local srl = cereal.serialize(db)
  modem.send(serveraddress,1212,"dbwrite",room,srl)
end

local function confirmRoom(room,username,status)
  term.clear()
  ::redrawconfirm::
  fgui.deleteAllButtons()
  gpu.setBackground(frontpagecolor)
  gpu.setForeground(frontpagetext)
  gpu.fill(1, 1, 160, 50, " ")
  header()
  gpu.setBackground(frontpagecolor)
  gpu.setForeground(frontpagetext)
  fgui.writeTextCentered("Confirm?",height/4)
  fgui.createButton("yes", 40, 24, 51, 28, handleButton, "Yes", green, roombuttontext)
  fgui.createButton("no", 109, 24, 120, 28, handleButton, "No", red, roombuttontext)
  local _,id,player = event.pull(60,"buttonpush")
  if id then
    if player == username then
      if id == "yes" then
        writeDB(room,username,status)
        computer.beep(400,0.2)
        computer.beep(800,0.3)
      else
        computer.beep(800,0.2)
        computer.beep(400,0.3)
        return
      end
    else
      goto redrawconfirm
    end
  end
end

local function renderRooms(floor,floordb)
  fgui.writeTextCentered("Please choose a room.",8,frontpagetext,frontpagecolor)
  gpu.setForeground(roombuttontext)
  fgui.createButton("1",36,6,55,21,handleButton,floor.."1",colorFromStatus(floordb["1"]),roombuttontext)
  fgui.createButton("2",36,23,55,38,handleButton,floor.."2",colorFromStatus(floordb["2"]),roombuttontext)
  fgui.createButton("3",36,40,71,48,handleButton,floor.."3",colorFromStatus(floordb["3"]),roombuttontext)
  fgui.createButton("4",88,40,123,48,handleButton,floor.."4",colorFromStatus(floordb["4"]),roombuttontext)
  fgui.createButton("5",104,23,123,38,handleButton,floor.."5",colorFromStatus(floordb["5"]),roombuttontext)
  fgui.createButton("6",104,6,123,21,handleButton,floor.."6",colorFromStatus(floordb["6"]),roombuttontext)
end

local function chooseRoom(floordbA,floordbB,username)
  term.clear()
  header()
  local floor = "A"
  local floordb = {}
  ::redraw::
  if floor == "A" then
    floordb = floordbA
  else
    floordb = floordbB
  end
  fgui.deleteAllButtons()
  gpu.setBackground(headerbuttoncolor)
  gpu.setForeground(headerbuttontext)
  fgui.createButton("goback", 1, 1, 16, 3, handleButton, "Go Back", headerbuttoncolor, headerbuttontext)
  fgui.createButton("changefloors", 144, 1, 160, 3, handleButton, "Change Floors", headerbuttoncolor, headerbuttontext)
  renderRooms(floor,floordb)
  local _,id,player = event.pull(60,"buttonpush")
  if id then
    if player == username then
      if id == "goback" then
        fgui.deleteAllButtons()
        return
      elseif id == "changefloors" then
        if floor == "A" then
          floor = "B"
        else
          floor = "A"
        end
        goto redraw
      elseif string.len(id) < 3 then
        if not floordb[id] then
          confirmRoom(floor..id,username,true)
        else
          goto redraw
        end
      end
    else
      goto redraw
    end
  end
  fgui.deleteAllButtons()
end

function disp_time(time)
  local days = math.floor(time/86400)
  local remaining = time % 86400
  local hours = math.floor(remaining/3600)
  remaining = remaining % 3600
  local minutes = math.floor(remaining/60)
  remaining = remaining % 60
  local seconds = remaining
  if (hours < 10) then
    hours = "0" .. tostring(hours)
  end
  if (minutes < 10) then
    minutes = "0" .. tostring(minutes)
  end
  if (seconds < 10) then
    seconds = "0" .. tostring(seconds)
  end
  answer = tostring(days)..':'..hours..':'..minutes..':'..seconds
  return answer
end

local function userOptions(username,userReserved,userTime)
  term.clear()
  header()
  ::redrawoptions::
  local timeRemaining = 1728000 - (unixtime() - userTime)
  fgui.deleteAllButtons()
  gpu.setBackground(headerbuttoncolor)
  gpu.setForeground(headerbuttontext)
  fgui.createButton("goback", 1, 1, 16, 3, handleButton, "Go Back", headerbuttoncolor, headerbuttontext)
  gpu.setForeground(frontpagetext)
  gpu.setBackground(frontpagecolor)
  fgui.writeTextCentered("User: "..username,height/8)
  fgui.writeTextCentered("Room: "..userReserved,(height/8)+1)
  fgui.writeTextCentered("Time Remaining: "..disp_time(timeRemaining),(height/8)+2)
  fgui.createButton("renew",40,24,71,28,handleButton,"Renew Reservation",green,roombuttontext)
  fgui.createButton("cancel",89,24,120,28,handleButton,"Cancel Reservation",red,roombuttontext)
  local _,id,player = event.pull(60,"buttonpush")
  if id then
    if player == username then
      if id == "goback" then
        fgui.deleteAllButtons()
        return
      elseif id == "renew" then
        confirmRoom(userReserved,username,true)
      elseif id == "cancel" then
        confirmRoom(userReserved,username,false)
      end
    else
      goto redrawoptions
    end
  end
  fgui.deleteAllButtons()
end

local function handleInput(username)
  loadingscreen()
  local userdbA, userdbB, userReserved, userTime = parsedb(username,"A")
  if userReserved then
    userOptions(username,userReserved,userTime)
    return
  else
    chooseRoom(userdbA,userdbB,username)
    return
  end
end

local function mainLoop()
  frontpage()
  while not input do
    local input,b,c,d,e,f = event.pull(2)
    if input == "key_down" then
      if c == 104 then
        print("Password Input: ")
        passinput = term.read({dobreak=false,pwchar="*"})
        passinput = string.gsub(passinput,"\n","")
        if passinput == password then
          computer.beep(400,0.2)
          computer.beep(800,0.3)
          Quit()
        else
          computer.beep(800,0.2)
          computer.beep(400,0.3)
          input = false
          frontpage()
        end
      elseif c == 114 then
        print("Rebooting")
        computer.shutdown(true)
      else
        handleInput(e)
        input = false
        frontpage()
      end
    elseif input == "touch" then
      handleInput(f)
      input = false
      frontpage()
    else
      input = false
    end
  end
end

mainLoop()
return