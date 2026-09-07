do
    task.spawn(function()
        local ok, err = pcall(function()
            local RS = game:GetService("ReplicatedStorage")
            local pkgs = RS:WaitForChild("Packages", 120)
            require(pkgs:WaitForChild("Synchronizer", 120))
            local datas = RS:WaitForChild("Datas", 60)
            require(datas:WaitForChild("Animals", 60))
            require(datas:WaitForChild("Mutations", 30))
            require(datas:WaitForChild("Traits", 30))
            local utils = RS:WaitForChild("Utils", 30)
            require(utils:WaitForChild("NumberUtils", 30))
            pkgs:WaitForChild("Net", 30)   -- remote folder (the resolver scans this)
        end)
    end)
    task.spawn(function()
        local Players = game:GetService("Players")
        local lp = Players.LocalPlayer
        for _ = 1, 20 do
            pcall(function()
                local c = lp and lp.Character
                local h = c and c:FindFirstChild("HumanoidRootPart")
                if h and h.Anchored then h.Anchored = false end
            end)
            task.wait(0.25)
        end
    end)
end

if not game:IsLoaded() then game.Loaded:Wait() end

-- LOAD TIMER (hub_Mata). Three places further down already call _G.__LMARK
-- behind an `if _G.__LMARK then` guard -- the Net streaming request, the plot
-- stream-in and the grapple hook -- but nothing ever DEFINED it here, so every
-- one of those was a silent no-op and the load-time breakdown they exist to
-- print was simply missing.
-- SILENT. The call sites stay (they are all `if _G.__LMARK then` guarded and
-- hub_Mata's own header calls this timer temporary), but it prints nothing --
-- no debug output in console. Set _G.__LMARK_DEBUG = true before load to get
-- the load-time breakdown back.
_G.__LT = os.clock()
_G.__LMARK = function(name)
    if _G.__LMARK_DEBUG then
        print(("[LOAD] %-22s %6.2fs"):format(name, os.clock() - _G.__LT))
    end
end
if LPH_OBFUSCATED == nil then
    local env = getfenv()
    env["LPH_NO_" .. "VIRTUALIZE"] = function(...) return ... end
    env["LPH_JIT_" .. "MAX"]       = function(...) return ... end
end

-- game.Loaded:Wait() removed: start the hub before the game finishes loading so TP-on-load can
-- fire during the loading screen. The specific WaitForChild calls below still wait for the
-- individual instances they need (Datas, Net, PlayerGui, Synchronizer, ...).

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
-- With game.Loaded:Wait() gone, the script can run the very first instant on auto-execute;
-- make sure LocalPlayer exists before anything below touches it.
while not LocalPlayer do task.wait(); LocalPlayer = Players.LocalPlayer end
UIS = game:GetService("UserInputService")
RunService = game:GetService("RunService")
Stats = game:GetService("Stats")
TweenService = game:GetService("TweenService")
HttpService = game:GetService("HttpService")
ReplicatedStorage = game:GetService("ReplicatedStorage")
Workspace = game:GetService("Workspace")
Lighting = game:GetService("Lighting")
TeleportService = game:GetService("TeleportService")
CoreGui = game:GetService("CoreGui")
VirtualInputManager = game:GetService("VirtualInputManager")



-- GUI lookup helper carried over from the Heresy core (gethui first, PlayerGui
-- fallback). Harmless if nothing calls it; here so any Heresy-core code spliced
-- in below resolves rather than erroring inside its own pcall.
_G.SXEBuscaGui = function(nome)
    local alvo = (gethui and gethui()) or game:GetService("CoreGui")
    local r
    pcall(function() r = alvo and alvo:FindFirstChild(nome) end)
    if r then return r end
    pcall(function()
        local pg = game:GetService("Players").LocalPlayer
            :FindFirstChildOfClass("PlayerGui")
        r = pg and pg:FindFirstChild(nome)
    end)
    return r
end

-- =====================================================================
-- CHANNEL DISCOVERY -- HERESY CORE (execute-path swap)
-- ---------------------------------------------------------------------
-- Replaces this fork's getgc(true) heap-identity sweep with the Heresy
-- core's upvalue probe. Same result (_xchan -> the live channel registry),
-- same public surface below (XenSyncGet / sProp / _xenRawCT / accessors),
-- but it never walks the whole Lua heap on a timer and it only READS
-- Synchronizer upvalues -- debug.getupvalue, never setupvalue. This is the
-- discovery path on the build that stays in-game.
-- =====================================================================
do
local _xchan
local _lastTry, _attempts = 0, 0
local _deepScans, _lastDeep = 0, 0
local _mod
local MAX_ATTEMPTS, RETRY_GAP = 40, 0.5
-- After the fast budget is spent this keeps trying, just rarely, instead of
-- giving up for good. See the note in _chans -- this is the difference between
-- "plot scanning is degraded for a few seconds" and "for the whole session".
local SLOW_GAP = 5.0
local BOOT_T0, BOOT_BURST, BOOT_GAP = os.clock(), 3.0, 0.10
local MAX_DEEP, DEEP_GAP = 3, 1.5
local function _retryGap()
    if (os.clock() - BOOT_T0) < BOOT_BURST then return BOOT_GAP end
    if _attempts >= MAX_ATTEMPTS then return SLOW_GAP end
    return RETRY_GAP
end
local function _channelCount(t)
    if type(t) ~= "table" then return 0 end
    local ok, hits = pcall(function()
        local h, n = 0, 0
        for _, v in next, t do
            n = n + 1
            if type(v) == "table" and type(rawget(v, "CacheTable")) == "table" then
                h = h + 1
            end
            if n >= 200 then break end
        end
        return h
    end)
    return (ok and hits) or 0
end
local function _module()
    if _mod then return _mod end
    local ok, m = pcall(function()
        return require(game:GetService("ReplicatedStorage").Packages.Synchronizer)
    end)
    if ok and type(m) == "table" then _mod = m; return _mod end
    local ok2, m2 = pcall(function()
        local pkgs = game:GetService("ReplicatedStorage"):FindFirstChild("Packages")
        local sync = pkgs and pkgs:FindFirstChild("Synchronizer")
        if not sync then return nil end
        return require(sync)
    end)
    if ok2 and type(m2) == "table" then _mod = m2 end
    return _mod
end
local function _probe(mod)
    local gu = (debug and debug.getupvalue) or getupvalue
    if type(gu) ~= "function" then return nil, 0, nil end
    local best, bestN, where = nil, 0, nil
    local function consider(t, tag)
        local n = _channelCount(t)
        if n > bestN then best, bestN, where = t, n, tag end
    end
    local ok, up = pcall(gu, mod.Get, 9)
    if ok and type(up) == "table" then
        consider(rawget(up, 3), "Get/9/3")
        if bestN > 0 then return best, bestN, where end
        consider(up, "Get/9")
        if bestN > 0 then return best, bestN, where end
    end
    return nil, 0, nil
end
local function _deepScan(mod)
    local gu = (debug and debug.getupvalue) or getupvalue
    if type(gu) ~= "function" then return nil, 0, nil end
    local best, bestN, where = nil, 0, nil
    local function consider(t, tag)
        local n = _channelCount(t)
        if n > bestN then best, bestN, where = t, n, tag end
    end
    for fname, fn in next, mod do
        if type(fn) == "function" then
            for i = 1, 24 do
                local o, u = pcall(gu, fn, i)
                if not o then break end
                if type(u) == "table" then
                    consider(u, tostring(fname) .. "/" .. i)
                    for j = 1, 4 do
                        consider(rawget(u, j), tostring(fname) .. "/" .. i .. "/" .. j)
                    end
                end
            end
        end
    end
    return best, bestN, where
end
local function _chans()
    if _xchan then return _xchan end
    if (os.clock() - _lastTry) <= _retryGap() then return nil end
    _lastTry = os.clock()
    local mod = _module()
    if not mod then return nil end

    -- NEVER GIVE UP FOR GOOD. This used to bail permanently at MAX_ATTEMPTS --
    -- and its own diagnostic said what that meant: "plot scanning is disabled".
    --
    -- The budget burns in about eight seconds (30 fast attempts in the 3s boot
    -- burst, then 10 at 0.5s), and the module can be REQUIRED long before its
    -- channel registry is actually populated -- so on any slow load, or when the
    -- hub is executed during the loading screen as it is designed to be, those
    -- attempts were spent against an empty registry. After that every plot fell
    -- back to rendered models only, for the rest of the session: distant bases
    -- show nothing, the TP has no targets, and scanning looks broken.
    --
    -- Past the fast budget it now drops to one attempt every SLOW_GAP seconds
    -- instead of stopping. Once _xchan is found this whole function short-
    -- circuits on its first line, so the slow retry costs nothing in the normal
    -- case -- it only runs while the thing is genuinely still missing.
    _attempts = _attempts + 1
    local found, n, where = _probe(mod)
    -- a few extra deep scans are unlocked on the slow path too: the cheap probe
    -- only knows one shape, and a registry that shows up late may not match it
    local deepBudget = (_attempts >= MAX_ATTEMPTS) and (MAX_DEEP + 6) or MAX_DEEP
    if not found and _deepScans < deepBudget and (os.clock() - _lastDeep) > DEEP_GAP then
        _lastDeep = os.clock()
        _deepScans = _deepScans + 1
        found, n, where = _deepScan(mod)
    end
    if found then
        _xchan = found
        _G.XenSyncDiag = string.format("bypassed via %s - %d channels (attempt %d)",
            tostring(where), n, _attempts)
    elseif _attempts == MAX_ATTEMPTS then
        _G.XenSyncDiag = "channels not found after " .. MAX_ATTEMPTS
            .. " fast attempts - still retrying every " .. tostring(SLOW_GAP) .. "s"
    end
    return _xchan
end

_G.XenSyncAll=function()return _chans()end
_G.XenSyncGet=function(idx)
local t=_chans()
if not t or idx==nil then return nil end
local ok,cd=pcall(rawget,t,idx)
if ok and type(cd)=="table" then return cd end
local ok2,cd2=pcall(function() return t[idx] end)
if ok2 and type(cd2)=="table" then return cd2 end
return nil
end
-- Raw channel property read (the BYPASS): never calls channel:Get(key) -- the
-- hookable/patched surface -- it reads CacheTable directly with rawget, falling
-- back to plain indexing only for proxy/__index-backed registries.
_G.sProp=function(ch,key)
if type(ch)~="table" or key==nil then return nil end
local ct=rawget(ch,"CacheTable")
if type(ct)~="table" then
local okC,c2=pcall(function() return ch.CacheTable end)
if okC and type(c2)=="table" then ct=c2 end
end
if type(ct)~="table" then return nil end
local v=rawget(ct,key)
if v~=nil then return v end
local okV,v2=pcall(function() return ct[key] end)
if okV then return v2 end
return nil
end
-- Slot list rebuilt from the hub's own plot scanner cache.
--
-- The TP engines build their pet list from a channel AnimalList. When the
-- channel is missing they had nothing -- which is why removing the "no channel,
-- skip the base" gate alone was not enough: the base got past the gate and then
-- produced no slots anyway.
--
-- The plot scanner already resolves those bases (it falls back to rendered
-- Models), so this hands its findings back in AnimalList shape. The TP only
-- needs plot + slot; it calls getPetPosition itself from there.
_G.Skyr0CachedSlotsForPlot=function(plotName)
    local c = (_G.SharedState and _G.SharedState.AllAnimalsCache)
           or (SharedState and SharedState.AllAnimalsCache)
    if type(c) ~= "table" then return nil end
    local out, n = {}, 0
    for _, a in ipairs(c) do
        if a.plot == plotName and a.slot and a.index then
            out[a.slot] = { Index = a.index, Mutation = a.mutation, Traits = nil }
            n = n + 1
        end
    end
    if n == 0 then return nil end
    return out
end

-- Channel read that PREFERS the raw path but never loses data.
--
-- sProp reads CacheTable directly, which is the whole point of the bypass: it
-- never touches the hookable channel:Get. But a channel that exposes no
-- CacheTable makes sProp return nil, and several call sites were switched from
-- :Get to sProp-only -- so on those channels the read silently became "no data"
-- and the scanners went blind.
--
-- Raw first (so the normal case never touches :Get), :Get only when raw came
-- back empty. Anti-detection preference kept, blind spot removed.
_G.Skyr0ChanGet=function(ch,key)
    if type(ch)~="table" or key==nil then return nil end
    local v=_G.sProp and _G.sProp(ch,key)
    if v~=nil then return v end
    local ok,v2=pcall(function() return ch.Get and ch:Get(key) end)
    if ok and v2~=nil then return v2 end
    return nil
end
_G._xenRawCT=function(plotName)
local c=_G.XenSyncGet(plotName)
if not c then return nil end
return rawget(c,"CacheTable")
end
local _AD,_MD,_TD
local function _data()
if _AD then return true end
local ok=pcall(function()
local d=game:GetService("ReplicatedStorage"):WaitForChild("Datas")
_AD=require(d:WaitForChild("Animals"))
_MD=require(d:WaitForChild("Mutations"))
_TD=require(d:WaitForChild("Traits"))
end)
return ok and _AD~=nil
end
-- Traits arrive in whatever shape the game feels like. Seen and handled:
--   {"Fast","Strong"}                 array of names
--   {Fast=true, Strong=true}          set keyed by name
--   {{Name="Fast"},{Id="Strong"}}     array of records
--   "Fast"                            a bare single trait
-- Returns a plain array of name strings, or nil when there are none. Every
-- consumer below goes through this rather than trusting the raw value.
_G.Skyr0NormTraits=function(traits)
if traits==nil then return nil end
if type(traits)=="string" then return traits~="" and {traits} or nil end
if type(traits)~="table" then return nil end
local out={}
-- array part first: names, or records carrying a name
for _,v in ipairs(traits) do
if type(v)=="string" then
if v~="" then out[#out+1]=v end
elseif type(v)=="table" then
local n=v.Name or v.Id or v.Trait or v.TraitName or v.Type
if type(n)=="string" and n~="" then out[#out+1]=n end
end
end
-- no array part: treat it as a set keyed by trait name
if #out==0 then
for k,v in pairs(traits) do
if type(k)=="string" and k~="" and v~=false and v~=nil then out[#out+1]=k end
end
end
if #out==0 then return nil end
return out
end

_G._xenGen=function(index,mutation,traits)
if not _data() then return 0 end
local info=_AD[index]
if not info or not info.Generation then return 0 end
local mult=1
if mutation and mutation~="None" and mutation~="" then
local m=_MD[mutation]
if m and m.Modifier then mult=mult+m.Modifier end
end
-- Normalised first: the raw value is frequently NOT an array of names, and
-- ipairs over the wrong shape silently contributes no multiplier at all --
-- which prices a traited pet exactly as if it were plain.
local tl=_G.Skyr0NormTraits and _G.Skyr0NormTraits(traits) or traits
if type(tl)=="table" then
for _,tr in ipairs(tl)do
local t=_TD[tr]
if t and t.MultiplierModifier then mult=mult+t.MultiplierModifier end
end
end
return info.Generation*mult
end
-- MEMOISED __index. This was the per-pet cost that showed up as an FPS drop
-- while the scanners were working hardest -- the load, and TP-on-load with it.
--
-- GetGeneration is a raw field, so it never reached this metamethod. GetValue is
-- NOT -- and the plot scanner calls AnimalsShared:GetValue once for EVERY pet on
-- EVERY plot on EVERY scan. Each of those calls landed here and re-ran the whole
-- lookup from scratch: a closure allocation, a pcall, game:GetService, TWO
-- WaitForChild traversals and a require. On a full server that is ~100 pets per
-- scan paying for a module reference that never changes.
--
-- Now the real module is resolved once, and each member is rawset onto the shim
-- the first time it is asked for -- so the SECOND access is a plain field read
-- and the metamethod is never entered again for that key. Nothing is cached
-- until it actually resolves, so an early call made before Shared.Animals has
-- replicated still returns nil and is retried later instead of poisoning the
-- shim with a permanent nil.
_G._xenAnimReal = _G._xenAnimReal or nil
_G._xenAnimShim=setmetatable({GetGeneration=function(_,index,mutation,traits)return _G._xenGen(index,mutation,traits)end},{
__index=function(self,k)
local real=_G._xenAnimReal
if type(real)~="table" then
local ok,r=pcall(function()return require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Animals"))end)
if not ok or type(r)~="table" then return nil end
real=r; _G._xenAnimReal=r
end
local v=rawget(real,k)
if v==nil then local ok2,v2=pcall(function()return real[k] end); if ok2 then v=v2 end end
-- only cache a real hit: a nil here means "not there YET", not "not there"
if v~=nil then rawset(self,k,v) end
return v
end})
-- Plain lookup by the plot instance's own name.
--
-- This briefly tried the plot's "Order" attribute FIRST ("Plot1", "Plot2", ...)
-- and fell back to the name. That was over-applied: the reference hub only uses
-- the Order key inside its channel WARM-UP loop, and its own GetPlotChannel is
-- a plain by-name lookup like this one. Trying Order first here risks handing
-- back a DIFFERENT plot's channel whenever both keys happen to resolve, which
-- silently poisons every scan built on it. The Order attempt stays where the
-- reference puts it -- in the warm-up below, where a wrong hit only wastes a
-- prefetch and cannot corrupt a read.
_G.Skyr0_GetPlotChannel=function(plotName)return _G.XenSyncGet(plotName)end
_G.Skyr0_GetAllPlots=function()return _G.XenSyncAll() or {} end
_G.Skyr0_GetPlotAnimalList=function(plotName)
local ct=_G._xenRawCT(plotName)
local al=ct and ct.AnimalList
return type(al)=="table" and al or nil
end

-- hub_Mata names the SAME accessors SXE_*, and code written against that hub
-- calls them by that name -- isMyPlot_Instant's Synchronizer check is exactly
-- that. None of them existed here, so that check threw inside its own pcall
-- every single call and the function silently degraded to the PlotSign /
-- YourBase fallbacks. Both names now point at one implementation.
_G.SXE_GetPlotChannel=_G.Skyr0_GetPlotChannel
_G.SXE_GetAllPlots=_G.Skyr0_GetAllPlots
_G.SXE_GetPlotAnimalList=_G.Skyr0_GetPlotAnimalList

end

-- NOT self-armed at boot. An earlier version patched the shared module globally
-- from a background thread, which the original code never did -- so a bad patch
-- took out every scanner at once, before anything had a chance to notice. It is
-- applied only from loadModules now, on the module that loader actually uses.

-- EARLY DATA FORCE-LOAD (overlaps the ENTIRE rest of the hub's load) -----------
-- The TP can't fire until plot data has replicated to you. Instead of waiting for
-- that lazily during the first scan, start hammering every plot channel the instant
-- the sync accessors exist -- while the UI and everything else is still building --
-- so by the time the TP engine is ready the data is already cached and TP fires
-- immediately. Uses the game's own :Get() (forces a fetch if the channel lazy-loads)
-- then verifies via sProp, and drops each channel once its data is present so the
-- cost is bounded and it can't spin forever.
task.spawn(function()
    local WS = game:GetService("Workspace")
    local plots
    local t0 = os.clock()
    repeat
        plots = WS:FindFirstChild("Plots")
        if not plots then task.wait(0.05) end
    until plots or (os.clock() - t0) > 25
    if not plots then return end
    local done, warmT0 = {}, os.clock()
    local _warmGap = 0.35
    while (os.clock() - warmT0) < 15 do
        local kids = plots:GetChildren()
        local pending = false
        for _, plot in ipairs(kids) do
            if not done[plot.Name] then
                -- Channels are keyed by Order ("PlotN"), with the UUID as a
                -- fallback. Using only the UUID this warm-up missed EVERY base
                -- and burned the whole 15s without warming anything -- the data
                -- only arrived later during the normal scan, which is why the
                -- first TPs were so slow.
                local ch
                if _G.XenSyncGet then
                    local ord; pcall(function() ord = plot:GetAttribute("Order") end)
                    if ord ~= nil then ch = _G.XenSyncGet("Plot" .. tostring(ord)) end
                    if not ch then ch = _G.XenSyncGet(plot.Name) end
                end
                if ch then
                    pcall(function() if ch.Get then ch:Get("AnimalList"); ch:Get("Owner") end end)
                    local al = _G.Skyr0ChanGet and _G.Skyr0ChanGet(ch, "AnimalList")
                    if al ~= nil then done[plot.Name] = true else pending = true end
                else
                    pending = true
                end
            end
        end
        if not pending and #kids > 0 then break end
        -- Grow the interval as the window runs out. The first passes are the
        -- ones that matter (that is when data actually lands); a plot still
        -- missing at t+8s is usually an unowned base that will never have data,
        -- and hammering it for the remaining seconds only costs frames.
        _warmGap = math.min(_warmGap * 1.35, 1.5)
        -- 0.35s, not 0.05s.
        --
        -- This is the execute lag. At 0.05 the loop ran TWENTY passes a second
        -- for its full 15s window -- ~300 sweeps of every plot, each doing two
        -- ch:Get() calls, which are the expensive Synchronizer reads this file
        -- otherwise goes out of its way to avoid. It exits the moment every
        -- plot has data, so the interval only controls how hard it hammers
        -- while waiting, not how quickly it finishes.
        task.wait(_warmGap)
    end
    if _G.__LMARK then _G.__LMARK("plot data force-loaded") end
end)

-- EARLY STREAM-IN (forces the brainrot plots to load so the scan sees them fast) --
-- If the game uses StreamingEnabled, distant plots' brainrot models aren't loaded on
-- join, so getPetPosition() can't find them and the scan skips those plots until they
-- stream in on their own. RequestStreamAroundAsync tells the server to stream each
-- plot area in NOW. No-op (returns instantly) if the game doesn't use streaming --
-- which also confirms whether streaming was ever the bottleneck.
task.spawn(function()
    local Players = game:GetService("Players")
    local WS = game:GetService("Workspace")
    local lp = Players.LocalPlayer
    if not WS.StreamingEnabled then
        if _G.__LMARK then _G.__LMARK("stream-in skipped (no StreamingEnabled)") end
        return
    end
    local plots
    local t0 = os.clock()
    repeat plots = WS:FindFirstChild("Plots"); if not plots then task.wait(0.1) end
    until plots or (os.clock() - t0) > 25
    if not plots then return end
    local function plotPos(plot)
        local okp, pv = pcall(function() return plot:GetPivot().Position end)
        if okp and pv and pv.Magnitude > 1 then return pv end
        if plot.PrimaryPart then return plot.PrimaryPart.Position end
        local bp = plot:FindFirstChildWhichIsA("BasePart", true)
        return bp and bp.Position or nil
    end
    local pending = 0
    for _, plot in ipairs(plots:GetChildren()) do
        local pos = plotPos(plot)
        if pos then
            pending = pending + 1
            task.spawn(function()
                pcall(function() lp:RequestStreamAroundAsync(pos) end)
                pending = pending - 1
            end)
        end
    end
    local sw = os.clock()
    while pending > 0 and os.clock() - sw < 10 do task.wait(0.05) end
    if _G.__LMARK then _G.__LMARK("plots stream-in requested") end
end)

do
  if not (_G.__Skyr0NetBuilt or _G.__SXENetBuilt) then
    -- Both flags, so a hub_Mata-derived script loaded alongside this one sees
    -- the Net layer as already built instead of rebuilding it (the build does a
    -- getgc(true) heap sweep -- not something to pay for twice).
    _G.__Skyr0NetBuilt = true
    _G.__SXENetBuilt = true
    local netFolder = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net")
    local getupvalues = debug.getupvalues or getupvalues
    local getinfo = debug.getinfo or getinfo

    local F1, F2, secret

    local function isGuid(s)
        return type(s) == "string" and #s == 36
            and s:match("^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$") ~= nil
    end

    local _bufFromString = buffer.fromstring or function(s)
        local b = buffer.create(#s)
        buffer.writestring(b, 0, s)
        return b
    end

    local _lastBuild, _buildFails = 0, 0
    local function build()
        if F1 and secret then return true end
        -- getgc(true) below walks the ENTIRE Lua heap -- extremely heavy. If a
        -- recent attempt already failed (e.g. the game update broke the hashing-
        -- function detection), skip re-scanning so repeated resolves can't run it
        -- on a loop and tank FPS periodically. Retry at most once every 15s, and
        -- give up entirely after 4 fails (it's broken this session -- the grapple
        -- and clone use the hook-free alias resolver instead, so this isn't needed).
        if _buildFails >= 4 then return false end
        if (os.clock() - _lastBuild) < 15 then return false end
        _lastBuild = os.clock()
        _buildFails = _buildFails + 1   -- counted as a fail; on success F1/secret set + short-circuit above
        local jobId = game.JobId
        local a, b
        local cands, seen = {}, {}
        local _srcMatches = 0
        local _srcSamples = {}
        local _cloneFn = clonefunction or function(f) return f end
        if not getgc then
            warn("[skyr0 Net] build() FAILED - getgc not available")
            return false
        end
        for _, v in getgc(true) do
            if typeof(v) == "function" then
                local ok, info = pcall(getinfo, v)
                if ok and info and info.source then
                    local src = info.source
                    local matched = (src == "=ReplicatedStorage.Packages.Net.Net")
                        or (src:find("ReplicatedStorage", 1, true) and src:find("Net", 1, true))
                    if matched then
                        _srcMatches = _srcMatches + 1
                        if #_srcSamples < 5 then _srcSamples[#_srcSamples + 1] = src end
                        local ok2, ups = pcall(getupvalues, v)
                        if ok2 and ups then
                            for _, up in pairs(ups) do
                                if type(up) == "table" then
                                    local x, y, z = rawget(up, 1), rawget(up, 2), rawget(up, 3)
                                    if not a and type(x) == "function" and type(y) == "function" and type(z) == "string" then
                                        a, b = _cloneFn(x), _cloneFn(y)
                                    end
                                    for _, e in pairs(up) do
                                        if isGuid(e) and e ~= jobId and not seen[e] then seen[e] = true; cands[#cands + 1] = e end
                                    end
                                elseif isGuid(up) and up ~= jobId and not seen[up] then
                                    seen[up] = true; cands[#cands + 1] = up
                                end
                            end
                        end
                    end
                end
            end
        end
        if not a then
            warn("[skyr0 Net] build() FAILED - no hashing functions found.")
            warn("[skyr0 Net] Source matches:", _srcMatches, "Samples:", table.concat(_srcSamples, ", "))
            pcall(function()
                local children = netFolder:GetChildren()
                warn("[skyr0 Net] Net folder has", #children, "children. First few:")
                for i = 1, math.min(5, #children) do
                    warn("[skyr0 Net]   ", children[i].Name)
                end
            end)
            return false
        end
        F1, F2 = a, b
        local cipher = F2("UseItem", jobId)
        if #cands == 1 then secret = cands[1]; print("[skyr0 Net] build() OK (single candidate)"); return true end
        for _, sec in ipairs(cands) do
            local ok, h = pcall(function() return F1(_bufFromString(cipher), _bufFromString(sec .. jobId)) end)
            if ok and type(h) == "string" and netFolder:FindFirstChild("RE/" .. h) then secret = sec; print("[skyr0 Net] build() OK (multi candidate, resolved)"); return true end
        end
        warn("[skyr0 Net] build() FAILED - found", #cands, "GUID candidates but none resolved a valid remote.")
        pcall(function()
            local children = netFolder:GetChildren()
            warn("[skyr0 Net] Net folder has", #children, "children. First few:")
            for i = 1, math.min(5, #children) do
                warn("[skyr0 Net]   ", children[i].Name)
            end
        end)
        return false
    end

    local _resolveWarned = {}
    local function resolve(prefix, name)
        -- 1) Try unhashed direct lookup first (game update exposed many remotes)
        local direct = netFolder:FindFirstChild(prefix .. "/" .. name)
        if direct then return direct end
        -- 2) Try hashing -- but NEVER build it here on demand.
        --
        -- build() is a getgc(true) walk of the entire Lua heap. Letting resolve()
        -- run it lazily meant any caller that missed the direct lookup above
        -- triggered a full heap sweep, from wherever it happened to be standing
        -- -- including from inside a remote fire. That is the periodic stall.
        --
        -- The hasher is still built, once, by the background prewarm that sets
        -- __Skyr0NetAllowBuild around its own call. Everywhere else: if the
        -- hasher is already up, use it (free); if it is not, say so and return
        -- nil rather than paying seconds for it on the spot.
        if not (F1 and secret) then
            if not _G.__Skyr0NetAllowBuild then
                if not _resolveWarned[name] then
                    _resolveWarned[name] = true
                    warn("[skyr0 Net] resolve('" .. name .. "') skipped - hasher not warmed and "
                      .. "on-demand build is disabled (it is a full heap sweep). No unhashed '"
                      .. prefix .. "/" .. name .. "' either.")
                end
                return nil
            end
            if not build() then
                if not _resolveWarned[name] then
                    _resolveWarned[name] = true
                    warn("[skyr0 Net] resolve('" .. name .. "') FAILED - build() failed and no unhashed '" .. prefix .. "/" .. name .. "' found.")
                end
                return nil
            end
        end
        local jobId = game.JobId
        local ok, h = pcall(function()
            local c = F2(name, jobId)
            return F1(_bufFromString(c), _bufFromString(secret .. jobId))
        end)
        if not ok or type(h) ~= "string" then
            if not _resolveWarned[name] then
                _resolveWarned[name] = true
                warn("[skyr0 Net] resolve('" .. name .. "') FAILED - hash error:", tostring(h))
            end
            return nil
        end
        local remote = netFolder:FindFirstChild(prefix .. "/" .. h)
        if not remote then
            if not _resolveWarned[name] then
                _resolveWarned[name] = true
                warn("[skyr0 Net] resolve('" .. name .. "') FAILED - remote '" .. prefix .. "/" .. h .. "' not found in Net folder.")
            end
            return nil
        end
        return remote
    end

    -- Universal remote getter: tries RE, RF, URE prefixes (unhashed then hashed)
    local function getRemoteAny(name)
        for _, pfx in ipairs({"RE", "RF", "URE"}) do
            local r = resolve(pfx, name)
            if r then return r end
        end
        return nil
    end

_G.Net = {
        RemoteEvent           = function(_, name) return resolve("RE", name) end,
        RemoteFunction        = function(_, name) return resolve("RF", name) end,
        UnreliableRemoteEvent = function(_, name) return resolve("URE", name) end,
        GetRemote             = function(_, name) return getRemoteAny(name) end,
    }

    -- Helper: fire any remote (RemoteEvent or RemoteFunction) with args
    _G.Net.FireServer = function(_, name, ...)
        local r = getRemoteAny(name)
        if not r then return false end
        local args = {...}
        if r:IsA("RemoteFunction") then
            return pcall(function() return r:InvokeServer(table.unpack(args)) end)
        else
            return pcall(function() r:FireServer(table.unpack(args)) end)
        end
    end
  end -- closes if not __Skyr0NetBuilt
end -- closes do

-- =====================================================================
-- HEAP-SWEEP GATE -- one getgc(true) at a time, and never during the load
-- ---------------------------------------------------------------------
-- Two separate prewarms in this file each run getgc(true), a full walk of the
-- Lua heap that this file's own Net builder calls "extremely heavy": the Net
-- hasher build() and Skyr0BuildPMRefs(deep). They were scheduled on bare
-- task.wait(4) and task.wait(3) -- ONE SECOND APART, both landing mid-loading-
-- screen, back to back, on a client already down at ~7fps. Two full heap walks
-- stacked on the worst frames of the session is the "lag on execute".
--
-- The gate does two things:
--   * SERIALISES them, so the second walk cannot start while the first still
--     has the heap.
--   * Waits for the client to be IDLE -- game:IsLoaded() plus a short settle --
--     instead of firing on a fixed timer. Neither prewarm is needed during the
--     load: the grapple's PlayerMouse refs are only read when you actually
--     fire, and every remote lookup tries the structural folder-read resolver
--     before it ever falls back to the hashed one.
--
-- Both prewarms still happen, and still off the hot path. They just no longer
-- happen ON TOP OF the load. Callers stay non-blocking -- this returns
-- immediately and does the work on its own thread.
-- =====================================================================
-- maxWait caps how long a sweep will hold out for game:IsLoaded(). Anything the
-- hub needs DURING the load (the grapple's PlayerMouse refs -- TP-on-load fires
-- while the loading screen is still up) passes a short cap so it is ready in
-- time; anything that can wait passes none. Serialisation applies either way,
-- so the worst case is one heap walk during the load instead of two.
_G.__Skyr0HeapBusy = false   -- reset on every execute: last run's threads are gone
_G.__Skyr0HeapSweep = function(name, fn, maxWait)
    task.spawn(function()
        -- Polled, never game.Loaded:Wait(). That signal fires ONCE, so a :Wait()
        -- entered after loading finished blocks forever -- the same trap the
        -- EARLY BOOT header at the top of this file warns about.
        local cap = tonumber(maxWait) or 60
        local t0 = os.clock()
        while not game:IsLoaded() and os.clock() - t0 < cap do task.wait(0.25) end

        -- NEVER DURING A TELEPORT.
        --
        -- TP-on-load fires within a few seconds of execute, which is the same
        -- window these prewarms live in -- so the PlayerMouse sweep was landing
        -- mid-flight and getgc(true) stalled the frames the teleport was using.
        -- That is the "fps drops on tp on load". A flight is seconds long and a
        -- sweep can always wait; the reverse is not true.
        --
        -- The TP side of this exclusion is in Skyr0LaunchTP, which waits for
        -- __Skyr0HeapBusy to clear before it commits -- so the two can never
        -- overlap from either direction.
        -- __Skyr0TPPending as well as the cycle latch: pending is raised the
        -- INSTANT a launch is armed, which is well before the cycle starts, so
        -- this is what actually keeps a sweep from opening in front of a
        -- teleport. Both are timestamps with their own reclaim, and this wait is
        -- bounded, so nothing here can strand a prewarm forever.
        local tp0 = os.clock()
        local function _tpBusy()
            if _G.__Skyr0CicloRodando then return true end
            local pend = _G.__Skyr0TPPending
            return type(pend) == "number" and (os.clock() - pend) < 45
        end
        while _tpBusy() and os.clock() - tp0 < 45 do task.wait(0.1) end

        -- take our turn (bounded, so a leaked flag cannot deadlock the prewarm)
        local w0 = os.clock()
        while _G.__Skyr0HeapBusy and os.clock() - w0 < 60 do task.wait(0.1) end
        _G.__Skyr0HeapBusy = true

        -- Let frame times settle before seizing the heap -- and keep watching
        -- for a teleport while we do.
        --
        -- The TP check above and Skyr0LaunchTP's own wait can clear in the same
        -- instant, so a flight can still start just after we claimed the slot.
        -- If that happens, hand the slot back and wait the flight out rather
        -- than sweeping into it. Capped, so this can never spin forever.
        local RunSvc = game:GetService("RunService")
        local tries = 0
        while tries < 5 do
            tries = tries + 1
            local clear = true
            for _ = 1, 20 do
                RunSvc.Heartbeat:Wait()
                if _tpBusy() then clear = false; break end
            end
            if clear then break end
            _G.__Skyr0HeapBusy = false
            local r0 = os.clock()
            while _tpBusy() and os.clock() - r0 < 45 do task.wait(0.1) end
            _G.__Skyr0HeapBusy = true
        end

        local ok, err = pcall(fn)
        _G.__Skyr0HeapBusy = false
        if not ok then
            warn("[skyr0] heap prewarm '" .. tostring(name) .. "' failed:", err)
        end
    end)
end

-- Warm the Net hasher in the BACKGROUND, once, after the load.
--
-- resolve() lazily calls build(), and build() does a getgc(true) heap sweep --
-- seconds on a loaded game. Whoever asked for the first remote paid that bill,
-- and in practice that was a teleport: press the key, stall, then fly. Doing it
-- here means every later lookup is a cache hit.
--
-- The name asked for is irrelevant -- the point is to make build() run once.
_G.__Skyr0HeapSweep("net-hasher", function()
    -- ...and often the point is to NOT run it. Skyr0GetRemote resolves remotes
    -- structurally FIRST (the dual-hash folder read, microseconds) and only
    -- falls back to the hashed _G.Net path when that fails. So on any server
    -- where the fingerprint resolves -- the normal case -- build()'s heap walk
    -- buys nothing, and the cheapest heap sweep is the one that never happens.
    if type(_G.Skyr0FindUseItem) == "function" then
        local okD, d = pcall(_G.Skyr0FindUseItem)
        if okD and d then return end
    end
    -- The ONE place allowed to run build(). resolve() refuses to do it on demand
    -- (see the note there) precisely so it can only ever happen here: once, on a
    -- background thread, after the load, through the heap gate.
    _G.__Skyr0NetAllowBuild = true
    pcall(function()
        if _G.Net and _G.Net.GetRemote then _G.Net:GetRemote("UseItem") end
    end)
    _G.__Skyr0NetAllowBuild = false
end)

-- Always patch _G.Net with GetRemote/FireServer (survives re-exec when __Skyr0NetBuilt is already true)
do
    local _netFolder = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net")
    local function _resolveAny(prefix, name)
        local direct = _netFolder:FindFirstChild(prefix .. "/" .. name)
        if direct then return direct end
        return nil
    end
    local function _getRemoteAny(name)
        for _, pfx in ipairs({"RE", "RF", "URE"}) do
            local r = _resolveAny(pfx, name)
            if r then return r end
        end
        -- Try hashed resolution if available
        if _G.Net and _G.Net.RemoteEvent then
            for _, pfx in ipairs({"RE", "RF", "URE"}) do
                local r = _G.Net[pfx == "RE" and "RemoteEvent" or (pfx == "RF" and "RemoteFunction" or "UnreliableRemoteEvent")]
                if r then
                    local ok, remote = pcall(r, _G.Net, name)
                    if ok and remote then return remote end
                end
            end
        end
        return nil
    end
    if _G.Net then
        _G.Net.GetRemote = function(_, name) return _getRemoteAny(name) end
        _G.Net.FireServer = function(_, name, ...)
            local r = _getRemoteAny(name)
            if not r then return false end
            local args = {...}
            if r:IsA("RemoteFunction") then
                return pcall(function() return r:InvokeServer(table.unpack(args)) end)
            else
                return pcall(function() r:FireServer(table.unpack(args)) end)
            end
        end
        -- Patch RemoteEvent to cross-prefix fallback when hashed resolution fails
        local _origRE = _G.Net.RemoteEvent
        _G.Net.RemoteEvent = function(_, name)
            local r = _origRE and _origRE(_, name)
            if r then return r end
            return _getRemoteAny(name)
        end
    end
end

-- FPS UNLOCK / optimizer (hub_Mata's version). The old line here set the cap
-- ONCE at load; some game/engine paths silently re-cap the framerate later, and
-- a one-shot call has no answer to that. A light keeper re-applies it every 2s.
-- Override with _G.Skyr0_FPS_CAP before load (0 = unlimited, or a number to cap);
-- _G.SXE_FPS_CAP is honoured too so hub_Mata configs carry over unchanged.
_G.Skyr0_FPS_CAP = _G.Skyr0_FPS_CAP or _G.SXE_FPS_CAP or 999
do
    local function applyCap()
        if not setfpscap then return end
        pcall(setfpscap, tonumber(_G.Skyr0_FPS_CAP) or tonumber(_G.SXE_FPS_CAP) or 999)
    end
    applyCap()
    task.spawn(function()
        while true do
            applyCap()
            task.wait(2)
        end
    end)
end

-- INSTA-RESET REMOVED. The reset GUID generator, the reset-remote state and the
-- `_G.Skyr0_RESET_REMOTE` resolver that used to live here are gone -- the hub no
-- longer resolves, stores or fires any reset remote, and logs nothing about it.

local function makeOneWay(plat)
    if not plat then return end
    local rsConn
    local lastY = nil
    rsConn = game:GetService("RunService").Stepped:Connect(function()
        if not plat or not plat.Parent then
            if rsConn then rsConn:Disconnect() end
            return
        end
        local char = game.Players.LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local currentY = hrp.Position.Y
            if not lastY then lastY = currentY end
            
            local deltaY = currentY - lastY
            local isMovingUp = (hrp.AssemblyLinearVelocity.Y > 1) or (deltaY > 0.01 and deltaY < 5)
            
            if isMovingUp then
                plat.CanCollide = false
            else
                if currentY > plat.Position.Y + 0.1 then
                    plat.CanCollide = true
                else
                    plat.CanCollide = false
                end
            end
            
            lastY = currentY
        end
    end)
end

-- HOOK REMOVED. This used to hookfunction(FireServer) to (a) capture the first
-- RE/* the game fires as the insta-reset target and (b) drop outgoing
-- "StopTrying" messages. The game update added an anti-cheat canary that
-- integrity-checks the remote-fire path, so ANY FireServer/__namecall hook now
-- flags the account (the "Unable to cast Array to bool" error). Going hook-free
-- is the only way to stay undetected. The insta-reset feature itself has since
-- been removed entirely, so nothing here captures or pins a reset remote.


-- =====================================================================
-- SYNCHRONIZER BYPASS -- secure_call (thread-identity swap)   [ported]
-- ---------------------------------------------------------------------
-- Ported from the reference hub. Runs a function under the IDENTITY of
-- RS.Controllers.PlotController: setthreadidentity(2) + a coroutine hop
-- through a loadstring-built trampoline whose fenv is the masked script's own
-- env (getsenv), plus a temporary swap of any LuaSourceContainer upvalue for
-- the mask. Anything the module gates on "which script is asking" -- the
-- Synchronizer's RelateChannels snitch above all -- sees PlotController and
-- stays quiet, so the registry can be read without tripping it.
--
-- READ-ONLY on the game side: the upvalue swap is restored on the way out and
-- the thread identity is put back to whatever it was. No hookfunction, no
-- __namecall -- nothing the remote-fire canary integrity-checks.
--
-- Exports: _G.secure_call(func, mask, ...) and _G.VanishGetMask().
-- Wrapped in do..end (and given its own RS) because this fork keeps
-- ReplicatedStorage in a global, not a file-level RS local.
-- =====================================================================
do
local RS = game:GetService("ReplicatedStorage")
-- ===== RESOLUTION REMOTE : FORCAGE PUR (secure_call) =====
-- Plus de lecture passive / hook / folder-scan. Tout est resolu activement via
-- Net.RemoteEvent(name) execute sous l'identite de PlotController (setthreadidentity
-- + setfenv). mask = RS.Controllers.PlotController. Net = require(RS.Packages.Net).
-- Retry ping-safe: si le jeu renvoie le decoy (mapping pas pret), on re-tente.
local secure_call
do
    local LAYERS = 2
    local TEMPLATE do
        local lines = {
            "return function(__renv, __func, ...)",
            "    setfenv(0, __renv)",
            ("    local function l%d(...) return __func(...) end"):format(LAYERS),
        }
        for c = LAYERS - 1, 1, -1 do
            lines[#lines + 1] = ("    local function l%d(...) return l%d(...) end"):format(c, c + 1)
        end
        lines[#lines + 1] = "    return l1(...)"
        lines[#lines + 1] = "end"
        TEMPLATE = table.concat(lines, string.char(10))
    end
    local _gti = getthreadidentity or get_thread_identity or getidentity
    local _sti = setthreadidentity or set_thread_identity or setidentity
    local _sentinel, _senv
    secure_call = function(func, mask, ...)
        if type(func) ~= "function" or typeof(mask) ~= "Instance" then return nil end
        if not (_gti and _sti and getrenv and loadstring and setfenv) then return nil end
        local renv = getrenv()
        if not _sentinel then
            local ok, env = pcall(getsenv, mask)
            if not ok or type(env) ~= "table" then
                env = setmetatable({ script = mask, _G = {}, shared = {} }, { __index = renv, __newindex = renv })
            end
            local loader = loadstring(TEMPLATE, "=" .. mask:GetFullName())
            if not loader then return nil end
            setfenv(loader, env)
            _sentinel, _senv = loader(), env
        end
        local level = _gti()
        local changed = {}
        local okU, snap = pcall(debug.getupvalues, func)
        if okU and type(snap) == "table" then
            for i, v in pairs(snap) do
                if typeof(v) == "Instance" and v:IsA("LuaSourceContainer") then
                    if pcall(debug.setupvalue, func, i, mask) then changed[i] = v end
                end
            end
        end
        _sti(2)
        local co, args = coroutine.create(_sentinel), table.pack(renv, func, ...)
        local response, err
        while true do
            local r = table.pack(coroutine.resume(co, table.unpack(args, 1, args.n)))
            if not r[1] then err = r[2] break end
            if coroutine.status(co) == "dead" then
                response = table.pack(table.unpack(r, 2, r.n)) break
            end
            args = table.pack(coroutine.yield(table.unpack(r, 2, r.n)))
        end
        _sti(level)
        for i, orig in pairs(changed) do pcall(debug.setupvalue, func, i, orig) end
        if err or not response then return nil end
        return table.unpack(response, 1, response.n)
    end
end
_G.secure_call = secure_call

local _sc_mask
local function _sc_getMask()
    if _sc_mask and _sc_mask.Parent then return _sc_mask end
    local c = RS:FindFirstChild("Controllers") or RS:WaitForChild("Controllers", 10)
    _sc_mask = c and (c:FindFirstChild("PlotController") or c:WaitForChild("PlotController", 10))
    return _sc_mask
end
_G.VanishGetMask = _sc_getMask
end

-- =====================================================================
-- USEITEM REMOTE RESOLVER  (HOOK-FREE -- dual-hash resolve + saved payload)
-- ---------------------------------------------------------------------
-- The grapple/Quantum Cloner fire RE/UseItem, but the functional remote is
-- HASH-NAMED and the hash ROTATES every server join. The plaintext "RE/UseItem"
-- entry is a DEAD alias -- firing it does nothing.
--
-- Resolution history (each broke in turn):
--   1. FindFirstChild("RE/UseItem")      -> returns the dead alias.
--   2. Adjacency ([hashed][plaintext])   -> the update moved all plaintext
--      aliases into their OWN region (alias at index ~397, real remote at ~6),
--      so the pairing no longer exists.
--   3. The game's own hash function      -> getgc can no longer locate F1/F2.
--
-- What still works: PASSIVE CAPTURE. A __namecall hook watches for the game
-- firing a hash-named RE with a single number arg while the Grapple Hook is
-- equipped -- that is unambiguously the grapple -- and remembers it for the
-- session (hash is stable until you rejoin). Cached in _G so it survives
-- script re-execution. Adjacency + Net module are kept as fallbacks in case a
-- future update restores them.
--
-- The arg is a FLOAT (grapple distance/time), NOT the old int 2.
-- =====================================================================
_G.Skyr0GrappleValue = _G.Skyr0GrappleValue or 0.33  -- live-tunable grapple distance value
_G.__Skyr0UseItemPayload = _G.__Skyr0UseItemPayload or nil
do
    local RS = game:GetService("ReplicatedStorage")
    local netFolder = RS:WaitForChild("Packages"):WaitForChild("Net")
    local PAYLOAD_FILE = "skyr0_grapple_payload.txt"

    local function isHashName(nm)
        return type(nm) == "string"
            and (nm:match("^RE/%x%x%x%x%x%x%x%x") or nm:match("^RF/%x%x%x%x%x%x%x%x")) ~= nil
    end
    local function isHashRemote(ch, className)
        return ch and ch:IsA(className) and isHashName(ch.Name)
    end

    -- =====================================================================
    -- HOOK-FREE (the game update added an anti-cheat canary that integrity-
    -- checks __namecall -- the old passive-capture hook here tripped it, which
    -- produced the "Unable to cast Array to bool" error in AssetStreamController
    -- and flagged the account even without firing). So: NO hooks. The remote is
    -- found structurally (dual-hash) and the payload is read from the file the
    -- standalone tester saved. Both are pure reads -- nothing to canary.
    -- =====================================================================

    -- DUAL-HASH FINGERPRINT: "UseItem" is the ONLY name the game registers as
    -- both an RF and an RE, so the one hash that exists as both RF/<h> and
    -- RE/<h> IS UseItem. Structural, not an ordering guess -> survives the
    -- per-join hash rotation and the folder reshuffle with no hook, no manual
    -- fire. Returns nil unless the match is UNAMBIGUOUS (exactly one).
    local _dualCache
    local function findUseItemByDualHash()
        if _dualCache and _dualCache.Parent then return _dualCache end
        local reH, rfH = {}, {}
        for _, ch in ipairs(netFolder:GetChildren()) do
            local nm = ch.Name
            if type(nm) == "string" then
                local pfx, rest = nm:match("^(R[EF])/(.+)$")
                if pfx and rest and #rest >= 32 and rest:match("^%x%x%x%x%x%x%x%x") then
                    if pfx == "RE" then reH[rest] = ch else rfH[rest] = ch end
                end
            end
        end
        local found, count = nil, 0
        for h, ch in pairs(reH) do
            if rfH[h] then count = count + 1; found = ch end
        end
        if count == 1 then _dualCache = found; return found end
        return nil   -- ambiguous: do not guess
    end
    _G.Skyr0FindUseItem = findUseItemByDualHash

    -- Resolve the live hashed remote for a plaintext name (hook-free).
    local function resolveHashed(name, className)
        className = className or "RemoteEvent"
        if name == "UseItem" then
            -- dual-hash fingerprint (deterministic, no hook, no manual fire)
            local d = findUseItemByDualHash()
            if d then return d end
        end
        local prefix = (className == "RemoteFunction") and "RF/" or "RE/"
        -- adjacency (works only if a future update restores the pairing)
        local children = netFolder:GetChildren()
        local aliasIdx
        for i, ch in ipairs(children) do
            if ch.Name == prefix .. name and ch:IsA(className) then aliasIdx = i; break end
        end
        if aliasIdx then
            if isHashRemote(children[aliasIdx - 1], className) then return children[aliasIdx - 1] end
            if isHashRemote(children[aliasIdx + 1], className) then return children[aliasIdx + 1] end
        end
        -- The game's own Net-module hasher used to be the last step here. It is
        -- GONE, for the same reason it is gone from Skyr0GetRemote: _G.Net
        -- resolves lazily, which runs build(), which is a getgc(true) walk of
        -- the whole Lua heap. Reaching that from a resolve meant a name that
        -- does not resolve structurally paid a full heap sweep -- on a path that
        -- runs when remotes fire. Structural resolution only from here on.
        return nil
    end
    _G.Skyr0ResolveHashed = resolveHashed

    -- =====================================================================
    -- NARROW RESOLVER -- direct lookup + UseItem. NOTHING ELSE.
    -- ---------------------------------------------------------------------
    -- This was a generalised "one resolver for every remote fire" with a
    -- four-step fallback chain, and steps 2 and 3 of that chain called into
    -- _G.Net:GetRemote / _G.Net:RemoteEvent. Those resolve lazily -- meaning
    -- they run build(), and build() does a getgc(true) walk of the ENTIRE Lua
    -- heap. So any remote whose name did not resolve structurally paid a full
    -- heap sweep, and a name that NEVER resolves paid it again every 15s
    -- forever. That is the stall on every remote fire.
    --
    -- The generalisation also was not earning its keep: the only live caller in
    -- this file is the steal path, which asks for a GUID-named remote -- and a
    -- GUID IS the folder's own key, so a plain FindFirstChild answers it.
    --
    -- What is left is only what is actually needed:
    --   * DIRECT folder lookup -- "RE/<name>", "RF/<name>", or the bare name.
    --     Answers GUID-named remotes and anything already hash-named.
    --   * UseItem, via the dual-hash fingerprint -- the one name the game
    --     registers as BOTH an RE and an RF, so the hash that exists under both
    --     prefixes is it. Pure folder read, survives the per-join rotation.
    --
    -- Nothing here can reach build(). No getgc, no heap sweep, no hidden cost
    -- on a fire path. If a name needs the game's own hasher, ask _G.Net
    -- directly and accept that it may pay for a sweep -- but do it deliberately,
    -- off a hot path, not by accident from inside a remote fire.
    --
    -- The cache is keyed by JobId so rejoining cannot serve a remote belonging
    -- to the previous server's hash.
    _G.__Skyr0RemoteCache = _G.__Skyr0RemoteCache or {}
    _G.__Skyr0RemoteJob   = _G.__Skyr0RemoteJob or game.JobId

    _G.Skyr0GetRemote = function(name, className)
        if type(name) ~= "string" or name == "" then return nil, false end
        className = className or "RemoteEvent"

        -- drop the whole cache if the server changed under us
        if _G.__Skyr0RemoteJob ~= game.JobId then
            _G.__Skyr0RemoteCache = {}
            _G.__Skyr0RemoteJob = game.JobId
        end
        local ck = className .. "|" .. name
        local hit = _G.__Skyr0RemoteCache[ck]
        if hit and typeof(hit) == "Instance" and hit.Parent then return hit, true end

        local prefix = (className == "RemoteFunction") and "RF/" or "RE/"

        -- 1. DIRECT. Three FindFirstChild calls, no allocation, no scan. This is
        --    what resolves the steal GUID and any already-hashed name.
        local found = netFolder:FindFirstChild(prefix .. name)
        if found and not found:IsA(className) then found = nil end
        if not found then
            local bare = netFolder:FindFirstChild(name)
            if bare and bare:IsA(className) then found = bare end
        end

        -- 2. USEITEM ONLY. The plaintext RE/UseItem entry is a dead alias, so a
        --    direct hit on it above is worthless -- the dual-hash fingerprint is
        --    the real one. Checked after the direct lookup and only for this one
        --    name, because it is the only name that needs it.
        if name == "UseItem" then
            local okD, d = pcall(findUseItemByDualHash)
            if okD and typeof(d) == "Instance" and d:IsA(className) then found = d end
        end

        if found then
            -- Only a hash/GUID-named instance is a REAL remote; a plaintext
            -- alias is a stub. Cache the real ones, hand back stubs uncached and
            -- flagged false so a caller can retry or fall back.
            if isHashName(found.Name) or found.Name:find("-", 1, true) then
                _G.__Skyr0RemoteCache[ck] = found
                return found, true
            end
            return found, false
        end
        return nil, false
    end

    -- Resolve + fire in one call. Returns false when nothing real was reached,
    -- so a caller can fall back (e.g. auto-buy dropping to fireproximityprompt)
    -- instead of assuming the fire landed.
    _G.Skyr0FireRemote = function(name, ...)
        local r, real = _G.Skyr0GetRemote(name, "RemoteEvent")
        if not r or not real then return false end
        local args = table.pack(...)
        return (pcall(function() r:FireServer(table.unpack(args, 1, args.n)) end))
    end

    _G.Skyr0InvokeRemote = function(name, ...)
        local r, real = _G.Skyr0GetRemote(name, "RemoteFunction")
        if not r or not real then return false, nil end
        local args = table.pack(...)
        local ok, res = pcall(function() return r:InvokeServer(table.unpack(args, 1, args.n)) end)
        return ok, res
    end

    -- PAYLOAD: replay the exact args a legit grapple sends. The standalone
    -- tester learns them from your own manual grapple (once) and saves them to
    -- PAYLOAD_FILE; here we just read that file -- no hook needed. Set
    -- _G.Skyr0_GRAPPLE_PAYLOAD = { [1]=<num>, n=1 } to override without a file.
    local function loadPersistedPayload()
        if _G.Skyr0_GRAPPLE_PAYLOAD then return _G.Skyr0_GRAPPLE_PAYLOAD end
        if not (readfile and isfile) then return nil end
        local ok, res = pcall(function()
            if not isfile(PAYLOAD_FILE) then return nil end
            local raw = readfile(PAYLOAD_FILE)
            local lines = {}
            for line in raw:gmatch("[^\n]+") do lines[#lines + 1] = line end
            local n = tonumber(lines[1]); if not n then return nil end
            local p = { n = n }
            for i = 1, n do
                local ln = lines[i + 1] or ""
                local tag, rest = ln:sub(1, 2), ln:sub(3)
                if tag == "s:" then p[i] = rest
                elseif tag == "n:" then p[i] = tonumber(rest)
                elseif tag == "b:" then p[i] = (rest == "true")
                else p[i] = nil end
            end
            return p
        end)
        return ok and res or nil
    end
    _G.__Skyr0UseItemPayload = loadPersistedPayload()

    -- WARM-UP: the Net folder is still streaming in when TP-on-load fires, so an
    -- early fingerprint scan sees an incomplete folder and returns nil. Resolve
    -- it in the background so it's cached and ready before the first TP.
    task.spawn(function()
        local t0 = os.clock()
        while os.clock() - t0 < 60 do
            if findUseItemByDualHash() then
                warn("[skyr0] UseItem resolved: " .. _G.Skyr0FindUseItem().Name)
                return
            end
            task.wait(0.25)
        end
    end)

    -- =====================================================================
    -- THE SHOT ITSELF (shared by both aiming modes)
    -- ---------------------------------------------------------------------
    -- Writes the aim into every live PlayerMouse table AND rotates the camera,
    -- calls Activate(), and HOLDS that state for 4 frames before returning.
    --
    -- Those 4 frames are the critical part: SignalBehavior = Deferred is the
    -- Roblox default, so Activate() only QUEUES the item handler -- it runs at
    -- the end of the frame. Restoring on the next line meant the item script
    -- read the already-reverted state and aimed at the cursor instead.
    -- =====================================================================
    -- =====================================================================
    -- AIM TARGETS -- built ONCE, IN THE BACKGROUND. Never inline.
    -- ---------------------------------------------------------------------
    -- This used to do the getgc(true) heap sweep on the FIRST grapple fire,
    -- synchronously, in the middle of the keybind path. getgc(true) walks the
    -- ENTIRE Lua heap -- this file's own Net builder calls it "extremely heavy"
    -- -- and on a loaded game that is many seconds. THAT is the "fires the
    -- grapple then waits ~15 seconds" stall: it was a one-off cost, paid the
    -- first time you pressed the key, right where you would feel it most.
    --
    -- Split in two now:
    --   cheap  -- require(PlayerMouse). Instant, always safe to do inline.
    --   deep   -- the heap sweep, which finds the OTHER live PlayerMouse-shaped
    --             tables (the executor's require cache is separate from the
    --             game's, so the module the item reads may not be the one we
    --             get back). Runs on a background thread shortly after load.
    --
    -- If the deep pass has not finished when you fire, the cheap refs are used
    -- and the shot still happens immediately.
    -- =====================================================================
    _G.Skyr0BuildPMRefs = function(deep)
        local refs = _G.__Skyr0PMRefs or {}
        local vistos = {}
        for _, t in ipairs(refs) do vistos[t] = true end
        local function juntar(t)
            if type(t) == "table" and not vistos[t] then
                vistos[t] = true; refs[#refs + 1] = t
            end
        end
        pcall(function()
            juntar(require(game:GetService("ReplicatedStorage").Packages.PlayerMouse))
        end)
        _G.__Skyr0PMRefs = refs          -- usable from here on, deep or not
        if deep and not _G.__Skyr0PMRefsDeep and getgc then
            pcall(function()
                for _, v in ipairs(getgc(true)) do
                    if type(v) == "table" and typeof(rawget(v, "Hit")) == "CFrame" then
                        local n = 0
                        for _ in pairs(v) do n = n + 1 end
                        if n <= 3 then juntar(v) end
                    end
                end
            end)
            _G.__Skyr0PMRefsDeep = true
        end
        return refs
    end

    -- Warm it off the hot path, through the shared heap gate (defined with the
    -- Net builder above). This used to be a bare task.wait(3), which put its
    -- getgc(true) walk one second before the Net builder's -- two full heap
    -- sweeps back to back, in the middle of the loading screen. The gate waits
    -- for game:IsLoaded() and lets only one walk run at a time.
    --
    -- SHORT CAP (4s), unlike the Net prewarm, and deliberately so. TP-on-load
    -- fires the grapple WHILE the loading screen is still up, and the deep pass
    -- is what finds the OTHER live PlayerMouse tables -- the executor's require
    -- cache is separate from the game's, so the module the item actually reads
    -- may not be the one the cheap path returns. That is the "aim kept following
    -- the mouse" bug. Waiting for game:IsLoaded() here would hand the first shot
    -- of the session cheap-refs-only, which is safe and instant but can miss.
    --
    -- So: hold out for an idle client for at most 4s, then go anyway. Worst case
    -- is ONE heap walk during the load rather than the two that used to stack
    -- here -- and the Net sweep, serialised behind this one, usually skips
    -- entirely because the structural resolver already answered.
    _G.__Skyr0HeapSweep("playermouse-refs", function()
        _G.Skyr0BuildPMRefs(true)
    end, 4)

    _G.__Skyr0GrappleDisparar = function(tool, pos, alvo, char, RSv)
        -- CHEAP BUILD ONLY. The getgc(true) heap sweep that used to be inlined
        -- here is what froze the game on the first teleport: it walks the ENTIRE
        -- Lua heap -- this file's own Net builder calls that "extremely heavy" --
        -- and TP-on-load fires the grapple, so you paid it on every fresh
        -- execute, right at load.
        --
        -- The split already exists above: require(PlayerMouse) is instant and
        -- safe inline, and the deep sweep runs once in the background 3s after
        -- load (see the warm-up thread). If it has not finished when you fire,
        -- the cheap refs are used and the shot still happens immediately.
        local refs = _G.__Skyr0PMRefs
        if not refs or #refs == 0 then refs = _G.Skyr0BuildPMRefs(false) end

        -- mira pela camera: o HookScript monta o raio a partir de
        -- GetMouseLocation() + camera, entao giramos a camera de modo
        -- que o raio do cursor -- onde quer que ele esteja -- aponte
        -- pro nosso ponto
        local cam = workspace.CurrentCamera
        local camAntes = cam and cam.CFrame
        local camNova
        if cam then
            pcall(function()
                local m = game:GetService("UserInputService"):GetMouseLocation()
                local raio = cam:ViewportPointToRay(m.X, m.Y)
                local L = cam.CFrame:VectorToObjectSpace(raio.Direction).Unit
                local d = pos - cam.CFrame.Position
                if d.Magnitude > 0.01 then
                    d = d.Unit
                    camNova = CFrame.new(cam.CFrame.Position)
                            * (CFrame.lookAt(Vector3.zero, d)
                             * CFrame.lookAt(Vector3.zero, L):Inverse())
                end
            end)
        end

        local mira = CFrame.new(pos)
        local antes = {}
        for i, t in ipairs(refs) do
            antes[i] = { rawget(t, "Hit"), rawget(t, "Target") }
            pcall(function() t.Hit = mira; t.Target = alvo end)
        end
        if camNova then cam.CFrame = camNova end

        local ok = pcall(function() tool:Activate() end)
        if not ok then ok = pcall(function() firesignal(tool.Activated) end) end

        task.spawn(function()
            local RSvc = game:GetService("RunService")
            for _ = 1, 4 do
                if camNova and cam then cam.CFrame = camNova end
                for _, t in ipairs(refs) do
                    pcall(function() t.Hit = mira; t.Target = alvo end)
                end
                RSvc.Heartbeat:Wait()
            end
            if camNova and cam and camAntes then cam.CFrame = camAntes end
            for i, t in ipairs(refs) do
                local a = antes[i]
                pcall(function() t.Hit = a[1]; t.Target = a[2] end)
            end
        end)

        return ok
    end

    -- =====================================================================
    -- FIRE THE GRAPPLE -- TOOL ACTIVATE  (the SECONDARY path)
    -- ---------------------------------------------------------------------
    -- NOT the default any more. USETHISTP's remote fire is primary (see
    -- Skyr0FireGrapple2 below); this stays reachable because it is the version
    -- that demonstrably fired when the remote replay did not. Flip to it at
    -- runtime with:   _G.Skyr0GrappleUseTool = true
    --
    -- It works by driving the tool's own Activated signal and letting
    -- the item script build the call itself -- which is why the aim has to be
    -- written into every live PlayerMouse table FIRST, in the same frame, with
    -- no yield in between, and HELD for 4 frames afterwards (SignalBehavior is
    -- Deferred by default, so Activate() only queues the handler).
    --
    -- The remote is still RESOLVED at the top as a readiness gate -- if UseItem
    -- has not replicated yet the item is not usable either -- but it is never
    -- fired.
    -- =====================================================================
    -- Fire the grapple HOOK-FREE.
    --
    -- value: nil            -> aim along the character's LookVector (legacy call
    --                          sites that fire with no arguments)
    --        Vector3/BasePart -> SEARCH mode: flatten the direction to the target
    --                          and pick the CLOSEST bit of ground the item will
    --                          accept (10-50 studs)
    -- exato: true + Vector3 -> EXACT mode: use the point as given, no search
    --
    -- Replaying the captured payload never worked (the Grapple HookScript is
    -- Luraph-obfuscated and its signature is not the one its plaintext siblings
    -- use). What works is driving Activated and letting the item's OWN script
    -- build the call -- which is why the aim has to be written first.
    _G.Skyr0FireGrappleTool = function(value, exato)
        local r = resolveHashed("UseItem", "RemoteEvent")
        -- Short bounded retry: on a fresh join the folder may still be
        -- replicating, so don't give up on the very first miss. 0.4s, not 1.5s
        -- -- a warm session resolves on the first try and a cold one falls back
        -- to the plain TP, so a long budget only added latency to the keybind.
        if not r then
            local t0 = os.clock()
            repeat
                task.wait(0.05)
                r = resolveHashed("UseItem", "RemoteEvent")
            until r or (os.clock() - t0) > 1.5
        end
        if not r then
            if not _G.__Skyr0GrappleWarned then
                _G.__Skyr0GrappleWarned = true
                warn("[skyr0] Grapple remote unresolved (Net folder still streaming?)")
            end
            return false
        end

        local RSv = game:GetService("ReplicatedStorage")
        local Plrs = game:GetService("Players")
        local eu = Plrs.LocalPlayer
        local char = eu and eu.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return false end

        if eu:GetAttribute("Stealing") then return false end

        -- EQUIP THE TOOL IF NEEDED. This has to happen HERE, before anything
        -- else: further down, between writing the aim and calling Activate(),
        -- there must be no yield at all.
        local tool = char:FindFirstChild("Grapple Hook")
        if not tool then
            local bp = eu:FindFirstChildOfClass("Backpack")
            local t2 = bp and bp:FindFirstChild("Grapple Hook")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not t2 or not hum then return false end
            pcall(function() hum:EquipTool(t2) end)
            -- 0.25s: an equip that has not landed in ~15 frames is not going to,
            -- and this sits directly between the keypress and any movement.
            local t0 = os.clock()
            repeat
                game:GetService("RunService").Heartbeat:Wait()
                char = eu.Character
                tool = char and char:FindFirstChild("Grapple Hook")
            until tool or os.clock() - t0 > 0.5
            if not tool then return false end
            hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return false end
        end

        local par0 = RaycastParams.new()
        par0.FilterType = Enum.RaycastFilterType.Exclude
        par0.FilterDescendantsInstances = { char }

        -- EXACT AIM. Without this the search code below FLATTENS the direction
        -- onto XZ and hunts for ground 45/38/31 studs out HORIZONTALLY. With a
        -- target right under your feet the horizontal direction is ~zero, it
        -- falls back to the LookVector and fires diagonally forwards.
        if exato and typeof(value) == "Vector3" then
            local pos = value
            local m = (pos - hrp.Position).Magnitude
            if m < 10 or m > 50 then return false end

            local alvo
            local hit = workspace:Raycast(hrp.Position, pos - hrp.Position, par0)
            if hit then alvo = hit.Instance end
            if not alvo then
                for _, p in ipairs(workspace:GetPartBoundsInRadius(pos, 6)) do
                    if p:IsA("BasePart") and not p:IsDescendantOf(char) then alvo = p; break end
                end
            end
            if not alvo then return false end
            return _G.__Skyr0GrappleDisparar(tool, pos, alvo, char, RSv)
        end

        -- ---- pick the point: GROUND, in the direction of the destination ----
        local destino
        if typeof(value) == "Vector3" then destino = value
        elseif typeof(value) == "Instance" and value:IsA("BasePart") then destino = value.Position end

        local dir
        if destino then
            dir = destino - hrp.Position
            dir = Vector3.new(dir.X, 0, dir.Z)
        end
        if not dir or dir.Magnitude < 1 then
            local lv = hrp.CFrame.LookVector
            dir = Vector3.new(lv.X, 0, lv.Z)
        end
        if dir.Magnitude < 0.01 then return false end
        dir = dir.Unit

        local par = RaycastParams.new()
        par.FilterType = Enum.RaycastFilterType.Exclude
        par.FilterDescendantsInstances = { char }

        -- THE CLOSEST POINT THE ITEM ACCEPTS, ALWAYS ON THE GROUND.
        -- The item only fires with the target between 10 and 50 studs, so
        -- "as close as possible" = the SMALLEST distance still over 10.
        --
        --  1. ORIGIN HEIGHT. The downward ray used to start 30 studs ABOVE you.
        --     Inside a base that puts the origin over the roof and the ray hits
        --     the roof from above -- the "grapple onto my own base roof" bug.
        --     It now starts 3 studs over your head and drops 60, staying under
        --     any cover.
        --  2. CHOICE. It used to stop at the FIRST valid candidate while
        --     sweeping far-to-near, i.e. almost always the farthest one. Now it
        --     tests every step and keeps the SHORTEST.
        --
        -- Steps start at 9 because the distance is 3D: with the ground a few
        -- studs below, 9 horizontal already clears 10.
        -- PICK THE GROUND NEAREST THE DESTINATION, not the ground nearest ME.
        --
        -- This kept the SHORTEST hit inside the item's 10-50 stud window, i.e.
        -- the closest patch of floor in roughly the right direction. Standing on
        -- your own base that is your own floor -- which is exactly the "it hooks
        -- at my base instead of towards the plot" behaviour. Every candidate is
        -- still gated on 10-50 studs from you (the item refuses anything else),
        -- but among the ones that qualify we now keep whichever lands CLOSEST TO
        -- THE TARGET PLOT, so the pull is always the one that makes progress.
        local pos, alvo, melhorD
        local function consider(hit)
            if not hit then return end
            local m = (hit.Position - hrp.Position).Magnitude
            if m < 10 or m > 50 then return end
            -- no destination to measure against (aiming down the LookVector):
            -- fall back to the old "closest to me" rule
            local d2 = destino and (hit.Position - destino).Magnitude or m
            if not melhorD or d2 < melhorD then
                pos, alvo, melhorD = hit.Position, hit.Instance, d2
            end
        end

        for _, d in ipairs({ 9, 10, 11, 12, 13, 14, 16, 18, 21, 24, 28, 32, 36, 40, 45 }) do
            local origem = hrp.Position + dir * d + Vector3.new(0, 3, 0)
            consider(workspace:Raycast(origem, Vector3.new(0, -60, 0), par))
        end

        -- no ground anywhere (flying, over a hole): straight ray in the
        -- requested direction, same "nearest the destination" rule
        if not pos then
            for _, d in ipairs({ 11, 14, 18, 24, 32, 42, 48 }) do
                consider(workspace:Raycast(hrp.Position, dir * d, par))
            end
        end
        if not pos or not alvo then return false end

        -- ---- write the aim and fire IN THE SAME FRAME ----
        --
        -- WHY WRITE INTO SEVERAL TABLES: the executor's require() usually keeps
        -- its OWN cache, separate from the game scripts' cache. In that case
        -- require(PlayerMouse) RE-EXECUTES the module and hands back a fresh
        -- table -- which also connects to PreRender and also holds live values.
        -- Reading it looks right, but the HookScript reads the OTHER one. That
        -- is why the aim kept following the mouse. So we sweep the heap for
        -- every table shaped { Hit = CFrame, Target = ... } and write to all of
        -- them. The game's is among them.
        return _G.__Skyr0GrappleDisparar(tool, pos, alvo, char, RSv)
    end

    -- =====================================================================
    -- FIRE THE GRAPPLE -- USETHISTP's method  (the DEFAULT)
    -- ---------------------------------------------------------------------
    -- Ported from that build's SXEFireGrapple2 exactly; only the _G names differ.
    --
    -- The remote is taken POSITIONALLY -- Net folder child #6. That is the real
    -- UseItem RE; the plaintext "RE/UseItem" alias sits far later in the folder
    -- and is dead, which is why resolving it by name stopped working after the
    -- update. With a saved payload this is an exact replay of a legitimate fire.
    --
    -- Nothing here touches the client: no camera rotation, no PlayerMouse writes,
    -- no Activated signal, no getgc sweep -- which is the whole reason to prefer
    -- it. If it stops actually pulling you (the payload shape is wrong for the
    -- obfuscated HookScript), set _G.Skyr0GrappleUseTool = true to fall back to
    -- the Activate path above.
    -- =====================================================================
    _G.Skyr0FireGrapple2 = function(value, exato)
        if _G.Skyr0GrappleUseTool and _G.Skyr0FireGrappleTool then
            return _G.Skyr0FireGrappleTool(value, exato)
        end
        local function netChild6()
            local c = netFolder:GetChildren()[6]
            if c and c:IsA("RemoteEvent") then return c end
            return nil
        end
        local r = netChild6()
        -- Short bounded retry: on a fresh join the folder may still be
        -- replicating, so don't give up on the very first miss.
        if not r then
            local t0 = os.clock()
            repeat
                task.wait(0.05)
                r = netChild6()
            until r or (os.clock() - t0) > 1.5
        end
        if not r then
            if not _G.__Skyr0GrappleWarned then
                _G.__Skyr0GrappleWarned = true
                warn("[skyr0] Grapple remote unresolved (Net folder still streaming?)")
            end
            return false
        end
        local p = _G.__Skyr0UseItemPayload
        if p and p.n then
            -- exact replay of a legit fire -> indistinguishable server-side
            return (pcall(function() r:FireServer(table.unpack(p, 1, p.n)) end))
        end
        -- no saved payload: fall back to the scalar grapple value
        return (pcall(function()
            r:FireServer(tonumber(value) or tonumber(_G.Skyr0GrappleValue) or 0.33)
        end))
    end

    _G.Skyr0GrappleReady = function() return resolveHashed("UseItem", "RemoteEvent") ~= nil end

    -- =====================================================================
    -- THE CYCLE:   grapple towards the base  ->  TP
    -- ---------------------------------------------------------------------
    -- Single entry point: TP-on-load and the Manual TP keybind both call this,
    -- so the two behave identically and there is only one place to tune.
    --
    -- The gap between the hook and the TP is 2 frames -- the useful minimum. It
    -- cannot be zero: Activate() only QUEUES the handler (Roblox defaults to
    -- SignalBehavior = Deferred), so on the firing frame the item script has not
    -- even run yet and the pull has not started.
    -- =====================================================================
    -- =====================================================================
    -- STEAL LOCKOUT -- no carpet speed, no teleport, while Stealing is set.
    -- ---------------------------------------------------------------------
    -- Same signal Auto Invis rides on: the LocalPlayer "Stealing" attribute.
    -- The carpet boost already skipped its per-frame velocity write while this
    -- was set, but only the write -- the toggle still turned on, the teleports
    -- still fired, and either one moves you during a steal. A ~140 studs/s
    -- delta (or a whole flight) while the server thinks you are standing still
    -- holding a prompt is the exact shape an anti-cheat looks for, and it drops
    -- the steal anyway.
    --
    -- One predicate, checked at every entry point rather than deep inside, so a
    -- blocked action never half-runs.
    -- =====================================================================
    _G.Skyr0IsStealing = function()
        local ok, v = pcall(function()
            return game:GetService("Players").LocalPlayer:GetAttribute("Stealing")
        end)
        return ok and v == true
    end

    _G.Skyr0CicloTP = function(esperaMax)
        if _G.Skyr0IsStealing() then
            warn("[skyr0] Grapple TP blocked: you are stealing.")
            return false
        end
        -- Stale-guard: the old boolean latch could be left true by an error
        -- inside the cycle, which killed every later TP on that server. Store
        -- the START TIME instead and let anything older than 20s be reclaimed.
        local rodando = _G.__Skyr0CicloRodando
        if type(rodando) == "number" and (os.clock() - rodando) < 20 then
            warn(("[skyr0] Grapple TP ignored: a cycle started %.1fs ago is still running.")
                :format(os.clock() - rodando))
            return false
        end
        _G.__Skyr0CicloRodando = os.clock()

        local okCiclo, resCiclo = pcall(function()

        local RSvc = game:GetService("RunService")
        local eu = game:GetService("Players").LocalPlayer

        -- TARGET FIRST. ALWAYS.
        --
        -- This is what made "the first 10 tries fail and then it always works":
        -- in the opening seconds the pet cache is still empty, so the cycle went
        -- up, spent the hook, and the TP started with nowhere to go. 20-30s
        -- later the scanner has populated and it never misses again.
        --
        -- Now it checks first: no target, no climb. The hook is not wasted and
        -- the reason lands in the console.
        local function temAlvo()
            local c = _G.SharedState and _G.SharedState.AllAnimalsCache
                   or (SharedState and SharedState.AllAnimalsCache)
            if not c then return false end
            local meu, meuD = eu.Name, eu.DisplayName
            for _, a in ipairs(c) do
                if a.plot and a.slot and a.owner ~= meu and a.owner ~= meuD
                   and not (_G.Skyr0IsMyPlotCached and _G.Skyr0IsMyPlotCached(a.plot)) then
                    return true
                end
            end
            return false
        end

        -- NO WAIT AT ALL by default.
        --
        -- This started at 4s, then 1.5s, and it was still the reason the
        -- keybind felt sluggish: every Grapple TP paid it up front before
        -- anything visible happened. It is not a requirement -- with no cached
        -- target the cycle hands off to the plain TP, which runs its own scan
        -- and polls for 6s anyway. So check ONCE and move immediately; pass an
        -- explicit esperaMax if a caller genuinely wants to wait.
        local teto = tonumber(esperaMax) or 0
        if teto > 0 then
            local t0 = os.clock()
            while not temAlvo() and os.clock() - t0 < teto do
                RSvc.Heartbeat:Wait()
            end
        end

        -- No cached target: DO NOT just give up. The cache is only the hub's own
        -- scanner view, and if that is cold (or broken) the old behaviour was a
        -- keybind that looked completely dead -- one warn line in a console
        -- nobody has open. Skip the grapple, since aiming it needs a destination
        -- from the cache, and hand off to the normal TP, which runs its own scan.
        if not temAlvo() then
            warn("[skyr0] Grapple TP: nothing in the scanner cache yet "
              .. "-- skipping the hook and running a plain TP instead.")
            if _G.Skyr0StartSideTP then task.spawn(_G.Skyr0StartSideTP)
            elseif _G.Skyr0_ExecuteManualTP then task.spawn(_G.Skyr0_ExecuteManualTP) end
            return false
        end

        -- DESTINATION STREAMING -- the cause of the early-join rollback.
        --
        -- With StreamingEnabled the target base's region has not been sent to
        -- the client in the first seconds. Flying there means crossing space
        -- that is empty as far as your client knows -- the server rejects the
        -- movement and yanks you back. Once the map loads it stops happening:
        -- exactly the "insane rollback the first few times, then TP freely".
        --
        -- RequestStreamAroundAsync asks for the region and WAITS for it. On
        -- demand, at the destination, right before leaving.
        local destino
        do
            local plots = workspace:FindFirstChild("Plots")
            local cache = (_G.SharedState and _G.SharedState.AllAnimalsCache)
                       or (SharedState and SharedState.AllAnimalsCache) or {}
            if plots then
                -- Aim at the BEST target, not the first one in the cache. The
                -- old loop broke on whatever entry happened to be first, so the
                -- hook pointed at a random base while the TP that follows went
                -- somewhere else entirely -- and it never excluded your own
                -- plot, so it would happily aim at your own brainrots.
                -- SAME TARGET THE TP WILL USE, when we can get it. The hook and
                -- the TP used to pick independently -- both "the best target",
                -- but from different data -- so the hook could launch at one
                -- base while the TP flew to another. Ask the shared picker
                -- first; the scan below is the fallback for when it is not up
                -- yet (it is defined much further down the file).
                local pick = _G.Skyr0GetTargetPetData and select(2, pcall(_G.Skyr0GetTargetPetData))
                if type(pick) == "table" and pick.plot
                   and not (_G.Skyr0IsMyPlotCached and _G.Skyr0IsMyPlotCached(pick.plot)) then
                    local pl = plots:FindFirstChild(pick.plot)
                    if pl then
                        local okp, pv = pcall(function() return pl:GetPivot().Position end)
                        if okp and pv then destino = pv end
                    end
                    -- LOCK IT IN for the teleport that follows.
                    --
                    -- Both sides called the picker, but at different moments --
                    -- the hook now, the TP a fraction of a second later, after
                    -- the scanner had refreshed. A different pet could win the
                    -- second call, so the hook launched at one base and the TP
                    -- flew to another. The TP reuses this exact pet instead.
                    _G.Skyr0TPLockedPet = pick
                    _G.Skyr0TPLockedAt = os.clock()
                end

                local melhor, melhorGen = nil, -1
                for _, a in ipairs(cache) do
                    if a.plot and a.owner ~= eu.Name and a.owner ~= eu.DisplayName
                       and not (_G.Skyr0IsMyPlotCached and _G.Skyr0IsMyPlotCached(a.plot)) then
                        local gen = tonumber(a.genValue) or 0
                        if gen > melhorGen then
                            local pl = plots:FindFirstChild(a.plot)
                            if pl then
                                local okp, pv = pcall(function() return pl:GetPivot().Position end)
                                if okp and pv then melhor, melhorGen = pv, gen end
                            end
                        end
                    end
                end
                destino = destino or melhor
            end
        end

        -- FIRE AND FORGET. RequestStreamAroundAsync YIELDS until the region
        -- arrives, so awaiting it -- even with a deadline -- put up to a second
        -- of nothing between your keypress and the hook. The request is still
        -- worth making (it is what stops the early-join rollback), but the
        -- streaming happens while we are already flying, not before we start.
        if workspace.StreamingEnabled and destino then
            task.spawn(function()
                pcall(function() eu:RequestStreamAroundAsync(destino) end)
            end)
        end

        -- GRAPPLE TOWARDS THE BASE, FROM THE GROUND.
        --
        -- Passing the destination WITHOUT the second argument puts
        -- Skyr0FireGrapple2 in SEARCH mode: it takes the horizontal direction to
        -- the base and hunts for ground, keeping the closest hit inside the
        -- 10-50 stud window the item accepts. i.e. it pulls you towards the
        -- base, close to the ground.
        local ok = false
        if destino and _G.Skyr0FireGrapple2 then
            pcall(function() ok = _G.Skyr0FireGrapple2(destino) and true or false end)
        end

        -- Gap between the hook and the TP. Cannot be zero: Activate() only
        -- QUEUES the handler. With zero the TP starts on the same frame and the
        -- first thing it does is equip the carpet -- which takes the Grapple
        -- Hook OUT of your hand. When the handler finally runs, the item script
        -- tests Tool.Name == "Grapple Hook", does not find it, and bails.
        --
        -- TWO FRAMES, not 0.12s. This is the smallest gap that works, and it is
        -- the pause you see after pressing the key: Activate() only QUEUES the
        -- item's handler, so the TP must not start on the firing frame -- the
        -- first thing it does is equip the carpet, which takes the Grapple Hook
        -- out of your hand before the handler ever runs. Two frames is enough
        -- for the handler to be dequeued; 0.12s was ~7 frames of standing still.
        RSvc.Heartbeat:Wait(); RSvc.Heartbeat:Wait()

        -- NO CLONE HERE. The cycle's job is: hook towards the base, then hand
        -- off to the TP. The clone belongs to the TP, which fires it AT THE
        -- WALL -- after the flight lands, facing the base, pushed 2.5 studs in,
        -- with the retry loop watching whether it took.
        --
        -- Cloning here instead fired it 0.12s after the hook, in mid-air, miles
        -- from the base: it equips the Quantum Cloner (which drops the Grapple
        -- Hook and kills the pull), burns the clone on empty space, and leaves
        -- the wall clone with nothing to swap to.
        if _G.Skyr0StartSideTP then
            task.spawn(_G.Skyr0StartSideTP)
        elseif _G.Skyr0_ExecuteManualTP then
            task.spawn(_G.Skyr0_ExecuteManualTP)
        end

        return ok
        end)

        _G.__Skyr0CicloRodando = nil
        if not okCiclo then warn("[skyr0] TP cycle error:", resCiclo); return false end
        return resCiclo
    end
end

-- =====================================================================
-- NET BYPASS -- _G.getRemote  (name -> LIVE hashed remote)      [ported]
-- ---------------------------------------------------------------------
-- The generic front door to the Net layer, ported from the reference hub.
-- Plaintext RE/<Name> entries in the Net folder are DEAD ALIASES and the real
-- remotes are hash-named with a hash that rotates every server join, so a
-- caller must never touch the folder by name. This normalises "RE/Foo" /
-- "RF/Foo" / "Foo", routes UseItem through the dual-hash fingerprint (the one
-- name registered as BOTH an RE and an RF), and otherwise walks the _G.Net
-- hasher across all three classes before giving up. Resolved TP remotes are
-- pinned into _G.__tpUseItemRemote / _G.__tpOnTelRemote for the prewarm path.
--
-- ADAPTED: the reference calls its dual-hash helpers _G.SXEFindUseItem /
-- _G.SXEResolveHashed; this fork already defines the same two as
-- _G.Skyr0FindUseItem / _G.Skyr0ResolveHashed. Both names are accepted.
-- =====================================================================
do
-- Compat: alte TP-Hub-Namen, die andere Teile / Prewarm noch aufrufen
_G.VanishGetNet = function()
    return _G.Net
end
_G.SXE_DualHash = _G.SXEFindUseItem or _G.Skyr0FindUseItem
_G.VanishGetRemote = function(method, name)
    if type(_G.getRemote) == "function" then
        return _G.getRemote(method, name)
    end
    return nil
end

do
    _G.__tpRemotesReady = _G.__tpRemotesReady or false
    _G.__tpUseItemRemote = _G.__tpUseItemRemote
    _G.__tpOnTelRemote = _G.__tpOnTelRemote

    local function _stripRemoteName(name)
        name = tostring(name or "")
        local pfx = name:match("^(%u+)/")
        if pfx == "RE" or pfx == "RF" or pfx == "URE" then
            name = name:gsub("^%u+/", "", 1)
        end
        return name, pfx
    end

    function _G.getRemote(method, name)
        local rawName, pfx = _stripRemoteName(name)
        local kindGuess = method
        if pfx == "RF" then kindGuess = "RemoteFunction"
        elseif pfx == "URE" then kindGuess = "UnreliableRemoteEvent"
        elseif pfx == "RE" then kindGuess = "RemoteEvent"
        end

        local r
        -- UseItem: live gehashter Remote via dual-hash (Klartext RE/UseItem ist ein toter Alias)
        if rawName == "UseItem" then
            local _find = _G.SXEFindUseItem or _G.Skyr0FindUseItem
            if type(_find) == "function" then
                pcall(function() r = _find() end)
            end
            local _res = _G.SXEResolveHashed or _G.Skyr0ResolveHashed
            if not r and type(_res) == "function" then
                pcall(function() r = _res("UseItem", kindGuess or "RemoteEvent") end)
            end
        end
        if not r and _G.Net then
            local function tryKind(kind)
                if not _G.Net then return nil end
                if kind == "RemoteFunction" and _G.Net.RemoteFunction then
                    local ok, remote = pcall(_G.Net.RemoteFunction, _G.Net, rawName)
                    if ok and remote then return remote end
                elseif kind == "UnreliableRemoteEvent" and _G.Net.UnreliableRemoteEvent then
                    local ok, remote = pcall(_G.Net.UnreliableRemoteEvent, _G.Net, rawName)
                    if ok and remote then return remote end
                elseif _G.Net.RemoteEvent then
                    local ok, remote = pcall(_G.Net.RemoteEvent, _G.Net, rawName)
                    if ok and remote then return remote end
                end
                if _G.Net.GetRemote then
                    local ok, remote = pcall(_G.Net.GetRemote, _G.Net, rawName)
                    if ok and remote then return remote end
                end
                return nil
            end
            r = tryKind(kindGuess)
            if not r and kindGuess ~= "RemoteEvent" then r = tryKind("RemoteEvent") end
            if not r and kindGuess ~= "RemoteFunction" then r = tryKind("RemoteFunction") end
            if not r and kindGuess ~= "UnreliableRemoteEvent" then r = tryKind("UnreliableRemoteEvent") end
        end
        if r then
            if rawName == "UseItem" and (r:IsA("RemoteEvent") or r:IsA("UnreliableRemoteEvent")) then
                _G.__tpUseItemRemote = r
                _G.__tpRemotesReady = true
            elseif rawName:find("OnTeleport", 1, true) then
                _G.__tpOnTelRemote = r
            end
            return r
        end
        return nil
    end
end

local function getRemote(method, name)
    if _G.getRemote then return _G.getRemote(method, name) end
    return nil
end
_G.MynxxGetRemote = getRemote
end


-- =====================================================================
-- SYNCHRONIZER BYPASS -- channel registry via UPVALUES          [ported]
-- ---------------------------------------------------------------------
-- Second half of the Synchronizer bypass. It never asks the module to build
-- the registry (GetAllChannels is the call that trips RelateChannels) and it
-- never hooks mod.Get: it reads the table the module already keeps its
-- channels in, straight out of mod.Get's upvalues, recognising it by an entry
-- carrying a CacheTable -- checked one level deep and then one level down.
-- Pure debug.getupvalue, never setupvalue.
--
-- Non-blocking on purpose: no WaitForChild anywhere on the hot path, and the
-- ~800ms require(Synchronizer) is done ONCE on its own task while every other
-- caller returns nil and retries next frame, so a RunService handler is never
-- left yielding on it.
--
-- This is ADDITIVE. The fork's own Heresy-core discovery (_G.XenSyncGet /
-- sProp / _xenRawCT, near the top of this file) is untouched and stays the
-- path everything currently uses; this one lands beside it under Vanish*/SXE_*
-- names as a second, independent read of the same registry.
--
-- Exports: _G.VanishSyncAll, _G.VanishSyncGet, _G.VanishGetSyncMod,
-- _G.SXE_MaskNow, _G.SXE_ChannelGet, _G.VanishGetPlotChannel, _G.SXE_SynStatus.
-- =====================================================================
do
local RS = game:GetService("ReplicatedStorage")
_G.__SXE_T0 = _G.__SXE_T0 or os.clock()
-- ===================================================================
-- SYNCHRONIZER : METHODE UNIQUE (port du hub SE)
-- ===================================================================
-- SUPPRIMES d'ici: le hook hookfunction sur mod.Get / mod.Wait, le scan
-- getgc(true), le scrape debug.getupvalue(Get, 9) + l'unpatch de la gate
-- up9[0] -> up9[1], digOnce (direct + recursif), la capture OnChannelCreated,
-- les 2 boucles de harvest par frame, et le probe multi-bag
-- (CacheTable/Data/_data/state/values).
-- A LA PLACE, une seule voie: GetAllChannels appele SOUS L'IDENTITE de
-- RS.Controllers.PlotController via secure_call (swap d'identite de thread +
-- hop coroutine + setfenv sur l'env du script masque), donc le mouchard
-- RelateChannels du module ne part pas. Les donnees sortent ensuite par
-- channel:Get(cle), sans secure_call (la gate est dans la couche registre,
-- pas dans le getter du channel).
do
    -- resolveurs NON BLOQUANTS: aucun WaitForChild dans le chemin chaud, sinon
    -- le thread du radar se ferait geler jusqu'a 10s au premier appel.

    local _mask
    local function _maskNow()
        if _mask and _mask.Parent then return _mask end
        local c = RS:FindFirstChild("Controllers")
        _mask = c and c:FindFirstChild("PlotController")
        return _mask
    end

    local _syncMod, _reqInFlight
    local function _getSyncMod()
        if _syncMod then return _syncMod end
        local p = RS:FindFirstChild("Packages")
        local m = p and p:FindFirstChild("Synchronizer")
        if not m then return nil end
        -- require() KANN YIELDEN: das Modul führt seine eigene Initialisierung durch,
        -- gemessen bei ~800ms. Da wir mehrmals pro Frame abfragen, würde ein direkter
        -- require hier Dutzende von Threads blockieren, die in derselben Initialisierung
        -- stecken, und den heißen Pfad (einschließlich RunService-Handler) zum Yielden
        -- bringen.
        -- Nur ein require gleichzeitig, in seiner eigenen Aufgabe; andere Aufrufe
        -- geben sofort nil zurück und versuchen es im nächsten Frame erneut.
        if _reqInFlight then return nil end
        _reqInFlight = true
        task.spawn(function()
            local ok, mod = pcall(require, m)
            if ok and type(mod) == "table" then
                _syncMod = mod
            end
            _reqInFlight = false
        end)
        return nil
    end
    _G.VanishGetSyncMod = _getSyncMod
    -- version NON bloquante du resolveur de masque (FindFirstChild seulement),
    -- appelable depuis un handler de signal. A ne pas confondre avec
    -- _G.VanishGetMask qui fait des WaitForChild.
    _G.SXE_MaskNow = _maskNow

    -- Politique de rafraichissement taillee pour la VITESSE, pas pour le CPU.
    -- Le hub SE met le registre en cache une fois pour toutes et throttle les
    -- echecs a 3s: ici on veut le registre a la frame pres, donc
    --   * rien encore obtenu -> nouvelle tentative a CHAQUE appel (chaque frame)
    --   * registre partiel    -> re-appel toutes les 50ms (les channels des
    --                            autres plots se repliquent en decale, un cache
    --                            definitif trop tot les perdrait a vie)
    --   * registre complet    -> cache servi tel quel, revalide toutes les 500ms
    --                            contre workspace.Plots (un plot qui se replique en
    --                            retard doit pouvoir relancer le rafraichissement)
    local _xchan, _nextTry, _full = nil, 0, false
    -- Stable-within-a-frame stamp, so the hot window below cannot run its
    -- upvalue sweep more than once per frame.
    --
    -- The poller at the bottom of this port drives probe() from a Heartbeat
    -- connection, RS.DescendantAdded and Plots.ChildAdded -- all three of which
    -- can land in the SAME frame while the game is streaming in. Bucketing
    -- os.clock() at 8ms collapses them into one sweep. It is deliberately not a
    -- true frame counter: the only framerate where an 8ms bucket could swallow
    -- two real frames is >125fps, which is not the ~7fps load screen the hot
    -- window exists for, and the 50ms fallback throttle covers that case anyway.
    local _lastHotFrame = -1
    local function _frameStamp()
        return math.floor(os.clock() * 125)
    end
    local _fullRecheck = 0
    -- complet = CHAQUE plot de workspace.Plots a son channel dans le registre.
    -- Comparer juste le nombre d'entrees se figerait trop tot si le registre
    -- contient des cles qui ne sont pas des plots.
    local function _regComplete(reg)
        local p = workspace:FindFirstChild("Plots")
        if not p then return false end
        local kids = p:GetChildren()
        if #kids == 0 then return false end
        for _, plot in ipairs(kids) do
            if reg[plot.Name] == nil then return false end
        end
        return true
    end
    -- ===================================================================
    -- METHODE UPVALUES (remplace secure_call + GetAllChannels)
    -- ===================================================================
    -- On ne demande plus au module de construire le registre: on lit
    -- directement la table ou il RANGE ses channels, trouvee dans les
    -- upvalues de mod.Get.
    -- Recherche: getupvalues() si dispo, sinon debug.getupvalue(fn, i) de
    -- 1 a 128. La table est reconnue a une valeur possedant CacheTable,
    -- teste sur DEUX niveaux (direct puis sous-tables).
    -- _G.MynxxUpvalDepth pour la borne (defaut 128).
    local function _getUpvalues(fn)
        local g = getupvalues or (debug and debug.getupvalues)
        if type(g) == "function" then
            local ok, t = pcall(g, fn)
            if ok and type(t) == "table" then return t end
        end
        local gu = getupvalue or (debug and debug.getupvalue)
        if type(gu) ~= "function" then return nil end
        local out = {}
        local lim = tonumber(_G.MynxxUpvalDepth) or 128
        for i = 1, lim do
            local ok, a, b = pcall(gu, fn, i)
            if not ok then break end
            local v = (b ~= nil) and b or a
            if v == nil then break end
            out[i] = v
        end
        return out
    end

    local function _findChannels(upvals)
        local found
        pcall(function()
            for _, upval in next, upvals do
                if type(upval) == "table" then
                    -- niveau 1: upval ist die Tabelle der Channels
                    for _, val in next, upval do
                        if type(val) == "table" and rawget(val, "CacheTable") then
                            found = upval
                            return
                        end
                    end
                    -- niveau 2: die Channels sind in einer Untertabelle
                    for _, v1 in next, upval do
                        if type(v1) == "table" then
                            for _, v2 in next, v1 do
                                if type(v2) == "table" and rawget(v2, "CacheTable") then
                                    found = v1
                                    return
                                end
                            end
                        end
                    end
                end
            end
        end)
        return found
    end

    local function _chans()
        -- bereits gefundene Tabelle: direkt lesen (sie ist lebendig)
        if _xchan then
            -- Throttle auf BEIDEN Seiten: früher rief der Zweig "noch nicht vollständig"
            -- _regComplete bei jedem Scan ohne Limit auf, und er bleibt dauerhaft aktiv
            -- sobald ein Plot im Spiel keine Einträge im Register hat (häufiger Fall).
            -- _regComplete macht ein FindFirstChild + Durchlauf aller Plots.
            if os.clock() >= _fullRecheck then
                _fullRecheck = os.clock() + 0.5
                _full = _regComplete(_xchan)
            end
            return _xchan
        end

        -- ADOPT WHAT THE HERESY CORE ALREADY FOUND -- before spending anything.
        --
        -- This block and the Heresy core at the top of the file resolve the SAME
        -- live registry table by two different routes. Re-deriving it here was
        -- pure duplicated work, and it was duplicated at the single worst moment:
        -- the load screen, where the client sits near 7fps and the poller below
        -- is calling this from three frame signals.
        --
        -- The core's _chans() is cheap once it has succeeded (it just returns its
        -- cached _xchan), so ask it first. On the normal path this block now
        -- costs one function call and never touches getupvalue at all. The
        -- upvalue scan underneath is the fallback for when the core has not
        -- resolved yet -- or never does.
        if type(_G.XenSyncAll) == "function" then
            local okX, regX = pcall(_G.XenSyncAll)
            if okX and type(regX) == "table" and next(regX) ~= nil then
                _xchan = regX
                if _regComplete(regX) then _full = true end
                return _xchan
            end
        end

        -- noch nicht gefunden: bei jedem Frame während der Load-Fenster wiederholen,
        -- dann alle 50ms.
        --
        -- The "hot" window used to mean UNTHROTTLED: for the first 8s every
        -- single call ran a full _getUpvalues sweep (up to 128 pcall'd
        -- getupvalue calls) plus a two-level _findChannels walk. With three
        -- frame signals wired to the poller that is three full sweeps per frame,
        -- for eight seconds, while the game is loading. The window is kept --
        -- catching the registry a frame earlier is the whole point of it -- but
        -- it is now floored at one sweep per frame instead of one per CALL.
        local hot = (os.clock() - (_G.__SXE_T0 or 0)) < (tonumber(_G.MynxxHotScanSec) or 8)
        if hot then
            local fr = _frameStamp()
            if fr == _lastHotFrame then return nil end
            _lastHotFrame = fr
        elseif os.clock() < _nextTry then
            return nil
        end
        _nextTry = os.clock() + 0.05

        local sync = _getSyncMod()
        if not sync then return nil end
        local getfn
        pcall(function() getfn = sync.Get end)
        if type(getfn) ~= "function" then getfn = rawget(sync, "Get") end
        if type(getfn) ~= "function" then return nil end

        local ups = _getUpvalues(getfn)
        if type(ups) ~= "table" then
            return nil
        end

        local reg = _findChannels(ups)
        if type(reg) == "table" then
            local n = 0
            for _ in pairs(reg) do n = n + 1 end
            if n > 0 then
                _xchan = reg
                if _regComplete(reg) then _full = true end
                return _xchan
            end
        end
        return nil
    end
    _G.VanishSyncAll = function() return _chans() end
    -- CHEAP readiness probe. SXE_SynStatus further down COUNTS the registry -- a
    -- full pairs() walk -- and the poller at the end of this port was calling it
    -- on every probe, three times a frame, purely to read one boolean out of it.
    -- This answers the same question without touching the table.
    _G.VanishSyncReady = function()
        return _xchan ~= nil and _maskNow() ~= nil
    end
    _G.VanishSyncGet = function(idx)
        local t = _chans()
        if not t or idx == nil then return nil end
        return t[idx]
    end

    -- Lesen einer Channel-Eigenschaft = channel:Get(key), wie im hub SE.
    -- Wenn Get antwortet, wird der Wert so zurückgegeben (nil inklusive). Der Fallback
    -- CacheTable wird NUR verwendet, wenn der Aufruf einen Fehler auslöst, d.h. wenn
    -- das Objekt überhaupt keinen Getter hat: niemals parallel zu Get.
    -- Funktion gehoben: der alte "pcall(function() return ch:Get(key) end)" allozierte
    -- eine Closure bei JEDER Lesung, also 2 pro Channel und pro Frame (AnimalList +
    -- Owner) auf 12 Channels. Der Indexzugriff auf Get bleibt im geschützten Aufruf.
    local function _rawChanGet(c, k) return c:Get(k) end
    function _G.SXE_ChannelGet(ch, key)
        if ch == nil or key == nil then return nil end
        -- Zuerst DIREKT aus der internen Tabelle lesen: das ist genau das, was
        -- c:Get(k) zurückgibt, ohne pcall und Methodenaufruf des Moduls.
        -- Diese beiden wurden 3x pro Channel + 1x pro Pet bezahlt, also 300-400
        -- Aufrufe konzentriert in EINEM Frame pro Scan -> der Peak.
        if type(ch) == "table" then
            local t = rawget(ch, "CacheTable")
            if type(t) == "table" then
                local v = t[key]
                if v ~= nil then return v end
            end
        end
        local ok, v = pcall(_rawChanGet, ch, key)
        if ok then return v end
        return nil
    end

    -- ADAPTED: this fork ALREADY binds _G.SXE_GetPlotChannel (near the top,
    -- onto _G.Skyr0_GetPlotChannel -> _G.XenSyncGet) and every existing caller
    -- -- isMyPlot_Instant, the plot scanners -- is built on that one. The port
    -- would have silently repointed all of them at this second registry, so it
    -- gets its OWN name and only fills SXE_GetPlotChannel if nothing claimed it.
    _G.VanishGetPlotChannel = function(name)
        return _G.VanishSyncGet(tostring(name))
    end
    if type(_G.SXE_GetPlotChannel) ~= "function" then
        _G.SXE_GetPlotChannel = _G.VanishGetPlotChannel
    end

    function _G.SXE_SynStatus()
        local t = _chans()
        local n = 0
        if type(t) == "table" then for _ in pairs(t) do n = n + 1 end end
        return { mod = _syncMod ~= nil, mask = _maskNow() ~= nil, full = _full, channels = n }
    end

end
end


-- =====================================================================
-- SYNCHRONIZER BYPASS -- frame-precise registry polling          [ported]
-- ---------------------------------------------------------------------
-- The registry is a plain Lua table the GAME's client code fills as it runs --
-- there is no Roblox signal to wait on, so the only option is to look. During
-- the loading screen the client sits at ~7fps, so this polls on Heartbeat plus
-- on the DescendantAdded of the instances it is waiting for (which fires INSIDE
-- the frame the instance arrives, with no tick wait -- the biggest win, since it
-- lands while the client is at its lowest fps).
--
-- ADAPTED: the reference wires all three frame phases; this build uses Heartbeat
-- only -- see the note at the connection itself.
--
-- Self-disarming: every connection is dropped as soon as the registry is in
-- hand, at the 30s deadline, or the moment a TP starts -- so it costs nothing
-- once you are actually playing.
--
-- ADAPTED: the reference watches its own _G.__TP_T0 latch; this fork's TP
-- cycle latch is _G.__Skyr0CicloRodando, so both are honoured.
-- =====================================================================
do
local RS = game:GetService("ReplicatedStorage")
-- ===================================================================
-- SONDAGE A LA FRAME PRES
-- ===================================================================
-- Das Register hat kein Roblox-Signal: Es ist eine Lua-Tabelle, die der
-- Client-Code des SPIELS füllt, wenn er läuft. Man kann also nur abfragen.
-- Während des Ladebildschirms fällt der Client auf ~7 fps (Messung: 10 Aufrufe
-- auf 1381ms), und eine einzige Abfrage pro Heartbeat kostet bis zu 140ms
-- Verzögerung für den Zeitpunkt, an dem die Daten lesbar werden.
-- Daher wird zu den DREI Punkten der Frame abgefragt, plus jedes Mal, wenn
-- eine erwartete Instanz repliziert wird (dort ist der Gewinn sofort: kein
-- Warten auf den nächsten Tick).
-- Radar und TP-Schleife laufen auf Heartbeat, dem LETZTEN der drei Punkte:
-- Wenn sie durchlaufen, ist das Register des aktuellen Frames bereits aufgelöst
-- -> keine Frame verloren zwischen "Daten werden lesbar" und "Ziel wird gewählt".
-- Alles wird abgeschaltet, sobald das TP gestartet ist: keine Kosten im Spiel.
do
    local RunSvc = game:GetService("RunService")
    local conns = {}
    local stopped = false
    local function stopAll()
        if stopped then return end
        stopped = true
        for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
        conns = {}
    end
    local function probe()
        if stopped then return end
        if _G.__TP_T0 or _G.__Skyr0CicloRodando then stopAll() return end
        -- separat aufgelöst: sonst wurde PlotController erst NACH dem require des
        -- Synchronizers getestet, und seine Zeitmessung maß den require statt seiner
        -- eigenen Replikation.
        pcall(_G.SXE_MaskNow)
        pcall(_G.VanishSyncAll)
        -- STOP THE MOMENT THE REGISTRY IS IN HAND.
        --
        -- The only exit used to be the 30s task.delay, so on a server where the
        -- registry resolved in the first second this kept its per-frame
        -- callbacks and an RS.DescendantAdded listener alive for another 29
        -- seconds of the load, re-confirming a table it had already cached.
        --
        -- The bar is "present and usable", NOT "complete". Waiting for complete
        -- was wrong on two counts: it walks the registry to decide, and a
        -- registry that never completes (a plot with no channel is common, per
        -- the Heresy core's own note) means it never stops at all. And once the
        -- table is adopted there is nothing left to poll FOR -- _chans() above
        -- now takes it straight from the Heresy core, which the scanners drive
        -- many times a second anyway. VanishSyncReady is the no-walk check.
        if _G.VanishSyncReady and _G.VanishSyncReady() then stopAll() end
    end

    -- moderne Namen zuerst, historische Namen als Fallback; Zugriff auf eine
    -- nicht existierende Eigenschaft löst einen Fehler aus, daher der pcall.
    local function sig(...)
        for _, n in ipairs({ ... }) do
            local ok, s = pcall(function() return RunSvc[n] end)
            if ok and typeof(s) == "RBXScriptSignal" then return s end
        end
        return nil
    end
    -- ONE frame signal, not three.
    --
    -- The reference hub wires PreRender + PreSimulation + PostSimulation because
    -- there it is the ONLY thing driving the registry, so catching it a third of
    -- a frame earlier is a real win. Here it is not: the Heresy core at the top
    -- of this file resolves the same registry, the scanners drive that core many
    -- times a second, and _chans() above now adopts its result rather than
    -- re-deriving anything. Three callbacks per frame was paying triple for a
    -- fraction of a frame nobody was waiting on -- during the load, which is
    -- exactly when it is least affordable.
    --
    -- PostSimulation/Heartbeat is the one kept, deliberately: it is the LAST
    -- phase of the frame, and both the radar and the TP loop run on Heartbeat --
    -- so the registry is resolved for the current frame before either of them
    -- reads it. No frame is lost between "data became readable" and "target
    -- chosen", which was the whole point of the three-phase wiring.
    --
    -- The instance-replication hooks below are untouched. They are the cheap,
    -- high-value half: they fire INSIDE the frame the instance arrives, and only
    -- for the four names actually being waited on.
    do
        local s = sig("PostSimulation", "Heartbeat")
        if s then
            local ok, c = pcall(function() return s:Connect(probe) end)
            if ok and c then conns[#conns + 1] = c end
        end
    end

    -- Instanz-Replikation: wird INNERHALB des Frames ausgelöst, ohne auf den
    -- nächsten Tick zu warten. Das ist der größte Gewinn, weil es bei 525ms
    -- ankommt, wenn der Client am niedrigsten in fps ist.
    local watch = {
        Synchronizer = true, PlotController = true,
        Packages = true, Controllers = true,
    }
    do
        local ok, c = pcall(function()
            return RS.DescendantAdded:Connect(function(d)
                if watch[d.Name] then probe() end
            end)
        end)
        if ok and c then conns[#conns + 1] = c end
    end

    -- Ein Plot, der spät erscheint, macht die Vollständigkeit des Registers
    -- ungültig: erneut abfragen.
    -- An Plots selbst anhängen, NICHT an workspace.DescendantAdded, das während
    -- des Ladens auf Tausende von Parts feuern würde.
    task.spawn(function()
        local t = os.clock()
        while os.clock() - t < 20 and not stopped do
            local plots = workspace:FindFirstChild("Plots")
            if plots then
                local ok, c = pcall(function() return plots.ChildAdded:Connect(probe) end)
                if ok and c then conns[#conns + 1] = c end
                return
            end
            RunSvc.Heartbeat:Wait()
        end
    end)

    task.delay(30, stopAll)
end
end


-- The macro below is a real Luraph directive (keeps the lazy worker non-virtualized) and a no-op
-- pass-through when unobfuscated. Its pass-through DEFINITION lives in the LPH shim at the very
-- top of this file. Do NOT re-define or test the macro by name here: under Luraph a macro may
-- only be CALLED directly -- using it by itself (assignment / boolean test) is a syntax error.

-- =====================================================================
-- LAZY-LOAD QUEUE
-- =====================================================================
_G.__Skyr0LazyQ = _G.__Skyr0LazyQ or {}
local function LazyInit(name, fn)
    table.insert(_G.__Skyr0LazyQ, { name = name, fn = fn })
end
task.defer(LPH_NO_VIRTUALIZE(function()
    while true do
        if #_G.__Skyr0LazyQ > 0 then
            local item = table.remove(_G.__Skyr0LazyQ, 1)
            local ok, err = pcall(item.fn)
            if not ok then warn("[skyr0 Lazy]", item.name, err) end
            task.wait(0.08)
        else
            task.wait(0.5)
        end
    end
end))

-- Persistent panel visibility store that survives script re-executes within the same Roblox session
_G._Skyr0PanelVis = _G._Skyr0PanelVis or {}

_G.lazyUIs = {}
_G.addLazyUI = function(element, targetVis, isScreenGui, panelName)
    if element then
        if isScreenGui then
            element.Enabled = false
        else
            element.Visible = false
        end
        table.insert(_G.lazyUIs, {element = element, targetVis = targetVis, isScreenGui = isScreenGui, cancelled = false, panelName = panelName})
    end
end
_G.cancelLazyUI = function(element)
    for _, item in ipairs(_G.lazyUIs) do
        if item.element == element then
            item.cancelled = true
            break
        end
    end
end
task.delay(4.0, function()
    for _, item in ipairs(_G.lazyUIs) do
        if item.element and not item.cancelled then
            local vis
            if item.panelName then
                -- Priority: _G store (survives re-exec) > Config.Visibilities > default true
                local fromG = _G._Skyr0PanelVis[item.panelName]
                if fromG ~= nil then
                    vis = fromG
                elseif Config and Config.Visibilities then
                    local saved = Config.Visibilities[item.panelName]
                    if saved ~= nil then vis = saved else vis = true end
                else
                    vis = item.targetVis
                end
            else
                vis = item.targetVis
            end
            if item.isScreenGui then
                pcall(function() item.element.Enabled = vis end)
            elseif item.element.Parent then
                pcall(function() item.element.Visible = vis end)
            end
        end
    end
end)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
pcall(function() Players.RespawnTime = 0 end)

-- GLOBAL SCALE SYSTEM (Mobile Friendly Auto-Scaling)
local GlobalUIScaleVal = 1
local scaledGuis = {}

local function getGlobalScale()
    return GlobalUIScaleVal
end

local function updateAllGuisScale(newScale)
    GlobalUIScaleVal = newScale
    for sg, master in pairs(scaledGuis) do
        pcall(function()
            if sg and sg.Parent and master and master.Parent then
                local scaleObj = master:FindFirstChild("Skyr0_GlobalScale")
                if scaleObj then
                    scaleObj.Scale = newScale
                end
                master.Size = UDim2.new(1 / newScale, 0, 1 / newScale, 0)
            end
        end)
    end
end

local function registerScreenGui(sg)
    local master = sg:FindFirstChild("Skyr0_MasterFrame")
    if not master then
        master = Instance.new("Frame")
        master.Name = "Skyr0_MasterFrame"
        master.BackgroundTransparency = 1
        master.BorderSizePixel = 0
        master.Parent = sg
        
        local scaleObj = Instance.new("UIScale")
        scaleObj.Name = "Skyr0_GlobalScale"
        scaleObj.Parent = master
    end
    scaledGuis[sg] = master
    
    pcall(function()
        local scaleObj = master:FindFirstChild("Skyr0_GlobalScale")
        if scaleObj then
            scaleObj.Scale = GlobalUIScaleVal
        end
        master.Size = UDim2.new(1 / GlobalUIScaleVal, 0, 1 / GlobalUIScaleVal, 0)
    end)
    return master
end

local function recalculateScale()
    local cam = Workspace.CurrentCamera
    if not cam then return end
    local size = cam.ViewportSize
    local h = size.Y
    
    local isMobile = UIS.TouchEnabled
    local newScale = 1
    if isMobile then
        -- Mobile/Tablet scaling: aggressive down-scale to perfectly fit small landscape screens
        newScale = math.clamp(h / 1000, 0.40, 0.58)
    else
        -- PC/Console scaling: standard comfortable scaling
        newScale = math.clamp(h / 800, 0.65, 1.0)
    end
    updateAllGuisScale(newScale)
end

local cameraConn
local function setupCameraListener()
    if cameraConn then pcall(function() cameraConn:Disconnect() end) end
    local cam = Workspace.CurrentCamera
    if cam then
        cameraConn = cam:GetPropertyChangedSignal("ViewportSize"):Connect(recalculateScale)
        recalculateScale()
    end
end
Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(setupCameraListener)
task.spawn(setupCameraListener)

-- =====================================================================
-- DEVICE DETECTION  --  _G.Skyr0Device
-- ---------------------------------------------------------------------
-- `TouchEnabled and not MouseEnabled` is what every check in this file used,
-- and it is wrong in both directions:
--   * a Windows touchscreen laptop reports BOTH, so it was treated as a phone
--     and got 40px rows and a launcher button it does not need
--   * an iPad reports touch-only, so it was treated as a phone and got the
--     cramped 300px phone layout on a 1024px screen
--
-- GuiService:IsTenFootInterface() identifies console, and the viewport's
-- SMALLER edge separates phone from tablet regardless of orientation -- a
-- rotated phone is still a phone.
--
-- Exposes _G.Skyr0Device = "pc" | "phone" | "tablet" | "console" and the two
-- booleans everything else reads. Recomputed on rotation.
-- =====================================================================
do
    local UIS_ = game:GetService("UserInputService")
    local GS_  = game:GetService("GuiService")

    local function classify()
        local touch, kbd, mouse, gamepad = false, false, false, false
        pcall(function()
            touch   = UIS_.TouchEnabled
            kbd     = UIS_.KeyboardEnabled
            mouse   = UIS_.MouseEnabled
            gamepad = UIS_.GamepadEnabled
        end)
        local tenfoot = false
        pcall(function() tenfoot = GS_:IsTenFootInterface() end)
        if tenfoot or (gamepad and not touch and not kbd) then return "console" end
        -- a real pointer + keyboard means desktop, even with a touchscreen
        if kbd and mouse then return "pc" end
        if touch then
            local cam = workspace.CurrentCamera
            local vp = (cam and cam.ViewportSize) or Vector2.new(390, 760)
            -- smaller edge: orientation-independent
            return (math.min(vp.X, vp.Y) >= 600) and "tablet" or "phone"
        end
        return "pc"
    end

    local function apply()
        _G.Skyr0Device    = classify()
        _G.Skyr0IsTouch   = (_G.Skyr0Device == "phone" or _G.Skyr0Device == "tablet")
        _G.Skyr0IsPhone   = (_G.Skyr0Device == "phone")
        _G.Skyr0IsTablet  = (_G.Skyr0Device == "tablet")
        _G.Skyr0IsConsole = (_G.Skyr0Device == "console")
    end
    apply()

    local cam = workspace.CurrentCamera
    if cam then
        cam:GetPropertyChangedSignal("ViewportSize"):Connect(function()
            local was = _G.Skyr0Device
            apply()
            if was ~= _G.Skyr0Device and _G.__LMARK then
                _G.__LMARK("device -> " .. tostring(_G.Skyr0Device))
            end
        end)
    end
end

-- HIDDEN UI ROOT (Heresy core behaviour). This used to be `Parent = playerGui`.
-- PlayerGui is walkable by the GAME'S OWN LocalScripts -- they enumerate it,
-- find a ScreenGui that is not theirs and report it over a remote. gethui()
-- (and CoreGui as the fallback) is not reachable from game code, so the hub
-- becomes invisible to that scan. Every other ScreenGui here already went to
-- ExploitGui; these were the ones still in the open.
local old = _G.SXEBuscaGui("PingHub_GUI"); if old then old:Destroy() end
local gui_sg = Instance.new("ScreenGui"); gui_sg.Name = "PingHub_GUI"; gui_sg.ResetOnSpawn = false; gui_sg.IgnoreGuiInset = true; gui_sg.DisplayOrder = 9999999; gui_sg.Parent = ((gethui and gethui()) or game:GetService("CoreGui"))
local gui = registerScreenGui(gui_sg)

-- (JP Button removed per user request)

-- SHARED TOGGLE STATE
local ToggleState = {}
local function regToggle(name, default)
    if not ToggleState[name] then ToggleState[name] = {value = default or false, listeners = {}} end
end
local function getToggle(name) return ToggleState[name] and ToggleState[name].value or false end
local function setToggle(name, val, skipNotify)
    regToggle(name)
    ToggleState[name].value = val
    if not skipNotify then
        for _, fn in ipairs(ToggleState[name].listeners) do pcall(fn, val) end
    end
end
local function onToggleChanged(name, fn)
    regToggle(name); table.insert(ToggleState[name].listeners, fn)
end

-- GLOBAL CONFIG FORWARD DECLARATIONS (to avoid undefined/shadowing issues)
local Config
local saveConfig
local loadConfig

-- =====================================================================
-- skyr0.wtf  --  PURPLE / WHITE
-- ---------------------------------------------------------------------
-- Two colours and a grey ramp. Purple carries every active state, white
-- carries every readable thing, and the surfaces are pure neutral so nothing
-- else competes.
--
-- Because the palette is deliberately two-tone, state is NOT split across
-- three hues the way it was before. Instead:
--
--   PURPLE  = on / active / selected   (toggle on, active tab, slider fill)
--   WHITE   = text and emphasis
--   RED     = destructive ONLY         (delete, kick, blacklist)
--
-- Red stays because "remove this" must never look like "enable this" -- it is
-- the one place a third colour earns its keep, and it appears on a handful of
-- buttons rather than across the UI.
--
-- Surfaces ramp 0C -> 14 -> 1C -> 26 -> 32. No tinting: a neutral grey next to
-- purple reads as purple-adjacent anyway, and tinted greys would muddy it.
-- =====================================================================
SKYR_BRAND     = "PingHub"       -- wordmark
SKYR_BRAND_TLD = ""              -- no TLD
SKYR_TAG       = "PingHub"       -- full mark, used where one string is needed

Themes = {
    Dark = {
        MainBackground=Color3.fromRGB(12,12,14),  Background=Color3.fromRGB(20,20,23),
        Panel=Color3.fromRGB(28,28,32),           Row=Color3.fromRGB(38,38,43),
        RowHover=Color3.fromRGB(50,50,57),
        -- purple = every active state
        Accent=Color3.fromRGB(235,235,235),       AccentLight=Color3.fromRGB(210,210,210),
        -- Green is the ON colour throughout the file; pointing it at the same
        -- purple keeps the palette to two tones without touching ~40 call sites.
        Green=Color3.fromRGB(235,235,235),
        Red=Color3.fromRGB(226,72,80),            Red2=Color3.fromRGB(190,54,62),
        Text=Color3.fromRGB(255,255,255),         Dim=Color3.fromRGB(138,138,150),
        Stroke=Color3.fromRGB(44,44,50),
        SoftButton=Color3.fromRGB(38,38,43),      SoftButtonHover=Color3.fromRGB(50,50,57),
        SoftAccent=Color3.fromRGB(28,28,32),      SoftAccentHover=Color3.fromRGB(40,40,46),
        ToggleOff=Color3.fromRGB(58,58,66),       ToggleOff2=Color3.fromRGB(30,30,34),
        InputBg=Color3.fromRGB(16,16,19),         SliderBg=Color3.fromRGB(44,44,50),
        BlacklistHover=Color3.fromRGB(88,38,44),  BlacklistLeave=Color3.fromRGB(38,38,43),
    },
    Light = {
        MainBackground=Color3.fromRGB(248,247,251), Background=Color3.fromRGB(255,255,255),
        Panel=Color3.fromRGB(244,242,249),          Row=Color3.fromRGB(236,233,245),
        RowHover=Color3.fromRGB(227,222,241),
        -- Deepened purple for light mode: the dark-mode value sits under
        -- near-black button text and would drop to mud on white.
        Accent=Color3.fromRGB(235,235,235),          AccentLight=Color3.fromRGB(210,210,210),
        Green=Color3.fromRGB(235,235,235),
        Red=Color3.fromRGB(198,44,52),              Red2=Color3.fromRGB(168,34,42),
        Text=Color3.fromRGB(24,22,30),              Dim=Color3.fromRGB(118,114,128),
        Stroke=Color3.fromRGB(222,218,232),
        SoftButton=Color3.fromRGB(239,236,247),     SoftButtonHover=Color3.fromRGB(229,225,242),
        SoftAccent=Color3.fromRGB(244,242,249),     SoftAccentHover=Color3.fromRGB(233,229,246),
        ToggleOff=Color3.fromRGB(205,200,216),      ToggleOff2=Color3.fromRGB(235,232,244),
        InputBg=Color3.fromRGB(255,255,255),        SliderBg=Color3.fromRGB(220,215,232),
        BlacklistHover=Color3.fromRGB(247,206,209), BlacklistLeave=Color3.fromRGB(236,233,245),
    }
}
Theme = {}
for k, v in pairs(Themes.Dark) do
    Theme[k] = v
end

function applyTheme(themeName)
    local fromTheme = {}
    for k, v in pairs(Theme) do
        fromTheme[k] = v
    end
    
    local toTheme = Themes[themeName] or Themes.Light
    for k, v in pairs(toTheme) do
        Theme[k] = v
    end
    
    -- Helper 1: Explicitly style panels to avoid color collision bugs
    local function updatePanelTheme(f, isMain)
        if not f then return end
        f.BackgroundColor3 = isMain and toTheme.MainBackground or toTheme.Background
        for _, child in ipairs(f:GetChildren()) do
            if child:IsA("UIStroke") then
                child.Color = toTheme.AccentLight
            elseif child:IsA("Frame") then
                if child.Size == UDim2.new(1,-24,0,1) then
                    child.BackgroundColor3 = toTheme.AccentLight
                elseif child.BackgroundTransparency == 1 and child.Size == UDim2.new(1,0,0,42) then
                    for _, sub in ipairs(child:GetChildren()) do
                        if sub:IsA("TextLabel") then
                            if sub.TextSize == 16 or sub.TextSize == 12 then
                                sub.TextColor3 = toTheme.Text
                            elseif sub.TextSize == 10 then
                                sub.TextColor3 = toTheme.Dim
                            end
                        end
                    end
                end
            end
        end
    end

    -- Helper 2: Explicitly style bottom bar
    local function updateBottomBarTheme()
        if not bottomBar then return end
        bottomBar.BackgroundColor3 = toTheme.Background
        for _, child in ipairs(bottomBar:GetChildren()) do
            if child:IsA("UIStroke") then
                child.Color = toTheme.AccentLight
            elseif child:IsA("TextLabel") then
                if child.Text == "|" or child.Text == "PingHub" or child.Text == ".gg/PingHub" then
                    child.TextColor3 = toTheme.AccentLight
                elseif child.Text == "By: pingisreal" then
                    child.TextColor3 = toTheme.Dim
                end
            elseif child:IsA("Frame") then
                if child.Size == UDim2.new(0,1,0,36) then
                    child.BackgroundColor3 = toTheme.Accent
                end
            end
        end
    end

    -- Helper 3: Explicitly style admin panel rows
    local function updateAdminPanelTheme()
        if not apBG then return end
        apBG.BackgroundColor3 = toTheme.Background
        local idx = 0
        for uid, row in pairs(apRows) do
            if row and row.Parent then
                idx = idx + 1
                local isAlt = (idx % 2 == 0)
                local rowCol = isAlt and toTheme.Row or toTheme.Panel
                row.BackgroundColor3 = rowCol
                local plr = Players:GetPlayerByUserId(uid)
                local isBlacklisted = isPlayerBlacklisted and isPlayerBlacklisted(plr)
                for _, child in ipairs(row:GetChildren()) do
                    if child:IsA("Frame") then
                        if child.Size == UDim2.fromOffset(34,34) then
                            child.BackgroundColor3 = toTheme.InputBg
                            local stroke = child:FindFirstChildOfClass("UIStroke")
                            if stroke then stroke.Color = toTheme.Accent end
                        elseif child.ZIndex == 12 then
                            for _, btn in ipairs(child:GetChildren()) do
                                if btn:IsA("TextButton") then
                                    if btn.Name == "BlacklistBtn" then
                                        btn.BackgroundColor3 = isBlacklisted and Color3.fromRGB(255, 60, 60) or toTheme.BlacklistLeave
                                    else
                                        btn.BackgroundColor3 = toTheme.SoftButton
                                    end
                                end
                            end
                        end
                    elseif child:IsA("TextLabel") then
                        if child.TextSize == 14 then
                            child.TextColor3 = toTheme.Text
                        elseif child.TextSize == 10 then
                            child.TextColor3 = toTheme.Dim
                        elseif child.TextSize == 11 then
                            child.TextColor3 = toTheme.AccentLight
                        end
                    end
                end
            end
        end
    end

    -- Run explicit styling on all static panels
    pcall(function()
        updatePanelTheme(main, true)
        updateBottomBarTheme()
        updateAdminPanelTheme()
        for _, name in ipairs({"Invisible Steal Panel", "Admin Command Panel", "Command Cooldowns", "Actions", "Steal Panel", "Steal Target", "Face Away"}) do
            updatePanelTheme(panels[name], false)   -- nil-safe: panels can be absent or built later
        end
        updatePanelTheme(actionSettingsPanel, false)
        updatePanelTheme(tpSpeedSettingsPanel, false)
    end)
    
    -- Fallback/Recursive styling for other dynamic frames (excluding mainBody descendants!)
    local function updateInstanceColors(inst)
        local shouldStyle = true
        if inst:IsA("GuiObject") or inst:IsA("UIStroke") then
            -- AVOID COLOR COLLISION BUG: Skip styling anything inside the tab mainBody dynamically
            if mainBody and inst:IsDescendantOf(mainBody) then return end
            
            -- Avoid updating main structures explicitly styled above
            if inst == main or inst == bottomBar or inst == apBG then
                shouldStyle = false
            end
            for _, p in ipairs({"Invisible Steal Panel", "Admin Command Panel", "Command Cooldowns", "Actions", "Steal Panel", "Steal Target", "Face Away"}) do
                if inst == panels[p] then
                    shouldStyle = false
                end
            end
            if inst == actionSettingsPanel or inst == tpSpeedSettingsPanel then
                shouldStyle = false
            end

            if shouldStyle then
                local bgKeys = {
                    Background=true, MainBackground=true, Panel=true, Row=true, RowHover=true,
                    SoftButton=true, SoftButtonHover=true, SoftAccent=true, SoftAccentHover=true,
                    ToggleOff=true, ToggleOff2=true, InputBg=true, SliderBg=true,
                    BlacklistHover=true, BlacklistLeave=true
                }
                local textKeys = {
                    Text=true, Dim=true, Accent=true, AccentLight=true,
                    Green=true, Red=true, Red2=true, Stroke=true
                }
                local properties = {
                    BackgroundColor3 = bgKeys,
                    TextColor3 = textKeys,
                    PlaceholderColor3 = textKeys,
                    Color = textKeys
                }
                
                for prop, allowedKeys in pairs(properties) do
                    pcall(function()
                        local current = inst[prop]
                        if typeof(current) == "Color3" then
                            -- PROTECT WHITE TEXT ON SPECIFIC BUTTONS FROM THEME CONVERSION
                            if prop == "TextColor3" and inst.Name == "WhiteTextBtn" then
                                return
                            end
                            if prop == "BackgroundColor3" and inst.Name == "WhiteSliderKnob" then
                                return
                            end
                            for k, val in pairs(fromTheme) do
                                if allowedKeys[k] then
                                    if (current.R - val.R)^2 + (current.G - val.G)^2 + (current.B - val.B)^2 < 0.0001 then
                                        inst[prop] = toTheme[k]
                                        break
                                    end
                                end
                            end
                        end
                    end)
                end
            end
        end
        for _, child in ipairs(inst:GetChildren()) do
            updateInstanceColors(child)
        end
    end
    
    pcall(function()
        local sg = _G.SXEBuscaGui("PingHub_GUI")
        if sg then updateInstanceColors(sg) end
        if _G.updateLogoImage then
            _G.updateLogoImage(themeName == "Dark")
        end
    end)
    pcall(function()
        local ExploitGui = (gethui and gethui()) or game:GetService("CoreGui")
        local sg = ExploitGui:FindFirstChild("XiPriorityAlertTest")
        if sg then updateInstanceColors(sg) end
    end)
    for _, name in ipairs({"Skyr0_StealProgressBar", "XiAdminPanel"}) do
        pcall(function()
            local otherSg = _G.SXEBuscaGui(name)
            if otherSg then updateInstanceColors(otherSg) end
        end)
    end
    
    -- Button text colors are already set correctly at creation/refresh (dark on the white
    -- Accent/Green backgrounds, white on dark). Forcing white here made "ON"/arrows/keybind
    -- text invisible on the old hub's white accents -- so only the slider knob stays forced white.
    local function forceWhiteText(inst)
        if inst:IsA("Frame") and inst.Name == "WhiteSliderKnob" then
            inst.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        end
        for _, child in ipairs(inst:GetChildren()) do
            forceWhiteText(child)
        end
    end
    
    pcall(function()
        local sg = _G.SXEBuscaGui("PingHub_GUI")
        if sg then forceWhiteText(sg) end
    end)
    
    if Config then
        Config.DarkMode = (themeName == "Dark")
        if saveConfig then saveConfig() end
    end
    pcall(function() if rebuildActions then rebuildActions() end end)
    pcall(function() if rebuildActionSettings then rebuildActionSettings() end end)
    pcall(function() if rebuildTpSpeedSettings then rebuildTpSpeedSettings() end end)
    pcall(function() if loadTab then loadTab(UI.CurrentTab) end end)
end
_G.applyTheme = applyTheme

-- OpenMenuKeyName is what the input handler matches on; OpenMenuKey is the
-- EnumItem form kept for anything that wants it. Both are (re)derived from
-- Keybinds["Open Menu"] by applyOpenMenuKey -- never assigned anywhere else.
local UI = {Locked=false, OpenMenuKey=Enum.KeyCode.LeftControl,
            OpenMenuKeyName="LeftControl", CurrentTab="Auto TP"}

-- Defaults. Every key here must be UNIQUE: two actions once shared K, and
-- dispatch walked the table with pairs() -- whose order is undefined -- so
-- which one fired was a coin flip that changed between runs.
Keybinds = {
    Kick="Y",["Rejoin Job ID"]="J",Clone="F",["Manual TP"]="T",["Invisible Steal"]="U",
    ["Job ID"]="K",Proximity="P",["Carpet Boost"]="Q",["Open Menu"]="LeftControl",
    ["Ragdoll Self"]="R",["Drop Brainrot"]="G",Float="Z",
    ["Grapple TP"]="V",["Click to AP"]="NONE",["Insta Reset"]="H",
    -- Unbound by default: every letter worth having is already taken, and a
    -- default that collides is silently DROPPED by the restore pass below.
    -- Set it from the Keybinds tab.
    ["Steal Nearest"]="NONE"
}

-- Keys a bind may never take: WASD/Space are movement and C is the game's own
-- steal key (the TP engine sends it itself). Chat/typing is handled separately
-- by checking for a focused TextBox at dispatch time.
KeybindReserved = { W=true, A=true, S=true, D=true, Space=true, C=true, Unknown=true }

-- =====================================================================
-- Enum.KeyCode[name] IS NOT A SAFE LOOKUP.
-- ---------------------------------------------------------------------
-- Indexing an Enum with a name it does not have does not return nil, it
-- THROWS. Three places did `Enum.KeyCode[v]` on a string straight out of the
-- saved config or off an input event, and one of them (the config restore) is
-- at chunk scope with no pcall around it -- so a config holding "MouseButton3"
-- for Open Menu, which the bind UI can write, killed the whole hub on load
-- before a single feature came up.
-- =====================================================================
function Skyr0KeyCode(name)
    if type(name) ~= "string" or name == "" or name == "NONE" then return nil end
    local ok, kc = pcall(function() return Enum.KeyCode[name] end)
    if ok and typeof(kc) == "EnumItem" then return kc end
    return nil
end

-- =====================================================================
-- ONE PLACE DECIDES WHAT OPENS THE MENU.
-- ---------------------------------------------------------------------
-- UI.OpenMenuKey was written in four places and cleared in none of them, and
-- that is the "keybinds not being set":
--
--   * clearing Open Menu with the X button called commit("NONE") with no
--     KeyCode, so the assignment was skipped and the OLD key kept opening the
--     menu -- for good, since nothing else ever writes it;
--   * binding Open Menu to MouseButton3 has no KeyCode either, same result;
--   * the config restore only assigned when Enum.KeyCode[v] existed, so a
--     saved "NONE" left the LeftControl default in place.
--
-- And because the input handler checks OpenMenuKey FIRST and returns, a stale
-- key silently swallows every action later bound to it: you set Clone to
-- LeftControl, the row shows LeftControl, and pressing it opens the menu.
--
-- Derived from Keybinds["Open Menu"] and nothing else. NONE means nil, which
-- means the menu has no key -- exactly what the row says.
-- =====================================================================
function applyOpenMenuKey()
    local name = Keybinds and Keybinds["Open Menu"]
    UI.OpenMenuKeyName = (type(name) == "string" and name ~= "NONE" and name) or nil
    UI.OpenMenuKey = Skyr0KeyCode(name)
end

-- =====================================================================
-- OPEN MENU CAN NEVER BE UNBOUND.
-- ---------------------------------------------------------------------
-- Every other action losing its key is an inconvenience you fix from the
-- Keybinds tab. Open Menu losing its key is a LOCKOUT: the tab is inside the
-- panel that key opens, so there is nothing left to fix it with -- on desktop
-- there is no launcher button either (the mobile FAB is touch-only).
--
-- It used to be impossible to notice, because UI.OpenMenuKey was seeded with
-- LeftControl at declaration and never cleared: the panel opened on LeftControl
-- whatever the config said, so an "Open Menu = NONE" sitting in the config --
-- from the X button, or from the collision pass dropping it when a saved bind
-- claimed LeftControl -- did nothing at all. Making OpenMenuKey honest turned
-- that dormant state into a locked-out hub, so the state itself has to go.
--
-- The rule: Open Menu always holds a key. If its own is gone it takes the first
-- free one from the list below, and if they are ALL taken it reclaims
-- LeftControl from whoever has it -- the menu wins, because it is the only bind
-- that can give the others back. Whatever it lands on shows in the Keybinds tab
-- like any other bind.
-- =====================================================================
Skyr0OpenMenuFallbacks = {"LeftControl","RightControl","Insert","End","Delete",
                          "F4","RightShift","LeftAlt","Backquote"}

function Skyr0EnsureOpenMenuBind()
    if type(Keybinds) ~= "table" then return nil end
    local function gravar(k)
        Keybinds["Open Menu"] = k
        if type(Config) == "table" and type(Config.keybinds) == "table" then
            Config.keybinds["Open Menu"] = k
        end
        applyOpenMenuKey()
        return k
    end

    local cur = Keybinds["Open Menu"]
    if type(cur) == "string" and cur ~= "NONE" and not KeybindReserved[cur] then
        applyOpenMenuKey()
        return cur
    end

    local taken = {}
    for action, k in pairs(Keybinds) do
        if action ~= "Open Menu" and type(k) == "string" and k ~= "NONE" then
            taken[k] = action
        end
    end
    for _, k in ipairs(Skyr0OpenMenuFallbacks) do
        if not taken[k] and not KeybindReserved[k] then
            warn("[skyr0] Open Menu had no key -- bound to " .. k .. ".")
            return gravar(k)
        end
    end

    -- Last resort: take LeftControl back off whoever holds it.
    local vitima = taken["LeftControl"]
    if vitima then
        Keybinds[vitima] = "NONE"
        if type(Config) == "table" and type(Config.keybinds) == "table" then
            Config.keybinds[vitima] = "NONE"
        end
        warn("[skyr0] Open Menu had no key and every fallback was taken -- "
          .. "reclaimed LeftControl from '" .. tostring(vitima) .. "'.")
    end
    return gravar("LeftControl")
end

-- MUTATION PRIORITY. Empty here on purpose: the real default is DERIVED from
-- the game's own Mutations table (sorted by Modifier, biggest first) the first
-- time it is needed, so a mutation added by an update slots itself in at the
-- right place instead of falling off the end of a list written months ago.
-- Config.MutationPriority takes over once the user reorders anything.
mutationPriority = {}

priorityList = {
    "Strawberry Elephant",
    "Meowl",
    "Skibidi Toilet",
    "Headless Horseman",
    "Dragon Gingerini",
    "Dragon Cannelloni",
    "Ketupat Bros",
    "Hydra Dragon Cannelloni",
    "La Supreme Combinasion",
    "Love Love Bear",
    "Ginger Gerat",
    "Cerberus",
    "Capitano Moby",
    "La Casa Boo",
    "Burguro and Fryuro",
    "Spooky and Pumpky",
    "Cooki and Milki",
    "Rosey and Teddy",
    "Popcuru and Fizzuru",
    "Reinito Sleighito",
    "Fragrama and Chocrama",
    "Garama and Madundung",
    "Ketchuru and Musturu",
    "La Secret Combinasion",
    "Tralaledon",
    "Tictac Sahur",
    "Ketupat Kepat",
    "Tang Tang Keletang",
    "Orcaledon",
    "La Ginger Sekolah",
    "Los Spaghettis",
    "Lavadorito Spinito",
    "Swaggy Bros",
    "La Taco Combinasion",
    "Los Primos",
    "Los Chillis",
    "Chillin Chili",
    "Tuff Toucan",
    "W or L",
    "Chipso and Queso",
    "Signore Carapace",
    "Arcadragon",
    "John Pork",
    "Elefanto Frigo",
    "Antonio",
    "Pancake and Syrup",
    "Griffin",
    "Kalika Bros",
    "Globa Steppa",
    "Fishino Clownino",
    "Rico Dinero",
    "Tirilikalika Tirilikalako",
    "Digi Narwhal",
    "Hydra Bunny",
    "Dug dug dug",
    "Bunny and Eggy",
    "Los Hackers",
    "Duggy Bros",
    "Guest 666",
    "Money Money Reindeer",
    "Foxini Lanternini",
    "Fragola La La La",
    "Quackini Snackini",
    "Los Sekolahs",
    "Los Tacoritas",
    "Los Amigos",
    "Fortunu and Cashuru",
    "Jolly Jolly Sahur",
    "Boppin Bunny",
    "Gym Bros",
    "Los Cupids",
    "Festive 67",
    "Celularcini Viciosini",
    "Cloverat Clapat",
    "La Food Combinasion",
    "Hopilikalika Hopilikalako",
    "Celestial Pegasus",
    "Sammyni Fattini",
    "Money Money Bros",
    "La Spooky Grande",
    "Cash or Card",
    "Swag Soda",
    "Los Planitos",
    "Lovin Rose",
    "Tacorita Bicicleta",
    "Los Jolly Combinasionas",
    "La Romantic Grande",
    "La Easter Grande",
    "Los Hotspotsitos",
    "Rosetti Tualetti",
    "Los Bros",
    "Gobblino Uniciclino",
    "Chicleteira Cupideira",
    "La Extinct Grande",
    "Las Sis",
    "Nacho Spyder",
    "Gold Gold Gold",
    "Los Mariachis",
    "Snailo Clovero",
    "La Jolly Grande",
    "Los Candies",
    "Churrito Bunnito",
    "Bananito",
    "Eviledon",
    "Los 67",
    "Los Sweethearts",
    "Noo my Heart",
    "La Lucky Grande",
    "Ventoliero Pavonero",
    "Baskito",
    "Chimnino",
    "Los Puggies",
    "Camera Ramena",
    "Los 25",
    "Spinny Hammy",
    "Money Money Puggy",
    "Cigno Fulgoro",
    "Los Spooky Combinasionas",
    "Chicleteira Noelteira",
    "Mariachi Corazoni",
    "Tacorillo Crocodillo",
    "Noo my Gold",
    "Los Mobilis",
    "Mieteteira Bicicleteira",
    "DJ Panda",
    "Los Combinasionas",
    "Nuclearo Dinossauro",
    "Bacuru and Egguru",
    "Spaghetti Tualetti",
    "La Grande Combinasion",
    "Esok Sekolah"
}

-- =====================================================================
--  ONE PRIORITY RULE FOR EVERY PICKER.   <-- "the TP ignores my priority"
-- ---------------------------------------------------------------------
--  Three separate places decided "which pet is the priority target", and
--  all three disagreed:
--
--    * getTargetPetData()   -- the panel picker. Skyr0CicloTP aims the hook
--                              with it and stashes the result in
--                              _G.Skyr0TPLockedPet, which doVelocityTP
--                              honours BEFORE _pickByMode. So this one is
--                              what actually decides where you land.
--                              It matched untrimmed, ignored the mode, and
--                              broke ties by highest gen.
--    * _pickByMode()        -- the flight/steal engine. Trimmed, respected
--                              the mode, and broke ties by SCAN ORDER.
--    * the Steal Target selection thread -- untrimmed, first match in a
--                              gen-sorted list.
--
--  Two of the same priority pet on a server (or a list entry with a stray
--  space) and the hook aimed at one base, the flight landed at another and
--  auto-grab armed a third. That is the "TP goes to random things".
--
--  Everything below is shared, so all three now answer identically:
--    _G.Skyr0PrioRank      -- position in the list, trimmed + case-folded,
--                             matched on DisplayName OR Index
--    _G.Skyr0PickPriority  -- best priority target out of any pet list
--    _G.Skyr0ResolveMode   -- which mode is actually in effect
--
--  Globals, not top-level locals: this chunk has already overflowed Luau's
--  200-register limit once (see the note on the auto-buy scope).
-- =====================================================================
do
    local _rankMap, _looseMap, _rankList, _rankAt = {}, {}, nil, 0

    -- Trimmed, lowercased, and internal runs of whitespace collapsed to one
    -- space. A list entry typed by hand or pasted can carry leading/trailing
    -- whitespace -- and a double space in the middle, which is invisible in the
    -- UI -- and an untrimmed " Headless " matched nothing at all, silently,
    -- straight into the biggest-earner fallback. That looks exactly like "it
    -- ignored my priority".
    local function _norm(s)
        if type(s) ~= "string" then return nil end
        return (s:lower():gsub("%s+", " "):match("^%s*(.-)%s*$"))
    end
    _G.Skyr0PrioNorm = _norm

    -- LOOSE key: letters and digits only.
    --
    -- The second pass, used only when the exact key misses. The list is typed
    -- by a human (or pasted from a wiki, or carried over from an older config)
    -- while the pet name comes from AnimalsData.DisplayName, and the two
    -- disagree on punctuation constantly: "Cupid's Wings" vs "Cupids Wings",
    -- "Ketchuru & Musturu" vs "Ketchuru and Musturu", a trailing "!" or a
    -- non-breaking hyphen. Every one of those was a silent no-match.
    local function _loose(s)
        local n = _norm(s)
        if not n then return nil end
        -- "&" becomes "and" BEFORE the strip.
        --
        -- Stripping punctuation alone does NOT make these match, which is
        -- exactly what this pass claimed to do and did not:
        --     "Garama & Madundung"   -> garamamadundung
        --     "Garama and Madundung" -> garamaandmadundung
        -- Different keys, no match, and the pet drops silently out of the
        -- priority walk into the biggest-earner fallback -- the exact "it is
        -- on my list and the TP went somewhere else" report. Half the
        -- two-part names in this game are written both ways, and the list is
        -- typed by hand while the name comes from AnimalsData.DisplayName.
        n = n:gsub("&", " and ")
        n = n:gsub("[^%w]", "")
        return n ~= "" and n or nil
    end
    _G.Skyr0PrioLoose = _loose

    -- Position in the user's priority list (1 = top), or nil if absent.
    --
    -- The map is rebuilt on a 0.2s throttle rather than per call: the UI
    -- reorder buttons SWAP IN PLACE, so neither the table identity nor its
    -- length changes and there is nothing cheap to compare against. 0.2s is
    -- invisible for a button press and turns ~150 string ops per call into
    -- ~150 five times a second.
    function _G.Skyr0PrioRank(name, index)
        local list = priorityList
        if type(list) ~= "table" then return nil end
        local now = os.clock()
        if _rankList ~= list or (now - _rankAt) > 0.2 then
            local m, lm = {}, {}
            -- backwards, so a duplicated name keeps its HIGHEST placing
            for i = #list, 1, -1 do
                local k = _norm(list[i])
                if k and k ~= "" then m[k] = i end
                local lk = _loose(list[i])
                if lk then lm[lk] = i end
            end
            _rankMap, _looseMap, _rankList, _rankAt = m, lm, list, now
        end
        -- exact first, on DisplayName then Index; loose only if both miss
        local r = (name and _rankMap[_norm(name) or ""])
               or (index and _rankMap[_norm(index) or ""])
        if r then return r end
        return (name and _looseMap[_loose(name) or ""])
            or (index and _looseMap[_loose(index) or ""])
            or nil
    end

    -- =====================================================================
    -- MUTATION PRIORITY
    -- ---------------------------------------------------------------------
    -- A second ordered list, of MUTATIONS, that decides between two pets the
    -- name list rates equally -- which until now was settled by raw earnings
    -- alone, so two Strawberry Elephants at #1 meant the Gold one and the
    -- Rainbow one were interchangeable to the picker.
    --
    -- Scoring, lower is better:
    --
    --   listed pet                    nameRank * 1000 + mutationRank
    --   unlisted pet, listed mutation MUT_ONLY + mutationRank   (opt-in)
    --   neither                       nil
    --
    -- The *1000 is what makes this a TIE-BREAK and not an override: no
    -- mutation can lift a #9 pet above a #1 pet, which is the whole point of
    -- keeping an ordered list. It only ever reorders pets that were equal.
    --
    -- A list entry may also NAME a mutation -- "Gold Meowl" -- and then it
    -- only matches that combination, while a bare "Meowl" lower down still
    -- catches every other one.
    -- =====================================================================
    local MUT_ONLY = 1e6

    local function _mutNorm(m)
        if type(m) ~= "string" then return nil end
        m = m:gsub("%s+", ""):lower()
        if m == "" or m == "none" then return nil end
        return m
    end
    _G.Skyr0MutNorm = _mutNorm

    -- One mutation colour table, so a mutation cannot be pink in one place and
    -- grey in another.
    local MUT_COLOR = {
        gold        = Color3.fromRGB(255, 222, 89),
        diamond     = Color3.fromRGB(37, 196, 254),
        bloodrot    = Color3.fromRGB(145, 0, 27),
        rainbow     = Color3.fromRGB(255, 0, 251),
        candy       = Color3.fromRGB(255, 70, 246),
        lava        = Color3.fromRGB(255, 149, 0),
        galaxy      = Color3.fromRGB(210, 45, 45),
        yinyang     = Color3.fromRGB(255, 255, 255),
        radioactive = Color3.fromRGB(104, 245, 0),
        cursed      = Color3.fromRGB(245, 56, 56),
        divine      = Color3.fromRGB(255, 209, 59),
        cyber       = Color3.fromRGB(121, 219, 255),
        celestial   = Color3.fromRGB(168, 132, 255),
    }
    function _G.Skyr0MutColor(mutation)
        local k = _mutNorm(mutation)
        return (k and MUT_COLOR[k]) or nil
    end

    -- Built from the game's own Mutations table, biggest Modifier first.
    function _G.Skyr0DefaultMutationOrder()
        local out = {}
        pcall(function()
            local mods = require(game:GetService("ReplicatedStorage")
                :WaitForChild("Datas", 10):WaitForChild("Mutations", 10))
            for name, info in pairs(mods) do
                if type(name) == "string" then
                    out[#out+1] = { name = name,
                                    mult = (type(info) == "table" and tonumber(info.Modifier)) or 0 }
                end
            end
        end)
        table.sort(out, function(a, b)
            if a.mult ~= b.mult then return a.mult > b.mult end
            return a.name < b.name
        end)
        local names = {}
        for _, e in ipairs(out) do names[#names+1] = e.name end
        -- An empty list would turn the whole feature off silently, so a sane
        -- fallback covers the case where Datas has not replicated yet.
        if #names == 0 then
            names = { "Bloodrot", "Cursed", "Divine", "Celestial", "Galaxy",
                      "Rainbow", "Cyber", "Radioactive", "Diamond", "YinYang",
                      "Lava", "Candy", "Gold" }
        end
        return names
    end

    local _mutMap, _mutList, _mutAt = nil, nil, 0

    -- Position of a mutation in the list (1 = best), or nil if unlisted.
    function _G.Skyr0MutRank(mutation)
        local list = mutationPriority
        if type(list) ~= "table" then return nil end
        local key = _mutNorm(mutation)
        if not key then return nil end
        local now = os.clock()
        if _mutList ~= list or (now - _mutAt) > 0.2 then
            local m = {}
            for i = #list, 1, -1 do
                local k = _mutNorm(list[i])
                if k then m[k] = i end
            end
            _mutMap, _mutList, _mutAt = m, list, now
        end
        return _mutMap[key]
    end

    -- Split "Gold Meowl" into ("Meowl", "Gold"). Plain entries come back
    -- unchanged with no mutation.
    function _G.Skyr0SplitEntry(entry)
        if type(entry) ~= "string" then return nil, nil end
        local list = mutationPriority
        if type(list) == "table" then
            for _, mut in ipairs(list) do
                if type(mut) == "string" and mut ~= "" then
                    local rest = entry:match("^" .. mut:gsub("(%W)", "%%%1") .. "%s+(.+)$")
                    if rest then return rest, mut end
                end
            end
        end
        return entry, nil
    end

    -- The priority list parsed once into plain and mutation-qualified entries,
    -- on the same 0.2s throttle the name map uses.
    local _plain, _qual, _peList, _peAt = nil, nil, nil, 0
    local function _entryMaps()
        local list = priorityList
        if type(list) ~= "table" then return {}, {} end
        local now = os.clock()
        if _peList == list and (now - _peAt) <= 0.2 then return _plain, _qual end

        local plain, qual = {}, {}
        for i = #list, 1, -1 do          -- backwards: the best placing wins
            local entry = list[i]
            if type(entry) == "string" and entry ~= "" then
                local petName, mut = _G.Skyr0SplitEntry(entry)
                local mk = mut and _mutNorm(mut) or nil
                for _, key in ipairs({ _norm(petName), _loose(petName) }) do
                    if key and key ~= "" then
                        if mk then
                            qual[key] = qual[key] or {}
                            qual[key][mk] = i
                        elseif plain[key] == nil or i < plain[key] then
                            plain[key] = i
                        end
                    end
                end
            end
        end
        _plain, _qual, _peList, _peAt = plain, qual, list, now
        return plain, qual
    end

    -- Combined score. Lower is better; nil means "not a priority target".
    function _G.Skyr0PrioScore(name, index, mutation)
        local plain, qual = _entryMaps()
        local mutRank = _G.Skyr0MutRank(mutation)
        local mk = _mutNorm(mutation)

        local nameRank
        for _, candidate in ipairs({ name, index }) do
            if candidate then
                for _, key in ipairs({ _norm(candidate), _loose(candidate) }) do
                    if key and key ~= "" then
                        -- a mutation-qualified entry outranks the bare one for
                        -- the same pet, which is why you would write it
                        local q = mk and qual[key] and qual[key][mk]
                        if q and (not nameRank or q < nameRank) then nameRank = q end
                        local p = plain[key]
                        if p and (not nameRank or p < nameRank) then nameRank = p end
                    end
                end
            end
        end

        if nameRank then
            return nameRank * 1000 + (mutRank or 999)
        end
        if Config.MutationPriorityOnly and mutRank then
            local floor = tonumber(Config.MutationPriorityTopN) or 0
            if floor <= 0 or mutRank <= floor then
                return MUT_ONLY + mutRank * 1000
            end
        end
        return nil
    end

    -- "Is this pet a priority target at all." Separate from Skyr0PrioRank
    -- because a dozen call sites use that one purely as a name lookup.
    function _G.Skyr0IsPriority(name, index, mutation)
        return _G.Skyr0PrioScore(name, index, mutation) ~= nil
    end

    -- Best priority target out of `pets`, or nil if none of them are listed.
    --
    -- The TOPMOST list entry present wins outright -- that is the whole point
    -- of an ordered list, so distance and gen never promote a #9 over a #1.
    -- They only break ties BETWEEN TWO PETS OF THE SAME ENTRY: biggest earner
    -- first, then the nearest base.
    --
    --   getGen(p)  -> earnings for the tie-break (mps / genValue)
    --   getPos(p)  -> Vector3 or nil; only consulted when fromPos is given
    --   accept(p)  -> optional filter (ownership, conveyor, ...)
    --   fromPos    -> Vector3 to measure distance from, or nil to skip it
    --
    -- The three lists this runs over are shaped differently (the panel cache,
    -- get_all_pets' flattened rows, the engine's scanAllPets rows), so the
    -- name/index are read through every spelling they use.
    function _G.Skyr0PickPriority(pets, getGen, getPos, accept, fromPos)
        if type(pets) ~= "table" then return nil end
        local function _dist(p)
            if not (p and fromPos and getPos) then return math.huge end
            local pos = getPos(p)
            return pos and (fromPos - pos).Magnitude or math.huge
        end
        local best, bestRank, bestGen, bestDist = nil, math.huge, -1, nil
        for _, p in ipairs(pets) do
            if p and (not accept or accept(p)) then
                -- Score, not bare rank: this is what lets the mutation list
                -- break a tie between two pets on the same list entry.
                local rank = _G.Skyr0PrioScore(
                    p.name or p.petName,
                    p.index or (p.animalData and p.animalData.index),
                    p.mutation or (p.animalData and p.animalData.mutation))
                if rank and rank <= bestRank then
                    local gen = (getGen and getGen(p)) or 0
                    local take, newDist = (rank < bestRank) or (gen > bestGen), nil
                    if not take and gen == bestGen and fromPos and getPos then
                        -- Distance is only asked for HERE: same list entry, same
                        -- earnings. getPos ends in a FindFirstChild + GetPivot per
                        -- pet, and this runs on a 0.1s poll during launch -- paying
                        -- it for every candidate would be a plot sweep per tick.
                        if bestDist == nil then bestDist = _dist(best) end
                        local d = _dist(p)
                        if d < bestDist then take, newDist = true, d end
                    end
                    if take then
                        best, bestRank, bestGen, bestDist = p, rank, gen, newDist
                    end
                end
            end
        end
        return best
    end

    -- THE MODE THAT IS ACTUALLY IN EFFECT.
    --
    -- Config.StealMode is authoritative: every explicit choice writes it --
    -- the Steal panel and the Auto-TP tab's three toggles both go through
    -- setStealMode -- so a non-nil value means the user picked it.
    --
    -- When it is nil the user has never chosen, and the ORDER of the fallback
    -- is the bug that made the priority list look dead on a fresh install:
    -- Config.StealHighest ships as TRUE and was read first, so every untouched
    -- config resolved to "Highest" and setStealMode then wrote
    -- AutoTPPriority = false over the default. AutoTPPriority (which also
    -- ships TRUE, and is the toggle users actually flip) is consulted first
    -- now; the legacy Steal* flags are only there for old saved configs.
    -- "Approach Floor 2 From 1" -- ONE definition of the floor-2 band.
    --
    -- The three sites that implement it each carried their own numbers:
    -- doVelocityTP's coord clamp and its _forceGo used `Y > 10 and Y <= 25`,
    -- while goToBrainrot -- the half that actually places you under the pet --
    -- used `Y >= 11 and Y <= 23.15`. So the two ends disagreed at the edges: a
    -- pet at Y=24 (floor THREE) got pushed in at floor-1 wall height and then
    -- handed to the floor-3 arrival, and a pet at Y=10.5 got the opposite. The
    -- feature half-applied and looked broken rather than off.
    --
    -- goToBrainrot's band wins: it is the tuned one, and it is the code that
    -- has to land you in the right place.
    function _G.Skyr0IsF2FromF1(y)
        local C = Config or {}
        if not C.AutoTPFloor2FromFloor1 then return false end
        y = tonumber(y)
        return (y ~= nil) and y >= 11 and y <= 23.15
    end

    function _G.Skyr0ResolveMode()
        local C = Config or {}
        local m = C.StealMode
        if m == "Priority" or m == "Highest" or m == "Nearest" then return m end
        if C.AutoTPPriority then return "Priority" end
        if C.AutoTPHighestGen or C.AutoTPHighestValue then return "Highest" end
        if C.StealPriority then return "Priority" end
        if C.StealHighest then return "Highest" end
        return "Priority"
    end
end

actionConfig = {
    ["Ragdoll Self (R)"]=true,["Insta Reset (H)"]=true,["Rejoin PS"]=true,["Rejoin Job ID (J)"]=true,
    ["Kick (Y)"]=true,["Kick To Private"]=true,
    ["Anti Ragdoll"]=false,["Infinite Jump"]=false,["Float"]=false,["Carpet Speed"]=false,
    -- Grapple TP is bound to V, but the bind alone is not discoverable, so it
    -- also gets a button in the Actions panel.
    ["Grapple TP"]=true,
}

-- CONFIG (merged)
local CONFIG_FILE = "skyr0_hub_config.json"
local PS_CODE_FILE = "skyr0_hub_pscode.txt"
-- Old filenames from before the rename. Config lives on disk, so renaming the
-- file without this would silently reset everyone's settings to defaults on the
-- next run and look like the hub had lost them. Read-only: the first save
-- writes the new name and the old file is simply left behind.
local LEGACY_CONFIG_FILE  = "sxe_hub_v3_config.json"
local LEGACY_PS_CODE_FILE = "sxe_hub_pscode.txt"
PrivateServerCode = ""

local function loadPSCode()
    pcall(function()
        if typeof(readfile)~="function" or typeof(isfile)~="function" then return end
        if isfile(PS_CODE_FILE) then PrivateServerCode = readfile(PS_CODE_FILE)
        elseif isfile(LEGACY_PS_CODE_FILE) then PrivateServerCode = readfile(LEGACY_PS_CODE_FILE) end
    end)
end
local function savePSCode()
    pcall(function() if typeof(writefile)=="function" then writefile(PS_CODE_FILE, PrivateServerCode or "") end end)
end
loadPSCode()

Config = {
    positions={},keybinds={},actions={},locked=false,
    DarkMode=false,
    AntiRagdoll=false,InfiniteJump=false,Float=false,
    AutoKickOnSteal=false,KickToPrivateServer=false,CleanErrorGUIs=false,
    AutoBuyEnabled=false, AutoBuyRange=17, AutoGrabSpeed=17,
    LineToBase=false,LineToBrainrot=false,InvisStealAngle=225,SinkSliderValue=7,
    AutoRecoverLagback=true,
    WalkSpeedEnabled=false, WalkSpeedValue=16,
    AutoTPPriority=true, AutoTPHighestGen=false, AutoTPHighestValue=false, AutoTPFloor2FromFloor1=false, FPSBoost=false, FPSBoostUltra=false, XRay=false, FOV=70,
    BrainrotESP=true, TimerESP=false, SubspaceMineESP=false, PlayerESP=true, BaseOwnerESP=false,
    AutoDestroyTurrets=false, AutoUnlockOnSteal=false,
    -- Face Away (ported from Heresy Free.txt). Modo: "baseowner" | "nearest" |
    -- "player" (with FaceAwayAlvo = the player's name).
    FaceAway=false, FaceAwayNearest=false, FaceAwayModo="baseowner", FaceAwayAlvo=nil,
    AutoInvisDuringSteal=false,
    ClickToAP=false, ClickToAPSingleCommand=false,
    ClickToAPRadius=8,
    SpamBaseOwnerCommands={balloon=true, inverse=true, jail=true, jumpscare=true, morph=true, nightvision=true, ragdoll=true, rocket=true, tiny=true},
    SpamBaseOwnerOrder={"balloon", "inverse", "jail", "jumpscare", "morph", "nightvision", "ragdoll", "rocket", "tiny"},
    SpamBaseOwnerSingleCommand=false,
    ProximityAP=false, ShowJobJoiner=true, AntiBeeDisco=false,
    AdminPanelUI=true,
    StealHighest=true, StealPriority=false, StealNearest=false,
    AutoStealEnabled=true,
    Unwalk=false,
    Visibilities = {
        ["Invisible Steal Panel"] = true,
        ["Admin Command Panel"] = true,
        ["Command Cooldowns"] = true,
        ["Actions"] = true,
        ["Steal Panel"] = true,
        ["Steal Target"] = true,
        -- built lazily the first time Face Away is switched on
        ["Face Away"] = true,
    },
    TpSettings = {
        Tool="Flying Carpet", TpKey="T", CloneKey="V", CarpetSpeedKey="Q",
        InfiniteJump=false, DelayVal=0.4, CloneDelayVal=0.1,
        RagdollTP=false, FPSWait=false, FlyTP=false, FlyTPSpeed=160, FlyTPCloseSpeed=75,
        GrabbleTP=false, GrabbleTPSpeed=230,
        TpOnLoad=false, MinGenForTp="", MinGenForGrab="",
        -- How long TP-on-load may wait for the FIRST scan to find a target
        -- before giving up. LOAD ONLY -- the keybind never waits for a target
        -- (see _G.Skyr0LaunchTP). Raising this widens the window in which a
        -- base streaming in can still trigger the on-load teleport.
        TpOnLoadScanWindow=10,
        -- How long the plot scanner must go QUIET before TP-on-load will
        -- settle for a non-priority target. Only used when a priority list
        -- is set; a listed pet always goes immediately.
        TpOnLoadSettle=1.5,
        BrainrotCarpet=false,
    },
    PriorityList=priorityList,
    MutationPriority=mutationPriority,
    RemovedFromPriority={},
}

local suffixes = {
    k = 1e3,
    m = 1e6,
    b = 1e9,
    t = 1e12,
    q = 1e15,
    qi = 1e18,
    qd = 1e18,
    qn = 1e18,
    sx = 1e21,
    sp = 1e24,
    oc = 1e27,
    no = 1e30,
    dc = 1e33,
    ud = 1e36,
    dd = 1e39,
    td = 1e42,
    qad = 1e45,
    qid = 1e48,
    sxd = 1e51,
    spd = 1e54,
    ocd = 1e57,
    nod = 1e60,
    vg = 1e63,
}

local function parseMinGen(str)
    if not str or type(str) ~= "string" then return 0 end
    str = str:gsub("%s", ""):lower():gsub("/s$", "")
    if str == "" then return 0 end
    local numStr, suffix = str:match("^([%d%.]+)(%a*)$")
    if not numStr then return 0 end
    local num = tonumber(numStr)
    if not num or num < 0 then return 0 end
    if suffix ~= "" then
        local mult = suffixes[suffix]
        if mult then
            return num * mult
        end
    end
    return num
end

local function canUseFiles() return typeof(readfile)=="function" and typeof(writefile)=="function" and typeof(isfile)=="function" end
loadConfig = function()
    if not canUseFiles() then return end
    local ok,data=pcall(function()
        if isfile(CONFIG_FILE) then return HttpService:JSONDecode(readfile(CONFIG_FILE)) end
        -- fall back to the pre-rename file exactly once (see LEGACY_CONFIG_FILE)
        if isfile(LEGACY_CONFIG_FILE) then return HttpService:JSONDecode(readfile(LEGACY_CONFIG_FILE)) end
    end)
    if ok and type(data)=="table" then
        for k,v in pairs(data) do
            if k == "PriorityList" or k == "RemovedFromPriority" then
                Config[k] = v
            elseif type(v) == "table" and type(Config[k]) == "table" then
                for subk, subv in pairs(v) do
                    Config[k][subk] = subv
                end
            else
                Config[k] = v
            end
        end
        if type(Config.positions)~="table" then Config.positions={} end
        if type(Config.keybinds)~="table" then Config.keybinds={} end
        if type(Config.actions)~="table" then Config.actions={} end
        -- "Approach Floor 2 From 1" used to save to TpSettings.ApproachFloor2From1
        -- while the engine read Config.AutoTPFloor2FromFloor1 -- so anyone who
        -- turned it on has the ON state sitting in the wrong key. Adopt it, and
        -- keep the two in step from here on.
        if type(Config.TpSettings)=="table" then
            if Config.TpSettings.ApproachFloor2From1 and not Config.AutoTPFloor2FromFloor1 then
                Config.AutoTPFloor2FromFloor1 = true
            end
            Config.TpSettings.ApproachFloor2From1 = Config.AutoTPFloor2FromFloor1 and true or false
        end
        if type(Config.RemovedFromPriority)~="table" then Config.RemovedFromPriority={} end
        local removedSet = {}
        for _, rn in ipairs(Config.RemovedFromPriority) do removedSet[rn] = true end
        if type(Config.PriorityList)=="table" then
            if #Config.PriorityList == 0 then
                Config.PriorityList = priorityList
            else
                local present = {}
                for _, name in ipairs(Config.PriorityList) do
                    present[name] = true
                end
                for _, name in ipairs(priorityList) do
                    if not present[name] and not removedSet[name] then
                        table.insert(Config.PriorityList, name)
                    end
                end
                priorityList = Config.PriorityList
            end
        else
            Config.PriorityList = priorityList
        end
        -- MUTATION PRIORITY. Seeded from the game's Mutations table when the
        -- config has nothing, so the feature works before it has been touched
        -- rather than sitting inert on an empty list.
        if type(Config.MutationPriority) == "table" and #Config.MutationPriority > 0 then
            mutationPriority = Config.MutationPriority
        else
            mutationPriority = _G.Skyr0DefaultMutationOrder and _G.Skyr0DefaultMutationOrder() or {}
            Config.MutationPriority = mutationPriority
        end
        if Config.MutationPriorityOnly == nil then Config.MutationPriorityOnly = false end
        if Config.MutationPriorityTopN == nil then Config.MutationPriorityTopN = 3 end

        -- Deduplicate priority list
        if type(Config.PriorityList) == "table" then
            local seen = {}
            local cleanList = {}
            for _, name in ipairs(Config.PriorityList) do
                if not seen[name] then
                    seen[name] = true
                    table.insert(cleanList, name)
                end
            end
            Config.PriorityList = cleanList
            priorityList = cleanList
        end
    end
end
saveConfig = function()
    if not canUseFiles() then return end
    task.spawn(function() pcall(function() writefile(CONFIG_FILE, HttpService:JSONEncode(Config)) end) end)
end

-- BASE64 ENCODER/DECODER FOR CONFIG SHARING (Wrapped in do-scope to save global registers)
do
    local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    local function base64Encode(data)
        local len = #data
        local t = {}
        for i = 1, len, 3 do
            local a = data:byte(i)
            local b = data:byte(i + 1) or 0
            local c = data:byte(i + 2) or 0
            local n = a * 65536 + b * 256 + c
            t[#t + 1] = b64chars:sub(math.floor(n / 262144) + 1, math.floor(n / 262144) + 1)
            t[#t + 1] = b64chars:sub(math.floor(n / 4096) % 64 + 1, math.floor(n / 4096) % 64 + 1)
            t[#t + 1] = (i + 1 <= len) and b64chars:sub(math.floor(n / 64) % 64 + 1, math.floor(n / 64) % 64 + 1) or "="
            t[#t + 1] = (i + 2 <= len) and b64chars:sub(n % 64 + 1, n % 64 + 1) or "="
        end
        return table.concat(t)
    end

    local function base64Decode(data)
        data = data:gsub('[^' .. b64chars .. '=]', '')
        local len = #data
        local t = {}
        local lookup = {}
        for i = 1, 64 do lookup[b64chars:sub(i, i)] = i - 1 end
        local i = 1
        while i <= len do
            local c1 = lookup[data:sub(i, i)]
            local c2 = lookup[data:sub(i + 1, i + 1)]
            local s3 = data:sub(i + 2, i + 2)
            local s4 = data:sub(i + 3, i + 3)
            local c3 = lookup[s3]
            local c4 = lookup[s4]
            if not c1 or not c2 then break end
            local n = c1 * 262144 + c2 * 4096 + (c3 or 0) * 64 + (c4 or 0)
            t[#t + 1] = string.char(math.floor(n / 65536))
            if s3 ~= "=" then
                t[#t + 1] = string.char(math.floor(n / 256) % 256)
            end
            if s4 ~= "=" then
                t[#t + 1] = string.char(n % 256)
            end
            i = i + 4
        end
        return table.concat(t)
    end

    _G.importConfig = function(str)
        if not str or str == "" then
            ShowNotification("IMPORT ERROR", "Config string is empty")
            return false
        end
        
        local success, parsed = pcall(function()
            return HttpService:JSONDecode(str)
        end)
        
        if not success or type(parsed) ~= "table" then
            local decoded
            pcall(function() decoded = base64Decode(str:gsub("%s", "")) end)
            if decoded then
                success, parsed = pcall(function() return HttpService:JSONDecode(decoded) end)
            end
        end

        if not success or type(parsed) ~= "table" then
            ShowNotification("IMPORT ERROR", "Invalid config data")
            return false
        end

        for k, v in pairs(parsed) do
            Config[k] = v
        end
        
        if type(Config.PriorityList) == "table" then priorityList = Config.PriorityList end
        
        saveConfig()

        if type(Config.keybinds) ~= "table" then Config.keybinds = {} end
        for k, v in pairs(Config.keybinds) do
            if Keybinds[k] ~= nil and type(v) == "string" then
                Keybinds[k] = v
            end
        end
        applyOpenMenuKey()
        -- keep the dispatch map in step with a re-load (no-op on first run,
        -- when the map has not been built yet)
        if rebuildKeybindMap then rebuildKeybindMap() end

        for k, v in pairs(Config.actions or {}) do
            if actionConfig[k] ~= nil then
                actionConfig[k] = v and true or false
            end
        end

        if type(Config.locked) == "boolean" then
            UI.Locked = Config.locked
        end

        initToggles()

        if setFPSBoost then pcall(setFPSBoost, Config.FPSBoost) end
        if setFPSBoostUltra then pcall(setFPSBoostUltra, Config.FPSBoostUltra) end
        if setXRay then pcall(setXRay, Config.XRay) end
        if setInfiniteJump then pcall(setInfiniteJump, Config.InfiniteJump) end
        if setFloat then pcall(setFloat, Config.Float) end
        if setCarpetSpeed then pcall(setCarpetSpeed, Config.CarpetSpeed or false) end
        -- ProximityAP always starts OFF, never loaded from config
    Config.ProximityAP = false
        if setStealMode then
            -- Same precedence as the main restore further down, and the same
            -- resolver the two target pickers read -- see _G.Skyr0ResolveMode.
            -- Getting this wrong has a lasting consequence: setStealMode
            -- rewrites Config.AutoTPPriority, so a wrong guess here ERASES the
            -- user's setting on import.
            -- Nearest is session-only: an imported Nearest resolves to whatever
            -- the rest of the config says, never back to Nearest.
            if Config.StealMode == "Nearest" then Config.StealMode = nil end
            pcall(setStealMode, _G.Skyr0ResolveMode())
        end
        if updateMovementPanelLabels then pcall(updateMovementPanelLabels) end

        rebuildActions()
        rebuildActionSettings()
        loadTab(UI.CurrentTab)

        ShowNotification("CONFIG SYSTEM", "Config imported successfully!")
        return true
    end

    _G.exportConfig = function()
        local ok, str = pcall(function()
            return HttpService:JSONEncode(Config)
        end)
        if not ok or not str then
            ShowNotification("EXPORT ERROR", "Failed to encode config")
            return nil
        end
        local cbSuccess = false
        if typeof(setclipboard) == "function" then
            pcall(function() setclipboard(str); cbSuccess = true end)
        elseif typeof(toclipboard) == "function" then
            pcall(function() toclipboard(str); cbSuccess = true end)
        end
        if cbSuccess then
            ShowNotification("CONFIG SYSTEM", "Config copied to clipboard!")
        else
            ShowNotification("CONFIG SYSTEM", "Config generated! Copy from share box.")
        end
        return str
    end
end
local function applySavedPosition(name, frame)
    if not name or not frame then return end; local d=Config.positions and Config.positions[name]
    if d then frame.Position=UDim2.new(d.xs or 0,d.xo or 0,d.ys or 0,d.yo or 0) end
end
-- =====================================================================
-- rememberPosition  --  THE COUNTERPART TO applySavedPosition, AND IT DID
-- NOT EXIST. This is the "mouse gets stuck when moving the GUI" bug.
-- ---------------------------------------------------------------------
-- makeDraggable's release handler is one line:
--
--     if dragging and saveName then rememberPosition(saveName,frame) end; dragging=false
--
-- rememberPosition was never defined anywhere in the file, so that call
-- raised "attempt to call a nil value" -- and it raised it BEFORE the
-- `dragging=false` that follows it on the SAME line. The flag therefore
-- stayed true forever: you let go of the mouse button and the window kept
-- following the cursor, and every later click was spent dragging that
-- window instead of hitting what was under the pointer.
--
-- It hit on the FIRST release of any drag, because every window built
-- through buildPanel passes a saveName ("MainWindow" and the panel titles).
--
-- Only Config.positions (already read by applySavedPosition, already
-- initialised in the config loader) is written, so panel positions now
-- actually survive a re-execute, which is what the comment above
-- makeDraggable always claimed they did.
-- =====================================================================
function rememberPosition(name, frame)
    if not name or not frame or not frame.Parent then return end
    if type(Config.positions) ~= "table" then Config.positions = {} end
    local ok, p = pcall(function() return frame.Position end)
    if not ok or not p then return end
    Config.positions[name] = { xs = p.X.Scale, xo = p.X.Offset, ys = p.Y.Scale, yo = p.Y.Offset }
    if saveConfig then pcall(saveConfig) end
end
local function initToggles()
    setToggle("MutationPriorityOnly", Config.MutationPriorityOnly, true)
    setToggle("Anti Ragdoll", Config.AntiRagdoll, true)
    setToggle("Infinite Jump", Config.InfiniteJump, true)
    setToggle("Auto Kick", Config.AutoKickOnSteal, true)
    setToggle("Auto Buy", Config.AutoBuyEnabled, true)
    setToggle("Face Away", Config.FaceAway, true)
    setToggle("Face Nearest", Config.FaceAwayNearest, true)
    setToggle("Auto Steal", Config.AutoStealEnabled, true)
    setToggle("Steal Highest", Config.StealHighest, true)
    setToggle("Steal Priority", Config.StealPriority, true)
    setToggle("Steal Nearest", Config.StealNearest, true)
    Config.ClickToAP = false  -- always off on rejoin
    setToggle("Click to AP", false, true)
    setToggle("ClickToAP", false, true)
    setToggle("Click AP Single Cmd", Config.ClickToAPSingleCommand, true)
    setToggle("ClickToAPSingle", Config.ClickToAPSingleCommand, true)
    setToggle("FPS Boost (normal)", Config.FPSBoost, true)
    setToggle("FPS Boost (normal)", Config.FPSBoost, true)
    setToggle("FPS Boost Ultra", Config.FPSBoostUltra, true)
    setToggle("FPSBoostUltra", Config.FPSBoostUltra, true)
    setToggle("XRay", Config.XRay, true)
    setToggle("X-Ray", Config.XRay, true)
    setToggle("Xray", Config.XRay, true)
    setToggle("Proximity", Config.ProximityAP, true)

    setToggle("Player ESP", Config.PlayerESP, true)
    setToggle("Brainrot ESP", Config.BrainrotESP, true)
    setToggle("Timer ESP", Config.TimerESP, true)
    setToggle("Subspace Mine ESP", Config.SubspaceMineESP, true)
    setToggle("Base Owner ESP", Config.BaseOwnerESP, true)
    setToggle("Float", Config.Float, true)
    setToggle("Anti-Bee & Anti-Disco", Config.AntiBeeDisco, true)
    setToggle("AntiBeeDisco", Config.AntiBeeDisco, true)
    setToggle("Admin Panel UI", Config.AdminPanelUI, true)
    setToggle("Auto Invis During Steal", Config.AutoInvisDuringSteal, true)
    setToggle("Auto TP Priority Mode", Config.AutoTPPriority, true)
    setToggle("Auto TP Highest Gen", Config.AutoTPHighestGen, true)
    setToggle("Auto TP Highest Value", Config.AutoTPHighestValue, true)
    setToggle("Unwalk", Config.Unwalk, true)
    setToggle("Stealing ESP", Config.StealingESP, true)
    setToggle("WalkSpeed", Config.WalkSpeedEnabled, true)
    setToggle("Dark Mode", Config.DarkMode, true)
    setToggle("DarkMode", Config.DarkMode, true)
    setToggle("Grapple TP", Config.TpSettings.GrabbleTP or false, true)
    setToggle("Fly TP", Config.TpSettings.FlyTP or false, true)
    setToggle("OpenBase", Config.OpenBase or false, true)
end

loadConfig()
if Config.DarkMode then
    for k, v in pairs(Themes.Dark) do
        Theme[k] = v
    end
end
-- Restore saved binds. Two guards over the old one-liner: a key already taken
-- by another action is DROPPED (older configs were saved when two actions both
-- defaulted to K, and loading one silently recreated the collision), and a
-- reserved key is refused so a config written before KeybindReserved existed
-- cannot bind movement keys.
do
    -- Pass 1: apply what the user actually chose. A SAVED bind always beats a
    -- default -- doing it the other way round meant binding Clone to Y was
    -- silently refused because Kick's untouched default already held Y.
    local taken = {}
    if type(Config.keybinds) ~= "table" then Config.keybinds = {} end
    local saved = Config.keybinds
    for action, v in pairs(saved) do
        if Keybinds[action] ~= nil and type(v) == "string" then
            if v == "NONE" or KeybindReserved[v] or taken[v] then
                -- unbindable, or a genuine duplicate between two SAVED binds
                Keybinds[action] = "NONE"
                saved[action] = "NONE"
            else
                taken[v] = action
                Keybinds[action] = v
            end
        end
    end
    -- Pass 2: any default the user never touched now yields if a saved bind
    -- claimed its key.
    for action, key in pairs(Keybinds) do
        if saved[action] == nil and key ~= "NONE" then
            if taken[key] then Keybinds[action] = "NONE" else taken[key] = action end
        end
    end
    -- WRITE BACK EVERY BIND, NOT JUST THE ONES THE USER TOUCHED.
    --
    -- Config.keybinds only ever held actions that had been through the bind UI,
    -- so an untouched DEFAULT that pass 2 has just dropped (its key was claimed
    -- by a saved bind) was left unrecorded -- the row showed NONE, the config
    -- still said nothing, and on the next load pass 2 re-derived it from
    -- whatever the defaults happened to be that build. Saving the resolved
    -- table makes what the Keybinds tab shows and what is on disk the same
    -- thing, which is the only way "set a key, restart, it is still set" can be
    -- true for every row rather than most of them.
    -- BEFORE the write-back, so a repaired Open Menu is what gets persisted:
    -- a config that locked the panel out stays fixed instead of needing the
    -- repair again on every execute.
    Skyr0EnsureOpenMenuBind()
    local mudou = false
    for action, key in pairs(Keybinds) do
        if saved[action] ~= key then saved[action] = key; mudou = true end
    end
    -- Only when the resolve actually changed something, so a normal load is
    -- still a read and nothing else.
    if mudou and saveConfig then pcall(saveConfig) end
end
for k,v in pairs(Config.actions or {}) do if actionConfig[k]~=nil then actionConfig[k]=v and true or false end end
if type(Config.locked)=="boolean" then UI.Locked=Config.locked end
initToggles()





do
_G.stealthGet=function(n) return _G.XenSyncGet(n) end
_G.SyncInt={_cache={},_data=nil}
end

-- SYNCHRONIZER RelateChannels DETECTION NEUTER -- DISABLED to match Heresy Free.
-- This used to replace Synchronizer detector-fn upvalues with EXECUTOR closures
-- (debug.setupvalue + newcclosure) inline on execute. Injecting an executor
-- closure into a game module's upvalue is exactly what the anticheat integrity-
-- checks -- and it ran the instant you executed, which fits the instant kick.
-- Heresy Free never touches the Synchronizer functions and doesn't get kicked,
-- so this whole tamper is OFF. Channel reads are unaffected: they go through the
-- XenSyncGet stealth reader (reads CacheTable directly, never calls :Get), which
-- needs no neuter.
_G.__Skyr0_RelateKilled = false

-- Decrypted net
local Decrypted=setmetatable({},{__index=function(S,ez)
    local ok,Netty=pcall(function() return ReplicatedStorage.Packages.Net end); if not ok or not Netty then return nil end
    if ez:sub(1,3)~="RE/" and ez:sub(1,3)~="RF/" then return nil end
    local Remote; for i,v in ipairs(Netty:GetChildren()) do if v.Name==ez then local children=Netty:GetChildren(); Remote=children[i+1]; break end end
    if Remote and not rawget(Decrypted,ez) then rawset(Decrypted,ez,Remote) end; return rawget(Decrypted,ez)
end})



-- Short ASCII tags, not emoji: these are the admin-panel button LABELS, and a
-- glyph that renders as a box on a client without the font is a button nobody
-- can identify. Three characters keeps the buttons the same size.
AP_ALL_COMMANDS={"balloon","inverse","jail","jumpscare","morph","nightvision","ragdoll","rocket","tiny"}
AP_COMMAND_LABELS={balloon="BAL",inverse="INV",jail="JAIL",jumpscare="JMP",morph="MRPH",nightvision="NVIS",ragdoll="RAG",rocket="RKT",tiny="TINY"}
if not Config.ClickToAPCommands then
    Config.ClickToAPCommands = {}
    for _, cmd in ipairs(AP_ALL_COMMANDS) do Config.ClickToAPCommands[cmd] = true end
end
if not Config.AdminPanelButtons then
    Config.AdminPanelButtons = {ragdoll=true, jail=true, rocket=true, balloon=true}
end
if not Config.ClickToAPRadius then
    Config.ClickToAPRadius = 8
end
if not Config.SpamBaseOwnerCommands then
    Config.SpamBaseOwnerCommands = {}
    for _, cmd in ipairs(AP_ALL_COMMANDS) do Config.SpamBaseOwnerCommands[cmd] = true end
end
if not Config.SpamBaseOwnerOrder then
    Config.SpamBaseOwnerOrder = {}
    for i, cmd in ipairs(AP_ALL_COMMANDS) do Config.SpamBaseOwnerOrder[i] = cmd end
end
if Config.SpamBaseOwnerSingleCommand == nil then
    Config.SpamBaseOwnerSingleCommand = false
end
setToggle("SpamBaseOwnerSingleCommand", Config.SpamBaseOwnerSingleCommand or false)

_G.apBlacklist = Config.apBlacklist or {}

-- =====================================================================
-- GOODBOYS / BADBOYS  --  auto-fetched "family" list  (ported from Heresy Free)
-- ---------------------------------------------------------------------
-- A remote gist lists "good" players (never AP them -- folded into
-- isPlayerBlacklisted below) and "bad" players (marked). It is cached to disk,
-- applied on load, and refreshed at most once every 6h.
--
-- NOTE: the URL below is a hardcoded THIRD-PARTY gist -- whoever controls it
-- decides who this script treats as good/bad. Point it elsewhere or delete this
-- whole block if you don't want that.
-- =====================================================================
_G.SXEGoodBoys = _G.SXEGoodBoys or {}
_G.SXEBadBoys  = _G.SXEBadBoys  or {}
do
    local URL = "https://gist.githubusercontent.com/josecastle21/fcc5696b9d37ae086a324d99e6b8fa5e/raw/fmly_badboys.json"
    local HttpService = game:GetService("HttpService")
    local function httpGet(u)
        local req = (syn and syn.request) or (http and http.request) or http_request or request
        if req then
            local ok, res = pcall(req, { Url = u, Method = "GET" })
            if ok and res and res.Body then return res.Body end
        end
        local ok, body = pcall(function() return game:HttpGet(u) end)
        if ok then return body end
        return nil
    end
    local CACHE_FILE = "sxe_fmly_boys.json"
    local SIX_HOURS = 6 * 3600
    local lastFetch = 0
    local function applyArrays(goodArr, badArr)
        local good, bad = {}, {}
        if type(goodArr) == "table" then for _, n in ipairs(goodArr) do if type(n) == "string" then good[n:lower()] = true end end end
        if type(badArr) == "table" then for _, n in ipairs(badArr) do if type(n) == "string" then bad[n:lower()] = true end end end
        _G.SXEGoodBoys, _G.SXEBadBoys = good, bad
        if _G.refreshAdminPanelRows then pcall(_G.refreshAdminPanelRows) end
    end
    local function loadCache()
        local ok, raw = pcall(function()
            if isfile and isfile(CACHE_FILE) then return readfile(CACHE_FILE) end
        end)
        if ok and type(raw) == "string" then
            local ok2, c = pcall(function() return HttpService:JSONDecode(raw) end)
            if ok2 and type(c) == "table" then return c end
        end
        return nil
    end
    local function fetchAndSave()
        local body = httpGet(URL .. "?cb=" .. tostring(os.time()))
        if not body then return false end
        local ok, data = pcall(function() return HttpService:JSONDecode(body) end)
        if not ok or type(data) ~= "table" then return false end
        local goodArr = type(data.good) == "table" and data.good or {}
        local badArr  = type(data.bad)  == "table" and data.bad  or {}
        applyArrays(goodArr, badArr)
        lastFetch = os.time()
        pcall(function()
            if writefile then
                writefile(CACHE_FILE, HttpService:JSONEncode({ t = lastFetch, good = goodArr, bad = badArr }))
            end
        end)
        return true
    end
    task.spawn(function()
        local cache = loadCache()
        if cache then
            applyArrays(cache.good, cache.bad)
            if type(cache.t) == "number" then lastFetch = cache.t end
        end
        if (os.time() - lastFetch) >= SIX_HOURS then
            pcall(fetchAndSave)
        end
        while true do
            task.wait(1800)
            if (os.time() - lastFetch) >= SIX_HOURS then pcall(fetchAndSave) end
        end
    end)
end
_G.SXEIsGoodBoy = function(plr) return plr ~= nil and _G.SXEGoodBoys[tostring(plr.Name):lower()] == true end
_G.SXEIsBadBoy  = function(plr) return plr ~= nil and _G.SXEBadBoys[tostring(plr.Name):lower()] == true end

-- =====================================================================
-- BY-NAME BLACKLIST
-- ---------------------------------------------------------------------
-- The admin panel's Blacklist tab was written against three things that were
-- never implemented anywhere in this file:
--     Config.apBlacklistNames     -- never initialised (nil)
--     _G.apBlacklistAddName       -- never defined
--     _G.apBlacklistRemoveName    -- never defined
-- so opening that tab threw "invalid argument #1 to ipairs" on the nil list,
-- and both of its buttons would have errored too. Only the by-UserId list
-- above was ever real.
--
-- Names are stored lowercase and matched against BOTH Name and DisplayName, so
-- a name added while someone is offline still protects them when they join.
-- =====================================================================
Config.apBlacklistNames = Config.apBlacklistNames or {}

local function _nameIndex(name)
    local want = tostring(name or ""):lower()
    if want == "" then return nil end
    for i, n in ipairs(Config.apBlacklistNames) do
        if tostring(n):lower() == want then return i end
    end
    return nil
end

_G.apBlacklistAddName = function(name)
    name = tostring(name or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if name == "" then return false end
    if _nameIndex(name) then return false end          -- already listed
    table.insert(Config.apBlacklistNames, name)
    if saveConfig then pcall(saveConfig) end
    return true
end

_G.apBlacklistRemoveName = function(name)
    local i = _nameIndex(name)
    if not i then return false end
    table.remove(Config.apBlacklistNames, i)
    if saveConfig then pcall(saveConfig) end
    return true
end

local function isPlayerBlacklisted(plr)
    if not plr then return false end
    -- "goodboys" are protected the same way blacklisted players are: never AP them
    if _G.SXEIsGoodBoy and _G.SXEIsGoodBoy(plr) then return true end
    local uid = plr.UserId
    if _G.apBlacklist[uid] == true or _G.apBlacklist[tostring(uid)] == true then return true end
    -- the name list has to be honoured here too, or adding a name would show in
    -- the tab and protect nobody
    local n, d = tostring(plr.Name):lower(), tostring(plr.DisplayName or ""):lower()
    for _, entry in ipairs(Config.apBlacklistNames or {}) do
        local e = tostring(entry):lower()
        if e == n or (d ~= "" and e == d) then return true end
    end
    return false
end

-- Cached Synchronizer module. Re-requiring + WaitForChild on every call (inside
-- per-player loops) was a major admin-panel lag source; cache it once.
do
    local cached
    function _G.__getSync()
        if cached then return cached end
        local ok, mod = pcall(function()
            local pkgs = ReplicatedStorage:FindFirstChild("Packages")
            return pkgs and require(pkgs:WaitForChild("Synchronizer", 5))
        end)
        if ok then cached = mod end
        return cached
    end
end

-- NOTE: current-base-owner detection lives below as _G.__getCurrentBaseOwnerId,
-- right after getPlayerBaseInfo (it depends on getPlotAtPosition/getPlotOwner,
-- which are declared further down). Every player here owns their own base, so a
-- "who owns ANY base" check would (correctly but uselessly) flag everyone.

local function getPlotOwner(plot)
    if not plot then return nil end
    local Synchronizer = _G.__getSync()
    if Synchronizer then
        local ch = _G.Skyr0_GetPlotChannel(plot.Name)
        if ch then
            -- sProp (raw CacheTable) instead of ch:Get -- :Get is the hookable
            -- surface the RelateChannels snitch watches, and Owner is always in
            -- the client cache anyway.
            local owner = _G.Skyr0ChanGet and _G.Skyr0ChanGet(ch, "Owner")
            if owner then
                if typeof(owner) == "Instance" and owner:IsA("Player") then
                    return owner
                elseif type(owner) == "table" and owner.Name then
                    return Players:FindFirstChild(owner.Name)
                elseif type(owner) == "number" then
                    return Players:GetPlayerByUserId(owner)
                end
            end
        end
    end
    local sign = plot:FindFirstChild("PlotSign")
    local textLabel = sign
        and sign:FindFirstChild("SurfaceGui")
        and sign.SurfaceGui:FindFirstChild("Frame")
        and sign.SurfaceGui.Frame:FindFirstChild("TextLabel")
    if textLabel then
        local baseText = textLabel.Text
        local nickname = (baseText and baseText:match("^(.-)'")) or baseText
        if nickname then
            for _, p in ipairs(Players:GetPlayers()) do
                if (p.DisplayName == nickname) or (p.Name == nickname) then
                    return p
                end
            end
        end
    end
    return nil
end

local function getPlotAtPosition(pos)
    local plots = Workspace:FindFirstChild("Plots")
    if not plots then return nil end
    local closestPlot = nil
    local minDistance = math.huge
    for _, plot in ipairs(plots:GetChildren()) do
        local plotPos
        if plot:IsA("Model") then
            plotPos = plot.PrimaryPart and plot.PrimaryPart.Position or plot:GetPivot().Position
        else
            plotPos = plot.Position
        end
        if plotPos then
            local distH = math.sqrt((pos.X - plotPos.X)^2 + (pos.Z - plotPos.Z)^2)
            if distH < minDistance then
                minDistance = distH
                closestPlot = plot
            end
        end
    end
    if closestPlot and minDistance < 72 then
        return closestPlot
    end
    return nil
end

local function getPlayerBaseInfo(plr)
    if not plr or not plr.Character then return nil, nil end
    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil, nil end
    local plot = getPlotAtPosition(hrp.Position)
    if plot then
        return plot, getPlotOwner(plot)
    end
    return nil, nil
end

-- userId of the owner of the base the LOCAL player is currently standing in
-- (nil if none). Memoized ~0.4s and shared by all admin rows, so only ONE row
-- shows "Base Owner": the owner of the base you're actually in.
do
    local cachedId, lastT = nil, 0
    function _G.__getCurrentBaseOwnerId()
        local now = os.clock()
        if (now - lastT) < 0.4 then return cachedId end
        lastT = now
        cachedId = nil
        local _, owner = getPlayerBaseInfo(LocalPlayer)
        if owner then cachedId = owner.UserId end
        return cachedId
    end
end


-- (ADMIN COMMAND removed)



local function runAutoBaseActions()
    task.spawn(function()
        task.wait(1.5)
        local char = player.Character or player.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart", 10)
        if not hrp then return end
        
        local nearestPlayer = nil
        local nearestDist = math.huge
        local Plots = Workspace:FindFirstChild("Plots")
        if Plots then
            for _, plot in ipairs(Plots:GetChildren()) do
                local owner = getPlotOwner(plot)
                if owner and owner ~= player then
                    local sign = plot:FindFirstChild("PlotSign")
                    if sign then
                        local signPos = (sign:IsA("BasePart") and sign.Position) or (sign.PrimaryPart and sign.PrimaryPart.Position)
                        if signPos then
                            local dist = (hrp.Position - signPos).Magnitude
                            if dist < nearestDist then
                                nearestDist = dist
                                nearestPlayer = owner
                            end
                        end
                    end
                end
            end
        end
        
        if nearestPlayer then
            -- auto base actions removed
        end
    end)
end
_G.runAutoBaseActions = runAutoBaseActions



local function kickPlayer(stolenText)
    local isAutoKickSteal = false

    if stolenText and type(stolenText) == "string" then
        isAutoKickSteal = true
    end

    if Config.KickToPrivateServer and PrivateServerCode and PrivateServerCode ~= "" and isAutoKickSteal then
        task.delay(0.2, function()
            pcall(function()
                local ExperienceService = game:GetService("ExperienceService")
                ExperienceService:LaunchExperience({
                    placeId = game.PlaceId,
                    linkCode = PrivateServerCode,
                })
            end)
        end)
        return
    end
    pcall(function() game:Shutdown() end)
    pcall(function() LocalPlayer:Kick("") end)
end

-- SHARED STATE
SharedState = {SelectedPetData=nil, AllAnimalsCache={}, ListNeedsRedraw=true, InitialScanComplete=false, seenUIDs={}, BrainrotNames={}}
-- COVERAGE, for TP-on-load. PlotsTotal is how many bases exist; PlotsSeen maps
-- plot name -> true once that base has finished a scan and put its answer (even
-- an empty one) into the cache. PlotsScanned is the count.
--
-- This is what lets the teleport tell "my priority pet has not been scanned
-- yet" apart from "my priority pet is not on this server" -- two states that
-- look identical from the cache alone, and which the settle window had to
-- guess at by waiting for the scanner to go quiet.
SharedState.PlotsTotal, SharedState.PlotsSeen, SharedState.PlotsScanned = 0, {}, 0
-- PlotsFull counts the bases that reported with an actual SYNCHRONIZER CHANNEL
-- behind them, not just rendered models.
--
-- The difference decides how much the teleport is allowed to conclude. A base
-- that reported from rendered models alone has only told you what had streamed
-- in at that moment -- its channel can land a second later and reveal a pet
-- that was never on screen. A base that reported WITH a channel has given its
-- authoritative slot list, and nothing new is coming.
--
-- So PlotsScanned == PlotsTotal means "everyone has said something" (worth a
-- short settle), while PlotsFull == PlotsTotal means "everyone has said
-- everything" -- at which point a listed pet that is not in the cache is not on
-- this server, and there is nothing left to wait for at all.
SharedState.PlotsFull = 0

-- NOTIFICATION SYSTEM
local function ShowNotification(title, text)
    -- Disabled: all notifications removed by user request
    return
end

-- ============================================================
-- RESET -- REMOVED
-- ============================================================
-- The entire insta-reset subsystem is gone: the keyword remote scanner
-- (scanForRemotes / resetRemotes), the ToolActivationController FireServer
-- capture hook, the balloon-payload reset, the reset-remote spam loop, the
-- StarterGui ResetButtonCallback override and every log()/warn() call that
-- belonged to it. Nothing here fires a remote, installs a hook, or writes to
-- the console anymore, and the native Esc -> Reset button is left untouched.
--
-- Only the teleport-bypass notifier survives (other scripts call it); it is now
-- a no-op that keeps the old shape so nothing errors on a nil call.
_G.NotifyLocalTeleport = function() end
shared.NotifyLocalTeleport = _G.NotifyLocalTeleport


-- ============================================================
-- AUTO BUY (DTC port -- proximity buy on conveyor/podium purchase prompts)
-- ============================================================
local toggleAutoBuy
local function _initAutoBuyScope()
local autoBuyActive = false
pcall(function()
    local e = Workspace:FindFirstChild("XiAutoBuyRing")
    if e then e:Destroy() end
end)

local lockedTarget, lockedPart, lockedModel, bodyPos = nil, nil, nil, nil
local HOVER_HEIGHT = 5
local BUY_INTERVAL = 0.08

local RARITY_WORDS = {
    common=true,uncommon=true,rare=true,epic=true,legendary=true,secret=true,
    divine=true,rainbow=true,cursed=true,gold=true,diamond=true,
}
local function getBrainrotName(model)
    if not model then return "Brainrot","" end
    local nameFound,genFound="",""
    for _,bb in ipairs(model:GetDescendants()) do
        if bb:IsA("BillboardGui") then
            for _,lbl in ipairs(bb:GetDescendants()) do
                if lbl:IsA("TextLabel") and lbl.Text and lbl.Text~="" then
                    local t=lbl.Text:match("^%s*(.-)%s*$"); local tl=t:lower()
                    if RARITY_WORDS[tl] then continue end
                    if t:match("^%$[%d%.]+[KkMmBb]?/s$") then if genFound=="" then genFound=t end; continue end
                    if t:match("^%$[%d%.]+[KkMmBb]?$") then continue end
                    if t:match("^[%d%.]+[KkMmBb]?$") then continue end
                    if nameFound=="" and #t>1 then nameFound=t end
                end
            end
        end
    end
    if nameFound=="" then nameFound=model.Name~="" and model.Name or "Brainrot" end
    return nameFound,genFound
end

local function scanConveyor()
    local results={}
    for _,obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Enabled then
            local txt=obj.ActionText or ""
            if txt=="Purchase" or txt:lower():find("purchase") or txt:lower():find("comprar") then
                local part=obj.Parent; if not part then continue end
                local realPart=(part:IsA("Attachment") and part.Parent) or part
                if not (realPart and realPart:IsA("BasePart")) then continue end
                local model=nil; local cur=realPart
                for _=1,8 do if cur and cur:IsA("Model") then model=cur; break end; cur=cur and cur.Parent end
                local name,gen=getBrainrotName(model)
                table.insert(results,{name=name,gen=gen,prompt=obj,part=realPart,model=model,uid="conveyor_"..tostring(obj)})
            end
        end
    end
    local movingFolder=Workspace:FindFirstChild("RenderedMovingAnimals")
    if movingFolder then
        for _,model in ipairs(movingFolder:GetChildren()) do
            if model:IsA("Model") then
                for _,desc in ipairs(model:GetDescendants()) do
                    if desc:IsA("ProximityPrompt") and desc.Enabled then
                        local txt=desc.ActionText or ""
                        if txt=="Purchase" or txt:lower():find("purchase") or txt:lower():find("comprar") then
                            local part=desc.Parent; local realPart=(part:IsA("Attachment") and part.Parent) or part
                            if realPart and realPart:IsA("BasePart") then
                                local name,gen=getBrainrotName(model)
                                table.insert(results,{name=name,gen=gen,prompt=desc,part=realPart,model=model,uid="moving_"..tostring(desc)})
                            end
                        end
                    end
                end
            end
        end
    end
    return results
end

local purchaseRemote=nil
local function resolvePurchaseRemote()
    if purchaseRemote and purchaseRemote.Parent then return purchaseRemote end
    pcall(function()
        local net=ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("Net")
        if not net then return end
        local kws={"buy","purchase","animal","shop","acquire","conveyor"}
        for _,v in ipairs(net:GetChildren()) do
            local nl=(v.Name or ""):lower()
            for _,kw in ipairs(kws) do if nl:find(kw) then purchaseRemote=v; return end end
        end
    end)
    return purchaseRemote
end

local function firePurchaseNatural(prompt)
    if not prompt or not prompt.Parent or not prompt.Enabled then return end
    pcall(function() if fireproximityprompt then fireproximityprompt(prompt) end end)
    task.spawn(function()
        local remote=resolvePurchaseRemote()
        if remote then
            pcall(function()
                if remote:IsA("RemoteFunction") then remote:InvokeServer(prompt.Parent)
                elseif remote:IsA("RemoteEvent") then remote:FireServer(prompt.Parent) end
            end)
        end
    end)
end

local function partAlive() return lockedPart and lockedPart.Parent and lockedModel and lockedModel.Parent end
local function promptAlive() return lockedTarget and lockedTarget.prompt and lockedTarget.prompt.Parent and lockedTarget.prompt.Enabled end

local function ensureBodyPos(hrp)
    local speed=math.clamp(tonumber(Config.AutoGrabSpeed) or 17,1,50)
    if bodyPos and bodyPos.Parent==hrp then bodyPos.P=speed*1000; return bodyPos end
    if bodyPos then bodyPos:Destroy() end
    local bp=Instance.new("BodyPosition",hrp); bp.MaxForce=Vector3.new(math.huge,math.huge,math.huge)
    bp.P=speed*1000; bp.D=1000; bp.Position=hrp.Position; bodyPos=bp; return bp
end
local function destroyBodyPos() if bodyPos then bodyPos:Destroy(); bodyPos=nil end end

RunService.Heartbeat:Connect(function()
    if not autoBuyActive or not partAlive() then if bodyPos then destroyBodyPos() end; return end
    local char=LocalPlayer.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then destroyBodyPos(); return end
    ensureBodyPos(hrp).Position=lockedPart.Position+Vector3.new(0,HOVER_HEIGHT,0)
end)
task.spawn(function()
    while true do task.wait(BUY_INTERVAL)
        if autoBuyActive and partAlive() and promptAlive() then firePurchaseNatural(lockedTarget.prompt) end
    end
end)
task.spawn(function()
    while true do task.wait(0.25)
        if not autoBuyActive then
            if lockedTarget or lockedPart or lockedModel then lockedTarget,lockedPart,lockedModel=nil,nil,nil; destroyBodyPos() end
            continue
        end
        if lockedPart or lockedModel then if not partAlive() then lockedTarget,lockedPart,lockedModel=nil,nil,nil end; continue end
        local char=LocalPlayer.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart"); if not hrp then continue end
        local radius=tonumber(Config.AutoBuyRange) or 17
        local best,bestDist=nil,math.huge
        for _,entry in ipairs(scanConveyor()) do
            if entry.prompt and entry.prompt.Parent and entry.prompt.Enabled and entry.part and entry.part.Parent then
                local d=(hrp.Position-entry.part.Position).Magnitude
                if d<=radius and d<bestDist then bestDist,best=d,entry end
            end
        end
        if best then lockedTarget=best; lockedPart=best.part; lockedModel=best.model or best.part.Parent end
    end
end)

toggleAutoBuy=function(on)
    if type(on)=="boolean" then autoBuyActive=on else autoBuyActive=not autoBuyActive end
    Config.AutoBuyEnabled=autoBuyActive; pcall(saveConfig); pcall(setToggle,"Auto Buy",autoBuyActive)
    if not autoBuyActive then
        lockedTarget,lockedPart,lockedModel=nil,nil,nil; destroyBodyPos()
        pcall(function() local e=Workspace:FindFirstChild("XiAutoBuyRing"); if e then e:Destroy() end end)
    end
    if _G.AutoBuyOnToggle then pcall(_G.AutoBuyOnToggle,autoBuyActive) end
end
_G.Skyr0ToggleAutoBuy=function(v) toggleAutoBuy(v) end
end
_initAutoBuyScope()
-- ============================================================

-- CLONE
-- Returns true only if the TeleportToClone button was actually fired, so callers
-- (the Clone-TP engine) can tell a real clone swap from a silent bail-out and fall
-- back to the raw remotes instead of flying on as if the clone had happened.
local function instantClone()
    local c=player.Character; if not c then return false end
    local h=c:FindFirstChildOfClass("Humanoid"); if not h then return false end
    local cl=player.Backpack:FindFirstChild("Quantum Cloner") or c:FindFirstChild("Quantum Cloner"); if not cl then return false end
    pcall(function() h:UnequipTools() end); task.wait()
    if cl.Parent~=c then h:EquipTool(cl); task.wait() end
    -- The ToolsFrames/QuantumCloner UI is built when the cloner equips, so give it
    -- a few frames to appear instead of bailing on the first miss.
    local tb
    do
        local t0=os.clock()
        repeat
            local tf=playerGui:FindFirstChild("ToolsFrames"); local qc=tf and tf:FindFirstChild("QuantumCloner")
            tb=qc and qc:FindFirstChild("TeleportToClone")
            if tb then break end
            task.wait(0.03)
        until os.clock()-t0>0.5
    end
    if not tb then return false end
    _G.isCloning=true; cl:Activate(); task.wait(0.05); tb.Visible=true
    pcall(function() firesignal(tb.MouseButton1Click) end)
    pcall(function() firesignal(tb.MouseButton1Up) end)
    pcall(function() firesignal(tb.Activated) end)
    task.delay(0.55, function() _G.isCloning=false end)
    return true
end
_G.Skyr0InstantClone = instantClone -- exposed so the auto Clone-TP engine reuses the exact manual method

-- DROP BRAINROT
local _wfConns,_wfActive={},false
local function stopWalkFling() _wfActive=false; for _,c in ipairs(_wfConns) do if typeof(c)=="RBXScriptConnection" then c:Disconnect() end end; _wfConns={} end
local function startWalkFling()
    _wfActive=true; local ch=player.Character; if not ch then return end
    local rr=ch:FindFirstChild("HumanoidRootPart")
    for _,o in pairs(Workspace.CurrentCamera:GetChildren()) do if o.Name=="HumanoidRootPart" then rr=o; break end end
    if not rr then return end
    table.insert(_wfConns,RunService.Stepped:Connect(function() if not _wfActive then return end
        for _,p in ipairs(Players:GetPlayers()) do if p~=player and p.Character then for _,pt in ipairs(p.Character:GetChildren()) do if pt:IsA("BasePart") then pt.CanCollide=false end end end end
    end))
    local co=coroutine.create(function()
        if _G.invisibleStealEnabled then rr.CFrame=rr.CFrame*CFrame.new(0,3,0) end
        while _wfActive do RunService.Heartbeat:Wait(); if not rr or not rr.Parent then break end
            local v=rr.Velocity; rr.Velocity=v*10000+Vector3.new(0,10000,0)
            RunService.RenderStepped:Wait(); if rr then rr.Velocity=v end
            RunService.Stepped:Wait(); if rr then rr.Velocity=v+Vector3.new(0,0.1,0) end
        end
    end); coroutine.resume(co); table.insert(_wfConns,co)
end
local function runDropBrainrot() if _wfActive then return end; startWalkFling(); task.delay(0.4,stopWalkFling) end

-- ============================================================
-- INVISIBLE STEAL
-- ============================================================
do
local animPlaying = false
local tracks = {}
local clone, oldRoot, hip, connection
local folderConnections = {}
local serverGhosts = {}
local ghostEnabled = true
local lagbackCallCount = 0
local lagbackWindowStart = 0
local lastLagbackTime = 0
local errorOrbActive = false
local errorOrb = nil
local errorOrbConnection = nil

_G.invisibleStealEnabled = false
_G.InvisStealAngle = Config.InvisStealAngle or 225
_G.SinkSliderValue = Config.SinkSliderValue or 7
_G.AutoRecoverLagback = Config.AutoRecoverLagback ~= nil and Config.AutoRecoverLagback or true
_G.AutoInvisDuringSteal = Config.AutoInvisDuringSteal or false

local function clearErrorOrb()
    if errorOrb and errorOrb.Parent then errorOrb:Destroy() end
    errorOrb = nil; errorOrbActive = false
    if errorOrbConnection then errorOrbConnection:Disconnect(); errorOrbConnection = nil end
end

local function createErrorOrb()
    if errorOrbActive then return end
    errorOrbActive = true
    for _, ghost in pairs(serverGhosts) do if ghost and ghost.Parent then ghost:Destroy() end end
    serverGhosts = {}
    -- Error UI notifications disabled
end

local function createServerGhost(position)
    if not ghostEnabled or errorOrbActive then return end
    local now = tick()
    if now - lastLagbackTime < 0.05 then return end
    lastLagbackTime = now
    if now - lagbackWindowStart > 1 then lagbackCallCount = 0; lagbackWindowStart = now end
    lagbackCallCount = lagbackCallCount + 1
    if lagbackCallCount >= 7 then createErrorOrb(); return end
    for _, g in pairs(serverGhosts) do if g and g.Parent then g:Destroy() end end
    serverGhosts = {}
    local ghost = Instance.new("Part")
    ghost.Name = "LagbackGhost"; ghost.Shape = Enum.PartType.Ball
    ghost.Size = Vector3.new(3, 3, 3); ghost.Color = Color3.fromRGB(255, 0, 0)
    ghost.Material = Enum.Material.Glass; ghost.Transparency = 0.3
    ghost.CanCollide = false; ghost.Anchored = true; ghost.CastShadow = false
    ghost.Position = position + Vector3.new(0, 5, 0); ghost.Parent = Workspace.CurrentCamera
    table.insert(serverGhosts, ghost)
    -- Lagback text notifications & billboard GUIs disabled
end

local function clearAllGhosts()
    for _, ghost in pairs(serverGhosts) do pcall(function() if ghost and ghost.Parent then ghost:Destroy() end end) end
    serverGhosts = {}; clearErrorOrb(); lagbackCallCount = 0; lastLagbackTime = 0
    pcall(function()
        local pg = player:FindFirstChild("PlayerGui")
        if pg then for _, gui in pairs(pg:GetChildren()) do if gui.Name == "LagbackNotification" then gui:Destroy() end end end
    end)
    pcall(function() if Workspace.CurrentCamera then for _, c in pairs(Workspace.CurrentCamera:GetChildren()) do if c.Name == "LagbackGhost" then c:Destroy() end end end end)
    pcall(function() for _, c in pairs(Workspace:GetDescendants()) do if c.Name == "LagbackGhost" then c:Destroy() end end end)
end

local function removeFolders()
    local pf = Workspace:FindFirstChild(player.Name)
    if not pf then return end
    local dr = pf:FindFirstChild("DoubleRig")
    if dr then
        local rr = dr:FindFirstChild("HumanoidRootPart") or dr:FindFirstChildWhichIsA("BasePart")
        if rr and ghostEnabled then createServerGhost(rr.Position) end
        dr:Destroy()
    end
    local cs = pf:FindFirstChild("Constraints")
    if cs then cs:Destroy() end
    local conn = pf.ChildAdded:Connect(function(child)
        if child.Name == "DoubleRig" then
            task.defer(function()
                local rr = child:FindFirstChild("HumanoidRootPart") or child:FindFirstChildWhichIsA("BasePart")
                if rr and ghostEnabled then createServerGhost(rr.Position) end
                child:Destroy()
            end)
        elseif child.Name == "Constraints" then child:Destroy() end
    end)
    table.insert(folderConnections, conn)
end

local function doClone()
    local character = player.Character
    if character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
        hip = character.Humanoid.HipHeight
        oldRoot = character:FindFirstChild("HumanoidRootPart")
        if not oldRoot or not oldRoot.Parent then return false end
        for _, c in pairs(oldRoot:GetChildren()) do
            if c:IsA("Attachment") and (c.Name:find("Beam") or c.Name:find("Attach")) then c:Destroy() end
        end
        for _, c in pairs(oldRoot:GetChildren()) do if c:IsA("Beam") then c:Destroy() end end
        local tmp = Instance.new("Model"); tmp.Parent = game
        character.Parent = tmp
        clone = oldRoot:Clone(); clone.Parent = character
        oldRoot.Parent = Workspace.CurrentCamera
        clone.CFrame = oldRoot.CFrame; character.PrimaryPart = clone
        character.Parent = Workspace
        for _, v in pairs(character:GetDescendants()) do
            if v:IsA("Weld") or v:IsA("Motor6D") then
                if v.Part0 == oldRoot then v.Part0 = clone end
                if v.Part1 == oldRoot then v.Part1 = clone end
            end
        end
        tmp:Destroy(); return true
    end
    return false
end

local function revertClone()
    local character = player.Character
    if not oldRoot or not oldRoot:IsDescendantOf(Workspace) or not character or character.Humanoid.Health <= 0 then return end
    local tmp = Instance.new("Model"); tmp.Parent = game
    character.Parent = tmp
    oldRoot.Parent = character; character.PrimaryPart = oldRoot
    character.Parent = Workspace; oldRoot.CanCollide = true
    for _, v in pairs(character:GetDescendants()) do
        if v:IsA("Weld") or v:IsA("Motor6D") then
            if v.Part0 == clone then v.Part0 = oldRoot end
            if v.Part1 == clone then v.Part1 = oldRoot end
        end
    end
    if clone then local p = clone.CFrame; clone:Destroy(); clone = nil; oldRoot.CFrame = p end
    oldRoot = nil
    if character and character.Humanoid then character.Humanoid.HipHeight = hip end
    clearAllGhosts()
end

local function animationTrickery()
    local character = player.Character
    if character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
        local anim = Instance.new("Animation")
        anim.AnimationId = "http://www.roblox.com/asset/?id=18537363391"
        local humanoid = character.Humanoid
        local animator = humanoid:FindFirstChild("Animator") or Instance.new("Animator", humanoid)
        local animTrack = animator:LoadAnimation(anim)
        animTrack.Priority = Enum.AnimationPriority.Action4
        animTrack:Play(0, 1, 0); anim:Destroy()
        table.insert(tracks, animTrack)
        animTrack.Stopped:Connect(function() if animPlaying then animationTrickery() end end)
        task.delay(0, function()
            animTrack.TimePosition = 0.7
            task.delay(0.3, function() if animTrack then animTrack:AdjustSpeed(math.huge) end end)
        end)
    end
end

local _invisToggleCooldown = 0

local function invisTurnOff()
    clearAllGhosts()
    if not animPlaying then return end
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    animPlaying = false; _G.invisibleStealEnabled = false
    setToggle("Invisible Steal", false)
    for _, t in pairs(tracks) do pcall(function() t:Stop(0) end) end
    tracks = {}
    if connection then connection:Disconnect(); connection = nil end
    for _, c in ipairs(folderConnections) do if c then c:Disconnect() end end
    folderConnections = {}
    revertClone(); clearAllGhosts()
    -- Force reset all animations back to default
    if humanoid then
        pcall(function()
            local animator = humanoid:FindFirstChildOfClass("Animator")
            if animator then
                for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                    if track.Priority == Enum.AnimationPriority.Action4 or track.Priority == Enum.AnimationPriority.Action3 then
                        track:Stop(0)
                    end
                end
            end
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            task.defer(function()
                if humanoid and humanoid.Parent then
                    humanoid:ChangeState(Enum.HumanoidStateType.Running)
                end
            end)
        end)
    end
    if _G.updateMovementPanelInvisVisual then pcall(_G.updateMovementPanelInvisVisual, false) end
    -- Instantly disable walkspeed when invis steal turns off
    if WalkSpeedState and WalkSpeedState.enabled and Config.WalkSpeedEnabled then
        setWalkSpeedEnabled(false)
    end
    _invisToggleCooldown = tick()
end

local function invisTurnOn()
    if animPlaying then return end
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    animPlaying = true; _G.invisibleStealEnabled = true
    setToggle("Invisible Steal", true)
    if _G.updateMovementPanelInvisVisual then pcall(_G.updateMovementPanelInvisVisual, true) end
    tracks = {}; removeFolders()
    local success = doClone()
    if success then
        task.wait(0.05); animationTrickery()
        task.defer(function()
            if _G.resetBrainrotBeam then pcall(_G.resetBrainrotBeam) end
            if _G.resetPlotBeam then pcall(_G.resetPlotBeam) end
            task.wait(0.1)
            if _G.updateBrainrotBeam then pcall(_G.updateBrainrotBeam) end
            if _G.createPlotBeam then pcall(_G.createPlotBeam) end
        end)
        -- Enable walkspeed 1 second after invis steal activates
        task.delay(1, function()
            if _G.invisibleStealEnabled and not WalkSpeedState.enabled then
                setWalkSpeedEnabled(true)
            end
        end)
        local lastSetPosition = nil; local skipFrames = 5
        connection = RunService.PreSimulation:Connect(function()
            if character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 and oldRoot then
                local root = character.PrimaryPart or character:FindFirstChild("HumanoidRootPart")
                if root then
                    if skipFrames > 0 then skipFrames = skipFrames - 1; lastSetPosition = nil
                    elseif lastSetPosition and ghostEnabled then
                        local currentPos = oldRoot.Position
                        local jumpDist = (currentPos - lastSetPosition).Magnitude
                        if jumpDist > 6 and not _G.RecoveryInProgress and player:GetAttribute("Stealing") then
                            lastSetPosition = nil; createServerGhost(currentPos)
                            if _G.AutoRecoverLagback and _G._forceInvisToggle then
                                _G.RecoveryInProgress = true
                                task.spawn(function()
                                    pcall(_G._forceInvisToggle); task.wait(0.6)
                                    if player:GetAttribute("Stealing") then
                                        pcall(_G._forceInvisToggle)
                                    end
                                    _G.RecoveryInProgress = false
                                end)
                            end
                        end
                    end
                    if clone then clone.CanCollide = true end
                    if oldRoot and oldRoot.Parent then
                        for _, c in pairs(oldRoot:GetChildren()) do
                            if c:IsA("Attachment") or c:IsA("Beam") then c:Destroy() end
                        end
                        local sa = (_G.SinkSliderValue or 7) * 0.5
                        local cf = root.CFrame - Vector3.new(0, sa, 0)
                        oldRoot.CFrame = cf * CFrame.Angles(math.rad(_G.InvisStealAngle or 225), 0, 0)
                        oldRoot.AssemblyLinearVelocity = root.AssemblyLinearVelocity; oldRoot.CanCollide = false
                        lastSetPosition = oldRoot.Position
                    end
                end
            end
        end)
    end
end

_G.toggleInvisibleSteal = function()
    if (tick() - _invisToggleCooldown) < 0.3 then return end
    if animPlaying then invisTurnOff() else invisTurnOn() end
end

-- Force toggle that bypasses debounce (for auto-recover and auto-invis)
_G._forceInvisToggle = function()
    if animPlaying then invisTurnOff() else invisTurnOn() end
end

player.CharacterAdded:Connect(function(newChar)
    task.wait(0.1)
    if Config then Config.ClickToAP = false end
    clearErrorOrb(); clearAllGhosts(); lagbackCallCount = 0
    pcall(function() for _, c in pairs(Workspace.CurrentCamera:GetChildren()) do if c:IsA("BasePart") and c.Name == "HumanoidRootPart" then c:Destroy() end end end)
    if oldRoot then pcall(function() oldRoot:Destroy() end); oldRoot = nil end
    if clone then pcall(function() clone:Destroy() end); clone = nil end
    animPlaying = false; _G.invisibleStealEnabled = false
    setToggle("Invisible Steal", false)
    if _G.updateMovementPanelInvisVisual then pcall(_G.updateMovementPanelInvisVisual, false) end
    task.wait(0.2)
    local camera = Workspace.CurrentCamera
    if camera and newChar then
        local h = newChar:FindFirstChildOfClass("Humanoid")
        if h then camera.CameraSubject = h; camera.CameraType = Enum.CameraType.Custom end
    end
end)

local function setupDeathListener()
    local ch = player.Character
    if ch then
        local h = ch:FindFirstChildOfClass("Humanoid")
        if h then h.Died:Connect(function() clearErrorOrb(); clearAllGhosts(); lagbackCallCount = 0 end) end
    end
end
setupDeathListener()
player.CharacterAdded:Connect(function() task.wait(0.1); setupDeathListener() end)

-- ANTI-DIE
task.spawn(function()
    _G.AntiDieDisabled = false
    local function setupAntiDie()
        if _G.AntiDieDisabled then return end
        local character = player.Character
        if not character then return end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end
        if _G.AntiDieConnection then pcall(function() _G.AntiDieConnection:Disconnect() end) end
        _G.AntiDieConnection = humanoid:GetPropertyChangedSignal("Health"):Connect(function()
            if _G.AntiDieDisabled then return end
            if humanoid.Health <= 0 then
                humanoid.Health = humanoid.MaxHealth
            end
        end)
    end
    _G.setupAntiDie = setupAntiDie
    setupAntiDie()
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if not _G.AntiDieDisabled then
            setupAntiDie()
        end
    end)
end)

-- Automatic Invis During Steal Loop
task.spawn(function()
    local wasStealingForInvis = false
    local autoEnabledInvis = false
    task.wait(1)
    while task.wait(0.15) do
        if Config.AutoInvisDuringSteal == false then
            wasStealingForInvis = false
            autoEnabledInvis = false
        else
            local isStealing = player:GetAttribute("Stealing")
            if isStealing and not wasStealingForInvis then
                if not _G.invisibleStealEnabled and _G._forceInvisToggle then
                    task.defer(function()
                        if player:GetAttribute("Stealing") and not _G.invisibleStealEnabled then
                            pcall(_G._forceInvisToggle)
                            autoEnabledInvis = true
                        end
                    end)
                end
            end
            if not isStealing and autoEnabledInvis and _G.invisibleStealEnabled and _G._forceInvisToggle then
                task.wait(0.3)
                if not player:GetAttribute("Stealing") then
                    pcall(_G._forceInvisToggle)
                    autoEnabledInvis = false
                end
            end
            wasStealingForInvis = isStealing
        end
    end
end)

-- FLOAT
FloatState={active=false,platform=nil,followConn=nil}
local function removeFloatPlatform() if FloatState.followConn then FloatState.followConn:Disconnect(); FloatState.followConn=nil end; if FloatState.platform then FloatState.platform:Destroy(); FloatState.platform=nil end end
local function createFloatPlatform()
    removeFloatPlatform(); local c=player.Character; local hrp=c and c:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local p=Instance.new("Part"); p.Size=Vector3.new(7,1,7); p.Anchored=true; p.CanCollide=true; p.CanTouch=false; p.CanQuery=false
    p.Transparency=1; p.CastShadow=false; p.CFrame=CFrame.new(hrp.Position-Vector3.new(0,3.35,0)); p.Parent=Workspace; FloatState.platform=p
    FloatState.followConn=RunService.Heartbeat:Connect(function() if not FloatState.active then return end
        local ch=player.Character; local h=ch and ch:FindFirstChild("HumanoidRootPart")
        if h and FloatState.platform then FloatState.platform.CFrame=CFrame.new(h.Position-Vector3.new(0,3.35,0)) end
    end)
end
local function setFloat(on) FloatState.active=on; Config.Float=on; saveConfig(); setToggle("Float",on); if on then createFloatPlatform() else removeFloatPlatform() end end
_G.toggleFloat=function() setFloat(not FloatState.active) end

-- WALKSPEED (CFrame Bypass)
WalkSpeedState = {enabled = false, conn = nil, speed = Config.WalkSpeedValue or 16}
local function setWalkSpeedEnabled(en)
    WalkSpeedState.enabled = en
    Config.WalkSpeedEnabled = en
    setToggle("WalkSpeed", en)
    saveConfig()
    if WalkSpeedState.conn then WalkSpeedState.conn:Disconnect(); WalkSpeedState.conn = nil end
    if not en then return end
    WalkSpeedState.conn = RunService.Heartbeat:Connect(function(dt)
        local character = player.Character
        if not character then return end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoid or not rootPart or humanoid.Health <= 0 then return end
        if humanoid.MoveDirection.Magnitude > 0 and WalkSpeedState.speed > humanoid.WalkSpeed then
            local extraSpeed = WalkSpeedState.speed - humanoid.WalkSpeed
            rootPart.CFrame = rootPart.CFrame + (humanoid.MoveDirection * extraSpeed * dt)
        end
    end)
end
local function setWalkSpeedValue(v)
    v = math.clamp(math.floor(v + 0.5), 15, 29)
    WalkSpeedState.speed = v
    Config.WalkSpeedValue = v
    saveConfig()
    return v
end
_G.setWalkSpeedEnabled = setWalkSpeedEnabled
_G.setWalkSpeedValue = setWalkSpeedValue

-- CARPET SPEED
CarpetState={enabled=false,conn=nil}
local function setCarpetSpeed(en)
    -- Refuse to ARM while stealing, not just to skip the velocity write below.
    -- Flipping the toggle mid-steal used to leave it enabled and waiting, so it
    -- snapped to 140 studs/s the instant the steal ended -- which is the moment
    -- the server is still watching you.
    if en and _G.Skyr0IsStealing and _G.Skyr0IsStealing() then
        warn("[skyr0] Carpet Speed blocked: you are stealing.")
        setToggle("Carpet Speed", false)
        CarpetState.enabled = false
        return
    end
    CarpetState.enabled=en; setToggle("Carpet Speed",en)
    if CarpetState.conn then CarpetState.conn:Disconnect(); CarpetState.conn=nil end; if not en then return end
    CarpetState.conn=RunService.Heartbeat:Connect(function() local c=player.Character; if not c then return end
        -- Do NOT apply the carpet speed boost while stealing/teleporting: the ~140 studs/s speed
        -- difference during a steal is exactly what the anti-cheat scans for, so pause it then.
        if (_G.Skyr0IsTpBusy and _G.Skyr0IsTpBusy() or (not _G.Skyr0IsTpBusy and _G._isTpMoving)) or player:GetAttribute("Stealing") then return end
        local hum=c:FindFirstChild("Humanoid"); local hrp=c:FindFirstChild("HumanoidRootPart"); if not hum or not hrp then return end
        local tn=Config.TpSettings.Tool or "Flying Carpet"; if not c:FindFirstChild(tn) then local tb=player.Backpack:FindFirstChild(tn); if tb then hum:EquipTool(tb) end end
        if c:FindFirstChild(tn) then local md=hum.MoveDirection; if md.Magnitude>0 then hrp.AssemblyLinearVelocity=Vector3.new(md.X*140,hrp.AssemblyLinearVelocity.Y,md.Z*140) else hrp.AssemblyLinearVelocity=Vector3.new(0,hrp.AssemblyLinearVelocity.Y,0) end end
    end)
end

-- INFINITE JUMP (0.1s cooldown, 55 velocity)
InfJumpState={enabled=false,conn=nil,lastJump=0}
local function setInfiniteJump(en) InfJumpState.enabled=en; Config.InfiniteJump=en; Config.TpSettings.InfiniteJump=en; setToggle("Infinite Jump",en); saveConfig()
    if InfJumpState.conn then InfJumpState.conn:Disconnect(); InfJumpState.conn=nil end; if not en then return end
    InfJumpState.conn=RunService.Heartbeat:Connect(function() if not UIS:IsKeyDown(Enum.KeyCode.Space) then return end
        local now=tick(); if now-InfJumpState.lastJump<0.1 then return end; local c=player.Character; if not c then return end
        local hrp=c:FindFirstChild("HumanoidRootPart"); local hum=c:FindFirstChild("Humanoid"); if not hrp or not hum or hum.Health<=0 then return end
        InfJumpState.lastJump=now; hrp.AssemblyLinearVelocity=Vector3.new(hrp.AssemblyLinearVelocity.X,55,hrp.AssemblyLinearVelocity.Z)
    end)
end

-- ANTI RAGDOLL
-- Anti-Ragdoll System (comprehensive with knockback suppression)
do
    local antiRagdollConnections = {}
    local antiRagdollCharacter, antiRagdollHumanoid, antiRagdollRootPart, antiRagdollAnimator
    local lastVelocity = Vector3.new(0, 0, 0)
    -- ===================================================================
    -- Forward-declared: the ragdoll timer below closes over it, and Lua
    -- closures cannot see a local declared after them -- without this the name
    -- would resolve as a nil global inside the timer coroutine.
    local isRagdolled

    -- RAGDOLL TIMER (driven by _ragdollHit below)
    -- -------------------------------------------------------------------
    -- 2.6s is the NOMINAL ragdoll duration and the countdown reads from it;
    -- the auto-grab is restarted when the count reaches 1.6s REMAINING.
    --
    -- The first version was a blind 2.6s stopwatch started on the first
    -- knockdown and latched until it expired, which is why it was sometimes
    -- wrong in both directions:
    --   * CHAIN KNOCKDOWNS were swallowed. Get hit again 1s in and the latch
    --     ignored it, so the bar kept counting down from the FIRST hit and hit
    --     zero while you were still on the floor.
    --   * SHORT RAGDOLLS ran long. Back up in 0.8s and the bar still showed
    --     ~1.8s of phantom time.
    --
    -- It now tracks the real thing. While a ragdoll is genuinely active the
    -- game keeps re-applying it -- anti-ragdoll forces Running, the server puts
    -- you back into Physics, and round it goes -- so knockdown signals arrive
    -- in a continuous stream and stop only when the ragdoll actually ends.
    -- _ragLastHit timestamps that stream: every new signal restarts the count,
    -- and RAG_QUIET seconds of silence means you are really up.
    -- ===================================================================
    local RAGDOLL_TIMER   = 2.6     -- nominal duration the countdown reads from
    local GRAB_RESUME_AT  = 1.6     -- restart auto grab at this many seconds left
    local RAG_QUIET       = 0.35    -- no new knockdown signal for this long => up
    local RAG_MIN         = 0.25    -- never close out faster than this
    local _ragTimerActive = false
    local _ragT0          = 0       -- start of the CURRENT count (moves on re-hit)
    local _ragLastHit     = 0       -- most recent knockdown signal

    -- ===================================================================
    -- RAGDOLL TIMER ESP -- countdown billboard above your own head.
    -- -------------------------------------------------------------------
    -- Parented to the Head so it tracks the character rather than sitting in
    -- a fixed screen slot. Torn down when the count reaches zero, and again
    -- defensively on the next knockdown, so one can never be orphaned.
    -- _G.Skyr0RagdollESP = false turns it off without touching the timer.
    -- ===================================================================
    local _ragESP = nil
    local function _killRagdollESP()
        if _ragESP then pcall(function() _ragESP:Destroy() end); _ragESP = nil end
    end
    local function _showRagdollESP()
        _killRagdollESP()
        if _G.Skyr0RagdollESP == false then return end
        local char = antiRagdollCharacter or player.Character
        local head = char and char:FindFirstChild("Head")
        if not head then return end

        local bb = Instance.new("BillboardGui")
        bb.Name = "Skyr0RagdollTimer"
        bb.Size = UDim2.new(0, 130, 0, 44)
        bb.StudsOffset = Vector3.new(0, 3.2, 0)
        bb.AlwaysOnTop = true
        bb.LightInfluence = 0
        bb.MaxDistance = 200

        local card = Instance.new("Frame", bb)
        card.Size = UDim2.new(1, 0, 1, 0)
        card.BackgroundColor3 = Color3.fromRGB(6, 4, 14)
        card.BackgroundTransparency = 0.15
        card.BorderSizePixel = 0
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
        local st = Instance.new("UIStroke", card)
        st.Color = Color3.fromRGB(235, 235, 235); st.Thickness = 2; st.Transparency = 0.1

        local title = Instance.new("TextLabel", card)
        title.Size = UDim2.new(1, -8, 0, 15); title.Position = UDim2.new(0, 4, 0, 3)
        title.BackgroundTransparency = 1; title.Text = "RAGDOLL"
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.Font = Enum.Font.GothamBlack; title.TextSize = 11
        title.TextStrokeTransparency = 0.5

        local timeLbl = Instance.new("TextLabel", card)
        timeLbl.Size = UDim2.new(1, -8, 0, 22); timeLbl.Position = UDim2.new(0, 4, 0, 18)
        timeLbl.BackgroundTransparency = 1
        timeLbl.Text = string.format("%.1fs", RAGDOLL_TIMER)
        timeLbl.TextColor3 = Color3.fromRGB(255, 110, 110)
        timeLbl.Font = Enum.Font.GothamBlack; timeLbl.TextSize = 18
        timeLbl.TextStrokeTransparency = 0.5

        bb.Parent = head
        _ragESP = bb

        -- Reads _ragT0 live rather than capturing it, so a chain knockdown --
        -- which moves _ragT0 forward -- visibly restarts the count on screen
        -- instead of continuing to drain toward zero while you are still down.
        -- Same clock the resume threshold uses, so the number you see is the
        -- number that decides.
        task.spawn(function()
            while bb.Parent do
                local remaining = RAGDOLL_TIMER - (tick() - _ragT0)
                if remaining <= 0 then break end
                timeLbl.Text = string.format("%.1fs", remaining)
                -- turns red once the auto-grab resume point has passed
                timeLbl.TextColor3 = (remaining <= GRAB_RESUME_AT)
                    and Color3.fromRGB(255, 110, 110) or Color3.fromRGB(255, 110, 110)
                RunService.Heartbeat:Wait()
            end
            if _ragESP == bb then _killRagdollESP() end
        end)
    end

    -- ===================================================================
    -- _ragdollHit -- called for EVERY knockdown signal, not just the first.
    -- -------------------------------------------------------------------
    -- Two callers, because not every ragdoll announces itself the same way:
    --   * Humanoid.StateChanged into Physics / Ragdoll / FallingDown
    --   * a ragdoll constraint (BallSocket / NoCollision / Hinge) appearing on
    --     the character -- some knockdowns land as pure constraints and never
    --     produce a state change the client sees
    --
    -- Re-entry is the point: while you are actually down these arrive
    -- continuously, each one pushes _ragT0 forward, and the countdown restarts
    -- rather than expiring underneath you.
    -- ===================================================================
    local _ragdollHit
    _ragdollHit = function()
        _ragLastHit = tick()
        if _ragTimerActive then
            _ragT0 = _ragLastHit   -- chain knockdown: restart the count
            return
        end
        _ragTimerActive = true
        _ragT0 = _ragLastHit
        _showRagdollESP()
        task.spawn(function()
            local resumed = false
            while true do
                local now = tick()
                local elapsed   = now - _ragT0
                local remaining = RAGDOLL_TIMER - elapsed

                -- Nominal duration reached.
                if remaining <= 0 then break end

                -- Or genuinely back up: the knockdown signals have stopped for
                -- RAG_QUIET AND the humanoid is not in a ragdoll state right
                -- now. RAG_MIN keeps a single stray signal from closing the
                -- timer out in the first couple of frames.
                if elapsed >= RAG_MIN
                   and (now - _ragLastHit) >= RAG_QUIET
                   and not isRagdolled() then
                    break
                end

                if not resumed and remaining <= GRAB_RESUME_AT then
                    -- Retried each tick until it actually takes. The finisher
                    -- declines (returns false) while a steal hold is still in
                    -- flight -- deliberately, so it cannot stack coroutines --
                    -- so a single shot at the threshold could land during that
                    -- hold and do nothing.
                    resumed = (_G.Skyr0GrabFinisher
                        and select(2, pcall(_G.Skyr0GrabFinisher)) == true) or false
                end
                RunService.Heartbeat:Wait()
            end
            -- Ended early (back on our feet before the threshold): still restart
            -- the grab, otherwise a short ragdoll would never resume it at all.
            if not resumed and _G.Skyr0GrabFinisher then pcall(_G.Skyr0GrabFinisher) end
            _ragTimerActive = false
            _killRagdollESP()
        end)
    end

    local velocityChangeThreshold = 40
    local velocityMagnitudeThreshold = 25
    local maxVelocity = 15

    local function isFlyingCarpetActive()
        if not antiRagdollCharacter then return false end
        local tool = antiRagdollCharacter:FindFirstChildWhichIsA("Tool")
        if not tool then return false end
        local hrp = antiRagdollCharacter:FindFirstChild("HumanoidRootPart")
        if hrp then
            for _, obj in ipairs(hrp:GetChildren()) do
                if obj:IsA("BodyVelocity") or obj:IsA("BodyPosition") or obj:IsA("BodyGyro") then
                    return true
                end
            end
        end
        return false
    end

    function isRagdolled()   -- assigns the forward declaration above
        if not antiRagdollHumanoid then return false end
        local state = antiRagdollHumanoid:GetState()
        return state == Enum.HumanoidStateType.Physics
            or state == Enum.HumanoidStateType.Ragdoll
            or state == Enum.HumanoidStateType.FallingDown
            or state == Enum.HumanoidStateType.GettingUp
    end

    local function enableAntiRagdollControls()
        pcall(function()
            local PlayerModule = player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule", 10)
            require(PlayerModule):GetControls():Enable()
        end)
    end

    local function cleanupRagdoll()
        if not antiRagdollCharacter then return end
        local carpetEquipped = isFlyingCarpetActive()

        local function processChildren(parent)
            for _, obj in ipairs(parent:GetChildren()) do
                if obj:IsA("BallSocketConstraint") or obj:IsA("NoCollisionConstraint") or obj:IsA("HingeConstraint")
                    or (obj:IsA("Attachment") and (obj.Name == "A" or obj.Name == "B")) then
                    obj:Destroy()
                elseif obj:IsA("BodyVelocity") or obj:IsA("BodyPosition") or obj:IsA("BodyGyro") then
                    if not carpetEquipped then obj:Destroy() end
                elseif obj:IsA("Motor6D") then
                    obj.Enabled = true
                elseif obj:IsA("BasePart") then
                    for _, child in ipairs(obj:GetChildren()) do
                        if child:IsA("BallSocketConstraint") or child:IsA("NoCollisionConstraint") or child:IsA("HingeConstraint") or child:IsA("Motor6D") then
                            if child:IsA("Motor6D") then
                                child.Enabled = true
                            else
                                child:Destroy()
                            end
                        elseif child:IsA("Attachment") and (child.Name == "A" or child.Name == "B") then
                            child:Destroy()
                        end
                    end
                end
            end
        end

        pcall(function() processChildren(antiRagdollCharacter) end)

        if antiRagdollAnimator then
            for _, track in pairs(antiRagdollAnimator:GetPlayingAnimationTracks()) do
                local animName = track.Animation and track.Animation.Name:lower() or ""
                if animName:find("rag") or animName:find("fall") or animName:find("hurt") or animName:find("down") then
                    track:Stop(0)
                end
            end
        end
    end

    local function setupAntiRagdollCharacter(char)
        antiRagdollCharacter = char
        antiRagdollHumanoid = char:WaitForChild("Humanoid", 10)
        antiRagdollRootPart = char:WaitForChild("HumanoidRootPart", 10)
        antiRagdollAnimator = antiRagdollHumanoid and antiRagdollHumanoid:WaitForChild("Animator", 10)
        lastVelocity = Vector3.new(0, 0, 0)
    end

    local function clearAntiRagdollConnections()
        for _, c in pairs(antiRagdollConnections) do
            pcall(function() c:Disconnect() end)
        end
        antiRagdollConnections = {}
    end

    local function setupAntiRagdollConnections()
        clearAntiRagdollConnections()
        if not antiRagdollHumanoid or not antiRagdollRootPart then return end

        table.insert(antiRagdollConnections, antiRagdollHumanoid.StateChanged:Connect(function(_old, _new)
            if (_G.AntiRagdollEnabled or _G.antiKnockbackEnabled) and isRagdolled() then
                if not isFlyingCarpetActive() then
                    antiRagdollHumanoid:ChangeState(Enum.HumanoidStateType.Running)
                end
                cleanupRagdoll()
                Workspace.CurrentCamera.CameraSubject = antiRagdollHumanoid
                enableAntiRagdollControls()
            end

            -- ===========================================================
            -- RAGDOLL TIMER -> restart auto grab at 1.4s remaining
            -- -----------------------------------------------------------
            -- EDGE-TRIGGERED, and that is the whole point. The previous
            -- attempt polled isRagdolled() on Heartbeat, which cannot work
            -- here: the block above FORCES you out of the ragdoll state every
            -- single frame, so the polled predicate flickered true/false
            -- continuously, the "recovery ended" branch kept firing, and the
            -- auto grab restarted nonstop.
            --
            -- This is the same shape the reference ragdoll counter uses: fire
            -- once on the StateChanged that knocks you down, latch it, and let
            -- a plain timer run. isRagdolled() is deliberately NOT used for the
            -- test -- it counts GettingUp, which is a state anti-ragdoll itself
            -- produces. The three knockdown states plus the PlatformStand check
            -- are what the counter keys on.
            --
            -- One timer per knockdown, one restart per timer.
            -- ===========================================================
            local isRag = (_new == Enum.HumanoidStateType.Physics
                        or _new == Enum.HumanoidStateType.Ragdoll
                        or _new == Enum.HumanoidStateType.FallingDown)
            if isRag and not antiRagdollHumanoid.PlatformStand then
                _ragdollHit()
            end
        end))

        pcall(function()
            local impulsePath = ReplicatedStorage:FindFirstChild("Packages")
            if impulsePath then
                impulsePath = impulsePath:FindFirstChild("Net")
                if impulsePath then
                    impulsePath = impulsePath:FindFirstChild("RE/CombatService/ApplyImpulse")
                    if impulsePath then
                        table.insert(antiRagdollConnections, impulsePath.OnClientEvent:Connect(function()
                            if (_G.AntiRagdollEnabled or _G.antiKnockbackEnabled) and isRagdolled() then
                                antiRagdollRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                            end
                        end))
                    end
                end
            end
        end)

        table.insert(antiRagdollConnections, antiRagdollCharacter.DescendantAdded:Connect(function(d)
            if (_G.AntiRagdollEnabled or _G.antiKnockbackEnabled) and isRagdolled() then
                cleanupRagdoll()
            end
            -- Second knockdown signal for the timer. Some ragdolls land as pure
            -- constraints and never produce a Humanoid state change the client
            -- sees, and during a real ragdoll the game keeps re-adding these --
            -- which is exactly the continuous stream the timer measures.
            if d and (d:IsA("BallSocketConstraint") or d:IsA("NoCollisionConstraint")
                   or d:IsA("HingeConstraint")) then
                _ragdollHit()
            end
        end))

        table.insert(antiRagdollConnections, RunService.Heartbeat:Connect(function()
            if (_G.AntiRagdollEnabled or _G.antiKnockbackEnabled) and isRagdolled() then
                cleanupRagdoll()
                local velocity = antiRagdollRootPart.AssemblyLinearVelocity
                if (velocity - lastVelocity).Magnitude > velocityChangeThreshold
                    and velocity.Magnitude > velocityMagnitudeThreshold then
                    antiRagdollRootPart.AssemblyLinearVelocity = velocity.Unit * math.min(velocity.Magnitude, maxVelocity)
                end
                lastVelocity = velocity
            end
        end))

        enableAntiRagdollControls()
        cleanupRagdoll()
    end

    function startAntiRagdoll()
        _G.AntiRagdollEnabled = true
        _G.antiKnockbackEnabled = true
        Config.AntiRagdoll = true; setToggle("Anti Ragdoll", true); saveConfig()
        if player.Character then
            setupAntiRagdollCharacter(player.Character)
            setupAntiRagdollConnections()
        end
    end

    function stopAntiRagdoll()
        _G.AntiRagdollEnabled = false
        _G.antiKnockbackEnabled = false
        Config.AntiRagdoll = false; setToggle("Anti Ragdoll", false); saveConfig()
        clearAntiRagdollConnections()
    end

    _G.toggleAntiRagdoll = function(enabled)
        if enabled then startAntiRagdoll() else stopAntiRagdoll() end
    end
    _G.enableAntiKnockback = function() startAntiRagdoll() end
    _G.disableAntiKnockback = function() stopAntiRagdoll() end

    player.CharacterAdded:Connect(function(char)
        clearAntiRagdollConnections()
        antiRagdollCharacter = nil; antiRagdollHumanoid = nil; antiRagdollRootPart = nil; antiRagdollAnimator = nil
        local humanoid = char:WaitForChild("Humanoid", 10)
        local rootPart = char:WaitForChild("HumanoidRootPart", 10)
        if not humanoid or not rootPart then return end
        task.wait(0.2)
        setupAntiRagdollCharacter(char)
        if _G.AntiRagdollEnabled or _G.antiKnockbackEnabled then
            setupAntiRagdollConnections()
        end
    end)

    if player.Character then
        setupAntiRagdollCharacter(player.Character)
        if _G.AntiRagdollEnabled or _G.antiKnockbackEnabled then
            setupAntiRagdollConnections()
        end
    end
end

local function applyUnwalk(char, on)
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local animator = hum and hum:FindFirstChildOfClass("Animator")
    local animate = char:FindFirstChild("Animate")
    if on then
        if animate then animate.Disabled = true end
        if animator then
            local ok, tracks = pcall(function() return animator:GetPlayingAnimationTracks() end)
            if ok and tracks then
                for _, t in ipairs(tracks) do pcall(function() t:Stop(0) end) end
            end
        end
    else
        if animate then animate.Disabled = false end
    end
end

local function setUnwalk(on)
    Config.Unwalk = on
    saveConfig()
    setToggle("Unwalk", on)
    if on then
        task.spawn(function()
            local char = player.Character
            for i = 1, 6 do
                if not Config.Unwalk or player.Character ~= char then break end
                applyUnwalk(char, true)
                task.wait(0.3)
            end
        end)
    else
        applyUnwalk(player.Character, false)
    end
end
_G.setUnwalk = setUnwalk

player.CharacterAdded:Connect(function(char)
    task.spawn(function()
        char:WaitForChild("Humanoid", 10)
        task.wait(0.1)
        if Config.Unwalk then
            for i = 1, 6 do
                if not Config.Unwalk or player.Character ~= char then break end
                applyUnwalk(char, true)
                task.wait(0.3)
            end
        end
    end)
end)

-- =====================================================================
-- ACCESSORY REMOVER  (hub_Mata -- event-driven, deletes accessories as they appear)
-- ---------------------------------------------------------------------
-- Deletes accessories (yours + everyone else's). EVENT-DRIVEN: strips a
-- character once when it loads, then deletes any accessory the instant it is
-- added -- no per-second polling loop (that caused little periodic freezes).
-- Skips "Overhead" (nametag). Toggle: _G.Skyr0HideAccessories(false)/(true)
--
-- This is standalone on purpose. The FPS Boost engine here also destroys
-- Accessory/Clothing, but only while the boost is ON and only as part of a
-- workspace-wide strip pass -- so with the boost off, accessories stayed.
-- =====================================================================
do
    local Players = game:GetService("Players")
    local accOn = true

    local ACC_CLASSES = {
        "Accessory", "Hat", "HairAccessory", "FaceAccessory", "NeckAccessory",
        "ShoulderAccessory", "FrontAccessory", "BackAccessory", "WaistAccessory",
    }
    local function isAccessory(obj)
        for _, c in ipairs(ACC_CLASSES) do if obj:IsA(c) then return true end end
        return false
    end
    local function safeDestroy(obj)
        if obj.Name == "Overhead" then return end
        pcall(function() obj:Destroy() end)
    end

    local function stripChar(char)
        for _, obj in ipairs(char:GetChildren()) do
            if isAccessory(obj) then safeDestroy(obj) end
        end
    end
    local function watchChar(char)
        if accOn then stripChar(char) end
        char.ChildAdded:Connect(function(obj)
            if accOn and isAccessory(obj) then task.defer(safeDestroy, obj) end
        end)
    end
    local function watchPlayer(plr)
        if plr.Character then watchChar(plr.Character) end
        plr.CharacterAdded:Connect(watchChar)
    end

    for _, plr in ipairs(Players:GetPlayers()) do watchPlayer(plr) end
    Players.PlayerAdded:Connect(watchPlayer)

    _G.Skyr0HideAccessories = function(v)
        accOn = (v ~= false)
        if accOn then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr.Character then stripChar(plr.Character) end
            end
        end
    end
end

-- =====================================================================
--  "THE TP SOMETIMES FLIES AT MY OWN BASE."
-- ---------------------------------------------------------------------
--  Returns TWO values: isMine, and whether the question could actually be
--  ANSWERED. Every early exit here used to return a bare `false`, which the
--  callers read as "not your base" -- but most of those exits mean "I have no
--  idea yet": the Plots folder has not replicated, this plot has not streamed
--  in, there is no channel and no sign. On a fresh join that is the normal
--  state for the first seconds, and the cache below then froze that guess for
--  5 whole seconds. That is the entire "sometimes": it is not random, it is
--  early.
-- =====================================================================
local function isMyPlot_Instant(plotName)
    local plots = Workspace:FindFirstChild("Plots")
    if not plots then return false, false end
    local plot = plots:FindFirstChild(plotName)
    if not plot then return false, false end

    -- Method 1: Synchronizer check
    local syncSuccess = false
    local isOwner = false
    pcall(function()
        local Packages = ReplicatedStorage:FindFirstChild("Packages")
        local Synchronizer = Packages and require(Packages:FindFirstChild("Synchronizer"))
        if Synchronizer then
            local ch = _G.Skyr0_GetPlotChannel(plotName)
            if ch then
                local own = _G.sProp(ch, "Owner")
                if own then
                    syncSuccess = true
                    -- `own.Name` added: scanSinglePlot already reads the Owner
                    -- field in that shape, so it does occur on live servers --
                    -- and it was the one shape this test did not understand.
                    -- It still counted as syncSuccess, so the function returned
                    -- "not yours" and skipped the YourBase billboard below.
                    local ownName = (typeof(own) == "table" and own.Name and tostring(own.Name))
                                 or (typeof(own) == "string" and own)
                                 or nil
                    if (typeof(own) == "Instance" and own == player) or
                       (typeof(own) == "table" and own.UserId == player.UserId) or
                       (typeof(own) == "number" and own == player.UserId) or
                       (ownName and (ownName:lower() == player.Name:lower() or ownName:lower() == player.DisplayName:lower())) then
                        isOwner = true
                    end
                end
            end
        end
    end)
    -- Only a POSITIVE short-circuits. `if syncSuccess then return isOwner end`
    -- threw away Methods 2 and 3 the moment a channel existed -- including the
    -- YourBase billboard, which is the one signal the game itself puts on your
    -- own plot and cannot be wrong.
    if isOwner then return true, true end

    local resolved = syncSuccess

    -- Method 2: the PlotSign text
    local sign = plot:FindFirstChild("PlotSign")
    if sign then
        local surfaceGui = sign:FindFirstChildWhichIsA("SurfaceGui", true)
        local label = surfaceGui and surfaceGui:FindFirstChildWhichIsA("TextLabel", true)
        if label then
            local raw = label.Text or ""
            local text = raw:lower()
            -- a blank sign has not filled in yet -- that is not an answer
            if text ~= "" then resolved = true end
            -- the sign saying so outright is the strongest signal there is, and
            -- this function never looked for it. scanSinglePlot has recognised
            -- both spellings for ages (it must, or it reads "Your Base" as an
            -- owner NAME) -- so they are known to appear on live signs.
            if text:find("your base", 1, true) or text:find("sua base", 1, true) then
                return true, true
            end
            -- Otherwise compare the OWNER NAME, parsed exactly the way
            -- scanSinglePlot parses it.
            --
            -- This was `text:find(DisplayName)` -- a plain SUBSTRING test, so a
            -- short name swallowed every base whose owner's name contains it
            -- ("Sam" matching "Samuel's Base") and you could never target them.
            -- Survivable while the answer was recomputed every 5s and always
            -- came back the same; not survivable now that a positive is latched
            -- for the whole session.
            local owner = (raw:gsub("'s Base$", ""):gsub(" Base$", ""):match("^%s*(.-)%s*$") or ""):lower()
            if owner ~= "" and (owner == player.Name:lower() or owner == player.DisplayName:lower()) then
                return true, true
            end
        end
    end

    -- Method 3: BillboardGui "YourBase" check
    if sign then
        local yb = sign:FindFirstChild("YourBase")
        if yb and yb:IsA("BillboardGui") and yb.Enabled == true then
            return true, true
        end
    end

    return false, resolved
end
_G.isMyPlot_Instant = isMyPlot_Instant

-- Cached wrapper for the scanners. isMyPlot_Instant does a require() plus an
-- instance walk, and every sweep asks about every plot, so memoise it briefly.
-- Base ownership only changes when someone claims or leaves a plot.
do
    local memo, memoAt, memoRes = {}, {}, {}
    _G.Skyr0IsMyPlotCached = function(plotName)
        if type(plotName) ~= "string" then return false end
        -- YOUR OWN BASE NEVER STOPS BEING YOURS.
        --
        -- A positive is latched for the session. You keep your plot until you
        -- leave the server, so nothing good can come of un-protecting a base we
        -- have already positively identified -- and plenty can go wrong: one
        -- streamed-out PlotSign or one channel hiccup 5 seconds later flipped
        -- the answer back to "fair game" and the next TP went home.
        if memo[plotName] == true then return true end
        local now = os.clock()
        -- An UNRESOLVED negative is re-asked ten times more often. Caching "I
        -- could not tell" for the full 5s is what let a cold first scan decide
        -- the next five seconds of targeting.
        local ttl = memoRes[plotName] and 5 or 0.5
        if memo[plotName] ~= nil and (now - (memoAt[plotName] or 0)) < ttl then
            if memo[plotName] == false and memoRes[plotName] ~= true
               and _G.Skyr0SpawnPlot == plotName and now < (_G.Skyr0SpawnPlotUntil or 0) then
                return true
            end
            return memo[plotName]
        end
        local ok, res, resolved = pcall(isMyPlot_Instant, plotName)
        if not ok then res, resolved = false, false end
        memo[plotName] = res and true or false
        memoRes[plotName] = resolved and true or false
        memoAt[plotName] = now
        -- =============================================================
        --  THE SPAWN PLOT COUNTS AS OURS UNTIL THE GAME SAYS OTHERWISE.
        --
        --  This is the TP-on-load "it goes for our own base and fails".
        --  On a fresh join NONE of the three signals above exist yet: the
        --  Synchronizer channel has not resolved, the PlotSign label is
        --  still blank, the YourBase billboard has not been enabled. So
        --  isMyPlot_Instant answers (false, false) -- "no idea" -- and
        --  every ownership filter in the file reads that as "not yours"
        --  and happily targets your own podiums. TP-on-load fires in
        --  EXACTLY that window (that is what the settle window is for),
        --  so it is the one caller that gets the cold answer every time.
        --
        --  Skyr0SpawnPlot is the plot we were standing in when the
        --  character first spawned, which on a join is your base.
        --
        --  THREE THINGS KEEP IT FROM EVER COSTING US A TARGET, because a
        --  guess that says "yours" hides a whole base from every picker
        --  in the file -- and if that base held the big earner, the
        --  teleport quietly settles for the leftovers:
        --    * it is consulted ONLY while the real answer is unresolved;
        --    * it is dropped the instant the game resolves that plot to
        --      somebody else;
        --    * it EXPIRES (Skyr0SpawnPlotUntil). TP-on-load fires within
        --      seconds of the join, so the guess only has to cover that
        --      window. Past it the ownership answer is whatever the game
        --      says and nothing else, so a bad guess cannot follow you
        --      through the session.
        -- =============================================================
        if _G.Skyr0SpawnPlot == plotName then
            if resolved and not res then
                _G.Skyr0SpawnPlot = nil          -- it is demonstrably somebody else's
            elseif not resolved and now < (_G.Skyr0SpawnPlotUntil or 0) then
                return true
            end
        end
        return memo[plotName]
    end
end

-- =====================================================================
-- SPAWN PLOT LATCH  --  feeds Skyr0IsMyPlotCached above.
-- ---------------------------------------------------------------------
-- Runs once, on the FIRST character of the session, which is the only
-- moment "the plot I am standing in" is guaranteed to mean "my base".
-- The 25-stud X/Z box is the same plot-proximity test doVelocityTP uses
-- to decide whether a clone landed on a base.
--
-- It refuses to latch a plot the game has ALREADY resolved to someone
-- else, so joining onto a neighbour's doorstep cannot poison it, and it
-- keeps re-checking for a while in case Plots streams in late.
-- =====================================================================
_G.Skyr0PlotUnderMe = function(pos)
    if not pos then
        local c = LocalPlayer.Character
        local hrp = c and c:FindFirstChild("HumanoidRootPart")
        if not hrp then return nil end
        pos = hrp.Position
    end
    local plots = Workspace:FindFirstChild("Plots")
    if not plots then return nil end
    for _, plot in ipairs(plots:GetChildren()) do
        local ok, pv = pcall(function() return plot:GetPivot().Position end)
        if ok and pv and math.abs(pos.X - pv.X) < 25 and math.abs(pos.Z - pv.Z) < 25 then
            return plot.Name
        end
    end
    return nil
end
task.spawn(function()
    -- ONLY ON A REAL JOIN.
    --
    -- "The plot I am standing in is mine" is true when the server has just
    -- spawned you and false the moment you go anywhere -- so it may only be
    -- asked of a character that did not exist yet when the hub started. On
    -- auto-execute that is always the case (the hub deliberately starts before
    -- the game finishes loading, see the top of the file), and that is the only
    -- run where TP-on-load happens. Executing by hand mid-game skips this
    -- entirely: standing on somebody else's base to steal must never mark it
    -- as ours.
    if LocalPlayer.Character then return end
    local c = LocalPlayer.CharacterAdded:Wait()
    local hrp = c:FindFirstChild("HumanoidRootPart") or c:WaitForChild("HumanoidRootPart", 10)
    if not hrp then return end
    local t0 = os.clock()
    -- The position is re-read each pass rather than sampled once: the server
    -- CFrames a freshly added character onto its plot a beat AFTER it is
    -- parented, so the first read is often the placeholder spawn.
    while os.clock() - t0 < 15 do
        if _G.Skyr0SpawnPlot then return end
        if not hrp.Parent then return end
        local name = _G.Skyr0PlotUnderMe(hrp.Position)
        if name then
            local ok, res, resolved = pcall(isMyPlot_Instant, name)
            if ok and res then return end                 -- already known ours, nothing to add
            if ok and resolved then return end            -- resolved to someone else: leave it alone
            _G.Skyr0SpawnPlot = name
            -- The guess is only ever allowed to cover the load. See the
            -- expiry note in Skyr0IsMyPlotCached: a base wrongly held to
            -- be ours is a base no picker can see, and living with that
            -- for a whole session is far worse than the cold-ownership
            -- window it exists to patch.
            _G.Skyr0SpawnPlotUntil = os.clock() + 25
            return
        end
        task.wait(0.25)
    end
end)

-- UNLOCK BASE 
local function getUnlockHRP()
    local c = LocalPlayer.Character or player.Character
    if not c then return end
    return c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("UpperTorso")
end

local function smartInteract(number)
    local char = LocalPlayer.Character or player.Character
    local hrp = getUnlockHRP()
    if not char or not hrp then return end

    local plots = Workspace:FindFirstChild("Plots")
    if not plots then return end

    local closestPlot, minDistance = nil, 40

    for _, plot in pairs(plots:GetChildren()) do
        local plotPos
        if plot:IsA("Model") then
            plotPos = plot.PrimaryPart and plot.PrimaryPart.Position or plot:GetPivot().Position
        else
            plotPos = plot.Position
        end

        local dist = (hrp.Position - plotPos).Magnitude
        if dist < minDistance then
            closestPlot = plot
            minDistance = dist
        end
    end

    if closestPlot and closestPlot:FindFirstChild("Unlock") then
        local items = {}

        for _, item in pairs(closestPlot.Unlock:GetChildren()) do
            local pos = item:IsA("Model") and item:GetPivot().Position or item.Position
            table.insert(items, {
                Obj = item,
                Y = pos.Y
            })
        end

        table.sort(items, function(a, b)
            return a.Y < b.Y
        end)

        if items[number] then
            for _, pr in pairs(items[number].Obj:GetDescendants()) do
                if pr:IsA("ProximityPrompt") then
                    pcall(function()
                        fireproximityprompt(pr)
                    end)
                end
            end
        end
    end
end

local function getCurrentUnlockFloor()
    local hrp = getUnlockHRP()
    if not hrp then return 1 end

    local y = hrp.Position.Y
    if y < 12 then
        return 1
    else
        return 2
    end
end

-- (PROXIMITY AP removed)
-- AUTO KICK ON STEAL / CLEAN ERRORS
-- (Auto Reset On Balloon removed together with the insta-reset subsystem: it was
--  the only consumer of executeReset, and it scanned every PlayerGui descendant
--  once a second purely to trigger it.)

task.spawn(function() local kw="you stole"; local hooked=setmetatable({},{__mode="k"})
    local function hookObj(obj) if hooked[obj] then return end; hooked[obj]=true
        if string.find(string.lower(tostring(obj.Text or "")),kw,1,true) then
            if Config.AutoKickOnSteal then kickPlayer(tostring(obj.Text or "")); return end
        end
        obj:GetPropertyChangedSignal("Text"):Connect(function()
            if string.find(string.lower(tostring(obj.Text or "")),kw,1,true) then
                if Config.AutoKickOnSteal then kickPlayer(tostring(obj.Text or "")) end
            end
        end)
    end
    local function watchRoot(root) for _,obj in ipairs(root:GetDescendants()) do if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then hookObj(obj) end end
        root.DescendantAdded:Connect(function(desc) if desc:IsA("TextLabel") or desc:IsA("TextButton") or desc:IsA("TextBox") then hookObj(desc) end end) end
    for _,g in ipairs(playerGui:GetChildren()) do watchRoot(g) end; playerGui.ChildAdded:Connect(function(g) watchRoot(g) end)
end)

task.spawn(function() local GS=pcall(function() return cloneref(game:GetService("GuiService")) end) and cloneref(game:GetService("GuiService")) or game:GetService("GuiService")
    -- Was a flat task.wait(0.1) whether or not CleanErrorGUIs was on, so this
    -- woke 10x a second for the whole session to evaluate one `if`. Idle when
    -- the toggle is off, unchanged when it is on.
    while true do
        if Config.CleanErrorGUIs then
            pcall(function() GS:ClearError() end)
            task.wait(0.1)
        else
            task.wait(1)
        end
    end
end)

-- ============================================================
-- AUTO STEAL / GRAB
-- ============================================================
do
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Datas = ReplicatedStorage:WaitForChild("Datas")
local Synchronizer = require(Packages:WaitForChild("Synchronizer"))
local AnimalsData = require(Datas:WaitForChild("Animals"))

autoStealEnabled = Config.AutoStealEnabled
if autoStealEnabled == nil then autoStealEnabled = true end
instantStealEnabled = Config.InstantStealEnabled
if instantStealEnabled == nil then instantStealEnabled = true end
stealHighestEnabled = Config.StealHighest
if stealHighestEnabled == nil then stealHighestEnabled = true end
stealPriorityEnabled = Config.StealPriority
stealNearestEnabled = Config.StealNearest
selectedTargetIndex = 1
selectedTargetUID = nil
manuallySelectedUID = nil
currentStealTargetUID = nil
activeProgressTween = nil
instantStealReady = false
instantStealDidInit = false
INSTANT_STEAL_RADIUS = 60
INSTANT_STEAL_COOLDOWN = 0
lastInstantStealTime = 0
PromptMemoryCache = {}

-- ============================================================
-- AUTO GRAB INTEGRATION 
-- ============================================================
local CONFIG = {
    AUTO_STEAL = false,
    RADIUS = 60
}


local trackedPrompts = {}
local lastFire = {}

local SAFE_POLL_RATE = 0.05
local SAFE_POLL_OVERRIDE_UNTIL = 0

function _G.getSafePollRate()
    if os.clock() < SAFE_POLL_OVERRIDE_UNTIL then
        return 0.27
    end
    return SAFE_POLL_RATE
end

function _G.triggerSafePollBoost()
    SAFE_POLL_OVERRIDE_UNTIL = os.clock() + 3
end

local FIRE_DEBOUNCE = 0.12
local FIRE_BURST = 4
local ENABLE_BURST = 35
local ENABLE_DEBOUNCE = 0.00
local ENABLE_COOLDOWN = 0.08
local lastEnableFire = {}

local function getHRP()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end


local function getPromptPosition(prompt)
    local p = prompt.Parent
    if not p then return end
    if p:IsA("Attachment") and p.Parent then p = p.Parent end
    if p:IsA("BasePart") then return p.Position elseif p:IsA("Model") then return p:GetPivot().Position end
end

-- HOLD THE LAST TARGET ACROSS A BLINK.
--
-- The selection thread (0.1s) writes SharedState.SelectedPetData = nil on any
-- tick where get_all_pets() comes back empty, or -- in Nearest mode -- where
-- findAdorneeGlobal cannot resolve a podium yet. Both happen routinely for a
-- tick or two while a base streams in or the scanner cache is rebuilding, and
-- neither means "stop grabbing": the pet is still standing right there.
--
-- Auto-grab reads that flag every frame, so a single blank tick disarmed it
-- for 100ms -- and 100ms is most of the window a prompt is grabbable in. That
-- is the "sometimes it grabs, sometimes it just stands there".
--
-- The last real selection is kept for STICKY_MS and used only while the live
-- one is blank, so a genuine target change still takes effect immediately.
local STICKY_SELECTION = 1.5
local function _selectedPet()
    local live = SharedState and SharedState.SelectedPetData
    if live then
        SharedState.__selSticky, SharedState.__selStickyAt = live, os.clock()
        return live
    end
    local held = SharedState and SharedState.__selSticky
    if held and (os.clock() - (SharedState.__selStickyAt or 0)) < STICKY_SELECTION then
        return held
    end
    return nil
end

local function promptMatchesSelectedPet(prompt)
    if not SharedState then return false end
    local selected = _selectedPet()
    if not selected then return false end
    local model = prompt:FindFirstAncestorOfClass("Model")
    if not model then return false end
    if selected.slot then
        local slotAncestor = prompt:FindFirstAncestor(selected.slot)
        if slotAncestor or model.Name == selected.slot or (model.Parent and model.Parent.Name == selected.slot) then return true end
    end
    local name = selected.name or selected.petName
    if name then
        local wantedName = string.lower(name)
        local current = model
        while current do
            if current.Name and string.lower(current.Name) == wantedName then return true end
            current = current.Parent
        end
    end
    return false
end

-- Is this prompt on MY base?
--
-- TWO SEPARATE QUESTIONS, and merging them is what made auto-grab flaky.
--
--   1. WHICH PLOT is this prompt on? That is an ancestor walk, and the answer
--      NEVER changes for the life of the prompt -- a podium does not move
--      between bases. Cached forever (per prompt), not for 10 seconds.
--   2. IS THAT PLOT MINE? That is ownership, and this used to be a SECOND,
--      private implementation: a raw substring match of the plot sign against
--      your name. It disagreed with Skyr0IsMyPlotCached -- the test every
--      other filter in the file uses -- in both directions. A short display
--      name matched every base containing it as a substring, so whole bases
--      were silently un-grabbable; and while the sign was still blank (a
--      streamed-out or freshly joined plot) it answered "not mine" and then
--      FROZE that answer for 10 seconds, which is longer than the window the
--      grab had to fire in.
--
-- Ownership now goes through the canonical cached test, which latches a
-- positive for the session, re-asks an unresolved negative ten times a second
-- and knows about the spawn-plot latch. One answer, one place to fix it.
local _plotOfPrompt = {}

local function _promptPlotName(prompt)
    local cached = _plotOfPrompt[prompt]
    if cached ~= nil then
        return (cached ~= false) and cached or nil
    end
    local name = false
    local plots = workspace:FindFirstChild("Plots")
    if plots then
        local node = prompt.Parent
        while node and node ~= plots do
            if node.Parent == plots then name = node.Name; break end
            node = node.Parent
        end
    end
    -- Only a real answer is memoised. Before the Plots folder replicates there
    -- is nothing to walk, and caching that "false" would leave every prompt
    -- tracked during the load permanently unattributed.
    if name ~= false then _plotOfPrompt[prompt] = name end
    return (name ~= false) and name or nil
end

local function _promptIsMyPlot(prompt)
    local name = _promptPlotName(prompt)
    if not name then return false end
    return _G.Skyr0IsMyPlotCached and _G.Skyr0IsMyPlotCached(name) or false
end
_G.Skyr0ClearGrabPlotCache = function()
    table.clear(_plotOfPrompt)
end

local function isPromptAvailable(prompt, hrpPos)
    if not autoStealEnabled or not instantStealEnabled then return false end
    if not prompt or not prompt.Parent or not prompt.Enabled then return false end
    local pos = getPromptPosition(prompt)
    if not pos then return false end
    -- cheap test first: a prompt outside the radius never needs the plot lookup
    local radius = Config.AutoGrabRadius or 60
    if (pos - hrpPos).Magnitude > radius then return false end
    if _promptIsMyPlot(prompt) then return false end
    if _G.NEAREST_INSTANT_MODE == true then
        -- Box checks removed to allow nearest to work globally based on radius
    end
    if not (_G.NEAREST_INSTANT_MODE == true) then
        if not promptMatchesSelectedPet(prompt) then return false end
    end
    return true
end

local function canFire(prompt, debounce)
    local t = os.clock()
    local last = lastFire[prompt]
    if last and (t - last) < debounce then return false end
    lastFire[prompt] = t
    return true
end

local function firePrompt(prompt, burst, debounce)
    if not prompt or not prompt.Parent or not prompt.Enabled or not canFire(prompt, debounce) then return end
    for i = 1, burst do pcall(function() fireproximityprompt(prompt, 0) end) end
end

local function trackPrompt(prompt)
    if trackedPrompts[prompt] then return end
    trackedPrompts[prompt] = true
    local function tryInstantEnableFire()
        if not autoStealEnabled or not instantStealEnabled then return end
        local hrp = getHRP()
        if hrp and isPromptAvailable(prompt, hrp.Position) then
            CONFIG.AUTO_STEAL = true
            local now = os.clock()
            local le = lastEnableFire[prompt]
            if not le or (now - le) >= ENABLE_COOLDOWN then
                lastEnableFire[prompt] = now
                firePrompt(prompt, ENABLE_BURST, ENABLE_DEBOUNCE)
            end
        end
    end
    task.defer(tryInstantEnableFire)
    pcall(function() prompt:GetPropertyChangedSignal("Enabled"):Connect(function() if prompt.Enabled then tryInstantEnableFire() end end) end)
    prompt.AncestryChanged:Connect(function()
        if not prompt:IsDescendantOf(workspace) then
            trackedPrompts[prompt] = nil; lastFire[prompt] = nil; lastEnableFire[prompt] = nil
            -- drop the cached plot attribution too, or the table grows for the
            -- life of the session as podiums stream in and out
            _plotOfPrompt[prompt] = nil
        end
    end)
end

local function scanBrainrotPrompts()
    local plots = workspace:FindFirstChild("Plots")
    if plots then
        for _, plot in ipairs(plots:GetChildren()) do
            local podiums = plot:FindFirstChild("AnimalPodiums")
            if podiums then
                for _, obj in ipairs(podiums:GetDescendants()) do
                    if obj:IsA("ProximityPrompt") then trackPrompt(obj) end
                end
            end
        end
    end
end

scanBrainrotPrompts()
workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("ProximityPrompt") and obj:FindFirstAncestor("AnimalPodiums") then trackPrompt(obj) end
end)

-- A PROMPT THAT IS NOT TRACKED CAN NEVER BE FIRED.
--
-- The two lines above are the whole discovery path, and both can miss:
--
--   * scanBrainrotPrompts runs ONCE, at execute. On auto-execute that is
--     before workspace.Plots exists, so it finds nothing at all and the entire
--     starting server is left to DescendantAdded.
--   * DescendantAdded requires the AnimalPodiums ancestor to already be in
--     place at the moment the event fires. A podium whose parenting order puts
--     the prompt in the tree first is silently dropped, permanently -- nothing
--     ever looks again.
--
-- Neither failure is visible: auto-grab simply does nothing for those podiums
-- while working perfectly for the ones next to them, which is exactly what
-- "inconsistent" looks like from the outside. A rescan closes both. trackPrompt
-- is a table lookup for anything already tracked, so a pass is cheap, and the
-- interval is backed off once the map has settled.
task.spawn(function()
    local n = 0
    while true do
        n = n + 1
        task.wait(n < 20 and 1 or 5)
        pcall(scanBrainrotPrompts)
    end
end)

-- NO task.wait. This used to sleep _G.getSafePollRate() (0.05s, or 0.27s in
-- boost mode) between passes, which put up to a whole poll interval of latency
-- between a prompt becoming grabbable and the hub firing it -- the "auto grab
-- feels delayed" complaint -- while STILL doing a full pass 20 times a second
-- whether or not anything had changed.
--
-- It is a Heartbeat connection now, so it is in step with the frame instead of
-- fighting it, and it returns on the first line when auto-grab is off: no
-- prompt iteration, no allocation, nothing. The per-prompt cost is a distance
-- compare plus a cached ownership flag (see _promptIsMyPlot), so a full pass is
-- cheap enough to run every frame -- which is what makes the grab instant
-- rather than up to 50ms late.
--
-- firePrompt still has its own debounce, so per-frame passes do not turn into a
-- fireproximityprompt flood.
-- FIRE ON THE FRAME THE PROMPT BECOMES AVAILABLE, NOT THE FRAME AFTER.
--
-- CONFIG.AUTO_STEAL was set at the END of the pass and read at the TOP of the
-- next one, so the first frame a prompt was grabbable it was found and then
-- deliberately not fired -- the burst only started one frame later. Worse, the
-- flag is global rather than per prompt: it went false on any pass where
-- nothing was in range, so EVERY approach paid that dead frame again, and a
-- prompt that was available for a single frame (the owner walking past, a
-- prompt toggling Enabled) was never fired at all.
--
-- The flag is only ever read by that gate, so it stops gating and just reports.
-- firePrompt keeps its own per-prompt debounce, which is what actually stops a
-- per-frame pass turning into a fireproximityprompt flood.
RunService.Heartbeat:Connect(function()
    if not (autoStealEnabled and instantStealEnabled) then
        if CONFIG.AUTO_STEAL then CONFIG.AUTO_STEAL = false end
        return
    end
    _G.NEAREST_INSTANT_MODE = (stealNearestEnabled == true)
    local hrp = getHRP()
    if not hrp then CONFIG.AUTO_STEAL = false; return end
    local myPos = hrp.Position
    local anyAvailable = false
    for prompt in pairs(trackedPrompts) do
        if isPromptAvailable(prompt, myPos) then
            anyAvailable = true
            firePrompt(prompt, FIRE_BURST, FIRE_DEBOUNCE)
        end
    end
    CONFIG.AUTO_STEAL = anyAvailable
end)


-- =====================================================================
-- get_all_pets  --  MEMOISED AGAINST SharedState.CacheVersion.
-- ---------------------------------------------------------------------
-- Three callers hammer this: the selection thread (10x a second), the Steal
-- Target panel and getTargetPetData. Every call built a brand new table for
-- EVERY pet on the server and then sorted the result -- hundreds of tables a
-- second whose contents were identical to the ones thrown away 100ms earlier.
--
-- The underlying cache only changes when the plot scanner says it changed
-- (it already gates on a content hash), so the answer is rebuilt when the
-- version moves and reused when it has not. The other inputs -- the min-gen
-- filters and the priority list -- are in the key, so changing a setting
-- still takes effect on the next call.
--
-- The returned list is READ-ONLY BY CONVENTION. Callers iterate it or copy
-- out of it (the panel builds its own prio/other tables and sorts those);
-- none of them sort or mutate this list in place, which is what makes handing
-- the same table to all three safe.
-- =====================================================================
-- The memo lives on SharedState rather than in two chunk-level locals: this
-- file has already overflowed Luau's 200-register limit for the main chunk once
-- (see the note on the auto-buy scope), so new top-level locals are avoided.
function get_all_pets()
    local _key = tostring(SharedState.CacheVersion or 0)
        .. "|" .. tostring(Config.StealNearest)
        .. "|" .. tostring(Config.TpSettings.MinGenForTp)
        .. "|" .. tostring(Config.TpSettings.MinGenForGrab)
        .. "|" .. table.concat(priorityList, ",")
    if SharedState.__gapOut and SharedState.__gapKey == _key then return SharedState.__gapOut end

    local out = {}
    local cache = SharedState.AllAnimalsCache
    local minGenStr = Config.StealNearest and Config.TpSettings.MinGenForGrab or Config.TpSettings.MinGenForTp
    local minGen = parseMinGen(minGenStr)
    local myName = LocalPlayer.Name
    local myDisplay = LocalPlayer.DisplayName
    if cache and type(cache) == "table" then
        for _, a in ipairs(cache) do
            -- A PRIORITY PET IS NEVER FILTERED OUT OF THIS LIST.
            --
            -- Not by Min Gen for Auto TP, not by Min Gen for Nearest Grab, and
            -- not by the `>= 1` earnings floor either -- that one silently
            -- dropped any listed pet the scanner had not priced yet, and a
            -- priority pet missing from this list is a priority pet the panel
            -- and the pets[1] fallback cannot see.
            --
            -- Membership goes through Skyr0PrioRank so it is trimmed and
            -- case-folded exactly like every other priority test in the file;
            -- the old prioSet compared raw lowercase, so a list entry with a
            -- stray space was "not on the list" HERE while it matched in the
            -- pickers.
            local isPriority = _G.Skyr0IsPriority
                and _G.Skyr0IsPriority(a and a.name, a and a.index, a and a.mutation)
            -- YOUR OWN BASE IS NOT A TARGET LIST ENTRY.
            --
            -- The owner-name test alone is not enough: scanSinglePlot records
            -- owner = "" when the channel has not resolved yet (it says so in
            -- its own hash comment), and "" passes both compares. So your own
            -- pets landed in this list, in the Steal Target panel, and at
            -- pets[1] -- which is what getTargetPetData falls back to.
            if a and ((a.genValue or 0) >= 1 or isPriority) and a.owner ~= myName and a.owner ~= myDisplay
               and not (_G.Skyr0IsMyPlotCached and _G.Skyr0IsMyPlotCached(a.plot)) then
                local isBrainrot = ((tonumber(a.genValue) or 0) >= 10000000)
                if isBrainrot and a.name then SharedState.BrainrotNames[a.name:lower()] = true end
                if minGen > 0 and (tonumber(a.genValue) or 0) < minGen then
                    if not isBrainrot and not isPriority then continue end
                end
                table.insert(out, {
                    name = a.name,
                    petName = a.name,
                    mpsText = a.genText,
                    mpsValue = a.genValue,
                    petValue = a.petValue or 0,
                    owner = a.owner,
                    plot = a.plot,
                    slot = a.slot,
                    uid = a.uid,
                    mutation = a.mutation,
                    animalData = a,
                })
            end
        end
    end
    table.sort(out, function(a, b) return (a.mpsValue or 0) > (b.mpsValue or 0) end)
    SharedState.__gapOut, SharedState.__gapKey = out, _key
    return out
end

function get_all_pets_by_value()
    local out = {}
    local cache = SharedState.AllAnimalsCache
    local minGenStr = Config.StealNearest and Config.TpSettings.MinGenForGrab or Config.TpSettings.MinGenForTp
    local minGen = parseMinGen(minGenStr)
    local myName = LocalPlayer.Name
    local myDisplay = LocalPlayer.DisplayName
    if cache and type(cache) == "table" then
        for _, a in ipairs(cache) do
            -- same two exemptions as get_all_pets: the own-plot guard (owner ==
            -- "" passes the name compares while the channel is still resolving)
            -- and priority pets, which no min-gen box may filter out. This one
            -- had no priority exemption at all, so "Highest Value" could not see
            -- a listed pet that sat under the min-gen floor.
            local isPriority = _G.Skyr0IsPriority
                and _G.Skyr0IsPriority(a and a.name, a and a.index, a and a.mutation)
            if a and ((a.genValue or 0) >= 1 or isPriority) and a.owner ~= myName and a.owner ~= myDisplay
               and not (_G.Skyr0IsMyPlotCached and _G.Skyr0IsMyPlotCached(a.plot)) then
                if minGen > 0 and (tonumber(a.genValue) or 0) < minGen and not isPriority then continue end
                table.insert(out, {
                    name = a.name,
                    petName = a.name,
                    mpsText = a.genText,
                    mpsValue = a.genValue,
                    petValue = a.petValue or 0,
                    owner = a.owner,
                    plot = a.plot,
                    slot = a.slot,
                    uid = a.uid,
                    mutation = a.mutation,
                    animalData = a,
                })
            end
        end
    end
    table.sort(out, function(a, b) return (a.petValue or 0) > (b.petValue or 0) end)
    return out
end

function findProximityPromptForAnimal(animalData)
    if not animalData then return nil end
    local cp = PromptMemoryCache[animalData.uid]
    if cp and cp.Parent then return cp end
    local plot = Workspace.Plots:FindFirstChild(animalData.plot)
    if not plot then return nil end
    local podiums = plot:FindFirstChild("AnimalPodiums")
    if not podiums then return nil end
    local ch = _G.Skyr0_GetPlotChannel(plot.Name)
    if not ch then
        local podium = podiums:FindFirstChild(animalData.slot)
        if podium then
            local base = podium:FindFirstChild("Base")
            local spawn = base and base:FindFirstChild("Spawn")
            if spawn then
                local attach = spawn:FindFirstChild("PromptAttachment")
                if attach then
                    for _, p in ipairs(attach:GetChildren()) do
                        if p:IsA("ProximityPrompt") then
                            PromptMemoryCache[animalData.uid] = p
                            return p
                        end
                    end
                end
            end
        end
        return nil
    end
    -- raw CacheTable read instead of the hookable ch:Get (RelateChannels snitch)
    local al = (_G.Skyr0ChanGet and _G.Skyr0ChanGet(ch, "AnimalList")) or nil
    if not al then return nil end
    local brainrotName = (animalData.name and animalData.name:lower()) or ""
    local targetSlot = animalData.slot
    local foundPodium = nil
    for slot, ad in pairs(al) do
        if (type(ad) == "table") and (tostring(slot) == targetSlot) then
            local aName, aInfo = ad.Index, AnimalsData[ad.Index]
            if aInfo and ((aInfo.DisplayName or aName):lower() == brainrotName) then
                foundPodium = podiums:FindFirstChild(tostring(slot))
                break
            end
        end
    end
    if not foundPodium then foundPodium = podiums:FindFirstChild(animalData.slot) end
    if foundPodium then
        local base = foundPodium:FindFirstChild("Base")
        local spawn = base and base:FindFirstChild("Spawn")
        if spawn then
            local attach = spawn:FindFirstChild("PromptAttachment")
            if attach then
                for _, p in ipairs(attach:GetChildren()) do
                    if p:IsA("ProximityPrompt") and p.Enabled and (p.ActionText:lower():find("steal") or p.ActionText == "") then
                        PromptMemoryCache[animalData.uid] = p
                        return p
                    end
                end
            end
            local startPos = spawn.Position
            local slotX, slotZ = startPos.X, startPos.Z
            local nearestPrompt = nil
            local minDist = math.huge
            for _, desc in pairs(plot:GetDescendants()) do
                if desc:IsA("ProximityPrompt") and desc.Enabled and (desc.ActionText:lower():find("steal") or desc.ActionText == "") then
                    local part = desc.Parent
                    local promptPos = nil
                    if part and part:IsA("BasePart") then
                        promptPos = part.Position
                    elseif part and part:IsA("Attachment") and part.Parent and part.Parent:IsA("BasePart") then
                        promptPos = part.Parent.Position
                    end
                    if promptPos then
                        local checkStartY = startPos.Y
                        if brainrotName:find("la secret combinasion") then checkStartY = startPos.Y - 5 end
                        local horizontalDist = math.sqrt(((promptPos.X - slotX) ^ 2) + ((promptPos.Z - slotZ) ^ 2))
                        if (horizontalDist < 5) and (promptPos.Y > checkStartY) then
                            local yDist = promptPos.Y - checkStartY
                            if yDist < minDist then
                                minDist = yDist
                                nearestPrompt = desc
                            end
                        end
                    end
                end
            end
            if nearestPrompt then
                PromptMemoryCache[animalData.uid] = nearestPrompt
                return nearestPrompt
            end
        end
    end
    return nil
end

-- executeInstantSteal logic removed

function setStealMode(mode)
    manuallySelectedUID = nil
    stealHighestEnabled = (mode == "Highest")
    stealPriorityEnabled = (mode == "Priority")
    stealNearestEnabled = (mode == "Nearest")
    Config.StealHighest = stealHighestEnabled
    Config.StealPriority = stealPriorityEnabled
    Config.StealNearest = stealNearestEnabled
    Config.StealMode = mode
    -- The Auto-TP tab's three toggles are the SAME setting under different
    -- names. They were never kept in sync, and AutoTPPriority defaults to TRUE
    -- -- so the target picker read "priority" no matter what you chose here and
    -- Highest/Nearest did nothing. Mirror the choice into them so there is one
    -- state, whichever panel you set it from.
    Config.AutoTPPriority    = (mode == "Priority")
    Config.AutoTPHighestGen  = (mode == "Highest")
    Config.AutoTPHighestValue = false
    pcall(function()
        if BoundToggles["Auto TP Priority Mode"] then BoundToggles["Auto TP Priority Mode"](Config.AutoTPPriority, false) end
        if BoundToggles["Auto TP Highest Gen"] then BoundToggles["Auto TP Highest Gen"](Config.AutoTPHighestGen, false) end
        if BoundToggles["Auto TP Highest Value"] then BoundToggles["Auto TP Highest Value"](false, false) end
    end)
    saveConfig()
    setToggle("Steal Highest", stealHighestEnabled)
    setToggle("Steal Priority", stealPriorityEnabled)
    setToggle("Steal Nearest", stealNearestEnabled)
    -- Bridge to Skyr0 Clone-TP engine
    if _G.Skyr0StealMode then pcall(_G.Skyr0StealMode, mode) end
end

-- Create the Bottom Steal HUD matching 
local hudGui = _G.SXEBuscaGui("AutoStealCurrentTargetHUD")
if hudGui then hudGui:Destroy() end
hudGui = Instance.new("ScreenGui")
hudGui.Name = "AutoStealCurrentTargetHUD"
hudGui.ResetOnSpawn = false
hudGui.IgnoreGuiInset = true
hudGui.DisplayOrder = 998
hudGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
hudGui.Parent = ((gethui and gethui()) or game:GetService("CoreGui"))  -- was playerGui (server-scannable)
local STEALBAR = {
    PANEL = Color3.fromRGB(15, 15, 15),
    TEXT = Color3.fromRGB(255, 255, 255),
    STROKE = Color3.fromRGB(60, 60, 65),
    GLOW = Color3.fromRGB(255, 255, 255),
    TRACK = Color3.fromRGB(55, 55, 58),
    TRACK2 = Color3.fromRGB(35, 35, 38),
    FILL1 = Color3.fromRGB(235, 235, 235),
    FILL2 = Color3.fromRGB(210, 210, 210),
}

local mobileScale = UIS.TouchEnabled and 0.6 or 1
local targetHud = Instance.new("Frame", hudGui)
targetHud.Name = "CurrentTargetHUD"
targetHud.AnchorPoint = Vector2.new(0.5, 1)
targetHud.Size = UDim2.new(0, 230 * mobileScale, 0, 46 * mobileScale)
targetHud.Position = UDim2.new(0.5, 0, 1, -135)
targetHud.BackgroundColor3 = STEALBAR.PANEL
targetHud.BackgroundTransparency = 0.4
targetHud.BorderSizePixel = 0
targetHud.ZIndex = 70
Instance.new("UICorner", targetHud).CornerRadius = UDim.new(0, math.floor(12 * mobileScale))

local hudStroke = Instance.new("UIStroke", targetHud)
hudStroke.Color = STEALBAR.STROKE
hudStroke.Thickness = 1
hudStroke.Transparency = 0.35

local hudGlow = Instance.new("UIStroke", targetHud)
hudGlow.Color = STEALBAR.GLOW
hudGlow.Thickness = 3
hudGlow.Transparency = 0.84
hudGlow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local hudShadow = Instance.new("ImageLabel", targetHud)
hudShadow.Name = "Shadow"
hudShadow.AnchorPoint = Vector2.new(0.5, 0.5)
hudShadow.Position = UDim2.new(0.5, 0, 0.5, 1)
hudShadow.Size = UDim2.new(1, 20, 1, 20)
hudShadow.BackgroundTransparency = 1
hudShadow.Image = "rbxassetid://6014261993"
hudShadow.ImageColor3 = Color3.new(0, 0, 0)
hudShadow.ImageTransparency = 0.72
hudShadow.ScaleType = Enum.ScaleType.Slice
hudShadow.SliceCenter = Rect.new(49, 49, 450, 450)
hudShadow.ZIndex = 69

local hudName = Instance.new("TextLabel", targetHud)
hudName.Name = "TargetName"
hudName.Size = UDim2.new(1, -12, 0, 13 * mobileScale)
hudName.Position = UDim2.fromOffset(6 * mobileScale, 3 * mobileScale)
hudName.BackgroundTransparency = 1
hudName.Font = Enum.Font.GothamBold
hudName.TextSize = 11 * mobileScale
hudName.TextColor3 = STEALBAR.TEXT
hudName.TextXAlignment = Enum.TextXAlignment.Center
hudName.TextTruncate = Enum.TextTruncate.AtEnd
hudName.ZIndex = 72
hudName.Text = "No target"

local hudProgressBg = Instance.new("Frame", targetHud)
hudProgressBg.Name = "ProgressBg"
hudProgressBg.Size = UDim2.new(1, -10 * mobileScale, 0, 18 * mobileScale)
hudProgressBg.Position = UDim2.fromOffset(5 * mobileScale, 18 * mobileScale)
hudProgressBg.BackgroundColor3 = STEALBAR.TRACK
hudProgressBg.BorderSizePixel = 0
hudProgressBg.ZIndex = 72
Instance.new("UICorner", hudProgressBg).CornerRadius = UDim.new(0, math.floor(8 * mobileScale))

local hudProgressBgStroke = Instance.new("UIStroke", hudProgressBg)
hudProgressBgStroke.Color = STEALBAR.STROKE
hudProgressBgStroke.Thickness = 1
hudProgressBgStroke.Transparency = 0.55

local hudInnerTrack = Instance.new("Frame", hudProgressBg)
hudInnerTrack.Name = "InnerTrack"
hudInnerTrack.Size = UDim2.new(1, -2, 1, -2)
hudInnerTrack.Position = UDim2.fromOffset(1, 1)
hudInnerTrack.BackgroundColor3 = STEALBAR.TRACK2
hudInnerTrack.BackgroundTransparency = 0.4
hudInnerTrack.BorderSizePixel = 0
hudInnerTrack.ZIndex = 72
Instance.new("UICorner", hudInnerTrack).CornerRadius = UDim.new(0, math.floor(7 * mobileScale))

local hudProgressFill = Instance.new("Frame", hudProgressBg)
hudProgressFill.Name = "ProgressFill"
hudProgressFill.Size = UDim2.new(0, 0, 1, 0)
hudProgressFill.BackgroundColor3 = STEALBAR.FILL1
hudProgressFill.BorderSizePixel = 0
hudProgressFill.ZIndex = 73
Instance.new("UICorner", hudProgressFill).CornerRadius = UDim.new(0, math.floor(8 * mobileScale))

local hudProgressFillGradient = Instance.new("UIGradient", hudProgressFill)
hudProgressFillGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, STEALBAR.FILL1),
    ColorSequenceKeypoint.new(1, STEALBAR.FILL2),
})

local hudProgressFillStroke = Instance.new("UIStroke", hudProgressFill)
hudProgressFillStroke.Color = Color3.fromRGB(255, 255, 255)
hudProgressFillStroke.Thickness = 1
hudProgressFillStroke.Transparency = 0.45

local hudPercent = Instance.new("TextLabel", hudProgressBg)
hudPercent.Name = "Percent"
hudPercent.Size = UDim2.new(1, 0, 1, 0)
hudPercent.BackgroundTransparency = 1
hudPercent.Font = Enum.Font.GothamBold
hudPercent.TextSize = 12 * mobileScale
hudPercent.TextColor3 = STEALBAR.TEXT
hudPercent.TextStrokeTransparency = 0.7
hudPercent.TextXAlignment = Enum.TextXAlignment.Center
hudPercent.ZIndex = 74
hudPercent.Text = "0%"

local function applySelection(newIndex, pets)
    if newIndex and (newIndex >= 1) and (newIndex <= #pets) then
        local newUID = pets[newIndex].uid
        if (selectedTargetIndex ~= newIndex) or (selectedTargetUID ~= newUID) or (SharedState.SelectedPetData == nil) then
            selectedTargetIndex = newIndex
            selectedTargetUID = newUID
            SharedState.SelectedPetData = pets[newIndex]
            if SharedState.SelectedPetData then SharedState.LastTargetedPetMpsValue = SharedState.SelectedPetData.mpsValue or 0 end
        end
    end
end

-- Update Selection Thread
task.spawn(function()
    while true do
        task.wait(0.1)
        if autoStealEnabled then
            local pets = get_all_pets()
            if #pets > 0 then
                -- SAME ORDER THE TELEPORT USES: manual, then the priority list in
                -- EVERY mode, then the mode's own rule.
                --
                -- The priority branch was `elseif stealPriorityEnabled`, so in
                -- Highest/Nearest the panel highlighted the mode's pick while the
                -- flight went to your #1 priority -- the HUD said one pet and you
                -- landed at another. It also walked the list itself with an
                -- untrimmed compare, so a list entry with a stray space matched
                -- here but not in the pickers, or the other way round.
                local _prioPick = _G.Skyr0PickPriority and _G.Skyr0PickPriority(
                    pets, function(p) return p.mpsValue or 0 end)
                if manuallySelectedUID then
                    local found = false
                    for i, p in ipairs(pets) do if p.uid == manuallySelectedUID then applySelection(i, pets); found = true; break end end
                    if not found then manuallySelectedUID = nil; selectedTargetUID = nil; SharedState.SelectedPetData = nil end
                elseif _prioPick then
                    for i, p in ipairs(pets) do
                        if p == _prioPick then applySelection(i, pets); break end
                    end
                elseif stealNearestEnabled then
                    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local bestIndex, bestDist = nil, math.huge
                        for i, p in ipairs(pets) do
                            local targetPart = p.animalData and findAdorneeGlobal(p.animalData)
                            if targetPart and targetPart:IsA("BasePart") then
                                local d = (hrp.Position - targetPart.Position).Magnitude
                                if d < bestDist then bestDist = d; bestIndex = i end
                            end
                        end
                        if bestIndex then
                            applySelection(bestIndex, pets)
                        else
                            SharedState.SelectedPetData = nil
                        end
                    else applySelection(1, pets) end
                else applySelection(1, pets) end
            else SharedState.SelectedPetData = nil end
        else SharedState.SelectedPetData = nil end
    end
end)

-- Heartbeat loop updating bottom HUD labels & executing steals
local function _pbFmtVal(num)
    if not num or num == 0 then return "0" end
    if num >= 1e9 then return string.format("%.2fb", num / 1e9) end
    if num >= 1e6 then return string.format("%.2fm", num / 1e6) end
    if num >= 1e3 then return string.format("%.1fk", num / 1e3) end
    return tostring(math.floor(num))
end

local WHITE = Color3.fromRGB(235, 235, 235)
RunService.RenderStepped:Connect(function()
    pcall(function()
        if not (Config and Config.AutoStealEnabled) then
            hudName.Text = "Disabled"
            hudProgressFill.Size = UDim2.new(0, 0, 1, 0)
            hudPercent.Text = "0%"
            return
        end

        if LocalPlayer:GetAttribute("Stealing") then
            hudProgressFill.Size = UDim2.new(1, 0, 1, 0)
            hudProgressFill.BackgroundColor3 = WHITE
            hudPercent.Text = "100%"
            hudName.Text = "Carrying Brainrot!"
            return
        end

        local status = _G.Skyr0_StealStatus or {}
        if status.active then
            local p = math.clamp((tick() - (status.start or 0)) / (status.duration or 1.3), 0, 1)
            hudProgressFill.Size = UDim2.new(p, 0, 1, 0)
            hudPercent.Text = math.floor(p * 100) .. "%"
            hudProgressFill.BackgroundColor3 = WHITE
            hudName.Text = "Stealing..."
        elseif status.target then
            hudProgressFill.Size = UDim2.new(0, 0, 1, 0)
            hudPercent.Text = "0%"
            hudProgressFill.BackgroundColor3 = WHITE
            local vs = _pbFmtVal(status.target.mps or status.target.value)
            hudName.Text = (status.target.name or "Brainrot") .. ((vs ~= "0") and (" - $" .. vs) or "")
        else
            hudProgressFill.Size = UDim2.new(0, 0, 1, 0)
            hudPercent.Text = "0%"
            hudProgressFill.BackgroundColor3 = WHITE
            hudName.Text = "Searching..."
        end
    end)
end)

end


-- ============================================================
-- PRIORITY ALERT (Skyr0 Styled 3D Viewer with Sorting Queue)
-- ============================================================
local function ShowPriorityAlertImpl(brainrotName, genText, mutation, ownerUsername)
    local normalizedMutation = mutation and mutation:gsub("%s+", ""):lower() or ""
    
    local mutationColors = {
        ["gold"] = Color3.fromRGB(255, 222, 89),
        ["diamond"] = Color3.fromRGB(37, 196, 254),
        ["bloodrot"] = Color3.fromRGB(145, 0, 27),
        ["rainbow"] = Color3.fromRGB(255, 0, 251),
        ["candy"] = Color3.fromRGB(255, 70, 246),
        ["lava"] = Color3.fromRGB(255, 149, 0),
        ["galaxy"] = Color3.fromRGB(210, 45, 45),
        ["yinyang"] = Color3.fromRGB(255, 255, 255),
        ["radioactive"] = Color3.fromRGB(104, 245, 0),
        ["cursed"] = Color3.fromRGB(245, 56, 56),
        ["divine"] = Color3.fromRGB(255, 209, 59),
        ["cyber"] = Color3.fromRGB(121, 219, 255)
    }
    
    local ExploitGui = (gethui and gethui()) or game:GetService("CoreGui")
    local strokeColor = mutationColors[normalizedMutation] or Theme.AccentLight
    local txtColor = Theme.Text
    local subColor = mutationColors[normalizedMutation] or Theme.Dim
    
    local subText = ""
    if normalizedMutation ~= "" and normalizedMutation ~= "none" then
        subText = mutation:upper()
    else
        subText = "NORMAL"
    end
    
    local existing = ExploitGui:FindFirstChild("XiPriorityAlertTest")
    if existing then existing:Destroy() end
    
    if Config.PrioritySoundAlert and Config.PrioritySoundID and Config.PrioritySoundID ~= "" then
        pcall(function()
            local sid = Config.PrioritySoundID:match("%d+")
            if sid then
                local snd = Instance.new("Sound")
                snd.SoundId = "rbxassetid://" .. sid
                snd.Volume = 1
                snd.Parent = game:GetService("SoundService")
                snd:Play()
                game:GetService("Debris"):AddItem(snd, 5)
            end
        end)
    end
    
    local alertGui = Instance.new("ScreenGui")
    if _G.addLazyUI then _G.addLazyUI(alertGui, true, true) end
    alertGui.Name = "XiPriorityAlertTest"
    alertGui.ResetOnSpawn = false
    alertGui.DisplayOrder = 999
    alertGui.Parent = ExploitGui
    
    local alertFrame = Instance.new("Frame")
    alertFrame.Size = UDim2.new(0, 360, 0, 70)
    alertFrame.Position = UDim2.new(0.5, 0, 0, -100) -- Start off-screen top
    alertFrame.AnchorPoint = Vector2.new(0.5, 0)
    alertFrame.BackgroundColor3 = Theme.MainBackground
    alertFrame.BackgroundTransparency = 0.08
    alertFrame.BorderSizePixel = 0
    alertFrame.Parent = registerScreenGui(alertGui)
    
    local gradient = Instance.new("UIGradient", alertFrame)
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.MainBackground),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 244, 249))
    })
    gradient.Rotation = 90
    
    local corner = Instance.new("UICorner", alertFrame)
    corner.CornerRadius = UDim.new(0, 10)
    
    local stroke = Instance.new("UIStroke", alertFrame)
    stroke.Color = strokeColor
    stroke.Thickness = 1.5
    stroke.Transparency = 0.12
    
    local bottomAccent = Instance.new("Frame", alertFrame)
    bottomAccent.Size = UDim2.new(1, -24, 0, 3)
    bottomAccent.Position = UDim2.new(0.5, 0, 1, -4)
    bottomAccent.AnchorPoint = Vector2.new(0.5, 1)
    bottomAccent.BackgroundColor3 = strokeColor
    bottomAccent.BorderSizePixel = 0
    local bottomCorner = Instance.new("UICorner", bottomAccent)
    bottomCorner.CornerRadius = UDim.new(1, 0)
    
    -- 3D Model ViewportFrame on the left
    local viewportFrame = Instance.new("ViewportFrame", alertFrame)
    viewportFrame.Size = UDim2.new(0, 56, 0, 56)
    viewportFrame.Position = UDim2.new(0, 12, 0.5, -2)
    viewportFrame.AnchorPoint = Vector2.new(0, 0.5)
    viewportFrame.BackgroundTransparency = 1
    viewportFrame.BorderSizePixel = 0
    viewportFrame.Ambient = Color3.fromRGB(255, 255, 255)
    viewportFrame.LightColor = strokeColor
    
    local worldModel = Instance.new("WorldModel", viewportFrame)
    local camera = Instance.new("Camera", viewportFrame)
    viewportFrame.CurrentCamera = camera
    
    task.spawn(function()
        local modelsFolder = ReplicatedStorage:FindFirstChild("Models") and ReplicatedStorage.Models:FindFirstChild("Animals")
        local animationsFolder = ReplicatedStorage:FindFirstChild("Animations") and ReplicatedStorage.Animations:FindFirstChild("Animals")
        
        if modelsFolder and brainrotName then
            local sourceModel = modelsFolder:FindFirstChild(brainrotName)
            if not sourceModel then
                for _, child in pairs(modelsFolder:GetChildren()) do
                    if child.Name:lower() == brainrotName:lower() then
                        sourceModel = child
                        break
                    end
                end
            end
            
            if sourceModel then
                local modelClone = sourceModel:Clone()
                modelClone.Parent = worldModel
                
                local cframe, size = modelClone:GetBoundingBox()
                local maxAxis = math.max(size.X, size.Y, size.Z)
                
                if modelClone.PrimaryPart then
                    modelClone:SetPrimaryPartCFrame(CFrame.new(0, 0, 0))
                else
                    modelClone:MoveTo(Vector3.new(0, 0, 0))
                end
                
                -- Zoomed in camera offset
                local cameraOffset = Vector3.new(0, size.Y / 2, -(maxAxis * 0.85))
                camera.CFrame = CFrame.lookAt(cameraOffset, Vector3.new(0, 0, 0))
                
                if animationsFolder then
                    local animFolder = animationsFolder:FindFirstChild(sourceModel.Name)
                    local idleAnim = animFolder and animFolder:FindFirstChild("Idle")
                    if idleAnim and idleAnim:IsA("Animation") then
                        local animator = nil
                        local humanoid = modelClone:FindFirstChildOfClass("Humanoid")
                        local animController = modelClone:FindFirstChildOfClass("AnimationController")
 
                        if humanoid then
                            animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
                        elseif animController then
                            animator = animController:FindFirstChildOfClass("Animator") or Instance.new("Animator", animController)
                        else
                            animController = Instance.new("AnimationController", modelClone)
                            animator = Instance.new("Animator", animController)
                        end
 
                        local animTrack = animator:LoadAnimation(idleAnim)
                        animTrack.Looped = true
                        animTrack:Play(0)
                        task.delay(0.01, function()
                            if animTrack.IsPlaying then
                                animTrack.TimePosition = 0.2
                            end
                        end)
                    end
                end
            end
        end
    end)
    
    local titleLabel = Instance.new("TextLabel", alertFrame)
    titleLabel.Size = UDim2.new(1, -85, 0, 20)
    titleLabel.Position = UDim2.new(0, 76, 0, 12)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = brainrotName .. " - " .. genText
    titleLabel.Font = Enum.Font.GothamBlack
    titleLabel.TextSize = 13
    titleLabel.TextColor3 = txtColor
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local subLabel = Instance.new("TextLabel", alertFrame)
    subLabel.Size = UDim2.new(1, -85, 0, 16)
    subLabel.Position = UDim2.new(0, 76, 0, 32)
    subLabel.BackgroundTransparency = 1
    subLabel.Text = subText .. " (Owner: " .. ownerUsername .. ")"
    subLabel.Font = Enum.Font.GothamBold
    subLabel.TextSize = 10
    subLabel.TextColor3 = subColor
    subLabel.TextXAlignment = Enum.TextXAlignment.Left

    TweenService:Create(alertFrame, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, 0, 0, 20)
    }):Play()
    
    task.delay(4, function()
        if alertFrame and alertFrame.Parent then
            TweenService:Create(alertFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Position = UDim2.new(0.5, 0, 0, -100)
            }):Play()
            task.wait(0.45)
            if alertGui and alertGui.Parent then alertGui:Destroy() end
        end
    end)
end

local highestAlertedPriorityIndex = 99999

task.spawn(function()
    while true do
        task.wait(1.5)
        pcall(function()
            local cache = SharedState.AllAnimalsCache
            if not cache or #cache == 0 then return end
            
            local bestPet = nil
            local bestPriorityIndex = 99999

            -- Lower the priority names ONCE per pass instead of once per
            -- (pet x priority entry): the nested version allocated a new string
            -- for both sides of every comparison -- 60 pets against a 40-name
            -- list is ~4,800 throwaway strings every 1.5s, a small periodic
            -- burst of exactly the kind of garbage this file is being cleaned of.
            local _prioIdx = {}
            for idx = #priorityList, 1, -1 do
                _prioIdx[priorityList[idx]:lower()] = idx
            end

            for _, pet in ipairs(cache) do
                local priorityIndex = pet.name and _prioIdx[pet.name:lower()] or nil

                if priorityIndex then
                    if priorityIndex < bestPriorityIndex then
                        bestPriorityIndex = priorityIndex
                        bestPet = pet
                    end
                end
            end
            
            if bestPet and bestPriorityIndex < highestAlertedPriorityIndex then
                local myName = LocalPlayer.Name
                local myDisplay = LocalPlayer.DisplayName
                if bestPet.owner ~= myName and bestPet.owner ~= myDisplay then
                    highestAlertedPriorityIndex = bestPriorityIndex
                    ShowPriorityAlertImpl(bestPet.name, bestPet.genText, bestPet.mutation, bestPet.owner)
                end
            end
        end)
    end
end)

-- ============================================================
-- PRIORITY SCANNER
-- ============================================================
local PRIORITY_LIST = priorityList
task.spawn(function()
    local ok1,Packages=pcall(function() return ReplicatedStorage:WaitForChild("Packages",5) end); if not ok1 or not Packages then return end
    local ok2,Datas=pcall(function() return ReplicatedStorage:WaitForChild("Datas",5) end); if not ok2 or not Datas then return end
    local ok3,Shared=pcall(function() return ReplicatedStorage:WaitForChild("Shared",5) end); if not ok3 or not Shared then return end
    local ok4,Utils=pcall(function() return ReplicatedStorage:WaitForChild("Utils",5) end); if not ok4 or not Utils then return end
    local okS,Synchronizer=pcall(function() return require(Packages:WaitForChild("Synchronizer")) end); if not okS then return end
    local okA,AnimalsData=pcall(function() return require(Datas:WaitForChild("Animals")) end); if not okA then return end
    local AnimalsShared=_G._xenAnimShim
    local okN,NumberUtils=pcall(function() return require(Utils:WaitForChild("NumberUtils")) end); if not okN then return end
    local allAnimalsCache={}; local lastAnimalData={}

    -- ========================================================
    --  PLOT SCANNER  (ported from the reference hub, end to end)
    --
    --  This is the function that feeds Steal Target -- and therefore the TP,
    --  the priority list and the grapple cycle's "is there a target" check.
    --  What the previous version did, and why the list came up empty:
    --
    --   1. setupPlotListener did `if not ch then return end`.
    --      A base with no client-registered channel never got scanned AT
    --      ALL -- scanSinglePlot was not called once and the periodic loop
    --      never started. Fixing the scan body could not help: it never ran.
    --
    --   2. The channel was resolved by plot.Name (the Model's UUID). The
    --      game also registers channels as Plot1, Plot2, ... so on servers
    --      using that naming the lookup returned nil for EVERY base.
    --
    --   3. `not Players:FindFirstChild(owner.Name)` required the owner to be
    --      ONLINE, and wiped the base from the cache otherwise -- but a base
    --      whose owner logged off is the most common thing worth stealing.
    --
    --   4. The pet list came only from the client's channel cache, which is
    --      empty until the pet streams in.
    --
    --  Now: channel by UUID with the Order key as backup, NO requirement for
    --  a channel to exist, owner from the channel with the PlotSign as
    --  backup, no online requirement, and rendered Models as a second source
    --  so a base still resolves with no channel data whatsoever.
    -- ========================================================

    -- CHANNEL FOR A PLOT -- UUID first, "PlotN" as backup. Deliberately that
    -- order: the UUID is the Model's own key, so a hit is unambiguously THIS
    -- plot's channel. "Plot"..Order is a guess -- nothing verifies the channel
    -- belongs to this base, and if Order is 0-based or offset from the channel
    -- numbering it pairs one plot's podiums with another's slot list. That
    -- yields a REAL, plausible position on the wrong podium, and since the
    -- floor comes from the podium's Y the TP flies to the far side of the base.
    -- Trying the unambiguous key first costs nothing and removes that entirely.
    -- Takes the Instance, not the name: Order only exists on the Model.
    local function _canalDoPlot(plot)
        if not plot then return nil end
        local ch = _G.XenSyncGet and _G.XenSyncGet(plot.Name)
        if type(ch) == "table" then return ch end
        local ord
        pcall(function() ord = plot:GetAttribute("Order") end)
        if ord ~= nil then
            local ch2 = _G.XenSyncGet and _G.XenSyncGet("Plot" .. tostring(ord))
            if type(ch2) == "table" then return ch2 end
        end
        return nil
    end

    -- read order: CacheTable -> direct field -> :Get
    --
    -- CLOSURE-FREE. This allocated up to FOUR function objects per call (the
    -- outer pcall, the nested CacheTable pcall, the rawget pcall and the :Get
    -- pcall), and it is called twice per plot per scan by _listaDePets -- on top
    -- of the per-pet churn below. All of it was immediate garbage feeding the
    -- periodic GC pause.
    --
    -- The rewrite leans on the fact that rawget CANNOT throw on a table, so the
    -- common path needs no protection at all. Only the two operations that can
    -- run user metamethods -- the plain index and the :Get call -- are guarded,
    -- and those use hoisted helpers with pcall(fn, args) instead of a closure.
    local function _rawIndex(t, k) return t[k] end
    local function _chanGetCall(c, k) return c:Get(k) end
    local function _lerCanal(ch, key)
        if type(ch) ~= "table" or key == nil then return nil end
        -- 1) CacheTable, raw first
        local ct = rawget(ch, "CacheTable")
        if type(ct) ~= "table" then
            local ok, c2 = pcall(_rawIndex, ch, "CacheTable")
            if ok and type(c2) == "table" then ct = c2 end
        end
        if type(ct) == "table" then
            local v = rawget(ct, key)
            if v == nil then
                local ok, v2 = pcall(_rawIndex, ct, key)
                if ok then v = v2 end
            end
            if v ~= nil then return v end
        end
        -- 2) direct field on the channel
        local v = rawget(ch, key)
        if v ~= nil then return v end
        -- 3) the module's own getter, last (it is the hookable surface)
        local okG, g = pcall(_rawIndex, ch, "Get")
        if okG and type(g) == "function" then
            local ok2, v2 = pcall(_chanGetCall, ch, key)
            if ok2 then return v2 end
        end
        return nil
    end

    -- Pets live under AnimalList or Animals depending on the server.
    -- AnimalList FIRST: every other reader in this file uses only AnimalList,
    -- and it is that table's keys the podium names match. If Animals happens to
    -- be indexed differently (array 1..n, UUID) the slot lands in another
    -- namespace and getPetPosition resolves the wrong podium, silently.
    -- Animals stays as backup for a server that only has it.
    local function _listaDePets(ch, plotName)
        if ch then
            local al = _lerCanal(ch, "AnimalList")
            if type(al) == "table" then return al end
            al = _lerCanal(ch, "Animals")
            if type(al) == "table" then return al end
        end
        -- Server-side list, if the RequestData probe found one usable. This is
        -- the non-blocking reader: it returns whatever is already cached and
        -- never waits on the wire, so it cannot stall a scan.
        if plotName and _G.Skyr0ReadPlotData then
            local d = _G.Skyr0ReadPlotData(plotName)
            if type(d) == "table" and type(d.AnimalList) == "table" then return d.AnimalList end
        end
        return nil
    end

    -- an entry shows up in five different shapes
    local function _normalizar(ad)
        if type(ad) == "string" then return ad, nil, nil end
        if type(ad) ~= "table" then return nil end
        local idx = ad.Index or ad.AnimalIndex or ad.Animal or ad.Name
        if type(idx) ~= "string" then return nil end
        -- Normalised HERE so everything downstream -- the price, the hash, the
        -- display text -- sees one shape.
        return idx, ad.Mutation, (_G.Skyr0NormTraits and _G.Skyr0NormTraits(ad.Traits) or ad.Traits)
    end

    -- ONE attempt, not one per scan. The old guard only stopped repeating after
    -- a SUCCESS -- and success never happens here: AnimalsShared in this hub is
    -- _G._xenAnimShim, whose GetGeneration is a closure with NO upvalues, so
    -- debug.getupvalue(f, 2) fails every time and the whole pcall re-ran per
    -- plot, every scan, forever. Mark it TRIED on the first go either way.
    local _genTentado = false
    local function _fixGen()
        if _genTentado then return end
        _genTentado = true
        pcall(function()
            if _G.Skyr0FixGeneration then _G.Skyr0FixGeneration(AnimalsShared) end
        end)
    end

    -- game-style formatting, with a fallback that TRUNCATES rather than rounds:
    -- 1.95B becomes "1.9B", never "2B"
    -- hoisted: a `local function` inside _fmtGen allocated a fresh closure on
    -- every fallback-path call, and _fmtGen runs once per pet per scan
    local function _t1(n) return math.floor(n * 10) / 10 end
    local function _fmtGen(v)
        if not v or v == 0 then return "?" end
        -- pcall(method, self, ...) rather than a wrapping closure -- one per pet
        -- per scan otherwise. NumberUtils is checked first because indexing it
        -- while nil would throw OUTSIDE the pcall.
        local s
        if NumberUtils then
            local ok, r = pcall(NumberUtils.ToString, NumberUtils, v)
            if ok then s = r end
        end
        if type(s) == "string" and s ~= "" then return s end
        local t1 = _t1
        if v >= 1e12 then return tostring(t1(v/1e12)) .. "T"
        elseif v >= 1e9 then return tostring(t1(v/1e9)) .. "B"
        elseif v >= 1e6 then return tostring(t1(v/1e6)) .. "M"
        elseif v >= 1e3 then return tostring(t1(v/1e3)) .. "K" end
        return tostring(math.floor(v))
    end

    -- ========================================================
    --  FALLBACK: RENDERED MODELS
    --  DIRECT children of Plots.<UUID> only. Sweeping the whole workspace
    --  would drag in event pets, machines and characters.
    -- ========================================================
    local _catalogo   -- normalised name -> official Index
    local function _montarCatalogo()
        if _catalogo then return _catalogo end
        _catalogo = {}
        pcall(function()
            for idx, info in pairs(AnimalsData or {}) do
                if type(idx) == "string" then
                    _catalogo[idx:lower()] = idx
                    if type(info) == "table" and type(info.DisplayName) == "string" then
                        _catalogo[info.DisplayName:lower()] = idx
                    end
                end
            end
        end)
        return _catalogo
    end

    local _SUF = { K=1e3, M=1e6, B=1e9, T=1e12, Q=1e15, Qi=1e18,
                   Sx=1e21, Sp=1e24, Oc=1e27 }

    -- last resort for MPS: read the "$X/s" the pet itself displays
    local function _mpsDoTexto(model)
        local achado
        for _, d in ipairs(model:GetDescendants()) do
            if d:IsA("TextLabel") and type(d.Text) == "string" then
                local num, suf = d.Text:match("%$%s*([%d%.]+)%s*(%a*)%s*/s")
                if num then
                    local v = tonumber(num)
                    if v then
                        if suf and suf ~= "" then
                            local m = _SUF[suf] or _SUF[suf:sub(1,1):upper() .. (suf:sub(2) or "")]
                            if m then v = v * m end
                        end
                        achado = v
                        break
                    end
                end
            end
        end
        return achado
    end

    -- The slot comes from the NEAREST PODIUM, never from the Model's pivot: the
    -- TP destination has to stay on the podium system. Podium positions are
    -- cached because they do not move, and recomputing GetPivot for all of them
    -- per Model per scan was the cost that forced a long scan interval.
    local _podCache = {}
    -- SECOND-CHANCE CACHE, for the window where the podium folder is only
    -- PARTLY replicated.
    --
    -- The permanent cache below deliberately refuses to latch until every
    -- numeric podium has arrived -- caching 2 of 8 would freeze the incomplete
    -- map for the session. Correct, but it left a hole exactly where it hurts:
    -- during load NOTHING latches, so this function fell through to the full
    -- rebuild EVERY time it was asked.
    --
    -- And it is asked once per rendered Model per scan. Eight plots, ~8 pets
    -- each, ~8 podiums each, rescanning at 0.25s: that is thousands of GetPivot
    -- calls and hundreds of throwaway tables per second, all recomputing the
    -- same answer within a single scan pass. That is the slow scanner.
    --
    -- So the provisional result is kept too, just briefly. _POD_TTL is shorter
    -- than the 0.25s scan interval, so every model in ONE pass shares one
    -- rebuild while the NEXT pass still re-checks for podiums that have since
    -- streamed in. The "never freeze an incomplete map" rule is intact -- this
    -- expires on its own; only the complete map is kept for good.
    local _podTmp = {}
    local _POD_TTL = 0.2
    -- how long the podium count must hold steady before the map is trusted
    -- as complete and cached for good -- see the note at the latch below
    local _podSeen = {}
    local _POD_STABLE = 1.0
    local function _podiumsDe(plot)
        local c = _podCache[plot.Name]
        if c then return c end
        local podiums = plot:FindFirstChild("AnimalPodiums")
        if not podiums then return nil end
        local filhos = podiums:GetChildren()
        -- The provisional map is only reused while the folder has not GROWN.
        --
        -- A plain time check was not enough: during load the held map can be
        -- 2 podiums out of 8, and a pet on podium 5 fails _slotDoModel's 8-stud
        -- test and drops out of the scan entirely. Holding that for the full
        -- TTL would delay the very pets this is meant to find faster.
        --
        -- Comparing the child count costs one GetChildren -- which is needed a
        -- line later anyway -- against the eight GetPivot calls and eight table
        -- allocations a rebuild costs. So a podium streaming in invalidates
        -- immediately, and a folder that has not changed still skips the sweep.
        local tmp = _podTmp[plot.Name]
        if tmp and (os.clock() - tmp.at) < _POD_TTL and tmp.n == #filhos then
            return tmp.lista
        end
        local lista = {}
        for _, pod in ipairs(filhos) do
            -- REAL podiums only. A slot name is always numeric. Without this
            -- guard a "Decorations" child became a slot -- uid "<uuid>_Decorations"
            -- -- and getPetPosition resolved that object's pivot: arbitrary
            -- position and floor, which is the TP flying into nothing.
            if tonumber(pod.Name) then
                -- pcall(method, self) not a closure: this runs per podium, per
                -- rendered model, per scan whenever the cache below has not
                -- latched (a partially replicated podium folder never latches).
                local ok, cf = pcall(pod.GetPivot, pod)
                if ok and cf then lista[#lista+1] = { nome = pod.Name, pos = cf.Position } end
            end
        end
        if #lista == 0 then return nil end
        -- ============================================================
        --  ONLY LATCH ONCE THE FOLDER HAS STOPPED GROWING.
        --
        --  The intent here was always "do not freeze a partially replicated
        --  podium map" -- caching 2 of 8 podiums means the other 6 are never
        --  seen again for the whole session, so every pet on them resolves to
        --  the wrong slot and the TP lands on the wrong podium.
        --
        --  The old test could not detect that. It was:
        --      #lista == numericos
        --  and `numericos` was counted from `filhos` -- the SAME snapshot
        --  `lista` was just built from. So it compared the folder against
        --  itself. Two podiums replicated, both pivot fine, 2 == 2: latched,
        --  permanently, on a quarter of the map. The only thing that condition
        --  ever caught was a GetPivot that threw.
        --
        --  What actually distinguishes "still streaming" from "complete" is
        --  whether the count is still MOVING. So the count is remembered and
        --  the map is only latched once it has held steady for _POD_STABLE --
        --  by then the folder has finished arriving. Until it does the result
        --  is still returned, just held provisionally, so nothing waits on this.
        -- ============================================================
        local numericos = 0
        for _, pod in ipairs(filhos) do if tonumber(pod.Name) then numericos = numericos + 1 end end
        local prev = _podSeen[plot.Name]
        local agora = os.clock()
        if not prev or prev.n ~= numericos then
            -- first sight, or the folder just grew: restart the stability clock
            _podSeen[plot.Name] = { n = numericos, at = agora }
            prev = nil
        end
        if #lista == numericos and numericos > 0
           and prev and (agora - prev.at) >= _POD_STABLE then
            _podCache[plot.Name] = lista
            _podTmp[plot.Name] = nil
        else
            -- still settling: hold it for _POD_TTL only, never permanently
            _podTmp[plot.Name] = { lista = lista, at = agora, n = #filhos }
        end
        return lista
    end

    local function _slotDoModel(plot, model)
        local lista = _podiumsDe(plot)
        if not lista then return nil end
        local okp, cfp = pcall(model.GetPivot, model)   -- closure-free: once per model per scan
        if not okp or not cfp then return nil end
        local pivo = cfp.Position
        local melhor, melhorD
        for _, pod in ipairs(lista) do
            local d = (pod.pos - pivo).Magnitude
            if not melhorD or d < melhorD then melhorD, melhor = d, pod.nome end
        end
        if melhor and melhorD and melhorD <= 8 then return melhor end
        return nil
    end

    local function scanSinglePlot(plot) pcall(function()
        _fixGen()
        local nome = plot.Name
        local ch = _canalDoPlot(plot)

        local function limpar()
            lastAnimalData[nome] = nil
            for i=#allAnimalsCache,1,-1 do
                if allAnimalsCache[i].plot == nome then table.remove(allAnimalsCache, i) end
            end
        end

        -- Owner from the channel's Owner field, with the old fallbacks.
        -- "YOUR BASE" on the PlotSign does NOT prove ownership.
        local ownerName = ""
        if ch then
            local o = _lerCanal(ch, "Owner")
            if typeof(o) == "string" then ownerName = o
            elseif typeof(o) == "Instance" and o:IsA("Player") then ownerName = o.Name
            elseif type(o) == "table" then
                if o.Name then ownerName = tostring(o.Name)
                elseif o.UserId then
                    local p = Players:GetPlayerByUserId(o.UserId)
                    if p then ownerName = p.Name end
                end
            end
        end
        if ownerName == "" then
            pcall(function()
                local t = plot.PlotSign.SurfaceGui.Frame.TextLabel.Text
                if t and t ~= "" then
                    local low = t:lower()
                    -- "sua base" kept alongside "your base": the reference hub
                    -- carries it, which means that string was actually seen on
                    -- a live sign. Missing it would read the localized
                    -- "your base" text as an owner NAME and mark your own plot
                    -- as someone else's -- i.e. auto-steal aiming at yourself.
                    if not (low:find("your base") or low:find("sua base") or low:find("^empty")) then
                        ownerName = (t:gsub("'s Base$",""):gsub(" Base$",""):match("^%s*(.-)%s*$"))
                    end
                end
            end)
        end

        local vistos, novos = {}, {}
        local nSync, nRend = 0, 0

        local function addPet(idx, mut, traits, slot, mpsFallback, viaSync)
            if type(idx) ~= "string" or slot == nil then return end
            local info = AnimalsData and AnimalsData[idx]
            if not info then return end
            if info.Egg == true or info.LuckyBlock == true then return end

            -- KEYED BY SLOT ALONE. With the Index in the key the two passes only
            -- collided when they already agreed about the animal -- exactly when
            -- it did not matter. If the channel said slot 5 = Cow while the
            -- rendered Model was still the previous Dragon, the keys differed and
            -- BOTH went in: two entries with the same uid and slot, and the TP
            -- landed on the wrong pet.
            local chave = nome .. ":" .. tostring(slot)
            if vistos[chave] then return end          -- sync wins
            vistos[chave] = true

            local m = mut or "None"; if m == "Yin Yang" then m = "YinYang" end
            -- table.concat THROWS on a table holding anything but strings and
            -- numbers, and this whole scan runs inside one pcall -- so a single
            -- traited pet in an unexpected shape used to abort the entire plot
            -- and take every other pet on that base down with it.
            local tList = _G.Skyr0NormTraits and _G.Skyr0NormTraits(traits) or nil
            traits = tList
            local tTxt = (tList and #tList > 0) and table.concat(tList, ", ") or "None"

            local gv
            -- pcall(method, self, ...) instead of pcall(function() ... end).
            --
            -- The closure form allocated a NEW function object on every call --
            -- and this runs once per pet, per plot, per scan. With ~10 plots on a
            -- 0.25s loop and ~10 pets each, that alone was ~400 throwaway
            -- closures a second, and the two below made it ~1200. Steady garbage
            -- at that rate is what turns into a periodic GC pause -- the "every
            -- few seconds the game hitches". Same fix getPetPosition already
            -- documents a few hundred lines up.
            --
            -- These capture upvalues (gv/idx/mut/traits), so Luau cannot cache
            -- and reuse them the way it does for a constant closure.
            local _okg, _g = pcall(AnimalsShared.GetGeneration, AnimalsShared, idx, mut, traits, nil)
            if _okg then gv = _g end
            -- mpsFallback arrives as a FUNCTION, not a value. It used to come in
            -- pre-computed, and Lua evaluates arguments before the call -- so the
            -- GetDescendants sweep inside _mpsDoTexto ran for EVERY rendered pet,
            -- on EVERY plot, every scan, even when GetGeneration had succeeded
            -- and the value was thrown away.
            if type(gv) ~= "number" and type(mpsFallback) == "function" then
                gv = mpsFallback()
            elseif type(gv) ~= "number" then
                gv = mpsFallback
            end
            if type(gv) ~= "number" then return end

            local pv = 0
            local _okv, _v = pcall(AnimalsShared.GetValue, AnimalsShared, idx, mut, traits, nil)
            if _okv then pv = _v end
            if type(pv) ~= "number" then pv = 0 end

            novos[#novos+1] = {
                name = info.DisplayName or idx, index = idx,
                genText = "$" .. _fmtGen(gv) .. "/s", genValue = gv, petValue = pv,
                mutation = m, traits = tTxt, owner = ownerName,
                plot = nome, slot = tostring(slot),
                uid = nome .. "_" .. tostring(slot),
            }
            if viaSync then nSync = nSync + 1 else nRend = nRend + 1 end
        end

        -- ---------- 1. Synchronizer ----------
        local al = _listaDePets(ch, nome)
        if type(al) == "table" then
            for slot, ad in pairs(al) do
                local idx, mut, traits = _normalizar(ad)
                if idx then addPet(idx, mut, traits, slot, nil, true) end
            end
        end

        -- ---------- 2. Rendered Models ----------
        local cat = _montarCatalogo()
        for _, m in ipairs(plot:GetChildren()) do
            if m:IsA("Model") then
                local idx = cat[m.Name:lower()]
                if idx then
                    local slot = _slotDoModel(plot, m)
                    if slot then
                        -- pass the FUNCTION, not the result: only computed if
                        -- GetGeneration failed
                        addPet(idx, m:GetAttribute("Mutation"), nil, slot,
                               function() return _mpsDoTexto(m) end, false)
                    end
                end
            end
        end

        -- THIS BASE HAS NOW REPORTED. Marked here, before the empty-plot
        -- early return, because "scanned and empty" is a real answer and the
        -- teleport must be able to count it -- otherwise an empty base would
        -- hold coverage below 100% forever and the fast path below could never
        -- arm.
        if not SharedState.PlotsSeen[nome] then
            SharedState.PlotsSeen[nome] = true
            SharedState.PlotsScanned = (SharedState.PlotsScanned or 0) + 1
        end
        -- Upgradeable: a base commonly reports from rendered models first and
        -- only gets its channel a moment later, so this promotes rather than
        -- being decided once at first sight.
        if ch and SharedState.PlotsSeen[nome] ~= "full" then
            SharedState.PlotsSeen[nome] = "full"
            SharedState.PlotsFull = (SharedState.PlotsFull or 0) + 1
        end
        if #novos == 0 and not al then limpar(); return end

        -- HASH OVER THE ACTUAL RESULT, not over a count.
        --
        -- It used to be getAnimalHash(al) .. "|r" .. #novos. Three holes:
        --  * with no channel, getAnimalHash(nil) = "" and only the count was
        --    left. Swapping the pet on podium 3 keeps the count -> the cache
        --    froze with the old pet forever. A pet moving from podium 2 to 6
        --    also slipped through, and the TP went to an empty podium.
        --  * Traits were not in the hash but ARE in GetGeneration -> genValue
        --    and the ordering went stale.
        --  * ownerName was not in it. For your own base the name only resolves
        --    once the channel arrives; if the list did not change in that
        --    window the "" got recorded -- and every filter is
        --    `owner ~= LocalPlayer`, which "" passes. Result: auto-steal
        --    targeting your own base.
        local partes = { ownerName }
        for _, p in ipairs(novos) do
            partes[#partes+1] = p.slot .. "|" .. p.index .. "|" .. p.mutation .. "|" .. p.traits
        end
        table.sort(partes)          -- pairs() has no stable order
        local hash = table.concat(partes, ";")
        if lastAnimalData[nome] == hash then return end

        for i=#allAnimalsCache,1,-1 do
            if allAnimalsCache[i].plot == nome then table.remove(allAnimalsCache, i) end
        end
        for _, p in ipairs(novos) do allAnimalsCache[#allAnimalsCache+1] = p end

        lastAnimalData[nome] = hash
        table.sort(allAnimalsCache, function(a,b) return a.genValue > b.genValue end)
        SharedState.AllAnimalsCache = allAnimalsCache
        SharedState.ListNeedsRedraw = true
        -- Bumped ONLY here and on plot removal -- i.e. only when the cache
        -- genuinely changed, since the hash gate above has already returned for
        -- a scan that found nothing new. Everything that derives a list from the
        -- cache (get_all_pets, the Steal Target panel) rebuilds when this moves
        -- and reuses its last answer when it does not, which is what stops those
        -- consumers from rebuilding the same list several times a second.
        SharedState.CacheVersion = (SharedState.CacheVersion or 0) + 1

    end) end

    local function setupPlotListener(plot, phase)
        -- ====================================================
        --  THIS WAS THE GATE THAT KILLED STEAL TARGET
        --
        --  It used to be:
        --      ... _G.Skyr0_GetPlotChannel(plot.Name) ...
        --      if not ch then return end
        --
        --  Two faults compounding:
        --   1. it resolved the channel by plot.Name (the Model UUID). With the
        --      game naming channels Plot1/Plot2 that is nil for EVERY base.
        --   2. with no channel it RETURNED -- so scanSinglePlot was never
        --      called and the periodic loop never started. Fixing the scan body
        --      could not help: it did not run.
        --
        --  Now it resolves UUID-first with Order as backup and, far more
        --  importantly, does NOT give up when the channel is missing: the
        --  rendered-Model fallback works with no channel at all.
        -- ====================================================
        -- FIRST SCAN IMMEDIATELY, waiting for no channel. Previously the scan
        -- only happened AFTER a loop of up to 40x0.07s (~2.8s) -- and that was
        -- paid even when the rendered Models were already on screen and could
        -- have given a target straight away.
        scanSinglePlot(plot)

        -- The channel resolves in parallel; rescan the moment it lands.
        --
        -- TIME-BOUNDED, not attempt-bounded. This was 40 tries at 0.07s -- it
        -- expired after 2.8 SECONDS, which on a streaming-heavy join is well
        -- before the Synchronizer registry is populated. When it expired the
        -- plot was left on whatever the channel-free first scan found (rendered
        -- models only) until the 0.25s safety loop happened to catch it, and if
        -- the registry was still empty then too, that state just persisted.
        --
        -- Now it keeps watching for 45s with a gap that widens once the initial
        -- burst is over: fast while it matters, nearly free afterwards.
        task.spawn(function()
            local t0 = os.clock()
            while plot.Parent and (os.clock() - t0) < 45 do
                local ok, r = pcall(_canalDoPlot, plot)   -- closure-free
                if ok and r then
                    -- ================================================
                    --  THE CHANNEL ARRIVING IS NOT THE DATA ARRIVING.
                    --
                    --  This used to scan once here and return, handing the base
                    --  back to the 0.25s safety loop. But _canalDoPlot answers
                    --  the moment the REGISTRY has the channel object -- its
                    --  AnimalList is routinely still empty or half filled at
                    --  that point, so the one scan taken right here often read
                    --  nothing and the base then sat until the next 0.25s tick.
                    --
                    --  That matters because Synchronizer data arrives with NO
                    --  Instance event behind it: no ChildAdded fires, so the
                    --  event-driven path below cannot see it and the periodic
                    --  loop is the only thing that will. Up to a quarter second
                    --  of latency on the base holding your priority pet, and
                    --  the TP-on-load window is waiting on exactly that.
                    --
                    --  So the base is polled hard for a short window after its
                    --  channel lands, until it actually yields pets. Bounded by
                    --  time AND by success, and it only ever runs in the first
                    --  couple of seconds of a base's life -- the steady state is
                    --  untouched.
                    -- ================================================
                    local c0 = os.clock()
                    while plot.Parent and (os.clock() - c0) < 2 do
                        scanSinglePlot(plot)
                        -- lastAnimalData is only written once a scan actually
                        -- produced something, so this is "the base has reported
                        -- real pets" -- stop early and stop paying for it.
                        if lastAnimalData[plot.Name] then return end
                        task.wait(0.06)
                    end
                    return
                end
                task.wait((os.clock() - t0) < 3 and 0.07 or 0.5)
            end
        end)

        -- ====================================================
        --  INSTANT EVENT-DRIVEN DETECTION
        --
        --  The periodic loop becomes just a safety net. These two events give
        --  the immediate answer: a pet placed on or taken off the plot is a
        --  DIRECT child entering or leaving.
        --
        --  ChildAdded on purpose, not DescendantAdded: the latter fires
        --  thousands of times while each base's parts stream in at startup,
        --  which is exactly what used to freeze the game.
        --
        --  30ms debounce because a pet arrives as several parts in sequence;
        --  this groups them into one scan.
        -- ====================================================
        local _pend = false
        local function agora()
            if _pend then return end
            _pend = true
            task.defer(function()
                task.wait(0.03)
                _pend = false
                scanSinglePlot(plot)
            end)
        end
        plot.ChildAdded:Connect(agora)
        plot.ChildRemoved:Connect(agora)

        -- STAGGER: offset each plot's scan phase so they do NOT all scan on the
        -- same frame. Every plot's loop starting together meant all ~8
        -- scanSinglePlot calls landed in one frame -- that synchronized burst
        -- was the recurring FPS spike.
        if phase and phase > 0 then task.wait(phase) end
        -- 0.25s rather than 0.5s. It is cheap enough now: _fixGen no longer
        -- repeats per scan, _mpsDoTexto only runs when actually needed, and the
        -- hash gate already avoids rebuilding the list when nothing changed.
        task.spawn(function() while plot.Parent do task.wait(0.25); scanSinglePlot(plot) end end)
    end
    local plots=Workspace:WaitForChild("Plots",8)
    if plots then
        local kids = plots:GetChildren()
        local n = #kids
        SharedState.PlotsTotal = n
        for i,p in ipairs(kids) do
            task.spawn(setupPlotListener, p, (n > 0) and ((i - 1) * (0.5 / n)) or 0)
        end
        SharedState.InitialScanComplete=true
        plots.ChildAdded:Connect(function(p) SharedState.PlotsTotal = (SharedState.PlotsTotal or 0) + 1; task.wait(0.5 + math.random() * 0.5); task.spawn(setupPlotListener, p, math.random() * 0.5) end)
        plots.ChildRemoved:Connect(function(p) lastAnimalData[p.Name]=nil; if SharedState.PlotsSeen[p.Name] then if SharedState.PlotsSeen[p.Name]=="full" then SharedState.PlotsFull=math.max(0,(SharedState.PlotsFull or 1)-1) end; SharedState.PlotsSeen[p.Name]=nil; SharedState.PlotsScanned=math.max(0,(SharedState.PlotsScanned or 1)-1) end; SharedState.PlotsTotal=math.max(0,(SharedState.PlotsTotal or 1)-1); for i=#allAnimalsCache,1,-1 do if allAnimalsCache[i].plot==p.Name then table.remove(allAnimalsCache,i) end end; SharedState.ListNeedsRedraw=true; SharedState.CacheVersion=(SharedState.CacheVersion or 0)+1 end)
    end
    task.spawn(function() while true do SharedState.AllAnimalsCache=allAnimalsCache; task.wait(0.5) end end)
end)

-- Steal attribute listeners
player:GetAttributeChangedSignal("Stealing"):Connect(function()
    local isStealing=(player:GetAttribute("Stealing")==true)
    if FloatState.active and not isStealing then setFloat(false) end
    if _G.AutoInvisDuringSteal then
        if isStealing and not _G.invisibleStealEnabled and _G._forceInvisToggle then task.defer(function() if player:GetAttribute("Stealing") and not _G.invisibleStealEnabled then pcall(_G._forceInvisToggle) end end)
        elseif not isStealing and _G.invisibleStealEnabled and _G._forceInvisToggle then task.wait(0.3); if not player:GetAttribute("Stealing") then pcall(_G._forceInvisToggle) end end
    end
    if isStealing and Config.AutoUnlockOnSteal then
        local hrp=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local floor = getCurrentUnlockFloor()
            task.spawn(function()
                task.wait(0.1)
                pcall(smartInteract, floor)
            end)
        end
    end
end)

player.CharacterAdded:Connect(function() task.wait(0.5); if FloatState.active then removeFloatPlatform(); createFloatPlatform() end end)

-- ============================================================
-- TP SYSTEM
-- ============================================================
function findAdorneeGlobal(animalData)
    if not animalData then return nil end
    local plot = Workspace:FindFirstChild("Plots") and Workspace.Plots:FindFirstChild(animalData.plot)
    if plot then
        local podiums = plot:FindFirstChild("AnimalPodiums")
        if podiums then
            local podium = podiums:FindFirstChild(animalData.slot)
            if podium then
                local base = podium:FindFirstChild("Base")
                if base then
                    local spawn = base:FindFirstChild("Spawn")
                    if spawn then return spawn end
                    return base:FindFirstChildWhichIsA("BasePart") or base
                end
            end
        end
    end
    return nil
end

function getClosestBaseSign(brainrotPart)
    if not brainrotPart or not brainrotPart:IsA("BasePart") then return nil end
    local closestPart = nil
    local closestDist = math.huge
    for _, label in ipairs(Workspace:GetDescendants()) do
        if label:IsA("TextLabel") then
            local txt = tostring(label.Text or "")
            if (txt ~= "") and txt:lower():find("base", 1, true) then
                local gui = label:FindFirstAncestorWhichIsA("SurfaceGui")
                if gui then
                    local part = gui.Adornee or gui.Parent
                    if part and part:IsA("BasePart") then
                        local dist = (part.Position - brainrotPart.Position).Magnitude
                        if dist < closestDist then
                            closestDist = dist
                            closestPart = part
                        end
                    end
                end
            end
        end
    end
    return closestPart
end


function equipTpToolAndWait(hum)
    if not hum then return nil end
    local char = hum.Parent
    local toolName = Config.TpSettings.Tool or "Flying Carpet"
    local tool = LocalPlayer.Backpack:FindFirstChild(toolName) or (char and char:FindFirstChild(toolName))
    if tool then
        hum:EquipTool(tool)
        task.wait(0.02)
    end
    return tool
end


function waitSecondsHeartbeat(sec)
    local t = 0
    while t < sec do
        t += RunService.Heartbeat:Wait()
    end
end

function waitUntilHeartbeat(predicate, timeoutSec)
    local t = 0
    while true do
        if predicate() then
            return true
        end
        local dt = RunService.Heartbeat:Wait()
        t += dt
        if timeoutSec and (t >= timeoutSec) then
            return false
        end
    end
end

-- ============================================================
-- TELEPORT SYSTEM STAGE 2
-- ============================================================
TP_V2_MED_POINTS = {
    { name = "MED1", pos = Vector3.new(-410.65, -5.68, -46.1) },
    { name = "MED2", pos = Vector3.new(-410.91, -5.68, 168.89) },
}



function flatDistance(a, b)
    return (Vector3.new(a.X, 0, a.Z) - Vector3.new(b.X, 0, b.Z)).Magnitude
end

_G._isTargetPlotUnlocked = function(plotName)
    local ok, res = pcall(function()
        local plots = Workspace:FindFirstChild("Plots")
        if not plots then return false end
        local targetPlot = plots:FindFirstChild(plotName)
        if not targetPlot then return false end
        local unlockFolder = targetPlot:FindFirstChild("Unlock")
        if not unlockFolder then return true end
        local unlockItems = {}
        for _, item in pairs(unlockFolder:GetChildren()) do
            local pos = nil
            if item:IsA("Model") then
                pcall(function() pos = item:GetPivot().Position end)
            elseif item:IsA("BasePart") then
                pos = item.Position
            end
            if pos then
                table.insert(unlockItems, { Object = item, Height = pos.Y })
            end
        end
        table.sort(unlockItems, function(a, b) return a.Height < b.Height end)
        if #unlockItems == 0 then return true end
        local floor1Door = unlockItems[1].Object
        for _, desc in ipairs(floor1Door:GetDescendants()) do
            if desc:IsA("ProximityPrompt") and desc.Enabled then return false end
        end
        for _, child in ipairs(floor1Door:GetChildren()) do
            if child:IsA("ProximityPrompt") and child.Enabled then return false end
        end
        return true
    end)
    return (ok and res) or false
end


function getNearestTeleportV2MedPoint(fromPos)
    local bestPoint = nil
    local bestDist = math.huge
    for _, entry in ipairs(TP_V2_MED_POINTS) do
        local dist = flatDistance(fromPos, entry.pos)
        if dist < bestDist then
            bestDist = dist
            bestPoint = entry
        end
    end
    return bestPoint, bestDist
end




local FLY_SPEED = 160
local FLY_RISE_SPEED = 200
local FLY_RAY_DIST = 20
local FLY_TIMEOUT = 15
local FLY_ARRIVE_DIST = 4
local flyRayParams = RaycastParams.new()
flyRayParams.FilterType = Enum.RaycastFilterType.Exclude

function flyForwardTo(hrp, tpPos, lookDir, targetY, customSpeed)
    if not hrp or not hrp.Parent then
        return false
    end
    local char = hrp.Parent
    local hum = char:FindFirstChildOfClass("Humanoid")
    local unwalkConn
    if hum then
        local animator = hum:FindFirstChildOfClass("Animator")
        if animator then
            unwalkConn = RunService.Heartbeat:Connect(function()
                pcall(function()
                    for _, tr in ipairs(animator:GetPlayingAnimationTracks()) do
                        tr:Stop()
                    end
                end)
            end)
        end
    end
    flyRayParams.FilterDescendantsInstances = { char }
    local startTime = os.clock()
    while hrp.Parent do
        if (os.clock() - startTime) > FLY_TIMEOUT then
            break
        end
        if LocalPlayer:GetAttribute("Stealing") then
            break
        end
        local myPos = hrp.Position
        local flatDiff = Vector3.new(tpPos.X - myPos.X, 0, tpPos.Z - myPos.Z)
        local flatDist = flatDiff.Magnitude
        if flatDist < FLY_ARRIVE_DIST then
            break
        end
        local moveDir = flatDiff.Unit
        local yVel = 0
        if tpPos.Y <= 10 then
            -- Glue the feet to the floor by offsetting the HumanoidRootPart by +3.5 studs to prevent clipping into the ground and dying
            local targetFloorY = tpPos.Y + 3.5
            if targetY then
                -- Diagonal smooth ascent starting from 60 studs away down to 20 studs away
                if flatDist <= 60 then
                    local t = math.clamp((60 - flatDist) / (60 - 20), 0, 1)
                    targetFloorY = (tpPos.Y + 3.5) + (targetY - tpPos.Y) * t
                end
            end

            -- Ballistic arc: climb to cruise altitude that clears typical two-floor
            -- base walls (~30 studs), hold it over the obstacle, then descend into
            -- the target. The old code only rose when a wall was ~20 studs away --
            -- too late to clear it at 160 studs/sec cruise, so the character just
            -- slammed into walls.
            local CRUISE_ALT   = tpPos.Y + 35   -- well above roof height of a full 2-floor base
            local DESCEND_DIST = 25             -- start descent when this close (X/Z) to target
            local LOOKAHEAD    = 80             -- scan this far ahead for tall obstacles

            -- Long-range multi-height scan for tall obstacles in the path
            local hasTallObstacleAhead = false
            for _, hoff in ipairs({-3, 0, 3, 8}) do
                local rayFwd = Workspace:Raycast(myPos + Vector3.new(0, hoff, 0), moveDir * LOOKAHEAD, flyRayParams)
                if rayFwd and rayFwd.Instance and rayFwd.Instance.CanCollide then
                    local topY = rayFwd.Instance.Position.Y + (rayFwd.Instance.Size.Y / 2)
                    if (topY - tpPos.Y) > 5 then
                        hasTallObstacleAhead = true
                        break
                    end
                end
            end

            if flatDist > DESCEND_DIST and (hasTallObstacleAhead or myPos.Y < CRUISE_ALT - 5) then
                -- Climb/cruise phase: rise until at cruise altitude, then hold it
                if myPos.Y < CRUISE_ALT then
                    yVel = FLY_RISE_SPEED
                else
                    yVel = 0
                end
            elseif flatDist <= DESCEND_DIST then
                -- Descent phase: pull down toward the target ground level
                yVel = math.clamp((targetFloorY - myPos.Y) * 4, -150, 0)
            elseif myPos.Y > targetFloorY + 5 then
                -- Coasting mid-arc with no obstacle ahead -- hold altitude, no snap
                yVel = 0
            else
                -- Already low and nothing tall ahead -- snap to target ground so
                -- gravity/carpet don't drift us down into terrain
                hrp.CFrame = CFrame.new(hrp.Position.X, targetFloorY, hrp.Position.Z) * (hrp.CFrame - hrp.CFrame.Position)
                yVel = 0
            end
        else
            -- Normal rise/fall behavior for second floor
            local rayFwd = Workspace:Raycast(myPos, moveDir * FLY_RAY_DIST, flyRayParams)
            if rayFwd then
                yVel = FLY_RISE_SPEED
            end
            local rayDown = Workspace:Raycast(myPos, Vector3.new(0, -12, 0), flyRayParams)
            if rayDown and ((myPos.Y - rayDown.Position.Y) < 5) then
                yVel = math.max(yVel, 100)
            end
            if not rayFwd and (tpPos.Y < (myPos.Y - 3)) then
                yVel = math.clamp((tpPos.Y - myPos.Y) * 3, -120, 0)
            end
        end
        local speed = customSpeed or Config.TpSettings.FlyTPSpeed or FLY_SPEED
        hrp.AssemblyLinearVelocity = (moveDir * speed) + Vector3.new(0, yVel, 0)
        hrp.AssemblyAngularVelocity = Vector3.zero
        RunService.Heartbeat:Wait()
    end
    if unwalkConn then
        unwalkConn:Disconnect()
        unwalkConn = nil
    end
    if not hrp.Parent then
        return false
    end
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
    local finalY = targetY or tpPos.Y
    local finalPos = Vector3.new(tpPos.X, finalY, tpPos.Z)
    hrp.CFrame = CFrame.lookAt(finalPos, finalPos + (lookDir or hrp.CFrame.LookVector))
    hrp.AssemblyLinearVelocity = Vector3.zero
    return true
end

function prepMiniTpTool(hum, hrp)
    if not hum or not hrp then return end
end

local function getTargetPetData()
    local cache = SharedState.AllAnimalsCache
    if not cache or #cache == 0 then
        return nil
    end
    
    -- get_all_pets() IS NOT CALLED HERE ANY MORE.  See step 3.
    --
    -- It used to be `local pets = get_all_pets()` right here, unconditionally,
    -- and THAT is why the scanner felt slow on load.
    --
    -- get_all_pets builds a fresh table for every pet on the server and sorts
    -- the result. It is memoised against SharedState.CacheVersion, which makes
    -- it nearly free in the steady state -- but the memo key IS the version, so
    -- every bump is a guaranteed miss and a full rebuild.
    --
    -- Now look at when this function runs during load: the TP-on-load settle
    -- loop calls it on EVERY CacheVersion bump. That is the one moment the memo
    -- can never hit. Eight plots streaming in, each rescanning at 0.25s, each
    -- bump firing a full rebuild+sort of the whole server -- and the result then
    -- thrown away unread, because every branch below returns before it.
    --
    -- The list is read at exactly ONE place: step 3, the last-resort "biggest
    -- earner" fallback, reached only when the manual override, the priority
    -- list, Nearest, Highest Value and the brainrot sweep have all found
    -- nothing. On a live server the brainrot branch answers almost every call.
    --
    -- So it is built where it is used. Nothing else in here reads it, and
    -- get_all_pets has no side effect anything depends on (it writes
    -- SharedState.BrainrotNames, which nothing reads).

    -- 1) Manual Override First
    if manuallySelectedUID then
        for _, a in ipairs(cache) do
            if a.uid == manuallySelectedUID and a.owner ~= LocalPlayer.Name then
                return a
            end
        end
    end
    
    -- PRIORITY LIST FIRST, THEN THE MODE.
    --
    -- This function is not "the panel's picker" -- it is THE picker. Skyr0CicloTP
    -- calls it to aim the grapple and stashes the result in _G.Skyr0TPLockedPet,
    -- and doVelocityTP honours that lock BEFORE it ever reaches _pickByMode. So
    -- on the normal (grapple) path this is what decides where you land, and it
    -- has to agree with _pickByMode exactly -- same list, same tie-break, same
    -- order of tiers. It used to agree with it on nothing.
    --
    -- The mode is read here only to choose the fallback for when NOTHING on the
    -- priority list is on the server. It never gates the list itself.
    local _mode = _G.Skyr0ResolveMode and _G.Skyr0ResolveMode() or "Priority"
    local _plots = Workspace:FindFirstChild("Plots")
    local _myChar = LocalPlayer.Character
    local _myHrp = _myChar and _myChar:FindFirstChild("HumanoidRootPart")
    -- pcall(method, self) rather than pcall(function() ... end): the closure form
    -- allocated a function object per pet per call, and this sits behind a 0.1s
    -- poll on launch. Same fix getPetPosition and scanSinglePlot already document.
    local _plotPos = function(a)
        local pl = a and a.plot and _plots and _plots:FindFirstChild(a.plot)
        if not pl then return nil end
        local ok, cf = pcall(pl.GetPivot, pl)
        return (ok and cf) and cf.Position or nil
    end
    local _stealable = function(a)
        -- DisplayName was missing from this check while every other ownership
        -- filter in the file tests both. On a server where the plot sign
        -- resolves to a display name, your OWN pets passed it -- so the priority
        -- walk could aim the teleport at your own base.
        return a and a.owner ~= LocalPlayer.Name and a.owner ~= LocalPlayer.DisplayName
            and not (_G.Skyr0IsMyPlotCached and _G.Skyr0IsMyPlotCached(a.plot))
    end

    -- ================================================================
    --  1.5) THE PRIORITY LIST, FIRST, IN EVERY MODE.
    --
    --  Gating this on `_mode == "Priority"` was wrong. The list is not one of
    --  the modes -- it is the user's explicit "take THESE, in THIS order", and
    --  the mode only answers what to do when none of them are on the server.
    --  With the gate, a saved StealMode of "Highest" (one click on the Steal
    --  panel, ever) killed the list silently and for good.
    --
    --  NO MIN-GEN APPLIES HERE. Not Min Gen for Auto TP, not Min Gen for
    --  Nearest Grab, not the 10M brainrot baseline the section below uses.
    --  A pet on your list is a target at any earnings -- that is the whole
    --  point of putting it on the list. The floors below only ever apply to
    --  pets you did NOT ask for by name.
    --
    --  Topmost entry present wins outright, whatever its gen or distance. Ties
    --  inside ONE entry go to the biggest earner, then the nearest base
    --  (_G.Skyr0PickPriority is the exact same tie-break _pickByMode uses).
    -- ================================================================
    if _G.Skyr0PickPriority then
        local bestPet = _G.Skyr0PickPriority(
            cache,
            function(a) return a.genValue or 0 end,
            _plotPos,
            _stealable,
            _myHrp and _myHrp.Position or nil)
        if bestPet then
            return bestPet
        end
    end

    -- 1.6) Nearest mode. There was NO nearest branch here at all, so choosing
    -- "Nearest" still locked the highest earner into the teleport while the
    -- steal engine (which does implement Nearest) armed something else.
    -- Measured base-to-base, the same way _pickByMode measures it.
    if _mode == "Nearest" and _myHrp then
        -- Min-Gen-for-Grab is honoured (the box that belongs to this mode), but
        -- NOT the 10M brainrot baseline the section below imposes -- "nearest"
        -- means nearest, and an empty box means no floor at all.
        local _nearFloor = parseMinGen(Config.TpSettings.MinGenForGrab) or 0
        local bestNear, bestNearDist = nil, math.huge
        for _, a in ipairs(cache) do
            if _stealable(a) and (a.genValue or 0) >= _nearFloor then
                local pos = _plotPos(a)
                if pos then
                    local d = (_myHrp.Position - pos).Magnitude
                    if d < bestNearDist then bestNearDist, bestNear = d, a end
                end
            end
        end
        if bestNear then return bestNear end
    end

    -- 1.7) Auto TP Highest Value (sorted by pet VALUE, not gen).
    --
    -- Moved ABOVE the brainrot section. It sat below it, and the brainrot
    -- section returns on any pet over 10M/s -- which is nearly always true on a
    -- live server -- so the value ordering was unreachable in practice and
    -- "Highest Value" behaved identically to "Highest Gen".
    -- get_all_pets_by_value applies the min-gen filter itself.
    if Config.AutoTPHighestValue then
        local valuePets = get_all_pets_by_value()
        if valuePets and #valuePets > 0 then
            return valuePets[1].animalData
        end
    end

    -- 2) Brainrots Second (target brainrots after priority)
    -- Respect Min-Gen-for-TP here too. Without this, brainrots BELOW the configured
    -- min gen (but still over the 10M "is-a-brainrot" baseline) got teleported to
    -- even though the list/scan correctly excluded them. Priority pets above are
    -- intentionally exempt from min gen; this non-priority section is not.
    -- keyed off the RESOLVED mode, not Config.StealNearest: that flag is only
    -- written by setStealMode, so the Auto-TP tab could put you in a mode this
    -- line could not see and the wrong min-gen box was applied.
    local _mgStr = (_mode == "Nearest" and Config.TpSettings.MinGenForGrab) or Config.TpSettings.MinGenForTp
    local _brainrotFloor = math.max(10000000, parseMinGen(_mgStr) or 0)
    local bestBrainrot = nil
    local bestBrainrotDist = math.huge
    for _, a in ipairs(cache) do
        -- _stealable, not a bare owner-name compare: this branch was missing the
        -- DisplayName half of the check that the rest of the file does.
        if _stealable(a) and a.genValue and a.genValue >= _brainrotFloor then
            local dist = math.huge
            if _myHrp then
                local pos = _plotPos(a)
                if pos then dist = (_myHrp.Position - pos).Magnitude end
            end
            -- HIGHEST VALUE FIRST, distance only as the tie-break.
            --
            -- This used to keep the NEAREST brainrot over the floor, which is
            -- why it flew to whatever cheap thing sat on the closest base --
            -- the red-carpet pet two plots over instead of the big one across
            -- the map. Distance still decides between equals.
            local _bestGen = bestBrainrot and (bestBrainrot.genValue or 0) or -1
            local _thisGen = a.genValue or 0
            if _thisGen > _bestGen or (_thisGen == _bestGen and dist < bestBrainrotDist) then
                bestBrainrotDist = dist
                bestBrainrot = a
            end
        end
    end
    if bestBrainrot then return bestBrainrot end

    -- 3) Nothing above matched: the biggest earner, which is what _pickByMode
    -- falls back to as well. get_all_pets is gen-sorted, so pets[1] is it.
    -- This used to be gated on Config.AutoTPHighestGen / AutoTPPriority --
    -- neither of which is set when the mode came from the Steal panel -- so a
    -- Highest/Nearest user with an empty result fell all the way through to the
    -- Steal Target panel's own selection, a fourth picker again.
    -- Built HERE, not at the top of the function -- this is its only reader.
    local pets = get_all_pets()
    if pets and #pets > 0 then
        return pets[1].animalData
    end

    -- 4) General Selected Pet
    if SharedState.SelectedPetData then
        return SharedState.SelectedPetData.animalData
    end

    return nil
end
-- Exposed so the grapple cycle aims the hook at the SAME base this picks. The
-- cycle lives much earlier in the file and cannot see this local, so it reads
-- the global at call time and falls back to its own cache scan if it is unset.
_G.Skyr0GetTargetPetData = getTargetPetData

local doGrabbleVelocityTP
do
local UPPER = {
    B = {{coord=Vector3.new(-487.921448,16.850713,-75.768013),facing="NORTH"},{coord=Vector3.new(-332.379730,16.850722,-75.762100),facing="NORTH"},{coord=Vector3.new(-487.134918,16.850713,-18.094154),facing="SOUTH"},{coord=Vector3.new(-316.300171,16.850713,-17.845898),facing="SOUTH"}},
    C = {{coord=Vector3.new(-330.765381,16.850713,31.424425),facing="NORTH"},{coord=Vector3.new(-502.989349,16.850713,31.172430),facing="NORTH"},{coord=Vector3.new(-489.077087,16.850713,89.010147),facing="SOUTH"},{coord=Vector3.new(-330.908936,16.850713,88.930145),facing="SOUTH"}},
    D = {{coord=Vector3.new(-331.264893,16.850713,138.209167),facing="NORTH"},{coord=Vector3.new(-487.935181,16.850713,138.026321),facing="NORTH"},{coord=Vector3.new(-487.774933,16.850713,195.882538),facing="SOUTH"},{coord=Vector3.new(-330.799133,16.850575,196.022354),facing="SOUTH"}},
}
local LOWER = {
    B = {{coord=Vector3.new(-335.725586,-3.048217,-74.984589),facing="NORTH"},{coord=Vector3.new(-503.214233,-3.048217,-75.043137),facing="NORTH"},{coord=Vector3.new(-483.619385,-3.718430,-18.844337),facing="SOUTH"},{coord=Vector3.new(-316.147095,-3.048218,-18.818844),facing="SOUTH"}},
    C = {{coord=Vector3.new(-335.985413,-3.048218,32.051426),facing="NORTH"},{coord=Vector3.new(-503.277008,-3.048217,31.956175),facing="NORTH"},{coord=Vector3.new(-483.749390,-3.048218,88.147003),facing="SOUTH"},{coord=Vector3.new(-315.793823,-3.048217,88.163979),facing="SOUTH"}},
    D = {{coord=Vector3.new(-335.476654,-3.048218,139.001083),facing="NORTH"},{coord=Vector3.new(-503.710083,-3.048218,138.989883),facing="NORTH"},{coord=Vector3.new(-315.654938,-3.048218,195.302444),facing="SOUTH"},{coord=Vector3.new(-483.859253,-3.048218,195.269043),facing="SOUTH"}},
}
local UPPER_Y_THRESHOLD = 7
local TALL_PETS = { ["La Secret Combinasion"]=true, ["La Jolly Grande"]=true }
local TALL_OFFSET = 3

local CARPET_SPEED = 230
local INBASE_SPEED = 230
local SKY_CLONE_WAIT = 0.2
local CARPET_NAMES = { "Flying Carpet", "Carpet", "Cloud", "Witch's Broom", "Cupid's Wings", "Santa's Sleigh", "Magic Carpet", "Waverider" }
local GRAPPLE_NAMES = { "Grapple Hook", "Grappling Hook", "Grapple", "Hook", "Web Slinger", "Grapple Gun", "GrappleHook" }

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local RS         = game:GetService("ReplicatedStorage")
local LP         = Players.LocalPlayer

_G.AntiDieDisabled = false
do
    local _conn, _diedConn, _hbConn
    local _harden = function(hum)
        pcall(function() hum.BreakJointsOnDeath = false end)
        pcall(function() hum.RequiresNeck = false end)
        pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false) end)
        pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false) end)
        pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false) end)
        pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false) end)
    end
    local function _revive(hum)
        pcall(function() hum.Health = hum.MaxHealth end)
        pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
    end
    local function _bind()
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        _harden(hum)
        if _conn then pcall(function() _conn:Disconnect() end) end
        if _diedConn then pcall(function() _diedConn:Disconnect() end) end
        if _hbConn then pcall(function() _hbConn:Disconnect() end) end
        _conn = hum:GetPropertyChangedSignal("Health"):Connect(function()
            if _G.AntiDieDisabled then return end
            if hum.Health <= 0 then _revive(hum) end
        end)
        _diedConn = hum.Died:Connect(function()
            if _G.AntiDieDisabled then return end
            _revive(hum)
        end)
        local _lastHarden = 0
        _hbConn = RunService.Heartbeat:Connect(function()
            if _G.AntiDieDisabled or not hum or not hum.Parent then return end
            local now = os.clock()
            if now - _lastHarden >= 0.5 then _lastHarden = now; _harden(hum) end
            if hum.Health <= 0 then _revive(hum) end
            local state = hum:GetState()
            if state == Enum.HumanoidStateType.Dead or state == Enum.HumanoidStateType.Ragdoll
               or state == Enum.HumanoidStateType.FallingDown then
                pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
            end
        end)
    end
    _bind()
    LP.CharacterAdded:Connect(function(char)
        local hum = char:WaitForChild("Humanoid", 5)
        if hum then _harden(hum) end
        task.wait(0.1)
        _bind()
    end)
end

-- =====================================================================
-- Module loaders
-- =====================================================================
local Synchronizer, AnimalsData, AnimalsShared, NumberUtils

local function loadModules()
    if Synchronizer then return true end
    local ok = pcall(function()
        local Packages = RS:WaitForChild("Packages", 5)
        local Datas = RS:WaitForChild("Datas", 5)
        local Shared = RS:WaitForChild("Shared", 5)
        local Utils = RS:WaitForChild("Utils", 5)
        Synchronizer = require(Packages:WaitForChild("Synchronizer"))
        AnimalsData = require(Datas:WaitForChild("Animals"))
        AnimalsShared = _G._xenAnimShim
        NumberUtils = require(Utils:WaitForChild("NumberUtils"))
    end)
    return ok and Synchronizer ~= nil
end

local NetModule
local function loadNet()
    if NetModule then return true end
    local ok, mod = pcall(function()
        return _G.Net
    end)
    if not ok or type(mod) ~= "table" then return false end
    NetModule = mod
    return true
end

local function findTool(name)
    local char = LP.Character
    local bp = LP:FindFirstChild("Backpack")
    return (char and char:FindFirstChild(name)) or (bp and bp:FindFirstChild(name))
end

local function findGrapple()
    for _, n in ipairs(GRAPPLE_NAMES) do
        local t = findTool(n)
        if t and t:IsA("Tool") then return t, n end
    end
    return nil
end

local function equipCarpet()
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return nil end
    local preferred = Config and Config.TpSettings and Config.TpSettings.Tool
    if preferred then
        local pt = findTool(preferred)
        if pt and pt:IsA("Tool") then
            if pt.Parent ~= char then pcall(function() hum:EquipTool(pt) end) end
            return preferred
        end
    end
    for _, n in ipairs(CARPET_NAMES) do
        local t = findTool(n)
        if t and t:IsA("Tool") then
            if t.Parent ~= char then pcall(function() hum:EquipTool(t) end) end
            return n
        end
    end
    return nil
end

local function fireGrapple()
    if not NetModule then loadNet() end
    if not NetModule then return end
    local char = LP.Character
    if not char then return end
    if not char:FindFirstChild("Grapple Hook") then
        local bp = LP:FindFirstChild("Backpack")
        local tool = bp and bp:FindFirstChild("Grapple Hook")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if tool and hum then pcall(function() hum:EquipTool(tool) end) end
    end
    if not char:FindFirstChild("Grapple Hook") then return end
    -- Fire via the TOOL: Skyr0FireGrapple2 writes the aim into the live
    -- PlayerMouse tables and drives Activated. No remote is fired.
    if _G.Skyr0FireGrapple2 then pcall(_G.Skyr0FireGrapple2) end
end

local function carpetEngage()
    if not NetModule then pcall(loadNet) end
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not char or not hum then return nil end
    local g = findTool("Grapple Hook")
    if g then
        if g.Parent ~= char then
            pcall(function() hum:EquipTool(g) end)
            task.wait(0.05) -- Let tool equip register
        end
        if _G.Skyr0FireGrapple2 then pcall(_G.Skyr0FireGrapple2) end
        task.wait(0.10) -- Let grapple projectile register and pull
    end
    pcall(function() hum:UnequipTools() end)
    task.wait(0.10) -- Wait before putting carpet on
    local cn = equipCarpet()
    _G.TPEngage = "carpet=" .. tostring(cn)
    return cn
end

-- =====================================================================
-- Pet priority data tables
-- =====================================================================
local PET_PRIORITY_TIERS = {
    [1] = { pets = {"Headless Horseman"}, threshold = 0 },
    [2] = { pets = {"Signore Carapace"}, threshold = 0 },
    [3] = { pets = {"John Pork"}, threshold = 0 },
    [4] = { pets = {"Strawberry Elephant"}, threshold = 0 },
    [5] = { pets = {"Arcadragon"}, threshold = 5e9 },
    [6] = { pets = {"Elefanto Frigo"}, threshold = 10e9 },
    [7] = { pets = {"Meowl"}, threshold = 5e9 },
    [8] = { pets = {"Skibidi Toilet"}, threshold = 5e9 },
    [9] = { pets = {"Love Love Bear"}, threshold = 0 },
    [10] = { pets = {"Antonio"}, threshold = 0 },
    [11] = { pets = {"Pancake and Syrup"}, threshold = 0 },
    [12] = { pets = {"Griffin"}, threshold = 0 },
    [13] = { pets = {"Globa Steppa","La Supreme Combinasion","Fishino Clownino","Dragon Gingerini","Tirilikalika Tirilikalako"}, threshold = 5e9 },
    [14] = { pets = {"Ginger Gerat","Pet"}, threshold = 10e9 },
    [15] = { pets = {"Hydra Bunny","Digi Narwhal","Kalika Bros"}, threshold = 3e9 },
    [16] = { pets = {"Hydra Dragon Cannelloni","Dragon Cannelloni","Bunny and Eggy"}, threshold = 3e9 },
    [17] = { pets = {"Ketupat Bros","Rosey and Teddy","La Casa Boo","Fragola la la"}, threshold = 3e9 },
    [18] = { pets = {"Fragola La La La","Cerberus","Guest 666","Los Hackers"}, threshold = 1e9 },
    [19] = { pets = {"Garama and Madundung","Spooky and Pumpky","Reinito Sleighito","Burguro And Fryuro","Cooki and Milki","Fragrama and Chocrama","La Food Combinasion","Los Amigos","Foxini Lanternini","Capitano Moby","Fortunu and Cashuru","Los Sekolahs","Celestial Pegasus"}, threshold = 750e6 },
    [20] = { pets = {"La Secret Combinasion","Sammyni Fattini","Cloverat Clapat","Popcuru and Fizzuru"}, threshold = 1e9 },
}

local TIER_LOOKUP = {}
for tier, data in pairs(PET_PRIORITY_TIERS) do
    for _, name in ipairs(data.pets) do TIER_LOOKUP[name] = tier end
end

local LOCKED_TIERS = { [1]=true, [2]=true, [3]=true, [4]=true }

local DIRECT_THRESHOLDS = {
    [3] = { [4] = 10e9 },
    [4] = {},
    [5] = { [6] = math.huge },
    [6] = { [9] = math.huge, [10] = math.huge, [12] = 15e9 },
    [10] = { [12] = 20e9 },
    [11] = { [12] = 10e9 },
}

local MUTATION_PRIORITY = {
    ["Galaxy"]=1,["Candy"]=1,["Yin Yang"]=1,["YinYang"]=1,["Divine"]=1,
    ["Cursed"]=1,["Lava"]=1,["Radioactive"]=1,["Cyber"]=1,["Rainbow"]=1,["Bloodrot"]=2,
}

local MUTATED_BEATS_GRIFFIN = {
    ["Fishino Clownino"]=true,["Globa Steppa"]=true,
    ["La Supreme Combinasion"]=true,["Tirilikalika Tirilikalako"]=true,
}

local function getMutPrio(m)
    if not m or m == "" or m == "None" then return 0 end
    if MUTATION_PRIORITY[m] then return MUTATION_PRIORITY[m] end
    local n = tostring(m):lower():gsub("[%s%-_]","")
    if n == "bloodrot" then return 2 end
    if n == "yinyang" or n == "galaxy" or n == "candy" or n == "divine"
        or n == "cursed" or n == "lava" or n == "radioactive" or n == "cyber"
        or n == "rainbow" then return 1 end
    return 0
end

local function getCumThreshold(hi, lo)
    if DIRECT_THRESHOLDS[hi] and DIRECT_THRESHOLDS[hi][lo] then return DIRECT_THRESHOLDS[hi][lo] end
    if LOCKED_TIERS[hi] then return math.huge end
    local total = 0
    for t = hi + 1, lo do
        local td = PET_PRIORITY_TIERS[t]
        if td and td.threshold > 0 then total = total + td.threshold end
    end
    return total
end

local function petOutranks(aName, bName, aMut, bMut, aMPS, bMPS)
    if aName == "Strawberry Elephant" and bName == "John Pork" then return true end
    if aName == "John Pork" and bName == "Strawberry Elephant" then return false end

    if MUTATED_BEATS_GRIFFIN[aName] and bName == "Griffin" and getMutPrio(aMut) >= 1 then return true end
    if aName == "Griffin" and MUTATED_BEATS_GRIFFIN[bName] and getMutPrio(bMut) >= 1 then return false end

    if aName == "Antonio" and bName == "Elefanto Frigo" and getMutPrio(aMut) >= 1 then return true end
    if aName == "Elefanto Frigo" and bName == "Antonio" and getMutPrio(bMut) >= 1 then return false end

    local tA = TIER_LOOKUP[aName] or 99
    local tB = TIER_LOOKUP[bName] or 99

    if not (TIER_LOOKUP[aName] and TIER_LOOKUP[bName]) then
        if tA == tB then return (aMPS or 0) > (bMPS or 0) end
        return tA < tB
    end

    if tA == tB then
        local pA, pB = getMutPrio(aMut), getMutPrio(bMut)
        if pA ~= pB then return pA > pB end
        return (aMPS or 0) > (bMPS or 0)
    end

    if tA == 4 and tB == 3 then return true end
    if tA == 3 and tB == 4 then return false end

    local hi = math.min(tA, tB)
    local lo = math.max(tA, tB)
    local hiMPS = tA < tB and aMPS or bMPS
    local loMPS = tA < tB and bMPS or aMPS
    local cum = getCumThreshold(hi, lo)
    if cum > 0 and cum ~= math.huge then
        if (loMPS or 0) - (hiMPS or 0) > cum then return tA > tB end
    end
    return tA < tB
end

-- =====================================================================
-- Plot / channel helpers
-- =====================================================================
local function getPlotChannel(plotName)
    if not Synchronizer then return nil end
    local channel
    pcall(function() channel = _G.Skyr0_GetPlotChannel(plotName) end)
    -- NO BLOCKING RETRY HERE. This used to be:
    --     repeat channel=_G.XenSyncGet(plotName) ... task.wait(0.05)
    --     until os.clock()-_t0>3
    --
    -- i.e. up to THREE SECONDS of spinning, PER PLOT, inside the scan loop.
    -- On a server where the channels never register (the scan line reports
    -- sync=0), every plot paid the full three seconds and nothing was ever
    -- found: eight plots = a 24-SECOND teleport, which is exactly what the
    -- timing trace showed. isPlotUnlocked calls this too, which was the
    -- separate ~3s gap before carpetEngage.
    --
    -- The retry was also redundant: XenSyncGet -> _chans() ALREADY retries on
    -- its own rate-limited schedule (with the bounded deep scan), without
    -- yielding. Calling it once per scan gives exactly the same recovery over
    -- time, because the scanners run continuously.
    --
    -- And a missing channel is no longer fatal: the plot scanner falls back to
    -- rendered Models, and the TP scanners fall back to Skyr0CachedSlotsForPlot.
    if not channel then channel = _G.XenSyncGet and _G.XenSyncGet(plotName) or nil end
    return channel
end

local function channelGet(channel, key)
    return _G.sProp(channel, key)
end

local function isMyPlot(channel)
    if not channel then return false end
    local owner = channelGet(channel, "Owner")
    if not owner then return false end
    local result = false
    pcall(function()
        if typeof(owner) == "Instance" and owner:IsA("Player") then
            result = owner.UserId == LP.UserId
        elseif type(owner) == "table" and owner.UserId then
            result = owner.UserId == LP.UserId
        elseif typeof(owner) == "Instance" then
            result = owner == LP
        elseif type(owner) == "string" then
            result = (owner:lower() == LP.Name:lower() or owner:lower() == LP.DisplayName:lower())
        elseif type(owner) == "number" then
            result = owner == LP.UserId
        end
    end)
    return result
end

local function ownerInGame(channel)
    if not channel then return false end
    local owner = channelGet(channel, "Owner")
    if not owner then return false end
    local inGame = false
    pcall(function()
        if typeof(owner) == "Instance" and owner:IsA("Player") then
            inGame = Players:FindFirstChild(owner.Name) ~= nil
        elseif type(owner) == "number" then
            inGame = Players:GetPlayerByUserId(owner) ~= nil
        elseif type(owner) == "table" and owner.Name then
            inGame = Players:FindFirstChild(tostring(owner.Name)) ~= nil
        elseif type(owner) == "string" then
            inGame = Players:FindFirstChild(owner) ~= nil
        elseif typeof(owner) == "Instance" and owner.Name then
            inGame = Players:FindFirstChild(owner.Name) ~= nil
        end
    end)
    return inGame
end

local function getStealPromptForSlot(plot, slot)
    local podiums = plot and plot:FindFirstChild("AnimalPodiums")
    local podium = podiums and podiums:FindFirstChild(tostring(slot))
    local base = podium and podium:FindFirstChild("Base")
    local spawnp = base and base:FindFirstChild("Spawn")
    local att = spawnp and spawnp:FindFirstChild("PromptAttachment")
    local prompt = att and att:FindFirstChildWhichIsA("ProximityPrompt")
    if prompt and (prompt.ActionText:lower():find("steal") or prompt.ActionText == "") then return prompt end
    return nil
end

local _BLOCKING_MACHINE_TYPES = {
    Fuse     = true,
    Duel     = true,
    Trade    = true,
    Crafting = true,
}
local function _CartisIsFusing(animalData)
    if type(animalData) ~= "table" then return false end
    local m = animalData.Machine
    if type(m) ~= "table" then return false end
    return _BLOCKING_MACHINE_TYPES[m.Type] == true
end

local function scanAllPets()
    local pets = {}
    if not loadModules() then return pets end

    local Plots = Workspace:FindFirstChild("Plots")
    if not Plots then return pets end

    for _, plot in ipairs(Plots:GetChildren()) do
        local channel = getPlotChannel(plot.Name)
        -- "no channel" is not a reason to skip a base (see the plot scanner):
        -- on servers that key channels as PlotN the by-name lookup misses all
        -- of them. isMyPlot still applies when there IS a channel to ask.
        -- YOUR OWN BASE, ALWAYS. The channel test only runs when there IS a
        -- channel, and on servers that key channels as PlotN there never is --
        -- which is exactly how your own brainrots ended up as TP targets. The
        -- instant check reads the PlotSign / YourBase billboard instead, so it
        -- answers with or without a channel.
        if (channel and isMyPlot(channel))
            or (_G.Skyr0IsMyPlotCached and _G.Skyr0IsMyPlotCached(plot.Name)) then continue end

        -- SERVER FIRST. channelGet reads the client cache, which is empty for
        -- any base that has not streamed in -- those plots scanned as empty.
        -- Skyr0GetAnimalList asks the server via Synchronizer.RequestData and
        -- falls back to the same client cache when RequestData is absent.
        local animalList = (_G.Skyr0GetAnimalList and _G.Skyr0GetAnimalList(plot.Name, channel))
                        or channelGet(channel, "AnimalList")
                        or (_G.Skyr0CachedSlotsForPlot and _G.Skyr0CachedSlotsForPlot(plot.Name))
        if not animalList then continue end

        for slot, animalData in pairs(animalList) do
            if type(animalData) ~= "table" then continue end
            local animalName = animalData.Index
            if not animalName then continue end
            local animalInfo = AnimalsData and AnimalsData[animalName]
            if not animalInfo then continue end
            if _CartisIsFusing(animalData) then continue end

            local mutation = animalData.Mutation or "None"
            local genValue = 0
            pcall(function()
                genValue = AnimalsShared:GetGeneration(animalName, animalData.Mutation,
                    (_G.Skyr0NormTraits and _G.Skyr0NormTraits(animalData.Traits) or animalData.Traits), nil)
            end)

            local displayName = (animalInfo and animalInfo.DisplayName) or animalName
            local pos = getPetPosition(plot, slot)

            if pos then
                table.insert(pets, {
                    name = displayName,
                    mps = genValue,
                    mutation = mutation,
                    position = pos,
                    plot = plot.Name,
                    slot = tostring(slot),
                    prompt = getStealPromptForSlot(plot, slot),
                })
            end
        end
    end

    table.sort(pets, function(a, b)
        return petOutranks(a.name, b.name, a.mutation, b.mutation, a.mps, b.mps)
    end)

    return pets
end

local function findClosest(petPos, coordTable, fromPos)
    local all = {}
    for skyKey, coords in pairs(coordTable) do
        for _, data in ipairs(coords) do
            local c = data.coord
            local d = (petPos.X - c.X)^2 + (petPos.Z - c.Z)^2
            all[#all + 1] = { data = data, key = skyKey, petD = d }
        end
    end
    table.sort(all, function(a, b) return a.petD < b.petD end)
    if #all == 0 then return nil, nil end
    if not fromPos then return all[1].data, all[1].key end

    local cands = { all[1] }
    if all[2] and math.abs(all[2].data.coord.X - all[1].data.coord.X) < 40 then
        cands[#cands + 1] = all[2]
    end
    local best, bestKey, bestDist = all[1].data, all[1].key, math.huge
    for _, e in ipairs(cands) do
        local c = e.data.coord
        local d = (fromPos.X - c.X)^2 + (fromPos.Z - c.Z)^2
        if d < bestDist then bestDist = d; best = e.data; bestKey = e.key end
    end
    return best, bestKey
end

-- =====================================================================
-- Path visualization helpers
-- =====================================================================
local _vizParts = {}
local function clearViz()
    for _, p in ipairs(_vizParts) do if p and p.Parent then p:Destroy() end end
    table.clear(_vizParts)
end
local function vizPath(fromPos, waypoints)
    -- Pathfinder lines/dots disabled (user request: no lines).
    return
end

local isGrabbleTeleporting = false
local isTeleporting = false


local SPEED = 200
local ARRIVE = 3

local function vZero(hrp)
    if hrp then hrp.AssemblyLinearVelocity = Vector3.zero; hrp.AssemblyAngularVelocity = Vector3.zero end
end

local MAX_CLIMB = 60

local function velMoveThrough(hrp, waypoints, speedOverride, allowJump, quickStart)
    if not hrp or not hrp.Parent or #waypoints == 0 then return end
    local _runSpeed = speedOverride or Config.TpSettings.GrabbleTPSpeed or (_G.Skyr0CarpetSpeed or CARPET_SPEED or 230)
    vizPath(hrp.Position, waypoints)
    local wpIdx = 1
    local done = false
    local conn
    local function finish()
        if done then return end
        done = true
        if hrp and hrp.Parent then
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            local _, y = hrp.CFrame:ToEulerAnglesYXZ()
            hrp.CFrame = CFrame.new(waypoints[#waypoints]) * CFrame.Angles(0, y, 0)
        end
        if conn then conn:Disconnect() end
        clearViz()
    end
    local lastDist, stall = math.huge, 0

    if quickStart then
        local _hp = RaycastParams.new()
        _hp.FilterType = Enum.RaycastFilterType.Exclude
        _hp.IgnoreWater = true
        local _skip = {}
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl.Character then _skip[#_skip + 1] = pl.Character end
        end
        _hp.FilterDescendantsInstances = _skip
        for _ = 1, 3 do
            local target = waypoints[wpIdx]
            if not target then break end
            local flat = Vector3.new(target.X - hrp.Position.X, 0, target.Z - hrp.Position.Z)
            local mag = flat.Magnitude
            if mag < 1 then break end
            local nextPos = hrp.Position + flat.Unit * math.min(20, mag)
            local _hit = Workspace:Raycast(hrp.Position, nextPos - hrp.Position, _hp)
            if _hit and _hit.Instance and _hit.Instance.CanCollide then break end
            hrp.CFrame = (hrp.CFrame - hrp.CFrame.Position) + nextPos
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            RunService.Heartbeat:Wait()
            if not hrp or not hrp.Parent then return end
        end
    end

    conn = RunService.Heartbeat:Connect(function()
        if not hrp or not hrp.Parent or done then
            if conn then conn:Disconnect() end
            return
        end
        equipCarpet()
        local target = waypoints[wpIdx]
        local diff = target - hrp.Position
        local mag = diff.Magnitude
        if mag < ARRIVE then
            wpIdx = wpIdx + 1
            if wpIdx > #waypoints then finish() return end
            lastDist, stall = math.huge, 0
            target = waypoints[wpIdx]
            diff = target - hrp.Position
            mag = diff.Magnitude
        end
        if mag > lastDist - 0.05 then stall = stall + 1 else stall = 0 end
        lastDist = mag
        if stall >= 18 then finish() return end
        if mag >= 0.1 then
            local dir = diff.Unit
            if allowJump and diff.Y > 5 and wpIdx < #waypoints then
                local hum = hrp.Parent and hrp.Parent:FindFirstChildOfClass("Humanoid")
                if hum then
                    local st = hum:GetState()
                    if st ~= Enum.HumanoidStateType.Jumping and st ~= Enum.HumanoidStateType.Freefall then
                        pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end)
                        pcall(function() hum.Jump = true end)
                    end
                end
            end
            local _sp = _runSpeed
            local _vy = dir.Y * _sp
            if _vy > MAX_CLIMB then _vy = MAX_CLIMB end
            hrp.Velocity = Vector3.new(dir.X * _sp, _vy, dir.Z * _sp)
        end
    end)
    local totalDist = 0
    local prev = hrp.Position
    for _, wp in ipairs(waypoints) do
        totalDist = totalDist + (prev - wp).Magnitude
        prev = wp
    end
    local timeout = totalDist / math.min(SPEED, _runSpeed) + 2
    local elapsed = 0
    while not done and elapsed < timeout do
        task.wait(0.05)
        elapsed = elapsed + 0.05
    end
    finish()
    vZero(hrp)
end



-- =====================================================================
-- Raycast / route-pulling helpers
-- =====================================================================
local _DIRS = { Vector3.new(1,0,0), Vector3.new(-1,0,0), Vector3.new(0,0,1), Vector3.new(0,0,-1) }
local _STRUCT = { ["structure base home"] = true, ["Wall"] = true, ["Floor"] = true, ["Roof"] = true }
local _SKIP_NAME = { ["DeliveryHitbox"]=true, ["StealHitbox"]=true, ["LaserHitbox"]=true,
    ["AnimalTarget"]=true, ["Multiplier"]=true, ["Laser"]=true, ["Hitbox"]=true,
    ["Spawn"]=true, ["MainRoot"]=true, ["SecondFloor"]=true, ["ThirdFloor"]=true, ["Slope"]=true }

function _blocks(inst)
    if not inst then return false end
    if _SKIP_NAME[inst.Name] then return false end
    if inst.CanCollide then return true end
    if _STRUCT[inst.Name] then return true end
    local s = inst.Size
    if s and math.max(s.X * s.Y, s.X * s.Z, s.Y * s.Z) > 150 then return true end
    return false
end

-- Same shape as the TP engine's own _block further down, and fixed the same
-- way: one reusable RaycastParams, a cached player-skip list, and AddToFilter
-- instead of reassigning (and revalidating) the filter array on every bounce.
-- This copy feeds runAutoSnipe's route, the fallback teleport engine.
local _rpG = RaycastParams.new()
_rpG.FilterType = Enum.RaycastFilterType.Exclude
_rpG.IgnoreWater = true
local _charSkipG, _charSkipAtG = {}, 0
local function _charListG()
    if _charSkipAtG ~= 0 and (os.clock() - _charSkipAtG) < 1 then return _charSkipG end
    local t = {}
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl.Character then t[#t + 1] = pl.Character end
    end
    _charSkipG, _charSkipAtG = t, os.clock()
    return t
end
local _hasAddToFilterG = pcall(function() return RaycastParams.new().AddToFilter end)
function _block(origin, target)
    local skip = _charListG()
    _rpG.FilterDescendantsInstances = skip   -- resets whatever the last call appended
    local grown = nil
    local o = origin
    for _ = 1, 16 do
        local d = target - o
        if d.Magnitude < 0.05 then return nil end
        local res = Workspace:Raycast(o, d, _rpG)
        if not res then return nil end
        if _blocks(res.Instance) then return res end
        if _hasAddToFilterG then
            _rpG:AddToFilter(res.Instance)
        else
            if not grown then
                grown = table.create and table.create(#skip + 4) or {}
                table.move(skip, 1, #skip, 1, grown)
            end
            grown[#grown + 1] = res.Instance
            _rpG.FilterDescendantsInstances = grown
        end
        o = res.Position + d.Unit * 0.3
    end
    return nil
end

function _clear(a, b) return _block(a, b) == nil end

function _clearDist(origin, dir, maxD)
    local res = _block(origin, origin + dir.Unit * maxD)
    if not res then return maxD end
    return (res.Position - origin).Magnitude
end


function _pull(pts)
    if #pts <= 2 then return pts end
    local out = { pts[1] }
    local i = 1
    while i < #pts do
        local j = #pts
        while j > i + 1 and not _clear(out[#out], pts[j]) do j = j - 1 end
        out[#out + 1] = pts[j]
        i = j
    end
    return out
end






local PathfindingService = game:GetService("PathfindingService")
local _CLEARANCE = 6

local function _clearWide(a, b)
    if not _clear(a, b) then return false end
    local d = Vector3.new(b.X - a.X, 0, b.Z - a.Z)
    if d.Magnitude < 0.1 then return true end
    local p = Vector3.new(-d.Z, 0, d.X).Unit * _CLEARANCE
    return _clear(a + p, b + p) and _clear(a - p, b - p)
end

-- Bounded, for the same reason as the TP engine's copy: the unbounded backward
-- scan is O(N^2) over _clearWide, which is three _blocks of up to 16 raycasts
-- each, all in one frame. Lookahead cap plus a shared deadline; both degrade
-- into "a route with more corners", never into a wrong route.
local _PULL_LOOKAHEAD_G = 6
local function _pullWide(pts, deadline)
    if #pts <= 2 then return pts end
    local out = { pts[1] }
    local i = 1
    while i < #pts do
        if deadline and os.clock() > deadline then
            for k = i + 1, #pts do out[#out + 1] = pts[k] end
            return out
        end
        local j = math.min(#pts, i + _PULL_LOOKAHEAD_G)
        while j > i + 1 and not _clearWide(out[#out], pts[j]) do j = j - 1 end
        out[#out + 1] = pts[j]
        i = j
    end
    return out
end

function computeRoute(fromPos, toPos, facingDir)
    if _clear(fromPos, toPos) then return { toPos } end
    local entry = facingDir and (toPos - facingDir * 14) or toPos
    local groundTo = Vector3.new(entry.X, fromPos.Y, entry.Z)
    local path = PathfindingService:CreatePath({
        AgentRadius = 8, AgentHeight = 5, AgentCanJump = true, AgentJumpHeight = 10, AgentMaxSlope = 89,
    })
    local FLOAT = 3
    local nav = { fromPos }
    local ok = pcall(function()
        path:ComputeAsync(Vector3.new(fromPos.X, fromPos.Y, fromPos.Z), groundTo)
    end)
    if ok and path.Status == Enum.PathStatus.Success then
        local last = fromPos
        for _, wp in ipairs(path:GetWaypoints()) do
            if (wp.Position - last).Magnitude >= 8 then
                nav[#nav + 1] = wp.Position + Vector3.new(0, FLOAT, 0)
                last = wp.Position
            end
        end
    end
    nav[#nav + 1] = entry + Vector3.new(0, FLOAT, 0)
    -- shared budget, same as the TP engine's computeRoute
    local route = _pullWide(nav, os.clock() + (tonumber(_G.Skyr0RouteBudget) or 0.03))
    route[#route + 1] = toPos
    return route
end

-- =====================================================================
-- Tool & Clone Helpers
-- =====================================================================

function getPetPosition(plot, slot)
    local podiums = plot:FindFirstChild("AnimalPodiums")
    if not podiums then return nil end
    local podium = podiums:FindFirstChild(tostring(slot))
    if not podium then return nil end

    for _, desc in ipairs(podium:GetDescendants()) do
        if desc:IsA("Model") and desc.Name ~= "Claim" and desc.Name ~= "Base" and desc.Name ~= "Decorations" then
            local hasMesh = false
            for _, c in ipairs(desc:GetDescendants()) do
                if c:IsA("MeshPart") then hasMesh = true; break end
            end
            if hasMesh then
                local ok, cf = pcall(function() return desc:GetBoundingBox() end)
                if ok then return cf.Position end
            end
        end
    end

    local ok, cf = pcall(function() return podium:GetPivot() end)
    if ok then return cf.Position end
    return podium.Position
end

end

local cloneref = cloneref or function(o) return o end
local getinfo = debug.getinfo or getinfo
local lp = cloneref(game:GetService("Players")).LocalPlayer

local function Strip()
    local char = lp.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if not getconnections or not getinfo then return end
    for _, sig in ipairs({"CFrame", "Position"}) do
        local signal = hrp:GetPropertyChangedSignal(sig)
        if signal then
            for _, c in ipairs(getconnections(signal)) do
                local f = c.Function
                if f and c.Enabled and getinfo(f) and getinfo(f).source == "=ReplicatedFirst.test" then
                    pcall(function() c:Disable() end)
                end
            end
        end
    end
end

-- Strip walks getconnections() on two signals and calls debug.getinfo on every
-- connection it finds. Both are executor calls and neither is free, and this ran
-- at 2Hz for the entire session -- but the connections it disables only ever
-- APPEAR when the character respawns and ReplicatedFirst.test re-hooks the new
-- root. So: a burst right after each spawn, then a slow idle heartbeat.
task.spawn(function()
    local function burst()
        for _ = 1, 20 do          -- ~10s at 0.5s, covering the respawn re-hook
            pcall(Strip)
            task.wait(0.5)
        end
    end
    burst()
    pcall(function()
        lp.CharacterAdded:Connect(function() task.spawn(burst) end)
    end)
    while true do
        task.wait(5)
        pcall(Strip)
    end
end)

-- Is a TP actually in flight right now? _G._isTpMoving holds the os.clock() of
-- the run that owns the lock; anything older than the ceiling is a leaked lock
-- from a run that died and must not keep blocking. Every reader goes through
-- here so one stale value cannot silently disable TP-adjacent features too.
_G.Skyr0IsTpBusy = function(maxAge)
    local m = _G._isTpMoving
    if not m then return false end
    if type(m) ~= "number" then return true end
    return (os.clock() - m) < (tonumber(maxAge) or 45)
end

-- Manual escape hatch: drops every TP lock and cancel flag at once. The engine
-- reclaims stale locks on its own now, but this makes it instant.
_G.Skyr0TPReset = function()
    _G._isTpMoving = false
    _G.Skyr0TPCancel = false
    _G.__Skyr0CicloRodando = nil
    _G.__Skyr0GrappleWarned = nil
    _G.RecoveryInProgress = false
    _G.isCloning = false
    if _G.Skyr0ForceIdleTP then pcall(_G.Skyr0ForceIdleTP) end
    local c = LocalPlayer and LocalPlayer.Character
    local h = c and c:FindFirstChild("HumanoidRootPart")
    if h then pcall(function() h.Anchored = false end) end
    return true
end

function runAutoSnipe()
    pcall(Strip)
    -- STALE-GUARD (this is what made the TP fire exactly ONCE per server).
    --
    -- _G._isTpMoving is a plain boolean that lives in _G, so it survives script
    -- re-execution AND every respawn. Anything that stopped the TP mid-flight
    -- without unwinding -- a character rebuild during the clone swap, a yield
    -- that never returned, a re-exec while a TP was in progress -- left it
    -- stuck true forever, and from then on every press returned here silently.
    --
    -- It is now a TIMESTAMP: still a hard mutex for a run in progress, but any
    -- run older than the ceiling is treated as dead and reclaimed.
    local moving = _G._isTpMoving
    if moving then
        local since = (type(moving) == "number") and (os.clock() - moving) or math.huge
        if since < 45 then return true end
        warn(("[skyr0] clearing a stuck TP lock (%s) -- previous run never finished")
            :format(type(moving) == "number" and ("%.0fs old"):format(since) or "no timestamp"))
    end
    -- Cancel is sticky too: a cancelled TP left Skyr0TPCancel true, and every
    -- later run bailed at its first checkpoint. Clear it on entry.
    _G.Skyr0TPCancel = false
    -- Bypass removed: it called _G.Skyr0StartSideTP, which IS the dispatcher
    -- that calls this function, so leaving it in loops the two forever.
    if CarpetState and CarpetState.enabled then
        setCarpetSpeed(false)
    end
    local targetPetData = getTargetPetData()
    if not targetPetData then
        return false
    end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    if not hrp or not hum or (hum.Health <= 0) then
        return false
    end
    local lastFpsCap = pcall(getfpscap) and getfpscap() or 60
    pcall(setfpscap, 200)
    -- (Old Grabble TP branch removed - now handled by Skyr0 Clone-TP router above.)
    _G._isTpMoving = true
    local ok, err = pcall(function()
        local targetPart = findAdorneeGlobal(targetPetData)
        if not targetPart then
            error("targetPart nil")
        end
        local targetCF
        if targetPart:IsA("Attachment") then
            targetCF = targetPart.WorldCFrame
        elseif targetPart:IsA("BasePart") then
            targetCF = targetPart.CFrame
        else
            local okPivot, pivot = pcall(function()
                return targetPart:GetPivot()
            end)
            if okPivot then
                targetCF = pivot
            end
        end
        if not targetCF then
            error("targetCF nil")
        end
        local exactPos = targetPart.Position
        local carpetName = Config.TpSettings.Tool
        local carpet = LocalPlayer.Backpack:FindFirstChild(carpetName) or char:FindFirstChild(carpetName)
        local cloner = LocalPlayer.Backpack:FindFirstChild("Quantum Cloner") or char:FindFirstChild("Quantum Cloner")
        equipTpToolAndWait(hum)
        -- Treat every floor the same: rise to brainrot height outside, clone push
        -- through the wall at that height, platform under player during steal.
        -- isSecondFloor is kept for the rise height calculation only.
        local isSecondFloor = exactPos.Y > 10
        -- V3 F2 from F1: for 2nd-floor brainrots, approach from floor 1 (clone-push
        -- through the ground-floor wall, then platform up to brainrot from below).
        local f2FromF1 = Config.AutoTPFloor2FromFloor1 and isSecondFloor
        local isCloseBase = false

        local signPart = getClosestBaseSign(targetPart)
            if not signPart then
                error("signPart nil")
            end
            local signCF = signPart.CFrame
            local RIGHT = signCF.RightVector
            local LEFT = -RIGHT
            local FORWARD = signCF.LookVector
            local BACK = -signCF.LookVector
            local medPoint = getNearestTeleportV2MedPoint(hrp.Position)
            if not medPoint then
                error("normal tp MED point nil")
            end
            hrp.AssemblyLinearVelocity = Vector3.zero

            -- Pick the closer side of the base sign, always at ground level first
            local frontPoint = signPart.Position + (FORWARD * 20)
            local backPoint  = signPart.Position + (BACK * 20)
            local myFlat     = Vector3.new(hrp.Position.X, 0, hrp.Position.Z)
            local distFront  = (Vector3.new(frontPoint.X, 0, frontPoint.Z) - myFlat).Magnitude
            local distBack   = (Vector3.new(backPoint.X, 0, backPoint.Z) - myFlat).Magnitude
            local chosen     = (distFront < distBack) and frontPoint or backPoint
            local tpPos      = Vector3.new(chosen.X, -4.8, chosen.Z)

            local initialDist = (hrp.Position - tpPos).Magnitude
            isCloseBase = initialDist <= 100

            -- Step 1: move to the outside position at ground level
            -- YOUR GRAPPLE TP SLIDER, EXACTLY. Read from Config first: the
            -- dispatcher primes _G.TPVelocity as math.max(GrabbleTPSpeed, 400),
            -- so reading that instead silently ignores every setting below 400.
            -- Clamped to the slider's own 50-600 range.
            local _flySpd = math.clamp(
                tonumber(Config.TpSettings.GrabbleTPSpeed)
                    or tonumber(_G.TPVelocity)
                    or 230,
                50, 600)
            -- Fly whenever the base is not close: with FlyTP off (the default) a
            -- far target fell through to a bare CFrame snap across the map, which
            -- the server rejects -- the "only works up close" behaviour.
            if Config.TpSettings.FlyTP or not isCloseBase then
                flyForwardTo(hrp, tpPos, LEFT, nil, _flySpd)
            else
                if hum and hum.Parent then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
                task.wait(0.01)
                hrp.AssemblyLinearVelocity = Vector3.zero
                local targetCF = CFrame.lookAt(tpPos, tpPos + LEFT)
                if isCloseBase then
                    local startCF = hrp.CFrame
                    local duration = math.clamp(initialDist / _flySpd, 0.08, 0.6)
                    local start = tick()
                    while tick() - start < duration and hrp.Parent do
                        local t = (tick() - start) / duration
                        hrp.AssemblyLinearVelocity = Vector3.zero
                        hrp.AssemblyAngularVelocity = Vector3.zero
                        hrp.CFrame = startCF:Lerp(targetCF, t)
                        RunService.Heartbeat:Wait()
                    end
                end
                hrp.CFrame = targetCF
                hrp.AssemblyLinearVelocity = Vector3.zero
            end
            waitUntilHeartbeat(function()
                return hrp and hrp.Parent and (flatDistance(hrp.Position, tpPos) <= 5)
            end, 0.5)
            task.wait(0.05)

            -- Step 2: rise to brainrot height outside the wall.
            -- First floor rises to brainrot Y + 1 (enough to be level with it).
            -- Second floor rises to signPart.Y + 4 (same as before).
            -- F2 from F1: stay low at ground-floor wall height so we clone-push
            -- through the 1st-floor wall; the final positioning block then lifts
            -- us up to the 2nd-floor brainrot with a platform underneath.
            local riseTargetY
            if f2FromF1 then
                riseTargetY = signPart.Position.Y + 3
            elseif isSecondFloor then
                riseTargetY = signPart.Position.Y + 4
            else
                riseTargetY = exactPos.Y + 1
            end

            if hrp.Position.Y < (riseTargetY - 0.5) then
                local startY    = hrp.Position.Y
                local riseTime  = math.clamp(math.abs(riseTargetY - startY) / _flySpd, 0.12, 1.2)
                local elapsed   = 0
                while elapsed < riseTime and hrp.Parent do
                    elapsed = elapsed + RunService.Heartbeat:Wait()
                    local t = math.min(elapsed / riseTime, 1)
                    local currentY = startY + (riseTargetY - startY) * t
                    hrp.CFrame = CFrame.lookAt(
                        Vector3.new(tpPos.X, currentY, tpPos.Z),
                        Vector3.new(tpPos.X, currentY, tpPos.Z) + LEFT)
                    hrp.AssemblyLinearVelocity = Vector3.zero
                end
                hrp.CFrame = CFrame.lookAt(
                    Vector3.new(tpPos.X, riseTargetY, tpPos.Z),
                    Vector3.new(tpPos.X, riseTargetY, tpPos.Z) + LEFT)
                hrp.AssemblyLinearVelocity = Vector3.zero
            end

            -- Step 3: clone push through the wall at brainrot height (all floors)
            prepMiniTpTool(hum, hrp)
            waitSecondsHeartbeat(0.05)
            hrp.AssemblyLinearVelocity = Vector3.zero
            waitSecondsHeartbeat(0.01)
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.CFrame = hrp.CFrame * CFrame.new(0, 0, -2.5)
            hrp.AssemblyLinearVelocity = Vector3.zero
            waitSecondsHeartbeat(Config.TpSettings.CloneDelayVal or 0.1)
            local miniPos = hrp.Position
            waitSecondsHeartbeat(0.01)
            local stillAtMiniPos = waitUntilHeartbeat(function()
                return hrp and hrp.Parent and ((hrp.Position - miniPos).Magnitude <= 2)
            end, 0.75)
            if not stillAtMiniPos then
                error("moved away from mini TP position before clone")
            end
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            local cloneSuccess = false
            for attempt = 1, 3 do
                instantClone()
                local moved = waitUntilHeartbeat(function()
                    return hrp and hrp.Parent and ((hrp.Position - miniPos).Magnitude >= 0.35)
                end, 3)
                if moved then
                    cloneSuccess = true
                    break
                end
                while _G.isCloning do task.wait() end
                task.wait(0.1)
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.CFrame = CFrame.new(miniPos)
            end
            if not cloneSuccess then
                error("clone failed/no push")
            end
            if cloner then
                hum:EquipTool(cloner)
                task.wait(0.02)
                pcall(function() cloner:Activate() end)
                task.wait(0.05)
                equipTpToolAndWait(hum)
            end

            -- Keep velocity zero and CFrame glued to target animal for steal duration
            local holdEnd = tick() + math.max(0.18, Config.TpSettings.DelayVal or 0.4)
            while tick() < holdEnd do
                if not hrp.Parent then break end
                if LocalPlayer:GetAttribute("Stealing") then break end
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
                pcall(function() hrp.CFrame = CFrame.new(targetPart.Position) end)
                RunService.Heartbeat:Wait()
            end

            -- Step 4: platform removed (no float pad under the character)
        -- Force equip the configured TP tool (not the cloner)
        pcall(function() hum:UnequipTools() end)
        task.wait(0.05)
        equipTpToolAndWait(hum)
        -- Verify tool is equipped, retry if game re-equipped cloner
        task.defer(function()
            task.wait(0.1)
            local char2 = LocalPlayer.Character
            local hum2 = char2 and char2:FindFirstChildOfClass("Humanoid")
            if not hum2 then return end
            local toolName2 = Config.TpSettings.Tool or "Flying Carpet"
            local equipped = char2:FindFirstChild(toolName2)
            if not equipped then
                pcall(function() hum2:UnequipTools() end)
                task.wait(0.05)
                local t2 = LocalPlayer.Backpack:FindFirstChild(toolName2)
                if t2 then pcall(function() hum2:EquipTool(t2) end) end
            end
        end)
        if isCloseBase then
            task.wait(0.3) -- slightly delay starting carpet speed to brainrot for close bases to avoid anti-cheat flag
        end
        
        -- Walk to brainrot with Carpet Speed instead of direct teleport
        local targetBrainrotPos = targetPart.Position
        local distToBrainrot = (hrp.Position - targetBrainrotPos).Magnitude
        
        if distToBrainrot > 3 then
            -- Equip carpet and walk there with carpet speed
            local toolName = Config.TpSettings.Tool or "Flying Carpet"
            local tool = LocalPlayer.Backpack:FindFirstChild(toolName) or char:FindFirstChild(toolName)
            if tool and tool.Parent ~= char then hum:EquipTool(tool); task.wait(0.02) end
            
            local walkTimeout = os.clock()
            local WALK_SPEED = 190
            
            while hrp.Parent and (os.clock() - walkTimeout) < 8 do
                if LocalPlayer:GetAttribute("Stealing") then break end
                local brPos = targetPart.Position
                local diff = Vector3.new(brPos.X - hrp.Position.X, 0, brPos.Z - hrp.Position.Z)
                local flatDist = diff.Magnitude
                
                local verticalDiff = brPos.Y - hrp.Position.Y
                -- When f2FromF1 is on, break as soon as we're horizontally close;
                -- the airPos+platform block below handles the vertical lift.
                if flatDist < 3 and (f2FromF1 or math.abs(verticalDiff) < 8) then break end
                
                local moveDir = (flatDist > 0.1) and diff.Unit or Vector3.zero
                local yVel = hrp.AssemblyLinearVelocity.Y
                
                -- Handle vertical: if brainrot is above, rise up smoothly.
                -- Skip the rise when f2FromF1 is on so we stay on floor 1.
                if verticalDiff > 2 then
                    if not f2FromF1 then
                        yVel = math.clamp(verticalDiff * 7, 30, 60)
                    end
                elseif verticalDiff < -2 then
                    yVel = math.clamp(verticalDiff * 4, -80, 0)
                end
                
                local currentWalkSpeed = WALK_SPEED
                if flatDist < 3 then currentWalkSpeed = 0 end
                
                hrp.AssemblyLinearVelocity = Vector3.new(moveDir.X * currentWalkSpeed, yVel, moveDir.Z * currentWalkSpeed)
                RunService.Heartbeat:Wait()
            end
            hrp.AssemblyLinearVelocity = Vector3.zero
        end
        
        -- Final positioning near brainrot
        local verticalDiff = targetPart.Position.Y - hrp.Position.Y
        if verticalDiff > 2 then
            local airPos = Vector3.new(targetPart.Position.X, targetPart.Position.Y - 8, targetPart.Position.Z)
            -- platform removed (see step 4)
            
            -- Smooth CFrame Lerp to prevent anti-cheat triggers and flinging
            local startCF = hrp.CFrame
            local targetCF = CFrame.new(airPos)
            local duration = 0.6
            local start = tick()
            while tick() - start < duration and hrp.Parent do
                if LocalPlayer:GetAttribute("Stealing") then break end
                local t = (tick() - start) / duration
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
                hrp.CFrame = startCF:Lerp(targetCF, t)
                RunService.Heartbeat:Wait()
            end
            hrp.CFrame = targetCF
            hrp.AssemblyLinearVelocity = Vector3.zero
        else
            for i = 1, 5 do
                if LocalPlayer:GetAttribute("Stealing") then break end
                hrp.AssemblyLinearVelocity = Vector3.zero
                if (hrp.Position - targetPart.Position).Magnitude > 3 then
                    hrp.CFrame = CFrame.new(targetPart.Position)
                end
                task.wait(0.05)
            end
            -- V3 Floor 2 from Floor 1 also spams jump on arrival for floor-1
            -- pets so we grab elevated pets on floor 1 (small platforms, podiums,
            -- pets sitting slightly above ground level).
            if Config.AutoTPFloor2FromFloor1 and not isSecondFloor then
                task.spawn(function()
                    local start = tick()
                    while (tick() - start) < 5 do
                        if LocalPlayer:GetAttribute("Stealing") then break end
                        if hum and hum.Parent then
                            pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end)
                            pcall(function() hum.Jump = true end)
                        end
                        task.wait(0.1)
                    end
                end)
            end
        end
    end)
    _G._isTpMoving = false
    pcall(setfpscap, lastFpsCap)
    if not ok then
        warn("runAutoSnipe error:", err)
    end
    -- handled either way: a mid-run failure already moved the character, so the
    -- dispatcher must not start a second engine on top of it
    return true
end

function tpToBrainrot()
    local targetPetData = getTargetPetData()
    if not targetPetData then
        return
    end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    if not hrp or not hum or (hum.Health <= 0) then
        return
    end
    local targetPart = nil
    for _ = 1, 10 do
        targetPart = findAdorneeGlobal(targetPetData)
        if targetPart then
            break
        end
        task.wait(0.05)
    end
    if not targetPart then
        return
    end
    local lastFpsCap = pcall(getfpscap) and getfpscap() or 60
    pcall(setfpscap, 200)
    local ok, err = pcall(function()
        local carpetName = Config.TpSettings.Tool
        local carpet = LocalPlayer.Backpack:FindFirstChild(carpetName) or char:FindFirstChild(carpetName)
        if carpet then
            hum:EquipTool(carpet)
        end
        local targetPos = targetPart.Position
        local verticalDiff = targetPos.Y - hrp.Position.Y
        -- Compute an "over" Y that clears anything between us and the target.
        -- We hop UP to this Y at the target's XZ, then drop down.
        local overY = math.max(hrp.Position.Y, targetPos.Y) + 20
        if verticalDiff > 2 or targetPos.Y > 25 then
            local plat = Instance.new("Part")
            plat.Name = "XiTempPlatform"
            plat.Size = Vector3.new(6, 1.5, 6)
            plat.Position = Vector3.new(targetPos.X, targetPos.Y - 11, targetPos.Z)
            plat.Color = Color3.fromRGB(30, 30, 30)
            plat.Material = Enum.Material.Neon
            plat.Anchored = true
            plat.CanCollide = false; pcall(makeOneWay, plat)
            plat.Transparency = 0.3
            plat.Parent = Workspace
            
            -- JUMP-OVER phase: hop up above target first (dodges walls/ceilings).
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            hrp.CFrame = CFrame.new(targetPos.X, overY, targetPos.Z)
            task.wait(0.03)
            
            -- Drop onto target (8 studs below target center, onto the platform).
            local targetCF = CFrame.new(targetPos.X, targetPos.Y - 8, targetPos.Z)
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            hrp.CFrame = targetCF
            task.wait(0.05)
            hrp.AssemblyLinearVelocity = Vector3.zero
            
            task.spawn(function()
                local start = tick()
                while (tick() - start) < 20 do
                    if LocalPlayer:GetAttribute("Stealing") then
                        break
                    end
                    task.wait(0.1)
                end
                plat:Destroy()
            end)
        else
            -- JUMP-OVER phase: hop up above target first (dodges walls/ceilings).
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            hrp.CFrame = CFrame.new(targetPos.X, overY, targetPos.Z)
            task.wait(0.03)
            
            -- Drop onto brainrot.
            local targetCF = CFrame.new(targetPos)
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            hrp.CFrame = targetCF
            task.wait(0.05)
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            local holdEnd = tick() + math.max(0.18, Config.TpSettings.DelayVal or 0.4)
            while tick() < holdEnd do
                if not hrp.Parent then
                    break
                end
                if LocalPlayer:GetAttribute("Stealing") then
                    break
                end
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
                pcall(function() hrp.CFrame = CFrame.new(targetPos) end)
                RunService.Heartbeat:Wait()
            end
        end
    end)
    pcall(setfpscap, lastFpsCap)
    if not ok then
        warn("tpToBrainrot error:", err)
    end
end
_G.runAutoSnipe = runAutoSnipe
_G.tpToBrainrot = tpToBrainrot

-- AUTO-EXECUTE FROM CONFIG (TP-on-load) -- HOISTED here (right after runAutoSnipe is defined) so
-- the watcher starts polling as EARLY as possible, in PARALLEL with the rest of the hub loading,
-- and fires the grapple TP the INSTANT your character + a target brainrot exist -- while the game
-- is still on the loading screen. (Moved up from its old spot ~line 9750.)
-- =====================================================================
-- TP ON LOAD  ==  pressing the Manual TP key, automatically.
-- ---------------------------------------------------------------------
-- It used to gate on getTargetPetData() AND findAdorneeGlobal() both returning
-- something, then call runAutoSnipe. Three problems, all of which showed up as
-- "TP on load just does not work":
--
--   * getTargetPetData() reads SharedState.AllAnimalsCache, so it needed the
--     panel scanner to have already populated -- on a fresh join that is
--     several seconds, and the 25s budget was often spent waiting on it.
--   * findAdorneeGlobal() needed the podium instance to exist CLIENT-SIDE.
--     With StreamingEnabled a far base has not arrived yet, so the gate stayed
--     shut and the TP never fired at all.
--   * it used a different entry point (and therefore a different target
--     picker) from the Manual TP key.
--
-- The engine already polls for pets for 6s on its own and streams the
-- destination in, so none of that gating is needed. Wait for the character,
-- give the scanner a brief head start so the first pick is a good one, then
-- fire the SAME function the keybind fires.
-- =====================================================================
-- =====================================================================
-- THE ONE TP LAUNCHER
-- ---------------------------------------------------------------------
-- Every way of starting a teleport runs THIS, so the keybind, the Actions
-- button and TP-on-load are the same thing by construction rather than three
-- copies that drifted apart.
--
-- They had drifted badly: TP-on-load gated on getTargetPetData() out here,
-- while the keybind passed an esperaMax into the cycle and gated on temAlvo()
-- INSIDE it -- a different check, reading the cache directly with its own owner
-- filters. temAlvo() could say "no target" on a server where getTargetPetData()
-- returned one perfectly well, and then the cycle skipped the hook entirely.
-- That is why the keybind never dragged you and TP-on-load did.
--
-- It calls the grapple cycle with NO esperaMax: the (bounded) wait already
-- happened here, so the cycle finds its target on the first check.
-- =====================================================================
-- ONE SHOT. IT DECIDES NOW.
-- ---------------------------------------------------------------------
-- THIS is what teleported you "whenever a new plot is detected". Nothing in
-- the hub watches plots in order to teleport -- but this launcher used to sit
-- in a 25-SECOND loop re-asking getTargetPetData() every 0.1s and firing the
-- instant one appeared. A base streaming in, or a brainrot spawning on a
-- podium, is exactly what makes that call start returning something -- so the
-- teleport went off ten or twenty seconds after load, or long after a keypress
-- that had visibly done nothing, with no way to tell a launcher was still
-- armed. Pressing the key twice armed two of them.
--
-- The rules now:
--   * every launch invalidates the one before it (the token), so a keypress can
--     never leave an older watcher running behind it;
--   * the ONLY wait is for your own character, which is not a target watch --
--     with no HumanoidRootPart there is nothing to teleport at all;
--   * TP-on-load gets ONE short settle window, because on a fresh join the
--     scanner cache is legitimately empty for a second or two. That window is
--     the whole of "on load"; it is never armed again afterwards and the
--     keybind never gets it;
--   * no target at the moment of the decision means NO teleport -- not a
--     teleport later. It says so and stops.
-- =====================================================================
_G.Skyr0TPLaunchToken = 0
_G.Skyr0LaunchTP = function(onLoad)
    _G.Skyr0TPLaunchToken = (_G.Skyr0TPLaunchToken or 0) + 1
    local meuToken = _G.Skyr0TPLaunchToken
    -- Claim priority over the heap prewarms for as long as this launch is live.
    -- __Skyr0HeapSweep refuses to START a getgc(true) walk while this is set, so
    -- the teleport never has to wait for one (see step 2b). Timestamped and
    -- reclaimed after 45s so a launch that dies somewhere unexpected cannot
    -- block the prewarms for the rest of the session.
    _G.__Skyr0TPPending = os.clock()
    task.spawn(function()
        local function cancelado() return _G.Skyr0TPLaunchToken ~= meuToken end
        -- released on EVERY exit from this thread, including the early returns
        local function soltar()
            if _G.Skyr0TPLaunchToken == meuToken then _G.__Skyr0TPPending = nil end
        end

        -- ============================================================
        --  NEVER LAUNCH AT THE BASE WE ARE STANDING IN.
        --
        --  Belt and braces alongside the spawn-plot latch that feeds
        --  Skyr0IsMyPlotCached. That latch needs workspace.Plots to have
        --  replicated; on a slow join it can still be unset when this
        --  window opens, and then the ownership filters are cold and a
        --  pet on OUR OWN podium is a perfectly valid answer to every
        --  picker. Flying to a base you are already inside does nothing
        --  and the steal that follows has nothing to grab -- which is
        --  the "TP on load hits our base and fails".
        --
        --  Asked live, not cached: it is one pivot compare per plot and
        --  it only runs on the load path.
        -- ============================================================
        --  LOAD ONLY. A keypress is a deliberate "go there now" and must not
        --  start second-guessing the pickers -- if you press it standing on a
        --  base, you meant it. Only the automatic launch, which fires while
        --  ownership is still cold, gets this.
        local function _alvoEmCasa(cand)
            if not onLoad then return false end
            if type(cand) ~= "table" or not cand.plot then return false end
            if _G.Skyr0IsMyPlotCached and _G.Skyr0IsMyPlotCached(cand.plot) then return true end
            local aqui = _G.Skyr0PlotUnderMe and _G.Skyr0PlotUnderMe()
            return aqui ~= nil and aqui == cand.plot
        end

        -- 1) WAIT FOR THE BODY, NOT FOR A TARGET.
        --    Short for a keypress: you are already spawned when you press it, so
        --    3s is a hiccup allowance, not a watch.
        local prazoChar = onLoad and 20 or 3
        local _t0 = os.clock()
        local _hrp, _h
        while true do
            if cancelado() then soltar(); return end
            local _c = player.Character
            _hrp = _c and _c:FindFirstChild("HumanoidRootPart")
            _h = _c and _c:FindFirstChild("Humanoid")
            if _hrp and _h and _h.Health > 0 then break end
            if os.clock() - _t0 > prazoChar then soltar(); return end
            task.wait(0.1)
        end

        -- 2) LOAD ONLY: one settle window for the FIRST scan.
        --    sxe.txt also required findAdorneeGlobal() here, and that is why
        --    TP-on-load never fired: the adornee is the podium INSTANCE, and with
        --    StreamingEnabled a base you are not standing next to has not
        --    replicated yet. runAutoSnipe polls for the podium and streams the
        --    region in itself, so gating on it out here only blocks.
        --
        --    0.1s per check, not every frame: getTargetPetData() walks the whole
        --    animal cache with a FindFirstChild + GetPivot per entry, and doing
        --    that on Heartbeat was the FPS drop right after execute.
        if onLoad then
            local janela = tonumber(Config.TpSettings.TpOnLoadScanWindow) or 10
            local _s0 = os.clock()
            -- EVENT-DRIVEN, not a blind 0.1s poll.
            --
            -- The expensive part is getTargetPetData(), which walks the whole
            -- animal cache -- that is why it was throttled to 0.1s, and why it
            -- must not go on Heartbeat. But the cheap part is
            -- SharedState.CacheVersion, which the plot scanner bumps ONLY when
            -- the cache genuinely changed. Watching that costs one table read.
            --
            -- So: check the version every frame and call the expensive function
            -- the instant it moves, otherwise fall back to the same 0.1s tick.
            -- Same CPU cost as before in the worst case, but the moment the
            -- first pets land the teleport goes on that frame instead of up to
            -- 100ms later -- and on a slow-filling server that difference
            -- repeats on every empty tick until something appears.
            -- ============================================================
            --  DO NOT COMMIT TO THE FIRST PET THAT SHOWS UP.
            --
            --  This is why TP-on-load went to the wrong brainrot while every
            --  manual TP afterwards was right.
            --
            --  The exit used to be `if getTargetPetData() then break end` --
            --  any target at all, and go. But at load the cache is filling
            --  BASE BY BASE as plots replicate, and getTargetPetData answers
            --  from whatever is in it at that instant. The first base to
            --  stream in produces a target, this broke immediately, and the
            --  teleport locked onto it -- while the priority pet was still two
            --  seconds away from being scanned. By the time you press the key
            --  manually the cache is full, so it looks fine from then on.
            --
            --  Three ways out now, in order of how good the answer is:
            --    1. a pet ON THE PRIORITY LIST -> go immediately. Nothing that
            --       arrives later can beat it, so there is nothing to wait for.
            --    2. no priority list in use    -> first target, as before.
            --    3. anything else              -> only once the scanner has
            --       gone QUIET for SETTLE seconds. CacheVersion moves on every
            --       real change, so "stopped moving" means the plots have
            --       finished landing and the pick is over the whole server
            --       rather than over whichever base won the replication race.
            --  The scan window is still the hard ceiling on all of it.
            -- ============================================================
            local SETTLE = tonumber(Config.TpSettings.TpOnLoadSettle) or 1.5
            local _listInUse = (type(priorityList) == "table" and #priorityList > 0)
            local _lastVer = SharedState and SharedState.CacheVersion or 0
            local _verAt   = os.clock()
            local _nextPoll = 0
            -- COALESCE THE BURST.
            --
            -- `_moved` bypassed _nextPoll entirely, so every single version bump
            -- fired getTargetPetData() immediately. That reads fine when bumps
            -- are occasional -- but this loop only ever runs DURING LOAD, which
            -- is precisely when they are not: eight plots land within a second
            -- of each other and each one bumps as its pets resolve, so the
            -- "event-driven" path degenerated into calling the most expensive
            -- function in the picker dozens of times a second.
            --
            -- A floor of _MOVE_GAP keeps the responsiveness that path exists for
            -- (0.03s is under half a frame at 60fps -- still far tighter than the
            -- 0.1s fallback tick) while collapsing a burst of bumps arriving
            -- together into one evaluation instead of one each.
            --
            -- _verAt is still stamped on EVERY bump, unthrottled. It has to be:
            -- it is what SETTLE measures "the scanner has gone quiet" against,
            -- and skipping bumps there would make the scanner look settled while
            -- plots were still landing -- the exact bug the settle window exists
            -- to prevent.
            local _MOVE_GAP = 0.03
            local _nextMove = 0

            -- ============================================================
            --  THE PRIORITY EXIT DOES NOT WAIT FOR THE FULL PICKER.
            --
            --  The question "is one of my priority pets on the server yet"
            --  used to be answered by calling getTargetPetData() and asking
            --  whether the pet it CHOSE happens to be listed. That works, but
            --  it pays for the entire picker to find out -- plot pivots,
            --  distance sweeps, the brainrot walk -- and it only ran on the
            --  throttled tick, so the answer arrived up to 0.1s after the pet
            --  actually landed in the cache.
            --
            --  Answering it directly is a name lookup per cached pet and
            --  nothing else: no GetPivot, no distance, no table building. Cheap
            --  enough to run UNTHROTTLED on every version bump -- which is the
            --  only moment the answer can change, since the cache is what
            --  CacheVersion tracks.
            --
            --  So the priority pet is now caught on the very frame its base
            --  lands, and the expensive picker stays on its throttle for the
            --  other exits.
            --
            --  The ownership filter matters here: without it your OWN listed
            --  pets would satisfy this and fire the teleport at your own base.
            --  scanSinglePlot records owner = "" until the channel resolves, so
            --  the plot test is checked too, exactly as _stealable does.
            -- ============================================================
            local _prioReady = function()
                local c = SharedState and SharedState.AllAnimalsCache
                if type(c) ~= "table" or not _G.Skyr0PrioRank then return false end
                local myName, myDisp = LocalPlayer.Name, LocalPlayer.DisplayName
                -- resolved once per call, not once per pet: it is a walk of the
                -- Plots folder and the answer cannot change inside the loop
                local aqui = _G.Skyr0PlotUnderMe and _G.Skyr0PlotUnderMe()
                for _, a in ipairs(c) do
                    if a and a.owner ~= myName and a.owner ~= myDisp
                       and not (_G.Skyr0IsMyPlotCached and _G.Skyr0IsMyPlotCached(a.plot))
                       and not (aqui ~= nil and a.plot == aqui)
                       and _G.Skyr0PrioRank(a.name, a.index) then
                        return true
                    end
                end
                return false
            end

            -- ============================================================
            --  AND IT DOES NOT WAIT 1.5s TO GIVE UP EITHER.
            --
            --  SETTLE exists to answer "have the plots finished landing", and
            --  it answers it by watching the scanner go quiet -- an inference,
            --  because there was nothing better to ask. The cost of that
            --  inference is paid on EVERY load where the priority pet simply
            --  is not on the server: a full SETTLE of dead time before the
            --  teleport will accept anything else.
            --
            --  The scanner now reports coverage directly (PlotsScanned /
            --  PlotsTotal), so the question can be asked instead of inferred.
            --  Once every base has reported, a listed pet that is not in the
            --  cache is not on the server, and there is nothing left to wait
            --  for -- _SETTLE_FAST is only there to absorb the last couple of
            --  frames of a base that reported mid-bump.
            --
            --  SETTLE stays as the fallback for when coverage never completes
            --  (a base that never streams in, PlotsTotal never resolving), so
            --  this can only ever make the wait shorter, never longer.
            -- ============================================================
            local _SETTLE_FAST = 0.2
            -- "everyone has said something" -- worth a short settle
            local _covered = function()
                local tot = SharedState and SharedState.PlotsTotal or 0
                local got = SharedState and SharedState.PlotsScanned or 0
                return tot > 0 and got >= tot
            end
            -- "everyone has said everything" -- worth nothing further at all
            local _complete = function()
                local tot = SharedState and SharedState.PlotsTotal or 0
                local got = SharedState and SharedState.PlotsFull or 0
                return tot > 0 and got >= tot
            end

            while os.clock() - _s0 < janela do
                if cancelado() then soltar(); return end
                local _ver = SharedState and SharedState.CacheVersion or 0
                local _moved = (_ver ~= _lastVer)
                if _moved then _lastVer, _verAt = _ver, os.clock() end

                -- cheap, unthrottled, and only on a real change
                if _moved and _listInUse and _prioReady() then break end

                local _now = os.clock()
                if (_moved and _now >= _nextMove) or _now >= _nextPoll then
                    _nextMove = _now + _MOVE_GAP
                    _nextPoll = _now + 0.1
                    local cand = getTargetPetData()
                    -- our own podiums are not a reason to stop waiting: keep the
                    -- window open until a real base reports in
                    if cand and _alvoEmCasa(cand) then cand = nil end
                    if cand then
                        if not _listInUse then break end
                        if _G.Skyr0PrioRank and _G.Skyr0PrioRank(cand.name, cand.index) then break end
                        -- Every base has given its authoritative list and the
                        -- listed pet is not in it: it is not on this server.
                        -- No amount of further waiting changes that answer.
                        if _complete() then break end
                        local _quiet = os.clock() - _verAt
                        if _covered() and _quiet >= _SETTLE_FAST then break end
                        if _quiet >= SETTLE then break end
                    end
                end
                RunService.Heartbeat:Wait()
            end
        end

        if cancelado() then soltar(); return end

        -- 2b) THE TELEPORT NEVER WAITS FOR A HEAP PREWARM.
        --
        -- This used to block here until __Skyr0HeapBusy cleared, and THAT is
        -- what made TP-on-load feel "super delayed": the PlayerMouse prewarm
        -- holds out up to 4s for game:IsLoaded(), then settles 20 heartbeats --
        -- which during a load screen at ~7fps is seconds on its own -- and only
        -- then runs its sweep. The teleport sat behind all of it.
        --
        -- The priority is inverted now. __Skyr0TPPending is raised the moment a
        -- launch is armed (top of this function) and __Skyr0HeapSweep waits on
        -- IT, so a sweep that has not started yet simply stays out of the way and
        -- the teleport goes immediately. A sweep already mid-getgc cannot be
        -- preempted -- that is one blocking C call -- but it can no longer start
        -- in front of us, which was the actual collision.
        --
        -- 2c) Steal lockout, re-checked at the decision point. Skyr0CicloTP and
        -- _fxTpDispatch both refuse while Stealing is set, but this thread can
        -- have been waiting for up to 30s -- a steal may well have started in
        -- the meantime -- and stopping here is cleaner than launching a cycle
        -- that immediately declines.
        if _G.Skyr0IsStealing and _G.Skyr0IsStealing() then
            warn("[skyr0] TP not launched: you are stealing.")
            soltar()
            return
        end

        -- 3) DECIDE ONCE.
        local _alvo = getTargetPetData()
        if not _alvo then
            ShowNotification("TP", "No target right now -- press the key again.")
            warn("[skyr0] TP: nothing in the scanner cache right now -- not teleporting, "
              .. "and nothing is left armed waiting for one to appear.")
            soltar()
            return
        end
        -- The only answer the pickers could give is a pet on the base we are
        -- standing in. Launching would fly nowhere and hand the steal engine a
        -- podium it can never take, so say so and stop instead.
        if _alvoEmCasa(_alvo) then
            ShowNotification("TP", "Only your own base is in range -- not teleporting.")
            warn("[skyr0] TP: the only target the pickers can see is on YOUR OWN base "
              .. "(ownership has not resolved yet) -- not teleporting.")
            soltar()
            return
        end

        -- The cycle hooks, faces the plot, then hands off to _fxTpDispatch --
        -- which is what primes _G.TPVelocity from GrabbleTPSpeed, TPCloneDelay
        -- and the live priority list.
        if _G.Skyr0CicloTP then task.spawn(_G.Skyr0CicloTP)
        else task.spawn(runAutoSnipe) end
        -- Held a few seconds past the hand-off, not dropped instantly: the cycle
        -- needs a moment to raise __Skyr0CicloRodando, and a prewarm slipping
        -- into that gap is exactly the collision this is here to prevent.
        task.delay(4, soltar)
    end)
end

if Config.TpSettings.TpOnLoad then task.spawn(function()
    task.wait(tonumber(Config.TpSettings.TpOnLoadDelay) or 0)
    -- load Net in parallel -- never block the target scan waiting on it (the
    -- flight to the base covers the load; the steal only needs it once we arrive)
    task.spawn(function() pcall(loadNet) end)
    -- TpOnLoadDelay above is the ONLY wait.
    -- true == "this is the load", the one and only caller allowed the settle
    -- window in step 2. Every other caller (keybinds, Actions button) decides
    -- on the spot.
    _G.Skyr0LaunchTP(true)
end) end

-- (CLICK TO AP removed)
-- ============================================================
-- ESP
-- ============================================================
-- Player ESP
local playerESPEnabled=Config.PlayerESP; local playerBillboards={}
DANGER_TOOLS={["Boogie Bomb"]=true,["Medusa's Head"]=true,["Body Swap Potion"]=true,["Laser Cape"]=true,["Rainbowrath Sword"]=true,["Gummy Bear"]=true}
local function getHeldTool(p) local c=p.Character; if not c then return nil end; for _,o in ipairs(c:GetChildren()) do if o:IsA("Tool") then return o.Name end end; return nil end
local function makePlayerBillboard(plr)
    local bb=Instance.new("BillboardGui"); bb.Name="PlayerESP_"..tostring(plr.UserId); bb.Size=UDim2.new(0,170,0,34)
    bb.StudsOffsetWorldSpace=Vector3.new(0,2.8,0); bb.AlwaysOnTop=true; bb.LightInfluence=0; bb.ResetOnSpawn=false
    local nameLbl=Instance.new("TextLabel",bb); nameLbl.Size=UDim2.new(1,0,0,18); nameLbl.BackgroundTransparency=1
    nameLbl.Font=Enum.Font.GothamBold; nameLbl.TextSize=14; nameLbl.TextColor3=Color3.fromRGB(255,255,255)
    nameLbl.TextStrokeTransparency=0.4; nameLbl.TextStrokeColor3=Color3.fromRGB(0,0,0); nameLbl.Text=plr.Name
    local toolLbl=Instance.new("TextLabel",bb); toolLbl.Name="ToolLabel"; toolLbl.Size=UDim2.new(1,0,0,13); toolLbl.Position=UDim2.new(0,0,0,18)
    toolLbl.BackgroundTransparency=1; toolLbl.Font=Enum.Font.GothamMedium; toolLbl.TextSize=11; toolLbl.TextColor3=Color3.fromRGB(100,220,255)
    toolLbl.TextStrokeTransparency=0.4; toolLbl.TextStrokeColor3=Color3.fromRGB(0,0,0); toolLbl.Text=getHeldTool(plr) or ""
    return bb,nameLbl
end
local function createOrRefreshPlayerESP(plr)
    if plr==LocalPlayer then return end; local hrp=plr.Character and plr.Character:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local hum=plr.Character:FindFirstChild("Humanoid"); if hum then hum.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None end
    local uid=plr.UserId; local entry=playerBillboards[uid]
    if not entry or not entry.bb or not entry.bb.Parent then
        if entry and entry.bb then pcall(function() entry.bb:Destroy() end) end
        local bb,nameLbl=makePlayerBillboard(plr); bb.Adornee=hrp; bb.Parent=hrp; playerBillboards[uid]={bb=bb,nameLbl=nameLbl,player=plr}
    elseif entry.bb.Adornee~=hrp then entry.bb.Adornee=hrp; entry.bb.Parent=hrp end
end
local function clearPlayerESP()
    for uid,entry in pairs(playerBillboards) do if entry.bb then pcall(entry.bb.Destroy,entry.bb) end; playerBillboards[uid]=nil end
end
task.spawn(function() while true do task.wait(0.5)
    if playerESPEnabled then
        for _,plr in ipairs(Players:GetPlayers()) do if plr~=LocalPlayer then pcall(createOrRefreshPlayerESP,plr) end end
        for uid,entry in pairs(playerBillboards) do if entry.bb and entry.bb.Parent then
            pcall(function() local tl=entry.bb:FindFirstChild("ToolLabel"); if tl then local ht=getHeldTool(entry.player); tl.Text=ht or ""
                if entry.nameLbl then entry.nameLbl.TextColor3=ht and DANGER_TOOLS[ht] and Color3.fromRGB(255,60,60) or Color3.fromRGB(255,255,255) end
            end end)
        end end
    else clearPlayerESP() end
end end)

-- Line To Base ESP (kinqs beam style)
do
    local plotBeam = nil
    local plotBeamAttachment0 = nil
    local plotBeamAttachment1 = nil

    local function findMyPlot()
        local plots = workspace:FindFirstChild("Plots")
        if not plots then return nil end
        for _, plot in ipairs(plots:GetChildren()) do
            local sign = plot:FindFirstChild("PlotSign")
            if sign then
                local surfaceGui = sign:FindFirstChildWhichIsA("SurfaceGui", true)
                if surfaceGui then
                    local label = surfaceGui:FindFirstChildWhichIsA("TextLabel", true)
                    if label then
                        local text = label.Text:lower()
                        if text:find(LocalPlayer.DisplayName:lower(), 1, true) or text:find(LocalPlayer.Name:lower(), 1, true) then
                            return plot
                        end
                    end
                end
            end
        end
        return nil
    end

    local function createPlotBeam()
        if not Config.LineToBase then return end
        local myPlot = findMyPlot()
        if not myPlot or not myPlot.Parent then return end
        local character = LocalPlayer.Character
        if not character or not character.Parent then return end
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp or not hrp.Parent then return end
        if plotBeam then pcall(function() plotBeam:Destroy() end) end
        if plotBeamAttachment0 then pcall(function() plotBeamAttachment0:Destroy() end) end
        plotBeamAttachment0 = hrp:FindFirstChild("PlotBeamAttach_Player") or Instance.new("Attachment")
        plotBeamAttachment0.Name = "PlotBeamAttach_Player"
        plotBeamAttachment0.Position = Vector3.new(0, 0, 0)
        plotBeamAttachment0.Parent = hrp
        local plotPart = myPlot:FindFirstChild("MainRootPart") or myPlot:FindFirstChildWhichIsA("BasePart")
        if not plotPart or not plotPart.Parent then return end
        plotBeamAttachment1 = plotPart:FindFirstChild("PlotBeamAttach_Plot") or Instance.new("Attachment")
        plotBeamAttachment1.Name = "PlotBeamAttach_Plot"
        plotBeamAttachment1.Position = Vector3.new(0, 5, 0)
        plotBeamAttachment1.Parent = plotPart
        plotBeam = hrp:FindFirstChild("PlotBeam") or Instance.new("Beam")
        plotBeam.Name = "PlotBeam"
        plotBeam.Attachment0 = plotBeamAttachment0
        plotBeam.Attachment1 = plotBeamAttachment1
        plotBeam.FaceCamera = true
        plotBeam.LightEmission = 1
        plotBeam.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
        plotBeam.Transparency = NumberSequence.new(0)
        plotBeam.Width0 = 0.3
        plotBeam.Width1 = 0.3
        plotBeam.TextureMode = Enum.TextureMode.Wrap
        plotBeam.TextureSpeed = 0
        plotBeam.Parent = hrp
    end

    local function resetPlotBeam()
        if plotBeam then pcall(function() plotBeam:Destroy() end) end
        if plotBeamAttachment0 then pcall(function() plotBeamAttachment0:Destroy() end) end
        if plotBeamAttachment1 then pcall(function() plotBeamAttachment1:Destroy() end) end
        plotBeam = nil
        plotBeamAttachment0 = nil
        plotBeamAttachment1 = nil
    end

    task.spawn(function()
        local checkCounter = 0
        RunService.Heartbeat:Connect(function()
            if not Config.LineToBase then return end
            checkCounter = checkCounter + 1
            if checkCounter >= 30 then
                checkCounter = 0
                if not plotBeam or not plotBeam.Parent or not plotBeamAttachment0 or not plotBeamAttachment0.Parent then
                    pcall(createPlotBeam)
                end
            end
        end)
    end)

    LocalPlayer.CharacterAdded:Connect(function(character)
        task.wait(0.5)
        if Config.LineToBase and character then
            pcall(createPlotBeam)
        end
    end)

    if LocalPlayer.Character then
        task.spawn(function()
            task.wait(0.2)
            if Config.LineToBase then createPlotBeam() end
        end)
    end

    _G.createPlotBeam = createPlotBeam
    _G.resetPlotBeam = resetPlotBeam
end

-- Line To Best Brainrot (kinqs beam style)
do
    local BEAM_NAME    = "BestPetBeam"
    local ATT0_NAME    = "BestPetBeamAttach_Player"
    local ATT1_NAME    = "BestPetBeamAttach_Target"
    local BEAM_COLOR   = Color3.fromRGB(30, 30, 30)   -- pink (line to best brainrot)

    local bestBeam     = nil
    local bestAtt0     = nil
    local bestAtt1     = nil
    local currentTargetPart = nil

    local function destroyBeam()
        if bestBeam then pcall(function() bestBeam:Destroy() end) end
        if bestAtt0 then pcall(function() bestAtt0:Destroy() end) end
        if bestAtt1 then pcall(function() bestAtt1:Destroy() end) end
        bestBeam, bestAtt0, bestAtt1 = nil, nil, nil
        currentTargetPart = nil
    end

    local function getBestTargetPart()
        -- ARMED TARGET FIRST.
        --
        -- Below is a third picker -- its own walk of AllAnimalsCache with its
        -- own priority/value/gen ordering -- which is how the beam could point
        -- at one pet while the steal engine was armed on another. When
        -- something IS armed, the tracer should show that and nothing else:
        -- the beam is meant to tell you where the hub is going, not to hold an
        -- opinion of its own.
        --
        -- Falls through to its own scan only when nothing is armed (auto-steal
        -- off, or still searching), which is what it is actually useful for.
        local armed = _G.Skyr0_StealStatus and _G.Skyr0_StealStatus.target
        if type(armed) == "table" and armed.plot and armed.slot then
            local ad = findAdorneeGlobal(armed)
            if ad and ad:IsA("BasePart") then return ad end
        end

        local cache = SharedState.AllAnimalsCache
        if not cache or #cache == 0 then return nil end
        local bestData = nil
        local bestVal = 0
        -- Priority list first
        for _, pName in ipairs(priorityList) do
            local searchName = pName:lower()
            for _, a in ipairs(cache) do
                if a and a.name and a.name:lower() == searchName and a.owner ~= LocalPlayer.Name then
                    local score = (a.genValue or 0) + 1e15
                    if score > bestVal then
                        bestVal = score
                        bestData = a
                    end
                end
            end
            if bestData then break end
        end
        -- Then brainrots by value
        if not bestData then
            for _, a in ipairs(cache) do
                if a and a.owner ~= LocalPlayer.Name and a.genValue and a.genValue >= 10000000 then
                    if a.genValue > bestVal then
                        bestVal = a.genValue
                        bestData = a
                    end
                end
            end
        end
        -- Then highest gen fallback
        if not bestData then
            for _, a in ipairs(cache) do
                if a and a.owner ~= LocalPlayer.Name and (a.genValue or 0) >= 1 then
                    if (a.genValue or 0) > bestVal then
                        bestVal = a.genValue or 0
                        bestData = a
                    end
                end
            end
        end
        if not bestData then return nil end
        local adornee = findAdorneeGlobal(bestData)
        if adornee and adornee:IsA("BasePart") then return adornee end
        return nil
    end

    local function ensureBeam(hrp, targetPart)
        if not hrp or not hrp.Parent or not targetPart or not targetPart.Parent then return end
        if not bestAtt0 or not bestAtt0.Parent or bestAtt0.Parent ~= hrp then
            if bestAtt0 then pcall(function() bestAtt0:Destroy() end) end
            bestAtt0 = hrp:FindFirstChild(ATT0_NAME) or Instance.new("Attachment")
            bestAtt0.Name = ATT0_NAME
            bestAtt0.Position = Vector3.new(0, 0, 0)
            bestAtt0.Parent = hrp
        end
        if currentTargetPart ~= targetPart or not bestAtt1 or not bestAtt1.Parent then
            if bestAtt1 then pcall(function() bestAtt1:Destroy() end) end
            bestAtt1 = targetPart:FindFirstChild(ATT1_NAME) or Instance.new("Attachment")
            bestAtt1.Name = ATT1_NAME
            bestAtt1.Position = Vector3.new(0, 3, 0)
            bestAtt1.Parent = targetPart
            currentTargetPart = targetPart
            if bestBeam then
                bestBeam.Attachment1 = bestAtt1
            end
        end
        if not bestBeam or not bestBeam.Parent then
            if bestBeam then pcall(function() bestBeam:Destroy() end) end
            bestBeam = Instance.new("Beam")
            bestBeam.Name = BEAM_NAME
            bestBeam.Attachment0 = bestAtt0
            bestBeam.Attachment1 = bestAtt1
            bestBeam.FaceCamera = true
            bestBeam.LightEmission = 1
            bestBeam.Color = ColorSequence.new(BEAM_COLOR)
            bestBeam.Transparency = NumberSequence.new(0.35)
            bestBeam.Width0 = 0.45
            bestBeam.Width1 = 0.45
            bestBeam.TextureMode = Enum.TextureMode.Wrap
            bestBeam.TextureSpeed = 0
            bestBeam.Parent = hrp
        end
    end

    task.spawn(function()
        local check = 0
        RunService.Heartbeat:Connect(function()
            if not Config.LineToBrainrot then
                if bestBeam or bestAtt0 or bestAtt1 then destroyBeam() end
                return
            end
            check = check + 1
            if check < 10 then return end
            check = 0

            local char = LocalPlayer.Character
            local hrp  = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then
                if bestBeam or bestAtt0 or bestAtt1 then destroyBeam() end
                return
            end

            local targetPart = getBestTargetPart()
            if not targetPart or not targetPart.Parent then
                if bestBeam or bestAtt1 then
                    if bestBeam then pcall(function() bestBeam:Destroy() end); bestBeam = nil end
                    if bestAtt1 then pcall(function() bestAtt1:Destroy() end); bestAtt1 = nil end
                    currentTargetPart = nil
                end
                return
            end

            pcall(ensureBeam, hrp, targetPart)

            -- Color coding: green when stealing, yellow when close, red default
            if bestBeam then
                local col = BEAM_COLOR
                if LocalPlayer:GetAttribute("Stealing") then
                    col = Color3.fromRGB(80, 255, 120)
                else
                    local dist = hrp and targetPart and (hrp.Position - targetPart.Position).Magnitude or math.huge
                    if dist < 30 then
                        col = Color3.fromRGB(255, 196, 72)
                    end
                end
                bestBeam.Color = ColorSequence.new(col)
            end
        end)
    end)

    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.5)
        currentTargetPart = nil
        bestAtt0 = nil
        if bestBeam then pcall(function() bestBeam:Destroy() end); bestBeam = nil end
    end)

    _G.updateBrainrotBeam = function()
        -- beam auto-updates via heartbeat, nothing to do
    end
    _G.resetBrainrotBeam = destroyBeam
    _G.resetBestPetBeam = destroyBeam
end

-- Brainrot ESP
local brainrotESPEnabled=Config.BrainrotESP; local brainrotBillboards={}
local function createBrainrotBillboard(data)
    local bb=Instance.new("BillboardGui"); bb.Name="BrainrotESP_"..data.uid; bb.Size=UDim2.new(0,160,0,38)
    bb.StudsOffset=Vector3.new(0,1.8,0); bb.AlwaysOnTop=true; bb.LightInfluence=0; bb.MaxDistance=3000
    local container=Instance.new("Frame",bb); container.Size=UDim2.new(1,0,1,0); container.BackgroundColor3=Color3.fromRGB(0,0,0)
    container.BackgroundTransparency=0.5; container.BorderSizePixel=0; Instance.new("UICorner",container).CornerRadius=UDim.new(0,4)
    local stroke=Instance.new("UIStroke",container); stroke.Color=Color3.fromRGB(235,235,235); stroke.Thickness=1.5; stroke.Transparency=0.2
    local nameLabel=Instance.new("TextLabel",container); nameLabel.Size=UDim2.new(1,-6,0,18); nameLabel.Position=UDim2.new(0,3,0,2)
    nameLabel.BackgroundTransparency=1; nameLabel.Font=Enum.Font.GothamBlack; nameLabel.TextSize=13; nameLabel.TextColor3=Color3.fromRGB(235,235,235)
    nameLabel.TextStrokeTransparency=0; nameLabel.TextStrokeColor3=Color3.fromRGB(0,0,0); nameLabel.Text=data.name or "???"; nameLabel.TextXAlignment=Enum.TextXAlignment.Center
    local genLabel=Instance.new("TextLabel",container); genLabel.Size=UDim2.new(1,-6,0,14); genLabel.Position=UDim2.new(0,3,0,20)
    genLabel.BackgroundTransparency=1; genLabel.Font=Enum.Font.GothamBold; genLabel.TextSize=11; genLabel.TextColor3=Color3.fromRGB(255,255,255)
    genLabel.TextStrokeTransparency=0; genLabel.TextStrokeColor3=Color3.fromRGB(0,0,0); genLabel.Text=data.genText or ""; genLabel.TextXAlignment=Enum.TextXAlignment.Center
    return bb
end
local function refreshBrainrotESP()
    if not brainrotESPEnabled then return end; local cache=SharedState.AllAnimalsCache; if not cache or #cache==0 then return end
    local seen={}
    for _,data in ipairs(cache) do if data.genValue>=10000000 then seen[data.uid]=true
        if not brainrotBillboards[data.uid] then
            local adornee=findAdorneeGlobal(data)
            if adornee then local bb=createBrainrotBillboard(data); bb.Adornee=adornee; bb.Parent=adornee
                local hlParent=(adornee.Parent and adornee.Parent:IsA("Model") and adornee.Parent) or adornee
                local hl=Instance.new("Highlight"); hl.Name="BrainrotHL_"..data.uid; hl.FillColor=Color3.fromRGB(235,235,235); hl.FillTransparency=0.65
                hl.OutlineColor=Color3.fromRGB(235,235,235); hl.OutlineTransparency=0.1; hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; hl.Adornee=hlParent; hl.Parent=hlParent
                brainrotBillboards[data.uid]={bb=bb,highlight=hl}
            end
        end
    end end
    for uid,entry in pairs(brainrotBillboards) do if not seen[uid] then
        if entry.bb then entry.bb:Destroy() end; if entry.highlight then entry.highlight:Destroy() end; brainrotBillboards[uid]=nil
    end end
end
local function clearBrainrotESP() for _,e in pairs(brainrotBillboards) do if e.bb then e.bb:Destroy() end; if e.highlight then e.highlight:Destroy() end end; brainrotBillboards={} end
task.spawn(function() while true do task.wait(0.3); if brainrotESPEnabled then pcall(refreshBrainrotESP) end end end)

-- Subspace Mine ESP
local subspaceMineESPEnabled=Config.SubspaceMineESP; local subspaceMineESPData={}
local function refreshSubspaceMineESP()
    if not subspaceMineESPEnabled then return end; local tools=Workspace:FindFirstChild("ToolsAdds"); if not tools then return end
    local currentMines={}
    for _,obj in ipairs(tools:GetChildren()) do if obj.Name:match("SubspaceTripmine") and obj:IsA("BasePart") then currentMines[obj]=true
        if not subspaceMineESPData[obj] then
            local ownerName=obj.Name:match("SubspaceTripmine(.+)") or "Unknown"
            local sel=Instance.new("SelectionBox",obj); sel.Color3=Color3.fromRGB(235,235,235); sel.LineThickness=0.05
            local bb=Instance.new("BillboardGui",obj); bb.Size=UDim2.new(0,250,0,50); bb.StudsOffset=Vector3.new(0,2.5,0); bb.AlwaysOnTop=false
            local lbl=Instance.new("TextLabel",bb); lbl.Size=UDim2.new(1,0,1,0); lbl.BackgroundTransparency=1; lbl.Text=ownerName.."'s Subspace Mine"
            lbl.TextColor3=Color3.fromRGB(235,235,235); lbl.TextStrokeTransparency=0; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=16
            subspaceMineESPData[obj]={sel=sel,bb=bb}
        end
    end end
    for mineObj,data in pairs(subspaceMineESPData) do if not currentMines[mineObj] or not mineObj.Parent then
        data.sel:Destroy(); data.bb:Destroy(); subspaceMineESPData[mineObj]=nil
    end end
end
task.spawn(function() while true do if subspaceMineESPEnabled then pcall(refreshSubspaceMineESP) end; task.wait(0.5) end end)

-- Timer ESP
local timerESPEnabled=Config.TimerESP
local function clearTimerESP()
    local plots = Workspace:FindFirstChild("Plots")
    if plots then
        for _, plot in ipairs(plots:GetChildren()) do
            for _, desc in ipairs(plot:GetDescendants()) do
                if desc.Name == "TimerESP" and desc:IsA("BillboardGui") then
                    pcall(function() desc:Destroy() end)
                end
            end
        end
    end
end
_G.clearTimerESP = clearTimerESP

local function refreshTimerESP()
    if not timerESPEnabled then
        clearTimerESP()
        return
    end
    local plots=Workspace:FindFirstChild("Plots"); if not plots then return end
    for _,plot in ipairs(plots:GetChildren()) do
        -- The game shows a timer per floor. User wants ONLY the first floor, so
        -- gather this plot's timer billboards and keep just the lowest-Y ones.
        local found = {}
        local minY = math.huge
        for _,g in ipairs(plot:GetDescendants()) do
            if g:IsA("BillboardGui") and g:FindFirstChild("RemainingTime") then
                local base=g.Adornee or g.Parent
                if base and base:IsA("BasePart") then
                    found[#found+1] = {g=g, base=base, y=base.Position.Y}
                    if base.Position.Y < minY then minY = base.Position.Y end
                end
            end
        end
        for _,item in ipairs(found) do
            local base, g = item.base, item.g
            local existing = base:FindFirstChild("TimerESP")
            if item.y <= minY + 4 then   -- first floor only
                local rt = g:FindFirstChild("RemainingTime")
                if rt then
                    if not existing then
                        local bb=Instance.new("BillboardGui"); bb.Name="TimerESP"; bb.Adornee=base; bb.Size=UDim2.new(0,98,0,26); bb.AlwaysOnTop=true; bb.StudsOffsetWorldSpace=Vector3.new(0,1.6,0)
                        local lbl=Instance.new("TextLabel",bb); lbl.Size=UDim2.new(1,0,1,0); lbl.BackgroundTransparency=1; lbl.Text=rt.Text
                        lbl.Font=Enum.Font.GothamBold; lbl.TextSize=15; lbl.TextColor3=Color3.fromRGB(255,255,255)
                        lbl.TextStrokeTransparency=0.35; lbl.TextStrokeColor3=Color3.fromRGB(0,0,0); bb.Parent=base
                    else existing.TextLabel.Text=rt.Text end
                end
            elseif existing then
                pcall(function() existing:Destroy() end)   -- not first floor -> remove
            end
        end
    end
end
task.spawn(function() while true do if timerESPEnabled then pcall(refreshTimerESP) else clearTimerESP() end; task.wait(0.5) end end)

-- ============================================================
-- Base Owner ESP  (red outline + "BASE OWNER" tag on the owner of the
-- base you are CURRENTLY standing in -- one player at a time, not all bases)
-- Wrapped in a do-block + exposed via _G so it adds no chunk-level locals.
-- ============================================================
do
    local enabled = Config.BaseOwnerESP
    local entries = {}   -- userId -> { hl = Highlight, bb = BillboardGui }

    local function destroyEntry(e)
        if not e then return end
        if e.hl then pcall(function() e.hl:Destroy() end) end
        if e.bb then pcall(function() e.bb:Destroy() end) end
    end
    local function clearAll()
        for uid, e in pairs(entries) do destroyEntry(e); entries[uid] = nil end
    end

    local function makeTag()
        local bb = Instance.new("BillboardGui")
        bb.Name = "BaseOwnerTag"
        bb.Size = UDim2.new(0, 160, 0, 34)
        bb.StudsOffsetWorldSpace = Vector3.new(0, 3.6, 0)
        bb.AlwaysOnTop = true
        bb.LightInfluence = 0
        local lbl = Instance.new("TextLabel", bb)
        lbl.Size = UDim2.fromScale(1, 1)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamBlack
        lbl.TextSize = 18
        lbl.TextColor3 = Color3.fromRGB(255, 60, 60)
        lbl.TextStrokeTransparency = 0
        lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        lbl.Text = "BASE OWNER"
        return bb
    end

    -- Highlight + tag ONLY the given player (owner of the base you're in).
    -- Passing nil clears everything.
    local function setTarget(plr)
        for uid, e in pairs(entries) do
            if not plr or uid ~= plr.UserId then destroyEntry(e); entries[uid] = nil end
        end
        if not plr or not plr.Character then return end
        local uid = plr.UserId
        local e = entries[uid]; if not e then e = {}; entries[uid] = e end
        if not e.hl or not e.hl.Parent then
            if e.hl then pcall(function() e.hl:Destroy() end) end
            local hl = Instance.new("Highlight")
            hl.Name = "BaseOwnerESP"
            hl.FillColor = Color3.fromRGB(255, 0, 0); hl.FillTransparency = 0.6
            hl.OutlineColor = Color3.fromRGB(255, 0, 0); hl.OutlineTransparency = 0
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Parent = CoreGui
            e.hl = hl
        end
        if e.hl.Adornee ~= plr.Character then e.hl.Adornee = plr.Character end
        if not e.bb or not e.bb.Parent then
            if e.bb then pcall(function() e.bb:Destroy() end) end
            e.bb = makeTag(); e.bb.Parent = CoreGui
        end
        local head = plr.Character:FindFirstChild("Head") or plr.Character:FindFirstChild("HumanoidRootPart")
        if head and e.bb.Adornee ~= head then e.bb.Adornee = head end
    end

    local function refresh()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then setTarget(nil); return end
        local plot = getPlotAtPosition(hrp.Position)
        local owner = plot and getPlotOwner(plot)
        if owner == LocalPlayer then owner = nil end   -- don't tag your own base
        setTarget(owner)
    end
    _G.setBaseOwnerESP = function(on)
        enabled = on
        Config.BaseOwnerESP = on
        saveConfig()
        setToggle("Base Owner ESP", on)
        if on then pcall(refresh) else clearAll() end
    end
    _G.clearBaseOwnerESP = clearAll
    task.spawn(function()
        while true do
            task.wait(0.5)
            if enabled then pcall(refresh) end
        end
    end)
end


-- =====================================================================
-- TEXTURE-STRIP PROTECTION  (shared by both FPS boosts)
-- ---------------------------------------------------------------------
-- GriefShieldController builds its shield out of a SurfaceAppearance and then
-- keeps parenting children into it. Once a boost destroys that instance the
-- controller is writing into something dead, and the game throws
--
--   The Parent property of 1 is locked, current parent: NULL,
--   new parent: SurfaceAppearance
--   ... ReplicatedStorage.Controllers.ItemController.GriefShieldController
--
-- on every shield tick -- "current parent: NULL" IS the destroyed instance.
--
-- Defined here, above both boost blocks, so neither can run before it exists.
-- Add substrings to _G.Skyr0TextureProtect (lowercase, matched against each
-- ancestor's name) if another controller starts complaining.
-- =====================================================================
_G.Skyr0TextureProtect = _G.Skyr0TextureProtect or {
    "griefshield", "grief shield", "grief_shield",
}
-- Belt and braces: the name guard only fires if a shield instance or one of its
-- ancestors is actually NAMED for the shield, and the controller may well name
-- them something else -- in which case the error comes straight back.
-- SurfaceAppearance is the exact class in that error, so by default it is left
-- alone entirely and only the parts underneath get flattened. Everything else
-- still goes: Decals, Textures, SpecialMesh TextureIds, particles, trails,
-- beams, lights, fire/smoke. Set false before load for the old behaviour.
if _G.Skyr0KeepSurfaceAppearance == nil then _G.Skyr0KeepSurfaceAppearance = true end
_G.Skyr0IsTextureProtected = function(obj)
    local node, depth = obj, 0
    while node and depth < 10 do
        local nm = node.Name
        if type(nm) == "string" then
            local low = nm:lower()
            for _, p in ipairs(_G.Skyr0TextureProtect) do
                if low:find(p, 1, true) then return true end
            end
        end
        node = node.Parent
        depth = depth + 1
    end
    return false
end

local setFPSBoost, setFPSBoostUltra
-- FPS BOOST (twayve.txt engine): flatten lighting + kill terrain water + strip every workspace
-- visual (particles/lights/decals/textures/shadows) so the game renders cheaply. Both old boosts
-- are fully replaced; Ultra is aliased to this single boost. Wrapped in an IIFE => 0 main-chunk regs.
-- upstream tweak: Highlights are NOT disabled, so hub ESP outlines keep working while boost is on.
;(function()
    local Light = game:GetService("Lighting")
    local Plrs = game:GetService("Players")
    local fpsConn = nil
    local function isPlrChar(m) return Plrs:GetPlayerFromCharacter(m) ~= nil end
    local function stripVisuals(obj)
        -- Grief-shield instances are off limits before any write (see the note
        -- at the destroy branch below).
        local prot = _G.Skyr0IsTextureProtected
        if prot and prot(obj) then return end
        local isMesh = obj:IsA("MeshPart")
        -- fast path: plain BasePart (the bulk of the workspace) only needs a material flatten;
        -- none of the other branches below apply, so skip the ancestor/player lookups entirely.
        if obj:IsA("BasePart") and not isMesh then
            pcall(function() obj.Material=Enum.Material.Plastic; obj.Reflectance=0; obj.CastShadow=false end)
            return
        end
        local model = obj:FindFirstAncestorOfClass("Model")   -- computed once (was called twice)
        local isPlayer = model ~= nil and isPlrChar(model)
        if obj:IsA("Animator") and not isPlayer then
            pcall(function() for _,tr in pairs(obj:GetPlayingAnimationTracks()) do tr:Stop(0) end end)
            obj.AnimationPlayed:Connect(function(tr) pcall(function() tr:Stop(0) end) end)
        end
        if (obj:IsA("Accessory") or obj:IsA("Clothing")) and model then pcall(function() obj:Destroy() end) end
        local keepBeam = obj:IsA("Beam") and (obj.Name=="PlotBeam" or obj.Name=="MeerkoBrainrotBeam")
        if not isPlayer and not keepBeam then
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then pcall(function() obj.Enabled=false end) end
            if obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then pcall(function() obj.Enabled=false; obj.Brightness=0; obj.Range=0 end); task.defer(function() pcall(function() obj:Destroy() end) end) end
            if obj:IsA("Explosion") then pcall(function() obj:Destroy() end) end
            if isMesh then pcall(function() obj.TextureID="" end) end
        end
        if isMesh then pcall(function() obj.Material=Enum.Material.Plastic; obj.Reflectance=0; obj.CastShadow=false end) end
        -- GriefShieldController keeps parenting children into the
        -- SurfaceAppearance it builds its shield from, so deleting that leaves
        -- it writing into a destroyed instance and the game throws
        --   "The Parent property of 1 is locked, current parent: NULL,
        --    new parent: SurfaceAppearance"
        -- on every shield tick. Skip anything grief-shield related, and leave
        -- SurfaceAppearance alone entirely unless explicitly re-enabled.
        if obj:IsA("SurfaceAppearance") then
            if not _G.Skyr0KeepSurfaceAppearance then pcall(function() obj:Destroy() end) end
        elseif obj:IsA("Texture") or obj:IsA("Decal") then
            pcall(function() obj:Destroy() end)
        end
    end

    -- Streamed-in objects are drained by ONE time-budgeted worker instead of a task.defer per
    -- object, so a streaming burst can't flood the scheduler with thousands of closures at once.
    local addQueue, addHead, addTail, draining = {}, 1, 0, false
    local function drainAddQueue()
        if draining then return end
        draining = true
        task.spawn(function()
            local t = os.clock()
            while addHead <= addTail do
                local obj = addQueue[addHead]; addQueue[addHead] = nil; addHead = addHead + 1
                if obj and obj.Parent then pcall(stripVisuals, obj) end
                if os.clock() - t > 0.003 then task.wait(); t = os.clock() end
            end
            addHead, addTail, draining = 1, 0, false
        end)
    end
    local function onDescAdded(obj)
        if not Config.FPSBoost then return end
        addTail = addTail + 1; addQueue[addTail] = obj
        drainAddQueue()
    end
    setFPSBoost = function(enabled)
        Config.FPSBoost = enabled; saveConfig(); pcall(setToggle, "FPS Boost (normal)", enabled)
        if fpsConn then pcall(function() fpsConn:Disconnect() end); fpsConn=nil end
        if not enabled then return end
        for _, fn in ipairs({ setfpscap, set_fps_cap }) do if type(fn)=="function" then pcall(fn, 9999) end end   -- 9999 not 0: Synapse ignores 0
        pcall(function()
            Light.ClockTime=7; Light.Brightness=2; Light.GlobalShadows=false
            Light.OutdoorAmbient=Color3.fromRGB(165,165,165)
            Light.FogEnd=9e9; Light.FogStart=0
            Light.EnvironmentDiffuseScale=0; Light.EnvironmentSpecularScale=0
            -- DISABLE, DO NOT DESTROY. This used to :Destroy() these five, and
            -- a SunRaysEffect carries the default name "SunRays" -- so the game's
            -- own client script then threw "SunRays is not a valid member of
            -- Lighting" on every access, forever. That is the identical bug
            -- cleanObject() documents for Animations a few hundred lines down
            -- ("a client spraying 'X is not a valid member of Y' is trivially
            -- flagged"), and it was still live on this path.
            -- Enabled=false costs the same as deletion for rendering: a disabled
            -- PostEffect is not evaluated. The instance simply stays referencable.
            for _,v in pairs(Light:GetChildren()) do
                if v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("BloomEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("DepthOfFieldEffect") then
                    pcall(function() v.Enabled = false end)
                end
            end
            local Terrain = workspace:FindFirstChildOfClass("Terrain")
            if Terrain then Terrain.WaterWaveSize=0; Terrain.WaterWaveSpeed=0; Terrain.WaterReflectance=0; Terrain.WaterTransparency=1 end
        end)
        -- connect the incremental handler FIRST so objects streamed during the bulk pass aren't missed
        if not fpsConn then fpsConn = workspace.DescendantAdded:Connect(onDescAdded) end
        task.spawn(function()
            -- No artificial startup wait: the strip pass begins the SAME frame the toggle fires
            -- so the boost is visible instantly. Still budgeted + yields each frame => no freeze.
            if not Config.FPSBoost then return end  -- user may have toggled off in the meantime
            local objs = workspace:GetDescendants()
            local t = os.clock()
            for i = 1, #objs do
                stripVisuals(objs[i])
                if os.clock() - t > 0.005 then task.wait(); t = os.clock() end  -- ~5ms/frame: fast apply, stays under frame budget (no spike)
            end
        end)
    end
    _G.setFPSBoost = setFPSBoost
end)()

-- =====================================================================
-- TEXTURE REMOVER / FPS BOOST ULTRA  (hub_Mata's version)
-- ---------------------------------------------------------------------
-- Ultra used to be `setFPSBoostUltra = setFPSBoost` -- an alias, so the toggle
-- existed but did nothing beyond the normal boost. This is hub_Mata's real one.
--
-- Over the normal boost it adds: SpecialMesh TextureId cleared, MaterialService
-- entries destroyed as they appear, PostEffect/Atmosphere/Clouds killed on
-- arrival, a blank grey skybox, terrain water flattened, non-player Animators
-- stopped, and a per-character clean on spawn. Clothing/accessories are removed
-- through the same class list the accessory remover uses.
--
-- Two deliberate departures from hub_Mata, both for things it documents as
-- broken there:
--   * IsOutOfRange deletion stays OFF. hub_Mata disabled it too -- it deleted
--     game event models (PhantomSpinWheel.Main) and the game's own controller
--     then errored every frame.
--   * MakeTransparentUltra (hiding baseplates) is NOT ported: that is the X-ray
--     feature here, it has its own toggle and its own transparency bookkeeping,
--     and having two systems write the same property fights.
--
-- Exposed as _G.Skyr0RemoveTextures(true/false) as well as the Ultra toggle.
-- Wrapped in an IIFE => 0 main-chunk registers.
-- =====================================================================
;(function()
    local Players   = game:GetService("Players")
    local Lighting  = game:GetService("Lighting")
    local WS        = workspace
    local conns, threads = {}, {}

    local function addConn(c) table.insert(conns, c) end

    -- Grief-shield guard lives above both boosts (see the note there).
    local isProtected = _G.Skyr0IsTextureProtected

    local function safeDestroy(obj)
        if obj.Name == "Overhead" then return end
        if isProtected(obj) then return end
        if _G.Skyr0KeepSurfaceAppearance and obj:IsA("SurfaceAppearance") then return end
        pcall(function() obj:Destroy() end)
    end

    local CLOTHING = {
        "Shirt", "Pants", "ShirtGraphic",
        "Accessory", "Hat", "HairAccessory",
        "FaceAccessory", "NeckAccessory", "ShoulderAccessory",
        "FrontAccessory", "BackAccessory", "WaistAccessory",
    }
    local function isClothing(obj)
        for _, c in ipairs(CLOTHING) do if obj:IsA(c) then return true end end
        return false
    end
    local function isCharacterPart(obj)
        local parent = obj.Parent
        while parent and parent ~= WS do
            if parent:IsA("Model") and Players:GetPlayerFromCharacter(parent) then return true end
            parent = parent.Parent
        end
        return false
    end

    local function stripObject(obj)
        if isProtected(obj) then return end
        pcall(function()
            if obj:IsA("SpecialMesh") then
                -- Clear the texture, do NOT delete the mesh. Destroying a
                -- SpecialMesh changes the part's shape and breaks any script
                -- holding it -- same failure mode as GriefShieldController.
                -- cleanObject already does exactly this; stripObject deleting it
                -- was the inconsistency.
                pcall(function() obj.TextureId = "" end)
            elseif obj:IsA("Texture") or obj:IsA("Decal") then
                safeDestroy(obj)
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam")
                or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
                pcall(function() obj.Enabled = false end)
                safeDestroy(obj)
            elseif obj:IsA("SurfaceAppearance") then
                safeDestroy(obj)
            elseif obj:IsA("BasePart") then
                obj.CastShadow      = false
                obj.Material        = Enum.Material.Plastic
                obj.MaterialVariant = ""
                obj.Reflectance     = 0
            end
        end)
    end

    local function cleanObject(obj)
        if isProtected(obj) then return end
        pcall(function()
            if obj:IsA("SurfaceAppearance") then
                safeDestroy(obj)
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                -- the head face is the one decal worth keeping
                if not (obj.Name == "face" and obj.Parent and obj.Parent.Name == "Head") then
                    safeDestroy(obj)
                end
            elseif obj:IsA("SpecialMesh") then
                obj.TextureId = ""
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
                safeDestroy(obj)
            elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
                safeDestroy(obj)
            elseif obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") or obj:IsA("Explosion") then
                safeDestroy(obj)
            elseif obj:IsA("Animation") or obj:IsA("AnimationController") then
                -- LEFT ALONE. hub_Mata destroys these, and it is the exact same
                -- bug as GriefShieldController: game scripts hold references to
                -- their Animations and AnimationControllers, so deleting them
                -- makes the game's own code throw on every use. Those errors are
                -- a louder signal than any hook -- a client spraying
                -- "X is not a valid member of Y" is trivially flagged.
                -- Non-player animation is already silenced by stopAnimations().
            elseif obj:IsA("BasePart") then
                obj.CastShadow      = false
                obj.Material        = Enum.Material.Plastic
                obj.MaterialVariant = ""
                obj.Reflectance     = 0
            end
        end)
    end

    local function stopAnimations(animator)
        pcall(function()
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                local isChar = false
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr.Character and animator:IsDescendantOf(plr.Character) then
                        isChar = true; break
                    end
                end
                if not isChar then track:Stop() end
            end
        end)
    end

    local function optimizeCharacter(char)
        if not char then return end
        table.insert(threads, task.spawn(function()
            task.wait(0.3)
            for _, obj in ipairs(char:GetDescendants()) do
                if isClothing(obj) then safeDestroy(obj) else cleanObject(obj) end
            end
        end))
    end

    local function applyGreySky()
        pcall(function()
            for _, obj in ipairs(Lighting:GetChildren()) do
                if obj:IsA("Sky") then obj:Destroy() end
            end
            local sky = Instance.new("Sky")
            sky.SkyboxBk, sky.SkyboxDn, sky.SkyboxFt = "", "", ""
            sky.SkyboxLf, sky.SkyboxRt, sky.SkyboxUp = "", "", ""
            sky.CelestialBodiesShown = false
            sky.Parent = Lighting
        end)
    end

    local function optimizeLighting()
        pcall(function()
            Lighting.GlobalShadows            = false
            Lighting.FogEnd                   = 9e9
            Lighting.FogStart                 = 9e9
            Lighting.EnvironmentDiffuseScale  = 0
            Lighting.EnvironmentSpecularScale = 0
            Lighting.Brightness               = 1.5
            Lighting.Ambient                  = Color3.fromRGB(60, 60, 60)
            for _, v in ipairs(Lighting:GetChildren()) do
                if v:IsA("PostEffect") then
                    pcall(function() v.Enabled = false end)
                elseif v:IsA("Atmosphere") or v:IsA("Clouds") then
                    v:Destroy()
                end
            end
        end)
        applyGreySky()
    end

    local function applyTerrain()
        pcall(function()
            local T = WS.Terrain
            T.Decoration        = false
            T.WaterWaveSize     = 0
            T.WaterWaveSpeed    = 0
            T.WaterReflectance  = 0
            T.WaterTransparency = 1
        end)
    end

    local function handle(obj)
        -- Bail before ANY write, not just before destroys: flattening the
        -- material or clearing a TextureId on a shield instance upsets its
        -- controller the same way deleting it does.
        if isProtected(obj) then return end
        if isClothing(obj) then
            safeDestroy(obj)
        elseif isCharacterPart(obj) then
            -- skip: characters are handled by optimizeCharacter
        else
            cleanObject(obj)
            stripObject(obj)
            if obj:IsA("Animator") then stopAnimations(obj) end
        end
    end

    setFPSBoostUltra = function(enabled)
        Config.FPSBoostUltra = enabled
        saveConfig()
        pcall(setToggle, "FPS Boost Ultra", enabled)

        if not enabled then
            for _, conn in ipairs(conns) do
                if typeof(conn) == "RBXScriptConnection" then pcall(function() conn:Disconnect() end) end
            end
            conns = {}
            for _, thr in ipairs(threads) do pcall(function() task.cancel(thr) end) end
            threads = {}
            return
        end

        pcall(function()
            settings().Rendering.QualityLevel        = Enum.QualityLevel.Level01
            settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
            settings().Physics.AllowSleep = true
        end)
        for _, fn in ipairs({ setfpscap, set_fps_cap }) do
            if type(fn) == "function" then pcall(fn, 9999) end
        end

        optimizeLighting()
        applyTerrain()

        -- Incremental handler FIRST so anything streamed during the bulk pass
        -- is not missed.
        addConn(WS.DescendantAdded:Connect(function(obj)
            task.defer(function()
                if not Config.FPSBoostUltra then return end
                if obj.Parent then pcall(handle, obj) end
            end)
        end))
        addConn(Lighting.DescendantAdded:Connect(function(obj)
            if obj:IsA("PostEffect") then
                pcall(function() obj.Enabled = false end)
            elseif obj:IsA("Atmosphere") or obj:IsA("Clouds") then
                safeDestroy(obj)
            end
        end))
        pcall(function()
            local MaterialService = game:GetService("MaterialService")
            addConn(MaterialService.DescendantAdded:Connect(safeDestroy))
        end)

        for _, plr in ipairs(Players:GetPlayers()) do
            optimizeCharacter(plr.Character)
            addConn(plr.CharacterAdded:Connect(optimizeCharacter))
        end
        addConn(Players.PlayerAdded:Connect(function(plr)
            addConn(plr.CharacterAdded:Connect(optimizeCharacter))
        end))

        -- Bulk pass, batched so a big workspace cannot freeze the frame.
        table.insert(threads, task.spawn(function()
            local allDesc = WS:GetDescendants()
            local BATCH = 200
            for i = 1, #allDesc, BATCH do
                if not Config.FPSBoostUltra then return end
                local last = math.min(i + BATCH - 1, #allDesc)
                for j = i, last do
                    local obj = allDesc[j]
                    if obj and obj.Parent then pcall(handle, obj) end
                end
                if last < #allDesc then task.wait() end
            end
        end))
    end

    _G.Skyr0RemoveTextures = function(v) setFPSBoostUltra(v ~= false) end
    _G.setFPSBoostUltra = setFPSBoostUltra
end)()

-- ============================================================
-- X-RAY
-- ============================================================
local setXRay
do -- X-RAY SCOPE
local xrayOriginalTransparencies = setmetatable({}, {__mode = "k"})
local xrayConnections = {}
local xrayLoopId = 0

local function setXRayTargetTransparency(instance, alphaPercent, loopId)
    if not instance then return end
    if loopId and loopId ~= xrayLoopId then return end   -- X-ray already turned off

    local function apply(obj)
        if obj:IsA("BasePart") then
            if xrayOriginalTransparencies[obj] == nil then
                if obj.Transparency == alphaPercent then xrayOriginalTransparencies[obj] = 0
                else xrayOriginalTransparencies[obj] = obj.Transparency end
            end
            local orig = xrayOriginalTransparencies[obj]
            if orig < 1 then
                local target = orig + (1 - orig) * alphaPercent
                if math.abs(obj.Transparency - target) > 0.01 then obj.Transparency = target end
            end
        elseif obj:IsA("TextLabel") or obj:IsA("TextButton") then
            if xrayOriginalTransparencies[obj] == nil then
                local t, b = obj.TextTransparency, obj.BackgroundTransparency
                if t == alphaPercent then t = 0 end
                if b == alphaPercent then b = 0 end
                xrayOriginalTransparencies[obj] = {text = t, bg = b}
            end
            local orig = xrayOriginalTransparencies[obj]
            if orig.text < 1 then
                local targetText = orig.text + (1 - orig.text) * alphaPercent
                if math.abs(obj.TextTransparency - targetText) > 0.01 then obj.TextTransparency = targetText end
            end
            if orig.bg < 1 then
                local targetBg = orig.bg + (1 - orig.bg) * alphaPercent
                if math.abs(obj.BackgroundTransparency - targetBg) > 0.01 then obj.BackgroundTransparency = targetBg end
            end
        elseif obj:IsA("Frame") or obj:IsA("ScrollingFrame") then
            if xrayOriginalTransparencies[obj] == nil then
                if obj.BackgroundTransparency == alphaPercent then xrayOriginalTransparencies[obj] = 0
                else xrayOriginalTransparencies[obj] = obj.BackgroundTransparency end
            end
            local orig = xrayOriginalTransparencies[obj]
            if orig < 1 then
                local target = orig + (1 - orig) * alphaPercent
                if math.abs(obj.BackgroundTransparency - target) > 0.01 then obj.BackgroundTransparency = target end
            end
        elseif obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
            if xrayOriginalTransparencies[obj] == nil then
                local i, b = obj.ImageTransparency, obj.BackgroundTransparency
                if i == alphaPercent then i = 0 end
                if b == alphaPercent then b = 0 end
                xrayOriginalTransparencies[obj] = {img = i, bg = b}
            end
            local orig = xrayOriginalTransparencies[obj]
            if orig.img < 1 then
                local targetImg = orig.img + (1 - orig.img) * alphaPercent
                if math.abs(obj.ImageTransparency - targetImg) > 0.01 then obj.ImageTransparency = targetImg end
            end
            if orig.bg < 1 then
                local targetBg = orig.bg + (1 - orig.bg) * alphaPercent
                if math.abs(obj.BackgroundTransparency - targetBg) > 0.01 then obj.BackgroundTransparency = targetBg end
            end
        end
    end

    apply(instance)
    local descendants = instance:GetDescendants()
    for i, child in ipairs(descendants) do
        apply(child)
        if i % 300 == 0 then
            task.wait()
            if loopId and loopId ~= xrayLoopId then return end   -- aborted: X-ray turned off mid-apply
        end
    end
end

local XRAY_FOLDERS = {"Base","PlotSign","FriendPanel","Cash","Laser","Decorations","Skin","Unlock","Purchases"}

-- X-ray a subtree once, then keep newly-streamed parts x-rayed via a cheap
-- DescendantAdded hook. Event-driven -> ZERO cost while nothing changes
-- (replaces the old 1.5s full re-walk that caused the lag).
local function trackXRaySubtree(root, alphaPercent, loopId)
    if not root then return end
    if loopId ~= xrayLoopId then return end
    setXRayTargetTransparency(root, alphaPercent, loopId)
    if loopId ~= xrayLoopId then return end   -- don't re-arm a listener after X-ray was turned off
    xrayConnections[#xrayConnections+1] = root.DescendantAdded:Connect(function(obj)
        if loopId ~= xrayLoopId then return end
        setXRayTargetTransparency(obj, alphaPercent, loopId)
    end)
end

local function processPlotXRay(plot, alphaPercent, loopId)
    if not plot then return end
    if loopId ~= xrayLoopId then return end

    for _, fname in ipairs(XRAY_FOLDERS) do
        if loopId ~= xrayLoopId then return end
        trackXRaySubtree(plot:FindFirstChild(fname), alphaPercent, loopId)
    end
    if loopId ~= xrayLoopId then return end
    -- target folders that stream in after enable
    xrayConnections[#xrayConnections+1] = plot.ChildAdded:Connect(function(child)
        if loopId ~= xrayLoopId then return end
        for _, fname in ipairs(XRAY_FOLDERS) do
            if child.Name == fname then trackXRaySubtree(child, alphaPercent, loopId); break end
        end
    end)

    local animalPodiums = plot:FindFirstChild("AnimalPodiums")
    if animalPodiums then
        local function processPodium(podium)
            for _, child in ipairs(podium:GetChildren()) do
                if child.Name == "Claim" then
                    trackXRaySubtree(child, alphaPercent, loopId)
                elseif child.Name == "Base" then
                    trackXRaySubtree(child:FindFirstChild("Decorations"), alphaPercent, loopId)
                elseif child:IsA("Model") and child.Name ~= "Decorations" then
                    trackXRaySubtree(child, alphaPercent, loopId)
                end
            end
        end
        for _, podium in ipairs(animalPodiums:GetChildren()) do processPodium(podium) end
        xrayConnections[#xrayConnections+1] = animalPodiums.ChildAdded:Connect(function(podium)
            if loopId ~= xrayLoopId then return end
            task.wait(0.1)
            if loopId ~= xrayLoopId then return end
            processPodium(podium)
        end)
    end
end

local function applyTransparencyToAllPlotsXRay(alphaPercent, loopId)
    local plotsFolder = Workspace:FindFirstChild("Plots")
    if not plotsFolder then return end

    for _, plot in ipairs(plotsFolder:GetChildren()) do
        if loopId ~= xrayLoopId then return end
        processPlotXRay(plot, alphaPercent, loopId)
        task.wait()
    end
    -- new bases joining later
    xrayConnections[#xrayConnections+1] = plotsFolder.ChildAdded:Connect(function(plot)
        if loopId ~= xrayLoopId then return end
        task.wait(0.2)
        processPlotXRay(plot, alphaPercent, loopId)
    end)
end

function setXRay(enabled)
    Config.XRay = enabled
    saveConfig()
    setToggle("XRay", enabled)
    setToggle("X-Ray", enabled)
    setToggle("Xray", enabled)

    -- Clean up previous connections
    for _, conn in ipairs(xrayConnections) do
        if typeof(conn) == "RBXScriptConnection" then
            conn:Disconnect()
        end
    end
    xrayConnections = {}

    xrayLoopId = xrayLoopId + 1
    local currentLoopId = xrayLoopId

    if enabled then
        local alphaPercent = 0.5
        
        task.spawn(function()
            -- Asteptam sa se incarce folder-ul Plots
            while currentLoopId == xrayLoopId and not Workspace:FindFirstChild("Plots") do
                task.wait(0.5)
            end
            
            if currentLoopId ~= xrayLoopId then return end
            
            -- Initial call cu un mic delay sa dam timp primelor modele sa apara
            if currentLoopId ~= xrayLoopId then return end
            pcall(applyTransparencyToAllPlotsXRay, alphaPercent, currentLoopId)
            
            -- Loop continuu si super-optimizat (fara overlap de thread-uri)
            -- (perpetual 1.5s re-walk removed; upkeep is now event-driven)
        end)
    else
        -- Turn OFF instantly AND completely: swap the snapshot out atomically, then
        -- restore every captured original in ONE synchronous pass (no task.wait
        -- yields). This removes the old race where a restore could overlap a
        -- re-enable and leave some parts still see-through after toggling off.
        local snapshot = xrayOriginalTransparencies
        xrayOriginalTransparencies = setmetatable({}, {__mode = "k"})
        for obj, orig in pairs(snapshot) do
            pcall(function()
                if obj:IsA("BasePart") then
                    obj.Transparency = orig
                elseif obj:IsA("TextLabel") or obj:IsA("TextButton") then
                    obj.TextTransparency = orig.text
                    obj.BackgroundTransparency = orig.bg
                elseif obj:IsA("Frame") or obj:IsA("ScrollingFrame") then
                    obj.BackgroundTransparency = orig
                elseif obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
                    obj.ImageTransparency = orig.img
                    obj.BackgroundTransparency = orig.bg
                end
            end)
        end
        -- User setting: X-ray OFF forces bases solid even when FPS Boost Ultra hid
        -- them. FPS Boost Ultra records each base's true transparency before hiding
        -- it, so re-apply those originals here -> hidden bases become visible again.
        for part, data in pairs(OriginalTransparency) do
            if part and part.Parent and typeof(data) == "table" then
                pcall(function() part.Transparency = data.trans end)
            end
        end
    end
end

_G.setXRay = setXRay
end -- END X-RAY SCOPE


-- ============================================================
-- ANTI BEE & DISCO
-- ============================================================
SharedState.ANTI_BEE_DISCO = {
    running = false,
    connections = {},
    originalMoveFunction = nil,
    controlsProtected = false,
    badLightingNames = { Blue = true, DiscoEffect = true, BeeBlur = true, ColorCorrection = true },
}
SharedState.ANTI_BEE_DISCO.nuke = function(obj)
    if not obj or not obj.Parent then return end
    if SharedState.ANTI_BEE_DISCO.badLightingNames[obj.Name] then
        pcall(function() obj:Destroy() end)
    end
end
SharedState.ANTI_BEE_DISCO.disconnectAll = function()
    for _, conn in ipairs(SharedState.ANTI_BEE_DISCO.connections) do
        if typeof(conn) == "RBXScriptConnection" then conn:Disconnect() end
    end
    SharedState.ANTI_BEE_DISCO.connections = {}
end
SharedState.ANTI_BEE_DISCO.protectControls = function()
    if SharedState.ANTI_BEE_DISCO.controlsProtected then return end
    pcall(function()
        local PlayerScripts = LocalPlayer.PlayerScripts
        local PlayerModule = PlayerScripts:FindFirstChild("PlayerModule")
        if not PlayerModule then return end
        local Controls = require(PlayerModule):GetControls()
        if not Controls then return end
        local ab = SharedState.ANTI_BEE_DISCO
        if not ab.originalMoveFunction then ab.originalMoveFunction = Controls.moveFunction end
        local function protectedMoveFunction(self, moveVector, relativeToCamera)
            if ab.originalMoveFunction then ab.originalMoveFunction(self, moveVector, relativeToCamera) end
        end
        table.insert(ab.connections, RunService.Heartbeat:Connect(function()
            if not ab.running or not Config.AntiBeeDisco then return end
            if _G.Skyr0IsTpBusy and _G.Skyr0IsTpBusy() then return end
            if Controls.moveFunction ~= protectedMoveFunction then Controls.moveFunction = protectedMoveFunction end
        end))
        Controls.moveFunction = protectedMoveFunction
        ab.controlsProtected = true
    end)
end
SharedState.ANTI_BEE_DISCO.restoreControls = function()
    if not SharedState.ANTI_BEE_DISCO.controlsProtected then return end
    pcall(function()
        local PlayerModule = LocalPlayer.PlayerScripts:FindFirstChild("PlayerModule")
        if not PlayerModule then return end
        local Controls = require(PlayerModule):GetControls()
        local ab = SharedState.ANTI_BEE_DISCO
        if Controls and ab.originalMoveFunction then
            Controls.moveFunction = ab.originalMoveFunction
            ab.controlsProtected = false
        end
    end)
end
SharedState.ANTI_BEE_DISCO.blockBuzzingSound = function()
    pcall(function()
        local beeScript = LocalPlayer.PlayerScripts:FindFirstChild("Bee", true)
        if beeScript then
            local buzzing = beeScript:FindFirstChild("Buzzing")
            if buzzing and buzzing:IsA("Sound") then
                buzzing:Stop()
                buzzing.Volume = 0
            end
        end
    end)
end
SharedState.ANTI_BEE_DISCO.Enable = function()
    local ab = SharedState.ANTI_BEE_DISCO
    if ab.running then return end
    ab.running = true
    for _, inst in ipairs(Lighting:GetDescendants()) do ab.nuke(inst) end
    table.insert(ab.connections, Lighting.DescendantAdded:Connect(function(obj)
        if not ab.running or not Config.AntiBeeDisco then return end
        ab.nuke(obj)
    end))
    ab.protectControls()
    table.insert(ab.connections, RunService.Heartbeat:Connect(function()
        if not ab.running or not Config.AntiBeeDisco then return end
        ab.blockBuzzingSound()
    end))
    ShowNotification("ANTIBEE & DISCO", "Enabled")
end
SharedState.ANTI_BEE_DISCO.Disable = function()
    local ab = SharedState.ANTI_BEE_DISCO
    if not ab.running then return end
    ab.running = false
    ab.restoreControls()
    ab.disconnectAll()
    ShowNotification("ANTI-BEE & DISCO", "Disabled")
end
_G.ANTI_BEE_DISCO = SharedState.ANTI_BEE_DISCO
if Config.AntiBeeDisco then
    task.delay(1, function()
        if SharedState.ANTI_BEE_DISCO.Enable then SharedState.ANTI_BEE_DISCO.Enable() end
    end)
end


-- =====================================================================
-- FACE AWAY  --  ported from Heresy Free.txt
-- ---------------------------------------------------------------------
-- While you are STEALING, turn your character's back to the player who is
-- most likely to be watching -- by default the owner of the base you are
-- standing in, or the nearest player if "Face Nearest" is on -- and mark that
-- player with a highlight + distance tag so you can see who is being faced
-- away from.
--
-- Faithful to Heresy's logic:
--   * the target is re-resolved at most 4x a second (fa.ultimoAlvo), not every
--     frame -- resolving it walks the player list;
--   * while stealing, the BASE OWNER target is LATCHED (fa.travado): the owner
--     walking out of the base mid-steal must not make you spin to face someone
--     else halfway through;
--   * Humanoid.AutoRotate is saved and switched off while turning, and
--     RESTORED the moment the steal ends or the feature is turned off -- if it
--     is not restored your character can never turn again;
--   * the turn is a flat (Y-only) look-at AWAY from the target, so it cannot
--     tilt the character.
--
-- Wrapped in a function, exactly like the auto-buy scope above, so its locals
-- get their own Luau register budget instead of the main chunk's.
--
-- NOT carried over: Heresy's separate "Panel Face Away" player picker (its own
-- themed window with avatars and per-player rows). The two modes it selected
-- between are here as toggles; a specific player can still be targeted by
-- setting Config.FaceAwayModo = "player" and Config.FaceAwayAlvo = "<Name>",
-- which alvoAtual() below honours.
-- =====================================================================
local function _initFaceAwayScope()
    local Plrs = Players
    local eu   = LocalPlayer
    local fa   = { roubando = false, travado = nil, autoRot = nil, conn = nil,
                   ultimoAlvo = 0, alvoCache = nil }
    local mkFolder, mkHL, mkBB, mkLabel, mkAlvo
    -- panel handles (built lazily -- see construirPainel)
    local painel, corpo, pAvatar, pNome, pModo, pDist, pBarra
    local linhas, ultimoPaint = {}, 0

    local function hrpDe(p)
        local c = p and p.Character
        return c and c:FindFirstChild("HumanoidRootPart") or nil
    end

    local function donoDaBase()
        local fn = _G.__getCurrentBaseOwnerId
        if type(fn) ~= "function" then return nil end
        local ok, id = pcall(fn)
        if ok and id then
            local p = Plrs:GetPlayerByUserId(id)
            if p and p ~= eu then return p end
        end
        return nil
    end

    local function maisProximo()
        local meu = hrpDe(eu); if not meu then return nil end
        local best, bd = nil, math.huge
        for _, p in ipairs(Plrs:GetPlayers()) do
            if p ~= eu then
                local h = hrpDe(p)
                if h then
                    local d = (h.Position - meu.Position).Magnitude
                    if d < bd then bd, best = d, p end
                end
            end
        end
        return best
    end

    local function alvoAtual()
        local m = Config.FaceAwayModo or "baseowner"
        if m == "nearest" then return maisProximo() end
        if m == "player" then
            return Config.FaceAwayAlvo and Plrs:FindFirstChild(Config.FaceAwayAlvo) or nil
        end
        -- base owner, latched for the duration of a steal
        if fa.roubando then
            if fa.travado and fa.travado.Parent then return fa.travado end
            local d = donoDaBase()
            if d then fa.travado = d; return d end
            return nil
        end
        return donoDaBase()
    end

    -- The marker lives under CurrentCamera, not the character: it survives a
    -- respawn and is never replicated.
    local function marcaGarantir()
        local cam = workspace.CurrentCamera; if not cam then return false end
        if mkFolder and mkFolder.Parent == cam then return true end
        if mkFolder then pcall(function() mkFolder:Destroy() end) end
        mkFolder = Instance.new("Folder"); mkFolder.Name = "Skyr0FaceAway"; mkFolder.Parent = cam
        mkHL = Instance.new("Highlight")
        mkHL.FillColor = Color3.fromRGB(255,90,90); mkHL.FillTransparency = 0.72
        mkHL.OutlineColor = Color3.fromRGB(255,60,60)
        mkHL.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        mkHL.Enabled = false; mkHL.Parent = mkFolder
        mkBB = Instance.new("BillboardGui")
        mkBB.Size = UDim2.fromOffset(210,20); mkBB.StudsOffset = Vector3.new(0,3.2,0)
        mkBB.AlwaysOnTop = true; mkBB.Enabled = false; mkBB.Parent = mkFolder
        mkLabel = Instance.new("TextLabel")
        mkLabel.Size = UDim2.fromScale(1,1); mkLabel.BackgroundTransparency = 1
        mkLabel.Font = Enum.Font.GothamBold; mkLabel.TextSize = 12
        mkLabel.TextColor3 = Color3.fromRGB(255,235,235)
        mkLabel.TextStrokeTransparency = 0.35; mkLabel.Parent = mkBB
        mkAlvo = nil
        return true
    end

    local function marcaLimpar()
        if mkHL then mkHL.Enabled = false end
        if mkBB then mkBB.Enabled = false end
        mkAlvo = nil
    end

    local function marcaAtualizar(p, dist)
        if not p or not Config.FaceAway then marcaLimpar(); return end
        if not marcaGarantir() then return end
        local char = p.Character
        if not char then marcaLimpar(); return end
        if mkAlvo ~= p or mkHL.Adornee ~= char then
            mkAlvo = p; mkHL.Adornee = char
            mkBB.Adornee = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
        end
        mkHL.Enabled = true
        mkBB.Enabled = mkBB.Adornee ~= nil
        if mkLabel then
            local t = (fa.roubando and "FACING AWAY  " or "TARGET  ") .. (dist or 0) .. "m"
            if mkLabel.Text ~= t then mkLabel.Text = t end
        end
    end

    local function soltarRotacao()
        local c = eu.Character
        local hum = c and c:FindFirstChildOfClass("Humanoid")
        if hum and fa.autoRot ~= nil then
            pcall(function() hum.AutoRotate = fa.autoRot end)
        end
        fa.autoRot = nil
    end

    local function virarDeCostas(pos)
        local c = eu.Character; if not c then return false end
        local hrp = c:FindFirstChild("HumanoidRootPart")
        local hum = c:FindFirstChildOfClass("Humanoid")
        if not hrp then return false end
        if hum and fa.autoRot == nil then
            fa.autoRot = hum.AutoRotate
            pcall(function() hum.AutoRotate = false end)
        end
        local meu = hrp.Position
        local dir = pos - meu
        dir = Vector3.new(dir.X, 0, dir.Z)
        if dir.Magnitude < 0.05 then return false end
        dir = dir.Unit
        hrp.CFrame = CFrame.lookAt(meu, meu - dir * 10)
        return true
    end

    -- =================================================================
    -- FACE AWAY PANEL  --  Heresy's picker, rebuilt in the hub's own style.
    -- -----------------------------------------------------------------
    -- Heresy's version was its own window with its own look and Portuguese
    -- labels. This is the same panel -- a status card over a radio list of
    -- Base owner / Nearest player / every player on the server -- built out of
    -- the hub's makeQuickPanel and Theme, so it sits next to Steal Target and
    -- Actions as though it always belonged there: same 6px rows, same accent
    -- stroke on the selected entry, same ON-pill colours as the Steal Panel.
    --
    -- Built LAZILY. This whole scope runs early (long before makeQuickPanel
    -- exists), so the panel is created the first time Face Away is switched on
    -- -- by which point the UI is up. If the UI somehow is not ready, the
    -- feature still runs; it just has no window.
    -- =================================================================
    local function pintarSelecao()
        local m = Config.FaceAwayModo or "baseowner"
        for _, r in ipairs(linhas) do
            local sel
            if r.kind == "player" then
                sel = (m == "player" and Config.FaceAwayAlvo == r.playerName)
            else
                sel = (m == r.kind)
            end
            r.dot.BackgroundTransparency   = sel and 0 or 1
            r.stroke.Color                 = sel and Theme.Accent or Theme.Stroke
            r.stroke.Transparency          = sel and 0.1 or 0.62
            r.frame.BackgroundTransparency = sel and 0.15 or 0.45
        end
    end

    local function escolher(kind, playerName)
        Config.FaceAwayModo    = kind
        Config.FaceAwayAlvo    = playerName
        Config.FaceAwayNearest = (kind == "nearest")
        pcall(setToggle, "Face Nearest", Config.FaceAwayNearest)
        fa.travado   = nil
        fa.alvoCache = nil
        marcaLimpar()
        pintarSelecao()
        pcall(saveConfig)
    end

    -- One row = the hub's Steal Target row, minus the rank box: avatar (or a
    -- colour chip for the two automatic modes), title, sub-line, radio dot.
    local function novaLinha(o)
        local f = Instance.new("Frame")
        f.Size = UDim2.new(1, -4, 0, 40)
        f.BackgroundColor3 = Theme.Panel
        f.BackgroundTransparency = 0.45
        f.Parent = corpo
        corner(f, 6)
        local st = stroke(f, Theme.Stroke, 1.25, 0.62)

        local holder = Instance.new("Frame")
        holder.Size = UDim2.fromOffset(26, 26)
        holder.Position = UDim2.new(0, 8, 0.5, -13)
        holder.BackgroundColor3 = o.cor or Theme.SoftAccent
        holder.BackgroundTransparency = o.foto and 0.35 or 0
        holder.BorderSizePixel = 0
        holder.Parent = f
        corner(holder, 13)
        if o.foto then
            local ic = Instance.new("ImageLabel")
            ic.Size = UDim2.new(1, -2, 1, -2)
            ic.Position = UDim2.fromOffset(1, 1)
            ic.BackgroundTransparency = 1
            ic.Image = "rbxthumb://type=AvatarHeadShot&id=" .. o.foto .. "&w=48&h=48"
            ic.Parent = holder
            corner(ic, 12)
        end

        local t = Instance.new("TextLabel")
        t.Size = UDim2.new(1, -78, 0, 15)
        t.Position = UDim2.new(0, 42, 0, 6)
        t.BackgroundTransparency = 1
        t.Text = o.titulo
        t.TextColor3 = Theme.Text
        t.Font = Enum.Font.GothamBold
        t.TextSize = 12
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.TextTruncate = Enum.TextTruncate.AtEnd
        t.Parent = f

        local s = Instance.new("TextLabel")
        s.Size = UDim2.new(1, -78, 0, 13)
        s.Position = UDim2.new(0, 42, 0, 21)
        s.BackgroundTransparency = 1
        s.Text = o.sub or ""
        s.TextColor3 = Theme.Dim
        s.Font = Enum.Font.GothamMedium
        s.TextSize = 10
        s.TextXAlignment = Enum.TextXAlignment.Left
        s.TextTruncate = Enum.TextTruncate.AtEnd
        s.Parent = f

        local radio = Instance.new("Frame")
        radio.Size = UDim2.fromOffset(15, 15)
        radio.AnchorPoint = Vector2.new(1, 0.5)
        radio.Position = UDim2.new(1, -10, 0.5, 0)
        radio.BackgroundTransparency = 1
        radio.Parent = f
        corner(radio, 8)
        stroke(radio, Theme.AccentLight, 1.4, 0.35)
        local dot = Instance.new("Frame")
        dot.Size = UDim2.fromOffset(7, 7)
        dot.AnchorPoint = Vector2.new(0.5, 0.5)
        dot.Position = UDim2.fromScale(0.5, 0.5)
        dot.BackgroundColor3 = Theme.Accent
        dot.BackgroundTransparency = 1
        dot.BorderSizePixel = 0
        dot.Parent = radio
        corner(dot, 4)

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.fromScale(1, 1)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.ZIndex = 8
        btn.Parent = f
        -- bindPress, so the row answers to a finger the same way every other row
        -- in this hub does. It has to come through _G.Skyr0BindPress: bindPress
        -- itself is a LOCAL declared further down the file, so this scope -- which
        -- is compiled above it -- would only see a nil global. MouseButton1Click
        -- is the fallback for the case where the UI has not exported it yet.
        local _bp = _G.Skyr0BindPress
        if _bp then _bp(btn, function() escolher(o.kind, o.playerName) end)
        else btn.MouseButton1Click:Connect(function() escolher(o.kind, o.playerName) end) end

        linhas[#linhas + 1] = { frame = f, dot = dot, stroke = st,
                                kind = o.kind, playerName = o.playerName }
    end

    local function reconstruirLista()
        if not corpo then return end
        for _, r in ipairs(linhas) do pcall(function() r.frame:Destroy() end) end
        table.clear(linhas)
        novaLinha({ kind = "baseowner", titulo = "Base Owner",
                    sub = "whoever owns the base you are in",
                    cor = Color3.fromRGB(232, 72, 72) })
        novaLinha({ kind = "nearest", titulo = "Nearest Player",
                    sub = "re-picks the closest, live",
                    cor = Color3.fromRGB(86, 142, 245) })
        local outros = {}
        for _, p in ipairs(Plrs:GetPlayers()) do
            if p ~= eu then outros[#outros + 1] = p end
        end
        table.sort(outros, function(a, b)
            return a.DisplayName:lower() < b.DisplayName:lower()
        end)
        for _, p in ipairs(outros) do
            novaLinha({ kind = "player", titulo = p.DisplayName, sub = "@" .. p.Name,
                        foto = p.UserId, playerName = p.Name })
        end
        pintarSelecao()
    end

    local function construirPainel()
        if painel then return true end
        if not (makeQuickPanel and panels and Theme) then return false end
        local okp = pcall(function()
            painel, corpo = makeQuickPanel("PingHub\nFace Away",
                UDim2.new(0, 300, 0, 360), UDim2.new(1, -640, 0, 85))
        end)
        if not okp or not painel then painel = nil; return false end
        -- registered so the UI tab's visibility list and the theme pass see it
        panels["Face Away"]     = painel
        panels["FaceAwayBody"]  = corpo

        -- status card: same shape as the Steal Target rows, one size up
        local caixa = Instance.new("Frame")
        caixa.Size = UDim2.new(1, -4, 0, 88)
        caixa.BackgroundColor3 = Theme.Panel
        caixa.BackgroundTransparency = 0.3
        caixa.Parent = corpo
        corner(caixa, 6)
        stroke(caixa, Theme.AccentLight, 1.25, 0.35)

        pAvatar = Instance.new("ImageLabel")
        pAvatar.Size = UDim2.new(0, 46, 0, 46)
        pAvatar.Position = UDim2.new(0, 9, 0, 9)
        pAvatar.BackgroundColor3 = Theme.SoftAccent
        pAvatar.BackgroundTransparency = 0.35
        pAvatar.BorderSizePixel = 0
        pAvatar.Parent = caixa
        corner(pAvatar, 23)

        pNome = Instance.new("TextLabel")
        pNome.Size = UDim2.new(1, -70, 0, 18)
        pNome.Position = UDim2.new(0, 64, 0, 10)
        pNome.BackgroundTransparency = 1
        pNome.Text = "No target"
        pNome.TextColor3 = Theme.Text
        pNome.Font = Enum.Font.GothamBold
        pNome.TextSize = 13
        pNome.TextXAlignment = Enum.TextXAlignment.Left
        pNome.TextTruncate = Enum.TextTruncate.AtEnd
        pNome.Parent = caixa

        pModo = Instance.new("TextLabel")
        pModo.Size = UDim2.new(1, -70, 0, 14)
        pModo.Position = UDim2.new(0, 64, 0, 29)
        pModo.BackgroundTransparency = 1
        pModo.RichText = true
        pModo.Text = "Base Owner"
        pModo.TextColor3 = Theme.Dim
        pModo.Font = Enum.Font.GothamMedium
        pModo.TextSize = 11
        pModo.TextXAlignment = Enum.TextXAlignment.Left
        pModo.TextTruncate = Enum.TextTruncate.AtEnd
        pModo.Parent = caixa

        pDist = Instance.new("TextLabel")
        pDist.Size = UDim2.new(1, -70, 0, 14)
        pDist.Position = UDim2.new(0, 64, 0, 43)
        pDist.BackgroundTransparency = 1
        pDist.Text = "--"
        pDist.TextColor3 = Theme.Dim
        pDist.Font = Enum.Font.GothamMedium
        pDist.TextSize = 11
        pDist.TextXAlignment = Enum.TextXAlignment.Left
        pDist.Parent = caixa

        pBarra = Instance.new("TextLabel")
        pBarra.Name = "WhiteTextBtn"
        pBarra.Size = UDim2.new(1, -18, 0, 22)
        pBarra.Position = UDim2.new(0, 9, 0, 60)
        pBarra.BackgroundColor3 = Theme.ToggleOff2
        pBarra.Text = "WAITING"
        pBarra.TextColor3 = Color3.fromRGB(255, 255, 255)
        pBarra.Font = Enum.Font.GothamBlack
        pBarra.TextSize = 11
        pBarra.BorderSizePixel = 0
        pBarra.Parent = caixa
        corner(pBarra, 7)

        reconstruirLista()
        -- rows are rebuilt ONLY when the roster changes, never per frame
        Plrs.PlayerAdded:Connect(function() task.defer(reconstruirLista) end)
        Plrs.PlayerRemoving:Connect(function(p)
            if Config.FaceAwayModo == "player" and Config.FaceAwayAlvo == p.Name then
                Config.FaceAwayModo = "baseowner"
                Config.FaceAwayAlvo = nil
                Config.FaceAwayNearest = false
                pcall(setToggle, "Face Nearest", false)
                fa.alvoCache = nil
            end
            task.defer(reconstruirLista)
        end)
        pcall(function() applySavedPosition("PingHub\nFace Away", painel) end)
        -- phones only: pull it inside the viewport (nil on desktop, so a no-op).
        -- Every other panel got this at startup; this one is born too late for it.
        if _G.Skyr0FitPanel then pcall(_G.Skyr0FitPanel, painel) end
        return true
    end

    -- Repaint is throttled to ~8/s AND skipped while the panel is closed --
    -- it is driven from a Heartbeat, so neither is optional.
    local function pintarPainel(alvo, d)
        if not painel or not painel.Visible then return end
        local agora = os.clock()
        if agora - ultimoPaint < 0.12 then return end
        ultimoPaint = agora
        local m = Config.FaceAwayModo or "baseowner"
        local nomeModo = (m == "nearest" and "Nearest Player")
                      or (m == "player" and ("@" .. tostring(Config.FaceAwayAlvo)))
                      or "Base Owner"
        local travado = (m == "baseowner" and fa.travado) and '  <font color="#38D66E">[locked]</font>' or ""
        pModo.Text = nomeModo .. travado
        if alvo then
            if pNome.Text ~= alvo.DisplayName then
                pNome.Text = alvo.DisplayName
                pAvatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. alvo.UserId .. "&w=48&h=48"
            end
            pDist.Text = tostring(d or 0) .. " studs"
            if fa.roubando then
                pBarra.Text = "FACING AWAY"
                pBarra.BackgroundColor3 = Theme.Green
                pBarra.TextColor3 = Color3.fromRGB(15, 15, 15)
            else
                pBarra.Text = "ARMED  -  not stealing"
                pBarra.BackgroundColor3 = Theme.SoftAccent
                pBarra.TextColor3 = Theme.Text
            end
        else
            pNome.Text = "No target"
            pAvatar.Image = ""
            pDist.Text = "--"
            pBarra.Text = "NO TARGET"
            pBarra.BackgroundColor3 = Theme.ToggleOff2
            pBarra.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    end

    local function faceAwayLigar()
        if construirPainel() and painel then
            -- honour a "hidden" choice made from the UI tab's panel list; only
            -- an explicit false counts, so a fresh config still opens it
            local vis = Config.Visibilities and Config.Visibilities["Face Away"]
            if vis ~= false then openAnim(painel) end
        end
        if fa.conn then return end
        fa.conn = RunService.Heartbeat:Connect(function()
            if not Config.FaceAway then return end
            local roubando = eu:GetAttribute("Stealing") and true or false
            if roubando ~= fa.roubando then
                fa.roubando = roubando
                if not roubando then
                    soltarRotacao()
                    fa.travado = nil
                end
            end
            local agora = os.clock()
            if agora - fa.ultimoAlvo >= 0.25 then
                fa.ultimoAlvo = agora
                fa.alvoCache = alvoAtual()
            end
            local alvo    = fa.alvoCache
            local alvoHrp = alvo and hrpDe(alvo) or nil
            local meuHrp  = hrpDe(eu)
            local d = 0
            if alvoHrp and meuHrp then
                d = math.floor((alvoHrp.Position - meuHrp.Position).Magnitude + 0.5)
            end
            if roubando and alvoHrp then
                virarDeCostas(alvoHrp.Position)
            end
            marcaAtualizar(alvo, d)
            pintarPainel(alvo, d)
        end)
    end

    local function faceAwayDesligar()
        if fa.conn then fa.conn:Disconnect(); fa.conn = nil end
        soltarRotacao()
        marcaLimpar()
        fa.travado = nil
        if painel then closeAnim(painel) end
    end

    _G.Skyr0SetFaceAway = function(on)
        Config.FaceAway = on and true or false
        pcall(setToggle, "Face Away", Config.FaceAway)
        if Config.FaceAway then faceAwayLigar() else faceAwayDesligar() end
        pcall(saveConfig)
        pcall(ShowNotification, "FACE AWAY", Config.FaceAway and "Enabled" or "Disabled")
    end

    _G.Skyr0SetFaceNearest = function(on)
        Config.FaceAwayNearest = on and true or false
        Config.FaceAwayModo = Config.FaceAwayNearest and "nearest" or "baseowner"
        Config.FaceAwayAlvo = nil
        pcall(setToggle, "Face Nearest", Config.FaceAwayNearest)
        fa.travado   = nil
        fa.alvoCache = nil
        marcaLimpar()
        pcall(pintarSelecao)   -- keep the panel's radio dots in step with the toggle
        pcall(saveConfig)
        pcall(ShowNotification, "FACE AWAY", Config.FaceAwayNearest and "Nearest Player" or "Base Owner")
    end

    pcall(function()
        regToggle("Face Away",    Config.FaceAway)
        regToggle("Face Nearest", Config.FaceAwayNearest)
    end)

    -- Same 2s delay Heresy used: the character and the base-owner resolver both
    -- need to exist before the first pass means anything.
    task.spawn(function()
        task.wait(2)
        if Config.FaceAway then faceAwayLigar() end
    end)
end
_initFaceAwayScope()

-- ============================================================
-- ============================================================

local function hasExclamation(target) for _,d in ipairs(target:GetDescendants()) do if d:IsA("BillboardGui") then
    local label=d:FindFirstChildWhichIsA("TextLabel",true); if label and label.Text:find("!") then return true end
end end; return false end

task.spawn(function()
    while true do task.wait(0.1)
        if Config.AutoDestroyTurrets then
            if LocalPlayer:GetAttribute("Stealing")~=true then
                local char=LocalPlayer.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart"); local hum=char and char:FindFirstChildOfClass("Humanoid")
                if hrp and hum then
                    local closest,shortestDist=nil,math.huge
                    for _,inst in ipairs(Workspace:GetDescendants()) do if inst.Name:match("^Sentry_") and hasExclamation(inst) then
                        local root=inst:IsA("BasePart") and inst or inst:FindFirstChildWhichIsA("BasePart",true)
                        if root then
                            local dist=(hrp.Position-root.Position).Magnitude
                            if dist <= 29 and dist<shortestDist then shortestDist=dist; closest=inst end
                        end
                    end end
                    if closest then
                        -- Make turret visible and move in front of player
                        for _,d in ipairs(closest:GetDescendants()) do if d:IsA("BasePart") then d.Transparency=0.5; d.CanCollide=false end end
                        local offset=hrp.CFrame.LookVector*4; local targetCF=CFrame.new(hrp.Position+offset,hrp.Position)
                        if closest:IsA("Model") then closest:PivotTo(targetCF) elseif closest:IsA("BasePart") then closest.CFrame=targetCF end
                        local bat=player.Backpack:FindFirstChild("Bat") or char:FindFirstChild("Bat")
                        if bat then if bat.Parent~=char then hum:EquipTool(bat) end; bat:Activate() end
                    end
                end
            end
        end
    end
end)


-- ============================================================
-- GUI HELPERS
-- ============================================================
main,mainBody,tabBar,bottomBar,fpsText = nil,nil,nil,nil,nil
panels,panelSetters,tabButtons={},{},{}
actionSettingsPanel,actionSettingsBody = nil,nil
BoundToggles={}

stealProgressBarGui = nil

-- Pre-declare helper functions made global to free local registers in outer scope

_G.ShowStealProgressBar = function(targetName, duration)
    local ExploitGui = (gethui and gethui()) or game:GetService("CoreGui")
    
    if stealProgressBarGui then
        pcall(function() stealProgressBarGui:Destroy() end)
    end
    
    local sg = Instance.new("ScreenGui")
    sg.Name = "Skyr0_StealProgressBar"
    sg.ResetOnSpawn = false
    sg.Parent = ExploitGui
    stealProgressBarGui = sg
    
    local barWidth = 270
    local barHeight = 50
    
    local container = Instance.new("Frame")
    container.Size = UDim2.fromOffset(barWidth, barHeight)
    container.Position = UDim2.new(0.5, -barWidth/2, 1, -190)
    container.BackgroundColor3 = Theme.Background
    container.BackgroundTransparency = 0.25
    container.BorderSizePixel = 0
    container.Parent = registerScreenGui(sg)
    corner(container, 12)
    addOutline(container)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.6, -14, 0, 16)
    title.Position = UDim2.new(0, 14, 0, 8)
    title.BackgroundTransparency = 1
    title.Text = "STEALING: " .. (targetName or "Brainrot"):upper()
    title.TextColor3 = Theme.Text
    title.Font = Enum.Font.GothamBold
    title.TextSize = 9.5
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = container
    
    local pctLabel = Instance.new("TextLabel")
    pctLabel.Size = UDim2.new(0.4, -14, 0, 16)
    pctLabel.Position = UDim2.new(0.6, 0, 0, 8)
    pctLabel.BackgroundTransparency = 1
    pctLabel.Text = "0%"
    pctLabel.TextColor3 = Theme.AccentLight
    pctLabel.Font = Enum.Font.GothamBold
    pctLabel.TextSize = 10
    pctLabel.TextXAlignment = Enum.TextXAlignment.Right
    pctLabel.Parent = container
    
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -28, 0, 6)
    track.Position = UDim2.new(0, 14, 0, 30)
    track.BackgroundColor3 = Theme.SliderBg
    track.BorderSizePixel = 0
    track.Parent = container
    corner(track, 3)
    stroke(track, Theme.Stroke, 1, 0.1)
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = Theme.Accent
    fill.BorderSizePixel = 0
    fill.Parent = track
    corner(fill, 3)
    
    local fillGrad = Instance.new("UIGradient", fill)
    fillGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.AccentLight),
        ColorSequenceKeypoint.new(1, Theme.Accent)
    })
    
    local safeDuration = tonumber(duration) or 5
    if safeDuration <= 0.01 then safeDuration = 5 end
    local startTick = tick()
    
    task.spawn(function()
        while sg and sg.Parent do
            local elapsed = tick() - startTick
            local t = math.clamp(elapsed / safeDuration, 0, 1)
            local ratio = 1 - (1 - t)^3
            
            pcall(function()
                pctLabel.Text = math.floor(ratio * 100) .. "%"
                fill.Size = UDim2.new(ratio, 0, 1, 0)
            end)
            
            if t >= 1 then break end
            task.wait()
        end
    end)
end

_G.HideStealProgressBar = function()
    local targetGui = stealProgressBarGui
    if targetGui then
        stealProgressBarGui = nil
        pcall(function()
            local container = targetGui:FindFirstChildWhichIsA("Frame")
            if container then
                tw(container, {BackgroundTransparency = 1}, 0.15)
                for _, child in ipairs(container:GetDescendants()) do
                    if child:IsA("TextLabel") then
                        tw(child, {TextTransparency = 1}, 0.15)
                    elseif child:IsA("Frame") then
                        tw(child, {BackgroundTransparency = 1}, 0.15)
                    elseif child:IsA("UIStroke") then
                        tw(child, {Transparency = 1}, 0.15)
                    end
                end
                task.wait(0.16)
            end
            targetGui:Destroy()
        end)
    end
end

-- =====================================================================
-- skyr0.wtf  --  UI CORE (rewritten)
-- ---------------------------------------------------------------------
-- Same palette, same name, same public API as the old core: every builder
-- below keeps its exact signature and return shape, so nothing downstream --
-- loadTab, rebuildActions, the AP panel, applyTheme -- needed touching.
--
-- What is new:
--   * ONE shared widget spine. Every row (toggle, slider, dropdown, textbox,
--     keybind) is built from the same `shell()` primitive, so spacing, corner
--     radius, hover and press feedback are defined once instead of per widget.
--   * Pointer-agnostic input. Buttons react to InputBegan/InputEnded rather
--     than MouseButton1Click, so touch behaves exactly like mouse -- that plus
--     the sizing below is the mobile support.
--   * Touch-sized targets. Every interactive row is at least MIN_TAP tall on a
--     touch device, and the window itself scales to the viewport instead of
--     using fixed 560px numbers that fall off a phone screen.
--   * Springy, interruptible motion. Tweens are short, Quint, and always
--     replace the previous one on the same property, so dragging or spamming a
--     toggle never queues up a backlog of animations.
-- =====================================================================

-- ---------- environment ----------
local UIS_ = game:GetService("UserInputService")
local IS_TOUCH = false
IS_TOUCH = _G.Skyr0IsTouch == true   -- shared detector (see DEVICE DETECTION)
local MIN_TAP = IS_TOUCH and 40 or 0

local function viewport()
    local cam = workspace.CurrentCamera
    return (cam and cam.ViewportSize) or Vector2.new(1280, 720)
end

-- Window size: fixed on desktop, viewport-relative on a phone so the panel can
-- never open larger than the screen it is drawn on.
local function windowSize()
    local vp = viewport()
    if not IS_TOUCH then return UDim2.fromOffset(560, 560) end
    -- A tablet has the room for the desktop window; only phones need shrinking.
    -- Sizing both the same is why an iPad got the cramped phone layout.
    if _G.Skyr0IsTablet then
        local w = math.clamp(vp.X * 0.62, 460, 620)
        local h = math.clamp(vp.Y * 0.72, 420, 640)
        return UDim2.fromOffset(math.floor(w), math.floor(h))
    end
    local w = math.clamp(vp.X * 0.92, 300, 560)
    local h = math.clamp(vp.Y * 0.80, 320, 560)
    return UDim2.fromOffset(math.floor(w), math.floor(h))
end

-- ---------- primitives ----------
corner = function(o,r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r); c.Parent=o; return c end
stroke = function(o,col,th,tr) local s=Instance.new("UIStroke"); s.Color=col or Theme.Stroke; s.Thickness=th or 1; s.Transparency=tr or 0; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; s.Parent=o; return s end
tw = function(o,p,t) TweenService:Create(o,TweenInfo.new(t or 0.14,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),p):Play() end
addOutline = function(f) local o=Instance.new("UIStroke"); o.Color=Theme.AccentLight; o.Thickness=1.25; o.Transparency=0.08; o.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; o.Parent=f; return o end

decoratePanel = function(f)
    local g=Instance.new("UIGradient", f); g.Rotation=90
    g.Color=ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(188,188,188))}
    local hl=Instance.new("Frame"); hl.Size=UDim2.new(1,-16,0,1); hl.Position=UDim2.new(0,8,0,1); hl.BackgroundColor3=Color3.fromRGB(243,243,243); hl.BackgroundTransparency=0.5; hl.BorderSizePixel=0; hl.ZIndex=6; hl.Parent=f
    local hlg=Instance.new("UIGradient", hl); hlg.Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(0.5,0), NumberSequenceKeypoint.new(1,1)}
    return g
end

-- Pointer press/release that works for mouse AND touch. Returns the button so
-- callers can keep chaining. `press` fires on release inside the widget only,
-- which is what makes a drag off a button cancel it the way a phone user
-- expects.
local function bindPress(btn, onPress, hoverIn, hoverOut)
    local inside, down = false, false
    btn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            down = true
            if hoverIn then hoverIn(true) end
        elseif i.UserInputType == Enum.UserInputType.MouseMovement then
            inside = true; if hoverIn then hoverIn(false) end
        end
    end)
    btn.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            if down and onPress then task.spawn(onPress) end
            down = false
            if hoverOut then hoverOut() end
        elseif i.UserInputType == Enum.UserInputType.MouseMovement then
            inside = false; if hoverOut then hoverOut() end
        end
    end)
    return btn
end
_G.Skyr0BindPress = bindPress

-- The one row primitive every widget is built on.
local function shell(parent, height, opts)
    opts = opts or {}
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -4, 0, math.max(height, MIN_TAP))
    row.BackgroundColor3 = opts.bg or Theme.Panel
    row.BackgroundTransparency = opts.transparent and 1 or 0.3
    row.BorderSizePixel = 0
    row.Parent = parent
    if not opts.transparent then corner(row, 8) end
    return row
end

local function rowLabel(row, text, rightPad, size)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -(rightPad or 54), 1, 0)
    l.Position = UDim2.new(0, 10, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Theme.Text
    l.Font = Enum.Font.GothamMedium
    l.TextSize = size or 11
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextTruncate = Enum.TextTruncate.AtEnd
    l.Parent = row
    return l
end

-- Pill switch, shared by every toggle flavour.
local function pill(row, initial)
    local sw = Instance.new("TextButton")
    local w, h = (IS_TOUCH and 46 or 38), (IS_TOUCH and 26 or 21)
    sw.Size = UDim2.fromOffset(w, h)
    sw.Position = UDim2.new(1, -(w + 8), 0.5, -h/2)
    sw.BackgroundColor3 = initial and Theme.Green or Theme.ToggleOff
    sw.Text = ""
    sw.AutoButtonColor = false
    sw.Parent = row
    corner(sw, 20)
    local d = h - 5
    local dot = Instance.new("Frame")
    dot.Size = UDim2.fromOffset(d, d)
    dot.Position = initial and UDim2.new(1, -(d+3), 0.5, -d/2) or UDim2.new(0, 3, 0.5, -d/2)
    dot.BackgroundColor3 = Theme.InputBg
    dot.BorderSizePixel = 0
    dot.Parent = sw
    corner(dot, 20)
    local function paint(on)
        tw(sw, {BackgroundColor3 = on and Theme.Green or Theme.ToggleOff}, 0.14)
        tw(dot, {Position = on and UDim2.new(1, -(d+3), 0.5, -d/2) or UDim2.new(0, 3, 0.5, -d/2)}, 0.14)
    end
    return sw, paint
end

function clearBody(body) for _,c in ipairs(body:GetChildren()) do if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then c:Destroy() end end end

function openAnim(f)
    if not f then return end
    local us=f:FindFirstChild("Skyr0Scale") or Instance.new("UIScale"); us.Name="Skyr0Scale"; us.Parent=f
    f.Visible=true; us.Scale=0.94
    tw(us,{Scale=1},0.18)
end
function closeAnim(f) if not f then return end; f.Visible = false end

-- ---------- window chrome ----------
function makeHeader(f,t,isMain)
    local h=Instance.new("Frame"); h.Size=UDim2.new(1,0,0,44); h.BackgroundTransparency=1; h.Parent=f
    local title=Instance.new("TextLabel"); title.Size=UDim2.new(1,-96,0,20); title.Position=UDim2.new(0,16,0,12)
    title.BackgroundTransparency=1; title.Text=t; title.TextColor3=Theme.Text
    title.Font=Enum.Font.GothamBold; title.TextSize=isMain and 16 or 12
    title.TextXAlignment=Enum.TextXAlignment.Left; title.Parent=h
    local sub=Instance.new("TextLabel"); sub.Size=UDim2.new(1,-96,0,12); sub.Position=UDim2.new(0,16,0,30)
    sub.BackgroundTransparency=1; sub.Text=isMain and ".gg/PingHub" or ""; sub.TextColor3=Theme.Dim
    sub.Font=Enum.Font.GothamMedium; sub.TextSize=10
    sub.TextXAlignment=Enum.TextXAlignment.Left; sub.Parent=h
    local div=Instance.new("Frame"); div.Size=UDim2.new(1,-24,0,1); div.Position=UDim2.new(0,12,0,43)
    div.BackgroundColor3=Theme.AccentLight; div.BackgroundTransparency=0.55; div.BorderSizePixel=0; div.Parent=f
    return h
end

-- RESTORED from the previous core, unchanged. Two things in here are not
-- optional and a hand-rolled drag gets both wrong:
--   * it divides the delta by getGlobalScale(). The hub renders under a global
--     UIScale, so raw pixel deltas move the frame by the wrong amount and the
--     window slides away from the cursor as you drag.
--   * it honours UI.Locked and calls rememberPosition(saveName), which is how
--     panel positions survive a re-execute.
-- It is also what the Admin, config and overlay panels call, so
-- losing it took their dragging out too.
-- RELEASE IS NOW UNCONDITIONAL. The old body dropped the drag flag on the
-- same line as the save call -- `... rememberPosition(saveName,frame) end; dragging=false`
-- -- so anything that threw inside the save (and rememberPosition did not even
-- exist, see its definition above) skipped the flag and left the window welded
-- to the cursor. The flag is cleared FIRST here and the save is pcall'd, so a
-- broken save can cost you a remembered position and nothing else.
--
-- Three ways a drag can end, because one is not enough:
--   * UIS.InputEnded -- the normal mouse-up / finger-up.
--   * the input object's own state going to End -- fires even when the
--     mouse-up lands somewhere UIS.InputEnded does not report it.
--   * WindowFocusReleased -- alt-tabbing mid-drag used to come back with the
--     button "still held" and the window stuck to the pointer.
makeDraggable = function(frame,handle,saveName) local dragging,dragStart,startPos=false,nil,nil
    local function stopDrag()
        if not dragging then return end
        dragging=false
        if saveName then pcall(rememberPosition, saveName, frame) end
    end
    handle.InputBegan:Connect(function(i) if UI.Locked then return end; if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        dragging=true; dragStart=i.Position; startPos=frame.Position
        -- the pointer that STARTED this drag is also allowed to end it.
        -- Self-disconnecting: one connection per press that outlived the press
        -- would pile up for the life of the session.
        local endConn
        endConn = i.Changed:Connect(function()
            if i.UserInputState==Enum.UserInputState.End then
                if endConn then endConn:Disconnect(); endConn=nil end
                stopDrag()
            end
        end)
    end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then stopDrag() end end)
    UIS.WindowFocusReleased:Connect(stopDrag)
    UIS.InputChanged:Connect(function(i) if dragging and not UI.Locked and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
        -- A destroyed panel (a rebuilt tab, a re-execute) must not keep a drag
        -- alive against a frame that is no longer on screen.
        if not frame.Parent then dragging=false; return end
        local d=i.Position-dragStart
        -- guard the divide: a zero/garbage scale produced inf/NaN offsets, and a
        -- frame at NaN is off-screen and unclickable for the rest of the session
        local scale = tonumber(getGlobalScale()) or 1
        if scale <= 0 then scale = 1 end
        frame.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+(d.X/scale),startPos.Y.Scale,startPos.Y.Offset+(d.Y/scale))
    end end)
end

local function buildPanel(title, size, pos, isMain)
    local f=Instance.new("Frame")
    f.Size = isMain and windowSize() or size
    f.Position=pos
    f.BackgroundColor3 = isMain and Theme.MainBackground or Theme.Background
    f.BackgroundTransparency=0.3
    f.BorderSizePixel=0
    f.ClipsDescendants=true
    f.Active=true
    f.Parent=gui
    corner(f,14); addOutline(f); decoratePanel(f)
    local head = makeHeader(f,title,isMain)
    head.Active = true      -- a Frame must be Active to receive InputBegan
    makeDraggable(f, head, isMain and "MainWindow" or title)

    local body=Instance.new("ScrollingFrame")
    body.Position=UDim2.new(0,10,0,52)
    body.Size=UDim2.new(1,-20,1,-62)
    body.BackgroundTransparency=1
    body.BorderSizePixel=0
    body.ScrollBarThickness = IS_TOUCH and 0 or 3
    body.ScrollBarImageColor3=Theme.Accent
    body.ScrollingDirection=Enum.ScrollingDirection.Y
    body.AutomaticCanvasSize=Enum.AutomaticSize.Y
    body.CanvasSize=UDim2.new()
    body.ElasticBehavior=Enum.ElasticBehavior.WhenScrollable
    body.Parent=f
    local lay=Instance.new("UIListLayout"); lay.Padding=UDim.new(0,6); lay.SortOrder=Enum.SortOrder.LayoutOrder; lay.Parent=body
    local pad=Instance.new("UIPadding"); pad.PaddingTop=UDim.new(0,2); pad.PaddingBottom=UDim.new(0,8); pad.Parent=body
    return f, body
end

function makeMainPanel(t,size,pos) return buildPanel(t,size,pos,true) end
function makeQuickPanel(t,size,pos) return buildPanel(t,size,pos,false) end

-- ---------- widgets ----------
function makeSyncStateRow(parent,text,toggleName,callback)
    regToggle(toggleName,getToggle(toggleName))
    local row=shell(parent,34,{transparent=true})
    local label=rowLabel(row,text,90,12)
    local bw = IS_TOUCH and 80 or 72
    local btn=Instance.new("TextButton"); btn.Name="WhiteTextBtn"
    btn.Size=UDim2.fromOffset(bw,30); btn.Position=UDim2.new(1,-(bw+2),0.5,-15)
    btn.Font=Enum.Font.GothamBlack; btn.TextSize=12; btn.AutoButtonColor=false; btn.Parent=row; corner(btn,7)
    local function refresh(val)
        tw(btn,{BackgroundColor3=val and Theme.Green or Theme.ToggleOff2},0.12)
        btn.Text=val and "ON" or "OFF"
        btn.TextColor3=val and Color3.fromRGB(15,15,15) or Color3.fromRGB(255,255,255)
    end
    btn.BackgroundColor3=getToggle(toggleName) and Theme.Green or Theme.ToggleOff2
    refresh(getToggle(toggleName)); onToggleChanged(toggleName,function(val) refresh(val) end)
    bindPress(btn,function() local nv=not getToggle(toggleName); setToggle(toggleName,nv); if callback then callback(nv) end end)
    return function(ns,fire) if typeof(ns)=="boolean" then setToggle(toggleName,ns); if fire~=false and callback then callback(ns) end end end, label
end

function makeSyncMainToggle(parent,text,toggleName,callback)
    regToggle(toggleName,getToggle(toggleName))
    local row=shell(parent,32)
    rowLabel(row,text,64)
    local sw,paint = pill(row,getToggle(toggleName))
    onToggleChanged(toggleName,function(val) paint(val) end)
    bindPress(sw,function() local nv=not getToggle(toggleName); setToggle(toggleName,nv); if callback then callback(nv) end end)
    BoundToggles[text]=function(ns,fire) if typeof(ns)=="boolean" then setToggle(toggleName,ns); if fire~=false and callback then callback(ns) end end end
    return BoundToggles[text]
end

function makeMainToggle(parent,text,enabled,callback)
    local row=shell(parent,32)
    rowLabel(row,text,64)
    local state=enabled
    local sw,paint = pill(row,state)
    local function setState(ns,fire) state=ns; paint(state); if fire~=false and callback then callback(state) end end
    bindPress(sw,function() setState(not state,true) end)
    BoundToggles[text]=function(ns,fire) if typeof(ns)=="boolean" then setState(ns,fire) else setState(not state,true) end end
    return BoundToggles[text]
end

function makeQuickButton(parent,text,callback,bg)
    local b=Instance.new("TextButton")
    b.Size=UDim2.new(1,-4,0,math.max(36,MIN_TAP)); b.BackgroundColor3=bg or Theme.SoftButton
    b.BackgroundTransparency=0.15; b.Text=text; b.TextColor3=Theme.Text
    b.Font=Enum.Font.GothamBold; b.TextSize=13; b.AutoButtonColor=false; b.BorderSizePixel=0
    b.Parent=parent; corner(b,8)
    bindPress(b, function() if callback then callback() end end,
        function(isDown) tw(b,{BackgroundColor3=bg or Theme.SoftButtonHover, Size=isDown and UDim2.new(1,-10,0,math.max(36,MIN_TAP)-1) or UDim2.new(1,-4,0,math.max(36,MIN_TAP))},0.10) end,
        function() tw(b,{BackgroundColor3=bg or Theme.SoftButton, Size=UDim2.new(1,-4,0,math.max(36,MIN_TAP))},0.12) end)
    return b
end

function makeMainButton(parent,text,callback,color)
    local b=Instance.new("TextButton")
    b.Size=UDim2.new(1,-4,0,math.max(32,MIN_TAP)); b.BackgroundColor3=color or Theme.Row
    b.BackgroundTransparency=0.3; b.Text=text; b.TextColor3=Theme.Text
    b.Font=Enum.Font.GothamBold; b.TextSize=11; b.AutoButtonColor=false; b.BorderSizePixel=0
    b.Parent=parent; corner(b,7); stroke(b,Theme.AccentLight,1,0.35)
    bindPress(b, function() if callback then callback() end end,
        function() tw(b,{BackgroundColor3=color or Theme.RowHover},0.10) end,
        function() tw(b,{BackgroundColor3=color or Theme.Row},0.12) end)
    return b
end

-- Sliders: one drag implementation, pointer-agnostic, used by both flavours.
-- `step` (optional, trailing) sets the slider's precision EXPLICITLY.
--
-- Without it the precision is inferred from the range: a span of 5 or less gets
-- two decimals, anything wider is rounded to whole numbers. That heuristic is
-- right for speeds, radii and FOV, but it silently destroys small values on a
-- wide range measured in seconds -- "TP on Load Delay" is 0-30, so a typed 0.13
-- was floored straight to 0 and the delay did nothing. Pass step=0.01 there and
-- the value survives, both from the text box and from dragging.
local function buildSlider(parent, text, min, max, default, callback, suffix, withInput, step)
    local h = withInput and 56 or 52
    local holder=shell(parent, h, {transparent=true})
    local label=Instance.new("TextLabel")
    label.Size=UDim2.new(1,-70,0,16); label.Position=UDim2.new(0,6,0,0); label.BackgroundTransparency=1
    label.Text=text; label.TextColor3=Theme.Text; label.Font=Enum.Font.GothamMedium; label.TextSize=11
    label.TextXAlignment=Enum.TextXAlignment.Left; label.Parent=holder

    local val=Instance.new("TextBox")
    val.Size=UDim2.fromOffset(58,18); val.Position=UDim2.new(1,-62,0,0)
    val.BackgroundColor3=Theme.InputBg; val.BackgroundTransparency=withInput and 0.1 or 1
    val.Text=tostring(default)..(suffix or ""); val.TextColor3=withInput and Theme.Text or Theme.Dim
    val.Font=Enum.Font.GothamBold; val.TextSize=10; val.TextEditable=withInput and true or false
    val.ClearTextOnFocus=false; val.BorderSizePixel=0; val.Parent=holder
    if withInput then corner(val,5) end

    local barH = IS_TOUCH and 10 or 6
    local bar=Instance.new("Frame")
    bar.Size=UDim2.new(1,-12,0,barH); bar.Position=UDim2.new(0,6,0,h-(IS_TOUCH and 20 or 18))
    bar.BackgroundColor3=Theme.SliderBg; bar.BorderSizePixel=0; bar.Parent=holder; corner(bar,20)
    local fill=Instance.new("Frame")
    fill.Size=UDim2.fromScale((default-min)/math.max(max-min,1e-6),1)
    fill.BackgroundColor3=Theme.Accent; fill.BorderSizePixel=0; fill.Parent=bar; corner(fill,20)
    local knobD = IS_TOUCH and 20 or 14
    local knob=Instance.new("Frame")
    knob.Size=UDim2.fromOffset(knobD,knobD); knob.AnchorPoint=Vector2.new(0.5,0.5)
    knob.Position=UDim2.new(fill.Size.X.Scale,0,0.5,0)
    knob.BackgroundColor3=Theme.Text; knob.BorderSizePixel=0; knob.ZIndex=3; knob.Parent=bar; corner(knob,20)

    -- oversized invisible hit area so a finger does not have to land on a 6px bar
    local hit=Instance.new("TextButton")
    hit.Size=UDim2.new(1,0,0,math.max(barH+22,MIN_TAP)); hit.Position=UDim2.new(0,0,0.5,-math.max(barH+22,MIN_TAP)/2)
    hit.BackgroundTransparency=1; hit.Text=""; hit.AutoButtonColor=false; hit.ZIndex=4; hit.Parent=bar

    local cur=default
    local function apply(v, fire)
        v=math.clamp(v,min,max)
        if step and step > 0 then
            -- Quantise to the step, then round to the step's OWN decimal places.
            -- The second half matters: math.floor(0.13/0.01+0.5)*0.01 comes back
            -- as 0.13000000000000001 in binary float, which tostring() would then
            -- render in full into the box.
            local dec, s = 0, step
            while s < 1 and dec < 6 do s = s * 10; dec = dec + 1 end
            v = tonumber(string.format("%." .. dec .. "f", math.floor(v/step + 0.5) * step)) or v
        elseif max-min <= 5 then v=math.floor(v*100+0.5)/100
        else v=math.floor(v+0.5) end
        cur=v
        local a=(v-min)/math.max(max-min,1e-6)
        tw(fill,{Size=UDim2.fromScale(a,1)},0.08)
        tw(knob,{Position=UDim2.new(a,0,0.5,0)},0.08)
        if not val:IsFocused() then val.Text=tostring(v)..(suffix or "") end
        if fire~=false and callback then callback(v) end
    end

    local dragging=false
    local function fromX(px)
        local a=math.clamp((px-bar.AbsolutePosition.X)/math.max(bar.AbsoluteSize.X,1),0,1)
        apply(min+(max-min)*a)
    end
    hit.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dragging=true; tw(knob,{Size=UDim2.fromOffset(knobD+4,knobD+4)},0.10); fromX(i.Position.X)
        end
    end)
    hit.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dragging=false; tw(knob,{Size=UDim2.fromOffset(knobD,knobD)},0.10)
        end
    end)
    UIS_.InputChanged:Connect(function(i)
        if not dragging then return end
        if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then fromX(i.Position.X) end
    end)
    if withInput then
        val.FocusLost:Connect(function()
            local n=tonumber((val.Text:gsub("[^%d%.%-]","")))
            if n then apply(n) else val.Text=tostring(cur)..(suffix or "") end
        end)
    end
    return function(v,fire) apply(tonumber(v) or cur, fire) end
end

function makeQuickSlider(parent,text,min,max,default,callback,suffix,step)
    return buildSlider(parent,text,min,max,default,callback,suffix,false,step)
end
function makeMainSliderWithInput(parent,text,min,max,default,callback,suffix,step)
    return buildSlider(parent,text,min,max,default,callback,suffix,true,step)
end

function makeMainDropdown(parent,label,options,current,onSelect)
    local sel=current or (options and options[1]) or ""
    local rowH=math.max(32,MIN_TAP)
    local box=shell(parent,rowH)
    box.ClipsDescendants=true
    box.AutomaticSize=Enum.AutomaticSize.None
    local head=Instance.new("TextButton")
    head.Size=UDim2.new(1,0,0,rowH); head.BackgroundTransparency=1; head.Text=""; head.AutoButtonColor=false; head.Parent=box
    local l=rowLabel(head,label,120)
    local pick=Instance.new("TextLabel")
    pick.Size=UDim2.fromOffset(110,rowH); pick.Position=UDim2.new(1,-118,0,0); pick.BackgroundTransparency=1
    pick.Text=tostring(sel); pick.TextColor3=Theme.Accent; pick.Font=Enum.Font.GothamBold; pick.TextSize=11
    pick.TextXAlignment=Enum.TextXAlignment.Right; pick.TextTruncate=Enum.TextTruncate.AtEnd; pick.Parent=head
    local caret=Instance.new("TextLabel")
    caret.Size=UDim2.fromOffset(12,rowH); caret.Position=UDim2.new(1,-14,0,0); caret.BackgroundTransparency=1
    caret.Text="\u{25BE}"; caret.TextColor3=Theme.Dim; caret.Font=Enum.Font.GothamBold; caret.TextSize=10; caret.Parent=head

    local list=Instance.new("Frame")
    list.Size=UDim2.new(1,-12,0,0); list.Position=UDim2.new(0,6,0,rowH); list.BackgroundTransparency=1; list.Parent=box
    local ll=Instance.new("UIListLayout"); ll.Padding=UDim.new(0,3); ll.Parent=list

    local open=false
    local optH=math.max(26,MIN_TAP-8)
    for _,opt in ipairs(options or {}) do
        local b=Instance.new("TextButton")
        b.Size=UDim2.new(1,0,0,optH); b.BackgroundColor3=Theme.Row; b.BackgroundTransparency=0.25
        b.Text=tostring(opt); b.TextColor3=Theme.Text; b.Font=Enum.Font.GothamMedium; b.TextSize=10
        b.AutoButtonColor=false; b.BorderSizePixel=0; b.Parent=list; corner(b,6)
        bindPress(b,function()
            sel=opt; pick.Text=tostring(opt)
            open=false; tw(box,{Size=UDim2.new(1,-4,0,rowH)},0.16); tw(caret,{Rotation=0},0.16)
            if onSelect then onSelect(opt) end
        end,
        function() tw(b,{BackgroundColor3=Theme.RowHover},0.10) end,
        function() tw(b,{BackgroundColor3=Theme.Row},0.12) end)
    end
    bindPress(head,function()
        open=not open
        local full=rowH+8+(#(options or {})*(optH+3))
        tw(box,{Size=UDim2.new(1,-4,0,open and full or rowH)},0.18)
        tw(caret,{Rotation=open and 180 or 0},0.18)
    end)
    return function(v) if v then sel=v; pick.Text=tostring(v) end return sel end
end

function makeMainTextBox(parent,text,default,placeholder,callback)
    local row=shell(parent,math.max(32,MIN_TAP))
    rowLabel(row,text,150)
    local tb=Instance.new("TextBox")
    tb.Size=UDim2.new(0,140,0,math.max(24,MIN_TAP-10)); tb.Position=UDim2.new(1,-148,0.5,-math.max(24,MIN_TAP-10)/2)
    tb.BackgroundColor3=Theme.InputBg; tb.BackgroundTransparency=0.1; tb.BorderSizePixel=0
    tb.Text=tostring(default or ""); tb.PlaceholderText=placeholder or ""
    tb.TextColor3=Theme.Text; tb.PlaceholderColor3=Theme.Dim
    tb.Font=Enum.Font.GothamMedium; tb.TextSize=11; tb.ClearTextOnFocus=false; tb.Parent=row
    corner(tb,6); stroke(tb,Theme.Stroke,1,0.5)
    tb.Focused:Connect(function() tw(tb,{BackgroundTransparency=0},0.12) end)
    tb.FocusLost:Connect(function() tw(tb,{BackgroundTransparency=0.1},0.12); if callback then callback(tb.Text) end end)
    return tb
end

function makeKeybindRow(parent,nameText)
    local rowH=math.max(32,MIN_TAP)
    local row=shell(parent,rowH)
    rowLabel(row,nameText,100)
    local bh=math.max(22,MIN_TAP-12)
    local x=Instance.new("TextButton"); x.Name="WhiteTextBtn"
    x.Size=UDim2.fromOffset(24,bh); x.Position=UDim2.new(1,-82,0.5,-bh/2)
    x.BackgroundColor3=Theme.Red; x.Text="X"; x.TextColor3=Color3.new(1,1,1)
    x.Font=Enum.Font.GothamBold; x.TextSize=10; x.AutoButtonColor=false; x.BorderSizePixel=0
    x.Parent=row; corner(x,6)
    local key=Instance.new("TextButton"); key.Name="WhiteTextBtn"
    key.Size=UDim2.fromOffset(54,bh); key.Position=UDim2.new(1,-56,0.5,-bh/2)
    key.BackgroundColor3=Theme.Accent; key.Text=Keybinds[nameText] or "NONE"
    key.TextColor3=Color3.fromRGB(25,25,28); key.Font=Enum.Font.GothamBold; key.TextSize=9
    key.AutoButtonColor=false; key.BorderSizePixel=0; key.Parent=row; corner(key,6)

    local function commit(newKey)
        if type(Config.keybinds)~="table" then Config.keybinds={} end
        -- Clearing THIS row would lock the panel shut with the only way to
        -- reopen it inside the panel. Refused rather than silently ignored, so
        -- the X button says what it did instead of looking broken.
        if nameText=="Open Menu" and newKey=="NONE" then
            key.Text="KEEP"
            warn("[skyr0] Open Menu cannot be unbound -- it is the only way back into the panel.")
            if ShowNotification then ShowNotification("KEYBINDS","Open Menu cannot be unbound") end
            task.delay(0.9,function()
                if key and key.Parent then key.Text=Keybinds[nameText] or "NONE" end
            end)
            return
        end
        Keybinds[nameText]=newKey
        Config.keybinds[nameText]=newKey
        -- A key can only drive one action. Steal it from whoever had it so the
        -- old "two actions, one key, undefined winner" state cannot come back.
        if newKey~="NONE" then
            for other,k in pairs(Keybinds) do
                if other~=nameText and k==newKey then
                    Keybinds[other]="NONE"; Config.keybinds[other]="NONE"
                end
            end
        end
        -- Derived from the table rather than from the event: clearing a bind, or
        -- binding to MouseButton3, has no KeyCode to assign and used to leave
        -- the old key live forever. Ensure, not just apply -- the steal loop
        -- above can have taken the key off Open Menu, and that must not be
        -- allowed to leave it unbound.
        Skyr0EnsureOpenMenuBind()
        -- The ensure normally MOVES Open Menu to a free key, which needs no
        -- comment -- the tab redraws and shows where it went. The one case worth
        -- saying out loud is the last resort, where every fallback was taken and
        -- it reclaimed the key this row had just been given.
        if Keybinds[nameText]~=newKey and ShowNotification then
            ShowNotification("KEYBINDS", tostring(newKey).." is held by Open Menu")
        end
        saveConfig()
        key.Text=Keybinds[nameText] or "NONE"
        if rebuildKeybindMap then rebuildKeybindMap() end
        if updateMovementPanelLabels then updateMovementPanelLabels() end
        if UI.CurrentTab=="Keybinds" and loadTab then task.defer(loadTab,"Keybinds") end
    end

    bindPress(x,function() commit("NONE") end,
        function() tw(x,{BackgroundColor3=Theme.Red2},0.10) end,
        function() tw(x,{BackgroundColor3=Theme.Red},0.12) end)

    bindPress(key,function()
        -- ONE ROW CAPTURES AT A TIME.
        --
        -- Clicking a second row while the first was still listening left BOTH
        -- connections live, and the next key press committed to both of them --
        -- then the duplicate-stealing loop in commit() immediately blanked
        -- whichever ran second. Two rows clicked, one key pressed, and the
        -- visible result was a row that refused to take a bind.
        if _G.__Skyr0BindCancel then pcall(_G.__Skyr0BindCancel) end
        key.Text="..."
        tw(key,{BackgroundColor3=Theme.AccentLight},0.12)
        local con
        local myCancel
        local function stop()
            if con then con:Disconnect(); con=nil end
            if _G.__Skyr0BindCancel == myCancel then _G.__Skyr0BindCancel = nil end
            -- Cleared so the input handler starts dispatching again. Held one
            -- extra frame: the key that ENDS the capture is still travelling
            -- through InputBegan, and without the delay it also fires whatever
            -- action was previously bound to it (pressing T to rebind launched
            -- a teleport, pressing LeftControl toggled the menu shut).
            task.defer(function()
                if not _G.__Skyr0BindCancel then _G.Skyr0BindCapturing = false end
            end)
        end
        myCancel = function()
            stop()
            if key and key.Parent then key.Text=Keybinds[nameText] or "NONE" end
            pcall(tw,key,{BackgroundColor3=Theme.Accent},0.12)
        end
        _G.Skyr0BindCapturing = true
        _G.__Skyr0BindCancel = myCancel
        -- DEAD MAN'S SWITCH. Capturing suppresses the whole input handler, so a
        -- capture that never ends -- switching tabs mid-bind destroys the row
        -- and takes the only way to cancel with it -- would silently kill every
        -- keybind in the hub until the next execute. It always ends.
        task.delay(8, function()
            if _G.__Skyr0BindCancel == myCancel then pcall(myCancel) end
        end)
        con=UIS.InputBegan:Connect(function(input,gp)
            if gp then return end
            if not (key and key.Parent) then stop(); return end
            local newKey
            if input.UserInputType==Enum.UserInputType.Keyboard then
                if input.KeyCode==Enum.KeyCode.Escape then
                    stop(); key.Text=Keybinds[nameText] or "NONE"
                    tw(key,{BackgroundColor3=Theme.Accent},0.12); return
                end
                newKey = input.KeyCode.Name
            elseif input.UserInputType==Enum.UserInputType.MouseButton3 then
                newKey = "MouseButton3"
            else
                return
            end
            stop()
            tw(key,{BackgroundColor3=Theme.Accent},0.12)
            if KeybindReserved and KeybindReserved[newKey] then
                key.Text="RSVD"
                warn("[skyr0] "..newKey.." is reserved by the game and cannot be bound")
                task.delay(0.9, function()
                    if key and key.Parent then key.Text=Keybinds[nameText] or "NONE" end
                end)
                return
            end
            commit(newKey)
        end)
    end)
end

-- CREATE PANELS
main,mainBody=makeMainPanel("PingHub",UDim2.new(0,560,0,560),UDim2.new(0.5,-280,0.5,-290))
do
    -- Centre the window for whatever size it actually got (mobile shrinks it),
    -- and re-centre on rotation / resize so it can never end up half off-screen.
    local function centre()
        local s=main.AbsoluteSize
        main.Position=UDim2.new(0.5,-math.floor(s.X/2),0.5,-math.floor(s.Y/2))
    end
    task.defer(centre)
    local cam=workspace.CurrentCamera
    if cam then
        cam:GetPropertyChangedSignal("ViewportSize"):Connect(function()
            main.Size = windowSize()
            task.defer(centre)
        end)
    end
end

-- MOBILE LAUNCHER -- a draggable round button that opens/closes the panel.
-- Touch devices have no keyboard, so the Open Menu keybind is unreachable
-- there; without this the hub simply cannot be reopened once closed.
if IS_TOUCH then
    local fab=Instance.new("TextButton")
    fab.Name="Skyr0_Launcher"
    fab.Size=UDim2.fromOffset(52,52)
    fab.Position=UDim2.new(0,14,0.5,-26)
    fab.BackgroundColor3=Theme.Accent
    fab.Text="wtf"
    fab.TextColor3=Color3.fromRGB(20,20,20)
    fab.Font=Enum.Font.GothamBlack
    fab.TextSize=13
    fab.AutoButtonColor=false
    fab.BorderSizePixel=0
    fab.ZIndex=50
    fab.Parent=gui
    corner(fab,26); stroke(fab,Theme.Text,1.5,0.6)

    -- drag vs tap: only treat it as a tap if the finger barely moved
    local dragging,moved,startIn,startPos=false,false,nil,nil
    fab.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
            dragging=true; moved=false; startIn=i.Position; startPos=fab.Position
            tw(fab,{Size=UDim2.fromOffset(48,48)},0.08)
        end
    end)
    fab.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
            dragging=false
            tw(fab,{Size=UDim2.fromOffset(52,52)},0.10)
            if not moved then
                if main.Visible then closeAnim(main) else openAnim(main) end
            end
        end
    end)
    UIS_.InputChanged:Connect(function(i)
        if not dragging then return end
        if i.UserInputType~=Enum.UserInputType.Touch and i.UserInputType~=Enum.UserInputType.MouseMovement then return end
        local d=i.Position-startIn
        if math.abs(d.X)>6 or math.abs(d.Y)>6 then moved=true end
        local vp=viewport()
        fab.Position=UDim2.new(0,math.clamp(startPos.X.Offset+d.X,0,vp.X-52),0,math.clamp(startPos.Y.Offset+d.Y,0,vp.Y-52))
    end)
end
if Config.AutoCloseOnExec then main.Visible = false end
panels["Invisible Steal Panel"],panels["InvisStealBody"]=makeQuickPanel("PingHub\nInvisible Steal",UDim2.new(0,230,0,375),UDim2.new(0,80,0.5,-220))
panels["InvisStealBody"].ScrollBarThickness = 0
panels["InvisStealBody"].ScrollingEnabled = false
panels["Actions"],panels["ActionsBody"]=makeQuickPanel("PingHub\nActions",UDim2.new(0,230,0,340),UDim2.new(0.5,505,1,-415))
panels["Steal Panel"],panels["StealBody"]=makeQuickPanel("PingHub\nSteal Panel",UDim2.new(0,235,0,300),UDim2.new(1,-300,1,-385))
panels["Steal Target"],panels["TargetBody"]=makeQuickPanel("PingHub\nSteal Target",UDim2.new(0,320,0,380),UDim2.new(1,-330,0,85))
actionSettingsPanel,actionSettingsBody=makeQuickPanel("PingHub\nAction Settings",UDim2.new(0,230,0,370),UDim2.new(0.5,745,1,-440))
actionSettingsPanel.Visible=false
for _,pair in ipairs({{"PingHub",main},{"PingHub\nInvisible Steal",panels["Invisible Steal Panel"]},
    {"PingHub\nActions",panels["Actions"]},{"PingHub\nSteal Panel",panels["Steal Panel"]},{"PingHub\nSteal Target",panels["Steal Target"]},
    {"PingHub\nAction Settings",actionSettingsPanel}}) do applySavedPosition(pair[1],pair[2]) end

-- =====================================================================
-- MOBILE PANEL FIT
-- ---------------------------------------------------------------------
-- Every floating panel above is placed with a desktop offset -- Action
-- Settings sits at 0.5,+745 and Actions at 0.5,+505. On a phone the viewport
-- is often under 500px wide, so those open far off the right edge with no way
-- to reach them: they are drag-only, and you cannot drag what you cannot see.
-- applySavedPosition makes it worse by restoring a position saved on desktop.
--
-- So on touch only: shrink anything bigger than the screen, then pull every
-- panel back inside it. Desktop is left exactly as it was.
-- =====================================================================
do
    local UIS_ = game:GetService("UserInputService")
    local touch = false
    touch = _G.Skyr0IsTouch == true   -- shared detector
    if touch then
        local function targets()
            return {
                panels["Steal Panel"], panels["Steal Target"],
                actionSettingsPanel,
                -- built lazily when Face Away is switched on, so it is nil here
                -- on a cold start; fit() skips nils and the builder calls
                -- _G.Skyr0FitPanel itself (below) the moment it exists
                panels["Face Away"],
            }
        end
        local function fit(f)
            if not f then return end
            task.defer(function()
                if not f.Parent then return end
                local cam = workspace.CurrentCamera
                local vp = (cam and cam.ViewportSize) or Vector2.new(390, 760)
                local sz = f.AbsoluteSize
                -- shrink first: a panel taller than the screen can never be
                -- clamped into it
                local w = math.min(sz.X, vp.X - 16)
                local h = math.min(sz.Y, vp.Y - 16)
                if w ~= sz.X or h ~= sz.Y then
                    f.Size = UDim2.fromOffset(math.floor(w), math.floor(h))
                end
                local pos = f.AbsolutePosition
                local nx = math.clamp(pos.X, 8, math.max(8, vp.X - w - 8))
                local ny = math.clamp(pos.Y, 8, math.max(8, vp.Y - h - 8))
                if nx ~= pos.X or ny ~= pos.Y then
                    f.Position = UDim2.fromOffset(math.floor(nx), math.floor(ny))
                end
            end)
        end
        -- so panels created after this block (Face Away) can fit themselves
        _G.Skyr0FitPanel = fit
        for _, f in ipairs(targets()) do fit(f) end
        -- re-fit on rotation, where the viewport swaps width for height
        local cam = workspace.CurrentCamera
        if cam then
            cam:GetPropertyChangedSignal("ViewportSize"):Connect(function()
                for _, f in ipairs(targets()) do fit(f) end
            end)
        end
    end
end

-- LAZY UI LOADING
if _G.addLazyUI then
    _G.addLazyUI(main, not Config.AutoCloseOnExec)
    _G.addLazyUI(actionSettingsPanel, false)
end

local immediatePanels = {
    ["Steal Target"] = true,
    ["Steal Panel"] = true,
    ["Invisible Steal Panel"] = true
}

for name, panel in pairs(panels) do
    if not string.match(name, "Body$") then
        -- _G._Skyr0PanelVis survives re-executes; override Config if it has a value
        local fromG = _G._Skyr0PanelVis[name]
        local targetVis
        if fromG ~= nil then
            targetVis = fromG
            Config.Visibilities[name] = fromG  -- sync back so Config is consistent
        else
            if Config.Visibilities[name] ~= nil then targetVis = Config.Visibilities[name] else targetVis = true end
        end
        if immediatePanels[name] then
            panel.Visible = targetVis
        elseif _G.addLazyUI then
            _G.addLazyUI(panel, targetVis, false, name)
        end
    end
end

-- ACTIONS PANEL 
function rebuildActions()
    clearBody(panels["ActionsBody"])
    if actionConfig["Insta Reset (H)"] then makeQuickButton(panels["ActionsBody"],"Insta Reset (H)",function() if _G.Skyr0InstaReset then pcall(_G.Skyr0InstaReset) end end) end
    if actionConfig["Rejoin PS"] then makeQuickButton(panels["ActionsBody"],"Rejoin PS",function() TeleportService:Teleport(game.PlaceId,player) end) end
    if actionConfig["Rejoin Job ID (J)"] then makeQuickButton(panels["ActionsBody"],"Rejoin Job ID (J)",function()
        pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player) end)
    end) end
    if actionConfig["Kick (Y)"] then makeQuickButton(panels["ActionsBody"],"Kick (Y)",function() kickPlayer() end) end
    if actionConfig["Kick To Private"] then makeQuickButton(panels["ActionsBody"],"Kick To Private",function()
        if PrivateServerCode and PrivateServerCode ~= "" then
            task.delay(0.2, function()
                pcall(function() game:GetService("ExperienceService"):LaunchExperience({placeId=game.PlaceId,linkCode=PrivateServerCode}) end)
            end)
        end
    end) end
    if actionConfig["Anti Ragdoll"] then makeSyncStateRow(panels["ActionsBody"],"Anti Ragdoll:","Anti Ragdoll",function(on) if on then startAntiRagdoll() else stopAntiRagdoll() end end) end
    if actionConfig["Infinite Jump"] then makeSyncStateRow(panels["ActionsBody"],"Infinite Jump:","Infinite Jump",function(on) setInfiniteJump(on) end) end
    if actionConfig["Float"] then makeSyncStateRow(panels["ActionsBody"],"Float:","Float",function(on) setFloat(on) end) end
    if actionConfig["Carpet Speed"] then makeSyncStateRow(panels["ActionsBody"],"Carpet Speed:","Carpet Speed",function(on) setCarpetSpeed(on) end) end
    if actionConfig["Auto Turret"] then makeSyncStateRow(panels["ActionsBody"],"Auto Turret:","Auto Turret",function(on) Config.AutoDestroyTurrets=on; saveConfig() end) end
    if actionConfig["WalkSpeed"] then makeSyncStateRow(panels["ActionsBody"],"WalkSpeed:","WalkSpeed",function(on) if _G.setWalkSpeedEnabled then _G.setWalkSpeedEnabled(on) end end) end
    -- extra hub features toggleable from Actions (excludes Auto-TP + keybinds): {label, syncToggleName, callback}
    local EXTRA_ACTIONS = {
        {"FPS Boost","FPS Boost (normal)",function(on) if setFPSBoost then pcall(setFPSBoost,on) end end},
        {"Xray","XRay",function(on) if _G.setXRay then pcall(_G.setXRay,on) end end},
        {"Player ESP","Player ESP",function(on) if _G.setPlayerESP then _G.setPlayerESP(on) end end},
        {"Brainrot ESP","Brainrot ESP",function(on) if _G.setBrainrotESP then _G.setBrainrotESP(on) end end},
        {"Base Owner ESP","Base Owner ESP",function(on) if _G.setBaseOwnerESP then _G.setBaseOwnerESP(on) end end},
        {"Unwalk","Unwalk",function(on) if _G.setUnwalk then _G.setUnwalk(on) end end},
    }
    for _,a in ipairs(EXTRA_ACTIONS) do
        if actionConfig[a[1]] then makeSyncStateRow(panels["ActionsBody"],a[1]..":",a[2],a[3]) end
    end
    if actionConfig["Teleport"] then makeQuickButton(panels["ActionsBody"],"Teleport",function()
        if _G.Skyr0ManualTP then _G.Skyr0ManualTP() else task.spawn(runAutoSnipe) end
    end) end
    if actionConfig["Grapple TP"] then makeQuickButton(panels["ActionsBody"],"Grapple TP",function()
        if _G.Skyr0LaunchTP then _G.Skyr0LaunchTP() else task.spawn(runAutoSnipe) end
    end) end
    if actionConfig["Menu"] then makeQuickButton(panels["ActionsBody"],"Menu",function()
        if main.Visible then closeAnim(main) else openAnim(main) end
    end) end
    makeQuickButton(panels["ActionsBody"],"Settings",function()
        if actionSettingsPanel.Visible then closeAnim(actionSettingsPanel) else openAnim(actionSettingsPanel) end
    end,Theme.SoftAccent)
end

function rebuildActionSettings()
    clearBody(actionSettingsBody)
    for actionName,enabled in pairs(actionConfig) do
        local row=Instance.new("Frame"); row.Size=UDim2.new(1,-4,0,34); row.BackgroundTransparency=1; row.Parent=actionSettingsBody
        local label=Instance.new("TextLabel"); label.Size=UDim2.new(1,-84,1,0); label.Position=UDim2.new(0,4,0,0); label.BackgroundTransparency=1; label.Text=actionName; label.TextColor3=Theme.Text; label.Font=Enum.Font.GothamSemibold; label.TextSize=11; label.TextXAlignment=Enum.TextXAlignment.Left; label.TextTruncate=Enum.TextTruncate.AtEnd; label.Parent=row
        local btn=Instance.new("TextButton"); btn.Name="WhiteTextBtn"; btn.Size=UDim2.new(0,72,0,30); btn.Position=UDim2.new(1,-74,0.5,-15); btn.BackgroundColor3=enabled and Theme.Green or Theme.ToggleOff2; btn.Text=enabled and "ON" or "OFF"; btn.TextColor3=enabled and Color3.fromRGB(15,15,15) or Color3.fromRGB(255,255,255); btn.Font=Enum.Font.GothamBlack; btn.TextSize=12; btn.AutoButtonColor=false; btn.Parent=row; corner(btn,6)
        btn.MouseButton1Click:Connect(function()
            actionConfig[actionName]=not actionConfig[actionName]; Config.actions[actionName]=actionConfig[actionName]; saveConfig()
            btn.BackgroundColor3=actionConfig[actionName] and Theme.Green or Theme.ToggleOff2; btn.Text=actionConfig[actionName] and "ON" or "OFF"; btn.TextColor3=actionConfig[actionName] and Color3.fromRGB(15,15,15) or Color3.fromRGB(255,255,255)
            rebuildActions()
        end)
    end
    makeQuickButton(actionSettingsBody,"Close",function() closeAnim(actionSettingsPanel) end,Theme.SoftAccentHover)
end

-- (separate TP & Clone Settings panel removed; all TP settings now inline in the Auto TP tab)

do
    -- INVISIBLE STEAL PANEL POPULATION
    regToggle("Auto Recover Lagback", Config.AutoRecoverLagback)
    regToggle("Auto Steal Speed", Config.AutoStealSpeed)
    regToggle("Auto Invis During Steal", Config.AutoInvisDuringSteal)

    local enabledRow = makeSyncStateRow(panels["InvisStealBody"],"Enabled:","Invisible Steal",function(on) if _G.toggleInvisibleSteal then pcall(_G.toggleInvisibleSteal) end end)

    _G.updateMovementPanelLabels = function() end
    local rotSlider = makeQuickSlider(panels["InvisStealBody"],"Rotation",0,360,Config.InvisStealAngle or 225,function(v) _G.InvisStealAngle=v; Config.InvisStealAngle=v; saveConfig() end)
    local depthSlider = makeQuickSlider(panels["InvisStealBody"],"Depth",0,18,Config.SinkSliderValue or 7,function(v) _G.SinkSliderValue=v; Config.SinkSliderValue=v; saveConfig() end)
    local recoverToggle = makeSyncStateRow(panels["InvisStealBody"],"Auto Recover:","Auto Recover Lagback",function(on) _G.AutoRecoverLagback=on; Config.AutoRecoverLagback=on; saveConfig() end)
    local autoInvisToggle = makeSyncStateRow(panels["InvisStealBody"],"Auto Invis:","Auto Invis During Steal",function(on) _G.AutoInvisDuringSteal=on; Config.AutoInvisDuringSteal=on; saveConfig() end)

    -- WALKSPEED CONTROL (CFrame Bypass, min 15 max 29)
    regToggle("WalkSpeed", Config.WalkSpeedEnabled)
    makeSyncStateRow(panels["InvisStealBody"],"WalkSpeed:","WalkSpeed",function(on) setWalkSpeedEnabled(on) end)
    makeMainSliderWithInput(panels["InvisStealBody"], "Walk Speed", 15, 29, Config.WalkSpeedValue or 16, function(v)
        local clamped = setWalkSpeedValue(v)
    end)
    if Config.WalkSpeedEnabled then
        task.defer(function() setWalkSpeedEnabled(true) end)
    end


-- ADMIN QUICK PANEL

-- ADMIN QUICK PANEL
-- (Spam Base Owner, Admin Command Panel rows and Cooldown Panel removed)

-- STEAL PANEL
makeSyncStateRow(panels["StealBody"],"Auto Steal:","Auto Steal",function(on)
    autoStealEnabled=on; Config.AutoStealEnabled=on; saveConfig()
    -- Skyr0 Clone-TP engine owns the auto-steal loop unconditionally.
    if _G.Skyr0AutoSteal then pcall(_G.Skyr0AutoSteal, on) end
end)
makeSyncStateRow(panels["StealBody"],"Steal Highest:","Steal Highest",function(on) if on then setStealMode("Highest") end end)
makeSyncStateRow(panels["StealBody"],"Steal Priority:","Steal Priority",function(on) if on then setStealMode("Priority") end end)
makeSyncStateRow(panels["StealBody"],"Steal Nearest:","Steal Nearest",function(on) if on then setStealMode("Nearest") end end)
makeSyncStateRow(panels["StealBody"],"Auto Buy:","Auto Buy",function(on) if toggleAutoBuy then toggleAutoBuy(on) end end)
makeQuickSlider(panels["StealBody"],"Buy Range",1,50,Config.AutoBuyRange or 17,function(v) Config.AutoBuyRange=v; saveConfig() end," studs")
makeQuickSlider(panels["StealBody"],"Grab Speed",1,50,Config.AutoGrabSpeed or 17,function(v) Config.AutoGrabSpeed=v; saveConfig() end)
makeSyncStateRow(panels["StealBody"],"Auto Kick:","Auto Kick",function(on) Config.AutoKickOnSteal=on; saveConfig() end)



-- STEAL TARGET (0.4s refresh) -- NOT lazy: panel must populate on load
do -- STEAL TARGET SCOPE
-- ============================================================
-- BRAINROT THUMBNAILS
-- Executors can't point ImageLabel.Image straight at an http URL,
-- so each brainrot PNG is downloaded from the CDN once, cached to
-- disk and exposed through getcustomasset. Results are memo-cached
-- so the 0.4s panel refresh never re-downloads.
-- ============================================================
local BrainrotImg = {}
do
    local cache  = {}   -- key -> loadable asset id (resolved, ready to use)
    local status = {}   -- key -> "pending" | "failed" (absent = not started)
    local fails  = {}   -- key -> failed attempt count (caps pointless CDN retries)
    local warned = false

    local httpreq = request or http_request or (http and http.request)
        or (syn and syn.request) or (fluxus and fluxus.request)
        or (getgenv and getgenv().request)
    local customasset = (typeof(getcustomasset) == "function" and getcustomasset)
        or (typeof(getsynasset) == "function" and getsynasset)
        or (typeof(getcustomasseturl) == "function" and getcustomasseturl)
        or (syn and typeof(syn.getcustomasset) == "function" and syn.getcustomasset)
        or nil
    local canFiles = typeof(writefile) == "function" and typeof(isfile) == "function"

    -- one-time capability dump (open the executor console to read it)
    print(("[skyr0 thumbs] httpreq=%s  getcustomasset=%s  writefile=%s  isfile=%s"):format(
        httpreq and "yes" or "NO",
        customasset and "yes" or "NO",
        typeof(writefile) == "function" and "yes" or "NO",
        typeof(isfile) == "function" and "yes" or "NO"))

    -- Accept any sizable non-error body. The PNG magic bytes aren't reliable here:
    -- some executors (e.g. Volt) sanitize the high 0x89 signature byte when handing
    -- the response back as a Lua string, which false-negatives a perfectly good image.
    -- The CDN's "missing" response is a ~65-byte JSON blob, so a length gate plus a
    -- JSON/HTML sniff cleanly separates real images from errors.
    local function looksValid(b)
        return type(b) == "string" and #b > 200
            and b:sub(1, 1) ~= "{" and b:sub(1, 1) ~= "<"
    end

    local function download(url)
        -- request() returns raw binary reliably; HttpGet is the fallback because some
        -- executors mangle binary bytes when returning the body as a string.
        if httpreq then
            local ok, res = pcall(httpreq, {Url = url, Method = "GET"})
            if ok and type(res) == "table" then
                local body = res.Body or res.body
                if looksValid(body) then return body end
            end
        end
        local ok2, body = pcall(function() return game:HttpGet(url) end)
        if ok2 and looksValid(body) then return body end
        return nil
    end

    -- Returns a ready-to-use asset id, or nil while it loads in the background.
    -- The next 0.4s refresh picks up the cached image with no extra work.
    function BrainrotImg.get(name)
        if not name or name == "" then return nil end
        local key = tostring(name):gsub(" ", "_")
        if cache[key] then return cache[key] end
        if status[key] then return nil end                       -- pending or recently failed
        if not (canFiles and customasset) then status[key] = "failed"; return nil end
        status[key] = "pending"
        task.spawn(function()
            local fileKey = key:gsub("[^%w_%-]", "")             -- filesystem-safe name
            -- try a subfolder path first, then a flat path (some executors won't auto-create folders)
            local paths = { "skyr0_brainrots/" .. fileKey .. ".png", "skyr0_br_" .. fileKey .. ".png" }
            local asset, reason

            -- reuse a file cached from a previous session
            for _, p in ipairs(paths) do
                local exists = false
                pcall(function() exists = isfile(p) end)
                if exists then
                    local ok, a = pcall(customasset, p)
                    if ok and a then asset = a; break end
                end
            end

            -- otherwise download -> save -> load
            if not asset then
                local bytes = download(string.format("https://cdn.lura.blue/sab/%s.png", key))
                if not bytes then
                    reason = "download failed"
                else
                    for _, p in ipairs(paths) do
                        if pcall(writefile, p, bytes) then
                            local ok, a = pcall(customasset, p)
                            if ok and a then asset = a; break else reason = "getcustomasset error" end
                        else
                            reason = reason or "writefile error"
                        end
                    end
                end
            end

            if asset then
                cache[key], status[key], fails[key] = asset, nil, nil
            else
                if not warned then
                    warned = true
                    warn("[skyr0 thumbs] '" .. key .. "' -> " .. (reason or "unknown")
                        .. "  (httpreq=" .. (httpreq and "y" or "n")
                        .. " customasset=" .. (customasset and "y" or "n") .. ")")
                end
                fails[key] = (fails[key] or 0) + 1
                status[key] = "failed"
                if fails[key] < 3 then   -- transient error? retry a few times, then stop for the session
                    task.delay(15, function() if status[key] == "failed" then status[key] = nil end end)
                end
            end
        end)
        return nil
    end
end
_G.Skyr0_GetBrainrotImg = BrainrotImg.get   -- shared with the priority-alert banner

-- =====================================================================
-- refreshTargetPanel  --  NOW ONLY REDRAWS WHEN THERE IS SOMETHING NEW.
-- ---------------------------------------------------------------------
-- This ran every 0.4s unconditionally, and every run DESTROYED and REBUILT
-- the entire list: each row is ~12 instances (frame, corner, stroke, rank box,
-- two labels, thumbnail holder, image, click overlay) plus a fresh
-- MouseButton1Click closure. Sixty pets on a busy server is ~700 instances
-- created and destroyed every 0.4s -- roughly 1,800 a second of pure churn,
-- for a list that usually looks exactly the same as it did last time. It ran
-- even with the panel closed, where nobody could see any of it.
--
-- Two gates now:
--   * the panel is not visible -> do nothing at all;
--   * nothing that affects the drawing has changed -> keep what is on screen.
-- The signature is O(1) (a cache version, not a walk of the pet list) because
-- the scanner already tells us when the underlying data actually moved.
--
-- Side benefit: the list no longer resets its scroll position and flickers
-- two and a half times a second while you are trying to click a row.
-- =====================================================================
function refreshTargetPanel(force)
    local _panel = panels and panels["Steal Target"]
    if not force and _panel and not _panel.Visible then return end
    local _sig = tostring(SharedState.CacheVersion or 0)
        .. "|" .. tostring(selectedTargetUID) .. "|" .. tostring(manuallySelectedUID)
        .. "|" .. tostring(Config.DarkMode)
        .. "|" .. tostring(Config.StealNearest)
        .. "|" .. tostring(Config.TpSettings.MinGenForTp) .. "|" .. tostring(Config.TpSettings.MinGenForGrab)
        .. "|" .. table.concat(priorityList, ",")
    -- signature parked on SharedState, not a new chunk-level local (register budget)
    if not force and SharedState.__tgtSig == _sig then return end
    SharedState.__tgtSig = _sig

    clearBody(panels["TargetBody"])
    local cache = get_all_pets()
    if not cache or #cache == 0 then
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1,-4,0,24)
        l.BackgroundTransparency = 1
        l.Text = "Scanning..."
        l.TextColor3 = Theme.Dim
        l.Font = Enum.Font.GothamSemibold
        l.TextSize = 11
        l.TextXAlignment = Enum.TextXAlignment.Center
        l.Parent = panels["TargetBody"]
        return
    end

    -- Build priority lookup
    local prioSet = {}
    for _, pName in ipairs(priorityList) do prioSet[pName:lower()] = true end

    -- Split into priority and non-priority
    local prioPets, otherPets = {}, {}
    for _, pet in ipairs(cache) do
        local isBrainrot = (pet.mpsValue and pet.mpsValue >= 10000000)
        if isBrainrot or (pet.petName and prioSet[pet.petName:lower()]) then
            table.insert(prioPets, pet)
        else
            table.insert(otherPets, pet)
        end
    end

    -- Sort priority pets by priority list order, keeping Brainrots at the absolute top
    table.sort(prioPets, function(a, b)
        local ai, bi = 999, 999
        for idx, pn in ipairs(priorityList) do
            local pnL = pn:lower()
            if a.petName and a.petName:lower() == pnL then ai = idx end
            if b.petName and b.petName:lower() == pnL then bi = idx end
        end
        
        local aIsBrainrot = (a.mpsValue and a.mpsValue >= 10000000)
        local bIsBrainrot = (b.mpsValue and b.mpsValue >= 10000000)
        
        if aIsBrainrot and not bIsBrainrot then return true end
        if bIsBrainrot and not aIsBrainrot then return false end
        
        if ai == bi then return (a.mpsValue or 0) > (b.mpsValue or 0) end
        return ai < bi
    end)

    local function makeTargetRow(pet, displayIndex, isPriority)
        local isSelected = (selectedTargetUID == pet.uid)
        local isManual = (manuallySelectedUID == pet.uid)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1,-4,0,44)
        row.BackgroundColor3 = isSelected and Theme.RowHover or Theme.Panel
        row.BackgroundTransparency = isPriority and 0.3 or 0.45
        row.Parent = panels["TargetBody"]
        corner(row, 6)
        if isSelected or isManual then
            local str = Instance.new("UIStroke", row)
            str.Color = isManual and Color3.fromRGB(56, 214, 110) or Theme.Accent
            str.Thickness = isManual and 1.75 or 1.25
        elseif isPriority then
            local str = Instance.new("UIStroke", row)
            str.Color = Color3.fromRGB(255, 90, 120)
            str.Thickness = 0.75
            str.Transparency = 0.3
        end
        
        local rankBox = Instance.new("Frame")
        rankBox.Size = UDim2.new(0, 26, 0, 26)
        rankBox.Position = UDim2.new(0, 8, 0.5, -13)
        rankBox.BackgroundColor3 = Color3.fromRGB(48, 48, 52)
        rankBox.BorderSizePixel = 0
        rankBox.Parent = row
        corner(rankBox, 4)
        local rkst = Instance.new("UIStroke", rankBox); rkst.Color = Theme.Stroke; rkst.Thickness = 1; rkst.Transparency = 0.4

        local n = Instance.new("TextLabel")
        n.Size = UDim2.new(1,0,1,0)
        n.BackgroundTransparency = 1
        n.Text = "#"..displayIndex
        n.TextColor3 = Color3.new(1,1,1)
        n.Font = Enum.Font.GothamBold
        n.TextSize = 11
        n.Parent = rankBox

        -- brainrot thumbnail (right of the rank number, left of the name)
        local imgHolder = Instance.new("Frame")
        imgHolder.Size = UDim2.new(0, 34, 0, 34)
        imgHolder.Position = UDim2.new(0, 40, 0.5, -17)
        imgHolder.BackgroundColor3 = Theme.SoftAccent
        imgHolder.BackgroundTransparency = 0.35
        imgHolder.BorderSizePixel = 0
        imgHolder.Parent = row
        corner(imgHolder, 6)

        local img = Instance.new("ImageLabel")
        img.Size = UDim2.new(1, -4, 1, -4)
        img.Position = UDim2.new(0, 2, 0, 2)
        img.BackgroundTransparency = 1
        img.ScaleType = Enum.ScaleType.Fit
        img.Image = BrainrotImg.get(pet.petName) or ""
        img.Parent = imgHolder

        local nm = Instance.new("TextLabel")
        nm.Size = UDim2.new(1,-86,0,18)
        nm.Position = UDim2.new(0,80,0,5)
        nm.BackgroundTransparency = 1
        nm.Text = pet.petName or "?"
        nm.TextColor3 = isPriority and Color3.new(1,1,1) or Theme.Text
        nm.Font = isPriority and Enum.Font.GothamBold or Enum.Font.GothamSemibold
        nm.TextSize = 13
        nm.TextXAlignment = Enum.TextXAlignment.Left
        nm.TextTruncate = Enum.TextTruncate.AtEnd
        nm.Parent = row
        
        local gn = Instance.new("TextLabel")
        gn.Size = UDim2.new(1,-86,0,14)
        gn.Position = UDim2.new(0,80,0,23)
        gn.BackgroundTransparency = 1
        gn.RichText = true
        local ownerText = pet.owner and (' <font color="#999999">| @' .. tostring(pet.owner) .. '</font>') or ""
        gn.Text = '<font color="#38D66E">Gem: ' .. (pet.mpsText or "") .. '</font>' .. ownerText
        gn.TextColor3 = Color3.new(1,1,1)
        gn.Font = Enum.Font.GothamMedium
        gn.TextSize = 11
        gn.TextXAlignment = Enum.TextXAlignment.Left
        gn.TextTruncate = Enum.TextTruncate.AtEnd
        gn.Parent = row

        local overlay = Instance.new("TextButton")
        overlay.Size = UDim2.new(1,0,1,0)
        overlay.BackgroundTransparency = 1
        overlay.Text = ""
        overlay.ZIndex = 8
        overlay.Parent = row
        overlay.MouseButton1Click:Connect(function()
            if manuallySelectedUID == pet.uid then
                manuallySelectedUID = nil
                selectedTargetUID = nil
                SharedState.SelectedPetData = nil
            else
                selectedTargetUID = pet.uid
                manuallySelectedUID = pet.uid
                SharedState.SelectedPetData = pet
                if pet then SharedState.LastTargetedPetMpsValue = pet.mpsValue or 0 end
            end
            refreshTargetPanel()

            if manuallySelectedUID then
                task.spawn(function()
                    local pr = PromptMemoryCache[pet.uid] or findProximityPromptForAnimal(pet.animalData)
                    if pr then
                        if _G.Skyr0_ExecuteManualSteal then
                            pcall(_G.Skyr0_ExecuteManualSteal, pr)
                        end
                    end
                end)
            end
        end)
    end

    local idx = 0
    for _, pet in ipairs(prioPets) do idx = idx + 1; makeTargetRow(pet, idx, true) end

    if #prioPets > 0 and #otherPets > 0 then
        local sep = Instance.new("Frame")
        sep.Size = UDim2.new(1,-20,0,1)
        sep.BackgroundColor3 = Theme.AccentLight
        sep.BackgroundTransparency = 0.5
        sep.BorderSizePixel = 0
        sep.Parent = panels["TargetBody"]
    end

    for _, pet in ipairs(otherPets) do idx = idx + 1; makeTargetRow(pet, idx, false) end
end
task.spawn(function() while true do task.wait(0.4); refreshTargetPanel() end end)
end -- END STEAL TARGET SCOPE

-- (ADMIN PANEL UI removed)

-- ============================================================
-- TAB BAR + TABS
-- ============================================================
-- LEFT SIDEBAR layout (22S-style, sxe glass design): vertical tabs + player profile.
-- Wrapped in an IIFE (its OWN function register frame) so its locals cost the main chunk
-- ZERO registers -- a bare do-block shares the main chunk's frame, which sits right at
-- Luau's 200-local limit and would overflow.
;(function()
-- =====================================================================
-- SIDEBAR + TABS (rewritten)
-- ---------------------------------------------------------------------
-- Desktop keeps the vertical rail. On touch the rail would eat a third of a
-- phone screen, so the same tabs become a horizontal strip across the top and
-- the body reclaims the full width.
--
-- The selection indicator is one sliding pill rather than recolouring every
-- button each switch: a single tween instead of seven, and it reads as
-- movement rather than a flicker.
-- =====================================================================
local UIS_ = game:GetService("UserInputService")
-- Only PHONES get the horizontal tab strip. A tablet has the width for the
-- sidebar rail, and collapsing it there wastes the screen it does have.
local TOUCH = _G.Skyr0IsPhone == true

local tabs={"Keybinds","Auto TP","ESP","UI","Misc","Priority","Performance"}

local rail, indicator
if TOUCH then
    -- horizontal strip
    mainBody.Position = UDim2.new(0, 10, 0, 96)
    mainBody.Size     = UDim2.new(1, -20, 1, -106)

    rail=Instance.new("ScrollingFrame")
    rail.Name="TabRail"
    rail.Size=UDim2.new(1,-20,0,38); rail.Position=UDim2.new(0,10,0,50)
    rail.BackgroundColor3=Theme.Panel; rail.BackgroundTransparency=0.3; rail.BorderSizePixel=0
    rail.ScrollBarThickness=0; rail.ScrollingDirection=Enum.ScrollingDirection.X
    rail.AutomaticCanvasSize=Enum.AutomaticSize.X; rail.CanvasSize=UDim2.new()
    rail.Parent=main; corner(rail,10)
    local l=Instance.new("UIListLayout"); l.FillDirection=Enum.FillDirection.Horizontal
    l.Padding=UDim.new(0,4); l.SortOrder=Enum.SortOrder.LayoutOrder; l.VerticalAlignment=Enum.VerticalAlignment.Center; l.Parent=rail
    local p=Instance.new("UIPadding"); p.PaddingLeft=UDim.new(0,4); p.PaddingRight=UDim.new(0,4); p.Parent=rail
else
    mainBody.Position = UDim2.new(0, 122, 0, 52)
    mainBody.Size     = UDim2.new(1, -130, 1, -60)

    local sidebar=Instance.new("Frame"); sidebar.Name="Sidebar"
    sidebar.Size=UDim2.new(0,106,1,-60); sidebar.Position=UDim2.new(0,8,0,52)
    sidebar.BackgroundColor3=Theme.Panel; sidebar.BackgroundTransparency=0.3; sidebar.BorderSizePixel=0
    sidebar.Parent=main; corner(sidebar,10)
    do local s=Instance.new("UIStroke",sidebar); s.Color=Theme.Stroke; s.Thickness=1; s.Transparency=0.45 end

    rail=Instance.new("Frame"); rail.Name="TabRail"
    rail.Size=UDim2.new(1,-12,1,-62); rail.Position=UDim2.new(0,6,0,6)
    rail.BackgroundTransparency=1; rail.Parent=sidebar

    -- Player profile pinned to the bottom of the rail.
    local prof=Instance.new("Frame"); prof.Name="Profile"
    prof.Size=UDim2.new(1,-12,0,46); prof.Position=UDim2.new(0,6,1,-52)
    prof.BackgroundColor3=Theme.SoftAccent; prof.BackgroundTransparency=0.15; prof.BorderSizePixel=0
    prof.Parent=sidebar; corner(prof,10)
    local av=Instance.new("ImageLabel"); av.Size=UDim2.fromOffset(28,28); av.Position=UDim2.new(0,8,0.5,-14)
    av.BackgroundColor3=Theme.InputBg; av.BorderSizePixel=0
    av.Image="rbxthumb://type=AvatarHeadShot&id="..tostring(LocalPlayer.UserId).."&w=150&h=150"
    av.Parent=prof; corner(av,20)
    do local s=Instance.new("UIStroke",av); s.Color=Theme.Accent; s.Thickness=1; s.Transparency=0.3 end
    local nm=Instance.new("TextLabel"); nm.Size=UDim2.new(1,-44,0,13); nm.Position=UDim2.new(0,42,0,10)
    nm.BackgroundTransparency=1; nm.Text=tostring(LocalPlayer.DisplayName); nm.TextColor3=Theme.Text
    nm.Font=Enum.Font.GothamBold; nm.TextSize=10; nm.TextXAlignment=Enum.TextXAlignment.Left
    nm.TextTruncate=Enum.TextTruncate.AtEnd; nm.Parent=prof
    local un=Instance.new("TextLabel"); un.Size=UDim2.new(1,-44,0,11); un.Position=UDim2.new(0,42,0,25)
    un.BackgroundTransparency=1; un.Text="@"..tostring(LocalPlayer.Name); un.TextColor3=Theme.Dim
    un.Font=Enum.Font.GothamMedium; un.TextSize=9; un.TextXAlignment=Enum.TextXAlignment.Left
    un.TextTruncate=Enum.TextTruncate.AtEnd; un.Parent=prof
end

-- The sliding selection pill, drawn behind the labels.
indicator=Instance.new("Frame"); indicator.Name="TabIndicator"
indicator.BackgroundColor3=Theme.Accent; indicator.BorderSizePixel=0; indicator.ZIndex=1
indicator.Size = TOUCH and UDim2.fromOffset(0,30) or UDim2.new(1,0,0,30)
indicator.Parent=rail; corner(indicator,7)

local BTN_H, STEP = 30, 34
for i,name in ipairs(tabs) do
    local b=Instance.new("TextButton")
    if TOUCH then
        b.Size=UDim2.fromOffset(92,30); b.LayoutOrder=i
    else
        b.Size=UDim2.new(1,0,0,BTN_H); b.Position=UDim2.new(0,0,0,(i-1)*STEP)
    end
    b.BackgroundTransparency=1
    b.Text=name; b.TextColor3=Theme.Dim
    b.Font=Enum.Font.GothamSemibold; b.TextSize=11
    b.AutoButtonColor=false; b.BorderSizePixel=0; b.ZIndex=2
    b.Parent=rail
    tabButtons[name]=b

    local function press() if loadTab then loadTab(name) end end
    if _G.Skyr0BindPress then _G.Skyr0BindPress(b, press) else b.MouseButton1Click:Connect(press) end
end

-- loadTab recolours tabButtons itself; this keeps the pill following the
-- active one without loadTab needing to know the indicator exists.
task.spawn(function()
    local last
    while rail.Parent do
        local cur = UI and UI.CurrentTab
        if cur ~= last and tabButtons[cur] then
            last = cur
            local b = tabButtons[cur]
            if TOUCH then
                tw(indicator,{Position=UDim2.fromOffset(b.AbsolutePosition.X - rail.AbsolutePosition.X + rail.CanvasPosition.X, 0), Size=UDim2.fromOffset(b.AbsoluteSize.X,30)},0.18)
            else
                tw(indicator,{Position=b.Position, Size=UDim2.new(1,0,0,BTN_H)},0.18)
            end
        end
        task.wait(0.08)
    end
end)
end)()

-- Cache all animal names for autocomplete. Source per request:
-- ReplicatedStorage.Animations.Animals (animation instances are named after
-- each brainrot). Fallback: ReplicatedStorage.Models.Animals if Animations
-- isn't present in the place.
local _allAnimalNames = nil
local function getAllAnimalNames()
    if _allAnimalNames and #_allAnimalNames > 0 then return _allAnimalNames end
    _allAnimalNames = {}
    pcall(function()
        local source = ReplicatedStorage:FindFirstChild("Animations")
        source = source and source:FindFirstChild("Animals")
        if not source then
            -- fallback if Animations.Animals isn't present
            local models = ReplicatedStorage:FindFirstChild("Models")
            source = models and models:FindFirstChild("Animals")
        end
        if source then
            local seen = {}
            for _, child in ipairs(source:GetChildren()) do
                if not seen[child.Name] then
                    seen[child.Name] = true
                    table.insert(_allAnimalNames, child.Name)
                end
            end
            table.sort(_allAnimalNames, function(a, b) return a:lower() < b:lower() end)
        end
    end)
    return _allAnimalNames
end
task.spawn(getAllAnimalNames)

-- Drag state for priority reorder
local _priDragState = {active = false, fromIndex = nil, ghostFrame = nil, overlay = nil}

local function cleanupPriDrag()
    if _priDragState.ghostFrame then pcall(function() _priDragState.ghostFrame:Destroy() end); _priDragState.ghostFrame = nil end
    if _priDragState.overlay then pcall(function() _priDragState.overlay:Destroy() end); _priDragState.overlay = nil end
    _priDragState.active = false; _priDragState.fromIndex = nil
end

function makePriorityRow(index)
    local row=Instance.new("Frame"); row.Size=UDim2.new(1,-4,0,31); row.BackgroundColor3=Theme.Panel; row.BackgroundTransparency=0.3; row.Parent=mainBody; corner(row,6); row.LayoutOrder=index

    -- Number label
    local num=Instance.new("TextLabel"); num.Size=UDim2.new(0,24,1,0); num.Position=UDim2.new(0,4,0,0); num.BackgroundTransparency=1; num.Text=tostring(index).."."; num.TextColor3=Theme.Dim; num.Font=Enum.Font.GothamBold; num.TextSize=10; num.TextXAlignment=Enum.TextXAlignment.Left; num.Parent=row

    local l=Instance.new("TextLabel"); l.Size=UDim2.new(1,-120,1,0); l.Position=UDim2.new(0,28,0,0); l.BackgroundTransparency=1; l.Text=priorityList[index]; l.TextColor3=Theme.Text; l.Font=Enum.Font.GothamMedium; l.TextSize=10; l.TextXAlignment=Enum.TextXAlignment.Left; l.TextTruncate=Enum.TextTruncate.AtEnd; l.Parent=row

    local up=Instance.new("TextButton"); up.Name="WhiteTextBtn"; up.Size=UDim2.new(0,26,0,22); up.Position=UDim2.new(1,-86,0.5,-11); up.BackgroundColor3=Theme.Accent; up.Text="^"; up.TextColor3=Color3.fromRGB(25,25,28); up.Font=Enum.Font.GothamBold; up.TextSize=10; up.Parent=row; corner(up,5)
    local dn=Instance.new("TextButton"); dn.Name="WhiteTextBtn"; dn.Size=UDim2.new(0,26,0,22); dn.Position=UDim2.new(1,-56,0.5,-11); dn.BackgroundColor3=Theme.Accent; dn.Text="v"; dn.TextColor3=Color3.fromRGB(25,25,28); dn.Font=Enum.Font.GothamBold; dn.TextSize=10; dn.Parent=row; corner(dn,5)
    local del=Instance.new("TextButton"); del.Name="WhiteTextBtn"; del.Size=UDim2.new(0,26,0,22); del.Position=UDim2.new(1,-26,0.5,-11); del.BackgroundColor3=Theme.Red; del.Text="X"; del.TextColor3=Color3.new(1,1,1); del.Font=Enum.Font.GothamBold; del.TextSize=10; del.Parent=row; corner(del,5)
    up.MouseButton1Click:Connect(function() if index>1 then priorityList[index],priorityList[index-1]=priorityList[index-1],priorityList[index]; Config.PriorityList=priorityList; saveConfig(); loadTab("Priority") end end)
    dn.MouseButton1Click:Connect(function() if index<#priorityList then priorityList[index],priorityList[index+1]=priorityList[index+1],priorityList[index]; Config.PriorityList=priorityList; saveConfig(); loadTab("Priority") end end)
    del.MouseButton1Click:Connect(function() local removedName=priorityList[index]; table.remove(priorityList,index); if not Config.RemovedFromPriority then Config.RemovedFromPriority={} end; local alreadyRemoved=false; for _,rn in ipairs(Config.RemovedFromPriority) do if rn==removedName then alreadyRemoved=true; break end end; if not alreadyRemoved then table.insert(Config.RemovedFromPriority,removedName) end; Config.PriorityList=priorityList; saveConfig(); loadTab("Priority") end)

    -- Drag & Drop
    local dragHandle = Instance.new("TextButton"); dragHandle.Size=UDim2.new(0,24,1,0); dragHandle.Position=UDim2.new(0,0,0,0); dragHandle.BackgroundTransparency=1; dragHandle.Text=""; dragHandle.ZIndex=9; dragHandle.Parent=row
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
        cleanupPriDrag()
        _priDragState.active = true; _priDragState.fromIndex = index

        local ghost = Instance.new("Frame"); ghost.Size = UDim2.new(0, row.AbsoluteSize.X, 0, 31)
        ghost.BackgroundColor3 = Theme.Accent; ghost.BackgroundTransparency = 0.55; ghost.BorderSizePixel = 0; ghost.ZIndex = 100
        ghost.Parent = gui_sg; corner(ghost, 6)
        local gl = Instance.new("TextLabel"); gl.Size = UDim2.new(1,0,1,0); gl.BackgroundTransparency = 1; gl.Text = tostring(index)..". "..priorityList[index]; gl.TextColor3 = Color3.new(1,1,1); gl.Font = Enum.Font.GothamBold; gl.TextSize = 10; gl.Parent = ghost
        _priDragState.ghostFrame = ghost

        local moveConn, endConn
        moveConn = UIS.InputChanged:Connect(function(mi)
            if mi.UserInputType == Enum.UserInputType.MouseMovement or mi.UserInputType == Enum.UserInputType.Touch then
                ghost.Position = UDim2.new(0, mi.Position.X - ghost.AbsoluteSize.X/2, 0, mi.Position.Y - 15)
            end
        end)
        endConn = UIS.InputEnded:Connect(function(ei)
            if ei.UserInputType ~= Enum.UserInputType.MouseButton1 and ei.UserInputType ~= Enum.UserInputType.Touch then return end
            moveConn:Disconnect(); endConn:Disconnect()
            if not _priDragState.active then cleanupPriDrag(); return end

            -- Determine drop target index from Y position
            local dropY = ei.Position.Y
            local targetIndex = #priorityList
            for _, child in ipairs(mainBody:GetChildren()) do
                if child:IsA("Frame") and child.LayoutOrder and child.LayoutOrder >= 1 and child.LayoutOrder <= #priorityList then
                    local absY = child.AbsolutePosition.Y
                    local absH = child.AbsoluteSize.Y
                    if dropY < absY + absH / 2 then
                        targetIndex = child.LayoutOrder
                        break
                    end
                end
            end
            local fromIdx = _priDragState.fromIndex
            cleanupPriDrag()
            if fromIdx and targetIndex and fromIdx ~= targetIndex then
                local item = table.remove(priorityList, fromIdx)
                if targetIndex > fromIdx then targetIndex = targetIndex - 1 end
                targetIndex = math.clamp(targetIndex, 1, #priorityList + 1)
                table.insert(priorityList, targetIndex, item)
                Config.PriorityList = priorityList; saveConfig()
                loadTab("Priority")
            end
        end)
    end)
end

-- One mutation, with the same up/down controls the pet rows use.
function makeMutationRow(index)
    local row=Instance.new("Frame"); row.Size=UDim2.new(1,-4,0,28); row.BackgroundColor3=Theme.Panel; row.BackgroundTransparency=0.35; row.Parent=mainBody; corner(row,6)

    local num=Instance.new("TextLabel"); num.Size=UDim2.new(0,24,1,0); num.Position=UDim2.new(0,6,0,0); num.BackgroundTransparency=1; num.Text=tostring(index).."."; num.TextColor3=Theme.AccentLight; num.Font=Enum.Font.GothamBold; num.TextSize=10; num.TextXAlignment=Enum.TextXAlignment.Left; num.Parent=row

    -- colour chip, so the ordering is scannable without reading every name
    local mutName = mutationPriority[index]
    local col = _G.Skyr0MutColor and _G.Skyr0MutColor(mutName)
    if col then
        local chip=Instance.new("Frame"); chip.Size=UDim2.new(0,10,0,10); chip.Position=UDim2.new(0,30,0.5,-5); chip.BackgroundColor3=col; chip.BorderSizePixel=0; chip.Parent=row; corner(chip,5)
    end

    local l=Instance.new("TextLabel"); l.Size=UDim2.new(1,-118,1,0); l.Position=UDim2.new(0,col and 46 or 32,0,0); l.BackgroundTransparency=1; l.Text=tostring(mutName); l.TextColor3=Theme.Text; l.Font=Enum.Font.GothamMedium; l.TextSize=10; l.TextXAlignment=Enum.TextXAlignment.Left; l.TextTruncate=Enum.TextTruncate.AtEnd; l.Parent=row

    local up=Instance.new("TextButton"); up.Name="WhiteTextBtn"; up.Size=UDim2.new(0,26,0,20); up.Position=UDim2.new(1,-58,0.5,-10); up.BackgroundColor3=Theme.Accent; up.Text="^"; up.TextColor3=Color3.fromRGB(25,25,28); up.Font=Enum.Font.GothamBold; up.TextSize=10; up.Parent=row; corner(up,5)
    local dn=Instance.new("TextButton"); dn.Name="WhiteTextBtn"; dn.Size=UDim2.new(0,26,0,20); dn.Position=UDim2.new(1,-28,0.5,-10); dn.BackgroundColor3=Theme.Accent; dn.Text="v"; dn.TextColor3=Color3.fromRGB(25,25,28); dn.Font=Enum.Font.GothamBold; dn.TextSize=10; dn.Parent=row; corner(dn,5)

    up.MouseButton1Click:Connect(function() if index>1 then mutationPriority[index],mutationPriority[index-1]=mutationPriority[index-1],mutationPriority[index]; Config.MutationPriority=mutationPriority; saveConfig(); loadTab("Priority") end end)
    dn.MouseButton1Click:Connect(function() if index<#mutationPriority then mutationPriority[index],mutationPriority[index+1]=mutationPriority[index+1],mutationPriority[index]; Config.MutationPriority=mutationPriority; saveConfig(); loadTab("Priority") end end)
end

function makePriorityAddRow()
    local holder = Instance.new("Frame"); holder.Size=UDim2.new(1,-4,0,31); holder.BackgroundColor3=Theme.SoftAccent; holder.BackgroundTransparency=0.1; holder.ClipsDescendants=false; holder.Parent=mainBody; holder.ZIndex=20; corner(holder,6); holder.LayoutOrder = -2

    local box=Instance.new("TextBox"); box.Size=UDim2.new(1,-60,1,-6); box.Position=UDim2.new(0,6,0,3); box.BackgroundColor3=Theme.InputBg; box.BorderSizePixel=0; box.Text=""; box.PlaceholderText="Enter pet name..."; box.TextColor3=Theme.Text; box.PlaceholderColor3=Theme.Dim; box.Font=Enum.Font.GothamMedium; box.TextSize=10; box.ClearTextOnFocus=false; box.Parent=holder; box.ZIndex=21; corner(box,4)

    local addBtn=Instance.new("TextButton"); addBtn.Name="WhiteTextBtn"; addBtn.Size=UDim2.new(0,44,0,25); addBtn.Position=UDim2.new(1,-50,0.5,-12.5); addBtn.BackgroundColor3=Theme.Accent; addBtn.Text="ADD"; addBtn.TextColor3=Color3.fromRGB(25,25,28); addBtn.Font=Enum.Font.GothamBlack; addBtn.TextSize=10; addBtn.AutoButtonColor=false; addBtn.Parent=holder; addBtn.ZIndex=21; corner(addBtn,5)

    -- Dropdown for autocomplete
    local dropdown = Instance.new("Frame"); dropdown.Name="PriorityDropdown"; dropdown.Size=UDim2.new(1,-60,0,0); dropdown.Position=UDim2.new(0,6,1,2)
    dropdown.BackgroundColor3=Theme.Background; dropdown.BorderSizePixel=0; dropdown.ClipsDescendants=true; dropdown.Visible=false; dropdown.ZIndex=50; dropdown.Parent=holder; corner(dropdown,6)
    local ddStroke = Instance.new("UIStroke"); ddStroke.Color=Theme.AccentLight; ddStroke.Thickness=1; ddStroke.Parent=dropdown
    local ddScroll = Instance.new("ScrollingFrame"); ddScroll.Size=UDim2.new(1,0,1,0); ddScroll.BackgroundTransparency=1; ddScroll.BorderSizePixel=0; ddScroll.ScrollBarThickness=3; ddScroll.ScrollBarImageColor3=Theme.Accent; ddScroll.CanvasSize=UDim2.new(0,0,0,0); ddScroll.Active=true; ddScroll.ZIndex=51; ddScroll.Parent=dropdown
    local ddLayout = Instance.new("UIListLayout"); ddLayout.Padding=UDim.new(0,1); ddLayout.Parent=ddScroll
    ddLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() ddScroll.CanvasSize=UDim2.new(0,0,0,ddLayout.AbsoluteContentSize.Y) end)

    local function addName(name)
        local trimmed = name:match("^%s*(.-)%s*$")
        if not trimmed or trimmed == "" then return end
        local exists = false
        for _, pName in ipairs(priorityList) do if pName == trimmed then exists = true; break end end
        if not exists then
            table.insert(priorityList, trimmed)
            if Config.RemovedFromPriority then
                for i=#Config.RemovedFromPriority,1,-1 do
                    if Config.RemovedFromPriority[i] == trimmed then table.remove(Config.RemovedFromPriority, i) end
                end
            end
            Config.PriorityList=priorityList; saveConfig()
        end
        box.Text=""; dropdown.Visible=false; loadTab("Priority")
    end

    local function updateDropdown(query)
        for _, c in ipairs(ddScroll:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
        if not query or query == "" then dropdown.Visible = false; return end
        local names = getAllAnimalNames()
        local q = query:lower()
        local matches = {}
        for _, name in ipairs(names) do
            if name:lower():find(q, 1, true) then
                local exists = false
                for _, pName in ipairs(priorityList) do if pName == name then exists = true; break end end
                if not exists then table.insert(matches, name); if #matches >= 8 then break end end
            end
        end
        if #matches == 0 then dropdown.Visible = false; return end
        local itemH = 24
        dropdown.Size = UDim2.new(1,-60,0,math.min(#matches,6)*itemH)
        dropdown.Visible = true
        for _, name in ipairs(matches) do
            local btn = Instance.new("TextButton"); btn.Size=UDim2.new(1,0,0,itemH); btn.BackgroundColor3=Theme.Row; btn.BackgroundTransparency=0.1; btn.Text=name; btn.TextColor3=Theme.Text; btn.Font=Enum.Font.GothamMedium; btn.TextSize=10; btn.AutoButtonColor=false; btn.ZIndex=52; btn.Parent=ddScroll
            btn.MouseEnter:Connect(function() btn.BackgroundColor3=Theme.RowHover end)
            btn.MouseLeave:Connect(function() btn.BackgroundColor3=Theme.Row end)
            btn.MouseButton1Click:Connect(function() addName(name) end)
        end
    end

    box:GetPropertyChangedSignal("Text"):Connect(function() updateDropdown(box.Text) end)
    box.FocusLost:Connect(function() task.delay(0.15, function() dropdown.Visible = false end) end)
    box.Focused:Connect(function() if box.Text ~= "" then updateDropdown(box.Text) end end)

    addBtn.MouseButton1Click:Connect(function() addName(box.Text) end)
end

function makePriorityRestoreRow()
    if not Config.RemovedFromPriority or #Config.RemovedFromPriority == 0 then return end
    local row=Instance.new("Frame"); row.Size=UDim2.new(1,-4,0,31); row.BackgroundColor3=Theme.SoftAccent; row.BackgroundTransparency=0.1; row.Parent=mainBody; corner(row,6); row.LayoutOrder = -1
    local l=Instance.new("TextLabel"); l.Size=UDim2.new(1,-96,1,0); l.Position=UDim2.new(0,8,0,0); l.BackgroundTransparency=1; l.Text=tostring(#Config.RemovedFromPriority).." ignored pet(s) available"; l.TextColor3=Theme.Dim; l.Font=Enum.Font.GothamMedium; l.TextSize=10; l.TextXAlignment=Enum.TextXAlignment.Left; l.Parent=row
    local restBtn=Instance.new("TextButton"); restBtn.Name="WhiteTextBtn"; restBtn.Size=UDim2.new(0,74,0,25); restBtn.Position=UDim2.new(1,-80,0.5,-12.5); restBtn.BackgroundColor3=Theme.Green; restBtn.Text="RESTORE"; restBtn.TextColor3=Color3.fromRGB(25,25,28); restBtn.Font=Enum.Font.GothamBlack; restBtn.TextSize=10; restBtn.AutoButtonColor=false; restBtn.Parent=row; corner(restBtn,5)
    restBtn.MouseButton1Click:Connect(function()
        for _, name in ipairs(Config.RemovedFromPriority) do
            local exists = false
            for _, pName in ipairs(priorityList) do
                if pName == name then exists = true; break end
            end
            if not exists then table.insert(priorityList, name) end
        end
        Config.RemovedFromPriority = {}
        Config.PriorityList = priorityList
        saveConfig()
        loadTab("Priority")
    end)
end

function loadTab(tabName)
    UI.CurrentTab=tabName; clearBody(mainBody)
    pcall(function() mainBody:FindFirstChildOfClass("UIListLayout").SortOrder = Enum.SortOrder.LayoutOrder end)
    for name,btn in pairs(tabButtons) do local act=(name==tabName); tw(btn,{BackgroundColor3=act and Theme.Accent or Theme.SoftAccent, TextColor3=act and Color3.fromRGB(20,20,20) or Theme.Dim, BackgroundTransparency=act and 0 or 0.15},0.16) end

    if tabName=="Keybinds" then
        -- NO Steal Speed keybind, NO Unwalk
        for _,name in ipairs({"Kick","Rejoin Job ID","Clone","Manual TP","Grapple TP","Invisible Steal","Job ID","Proximity","Carpet Boost","Open Menu","Ragdoll Self","Insta Reset","Drop Brainrot","Float","Click to AP","Steal Nearest"}) do makeKeybindRow(mainBody,name) end

    elseif tabName=="Auto TP" then
        -- THESE THREE GO THROUGH setStealMode.
        --
        -- They used to write Config.StealMode and the sibling AutoTP* flags by
        -- hand. That covers _pickByMode (which reads StealMode) and NOTHING
        -- else: stealPriorityEnabled / stealHighestEnabled / stealNearestEnabled
        -- and Config.Steal* stayed exactly as they were, and those are what the
        -- Steal Target selection thread and the Steal panel's own toggles read.
        --
        -- So flipping "Auto TP Priority Mode" on put the FLIGHT into priority
        -- while the target panel and auto-grab were still on Highest, until the
        -- next execute re-ran the restore. You teleported to your #1 priority
        -- and the grab was armed on the biggest earner on the map.
        --
        -- setStealMode sets every one of them, saves, and pushes the state back
        -- into these three switches with fire=false, so there is no recursion.
        makeMainToggle(mainBody,"Auto TP Priority Mode",Config.AutoTPPriority,function(on)
            if on then setStealMode("Priority")
            else Config.AutoTPPriority = false; saveConfig() end
        end)
        makeMainToggle(mainBody,"Auto TP Highest Gen",Config.AutoTPHighestGen,function(on)
            if on then setStealMode("Highest")
            else Config.AutoTPHighestGen = false; saveConfig() end
        end)
        makeMainToggle(mainBody,"Auto TP Highest Value",Config.AutoTPHighestValue,function(on)
            -- setStealMode clears AutoTPHighestValue (it only knows the three
            -- modes), so it is re-raised afterwards: the mode is "Highest" for
            -- every engine, and getTargetPetData's value-sorted branch is what
            -- this extra flag selects.
            if on then
                setStealMode("Highest")
                Config.AutoTPHighestValue = true
                Config.AutoTPHighestGen = false
                -- setStealMode just painted both of these; put them back the way
                -- this toggle means them (fire=false = repaint only, no callback)
                if BoundToggles["Auto TP Highest Gen"] then BoundToggles["Auto TP Highest Gen"](false, false) end
                if BoundToggles["Auto TP Highest Value"] then BoundToggles["Auto TP Highest Value"](true, false) end
                saveConfig()
            else
                Config.AutoTPHighestValue = false; saveConfig()
            end
        end)
        makeMainToggle(mainBody,"TP on Load",Config.TpSettings.TpOnLoad,function(on) Config.TpSettings.TpOnLoad=on; saveConfig() end)
        -- step 0.01: this is a wait in SECONDS, and small fractional values are
        -- the useful part of its range. On the range heuristic alone (0-30) it
        -- rounded to whole seconds, so 0.13 became 0 and the delay vanished.
        makeMainSliderWithInput(mainBody,"TP on Load Delay",0,30,tonumber(Config.TpSettings.TpOnLoadDelay) or 0,function(v) Config.TpSettings.TpOnLoadDelay=v; saveConfig() end,"s",0.01)
        -- TP Tool selection (single collapsible dropdown)
        makeMainDropdown(mainBody,"Teleport Tool",{"Flying Carpet","Cupid's Wings","Santa's Sleigh","Witch's Broom","Waverider"},Config.TpSettings.Tool or "Flying Carpet",function(tn) Config.TpSettings.Tool=tn; saveConfig(); ShowNotification("TP TOOL",tn) end)
        makeMainToggle(mainBody,"Grapple TP",Config.TpSettings.GrabbleTP,function(on)
            Config.TpSettings.GrabbleTP=on
            saveConfig()
            -- This toggle IS the Skyr0 Clone-TP engine (not the Grapple TP keybind). Sync auto-steal loop state.
            if _G.Skyr0AutoSteal then
                pcall(_G.Skyr0AutoSteal, on and (Config.AutoStealEnabled or false))
            end
        end)
        -- THIS TOGGLE WAS WIRED TO A KEY NOTHING READS.
        --
        -- It set Config.TpSettings.ApproachFloor2From1. Every one of the SEVEN
        -- places that implement the behaviour -- the adjY clamp that forces the
        -- LOWER (floor-1) wall coords, the sky-clone routing, goToBrainrot's
        -- petY-8 airPos, the jump spam, the _forceGo that runs goToBrainrot even
        -- when the clone proximity check fails, and runAutoSnipe's two -- read
        -- Config.AutoTPFloor2FromFloor1. Two different keys, so the switch wrote
        -- a flag nobody reads and the flag the engine reads was never set by
        -- anything. The toggle did literally nothing.
        --
        -- Writes the real key now, and mirrors the old one so a config saved by
        -- the broken build stays consistent instead of holding a third state.
        makeMainToggle(mainBody,"Approach Floor 2 From 1",
            (Config.AutoTPFloor2FromFloor1 or Config.TpSettings.ApproachFloor2From1) and true or false,
            function(on)
                Config.AutoTPFloor2FromFloor1 = on
                Config.TpSettings.ApproachFloor2From1 = on
                saveConfig()
            end)

        -- Full TP & Clone settings merged directly into Auto TP (no separate TP Speed panel)
        makeMainSliderWithInput(mainBody,"Grapple TP Speed",50,600,Config.TpSettings.GrabbleTPSpeed or 230,function(v) Config.TpSettings.GrabbleTPSpeed=v; saveConfig(); if _G.Skyr0SetCarpetSpeed then pcall(_G.Skyr0SetCarpetSpeed, v) end end)
        makeMainSliderWithInput(mainBody,"Walk To Brainrot Speed",50,600,Config.TpSettings.WalkTPSpeed or 190,function(v) Config.TpSettings.WalkTPSpeed=v; saveConfig() end)
        makeMainSliderWithInput(mainBody,"Clone Delay",0.05,2.0,Config.TpSettings.CloneDelayVal or 0.1,function(v) Config.TpSettings.CloneDelayVal=v; saveConfig() end,"s")
        makeMainTextBox(mainBody,"Min Gen for Auto TP",Config.TpSettings.MinGenForTp,"e.g. 50k, 1m, 10b",function(v)
            Config.TpSettings.MinGenForTp = v
            saveConfig()
            ShowNotification("MIN GEN TP", v == "" and "No minimum" or "Min: " .. v)
        end)

    elseif tabName=="ESP" then

        makeMainToggle(mainBody,"Player ESP",playerESPEnabled,function(on) playerESPEnabled=on; Config.PlayerESP=on; saveConfig(); if on then task.spawn(function() for _,pl in ipairs(Players:GetPlayers()) do if pl~=LocalPlayer then pcall(createOrRefreshPlayerESP,pl) end end end) else clearPlayerESP() end end)
        makeMainToggle(mainBody,"Brainrot ESP",brainrotESPEnabled,function(on) brainrotESPEnabled=on; Config.BrainrotESP=on; saveConfig(); if on then task.spawn(function() pcall(refreshBrainrotESP) end) else clearBrainrotESP() end end)
        makeSyncMainToggle(mainBody,"Timer ESP","Timer ESP",function(on)
            timerESPEnabled=on
            Config.TimerESP=on
            saveConfig()
            if on then task.spawn(function() pcall(refreshTimerESP) end) else clearTimerESP() end
        end)
        makeMainToggle(mainBody,"Subspace Mine ESP",subspaceMineESPEnabled,function(on) subspaceMineESPEnabled=on; Config.SubspaceMineESP=on; saveConfig() end)
        makeMainToggle(mainBody,"Base Owner ESP",Config.BaseOwnerESP,function(on) if _G.setBaseOwnerESP then _G.setBaseOwnerESP(on) end end)
        makeMainToggle(mainBody,"Line To Base",Config.LineToBase,function(on)
            Config.LineToBase=on; saveConfig()
            if on then if _G.createPlotBeam then pcall(_G.createPlotBeam) end
            else if _G.resetPlotBeam then pcall(_G.resetPlotBeam) end end
        end)
        makeMainToggle(mainBody,"Line To Best Brainrot",Config.LineToBrainrot or false,function(on)
            Config.LineToBrainrot=on; saveConfig()
            if on then -- beam auto-creates via heartbeat
            else if _G.resetBrainrotBeam then pcall(_G.resetBrainrotBeam) end end
        end)

    elseif tabName=="UI" then
        -- SKIP PANELS THAT DO NOT EXIST.
        --
        -- This is why the UI tab showed ONE toggle. The list is hard-coded and
        -- still names "Admin Command Panel" and "Command Cooldowns", but the
        -- Admin Panel UI was removed from this build -- so `panels[name]` is nil
        -- for both, and `panels[name].Visible` threw on the SECOND iteration.
        -- The error killed loadTab("UI") right there, which is why only
        -- "Invisible Steal Panel" (the first entry) was ever drawn and every row
        -- below it -- the rest of the panel toggles, Reset UI, the lock button,
        -- the scale slider -- was missing too.
        --
        -- The order is kept deliberate rather than read from `panels`, because
        -- that table also holds the *Body scroll frames and the AP command
        -- popups, none of which belong in this list.
        for _,name in ipairs({"Invisible Steal Panel","Admin Command Panel","Command Cooldowns","Actions","Steal Panel","Steal Target","Face Away"}) do
            local _p = panels[name]
            if _p then
                makeMainToggle(mainBody,name,_p.Visible,function(on)
                    Config.Visibilities[name]=on
                    saveConfig()
                    if on then openAnim(_p) else closeAnim(_p) end
                end)
            end
        end
        makeMainToggle(mainBody,"Clear Error Popups",Config.CleanErrorGUIs,function(on) Config.CleanErrorGUIs=on; saveConfig() end)
        makeMainToggle(mainBody,"Auto Close Main UI on Execute",Config.AutoCloseOnExec,function(on) Config.AutoCloseOnExec=on; saveConfig() end)
        local shareRow = Instance.new("Frame")
        shareRow.Size = UDim2.new(1, -4, 0, 31)
        shareRow.BackgroundColor3 = Theme.Panel
        shareRow.BackgroundTransparency = 0.18
        shareRow.Parent = mainBody
        corner(shareRow, 6)
        
        local shareBox = Instance.new("TextBox")
        shareBox.Size = UDim2.new(1, -12, 1, -6)
        shareBox.Position = UDim2.new(0, 6, 0, 3)
        shareBox.BackgroundColor3 = Theme.InputBg
        shareBox.BorderSizePixel = 0
        shareBox.Text = ""
        shareBox.PlaceholderText = "Paste config here to import, or click Export..."
        shareBox.TextColor3 = Theme.Text
        shareBox.Font = Enum.Font.GothamMedium
        shareBox.TextSize = 9
        shareBox.ClearTextOnFocus = false
        shareBox.Parent = shareRow
        corner(shareBox, 4)

        local btnRow = Instance.new("Frame")
        btnRow.Size = UDim2.new(1, -4, 0, 30)
        btnRow.BackgroundTransparency = 1
        btnRow.Parent = mainBody
        
        local expBtn = Instance.new("TextButton")
        expBtn.Size = UDim2.new(0.5, -3, 1, 0)
        expBtn.Position = UDim2.new(0, 0, 0, 0)
        expBtn.BackgroundColor3 = Theme.Row
        expBtn.BackgroundTransparency = 0.16
        expBtn.Text = "Export Config"
        expBtn.TextColor3 = Theme.Text
        expBtn.Font = Enum.Font.GothamBold
        expBtn.TextSize = 11
        expBtn.AutoButtonColor = false
        expBtn.Parent = btnRow
        corner(expBtn, 6)
        stroke(expBtn, Theme.AccentLight, 1, 0.28)
        expBtn.MouseEnter:Connect(function() tw(expBtn, {BackgroundColor3 = Theme.RowHover}, 0.12) end)
        expBtn.MouseLeave:Connect(function() tw(expBtn, {BackgroundColor3 = Theme.Row}, 0.12) end)
        expBtn.MouseButton1Click:Connect(function()
            local str = _G.exportConfig()
            if str then
                shareBox.Text = str
            end
        end)
        
        local impBtn = Instance.new("TextButton")
        impBtn.Size = UDim2.new(0.5, -3, 1, 0)
        impBtn.Position = UDim2.new(0.5, 3, 0, 0)
        impBtn.BackgroundColor3 = Theme.Row
        impBtn.BackgroundTransparency = 0.16
        impBtn.Text = "Import Config"
        impBtn.TextColor3 = Theme.Text
        impBtn.Font = Enum.Font.GothamBold
        impBtn.TextSize = 11
        impBtn.AutoButtonColor = false
        impBtn.Parent = btnRow
        corner(impBtn, 6)
        stroke(impBtn, Theme.AccentLight, 1, 0.28)
        impBtn.MouseEnter:Connect(function() tw(impBtn, {BackgroundColor3 = Theme.RowHover}, 0.12) end)
        impBtn.MouseLeave:Connect(function() tw(impBtn, {BackgroundColor3 = Theme.Row}, 0.12) end)
        impBtn.MouseButton1Click:Connect(function()
            _G.importConfig(shareBox.Text)
        end)

        -- White Mode / Dark Mode buttons removed -- dark mode only
        -- (Theme is always dark)

        local rb=makeMainButton(mainBody,"Reset UI",function()
            main.Position=UDim2.new(0.5,-187,0.5,-255); panels["Invisible Steal Panel"].Position=UDim2.new(0,80,0.5,-220)
            panels["Actions"].Position=UDim2.new(0.5,505,1,-415); panels["Steal Panel"].Position=UDim2.new(1,-300,1,-385)
            panels["Steal Target"].Position=UDim2.new(1,-290,0,85); actionSettingsPanel.Position=UDim2.new(0.5,745,1,-400)
            bottomBar.Position=UDim2.new(0.5,-287,1,-125); Config.positions={}; saveConfig()
        end)
        local lockBtn; lockBtn=makeMainButton(mainBody,UI.Locked and "Locked" or "Unlocked",function() UI.Locked=not UI.Locked; Config.locked=UI.Locked; saveConfig(); lockBtn.Text=UI.Locked and "Locked" or "Unlocked" end,Theme.SoftButton)
        
        makeMainToggle(mainBody,"Priority Sound Alert",Config.PrioritySoundAlert,function(on) Config.PrioritySoundAlert=on; saveConfig() end)
        makeMainTextBox(mainBody,"Custom Sound ID",Config.PrioritySoundID or "e.g. 123456789","e.g. 123456789",function(v) Config.PrioritySoundID=v; saveConfig() end)

    elseif tabName=="Misc" then
        -- NO Unwalk, NO Steal Speed, NO FPS Boost (moved to Performance)
        makeMainToggle(mainBody,"Instant Clone",true)
        -- Desync removed
        makeMainToggle(mainBody,"Auto Invisible During Steal",Config.AutoInvisDuringSteal,function(on) _G.AutoInvisDuringSteal=on; Config.AutoInvisDuringSteal=on; saveConfig() end)
        makeMainToggle(mainBody,"Auto Unlock During Steal",Config.AutoUnlockOnSteal,function(on) Config.AutoUnlockOnSteal=on; saveConfig() end)
        -- Face Away: turns your back to the base owner (or the nearest player,
        -- with the second toggle) for as long as a steal is running.
        makeSyncMainToggle(mainBody,"Face Away","Face Away",function(on)
            if _G.Skyr0SetFaceAway then _G.Skyr0SetFaceAway(on) end
        end)
        makeSyncMainToggle(mainBody,"Face Nearest (else Base Owner)","Face Nearest",function(on)
            if _G.Skyr0SetFaceNearest then _G.Skyr0SetFaceNearest(on) end
        end)
        makeSyncMainToggle(mainBody,"Anti Ragdoll","Anti Ragdoll",function(on) if on then startAntiRagdoll() else stopAntiRagdoll() end end)
        makeSyncMainToggle(mainBody,"Infinite Jump","Infinite Jump",function(on) setInfiniteJump(on) end)
        makeSyncMainToggle(mainBody,"Auto Kick On Steal","Auto Kick",function(on) Config.AutoKickOnSteal=on; saveConfig() end)
        makeMainToggle(mainBody,"Kick to Private Server",Config.KickToPrivateServer,function(on) Config.KickToPrivateServer=on; saveConfig() end)
        makeMainTextBox(mainBody,"Private Server Code",PrivateServerCode,"e.g. ABC123XYZ...",function(v) PrivateServerCode=v; savePSCode() end)
        makeSyncMainToggle(mainBody,"Unwalk","Unwalk",function(on) if _G.setUnwalk then _G.setUnwalk(on) end end)
        makeSyncMainToggle(mainBody,"Invisible Steal","Invisible Steal",function(on) if _G.toggleInvisibleSteal then pcall(_G.toggleInvisibleSteal) end end)
        makeSyncMainToggle(mainBody,"Float","Float",function(on) setFloat(on) end)
        makeSyncMainToggle(mainBody,"Carpet Speed","Carpet Speed",function(on) setCarpetSpeed(on) end)
        makeSyncMainToggle(mainBody,"Click to AP","ClickToAP",function(on) Config.ClickToAP=on; saveConfig() end)
        makeSyncMainToggle(mainBody,"Open Base","OpenBase",function(on) if _G.setOpenBaseButtons then _G.setOpenBaseButtons(on) end end)

        -- Helper: create a config panel with toggles + ordering for AP commands
        local function makeAPConfigPanel(panelKey, titleText, configTable, orderKey, onToggleCb)
            if panels[panelKey] then
                panels[panelKey].Visible = not panels[panelKey].Visible
                return
            end

            -- Initialize order from config or default
            if not Config[orderKey] then
                Config[orderKey] = {}
                for i, cmd in ipairs(AP_ALL_COMMANDS) do Config[orderKey][i] = cmd end
            end
            local cmdOrder = Config[orderKey]

            local cfgPanel = Instance.new("Frame")
            cfgPanel.Name = panelKey
            cfgPanel.Size = UDim2.fromOffset(240, 0)
            cfgPanel.AutomaticSize = Enum.AutomaticSize.Y
            cfgPanel.Position = panelKey == "AdminPanelCmds" and UDim2.new(0.5, 200, 0.5, -200) or UDim2.new(0.5, 200, 0.5, -50)
            cfgPanel.BackgroundColor3 = Theme.Background
            cfgPanel.BackgroundTransparency = 0.04
            cfgPanel.BorderSizePixel = 0
            cfgPanel.ZIndex = 100 -- High ZIndex to stay on top
            cfgPanel.Parent = gui_sg -- Parent to ScreenGui to act as a floating popup
            panels[panelKey] = cfgPanel
            corner(cfgPanel, 10)
            stroke(cfgPanel, Theme.Accent, 1.5, 0.3)
            makeDraggable(cfgPanel, cfgPanel)

            local cfgTitleLbl = Instance.new("TextLabel")
            cfgTitleLbl.Size = UDim2.new(1, 0, 0, 28)
            cfgTitleLbl.BackgroundColor3 = Theme.Panel
            cfgTitleLbl.BackgroundTransparency = 0.3
            cfgTitleLbl.Text = titleText
            cfgTitleLbl.TextColor3 = Theme.Text
            cfgTitleLbl.Font = Enum.Font.GothamBold
            cfgTitleLbl.TextSize = 12
            cfgTitleLbl.ZIndex = 101 -- Fix: Render on top of panel
            cfgTitleLbl.Parent = cfgPanel
            corner(cfgTitleLbl, 8)

            local cfgBody = Instance.new("Frame")
            cfgBody.Size = UDim2.new(1, -8, 0, 0)
            cfgBody.AutomaticSize = Enum.AutomaticSize.Y
            cfgBody.Position = UDim2.fromOffset(4, 32)
            cfgBody.BackgroundTransparency = 1
            cfgBody.ZIndex = 101 -- Fix: Render on top of panel
            cfgBody.Parent = cfgPanel
            Instance.new("UIListLayout", cfgBody).SortOrder = Enum.SortOrder.LayoutOrder
            cfgBody:FindFirstChildOfClass("UIListLayout").Padding = UDim.new(0, 2)

            local rowMap = {} -- cmd -> row frame
            local numMap = {} -- cmd -> number label

            local function refreshNumbers()
                for i, cmd in ipairs(cmdOrder) do
                    if rowMap[cmd] then rowMap[cmd].LayoutOrder = i end
                    if numMap[cmd] then numMap[cmd].Text = tostring(i) end
                end
            end

            local function swapOrder(idx1, idx2)
                if idx1 < 1 or idx2 < 1 or idx1 > #cmdOrder or idx2 > #cmdOrder then return end
                cmdOrder[idx1], cmdOrder[idx2] = cmdOrder[idx2], cmdOrder[idx1]
                Config[orderKey] = cmdOrder
                saveConfig()
                refreshNumbers()
            end

            for idx, cmd in ipairs(cmdOrder) do
                local emoji = AP_COMMAND_LABELS[cmd] or cmd:upper():sub(1,4)
                local isOn = configTable[cmd] == true
                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, 0, 0, 28)
                row.BackgroundColor3 = Theme.Panel
                row.BackgroundTransparency = 0.4
                row.LayoutOrder = idx
                row.ZIndex = 102 -- Fix: Render on top of body
                row.Parent = cfgBody
                corner(row, 5)
                rowMap[cmd] = row

                -- Number label
                local numLbl = Instance.new("TextLabel")
                numLbl.Size = UDim2.fromOffset(16, 28)
                numLbl.Position = UDim2.fromOffset(2, 0)
                numLbl.BackgroundTransparency = 1
                numLbl.Text = tostring(idx)
                numLbl.TextColor3 = Theme.Dim
                numLbl.Font = Enum.Font.GothamBold
                numLbl.TextSize = 10
                numLbl.ZIndex = 103
                numLbl.Parent = row
                numMap[cmd] = numLbl

                -- Up arrow
                local upBtn = Instance.new("TextButton")
                upBtn.Size = UDim2.fromOffset(16, 13)
                upBtn.Position = UDim2.fromOffset(18, 1)
                upBtn.BackgroundTransparency = 1
                upBtn.Text = "^"
                upBtn.TextColor3 = Theme.AccentLight
                upBtn.Font = Enum.Font.GothamBold
                upBtn.TextSize = 8
                upBtn.AutoButtonColor = false
                upBtn.ZIndex = 103
                upBtn.Parent = row

                -- Down arrow
                local dnBtn = Instance.new("TextButton")
                dnBtn.Size = UDim2.fromOffset(16, 13)
                dnBtn.Position = UDim2.fromOffset(18, 14)
                dnBtn.BackgroundTransparency = 1
                dnBtn.Text = "v"
                dnBtn.TextColor3 = Theme.AccentLight
                dnBtn.Font = Enum.Font.GothamBold
                dnBtn.TextSize = 8
                dnBtn.AutoButtonColor = false
                dnBtn.ZIndex = 103
                dnBtn.Parent = row

                upBtn.MouseButton1Click:Connect(function()
                    local curIdx
                    for i, c in ipairs(cmdOrder) do if c == cmd then curIdx = i; break end end
                    if curIdx and curIdx > 1 then swapOrder(curIdx, curIdx - 1) end
                end)
                dnBtn.MouseButton1Click:Connect(function()
                    local curIdx
                    for i, c in ipairs(cmdOrder) do if c == cmd then curIdx = i; break end end
                    if curIdx and curIdx < #cmdOrder then swapOrder(curIdx, curIdx + 1) end
                end)

                -- Command label
                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(1, -90, 1, 0)
                lbl.Position = UDim2.fromOffset(36, 0)
                lbl.BackgroundTransparency = 1
                lbl.Text = emoji .. " " .. cmd
                lbl.TextColor3 = Theme.Text
                lbl.Font = Enum.Font.GothamMedium
                lbl.TextSize = 11
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.ZIndex = 103
                lbl.Parent = row

                -- Toggle button
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.fromOffset(36, 18)
                btn.Position = UDim2.new(1, -42, 0.5, -9)
                btn.BackgroundColor3 = isOn and Theme.Green or Theme.ToggleOff2
                btn.Text = isOn and "ON" or "OFF"
                btn.TextColor3 = isOn and Color3.fromRGB(15,15,15) or Color3.fromRGB(255,255,255)
                btn.Font = Enum.Font.GothamBold
                btn.TextSize = 9
                btn.AutoButtonColor = false
                btn.ZIndex = 103
                btn.Parent = row
                corner(btn, 5)

                btn.MouseButton1Click:Connect(function()
                    isOn = not isOn
                    configTable[cmd] = isOn
                    saveConfig()
                    btn.BackgroundColor3 = isOn and Theme.Green or Theme.ToggleOff2
                    btn.Text = isOn and "ON" or "OFF"
                    btn.TextColor3 = isOn and Color3.fromRGB(15,15,15) or Color3.fromRGB(255,255,255)
                    if onToggleCb then onToggleCb(cmd, isOn) end
                end)
            end

            if panelKey == "ClickToAPCmds" then
                local function setZIndex(inst)
                    if inst:IsA("GuiObject") then
                        inst.ZIndex = 103
                    end
                    for _, child in ipairs(inst:GetChildren()) do
                        setZIndex(child)
                    end
                end

                local sep = Instance.new("Frame")
                sep.Size = UDim2.new(1, -8, 0, 1)
                sep.Position = UDim2.new(0, 4, 0, 0)
                sep.BackgroundColor3 = Theme.Stroke
                sep.BackgroundTransparency = 0.2
                sep.LayoutOrder = 1000
                sep.ZIndex = 103
                sep.Parent = cfgBody

                local subHeader = Instance.new("TextLabel")
                subHeader.Size = UDim2.new(1, 0, 0, 24)
                subHeader.BackgroundTransparency = 1
                subHeader.Text = "Settings"
                subHeader.TextColor3 = Theme.Accent
                subHeader.Font = Enum.Font.GothamBold
                subHeader.TextSize = 10
                subHeader.LayoutOrder = 1001
                subHeader.ZIndex = 103
                subHeader.Parent = cfgBody

                local sliderWrapper = Instance.new("Frame")
                sliderWrapper.Size = UDim2.new(1, 0, 0, 50)
                sliderWrapper.BackgroundTransparency = 1
                sliderWrapper.LayoutOrder = 1002
                sliderWrapper.Parent = cfgBody

                local sliderObj = makeQuickSlider(sliderWrapper, "Click Radius", 1, 50, Config.ClickToAPRadius or 8, function(v)
                    Config.ClickToAPRadius = v
                    saveConfig()
                end, " studs")
                setZIndex(sliderWrapper)
            end

            if panelKey == "SpamBaseOwnerCmds" then
                local function setZIndex(inst)
                    if inst:IsA("GuiObject") then
                        inst.ZIndex = 103
                    end
                    for _, child in ipairs(inst:GetChildren()) do
                        setZIndex(child)
                    end
                end

                local sep = Instance.new("Frame")
                sep.Size = UDim2.new(1, -8, 0, 1)
                sep.Position = UDim2.new(0, 4, 0, 0)
                sep.BackgroundColor3 = Theme.Stroke
                sep.BackgroundTransparency = 0.2
                sep.LayoutOrder = 1000
                sep.ZIndex = 103
                sep.Parent = cfgBody

                local subHeader = Instance.new("TextLabel")
                subHeader.Size = UDim2.new(1, 0, 0, 24)
                subHeader.BackgroundTransparency = 1
                subHeader.Text = "Settings"
                subHeader.TextColor3 = Theme.Accent
                subHeader.Font = Enum.Font.GothamBold
                subHeader.TextSize = 10
                subHeader.LayoutOrder = 1001
                subHeader.ZIndex = 103
                subHeader.Parent = cfgBody

                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, 0, 0, 34)
                row.BackgroundTransparency = 1
                row.LayoutOrder = 1002
                row.Parent = cfgBody

                local toggleFunc = makeSyncStateRow(row, "Single Command:", "SpamBaseOwnerSingleCommand", function(on)
                    Config.SpamBaseOwnerSingleCommand = on
                    saveConfig()
                end)
                setZIndex(row)
            end

            local pad = Instance.new("Frame")
            pad.Size = UDim2.new(1, 0, 0, 6)
            pad.BackgroundTransparency = 1
            pad.LayoutOrder = 1004
            pad.Parent = cfgBody
        end

        -- Admin Panel Commands button (controls which buttons show per player in admin panel)
        makeMainButton(mainBody, "Admin Panel Commands", function()
            makeAPConfigPanel("AdminPanelCmds", "Admin Panel Commands", Config.AdminPanelButtons, "AdminPanelOrder", function()
                if _G.refreshAdminPanelRows then _G.refreshAdminPanelRows() end
            end)
        end)

        -- Click to AP Commands button (controls which commands fire when you click a player)
        makeMainButton(mainBody, "Click to AP Commands", function()
            makeAPConfigPanel("ClickToAPCmds", "Click to AP Commands", Config.ClickToAPCommands, "ClickToAPOrder")
        end)

        -- Spam Base Owner Commands button
        makeMainButton(mainBody, "Spam Base Owner Commands", function()
            makeAPConfigPanel("SpamBaseOwnerCmds", "Spam Base Owner Commands", Config.SpamBaseOwnerCommands, "SpamBaseOwnerOrder")
        end)
        makeSyncMainToggle(mainBody,"Anti-Bee & Anti-Disco","AntiBeeDisco",function(on)
            Config.AntiBeeDisco = on
            saveConfig()
            if on then
                if _G.ANTI_BEE_DISCO and _G.ANTI_BEE_DISCO.Enable then
                    _G.ANTI_BEE_DISCO.Enable()
                end
            else
                if _G.ANTI_BEE_DISCO and _G.ANTI_BEE_DISCO.Disable then
                    _G.ANTI_BEE_DISCO.Disable()
                end
            end
        end)
        makeMainTextBox(mainBody,"Min Gen for Nearest Grab",Config.TpSettings.MinGenForGrab,"e.g. 10k, 500k, 1m",function(v)
            Config.TpSettings.MinGenForGrab = v
            saveConfig()
            ShowNotification("MIN GEN GRAB", v == "" and "No minimum" or "Min: " .. v)
        end)

    elseif tabName=="Priority" then
        makePriorityAddRow(); makePriorityRestoreRow(); for i=1,#priorityList do makePriorityRow(i) end

        -- ---------------- mutation priority ----------------
        do
            local head=Instance.new("TextLabel"); head.Size=UDim2.new(1,-4,0,26); head.BackgroundTransparency=1
            head.Text="MUTATION PRIORITY"; head.TextColor3=Theme.AccentLight; head.Font=Enum.Font.GothamBlack; head.TextSize=10
            head.TextXAlignment=Enum.TextXAlignment.Left; head.TextYAlignment=Enum.TextYAlignment.Bottom; head.Parent=mainBody

            local hint=Instance.new("TextLabel"); hint.Size=UDim2.new(1,-4,0,26); hint.BackgroundTransparency=1
            hint.Text="Breaks ties between pets on the same entry above. Write \"Gold Meowl\" up there to rank one mutation on its own."
            hint.TextColor3=Theme.Dim; hint.Font=Enum.Font.GothamMedium; hint.TextSize=9
            hint.TextWrapped=true; hint.TextXAlignment=Enum.TextXAlignment.Left; hint.Parent=mainBody

            makeSyncStateRow(mainBody,"Promote Unlisted:","MutationPriorityOnly",function(on)
                Config.MutationPriorityOnly=on; saveConfig()
            end)
            makeQuickSlider(mainBody,"Promote Top N Mutations",1,8,tonumber(Config.MutationPriorityTopN) or 3,function(v)
                Config.MutationPriorityTopN=v; saveConfig()
            end,nil,1)
            makeQuickButton(mainBody,"Reset Mutation Order",function()
                mutationPriority = _G.Skyr0DefaultMutationOrder and _G.Skyr0DefaultMutationOrder() or {}
                Config.MutationPriority = mutationPriority
                saveConfig(); loadTab("Priority")
            end)

            for i=1,#mutationPriority do makeMutationRow(i) end
        end

    elseif tabName=="Performance" then
        makeSyncMainToggle(mainBody,"FPS Boost","FPS Boost (normal)",function(on) setFPSBoost(on) end)
        -- Ultra had a saved Config value and a load-time apply but no row to turn
        -- it on with, because it was an alias to the normal boost. It is a real
        -- texture remover now, so it gets its row back (hub_Mata's Performance tab).
        makeSyncMainToggle(mainBody,"FPS Boost Ultra","FPS Boost Ultra",function(on) if setFPSBoostUltra then setFPSBoostUltra(on) end end)
        makeSyncMainToggle(mainBody,"Xray","XRay",function(on) setXRay(on) end)
        makeQuickSlider(mainBody,"FOV",50,120,Config.FOV or 70,function(v) Config.FOV=v; saveConfig(); pcall(function() Workspace.CurrentCamera.FieldOfView=v end) end)
    end

    local idx = 0
    for _, child in ipairs(mainBody:GetChildren()) do
        if child:IsA("GuiObject") and not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
            idx = idx + 1
            child.LayoutOrder = idx
        end
    end
end

for tabName,btn in pairs(tabButtons) do btn.MouseButton1Click:Connect(function() loadTab(tabName) end) end

-- BOTTOM BAR
bottomBar=Instance.new("Frame"); bottomBar.Size=UDim2.new(0,575,0,50); bottomBar.Position=UDim2.new(0.5,-287,1,-125); bottomBar.BackgroundColor3=Theme.Background; bottomBar.BackgroundTransparency=0.3; bottomBar.BorderSizePixel=0; bottomBar.Parent=gui; corner(bottomBar,12); addOutline(bottomBar); decoratePanel(bottomBar)
local iw=Instance.new("Frame"); iw.Size=UDim2.new(0,34,0,34); iw.Position=UDim2.new(0,12,0.5,-17); iw.BackgroundColor3=Theme.SoftAccent; iw.BorderSizePixel=0; iw.Parent=bottomBar; corner(iw,8)
local iwImg=Instance.new("ImageLabel",iw); iwImg.Size=UDim2.new(1,0,1,0); iwImg.BackgroundTransparency=1; iwImg.Image="rbxassetid://136703267344204"; iwImg.ScaleType=Enum.ScaleType.Fit; iwImg.ZIndex=2
local ic=Instance.new("ImageLabel"); ic.Size=UDim2.new(1,0,1,0); ic.BackgroundTransparency=1; ic.ScaleType=Enum.ScaleType.Fit; ic.Parent=iw; corner(ic,8)

_G.updateLogoImage = function(isDark)
    -- NO branded asset. This used to load the hub logo by asset id, which is
    -- the one thing in the whole file a client-side scan can match on without
    -- touching a single function: walk the GUI, read ImageLabel.Image, compare.
    -- The tile is kept (the bottom bar is laid out around it) but stays a plain
    -- accent square. Other code still calls this, so the entry point remains.
    ic.Image = ""
    iw.BackgroundColor3 = Theme.SoftAccent
end
_G.updateLogoImage(Config and Config.DarkMode or false)
local lg=Instance.new("TextLabel"); lg.Size=UDim2.new(0,70,0,26); lg.Position=UDim2.new(0,54,0,5); lg.BackgroundTransparency=1; lg.Text="PingHub"; lg.TextColor3=Theme.AccentLight; lg.Font=Enum.Font.GothamBlack; lg.TextSize=19; lg.TextXAlignment=Enum.TextXAlignment.Left; lg.Parent=bottomBar
local dd=Instance.new("TextLabel"); dd.Size=UDim2.new(0,20,0,26); dd.Position=UDim2.new(0,126,0,5); dd.BackgroundTransparency=1; dd.Text="|"; dd.TextColor3=Theme.AccentLight; dd.Font=Enum.Font.GothamBlack; dd.TextSize=18; dd.Parent=bottomBar
local dc=Instance.new("TextLabel"); dc.Size=UDim2.new(0,210,0,26); dc.Position=UDim2.new(0,146,0,5); dc.BackgroundTransparency=1; dc.Text=".gg/PingHub"; dc.TextColor3=Theme.AccentLight; dc.Font=Enum.Font.GothamBold; dc.TextSize=16; dc.TextXAlignment=Enum.TextXAlignment.Left; dc.Parent=bottomBar
local sb=Instance.new("TextLabel"); sb.Size=UDim2.new(0,290,0,14); sb.Position=UDim2.new(0,55,0,30); sb.BackgroundTransparency=1; sb.Text="By: pingisreal"; sb.TextColor3=Theme.Dim; sb.Font=Enum.Font.GothamSemibold; sb.TextSize=8; sb.TextXAlignment=Enum.TextXAlignment.Left; sb.Parent=bottomBar
local rightDiv=Instance.new("Frame"); rightDiv.Size=UDim2.new(0,1,0,36); rightDiv.Position=UDim2.new(1,-138,0.5,-18); rightDiv.BackgroundColor3=Theme.Accent; rightDiv.BackgroundTransparency=0.35; rightDiv.BorderSizePixel=0; rightDiv.Parent=bottomBar
fpsText=Instance.new("TextLabel"); fpsText.Size=UDim2.new(0,126,1,0); fpsText.Position=UDim2.new(1,-128,0,0); fpsText.BackgroundTransparency=1; fpsText.Text="FPS: --\nPING: --ms"; fpsText.TextColor3=Theme.Green; fpsText.Font=Enum.Font.GothamBold; fpsText.TextSize=10; fpsText.TextXAlignment=Enum.TextXAlignment.Left; fpsText.Parent=bottomBar
if _G.addLazyUI then _G.addLazyUI(bottomBar, true) end

task.defer(function()
    loadTab("Auto TP")
    rebuildActions(); rebuildActionSettings()
end)

-- FPS/PING COUNTER
local frames,lastT=0,tick()
_G.currentFPS = 60
RunService.RenderStepped:Connect(function() frames=frames+1; local now=tick(); if now-lastT>=1 then local fps=frames; _G.currentFPS=fps; frames=0; lastT=now; local ping=0; pcall(function() ping=math.floor(LocalPlayer:GetNetworkPing() * 1000) end); fpsText.Text="FPS: "..fps.."\nPING: "..ping.."ms" end end)

-- INPUT HANDLER (NO Steal Speed, NO Unwalk keybinds)
KeybindActions = {
    ["Drop Brainrot"]=function() runDropBrainrot() end,
    ["Clone"]=function() instantClone() end,
    ["Float"]=function() setFloat(not FloatState.active) end,
    ["Carpet Boost"]=function() setCarpetSpeed(not CarpetState.enabled) end,
    ["Kick"]=function() kickPlayer() end,
    ["Insta Reset"]=function() if _G.Skyr0InstaReset then pcall(_G.Skyr0InstaReset) end end,
    ["Invisible Steal"]=function() if _G.toggleInvisibleSteal then pcall(_G.toggleInvisibleSteal) end end,
    ["Rejoin Job ID"]=function() pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player) end) end,
    -- "Job ID" used to have a key and a UI row but no action at all. It copies
    -- the current server's JobId, which is what the row always implied.
    ["Job ID"]=function()
        local ok = pcall(function() (setclipboard or toclipboard or writeclipboard)(tostring(game.JobId)) end)
        ShowNotification("JOB ID", ok and "Copied to clipboard" or tostring(game.JobId))
    end,
    -- Route Manual TP through the SAME engine TP-on-load uses. runAutoSnipe is
    -- the legacy path and could run concurrently with the velocity engine, so
    -- two TP systems fought over the character.
    ["Manual TP"]=function()
        if _G.Skyr0ManualTP then _G.Skyr0ManualTP()
        elseif _G.Skyr0_ExecuteManualTP then _G.Skyr0_ExecuteManualTP()
        elseif _G.Skyr0StartSideTP then task.spawn(_G.Skyr0StartSideTP)
        else task.spawn(runAutoSnipe) end
    end,
    -- Grapple TP: hook towards the target base first, then fly. Needs the
    -- Grapple Hook in your inventory.
    ["Grapple TP"]=function()
        -- WAIT FOR A TARGET, exactly like TP-on-load does.
        --
        -- task.spawn(_G.Skyr0CicloTP) passes NO argument, so esperaMax is nil
        -- and the cycle's wait ceiling is 0: it checked the pet cache once and,
        -- finding it cold, skipped the hook and handed straight to the plain TP.
        -- That is the "keybind instantly tries to teleport" -- TP-on-load only
        -- looked better because it gates on getTargetPetData() before calling,
        -- so a target already exists by the time the cycle runs.
        --
        -- Same launcher TP-on-load uses -- identical by construction.
        if _G.Skyr0LaunchTP then _G.Skyr0LaunchTP()
        elseif _G.Skyr0_ExecuteManualTP then _G.Skyr0_ExecuteManualTP() end
    end,
    -- Snaps the steal mode to Nearest. setStealMode is the single entry point
    -- for this -- it flips the three Steal flags, mirrors the choice into the
    -- Auto-TP tab's toggles (they are the same setting under other names),
    -- repaints all of them, saves, and bridges to the Clone-TP engine. Setting
    -- Config.StealNearest by hand would do one of those six things.
    --
    -- Pressing it while already on Nearest returns to Priority, so the one key
    -- flips in and out rather than being a dead press half the time.
    ["Steal Nearest"]=function()
        local nowNearest = (Config.StealMode == "Nearest")
        local target = nowNearest and "Priority" or "Nearest"
        setStealMode(target)
        ShowNotification("STEAL MODE", target)
    end,
    ["Click to AP"]=function()
        Config.ClickToAP = not Config.ClickToAP
        saveConfig()
        setToggle("Click to AP", Config.ClickToAP)
        setToggle("ClickToAP", Config.ClickToAP)
        ShowNotification("CLICK TO AP", Config.ClickToAP and "Enabled" or "Disabled")
    end,
}

-- =====================================================================
-- MOBILE ACTION BAR
-- ---------------------------------------------------------------------
-- Every entry in KeybindActions above is reachable ONLY by pressing a key.
-- A phone has no keyboard, so on touch the entire table -- Manual TP, Grapple
-- TP, Clone, Insta Reset, all of it -- is dead. The Actions panel covers a few
-- of them, but not the ones that matter most for a teleport hub.
--
-- This builds one compact, draggable strip of buttons that call the SAME
-- KeybindActions entries the keys do, so there is exactly one implementation
-- per action and mobile cannot drift from desktop.
-- =====================================================================
do
    local UIS_ = game:GetService("UserInputService")
    local touch = false
    touch = _G.Skyr0IsTouch == true   -- shared detector
    -- NOT an early `return`: this do-block sits at chunk scope, so a bare
    -- return here returns from the whole FILE and everything below it would
    -- never load on desktop. Gate with an if instead.
    if touch then

    -- the actions worth a thumb; anything missing is still on the Actions panel
    local WANT = { "Manual TP", "Grapple TP", "Clone", "Insta Reset", "Float", "Drop Brainrot" }
    local SHORT = {
        ["Manual TP"]="TP", ["Grapple TP"]="HOOK", ["Clone"]="CLONE",
        ["Insta Reset"]="RESET", ["Float"]="FLOAT", ["Drop Brainrot"]="DROP",
    }

    local bar = Instance.new("Frame")
    bar.Name = "Skyr0_MobileActions"
    bar.Size = UDim2.fromOffset(64, #WANT * 40 + 8)
    bar.Position = UDim2.new(1, -78, 0.5, -(#WANT * 40 + 8)/2)
    bar.BackgroundColor3 = Theme.Background
    bar.BackgroundTransparency = 0.25
    bar.BorderSizePixel = 0
    bar.Active = true
    bar.ZIndex = 40
    bar.Parent = gui
    corner(bar, 12); addOutline(bar)

    local lay = Instance.new("UIListLayout")
    lay.Padding = UDim.new(0, 4); lay.SortOrder = Enum.SortOrder.LayoutOrder
    lay.HorizontalAlignment = Enum.HorizontalAlignment.Center
    lay.VerticalAlignment = Enum.VerticalAlignment.Center
    lay.Parent = bar

    for i, name in ipairs(WANT) do
        local fn = KeybindActions[name]
        if fn then
            local b = Instance.new("TextButton")
            b.Size = UDim2.fromOffset(56, 36)
            b.LayoutOrder = i
            b.BackgroundColor3 = Theme.SoftButton
            b.BackgroundTransparency = 0.1
            b.BorderSizePixel = 0
            b.AutoButtonColor = false
            b.Text = SHORT[name] or name
            b.TextColor3 = Theme.Text
            b.Font = Enum.Font.GothamBold
            b.TextSize = 10
            b.ZIndex = 41
            b.Parent = bar
            corner(b, 8)
            -- same press semantics as the rest of the rewritten UI
            if _G.Skyr0BindPress then
                _G.Skyr0BindPress(b, function() pcall(fn) end,
                    function() tw(b, {BackgroundColor3 = Theme.Accent}, 0.08) end,
                    function() tw(b, {BackgroundColor3 = Theme.SoftButton}, 0.12) end)
            else
                b.MouseButton1Click:Connect(function() pcall(fn) end)
            end
        end
    end

    -- draggable so it never sits on top of the game's own controls
    local dragging, startIn, startPos = false, nil, nil
    bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch then
            dragging, startIn, startPos = true, i.Position, bar.Position
        end
    end)
    bar.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    UIS_.InputChanged:Connect(function(i)
        if not dragging or i.UserInputType ~= Enum.UserInputType.Touch then return end
        local d = i.Position - startIn
        local scale = (getGlobalScale and getGlobalScale()) or 1
        bar.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X/scale,
                                 startPos.Y.Scale, startPos.Y.Offset + d.Y/scale)
    end)
    end -- if touch
end

-- key name -> action name, rebuilt on every bind change so dispatch is O(1)
-- and, more importantly, DETERMINISTIC.
KeybindMap = {}
function rebuildKeybindMap()
    KeybindMap = {}
    local dupes = {}
    for actionName, key in pairs(Keybinds) do
        if type(key) == "string" and key ~= "" and key ~= "NONE" and key ~= "Unknown"
           and KeybindActions[actionName] then
            if KeybindMap[key] then
                dupes[#dupes+1] = key .. " (" .. KeybindMap[key] .. " / " .. actionName .. ")"
            else
                KeybindMap[key] = actionName
            end
        end
    end
    if #dupes > 0 then
        warn("[skyr0] duplicate keybinds ignored: " .. table.concat(dupes, ", "))
    end
end
rebuildKeybindMap()

-- One implementation of "toggle the panel", reachable from anywhere. Exported
-- so it is ALWAYS possible to get the window back -- run _G.Skyr0OpenMenu() in
-- the executor console if every key somehow fails.
function _G.Skyr0OpenMenu()
    if not main then return end
    if main.Visible then
        closeAnim(main)
        if actionSettingsPanel and actionSettingsPanel.Visible then closeAnim(actionSettingsPanel) end
        local apCmds = gui_sg and gui_sg:FindFirstChild("AdminPanelCmds")
        if apCmds and apCmds.Visible then apCmds.Visible = false end
        local clickCmds = gui_sg and gui_sg:FindFirstChild("ClickToAPCmds")
        if clickCmds and clickCmds.Visible then clickCmds.Visible = false end
        local sbOwnerCmds = gui_sg and gui_sg:FindFirstChild("SpamBaseOwnerCmds")
        if sbOwnerCmds and sbOwnerCmds.Visible then sbOwnerCmds.Visible = false end
    else
        openAnim(main)
    end
end

-- CROSS-EXECUTION LEAK. Skyr0BindCapturing lives on _G, and _G survives a
-- re-execute while the task.delay that clears it does NOT -- it belongs to the
-- previous, now-dead script. So clicking a keybind row and then re-running the
-- hub left the flag true forever, and the guard below silently swallowed EVERY
-- key including the one that opens the panel. Reset on load.
_G.Skyr0BindCapturing = false
_G.__Skyr0BindCancel = nil

UIS.InputBegan:Connect(function(input,gp)
    if gp then return end
    -- Typing inside one of OUR TextBoxes does not set GameProcessed, so guard
    -- explicitly or every letter typed into the priority/blacklist boxes fires
    -- whatever action is bound to it.
    if UIS:GetFocusedTextBox() then return end
    -- A bind row is listening for the next key. That press is a CHOICE OF KEY,
    -- not a command -- without this it also ran whatever was already bound to
    -- it, so rebinding Manual TP launched a teleport and rebinding Open Menu
    -- shut the window you were binding from.
    if _G.Skyr0BindCapturing then return end

    local ut = input.UserInputType
    local kn
    if ut == Enum.UserInputType.Keyboard then kn = input.KeyCode.Name
    elseif ut == Enum.UserInputType.MouseButton3 then kn = "MouseButton3"
    else return end

    -- =================================================================
    --  CTRL ALWAYS OPENS THE PANEL.
    --
    --  The bound key is matched by NAME (so MouseButton3 works here too),
    --  but it is NOT the only way in any more. Both Control keys open the
    --  window unless you have deliberately bound that key to some other
    --  action -- KeybindMap only has an entry when an action actually
    --  claims it, so this yields to a real bind and covers every other
    --  case.
    --
    --  This exists because losing the menu key is not like losing any
    --  other bind: the Keybinds tab is INSIDE the window it opens, so
    --  there is nothing left to fix it with (desktop has no launcher
    --  button -- the FAB is touch-only). Whatever the config says, and
    --  whatever a future change does to Open Menu, Ctrl gets you in.
    -- =================================================================
    local isMenu = (UI.OpenMenuKeyName ~= nil and kn == UI.OpenMenuKeyName)
    if not isMenu and (kn == "LeftControl" or kn == "RightControl")
       and not KeybindMap[kn] then
        isMenu = true
    end
    if isMenu then
        _G.Skyr0OpenMenu()
        return
    end

    local actionName = KeybindMap[kn]
    if not actionName then return end
    local fn = KeybindActions[actionName]
    if not fn then return end
    -- pcall so one broken action can never kill the connection and take every
    -- other keybind down with it.
    local ok, err = pcall(fn)
    if not ok then warn("[skyr0] keybind '" .. actionName .. "' error:", err) end
end)


-- (AUTO-EXECUTE / TP-on-load was here -- moved UP to right after runAutoSnipe is defined
--  (~line 5767) so it starts polling as early as possible, before all the setup below.)

-- OPEN BASE BUTTONS (top-level so it exists at load, not only after opening the Misc tab)
_G.setOpenBaseButtons = function(on)
    Config.OpenBase = on; pcall(saveConfig)
    pcall(setToggle, "OpenBase", on and true or false)
    if not on then
        if _G.OpenBaseGui then pcall(function() _G.OpenBaseGui:Destroy() end); _G.OpenBaseGui = nil end
        return
    end
    if _G.OpenBaseGui and _G.OpenBaseGui.Parent then return end

    local og = Instance.new("Frame")
    og.Name = "Skyr0_OpenBase"
    og.Size = UDim2.fromOffset(150, 84)
    og.Position = UDim2.new(0, Config._openBaseX or 30, 0, Config._openBaseY or 220)
    og.BackgroundColor3 = Theme.Background
    og.BackgroundTransparency = 0.08
    og.BorderSizePixel = 0
    og.Parent = gui_sg
    corner(og, 10)
    stroke(og, Theme.AccentLight, 1, 0.35)
    _G.OpenBaseGui = og

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 26)
    title.BackgroundTransparency = 1
    title.Text = "Open Base"
    title.TextColor3 = Theme.Text
    title.Font = Enum.Font.GothamBold
    title.TextSize = 12
    title.Parent = og

    local cont = Instance.new("Frame")
    cont.Size = UDim2.new(1, -16, 0, 42)
    cont.Position = UDim2.new(0, 8, 0, 32)
    cont.BackgroundTransparency = 1
    cont.Parent = og
    local lay = Instance.new("UIListLayout", cont)
    lay.Padding = UDim.new(0, 8)
    lay.FillDirection = Enum.FillDirection.Horizontal
    lay.HorizontalAlignment = Enum.HorizontalAlignment.Center
    lay.VerticalAlignment = Enum.VerticalAlignment.Center

    for i = 1, 3 do
        local b = Instance.new("TextButton")
        b.Size = UDim2.fromOffset(38, 38)
        b.BackgroundColor3 = Theme.InputBg
        b.BackgroundTransparency = 0.45
        b.Text = tostring(i)
        b.TextColor3 = Theme.Text
        b.TextSize = 15
        b.Font = Enum.Font.GothamBold
        b.AutoButtonColor = false
        b.Parent = cont
        corner(b, 8)
        local bs = stroke(b, Theme.AccentLight, 0.8, 0.5)
        b.MouseEnter:Connect(function() tw(b,{BackgroundTransparency=0.25},0.12); tw(bs,{Transparency=0.15},0.12) end)
        b.MouseLeave:Connect(function() tw(b,{BackgroundTransparency=0.45},0.12); tw(bs,{Transparency=0.5},0.12) end)
        b.MouseButton1Click:Connect(function()
            pcall(smartInteract, i)
            tw(b,{BackgroundColor3=Theme.Green},0.08)
            task.delay(0.18, function() tw(b,{BackgroundColor3=Theme.InputBg},0.18) end)
        end)
    end

    makeDraggable(og, title)
    og:GetPropertyChangedSignal("Position"):Connect(function()
        Config._openBaseX = og.Position.X.Offset
        Config._openBaseY = og.Position.Y.Offset
        pcall(saveConfig)
    end)
end

task.spawn(function() task.wait(0.5)
    -- Desync removed from startup
    if Config.OpenBase then pcall(_G.setOpenBaseButtons, true) end
    if Config.ClickToAP then Config.ClickToAP = false end
    if Config.AntiRagdoll then startAntiRagdoll() end
    if Config.InfiniteJump then setInfiniteJump(true) end
    if Config.Float then setFloat(true) end
    if Config.Unwalk then setUnwalk(true) end

    if Config.AutoCloseOnExec then if main then main.Visible = false end end
    if Config.FPSBoost then setFPSBoost(true) end
    if Config.FPSBoostUltra then setFPSBoostUltra(true) end
    if Config.XRay then setXRay(true) end
    pcall(function() Workspace.CurrentCamera.FieldOfView = Config.FOV or 70 end)
    if Config.PlayerESP then playerESPEnabled=true end
    if Config.TimerESP then timerESPEnabled=true end
    if Config.SubspaceMineESP then subspaceMineESPEnabled=true end
    if Config.ProximityAP then setProximityAP(true) end
    if Config.AutoBuyEnabled then pcall(toggleAutoBuy, true) end
    -- ================================================================
    --  THIS IS WHY THE TP SOMETIMES IGNORED THE PRIORITY LIST.
    --
    --  The final `else setStealMode("Highest")` fired for anyone whose saved
    --  config had none of the three legacy Steal* flags set -- which is every
    --  user who turned on "Auto TP Priority Mode" and never touched the Steal
    --  panel. And setStealMode does not just set the mode: it also writes
    --  Config.AutoTPPriority = (mode == "Priority"), so it SILENTLY CLEARED the
    --  priority setting the user had actually chosen, on every single execute.
    --  _pickByMode then read "Highest" and took the biggest earner, list ignored.
    --
    --  Config.StealMode is the authoritative value -- setStealMode persists it
    --  and keeps both panels in sync -- so it is consulted FIRST now, and
    --  AutoTPPriority is honoured as a fallback before anything defaults.
    --
    --  AND THE FALLBACK ORDER WAS STILL WRONG. The fix above only moved the
    --  damage one line up: Config.StealHighest ALSO SHIPS AS TRUE (see the
    --  defaults), so `elseif Config.StealHighest` fired for exactly the same
    --  untouched configs the final `else` used to catch -- Highest mode, and
    --  AutoTPPriority = false written straight over the shipped default. Every
    --  fresh install had the priority list switched off without being asked.
    --
    --  One resolver for all of it now, shared with both target pickers, so the
    --  restore, the hook and the flight cannot disagree about the mode.
    -- ================================================================
    -- Nearest stays session-only: a saved Nearest comes back as whatever the
    -- rest of the config resolves to rather than restoring Nearest.
    if Config.StealMode == "Nearest" then Config.StealMode = nil end
    setStealMode(_G.Skyr0ResolveMode())
    if updateMovementPanelLabels then updateMovementPanelLabels() end
end)

_G.InvisStealAngle=Config.InvisStealAngle or 225; _G.SinkSliderValue=Config.SinkSliderValue or 7
_G.AutoRecoverLagback=true; _G.AutoInvisDuringSteal=Config.AutoInvisDuringSteal or false

print("Hub loaded")


task.spawn(function()
    while true do
        task.wait(15)
        pcall(collectgarbage, "collect")
    end
end)



RunService.RenderStepped:Connect(function()
    pcall(function()
        local cam = Workspace.CurrentCamera
        if cam and Config.FOV and cam.FieldOfView ~= Config.FOV then
            cam.FieldOfView = Config.FOV
        end
    end)
end)


-- No Player Collision Logic (+ clone illusion: noclip server-spawned Quantum Cloner clones so
-- placing a clone teleports you instantly instead of colliding with your own clone body).
local lastNoclipUpdate = 0
local lastCloneScan = 0
local activeClones = {}
local function _isCloneModel(m)
    if not m:IsA("Model") or not m:FindFirstChild("HumanoidRootPart") then return false end
    if not m:FindFirstChildOfClass("Humanoid") then return false end
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl.Character == m then return false end
    end
    if m.Name:find("Clone") or m.Name:find("clone") then return true end
    return m:FindFirstChild("Head") ~= nil
end
RunService.Stepped:Connect(function()
    local now = tick()
    if now - lastNoclipUpdate < 0.1 then return end
    lastNoclipUpdate = now
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            for _, part in ipairs(p.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
    -- refresh the clone list ~1x/s: any humanoid model DIRECTLY under Workspace that isn't a
    -- live player's character is a placed clone (server-spawned by the Quantum Cloner). Scanning
    -- only Workspace:GetChildren() (not descendants) keeps game pets/NPCs on plots out of scope.
    if now - lastCloneScan > 1 then
        lastCloneScan = now
        local found = {}
        for _, obj in ipairs(Workspace:GetChildren()) do
            if _isCloneModel(obj) then found[#found + 1] = obj end
        end
        activeClones = found
    end
    for _, model in ipairs(activeClones) do
        if model and model.Parent then
            for _, part in ipairs(model:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)
end 
   end

task.spawn(function()
    task.wait(0.15)
    pcall(applyTheme, "Dark")
end)


-- ============================================================
-- Skyr0 AUTO-STEAL + CLONE-TP ENGINE (integrated) -- xentp.lua 1:1 port
-- Speed: Config.TpSettings.GrabbleTPSpeed | Clone Delay: Config.TpSettings.CloneDelayVal
-- ============================================================
do
    local Players    = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UIS        = game:GetService("UserInputService")
    local RS         = game:GetService("ReplicatedStorage")
    local LP = Players.LocalPlayer

    -- ===== Modules =====
    local Synchronizer, AnimalsData, AnimalsShared, NumberUtils
    local function loadModules()
        if Synchronizer then return true end
        local ok = pcall(function()
            local Packages = RS:WaitForChild("Packages", 5)
            local Datas = RS:WaitForChild("Datas", 5)
            local Shared = RS:WaitForChild("Shared", 5)
            local Utils = RS:WaitForChild("Utils", 5)
            Synchronizer = require(Packages:WaitForChild("Synchronizer"))
            AnimalsData = require(Datas:WaitForChild("Animals"))
            AnimalsShared = _G._xenAnimShim
            NumberUtils = require(Utils:WaitForChild("NumberUtils"))
        end)
        return ok and Synchronizer ~= nil
    end

    local NetModule
    local function loadNet()
        if NetModule then return true end
        local ok, mod = pcall(function()
            return _G.Net
        end)
        if not ok or type(mod) ~= "table" then return false end
        NetModule = mod
        return true
    end

    local function fireGrapple()
        local char = LP.Character
        if not char then return end
        if not char:FindFirstChild("Grapple Hook") then
            -- TP-on-load now fires very early (warmed during the load), so it can
            -- get here before the server has finished handing you the Grapple
            -- Hook in the Backpack. Wait a moment -- bounded, and it does not
            -- block the rest of the hub -- instead of giving up instantly.
            local bp = LP:FindFirstChild("Backpack") or LP:WaitForChild("Backpack", 2)
            local tool = bp and bp:FindFirstChild("Grapple Hook")
            if not tool and bp then
                local _t0 = os.clock()
                while not tool and os.clock() - _t0 < 1.5 do
                    task.wait(0.05)
                    tool = bp:FindFirstChild("Grapple Hook")
                end
            end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if tool and hum then pcall(function() hum:EquipTool(tool) end) end
        end
        if not char:FindFirstChild("Grapple Hook") then return end
        -- Same for the remote resolver: if it has not finished scanning yet,
        -- wait an instant rather than silently failing the first time.
        if not _G.Skyr0FireGrapple2 then
            local _t0 = os.clock()
            while not _G.Skyr0FireGrapple2 and os.clock() - _t0 < 1.5 do
                task.wait(0.05)
            end
        end
        -- Fire via the TOOL, not the remote: the aim goes into every live
        -- PlayerMouse table and the item's own Activated signal is driven, so
        -- the obfuscated HookScript builds the call itself.
        if not (_G.Skyr0FireGrapple2 and _G.Skyr0FireGrapple2()) then
            warn("[skyr0] fireGrapple: could not aim or activate the Grapple Hook")
        end
    end
    _G.Skyr0FireGrapple = fireGrapple

    -- ===== Speed config (live-settable) =====
    local Skyr0Speed = { CARPET = 400, INBASE = 250 }
    _G.Skyr0SetCarpetSpeed = function(v) v = tonumber(v); if v and v > 0 then Skyr0Speed.CARPET = v end end
    _G.Skyr0SetInbaseSpeed = function(v) v = tonumber(v); if v and v > 0 then Skyr0Speed.INBASE = v end end
    _G.Skyr0GetCarpetSpeed = function() return Skyr0Speed.CARPET end
    if Config and Config.TpSettings then
        if tonumber(Config.TpSettings.GrabbleTPSpeed) then Skyr0Speed.CARPET = tonumber(Config.TpSettings.GrabbleTPSpeed) end
    end

    -- ===== Tools =====
    local CARPET_NAMES = { "Flying Carpet", "Carpet", "Cloud", "Witch's Broom", "Cupid's Wings", "Santa's Sleigh", "Magic Carpet" }
    local GRAPPLE_NAMES = { "Grapple Hook", "Grappling Hook", "Grapple", "Hook", "Web Slinger", "Grapple Gun", "GrappleHook" }
    local function findTool(name)
        local char = LP.Character
        local bp = LP:FindFirstChild("Backpack")
        return (char and char:FindFirstChild(name)) or (bp and bp:FindFirstChild(name))
    end
    local function findGrapple()
        for _, n in ipairs(GRAPPLE_NAMES) do
            local t = findTool(n); if t then return t end
        end
        return nil
    end
    local function equipCarpet()
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hum then return nil end
        local preferred = Config and Config.TpSettings and Config.TpSettings.Tool
        if preferred then
            local pt = findTool(preferred)
            if pt and pt:IsA("Tool") then
                if pt.Parent ~= char then pcall(function() hum:EquipTool(pt) end) end
                return preferred
            end
        end
        for _, n in ipairs(CARPET_NAMES) do
            local t = findTool(n)
            if t and t:IsA("Tool") then
                if t.Parent ~= char then pcall(function() hum:EquipTool(t) end) end
                return n
            end
        end
        return nil
    end
local function carpetEngage()
        if not NetModule then pcall(loadNet) end
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not char or not hum then return nil end
        -- Wait up to 3s for the grapple to replicate into backpack/character AND
        -- for _G.Net to come online. (Was 1s -- too short on a fresh join, so the
        -- very first TP silently skipped the grapple fire.)
        local _t0 = os.clock()
        while not findTool("Grapple Hook") and os.clock() - _t0 < 3 do
            if not NetModule then pcall(loadNet) end
            RunService.Heartbeat:Wait()
        end
        local g = findTool("Grapple Hook")
        if g and g.Parent ~= char then
            pcall(function() hum:EquipTool(g) end)
            -- Wait until the equip actually registers (tool becomes a child of the
            -- character) instead of a fixed 0.05s that lost the race on start.
            local _te = os.clock()
            while not (LP.Character and LP.Character:FindFirstChild("Grapple Hook"))
                  and os.clock() - _te < 0.5 do
                RunService.Heartbeat:Wait()
            end
        end
        if LP.Character and LP.Character:FindFirstChild("Grapple Hook") then
            -- Fire via the TOOL, not the remote (see Skyr0FireGrapple2): aim is
            -- written into the live PlayerMouse tables, then Activated is driven
            -- and held for 4 frames because SignalBehavior is Deferred.
            if not (_G.Skyr0FireGrapple2 and _G.Skyr0FireGrapple2()) then
                warn("[skyr0] carpetEngage: could not aim or activate the Grapple Hook")
            end
        else
            -- Diagnostic: say exactly WHY, so a load-time failure is identifiable
            -- instead of ambiguous (tool missing vs. equip race vs. no remote).
            local _bp = LP:FindFirstChild("Backpack")
            local _names = {}
            if _bp then for _, t in ipairs(_bp:GetChildren()) do _names[#_names+1] = t.Name end end
            warn(("[skyr0] carpetEngage: grapple skipped -- inBackpack=%s inChar=%s remote=%s | backpack: %s")
                :format(
                    tostring(_bp ~= nil and _bp:FindFirstChild("Grapple Hook") ~= nil),
                    tostring(LP.Character ~= nil and LP.Character:FindFirstChild("Grapple Hook") ~= nil),
                    tostring(_G.Skyr0GrappleReady and _G.Skyr0GrappleReady() or false),
                    (#_names > 0 and table.concat(_names, ", ") or "(empty)")))
        end
        task.wait(0.08)
        local h = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if h then pcall(function() h:UnequipTools() end) end
        task.wait(0.08)
        local cn
        local _tc = os.clock()
        repeat
            cn = equipCarpet()
            local c = LP.Character
            if cn and c and c:FindFirstChild(cn) then break end
            RunService.Heartbeat:Wait()
        until os.clock() - _tc > 1
        return cn
    end

    -- ===== Priority system =====
    local PET_PRIORITY_TIERS = {
        [1]  = { pets = {"Headless Horseman"}, threshold = 0 },
        [2]  = { pets = {"Signore Carapace"}, threshold = 0 },
        [3]  = { pets = {"Strawberry Elephant"}, threshold = 0 },
        [4]  = { pets = {"Arcadragon"}, threshold = 0 },
        [5]  = { pets = {"Elefanto Frigo"}, threshold = 5e9 },
        [6]  = { pets = {"John Pork"}, threshold = 10e9 },
        [7]  = { pets = {"Meowl"}, threshold = 5e9 },
        [8]  = { pets = {"Skibidi Toilet"}, threshold = 5e9 },
        [9]  = { pets = {"Love Love Bear"}, threshold = 0 },
        [10] = { pets = {"Antonio"}, threshold = 0 },
        [11] = { pets = {"Pancake and Syrup"}, threshold = 0 },
        [12] = { pets = {"Griffin"}, threshold = 0 },
        [13] = { pets = {"La Supreme Combinasion","Fishino Clownino","Dragon Gingerini","Tirilikalika Tirilikalako"}, threshold = 5e9 },
        [14] = { pets = {"Ginger Gerat","Pet"}, threshold = 10e9 },
        [15] = { pets = {"Hydra Bunny","Digi Narwhal","Kalika Bros"}, threshold = 3e9 },
        [16] = { pets = {"Hydra Dragon Cannelloni","Dragon Cannelloni","Bunny and Eggy"}, threshold = 3e9 },
        [17] = { pets = {"Globa Steppa","Ketupat Bros","Rosey and Teddy","La Casa Boo","Fragola la la"}, threshold = 3e9 },
        [18] = { pets = {"Fragola La La La","Cerberus","Guest 666","Los Hackers"}, threshold = 1e9 },
        [19] = { pets = {"Garama and Madundung","Spooky and Pumpky","Reinito Sleighito","Burguro And Fryuro","Cooki and Milki","Fragrama and Chocrama","La Food Combinasion","Los Amigos","Foxini Lanternini","Capitano Moby","Fortunu and Cashuru","Los Sekolahs","Celestial Pegasus"}, threshold = 750e6 },
        [20] = { pets = {"La Secret Combinasion","Sammyni Fattini","Cloverat Clapat","Popcuru and Fizzuru"}, threshold = 1e9 },
    }
    local TIER_LOOKUP = {}
    for tier, data in pairs(PET_PRIORITY_TIERS) do
        for _, name in ipairs(data.pets) do TIER_LOOKUP[name] = tier end
    end
    local LOCKED_TIERS = { [1]=true,[2]=true,[3]=true,[4]=true }
    local DIRECT_THRESHOLDS = {
        [3] = { [4] = 10e9 },
        [4] = {},
        [5] = { [6] = math.huge },
        [6] = { [9] = math.huge, [10] = math.huge, [12] = 15e9 },
        [10] = { [12] = 20e9 },
        [11] = { [12] = 10e9 },
    }
    local MUTATION_PRIORITY = {
        ["Galaxy"]=1,["Candy"]=1,["Yin Yang"]=1,["YinYang"]=1,["Divine"]=1,
        ["Cursed"]=1,["Lava"]=1,["Radioactive"]=1,["Cyber"]=1,["Rainbow"]=1,["Bloodrot"]=2,
    }
    local MUTATED_BEATS_GRIFFIN = {
        ["Fishino Clownino"]=true,["Globa Steppa"]=true,
        ["La Supreme Combinasion"]=true,["Tirilikalika Tirilikalako"]=true,
    }
    local function getMutPrio(m)
        if not m or m == "" or m == "None" then return 0 end
        if MUTATION_PRIORITY[m] then return MUTATION_PRIORITY[m] end
        local n = tostring(m):lower():gsub("[%s%-_]","")
        if n == "bloodrot" then return 2 end
        if n == "yinyang" or n == "galaxy" or n == "candy" or n == "divine"
            or n == "cursed" or n == "lava" or n == "radioactive" or n == "cyber"
            or n == "rainbow" then return 1 end
        return 0
    end
    local function getCumThreshold(hi, lo)
        if DIRECT_THRESHOLDS[hi] and DIRECT_THRESHOLDS[hi][lo] then return DIRECT_THRESHOLDS[hi][lo] end
        if LOCKED_TIERS[hi] then return math.huge end
        local total = 0
        for t = hi + 1, lo do
            local td = PET_PRIORITY_TIERS[t]
            if td and td.threshold > 0 then total = total + td.threshold end
        end
        return total
    end
    local function petOutranks(aName, bName, aMut, bMut, aMPS, bMPS)
        if aName == "Strawberry Elephant" and bName == "John Pork" then return true end
        if aName == "John Pork" and bName == "Strawberry Elephant" then return false end
        if MUTATED_BEATS_GRIFFIN[aName] and bName == "Griffin" and getMutPrio(aMut) >= 1 then return true end
        if aName == "Griffin" and MUTATED_BEATS_GRIFFIN[bName] and getMutPrio(bMut) >= 1 then return false end
        if aName == "Antonio" and bName == "Elefanto Frigo" and getMutPrio(aMut) >= 1 then return true end
        if aName == "Elefanto Frigo" and bName == "Antonio" and getMutPrio(bMut) >= 1 then return false end
        local tA = TIER_LOOKUP[aName] or 99
        local tB = TIER_LOOKUP[bName] or 99
        if not (TIER_LOOKUP[aName] and TIER_LOOKUP[bName]) then
            if tA == tB then return (aMPS or 0) > (bMPS or 0) end
            return tA < tB
        end
        if tA == tB then
            local pA, pB = getMutPrio(aMut), getMutPrio(bMut)
            if pA ~= pB then return pA > pB end
            return (aMPS or 0) > (bMPS or 0)
        end
        if tA == 4 and tB == 3 then return true end
        if tA == 3 and tB == 4 then return false end
        local hi = math.min(tA, tB)
        local lo = math.max(tA, tB)
        local hiMPS = tA < tB and aMPS or bMPS
        local loMPS = tA < tB and bMPS or aMPS
        local cum = getCumThreshold(hi, lo)
        if cum > 0 and cum ~= math.huge then
            if (loMPS or 0) - (hiMPS or 0) > cum then return tA > tB end
        end
        return tA < tB
    end

    -- ===== Plot/Channel helpers =====
    local function getPlotChannel(plotName)
        if not Synchronizer then return nil end
        local channel
        pcall(function() channel = _G.Skyr0_GetPlotChannel(plotName) end)
        -- NO BLOCKING RETRY HERE. This used to be:
    --     repeat channel=_G.XenSyncGet(plotName) ... task.wait(0.05)
    --     until os.clock()-_t0>3
    --
    -- i.e. up to THREE SECONDS of spinning, PER PLOT, inside the scan loop.
    -- On a server where the channels never register (the scan line reports
    -- sync=0), every plot paid the full three seconds and nothing was ever
    -- found: eight plots = a 24-SECOND teleport, which is exactly what the
    -- timing trace showed. isPlotUnlocked calls this too, which was the
    -- separate ~3s gap before carpetEngage.
    --
    -- The retry was also redundant: XenSyncGet -> _chans() ALREADY retries on
    -- its own rate-limited schedule (with the bounded deep scan), without
    -- yielding. Calling it once per scan gives exactly the same recovery over
    -- time, because the scanners run continuously.
    --
    -- And a missing channel is no longer fatal: the plot scanner falls back to
    -- rendered Models, and the TP scanners fall back to Skyr0CachedSlotsForPlot.
    if not channel then channel = _G.XenSyncGet and _G.XenSyncGet(plotName) or nil end
        return channel
    end
    local function channelGet(channel, key)
        if not channel then return nil end
        local v
        pcall(function() if type(channel.Get) == "function" then v = channel:Get(key) end end)
        if v == nil then pcall(function() v = channel.CacheTable and channel.CacheTable[key] end) end
        return v
    end
    local function isMyPlot(channel)
        if not channel then return false end
        local owner = channelGet(channel, "Owner")
        if not owner then return false end
        local result = false
        pcall(function()
            if typeof(owner) == "Instance" and owner:IsA("Player") then
                result = owner.UserId == LP.UserId
            elseif type(owner) == "table" and owner.UserId then
                result = owner.UserId == LP.UserId
            elseif typeof(owner) == "Instance" then
                result = owner == LP
            -- THREE SHAPES WERE MISSING, and they are exactly the ones that put
            -- your own base back in the target list.
            --
            -- The other copy of this function (the panel scanner's, further up)
            -- already handles a string or a number owner; this one -- the TELEPORT
            -- engine's -- did not, so on any server that reports Owner as a name
            -- or a UserId, scanAllPets kept your own plot and the flight could
            -- pick it. ownerInGame right below already reads `owner.Name`, which
            -- is proof that shape occurs here too.
            elseif type(owner) == "string" then
                result = (owner:lower() == LP.Name:lower() or owner:lower() == LP.DisplayName:lower())
            elseif type(owner) == "number" then
                result = owner == LP.UserId
            elseif type(owner) == "table" and owner.Name then
                local n = tostring(owner.Name):lower()
                result = (n == LP.Name:lower() or n == LP.DisplayName:lower())
            end
        end)
        return result
    end
    local function ownerInGame(channel)
        if not channel then return false end
        local owner = channelGet(channel, "Owner")
        if not owner then return false end
        local inGame = false
        pcall(function()
            if typeof(owner) == "Instance" and owner:IsA("Player") then
                inGame = Players:FindFirstChild(owner.Name) ~= nil
            elseif type(owner) == "number" then
                inGame = Players:GetPlayerByUserId(owner) ~= nil
            elseif type(owner) == "table" and owner.Name then
                inGame = Players:FindFirstChild(tostring(owner.Name)) ~= nil
            elseif typeof(owner) == "Instance" and owner.Name then
                inGame = Players:FindFirstChild(owner.Name) ~= nil
            end
        end)
        return inGame
    end
    local function isPlotUnlocked(plotName)
        local ok, res = pcall(function()
            local channel = getPlotChannel(plotName)
            if not channel then return false end
            return channelGet(channel, "BlockEndTimeFirstFloor") == nil
        end)
        return ok and (res == true)
    end

    -- ===== Pet position =====
    -- =====================================================================
    -- PODIUM POSITION  --  MEMOISED. THIS IS THE PERIODIC-FREEZE FIX.
    -- ---------------------------------------------------------------------
    -- The body of this used to walk podium:GetDescendants() and then, for every
    -- candidate Model it found, walk THAT model's descendants again hunting for
    -- a MeshPart. GetDescendants ALLOCATES a fresh table holding every
    -- descendant, and a podium with a brainrot on it is 50-300 instances.
    --
    -- scanAllPets calls this once per pet, and the auto-steal Heartbeat calls
    -- scanAllPets ten times a second. On a busy server -- 8 bases, ~8 occupied
    -- podiums each -- that is tens of thousands of instance references
    -- allocated EVERY SECOND, for an answer that does not change: a pet
    -- standing on a podium does not move. Luau's collector pays that bill back
    -- in one visible pause every couple of seconds, which is exactly the
    -- "freezes every ~3 seconds", and only on servers with enough brainrots on
    -- enough bases to generate the garbage. An empty server never stutters.
    --
    -- The memo is keyed by podium and holds the RESOLVED MODEL, not a position:
    --   * the entry is dropped the instant that model stops being a descendant
    --     of the podium (stolen, swapped, streamed out), so a stale coordinate
    --     cannot outlive the pet it belonged to;
    --   * the bounding box is still read live on every call, so nothing that
    --     does move reports an old position;
    --   * an EMPTY podium is remembered too (model = nil) but only for
    --     POS_MEMO_TTL, so a pet arriving is picked up on the next second --
    --     and until it is, the fallback below still returns the podium's own
    --     position, which is what the old code returned for that case anyway.
    -- =====================================================================
    local _posMemo = setmetatable({}, { __mode = "k" })   -- podium -> {model=, at=}
    local POS_MEMO_TTL = 1.0
    local function _resolvePetModel(podium)
        for _, desc in ipairs(podium:GetDescendants()) do
            if desc:IsA("Model") and desc.Name ~= "Claim" and desc.Name ~= "Base" and desc.Name ~= "Decorations" then
                for _, c in ipairs(desc:GetDescendants()) do
                    if c:IsA("MeshPart") then return desc end
                end
            end
        end
        return nil
    end
    local function getPetPosition(plot, slot)
        local podiums = plot:FindFirstChild("AnimalPodiums")
        if not podiums then return nil end
        local podium = podiums:FindFirstChild(tostring(slot))
        if not podium then return nil end

        local memo = _posMemo[podium]
        local model = memo and memo.model
        -- the remembered model has to still BE on this podium
        if model and not model:IsDescendantOf(podium) then model, memo = nil, nil end
        if not model and (not memo or (os.clock() - memo.at) > POS_MEMO_TTL) then
            model = _resolvePetModel(podium)
            _posMemo[podium] = { model = model, at = os.clock() }
        end
        if model then
            -- pcall(f, self) rather than pcall(function() ... end): the closure
            -- form allocated one function object per pet per scan, ~600 a
            -- second on a full server, all of it immediate garbage.
            local ok, cf = pcall(model.GetBoundingBox, model)
            if ok and cf then return cf.Position end
        end
        local ok, cf = pcall(podium.GetPivot, podium)
        if ok and cf then return cf.Position end
        return podium.Position
    end

    -- ===== Fusing check =====
    local _BLOCKING_MACHINE_TYPES = { Fuse=true, Duel=true, Trade=true, Crafting=true }
    local function _Skyr0IsFusing(animalData)
        if type(animalData) ~= "table" then return false end
        local m = animalData.Machine
        if type(m) ~= "table" then return false end
        return _BLOCKING_MACHINE_TYPES[m.Type] == true and m.Active == true
    end

    -- ===== Scanner =====
    -- SHORT RESULT CACHE. The auto-steal Heartbeat asks for a full scan TEN
    -- TIMES A SECOND, and every ask rebuilt the whole list -- a fresh table per
    -- pet -- and re-sorted it. Nothing on a podium changes ten times a second,
    -- so a result up to _SCAN_TTL old is the same result, at a tenth of the
    -- garbage.
    --
    -- Callers that must not be even 0.2s behind (the teleport, which decides
    -- where to fly from this) pass force=true and always get a live scan.
    -- Nothing mutates the returned list -- every consumer either reads it or
    -- copies out of it -- so handing the same table to several callers is safe.
    local _scanCache, _scanAt = nil, 0
    local _SCAN_TTL = 0.2
    local function scanAllPets(force)
        if not force and _scanCache and (os.clock() - _scanAt) < _SCAN_TTL then
            return _scanCache
        end
        local pets = {}
        if not loadModules() then return pets end
        local Plots = workspace:FindFirstChild("Plots")
        if not Plots then return pets end
        for _, plot in ipairs(Plots:GetChildren()) do
            local channel = getPlotChannel(plot.Name)
            -- see the note on the other scanner: neither "no channel" nor
            -- "owner offline" is a reason to skip a base
            -- YOUR OWN BASE, ALWAYS. The channel test only runs when there IS a
        -- channel, and on servers that key channels as PlotN there never is --
        -- which is exactly how your own brainrots ended up as TP targets. The
        -- instant check reads the PlotSign / YourBase billboard instead, so it
        -- answers with or without a channel.
        if (channel and isMyPlot(channel))
            or (_G.Skyr0IsMyPlotCached and _G.Skyr0IsMyPlotCached(plot.Name)) then continue end
            -- server first (see the note on the other scanner); falls back to
            -- the client cache when Synchronizer.RequestData is unavailable
            local animalList = (_G.Skyr0GetAnimalList and _G.Skyr0GetAnimalList(plot.Name, channel))
                            or channelGet(channel, "AnimalList")
                            or (_G.Skyr0CachedSlotsForPlot and _G.Skyr0CachedSlotsForPlot(plot.Name))
            if not animalList then continue end
            for slot, animalData in pairs(animalList) do
                if type(animalData) ~= "table" then continue end
                local animalName = animalData.Index
                if not animalName then continue end
                local animalInfo = AnimalsData and AnimalsData[animalName]
                if not animalInfo then continue end
                if _Skyr0IsFusing(animalData) then continue end
                local mutation = animalData.Mutation or "None"
                -- pcall(method, self, ...) instead of wrapping it in a closure:
                -- the closure form allocated a function object per pet per scan.
                local genValue = 0
                if AnimalsShared then
                    local okg, g = pcall(AnimalsShared.GetGeneration, AnimalsShared, animalName, animalData.Mutation,
                        (_G.Skyr0NormTraits and _G.Skyr0NormTraits(animalData.Traits) or animalData.Traits), nil)
                    if okg then genValue = tonumber(g) or 0 end
                end
                local displayName = (animalInfo and animalInfo.DisplayName) or animalName
                local pos = getPetPosition(plot, slot)
                if pos then
                    table.insert(pets, {
                        name = displayName, index = animalName, mps = genValue,
                        mutation = mutation, position = pos, plot = plot.Name, slot = tostring(slot),
                    })
                end
            end
        end
        local conveyorFolder = workspace:FindFirstChild("RenderedMovingAnimals")
        if conveyorFolder then
            for _, model in ipairs(conveyorFolder:GetChildren()) do
                pcall(function()
                    if not model:IsA("Model") then return end
                    local animalInfo = AnimalsData and AnimalsData[model.Name]
                    if not animalInfo then return end
                    local mutation = model:GetAttribute("Mutation") or "None"
                    local genValue = 0
                    pcall(function()
                        genValue = AnimalsShared:GetGeneration(model.Name, model:GetAttribute("Mutation"), nil, nil) or 0
                    end)
                    if genValue <= 0 then return end
                    local part = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
                    if not part then return end
                    table.insert(pets, {
                        name = animalInfo.DisplayName or model.Name, index = model.Name,
                        mps = genValue, mutation = mutation, position = part.Position,
                        plot = nil, slot = nil, conveyor = true, model = model,
                    })
                end)
            end
        end
        table.sort(pets, function(a, b)
            return petOutranks(a.name, b.name, a.mutation, b.mutation, a.mps, b.mps)
        end)
        _scanCache, _scanAt = pets, os.clock()
        return pets
    end

    -- FRESH-ENOUGH READ -- for callers that need current data but do not need a
    -- guaranteed rebuild.
    --
    -- This exists for the teleport. doVelocityTP ran scanAllPets(true) -- an
    -- unconditional full rebuild -- synchronously on the keypress, before it
    -- could do anything else. On a full server that is ~12 plots and ~100 pets,
    -- each pet costing a GetGeneration call and a getPetPosition that ends in
    -- model:GetBoundingBox(), then the whole list re-sorted. That is the hitch
    -- between pressing the key and moving.
    --
    -- And it was almost always redundant work: the auto-steal Heartbeat runs the
    -- same scan TEN TIMES A SECOND, so when you press the key the cache is
    -- typically 0-100ms old. Nothing the teleport reads from a pet -- podium
    -- position, gen, mutation -- changes in 150ms; pets do not move on podiums.
    -- So reuse a genuinely fresh cache and only pay for a live scan when the
    -- cache really is stale (auto-steal off, or the hub just loaded).
    --
    -- force=true is still there and still means "rebuild now" -- the cold-join
    -- poll below uses it, because that one is waiting for data it does NOT have.
    local function scanAllPetsFresh(maxAge)
        if _scanCache and (os.clock() - _scanAt) < (tonumber(maxAge) or 0.15) then
            return _scanCache
        end
        return scanAllPets(true)
    end

    -- ===== Sky coordinates =====
    local UPPER = {
        B = {{coord=Vector3.new(-487.921448,16.850713,-75.768013),facing="NORTH"},{coord=Vector3.new(-332.379730,16.850722,-75.762100),facing="NORTH"},{coord=Vector3.new(-487.134918,16.850713,-18.094154),facing="SOUTH"},{coord=Vector3.new(-316.300171,16.850713,-17.845898),facing="SOUTH"}},
        C = {{coord=Vector3.new(-330.765381,16.850713,31.424425),facing="NORTH"},{coord=Vector3.new(-502.989349,16.850713,31.172430),facing="NORTH"},{coord=Vector3.new(-489.077087,16.850713,89.010147),facing="SOUTH"},{coord=Vector3.new(-330.908936,16.850713,88.930145),facing="SOUTH"}},
        D = {{coord=Vector3.new(-331.264893,16.850713,138.209167),facing="NORTH"},{coord=Vector3.new(-487.935181,16.850713,138.026321),facing="NORTH"},{coord=Vector3.new(-487.774933,16.850713,195.882538),facing="SOUTH"},{coord=Vector3.new(-330.799133,16.850575,196.022354),facing="SOUTH"}},
    }
    local LOWER = {
        B = {{coord=Vector3.new(-335.725586,-3.048217,-74.984589),facing="NORTH"},{coord=Vector3.new(-503.214233,-3.048217,-75.043137),facing="NORTH"},{coord=Vector3.new(-483.619385,-3.718430,-18.844337),facing="SOUTH"},{coord=Vector3.new(-316.147095,-3.048218,-18.818844),facing="SOUTH"}},
        C = {{coord=Vector3.new(-335.985413,-3.048218,32.051426),facing="NORTH"},{coord=Vector3.new(-503.277008,-3.048217,31.956175),facing="NORTH"},{coord=Vector3.new(-483.749390,-3.048218,88.147003),facing="SOUTH"},{coord=Vector3.new(-315.793823,-3.048217,88.163979),facing="SOUTH"}},
        D = {{coord=Vector3.new(-335.476654,-3.048218,139.001083),facing="NORTH"},{coord=Vector3.new(-503.710083,-3.048218,138.989883),facing="NORTH"},{coord=Vector3.new(-315.654938,-3.048218,195.302444),facing="SOUTH"},{coord=Vector3.new(-483.859253,-3.048218,195.269043),facing="SOUTH"}},
    }
    local UPPER_Y_THRESHOLD = 7
    local TALL_PETS = { ["La Secret Combinasion"]=true, ["La Jolly Grande"]=true }
    local TALL_OFFSET = 3
    local BASES_LOW = {
        [1]=Vector3.new(-476.52,-2,220.94),[2]=Vector3.new(-476.52,-2,113.77),
        [3]=Vector3.new(-476.52,-2,6.18),[4]=Vector3.new(-476.52,-2,-101.07),
        [5]=Vector3.new(-342.66,-2,221.45),[6]=Vector3.new(-342.66,-2,113.41),
        [7]=Vector3.new(-342.66,-2,6.25),[8]=Vector3.new(-342.66,-2,-99.73),
    }
    local BASES_HIGH = {
        [1]=Vector3.new(-479.51,18,220.94),[2]=Vector3.new(-479.51,18,113.77),
        [3]=Vector3.new(-479.51,18,6.18),[4]=Vector3.new(-479.51,18,-101.07),
        [5]=Vector3.new(-339.48,18,221.45),[6]=Vector3.new(-339.48,18,113.41),
        [7]=Vector3.new(-339.48,18,6.25),[8]=Vector3.new(-339.48,18,-99.73),
    }
    local FRONT_Y_LOW = -3.048217
    local FRONT_Y_HIGH = 16.850713
    local COLUMN_SPLIT_X = -410
    local FRONT_Z_CLAMP = 18
    local SIDE_NEAR_Z = 45

    local function getClosestBaseIdx(pos)
        local closest, dist = 1, math.huge
        for i = 1, 8 do
            local b = BASES_LOW[i]
            local d = (pos.X - b.X)^2 + (pos.Z - b.Z)^2
            if d < dist then dist = d; closest = i end
        end
        return closest
    end
    local function buildFrontCandidate(idx, isUpper, playerZ)
        local base = isUpper and BASES_HIGH[idx] or BASES_LOW[idx]
        local frontY = isUpper and FRONT_Y_HIGH or FRONT_Y_LOW
        local frontZ = math.clamp(playerZ - base.Z, -FRONT_Z_CLAMP, FRONT_Z_CLAMP) + base.Z
        local coord = Vector3.new(base.X, frontY, frontZ)
        local faceDir = (idx <= 4) and Vector3.new(-1, 0, 0) or Vector3.new(1, 0, 0)
        return coord, faceDir
    end
    local function plotSides(coordTable, idx)
        local base = BASES_LOW[idx]
        local isWest = idx <= 4
        local out = {}
        for _, coords in pairs(coordTable) do
            for _, data in ipairs(coords) do
                if ((data.coord.X < COLUMN_SPLIT_X) == isWest)
                   and math.abs(data.coord.Z - base.Z) < SIDE_NEAR_Z then
                    out[#out + 1] = data
                end
            end
        end
        return out
    end
    local function findClosest(petPos, coordTable)
        local best, bestKey, bestDist = nil, nil, math.huge
        for skyKey, coords in pairs(coordTable) do
            for _, data in ipairs(coords) do
                local c = data.coord
                local d = math.sqrt((petPos.X - c.X)^2 + (petPos.Z - c.Z)^2)
                if d < bestDist then bestDist = d; best = data; bestKey = skyKey end
            end
        end
        return best, bestKey
    end

    -- ===== Viz =====
    local _vizParts = {}
    local function clearViz()
        for _, p in ipairs(_vizParts) do if p and p.Parent then p:Destroy() end end
        table.clear(_vizParts)
    end
    local function vizPath(fromPos, waypoints)
        -- Pathfinder lines/dots disabled (user request: no lines).
        return
    end

    -- ===== Movement =====
    local SPEED = 200
    local ARRIVE = 3
    local MAX_CLIMB = 60

    local function vZero(hrp)
        if hrp then hrp.AssemblyLinearVelocity = Vector3.zero; hrp.AssemblyAngularVelocity = Vector3.zero end
    end

    local function velMoveThrough(hrp, waypoints, speedOverride, allowJump, quickStart)
        if not hrp or not hrp.Parent or #waypoints == 0 then return end
        local _runSpeed = speedOverride or Skyr0Speed.CARPET
        vizPath(hrp.Position, waypoints)
        local wpIdx = 1
        local done = false
        local conn
        local function finish()
            if done then return end
            done = true
            if hrp and hrp.Parent then
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
                local _, y = hrp.CFrame:ToEulerAnglesYXZ()
                hrp.CFrame = CFrame.new(waypoints[#waypoints]) * CFrame.Angles(0, y, 0)
            end
            if conn then conn:Disconnect() end
            clearViz()
        end
        local lastDist, stall = math.huge, 0
        if quickStart then
            local _hp = RaycastParams.new()
            _hp.FilterType = Enum.RaycastFilterType.Exclude
            _hp.IgnoreWater = true
            local _skip = {}
            for _, pl in ipairs(Players:GetPlayers()) do
                if pl.Character then _skip[#_skip + 1] = pl.Character end
            end
            _hp.FilterDescendantsInstances = _skip
            for _ = 1, 3 do
                local target = waypoints[wpIdx]
                if not target then break end
                local flat = Vector3.new(target.X - hrp.Position.X, 0, target.Z - hrp.Position.Z)
                local mag = flat.Magnitude
                if mag < 1 then break end
                local nextPos = hrp.Position + flat.Unit * math.min(20, mag)
                local _hit = workspace:Raycast(hrp.Position, nextPos - hrp.Position, _hp)
                if _hit and _hit.Instance and _hit.Instance.CanCollide then break end
                hrp.CFrame = (hrp.CFrame - hrp.CFrame.Position) + nextPos
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
                RunService.Heartbeat:Wait()
                if not hrp or not hrp.Parent then return end
            end
        end
        conn = RunService.Heartbeat:Connect(function()
            if not hrp or not hrp.Parent or done then
                if conn then conn:Disconnect() end; return
            end
            equipCarpet()
            local target = waypoints[wpIdx]
            local diff = target - hrp.Position
            local mag = diff.Magnitude
            if mag < ARRIVE then
                wpIdx = wpIdx + 1
                if wpIdx > #waypoints then finish(); return end
                lastDist, stall = math.huge, 0
                target = waypoints[wpIdx]
                diff = target - hrp.Position
                mag = diff.Magnitude
            end
            if mag > lastDist - 0.05 then stall = stall + 1 else stall = 0 end
            lastDist = mag
            if stall >= 18 then finish(); return end
            if mag >= 0.1 then
                local dir = diff.Unit
                if allowJump and diff.Y > 5 and wpIdx < #waypoints then
                    local hum = hrp.Parent and hrp.Parent:FindFirstChildOfClass("Humanoid")
                    if hum then
                        local st = hum:GetState()
                        if st ~= Enum.HumanoidStateType.Jumping and st ~= Enum.HumanoidStateType.Freefall then
                            pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end)
                            pcall(function() hum.Jump = true end)
                        end
                    end
                end
                local _vy = dir.Y * _runSpeed
                if _vy > MAX_CLIMB then _vy = MAX_CLIMB end
                hrp.Velocity = Vector3.new(dir.X * _runSpeed, _vy, dir.Z * _runSpeed)
            end
        end)
        local totalDist = 0
        local prev = hrp.Position
        for _, wp in ipairs(waypoints) do totalDist = totalDist + (prev - wp).Magnitude; prev = wp end
        local timeout = totalDist / math.min(SPEED, _runSpeed) + 2
        local elapsed = 0
        while not done and elapsed < timeout do task.wait(0.05); elapsed = elapsed + 0.05 end
        finish()
        vZero(hrp)
    end

    -- ===== Routing =====
    local _DIRS = { Vector3.new(1,0,0), Vector3.new(-1,0,0), Vector3.new(0,0,1), Vector3.new(0,0,-1) }
    local _STRUCT = { ["structure base home"]=true, ["Wall"]=true, ["Floor"]=true, ["Roof"]=true }
    local _SKIP_NAME = { ["DeliveryHitbox"]=true, ["StealHitbox"]=true, ["LaserHitbox"]=true,
        ["AnimalTarget"]=true, ["Multiplier"]=true, ["Laser"]=true, ["Hitbox"]=true,
        ["Spawn"]=true, ["MainRoot"]=true, ["SecondFloor"]=true, ["ThirdFloor"]=true, ["Slope"]=true }
    local function _blocks(inst)
        if not inst then return false end
        if _SKIP_NAME[inst.Name] then return false end
        if inst.CanCollide then return true end
        if _STRUCT[inst.Name] then return true end
        local s = inst.Size
        if s and math.max(s.X * s.Y, s.X * s.Z, s.Y * s.Z) > 150 then return true end
        return false
    end
    local function _blocksWide(inst)
        if not inst then return false end
        if _SKIP_NAME[inst.Name] then return false end
        if inst.CanCollide then return true end
        if _STRUCT[inst.Name] then return true end
        local s = inst.Size
        if s and math.max(s.X * s.Y, s.X * s.Z, s.Y * s.Z) > 30 then return true end
        return false
    end
    -- ONE RaycastParams, ONE cached player-skip list, and AddToFilter instead of
    -- a whole-array reassignment per bounce.
    --
    -- This is the single hottest function on the teleport path, and it rebuilt
    -- its entire world on EVERY call: a fresh RaycastParams, a full
    -- Players:GetPlayers() walk to collect characters, and then -- inside a loop
    -- that runs up to 16 times -- a reassignment of FilterDescendantsInstances,
    -- which revalidates the whole instance array each time. So one _clear() cost
    -- up to 16 raycasts AND 16 array revalidations AND a player scan.
    --
    -- Multiply that by the callers: _clearWide is FIVE _blocks, and _pullWide
    -- called it in an O(N^2) loop. That burst is the freeze right before the TP.
    local _rp = RaycastParams.new()
    _rp.FilterType = Enum.RaycastFilterType.Exclude
    _rp.IgnoreWater = true
    local _charSkip, _charSkipAt = {}, 0
    local function _charList()
        -- 1s TTL instead of per-raycast: someone spawning mid-solve is not a
        -- correctness concern for a path that takes milliseconds to compute.
        if _charSkipAt ~= 0 and (os.clock() - _charSkipAt) < 1 then return _charSkip end
        local t = {}
        for _, pl in ipairs(Players:GetPlayers()) do if pl.Character then t[#t + 1] = pl.Character end end
        _charSkip, _charSkipAt = t, os.clock()
        return t
    end
    -- AddToFilter appends without revalidating the array. Probed once; the
    -- copy-and-reassign path below is the fallback for older clients.
    local _hasAddToFilter = pcall(function() return RaycastParams.new().AddToFilter end)
    local function _block(origin, target, blockFn)
        blockFn = blockFn or _blocks
        local skip = _charList()
        -- Resets the shared params for this call (and drops whatever the last
        -- call appended). The cached list itself is never mutated -- growing it
        -- would poison the cache -- so a copy is made only if we actually bounce
        -- and AddToFilter is unavailable.
        _rp.FilterDescendantsInstances = skip
        local grown = nil
        local o = origin
        for _ = 1, 16 do
            local d = target - o; if d.Magnitude < 0.05 then return nil end
            local res = workspace:Raycast(o, d, _rp)
            if not res then return nil end
            if blockFn(res.Instance) then return res end
            if _hasAddToFilter then
                _rp:AddToFilter(res.Instance)
            else
                if not grown then
                    grown = table.create and table.create(#skip + 4) or {}
                    table.move(skip, 1, #skip, 1, grown)
                end
                grown[#grown + 1] = res.Instance
                _rp.FilterDescendantsInstances = grown
            end
            o = res.Position + d.Unit * 0.3
        end
        return nil
    end
    local function _clear(a, b) return _block(a, b) == nil end
    local function _clearDist(origin, dir, maxD)
        local res = _block(origin, origin + dir.Unit * maxD)
        if not res then return maxD end
        return (res.Position - origin).Magnitude
    end
    local function _pull(pts)
        if #pts <= 2 then return pts end
        local out = { pts[1] }; local i = 1
        while i < #pts do
            local j = #pts
            while j > i + 1 and not _clear(out[#out], pts[j]) do j = j - 1 end
            out[#out + 1] = pts[j]; i = j
        end
        return out
    end
    local function _clearWideRay(a, b) return _block(a, b, _blocksWide) == nil end
    local function _clearWide(a, b)
        if not _clear(a, b) then return false end
        local d = Vector3.new(b.X - a.X, 0, b.Z - a.Z)
        if d.Magnitude < 0.1 then return true end
        local _CLEARANCE = 10
        local perp = Vector3.new(-d.Z, 0, d.X).Unit * _CLEARANCE
        local up = Vector3.new(0, _CLEARANCE, 0)
        return _clearWideRay(a + perp, b + perp) and _clearWideRay(a - perp, b - perp)
            and _clearWideRay(a + up, b + up) and _clearWideRay(a - up, b - up)
    end
    -- BOUNDED SMOOTHING.
    --
    -- The old loop scanned backwards from the END of the route for every point
    -- it kept -- O(N^2) calls to _clearWide, and _clearWide is FIVE _blocks of
    -- up to 16 raycasts each. On a 20-waypoint route that is tens of thousands
    -- of raycasts in ONE frame, with nothing yielding in between. That is the
    -- freeze immediately before the teleport.
    --
    -- Two bounds. The LOOKAHEAD cap costs almost nothing in route quality: a
    -- shortcut worth taking is nearly always a few waypoints ahead, not twenty,
    -- and the only penalty for missing one is a route with an extra corner in
    -- it. The DEADLINE is the hard guarantee -- whatever the map geometry does,
    -- past the budget the pass stops refining and hands back what it has, which
    -- is still a perfectly flyable path.
    local _PULL_LOOKAHEAD = 6
    local function _pullWide(pts, deadline)
        if #pts <= 2 then return pts end
        local out = { pts[1] }; local i = 1
        while i < #pts do
            if deadline and os.clock() > deadline then
                for k = i + 1, #pts do out[#out + 1] = pts[k] end
                return out
            end
            local j = math.min(#pts, i + _PULL_LOOKAHEAD)
            while j > i + 1 and not _clearWide(out[#out], pts[j]) do j = j - 1 end
            out[#out + 1] = pts[j]; i = j
        end
        return out
    end
    -- Linear in the waypoint count (4 _blocks each), so far less dangerous than
    -- _pullWide -- but it shares the same budget so a pathological route cannot
    -- spend it all here and leave nothing for the caller.
    local function _pushOffWalls(pts, deadline)
        if #pts <= 2 then return pts end
        local MARGIN = 10; local MAX_PUSH = 14
        local out = { pts[1] }
        for i = 2, #pts - 1 do
            if deadline and os.clock() > deadline then
                for k = i, #pts do out[#out + 1] = pts[k] end
                return out
            end
            local p = pts[i]; local shift = Vector3.zero
            for _, dr in ipairs(_DIRS) do
                local res = _block(p, p + dr * MARGIN, _blocks)
                if res then
                    local dist = (res.Position - p).Magnitude
                    if dist < MARGIN then shift = shift - dr * (MARGIN - dist) end
                end
            end
            if shift.Magnitude > 0.1 then
                if shift.Magnitude > MAX_PUSH then shift = shift.Unit * MAX_PUSH end
                local moved = p + shift
                if _clear(out[#out], moved) then out[#out + 1] = moved else out[#out + 1] = p end
            else
                out[#out + 1] = p
            end
        end
        out[#out + 1] = pts[#pts]
        return out
    end
    local PathfindingService = game:GetService("PathfindingService")
    local function computeRoute(fromPos, toPos, facingDir)
        if _clear(fromPos, toPos) then return { toPos } end
        local entry = facingDir and (toPos - facingDir * 14) or toPos
        local groundTo = Vector3.new(entry.X, fromPos.Y, entry.Z)
        local path = PathfindingService:CreatePath({
            AgentRadius = 12, AgentHeight = 5, AgentCanJump = true, AgentJumpHeight = 10, AgentMaxSlope = 89,
        })
        local FLOAT = 3
        local nav = { fromPos }
        local ok = pcall(function()
            path:ComputeAsync(Vector3.new(fromPos.X, fromPos.Y, fromPos.Z), groundTo)
        end)
        if ok and path.Status == Enum.PathStatus.Success then
            local last = fromPos
            for _, wp in ipairs(path:GetWaypoints()) do
                if (wp.Position - last).Magnitude >= 8 then
                    nav[#nav + 1] = wp.Position + Vector3.new(0, FLOAT, 0); last = wp.Position
                end
            end
        end
        nav[#nav + 1] = entry + Vector3.new(0, FLOAT, 0)
        -- HARD BUDGET for the two smoothing passes, shared between them.
        --
        -- Whatever geometry the map throws at these, the raycasting cannot cost
        -- more than this before they bail and return what they have. Both passes
        -- degrade gracefully: an unsmoothed route just has more corners in it,
        -- and velMoveThrough flies whatever it is given.
        --
        -- ~30ms is about two frames -- noticeable if you look for it, nowhere
        -- near the multi-second stall the unbounded version could produce.
        -- _G.Skyr0RouteBudget overrides it.
        local deadline = os.clock() + (tonumber(_G.Skyr0RouteBudget) or 0.03)
        nav = _pushOffWalls(nav, deadline)
        local route = _pullWide(nav, deadline)
        route[#route + 1] = toPos
        return route
    end

    -- ===== Clone / goToBrainrot =====
    local function doClone()
        local char = LP.Character or LP.CharacterAdded:Wait()
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not char or not hum then return false end
        local cloner = (LP:FindFirstChild("Backpack") and LP.Backpack:FindFirstChild("Quantum Cloner"))
                    or char:FindFirstChild("Quantum Cloner")
        if not cloner then
            warn("[skyr0] doClone: Quantum Cloner not found in Backpack or Character")
            return false
        end
        -- Use the EXACT manual-clone method: equip the cloner, Activate() it, then
        -- firesignal the game's own TeleportToClone button so the GAME performs the
        -- switch through its legitimate code path. Firing QuantumCloner/OnTeleport
        -- directly stopped switching after the update -- this doesn't.
        if _G.Skyr0InstantClone then
            _G.Skyr0InstantClone()
            return true
        end
        warn("[skyr0] doClone: manual clone method (_G.Skyr0InstantClone) unavailable")
        return false
    end

    -- CARPET GLIDE: fly straight to the pet on the equipped carpet at FULL 3D speed
    -- (same pace as velMoveThrough -- WalkTPSpeed in the actual direction, vertical
    -- included). The carpet is already equipped by goToBrainrot, so no extra equip
    -- wait. Used as the FINAL approach after the clone/grabble TP.
    local function carpetGlideTo(targetPos)
        if not targetPos then return end
        local char = LP.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        pcall(function() hrp.Anchored = false end)
        pcall(equipCarpet)
        local SPEED = (Config.TpSettings and (tonumber(Config.TpSettings.WalkTPSpeed) or tonumber(Config.TpSettings.GrabbleTPSpeed))) or 190
        local FLOAT_OFFSET = (targetPos.Y > 20) and -4 or 0
        local goal = Vector3.new(targetPos.X, targetPos.Y + FLOAT_OFFSET, targetPos.Z)
        local t0 = os.clock()
        local lastDist, stall = math.huge, 0
        while hrp.Parent and (os.clock() - t0) < 8 do
            if LP:GetAttribute("Stealing") then break end
            equipCarpet()
            local diff = goal - hrp.Position
            local mag = diff.Magnitude          -- full 3D distance (so it doesn't stop short on upper floors)
            if mag < 3 then break end
            if mag > lastDist - 0.05 then stall = stall + 1 else stall = 0 end
            lastDist = mag
            if stall >= 30 then break end       -- stuck on a wall -> give up
            hrp.AssemblyLinearVelocity = diff.Unit * SPEED   -- full speed straight at the pet
            RunService.Heartbeat:Wait()
        end
        if hrp and hrp.Parent then
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end
    end

    local function goToBrainrot(petPos)
        if not petPos then return end
        local char, hrp, hum
        local _t0 = os.clock()
        repeat
            char = LP.Character
            hrp = char and char:FindFirstChild("HumanoidRootPart")
            hum = char and char:FindFirstChildOfClass("Humanoid")
            if hrp and hum then break end
            RunService.Heartbeat:Wait()
        until os.clock() - _t0 > 3
        if not hrp or not hum then return end
        pcall(function() hrp.Anchored = false end)
        local _equipped = false
        do
            local _e0 = os.clock()
            repeat
                char = LP.Character
                for _, _cn in ipairs(CARPET_NAMES) do
                    if char and char:FindFirstChild(_cn) then _equipped = true; break end
                end
                if _equipped then break end
                equipCarpet()
                RunService.Heartbeat:Wait()
            until _equipped or os.clock() - _e0 > 1.5
            if _equipped then task.wait(0.2) end
        end
        char = LP.Character
        hrp = char and char:FindFirstChild("HumanoidRootPart")
        hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hrp then return end
        pcall(function() hrp.Anchored = false end)
        local _plotRad = (petPos.Y <= 8.9) and 26 or 25
        do
            local _t0b = os.clock()
            repeat
                local p = hrp.Position
                local inRad = false
                local plotsFolder = workspace:FindFirstChild("Plots")
                if plotsFolder then
                    for _, plot in ipairs(plotsFolder:GetChildren()) do
                        pcall(function()
                            local pp = plot:GetPivot().Position
                            if math.abs(p.X - pp.X) < _plotRad and math.abs(p.Z - pp.Z) < _plotRad then inRad = true end
                        end)
                        if inRad then break end
                    end
                end
                if inRad then break end
                RunService.Heartbeat:Wait()
            until os.clock() - _t0b > 1.5
        end
        local h = petPos.Y
        -- one band, shared with doVelocityTP's coord clamp and its _forceGo
        local _isF2FromF1Case = _G.Skyr0IsF2FromF1 and _G.Skyr0IsF2FromF1(h) or false
        local targetY = hrp.Position.Y
        if h > 23.15 then targetY = 21
        elseif h >= 11 and h <= 23.15 then
            -- V3 Floor 2 from Floor 1: use the runAutoSnipe F3-from-F2 pattern
            -- literally -- character ends up at petY - 8 (8 studs below the pet)
            -- and the platform below settles at petY - 11 (3 studs below the
            -- character). Same relative offsets the F3 case uses, just applied
            -- to the F2 pet Y.
            targetY = (_isF2FromF1Case and (h - 8)) or 14.5
        elseif h >= -6.9 and h <= 8.9 then targetY = -4 end
        local _to = Vector3.new(petPos.X, targetY, petPos.Z)
        -- V3 Floor 2 from Floor 1: after the clone lands us inside the base on
        -- floor 1, spam Humanoid.Jump so we bounce up toward the 2nd floor pet
        -- instead of moving to under it with a lerp+platform.
        if _isF2FromF1Case then
            task.spawn(function()
                local start = tick()
                while (tick() - start) < 8 do
                    if LP:GetAttribute("Stealing") then break end
                    if hum and hum.Parent then
                        pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end)
                        pcall(function() hum.Jump = true end)
                    end
                    task.wait(0.1)
                end
            end)
        elseif Config.TpSettings and Config.TpSettings.BrainrotCarpet then
            -- Carpet to Brainrot: after the clone/grabble TP into the base, glide on
            -- the carpet straight to the pet (uses live Walk To Brainrot Speed).
            carpetGlideTo(petPos)
        else
            local _route = computeRoute(hrp.Position, _to, nil)
            if not _route or #_route == 0 then _route = { _to } end
            velMoveThrough(hrp, _route, (Config and Config.TpSettings and (tonumber(Config.TpSettings.WalkTPSpeed) or tonumber(Config.TpSettings.GrabbleTPSpeed))) or Skyr0Speed.INBASE, true, true)
        end
        if hrp and hrp.Parent and not _isF2FromF1Case then
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end
        if not _isF2FromF1Case then
            do
                local _platPos = (hrp and hrp.Parent and hrp.Position) or _to
                local _feetY = _platPos.Y - 3
                local _plat = Instance.new("Part")
                _plat.Name = "Skyr0TempPlatform"; _plat.Size = Vector3.new(8, 1, 8)
                _plat.Position = Vector3.new(petPos.X, _feetY - 1.5, petPos.Z)
                _plat.Anchored = true; _plat.CanCollide = false; pcall(makeOneWay, _plat); _plat.Transparency = 1
                _plat.Material = Enum.Material.SmoothPlastic; _plat.Parent = workspace
                task.spawn(function()
                    local _s = tick()
                    while tick() - _s < 20 do
                        if LP:GetAttribute("Stealing") then break end
                        task.wait(0.1)
                    end
                    if _plat and _plat.Parent then _plat:Destroy() end
                end)
            end
        end
    end

    -- ===== Steal engine =====
    local InternalStealCache = {}
    local STEAL_HOLD_DURATION = 1.3
    local _stealHoldStart = 0
    local _stealHoldActive = false

    local function buildStealCallbacks(prompt)
        if InternalStealCache[prompt] then return end
        if not prompt or not prompt.Parent then return end
        local data = { holdCallbacks = {}, triggerCallbacks = {}, holdEndCallbacks = {}, ready = true }
        local function grab(sig, into)
            local ok, conns = pcall(getconnections, sig)
            if ok and type(conns) == "table" then
                for _, c in ipairs(conns) do
                    if type(c.Function) == "function" then table.insert(into, c.Function) end
                end
            end
        end
        grab(prompt.PromptButtonHoldBegan, data.holdCallbacks)
        grab(prompt.Triggered, data.triggerCallbacks)
        grab(prompt.PromptButtonHoldEnded, data.holdEndCallbacks)
        if #data.holdCallbacks > 0 or #data.triggerCallbacks > 0 or #data.holdEndCallbacks > 0 then
            InternalStealCache[prompt] = data
        end
    end

    local function executeStealAsync(prompt)
        local data = InternalStealCache[prompt]
        if not data or not data.ready then return false end
        data.ready = false
        _stealHoldStart = tick()
        _stealHoldActive = true
        _G.Skyr0_StealStatus = _G.Skyr0_StealStatus or {}
        _G.Skyr0_StealStatus.active = true
        _G.Skyr0_StealStatus.start = _stealHoldStart
        _G.Skyr0_StealStatus.duration = tonumber(_G.Skyr0StealHoldDuration) or STEAL_HOLD_DURATION

        task.spawn(function()
            for _, fn in ipairs(data.holdCallbacks) do task.spawn(fn) end
            pcall(function()
                local _st = prompt:GetAttribute("State")
                if _st ~= nil and _st ~= "Steal" then
                    -- Was `_net:RemoteEvent(<guid>)`, which hands back the DEAD
                    -- PLAINTEXT ALIAS -- the steal fires went nowhere. Resolve
                    -- through the hashed resolver (HERENEW's GetRemote-first
                    -- order) and only keep it if it is a real remote, so a miss
                    -- retries next steal instead of latching a stub forever.
                    -- THIS is the "lags every time a remote happens" site.
                    --
                    -- The name here is a GUID, which is the Net folder's own key,
                    -- so Skyr0GetRemote answers it with a plain FindFirstChild.
                    -- The _G.Net fallback underneath it did not: _G.Net resolves
                    -- lazily and runs build() -- a getgc(true) walk of the entire
                    -- Lua heap. And because a failed resolve leaves
                    -- _xenStealRemote nil, this whole block re-ran on EVERY
                    -- steal, so a name that never resolves meant a heap sweep
                    -- every 15s for the rest of the session.
                    --
                    -- The fallback is gone. A miss now costs three FindFirstChild
                    -- calls and retries on the next steal, which is what the
                    -- retry was always meant to be.
                    if not _G._xenStealRemote or not _G._xenStealRemote.Parent then
                        local _r, _real = nil, false
                        if _G.Skyr0GetRemote then
                            _r, _real = _G.Skyr0GetRemote("f40f7d9e-2f0d-4167-b250-899273f46874", "RemoteEvent")
                        end
                        if _r and _real then _G._xenStealRemote = _r end
                    end
                    local r = _G._xenStealRemote
                    if r then
                        local _t = workspace:GetServerTimeNow() + 124
                        r:FireServer(_t, "68c86eb7-eb7e-4b4d-96ae-cf7cd847c5b0")
                        r:FireServer(_t, "07b9cc25-2a1f-4a26-a0ec-f2fab578d8bd")
                    end
                end
            end)
            -- Effective hold before firing the trigger that completes the steal.
            -- Live-tunable via _G.Skyr0StealHoldDuration (default 1.3 = the game's
            -- normal timing). Kept SEPARATE from STEAL_HOLD_DURATION so the
            -- guard/threshold logic below is unaffected by it. Lower is faster
            -- but far more detectable -- change it deliberately.
            local _holdDur = tonumber(_G.Skyr0StealHoldDuration) or STEAL_HOLD_DURATION
            local remain = _holdDur - (tick() - _stealHoldStart)
            if remain > 0 then task.wait(remain) end
            if prompt and prompt.Parent then
                for _, fn in ipairs(data.triggerCallbacks) do task.spawn(fn) end
            end
            for _, fn in ipairs(data.holdEndCallbacks) do task.spawn(fn) end
            _stealHoldActive = false
            if _G.Skyr0_StealStatus then _G.Skyr0_StealStatus.active = false end
            task.wait(0.05)
            data.ready = true
        end)
        return true
    end

    local function findStealPrompt(pet)
        if pet.plot and pet.slot then
            local plots = workspace:FindFirstChild("Plots")
            local plot = plots and plots:FindFirstChild(pet.plot)
            local podiums = plot and plot:FindFirstChild("AnimalPodiums")
            local podium = podiums and podiums:FindFirstChild(tostring(pet.slot))
            if podium then
                local base = podium:FindFirstChild("Base")
                local spawn = base and base:FindFirstChild("Spawn")
                local attach = spawn and spawn:FindFirstChild("PromptAttachment")
                if attach then
                    for _, p in ipairs(attach:GetChildren()) do
                        if p:IsA("ProximityPrompt") then return p end
                    end
                end
                for _, d in ipairs(podium:GetDescendants()) do
                    if d:IsA("ProximityPrompt") then return d end
                end
            end
        end
        if pet.model and pet.model.Parent then
            for _, d in ipairs(pet.model:GetDescendants()) do
                if d:IsA("ProximityPrompt") then return d end
            end
        end
        return nil
    end

    local STEAL_PROXIMITY = 60
    local STEAL_ARM_TIMEOUT = 25
    local _stealTarget = nil
    local _stealArmedAt = 0

    local function timeUntilCanSteal()
        if LP:GetAttribute("Stealing") or LP:GetAttribute("IsTrading")
            or LP:GetAttribute("IsDuelSelecting") or LP:GetAttribute("Web") then
            return -1
        end
        return 0
    end

    local function _petKey(pet)
        if not pet then return nil end
        if pet.plot and pet.slot then return tostring(pet.plot) .. "|" .. tostring(pet.slot) end
        return "idx|" .. tostring(pet.index or pet.name)
    end
    local function _petStillExists(sel, pets)
        if not sel or not pets then return nil end
        local k = _petKey(sel)
        for _, p in ipairs(pets) do if _petKey(p) == k then return p end end
        return nil
    end
    -- forward declaration: _pickByMode's priority branch falls back to this, and
    -- it is defined further down (it needs getPetPosition)
    local _petPorUID

    -- The topmost priority-list entry present on the server, or nil.
    --
    -- Split out of _pickByMode so it can run BEFORE the mode branches instead of
    -- after them (see the note there), and so the "no min gen ever applies to a
    -- priority pet" rule lives in exactly one place: nothing in here filters on
    -- earnings at all. If it is on your list, it is a target, full stop.
    --
    -- Trimming/case-folding and the same-name tie-break are in
    -- _G.Skyr0PickPriority, shared with getTargetPetData and the Steal Target
    -- selector -- this used to take the FIRST scan-order match while
    -- getTargetPetData took the biggest earner of that name, and
    -- getTargetPetData's pick is what Skyr0CicloTP locks in as the teleport's
    -- destination. Two of the same priority pet on a server and the hook aimed
    -- at one base while the grab was armed on the other.
    local function _pickPriorityFrom(pets, hrp)
        if not (priorityList and #priorityList > 0 and _G.Skyr0PickPriority) then return nil end
        local _rp
        if typeof(hrp) == "Vector3" then _rp = hrp
        elseif typeof(hrp) == "Instance" then _rp = hrp.Position end

        if pets then
            local hit = _G.Skyr0PickPriority(
                pets,
                function(p) return p.mps or 0 end,
                function(p) return p.position end,
                function(p) return not p.conveyor end,
                _rp)
            if hit then return hit end
        end

        -- SECOND CHANCE: the PANEL's cache.
        --
        -- The panel (SharedState.AllAnimalsCache) and this teleport engine build
        -- two INDEPENDENT lists -- the file says so at _petPorUID -- and the panel
        -- deliberately sees pets the engine cannot: bases with no channel resolved
        -- yet, and rendered-Model entries. So a priority pet can be sitting right
        -- there in your list while `pets` above does not contain it, and the walk
        -- falls through to the biggest earner. That is the intermittent "it went
        -- to the wrong one": it depends on which bases have replicated, which is
        -- different every join.
        --
        -- _petPorUID rebuilds the entry from the uid, taking the position from the
        -- podium exactly as the engine would, so the result is a normal target and
        -- not a second-class one.
        local cache = (_G.SharedState and _G.SharedState.AllAnimalsCache)
                   or (SharedState and SharedState.AllAnimalsCache)
        if type(cache) == "table" and _petPorUID then
            local eu = LocalPlayer
            -- EVERY listed candidate, in list order -- not just the top one.
            --
            -- Taking only the best and giving up if _petPorUID could not rebuild
            -- it (no podium position yet, plot not streamed) threw away every
            -- OTHER priority pet on the server and fell straight through to the
            -- biggest earner. Walk down the list instead: #1 if it resolves, else
            -- #2, and so on. Only a completely unresolvable list falls through.
            local cands = {}
            for _, a in ipairs(cache) do
                if a and a.uid and a.plot
                   and a.owner ~= eu.Name and a.owner ~= eu.DisplayName
                   and not (_G.Skyr0IsMyPlotCached and _G.Skyr0IsMyPlotCached(a.plot)) then
                    local rank = _G.Skyr0PrioRank(a.name, a.index)
                    if rank then cands[#cands + 1] = { a = a, rank = rank, gen = a.genValue or 0 } end
                end
            end
            table.sort(cands, function(x, y)
                if x.rank ~= y.rank then return x.rank < y.rank end
                return x.gen > y.gen
            end)
            for _, c in ipairs(cands) do
                local rebuilt = _petPorUID(c.a.uid)
                if rebuilt and rebuilt.position then return rebuilt end
            end
        end
        return nil
    end

    local function _pickByMode(pets, hrp)
        if not pets or #pets == 0 then return nil end
        local C = Config or {}
        -- ============================================================
        --  THE PRIORITY LIST IS NOT A MODE. IT IS THE FIRST TIER.
        --
        --  This ran BELOW the mode branches, so `mode == "Highest"` and
        --  `mode == "Nearest"` both returned before the list was ever read.
        --  And the mode resolves to "Highest" for anyone whose saved config
        --  has StealMode = "Highest" in it -- one click on the Steal panel,
        --  ever, and the priority list was dead from then on, silently.
        --
        --  The list is the user's explicit "take THESE, in THIS order". It is
        --  checked first, always, whatever the mode says. The mode only
        --  decides what happens when NOTHING on the list is on the server --
        --  which is what the Highest/Nearest branches below now are.
        -- ============================================================
        local hit = _pickPriorityFrom(pets, hrp)
        if hit then return hit end

        -- The resolution lives in _G.Skyr0ResolveMode so that getTargetPetData
        -- -- whose pick is what actually locks the teleport's destination, see
        -- the note there -- answers this question with the SAME code. The two
        -- had drifted: this one read AutoTPHighestGen/Value and that one read
        -- nothing at all.
        local mode = _G.Skyr0ResolveMode and _G.Skyr0ResolveMode() or (C.StealMode or "Priority")

        if mode == "Nearest" then
            -- `hrp` may be an HRP instance (the usual case) OR a bare Vector3.
            -- The teleport passes a Vector3 while it is airborne so "nearest"
            -- is measured from the DESTINATION rather than from a root part
            -- that is still crossing the map -- see the call site.
            local rp
            if typeof(hrp) == "Vector3" then
                rp = hrp
            elseif typeof(hrp) == "Instance" then
                rp = hrp.Position
            else
                local c = LocalPlayer.Character
                local h = c and c:FindFirstChild("HumanoidRootPart")
                rp = h and h.Position
            end
            if rp then
                local best, bd = nil, math.huge
                for _, p in ipairs(pets) do
                    if p.position then
                        local d = (rp - p.position).Magnitude
                        if d < bd then bd, best = d, p end
                    end
                end
                if best then return best end
            end
            return pets[1]
        end

        if mode == "Highest" then
            local best, bv
            for _, p in ipairs(pets) do
                local v = p.mps or 0
                if not bv or v > bv then bv, best = v, p end
            end
            return best or pets[1]
        end

        -- Neither Highest nor Nearest, and nothing on the list is here: the
        -- biggest earner.
        local best, bv
        for _, p in ipairs(pets) do
            local v = p.mps or 0
            if not bv or v > bv then bv, best = v, p end
        end
        return best or pets[1]
    end
    local function _samePet(a, b)
        if not a or not b then return false end
        return a.plot == b.plot and tostring(a.slot) == tostring(b.slot)
    end

    -- ========================================================
    --  REBUILD A PET FROM ITS UID -- fixes "the TP goes to the wrong pet"
    --
    --  The PANEL (scanSinglePlot -> SharedState.AllAnimalsCache) and the TP
    --  ENGINE (scanAllPets, in this scope) build TWO INDEPENDENT lists. The
    --  only link between them is manuallySelectedUID = plot.."_"..slot.
    --
    --  When the clicked uid was not in the engine's list, the code fell
    --  through to `_pickByMode(allPets) or allPets[1]` -- silently, with no
    --  error: you clicked one pet and the TP flew to a different one. That is
    --  the "sometimes it works, sometimes it doesn't".
    --
    --  It became common with the new plot scanner, which deliberately sees
    --  pets the engine cannot: rendered-Model entries and bases with no
    --  channel at all. So the panel lists them and the engine does not.
    --
    --  Here the entry is rebuilt from the uid itself. The position comes from
    --  the usual getPetPosition (podium), never from the Model's pivot, so
    --  floor and slot still come from the old system.
    -- ========================================================
    -- assigns the forward-declared local above (so _pickByMode's priority
    -- second-chance can reach it); NOT a new local
    function _petPorUID(uid)
        if type(uid) ~= "string" then return nil end
        -- the plot UUID contains no "_", so the LAST one separates the slot
        local plotName, slot = uid:match("^(.+)_([^_]+)$")
        if not plotName or not slot then return nil end

        local plots = workspace:FindFirstChild("Plots")
        local plot = plots and plots:FindFirstChild(plotName)
        if not plot then return nil end

        local pos = getPetPosition(plot, slot)
        if not pos then return nil end

        -- name/value come from what the panel already showed, for display only
        local nome, mps, mut = "Target", 0, "None"
        for _, a in ipairs(SharedState.AllAnimalsCache or {}) do
            if a.uid == uid then
                nome = a.name or nome
                mps  = a.genValue or 0
                mut  = a.mutation or mut
                break
            end
        end
        return {
            name = nome, index = nome, mps = mps, mutation = mut,
            position = pos, plot = plotName, slot = tostring(slot),
        }
    end

    local _stealTarget2 = nil
    local function armSteal(pet)
        if not pet then return end
        _stealTarget = pet; _stealArmedAt = os.clock()
        _stealTarget2 = pet
        _G.Skyr0_StealStatus = _G.Skyr0_StealStatus or {}
        _G.Skyr0_StealStatus.target = pet
    end
    local function disarmSteal()
        _stealTarget = nil
        _G.Skyr0_StealStatus = _G.Skyr0_StealStatus or {}
        _G.Skyr0_StealStatus.target = nil
        _G.Skyr0_StealStatus.active = false
    end
    _G.Skyr0ArmSteal = armSteal
    _G.Skyr0DisarmSteal = disarmSteal

    local AUTO_STEAL = (Config and Config.AutoStealEnabled) and true or false
    _G.Skyr0AutoSteal = function(on) AUTO_STEAL = on ~= false end

    local _stealLastScan = 0
    local _autoLastScan = 0
    local isTeleporting = false
    local _tpStartedAt = 0
    local _cloneTP = false
    local _cloneFired = false
    local _started = false
    -- last plot-scanner cache version this loop acted on; a change means the
    -- plots really changed and the target should be re-decided (see the gate
    -- in the Heartbeat below)
    local _lastCacheVer = -1
    -- position the in-flight teleport committed to, used as the "nearest"
    -- reference while airborne so a mid-flight retarget cannot chase the HRP
    local _tpAnchor = nil

    -- =====================================================================
    -- AUTO-GRAB FINISHER
    -- ---------------------------------------------------------------------
    -- Called by the anti-ragdoll watchdog a short lead before a ragdoll
    -- recovery finishes, so the steal engine is already armed and clean the
    -- instant you are back on your feet instead of spending the first second
    -- upright sorting itself out.
    --
    -- A ragdoll interrupts a steal, so once you are back up the engine should
    -- be picking a target again rather than sitting on whatever it was reaching
    -- for when you got knocked over.
    --
    -- WHAT THIS MUST NOT DO: touch an in-flight hold.
    --
    -- The first version force-set data.ready = true on every cached prompt, on
    -- the theory that an interrupted hold could leave it stuck false. It cannot
    -- -- executeStealAsync's coroutine is just task.wait plus callbacks, it
    -- always runs to completion and always restores ready itself. What forcing
    -- it actually did was let a SECOND hold coroutine start on a prompt that
    -- already had one running. Both then raced: each finished, each set
    -- _stealHoldActive/Skyr0_StealStatus.active false and ready true again 0.05s
    -- later, and each of those re-opened the gate for another. The result was a
    -- permanent restart loop -- the bar climbing to 10% or 60% and snapping back
    -- to 0 forever, from a single ragdoll, until rejoin.
    --
    -- So: if a hold is genuinely running, leave it completely alone. It will
    -- finish on its own in at most STEAL_HOLD_DURATION and the normal path takes
    -- over from there. Only when nothing is in flight does this re-arm.
    -- =====================================================================
    _G.Skyr0GrabFinisher = function()
        -- Re-enable, but never turn on something the user switched off.
        if Config and Config.AutoStealEnabled then AUTO_STEAL = true end

        -- A hold is running: hands off. No ready flags, no status writes, no
        -- disarm -- every one of those is what created the overlapping
        -- coroutines. It completes by itself.
        if _stealHoldActive then return false end

        -- Nothing in flight: drop the stale progress and force the re-picker to
        -- re-evaluate on its next Heartbeat tick.
        --
        -- Deliberately NOT disarmSteal(). The re-picker already keeps the target
        -- when it is still the best one and swaps it when it is not, so a disarm
        -- buys nothing -- and it is actively harmful if the re-picker happens to
        -- be frozen for a teleport, which would leave nothing armed at all.
        _G.Skyr0_StealStatus = _G.Skyr0_StealStatus or {}
        _G.Skyr0_StealStatus.active = false
        _autoLastScan = 0
        return true
    end

    RunService.Heartbeat:Connect(function()
        local now = os.clock()
        -- FROZEN FOR THE WHOLE FLIGHT, not just the clone sub-case.
        --
        -- This is what made the TP and the auto-grab go to DIFFERENT pets. The
        -- teleport picks its destination ONCE, at the top of doVelocityTP, from
        -- a forced scan -- and then flies. This re-picker kept running for the
        -- entire flight, every 0.1s, off its own (0.2s-cached) scan, and
        -- re-armed _stealTarget the moment its answer differed.
        --
        -- In "Nearest" mode that divergence is guaranteed, not occasional: the
        -- reference point is the HRP and the HRP is crossing the map at ~400
        -- studs/s, so "nearest" is a different pet on almost every tick. You
        -- land where the TP aimed and auto-grab has already armed something
        -- else. Priority/Highest diverge too, just less often -- the TP reads a
        -- forced scan and this reads a stale one, so a pet that replicates in
        -- mid-flight flips the pick.
        --
        -- The destination is now the armed target (doVelocityTP calls armSteal
        -- on its own pick) and nothing is allowed to re-target until the flight
        -- ends. Same 30s reclaim as the doVelocityTP stale-guard, so a leaked
        -- isTeleporting can't freeze retargeting forever.
        --
        -- The cycle latch is checked as well as the engine's own flag. TP-on-load
        -- runs Skyr0CicloTP, which GRAPPLES AND CLIMBS before it ever reaches
        -- doVelocityTP -- so isTeleporting is still false for that whole first
        -- leg, and this loop was re-scanning every 0.1s (a full ~100-pet rebuild,
        -- GetBoundingBox per pet) right through it. That is load-time frames
        -- spent re-deciding a target that is about to be decided anyway.
        -- __Skyr0CicloRodando is set for the whole cycle; it holds os.clock() at
        -- start, so it carries the same 20s reclaim doVelocityTP gives it.
        local _ciclo = _G.__Skyr0CicloRodando
        local _cicloRunning = type(_ciclo) == "number" and (os.clock() - _ciclo) < 20
        local _tpInFlight = (isTeleporting and (now - _tpStartedAt) < 30) or _cicloRunning

        -- PLOT CHANGED -> RETARGET, even mid-flight.
        --
        -- The freeze above stops the TIMER-driven re-pick, which is the one that
        -- caused the TP and the grab to disagree: it re-decided ten times a
        -- second off data that had not changed, and in "Nearest" mode it chased
        -- the HRP across the map while the HRP was the thing moving.
        --
        -- What it must NOT stop is a retarget when the WORLD actually changes --
        -- someone steals the pet you were flying at, a base empties out, new pets
        -- land. Frozen through that, the engine sat on a target that no longer
        -- existed and never grabbed anything.
        --
        -- SharedState.CacheVersion is exactly that signal and nothing else: the
        -- plot scanner bumps it only after its content hash says the cache really
        -- changed, so this fires on real plot changes and not on a timer.
        local _ver = SharedState and SharedState.CacheVersion or 0
        local _plotChanged = (_ver ~= _lastCacheVer)
        if _plotChanged then _lastCacheVer = _ver end

        if AUTO_STEAL and _started and not LP:GetAttribute("Stealing")
            and (_plotChanged or not _tpInFlight)
            and (now - _autoLastScan) >= 0.1 then
            _autoLastScan = now
            local char = LP.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local ok, pets = pcall(scanAllPets)
                if ok and pets then
                    local best
                    -- Manual selection from Skyr0Hub
                    if manuallySelectedUID then
                        for _, pet in ipairs(pets) do
                            if not pet.conveyor and pet.plot and pet.slot then
                                local uid = pet.plot .. "_" .. tostring(pet.slot)
                                if uid == manuallySelectedUID then best = pet; break end
                            end
                        end
                        -- not in the engine's list: rebuild it from the uid
                        -- instead of silently switching to a different pet
                        if not best then best = _petPorUID(manuallySelectedUID) end
                    end
                    if not best then
                        -- One picker for every mode. Nearest used to be handled
                        -- separately here (measuring to the steal PROMPT rather
                        -- than the pet), so the auto-steal loop and the TP could
                        -- disagree about which pet is nearest and fight over the
                        -- target. Both go through _pickByMode now.
                        local nc = {}
                        for _, p in ipairs(pets) do if not p.conveyor then nc[#nc + 1] = p end end
                        -- MID-FLIGHT, MEASURE FROM WHERE WE ARE GOING.
                        --
                        -- Only relevant to "Nearest". Retargeting during a flight
                        -- is the right thing to do when the plot changed, but
                        -- measuring "nearest" from the LIVE HRP while it crosses
                        -- the map at ~400 studs/s is what made the TP and the grab
                        -- disagree in the first place -- the answer changes every
                        -- tick and none of those answers is where you will land.
                        --
                        -- _tpAnchor is the position the teleport committed to, so
                        -- during a flight the question becomes "which pet will be
                        -- nearest when I arrive" -- stable, and consistent with
                        -- the destination. On the ground it is nil and the live
                        -- HRP is used exactly as before.
                        best = _pickByMode(nc, (_tpInFlight and _tpAnchor) or hrp)
                    end
                    if best then
                        if not _samePet(best, _stealTarget) then armSteal(best) end
                    elseif _stealTarget and not _stealHoldActive then
                        disarmSteal()
                    end
                end
            end
        end

        local pet = _stealTarget
        if not pet then return end
        local STEAL_MODE = (Config and Config.StealMode) or "Priority"
        if STEAL_MODE == "Nearest" and now - _stealArmedAt > STEAL_ARM_TIMEOUT then
            disarmSteal(); return
        end
        if now - _stealLastScan < 0.067 then return end
        _stealLastScan = now
        local t = timeUntilCanSteal()
        if t == -1 then
            if LP:GetAttribute("Stealing") then disarmSteal() end
            return
        end
        if t > 0 and t > STEAL_HOLD_DURATION then return end
        local char = LP.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local prompt = findStealPrompt(pet)
        if not prompt or not prompt.Parent then return end
        local pp = prompt.Parent
        local ppPos = (pp and pp:IsA("BasePart") and pp.Position)
            or (pp and pp.Parent and pp.Parent:IsA("BasePart") and pp.Parent.Position)
        local _inCloneTP = isTeleporting and _cloneTP and _cloneFired
        if not _inCloneTP and ppPos and (hrp.Position - ppPos).Magnitude > STEAL_PROXIMITY then return end
        local oldMax
        pcall(function() oldMax = prompt.MaxActivationDistance end)
        pcall(function() prompt.MaxActivationDistance = math.huge end)
        buildStealCallbacks(prompt)
        if InternalStealCache[prompt] then executeStealAsync(prompt) end
        pcall(function() if oldMax ~= nil then prompt.MaxActivationDistance = oldMax end end)
    end)

    -- ===== Main TP function (1:1 xentp.lua doVelocityTP) =====
    local function doVelocityTP()
        if isTeleporting and (os.clock() - _tpStartedAt) < 30 then return end
        isTeleporting = true
        _tpStartedAt = os.clock()
        _cloneTP = false
        _cloneFired = false
        clearViz()
        if not NetModule then pcall(loadNet) end

        local char = LP.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then isTeleporting = false; return end

        -- hub_Mata's scan gate. Three differences from a bare scanAllPets():
        --   * pcall + type check: a scan that throws used to take the whole TP
        --     down with it instead of just retrying.
        --   * _nBase counts NON-CONVEYOR pets. #allPets counted belt pets too,
        --     so a single brainrot riding the conveyor satisfied "found
        --     something" and the poll exited with no base target to fly to.
        --   * 6s at 0.05 instead of 4s at 0.15 -- more attempts, and the first
        --     success is caught ~100ms sooner on a cold join.
        -- Fresh-enough instead of forced. The teleport picks its destination
        -- from this, so it must not read stale data -- but a 150ms-old scan is
        -- not stale for a pet standing on a podium, and forcing a rebuild here
        -- put a full ~100-pet scan (each one a GetBoundingBox) directly on the
        -- keypress, duplicating what the auto-steal Heartbeat had just done
        -- milliseconds earlier. See scanAllPetsFresh. The cold-join poll below
        -- still forces, because it is waiting for data that does not exist yet.
        local _okScan, allPets = pcall(scanAllPetsFresh, 0.15)
        if not _okScan or type(allPets) ~= "table" then
            isTeleporting = false; return
        end
        local function _nBase(t)
            local n = 0
            for _, p in ipairs(t) do if not p.conveyor then n = n + 1 end end
            return n
        end
        if _nBase(allPets) == 0 then
            local _t0 = os.clock()
            while _nBase(allPets) == 0 and os.clock() - _t0 < 6 do
                task.wait(0.05)
                local ok2, r = pcall(scanAllPets, true)
                if ok2 and type(r) == "table" then allPets = r end
            end
        end
        -- hub_Mata gates the FINAL check on #allPets, not _nBase: after the poll
        -- gives up, a conveyor-only result is still allowed through rather than
        -- aborting the teleport outright.
        if #allPets == 0 then isTeleporting = false; return end

        -- Respect Skyr0Hub manual selection, then fall back to priority/mode
        local pet
        if manuallySelectedUID then
            for _, p in ipairs(allPets) do
                if p.plot and p.slot and (p.plot .. "_" .. tostring(p.slot)) == manuallySelectedUID then pet = p; break end
            end
            -- not in the engine's list: rebuild from the uid rather than
            -- silently changing target (see _petPorUID)
            if not pet then pet = _petPorUID(manuallySelectedUID) end
            -- A MANUAL CHOICE IS ABSOLUTE. This used to fall through to
            -- _pickByMode below, which does NOT filter the conveyor -- which is
            -- how the TP ended up flying at RenderedMovingAnimals. If the
            -- clicked target cannot be resolved, better to not teleport at all
            -- than to go somewhere else.
            if not pet then isTeleporting = false; return end
        end
        -- ================================================================
        --  HONOUR THE CYCLE'S LOCKED TARGET.  <-- "it TPs to random things"
        --
        --  Skyr0CicloTP picks the base to GRAPPLE at using
        --  _G.Skyr0GetTargetPetData -- the PANEL's picker, over
        --  SharedState.AllAnimalsCache -- and then stashes that exact pet in
        --  _G.Skyr0TPLockedPet, with a comment saying "the TP reuses this exact
        --  pet instead".
        --
        --  It never did. NOTHING read that global. So the cycle grappled toward
        --  your priority brainrot's base, and then doVelocityTP -- reached a
        --  fraction of a second later -- ran a COMPLETELY DIFFERENT picker
        --  (_pickByMode, over this engine's own scanAllPets list) and flew
        --  wherever that one landed. Two pickers, two data sources, one flight.
        --  That is why the grapple went one way and the teleport another, and
        --  why it looked random rather than simply wrong.
        --
        --  The lock is honoured here, as intended, and consumed so a stale one
        --  can never steer a later teleport. The live entry from THIS scan is
        --  preferred when present (fresher position); _petPorUID rebuilds it
        --  when the engine cannot see that pet, which is the whole reason the
        --  two lists disagree in the first place.
        -- ================================================================
        if not pet then
            local locked   = _G.Skyr0TPLockedPet
            local lockedAt = tonumber(_G.Skyr0TPLockedAt) or 0
            _G.Skyr0TPLockedPet, _G.Skyr0TPLockedAt = nil, nil
            if type(locked) == "table" and locked.plot and locked.slot
               and (os.clock() - lockedAt) < 20
               and not (_G.Skyr0IsMyPlotCached and _G.Skyr0IsMyPlotCached(locked.plot)) then
                local uid = tostring(locked.plot) .. "_" .. tostring(locked.slot)
                for _, p in ipairs(allPets) do
                    if not p.conveyor and p.plot and p.slot
                       and (p.plot .. "_" .. tostring(p.slot)) == uid then
                        pet = p; break
                    end
                end
                if not pet then pet = _petPorUID(uid) end
            end
        end

        -- ================================================================
        --  GO WHERE AUTO-GRAB IS ALREADY GOING.  (fallback, not first choice)
        --
        --  ORDER MATTERS, AND GETTING IT WRONG PUT THE TELEPORT BACK ON RANDOM
        --  PETS. This block used to sit ABOVE the cycle lock, and that is a
        --  strictly worse source on the grapple path:
        --
        --    Skyr0CicloTP raises __Skyr0CicloRodando FIRST, which FREEZES the
        --    auto-steal re-picker, and only then calls getTargetPetData to aim
        --    the grapple and set the lock. So by the time doVelocityTP runs,
        --    _stealTarget is whatever happened to be armed BEFORE the cycle
        --    started -- frozen, possibly minutes old, possibly not on the
        --    priority list at all -- while the lock is a fresh, priority-first
        --    pick made moments ago. Reading the stale one first overrode the
        --    good one on every single grapple TP.
        --
        --  It stays, below the lock, because it is the right answer for a
        --  teleport that never went through the cycle (side TP, dispatcher,
        --  re-fire) -- there is no lock in those cases and the armed target is
        --  then the only live statement of intent.
        --
        --  The hub has THREE independent target pickers, each over its own data:
        --    * the beam/tracer  -- its own walk of SharedState.AllAnimalsCache
        --    * the steal engine -- _pickByMode over scanAllPets, result in
        --                          _stealTarget (this is what actually gets
        --                          grabbed)
        --    * this teleport    -- _pickByMode again, its own fresh scan
        --
        --  Two runs of _pickByMode are not the same answer. The steal loop and
        --  the teleport scan at different moments, and the priority pet may be
        --  visible to one list and not the other -- the panel scanner resolves
        --  bases the engine cannot (no channel yet, rendered-Model only), which
        --  is exactly why _petPorUID exists. So auto-grab arms the priority pet,
        --  the tracer draws to it, and the teleport independently decides on
        --  something else.
        --
        --  _stealTarget is what the engine will actually fire the prompt on, so
        --  on a lock-less teleport it is the best statement of intent there is.
        --
        --  BUT IT NEVER OUTRANKS THE LIST. If the armed pet is not on the
        --  priority list and the list is in use, this stands aside and lets
        --  _pickByMode run -- that path checks the list first, across BOTH the
        --  engine scan and the panel cache, so it can see a listed pet the
        --  auto-steal loop had not gotten to yet. Without this guard a stale
        --  non-priority armed target would win outright, which is the whole
        --  complaint: it goes to random stuff while a priority pet is sitting
        --  right there.
        -- ================================================================
        local _armedRanked = (type(_stealTarget) == "table" and _G.Skyr0PrioRank)
            and _G.Skyr0PrioRank(_stealTarget.name, _stealTarget.index) or nil
        local _listInUse = (type(priorityList) == "table" and #priorityList > 0)
        if not pet and type(_stealTarget) == "table"
           and (_armedRanked or not _listInUse)
           and _stealTarget.plot and _stealTarget.slot and not _stealTarget.conveyor
           and not (_G.Skyr0IsMyPlotCached and _G.Skyr0IsMyPlotCached(_stealTarget.plot)) then
            local uid = tostring(_stealTarget.plot) .. "_" .. tostring(_stealTarget.slot)
            for _, p in ipairs(allPets) do
                if not p.conveyor and p.plot and p.slot
                   and (p.plot .. "_" .. tostring(p.slot)) == uid then
                    pet = p; break
                end
            end
            -- armed against a pet this engine's scan cannot see: rebuild it from
            -- the uid rather than falling through to a different target
            if not pet then pet = _petPorUID(uid) end
        end

        if not pet then
            -- no manual choice: conveyor pets are out of the running. The
            -- auto-steal path already filtered this way; only doVelocityTP did not.
            local semEsteira = {}
            for _, p in ipairs(allPets) do
                if not p.conveyor then semEsteira[#semEsteira+1] = p end
            end
            if #semEsteira == 0 then isTeleporting = false; return end
            -- hrp passed explicitly: in "Nearest" mode _pickByMode measures from
            -- this reference, and the auto-steal caller above already passes it.
            -- It fell back to LocalPlayer's HRP here, which is the same instance
            -- -- but leaving the two call sites asymmetric is how they drifted
            -- apart in the first place.
            pet = _pickByMode(semEsteira, hrp) or semEsteira[1]
        end

        -- ================================================================
        --  LAST LINE OF DEFENCE AGAINST FLYING HOME.  <-- "it TPs to my own base"
        --
        --  Every picker above does filter your own plot -- but each one does it
        --  from a DIFFERENT snapshot, and the flight commits to whichever
        --  answered last:
        --    * the engine's scanAllPets list (its own isMyPlot + the cache)
        --    * a lock stashed by the grapple cycle up to 20 SECONDS earlier
        --    * _petPorUID, which resolves a uid straight off the plot with no
        --      ownership test at all -- and both the lock path and the manual
        --      path fall back to it
        --    * the bare `or semEsteira[1]` above, which is not filtered by
        --      anything except "not a conveyor pet"
        --
        --  One stale or cold answer anywhere in that chain and you fly home.
        --  Asked once more here, at the point of no return, against what the
        --  check knows NOW -- and a positive is latched for the session (see
        --  Skyr0IsMyPlotCached), so by this point it is as good as it gets.
        --
        --  Conveyor pets have no plot and are skipped, not rejected.
        -- ================================================================
        if pet and pet.plot and _G.Skyr0IsMyPlotCached and _G.Skyr0IsMyPlotCached(pet.plot) then
            warn("[skyr0] TP: target sits on YOUR OWN base -- re-picking.")
            local safe = {}
            for _, p in ipairs(allPets) do
                if not p.conveyor and p.plot and not _G.Skyr0IsMyPlotCached(p.plot) then
                    safe[#safe+1] = p
                end
            end
            if #safe == 0 then
                warn("[skyr0] TP aborted: nothing on this server but your own base.")
                isTeleporting = false
                return
            end
            -- re-picked through the mode, not just "the first survivor", so the
            -- replacement still obeys the priority list
            pet = _pickByMode(safe, hrp) or safe[1]
        end

        -- ================================================================
        --  SAY WHAT IT PICKED AND WHY.
        --
        --  Every "the TP went to the wrong thing" report so far has been a
        --  guess at which of five pickers answered, because the flight commits
        --  in silence. One line at the point of no return: the pet, its place
        --  in your priority list (or that it is not on it at all), how many
        --  listed pets were on the server, and the mode that would have decided
        --  if the list came up empty.
        --
        --  If this says "not on list" while the pet IS on your list, the names
        --  disagree -- the list entry and AnimalsData.DisplayName are not the
        --  same string -- and that is a matching problem, not a picker problem.
        -- ================================================================
        if pet then
            local _rank = _G.Skyr0PrioRank and _G.Skyr0PrioRank(pet.name, pet.index)
            local _onServer = 0
            for _, p in ipairs(allPets) do
                if not p.conveyor and _G.Skyr0PrioRank and _G.Skyr0PrioRank(p.name, p.index) then
                    _onServer = _onServer + 1
                end
            end
            warn(("[skyr0] TP target: %s -- %s | %d listed pet(s) on server | fallback mode: %s")
                :format(tostring(pet.name),
                        _rank and ("priority #" .. _rank) or "NOT ON LIST",
                        _onServer,
                        tostring(_G.Skyr0ResolveMode and _G.Skyr0ResolveMode() or "?")))
        end

        -- ONE TARGET FOR BOTH ENGINES.
        --
        -- The destination the TP just committed to IS the pet auto-grab will
        -- take. Previously the TP flew to `pet` and never told the steal engine
        -- anything -- the Heartbeat above kept picking its own target on its own
        -- schedule, so the two routinely disagreed and you arrived next to a pet
        -- auto-grab had no interest in. Arming it here, combined with the flight
        -- freeze on the re-picker, makes the destination and the grab target the
        -- same pet by construction rather than by coincidence.
        --
        -- Conveyor pets are excluded: they have no plot/slot, so findStealPrompt
        -- has nothing to resolve and arming one would just park the steal engine
        -- on a target it can never fire. (Both selection branches above already
        -- filter them out; this is a guard, not a live case.)
        if not pet.conveyor then armSteal(pet) end
        -- The "nearest" reference for the rest of the flight. A mid-flight
        -- retarget (plot changed) measures from HERE, not from the moving HRP.
        _tpAnchor = pet.position

        local _tpSpd = (Config and Config.TpSettings and Config.TpSettings.GrabbleTPSpeed) or 400
        local _cloneDelay = (Config and Config.TpSettings and Config.TpSettings.CloneDelayVal) or 0.35

        local petPos = pet.position
        local petName = pet.name

        local adjY = petPos.Y
        if TALL_PETS[petName] then adjY = petPos.Y - TALL_OFFSET end
        -- V3 Floor 2 from Floor 1: when the pet is on floor 2 and the toggle is on,
        -- clamp adjY down so coordTable picks LOWER (floor-1 wall) instead of UPPER.
        -- Same band as goToBrainrot's arrival half -- see _G.Skyr0IsF2FromF1.
        local _f2FromF1 = _G.Skyr0IsF2FromF1 and _G.Skyr0IsF2FromF1(petPos.Y) or false
        if _f2FromF1 then adjY = math.min(adjY, UPPER_Y_THRESHOLD) end
        local coordTable = adjY > UPPER_Y_THRESHOLD and UPPER or LOWER

        -- CONVEYOR
        if pet.conveyor then
            local model = pet.model
            local maxHP = hum.MaxHealth
            hum.Health = maxHP
            local healConn = RunService.Heartbeat:Connect(function()
                if hum and hum.Parent then hum.Health = maxHP end
            end)
            carpetEngage()
            vZero(hrp)
            local function livePos()
                if not model or not model.Parent then return nil end
                local part = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
                return part and part.Position or nil
            end
            local _t0 = os.clock()
            -- hub_Mata's chase loop: stall detection + a vertical clamp.
            local _parado, _ultDist = 0, math.huge
            while os.clock() - _t0 < 8 do
                if not hrp or not hrp.Parent then break end
                local lp = livePos()
                if not lp then break end
                local diff = lp - hrp.Position
                local mag = diff.Magnitude
                if mag <= 6 then break end
                -- Stuck on geometry: without this the loop kept pushing into a
                -- wall for the full 8s while the distance never dropped. 25
                -- frames of no progress is enough to call it.
                if mag > _ultDist - 0.05 then _parado = _parado + 1 else _parado = 0 end
                _ultDist = mag
                if _parado >= 25 then break end
                equipCarpet()
                local v = diff.Unit * _tpSpd
                -- Vertical clamp, same 60 the mover uses. Chasing a target
                -- straight overhead produced a full-speed climb the server reads
                -- as flight and rolls back.
                if v.Y > 60 then v = Vector3.new(v.X, 60, v.Z) end
                hrp.AssemblyLinearVelocity = v
                RunService.Heartbeat:Wait()
            end
            if hrp and hrp.Parent then
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
            end
            healConn:Disconnect()
            _tpAnchor = nil
            isTeleporting = false
            return
        end

        -- FIRST FLOOR: pathfinder walks the player straight in via the front door.
        -- V3 Floor 2 from Floor 1 is intentionally NOT routed here -- it always goes
        -- through the SKY CLONE-TP branch below so the clone anchors the character
        -- and goToBrainrot's CFrame lerp reliably places you under the pet with a
        -- platform (same pattern the F3-from-F2 case uses).
        if petPos.Y <= 8.9 and isPlotUnlocked(pet.plot) then
            local maxHP = hum.MaxHealth
            hum.Health = maxHP
            local healConn = RunService.Heartbeat:Connect(function()
                if hum and hum.Parent then hum.Health = maxHP end
            end)
            carpetEngage()
            vZero(hrp)
            local _to = Vector3.new(petPos.X, -4, petPos.Z)
            local _faceDir
            do
                local idx = getClosestBaseIdx(petPos)
                local _, frontFace = buildFrontCandidate(idx, false, hrp.Position.Z)
                _faceDir = frontFace
            end
            local route = computeRoute(hrp.Position, _to, _faceDir)
            if not route or #route == 0 then route = { _to } end
            velMoveThrough(hrp, route, _tpSpd, true, true)
            if hrp and hrp.Parent then
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
            end
            -- V3 Floor 2 from Floor 1 also spams jump on arrival for floor-1
            -- pets so we grab elevated pets on floor 1 (small platforms, podiums,
            -- pets sitting slightly above ground level).
            if Config.AutoTPFloor2FromFloor1 then
                task.spawn(function()
                    local start = tick()
                    while (tick() - start) < 5 do
                        if LP:GetAttribute("Stealing") then break end
                        if hum and hum.Parent then
                            pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end)
                            pcall(function() hum.Jump = true end)
                        end
                        task.wait(0.1)
                    end
                end)
            end
            healConn:Disconnect()
            _tpAnchor = nil
            isTeleporting = false
            return
        end

        -- SKY CLONE-TP
        _cloneTP = true
        disarmSteal()

        local closestData, skyKey = findClosest(petPos, coordTable)
        if not closestData or not skyKey then _tpAnchor = nil; isTeleporting = false; return end

        local destPos = closestData.coord
        local maxHP = hum.MaxHealth
        hum.Health = maxHP
        local healConn = RunService.Heartbeat:Connect(function()
            if hum and hum.Parent then hum.Health = maxHP end
        end)

        carpetEngage()
        vZero(hrp)

        local facingDir = closestData.facing == "NORTH" and Vector3.new(0, 0, -1) or Vector3.new(0, 0, 1)
        do
            local isUpper = (coordTable == UPPER)
            local idx = getClosestBaseIdx(petPos)
            local frontCoord, frontFace = buildFrontCandidate(idx, isUpper, hrp.Position.Z)
            local bestCoord, bestFace = frontCoord, frontFace
            local bestDist = (hrp.Position - frontCoord).Magnitude
            for _, d in ipairs(plotSides(coordTable, idx)) do
                local dd = (hrp.Position - d.coord).Magnitude
                if dd < bestDist then
                    bestDist = dd
                    bestCoord = d.coord
                    bestFace = d.facing == "NORTH" and Vector3.new(0, 0, -1) or Vector3.new(0, 0, 1)
                end
            end
            destPos = bestCoord
            facingDir = bestFace
        end

        if hrp and hrp.Parent then
            hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + facingDir)
            hrp.AssemblyAngularVelocity = Vector3.zero
        end

        local _route = computeRoute(hrp.Position, destPos, facingDir)
        local _stepped = {}
        do
            local startY = hrp.Position.Y
            local destY = destPos.Y
            local prev = hrp.Position
            local totalFlat = 0
            for _, wp in ipairs(_route) do
                totalFlat = totalFlat + (Vector3.new(wp.X, 0, wp.Z) - Vector3.new(prev.X, 0, prev.Z)).Magnitude
                prev = wp
            end
            if totalFlat < 0.01 then totalFlat = 0.01 end
            local SEG = 30
            prev = hrp.Position
            local travelled = 0
            for _, wp in ipairs(_route) do
                local flatVec = Vector3.new(wp.X, 0, wp.Z) - Vector3.new(prev.X, 0, prev.Z)
                local legFlat = flatVec.Magnitude
                if legFlat >= 0.01 then
                    local subs = math.max(1, math.ceil(legFlat / SEG))
                    for s = 1, subs do
                        local f = s / subs
                        local px = prev.X + (wp.X - prev.X) * f
                        local pz = prev.Z + (wp.Z - prev.Z) * f
                        local along = travelled + legFlat * f
                        local rampY = startY + (destY - startY) * (along / totalFlat)
                        _stepped[#_stepped + 1] = Vector3.new(px, rampY, pz)
                    end
                else
                    _stepped[#_stepped + 1] = wp
                end
                travelled = travelled + legFlat
                prev = wp
            end
            if #_stepped > 0 then _stepped[#_stepped] = _route[#_route] end
        end
        velMoveThrough(hrp, _stepped, _tpSpd, true, true)

        hrp.CFrame = CFrame.new(destPos, destPos + facingDir)
        vZero(hrp)

        local syncFrames = 5
        local syncConn
        syncConn = RunService.Heartbeat:Connect(function()
            if not hrp or not hrp.Parent then syncConn:Disconnect(); return end
            syncFrames = syncFrames - 1
            hrp.CFrame = CFrame.new(destPos, destPos + facingDir)
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            if syncFrames <= 0 then syncConn:Disconnect() end
        end)

        for _ = 1, 20 do
            task.wait(0.05)
            if hum.FloorMaterial ~= Enum.Material.Air then break end
        end

        healConn:Disconnect()
        -- LANDING RE-ARM -- but do not resurrect a pet that is gone.
        --
        -- The sky flight disarms on launch and re-arms here with the pet chosen
        -- before take-off. If the plot changed mid-flight -- someone else stole
        -- it, the base emptied -- the Heartbeat above has already retargeted, and
        -- blindly re-arming the stale `pet` would throw that away and park the
        -- steal engine on a podium with nothing on it.
        --
        -- So: keep whatever the live retarget decided, and only fall back to the
        -- pre-flight pick when nothing replaced it.
        local _live = _stealTarget
        if _live and not _samePet(_live, pet) then
            -- a plot change during the flight already moved us on
        else
            armSteal(pet)
        end
        _cloneFired = true

        local _ahrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        local _clonePos = (_ahrp and _ahrp.Parent and _ahrp.Position) or destPos

        local _clonePlat = Instance.new("Part")
        _clonePlat.Name = "Skyr0ClonePlatform"
        _clonePlat.Size = Vector3.new(12, 1, 12)
        _clonePlat.Position = Vector3.new(_clonePos.X, _clonePos.Y - 3, _clonePos.Z)
        _clonePlat.Anchored = true; _clonePlat.CanCollide = false; pcall(makeOneWay, _clonePlat); _clonePlat.Transparency = 1
        _clonePlat.Material = Enum.Material.SmoothPlastic; _clonePlat.Parent = workspace

        -- ============================================================
        -- sxe.txt CLONE -- push through the wall, then clone WITH RETRIES.
        --
        -- The sky-pad clone fires once from where you land and trusts it took.
        -- The old one pushes the root 2.5 studs FORWARD first (facingDir points
        -- into the base, set when we landed), waits out the clone delay, checks
        -- the server did not shove us back out, then clones -- up to 3 attempts,
        -- re-seating the CFrame between them. The retry is the whole point: a
        -- clone that does not take is detected, because the character never
        -- moves, and fired again -- instead of the TP carrying on as though it
        -- had worked.
        --
        -- The root is deliberately NOT anchored. Anchoring pins it, so the push
        -- cannot land and the movement check can never see the clone take --
        -- which is why this stopped behaving like the old one. Velocity is
        -- zeroed instead, the same way sxe.txt holds position.
        -- ============================================================
        if _ahrp and _ahrp.Parent then
            _ahrp.AssemblyLinearVelocity = Vector3.zero
            _ahrp.AssemblyAngularVelocity = Vector3.zero
            pcall(function() _ahrp.Anchored = true end)
            task.delay(1, function()
                if _ahrp and _ahrp.Parent then
                    pcall(function() _ahrp.Anchored = false end)
                end
            end)
        end

        -- Catch the character rebuild explicitly: on some clone paths the
        -- character is replaced rather than moved, and then the old root never
        -- reports any movement at all.
        local _charAdded = false
        local _caConn = LP.CharacterAdded:Connect(function() _charAdded = true end)

        task.wait(_cloneDelay)

    local _cloneOk = doClone()

        if _clonePlat then pcall(function() _clonePlat:Destroy() end); _clonePlat = nil end
        if _cloneOk then
            task.wait(0.3)
            local _cloneSucceeded = false
            do
                -- The swap loop can break on CharacterAdded before the new root
                -- has replicated; without this the proximity test reads a nil
                -- root and reports a perfectly good clone as failed.
                local _c = LP.Character
                local _h = _c and _c:FindFirstChild("HumanoidRootPart")
                local plotsFolder = workspace:FindFirstChild("Plots")
                if _h and plotsFolder then
                    local _rad = (petPos.Y <= 8.9) and 26 or 25
                    local p = _h.Position
                    for _, plot in ipairs(plotsFolder:GetChildren()) do
                        pcall(function()
                            local pp = plot:GetPivot().Position
                            if math.abs(p.X - pp.X) < _rad and math.abs(p.Z - pp.Z) < _rad then
                                _cloneSucceeded = true
                            end
                        end)
                        if _cloneSucceeded then break end
                    end
                end
            end
            if _caConn then _caConn:Disconnect() end
            -- For F2-from-F1 pets, always call goToBrainrot even if the plot-pivot
            -- proximity check failed. goToBrainrot's anchored CFrame lerp will
            -- teleport the character to airPos = (petX, petY-8, petZ) regardless
            -- of where the clone landed, ensuring reliable placement under the pet.
            local _forceGo = _G.Skyr0IsF2FromF1 and _G.Skyr0IsF2FromF1(petPos.Y) or false
            if _cloneSucceeded or _forceGo then goToBrainrot(petPos) end
        else
            if _caConn then _caConn:Disconnect() end
        end
        _tpAnchor = nil   -- back on the ground: "nearest" measures from the HRP again
        isTeleporting = false
    end

    doGrabbleVelocityTP = doVelocityTP
    _G.Skyr0StartSideTP = doVelocityTP
    -- Stashed on _G so the dispatcher at the very bottom of the file can point
    -- back at THIS function. doVelocityTP is a local inside this do-block, and
    -- the tail used to overwrite both names above with the V1 engine -- so this
    -- teleport, the one that matches hub_Mata, never actually ran.
    _G.Skyr0DoVelocityTP = doVelocityTP
    -- Escape hatch for _G.Skyr0TPReset. The V1 engine used to export this;
    -- with V1 gone the live engine has to, or a stuck isTeleporting can only
    -- be cleared by the 30s staleness check inside doVelocityTP.
    _G.Skyr0ForceIdleTP = function() isTeleporting = false end

    _G.Skyr0_ExecuteManualTP = function()
        task.spawn(function() pcall(doVelocityTP) end)
    end

    -- (hardcoded T-key handler removed -- it fired this hub's OLD doVelocityTP in PARALLEL with
    -- the "Manual TP" keybind's runAutoSnipe -> _fxTpDispatch -> V1, so two TP engines fought and
    -- the character spun. T is now handled ONLY by the "Manual TP" keybind, exactly like the upstream hub.)

    -- Boot
    task.spawn(function() pcall(loadModules) pcall(loadNet) end)
    task.spawn(function()
        local char = LP.Character or LP.CharacterAdded:Wait()
        char:WaitForChild("HumanoidRootPart", 10)
        char:WaitForChild("Humanoid", 10)
        pcall(loadModules); pcall(loadNet)
        local _t0 = os.clock()
        repeat
            local ok, pets = pcall(scanAllPets)
            if ok and pets and #pets > 0 then break end
            task.wait(0.3)
        until os.clock() - _t0 > 12
        _started = true
    end)
end

-- (The V1 teleport engine that used to sit here is GONE, along with the
--  _G.Skyr0_getNet / _G.Skyr0FireUseItem shims that existed only to feed it.
--  It was unreachable: _fxTpDispatch tries _G.Skyr0DoVelocityTP first and
--  that is always set, so the V1 branch never ran.)

-- Route this hub's TP through the upstream hub's V1 engine via a settings bridge (its _tpDispatch,
-- 1:1). This hub has the SAME Config keys, so this maps StealMode / PriorityList / manual
-- selection / speed onto the _G.* contract the V1 engine reads -- so the V1 TP flies to the
-- Highest/Priority/Nearest/manually-selected pet exactly like the upstream hub, not just allPets[1].
local function _fxTpDispatch()
    -- Steal lockout (see Skyr0IsStealing): every "just teleport" path funnels
    -- through here, so one check covers the keybind, the Actions button and the
    -- side-TP dispatcher alike.
    if _G.Skyr0IsStealing and _G.Skyr0IsStealing() then
        warn("[skyr0] TP blocked: you are stealing.")
        return false
    end
    _G.TPVelocity        = math.max(tonumber(Config.TpSettings.GrabbleTPSpeed) or 400, 400)
    _G.TPCloneDelay      = tonumber(Config.TpSettings.CloneDelayVal) or 0.1
    _G.LandingDelay      = _G.LandingDelay or 0.4
    _G.MeerkoStealMode   = (tostring(Config.StealMode or "")):lower()
    _G.Skyr0StealTargetUID = manuallySelectedUID and ((tostring(manuallySelectedUID):gsub("_", "|"))) or nil
    -- Always re-point at the LIVE priority list so UI reorders/adds/removes take effect on
    -- the very next TP (the old `x = x or Config.PriorityList` latched the first value and
    -- ignored later reorders, so TP would not follow the freshly-sorted list).
    _G.SHARED_PRIORITY_ITEMS = Config.PriorityList or _G.SHARED_PRIORITY_ITEMS
    _G.Skyr0TPCancel = false
    -- One engine, one branch. doVelocityTP, exported as _G.Skyr0DoVelocityTP:
    -- its velMoveThrough is the USETHISTP mover (SPEED 200, ARRIVE 3, quickStart
    -- hop, 18-frame stall detector, CFrame settle in finish()).
    if _G.Skyr0DoVelocityTP then return _G.Skyr0DoVelocityTP() end
    warn("[skyr0] TP engine missing -- did the engine block fail to load?")
end
_G.Skyr0StartSideTP      = _fxTpDispatch
doGrabbleVelocityTP    = _fxTpDispatch
_G.Skyr0_ExecuteManualTP = function() task.spawn(function() pcall(_fxTpDispatch) end) end

-- =====================================================================
-- THE ONE MANUAL TP
-- ---------------------------------------------------------------------
-- Every "just teleport now" caller goes through here: the Manual TP keybind,
-- the Actions button, and TP-on-load.
--
-- They used to disagree. The keybind ran the dispatcher above, while
-- TP-on-load ran runAutoSnipe behind a getTargetPetData()/findAdorneeGlobal()
-- gate -- a different target picker AND a precondition the engine does not
-- need, since it polls for pets itself. So the two could pick different pets,
-- and on a slow join TP-on-load simply never fired.
--
-- One entry point means "TP on load" is now, by definition, the same thing as
-- pressing the Manual TP key.
-- =====================================================================
_G.Skyr0ManualTP = function()
    _G.Skyr0TPCancel = false
    -- THROUGH THE GRAPPLE CYCLE, same as TP-on-load and the Grapple TP key.
    --
    -- This called _fxTpDispatch directly, which goes straight to the teleport.
    -- The cycle is what fires the hook, turns you to face the plot and lets the
    -- pull drag you before the flight starts -- so Manual TP had no hook and no
    -- drag at all, it just started teleporting. TP-on-load looked completely
    -- different for that one reason.
    --
    -- 25 is the wait-for-a-target ceiling; it exits the moment one exists.
    -- The cycle hands off to _fxTpDispatch itself once the hook is away.
    if _G.Skyr0LaunchTP then _G.Skyr0LaunchTP(); return end
    task.spawn(function()
        local ok, err = pcall(_fxTpDispatch)
        if not ok then warn("[skyr0] Manual TP error:", err) end
    end)
end


-- =====================================================================
-- INSTA RESET
-- ---------------------------------------------------------------------
-- Kill and respawn, with no waiting on the normal death path.
--
-- HipHeight 1e30 launches the humanoid clean out of the world, so the server
-- takes it as a void death and respawns immediately instead of playing out an
-- ordinary death on RespawnTime. Health 0 is the backstop for when the launch
-- gets caught.
--
-- Two ordering rules this depends on, both learned the hard way:
--   * NEVER kill on the same frame as the launch. HipHeight moves you through
--     the humanoid state machine, and that stops the instant the humanoid
--     dies -- kill too early and you simply drop where you stood.
--   * A seated / platform-stood / anchored character cannot be moved at all,
--     so it is freed first and the unlock is REAPPLIED every frame. Writing
--     any of this once only works when the write happens to land on a frame
--     the game is not overwriting, which is what makes it fire intermittently.
--
-- No remote is resolved, stored or fired anywhere in here.
-- =====================================================================
do
    local FLING_TIME  = 0.4      -- how long to keep reapplying the launch
    local FLING_POWER = 50000
    local USE_VOID    = true     -- also drop below FallenPartsDestroyHeight
    local VOID_TIME   = 0.6
    local TIMEOUT     = 6
    local CAM_BIND    = "Skyr0InstaResetCam"
    local resetting   = false

    local function hideLocally(obj)
        if obj:IsA("BasePart") or obj:IsA("Decal") then
            obj.LocalTransparencyModifier = 1
        end
    end

    _G.Skyr0InstaReset = function()
        if resetting then return false end
        local LP = game:GetService("Players").LocalPlayer
        local char = LP and LP.Character
        -- Acting on a stale or already-dead character is another way this ends
        -- up working only some of the time: it burns the whole budget flinging
        -- a corpse while holding the lock, so the next real press is swallowed.
        if not char or not char.Parent then return false end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then return false end
        local hrp = hum.RootPart or char:FindFirstChild("HumanoidRootPart")
        resetting = true

        task.spawn(function()
            local RSv = game:GetService("RunService")

            -- Hold the camera where it is until the new character loads: the
            -- death cam swinging away is most of what makes a reset FEEL slow.
            local cam = workspace.CurrentCamera
            local frozen = cam and cam.CFrame
            local oldType = cam and cam.CameraType
            pcall(function()
                cam.CameraType = Enum.CameraType.Scriptable
                RSv:BindToRenderStep(CAM_BIND, Enum.RenderPriority.Camera.Value + 1, function()
                    cam.CFrame = frozen
                end)
            end)

            -- Drop the body out of view on this client only.
            local added
            pcall(function()
                for _, obj in ipairs(char:GetDescendants()) do pcall(hideLocally, obj) end
                added = char.DescendantAdded:Connect(function(obj) pcall(hideLocally, obj) end)
            end)

            -- Listen before killing -- the respawn can land before the next line.
            local newChar
            local respawned = LP.CharacterAdded:Connect(function(c) newChar = c end)

            local function unlock()
                pcall(function() hum.PlatformStand = false end)
                pcall(function() hum.Sit = false end)
                pcall(function() hum.AutoRotate = true end)
            end
            unlock()
            for _, obj in ipairs(char:GetDescendants()) do
                if obj:IsA("BasePart") then
                    pcall(function() obj.Anchored = false end)
                    pcall(function() obj.CanCollide = false end)
                elseif obj.Name == "SeatWeld" then
                    pcall(function() obj:Destroy() end)
                end
            end

            local started = os.clock()
            local function aliveHRP()
                if hrp and hrp.Parent then return hrp end
                hrp = hum.RootPart or char:FindFirstChild("HumanoidRootPart")
                if hrp and hrp.Parent then return hrp end
                return nil
            end

            -- The launch, HELD. Velocity flings regardless of humanoid state,
            -- HipHeight needs the state machine -- both go in, neither kills.
            local flingUntil = os.clock() + FLING_TIME
            while not newChar and os.clock() < flingUntil and hum.Parent do
                unlock()
                pcall(function() hum.HipHeight = 1e30 end)
                local root = aliveHRP()
                if root then
                    pcall(function() root.Anchored = false end)
                    pcall(function() root.AssemblyLinearVelocity = Vector3.new(0, FLING_POWER, 0) end)
                    pcall(function() root.Velocity = Vector3.new(0, FLING_POWER, 0) end)
                end
                RSv.Heartbeat:Wait()
            end

            -- Out of the world, also held: one teleport gets reverted by a
            -- position check, a teleport every frame outruns it.
            if USE_VOID and not newChar then
                local floor = -500
                pcall(function() floor = workspace.FallenPartsDestroyHeight end)
                local voidUntil = os.clock() + VOID_TIME
                while not newChar and os.clock() < voidUntil do
                    local root = aliveHRP()
                    if not root then break end
                    pcall(function() root.CFrame = CFrame.new(0, floor - 500, 0) end)
                    pcall(function() root.AssemblyLinearVelocity = Vector3.new(0, -FLING_POWER, 0) end)
                    RSv.Heartbeat:Wait()
                end
            end

            -- Backstop: keep killing until the respawn actually lands.
            while not newChar and os.clock() - started < TIMEOUT do
                if hum.Parent then
                    pcall(function() hum.Health = 0 end)
                    pcall(function() hum:ChangeState(Enum.HumanoidStateType.Dead) end)
                end
                if char.Parent then pcall(function() char:BreakJoints() end) end
                task.wait(0.1)
            end

            pcall(function() respawned:Disconnect() end)
            if added then pcall(function() added:Disconnect() end) end
            pcall(function() RSv:UnbindFromRenderStep(CAM_BIND) end)
            pcall(function()
                cam.CameraType = (oldType == Enum.CameraType.Scriptable)
                    and Enum.CameraType.Custom or oldType
                if newChar then
                    local newHum = newChar:FindFirstChildOfClass("Humanoid")
                        or newChar:WaitForChild("Humanoid", 5)
                    if newHum then cam.CameraSubject = newHum end
                end
            end)
            resetting = false
        end)
        return true
    end
end
