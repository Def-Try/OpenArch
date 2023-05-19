--[[
PACkage MANager - pacman
-- by googer (Def-Try), 19.05.23
]]
local component = require("component")
local event = require("event")
local fs = require("filesystem")
local serial = require("serialization")
local shell = require("shell")
local process = require("process")
local term = require("term")

local gpu = component.gpu

local internet

local args, options = shell.parse(...)

local repositories = {
  {"OPPM", "https://raw.githubusercontent.com/OpenPrograms/openprograms.github.io/master/repos.cfg"},
--  {"HPM", "!!NOT_SUPPORTED!!"}
}

local function man_error(...)
  if not superquiet then
    io.stderr:write("ERROR:\n  " .. ... .. "\n")
  end
end

if not component.isAvailable("internet") then
  man_error("This program requires an internet card to run.")
  return false
end

internet = require("internet")

--for k,v in pairs(args) do print(v) end
--for k,v in pairs(options) do print(k, v) end

local autoagree = options["y"] or false
local superquiet = options["q"] or false
local verbose = options["v"] or false
local quiet = options["c"] or false

local cmd_update = options["u"] or false
local cmd_install = options["S"] or false
local cmd_uninstall = options["R"] or false
local cmd_list = options["Q"] or false

local installpath = "/usr"

local print = print

if #options < 0 and #args < 0 or args['h'] then
  local seg = fs.segments(shell.resolve(process.info().path))
  print("Usage: "..seg.."[-SRQu] <-yqvc> <packages...>"..[[
    PacMan is a package manager that supports OPPM repositories
    -S - inStall packages
    -R - Remove packages
    -Q - list packages
    -u - Update package list

    -y - auto "yes" everywhere
    -q - Superquiet mode - do not output anyting at all
    -v - Verbose mode - output every action
    -c - Quiet mode - output less info
  ]])
end

if superquiet then
  function print(...) end
end

if (cmd_update and cmd_uninstall) or (cmd_install and cmd_uninstall) then
  man_error("-R flag is not allowed with other action flags")
  return -1
end

local freshinstall = not (fs.exists("/etc/pacman") and fs.exists("/etc/pacman/cache/pkgs.cfg") and fs.exists("/etc/pacman/cache/repos.cfg"))

local function man_yn(msg)
  if superquiet then return true end
  print(msg)
  io.write("[Y]es/[N]o > ")
  if autoagree then io.write("yes\n") return true end
  local inp = ""
  repeat
    inp = io.read(1)
  until #inp > 0
  local _ = ""
  repeat
    _ = io.read(1)
  until _ == "\n"
  if inp:sub(1,2):lower() == "y" then return true end
  return false
end

local function download(url, filename)
  if not fs.exists(fs.path(filename)) then
    fs.makeDirectory(fs.path(filename))
  end
  local f
  local result, response = pcall(internet.request, url)
  if result then
    local result, reason = pcall(function()
      for chunk in response do
        if not f then
          f, reason = io.open(filename, "wb")
          if not f then
            man_error("Failed opening file for writing: "..reason)
            return nil, reason
          end
        end
        f:write(chunk)
      end
    end)
    if not result then
      if f then
        f:close()
        fs.remove(filename)
      end
      man_error("HTTP request failed: "..reason)
      return nil, reason
    end
    
    if f then
      f:close()
    end
  else
    man_error("HTTP request failed: "..reason)
    return nil, response
  end
  return true
end

local function geturl(url)
  local sContent = ""
  local result, response = pcall(internet.request, url)
  if not result then
    return nil
  end
  for chunk in response do
    sContent = sContent..chunk
    local got = {}
    for s in sContent:gmatch("[^\r\n]+") do
      table.insert(got, s)
    end
    if verbose then
      io.stdout:write("\r"..#got.." chunks retreived")
    end
  end
  if verbose then print() end
  return sContent
end

local function readfile(path)
  if not fs.exists(fs.path(path)) then
    fs.makeDirectory(fs.path(path))
  end
  if not fs.exists(path) then
    return -1
  end
  local file,msg = io.open(path,"rb")
  if not file then
    man_error("Error while trying to read file at "..path..": "..msg)
    return
  end
  local data = file:read("*a")
  file:close()
  return data
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

local function move(from, to)
  local ok, reason = fs.copy(from, to)
  if not ok then return nil, reason end
  fs.remove(from)
  return true
end

local function man_updatelists()
  if not man_yn("Are you sure that you want to update ALL package lists?") then
    print("Aborted lists update.")
    return false
  end

  local retv_repos = {}
  local retreived = 0
  for n,parent in pairs(repositories) do
    print("Retreiving '"..parent[1].."' subrepositories ("..n.."/"..#repositories..") ...")
    local success, repos = pcall(geturl,parent[2])
    if not success then
      man_error("Could not connect to the Internet. Please ensure you have an Internet connection.")
      return -1
    end
    for k,v in pairs(serial.unserialize(repos)) do
      retv_repos[#retv_repos+1] = {k, v}
      if verbose then
        io.stdout:write("\r"..#retv_repos-retreived.." sub-repositories updated")
      end
    end
    retreived = #retv_repos
    if verbose then print() end
  end
  if verbose then
    print("Retreived total of "..#retv_repos.." sub-repositories")
  end
  writefile("/etc/pacman/cache/repos.cfg", serial.serialize(retv_repos))
  if verbose then
    print("Cache saved")
  end

  if verbose then
    print("Retreiving packages...")
  end

  local packages = {}

  for n,_repo in pairs(retv_repos) do
    repo = _repo[2]
    if repo.repo then
      print("Checking sub-repository ".._repo[1].." ("..n.."/"..#retv_repos..")")
      local success, pkgs = pcall(geturl,"https://raw.githubusercontent.com/"..repo.repo.."/master/programs.cfg")
      if not success then
        man_error("Error while trying to receive package list for " .. _repo[1])
      else
        pkgs = serial.unserialize(pkgs)
        if pkgs then
          for k,kt in pairs(pkgs) do
            packages[#packages+1] = {k, kt, "https://raw.githubusercontent.com/"..repo.repo}
            if verbose then
              io.stdout:write("\r"..#packages.." packages updated")
            end
          end
          if verbose then print() end
        else
          man_error("Error while trying to receive package list for " .. _repo[1])
        end
      end
    else
      print("Checking sub-repository ".._repo[1].." ("..n.."/"..#retv_repos..")")
      man_error("Error while trying to receive package list for " .. _repo[1])
    end
  end
  print()

  if verbose then
    print("Retreived total of "..#packages.." package(s)")
  end
  writefile("/etc/pacman/cache/pkgs.cfg", serial.serialize(packages))
  if verbose then
    print("Cache saved")
  end

  return true
end

if cmd_update or freshinstall then
  if freshinstall and not quiet then
    print("Fresh installation detected: initialising PacMan...")
    autoagree = true
  end
  if not man_updatelists() then
    man_error("Repositories update failed. Aborting.")
  end
  print("Update done")
end

local function printtable(tbl, deep)
  if not deep then deep = 0 end
  for k,v in pairs(tbl) do
    if type(v) ~= 'table' then
      print(string.rep("  ", deep)..k, v)
    else
      printtable(v, deep+1)
    end
  end
end

if cmd_uninstall then
  if #args < 1 then
    man_error("No packages found to uninstall")
    return -1
  end
  print("Found "..#args.." package(s) to uninstall: ")
  for _,i in pairs(args) do
    print("  "..i)
  end

  if not man_yn("Are you sure that you want to uninstall these packages?") then
    print("Aborted uninstallation.")
    return -1
  end

  local touninstall = {}
  print("Uninstalling...")
  local fail = false
  local reg = readfile("/etc/pacman/registered.cfg")
  if reg == -1 then reg = {} end
  if type(reg) == 'string' then
    reg = serial.unserialize(reg)
  end
  for n,i in pairs(args) do
    if not quiet then print("Searching package "..i.." ("..n.."/"..#args..")") end
    local ok = false
    for _,pkg in pairs(reg) do
      if pkg[1] == i then
        touninstall[#touninstall+1] = pkg
        ok = true
        break
      end
    end
    if not ok then
      man_error("Package "..i.." not installed.")
      fail = true
    end
  end
  if fail then
    return -1
  end
  for n,provider in pairs(touninstall) do
    if not quiet then print("Uninstalling package "..provider[1].." ("..n.."/"..#touninstall..")") end
    for rfile, lpath in pairs(provider[2].files) do
      local to = fs.segments("/"..rfile)
      to = to[#to]
      if verbose then
        print("Uninstalling file: "..installpath..lpath.."/"..to)
      end
      fs.remove(installpath..lpath.."/"..to)
    end
    if verbose then
      print("Unregistering package "..provider[1].."... ")
    end
    local unregistering = true
    while true do
      unregistering = false
      for n,pkg in pairs(reg) do
        if pkg[1] == provider[1] then
          table.remove(reg, n)
          unregistering = true
          break
        end
      end
      if not unregistering then break end
    end
  end
  writefile("/etc/pacman/registered.cfg", serial.serialize(reg))
end

if cmd_install then
  if #args < 1 then
    man_error("No packages found to install")
    return -1
  end
  print("Found "..#args.." package(s) to install: ")
  for _,i in pairs(args) do
    print("  "..i)
  end

  if not man_yn("Are you sure that you want to install these packages?") then
    print("Aborted installation.")
    return -1
  end

  print("Installing...")
  local packages = readfile("/etc/pacman/cache/pkgs.cfg")
  if packages == -1 then
    man_error("Package list not found!")
    return -1
  end
  packages = serial.unserialize(packages)
  local toinstall = {}
  local fail = false
  local reg = readfile("/etc/pacman/registered.cfg")
  if reg == -1 then reg = {} end
  if type(reg) == 'string' then
    reg = serial.unserialize(reg)
  end
  for n,i in pairs(args) do
    if not quiet then print("Searching package "..i.." ("..n.."/"..#args..")") end
    local found = false
    for _,provider in pairs(packages) do
      if provider[1] == i then
        found = true
        toinstall[#toinstall + 1] = provider
      end
    end
    if not found then
      man_error("Package "..i.." not found")
      fail = true
    else
      for _,regpkg in pairs(reg) do
        for j,inspkg in pairs(toinstall) do
          if regpkg[1] == inspkg[1] then
            print("Package "..regpkg[1].." is already installed - reinstalling.")
            local unregistering = true
            while true do
              unregistering = false
              for n,pkg in pairs(reg) do
                if pkg[1] == i then
                  table.remove(reg, n)
                  unregistering = true
                  break
                end
              end
              if not unregistering then break end
            end
          end
        end
      end
    end
  end
  if fail then return -1 end
  for n,provider in pairs(toinstall) do
    if not quiet then print("Installing package "..provider[1].." ("..n.."/"..#toinstall..")") end
    for rfile, lpath in pairs(provider[2].files) do
      local to = fs.segments("/"..rfile)
      to = to[#to]
      if verbose then
        print("Installing file: "..installpath..lpath.."/"..to)
      end
      download(provider[3].."/"..rfile, installpath..lpath.."/"..to)
    end
    if verbose then
      print("Registering package "..provider[1].."... ")
    end
    reg[#reg + 1] = provider
    writefile("/etc/pacman/registered.cfg", serial.serialize(reg))
  end
end

if cmd_list then
  local installed = readfile("/etc/pacman/registered.cfg")
  if installed == -1 then
    print("No pacman registration file found. Try installing any package.")
    return -1
  end
  installed = serial.unserialize(installed)
  for _,pkg in pairs(installed) do
    print(pkg[1])
  end
end
