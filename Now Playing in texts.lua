function descriptor()
  return { title = "Now Playing in texts v2",
    version = "2.1",
    author = "un_pogaz",
    url = "",
    description = [[
Write the metadatas of the curent playing song in texts files.
You can create customs outputs files, read the doc for more detailed information.

The TXT's will be saved in your VLC user director which can be found in the following places
  Linux: ~/.local/share/vlc/
  Windows: %APPDATA%\vlc\
  Mac OS X: /Users/%your_name%/Library/Application Support/org.videolan.vlc/
]],
--  shortdesc = "Now Playing in texts",
    capabilities = { "input-listener" },
    icon = NP_icon
  }
end

--[[
Now Playing in texts, extension for VLC media player

-------------------------
Installation Instructions
-------------------------

Place this file in the corresponding folder and restart VLC or reload plugin extensions.

Linux:
  Current User: ~/.local/share/vlc/lua/extensions/
     All Users: /usr/lib/vlc/lua/extensions/

Windows:
  Current User: %APPDATA%\vlc\lua\extensions
     All Users: %ProgramFiles%\VideoLAN\VLC\lua\extensions\

Mac OS X:
  Current User: /Users/%your_name%/Library/Application Support/org.videolan.vlc/lua/extensions/
     All Users: /Applications/VLC.app/Contents/MacOS/share/lua/extensions/

--]]


-- Activate & Deactivate
function activate()
  vlc.msg.dbg("[Now Playing texts] Activate")
  init()
  update_files()
end
function close()
  clear_files()
  vlc.msg.dbg("[Now Playing texts] Close")
end
function deactivate()
  clear_files()
  vlc.msg.dbg("[Now Playing texts] Deactivate")
end

-- Triggers
function input_changed()
  update_files()
end
function meta_changed()
  update_files()
end

----------------
-- global values

names = { "filename", "title", "artist", "album",
    "genre", "date", "description",
    "COMPOSER", "ALBUMARTIST",
    "now_playing",
    "name", "duration", "duration_1" }

names0 = { "track_number", "track_total", "DISCNUMBER" } -- this names exist wiht a 0 variante

path = { ["uri"]="filepath", ["artwork_url"]="artwork" }

not_playing = "NOT_PLAYING"

default_file = {}
metadata = {}
is_playing = "is_playing_bool"

-- initialisation
function init()
  vlc.msg.dbg("[Now Playing texts] init()")
  
  for i, n in pairs(names0) do
    table.insert(names, n)
    table.insert(names, n .. "0")
  end
  for k, v in pairs(path) do
    table.insert(names, k)
    table.insert(names, v)
  end
  table.sort(names)
  
  metadata = {}
  
  default_file = {}
  
  default_file["title"] = {"{title}", "{filename}"}
  default_file["artist"] = {"{artist}"}
  default_file["album"] = {"{album}"}
  default_file["artist_title"] = {"{artist} - {title}", "{title}", "{filename}"}
  
  default_file["radio"] = {"{now_playing}", "{title}", "{filename}"}
  default_file["bandcamp"] = {"{artist} - {album} - {track_number0} {title}", "{artist} - {album} - {title}", "{artist} - {title}", "{title}", "{filename}"}
  
end

---------------
-- update files

function update_files()
  vlc.msg.dbg("[Now Playing texts] update_files()")
  metadata = get_metadata()
  write_all_files()
end
function clear_files()
  vlc.msg.dbg("[Now Playing texts] clear_files()")
  metadata[is_playing] = false
  write_all_files()
end

function write_all_files()
  
  for k, v in pairs(default_file) do
    write_pattern(k, v)
  end
  
  for o, ptr in get_custom_files() do
    if ptr then
      write_pattern(o, ptr)
    else
      os.remove(get_filename(o))
    end
  end
  
  write_metadata()
  
  write_artwork()
  
end

-- get metadata (safe)
function get_metadata()
  
  local rslt = {}
  rslt[is_playing] = vlc.input.is_playing()
  
  if not rslt[is_playing] then
    return rslt
  end
  
  local item = vlc.input.item()
  local metas = item:metas()
  
  --debug_metadata(metas)
  
  for i, n in pairs(names) do
    rslt[n] = metas[n]
  end
  
  rslt["uri"] = item:uri()
  
  rslt["name"] = item:name()
  
  local t_s = item:duration()
  local t_m = 0
  local t_h = 0
  
  if t_s then
    t_s = truncate(t_s)
    if t_s > 0 then
      t_m = truncate(t_s / 60)
      t_h = truncate(t_m / 60)
      t_s = t_s - t_m * 60
      t_m = t_m - t_h * 60
    end
    
    local duration = tostring(t_s)
    
    if (t_s >= 0) and (t_s < 10) then
      duration = "0" .. duration
    end
    if t_s >= 0 then
      duration = t_m .. ":" .. duration
    end
    if t_h > 0 then
      if t_m < 10 then
        duration = "0" .. duration
      end
      duration = t_h .. ":" .. duration
    end
    
    rslt["duration_1"] = duration
    if t_s >= 0 then
      rslt["duration"] = duration
    end
    
  end
  
  -- set names0
  for i, n in pairs(names0) do
    if rslt[n] then
      local n0 = n .. "0"
      rslt[n] = tostring(rslt[n])
      rslt[n0] = rslt[n]
      while string.len(rslt[n0]) < 2 do
        rslt[n0] = "0" .. rslt[n0]
      end
    end
  end
  
  -- set path
  for k, v in pairs(path) do
    local uri = rslt[k]
    if uri then
      local status, url = pcall(vlc.strings.url_parse, uri)
      if not status then
        status, url = pcall(vlc.net.url_parse, uri)
      end
      if not status then
        url = {}
      end
      
      if url["protocol"] == "file" then
        uri = vlc.strings.decode_uri(url["path"])
        if string.find(uri, "^/%a:/") then
          uri = string.sub(uri, 2)
        end
        rslt[v] = uri;
      end
    end
  end
  
  -- trim white space
  local s, e
  for k, v in pairs(rslt) do
    if type(v) == type("") then
      s, e = string.find(v, "^%s+")
      if e then
        v = string.sub(v, e+1)
      end
      s, e = string.find(v, "%s+$")
      if s then
        v = string.sub(v, 1, s-1)
      end
      if v == "" then
        v = nil
      end
      rslt[k] = v
    end
  end
  
  return rslt
end

---------------
-- output files

function write_pattern(name, patterns)
  vlc.msg.dbg("[Now Playing texts] write file > " .. name)
  
  if not metadata[is_playing] then
    local is_playing_line = get_not_playing(patterns[table.getn(patterns)])
    if is_playing_line then
      vlc.msg.dbg("[Now Playing texts] not playing > " .. is_playing_line)
    else
      vlc.msg.dbg("[Now Playing texts] not playing <empty file>")
      is_playing_line = ""
    end
    write_file(name, is_playing_line)
    return
  end
  
  for i, ptr in ipairs(patterns) do
    
    local is_playing_line = get_not_playing(ptr)
    if is_playing_line then
      -- next pattern
    else
      
      local used_name = get_used_name(ptr)
      local used_name_lenght = table.getn(used_name)
      
      if used_name_lenght == 0 then
        -- if no valide name, write the text
        vlc.msg.dbg("[Now Playing texts] pattern > " .. ptr)
        write_file(name, ptr)
        return
        
      else
        local valide_meta = get_valide_meta(used_name)
        local valide_meta_lenght = 0
        for w, v in pairs(valide_meta) do
          valide_meta_lenght = valide_meta_lenght +1
        end
        
        if used_name_lenght ~= valide_meta_lenght then
          -- next pattern
        else
          
          vlc.msg.dbg("[Now Playing texts] pattern > " .. ptr)
          local index_name = get_index_name(ptr, used_name)
          local rslt = {}
          for i, rev in reverse(index_name) do
            --exctract the end of the patern for replace only the last one metadata
            local fin = string.sub(ptr, rev[1])
            rslt[i+1] = valide_meta[rev[2]] .. string.sub(fin, string.len(k_w(rev[2]))+1)
            ptr = string.sub(ptr, 0, rev[1]-1)
          end
          rslt[1] = ptr
          
          write_file(name, table.concat(rslt, "")) --rebuild the string and write
          return
        end
      end
    end
  end
  
  vlc.msg.dbg("[Now Playing texts] no matching pattern <empty file>")
  write_file(name, "")
  return
end

function write_metadata()
  local mdt1 = {}
  local mdt2 = {}
  local m = "";
  
  if metadata[is_playing] then
    for i, v in ipairs(names) do
      m = metadata[v]
      if m then
        table.insert(mdt1, k_w(v)..":")
        table.insert(mdt1, "\t"..m)
        table.insert(mdt2, k_w(v)..":")
        table.insert(mdt2, "\t"..m)
      else
        table.insert(mdt2, k_w(v)..":")
        table.insert(mdt2, "")
      end
    end
  else
    table.insert(mdt1, not_playing)
    table.insert(mdt2, not_playing)
  end
  
  vlc.msg.dbg("[Now Playing texts] write file > metadata")
  write_file("metadata", table.concat(mdt1, "\n"))
  vlc.msg.dbg("[Now Playing texts] write file > metadata_full")
  write_file("metadata_full", table.concat(mdt2, "\n"))
end

function write_artwork()
  local artwork = vlc.config.userdatadir() .. "/np_artwork.jpg"
  local src = metadata["artwork"]
  if metadata[is_playing] and src then
    local fi_r = io.open(src, "rb")
    if fi_r then
      vlc.msg.dbg("[Now Playing texts] write artwork > np_artwork.jpg")
      local fi_w = io.open(artwork, "wb")
      local nr = 2^16
      local bytes = fi_r:read(nr)
      while bytes ~= nil do
        fi_w:write(bytes)
        bytes = fi_r:read(nr)
      end
      fi_w:close()
      fi_r:close()
      
      return
    end
  end
  
  vlc.msg.dbg("[Now Playing texts] no artwork <empty artwork>")
  local fi_w = io.open(artwork, "wb")
  fi_w:write(NP_transparent)
  fi_w:close()
end

function debug_metadata(metas)
  local rslt = {}
  for k, v in pairs(metas) do
    table.insert(rslt, k.."=")
    table.insert(rslt, "\t"..v)
  end
  vlc.msg.dbg("[Now Playing texts] write file > debug_metadata")
  write_file("debug_metadata", table.concat(rslt, "\n"))
end

-------------------
-- various function

function get_not_playing(pattern)
  local key_word = k_w(not_playing)
  if (string.len(pattern) >= string.len(key_word)) and (string.sub(string.lower(pattern), 0, string.len(key_word)) == key_word) then
    return string.sub(pattern, string.len(key_word)+1)
  end
  return nil
end
function get_used_name(pattern)
  local rslt = {}
  pattern = string.lower(pattern)
  for i, n in ipairs(names) do
    if string.match(pattern, k_w(n)) then
      table.insert(rslt, n)
    end
  end
  return rslt
end
function get_valide_meta(used_name)
  local rslt = {}
  for i, n in ipairs(used_name) do
    rslt[n] = metadata[n]
  end
  return rslt
end
function get_index_name(pattern, used_name)
  local rslt = {}
  pattern = string.lower(pattern)
  for i, n in ipairs(used_name) do
    local idx = 0
    local i_s, i_e
    
    repeat
      i_s, i_e = string.find(pattern, k_w(n), idx)
      idx = i_e
      if i_s then
        table.insert(rslt, { i_s, n })
      end
    until i_s == nil
    
  end
  
  table.sort(rslt, function(a,b) return a[1] < b[1] end)
  
  return rslt
end

function get_custom_files()
  local i = -1
  return function()
    i = i + 1
    if i == 0 then
      return get_custom_patterns("custom")
    elseif i <= 100 then
      return get_custom_patterns("custom" .. i)
    end
  end
end
function get_custom_patterns(name)
  
  local status, rslt = pcall(function()
    local lst = {}
    for line in io.lines(get_filename(name)) do
      table.insert(lst, line)
    end
    return lst
  end)
  
  if not status or table.getn(rslt) == 0 then
    return name .. "_out", nil
  else
    return name .. "_out", rslt
  end
end

------------------
-- common function

function k_w(word)
  word = get_value_empty(word)
  return "{".. string.lower(word) .. "}"
end

function get_value_empty(value)
  if value == nil then
    return ""
  else
    return tostring(value)
  end
end
function reverse(t)
  local lenght = table.getn(t) + 1
  return function()
    lenght = lenght - 1
    if 0 < lenght then
      return lenght, t[lenght]
    end
  end
end
function truncate(num)
  return tonumber(string.format("%i", num))
end

function get_filename(name)
  return vlc.config.userdatadir() .. "/np_" .. get_value_empty(name) .. ".txt"
end

function write_file(name, text)
  text = get_value_empty(text)
  if text == "" then
    text = " "
  end
  text = string.gsub(tostring(text), "\\n", "\n")
  local w = io.open(get_filename(name), "w")
  if w then
    w:write(text)
    w:close()
  end
end

----------
-- picture

NP_transparent = "\137\80\78\71\13\10\26\10\0\0\0\13\73\72\68\82\0\0\1\244\0\0\1\244\8\6\0\0\0\203\214\223\138\0\0\0\9\112\72\89\115\0\0\12\78\0\0\12\78\1\127\119\140\35\0\0\3\225\73\68\65\84\120\1\237\193\129\1\0\0\4\192\160\253\255\52\254\80\117\166\15\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\88\21\15\1\0\86\59\154\147\0\0\0\0\73\69\78\68\174\66\96\130"

NP_icon = "\137\80\78\71\13\10\26\10\0\0\0\13\73\72\68\82\0\0\0\32\0\0\0\32\8\6\0\0\0\115\122\122\244\0\0\0\6\98\75\71\68\0\0\0\0\0\0\249\67\187\127\0\0\0\9\112\72\89\115\0\0\11\19\0\0\11\19\1\0\154\156\24\0\0\4\227\73\68\65\84\88\9\237\213\109\108\83\213\31\7\240\239\57\231\222\219\118\237\218\110\107\237\214\141\61\180\76\70\24\27\123\0\199\192\76\116\60\160\44\193\133\16\37\194\20\53\6\163\44\134\152\128\198\240\198\37\190\240\175\60\72\116\137\36\42\49\129\224\18\34\9\35\38\62\152\49\35\113\62\48\193\205\205\141\101\110\140\109\116\99\107\235\109\123\111\207\241\14\100\194\160\100\111\136\249\39\251\52\191\54\105\123\114\190\231\119\78\206\197\156\57\115\254\107\4\179\148\61\47\43\179\180\124\217\10\91\178\221\29\14\5\7\219\207\253\220\210\211\211\27\184\103\1\28\10\49\55\62\138\67\106\76\68\190\114\108\233\221\244\204\203\175\186\189\217\30\65\8\212\240\36\2\151\250\250\154\79\28\219\115\228\200\39\71\227\241\56\76\6\139\1\9\4\131\193\9\227\127\2\51\72\72\160\204\45\202\106\230\99\251\136\127\35\242\43\223\134\59\195\13\206\57\40\99\16\220\13\71\170\43\183\154\154\143\4\131\147\225\166\166\166\147\117\117\117\91\247\26\184\49\9\165\20\55\51\198\145\150\51\103\218\234\235\235\183\143\142\142\142\207\42\64\201\67\107\215\142\45\202\64\112\241\78\164\123\61\128\208\0\66\96\76\0\33\4\82\28\118\100\249\22\72\27\106\159\104\56\221\220\220\108\181\90\109\94\175\55\11\9\60\182\97\67\86\90\90\154\109\219\182\173\155\135\135\71\166\67\80\220\129\172\40\172\96\221\211\107\134\74\119\195\228\242\67\196\85\0\4\132\16\72\76\130\44\43\16\96\240\166\123\144\151\95\176\40\39\39\219\31\137\198\98\90\28\8\171\49\168\177\248\45\21\209\56\254\82\163\40\42\42\174\62\112\224\189\163\105\105\46\231\93\3\100\205\203\241\231\228\205\47\138\70\85\152\101\10\161\199\16\83\67\208\140\10\78\4\0\93\133\205\76\160\48\1\135\221\65\45\102\75\42\0\142\4\132\16\176\59\156\176\217\157\168\217\88\187\102\121\101\229\170\187\110\65\165\245\202\195\185\93\135\45\1\179\15\36\35\15\78\187\13\58\143\131\115\1\61\206\161\200\18\36\34\96\188\129\199\194\177\75\151\6\7\41\165\37\2\226\198\148\152\105\170\123\76\146\32\49\6\89\150\45\9\3\208\169\0\41\87\215\167\180\127\0\41\66\48\145\89\4\101\241\35\32\208\65\1\216\173\150\107\43\82\35\42\76\38\5\103\91\190\105\29\26\30\249\147\49\38\195\32\166\94\2\51\77\135\226\215\127\20\9\3\120\172\178\187\32\85\91\206\5\144\42\9\4\190\216\133\1\229\48\60\57\249\208\185\6\174\199\174\117\34\206\57\250\187\47\68\246\239\223\183\27\128\32\6\136\219\23\159\40\72\194\51\144\91\188\172\66\170\218\225\142\120\150\66\79\205\69\182\105\18\87\191\125\23\93\29\191\66\143\168\92\8\46\174\94\25\142\181\124\121\122\96\100\104\128\221\231\52\151\195\32\166\204\42\65\130\123\192\105\97\74\161\155\100\151\151\45\217\172\150\108\197\101\251\139\144\133\6\66\0\41\164\162\187\247\34\142\125\250\209\15\129\243\173\205\109\253\227\223\13\140\142\247\110\169\169\248\208\111\10\28\26\112\203\140\48\22\3\110\52\65\204\98\253\51\58\176\107\165\165\238\179\245\188\189\44\195\250\148\160\20\28\20\186\148\4\141\37\1\74\18\82\60\89\40\76\53\149\190\98\239\174\95\231\26\183\27\183\90\207\247\29\125\175\185\60\158\104\153\215\252\78\154\69\127\22\148\96\22\110\9\200\96\144\37\134\55\87\179\6\109\34\182\80\27\236\134\203\164\66\161\2\84\83\193\212\0\148\177\14\36\117\156\132\56\123\130\153\161\90\188\46\133\54\253\33\142\95\9\132\6\124\254\252\164\204\100\90\213\127\225\71\175\61\61\15\190\130\197\16\156\35\17\74\40\154\142\31\111\234\236\236\56\63\189\5\133\94\197\187\208\171\85\12\235\128\227\242\8\156\109\141\176\180\55\66\146\76\144\45\83\131\162\152\28\3\162\2\72\207\2\10\179\241\224\253\63\153\210\58\6\213\192\169\214\246\134\23\106\30\168\78\14\183\47\253\184\97\39\236\41\46\148\46\175\130\166\105\179\223\130\213\133\172\202\238\210\157\243\22\0\5\5\128\221\6\40\12\144\120\20\84\51\138\2\14\15\80\82\14\248\138\1\151\79\243\172\46\150\86\192\48\54\54\30\110\106\249\237\185\100\87\230\168\149\70\209\184\119\7\46\246\116\65\81\100\72\146\116\91\201\50\5\53\76\31\194\169\150\60\190\18\181\200\20\48\235\128\217\13\32\140\235\56\0\2\64\250\231\211\6\32\25\128\133\99\211\42\81\123\176\153\124\46\132\64\87\111\127\123\103\78\250\91\75\114\124\255\235\235\234\196\251\123\95\194\243\111\236\27\98\76\138\138\25\79\92\70\25\9\133\66\193\233\0\66\112\156\250\90\61\223\219\69\168\16\4\132\0\132\227\58\34\254\29\61\245\189\4\8\16\80\42\72\199\64\228\247\155\111\156\211\173\231\14\202\21\126\215\130\220\220\61\23\187\218\80\189\98\217\147\33\13\191\220\225\145\79\162\209\104\8\247\130\44\49\90\93\234\219\85\238\119\189\78\0\9\115\230\204\249\127\240\55\11\195\251\160\5\210\190\221\0\0\0\0\73\69\78\68\174\66\96\130"
