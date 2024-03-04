function time()
    text_by_left({ x = 3, y = 58 }, conky_parse('${time %H:%M:%S}'), { color= '0xffffff', size = '60', font = 'LED' })
    text_by_right({ x = 316, y = 34 }, conky_parse('${time %d.%m.%Y}'), { color= '0xffffff', size = '25', font = 'LED' })
    text_by_right({ x = 316, y = 57 }, conky_parse('${time %A}'), { color= '0xffffff', size = '15' })
end