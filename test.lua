require 'torch'
require 'libfs'
package.path = libfs.cwd()..'/'..'?;'..package.path
package.path = libfs.cwd()..'/src/?.lua;'..package.path

local MODE_DIRECTORY = 'directory'
local MODE_FILE = 'file'

cmd = torch.CmdLine()
cmd:text('Testing modules for tako')
cmd:text()
cmd:text('Options')
cmd:option('-path','','')
cmd:option('-pathForRequire','','')
cmd:text()
-- parse input params
params = cmd:parse(arg)

-- All tests should 
octest = torch.TestSuite()
octester = torch.Tester()

local function isLuaFile(path)
  return path:match("^.+/.+(.lua)$") ~= nil
end

--Forwarding directive
local processPath
--! @brief Loop through all of the files in the directory passed in
--! @param path Path of the directory
local function processDir(path, pathForRequire)
  local dir_files = libfs.readdir (path)
  --[[
  do 
    return
  end
  --]]
  for k, file in ipairs(dir_files) do
    if file ~= '.' and file ~= '..' then
      print(file)
      local curFile = path..'/'..file
      local curRequire = pathForRequire..'.'..file
      processPath(curFile, curRequire)
    end
  end
end

--! @brief Call process dir if a directory or load the file if
--!        it is a lua file
--! @param path Current path of file or directory - string
processPath = function (path, pathForRequire)
  print(path, pathForRequire)
  local pathType = libfs.stat(path).type
  if pathType == MODE_DIRECTORY then
    processDir(path, pathForRequire)
  elseif pathType == MODE_FILE and isLuaFile(path) then
    require(pathForRequire:match("^(.+)%.lua$"))
  end
end

params.pathForRequire = string.gsub(params.path, '/', ".")

local path = './tests'..params.path
local pathForRequire = 'tests'..params.pathForRequire

-- load all of the tests
processPath(path, pathForRequire)

-- add the Test Suite
octester:add(octest)
octester:run()