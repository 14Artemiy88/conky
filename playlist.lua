function player()
    if (
            mopidy_player() == false and
            vlc_player() == false and
            browser_player() == false
        ) then
        text_by_left ({x=25, y=650}, 'Ничего не играет', '0x666666', def.font, 20, nil, nil)
    end
end

function mopidy_player()
    local current_t_a_al_d = trim(read_CLI('mpc current -f %title%/%artist%/%album%/%date%'))
    if string.len(current_t_a_al_d) > 0 then
        local current,artist,album,date = current_t_a_al_d:match('(.*)/(.*)/(.*)/(%d*)')
        local tt_ct_p_tc_pt = read_CLI('mpc status %totaltime%/%currenttime%/%songpos%/%length%/%percenttime%')
        local tt_m,tt_s,ct_m,ct_s,current_num,total_count,_,pt = tt_ct_p_tc_pt:match('(%d+):(%d+)/(%d+):(%d+)/(%d+)/(%d+)/(%s+)(%d+)')
        local u_el_time  = (tt_m * 60 + tt_s) - (ct_m * 60 + ct_s)
        local el_time    = os.date("%M:%S", u_el_time)
        local count = 5
        current_num = tonumber(current_num)
        local start = tonumber(total_count - count + 1)
        if total_count - current_num >= count then
            start = current_num
        end
        local stop = start + count
        local el_total_time = 0
        local y_start = 635
        local playlist = split(read_CLI('mpc playlist -f %title%/%time%'), '\n')
        for N in pairs(playlist) do
            local song, time_m, time_s = playlist[N]:match('(.*)/(%d+):(%d+)')
            if N > current_num then
                el_total_time = el_total_time + time_m * 60 + time_s
            end
            if start <= N and N < stop then
                local y_step = 18
                local color = def.color
                local song_time = time_m .. ':' .. time_s
                if song == current then
                    el_total_time = el_total_time + u_el_time
                    color = '0x3daee9'
                    song_time = string.gsub('-'..el_time, "-0", "-")
                end
                song = string_to_strings(song, 33)
                if song[2] ~= nil then song[1] = song[1] .. '…' end
                text_by_left ({x=53, y=y_start}, trim(song[1]), color, def.font, def.size)
                text_by_right({x=313, y=y_start}, song_time, color, def.font, def.size)
                y_start = y_start + y_step
            end
        end

        local total_time
        if el_total_time >= 3600 then
            total_time = os.date("-%X", el_total_time-5*60*60)
        else
            total_time = os.date("-%M:%S", el_total_time)
        end
        if string.len(date) > 0 then date = ' ('..date..')' else date = '' end
        draw_dash_bar({
            height = 7,
            width = 310,
            seg_width = 3,
            seg_margin = 3,
            start_x = 4,
            y = 612,
            value = tonumber(pt),
            colors = {
                { color = '0xcc0000', alpha = 1 },
                { color = def.color, alpha = .3 },
            }
        })
        text_by_left  ({x=5, y=600}, artist, def.color, def.font, def.size, nil, weight_bold)
        text_by_right ({x=313, y=600}, album..date, def.color, def.font, def.size)
        display_image ({ coord = { x = 5, y = 625 }, img = '/tmp/album_cover.png'} )
        text_by_center( {x=23, y=685}, current_num..'/'..total_count, def.color, def.font, def.size )
        text_by_center( {x=23, y=702}, string.gsub(total_time, "-0", "-"), def.color, def.font, def.size )

        return true
    end

    return false
end

function browser_player()
    local params = {
        'artist',
        'title',
        'mpris:length',
        'position',
        'duration(mpris:length - position)',
        'kde:mediaSrc',
        'mpris:artUrl',
    }
    local command = "playerctl -p plasma-browser-integration metadata -f '{{ %s }}'"
    local player = trim(read_CLI(string.format(command, table.concat(params,' }}💩{{ '))))
    if string.len(player) > 0 then
        return draw_player(player:match('(.*)💩(.*)💩(.*)💩(.*)💩(.*)💩(.*)💩(.*)'))
    end

    return false
end

function vlc_player()
    local params = {
        'title',
        'mpris:length',
        'position',
        'duration(mpris:length - position)',
    }
    local command = "playerctl -p vlc metadata -f '{{ %s }}'"
    --print(command)
    local player = trim(read_CLI(string.format(command, table.concat(params,' }}💩{{ '))))
    if string.len(player) > 0 then
        return draw_player('VLC', player:match('(.*)💩(.*)💩(.*)💩(.*)'))
    end

    return false
end

function draw_player(artist, title, total_time, playing_time, el_time, mediaSrc, img)
    draw_dash_bar({
        height = 7,
        width = 310,
        seg_width = 3,
        seg_margin = 3,
        start_x = 4,
        y = 650,
        value = tonumber(playing_time/total_time * 100),
        colors = {
            { alpha = 1 },
            { color = def.color, alpha = .3 },
        }
    })
    local start = 673
    local step = 15
    local title_parts = string_to_strings(title, 30)
    for title_part in pairs(title_parts) do
        text_by_left ({x=55, y=start}, trim(title_parts[title_part]), def.color, def.font, def.size, nil, nil)
        start = start + step
    end

    text_by_left ({x=5, y=637}, artist, def.color, def.font, def.size, nil, nil)
    text_by_right( {x=313, y=673}, '-'..el_time, def.color, def.font, def.size, nil, nil)
    if mediaSrc ~= nil then
        get_img(mediaSrc, img)
    else
        display_image ({ coord = { x = 3, y = 665 }, img = scripts .. 'img/VLC.png'} )
    end

    return true
end

function get_img(mediaSrc, img)
    local _, img_id = mediaSrc:match('(.*)-(.*)')
    local path = '/tmp/' .. trim(img_id) .. '.png'
    if file_exists(path) == false then
        local img_tml_command = 'ffmpeg -loglevel 0 -y -i %s -pix_fmt rgba -vf "scale=45:-1" "%s"'
        img = img:gsub( "=", [[\%1]]):gsub( "?", [[\%1]]):gsub( "&", [[\%1]])
        img_tml_command = string.format(img_tml_command,img,path)
        os.execute(img_tml_command)
    end
    display_image ({ coord = { x = 3, y = 665 }, img = path} )
end
