local iup = require "iuplua"

local function text(multiline)
  return iup.text{
    font="Consolas, 8",
    multiline=multiline and "YES" or "NO",
    --formatting="yes",
    autohide="yes",
    expand=multiline and "yes" or "horizontal"}
end

local input = text(true)
local output = text(true)
output.readonly = "yes"

local pattern_tb = text()
local repl_tb = text()

local escapes_tog = iup.toggle{title="Escapes"}
local plain_tog = iup.toggle{title="Plain"}

local nr = iup.normalizer{escapes_tog,plain_tog,NORMALIZE="HORIZONTAL"}
local nr2 = iup.normalizer{pattern_tb,repl_tb,NORMALIZE="HORIZONTAL"}

local function depat_s(s)
  return string.gsub(s,"%W","%%%0")
end

local escape_s; do
  local specchars={
    a='\a',
    b='\b',
    f='\f',
    n='\n',
    r='\r',
    t='\t',
    v='\v',
  }
  local function escape_c(c,ctd)
    if specchars[c] then
      return specchars[c]..ctd
    elseif string.match(c,"%d") then
      local ctd, xctd = string.match(ctd, "^(%d*)(%D*)")
      local escapebyte = tonumber(c..ctd,10)
      if escapebyte > 255 then
        --Lua's parser would throw this error:
          --escape sequence too large near '"(preceding text)'
        --Tossing away the third digit circumvents any errors...
        --as ridiculous as it looks.
        xctd = string.sub(ctd,2)
        ctd = string.sub(ctd,1,1)
        escapebyte = tonumber(c..ctd,10)
      end
      return string.char(escapebyte) .. xctd
    elseif c == "x" then
      --another dumb not-an-error case.
      if ctd == "" then return "x"
      else
        return string.char(tonumber(ctd,16))
      end
    else
      --just return the literal of whatever's after the slash
      return c .. ctd
    end
  end
  function escape_s(s)
    return string.gsub(s,"\\(.)(%x?%x?)",escape_c)
  end
end

local function rungsub()
  local pattern = pattern_tb.value
  local repl = repl_tb.value
  local function iftogfit(tog,f)
    if tog.value=="ON" then
      pattern = f(pattern)
      repl = f(repl)
    end
  end
  iftogfit(escapes_tog, escape_s)
  iftogfit(plain_tog, depat_s)
  output.value = string.gsub(
    input.value, pattern, repl)
end

local runb = iup.button{title="Run",
  expand="horizontal", action=rungsub}

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

local function save_textbox(
  dlg_title, dlg_extfilter, srctext)

  file_dlg("SAVE",
    dlg_title, dlg_extfilter,
    function(filename)
      write_str_to_file(srctext.value, filename)
    end)
end

local function recycle()
  input.value=output.value
  output.value=""
end

local function openinput()
  file_dlg("OPEN",
    "Open Source Text",
    "All Files|*.*|",
    function(filename)
      input.value = file_contents(filename)
    end)
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
    iup.item{title="Save Output...",
      action=saveoutput},
    {},
    iup.item{title="Exit",
      action=iup.ExitLoop},
  }},
}

--Dialog creation and display
local dlg = iup.dialog{
  title="string.gsub",
  menu=menu,
  size="HALFxHALF",
  shrink="yes";
  iup.split{
    orientation="HORIZONTAL",
    --showgrip="no";
    iup.vbox{alignment="ACENTER"; gap="3x3"; nmargin="3x3";
      input,
      iup.hbox{alignment="ACENTER";
        iup.label{title="Pattern:"},
        pattern_tb,
        escapes_tog
      },
      iup.hbox{alignment="ACENTER";
        iup.label{title="Replacement:"},
        repl_tb,
        plain_tog
      },
    },
    iup.vbox{alignment="ACENTER"; gap="3x3"; nmargin="3x3";
      runb,
      output
    }
  }
}

dlg:show()

iup.MainLoop()
