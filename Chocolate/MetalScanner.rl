//
//  MetalScanner.m
//  Chocolate
//
//  Created by Hans Sjunnesson on 22/12/15.
//  Copyright © 2015 Hans Sjunnesson. All rights reserved.
//

#import "MetalScanner.h"

%%{
    machine Scanner;
    
    access self.;
    
    # Floating literals.
    fract_const = digit* '.' digit+ | digit+ '.';
    exponent = [eE] [+\-]? digit+;
    float_suffix = [flFL];
    
    # Comments
#    c_comment :=
#    any* :>> '*/'
#    @{ fgoto main; };
    
    main := |*
    # Single and double literals
    ( 'L'? "'" ( [^'\\\n] | /\\./ )* "'" )
	{[self token:MetalScannerTokenSingleLiteral];};
	( 'L'? '"' ( [^"\\\n] | /\\./ )* '"' ) 
	{[self token:MetalScannerTokenDoubleLiteral];};
    
    # Identifiers
    ( [a-zA-Z_] [a-zA-Z0-9_]* )
    {[self token:MetalScannerTokenIdentifier];};
    
    # Floating literals.
    ( fract_const exponent? float_suffix? | digit+ exponent float_suffix? )
    {[self token:MetalScannerTokenFloat];};
    
    # Integer decimal. Leading part buffered by float.
    ( ( '0' | [1-9] [0-9]* ) [ulUL]{0,3} )
    {[self token:MetalScannerTokenIntegerDecimal];};
    
    # Integer octal. Leading part buffered by float.
    ( '0' [0-9]+ [ulUL]{0,2} )
    {[self token:MetalScannerTokenIntegerOctal];};

    # Integer hex. Leading 0 buffered by float.
    ( '0' ( 'x' [0-9a-fA-F]+ [ulUL]{0,2} ) )
    {[self token:MetalScannerTokenIntegerHex];};

    # Only buffer the second item, first buffered by symbol. */
    '::' {[self token:MetalScannerTokenNameSep];};
    '==' {[self token:MetalScannerTokenEqualsEquals];};
    '!=' {[self token:MetalScannerTokenNotEquals];};
    '&&' {[self token:MetalScannerTokenAndAnd];};
    '||' {[self token:MetalScannerTokenOrOr];};
    '*=' {[self token:MetalScannerTokenMultAssign];};
    '/=' {[self token:MetalScannerTokenDivAssign];};
    '%=' {[self token:MetalScannerTokenPercentAssign];};
    '+=' {[self token:MetalScannerTokenPlusAssign];};
    '-=' {[self token:MetalScannerTokenMinusAssign];};
    '&=' {[self token:MetalScannerTokenAmpAssign];};
    '^=' {[self token:MetalScannerTokenCaretAssign];};
    '|=' {[self token:MetalScannerTokenBarAssign];};
    '++' {[self token:MetalScannerTokenPlusPlus];};
    '--' {[self token:MetalScannerTokenMinusMinus];};
    '->' {[self token:MetalScannerTokenArrow];};
    '->*' {[self token:MetalScannerTokenArrowStar];};
    '.*' {[self token:MetalScannerTokenDotStar];};
    
    # Three char compounds, first item already buffered. */
    '...' {[self token:MetalScannerTokenDotDotDot];};
    
    # Single char symbols.
    ( punct - [_"'] ) {[self token:MetalScannerTokenSingleChar];};
    
    # Comments
#    '/*' { fgoto c_comment; };
    ( '//' [^\n]* '\n' ) {[self token:MetalScannerTokenComment];};
    
    ( space+ ) {[self token:MetalScannerTokenWhitespace];};
               
    any {[self token:MetalScannerTokenUnknown];};
    *|;
}%%

%% write data nofinal;


@interface MetalScanner ()

@property (nonatomic, assign) int cs;
@property (nonatomic, assign) char *ts;
@property (nonatomic, assign) char *te;
@property (nonatomic, assign) int act;
@property (nonatomic, assign) NSInteger have;
@property (nonatomic, assign) NSInteger count;

@end


#define BUFSIZE 16384

@implementation MetalScannerTokenWrapper
@end

@implementation MetalScanner

- (id)init {
    if ((self = [super init])) {
        %% write init;
        self.tokens = [NSMutableArray new];
    }
    
    return self;
}

- (BOOL)scanSource:(NSString *)source error:(NSError **)error {
    if (![source canBeConvertedToEncoding:NSASCIIStringEncoding]) {
        *error = [NSError errorWithDomain:@"MetalScanner" code:1 userInfo:@{NSLocalizedDescriptionKey: @"Source not ASCII"}];
        return NO;
    }
    
    BOOL done = NO;
    char buf[BUFSIZE];
    
    while (!done) {
        char *p = buf + self.have;
        NSInteger space = BUFSIZE - self.have;
        
        if (space == 0) {
            *error = [NSError errorWithDomain:@"MetalScanner" code:1 userInfo:@{NSLocalizedDescriptionKey: @"Out of buffer space"}];
            return NO;
        }
        
        NSRange leftover;
        NSUInteger len;
        [source getBytes:p maxLength:space usedLength:&len encoding:NSUTF8StringEncoding options:0 range:NSMakeRange(self.have, source.length - self.have) remainingRange:&leftover];
        
        char *pe = p + len;
        char *eof = 0;
        
        if (leftover.length == 0) {
            eof = pe;
            done = YES;
        }
        
        %% write exec;
        
        if (self.cs == Scanner_error) {
            *error = [NSError errorWithDomain:@"MetalScanner" code:1 userInfo:@{NSLocalizedDescriptionKey: @"Parse error"}];
            return NO;
        }
        
        if (self.ts == 0) {
            self.have = 0;
        } else {
            self.have = pe - self.ts;
            memmove(buf, self.ts, self.have);
            self.te -= (self.ts - buf);
            self.ts = buf;
        }
    }
    
    return YES;
}

- (void)token:(MetalScannerToken)token {
    NSInteger len = self.te - self.ts;
    NSRange range = NSMakeRange(self.count, len);
    
    MetalScannerTokenWrapper *wrapper = [MetalScannerTokenWrapper new];
    wrapper.range = range;
    wrapper.token = token;
    
    self.tokens = [self.tokens arrayByAddingObject:wrapper];
    
    self.count += len;
}

@end
