local unicode = require("unicode")
local term = require('term')
local os = require("os")
local component = require("component")
local event = require("event")
local ecs = require("ECSAPI")
local gpu = component.gpu
local radio

if not component.isAvailable("openfm_radio") then
	ecs.error("Этой программе требуется радио из мода OpenFM.")
	return
else
	radio = component.openfm_radio
end

local ow, oh = gpu.getResolution()

local stationNameLimit = 8
local spaceBetweenStations = 8
local countOfStationsLimit = 9
local lineHeight

local config = {
	colors = {
		bg = 0x1b1b1b, -- серый
		active = 0xFFA800, -- золотой
		toolbar = 0xBBBBBB,
		inactive = 0xAAAAAA,
	},
}

local radioStations = {
	currentStation = 1,
	{
		name = "SC Radio",
		url = "http://37.46.135.11:8000/live"
	},
	{
		name = "k0f3st local",
		url = "http://85.113.41.240:8001/sc-hitech"
	},
	{
		name = "Европа Плюс",
		url = "http://ep256.hostingradio.ru:8052/europaplus256.mp3"
	},
	{
		name = "Radio Record",
		url = "http://online.radiorecord.ru:8101/rr_128.m3u"
	},
}

local function drawFirstStation()
	if radioStations.currentStation == 1 then
		gpu.setBackground(config.colors.active)
		gpu.setForeground(config.colors.bg)
	else
		gpu.setBackground(config.colors.bg)
		gpu.setForeground(config.colors.inactive)
	end

	gpu.set(1,3,"                                                                              ")
	gpu.set(1,4,"                   ***   ***    ***    **    ***   ***   **                   ")
	gpu.set(1,5,"                  *     *       *  *  *  *   *  *   *   *  *                  ")
	gpu.set(1,6,"                   **   *       ***   ****   *  *   *   *  *                  ")
	gpu.set(1,7,"                     *  *       *  *  *  *   *  *   *   *  *                  ")
	gpu.set(1,8,"                  ***    ***    *  *  *  *   **    ***   **                   ")
	gpu.set(1,9,"                                                                              ")
end

local function drawSecondStation()
	if radioStations.currentStation == 2 then
		gpu.setBackground(config.colors.active)
		gpu.setForeground(config.colors.bg)
	else
		gpu.setBackground(config.colors.bg)
		gpu.setForeground(config.colors.inactive)
	end

	gpu.set(1,12,"                                                                              ")
	gpu.set(1,13,"       *  *  ****  ****  ***   ***  *****    *     **    ***   **   *         ")
	gpu.set(1,14,"       * *   *  *  *       *  *       *      *    *  *  *     *  *  *         ")
	gpu.set(1,15,"       **    *  *  ***   ***   **     *      *    *  *  *     ****  *         ")
	gpu.set(1,16,"       * *   *  *  *       *     *    *      *    *  *  *     *  *  *         ")
	gpu.set(1,17,"       *  *  ****  *     ***  ***     *      ***   **    ***  *  *  ***       ")
	gpu.set(1,18,"                                                                              ")
end

local function drawThirdStation()
	if radioStations.currentStation == 3 then
		gpu.setBackground(config.colors.active)
		gpu.setForeground(config.colors.bg)
	else
		gpu.setBackground(config.colors.bg)
		gpu.setForeground(config.colors.inactive)
	end

	gpu.set(1,21,"                                                                              ")
	gpu.set(1,22,"               ****  ***   ***    **   ****   **         *                    ")
	gpu.set(1,23,"               *     *  *  *  *  *  *  *  *  *  *        *                    ")
	gpu.set(1,24,"               ***   ***   ***   *  *  *  *  ****    * * * * *                ")
	gpu.set(1,25,"               *     *  *  *     *  *  *  *  *  *        *                    ")
	gpu.set(1,26,"               ****  ***   *      **   *  *  *  *        *                    ")
	gpu.set(1,27,"                                                                              ")
end

local function drawFourthStation()
	if radioStations.currentStation == 4 then
		gpu.setBackground(config.colors.active)
		gpu.setForeground(config.colors.bg)
	else
		gpu.setBackground(config.colors.bg)
		gpu.setForeground(config.colors.inactive)
	end

	gpu.set(1,30,"                                                                              ")
	gpu.set(1,31,"      ***    **    ***   ***   **     ***   ****   ***   **   ***   ***       ")
	gpu.set(1,32,"      *  *  *  *   *  *   *   *  *    *  *  *     *     *  *  *  *  *  *      ")
	gpu.set(1,33,"      ***   ****   *  *   *   *  *    ***   ***   *     *  *  ***   *  *      ")
	gpu.set(1,34,"      *  *  *  *   *  *   *   *  *    *  *  *     *     *  *  *  *  *  *      ")
	gpu.set(1,35,"      *  *  *  *   **    ***   **     *  *  ****   ***   **   *  *  ***       ")
	gpu.set(1,36,"                                                                              ")
end

local function drawToolbar()
	gpu.setBackground(config.colors.bg)
	gpu.setForeground(config.colors.toolbar)
	gpu.set(61,44,"  *         *                        *  ")
	gpu.set(61,45," *          *                         * ")
	gpu.set(61,46,"*       * * * * *      * * * * *       *")
	gpu.set(61,47," *          *                         * ")
	gpu.set(61,48,"  *         *                        *  ")
end

local function drawMainElements()
	gpu.setResolution(160, 50)
	term.clear()
	drawFirstStation()
	drawSecondStation()
	drawThirdStation()
	drawFourthStation()
	drawToolbar()
end


local function switchStation(i)
	if i == 1 then
		if radioStations.currentStation < #radioStations then
			radioStations.currentStation = radioStations.currentStation + 1
			drawFirstStation()
			drawSecondStation()
			drawThirdStation()
			drawFourthStation()

			radio.stop()
			os.sleep(1)
			radio.setURL(radioStations[radioStations.currentStation].url)
			os.sleep(1)
			radio.start()
		end
	else
		if radioStations.currentStation > 1 then
			radioStations.currentStation = radioStations.currentStation - 1
			drawFirstStation()
			drawSecondStation()
			drawThirdStation()
			drawFourthStation()

			radio.stop()
			os.sleep(1)
			radio.setURL(radioStations[radioStations.currentStation].url)
			os.sleep(1)
			radio.start()
		end
	end
end

local function volume(i)
	if i == 1 then
		radio.volUp()
	else
		radio.volDown()
	end
end

local function onTouch(event,adress,x,y,clic,pseudo)
	if x == 1 and y == 1 then
		computer.pushSignal("quit")
   		term.setCursor(1,1)
	elseif x > 60 and x < 66 and y > 43 and y < 49 then
		os.sleep(0.2)
		switchStation(-1)
	elseif x > 95 and x < 102 and y > 43 and y < 49 then
		os.sleep(0.2)
		switchStation(1)
	elseif x > 65 and x < 81 and y > 43 and y < 49 then
		volume(1)
		os.sleep(0.2)
	elseif x > 80 and x < 96 and y > 43 and y < 49 then
		volume(-1)
		os.sleep(0.2)
	end
end

drawMainElements()

radio.stop()
radio.setURL(radioStations[radioStations.currentStation].url)
radio.start()

event.listen("touch",onTouch)
event.pull("quit")
event.ignore("touch",onTouch)

radio.stop()
-- восстанавливаем параметры экрана
gpu.setResolution(ow, oh)
gpu.setForeground(0xFFFFFF)
gpu.setBackground(0x000000)
term.clear()