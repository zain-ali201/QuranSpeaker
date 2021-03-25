//
//  ReverseTextVC.m
//  QuranSpeaker
//
//  Created by Apple on 24/03/2021.
//

#import "ReverseTextVC.h"

@implementation ReverseTextVC

+(NSString*) setTextViewText:(NSString*) txt textViewFont:(UIFont*)txtFont TextViewBounds:(CGRect)txtBounds
{
    NSMutableArray *lines = [[NSMutableArray alloc] initWithCapacity: 10];
    [lines addObject: [NSMutableString stringWithCapacity: 255]];
    NSString* result = nil;
    NSRange rng;
    NSArray* words = [txt componentsSeparatedByString: @" "];
    //we should do it iteratively (cause it's the simplest way =) )
    for(NSString* word in words)
    {
        NSString *text = [NSString stringWithFormat: @"%@ ", word];
        for(int i=0; i<[word length]; ++i) {
            NSRange r; r.length = 1; r.location = i;
            result = [ReverseTextVC reverseText: [text substringWithRange: r]
                                                                withFont: txtFont
                                                      carretPosition: &rng
                                                                Lines: lines
                                                              Bounds: txtBounds];
        }
    }

    return result;
}


#pragma mark -
#pragma mark Static

+(NSString*) reverseText:(NSString*) text withFont:(UIFont*) font carretPosition:(NSRange*) cpos Lines:(NSMutableArray*) lines Bounds:(CGRect) bounds {
    cpos->length = 0;
    cpos->location = 0;
    if( [text length] ) {
        if( ![text isEqualToString: @"\n"] ) {
            [(NSMutableString*)[lines lastObject] insertString: text
                                                        atIndex: 0];
        } else {
            [lines addObject: [NSMutableString stringWithCapacity: 255]];
        }
    } else {
        //backspace
        //TODO:
        NSRange del_rng;
        del_rng.length = 1;
        del_rng.location = 0;
        if( [(NSMutableString*)[lines lastObject] length] ) {
            [(NSMutableString*)[lines lastObject] deleteCharactersInRange: del_rng];
        }
        if( ![(NSMutableString*)[lines lastObject] length] ) {
            [lines removeLastObject];
        }
    }

    CGSize sz = [(NSString*)[lines lastObject] sizeWithFont: font];
    if( sz.width >= bounds.size.width-15 ) {
        NSMutableArray* words = [NSMutableArray arrayWithArray: [(NSString*)[lines lastObject] componentsSeparatedByString: @" "]];
        NSString* first_word = [words objectAtIndex: 0];
        [words removeObjectAtIndex: 0];
        [(NSMutableString*)[lines lastObject] setString: [words componentsJoinedByString: @" "]];
        [lines addObject: [NSMutableString stringWithString: first_word]];
    }

    NSMutableString* txt = [NSMutableString stringWithCapacity: 100];
    for(int i=0; i<[lines count]; ++i) {
        NSString* line = [lines objectAtIndex: i];
        if( i<([lines count]-1) ) {
            [txt appendFormat: @"%@\n", line];
            cpos->location += [line length]+1;
        } else {
            [txt appendFormat: @"%@", line];
        }
    }

    return txt;
}

@end
