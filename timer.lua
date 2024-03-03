function timer()
    local timer
    local file, err = io.open("/run/user/1000/timer.txt", "r")
    if file then
        timer = file:read()
        file:close()
    end

    text_by_left({ x = 350, y = 620 }, timer, { font = 'LED',size = '52' })
end