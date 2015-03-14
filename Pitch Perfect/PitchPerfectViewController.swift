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
    
    
    //MARK: - Properties
    
    
    var audioRecorder: AVAudioRecorder!
    
    var recordedAudio: RecordedAudio!
    
    let playSoundsSegueIdentifier = "ShowPlaySoundsViewController"
    
    var isPaused = false
    
    
    //MARK: - Outlets
    
    
    @IBOutlet weak var stopButton: UIButton!
    
    @IBOutlet weak var recordingLabel: UILabel!
    
    @IBOutlet weak var recordAudioButton: UIButton!
    
    @IBOutlet weak var pauseRecordingButton: UIButton!
    
    
    //MARK: - Segue
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == playSoundsSegueIdentifier {
            let destination = segue.destinationViewController as PlaySoundsViewController
            
            destination.recordedAudio = recordedAudio
        } else {
            super.prepareForSegue(segue, sender: sender)
        }
    }
    
    
    //MARK: - Target Actions
    
    
    @IBAction func recordAudio(sender: UIButton) {
        recordAudioButton.hidden = true
        pauseRecordingButton.hidden = false
        stopButton.hidden = false
        recordingLabel.text = "Recording... Tap to pause."
        
        // If we were paused then we can simply call -record() on out audio recorder and return.
        if isPaused {
            audioRecorder.record()
            
            isPaused = false
            
            return
        }

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
    
    @IBAction func pauseRecording(sender: UIButton) {
        pauseRecordingButton.hidden = true
        recordAudioButton.hidden = false
        recordingLabel.text = "Paused... Tap to resume recording."
        isPaused = true

        audioRecorder.pause()
    }
    
    @IBAction func stopRecordingAudio(sender: UIButton) {
        pauseRecordingButton.hidden = true
        recordAudioButton.hidden = false
        stopButton.hidden = true
        recordingLabel.text = "Tap to record"
        
        // Reset `isPaused` to false so we don't run into any unexpected state when returning to this view controller.
        isPaused = false
        
        audioRecorder.stop()
    }
    
    
    //MARK: - AVAudioRecorderDelegate
    
    
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
            isPaused = false
        }
    }
}
