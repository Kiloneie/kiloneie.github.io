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

#Adding hlMd or hlMdf enables nimiboost's markdown highlight mode
nbText: hlMdF"""
## INTRO - GREETING
- TITLE: Sets

## INTRO - FOREWORDS
<b>(What is the purpose of this video ?)</b><br>
In this video we will learn about Sets, their pros and cons, as well as their use cases.
   
The code for this video and it's script/documentation styled with nimib,
is in the link in the description as a form of offline tutorial.
"""

nbSection "What are Sets ?"
nbText: hlMd"""
- Sets are a data type that can only have ordinal types for it's elements. 
  They model a mathematical notion of a set.
  In short Sets are a simple data type that is extremely performant and can be operated upon,
  with distinct mathematics operations, that makes it very easy to determine what belongs to what.
  Here is an example to make you more interested:
- Say you want to download somefiles from a remote computer via the File Transfer Protocol/FTP. 
  You can create a "set" with a listing of your local files and another with a listing of the remote files. 

  Then you can easily create a set of only the files you need to download.
	- files_to_download = remote_files - local_files

- Now let's get into the details of Sets:
  - They are allocated on the stack(hashSets are on the heap)
  - The size of a Set when using singed integers(normal ints, not the unsigned uint ones we haven't covered yet),
    is 0 .. DefaultSetElements-1, where DefaultSetElements is currently always 2^8(0 .. 2^8-1).
    While the maximum range length for the base type of a set, is MaxSetElements which is 2^16.
    Types with bigger range than 2^16 are forced into this range. 
    This is because Sets are implemented as high performance bit vectors.
  - The order of it's elements is unordered
  - There are also HashSets that can have more types than just ordinal and can be ordered,
   but that is the subject of another video

- Empty Set declaration an initialization:
"""
nbCode:
  #var emptySet = {} #The compiler cannot infer the data type of it's elements, so we must use declaration instead
  var emptySet: set[char]
  echo emptySet

nbText: hlMd"""
- As you can see curly brackets {} are Set's constructors
- They cannot be accessed via [] brackets, to access them by the index like so:
"""
nbCode:
  var accessSet = {'a', 'b'}
  #echo accessSet[0] #Nim's Visual Studio Code Extension catches the error
  #So instead we do it by calling the element of the Set that we want
  if 'a' in accessSet:
    echo "a is in accessSet"
nbText: hlMd"""
You can also use the "contains" proc to do the same as with the "in" proc
The reverse as in negated version of the above is done with the "notin" proc
"""    

nbText: hlMd"""
-  Sets can only have unique elements of ordinal types, any duplicates get removed
"""
nbCode:
  var deduplicatedSet = {'a', 'a', 'b'}
  echo deduplicatedSet
nbText: hlMd"""
As you can see, we had 2x 'a' characters as elements of the Set, but displaying them only shown one.
  Again, only unique elements. This is one of the use cases of Sets, 
  to convert to a Set and back quickly and efficiently.

-  Now that i have mentioned that Sets can only have ordinal types multiple times,
  let's see what those actually are in code:
"""
nbCode:
  var
    int8Set: set[int8]
    int16Set: set[int16]
    charSet: set[char]

  type
    enumSet = enum
      s1, s2, s3

nbText: hlMd"""
Maximum size of a Set is 2^16 bits for reasons of performance. HashSets do not have such limitations.
Here is a list of all the unique procs for ordinal types:
-  <b>succ</b>	Successor of the value
-  <b>pred</b>	Predecessor of the value
-  <b>inc</b>	Increment the ordinal
-  <b>dec</b>	Decrement the ordinal
-  <b>high</b>	Return the highest possible value
-  <b>low</b>	Return the lowest possible value
-  <b>ord</b>	Return int value of an ordinal value

Like with every container construct in Nim, we can also use a for loop on them.
"""
nbCode:
  for e in deduplicatedSet:
    echo e

nbText: hlMd"""
Here is the full list of procs that you can use to operate on Sets:

-  <span style="color:pink"><b>incl</b></span>(A, e)	same as A = A + e
-  <span style="color:pink"><b>excl</b></span>(A, e)	same as A = A - e
-  <span style="color:pink"><b>card</b></span>(A)	the cardinality of A (number of elements in A)
-  <span style="color:pink"><b>contains</b></span>(A, e)	A contains element e
-  e <span style="color:pink"><b>in</b></span> A	set membership (A contains element e)
-  e <span style="color:pink"><b>notin</b></span> A	A does not contain element e
-  a <span style="color:pink"><b>*</b></span> b	Intersection
-  a <span style="color:pink"><b>+</b></span> b	Union
-  a <span style="color:pink"><b>-</b></span> b	Difference
-  a <span style="color:pink"><b>==</b></span> b	Set equality
-  a <span style="color:pink"><b><=</b></span> b	subset relation (a is subset of b or equal to b)
-  a <span style="color:pink"><b><</b></span> b	Check if a is a subset of b

Let's start with difference between 2 similar sets
"""
nbCode:
  var setA = {'a', 'b'}
  var setB = {'a', 'c'}

  echo setA - setB
nbText: hlMd"""
{'b'} is the difference between setA - setB<br>
If we do the same, but reverse the 2 sets
"""
nbCode:
  echo setB - setA
nbText: hlMd"""
We get {'c'} as the element of the difference.<br>
What is happening here, is that setA has element 'a' and 'b',
using "-" setB, it will compare the 2 sets. It will check what setA has that setB doesn't,
and that is character 'b', or 'c' if we reverse it.

Second explanation if you did not understand:
  It's basically like subtraction in Math.
  If setA has {'a', 'b'} and setB has {'a', 'b', 'c'},
  then if we do the difference between the two,
  setA being on the left and setB on the right,
  then 'a' - 'a' = 0, 'b' - 'b' = 0 and setA has no elements left and the result is empty,
  but if we reverse it, setB will still have element 'c'.

By using the + sign with the 2 sets, it will simply join both set's elements and ignore any duplicates
"""
nbCode:
  echo setA + setB
nbText: hlMd"""
As you can see, only one character 'a' is shown. This is also called a Union(joining) in discrete math.

In order to add or remove elements of sets, instead of using the "add" and "del" procs that sequences use
(strings only have add), we use "incl" short for include and "excl" short for exclude.
"""
nbCode:
  setA.incl 'd'
  setB.excl 'a'

  echo setA
  echo setB
nbText: hlMd"""
As you can see, setA now has a third element of char 'd', while setB lost char element 'a'

Equality operation "==" checks if both sets members and size is equal, so they have to be exactly the same.

Let's continue with the intersection operation which is done with the star sign "*".
Intersection means elements common/shared between both sets. Right now our sets have none of those,
so let's add them.
"""
nbCode:
  setB.incl 'a'
  setB.incl 'b'

  echo setA * setB
  echo setB * setA
nbText: hlMd"""
As you can see reversing doesn't do anything here.

Now let's continue with subsets. Subset meaning if setB has the same elements that setA has,
but not all of them, just a part of them since in order for a subset to exist, 
there has to be a set larger than it's subset.
The best way to demonstrate this is with 2x subsets, so let's add another.
Let's also display all 3 before hand to easly see what is going on.
"""
nbCode: 
  var setC = {'a', 'd'}

  echo setA
  echo setB
  echo setC
  echo ""
  echo setB < setA
  echo setC < setA

nbText: hlMd"""
Here we go, as you can see setC is a subset of setA, but setB is not,
since it's third element of char 'c' is not in setA.
Now even if we remove the different element in setB and make setB identical to setA,
setB will still not be a subset of setA, that is because again, it has to be a subset,
a smaller set than the one we are comparing to.
<br>Let's demonstrate:
"""
nbCode:
  setB.excl 'c'
  setB.incl 'd'
  
  echo setA
  echo setB
  echo setB < setA

nbText: hlMd"""
As you can see, both sets are identical but the result is false, since a subset has to be smaller.

There is also the smaller or equal operator "<=" which does NOT require for the subset to be smaller,
and will return true in this case.
"""
nbCode:
  echo setB <= setA

nbText: hlMd"""
Lastly there is the "card" proc, which returns the cardinality of a "set", it's number of elements.
Let's echo all 3 and then "card" all 3:
"""
nbCode:
  echo setA
  echo setB
  echo setC

  echo setA.card
  echo setB.card
  echo setC.card

nbText: hlMd"""
You can also still use the "len" proc to get the same result of number of elements.

There are also integer sets, intsets module for efficient int sets.
There is also the std/setutils module for a bit more utility for Sets

Now let's move on to 2 very useful use cases for Sets, 
the first being using Sets with Enumerators to produce flags.
"""
nbCode:
  type
    SandboxFlag = enum
      allowCast, allowInfiniteLoops 

  var sandboxFlags: set[SandboxFlag]

  sandboxFlags.incl allowCast #E.g allowCast -> Allow unsafe language features
  sandboxFlags.incl allowInfiniteLoops 

  #A second more gamey example if the first example was not understandable
  type
    Flags = enum
      walk, attack, defend

  var moves: set[Flags]

  moves.incl walk
  moves.incl attack
  moves.incl defend

  echo moves

nbText: hlMd"""
Not much different on the first glance, than when we used a similar enumerator with a sequence,
but the operations you can do with enumerators in a Set, change the game.

Now the second use case is for Parsing data. In the following example,
we are going to make a "split" proc that will use a set of characters,
in order to search and destroy any of the characters specified in our Set:
"""
nbCode:
  import strutils

  proc split(s: string; seps: set[char] = #[strutils.Whitespace]# {' ', '!', '?'}): string = #const Whitespace = {' ', '\t', '\v', '\r', '\n', '\f'}
    var splitString = s
    var c: int

    for sep in seps:
      c = splitString.find(sep)
      splitString.delete(c, c)
    
    result = splitString
          
  var myString = "Hello , World !?" 
  echo myString

  echo myString.split 


nbText: hlMd"""
Here we go.

Now let's move on to Set pros, cons and use cases, many of which i have already mentioned,
but it's always good to have such a list of condensed data, 
so that one may check it again to know when to use Sets.
"""

nbSection "Set pros"
nbText: hlMd"""
- Extremely fast due to bitwise operations happening behind the scenes,
  along with being limited to 16 bytes/ordinal types.

- A ton of powerful operations you can do with them
  (membership testing, deduplication, distinct mathematical operations)
"""

nbSection "Set cons"
nbText: hlMd"""
- No easy way to access an element's data without changing a Set's data to a Sequence, 
  or another container construct
- Sets can only store elements of a single data type, 
  and only ordinal types(there are also HashSets which can be ordered and of any type you want, 
  but obviously a bit slower, use them if you need Set operations, and normal sets don't cover your data type)
- Sets are unordered, don't use them if you REALLY need order

    Example: you want objects of say bullets in a game,
    ordered by time created, so that you can destroy them to free memory and not have the game crash,
    due to way too many bullets being rendered in a game. One way of optimizing games with bullets,
    is to remove them after a certain amount of time, another is to remove them when they go out of bounds, etc)
"""
nbSection "Set use cases"
nbText: hlMd"""
-  Say you want to download some files from a remote computer via the File Transfer Protocol/FTP. 
    You can create a "set" with a listing of your local files and another with a listing of the remote files. 
    Then you can easily create a set of only the files you need to download.

	  files_to_download = remote_files - local_files
-  Removing duplicates/deduplication
-  Ownership checking
-  Say you made your game with a bunch of controller objects,
   which are then checked for their existence.
   And if they do exist say objectSFX, then sound effects will play,
   otherwise the game will have no soud effects.
   Or if you want to enable or disable debug mode.
   This can again be done with other such constructs, 
   but if your game has a ton of objects that work in such a way, 
   then they could all be checking for existence of controller objects to do their function,
   which would get really slow with Sequences.
-  Setting compiler flags by using Sets with Enumerators(or moves a unit in a game can do)
-  Parsing data(example 2 just before Set pros)
"""

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
- Version used: 2.0.0
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
- [Set type](https://nim-lang.org/docs/manual.html#types-set-type "Set type")
- [Set operations and extra modules](https://nim-lang.org/docs/system.html#system-module-sets "Set operations and extra modules")
- [Ordinal types](https://nim-lang.org/docs/manual.html#types-ordinal-types "Ordinal types")
- [Ordinal operations](https://nim-lang.org/docs/system.html#system-module-ordinals "Ordinal operations")
- [strutils module for the last example/use case of parsing data](https://nim-lang.org/docs/strutils.html "strutils module for the last example/use case parsing data")
"""

nbSave()