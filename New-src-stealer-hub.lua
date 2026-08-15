local t1, v1, v2, f1, v3, v4, v5, f2
local v6, v7, f3, f4, v8, f5, f6, v9
local v10, f7, f8, v11, f9, t2, v12, f10
local v13, v14, v15, f11, f12, t3, v16, v17
local f13, f14, f15, f16, v18, f17, v19, f18
local t4, v20, f19, f20, v21, v22, f21, t5
local v23, v24, f22, v25, v26, f23, f24, f25
local v27, v28, v29, v30
while true do
	local _continue67 = false
	task.wait()
	if game:IsLoaded() then
		if getgenv().SxeAuth then
			print("[SxeAuth] Script already ran!")
			return
		end
		getgenv().SxeAuth = true
		if not Key then
			return (game:GetService("Players").LocalPlayer:Kick("[SxeAuth] Script Key Not Set."))
		end
		if type(Key) ~= "string" then
			return (game:GetService("Players").LocalPlayer:Kick("[SxeAuth] Incorrect Key format."))
		end
		if typeof(Key) ~= "string" then
			return (game:GetService("Players").LocalPlayer:Kick("[SxeAuth] Incorrect Key format."))
		end
		if #Key ~= 16 then
			return (game:GetService("Players").LocalPlayer:Kick("[SxeAuth] Incorrect Key format."))
		end
		local LocalizationService = game:GetService("LocalizationService")
		local t6 = { US = true, CA = true, MX = true }
		local v31 = LocalizationService
		local v32 = t6
		local Key2 = Key
		v1 = false
		v2 = "N/A"
		local v33 = tick()
		local GetClientId = game:GetService("RbxAnalyticsService"):GetClientId()
		local v34 = gethwid() .. "-" .. GetClientId
		f1 = nil
		v3 = nil
		local v35, v36
		local v37 = identifyexecutor()
		getgenv().SxeAuthLoaded = false
		local find = string.find
		local byte = string.byte
		local request2 = http.request
		local f26 = nil

		local function f27()
			local function f28(...)
				while true do
					if (nil)() then
						(nil)()
					end
				end
			end

			f28()
			while true do
			end
		end

		local function f29()
			local game2 = game
			local f30 = game2.GetService
			while true do
				f30 = f30(game2, "Players")
			end
		end

		local function f31(p1)
			if type(p1) ~= "number" then
				return (print("Input is not a number."))
			end
			if 0 <= p1 then
				return p1 - p1 % 1
			end
			if p1 % 1 == 0 then
				return p1
			end
			return p1 - p1 % 1 - 1
		end

		local v38 = byte

		local function f32(p1, p2)
			if type(p1) ~= type(p2) then
				return false
			end
			local v1
			if type(p1) ~= "string" then
				v1 = p1 == p2
				return v1
			end
			if #p1 ~= #p2 then
				return false
			end
			local v2 = 0
			for v3 = 1, #p1 do
				local _ = bit32.bor
				bit32.bxor(v38(p1, v3), v38(p2, v3))
				v2 = bit32.bor()
			end
			local v4
			v4 = v2 == 0
			return v4
		end

		local function f33(p1)
			local v1 = 0
			for v2 = 1, #p1 do
				v1 = (v1 + string.byte(p1, v2) * v2) % 1000000
			end
			return v1
		end

		local function f34(...)
			local v1 = nil
			if not 48 then
				v1 = 0
			end
			return v1
		end

		local function f35(p1)
			return (bit32.band(p1, 4294967295))
		end

		local v39 = f31
		local v40 = f35

		local function f36(...)
			local f37, v1
			if false then
				v1 = f37(nil)
				f37 = bit32
				return (v40(f37.bxor(v1, 2779096485) + 1831565813))
			end
			repeat
				local v2 = ...
			until -2 < v2 and v2 < 2
			return nil
		end

		local v41 = f31

		local function f38(...)
			while true do
				local v1 = ...
				if v1 == nil then
					error()
					if -2 < v1 and v1 < 2 then
						return nil
					end
				end
			end
		end

		local function f39()
			local function f40()
			end
			return (("%*"):format(f40))
		end

		local t7 = {}
		v4 = nil
		local t8 = {
			["\\"] = "\\",
			["\""] = "\"",
			["\8"] = "b",
			["\12"] = "f",
			["\n"] = "n",
			["\r"] = "r",
			["\t"] = "t"
		}
		local t9 = { ["/"] = "/" }
		pairs(t1)
		local v42 = t8

		local function f41(...)
			repeat
				local v1 = ...
			until not v42[v1]
			while true do
			end
		end

		t1 = function()
			return "null"
		end

		local function f42(p1, p2)
			local t1 = {}
			if not p2 then
				p2 = {}
			end
			if p2[p1] then
				error("circular reference")
			end
			p2[p1] = true
			if rawget(p1, 1) == nil and next(p1) ~= nil then
				for v1, v2 in pairs(p1) do
					if type(v1) ~= "string" then
						error("invalid table: mixed or invalid key types")
					end
					table.insert(t1, v4(v1, p2) .. ":" .. v4(v2, p2))
				end
				p2[p1] = nil
				return "{" .. table.concat(t1, ",") .. "}"
			end
			local v3 = 0
			for v4, _ in pairs(p1) do
				if type(v4) ~= "number" then
					error("invalid table: mixed or invalid key types")
				end
				v3 = v3 + 1
			end
			if v3 ~= #p1 then
				error("invalid table: sparse array")
			end
			for _, v5 in ipairs(p1) do
				table.insert(t1, v4(v5, p2))
			end
			p2[p1] = nil
			return "[" .. table.concat(t1, ",") .. "]"
		end

		local v43 = f41

		local function f43(p1)
			return "\"" .. p1:gsub("[%z\1-\31\\\"]", v43) .. "\""
		end

		local function f44(p1)
			if not (p1 == p1 and not (p1 <= -math.huge) and not (math.huge <= p1)) then
				error("unexpected number value '" .. tostring(p1) .. "'")
			end
			return (string.format("%.14g", p1))
		end

		local t10 = { ["nil"] = t1, table = f42, string = f43, number = f44 }
		v5 = tostring
		t10.boolean = v5
		local v44 = t10

		v4 = function(p1, p2)
			local f45 = type
			local f46 = p1
			repeat
				f45 = f45(f46)
				f46 = v44[f45]
			until f46
			return (f46(p1, p2))
		end

		v5 = "encode"

		local function f47(p1)
			return (v4(p1))
		end

		t7[v5] = f47
		v5 = nil

		local function f48(...)
			select(...)
			return {}
		end

		local v45 = f48(" ", "\t", "\r", "\n")
		local v46 = f48(" ", "\t", "\r", "\n", "]", "}", ",")
		local v47 = f48("\\", "/", "\"", "b", "f", "n", "r", "t", "u")
		local v48 = f48("true", "false", "null")
		local t11 = { ["true"] = true, ["false"] = false, null = nil }

		local function f49(...)
			return nil
		end

		local function f50(p1, _, _)
			local v1 = 1
			local v2 = 1
			while true do
				v2 = v2 + 1
				if p1:sub(nil, nil) == "\n" then
					v1 = v1 + 1
					v2 = 1
				end
			end
		end

		local function f51(p1)
			local _ = math.floor
			if p1 <= 127 then
				return (string.char(p1))
			end
			if p1 <= 2047 then
				return (string.char(math.floor(p1 / 64) + 192, p1 % 64 + 128))
			end
			if p1 <= 65535 then
				return (string.char(
					math.floor(p1 / 4096) + 224,
					math.floor(p1 % 4096 / 64) + 128,
					p1 % 64 + 128
				))
			end
			if p1 <= 1114111 then
				return (string.char(
					math.floor(p1 / 262144) + 240,
					math.floor(p1 % 262144 / 4096) + 128,
					math.floor(p1 % 4096 / 64) + 128,
					p1 % 64 + 128
				))
			end
			error(string.format("invalid unicode codepoint '%x'", p1))
		end

		local v49 = f51

		local function f52(...)
			local v1, v2
			repeat
				local v3 = ...
				v2 = tonumber(v3:sub(1, 4), 16)
				v1 = tonumber(v3:sub(7, 10), 16)
			until v1
			return (v49((v2 - 55296) * 1024 + (v1 - 56320) + 65536))
		end

		local v50 = f50
		local v51 = f52
		local v52 = v47
		local v53 = t9

		local function f53(p1, p2)
			local v1 = nil
			local v2 = ""
			local v3 = p2 + 1
			local v4 = v3
			while v4 <= #p1 do
				local byte2 = p1:byte(v4)
				if byte2 < 32 then
					v50(p1, v4, "control character in string")
					v1 = p1
				elseif byte2 == 92 then
					local v5 = v2 .. p1:sub(v3, v4 - 1)
					v4 = v4 + 1
					local sub = p1:sub(v4, v4)
					if sub == "u" then
						v1 = p1:match("^[dD][89aAbB]%x%x\\u%x%x%x%x", v4 + 1)
						if not v1 then
							v1 = p1:match("^%x%x%x%x", v4 + 1)
						end
						if not v1 then
							v1 = v50(p1, v4 - 1, "invalid unicode escape in string")
						end
						v2 = v5 .. v51(v1)
						v4 = v4 + #v1
					else
						if not v52[sub] then
							v50(p1, v4 - 1, "invalid escape char '" .. sub .. "' in string")
						end
						v1 = v53[sub]
						v2 = v5 .. v1
					end
					v3 = v4 + 1
				else
					if byte2 == 34 then
						return v2 .. p1:sub(v3, v4 - 1), v4 + 1
					end
					v1 = v4
				end
				v4 = v4 + 1
			end
			v50(p1, p2, v1)
		end

		local v54 = f49
		local v55 = v46
		local v56 = f50

		local function f54(...)
			local v1, v2, v3, v4, v5
			repeat
				v5, v4 = ...
				v3 = v54(v5, v4, v55)
				v2 = v5:sub(v4, v3 - 1)
				v1 = tonumber(v2)
			until not v1
			v56(v5, v4, "invalid number '" .. v2 .. "'")
			return v1, v3
		end

		local v57 = f49
		local v58 = v46
		local v59 = v48
		local v60 = f50
		local v61 = t11

		local function f55(...)
			while true do
			end
			v60(nil, nil, "invalid literal '" .. nil .. "'")
			return v61[nil], nil
		end

		local v62 = f49
		local v63 = v45
		local v64 = f50

		local function f56(p1, p2)
			local t1 = {}
			local v1 = 1
			local v2 = p2 + 1
			local _leave2 = false
			local v3
			while true do
				v3 = v62(p1, v2, v63, true)
				if p1:sub(v3, v3) == "]" then
					break
				end
				local v4, v5
				v5, v4 = v5(p1, v3)
				t1[v1] = v5
				v1 = v1 + 1
				local v6 = v62(p1, v4, v63, true)
				local sub2 = p1:sub(v6, v6)
				v2 = v6 + 1
				if sub2 == "]" then
					_leave2 = true
					break
				end
				if sub2 ~= "," then
					v64(p1, v2, "expected ']' or ','")
				end
			end
			if not _leave2 then
				v2 = v3 + 1
			end
			return t1, v2
		end

		local v65 = f49
		local v66 = v45
		local v67 = f50

		local function f57(p1, p2)
			local t1 = {}
			local v1 = p2 + 1
			local _leave3 = false
			local v2, v3
			while true do
				v3 = v65(p1, v1, v66, true)
				if p1:sub(v3, v3) == "}" then
					break
				end
				if p1:sub(v3, v3) ~= "\"" then
					v67(p1, v3, "expected string for key")
				end
				local v4, v5
				v5, v4 = v5(p1, v3)
				local v6 = v65(p1, v4, v66, true)
				if p1:sub(v6, v6) == ":" then
					v2 = v6
				else
					v2 = "expected ':' after key"
					v67(p1, v6, v2)
				end
				local v7, v8
				v8, v7 = v5(p1, (v65(p1, v6 + 1, v2, true)))
				t1[v5] = v8
				local v9 = v65(p1, v7, v66, true)
				local sub3 = p1:sub(v9, v9)
				v1 = v9 + 1
				if sub3 == "}" then
					_leave3 = true
					break
				end
				if sub3 ~= "," then
					v67(p1, v1, "expected '}' or ','")
				end
			end
			if not _leave3 then
				v1 = v3 + 1
			end
			return t1, v1
		end

		local t12 = {
			["\""] = f53,
			["0"] = f54,
			["1"] = f54,
			["2"] = f54,
			["3"] = f54,
			["4"] = f54,
			["5"] = f54,
			["6"] = f54,
			["7"] = f54,
			["8"] = f54,
			["9"] = f54,
			["-"] = f54,
			t = f55,
			f = f55,
			n = f55,
			["["] = f56,
			["{"] = f57
		}
		local v68 = t12
		local v69 = f50

		v5 = function(p1, p2)
			local sub4 = p1:sub(p2, p2)
			local f58 = v68[sub4]
			if f58 then
				return (f58(p1, p2))
			end
			v69(p1, p2, "unexpected character '" .. sub4 .. "'")
		end

		f2 = "decode"
		local v70 = f49
		local v71 = v45
		local v72 = f50

		local function f59(p1)
			if type(p1) ~= "string" then
				error("expected argument of type string, got " .. type(p1))
			end
			local v1, v2
			v2, v1 = v5(p1, v70(p1, 1, v71, true))
			local v3 = v70(p1, v1, v71, true)
			if v3 <= #p1 then
				v72(p1, v3, "trailing garbage")
			end
			return v2
		end

		t7[f2] = f59
		local v73 = Key2
		local v74 = t7
		local v75 = v37
		local v76 = f29

		f2 = function(p1, p2)
			if p2 then
				local request3 = request
				if not request3 then
					request3 = http.request
				end
				f1 = request3
			end
			local gsub = p1:gsub("\0", "")
			local f60 = f1
			local t1 = { Url = "https://sxehub.com" .. "/blacklist?Key=" .. v73, Method = "POST" }
			local encode = v74.encode
			local t2 = { Key = v73, ServerNonce = v3 }
			t1.Body = encode(t2)
			local t3 = {
				["Content-Type"] = "application/json",
				["x-Executor"] = v75,
				["x-Reason"] = gsub
			}
			t1.Headers = t3
			f60(t1)
			task.wait(1)
			v76("Blacklisted - 2")
		end

		local function f61(p1, p2)
			local t1 = {}
			if p1 == nil then
				return t1
			end
			t1[p1] = p2
			return t1
		end

		local function f62(p1)
			return p1
		end

		if string.len(Key2) ~= 16 then
			v1 = true
			v2 = "\0Key length wrong"
		end
		loadstring("return function() end")()
		local v77 = 6
		if game:GetService("RunService"):IsStudio() then
			return (f27())
		end
		loadstring("-- Hello pentester <3")()
		local v78, v79
		v79, v78 = pcall(isfunctionhooked)
		if v79 == true then
			v1 = true
			v2 = "\0Ishooked error dtc type 1"
		end
		if v78 ~= "missing argument #1 to 'isfunctionhooked' (function expected)" then
			v1 = true
			v2 = "\0Ishooked error dtc type 2"
		end
		local v80, v81
		v81, v80 = pcall(clonefunction)
		if v81 == true then
			v1 = true
			v2 = "\0Clonefunction error dtc type 1"
		end
		if v80 ~= "missing argument #1 to 'clonefunction' (function expected)" then
			v1 = true
			v2 = "\0Clonefunction error dtc type 2"
		end
		local v82, v83
		v83, v82 = pcall(restorefunction)
		if v83 == true then
			v1 = true
			v2 = "\0Clonefunction error dtc type 1"
		end
		if v82 ~= "missing argument #1 to 'restorefunction' (function expected)" then
			v1 = true
			v2 = "\0Clonefunction error dtc type 2"
		end
		getgenv()

		local function f63(p1)
			if isfunctionhooked(p1) then
				return true
			end
			local v1 = clonefunction(p1)
			hookfunction(p1, v1)
			if not isfunctionhooked(p1) then
				return true
			end
			restorefunction(p1)
			if isfunctionhooked(p1) then
				return true
			end
			return false
		end

		getgenv()
		local v84 = _G["table.create"](14)
		local v85 = nil
		f24 = v84
		while true do
			local v86
			v85, v86 = f24(nil, v85)
			if v85 == nil then
				break
			end
			if f63(v86) then
				v1 = true
				v2 = "\0Function hooking type " .. v85
			end
		end

		local function f64()
			while true do
			end
		end

		local v87, v88
		v88, v87 = pcall(f64)
		if v88 ~= true then
			v1 = true
			v2 = "\0Pcall error dtc type -2"
		end
		if v87 ~= nil then
			v1 = true
		end
		while true do
			local _continue68 = false
			local t13 = {}

			local function f65()
				return "\0", 25, true
			end

			t13[1] = (pcall(f65)) -- multiple values truncated
			if not (t13[1] == true and t13[2] == "\0" and (t13[3] == 25 and t13[4] == true)) then
				v1 = true
				v2 = "\0Pcall error dtc type 0"
			end
			local v89, v90
			v90, v89 = pcall(pcall)
			if v90 == true then
				v1 = true
				v2 = "\0Pcall error dtc type 1"
			end
			if v89 ~= "missing argument #1" then
				v1 = true
				v2 = "\0Pcall error dtc type 2"
			end
			local v91, v92
			v92, v91 = pcall(pcall(pcall))
			if v92 == true then
				v1 = true
				v2 = "\0Pcall error dtc type 3"
			end
			if v91 ~= "attempt to call a boolean value" then
				v1 = true
				v2 = "\0Pcall error dtc type 4"
			end
			local v93 = nil
			f25 = v84
			while true do
				local v94
				v93, v94 = f25(nil, v93)
				if v93 == nil then
					break
				end
				local v95, v96
				v96, v95 = pcall(f62(v94))
				if v95 == "C stack overflow" then
					if v96 ~= false then
						v1 = true
						v2 = "\0C stack overflow dtc type 1." .. v93
					end
					v1 = true
					v2 = "\0C stack overflow dtc type " .. v93
				end
			end
			if v37 == "Delta" then
				f1 = request
			else
				local v97 = find
				local v98 = v37
				local v99 = request2

				f1 = function(p1)
					if v2 ~= "N/A" then
						v1 = true
					end
					local t1 = { "Url", "Method", "Body", "Headers", "Cookies" }
					local v1, v2, v3
					if v97(v98, "Potassium") then
						local t2 = { "Url", "Method", "Headers", "Cookies", "Body" }
						v3 = 0
						v2 = p1
						v1 = t2
					elseif v97(v98, "Delta") then
						local t3 = { "Url", "method", "Method", "Cookies", "Headers", "Body" }
						v3 = 0
						v2 = p1
						v1 = t3
					elseif v97(v98, "Vega-X") then
						local t4 = { "Url", "Method", "Body", "Headers", "Cookies" }
						v3 = 0
						v2 = p1
						v1 = t4
					elseif v97(v98, "Wave") then
						local t5 = { "Url", "Method", "Body", "Headers", "Cookies" }
						v3 = 0
						v2 = p1
						v1 = t5
					elseif v97(v98, "Volcano") then
						local t6 = { "Url", "Method", "Headers", "Cookies", "Body" }
						v3 = 0
						v2 = p1
						v1 = t6
					elseif v97(v98, "Volt") then
						local t7 = { "Url", "Method", "Headers", "Body" }
						v3 = 0
						v2 = p1
						v1 = t7
					elseif v97(v98, "Real") then
						local t8 = { "Url", "Method", "Headers", "Cookies", "Body" }
						v3 = 0
						v2 = p1
						v1 = t8
					else
						v3 = 0
						v2 = p1
						v1 = t1
						if v97(v98, "Velocity") then
							local t9 = { "Url", "method", "Method", "Cookies", "Headers", "Body" }
							v3 = 0
							v2 = p1
							v1 = t9
						end
					end
					local _ = setmetatable
					local t10 = {}

					function t10.__index(_, p2)
						local func = getinfo(0).func
						v3 = v3 + 0 + 1
						if not func == v99 then
							v1 = true
							v2 = {}
							v2 = "\0Http spy one"
							f2(v2, true)
						end
						if #v1 < v3 then
							v1 = true
							v2 = {}
							v2 = "\0Http spy two"
							f2(v2, true)
						end
						if v1[v3] ~= p2 then
							v1 = true
							v2 = {}
							v2 = "\0Http spy three"
							f2(v2, true)
						end
						if coroutine.isyieldable() then
							v1 = true
							v2 = {}
							v2 = "\0Http spy four"
							f2(v2, true)
						end
						local t11 = debug.getinfo(0)
						local f66 = t11.numparams
						if not (f66 == 0 and t11.currentline == -1 and
							(t11.is_vararg == 1 and t11.what ~= "Lua")) then
							v1 = true
							v2 = {}
							v2 = "\0Http spy five"
							f66 = f2
							f66(v2, true)
						end
						return f66
					end

					function t10.__len()
						v1 = true
						v2 = {}
						v2 = "\0Http spy five"
						f2(v2, true)
						return 0
					end

					return (v99((setmetatable({}, t10))))
				end
			end
			local encode2 = t7.encode
			local t14 = { Key = Key2 }
			local v100 = encode2(t14)
			local t15 = {
				["Content-Type"] = "application/json",
				["x-Executor"] = v37,
				["x-Identifier"] = v34
			}
			local t16 = {
				Url = "https://sxehub.com" .. "/start?Key=" .. Key2,
				Method = "POST",
				method = "POST",
				Body = v100,
				Headers = t15
			}
			local t17 = f1(t16)
			if t17 then
				if t17.StatusCode == 0 then
					return (print("Server did not respond. - 0"))
				end
				if t17.StatusCode == 111 then
					return (f29("Blacklisted - 1"))
				end
				if t17.StatusCode == 403 then
					return (f29("Error:" .. t7.decode(t17.Body).Error))
				end
				if t17.StatusCode ~= 200 then
					return (print("[SxeAuth] Incorrect Key"))
				end
				local _leave65 = false
				local v101 = v77 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1
				if t17.Success then
					local t18 = t7.decode(t17.Body)
					v101 = v101 + 1
					if t18.Success then
						v101 = v101 + 1
						v3 = t18.Nonce
						if t17.Headers.date == nil then
							v35 = f33(t17.Headers.Date)
							v36 = t17.Headers["x-railway-request-id"] == nil and 100 or
								f33(t17.Headers["x-railway-request-id"])
						else
							f13 = function()
								local _G2 = _G
								local _ = math.max
								local v1 = tonumber(t2.TpSettings.GrabbleTPSpeed)
								if not v1 then
									v1 = 400
								end
								_G2.TPVelocity = math.max(v1, 400)
								local _G3 = _G
								local v2 = tonumber(t2.TpSettings.CloneDelayVal)
								if not v2 then
									v2 = 0.1
								end
								_G3.TPCloneDelay = v2
								local _G4 = _G
								local v3 = _G.LandingDelay
								if not v3 then
									v3 = 0.4
								end
								_G4.LandingDelay = v3
								local _G5 = _G
								local _ = tostring
								local v4 = t2.StealMode
								if not v4 then
									v4 = ""
								end
								_G5.MeerkoStealMode = tostring(v4):lower()
								local _G6 = _G
								local v5 = manuallySelectedUID
								v5 = v5 and tostring(manuallySelectedUID):gsub("_", "|") or nil
								_G6.SXEStealTargetUID = v5
								local _G7 = _G
								local v6 = t2.PriorityList
								if not v6 then
									v6 = _G.SHARED_PRIORITY_ITEMS
								end
								_G7.SHARED_PRIORITY_ITEMS = v6
								_G.SXETPCancel = false
								if _G.SXETPv1 then
									return (_G.SXETPv1())
								end
							end

							f14 = _G
							f14.SXEStartSideTP = f13
							doGrabbleVelocityTP = f13
							f14 = _G
							local v102 = f13

							f15 = function()
								local function f67()
									pcall(v102)
								end

								task.spawn(f67)
							end

							f14.SXE_ExecuteManualTP = f15
							_leave65 = true
						end
					else
						v1 = true
						v2 = "\0Response editing"
					end
				else
					v1 = true
					v2 = "\0Response editing type 2"
				end
				if not _leave65 then
					if v2 ~= "N/A" then
						return (f2(v2))
					end
					if v1 then
						return (f2(v2))
					end
					if math.random(1, 2) == math.random(3, 4) then
						return (f2("\0Math random spoofing 0"))
					end
					local v103 = f31(math.random() * 1500 + 500)
					getfenv()["nil"] = v103
					math.randomseed(68)
					local v104 = math.random()
					local v105 = math.random(1, 2)
					local v106 = math.random(500, 1500)
					if v104 ~= 0.935796038750838 then
						return (f2("\0Math random spoofing 1"))
					end
					if v105 ~= 1 then
						return (f2("\0Math random spoofing 2"))
					end
					if v106 ~= 866 then
						return (f2("\0Math random spoofing 3"))
					end
					local v107 = os.time()
					getfenv()[""] = v107
					if v107 < 1782666640 then
						v1 = true
						v2 = "\0Rng2 spoof detected"
						return (f2(v2))
					end
					local v108 = f31(os.clock()) + 100
					getfenv()[" "] = v108
					local v109 = f34(os.date()) + f31(gcinfo())
					local v110 = f31(tick())
					if v110 < 1784314010 then
						return (f2("\0Tick spoofing"))
					end
					local v111 = f31(time()) + 100
					local NextInteger = Random.new():NextInteger(500, 1999)
					if tostring({}) == tostring({}) then
						v1 = true
						v2 = "\0Rng8 spoof detected"
					end
					local v112 = f33(tostring({}))
					local function f68()
					end
					local v113 = f34(tostring(f68)) + f34(tostring(print))
					local v114 = v3
					local t19 = f61()
					t19["nil"] = v114
					getfenv()["    "] = v35
					local v115 = f34(f39())
					if v1 then
						return (f2(v2))
					end
					if getfenv()["nil"] ~= v103 then
						return (f2("\0Stack replay detected 1"))
					end
					if getfenv()[""] ~= v107 then
						return (f2("\0Stack replay detected 2"))
					end
					if getfenv()[" "] ~= v108 then
						return (f2("\0Stack replay detected 3"))
					end
					for v116 = 1, 50 do
						({})[{}] = v116
					end
					local v117 = v115 + Rng15 + f31(gcinfo())
					local f69 = f1
					local t20 = {
						Url = "https://sxehub.com" .. "/authenticate?Key=" .. Key2,
						Method = "POST",
						method = "POST"
					}
					local encode3 = t7.encode
					local t21 = {
						Key = Key2,
						Rng = f38(v103),
						Rng2 = f38(v107),
						Rng3 = f38(v108),
						Rng4 = f38(v109),
						Rng5 = f38(v110),
						Rng6 = f38(v111),
						Rng7 = f38(NextInteger),
						Rng8 = f38(v112),
						Rng9 = f38(v113),
						Rng10 = f38(v114),
						Rng11 = f38(v35),
						Rng12 = f38(v36),
						Rng13 = f38(v117)
					}
					t20.Body = encode3(t21)
					local t22 = {
						["Content-Type"] = "application/json",
						["x-Executor"] = v37,
						["x-Identifier"] = v34
					}
					t20.Headers = t22
					local t23 = f69(t20)
					if t23.StatusCode == 0 then
						return (print("Server did not respond."))
					end
					if not t23 then
						return (print("Server did not respond."))
					end
					if t17.StatusCode == 403 then
						return (f29("Error:" .. t7.decode(t17.Body).Error))
					end
					if f36(v107) == t7.decode(t23.Body).Transformed.Rng2 then
						f26 = function(p1)
							return print(p1), 2
						end
					end
					if f32(200, 200) ~= true then
						while true do
						end
					end
					if f32(t23.StatusCode, 200) then
						if t23.Success then
							local t24 = t7.decode(t23.Body)
							if f32(t24.Success, true) then
								local Transformed = t24.Transformed
								if f36(v103) ~= Transformed.Rng then
									v2 = "\0Rng incorrect 1"
									f2(v2)
									return
								end
								if not f32(f36(v107), Transformed.Rng2) then
									v2 = "\0Rng incorrect 2"
									f2(v2)
									return
								end
								if not f32(f36(v108), Transformed.Rng3) then
									v2 = "\0Rng incorrect 3"
									f2(v2)
									return
								end
								if not f32(f36(v109), Transformed.Rng4) then
									v2 = "\0Rng incorrect 4"
									f2(v2)
									return
								end
								if not f32(f36(v110), Transformed.Rng5) then
									v2 = "\0Rng incorrect 5"
									f2(v2)
									return
								end
								if not f32(f36(v111), Transformed.Rng6) then
									v2 = "\0Rng incorrect 6"
									f2(v2)
									return
								end
								if not f32(f36(NextInteger), Transformed.Rng7) then
									v2 = "\0Rng incorrect 7"
									f2(v2)
									return
								end
								if not f32(f36(v112), Transformed.Rng8) then
									v2 = "\0Rng incorrect 8"
									f2(v2)
									return
								end
								if f36(v113) ~= Transformed.Rng9 then
									v2 = "\0Rng incorrect 9"
									f2(v2)
									return
								end
								if not f32(f36(v114), Transformed.Rng10) then
									v2 = "\0Rng incorrect 10"
									f2(v2)
									return
								end
								if f36(v35) ~= Transformed.Rng11 then
									v2 = "\0Rng incorrect 11"
									f2(v2)
									return
								end
								if f36(v36) ~= Transformed.Rng12 then
									v2 = "\0Rng incorrect 12"
									f2(v2)
									return
								end
								v77 = v101 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1
								if not f32(f36(v117), Transformed.Rng13) then
									v2 = "\0Rng incorrect 13"
									f2(v2)
									return
								end
								if t19["nil"] ~= v114 then
									return (f2("\0Stack replay detected 4"))
								end
								if getfenv()["    "] ~= v35 then
									return (f2("\0Stack replay detected 5"))
								end
								if v77 ~= 34 then
									return
								end
								getgenv().SxeAuthLoaded = true
								local v118, _
								_, v118 = f26("[SxeAuth] Successfully authenticated in ~ " .. tick() - v33)
								if v118 ~= 2 then
									while true do
									end
								end
								f2 = nil
								local game3 = game
								v6 = game3
								if not game3.IsLoaded(v6) then
									local Loaded = game.Loaded
									v6 = Loaded
									Loaded.Wait(v6)
								end
								local game4 = game
								v6 = game4
								local t25 = game4.GetService(v6, "Players")
								v6 = t25.LocalPlayer
								while not v6 do
									task.wait()
									v6 = t25.LocalPlayer
								end
								local game5 = game
								v7 = game5
								UIS = game5.GetService(v7, "UserInputService")
								local game6 = game
								v7 = game6
								RunService = game6.GetService(v7, "RunService")
								local game7 = game
								v7 = game7
								Stats = game7.GetService(v7, "Stats")
								local game8 = game
								v7 = game8
								TweenService = game8.GetService(v7, "TweenService")
								local game9 = game
								v7 = game9
								HttpService = game9.GetService(v7, "HttpService")
								local game10 = game
								v7 = game10
								ReplicatedStorage = game10.GetService(v7, "ReplicatedStorage")
								local game11 = game
								v7 = game11
								Workspace = game11.GetService(v7, "Workspace")
								local game12 = game
								v7 = game12
								Lighting = game12.GetService(v7, "Lighting")
								local game13 = game
								v7 = game13
								TeleportService = game13.GetService(v7, "TeleportService")
								local game14 = game
								v7 = game14
								CoreGui = game14.GetService(v7, "CoreGui")
								local game15 = game
								v7 = game15
								VirtualInputManager = game15.GetService(v7, "VirtualInputManager")
								local game16 = game
								v7 = game16
								local v119 = game16.GetService(v7, "ReplicatedStorage")
								v7 = nil
								local v120 = v119

								local function f70()
									if v7 and v7.Parent then
										return v7
									end
									local v1 = v120:FindFirstChild("Controllers")
									if v1 then
										v1 = v1:FindFirstChild("PlotController")
									end
									v7 = v1
									return v7
								end

								f3 = nil
								v8 = nil
								local v121 = _G["table.create"](2)
								f5 = "\tsetfenv(0, __renv)"
								f6 = "\tlocal function l%d(...) return __func(...) end"
								v9 = f6
								f6 = f6.format
								v10 = 2
								f5 = 1
								f6 = -1
								local v122 = 1 - f6
								f6(v9, v10)
								while true do
									v122 = v122 + f6
									if not (f5 <= v122) then
										break
									end
									v9 = v122
									v10 = #v121
									v10 = v10 + 1
									local t26 = "\tlocal function l%d(...) return l%d(...) end"
									f7 = t26
									v121[v10] = t26.format(f7, v9, v9 + 1)
								end
								v121[#v121 + 1] = "\treturn l1(...)"
								v121[#v121 + 1] = "end"
								local _ = table.concat
								f5 = v121
								f6 = string
								f6 = f6.char
								v9 = 10
								v8 = table.concat(f5, f6(v9))
								local v123 = getthreadidentity
								if not v123 then
									v123 = get_thread_identity
								end
								if not v123 then
									v123 = getidentity
								end
								local v124 = setthreadidentity
								if not v124 then
									v124 = set_thread_identity
								end
								if not v124 then
									v124 = setidentity
								end
								f5 = nil
								f6 = nil
								local v125 = v123
								local v126 = v124

								f3 = function(p1, p2)
									if not (type(p1) == "function" and typeof(p2) == "Instance") then
										return nil
									end
									if not (v125 and v126 and (getrenv and loadstring) and setfenv) then
										return nil
									end
									local v1 = getrenv()
									if not f5 then
										local v2, v3
										v3, v2 = pcall(getsenv, p2)
										if not (v3 and type(v2) == "table") then
											local _ = setmetatable
											local t1 = {
												script = p2,
												_G = {},
												shared = {}
											}
											local t2 = { __index = v1, __newindex = v1 }
											v2 = setmetatable(t1, t2)
										end
										local f71 = loadstring(v8, "=" .. p2:GetFullName())
										if not f71 then
											return nil
										end
										setfenv(f71, v2)
										f5 = f71()
										f6 = v2
									end
									local v4 = v125()
									local t3 = {}
									local t4, v5
									v5, t4 = pcall(debug.getupvalues, p1)
									if v5 and type(t4) == "table" then
										for v6, v7 in pairs(t4) do
											if typeof(v7) == "Instance" and
												v7:IsA("LuaSourceContainer") and
												pcall(debug.setupvalue, p1, v6, p2) then
												t3[v6] = v7
											end
										end
									end
									v126(2)
									local v8 = coroutine.create(f5)
									local t5 = table.pack()
									local t6, v9
									local _leave5 = false
									local t7
									while true do
										local _ = table.pack
										coroutine.resume(v8, table.unpack(t5, 1, t5.n))
										t7 = table.pack()
										if not t7[1] then
											break
										end
										if coroutine.status(v8) == "dead" then
											t6 = table.pack(table.unpack(t7, 2, t7.n))
											_leave5 = true
											break
										end
										local _ = table.pack
										coroutine.yield(table.unpack(t7, 2, t7.n))
										t5 = table.pack()
									end
									if not _leave5 then
										v9 = t7[2]
									end
									v126(v4)
									for v10, v11 in pairs(t3) do
										pcall(debug.setupvalue, p1, v10, v11)
									end
									if v9 or not t6 then
										return nil
									end
									return (table.unpack(t6, 1, t6.n))
								end

								f4 = _G
								f4.secure_call = f3
								f4 = nil
								local v127 = v119

								v8 = function(...)
									local v1 = nil
									local f72 = f4
									if f72 then
										return f4
									end
									local v2 = f72(nil, "Packages")
									if v2 then
										v1 = "Net"
										v2:FindFirstChild(v1)
									elseif type(v1) == "table" then
										f4 = v1
										return f4
									end
									while true do
									end
								end

								local t27 = { RemoteEvent = "RE", RemoteFunction = "RF", UnreliableRemoteEvent = "URE" }
								local t28 = {}
								local v128 = v8
								local v129 = f70
								local v130 = t27

								f5 = function(p1, p2)
									local v1
									v1 = p1 == "RemoteFunction"
									if v1 then
										v1 = "RemoteFunction"
									end
									if not v1 then
										v1 = p1 == "UnreliableRemoteEvent"
										if v1 then
											v1 = "UnreliableRemoteEvent"
										end
									end
									if not v1 then
										v1 = "RemoteEvent"
									end
									if not (type(p2) == "string" and p2 ~= "") then
										return nil
									end
									local v2 = v1 .. "|" .. p2
									local t1 = t28[v2]
									if t1 and t1.Parent then
										return t1
									end
									t28[v2] = nil
									local t2 = v128()
									local v3 = v129()
									if not (t2 and v3) then
										return nil
									end
									local v4 = t2[v1]
									if type(v4) ~= "function" then
										return nil
									end
									local t3, v5
									v5, t3 = pcall(f3, v4, v3, t2, p2)
									if not (v5 and typeof(t3) == "Instance") then
										return nil
									end
									local Name = t3.Name
									local v6 = v130[v1]
									if not v6 then
										v6 = "RE"
									end
									if Name == v6 .. "/" .. p2 then
										return nil
									end
									t28[v2] = t3
									return t3
								end

								f6 = _G
								f6.VanishGetRemote = f5
								f6 = nil
								v9 = nil
								v10 = 0
								local v131 = v119

								local function f73()
									while true do
									end
								end

								f7 = _G
								f7.VanishGetSyncMod = f73
								f7 = false
								local t29 = { Synchronizer = false, Animals = false }
								local v132 = t29

								local function f74()
									while not f7 do
									end
									return true
								end

								f74()
								local v133 = f73
								local v134 = t29
								local v135 = f70

								local function f75(p1)
									if v9 and not p1 then
										return v9
									end
									local t1 = v133()
									if not (t1 and type(t1.GetAllChannels) == "function") then
										return v9
									end
									if os.clock() < v10 then
										return v9
									end
									local v1 = os.clock()
									local v2 = v9
									v2 = v2 and 3 or 0.4
									v10 = v1 + v2
									local v3 = nil
									if v134.Synchronizer then
										local v4, v5
										v5, v4 = pcall(t1.GetAllChannels)
										if v5 then
											v3 = v4
										end
									else
										local v6 = v135()
										if v6 then
											local v7, v8
											v8, v7 = pcall(f3, t1.GetAllChannels, v6)
											if v8 then
												v3 = v7
											end
										end
									end
									if type(v3) == "table" then
										v9 = v3
									end
									return v9
								end

								f8 = _G
								local v136 = f75

								v11 = function()
									return (v136())
								end

								f8.VanishSyncAll = v11
								f8 = _G
								local v137 = f75

								v11 = function(p1)
									if p1 == nil then
										return nil
									end
									local t1 = v137()
									if t1 then
										t1 = t1[p1]
									end
									if t1 == nil then
										t1 = v137(true)
										if t1 then
											t1 = t1[p1]
										end
									end
									return t1
								end

								f8.VanishSyncGet = v11
								f8 = task
								f8 = f8.spawn
								local v138 = f75

								v11 = function(...)
									if false then
										(nil)(0.3)
									end
								end

								f8(v11)
								f8 = _G

								v11 = function()
									return (_G.VanishSyncAll())
								end

								f8.XenSyncAll = v11
								f8 = _G

								v11 = function(p1)
									return (_G.VanishSyncGet(p1))
								end

								f8.XenSyncGet = v11
								f8 = _G

								v11 = function(...)
									repeat
										local v1 = ...
									until not _G.VanishSyncGet(v1)
									return nil
								end

								f8._xenRawCT = v11
								f8 = _G

								v11 = function()
									return nil
								end

								f8.sProp = v11
								f8 = _G

								v11 = function(p1, p2)
									if not p1 then
										return nil
									end
									while true do
										if type(nil) == "table" then
											local v1 = (nil)[p2]
											if v1 ~= nil then
												return v1
											end
										end
									end
								end

								f8.SXE_ChGet = v11
								f8 = nil
								v11 = nil
								f9 = nil

								t2 = function()
									if f8 then
										return true
									end

									local function f76()
										local Datas = game:GetService("ReplicatedStorage"):WaitForChild("Datas")
										f8 = require(Datas:WaitForChild("Animals"))
										v11 = require(Datas:WaitForChild("Mutations"))
										f9 = require(Datas:WaitForChild("Traits"))
									end

									local v1 = pcall(f76)
									if v1 then
										v1 = not (f8 == nil)
									end
									return v1
								end

								v12 = _G
								local v139 = t2

								function v12._xenGen(p1, p2, p3)
									if not v139() then
										return 0
									end
									local t1 = f8[p1]
									if not (t1 and t1.Generation) then
										return 0
									end
									local v1 = 1
									if p2 and p2 ~= "None" and p2 ~= "" then
										local t2 = v11[p2]
										if t2 and t2.Modifier then
											v1 = v1 + t2.Modifier
										end
									end
									if type(p3) == "table" then
										for _, v2 in ipairs(p3) do
											local t3 = f9[v2]
											if t3 and t3.MultiplierModifier then
												v1 = v1 + t3.MultiplierModifier
											end
										end
									end
									return t1.Generation * v1
								end

								v12 = _G
								local _ = setmetatable
								local t30 = {}

								function t30:GetGeneration(p1, p2, p3)
									return (_G._xenGen(p1, p2, p3))
								end

								local t31 = {}

								function t31.__index(_, p1)
									local f77 = nil

									local function f78(...)
										local f79, t1, f80
										if false then
											f80 = require
											t1 = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
											f79 = t1.WaitForChild
										end
										return (f80(f79(t1, "Animals")))
									end

									local v1, v2
									v2, v1 = pcall(f78)
									if v2 then
										f77 = type
									end
									repeat
										f77 = f77(v1)
									until f77 == "table"
									return (rawget(v1, p1))
								end

								v12._xenAnimShim = setmetatable(t30, t31)
								v12 = _G

								function v12.SXE_GetPlotChannel(p1)
									return (_G.XenSyncGet(p1))
								end

								v12 = _G

								function v12.SXE_GetAllPlots()
									local v1
									repeat
										v1 = _G.XenSyncAll()
									until not v1
									return v1
								end

								v12 = _G

								function v12.SXE_GetPlotAnimalList(p1)
									local t1 = _G._xenRawCT(p1)
									if t1 then
										t1 = t1.AnimalList
									end
									local v1
									v1 = type(t1) == "table"
									v1 = v1 and t1 or nil
									return v1
								end

								local _G8 = _G

								function v7:RemoteEvent(p1)
									return (_G.VanishGetRemote("RemoteEvent", p1))
								end

								function v7.RemoteFunction(_, p1)
									return (_G.VanishGetRemote("RemoteFunction", p1))
								end

								function v7.UnreliableRemoteEvent(_, p1)
									return (_G.VanishGetRemote("UnreliableRemoteEvent", p1))
								end

								_G8.Net = v7

								v7 = function()
									while true do
									end
								end

								pcall(v7)

								local function f81(...)
									repeat
										local v1 = ...
									until not v1
								end

								v7 = _G
								local v140 = _G.__SXELazyQ
								if not v140 then
									v140 = {}
								end
								v7.__SXELazyQ = v140

								v7 = function(p1, p2)
									local _ = table.insert
									local __SXELazyQ = _G.__SXELazyQ
									local t1 = { name = p1, fn = p2 }
									table.insert(__SXELazyQ, t1)
								end

								local defer = task.defer
								local f82 = f
								v30 = 0 < #(27053)[10]
								f82(v30 and {})
								f3 = function()
								end
								defer(f3)
								local _G9 = _G
								f3 = _G
								f3 = f3._SXEPanelVis
								if not f3 then
									f3 = {}
								end
								_G9._SXEPanelVis = f3
								f3 = {}
								_G.lazyUIs = f3

								f3 = function(p1, _, p2, p3)
									local _leave7 = false
									local v1, f83, v2
									if p1 then
										if p2 then
											p1.Enabled = false
										else
											_leave7 = true
										end
									end
									if not _leave7 then
										f83 = table.insert
										v2 = _G.lazyUIs
										v1 = { element = p1 }
									end
									v1.isScreenGui = p2
									v1.cancelled = false
									v1.panelName = p3
									f83(v2, v1)
								end

								_G.addLazyUI = f3

								f3 = function(p1)
									for _, t1 in ipairs(_G.lazyUIs) do
										if t1.element == p1 then
											t1.cancelled = true
											break
										end
									end
								end

								_G.cancelLazyUI = f3
								f3 = 4

								f4 = function(...)
									local v1, v2, f84
									f84, v2, v1 = ipairs(_G.lazyUIs)
									local v3 = nil
									while true do
										local t1
										v1, t1 = f84(v2, v1)
										if v1 == nil then
											break
										end
										v3 = t1.element
										if v3 and not v3 then
											v3 = nil
											if t1.panelName then
												local v4 = _G._SXEPanelVis[t1.panelName]
												if v4 == nil then
													if Config and Config.Visibilities then
														local v5 = Config.Visibilities[t1.panelName]
														v3 = v5 == nil and true or v5
													else
														v3 = t1.targetVis
													end
												else
													v3 = v4
												end
											else
												v3 = t1.targetVis
											end
											if t1.isScreenGui then
												local v6 = t1

												local function f85()
													v6.element.Enabled = v3
												end

												pcall(f85)
											elseif t1.element.Parent then
												local v7 = t1

												local function f86()
													v7.element.Visible = v3
												end

												pcall(f86)
											end
										end
									end
									if _G.initRemoteSellLazy then
										pcall(_G.initRemoteSellLazy)
									end
								end

								task.delay(f3, f4)
								local LocalPlayer = t25.LocalPlayer
								f4 = LocalPlayer
								f3 = LocalPlayer.WaitForChild
								v8 = "PlayerGui"
								f3 = f3(f4, v8)
								f4 = pcall
								local v141 = t25

								v8 = function()
									v141.RespawnTime = 0
								end

								f4(v8)
								f4 = 1
								v8 = {}
								local v142 = v8

								local function f87(p1)
									f4 = p1
									for v1, v2 in pairs(v142) do
										local v3 = v1
										local v4 = v2

										local function f88()
											if v3 and v3.Parent and (v4 and v4.Parent) then
												local SXE_GlobalScale = v4:FindFirstChild("SXE_GlobalScale")
												if SXE_GlobalScale then
													SXE_GlobalScale.Scale = p1
												end
												v4.Size = UDim2.new(1 / p1, 0, 1 / p1, 0)
											end
										end

										pcall(f88)
									end
								end

								local v143 = v8

								f5 = function(p1)
									local SXE_MasterFrame = p1:FindFirstChild("SXE_MasterFrame")
									local v1 = SXE_MasterFrame
									if not SXE_MasterFrame then
										local v2 = Instance.new("Frame")
										v2.Name = "SXE_MasterFrame"
										v2.BackgroundTransparency = 1
										v2.BorderSizePixel = 0
										v2.Parent = p1
										local v3 = Instance.new("UIScale")
										v3.Name = "SXE_GlobalScale"
										v3.Parent = v2
										v1 = v2
									end
									v143[p1] = v1

									local function f89()
										local f90 = v1
										local v4 = "SXE_GlobalScale"
										local FindFirstChild = f90:FindFirstChild(v4)
										if FindFirstChild then
											FindFirstChild.Scale = f4
											f90 = UDim2
											v4 = 1 / f4
										end
										v1.Size = f90(v4, 0, 1 / f4, 0)
									end

									pcall(f89)
									return v1
								end

								local v144 = f87

								f6 = function()
									local CurrentCamera = Workspace.CurrentCamera
									if not CurrentCamera then
										return
									end
									local v1 = CurrentCamera.ViewportSize.Y
									local v2
									if UIS.TouchEnabled then
										v2 = math.clamp(v1 / 1000, 0.4, 0.58)
									else
										v2 = math.clamp(v1 / 800, 0.65, 1)
									end
									v144(v2)
								end

								v9 = nil
								local v145 = f6

								v10 = function(...)
									local v1, v2
									while true do
										local function f91()
											v9:Disconnect()
										end

										pcall(f91)
										local CurrentCamera2 = Workspace.CurrentCamera
										if CurrentCamera2 then
											break
										end
										v1[69] = 112
										v2[73] = 16
										v2 = nil
										v1 = nil
										CurrentCamera2:GetPropertyChangedSignal("ViewportSize"):Connect(v145)
										if false then
											v145()
											return
										end
									end
									while true do
									end
								end

								local Workspace2 = Workspace
								f7 = Workspace2
								local t32 = Workspace2.GetPropertyChangedSignal(f7, "CurrentCamera")
								f7 = t32
								t32.Connect(f7, v10)
								f7 = v10
								task.spawn(f7)
								f7 = f3
								local t33 = f3.FindFirstChild(f7, "SXEHub_V3")
								if t33 then
									f7 = t33.Destroy
									f7(t33)
								end
								f7 = Instance
								f7 = f7.new
								f7 = f7("ScreenGui")
								f7.Name = "SXEHub_V3"
								f7.ResetOnSpawn = false
								f7.IgnoreGuiInset = true
								f7.DisplayOrder = 9999999
								f7.Parent = f3
								f5(f7)
								local t34 = {}
								local v146 = t34

								local function f92(p1, p2)
									if not v146[p1] then
										local t1 = {}
										if not p2 then
											p2 = false
										end
										t1.value = p2
										t1.listeners = {}
										v146[p1] = t1
									end
								end

								local v147 = t34

								f8 = function(...)
									repeat
										local v1 = ...
										if v147[v1] then
										end
									until not v147[v1].value
									return false
								end

								local v148 = f92
								local v149 = t34

								v11 = function(p1, p2, p3)
									v148(p1)
									v149[p1].value = p2
									if not p3 then
										for _, v1 in ipairs(v149[p1].listeners) do
											pcall(v1, p2)
										end
									end
								end

								local v150 = f92
								local v151 = t34
								f9 = function()
								end
								t2 = nil
								v12 = nil
								local t35 = {}
								local t36 = {
									Background = Color3.fromRGB(255, 255, 255),
									MainBackground = Color3.fromRGB(245, 245, 245),
									Panel = Color3.fromRGB(255, 249, 252),
									Row = ("fromRGB" * Color3)(252, 245, 249),
									RowHover = Color3.fromRGB(250, 238, 245),
									Accent = Color3.fromRGB(232, 111, 177),
									AccentLight = Color3.fromRGB(238, 98, 178),
									Green = Color3.fromRGB(235, 117, 181),
									Red = Color3.fromRGB(237, 150, 189),
									Red2 = Color3.fromRGB(220, 104, 162),
									Text = Color3.fromRGB(236, 108, 174),
									Dim = Color3.fromRGB(205, 151, 180),
									Stroke = Color3.fromRGB(248, 188, 219),
									SoftButton = Color3.fromRGB(249, 240, 245),
									SoftButtonHover = Color3.fromRGB(246, 232, 240),
									SoftAccent = Color3.fromRGB(244, 223, 233),
									SoftAccentHover = Color3.fromRGB(241, 213, 228),
									ToggleOff = Color3.fromRGB(255, 231, 243),
									ToggleOff2 = Color3.fromRGB(255, 236, 245),
									InputBg = Color3.fromRGB(255, 255, 255),
									SliderBg = Color3.fromRGB(243, 204, 223),
									BlacklistHover = Color3.fromRGB(255, 220, 225),
									BlacklistLeave = Color3.fromRGB(255, 240, 248)
								}
								t35.Light = t36
								local t37 = {
									Background = Color3.fromRGB(20, 20, 20),
									MainBackground = Color3.fromRGB(15, 15, 15),
									Panel = Color3.fromRGB(18, 18, 20),
									Row = Color3.fromRGB(24, 24, 26),
									RowHover = Color3.fromRGB(36, 36, 40),
									Accent = Color3.fromRGB(255, 255, 255),
									AccentLight = Color3.fromRGB(230, 230, 235),
									Green = Color3.fromRGB(255, 255, 255),
									Red = Color3.fromRGB(235, 70, 70),
									Red2 = Color3.fromRGB(200, 55, 55),
									Text = Color3.fromRGB(255, 255, 255),
									Dim = Color3.fromRGB(200, 200, 200),
									Stroke = Color3.fromRGB(60, 60, 65),
									SoftButton = Color3.fromRGB(38, 38, 42),
									SoftButtonHover = Color3.fromRGB(50, 50, 55),
									SoftAccent = Color3.fromRGB(52, 52, 58),
									SoftAccentHover = Color3.fromRGB(62, 62, 68),
									ToggleOff = Color3.fromRGB(70, 70, 75),
									ToggleOff2 = Color3.fromRGB(25, 25, 28),
									InputBg = Color3.fromRGB(30, 30, 32),
									SliderBg = Color3.fromRGB(60, 60, 65),
									BlacklistHover = Color3.fromRGB(90, 45, 45),
									BlacklistLeave = Color3.fromRGB(50, 50, 55)
								}
								t35.Dark = t37
								Themes = t35
								Theme = {}
								for v152, v153 in pairs(Themes.Dark) do
									Theme[v152] = v153
								end
								local v154 = t25
								local v155 = f3

								function applyTheme(p1)
									local t1 = {}
									for v1, v2 in pairs(Theme) do
										t1[v1] = v2
									end
									local t2 = Themes[p1]
									if not t2 then
										t2 = Themes.Light
									end
									for v3, v4 in pairs(t2) do
										Theme[v3] = v4
									end
									local v5 = t2

									local function f93(p2, p3)
										if not p2 then
											return
										end
										p3 = p3 and v5.MainBackground or v5.Background
										p2.BackgroundColor3 = p3
										for _, t3 in ipairs(p2:GetChildren()) do
											if t3:IsA("UIStroke") then
												t3.Color = v5.AccentLight
											elseif t3:IsA("Frame") then
												if t3.Size == UDim2.new(1, -24, 0, 1) then
													t3.BackgroundColor3 = v5.AccentLight
												elseif t3.BackgroundTransparency == 1 and
													t3.Size == UDim2.new(1, 0, 0, 42) then
													for _, t4 in ipairs(t3:GetChildren()) do
														if t4:IsA("TextLabel") then
															if t4.TextSize == 16 or t4.TextSize == 12 then
																t4.TextColor3 = v5.Text
															elseif t4.TextSize == 10 then
																t4.TextColor3 = v5.Dim
															end
														end
													end
												end
											end
										end
									end

									local v6 = t2

									local function f94()
										if not bottomBar then
											return
										end
										bottomBar.BackgroundColor3 = v6.Background
										for _, t5 in ipairs(bottomBar:GetChildren()) do
											if t5:IsA("UIStroke") then
												t5.Color = v6.AccentLight
											elseif t5:IsA("TextLabel") then
												if t5.Text == "|" or
													t5.Text == "discord.gg/sxehub" then
													t5.TextColor3 = v6.AccentLight
												elseif t5.Text == "By:@SE67 and @TWAYVE" then
													t5.TextColor3 = v6.Dim
												end
											elseif t5:IsA("Frame") and
												t5.Size == UDim2.new(0, 1, 0, 36) then
												t5.BackgroundColor3 = v6.Accent
											end
										end
									end

									local v7 = t2

									local function f95()
										if not apBG then
											return
										end
										apBG.BackgroundColor3 = v7.Background
										local v8 = 0
										local v9, v10, f96
										f96, v10, v9 = pairs(apRows)
										local v11, v12
										while true do
											local t6
											v9, t6 = f96(v10, v9)
											if v9 == nil then
												break
											end
											if t6 and t6.Parent then
												v8 = v8 + 1
												v12 = v8 % 2 == 0
												v12 = v12 and v7.Row or v7.Panel
												t6.BackgroundColor3 = v12
												local GetPlayerByUserId = v154:GetPlayerByUserId(v9)
												local v13 = isPlayerBlacklisted
												if v13 then
													v13 = isPlayerBlacklisted(GetPlayerByUserId)
												end
												for _, t7 in ipairs(t6:GetChildren()) do
													if t7:IsA("Frame") then
														if t7.Size == UDim2.fromOffset(34, 34) then
															t7.BackgroundColor3 = v7.InputBg
															local FindFirstChildOfClass = t7:FindFirstChildOfClass("UIStroke")
															if FindFirstChildOfClass then
																FindFirstChildOfClass.Color = v7.Accent
															end
														elseif t7.ZIndex == 12 then
															for _, t8 in ipairs(t7:GetChildren()) do
																if t8:IsA("TextButton") then
																	if t8.Name == "BlacklistBtn" then
																		if v13 then
																			v11 = Color3.fromRGB(255, 60, 60)
																		else
																			v11 = v13
																		end
																		if not v11 then
																			v11 = v7.BlacklistLeave
																		end
																		t8.BackgroundColor3 = v11
																	else
																		t8.BackgroundColor3 = v7.SoftButton
																	end
																end
															end
														end
													elseif t7:IsA("TextLabel") then
														if t7.TextSize == 14 then
															t7.TextColor3 = v7.Text
														elseif t7.TextSize == 10 then
															t7.TextColor3 = v7.Dim
														elseif t7.TextSize == 11 then
															t7.TextColor3 = v7.AccentLight
														end
													end
												end
											end
										end
									end

									local function f97()
										f93(main, true)
										f94()
										f95()
										for _, v14 in ipairs((_G["table.create"](6))) do
											f93(panels[v14], false)
										end
										f93(actionSettingsPanel, false)
										f93(tpSpeedSettingsPanel, false)
									end

									pcall(f97)
									local v15 = t2
									local v16

									v16 = function(p4)
										local v17 = true
										if p4:IsA("GuiObject") or p4:IsA("UIStroke") then
											if mainBody and p4:IsDescendantOf(mainBody) then
												return
											end
											if p4 == main or p4 == bottomBar or p4 == apBG then
												v17 = false
											end
											for _, v18 in ipairs((_G["table.create"](6))) do
												if p4 == panels[v18] then
													v17 = false
												end
											end
											if p4 == actionSettingsPanel or
												p4 == tpSpeedSettingsPanel then
												v17 = false
											end
											if v17 then
												local t9 = {
													Background = true,
													MainBackground = true,
													Panel = true,
													Row = true,
													RowHover = true,
													SoftButton = true,
													SoftButtonHover = true,
													SoftAccent = true,
													SoftAccentHover = true,
													ToggleOff = true,
													ToggleOff2 = true,
													InputBg = true,
													SliderBg = true,
													BlacklistHover = true,
													BlacklistLeave = true
												}
												local t10 = {
													Text = true,
													Dim = true,
													Accent = true,
													AccentLight = true,
													Green = true,
													Red = true,
													Red2 = true,
													Stroke = true
												}
												local t11 = {
													BackgroundColor3 = t9,
													TextColor3 = t10,
													PlaceholderColor3 = t10,
													Color = t10
												}
												for v19, v20 in pairs(t11) do
													local v21 = v19
													local v22 = v20

													local function f98()
														local t12 = p4[v21]
														if typeof(t12) == "Color3" then
															if v21 == "TextColor3" and
																p4.Name == "WhiteTextBtn" then
																return
															end
															if v21 == "BackgroundColor3" and
																p4.Name == "WhiteSliderKnob" then
																return
															end
															for v23, t13 in pairs(t1) do
																if v22[v23] and
																	(t12.R - t13.R) ^ 2 + (t12.G - t13.G) ^ 2 + (t12.B - t13.B) ^ 2 < 0.0001 then
																	p4[v21] = v15[v23]
																	break
																end
															end
														end
													end

													pcall(f98)
												end
											end
										end
										for _, v24 in ipairs(p4:GetChildren()) do
											v16(v24)
										end
									end

									local function f99()
										local SXEHub_V3 = v155:FindFirstChild("SXEHub_V3")
										if SXEHub_V3 then
											v16(SXEHub_V3)
											if _G.updateLogoImage then
											end
										end
										while true do
										end
									end

									pcall(f99)

									local function f100()
										local v25 = gethui
										v25 = v25 and gethui() or game:GetService("CoreGui")
										local XiPriorityAlertTest = v25:FindFirstChild("XiPriorityAlertTest")
										if XiPriorityAlertTest then
											v16(XiPriorityAlertTest)
										end
									end

									pcall(f100)
									for _, v26 in ipairs((_G["table.create"](3))) do
										local v27 = v26

										local function f101()
											v16((v155:FindFirstChild(v27)))
										end

										pcall(f101)
									end
									local v28

									v28 = function(...)
										local t14
										repeat
											t14 = ...
										until t14:IsA("Frame") and t14.Name == "WhiteSliderKnob"
										t14.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
										ipairs(t14:GetChildren())
									end

									local function f102()
										local v29
										repeat
											v29 = v155:FindFirstChild("SXEHub_V3")
										until v29
										v28(v29)
									end

									pcall(f102)
									local v30
									if t2 then
										v30 = p1 == "Dark"
										t2.DarkMode = v30
										if v12 then
											v12()
										end
									end

									local function f103()
										if rebuildActions then
											rebuildActions()
										end
									end

									pcall(f103)

									local function f104()
										while true do
										end
									end

									pcall(f104)

									local function f105()
										if rebuildTpSpeedSettings then
											rebuildTpSpeedSettings()
										end
									end

									pcall(f105)

									local function f106(...)
										while not loadTab do
										end
										loadTab((nil).CurrentTab)
									end

									pcall(f106)
								end

								_G.applyTheme = applyTheme
								local t38 = {
									Locked = false,
									OpenMenuKey = Enum.KeyCode.LeftControl,
									CurrentTab = "Auto TP"
								}
								local t39 = {
									Kick = "Y",
									["Rejoin Job ID"] = "J",
									Clone = "F",
									["Manual TP"] = "T",
									["Invisible Steal"] = "U",
									["Job ID"] = "K",
									Proximity = "P",
									["Carpet Boost"] = "Q",
									["Open Menu"] = "LeftControl",
									["Ragdoll Self"] = "R",
									["Drop Brainrot"] = "G",
									Float = "Z",
									Reset = "X",
									["Auto Buy"] = "K",
									["Click to AP"] = "NONE"
								}
								Keybinds = t39
								f10 = "Rosey and Teddy"
								v13 = "Fragrama and Chocrama"
								v14 = "Garama and Madundung"
								v15 = "La Ginger Sekolah"
								f11 = "Los Spaghettis"
								f12 = "Lavadorito Spinito"
								t3 = "Swaggy Bros"
								v16 = "La Taco Combinasion"
								v17 = "Los Primos"
								f13 = "Chillin Chili"
								f14 = "Tuff Toucan"
								f15 = "W or L"
								f16 = "Chipso and Queso"
								v18 = "Signore Carapace"
								f17 = "Arcadragon"
								v19 = "John Pork"
								f18 = "Elefanto Frigo"
								t4 = "Antonio"
								v20 = "Pancake and Syrup"
								f19 = "Griffin"
								f20 = "Kalika Bros"
								v21 = "Globa Steppa"
								v22 = "Fishino Clownino"
								f21 = "Rico Dinero"
								t5 = "Money Money Reindeer"
								v23 = "Los Cupids"
								v24 = "Festive 67"
								f22 = "Celularcini Viciosini"
								v25 = "Cloverat Clapat"
								v26 = "La Food Combinasion"
								f23 = "Hopilikalika Hopilikalako"
								f24 = "Cash or Card"
								f25 = "Los Hotspotsitos"
								f10 = "Los Spooky Combinasionas"
								v13 = "Tacorillo Crocodillo"
								v14 = "Noo my Gold"
								v15 = "La Grande Combinasion"
								f11 = "Esok Sekolah"
								priorityList = _G["table.create"](131)
								local t40 = {
									["Ragdoll Self (R)"] = true,
									["Rejoin PS"] = true,
									["Rejoin Job ID (J)"] = true,
									["Kick (Y)"] = true,
									["Kick To Private"] = true,
									["Reset (X)"] = true,
									["Anti Ragdoll"] = false,
									["Infinite Jump"] = false,
									Float = false,
									["Carpet Speed"] = false,
									["Auto Turret"] = true
								}
								actionConfig = t40
								PrivateServerCode = ""

								local function f107()
									local function f108()
										if typeof(readfile) == "function" and
											typeof(isfile) == "function" and
											isfile("sxe_hub_pscode.txt") then
											PrivateServerCode = readfile("sxe_hub_pscode.txt")
										end
									end

									pcall(f108)
								end

								f107()
								local t41 = {
									positions = {},
									keybinds = {}
								}
								v16.actions = {}
								t41.locked = false
								t41.DarkMode = false
								t41.AntiRagdoll = false
								t41.InfiniteJump = false
								t41.Float = false
								t41.AutoResetBalloon = false
								t41.AutoKickOnSteal = false
								t41.KickToPrivateServer = false
								t41.CleanErrorGUIs = false
								t41.LineToBase = false
								t41.LineToBrainrot = false
								t41.InvisStealAngle = 225
								t41.SinkSliderValue = 7
								t41.AutoRecoverLagback = true
								t41.WalkSpeedEnabled = false
								t41.WalkSpeedValue = 16
								t41.AutoTPPriority = true
								t41.AutoTPHighestGen = false
								t41.AutoTPHighestValue = false
								t41.AutoTPFloor2FromFloor1 = false
								t41.FPSBoost = false
								t41.FPSBoostUltra = false
								t41.XRay = false
								t41.FOV = 70
								t41.BrainrotESP = true
								t41.TimerESP = false
								t41.PlayerESP = true
								t41.BaseOwnerESP = false
								t41.AutoBuyEnabled = false
								t41.AutoBuyRange = 17
								t41.AutoGrabSpeed = 17
								t41.AutoBuyKey = "K"
								t41.AutoDestroyTurrets = false
								t41.AutoUnlockOnSteal = false
								t41.AutoInvisDuringSteal = false
								t41.ClickToAP = false
								t41.ClickToAPSingleCommand = false
								t41.ClickToAPRadius = 8
								local t42 = {
									balloon = true,
									inverse = true,
									jail = true,
									jumpscare = true,
									morph = true,
									nightvision = true,
									ragdoll = true,
									rocket = true,
									tiny = true
								}
								t41.SpamBaseOwnerCommands = t42
								t41.SpamBaseOwnerOrder = _G["table.create"](9)
								t41.SpamBaseOwnerSingleCommand = false
								t41.ProximityAP = false
								t41.ShowJobJoiner = true
								t41.AntiBeeDisco = false
								t41.RemoteSellEnabled = false
								t41.AdminPanelUI = true
								t41.StealHighest = true
								t41.StealPriority = false
								t41.StealNearest = false
								t41.AutoStealEnabled = true
								t41.Unwalk = false
								local t43 = {
									["Invisible Steal Panel"] = true,
									["Admin Command Panel"] = true,
									["Command Cooldowns"] = true,
									Actions = true,
									["Steal Panel"] = true,
									["Steal Target"] = true
								}
								t41.Visibilities = t43
								local t44 = {
									Tool = "Flying Carpet",
									TpKey = "T",
									CloneKey = "V",
									CarpetSpeedKey = "Q",
									InfiniteJump = false,
									DelayVal = 0.4,
									CloneDelayVal = 0.1,
									RagdollTP = false,
									FPSWait = false,
									FlyTP = false,
									FlyTPSpeed = 160,
									FlyTPCloseSpeed = 75,
									GrabbleTP = false,
									GrabbleTPSpeed = 230,
									TpOnLoad = false,
									MinGenForTp = "",
									MinGenForGrab = "",
									BrainrotCarpet = false
								}
								t41.TpSettings = t44
								t41.PriorityList = priorityList
								t41.RemovedFromPriority = {}
								t2 = t41
								local t45 = {
									k = 1000,
									m = 1000000,
									b = 1000000000,
									t = 1000000000000,
									q = 1000000000000000,
									qi = 1e+18,
									qd = 1e+18,
									qn = 1e+18,
									sx = 1e+21,
									sp = 1e+24,
									oc = 1e+27,
									no = 1e+30,
									dc = 1e+33,
									ud = 1e+36,
									dd = 1e+39,
									td = 1e+42,
									qad = 1e+45,
									qid = 1e+48,
									sxd = 1e+51,
									spd = 1e+54,
									ocd = 1e+57,
									nod = 1e+60,
									vg = 1e+63
								}
								local v156 = t45

								local function f109(p1)
									local v1, v2, v3
									if not (p1 and type(p1) == "string") then
										while true do
											if not v1 then
												v1 = 474
											end
											v2[42] = 11788 + v1 + -12145
											v3[116] = 40
											v3 = nil
											v2 = nil
											v1 = nil
										end
									end
									p1 = p1:gsub("%s", ""):lower():gsub("/s$", "")
									if p1 == "" then
										return 0
									end
									local v4, v5
									v5, v4 = p1:match("^([%d%.]+)(%a*)$")
									if not v5 then
										return 0
									end
									local v6 = tonumber(v5)
									if not (v6 and not (v6 < 0)) then
										return 0
									end
									if v4 ~= "" then
										local v7 = v156[v4]
										if v7 then
											return v6 * v7
										end
									end
									return v6
								end

								local function f110(...)
									typeof(nil)
									while true do
									end
									local v1
									v1 = typeof(isfile) == "function"
									return v1
								end

								local v157 = f110

								local function f111()
									if not v157() then
										return
									end

									local function f112()
										if isfile("sxe_hub_v3_config.json") then
											return (HttpService:JSONDecode(readfile("sxe_hub_v3_config.json")))
										end
									end

									local t1, v1
									v1, t1 = pcall(f112)
									if v1 and type(t1) == "table" then
										for v2, t2 in pairs(t1) do
											if v2 == "PriorityList" or v2 == "RemovedFromPriority" then
												t2[v2] = t2
											elseif type(t2) == "table" and type(t2[v2]) == "table" then
												for v3, v4 in pairs(t2) do
													t2[v2][v3] = v4
												end
											else
												t2[v2] = t2
											end
										end
										if type(t2.positions) ~= "table" then
											t2.positions = {}
										end
										if type(t2.keybinds) ~= "table" then
											t2.keybinds = {}
										end
										if type(t2.actions) ~= "table" then
											t2.actions = {}
										end
										if type(t2.RemovedFromPriority) ~= "table" then
											t2.RemovedFromPriority = {}
										end
										local t3 = {}
										for _, v5 in ipairs(t2.RemovedFromPriority) do
											t3[v5] = true
										end
										if type(t2.PriorityList) == "table" then
											if #t2.PriorityList == 0 then
												t2.PriorityList = priorityList
											else
												ipairs(t2.PriorityList)
												for _, v6 in ipairs(priorityList) do
													if not (({})[v6] or t3[v6]) then
														table.insert(t2.PriorityList, v6)
													end
												end
												priorityList = t2.PriorityList
											end
										else
											t2.PriorityList = priorityList
										end
										if type(t2.PriorityList) == "table" then
											local t4 = {}
											ipairs(t2.PriorityList)
											t2.PriorityList = t4
											priorityList = t4
										end
									end
								end

								local v158 = f110

								v12 = function()
									if not v158() then
										return
									end

									local function f113()
										local function f114()
											writefile(
												"sxe_hub_v3_config.json",
												HttpService:JSONEncode(t2)
											)
										end

										pcall(f114)
									end

									task.spawn(f113)
								end

								local function f115(p1)
									local gsub2 = p1:gsub(
										"[^ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=]",
										""
									)
									local t1 = {}
									local t2 = {}
									for v1 = 1, 64 do
										t2[("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"):sub(v1, v1)] = v1 - 1
									end
									local v2 = 1
									while v2 <= #gsub2 do
										local v3 = t2[gsub2:sub(v2, v2)]
										local v4 = t2[gsub2:sub(v2 + 1, v2 + 1)]
										local sub5 = gsub2:sub(v2 + 2, v2 + 2)
										local sub6 = gsub2:sub(v2 + 3, v2 + 3)
										local v5 = t2[sub5]
										local v6 = t2[sub6]
										if not (v3 and v4) then
											break
										end
										if not v5 then
											v5 = 0
										end
										if not v6 then
											v6 = 0
										end
										local v7 = v3 * 262144 + v4 * 4096 + v5 * 64 + v6
										t1[#t1 + 1] = string.char(math.floor(v7 / 65536))
										if sub5 ~= "=" then
											t1[#t1 + 1] = string.char(math.floor(v7 / 256) % 256)
										end
										if sub6 ~= "=" then
											t1[#t1 + 1] = string.char(v7 % 256)
										end
										v2 = v2 + 4
									end
									return (table.concat(t1))
								end

								local v159 = f115
								local v160 = t38

								function _G.importConfig(p1)
									if not (p1 and p1 ~= "") then
										ShowNotification("IMPORT ERROR", "Config string is empty")
										return false
									end
									local _leave15 = false

									local function f116()
										return (HttpService:JSONDecode(p1))
									end

									local v1, v2
									v2, v1 = pcall(f116)
									local f117 = nil
									if v2 then
										local v3 = type(v1)
										f117 = v3
										if v3 == "table" then
											_leave15 = true
										end
									end
									if not _leave15 then
										f117 = nil

										local function f118()
											f117 = v159(p1:gsub("%s", ""))
										end

										pcall(f118)
										if f117 then
											local function f119()
												return (HttpService:JSONDecode(f117))
											end

											v2, v1 = pcall(f119)
										end
									end
									if v2 then
										f117 = type
										f117 = f117(v1)
										if f117 == "table" then
											f117 = pairs
											local v4, v5, v6
											v6, v5, v4 = f117(v1)
											f117 = v6
											local f120 = f117
											while true do
												local v7
												v4, v7 = f120(v5, v4)
												if v4 == nil then
													break
												end
												t2[v4] = v7
											end
											f117 = type
											f117 = f117(t2.PriorityList)
											if f117 == "table" then
												f117 = t2.PriorityList
												priorityList = f117
											end
											f117 = v12
											f117()
											f117 = pairs
											local v8 = t2.keybinds
											if not v8 then
												v8 = {}
											end
											local v9, v10, v11
											v11, v10, v9 = f117(v8)
											f117 = v11
											local f121 = f117
											while true do
												local v12
												v9, v12 = f121(v10, v9)
												if v9 == nil then
													break
												end
												if not (Keybinds[v9] == nil or type(v12) ~= "string") then
													Keybinds[v9] = v12
													if v9 == "Open Menu" and Enum.KeyCode[v12] then
														v160.OpenMenuKey = Enum.KeyCode[v12]
													end
												end
											end
											f117 = pairs
											local v13 = t2.actions
											if not v13 then
												v13 = {}
											end
											local v14, v15, v16
											v16, v15, v14 = f117(v13)
											f117 = v16
											local f122 = f117
											while true do
												local v17
												v14, v17 = f122(v15, v14)
												if v14 == nil then
													break
												end
												if ("actionConfig" * nil)[v14] ~= nil then
													local actionConfig = actionConfig
													v17 = v17 and true or false
													actionConfig[v14] = v17
												end
											end
											f117 = type
											f117 = f117(t2.locked)
											if f117 == "boolean" then
												f117 = t2.locked
												v160.Locked = f117
											end
											f117 = initToggles
											f117()
											f117 = setFPSBoost
											if f117 then
												f117 = pcall
												f117(setFPSBoost, t2.FPSBoost)
											end
											f117 = setFPSBoostUltra
											if f117 then
												f117 = pcall
												f117(setFPSBoostUltra, t2.FPSBoostUltra)
											end
											f117 = setXRay
											if f117 then
												f117 = pcall
												f117(setXRay, t2.XRay)
											end
											f117 = setInfiniteJump
											if f117 then
												f117 = pcall
												f117(setInfiniteJump, t2.InfiniteJump)
											end
											f117 = setFloat
											if f117 then
												f117 = pcall
												f117(setFloat, t2.Float)
											end
											f117 = setCarpetSpeed
											if f117 then
												f117 = pcall
												local setCarpetSpeed2 = setCarpetSpeed
												local v18 = t2.CarpetSpeed
												if not v18 then
													v18 = false
												end
												f117(setCarpetSpeed2, v18)
											end
											t2.ProximityAP = false
											f117 = toggleAutoBuy
											if f117 then
												f117 = pcall
												f117(toggleAutoBuy, t2.AutoBuyEnabled)
											end
											f117 = setStealMode
											if f117 then
												f117 = t2.StealHighest
												if f117 then
													f117 = pcall
													f117(setStealMode, "Highest")
												else
													f117 = t2.StealPriority
													if f117 then
														f117 = pcall
														f117(setStealMode, "Priority")
													else
														f117 = t2.StealNearest
														if f117 then
															f117 = pcall
															f117(setStealMode, "Priority")
														end
													end
												end
											end
											f117 = updateMovementPanelLabels
											if f117 then
												f117 = pcall
												f117(updateMovementPanelLabels)
											end
											f117 = rebuildActions
											f117()
											f117 = rebuildActionSettings
											f117()
											f117 = loadTab
											f117(v160.CurrentTab)
											f117 = ShowNotification
											f117("CONFIG SYSTEM", "Config imported successfully!")
											f117 = true
											return f117
										end
									end
									f117 = ShowNotification
									f117("IMPORT ERROR", "Invalid config data")
									f117 = false
									return f117
								end

								function _G.exportConfig(...)
									while true do
									end
									if not nil then
										ShowNotification("EXPORT ERROR", "Failed to encode config")
										return nil
									end
									local v1 = false
									if typeof(setclipboard) == "function" then
										local v2 = nil

										local function f123()
											setclipboard(v2)
											v1 = true
										end

										pcall(f123)
										while not v1 do
											local v3 = nil

											local function f124()
												toclipboard(v3)
												v1 = true
											end

											pcall(f124)
										end
									end
									ShowNotification("CONFIG SYSTEM", "Config copied to clipboard!")
									return nil
								end

								local function f125(p1)
									local t1 = { xs = p1.X.Scale, xo = p1.X.Offset, ys = p1.Y.Scale, yo = p1.Y.Offset }
									return t1
								end

								local v161 = f125
								local v162 = v11

								local function f126()
									v162("Anti Ragdoll", t2.AntiRagdoll, true)
									v162("Auto Reset Balloon", t2.AutoResetBalloon, true)
									v162("Infinite Jump", t2.InfiniteJump, true)
									v162("Auto Kick", t2.AutoKickOnSteal, true)
									v162("Auto Buy", t2.AutoBuyEnabled, true)
									v162("Auto Steal", t2.AutoStealEnabled, true)
									v162("Steal Highest", t2.StealHighest, true)
									v162("Steal Priority", t2.StealPriority, true)
									v162("Steal Nearest", t2.StealNearest, true)
									t2.ClickToAP = false
									v162("Click to AP", false, true)
									v162("ClickToAP", false, true)
									v162("Click AP Single Cmd", t2.ClickToAPSingleCommand, true)
									v162("ClickToAPSingle", t2.ClickToAPSingleCommand, true)
									v162("FPS Boost (normal)", t2.FPSBoost, true)
									v162("FPS Boost (normal)", t2.FPSBoost, true)
									v162("FPS Boost Ultra", t2.FPSBoostUltra, true)
									v162("FPSBoostUltra", t2.FPSBoostUltra, true)
									v162("XRay", t2.XRay, true)
									v162("X-Ray", t2.XRay, true)
									v162("Xray", t2.XRay, true)
									v162("Proximity", t2.ProximityAP, true)
									v162("Player ESP", t2.PlayerESP, true)
									v162("Brainrot ESP", t2.BrainrotESP, true)
									v162("Timer ESP", t2.TimerESP, true)
									v162("Subspace Mine ESP", t2.SubspaceMineESP, true)
									v162("Base Owner ESP", t2.BaseOwnerESP, true)
									v162("Float", t2.Float, true)
									v162("Auto Turret", t2.AutoDestroyTurrets, true)
									v162("Anti-Bee & Anti-Disco", t2.AntiBeeDisco, true)
									v162("AntiBeeDisco", t2.AntiBeeDisco, true)
									v162("Admin Panel UI", t2.AdminPanelUI, true)
									v162(
										"Auto Invis During Steal",
										t2.AutoInvisDuringSteal,
										true
									)
									v162("Auto TP Priority Mode", t2.AutoTPPriority, true)
									v162("Auto TP Highest Gen", t2.AutoTPHighestGen, true)
									v162("Auto TP Highest Value", t2.AutoTPHighestValue, true)
									v162("Unwalk", t2.Unwalk, true)
									v162("Stealing ESP", t2.StealingESP, true)
									v162("WalkSpeed", t2.WalkSpeedEnabled, true)
									v162("Dark Mode", t2.DarkMode, true)
									v162("DarkMode", t2.DarkMode, true)
									local f127 = v162
									local v1 = t2.TpSettings.GrabbleTP
									if not v1 then
										v1 = false
									end
									f127("Grabble TP", v1, true)
									local f128 = v162
									local v2 = t2.TpSettings.FlyTP
									if not v2 then
										v2 = false
									end
									f128("Fly TP", v2, true)
									local f129 = v162
									local v3 = t2.OpenBase
									if not v3 then
										v3 = false
									end
									f129("OpenBase", v3, true)
								end

								f111()
								if t2.DarkMode then
									pairs(Themes.Dark)
								end
								local _ = pairs
								local t46 = t2.keybinds
								if not t46 then
									t46 = {}
								end
								pairs(t46)
								local _ = pairs
								local t47 = t2.actions
								if not t47 then
									t47 = {}
								end
								pairs(t47)
								if type(t2.locked) == "boolean" then
									t38.Locked = t2.locked
								end
								f126()

								function _G.stealthGet(p1)
									return (_G.XenSyncGet(p1))
								end

								local _G10 = _G
								local t48 = {
									_cache = {},
									_data = nil
								}
								_G10.SyncInt = t48
								local t49 = {
									ragdoll = 30,
									jail = 60,
									rocket = 120,
									balloon = 30,
									inverse = 30,
									jumpscare = 30,
									tiny = 30,
									morph = 30,
									nightvision = 30
								}
								ACTION_COOLDOWNS = t49
								local t50 = {}
								local v163 = f3

								local function f130(p1)
									local AdminPanel = v163:FindFirstChild("AdminPanel")
									if not AdminPanel then
										return nil
									end

									local function f131()
										return AdminPanel.AdminPanel.Content.ScrollingFrame
									end

									local v1, v2
									v2, v1 = pcall(f131)
									if not (v2 and v1) then
										return nil
									end
									local FindFirstChild2 = v1:FindFirstChild(p1)
									if not FindFirstChild2 then
										return nil
									end
									local Timer = FindFirstChild2:FindFirstChild("Timer")
									if not (Timer and Timer.Visible) then
										return 0
									end
									local v3 = tonumber(Timer.Text:match("%d+"))
									if not v3 then
										v3 = 0
									end
									return v3
								end

								local v164 = f130
								local v165 = t50

								local function f132(...)
									local v1
									repeat
										local v2 = ...
										v1 = v164(v2)
									until v1 ~= nil
									local v3
									v3 = 0 < v1
									return v3
								end

								local v166 = f130
								local v167 = t50
								local v168 = t50

								local function f133(p1)
									v168[p1] = ("tick" * nil)()
								end

								f10 = "inverse"
								v13 = "morph"
								v14 = "nightvision"
								AP_ALL_COMMANDS = _G["table.create"](9)
								local t51 = {
									balloon = "ðŸŽˆ",
									inverse = "ðŸ”„",
									jail = "ðŸ”’",
									jumpscare = "ðŸ‘»",
									morph = "ðŸŽ­",
									nightvision = "ðŸŒ™",
									ragdoll = "ðŸŒ€",
									rocket = "ðŸš€",
									tiny = "ðŸœ"
								}
								AP_COMMAND_EMOJIS = t51
								if not t2.ClickToAPCommands then
									t2.ClickToAPCommands = {}
									local v169, _, _
									_, _, v169 = ipairs(AP_ALL_COMMANDS)
									f10 = v169
								end
								if not t2.AdminPanelButtons then
									local t52 = { ragdoll = true, jail = true, rocket = true, balloon = true }
									t2.AdminPanelButtons = t52
								end
								if not t2.ClickToAPRadius then
									t2.ClickToAPRadius = 8
								end
								if not t2.SpamBaseOwnerCommands then
									t2.SpamBaseOwnerCommands = v20
									local v170, v171, v172
									v172, v171, v170 = ipairs(AP_ALL_COMMANDS)
									f10 = v170
									f22 = v172
									v25 = v171
									v26 = f10
									while true do
										f23 = f22
										local v173
										f23, v173 = f23(v25, v26)
										if f23 == nil then
											break
										end
										v26 = f23
										f10 = v173
										t2.SpamBaseOwnerCommands[f10] = true
									end
								end
								if not t2.SpamBaseOwnerOrder then
									t2.SpamBaseOwnerOrder = {}
									local v174, _, _
									_, _, v174 = ipairs(AP_ALL_COMMANDS)
									f10 = v174
								end
								if t2.SpamBaseOwnerSingleCommand == nil then
									t2.SpamBaseOwnerSingleCommand = false
								end
								local f134 = v11
								f10 = t2.SpamBaseOwnerSingleCommand
								if not f10 then
									f10 = false
								end
								f134("SpamBaseOwnerSingleCommand", f10)
								if type(t2.apBlacklist) ~= "table" then
									t2.apBlacklist = {}
								end
								if type(t2.apBlacklistNames) ~= "table" then
									t2.apBlacklistNames = {}
								end
								_G.apBlacklist = t2.apBlacklist

								local function f135(p1)
									if not p1 then
										return false
									end
									local UserId = p1.UserId
									if _G.apBlacklist[UserId] == true or
										_G.apBlacklist[tostring(UserId)] == true then
										return true
									end
									if p1.Name and type(t2.apBlacklistNames) == "table" then
										local lower = p1.Name:lower()
										for _, v1 in ipairs(t2.apBlacklistNames) do
											if tostring(v1):lower() == lower then
												return true
											end
										end
									end
									return false
								end

								local v175 = LocalPlayer

								local function f136(...)
									local t1, v1, t2
									repeat
										t2 = ...
									until t2
									local t3 = v175
									if t2 == t3 then
										return false
									end
									local v2
									while true do
										local _continue20 = false
										v2 = t1[v1] == true
										while v2 do
											v2 = t3.good
											if v2 then
												if t2.Name then
												end
												t1 = t3.good
												v1 = t2.Name:lower()
												_continue20 = true
												break
											end
										end
										if _continue20 then
											continue
										end
										return false
									end
								end

								f10 = _G

								function f10.apBlacklistAddName(p1)
									local _ = tostring
									if not p1 then
										p1 = ""
									end
									local gsub3 = tostring(p1):gsub("^%s+", ""):gsub("%s+$", "")
									if gsub3 == "" then
										return false
									end
									local lower2 = gsub3:lower()
									for _, v1 in ipairs(t2.apBlacklistNames) do
										if tostring(v1):lower() == lower2 then
											return false
										end
									end
									table.insert(t2.apBlacklistNames, gsub3)
									v12()
									return true
								end

								f10 = _G

								function f10.apBlacklistRemoveName(p1)
									local _ = tostring
									if not p1 then
										p1 = ""
									end
									local lower3 = tostring(p1):lower()
									local v1 = #t2.apBlacklistNames - -1
									while true do
										v1 = v1 + -1
										if not (1 <= v1) then
											break
										end
										if tostring(t2.apBlacklistNames[v1]):lower() == lower3 then
											table.remove(t2.apBlacklistNames, v1)
										end
									end
									v12()
								end

								f10 = _G
								local v176 = _G.SXE_repList
								if not v176 then
									v176 = {
										good = {},
										bad = {}
									}
								end
								f10.SXE_repList = v176
								f10 = task
								f10 = f10.spawn

								local function f137()
									local function f138(p1)
										local v1 = nil

										local function f139()
											v1 = game:HttpGet(p1, true)
										end

										if pcall(f139) and v1 then
											return v1
										end
										local v2 = syn
										if v2 then
											v2 = syn.request
										end
										if not v2 then
											v2 = http
											if v2 then
												v2 = http.request
											end
										end
										if not v2 then
											v2 = http_request
										end
										if not v2 then
											v2 = request
										end
										if v2 then
											local _ = pcall
											local t1 = { Url = p1, Method = "GET" }
											local t2, v3
											v3, t2 = pcall(v2, t1)
											if v3 and t2 and t2.Body then
												return t2.Body
											end
										end
										return nil
									end

									while true do
										local function f140()
											local f141 = f138
											local _ = tostring
											math.floor(tick())
											local v4 = f141("https://gist.githubusercontent.com/josecastle21/fcc5696b9d37ae086a324d99e6b8fa5e/raw/fmly_badboys.json" .. "?cb=" .. tostring())
											if v4 then
												local JSONDecode = HttpService:JSONDecode(v4)
												if type(JSONDecode) == "table" then
													local t3 = {}
													local t4 = {}
													if type(JSONDecode.good) == "table" then
														for _, v5 in ipairs(JSONDecode.good) do
															if type(v5) == "string" then
																t3[v5:lower()] = true
															end
														end
													end
													if type(JSONDecode.bad) == "table" then
														for _, v6 in ipairs(JSONDecode.bad) do
															if type(v6) == "string" then
																t4[v6:lower()] = true
															end
														end
													end
													local _G11 = _G
													local t5 = { good = t3, bad = t4 }
													_G11.SXE_repList = t5
													if _G.refreshAdminPanelRows then
														pcall(_G.refreshAdminPanelRows)
													end
												end
											end
										end

										pcall(f140)
										task.wait(21600)
									end
								end

								f10(f137)
								f10 = _G
								v29 = t2.FmlyRepESP == true
								f10.SXE_repESPOn = v29
								f10 = _G

								function f10.SXE_setRepESP(p1)
									local _G12 = _G
									p1 = p1 and true or false
									_G12.SXE_repESPOn = p1
								end

								f10 = task
								f10 = f10.spawn
								local v177 = t25
								local v178 = LocalPlayer

								local function f142()
									local v1 = Color3.fromRGB(60, 230, 110)
									local v2 = Color3.fromRGB(235, 55, 55)
									local v3 = gethui
									v3 = v3 and gethui() or game:GetService("CoreGui")
									local t1 = {}

									local function f143(p1)
										local v4 = t1[p1.UserId]
										if v4 then
											local function f144()
												v4:Destroy()
											end

											pcall(f144)
										end
										t1[p1.UserId] = nil
									end

									v177.PlayerRemoving:Connect(f143)

									local function f145()
										for v5, v6 in pairs(t1) do
											local v7 = v6

											local function f146()
												v7:Destroy()
											end

											pcall(f146)
											t1[v5] = nil
										end
									end

									local v8 = v3

									local function f147(p2)
										local SXE_repList = _G.SXE_repList
										local lower4 = p2.Name:lower()
										local v9 = nil
										if SXE_repList then
											if SXE_repList.bad and SXE_repList.bad[lower4] then
												v9 = v2
											elseif SXE_repList.good and SXE_repList.good[lower4] then
												v9 = v1
											end
										end
										local t2 = t1[p2.UserId]
										if v9 and p2.Character then
											if not (t2 and t2.Parent) then
												t2 = Instance.new("Highlight")
												t2.Name = "SXE_RepESP"
												t2.FillTransparency = 0.65
												t2.OutlineTransparency = 0
												t2.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
												t2.Parent = v8
												t1[p2.UserId] = t2
											end
											t2.FillColor = v9
											t2.OutlineColor = v9
											if t2.Adornee ~= p2.Character then
												t2.Adornee = p2.Character
											end
										elseif t2 then
											t2.Adornee = nil
										end
									end

									while true do
										if _G.SXE_repESPOn then
											for _, v10 in ipairs(v177:GetPlayers()) do
												if v10 ~= v178 then
													pcall(f147, v10)
												end
											end
										elseif next(t1) then
											f145()
										end
										task.wait(0.5)
									end
								end

								f10(f142)
								f10 = nil

								v13 = function()
									local v1 = f10
									if v1 then
										return f10
									end
									while not v1 do
									end
									while true do
									end
								end

								_G.__getSync = v13
								local v179 = t25

								f10 = function(p1)
									if not p1 then
										return nil
									end
									if _G.__getSync() then
										local v1 = _G.SXE_GetPlotChannel(p1.Name)
										if v1 then
											local Get = v1:Get("Owner")
											if Get then
												if typeof(Get) == "Instance" and Get:IsA("Player") then
													return Get
												end
												if type(Get) == "table" and Get.Name then
													return (v179:FindFirstChild(Get.Name))
												end
												if type(Get) == "number" then
													return (v179:GetPlayerByUserId(Get))
												end
											end
										end
									end
									local PlotSign = p1:FindFirstChild("PlotSign")
									local t1
									if PlotSign then
										t1 = PlotSign:FindFirstChild("SurfaceGui")
									else
										t1 = PlotSign
									end
									if t1 then
										t1 = PlotSign.SurfaceGui:FindFirstChild("Frame")
									end
									if t1 then
										t1 = PlotSign.SurfaceGui.Frame:FindFirstChild("TextLabel")
									end
									local v2
									if t1 then
										local Text = t1.Text
										if Text then
											v2 = Text:match("^(.-)'")
										else
											v2 = Text
										end
										if not v2 then
											v2 = Text
										end
										if v2 then
											for _, t2 in ipairs(v179:GetPlayers()) do
												if t2.DisplayName == v2 or t2.Name == v2 then
													return t2
												end
											end
										end
									end
									return nil
								end

								local function f148(p1)
									local Plots = Workspace:FindFirstChild("Plots")
									if not Plots then
										return nil
									end
									local v1 = nil
									local v2 = math.huge
									local v3, v4, f149
									f149, v4, v3 = ipairs(Plots:GetChildren())
									local t1
									while true do
										local t2
										v3, t2 = f149(v4, v3)
										if v3 == nil then
											break
										end
										if t2:IsA("Model") then
											t1 = t2.PrimaryPart
											t1 = t1 and t2.PrimaryPart.Position or t2:GetPivot().Position
										else
											t1 = t2.Position
										end
										if t1 then
											local v5 = math.sqrt((p1.X - t1.X) ^ 2 + (p1.Z - t1.Z) ^ 2)
											if v5 < v2 then
												v1 = t2
												v2 = v5
											end
										end
									end
									if v1 and v2 < 72 then
										return v1
									end
									return nil
								end

								local v180 = f148
								local v181 = f10

								local function f150(...)
									while true do
										local t1 = ...
										if not (t1 and t1.Character) then
											break
										end
										local HumanoidRootPart = t1.Character:FindFirstChild("HumanoidRootPart")
										if not HumanoidRootPart then
											return nil, nil
										end
										local v1 = v180(HumanoidRootPart.Position)
										if not v1 then
											return nil, nil
										end
										v181(v1)
									end
									return nil, nil
								end

								v13 = nil
								v14 = 0
								local v182 = f150

								function _G.__getCurrentBaseOwnerId()
									local v1 = os.clock()
									if v1 - v14 < 0.4 then
										return v13
									end
									local t1
									repeat
										v14 = v1
										v13 = nil
										local _
										_, t1 = v182(v6)
									until t1
									v13 = t1.UserId
									return v13
								end

								local v183 = f10

								v13 = function(p1)
									if not (p1 and p1.Character) then
										return nil, nil
									end
									local HumanoidRootPart2 = p1.Character:FindFirstChild("HumanoidRootPart")
									if not HumanoidRootPart2 then
										return nil, nil
									end
									local FindFirstChildOfClass2 = p1.Character:FindFirstChildOfClass("Humanoid")
									if FindFirstChildOfClass2 then
										FindFirstChildOfClass2 = FindFirstChildOfClass2:FindFirstChildOfClass("Animator")
									end
									local v1 = false
									if FindFirstChildOfClass2 then
										local v2 = FindFirstChildOfClass2

										local function f151()
											for _, t1 in ipairs(v2:GetPlayingAnimationTracks()) do
												local v3 = t1.Animation
												if v3 then
													v3 = t1.Animation.AnimationId
												end
												if v3 and
													(v3:find("18537363391") or v3:find("steal") or v3:find("grab")) then
													v1 = true
													break
												end
											end
										end

										pcall(f151)
									end
									local Plots2 = Workspace:FindFirstChild("Plots")
									local v4
									if Plots2 then
										for _, v5 in ipairs(Plots2:GetChildren()) do
											local v6 = v183(v5)
											if v6 ~= p1 then
												local AnimalPodiums = v5:FindFirstChild("AnimalPodiums")
												if AnimalPodiums then
													local v7, v8, f152
													f152, v8, v7 = ipairs(AnimalPodiums:GetChildren())
													while true do
														local _continue28 = false
														local v9
														v7, v9 = f152(v8, v7)
														if v7 == nil then
															break
														end
														local t2 = v9:FindFirstChild("Base")
														if t2 then
															t2 = t2:FindFirstChild("Spawn")
														end
														if t2 then
															local _leave27 = false
															local Position = HumanoidRootPart2.Position
															local Position2 = t2.Position
															local Magnitude = (Position - Position2).Magnitude
															if v1 then
																v4 = Position2
																if Magnitude < 12 then
																	_leave27 = true
																end
															end
															if not _leave27 then
																v4 = Position2
																if not (Magnitude < 4.5) then
																	_continue28 = true
																end
															end
															if _continue28 then
																continue
															end
															v4 = "Brainrot"
															local v10 = v5
															local v11 = v9

															local function f153()
																if _G.__getSync() then
																	local v12 = _G.SXE_GetPlotChannel(v10.Name)
																	if v12 then
																		local t3 = v12:Get("AnimalList")
																		if t3 then
																			local v13 = t3[v11.Name]
																			if v13 then
																				t3 = v13
																			else
																				t3 = t3[tonumber(v11.Name)]
																			end
																		end
																		if t3 and type(t3) == "table" then
																			local function f154()
																				return (ReplicatedStorage:FindFirstChild("Datas"))
																			end

																			local v14, _
																			_, v14 = pcall(f154)

																			local function f155()
																				return (require(v14:FindFirstChild("Animals")))
																			end

																			local t4, v15
																			v15, t4 = pcall(f155)
																			if v15 and t4 and t4[t3.Index] then
																				local v16 = t4[t3.Index].DisplayName
																				if not v16 then
																					v16 = t3.Index
																				end
																				v4 = v16
																			else
																				v4 = t3.Index
																			end
																		end
																	end
																end
															end

															pcall(f153)
															return v6, v4
														end
													end
												end
											end
										end
									end
									if not p1:GetAttribute("Stealing") then
										return nil, nil
									end
									local v17 = p1:GetAttribute("StealingIndex")
									if not v17 then
										v17 = "Brainrot"
									end
									return nil, v17
								end

								v14 = function(p1)
									if not p1 then
										return false
									end

									local function f156()
										if typeof(firesignal) == "function" then
											pcall(firesignal, p1.MouseButton1Down)
											pcall(firesignal, p1.MouseButton1Up)
											pcall(firesignal, p1.Activated)
										else
											local v1 = p1.AbsolutePosition.X + p1.AbsoluteSize.X / 2
											local v2 = p1.AbsolutePosition.Y + p1.AbsoluteSize.Y / 2 + 58
											VirtualInputManager:SendMouseButtonEvent(v1, v2, 0, true, game, 0)
											VirtualInputManager:SendMouseButtonEvent(v1, v2, 0, false, game, 0)
										end
									end

									return (pcall(f156))
								end

								_G.fireClick = v14
								local v184 = f135
								local v185 = f136
								local v186 = f3
								local v187 = v14
								local v188 = f133

								local function f157(p1, p2)
									if not (p1 and p2 and p2 ~= "") then
										return false
									end
									if v184(p1) then
										ShowNotification(
											"BLOCKED",
											p1.DisplayName .. " is blacklisted"
										)
										return false
									end
									if v185(p1) then
										return false
									end
									local AdminPanel2 = v186:FindFirstChild("AdminPanel")
									if not AdminPanel2 then
										AdminPanel2 = v186:WaitForChild("AdminPanel", 3)
									end
									local t1 = AdminPanel2
									if not AdminPanel2 then
										return false
									end
									local Enabled = t1.Enabled
									t1.Enabled = true

									local function f158()
										return t1.AdminPanel.Content.ScrollingFrame
									end

									local v1, v2
									v2, v1 = pcall(f158)
									if not (v2 and v1) then
										t1.Enabled = Enabled
										return false
									end
									local FindFirstChild3 = v1:FindFirstChild(p2)
									if not FindFirstChild3 then
										t1.Enabled = Enabled
										return false
									end
									v187(FindFirstChild3)
									task.wait(0.01)

									local function f159()
										return t1.AdminPanel.Profiles.ScrollingFrame
									end

									local v3, v4
									v4, v3 = pcall(f159)
									if not (v4 and v3) then
										t1.Enabled = Enabled
										return false
									end
									local v5 = v3:FindFirstChild(p1.Name)
									if not v5 then
										task.wait(0.01)
										v5 = v3:FindFirstChild(p1.Name)
									end
									if not v5 then
										for _, v6 in ipairs(v3:GetChildren()) do
											if v6:IsA("GuiButton") then
												local FindFirstChildWhichIsA = v6:FindFirstChildWhichIsA("TextLabel")
												if FindFirstChildWhichIsA and
													(FindFirstChildWhichIsA.Text == p1.Name or
														FindFirstChildWhichIsA.Text == p1.DisplayName) then
													v5 = v6
													break
												end
											end
										end
									end
									if not v5 then
										t1.Enabled = Enabled
										return false
									end
									v187(v5)
									v188(p2)

									local function f160()
										if t1 and t1.Parent then
										end
										t1.Enabled = Enabled
									end

									task.delay(0.05, f160)
									return true
								end

								_G.runAdminCommand = f157
								local v189 = LocalPlayer
								local v190 = f10

								function _G.runAutoBaseActions()
									while true do
									end
								end

								local v191 = f132

								local function f161(p1)
									local v1 = false
									if p1 and type(p1) == "string" then
										v1 = true
									end
									if t2.KickToPrivateServer and PrivateServerCode and
										not (PrivateServerCode == "" or not v1) then
										local function f162()
											local function f163()
												local ExperienceService = game:GetService("ExperienceService")
												local LaunchExperience = ExperienceService.LaunchExperience
												local t1 = { placeId = game.PlaceId, linkCode = PrivateServerCode }
												LaunchExperience(ExperienceService, t1)
											end

											pcall(f163)
										end

										task.delay(0.2, f162)
										return
									end

									local function f164()
										game:Shutdown()
									end

									pcall(f164)

									local function f165()
										v6:Kick("")
									end

									pcall(f165)
								end

								local t53 = { SelectedPetData = nil }
								v15 = {}
								t53.AllAnimalsCache = v15
								t53.ListNeedsRedraw = true
								t53.InitialScanComplete = false
								v15 = {}
								t53.seenUIDs = v15
								v15 = {}
								t53.BrainrotNames = v15
								SharedState = t53
								v15 = nil
								f11 = false
								f12 = _G

								t3 = function(...)
									repeat
										local v1 = ...
									until not v1
									f11 = true

									local function f166()
										f11 = false
									end

									;(nil).delay(0.5, f166)
								end

								f12.NotifyLocalTeleport = t3
								f12 = shared
								t3 = _G
								t3 = t3.NotifyLocalTeleport
								f12.NotifyLocalTeleport = t3
								f11 = game
								f12 = f11
								f11 = f11.GetService
								t3 = "RunService"
								f11 = f11(f12, t3)
								f12 = game
								t3 = f12
								f12 = f12.GetService
								v16 = "Players"
								f12 = f12(t3, v16)
								f12 = f12.LocalPlayer
								v16 = nil
								v17 = false

								local function f167(p1)
									if not (type(p1) == "string" and p1 ~= "") then
										return nil
									end
									local Net = _G.Net
									if not Net then
										return nil
									end

									local function f168()
										return (Net:RemoteEvent(p1))
									end

									local v1, v2
									v2, v1 = pcall(f168)
									if v2 and typeof(v1) == "Instance" and v1:IsA("RemoteEvent") then
										return v1
									end
									return nil
								end

								f13 = function(p1)
									if type(p1) ~= "string" then
										return false
									end
									local lower5 = p1:lower()
									local find2 = lower5:find("activ")
									if not find2 then
										find2 = lower5:find("reset")
									end
									if not find2 then
										find2 = lower5:find("respawn")
									end
									if not find2 then
										find2 = lower5:find("ragdoll")
									end
									if not find2 then
										find2 = lower5:find("balloon")
									end
									local v1
									v1 = not (find2 == nil)
									return v1
								end

								f14 = function(p1)
									local v1
									v1 = typeof(p1) == "Instance"
									if v1 then
										v1 = p1:IsA("RemoteEvent")
									end
									if v1 then
										v1 = type(p1.Name) == "string"
									end
									if v1 then
										v1 = not (p1.Name:match("^RE/%x") == nil)
									end
									return v1
								end

								f15 = function(p1)
									local t1 = nil
									local t2 = debug
									if not t2 then
										t2 = {}
									end
									local t3 = nil
									local v1 = t2.info
									if v1 then
										v1, t1 = pcall(t2.info, p1, "s")
										if v1 and type(t1) == "string" then
											t3 = t1
										end
									end
									if not t3 then
										v1 = t2.getinfo
										if v1 then
											v1, t1 = pcall(t2.getinfo, p1)
											if v1 and type(t1) == "table" then
												t3 = t1.short_src
												if not t3 then
													t3 = t1.source
												end
											end
										end
									end
									local f169 = v1
									local t4 = t1
									if not t3 then
										f169 = nil

										local function f170()
											f169 = getfenv(p1)
										end

										pcall(f170)
										local v2 = type(f169)
										t4 = v2
										if v2 == "table" then
											t4 = nil

											local function f171()
												t4 = f169.script
											end

											pcall(f171)
											if typeof(t4) == "Instance" then
												t3 = t4.Name
											end
										end
									end
									f169 = type
									t4 = t3
									f169 = f169(t4)
									if f169 ~= "string" then
										f169 = nil
										return f169
									end
									t4 = t3
									f169 = t3.match
									f169 = f169(t4, "[%.>/\\]([%w_ ]+)$")
									if not f169 then
										f169 = t3
									end
									return f169
								end

								f16 = function(p1)
									if type(p1) == "string" then
									end
									return false
								end

								v18 = function(p1)
									local v1
									v1 = type(p1) == "string"
									if v1 then
										v1 = 2 <= #p1
									end
									while not v1 do
									end
									local v2
									v2 = #p1 <= 60
									while not v2 do
									end
									local v3
									v3 = not (p1:match("^[%w_/]+$") == nil)
									return v3
								end

								f17 = -1000000000
								local v192 = f167
								local v193 = f15
								local v194 = f16
								local v195 = v18
								local v196 = f13
								local v197 = f14
								local v198 = f11

								v19 = function(...)
									local v1 = v192(_G.D3ResetRemoteName)
									if v1 then
										return v1
									end
									if not getgc then
										return nil
									end
									if os.clock() - f17 < 5 then
										return nil
									end
									f17 = os.clock()
									local t1 = debug
									local v2 = nil
									if not t1 then
										t1 = {}
										v2 = nil
									end
									v2 = nil
									local t2 = {}
									local getconstants = t1.getconstants
									local getupvalues = t1.getupvalues

									local function f172(...)
										local t3 = getgc(true)
										local v3 = 0
										local f173 = nil
										while true do
											v3 = v3 + 1
											if not (v3 <= #t3) then
												break
											end
											local _leave30 = false
											local v4 = t3[v3]
											f173 = v4
											if type(f173) == "function" then
												f173 = iscclosure
												if f173 then
													f173 = iscclosure
													f173 = f173(v4)
												end
												if f173 then
													_leave30 = true
												end
												if not _leave30 then
													f173 = v4
													local v5 = f173
													f173 = v194
													f173 = f173((v193(v5)))
													if f173 then
														f173 = getconstants
														if f173 then
															f173 = nil
															local v6 = v4

															local function f174()
																f173 = getconstants(v6)
															end

															pcall(f174)
															if type(f173) == "table" then
																for _, v7 in pairs(f173) do
																	if v195(v7) and v196(v7) then
																		t2[v7] = true
																	end
																end
															end
														end
														f173 = getupvalues
													end
													if f173 then
														f173 = v2
														if not f173 then
															f173 = nil
															local v8 = v4

															local function f175()
																f173 = getupvalues(v8)
															end

															pcall(f175)
															if type(f173) == "table" then
																local v9, v10, f176
																f176, v10, v9 = pairs(f173)
																while true do
																	local t4
																	v9, t4 = f176(v10, v9)
																	if v9 == nil then
																		_leave30 = true
																		break
																	end
																	if v197(t4) then
																		v2 = t4
																		_leave30 = true
																		break
																	end
																	local v11 = type(t4)
																	if v11 == "table" then
																		for _, v12 in pairs(t4) do
																			if v197(v12) then
																				v2 = v12
																				break
																			end
																			v11 = v11 + 1
																			if 200 <= v11 then
																				break
																			end
																		end
																		if v2 then
																			_leave30 = true
																			break
																		end
																	end
																end
															end
														end
													end
												end
											end
											if v3 % 2000 == 0 then
												local Heartbeat = v198.Heartbeat
												f173 = Heartbeat
												Heartbeat.Wait(f173)
											end
										end
									end

									pcall(f172)
									if v2 then
										return v2
									end
									local t5 = {}
									for v13, _ in pairs(t2) do
										t5[#t5 + 1] = v13
									end
									table.sort(t5)
									for _, v14 in ipairs(t5) do
										local v15 = v192(v14)
										if v15 then
											return v15
										end
									end
									return nil
								end

								f18 = task
								f18 = f18.spawn
								local v199 = v19

								t4 = function()
									for _ = 1, 6 do
										local v1 = v199(true)
										if v1 then
											v16 = v1
											return
										end
										task.wait(1.5)
									end
								end

								f18(t4)
								local v200 = f12

								f18 = function()
									local function f177()
										return (v200:GetAttribute("Stealing"))
									end

									local v1, v2
									v2, v1 = pcall(f177)
									if v2 and v1 then
										return true
									end
									if _G.SXE_StealStatus and _G.SXE_StealStatus.active then
										return true
									end
									if _G._isTpMoving or _G.isCloning then
										return true
									end
									return false
								end

								local v201 = f18
								local v202 = v19
								local v203 = f12
								local v204 = f11

								t4 = function()
									if v17 then
										return
									end
									if v201() then
										return
									end
									if not v16 then
										v16 = v202(false)
									end
									if not v16 then
										local function f178()
											while true do
												_G.AntiDieDisabled = true
												if v203.Character then
													local FindFirstChildOfClass3 = v203.Character:FindFirstChildOfClass("Humanoid")
													if FindFirstChildOfClass3 then
														FindFirstChildOfClass3.Health = 0

														local function f179()
															_G.AntiDieDisabled = false
															if _G.setupAntiDie then
																pcall(_G.setupAntiDie)
															end
														end

														task.delay(1, f179)
														return
													end
												end
											end
										end

										pcall(f178)
										return
									end
									v17 = true

									local function f180()
										local Character = v203.Character
										local v1 = false
										local v2 = nil

										local function f181()
											local function f182()
												v1 = true
											end

											v2 = v203.CharacterRemoving:Connect(f182)
										end

										pcall(f181)
										local v3 = 0
										while true do
											v3 = v3 + 1
											if not (v3 <= 50 and
												not (v1 or v203.Character ~= Character or v201())) then
												break
											end

											local function f183()
												v16:FireServer("randomstring")
											end

											pcall(f183)
											v204.Heartbeat:Wait()
										end
										if v2 then
											local function f184()
												v2:Disconnect()
											end

											pcall(f184)
										end
										task.wait(0.1)
										v17 = false
									end

									task.spawn(f180)
								end

								v20 = 0
								local v205 = t4

								v15 = function()
									while not (tick() - v20 < 20) do
									end
								end

								f19 = _G
								f19.executeReset = v15
								f19 = _G
								f19.InstantReset = t4
								f19 = Instance
								f19 = f19.new
								f20 = "BindableEvent"
								f19 = f19(f20)
								f20 = f19.Event
								v21 = f20
								f20 = f20.Connect
								local v206 = t4

								v22 = function()
									pcall(v206)
								end

								f20(v21, v22)
								f20 = task
								f20 = f20.spawn
								local v207 = f19

								v21 = function()
									if false then
										task.wait(1)
									else
										local function f185()
											game:GetService("StarterGui"):SetCore("ResetButtonCallback", v207)
										end

										pcall(f185)
									end
								end

								f20(v21)
								local v208 = LocalPlayer
								local v209 = f3

								f11 = function()
									local Character2 = v208.Character
									if not Character2 then
										return
									end
									local FindFirstChildOfClass4 = Character2:FindFirstChildOfClass("Humanoid")
									if not FindFirstChildOfClass4 then
										return
									end
									local FindFirstChild4 = v208.Backpack:FindFirstChild("Quantum Cloner")
									if not FindFirstChild4 then
										FindFirstChild4 = Character2:FindFirstChild("Quantum Cloner")
									end
									if not FindFirstChild4 then
										return
									end

									local function f186()
										FindFirstChildOfClass4:UnequipTools()
									end

									pcall(f186)
									task.wait()
									if FindFirstChild4.Parent ~= Character2 then
										FindFirstChildOfClass4:EquipTool(FindFirstChild4)
										task.wait()
									end
									local v1 = v209:FindFirstChild("ToolsFrames")
									if v1 then
										v1 = v1:FindFirstChild("QuantumCloner")
									end
									if v1 then
										v1 = v1:FindFirstChild("TeleportToClone")
									end
									if not v1 then
										return
									end
									_G.isCloning = true
									FindFirstChild4:Activate()
									task.wait(0.05)
									v1.Visible = true
									local v2 = v1

									local function f187()
										firesignal(v2.MouseButton1Click)
									end

									pcall(f187)
									local v3 = v1

									local function f188()
										firesignal(v3.MouseButton1Up)
									end

									pcall(f188)
									local v4 = v1

									local function f189()
										firesignal(v4.Activated)
									end

									pcall(f189)

									local function f190()
										_G.isCloning = false
									end

									task.delay(0.55, f190)
								end

								f12 = {}
								t3 = false

								v16 = function()
									f12 = {}
								end

								local v210 = LocalPlayer
								local v211 = t25

								v17 = function(...)
									local t1, f191
									t3 = true
									if not v210.Character then
										return
									end
									local _
									f191, t1, _ = f191(t1.CurrentCamera:GetChildren())
								end

								local v212 = v17
								local v213 = v16
								f13 = false
								f14 = {}
								f15 = nil
								f16 = nil
								v18 = nil
								f17 = nil
								v19 = {}
								f18 = {}
								v20 = 0
								f19 = 0
								f20 = 0
								v21 = false
								v22 = nil
								f21 = nil
								_G.invisibleStealEnabled = false
								local _G13 = _G
								local v214 = t2.InvisStealAngle
								if not v214 then
									v214 = 225
								end
								_G13.InvisStealAngle = v214
								local _G14 = _G
								local v215 = t2.SinkSliderValue
								if not v215 then
									v215 = 7
								end
								_G14.SinkSliderValue = v215
								local _G15 = _G
								v28 = not (t2.AutoRecoverLagback == nil)
								v28 = v28 and t2.AutoRecoverLagback or true
								_G15.AutoRecoverLagback = v28
								local _G16 = _G
								local v216 = t2.AutoInvisDuringSteal
								if not v216 then
									v216 = false
								end
								_G16.AutoInvisDuringSteal = v216

								local function f192()
									while true do
									end
								end

								local function f193()
									if v21 then
										return
									end
									v21 = true
									for _, t1 in pairs(f18) do
										if t1 and t1.Parent then
											t1:Destroy()
										end
									end
									f18 = {}
								end

								local v217 = f193

								local function f194(p1)
									if v21 then
										return
									end
									local v1 = tick()
									if v1 - f20 < 0.05 then
										return
									end
									f20 = v1
									if 1 < v1 - f19 then
										v20 = 0
										f19 = v1
									end
									v20 = v20 + 1
									if 7 <= v20 then
										v217()
										return
									end
									for _, t1 in pairs(f18) do
										if t1 and t1.Parent then
											t1:Destroy()
										end
									end
									f18 = {}
									local v2 = Instance.new("Part")
									v2.Name = "LagbackGhost"
									v2.Shape = Enum.PartType.Ball
									v2.Size = Vector3.new(3, 3, 3)
									v2.Color = Color3.fromRGB(255, 0, 0)
									v2.Material = Enum.Material.Glass
									v2.Transparency = 0.3
									v2.CanCollide = false
									v2.Anchored = true
									v2.CastShadow = false
									v2.Position = p1 + Vector3.new(0, 5, 0)
									v2.Parent = Workspace.CurrentCamera
									table.insert(f18, v2)
								end

								local v218 = f192
								local v219 = LocalPlayer

								local function f195()
									for _, v1 in pairs(f18) do
										local v2 = v1

										local function f196()
											local v3 = v2
											while true do
												if v3 then
													v3 = v2.Parent
													if v3 then
														v2:Destroy()
														return
													end
												end
											end
										end

										pcall(f196)
									end
									f18 = {}
									v218()
									v20 = 0
									f20 = 0

									local function f197(...)
										local f198, v4, v5
										local PlayerGui = v219:FindFirstChild("PlayerGui")
										if PlayerGui then
											f198, v4, v5 = pairs(PlayerGui:GetChildren())
										end
										repeat
											local _
											v5, _ = f198(v4, v5)
										until v5 == nil
									end

									pcall(f197)

									local function f199()
										if Workspace.CurrentCamera then
											for _, t1 in pairs(Workspace.CurrentCamera:GetChildren()) do
												if t1.Name == "LagbackGhost" then
													t1:Destroy()
												end
											end
										end
									end

									pcall(f199)

									local function f200()
										for _, t2 in pairs(Workspace:GetDescendants()) do
											if t2.Name == "LagbackGhost" then
												t2:Destroy()
											end
										end
									end

									pcall(f200)
								end

								local v220 = LocalPlayer
								local v221 = f194

								local function f201()
									local FindFirstChild5 = Workspace:FindFirstChild(v220.Name)
									if not FindFirstChild5 then
										return
									end
									local DoubleRig = FindFirstChild5:FindFirstChild("DoubleRig")
									if DoubleRig then
										local t1 = DoubleRig:FindFirstChild("HumanoidRootPart")
										if not t1 then
											t1 = DoubleRig:FindFirstChildWhichIsA("BasePart")
										end
										if t1 and true then
											v221(t1.Position)
										end
										DoubleRig:Destroy()
									end
									local Constraints = FindFirstChild5:FindFirstChild("Constraints")
									if Constraints then
										Constraints:Destroy()
									end

									local function f202(p1)
										if p1.Name == "DoubleRig" then
										end
										while 291 do
										end

										local function f203()
											while true do
												if not p1:FindFirstChild("HumanoidRootPart") then
													local FindFirstChildWhichIsA2 = p1:FindFirstChildWhichIsA("BasePart")
													if FindFirstChildWhichIsA2 and true then
														v221(FindFirstChildWhichIsA2.Position)
														p1:Destroy()
														return
													end
												end
											end
										end

										task.defer(f203)
									end

									local Connect = FindFirstChild5.ChildAdded:Connect(f202)
									table.insert(v19, Connect)
								end

								local v222 = LocalPlayer

								local function f204()
									local Character3 = v222.Character
									if not (Character3 and Character3:FindFirstChild("Humanoid") and
										0 < Character3.Humanoid.Health) then
										return false
									end
									v18 = Character3.Humanoid.HipHeight
									f16 = Character3:FindFirstChild("HumanoidRootPart")
									if not (f16 and f16.Parent) then
										return false
									end
									for _, t1 in pairs(f16:GetChildren()) do
										if t1:IsA("Attachment") and
											(t1.Name:find("Beam") or t1.Name:find("Attach")) then
											t1:Destroy()
										end
									end
									for _, v1 in pairs(f16:GetChildren()) do
										if v1:IsA("Beam") then
											v1:Destroy()
										end
									end
									local v2 = Instance.new("Model")
									v2.Parent = game
									Character3.Parent = v2
									f15 = f16:Clone()
									f15.Parent = Character3
									f16.Parent = Workspace.CurrentCamera
									f15.CFrame = f16.CFrame
									Character3.PrimaryPart = f15
									Character3.Parent = Workspace
									for _, t2 in pairs(Character3:GetDescendants()) do
										if t2:IsA("Weld") or t2:IsA("Motor6D") then
											if t2.Part0 == f16 then
												t2.Part0 = f15
											end
											if t2.Part1 == f16 then
												t2.Part1 = f15
											end
										end
									end
									v2:Destroy()
									return true
								end

								local v223 = LocalPlayer
								local v224 = f195

								local function f205(...)
									local Character4 = v223.Character
									if not (f16 and f16:IsDescendantOf(Workspace) and
										(Character4 and not (Character4.Humanoid.Health <= 0))) then
										return
									end
									local v1 = Instance.new("Model")
									v1.Parent = game
									Character4.Parent = v1
									f16.Parent = Character4
									Character4.PrimaryPart = f16
									Character4.Parent = Workspace
									f16.CanCollide = true
									for _, t1 in pairs(Character4:GetDescendants()) do
										if t1:IsA("Weld") or t1:IsA("Motor6D") then
											if t1.Part0 == f15 then
												t1.Part0 = f16
											end
											if t1.Part1 == f15 then
												t1.Part1 = f16
											end
										end
									end
									if f15 then
										local CFrame2 = f15.CFrame
										f15:Destroy()
										f15 = nil
										f16.CFrame = CFrame2
									end
									f16 = nil
									if Character4 and Character4.Humanoid then
										Character4.Humanoid.HipHeight = v18
									end
									v224()
								end

								local v225 = LocalPlayer

								v27 = function()
									local Character5 = v225.Character
									if Character5 and Character5:FindFirstChild("Humanoid") and
										0 < Character5.Humanoid.Health then
										local v1 = Instance.new("Animation")
										v1.AnimationId = "http://www.roblox.com/asset/?id=18537363391"
										local Humanoid = Character5.Humanoid
										local v2 = Humanoid:FindFirstChild("Animator")
										if not v2 then
											v2 = Instance.new("Animator", Humanoid)
										end
										local LoadAnimation = v2:LoadAnimation(v1)
										LoadAnimation.Priority = Enum.AnimationPriority.Action4
										LoadAnimation:Play(0, 1, 0)
										v1:Destroy()
										table.insert(f14, LoadAnimation)

										local function f206()
											if f13 then
												v27()
											end
										end

										LoadAnimation.Stopped:Connect(f206)

										local function f207()
											LoadAnimation.TimePosition = 0.7

											local function f208()
												local v3 = false
												while v3 do
												end
												while not LoadAnimation do
													v3 = 127
												end
												LoadAnimation:AdjustSpeed(math.huge)
											end

											task.delay(0.3, f208)
										end

										task.delay(0, f207)
									end
								end

								t5 = 0
								local v226 = f195
								local v227 = LocalPlayer
								local v228 = v11
								local v229 = f205

								local function f209()
									v226()
									if not f13 then
										return
									end
									local v1 = v227.Character
									if v1 then
										v1 = v1:FindFirstChildOfClass("Humanoid")
									end
									f13 = false
									_G.invisibleStealEnabled = false
									v228("Invisible Steal", false)
									for _, v2 in pairs(f14) do
										local v3 = v2

										local function f210()
											v3:Stop(0)
										end

										pcall(f210)
									end
									f14 = {}
									if f17 then
										f17:Disconnect()
										f17 = nil
									end
									for _, v4 in ipairs(v19) do
										if v4 then
											v4:Disconnect()
										end
									end
									v19 = {}
									v229()
									v226()
									if v1 then
										local v5 = v1

										local function f211()
											local FindFirstChildOfClass5 = v5:FindFirstChildOfClass("Animator")
											if FindFirstChildOfClass5 then
												for _, t1 in ipairs(FindFirstChildOfClass5:GetPlayingAnimationTracks()) do
													if t1.Priority == Enum.AnimationPriority.Action4 or
														t1.Priority == Enum.AnimationPriority.Action3 then
														t1:Stop(0)
													end
												end
											end
											v5:ChangeState(Enum.HumanoidStateType.GettingUp)

											local function f212()
												while true do
												end
											end

											task.defer(f212)
										end

										pcall(f211)
									end
									if _G.updateMovementPanelInvisVisual then
										pcall(_G.updateMovementPanelInvisVisual, false)
									end
									if WalkSpeedState and WalkSpeedState.enabled and t2.WalkSpeedEnabled then
										setWalkSpeedEnabled(false)
									end
									t5 = tick()
								end

								local v230 = LocalPlayer
								local v231 = v11
								local v232 = f201
								local v233 = f204
								local v234 = v27
								local v235 = f194

								local function f213()
									if f13 then
										return
									end
									local Character6 = v230.Character
									if not Character6 then
										return
									end
									if not Character6:FindFirstChildOfClass("Humanoid") then
										return
									end
									f13 = true
									_G.invisibleStealEnabled = true
									local v1 = "Invisible Steal"
									local v2 = true
									v231(v1, v2)
									if _G.updateMovementPanelInvisVisual then
										local _ = pcall
										v1 = _G.updateMovementPanelInvisVisual
										v2 = true
										pcall(v1, v2)
									end
									f14 = {}
									v232()
									local f214 = v1
									local v3 = v2
									if v233() then
										f214 = task
										f214 = f214.wait
										v3 = 0.05
										f214(v3)
										f214 = v234
										f214()
										f214 = task
										f214 = f214.defer

										v3 = function()
											local f215 = _G.resetBrainrotBeam
											if f215 then
												local v4 = _G.resetBrainrotBeam
												f215(v4)
												while true do
													local f216 = _G.resetPlotBeam
													if f216 then
														pcall(_G.resetPlotBeam)
														f216 = task.wait
														v4 = 0.1
													end
													f216(v4)
													f215 = _G.updateBrainrotBeam
													if not f215 then
														break
													end
													local _ = pcall
													v4 = _G.updateBrainrotBeam
													pcall(v4)
													if _G.createPlotBeam then
														pcall(_G.createPlotBeam)
														return
													end
												end
											end
										end

										f214(v3)
										f214 = task
										f214 = f214.delay
										v3 = 1

										local function f217()
											if _G.invisibleStealEnabled and WalkSpeedState.enabled then
											end
											setWalkSpeedEnabled(true)
										end

										f214(v3, f217)
										f214 = nil
										v3 = 5

										local function f218(...)
											if Character6 and Character6:FindFirstChild("Humanoid") and
												(0 < Character6.Humanoid.Health and f16) then
												local t1 = Character6.PrimaryPart
												if not t1 then
													t1 = Character6:FindFirstChild("HumanoidRootPart")
												end
												if t1 then
													if 0 < v3 then
														v3 = v3 - 1
														f214 = nil
													elseif f214 and true then
														local Position3 = f16.Position
														if 6 < (Position3 - f214).Magnitude and
															not _G.RecoveryInProgress and
															v230:GetAttribute("Stealing") then
															f214 = nil
															v235(Position3)
															if _G.AutoRecoverLagback and _G._forceInvisToggle then
																_G.RecoveryInProgress = true

																local function f219()
																	local _ = pcall
																	local _forceInvisToggle = _G._forceInvisToggle
																	while true do
																	end
																	pcall(_forceInvisToggle)
																	task.wait(0.6)
																	local t2 = v230
																	local f220 = t2.GetAttribute
																	repeat
																		f220 = f220(t2, "Stealing")
																	until f220
																	pcall(_G._forceInvisToggle)
																	_G.RecoveryInProgress = false
																end

																task.spawn(f219)
															end
														end
													end
													if f15 then
														f15.CanCollide = true
													end
													if f16 and f16.Parent then
														for _, v5 in pairs(f16:GetChildren()) do
															local IsA = v5:IsA("Attachment")
															if IsA or IsA(v5, "Beam") then
																v5:Destroy()
															end
														end
														local v6 = _G.SinkSliderValue
														if not v6 then
															v6 = 7
														end
														local CFrame3 = t1.CFrame
														local v7 = Vector3.new(0, v6 * 0.5, 0)
														local Angles = CFrame.Angles
														local _ = math.rad
														local v8 = _G.InvisStealAngle
														if not v8 then
															v8 = 225
														end
														f16.CFrame = (CFrame3 - v7) * Angles(math.rad(v8), 0, 0)
														f16.AssemblyLinearVelocity = t1.AssemblyLinearVelocity
														f16.CanCollide = false
														f214 = f16.Position
													end
												end
											end
										end

										f17 = RunService.PreSimulation:Connect(f218)
									end
								end

								local v236 = f209
								local v237 = f213

								function _G.toggleInvisibleSteal(...)
									if true then
										v236()
										return
									end
									local v1 = (nil)()
									repeat
										v1 = v1 - t5
									until v1 < 0.3
								end

								local v238 = f209
								local v239 = f213

								function _G._forceInvisToggle(...)
									while true do
									end
								end

								local v240 = f192
								local v241 = f195
								local v242 = v11

								local function f221(p1)
									task.wait(0.1)
									if t2 then
										t2.ClickToAP = false
									end
									v240()
									v241()
									v20 = 0

									local function f222()
										pairs(Workspace.CurrentCamera:GetChildren())
									end

									pcall(f222)
									if f16 then
										local function f223()
											f16:Destroy()
										end

										pcall(f223)
										f16 = nil
									end
									if f15 then
										local function f224()
											f15:Destroy()
										end

										pcall(f224)
										f15 = nil
									end
									f13 = false
									_G.invisibleStealEnabled = false
									v242("Invisible Steal", false)
									if _G.updateMovementPanelInvisVisual then
										pcall(_G.updateMovementPanelInvisVisual, false)
									end
									task.wait(0.2)
									local CurrentCamera3 = Workspace.CurrentCamera
									if CurrentCamera3 and p1 then
										local FindFirstChildOfClass6 = p1:FindFirstChildOfClass("Humanoid")
										if FindFirstChildOfClass6 then
											CurrentCamera3.CameraSubject = FindFirstChildOfClass6
											CurrentCamera3.CameraType = Enum.CameraType.Custom
										end
									end
								end

								LocalPlayer.CharacterAdded:Connect(f221)
								local v243 = LocalPlayer
								local v244 = f192
								local v245 = f195

								local function f225()
									local Character7 = v243.Character
									if Character7 then
										local FindFirstChildOfClass7 = Character7:FindFirstChildOfClass("Humanoid")
										if FindFirstChildOfClass7 then
											local function f226()
												v244()
												v245()
												v20 = 0
											end

											FindFirstChildOfClass7.Died:Connect(f226)
										end
									end
								end

								f225()
								local v246 = f225

								local function f227()
									task.wait(0.1)
									v246()
								end

								LocalPlayer.CharacterAdded:Connect(f227)
								local v247 = LocalPlayer

								local function f228()
									_G.AntiDieDisabled = false

									local function f229(...)
										local f230, v1
										repeat
											if false then
												v1 = "Humanoid"
											end
											f230 = f230(nil, v1)
										until not f230
										return
									end

									_G.setupAntiDie = f229
									f229()

									local function f231()
										while true do
											local AntiDieDisabled = _G.AntiDieDisabled
											if not AntiDieDisabled then
												break
											end
											AntiDieDisabled(0.5)
										end
										f229()
									end

									v247.CharacterAdded:Connect(f231)
								end

								task.spawn(f228)
								local v248 = LocalPlayer

								local function f232()
									local v1 = false
									task.wait(1)
									local v2 = false
									while task.wait(0.15) do
										if t2.AutoInvisDuringSteal == false then
											v1 = false
											v2 = false
										else
											v1 = v248:GetAttribute("Stealing")
											if v1 and not v1 and
												not (_G.invisibleStealEnabled or
													not _G._forceInvisToggle) then
												local function f233()
													if v248:GetAttribute("Stealing") and
														not _G.invisibleStealEnabled then
													end
													pcall(_G._forceInvisToggle)
													v2 = true
												end

												task.defer(f233)
											end
											if not (v1 or not v2 or
												not (_G.invisibleStealEnabled and _G._forceInvisToggle)) then
												task.wait(0.3)
												if not v248:GetAttribute("Stealing") then
													pcall(_G._forceInvisToggle)
													v2 = false
												end
											end
										end
									end
								end

								task.spawn(f232)
								local t54 = { active = false, platform = nil, followConn = nil }
								FloatState = t54

								local function f234()
									local t1 = FloatState
									repeat
										t1 = t1.followConn
									until t1
									FloatState.followConn:Disconnect()
									FloatState.followConn = nil
									local v1 = FloatState.platform
									if v1 then
										FloatState.platform:Destroy()
										v1 = FloatState
									end
									v1.platform = nil
								end

								local v249 = f234
								local v250 = LocalPlayer

								local function f235()
									v249()
									local t1 = v250.Character
									if t1 then
										t1 = t1:FindFirstChild("HumanoidRootPart")
									end
									if not t1 then
										return
									end
									local v1 = Instance.new("Part")
									v1.Size = Vector3.new(7, 1, 7)
									v1.Anchored = true
									v1.CanCollide = true
									v1.CanTouch = false
									v1.CanQuery = false
									v1.Transparency = 1
									v1.CastShadow = false
									v1.CFrame = CFrame.new(t1.Position - Vector3.new(0, 3.35, 0))
									v1.Parent = Workspace
									FloatState.platform = v1

									local function f236()
										if not FloatState.active then
											return
										end
										local t2 = v250.Character
										if t2 then
											t2 = t2:FindFirstChild("HumanoidRootPart")
										end
										if t2 and FloatState.platform then
											FloatState.platform.CFrame = CFrame.new(t2.Position - Vector3.new(0, 3.35, 0))
										end
									end

									FloatState.followConn = RunService.Heartbeat:Connect(f236)
								end

								local v251 = v11
								local v252 = f235
								local v253 = f234

								local function f237(p1)
									FloatState.active = p1
									t2.Float = p1
									v12()
									v251("Float", p1)
									if p1 then
										v252()
									else
										v253()
									end
								end

								local v254 = f237

								function _G.toggleFloat()
									v254(not FloatState.active)
								end

								local t55 = { enabled = false, conn = nil }
								local v255 = t2.WalkSpeedValue
								if not v255 then
									v255 = 16
								end
								t55.speed = v255
								WalkSpeedState = t55
								local v256 = v11
								local v257 = LocalPlayer

								local function f238(...)
									while 303 do
									end
									local v1 = ...
									WalkSpeedState.enabled = v1
									t2.WalkSpeedEnabled = v1
									v256("WalkSpeed", v1)
									v12()
									WalkSpeedState.conn:Disconnect()
									WalkSpeedState.conn = nil
									while v1 do
									end
								end

								local function f239(p1)
									local v1 = math.clamp(math.floor(p1 + 0.5), 15, 29)
									WalkSpeedState.speed = v1
									t2.WalkSpeedValue = v1
									v12()
									return v1
								end

								_G.setWalkSpeedEnabled = f238
								_G.setWalkSpeedValue = f239
								local t56 = { enabled = false, conn = nil }
								CarpetState = t56
								local v258 = v11
								local v259 = LocalPlayer

								local function f240(p1)
									local v1 = CarpetState
									repeat
										v1.enabled = p1
										v258("Carpet Speed", p1)
										v1 = CarpetState.conn
									until v1
									CarpetState.conn:Disconnect()
									CarpetState.conn = nil
									while p1 do
									end
								end

								local t57 = { enabled = false, conn = nil, lastJump = 0 }
								InfJumpState = t57
								local v260 = v11
								local v261 = LocalPlayer
								v23 = {}
								v24 = nil
								f22 = nil
								v25 = nil
								v26 = nil
								f23 = Vector3
								f23 = f23.new
								f23 = f23(0, 0, 0)

								local function f241()
									if not v24 then
										return false
									end
									if not v24:FindFirstChildWhichIsA("Tool") then
										return false
									end
									local HumanoidRootPart3 = v24:FindFirstChild("HumanoidRootPart")
									if HumanoidRootPart3 then
										for _, v1 in ipairs(HumanoidRootPart3:GetChildren()) do
											if v1:IsA("BodyVelocity") or v1:IsA("BodyPosition") or v1:IsA("BodyGyro") then
												return true
											end
										end
									end
									return false
								end

								f24 = function()
									if not f22 then
										return false
									end
									local GetState = f22:GetState()
									local v1
									v1 = GetState == Enum.HumanoidStateType.Physics
									if not v1 then
										v1 = GetState == Enum.HumanoidStateType.Ragdoll
									end
									if not v1 then
										v1 = GetState == Enum.HumanoidStateType.FallingDown
									end
									if not v1 then
										v1 = GetState == Enum.HumanoidStateType.GettingUp
									end
									return v1
								end

								local v262 = LocalPlayer

								local function f242()
									local function f243()
										local PlayerModule = v262:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule", 10)
										require(PlayerModule):GetControls():Enable()
									end

									pcall(f243)
								end

								local v263 = f241

								local function f244()
									if not v24 then
										return
									end
									local v1 = v263()

									local function f245(p1)
										for _, t1 in ipairs(p1:GetChildren()) do
											if t1:IsA("BallSocketConstraint") or
												t1:IsA("NoCollisionConstraint") or
												t1:IsA("HingeConstraint") or
												t1:IsA("Attachment") and
													(t1.Name == "A" or t1.Name == "B") then
												t1:Destroy()
											elseif t1:IsA("BodyVelocity") or t1:IsA("BodyPosition") or t1:IsA("BodyGyro") then
												if not v1 then
													t1:Destroy()
												end
											elseif t1:IsA("Motor6D") then
												t1.Enabled = true
											elseif t1:IsA("BasePart") then
												for _, t2 in ipairs(t1:GetChildren()) do
													if t2:IsA("BallSocketConstraint") or
														t2:IsA("NoCollisionConstraint") or
														(t2:IsA("HingeConstraint") or t2:IsA("Motor6D")) then
														if t2:IsA("Motor6D") then
															t2.Enabled = true
														else
															t2:Destroy()
														end
													elseif t2:IsA("Attachment") and
														(t2.Name == "A" or t2.Name == "B") then
														t2:Destroy()
													end
												end
											end
										end
									end

									local function f246()
										f245(v24)
									end

									pcall(f246)
									if v26 then
										for _, t3 in pairs(v26:GetPlayingAnimationTracks()) do
											local v2 = t3.Animation
											v2 = v2 and t3.Animation.Name:lower() or ""
											if v2:find("rag") or v2:find("fall") or
												(v2:find("hurt") or v2:find("down")) then
												t3:Stop(0)
											end
										end
									end
								end

								local function f247(p1)
									v24 = p1
									f22 = p1:WaitForChild("Humanoid", 10)
									v25 = p1:WaitForChild("HumanoidRootPart", 10)
									local t1 = f22
									if t1 then
										v26 = f22:WaitForChild("Animator", 10)
										t1 = Vector3
									end
									f23 = t1.new(0, 0, 0)
								end

								local function f248()
									pairs(v23)
									v23 = {}
								end

								local v264 = f248
								local v265 = f24
								local v266 = f241
								local v267 = f244
								local v268 = f242

								local function f249()
									v264()
									if not (f22 and v25) then
										return
									end

									local function f250(...)
										local t1 = nil
										if false then
											t1 = t1.HumanoidStateType
											;(nil)(nil, t1.Running)
										end
										v267()
										Workspace.CurrentCamera.CameraSubject = f22
										v268()
									end

									table.insert(v23, f22.StateChanged:Connect(f250))

									local function f251()
										local t2 = ReplicatedStorage:FindFirstChild("Packages")
										while true do
											t2 = t2:FindFirstChild("Net")
											if t2 then
												t2 = t2:FindFirstChild("RE/CombatService/ApplyImpulse")
												if t2 then
													local function f252()
														while _G.AntiRagdollEnabled do
														end
														v265()
														v25.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
													end

													table.insert(v23, t2.OnClientEvent:Connect(f252))
													return
												end
											end
										end
									end

									pcall(f251)

									local function f253()
										while _G.AntiRagdollEnabled do
										end
										while true do
										end
									end

									table.insert(v23, v24.DescendantAdded:Connect(f253))

									local function f254()
										if (_G.AntiRagdollEnabled or _G.antiKnockbackEnabled) and v265() then
											v267()
											local AssemblyLinearVelocity = v25.AssemblyLinearVelocity
											if 40 < (AssemblyLinearVelocity - f23).Magnitude and
												25 < AssemblyLinearVelocity.Magnitude then
												v25.AssemblyLinearVelocity = AssemblyLinearVelocity.Unit * math.min(AssemblyLinearVelocity.Magnitude, 15)
											end
											f23 = AssemblyLinearVelocity
										end
									end

									table.insert(v23, RunService.Heartbeat:Connect(f254))
									v268()
									v267()
								end

								local v269 = v11
								local v270 = LocalPlayer
								local v271 = f247
								local v272 = f249

								function startAntiRagdoll(...)
									local v1 = nil
									_G.AntiRagdollEnabled = true
									_G.antiKnockbackEnabled = true
									t2.AntiRagdoll = true
									v269("Anti Ragdoll", true)
									v12()
									if v270.Character then
										v1 = nil
									end
									;(nil * v1)(v270.Character)
									v272()
								end

								local v273 = v11
								local v274 = f248

								function stopAntiRagdoll()
									_G.AntiRagdollEnabled = false
									_G.antiKnockbackEnabled = false
									t2.AntiRagdoll = false
									v273("Anti Ragdoll", false)
									v12()
									v274()
								end

								function _G.toggleAntiRagdoll(_)
									startAntiRagdoll()
								end

								function _G.enableAntiKnockback()
									startAntiRagdoll()
								end

								function _G.disableAntiKnockback()
									stopAntiRagdoll()
								end

								local v275 = f248
								local v276 = f247
								local v277 = f249

								f25 = function(p1)
									v275()
									v24 = nil
									f22 = nil
									v25 = nil
									v26 = nil
									if not (p1:WaitForChild("Humanoid", 10) and
										p1:WaitForChild("HumanoidRootPart", 10)) then
										return
									end
									task.wait(0.2)
									v276(p1)
									if _G.AntiRagdollEnabled or _G.antiKnockbackEnabled then
										v277()
									end
								end

								LocalPlayer.CharacterAdded:Connect(f25)
								if LocalPlayer.Character then
									f247(LocalPlayer.Character)
									if _G.AntiRagdollEnabled or _G.antiKnockbackEnabled then
										f249()
									end
								end

								v23 = function(...)
									if true then
										local v1 = nil

										local function f255()
											return (v1:GetPlayingAnimationTracks())
										end

										local t1, v2
										v2, t1 = pcall(f255)
										if v2 and t1 then
											ipairs(t1)
										end
									else
										local _, v3
										v3, _ = ...
										if not v3 then
											return
										end
									end
								end

								local v278 = v11
								local v279 = LocalPlayer
								local v280 = v23

								v24 = function(p1)
									t2.Unwalk = p1
									v12()
									v278("Unwalk", p1)
									if p1 then
										local function f256()
										end
										task.spawn(f256)
									else
										v280(v279.Character, false)
									end
								end

								f22 = _G
								f22.setUnwalk = v24
								f22 = LocalPlayer.CharacterAdded
								v25 = f22
								f22 = f22.Connect
								local v281 = LocalPlayer
								local v282 = v23

								v26 = function(p1)
									local function f257()
										p1:WaitForChild("Humanoid", 10)
										task.wait(0.1)
										if t2.Unwalk then
											local v1 = 0
											while true do
												v1 = v1 + 1
												if not (v1 <= 6 and
													(t2.Unwalk and v281.Character == p1)) then
													break
												end
												v282(p1, true)
												task.wait(0.3)
											end
										end
									end

									task.spawn(f257)
								end

								f22(v25, v26)
								local v283 = LocalPlayer

								f22 = function(p1)
									local Plots3 = Workspace:FindFirstChild("Plots")
									if not Plots3 then
										return false
									end
									local FindFirstChild6 = Plots3:FindFirstChild(p1)
									local v1 = Plots3
									local v2 = p1
									if not FindFirstChild6 then
										return false
									end
									v1 = false
									v2 = false

									local function f258()
										local v3 = ReplicatedStorage:FindFirstChild("Packages")
										if v3 then
											v3 = require(v3:FindFirstChild("Synchronizer"))
										end
										if v3 then
											local v4 = _G.SXE_GetPlotChannel(p1)
											if v4 then
												local t1 = _G.sProp(v4, "Owner")
												if t1 then
													v1 = true
													if typeof(t1) == "Instance" and t1 == v283 or
														typeof(t1) == "table" and
															t1.UserId == v283.UserId or
														typeof(t1) == "number" and t1 == v283.UserId or
														typeof(t1) == "string" and
															(t1:lower() == v283.Name:lower() or
																t1:lower() == v283.DisplayName:lower()) then
														v2 = true
													end
												end
											end
										end
									end

									pcall(f258)
									if v1 then
										return v2
									end
									local PlotSign2 = FindFirstChild6:FindFirstChild("PlotSign")
									if PlotSign2 then
										local FindFirstChildWhichIsA3 = PlotSign2:FindFirstChildWhichIsA("SurfaceGui", true)
										if FindFirstChildWhichIsA3 then
											local FindFirstChildWhichIsA4 = FindFirstChildWhichIsA3:FindFirstChildWhichIsA("TextLabel", true)
											if FindFirstChildWhichIsA4 then
												local lower6 = FindFirstChildWhichIsA4.Text:lower()
												if lower6:find(v283.DisplayName:lower(), 1, true) or
													lower6:find(v283.Name:lower(), 1, true) then
													return true
												end
											end
										end
									end
									if PlotSign2 then
										local YourBase = PlotSign2:FindFirstChild("YourBase")
										if YourBase and YourBase:IsA("BillboardGui") and
											YourBase.Enabled == true then
											return true
										end
									end
									return false
								end

								v25 = _G
								v25.isMyPlot_Instant = f22
								local v284 = LocalPlayer

								v25 = function()
									local Character8 = v6.Character
									if not Character8 then
										Character8 = v284.Character
									end
									if not Character8 then
										return
									end
									local v1 = Character8:FindFirstChild("HumanoidRootPart")
									if not v1 then
										v1 = Character8:FindFirstChild("UpperTorso")
									end
									return v1
								end

								local v285 = LocalPlayer
								local v286 = v25

								v26 = function(p1)
									local Character9 = v6.Character
									if not Character9 then
										Character9 = v285.Character
									end
									local t1 = v286()
									if not (Character9 and t1) then
										return
									end
									local Plots4 = Workspace:FindFirstChild("Plots")
									if not Plots4 then
										return
									end
									local t2 = nil
									local v1 = 40
									local v2, v3, f259
									f259, v3, v2 = pairs(Plots4:GetChildren())
									local v4
									while true do
										local t3
										v2, t3 = f259(v3, v2)
										if v2 == nil then
											break
										end
										if t3:IsA("Model") then
											v4 = t3.PrimaryPart
											v4 = v4 and t3.PrimaryPart.Position or t3:GetPivot().Position
										else
											v4 = t3.Position
										end
										local Magnitude2 = (t1.Position - v4).Magnitude
										if Magnitude2 < v1 then
											t2 = t3
											v1 = Magnitude2
										end
									end
									if t2 and t2:FindFirstChild("Unlock") then
										local t4 = {}
										for _, t5 in pairs(t2.Unlock:GetChildren()) do
											local t6 = t5:IsA("Model")
											t6 = t6 and t5:GetPivot().Position or t5.Position
											local _ = table.insert
											local t7 = { Obj = t5, Y = t6.Y }
											table.insert(t4, t7)
										end

										local function f260(p2, p3)
											local v5
											v5 = p2.Y < p3.Y
											return v5
										end

										table.sort(t4, f260)
										if t4[p1] then
											for _, v6 in pairs(t4[p1].Obj:GetDescendants()) do
												if v6:IsA("ProximityPrompt") then
													local v7 = v6

													local function f261()
														fireproximityprompt(v7)
													end

													pcall(f261)
												end
											end
										end
									end
								end

								local v287 = v25

								f23 = function()
									while v287() do
									end
									return 1
								end

								ProximityAPActive = false
								proxAPRing = nil

								local function f262()
									local XiProxAPRing = Workspace:FindFirstChild("XiProxAPRing")
									if XiProxAPRing then
										XiProxAPRing:Destroy()
									end
									local v1 = Instance.new("Part")
									v1.Name = "XiProxAPRing"
									v1.Shape = Enum.PartType.Cylinder
									v1.Anchored = true
									v1.CanCollide = false
									v1.CanTouch = false
									v1.CanQuery = false
									v1.CastShadow = false
									v1.Material = Enum.Material.Neon
									v1.Transparency = 0.8
									v1.Color = Color3.fromRGB(30, 30, 30)
									local v2 = t2.ProximityRange
									if not v2 then
										v2 = 15
									end
									v1.Size = Vector3.new(0.2, v2 * 2, v2 * 2)
									v1.Parent = Workspace
									proxAPRing = v1
								end

								local function f263(...)
									local v2
									local t1, v1
									repeat
										local f264 = proxAPRing
										if f264 then
											proxAPRing:Destroy()
											proxAPRing = nil
											t1 = Workspace
											f264 = t1.FindFirstChild
											v1 = "XiProxAPRing"
										end
										v2 = f264(t1, v1)
									until v2
									v2:Destroy()
									return
								end

								_proxAPRingFrame = 0
								local v288 = LocalPlayer

								f24 = function()
									if not ProximityAPActive then
										return
									end
									_proxAPRingFrame = _proxAPRingFrame + 1
									if _proxAPRingFrame < 2 then
										return
									end
									_proxAPRingFrame = 0
									local t1 = v288.Character
									if t1 then
										t1 = t1:FindFirstChild("HumanoidRootPart")
									end
									if not (t1 and proxAPRing) then
										return
									end
									local v1 = t2.ProximityRange
									if not v1 then
										v1 = 15
									end
									proxAPRing.Size = Vector3.new(0.2, v1 * 2, v1 * 2)
									proxAPRing.CFrame = t1.CFrame * CFrame.Angles(0, 0, math.rad(90)) - Vector3.new(0, 2.8, 0)
								end

								RunService.Heartbeat:Connect(f24)
								local v289 = v11
								local v290 = f262
								local v291 = f263
								f24 = "Proximity"
								local v292 = f262
								local v293 = f263
								local function f265()
								end
								f9(f24, f265)
								local v294 = LocalPlayer
								local v295 = t25
								local v296 = f135
								local v297 = f136
								local v298 = f132
								local v299 = f157

								f24 = function()
									while true do
										task.wait(0.2)
										if ProximityAPActive then
											local t1 = v294.Character
											if t1 then
												t1 = t1:FindFirstChild("HumanoidRootPart")
											end
											if t1 then
												for _, t2 in ipairs(v295:GetPlayers()) do
													if not (t2 == v294 or not t2.Character or
														not t2.Character:FindFirstChild("HumanoidRootPart") or (v296(t2) or v297(t2))) then
														local Magnitude3 = (t2.Character.HumanoidRootPart.Position - t1.Position).Magnitude
														local v1 = t2.ProximityRange
														if not v1 then
															v1 = 15
														end
														if Magnitude3 <= v1 then
															local t3 = {}
															for _, v2 in ipairs(AP_ALL_COMMANDS) do
																if not v298(v2) then
																	table.insert(t3, v2)
																end
															end
															for v3, v4 in ipairs(t3) do
																local v5 = v3
																local v6 = t2
																local v7 = v4

																local function f266()
																	while 367 do
																	end
																	task.wait((v5 - 1) * 0.01)
																	v299(v6, v7)
																end

																task.spawn(f266)
															end
														end
													end
												end
											end
										end
									end
								end

								task.spawn(f24)
								local v300 = f3

								f24 = function()
									while true do
										task.wait(1)
										if t2.AutoResetBalloon then
											for _, t1 in ipairs(v300:GetDescendants()) do
												local v1 = t1:IsA("TextLabel")
												if not v1 then
													v1 = t1:IsA("TextButton")
												end
												if v1 then
													v1 = t1.Text
												end
												if v1 and
													string.find(v1, "ran \"balloon\" on you") then
													v15(true)
													break
												end
											end
										end
									end
								end

								task.spawn(f24)
								local v301 = f161
								local v302 = f3

								f24 = function()
									local f267 = setmetatable
									local v1 = {}
									local v2 = { __mode = "k" }
									f267 = f267(v1, v2)
									local v3 = f267

									v1 = function(p1)
										if v3[p1] then
											return
										end
										v3[p1] = true
										if t2.AutoKickOnSteal then
											local _ = string.find
											local _ = string.lower
											local _ = tostring
											local v4 = p1.Text
											if not v4 then
												v4 = ""
											end
											if string.find(
												string.lower(tostring(v4)),
												"you stole",
												1,
												true
											) then
												local f268 = v301
												local _ = tostring
												local v5 = p1.Text
												if not v5 then
													v5 = ""
												end
												f268(tostring(v5))
												return
											end
										end

										local function f269(...)
											local t1, f270, v6, v7
											local f271 = t2.AutoKickOnSteal
											if f271 then
												f271 = t1.find
												local _ = string.lower
												local _ = tostring
												local v8 = p1.Text
												if not v8 then
													v8 = ""
												end
												f270 = string.lower(tostring(v8))
												t1 = "you stole"
												v6 = 1
												v7 = true
											end
											while true do
												f271 = f271(f270, t1, v6, v7)
												if f271 then
													f271 = v301
													f270 = tostring
													t1 = p1.Text
													if not t1 then
														f271(f270(""))
														return
													end
													v6 = 1
													v7 = true
												end
											end
										end

										p1:GetPropertyChangedSignal("Text"):Connect(f269)
									end

									local v9 = v1

									v2 = function(p2)
										ipairs(p2:GetDescendants())

										local function f272(p3)
											if p3:IsA("TextLabel") then
											end
											while p3:IsA("TextButton") or not p3:IsA("TextBox") do
											end
											v9(p3)
										end

										p2.DescendantAdded:Connect(f272)
									end

									ipairs(v302:GetChildren())
									local v10 = v2

									local function f273()
										while true do
										end
									end

									v302.ChildAdded:Connect(f273)
								end

								task.spawn(f24)

								f24 = function()
									local function f274()
										return (cloneref(game:GetService("GuiService")))
									end

									local v1 = pcall(f274)
									v1 = v1 and cloneref(game:GetService("GuiService")) or
										game:GetService("GuiService")
									while true do
										if t2.CleanErrorGUIs then
											local v2 = v1

											local function f275()
												v2:ClearError()
											end

											pcall(f275)
										end
										task.wait(0.1)
									end
								end

								task.spawn(f24)
								local ReplicatedStorage2 = ReplicatedStorage
								f24 = ReplicatedStorage2
								local v303 = ReplicatedStorage2.WaitForChild(f24, "Packages")
								f24 = ReplicatedStorage
								local v304 = f24
								f24 = f24.WaitForChild
								f24 = f24(v304, "Datas")
								require(v303:WaitForChild("Synchronizer"))
								require(f24:WaitForChild("Animals"))
								autoStealEnabled = t2.AutoStealEnabled
								if autoStealEnabled == nil then
									autoStealEnabled = true
								end
								instantStealEnabled = t2.InstantStealEnabled
								if instantStealEnabled == nil then
									instantStealEnabled = true
								end
								stealHighestEnabled = t2.StealHighest
								if stealHighestEnabled == nil then
									stealHighestEnabled = true
								end
								stealPriorityEnabled = t2.StealPriority
								stealNearestEnabled = t2.StealNearest
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
								InternalStealCacheData = {}
								_G["table.create"](10)
								f25 = -3.898971
								local v305
								v305.min = Vector3.new(-337.448303, f25, -122.397758)
								f25 = -3.898971
								v305.max = Vector3.new(-328.004578, f25, 242.625626)
								f25 = -327.25766
								local v306
								v306.min = Vector3.new(f25, -3.899109, -122.228622)
								f25 = -320.600891
								v306.max = Vector3.new(f25, -3.899109, 242.612259)
								f25 = Vector3
								f25 = f25.new
								f25 = f25(-319.783386, -3.89897, -122.227089)
								f25 = Vector3
								f25 = f25.new
								f25 = f25(-312.908325, -3.89897, 242.585617)
								f25 = {}
								f25.min = Vector3.new(-312.445648, -3.899108, -122.389832)
								f25.max = Vector3.new(-305.489899, -3.899108, 242.456818)
								local v307
								v307.min = Vector3.new(-305.037048, -3.89897, -122.230743)
								v307.max = Vector3.new(-293.957489, -3.89897, 242.606873)
								local v308
								v308.min = Vector3.new(-491.448608, -3.898972, -122.253258)
								v308.max = Vector3.new(-481.811737, -3.898972, 242.615005)
								local v309
								v309.min = Vector3.new(-498.971069, -3.89897, -122.382767)
								v309.max = Vector3.new(-491.74884, -3.89897, 242.612061)
								local v310
								v310.min = Vector3.new
								v310.max = Vector3.new
								local v311
								v311.min = Vector3.new
								v311.max = Vector3.new
								local v312
								v312.min = Vector3.new
								v312.max = Vector3.new
								f25 = 0

								function _G.getSafePollRate()
									while not (os.clock() < f25) do
									end
									return 0.27
								end

								function _G.triggerSafePollBoost()
									f25 = os.clock() + 3
								end

								local v313 = f5

								local function f276(p1, p2, p3, p4)
									local v1
									if p3 then
										v1 = p3:gsub("%s+", ""):lower()
									else
										v1 = p3
									end
									if not v1 then
										v1 = ""
									end
									local t1 = {
										gold = Color3.fromRGB(255, 222, 89),
										diamond = Color3.fromRGB(37, 196, 254),
										bloodrot = Color3.fromRGB(145, 0, 27),
										rainbow = Color3.fromRGB(255, 0, 251),
										candy = Color3.fromRGB(255, 70, 246),
										lava = Color3.fromRGB(255, 149, 0),
										galaxy = Color3.fromRGB(170, 60, 255),
										yinyang = Color3.fromRGB(255, 255, 255),
										radioactive = Color3.fromRGB(104, 245, 0),
										cursed = Color3.fromRGB(245, 56, 56),
										divine = Color3.fromRGB(255, 209, 59),
										cyber = Color3.fromRGB(121, 219, 255)
									}
									local v2 = gethui
									v2 = v2 and gethui() or game:GetService("CoreGui")
									local v3 = t1[v1]
									if not v3 then
										v3 = Theme.AccentLight
									end
									local Text2 = Theme.Text
									local v4 = t1[v1]
									if not v4 then
										v4 = Theme.Dim
									end
									local v5
									v5 = (v1 == "" or v1 == "none") and "NORMAL" or p3:upper()
									local XiPriorityAlertTest2 = v2:FindFirstChild("XiPriorityAlertTest")
									if XiPriorityAlertTest2 then
										XiPriorityAlertTest2:Destroy()
									end
									if t2.PrioritySoundAlert and t2.PrioritySoundID and
										t2.PrioritySoundID ~= "" then
										local function f277(...)
											(nil).Parent = nil
											;(nil).Play(nil)
											game:GetService("Debris"):AddItem(nil, 5)
										end

										pcall(f277)
									end
									local v6 = Instance.new("ScreenGui")
									if _G.addLazyUI then
										_G.addLazyUI(v6, true, true)
									end
									v6.Name = "XiPriorityAlertTest"
									v6.ResetOnSpawn = false
									v6.DisplayOrder = 999
									v6.Parent = v2
									local v7 = Instance.new("Frame")
									v7.Size = UDim2.new(0, 360, 0, 70)
									v7.Position = UDim2.new(0.5, 0, 0, -100)
									v7.AnchorPoint = Vector2.new(0.5, 0)
									v7.BackgroundColor3 = Theme.MainBackground
									v7.BackgroundTransparency = 0.08
									v7.BorderSizePixel = 0
									v7.Parent = v313(v6)
									local v8 = Instance.new("UIGradient", v7)
									local new = ColorSequence.new
									local v9 = _G["table.create"](1)
									ColorSequenceKeypoint.new(0, Theme.MainBackground)
									ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 244, 249))
									v8.Color = new(v9)
									v8.Rotation = 90
									Instance.new("UICorner", v7).CornerRadius = UDim.new(0, 10)
									local v10 = Instance.new("UIStroke", 10)
									v10.Color = v3
									v10.Thickness = 1.5
									v10.Transparency = 0.12
									local v11 = Instance.new("Frame", v7)
									v11.Size = UDim2.new(1, -24, 0, 3)
									v11.Position = UDim2.new(0.5, 0, 1, -4)
									v11.AnchorPoint = Vector2.new(0.5, 1)
									v11.BackgroundColor3 = v3
									v11.BorderSizePixel = 0
									Instance.new("UICorner", v11).CornerRadius = UDim.new(1, 0)
									local v12 = Instance.new("ViewportFrame", v7)
									v12.Size = UDim2.new(0, 56, 0, 56)
									v12.Position = UDim2.new(0, 12, 0.5, -2)
									v12.AnchorPoint = Vector2.new(0, 0.5)
									v12.BackgroundTransparency = 1
									v12.BorderSizePixel = 0
									v12.Ambient = Color3.fromRGB(255, 255, 255)
									v12.LightColor = v3
									local v13 = Instance.new("WorldModel", v12)
									local v14 = Instance.new("Camera", v12)
									v12.CurrentCamera = v14

									local function f278()
										local v15 = ReplicatedStorage:FindFirstChild("Models")
										if v15 then
											v15 = ReplicatedStorage.Models:FindFirstChild("Animals")
										end
										local v16 = ReplicatedStorage:FindFirstChild("Animations")
										if v16 then
											v16 = ReplicatedStorage.Animations:FindFirstChild("Animals")
										end
										local v17
										if v15 and p1 then
											local t2 = v15:FindFirstChild(p1)
											if not t2 then
												for _, t3 in pairs(v15:GetChildren()) do
													if t3.Name:lower() == p1:lower() then
														t2 = t3
														break
													end
												end
											end
											if t2 then
												local Clone = t2:Clone()
												Clone.Parent = v13
												local t4, _
												_, t4 = Clone:GetBoundingBox()
												local v18 = math.max(t4.X, t4.Y, t4.Z)
												if Clone.PrimaryPart then
													Clone:SetPrimaryPartCFrame(CFrame.new(0, 0, 0))
												else
													Clone:MoveTo(Vector3.new(0, 0, 0))
												end
												local v19 = Vector3.new(0, t4.Y / 2, -(v18 * 0.85))
												v14.CFrame = CFrame.lookAt(v19, Vector3.new(0, 0, 0))
												if v16 then
													local v20 = v16:FindFirstChild(t2.Name)
													if v20 then
														v20 = v20:FindFirstChild("Idle")
													end
													if v20 and v20:IsA("Animation") then
														local FindFirstChildOfClass8 = Clone:FindFirstChildOfClass("Humanoid")
														local FindFirstChildOfClass9 = Clone:FindFirstChildOfClass("AnimationController")
														if FindFirstChildOfClass8 then
															v17 = FindFirstChildOfClass8:FindFirstChildOfClass("Animator")
															if not v17 then
																v17 = Instance.new("Animator", FindFirstChildOfClass8)
															end
														elseif FindFirstChildOfClass9 then
															v17 = FindFirstChildOfClass9:FindFirstChildOfClass("Animator")
															if not v17 then
																v17 = Instance.new("Animator", FindFirstChildOfClass9)
															end
														else
															local v21 = Instance.new("AnimationController", Clone)
															v17 = Instance.new("Animator", v21)
														end
														local LoadAnimation2 = v17:LoadAnimation(v20)
														LoadAnimation2.Looped = true
														LoadAnimation2:Play(0)

														local function f279()
															if LoadAnimation2.IsPlaying then
																LoadAnimation2.TimePosition = 0.2
															end
														end

														task.delay(0.01, f279)
													end
												end
											end
										end
									end

									task.spawn(f278)
									local v22 = Instance.new("TextLabel", v7)
									v22.Size = UDim2.new(1, -85, 0, 20)
									v22.Position = UDim2.new(0, 76, 0, 12)
									v22.BackgroundTransparency = 1
									v22.Text = p1 .. " â€¢ " .. p2
									v22.Font = Enum.Font.GothamBlack
									v22.TextSize = 13
									v22.TextColor3 = Text2
									v22.TextXAlignment = Enum.TextXAlignment.Left
									local v23 = Instance.new("TextLabel", v7)
									v23.Size = UDim2.new(1, -85, 0, 16)
									v23.Position = UDim2.new(0, 76, 0, 32)
									v23.BackgroundTransparency = 1
									v23.Text = v5 .. " (Owner: " .. p4 .. ")"
									v23.Font = Enum.Font.GothamBold
									v23.TextSize = 10
									v23.TextColor3 = v4
									v23.TextXAlignment = Enum.TextXAlignment.Left
									local TweenService2 = TweenService
									local Create = TweenService2.Create
									local v24 = TweenInfo.new(
										0.5,
										Enum.EasingStyle.Exponential,
										Enum.EasingDirection.Out
									)
									local t5 = { Position = UDim2.new(0.5, 0, 0, 20) }
									Create(TweenService2, v7, v24, t5):Play()

									local function f280()
										if v7 and v7.Parent then
											local TweenService3 = TweenService
											local Create2 = TweenService3.Create
											local v25 = v7
											local v26 = TweenInfo.new(
												0.4,
												Enum.EasingStyle.Back,
												Enum.EasingDirection.In
											)
											local t6 = { Position = UDim2.new(0.5, 0, 0, -100) }
											Create2(TweenService3, v25, v26, t6):Play()
											task.wait(0.45)
											if v6 and v6.Parent then
												v6:Destroy()
											end
										end
									end

									task.delay(4, f280)
								end

								f24 = 99999
								local v314 = f276

								local function f281()
									while true do
										task.wait(1.5)

										local function f282()
											local AllAnimalsCache = SharedState.AllAnimalsCache
											if not (AllAnimalsCache and #AllAnimalsCache ~= 0) then
												return
											end
											local t1 = nil
											local v1 = 99999
											for _, t2 in ipairs(AllAnimalsCache) do
												local v2, v3, f283
												f283, v3, v2 = ipairs(priorityList)
												local _leave45 = false
												while true do
													local v4
													v2, v4 = f283(v3, v2)
													if v2 == nil then
														break
													end
													if v4:lower() == t2.name:lower() then
														_leave45 = true
														break
													end
												end
												if not _leave45 then
													v2 = nil
												end
												if v2 and v2 < v1 then
													t1 = t2
													v1 = v2
												end
											end
											if t1 and v1 < f24 and
												not (t1.owner == v6.Name or
													t1.owner == v6.DisplayName) then
												f24 = v1
												v314(
													t1.name,
													t1.genText,
													t1.mutation,
													t1.owner
												)
											end
										end

										pcall(f282)
									end
								end

								task.spawn(f281)
								local v315 = t25

								local function f284(...)
									local function f285()
										return (ReplicatedStorage:WaitForChild("Packages", 5))
									end

									local v1, v2
									v2, v1 = pcall(f285)
									if not (v2 and v1) then
										return
									end

									local function f286()
										return (ReplicatedStorage:WaitForChild("Datas", 5))
									end

									local v3, v4
									v4, v3 = pcall(f286)
									if not (v4 and v3) then
										return
									end

									local function f287()
										return (ReplicatedStorage:WaitForChild("Utils", 5))
									end

									local v5, v6
									v6, v5 = pcall(f287)
									if not (v6 and v5) then
										return
									end

									local function f288()
										return (require(v3:WaitForChild("Animals")))
									end

									local v7, v8
									v8, v7 = pcall(f288)
									if not v8 then
										return
									end
									local _xenAnimShim = _G._xenAnimShim

									local function f289()
										return (require(v5:WaitForChild("NumberUtils")))
									end

									local v9, v10
									v10, v9 = pcall(f289)
									local v11 = nil
									if not v10 then
										return
									end
									local t1 = {}
									local t2 = {}
									v11 = false

									local function f290(p1)
										if not p1 then
											return ""
										end
										local v12 = ""
										for v13, t3 in pairs(p1) do
											if type(t3) == "table" then
												v12 = v12 ..
													tostring(v13) ..
														tostring(t3.Index) .. tostring(t3.Mutation)
											end
										end
										return v12
									end

									local function f291(...)
										while true do
										end
										local v14 = ...

										local function f292(...)
											local v15, f293, v16, v17
											local v18 = _G.SXE_GetPlotChannel(v14.Name)
											if not v18 then
												return
											end
											local t4 = _G.SXE_ChGet(v18, "AnimalList")
											local t5 = _G.SXE_ChGet(v18, "Owner")
											if not (t5 and t5.Name and
												v315:FindFirstChild(t5.Name)) then
												t2[v14.Name] = nil
												local v19 = #t1 - -1
												while true do
													v19 = v19 + -1
													if not (1 <= v19) then
														break
													end
													if t1[v19].plot == v14.Name then
														table.remove(t1, v19)
													end
												end
												return
											end
											if not t4 then
												t2[v14.Name] = nil
												local v20 = #t1 - -1
												while true do
													v20 = v20 + -1
													if not (1 <= v20) then
														break
													end
													if t1[v20].plot == v14.Name then
														table.remove(t1, v20)
													end
												end
												return
											end
											local Name2 = t5.Name
											local v21 = f290(t4)
											if t2[v14.Name] == v21 then
												return
											end
											local v22 = #t1 - -1
											while true do
												v22 = v22 + -1
												if not (1 <= v22) then
													break
												end
												f293 = t1[v22].plot
												v16 = v14.Name
												if f293 == v16 then
													f293 = table.remove
													v16 = t1
													f293(v16, v22)
													v17 = v22
													v15 = v22
												else
													v15 = v22
												end
											end
											local t6, v23, _
											_, v23, t6 = pairs(t4)
											local v24 = nil
											local t7 = v9
											v24 = t7
											local v25 = t7.ToString(v24, nil) .. "/s"
											v24 = 0
											local v26 = v15

											local function f294(...)
												local v27 = nil
												local v28 = true
												if not v28 then
													while true do
														v27 = v27:GetValue(v26, t6.Mutation, t6.Traits, nil)
														if not v27 then
															break
														end
														v28 = nil
													end
												end
												v24 = 0
											end

											pcall(f294)
											if type(v24) ~= "number" then
												v24 = 0
											end
											local v29 = false
											if type(t6.Machine) == "table" then
												local Type = t6.Machine.Type
												if (Type == "Fuse" or Type == "Duel" or
													(Type == "Trade" or Type == "Crafting")) and
													t6.Machine.Active == true then
													v29 = true
												end
											end
											local _ = table.insert
											local v30 = t1
											local t8 = {}
											local v31 = f293.DisplayName
											if not v31 then
												v31 = v15
											end
											t8.name = v31
											t8.index = v15
											t8.genText = "$" .. v25
											t8.genValue = nil
											t8.petValue = v24
											t8.mutation = v16
											t8.traits = v17
											t8.owner = Name2
											t8.plot = v14.Name
											t8.slot = tostring(v23)
											t8.uid = v14.Name .. "_" .. tostring(v23)
											t8.fuse = v29
											table.insert(v30, t8)
											t2[v14.Name] = v21
											v11 = true
										end

										;(nil)(f292)
									end

									local Plots5 = Workspace:WaitForChild("Plots", 8)
									if Plots5 then
										local function f295(...)
											if not v11 then
												return
											end

											local function f296(p2, p3)
												local v32
												v32 = p3.genValue < p2.genValue
												return v32
											end

											table.sort(t1, f296)
											v11 = false
											SharedState.AllAnimalsCache = t1
											while true do
												SharedState.ListNeedsRedraw = true
											end
										end

										SharedState.AllAnimalsCache = t1

										local function f297(p4)
											t2[p4.Name] = nil
											local v33 = #t1 - -1
											while true do
												v33 = v33 + -1
												if not (1 <= v33) then
													break
												end
												if t1[v33].plot == p4.Name then
													table.remove(t1, v33)
												end
											end
											SharedState.ListNeedsRedraw = true
										end

										Plots5.ChildRemoved:Connect(f297)

										local function f298()
											local v34 = true
											while true do
												local v35 = os.clock()
												for _, v36 in ipairs(Plots5:GetChildren()) do
													f291(v36)
													if v34 and 0.006 < os.clock() - v35 then
														f295()
														task.wait()
														v35 = os.clock()
													end
												end
												f295()
												if v34 then
													SharedState.InitialScanComplete = true
												end
												v34 = false
												task.wait(0.15)
											end
										end

										task.spawn(f298)
									end
								end

								task.spawn(f284)
								local v316 = LocalPlayer
								local v317 = f237
								local v318 = f23
								local v319 = v26

								local function f299()
									local GetAttribute = v316:GetAttribute("Stealing")
									if FloatState.active and not GetAttribute then
										v317(false)
									end
									if _G.AutoInvisDuringSteal then
										if GetAttribute and not _G.invisibleStealEnabled and _G._forceInvisToggle then
											local function f300(...)
												local f301, v1
												while true do
													local _continue48 = false
													local v2 = 11893
													local _leave47 = false
													while true do
														v2 = 187
														if v2 then
															_leave47 = true
															break
														end
													end
													if not _leave47 then
														v1 = v316
														f301 = v1:GetAttribute("Stealing")
														if f301 then
															f301 = _G.invisibleStealEnabled
															if f301 then
																_continue48 = true
															else
																f301 = pcall
																v1 = _G._forceInvisToggle
															end
														else
															_continue48 = true
														end
													end
													if _continue48 then
														continue
													end
													f301(v1)
													return
												end
											end

											task.defer(f300)
										elseif not (GetAttribute or not _G.invisibleStealEnabled or
											not _G._forceInvisToggle) then
											task.wait(0.3)
											if not v316:GetAttribute("Stealing") then
												pcall(_G._forceInvisToggle)
											end
										end
									end
									if GetAttribute and t2.AutoUnlockOnSteal then
										local v3 = v316.Character
										if v3 then
											v3 = v316.Character:FindFirstChild("HumanoidRootPart")
										end
										if v3 then
											local v4 = v318()

											local function f302()
												task.wait(0.1)
												pcall(v319, v4)
											end

											task.spawn(f302)
										end
									end
								end

								LocalPlayer:GetAttributeChangedSignal("Stealing"):Connect(f299)
								local v320 = f234
								local v321 = f235

								local function f303()
									task.wait(0.5)
									local f304 = FloatState.active
									if f304 then
										v320()
										f304 = v321
									end
									f304()
								end

								LocalPlayer.CharacterAdded:Connect(f303)

								function findAdorneeGlobal(p1)
									if not p1 then
										return nil
									end
									local v1 = Workspace:FindFirstChild("Plots")
									if v1 then
										v1 = Workspace.Plots:FindFirstChild(p1.plot)
									end
									if v1 then
										local AnimalPodiums2 = v1:FindFirstChild("AnimalPodiums")
										if AnimalPodiums2 then
											local FindFirstChild7 = AnimalPodiums2:FindFirstChild(p1.slot)
											if FindFirstChild7 then
												local Base = FindFirstChild7:FindFirstChild("Base")
												if Base then
													local Spawn = Base:FindFirstChild("Spawn")
													if Spawn then
														return Spawn
													end
													local v2 = Base:FindFirstChildWhichIsA("BasePart")
													if not v2 then
														v2 = Base
													end
													return v2
												end
											end
										end
									end
									return nil
								end

								function getClosestBaseSign(p1)
									if not (p1 and p1:IsA("BasePart")) then
										return nil
									end
									local v1 = nil
									local v2 = math.huge
									for _, t1 in ipairs(Workspace:GetDescendants()) do
										if t1:IsA("TextLabel") then
											local _ = tostring
											local v3 = t1.Text
											if not v3 then
												v3 = ""
											end
											local v4 = tostring(v3)
											if not (v4 == "" or not v4:lower():find("base", 1, true)) then
												local FindFirstAncestorWhichIsA = t1:FindFirstAncestorWhichIsA("SurfaceGui")
												if FindFirstAncestorWhichIsA then
													local t2 = FindFirstAncestorWhichIsA.Adornee
													if not t2 then
														t2 = FindFirstAncestorWhichIsA.Parent
													end
													if t2 and t2:IsA("BasePart") then
														local Magnitude4 = (t2.Position - p1.Position).Magnitude
														if Magnitude4 < v2 then
															v1 = t2
															v2 = Magnitude4
														end
													end
												end
											end
										end
									end
									return v1
								end

								function riseToY(p1, p2)
									if not p1 then
										return
									end
									local v1 = os.clock()
									while p1.Parent and p1.Position.Y < p2 do
										local v2 = p1.Position.Y
										local v3 = math.clamp((p2 - v2) * 20, 280, 310)
										p1.AssemblyLinearVelocity = Vector3.new(
											p1.AssemblyLinearVelocity.X,
											v3,
											p1.AssemblyLinearVelocity.Z
										)
										if 3 < os.clock() - v1 then
											break
										end
										RunService.Heartbeat:Wait()
									end
									p1.AssemblyLinearVelocity = Vector3.new(
										p1.AssemblyLinearVelocity.X,
										0,
										p1.AssemblyLinearVelocity.Z
									)
								end

								function equipTpToolAndWait(p1)
									if not p1 then
										return nil
									end
									local Parent = p1.Parent
									local v1 = t2.TpSettings.Tool
									if not v1 then
										v1 = "Flying Carpet"
									end
									local FindFirstChild8 = v6.Backpack:FindFirstChild(v1)
									if not (FindFirstChild8 or not Parent) then
										FindFirstChild8 = Parent:FindFirstChild(v1)
									end
									if FindFirstChild8 then
										p1:EquipTool(FindFirstChild8)
										task.wait(0.02)
									end
									return FindFirstChild8
								end

								function walkForward(p1)
									local Character10 = v6.Character
									local Humanoid2 = Character10:FindFirstChild("Humanoid")
									local HumanoidRootPart4 = Character10:FindFirstChild("HumanoidRootPart")
									local PlayerScripts = v6:WaitForChild("PlayerScripts")
									local v1 = "PlayerModule"
									local GetControls = require(PlayerScripts:WaitForChild(v1)):GetControls()
									local LookVector = HumanoidRootPart4.CFrame.LookVector
									v1 = GetControls
									GetControls.Disable(v1)
									v1 = nil
									local v2 = os.clock()

									local function f305()
										os.clock()
										while true do
										end
									end

									v1 = RunService.RenderStepped:Connect(f305)
								end

								function waitSecondsHeartbeat(p1)
									local v1 = 0
									while true do
										if v1 < p1 then
											v1 = v1 + RunService.Heartbeat:Wait()
										end
									end
								end

								function waitUntilHeartbeat(...)
									repeat
										local _, f306
										f306, _ = ...
									until f306()
									return true
								end

								local v322 = _G["table.create"](2)
								local v323
								v323.pos = Vector3.new(-410.65, -5.68, -46.1)
								f25 = 168.89
								local v324
								v324.pos = Vector3.new(-410.91, -5.68, f25)
								TP_V2_MED_POINTS = v322
								local v325 = _G["table.create"](12)
								local v326
								v326.pos = Vector3.new(-488.88, 15, 196.38)
								f25 = 138.13
								local v327
								v327.pos = Vector3.new(-487.79, 15, f25)
								f25 = 15
								local v328
								v328.pos = Vector3.new(-489.38, f25, 89.23)
								f25 = -489.69
								local v329
								v329.pos = Vector3.new(f25, 15, 30.98)
								f25 = Vector3
								f25 = f25.new
								f25 = f25(-488.75, 15, -17.95)
								f25 = { name = "TP6" }
								f25.pos = Vector3.new(-490, 15, -75.9)
								f25.facing = "front"
								local v330
								v330.pos = Vector3.new(-331.75, 15, -75.8)
								local v331
								v331.pos = Vector3.new(-329.98, 15, -18.16)
								local v332
								v332.pos = Vector3.new(-330.04, 15, 31.14)
								local v333
								v333.pos = Vector3.new
								local v334
								v334.pos = Vector3.new
								local v335
								v335.pos = Vector3.new
								TP_V2_SECOND_FLOOR_POINTS = v325
								local t58 = {}
								local t59 = {
									TP6 = true,
									TP7 = true,
									TP8 = true,
									TP10 = true,
									TP12 = true,
									TP5 = true,
									TP3 = true,
									TP1 = true
								}
								t58.MED1 = t59
								local t60 = {
									TP1 = true,
									TP2 = true,
									TP4 = true,
									TP6 = true,
									TP7 = true,
									TP9 = true,
									TP11 = true,
									TP12 = true
								}
								t58.MED2 = t60
								TP_V2_ALLOWED_BY_MED = t58

								function flatDistance(p1, p2)
									return (Vector3.new(p1.X, 0, p1.Z) - Vector3.new(p2.X, 0, p2.Z)).Magnitude
								end

								function _G._isTargetPlotUnlocked(p1)
									local function f307(...)
										local Plots6 = Workspace:FindFirstChild("Plots")
										if not Plots6 then
											return false
										end
										local FindFirstChild9 = Plots6:FindFirstChild(p1)
										if not FindFirstChild9 then
											return false
										end
										local Unlock = FindFirstChild9:FindFirstChild("Unlock")
										if not Unlock then
											return true
										end
										local t1 = {}
										local v1, v2, f308
										f308, v2, v1 = pairs(Unlock:GetChildren())
										local t2 = nil
										while true do
											local t3
											v1, t3 = f308(v2, v1)
											if v1 == nil then
												break
											end
											t2 = nil
											if t3:IsA("Model") then
												local v3 = t3

												local function f309()
													v3:GetPivot()
													while true do
													end
												end

												pcall(f309)
											elseif t3:IsA("BasePart") then
												t2 = t3.Position
											end
											if t2 then
												local _ = table.insert
												local t4 = { Object = t3, Height = t2.Y }
												table.insert(t1, t4)
											end
										end

										local function f310(...)
											while true do
											end
											local t5, t6
											t6, t5 = ...
											local v4
											v4 = t6.Height < t5.Height
											return v4
										end

										table.sort(t1, f310)
										if #t1 == 0 then
											return true
										end
										local Object = t1[1].Object
										t2 = Object
										local v5, f311
										f311, v5, t2 = ipairs(Object.GetDescendants(t2))
										local v6 = t2
										while true do
											local v7
											v6, v7 = f311(v5, v6)
											if v6 == nil then
												break
											end
											t2 = v7
											if t2:IsA("ProximityPrompt") and t2.Enabled then
												return false
											end
										end
										t2 = Object
										local v8, f312
										f312, v8, t2 = ipairs(Object.GetChildren(t2))
										local v9 = t2
										while true do
											local v10
											v9, v10 = f312(v8, v9)
											if v9 == nil then
												break
											end
											t2 = v10
											if t2:IsA("ProximityPrompt") and t2.Enabled then
												return false
											end
										end
										return true
									end

									local v11, v12
									v12, v11 = pcall(f307)
									v12 = v12 and v11 or false
									return v12
								end

								function getClosestBaseSignToPosition(p1)
									local v1 = nil
									local v2 = math.huge
									for _, t1 in ipairs(Workspace:GetDescendants()) do
										if t1:IsA("TextLabel") then
											local _ = tostring
											local v3 = t1.Text
											if not v3 then
												v3 = ""
											end
											local v4 = tostring(v3)
											if not (v4 == "" or not v4:lower():find("base", 1, true)) then
												local FindFirstAncestorWhichIsA2 = t1:FindFirstAncestorWhichIsA("SurfaceGui")
												if FindFirstAncestorWhichIsA2 then
													local t2 = FindFirstAncestorWhichIsA2.Adornee
													if not t2 then
														t2 = FindFirstAncestorWhichIsA2.Parent
													end
													if t2 and t2:IsA("BasePart") then
														local Magnitude5 = (t2.Position - p1).Magnitude
														if Magnitude5 < v2 then
															v1 = t2
															v2 = Magnitude5
														end
													end
												end
											end
										end
									end
									return v1
								end

								function getNearestTeleportV2MedPoint()
									local huge = math.huge
									ipairs(TP_V2_MED_POINTS)
									return nil, huge
								end

								function getBestTeleportV2SecondFloorPoint(p1, p2)
									local v1, v2
									if p1 then
										v2 = p1.pos
									else
										v2 = p1
									end
									if v1 then
										v1 = p1.name
									end
									if not (v2 and v1) then
										return nil
									end
									local t1 = TP_V2_ALLOWED_BY_MED[v1]
									if not t1 then
										return nil
									end
									local v3 = nil
									local v4 = math.huge
									local v5 = math.huge
									for _, t2 in ipairs(TP_V2_SECOND_FLOOR_POINTS) do
										if t1[t2.name] then
											local v6 = flatDistance(v2, t2.pos)
											local v7 = flatDistance(p2, t2.pos)
											if v7 < v5 or
												math.abs(v7 - v5) <= 0.001 and v6 < v4 then
												v3 = t2
												v4 = v6
												v5 = v7
											end
										end
									end
									return v3, v4, v5
								end

								local v336 = RaycastParams.new()
								f25 = Enum
								f25 = f25.RaycastFilterType
								f25 = f25.Exclude
								v336.FilterType = f25
								local v337 = v336

								f25 = function(p1, p2, p3, p4, p5)
									if not (p1 and p1.Parent) then
										return false
									end
									local FindFirstChildOfClass10 = p1.Parent:FindFirstChildOfClass("Humanoid")
									local v1 = nil
									if FindFirstChildOfClass10 then
										local FindFirstChildOfClass11 = FindFirstChildOfClass10:FindFirstChildOfClass("Animator")
										if FindFirstChildOfClass11 then
											local function f313()
												local function f314()
													ipairs(FindFirstChildOfClass11:GetPlayingAnimationTracks())
												end

												pcall(f314)
											end

											v1 = RunService.Heartbeat:Connect(f313)
										end
									end
									v337.FilterDescendantsInstances = _G["table.create"](1)
									local v2 = os.clock()
									local v3
									while p1.Parent and not (15 < os.clock() - v2) and
										not v6:GetAttribute("Stealing") do
										local Position4 = p1.Position
										local t1 = Vector3.new(
											p2.X - Position4.X,
											0,
											p2.Z - Position4.Z
										)
										local Magnitude6 = t1.Magnitude
										if Magnitude6 < 4 then
											break
										end
										local Unit = t1.Unit
										local v4 = 0
										if p2.Y <= 10 then
											local v5 = p2.Y + 3.5
											if p4 and Magnitude6 <= 60 then
												local v6 = math.clamp((60 - Magnitude6) / 40, 0, 1)
												v5 = p2.Y + 3.5 + (p4 - p2.Y) * v6
											end
											local v7 = p2.Y + 35
											local v8 = false
											for _, v9 in ipairs((_G["table.create"](4))) do
												local Raycast = Workspace:Raycast(
													Position4 + Vector3.new(0, v9, 0),
													Unit * 80,
													v337
												)
												if Raycast and Raycast.Instance and
													(Raycast.Instance.CanCollide and
														5 < Raycast.Instance.Position.Y + Raycast.Instance.Size.Y / 2 - p2.Y) then
													v8 = true
													break
												end
											end
											if 25 < Magnitude6 and (v8 or Position4.Y < v7 - 5) then
												v4 = Position4.Y < v7 and 200 or 0
											elseif Magnitude6 <= 25 then
												v4 = math.clamp((v5 - Position4.Y) * 4, -150, 0)
											elseif v5 + 5 < Position4.Y then
												v4 = 0
											else
												p1.CFrame = CFrame.new(p1.Position.X, v5, p1.Position.Z) * (p1.CFrame - p1.CFrame.Position)
												v4 = 0
											end
										else
											local Raycast2 = Workspace:Raycast(Position4, Unit * 20, v337)
											if Raycast2 then
												v4 = 200
											end
											local Raycast3 = Workspace:Raycast(Position4, Vector3.new(0, -12, 0), v337)
											if Raycast3 and
												Position4.Y - Raycast3.Position.Y < 5 then
												v4 = math.max(v4, 100)
											end
											if not (Raycast2 or not (p2.Y < Position4.Y - 3)) then
												v4 = math.clamp((p2.Y - Position4.Y) * 3, -120, 0)
											end
										end
										if p5 then
											v3 = p5
										else
											v3 = t2.TpSettings.FlyTPSpeed
										end
										if not v3 then
											v3 = 160
										end
										p1.AssemblyLinearVelocity = Unit * v3 + Vector3.new(0, v4, 0)
										p1.AssemblyAngularVelocity = Vector3.zero
										RunService.Heartbeat:Wait()
									end
									if v1 then
										v1:Disconnect()
									end
									if not p1.Parent then
										return false
									end
									p1.AssemblyLinearVelocity = Vector3.zero
									p1.AssemblyAngularVelocity = Vector3.zero
									if not p4 then
										p4 = p2.Y
									end
									local v10 = Vector3.new(p2.X, p4, p2.Z)
									local lookAt = CFrame.lookAt
									if not p3 then
										p3 = p1.CFrame.LookVector
									end
									p1.CFrame = lookAt(v10, v10 + p3)
									p1.AssemblyLinearVelocity = Vector3.zero
									return true
								end

								flyForwardTo = f25

								f25 = function(...)
									repeat
										local v1, v2
										v2, v1 = ...
									until v2 and not v1
								end

								prepMiniTpTool = f25
								local v338 = f109

								f25 = function(...)
									local t1 = nil
									local AllAnimalsCache2 = SharedState.AllAnimalsCache
									if not (AllAnimalsCache2 and #AllAnimalsCache2 ~= 0) then
										return nil
									end
									local t2 = get_all_pets()
									if manuallySelectedUID then
										for _, t3 in ipairs(AllAnimalsCache2) do
											if t3.uid == manuallySelectedUID and t3.owner ~= v6.Name then
												return t3
											end
										end
									end
									local v1, v2, f315
									f315, v2, v1 = ipairs(priorityList)
									local v3, v4
									while true do
										local v5
										v1, v5 = f315(v2, v1)
										if v1 == nil then
											break
										end
										local lower7 = v5:lower()
										local t4 = nil
										local v6 = math.huge
										for _, t5 in ipairs(AllAnimalsCache2) do
											if t5 and t5.name and
												(t5.name:lower() == lower7 or
													t5.index and t5.index:lower() == lower7) then
												local owner = t5.owner
												t1 = v6.Name
												if owner ~= t1 then
													local v7 = math.huge
													local t6 = v6.Character
													if t6 then
														t1 = t6
														t6 = t6:FindFirstChild("HumanoidRootPart")
													end
													if t6 then
														v3 = "Plots"
														t1 = Workspace:FindFirstChild(v3)
														if t1 then
															v3 = t1
															v4 = t1.FindFirstChild(v3, t5.plot)
														else
															v4 = t1
														end
														if v4 then
															v3 = nil
															local v8 = v4

															local function f316()
																v3 = v8:GetPivot().Position
															end

															pcall(f316)
															if v3 then
																v7 = (t6.Position - v3).Magnitude
															end
														end
													end
													if t4 then
														t1 = t5.genValue
														if not t1 then
															t1 = 0
														end
														local v9 = t4.genValue
														if not v9 then
															v9 = 0
														end
														if v9 < t1 then
															v6 = v7
															t4 = t5
														elseif t1 == v9 and v7 < v6 then
															v6 = v7
															t4 = t5
														end
													else
														v6 = v7
														t4 = t5
													end
												end
											end
										end
										if t4 then
											return t4
										end
									end
									local v10 = t2.StealNearest
									v10 = v10 and t2.TpSettings.MinGenForGrab or
										t2.TpSettings.MinGenForTp
									local _ = math.max
									local v11 = v338(v10)
									if not v11 then
										v11 = 0
									end
									local v12 = math.max(10000000, v11)
									local v13 = nil
									local v14 = math.huge
									local v15, v16, f317
									f317, v16, v15 = ipairs(AllAnimalsCache2)
									local v17 = t1
									while true do
										local t7
										v15, t7 = f317(v16, v15)
										if v15 == nil then
											break
										end
										if t7 and t7.owner ~= v6.Name and
											(t7.genValue and v12 <= t7.genValue) then
											local v18 = math.huge
											local t8 = v6.Character
											if t8 then
												t8 = t8:FindFirstChild("HumanoidRootPart")
											end
											if t8 then
												v17 = "Plots"
												local t9 = Workspace:FindFirstChild(v17)
												if t9 then
													v17 = t9
													t9 = t9.FindFirstChild(v17, t7.plot)
												end
												if t9 then
													v17 = nil
													local v19 = t9

													v3 = function()
														v17 = v19:GetPivot().Position
													end

													pcall(v3)
													if v17 then
														v18 = (t8.Position - v17).Magnitude
													end
												end
											end
											if v18 < v14 then
												v13 = t7
												v14 = v18
											end
										end
									end
									if v13 then
										return v13
									end
									if t2.AutoTPHighestGen and t2 and 0 < #t2 then
										return t2[1].animalData
									end
									if t2.AutoTPHighestValue then
										local t10 = get_all_pets_by_value()
										if t10 and 0 < #t10 then
											return t10[1].animalData
										end
									end
									if t2.AutoTPPriority then
										if t2 and 0 < #t2 then
											return t2[1].animalData
										end
										return nil
									end
									if SharedState.SelectedPetData then
										return SharedState.SelectedPetData.animalData
									end
									return nil
								end

								_G["table.create"](4)
								local v339
								v339.coord = Vector3.new
								local v340
								v340.coord = Vector3.new
								local v341
								v341.coord = Vector3.new
								;({}).facing = "SOUTH"
								_G["table.create"](4)
								local v342
								v342.coord = Vector3.new
								local v343
								v343.coord = Vector3.new
								local v344
								v344.coord = Vector3.new
								;({}).facing = "SOUTH"
								_G["table.create"](4)
								local new2 = Vector3.new
								if new2 == nil then
									_continue67 = true
								else
									new2.coord = Vector3.new
									new2.facing = "NORTH"
									local v345
									v345.coord = Vector3.new
									;({}).facing = "SOUTH"
									_G["table.create"](4)
									local v346
									v346.coord = Vector3.new
									local v347
									v347.coord = Vector3.new
									;({}).facing = "SOUTH"
									_G["table.create"](4)
									local v348
									v348.coord = Vector3.new
									local v349
									v349.coord = Vector3.new
									;({}).facing = "SOUTH"
									_G["table.create"](4)
									local v350
									v350.coord = Vector3.new
									local v351
									v351.coord = Vector3.new
									;({}).facing = "SOUTH"
									local f318 = cloneref
									if not f318 then
										f318 = function(p1)
											return p1
										end
									end
									local _ = f318(game:GetService("Players")).LocalPlayer
									local function f319()
									end
									local v352 = f319
									local v353 = f240
									local v354 = f25
									local v355 = f11
									local v356 = f81

									function runAutoSnipe()
										pcall(v352)
										if _G._isTpMoving then
											return
										end
									end

									local v357 = f25
									local v358 = f81

									function tpToBrainrot()
										local v1 = v357()
										if not v1 then
											return
										end
										local Character11 = v6.Character
										local v2
										if Character11 then
											v2 = Character11:FindFirstChild("HumanoidRootPart")
										else
											v2 = Character11
										end
										local t1
										if Character11 then
											t1 = Character11:FindFirstChild("Humanoid")
										else
											t1 = Character11
										end
										if not (v2 and t1 and not (t1.Health <= 0)) then
											return
										end
										local v3 = nil
										for _ = 1, 10 do
											v3 = findAdorneeGlobal(v1)
											if v3 then
												break
											end
											task.wait(0.05)
										end
										if not v3 then
											return
										end
										local v4 = pcall(getfpscap)
										if v4 then
											v4 = getfpscap()
										end
										local v5 = v3
										if not v4 then
											v4 = 60
											v5 = v3
										end
										pcall(setfpscap, 200)
										local v6 = t1
										local v7 = v2

										local function f320()
											local Tool = t2.TpSettings.Tool
											local FindFirstChild10 = v6.Backpack:FindFirstChild(Tool)
											if not FindFirstChild10 then
												FindFirstChild10 = Character11:FindFirstChild(Tool)
											end
											if FindFirstChild10 then
												v6:EquipTool(FindFirstChild10)
											end
											local Position5 = v5.Position
											local v8 = Position5.Y
											local v9 = v7.Position.Y
											local v10 = math.max(v7.Position.Y, Position5.Y) + 20
											if 2 < v8 - v9 or 25 < Position5.Y then
												local v11 = Instance.new("Part")
												v11.Name = "XiTempPlatform"
												v11.Size = Vector3.new(6, 1.5, 6)
												v11.Position = Vector3.new(
													Position5.X,
													Position5.Y - 11,
													Position5.Z
												)
												v11.Color = Color3.fromRGB(30, 30, 30)
												v11.Material = Enum.Material.Neon
												v11.Anchored = true
												v11.CanCollide = false
												pcall(v358, v11)
												v11.Transparency = 0.3
												v11.Parent = Workspace
												v7.AssemblyLinearVelocity = Vector3.zero
												v7.AssemblyAngularVelocity = Vector3.zero
												v7.CFrame = CFrame.new(Position5.X, v10, Position5.Z)
												task.wait(0.03)
												local v12 = CFrame.new(
													Position5.X,
													Position5.Y - 8,
													Position5.Z
												)
												v7.AssemblyLinearVelocity = Vector3.zero
												v7.AssemblyAngularVelocity = Vector3.zero
												v7.CFrame = v12
												task.wait(0.05)
												v7.AssemblyLinearVelocity = Vector3.zero

												local function f321()
													local v13 = tick()
													repeat
														if tick() - v13 < 20 then
														end
													until v6:GetAttribute("Stealing")
													v11:Destroy()
													return
												end

												task.spawn(f321)
											else
												v7.AssemblyLinearVelocity = Vector3.zero
												v7.AssemblyAngularVelocity = Vector3.zero
												v7.CFrame = CFrame.new(Position5.X, v10, Position5.Z)
												task.wait(0.03)
												local v14 = CFrame.new(Position5)
												v7.AssemblyLinearVelocity = Vector3.zero
												v7.AssemblyAngularVelocity = Vector3.zero
												v7.CFrame = v14
												task.wait(0.05)
												v7.AssemblyLinearVelocity = Vector3.zero
												v7.AssemblyAngularVelocity = Vector3.zero
												local v15 = tick()
												local _ = math.max
												local v16 = t2.TpSettings.DelayVal
												if not v16 then
													v16 = 0.4
												end
												local v17 = math.max(0.18, v16)
												while tick() < v15 + v17 and v7.Parent and
													not v6:GetAttribute("Stealing") do
													v7.AssemblyLinearVelocity = Vector3.zero
													v7.AssemblyAngularVelocity = Vector3.zero

													local function f322()
														v7.CFrame = CFrame.new(Position5)
													end

													pcall(f322)
													RunService.Heartbeat:Wait()
												end
											end
										end

										local v18, v19
										v19, v18 = pcall(f320)
										pcall(setfpscap, v4)
										if not v19 then
											warn("tpToBrainrot error:", v18)
										end
									end

									_G.runAutoSnipe = runAutoSnipe
									_G.tpToBrainrot = tpToBrainrot
									if t2.TpSettings.TpOnLoad then
										local v359 = f109
										local v360 = LocalPlayer
										local v361 = f25

										local function f323()
											local wait = task.wait
											local v1 = tonumber(t2.TpSettings.TpOnLoadDelay)
											if not v1 then
												v1 = 0
											end
											wait(v1)

											local function f324()
												pcall(loadNet)
											end

											task.spawn(f324)
											v359(t2.TpSettings.MinGenForTp)
											local v2 = os.clock()
											local _leave51 = false
											local v3
											while os.clock() - v2 < 25 do
												local t1 = v360.Character
												if t1 then
													v3 = t1:FindFirstChild("HumanoidRootPart")
												else
													v3 = t1
												end
												if t1 then
													t1 = t1:FindFirstChild("Humanoid")
												end
												if v3 and t1 and 0 < t1.Health then
													local v4 = v361()
													if v4 and findAdorneeGlobal(v4) then
														task.spawn(runAutoSnipe)
														_leave51 = true
													end
												end
												if _leave51 then
													break
												end
												RunService.Heartbeat:Wait()
											end
										end

										task.spawn(f323)
									end
									local v362 = Instance.new("Highlight", CoreGui)
									v362.FillColor = Color3.fromRGB
									v362.FillTransparency = 0.3
									v362.OutlineColor = Color3.fromRGB
									v362.OutlineTransparency = 0
									v362.Adornee = nil
									v362.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
									main = nil
									mainBody = nil
									tabBar = nil
									bottomBar = nil
									fpsText = nil
									actionSettingsPanel = nil
									actionSettingsBody = nil
									stealProgressBarGui = nil
									if true then
										_continue67 = true
									else
										f13 = task
										f13 = f13.spawn

										f14 = function()
											task.wait(0.15)
											pcall(applyTheme, "Dark")
										end

										f13(f14)
										f13 = game
										f14 = f13
										f13 = f13.GetService
										f15 = "Players"
										f13 = f13(f14, f15)
										f14 = game
										f15 = f14
										f14 = f14.GetService
										f16 = "RunService"
										f14 = f14(f15, f16)
										f15 = game
										f16 = f15
										f15 = f15.GetService
										v18 = "UserInputService"
										f15 = f15(f16, v18)
										f16 = game
										v18 = f16
										f16 = f16.GetService
										f17 = "ReplicatedStorage"
										f16 = f16(v18, f17)
										v18 = f13.LocalPlayer
										f17 = nil
										v19 = nil
										f18 = nil
										t4 = nil
										local v363 = f16

										v20 = function()
											if f17 then
												return true
											end

											local function f325()
												local Packages = v363:WaitForChild("Packages", 5)
												local Datas2 = v363:WaitForChild("Datas", 5)
												v363:WaitForChild("Shared", 5)
												local Utils = v363:WaitForChild("Utils", 5)
												f17 = require(Packages:WaitForChild("Synchronizer"))
												v19 = require(Datas2:WaitForChild("Animals"))
												f18 = _G._xenAnimShim
												t4 = require(Utils:WaitForChild("NumberUtils"))
											end

											local v1 = pcall(f325)
											if v1 then
												v1 = not (f17 == nil)
											end
											return v1
										end

										f19 = nil

										f20 = function()
											if f19 then
												return true
											end

											local function f326()
												return _G.Net
											end

											local v1, v2
											v2, v1 = pcall(f326)
											if not (v2 and type(v1) == "table") then
												return false
											end
											f19 = v1
											return true
										end

										local v364 = f20
										local v365 = v18

										v21 = function()
											if not f19 then
												v364()
											end
											if not f19 then
												return
											end
											local Character12 = v365.Character
											if not Character12 then
												return
											end
											if not Character12:FindFirstChild("Grapple Hook") then
												local v1 = v365:FindFirstChild("Backpack")
												if v1 then
													v1 = v1:FindFirstChild("Grapple Hook")
												end
												local FindFirstChildOfClass12 = Character12:FindFirstChildOfClass("Humanoid")
												if v1 and FindFirstChildOfClass12 then
													local v2 = v1

													local function f327()
														FindFirstChildOfClass12:EquipTool(v2)
													end

													pcall(f327)
												end
											end
											if not Character12:FindFirstChild("Grapple Hook") then
												return
											end

											local function f328()
												f19:RemoteEvent("UseItem"):FireServer(2)
											end

											pcall(f328)
										end

										v22 = _G
										v22.SXEFireGrapple = v21
										v22 = { CARPET = 400, INBASE = 250 }
										f21 = _G
										local v366 = v22

										function f21.SXESetCarpetSpeed(p1)
											local v1 = tonumber(p1)
											if v1 and 0 < v1 then
												v366.CARPET = v1
											end
										end

										f21 = _G
										local v367 = v22

										function f21.SXESetInbaseSpeed(p1)
											local v1 = tonumber(p1)
											if v1 and 0 < v1 then
												v367.INBASE = v1
											end
										end

										f21 = _G
										local v368 = v22

										function f21.SXEGetCarpetSpeed()
											return v368.CARPET
										end

										if t2 then
											f21 = t2.TpSettings
											if f21 then
												f21 = tonumber
												f21 = f21(t2.TpSettings.GrabbleTPSpeed)
											end
											if f21 then
												f21 = tonumber
												f21 = f21(t2.TpSettings.GrabbleTPSpeed)
												v22.CARPET = f21
											end
										end
										f21 = _G["table.create"](7)
										local v369 = v18

										local function f329(...)
											local v1 = true
											if v1 then
												v1 = 60
											end
											while true do
												if v1 then
													local v2 = ...
													local Character13 = v369.Character
													local t1 = v369
													local f330 = t1.FindFirstChild
													local v3 = "Backpack"
													while true do
														f330 = f330(t1, v3)
														if not Character13 then
															break
														end
														t1 = Character13:FindFirstChild(v2)
														if not (t1 or not f330) then
															return (f330:FindFirstChild(v2))
														end
														v3 = Character13
													end
													v1 = 60
												end
											end
										end

										local v370 = _G["table.create"](7)
										local v371 = f329
										local v372 = v18
										local v373 = f329
										local v374 = f21

										local function f331()
											local Character14 = v372.Character
											local v1
											if Character14 then
												v1 = Character14:FindFirstChildOfClass("Humanoid")
											else
												v1 = Character14
											end
											if not v1 then
												return nil
											end
											local v2 = t2
											if v2 then
												v2 = t2.TpSettings
											end
											if v2 then
												v2 = t2.TpSettings.Tool
											end
											if v2 then
												local t1 = v373(v2)
												if t1 and t1:IsA("Tool") then
													if t1.Parent ~= Character14 then
														local v3 = v1

														local function f332()
															v3:EquipTool(t1)
														end

														pcall(f332)
													end
													return v2
												end
											end
											for _, v4 in ipairs(v374) do
												local t2 = v373(v4)
												if t2 and t2:IsA("Tool") then
													if t2.Parent ~= Character14 then
														local v5 = v1
														local v6 = t2

														local function f333()
															v5:EquipTool(v6)
														end

														pcall(f333)
													end
													return v4
												end
											end
											return nil
										end

										local v375 = f20
										local v376 = f329
										local v377 = f14
										local v378 = v18
										local v379 = f331
										local t61 = {}
										local t62 = {}
										t5 = "Headless Horseman"
										t62.pets = _G["table.create"](1)
										t62.threshold = 0
										t61[1] = t62
										local t63 = {}
										t5 = "Signore Carapace"
										t63.pets = _G["table.create"](1)
										t63.threshold = 0
										t61[2] = t63
										local t64 = {}
										t5 = "Strawberry Elephant"
										t64.pets = _G["table.create"](1)
										t64.threshold = 0
										t61[3] = t64
										local t65 = {}
										t5 = "Arcadragon"
										t65.pets = _G["table.create"](1)
										t65.threshold = 0
										t61[4] = t65
										local t66 = {}
										t5 = "Elefanto Frigo"
										t66.pets = _G["table.create"](1)
										t66.threshold = 5000000000
										t61[5] = t66
										local t67 = {}
										t5 = "John Pork"
										t67.pets = _G["table.create"](1)
										t67.threshold = 10000000000
										t61[6] = t67
										local t68 = {}
										t5 = "Meowl"
										t68.pets = _G["table.create"](1)
										t68.threshold = 5000000000
										t61[7] = t68
										local t69 = {}
										t5 = "Skibidi Toilet"
										t69.pets = _G["table.create"](1)
										t69.threshold = 5000000000
										t61[8] = t69
										local t70 = {}
										t5 = "Love Love Bear"
										t70.pets = _G["table.create"](1)
										t70.threshold = 0
										t61[9] = t70
										local t71 = {}
										t5 = "Antonio"
										t71.pets = _G["table.create"](1)
										t71.threshold = 0
										t61[10] = t71
										local t72 = {}
										t5 = "Pancake and Syrup"
										t72.pets = _G["table.create"](1)
										t72.threshold = 0
										t61[11] = t72
										local t73 = {}
										t5 = "Griffin"
										t73.pets = _G["table.create"](1)
										t73.threshold = 0
										t61[12] = t73
										local t74 = {}
										t5 = "La Supreme Combinasion"
										t74.pets = _G["table.create"](4)
										t74.threshold = 5000000000
										t61[13] = t74
										local t75 = {}
										t5 = "Ginger Gerat"
										t75.pets = _G["table.create"](2)
										t75.threshold = 10000000000
										t61[14] = t75
										local t76 = {}
										t5 = "Hydra Bunny"
										t76.pets = _G["table.create"](3)
										t76.threshold = 3000000000
										t61[15] = t76
										local t77 = {}
										t5 = "Hydra Dragon Cannelloni"
										t77.pets = _G["table.create"](3)
										t77.threshold = 3000000000
										t61[16] = t77
										local t78 = {}
										t5 = "Globa Steppa"
										t78.pets = _G["table.create"](5)
										t78.threshold = 3000000000
										t61[17] = t78
										local t79 = {}
										t5 = "Fragola La La La"
										t79.pets = _G["table.create"](4)
										t79.threshold = 1000000000
										t61[18] = t79
										local t80 = {}
										t5 = "Garama and Madundung"
										v23 = "Los Sekolahs"
										v24 = "Celestial Pegasus"
										t80.pets = _G["table.create"](13)
										t80.threshold = 750000000
										t61[19] = t80
										local t81 = {}
										t5 = "La Secret Combinasion"
										t81.pets = _G["table.create"](4)
										t81.threshold = 1000000000
										t61[20] = t81
										t5 = t61
										local _, v380, _
										_, v380, _ = pairs(t5)
										t5 = v380
										local t82 = { true, true, true, true }
										t5 = {}
										local t83 = { [4] = 10000000000 }
										t5[3] = t83
										t5[4] = {}
										local t84 = { [6] = math.huge }
										t5[5] = t84
										local t85 = { [9] = math.huge, [10] = math.huge, [12] = 15000000000 }
										t5[6] = t85
										local t86 = { [12] = 20000000000 }
										t5[10] = t86
										local t87 = { [12] = 10000000000 }
										t5[11] = t87
										local t88 = {
											Galaxy = 1,
											Candy = 1,
											["Yin Yang"] = 1,
											YinYang = 1,
											Divine = 1,
											Cursed = 1,
											Lava = 1,
											Radioactive = 1,
											Cyber = 1,
											Rainbow = 1,
											Bloodrot = 2
										}
										local t89 = {
											["Fishino Clownino"] = true,
											["Globa Steppa"] = true,
											["La Supreme Combinasion"] = true,
											["Tirilikalika Tirilikalako"] = true
										}
										local v381 = t88

										local function f334(p1)
											if p1 then
												while not (p1 == "" or p1 == "None") do
													if not v381[p1] then
														local gsub4 = tostring(p1):lower():gsub("[%s%-_]", "")
														if gsub4 == "bloodrot" then
															return 2
														end
														if gsub4 == "yinyang" or gsub4 == "galaxy" or
															(gsub4 == "candy" or gsub4 == "divine") or
															(gsub4 == "cursed" or gsub4 == "lava" or
																(gsub4 == "radioactive" or gsub4 == "cyber")) or gsub4 == "rainbow" then
															return 1
														end
														return 0
													end
												end
											end
											return 0
										end

										local v382 = t5
										local v383 = t82
										local v384 = t61

										local function f335(p1, p2)
											if v382[p1] and v382[p1][p2] then
												return v382[p1][p2]
											end
											if v383[p1] then
												return math.huge
											end
											local v1 = 0
											local v2 = p1 + 1 - 1
											while true do
												v2 = v2 + 1
												if not (v2 <= p2) then
													break
												end
												local t1 = v384[v2]
												if t1 and 0 < t1.threshold then
													v1 = v1 + t1.threshold
												end
											end
											return v1
										end

										local v385 = t89
										local v386 = f334
										local t90 = {}
										local v387 = f335

										local function f336(p1, p2, p3, p4, p5, p6)
											if p1 == "Strawberry Elephant" and p2 == "John Pork" then
												return true
											end
											if p1 == "John Pork" and p2 == "Strawberry Elephant" then
												return false
											end
											if v385[p1] and p2 == "Griffin" and 1 <= v386(p3) then
												return true
											end
											if p1 == "Griffin" and v385[p2] and 1 <= v386(p4) then
												return false
											end
											if p1 == "Antonio" and p2 == "Elefanto Frigo" and 1 <= v386(p3) then
												return true
											end
											if p1 == "Elefanto Frigo" and p2 == "Antonio" and 1 <= v386(p4) then
												return false
											end
											local v1 = t90[p1]
											if not v1 then
												v1 = 99
											end
											local v2 = t90[p2]
											if not v2 then
												v2 = 99
											end
											local v3, v4
											if not (t90[p1] and t90[p2]) then
												if v1 ~= v2 then
													v4 = v1 < v2
													return v4
												end
												if not p5 then
													p5 = 0
												end
												if not p6 then
													p6 = 0
												end
												v3 = p6 < p5
												return v3
											end
											local v5, v6
											if v1 == v2 then
												local v7 = v386(p3)
												local v8 = v386(p4)
												if v7 ~= v8 then
													v6 = v8 < v7
													return v6
												end
												if not p5 then
													p5 = 0
												end
												if not p6 then
													p6 = 0
												end
												v5 = p6 < p5
												return v5
											end
											if v1 == 4 and v2 == 3 then
												return true
											end
											if v2 == 4 then
												return false
											end
											local v9 = math.min(v1, v2)
											local v10 = math.max(v1, v2)
											local v11
											v11 = v1 < v2
											v11 = v11 and p5 or p6
											local v12
											v12 = v1 < v2
											v12 = v12 and p6 or p5
											local v13 = v387(v9, v10)
											local v14
											if 0 < v13 and v13 ~= math.huge then
												if not v12 then
													v12 = 0
												end
												if not v11 then
													v11 = 0
												end
												if v13 < v12 - v11 then
													v14 = v2 < v1
													return v14
												end
											end
											local v15
											v15 = v1 < v2
											return v15
										end

										local function f337(p1)
											local v1 = f17
											local v2 = v1
											if not v1 then
												return nil
											end
											v2 = nil

											local function f338()
												v2 = _G.SXE_GetPlotChannel(p1)
											end

											pcall(f338)
											if not v2 then
												local v3 = os.clock()
												while true do
													v2 = _G.XenSyncGet(p1)
													if v2 then
														break
													end
													task.wait(0.05)
													if 3 < os.clock() - v3 then
														break
													end
												end
											end
											return v2
										end

										local function f339(p1, p2)
											local v1 = nil
											if not p1 then
												return nil
											end
											v1 = nil

											local function f340()
												if type(p1.Get) == "function" then
													v1 = p1:Get(p2)
												end
											end

											pcall(f340)
											if v1 == nil then
												local function f341()
													while true do
													end
												end

												pcall(f341)
											end
											return v1
										end

										local v388 = f339
										local v389 = v18

										local function f342(p1)
											if not p1 then
												return false
											end
											local v1 = v388(p1, "Owner")
											local v2 = p1
											if not v1 then
												return false
											end
											v2 = false

											local function f343()
												local v3, v4, v5
												if typeof(v1) == "Instance" and v1:IsA("Player") then
													v5 = v1.UserId == v389.UserId
													v2 = v5
												elseif type(v1) == "table" and v1.UserId then
													v4 = v1.UserId == v389.UserId
													v2 = v4
												elseif typeof(v1) == "Instance" then
													v3 = v1 == v389
													v2 = v3
												end
											end

											pcall(f343)
											return v2
										end

										local v390 = f339
										local v391 = f13

										local function f344(p1)
											if not p1 then
												return false
											end
											local v1 = v390(p1, "Owner")
											local v2 = p1
											if not v1 then
												return false
											end
											v2 = false

											local function f345(...)
												local v3, v4, v5, v6
												if typeof(v1) == "Instance" and v1:IsA("Player") then
													v6 = not (v391:FindFirstChild(v1.Name) == nil)
													v2 = v6
												elseif type(v1) == "number" then
													v5 = not (v391:GetPlayerByUserId(v1) == nil)
													v2 = v5
												elseif type(v1) == "table" and v1.Name then
													v4 = not (v391:FindFirstChild(tostring(v1.Name)) == nil)
													v2 = v4
												elseif typeof(v1) == "Instance" and v1.Name then
													v3 = not (v391:FindFirstChild(v1.Name) == nil)
													v2 = v3
												end
											end

											pcall(f345)
											return v2
										end

										local v392 = f337
										local v393 = f339

										v23 = function(p1, p2)
											local AnimalPodiums3 = p1:FindFirstChild("AnimalPodiums")
											if not AnimalPodiums3 then
												return nil
											end
											local FindFirstChild11 = AnimalPodiums3:FindFirstChild(tostring(p2))
											if not FindFirstChild11 then
												return nil
											end
											for _, t1 in ipairs(FindFirstChild11:GetDescendants()) do
												if t1:IsA("Model") and t1.Name ~= "Claim" and
													not (t1.Name == "Base" or
														t1.Name == "Decorations") then
													local v1 = false
													for _, v2 in ipairs(t1:GetDescendants()) do
														if v2:IsA("MeshPart") then
															v1 = true
															break
														end
													end
													if v1 then
														local v3 = t1

														local function f346()
															return (v3:GetBoundingBox())
														end

														local t2, v4
														v4, t2 = pcall(f346)
														if v4 then
															return t2.Position
														end
													end
												end
											end

											local function f347()
												return (FindFirstChild11:GetPivot())
											end

											local t3, v5
											v5, t3 = pcall(f347)
											if v5 then
												return t3.Position
											end
											return FindFirstChild11.Position
										end

										v24 = { Fuse = true, Duel = true, Trade = true, Crafting = true }
										local v394 = v24

										f22 = function(...)
											local v1 = nil
											if true then
												return false
											end
											v1 = v394[v1]
											local v2
											v2 = v1 == true
											while not v2 do
											end
											local v3
											v3 = (nil).Active == true
											return v3
										end

										local v395 = v20
										local v396 = f337
										local v397 = f342
										local v398 = f344
										local v399 = f339
										local v400 = f22
										local v401 = v23
										local v402 = f336

										v25 = function(...)
											local t1 = {}
											if not v395() then
												return t1
											end
											local Plots7 = workspace:FindFirstChild("Plots")
											if not Plots7 then
												return t1
											end
											local v1, v2, f348
											f348, v2, v1 = ipairs(Plots7:GetChildren())
											local v3 = nil
											while true do
												local t2
												v1, t2 = f348(v2, v1)
												if v1 == nil then
													break
												end
												local v4 = v396(t2.Name)
												if v4 and not v397(v4) and v398(v4) then
													local t3 = v399(v4, "AnimalList")
													if t3 then
														for v5, t4 in pairs(t3) do
															if type(t4) == "table" then
																local Index = t4.Index
																if Index then
																	local t5 = v19
																	if t5 then
																		t5 = v19[Index]
																	end
																	if t5 then
																		v3 = t4
																		if not v400(v3) then
																			local v6 = t4.Mutation
																			if not v6 then
																				v6 = "None"
																			end
																			v3 = 0
																			local v7 = Index
																			local v8 = t4

																			local function f349()
																				v3 = f18:GetGeneration(v7, v8.Mutation, v8.Traits, nil)
																			end

																			pcall(f349)
																			t5 = t5 and t5.DisplayName or Index
																			local v9 = v401(t2, v5)
																			if v9 then
																				local _ = table.insert
																				local t6 = {
																					name = t5,
																					index = Index,
																					mps = v3,
																					mutation = v6,
																					position = v9,
																					plot = t2.Name,
																					slot = tostring(v5)
																				}
																				table.insert(t1, t6)
																			end
																		end
																	end
																end
															end
														end
													end
												end
											end
											local RenderedMovingAnimals = workspace:FindFirstChild("RenderedMovingAnimals")
											if RenderedMovingAnimals then
												for _, v10 in ipairs(RenderedMovingAnimals:GetChildren()) do
													local v11 = v10

													local function f350()
														if not v11:IsA("Model") then
															return
														end
														local t7 = v19
														if t7 then
															t7 = v19[v11.Name]
														end
														if not t7 then
															return
														end
														local v12 = v11
														local v13 = v12:GetAttribute("Mutation")
														local v14 = v12
														if not v13 then
															v13 = "None"
															v14 = v12
														end
														v14 = 0

														local function f351()
															local v15 = f18:GetGeneration(
																v11.Name,
																v11:GetAttribute("Mutation"),
																nil,
																nil
															)
															if not v15 then
																v15 = 0
															end
															v14 = v15
														end

														pcall(f351)
														if v14 <= 0 then
															return
														end
														local t8 = v11.PrimaryPart
														if not t8 then
															t8 = v11:FindFirstChildWhichIsA("BasePart")
														end
														if not t8 then
															return
														end
														local _ = table.insert
														local v16 = t1
														local t9 = {}
														local v17 = t7.DisplayName
														if not v17 then
															v17 = v11.Name
														end
														t9.name = v17
														t9.index = v11.Name
														t9.mps = v14
														t9.mutation = v13
														t9.position = t8.Position
														t9.plot = nil
														t9.slot = nil
														t9.conveyor = true
														t9.model = v11
														table.insert(v16, t9)
													end

													pcall(f350)
												end
											end

											local function f352(p1, p2)
												return (v402(
													p1.name,
													p2.name,
													p1.mutation,
													p2.mutation,
													p1.mps,
													p2.mps
												))
											end

											table.sort(t1, f352)
											return t1
										end

										v26 = {}
										f23 = _G["table.create"](4)
										f24 = -75.768013
										local v403
										v403.coord = Vector3.new(-487.921448, 16.850713, f24)
										f24 = 16.850722
										local v404
										v404.coord = Vector3.new(-332.37973, f24, -75.7621)
										f24 = -487.134918
										local v405
										v405.coord = Vector3.new(f24, 16.850713, -18.094154)
										f24 = Vector3
										f24 = f24.new
										f24 = f24(-316.300171, 16.850713, -17.845898)
										v26.B = f23
										f23 = _G["table.create"](4)
										f24 = 31.424425
										local v406
										v406.coord = Vector3.new(-330.765381, 16.850713, f24)
										f24 = 16.850713
										local v407
										v407.coord = Vector3.new(-502.989349, f24, 31.17243)
										f24 = -489.077087
										local v408
										v408.coord = Vector3.new(f24, 16.850713, 89.010147)
										f24 = Vector3
										f24 = f24.new
										f24 = f24(-330.908936, 16.850713, 88.930145)
										v26.C = f23
										f23 = _G["table.create"](4)
										f24 = 138.209167
										local v409
										v409.coord = Vector3.new(-331.264893, 16.850713, f24)
										f24 = 16.850713
										local v410
										v410.coord = Vector3.new(-487.935181, f24, 138.026321)
										f24 = -487.774933
										local v411
										v411.coord = Vector3.new(f24, 16.850713, 195.882538)
										f24 = Vector3
										f24 = f24.new
										f24 = f24(-330.799133, 16.850575, 196.022354)
										v26.D = f23
										f23 = {}
										local v412 = _G["table.create"](4)
										f24 = -3.048217
										local v413
										v413.coord = Vector3.new(-335.725586, f24, -74.984589)
										f24 = -503.214233
										local v414
										v414.coord = Vector3.new(f24, -3.048217, -75.043137)
										f24 = Vector3
										f24 = f24.new
										f24 = f24(-483.619385, -3.71843, -18.844337)
										f24 = {}
										f24.coord = Vector3.new(-316.147095, -3.048218, -18.818844)
										f24.facing = "SOUTH"
										f23.B = v412
										local v415 = _G["table.create"](4)
										f24 = -3.048218
										local v416
										v416.coord = Vector3.new(-335.985413, f24, 32.051426)
										f24 = -503.277008
										local v417
										v417.coord = Vector3.new(f24, -3.048217, 31.956175)
										f24 = Vector3
										f24 = f24.new
										f24 = f24(-483.74939, -3.048218, 88.147003)
										f24 = {}
										f24.coord = Vector3.new(-315.793823, -3.048217, 88.163979)
										f24.facing = "SOUTH"
										f23.C = v415
										local v418 = _G["table.create"](4)
										f24 = -3.048218
										local v419
										v419.coord = Vector3.new(-335.476654, f24, 139.001083)
										f24 = -503.710083
										local v420
										v420.coord = Vector3.new(f24, -3.048218, 138.989883)
										f24 = Vector3
										f24 = f24.new
										f24 = f24(-315.654938, -3.048218, 195.302444)
										f24 = {}
										f24.coord = Vector3.new(-483.859253, -3.048218, 195.269043)
										f24.facing = "SOUTH"
										f23.D = v418
										local t91 = {}
										f24 = Vector3
										f24 = f24.new
										f24 = f24(-476.52, -2, 220.94)
										t91[1] = f24
										f24 = Vector3
										f24 = f24.new
										f24 = f24(-476.52, -2, 113.77)
										t91[2] = f24
										f24 = Vector3
										f24 = f24.new
										f24 = f24(-476.52, -2, 6.18)
										t91[3] = f24
										f24 = Vector3
										f24 = f24.new
										f24 = f24(-476.52, -2, -101.07)
										t91[4] = f24
										f24 = Vector3
										f24 = f24.new
										f24 = f24(-342.66, -2, 221.45)
										t91[5] = f24
										f24 = Vector3
										f24 = f24.new
										f24 = f24(-342.66, -2, 113.41)
										t91[6] = f24
										f24 = Vector3
										f24 = f24.new
										f24 = f24(-342.66, -2, 6.25)
										t91[7] = f24
										f24 = Vector3
										f24 = f24.new
										f24 = f24(-342.66, -2, -99.73)
										t91[8] = f24
										f24 = {}
										f24[1] = Vector3.new(-479.51, 18, 220.94)
										f24[2] = Vector3.new(-479.51, 18, 113.77)
										f24[3] = Vector3.new(-479.51, 18, 6.18)
										f24[4] = Vector3.new(-479.51, 18, -101.07)
										f24[5] = Vector3.new(-339.48, 18, 221.45)
										f24[6] = Vector3.new(-339.48, 18, 113.41)
										f24[7] = Vector3.new(-339.48, 18, 6.25)
										f24[8] = Vector3.new(-339.48, 18, -99.73)
										local v421 = t91
										local v422 = f24
										local v423 = t91
										local v424 = t91

										f25 = function(p1, p2)
											local t1 = v424[p2]
											local v1
											v1 = p2 <= 4
											local t2 = {}
											local v2, v3, f353
											f353, v3, v2 = pairs(p1)
											local v4
											while true do
												local t3
												v2, t3 = f353(v3, v2)
												if v2 == nil then
													break
												end
												for _, t4 in ipairs(t3) do
													v4 = t4.coord.X < -410
													if v4 == v1 and
														math.abs(t4.coord.Z - t1.Z) < 45 then
														t2[#t2 + 1] = t4
													end
												end
											end
											return t2
										end

										local t92 = {}
										f13 = _G
										f14 = _G
										f14 = f14.SXE_getNet
										if not f14 then
											f14 = function()
												while true do
												end
											end
										end
										f13.SXE_getNet = f14
										f13 = _G
										f14 = _G
										f14 = f14.SXEFireUseItem
										if not f14 then
											f14 = function(...)
												if not _G.Net then
													return false
												end
												local v1 = table.pack(...)

												local function f354()
													_G.Net:RemoteEvent("UseItem"):FireServer(table.unpack(v1, 1, v1.n))
												end

												return (pcall(f354))
											end
										end
										f13.SXEFireUseItem = f14
										f13 = game
										f14 = f13
										f13 = f13.GetService
										f15 = "Players"
										f13 = f13(f14, f15)
										f14 = game
										f15 = f14
										f14 = f14.GetService
										f16 = "RunService"
										f14 = f14(f15, f16)
										f15 = game
										f16 = f15
										f15 = f15.GetService
										v18 = "UserInputService"
										f15 = f15(f16, v18)
										f16 = game
										v18 = f16
										f16 = f16.GetService
										f17 = "ReplicatedStorage"
										f16 = f16(v18, f17)
										v18 = f13.LocalPlayer
										while not v18 do
											f17 = task
											f17 = f17.wait
											v19 = 0.2
											f17(v19)
											v18 = f13.LocalPlayer
										end
										f17 = { Fuse = true, Duel = true, Trade = true, Crafting = true }
										local v425 = f17

										v19 = function(p1)
											if type(p1) ~= "table" then
												return false
											end
											local Machine = p1.Machine
											if type(Machine) ~= "table" then
												return false
											end
											local v1
											v1 = v425[Machine.Type] == true
											return v1
										end

										f18 = _G
										t4 = _G
										t4 = t4.VanishGetSyncData
										if not t4 then
											t4 = function(p1)
												local v1
												v1 = type(p1) == "string"
												if v1 then
													v1 = p1
												end
												if not (v1 or not p1) then
													v1 = p1.Name
												end
												if not v1 then
													return nil
												end
												local v2 = _G._xenRawCT
												v2 = v2 and _G._xenRawCT(v1) or nil
												if type(v2) == "table" then
													return v2
												end
												local v3 = _G.SXE_GetPlotChannel
												v3 = v3 and _G.SXE_GetPlotChannel(v1) or nil
												if not v3 then
													return nil
												end
												local t1 = { __channel = v3 }
												local v4 = v3

												local function f355()
													t1.AnimalList = v4:Get("AnimalList")
												end

												pcall(f355)
												local v5 = v3

												local function f356()
													t1.Owner = v5:Get("Owner")
												end

												pcall(f356)
												return t1
											end
										end
										f18.VanishGetSyncData = t4
										f18 = nil
										t4 = nil
										v20 = nil
										f19 = nil
										local v426 = f16

										f20 = function()
											if f18 then
												return true
											end

											local function f357()
												local Packages2 = v426:WaitForChild("Packages", 5)
												local Datas3 = v426:WaitForChild("Datas", 5)
												v426:WaitForChild("Shared", 5)
												local Utils2 = v426:WaitForChild("Utils", 5)
												f18 = require(Packages2:WaitForChild("Synchronizer"))
												t4 = require(Datas3:WaitForChild("Animals"))
												v20 = _G._xenAnimShim
												f19 = require(Utils2:WaitForChild("NumberUtils"))
											end

											local v1 = pcall(f357)
											if v1 then
												v1 = not (f18 == nil)
											end
											return v1
										end

										v21 = nil

										v22 = function()
											if v21 then
												return true
											end
											local v1 = _G.SXE_getNet
											v1 = v1 and _G.SXE_getNet() or nil
											v21 = v1
											local v2
											v2 = not (v21 == nil)
											return v2
										end

										local v427 = v22

										f21 = function()
											if not v21 then
												v427()
											end
											if not v21 then
												return
											end
											local Character15 = v18.Character
											if not Character15 then
												return
											end
											if not Character15:FindFirstChild("Grapple Hook") then
												local v1 = v18:FindFirstChild("Backpack")
												if v1 then
													v1 = v1:FindFirstChild("Grapple Hook")
												end
												local FindFirstChildOfClass13 = Character15:FindFirstChildOfClass("Humanoid")
												if v1 and FindFirstChildOfClass13 then
													local v2 = v1

													local function f358()
														FindFirstChildOfClass13:EquipTool(v2)
													end

													pcall(f358)
												end
											end
											if not Character15:FindFirstChild("Grapple Hook") then
												return
											end

											local function f359()
												_G.SXEFireUseItem(2)
											end

											pcall(f359)
										end

										_G.VanishFireGrapple = f21
										local v428 = _G["table.create"](7)
										t5 = "Cupid's Wings"

										local function f360(p1)
											local Character16 = v18.Character
											local Backpack = v18:FindFirstChild("Backpack")
											local v1
											if Character16 then
												v1 = Character16:FindFirstChild(p1)
											else
												v1 = Character16
											end
											if not (v1 or not Backpack) then
												v1 = Backpack:FindFirstChild(p1)
											end
											if v1 then
												return v1
											end
											local gsub5 = tostring(p1):lower():gsub("[^%w]", "")
											local t1 = {}
											if Character16 then
												t1[#t1 + 1] = Character16
											end
											if Backpack then
												t1[#t1 + 1] = Backpack
											end
											for _, v2 in ipairs(t1) do
												for _, t2 in ipairs(v2:GetChildren()) do
													if t2:IsA("Tool") and
														t2.Name:lower():gsub("[^%w]", "") == gsub5 then
														return t2
													end
												end
											end
											return nil
										end

										t5 = "Grapple"
										local v429 = _G["table.create"](7)
										local v430 = f360
										local v431 = f360
										local v432 = v428

										t5 = function()
											local Character17 = v18.Character
											local v1
											if Character17 then
												v1 = Character17:FindFirstChildOfClass("Humanoid")
											else
												v1 = Character17
											end
											if not v1 then
												return nil
											end
											local v2 = t2
											if v2 then
												v2 = t2.TpSettings
											end
											if v2 then
												v2 = t2.TpSettings.Tool
											end
											if type(v2) == "string" and v2 ~= "" and v2 ~= "Auto" then
												local t1 = v431(v2)
												if t1 and t1:IsA("Tool") then
													if t1.Parent ~= Character17 then
														local v3 = v1

														local function f361()
															v3:EquipTool(t1)
														end

														pcall(f361)
													end
													return v2
												end
											end
											if not (type(v2) == "string" and v2 ~= "" and
												not (v2 == "Auto" or v2 == "Flying Carpet")) then
												for _, v4 in ipairs(v432) do
													local t2 = v431(v4)
													if t2 and t2:IsA("Tool") then
														if t2.Parent ~= Character17 then
															local v5 = v1
															local v6 = t2

															local function f362()
																v5:EquipTool(v6)
															end

															pcall(f362)
														end
														return v4
													end
												end
											end
											return nil
										end

										local v433 = v22
										local v434 = f360
										local v435 = f14
										local v436 = t5
										local t93 = {}
										local t94 = { pets = _G["table.create"](1), threshold = 0 }
										t93[1] = t94
										local t95 = { pets = _G["table.create"](1), threshold = 0 }
										t93[2] = t95
										local t96 = { pets = _G["table.create"](1), threshold = 0 }
										t93[3] = t96
										local t97 = { pets = _G["table.create"](1), threshold = 0 }
										t93[4] = t97
										local t98 = { pets = _G["table.create"](1), threshold = 5000000000 }
										t93[5] = t98
										local t99 = { pets = _G["table.create"](1), threshold = 10000000000 }
										t93[6] = t99
										local t100 = { pets = _G["table.create"](1), threshold = 5000000000 }
										t93[7] = t100
										local t101 = { pets = _G["table.create"](1), threshold = 5000000000 }
										t93[8] = t101
										local t102 = { pets = _G["table.create"](1), threshold = 0 }
										t93[9] = t102
										local t103 = { pets = _G["table.create"](1), threshold = 0 }
										t93[10] = t103
										local t104 = { pets = _G["table.create"](1), threshold = 0 }
										t93[11] = t104
										local t105 = { pets = _G["table.create"](1), threshold = 0 }
										t93[12] = t105
										local t106 = { pets = _G["table.create"](5), threshold = 5000000000 }
										t93[13] = t106
										local t107 = { pets = _G["table.create"](2), threshold = 10000000000 }
										t93[14] = t107
										local t108 = { pets = _G["table.create"](3), threshold = 3000000000 }
										t93[15] = t108
										local t109 = { pets = _G["table.create"](3), threshold = 3000000000 }
										t93[16] = t109
										local t110 = { pets = _G["table.create"](4), threshold = 3000000000 }
										t93[17] = t110
										local t111 = { pets = _G["table.create"](4) }
										v3.threshold = 1000000000
										t93[18] = t111
										local t112 = {}
										v23 = "La Food Combinasion"
										v24 = "Los Amigos"
										f22 = "Foxini Lanternini"
										v25 = "Capitano Moby"
										v26 = "Fortunu and Cashuru"
										f23 = "Los Sekolahs"
										t112.pets = _G["table.create"](13)
										t112.threshold = 750000000
										t93[19] = t112
										local t113 = { pets = _G["table.create"](4), threshold = 1000000000 }
										t93[20] = t113
										pairs(t93)
										local t114 = { true, true, true, true }
										local t115 = {}
										local t116 = { [4] = 10000000000 }
										t115[3] = t116
										t115[4] = {}
										local t117 = { [6] = math.huge }
										t115[5] = t117
										local t118 = { [9] = math.huge, [10] = math.huge, [12] = 15000000000 }
										t115[6] = t118
										local t119 = { [12] = 20000000000 }
										t115[10] = t119
										local t120 = { [12] = 10000000000 }
										t115[11] = t120
										local t121 = {
											Galaxy = 1,
											Candy = 1,
											["Yin Yang"] = 1,
											YinYang = 1,
											Divine = 1,
											Cursed = 1,
											Lava = 1,
											Radioactive = 1,
											Cyber = 1,
											Rainbow = 1,
											Bloodrot = 2
										}
										local v437 = t121
										local v438 = t115
										local v439 = t114
										local v440 = t93

										local function f363(p1)
											return (tostring(p1):lower():gsub("[%s%-_'%.]", ""))
										end

										local v441 = f363

										v23 = function(p1)
											local SHARED_PRIORITY_ITEMS = _G.SHARED_PRIORITY_ITEMS
											if not (type(SHARED_PRIORITY_ITEMS) == "table" and p1) then
												return math.huge
											end
											local v1 = v441(p1)
											for v2, v3 in ipairs(SHARED_PRIORITY_ITEMS) do
												if v441(v3) == v1 then
													return v2
												end
											end
											return math.huge
										end

										local v442 = v23

										v24 = function(p1, p2, _, _, p3, p4)
											local v1 = v442(p1)
											local v2 = v442(p2)
											local v3
											if v1 ~= v2 then
												v3 = v1 < v2
												return v3
											end
											if not p3 then
												p3 = 0
											end
											if not p4 then
												p4 = 0
											end
											local v4
											v4 = p4 < p3
											return v4
										end

										f22 = function(p1)
											local v1 = nil
											if _G.SXE_GetPlotChannel then
												local function f364()
													v1 = _G.SXE_GetPlotChannel(p1)
												end

												pcall(f364)
											end
											if not v1 then
												local v2 = os.clock()
												while true do
													v1 = _G.XenSyncGet(p1)
													if v1 then
														break
													end
													task.wait(0.05)
													if 3 < os.clock() - v2 then
														break
													end
												end
											end
											return v1
										end

										v25 = function(p1, p2)
											local v1 = nil
											if not p1 then
												return nil
											end
											v1 = nil

											local function f365()
												if type(p1.Get) == "function" then
													v1 = p1:Get(p2)
												end
											end

											pcall(f365)
											if v1 == nil then
												local function f366()
													local v2 = p1.CacheTable
													if v2 then
														v2 = p1.CacheTable[p2]
													end
													v1 = v2
												end

												pcall(f366)
											end
											return v1
										end

										local v443 = v25

										v26 = function(p1)
											if not p1 then
												return false
											end
											local v1 = v443(p1, "Owner")
											local v2 = p1
											if not v1 then
												return false
											end
											v2 = false

											local function f367()
												local v3, v4, v5
												if typeof(v1) == "Instance" and v1:IsA("Player") then
													v5 = v1.UserId == v18.UserId
													v2 = v5
												elseif type(v1) == "table" and v1.UserId then
													v4 = v1.UserId == v18.UserId
													v2 = v4
												elseif typeof(v1) == "Instance" then
													v3 = v1 == v18
													v2 = v3
												end
											end

											pcall(f367)
											return v2
										end

										local v444 = v25
										local v445 = f13

										f23 = function(p1)
											if not p1 then
												return false
											end
											local v1 = v444(p1, "Owner")
											local v2 = p1
											if not v1 then
												return false
											end
											v2 = false

											local function f368(...)
												local v3, v4, v5, v6
												if typeof(v1) == "Instance" and v1:IsA("Player") then
													v6 = not (v445:FindFirstChild(v1.Name) == nil)
													v2 = v6
												elseif type(v1) == "number" then
													v5 = not (v445:GetPlayerByUserId(v1) == nil)
													v2 = v5
												elseif type(v1) == "table" and v1.Name then
													v4 = not (v445:FindFirstChild(tostring(v1.Name)) == nil)
													v2 = v4
												elseif typeof(v1) == "Instance" and v1.Name then
													v3 = not (v445:FindFirstChild(v1.Name) == nil)
													v2 = v3
												end
											end

											pcall(f368)
											return v2
										end

										local function f369(p1, p2)
											local AnimalPodiums4 = p1:FindFirstChild("AnimalPodiums")
											if not AnimalPodiums4 then
												return nil
											end
											local FindFirstChild12 = AnimalPodiums4:FindFirstChild(tostring(p2))
											if not FindFirstChild12 then
												return nil
											end
											for _, t1 in ipairs(FindFirstChild12:GetDescendants()) do
												if t1:IsA("Model") and t1.Name ~= "Claim" and
													not (t1.Name == "Base" or
														t1.Name == "Decorations") then
													local v1 = false
													for _, v2 in ipairs(t1:GetDescendants()) do
														if v2:IsA("MeshPart") then
															v1 = true
															break
														end
													end
													if v1 then
														local v3 = t1

														local function f370()
															return (v3:GetBoundingBox())
														end

														local t2, v4
														v4, t2 = pcall(f370)
														if v4 then
															return t2.Position
														end
													end
												end
											end

											local function f371()
												return (FindFirstChild12:GetPivot())
											end

											local t3, v5
											v5, t3 = pcall(f371)
											if v5 then
												return t3.Position
											end
											return FindFirstChild12.Position
										end

										local v446 = f20
										local v447 = f22
										local v448 = v26
										local v449 = f23
										local v450 = v25
										local v451 = v19
										local v452 = f369
										local v453 = f363
										_G["table.create"](4)
										f24 = {}
										f24.coord = Vector3.new(-487.921448, 16.850713, -75.768013)
										f24.facing = "NORTH"
										local v454
										v454.coord = Vector3.new(-332.37973, 16.850722, -75.7621)
										local v455
										v455.coord = Vector3.new(-487.134918, 16.850713, -18.094154)
										local v456
										v456.coord = Vector3.new(-316.300171, 16.850713, -17.845898)
										_G["table.create"](4)
										f24 = {}
										f24.coord = Vector3.new(-330.765381, 16.850713, 31.424425)
										f24.facing = "NORTH"
										local v457
										v457.coord = Vector3.new(-502.989349, 16.850713, 31.17243)
										local v458
										v458.coord = Vector3.new(-489.077087, 16.850713, 89.010147)
										local v459
										v459.coord = Vector3.new(-330.908936, 16.850713, 88.930145)
										_G["table.create"](4)
										f24 = {}
										f24.coord = Vector3.new(-331.264893, 16.850713, 138.209167)
										f24.facing = "NORTH"
										local v460
										v460.coord = Vector3.new(-487.935181, 16.850713, 138.026321)
										local v461
										v461.coord = Vector3.new(-487.774933, 16.850713, 195.882538)
										local v462
										v462.coord = Vector3.new(-330.799133, 16.850575, 196.022354)
										f24 = _G["table.create"](4)
										local v463
										v463.coord = Vector3.new(-335.725586, -3.048217, -74.984589)
										local v464
										v464.coord = Vector3.new(-503.214233, -3.048217, -75.043137)
										local v465
										v465.coord = Vector3.new(-483.619385, -3.71843, -18.844337)
										f25 = -18.818844
										local v466
										v466.coord = Vector3.new(-316.147095, -3.048218, f25)
										f24 = _G["table.create"](4)
										local v467
										v467.coord = Vector3.new(-335.985413, -3.048218, 32.051426)
										local v468
										v468.coord = Vector3.new(-503.277008, -3.048217, 31.956175)
										local v469
										v469.coord = Vector3.new(-483.74939, -3.048218, 88.147003)
										f25 = 88.163979
										local v470
										v470.coord = Vector3.new(-315.793823, -3.048217, f25)
										f24 = _G["table.create"](4)
										local v471
										v471.coord = Vector3.new(-335.476654, -3.048218, 139.001083)
										f36 = nil
										v1 = true
										_continue68 = true
									end
								end
							else
								v2 = "\0Response editing type 4"
								f2(v2)
							end
						else
							v2 = "\0Response editing type 5"
							f2(v2)
						end
					end
				end
				if _continue67 then
					break
				end
				if _continue68 then
					continue
				end
				return
			end
			return (print("Server did not respond. - not"))
		end
	end
end
