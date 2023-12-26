import Foundation
import UIKit
import Display
import ComponentFlow
import DirectionalPanGesture

public protocol PagerExpandableScrollView: UIScrollView {
}

public protocol PagerPanGestureRecognizer: UIGestureRecognizer {
}

open class PagerExternalTopPanelContainer: SparseContainerView {
}

public protocol PagerContentViewWithBackground: UIView {
    func pagerUpdateBackground(backgroundFrame: CGRect, transition: Transition)
}

public final class PagerComponentChildEnvironment: Equatable {
    public struct ContentScrollingUpdate {
        public var relativeOffset: CGFloat
        public var absoluteOffsetToTopEdge: CGFloat?
        public var absoluteOffsetToBottomEdge: CGFloat?
        public var isReset: Bool
        public var isInteracting: Bool
        public var transition: Transition
        
        public init(
            relativeOffset: CGFloat,
            absoluteOffsetToTopEdge: CGFloat?,
            absoluteOffsetToBottomEdge: CGFloat?,
            isReset: Bool,
            isInteracting: Bool,
            transition: Transition
        ) {
            self.relativeOffset = relativeOffset
            self.absoluteOffsetToTopEdge = absoluteOffsetToTopEdge
            self.absoluteOffsetToBottomEdge = absoluteOffsetToBottomEdge
            self.isReset = isReset
            self.isInteracting = isInteracting
            self.transition = transition
        }
    }
    
    public let containerInsets: UIEdgeInsets
    public let onChildScrollingUpdate: (ContentScrollingUpdate) -> Void
    public let onWantsExclusiveModeUpdated: (Bool) -> Void
    public let scrollToTop: ActionSlot<Void>
    
    init(
        containerInsets: UIEdgeInsets,
        onChildScrollingUpdate: @escaping (ContentScrollingUpdate) -> Void,
        onWantsExclusiveModeUpdated: @escaping (Bool) -> Void,
        scrollToTop: ActionSlot<Void>
    ) {
        self.containerInsets = containerInsets
        self.onChildScrollingUpdate = onChildScrollingUpdate
        self.onWantsExclusiveModeUpdated = onWantsExclusiveModeUpdated
        self.scrollToTop = scrollToTop
    }
    
    public static func ==(lhs: PagerComponentChildEnvironment, rhs: PagerComponentChildEnvironment) -> Bool {
        if lhs.containerInsets != rhs.containerInsets {
            return false
        }
        
        return true
    }
}

public final class PagerComponentPanelEnvironment<TopPanelEnvironment>: Equatable {
    public let isContentInFocus: Bool
    public let contentOffset: CGFloat
    public let contentTopPanels: [AnyComponentWithIdentity<TopPanelEnvironment>]
    public let contentIcons: [PagerComponentContentIcon]
    public let contentAccessoryLeftButtons: [AnyComponentWithIdentity<Empty>]
    public let contentAccessoryRightButtons: [AnyComponentWithIdentity<Empty>]
    public let activeContentId: AnyHashable?
    public let navigateToContentId: (AnyHashable) -> Void
    public let visibilityFractionUpdated: ActionSlot<(CGFloat, Transition)>
    public let isExpandedUpdated: (Bool, Transition) -> Void
    
    init(
        isContentInFocus: Bool,
        contentOffset: CGFloat,
        contentTopPanels: [AnyComponentWithIdentity<TopPanelEnvironment>],
        contentIcons: [PagerComponentContentIcon],
        contentAccessoryLeftButtons: [AnyComponentWithIdentity<Empty>],
        contentAccessoryRightButtons: [AnyComponentWithIdentity<Empty>],
        activeContentId: AnyHashable?,
        navigateToContentId: @escaping (AnyHashable) -> Void,
        visibilityFractionUpdated: ActionSlot<(CGFloat, Transition)>,
        isExpandedUpdated: @escaping (Bool, Transition) -> Void
    ) {
        self.isContentInFocus = isContentInFocus
        self.contentOffset = contentOffset
        self.contentTopPanels = contentTopPanels
        self.contentIcons = contentIcons
        self.contentAccessoryLeftButtons = contentAccessoryLeftButtons
        self.contentAccessoryRightButtons = contentAccessoryRightButtons
        self.activeContentId = activeContentId
        self.navigateToContentId = navigateToContentId
        self.visibilityFractionUpdated = visibilityFractionUpdated
        self.isExpandedUpdated = isExpandedUpdated
    }
    
    public static func ==(lhs: PagerComponentPanelEnvironment, rhs: PagerComponentPanelEnvironment) -> Bool {
        if lhs.isContentInFocus != rhs.isContentInFocus {
            return false
        }
        if lhs.contentOffset != rhs.contentOffset {
            return false
        }
        if lhs.contentTopPanels != rhs.contentTopPanels {
            return false
        }
        if lhs.contentIcons != rhs.contentIcons {
            return false
        }
        if lhs.contentAccessoryLeftButtons != rhs.contentAccessoryLeftButtons {
            return false
        }
        if lhs.contentAccessoryRightButtons != rhs.contentAccessoryRightButtons {
            return false
        }
        if lhs.activeContentId != rhs.activeContentId {
            return false
        }
        if lhs.visibilityFractionUpdated !== rhs.visibilityFractionUpdated {
            return false
        }
        
        return true
    }
}

public struct PagerComponentPanelState {
    public var topPanelHeight: CGFloat
    
    public init(topPanelHeight: CGFloat) {
        self.topPanelHeight = topPanelHeight
    }
}

public final class PagerComponentViewTag {
    public init() {
    }
}

public enum PagerComponentPanelHideBehavior {
    case hideOnScroll
    case show
    case hide
    case disable
}

public final class PagerComponentContentIcon: Equatable {
    public let id: AnyHashable
    public let imageName: String
    public let title: String
    
    public init(id: AnyHashable, imageName: String, title: String) {
        self.id = id
        self.imageName = imageName
        self.title = title
    }
    
    public static func ==(lhs: PagerComponentContentIcon, rhs: PagerComponentContentIcon) -> Bool {
        if lhs === rhs {
            return true
        }
        if lhs.id != rhs.id {
            return false
        }
        if lhs.imageName != rhs.imageName {
            return false
        }
        if lhs.title != rhs.title {
            return false
        }
        return true
    }
}

public final class PagerComponent<ChildEnvironmentType: Equatable, TopPanelEnvironment: Equatable>: Component {
    public typealias EnvironmentType = ChildEnvironmentType
    
    public let isContentInFocus: Bool
    public let contentInsets: UIEdgeInsets
    public let contents: [AnyComponentWithIdentity<(ChildEnvironmentType, PagerComponentChildEnvironment)>]
    public let contentTopPanels: [AnyComponentWithIdentity<TopPanelEnvironment>]
    public let contentIcons: [PagerComponentContentIcon]
    public let contentAccessoryLeftButtons:[AnyComponentWithIdentity<Empty>]
    public let contentAccessoryRightButtons:[AnyComponentWithIdentity<Empty>]
    public let defaultId: AnyHashable?
    public let contentBackground: AnyComponent<Empty>?
    public let topPanel: AnyComponent<PagerComponentPanelEnvironment<TopPanelEnvironment>>?
    public let externalTopPanelContainer: PagerExternalTopPanelContainer?
    public let bottomPanel: AnyComponent<PagerComponentPanelEnvironment<TopPanelEnvironment>>?
    public let externalBottomPanelContainer: PagerExternalTopPanelContainer?
    public let panelStateUpdated: ((PagerComponentPanelState, Transition) -> Void)?
    public let isTopPanelExpandedUpdated: (Bool, Transition) -> Void
    public let isTopPanelHiddenUpdated: (Bool, Transition) -> Void
    public let contentIdUpdated: (AnyHashable) -> Void
    public let panelHideBehavior: PagerComponentPanelHideBehavior
    public let clipContentToTopPanel: Bool
    
    public init(
        isContentInFocus: Bool,
        contentInsets: UIEdgeInsets,
        contents: [AnyComponentWithIdentity<(ChildEnvironmentType, PagerComponentChildEnvironment)>],
        contentTopPanels: [AnyComponentWithIdentity<TopPanelEnvironment>],
        contentIcons: [PagerComponentContentIcon],
        contentAccessoryLeftButtons: [AnyComponentWithIdentity<Empty>],
        contentAccessoryRightButtons: [AnyComponentWithIdentity<Empty>],
        defaultId: AnyHashable?,
        contentBackground: AnyComponent<Empty>?,
        topPanel: AnyComponent<PagerComponentPanelEnvironment<TopPanelEnvironment>>?,
        externalTopPanelContainer: PagerExternalTopPanelContainer?,
        bottomPanel: AnyComponent<PagerComponentPanelEnvironment<TopPanelEnvironment>>?,
        externalBottomPanelContainer: PagerExternalTopPanelContainer?,
        panelStateUpdated: ((PagerComponentPanelState, Transition) -> Void)?,
        isTopPanelExpandedUpdated: @escaping (Bool, Transition) -> Void,
        isTopPanelHiddenUpdated: @escaping (Bool, Transition) -> Void,
        contentIdUpdated: @escaping (AnyHashable) -> Void,
        panelHideBehavior: PagerComponentPanelHideBehavior,
        clipContentToTopPanel: Bool
    ) {
        self.isContentInFocus = isContentInFocus
        self.contentInsets = contentInsets
        self.contents = contents
        self.contentTopPanels = contentTopPanels
        self.contentIcons = contentIcons
        self.contentAccessoryLeftButtons = contentAccessoryLeftButtons
        self.contentAccessoryRightButtons = contentAccessoryRightButtons
        self.defaultId = defaultId
        self.contentBackground = contentBackground
        self.topPanel = topPanel
        self.externalTopPanelContainer = externalTopPanelContainer
        self.bottomPanel = bottomPanel
        self.externalBottomPanelContainer = externalBottomPanelContainer
        self.panelStateUpdated = panelStateUpdated
        self.isTopPanelExpandedUpdated = isTopPanelExpandedUpdated
        self.isTopPanelHiddenUpdated = isTopPanelHiddenUpdated
        self.contentIdUpdated = contentIdUpdated
        self.panelHideBehavior = panelHideBehavior
        self.clipContentToTopPanel = clipContentToTopPanel
    }
    
    public static func ==(lhs: PagerComponent, rhs: PagerComponent) -> Bool {
        if lhs.isContentInFocus != rhs.isContentInFocus {
            return false
        }
        if lhs.contentInsets != rhs.contentInsets {
            return false
        }
        if lhs.contents != rhs.contents {
            return false
        }
        if lhs.contentTopPanels != rhs.contentTopPanels {
            return false
        }
        if lhs.contentIcons != rhs.contentIcons {
            return false
        }
        if lhs.defaultId != rhs.defaultId {
            return false
        }
        if lhs.contentBackground != rhs.contentBackground {
            return false
        }
        if lhs.topPanel != rhs.topPanel {
            return false
        }
        if lhs.externalTopPanelContainer !== rhs.externalTopPanelContainer {
            return false
        }
        if lhs.bottomPanel != rhs.bottomPanel {
            return false
        }
        if lhs.externalBottomPanelContainer !== rhs.externalBottomPanelContainer {
            return false
        }
        if lhs.panelHideBehavior != rhs.panelHideBehavior {
            return false
        }
        if lhs.clipContentToTopPanel != rhs.clipContentToTopPanel {
            return false
        }
        
        return true
    }
    
    public final class View: UIView, ComponentTaggedView {
        private final class ContentView {
            let view: ComponentHostView<(ChildEnvironmentType, PagerComponentChildEnvironment)>
            var scrollingPanelOffsetToTopEdge: CGFloat = 0.0
            var scrollingPanelOffsetToBottomEdge: CGFloat = .greatestFiniteMagnitude
            var scrollingPanelOffsetFraction: CGFloat = 0.0
            var wantsExclusiveMode: Bool = false
            let scrollToTop = ActionSlot<Void>()
                                            
            init(view: ComponentHostView<(ChildEnvironmentType, PagerComponentChildEnvironment)>) {
                self.view = view
            }
        }
        
        private final class PagerPanGestureRecognizerImpl: DirectionalPanGestureRecognizer, PagerPanGestureRecognizer {
        }
        
        private struct PaneTransitionGestureState {
            var fraction: CGFloat = 0.0
            var nextIndex: Int? = nil
        }
        
        private var contentClippingView: UIView
        private var contentViews: [AnyHashable: ContentView] = [:]
        private var contentBackgroundView: ComponentHostView<Empty>?
        private let topPanelVisibilityFractionUpdated = ActionSlot<(CGFloat, Transition)>()
        private var topPanelView: ComponentHostView<PagerComponentPanelEnvironment<TopPanelEnvironment>>?
        private let bottomPanelVisibilityFractionUpdated = ActionSlot<(CGFloat, Transition)>()
        private var bottomPanelView: ComponentHostView<PagerComponentPanelEnvironment<TopPanelEnvironment>>?
        
        private var topPanelHeight: CGFloat?
        private var bottomPanelHeight: CGFloat?
        
        public private(set) var centralId: AnyHashable?
        private var paneTransitionGestureState: PaneTransitionGestureState?
        
        private var component: PagerComponent<ChildEnvironmentType, TopPanelEnvironment>?
        private weak var state: EmptyComponentState?
        
        private var panRecognizer: PagerPanGestureRecognizerImpl?
        
        private var isTopPanelExpanded: Bool = false
        
        public var topPanelComponentView: UIView? {
            return self.topPanelView?.componentView
        }
        
        override init(frame: CGRect) {
            self.contentClippingView = UIView()
            self.contentClippingView.clipsToBounds = true
            
            super.init(frame: frame)
            
            self.addSubview(self.contentClippingView)
            
            self.disablesInteractiveTransitionGestureRecognizer = true
            
            let panRecognizer = PagerPanGestureRecognizerImpl(target: self, action: #selector(self.panGesture(_:)))
            panRecognizer.direction = .horizontal
            self.panRecognizer = panRecognizer
            self.addGestureRecognizer(panRecognizer)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public func matches(tag: Any) -> Bool {
            if tag is PagerComponentViewTag {
                return true
            }
            
            return false
        }
        
        @objc private func panGesture(_ recognizer: UIPanGestureRecognizer) {
            switch recognizer.state {
            case .began:
                self.paneTransitionGestureState = PaneTransitionGestureState()
            case .changed:
                if let centralId = self.centralId, let component = self.component, let centralIndex = component.contents.firstIndex(where: { $0.id == centralId }), let centralView = self.contentViews[centralId], !centralView.wantsExclusiveMode, var paneTransitionGestureState = self.paneTransitionGestureState, self.bounds.width > 0.0 {
                    var fraction = recognizer.translation(in: self).x / self.bounds.width
                    if centralIndex <= 0 {
                        fraction = min(0.0, fraction)
                    }
                    if centralIndex >= component.contents.count - 1 {
                        fraction = max(0.0, fraction)
                    }
                    paneTransitionGestureState.fraction = fraction
                    
                    let nextIndex: Int
                    if fraction > 0.0 {
                        nextIndex = max(0, centralIndex - 1)
                    } else {
                        nextIndex = min(component.contents.count - 1, centralIndex + 1)
                    }
                    
                    paneTransitionGestureState.nextIndex = nextIndex
                    
                    self.paneTransitionGestureState = paneTransitionGestureState
                    self.state?.updated(transition: .immediate)
                }
            case .ended, .cancelled:
                if let paneTransitionGestureState = self.paneTransitionGestureState {
                    self.paneTransitionGestureState = nil
                    
                    var updateTopPanelExpanded = false
                    
                    if paneTransitionGestureState.fraction != 0.0, let component = self.component, let centralId = self.centralId, let centralIndex = component.contents.firstIndex(where: { $0.id == centralId }) {
                        let fraction = recognizer.translation(in: self).x / self.bounds.width
                        let velocity = recognizer.velocity(in: self)
                        
                        var updatedCentralIndex = centralIndex
                        if abs(velocity.x) > 180.0 {
                            if velocity.x > 0.0 {
                                updatedCentralIndex = max(0, updatedCentralIndex - 1)
                            } else {
                                updatedCentralIndex = min(component.contents.count - 1, updatedCentralIndex + 1)
                            }
                        } else if abs(fraction) > 0.35 {
                            if fraction > 0.0 {
                                updatedCentralIndex = max(0, updatedCentralIndex - 1)
                            } else {
                                updatedCentralIndex = min(component.contents.count - 1, updatedCentralIndex + 1)
                            }
                        }
                        if updatedCentralIndex != centralIndex {
                            self.centralId = component.contents[updatedCentralIndex].id
                            
                            if self.isTopPanelExpanded {
                                updateTopPanelExpanded = true
                            }
                        }
                    }
                    
                    if updateTopPanelExpanded {
                        self.isTopPanelExpandedUpdated(isExpanded: false, transition: Transition(animation: .curve(duration: 0.4, curve: .spring)))
                    } else {
                        self.state?.updated(transition: Transition(animation: .curve(duration: 0.4, curve: .spring)))
                    }
                    if let centralId = self.centralId {
                        self.component?.contentIdUpdated(centralId)
                    }
                }
            default:
                break
            }
        }
        
        public func navigateToContentId(_ id: AnyHashable) {
            guard let centralId = self.centralId, let component = self.component, let _ = component.contents.firstIndex(where: { $0.id == centralId }), let nextIndex = component.contents.firstIndex(where: { $0.id == id }) else {
                return
            }
            
            var updateTopPanelExpanded = false
            if self.centralId != id {
                var paneTransitionGestureState = PaneTransitionGestureState()
                paneTransitionGestureState.fraction = 0.0
                paneTransitionGestureState.nextIndex = nextIndex
                
                self.paneTransitionGestureState = paneTransitionGestureState
                self.state?.updated(transition: .immediate)
                
                self.paneTransitionGestureState = nil
                
                /*paneTransitionGestureState.fraction = 1.0
                
                self.paneTransitionGestureState = paneTransitionGestureState
                self.state?.updated(transition: Transition(animation: .curve(duration: 0.4, curve: .spring)))*/
                
                self.centralId = id
                
                if self.isTopPanelExpanded {
                    updateTopPanelExpanded = true
                }
            } else {
                self.contentViews[id]?.scrollToTop.invoke(Void())
            }
            
            if updateTopPanelExpanded {
                self.isTopPanelExpandedUpdated(isExpanded: false, transition: Transition(animation: .curve(duration: 0.4, curve: .spring)))
            } else {
                self.state?.updated(transition: Transition(animation: .curve(duration: 0.4, curve: .spring)))
            }
            self.component?.contentIdUpdated(id)
        }
        
        func update(component: PagerComponent<ChildEnvironmentType, TopPanelEnvironment>, availableSize: CGSize, state: EmptyComponentState, environment: Environment<EnvironmentType>, transition: Transition) -> CGSize {
            let previousPanelHideBehavior = self.component?.panelHideBehavior
            
            var panelStateTransition = transition
            if let previousPanelHideBehavior = previousPanelHideBehavior, previousPanelHideBehavior != component.panelHideBehavior, panelStateTransition.animation.isImmediate {
                panelStateTransition = Transition(animation: .curve(duration: 0.3, curve: .spring))
            }
            
            self.component = component
            self.state = state
            
            let navigateToContentId: (AnyHashable) -> Void = { [weak self] id in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.navigateToContentId(id)
            }
            
            var centralId: AnyHashable?
            if let current = self.centralId {
                if component.contents.contains(where: { $0.id == current }) {
                    centralId = current
                }
            }
            if centralId == nil {
                if let defaultId = component.defaultId {
                    if component.contents.contains(where: { $0.id == defaultId }) {
                        centralId = defaultId
                    }
                }
                if centralId == nil {
                    centralId = component.contents.first?.id
                }
            }
            
            if self.centralId != centralId {
                self.centralId = centralId
            }
            
            let contentSize = CGSize(width: availableSize.width, height: availableSize.height)
            var contentInsets = component.contentInsets
            contentInsets.bottom = 0.0
            var contentInsetTopPanelValue: CGFloat = 0.0
            
            var scrollingPanelOffsetFraction: CGFloat
            if let centralId = centralId, let centralContentView = self.contentViews[centralId], centralContentView.wantsExclusiveMode {
                scrollingPanelOffsetFraction = 1.0
            } else if case .show = component.panelHideBehavior {
                scrollingPanelOffsetFraction = 0.0
            } else if let centralId = centralId, let centralContentView = self.contentViews[centralId] {
                scrollingPanelOffsetFraction = centralContentView.scrollingPanelOffsetFraction
            } else {
                scrollingPanelOffsetFraction = 0.0
            }
            
            var topPanelVisibility: CGFloat = 1.0
            if let centralId = centralId, let index = component.contents.firstIndex(where: { $0.id == centralId }) {
                if let paneTransitionGestureState = self.paneTransitionGestureState {
                    var nextIndex: Int
                    if paneTransitionGestureState.fraction > 0.0 {
                        nextIndex = max(0, index - 1)
                    } else {
                        nextIndex = min(component.contents.count - 1, index + 1)
                    }
                    if let nextIndexValue = paneTransitionGestureState.nextIndex {
                        nextIndex = nextIndexValue
                    }
                    
                    let nextId = component.contents[nextIndex].id
                    
                    var centralPanelFraction: CGFloat = 1.0
                    if !component.contentTopPanels.contains(where: { $0.id == centralId }) {
                        centralPanelFraction = 0.0
                    }
                    var nextPanelFraction: CGFloat = 1.0
                    if !component.contentTopPanels.contains(where: { $0.id == nextId }) {
                        nextPanelFraction = 0.0
                    }
                    
                    topPanelVisibility = centralPanelFraction * (1.0 - abs(paneTransitionGestureState.fraction)) + nextPanelFraction * abs(paneTransitionGestureState.fraction)
                } else {
                    if !component.contentTopPanels.contains(where: { $0.id == centralId }) {
                        topPanelVisibility = 0.0
                    }
                }
            }
            
            if case .disable = component.panelHideBehavior {
                topPanelVisibility = 0.0
            }
            
            var topPanelHeight: CGFloat = 0.0
            if let topPanel = component.topPanel {
                let effectiveTopPanelOffsetFraction = scrollingPanelOffsetFraction
                
                let topPanelView: ComponentHostView<PagerComponentPanelEnvironment<TopPanelEnvironment>>
                var topPanelTransition = panelStateTransition
                if let current = self.topPanelView {
                    topPanelView = current
                } else {
                    topPanelTransition = .immediate
                    topPanelView = ComponentHostView<PagerComponentPanelEnvironment<TopPanelEnvironment>>()
                    self.topPanelView = topPanelView
                }
                
                let topPanelSuperview = component.externalTopPanelContainer ?? self
                if topPanelView.superview !== topPanelSuperview {
                    topPanelSuperview.addSubview(topPanelView)
                }
                
                var effectivePanelActiveContentId = centralId
                if let centralId = centralId, !component.contentTopPanels.contains(where: { $0.id == centralId }) {
                    effectivePanelActiveContentId = component.contentTopPanels.first?.id
                }
                
                let topPanelSize = topPanelView.update(
                    transition: topPanelTransition,
                    component: topPanel,
                    environment: {
                        PagerComponentPanelEnvironment(
                            isContentInFocus: component.isContentInFocus,
                            contentOffset: 0.0,
                            contentTopPanels: component.contentTopPanels,
                            contentIcons: [],
                            contentAccessoryLeftButtons: [],
                            contentAccessoryRightButtons: [],
                            activeContentId: effectivePanelActiveContentId,
                            navigateToContentId: navigateToContentId,
                            visibilityFractionUpdated: self.topPanelVisibilityFractionUpdated,
                            isExpandedUpdated: { [weak self] isExpanded, transition in
                                guard let strongSelf = self else {
                                    return
                                }
                                strongSelf.isTopPanelExpandedUpdated(isExpanded: isExpanded, transition: transition)
                            }
                        )
                    },
                    containerSize: availableSize
                )
                
                self.topPanelHeight = topPanelSize.height
                
                var topPanelOffset = topPanelSize.height * effectiveTopPanelOffsetFraction
                
                topPanelOffset = min(topPanelSize.height, topPanelOffset + topPanelSize.height * (1.0 - topPanelVisibility))
                
                var topPanelVisibilityFraction: CGFloat = 1.0 - effectiveTopPanelOffsetFraction
                switch component.panelHideBehavior {
                case .hide, .disable:
                    topPanelVisibilityFraction = 0.0
                case .show:
                    topPanelVisibilityFraction = 1.0
                case .hideOnScroll:
                    break
                }
                topPanelVisibilityFraction *= topPanelVisibility
                
                self.topPanelVisibilityFractionUpdated.invoke((topPanelVisibilityFraction, topPanelTransition))
                
                topPanelHeight = max(0.0, topPanelSize.height - topPanelOffset)
                
                if case .hide = component.panelHideBehavior {
                    topPanelOffset = topPanelSize.height
                } else if case .disable = component.panelHideBehavior {
                    topPanelOffset = topPanelSize.height
                }
                
                if component.externalTopPanelContainer != nil {
                    var visibleTopPanelHeight = max(0.0, topPanelSize.height - topPanelOffset)
                    if case .hide = component.panelHideBehavior {
                        visibleTopPanelHeight = 0.0
                    } else if case .disable = component.panelHideBehavior {
                        visibleTopPanelHeight = 0.0
                    }
                    panelStateTransition.setFrame(view: topPanelView, frame: CGRect(origin: CGPoint(), size: CGSize(width: topPanelSize.width, height: visibleTopPanelHeight)))
                    
                    panelStateTransition.setFrame(view: self.contentClippingView, frame: CGRect(origin: .zero, size: contentSize))
                    panelStateTransition.setBounds(view: self.contentClippingView, bounds: CGRect(origin: .zero, size: contentSize))
                } else {
                    panelStateTransition.setFrame(view: topPanelView, frame: CGRect(origin: CGPoint(x: 0.0, y: -topPanelOffset), size: topPanelSize))
                    
                    let clippingOffset: CGFloat = component.clipContentToTopPanel ? topPanelSize.height - topPanelOffset : 0.0
                    panelStateTransition.setFrame(view: self.contentClippingView, frame: CGRect(origin: CGPoint(x: 0.0, y: clippingOffset), size: contentSize))
                    panelStateTransition.setBounds(view: self.contentClippingView, bounds: CGRect(origin: CGPoint(x: 0.0, y: clippingOffset), size: contentSize))
                }
                
                contentInsetTopPanelValue = topPanelSize.height
                contentInsets.top += topPanelSize.height
            } else {
                if let topPanelView = self.topPanelView {
                    self.topPanelView = nil
                    
                    topPanelView.removeFromSuperview()
                }
                
                self.topPanelHeight = 0.0
            }
            
            var bottomPanelOffset: CGFloat = 0.0
            if let bottomPanel = component.bottomPanel {
                let bottomPanelView: ComponentHostView<PagerComponentPanelEnvironment<TopPanelEnvironment>>
                var bottomPanelTransition = panelStateTransition
                if let current = self.bottomPanelView {
                    bottomPanelView = current
                } else {
                    bottomPanelTransition = .immediate
                    bottomPanelView = ComponentHostView<PagerComponentPanelEnvironment<TopPanelEnvironment>>()
                    self.bottomPanelView = bottomPanelView
                }
                
                let bottomPanelSuperview = component.externalBottomPanelContainer ?? self
                if bottomPanelView.superview !== bottomPanelSuperview {
                    bottomPanelSuperview.addSubview(bottomPanelView)
                }
                
                let bottomPanelSize = bottomPanelView.update(
                    transition: bottomPanelTransition,
                    component: bottomPanel,
                    environment: {
                        PagerComponentPanelEnvironment<TopPanelEnvironment>(
                            isContentInFocus: component.isContentInFocus,
                            contentOffset: 0.0,
                            contentTopPanels: [],
                            contentIcons: component.contentIcons,
                            contentAccessoryLeftButtons: component.contentAccessoryLeftButtons,
                            contentAccessoryRightButtons: component.contentAccessoryRightButtons,
                            activeContentId: centralId,
                            navigateToContentId: navigateToContentId,
                            visibilityFractionUpdated: self.bottomPanelVisibilityFractionUpdated,
                            isExpandedUpdated: { _, _ in
                            }
                        )
                    },
                    containerSize: availableSize
                )
                
                self.bottomPanelHeight = bottomPanelSize.height
                
                bottomPanelOffset = bottomPanelSize.height * scrollingPanelOffsetFraction
                if case .hide = component.panelHideBehavior {
                    bottomPanelOffset = bottomPanelSize.height
                } else if case .disable = component.panelHideBehavior {
                    bottomPanelOffset = bottomPanelSize.height
                }
                
                panelStateTransition.setFrame(view: bottomPanelView, frame: CGRect(origin: CGPoint(x: 0.0, y: availableSize.height - bottomPanelSize.height + bottomPanelOffset), size: bottomPanelSize))
                
                contentInsets.bottom += bottomPanelSize.height
            } else {
                if let bottomPanelView = self.bottomPanelView {
                    self.bottomPanelView = nil
                    
                    bottomPanelView.removeFromSuperview()
                }
                
                self.bottomPanelHeight = 0.0
            }
            
            contentInsets.top *= topPanelVisibility
            
            let effectiveTopPanelHeight: CGFloat
            switch component.panelHideBehavior {
            case .hide, .disable:
                effectiveTopPanelHeight = 0.0
            case .show, .hideOnScroll:
                if component.externalTopPanelContainer != nil {
                    effectiveTopPanelHeight = topPanelHeight
                } else {
                    effectiveTopPanelHeight = 0.0
                }
            }
            
            let backgroundFrame = CGRect(origin: CGPoint(x: 0.0, y: effectiveTopPanelHeight), size: CGSize(width: availableSize.width, height: availableSize.height - effectiveTopPanelHeight + bottomPanelOffset))
            if let contentBackground = component.contentBackground {
                let contentBackgroundView: ComponentHostView<Empty>
                var contentBackgroundTransition = panelStateTransition
                if let current = self.contentBackgroundView {
                    contentBackgroundView = current
                } else {
                    contentBackgroundTransition = .immediate
                    contentBackgroundView = ComponentHostView<Empty>()
                    self.contentBackgroundView = contentBackgroundView
                    self.contentClippingView.insertSubview(contentBackgroundView, at: 0)
                }
                let _ = contentBackgroundView.update(
                    transition: contentBackgroundTransition,
                    component: contentBackground,
                    environment: {},
                    containerSize: backgroundFrame.size
                )
                contentBackgroundTransition.setFrame(view: contentBackgroundView, frame: backgroundFrame)
            } else {
                if let contentBackgroundView = self.contentBackgroundView {
                    self.contentBackgroundView = nil
                    contentBackgroundView.removeFromSuperview()
                }
            }

            var validIds: [AnyHashable] = []
            if let centralId = self.centralId, let centralIndex = component.contents.firstIndex(where: { $0.id == centralId }) {
                var referenceFrames: [AnyHashable: CGRect] = [:]
                if case .none = transition.animation {
                } else {
                    for (id, contentView) in self.contentViews {
                        referenceFrames[id] = contentView.view.frame
                    }
                }
                
                for index in 0 ..< component.contents.count {
                    let indexOffset = index - centralIndex
                    let clippedIndexOffset = max(-1, min(1, indexOffset))
                    var checkingContentFrame = CGRect(origin: CGPoint(x: contentSize.width * CGFloat(indexOffset), y: 0.0), size: contentSize)
                    var contentFrame = CGRect(origin: CGPoint(x: contentSize.width * CGFloat(clippedIndexOffset), y: 0.0), size: contentSize)
                    
                    var isInBounds = CGRect(origin: CGPoint(), size: availableSize).intersects(checkingContentFrame)
                    if let paneTransitionGestureState = self.paneTransitionGestureState {
                        checkingContentFrame.origin.x += paneTransitionGestureState.fraction * availableSize.width
                        contentFrame.origin.x += paneTransitionGestureState.fraction * availableSize.width
                        if let nextIndex = paneTransitionGestureState.nextIndex, nextIndex == index {
                            isInBounds = true
                        }
                    }
                    let content = component.contents[index]
                    
                    var isPartOfTransition = false
                    if case .none = transition.animation {
                    } else if self.contentViews[content.id] != nil {
                        isPartOfTransition = true
                    }
                    
                    if isInBounds || isPartOfTransition || content.id == centralId {
                        let id = content.id
                        validIds.append(content.id)
                        
                        var wasAdded = false
                        var contentTransition = transition
                        let contentView: ContentView
                        if let current = self.contentViews[content.id] {
                            contentView = current
                        } else {
                            wasAdded = true
                            contentView = ContentView(view: ComponentHostView<(ChildEnvironmentType, PagerComponentChildEnvironment)>())
                            contentTransition = transition.withAnimation(.none)
                            self.contentViews[content.id] = contentView
                            if let contentBackgroundView = self.contentBackgroundView {
                                self.contentClippingView.insertSubview(contentView.view, aboveSubview: contentBackgroundView)
                            } else {
                                self.contentClippingView.insertSubview(contentView.view, at: 0)
                            }
                        }
                        
                        let childContentInsets = contentInsets
                        if contentView.wantsExclusiveMode {
                            let _ = contentInsetTopPanelValue
                            //childContentInsets.top -= contentInsetTopPanelValue
                        }
                        
                        let pagerChildEnvironment = PagerComponentChildEnvironment(
                            containerInsets: childContentInsets,
                            onChildScrollingUpdate: { [weak self] update in
                                guard let strongSelf = self else {
                                    return
                                }
                                strongSelf.onChildScrollingUpdate(id: id, update: update)
                            },
                            onWantsExclusiveModeUpdated: { [weak self] wantsExclusiveMode in
                                guard let strongSelf = self else {
                                    return
                                }
                                strongSelf.onChildWantsExclusiveModeUpdated(id: id, wantsExclusiveMode: wantsExclusiveMode)
                            },
                            scrollToTop: contentView.scrollToTop
                        )
                        
                        let _ = contentView.view.update(
                            transition: contentTransition,
                            component: content.component,
                            environment: {
                                environment[ChildEnvironmentType.self]
                                pagerChildEnvironment
                            },
                            containerSize: contentFrame.size
                        )
                        
                        if wasAdded {
                            if case .none = transition.animation {
                                contentView.view.frame = contentFrame
                            } else {
                                var referenceDirectionIsRight: Bool?
                                for (previousId, previousFrame) in referenceFrames {
                                    if let previousIndex = component.contents.firstIndex(where: { $0.id == previousId }) {
                                        if previousFrame.minX == 0.0 {
                                            if previousIndex < index {
                                                referenceDirectionIsRight = true
                                            } else {
                                                referenceDirectionIsRight = false
                                            }
                                            break
                                        }
                                    }
                                }
                                if let referenceDirectionIsRight = referenceDirectionIsRight {
                                    contentView.view.frame = contentFrame.offsetBy(dx: referenceDirectionIsRight ? contentFrame.width : (-contentFrame.width), dy: 0.0)
                                    transition.setFrame(view: contentView.view, frame: contentFrame, completion: { [weak self] completed in
                                        if completed && !isInBounds && isPartOfTransition {
                                            DispatchQueue.main.async {
                                                self?.state?.updated(transition: .immediate)
                                            }
                                        }
                                    })
                                } else {
                                    contentView.view.frame = contentFrame
                                }
                            }
                        } else {
                            transition.setFrame(view: contentView.view, frame: contentFrame, completion: { [weak self] completed in
                                if completed && !isInBounds && isPartOfTransition {
                                    DispatchQueue.main.async {
                                        self?.state?.updated(transition: .immediate)
                                    }
                                }
                            })
                        }
                        
                        if let contentViewWithBackground = contentView.view.componentView as? PagerContentViewWithBackground {
                            contentViewWithBackground.pagerUpdateBackground(backgroundFrame: backgroundFrame, transition: contentTransition)
                        }
                    }
                }
            }
            
            var removedIds: [AnyHashable] = []
            for (id, _) in self.contentViews {
                if !validIds.contains(id) {
                    removedIds.append(id)
                }
            }
            for id in removedIds {
                self.contentViews.removeValue(forKey: id)?.view.removeFromSuperview()
            }
            
            if let panelStateUpdated = component.panelStateUpdated {
                panelStateUpdated(
                    PagerComponentPanelState(
                        topPanelHeight: topPanelHeight
                    ),
                    panelStateTransition
                )
            }
            
            return availableSize
        }
        
        private func onChildScrollingUpdate(id: AnyHashable, update: PagerComponentChildEnvironment.ContentScrollingUpdate) {
            guard let contentView = self.contentViews[id] else {
                return
            }
            
            var offsetDelta: CGFloat?
            offsetDelta = (update.absoluteOffsetToTopEdge ?? 0.0) - contentView.scrollingPanelOffsetToTopEdge
            if update.isReset {
                offsetDelta = 0.0
            }
            
            contentView.scrollingPanelOffsetToTopEdge = update.absoluteOffsetToTopEdge ?? 0.0
            contentView.scrollingPanelOffsetToBottomEdge = update.absoluteOffsetToBottomEdge ?? .greatestFiniteMagnitude
            
            if let topPanelHeight = self.topPanelHeight, let bottomPanelHeight = self.bottomPanelHeight {
                var scrollingPanelOffsetFraction = contentView.scrollingPanelOffsetFraction
                
                if topPanelHeight > 0.0, let offsetDelta = offsetDelta {
                    let fractionDelta = -offsetDelta / topPanelHeight
                    scrollingPanelOffsetFraction = max(0.0, min(1.0, contentView.scrollingPanelOffsetFraction - fractionDelta))
                }
                
                if bottomPanelHeight > 0.0 && contentView.scrollingPanelOffsetToBottomEdge < bottomPanelHeight {
                    scrollingPanelOffsetFraction = min(scrollingPanelOffsetFraction, contentView.scrollingPanelOffsetToBottomEdge / bottomPanelHeight)
                } else if topPanelHeight > 0.0 && contentView.scrollingPanelOffsetToTopEdge < topPanelHeight {
                    scrollingPanelOffsetFraction = min(scrollingPanelOffsetFraction, contentView.scrollingPanelOffsetToTopEdge / topPanelHeight)
                }
                
                var transition = update.transition
                if !update.isInteracting {
                    if scrollingPanelOffsetFraction < 0.5 {
                        scrollingPanelOffsetFraction = 0.0
                    } else {
                        scrollingPanelOffsetFraction = 1.0
                    }
                    if case .none = transition.animation {
                    } else {
                        transition = transition.withAnimation(.curve(duration: 0.25, curve: .easeInOut))
                    }
                }
                
                if scrollingPanelOffsetFraction != contentView.scrollingPanelOffsetFraction {
                    contentView.scrollingPanelOffsetFraction = scrollingPanelOffsetFraction
                    self.state?.updated(transition: transition)
                }
                
                if self.isTopPanelExpanded {
                    self.isTopPanelExpanded = false
                    self.component?.isTopPanelExpandedUpdated(self.isTopPanelExpanded, Transition(animation: .curve(duration: 0.25, curve: .easeInOut)))
                }
            }
        }
        
        private func onChildWantsExclusiveModeUpdated(id: AnyHashable, wantsExclusiveMode: Bool) {
            guard let contentView = self.contentViews[id] else {
                return
            }
            
            if contentView.wantsExclusiveMode != wantsExclusiveMode {
                contentView.wantsExclusiveMode = wantsExclusiveMode
                //self.state?.updated(transition: Transition(animation: .curve(duration: 0.4, curve: .spring)))
                self.component?.isTopPanelHiddenUpdated(wantsExclusiveMode, Transition(animation: .curve(duration: 0.4, curve: .spring)))
            }
        }
        
        private func isTopPanelExpandedUpdated(isExpanded: Bool, transition: Transition) {
            if self.isTopPanelExpanded == isExpanded {
                return
            }
            self.isTopPanelExpanded = isExpanded
            
            self.component?.isTopPanelExpandedUpdated(self.isTopPanelExpanded, transition)
        }
        
        public func collapseTopPanel() {
            if !self.isTopPanelExpanded {
                return
            }
            
            self.isTopPanelExpandedUpdated(isExpanded: false, transition: Transition(animation: .curve(duration: 0.4, curve: .spring)))
        }
    }
    
    public func makeView() -> View {
        return View(frame: CGRect())
    }
    
    public func update(view: View, availableSize: CGSize, state: EmptyComponentState, environment: Environment<EnvironmentType>, transition: Transition) -> CGSize {
        return view.update(component: self, availableSize: availableSize, state: state, environment: environment, transition: transition)
    }
}
