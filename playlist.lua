function player()
    if (mopidy_player() == false and playerctl_player() == false) then
        text_by_left ({x=25, y=650}, 'Ничего не играет', {color='0x666666', size=20})
    end
end

function mopidy_player()
    local stsusjson = read_CLI('curl -d \'{"jsonrpc": "2.0", "id": 1, "method": "core.playback.get_state"}\' -H \'Content-Type: application/json\' http://localhost:6680/mopidy/rpc')
    if (stsusjson ~= '{"jsonrpc": "2.0", "id": 1, "result": "playing"}') then return false end

    local URL = {
        currentUrl = '{"jsonrpc": "2.0", "id": 1, "method": "core.playback.get_current_tl_track"}',
        trackListUrl = '{"jsonrpc": "2.0", "id": 2, "method": "core.tracklist.get_tl_tracks"}',
        TimeUrl = '{"jsonrpc": "2.0", "id": 3, "method": "core.playback.get_time_position"}',
        indexUrl = '{"jsonrpc": "2.0", "id": 4, "method": "core.tracklist.index"}',
        totalUrl = '{"jsonrpc": "2.0", "id": 5, "method": "core.tracklist.get_length"}',
    }
    local json_response = read_CLI(
"curl -d '["..URL.currentUrl..","..URL.trackListUrl..","..URL.TimeUrl..","..URL.indexUrl..", "..URL.totalUrl.."]' -H 'Content-Type: application/json' http://localhost:6680/mopidy/rpc"
    )
    local response = json.decode(json_response)
    local current, trackList, time, index, total = response[1].result, response[2].result,response[3].result,response[4].result,response[5].result
    local curentTl = current.tlid
    local date = current.track.album.date
    local album = current.track.album.name
    local totalTime = 0
    local y_start = 640
    local y_step = 18
    for N in pairs(trackList) do
        if trackList[N].tlid >= curentTl then
            totalTime = totalTime + trackList[N].track.length
            if trackList[N].tlid < curentTl + 5 or (total - curentTl > 5 and trackList[N].tlid > total - 5)then
                local song_time = os.date("%M:%S", math.ceil(trackList[N].track.length/1000))
                local color = def.color
                if trackList[N].track.album.name ~= album then color = '0x666666' end
                if trackList[N].tlid == curentTl  then
                    color = '0x3daee9'
                    song_time = os.date("-%M:%S", math.ceil((trackList[N].track.length - time)/1000))
                end
                text_by_left ({x=53, y=y_start}, trackList[N].track.name, {color=color}, { width=230, col=1 })
                text_by_right({x=313, y=y_start}, song_time, {color=color})
                y_start = y_start + y_step
            end
        end
    end
    draw_dash_bar({
        height = 7,
        width = 310,
        seg_width = 3,
        seg_margin = 3,
        start_x = 4,
        y = 602,
        value = math.ceil(time/current.track.length*100),
        colors = {
            { color = '0x3daee9', alpha = 1 },
            { color = def.color, alpha = .3 },
        }
    })
    local total_time = math.ceil((totalTime - time)/1000)
    if total_time >= 3600 then
        total_time = os.date("-%X", total_time-5*60*60)
    else
        total_time = os.date("-%M:%S", total_time)
    end
    if string.len(date) > 0 then date = ' ('..date..')' else date = '' end
    text_by_left  ({x=5, y=590}, current.track.artists[1].name, { weight = weight_bold })
    text_by_left ({x=5, y=621}, album..date, nil, { width=300, col=1, suffix='…'..date })
    display_image ({ coord = { x = 5, y = 630 }, img = '/tmp/album_cover.png'} )
    text_by_center( {x=23, y=690}, index..'/'..total, {background={color='0x000000', alpha=.5}} )
    text_by_center( {x=23, y=707}, string.gsub(total_time, "-0", "-"), {} )

    return true
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
    if string.sub(mediaSrc, 14, 16) == 'vk.' then
        artist, title = trim(read_CLI("playerctl metadata -f '{{ title }}'")):match('(.*) — (.*)')
    end
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

--------------------------
--- Получение иконки ---
--------------------------
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