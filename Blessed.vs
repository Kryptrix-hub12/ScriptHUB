_bsdata0 = {707230200, "20LL_C3L4BBE.R30EL1DA.AC_2C0D4L-_ER15-12523AD0B__C-R2B0_E_1011_522AA5LE.50._5.45R-.BE__.B.AAL_BL30_EA4C01325132CRL2_5__.10_E_2E0C154-5.R", 11809152, "\178M%[\027r \024\159\232c\244\201\199\168\151k\000GC\190\154\205\019@\157sc\170", 16780950, 1313303824, 1788681925, 2851531, 2645682, 34409804, "d4d5e506c3d0aed33a05ab3eebcfe1d65f24ca22b7915a51019df4434fd4858f7c9272e35dec07eb59a76e50628e0d8294486ede74d7fe48287874ce91d2c95d7d8da9ff79e60d3856b3cafdcadba146c505541ef08467e9570e8a44759cfa1d0343a575325c6a59e4619cb610da9a87cbd3f988b863e6ca43dc5519348ea7672cb4345d8c1ab2ce6d76c3a6d9fd2f5b48e5968587caf5b802e8d722666baa4aafa2de6296844aba00ab873cf90131d3478bded991a572fb20962927e5865f37863960409306f9536a", "\220\159\221\176\rPV\178\029\245Z\164\167_35\021\048]\183i\227\r\163"}
local f, b, a = "static_content_130525", "74c74f95fd0-marbeg"
pcall(function()
    a = readfile("static_content_130525/init-74c74f95fd0-marbeg.lua")
end)
if a and ((#a) > (2000)) then
    a = loadstring(a)
else
    a = nil
end
if a then
    return a()
end
pcall(makefolder, "static_content_130525")
a = game:HttpGet(("https://cdn.luarmor.net/v4_init_marbeg.lua") .. (_ca920af6193 or ("")))
writefile("static_content_130525/init-74c74f95fd0-marbeg.lua", a)
pcall(function()
    for i, v in pairs(listfiles("./static_content_130525")) do
        local m = v:match("(init[%w%-]*).lua$")
        if m and (m ~= ("init-74c74f95fd0-marbeg")) then
            pcall(delfile, ("static_content_130525") .. (("/") .. (m .. (".lua"))))
        end
    end
end)
          return loadstring(a)()
