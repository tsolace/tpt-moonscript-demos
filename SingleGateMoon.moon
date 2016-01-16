tph =
	alloc: (a1, a2, a3) ->
		a4 = elements.allocate(a1, a2)
		elements.element(a4, elements.element(a3))
		return a4
	props: (elem, props) ->
		elements.property(elem, tostring(pkey), pval) for pkey, pval in pairs props
	setupdate: (elem, func) ->
		tpt.element_func(func, elem)
	setgraphics: (elem, func) ->
		tpt.graphics_func(func, elem)
	sp: (...) ->
		return tpt.set_property(...)
	gp: (...) ->
		return tpt.get_property(...)
	c: (...) ->
		return tpt.create(...)
	d: (...) ->
		return tpt.delete(...)
	setstep: (func) ->
		tpt.register_step(func)

frame_counter = 0
frame_max = 8

gate = tph.alloc "IAMDUMB", "GATE", elements.DEFAULT_PT_BRCK
tph.props gate,
	Name: "GATE", Description: "Multi Logic Gate. PSCN/NSCN in/out. Set tmp: 1=AND 2=OR 3=NOT 4=XOR 5=NAND 6=XNOR"
	MenuSection: 1, Colour: 0x800000

and_update = (index, partx, party, surround, nt) ->
	n_pscn = 0
	
	for dx = -2, 2, 1 for dy = -2, 2, 1
		if tph.gp("type", partx + dx, party + dy) == elements.DEFAULT_PT_SPRK and tph.gp("ctype", partx + dx, party + dy) == elements.DEFAULT_PT_PSCN
			n_pscn += 1
	if n_pscn >= 2 then
		for dx = -2, 2, 1 for dy = -2, 2, 1
			if tph.gp("type", partx + dx, party + dy) == elements.DEFAULT_PT_NSCN and tph.gp("life", partx + dx, party + dy) == 0
				tph.sp "life", 4, partx + dx, party + dy
				tph.sp "ctype", elements.DEFAULT_PT_NSCN, partx + dx, party + dy
				tph.sp "type", elements.DEFAULT_PT_SPRK, partx + dx, party + dy
	return 0

or_update = (index, partx, party, surround, nt) ->
	n_pscn = 0
	
	for dx = -2, 2, 1 for dy = -2, 2, 1
		if tph.gp("type", partx + dx, party + dy) == elements.DEFAULT_PT_SPRK and tph.gp("ctype", partx + dx, party + dy) == elements.DEFAULT_PT_PSCN
			n_pscn += 1
	if n_pscn >= 1 then
		for dx = -2, 2, 1 for dy = -2, 2, 1
			if tph.gp("type", partx + dx, party + dy) == elements.DEFAULT_PT_NSCN and tph.gp("life", partx + dx, party + dy) == 0
				tph.sp "life", 4, partx + dx, party + dy
				tph.sp "ctype", elements.DEFAULT_PT_NSCN, partx + dx, party + dy
				tph.sp "type", elements.DEFAULT_PT_SPRK, partx + dx, party + dy
	return 0

not_update = (index, partx, party, surround, nt) ->
	frame_counter += 1
	frame_counter = 0 if frame_counter == frame_max
	
	n_pscn = 0
	
	for dx = -2, 2, 1 for dy = -2, 2, 1
		whoa = (tpt.get_property("type", partx + dx, party + dy) == elements.DEFAULT_PT_SPRK and tpt.get_property("ctype", partx + dx, party + dy) == elements.DEFAULT_PT_PSCN) or (tpt.get_property("type", partx + dx, party + dy) == elements.DEFAULT_PT_PSCN and tpt.get_property("life", partx + dx, party + dy) > 0)
		if whoa
			n_pscn += 1
	if n_pscn == 0 and frame_counter == 0
		for dx = -2, 2, 1 for dy = -2, 2, 1
			if tph.gp("type", partx + dx, party + dy) == elements.DEFAULT_PT_NSCN and tph.gp("life", partx + dx, party + dy) == 0
				tph.sp "life", 4, partx + dx, party + dy
				tph.sp "ctype", elements.DEFAULT_PT_NSCN, partx + dx, party + dy
				tph.sp "type", elements.DEFAULT_PT_SPRK, partx + dx, party + dy
	return 0

xor_update = (index, partx, party, surround, nt) ->
	n_pscn = 0
	
	for dx = -2, 2, 1 for dy = -2, 2, 1
		if tph.gp("type", partx + dx, party + dy) == elements.DEFAULT_PT_SPRK and tph.gp("ctype", partx + dx, party + dy) == elements.DEFAULT_PT_PSCN
			n_pscn += 1
	
	if n_pscn == 1
		for dx = -2, 2, 1 for dy = -2, 2, 1
			if tph.gp("type", partx + dx, party + dy) == elements.DEFAULT_PT_NSCN and tph.gp("life", partx + dx, party + dy) == 0 then
				tph.sp "life", 4, partx + dx, party + dy
				tph.sp "ctype", elements.DEFAULT_PT_NSCN, partx + dx, party + dy
				tph.sp "type", elements.DEFAULT_PT_SPRK, partx + dx, party + dy
	return 0

nand_update = (index, partx, party, surround, nt) ->
	frame_counter += 1
	frame_counter = 0 if frame_counter == frame_max
	
	n_pscn = 0
	
	for dx = -2, 2, 1 for dy = -2, 2, 1
		whoa = (tpt.get_property("type", partx + dx, party + dy) == elements.DEFAULT_PT_SPRK and tpt.get_property("ctype", partx + dx, party + dy) == elements.DEFAULT_PT_PSCN) or (tpt.get_property("type", partx + dx, party + dy) == elements.DEFAULT_PT_PSCN and tpt.get_property("life", partx + dx, party + dy) > 0)
		if whoa
			n_pscn += 1
	if n_pscn < 2 and frame_counter == 0
		for dx = -2, 2, 1 for dy = -2, 2, 1
			if tph.gp("type", partx + dx, party + dy) == elements.DEFAULT_PT_NSCN and tph.gp("life", partx + dx, party + dy) == 0
				tph.sp "life", 4, partx + dx, party + dy
				tph.sp "ctype", elements.DEFAULT_PT_NSCN, partx + dx, party + dy
				tph.sp "type", elements.DEFAULT_PT_SPRK, partx + dx, party + dy
	return 0

xnor_update = (index, partx, party, surround, nt) ->
	frame_counter += 1
	frame_counter = 0 if frame_counter == frame_max
	
	n_pscn = 0
	
	for dx = -2, 2, 1 for dy = -2, 2, 1
		whoa = (tpt.get_property("type", partx + dx, party + dy) == elements.DEFAULT_PT_SPRK and tpt.get_property("ctype", partx + dx, party + dy) == elements.DEFAULT_PT_PSCN) or (tpt.get_property("type", partx + dx, party + dy) == elements.DEFAULT_PT_PSCN and tpt.get_property("life", partx + dx, party + dy) > 0)
		if whoa
			n_pscn += 1
	if n_pscn != 1 and frame_counter == 0
		for dx = -2, 2, 1 for dy = -2, 2, 1
			if tph.gp("type", partx + dx, party + dy) == elements.DEFAULT_PT_NSCN and tph.gp("life", partx + dx, party + dy) == 0
				tph.sp "life", 4, partx + dx, party + dy
				tph.sp "ctype", elements.DEFAULT_PT_NSCN, partx + dx, party + dy
				tph.sp "type", elements.DEFAULT_PT_SPRK, partx + dx, party + dy
	return 0

tph.setupdate gate, (i, x, y, s, n) ->
	switch tph.gp("tmp", i)
		when 1 then return  and_update i, x, y, s, n
		when 2 then return  or_update  i, x, y, s, n
		when 3 then return  not_update i, x, y, s, n
		when 4 then return  xor_update i, x, y, s, n
		when 5 then return nand_update i, x, y, s, n
		when 6 then return xnor_update i, x, y, s, n