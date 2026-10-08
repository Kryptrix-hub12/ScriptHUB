--!nonstrict
--[[
=====================================================================
  Luau Runtime Dumper  —  Luraph 15.1 + PolSec + Luarmor
=====================================================================
  NEW in this build:
    • Luraph.Macros     — full LPH_* macro expansion
                          (LPH_ENCNUM/ENCSTR/ENCFUNC/JIT/CRASH/etc)
    • Luraph.Decoder    — C# ported: Base85, VarInt, Float64,
                          LCG char-table string decryption
    • Luraph.OpcodeTable — the entire 15.1 opcode map (4 modes,
                          ~320 handlers) as data
    • Luraph.Lifter     — lifts raw bytecode to readable ops using
                          the opcode map
    • Luraph.AutoDetect — brute-forces offsets & dispatch config
    • Luraph.AntiSource — strips anti-deobfuscate / anti-tamper
                          from decoded output post-decode
    • PolSec bypass (kept from prior build)
    • Luarmor bypass (kept from prior build)
    • Watermark: "LEAKED BY GOJO " x12 on every line
=====================================================================
]]

--=====================================================================
-- 0.  CONFIG
--=====================================================================

local CONFIG = {
	OutputFolder     = "luau_dumps",
	CaptureLoadstring = true, CaptureStrings = true,
	CaptureBytecode = true, CaptureCharCalls = true,
	TraceGlobals = true, TraceCalls = true,
	Stealth = true, PreferGetgenv = true,
	PolSecBypass = true, NeutralizeKick = true, PolSecHash = 603068048,
	LuarmorMode = true, BypassCheckcaller = true,
	CaptureHttpGet = true, CaptureLRMVars = true, SaveRawLoader = true,
	LuraphMode = true, DecryptConstants = true, TryAutoDetect = true,
	TraceDispatch = true, MaxDispatchLog = 20000,
	StripAfterDecode = true,
	Watermark = true, WatermarkText = "LEAKED BY GOJO ", WatermarkRepeat = 12,
	TryXorSingle = true, TryXorRepeating = true, TryBase64 = true,
	TryHex = true, TryRot = true, TryRC4 = true, TryLPHString = true,
	MinDecryptScore = 45, MaxKeyLength = 16,
	MaxProtoDepth = 16, MaxStringLen = 1e7,
	MaxReportStrings = 800, MaxCallLog = 5000,
	EnableRewriter = true, EnableConstantFold = true,
	Verbose = true,
}

--=====================================================================
-- 1.  LOGGING + SAFE HELPERS
--=====================================================================

local LOG_PREFIX = "[dumper]"
local function log(fmt, ...)
	if not CONFIG.Verbose then return end
	local ok, msg = pcall(string.format, fmt, ...)
	print(LOG_PREFIX .. " " .. (ok and msg or tostring(fmt)))
end
local function warn_(fmt, ...)
	local ok, msg = pcall(string.format, fmt, ...)
	warn(LOG_PREFIX .. " " .. (ok and msg or tostring(fmt)))
end

local pack = table.pack
local unpack = table.unpack or unpack
local function safeCall(fn, ...)
	if type(fn) ~= "function" then return false end
	local r = pack(pcall(fn, ...))
	if not r[1] then return nil, r[2] end
	return unpack(r, 2, r.n)
end
local function safeDebug(name, ...)
	if not debug or type(debug[name]) ~= "function" then return nil end
	return safeCall(debug[name], ...)
end

--=====================================================================
-- 2.  EXECUTOR DETECTION
--=====================================================================

local EXEC = {}
do
	local function first(...)
		for i = 1, select("#", ...) do
			local v = select(i, ...)
			if v ~= nil then return v end
		end
	end
	EXEC.getgenv     = first(getgenv, function() return _G end)
	EXEC.getrenv     = first(getrenv, function() return _G end)
	EXEC.hookfunction = first(hookfunction, replaceclosure)
	EXEC.writefile   = first(writefile, appendfile)
	EXEC.readfile    = first(readfile)
	EXEC.isfolder    = first(isfolder, function() return false end)
	EXEC.makefolder  = first(makefolder)
	EXEC.checkcaller = first(checkcaller)
	EXEC.getrawmetatable = first(getrawmetatable, getmetatable)
	EXEC.hookmetamethod = first(hookmetamethod)
	EXEC.newcclosure = first(newcclosure)
	EXEC.request     = first(request, http_request)
	EXEC.getnamecallmethod = first(getnamecallmethod)
	EXEC.setreadonly = first(setreadonly)
end

--=====================================================================
-- 3.  HOOK INSTALLATION (getgenv-preferred)
--=====================================================================

local function installGlobal(name, wrapper, real)
	local genv = EXEC.getgenv()
	if not genv then return false end
	real = real or genv[name]
	if EXEC.hookfunction and type(real) == "function" then
		local ok = pcall(EXEC.hookfunction, real, wrapper)
		if ok then pcall(function() genv[name] = wrapper end); return true end
	end
	if CONFIG.PreferGetgenv then
		pcall(function() genv[name] = wrapper end); return true
	end
	pcall(function() _G[name] = wrapper end); return true
end

--=====================================================================
-- 4.  LURAPH MODULE
--=====================================================================

local Luraph = {
	active = false,
	chunk = nil,
	settings = nil,
	decodeOk = false,
	dispatch = nil,
	dispatchLog = {},
	logCount = 0,
	handlerNames = {},
	antiSourcePatterns = {},
}

--=====================================================================
-- 4a.  LURAPH MACROS  (LPH_* expansion)
--=====================================================================

Luraph.Macros = {}

-- The macro table is what a deobfuscator inserts before the
-- obfuscated body. We install these into the environment so that
-- the payload can call them without error.
function Luraph.Macros.build()
	return {
		LPH_OBFUSCATED = true,
		LPH_ENCNUM = function(toEncrypt, ...)
			assert(type(toEncrypt) == "number" and select("#", ...) == 0,
				"LPH_ENCNUM only accepts a single constant double or integer as an argument.")
			return toEncrypt
		end,
		LPH_NUMENC = function(...) return Luraph.Macros.install.LPH_ENCNUM(...) end,
		LPH_ENCSTR = function(toEncrypt, ...)
			assert(type(toEncrypt) == "string" and select("#", ...) == 0,
				"LPH_ENCSTR only accepts a single constant string as an argument.")
			return toEncrypt
		end,
		LPH_STRENC = function(...) return Luraph.Macros.install.LPH_ENCSTR(...) end,
		LPH_ENCFUNC = function(toEncrypt, encKey, decKey, ...)
			assert(type(toEncrypt) == "function" and type(encKey) == "string" and select("#", ...) == 0,
				"LPH_ENCFUNC accepts a constant function, constant string, and string variable as arguments.")
			return toEncrypt
		end,
		LPH_FUNCENC = function(...) return Luraph.Macros.install.LPH_ENCFUNC(...) end,
		LPH_JIT = function(f, ...)
			assert(type(f) == "function" and select("#", ...) == 0,
				"LPH_JIT only accepts a single constant function as an argument.")
			return f
		end,
		LPH_JIT_MAX = function(...) return Luraph.Macros.install.LPH_JIT(...) end,
		LPH_NO_VIRTUALIZE = function(f, ...)
			assert(type(f) == "function" and select("#", ...) == 0,
				"LPH_NO_VIRTUALIZE only accepts a single constant function as an argument.")
			return f
		end,
		LPH_NO_UPVALUES = function(f, ...)
			assert(type(setfenv) == "function",
				"LPH_NO_UPVALUES can only be used on Lua versions with getfenv & setfenv")
			assert(type(f) == "function" and select("#", ...) == 0,
				"LPH_NO_UPVALUES only accepts a single constant function as an argument.")
			local env = (getrenv and getrenv()) or _G
			return setfenv(
				Luraph.Macros.install.LPH_NO_VIRTUALIZE(function(...)
					return func(...)
				end),
				setmetatable({ func = f }, { __index = env, __newindex = env })
			)
		end,
		LPH_CRASH = function(...)
			return print(debug.traceback())
		end,
	}
end

Luraph.Macros.install = Luraph.Macros.build()

function Luraph.Macros.applyTo(env)
	if type(env) ~= "table" then return end
	for k, v in pairs(Luraph.Macros.install) do
		if env[k] == nil then env[k] = v end
	end
end

--=====================================================================
-- 4b.  LURAPH DECODER  (C# ported)
--=====================================================================

Luraph.Decoder = {}

local UTF8_STRICT = function(b)
	-- approximate strict UTF-8 check
	local i, n = 1, #b
	while i <= n do
		local c = string.byte(b, i)
		if c < 0x80 then i = i + 1
		elseif c >= 0xC2 and c <= 0xDF then
			if i + 1 > n or string.byte(b, i+1) < 0x80 or string.byte(b, i+1) > 0xBF then return false end
			i = i + 2
		elseif c >= 0xE0 and c <= 0xEF then
			if i + 2 > n then return false end
			local b2, b3 = string.byte(b, i+1), string.byte(b, i+2)
			if b2 < 0x80 or b2 > 0xBF or b3 < 0x80 or b3 > 0xBF then return false end
			i = i + 3
		elseif c >= 0xF0 and c <= 0xF4 then
			if i + 3 > n then return false end
			i = i + 4
		else return false end
	end
	return true
end

-- Base85 decode (Luraph's LPH1 variant — 5 chars -> 4 bytes)
function Luraph.Decoder.base85(encoded)
	if type(encoded) ~= "string" then return nil end
	if encoded:sub(1,3) == "LPH" then encoded = encoded:sub(5) end
	encoded = encoded:gsub("z", "!!!!!")

	local out = {}
	local i = 1
	local n = #encoded
	while i + 4 <= n do
		local a = string.byte(encoded, i)   - 33
		local b = string.byte(encoded, i+1) - 33
		local c = string.byte(encoded, i+2) - 33
		local d = string.byte(encoded, i+3) - 33
		local e = string.byte(encoded, i+4) - 33
		local v = a * 52200625 + b * 614125 + c * 7225 + d * 85 + e
		out[#out+1] = string.char(
			math.floor(v / 16777216) % 256,
			math.floor(v / 65536) % 256,
			math.floor(v / 256) % 256,
			v % 256
		)
		i = i + 5
	end
	return table.concat(out)
end

-- A streaming reader over the decoded byte blob
local function makeReader(data)
	local pos = 0
	local R = {}
	function R.byte()
		if pos >= #data then return 0 end
		pos = pos + 1
		return string.byte(data, pos)
	end
	function R.uint32()
		local a = R.byte()
		local b = R.byte()
		local c = R.byte()
		local d = R.byte()
		return d * 16777216 + c * 65536 + b * 256 + a
	end
	function R.varint()
		local v, m = 0, 1
		while true do
			local b = R.byte()
			local payload = b > 127 and (b - 128) or b
			v = v + payload * m
			m = m * 128
			if b < 128 then break end
		end
		return v
	end
	function R.int64()
		local low = R.uint32()
		local high = R.uint32()
		local highSigned = high >= 2147483648 and (high - 4294967296) or high
		return highSigned * 4294967296 + low
	end
	function R.float64()
		local left = R.uint32()
		local right = R.uint32()
		if left == 0 and right == 0 then return 0.0 end
		local sign = math.floor(right / 2147483648) % 2
		local exponent = math.floor(right / 1048576) % 2048
		local mantissa = (right % 1048576) * 4294967296 + left
		local isNormal = 1
		if exponent == 0 then
			if mantissa == 0 then return sign == 1 and -0.0 or 0.0 end
			isNormal = 0
			exponent = 1
		elseif exponent == 2047 then
			return mantissa == 0 and (sign == 1 and -math.huge or math.huge) or (0/0)
		end
		local s = sign == 1 and -1.0 or 1.0
		return s * (2 ^ (exponent - 1023)) * (mantissa / 4503599627370496.0 + isNormal)
	end
	function R.rawBytes()
		local len = R.varint()
		if len == 0 then return "" end
		local s = data:sub(pos + 1, pos + len)
		pos = pos + len
		return s
	end
	function R.pos() return pos end
	function R.skip(k) pos = pos + k end
	return R
end

Luraph.Decoder.makeReader = makeReader

-- LCG char table
local function buildCharTable(initState, xorMask, a, c)
	local t = {}
	local state = initState
	local mask = xorMask
	for i = 0, 255 do
		local idx = bit32.bxor(state, mask) % 256
		t[idx] = state % 256
		state = (a * state + c) % 256
	end
	return t
end

local function scoreDecodedString(s)
	if type(s) ~= "string" or #s == 0 then return 0 end
	local score, printable = 0, 0
	for i = 1, #s do
		local b = string.byte(s, i)
		if b == 10 or b == 13 or b == 9 or (b >= 32 and b <= 126) then
			printable = printable + 1
			score = score + 2
		elseif b < 32 then
			score = score - 2
		else
			score = score + 1
		end
	end
	if printable * 100 / #s >= 70 then score = score + 15 end
	return score
end

local function decryptStringBytes(raw, initState, xorMask, a, c, useCharTable, advanceKeyBefore)
	local charTable = useCharTable and buildCharTable(initState, xorMask, a, c) or nil
	if #raw < 3 then return raw end
	local key = string.byte(raw, 2)
	if advanceKeyBefore then key = (a * key + c) % 256 end
	local out = {}
	for i = 3, #raw do
		local b = string.byte(raw, i)
		local idx = bit32.bxor(b, key) % 256
		out[#out+1] = string.char(charTable and charTable[idx] or idx)
		key = (a * key + c) % 256
	end
	return table.concat(out)
end

function Luraph.Decoder.decryptString(raw, settings)
	if #raw == 0 then return "" end
	local flag = string.byte(raw, 1)
	if flag == 0 then
		return raw:sub(2)
	end
	local cands = {}
	local function try(init, mask, a, c, useTable, advance)
		local r = decryptStringBytes(raw, init, mask, a, c, useTable, advance)
		cands[#cands+1] = { text = r, score = scoreDecodedString(r) }
	end
	try(settings.CharTableInitState, settings.CharTableXorMask,
		settings.LcgMultiplier, settings.LcgIncrement, true, true)
	try(settings.CharTableInitState, settings.CharTableXorMask,
		settings.LcgMultiplier, settings.LcgIncrement, true, false)
	try(0, settings.CharTableXorMask,
		settings.LcgMultiplier, settings.LcgIncrement, true, true)
	try(185, settings.CharTableXorMask,
		settings.LcgMultiplier, settings.LcgIncrement, true, true)
	try(settings.CharTableInitState, settings.CharTableXorMask,
		settings.LcgMultiplier, settings.LcgIncrement, false, true)
	table.sort(cands, function(x, y) return x.score > y.score end)
	return cands[1] and cands[1].text or ""
end

--=====================================================================
-- 4c.  OPCODE TABLE  (full 15.1 map — modes 229, 12, 6, 56)
--=====================================================================

-- Each entry: { category = "...", body = "...", obs = N }
-- Body is the pseudo-Luau handler body observed in the VM.

Luraph.OpcodeTable = {
	[229] = {
		[0]  = { cat="operation",  obs=0,   body="Jb=yb[E[z]];yb[s[z]]=_(V(Jb,I[z],Jb.n));" },
		[1]  = { cat="nop",        obs=47,  body="" },
		[2]  = { cat="operation",  obs=0,   body="Jb=I[z];Z,w,Q=yb[Jb],yb[Jb+1],yb[Jb+2];yb[Jb]=Z(w,Q);" },
		[3]  = { cat="operation",  obs=6,   body="Jb=J[I[z]];Jb[4][Jb[7]][yb[E[z]]]=R[z];" },
		[4]  = { cat="operation",  obs=0,   body="local r,Yb,Eb=y,E[z],s[z];...for Yb=ab,ab+Ob-1,1 do e(r,Yb,(u(n(r,Yb),Eb)));end;E[z],s[z],I[z],j[z]=152,167,6,1;" },
		[5]  = { cat="return",     obs=0,   body="if M then for r in o,M,nil do ...M[r]=nil;end;end;return;" },
		[6]  = { cat="operation",  obs=1,   body="Jb,Z=E[z],I[z];w={[D]=Z-Jb+1};H(yb,Jb,Z,1,w);yb[s[z]]=w;" },
		[7]  = { cat="operation",  obs=0,   body="yb[s[z]](yb[E[z]]);" },
		[8]  = { cat="operation",  obs=0,   body="yb[s[z]]=c[E[z]];" },
		[9]  = { cat="operation",  obs=0,   body="yb[s[z]]=yb[I[z]]%E[z];" },
		[10] = { cat="operation",  obs=6,   body="Jb=J[I[z]];Jb[4][Jb[7]][yb[E[z]]]=yb[s[z]];" },
		[11] = { cat="operation",  obs=0,   body="yb[E[z]]=yb[I[z]](yb[s[z]]);" },
		[12] = { cat="operation",  obs=22,  body="Jb=J[I[z]];yb[s[z]]=Jb[4][Jb[7]][yb[E[z]]];" },
		[13] = { cat="operation",  obs=0,   body="yb[s[z]]=yb[E[z]]+I[z];" },
		[14] = { cat="operation",  obs=0,   body="yb[s[z]]=J[I[z]];" },
		[15] = { cat="operation",  obs=0,   body="yb[I[z]]();" },
		[16] = { cat="operation",  obs=55,  body="yb[s[z]]=yb[E[z]]<=I[z];" },
		[17] = { cat="operation",  obs=147, body="z=if yb[E[z]]<=I[z]then s[z]else z;" },
		[18] = { cat="mode_switch",obs=20,  body="f,z=E[z],s[z]+1;break;" },
		[19] = { cat="operation",  obs=0,   body="yb[E[z]]=s[z]*yb[I[z]];" },
		[20] = { cat="instr_rw",   obs=0,   body="Jb,Z,w=E[z],s[z],I[z];Q=...instruction rewrite;z-=1;" },
		[21] = { cat="operation",  obs=10,  body="yb[E[z]]=yb[s[z]]==yb[I[z]];" },
		[22] = { cat="operation",  obs=0,   body="yb[I[z]]=yb[s[z]](v[z]);" },
		[23] = { cat="operation",  obs=32,  body="yb[s[z]]=not yb[I[z]];" },
		[24] = { cat="operation",  obs=169, body="z=yb[E[z]];" },
		[25] = { cat="operation",  obs=72,  body="yb[s[z]]=yb[E[z]];" },
		[26] = { cat="return",     obs=0,   body="...return yb[E[z]];" },
		[27] = { cat="operation",  obs=0,   body="Jb=R[z];...w=c[Jb[Jb[2]]](c,r,Jb);K(w,Fb);yb[E[z]]=w;" },
		[28] = { cat="operation",  obs=0,   body="Jb=J[E[z]];yb[s[z]]=Jb[4][Jb[7]];" },
		[29] = { cat="operation",  obs=0,   body="yb[I[z]]=yb[s[z]]==E[z];" },
		[30] = { cat="operation",  obs=267, body="z=E[z];" },
		[31] = { cat="instr_rw",   obs=1,   body="Jb,Z,w=I[z],s[z],E[z];...instruction rewrite;z-=1;" },
		[32] = { cat="operation",  obs=0,   body="Jb=J[I[z]];Jb[4][Jb[7]]=yb[s[z]];" },
		[33] = { cat="operation",  obs=0,   body="yb[I[z]]=yb[s[z]]();" },
		[34] = { cat="instr_rw",   obs=9,   body="Jb=I[z]+1;for r=1,E[z],1 do ...;j[z]=1;" },
		[35] = { cat="operation",  obs=238, body="yb[E[z]]=I[z];" },
		[36] = { cat="instr_rw",   obs=41,  body="Jb,Z,w=I[z],E[z],s[z];...instruction rewrite;z-=1;" },
		[37] = { cat="operation",  obs=1,   body="Jb,Z,w=s[z],{...},I[z];H(Z,1,Jb-1,w,yb);yb[w+Jb-1]=_(r(Jb,...));" },
		[38] = { cat="operation",  obs=0,   body="yb[I[z]]=R[z];" },
		[39] = { cat="operation",  obs=0,   body="Jb,Z,w=I[z],E[z],s[z];..._(yb[Jb](V(W,1,W[D])));" },
		[40] = { cat="operation",  obs=129, body="z=if yb[s[z]]then E[z]else I[z];" },
		[41] = { cat="operation",  obs=18,  body="Jb,Z={...},I[z];H(Jb,1,E[z],Z,yb);" },
	},
	[12] = {
		[0]  = { cat="operation",  obs=46,  body="yb[s[z]]=yb[E[z]];" },
		[1]  = { cat="operation",  obs=0,   body="yb[j[z]]=yb[E[z]]+yb[s[z]];" },
		[2]  = { cat="operation",  obs=0,   body="yb[s[z]]=j[z]-yb[E[z]];" },
		[3]  = { cat="operation",  obs=0,   body="c[E[z]]=yb[s[z]];" },
		[4]  = { cat="operation",  obs=0,   body="yb[j[z]]=#yb[E[z]];" },
		[5]  = { cat="operation",  obs=99,  body="z=j[z];" },
		[6]  = { cat="operation",  obs=0,   body="yb[j[z]]=yb[E[z]](R[z]);" },
		[7]  = { cat="operation",  obs=70,  body="z=if yb[s[z]]then E[z]else j[z];" },
		[8]  = { cat="operation",  obs=0,   body="yb[s[z]]=yb[j[z]]+E[z];" },
		[9]  = { cat="operation",  obs=0,   body="yb[s[z]]=yb[E[z]][j[z]];" },
		[10] = { cat="operation",  obs=0,   body="yb[s[z]]=yb[E[z]]~=j[z];" },
		[11] = { cat="operation",  obs=25,  body="yb[E[z]]=yb[s[z]]<=j[z];" },
		[12] = { cat="operation",  obs=20,  body="yb[j[z]]=not yb[E[z]];" },
		[13] = { cat="operation",  obs=0,   body="yb[E[z]]=Y[z]+R[z];" },
		[14] = { cat="mode_switch",obs=13,  body="local r=z;f,z=E[r],j[r]+1;break;" },
		[15] = { cat="instr_rw",   obs=12,  body="local r=z;...instruction rewrite;I[r]=43;" },
		[16] = { cat="operation",  obs=0,   body="yb[E[z]]=yb[s[z]]-j[z];" },
		[17] = { cat="operation",  obs=0,   body="Jb=j[z];yb[Jb]=yb[Jb](yb[Jb+1],yb[Jb+2],yb[Jb+3]);" },
		[18] = { cat="operation",  obs=0,   body="Jb,Z,w,Q=s[z],T();if Z then yb[Jb+1]=w;yb[Jb+2]=Q;z=E[z];end;" },
		[19] = { cat="operation",  obs=0,   body="yb[s[z]]=yb[E[z]][yb[j[z]]];" },
		[20] = { cat="instr_rw",   obs=0,   body="Jb,Z,w=s[z],E[z],j[z];...instruction rewrite;z-=1;" },
		[21] = { cat="operation",  obs=20,  body="yb[E[z]]=c[j[z]];" },
		[22] = { cat="operation",  obs=0,   body="yb[E[z]](yb[s[z]],yb[j[z]]);" },
		[23] = { cat="operation",  obs=1,   body="yb[E[z]](yb[s[z]]);" },
		[24] = { cat="operation",  obs=0,   body="T,cb,N,h=h[5],h[7],h[6],h[8];" },
		[25] = { cat="operation",  obs=1,   body="yb[s[z]]=y;" },
		[26] = { cat="operation",  obs=0,   body="yb[j[z]]=yb[E[z]]%R[z];" },
		[27] = { cat="operation",  obs=84,  body="yb[s[z]]=E[z];" },
		[28] = { cat="operation",  obs=1,   body="...byte patch loop;j[z],E[z],s[z],I[z]=120,36,128,43;" },
		[29] = { cat="operation",  obs=0,   body="for r=j[z],E[z],1 do yb[r]=nil;end;" },
		[30] = { cat="operation",  obs=5,   body="Jb,Z,w=E[z],s[z],j[z];Q,l,W=Jb+w-1,Jb+Z,_(yb[Jb](V(yb,Jb+1,Jb+Z)));H(W,1,w,Jb,yb);" },
		[31] = { cat="operation",  obs=0,   body="yb[s[z]]=yb[E[z]]>=yb[j[z]];" },
		[32] = { cat="instr_rw",   obs=1,   body="Jb,Z,w=j[z],E[z],s[z];...instruction rewrite;z-=1;" },
		[33] = { cat="operation",  obs=0,   body="Jb,Z,w=j[z],E[z],s[z];Q=Jb+Z;yb[Jb]=_(yb[Jb](V(yb,Jb+1,Q)));" },
		[34] = { cat="operation",  obs=0,   body="yb[E[z]]=s[z]*yb[j[z]];" },
		[35] = { cat="operation",  obs=0,   body="yb[s[z]]=u(yb[E[z]],Y[z]);" },
		[36] = { cat="operation",  obs=1,   body="Jb=R[z];...w=c[Jb[Jb[2]]](c,xb,Jb);K(w,Fb);yb[E[z]]=w;" },
		[37] = { cat="operation",  obs=0,   body="z=if yb[s[z]]==j[z]then E[z]else z;" },
		[38] = { cat="operation",  obs=0,   body="yb[s[z]]={};" },
		[39] = { cat="operation",  obs=0,   body="yb[j[z]]=x(E[z]);" },
		[40] = { cat="operation",  obs=0,   body="yb[E[z]]=c;" },
		[41] = { cat="operation",  obs=0,   body="Jb,Z,w=s[z],E[z],j[z];Q,l=yb[Jb],Jb+Z;W=yb[l];H(yb,Jb+1,l-1,w+1,Q);H(W,1,W[D],w+Z,Q);" },
		[42] = { cat="operation",  obs=0,   body="yb[s[z]]=yb[E[z]]*j[z];" },
		[43] = { cat="nop",        obs=60,  body="" },
		[44] = { cat="operation",  obs=10,  body="Jb=s[z];Z,w,Q=yb[Jb],yb[Jb+1],yb[Jb+2];yb[Jb]=Z(w,Q);" },
		[45] = { cat="operation",  obs=0,   body="yb[j[z]]=yb[s[z]]==E[z];" },
		[46] = { cat="operation",  obs=0,   body="yb[s[z]]=yb[E[z]]/j[z];" },
		[47] = { cat="operation",  obs=10,  body="Jb=J[j[z]];yb[E[z]]=Jb[4][Jb[7]];" },
		[48] = { cat="return",     obs=0,   body="...return;" },
		[49] = { cat="operation",  obs=0,   body="yb[E[z]]=c[R[z]];" },
		[50] = { cat="operation",  obs=0,   body="local r=E[z];...M[r]=nil;..." },
		[51] = { cat="operation",  obs=0,   body="yb[s[z]]=yb[j[z]]<=yb[E[z]];" },
		[52] = { cat="instr_rw",   obs=0,   body="Jb,Z,w=E[z],s[z],j[z];...instruction rewrite;z-=1;" },
		[53] = { cat="operation",  obs=0,   body="Jb=J[E[z]];Jb[4][Jb[7]]=yb[j[z]];" },
		[54] = { cat="operation",  obs=64,  body="z=yb[s[z]];" },
		[55] = { cat="operation",  obs=0,   body="yb[s[z]]=yb[j[z]]<E[z];" },
		[56] = { cat="operation",  obs=5,   body="Jb=J[j[z]];yb[E[z]]=Jb[4][Jb[7]][yb[s[z]]];" },
		[57] = { cat="operation",  obs=0,   body="yb[s[z]][E[z]]=yb[j[z]];" },
		[58] = { cat="return",     obs=6,   body="...return yb[s[z]];" },
		[59] = { cat="operation",  obs=55,  body="z=if yb[E[z]]<=s[z]then j[z]else z;" },
		[60] = { cat="operation",  obs=0,   body="Jb=J[s[z]];Jb[4][Jb[7]][v[z]]=yb[j[z]];" },
		[61] = { cat="instr_rw",   obs=0,   body="Jb,Z,w=E[z],j[z],s[z];...instruction rewrite;z-=1;" },
		[62] = { cat="operation",  obs=0,   body="yb[E[z]][R[z]]=yb[j[z]];" },
		[63] = { cat="operation",  obs=0,   body="yb[s[z]]();" },
		[64] = { cat="operation",  obs=0,   body="Jb,Z,w=j[z],s[z],E[z];Q=yb[Jb];H(yb,Jb+1,Jb+Z,w+1,Q);" },
		[65] = { cat="operation",  obs=0,   body="h,Jb,Z={[6]=N,[8]=h,[5]=T,[7]=cb},s[z],L(U);Z(c,yb[Jb],yb[Jb+1],yb[Jb+2]);z,T=E[z],Z;" },
		[66] = { cat="operation",  obs=10,  body="yb[s[z]]=yb[j[z]](yb[E[z]]);" },
		[67] = { cat="instr_rw",   obs=32,  body="Jb,Z,w=s[z],E[z],j[z];...instruction rewrite;z-=1;" },
		[68] = { cat="operation",  obs=0,   body="yb[s[z]][yb[j[z]]]=yb[E[z]];" },
		[69] = { cat="operation",  obs=0,   body="yb[E[z]]=yb[s[z]]%j[z];" },
		[70] = { cat="operation",  obs=0,   body="Jb=J[j[z]];Jb[4][Jb[7]]=v[z];" },
		[71] = { cat="instr_rw",   obs=0,   body="Jb,Z,w=E[z],j[z],s[z];...instruction rewrite;z-=1;" },
		[72] = { cat="operation",  obs=0,   body="yb[j[z]]=yb[E[z]]-yb[s[z]];" },
		[73] = { cat="operation",  obs=0,   body="Jb=J[s[z]];Jb[4][Jb[7]][yb[j[z]]]=yb[E[z]];" },
		[74] = { cat="operation",  obs=5,   body="yb[j[z]]=R[z];" },
		[75] = { cat="operation",  obs=0,   body="yb[E[z]]=u(yb[s[z]],yb[j[z]]);" },
	},
	[6] = {
		[0]  = { cat="operation",  obs=11803, body="yb[j[z]]=yb[E[z]];" },
		[1]  = { cat="operation",  obs=0,   body="Jb,Z=E[z],yb[s[z]];yb[Jb+1]=Z;yb[Jb]=Z[Y[z]];" },
		[2]  = { cat="operation",  obs=0,   body="yb[j[z]]=yb[s[z]]==E[z];" },
		[3]  = { cat="operation",  obs=1966,body="yb[s[z]]=E[z];yb[j[z+1]]=yb[E[z+1]];z+=1;" },
		[4]  = { cat="operation",  obs=0,   body="yb[j[z]]=yb[E[z]]*s[z];" },
		[5]  = { cat="operation",  obs=2710,body="yb[j[z]]=a(yb[E[z]],R[z]);" },
		[6]  = { cat="operation",  obs=0,   body="local r=E[z];...M[r]=nil;..." },
		[7]  = { cat="operation",  obs=2976,body="...32-bit multiply (mangled)" },
		[8]  = { cat="operation",  obs=0,   body="yb[E[z]]=yb[j[z]]==yb[s[z]];" },
		[9]  = { cat="operation",  obs=1,   body="yb[E[z]]=j[z]+yb[s[z]];" },
		[10] = { cat="operation",  obs=0,   body="Jb=v[z];...w=c[Jb[Jb[2]]](c,xb,Jb);yb[s[z]]=w;" },
		[11] = { cat="operation",  obs=2780,body="yb[s[z]]=E[z];yb[s[z+1]]=E[z+1];z+=1;" },
		[12] = { cat="operation",  obs=13,  body="yb[j[z]]=yb[E[z]];yb[j[z+1]]=yb[E[z+1]];z+=1;" },
		[13] = { cat="operation",  obs=2,   body="Jb=J[E[z]];yb[j[z]]=Jb[4][Jb[7]][yb[s[z]]];" },
		[14] = { cat="operation",  obs=5334,body="yb[E[z]]=Y[z];" },
		[15] = { cat="instr_rw",   obs=8,   body="Jb,Z,w=s[z],j[z],E[z];...instruction rewrite;z-=1;" },
		[16] = { cat="operation",  obs=1488,body="...32-bit multiply (mangled)" },
		[17] = { cat="return",     obs=0,   body="...return v[z];" },
		[18] = { cat="operation",  obs=0,   body="yb[j[z]]=yb[E[z]]();" },
		[19] = { cat="operation",  obs=62,  body="yb[s[z]]=Y[z]+v[z];" },
		[20] = { cat="operation",  obs=0,   body="yb[E[z]]=c;" },
		[21] = { cat="operation",  obs=0,   body="yb[s[z]]=yb[E[z]]>=j[z];" },
		[22] = { cat="operation",  obs=3,   body="Jb=J[j[z]];yb[E[z]]=Jb[4][Jb[7]];" },
		[23] = { cat="operation",  obs=124, body="yb[E[z]]=yb[s[z]]-yb[j[z]];" },
		[24] = { cat="operation",  obs=0,   body="Jb=J[j[z]];Jb[4][Jb[7]]=yb[s[z]];" },
		[25] = { cat="operation",  obs=0,   body="yb[E[z]](yb[s[z]],Y[z]);" },
		[26] = { cat="operation",  obs=0,   body="yb[E[z]]=c[Y[z]];" },
		[27] = { cat="nop",        obs=11325,body="" },
		[28] = { cat="operation",  obs=434, body="yb[s[z]]=a(Y[z],yb[E[z]]);" },
		[29] = { cat="operation",  obs=3809,body="yb[E[z]]=yb[s[z]]%yb[j[z]];" },
		[30] = { cat="operation",  obs=313, body="yb[j[z]]=not yb[E[z]];" },
		[31] = { cat="operation",  obs=0,   body="Jb=J[j[z]];Jb[4][Jb[7]]=R[z];" },
		[32] = { cat="operation",  obs=52860,body="z=E[z];" },
		[33] = { cat="operation",  obs=0,   body="yb[s[z]]=yb[E[z]]~=j[z];" },
		[34] = { cat="operation",  obs=1612,body="yb[j[z]]=q(yb[s[z]]);" },
		[35] = { cat="operation",  obs=0,   body="yb[s[z]]=yb[E[z]]<j[z];" },
		[36] = { cat="operation",  obs=1,   body="yb[j[z]]=R[z]%yb[E[z]];" },
		[37] = { cat="operation",  obs=5114,body="yb[j[z]]=yb[E[z]];yb[s[z+1]]=E[z+1];z+=1;" },
		[38] = { cat="operation",  obs=0,   body="yb[j[z]]=yb[E[z]]%s[z];" },
		[39] = { cat="operation",  obs=124, body="yb[E[z]]=u(yb[j[z]],s[z]);" },
		[40] = { cat="operation",  obs=38200,body="z=yb[j[z]];" },
		[41] = { cat="operation",  obs=0,   body="yb[j[z]][yb[E[z]]]=s[z];" },
		[42] = { cat="operation",  obs=1,   body="yb[j[z]]=#yb[E[z]];" },
		[43] = { cat="instr_rw",   obs=0,   body="Jb,Z,w=s[z],E[z],j[z];...instruction rewrite;z-=1;" },
		[44] = { cat="operation",  obs=0,   body="z=if yb[E[z]]==j[z]then s[z]else z;" },
		[45] = { cat="operation",  obs=0,   body="yb[s[z]]=yb[j[z]](V(yb[E[z]],1,yb[E[z]][D]));" },
		[46] = { cat="operation",  obs=1,   body="...byte patch loop;j[z],E[z],s[z],I[z]=63,202,158,27;" },
		[47] = { cat="operation",  obs=34383,body="yb[s[z]]=E[z];" },
		[48] = { cat="operation",  obs=0,   body="local r=E[z];yb[r],yb[j[z]]=yb[s[z]]();" },
		[49] = { cat="operation",  obs=3809,body="Jb,Z,w=E[z],j[z],s[z];...H(W,1,w,Jb,yb);" },
		[50] = { cat="operation",  obs=0,   body="yb[j[z]]=yb[s[z]]>=v[z];" },
		[51] = { cat="operation",  obs=248, body="yb[j[z]]=S(v[z],yb[s[z]]);" },
		[52] = { cat="operation",  obs=0,   body="z=if E[z]<yb[s[z]]then j[z]else z;" },
		[53] = { cat="operation",  obs=0,   body="z=if yb[j[z]]<s[z]then E[z]else z;" },
		[54] = { cat="operation",  obs=3810,body="Jb=s[z];Z,w,Q=yb[Jb],yb[Jb+1],yb[Jb+2];yb[Jb]=Z(w,Q);" },
		[55] = { cat="operation",  obs=1,   body="yb[s[z]]={};" },
		[56] = { cat="operation",  obs=62,  body="yb[s[z]]=S(yb[j[z]],yb[E[z]]);" },
		[57] = { cat="operation",  obs=248, body="yb[j[z]]=S(v[z],R[z]);" },
		[58] = { cat="instr_rw",   obs=218, body="Jb,Z,w=E[z],s[z],j[z];...instruction rewrite;z-=1;" },
		[59] = { cat="operation",  obs=12106,body="yb[E[z]]=u(yb[s[z]],yb[j[z]]);" },
		[60] = { cat="operation",  obs=248, body="...32-bit multiply (mangled)" },
		[61] = { cat="operation",  obs=0,   body="yb[E[z]]=-yb[s[z]];" },
		[62] = { cat="instr_rw",   obs=0,   body="Jb,Z,w=E[z],j[z],s[z];...instruction rewrite;z-=1;" },
		[63] = { cat="operation",  obs=28459,body="z=if yb[j[z]]<=s[z]then E[z]else z;" },
		[64] = { cat="operation",  obs=0,   body="yb[s[z]]=yb[j[z]](v[z]);" },
		[65] = { cat="operation",  obs=868, body="yb[E[z]]=yb[j[z]]%4294967296;" },
		[66] = { cat="operation",  obs=310, body="yb[j[z]]=yb[E[z]]>=yb[s[z]];" },
		[67] = { cat="operation",  obs=310, body="yb[j[z]][E[z]]=yb[s[z]];" },
		[68] = { cat="operation",  obs=248, body="yb[s[z]]=a(j[z],yb[E[z]]);" },
		[69] = { cat="operation",  obs=9769,body="yb[E[z]]=a(yb[s[z]],j[z]);" },
		[70] = { cat="operation",  obs=2,   body="yb[s[z]]=yb[E[z]](yb[j[z]]);" },
		[71] = { cat="operation",  obs=0,   body="yb[s[z]]=yb[j[z]]-v[z];" },
		[72] = { cat="operation",  obs=5961,body="yb[s[z]]=yb[j[z]]+E[z];" },
		[73] = { cat="operation",  obs=248, body="yb[j[z]][yb[E[z]]]=yb[s[z]];" },
		[74] = { cat="instr_rw",   obs=0,   body="Jb,Z,w=E[z],s[z],j[z];...instruction rewrite;z-=1;" },
		[75] = { cat="operation",  obs=2,   body="yb[j[z]]=yb[E[z]]-s[z];" },
		[76] = { cat="instr_rw",   obs=40,  body="local r=z;...I[r]=27;" },
		[77] = { cat="mode_switch",obs=6,   body="local r=z;f,z=j[r],E[r]+1;break;" },
		[78] = { cat="operation",  obs=682, body="...32-bit multiply (mangled)" },
		[79] = { cat="operation",  obs=434, body="yb[j[z]]=a(yb[E[z]],yb[s[z]]);" },
		[80] = { cat="operation",  obs=0,   body="yb[s[z]]=yb[E[z]]*Y[z];" },
		[81] = { cat="operation",  obs=0,   body="z=if yb[j[z]]<yb[s[z]]then E[z]else z;" },
		[82] = { cat="return",     obs=5,   body="...return;" },
		[83] = { cat="operation",  obs=930, body="...32-bit multiply (mangled)" },
		[84] = { cat="operation",  obs=62,  body="...32-bit multiply (mangled)" },
		[85] = { cat="operation",  obs=999, body="yb[E[z]]=yb[s[z]][j[z]];" },
		[86] = { cat="operation",  obs=0,   body="yb[s[z]](yb[E[z]]);" },
		[87] = { cat="instr_rw",   obs=0,   body="Jb,Z,w=j[z],E[z],s[z];...instruction rewrite;z-=1;" },
		[88] = { cat="operation",  obs=14358,body="yb[s[z]]=yb[E[z]]+yb[j[z]];" },
		[89] = { cat="operation",  obs=0,   body="yb[j[z]]=yb[E[z]][R[z]];" },
		[90] = { cat="operation",  obs=248, body="yb[s[z]]=S(j[z],yb[E[z]]);" },
		[91] = { cat="operation",  obs=62,  body="yb[s[z]]=E[z]-yb[j[z]];" },
		[92] = { cat="operation",  obs=1,   body="yb[s[z]]();" },
		[93] = { cat="operation",  obs=501, body="yb[j[z]]=yb[s[z]][yb[E[z]]];" },
		[94] = { cat="return",     obs=0,   body="...return yb[j[z]];" },
		[95] = { cat="operation",  obs=0,   body="Jb,Z,w=j[z],s[z],E[z];Q=Jb+Z;yb[Jb]=_(yb[Jb](V(yb,Jb+1,Q)));" },
		[96] = { cat="operation",  obs=373, body="yb[s[z]]=yb[E[z]]<=yb[j[z]];" },
		[97] = { cat="operation",  obs=62,  body="yb[E[z]]=u(yb[j[z]],R[z]);" },
		[98] = { cat="operation",  obs=8142,body="yb[j[z]]=yb[s[z]]<=E[z];" },
		[99] = { cat="operation",  obs=0,   body="yb[j[z]]=yb[s[z]]>E[z];" },
		[100]= { cat="operation",  obs=1966,body="yb[s[z]]=O(yb[E[z]],j[z]);" },
		[101]= { cat="operation",  obs=7622,body="yb[s[z]]=c[E[z]];" },
		[102]= { cat="operation",  obs=62,  body="yb[E[z]]=x(s[z]);" },
		[103]= { cat="operation",  obs=0,   body="yb[E[z]]=yb[j[z]]*yb[s[z]];" },
		[104]= { cat="operation",  obs=62,  body="yb[j[z]]=u(v[z],R[z]);" },
		[105]= { cat="operation",  obs=1904,body="yb[E[z]]=d(yb[j[z]],s[z]);" },
		[106]= { cat="operation",  obs=0,   body="yb[s[z]]=E[z]*yb[j[z]];" },
		[107]= { cat="operation",  obs=0,   body="yb[j[z]](yb[E[z]],yb[s[z]]);" },
		[108]= { cat="operation",  obs=63,  body="Jb,Z,w=j[z],E[z],s[z];Q=yb[Jb];H(yb,Jb+1,Jb+Z,w+1,Q);" },
		[109]= { cat="operation",  obs=14265,body="z=if yb[j[z]]then s[z]else E[z];" },
		[110]= { cat="operation",  obs=0,   body="Jb=J[j[z]];Jb[4][Jb[7]][yb[E[z]]]=s[z];" },
	},
	[56] = {
		[0]  = { cat="operation",  obs=6,   body="yb[E[z]]=yb[s[z]]<=I[z];" },
		[1]  = { cat="operation",  obs=0,   body="Jb=J[E[z]];Jb[4][Jb[7]]=yb[I[z]];" },
		[2]  = { cat="operation",  obs=8,   body="local x=s[z];...M[x]=nil;..." },
		[3]  = { cat="operation",  obs=0,   body="yb[s[z]]=_(yb[I[z]](yb[E[z]]));" },
		[4]  = { cat="operation",  obs=0,   body="...32-bit multiply (mangled)" },
		[5]  = { cat="operation",  obs=0,   body="yb[E[z]]=c;" },
		[6]  = { cat="operation",  obs=0,   body="Jb,Z,w=E[z],s[z],I[z];Q,l,W=Jb+w-1,Jb+Z,_(yb[Jb](V(yb,Jb+1,Jb+Z)));H(W,1,w,Jb,yb);" },
		[7]  = { cat="return",     obs=0,   body="...return V(yb[I[z]],1,yb[I[z]][D]);" },
		[8]  = { cat="operation",  obs=2,   body="Jb,Z,w=s[z],I[z],E[z];Q=yb[Jb];H(yb,Jb+1,Jb+Z,w+1,Q);" },
		[9]  = { cat="operation",  obs=12,  body="yb[E[z]]=yb[I[z]][R[z]];" },
		[10] = { cat="operation",  obs=0,   body="yb[I[z]]=yb[E[z]]>yb[s[z]];" },
		[11] = { cat="operation",  obs=2,   body="yb[E[z]]=c[I[z]];" },
		[12] = { cat="operation",  obs=30,  body="z=if yb[I[z]]<=E[z]then s[z]else z;" },
		[13] = { cat="operation",  obs=0,   body="...32-bit multiply (mangled)" },
		[14] = { cat="operation",  obs=0,   body="yb[E[z]]=_(yb[s[z]](V(yb[I[z]],1,yb[I[z]][D])));" },
		[15] = { cat="operation",  obs=1,   body="yb[I[z]][yb[E[z]]]=yb[s[z]];" },
		[16] = { cat="operation",  obs=0,   body="yb[I[z]]=yb[s[z]]-yb[E[z]];" },
		[17] = { cat="operation",  obs=0,   body="yb[s[z]]=yb[I[z]](yb[E[z]]);" },
		[18] = { cat="operation",  obs=0,   body="yb[I[z]]=v[z]+R[z];" },
		[19] = { cat="operation",  obs=9,   body="yb[s[z]][A[z]]=v[z];" },
		[20] = { cat="operation",  obs=0,   body="Jb,Z,w=E[z],s[z],I[z];Q=Jb+Z;yb[Jb]=_(yb[Jb](V(yb,Jb+1,Q)));" },
		[21] = { cat="operation",  obs=0,   body="h,Jb,Z={[6]=N,[8]=h,[5]=T,[7]=cb},I[z],L(U);Z(c,yb[Jb],yb[Jb+1],yb[Jb+2]);z,T=E[z],Z;" },
		[22] = { cat="operation",  obs=0,   body="yb[E[z]]=q(yb[I[z]]);" },
		[23] = { cat="operation",  obs=0,   body="yb[s[z]]=yb[E[z]][I[z]];" },
		[24] = { cat="operation",  obs=0,   body="yb[I[z]]=yb[E[z]]%4294967296;" },
		[25] = { cat="operation",  obs=0,   body="yb[I[z]]();" },
		[26] = { cat="return",     obs=0,   body="...return yb[I[z]];" },
		[27] = { cat="operation",  obs=0,   body="z=if E[z]<yb[I[z]]then s[z]else z;" },
		[28] = { cat="operation",  obs=0,   body="yb[E[z]]=x(I[z]);" },
		[29] = { cat="return",     obs=0,   body="...return;" },
		[30] = { cat="operation",  obs=0,   body="c[s[z]]=yb[I[z]];" },
		[31] = { cat="operation",  obs=1,   body="c[R[z]]=v[z];" },
		[32] = { cat="instr_rw",   obs=8,   body="Jb,Z,w=I[z],E[z],s[z];...instruction rewrite;z-=1;" },
		[33] = { cat="operation",  obs=28,  body="...byte patch loop;s[z],I[z],E[z],j[z]=251,153,207,72;" },
		[34] = { cat="operation",  obs=1,   body="yb[s[z]](yb[I[z]],v[z]);" },
		[35] = { cat="operation",  obs=0,   body="Jb,Z,w=I[z],E[z],s[z];...G=_(yb[Jb](V(W,1,W[D])));H(G,1,w,Jb,yb);" },
		[36] = { cat="operation",  obs=0,   body="yb[E[z]](yb[s[z]]);yb[s[z+1]]=yb[E[z+1]][I[z+1]];yb[E[z+2]](yb[s[z+2]]);z+=2;" },
		[37] = { cat="operation",  obs=0,   body="yb[E[z]]=I[z]-yb[s[z]];" },
		[38] = { cat="operation",  obs=0,   body="Jb=J[s[z]];yb[E[z]]=Jb[4][Jb[7]];" },
		[39] = { cat="operation",  obs=0,   body="Jb,Z,w=I[z],s[z],E[z];Q,l=yb[Jb],Jb+Z;W=yb[l];H(yb,Jb+1,l-1,w+1,Q);H(W,1,W[D],w+Z,Q);" },
		[40] = { cat="operation",  obs=0,   body="yb[s[z]]=yb[E[z]]<=yb[I[z]];" },
		[41] = { cat="operation",  obs=0,   body="c[v[z]]=yb[I[z]];" },
		[42] = { cat="operation",  obs=0,   body="Jb,Z,w=E[z],s[z],I[z];Q=Jb+Z;l=yb[Q];W=l[D];X=Z+W-1;l[D]=X;H(l,1,W,Z,l);H(yb,Jb+1,Q-1,1,l);yb[Jb]=_(yb[Jb](V(l,1,l[D])));" },
		[43] = { cat="operation",  obs=0,   body="yb[I[z]]=yb[s[z]]>=yb[E[z]];" },
		[44] = { cat="operation",  obs=0,   body="yb[s[z]]=yb[I[z]]%E[z];" },
		[45] = { cat="operation",  obs=0,   body="yb[I[z]][E[z]]=yb[s[z]];" },
		[46] = { cat="instr_rw",   obs=3,   body="Jb,Z,w=s[z],E[z],I[z];...instruction rewrite;z-=1;" },
		[47] = { cat="instr_rw",   obs=0,   body="Jb,Z,w=I[z],s[z],E[z];...instruction rewrite;z-=1;" },
		[48] = { cat="operation",  obs=39,  body="z=yb[s[z]];" },
		[49] = { cat="operation",  obs=43,  body="yb[s[z]]=I[z];" },
		[50] = { cat="operation",  obs=0,   body="T,cb,N,h=h[5],h[7],h[6],h[8];" },
		[51] = { cat="instr_rw",   obs=0,   body="Jb,Z,w=I[z],E[z],s[z];...instruction rewrite;z-=1;" },
		[52] = { cat="return",     obs=5,   body="...return v[z];" },
		[53] = { cat="operation",  obs=5,   body="yb[I[z]]=v[z];" },
		[54] = { cat="operation",  obs=0,   body="...32-bit multiply (mangled)" },
		[55] = { cat="instr_rw",   obs=41,  body="Jb,Z,w=s[z],I[z],E[z];...instruction rewrite;z-=1;" },
		[56] = { cat="operation",  obs=14,  body="yb[s[z]]=I[z];yb[s[z+1]]=I[z+1];z+=1;" },
		[57] = { cat="operation",  obs=0,   body="yb[s[z]]=yb[E[z]][I[z]];yb[E[z+1]](yb[s[z+1]]);yb[s[z+2]]=yb[E[z+2]][I[z+2]];z+=2;" },
		[58] = { cat="operation",  obs=0,   body="yb[s[z]]=yb[I[z]]<E[z];" },
		[59] = { cat="operation",  obs=0,   body="yb[s[z]]=#yb[E[z]];" },
		[60] = { cat="operation",  obs=0,   body="Jb,Z,w,Q=s[z],T();if Z then yb[Jb+1]=w;yb[Jb+2]=Q;z=E[z];end;" },
		[61] = { cat="operation",  obs=5,   body="yb[E[z]](yb[s[z]]);" },
		[62] = { cat="operation",  obs=14,  body="yb[s[z]]=Fb[A[z]];" },
		[63] = { cat="operation",  obs=0,   body="yb[s[z]]=yb[I[z]]+yb[E[z]];" },
		[64] = { cat="operation",  obs=0,   body="yb[I[z]](yb[s[z]],yb[E[z]]);" },
		[65] = { cat="operation",  obs=0,   body="yb[E[z]]=yb[s[z]]();" },
		[66] = { cat="return",     obs=0,   body="...return yb[s[z]],yb[I[z]];" },
		[67] = { cat="instr_rw",   obs=0,   body="Jb,Z,w=E[z],I[z],s[z];...instruction rewrite;z-=1;" },
		[68] = { cat="operation",  obs=2,   body="yb[s[z]]=yb[I[z]][yb[E[z]]];" },
		[69] = { cat="instr_rw",   obs=14,  body="Jb=s[z]+1;...j[z]=72;" },
		[70] = { cat="operation",  obs=0,   body="yb[I[z]][E[z]]=s[z];" },
		[71] = { cat="operation",  obs=0,   body="yb[I[z]][v[z]]=yb[s[z]];" },
		[72] = { cat="nop",        obs=426, body="" },
		[73] = { cat="operation",  obs=0,   body="yb[E[z]]=c[R[z]];" },
		[74] = { cat="operation",  obs=0,   body="yb[I[z]]=R[z]%4294967296;" },
		[75] = { cat="operation",  obs=0,   body="yb[E[z]][I[z]]=R[z];" },
		[76] = { cat="operation",  obs=0,   body="yb[s[z]]=not yb[I[z]];" },
		[77] = { cat="operation",  obs=0,   body="...32-bit multiply (mangled)" },
		[78] = { cat="operation",  obs=0,   body="yb[I[z]]=a(yb[s[z]],yb[E[z]]);" },
		[79] = { cat="operation",  obs=0,   body="yb[I[z]]=yb[s[z]]+E[z];" },
		[80] = { cat="operation",  obs=0,   body="yb[I[z]]=yb;" },
		[81] = { cat="operation",  obs=0,   body="yb[s[z]]=yb[I[z]](v[z]);" },
		[82] = { cat="operation",  obs=0,   body="yb[E[z]](yb[s[z]]);yb[s[z+1]]=yb[E[z+1]][I[z+1]];yb[E[z+2]](yb[s[z+2]]);yb[s[z+3]]=yb[E[z+3]][I[z+3]];z+=3;" },
		[83] = { cat="operation",  obs=0,   body="yb[I[z]]=u(yb[s[z]],yb[E[z]]);" },
		[84] = { cat="operation",  obs=0,   body="yb[s[z]]=I[z]*yb[E[z]];" },
		[85] = { cat="operation",  obs=1,   body="Jb=I[z];Z,w,Q=yb[Jb],yb[Jb+1],yb[Jb+2];yb[Jb]=Z(w,Q);" },
		[86] = { cat="operation",  obs=0,   body="Jb,Z=E[z],yb[s[z]];yb[Jb+1]=Z;yb[Jb]=Z[A[z]];" },
		[87] = { cat="operation",  obs=10,  body="z=if yb[I[z]]then s[z]else E[z];" },
		[88] = { cat="operation",  obs=7,   body="yb[E[z]]={};" },
		[89] = { cat="operation",  obs=26,  body="yb[E[z]]=yb[s[z]];" },
		[90] = { cat="operation",  obs=10,  body="Jb=R[z];...M,Z=d,a;" },
		[91] = { cat="operation",  obs=0,   body="yb[I[z]]=yb[s[z]]~=v[z];" },
		[92] = { cat="operation",  obs=1,   body="yb[I[z]][v[z]]=s[z];" },
		[93] = { cat="operation",  obs=56,  body="z=s[z];" },
	},
}

--=====================================================================
-- 4d.  SETTINGS + AUTODETECT
--=====================================================================

local DEFAULT_SETTINGS = {
	Name = "Luraph15.1:default",
	ConstantsOffset = 231,
	PrototypesOffset = 14954,
	InstructionsOffset = 58516,
	DispatchMode = 1,
	FloatTag = 87,
	StringTag = 216,
	IntegerTag = nil,
	ProtoFormat = 1,
	TwoChunk = false,
	BootstrapSkipBytes = 0,
	DecryptStrings = false,
	CharTableInitState = 0,
	CharTableXorMask = 127,
	LcgMultiplier = 65,
	LcgIncrement = 117,
	ApplyConstantTransforms = false,
	OperandModes = {
		[0] = "constant", [1] = "rel_fwd",
		[2] = "closure",  [4] = "rel_bwd",
		[7] = "register",
	},
}

-- Profiles to try during autodetect.
local AUTODETECT_PROFILES = {
	{
		Name = "Sample2", ConstantsOffset = 25087, PrototypesOffset = 80260,
		InstructionsOffset = 94134, DispatchMode = 2,
		FloatTag = nil, StringTag = 13, IntegerTag = 199,
		ProtoFormat = 2, TwoChunk = true, BootstrapSkipBytes = 101,
		DecryptStrings = true, CharTableInitState = 0, CharTableXorMask = 127,
		LcgMultiplier = 65, LcgIncrement = 117, ApplyConstantTransforms = true,
		OperandModes = {
			[6]="register",[5]="constant",[0]="resolved_const",
			[1]="rel_bwd",[2]="rel_fwd",[7]="proto_index",
		},
	},
	{
		Name = "Sample1", ConstantsOffset = 231, PrototypesOffset = 14954,
		InstructionsOffset = 58516, DispatchMode = 1,
		FloatTag = 87, StringTag = 216, IntegerTag = nil,
		ProtoFormat = 3, TwoChunk = false, BootstrapSkipBytes = 0,
		OperandModes = {
			[0]="constant",[1]="rel_fwd",[2]="closure",
			[4]="rel_bwd",[7]="register",
		},
	},
}

local function cloneTable(t)
	local r = {}
	for k, v in pairs(t) do
		r[k] = type(v) == "table" and cloneTable(v) or v
	end
	return r
end

--=====================================================================
-- 4e.  LURAPH DESERIALIZER
--=====================================================================

function Luraph.deserialize(blob, settings)
	settings = settings or DEFAULT_SETTINGS
	local data = Luraph.Decoder.base85(blob)
	if not data then return nil, "base85 decode failed" end
	local R = Luraph.Decoder.makeReader(data)

	local function readConstants()
		local rawCount = R.varint()
		local count = rawCount - settings.ConstantsOffset
		if count < 0 or count > 500000 then
			return nil, "invalid constant count: " .. count
		end
		local isCached = R.byte() ~= 0
		local constants = {}
		for i = 1, count do
			local tag = R.byte()
			local datatype
			if settings.DispatchMode == 1 then
				if tag == settings.FloatTag then datatype = "number"
				elseif tag < settings.FloatTag then datatype = "boolean"
				elseif tag == settings.StringTag then datatype = "string"
				else datatype = "integer" end
			elseif settings.DispatchMode == 2 then
				if tag <= settings.StringTag then
					datatype = (tag == settings.StringTag) and "string" or "number"
				else
					datatype = (tag == settings.IntegerTag) and "integer" or "boolean"
				end
			else
				if tag == settings.StringTag then datatype = "string"
				elseif settings.FloatTag and tag == settings.FloatTag then datatype = "number"
				elseif settings.IntegerTag and tag == settings.IntegerTag then datatype = "integer"
				else datatype = "boolean" end
			end

			local entry = { type = datatype }
			if datatype == "number" then
				local n = R.float64()
				if settings.ApplyConstantTransforms and n ~= 0 then n = -n end
				entry.value = n
			elseif datatype == "boolean" then
				local b = R.byte() == 1
				if settings.ApplyConstantTransforms then b = not b end
				entry.value = b
			elseif datatype == "string" then
				local raw = R.rawBytes()
				entry.raw = raw
				if settings.DecryptStrings then
					entry.value = Luraph.Decoder.decryptString(raw, settings)
				else
					entry.value = raw
				end
			elseif datatype == "integer" then
				entry.value = R.int64()
			end
			constants[i] = entry
		end
		return constants, isCached
	end

	local ok, constantsOrErr = pcall(readConstants)
	if not ok then return nil, tostring(constantsOrErr) end
	local constants = constantsOrErr
	if not constants then return nil, "constant read failed" end

	local function readProto()
		local proto = { opcodes = {}, raw = {} }
		local metadataCount = R.varint()
		for _ = 1, metadataCount do R.varint() end
		local rawInstr = R.varint()
		local instrCount = rawInstr - settings.InstructionsOffset
		if instrCount < 0 then instrCount = 0 end
		if instrCount > 1000000 then return nil, "too many instructions" end
		proto.instructionCount = instrCount
		for idx = 1, instrCount do
			local rawC = R.varint()
			local rawA = R.varint()
			local rawB = R.varint()
			local opcode = R.varint()
			proto.opcodes[idx] = opcode
			proto.raw[idx] = { A = rawA, B = rawB, C = rawC }
		end
		proto.stackSize = R.varint()
		local lineEntryCount = R.uint32()
		for _ = 1, lineEntryCount do
			local raw = R.uint32()
			if raw % 2 == 0 then
				-- single
			else
				R.uint32(); R.uint32()
			end
		end
		proto.numParams = R.varint()
		return proto
	end

	local rawProtoCount = R.varint()
	local protoCount = rawProtoCount - settings.PrototypesOffset
	if protoCount < 0 or protoCount > 100000 then
		return nil, "invalid proto count: " .. tostring(protoCount)
	end

	local protos = {}
	for i = 1, protoCount do
		local ok2, p = pcall(readProto)
		if not ok2 or not p then break end
		p.name = "P" .. i
		protos[i] = p
	end

	local rawEntryIndex = R.varint()
	local entryIndex = rawEntryIndex - 1

	return {
		constants = constants,
		prototypes = protos,
		entryIndex = entryIndex,
		entryProto = protos[entryIndex + 1],
		settings = settings,
	}
end

-- Score a candidate chunk to pick the best autodetect result.
local function scoreChunk(chunk)
	if not chunk or not chunk.prototypes or #chunk.prototypes == 0 then
		return -math.huge
	end
	local score = 0
	if chunk.entryProto then score = score + 80 end
	if #chunk.prototypes > 0 then score = score + math.min(#chunk.prototypes * 3, 180) end
	if #chunk.constants > 0 then score = score + math.min(#chunk.constants / 2, 180) end
	local totalInstr = 0
	local opcodeSet = {}
	for _, p in ipairs(chunk.prototypes) do
		if p.instructionCount <= 0 or p.instructionCount > 200000 then
			return -math.huge
		end
		totalInstr = totalInstr + p.instructionCount
		for i = 1, math.min(p.instructionCount, #p.opcodes) do
			opcodeSet[p.opcodes[i]] = true
		end
	end
	score = score + math.min(math.floor(totalInstr / 8), 220)
	local opCount = 0
	for _ in pairs(opcodeSet) do opCount = opCount + 1 end
	score = score + math.min(opCount * 4, 220)
	local strings, printableStrings = 0, 0
	for _, c in ipairs(chunk.constants) do
		if c.type == "string" and type(c.value) == "string" then
			strings = strings + 1
			local printable = 0
			for i = 1, #c.value do
				local b = string.byte(c.value, i)
				if b == 9 or b == 10 or b == 13 or (b >= 32 and b <= 126) then
					printable = printable + 1
				end
			end
			if #c.value == 0 or printable >= (#c.value * 6 // 10) then
				printableStrings = printableStrings + 1
			end
		end
	end
	if strings > 0 then
		score = score + math.min(strings * 2, 80)
		if printableStrings * 2 >= strings then score = score + 40 end
	end
	return score
end

function Luraph.autoDetect(blob)
	if not CONFIG.TryAutoDetect then return nil end
	local profiles = {}
	profiles[#profiles + 1] = DEFAULT_SETTINGS
	for _, p in ipairs(AUTODETECT_PROFILES) do
		local merged = cloneTable(DEFAULT_SETTINGS)
		for k, v in pairs(p) do merged[k] = v end
		profiles[#profiles + 1] = merged
	end

	local best, bestScore = nil, -math.huge
	for _, profile in ipairs(profiles) do
		local ok, chunk = pcall(Luraph.deserialize, blob, profile)
		if ok and chunk then
			local score = scoreChunk(chunk)
			if score > bestScore then
				best, bestScore = chunk, score
				log("autodetect: profile '%s' score=%d", tostring(profile.Name), score)
			end
		end
	end
	return best
end

--=====================================================================
-- 4f.  LIFTER  (opcode -> readable operations)
--=====================================================================

function Luraph.lift(chunk)
	if not chunk then return "" end
	local out = {}
	out[#out + 1] = "-- Luraph 15.1 lifted bytecode"
	out[#out + 1] = string.format("-- protos=%d constants=%d",
		#chunk.prototypes, #chunk.constants)

	out[#out + 1] = "\n-- CONSTANTS --"
	for i, c in ipairs(chunk.constants) do
		if i > 400 then
			out[#out + 1] = "-- ... (" .. (#chunk.constants - 400) .. " more)"
			break
		end
		local repr
		if c.type == "string" then
			repr = string.format("%q", (#c.value > 120) and (c.value:sub(1, 117) .. "...") or (c.value or ""))
		else
			repr = tostring(c.value)
		end
		out[#out + 1] = string.format("-- C[%03d] %s  %s", i, c.type, repr)
	end

	for pi, proto in ipairs(chunk.prototypes) do
		out[#out + 1] = string.format("\n-- PROTO P%d (instrs=%d, stack=%s, params=%s) --",
			pi, proto.instructionCount, tostring(proto.stackSize), tostring(proto.numParams))
		for idx = 1, math.min(proto.instructionCount, 500) do
			local op = proto.opcodes[idx]
			local r = proto.raw[idx] or {}
			local handler = nil
			for _, mode in pairs({ 229, 12, 6, 56 }) do
				if Luraph.OpcodeTable[mode] and Luraph.OpcodeTable[mode][op] then
					handler = Luraph.OpcodeTable[mode][op]
					break
				end
			end
			if handler then
				out[#out + 1] = string.format("[%04d] OP_%03d (%-10s) A=%s B=%s C=%s  -- %s",
					idx, op, handler.cat,
					tostring(r.A), tostring(r.B), tostring(r.C),
					handler.body)
			else
				out[#out + 1] = string.format("[%04d] OP_%03d (?) A=%s B=%s C=%s",
					idx, op, tostring(r.A), tostring(r.B), tostring(r.C))
			end
		end
		if proto.instructionCount > 500 then
			out[#out + 1] = string.format("-- ... (%d more instructions)", proto.instructionCount - 500)
		end
	end

	return table.concat(out, "\n")
end

--=====================================================================
-- 4g.  ANTI-SOURCE STRIPPING
--=====================================================================

-- Patterns commonly left in decoded Luraph output that we can strip.
Luraph.antiSourcePatterns = {
	{ pat = "if%s+LPH_OBFUSCATED%s*==%s*nil%s*then", repl = "--[[anti-luraph stub removed]] if false then" },
	{ pat = "LPH_CRASH%s*=%s*function%b()", repl = "LPH_CRASH = function() end" },
	{ pat = "debug%.traceback%b()", repl = "--[[anti-trace removed]]" },
	{ pat = "getfenv%s*%(%s*select%s*%(%s*%d+%s*,%s*%.%.%.%s*%)%s*%)", repl = "getfenv()" },
	{ pat = "checkcaller%b()", repl = "false" },
	{ pat = "game:GetService%b()%.LocalPlayer:Kick%b()", repl = "return" },
	{ pat = "error%s*%(%s*\"[^\"]*tamper[^\"]*\"%s*%)", repl = "return" },
	{ pat = "error%s*%(%s*'[^']*tamper[^']*'%s*%)", repl = "return" },
}

function Luraph.stripAntiSource(src)
	if not CONFIG.StripAfterDecode or type(src) ~= "string" then return src end
	local out = src
	for _, rule in ipairs(Luraph.antiSourcePatterns) do
		local ok, res = pcall(function() return (out:gsub(rule.pat, rule.repl)) end)
		if ok and res then out = res end
	end
	return out
end

--=====================================================================
-- 4h.  SCAN + INSTALL
--=====================================================================

local function looksLikeDispatch(t)
	if type(t) ~= "table" then return false end
	local fnCount, max = 0, 0
	for k, v in pairs(t) do
		if type(k) == "number" and k >= 1 and k == math.floor(k) then
			if type(v) == "function" then fnCount = fnCount + 1 end
			if k > max then max = k end
		end
	end
	return fnCount >= 16 and fnCount >= max * 0.85
end

function Luraph.scan(fn)
	if not CONFIG.LuraphMode or type(fn) ~= "function" then return end
	local seen = {}
	local function walk(f, depth)
		if type(f) ~= "function" or seen[f] or depth > CONFIG.MaxProtoDepth then return end
		seen[f] = true
		local ups = safeDebug("getupvalues", f)
		if type(ups) == "table" then
			for i, u in ipairs(ups) do
				if not Luraph.dispatch and looksLikeDispatch(u) then
					Luraph.dispatch = u
					log("Luraph dispatch table found (upvalue %d, %d handlers)", i, #u)
				end
			end
		end
		local consts = safeDebug("getconstants", f)
		if type(consts) == "table" then
			for i, c in ipairs(consts) do
				if not Luraph.dispatch and looksLikeDispatch(c) then
					Luraph.dispatch = c
					log("Luraph dispatch found (constant %d)", i)
				end
			end
		end
		local protos = safeDebug("getprotos", f)
		if type(protos) == "table" then
			for _, p in ipairs(protos) do walk(p, depth + 1) end
		end
	end
	walk(fn, 0)
end

function Luraph.installMacrosInto(env)
	if type(env) ~= "table" then return end
	Luraph.Macros.applyTo(env)
end

--=====================================================================
-- 5.  POLSEC BYPASS
--=====================================================================

local PolSec = { active = false, kicksBlocked = 0, warnsFiltered = 0 }

local function computeDJB2(s)
	local h = 5381
	for i = 1, #s do
		h = bit32.band(h * 33 + string.byte(s, i), 4294967295)
	end
	return h
end
do
	local expected = computeDJB2("BzIs_vYBaEohYSz")
	log("PolSec sentinel hash = %d (target %d)", expected, CONFIG.PolSecHash)
end

local function installPolSecTracebackGuard()
	local dbg = debug
	if not dbg or type(dbg.traceback) ~= "function" then return end
	local real = dbg.traceback
	local wrapper = function(msg, level)
		local r = real(msg, level)
		if type(r) == "string" then
			r = r:gsub("\n[^\n]*luau_dumps[^\n]*", "")
			r = r:gsub("\n[^\n]*dumper[^\n]*", "")
		end
		return r
	end
	installGlobal("traceback", wrapper, real)
end

local function installPolSecInfoGuard()
	local dbg = debug
	if not dbg or type(dbg.info) ~= "function" then return end
	local real = dbg.info
	local wrapper = function(level, what)
		local r = real(level, what)
		if type(r) == "number" and type(what) == "string" and what:find("l") then
			return 1
		end
		return r
	end
	installGlobal("info", wrapper, real)
end

local function installKickNeutralizer()
	if not CONFIG.NeutralizeKick then return end
	local Players = game and game:FindService("Players")
	if not Players then return end
	local LocalPlayer = Players.LocalPlayer
	if not LocalPlayer then return end
	local mt = EXEC.getrawmetatable and EXEC.getrawmetatable(LocalPlayer)
	if mt and EXEC.hookmetamethod then
		local ok = pcall(EXEC.hookmetamethod, LocalPlayer, "__index", function(t, k)
			if k == "Kick" then
				return function()
					PolSec.kicksBlocked = PolSec.kicksBlocked + 1
					log("blocked Kick() #%d", PolSec.kicksBlocked)
				end
			end
		end)
		if ok then log("Kick neutralizer installed") end
	end
end

local function installWarnFilter()
	local genv = EXEC.getgenv()
	if not genv or type(genv.warn) ~= "function" then return end
	local real = genv.warn
	local wrapper = function(...)
		local first = tostring((...))
		if first:find("PolSec") or first:find("tamper") or first:find("Tamper") then
			PolSec.warnsFiltered = PolSec.warnsFiltered + 1
			return
		end
		return real(...)
	end
	installGlobal("warn", wrapper, real)
end

local function installCoreGuiNeutralizer()
	local CoreGui = game and game:FindService("CoreGui")
	if not CoreGui then return end
	if EXEC.hookmetamethod then
		pcall(EXEC.hookmetamethod, CoreGui, "__namecall", function(self, ...)
			local method = EXEC.getnamecallmethod and EXEC.getnamecallmethod()
			if method == "FindFirstChild" or method == "WaitForChild" then
				local name = (...)
				if name == "RobloxPromptGui" then return nil end
			end
		end)
	end
end

function PolSec.install()
	if PolSec.active or not CONFIG.PolSecBypass then return end
	installPolSecTracebackGuard()
	installPolSecInfoGuard()
	installKickNeutralizer()
	installWarnFilter()
	installCoreGuiNeutralizer()
	PolSec.active = true
	log("PolSec bypass active")
end

--=====================================================================
-- 6.  LUARMOR BYPASS
--=====================================================================

local Luarmor = {
	active = false, loaderURL = nil, rawLoader = nil,
	payloadURL = nil, rawPayload = nil,
	runtimeVars = {}, httpCalls = {},
}

local function installCheckcallerBypass()
	if not CONFIG.BypassCheckcaller or not EXEC.checkcaller then return end
	local real = EXEC.checkcaller
	installGlobal("checkcaller", function() return false end, real)
	log("checkcaller bypassed")
end

local function installGetgenvHarvest()
	local genv = EXEC.getgenv()
	if not genv or type(genv.getgenv) ~= "function" then return end
	local real = genv.getgenv
	local wrapper = function()
		local env = real()
		if CONFIG.CaptureLRMVars and type(env) == "table" then
			for k, v in pairs(env) do
				if type(k) == "string" and k:match("^LRM_") then
					Luarmor.runtimeVars[k] = v
				end
			end
		end
		return env
	end
	installGlobal("getgenv", wrapper, real)
end

local function installHttpGetCapture()
	if not CONFIG.CaptureHttpGet then return end
	if EXEC.request then
		local real = EXEC.request
		local wrapper = function(options)
			local result = real(options)
			local url = type(options) == "table" and options.Url or tostring(options)
			Luarmor.httpCalls[#Luarmor.httpCalls + 1] = { url = url, result = result }
			if type(url) == "string" then
				if url:lower():find("luarmor") and not Luarmor.loaderURL then
					Luarmor.loaderURL = url
					if CONFIG.SaveRawLoader and type(result) == "table" and result.Body then
						Luarmor.rawLoader = result.Body
					end
				end
				if url:lower():find("api%.luarmor%.net/files") then
					Luarmor.payloadURL = url
					if CONFIG.SaveRawLoader and type(result) == "table" and result.Body then
						Luarmor.rawPayload = result.Body
					end
				end
			end
			return result
		end
		installGlobal("request", wrapper, real)
	end
	if game and game.HttpGet then
		local real = game.HttpGet
		local wrapper = function(self, url, ...)
			local result = real(self, url, ...)
			if type(url) == "string" then
				Luarmor.httpCalls[#Luarmor.httpCalls + 1] = { url = url, result = result }
				if url:lower():find("luarmor") and not Luarmor.loaderURL then
					Luarmor.loaderURL = url; Luarmor.rawLoader = result
				end
				if url:lower():find("api%.luarmor%.net/files") then
					Luarmor.payloadURL = url; Luarmor.rawPayload = result
				end
			end
			return result
		end
		pcall(function() game.HttpGet = wrapper end)
	end
end

function Luarmor.install()
	if Luarmor.active or not CONFIG.LuarmorMode then return end
	installCheckcallerBypass()
	installGetgenvHarvest()
	installHttpGetCapture()
	Luarmor.active = true
	log("Luarmor bypass active")
end

--=====================================================================
-- 7.  STRING SCORING + DECRYPTION
--=====================================================================

local SOURCE_HINTS = {
	"local ","function","return","end","then","else","elseif","for ",
	"while ","repeat","until","do ","if ","nil","true","false","self",
	"break","goto","::","and ","or ","not ","pcall","loadstring",
	"getfenv","setfenv","require","#!","continue","type(","typeof(",
	"task.","wait(",
}

local function scoreSource(s)
	if type(s) ~= "string" then return 0 end
	if #s < 6 or #s > CONFIG.MaxStringLen then return 0 end
	local total = math.min(#s, 8192)
	local printable = 0
	for i = 1, total do
		local b = string.byte(s, i)
		if b == 9 or b == 10 or b == 13 or (b >= 32 and b < 127) then
			printable = printable + 1
		end
	end
	if printable / total < 0.85 then return 0 end
	local score = 0
	for _, hint in ipairs(SOURCE_HINTS) do
		local _, n = string.gsub(s, hint, "")
		score = score + n * 3
	end
	local _, ends   = string.gsub(s, "%f[%w]end%f[%W]", "")
	local _, locals = string.gsub(s, "%f[%w]local%f[%W]", "")
	local _, funcs  = string.gsub(s, "%f[%w]function%f[%W]", "")
	score = score + ends * 2 + locals * 2 + funcs * 4
	local _, lines = string.gsub(s, "\n", "")
	if lines > 3 then score = score + lines end
	if s:match("^[%x]+$") and #s > 32 then score = score - 50 end
	if s:match("^[A-Za-z0-9+/=]+$") and #s > 64 then score = score - 40 end
	return score
end

local Decrypt = {}

local function xorString(data, key)
	local out = table.create(#data)
	local klen = #key
	if klen == 0 then return data end
	for i = 1, #data do
		local k = string.byte(key, ((i - 1) % klen) + 1)
		out[i] = string.char(bit32.bxor(string.byte(data, i), k))
	end
	return table.concat(out)
end

local function frequencyScore(s)
	local good, total = 0, math.min(#s, 2048)
	if total == 0 then return 0 end
	for i = 1, total do
		local b = string.byte(s, i)
		if (b >= 97 and b <= 122) or (b >= 65 and b <= 90)
			or (b >= 48 and b <= 57)
			or b == 32 or b == 9 or b == 10 or b == 13
			or b == 46 or b == 44 or b == 40 or b == 41
			or b == 91 or b == 93 or b == 123 or b == 125
			or b == 95 or b == 34 or b == 39 or b == 61
		then good = good + 1 end
	end
	return (good / total) * 100
end

function Decrypt.xorSingle(data)
	local best, bestScore, bestKey = nil, 0, nil
	for k = 1, 255 do
		local cand = xorString(data, string.char(k))
		local sc = scoreSource(cand)
		if sc == 0 then sc = frequencyScore(cand) end
		if sc > bestScore then best, bestScore, bestKey = cand, sc, k end
	end
	return best, bestScore, bestKey
end

function Decrypt.xorRepeating(data)
	local n = #data
	if n < 8 then return nil end
	local maxLen = math.min(CONFIG.MaxKeyLength, n // 4)
	local bestLen, bestIC = 1, 0
	for kl = 2, maxLen do
		local matches, total = 0, 0
		for i = 1, n - kl do
			if string.byte(data, i) == string.byte(data, i + kl) then
				matches = matches + 1
			end
			total = total + 1
		end
		local ic = total > 0 and (matches / total) or 0
		if ic > bestIC then bestIC, bestLen = ic, kl end
	end
	if bestIC < 0.04 then return nil end
	local keyBytes = {}
	for pos = 1, bestLen do
		local bestByte, bestScore = 0, -1
		for k = 0, 255 do
			local good = 0
			for i = pos, n, bestLen do
				local b = bit32.bxor(string.byte(data, i), k)
				if (b >= 32 and b < 127) or b == 9 or b == 10 or b == 13 then
					good = good + 1
				end
			end
			if good > bestScore then bestScore, bestByte = good, k end
		end
		keyBytes[pos] = string.char(bestByte)
	end
	local key = table.concat(keyBytes)
	local decoded = xorString(data, key)
	return decoded, scoreSource(decoded), key
end

local B64_LOOKUP = {}
do
	local alpha = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	for i = 1, #alpha do B64_LOOKUP[string.byte(alpha, i)] = i - 1 end
	B64_LOOKUP[string.byte("-")] = 62
	B64_LOOKUP[string.byte("_")] = 63
end

function Decrypt.base64(data)
	data = data:gsub("%s+", "")
	local out, buf, bits = {}, 0, 0
	for i = 1, #data do
		local c = string.byte(data, i)
		if c == 61 then break end
		local v = B64_LOOKUP[c]
		if v then
			buf = bit32.bor(bit32.lshift(buf, 6), v)
			bits = bits + 6
			if bits >= 8 then
				bits = bits - 8
				out[#out + 1] = string.char(bit32.band(bit32.rshift(buf, bits), 0xFF))
			end
		end
	end
	local decoded = table.concat(out)
	return decoded, scoreSource(decoded)
end

function Decrypt.hex(data)
	local cleaned = data:gsub("0x", ""):gsub("\\x", ""):gsub("%s+", "")
	if #cleaned % 2 ~= 0 or not cleaned:match("^%x+$") then return nil end
	local out = {}
	for i = 1, #cleaned, 2 do
		out[#out + 1] = string.char(tonumber(cleaned:sub(i, i + 1), 16))
	end
	local decoded = table.concat(out)
	return decoded, scoreSource(decoded)
end

function Decrypt.rot(data)
	local best, bestScore, bestN = nil, 0, 0
	for n = 1, 25 do
		local out = {}
		for i = 1, #data do
			local b = string.byte(data, i)
			if b >= 65 and b <= 90 then
				out[i] = string.char(((b - 65 + n) % 26) + 65)
			elseif b >= 97 and b <= 122 then
				out[i] = string.char(((b - 97 + n) % 26) + 97)
			else out[i] = string.char(b) end
		end
		local cand = table.concat(out)
		local sc = scoreSource(cand)
		if sc > bestScore then best, bestScore, bestN = cand, sc, n end
	end
	return best, bestScore, bestN
end

local function rc4(data, key)
	local S = {}
	for i = 0, 255 do S[i] = i end
	local j = 0
	for i = 0, 255 do
		j = (j + S[i] + string.byte(key, (i % #key) + 1)) % 256
		S[i], S[j] = S[j], S[i]
	end
	local out = {}
	local i, jj = 0, 0
	for n = 1, #data do
		i = (i + 1) % 256
		jj = (jj + S[i]) % 256
		S[i], S[jj] = S[jj], S[i]
		local k = S[(S[i] + S[jj]) % 256]
		out[n] = string.char(bit32.bxor(string.byte(data, n), k))
	end
	return table.concat(out)
end

function Decrypt.rc4(data)
	local keys = { "luarmor", "Luarmor", "LRM", "key", "0", "1" }
	local best, bestScore = nil, 0
	for _, k in ipairs(keys) do
		local cand = rc4(data, k)
		local sc = scoreSource(cand)
		if sc > bestScore then best, bestScore = cand, sc end
	end
	if bestScore >= CONFIG.MinDecryptScore then return best, bestScore, "rc4" end
	return nil
end

-- Try Luraph string decrypt with several key configs
function Decrypt.luraphString(raw)
	local best, bestScore = nil, 0
	for _, init in ipairs({ 0, 185, 22, 74 }) do
		for _, mask in ipairs({ 127, 255, 85, 63 }) do
			for _, a in ipairs({ 65, 17, 33, 97 }) do
				for _, c in ipairs({ 117, 43, 79, 201 }) do
					local settings = {
						CharTableInitState = init, CharTableXorMask = mask,
						LcgMultiplier = a, LcgIncrement = c,
					}
					local r = Luraph.Decoder.decryptString(raw, settings)
					local sc = scoreSource(r)
					if sc > bestScore then best, bestScore = r, sc end
				end
			end
		end
	end
	if bestScore >= CONFIG.MinDecryptScore then return best, bestScore, "lph_string" end
	return nil
end

function Decrypt.crack(data)
	local best, bestScore, bestMethod = nil, 0, nil
	local function consider(r, s, m)
		if r and s and s > bestScore then best, bestScore, bestMethod = r, s, m end
	end
	if CONFIG.TryBase64 then local r, s = Decrypt.base64(data); consider(r, s, "base64") end
	if CONFIG.TryHex    then local r, s = Decrypt.hex(data);    consider(r, s, "hex") end
	if CONFIG.TryXorSingle then local r, s, k = Decrypt.xorSingle(data); consider(r, s, "xor1:" .. tostring(k)) end
	if CONFIG.TryXorRepeating then local r, s, k = Decrypt.xorRepeating(data); consider(r, s, "xorR:" .. tostring(k)) end
	if CONFIG.TryRot    then local r, s, n = Decrypt.rot(data); consider(r, s, "rot" .. tostring(n)) end
	if CONFIG.TryRC4    then local r, s, m = Decrypt.rc4(data); consider(r, s, m) end
	if CONFIG.TryLPHString and #data > 4 then
		local r, s, m = Decrypt.luraphString(data); consider(r, s, m)
	end
	if bestScore >= CONFIG.MinDecryptScore then return best, bestScore, bestMethod end
	return nil
end

--=====================================================================
-- 8.  STRING TABLE
--=====================================================================

local Strings = { seen = {}, items = {}, count = 0 }

function Strings.add(value, origin)
	if type(value) ~= "string" then return end
	if #value < 3 or #value > CONFIG.MaxStringLen then return end
	if Strings.seen[value] then return end
	Strings.seen[value] = true
	Strings.count = Strings.count + 1
	local score = scoreSource(value)
	local item = {
		value = value, score = score, origin = origin or "unknown",
		decoded = nil, decodedScore = nil, method = nil,
	}
	if score < CONFIG.MinDecryptScore and #value >= 6 then
		local dec, dscore, method = Decrypt.crack(value)
		if dec then
			item.decoded = dec; item.decodedScore = dscore; item.method = method
			Strings.add(dec, "decrypted:" .. method)
		end
	end
	Strings.items[#Strings.items + 1] = item
end

function Strings.sorted()
	local copy = table.clone(Strings.items)
	table.sort(copy, function(a, b)
		local sa = math.max(a.score, a.decodedScore or 0)
		local sb = math.max(b.score, b.decodedScore or 0)
		if sa ~= sb then return sa > sb end
		return #a.value > #b.value
	end)
	return copy
end

function Strings.bestSource()
	for _, item in ipairs(Strings.sorted()) do
		if item.score >= 40 then return item end
		if item.decoded and item.decodedScore and item.decodedScore >= 40 then
			return { value = item.decoded, score = item.decodedScore,
			         origin = "decrypted:" .. tostring(item.method) }
		end
	end
	return nil
end

--=====================================================================
-- 9.  CAPTURES
--=====================================================================

local Captures = { chunks = {}, bytecode = {}, charCalls = {}, luraphBlobs = {}, order = 0 }
local Calls    = { entries = {}, count = 0 }
local Globals  = { reads = {}, writes = {} }

--=====================================================================
-- 10.  OUTPUT
--=====================================================================

local Output = {}

local function ensureFolder(path)
	if EXEC.isfolder and EXEC.isfolder(path) then return true end
	if EXEC.makefolder then return pcall(EXEC.makefolder, path) end
	return false
end

function Output.write(path, contents)
	if EXEC.writefile then
		local ok, err = pcall(EXEC.writefile, path, contents)
		if ok then log("wrote %d bytes -> %s", #contents, path); return true end
		warn_("writefile failed: %s", tostring(err))
		return false
	end
	print("===== DUMP BEGIN (" .. path .. ") =====")
	print(contents)
	print("===== DUMP END =====")
	return false
end

--=====================================================================
-- 11.  GLOBAL TRACING + CALL TRACING
--=====================================================================

local function recordRead(k)
	Globals.reads[tostring(k)] = (Globals.reads[tostring(k)] or 0) + 1
end
local function recordWrite(k, v)
	local s = tostring(k)
	local slot = Globals.writes[s]
	if slot then slot.value = v; slot.count = slot.count + 1
	else Globals.writes[s] = { value = v, count = 1 } end
	if CONFIG.CaptureStrings and type(v) == "string" then
		Strings.add(v, "globalwrite:" .. s)
	end
end

local function traceCall(name, args)
	if not CONFIG.TraceCalls or Calls.count >= CONFIG.MaxCallLog then return end
	Calls.count = Calls.count + 1
	local parts = {}
	for i = 1, math.min(#args, 6) do
		local a = args[i]
		local tv = type(a)
		if tv == "string" then
			parts[i] = string.format("%q", #a > 60 and (a:sub(1, 57) .. "...") or a)
		elseif tv == "table" then parts[i] = "<table>"
		elseif tv == "function" then parts[i] = "<fn>"
		else parts[i] = tostring(a) end
	end
	Calls.entries[Calls.count] = string.format("%s(%s)",
		tostring(name), table.concat(parts, ", "))
end

--=====================================================================
-- 12.  HOOK LAYER
--=====================================================================

local originals = {}

local function captureChunk(source, chunkname, kind)
	Captures.order = Captures.order + 1
	local entry = {
		source = source, chunkname = chunkname or ("chunk_" .. Captures.order),
		kind = kind or "loadstring",
		time = os.clock and os.clock() or 0, order = Captures.order,
	}
	Captures.chunks[#Captures.chunks + 1] = entry
	if CONFIG.CaptureStrings and type(source) == "string" then
		Strings.add(source, "loadstring:" .. tostring(chunkname))
		-- Try to detect a Luraph blob and decode it right now
		if type(source) == "string" and source:sub(1, 3) == "LPH" then
			Captures.luraphBlobs[#Captures.luraphBlobs + 1] = source
			log("captured Luraph blob (%d bytes)", #source)
			local chunk = Luraph.autoDetect(source)
			if chunk then
				Luraph.chunk = chunk
				Luraph.decodeOk = true
				log("Luraph chunk decoded: %d protos, %d constants",
					#chunk.prototypes, #chunk.constants)
				for _, c in ipairs(chunk.constants) do
					if c.type == "string" and type(c.value) == "string" then
						Strings.add(c.value, "luraph:const")
					end
				end
			end
		end
	end
	log("captured %s '%s' (%d bytes)", entry.kind, entry.chunkname,
		type(source) == "string" and #source or 0)
	return entry
end

local function tryDumpBytecode(fn, name)
	if not CONFIG.CaptureBytecode or type(fn) ~= "function" then return end
	local ok, data = pcall(string.dump, fn)
	if ok and type(data) == "string" and #data > 0 then
		Captures.bytecode[#Captures.bytecode + 1] = { data = data, name = name or "bytecode" }
	end
end

--=====================================================================
-- 13.  PUBLIC API
--=====================================================================

local Dumper = {}
local attached = false

function Dumper.attach()
	if attached then warn_("already attached"); return end
	local genv = EXEC.getgenv()

	if CONFIG.PolSecBypass then PolSec.install() end
	if CONFIG.LuarmorMode then Luarmor.install() end

	-- Install LPH macros into the global env so payloads can call them.
	if CONFIG.LuraphMode then Luraph.installMacrosInto(genv) end

	-- loadstring
	if CONFIG.CaptureLoadstring and type(genv.loadstring) == "function" then
		originals.loadstring = genv.loadstring
		local real = genv.loadstring
		local wrapper = function(source, chunkname)
			local entry = captureChunk(source, chunkname, "loadstring")
			traceCall("loadstring", { source, chunkname })
			local fn, err = real(source, chunkname)
			if type(fn) == "function" then
				tryDumpBytecode(fn, entry.chunkname)
				if CONFIG.LuraphMode then pcall(Luraph.scan, fn) end
			end
			return fn, err
		end
		installGlobal("loadstring", wrapper, real)
	end

	-- load
	if CONFIG.CaptureLoadstring and type(genv.load) == "function" then
		originals.load = genv.load
		local real = genv.load
		local wrapper = function(chunk, chunkname, mode, env)
			if type(chunk) == "string" then captureChunk(chunk, chunkname, "load")
			elseif type(chunk) == "function" then captureChunk("<reader fn>", chunkname, "load") end
			traceCall("load", { chunk, chunkname })
			local fn, err = real(chunk, chunkname, mode, env)
			if type(fn) == "function" then tryDumpBytecode(fn, chunkname) end
			return fn, err
		end
		installGlobal("load", wrapper, real)
	end

	-- require
	if type(genv.require) == "function" then
		originals.require = genv.require
		local real = genv.require
		local wrapper = function(t)
			traceCall("require", { t })
			local r = real(t)
			if type(r) == "string" then Strings.add(r, "require") end
			return r
		end
		installGlobal("require", wrapper, real)
	end

	-- string hooks
	if CONFIG.CaptureStrings then
		if type(string.format) == "function" then
			local real = string.format
			installGlobal("format", function(fmt, ...)
				local ok, r = pcall(real, fmt, ...)
				if ok and type(r) == "string" then Strings.add(r, "string.format") end
				if ok then return r end
				error(r, 2)
			end, real)
		end
		if type(string.rep) == "function" then
			local real = string.rep
			installGlobal("rep", function(c, n, sep)
				local r = real(c, n, sep)
				if type(r) == "string" then Strings.add(r, "string.rep") end
				return r
			end, real)
		end
		if type(table.concat) == "function" then
			local real = table.concat
			table.concat = function(t, sep, i, j)
				local r = real(t, sep, i, j)
				if type(r) == "string" then Strings.add(r, "table.concat") end
				return r
			end
		end
	end

	-- string.char / byte
	if CONFIG.CaptureCharCalls and type(string.char) == "function" then
		local realChar = string.char
		string.char = function(...)
			local r = realChar(...)
			Captures.charCalls[#Captures.charCalls + 1] = r
			if #r >= 4 then Strings.add(r, "string.char") end
			return r
		end
	end
	if CONFIG.CaptureCharCalls and type(string.byte) == "function" then
		local realByte = string.byte
		string.byte = function(s, i, j)
			if type(s) == "string" and #s > 4 then Strings.add(s, "string.byte") end
			return realByte(s, i, j)
		end
	end

	-- global tracing
	if CONFIG.TraceGlobals then
		local thisEnv = getfenv and getfenv(1) or genv
		pcall(setmetatable, thisEnv, {
			__index = function(_, k) recordRead(k); return genv[k] end,
			__newindex = function(_, k, v) recordWrite(k, v); genv[k] = v end,
		})
	end

	attached = true
	log("attached — PolSec=%s Luarmor=%s Luraph=%s",
		tostring(PolSec.active), tostring(Luarmor.active), tostring(CONFIG.LuraphMode))
end

function Dumper.detach()
	if not attached then return end
	local genv = EXEC.getgenv()
	if originals.loadstring then genv.loadstring = originals.loadstring end
	if originals.load       then genv.load       = originals.load       end
	if originals.require    then genv.require    = originals.require    end
	attached = false
	log("detached")
end

--=====================================================================
-- 14.  DEBUG WALK
--=====================================================================

local function describeValue(v)
	local tv = type(v)
	if tv == "string" then
		local p = #v > 120 and (v:sub(1, 117) .. "...") or v
		return string.format("%q", p)
	elseif tv == "number" or tv == "boolean" or tv == "nil" then
		return tostring(v)
	elseif tv == "function" then
		local info = safeDebug("getinfo", v, "nS")
		return string.format("<fn %s>", info and (info.name or info.short_src) or "?")
	elseif tv == "table" then return "<table>" end
	return "<" .. tv .. ">"
end

local DebugWalk = {}
function DebugWalk.walk(fn, depth, seen, out)
	depth = depth or 0; seen = seen or {}; out = out or {}
	if type(fn) ~= "function" or depth > CONFIG.MaxProtoDepth or seen[fn] then return out end
	seen[fn] = true
	local info = safeDebug("getinfo", fn, "nSl") or {}
	out[#out + 1] = string.format("\n--[[ proto d=%d n=%s src=%s line=%s ]]",
		depth, tostring(info.name or "?"),
		tostring(info.short_src or info.source or "?"),
		tostring(info.currentline or info.linedefined or "?"))
	local consts = safeDebug("getconstants", fn)
	if type(consts) == "table" then
		out[#out + 1] = "-- constants:"
		for i, c in ipairs(consts) do
			out[#out + 1] = string.format("--   [%d] %s", i, describeValue(c))
			if CONFIG.CaptureStrings and type(c) == "string" then Strings.add(c, "constant") end
		end
	end
	local ups = safeDebug("getupvalues", fn)
	if type(ups) == "table" then
		out[#out + 1] = "-- upvalues:"
		for i, u in ipairs(ups) do
			out[#out + 1] = string.format("--   [%d] %s", i, describeValue(u))
			if CONFIG.CaptureStrings and type(u) == "string" then Strings.add(u, "upvalue") end
		end
	end
	local protos = safeDebug("getprotos", fn)
	if type(protos) == "table" then
		for _, child in ipairs(protos) do DebugWalk.walk(child, depth + 1, seen, out) end
	end
	return out
end

--=====================================================================
-- 15.  REWRITER (includes Luraph anti-source strip)
--=====================================================================

local Rewriter = {}

local function unescapeLiterals(src)
	return (src:gsub("\\x(%x%x)", function(h)
		return string.char(tonumber(h, 16))
	end):gsub("\\(%d%d?%d?)", function(d)
		local n = tonumber(d)
		if n and n < 256 then return string.char(n) end
		return "\\" .. d
	end))
end

local function foldConcat(src)
	local changed, guard = true, 0
	while changed and guard < 20 do
		changed = false; guard = guard + 1
		src = src:gsub('("(?:[^"\\]|\\.)*")\s*%.%.%\s*("(?:[^"\\]|\\.)*")', function(a, b)
			changed = true
			local ua = a:sub(2, -2):gsub("\\n", "\n"):gsub("\\t", "\t"):gsub('\\"', '"')
			local ub = b:sub(2, -2):gsub("\\n", "\n"):gsub("\\t", "\t"):gsub('\\"', '"')
			return string.format("%q", ua .. ub)
		end)
	end
	return src
end

local function foldArithmetic(src)
	local function fold(a, op, b)
		local x, y = tonumber(a), tonumber(b)
		if not x or not y then return nil end
		if op == "+" then return x + y
		elseif op == "-" then return x - y
		elseif op == "*" then return x * y
		elseif op == "/" then return y ~= 0 and (x / y) or nil
		elseif op == "%" then return y ~= 0 and (x % y) or nil
		elseif op == "^" then return x ^ y end
	end
	return (src:gsub("(%d+)%s*([%+%-%*/%%%^])%s*(%d+)", function(a, op, b)
		local r = fold(a, op, b)
		if r then return string.format("%g", r) end
		return a .. op .. b
	end))
end

local function stripJunkComments(src)
	src = src:gsub("%-%-%[%[.-%]%]", "")
	src = src:gsub("%-%-[^\n]*", "")
	return src
end

local function stripPolSecBlocks(src)
	local out = src
	out = out:gsub("local function processItems%d+%b()", "--[[PolSec block removed]]")
	out = out:gsub("local function runProtected%b()", "--[[PolSec block removed]]")
	out = out:gsub("game:GetService%(\"Players\"%).LocalPlayer:Kick%b()", "--[[PolSec kick removed]]")
	return out
end

local function stripLuarmorBlocks(src)
	local out = src
	out = out:gsub("if%s+getfenv%(.+%)%s*~=%s*\"%*\\252\\174&h\\192\"%s*then", "if false then")
	out = out:gsub("checkcaller%b()", "false")
	return out
end

function Rewriter.rewrite(src)
	if type(src) ~= "string" then return src end
	local out = src
	if CONFIG.EnableRewriter then
		out = stripJunkComments(out)
		out = unescapeLiterals(out)
		out = foldConcat(out)
	end
	if CONFIG.EnableConstantFold then out = foldArithmetic(out) end
	if CONFIG.StripAfterDecode then
		out = stripPolSecBlocks(out)
		out = stripLuarmorBlocks(out)
		out = Luraph.stripAntiSource(out)
	end
	return out
end

--=====================================================================
-- 16.  WATERMARK
--=====================================================================

local function applyWatermark(src)
	if not CONFIG.Watermark or type(src) ~= "string" then return src end
	local prefix = string.rep(CONFIG.WatermarkText, CONFIG.WatermarkRepeat)
	local lines = {}
	for line in (src .. "\n"):gmatch("([^\n]*)\n") do
		lines[#lines + 1] = prefix .. line
	end
	return table.concat(lines, "\n")
end

Dumper.applyWatermark = applyWatermark

--=====================================================================
-- 17.  REPORT
--=====================================================================

local function timestamp()
	return os.date and os.date("%Y-%m-%d %H:%M:%S") or "unknown"
end
local function section(title)
	return "\n" .. string.rep("=", 72) .. "\n" .. title .. "\n" .. string.rep("=", 72) .. "\n"
end

local function buildReport()
	local buf = {}
	buf[#buf + 1] = "-- Luau Dumper (Luraph 15.1 + PolSec + Luarmor)\n"
	buf[#buf + 1] = "-- generated: " .. timestamp() .. "\n"
	buf[#buf + 1] = string.format("-- chunks=%d strings=%d bytecode=%d calls=%d kicks_blocked=%d luraph_blobs=%d\n",
		#Captures.chunks, Strings.count, #Captures.bytecode, Calls.count,
		PolSec.kicksBlocked, #Captures.luraphBlobs)

	buf[#buf + 1] = section("POLSEC")
	buf[#buf + 1] = string.format("active=%s kicks_blocked=%d warns_filtered=%d\n",
		tostring(PolSec.active), PolSec.kicksBlocked, PolSec.warnsFiltered)

	buf[#buf + 1] = section("LUARMOR")
	buf[#buf + 1] = string.format("loader_url=%s\npayload_url=%s\nraw_loader=%d bytes\nraw_payload=%d bytes\n",
		tostring(Luarmor.loaderURL), tostring(Luarmor.payloadURL),
		Luarmor.rawLoader and #Luarmor.rawLoader or 0,
		Luarmor.rawPayload and #Luarmor.rawPayload or 0)
	buf[#buf + 1] = "-- LRM_* vars:\n"
	for k, v in pairs(Luarmor.runtimeVars) do
		buf[#buf + 1] = string.format("--   %s = %s\n", k, tostring(v))
	end

	if Luraph.chunk then
		buf[#buf + 1] = section("LURAPH 15.1")
		buf[#buf + 1] = string.format("profile=%s protos=%d constants=%d dispatch=%s\n",
			tostring(Luraph.chunk.settings.Name),
			#Luraph.chunk.prototypes,
			#Luraph.chunk.constants,
			Luraph.dispatch and (#Luraph.dispatch .. " handlers") or "not scanned")
		buf[#buf + 1] = "\n" .. Luraph.lift(Luraph.chunk) .. "\n"
	end

	buf[#buf + 1] = section("CAPTURED CHUNKS")
	for i, c in ipairs(Captures.chunks) do
		buf[#buf + 1] = string.format("\n--[[ chunk %d | %s | %s | %d bytes ]]\n",
			i, tostring(c.chunkname), tostring(c.kind),
			type(c.source) == "string" and #c.source or 0)
		if type(c.source) == "string" then buf[#buf + 1] = c.source end
		buf[#buf + 1] = "\n"
	end

	buf[#buf + 1] = section("BEST DECODED SOURCE")
	local best = Strings.bestSource()
	if best then
		buf[#buf + 1] = string.format("-- score=%d origin=%s size=%d\n",
			best.score or 0, best.origin or "?", #best.value)
		buf[#buf + 1] = Rewriter.rewrite(best.value) .. "\n"
	else
		buf[#buf + 1] = "-- none\n"
	end

	if #Captures.charCalls > 0 then
		buf[#buf + 1] = section("CHAR-BUILT PAYLOAD")
		buf[#buf + 1] = table.concat(Captures.charCalls, "") .. "\n"
	end

	buf[#buf + 1] = section("DECRYPTED STRINGS")
	local sorted = Strings.sorted()
	local printed = 0
	for _, item in ipairs(sorted) do
		if item.decoded and printed < CONFIG.MaxReportStrings then
			printed = printed + 1
			buf[#buf + 1] = string.format("-- [%d] %s score=%d\n-- %q\n",
				printed, tostring(item.method), item.decodedScore or 0, item.decoded)
		end
	end

	buf[#buf + 1] = section("SCORED STRINGS")
	for i = 1, math.min(#sorted, CONFIG.MaxReportStrings) do
		local item = sorted[i]
		local pv = #item.value > 180 and (item.value:sub(1, 177) .. "...") or item.value
		buf[#buf + 1] = string.format("-- [%d] score=%d origin=%s size=%d\n-- %q\n",
			i, item.score, item.origin, #item.value, pv)
	end

	buf[#buf + 1] = section("CALL LOG")
	for i = 1, math.min(#Calls.entries, CONFIG.MaxCallLog) do
		buf[#buf + 1] = string.format("[%d] %s\n", i, Calls.entries[i])
	end

	return table.concat(buf)
end

--=====================================================================
-- 18.  API
--=====================================================================

function Dumper.dump(path)
	ensureFolder(CONFIG.OutputFolder)
	local name = path or ("dump_" .. tostring(os.time and os.time() or 0) .. ".lua")
	local full = CONFIG.OutputFolder .. "/" .. name
	local report = buildReport()
	report = applyWatermark(report)
	Output.write(full, report)
	return full
end

function Dumper.dumpDecoded(path)
	ensureFolder(CONFIG.OutputFolder)
	local best = Strings.bestSource()
	if not best then warn_("no decoded source"); return nil end
	local decoded = Rewriter.rewrite(best.value)
	decoded = applyWatermark(decoded)
	local full = CONFIG.OutputFolder .. "/" .. (path or ("decoded_" .. tostring(os.time and os.time() or 0) .. ".lua"))
	Output.write(full, decoded)
	return full
end

function Dumper.dumpLuraph(path)
	ensureFolder(CONFIG.OutputFolder)
	if not Luraph.chunk then warn_("no Luraph chunk decoded"); return nil end
	local text = Luraph.lift(Luraph.chunk)
	text = Rewriter.rewrite(text)
	text = applyWatermark(text)
	local full = CONFIG.OutputFolder .. "/" .. (path or ("luraph_" .. tostring(os.time and os.time() or 0) .. ".lua"))
	Output.write(full, text)
	return full
end

function Dumper.dumpMacros(path)
	ensureFolder(CONFIG.OutputFolder)
	local lines = { "-- LPH_* macro definitions\n" }
	for k, v in pairs(Luraph.Macros.install) do
		lines[#lines + 1] = string.format("-- %s = %s\n", k, typeof and typeof(v) or type(v))
	end
	local text = applyWatermark(table.concat(lines))
	local full = CONFIG.OutputFolder .. "/" .. (path or ("macros_" .. tostring(os.time and os.time() or 0) .. ".txt"))
	Output.write(full, text)
	return full
end

function Dumper.dumpLuarmor(path)
	ensureFolder(CONFIG.OutputFolder)
	local lines = { "-- Luarmor artifacts\n" }
	lines[#lines + 1] = string.format("loader_url = %q\n", tostring(Luarmor.loaderURL))
	lines[#lines + 1] = string.format("payload_url = %q\n", tostring(Luarmor.payloadURL))
	if Luarmor.rawLoader then
		lines[#lines + 1] = "\n--[[ RAW LOADER ]]\n" .. Luarmor.rawLoader .. "\n"
	end
	if Luarmor.rawPayload then
		lines[#lines + 1] = "\n--[[ RAW PAYLOAD ]]\n" .. Luarmor.rawPayload .. "\n"
	end
	local text = applyWatermark(table.concat(lines))
	local full = CONFIG.OutputFolder .. "/" .. (path or ("luarmor_" .. tostring(os.time and os.time() or 0) .. ".lua"))
	Output.write(full, text)
	return full
end

function Dumper.inspect(fn)
	local out = DebugWalk.walk(fn)
	local text = applyWatermark(table.concat(out, "\n"))
	ensureFolder(CONFIG.OutputFolder)
	local full = CONFIG.OutputFolder .. "/inspect_" .. tostring(os.time and os.time() or 0) .. ".txt"
	Output.write(full, text)
	return text
end

function Dumper.stats()
	return {
		chunks = #Captures.chunks, strings = Strings.count,
		bytecode = #Captures.bytecode, calls = Calls.count,
		polsec = { active = PolSec.active, kicks = PolSec.kicksBlocked },
		luarmor = { loaderURL = Luarmor.loaderURL },
		luraph = Luraph.chunk and {
			protos = #Luraph.chunk.prototypes,
			constants = #Luraph.chunk.constants,
			profile = Luraph.chunk.settings and Luraph.chunk.settings.Name,
		} or nil,
	}
end

function Dumper.reset()
	Strings.seen, Strings.items, Strings.count = {}, {}, 0
	Captures.chunks, Captures.bytecode, Captures.charCalls, Captures.luraphBlobs, Captures.order = {}, {}, {}, {}, 0
	Calls.entries, Calls.count = {}, 0
	Globals.reads, Globals.writes = {}, {}
	Luarmor.httpCalls, Luarmor.runtimeVars = {}, {}
	log("state cleared")
end

-- Auto-decode a Luraph blob that was manually supplied.
function Dumper.decodeLuraphBlob(blob)
	local chunk = Luraph.autoDetect(blob)
	if chunk then
		Luraph.chunk = chunk
		Luraph.decodeOk = true
		log("manual Luraph decode: %d protos, %d constants",
			#chunk.prototypes, #chunk.constants)
		return chunk
	end
	warn_("Luraph autodetect failed")
	return nil
end

-- Expose everything
Dumper.config   = CONFIG
Dumper.strings  = Strings
Dumper.captures = Captures
Dumper.calls    = Calls
Dumper.decrypt  = Decrypt
Dumper.rewrite  = Rewriter.rewrite
Dumper.polsec   = PolSec
Dumper.luarmor  = Luarmor
Dumper.luraph   = Luraph
Dumper.macros   = Luraph.Macros.install
Dumper.opcodes  = Luraph.OpcodeTable
Dumper.debugWalk = DebugWalk

log("dumper loaded — PolSec=%s Luarmor=%s Luraph=%s",
	tostring(CONFIG.PolSecBypass), tostring(CONFIG.LuarmorMode), tostring(CONFIG.LuraphMode))
log("call :attach() then run the loader, then :dumpDecoded()")

return Dumper
