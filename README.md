# rebekka
Rebekka - an FTP/FTPS client in Swift. Utilizes `CFFTPStream` API from `CFNetworking`.

###Implemented FTP commands

+ Directory content listing.
+ Directory creation.
+ File upload/download.

###Installation

#####As Embedded framework (iOS 8.0+)

1. Add Rebekka as a submodule.
	`git submodule add git@github.com:Constantine-Fry/rebekka.git`
2. Drag-and-drop `Rebekka.xcodeproj` into your project. The project has two targets: Rebekka.framework for OSX project, RebekkaTouch.framework for iOS projects. 
3. Add new target in "Build Phases" -> "Target Dependencies".
4. Click the `+` button at the top left of the panel and choose "New copy files phase".
  * Rename the new phase to "Copy Frameworks".
  * Set the "Destination" to "Frameworks".
5. Add Rebekka framework to this phase.

To support iOS 7.0, you can add source code files directly into your project .

###Usage

```swift
var configuration = SessionConfiguration()
configuration.host = "ftp://ftp.mozilla.org:21"
configuration.encoding = NSUTF8StringEncoding
_session = Session(configuration: configuration)
_session.list("/") {
    (resources, error) -> Void in
    println("List directory with result:\n\(resources), error: \(error)\n\n")
}
```

```swift
var configuration = SessionConfiguration()
configuration.host = "127.0.0.1"
_session = Session(configuration: configuration)
_session.download("/Users/foo/testdownload.png") {
   (fileURL, error) -> Void in
   println("Download file with result:\n\(fileURL), error: \(error)\n\n")
}
```

```swift
var configuration = SessionConfiguration()
configuration.host = "localhost:21"
configuration.username = "optimus"
configuration.password = "rollout"
if let URL = NSBundle.mainBundle().URLForResource("testUpload", withExtension: "png") {
   let path = "/Users/foo/bar/testUpload.png"
   _session.upload(URL, path: path) {
       (result, error) -> Void in
       println("Upload file with result:\n\(result), error: \(error)\n\n")
  }
}
```

###Requirements

Swift 2.0 / iOS 8.0+ / Mac OS X 10.9+

###License

The BSD 2-Clause License. See License.txt for details.

===========
Bonn, December 2015.
