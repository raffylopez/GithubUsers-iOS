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
    
    override func loadView() {
        super.loadView()
        self.tableView?.register(AmiiboCharacterListViewCell.self, forCellReuseIdentifier: "AmiiboCharacterListViewCell")
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
    
    private func setupViews() {
        self.title = "Character List".localized()
        
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
        return 130
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
            cell.lblSeries?.text = viewModel.presentedElements[indexPath.row].login
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

