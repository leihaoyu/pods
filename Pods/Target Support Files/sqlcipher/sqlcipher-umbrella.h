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

#import "sqlcipher.h"
#import "sqlite3.h"
#import "sqlite3ext.h"
#import "sqlite3session.h"

FOUNDATION_EXPORT double sqlcipherVersionNumber;
FOUNDATION_EXPORT const unsigned char sqlcipherVersionString[];

