This is Project 38 from Hacking with Swift by Paul Hudson.

Functionally, this demo app loads the 100 most recent commits from a Github repo via a Github API, 
merges these into a persistent on-device data store and displays this to the user as a scrolling list (with Master/Detail functionality).
But the project was designed by Paul Hudson as a learning excercise in a mix of the following technologies:
1. SwiftyJSON - used to parse the JSON data format and convert the data into a Swift-friendly format.
2. CoreData - an abstracted version of SQLite. Somewhat outdated because Swift will gradually migrate to SwiftData.
3. UIKit - the older framework to build the user interface. Somewhat outdatd because Swift projects are migrating to SwiftUI.
The actual stepwise tutorial for Project 38 assumes that you are already proficient in Swift and are reasonably familiar with SwiftUI.

In my current personal project, I want to combine SwiftyJSON / CoreData / SwiftUI. But I already have the CoreData and SwiftUI working together. So the use of SwiftUI shouldn't be an issue for me.

There are minor changes compared to the original source code:
- made sure it works without warnings on the current version of Swift/Xcode
- some renaming (Hacking with Swift sometimes uses short names for practical reasons)
- fixing the warnings generated by SwiftLint 0.53 (mainly line length, even in template code generated by Xcode) 
- installed SwiftJSON as a package, thereby using the latest version of that code
- changes to logging to the console and error handling. I deliberately used `fatalError()` instead of `print()` here and there, as this is not meant to be prduction code.

The final set of changes in the stepwise tutorial for Project 38 are _not_ included here.
I will put them in a separate repo. They add two features that Paul Hudson described as "optional":
1. add Sections to the UITableView, with one section per author. This impacts the CoreData and UIKit part of the code.
2. the interface CoreData > UITableView reads records on demand (lazy loading) rather than buffering all records in memory 
The second modification shouldn't be relevant if you plan to use SwiftUI
because the `List` and `ForEach` views together automatically provide lazy loading.
