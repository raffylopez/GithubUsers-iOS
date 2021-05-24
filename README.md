

# 🚀 tawk.to iOS Developer Test - Raf Lopez

## Submit your work

1. Make sure code is running on both - simulator and real device.

2. Push up to your repo. The repository should be publicly accessible - must not require any invitation to be accepted or registrations.

3. Reply back to the initial email the link to your repository.

4. Any 3rd party code that is being used has to be bundled with the code even if the
project is using any code dependency manager.

5. Please indicate which bonus tasks (see next section) have you completed.

## BONUS

- __[OK] Exponential backoff ​must be used ​​when trying to reload the data__
    
    _Exponential backoff used for reloading stale data when HTTP server failure occurs to avoid pommeling the backend. Transport errors are handled by periodic async connectivity timer_

- __[OK] Any data fetch should utilize ​Result types.​__

- __[OK] CoreData stack implementation must use ​two managed contexts​ - 1.​main context​ to be used for reading data and feeding into UI 2. write (​background) context​ - that is
used for writing data.__

   _Private background MOC for write queries, viewContext for read queries_

- __[OK] All CoreData ​write​ queries must be ​queued​ while allowing one concurrent query at__
any time.

   _Uses `performAndWait` with private MOC to synchronize on writing_

- __[OK] Coordinator and/or MVVM patterns are used.__

   _Utilizes MVVM_

- __[OK] Users list UI must be done in code and Profile - with Interface Builder.__
 
    _VFL and layout anchor constraints for home (code), storyboard for profile_

- __[OK] Items in users list are greyed out a bit for seen profiles (seen status being saved to db).__

- __[OK] The app has to support ​dark mode​__

- __[OK] Empty views such as list items (while data is still loading) should have Loading__ Shimmer aka ​Skeletons​ ~
[https://miro.medium.com/max/4000/0\*s7uxK77a0FY43NLe.png](https://miro.medium.com/max/4000/0*s7uxK77a0FY43NLe.png)​​resembling​ final
views​.

   _Partially implemented. Profile view uses shimmer_

## Raf's notes:

- Scroll to top implemented by tapping on navbar title icon
- Image color inversion routine may slow down list rendering (may need a refresh due to image caching
- Debug flags can be activated in AppConfig.plist

## Reference Specs (All tasks complete)

Your task is to make an app that can fetch GitHub users list and then display the selected user&#39;s profile.

PLEASE NOTE - All requirements in all the sections must be met
(except the BONUS section - that is optional, you can do all, some
or none of the BONUS tasks).

## General

 - In the first screen, the app has to fetch GitHub users list, parse it and display in the list
(using UITableView or UICollectionView).

-  Selecting a user has to fetch the user&#39;s profile data and open a profile view displaying
the user&#39;s profile data.

- The design must loosely follow the wireframe (at the bottom of this document) but you
must demonstrate a high level of knowledge about best practises of iOS UX and UI
principles (e.g. HIGs). The app must look good, work smoothly and the design must
follow platform defaults.


- Own code logic should be commented on.


## Generic Requirements

- Code must be done in Swift 5.1. using Xcode 12.x, target iOS13.

-  CoreData​ must be used for data persisting.

-  UI must be done with ​UIKit​using ​AutoLayout.

-  All ​network calls​ must be ​qkjhueued​ and ​limited​ to ​1​ request at a time.


- All ​media​ has to be ​cached​ on disk.

- For GitHub api requests, for image loading &amp; caching and for CoreData integration only Apple&#39;s apis are allowed (no 3rd party libraries).

- Use Codable to inflate models fetched from api.



- Write Unit tests using ​XCTest​ library for data processing logic &amp; models, CoreData
models (validate creation &amp; update).

   - If ​functional programming​ approach is used then only ​Combine​ is permitted
(instead of e.g. ReactiveSwift).

## GitHub users

 1. The app has to be able to work ​offline​ if data has been previously loaded.

- The app must handle ​_no internet_ ​scenario, show appropriate UI indicators.
3. The app must ​automatically​ retry loading data once the connection is available.
- When there is data available (saved in the database) from previous launches, that data should be displayed first, then (in parallel) new data should be fetched from the backend.

### Users list

- Github users list can be obtained from ​[https://api.github.com/users?since=0](https://api.github.com/users?since=0)​ in JSON format.
- The list must support pagination (​_scroll to load more_​) utilizing ​since p​arameter as the integer ID of the last User loaded.
- Page size_​ has to be dynamically determined after the first batch is loaded.
- The list has to display a spinner while loading data as the last list item.
- Every fourth avatar&#39;s colour should have its (image) colours inverted.

- List item view should have a note icon if there is note information saved for the given

user.

7. Users list has to be searchable - local search only; in ​_search mode,_​ there is no 
pagination; username and note (see Profile section) fields should be used when
searching; precise match as well as ​_contains_ ​should be used.

8. List(table/collectionview)mustbeimplementedusingatleast​3differentcells
(normal, note &amp; inverted) and ​Protocols - meaning that controller
(UITableViewControllerorUICollectionViewController)isunawareofspecificcellor
data(cellviews,models&amp;viewmodels)ithastoshowas long as those conform to
certain protocols. It must be able to display any data (other cells) that would be added
later without any modifications - e.g. adding cell with an indicator whether the user is
asiteadmin(&quot;​site\_admin&quot;)​.Example:​thetableviewonlyknowsthat
cell, it has to display, conforms to ​AnimalCell protocol​, data
modelconforms​AnimalDataModelprotocolanditcangetthe
celltoshowfromobjectconformingto​AnimalCellViewModel
protocol providing only itself (the tableView and the
indexPath).Thentheactualdatawouldconsistofallkinds
of animals Cats, Dogs, Parrots - all conforming to AnimalXXX
protocol.


### Profile

Profile info can be obtained from ​[https://api.github.com/users/[](https://api.github.com/users/%5Busername)[​](https://api.github.com/users/%5B%E2%80%8Busername%E2%80%8B%5D)[username](https://api.github.com/users/%5Busername)[​]](https://api.github.com/users/%5B%E2%80%8Busername%E2%80%8B%5D) in JSON
 format (e.g. ​[https://api.github.com/users/tawk](https://api.github.com/users/tawk)​).
- The view should have the user&#39;s avatar as a header view followed by information
fields (UIX is up to you).
- The section must have the possibility to retrieve and save back to the database the Note​ data (not available in GitHub api; local database only).
