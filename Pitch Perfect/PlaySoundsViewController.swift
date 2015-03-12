//
//  PlaySoundsViewController.swift
//  Pitch Perfect
//
//  Created by Vasco d'Orey on 05/03/15.
//  Copyright (c) 2015 Delta Dog. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController, AVAudioPlayerDelegate {


    //MARK: Properties
    
    
    var recordedAudio: RecordedAudio!
    
    var audioPlayer: AVAudioPlayer!
    
    var audioFile: AVAudioFile!
    
    var audioEngine: AVAudioEngine!
    
    
    //MARK: Outlets
    
    
    @IBOutlet weak var stopButton: UIButton!
    
    
    //MARK: View Controller Lifecycle
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if recordedAudio != nil {
            audioPlayer = AVAudioPlayer(contentsOfURL: recordedAudio.filePath, error: nil)
            audioPlayer.enableRate = true
            audioPlayer.volume = 1
            
            audioFile = AVAudioFile(forReading: recordedAudio.filePath, error: nil)
            
            audioEngine = AVAudioEngine()
        } else {
            println("No file to play!")
        }
    }
    
    
    //MARK: Target Actions
    
    
    @IBAction func playChipmunkAudio(sender: UIButton) {
        playAudioWithVariablePitch(1000)
    }
    
    @IBAction func playDarthVaderAudio(sender: UIButton) {
        playAudioWithVariablePitch(-1000)
    }
    
    @IBAction func stopButtonTapped(sender: UIButton) {
        audioPlayer.stop()
        audioEngine.stop()
    }
    
    @IBAction func fastButtonTapped(sender: UIButton) {
        audioPlayer.stop()
        audioPlayer.rate = 2.0
        audioPlayer.play()
    }
    
    @IBAction func slowButtonTapped(sender: UIButton) {
        audioPlayer.stop()
        audioPlayer.rate = 0.5
        audioPlayer.play()
    }
    
    
    //MARK: Audio Methods
    
    
    func playAudioWithVariablePitch(pitch: Float) {
        audioPlayer.stop()
        audioEngine.stop()
        audioEngine.reset()
        
        let audioPlayerNode = AVAudioPlayerNode()
        audioPlayerNode.volume = 10
        audioEngine.attachNode(audioPlayerNode)
        
        let changePitchEffect = AVAudioUnitTimePitch()
        changePitchEffect.pitch = pitch
        audioEngine.attachNode(changePitchEffect)
        
        audioEngine.connect(audioPlayerNode, to: changePitchEffect, format: nil)
        audioEngine.connect(changePitchEffect, to: audioEngine.outputNode, format: nil)
        
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler:nil)
        audioEngine.startAndReturnError(nil)
        
        audioPlayerNode.play()
    }
    
    
}
