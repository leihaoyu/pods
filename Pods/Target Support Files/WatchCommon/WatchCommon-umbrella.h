#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "TGBridgeActionMediaAttachment.h"
#import "TGBridgeAudioMediaAttachment.h"
#import "TGBridgeBotCommandInfo.h"
#import "TGBridgeBotInfo.h"
#import "TGBridgeChat.h"
#import "TGBridgeChatMessages.h"
#import "TGBridgeCommon.h"
#import "TGBridgeContactMediaAttachment.h"
#import "TGBridgeContext.h"
#import "TGBridgeDocumentMediaAttachment.h"
#import "TGBridgeForwardedMessageMediaAttachment.h"
#import "TGBridgeImageMediaAttachment.h"
#import "TGBridgeLocationMediaAttachment.h"
#import "TGBridgeLocationVenue.h"
#import "TGBridgeMediaAttachment.h"
#import "TGBridgeMessage.h"
#import "TGBridgeMessageEntities.h"
#import "TGBridgeMessageEntitiesAttachment.h"
#import "TGBridgePeerIdAdapter.h"
#import "TGBridgePeerNotificationSettings.h"
#import "TGBridgeReplyMarkupMediaAttachment.h"
#import "TGBridgeReplyMessageMediaAttachment.h"
#import "TGBridgeSubscriptions.h"
#import "TGBridgeUnsupportedMediaAttachment.h"
#import "TGBridgeUser.h"
#import "TGBridgeVideoMediaAttachment.h"
#import "TGBridgeWebPageMediaAttachment.h"
#import "WatchCommon.h"

FOUNDATION_EXPORT double WatchCommonVersionNumber;
FOUNDATION_EXPORT const unsigned char WatchCommonVersionString[];

