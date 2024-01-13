#Do NOT use {} inside nbText: hlMdF""" """ fields, sometimes it will error, not always
#When using - to make a line a list item, you cannot have ANY one of the lines be an empty line
#Use spaces by a factor of 2x for indentation in levels
# *text* italic
# **text** for bold instead of <b></b>
# ***text*** italic bold
#Link 1 - <a href = "link"></a>
#Link 2 - [name](link)
#Link 3 `name <link>`_ -> without a name works too

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
  var link: string
  var links: string
  var removeUntil: int

  let path = getCurrentDir() & r"\" & fmt"{videoSeries}"

  #"/Nim for Beginners/Sets/Sets.html" this works in a href, so model the output for a href, and cut away everything B4 "/Nim for Beginners/Sets/Sets.html", 
    #or in other words videoSeries + directory found + file found.html

  #test using `name <link>`_ style for a link(markup, not html or nimib)
  for file in walkDirRec(path):
    if file.endsWith(".html"):
      link = file.replace(r"\", "/")
      removeUntil = file.find(videoSeries)
      link.delete(0 .. removeUntil-1) #remove everything before videoSeries -> use .find to find videoSeries index location, then delete everything from there to index 0 - start
      var linkName = link
      linkName.delete(0 .. videoSeries.len)
      links.add "- <a href = " & '"' & fmt"{link}" & '"' & ">" & linkName & "</a>" & "<br>" #&"* [{link}]({link})\n"    &"* `<{link}>`_ \n"
      #Not sure why the first link is on lvl 1, and the next ones are at lvl 2 of bullet points/indentation...
  result = links

  if result.isEmptyOrWhitespace:
    result = "No offline tutorials exist for this video series yet(coming soon)"

#Add a back to the index.html link... this would require that every single nimib file has it... lots of manual work... skip for now!

#Adding hlMd or hlMdf enables nimiboost's markdown highlight mode
nbText: hlMdF"""
- This is the index file to list all of my nimib styled offline tutorials of my Nim Tutorial videos,
  organized by their respective video series.
  (using nbSections for the video series organization)
  
  (Nimib tutorials are listed newest to oldest(top to bottom))
"""

nbSection "Nim for Beginners"
let nimForBeginners = findAndOutputTutorials("Nim for Beginners")
nbText: hlMdF"" & nimForBeginners

nbSection "Exploring Nim's Standard Library"
let exploringNimsStandardLibrary = findAndOutputTutorials("Exploring Nim's Standard Library")
nbText: hlMdF"" & exploringNimsStandardLibrary

nbSection "Nim SDL2 Game Development for Beginners"
let nimSDL2GameDevelopmentForBeginners = findAndOutputTutorials("Nim SDL2 Game Development for Beginners")
nbText: hlMdF"" & nimSDL2GameDevelopmentForBeginners

nbSection "Metaprogramming in Nim"
let metaprogrammingInNim = findAndOutputTutorials("Metaprogramming in Nim")
nbText: hlMdF"" & metaprogrammingInNim

nbSection "Work in Progress"
let workInProgress = findAndOutputTutorials("Work in Progress")
nbText: hlMdF"" & workInProgress

nbText: hlMdF"""
<b>LINKS:</b>
- [Nim's main page](https://nim-lang.org "Nim's main page")
- [Nim's manual/documentation](https://nim-lang.org/docs/manual.html "Nim's manual/documentation")
- [Twitter](https://twitter.com/Kiloneie "My Twitter")
- [Patreon](https://www.patreon.com/Kiloneie?fan_landing=true "Patreon")
- [Visual Studio Code Shortcuts](https://code.visualstudio.com/shortcuts/keyboard-shortcuts-windows.pdf "Visual Studio Code Shortcuts")
"""

nbSave()