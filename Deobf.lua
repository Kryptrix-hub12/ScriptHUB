```lua
-- Do not save this file
-- Always use the loadstring 
  _bsdata0={2004921614,".4D-.BDE0.RLDE50ERDEAB1352A5D4_._1A2RR-EBCR-0LA-LCLCC1_5__ERCRE-AELAC5B544LE352R13E.A03E110R20D23AB2_RE10L.0CA_23R1A541DEAD114R3-L20B1",39509632,"\178\77\37\91\27\114\32\24\159\232\99\244\201\199\168\151\107\0\71\67\190\154\205\19\64\157\115\99\170",17105800,3312970299,1790099020,2851531,2645682,30604524,"741a00876243d3fb4c87906efcaa94c19cdec2aff57082eaabdafb207da445a07748353fd487b161e09dd4013018780b7cab7b579e29ddb63c8147914209efd1a76e81be9e455aa1b78ee94b8cfc300de31d349f521ed1538f03bc974f3b7b1612bf03166a72d7d6723428d320b05764b1c59dcb4e3565826a6697566fc0b67f54e0035ee3eb32f4c523319eebf2059004f944717390e92bb7cb6f9a97f0b838fe976d27c4ad6b356c7ab90532e27eaa40505d44aa53fcc1833e11f460b30a93c0c6adc23e7aa26a8f","\220\159\221\176\13\80\86\178\29\245\90\164\167\95\51\53\21\48\93\183\105\227\13\163"};
local _v2,_v3,_v1="static_content_130525","74c74f95fd0-marbeg";pcall(function()_v1=readfile(_v2.."/init-".._v3..".lua")end) if _v1 and #_v1>2000 then _v1=loadstring(_v1) else _v1=nil; end;
if _v1 then return _v1() else pcall(makefolder,_v2) _v1=game:HttpGet("https://cdn.luarmor.net/v4_init_marbeg.lua"..(_ca920af6193 or "")) writefile(_v2.."/init-".._v3..".lua", _v1); 
pcall(function() for _v6,_v5 in pairs(listfiles('./'.._v2)) do local _v4=_v5:match('(init[%_v7%-]*).lua$') if _v4 and _v4~=('init-'.._v3) then pcall(delfile, _v2..'/'.._v4..'.lua') end end; end); return loadstring(_v1)() end
```
