local iup = require "iuplua"

local function multiline(readonly)
  return iup.text{
    font="Consolas, 8",
    multiline="yes",
    --formatting="yes",
    autohide="yes",
    expand="yes"}
end

local input = multiline()
local returned = multiline()
returned.readonly = "yes"
local output = multiline()
output.readonly = "yes"
local ftext = multiline()

function print(...)
  output.value = output.value
    .. table.concat({...},'\t')
    ..'\n'
end

function io.write(...)
  output.value = output.value
    .. table.concat{...}
end

local toppanel=iup.tabs{
  tabtitle0="...",input;
  tabtitle1="return",returned;
  tabtitle2="Output",output;
}

local function runf()
  local function showerr(err)
    output.value = err
    toppanel.value = output
  end
  local f, err = loadstring(ftext.value)
  if err then
    showerr(err)
  else
    output.value=""
    local success, result = pcall(f, input.value)
    if success then
      if result then
        returned.value = result
        toppanel.value = returned
      else
        returned.value = ""
        toppanel.value = output
      end
    else
      showerr(result)
    end
  end
end

local runb = iup.button{title="Run",
  expand="horizontal", action=runf}

local dlg = iup.dialog{
  title="Lua for Strings",
  size="HALFxHALF",
  shrink="yes";
  iup.split{
    orientation="HORIZONTAL",
    showgrip="no";
    toppanel,
    iup.vbox{
      ftext, runb}
  }
}

dlg:show()

iup.MainLoop()
