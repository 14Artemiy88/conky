local extents = cairo_text_extents_t:create()
def = {
    size = 12,
    font = 'Ubuntu Nerd Font',
    size_mono = 10,
    font_mono ='FiraCode Nerd Font Mono',
    color = '0xcccccc'
}
slant_normal  = CAIRO_FONT_SLANT_NORMAL
weight_normal = CAIRO_FONT_WEIGHT_NORMAL
weight_bold   = CAIRO_FONT_WEIGHT_BOLD

---------------------------
--- Вывод текста слева ---
---------------------------
function text_by_left(coord, text, color, font, size, slant, weight)
    cairo_set_font_size (cr, size)
	cairo_select_font_face (cr, font, slant, weight)
    cairo_set_source_rgba (cr, rgb_to_r_g_b(color, 1))
	cairo_text_extents(cr, text, extents)
	cairo_move_to (cr, coord.x, coord.y)
	cairo_show_text (cr, text)
end

---------------------------
--- Вывод текста справа ---
---------------------------
function text_by_right(coord, text, color, font, size, slant, weight)
    cairo_set_font_size (cr, size)
	cairo_select_font_face (cr, font, slant, weight)
    cairo_set_source_rgba (cr, rgb_to_r_g_b(color, 1))
	cairo_text_extents(cr, text, extents)
	cairo_move_to (cr, coord.x-(extents.width + extents.x_bearing),coord.y)
	cairo_show_text (cr, text)
end

------------------------------
--- Вывод текста по центру ---
------------------------------
function text_by_center(coord, text, color, font, size, slant, weight)
    cairo_set_font_size (cr, size)
	cairo_select_font_face (cr, font, slant, weight)
    cairo_set_source_rgba (cr, rgb_to_r_g_b(color, 1))
    cairo_text_extents(cr, text, extents)
    cairo_move_to (cr, coord.x - (extents.width/2 + extents.x_bearing), coord.y - (extents.height/2 + extents.y_bearing))
    cairo_show_text (cr, text)
end

------------------------
--- Вывести картинку ---
------------------------
function display_image(icon)
    local image_bg = cairo_image_surface_create_from_png (icon.img)
    cairo_set_source_surface (cr, image_bg, icon.coord.x, icon.coord.y)
    cairo_paint (cr)
    cairo_surface_destroy (image_bg)
end

----------------------
--- Вывести массив ---
----------------------
function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

-----------------------------
--- Перекодирвоание цвета ---
-----------------------------
function rgb_to_r_g_b(color, alpha)
    return ((color / 0x10000) % 0x100) / 255., ((color / 0x100) % 0x100) / 255., (color % 0x100) / 255., alpha
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
   local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
         table.insert(t, cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end

-----------------------------------
--- Разбить строку на подстроки ---
-----------------------------------
function string_to_strings(str,  length)
    local str_strings = {}
    if string.len(str) > length then
        local new_string = ''
        local str_arr = split(str, " ")
        for i in pairs(str_arr) do
            new_string = new_string .. ' ' .. str_arr[i]
            if string.len(new_string) >= length or i == #str_arr then
                table.insert(str_strings, new_string)
                new_string = ""
            end
        end
    else
        str_strings = {str}
    end

    return str_strings
end

---------------------------------------
--- Удалить пробелы по краям строки ---
---------------------------------------
function trim(s)
   return s:match "^%s*(.-)%s*$"
end

----------------------------------
--- Получить цвет из градиента ---
----------------------------------
function gradient(N, alpha)
    if N == nil then N = update_num end
    N = (N % 360) * 4.25 / 255
    if N <= 1 then return 1,     N,     0,     alpha end
    if N <= 2 then return 2 - N, 1,     0,     alpha end
    if N <= 3 then return 0,     1,     N - 2, alpha end
    if N <= 4 then return 0,     4 - N, 1,     alpha end
    if N <= 5 then return N - 4, 0,     1,     alpha end
    if N <= 6 then return 1,     0,     6 - N, alpha end
end

-----------------------------
--- День недели по номеру ---
-----------------------------
function get_weekday(day)
    local days = {'Вс', 'Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб'}

    return days[day]
end