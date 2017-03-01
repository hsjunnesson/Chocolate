//
//  MetalDecorating.swift
//  Chocolate
//
//  Created by Hans Sjunnesson on 22/12/15.
//  Copyright © 2015 Hans Sjunnesson. All rights reserved.
//

import Foundation
import UIKit

public enum MetalDecoratingErrorType: Error {
    case sourceNotASCII
}

private let ForegroundColor = UIColor(hexString: "#dcdccc")
private let CommentColor = UIColor(hexString: "#969896")
private let NumberColor = UIColor(hexString: "#de935f")
private let StringColor = UIColor(hexString: "#b5bd68")
private let KeywordColor = UIColor(hexString: "#b294bb")

private let Keywords = ["if","alignof","and","and_eq","asm","auto","bitand","bitor","bool","break","case","catch","char","char16_t","char32_t","class","compl","concept","const","constexpr","const_cast","continue","decltype","default","delete","do","double","dynamic_cast","else","enum","explicit","export","extern","false","float","uint","for","friend","goto","if","inline","int","long","mutable","namespace","new","noexcept","not","not_eq","nullptr","operator","or","or_eq","private","protected","public","register","reinterpret_cast","requires","return","short","signed","sizeof","static","static_assert","static_cast","struct","switch","template","this","thread_local","throw","true","try","typedef","typeid","typename","union","unsigned","using","virtual","void","volatile","wchar_t","while","xor","xor_eq","bool2","bool3","bool4","char2","char3","char4","short2","short3","short4","int2","int3","int4","uchar2","uchar3","uchar4","ushort2","ushort3","ushort4","uint2","uint3","uint4","half2","half3","half4","float2","float3","float4"]


public func decoratedAttributedSource(_ source: String) -> NSAttributedString {
    let attributedString = NSMutableAttributedString(string: source)
    let allRange = NSMakeRange(0, source.characters.count)
    let menloFont = UIFont(name: "Menlo", size: 16)!
    let menloItalicFont = UIFont(name: "Menlo-Italic", size: 16)!
    
    attributedString.beginEditing()
    attributedString.addAttribute(NSForegroundColorAttributeName, value: ForegroundColor, range: allRange)
    attributedString.addAttribute(NSFontAttributeName, value: menloFont, range: NSMakeRange(0, source.characters.count))
    
    do {
        if !source.canBeConverted(to: String.Encoding.ascii) {
            throw MetalDecoratingErrorType.sourceNotASCII
        }
        
        let scanner = MetalScanner()
        try scanner.scanSource(source)
        
        for tokenWrapper in scanner.tokens {
            let range = tokenWrapper.range
            let token = tokenWrapper.token
            
            switch token {
            case .comment:
                attributedString.addAttribute(NSForegroundColorAttributeName, value: CommentColor, range: range)
                attributedString.addAttribute(NSFontAttributeName, value: menloItalicFont, range: range)
            case .float:
                fallthrough
            case .integerDecimal:
                fallthrough
            case .integerHex:
                fallthrough
            case .integerOctal:
                attributedString.addAttribute(NSForegroundColorAttributeName, value: NumberColor, range: range)
            case .identifier:
                let identifier = (source as NSString).substring(with: range)
                if Keywords.contains(identifier) {
                    attributedString.addAttribute(NSForegroundColorAttributeName, value: KeywordColor, range: range)
                }
            default:
                break
            }
        }
    } catch {
        print("MetalScanner error \(error)")
    }
    
    attributedString.endEditing()
    
    return attributedString
}
