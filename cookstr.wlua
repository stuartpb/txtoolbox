--Constants------------------------------------------------------------------
--The default script to open at startup.
local startup_script = "recipes.lua"

--Libraries------------------------------------------------------------------
local iup = require "iuplua"

---File manipulation functions-----------------------------------------------
local function file_contents(filename)
  local fhandle = assert(
    io.open(filename, 'r'))
  local r = fhandle:read"*a"
  fhandle:close()
  return r
end

local function write_str_to_file(str,filename)
  local fhandle = assert(
    io.open(filename, 'w'))
  fhandle:write(str)
  fhandle:close()
end
-----------------------------------------------------------------------------

local function multiline()
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
local script_tb = multiline()
if startup_script then
  script_tb.value = file_contents(startup_script)
end

function print(...)
  local args = {...}
  local n = select('#',...)
  for i = 1, n do
    args[i] = tostring(args[i])
  end
  output.value = output.value
    .. table.concat(args,'\t')
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
  local f, err = loadstring(script_tb.value)
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

local function file_dlg(
  dlg_type, dlg_title, dlg_extfilter,
  filename_operation)

  local filedlg = iup.filedlg{
    dialogtype = dlg_type,
    title = dlg_title,
    extfilter = dlg_extfilter
  }

  filedlg:popup()

  local status = tonumber(filedlg.status)

  if status > -1 then --not canceled
    filename_operation(filedlg.value)
  end

end

local function save_textbox(
  dlg_title, dlg_extfilter, srctext)

  file_dlg("SAVE",
    dlg_title, dlg_extfilter,
    function(filename)
      write_str_to_file(srctext.value, filename)
    end)
end

local function openscript()
  file_dlg("OPEN",
    "Open Script",
    "Lua Scripts|*.lua|"..
      "All Files|*.*|",
    function(filename)
      script_tb.value = file_contents(filename)
    end)
end

local function openinput()
  file_dlg("OPEN",
    "Open Source Text",
    "All Files|*.*|",
    function(filename)
      input.value = file_contents(filename)
      toppanel.value=input
    end)
end

local function savescript()
  save_textbox("Save Script",
    "Lua Scripts|*.lua|"..
      "All Files|*.*|",
    script_tb)
end

local function savereturn()
  save_textbox("Save Return Value",
    "All Files|*.*|",
    returned)
end

local function saveoutput()
  save_textbox("Save Output",
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
    iup.item{title="Save Script...",
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
      script_tb, runb}
  }
}

dlg:show()

--scroll the script textbox to the bottom
script_tb.caretpos = #script_tb.value

iup.MainLoop()
