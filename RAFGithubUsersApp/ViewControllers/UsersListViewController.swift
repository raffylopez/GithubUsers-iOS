//
//  ViewController.swift
//  RAFGithubUsersApp
//
//  Created by Volare on 5/11/21.
//  Copyright © 2021 Raf. All rights reserved.
//

import UIKit

class UsersListViewController: UITableViewController {
    
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
    
    var tap: UITapGestureRecognizer!

    @objc func dismissKeyboard() {
        search.dismiss(animated: true, completion: nil)
    }
    
    override func loadView() {
        super.loadView()
        self.tableView?.register(AmiiboCharacterListViewCell.self, forCellReuseIdentifier: String(describing: AmiiboCharacterListViewCell.self))
        self.tableView.scrollsToTop = true
        self.view.backgroundColor = UIColor.systemBackground
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.tableView.addGestureRecognizer(tap)
        setupViews()
        let onDataAvailable = {
            OperationQueue.main.addOperation {
                self.tableView.alpha = 0
                UIView.transition(with: self.tableView,
                                  duration: 0.5,
                                  options: .transitionFlipFromTop,
                                  animations: {
                                    self.tableView.alpha = 1
                                    self.tableView?.reloadSections(IndexSet(integer: 0), with: .none)
                }, completion: { _ in
                    /* fixes graphical glitch when pull-to-refresh is started when navbar is collapsed */
                    self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                })
                self.refreshControl?.endRefreshing()
            }
        }
        self.viewModel.bind(availability: onDataAvailable)
//        tableView?.refreshControl?.beginRefreshing()
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage? {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    private func setNavbar() {
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
        label.text = "Github"
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
        self.navigationItem.searchController = search
        self.title = "Browse Users".localized()
    }
    
    private func setupViews() {
        setNavbar()
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    @objc private func refresh() {
        self.refreshControl?.beginRefreshing()
        self.viewModel.fetchUsers()
    }
    
    // MARK: - UITableViewDelegate methods
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let element = self.viewModel.users[indexPath.row]
        viewModel.fetchImage(for: element) { result in
            guard let photoIndex = self.viewModel.users.firstIndex(of: element),
                case let .success(image) = result else {
                    return
            }
            if let cell = self.tableView.cellForRow(at: IndexPath(item: photoIndex, section: 0)) as? AmiiboCharacterListViewCell {
                cell.update(displaying: image)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.users.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        let cell = self.tableView.cellForRow(at: indexPath) as? AmiiboCharacterListViewCell
//        let height = cell?.imageView?.frame.size.height ?? 130
        return 100
    }
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    // MARK: - UITableViewDatasource methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AmiiboCharacterListViewCell.self), for: indexPath)
        if let cell = cell as? AmiiboCharacterListViewCell {
            cell.delegate = self
            cell.amiiboElement = viewModel.users[indexPath.row]
            cell.lblName?.text = viewModel.presentedElements[indexPath.row].login
            cell.lblSeries?.text = viewModel.presentedElements[indexPath.row].urlHtml
        }
        return cell
    }
}

// MARK: - Cell Delegate Methods
extension UsersListViewController: AmiiboCharacterListViewCellDelegate {
    func didTouchImageThumbnail(view: UIImageView, cell: AmiiboCharacterListViewCell, element: User) {
//        let viewModel = UsersViewModel(apiService: GithubUsersApi())
        self.navigationController?.pushViewController(ViewControllersFactory.instance(vcType: .userProfile), animated: true)
    }
    
    func didTouchCellPanel(cell: AmiiboCharacterListViewCell) {
        self.navigationController?.pushViewController(
            ViewControllersFactory.instance(vcType: .userProfile),
            animated: true)
    }
}

extension UsersListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        // TODO
    }
    
}
