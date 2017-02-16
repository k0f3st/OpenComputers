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

local function waterDistillationEnabled()
   rs.setOutput(sides.forward, 15)
   
   gpu.setForeground(0x008000)
   gpu.setBackground(0x000000)
   gpu.set(7,14,"██████████████████████████████")
   gpu.set(7,15,"██████████████████████████████")
   gpu.set(7,16,"██████████ ВКЛЮЧЕНА ██████████")
   gpu.set(7,17,"██████████████████████████████")
   gpu.set(7,18,"██████████████████████████████")
   
   gpu.setForeground(0xFF0000)
   gpu.setBackground(0x000000)
   gpu.set(63,14,"██████████████████████████████")
   gpu.set(63,15,"██████████████████████████████")
   gpu.set(63,16,"█████████ ВЫКЛЮЧЕНА ██████████")
   gpu.set(63,17,"██████████████████████████████")
   gpu.set(63,18,"██████████████████████████████")
end

local function waterDistillationDisabled()
   rs.setOutput(sides.forward, 0)
   
   gpu.setForeground(0xFF0000)
   gpu.setBackground(0x000000)
   gpu.set(7,14,"██████████████████████████████")
   gpu.set(7,15,"██████████████████████████████")
   gpu.set(7,16,"██████████ ВКЛЮЧЕНА ██████████")
   gpu.set(7,17,"██████████████████████████████")
   gpu.set(7,18,"██████████████████████████████")
   
   gpu.setForeground(0x008000)
   gpu.setBackground(0x000000)
   gpu.set(63,14,"██████████████████████████████")
   gpu.set(63,15,"██████████████████████████████")
   gpu.set(63,16,"█████████ ВЫКЛЮЧЕНА ██████████")
   gpu.set(63,17,"██████████████████████████████")
   gpu.set(63,18,"██████████████████████████████")
end

local function lightBeer()
   rs.setOutput(sides.left, 0)
   rs.setOutput(sides.right, 15)
   
   gpu.setForeground(0x008000)
   gpu.setBackground(0x000000)
   gpu.set(7,5,"██████████████████████████████")
   gpu.set(7,6,"██████████████████████████████")
   gpu.set(7,7,"██████████ СВЕТЛОЕ ███████████")
   gpu.set(7,8,"██████████████████████████████")
   gpu.set(7,9,"██████████████████████████████")
   
   gpu.setForeground(0xFF0000)
   gpu.setBackground(0x000000)
   gpu.set(63,5,"██████████████████████████████")
   gpu.set(63,6,"██████████████████████████████")
   gpu.set(63,7,"███████████ ТЕМНОЕ ███████████")
   gpu.set(63,8,"██████████████████████████████")
   gpu.set(63,9,"██████████████████████████████")
end

local function darkBeer()
   rs.setOutput(sides.left, 15)
   rs.setOutput(sides.right, 0)
   
   gpu.setForeground(0xFF0000)
   gpu.setBackground(0x000000)
   gpu.set(7,5,"██████████████████████████████")
   gpu.set(7,6,"██████████████████████████████")
   gpu.set(7,7,"██████████ СВЕТЛОЕ ███████████")
   gpu.set(7,8,"██████████████████████████████")
   gpu.set(7,9,"██████████████████████████████")
   
   gpu.setForeground(0x008000)
   gpu.setBackground(0x000000)
   gpu.set(63,5,"██████████████████████████████")
   gpu.set(63,6,"██████████████████████████████")
   gpu.set(63,7,"███████████ ТЕМНОЕ ███████████")
   gpu.set(63,8,"██████████████████████████████")
   gpu.set(63,9,"██████████████████████████████")
end

local function drawGUILayot()
  gpu.setResolution(100,19)
  gpu.setForeground(0xFFFFFF)
  gpu.setBackground(0x000000)
  term.clear()
   gpu.set(1,1,"╔══════════════════════════════════════[ Контрольная панель ]══════════════════════════════════════╗")
   gpu.set(1,2,"║                                                                                                  ║")
   gpu.set(1,3,"║      Вид производимого пива:                                                                     ║")
   gpu.set(1,4,"║                                                                                                  ║")
   gpu.set(1,5,"║                                                                                                  ║")
   gpu.set(1,6,"║                                                                                                  ║")
   gpu.set(1,7,"║                                                                                                  ║")
   gpu.set(1,8,"║                                                                                                  ║")
   gpu.set(1,9,"║                                                                                                  ║")
  gpu.set(1,10,"╠══════════════════════════════════════════════════════════════════════════════════════════════════╣")
  gpu.set(1,11,"║                                                                                                  ║")
  gpu.set(1,12,"║      Дистилляция воды:                                                                           ║")
  gpu.set(1,13,"║                                                                                                  ║")
  gpu.set(1,14,"║                                                                                                  ║")
  gpu.set(1,15,"║                                                                                                  ║")
  gpu.set(1,16,"║                                                                                                  ║")
  gpu.set(1,17,"║                                                                                                  ║")
  gpu.set(1,18,"║                                                                                                  ║")
  gpu.set(1,19,"╚══════════════════════════════════════════════════════════════════════════════════════════════════╝")
end

local function onTouch(event,adress,x,y,clic,pseudo)
   if x==1 and y==1 then
   computer.pushSignal("quit")
   term.setCursor(1,1)
   elseif x > 7 and x < 37 and y > 5 and y < 9 then
   lightBeer()
   elseif x > 63 and x < 93 and y > 5 and y < 9 then
   darkBeer()
   elseif x > 7 and x < 37 and y > 14 and y < 18 then
   waterDistillationEnabled()
   elseif x > 63 and x < 93 and y > 14 and y < 18 then
   waterDistillationDisabled()
   end
end

-- рисуем интерфейс
term.clear()
drawGUILayot()
waterDistillationEnabled()
lightBeer()

event.listen("touch",onTouch)
event.pull("quit")
event.ignore("touch",onTouch)

-- восстанавливаем параметры экрана
gpu.setResolution(ow, oh)
gpu.setForeground(0xFFFFFF)
gpu.setBackground(0x000000)
term.clear()