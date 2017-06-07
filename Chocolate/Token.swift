//
//  Token.swift
//  MetalScanner
//
//  Created by Hans Sjunesson on 2017-06-06.
//  Copyright © 2017 Hans Sjunnesson. All rights reserved.
//

import Foundation

/// Metal tokens
public enum Token {
    case keyword(String)
    case number(NSNumber)
    case openingParenthesis
    case closingParenthesis
    case comment
    case other(String)
    
    
//    /// "double"
//    case doubleLiteral
//
//    case singleLiteral
//    case float
//    case identifier
//    case nameSep
//    case arrow
//    case plusPlus
//    case minusMinus
//    case arrowStar
//    case dotStar
//    case shiftLeft
//    case shiftRight
//    case integerDecimal
//    case integerOctal
//    case integerHex
//    case equalsEquals
//    case notEquals
//    case andAnd
//    case orOr
//    case multAssign
//    case divAssign
//    case percentAssign
//    case plusAssign
//    case minusAssign
//    case ampAssign
//    case caretAssign
//    case barAssign
//    case dotDotDot
//    case whitespace
//    case comment
//    case singleChar
}
