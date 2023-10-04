#Do NOT use {} inside nbText: hlMdF""" """ fields... 
#When using - to make a line a list item, you cannot have ANY one of the lines be an empty line
#Use spaces by a factor of 1x and then 2x for every indentation level

import nimib, std/strutils, #[ nimib / [paths, gits] ]# os, strformat, sugar
#You can use nimib's custom styling or HTML & CSS
nbInit()
nb.darkMode()
#nbShow() #This will auto open this file in the browser, but it does not check if it is already open
  #so it keeps bloody opening one after another, i just want a way to update changes quickly

# customize source highlighting:
nb.context["highlight"] = """
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/10.5.0/styles/default.min.css">
<script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/10.5.0/highlight.min.js"></script>
<script>hljs.initHighlightingOnLoad();</script>"""

# a custom text block that shows markdown source
template nbTextWithSource*(body: untyped) =
  newNbBlock("nbTextWithSource", false, nb, nb.blk, body):
    nb.blk.output = body
  nb.blk.context["code"] = body

nb.renderPlans["nbTextWithSource"] = @["mdOutputToHtml"]
nb.partials["nbTextWithSource"] = """{{&outputToHtml}}
<pre><code class=\"language-markdown\">{{code}}</code></pre>"""

# how to add a ToC
var
  nbToc: NbBlock

template addToc =
  newNbBlock("nbText", false, nb, nbToc, ""):
    nbToc.output = "## Table of Contents:\n\n"

template nbSection(name:string) =
  let anchorName = name.toLower.replace(" ", "-")
  nbText "<a name = \"" & anchorName & "\"></a>\n# " & name & "\n\n---"
  # see below, but any number works for a numbered list
  nbToc.output.add "1. <a href=\"#" & anchorName & "\">" & name & "</a>\n"
  #If you get an error from the above line, addToc must be ran before any nbSection 

#TABLE OF CONTENTS - MUST BE RUN BEFORE ANY nbSection !!!
addToc() 

#Do NOT forget to have the .html file OPEN at all times, otherwise 
  #live preview will NOT work! ANY live preview!

###############
#START OF FILE#
###############

#Proc to find all nimib styled offline tutorials of their respective video series(called per section)
proc findAndOutputTutorials(videoSeries: string): string =
  var tutorialsList: string
  var link: string
  var path = getCurrentDir()

  #[ for file in path(fmt"\" & videoSeries): #if we don't use nimib's procs, we need to learn paths module and get a list to traverse trough
    if file.endsWith(".html"):
      continue

    link = file.relPath.replace(fmt"\", "/")
    echo "Adding link: ", link ]#

#The proc will iterate over all the files in all of the subsequent folders and retrieve all .html files
  #then we add them to a sequence of type string and display links of them
  #i think we can use nbSection inline... surely.
#https://nim-lang.org/docs/osdirs.html#walkFiles.i,string
nbCode:
  #let path = getCurrentDir()
  let path = getCurrentDir() & r"\" & "Nim for Beginners" & r"\" & "Sets" & r"\"
  echo path
  let files = collect(newSeq): #r"\" & "Nim for Beginners" & r"\" & "*.html" does NOT work

    #This gives error of being used by another program already... even after closing github desktop
    #echo getCurrentDir()
    for file in walkFiles(path & "*.html"): #walkFiles("*.html") only walks trough the current dir 
      file

  echo files

#This works, but it does NOT go into files, so we must figure that out... we need all files from all folders,
  #from inside a specific folder of the 4 video series, e.g. Nim for Beginners

#Adding hlMd or hlMdf enables nimiboost's markdown highlight mode
nbText: hlMdF"""
- This is the index file to list all of my nimib styled offline tutorials of my Nim Tutorial videos,
  organized by their respective video series.
  (using nbSections for the video series organization)
"""

nbSection "Nim for Beginners"
nbText: hlMdF"""

"""

nbSection "Exploring Nim's Standard Library"
nbText: hlMdF"""

"""

nbSection "Nim SDL2 Game Development for Beginners"
nbText: hlMdF"""

"""

nbSection "Metaprogramming in Nim"
nbText: hlMdF"""

"""

nbText: hlMdF"""
<b>LINKS:</b>
- [Nim's main page](https://nim-lang.org "Nim's main page")
- [Nim's manual/documentation](https://nim-lang.org/docs/manual.html "Nim's manual/documentation")
- [Twitter](https://twitter.com/Kiloneie "My Twitter")
- [Patreon](https://www.patreon.com/Kiloneie?fan_landing=true "Patreon")
- [Visual Studio Code Shortcuts](https://code.visualstudio.com/shortcuts/keyboard-shortcuts-windows.pdf "Visual Studio Code Shortcuts")
"""

nbSave()