dofile (scripts .. "token.lua")
local json = dofile (scripts .. "json.lua")

local img_path = scripts .. "/gismeteo/new_png/"
local min_img_path = scripts .. "/gismeteo/min_icons/min_"

local weather_data = { '','','' }
local need_count = 4
local xs = { 20, 112, 203, 282 } -- положение каждого элемента по горизонтали

function weather()
    local date = os.date ("*t")
    weather_now()
    weather_by_hours(date)
    weather_by_days(date)
end

function get_weather(key, type, params)
    local url = "curl -H 'X-Gismeteo-Token: "..token.."' 'https://api.gismeteo.net/v2/weather/"..type.."/4517/"..params.."'"
    local f = io.popen(url)
    weather_data[key] = f:read("*a")
    f:close()
end

function weather_now()
    if weather_data[1] == '' or os.date("%M:%S") == '00:01' then
        get_weather(1, 'current', '')
    end
    local response = json.decode(weather_data[1]).response
    local temp = string.gsub(response.temperature.air.C, ",", ".")
    local comf = string.gsub(response.temperature.comfort.C, ",", ".")
    text_by_left ({x=10,  y=770}, temp, '0x02c3fa', 'LED', '58')
    text_by_left ({x=0,   y=787}, comf, def.color, 'LED', '38')
    text_by_right({x=250, y=755}, format_wind(response.wind.direction.scale_8), def.color, 'Arrows', '35')
    text_by_right({x=270, y=750}, response.wind.speed.m_s, def.color, 'LED', '18')
    text_by_right({x=300, y=750}, 'm/s', def.color, 'LED', '12')
    text_by_right({x=240, y=770}, response.pressure.mm_hg_atm, def.color, 'LED', '18')
    text_by_right({x=300, y=770}, 'мм.рт.ст.', def.color, def.font, '12')
    text_by_right({x=300, y=787}, response.description.full, def.color, def.font, '12')
    display_image( { img = img_path..response.icon..'.png', coord = { x = 130, y = 730 } } )
end

function weather_by_hours(now_date)
    if weather_data[2] == '' or os.date("%M:%S") == '00:06' then
        get_weather(2,'forecast', '?days=2')
    end
    local response = json.decode(weather_data[2]).response
    local counter = 1
    local ys = { 808, 825, 870 } -- положение каждого жлемента по вертикали
    for i in pairs(response) do
        local date = os.date("*t", response[i]['date']['unix'])
        if counter <= need_count and (date.hour > now_date.hour or date.day > now_date.day or date.month > now_date.month or date.year > now_date.year) then
            local temp = response[i]['temperature']['air']['C']
            text_by_center({x=xs[counter], y=ys[1]}, date.hour..':00', def.color, def.font, def.size)
            text_by_center({x=xs[counter], y=ys[3]}, temp..'°', temp_color(temp), def.font, def.size)
            display_image ({ img = min_img_path..response[i]['icon']..'.png', coord = { x = xs[counter]-35/2, y = ys[2] }} )
            local wind = format_wind(response[i].wind.direction.scale_8)
            text_by_center({x=xs[counter]-10, y=ys[3]-24}, wind, '0x000000', 'Arrows', 36)
            text_by_center({x=xs[counter]-10, y=ys[3]-25}, wind, def.color, 'Arrows', 27)
            counter = counter+1
        end
        if counter > need_count then break end
    end
end

function weather_by_days(now_date)
    if weather_data[3] == '' or os.date("%M:%S") == '00:11' then
        get_weather(3,'forecast/aggregate', '?days=5')
    end
    local response = json.decode(weather_data[3]).response
    local counter  = 1
    local ys = { 898, 915, 960, 974 } -- положение каждого жлемента по вертикали
    for i in pairs(response) do
        local date = os.date("*t", response[i]['date']['unix'])
        if counter <= need_count and (date.day > now_date.day or date.month > now_date.month or date.year > now_date.year) then
            local temp_max = response[i]['temperature']['air']['max']['C']
            local temp_min = response[i]['temperature']['air']['min']['C']
            text_by_center({x=xs[counter],   y=ys[1]}, date.day..'.'..get_weekday(date.wday), def.color, def.font, def.size)
            text_by_center({x=xs[counter]-5, y=ys[3]}, temp_max..'°', temp_color(temp_max), def.font, def.size)
            text_by_center({x=xs[counter]+5, y=ys[4]}, temp_min..'°', temp_color(temp_min), def.font, def.size)
            display_image ( { img = min_img_path..response[i]['icon']..'.png', coord = { x = xs[counter]-35/2, y = ys[2] }} )
            local wind = format_wind(response[i].wind.direction.max.scale_8)
            text_by_center({x=xs[counter]-10, y=ys[3]-24}, wind,'0x000000', 'Arrows', 36)
            text_by_center({x=xs[counter]-10, y=ys[3]-25}, wind,def.color, 'Arrows', 27)
            counter = counter+1
        end
        if counter > need_count then break end
    end
end

function format_wind(wind)
    local arrows = {
        '',  -- Штиль
        'd', -- Северный
        'f', -- Северо-восточный
        'b', -- Восточный
        'e', -- Юго-восточный
        'c', -- Южный
        'g', -- Юго-западный
        'a', -- Западный
        'h', -- Северо-западный
    }

    return arrows[wind+1]
end

function temp_color(temp)
    if temp > 30  then return "0xcc0000" end
    if temp > 20  then return "0xffb4bb" end
    if temp > 10  then return "0xffe0ba" end
    if temp > 0   then return "0xfce3c4" end
    if temp == 0  then return  def.color end
    if temp > -10 then return "0xbae1ff" end
    if temp > -20 then return "0x0ad1f3" end
    if temp > -30 then return "0x3c82e2" end
    if -30 > temp then return "0x0000cc" end
end
