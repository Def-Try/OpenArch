local process = require("process")
local serial = require("serialization")
local shell = require("shell")
local fs = require("filesystem")

local args, options = shell.parse(...)

local seg = fs.segments(shell.resolve(process.info().path))

if #args < 1 and not options.l then
  io.write("Usage: "..seg[#seg].." [command] [arguments...]\n")
  --io.write(" q: quiet mode, don't ask questions.\n")
  return
end

local function writefile(path, data)
  if not fs.exists(fs.path(path)) then
    fs.makeDirectory(fs.path(path))
  end
  local file,msg = io.open(path,"wb")
  if not file then
    man_error("Error while trying to write file at "..path..": "..msg)
    return
  end
  file:write(data)
  file:close()
end


if args[1] == "colorscheme" or args[1] == "colors" then
  if #args < 2 then
    io.write("Usage: "..seg[#seg].." "..args[1].." [<colorscheme file>]\n")
    io.write("Usage: "..seg[#seg].." "..args[1].." [BG color] [FG color]\n")
    return
  elseif #args < 3 then
    if not fs.exists(args[2]) then
      print("Colorscheme file not found.")
      return -1
    end
    local csm_file = fs.open(args[2])
    local csm_data = csm_file:read(math.huge)
    local success, csm_data = pcall(serial.unserialize, csm_data)
    if not success then
      print("Failed to decode csm data")
      return -1
    end
    local success, reason = pcall(function()
      tonumber(csm_data[1])
      tonumber(csm_data[2])
      writefile("/etc/arch/colorscheme/bg", csm_data[1])
      writefile("/etc/arch/colorscheme/fg", csm_data[2])
    end)
    if not success then
      print("Corrupted colorscheme.")
      return -1
    end
    writefile("/etc/arch/colorscheme/additional.lua", "return "..serial.serialize(csm_data[3]))

    print("Installed colorscheme. Reboot to apply changes.")
  elseif #args < 4 then
    local success, reason = pcall(function()
      tonumber(args[2])
      tonumber(args[3])
      writefile("/etc/arch/colorscheme/bg", args[2])
      writefile("/etc/arch/colorscheme/fg", args[3])
    end)
    if not success then
      print("Not-A-Number color provided")
      return -1
    end
    print("Installed colorscheme. Reboot to apply changes.")
  else
    print("Too much arguments given")
  end
else
  print("Invalid command \""..args[1].."\"")
end
