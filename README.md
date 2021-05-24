### Raf's Solution to the tawk.to iOS Developer Test

- TODO: Fill in details here


![](RackMultipart20210524-4-1m5phmq_html_ff719d467ce93573.png) ![](RackMultipart20210524-4-1m5phmq_html_2bd7a01bf5138263.gif) ![](RackMultipart20210524-4-1m5phmq_html_2bd7a01bf5138263.gif) ![](RackMultipart20210524-4-1m5phmq_html_d1fcd01371e613c0.gif)

![](RackMultipart20210524-4-1m5phmq_html_7c3a4076d6da220c.png)

![](RackMultipart20210524-4-1m5phmq_html_bf3231188c8fa419.png)

# tawk.to iOS Developer Test

Your task is to make an app that can fetch GitHub users list and then display the selected user&#39;s profile.

![](RackMultipart20210524-4-1m5phmq_html_1b65ac1e03ccdcb8.gif)​PLEASE NOTE​​ - ​All requirements in all the sections must be met
(except the BONUS section - that is optional, you can do all, some
or none of the BONUS tasks).

## General

- In the first screen, the app has to fetch GitHub users list, parse it and display in the list
(using UITableView or UICollectionView).
- 2. Selecting a user has to fetch the user&#39;s profile data and open a profile view displaying
the user&#39;s profile data.
- 3. The design must loosely follow the wireframe (at the bottom of this document) but you
must demonstrate a high level of knowledge about best practises of iOS UX and UI
principles (e.g. HIGs). The app must look good, work smoothly and the design must
follow platform defaults.

4. Own code logic should be commented on.

## Generic Requirements

- 1. Code must be done in Swift 5.1. using Xcode 12.x, target iOS13.
- 2. CoreData​ must be used for data persisting.
- 3. UI must be done with ​UIKit​using ​AutoLayout.
- 4. All ​network calls​ must be ​qkjhueued​ and ​limited​ to ​1​ request at a time.

- 5. All ​media​ has to be ​cached​ on disk.
- 6. For GitHub api requests, for image loading &amp; caching and for CoreData integration only Apple&#39;s apis are allowed (no 3rd party libraries).
- 7. Use Codable to inflate models fetched from api. ![](RackMultipart20210524-4-1m5phmq_html_b4cbd21e6c303b52.png)

![](RackMultipart20210524-4-1m5phmq_html_ff719d467ce93573.png) ![](RackMultipart20210524-4-1m5phmq_html_d35c00afdacfb18e.png) ![](RackMultipart20210524-4-1m5phmq_html_d35c00afdacfb18e.png) ![](RackMultipart20210524-4-1m5phmq_html_d35c00afdacfb18e.png) ![](RackMultipart20210524-4-1m5phmq_html_d35c00afdacfb18e.png) ![](RackMultipart20210524-4-1m5phmq_html_d35c00afdacfb18e.png) ![](RackMultipart20210524-4-1m5phmq_html_d35c00afdacfb18e.png) ![](RackMultipart20210524-4-1m5phmq_html_d35c00afdacfb18e.png) ![](RackMultipart20210524-4-1m5phmq_html_d35c00afdacfb18e.png) ![](RackMultipart20210524-4-1m5phmq_html_2bd7a01bf5138263.gif) ![](RackMultipart20210524-4-1m5phmq_html_2bd7a01bf5138263.gif) ![](RackMultipart20210524-4-1m5phmq_html_d1fcd01371e613c0.gif)

8. Write Unit tests using ​XCTest​ library for data processing logic &amp; models, CoreData
models (validate creation &amp; update).

- 9. If ​functional programming​ approach is used then only ​Combine​ is permitted
(instead of e.g. ReactiveSwift).

## GitHub users

- 1. The app has to be able to work ​offline​ if data has been previously loaded.
- 2. The app must handle ​_no internet_ ​scenario, show appropriate UI indicators.
3. The app must ​automatically​ retry loading data once the connection is available.
- 4. When there is data available (saved in the database) from previous launches, that data should be displayed first, then (in parallel) new data should be fetched from the

backend.

Users list

- 1. Github users list can be obtained from ​[https://api.github.com/users?since=0](https://api.github.com/users?since=0)​ in JSON format.
- 2. The list must support pagination (​_scroll to load more_​) utilizing ​since p​arameter as the integer ID of the last User loaded.
- _3. Page size_​ has to be dynamically determined after the first batch is loaded.
- 4. The list has to display a spinner while loading data as the last list item.
- 5. Every fourth avatar&#39;s colour should have its (image) colours inverted.

- 6. List item view should have a note icon if there is note information saved for the given

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
protocol. ![](RackMultipart20210524-4-1m5phmq_html_b4cbd21e6c303b52.png)

![](RackMultipart20210524-4-1m5phmq_html_ff719d467ce93573.png) ![](RackMultipart20210524-4-1m5phmq_html_d35c00afdacfb18e.png) ![](RackMultipart20210524-4-1m5phmq_html_d35c00afdacfb18e.png) ![](RackMultipart20210524-4-1m5phmq_html_d35c00afdacfb18e.png) ![](RackMultipart20210524-4-1m5phmq_html_d35c00afdacfb18e.png) ![](RackMultipart20210524-4-1m5phmq_html_d35c00afdacfb18e.png) ![](RackMultipart20210524-4-1m5phmq_html_d35c00afdacfb18e.png) ![](RackMultipart20210524-4-1m5phmq_html_d35c00afdacfb18e.png) ![](RackMultipart20210524-4-1m5phmq_html_d35c00afdacfb18e.png) ![](RackMultipart20210524-4-1m5phmq_html_d35c00afdacfb18e.png) ![](RackMultipart20210524-4-1m5phmq_html_d35c00afdacfb18e.png) ![](RackMultipart20210524-4-1m5phmq_html_d35c00afdacfb18e.png) ![](RackMultipart20210524-4-1m5phmq_html_d35c00afdacfb18e.png) ![](RackMultipart20210524-4-1m5phmq_html_2bd7a01bf5138263.gif) ![](RackMultipart20210524-4-1m5phmq_html_2bd7a01bf5138263.gif) ![](RackMultipart20210524-4-1m5phmq_html_d1fcd01371e613c0.gif)

Profile

- ![](RackMultipart20210524-4-1m5phmq_html_1d3a2fca63d5a59f.gif)Profile info can be obtained from ​[https://api.github.com/users/[](https://api.github.com/users/%5Busername)[​](https://api.github.com/users/%5B%E2%80%8Busername%E2%80%8B%5D)[username](https://api.github.com/users/%5Busername)[​]](https://api.github.com/users/%5B%E2%80%8Busername%E2%80%8B%5D) in JSON
 ![](RackMultipart20210524-4-1m5phmq_html_1ad282e6901133.gif)format (e.g. ​[https://api.github.com/users/tawk](https://api.github.com/users/tawk)​).
- The view should have the user&#39;s avatar as a header view followed by information
fields (UIX is up to you).
- The section must have the possibility to retrieve and save back to the database the Note​ data (not available in GitHub api; local database only).

## Submit your work

1. Make sure code is running on both - simulator and real device.

2. Push up to your repo. The repository should be publicly accessible - must not require

any invitation to be accepted or registrations.

3. Reply back to the initial email the link to your repository.

4. Any 3rd party code that is being used has to be bundled with the code even if the
project is using any code dependency manager.

5. Please indicate which bonus tasks (see next section) have you completed.

## BONUS

- Empty views such as list items (while data is still loading) should have Loading
Shimmer aka ​Skeletons​ ~
[https://miro.medium.com/max/4000/0\*s7uxK77a0FY43NLe.png](https://miro.medium.com/max/4000/0*s7uxK77a0FY43NLe.png)​​resembling​ final
views​.

2. Exponential backoff ​must be used​​when trying to reload the data.

3. Any data fetch should utilize ​Result types.​

- 4. CoreData stack implementation must use ​two managed contexts​ - 1.​main context​ to

be used for reading data and feeding into UI 2. write (​background) context​ - that is
used for writing data.

5. All CoreData ​write​ queries must be ​queued​ while allowing one concurrent query at
any time.

- 6. Coordinator and/or MVVM patterns are used.
- 7. Users list UI must be done in code and Profile - with Interface Builder.

8. Items in users list are greyed out a bit for seen profiles (seen status being saved to

db).

9. The app has to support ​dark mode​. ![](RackMultipart20210524-4-1m5phmq_html_b4cbd21e6c303b52.png)

![](RackMultipart20210524-4-1m5phmq_html_ff719d467ce93573.png) ![](RackMultipart20210524-4-1m5phmq_html_2bd7a01bf5138263.gif) ![](RackMultipart20210524-4-1m5phmq_html_2bd7a01bf5138263.gif) ![](RackMultipart20210524-4-1m5phmq_html_d1fcd01371e613c0.gif)

## Wireframe

[wireframe.png](https://drive.google.com/file/d/1mVTh1S2AHe0eg8RQ9x4rbkHWB5SSWljt/view)

![](RackMultipart20210524-4-1m5phmq_html_d22fd25bf9a1a75c.png)
