#import <Cordova/CDV.h>
#import <CallKit/CallKit.h>

@interface IOSCallDetector : CDVPlugin <CXCallObserverDelegate>

@property (nonatomic, strong) CXCallObserver *callObserver;
@property (nonatomic, strong) NSString *callbackId;

- (void)startListening:(CDVInvokedUrlCommand*)command;

@end
