//
//  ViewController.swift
//  FaceIt
//
//  Created by CS193p Instructor.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit

class FaceViewController: UIViewController
{
    // MARK: Model

    var expression = FacialExpression(eyes: .Closed, eyeBrows: .Relaxed, mouth: .Smirk) {
        didSet {
            updateUI() // Model changed, so update the View
        }
    }

    // MARK: View

    // the didSet here is called only once
    // when the outlet is connected up by iOS
    @IBOutlet weak var faceView: FaceView! {
        didSet {
            faceView.addGestureRecognizer(UIPinchGestureRecognizer(
                target: faceView, action: #selector(FaceView.changeScale(_:))
            ))

            let happierSwipeGestureRecognizer = UISwipeGestureRecognizer(
                target: self, action: #selector(FaceViewController.increaseHappiness)
            )
            happierSwipeGestureRecognizer.direction = .Up
            faceView.addGestureRecognizer(happierSwipeGestureRecognizer)

            let sadderSwipeGestureRecognizer = UISwipeGestureRecognizer(
                target: self, action: #selector(FaceViewController.decreaseHappiness)
            )
            sadderSwipeGestureRecognizer.direction = .Down
            faceView.addGestureRecognizer(sadderSwipeGestureRecognizer)

            // ADDED AFTER LECTURE 5
            faceView.addGestureRecognizer(UIRotationGestureRecognizer(
                target: self, action: #selector(FaceViewController.changeBrows(_:))
            ))

            updateUI() // View connected for first time, update it from Model
        }
    }
    
    // here the Controller is doing its job
    // of interpreting the Model (expression) for the View (faceView)
    
    private func updateUI() {
        switch expression.eyes {
        case .Open: faceView.eyesOpen = true
        case .Closed: faceView.eyesOpen = false
        case .Squinting: faceView.eyesOpen = false
        }
        faceView.mouthCurvature = mouthCurvatures[expression.mouth] ?? 0.0
        faceView.eyeBrowTilt = eyeBrowTilts[expression.eyeBrows] ?? 0.0
    }
    
    private var mouthCurvatures = [FacialExpression.Mouth.Frown:-1.0,.Grin:0.5,.Smile:1.0,.Smirk:-0.5,.Neutral:0.0 ]
    private var eyeBrowTilts = [FacialExpression.EyeBrows.Relaxed:0.5,.Furrowed:-0.5,.Normal:0.0]
    
    // MARK: Gesture Handlers
    
    // gesture handler for swipe to increase happiness
    // changes the Model (which will, in turn, updateUI())
    func increaseHappiness() {
        expression.mouth = expression.mouth.happierMouth()
    }

    // gesture handler for swipe to decrease happiness
    // changes the Model (which will, in turn, updateUI())
    func decreaseHappiness() {
        expression.mouth = expression.mouth.sadderMouth()
    }
    
    // gesture handler for taps
    //
    // toggles the open/closed state of the eyes in the Model
    // and all changes to the Model automatically updateUI()
    // (see the didSet for the Model var expression above)
    // so our faceView will also change its eyes
    //
    // this handler was added directly in the storyboard
    // by dragging a UITapGestureHandler onto the faceView
    // then ctrl-dragging from the tap gesture
    // (at the top of the scene in the storyboard)
    // here to our Controller
    // (so there's no need to call addGestureRecognizer)
    
    @IBAction func toggleEyes(recognizer: UITapGestureRecognizer) {
        if recognizer.state == .Ended {
            switch expression.eyes {
            case .Open: expression.eyes = .Closed
            case .Closed: expression.eyes = .Open
            case .Squinting: break // we don't know how to toggle "Squinting"
            }
        }
    }
    
    // ADDED AFTER LECTURE 5
    // gesture handler to change the Model's brows with a rotation gesture
    func changeBrows(recognizer: UIRotationGestureRecognizer) {
        switch recognizer.state {
        case .Changed,.Ended:
            if recognizer.rotation > CGFloat(M_PI/4) {
                expression.eyeBrows = expression.eyeBrows.moreRelaxedBrow()
                recognizer.rotation = 0.0
            } else if recognizer.rotation < -CGFloat(M_PI/4) {
                expression.eyeBrows = expression.eyeBrows.moreFurrowedBrow()
                recognizer.rotation = 0.0
            }
        default:
            break
        }
    }
}
