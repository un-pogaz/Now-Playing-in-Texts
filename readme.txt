This plugin reads the tags of the currently played music, and writes into text files.
Ideal if you want to display the current music on your stream with your streaming software (OBS Studio...).

Basic files
The 6 basic files are automatically generated and contain the most basic metadata

np_title.txt = contains the title of the music.
np_artist.txt = contains the artist of the music.
np_album.txt = contains the album of the music.
np_artist_title.txt = contains the artist and the title of the music.
np_radio.txt = this text use a metadata that more relevant if you listen a web radio.
np_bandcamp.txt = Uses the Bandcamp metadata pattern. 

Special files
The 3 special files are automatically generated and contain unique metadata or files useful for debugging.

np_metadata.txt = contains the list of metadata available for the current song.
np_metadata_full.txt = contains a list of all the metadata that can be used in Now Playing in texts, including those empty.
np_artwork.jpg = copy the cover image of the music. If no image is found, a blank/transparent image will be created.

Custom files
Now Playing in texts V2 integrates the possibility of creating its own metadata TXT files with your custom metadata pattern.
Read the HTML doc for more detail.

The TXTs files will be saved in the VLC user director which can be found in the following directory:
Linux: ~/.local/share/vlc/
Windows: %APPDATA%\vlc\
Mac OS X: /Users/%your_name%/Library/Application Support/org.videolan.vlc/

-------------------------
Installation Instructions

Place the "Now Playing in texts.lua" file in the corresponding folder and restart VLC or reload plugin extensions.

Linux:
Current User: ~/.local/share/vlc/lua/extensions/
All Users: /usr/lib/vlc/lua/extensions/

Windows:
Current User: %APPDATA%\vlc\lua\extensions
All Users: %ProgramFiles%\VideoLAN\VLC\lua\extensions\

Mac OS X:
Current User: /Users/%your_name%/Library/Application Support/org.videolan.vlc/lua/extensions/
All Users: /Applications/VLC.app/Contents/MacOS/share/lua/extensions/

=============
IMPORTANT
"Now Playing in texts" V2 is compatible with VLC 3 only.
If you absolutely must use VLC v2, only "Now Playing in texts" v1.5 and below are compatible. Go to "Files" tab on this page, click on "3 files ( 24 archived )" and select the old version of your choice.
