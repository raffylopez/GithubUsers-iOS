//
//  Copyright © 2021 Raf. All rights reserved.
//

import UIKit

protocol UserListTableViewCellDelegate: class {
    func didTouchImageThumbnail(view: UIImageView, cell: UserTableViewCellBase, element: User)
    func didTouchCellPanel(cell: UserTableViewCellBase)
}


