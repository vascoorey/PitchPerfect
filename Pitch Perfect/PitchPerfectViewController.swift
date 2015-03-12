//
//  PitchPerfectViewController.swift
//  Pitch Perfect
//
//  Created by Vasco d'Orey on 05/03/15.
//  Copyright (c) 2015 Delta Dog. All rights reserved.
//

import UIKit
import AVFoundation

class PitchPerfectViewController: UIViewController, AVAudioRecorderDelegate {
    
    
    //MARK: Properties
    
    
    var audioRecorder: AVAudioRecorder!
    
    var recordedAudio: RecordedAudio!
    
    let playSoundsSegueIdentifier = "ShowPlaySoundsViewController"
    
    
    //MARK: Outlets
    
    
    @IBOutlet weak var stopButton: UIButton!
    
    @IBOutlet weak var recordingLabel: UILabel!
    
    @IBOutlet weak var recordAudioButton: UIButton!
    
    
    //MARK: Segue
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == playSoundsSegueIdentifier {
            let destination = segue.destinationViewController as PlaySoundsViewController
            
            destination.recordedAudio = recordedAudio
        } else {
            super.prepareForSegue(segue, sender: sender)
        }
    }
    
    
    //MARK: Target Actions
    
    
    @IBAction func recordAudio(sender: UIButton) {
        recordAudioButton.enabled = false
        stopButton.hidden = false
        recordingLabel.text = "Recording..."
        
        if recordedAudio != nil {
            var error: NSError?
            
            if !NSFileManager.defaultManager().removeItemAtURL(recordedAudio.filePath, error: &error) {
                println("Error deleting old recorded audio: \(error!)")
            } else {
                println("Deleted old recorded audio...")
            }
        }
        
        // Store files in the tmp/ directory
        let dirPath = NSTemporaryDirectory()
        
        let currentDate = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "ddMMyyyy-HHmmss"
        let recordingName = formatter.stringFromDate(currentDate)+".wav"
        let filePath = NSURL.fileURLWithPathComponents([dirPath, recordingName])
        
        println(filePath)
        
        // Setup Audio Session
        let session = AVAudioSession.sharedInstance()
        var error: NSError?
        if session.setCategory(AVAudioSessionCategoryPlayAndRecord, error: &error) {
            if var recorder = AVAudioRecorder(URL: filePath, settings: nil, error: &error) {
                audioRecorder = recorder
                audioRecorder.delegate = self
                audioRecorder.meteringEnabled = true
                audioRecorder.prepareToRecord()
                audioRecorder.record()
            } else {
                println("Error setting up AVAudioRecorder: \(error!)")
            }
        } else {
            println("Error setting up session: \(error!)")
        }
    }
    
    @IBAction func stopRecordingAudio(sender: UIButton) {
        recordAudioButton.enabled = true
        stopButton.hidden = true
        recordingLabel.text = "Tap to record"
        
        audioRecorder.stop()
    }
    
    
    //MARK: AVAudioRecorderDelegate
    
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
        if(flag) {
            // Save recorded audio
            recordedAudio = RecordedAudio(title: recorder.url.lastPathComponent!, filePath: recorder.url)
            
            performSegueWithIdentifier(playSoundsSegueIdentifier, sender: self)
        } else {
            println("Something went wrong recording!")
            recordAudioButton.enabled = true
            stopButton.hidden = false
            recordingLabel.hidden = false
        }
    }
}
