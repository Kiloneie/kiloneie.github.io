#Do NOT use {} inside nbText: hlMdF""" """ fields, sometimes it will error, not always
#When using - to make a line a list item, you cannot have ANY one of the lines be an empty line
#Use spaces by a factor of 2x for indentation in levels
# *text* italic
# **text** for bold instead of <b></b>
# ***text*** italic bold
#Link 1 - <a href = "link"></a>
#Link 2 - [name](link)
#Link 3 `name <link>`_ -> without a name works too
#nbCodeSkip -> skips the output/echo calls from the file, everything else remains the same

import nimib, std/strutils, #[ nimib / [paths, gits] ]# os, strformat, sugar
import nimislides, nimibook

#You can use nimib's custom styling or HTML & CSS
nbInit()
nb.darkMode()

import /requiredForEmbeddedSlides/embeddedReveal
initEmbeddedSlides()

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

#Overriding nimib's nbCode -> with a version that has horizontal scroll for overflowing output
import nimib / [capture]

template nbCode(body: untyped) =
  newNbCodeBlock("nbCode", body): #Writes to stdout `lineNumb typeOfNBblock: a bit of first line
    captureStdout(nb.blk.output):
      body

nb.partials["nbCode"] = """
{{>nbCodeSource}}
<pre><code class=\"language-markdown\" style = "color:white;background-color: rgba(255, 255, 255, 0);font-size: 12px;">{{>nbCodeOutput}}</code></pre>
""" 
nb.renderPlans["nbCode"] = @["highlightCode"] # default partial automatically escapes output (code is escaped when highlighting)

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

template nbSubSection(name:string) =
  index.subsection.inc

  let anchorName = name.toLower.replace(" ", "-")
  nbText "<a name = \"" & anchorName & "\"></a>\n## " & "&nbsp;&nbsp;" & $index.section & "." & $index.subsection & ". "  & name & "\n\n---" #&nbsp; is inline HTML for a single white space(nothing in markdown)
  # see below, but any number works for a numbered list
  nbToc.output.add "  - " & $index.section & r"\." & $index.subsection & r"\. " & "<a href=\"#" & anchorName & "\">" & name & "</a>\n"
  #If you get an error from the above line, addToc must be ran before any nbSection 

template nbUoSection(name: string) =
  nbText "\n# " & name & "\n\n---"

template nbUoSubSection(name: string) =
  nbText "\n## " & name & "\n\n---"

#Updating the same file is shown instantly once deployed via Github Page on PC. 
  #Mobile takes either a random amount of time, or NOT at all!
template addButtonBackToTop() =
  nbRawHtml: hlHtml"""
      <meta name = "viewport" content = "width = device-width, initial-scale = 1">
      <style>
      body {} <!-- This is a comment, this needs to be here body {} -->

      #toTop {
        display: none;
        position: fixed;
        bottom: 20px;
        right: 30px;
        z-index: 99;
        font-size: 18px;
        border: none;
        outline: none;
        background-color: #1A222D;
        color: white;
        cursor: pointer;
        padding: 15px;
        border-radius: 4px;
      }
      #toTop:hover {background-color: #555;}

      #toTopMobile {
        display: none;
        position: fixed;
        bottom: -5px;
        right: -5px;
        z-index: 99;
        font-size: 18px;
        border: none;
        outline: none;
        background-color: #1A222D;
        opacity: .2;
        color: white;
        cursor: pointer;
        padding: 15px;
        border-radius: 4px;
      }
      #toTopMobile:hover {background-color: #555;}
      
      </style>
      <body>

      <button onclick = "topFunction()" id = "toTop" title = "Go to top">Top</button>
      <button onclick = "topFunction()" id = "toTopMobile" title = "Go to top">Top</button>

      <script>
        // Get the button
        let myButton = document.getElementById("toTop");
        let myButtonMobile = document.getElementById("toTopMobile");
        var currentButton = myButton

        var hasTouchScreen = false;

        //var contentBody = document.getElementsByTagName("body"); //gives a query object

        //myButton.style.color = "red"; //This works
        //myButton.textContent = contentBody; //This also works .innerHTML, .innerText
        //document.body.scrollTop > 20 || document.documentElement.scrollTop > 20
        //Above could be used to position the button relativly ?

        // Detecting if the device is a mobile device
        if ("maxTouchPoints" in navigator) 
          {
            hasTouchScreen = navigator.maxTouchPoints > 0;
          } 
        else if ("msMaxTouchPoints" in navigator) 
          {
            hasTouchScreen = navigator.msMaxTouchPoints > 0;
          } 
        else 
          {
            var mQ = window.matchMedia && matchMedia("(pointer:coarse)");

            if (mQ && mQ.media === "(pointer:coarse)") 
              {
                hasTouchScreen = !!mQ.matches;
              } 
            else if ('orientation' in window) 
              {
                hasTouchScreen = true; // deprecated, but good fallback
              } 
            else 
              {
                // Only as a last resort, fall back to user agent sniffing
                var UA = navigator.userAgent;
                hasTouchScreen = (
                    /\b(BlackBerry|webOS|iPhone|IEMobile)\b/i.test(UA) ||
                    /\b(Android|Windows Phone|iPad|iPod)\b/i.test(UA)
                    );
              }
          }

        if (hasTouchScreen)
            currentButton = myButtonMobile

        // When the user scrolls down 20px from the top of the document, show the button
        window.onscroll = function() 
          {
            scrollFunction()
          };

        function scrollFunction() 
          {
            if (document.body.scrollTop > 20 || document.documentElement.scrollTop > 20) {
              currentButton.style.display = "block";
            } else {currentButton.style.display = "none";}
          }

        // When the user clicks on the button, scroll to the top of the document
        function topFunction() {
          document.body.scrollTop = 0;
          document.documentElement.scrollTop = 0;
        }
      </script>
    """

#TABLE OF CONTENTS - MUST BE RUN BEFORE ANY nbSection !!!
addToc() 
addButtonBackToTop()

#Use Live Preview Extension and set the Auto Refresh Preview set to "On changes to Saved Files"
  #And Server Keep Alive After Embedded Preview Close set to 0, 
  #so that we no longer need the preview embedded window, we now have it in the browser!
    #Live SERVER Extension no longer works, even with the .html file kept open

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
  
  (Nimib tutorials are listed newest to oldest, with the latest at the top)
"""

nbSection "Nim for Beginners"
let nimForBeginners = findAndOutputTutorials("Nim for Beginners")
nbText: hlMdF"" & "<br>" & nimForBeginners

nbSection "Exploring Nim's Standard Library"
let exploringNimsStandardLibrary = findAndOutputTutorials("Exploring Nim's Standard Library")
nbText: hlMdF"" & "<br>" & exploringNimsStandardLibrary

nbSection "Nim SDL2 Game Development for Beginners"
let nimSDL2GameDevelopmentForBeginners = findAndOutputTutorials("Nim SDL2 Game Development for Beginners")
nbText: hlMdF"" & "<br>" & nimSDL2GameDevelopmentForBeginners

nbSection "Metaprogramming in Nim"
let metaprogrammingInNim = findAndOutputTutorials("Metaprogramming in Nim")
nbText: hlMdF"" & "<br>" & metaprogrammingInNim

nbSection "Work in Progress"
let workInProgress = findAndOutputTutorials("Work in Progress")
nbText: hlMdF"" & "<br>" & workInProgress

nbSection "Extra Content"
let extraContent = findAndOutputTutorials("Extra Content")
nbText: hlMdF"" & "<br>" & extraContent

nbUoSection "My and General Links"
nbText: """
- [Nim's main page](https://nim-lang.org "Nim's main page")
- [Nim's manual/documentation](https://nim-lang.org/docs/manual.html "Nim's manual/documentation")
- [Patreon](https://www.patreon.com/Kiloneie?fan_landing=true "Patreon")
- [Visual Studio Code Shortcuts](https://code.visualstudio.com/shortcuts/keyboard-shortcuts-windows.pdf "Visual Studio Code Shortcuts")
"""

nbSave()