//
//  CMTime.swift
//  Castio
//
//  Created by Xpress Integration on 4/12/19.
//  Copyright © 2019 Xpress Integration. All rights reserved.
//

import Foundation
import AVKit


extension CMTime {
    func toStringFormat() -> String {
        let totalSeconds = Int(CMTimeGetSeconds(self))
        let seconds = totalSeconds % 60
        let minutes = totalSeconds / 60
        let timeFormatString = String(format: "%02d:%02d", minutes, seconds)
        return timeFormatString
    }
}
