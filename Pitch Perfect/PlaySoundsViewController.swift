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
    
    @IBAction func reverbButtonTapped(sender: UIButton) {
        playAudioWithReverb()
    }
    
    @IBAction func echoButtonTapped(sender: UIButton) {
        playAudioWithEcho()
    }
    
    
    //MARK: Audio Methods
    
    
    func playAudioWithVariablePitch(pitch: Float) {
        let changePitchEffect = AVAudioUnitTimePitch()
        changePitchEffect.pitch = pitch
        
        playAudioWithEffects([changePitchEffect])
    }
    
    
    func playAudioWithReverb() {
        let reverbEffect = AVAudioUnitReverb()
        reverbEffect.loadFactoryPreset(.Cathedral)
        
        reverbEffect.wetDryMix = 75;
        
        playAudioWithEffects([reverbEffect])
    }
    
    func playAudioWithEcho() {
        let delayEffect = AVAudioUnitDelay()
        delayEffect.feedback = 75
        delayEffect.wetDryMix = 75
        
        let reverbEffect = AVAudioUnitReverb()
        reverbEffect.loadFactoryPreset(.Cathedral)
        
        reverbEffect.wetDryMix = 75;
        
        playAudioWithEffects([delayEffect, reverbEffect])
    }
    
    func playAudioWithEffects(effects: [AVAudioUnit]) {
        audioPlayer.stop()
        audioEngine.stop()
        audioEngine.reset()
        
        let audioPlayerNode = AVAudioPlayerNode()
        audioPlayerNode.volume = 100
        audioEngine.attachNode(audioPlayerNode)
        
        // Apply effects
        var previousEffect: AVAudioUnit! = nil
        
        for unit in effects {
            audioEngine.attachNode(unit);
            
            if previousEffect == nil {
                audioEngine.connect(audioPlayerNode, to: unit, format: nil)
            } else {
                audioEngine.connect(previousEffect, to: unit, format: nil)
            }
            
            previousEffect = unit
        }
        
        audioEngine.connect(previousEffect, to: audioEngine.outputNode, format: nil)
        
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler:nil)
        audioEngine.startAndReturnError(nil)
        
        audioPlayerNode.play()
    }
}
