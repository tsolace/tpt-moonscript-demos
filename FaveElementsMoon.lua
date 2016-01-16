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
local nplm = tph.alloc("FEYNMAN", "NPLM", elements.DEFAULT_PT_BCOL)
tph.props(nplm, {
  Name = "NPLM",
  Description = "Napalm, very slow-burning powder",
  Colour = 0x850000,
  MenuSection = elem.SC_EXPLOSIVE,
  Weight = 50,
  Gravity = .5,
  Flammable = 0,
  Explosive = 0,
  Loss = 1,
  AirLoss = .5,
  AirDrag = .01,
  Advection = .01,
  Diffusion = 0
})
tph.setupdate(nplm, function(i, x, y, s, n)
  local clife
  if tph.gp('type', x, y) ~= 0 then
    clife = tph.gp('life', x, y)
  else
    clife = 0
  end
  if clife > 1 then
    for cy = -1, 1, 2 do
      for cx = -1, 1, 2 do
        tph.c(x + cx, y + cy, 'fire')
      end
    end
    return tph.sp('life', clife - 1, x, y)
  elseif clife == 1 then
    return tph.sp('type', 0, x, y)
  elseif s > 0 then
    for cx = -1, 1, 2 do
      for cy = -1, 1, 2 do
        if tph.gp('type', x + cx, y + cy) == (4 or 49) then
          tph.sp('life', 500, x, y)
          return true
        end
      end
    end
  end
end)
tph.setgraphics(nplm, function(i, colr, colg, colb)
  return 1, 0x00000011, 255, 125, 0, 0, 255, 125, 0, 0
end)
local ergy = tph.alloc("QUENTINADAY", "ERGY", elements.DEFAULT_PT_SING)
tph.props(ergy, {
  Name = "ERGY",
  Description = "Pure energy, extremely powerful"
})
tph.setupdate(ergy, function(i, x, y, s, n)
  local cx, cy = math.random(-1, 1), math.random(-1, 1)
  local _exp_0 = math.random(1, 3)
  if 1 == _exp_0 then
    tph.c(x + cx, y + cy, 'phot')
  elseif 2 == _exp_0 then
    tph.c(x + cx, y + cy, 'neut')
  elseif 3 == _exp_0 then
    tph.c(x + cx, y + cy, 'elec')
  end
  tph.sp("temp", math.huge, x, y)
  return sim.pressure(x / 4, y / 4, math.huge)
end)
brptbypass = 0
local brpt = tph.alloc("BOXMEIN", "BRPT", elements.DEFAULT_PT_DMND)
tph.props(brpt, {
  Name = "BRPT",
  Description = "Breakpoints. When spark touches, will pause the game and turn red. Also glowy.",
  Colour = 0xDEADBEEF,
  MenuSection = elem.SC_POWERED,
  Properties = elem.PROP_LIFE_DEC
})
tph.setupdate(brpt, function(i, x, y, s, n)
  local life = sim.partProperty(i, "life")
  for ry = -1, 1, 1 do
    for rx = -1, 1, 1 do
      if life == 0 and tph.gp("type", x + rx, y + ry) == 15 then
        if not (brptbypass == 1) then
          tpt.set_pause(1)
        end
        sim.partProperty(i, "life", 10)
      end
    end
  end
end)
tph.setgraphics(brpt, function(i, x, y, s, n)
  x, y = sim.partPosition(i)
  local life = sim.partProperty(i, "life")
  if life > 0 then
    local pixel_mode = 296
    local colg, colb = 0, 0
    local colr = 255
  else
    local pixel_mode = 1
  end
  return 0, pixel_mode, 255, colr, colg, colb, 255, colr, colg, colb
end)
local rcld = tph.alloc("MRSALITOS", "RCLD", elements.DEFAULT_PT_WTRV)
tph.props(rcld, {
  Name = "RCLD",
  Description = "Raincloud. Produces water infinitely.",
  Colour = 0xFFFFFF,
  MenuSection = 6,
  Loss = 0.1,
  AirLoss = 0.3,
  Advection = 1,
  Diffusion = 0.3,
  Temperature = 273.15
})
tph.setupdate(rcld, function(i, x, y, s, n)
  local _exp_0 = math.random(0, 2000)
  if 1000 == _exp_0 then
    tpt.parts[i].type = elements.DEFAULT_PT_WATR
  end
end)
local neon = tph.alloc("MRSALITOS", "NEON", elements.DEFAULT_PT_NBLE)
tph.props(neon, {
  Name = "NEON",
  Description = "Neon gas. Glows in contact with spark.",
  Colour = 0x242424,
  MenuSection = 6,
  Loss = 0.1,
  AirLoss = 1,
  Advection = 0.4,
  Diffusion = 0.5,
  Gravity = 0,
  Flammable = 0,
  Weight = 0,
  Properties = 0x4828
})
local colour = {
  0xFFAA0000,
  0xFFFF6600,
  0xFFFFFF00,
  0xFF00FF00,
  0xFF00FFFF,
  0xFF0000FF,
  0xFF9900CC
}
local none = 0x00242424
tph.setupdate(neon, function(i, x, y, s, n)
  if tph.gp("tmp", i) == 0 then
    tph.sp("tmp", 1, i)
  end
  if tph.gp("tmp2", i) == 1 then
    tph.sp("life", 180 + math.random(0, 20), i)
    tph.sp("tmp2", 0, i)
  end
  if tpt.parts[i].life <= 0 then
    return tph.sp("dcolour", none, i)
  end
end)
tph.setupdate(elements.DEFAULT_PT_SPRK, function(i, x, y, s, n)
  local ntmp = tph.gp("tmp", i)
  local neontype = tph.gp("ctype", i)
  if tph.gp("tmp", i) == ntmp then
    if colour[ntmp] ~= nil then
      tph.sp("dcolour", colour[ntmp], x, y)
      tph.sp("tmp2", 1, x, y)
    end
  end
  if tph.gp("tmp", i) == 8 then
    return tph.sp("dcolour", colour[math.random(1, 7)], i)
  end
end)
tph.setgraphics(neon, function(i, colr, colg, colb)
  return 1, 0x00022110, 30, 30, 30, 30, 30, 30, 30, 30
end)
local mexp = tph.alloc("QBAMOD", "MEXP", elements.DEFAULT_PT_NBLE)
tph.props(mexp, {
  Name = "MEXP",
  Description = "Mixed Explosives.",
  MenuSection = 5,
  Colour = 0xAD9B12,
  Properties = elements.ST_SOLID + elements.TYPE_SOLID
})
tph.setupdate(mexp, function(i, x, y, s, n)
  local _exp_0 = math.random(0, 5)
  if 1 == _exp_0 then
    return tph.sp("type", "ligh", x, y)
  elseif 2 == _exp_0 then
    return tph.sp("type", "plsm", x, y)
  elseif 3 == _exp_0 then
    return tph.sp("type", "bomb", x, y)
  elseif 4 == _exp_0 then
    return tph.sp("type", "thdr", x, y)
  else
    return tph.sp("type", "nitr", x, y)
  end
end)
local famr = tph.alloc("QBAMOD", "FAMR", elements.DEFAULT_PT_TTAN)
tph.props(famr, {
  Name = "FAMR",
  Description = "Fire forged armour.",
  Properties = elements.ST_SOLID + elements.TYPE_SOLID
})
tph.setupdate(famr, function(i, x, y, s, n)
  local _exp_0 = math.random(0, 4)
  if 0 == _exp_0 then
    return tph.sp("type", "ttan", x, y)
  elseif 1 == _exp_0 then
    return tph.sp("type", "qrtz", x, y)
  elseif 2 == _exp_0 then
    return tph.sp("type", "coal", x, y)
  elseif 3 == _exp_0 then
    return tph.sp("type", "brck", x, y)
  else
    return tph.sp("type", "iron", x, y)
  end
end)
local dttn = tph.alloc("QUENTINADAY", "DTTN", elements.DEFAULT_PT_TTAN)
tph.props(dttn, {
  Name = "DTTN",
  Description = "Extremely durable TTAN. Evades VIRS and DEST.",
  Properties = elements.ST_SOLID + elements.TYPE_SOLID,
  HeatConduct = 0,
  Hardness = 0,
  Weight = 10000
})
sim.can_move(elements.DEFAULT_PT_DEST, dttn, 0)
tph.setupdate(dttn, function(i, x, y, s, n)
  local ttype = tph.gp("temp", x, y)
  if ttype > 300 then
    tph.sp("temp", -math.huge, x, y)
  end
  tph.sp("temp", -math.huge, x, y)
  ttype = tph.gp("type", x + math.random(-3, 3), y + math.random(-3, 3))
  if ttype == tpt.el.dest.id then
    sim.gravMap(x / 4, y / 4, -256)
  end
  ttype = tph.gp("type", x + math.random(-3, 3), y + math.random(-3, 3))
  if ttype == tpt.el.virs.id or ttype == tpt.el.vrss.id or ttype == tpt.el.vrsg.id then
    tph.c(x + math.random(-1, 1), y + math.random(-1, 1), "soap")
  end
  local rx, ry = x + math.random(-1, 1), y + math.random(-1, 1)
  ttype = tph.gp("type", rx, ry)
  if ttype == tpt.el.soap.id then
    return tph.d(rx, ry)
  end
end)
local vols = tph.alloc("MJPOWDER", "VOLS", elements.DEFAULT_PT_DUST)
tph.props(vols, {
  Name = "VOLS",
  Description = "Oddly colored thing.",
  Colour = 0x2BE0CB,
  MenuSection = elem.SC_GAS,
  Loss = 0.1,
  AirLoss = 1,
  Advection = 0.4,
  Diffusion = 0.5,
  Temperature = 295,
  Gravity = 15,
  Flammable = 98997,
  Weight = 999,
  Properties = 0x4828
})
local jmod = tpt.version.jacob1s_mod
local pbhl = tph.alloc("JACOB1", "PBHL", elements.DEFAULT_PT_NBHL)
tph.props(pbhl, {
  Name = "PBHL",
  Description = "Powered black hole. NSCN/PSCN to charge/take.",
  MenuSection = elem.SC_POWERED
})
if jmod then
  elem.property(pbhl, "Properties", elem.property(pbhl, "Properties") + elem.PROP_POWERED)
end
local pwhl = tph.alloc("JACOB1", "PWHL", elements.DEFAULT_PT_NWHL)
tph.props(pwhl, {
  Name = "PWHL",
  Description = "Powered white hole. NSCN/PSCN to charge/take.",
  MenuSection = elem.SC_POWERED
})
if jmod then
  elem.property(pwhl, "Properties", elem.property(pwhl, "Properties") + elem.PROP_POWERED)
end
local phlupdate
phlupdate = function(i, x, y, s, n)
  local life = sim.partProperty(i, sim.FIELD_LIFE)
  local itype = sim.partProperty(i, sim.FIELD_TYPE)
  if life == 10 then
    local amount = 1.5
    local tmp = sim.partProperty(i, sim.FIELD_TMP)
    if tmp > 0 then
      amount = tmp * .015
      if amount < 1.5 then
        amount = 1.5
      elseif amount > 768 then
        amount = 768
      end
    end
    sim.gravMap(x / 4, y / 4, itype == pbhl and amount or -amount)
    for r in sim.neighbors(x, y, 1, 1) do
      local rtype = sim.partProperty(r, sim.FIELD_TYPE)
      if not (jmod) then
        if rtype == itype and sim.partProperty(r, sim.FIELD_LIFE) == 9 then
          sim.partProperty(i, sim.FIELD_LIFE, 9)
        elseif rtype == tpt.el.sprk.id and sim.partProperty(r, sim.FIELD_CTYPE) == tpt.el.nscn.id then
          sim.partProperty(i, sim.FIELD_LIFE, 9)
        end
      end
      if rtype ~= nil then
        if itype == pbhl and rtype ~= itype and bit.band(elem.property(rtype, "Properties"), 0x1F) ~= 4 then
          sim.partKill(r)
        end
      end
    end
  elseif not jmod then
    if life > 0 then
      sim.partProperty(i, sim.FIELD_LIFE, life - 1)
      return 
    end
    for r in sim.neighbors(x, y, 1, 1) do
      local rtype = sim.partProperty(r, sim.FIELD_TYPE)
      if rtype == itype and sim.partProperty(r, sim.FIELD_LIFE) == 10 then
        sim.partProperty(i, sim.FIELD_LIFE, 10)
      elseif rtype == tpt.el.sprk.id and sim.partProperty(r, sim.FIELD_CTYPE) == tpt.el.pscn.id then
        sim.partProperty(i, sim.FIELD_LIFE, 10)
      end
    end
  end
end
local phlgraphics
phlgraphics = function(i, colr, colg, colb)
  local life = sim.partProperty(i, sim.FIELD_LIFE)
  local divide = life == 10 and 1 or (2.5 - life / 8)
  return 0, 1, 255, colr / divide, colg / divide, colb / divide
end
tph.setupdate(pbhl, phlupdate)
tph.setupdate(pwhl, phlupdate)
tph.setgraphics(pbhl, phlgraphics)
tph.setgraphics(pwhl, phlgraphics)
local song = tph.alloc("RDOCOC", "SONG", elem.DEFAULT_PT_ELEC)
tph.props(song, {
  Name = "SONG",
  Description = "Sound waves. Heavy energy. Displaces non-solid materials. (rdococ)",
  Colour = 0x0080A0,
  MenuSection = elem.SC_RADIOACTIVE,
  Properties = elem.TYPE_ENERGY,
  State = elem.ST_NONE,
  Temperature = 273.15,
  HeatConduct = 0,
  Weight = 99
})
tph.setupdate(song, function(i, x, y, s, n)
  local tmp2 = sim.partProperty(i, sim.FIELD_TMP2)
  if tmp2 == 0 then
    local angle = math.random() * math.pi * 2
    sim.partProperty(i, sim.FIELD_TMP2, 1)
    sim.partProperty(i, sim.FIELD_VX, math.sin(angle) * 5)
    return sim.partProperty(i, sim.FIELD_VY, math.cos(angle) * 5)
  end
end)
tph.setgraphics(song, function(i, colr, colg, colb)
  return 1, ren.PMODE_FLAT + ren.FIRE_BLEND, 1, colr, colg, colb, 210, colr, colg, colb
end)
local radc = tph.alloc("RADIOACTIVELUA", "RADC", elements.DEFAULT_PT_HYGN)
tph.props(radc, {
  Name = "RADC",
  Description = "Radioactive cloud. Rains radioactive particles.",
  Colour = 0x11FF22,
  MenuSection = 10,
  Gravity = 0,
  Explosive = 0,
  Weight = 0,
  Diffusion = 1,
  Hardness = 0,
  Flammable = 100000,
  AirDrag = 0.01,
  Loss = 0.1,
  AirLoss = 0.3,
  Advection = 1
})
tph.setupdate(radc, function(i, x, y, s, n)
  local _exp_0 = math.random(1, 500)
  if 5 == _exp_0 then
    return tph.sp("type", "plut", i)
  elseif 20 == _exp_0 then
    return tph.sp("type", "uran", i)
  elseif 30 == _exp_0 then
    return tph.sp("type", "isoz", i)
  elseif 40 == _exp_0 then
    return tph.sp("type", "deut", i)
  elseif 50 == _exp_0 then
    return tph.sp("type", "bvbr", i)
  end
end)
local bhiv = tph.alloc("RADIOACTIVELUA", "BEE", elements.DEFAULT_PT_WOOD)
tph.props(bhiv, {
  Name = "BHIV",
  Description = "BEE Hive. Produces BEES. Produced by BEES.",
  Colour = 0x999966,
  Flammable = 10,
  MenuSection = elem.SC_SPECIAL
})
tph.setupdate(bhiv, function(i, x, y, s, n)
  if math.random(1, 330) == 10 then
    return tph.c(x + math.random(-1, 1), y + math.random(-1, 1), "BEES")
  end
end)
local bees = tph.alloc("RADIOACTIVELUA", "BEES", elements.DEFAULT_PT_DUST)
tph.props(bees, {
  Name = "BEES",
  Description = "BEES. Pestering demons. Makes BHIV (bee hives).",
  Colour = 0xFFFF00,
  MenuSection = 11,
  Gravity = 0.1,
  Flammable = 10,
  Explosive = 0,
  Weight = -6000,
  Diffusion = 2,
  Falldown = 0.2
})
tph.setupdate(bees, function(i, x, y, s, n)
  if math.random(1, 9001) == 10 then
    return tph.c(x + math.random(-1, 1), y + math.random(-1, 1), "BHIV")
  end
end)
local metr = tph.alloc("IFORGOTWHOMADETHIS", "METR", elements.DEFAULT_PT_ELEC)
tph.props(metr, {
  Name = "METR",
  Description = "Meteors. Explode on impact. Use sparingly.",
  Colour = 0xFF7A0002,
  MenuSection = elem.SC_EXPLOSIVE,
  MenuVisible = 1,
  Weight = 100,
  Temperature = 9999
})
tph.setgraphics(metr, function(i, colr, colg, colb)
  return 1, 0x00010000, 255, 255, 0, 210, 255, 255, 255, 255
end)
local get_property
get_property = function(prop, x, y)
  if x >= 0 and x < sim.XRES and y >= 0 and y < sim.YRES then
    return tph.gp(prop, x, y)
  end
  return 0
end
math.randomseed(os.time())
tph.setupdate(metr, function(i, x, y, s, n)
  if tph.gp("tmp", i) == 0 then
    tpt.parts[i].tmp = 1
    local randvel = math.random(-20, 20) / 10
    tpt.parts[i].vx = randvel
    tpt.parts[i].vy = math.sqrt(8 - (randvel ^ 2))
  end
  local xvel = tph.gp("vx", i) / 2
  local yvel = tph.gp("vy", i) / 2
  if yvel <= 0 or math.abs(xvel) > 1 then
    tph.d(i)
  end
  local xpos = x - xvel
  local ypos = y - yvel
  local elemtype = get_property("type", xpos, ypos)
  if elemtype == 0 then
    tph.c(xpos, ypos, "bray")
    tph.sp("temp", 5000, xpos, ypos)
  end
  tpt.parts[i].temp = 9999
  local elemtype25 = get_property("type", x + xvel * 5, y + yvel * 5)
  local elemtype24 = get_property("type", x + xvel * 4, y + yvel * 4)
  local elemtype23 = get_property("type", x + xvel * 3, y + yvel * 3)
  local elemtype22 = get_property("type", x + xvel * 2, y + yvel * 2)
  local elemtype21 = get_property("type", x + xvel, y + yvel)
  if elemtype25 ~= 0 and elemtype25 ~= metr and elemtype25 ~= tpt.el.bray.id and elemtype25 ~= tpt.el.dmnd.id and elemtype25 ~= tpt.el.void.id then
    tph.sp("type", "bomb", i)
    tph.sp("life", 0, i)
    tph.sp("tmp", 0, i)
  end
  if elemtype24 ~= 0 and elemtype24 ~= metr and elemtype24 ~= tpt.el.bray.id and elemtype24 ~= tpt.el.dmnd.id and elemtype24 ~= tpt.el.void.id then
    tph.sp("type", "bomb", i)
    tph.sp("life", 0, i)
    tph.sp("tmp", 0, i)
  end
  if elemtype23 ~= 0 and elemtype23 ~= metr and elemtype23 ~= tpt.el.bray.id and elemtype23 ~= tpt.el.dmnd.id and elemtype23 ~= tpt.el.void.id then
    tph.sp("type", "bomb", i)
    tph.sp("life", 0, i)
    tph.sp("tmp", 0, i)
  end
  if elemtype22 ~= 0 and elemtype22 ~= metr and elemtype22 ~= tpt.el.bray.id and elemtype22 ~= tpt.el.dmnd.id and elemtype22 ~= tpt.el.void.id then
    tph.sp("type", "bomb", i)
    tph.sp("life", 0, i)
    tph.sp("tmp", 0, i)
  end
  if elemtype21 ~= 0 and elemtype21 ~= metr and elemtype21 ~= tpt.el.bray.id and elemtype21 ~= tpt.el.dmnd.id and elemtype21 ~= tpt.el.void.id then
    tph.sp("type", "bomb", i)
    tph.sp("life", 0, i)
    return tph.sp("tmp", 0, i)
  end
end)
local hetr = tph.alloc("YOSHI", "HETR", elements.DEFAULT_PT_DMND)
tph.props(hetr, {
  Name = "HETR",
  Description = "Maintains a constant max temperature.",
  Color = 0xFF1111,
  MenuSection = 2,
  HeatConduct = 65535
})
local colr = tph.alloc("YOSHI", "COLR", elements.DEFAULT_PT_DMND)
tph.props(colr, {
  Name = "COLR",
  Description = "Maintains a constant zero temperature.",
  Color = 0x1111FF,
  MenuSection = 2,
  HeatConduct = 65535
})
tph.setstep(function()
  tph.sp("temp", 9999, "HETR")
  return tph.sp("temp", 0, "COLR")
end)
return nil
