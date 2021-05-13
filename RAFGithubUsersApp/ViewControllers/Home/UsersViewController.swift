//
//  ViewController.swift
//  RAFGithubUsersApp
//
//  Created by Volare on 5/11/21.
//  Copyright © 2021 Raf. All rights reserved.
//

import UIKit

class UsersViewController: UITableViewController {
    // MARK: - Configurables
    /**
     Enables look-ahead prefetching for table cells for infinite-scroll implementation.
     If false, tail-end fetching is used.
     */
    let isPrefetchingEnabled: Bool = false
    
    // MARK: Configure table cell types
    typealias StandardTableViewCell = ShimmerTableViewCell
    typealias NoteTableViewCell = NoteUserTableViewCell
    typealias AlternativeTableViewCell = InvertedUserTableViewCell
    typealias DummyTableViewCell = StubUserTableViewCell

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
        registerReuseId(NoteUserTableViewCell.self)
        registerReuseId(AlternativeTableViewCell.self)
        registerReuseId(DummyTableViewCell.self)
    }
    
    /**
     Generic method that uses reflection to obtain a table view cell subtype instance,
     with dequeue identifier based on reflected type
     */
    private func getTableViewCell<T>(_ type: T.Type, cellForRowAt indexPath: IndexPath) -> T where T:UserTableViewCellBase {
        let cell  = tableView.dequeueReusableCell(withIdentifier: String(describing: T.self), for: indexPath)
        if let cell = cell as? T {
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

    private func setupHandlers() {
        let onDataAvailable = {
            var newIndexPathsToReload: [IndexPath] = []
            if self.viewModel.currentPage > 1 {
                newIndexPathsToReload = self.calculateIndexPathsToReload(from: self.viewModel.lastBatchCount)
            }
            
            OperationQueue.main.addOperation {
                if self.viewModel.currentPage <= 1 { /* User performed a refresh */
                    self.tableView.alpha = 0
                    UIView.transition(with: self.tableView,
                                      duration: 0.5,
                                      options: .transitionFlipFromTop,
                                      animations: {
                                        self.tableView.alpha = 1
                                        self.tableView?.reloadSections(IndexSet(integer: 0), with: .none)
                    }, completion: { _ in
                        /* Fix graphical glitch when pull-to-refresh is started when navbar is collapsed */
                        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                    })
                    self.refreshControl?.endRefreshing()
                    return
                }
                let indexPathsToReload = self.visibleIndexPathsToReload(intersecting: newIndexPathsToReload)
                
                /* Ensure slide animations are disabled on row insertion (slide animation used by default on insert) */
                UIView.setAnimationsEnabled(false)
                self.tableView?.beginUpdates()
                self.tableView?.insertRows(at: newIndexPathsToReload, with: .none)
                self.tableView?.endUpdates()
                
                UIView.setAnimationsEnabled(true)
                
                self.tableView?.reloadRows(at: indexPathsToReload, with: .fade)
                //                self.tableView?.reloadRows(at: [IndexPath(row: 29, section: 0)], with: .none)
                //                self.tableView?.reloadSections(IndexSet(integer: 0), with: .fade)
            }
        }
        self.viewModel.bind(availability: onDataAvailable)
    }

    private func setupNavbar() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        let imgSize = CGFloat(20)
        let imgHeight = CGFloat(imgSize)
        let imgWidth = CGFloat(imgSize)
        let spacing = CGFloat(5.0)
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: imgWidth, height: imgHeight))
        imageView.contentMode = .scaleAspectFit
        let img = UIImage(named: "githublogo_wb")!
        imageView.image = img
        let container = UIView()
        let label = UILabel()
        label.text = ""
        label.sizeToFit()
        UIHelper.initializeView(view: label, parent: container)
        label.centerXAnchor.constraint(equalTo: container.centerXAnchor, constant: (imgSize + spacing)/2).isActive = true
        label.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
        
        UIHelper.initializeView(view: imageView, parent: container)
        imageView.rightAnchor.constraint(equalTo: label.leftAnchor, constant: spacing * -1).isActive = true
        imageView.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: imgSize).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: imgSize).isActive = true
        
        self.navigationItem.titleView = container
        //        let bbi: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(tableViewScrollToTop))
        //        let leftBarItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(tableViewScrollToTop))
        //        let rightBarItem: UIBarButtonItem = UIBarButtonItem(image: img.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: nil)
        let rightBarItem = UIBarButtonItem(title: "Scroll to Top".localized(), style: .plain, target: self, action: #selector(tableViewScrollToTop))
        //        navigationItem.leftBarButtonItem = leftBarItem
        navigationItem.rightBarButtonItem = rightBarItem
        self.navigationItem.searchController = search
        self.title = "Browse Users".localized()
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        setupViews()
        setupHandlers()
    }
    
    // MARK: - Selector targets
    @objc private func refreshPulled() {
        self.refreshControl?.beginRefreshing()
        self.viewModel.fetchUsers()
    }
    
    @objc func tableViewScrollToTop() {
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
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
        let element = self.viewModel.users[indexPath.row]
        
        if !isPrefetchingEnabled && isLoadingCell2(for: indexPath) {
            viewModel.fetchUsers()
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
        return viewModel.users.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // TODO: Dynamic height computation
        return 100
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    private func calculateIndexPathsToReload(from newUsers: Int) -> [IndexPath] {
        let startIndex = self.viewModel.users.count - newUsers
        let endIndex = startIndex + newUsers
        print("vmuc:\(self.viewModel.users.count), n:\(newUsers)")
        print("\(startIndex-1), \(endIndex-1)")
        return ((startIndex-1)..<(endIndex-1)).map { IndexPath(row: $0, section: 0) }
    }


    func isLoadingCell2(for indexPath: IndexPath) -> Bool {
        return indexPath.row + 1 >= self.viewModel.currentCount
    }
}

// MARK: - Delegate Methods
// MARK: • UITableViewDatasource methods
extension UsersViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let rowMultipleOfFour = (indexPath.row + 1) % 4 == 0
//        let rowNotZero = indexPath.row != 0
        
//        if rowMultipleOfFour && rowNotZero {
//            return getTableViewCell(AlternativeTableViewCell.self, cellForRowAt: indexPath)
//        }

        let cell = getTableViewCell(StandardTableViewCell.self, cellForRowAt: indexPath)
        cell.delegate = self
//        if isLoadingCell2(for: indexPath) {
//            cell.updateWith(user: viewModel.users[indexPath.row])
//            return cell
//        }
        cell.updateWith(user: viewModel.users[indexPath.row])
        return cell
    }
}

// MARK: • Cell Touch Delegate Methods
extension UsersViewController: UserListTableViewCellDelegate {
    func didTouchImageThumbnail(view: UIImageView, cell: UserTableViewCellBase, element: User) {
    }
    
    func didTouchCellPanel(cell: UserTableViewCellBase) {
        let viewModel = ProfileViewModel(apiService: GithubUsersApi())
        self.navigationController?.pushViewController(ViewControllersFactory.instance(vcType: .userProfile(viewModel)), animated: true)
    }
}

extension UsersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        // TODO
    }
    
}

extension UsersViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if isPrefetchingEnabled && indexPaths.contains(where: isLoadingCell) {
            viewModel.fetchUsers()
        }
    }
}

private extension UsersViewController {
  func isLoadingCell(for indexPath: IndexPath) -> Bool {
    return (indexPath.row + 1) >= self.viewModel.currentCount
  }

  func visibleIndexPathsToReload(intersecting indexPaths: [IndexPath]) -> [IndexPath] {
    let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows ?? []
    let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(indexPaths)
    return Array(indexPathsIntersection)
  }
}

