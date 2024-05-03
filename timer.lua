file = nil

function timer()
    local timers = {}
    local counter = 0
    for filename in io.popen('find /run/user/1000/timer/ -type f -name "*"'):lines() do
        file, err = io.open(filename, "r")
        if file then
            counter = counter + 1
            timers[counter] = file:read()
            file:close()
        end
    end

    if counter == 1 then
        if string.len(timers[1]) > 5 then
            text_by_left({ x = 208, y = 579 }, timers[1], { font = 'LED',size = '35' })
        else
            text_by_left({ x = 208, y = 579 }, timers[1], { font = 'LED',size = '52' })
        end
    end

    if counter > 1 then
        text_by_left({ x = 260, y = 559 }, timers[1], { font = 'LED',size = '26' })
        text_by_left({ x = 260, y = 579 }, timers[2], { font = 'LED',size = '26' })
    end
end
