//
//  Shortcuts.swift
//  PopcornTime
//
//  Created by Jarosław Pendowski on 17/10/16.
//  Copyright © 2016 Popcorn Time. All rights reserved.
//

import Foundation

func asyncMain(closure: () -> Void) {
    dispatch_async(dispatch_get_main_queue(), closure)
}
