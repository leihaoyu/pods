import Foundation
import UIKit

public extension TGTransition.Appear {
    static func `default`(scale: Bool = false, alpha: Bool = false) -> TGTransition.Appear {
        return TGTransition.Appear { component, view, transition in
            if scale {
                transition.animateScale(view: view, from: 0.01, to: 1.0)
            }
            if alpha {
                transition.animateAlpha(view: view, from: 0.0, to: 1.0)
            }
        }
    }

    static func scaleIn() -> TGTransition.Appear {
        return TGTransition.Appear { component, view, transition in
            transition.animateScale(view: view, from: 0.01, to: 1.0)
        }
    }
}

public extension TGTransition.AppearWithGuide {
    static func `default`(scale: Bool = false, alpha: Bool = false) -> TGTransition.AppearWithGuide {
        return TGTransition.AppearWithGuide { component, view, guide, transition in
            if scale {
                transition.animateScale(view: view, from: 0.01, to: 1.0)
            }
            if alpha {
                transition.animateAlpha(view: view, from: 0.0, to: 1.0)
            }
            transition.animatePosition(view: view, from: CGPoint(x: guide.x - view.center.x, y: guide.y - view.center.y), to: CGPoint(), additive: true)
        }
    }
}

public extension TGTransition.Disappear {
    static func `default`(scale: Bool = false, alpha: Bool = true) -> TGTransition.Disappear {
        return TGTransition.Disappear { view, transition, completion in
            if scale {
                transition.setScale(view: view, scale: 0.01, completion: { _ in
                    if !alpha {
                        completion()
                    }
                })
            }
            if alpha {
                transition.setAlpha(view: view, alpha: 0.0, completion: { _ in
                    completion()
                })
            }
            if !alpha && !scale {
                completion()
            }
        }
    }
}

public extension TGTransition.DisappearWithGuide {
    static func `default`(alpha: Bool = true) -> TGTransition.DisappearWithGuide {
        return TGTransition.DisappearWithGuide { stage, view, guide, transition, completion in
            switch stage {
            case .begin:
                if alpha {
                    transition.setAlpha(view: view, alpha: 0.0, completion: { _ in
                        completion()
                    })
                }
                transition.setFrame(view: view, frame: CGRect(origin: CGPoint(x: guide.x - view.bounds.width / 2.0, y: guide.y - view.bounds.height / 2.0), size: view.bounds.size), completion: { _ in
                    if !alpha {
                        completion()
                    }
                })
            case .update:
                transition.setFrame(view: view, frame: CGRect(origin: CGPoint(x: guide.x - view.bounds.width / 2.0, y: guide.y - view.bounds.height / 2.0), size: view.bounds.size))
            }
        }
    }
}

public extension TGTransition.Update {
    static let `default` = TGTransition.Update { component, view, transition in
        let frame = component.size.centered(around: component._position ?? CGPoint())
        if let scale = component._scale {
            transition.setBounds(view: view, bounds: CGRect(origin: CGPoint(), size: frame.size))
            transition.setPosition(view: view, position: frame.center)
            transition.setScale(view: view, scale: scale)
        } else {
            if view.frame != frame {
                transition.setFrame(view: view, frame: frame)
            }
        }
        let opacity = component._opacity ?? 1.0
        if view.alpha != opacity {
            transition.setAlpha(view: view, alpha: opacity)
        }
    }
}
