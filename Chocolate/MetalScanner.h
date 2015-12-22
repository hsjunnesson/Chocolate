//
//  MetalScanner.h
//  Chocolate
//
//  Created by Hans Sjunnesson on 22/12/15.
//  Copyright © 2015 Hans Sjunnesson. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MetalScannerToken) {
    MetalScannerTokenUnknown,
    MetalScannerTokenDoubleLiteral,
    MetalScannerTokenSingleLiteral,
    MetalScannerTokenFloat,
    MetalScannerTokenIdentifier,
    MetalScannerTokenNameSep,
    MetalScannerTokenArrow,
    MetalScannerTokenPlusPlus,
    MetalScannerTokenMinusMinus,
    MetalScannerTokenArrowStar,
    MetalScannerTokenDotStar,
    MetalScannerTokenShiftLeft,
    MetalScannerTokenShiftRight,
    MetalScannerTokenIntegerDecimal,
    MetalScannerTokenIntegerOctal,
    MetalScannerTokenIntegerHex,
    MetalScannerTokenEqualsEquals,
    MetalScannerTokenNotEquals,
    MetalScannerTokenAndAnd,
    MetalScannerTokenOrOr,
    MetalScannerTokenMultAssign,
    MetalScannerTokenDivAssign,
    MetalScannerTokenPercentAssign,
    MetalScannerTokenPlusAssign,
    MetalScannerTokenMinusAssign,
    MetalScannerTokenAmpAssign,
    MetalScannerTokenCaretAssign,
    MetalScannerTokenBarAssign,
    MetalScannerTokenDotDotDot,
    MetalScannerTokenWhitespace,
    MetalScannerTokenComment,
    MetalScannerTokenSingleChar
};


@interface MetalScannerTokenWrapper : NSObject

@property (nonatomic, assign) MetalScannerToken token;
@property (nonatomic, assign) NSRange range;

@end


@interface MetalScanner : NSObject

@property (nonatomic, strong) NSArray<MetalScannerTokenWrapper *> * __nonnull tokens;

- (BOOL)scanSource:(NSString * __nonnull)source error:(NSError **)error;

@end
