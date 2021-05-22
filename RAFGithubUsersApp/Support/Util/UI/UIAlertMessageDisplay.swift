//
//  MessageDisplay.swift
//  RAFGithubUsersApp
//
//  Created by Volare on 5/19/21.
//  Copyright © 2021 Raf. All rights reserved.
//

import Foundation

protocol UIAlertMessageDisplay {
    func display(message: String)
}

/* Ensures that toast messages are always displayed on the main queue*/
class ToastAlertMessageDisplay: UIAlertMessageDisplay {
    static let main = ToastAlertMessageDisplay()
    static let appView = UIApplication.shared.windows.first?.rootViewController?.view
    func displayTop(message: String) {
        OperationQueue.main.addOperation {
            Self.appView?.hideAllToasts()
            Self.appView?.makeToast(message, position: .top)
        }
    }
    func display(message: String) {
        OperationQueue.main.addOperation {
            Self.appView?.hideAllToasts()
            Self.appView?.makeToast(message)
        }
    }
    func hideAllToasts() {
        OperationQueue.main.addOperation {
            Self.appView?.hideAllToasts()
        }
    }
    func stickyToast(message: String) {
        OperationQueue.main.addOperation {
            Self.appView?.hideAllToasts()
            Self.appView?.makeToast(message, duration: TimeInterval(Int.max))
        }
    }
    func makeToastActivity() {
        OperationQueue.main.addOperation {
            Self.appView?.makeToastActivity(.bottom)
        }
    }
    func hideToastActivity() {
        OperationQueue.main.addOperation {
            Self.appView?.hideToastActivity()
        }
        
    }
}

class StandardAlertMessageDisplay: UIAlertMessageDisplay {
    static let shared = StandardAlertMessageDisplay()
    func display(message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Note saved", message: "Your note has been saved", preferredStyle: .actionSheet)
            let action = UIAlertAction(title: "OK", style: .default) { action in }
            alert.addAction(action)
            UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
}

