#Do NOT use {} inside nbText: hlMdF""" """ fields... 
#When using - to make a line a list item, you cannot have ANY one of the lines be an empty line
#Use spaces by a factor of 1x and then 2x for every indentation level

import nimib, std/strutils #You can use nimib's custom styling or HTML & CSS
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

#Adding hlMd or hlMdf enables nimiboost's markdown highlight mode
nbText: hlMdF"""
## INTRO - GREETING
- TITLE: List Comprehensions with: sugar.collect. 
- ALT TITLE: Nim's Metaprogramming VS Python's List Comprehensions.

<br>test solo line
<br>test solo line

## Brainstorming/To do
Here go all thoughts on what the video will be like and how it will be made etc,
before being organized below.

    Chapters/sub topics of this video will be:
      What are list comprehensions ?
        Comprehending a list without comprehensions
        Using sugar.collect
        sugar.collect vs Python's list comprehensions(Python wins with verbosity and simplicity)
        sugar.collect also works on sets and tables(destroys Python in functionallity)(harder, but more powerful)
          Collect with Sets(brief explanation of Sets and HashSets)
          Collect with Tables

## INTRO - FOREWORDS
<b>(What is the purpose of this video ?)</b>
- This is the index file to list all of my nimib styled offline tutorials of my Nim Tutorial videos,
  organized by their respective video series.
  (using nbSections for the video series organization)
"""

nbSection "Nim for Beginners"
nbSection "Exploring Nim's Standard Library"
nbSection "Nim SDL2 Game Development for Beginners"
nbSection "Metaprogramming in Nim"

nbText: hlMd"""
## OUTRO - AFTERWORDS

  Okay, that's it for this video, thanks for watching like, share and subscribe, 
    aswell as click the bell icon if you liked it and want more, 
    you can also follow me on twitter of the same name, and support me on Patreon. 
    If you had any problems with any part of the video, 
    let me know in the comment section, 
    the code of this video, script and documentation, are in the link in the description,
    as a form of offline tutorial.

### Thanks to my past and current Patrons
<b>Past Patrons:</b>
- Goose_Egg: From April 4th 2021 to May 10th 2022
- Davide Galilei(1x month)

<b>Current Patrons</b>
- None

<b>Compiler information</b>
- Version used: E.G. 2.0.0
- Compiler settings used: none, ORC is now the default memory management option
- Timestamps:
  - 00:15 Start of video example
  
"""
nbText: hlMdF"""

<b>LINKS:</b>
- [Twitter](https://twitter.com/Kiloneie "My Twitter")
- [Patreon](https://www.patreon.com/Kiloneie?fan_landing=true "Patreon")
- Video's script/documentation with all of the code styled with nimib as a form of offline tutorial:
- [Visual Studio Code Shortcuts](https://code.visualstudio.com/shortcuts/keyboard-shortcuts-windows.pdf "Visual Studio Code Shortcuts")

<b>LINKS to this video's subject:</b>
- [E.G.1. SDL2_nim documentation](https://vladar4.github.io/sdl2_nim/ "Example link to an example video's subject")
- [E.G.2. SDL2 documentation(in case SDL2_nim documentation missed something)](https://wiki.libsdl.org/APIByCategory "Example link to an example video's subject")
"""

nbSave()