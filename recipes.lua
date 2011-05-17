local src = ...

--Swaps case.
local function swapcase(c)
  local function swapper(c)
    if c == string.lower(c) then return string.upper(c)
    else return string.lower(c) end
  end

  return (string.gsub(src,'%a',swapcase))
end

--Escape all possible special pattern characters.
local function plain(str)
  return (string.gsub(str,"[^%w%s]","%%%0"))
end

--Replaces all spans of whitespace with match for any span of whitespace.
local function gspace(str)
  return (string.gsub(str,"%s+","%%s%+"))
end

--Replaces all whitespace spans with a single space.
local function normspace(str)
  return (string.gsub(str,"%s+"," "))
end

--Counts instances of a pattern.
local function count(pat, fun)
  return select(2,string.gsub(src,pat,fun or ""))
end
