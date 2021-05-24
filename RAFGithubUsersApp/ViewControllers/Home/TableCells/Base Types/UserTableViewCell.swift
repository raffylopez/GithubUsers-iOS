//
//  Copyright © 2021 Raf. All rights reserved.
//

import UIKit

protocol UserTableViewCell: UITableViewCell {
    func update(displaying image: (UIImage, ImageSource)?)
}
