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

--File menu functions

local function load_file(
  dlg_title, dlg_extfilter,
  text_to_load_into)

  local filedlg = iup.filedlg{
    dialogtype = "OPEN", title = dlg_title,
    extfilter = dlg_extfilter}

  filedlg:popup()

  local status = tonumber(filedlg.status)

  if status > -1 then --not canceled
    local fhandle = assert(
      io.open(filedlg.value, 'r'))
    text_to_load_into.value = fhandle:read"*a"
    fhandle:close()
  end
end

local function save_file(
  dlg_title, dlg_extfilter,
  text_to_save_from)

  local filedlg = iup.filedlg{
    dialogtype = "SAVE", title = dlg_title,
    extfilter = dlg_extfilter}

  filedlg:popup()

  local status = tonumber(filedlg.status)

  if status > -1 then --Not canceled
    local fhandle = assert(
      io.open(filedlg.value, 'w'))
    fhandle:write(text_to_save_from.value)
    fhandle:close()
  end
end

local function openscript()
  load_file("Open Script",
    "Lua Scripts|*.lua|"..
    "All Files|*.*|",
    ftext)
end

local function openinput()
  load_file("Open Source Text",
    "All Files|*.*|",
    input)
end

local function savescript()
  save_file("Save Script",
    "Lua Scripts|*.lua|"..
    "All Files|*.*|",
    ftext)
end

local function savereturn()
  save_file("Save Return Value",
    "All Files|*.*|",
    returned)
end

local function saveoutput()
  save_file("Save Output",
    "All Files|*.*|",
    output)
end

local menu = iup.menu{
  {"File",iup.menu{
    iup.item{title="Open Input...",
      action=openinput},
    iup.item{title="Open Script...",
      action=openscript},
    {},
    iup.item{title="Save Result...",
      action=savereturn},
    iup.item{title="Save Output...",
      action=saveoutput},
    iup.item{title="Save Output...",
      action=savescript},
    {},
    iup.item{title="Exit",
      action=iup.ExitLoop},
  }},
}

--Dialog creation and display
local dlg = iup.dialog{
  title="Lua for Strings",
  menu=menu,
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
