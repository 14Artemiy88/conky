require 'cairo'

scripts = '/home/artemiy/.conky/scripts/'
json = dofile(scripts .. "json.lua")

dofile(scripts .. "params.lua")
dofile(scripts .. "frames.lua")
dofile(scripts .. "bars.lua")
dofile(scripts .. "weather.lua")
dofile(scripts .. "functions.lua")
dofile(scripts .. "playlist.lua")
dofile(scripts .. "timer.lua")

function conky_main()
    ---=====================================================================---
    if conky_window == nil then
        return
    end
    local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)
    cr = cairo_create(cs)
    update_num = tonumber(conky_parse('${updates}'))
    ---=====================================================================---
    text_by_left({ x = 3, y = 1020 }, 'alt+SysRq+R / ctrl+alt+F2', { size = 10 })
    weather()
    timer()
    cpu_frame()
    mem_frame()
    cpu_bar()
    for k in pairs(params) do
        draw_dash_bar(params[k])
    end

    player()

    cairo_destroy(cr)
    cr = nil
end
