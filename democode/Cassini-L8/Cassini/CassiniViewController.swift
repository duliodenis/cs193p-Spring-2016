//
//  CassiniViewController.swift
//  Cassini
//
//  Created by CS193p Instructor.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit

class CassiniViewController: UIViewController, UISplitViewControllerDelegate
{
    // this is just our normal "put constants in a struct" thing
    // but we call it Storyboard, because all the constants in it
    // are strings in our Storyboard

    private struct Storyboard {
        static let ShowImageSegue = "Show Image"
    }

    // prepare for segue is called
    // even if we invoke the segue from code using performSegue (see below)

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Storyboard.ShowImageSegue {
            if let ivc = segue.destinationViewController.contentViewController as? ImageViewController {
                let imageName = (sender as? UIButton)?.currentTitle
                ivc.imageURL = DemoURL.NASAImageNamed(imageName)
                ivc.title = imageName
            }
        }
    }
    
    // we changed the buttons to this target/action method
    // so that we could either
    // a) just set our imageURL in the detail if we're in a split view, or
    // b) cause the segue to happen from code with performSegue
    // to make the latter work, we had to create a segue in our storyboard
    // that was ctrl-dragged from the view controller icon (orange one at the top)

    @IBAction func showImage(sender: UIButton) {
        if let ivc = splitViewController?.viewControllers.last?.contentViewController as? ImageViewController {
            let imageName = sender.currentTitle
            ivc.imageURL = DemoURL.NASAImageNamed(imageName)
            ivc.title = imageName
        } else {
            performSegueWithIdentifier(Storyboard.ShowImageSegue, sender: sender)
        }
    }
    
    // if we are in a split view, we set ourselves as its delegate
    // this is so we can prevent an empty detail from collapsing on top of our master
    // see split view delegate method below
    
    override func viewDidLoad() {
        super.viewDidLoad()
        splitViewController?.delegate = self
    }
    
    // this method lets the split view's delegate
    // collapse the detail on top of the master when it's the detail's time to appear
    // this method returns whether we (the delegate) handled doing this
    // we don't want an empty detail to collapse on top of our master
    // so if the detail is an empty ImageViewController, we return true
    // (which tells the split view controller that we handled the collapse)
    // of course, we didn't actually handle it, we did nothing
    // but that's exactly what we want (i.e. no collapse if the detail ivc is empty)

    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool
    {
        if primaryViewController.contentViewController == self {
            if let ivc = secondaryViewController.contentViewController as? ImageViewController where ivc.imageURL == nil {
                return true
            }
        }
        return false
    }
}

// a little helper extension
// which either returns the view controller you send it to
// or, if you send it to a UINavigationController,
// it returns its visibleViewController
// (if any, otherwise the UINavigationController itself)

extension UIViewController {
    var contentViewController: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController ?? self
        } else {
            return self
        }
    }
}
