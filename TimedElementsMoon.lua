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
local tres = tph.alloc("SOLACE", "TRES", elements.DEFAULT_PT_DUST)
tph.props(tres, {
  Name = "TRES",
  Description = "Seed to generate random tree after 2 seconds.",
  Colour = 0x00FF00,
  MenuSection = elem.SC_SPECIAL
})
tph.setupdate(tres, function(i, x, y, s, n)
  if tph.gp("tmp2", i) == 1 then
    if os.time() > tph.gp("tmp", i) + 2 then
      local k = math.random(40, 55)
      local kk = math.random(40, 55)
      local l = math.random(55, 90)
      local ll = math.random(10, 22)
      local lll = math.random(10, 22)
      local r = 0
      for o = 1, l do
        local b = math.random(0, 10)
        if b == 1 then
          r = r + 1
          tph.c(x + r, y - o, 'wood')
          x = x + 1
        elseif b == 2 then
          r = r - 1
          tph.c(x + r, y - o, 'wood')
          x = x - 1
        else
          tph.c(x, y - o, 'wood')
        end
        if o == 39 then
          for i = 1, 2 do
            tph.c(x + i, y - 39, 'plnt')
          end
          for i = 1, 2 do
            tph.c(x - i, y - 39, 'plnt')
          end
        end
        if o == 40 then
          for i = 1, 3 do
            tph.c(x + i, y - 40, 'plnt')
          end
          for i = 1, 3 do
            tph.c(x - i, y - 40, 'plnt')
          end
        end
        if o == k then
          local yb = y
          for i = 1, ll do
            local q = math.random(0, 4)
            if q == 1 then
              tph.c(x + i, y - k - i, 'wood')
              y = y + 1
            elseif b == 2 then
              tph.c(x + i, y - k - i, 'wood')
              y = y - 1
            else
              tph.c(x + i, y - k - i, 'wood')
            end
            tph.c(x + i, y - k - i, 'vine')
          end
          y = yb
        end
        if o == kk then
          local yb = y
          for i = 1, lll do
            local q = math.random(0, 4)
            if q == 1 then
              tph.c(x - i, y - kk - i, 'wood')
              y = y + 1
            elseif b == 2 then
              tph.c(x - i, y - kk - i, 'wood')
              y = y - 1
            else
              tph.c(x - i, y - kk - i, 'wood')
            end
            tph.c(x - i, y - kk - i, 'vine')
          end
          y = yb
        end
        if o == l - 1 then
          tph.c(x, y - l, 'vine')
        end
      end
      tph.sp("tmp", 0, i)
      tph.sp("tmp2", 0, i)
      return tph.sp("type", "wood", i)
    end
  else
    tph.sp("tmp", os.time(), i)
    return tph.sp("tmp2", 1, i)
  end
end)
local rbom = tph.alloc("SOLACE", "RBOM", elements.DEFAULT_PT_DMND)
tph.props(rbom, {
  Properties = TYPE_LIQUID,
  State = ST_LIQUID,
  Falldown = 2,
  Advection = 0.04,
  Loss = 1,
  Gravity = 0.04,
  AirLoss = 0.90,
  Weight = 3,
  Name = "RBOM",
  Color = 0xFFFE8915,
  MenuSection = elem.SC_SPECIAL,
  Description = "Liquid Random Bomb. Particle turns into a random element after 30 seconds."
})
tph.setupdate(rbom, function(i, x, y, s, n)
  if tph.gp("tmp2", i) == 1 then
    if os.time() > tph.gp("tmp", i) + 30 then
      tph.sp("tmp", 0, i)
      tph.sp("tmp2", 0, i)
      return pcall(tpt.set_property, "type", math.random(1, 255), i)
    end
  else
    tph.sp("tmp", os.time(), i)
    return tph.sp("tmp2", 1, i)
  end
end)
timertype = "DMND"
local ttim = tph.alloc("SOLACE", "TTIM", elements.DEFAULT_PT_DMND)
tph.props(ttim, {
  Properties = TYPE_LIQUID,
  State = ST_LIQUID,
  Falldown = 2,
  Advection = 0.04,
  Loss = 1,
  Gravity = 0.04,
  AirLoss = 0.90,
  Weight = 3,
  Name = "TTIM",
  Color = 0x8F468F,
  MenuSection = elem.SC_SPECIAL,
  Description = "Type Timer liquid, changes to its ctype (from lua var timertype) after 30 sec"
})
tph.setupdate(ttim, function(i, x, y, s, n)
  if tph.gp("tmp2", i) == 1 then
    if os.time() > tph.gp("tmp", i) + 30 then
      tph.sp("tmp", 0, i)
      tph.sp("tmp2", 0, i)
      return tph.c(x + dx, y + dy, tph.gp("ctype", i))
    end
  else
    tph.sp("tmp", os.time(), i)
    tph.sp("tmp2", 1, i)
    return tph.sp("ctype", timertype, i)
  end
end)
local nr, ng, nb = 0, 0, 0
local checkedtime = false
local settime = 0
tph.setstep(function()
  if checkedtime == true then
    if socket.gettime() > settime + 0.1 then
      nr, ng, nb = math.random(50, 255), math.random(50, 255), math.random(50, 255)
      checkedtime = 0
    end
  else
    settime = socket.gettime()
    checkedtime = true
  end
end)
local tcol = tph.alloc("SOLACE", "TCOL", elements.DEFAULT_PT_DMND)
tph.props(tcol, {
  Name = "TCOL",
  Description = "Random color every 0.1 second",
  Color = 0xFFFFFF,
  MenuSection = elem.SC_SPECIAL
})
tph.setgraphics(tcol, function(i, r, g, b)
  return 0, PMODE_FLAT, nr, ng, nb
end)
local tcln = tph.alloc("SOLACE", "TCLN", elements.DEFAULT_PT_DMND)
tph.props(tcln, {
  Name = "TCLN",
  Description = "CLNE that clones every second",
  Color = 0xFFEEAA,
  MenuSection = elem.SC_SPECIAL
})
tph.setupdate(tcln, function(i, x, y, s, n)
  if tph.gp("tmp2", i) == 1 then
    if os.time() > tph.gp("tmp", i) + 1 then
      for dx = -1, 1, 1 do
        for dy = -1, 1, 1 do
          if not (dx == 0 or dy == 0) then
            tph.c(x + dx, y + dy, tph.gp("ctype", i))
          end
        end
      end
      tph.sp("tmp2", 0, i)
    end
  else
    tph.sp("tmp", os.time(), i)
    tph.sp("tmp2", 1, i)
  end
  if tph.gp("ctype", i) == 0 then
    for dx = -1, 1, 1 do
      for dy = -1, 1, 1 do
        local gtype = tph.gp("type", x + dx, y + dy)
        if gtype ~= 0 and gtype ~= tcln then
          tph.sp("ctype", tph.gp("type", x + dx, y + dy), i)
        end
      end
    end
  end
end)
return nil
