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

template nbSubSection(name:string) =
  index.subsection.inc

  let anchorName = name.toLower.replace(" ", "-")
  nbText "<a name = \"" & anchorName & "\"></a>\n## " & "&nbsp;&nbsp;" & $index.section & "." & $index.subsection & ". "  & name & "\n\n---" #&nbsp; is inline HTML for a single white space(nothing in markdown)
  # see below, but any number works for a numbered list
  nbToc.output.add "  - " & $index.section & r"\." & $index.subsection & r"\. " & "<a href=\"#" & anchorName & "\">" & name & "</a>\n"
  #If you get an error from the above line, addToc must be ran before any nbSection 

#Updating the same file is shown instantly once deployed via Github Page on PC. 
  #Mobile takes either a random amount of time, or NOT at all!
template addButtonBackToTop() =
  nbRawHtml: """
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

#Do NOT forget to have the .html file OPEN at all times, otherwise 
  #live preview will NOT work! ANY live preview!

###############
#START OF FILE#
###############

nbText: hlMdf"""
## INTRO - GREETING
Nim for Beginners: Object Variants Part 1
"""

nbText: hlMdf"""
## INTRO - FOREWORDS
(What is the purpose of this video ?) <br>

In this video i will teach you about object variants, what they are and how to use them,
as well as compare them against objects with inheritance.

The code for this video and it's script/documentation styled with nimib,
is in the links in the description as a form of offline tutorial.

"""

nbSection "What are object variants ?"
nbText: hlMdf"""
Object variants are when making an object and using logic,
to split it into several unique parts.
This is done by using a case statement and enumerators. 
Object variants are an easy way of having as the name suggests variants of the same object.

Sometimes or often an object hierarchy would be an overkill, needless complication.
  
Let's start with a a simple example:
First we make an enumerator withing a type section, 
with it's enumerations of line, circle, rectangle 
"""

nbCode:
  type
    Kind = enum
      line, circle, rectangle

nbText: hlMdf"""
Secondly we make our object with it's variants by using a case statement,
with the enumerator from above like this: 
"""

nbCode:         
  type
    Draw = object
      case kind: Kind
        of line:
          lx, ly: int
        of circle:
          cx, cy: int
          radius: float #PI = 3.14
        of rectangle:
          rx1, ry1, rx2, ry2: int
          
nbText: hlMdf"""          
How this works is simple, you initialize a new variable of type Draw object,
and then for it's field select one of it's kind enumerations, 
and then based on the kind of the object, you give that kind's field's data,
and thus you have a variant of that object.
Also note how we used different field names for each of the variants,
that is because they cannot be the same, 
since they are declared in the same object.

Let's demonstrate this by making a variable for each of the object variants 
and echo them, also make a constant for pi, circle's radius: 
"""

nbCode:
  const pi = 3.14
  var drawLine = Draw(kind: line, lx: 10, ly: 50)
  var drawCircle = Draw(kind: circle, cx: 10, cy: 50, radius: pi)
  var drawRectangle = Draw(kind: rectangle, rx1: 10, ry1: 50, rx2: 10)

  echo drawLine, " drawLine's type is: ", drawLine.type 
  echo drawCircle, " drawCircle's type is: ", drawCircle.type 
  echo drawRectangle, " drawRectangle's type is: ", drawRectangle.type 

nbText: hlMdf"""          
Here we go 3 different variants of the same object Draw.
We can also display their kind such as line, circle, 
rectangle that the case statement uses,
so let's display that using "variableName.kind" 
"""

nbCode:
  echo drawLine, " drawLine's type is: ", drawLine.type, " of kind: ", drawLine.kind
  echo drawCircle, " drawCircle's type is: ", drawCircle.type, " of kind: ", drawCircle.kind 
  echo drawRectangle, " drawRectangle's type is: ", drawRectangle.type, " of kind: ", drawRectangle.kind 

nbText: hlMdf"""
Here we go it works. 
"""

nbSection "Shared fields"
nbText: hlMdf"""
When using Object Variants we can easily share fields between them all as well,
this is as simple as adding those fields before or after the case statement.
Let's try this with a different example: 
"""

nbCode:
  type
    Enemies1 = enum
      footman, mage

    Armor = enum
      light, medium, heavy

    Spells = enum
      root, heal, arcaneMissiles

    Enemy = object
      damage: int
      attackRange: int
      health: int

      case kind: Enemies1
        of footman:
          armor: Armor
        of mage:
          spells: seq[Spells]

nbText: hlMdf"""
Okay here i have made 3 enumerators, 
1x for the Enemies1 with footman and mage as it's enumerations,
another for Armour our footman will be using and Spells for the mage.

In the object i have added 3 fields, 
that will be shared between both of the Object Variants,
of damage, attackRange and health.
And then i gave both of the variants their special field, 
of the enumerator i have made for each of them.

Now let's initialize a variable for each Object Variant kind and then display them both: 
"""

nbCode:
  var soldier = Enemy(kind: footman, armor: medium, health: 200, damage: 5, attackRange: 100)
  var sorcerer = Enemy(kind: mage, spells: @[root, heal], health: 75, damage: 10, attackRange: 600)

  echo soldier, " soldier's type is: ", soldier.kind
  echo sorcerer, " sorcerer's type is: ", sorcerer.kind

nbText: hlMdf"""
Here we go, that's how you do Object Variants and have shared fields for them. 
"""


nbSection "Circle-Ellipse problem"
nbText: hlMdf"""
In case you have heard of the Circle-Ellipse problem or Rectangle-Square problem,
object variants are the solution to this problem
"""

nbText: hlMdf"""
## OUTRO - AFTERWORDS

  Okay, that's it for this video, thanks for watching like, share and subscribe, 
    aswell as click the bell icon if you liked it, 
    you can also follow me on twitter of the same name, and support me on Patreon. 
    If you had any problems with any part of the video, 
    let me know in the comment section, 
    the code for this video will be from now on inside the script/documentation
    page styled with nimib, as a form of offline tutorial, 
    the link is in the description, have fun.

### Thanks to my past and current Patrons
<b>Past Patrons:</b>
- Goose_Egg: From April 4th 2021 to May 10th 2022
- Davide Galilei

<b>Current Patrons</b>
- None

<b>Compiler information</b>
- Version used: E.G. 1.6.8
- Compiler settings used: --gc:orc
- Timestamps:
  - 00:15 Start of video example


<b>LINKS:</b>
- [Twitter](https://twitter.com/Kiloneie "My Twitter")
- [Patreon](https://www.patreon.com/Kiloneie?fan_landing=true "Patreon")
- Video's script/documentation styled with nimib as a form of offline tutorial:
- [Visual Studio Code Shortcuts](https://code.visualstudio.com/shortcuts/keyboard-shortcuts-windows.pdf "Visual Studio Code Shortcuts")

<b>LINKS to this video's subject:</b>
- [Object Variants](https://nim-lang.org/docs/manual.html#types-object-variants "Object Variants")
"""

nbSave()