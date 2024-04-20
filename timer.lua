file = nil

function timer()
    local timer = ""
    file, err = io.open("/run/user/1000/timer.txt", "r")
    if file then
        timer = file:read()
        file:close()
    end

    if string.len(timer) > 5 then
        text_by_left({ x = 208, y = 579 }, timer, { font = 'LED',size = '35' })
    else
        text_by_left({ x = 208, y = 579 }, timer, { font = 'LED',size = '52' })
    end
end

