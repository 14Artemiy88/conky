function player()
    if (mopidy_player() == false and playerctl_player() == false) then
        draw_empty_player()
    end
end

function mopidy_player()
    local stsusjson = read_CLI(
            'curl -d \'{"jsonrpc": "2.0", "id": 1, "method": "core.playback.get_state"}\' -H \'Content-Type: application/json\' http://localhost:6680/mopidy/rpc'
    )
    if (stsusjson ~= '{"jsonrpc": "2.0", "id": 1, "result": "playing"}') then return false end

    local URL = {
        currentUrl   = '{"jsonrpc": "2.0", "id": 1, "method": "core.playback.get_current_tl_track"},',
        trackListUrl = '{"jsonrpc": "2.0", "id": 2, "method": "core.tracklist.get_tl_tracks"},',
        TimeUrl      = '{"jsonrpc": "2.0", "id": 3, "method": "core.playback.get_time_position"},',
        indexUrl     = '{"jsonrpc": "2.0", "id": 4, "method": "core.tracklist.index"},',
        totalUrl     = '{"jsonrpc": "2.0", "id": 5, "method": "core.tracklist.get_length"}',
    }
    local json_response = read_CLI(
"curl -d '["..
            URL.currentUrl..
            URL.trackListUrl..
            URL.TimeUrl..
            URL.indexUrl..
            URL.totalUrl..
        "]' -H 'Content-Type: application/json' http://localhost:6680/mopidy/rpc"
    )
    local response = json.decode(json_response)
    local current, trackList, time, index, total = response[1].result, response[2].result, response[3].result, response[4].result + 1, response[5].result
    local y_start, y_step = 642, 18
    local show_tracks = 5
    local current_album, date = '', ''
    if current.track.album ~= nil then
        current_album = current.track.album.name
        if current.track.album.date ~= nil then
            date = current.track.album.date
        end
    end
    local totalTime, album_track_count, album_length, album_el = 0, 0, 0, 0
    local tracks_lengths = {}
    for N in pairs(trackList) do
        local album = ''
        if trackList[N].track.album ~= nil then album = trackList[N].track.album.name end
        if album == current_album then
            album_track_count = album_track_count + 1
            tracks_lengths[N] = trackList[N].track.length
            album_length = album_length + trackList[N].track.length
        end
        if trackList[N].tlid >= current.tlid and trackList[N].track.length ~= nil then
            totalTime = totalTime + trackList[N].track.length
            if album == current_album then
                album_el = album_el + trackList[N].track.length
            end
        end

        if
            (trackList[N].tlid >= current.tlid and trackList[N].tlid < current.tlid + show_tracks)
             or (total - index < show_tracks and N > total - show_tracks)
        then
            local song_time = time_format(trackList[N].track.length)
            local color = def.color
            if album ~= current_album then color = '0x666666' end
            if trackList[N].tlid == current.tlid then
                color = '0x3daee9'
                song_time = time_format(trackList[N].track.length - time, '-')
            end
            text_by_left ({x=53, y=y_start}, trackList[N].track.name, {color=color}, { width=230, col=1 })
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
        y = 602,
        value = math.ceil(time/current.track.length*100),
        colors = {
            { color = '0x3daee9', alpha = 1 },
            { color = def.color, alpha = .3 },
        }
    })
    totalTime = time_format(totalTime - time, '-')
    album_el = time_format(album_el - time, '-')
    local artist = ""
    if current.track.artists ~= nil then
        artist = current.track.artists[1].name
    end
    text_by_left  ({x=3, y=593}, artist, { weight = weight_bold, size=14 })
    text_by_left ({x=3, y=620}, date .. ' ' .. current_album, nil, { width=300, col=1, size=13, additional_text=album_el})
    text_by_right ({x=313, y=620}, album_el, nil)
    display_image ({ coord = { x = 5, y = 633 }, img = '/tmp/album_cover.png'} )
    text_by_center( {x=23, y=692}, index..'/'..total, {background={color='0x000000', alpha=.5}} )
    text_by_center( {x=23, y=709}, totalTime, {} )
    draw_album_progress_line(
        { x_start=5, x_end=313, y=626},
        {total=album_track_count, current=current.track.track_no, pass=time/current.track.length},
            { tracks=tracks_lengths, total=album_length }
    )

    return true
end

--------------------------
--- Плеер из playerctl ---
--------------------------
function playerctl_player()
    local players = {
        {
            player = '-p vlc',
            icon = scripts .. 'img/VLC.png',
            color = '0xFE8D08',
            params = {
                'title',
                'xesam:url',
                'mpris:length',
                'position',
                'duration(mpris:length - position)',
                'xesam:artist',
            },
        },
        {
            -- player = '-p plasma-browser-integration',
            player = '',
            icon = scripts .. 'img/nocover.png',
            color = 'new_gradient',
            params = {
                'title',
                'xesam:url',
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
        local command = "playerctl "..players[key].player.." metadata -f '{{ %s }}'"
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
function draw_player(icn, clr, title, file, total_time, playing_time, el_time, artist, mediaSrc, img)
    local icon, color = get_icon(mediaSrc, icn, clr)
    draw_dash_bar({
        height = 7,
        width = 310,
        seg_width = 3,
        seg_margin = 3,
        start_x = 4,
        y = 620,
        value = tonumber(playing_time/total_time * 100),
        colors = {
            { color = color, alpha = 1 },
            { color = def.color, alpha = .3 },
        }
    })


    title = prep_title(title, file, mediaSrc)

    text_by_left ({x=5, y=607}, artist, { size=13 })
    text_by_left ({x=55, y=643}, title, { size=13 },{width = 211, margin=15})
    text_by_right( {x=313, y=643}, '-'..el_time)
    if img ~= nil and string.len(img) > 0 then
        get_img(mediaSrc, img)
    else
        display_image ({ coord = { x = 7, y = 632 }, img = icon} )
    end

    return true
end

--------------------------
--- Получение картинки ---
--------------------------
function get_img(mediaSrc, img)
    local _, img_id = img:match('(.*)/(.*)')
    local path = '/run/user/1000/' .. trim(img_id) .. '.png'
    if file_exists(path) == false then
        local img_tml_command = 'ffmpeg -loglevel 0 -y -i %s -pix_fmt rgba -vf "scale=45:-1" "%s"'
        img = img:gsub( "=", [[\%1]]):gsub( "?", [[\%1]]):gsub( "&", [[\%1]])
        img_tml_command = string.format(img_tml_command,img,path)
        os.execute(img_tml_command)
    end
    display_image ({ coord = { x = 3, y = 634 }, img = get_icon(mediaSrc, path)} )
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

function time_format(time, symbol)
    if symbol == nil then symbol = '' end
    if time == nil then time = 0 end
    time = math.floor(time/1000)
    if time >= 3600 then
        time = os.date(symbol .. "%X", time-5*60*60)
    else
        time = os.date(symbol .. "%M:%S", time)
    end

    if symbol == '' then return time end

    return string.gsub(time, symbol .."0", symbol)
end

function prep_title(title, file, mediaSrc)
    --if string.sub(mediaSrc, 14, 16) == 'vk.' then
    --    artist, title = trim(read_CLI("playerctl metadata -f '{{ title }}'")):match('(.*) — (.*)')
    --end
    if title == "" then
        local path = split(file, '/')
        title = path[#path]
    end
    if mediaSrc ~= nil and string.sub(mediaSrc, 14, 16) == 'hd.' then
        local kinopoisk_postfix = ' — смотреть онлайн в хорошем качестве — Кинопоиск'
        title = string.gsub(title, kinopoisk_postfix, "")
    end

    title = url_decode(title)

    return title
end