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

tres = tph.alloc "SOLACE", "TRES", elements.DEFAULT_PT_DUST
tph.props tres,
	Name: "TRES", Description: "Seed to generate random tree after 2 seconds."
	Colour: 0x00FF00, MenuSection: elem.SC_SPECIAL
tph.setupdate tres, (i, x, y, s, n) ->
	if tph.gp("tmp2", i) == 1
		if os.time! > tph.gp("tmp", i) + 2
			k = math.random 40, 55
			kk = math.random 40, 55
			l = math.random 55, 90
			ll = math.random 10, 22
			lll = math.random 10, 22
			r = 0
			for o = 1, l
				b = math.random 0, 10
				if b == 1
					r += 1
					tph.c x+r, y-o, 'wood'
					x += 1
				elseif b == 2
					r -= 1
					tph.c x+r, y-o, 'wood'
					x -= 1
				else
					tph.c x, y-o, 'wood'

				if o == 39
					tph.c x+i, y-39, 'plnt' for i = 1, 2
					tph.c x-i, y-39, 'plnt' for i = 1, 2

				if o == 40
					tph.c x+i, y-40, 'plnt' for i = 1, 3
					tph.c x-i, y-40, 'plnt' for i = 1, 3

				if o == k
					yb = y
					for i = 1, ll
						q = math.random 0, 4
						if q == 1
							tph.c x+i, y-k-i, 'wood'
							y += 1
						elseif b == 2
							tph.c x+i, y-k-i, 'wood'
							y -= 1
						else
							tph.c x+i, y-k-i, 'wood'
						tph.c x+i, y-k-i, 'vine'
					y = yb

				if o == kk
					yb = y
					for i = 1, lll
						q = math.random 0, 4
						if q == 1
							tph.c x-i, y-kk-i, 'wood'
							y += 1
						elseif b == 2
							tph.c x-i, y-kk-i, 'wood'
							y -= 1
						else
							tph.c x-i, y-kk-i, 'wood'
						tph.c x-i, y-kk-i, 'vine'
					y = yb

				if o == l - 1
					tph.c x, y-l, 'vine'
			tph.sp "tmp", 0, i
			tph.sp "tmp2", 0, i
			tph.sp "type", "wood", i
	else
		tph.sp "tmp", os.time!, i
		tph.sp "tmp2", 1, i

rbom = tph.alloc "SOLACE", "RBOM", elements.DEFAULT_PT_DMND
tph.props rbom,
	Properties: TYPE_LIQUID, State: ST_LIQUID, Falldown: 2, Advection: 0.04, Loss: 1, Gravity: 0.04
	AirLoss: 0.90, Weight: 3, Name: "RBOM", Color: 0xFFFE8915, MenuSection: elem.SC_SPECIAL
	Description: "Liquid Random Bomb. Particle turns into a random element after 30 seconds."
tph.setupdate rbom, (i, x, y, s, n) ->
	if tph.gp("tmp2", i) == 1
		if os.time! > tph.gp("tmp", i) + 30
			tph.sp "tmp", 0, i
			tph.sp "tmp2", 0, i
			pcall(tpt.set_property, "type", math.random(1, 255), i)
	else
		tph.sp "tmp", os.time!, i
		tph.sp "tmp2", 1, i

export timertype = "DMND"

ttim = tph.alloc "SOLACE", "TTIM", elements.DEFAULT_PT_DMND
tph.props ttim,
	Properties: TYPE_LIQUID, State: ST_LIQUID, Falldown: 2, Advection: 0.04, Loss: 1, Gravity: 0.04
	AirLoss: 0.90, Weight: 3, Name: "TTIM", Color: 0x8F468F, MenuSection: elem.SC_SPECIAL
	Description: "Type Timer liquid, changes to its ctype (from lua var timertype) after 30 sec"
tph.setupdate ttim, (i, x, y, s, n) ->
	if tph.gp("tmp2", i) == 1
		if os.time! > tph.gp("tmp", i) + 30
			tph.sp "tmp", 0, i
			tph.sp "tmp2", 0, i
			tph.sp "type", tph.gp("ctype",i), i
	else
		tph.sp "tmp", os.time!, i
		tph.sp "tmp2", 1, i
		tph.sp "ctype", timertype, i

nr, ng, nb = 0, 0, 0
checkedtime = false
settime = 0
tph.setstep ->
	if checkedtime == true then
		if socket.gettime! > settime + 0.1
			nr, ng, nb = math.random(50, 255), math.random(50, 255), math.random(50, 255)
			checkedtime = 0
	else
		settime = socket.gettime!
		checkedtime = true
tcol = tph.alloc "SOLACE", "TCOL", elements.DEFAULT_PT_DMND
tph.props tcol,
	Name: "TCOL", Description: "Random color every 0.1 second"
	Color: 0xFFFFFF, MenuSection: elem.SC_SPECIAL
tph.setgraphics tcol, (i, r, g, b) ->
	return 0, PMODE_FLAT, nr, ng, nb

tcln = tph.alloc "SOLACE", "TCLN", elements.DEFAULT_PT_DMND
tph.props tcln,
	Name: "TCLN", Description: "CLNE that clones every second"
	Color: 0xFFEEAA, MenuSection: elem.SC_SPECIAL
tph.setupdate tcln, (i, x, y, s, n) ->
	if tph.gp("tmp2", i) == 1
		if tonumber(string.sub(tostring(socket.gettime!*100), 5)) > tph.gp("tmp", i)+(tph.gp("life", i)/10)
			for dx = -1, 1, 1 for dy = -1, 1, 1
				unless dx == 0 and dy == 0
					tph.c x+dx, y+dy, tph.gp("ctype", i)
			tph.sp "tmp2", 0, i
	else
		tph.sp "tmp", tonumber(string.sub(tostring(socket.gettime!*100), 5)), i
		tph.sp "tmp2", 1, i
	if tph.gp("ctype", i) == 0
		for dx = -1, 1, 1 for dy = -1, 1, 1
			gtype = tph.gp("type", x + dx, y + dy)
			if gtype != 0 and gtype != tcln
				tph.sp "ctype", tph.gp("type", x+dx, y+dy), i
	if tph.gp("life", i) == 0
		tph.sp "life", 1000, i

return nil
