------------------------------
--- Рамка вокруг блока CPU ---
------------------------------
function cpu_frame()
    cairo_move_to(cr, 15, 315)
    cairo_line_to(cr, 5, 315)
    cairo_line_to(cr, 5, 412)
    cairo_line_to(cr, 315, 412)
    cairo_line_to(cr, 315, 315)
    cairo_line_to(cr, 50, 315)

    cairo_set_line_width(cr, 2)
    cairo_set_source_rgba(cr, 0, 0.5, 0, 1)
    cairo_stroke(cr)
end

------------------------------
--- Рамка вокруг блока MEM ---
------------------------------
function mem_frame()
    cairo_move_to(cr, 15, 427)
    cairo_line_to(cr, 5, 427)
    cairo_line_to(cr, 5, 522)
    cairo_line_to(cr, 315, 522)
    cairo_line_to(cr, 315, 427)
    cairo_line_to(cr, 55, 427)

    cairo_set_line_width(cr, 2)
    cairo_set_source_rgba(cr, 0, 0.48627450980392, 0.59607843137255, 1)
    cairo_stroke(cr)
end