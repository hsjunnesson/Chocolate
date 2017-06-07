//
//  MetalScanner.swift
//  MetalScanner
//
//  Created by Hans Sjunesson on 2017-06-06.
//  Copyright © 2017 Hans Sjunnesson. All rights reserved.
//

import Foundation

enum ScannerError: Error {
    case unknown
}

typealias TokenGenerator = (String) -> Token?
let TokenList: [(String, TokenGenerator)] = [
    ("[ \t\n]", { _ in nil }),
    ("\\(", { _ in .openingParenthesis }),
    ("\\)", { _ in .closingParenthesis }),
]

/// Wraps a bit of Metal source code.
public struct MetalScanner {
    public let source: String
    public let tokens: [(Token, NSRange)]
    
    public init(source: String) throws {
        self.source = source
        self.tokens = try tokenize(source)
    }
}

private func tokenize(_ source: String) throws -> [(Token, NSRange)] {
    var tokens = [(Token, NSRange)]()
    var content = source
    
    var sourceIndex = 0
    
    while content.count > 0 {
        var matched = false
        for (pattern, generator) in TokenList {
            if let m = content.match(pattern) {
                if let t = generator(m) {
                    tokens.append((t, NSRange(location: sourceIndex, length: m.count)))
                }
                
                let index = content.index(content.startIndex, offsetBy: m.count)
                content = content.substring(from: index)
                
                sourceIndex += m.count
                
                matched = true
                break
            }
        }
        
        if !matched {
            let index = content.index(content.startIndex, offsetBy: 1)
//            tokens.append((.other(content.substring(to: index)), NSRange(location: sourceIndex, length: 1)))
            content = content.substring(from: index)
            sourceIndex += 1
        }
    }
    
    return tokens
}
