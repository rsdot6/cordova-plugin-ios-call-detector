#import "IOSCallDetector.h"

@implementation IOSCallDetector

- (void)pluginInitialize {

    self.callObserver = [[CXCallObserver alloc] init];
}

- (void)sendState:(NSString *)state {

    if (!self.callbackId) {
        return;
    }

    CDVPluginResult *pluginResult =
    [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                      messageAsString:state];

    [pluginResult setKeepCallbackAsBool:YES];

    [self.commandDelegate sendPluginResult:pluginResult
                                callbackId:self.callbackId];
}

- (void)startListening:(CDVInvokedUrlCommand *)command {

    self.callbackId = command.callbackId;

    [self.callObserver setDelegate:self queue:nil];

    // Keep callback alive
    CDVPluginResult *result =
    [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];

    [result setKeepCallbackAsBool:YES];

    [self.commandDelegate sendPluginResult:result
                                callbackId:self.callbackId];

    // -----------------------------
    // Check if a call is already active
    // -----------------------------

    NSArray<CXCall *> *calls = self.callObserver.calls;

    if (calls.count == 0) {

        [self sendState:@"IDLE"];
        return;
    }

    for (CXCall *call in calls) {

        if (call.hasEnded) {
            continue;
        }

        if (call.hasConnected) {

            [self sendState:@"OFFHOOK"];
            return;
        }

        if (call.isOutgoing) {

            [self sendState:@"OFFHOOK"];
            return;
        }

        [self sendState:@"RINGING"];
        return;
    }

    [self sendState:@"IDLE"];
}

- (void)callObserver:(CXCallObserver *)callObserver
         callChanged:(CXCall *)call {

    if (call.hasEnded) {

        [self sendState:@"IDLE"];
        return;
    }

    if (call.hasConnected) {

        [self sendState:@"OFFHOOK"];
        return;
    }

    if (call.isOutgoing) {

        [self sendState:@"OFFHOOK"];
        return;
    }

    [self sendState:@"RINGING"];
}

@end
