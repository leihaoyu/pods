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

#import "TGBridgeAudioDecoder.h"
#import "TGBridgeAudioEncoder.h"
#import "WatchBridgeAudioImpl.h"

FOUNDATION_EXPORT double WatchBridgeAudioImplVersionNumber;
FOUNDATION_EXPORT const unsigned char WatchBridgeAudioImplVersionString[];

