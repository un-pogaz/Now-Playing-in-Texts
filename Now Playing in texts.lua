--[[
Now Playing in texts, extension for VLC media player

Author: un_pogaz

Information:
Save the actualy song playing (Title, Artist, Album) in a TXT's files.

np_album.txt = Contains just the Album.
np_artist.txt = Contains just the Artist.
np_title.txt = Contains just the Title.
np_artist_title.txt = Contains the name of Artist and the Title in one line.
np_radio.txt = Contains the currently played music. Ideal if you listen a web radio.
              (If you not listen a web radio, identical to np_title.txt)
np_uri.txt = Contains the file location in URI format.

The TXT's will be saved in the VLC user director which can be found in the following places
    Linux: ~/.local/share/vlc/
    Windows: %APPDATA%\vlc\
    Mac OS X: /Users/%your_name%/Library/Application Support/org.videolan.vlc/

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

function descriptor()
  return { title = "Now Playing in texts",
    version = "1.6",
    author = "un_pogaz",
    shortdesc = "Now Playing in texts",
    description = "Outputs the Title, Album and Artist of the currently playing song to a texts files.",
    capabilities = { "input-listener" }
  }
end

-- Activate & Deactivate
function activate()
  vlc.msg.dbg("[Now Playing texts] Activate")
  update_files()
end
function close()
  clear_file()
  vlc.msg.dbg("[Now Playing texts] Close")
end
function deactivate()
  clear_file()
  vlc.msg.dbg("[Now Playing texts] Deactivate")
end

-- Triggers
function input_changed()
  vlc.msg.dbg("[Now Playing texts] input changed")
  update_files()
end
function meta_changed()
  vlc.msg.dbg("[Now Playing texts] meta changed")
  update_files()
end 

function update_files()
  if vlc.input.is_playing() then
    title()
    artist()
    album()
    artist_title()
    genre()
    now_playing_radio()
    get_uri()
  else
    clear_file()
  end
end

-- title
function title()
  local item=vlc.item or vlc.input.item()
  io.output(vlc.config.userdatadir() .. "/np_title.txt")
  if item:metas()["title"] then
    io.write(item:metas()["title"])
  else
    io.write(item:name())
  end
  io.close()
end

-- artist
function artist()
  local item=vlc.item or vlc.input.item()
  io.output(vlc.config.userdatadir() .. "/np_artist.txt")
  if item:metas()["artist"] then
    io.write(item:metas()["artist"])
  else
    io.write(" ")
  end
  io.close()
end

-- album
function album()
  local item=vlc.item or vlc.input.item()
  io.output(vlc.config.userdatadir() .. "/np_album.txt")
  if item:metas()["album"] then
    io.write(item:metas()["album"])
  else
    io.write(" ")
  end
  io.close()
end

-- artist_title
function artist_title()
  local item=vlc.item or vlc.input.item()
  io.output(vlc.config.userdatadir() .. "/np_artist_title.txt")
  if item:metas()["title"] then
    if item:metas()["artist"] then
      io.write(item:metas()["artist"] .. " - " .. item:metas()["title"])
    else
     io.write(item:metas()["title"])
    end
  else
    local file = item:name();
    local xedni = string.find(string.reverse(file), "\.");
    local index = string.len(file) - xedni;
    local filename = string.sub(file, 0, index);
    io.write(filename)
  end
  io.close()
end

-- genre
function genre()
  local item=vlc.item or vlc.input.item()
  io.output(vlc.config.userdatadir() .. "/np_genre.txt")
  if item:metas()["genre"] then
    io.write(item:metas()["genre"])
  else
    io.write(" ")
  end
  io.close()
end

-- now_playing / radio
function now_playing_radio()
  local item=vlc.item or vlc.input.item()
  io.output(vlc.config.userdatadir() .. "/np_radio.txt")
  if item:metas()["now_playing"] then
    io.write(item:metas()["now_playing"])
  else
    io.write(item:name())
  end
  io.close()
end

-- uri
function get_uri()
  local item=vlc.item or vlc.input.item()
  io.output(vlc.config.userdatadir() .. "/np_uri.txt")
  if item:uri() then
    io.write(item:uri())
  else
    io.write(" ")
  end
  io.close()
end

-- Clear files
function clear_file()
  vlc.msg.dbg("[Now Playing texts] files clear")
  io.output(vlc.config.userdatadir() .. "/np_title.txt")
    io.write(" ")
  io.output(vlc.config.userdatadir() .. "/np_artist.txt")
    io.write(" ")
  io.output(vlc.config.userdatadir() .. "/np_album.txt")
    io.write(" ")
  io.output(vlc.config.userdatadir() .. "/np_artist_title.txt")
    io.write(" ")
  io.output(vlc.config.userdatadir() .. "/np_genre.txt")
    io.write(" ")
  io.output(vlc.config.userdatadir() .. "/np_radio.txt")
    io.write(" ")
  io.output(vlc.config.userdatadir() .. "/np_uri.txt")
    io.write(" ")
  io.close()
end

function hide_dialog()
  pathdialog:hide()
end