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
dgserver, dgport = "127.0.0.1", 25533
local sok = socket.udp()
sok:settimeout(0)
local sokconnect
sokconnect = function()
  sok:settimeout(0)
  sok:setpeername(dgserver, dgport)
  return sok:send("hello")
end
local udps = tph.alloc("SOLACE", "UDPS", elements.DEFAULT_PT_WIFI)
tph.props(udps, {
  Name = "UDP",
  Description = "Send or recieve sparks with UDP server, lua vars dgserver:dgport, works like WIFI",
  Colour = 0x00FF00,
  MenuSection = elem.SC_ELEC
})
tph.setupdate(udps, function(i, x, y, s, n)
  for dx = -1, 1, 1 do
    for dy = -1, 1, 1 do
      if tph.gp("type", x + dx, y + dy) == elements.DEFAULT_PT_SPRK and tph.gp("ctype", x + dx, y + dy) ~= elements.DEFAULT_PT_NSCN then
        sok:setpeername(dgserver, dgport)
        sok:send(math.floor(tph.gp("temp", i)))
        return 
      end
    end
  end
end)
tph.setstep(function()
  local rb = sok:receive()
  if rb ~= nil then
    for i in sim.parts() do
      if tph.gp("type", i) == udps then
        local y = tph.gp("y", i)
        local x = tph.gp("x", i)
        if math.floor(tonumber(rb)) == math.floor(tph.gp("temp", i)) then
          for dx = -1, 1, 1 do
            for dy = -1, 1, 1 do
              if tph.gp("type", x + dx, y + dy) == elements.DEFAULT_PT_NSCN then
                tph.sp("type", elements.DEFAULT_PT_SPRK, x + dx, y + dy)
                tph.sp("ctype", elements.DEFAULT_PT_NSCN, x + dx, y + dy)
              end
            end
          end
        end
      end
    end
  end
end)
return sokconnect()
