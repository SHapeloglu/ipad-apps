#import "SimplePDFSearch.h"
@implementation SimplePDFSearch
+ (NSArray*)searchTerm:(NSString*)term inPath:(NSString*)path { if(!term||![term length])return [NSArray array]; NSData*d=[NSData dataWithContentsOfFile:path]; if(!d)return [NSArray array]; NSString*s=[[[NSString alloc]initWithData:d encoding:NSISOLatin1StringEncoding]autorelease]; if(!s)return [NSArray array]; NSMutableArray*r=[NSMutableArray array]; NSRange search=NSMakeRange(0,[s length]); while(search.length&&[r count]<100){NSRange f=[s rangeOfString:term options:NSCaseInsensitiveSearch range:search]; if(f.location==NSNotFound)break; NSUInteger st=f.location>40?f.location-40:0,en=MIN([s length],NSMaxRange(f)+40); NSString*sn=[[s substringWithRange:NSMakeRange(st,en-st)]stringByReplacingOccurrencesOfString:@"
" withString:@" "];[r addObject:sn];NSUInteger n=NSMaxRange(f);search=NSMakeRange(n,[s length]-n);}return r;}
@end
