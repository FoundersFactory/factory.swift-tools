//
//  Serialisable.swift
//  MagicPayTrainer
//
//  Created by Sam Houghton on 15/01/2018.
//  Copyright © 2018 Sam Houghton. All rights reserved.
//

import Foundation

protocol Serialisable {
    
    init(withDictionary dictionary: [String: Any])
    
    func serialisableRepresentation() -> [String: Any]
}
