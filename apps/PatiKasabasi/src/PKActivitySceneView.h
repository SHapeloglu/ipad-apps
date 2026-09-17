#import <UIKit/UIKit.h>

@interface PKActivitySceneView : UIView {
    NSString *_sceneIdentifier;
}

@property(nonatomic, copy) NSString *sceneIdentifier;

- (id)initWithFrame:(CGRect)frame sceneIdentifier:(NSString *)sceneIdentifier;

@end
