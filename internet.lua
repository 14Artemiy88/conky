function internet()
    local x = 310

    if file ~= nil then
         x = 180
    end

    text_by_left({ x = 5, y = 554 }, '', { font = 'FontAwesome', size = '20', color = "0xbaffc9" })
    text_by_right({ x = x, y = 554 }, conky_parse('${upspeed enp0s31f6} / ${totalup enp0s31f6}'), { size = '14', color = "0xbaffc9" })
    text_by_left({ x = 5, y = 577 }, '', { font = 'FontAwesome', size = '20', color = "0xffb4bb" })
    text_by_right({ x = x, y = 577 }, conky_parse('${downspeed enp0s31f6} / ${totaldown enp0s31f6}'), { size = '14', color = "0xffb4bb" })
end
