import Foundation
import AccountContextKit

public protocol GalleryItemTransitionNode: AnyObject {
    func isAvailableForGalleryTransition() -> Bool
    func isAvailableForInstantPageTransition() -> Bool
    var decoration: UniversalVideoDecoration? { get }
}
