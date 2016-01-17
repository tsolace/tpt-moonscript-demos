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

nplm = tph.alloc "FEYNMAN", "NPLM", elements.DEFAULT_PT_BCOL
tph.props nplm,
	Name: "NPLM", Description: "Napalm, very slow-burning powder"
	Colour: 0x850000, MenuSection: elem.SC_EXPLOSIVE
	Weight: 50, Gravity: .5, Flammable: 0, Explosive: 0
	Loss: 1, AirLoss: .5, AirDrag: .01, Advection: .01, Diffusion: 0
tph.setupdate nplm, (i, x, y, s, n) ->
	clife = if tph.gp('type', x, y) != 0 then tph.gp('life', x, y) else 0
	if clife > 1
		tph.c x+cx, y+cy, 'fire' for cy = -1, 1, 2 for cx = -1, 1, 2
		tph.sp 'life', clife - 1, x, y
	elseif clife == 1
		tph.sp 'type', 0, x, y
	elseif s > 0
		for cx = -1, 1, 2 for cy = -1, 1, 2
				if tph.gp('type', x+cx, y+cy) == (4 or 49)
					tph.sp 'life', 500, x, y
					return true
tph.setgraphics nplm, (i, colr, colg, colb) ->
	return 1,0x00000011,255,125,0,0,255,125,0,0

--------------------------------------------------------------------------------

ergy = tph.alloc "QUENTINADAY", "ERGY", elements.DEFAULT_PT_SING
tph.props ergy,
	Name: "ERGY", Description: "Pure energy, extremely powerful"
tph.setupdate ergy, (i, x, y, s, n) ->
	cx, cy = math.random(-1, 1), math.random(-1, 1)
	switch math.random 1, 3
		when 1 then tph.c x + cx, y + cy, 'phot'
		when 2 then tph.c x + cx, y + cy, 'neut'
		when 3 then tph.c x + cx, y + cy, 'elec'
	tph.sp "temp", math.huge, x, y
	sim.pressure x/4, y/4, math.huge

--------------------------------------------------------------------------------

export brptbypass = 0
brpt = tph.alloc "BOXMEIN", "BRPT", elements.DEFAULT_PT_DMND
tph.props brpt,
	Name: "BRPT", Description: "Breakpoints. When spark touches, will pause the game and turn red. Also glowy."
	Colour: 0xDEADBEEF, MenuSection: elem.SC_POWERED, Properties: elem.PROP_LIFE_DEC
tph.setupdate brpt, (i, x, y, s, n) ->
	life = sim.partProperty i, "life"
	for ry = -1, 1, 1 for rx = -1, 1, 1
		if life == 0 and tph.gp("type", x + rx, y + ry) == 15
			tpt.set_pause 1 unless brptbypass == 1
			sim.partProperty i, "life", 10
tph.setgraphics brpt, (i, x, y, s, n) ->
	x, y = sim.partPosition i
	life = sim.partProperty i, "life"
	if life > 0
		pixel_mode = 296
		colg, colb = 0, 0
		colr = 255
	else
		pixel_mode = 1

	return 0, pixel_mode, 255, colr, colg, colb, 255, colr, colg, colb
--------------------------------------------------------------------------------

rcld = tph.alloc "MRSALITOS", "RCLD", elements.DEFAULT_PT_WTRV
tph.props rcld,
	Name: "RCLD", Description: "Raincloud. Produces water infinitely."
	Colour: 0xFFFFFF, MenuSection: 6
	Loss: 0.1, AirLoss: 0.3, Advection: 1, Diffusion: 0.3, Temperature: 273.15
tph.setupdate rcld, (i, x, y, s, n) ->
	switch math.random 0, 2000
		when 1000 then tpt.parts[i].type = elements.DEFAULT_PT_WATR

--------------------------------------------------------------------------------

neon = tph.alloc "MRSALITOS", "NEON", elements.DEFAULT_PT_NBLE
tph.props neon,
	Name: "NEON", Description: "Neon gas. Glows in contact with spark."
	Colour: 0x242424, MenuSection: 6
	Loss: 0.1, AirLoss: 1, Advection: 0.4, Diffusion: 0.5
	Gravity: 0, Flammable: 0, Weight: 0, Properties: 0x4828
colour = {0xFFAA0000,0xFFFF6600,0xFFFFFF00,0xFF00FF00,0xFF00FFFF,0xFF0000FF,0xFF9900CC}
none = 0x00242424
tph.setupdate neon, (i, x, y, s, n) ->
	if tph.gp("tmp", i) == 0
		tph.sp "tmp", 1, i
	if tph.gp("tmp2", i) == 1
		tph.sp "life", 180 + math.random(0, 20), i
		tph.sp "tmp2", 0, i
	if tpt.parts[i].life <= 0 then
		tph.sp "dcolour", none, i
tph.setupdate elements.DEFAULT_PT_SPRK, (i, x, y, s, n) ->
	ntmp = tph.gp "tmp", i
	neontype = tph.gp "ctype", i
	if tph.gp("tmp", i) == ntmp
		if colour[ntmp] != nil
			tph.sp "dcolour", colour[ntmp], x, y
			tph.sp "tmp2", 1, x, y
	if tph.gp("tmp", i) == 8
		tph.sp "dcolour", colour[math.random(1, 7)], i
tph.setgraphics neon, (i, colr, colg, colb) ->
	return 1, 0x00022110, 30, 30, 30, 30, 30, 30, 30, 30

--------------------------------------------------------------------------------

mexp = tph.alloc "QBAMOD", "MEXP", elements.DEFAULT_PT_NBLE
tph.props mexp,
	Name: "MEXP", Description: "Mixed Explosives."
	MenuSection: 5, Colour: 0xAD9B12
	Properties: elements.ST_SOLID + elements.TYPE_SOLID
tph.setupdate mexp, (i, x, y, s, n) ->
	switch math.random 0, 5
		when 1 tph.sp "type", "ligh", x, y
		when 2 tph.sp "type", "plsm", x, y
		when 3 tph.sp "type", "bomb", x, y
		when 4 tph.sp "type", "thdr", x, y
		else tph.sp "type", "nitr", x, y

--------------------------------------------------------------------------------

famr = tph.alloc "QBAMOD", "FAMR", elements.DEFAULT_PT_TTAN
tph.props famr,
	Name: "FAMR", Description: "Fire forged armour."
	Properties: elements.ST_SOLID + elements.TYPE_SOLID
tph.setupdate famr, (i, x, y, s, n) ->
	switch math.random 0, 4
		when 0 then tph.sp "type", "ttan", x, y
		when 1 then tph.sp "type", "qrtz", x, y
		when 2 then tph.sp "type", "coal", x, y
		when 3 then tph.sp "type", "brck", x, y
		else tph.sp "type", "iron", x, y

--------------------------------------------------------------------------------

dttn = tph.alloc "QUENTINADAY", "DTTN", elements.DEFAULT_PT_TTAN
tph.props dttn,
	Name: "DTTN", Description: "Extremely durable TTAN. Evades VIRS and DEST."
	Properties: elements.ST_SOLID + elements.TYPE_SOLID
	HeatConduct: 0, Hardness: 0, Weight: 10000
sim.can_move elements.DEFAULT_PT_DEST, dttn, 0
tph.setupdate dttn, (i, x, y, s, n) ->
	ttype = tph.gp "temp", x, y
	tph.sp "temp", -math.huge, x, y if ttype > 300
	tph.sp "temp", -math.huge, x, y
	ttype = tph.gp "type", x + math.random(-3, 3), y + math.random(-3, 3)
	sim.gravMap x/4, y/4, -256 if ttype == tpt.el.dest.id
	ttype = tph.gp "type", x + math.random(-3, 3), y + math.random(-3, 3)
	tph.c x + math.random(-1, 1), y + math.random(-1, 1), "soap" if ttype == tpt.el.virs.id or ttype == tpt.el.vrss.id or ttype == tpt.el.vrsg.id
	rx, ry = x + math.random(-1, 1), y + math.random(-1, 1)
	ttype = tph.gp "type", rx, ry
	tph.d rx, ry if ttype == tpt.el.soap.id

--------------------------------------------------------------------------------

vols = tph.alloc "MJPOWDER", "VOLS", elements.DEFAULT_PT_DUST
tph.props vols,
	Name: "VOLS", Description: "Oddly colored thing."
	Colour: 0x2BE0CB, MenuSection: elem.SC_GAS
	Loss: 0.1, AirLoss: 1, Advection: 0.4, Diffusion: 0.5
	Temperature: 295, Gravity: 15, Flammable: 98997
	Weight: 999, Properties: 0x4828

--------------------------------------------------------------------------------

jmod = tpt.version.jacob1s_mod

pbhl = tph.alloc "JACOB1", "PBHL", elements.DEFAULT_PT_NBHL
tph.props pbhl,
	Name: "PBHL", Description: "Powered black hole. NSCN/PSCN to charge/take."
	MenuSection: elem.SC_POWERED
elem.property pbhl, "Properties", elem.property(pbhl, "Properties") + elem.PROP_POWERED if jmod

pwhl = tph.alloc "JACOB1", "PWHL", elements.DEFAULT_PT_NWHL
tph.props pwhl,
	Name: "PWHL", Description: "Powered white hole. NSCN/PSCN to charge/take."
	MenuSection: elem.SC_POWERED
elem.property pwhl, "Properties", elem.property(pwhl, "Properties") + elem.PROP_POWERED if jmod

phlupdate = (i, x, y, s, n) ->
	life = sim.partProperty i, sim.FIELD_LIFE
	itype = sim.partProperty i, sim.FIELD_TYPE
	if life == 10
		amount = 1.5
		tmp = sim.partProperty i, sim.FIELD_TMP
		if tmp > 0
			amount = tmp * .015
			if amount < 1.5 then amount = 1.5 elseif amount > 768 then amount = 768
		sim.gravMap x/4, y/4, itype == pbhl and amount or -amount

		for r in sim.neighbors(x, y, 1, 1)
			rtype = sim.partProperty r, sim.FIELD_TYPE
			unless jmod
				if rtype == itype and sim.partProperty(r, sim.FIELD_LIFE) == 9
					sim.partProperty i, sim.FIELD_LIFE, 9
				elseif rtype == tpt.el.sprk.id and sim.partProperty(r, sim.FIELD_CTYPE) == tpt.el.nscn.id
					sim.partProperty i, sim.FIELD_LIFE, 9
			if rtype != nil then
				if itype == pbhl and rtype != itype and bit.band(elem.property(rtype, "Properties"), 0x1F) != 4
					sim.partKill r
	elseif not jmod then
		if life > 0
			sim.partProperty(i, sim.FIELD_LIFE, life-1)
			return
		for r in sim.neighbors(x, y, 1, 1)
			rtype = sim.partProperty r, sim.FIELD_TYPE
			if rtype == itype and sim.partProperty(r, sim.FIELD_LIFE) == 10
				sim.partProperty i, sim.FIELD_LIFE, 10
			elseif rtype == tpt.el.sprk.id and sim.partProperty(r, sim.FIELD_CTYPE) == tpt.el.pscn.id then
				sim.partProperty(i, sim.FIELD_LIFE, 10)
phlgraphics = (i, colr, colg, colb) ->
	life = sim.partProperty(i, sim.FIELD_LIFE)
	divide = life == 10 and 1 or (2.5 - life/8)
	return 0, 1, 255, colr/divide, colg/divide, colb/divide

tph.setupdate pbhl, phlupdate
tph.setupdate pwhl, phlupdate
tph.setgraphics pbhl, phlgraphics
tph.setgraphics pwhl, phlgraphics

--------------------------------------------------------------------------------

song = tph.alloc "RDOCOC", "SONG", elem.DEFAULT_PT_ELEC
tph.props song,
	Name: "SONG", Description: "Sound waves. Heavy energy. Displaces non-solid materials. (rdococ)"
	Colour: 0x0080A0, MenuSection: elem.SC_RADIOACTIVE, Properties: elem.TYPE_ENERGY
	State: elem.ST_NONE, Temperature: 273.15, HeatConduct: 0, Weight: 99
tph.setupdate song, (i, x, y, s, n) ->
	tmp2 = sim.partProperty i, sim.FIELD_TMP2
	if tmp2 == 0
		angle = math.random! * math.pi * 2

		sim.partProperty i, sim.FIELD_TMP2, 1
		sim.partProperty i, sim.FIELD_VX, math.sin(angle)*5
		sim.partProperty i, sim.FIELD_VY, math.cos(angle)*5
tph.setgraphics song, (i, colr, colg, colb) ->
	return 1, ren.PMODE_FLAT+ren.FIRE_BLEND,1,colr,colg,colb,210,colr,colg,colb

--------------------------------------------------------------------------------

radc = tph.alloc "RADIOACTIVELUA", "RADC", elements.DEFAULT_PT_HYGN
tph.props radc,
	Name: "RADC", Description: "Radioactive cloud. Rains radioactive particles."
	Colour: 0x11FF22, MenuSection: 10, Gravity: 0, Explosive: 0
	Weight: 0, Diffusion: 1, Hardness: 0, Flammable: 100000
	AirDrag: 0.01, Loss: 0.1, AirLoss: 0.3, Advection: 1
tph.setupdate radc, (i, x, y, s, n) ->
	switch math.random 1, 500
		when 5  then tph.sp "type", "plut", i
		when 20 then tph.sp "type", "uran", i
		when 30 then tph.sp "type", "isoz", i
		when 40 then tph.sp "type", "deut", i
		when 50 then tph.sp "type", "bvbr", i

--------------------------------------------------------------------------------

bhiv = tph.alloc "RADIOACTIVELUA", "BEE", elements.DEFAULT_PT_WOOD
tph.props bhiv,
	Name: "BHIV", Description: "BEE Hive. Produces BEES. Produced by BEES."
	Colour: 0x999966, Flammable: 10, MenuSection: elem.SC_SPECIAL
tph.setupdate bhiv, (i, x, y, s, n) ->
	tph.c x + math.random(-1, 1), y + math.random(-1, 1), "BEES" if math.random(1, 330) == 10

bees = tph.alloc "RADIOACTIVELUA", "BEES", elements.DEFAULT_PT_DUST
tph.props bees,
	Name: "BEES", Description: "BEES. Pestering demons. Makes BHIV (bee hives)."
	Colour: 0xFFFF00, MenuSection: 11, Gravity: 0.1, Flammable: 10
	Explosive: 0, Weight: -6000, Diffusion: 2, Falldown: 0.2
tph.setupdate bees, (i, x, y, s, n) ->
	tph.c x + math.random(-1, 1), y + math.random(-1, 1), "BHIV" if math.random(1, 9001) == 10

--------------------------------------------------------------------------------

metr = tph.alloc "IFORGOTWHOMADETHIS", "METR", elements.DEFAULT_PT_ELEC
tph.props metr,
	Name: "METR", Description: "Meteors. Explode on impact. Use sparingly."
	Colour: 0xFF7A0002, MenuSection: elem.SC_EXPLOSIVE, MenuVisible: 1
	Weight: 100, Temperature: 9999
tph.setgraphics metr, (i, colr, colg, colb) ->
	return 1, 0x00010000, 255, 255, 0, 210, 255, 255, 255, 255

get_property = (prop, x, y) ->
	if x >= 0 and x < sim.XRES and y >= 0 and y < sim.YRES
		return tph.gp(prop, x, y)
	return 0

math.randomseed os.time!

tph.setupdate metr, (i, x, y, s, n) ->
	if tph.gp("tmp", i) == 0
		tpt.parts[i].tmp = 1
		randvel = math.random(-20, 20)/10
		tpt.parts[i].vx = randvel
		tpt.parts[i].vy = math.sqrt(8 - (randvel ^ 2))
	xvel = tph.gp("vx", i)/2
	yvel = tph.gp("vy", i)/2
	tph.d i if yvel <= 0 or math.abs(xvel) > 1
	xpos = x - xvel
	ypos = y - yvel

	elemtype = get_property "type", xpos, ypos
	if elemtype == 0
		tph.c xpos, ypos, "bray"
		tph.sp("temp", 5000, xpos, ypos)
	tpt.parts[i].temp = 9999

	elemtype25 = get_property "type", x + xvel * 5, y + yvel * 5
	elemtype24 = get_property "type", x + xvel * 4, y + yvel * 4
	elemtype23 = get_property "type", x + xvel * 3, y + yvel * 3
	elemtype22 = get_property "type", x + xvel * 2, y + yvel * 2
	elemtype21 = get_property "type", x + xvel, y + yvel
	if elemtype25 != 0 and elemtype25 != metr and elemtype25 != tpt.el.bray.id and elemtype25 != tpt.el.dmnd.id and elemtype25 != tpt.el.void.id
		tph.sp "type", "bomb", i
		tph.sp "life", 0, i
		tph.sp "tmp", 0, i
	if elemtype24 != 0 and elemtype24 != metr and elemtype24 != tpt.el.bray.id and elemtype24 != tpt.el.dmnd.id and elemtype24 != tpt.el.void.id
		tph.sp "type", "bomb", i
		tph.sp "life", 0, i
		tph.sp "tmp", 0, i
	if elemtype23 != 0 and elemtype23 != metr and elemtype23 != tpt.el.bray.id and elemtype23 != tpt.el.dmnd.id and elemtype23 != tpt.el.void.id
		tph.sp "type", "bomb", i
		tph.sp "life", 0, i
		tph.sp "tmp", 0, i
	if elemtype22 != 0 and elemtype22 != metr and elemtype22 != tpt.el.bray.id and elemtype22 != tpt.el.dmnd.id and elemtype22 != tpt.el.void.id
		tph.sp "type", "bomb", i
		tph.sp "life", 0, i
		tph.sp "tmp", 0, i
	if elemtype21 != 0 and elemtype21 != metr and elemtype21 != tpt.el.bray.id and elemtype21 != tpt.el.dmnd.id and elemtype21 != tpt.el.void.id
		tph.sp "type", "bomb", i
		tph.sp "life", 0, i
		tph.sp "tmp", 0, i

--------------------------------------------------------------------------------

hetr = tph.alloc "YOSHI", "HETR", elements.DEFAULT_PT_DMND
tph.props hetr,
	Name: "HETR", Description: "Maintains a constant max temperature."
	Color: 0xFF1111, MenuSection: 2, HeatConduct: 65535
colr = tph.alloc "YOSHI", "COLR", elements.DEFAULT_PT_DMND
tph.props colr,
	Name: "COLR", Description: "Maintains a constant zero temperature."
	Color: 0x1111FF, MenuSection: 2, HeatConduct: 65535

tph.setstep ->
	tph.sp "temp", 9999, "HETR"
	tph.sp "temp", 0, "COLR"

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
return nil
