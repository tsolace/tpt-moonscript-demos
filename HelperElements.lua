local tph = {
  alloc = function(a1, a2, a3)
    local a4 = elements.allocate(a1, a2)
    elements.element(a4, elements.element(a3))
    return a4
  end,
  props = function(elem, props)
    for pkey, pval in pairs(props) do
      elements.property(elem, tostring(pkey), pval)
    end
  end,
  setupdate = function(elem, func)
    return tpt.element_func(func, elem)
  end,
  setgraphics = function(elem, func)
    return tpt.graphics_func(func, elem)
  end,
  sp = function(...)
    return tpt.set_property(...)
  end,
  gp = function(...)
    return tpt.get_property(...)
  end,
  c = function(...)
    return tpt.create(...)
  end,
  d = function(...)
    return tpt.delete(...)
  end,
  setstep = function(func)
    return tpt.register_step(func)
  end
}
local clnr = tph.alloc("SOLACE", "CLNR", elements.DEFAULT_PT_DMND)
tph.props(clnr, {
  Name = "CLNR",
  Description = "Clean ray. Clears all elements directly under it with a spark above it.",
  Color = 0x1BB77E
})
return tph.setupdate(clnr, function(i, x, y, s, n)
  if tph.gp("type", x, y - 1) == elements.DEFAULT_PT_SPRK then
    for b = y + 1, 379, 1 do
      tph.sp("type", 0, x, b)
    end
  end
end)
