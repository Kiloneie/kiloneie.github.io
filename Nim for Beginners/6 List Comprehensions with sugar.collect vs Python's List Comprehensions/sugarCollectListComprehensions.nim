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
#nbCodeInBlock -> opens up a new scope like the "block" statement, useful for when you don't want to use different variable names etc
#https://pietroppeter.github.io/nimib/allblocks.html
#nbShow is super useful!

#https://nim-lang.org/docs/manual.html#lexical-analysis-raw-string-literals raw strings r""

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

#Templates for showing Python code snippets and output
template nbPythonShowOnlyCode(body: untyped) =
  newNbCodeBlock("nbPythonShowOnlyCode", body):
    nb.blk.output = body

nb.partials["nbPythonShowOnlyCode"] = """<pre><code class="python hljs">{{&output}}</code></pre>"""
nb.renderPlans["nbPythonShowOnlyCode"] = @["highlightCode"]

template nbPythonShowOnlyOutput(body: untyped) =
  newNbCodeBlock("nbPythonShowOnlyOutput", body):
    nb.blk.output = body

nb.partials["nbPythonShowOnlyOutput"] = """<pre><code class=\"language-markdown\" style = "color:white;background-color: rgba(255, 255, 255, 0);font-size: 12px;">{{&output}}</code></pre>"""
nb.renderPlans["nbPythonShowOnlyOutput"] = @["highlightCode"]

# how to add a ToC
var
  nbToc: NbBlock

template addToc =
  newNbBlock("nbText", false, nb, nbToc, ""):
    nbToc.output = "## Table of Contents:\n\n"

var index = (section: 0, subsection: 0)

template nbSection(name:string) =
  index.section.inc
  index.subsection = 0 #Reset on a new nbSection

  let anchorName = name.toLower.replace(" ", "-")
  nbText "<a name = \"" & anchorName & "\"></a>\n# " & $index.section & ". " & name & "\n\n---"
  # see below, but any number works for a numbered list
  nbToc.output.add "- " & $index.section & r"\. " & "<a href=\"#" & anchorName & "\">" & name & "</a>\n" #&#92; is HTML code for "\", you can also "\\" or r"\"
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

#Adding hlMd or hlMdf enables nimiboost's markdown highlight mode
nbText: hlMdF"""
## INTRO - GREETING
- **Title**: List Comprehensions with sugar.collect and comparison against Python's List Comprehensions
- **Alt Title**: List Comprehensions with sugar.collect vs Python's List Comprehensions

## INTRO - FOREWORDS
**(What is the purpose of this video ?)**
- List comprehensions with sugar.collect and comparison against Python's List Comprehensions:
  - In this video we will go over sugar.collect, it's pros and cons,
    and compare it against Python's list comprehensions with some benchmarks.
   
The code for this video and it's script/documentation styled with nimib,
is in the link in the description as a form of written tutorial.
"""

nbSection "List Comprehensions"
nbText: """
  sugar.`collect` is a macro, a macro used for list comprehensions. 
  A list comprehension is basically making a list from an existing list based on some variable parameters.
  This can be done with either a for loop or sugar.collect, list comprehensions in Python.
"""

nbSubSection "Nim - Comprehending a list with a for loop"
nbText: """
  In the following example, we make a new list/sequence based on the `fruit` sequence,
  by iterating over it with a `for` loop using the `pairs` iterator,
  and returning only the elements of the list starting with the letter "P".
"""
nbCode:
  let fruit = @["Apple", "Orange", "Banana", "Peach", "Pear", "Pineapple"]

  var pFruit: seq[string]

  for i, f in fruit.pairs:
    if $f[0] == "P":
      pFruit.add f

  echo pFruit

#The following section is only shown(we are NOT teaching Python)
nbSubSection  "Python's List Comprehension structure" 
nbText: """
  Before we go on for the Python's version of the above example,
  here is the structure of a Python's **list comprehension**,
  with explanation.
"""
nbPythonShowOnlyCode: hlPy"""
  list = [returned for element in container if condition]
"""
nbText: hlmd"""
- **returned** - the element/value that will be returned/put in a new list.
- **element** - element of "a" container.
- **container** - dict, list, set, tuple(in Nim, it's a data structure).
- **condition** - optional -> to perform operations for the "returned".
"""

nbSubSection "Python - Comprehending a list with a for loop"
nbPythonShowOnlyCode: hlPy"""
  fruit = ["Apple", "Orange", "Banana", "Peach", "Pear", "Pineapple"]
  pfruit = []

  for f in fruit:
    if "P" in f:
      pfruit.append(f)

  print(pfruit)
"""
nbPythonShowOnlyOutput: hlPy"""
  ['Peach', 'Pear', 'Pineapple']
"""

nbSubSection "Nim - Using sugar.collect"
nbText: """
  The exact same code as the one with the `for` loop,
  except now it uses the `sugar` module's `collect` macro.
"""
nbCode:
  let pFruit2 = collect(newSeq):
    for i, f in fruit.pairs:
      if $f[0] == "P":
        f

  echo pFruit
  echo pFruit2

nbSubSection "Python - List Comprehension"
nbPythonShowOnlyCode: hlPy"""
  fruit2 = ["Apple", "Orange", "Banana", "Peach", "Pear", "Pineapple"]

  pfruit2 = [f for f in fruit2 if "P" in f]

  print(pfruit)
  print(pfruit2)
"""
nbPythonShowOnlyOutput: hlPy"""
  ['Peach', 'Pear', 'Pineapple']
  ['Peach', 'Pear', 'Pineapple']
"""

nbSection "Python's list comprehensions vs Nim's `collect`"
nbText: """
Python's List comprehensions are a more compact way to create new lists, 
in situations where map() and filter(), and or nested loops would be used. 
They are great for simple tasks.

<div style = "font-size: 10px">
map(function, container, container,...) runs a function on given containers,
and returns only the elements that passed<br>
filter(function, container, container,...) runs a function on given containers, 
and transforms them, returninmg the transformed result</div>

Here are a few examples:
"""
nbPythonShowOnlyCode: hlPy"""
  print([i for i in range(10)])
"""
nbPythonShowOnlyCode: hlpy"""
  toTen = []
  for i in range(10):
    toTen.append(i)

  print(toTen)
"""
nbPythonShowOnlyOutput: hlPy"""
  [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
"""

nbPythonShowOnlyCode: hlPy"""
  print([i for i in range(20) if i%2 == 0])
"""
nbPythonShowOnlyCode: hlPy"""
  evenToTwenty = []
  for i in range(20):
    if i%2 == 0:
      evenToTwenty.append(i)

  print(evenToTwenty)
"""
nbPythonShowOnlyOutput: hlPy"""
  [0, 2, 4, 6, 8, 10, 12, 14, 16, 18]
"""

nbPythonShowOnlyCode: hlPy"""
  nums = [1, 2, 3, 4]
  fruit = ["Apples", "Peaches", "Pears", "Bananas"]
  print([(i, f) for i in nums for f in fruit])
"""
nbPythonShowOnlyCode: hlpy"""
  fourTimesFour = []
  for i in nums:
    for f in fruit:
      fourTimesFour.append((i, f)) #Double (()) - because tuple as argument - python demands () for funcs

  print(fourTimesFour)
"""
nbPythonShowOnlyOutput: hlPy"""
  [(1, 'Apples'), (1, 'Peaches'), (1, 'Pears'), (1, 'Bananas'),
  (2, 'Apples'), (2, 'Peaches'), (2, 'Pears'), (2, 'Bananas'),
  (3, 'Apples'), (3, 'Peaches'), (3, 'Pears'), (3, 'Bananas'),
  (4, 'Apples'), (4, 'Peaches'), (4, 'Pears'), (4, 'Bananas')]
"""

nbPythonShowOnlyCode: hlPy"""
  print([(i, f) for i in nums for f in fruit if f[0] == "P"])
"""
nbPythonShowOnlyCode: hlPy"""
  fruitP = []
  for i in nums:
    for f in fruit:
      if f[0] == "P":
        fruitP.append((i, f))

  print(fruitP)
"""
nbPythonShowOnlyOutput: hlPy"""
  [(1, 'Peaches'), (1, 'Pears'),
  (2, 'Peaches'), (2, 'Pears'),
  (3, 'Peaches'), (3, 'Pears'),
  (4, 'Peaches'), (4, 'Pears')]
"""

nbPythonShowOnlyCode: hlPy"""
  print([(i, f) for i in nums for f in fruit if f[0] == "P" if i%2 == 1])
"""
nbPythonShowOnlyCode: hlpy"""
  fruitPodd = []
  for i in nums:
    for f in fruit:
      if f[0] == "P" and i%2 == 1:
        fruitPodd.append((i, f))

  print(fruitPodd)
"""
nbPythonShowOnlyOutput: hlPy"""
  [(1, 'Peaches'), (1, 'Pears'), (3, 'Peaches'), (3, 'Pears')]
"""

nbPythonShowOnlyCode: hlPy"""
  print([i for i in zip(nums, fruit) if i[0] %2== 0])
"""
nbPythonShowOnlyCode: hlpy"""
  fruitEvenZip = []

  for i in zip(nums, fruit):
    if i[0] %2 == 0:
      fruitEvenZip.append(i)

  print(fruitEvenZip)
"""
nbPythonShowOnlyOutput: hlPy"""
  [(2, 'Peaches'), (4, 'Bananas')]
"""

nbSubSection "Python's List Comprehension Cons"
nbText: """
  Python's List Comprehension are useful for small and simple lists, but become extremely hard to understand the more complex they become,
  unlike just using a for loop, which is yes more verbose, but also easier to understand and read,
  especially if you haven't viewed the code with with a list comprehension for a while.

  Here is a **good** example of a **bad** one liner:
"""
nbPythonShowOnlyCode: hlPy"""
  listLLL = [[[1,2,3],[4,5,6],[7,8,9]]]
  flatten_keep_evens = [item for listLL in listLLL for listL in listLL for item in listL if item % 2 == 0]

  print(flatten_keep_evens)
"""
nbPythonShowOnlyOutput: hlPy"""
  [2, 4, 6, 8]
"""

nbText: """
The above **good** example of a **bad** one liner, 
can be greatly improved by indentation(like a for loop) like this:
"""
nbPythonShowOnlyCode: hlPy"""
  doubleNestedLLL = [[[1,2,3], [4,5,6], [7,8,9]]]
  flatenedEvens = [
      element
      for nestedLL in doubleNestedLLL
      for elementsL in nestedLL
      for element in elementsL
      if not element % 2
  ]

  print(flatenedEvens)
"""
nbPythonShowOnlyOutput: hlPy"""
  [2, 4, 6, 8]
"""

nbSection "Nim's sugar `collect` Pros"
nbSubSection "Long one liners are bad"
nbText: """
Nim does not do list comprehensions as one liners like Python does,
they work very much the same as a for loop, but reduce a bit of typing,
by not having to declare/initialize a sequence before hand, but at the moment of usage.
Then we also don't need to call `.add + elementWeWant`, but just the `elementWeWant`. 
"""

nbSubSection "Sugar `collect` also works on Sets and Tables"
nbText: """
Nim's sugar's collect also works on hashSets and Tables, unlike Python.
Nim's collect macro does not have the drawbacks of Python's list comprehensions,
while being much more powerful, because `collect` also works on other types.
These types being, Sets, HashSets and Tables.
"""

nbSubSection "`collect` with Sets"
nbCode:
  var normalSet = {1, 2, 3, 4, 5, 6}

  var evenNumbers = collect:
    for num in normalSet:
      if num mod 2 == 0:
        num

  echo evenNumbers

nbSubSection "`collect` with hashSets"
nbCode:
  import std/sets

  let keyValueSet = [("Key 1", 1), ("Key 2", 2), ("Key 3", 3), ("Key 4", 4), ("Key 5", 5)].toOrderedSet

nbText: """
  **Normal version:**
"""
nbCode:
  var oddKeys: HashSet[(string, int)]

  for tup in keyValueSet:
    if tup[1] mod 2 != 0:
      oddKeys.incl tup

  echo oddKeys

nbText: """
  **`collect` version:**
"""
nbCode:
  var oddKeysCollect = collect:
    for tup in keyValueSet:
      if tup[1] mod 2 != 0:
        tup

  echo oddKeysCollect

nbSubSection "`collect` with Tables"
nbCode:
  import std/tables

  let characterClassEquipment = {"Paladin": @["Maul", "Breastplate"], 
                                "Wizard": @["Staff", "Robe"], "Druid": @["Staff"],
                                "Fighter": @["Sword", "Shield", "Plate Armour"]}.toOrderedTable
nbText: """
  **Normal version:**
"""
nbCode:
  var staffWielders = initOrderedTable[string, seq[string]]() #Do NOT forget `()` at the end

  for class, items in characterClassEquipment:
    for item in items:
      if item == "Staff":
        staffWielders[class] = items #`table.add key, value` is now deprecated(marked for future removal)

  echo staffWielders

nbText: """
  **`collect` version:**
"""
nbCode:
  var staffWieldersCollect = collect:
    for class, items in characterClassEquipment:
      for item in items:
        if item == "Staff":
          {class: items} #Kind of bizzare way of returning
  
  echo staffWieldersCollect

nbSubSection "sugar.collect as a one-liner"
nbText: """
  You can also write sugar.collect as a one-liner like this:
"""
nbCode:
  let evenNumbs = collect(for i in [0, 1, 2, 3, 4]: (if i mod 2 == 0: i))
  echo evenNumbs

nbText: """
  Credits to: "razorgamedev" for pointing that out to me on the reddit post.
"""

nbSection "Performance Benchmarks"
nbText: """
  Now i will show you performance benchmarks of 3 variants of making a new list,
  in both Python and Nim. This is NOT a benchmark of the languages.
  This is only meant to see the difference of the 3 variants.

  My relevant computer specs used for this benchmark:
  - **CPU**: Ryzen 2700x
  - **RAM**: G.Skill Ripjaws V 16GB (2x8GB) DDR4 F4-3200C16D-16GVKB

  The 3 variants are as follow:
  - **add** and **append**
  - **index** - **[]**
  - **collect** and **list comprehension**

  All 3 variants of the 2 versions of Nim and Python,
  create a new list by filling a pre-initialized to size 10000 sequence/array,
  with arbitrary data, that is then benchmarked 10000 times,
  in order to account for slight variations that occur.
  The resulting time elapsed is then divided back by 10000,
  to get the mostly correct/aproximate time elapsed for our variations.

  This is eased for Nim by the usage of a custom template,
  while Python has an official module specifically for this purpose.
"""

nbSubSection "Nim's 3 variants"
nbCodeSkip: #Skip - No benching when writting the script!
  import std/times, std/os, std/strutils, std/sequtils, std/sugar

  template benchmark(benchmarkName: string, timesToRun: int, code: untyped) =
    block:
      let t0 = cpuTime()

      for run in 0..timesToRun:
        code

      let elapsed = cpuTime() - t0
      let elapsedProcessed = elapsed / timesToRun
      let elapsedProcessedStr = elapsedProcessed.formatFloat(format = ffDecimal, precision = 12)
      echo "CPU Time [", benchmarkName, "] x ", timesToRun, " = ", elapsedProcessedStr, "s"

  benchmark "add    ", 10000:
    let num = 10000
    var list: seq[num.typeof]

    for j in 0..num:
      list.add j

  benchmark "index  ", 10000:
    let num = 10000

    #Initializing a seq of 10000 ups the time by about 3x
    var list = newSeqWith(num, 0) #size, default value

    for index, ele in list.pairs:
      list[index] = index

  benchmark "collect", 10000:
    let num = 10000

    var list = collect:
      for i in 0..num:
        i
#Using template for Python because i don't wanna wait for the benches when writting the script!
nbPythonShowOnlyOutput: """ 
CPU Time [add    ] x 10000 = 0.000166400000s
CPU Time [index  ] x 10000 = 0.000138800000s
CPU Time [collect] x 10000 = 0.000165400000s
"""

nbSubSection "Python's 3 variants"
nbPythonShowOnlyCode: hlPy"""
  from timeit import timeit

  def fAppend():
      num = 10000
      li = []
      for i in range(num):
          li.append(i)

  def fIndex():
      num = 10000
      li = [0] * num
      for i in range(num):
          li[i] = i

  def fLComprehension():
      num = 10000
      li = [i for i in range(num)]

  def main(x):
      print(timeit(stmt = fAppend, number = x) / x)
      print(timeit(stmt = fIndex, number = x) / x)
      print(timeit(stmt = fLComprehension, number = x) / x)

  main(10000) 
"""
nbPythonShowOnlyOutput: hlPy"""
  CPU Time [append       ] x 10000 = 0.00065512317
  CPU Time [index        ] x 10000 = 0.0003905595900000001
  CPU Time [comprehension] x 10000 = 0.0002650251300000001
"""
nbText: """
<h6>(You may run the above benchmarks yourself to double check the data. 
But the results will vary by your CPU and RAM speeds.)</h6>
"""

nbSubSection "Why doesn't Nim have proper list comprehensions ?"
nbText: """
  Nim doesn't have list comprehensions as part of the language,
  because what can be done as a **macro**, should be done as a **macro**.

  This is a part of Nim's philosophy of keeping the language as small as possible,
  while implementing what is not required or needed as a **macro** in a usually separate module.
"""

nbUoSection "Outro - Afterwords"
nbText: """
  Okay, that's it for this video, thanks for watching like, share and subscribe, 
    aswell as click the bell icon if you liked it and want more, 
    you can also support me on Patreon if you so wish. 
    If you had any problems with any part of the video, 
    let me know in the comment section, 
    the code of this video, script and documentation, are in the link in the description,
    as a form of written tutorial.
"""
nbUoSection "Thanks to my past and current Patrons"
nbUoSubSection "Past Patrons"
nbText: """
- Goose_Egg: From April 4th 2021 to May 10th 2022
- Davide Galilei(1x month)
"""
nbUoSubSection "Current Patrons"
nbText: """
- jaap groot (from October 2023)
- Dimitri Lesnoff (from October 2023)
"""
nbUoSubSection "Compiler Information"
nbText: """
- Version used: E.G. 2.0.2
- Compiler settings used: none, ORC is now the default memory management option(mm:orc)
"""
nbUoSubSection "My and General Links"
nbText: """
- [Patreon](https://www.patreon.com/Kiloneie?fan_landing=true "Patreon")
- [Visual Studio Code Shortcuts](https://code.visualstudio.com/shortcuts/keyboard-shortcuts-windows.pdf "Visual Studio Code Shortcuts")
"""
nbUoSubSection "Links to this video's subject:"
nbText: """
- [Sugar module's collect macro](https://nim-lang.org/docs/sugar.html#collect.m%2Cuntyped "sugar.collect")
- [Python's List Comprehensions](https://www.w3schools.com/python/python_lists_comprehension.asp "Python's List Comprehensions")
- [Python's map() function](https://www.w3schools.com/python/ref_func_map.asp "Python's map() function")
- [Python's filter() function](https://www.w3schools.com/python/ref_func_filter.asp "Python's filter() function")
- [Python's benchmarking timeit module's timeit() function](https://docs.python.org/3/library/timeit.html "Python's benchmarking timeit module's timeit() function")
- [Nim's formatFloat func](https://nim-lang.org/docs/strutils.html#formatFloat%2Cfloat%2CFloatFormatMode%2Crange%5B%5D%2Cchar "Nim's formatFloat func")
- [Nim's cpuTime from the Times module](https://nim-lang.org/docs/times.html#cpuTime "Nim's cpuTime from the Times module")
"""

nbSave()