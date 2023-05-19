
local JD=load([===[
local rA5U=20160728.17
local Uc06="-[ JSON.lua package by Jeffrey Friedl (http://regex.info/blog/lua/json) version 20160728.17 ]-"local lcBL={VERSION=rA5U,AUTHOR_NOTE=Uc06}local DHPxI="  "
local dx={pretty=true,align_keys=false,indent=DHPxI}
local RRuSHnxf={__tostring=function()return"JSON array"end}RRuSHnxf.__index=RRuSHnxf
local mcYOuT={__tostring=function()return"JSON object"end}mcYOuT.__index=mcYOuT;function lcBL:newArray(iXxD6s)
return setmetatable(iXxD6s or{},RRuSHnxf)end;function lcBL:newObject(oiY)return
setmetatable(oiY or{},mcYOuT)end;local function Rr(FsYIVlkf)
return
type(FsYIVlkf)=='number'and FsYIVlkf or FsYIVlkf.N end
local scRP0={__index=isNumber,__tostring=function(HLXS0Q_)return HLXS0Q_.S end,__unm=function(Kw)return
Rr(Kw)end,__concat=function(nvaIsNv7,vDnoL55)
return tostring(nvaIsNv7)..tostring(vDnoL55)end,__add=function(xlAK,zr1y)return Rr(xlAK)+Rr(zr1y)end,__sub=function(Hs,jk)return
Rr(Hs)-Rr(jk)end,__mul=function(qzSFyIO,Z65)
return Rr(qzSFyIO)*Rr(Z65)end,__div=function(umyCNfj,FT)return Rr(umyCNfj)/Rr(FT)end,__mod=function(YVLXYq,bJfct)return
Rr(YVLXYq)%Rr(bJfct)end,__pow=function(OhuFpq_N,Dzg)return
Rr(OhuFpq_N)^Rr(Dzg)end,__lt=function(_4O,C)return Rr(_4O)<Rr(C)end,__eq=function(fLI2zRe,_Fr2YU)return
Rr(fLI2zRe)==Rr(_Fr2YU)end,__le=function(Xfn,U)return
Rr(Xfn)<=Rr(U)end}
function lcBL:asNumber(Ebsw)
if getmetatable(Ebsw)==scRP0 then return Ebsw elseif
type(Ebsw)=='table'and
type(Ebsw.S)=='string'and type(Ebsw.N)=='number'then return setmetatable(Ebsw,scRP0)else
local UlikV={S=tostring(Ebsw),N=tonumber(Ebsw)}return setmetatable(UlikV,scRP0)end end
local function AI0R2TQ6(JtAjijkG)
if JtAjijkG<=127 then return string.char(JtAjijkG)elseif JtAjijkG<=2047 then
local s=math.floor(JtAjijkG/0x40)local YAtG_LV3=JtAjijkG- (0x40*s)return
string.char(0xC0+s,0x80+YAtG_LV3)elseif JtAjijkG<=65535 then
local LfEJbh_=math.floor(JtAjijkG/0x1000)local JD=JtAjijkG-0x1000*LfEJbh_
local u=math.floor(JD/0x40)local pzDMZwG=JD-0x40*u;LfEJbh_=0xE0+LfEJbh_;u=0x80+u
pzDMZwG=0x80+pzDMZwG
if

(LfEJbh_==0xE0 and u<0xA0)or
(LfEJbh_==0xED and u>0x9F)or(LfEJbh_==0xF0 and u<0x90)or(LfEJbh_==0xF4 and u>0x8F)then return"?"else return string.char(LfEJbh_,u,pzDMZwG)end else local XPoQB=math.floor(JtAjijkG/0x40000)
local XxJ=JtAjijkG-0x40000*XPoQB;local o5sms=math.floor(XxJ/0x1000)
XxJ=XxJ-0x1000*o5sms;local JQi1jg=math.floor(XxJ/0x40)local wVzn=XxJ-0x40*JQi1jg
return string.char(
0xF0+XPoQB,0x80+o5sms,0x80+JQi1jg,0x80+wVzn)end end
function lcBL:onDecodeError(pE,RSjapQ,QJf,zC)if RSjapQ then
if QJf then
pE=string.format("%s at char %d of: %s",pE,QJf,RSjapQ)else pE=string.format("%s: %s",pE,RSjapQ)end end
if zC~=nil then pE=pE.." ("..
lcBL:encode(zC)..")"end
if self.assert then self.assert(false,pE)else assert(false,pE)end end;lcBL.onDecodeOfNilError=lcBL.onDecodeError
lcBL.onDecodeOfHTMLError=lcBL.onDecodeError
function lcBL:onEncodeError(pfZ3SPy_,pDNa2ox6)
if pDNa2ox6 ~=nil then pfZ3SPy_=pfZ3SPy_..
" ("..lcBL:encode(pDNa2ox6)..")"end;if self.assert then self.assert(false,pfZ3SPy_)else
assert(false,pfZ3SPy_)end end
local function yA(Do6yo7nm,y06X3k,ivnJjrA,d3fMjkg)
local el=y06X3k:match('^-?[1-9]%d*',ivnJjrA)or y06X3k:match("^-?0",ivnJjrA)if not el then
Do6yo7nm:onDecodeError("expected number",y06X3k,ivnJjrA,d3fMjkg.etc)end
local Wu_uIt=ivnJjrA+el:len()local w=y06X3k:match('^%.%d+',Wu_uIt)or""Wu_uIt=Wu_uIt+
w:len()
local sgeP=y06X3k:match('^[eE][-+]?%d+',Wu_uIt)or""Wu_uIt=Wu_uIt+sgeP:len()local CM=el..w..sgeP;if
d3fMjkg.decodeNumbersAsObjects then return lcBL:asNumber(CM),Wu_uIt end
if

(
d3fMjkg.decodeIntegerStringificationLength and(el:len()>=d3fMjkg.decodeIntegerStringificationLength or
sgeP:len()>0))or
(d3fMjkg.decodeDecimalStringificationLength and
(
w:len()>=d3fMjkg.decodeDecimalStringificationLength or sgeP:len()>0))then return CM,Wu_uIt end;local Qlmlet=tonumber(CM)if not Qlmlet then
Do6yo7nm:onDecodeError("bad number",y06X3k,ivnJjrA,d3fMjkg.etc)end;return Qlmlet,Wu_uIt end
local function XmVolesU(_,RkGFh6,hw18,nvCiFt7r)if RkGFh6:sub(hw18,hw18)~='"'then
_:onDecodeError("expected string's opening quote",RkGFh6,hw18,nvCiFt7r.etc)end;local xSebv5Jc=hw18+1
local mMp=RkGFh6:len()local rDtVf=""
while xSebv5Jc<=mMp do local vj=RkGFh6:sub(xSebv5Jc,xSebv5Jc)if
vj=='"'then return rDtVf,xSebv5Jc+1 end
if vj~='\\'then rDtVf=rDtVf..vj;xSebv5Jc=
xSebv5Jc+1 elseif RkGFh6:match('^\\b',xSebv5Jc)then rDtVf=rDtVf.."\b"xSebv5Jc=
xSebv5Jc+2 elseif RkGFh6:match('^\\f',xSebv5Jc)then rDtVf=rDtVf.."\f"xSebv5Jc=
xSebv5Jc+2 elseif RkGFh6:match('^\\n',xSebv5Jc)then rDtVf=rDtVf.."\n"xSebv5Jc=
xSebv5Jc+2 elseif RkGFh6:match('^\\r',xSebv5Jc)then rDtVf=rDtVf.."\r"xSebv5Jc=
xSebv5Jc+2 elseif RkGFh6:match('^\\t',xSebv5Jc)then rDtVf=rDtVf.."\t"xSebv5Jc=
xSebv5Jc+2 else
local z=RkGFh6:match('^\\u([0123456789aAbBcCdDeEfF][0123456789aAbBcCdDeEfF][0123456789aAbBcCdDeEfF][0123456789aAbBcCdDeEfF])',xSebv5Jc)
if z then xSebv5Jc=xSebv5Jc+6;local Zg=tonumber(z,16)
if
Zg>=0xD800 and Zg<=0xDBFF then
local ykRppH=RkGFh6:match('^\\u([dD][cdefCDEF][0123456789aAbBcCdDeEfF][0123456789aAbBcCdDeEfF])',xSebv5Jc)
if ykRppH then xSebv5Jc=xSebv5Jc+6;Zg=0x2400+ (Zg-0xD800)*0x400+
tonumber(ykRppH,16)else end end;rDtVf=rDtVf..AI0R2TQ6(Zg)else rDtVf=rDtVf..
RkGFh6:match('^\\(.)',xSebv5Jc)xSebv5Jc=xSebv5Jc+2 end end end
_:onDecodeError("unclosed string",RkGFh6,hw18,nvCiFt7r.etc)end
local function eZ0l3ch(WQ6,y36Aetn)local iPL3B4cr,GI2hz6SK=WQ6:find("^[ \n\r\t]+",y36Aetn)if GI2hz6SK then
return GI2hz6SK+1 else return y36Aetn end end;local W_63_9
local function h9dyA_4T(Oh,PG,n,O)if PG:sub(n,n)~='{'then
Oh:onDecodeError("expected '{'",PG,n,O.etc)end;local N5UjTN=eZ0l3ch(PG,n+1)local qLH5=Oh.strictTypes and
Oh:newObject{}or{}if
PG:sub(N5UjTN,N5UjTN)=='}'then return qLH5,N5UjTN+1 end
local tE=PG:len()
while N5UjTN<=tE do local VcV0EuD,pX4gCR=XmVolesU(Oh,PG,N5UjTN,O)
N5UjTN=eZ0l3ch(PG,pX4gCR)if PG:sub(N5UjTN,N5UjTN)~=':'then
Oh:onDecodeError("expected colon",PG,N5UjTN,O.etc)end
N5UjTN=eZ0l3ch(PG,N5UjTN+1)local gad4ZcL,pX4gCR=W_63_9(Oh,PG,N5UjTN,O)qLH5[VcV0EuD]=gad4ZcL
N5UjTN=eZ0l3ch(PG,pX4gCR)local dk=PG:sub(N5UjTN,N5UjTN)
if dk=='}'then return qLH5,N5UjTN+1 end;if PG:sub(N5UjTN,N5UjTN)~=','then
Oh:onDecodeError("expected comma or '}'",PG,N5UjTN,O.etc)end
N5UjTN=eZ0l3ch(PG,N5UjTN+1)end;Oh:onDecodeError("unclosed '{'",PG,n,O.etc)end
local function oh(E,OO,y,cR6rJlAl)if OO:sub(y,y)~='['then
E:onDecodeError("expected '['",OO,y,cR6rJlAl.etc)end;local M6ilzGJ=eZ0l3ch(OO,y+1)local iW6CD=E.strictTypes and
E:newArray{}or{}if
OO:sub(M6ilzGJ,M6ilzGJ)==']'then return iW6CD,M6ilzGJ+1 end
local wZdg=1;local BaX=OO:len()
while M6ilzGJ<=BaX do
local SJsW11k,Ki1HJT=W_63_9(E,OO,M6ilzGJ,cR6rJlAl)iW6CD[wZdg]=SJsW11k;wZdg=wZdg+1;M6ilzGJ=eZ0l3ch(OO,Ki1HJT)
local wjim8xCV=OO:sub(M6ilzGJ,M6ilzGJ)if wjim8xCV==']'then return iW6CD,M6ilzGJ+1 end;if
OO:sub(M6ilzGJ,M6ilzGJ)~=','then
E:onDecodeError("expected comma or '['",OO,M6ilzGJ,cR6