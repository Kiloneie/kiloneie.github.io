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