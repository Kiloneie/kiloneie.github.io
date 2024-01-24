import nimibook

#Make this automatic with the proc, or a variant of the proc in the "index" file
  #Use the folder's name as argument1/name, arg2 is the filename in Nim's style guide .nim/.md(easy conversion between folder name and filename), arg3 is optional
var book = initBookWithToc:
  entry("Temporary front page", "index.nim", numbered = false)
  section("Nim for Beginners", "emptyNimForBeginners.nim"):
    entry("Object Variants Part 1", "Nim for Beginners/Object Variants Part 1/objectVariantsPart1.nim")
    entry("Object Variants Part 2", "Nim for Beginners/Object Variants Part 1/objectVariantsPart2.nim")
    entry("Sets", "Sets/sets.nim")
  section("Exploring Nim's Standard Library", "eNSL.md"):
    draft("placeholderENSL")
  section("Nim SDL2 Game Development for Beginners", "nSDL2GDfB.md"):
    draft("placeholderNSDL2GDFB")
  section("Metaprogramming in Nim", "mIN.md"):
    draft("placeholderMIN")
  section("Work in Progress", "workInProgress.md"):
    entry("Current WIP", "Work in Progress/scriptWSlides.nim")

nimibookCli(book)

#To do after edits of the above:
  #nim r filename/nbook init
  #nim r filename/nbook build
#This will generate a "book" folder containing all the files specified above as a nimibook instead of nimib/nimislides
  #as well as a "docs" folder that it requires and where .html files are generated into