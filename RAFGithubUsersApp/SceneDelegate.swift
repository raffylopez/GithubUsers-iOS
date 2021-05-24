//
//  SceneDelegate.swift
//  RAF_GithubUsersApp
//
//  Copyright © 2021 Raf. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var navigationController: GithubUsersAppNavController!
    var window: UIWindow?
    
    private func setupViewControllers() {
        let viewModel = UsersViewModel(apiService: GithubUsersApi(), databaseService: CoreDataService.shared)
        let top = ViewControllersFactory.instance(vcType: .usersList(viewModel))
        navigationController = GithubUsersAppNavController(rootViewController: top)
        navigationController.navigationBar.barStyle = .default
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
    func dbgClearDataStoresOnAppLaunch() {
        let context = CoreDataService.persistentContainer.viewContext
        let usersDatabaseService = CoreDataService.shared
        context.performAndWait {
            try? usersDatabaseService.deleteAll()
        }
        do {
            try context.save()
        } catch {
            fatalError("Can't delete coredata store")
        }
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.windowScene = scene
        setupViewControllers()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) { }
    
    func sceneDidBecomeActive(_ scene: UIScene) { }
    
    func sceneWillResignActive(_ scene: UIScene) { }
    
    func sceneWillEnterForeground(_ scene: UIScene) { }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        let context = CoreDataService.persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
