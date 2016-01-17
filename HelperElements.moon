tph =
	alloc: (a1, a2, a3) ->
		a4 = elements.allocate(a1, a2)
		elements.element(a4, elements.element(a3))
		return a4
	props: (elem, props) -> elements.property(elem, tostring(pkey), pval) for pkey, pval in pairs props
	setupdate: (elem, func) -> tpt.element_func(func, elem)
	setgraphics: (elem, func) -> tpt.graphics_func(func, elem)
	sp: (...) -> return tpt.set_property(...)
	gp: (...) -> return tpt.get_property(...)
	c: (...) -> return tpt.create(...)
	d: (...) -> return tpt.delete(...)
	setstep: (func) -> tpt.register_step(func)

clnr = tph.alloc "SOLACE", "CLNR", elements.DEFAULT_PT_DMND
tph.props clnr,
	Name: "CLNR", Description: "Clean ray. Clears all elements directly under it with a spark above it."
	Color: 0x1BB77E
tph.setupdate clnr, (i, x, y, s, n) ->
	if tph.gp("type", x, y-1) == elements.DEFAULT_PT_SPRK
		for b = y+1, 379, 1
			tph.sp "type", 0, x, b
