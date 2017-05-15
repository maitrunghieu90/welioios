//
//  SideMenuController.swift
//  SideMenuController
//
//  Created by Teodor Patras on 07.03.15.
//  Copyright (c) 2015 Teodor Patras. All rights reserved.
//

import UIKit

let CenterSegue = "CenterContainment"
let SideSegue   = "SideContainment"

class SideMenuRootController: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK:- Custom types -
    
    enum SideMenuControllerPresentationStyle {
        case underCenterPanelLeft
        case underCenterPanelRight
        case aboveCenterPanelLeft
        case aboveCenterPanelRight
    }
    
    enum CenterContainmentAnimationStyle {
        case circleMaskAnimation
        case fadeAnimation
    }
    
    // MARK:- Constants -
    
    fileprivate let revealAnimationDuration : TimeInterval = 0.3
    fileprivate let hideAnimationDuration   : TimeInterval = 0.2
    
    fileprivate var screenSize = UIScreen.main.bounds.size
    /** 
    If the SideMenuController is the root controller of the app and the
    project target has the "Hide status bar" option enabled, the StatusBarHeight
    constant will be 0. Therefore there is no other way of getting the height except
    hardcoding it.
    **/
    fileprivate let StatusBarHeight = UIApplication.shared.statusBarFrame.size.height > 0 ? UIApplication.shared.statusBarFrame.size.height : 20
    
    // MARK: - Customizable properties -
    
    fileprivate struct PrefsStruct {
        static var percentage: CGFloat  = 0.8
        static var sideStyle            = SideMenuControllerPresentationStyle.underCenterPanelRight
        static var shadow: Bool         = true
        static var panning : Bool       = true
        static var animationStyle       = CenterContainmentAnimationStyle.circleMaskAnimation
        static var menuButtonImage : UIImage?
        
    }
    
    class var menuButtonImage : UIImage? {
        get { return PrefsStruct.menuButtonImage }
        set { PrefsStruct.menuButtonImage = newValue }
    }
    
    class var panningEnabled : Bool {
        get { return PrefsStruct.panning }
        set { PrefsStruct.panning = newValue }
    }
    
    class var presentationStyle : SideMenuControllerPresentationStyle {
        get { return PrefsStruct.sideStyle }
        set { PrefsStruct.sideStyle = newValue }
    }
    
    class var animationStyle : CenterContainmentAnimationStyle
    {
        get { return PrefsStruct.animationStyle }
        set { PrefsStruct.animationStyle = newValue }
    }
    
    class var useShadow: Bool
        {
        get { return PrefsStruct.shadow }
        set { PrefsStruct.shadow = newValue }
    }
    
    /*
    Side Controller Width = sidePercentage * Screen Width
    */
    
    class var sidePercentage: CGFloat
        {
        get { return PrefsStruct.percentage }
        set { PrefsStruct.percentage = newValue }
    }
    
    
    // MARK: -      Private properties -
    
    fileprivate var navigationBar           : UINavigationBar!
    fileprivate var presentationStyle       : SideMenuControllerPresentationStyle!
    fileprivate var animationStyle          : CenterContainmentAnimationStyle!
    fileprivate var percentage              : CGFloat!
    fileprivate var flickVelocity           : CGFloat = 0
    
    fileprivate var centerViewController    : UIViewController!
    fileprivate var sideViewController      : UIViewController!
    fileprivate var statusBarView           : UIView!
    fileprivate var centerPanel             : UIView!
    fileprivate var sidePanel               : UIView!
    fileprivate var centerShadowView        : UIView!
    
    fileprivate var sidePanelVisible        : Bool     = false
    fileprivate var transitionInProgress    : Bool     = false
    fileprivate var landscapeOrientation    : Bool {
        return screenSize.width > screenSize.height
    }
    
    fileprivate var leftSwipeRecognizer     : UISwipeGestureRecognizer!
    fileprivate var rightSwipeGesture       : UISwipeGestureRecognizer!
    fileprivate var panRecognizer           : UIPanGestureRecognizer!
    fileprivate var tapRecognizer           : UITapGestureRecognizer!
    
    fileprivate var canDisplaySideController : Bool{
        get {
            return sideViewController != nil
        }
    }
    
    // MARK:- View lifecycle -

    override func viewDidLoad() {
        super.viewDidLoad()
        /*
        Because custom segue attributes cannot be edited in the Interface Builder,
        the two initial segues from this controller need to have their ids set as
        "CenterContainmentSegue" and "SideContainmentSegue".
        
        After that, the segues from this controller do not require an id anymore, unless you want
        to change the side controller.
        */
        
        self.configure()
        
        self.performSegue(withIdentifier: CenterSegue, sender: nil)
        self.performSegue(withIdentifier: SideSegue, sender: nil)
    }
    
    // MARK:- Orientation changes -
    
    // pre iOS 8
    override func willAnimateRotation(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        
        if toInterfaceOrientation == .portrait || toInterfaceOrientation == .portraitUpsideDown {
            screenSize = UIScreen.main.bounds.size
        } else {
            screenSize = CGSize(width: screenSize.height, height: screenSize.width)
        }
        
        UIView.animate(withDuration: duration, animations: { () -> Void in
            // reposition navigation bar
            self.navigationBar.frame = CGRect(x: 0, y: 0, width: self.screenSize.width, height: self.StatusBarHeight)
            // reposition center panel
            self.centerPanel.frame = self.centerPanelFrame()
            // reposition side panel
            self.sidePanel.frame = self.sidePanelFrame()
            
            // hide or show the view under the status bar
            if self.sidePanelVisible {
                self.statusBarView.alpha = self.landscapeOrientation ? 0 : 1
            }
            
            // reposition the center shadow view
            if let shadow = self.centerShadowView {
                shadow.frame = self.centerPanelFrame()
            }
            
            self.view.layoutIfNeeded()
        })

    }
    
    //  iOS 8 and later
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        self.screenSize = size
        
        coordinator.animate(alongsideTransition: { _ in
            // reposition navigation bar
            self.navigationBar.frame = CGRect(x: 0, y: 0, width: size.width, height: self.StatusBarHeight)
            // reposition center panel
            self.centerPanel.frame = self.centerPanelFrame()
            // reposition side panel
            self.sidePanel.frame = self.sidePanelFrame()
            
            // hide or show the view under the status bar
            if self.sidePanelVisible {
                self.statusBarView.alpha = self.landscapeOrientation ? 0 : 1
            }
            
            // reposition the center shadow view
            if let shadow = self.centerShadowView {
                shadow.frame = self.centerPanelFrame()
            }
            
            self.view.layoutIfNeeded()
            
            }, completion: nil)
    }
    
    // MARK: - Configurations -
    
    fileprivate func configure(){
        
        presentationStyle = SideMenuRootController.presentationStyle
        animationStyle = SideMenuRootController.animationStyle
        percentage = SideMenuRootController.sidePercentage
        
        centerPanel = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
        self.view.addSubview(centerPanel)
        
        navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: StatusBarHeight))
        //self.centerPanel.addSubview(navigationBar)
        
        statusBarView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: StatusBarHeight))
        //self.view.addSubview(statusBarView)
       statusBarView.backgroundColor = UIApplication.shared.statusBarStyle == UIStatusBarStyle.lightContent ? UIColor.black : UIColor.white
        statusBarView.alpha = 0
        
        sidePanel = UIView(frame: self.sidePanelFrame())
        self.view.addSubview(sidePanel)
        sidePanel.clipsToBounds = true
        
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(SideMenuRootController.handleTap(_:)))
        tapRecognizer.delegate = self
        
        if presentationStyle == .underCenterPanelLeft || presentationStyle == .underCenterPanelRight {
            
            panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(SideMenuRootController.handleCenterPanelPan(_:)))
            panRecognizer.delegate = self
            centerPanel.addGestureRecognizer(panRecognizer)
            
            self.view.sendSubview(toBack: sidePanel)
            self.centerPanel.addGestureRecognizer(tapRecognizer)
            
        } else {
            
            centerShadowView = UIView(frame: UIScreen.main.bounds)
            centerShadowView.backgroundColor = UIColor(hue:0, saturation:0, brightness:0.02, alpha:0.8)
            
            panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(SideMenuRootController.handleSidePanelPan(_:)))
            panRecognizer.delegate = self
            self.sidePanel.addGestureRecognizer(panRecognizer)
            self.view.bringSubview(toFront: sidePanel)
            
            leftSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(SideMenuRootController.handleLeftSwipe(_:)))
            leftSwipeRecognizer.direction = UISwipeGestureRecognizerDirection.left
            
            rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(SideMenuRootController.handleRightSwipe(_:)))
            rightSwipeGesture.direction = UISwipeGestureRecognizerDirection.right
            
            self.centerShadowView.addGestureRecognizer(tapRecognizer)
            
            if presentationStyle == .aboveCenterPanelLeft {
                self.centerPanel.addGestureRecognizer(rightSwipeGesture)
                self.centerShadowView.addGestureRecognizer(leftSwipeRecognizer)
            }else{
                self.centerPanel.addGestureRecognizer(leftSwipeRecognizer)
                self.centerShadowView.addGestureRecognizer(rightSwipeGesture)
            }
        }
        
        //self.view.bringSubviewToFront(self.statusBarView)
    }
    
    // MARK:- Containment -
    
    func addNewController(_ controller : UIViewController, forSegueType type:ContainmentSegue.ContainmentSegueType){
        
        if type == .center{
            if let navController = controller as? UINavigationController{
                self.addCenterController(navController)
            } else {
                fatalError("The center view controller must be a navigation controller!")
            }
        }else{
            self.addSideController(controller)
        }
    }
    
    fileprivate func addSideController(_ controller : UIViewController){
        if (sideViewController == nil) {
            sideViewController = controller
            
            sideViewController.view.frame = self.sidePanel.bounds
            
            self.sidePanel.addSubview(sideViewController.view)
            
            self.addChildViewController(sideViewController)
            sideViewController.didMove(toParentViewController: self)
            
            self.sidePanel.isHidden = true
        }
    }
    
    fileprivate func addCenterController(_ controller : UINavigationController){
        
        self.prepareCenterControllerForContainment(controller)
        centerPanel.addSubview(controller.view)
        
        if (centerViewController == nil) {
            centerViewController = controller
            self.addChildViewController(centerViewController)
            centerViewController.didMove(toParentViewController: self)
        }else{
            
            centerViewController.willMove(toParentViewController: nil)
            self.addChildViewController(controller)
            
            
            if (self.sidePanelVisible){
                animateToReveal(false)
            }
        }
    }
    
    fileprivate func triggerFadeAnimationForNewCenterController(_ controller : UINavigationController, completion: @escaping (()->())) {
        
        CATransaction.begin()
        CATransaction.setCompletionBlock (completion)
        
        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.duration = 0.7
        fadeAnimation.fromValue = 0
        fadeAnimation.toValue = 1
        
        fadeAnimation.fillMode = kCAFillModeBoth
        fadeAnimation.isRemovedOnCompletion = true
        
        controller.view.layer.add(fadeAnimation, forKey: "fadeInAnimation")
        
        CATransaction.commit()
    }
    
    fileprivate func triggerMaskAnimationForNewCenterController(_ controller : UINavigationController, completion: @escaping (()->())) {
       
        
        
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        
        let dim = max(screenSize.width, screenSize.height)
        let circleDiameter : CGFloat = 50.0
        let circleFrame = CGRect(x: (screenSize.width - circleDiameter) / 2, y: (screenSize.height - circleDiameter) / 2, width: circleDiameter, height: circleDiameter)
        let circleCenter = CGPoint(x: circleFrame.origin.x + circleDiameter / 2, y: circleFrame.origin.y + circleDiameter / 2)
        
        let circleMaskPathInitial = UIBezierPath(ovalIn: circleFrame)
        let extremePoint = CGPoint(x: circleCenter.x - dim, y: circleCenter.y - dim)
        let radius = sqrt((extremePoint.x * extremePoint.x) + (extremePoint.y * extremePoint.y))
        let circleMaskPathFinal = UIBezierPath(ovalIn: circleFrame.insetBy(dx: -radius, dy: -radius))
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = circleMaskPathFinal.cgPath
        controller.view.layer.mask = maskLayer
        
        let maskLayerAnimation = CABasicAnimation(keyPath: "path")
        maskLayerAnimation.fromValue = circleMaskPathInitial.cgPath
        maskLayerAnimation.toValue = circleMaskPathFinal.cgPath
        maskLayerAnimation.duration = 0.75
        maskLayer.add(maskLayerAnimation, forKey: "path")
        
        CATransaction.commit()
    }
    
    fileprivate func prepareCenterControllerForContainment (_ controller : UINavigationController){
        addMenuButtonToController(controller)
        
        //let frame = CGRectMake(0, StatusBarHeight, CGRectGetWidth(self.centerPanel.frame), CGRectGetHeight(self.centerPanel.frame) - StatusBarHeight)
        
        //controller.view.frame = frame
    }
    
    
    fileprivate func addMenuButtonToController (_ controller : UINavigationController) {
        
        if controller.viewControllers.count == 0 {
            return
        }
        
        let shouldPlaceOnLeftSide = presentationStyle == .underCenterPanelLeft || presentationStyle == .aboveCenterPanelLeft
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        
        if SideMenuRootController.menuButtonImage != nil
        {
            button.setImage(SideMenuRootController.menuButtonImage, for: UIControlState())
        }
        else
        {
            button.backgroundColor = UIColor.purple
        }
        
        button.addTarget(self, action: #selector(SideMenuRootController.toggleSidePanel), for: UIControlEvents.touchUpInside)
        
        let item:UIBarButtonItem = UIBarButtonItem()
        item.customView = button
        
        let spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        spacer.width = -10
        
        if shouldPlaceOnLeftSide {
            controller.childViewControllers[0].navigationItem.leftBarButtonItems = [spacer, item]
        }else{
            controller.childViewControllers[0].navigationItem.rightBarButtonItems = [spacer, item]
        }
    }
    
    fileprivate func prepareSidePanelForDisplay(_ display: Bool){
        self.sidePanel.isHidden = !display
        if presentationStyle == .aboveCenterPanelLeft || presentationStyle == .aboveCenterPanelRight {
            if display {
                if (self.centerShadowView.superview == nil){
                    self.centerShadowView.alpha = 0
                    self.view.insertSubview(self.centerShadowView, belowSubview: self.sidePanel)
                }
            }else{
                self.centerShadowView.removeFromSuperview()
            }
        }else{
            showShadowForCenterPanel(true)
        }
    }
    
    func toggleSidePanel () {
        
        if !transitionInProgress {
            if !sidePanelVisible {
                prepareSidePanelForDisplay(true)
            }
            
            self.animateToReveal(!self.sidePanelVisible)
        }
    }
    
    fileprivate func animateToReveal(_ reveal : Bool){
        
        transitionInProgress = true
        
        self.sidePanelVisible = reveal
        
        if (reveal) {
            if presentationStyle == .aboveCenterPanelLeft || presentationStyle == .aboveCenterPanelRight {
                self.setAboveSidePanelHidden(false, completion: { () -> Void in
                    self.transitionInProgress = false
                    self.centerViewController.view.isUserInteractionEnabled = false
                })
            }else{
                
                self.setUnderSidePanelHidden(false, completion: { () -> () in
                    self.transitionInProgress = false
                    self.centerViewController.view.isUserInteractionEnabled = false
                })
            }
        } else {
            if presentationStyle == .aboveCenterPanelLeft || presentationStyle == .aboveCenterPanelRight {
                self.setAboveSidePanelHidden(true, completion: { () -> Void in
                    self.prepareSidePanelForDisplay(false)
                    self.transitionInProgress = false
                    self.centerViewController.view.isUserInteractionEnabled = true
                })
            }else{
                
                self.setUnderSidePanelHidden(true, completion: { () -> () in
                    self.prepareSidePanelForDisplay(false)
                    self.transitionInProgress = false
                    self.centerViewController.view.isUserInteractionEnabled = true
                })
            }
            
        }
    }
    
    func handleTap(_ gesture : UITapGestureRecognizer) {
        self.animateToReveal(false)
    }
    
    // MARK:- .UnderCenterPanelLeft & Right -
    
    fileprivate func showShadowForCenterPanel(_ shouldShowShadow: Bool) {
        if (shouldShowShadow) {
            centerPanel.layer.shadowOpacity = 0.8
        } else {
            centerPanel.layer.shadowOpacity = 0.0
        }
    }
    
    fileprivate func setUnderSidePanelHidden (_ hidden : Bool, completion : (() -> ())?) {
        var centerPanelFrame = self.centerPanel.frame
        if !hidden {
            if presentationStyle == .underCenterPanelLeft {
                centerPanelFrame.origin.x = self.sidePanel.frame.maxX
            }else{
                centerPanelFrame.origin.x = self.sidePanel.frame.minX - self.centerPanel.frame.width
            }
        } else {
            centerPanelFrame.origin = CGPoint.zero
        }
        
        var duration = hidden ? hideAnimationDuration : revealAnimationDuration
        
        if abs(flickVelocity) > 0 {
            let newDuration = TimeInterval (self.sidePanel.frame.size.width / abs(flickVelocity))
            flickVelocity = 0
            
            if newDuration < duration {
                duration = newDuration
            }
        }
        
        
        UIView.panelAnimation( duration, animations: { () -> () in
            self.centerPanel.frame = centerPanelFrame
            if !self.landscapeOrientation {
                self.statusBarView.alpha = hidden ? 0 : 1
            }
        }) { () -> () in
            if hidden {
                self.showShadowForCenterPanel(false)
            }
            
            if (completion != nil) {
                completion!()
            }
        }
    }
    
    func handleCenterPanelPan(_ recognizer : UIPanGestureRecognizer){
        
        if !self.canDisplaySideController {
            return
        }
        
        self.flickVelocity = recognizer.velocity(in: recognizer.view).x
        let leftToRight = self.flickVelocity > 0
        
        switch(recognizer.state) {
        case .began:
            if (!sidePanelVisible) {
                sidePanelVisible = true
                prepareSidePanelForDisplay(true)
                showShadowForCenterPanel(true)
            }
        case .changed:
            
            let translation = recognizer.translation(in: view).x
            
            // origin.x or origin.x + width
            let xPoint : CGFloat = self.centerPanel.center.x + translation + ((presentationStyle == .underCenterPanelLeft) ? -1  : 1 ) * self.centerPanel.frame.width / 2
            
            
            if xPoint < self.sidePanel.frame.minX || xPoint > self.sidePanel.frame.maxX{
                return
            }
            
            if !landscapeOrientation {
                if presentationStyle == .underCenterPanelLeft {
                    self.statusBarView.alpha = xPoint / self.sidePanel.frame.width
                }else{
                    self.statusBarView.alpha =  1 - (xPoint - self.sidePanel.frame.minX) / self.sidePanel.frame.width
                }
            }
            centerPanel.center.x = self.centerPanel.center.x + translation
            recognizer.setTranslation(CGPoint.zero, in: view)
        default:
            if (sidePanelVisible) {
                
                var shouldOpen = true
                
                if presentationStyle == .underCenterPanelLeft {
                    if leftToRight {
                        // opening
                        shouldOpen = self.centerPanel.frame.minX > self.sidePanel.frame.width * 0.2
                    } else{
                        // closing
                        shouldOpen = self.centerPanel.frame.minX > self.sidePanel.frame.width * 0.8
                    }
                }else{
                    if leftToRight {
                        //closing
                        shouldOpen = self.centerPanel.frame.maxX < self.sidePanel.frame.minX + 0.2 * self.sidePanel.frame.width
                    }else{
                        // opening
                        shouldOpen = self.centerPanel.frame.maxX < self.sidePanel.frame.minX + 0.8 * self.sidePanel.frame.width
                    }
                }
                
                
                animateToReveal(shouldOpen)
            }
        }
    }
    
    // MARK:- .AboveCenterPanelLeft & Right -
    
    func handleSidePanelPan(_ recognizer : UIPanGestureRecognizer){
        
        if !self.canDisplaySideController {
            return
        }
        
        self.flickVelocity = recognizer.velocity(in: recognizer.view).x
        
        let leftToRight = self.flickVelocity > 0
        let sidePanelWidth = self.sidePanel.frame.width
        
        switch recognizer.state {
        case .began:
            
            self.prepareSidePanelForDisplay(true)
            
            break
            
        case .changed:
            
            let translation = recognizer.translation(in: view).x
            let xPoint : CGFloat = self.sidePanel.center.x + translation + (presentationStyle == .aboveCenterPanelLeft ? 1 : -1) * sidePanelWidth / 2
            var alpha : CGFloat
            
            if presentationStyle == .aboveCenterPanelLeft {
                if xPoint <= 0 || xPoint > self.sidePanel.frame.width {
                    return
                }
                alpha = xPoint / self.sidePanel.frame.width
            }else{
                if xPoint <= screenSize.width - sidePanelWidth || xPoint >= screenSize.width
                {
                    return
                }
                alpha = 1 - (xPoint - (screenSize.width - sidePanelWidth)) / sidePanelWidth
            }
            
            if !landscapeOrientation{
                self.statusBarView.alpha = alpha
            }
            
            self.centerShadowView.alpha = alpha
            
            
            self.sidePanel.center.x = sidePanel.center.x + translation
            recognizer.setTranslation(CGPoint.zero, in: view)
            
        default:
            
            let shouldClose = presentationStyle == .aboveCenterPanelLeft ? !leftToRight && self.sidePanel.frame.maxX < sidePanelWidth : leftToRight && self.sidePanel.frame.minX >  (screenSize.width - sidePanelWidth)
            
            self.animateToReveal(!shouldClose)
            
        }
    }
    
    fileprivate func setAboveSidePanelHidden(_ hidden: Bool, completion : ((Void) -> Void)?){
        
        let leftSidePositioned = presentationStyle == .aboveCenterPanelLeft
        var destinationFrame = self.sidePanel.frame
        
        if leftSidePositioned {
            if hidden
            {
                destinationFrame.origin.x = -destinationFrame.width
            } else {
                destinationFrame.origin.x = self.view.frame.minX
            }
        } else {
            if hidden
            {
                destinationFrame.origin.x = self.view.frame.maxX
            } else {
                destinationFrame.origin.x = self.view.frame.maxX - destinationFrame.width
            }
        }
        
        var duration = hidden ? hideAnimationDuration : revealAnimationDuration
        
        if abs(flickVelocity) > 0 {
            let newDuration = TimeInterval (destinationFrame.size.width / abs(flickVelocity))
            flickVelocity = 0
            
            if newDuration < duration {
                duration = newDuration
            }
        }
        
        UIView.panelAnimation(duration, animations: { () -> () in
            self.centerShadowView.alpha = hidden ? 0 : 1
            
            if !self.landscapeOrientation {
                self.statusBarView.alpha = hidden ? 0 : 1
            }
            
            self.sidePanel.frame = destinationFrame
            }, completion: completion)
    }
    
    func handleLeftSwipe(_ recognizer : UIGestureRecognizer){
        if presentationStyle == .aboveCenterPanelLeft {
            if self.sidePanelVisible{
                self.animateToReveal(false)
            }
        }else{
            if !self.sidePanelVisible {
                self.prepareSidePanelForDisplay(true)
                self.animateToReveal(true)
            }
        }
    }
    
    func handleRightSwipe(_ recognizer : UIGestureRecognizer){
        if presentationStyle == .aboveCenterPanelLeft {
            if !self.sidePanelVisible {
                self.prepareSidePanelForDisplay(true)
                self.animateToReveal(true)
            }
        }else{
            if sidePanelVisible {
                self.animateToReveal(false)
            }
        }
    }
    
    // MARK:- UIGestureRecognizerDelegate -
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if gestureRecognizer == self.panRecognizer {
            return SideMenuRootController.panningEnabled
        }else if gestureRecognizer == self.tapRecognizer{
            return self.sidePanelVisible
        } else {
            return true
        }
    }
    
    // MARK:- Helper methods -
    
    fileprivate func centerPanelFrame() -> CGRect {
        
        if (presentationStyle == .underCenterPanelLeft || presentationStyle == .underCenterPanelRight) && sidePanelVisible {
            
            let sidePanelWidth = percentage * min(screenSize.width, screenSize.height)
            
            return CGRect(x: presentationStyle == .underCenterPanelLeft ? sidePanelWidth : -sidePanelWidth, y: 0, width: screenSize.width, height: screenSize.height)
        } else {
            return CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
        }
    }
    
    fileprivate func sidePanelFrame() -> CGRect {
        var sidePanelFrame : CGRect
        
        let panelWidth = percentage * min(screenSize.width, screenSize.height)
        
        if presentationStyle == .underCenterPanelLeft || presentationStyle == .underCenterPanelRight {
            sidePanelFrame = CGRect(x: presentationStyle == .underCenterPanelLeft ? 0 :
                screenSize.width - panelWidth, y: 0, width: panelWidth, height: screenSize.height)
        } else {
            if sidePanelVisible {

                sidePanelFrame = CGRect(x: presentationStyle == .aboveCenterPanelLeft ? 0 : screenSize.width - panelWidth, y: 0, width: panelWidth, height: screenSize.height)
            } else {
                sidePanelFrame = CGRect(x: presentationStyle == .aboveCenterPanelLeft ? -panelWidth : screenSize.width, y: 0, width: panelWidth, height: screenSize.height)
            }
        }
        
        return sidePanelFrame
    }
}

// MARK:- Custom segue  -
@objc(ContainmentSegue)
class ContainmentSegue : UIStoryboardSegue{
    
    enum ContainmentSegueType{
        case center
        case side
    }
    
    fileprivate var type: ContainmentSegueType {
        get {
            if let id = self.identifier {
                if id == SideSegue {
                    return .side
                }else{
                    if self.identifier == "showPayment" {
                        let vc = (self.destination as! UINavigationController).viewControllers.first as! PaymentDetailVC
                        vc.isFromMenu = true
                    }
                    return .center
                }
            }else{
                return .center
            }
        }
    }
    
    override func perform() {
        
        if let sideController = self.source as? SideMenuRootController {
            sideController.addNewController(self.destination , forSegueType: self.type)
        } else {
            fatalError("This type of segue must only be used from a MenuViewController")
        }
    }
}

// MARK:-  Extensions -

extension UIView {
    class func panelAnimation(_ duration : TimeInterval, animations : @escaping (()->()), completion : (()->())?) {
        UIView.animate(withDuration: duration, animations: animations, completion: { _ -> Void in
            if completion != nil {
                completion!()
            }
        }) 
    }
}

extension UIViewController {
    func sideMenuController() -> SideMenuRootController? {
        return sideMenuControllerForViewController(self)
    }
    
    fileprivate func sideMenuControllerForViewController(_ controller : UIViewController) -> SideMenuRootController?
    {
        if let sideController = controller as? SideMenuRootController {
            return sideController
        }
        
        if controller.parent != nil {
            return sideMenuControllerForViewController(controller.parent!)
        }else{
            return nil
        }
    }
}

