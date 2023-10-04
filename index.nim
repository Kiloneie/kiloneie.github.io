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
  var link: string
  var links: string

  let path = getCurrentDir() & r"\" & fmt"{videoSeries}"

  for file in walkDirRec(path): #This seems to do the job already
    if file.endsWith(".html"):
      link = file.replace(r"\", "/")
      links.add &"* [{link}]({link})\n"

      #This is very janky... it only works it you open the link in another tab
      #[ let extra = "file:///"
      let dQuote = '"'
      var combined = "file:///" & dQuote & link & dQuote      
      links.add "*<a href = " & r"" & fmt"{combined}" & r"" & ">" & "A link" & "</a>" & "<br>" ]#

      #[ when defined(nblogRerun):
        let cmd = "nim r " & link.replace(".html", ".nim")
        echo "executing " & cmd
        if execShellCmd(cmd) != 0:
          echo cmd & " FAILED" ]# 

  result = links

nbCode:
  echo "Using proc to retrieve files: "

  let nimForBeginners = findAndOutputTutorials("Nim for Beginners")
  echo nimForBeginners


#Adding hlMd or hlMdf enables nimiboost's markdown highlight mode
nbText: hlMdF"""
- This is the index file to list all of my nimib styled offline tutorials of my Nim Tutorial videos,
  organized by their respective video series.
  (using nbSections for the video series organization)
"""

nbSection "Nim for Beginners"
nbText: hlMdF"""

""" & nimForBeginners

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
- <a href = "file:///C:/Users/Kiloneie/OneDrive/Documents/GitHub/kiloneie/Nim for Beginners/Sets/Sets.html">Sets.html</a>
- [file:///C:/Users/Kiloneie/OneDrive/Documents/GitHub/kiloneie/Nim for Beginners/Sets/Sets.html](file:///C://Users/Kiloneie/OneDrive/Documents/GitHub/kiloneie/Nim for Beginners/Sets/Sets.html "Test")
"""

nbSave()