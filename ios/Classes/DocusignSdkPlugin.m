#import "DocusignSdkPlugin.h"
#import <DocuSignSDK/DocuSignSDK.h>

@interface DocusignSdkPlugin ()

@property(strong, nonatomic) UIViewController *viewController;
@property(strong, nonatomic) DSMTemplatesManager *templatesManager;
@property(strong, nonatomic) DSMEnvelopesManager *envelopesManager;

- (void) handleEnvelopeSignedNotification:(NSNotification *)notification;

@end

@implementation DocusignSdkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  channel = [FlutterMethodChannel
      methodChannelWithName:@"docusign_sdk"
            binaryMessenger:[registrar messenger]];

  UIViewController *viewController = [UIApplication sharedApplication].delegate.window.rootViewController;

  DocusignSdkPlugin* instance = [[DocusignSdkPlugin alloc] initWithViewController:viewController];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)initWithViewController:(UIViewController *)viewController {
    self = [super init];
    if (self.templatesManager == nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleEnvelopeSignedNotification:)
                                                             name:DSMSigningCompletedNotification object:nil];
    }
    if (self) {
        self.viewController = viewController;
        self.templatesManager = [[DSMTemplatesManager alloc] init];
        self.envelopesManager = [[DSMEnvelopesManager alloc] init];
    }
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  // 登录
  if ([@"loginWithEmail" isEqualToString:call.method]) {
    NSString *email = call.arguments[@"email"];
    NSString *password = call.arguments[@"password"];
    NSString *integratorKey = call.arguments[@"integratorKey"];
    NSString *host = call.arguments[@"host"];
    [DSMManager loginWithEmail:email password:password integratorKey:integratorKey host:[NSURL URLWithString:host] completion:^(DSMAccountInfo *accountInfo, NSError *error) {
        if (error != nil) {
            result(error);
        }
        else {
            result(nil);
        }
    }];

  // cache template
  } else if ([@"cacheTemplateWithId" isEqualToString:call.method]) {
    NSString *templateId = call.arguments[@"templateId"];
    [self.templatesManager cacheTemplateWithId:templateId completion:^(NSError *error) {
        if (error != nil) {
            NSLog(@"An error occurred cache template with id: %@", error);
            result(@"cache template id failed");
        } else {
            NSLog(@"cache success");
            result(nil);
        }

    }];

  // remove cache template
  } else if ([@"removeCachedTemplateWithId" isEqualToString:call.method]) {
    NSString *templateId = call.arguments[@"templateId"];
    [self.templatesManager removeCachedTemplateWithId:templateId];
    result(nil);
  } else if ([@"renderWithTemplateId" isEqualToString:call.method]) {
      UIViewController* presentedViewController = self.viewController.presentedViewController;
      UIViewController* currentViewController = presentedViewController != nil ? presentedViewController : self.viewController;

      NSString *templateId = call.arguments[@"templateId"];
      NSNumber *animated = call.arguments[@"animated"];
      NSNumber *signingModeValue = call.arguments[@"signingMode"];
      NSDictionary *test = call.arguments[@"envelopeDefaults"];

      NSMutableArray *recipientDefaults = [NSMutableArray arrayWithCapacity:1];

      if (test[@"recipientDefaults"] != nil) {
          for (NSDictionary *item in test[@"recipientDefaults"]) {
            DSMRecipientDefault *recp = [[DSMRecipientDefault alloc] init];
            recp.recipientRoleName = item[@"recipientRoleName"];
            recp.recipientSelectorType = DSMEnvelopeDefaultsUniqueRecipientSelectorTypeRecipientRoleName;
            recp.inPersonSignerName = item[@"inPersonSignerName"];
            recp.recipientName = item[@"recipientName"];
            recp.recipientEmail = item[@"recipientEmail"];
    //             recp.recipientType = item[@"recipientType"];
            recp.recipientType = DSMRecipientTypeInPersonSigner;
//             recp.removeRecipient = item[@"removeRecipient"] ? true : false;
//             NSLog(@'remove: %@', item[@"removeRecipient"]);
            recp.removeRecipient = false;
            [recipientDefaults addObject:recp];
        }
      }

      DSMSigningMode signingMode;
      switch([signingModeValue intValue]) {
        case 0:
            signingMode = DSMSigningModeOnline;
            break;
        case 1:
            signingMode = DSMSigningModeOffline;
            break;
        default:
            break;
      }

      DSMEnvelopeDefaults *envelopeDefaults = [[DSMEnvelopeDefaults alloc] init];
      envelopeDefaults.recipientDefaults = recipientDefaults;
      envelopeDefaults.tabValueDefaults = nil;
      envelopeDefaults.customFields = nil;

      [self.templatesManager presentSendTemplateControllerWithTemplateWithId:templateId
        envelopeDefaults:envelopeDefaults
        pdfToInsert: nil
        insertAtPosition: DSMDocumentInsertAtPositionEnd
        signingMode: signingMode
        presentingController: currentViewController
        animated: animated ? true : false
        completion:^(UIViewController *viewController, NSError *error) {
            if (error != nil) {
                NSLog(@"An error occurred render template with id: %@", error);
                result(error);
            } else {
                result(nil);
            }
        }
       ];

  // 离线的合同id
  } else if ([@"cachedEnvelopeIds" isEqualToString:call.method]) {
    NSArray<NSString *> *envelopeIIds = [self.envelopesManager cachedEnvelopeIds];
    result(envelopeIIds);

  // 移除所有离线的合同
  } else if ([@"removeCachedEnvelopes" isEqualToString:call.method]) {
    [self.envelopesManager removeCachedEnvelopes];
    result(nil);

  // 同步合同
  } else if ([@"syncEnvelopes" isEqualToString:call.method]) {
    [self.envelopesManager syncEnvelopes];
    result(nil);

  // 开始监听
  } else if ([@"starListenEnvelopNotification" isEqualToString:call.method]) {
//       [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleEnvelopeSignedNotification:)
//                                                        name:DSMSigningCompletedNotification object:nil];
      result(nil);
  } else if ([@"removeCachedEnvelopeWithId" isEqualToString:call.method]) {
    NSString *envelopeId = call.arguments[@"envelopeId"];
    [self.envelopesManager removeCachedEnvelopeWithId:envelopeId];
    result(nil);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void) handleEnvelopeSignedNotification:(NSNotification *)notification
{
    //[[[DSMEnvelopesManager alloc] init] syncEnvelopes];
    NSLog(@"handleEnvelopeSignedNotification received: Envelope was signed.");
    NSLog(@"Created a new envelope: %@",notification.userInfo);
    [channel invokeMethod:@"onSigned" arguments:notification.userInfo];
}


@end
