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

export dgserver, dgport = "127.0.0.1", 25533

sok = socket.udp!
sok\settimeout 0
sokconnect = ->
	sok\settimeout 0
	sok\setpeername dgserver, dgport
	sok\send "hello"

udps = tph.alloc "SOLACE", "UDPS", elements.DEFAULT_PT_WIFI
tph.props udps,
	Name: "UDP", Description: "Send or recieve sparks with UDP server, lua vars dgserver:dgport, works like WIFI"
	Colour: 0x00FF00, MenuSection: elem.SC_ELEC
tph.setupdate udps, (i, x, y, s, n) ->
	for dx = -1, 1, 1 for dy = -1, 1, 1
		if tph.gp("type", x+dx, y+dy) == elements.DEFAULT_PT_SPRK and tph.gp("ctype", x+dx, y+dy) != elements.DEFAULT_PT_NSCN
			sok\setpeername dgserver, dgport
			sok\send math.floor tph.gp "temp", i
			return

tph.setstep ->
	rb = sok\receive!
	if rb != nil
		for i in sim.parts!
			if tph.gp("type", i) == udps then
				y = tph.gp "y", i
				x = tph.gp "x", i
				if math.floor(tonumber rb) == math.floor(tph.gp "temp", i)
					for dx = -1, 1, 1 for dy = -1, 1, 1
						if tph.gp("type", x+dx, y+dy) == elements.DEFAULT_PT_NSCN
							tph.sp "type", elements.DEFAULT_PT_SPRK, x+dx, y+dy
							tph.sp "ctype", elements.DEFAULT_PT_NSCN, x+dx, y+dy

sokconnect!