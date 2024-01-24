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

import nimib, std/strutils #You can use nimib's custom styling or HTML & CSS
import nimislides
nbInit(theme = revealTheme) #for full screen slides
nb.useLatex() #This existing or not, makes 0 difference
nb.darkMode()

import ../requiredForEmbeddedSlides/embeddedReveal
initEmbeddedSlides()

#If we want nimiBook style of ToC on the left -> https://github.com/HugoGranstrom/nimiSlides/blob/main/nbook.nim and import nimibook

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
useScrollWheel()
showSlideNumber()

slide:
  addToc() #Not working with slides... make it work!

#Do NOT forget to have the .html file OPEN at all times, otherwise 
  #live preview will NOT work! ANY live preview!

###############
#START OF FILE#
###############

#Adding hlMd or hlMdf enables nimiboost's markdown highlight mode
#Cannot use """ """ multiline text, it gets a weird coloring of certain keywords and just appears in a box...
slide:
  slide:
    bigText: "hashSets, more on hashTables and hashing"
  slide:
    speakerNote "(What is the purpose of this video ?)"
    nbText: """In this video, we will go over hashSets and hashes that are used with hashSets, as well as hashing in general in the world. 
            We will also refresh our memory on Tables(hashTables), and add some more on that knowledge."""
  slide:
    nbText: "The code for this video and it's script/documentation styled with nimib, is in the link in the description as a form of offline tutorial."

slide:
  slide:
    nbSection "What is hashing ?"
  slide:
    fragment:
      nbText: "First of, we have already used a bit of hashing in my Tables video without even knowing it." 
    fragment:
      nbText: "The 'tables' module uses variants of an efficient hashTable(dictionaries in other programming languages)."
  slide: 
    nbText: "Hashing is the process of transforming any given key or string, into a usually another shorter and more efficient value, by the use of a one way mathematical hashing algorithm/function."
  slide: 
    nbTexT: "One way algorithms are used, because Hashes are also used for encrypting data, and a 2 way algorithm would fail that."
  slide:
    nbText: "The most popular use for hashing, is the usage of hash tables."
  slide:
    fragment:
      nbText: "A hash table stores key and value pairs, in a list that is accessible trough it's index."
    fragment:
      nbText: "Because key and value pairs are unlimited, the hash function will map the keys to the table size. A hash value then becomes the index for a specific element."
  slide:
    fragment:
      nbText: "Hashing is used in data indexing and retrieval, digital signatures, cybersecurity and cryptography."
    fragment:
      nbText: "They are also used on some websites, especially those dedicated to Linux OSs and programs," 
    fragment:
      nbText: "to check your checksum(Secure Hash Algorithm/SHA, Message-Digest functions/MD), against the one on their website," 
    fragment:
      nbTexT: "to ensure it is exactly the same, without any tampering by a malicious person."
   
  slide:
    fragment:
      nbText: "There are several modules in nim, for dealing with hash function algorithms:"
    fragment:
      nbText: "`nimble install checksum` before use, of the `Sha` and `MD5` modules"
    align("left"):
      orderedList:
        listItem():
          nbText: "Sha1(old, used for legacy purposes"
        listItem():
          nbTexT: "Sha2(newer, but still insufficient for data security)"
        listItem():
          nbText: "Sha3(newest, use this one)"
        listItem():
          nbText: "MD5"
        listItem():
          nbText: "Base64(for encoding and decoding data)"
    fragment:
      nbText: "The usage of hashing in data structure, is used for the reasons of speed."
    fragment:
      nbText: "It is much faster to find something if the value, is much smaller than the original in a large database"
    fragment:
      nbText: "There is a phenomenon called `collision`, which is when 2x or more hashes manage to generate an identical hash."
    fragment:
      nbText: "Different hash functions have different margin of collisions. To address this, there are methods like:"
    fragmentList(@["Double hashing",
                   "Linear probing",
                   "Quadratic probing",
                   "Separate chaining(making every hash table cell point to linked lists of records with identical hash function values)"], fadeIn)
  slide:
    nbText: """
    In cybersecurity, they can go a step further with the term Salting.
    Which is adding random data into the hash function. It helps with attackers from accessing non-unique passwords,
    by the use of rainbow tables(reverse engineered data)
    """

slide:
  nbSection "Hashing in Nim"
  nbText: hlMdF"""
  Hey Araq, what is the default hash function used with hash() procs ?"""
  fragment:
    nbText: """
      First of, hashSets are allocated on the heap."""
  fragment:
    nbText: """
      You can hash just about any data type in Nim. 
      There is no list of what you can, but mostly everything. """
  fragment:
    nbText: """
      You can easily hash your own data types, 
      but first you must use a bit of skeleton/boilerplate code to do so."""
  fragment:
    nbText: """
      The following 2 examples are taken from the hashes module page, 
      that are required for your own data types:"""
  slide:
    speakerNote "Show, don't tell"
    nbCodeSkip:
      import std/hashes

      type
        Something = object
          foo: int
          bar: string

      iterator items(x: Something): Hash =
        yield hash(x.foo)
        yield hash(x.bar)

      proc hash(x: Something): Hash =
        ## Computes a Hash from `x`.
        var h: Hash = 0
        # Iterate over parts of `x`.
        for xAtom in x:
          # Mix the atom with the partial hash.
          h = h !& xAtom
        # Finish the hash.
        result = !$h

  fragment:
    nbText: hlMdF"""
    If your custom types contain fields for which there already is a "hash" proc,
    you can simply hash together the hash values of the individual fields,
    no need for the overload of the "items" iterator:"""

    speakerNote: "Show, don't tell"
    nbCodeSkip:
      import std/hashes

      type
        Something2 = object
          foo: int
          bar: string

      proc hash(x: Something2): Hash =
        ## Computes a Hash from `x`.
        var h: Hash = 0
        h = h !& hash(x.foo)
        h = h !& hash(x.bar) # "!&" Mixes a hash value "h" with "val" to produce a new hash value(only for custom types)
        result = !$h # "!$" Finishes the computation of the hash value(only for custom types)

  fragment:
    nbText: hlMdF"""
    **Important:** Use -d:nimPreviewHashRef to enable hashing refs.
    It is expected that this behaviour becomes the new default in upcoming versions.

    **Note:** If the type has "==" operator, the following must hold:
    If two values compare equal, their hashes must also be equal.

    - Now let's continue by hashing some simple data types that normal Sets can't use,
    like strings, sequences and objects(don't forget to import the hashes module).
    """
  fragment:
    nbCode:
      import std/hashes

      let data = "Hello, World"
      let hashedData = data.hash

      echo data
      echo hashedData

  nbText: hlMdF"""
  As you can see, the hashed result is a random like number, which we could use with tables as a hashed key.

  Now let's how it looks like for sequences:
  (show, don't tell)
  """
  nbCode:
    let seqData = @[1, 3, 5, 7]
    let hashedSeqData = seqData.hash

    echo seqData
    echo hashedSeqData

  nbText: hlMd"""
  And now for objects:
  (show, don't tell)
  """
  nbCode:
    type
      Student = object
        name: string
        id: int

    let person = Student(name: "Kiloneie", id: 404)
    let hashedPerson = person.hash

    echo person
    echo hashedPerson

  nbText: hlMd"""
  Lots of quite long random looking, hashed values.

  Now let's try using a hashTable, hash the key, then reinsert to get the value.
  """

slide:
  nbSection: "Hashing keys with hashTables"
  nbText: hlMd"""
  Now we are going to play around with hashTables a bit,
  to have you understand what you can do with hashes,
  other than be more efficient values and enable hashSets to have just about any data type.

  But first, let me tell you about all the different variants of hash tables.
  Besides the normal hash tables i have shown in the Tables video(Table),
  there is also OrderedTable which remembers the element insertion order.
  Then there is the CountTable for mapping from a key to it's number of occurrences.

  And lastly, there a Ref/Reference versions of each, with "Ref" affixed/appended at the end like so:
    - TableRef
    - OrderedTableRef
    - CountTableRef

  In case it wasn't clear on when to use Tables(hashTables) in Nim, here are a few examples/use cases:
    - Whenever you have 2 pieces of data that you want linked together(e.g. your phone contacts -> name : number)
    - Games/music listing on your computer(name of the game/music as key : value as location)
    - When generating JSON(lightweight data-interchange format), before it gets stringified, it's represented as a Table(dictionary)
    - Nested Tables(example 2 below)

  Now let's make a new hashTable and hash one of it's keys and then reinsert it back:
  """
  nbCode:
    import tables

    var tData = {1.hash: "one", 2: "two"}.toTable
    echo tData

    echo tData[8641844181895329213]
    echo tData[2]
  nbText: hlMd"""
  Here we go, it worked perfectly.

  Example 2: You can nest hashTables to create accounts that have usernames and passwords linked together like this:
  """
  nbCode:
    var passwordIndex = {"Account 1" : {"Username" : "littleMouse", "Password" : "Ter3456fgdgh"}.toTable, 
                        "Account 2" : {"Username" : "bigDog", "Password" : "mashthatkeyboard"}.toTable}.toTable

    echo passwordIndex

  nbText: hlMd"""
  Obviously if you don't like the random order, you can make an ordered table instead.

  Now let's proceed to hashSets.
  """

slide:
  nbSection: "hashSets"
  nbText: hlMd"""
  Now let's make the simplest hashSet data type a normal Set cannot use, String.
  We cannot declare an empty hashSets, it can only be initialized.
  So this example is just for show, since every hashSet is always initialized
  in this same way by default anyways.
  We are going to need the "sets" module for all hashSets.
  """
  nbCode:
    import sets
    var emptyHashSet = initHashSet[string]()

    echo emptyHashSet

  nbText: hlMd"""
  Now the initialization version:
  (show, don't tell)
  """
  nbCode:
    var hashedString = ["Hello, World!"].toHashSet

    echo hashedString
  nbText: hlMd"""
  Now remember that the order of the elements is unordered, not the value of an element.

  Now let's have a look on how hashSets and hashTables look like in procs:
  """
  nbCode:
    proc paramHashSet(data: HashSet): HashSet = # data: initHashSet[string]() does NOT work
      data

    proc paramHashTable(data: Table): Table = #same for hashTables
      data

    proc initParamHashTable(data = {1: "one", 2: "two"}.toTable) =
      echo data #We have to use this "data", the compiler will not let us return it with the "result" variable, it must be used right here

    echo paramHashSet([3.14].toHashSet)
    echo paramHashTable({1: "one"}.toTable)
    initParamHashTable()

  nbText: hlMd"""
  There is an additional operation you can do with hashSets that you cannot do with normal Sets, which is symmetricDifference(s1, s2).
  symmetricDifference(s1, s2). "-+-" is the alias for that proc. This proc gives you only the elements that are not present in both sets at the same time.
  E.g. if setA['a', 'b'] -+- setB['b', 'c'] = ['a', 'c'] because 'a' is only in one of them, and the same goes for 'c'. 'b' is in both of them so it gets excluded from this list.
  """
  nbCode:
    let setSD1 = [("key1", 10), ("key2", 20)].toHashSet #Anonymous tuple - must be inside [], and tuples require (,) -> [()]
    let setSD2 = [("key2", 20), ("key3", 30)].toHashSet

    echo setSD1
    echo setSD2
    echo ""
    echo setSD1 -+- setSD2

  nbText: hlMd"""
  There is also disjoint(s1, s2: bool) returns true if the sets s1 and s2 have no items in common,
  """
  nbCode:
    let setD1 = [9223372036854775807, -9223372036854775807, 1, 2].toHashSet #9,223,372,036,854,775,807 or -/negative of that value is the max value of int64
    let setD2 = [2147483648, -2147483648, 1, 2].toHashSet #2,147,483,647 or -/negative of that value, is the max value of int32, had to add +1 and -1 at the end  to make them int64, otherwise disjoint won't work

    echo setD1
    echo setD2
    echo ""
    echo disjoint(setD1, setD2)
      
  nbText: hlMd"""
  missingOrExcl(s, key) Excludes a key and tells you if the key was already missing from "s". (no proc for missingOrIncl)
  """
  nbCode:
    var setMOE = [1, 2, 3, 4, 5].toOrderedSet #So we can see the content of the set easier

    echo setMOE

    if setMOE.missingOrExcl(1) == true:
      echo 1, " true"
    else: echo "false"

    if setMOE.missingOrExcl(1) == true:
      echo 1, " true"
    else: echo "false"

    echo setMOE

  nbText: hlMd"""
  containsOrIncl(s, key) Includes a key in the set "s" and tells if key was already in "s".
  Inverse of missingOrExcl(s, key)
  """
  nbCode:
    var setCOI = [1, 2, 3, 4, 5].toOrderedSet #So we can see the content of the set easier

    echo setCOI

    block COI:
      if setCOI.containsOrIncl(6) == true:
        echo "6 was already in setCOI"
      else:
        echo "6 is not is setCOI, adding"

      if setCOI.containsOrIncl(6) == true:
        echo "6 was already in setCOI"
      else:
        echo "6 is not is setCOI, adding"

  nbText: hlMd"""
  map(data, op) Returns a new set after applying "op" proc(anonymous proc) on each of the elements of "data"set.
  Here is a simple example from the Sets module that demonstrates the "map" proc very well:
  """
  nbCode:
    let #using "let" since we wont be changing it with "b"
      a = toHashSet([1, 2, 3])
      b = a.map(proc (x: int): string = $x)

    echo a
    echo b
    
  nbText: hlMd"""
  And here is my example at this proc:
  """
  nbCode:
    let setM = ["lowercase", "UPPERCASE", "l", "U"].toHashSet #using "let" since we wont be changing it

    let setNewL = setM.map(proc (elem: string): string = 
      for c in elem:
        if c.isLowerAscii == true:
          result = elem)

    let setNewU = setM.map(proc (elem: string): string = 
      for c in elem:
        if c.isLowerAscii != true:
          result = elem)
      
    echo setNewL
    echo setNewU

  nbText: hlMd"""
  Not sure why there is a third empty "" element in the new sets...
  """

  nbText: hlMd"""
  clear(s) Clears the hashSet back to an empty state, without shrinking any of the existing storage.

  QUESTION FOR ARAQ, DO READ THIS PLEASE:
  Araq, does this mean that the size is of type X's size + whatever the extra size of making it a hashSet is ?
  or does it mean that if we had 10x elements of type "string", the size will be default hashSet size + 10x string elements ?
  """
  nbCode:
    discard

  nbText: hlMd"""

  pop(s) Removes and returns an element from the set "s". Not sure what this is useful for,
    since it gives us no control. We can have some control with an ordered hashSet,
    but popping a specific element would take a long of computing time...
  """
  nbCode:
    var myHashSet = ["a", "b", "c"].toHashSet
    var orderedSet = ["a", "b", "c"].toOrderedSet

    echo myHashSet.pop #Doesn't let me specify what to pop... proc pop only has 1x argument
    echo myHashSet.pop
    echo myHashSet.pop

    if myHashSet.len != 0:
      echo myHashSet.pop
    else:
      echo "myHashSet is empty"

  nbText: hlMd"""
  There is a use case for the "pop" proc. For example if you have a pool of jobs to be done in no particular order.
  Let's say that on weekends you clean your room, do your laundry, change the sheets, etc. That job only requires to be done once.
  So you would use a doTheJob()/processJob() proc that woould "pop" a job from your pool of jobs and execute it.
  Once all the jobs are done, you can put the exact same ones back in when weekend comes, or some relatives are coming to visit.
  Here is an example:
  """
  nbCode:
    proc executeJob(job: string) =
      echo job, " finished"

    var jobs = ["laundry", "sh8eets", "cleaning"].toHashSet

    while jobs.len != 0:
      let job = jobs.pop
      job.executeJob

  nbText: hlMd"""
  And lastly "[]" - Which returns the element that is actually stored in "s" which has the same value as "key" or raises the "KeyError" exception.
  This is useful when one overloaded the "hash" proc and the "==" operator, but still needs reference semantics for sharing.
  """
  nbCode:
    var setWithAKey = ["one", "two", "tree"].toHashSet
    echo setWithAKey["one"], " ", setWithAKey["one"].type

slide:
  nbSection: "hashSet use cases"
  nbText: hlMd"""
  One of the hashSet uses cases is very similar to the last use case example of the previous video of normal Sets.
  The example being, splitting a string based on character elements as separators.
  With hashSets, we can go a step further. We can use whole words as separators.
  So let's use the split() proc we made in the last tutorial and update it for string hashSets.
  We are also going to add another argument of type bool, to tell the proc if we are working with set[char],
  or hashSet[string]. Currently the compiler cannot infer which to use, 
  since the second argument of "seps" is not an argument we can give, since it is already initialized.
  """

  nbText: hlMd"""
  Original version:
  """
  nbCode: #Original version
    import strutils

    proc split(s: string; seps: set[char] =  {' ', '!', '?'}): string = 
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
  Modified version:
  """
  nbCode: #Modified version for string hashSets
    import strutils

    proc split(s: string; useNormalSet: bool): string = 
      if useNormalSet == true:
        var seps: set[char] =  {' ', '!', '?'}
        var splitString = s
        var c: int

        for sep in seps:
          c = splitString.find(sep)
          splitString.delete(c, c) 
          
        result = splitString
      else:
        discard
        var seps = ["var", "let", "const"].toHashSet
        var splitString = s
        var c: int

        for sep in seps:
          c = splitString.find(sep)

          if (c + sep.len) < splitString.len:
            splitString.delete(c, c+sep.len)
      
        result = splitString
            
    echo myString.split(true)
    echo "I have a var, a const, and a let me in pony".split(false) #43 length

slide:
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
  - Version used: E.G. 2.0.2
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