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


    //MARK: - Properties
    
    
    var recordedAudio: RecordedAudio!
    
    var audioPlayer: AVAudioPlayer!
    
    var audioFile: AVAudioFile!
    
    var audioEngine: AVAudioEngine!
    
    
    //MARK: - Outlets
    
    
    @IBOutlet weak var stopButton: UIButton!
    
    
    //MARK: - View Controller Lifecycle
    
    
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
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        audioPlayer.stop()
        audioEngine.stop()
    }
    
    
    //MARK: - Target Actions
    
    
    @IBAction func playChipmunkAudio(sender: UIButton) {
        playAudioWithVariablePitch(1000)
    }
    
    @IBAction func playDarthVaderAudio(sender: UIButton) {
        playAudioWithVariablePitch(-1000)
    }
    
    @IBAction func stopPlayingAudio(sender: UIButton) {
        audioPlayer.stop()
        audioEngine.stop()
    }
    
    @IBAction func playFastAudio(sender: UIButton) {
        playAudioWithVariableRate(2.0)
    }
    
    @IBAction func playSlowAudio(sender: UIButton) {
        playAudioWithVariableRate(0.5)
    }
    
    @IBAction func playAudioWithReverb(sender: UIButton) {
        playAudioWithReverb()
    }
    
    @IBAction func playAudioWithEcho(sender: UIButton) {
        playAudioWithEcho()
    }
    
    
    //MARK: - Audio Methods
    
    
    func playAudioWithVariableRate(rate: Float) {
        audioPlayer.stop()
        audioEngine.stop()
        audioPlayer.rate = rate
        audioPlayer.play()

    }
    
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
    
    /**
    Plays audio with an echo effect, which is, in essence, a delay + reverb
    */
    func playAudioWithEcho() {
        let delayEffect = AVAudioUnitDelay()
        delayEffect.feedback = 75
        delayEffect.wetDryMix = 75
        
        let reverbEffect = AVAudioUnitReverb()
        reverbEffect.loadFactoryPreset(.Cathedral)
        
        reverbEffect.wetDryMix = 75;
        
        playAudioWithEffects([delayEffect, reverbEffect])
    }
    
    /**
    Plays audio with the given effects. They will be chained in the order in which they are passed in the effects array.
    
    :param: effects The AVAudioUnit instances that should be chained. This array should contain at least 1 instance of an AVAudioSubclass
    */
    func playAudioWithEffects(effects: [AVAudioUnit]) {
        assert(effects.count > 0)
        
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
