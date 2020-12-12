//
//  NSScrollViewController.swift
//  xApi6000
//
//  Derived from https://www.thetopsites.net/article/58571702.shtml
//

//import Cocoa
import SwiftUI

struct ScrollableView<Content:View>: NSViewControllerRepresentable {
  typealias NSViewControllerType = NSScrollViewController<Content>
  
  var scrollPosition  : Binding<CGPoint?>
  var hasScrollbars   : Bool
  var content         : () -> Content
  
  init(hasScrollbars: Bool = true, scrollTo: Binding<CGPoint?>, @ViewBuilder content: @escaping () -> Content) {
    self.scrollPosition = scrollTo
    self.hasScrollbars  = hasScrollbars
    self.content        = content
  }
  
  func makeNSViewController(context: NSViewControllerRepresentableContext<Self>) -> NSViewControllerType {
    let scrollViewController = NSScrollViewController(rootView: self.content())
    
    scrollViewController.scrollView.hasVerticalScroller   = hasScrollbars
    scrollViewController.scrollView.hasHorizontalScroller = hasScrollbars
    
    return scrollViewController
  }
  
  func updateNSViewController(_ viewController: NSViewControllerType, context: NSViewControllerRepresentableContext<Self>) {
    viewController.hostingController.rootView = self.content()
    
    if let scrollPosition = self.scrollPosition.wrappedValue {
      viewController.scrollView.contentView.scroll(scrollPosition)
      DispatchQueue.main.async(execute: {self.scrollPosition.wrappedValue = nil})
    }
    viewController.hostingController.view.frame.size = viewController.hostingController.view.intrinsicContentSize
  }
}

class NSScrollViewController<Content: View> : NSViewController, ObservableObject {
  var scrollView          = NSScrollView()
  var scrollPosition      : Binding<CGPoint>? = nil
  var hostingController   : NSHostingController<Content>! = nil
  
  @Published var scrollTo : CGFloat? = nil
  
  override func loadView() {
    scrollView.documentView = hostingController.view
    view = scrollView
  }
  
  init(rootView: Content) {
    self.hostingController = NSHostingController<Content>(rootView: rootView)
    super.init(nibName: nil, bundle: nil)
  }
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
}
