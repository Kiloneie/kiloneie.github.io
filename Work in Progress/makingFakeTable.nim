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
- TITLE: Creating a fake Table using hashSets and Generics(overloading in depth)
- ALT TITLE: More on hashSets and overloading in depth

## Brainstorming/To do
Here go all thoughts on what the video will be like and how it will be made etc,
before being organized below.

    Chapters/sub topics of this video will be:
      Creating a fake Table using hashSets
        Generics
          Generic Procs
          Generic Tuples
          Generic Objects
        Overloading with Generics
        Fake Table, but better ?
      Tuple Unpacking

## INTRO - FOREWORDS
<b>(What is the purpose of this video ?)</b>
- In this video we will create a fakeTable using hashSets,
  which will function like a hashTable, but with all of the great Set operations.
  We won't go trough all of the operations a hashSet can have,
  but we will make all of the ones normal Sets can use work.
  Also `tuple unpacking`.
   
The code for this video and it's script/documentation styled with nimib,
is in the link in the description as a form of written tutorial.
"""

nbSection "Creating a fake Table using hashSets"
nbText: """
  In order to create this fakeTable using hashSets,
    we will have to use `tuples`.
    Tuples, because they are a 2x field data structure just like Tables are.
    We will also have to use `generics` to overload existing procs and operators that Sets use, 
    in order for the (key, value) tuples, to be able to be of any Nim's data type, 
    without having to overload an insane number of times.
"""
  
nbSection "Generics"
nbText: """
  Generics in Nim, are used to parametrize procs, iterators or types with type parameters.
  `[]` are used along with capital letters inside of them, separated by commas,
  after a type's name, proc or iterator to tell the compiler that this will be a `generic`:
"""
nbCodeSkip:
  type
    GenericObject[T] = object
      ndata: string

  proc genericProc[T]() =
    discard
  
  iterator genericIterator[T]() =
    discard
nbText """
  The above examples are incomplete, they will not work just yet.
  Again, using `[]` with a capital letter inside will just "mark" the `type, proc, iterator` as a generic.
  Now we require to use that `T`(can be any capital letter) in the arguments of the `proc`, `iterator`,
  and on the fields of a `type` like so:
"""
nbCode:
  type
    GenericObject[T] = object
      data: T

  type
    GenericTuple[A, B] = tuple
      name: A
      age: B

  proc genericProc[T](anyType: T) =
    discard
  
  iterator genericIterator[T](anyType: T): T =
    discard
nbText: """
  **And also for generic containers example:**
"""
nbCode:
  proc genericContainerProc[T](anyTypeContainer: seq[T]) =
    discard
nbText: """
  Now let's see how to use this `generic object`

  **Generic Object:**
"""
nbCode:
  var genericObject = GenericObject[string](data: "A String")
  var genericObject2 = GenericObject[int](data: 101)

  echo genericObject, " of type ", genericObject.typeof
  echo genericObject2, " of type ", genericObject2.typeof

nbText: """
  **Generic Tuple**
"""
nbCode:
  var genericTuple: GenericTuple[string, int] = ("Bob", 20)
  var genericTuple2: GenericTuple[seq[float], bool] = (@[0.5, 1.1, 3.25], true)

  echo genericTuple, " of type ", genericTuple.typeof
  echo genericTuple2, " of type ", genericTuple2.typeof

nbText: """
  One example for generic `iterators` and lots for generic `procs` will be shown making this `fakeTable`.
  Calling generic procs and iterators is exactly the same as non generic versions,
  unlike structures like `objects` and `tuples`(shown above).
"""

nbSection "Fake Table, but better ?"
nbText: """
  First of, we need to define our FakeTable and then overload the `hash` proc,
  and make a custom `iterator` that uses that overloaded `hash` proc,
  just like in the previous video of `hashSets, more on hash Tables and Hashing`,
  but with generics.

  **First the definition of our tuple to serve as our (key, value),
  and then the `FakeTable`, which is also easier to read and write than,
  `HashSet[KeyValue[K, V]]`**
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

  **Now the `hash` proc overload which is almost exactly the same as in the previous video,
  except for the generic part and the "runnableExamples":**
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

  **Now the custom `iterator elements` for this `hash` proc overload:**
"""
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

  **Here is the `hash` proc version without the custom iterator,
  which does not take our `FakeTable` type, because that would mean it would require an iterator:**
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
  **As you can see, initializing our fakeTable is much simpler than the original of:**
"""
nbCodeSkip:
  var keyValue = initHashSet[KeyValue[string, int]]()

nbText: """
  **Making a `OrderedSet` version of our constructor proc:**
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
  and we can't do that with the `FakeTables` we supplied to the 2x arguments of `a` and `b`˙,
  because you can't modify arguments received.
  We also can't use `var` before `FakeTable` as in `a: var FakeTable`,
  because we would be modifying the original `FakeTable`s, which we don't want to do.

  So the second part marked with the #De-duplication comment,
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
  And here is the code for the above manual explanation:
"""
nbCode:
  var ftA = newFakeTable(char, int)
  var ftB = newFakeTable(char, int)

  ftA.incl ('a', 10)
  ftA.incl ('b', 20)
  ftA.incl ('c', 30)

  ftB.incl ('c', 30)
  ftB.incl ('d', 40)
  ftB.incl ('e', 50)

  echo "ftA: ", ftA
  echo "ftB: ", ftB

  echo "ftA - ftB = ", ftA - ftB
nbTexT: """
  And the reverse:
"""
nbCode:
  echo "ftB - ftA = ", ftB - ftA

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
  Example:
"""
nbCode:
  echo ftA * ftB

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
  Here is an example:
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

  This isn't true for the `<=` operator(proc), which does the exact same as `<`,
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
  And an example:
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
nbText: """
  Here i have also used `;` which is optional in Nim,
  and allows for multiple operations to be used on a single line.
  I think it's quite useful for such small operations that work the same,
  to be put on a single line, instead of heavily spreading vertically.
  I don't recommend using the optional semicolon `;` for large operations,
  or different ones, most people don't like that,
  and it will hurt clarity and readability. But again, for same operations of such small scale, yes.

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

  Example(using variables from above):
"""
nbCode:
  echo a
  a.excl('a')
  echo a

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

#These sections are more of ideas or a guideline, they will probably change(update the above brainstorming when they do)
#missingOrExcl() is the last overload to do
nbSection "Tuple Unpacking"
nbText """
  Since we have been dealing with `tuples` quite a lot in this video,
  it's time to explain and demonstrate `tuple unpacking`, which i did not show in the `Tuples video`,
  nor did it find any use in this one.

  Tuple unpacking is quite simple.

  You can use them to give values to multiple variables(`var`), constants(`const`) or immutable variable(`let`),
  at once. Like this:
"""
nbCode:
  let (v1, c1, l1) = ("var", "const", "let")

  echo v1
  echo c1
  echo l1
nbText: """
  You may also ommit assignment of any of them:
"""
nbCode:
  let (v2, _, l2) = ("var", "const", "let")

  let (_, _, _) = ("var", "const", "let")
nbText: """
  Not sure why anyone would ommit all of them... but you can!

  All of this is treated as syntatic sugar for basically the following code(look at the first example):
"""
nbCode:
  let
    temporaryTuple = ("var", "const", "let")
    v3 = temporaryTuple[0]
    c3 = temporaryTuple[1]
    l3 = temporaryTuple[2]
nbText: """
  I don't think i have ever shown this before, but yes, you can access any field of a `tuple`,
  without knowing the name of the field, especially useful for `anonymous` tuples like here(fields without names).
  I do recommend though, that you do use the `names` of the fields over the `index` when the `names` are present.

  (When tuple unpacking with tuples with numbers(literals) into `var` and `let` variables,
  they get assigned their values without a `temporaryTuple`)

  Since you can nest any container withing another container(array, seq, set, table, etc), 
  as well as data structure in a data structure(object, tuple),
  you can also use nested tuples for tuple unpacking, like this:
"""
nbCode:
  proc returnsNestedTuple(): (int, (int, int), int, int) = (4, (5, 7), 2, 3)

  let (x, (_, y), _, z) = returnsNestedTuple()

nbText: """
  I have NO ideas of a good example of tuple unpacking... in this entire endeavour of making a FakeTable,
  i had no use for it.

  This script is complete from our standpoint, time to send for review,
  and find what to do next.
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
- Version used: E.G. 2.0.2
- Compiler settings used: none, ORC is now the default memory management option
- Timestamps:
  - 00:15 Start of video example
  
"""
nbText: hlMdF"""

<b>LINKS:</b>
- [Twitter](https://twitter.com/Kiloneie "My Twitter")
- [Patreon](https://www.patreon.com/Kiloneie?fan_landing=true "Patreon")
- [Visual Studio Code Shortcuts](https://code.visualstudio.com/shortcuts/keyboard-shortcuts-windows.pdf "Visual Studio Code Shortcuts")

<b>LINKS to this video's subject:</b>
- [typedesc](https://nim-lang.org/docs/manual.html#special-types-typedesc-t "typedesc")
- [E.G.2. SDL2 documentation(in case SDL2_nim documentation missed something)](https://wiki.libsdl.org/APIByCategory "Example link to an example video's subject")

"""

nbSave()