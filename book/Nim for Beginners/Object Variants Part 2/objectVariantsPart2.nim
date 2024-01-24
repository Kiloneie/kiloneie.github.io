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
Nim for Beginners: Object Variants Part 2
"""

nbText: hlMdf"""
## INTRO - FOREWORDS
(What is the purpose of this video ?) <br>

In this video i will teach you about object variants, what they are and how to use them,
as well as compare them against objects with inheritance.

The code for this video and it's script/documentation styled with nimib,
is in the links in the description as a form of offline tutorial.

"""

nbSection "Object Variants vs Inheritance"
nbText: hlMdf"""
Object variants are always stored in memory in it's full size.
Now this allows object variants, variants of an object to be stored in containers such as sequences.
This also allows changing variants into other variants, which is NOT possible with inheritance. 
"""

nbSection "Inheritance"
nbText: hlMdf"""
First of, we will "import random" for later use.
Then under a "type" section, we will make the parent of inheritance called EnemyI,
"I" affix for inheritance so we will be able to distinguish between inheritance code,
and object variance code later on. We will give this object "x" and "y" fields of type float,
as well as "parent" field of type "EnemyI". This will make it so that any child of
the parent "EnemyI" will be able to have a parent, and then when the parent object
is added into a collection like a sequence along with it's child objects,
Nim will be able to determine which overloaded "method" statement to use at runtime,
when the program is running. More on that later.

Finally we will create the children "BanditI" and "WolfI" with "attackMoves"
as it's fields of type sequence of the appropriate enumerator.
<br><br>
So let's begin:

"""

nbCode:
  import random

  type
    EnemyI = ref object of RootObj
      x, y: float
      parent: EnemyI #For dynamic dispatch of methods

    HumanoidAttackMovesI = enum
      backstabI, eviscerateI

    AnimalAttackMovesI = enum
      biteI, clawI

    BanditI = ref object of EnemyI 
      attackMoves: seq[HumanoidAttackMovesI]

    WolfI = ref object of EnemyI
      attackMoves: seq[AnimalAttackMovesI]

nbText: hlMdf"""
Now here we are going to use "methods" over procs, because methods enable dynamic dispatch,
selecting the appropriate function(proc, method etc), at runtime, when the program is running,
instead of doing it at compile time with <b>procs</b>, when writting our code
- Methods require objects as parameters<br>
- Base methods should be BASE and as minimal as possible, in other words
  the method using base pragma that targets the parent should be as minimal as possible<br>
- Base pragma is implicitly placed, but YOU should place it manually just in case<br>
- Pragmas in Nim are similar to the C programming language's pre-processor parameters,
  they are used to change the behaviour of code to a different one. 
  There are many pragmas in Nim.
"""

nbText: hlMdf"""
When writting methods, procs, templates, etc, that only have a short bit of code,
we can write the code of that proc, method, etc, in the same line.
Now let's continue with methods with that in mind.<br>

First let's write methods as constructors for our "parent" of EnemyI, BanditI and WolfI.
These constructors will be essentially useless because again, methods require objects
as parameters, so we can't give them the parameters we want to make creation of these
objects via constructors easier, object variants will be able to do that:
"""

nbCode:
  method newEnemyI(b: EnemyI): EnemyI {.base.} = b
  method newEnemyI(b: BanditI): BanditI {.base.} = b
  method newEnemyI(b: WolfI): WolfI {.base.} = b

nbText: hlMdf"""
Now we are going to make 3 methods for a hypothetical attack for all 3 objects.
First of AGAIN as i said above, the parent object, EnemyI requires it's attack method,
to be as barebones/simple as possible, because it's function in this code will be to
simply be a parent, it's child objects will have more functionality: 
"""

nbCode:
  method attackI(this: EnemyI): string {.base.} = "..."

  method attackI(this: BanditI): string =
    randomize() #Unless you use randomize, every program run will result in the same random numbers
    let max = this.attackMoves.high
    result = $this.attackMoves[rand(0..max)] #0..max -> so we don't make an illegal storage access

nbText: hlMdf"""
Now we are going to copy paste the bandit's attackI method and simply change it's
parameter of BanditI to WolfI. By naming a proc/method and more, with the same name
we overload that method/proc. Overloading means that the compiler will determine which
of the same named overloaded procs/methods is to be used
"""

nbCode:
  method attackI(this: WolfI): string =
    randomize()
    let max = this.attackMoves.high
    result = $this.attackMoves[rand(0..max)]

nbText: hlMdf"""
Now we will make a variable that will use the parent object of EnemyI,
a sequence to store 100 of randomly picked and stored BanditI and WolfI objects,
as well as the parent object, and the display that sequence
"""

nbCode:
  var overlordI = EnemyI() #Parent object
  var enemiesI: seq[EnemyI]

  for e in 0..99:
    let x = rand(0..1)

    if x == 0:
      enemiesI.add newEnemyI(BanditI(x: e.toFloat, y: e.toFloat, attackMoves: @[backstabI], parent: overlordI))
    if x == 1:
      enemiesI.add newEnemyI(WolfI(x: e.toFloat, y: e.toFloat, attackMoves: @[biteI], parent: overlordI))

nbText: hlMdf"""
Earlier we made a variable to use the parent object of EnemyI, now we are going to store
it into our sequence in order to satisfy/meet the requirements of dynamic dispatch
"""

nbCode:
  enemiesI.add overlordI #Used simply to meet the requirements of methods, otherwise we could use procs instead

  for e in enemiesI:
    echo e.attackI

  #Now let's run this. Okay it works, end of this section(nimib restriction)

nbSection "Object Variants"
nbText: hlMdf"""
Now we are going to write the above code with <b>inheritance</b> and <b>methods</b>,
into a version that uses Object Variants and procs instead. We are going to mostly
copy paste what we wrote before, but without the inheritance part like 
"ref object of RootObj" and change the affix of "I" when naming things into a "V"
for object variants, and NOT put the parent object into the sequence,
because it will not work, it will crash.<br>

First of we are going to use the "type" section to make an enumerator named Enemies,
with "bandit" and "wolf" for it's enumerations just like we did for the attack moves
for the bandit and the wolf objects of inheritance above.
Also copy paste the enumerators for HumanoidAttackMoves and AnimalAttackMoves,
but with "V" for it's affix:
"""

nbCode:
  type
    Enemies = enum
      bandit, wolf

    HumanoidAttackMovesV = enum
      backstabV, eviscerateV

    AnimalAttackMovesV = enum
      biteV, clawV

nbText: hlMdf"""
Now we will create our "EnemyV" object which will have 2 variants of itself,
instead of 2 children. To do this all we have to do is use our "Enemies" enumerator,
as a discriminator/selector in a case statement and then using different names
for the fields of the bandit and wolf attack moves. We must use unique field names,
because to Nim this code is still under the same object: EnemyV

(another "type" section is used here because of the "nimib" module restrictions,
which i am using to write the script/documentation of this video, and onwards from now on)

"""
nbCode:
  type
    EnemyV = object
      x, y: float

      case kind: Enemies
        of bandit:
          attackMovesB: seq[HumanoidAttackMovesV]
        of wolf:
          attackMovesW: seq[AnimalAttackMovesV]

nbText: hlMdf"""
Now let's create our constructors which unlike the ones we made and used for inheritance,
will actually make the construction of our objects a bit easier. We can give them 
the parameters they require, so we will give them x, y and attack moves parameters,
and return a completed object with the "result" variable filled with our parameters
like this:
"""

nbCode:
  proc newEnemyV(x, y: float, aMoves: seq[HumanoidAttackMovesV]): EnemyV =
    result = EnemyV(x: x, y: y, kind: bandit, attackMovesB: aMoves)

  proc newEnemyV(x, y: float, aMoves: seq[AnimalAttackMovesV]): EnemyV =
    result = EnemyV(x: x, y: y, kind: wolf, attackMovesW: aMoves)

nbText: hlMdf"""
Now we need to to make a proc that does what the 2 attack methods did for inheritance.
So instead of using 2 methods, with object variants we can simply use a "case" statement
instead. So let's copy paste the 2 methods and put them together into a single proc,
by using a "case" statement like this:
"""

nbCode:
  proc attackV(this: EnemyV): string =
    case this.kind:
      of bandit:
        randomize()
        let max = this.attackMovesB.high
        result = $this.attackMovesB[rand(0..max)]
      of wolf:
        randomize()
        let max = this.attackMovesW.high
        result = $this.attackMovesW[rand(0..max)]

nbText: hlMdf"""
Now we make the sequence, fill it and display it like before, except that
we won't be adding the base object variant, EnemyV object without a kind field specified,
because it will crash our program, you can't mix the base object with it's variants.
"""

nbCode:
  var enemiesV: seq[EnemyV]

  for e in 0..99:
    let x = rand(0..1)

    if x == 0:
      enemiesV.add newEnemyV(e.toFloat, e.toFloat, @[backstabV])
    if x == 1:
      enemiesV.add newEnemyV(e.toFloat, e.toFloat, @[biteV])

  var overlordV = EnemyV()
  #[ enemiesV.add overlordV ]# #This will crash, overlord.attackV ...

  for e in enemiesV:
    echo e.attackV

nbSection "Child A to Child B conversion"
nbText: hlMdf"""
Both object variants and inheritance allow for variant to base and child to parent,
and vice versa conversion, but only <b>object variants</b> allow for variant to variant
conversion. Inheritance does not allow this.

<b>Variant to variant conversion</b><br>
I will demonstrate this with a simpler than above example like this:

"""

nbCode:
  type
    VariantEnemies = enum
      outlaw, spider

    VariantEnemy = object
      x, y: float

      case kind: VariantEnemies
        of outlaw:
          stealth: bool
        of spider:
          poisonous: bool

  var o = VariantEnemy(kind: outlaw)
  var s = VariantEnemy(kind: spider)

  o = s #Variant to variant conversion
  echo s

  #Variant to base conversion
  var b = VariantEnemy()
  echo b

  b = s
  echo o 

nbText: hlMdf"""
As you can see the output of the base object is a variant of kind "outlaw", that is
because the default value of "kind" is 0, and 0 is also the integer value of "outlaw"
enumeration. So conversion between variants and the base object with no kind,
works perfectly.  
"""

nbText: hlMdf"""

<b>Child to child conversion</b><br>

"""

nbCode:
  type
    ChildEnemy = ref object of RootObj
      x, y: float

    Outlaw = ref object of ChildEnemy
      stealth: bool

    Spider = ref object of ChildEnemy
      poisonous: bool

  var oI = Outlaw()
  var oI2: ChildEnemy = Outlaw(stealth: true)
  var sI = Spider() #Must include :ParentName for child to parent and reverse, conversion

nbText: hlMdf"""
Now that we got our definitions and variables set, i will demonstrate that
well child to child conversion for normal objects and inheritance is possible,
but only on a quick glance. The conversion is only possible if a variable is first
defined as the parent and then given the values of one of it's child objects,
like "oI2". All this does is, fill the values of the object's fields and nothing more.
So let's echo both our outlaw variables to see their details:
"""

nbCode:
  echo oI[], " ", oI.type
  echo oI2[], " ", oI2.type

nbText: hlMdf"""
As you can see "oI" is of type "outlaw", but "oI2" is of type ChildEnemy.
Again, like i said this is no a real conversion, it just fills the fields that are
compatible, both have.

Now let's try converting "oI2" to type Spider()
"""

nbCode:
  oI2 = Spider(oI2)
  echo oI2[], " ", oI2.type

nbText: hlMdf"""
Make sure you are using compiler setting of --gc:orc in the config.nims file,
otherwise with the currently default refc garbage collector soon to be replaced with gc:orc,
you will get an object conversion error.

Now let's run this:<br>
As you can see nothing happened, outlaw2(oI2(inheritance)) is still of type ChildEnemy,
because child to child conversion is not possible.
Only child to parent and parent to child conversion is possible.

Now lastly let's try the child to parent conversion
"""

nbCode:
  oI2 = ChildEnemy(oI2) #Only child to parent and back is actually possible
  echo oI2[], " ", oI2.type

nbText: hlMdf"""
As i said earlier in this section, since we made "oI2" as ChildEnemy first,
and given it it's empty value of Outlaw(), it remained of type ChildEnemy.
No real/actual conversion for inheritance is possible.
Even the compiler will tell you that(try it).

There is a way to do this though, by using "casts", but that is the subject of another
video, casts in super short version are basically a "view" into another data type,
they are also considered unsafe, meaning you could easily cause problems with incorrect
usage.
"""


nbText: hlMdf"""

<b>Storing into containers</b><br>
As i have shown earlier, object variants have a problem with storing it's "base",
object along with it's variants into containers such as sequences, but inheritance
does not have that problem. Though i do not see a reason why one would need to do this.

"""

nbSection "Performance comparison"
nbText: hlMdf"""
Object variants are faster:
Inheritance works best with refs(and ptr), at this point inheritance should be very fast,
probably even faster than object variants, but then you are required to use methods.
Methods are dynamic dispatch and it is slow,
therefore with a complex Parent - Child hierarchy, you will have many methods,
and with many method calls, it will be much slower than object variants with procs.

Here in the following link are the results of a performance profiler program called
<b>valgrind:</b> that i used to get performance results from the earlier object variants
vs inheritance code.<br><br> 
<b>Performance comparison:</b> [Valgrind](https://postimg.cc/rRz2dHFf "Callgrind results on the left and cachegrind results on the right") 
<br>
(i forgot to remove the screenshoting program from the screenshot)


"""

nbSection "When to use Object Variants vs Inheritance?"
nbText: hlMdf"""
Use methods if you want unbounded polymorphism, 
(can add new logic/functionality without having to go update a master list of things, 
useful if you're expecting to be adding new things all the time, 
or if you're making a library and want users to be able to make their own kinds)
otherwise use object variants.

Procs use static dispatch, compiler will match a proc to the FIRST matching object call. 
With inheritance if the first appropriate match is the parent, 
all of it's children's calls will be ignored, the parent's call will be used instead.

Dynamic dispatch is achieved with methods, the matching will be done at run-time, 
allowing more flexibility at the cost of performance. Methods will not stop at the 
parent of inheritance, but find the most appropriate matching child.

"""

nbSection "Extra Information"
nbText: hlMdf"""

<b>Explanation of base pragma:</b><br> 
Base is like virtual in C++. 
It marks that a method can be overloaded in subclasses and dynamically dispatched.
First, dynamic dispatching pretty much requires ref, 
because it requires a situation where the runtime type of the object isn't known at compile time.
The pragma seems to be inserted implicitly.

Base pragma was required back when Nim had multi methods. 
Now it's still useful, C# uses an explicit "override" keyword to override methods, 
override in Nim is the default, but the downside is that "base" methods have to be annotated.

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