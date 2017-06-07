//
//  String+Regex.swift
//  MetalScanner
//
//  Created by Hans Sjunesson on 2017-06-06.
//  Copyright © 2017 Hans Sjunnesson. All rights reserved.
//

import Foundation

var expressions = [String: NSRegularExpression]()
public extension String {
    public func match(_ regex: String) -> String? {
        let expression: NSRegularExpression
        if let exists = expressions[regex] {
            expression = exists
        } else {
            expression = try! NSRegularExpression(pattern: "^\(regex)", options: [])
            expressions[regex] = expression
        }
        
        let range = expression.rangeOfFirstMatch(in: self, options: [], range: NSMakeRange(0, self.count))
        if range.location != NSNotFound {
            return (self as NSString).substring(with: range)
        }
        return nil
    }
}
