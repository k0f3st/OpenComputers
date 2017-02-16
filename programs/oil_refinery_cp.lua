local computer = require("computer")
local os = require("os")
local component = require("component")
local unicode = require("unicode")
local term = require('term')
local sides = require('sides')
local event = require("event")
local gpu = component.gpu
local rs = component.redstone

-- сохраняем параметры экрана
local ow, oh = gpu.getResolution()

local function firstEnabled()
   rs.setOutput(sides.left, 15)
   
   gpu.setForeground(0x008000)
   gpu.setBackground(0x000000)
   gpu.set(3,13,"█████████████")
   gpu.set(3,14,"█████████████")
   gpu.set(3,15,"█████ 1 █████")
   gpu.set(3,16,"█████████████")
   gpu.set(3,17,"█████████████")
end
local function firstDisabled()
   rs.setOutput(sides.left, 0)
   
   gpu.setForeground(0xFF0000)
   gpu.setBackground(0x000000)
   gpu.set(3,13,"█████████████")
   gpu.set(3,14,"█████████████")
   gpu.set(3,15,"█████ 1 █████")
   gpu.set(3,16,"█████████████")
   gpu.set(3,17,"█████████████")
end

local function secondEnabled()
   rs.setOutput(sides.forward, 15)
   
   gpu.setForeground(0x008000)
   gpu.setBackground(0x000000)
   gpu.set(21,13,"█████████████")
   gpu.set(21,14,"█████████████")
   gpu.set(21,15,"█████ 2 █████")
   gpu.set(21,16,"█████████████")
   gpu.set(21,17,"█████████████")
end
local function secondDisabled()
   rs.setOutput(sides.forward, 0)
   
   gpu.setForeground(0xFF0000)
   gpu.setBackground(0x000000)
   gpu.set(21,13,"█████████████")
   gpu.set(21,14,"█████████████")
   gpu.set(21,15,"█████ 2 █████")
   gpu.set(21,16,"█████████████")
   gpu.set(21,17,"█████████████")
end

local function thirdEnabled()
   rs.setOutput(sides.right, 15)
   
   gpu.setForeground(0x008000)
   gpu.setBackground(0x000000)
   gpu.set(39,13,"█████████████")
   gpu.set(39,14,"█████████████")
   gpu.set(39,15,"█████ 3 █████")
   gpu.set(39,16,"█████████████")
   gpu.set(39,17,"█████████████")
end
local function thirdDisabled()
   rs.setOutput(sides.right, 0)
   
   gpu.setForeground(0xFF0000)
   gpu.setBackground(0x000000)
   gpu.set(39,13,"█████████████")
   gpu.set(39,14,"█████████████")
   gpu.set(39,15,"█████ 3 █████")
   gpu.set(39,16,"█████████████")
   gpu.set(39,17,"█████████████")
end

local function refineEnabled()
   rs.setOutput(sides.back, 15)
   
   gpu.setForeground(0x008000)
   gpu.setBackground(0x000000)
   gpu.set(69,13,"█████████████████")
   gpu.set(69,14,"█████████████████")
   gpu.set(69,15,"██ ПЕРЕРАБОТКА ██")
   gpu.set(69,16,"█████████████████")
   gpu.set(69,17,"█████████████████")
end
local function refineDisabled()
   rs.setOutput(sides.back, 0)
   
   gpu.setForeground(0xFF0000)
   gpu.setBackground(0x000000)
   gpu.set(69,13,"█████████████████")
   gpu.set(69,14,"█████████████████")
   gpu.set(69,15,"██ ПЕРЕРАБОТКА ██")
   gpu.set(69,16,"█████████████████")
   gpu.set(69,17,"█████████████████")
end

local function drawGUILayot()
  gpu.setResolution(100,19)
  gpu.setForeground(0xFFFFFF)
  gpu.setBackground(0x000000)
  term.clear()
  
   gpu.set(1,1,"o           ╔══════════════╗    ╔══════════════╗    ╔══════════════╗    ╔══════════════╗            ")
   gpu.set(1,2,"            ║--------------║    ║--------------║    ║--------------║    ║--------------║            ")
   gpu.set(1,3,"            ║              ║    ║              ║    ║              ║    ║              ║            ")
   gpu.set(1,4,"            ╚══════╦═══════╝    ╚══════╦═══════╝    ╚══════╦═══════╝    ╚══════╦═══════╝            ")
   gpu.set(1,5,"                  ╔╩╗                 ╔╩╗                 ╔╩╗                 ╔╩╗                   ")
   gpu.set(1,6,"                  ║1╠═════════════════╣2╠═════════════════╣3╠═════════════════╣E║                   ")
   gpu.set(1,7,"                  ╚═╝                 ╚═╝                 ╚═╝                 ╚═╝                   ")
   gpu.set(1,8,"                                                                                                    ")
   gpu.set(1,9,"                                                                                                    ")
  gpu.set(1,10,"                                                                                                    ")
  gpu.set(1,11,"╔═══════════════════════════════════════════════════╗                                               ")                 
  gpu.set(1,12,"║                                                   ║               █████████████████               ")
  gpu.set(1,13,"║ █████████████     █████████████     █████████████ ║               █████████████████               ")
  gpu.set(1,14,"║ █████████████     █████████████     █████████████ ║               █████████████████               ")
  gpu.set(1,15,"║ █████ 1 █████     █████ 2 █████     █████ 3 █████ ║               ██ ПЕРЕРАБОТКА ██               ")
  gpu.set(1,16,"║ █████████████     █████████████     █████████████ ║               █████████████████               ")
  gpu.set(1,17,"║ █████████████     █████████████     █████████████ ║               █████████████████               ")
  gpu.set(1,18,"║                                                   ║               █████████████████               ")
  gpu.set(1,19,"╚═══════════════════════════════════════════════════╝                                               ")
  
  gpu.setForeground(0xFFFFFF)
  gpu.setBackground(0xFDE910)
  gpu.set(74,2,"--------------")
  gpu.set(74,3,"              ")
  gpu.setForeground(0xFFFFFF)
  gpu.setBackground(0x000000)
  
end

local function onTouch(event,adress,x,y,clic,pseudo)
   if x==1 and y==1 then
   computer.pushSignal("quit")
   term.setCursor(1,1)
   elseif x > 3 and x < 16 and y > 13 and y < 17 then
   firstEnabled()
   elseif x > 21 and x < 34 and y > 13 and y < 17 then
   secondEnabled()
   elseif x > 39 and x < 52 and y > 13 and y < 17 then
   thirdEnabled()
   elseif x > 69 and x < 86 and y > 12 and y < 18 then
   refineEnabled()
   end
end

-- рисуем интерфейс
term.clear()

drawGUILayot()
firstDisabled()
secondDisabled()
thirdDisabled()
refineDisabled()

event.listen("touch",onTouch)
event.pull("quit")
event.ignore("touch",onTouch)

-- восстанавливаем параметры экрана
gpu.setResolution(ow, oh)
gpu.setForeground(0xFFFFFF)
gpu.setBackground(0x000000)
term.clear()