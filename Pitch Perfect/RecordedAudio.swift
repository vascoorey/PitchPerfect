//
//  RecordedAudio.swift
//  Pitch Perfect
//
//  Created by Vasco d'Orey on 12/03/15.
//  Copyright (c) 2015 Delta Dog. All rights reserved.
//

import Foundation

class RecordedAudio {
    
    
    //MARK: - Properties
    
    
    var title: String
    
    var filePath: NSURL
    
    
    //MARK: - Constructor
    
    
    init(title: String, filePath: NSURL) {
        self.title = title
        self.filePath = filePath
    }
    
    
}
