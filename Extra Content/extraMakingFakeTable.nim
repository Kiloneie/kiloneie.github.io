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
- TITLE: Extra Content - Creating a fake Table using hashSets and Generics

## INTRO - FOREWORDS
<b>(What is the purpose of this written tutorial ?)</b>
- In this extra tutorial we will create a fakeTable using hashSets,
  which will function like a hashTable. By making this fake Table,
  i will teach you `generics`, `overloading` much more in depth,
  than the old 4 minutes long `Procedure Overloading` video.
"""

nbSection "Creating a fake Table using hashSets"

nbSubSection "Why ?"
nbText: """
  To have a hash Table with `Set operations` you have seen the previous `Sets` video,
  which can make your life quite a bit easier.
"""

nbSubSection "How ?"
nbText: """
  In order to create this fakeTable using hashSets,
    we will have to use `tuples`.
    Tuples, because they are a 2x field data structure just like Tables are.
    We will also have to use `generics` to overload existing procs and operators that Sets use, 
    in order for the (key, value) tuples, to be able to be of any Nim's data type, 
    without having to overload an insane number of times.
"""

nbSection "Fake Table, but better ?"
nbText: """
  First of, we need to define our FakeTable and then overload the `hash` proc,
  and make a custom `iterator` that uses that overloaded `hash` proc,
  just like in the previous video of `hashSets, more on hash Tables and Hashing`,
  but with generics.
"""

nbSubSection "`KeyValue` and `FakeTable` Definition"
nbText """
  First the definition of our tuple to serve as our (key, value),
  followed by `FakeTable`, which is also easier to read and write than,
  `HashSet[KeyValue[K, V]]`
"""
nbCode:
  import std/hashes, std/sets

  type
    KeyValue[K, V] = tuple
      key: K
      value: V
    
    FakeTable[K, V] = HashSet[KeyValue[K, V]]
nbText: """
  <h6>(From now on, when you see fakeTable or fake Table, i mean the idea, implementation of a "fake table",
  and NOT the `FakeTable` type)</h6>
"""

nbSubSection "`hash` proc overload WITH an iterator"
nbText """
  Now the `hash` proc overload which is almost exactly the same as in the previous video,
  except for the generic part and the "runnableExamples":
"""
nbCode:
  proc hash[K, V](fakeTable: FakeTable[K, V]): Hash =
    var h: Hash = 0

    for xAtom in fakeTable.elements:
      h = h !& xAtom # !& mixes a hash value "h" with "val" to produce a new hash value - only requires for use in overloading hash() proc for use in new data types
    result = !$h # !$ finishes the computation of the hash value - only required for use in overloading hash() proc for use in new data types

    runnableExamples:
      var keyValue = initHashSet[KeyValue[string, int]]()

      keyValue.incl ("Key 1", 101)
      keyValue.incl ("Key 2", 202)

      for e in keyValue.elements:
        echo "keyValue.elements: ", e
nbText: """
  In order to achieve a fakeTable with hashSets, we must again use hashSets,
  and so this `hash` proc takes a `HashSet` of type `KeyValue` with generic parameters of `K, V`,
  so that this fakeTable can function like a Table, which can use just about any data type.

  The `runnableExamples:` part is ignored by the `debug`(what we are using) and the `release` versions,
  of our programs. It's simply an area meant for examples of the proc, iterator etc.
"""

nbSubSection "Overloading the custom `elements` iterator for the `hash` proc"
nbCode:
  iterator elements[K, V](fakeTable: FakeTable[K, V]): Hash =
    for tup in fakeTable:
      yield hash(tup.key)
      yield hash(tup.value)
nbText: """
  Again the first changes to this custom iterator are the generic parts.
  The second change is because we are giving this iterator,
  instead of fields of an object, a `FakeTable` type which is a `HashSet` container of type `KeyValue`, our tuple.
  And so we must first `unwrap` this `FakeTable` with a simple `for loop`,
  to get the tuple elements, and then it works as before, hashing the 2x fields of our `KeyValue` tuple instead of an object.

  **Now let's try that `runnableExamples:`'s example:**
"""
nbCode:
  var keyValue = initHashSet[KeyValue[string, int]]()

  keyValue.incl ("Key 1", 101)
  keyValue.incl ("Key 2", 202)

  for e in keyValue.elements:
    echo "keyValue.elements: ", e
nbText: """
  Here we go, both fields of the 2x tuples hashed.
"""

nbSubSection "`hash` proc overload WITHOUT an iterator"
nbText: """
  It does not take the `FakeTable` type, because that would mean it would require an iterator:
"""
nbCode:
  proc hash[K, V](keyValue: KeyValue[K, V]): Hash =
    var h: Hash = 0

    h = h !& hash(keyValue.key) # !& mixes a hash value "h" with "val" to produce a new hash value - only requires for use in overloading hash() proc for use in new data types
    h = h !& hash(keyValue.value)
    result = !$h # !$ finishes the computation of the hash value - only required for use in overloading hash() proc for use in new data types

    runnableExamples:
      var keyValue = initHashSet[KeyValue[string, int]]()

      keyValue.incl ("Key 1", 101)
      keyValue.incl ("Key 2", 202)

      for tup in keyValue:
        echo "Hashing tuple: ", tup
        echo tup.hash

nbSubSection "Making a constructor proc for `FakeTable`"
nbText: """
  Now let's make a `constructor proc` to make creation/initialization of our `FakeTable`,
  easier and faster than having to write `HashSet[KeyValue[K, V]]`,
  AND, to actually use a `FakeTable` type, since `HashSet[KeyValue[K, V]]`,
  is NOT a `FakeTable`

  This proc will once again be a generic, since a Table's key and value can be of almost any data type,
  we need 2x generic arguments `[K, V]` for the (key, value) fields of our `KeyValue` tuple.
  Then we give it 2x arguments of type `typedesc`, which is short for `typedescription`.
  `typedesc` which is a meta type to denote a type description and is required to make our fakeTable.
  If we instead make our 2x arguments: "keyType: K, valueType: V",
  when we will try to use this proc, the Nim's VS Code extension will tell us that we have,
  a variable with `typedesc type, typedesc type`, instead of `type, type`.
  This is because we are giving types to our proc to make our HashSet[KeyValue[type, type]],
  and not some operation working with values of types already `initialized` outside of the `proc`

  And then we simply use the initialization proc for hashSets `initHashSet` of type KeyValue[type, type],
  to initialize our fakeTable of type `FakeTable`.
"""
nbCode:
  proc newFakeTable[K, V](keyType: typedesc[K], valueType: typedesc[V]): FakeTable[K, V] =
    result = initHashSet[KeyValue[K, V]]() #Have to use `result =` with `runnableExamples:` present

    runnableExamples:
      var fakeTable = newFakeTable(char, int)
      fakeTable.incl ('a', 10)
      echo fakeTable, " ", fakeTable.typeof
nbText: """
  **Now let's run the runnable example:**
"""
nbCode:
  var fakeTable = newFakeTable(char, int)
  fakeTable.incl ('a', 10)

  echo fakeTable, " ", fakeTable.typeof
nbText: """
  As you can see, initializing our fakeTable is much simpler than the original of:
"""
nbCodeSkip:
  var keyValue = initHashSet[KeyValue[string, int]]()

nbSubSection "Making a `OrderedSet` version of our constructor proc"
nbText: """
  First we make another type just like with we did for our FakeTable type,
  but instead of using a `HashSet`, we use a `OrderedSet`.
  And then lastly, we simply rename the return type to `FakeOrderedTable`
"""
nbCode:
  type
    FakeOrderedTable[K, V] = OrderedSet[KeyValue[K, V]]

  proc newOrderedFakeTable[K, V](keyType: typedesc[K], valueType: typedesc[V]): FakeOrderedTable[K, V] =
    initOrderedSet[KeyValue[K, V]]()

    runnableExamples:
      var fakeOrderedTable = newOrderedFakeTable(char, int)
      fakeOrderedTable.incl ('a', 10)
      echo fakeOrderedTable, " ", fakeOrderedTable.typeof

nbSection "Overloading"
nbText: """
  Now let's move on to overloading ALL of the operations normal `sets` can use,
  here is the list from the `sets video`:

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

  **As well as:**
  - \`[]\`(`[]` with apostrophes) so that we can find the value of a key, by supplying the key.
    Otherwise we have to supply the entire `tuple`.

  **And** `missingOrExcl(HashSet, key)` as an extra(only for hashSets, not normal Sets)
"""

nbSubSection "`contains` alias for `in` overload"
nbText """
  Let's start with `contains(container, key)`, which is an alias for the `in` operator.
  So that we can easily find a `key` inside our `FakeTable`'s `KeyValue` tuple,
  and with that `key`, it's `value:
"""
nbCode:
  # `in` is an alias for `contains`, 
  proc contains[K, V](fakeTable: FakeTable[K, V], k: K): bool =
    for tup in fakeTable:
      if tup.key == k:
        return true
nbText: """
  As you can see, we make it a `generic` proc that takes our `FakeTable` type,
  unwraps the `fakeTable`, and then checks every `KeyValue` tuple's first field of `key`,
  against `k`, the key we are looking for, and then returns true or false if it found it or not.

  **Here is an example of it's usage:**
"""
nbCode:
  var fakeTableContains = newFakeTable(string, int)

  fakeTableContains.incl ("Key 1", 101) #elements as tuples
  fakeTableContains.incl ("Key 2", 202) #elements as tuples

  if "Key 2" in fakeTableContains:
    echo "SUCCESS: Key 2 is in fakeTableContains"

nbSubSection "&#96;[]&#96; overload" #&#96; is inline HTML for ` backticks - cannot use double backticks here
nbText: """
  Now let's overload the \`[]\`(`[]` with apostrophes),
  to again, be able to easily find a `key` inside our `FakeTable`'s `KeyValue` tuple,
  and with that `key`, it's `value:
"""
nbCode:
  proc `[]`[K, V](fakeTable: FakeTable[K, V], k: K): V {.inline.} =
    for tup in fakeTable:
      if tup.key == k:
        return tup.value

nbText: """
  Very similar to the `contains`(`in` is the alias) overload.
  The strange part here is the `{.inline.}` pragma,
  which is simply there to mark it for the compiler(which will warn us) and us,
  that we should not call this proc `[]` directly,
  as in like a proc `[](arg1, arg2)`.

  **Here is the example of what that overload enables us:**
"""
nbCode:
  echo fakeTableContains
  echo fakeTableContains["Key 1"]

nbText: """
  **NOTE:** All of these overloads have to focus on the `key` part of the `KeyValue` tuple,
  in order to achieve the functionality of a `Table`.
  Meaning, these overloads must make it so that we only work with the `keys`,
  and not `tuples`.
"""

nbSubsection "&#96;+&#96; - union - operator overload"
nbText: """
  Now let's overload the `+` operator(proc), which is the `union` between Set1 and Set2,
  meaning both sets.
"""
nbCode:
  proc `+`[K, V](a: FakeTable[K, V], b: FakeTable[K, V]): FakeTable[K, V] =
    #Checking only the keys
    for tupA in a:
      for tupB in b:
        if tupA.key != tupB.key:
          result.incl tupA
          result.incl tupB
nbText: """
  The overload proc's head, could also put both arguments together like this:
"""
nbCodeSkip:
  proc `+`[K, V](a, b: FakeTable[K, V]): FakeTable[K, V] =
    discard
nbText: """
  **How it works:** Well, first of we unwrap the first `FakeTable`(HashSet[KeyValue[K, V]]) with a for loop,
  then we unwrap the second with another for loop on the second `FakeTable` of `b`,
  in order to -> elementOfSet1.key != elementOfSet1.key -> elementOfSet1.key != elementOfSet`2`.key -> 
  and so on, until we compare every element's key of `a` against every element's key of `b`,
  in order to find only the `keys`, both `FakeTables` share,
  to return a `result` of the `union` of both `FakeTables`.

  Remember that `sets` do not allow for duplicate keys.
  Checking without the `.key` part, could result in duplicate keys,
  because, even though our `FakeTable` is a `HashSet` which doesn't allow for duplicate elements,
  it can only do so, if the `(key, value)` tuple elements we have in it,
  have both fields of our `KeyValue` tuple `(key, value)` exactly the same,
  as another `KeyValue` tuple `(key, value)`.
  Tuples are only equal if both tuples have both fields identical.

  This is why we must provide "help" to our `FakeTable`'s overload procs.

  **Now let's finally see an example of the `+` operator(proc) overload:**
"""
nbCode:
  var fTableA = newFakeTable(char, int)
  var fTableB = newFakeTable(char, int)

  fTableA.incl ('A', 1)
  fTableA.incl ('B', 2)

  fTableB.incl ('B', 2)
  fTableB.incl ('C', 3)

  echo fTableA + fTableB

nbText: """
  Here we go, all the elements of both `FakeTables`, without duplicates.
"""

nbSubSection "&#96;-&#96; - difference - operator overload"
nbText """
  Now let's overload the `-` operator(proc) - Difference - Returns the elements that `fTableA` has,
  but `fTableB` does not.
"""
nbCode:
  proc `-`[K, V](a, b: FakeTable[K, V]): FakeTable[K, V] =
    #Checking only the keys
    var tempA = a
    var tempB = b

    #De-duplication
    for tupA in a:
      for tupB in b:
        if tupA.key == tupB.key:
          tempA.excl(tupA)
          tempB.excl(tupB)

    for tupA in tempA:
      for tupB in tempB:
        if tupA.key != tupB.key:
          if tupA in result:
            discard
          else:
            result.incl tupA
nbText: """
  First of, we copy the 2 `FakeTable`s of `a` and `b` into temporary variables of `tempA` and `tempB`,
  because want to de-duplicate the `FakeTable`s and only return different elements,
  and we can't do that with the `FakeTables` we supplied to the 2x arguments of `a` and `b`,
  because you can't modify arguments received.
  We also can't use `var` before `FakeTable` as in `a: var FakeTable`,
  because we would be modifying the original `FakeTable`s, which we don't want to do.

  So the second part marked with the `#De-duplication comment`,
  is where we unwrap both of the `FakeTables`,
  and check all the `keys` of the `KeyValue` tuples for identical keys/duplicates,
  and then remove them from both, because this isn't just to find and remove duplicates,
  but also because the `-` operator(proc), is supposed to only return the elements,
  that are not in `FakeTable` `b` - any duplicates/shared elements.

  And lastly, the third part then unwraps both `temp` `FakeTable`s,
  and looks for `different keys`, and also checks the `result` variable,
  because checking if the keys are not equal and then including `tupA`,
  the remaining keys WILL be different, and if both `FakeTable`s have 2x elements each,
  then both of the elements of `tupA`, would be added twice,
  requiring further de-duplication. Checking the `result` variable, fixes that.

  **Here is an example of manually going trough this overloaded `-` operator(proc):**
"""
nbCode:
  discard #nimib requires a return
  #a b c #a: FakeTable
  #c d e #b: FakeTable
  #De-duplication
  #a b
  #d e
  #1 a != d -> yes adding `a`
  #2 a != e -> yes adding `a` -> duplicated `a` -> hashSet detects that, removes it. BUT tuples != if not all fields are equal
  #3 b != d -> yes adding `b`
  #4 b != e -> yes adding `b`
  #result = {'a', 'a', 'b', 'b'} -> correct if we deduplicate... this could go on to infinity.
  #So checking the `result` variable fixes the above problem

nbText: """
  **And here is the code for the above manual explanation:**
"""
nbCode:
  var ftA = newFakeTable(char, int)
  var ftB = newFakeTable(char, int)

  ftA.incl ('a', 10); ftA.incl ('b', 20); ftA.incl ('c', 30)
  ftB.incl ('c', 30); ftB.incl ('d', 40); ftB.incl ('e', 50)

  echo "ftA: ", ftA
  echo "ftB: ", ftB

  echo "ftA - ftB = ", ftA - ftB
nbText: """
  **And the reverse:**
"""
nbCode:
  echo "ftB - ftA = ", ftB - ftA

nbSubSection "Optional Semicolon `;`"
nbText: """
  In the above code i have also used `;` which is optional in Nim,
  and allows for multiple operations to be used on a single line.
  I think it's quite useful for such small operations that work the same,
  to be put on a single line, instead of heavily spreading vertically.
  I don't recommend using the optional semicolon `;` for large operations,
  or different ones, most people don't like that,
  and it will hurt clarity and readability. But again, for same operations of such small scale, yes.
"""

nbSubSection "&#96;*&#96; - intersection - operator overload"
nbText: """
  Now we will overload the `*` operator(proc) - intersection - returns only shared elements.
  This one is very simple, simply compare the keys, and add one of them into the `result`(since both are the same):
"""
nbCode:
  proc `*`[K, V](a, b: FakeTable[K, V]): FakeTable[K, V] =
    #Checking only the keys
    for tupA in a:
      for tupB in b:
        if tupA.key == tupB.key:
          result.incl tupA

nbText: """
  **Example:**
"""
nbCode:
  echo ftA * ftB

nbSubSection "&#96;<&#96; - subset of - operator overload"
nbText: """
  Next is `<` operator(proc) overload - `a` subset of `b`
  First of, when using this operator, the `subset` HAS to be smaller than the set(FakeTable) we are comparing against.

  Which is easily achieved by first checking the lengths of the 2x `FakeTable`s:
    `if a.len >= b.len: return false`, `else:` we continue.
  Then we set the `result` variable to `false`, unwrap the 2x `FakeTable`s,
  make a `block subsetA` statement, so that we can easily break out of the second loop once we find an identical key,
  after setting the `result` variable to `true`˙.

  **This is for 2x reasons:** The first is for reasons of speed, we are checking every element of `FakeTable` `a`,
  against every element of `FakeTable` `b`, there are no duplicates, so once found, it's a waste to continue.

  And secondly, because we have to set the `result` variable to `false` if the keys are not identical,
  so that once loop 2 ends, and loop 1 is about to start another run of loop 2 with the next element,
  and we found no matching `keys`, then `FakeTable` `a` is NOT a subset of `FakeTable` `˙b`.
  And because of that, if we don't break out back to loop 1 using the `labeled block` statement,
  we could find a matching key, but then on the second element override it to false!
"""
nbCode:
  proc `<`[K, V](a, b: FakeTable[K, V]): bool =
    #Checking only the keys
    if a.len >= b.len:
      return false
    else:
      result = false
      for tupA in a:
        block subsetA:
          for tupB in b:
            if tupA.key == tupB.key:
              result = true
              break subsetA #1 so if we find "true", we don't keep on checking(the Set could be gigantic), AND so that if the results would be false, true, false, we don't overwrite the true on the third check.
            else: result = false
        if result == false: #2 we end up here after the break, if false, then it's not a subset, otherwise next tupA
          return false #This is here, again like #1, so we don't keep on checking.
nbText: """
  **Here is an example:**
"""
nbCode:
  #ftA has 'a', 'b', 'c'
  var subsetOfA = newFakeTable(char, int)

  subsetOfA.incl ('a', 10)
  subsetOfA.incl ('c', 30)

  echo ftA
  echo subsetOfA
  echo subsetOfA < ftA

  var subsetofA2 = ftA
  echo subsetofA2 < ftA
nbText: """
  `subsetofA2 is false because it is equal in size of `ftA`, again, has to be smaller.
"""

nbSubSection "&#96;<=&#96; - subset relation - operator overload"
nbText: """
  The `<=`(subset relation) operator(proc), does the exact same as `<`(subset of) operator,
  except that the subset can be equal in size.

  **Here is the code to overload `<=` operator(proc):**
"""
nbCode:
  proc `<=`[K, V](a, b: FakeTable[K, V]): bool =
    #Checking only the keys
    if system.`<=`(a.len, b.len): #Can't do this: if a.len <= b.len: -> for some reason this overload calls itself instead of the system <=
      result = false
      for tupA in a:
        block subsetA:
          for tupB in b:
            if tupA.key == tupB.key:
              result = true
              break subsetA #1 so if we find "true", we don't keep on checking(the Set could be gigantic), AND so that if the results would be false, true, false, we don't overwrite the true on the third check.
            else: result = false
        if result == false: #2 we end up here after the break, if false, then it's not a subset, otherwise next tupA
          return false #This is here, again like #1, so we don't keep on checking.
    else:
      return false
nbText: """
  The only real change here compared to the `<` overload,
  is that instead of checking for the `subset` to be smaller,
  we check for smaller or equal.
  Here i found a bit of a problem. For some reason when using the `<=` operator,
  Nim calls the version we are in right now, instead of the `system` module one.
  So in order to tell it to use the correct one,
  we have to explicitly specify that with `system.` + **\`<=\`** + `(a.len, b.len)`,
  instead of simply `a.len <= b.len`.
"""

nbSubSection "&#96;==&#96; - equality - operator overload"
nbText """
  **Now let's also overload the `==` operator(proc)**,
  so that we are no longer comparing tuples, which require both fields to be equal for equivalence.
  With this overload we would only require the `keys`.

  With this overload, we also have to use the `system.` way of explicitly calling the system module's `==` operator.
  I am pretty sure, that the reason this happens, is for reasons of `recursion`,
  proc calling itself, like in the famous fibonacci sequence.

  In this overload's code i've also used the `in` alias of the `contains` overload we have done earlier,
  to make this easier, as well as a `continue` statement, instead of reversing that logic with a `notin` template.
"""
nbCode:
  proc `==`[K, V](a, b: FakeTable[K, V]): bool =
    result = true #until false

    if system.`==`(a.len, b.len): #Cannot use: if a.len == b.len: -> because of reasons of recursion
      for tupA in a:
        if tupA.key in b:
          continue
        else:
          result = false
    else: 
      result = false
nbText: """
  **And an example:**
"""
nbCode:
  var a = newFakeTable(char, int)
  var b = newFakeTable(char, int)
  var c = newFakeTable(char, int)

  a.incl ('a', 10); a.incl ('b', 20)
  b.incl ('a', 10); b.incl ('b', 20)

  c.incl ('a', 10); c.incl ('c', 30)

  echo a == b
  echo a == c

nbSubSection "`excl` proc overload"
nbText: """
  **Now let's overload the `excl` proc(for Sets/HashSets)**, in order to simplify removal of `KeyValue` tuples,
  based on the `key` provided. `del` is the proc for doing this for `Tables`.
"""
nbCode:
  proc excl[K, V](fakeTable: var FakeTable[K, V], k: K) =
    #Since excluding/removing an element of a container while iterating over it with a `for` loop is an error,
      #iterating over a copy, and using the copy's data to remove from the original will avoid that problem
    var temp = fakeTable

    for tup in temp:
      if tup.key == k:
        fakeTable.excl(tup)

nbText: """
  We have to use the `var` keyword in the overload's definition/head for our `FakeTable` in order to remove a `key`,
  from the supplied `FakeTable`. Without `var` you only copy the argument's data.

  **Example(using variables from above):**
"""
nbCode:
  echo a
  a.excl('a')
  echo a

nbSubSection "`missingOrExcl` proc overload"
nbText """
  **Now we will overload the `missingOrExcl` proc, that is available only to hashSets, NOT normal Sets.**
  `missingOrExcl` again, first excludes a `key` from a `HashSet`, and tells you if the `key` was already missing:
"""
nbCode:
  proc missingOrExcl[K, V](fakeTable: var FakeTable[K, V], k: K): bool =
    if k in fakeTable:
      fakeTable.excl(k)
      result = false
    else: result = true

nbText: """
  Quite simple with the `excl` and `contains` proc overloads. 
  Without them, it would of been quite longer and harder to understand.

  **Here is an example from the `sets` module's example for `missingOrExcl` for `HashSet`s:**
"""
nbCode:
  var s = newFakeTable(int, int)
  s.incl (2, 2); s.incl (3, 3); s.incl (6, 6); s.incl (7, 7);

  echo s.missingOrExcl(4) #should be: true
  echo s.missingOrExcl(6) #should be: false
  echo s.missingOrExcl(6) #should be: true

nbUoSection "Outro - Afterwords"
nbText: """
  Okay, that's it for this video, thanks for watching like, share and subscribe, 
    aswell as click the bell icon if you liked it and want more, 
    you can also follow me on twitter of the same name, and support me on Patreon. 
    If you had any problems with any part of the video, 
    let me know in the comment section, 
    the code of this video, script and documentation, are in the link in the description,
    as a form of offline tutorial.
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
- Compiler settings used: none, ORC is now the default memory management option
"""
nbUoSubSection "My and General Links"
nbText: """
- [Patreon](https://www.patreon.com/Kiloneie?fan_landing=true "Patreon")
- [Visual Studio Code Shortcuts](https://code.visualstudio.com/shortcuts/keyboard-shortcuts-windows.pdf "Visual Studio Code Shortcuts")
"""
nbUoSubSection "Links to this video's subject"
nbText: """
- [Sets(hashSets)](https://nim-lang.org/docs/sets.html "Sets(hashSets)")
- [Hashes](https://nim-lang.org/docs/hashes.html "Hashes")
- [Tables(hashTables)](https://nim-lang.org/docs/tables.html "Tables(hashTables)")
"""
nbSave()