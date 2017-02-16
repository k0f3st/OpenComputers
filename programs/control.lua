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

local function fireButtonEnabled()
  gpu.setForeground(0x008000)
  gpu.setBackground(0x000000)
  gpu.set(62,2,"██████████████████████████████████████")
  gpu.set(62,3,"███████████████ ЗАПУСК ███████████████")
  gpu.set(62,4,"███████████████ ЛАЗЕРА ███████████████")
  gpu.set(62,5,"██████████████████████████████████████")
end

local function fireButtonDisabled()
  gpu.setForeground(0xFF0000)
  gpu.setBackground(0x000000)
  gpu.set(62,2,"██████████████████████████████████████")
  gpu.set(62,3,"███████████████ ЗАПУСК ███████████████")
  gpu.set(62,4,"███████████████ ЛАЗЕРА ███████████████")
  gpu.set(62,5,"██████████████████████████████████████")
end

local function drawGUILayot()
  gpu.setResolution(100,10)
  gpu.setForeground(0x1CDCF2)
  gpu.setBackground(0x000000)
  term.clear()
   gpu.set(1,1,"╔══════════════════════════════════════════[ АРХИМЕД II ]═══╦══════════════════════════════════════╗")
   gpu.set(1,2,"║                                                           ║                                      ║")
   gpu.set(1,3,"║                                                           ║                                      ║")
   gpu.set(1,4,"║                                                           ║                                      ║")
   gpu.set(1,5,"║                                                           ║                                      ║")
   gpu.set(1,6,"╠═══════════════════════════════════════════════════════════╩══════════════════════════════════════╣")
   gpu.set(1,7,"║                                                                                                  ║")
   gpu.set(1,8,"║                                                                                                  ║")
   gpu.set(1,9,"║                                                                                                  ║")
  gpu.set(1,10,"╚══════════════════════════════════════════════════════════════════════════════════════════════════╝")
end

local function firingLaser()
   fireButtonDisabled()
   rs.setOutput(sides.right,15)

   for v = 0, 98 do
   gpu.set(2+v,7,"█")
   gpu.set(2+v,8,"█")
   gpu.set(2+v,9,"█")
   os.sleep(0.5)
   gpu.set(43,8,"НАВЕДЕНИЕ...")
   end
   
   os.sleep(3)
   gpu.set(1,7,"║                                                                                                  ║")
   gpu.set(42,8,"ЦЕЛЬ ПОРАЖЕНА!")
   gpu.set(1,9,"║                                                                                                  ║")
   
   os.sleep(5)
   gpu.set(1,7,"║                                                                                                  ║")
   gpu.set(1,8,"║                                                                                                  ║")
   gpu.set(1,9,"║                                                                                                  ║")
   
   rs.setOutput(sides.right,0)
   fireButtonEnabled()
end

local function onTouch(event,adress,x,y,clic,pseudo)
   if x==1 and y==1 then
   computer.pushSignal("quit")
   term.setCursor(1,1)
   elseif x > 60 and x < 100 and y > 1 and y < 5 then
   firingLaser()
   end
end

-- рисуем интерфейс
term.clear()
drawGUILayot()

event.listen("touch",onTouch)
event.pull("quit")
event.ignore("touch",onTouch)

-- восстанавливаем параметры экрана
gpu.setResolution(ow, oh)
gpu.setForeground(0xFFFFFF)
gpu.setBackground(0x000000)
term.clear()