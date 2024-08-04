### version 2.5
Fix another unparity of the Lua Libraries betwen Linux and Windows

### version 2.4
Add "filename1" tag name for the file, without extension

### version 2.3
Fix unparity of the Lua Libraries betwen Linux and Windows

### version 2.2
Fix subtlety/error on Linux

### version 2.1
Fix metadata update error when the file path contain a text betewen bracket ex: [eng]
Add "ext" and "ext1" tag names for the file extension

### version 2.0
Complete rewriting and Custom files
Thanks to a complete rewrite of the code, "Now Playing in texts" uses a custom pattern feature. You can create hundreds of personalized files, read the HTML doc for more detail.
And as a bonus, it is now possible to get the cover.

### version 1.5
URI file location
Add "np_uri.txt" contains the file location in URI format.

### version 1.4
Web radio support
Add "np_radio.txt" contains the currently played music. (If you not listen a web radio, identical to np_title.txt)
(Thanks ronchristie52 for this tip)

### version 1.3
Clear TXT's if no track
The TXT's are cleared if no track is played or found (Stop or end of playlist, but Pause keep the files).

### version 1.2
"Artist - Title" feature
Add "np_artist_title.txt" containing the Artiste name and the Title in one line.
Code optimization.

### version 1.1
Fontion "Clear files"
Add a fontion "Clear files", when you disable the plugin or left VLC, the TXT's files are cleared.
Add a msg's for debug.

### version 1.0
init()