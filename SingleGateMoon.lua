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
local frame_counter = 0
local frame_max = 8
local gate = tph.alloc("IAMDUMB", "GATE", elements.DEFAULT_PT_BRCK)
tph.props(gate, {
  Name = "GATE",
  Description = "Multi Logic Gate. PSCN/NSCN in/out. Set tmp: 1=AND 2=OR 3=NOT 4=XOR 5=NAND 6=XNOR",
  MenuSection = 1,
  Colour = 0x800000
})
local and_update
and_update = function(index, partx, party, surround, nt)
  local n_pscn = 0
  for dx = -2, 2, 1 do
    for dy = -2, 2, 1 do
      if tph.gp("type", partx + dx, party + dy) == elements.DEFAULT_PT_SPRK and tph.gp("ctype", partx + dx, party + dy) == elements.DEFAULT_PT_PSCN then
        n_pscn = n_pscn + 1
      end
    end
  end
  if n_pscn >= 2 then
    for dx = -2, 2, 1 do
      for dy = -2, 2, 1 do
        if tph.gp("type", partx + dx, party + dy) == elements.DEFAULT_PT_NSCN and tph.gp("life", partx + dx, party + dy) == 0 then
          tph.sp("life", 4, partx + dx, party + dy)
          tph.sp("ctype", elements.DEFAULT_PT_NSCN, partx + dx, party + dy)
          tph.sp("type", elements.DEFAULT_PT_SPRK, partx + dx, party + dy)
        end
      end
    end
  end
  return 0
end
local or_update
or_update = function(index, partx, party, surround, nt)
  local n_pscn = 0
  for dx = -2, 2, 1 do
    for dy = -2, 2, 1 do
      if tph.gp("type", partx + dx, party + dy) == elements.DEFAULT_PT_SPRK and tph.gp("ctype", partx + dx, party + dy) == elements.DEFAULT_PT_PSCN then
        n_pscn = n_pscn + 1
      end
    end
  end
  if n_pscn >= 1 then
    for dx = -2, 2, 1 do
      for dy = -2, 2, 1 do
        if tph.gp("type", partx + dx, party + dy) == elements.DEFAULT_PT_NSCN and tph.gp("life", partx + dx, party + dy) == 0 then
          tph.sp("life", 4, partx + dx, party + dy)
          tph.sp("ctype", elements.DEFAULT_PT_NSCN, partx + dx, party + dy)
          tph.sp("type", elements.DEFAULT_PT_SPRK, partx + dx, party + dy)
        end
      end
    end
  end
  return 0
end
local not_update
not_update = function(index, partx, party, surround, nt)
  frame_counter = frame_counter + 1
  if frame_counter == frame_max then
    frame_counter = 0
  end
  local n_pscn = 0
  for dx = -2, 2, 1 do
    for dy = -2, 2, 1 do
      local whoa = (tpt.get_property("type", partx + dx, party + dy) == elements.DEFAULT_PT_SPRK and tpt.get_property("ctype", partx + dx, party + dy) == elements.DEFAULT_PT_PSCN) or (tpt.get_property("type", partx + dx, party + dy) == elements.DEFAULT_PT_PSCN and tpt.get_property("life", partx + dx, party + dy) > 0)
      if whoa then
        n_pscn = n_pscn + 1
      end
    end
  end
  if n_pscn == 0 and frame_counter == 0 then
    for dx = -2, 2, 1 do
      for dy = -2, 2, 1 do
        if tph.gp("type", partx + dx, party + dy) == elements.DEFAULT_PT_NSCN and tph.gp("life", partx + dx, party + dy) == 0 then
          tph.sp("life", 4, partx + dx, party + dy)
          tph.sp("ctype", elements.DEFAULT_PT_NSCN, partx + dx, party + dy)
          tph.sp("type", elements.DEFAULT_PT_SPRK, partx + dx, party + dy)
        end
      end
    end
  end
  return 0
end
local xor_update
xor_update = function(index, partx, party, surround, nt)
  local n_pscn = 0
  for dx = -2, 2, 1 do
    for dy = -2, 2, 1 do
      if tph.gp("type", partx + dx, party + dy) == elements.DEFAULT_PT_SPRK and tph.gp("ctype", partx + dx, party + dy) == elements.DEFAULT_PT_PSCN then
        n_pscn = n_pscn + 1
      end
    end
  end
  if n_pscn == 1 then
    for dx = -2, 2, 1 do
      for dy = -2, 2, 1 do
        if tph.gp("type", partx + dx, party + dy) == elements.DEFAULT_PT_NSCN and tph.gp("life", partx + dx, party + dy) == 0 then
          tph.sp("life", 4, partx + dx, party + dy)
          tph.sp("ctype", elements.DEFAULT_PT_NSCN, partx + dx, party + dy)
          tph.sp("type", elements.DEFAULT_PT_SPRK, partx + dx, party + dy)
        end
      end
    end
  end
  return 0
end
local nand_update
nand_update = function(index, partx, party, surround, nt)
  frame_counter = frame_counter + 1
  if frame_counter == frame_max then
    frame_counter = 0
  end
  local n_pscn = 0
  for dx = -2, 2, 1 do
    for dy = -2, 2, 1 do
      local whoa = (tpt.get_property("type", partx + dx, party + dy) == elements.DEFAULT_PT_SPRK and tpt.get_property("ctype", partx + dx, party + dy) == elements.DEFAULT_PT_PSCN) or (tpt.get_property("type", partx + dx, party + dy) == elements.DEFAULT_PT_PSCN and tpt.get_property("life", partx + dx, party + dy) > 0)
      if whoa then
        n_pscn = n_pscn + 1
      end
    end
  end
  if n_pscn < 2 and frame_counter == 0 then
    for dx = -2, 2, 1 do
      for dy = -2, 2, 1 do
        if tph.gp("type", partx + dx, party + dy) == elements.DEFAULT_PT_NSCN and tph.gp("life", partx + dx, party + dy) == 0 then
          tph.sp("life", 4, partx + dx, party + dy)
          tph.sp("ctype", elements.DEFAULT_PT_NSCN, partx + dx, party + dy)
          tph.sp("type", elements.DEFAULT_PT_SPRK, partx + dx, party + dy)
        end
      end
    end
  end
  return 0
end
local xnor_update
xnor_update = function(index, partx, party, surround, nt)
  frame_counter = frame_counter + 1
  if frame_counter == frame_max then
    frame_counter = 0
  end
  local n_pscn = 0
  for dx = -2, 2, 1 do
    for dy = -2, 2, 1 do
      local whoa = (tpt.get_property("type", partx + dx, party + dy) == elements.DEFAULT_PT_SPRK and tpt.get_property("ctype", partx + dx, party + dy) == elements.DEFAULT_PT_PSCN) or (tpt.get_property("type", partx + dx, party + dy) == elements.DEFAULT_PT_PSCN and tpt.get_property("life", partx + dx, party + dy) > 0)
      if whoa then
        n_pscn = n_pscn + 1
      end
    end
  end
  if n_pscn ~= 1 and frame_counter == 0 then
    for dx = -2, 2, 1 do
      for dy = -2, 2, 1 do
        if tph.gp("type", partx + dx, party + dy) == elements.DEFAULT_PT_NSCN and tph.gp("life", partx + dx, party + dy) == 0 then
          tph.sp("life", 4, partx + dx, party + dy)
          tph.sp("ctype", elements.DEFAULT_PT_NSCN, partx + dx, party + dy)
          tph.sp("type", elements.DEFAULT_PT_SPRK, partx + dx, party + dy)
        end
      end
    end
  end
  return 0
end
return tph.setupdate(gate, function(i, x, y, s, n)
  local _exp_0 = tph.gp("tmp", i)
  if 1 == _exp_0 then
    return and_update(i, x, y, s, n)
  elseif 2 == _exp_0 then
    return or_update(i, x, y, s, n)
  elseif 3 == _exp_0 then
    return not_update(i, x, y, s, n)
  elseif 4 == _exp_0 then
    return xor_update(i, x, y, s, n)
  elseif 5 == _exp_0 then
    return nand_update(i, x, y, s, n)
  elseif 6 == _exp_0 then
    return xnor_update(i, x, y, s, n)
  end
end)
