local unicode = require("unicode")
local component = require("component")
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
		url = "http://ep256.streamr.ru"
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

	gpu.set(1,3,"                                                        ")
	gpu.set(1,4,"        ***   ***    ***    **    ***   ***   **        ")
	gpu.set(1,5,"       *     *       *  *  *  *   *  *   *   *  *       ")
	gpu.set(1,6,"        **   *       ***   ****   *  *   *   *  *       ")
	gpu.set(1,7,"          *  *       *  *  *  *   *  *   *   *  *       ")
	gpu.set(1,8,"       ***    ***    *  *  *  *   **    ***   **        ")
	gpu.set(1,9,"                                                        ")
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

	gpu.set(1,21,"")
	gpu.set(1,22,"")
	gpu.set(1,23,"")
	gpu.set(1,24,"")
	gpu.set(1,25,"")
	gpu.set(1,26,"")
	gpu.set(1,27,"")
end

local function drawFourthStation()
	if radioStations.currentStation == 4 then
		gpu.setBackground(config.colors.active)
		gpu.setForeground(config.colors.bg)
	else
		gpu.setBackground(config.colors.bg)
		gpu.setForeground(config.colors.inactive)
	end

	gpu.set(1,30,"")
	gpu.set(1,31,"")
	gpu.set(1,32,"")
	gpu.set(1,33,"")
	gpu.set(1,34,"")
	gpu.set(1,35,"")
	gpu.set(1,36,"")
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
	
	drawToolbar()
end


local function switchStation(i)
	if i == 1 then
		if radioStations.currentStation < #radioStations then
			radioStations.currentStation = radioStations.currentStation + 1
			radio.stop()
			radio.setURL(radioStations[radioStations.currentStation].url)
			radio.start()
		end
	else
		if radioStations.currentStation > 1 then
			radioStations.currentStation = radioStations.currentStation - 1
			radio.stop()
			radio.setURL(radioStations[radioStations.currentStation].url)
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

drawMainElements()

radio.stop()
radio.setURL(radioStations[radioStations.currentStation].url)
radio.start()

while true do
	local e = {event.pull()}
	if e[1] == "touch" then
		if e[5] == 0 then
			if e[3] > 60 and e[3] < 66 and e[4] > 43 and e[4] < 49 then
				os.sleep(0.2)
				switchStation(-1)
			elseif e[3] > 95 and e[3] < 136 and e[4] > 43 and e[4] < 49 then
				os.sleep(0.2)
				switchStation(1)
			elseif e[3] > 65 and e[3] < 81 and e[4] > 43 and e[4] < 49 then
				volume(1)
				os.sleep(0.2)
			elseif e[3] > 80 and e[3] < 96 and e[4] > 43 and e[4] < 49 then
				volume(-1)
				os.sleep(0.2)
			end
		end

	elseif e[1] == "key_up" then
		if e[3] == 'q' then
			radio.stop()
			gpu.setResolution(ow, oh)
			gpu.setForeground(0xFFFFFF)
			gpu.setBackground(0x000000)
			term.clear()
		end
	end
end