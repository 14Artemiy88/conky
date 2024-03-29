local extents = cairo_text_extents_t:create()
def = {
    size = 12,
    font = 'Ubuntu Nerd Font',
    font_emoji = 'Noto Emoji',
    color = '0xcccccc'
}
slant_normal = CAIRO_FONT_SLANT_NORMAL
weight_normal = CAIRO_FONT_WEIGHT_NORMAL
weight_bold = CAIRO_FONT_WEIGHT_BOLD

---------------------------
--- Вывод текста слева ---
---------------------------
function text_by_left(coord, text, font_params, string_param)
    string_param = prepare_string_param(string_param)
    draw_text({ x = coord.x, y = coord.y }, text, font_params, string_param)
end

---------------------------
--- Вывод текста справа ---
---------------------------
function text_by_right(coord, text, font_params, string_param)
    string_param = prepare_string_param(string_param)
    draw_text({ position = 'right', x = coord.x, y = coord.y }, text, font_params, string_param)
end

------------------------------
--- Вывод текста по центру ---
------------------------------
function text_by_center(coord, text, font_params)
    draw_text({ position = 'center', x = coord.x, y = coord.y }, text, font_params, string_param)
end

------------------------
--- Вывести картинку ---
------------------------
function display_image(icon)
    local image_bg = cairo_image_surface_create_from_png(icon.img)
    cairo_set_source_surface(cr, image_bg, icon.coord.x, icon.coord.y)
    cairo_paint(cr)
    cairo_surface_destroy(image_bg)
end

----------------------------------
--- Прогресс альбома по трекам ---
----------------------------------
function draw_album_progress_line(coord, parts, lengths)
    local start = coord.x_start
    local length = coord.x_end - start + 2
    local current_start, current_length

    -- все треки альбома --
    for i = 1, parts.total do
        local part_length = length * lengths.tracks[i] / lengths.total
        local color, alpha = def.color, .3
        if i < parts.current then
            color, alpha = '0x3daee9', 1
        end
        if i == parts.current then
            current_start = start
            current_length = part_length
            color, alpha = '0x3daee9', .3
        end
        cairo_move_to(cr, start, coord.y)
        cairo_line_to(cr, start + part_length - 2, coord.y)
        cairo_set_line_width(cr, 2)
        cairo_set_source_rgba(cr, get_color(color, alpha))
        cairo_stroke(cr)
        start = start + part_length
    end

    -- прогресс текущего трека --
    cairo_move_to(cr, current_start, coord.y)
    cairo_line_to(cr, current_start + (current_length - 2) * parts.pass, coord.y)
    cairo_set_line_width(cr, 2)
    cairo_set_source_rgba(cr, get_color('0x3daee9', 1))
    cairo_stroke(cr)
end

----------------------
--- Вывести массив ---
----------------------
function dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k, v in pairs(o) do
            if type(k) ~= 'number' then
                k = '"' .. k .. '"'
            end
            s = s .. '[' .. k .. '] = ' .. dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

-----------------------------
--- Перекодирвоание цвета ---
-----------------------------
function get_color(color, alpha)
    if type(color) == 'string' then
        return ((color / 0x10000) % 0x100) / 255., ((color / 0x100) % 0x100) / 255., (color % 0x100) / 255., alpha
    end

    return gradient(color, alpha)
end

------------------------------------
--- Выполнить консольную команду ---
------------------------------------
function read_CLI(command)
    local file = io.popen(command)
    local output = file:read("*a")
    file:close()
    return output
end

-----------------------------------
--- Разбить строку на подстроки ---
-----------------------------------
function split(str, pat)
    local t = {}
    local fpat = "(.-)" .. pat
    local last_end = 1
    local s, e, cap = str:find(fpat, 1)
    while s do
        if s ~= 1 or cap ~= "" then
            table.insert(t, cap)
        end
        last_end = e + 1
        s, e, cap = str:find(fpat, last_end)
    end
    if last_end <= #str then
        cap = str:sub(last_end)
        table.insert(t, cap)
    end
    return t
end

--------------------------------
--- Разбить текст по строкам ---
--------------------------------
function get_text_strings(text, width)
    local text_strings = {}
    local string_part = ''
    local str_arr = split(text, " ")
    for i in pairs(str_arr) do
        local candidate = trim(string_part .. ' ' .. str_arr[i])
        cairo_text_extents(cr, candidate, extents)
        if extents.width > width then
            table.insert(text_strings, string_part)
            string_part = str_arr[i]
        else
            string_part = candidate
        end
        if i == #str_arr then
            table.insert(text_strings, string_part)
            break
        end
    end

    return text_strings
end

---------------------------------------
--- Удалить пробелы по краям строки ---
---------------------------------------
function trim(s)
    return s:match "^%s*(.-)%s*$"
end

------------------------
--- Декодировать URL ---
------------------------
function url_decode(url)
    local hex_to_char = function(x)
        return string.char(tonumber(x, 16))
    end
    return url:gsub("%%(%x%x)", hex_to_char)
end

----------------------------------
--- Получить цвет из градиента ---
----------------------------------
function gradient(N, alpha)
    if N == nil then
        N = update_num
    end
    N = (N % 360) * 4.25 / 255
    if N <= 1 then
        return 1, N, 0, alpha
    end
    if N <= 2 then
        return 2 - N, 1, 0, alpha
    end
    if N <= 3 then
        return 0, 1, N - 2, alpha
    end
    if N <= 4 then
        return 0, 4 - N, 1, alpha
    end
    if N <= 5 then
        return N - 4, 0, 1, alpha
    end
    if N <= 6 then
        return 1, 0, 6 - N, alpha
    end
end

-----------------------------
--- День недели по номеру ---
-----------------------------
function get_weekday(day)
    local days = { 'Вс', 'Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб' }

    return days[day]
end

------------------------------------
--- Проверка существования файла ---
------------------------------------
function file_exists(name)
    local f = io.open(name, "r")
    if f ~= nil then
        io.close(f)
        return true
    else
        return false
    end
end

------------------------
--- Отрисовка текста ---
------------------------
function draw_text(coord, text, font_params, string_param)
    font_params = set_def_font_params(font_params)
    cairo_set_font_size(cr, font_params.size)
    cairo_select_font_face(cr, font_params.font, nil, font_params.weight)
    local x, y = get_coord(text, coord)
    if font_params.background ~= nil then
        cairo_move_to(cr, coord.x - 17, coord.y)
        cairo_line_to(cr, coord.x + extents.width, coord.y)
        --- TODO: переделать с учётом string_param.width
        cairo_set_line_width(cr, font_params.size + 7)
        cairo_set_source_rgba(cr, get_color(font_params.background.color, font_params.background.alpha))
        cairo_stroke(cr)
    end
    cairo_set_source_rgba(cr, get_color(font_params.color, 1))
    if string_param ~= nil and extents.width > string_param.width then
        local text_strings = get_text_strings(text, string_param.width)
        if string_param.col == 1 then
            if string_param.suffix == nil then
                string_param.suffix = '…'
            end
            text = text_strings[1] .. string_param.suffix
            x, y = get_coord(text, coord)
            cairo_move_to(cr, x, y)
            cairo_show_text(cr, text)
        else
            if string_param.col == nil then
                string_param.col = #text_strings
            end
            local y_start = y
            for str = 1, string_param.col do
                x, y = get_coord(text_strings[str], coord)
                cairo_move_to(cr, x, y_start)
                cairo_show_text(cr, text_strings[str])
                y_start = y_start + string_param.margin
            end
        end
    else
        cairo_move_to(cr, x, y)
        cairo_show_text(cr, text)
    end
end

--------------------------------------
--- Координаты расположения текста ---
--------------------------------------
function get_coord(text, coord)
    cairo_text_extents(cr, text, extents)
    local x, y = coord.x, coord.y
    if (coord.position == 'right') then
        x, y = coord.x - (extents.width + extents.x_bearing), coord.y
    end
    if (coord.position == 'center') then
        x, y = coord.x - (extents.width / 2 + extents.x_bearing), coord.y - (extents.height / 2 + extents.y_bearing)
    end

    return x, y
end

-------------------------------------
--- Параметры текста по умолчанию ---
-------------------------------------
function set_def_font_params(font_params)
    if font_params == nil then
        font_params = {}
    end
    if font_params.size == nil then
        font_params.size = def.size
    end
    if font_params.font == nil then
        font_params.font = def.font
    end
    if font_params.color == nil then
        font_params.color = def.color
    end

    return font_params
end

------------------------------------
--- Подготовить параметры стркои ---
------------------------------------
function prepare_string_param(string_param)
    if string_param ~= nil and string_param.additional_text ~= nil then
        font_params = set_def_font_params(font_params)
        cairo_set_font_size(cr, font_params.size)
        cairo_select_font_face(cr, font_params.font, nil, font_params.weight)
        cairo_text_extents(cr, string_param.additional_text, extents)
        string_param.width = string_param.width - (extents.width + 3)
    end

    return string_param
end

-------------------------------------------
--- Рисует плеер когда ничего не играет ---
-------------------------------------------
local start_x = 25
local finish_x = 148
local start_y = 625
local finish_y = 703
local text_start_x = math.random(start_x, finish_x)
local text_start_y = math.random(start_y, finish_y)
local xy = { -1, 1 }
local xv = xy[math.random(1, 2)]
local yv = xy[math.random(1, 2)]
function draw_empty_player()
    local text = 'Ничего не играет'
    if text_start_y <= start_y and yv < 0 then
        yv = 1
    end
    if text_start_y >= finish_y and yv > 0 then
        yv = -1
    end
    if text_start_x <= start_x and xv < 0 then
        xv = 1
    end
    if text_start_x >= finish_x and xv > 0 then
        xv = -1
    end
    text_start_x = text_start_x + 1 * xv
    text_start_y = text_start_y + 1 * yv
    text_by_left({ x = text_start_x, y = text_start_y }, text, { color = '0x666666', size = 20 })
    bars_background()
end

--- фон ---
function bars_background()
    local start = 600
    local step = 10
    for i = 0, 10 do
        draw_dash_bar({
            height = 7, width = 310, seg_width = 3, seg_margin = 3, start_x = 4, y = start + i * step, value = 100, colors = {
                { color = 'new_gradient', alpha = .1 },
                { color = 'new_gradient', alpha = .1 },
            } })
        i = i + 1
    end
end
