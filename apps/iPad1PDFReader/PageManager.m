#import "PageManager.h"
#import <CoreGraphics/CoreGraphics.h>
@implementation PageManager
+ (BOOL)exportDocumentAtPath:(NSString*)path pageOrder:(NSArray*)pages toPath:(NSString*)outPath{CGPDFDocumentRef d=CGPDFDocumentCreateWithURL((CFURLRef)[NSURL fileURLWithPath:path]);if(!d)return NO;CGContextRef c=CGPDFContextCreateWithURL((CFURLRef)[NSURL fileURLWithPath:outPath],NULL,NULL);if(!c){CGPDFDocumentRelease(d);return NO;}for(NSNumber*n in pages){size_t i=[n unsignedIntegerValue];if(i<1||i>CGPDFDocumentGetNumberOfPages(d))continue;CGPDFPageRef p=CGPDFDocumentGetPage(d,i);CGRect b=CGPDFPageGetBoxRect(p,kCGPDFMediaBox);CGPDFContextBeginPage(c,NULL);CGContextSaveGState(c);CGContextTranslateCTM(c,0,b.size.height);CGContextScaleCTM(c,1,-1);CGContextDrawPDFPage(c,p);CGContextRestoreGState(c);CGPDFContextEndPage(c);}CGPDFContextClose(c);CGContextRelease(c);CGPDFDocumentRelease(d);return YES;}
@end
