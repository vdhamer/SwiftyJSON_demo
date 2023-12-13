![RocketSim_Screenshot_iPhone_SE_(3rd_generation)_2023-12-14_00 35 21](https://github.com/vdhamer/SwiftyJSON_demo/assets/13396568/abfdfe64-f706-40a2-ab37-e4357092c72a)

## Functionality and purpose
This is __Project 38__ from _Hacking with Swift_ by Paul Hudson.

Functionally, this demo app loads the 100 most recent commits from a Github repo via Github's API. It then 
merges these entries into a persistent on-device data store and displays the list of commits as a 
scrolling list (with basic Master/Detail functionality). 
The project was designed by Paul Hudson as a learning excercise only. 
So, because it is a technology demonstrator, both screens don't even have a title ;-)

## Technologies
Technically the app uses:
1. **SwiftyJSON** - used to parse the JSON data format and convert the data into a Swift-friendly format.
2. **CoreData** - an abstracted version of SQLite. Somewhat outdated because Swift will gradually migrate to SwiftData.
3. **UIKit** - Apple's original framework to build user interfaces. It is arguably outdated by the newer SwiftUI.
The Hacking with Swift lessons for Project 38 assume that you are reasonably proficient in Swift and are reasonably familiar with SwiftUI.

In my current personal project, I want to combine SwiftyJSON / CoreData / SwiftUI rather than SwiftyJSON / CoreData / UIKit.
But I already have the CoreData and SwiftUI working nicely together. 
So the use of UIKit isn't an issue for me personally: my SwiftUI code already displays a sectioned table with data persisted using CoreData.
So I only need to focus on filling the database using SwiftJSON.

## My code changes

There are minor changes compared to the original source code:
- it works without warnings on the current version of Swift/Xcode
- I did some renaming (Hacking with Swift sometimes uses short names for practical reasons)
- I installed SwiftLint 0.53 (with default settings) and fixed the warnings from SwiftLint 
- I installed SwiftJSON as a package rather than copying the Swift source file into the project. This keeps the package up to date.
- changes to logging to the console and error handling. I deliberately used `fatalError()` instead of `print()` here and there, as this is not meant to be prduction code.
- one of the filters now finds commits by Doug Gregor instead of Joe Groff. This increases the chance that the filter returns recent records. Joe Groff seems to have switched to other projects.
- added one line of code that allows the code to run on an iPad. It sets `ac.popoverPresentationController?.sourceItem` to anchor a popup.

The final code changes from the Hacking with Swift Project 38 are included in a separate repository. They add two advanced features that Paul Hudson described as "optional":
1. adding **Sections** to the UITableView (grouping commits per author). This impacts the CoreData and UIKit part of the code.
2. the interface CoreData > UITableView **reads records on demand** (lazy loading) rather than loading all records into memory up front.

The second modification shouldn't be relevant if you plan to use SwiftUI
because the `List` and `ForEach` views together automatically provide lazy loading.

### Acknowledgments

* Almost all the code is from [Project 38](https://www.hackingwithswift.com/read/38/) of Hacking with Swift.
* JSON parsing uses the [SwiftyJSON/SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON) package.
