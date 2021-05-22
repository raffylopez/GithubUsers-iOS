//
//  ViewController.swift
//  RAFGithubUsersApp
//
//  Created by Volare on 5/11/21.
//  Copyright © 2021 Raf. All rights reserved.
//

import UIKit


class UsersViewController: UITableViewController {
    
    init(viewModel: UsersViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    /* Storyboard not supported*/
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not supported")
    }
    

    fileprivate func startSplashAnimation() {
        let icon: SKSplashIcon = SKSplashIcon(image: UIImage(named: "github_splash_dark")!)
        guard let splashView = SKSplashView(splashIcon: icon, animationType: .none),
            let navController = self.navigationController
        else { return }
        splashView.backgroundColor = .black
        splashView.animationDuration = 2.0
        navController.view.addSubview(splashView)
        splashView.startAnimation()
    }
    
    // MARK: - Configurables
    /**
     Enables look-ahead prefetching for table cells for infinite-scroll implementation.
     If false, tail-end fetching is used.
     */
    let confPrefetchingEnabled: Bool = false
    
    /**
     Cached images need to be reloaded after toggling this flag
     */
    let confImageInversionOnFourthRows: Bool = true
    
    private func setupReachability() {
//        ConnectionMonitor.shared.delegate = self
//        ConnectionMonitor.shared.checkNetworkSignal()
    }
    
    var lastConnectionState: ConnectionState = .reachable
    // MARK: Configure table cell types
//    typealias StandardTableViewCell = NormalUserTableViewCell
//    typealias StandardNotedTableViewCell = NoteNormalUserTableViewCell
//    typealias AlternativeTableViewCell = InvertedUserTableViewCell
//    typealias AlternativeNotedTableViewCell = NoteInvertedUserTableViewCell
    typealias StandardTableViewCell = DebugUserTableViewCell
    typealias StandardNotedTableViewCell = DebugUserTableViewCell
    typealias AlternativeTableViewCell = DebugUserTableViewCell
    typealias AlternativeNotedTableViewCell = DebugUserTableViewCell
    
    typealias DummyTableViewCell = DebugUserTableViewCell

    // MARK: - Properties and attributes
    var viewModel: UsersViewModel!
    lazy var search: UISearchController = {
        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Search (quote for exact match)"
        search.searchBar.autocapitalizationType = .none
        search.searchBar.autocorrectionType = .no
        search.searchBar.sizeToFit()
        return search
    }()
    
    lazy var tap: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        return tap
    }()

    lazy var tapButton: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tableViewScrollToTop))
        tap.cancelsTouchesInView = false
        return tap
    }()

    // MARK: - Table cell registration
    /**
     Registers table cell types with reuse identifiers, used for dequeueing cells
     */
    private func registerReuseId<T>(_ type: T.Type) where T: UserTableViewCellBase {
        self.tableView?.register(T.self, forCellReuseIdentifier: String(describing: T.self))
    }

    private func registerTableCellTypes() {
        registerReuseId(StandardTableViewCell.self)
        registerReuseId(StandardNotedTableViewCell.self)
        registerReuseId(AlternativeTableViewCell.self)
        registerReuseId(AlternativeNotedTableViewCell.self)
        registerReuseId(DummyTableViewCell.self)
    }
    
    /**
     Generic method that uses reflection to obtain a table view cell subtype instance,
     with dequeue identifier based on reflected type
     */
    private func buildCell<T>(associatedUser: User, _ type: T.Type, cellForRowAt indexPath: IndexPath) -> T where T:UserTableViewCellBase {
        let cell  = tableView.dequeueReusableCell(withIdentifier: String(describing: T.self), for: indexPath)
        if let cell = cell as? T {
            cell.user = associatedUser
            cell.indexPath = indexPath
            cell.delegate = self
            cell.owningController = self
            return cell
        }
        fatalError("Cannot dequeue to \(String(describing:T.self))")
    }

    // MARK: - Setup
    private func setupTableView() {
        self.tableView.addGestureRecognizer(tap)
        self.tableView.scrollsToTop = true
        self.tableView.prefetchDataSource = self
        registerTableCellTypes()
    }

    /**
     Displays a toast message at the bottom.
     
     Navigation controller should be the receiver, otherwise toast
     might be misplaced or obscured.
     
     Display is always performed in the main queue
     */
    private func makeToast(message:String, duration: TimeInterval) {
        DispatchQueue.main.async {
            self.navigationController?.view.makeToast(message, duration: duration, position: .bottom)
        }
    }
    
    private func multiple(of multiple: Int, _ value: Int, includingFirst: Bool = false) -> Bool {
        if includingFirst {
            return value % multiple == 0
        }
        return value % multiple == 0 && value != 0
    }
    
    private func performInvertedImagesPrefetching() {
        guard confImageInversionOnFourthRows else {
            return
        }
        
        var i: Int = 0
        for user in self.viewModel.users {
            guard self.viewModel.imageStore.image(forKey: "\(user.id)") == nil else  { continue }
            if (i+1) % 4 == 0 {
                self.viewModel.fetchImage(for: user) { result in
                    if case let .success(img) = result, let inverted = img.0.invertImageColors() {
                        self.viewModel.imageStore.setImage(forKey: "\(user.id)", image: inverted)
                    }
                }
            }
            
            i += 1
        }
    }
    

    // zxcv
    private func setupHandlers() {

        self.viewModel.delegate = self
        let onDataAvailable = {
            guard !self.viewModel.users.isEmpty && !self.search.isActive else {
//                self.tableView.reloadData()
                return
            }
            print("STATS TOTAL USERS DATASOURCE COUNT (onDataAvailable): \(self.viewModel.users.count)" )
            print("STATS UserCount: \(self.viewModel.users.count)")
            
//            self.viewModel.currentPage = 1 /* DEBUG: FORCE*/

//            if let users = self.viewModel.users, let first = users.first {
//                print(first)
//             }  // DEBUG

            OperationQueue.main.addOperation {
                ToastAlertMessageDisplay.main.hideToastActivity()
                
                /* RECALICTRANT */
                if self.viewModel.currentPage <= 1 { /* User performed a refresh/first load */
                    self.tableView.alpha = 0
                    self.tableView.alpha = 1
                    UIView.transition(with: self.tableView,
                                      duration: 0.0,
                                      options: [],
                                      animations: {
                                        self.tableView.alpha = 1
                                        self.tableView?.reloadSections(IndexSet(integer: 0), with: .none)
                    }, completion: { _ in
                        /* Fix graphical glitch when pull-to-refresh is started when navbar is collapsed */
//                        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                    })
                    self.refreshControl?.endRefreshing()
                    return
                }
                
                let newIndexPathsToInsert: [IndexPath] = self.calculateIndexPathsToInsert(from: self.viewModel.lastBatchCount)
                let indexPathsToReload = self.visibleIndexPathsToReload(intersecting: newIndexPathsToInsert)
                
                print("STATS To reload(new): \(newIndexPathsToInsert.count), since: \(self.viewModel.since), currentCount: \(self.viewModel.currentCount), lastBatchCount: \(self.viewModel.lastBatchCount), start: \(newIndexPathsToInsert[0].row), end: end: \(newIndexPathsToInsert[newIndexPathsToInsert.count-1].row) ")
                
                /* Ensure slide animations are disabled on row insertion (slide animation used by default on insert) */
                UIView.setAnimationsEnabled(false)
                self.tableView?.beginUpdates()
                self.tableView?.insertRows(at: newIndexPathsToInsert, with: .none)
                self.tableView?.endUpdates()
                
                UIView.setAnimationsEnabled(true)
                
                self.tableView?.reloadRows(at: indexPathsToReload, with: .fade)
                //                self.tableView?.reloadRows(at: [IndexPath(row: 29, section: 0)], with: .none)
                //                self.tableView?.reloadSections(IndexSet(integer: 0), with: .fade)
                    let contentOffset = self.tableView.contentOffset
                    self.tableView.reloadData()
                    self.tableView.layoutIfNeeded()
                    self.tableView.setContentOffset(contentOffset, animated: false)
            }
        }
        self.viewModel.bind(availability: onDataAvailable)
        
        // if network is available, freshen datastore objects
        
    }

    private func setupNavbar() {
        let imgSize = CGFloat(24)
//        let imgHeight = CGFloat(imgSize)
//        let imgWidth = CGFloat(imgSize)
        let spacing = CGFloat(5.0)
//        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: imgWidth, height: imgHeight))
//        imageView.contentMode = .scaleAspectFit
//        let img = UIImage(named: "github_splash_light")!
//        imageView.image = img
        let container = UIView()
        let label = UILabel()
        label.text = "".localized()
        label.sizeToFit()
        UIHelper.initializeView(view: label, parent: container)
        label.centerXAnchor.constraint(equalTo: container.centerXAnchor, constant: (imgSize + spacing)/2).isActive = true
        label.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
        
//        UIHelper.initializeView(view: imageView, parent: container)
//        imageView.rightAnchor.constraint(equalTo: label.leftAnchor, constant: spacing * -1).isActive = true
//        imageView.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
//        imageView.widthAnchor.constraint(equalToConstant: imgSize).isActive = true
//        imageView.heightAnchor.constraint(equalToConstant: imgSize).isActive = true
        
//        self.navigationItem.titleView = container
        let titleLabel = UILabel()
        titleLabel.font = UIFont.fontAwesome(ofSize: 20, style: .brands)
        titleLabel.text = String.fontAwesomeIcon(name: .github)
        self.navigationItem.titleView = titleLabel
        //        let bbi: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(tableViewScrollToTop))
        //        let leftBarItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(tableViewScrollToTop))
        //        let rightBarItem: UIBarButtonItem = UIBarButtonItem(image: img.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: nil)
        //        navigationItem.leftBarButtonItem = leftBarItem
        self.navigationItem.searchController = search
        self.title = "Browse Users".localized()
        let leftBarItem = UIBarButtonItem(title: "Refresh Stale".localized(), style: .plain, target: self, action: #selector(self.refreshStale))
        self.navigationItem.leftBarButtonItem = leftBarItem
    }
    
    @objc func refreshStale() {
        self.viewModel.refreshStale { result in
//            switch result {
//            case let .success(_):
//                let endIndex = self.viewModel.users.count - 1
//                let paths = (0..<endIndex).map { IndexPath(row: $0, section: 0) }
//                self.tableView.reloadRows(at: paths, with: .none)
//            case let .failure(_):
//                break
//            }
            DispatchQueue.main.async {
//                let paths: [IndexPath] = self.tableView.visibleCells.map {
//                    let cell = $0 as! UserTableViewCellBase
//                    return cell.indexPath
//                }
//                self.tableView.reloadRows(at: paths, with: .none)
                let contentOffset = self.tableView.contentOffset
//                self.tableView.reloadData()
//                self.tableView.layoutIfNeeded()
//                let paths: [IndexPath] = self.tableView.visibleCells.map {
//                    let cell = $0 as! UserTableViewCellBase
//                    return cell.indexPath
//                }
                                self.tableView.reloadData()
//                self.tableView.reloadRows(at: paths, with: .none)
                self.tableView.layoutIfNeeded()
                self.tableView.setContentOffset(contentOffset, animated: false)
//                self.tableView.estimatedRowHeight = 1000
//                self.tableView.estimatedSectionFooterHeight = 100.0
//                self.tableView.estimatedSectionHeaderHeight = 500.0
            }
        }
    }
    private func setupViews() {
        setupNavbar()
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(refreshPulled), for: .valueChanged)
    }
    
    // MARK: - ViewController methods
    override func loadView() {
        super.loadView()
        setupTableView()
        self.view.backgroundColor = UIColor.systemBackground
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
//        navigationItem.title = "Browse Users".localized()
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        try? self.viewModel.usersDatabaseService.deleteAll() // DEBUG
        startSplashAnimation()
        self.view.backgroundColor = .systemBackground
        setupViews()
        setupHandlers()
        setupReachability()
        self.fetchMoreTableDataDisplayingResults()

    }
    
    private func clearData() {
        self.viewModel.clearData()
        self.tableView.reloadData() // TODO
    }
    
    // MARK: - Selector targets
    @objc private func refreshPulled() {
        self.refreshControl?.beginRefreshing()
        clearData()
        fetchMoreTableDataDisplayingResults()
    }
    
    func fetchMoreTableDataDisplayingResults(completion: (()->Void)? = nil) {
        ToastAlertMessageDisplay.main.makeToastActivity()
        self.viewModel.updateUsers {
            ToastAlertMessageDisplay.main.hideToastActivity()
        }
//        self.viewModel.fetchUsers { result in
//            DispatchQueue.main.async {
//                self.refreshControl?.endRefreshing()
//                if case let .failure(error) = result {
//                    print(error) // TODO
//                }
//            }
//        }
    }

    @objc func tableViewScrollToTop() {
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
    }
    
    /**
     Selectable method for tap gesture recognizer, for dismissing search
     when user clicks out of keyboard/searchbox. Needs gesture recognizer
     to have cancelsTouchesInView set to false
     */
    @objc func dismissKeyboard() {
        search.dismiss(animated: true, completion: nil)
    }

    // MARK: - UITableViewDelegate methods
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard !self.viewModel.users.isEmpty && self.viewModel.users.count - 1 >= indexPath.row else {
            return
        }
//        guard !self.search.isActive else {
//            return
//        }
        let element = self.viewModel.users[indexPath.row]
        
        if isLoadingLastCell(for: indexPath) && !self.search.isActive {
            fetchMoreTableDataDisplayingResults()
        }

        viewModel.fetchImage(for: element) { result in
            guard let photoIndex = self.viewModel.users.firstIndex(of: element),
                case let .success(image) = result else {
                    return
            }
            if let cell = self.tableView.cellForRow(at: IndexPath(item: photoIndex, section: 0)) as? StandardTableViewCell {
                cell.update(displaying: image)
                return
            }
            if let cell = self.tableView.cellForRow(at: IndexPath(item: photoIndex, section: 0)) as? AlternativeTableViewCell {
                cell.update(displaying: image)
                return
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewModel.users.count > 0 {
        return viewModel.users.count
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // TODO: Dynamic height computation
        return 100
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    private func calculateIndexPathsToInsert(from newUsers: Int, offset: Int = 0) -> [IndexPath] {
        let startIndex = (self.viewModel.users.count - newUsers) + offset
        let endIndex = (startIndex + newUsers)
        print("STATS vmuc:\(self.viewModel.users.count), n:\(newUsers)")
        print("STATS STARTINDEX: \(startIndex), ENDINDEX: \(endIndex)")
//        if self.viewModel.currentPage == 1 {
//            return ((startIndex)..<(endIndex-1)).map { IndexPath(row: $0, section: 0) }
//        }
//        return ((startIndex < 0 ? startIndex : startIndex - 1)..<(endIndex-1)).map { IndexPath(row: $0, section: 0) }
//        return (startIndex-1..<endIndex-1).map { IndexPath(row: $0, section: 0) }
        return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
    }

    func isLoadingLastCell(for indexPath: IndexPath) -> Bool {
        return indexPath.row + 1 >= self.viewModel.users.count
    }
}

// MARK: - Delegate Methods
// MARK: • UITableViewDatasource methods
extension UsersViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard !self.viewModel.users.isEmpty && self.viewModel.users.count - 1 >= indexPath.row else {
//            self.tableView.reloadData()
            return UITableViewCell()
        }
        
        let user = viewModel.users[indexPath.row]
        var cell: UserTableViewCellBase!

        let hasNote = user.userInfo != nil && user.userInfo?.note != nil && user.userInfo?.note != ""
        
        if (multiple(of: 4, indexPath.row + 1) && confImageInversionOnFourthRows) {
            cell = hasNote ?
                buildCell(associatedUser: user, AlternativeNotedTableViewCell.self, cellForRowAt: indexPath) :
                buildCell(associatedUser: user, AlternativeTableViewCell.self, cellForRowAt: indexPath)
            cell.tag = indexPath.row
            cell.updateCell()
            return cell
        }
        cell = hasNote ?
            buildCell(associatedUser: user, StandardNotedTableViewCell.self, cellForRowAt: indexPath) :
            buildCell(associatedUser: user, StandardTableViewCell.self, cellForRowAt: indexPath)
        cell.tag = indexPath.row
        cell.updateCell()

//        self.navigationItem.rightBarButtonItem?.title = "\(indexPath.row)"
        //        let cell: UserTableViewCellBase = multiple(of: 4, indexPath.row + 1) && confImageInversionOnFourthRows ?
        //            getUserTableViewCell(associatedUser: user, AlternativeTableViewCell.self, cellForRowAt: indexPath) :
        //            getUserTableViewCell(associatedUser: user, StandardTableViewCell.self, cellForRowAt: indexPath)
        return cell
    }
}

// MARK: • Cell Touch Delegate Methods
extension UsersViewController: UserListTableViewCellDelegate {
    func didTouchImageThumbnail(view: UIImageView, cell: UserTableViewCellBase, element: User) {
    }
    
    func didTouchCellPanel(cell: UserTableViewCellBase) {
        guard !self.viewModel.isFetchInProgress else {
            return
        }
        let viewModel = ProfileViewModel(cell: cell, apiService: GithubUsersApi(), databaseService: CoreDataService.shared)
        let profileViewController = ViewControllersFactory.instance(vcType: .userProfile(viewModel)) as! ProfileViewController
        profileViewController.delegate = self
        self.navigationController?.pushViewController(profileViewController, animated: true)
    }
    
}

extension UsersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        // TODO
//        self.viewModel.clearUsers()
        guard let text = searchController.searchBar.text else {
            return
        }
        self.viewModel.searchUsers(for: text)
        self.tableView.reloadData()
//        self.tableView.dataSource = self.viewModel.filteredUsers
//        var request = NSFetchRequest(entityName: "User")
//        filteredTableData.removeAll(keepCapacity: false)
//        let searchPredicate = NSPredicate(format: "SELF.infos CONTAINS[c] %@", searchController.searchBar.text)
//        let array = (series as NSArray).filteredArrayUsingPredicate(searchPredicate)
//
//        for item in array
//        {
//            let infoString = item.infos
//            filteredTableData.append(infoString)
//        }
//
//        self.tableView.reloadData()
    }
    
}

extension UsersViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
//        if confPrefetchingEnabled && indexPaths.contains(where: isLoadingCell) {
//            fetchAdditionalTableData()
//        }
    }
}

extension UsersViewController {
    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return (indexPath.row + 1) >= self.viewModel.currentCount
    }
    
    func visibleIndexPathsToReload(intersecting indexPaths: [IndexPath]) -> [IndexPath] {
        let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows ?? []
        let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(indexPaths)
        return Array(indexPathsIntersection)
    }
}

enum ConnectionState {
    case reachable
    case unreachable
}

extension UsersViewController: ReachabilityDelegate {
    func onLostConnection() {
        lastConnectionState = .unreachable
        makeToast(message: "You are browsing offline", duration: 1000.0)
        
    }
    
    func onRegainConnection() {
        if lastConnectionState == .unreachable {
            ToastAlertMessageDisplay.main.hideToastActivity()
            makeToast(message: "Connected", duration: 3.0)
            lastConnectionState = .reachable
        }
    }
    
    
}
extension UsersViewController: ViewModelDelegate {

    func onRetryError(n: Int, nextAttemptInMilliseconds: Int, error: Error) {
            self.makeToast(message: "Unable to load data (\(n)). Retrying in \(nextAttemptInMilliseconds/1000) secs", duration: 3.0)
        DispatchQueue.main.async {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    func onDataAvailable() {
        DispatchQueue.main.async {
            let rightBarItem = UIBarButtonItem(title: "Scroll to Top".localized(), style: .plain, target: self, action: #selector(self.tableViewScrollToTop))
            self.navigationItem.rightBarButtonItem = rightBarItem
        }
    }
    
    func onFetchInProgress() {
        //
    }
    
    func onFetchDone() {
        //
    }
}

extension UsersViewController: ProfileViewDelegate {
    func didSaveNote(at indexPath: IndexPath) {
        self.tableView.reloadRows(at: [indexPath], with: .none)
    }
}
