//
//  ViewController.swift
//  RAFGithubUsersApp
//
//  Created by Volare on 5/11/21.
//  Copyright © 2021 Raf. All rights reserved.
//

import UIKit

class UsersListViewController: UITableViewController, UISearchBarDelegate {
    
    var viewModel: UsersViewModel!
    lazy var searchBar:UISearchBar = UISearchBar()

    func setupSearchBar()
    {
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = " Search..."
        searchBar.sizeToFit()
        searchBar.isTranslucent = false
        searchBar.backgroundImage = UIImage()
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        
    }


    override func loadView() {
        super.loadView()
        self.tableView?.register(AmiiboCharacterListViewCell.self, forCellReuseIdentifier: "AmiiboCharacterListViewCell")
        self.view.backgroundColor = UIColor.systemBackground
        searchBar = UISearchBar()
        self.view.addSubview(searchBar)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        setupViews()
        let onDataAvailable = {
            OperationQueue.main.addOperation {
                UIView.transition(with: self.tableView,
                                  duration: 1,
                                  options: .transitionFlipFromTop,
                                  animations: {
                                    self.tableView?.reloadSections(IndexSet(integer: 0), with: .none)
                })
                self.refreshControl?.endRefreshing()
            }
        }
        self.viewModel.bind(availability: onDataAvailable)
        tableView?.refreshControl?.beginRefreshing()
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
        label.text = "Browse Github Users"
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
        self.title = "Github Users".localized()
    }
    
    private func setupViews() {
        setNavbar()
        setupSearchBar()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "AmiiboCharacterListViewCell", for: indexPath)
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

