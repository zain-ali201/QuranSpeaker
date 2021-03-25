//
//  ReverseTextVC.h
//  QuranSpeaker
//
//  Created by Apple on 24/03/2021.
//

#import <UIKit/UIKit.h>

@interface ReverseTextVC : UIViewController <UITextViewDelegate> {
    NSMutableArray* _lines;
}

/**
 Returns reversed text.
 The lines is also updated. This array contains all lines. You should pass this array again if you want to append the text.
 */
+(NSString*) reverseText:(NSString*) text withFont:(UIFont*) font carretPosition:(NSRange*) cpos Lines:(NSMutableArray*) lines Bounds:(CGRect) bounds;

+(NSString*) setTextViewText:(NSString*) txt textViewFont:(UIFont*)txtFont TextViewBounds:(CGRect)txtBounds;

@end

