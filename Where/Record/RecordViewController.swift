//
//  RecordViewController.swift
//  Where
//
//  Created by Vinicius Silva on 08/11/21.
//

import UIKit
import MapKit

class RecordViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var verticalSpacePlayPause: NSLayoutConstraint!
    
    private let hiddenStopButtonValue: CGFloat = -50
    private let showStopButtonValue: CGFloat = 20
    private var isRecording = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func playPauseButtonPressed(_ sender: Any) {
        animateButtons()
    }
    
    private func animateButtons() {
        self.verticalSpacePlayPause.constant = self.isRecording ? self.hiddenStopButtonValue : self.showStopButtonValue
        let newImage = self.isRecording ? UIImage(systemName: "play.fill")! : UIImage(systemName: "pause.fill")!
        
        self.isRecording.toggle()
        
        UIView.transition(with: self.playPauseButton, duration: 0.3, options: .transitionFlipFromBottom) {
            self.playPauseButton.setImage(newImage, for: .normal)
            self.view.layoutIfNeeded()
        }
    }
}
