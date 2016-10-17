//
//  APIProtocols.swift
//  PopcornTime
//
//  Created by Jarosław Pendowski on 17/10/16.
//  Copyright © 2016 Popcorn Time. All rights reserved.
//

import Foundation


protocol Titlable {
    var title: String { get }
}

protocol StringValueRepresentable {
    var stringValue: String { get }
}
