function player()
    if (mpc_player() == false and playerctl_player() == false) then
        text_by_left ({x=25, y=650}, 'Ничего не играет', {color='0x666666', size=20})
    end
end

------------------------------
--- Плэйлист плеера из mpc ---
------------------------------
function mpc_player()
    local current_t_a_al_d = trim(read_CLI('mpc current -f %title%💩%artist%💩%album%💩%date%'))
    if string.len(current_t_a_al_d) > 0 then
        local tt_ct_p_tc_pt = read_CLI('mpc status %state%💩%totaltime%💩%currenttime%💩%songpos%💩%length%💩%percenttime%')
        local state,tt_m,tt_s,ct_m,ct_s,current_num,total_count,_,pt = tt_ct_p_tc_pt:match('(%a+)💩(%d+):(%d+)💩(%d+):(%d+)💩(%d+)💩(%d+)💩(%s+)(%d+)')
        if state == 'playing' then
            local current,artist,album,date = current_t_a_al_d:match('(.*)💩(.*)💩(.*)💩(%d*)')
            local u_el_time = (tt_m * 60 + tt_s) - (ct_m * 60 + ct_s)
            local el_time   = os.date("%M:%S", u_el_time)
            local count = 5
            current_num = tonumber(current_num)
            local start = current_num
            if total_count - current_num < count then
                start = tonumber(total_count - count + 1)
            end
            local stop = start + count
            local el_total_time = 0
            local y_start = 635
            local y_step = 18
            local playlist = split(read_CLI('mpc playlist -f %title%💩%time%💩%album%'), '\n')
            for N in pairs(playlist) do
                local song, time_m, time_s, pl_album = playlist[N]:match('(.*)💩(%d+):(%d+)💩(.*)')
                if N > current_num then
                    el_total_time = el_total_time + time_m * 60 + time_s
                end
                if start <= N and N < stop then
                    local color = def.color
                    if pl_album ~= album then color = '0x666666' end
                    local song_time = time_m .. ':' .. time_s
                    if song == current then
                        el_total_time = el_total_time + u_el_time
                        color = '0x3daee9'
                        song_time = string.gsub('-'..el_time, "-0", "-")
                    end
                    song = string.gsub(song, '.wav', '')
                    text_by_left ({x=53, y=y_start}, trim(song), {color=color}, { width=230, col=1 })
                    text_by_right({x=313, y=y_start}, song_time, {color=color})
                    y_start = y_start + y_step
                end
            end

            draw_dash_bar({
                height = 7,
                width = 310,
                seg_width = 3,
                seg_margin = 3,
                start_x = 4,
                y = 612,
                value = tonumber(pt),
                colors = {
                    { color = '0x3daee9', alpha = 1 },
                    { color = def.color, alpha = .3 },
                }
            })

            local total_time
            if el_total_time >= 3600 then
                total_time = os.date("-%X", el_total_time-5*60*60)
            else
                total_time = os.date("-%M:%S", el_total_time)
            end
            if string.len(date) > 0 then date = ' ('..date..')' else date = '' end
            text_by_left  ({x=5, y=600}, artist, { weight = weight_bold })
            text_by_right ({x=313, y=600}, album..date, nil, { width=210, col=1, suffix='…'..date })
            display_image ({ coord = { x = 5, y = 625 }, img = '/tmp/album_cover.png'} )
            text_by_center( {x=23, y=685}, current_num..'/'..total_count )
            text_by_center( {x=23, y=702}, string.gsub(total_time, "-0", "-"), {} )

            return true
        end
    end

    return false
end

--------------------------
--- Плеер из playerctl ---
--------------------------
function playerctl_player()
    local players = {
        {
            player = 'vlc',
            icon = scripts .. 'img/VLC.png',
            color = '0xFE8D08',
            params = {
                'title',
                'mpris:length',
                'position',
                'duration(mpris:length - position)',
            },
        },
        {
            player = 'plasma-browser-integration',
            icon = scripts .. 'img/nocover.png',
            color = update_num,
            params = {
                'title',
                'mpris:length',
                'position',
                'duration(mpris:length - position)',
                'artist',
                'kde:mediaSrc',
                'mpris:artUrl',
            }
        },
    }

    for key in pairs(players) do
        local command = "playerctl -p "..players[key].player.." metadata -f '{{ %s }}'"
        local player = trim(read_CLI(string.format(command, table.concat(players[key].params,' }}💩{{ '))))
        if string.len(player) > 0 then
            local pattern = '💩(.*)'

            return draw_player( players[key].icon, players[key].color, player:match('(.*)' .. pattern:rep(#players[key].params-1)) )
        end
    end

    return false
end

------------------------
--- Отрсиовка плеера ---
------------------------
function draw_player(icn, clr, title, total_time, playing_time, el_time, artist, mediaSrc, img)
    local icon, color = get_icon(mediaSrc, icn, clr)
    draw_dash_bar({
        height = 7,
        width = 310,
        seg_width = 3,
        seg_margin = 3,
        start_x = 4,
        y = 640,
        value = tonumber(playing_time/total_time * 100),
        colors = {
            { color = color, alpha = 1 },
            { color = def.color, alpha = .3 },
        }
    })
    text_by_left ({x=5, y=627}, artist, { size=13 })
    text_by_left ({x=55, y=663}, title, { size=13 },{width = 210, margin=15})
    text_by_right( {x=313, y=663}, '-'..el_time)
    if img ~= nil and string.len(img) > 0 then
        get_img(mediaSrc, img)
    else
        display_image ({ coord = { x = 7, y = 652 }, img = icon} )
    end

    return true
end

--------------------------
--- Получение картинки ---
--------------------------
function get_img(mediaSrc, img)
    local _, img_id = mediaSrc:match('(.*)-(.*)')
    local path = '/tmp/' .. trim(img_id) .. '.png'
    if file_exists(path) == false then
        local img_tml_command = 'ffmpeg -loglevel 0 -y -i %s -pix_fmt rgba -vf "scale=45:-1" "%s"'
        img = img:gsub( "=", [[\%1]]):gsub( "?", [[\%1]]):gsub( "&", [[\%1]])
        img_tml_command = string.format(img_tml_command,img,path)
        os.execute(img_tml_command)
    end
    display_image ({ coord = { x = 3, y = 654 }, img = get_icon(mediaSrc, path)} )
end

function get_icon(mediaSrc, icon, color)
    if mediaSrc ~= nil then
        if string.sub(mediaSrc, 14, 16) == 'vk.' then
            return scripts .. 'img/vk.png', '0x4986CD'
        end
        if string.sub(mediaSrc, 14, 16) == 'hd.' then
            return scripts .. 'img/kinipoisk.png', color
        end
    end

    return icon, color
end