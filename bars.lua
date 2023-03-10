local cpu_graph = {}

-------------------------------------
--- Рисует прогрессбар чёрточками ---
-------------------------------------
function draw_dash_bar(bar)
    local start_x = bar.start_x
    local value = bar.value
    if type(bar.value) ~= 'number' then
        if bar.value == 'gpu' then
            value = conky_gpu()
        else
            value = get_value(bar.value)
        end
    end

    local seg_count = math.ceil(bar.width / (bar.seg_width + bar.seg_margin))
    local active_seg = math.ceil(seg_count * value / 100)
    local coord = { active_seg, seg_count - active_seg }
    local color
    for k = 1, 2 do
        for i = 1, coord[k] do
            cairo_move_to(cr, start_x, bar.y)
            cairo_set_line_width(cr, bar.height)
            if i == 1 then
                cairo_move_to(cr, start_x, bar.y)
            end
            start_x = start_x + bar.seg_width
            cairo_line_to(cr, start_x, bar.y)

            start_x = start_x + bar.seg_margin
            cairo_move_to(cr, start_x, bar.y)
            color = bar.colors[k].color
            if color == 'new_gradient' then
                color = update_num + i * 4
            end
            cairo_set_source_rgba(cr, get_color(color, bar.colors[k].alpha))
            cairo_stroke(cr)
        end
    end
end

---------------------------
--- График загрузки CPU ---
---------------------------
function cpu_bar()
    local y = 120
    local start_x = 10
    local seg_width = 3
    local seg_margin = 5
    local width = 485
    local seg_count = math.ceil(width / (seg_width + seg_margin))
    update_cpu_graph()
    for i = update_num - seg_count, update_num do
        cairo_move_to(cr, start_x, y)
        local val = cpu_graph[i]
        if val == nil then
            val = 0
        end
        local height = y - val / 2
        cairo_line_to(cr, start_x, height)
        start_x = start_x + seg_margin
        cairo_move_to(cr, start_x, y)
        local color = { .8, .8, .8 }
        if val > 80 then
            color = { 1, 0.70588235294118, 0.73333333333333 }
        elseif val > 60 then
            color = { 1, 0.87843137254902, 0.72941176470588 }
        elseif val > 30 then
            color = { 1, 0.99607843137255, 0.73333333333333 }
        end
        cairo_set_source_rgba(cr, color[1], color[2], color[3], 1)
        cairo_set_line_width(cr, seg_width)
        cairo_stroke(cr)
    end
end

--- Записывает показания CPU ---
function update_cpu_graph()
    cpu_graph[update_num] = get_value('cpu')
end

--- Значение conky параметра ---
function get_value(name)
    local str = string.format('${%s}', name)
    str = conky_parse(str)

    return tonumber(str)
end

--- Переводит в проценты ---
function get_percents(val, total)
    return val / total * 100
end

--- GPU % ---
function conky_gpu()
    local gpu = conky_parse('${exec nvidia-smi | grep % | cut -c 37-40}')
    if gpu == nil then
        gpu = 0
    end

    return get_percents(gpu, 2048)
end
