require "yaml"

pit = {}

local home = os.getenv("HOME")
local editor = os.getenv("EDITOR")

function pit.switch(profile)
  pit.path.profile = pit.path.pitdir .. profile .. ".yaml"
  local file = io.open(pit.path.config, "w")
  if not file then
    io.stderr:write("cannot open "..pit.path.config)
    return nil
  end
  file:write(yaml.dump({profile="default"}))
  file:flush()
  file:close()
  return profile
end
function pit.profile()
  local data = yaml.load_file(pit.path.config)
  if data then
    profile = data.profile
  elseif not profile then
    pit.switch("default")
    profile = "default"
  end
  return profile
end
function pit.edit(name, req)
  local path = os.tmpname()
  local tmp = io.open(path, "w")
  local opt = {}
  opt[name] = req
  tmp:write(yaml.dump(opt))
  tmp:flush()
  os.execute(editor.." "..path)
  opt = yaml.load_file(path)
  tmp:close()
  os.remove(path)
  return opt[name]
end
function pit.validopt(opt, req)
  for i,v in pairs(req) do
    if not opt[i] then
      return false
    end
  end
  return true
end
function pit.get(name, req)
  local opts = yaml.load_file(pit.path.profile)
  if not opts then
    opts = {}
    opts[name] = {}
  elseif not opts[name] then
    opts[name] = {}
  elseif pit.validopt(opts[name], req) then
    return opts[name]
  end
  local opt = pit.edit(name, req)
  for i,v in pairs(opt) do
    opts[name][i] = v
  end
  local file = io.open(pit.path.profile, "w")
  file:write(yaml.dump(opts))
  file:close()
  return opts[name]
end

pit.path = {}
pit.path.pitdir = home .. "/.pit/"
pit.path.config = pit.path.pitdir.."pit.yaml"
pit.path.profile = pit.path.pitdir..pit.profile()..".yaml"

-- print(yaml.dump(pit.get("test", {username="id",password="password"})))
