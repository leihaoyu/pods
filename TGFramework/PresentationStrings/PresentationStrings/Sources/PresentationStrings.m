// Automatically-generated file, do not edit

#import "PresentationStringsKit.h"
#import <NumberPluralizationForm/NumberPluralizationForm.h>
#import <AppBundle/AppBundle.h>

@implementation _FormattedStringRange

- (instancetype _Nonnull)initWithIndex:(NSInteger)index range:(NSRange)range {
    self = [super init];
    if (self != nil) {
        _index = index;
        _range = range;
    }
    return self;
}

@end


@implementation _FormattedString

- (instancetype _Nonnull)initWithString:(NSString * _Nonnull)string
    ranges:(NSArray<_FormattedStringRange *> * _Nonnull)ranges {
    self = [super init];
    if (self != nil) {
        _string = string;
        _ranges = ranges;
    }
    return self;
}

@end

@implementation _PresentationStringsComponent

- (instancetype _Nonnull)initWithLanguageCode:(NSString * _Nonnull)languageCode
    localizedName:(NSString * _Nonnull)localizedName
    pluralizationRulesCode:(NSString * _Nullable)pluralizationRulesCode
    dict:(NSDictionary<NSString *, NSString *> * _Nonnull)dict {
    self = [super init];
    if (self != nil) {
        _languageCode = languageCode;
        _localizedName = localizedName;
        _pluralizationRulesCode = pluralizationRulesCode;
        _dict = dict;
    }
    return self;
}

@end

@interface _PresentationStrings () {
    @public
    NSDictionary<NSNumber *, NSString *> *_idToKey;
}

@end

static NSArray<_FormattedStringRange *> * _Nonnull extractArgumentRanges(NSString * _Nonnull string) {
    static NSRegularExpression *argumentRegex = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        argumentRegex = [NSRegularExpression regularExpressionWithPattern:@"%(((\\d+)\\$)?)([@df])"
            options:0 error:nil];
    });
    
    NSMutableArray<_FormattedStringRange *> *result = [[NSMutableArray alloc] init];
    NSArray<NSTextCheckingResult *> *matches = [argumentRegex matchesInString:string
        options:0 range:NSMakeRange(0, string.length)];
    int index = 0;
    for (NSTextCheckingResult *match in matches) {
        int currentIndex = index;
        NSRange matchRange = [match rangeAtIndex:3]; 
        if (matchRange.location != NSNotFound) {
            currentIndex = [[string substringWithRange:matchRange] intValue] - 1;
        }
        [result addObject:[[_FormattedStringRange alloc] initWithIndex:currentIndex range:[match rangeAtIndex:0]]];
        index += 1;
    }
    
    return result;
}

static _FormattedString * _Nonnull formatWithArgumentRanges(
    NSString * _Nonnull string,
    NSArray<_FormattedStringRange *> * _Nonnull ranges,
    NSArray<NSString *> * _Nonnull arguments
) {
    NSMutableArray<_FormattedStringRange *> *resultingRanges = [[NSMutableArray alloc] init];
    NSMutableString *result = [[NSMutableString alloc] init];
    NSUInteger currentLocation = 0;
    
    for (_FormattedStringRange *range in ranges) {
        if (currentLocation < range.range.location) {
            [result appendString:[string substringWithRange:
                NSMakeRange(currentLocation, range.range.location - currentLocation)]];
        }
        NSString *argument = nil;
        if (range.index >= 0 && range.index < arguments.count) {
            argument = arguments[range.index];
        } else {
            argument = @"?";
        }
        [resultingRanges addObject:[[_FormattedStringRange alloc] initWithIndex:range.index
            range:NSMakeRange(result.length, argument.length)]];
        [result appendString:argument];
        currentLocation = range.range.location + range.range.length;
    }
    
    if (currentLocation != string.length) {
        [result appendString:[string substringWithRange:NSMakeRange(currentLocation, string.length - currentLocation)]];
    }
    
    return [[_FormattedString alloc] initWithString:result ranges:resultingRanges];
}

static NSString * _Nonnull getPluralizationSuffix(uint32_t lc, int32_t value) {
    NumberPluralizationForm pluralizationForm = numberPluralizationForm(lc, value);
    switch (pluralizationForm) {
        case NumberPluralizationFormZero: {
            return @"_0";
        }
        case NumberPluralizationFormOne: {
            return @"_1";
        }
        case NumberPluralizationFormTwo: {
            return @"_2";
        }
        case NumberPluralizationFormFew: {
            return @"_3_10";
        }
        case NumberPluralizationFormMany: {
            return @"_many";
        }
        default: {
            return @"_any";
        }
    }
}

static NSString * _Nonnull getSingle(_PresentationStrings * _Nullable strings, NSString * _Nonnull key,
    bool * _Nullable isFound) {
    NSString *result = nil;
    if (strings) {
        result = strings.primaryComponent.dict[key];
        if (!result) {
            result = strings.secondaryComponent.dict[key];
        }
    }
    if (!result) {
        static NSDictionary<NSString *, NSString *> *fallbackDict = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSString *lprojPath = [getAppBundle() pathForResource:@"en" ofType:@"lproj"];
            if (!lprojPath) {
                return;
            }
            NSBundle *bundle = [NSBundle bundleWithPath:lprojPath];
            if (!bundle) {
                return;
            }
            NSString *stringsPath = [bundle pathForResource:@"Localizable" ofType:@"strings"];
            if (!stringsPath) {
                return;
            }
            fallbackDict = [NSDictionary dictionaryWithContentsOfURL:[NSURL fileURLWithPath:stringsPath]];
        });
        result = fallbackDict[key]; 
    }
    if (!result) {
        result = key;
        if (isFound) {
            *isFound = false;
        }
    } else {
        if (isFound) {
            *isFound = true;
        }
    }
    return result;
}

static NSString * _Nonnull getSingleIndirect(_PresentationStrings * _Nonnull strings, uint32_t keyId) {
    return getSingle(strings, strings->_idToKey[@(keyId)], nil);
}

static NSString * _Nonnull getPluralized(_PresentationStrings * _Nonnull strings, NSString * _Nonnull key,
    int32_t value) {
    NSString *parsedKey = [[NSString alloc] initWithFormat:@"%@%@", key, getPluralizationSuffix(strings.lc, value)];
    bool isFound = false;
    NSString *formatString = getSingle(strings, parsedKey, &isFound);
    if (!isFound) {
        // fall back to English
        parsedKey = [[NSString alloc] initWithFormat:@"%@%@", key, getPluralizationSuffix(0x656e, value)];
        formatString = getSingle(nil, parsedKey, nil);
    }
    NSString *stringValue = formatNumberWithGroupingSeparator(strings.groupingSeparator, value);
    NSArray<_FormattedStringRange *> *argumentRanges = extractArgumentRanges(formatString);
    return formatWithArgumentRanges(formatString, argumentRanges, @[stringValue]).string;
}

static NSString * _Nonnull getPluralizedIndirect(_PresentationStrings * _Nonnull strings, uint32_t keyId,
    int32_t value) {
    return getPluralized(strings, strings->_idToKey[@(keyId)], value);
}
static _FormattedString * _Nonnull getFormatted1(_PresentationStrings * _Nonnull strings,
    uint32_t keyId, id _Nonnull arg0) {
    NSString *formatString = getSingle(strings, strings->_idToKey[@(keyId)], nil);
    NSArray<_FormattedStringRange *> *argumentRanges = extractArgumentRanges(formatString);
    return formatWithArgumentRanges(formatString, argumentRanges, @[[[NSString alloc] initWithFormat:@"%@", arg0]]);
}

static _FormattedString * _Nonnull getFormatted2(_PresentationStrings * _Nonnull strings,
    uint32_t keyId, id _Nonnull arg0, id _Nonnull arg1) {
    NSString *formatString = getSingle(strings, strings->_idToKey[@(keyId)], nil);
    NSArray<_FormattedStringRange *> *argumentRanges = extractArgumentRanges(formatString);
    return formatWithArgumentRanges(formatString, argumentRanges, @[[[NSString alloc] initWithFormat:@"%@", arg0], [[NSString alloc] initWithFormat:@"%@", arg1]]);
}

static _FormattedString * _Nonnull getFormatted3(_PresentationStrings * _Nonnull strings,
    uint32_t keyId, id _Nonnull arg0, id _Nonnull arg1, id _Nonnull arg2) {
    NSString *formatString = getSingle(strings, strings->_idToKey[@(keyId)], nil);
    NSArray<_FormattedStringRange *> *argumentRanges = extractArgumentRanges(formatString);
    return formatWithArgumentRanges(formatString, argumentRanges, @[[[NSString alloc] initWithFormat:@"%@", arg0], [[NSString alloc] initWithFormat:@"%@", arg1], [[NSString alloc] initWithFormat:@"%@", arg2]]);
}

static _FormattedString * _Nonnull getFormatted4(_PresentationStrings * _Nonnull strings,
    uint32_t keyId, id _Nonnull arg0, id _Nonnull arg1, id _Nonnull arg2, id _Nonnull arg3) {
    NSString *formatString = getSingle(strings, strings->_idToKey[@(keyId)], nil);
    NSArray<_FormattedStringRange *> *argumentRanges = extractArgumentRanges(formatString);
    return formatWithArgumentRanges(formatString, argumentRanges, @[[[NSString alloc] initWithFormat:@"%@", arg0], [[NSString alloc] initWithFormat:@"%@", arg1], [[NSString alloc] initWithFormat:@"%@", arg2], [[NSString alloc] initWithFormat:@"%@", arg3]]);
}

static _FormattedString * _Nonnull getFormatted5(_PresentationStrings * _Nonnull strings,
    uint32_t keyId, id _Nonnull arg0, id _Nonnull arg1, id _Nonnull arg2, id _Nonnull arg3, id _Nonnull arg4) {
    NSString *formatString = getSingle(strings, strings->_idToKey[@(keyId)], nil);
    NSArray<_FormattedStringRange *> *argumentRanges = extractArgumentRanges(formatString);
    return formatWithArgumentRanges(formatString, argumentRanges, @[[[NSString alloc] initWithFormat:@"%@", arg0], [[NSString alloc] initWithFormat:@"%@", arg1], [[NSString alloc] initWithFormat:@"%@", arg2], [[NSString alloc] initWithFormat:@"%@", arg3], [[NSString alloc] initWithFormat:@"%@", arg4]]);
}

static _FormattedString * _Nonnull getFormatted6(_PresentationStrings * _Nonnull strings,
    uint32_t keyId, id _Nonnull arg0, id _Nonnull arg1, id _Nonnull arg2, id _Nonnull arg3, id _Nonnull arg4, id _Nonnull arg5) {
    NSString *formatString = getSingle(strings, strings->_idToKey[@(keyId)], nil);
    NSArray<_FormattedStringRange *> *argumentRanges = extractArgumentRanges(formatString);
    return formatWithArgumentRanges(formatString, argumentRanges, @[[[NSString alloc] initWithFormat:@"%@", arg0], [[NSString alloc] initWithFormat:@"%@", arg1], [[NSString alloc] initWithFormat:@"%@", arg2], [[NSString alloc] initWithFormat:@"%@", arg3], [[NSString alloc] initWithFormat:@"%@", arg4], [[NSString alloc] initWithFormat:@"%@", arg5]]);
}

@implementation _PresentationStrings

- (instancetype _Nonnull)initWithPrimaryComponent:(_PresentationStringsComponent * _Nonnull)primaryComponent
    secondaryComponent:(_PresentationStringsComponent * _Nullable)secondaryComponent
    groupingSeparator:(NSString * _Nullable)groupingSeparator {
    self = [super init];
    if (self != nil) {
        static NSDictionary<NSNumber *, NSString *> *idToKey = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSString *dataPath = [getAppBundle() pathForResource:@"PresentationStrings" ofType:@"data"];
            if (!dataPath) {
                assert(false);
                return;
            }
            NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:dataPath]];
            if (!data) {
                assert(false);
                return;
            }
            if (data.length < 4) {
                assert(false);
                return;
            }
            
            NSMutableDictionary<NSNumber *, NSString *> *result = [[NSMutableDictionary alloc] init]; 
            
            uint32_t entryCount = 0;
            [data getBytes:&entryCount range:NSMakeRange(0, 4)];
            
            NSInteger offset = 4;
            for (uint32_t i = 0; i < entryCount; i++) {
                uint8_t stringLength = 0;
                [data getBytes:&stringLength range:NSMakeRange(offset, 1)];
                offset += 1;
                
                NSData *stringData = [data subdataWithRange:NSMakeRange(offset, stringLength)];
                offset += stringLength;
                
                result[@(i)] = [[NSString alloc] initWithData:stringData encoding:NSUTF8StringEncoding];
            }
            idToKey = result;
        });
        _idToKey = idToKey;
    
        _primaryComponent = primaryComponent;
        _secondaryComponent = secondaryComponent;
        _groupingSeparator = groupingSeparator;
        
        if (secondaryComponent) {
            _baseLanguageCode = secondaryComponent.languageCode;
        } else {
            _baseLanguageCode = primaryComponent.languageCode;
        }
        
        NSString *languageCode = nil;
        if (primaryComponent.pluralizationRulesCode) {
            languageCode = primaryComponent.pluralizationRulesCode;
        } else {
            languageCode = primaryComponent.languageCode;
        }
        
        NSString *rawCode = languageCode;
        
        NSRange range = [languageCode rangeOfString:@"_"];
        if (range.location != NSNotFound) {
            rawCode = [rawCode substringWithRange:NSMakeRange(0, range.location)];
        }
        range = [languageCode rangeOfString:@"-"];
        if (range.location != NSNotFound) {
            rawCode = [rawCode substringWithRange:NSMakeRange(0, range.location)];
        }
        
        rawCode = [rawCode lowercaseString];
        
        uint32_t lc = 0;
        for (NSInteger i = 0; i < rawCode.length; i++) {
            lc = (lc << 8) + (uint32_t)[rawCode characterAtIndex:i];
        }
        _lc = lc;
    }
    return self;
}

@end


// AccentColor.Title
NSString * _Nonnull _La(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 0);
}
// AccessDenied.CallMicrophone
NSString * _Nonnull _Lb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1);
}
// AccessDenied.Camera
NSString * _Nonnull _Lc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2);
}
// AccessDenied.CameraDisabled
NSString * _Nonnull _Ld(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3);
}
// AccessDenied.CameraRestricted
NSString * _Nonnull _Le(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4);
}
// AccessDenied.Contacts
NSString * _Nonnull _Lf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5);
}
// AccessDenied.LocationAlwaysDenied
NSString * _Nonnull _Lg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 6);
}
// AccessDenied.LocationDenied
NSString * _Nonnull _Lh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 7);
}
// AccessDenied.LocationDisabled
NSString * _Nonnull _Li(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 8);
}
// AccessDenied.LocationPreciseDenied
NSString * _Nonnull _Lj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 9);
}
// AccessDenied.LocationTracking
NSString * _Nonnull _Lk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 10);
}
// AccessDenied.MicrophoneRestricted
NSString * _Nonnull _Ll(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 11);
}
// AccessDenied.PhotosAndVideos
NSString * _Nonnull _Lm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 12);
}
// AccessDenied.PhotosRestricted
NSString * _Nonnull _Ln(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 13);
}
// AccessDenied.QrCamera
NSString * _Nonnull _Lo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 14);
}
// AccessDenied.QrCode
NSString * _Nonnull _Lp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 15);
}
// AccessDenied.SaveMedia
NSString * _Nonnull _Lq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 16);
}
// AccessDenied.Settings
NSString * _Nonnull _Lr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 17);
}
// AccessDenied.Title
NSString * _Nonnull _Ls(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 18);
}
// AccessDenied.VideoCallCamera
NSString * _Nonnull _Lt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 19);
}
// AccessDenied.VideoMessageCamera
NSString * _Nonnull _Lu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 20);
}
// AccessDenied.VideoMessageMicrophone
NSString * _Nonnull _Lv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 21);
}
// AccessDenied.VideoMicrophone
NSString * _Nonnull _Lw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 22);
}
// AccessDenied.VoiceMicrophone
NSString * _Nonnull _Lx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 23);
}
// AccessDenied.Wallpapers
NSString * _Nonnull _Ly(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 24);
}
// Activity.ChoosingSticker
NSString * _Nonnull _Lz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 25);
}
// Activity.EnjoyingAnimations
_FormattedString * _Nonnull _LA(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 26, _0);
}
// Activity.PlayingGame
NSString * _Nonnull _LB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 27);
}
// Activity.RecordingAudio
NSString * _Nonnull _LC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 28);
}
// Activity.RecordingVideoMessage
NSString * _Nonnull _LD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 29);
}
// Activity.RemindAboutChannel
_FormattedString * _Nonnull _LE(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 30, _0);
}
// Activity.RemindAboutGroup
_FormattedString * _Nonnull _LF(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 31, _0);
}
// Activity.RemindAboutUser
_FormattedString * _Nonnull _LG(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 32, _0);
}
// Activity.TappingInteractiveEmoji
_FormattedString * _Nonnull _LH(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 33, _0);
}
// Activity.UploadingDocument
NSString * _Nonnull _LI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 34);
}
// Activity.UploadingPhoto
NSString * _Nonnull _LJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 35);
}
// Activity.UploadingVideo
NSString * _Nonnull _LK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 36);
}
// Activity.UploadingVideoMessage
NSString * _Nonnull _LL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 37);
}
// AddContact.ContactWillBeSharedAfterMutual
_FormattedString * _Nonnull _LM(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 38, _0);
}
// AddContact.SharedContactException
NSString * _Nonnull _LN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 39);
}
// AddContact.SharedContactExceptionInfo
_FormattedString * _Nonnull _LO(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 40, _0);
}
// AddContact.StatusSuccess
_FormattedString * _Nonnull _LP(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 41, _0);
}
// AppUpgrade.Running
NSString * _Nonnull _LQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 42);
}
// Appearance.AccentColor
NSString * _Nonnull _LR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 43);
}
// Appearance.Animations
NSString * _Nonnull _LS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 44);
}
// Appearance.AppIcon
NSString * _Nonnull _LT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 45);
}
// Appearance.AppIconBlack
NSString * _Nonnull _LU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 46);
}
// Appearance.AppIconClassic
NSString * _Nonnull _LV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 47);
}
// Appearance.AppIconClassicX
NSString * _Nonnull _LW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 48);
}
// Appearance.AppIconDefault
NSString * _Nonnull _LX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 49);
}
// Appearance.AppIconDefaultX
NSString * _Nonnull _LY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 50);
}
// Appearance.AppIconFilled
NSString * _Nonnull _LZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 51);
}
// Appearance.AppIconFilledX
NSString * _Nonnull _Laa(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 52);
}
// Appearance.AppIconNew1
NSString * _Nonnull _Lab(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 53);
}
// Appearance.AppIconNew2
NSString * _Nonnull _Lac(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 54);
}
// Appearance.AppIconPremium
NSString * _Nonnull _Lad(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 55);
}
// Appearance.AppIconTurbo
NSString * _Nonnull _Lae(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 56);
}
// Appearance.AutoNightTheme
NSString * _Nonnull _Laf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 57);
}
// Appearance.AutoNightThemeDisabled
NSString * _Nonnull _Lag(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 58);
}
// Appearance.BubbleCorners.AdjustAdjacent
NSString * _Nonnull _Lah(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 59);
}
// Appearance.BubbleCorners.Apply
NSString * _Nonnull _Lai(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 60);
}
// Appearance.BubbleCorners.Title
NSString * _Nonnull _Laj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 61);
}
// Appearance.BubbleCornersSetting
NSString * _Nonnull _Lak(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 62);
}
// Appearance.ColorTheme
NSString * _Nonnull _Lal(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 63);
}
// Appearance.ColorThemeNight
NSString * _Nonnull _Lam(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 64);
}
// Appearance.CreateTheme
NSString * _Nonnull _Lan(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 65);
}
// Appearance.EditTheme
NSString * _Nonnull _Lao(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 66);
}
// Appearance.LargeEmoji
NSString * _Nonnull _Lap(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 67);
}
// Appearance.NightTheme
NSString * _Nonnull _Laq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 68);
}
// Appearance.Other
NSString * _Nonnull _Lar(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 69);
}
// Appearance.PickAccentColor
NSString * _Nonnull _Las(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 70);
}
// Appearance.Preview
NSString * _Nonnull _Lat(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 71);
}
// Appearance.PreviewIncomingText
NSString * _Nonnull _Lau(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 72);
}
// Appearance.PreviewOutgoingText
NSString * _Nonnull _Lav(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 73);
}
// Appearance.PreviewReplyAuthor
NSString * _Nonnull _Law(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 74);
}
// Appearance.PreviewReplyText
NSString * _Nonnull _Lax(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 75);
}
// Appearance.ReduceMotion
NSString * _Nonnull _Lay(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 76);
}
// Appearance.ReduceMotionInfo
NSString * _Nonnull _Laz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 77);
}
// Appearance.RemoveTheme
NSString * _Nonnull _LaA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 78);
}
// Appearance.RemoveThemeColor
NSString * _Nonnull _LaB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 79);
}
// Appearance.RemoveThemeColorConfirmation
NSString * _Nonnull _LaC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 80);
}
// Appearance.RemoveThemeConfirmation
NSString * _Nonnull _LaD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 81);
}
// Appearance.ShareTheme
NSString * _Nonnull _LaE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 82);
}
// Appearance.ShareThemeColor
NSString * _Nonnull _LaF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 83);
}
// Appearance.TextSize.Apply
NSString * _Nonnull _LaG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 84);
}
// Appearance.TextSize.Automatic
NSString * _Nonnull _LaH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 85);
}
// Appearance.TextSize.Title
NSString * _Nonnull _LaI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 86);
}
// Appearance.TextSize.UseSystem
NSString * _Nonnull _LaJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 87);
}
// Appearance.TextSizeSetting
NSString * _Nonnull _LaK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 88);
}
// Appearance.ThemeCarouselClassic
NSString * _Nonnull _LaL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 89);
}
// Appearance.ThemeCarouselDay
NSString * _Nonnull _LaM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 90);
}
// Appearance.ThemeCarouselNewNight
NSString * _Nonnull _LaN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 91);
}
// Appearance.ThemeCarouselNight
NSString * _Nonnull _LaO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 92);
}
// Appearance.ThemeCarouselNightBlue
NSString * _Nonnull _LaP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 93);
}
// Appearance.ThemeCarouselTintedNight
NSString * _Nonnull _LaQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 94);
}
// Appearance.ThemeDay
NSString * _Nonnull _LaR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 95);
}
// Appearance.ThemeDayClassic
NSString * _Nonnull _LaS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 96);
}
// Appearance.ThemeNight
NSString * _Nonnull _LaT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 97);
}
// Appearance.ThemeNightBlue
NSString * _Nonnull _LaU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 98);
}
// Appearance.ThemePreview.Chat.1.Text
NSString * _Nonnull _LaV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 99);
}
// Appearance.ThemePreview.Chat.2.ReplyName
NSString * _Nonnull _LaW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 100);
}
// Appearance.ThemePreview.Chat.2.Text
NSString * _Nonnull _LaX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 101);
}
// Appearance.ThemePreview.Chat.3.Text
NSString * _Nonnull _LaY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 102);
}
// Appearance.ThemePreview.Chat.3.TextWithLink
NSString * _Nonnull _LaZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 103);
}
// Appearance.ThemePreview.Chat.4.Text
NSString * _Nonnull _Lba(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 104);
}
// Appearance.ThemePreview.Chat.5.Text
NSString * _Nonnull _Lbb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 105);
}
// Appearance.ThemePreview.Chat.6.Text
NSString * _Nonnull _Lbc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 106);
}
// Appearance.ThemePreview.Chat.7.Text
NSString * _Nonnull _Lbd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 107);
}
// Appearance.ThemePreview.ChatList.1.Name
NSString * _Nonnull _Lbe(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 108);
}
// Appearance.ThemePreview.ChatList.1.Text
NSString * _Nonnull _Lbf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 109);
}
// Appearance.ThemePreview.ChatList.2.Name
NSString * _Nonnull _Lbg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 110);
}
// Appearance.ThemePreview.ChatList.2.Text
NSString * _Nonnull _Lbh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 111);
}
// Appearance.ThemePreview.ChatList.3.AuthorName
NSString * _Nonnull _Lbi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 112);
}
// Appearance.ThemePreview.ChatList.3.Name
NSString * _Nonnull _Lbj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 113);
}
// Appearance.ThemePreview.ChatList.3.Text
NSString * _Nonnull _Lbk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 114);
}
// Appearance.ThemePreview.ChatList.4.Name
NSString * _Nonnull _Lbl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 115);
}
// Appearance.ThemePreview.ChatList.4.Text
NSString * _Nonnull _Lbm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 116);
}
// Appearance.ThemePreview.ChatList.5.Name
NSString * _Nonnull _Lbn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 117);
}
// Appearance.ThemePreview.ChatList.5.Text
NSString * _Nonnull _Lbo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 118);
}
// Appearance.ThemePreview.ChatList.6.Name
NSString * _Nonnull _Lbp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 119);
}
// Appearance.ThemePreview.ChatList.6.Text
NSString * _Nonnull _Lbq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 120);
}
// Appearance.ThemePreview.ChatList.7.Name
NSString * _Nonnull _Lbr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 121);
}
// Appearance.ThemePreview.ChatList.7.Text
NSString * _Nonnull _Lbs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 122);
}
// Appearance.TintAllColors
NSString * _Nonnull _Lbt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 123);
}
// Appearance.Title
NSString * _Nonnull _Lbu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 124);
}
// Appearance.VoiceOver.Theme
_FormattedString * _Nonnull _Lbv(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 125, _0);
}
// AppleWatch.ReplyPresets
NSString * _Nonnull _Lbw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 126);
}
// AppleWatch.ReplyPresetsHelp
NSString * _Nonnull _Lbx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 127);
}
// AppleWatch.Title
NSString * _Nonnull _Lby(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 128);
}
// Application.Name
NSString * _Nonnull _Lbz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 129);
}
// Application.Update
NSString * _Nonnull _LbA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 130);
}
// ApplyLanguage.ApplyLanguageAction
NSString * _Nonnull _LbB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 131);
}
// ApplyLanguage.ApplySuccess
NSString * _Nonnull _LbC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 132);
}
// ApplyLanguage.ChangeLanguageAction
NSString * _Nonnull _LbD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 133);
}
// ApplyLanguage.ChangeLanguageAlreadyActive
_FormattedString * _Nonnull _LbE(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 134, _0);
}
// ApplyLanguage.ChangeLanguageOfficialText
_FormattedString * _Nonnull _LbF(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 135, _0);
}
// ApplyLanguage.ChangeLanguageTitle
NSString * _Nonnull _LbG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 136);
}
// ApplyLanguage.ChangeLanguageUnofficialText
_FormattedString * _Nonnull _LbH(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 137, _0, _1);
}
// ApplyLanguage.LanguageNotSupportedError
NSString * _Nonnull _LbI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 138);
}
// ApplyLanguage.UnsufficientDataText
_FormattedString * _Nonnull _LbJ(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 139, _0);
}
// ApplyLanguage.UnsufficientDataTitle
NSString * _Nonnull _LbK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 140);
}
// Appstore.Cloud
NSString * _Nonnull _LbL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 141);
}
// Appstore.Cloud.Profile
NSString * _Nonnull _LbM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 142);
}
// Appstore.Creative
NSString * _Nonnull _LbN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 143);
}
// Appstore.Creative.Chat
NSString * _Nonnull _LbO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 144);
}
// Appstore.Creative.Chat.Name
NSString * _Nonnull _LbP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 145);
}
// Appstore.Fast
NSString * _Nonnull _LbQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 146);
}
// Appstore.Fast.Chat1
NSString * _Nonnull _LbR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 147);
}
// Appstore.Fast.Chat2
NSString * _Nonnull _LbS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 148);
}
// Appstore.Fast.Chat3
NSString * _Nonnull _LbT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 149);
}
// Appstore.Fast.Chat4
NSString * _Nonnull _LbU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 150);
}
// Appstore.Fast.Chat5
NSString * _Nonnull _LbV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 151);
}
// Appstore.Fast.Chat6
NSString * _Nonnull _LbW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 152);
}
// Appstore.Fast.Chat7
NSString * _Nonnull _LbX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 153);
}
// Appstore.Fast.Chat8
NSString * _Nonnull _LbY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 154);
}
// Appstore.Fast.Chat9
NSString * _Nonnull _LbZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 155);
}
// Appstore.Free.Chat
NSString * _Nonnull _Lca(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 156);
}
// Appstore.Free.Chat.Name
NSString * _Nonnull _Lcb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 157);
}
// Appstore.Open
NSString * _Nonnull _Lcc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 158);
}
// Appstore.Powerful
NSString * _Nonnull _Lcd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 159);
}
// Appstore.Powerful.Chat
NSString * _Nonnull _Lce(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 160);
}
// Appstore.Private
NSString * _Nonnull _Lcf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 161);
}
// Appstore.Private.Chat
NSString * _Nonnull _Lcg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 162);
}
// Appstore.Private.Chat.Name
NSString * _Nonnull _Lch(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 163);
}
// Appstore.Public
NSString * _Nonnull _Lci(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 164);
}
// Appstore.Public.Chat1
NSString * _Nonnull _Lcj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 165);
}
// Appstore.Public.Chat2
NSString * _Nonnull _Lck(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 166);
}
// Appstore.Public.Chat3
NSString * _Nonnull _Lcl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 167);
}
// Appstore.Public.IV
NSString * _Nonnull _Lcm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 168);
}
// Appstore.Secure
NSString * _Nonnull _Lcn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 169);
}
// Appstore.Secure.Chat
NSString * _Nonnull _Lco(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 170);
}
// Appstore.Secure.Chat.Name
NSString * _Nonnull _Lcp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 171);
}
// ArchivedChats.IntroText1
NSString * _Nonnull _Lcq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 172);
}
// ArchivedChats.IntroText2
NSString * _Nonnull _Lcr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 173);
}
// ArchivedChats.IntroText3
NSString * _Nonnull _Lcs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 174);
}
// ArchivedChats.IntroTitle1
NSString * _Nonnull _Lct(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 175);
}
// ArchivedChats.IntroTitle2
NSString * _Nonnull _Lcu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 176);
}
// ArchivedChats.IntroTitle3
NSString * _Nonnull _Lcv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 177);
}
// ArchivedPacksAlert.Title
NSString * _Nonnull _Lcw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 178);
}
// Attachment.AllMedia
NSString * _Nonnull _Lcx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 179);
}
// Attachment.Camera
NSString * _Nonnull _Lcy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 180);
}
// Attachment.CameraAccessText
NSString * _Nonnull _Lcz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 181);
}
// Attachment.CancelSelectionAlertNo
NSString * _Nonnull _LcA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 182);
}
// Attachment.CancelSelectionAlertText
NSString * _Nonnull _LcB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 183);
}
// Attachment.CancelSelectionAlertYes
NSString * _Nonnull _LcC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 184);
}
// Attachment.Contact
NSString * _Nonnull _LcD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 185);
}
// Attachment.DeselectedItems
NSString * _Nonnull _LcE(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 186, value);
}
// Attachment.DeselectedPhotos
NSString * _Nonnull _LcF(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 187, value);
}
// Attachment.DeselectedVideos
NSString * _Nonnull _LcG(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 188, value);
}
// Attachment.DisableSpoiler
NSString * _Nonnull _LcH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 189);
}
// Attachment.DiscardPasteboardAlertText
NSString * _Nonnull _LcI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 190);
}
// Attachment.DragToReorder
NSString * _Nonnull _LcJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 191);
}
// Attachment.EnableSpoiler
NSString * _Nonnull _LcK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 192);
}
// Attachment.File
NSString * _Nonnull _LcL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 193);
}
// Attachment.FilesIntro
NSString * _Nonnull _LcM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 194);
}
// Attachment.FilesSearchPlaceholder
NSString * _Nonnull _LcN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 195);
}
// Attachment.Gallery
NSString * _Nonnull _LcO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 196);
}
// Attachment.Grouped
NSString * _Nonnull _LcP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 197);
}
// Attachment.LimitedMediaAccessText
NSString * _Nonnull _LcQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 198);
}
// Attachment.Location
NSString * _Nonnull _LcR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 199);
}
// Attachment.LocationAccessText
NSString * _Nonnull _LcS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 200);
}
// Attachment.LocationAccessTitle
NSString * _Nonnull _LcT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 201);
}
// Attachment.Manage
NSString * _Nonnull _LcU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 202);
}
// Attachment.MediaAccessText
NSString * _Nonnull _LcV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 203);
}
// Attachment.MediaAccessTitle
NSString * _Nonnull _LcW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 204);
}
// Attachment.MediaTypes
NSString * _Nonnull _LcX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 205);
}
// Attachment.MessagePreview
NSString * _Nonnull _LcY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 206);
}
// Attachment.MessagesPreview
NSString * _Nonnull _LcZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 207);
}
// Attachment.MyAlbums
NSString * _Nonnull _Lda(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 208);
}
// Attachment.OpenCamera
NSString * _Nonnull _Ldb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 209);
}
// Attachment.OpenSettings
NSString * _Nonnull _Ldc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 210);
}
// Attachment.Pasteboard
NSString * _Nonnull _Ldd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 211);
}
// Attachment.Poll
NSString * _Nonnull _Lde(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 212);
}
// Attachment.RecentlySentFiles
NSString * _Nonnull _Ldf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 213);
}
// Attachment.SearchWeb
NSString * _Nonnull _Ldg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 214);
}
// Attachment.SelectFromFiles
NSString * _Nonnull _Ldh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 215);
}
// Attachment.SelectFromGallery
NSString * _Nonnull _Ldi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 216);
}
// Attachment.SelectedMedia
NSString * _Nonnull _Ldj(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 217, value);
}
// Attachment.SendAsFile
NSString * _Nonnull _Ldk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 218);
}
// Attachment.SendAsFiles
NSString * _Nonnull _Ldl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 219);
}
// Attachment.Ungrouped
NSString * _Nonnull _Ldm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 220);
}
// AttachmentMenu.File
NSString * _Nonnull _Ldn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 221);
}
// AttachmentMenu.PhotoOrVideo
NSString * _Nonnull _Ldo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 222);
}
// AttachmentMenu.Poll
NSString * _Nonnull _Ldp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 223);
}
// AttachmentMenu.SendAsFile
NSString * _Nonnull _Ldq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 224);
}
// AttachmentMenu.SendAsFiles
NSString * _Nonnull _Ldr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 225);
}
// AttachmentMenu.SendGif
NSString * _Nonnull _Lds(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 226, value);
}
// AttachmentMenu.SendItem
NSString * _Nonnull _Ldt(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 227, value);
}
// AttachmentMenu.SendPhoto
NSString * _Nonnull _Ldu(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 228, value);
}
// AttachmentMenu.SendVideo
NSString * _Nonnull _Ldv(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 229, value);
}
// AttachmentMenu.WebSearch
NSString * _Nonnull _Ldw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 230);
}
// AuthCode.Alert
_FormattedString * _Nonnull _Ldx(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 231, _0);
}
// AuthSessions.AddDevice
NSString * _Nonnull _Ldy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 232);
}
// AuthSessions.AddDevice.InvalidQRCode
NSString * _Nonnull _Ldz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 233);
}
// AuthSessions.AddDevice.ScanInfo
NSString * _Nonnull _LdA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 234);
}
// AuthSessions.AddDevice.ScanInstallInfo
NSString * _Nonnull _LdB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 235);
}
// AuthSessions.AddDevice.ScanTitle
NSString * _Nonnull _LdC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 236);
}
// AuthSessions.AddDevice.UrlLoginHint
NSString * _Nonnull _LdD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 237);
}
// AuthSessions.AddDeviceIntro.Action
NSString * _Nonnull _LdE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 238);
}
// AuthSessions.AddDeviceIntro.Text1
NSString * _Nonnull _LdF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 239);
}
// AuthSessions.AddDeviceIntro.Text2
NSString * _Nonnull _LdG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 240);
}
// AuthSessions.AddDeviceIntro.Text3
NSString * _Nonnull _LdH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 241);
}
// AuthSessions.AddDeviceIntro.Title
NSString * _Nonnull _LdI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 242);
}
// AuthSessions.AddedDeviceTerminate
NSString * _Nonnull _LdJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 243);
}
// AuthSessions.AddedDeviceTitle
NSString * _Nonnull _LdK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 244);
}
// AuthSessions.AppUnofficial
_FormattedString * _Nonnull _LdL(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 245, _0);
}
// AuthSessions.CurrentSession
NSString * _Nonnull _LdM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 246);
}
// AuthSessions.DevicesTitle
NSString * _Nonnull _LdN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 247);
}
// AuthSessions.EmptyText
NSString * _Nonnull _LdO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 248);
}
// AuthSessions.EmptyTitle
NSString * _Nonnull _LdP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 249);
}
// AuthSessions.HeaderInfo
NSString * _Nonnull _LdQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 250);
}
// AuthSessions.IncompleteAttempts
NSString * _Nonnull _LdR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 251);
}
// AuthSessions.IncompleteAttemptsInfo
NSString * _Nonnull _LdS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 252);
}
// AuthSessions.LinkDesktopDevice
NSString * _Nonnull _LdT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 253);
}
// AuthSessions.LogOut
NSString * _Nonnull _LdU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 254);
}
// AuthSessions.LogOutApplications
NSString * _Nonnull _LdV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 255);
}
// AuthSessions.LogOutApplicationsHelp
NSString * _Nonnull _LdW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 256);
}
// AuthSessions.LoggedIn
NSString * _Nonnull _LdX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 257);
}
// AuthSessions.LoggedInWithTelegram
NSString * _Nonnull _LdY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 258);
}
// AuthSessions.Message
_FormattedString * _Nonnull _LdZ(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 259, _0);
}
// AuthSessions.OtherDevices
NSString * _Nonnull _Lea(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 260);
}
// AuthSessions.OtherSessions
NSString * _Nonnull _Leb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 261);
}
// AuthSessions.Sessions
NSString * _Nonnull _Lec(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 262);
}
// AuthSessions.Terminate
NSString * _Nonnull _Led(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 263);
}
// AuthSessions.TerminateIfAwayFor
NSString * _Nonnull _Lee(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 264);
}
// AuthSessions.TerminateIfAwayTitle
NSString * _Nonnull _Lef(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 265);
}
// AuthSessions.TerminateOtherSessions
NSString * _Nonnull _Leg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 266);
}
// AuthSessions.TerminateOtherSessionsHelp
NSString * _Nonnull _Leh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 267);
}
// AuthSessions.TerminateOtherSessionsText
NSString * _Nonnull _Lei(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 268);
}
// AuthSessions.TerminateSession
NSString * _Nonnull _Lej(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 269);
}
// AuthSessions.TerminateSessionText
NSString * _Nonnull _Lek(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 270);
}
// AuthSessions.Title
NSString * _Nonnull _Lel(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 271);
}
// AuthSessions.View.AcceptIncomingCalls
NSString * _Nonnull _Lem(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 272);
}
// AuthSessions.View.AcceptSecretChats
NSString * _Nonnull _Len(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 273);
}
// AuthSessions.View.AcceptTitle
NSString * _Nonnull _Leo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 274);
}
// AuthSessions.View.Application
NSString * _Nonnull _Lep(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 275);
}
// AuthSessions.View.Browser
NSString * _Nonnull _Leq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 276);
}
// AuthSessions.View.Device
NSString * _Nonnull _Ler(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 277);
}
// AuthSessions.View.IP
NSString * _Nonnull _Les(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 278);
}
// AuthSessions.View.Location
NSString * _Nonnull _Let(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 279);
}
// AuthSessions.View.LocationInfo
NSString * _Nonnull _Leu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 280);
}
// AuthSessions.View.Logout
NSString * _Nonnull _Lev(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 281);
}
// AuthSessions.View.OS
NSString * _Nonnull _Lew(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 282);
}
// AuthSessions.View.TerminateSession
NSString * _Nonnull _Lex(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 283);
}
// AutoDownloadSettings.AutoDownload
NSString * _Nonnull _Ley(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 284);
}
// AutoDownloadSettings.AutodownloadFiles
NSString * _Nonnull _Lez(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 285);
}
// AutoDownloadSettings.AutodownloadPhotos
NSString * _Nonnull _LeA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 286);
}
// AutoDownloadSettings.AutodownloadVideos
NSString * _Nonnull _LeB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 287);
}
// AutoDownloadSettings.Cellular
NSString * _Nonnull _LeC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 288);
}
// AutoDownloadSettings.CellularTitle
NSString * _Nonnull _LeD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 289);
}
// AutoDownloadSettings.Channels
NSString * _Nonnull _LeE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 290);
}
// AutoDownloadSettings.Contacts
NSString * _Nonnull _LeF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 291);
}
// AutoDownloadSettings.DataUsage
NSString * _Nonnull _LeG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 292);
}
// AutoDownloadSettings.DataUsageCustom
NSString * _Nonnull _LeH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 293);
}
// AutoDownloadSettings.DataUsageHigh
NSString * _Nonnull _LeI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 294);
}
// AutoDownloadSettings.DataUsageLow
NSString * _Nonnull _LeJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 295);
}
// AutoDownloadSettings.DataUsageMedium
NSString * _Nonnull _LeK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 296);
}
// AutoDownloadSettings.Delimeter
NSString * _Nonnull _LeL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 297);
}
// AutoDownloadSettings.DocumentsTitle
NSString * _Nonnull _LeM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 298);
}
// AutoDownloadSettings.Files
NSString * _Nonnull _LeN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 299);
}
// AutoDownloadSettings.GroupChats
NSString * _Nonnull _LeO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 300);
}
// AutoDownloadSettings.LastDelimeter
NSString * _Nonnull _LeP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 301);
}
// AutoDownloadSettings.LimitBySize
NSString * _Nonnull _LeQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 302);
}
// AutoDownloadSettings.MaxFileSize
NSString * _Nonnull _LeR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 303);
}
// AutoDownloadSettings.MaxVideoSize
NSString * _Nonnull _LeS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 304);
}
// AutoDownloadSettings.MediaTypes
NSString * _Nonnull _LeT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 305);
}
// AutoDownloadSettings.OffForAll
NSString * _Nonnull _LeU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 306);
}
// AutoDownloadSettings.OnFor
_FormattedString * _Nonnull _LeV(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 307, _0);
}
// AutoDownloadSettings.OnForAll
NSString * _Nonnull _LeW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 308);
}
// AutoDownloadSettings.Photos
NSString * _Nonnull _LeX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 309);
}
// AutoDownloadSettings.PhotosTitle
NSString * _Nonnull _LeY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 310);
}
// AutoDownloadSettings.PreloadVideo
NSString * _Nonnull _LeZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 311);
}
// AutoDownloadSettings.PreloadVideoInfo
_FormattedString * _Nonnull _Lfa(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 312, _0);
}
// AutoDownloadSettings.PrivateChats
NSString * _Nonnull _Lfb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 313);
}
// AutoDownloadSettings.Reset
NSString * _Nonnull _Lfc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 314);
}
// AutoDownloadSettings.ResetHelp
NSString * _Nonnull _Lfd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 315);
}
// AutoDownloadSettings.ResetSettings
NSString * _Nonnull _Lfe(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 316);
}
// AutoDownloadSettings.Title
NSString * _Nonnull _Lff(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 317);
}
// AutoDownloadSettings.TypeChannels
NSString * _Nonnull _Lfg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 318);
}
// AutoDownloadSettings.TypeContacts
NSString * _Nonnull _Lfh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 319);
}
// AutoDownloadSettings.TypeGroupChats
NSString * _Nonnull _Lfi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 320);
}
// AutoDownloadSettings.TypePrivateChats
NSString * _Nonnull _Lfj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 321);
}
// AutoDownloadSettings.Unlimited
NSString * _Nonnull _Lfk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 322);
}
// AutoDownloadSettings.UpTo
_FormattedString * _Nonnull _Lfl(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 323, _0);
}
// AutoDownloadSettings.UpToFor
_FormattedString * _Nonnull _Lfm(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 324, _0, _1);
}
// AutoDownloadSettings.UpToForAll
_FormattedString * _Nonnull _Lfn(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 325, _0);
}
// AutoDownloadSettings.VideoMessagesTitle
NSString * _Nonnull _Lfo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 326);
}
// AutoDownloadSettings.Videos
NSString * _Nonnull _Lfp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 327);
}
// AutoDownloadSettings.VideosTitle
NSString * _Nonnull _Lfq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 328);
}
// AutoDownloadSettings.VoiceMessagesInfo
NSString * _Nonnull _Lfr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 329);
}
// AutoDownloadSettings.VoiceMessagesTitle
NSString * _Nonnull _Lfs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 330);
}
// AutoDownloadSettings.WiFi
NSString * _Nonnull _Lft(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 331);
}
// AutoDownloadSettings.WifiTitle
NSString * _Nonnull _Lfu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 332);
}
// AutoNightTheme.Automatic
NSString * _Nonnull _Lfv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 333);
}
// AutoNightTheme.AutomaticHelp
_FormattedString * _Nonnull _Lfw(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 334, _0);
}
// AutoNightTheme.AutomaticSection
NSString * _Nonnull _Lfx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 335);
}
// AutoNightTheme.Disabled
NSString * _Nonnull _Lfy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 336);
}
// AutoNightTheme.LocationHelp
_FormattedString * _Nonnull _Lfz(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 337, _0, _1);
}
// AutoNightTheme.NotAvailable
NSString * _Nonnull _LfA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 338);
}
// AutoNightTheme.PreferredTheme
NSString * _Nonnull _LfB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 339);
}
// AutoNightTheme.ScheduleSection
NSString * _Nonnull _LfC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 340);
}
// AutoNightTheme.Scheduled
NSString * _Nonnull _LfD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 341);
}
// AutoNightTheme.ScheduledFrom
NSString * _Nonnull _LfE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 342);
}
// AutoNightTheme.ScheduledTo
NSString * _Nonnull _LfF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 343);
}
// AutoNightTheme.System
NSString * _Nonnull _LfG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 344);
}
// AutoNightTheme.Title
NSString * _Nonnull _LfH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 345);
}
// AutoNightTheme.UpdateLocation
NSString * _Nonnull _LfI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 346);
}
// AutoNightTheme.UseSunsetSunrise
NSString * _Nonnull _LfJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 347);
}
// Autoremove.OptionOff
NSString * _Nonnull _LfK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 348);
}
// Autoremove.SetCustomTime
NSString * _Nonnull _LfL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 349);
}
// AutoremoveSetup.AdditionalGlobalSettingsInfo
NSString * _Nonnull _LfM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 350);
}
// AutoremoveSetup.TimeSectionHeader
NSString * _Nonnull _LfN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 351);
}
// AutoremoveSetup.TimerInfoChannel
NSString * _Nonnull _LfO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 352);
}
// AutoremoveSetup.TimerInfoChat
NSString * _Nonnull _LfP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 353);
}
// AutoremoveSetup.TimerValueAfter
_FormattedString * _Nonnull _LfQ(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 354, _0);
}
// AutoremoveSetup.TimerValueNever
NSString * _Nonnull _LfR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 355);
}
// AutoremoveSetup.Title
NSString * _Nonnull _LfS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 356);
}
// Autosave.AddException
NSString * _Nonnull _LfT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 357);
}
// Autosave.DeleteAllExceptions
NSString * _Nonnull _LfU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 358);
}
// Autosave.Exception
NSString * _Nonnull _LfV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 359);
}
// Autosave.ExceptionsSection
NSString * _Nonnull _LfW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 360);
}
// Autosave.TypePhoto
NSString * _Nonnull _LfX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 361);
}
// Autosave.TypeVideo
NSString * _Nonnull _LfY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 362);
}
// Autosave.TypesInfo
NSString * _Nonnull _LfZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 363);
}
// Autosave.TypesSection
NSString * _Nonnull _Lga(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 364);
}
// Autosave.VideoInfo
_FormattedString * _Nonnull _Lgb(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 365, _0);
}
// Autosave.VideoSizeSection
NSString * _Nonnull _Lgc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 366);
}
// AvatarEditor.Background
NSString * _Nonnull _Lgd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 367);
}
// AvatarEditor.Emoji
NSString * _Nonnull _Lge(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 368);
}
// AvatarEditor.EmojiOrSticker
NSString * _Nonnull _Lgf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 369);
}
// AvatarEditor.Set
NSString * _Nonnull _Lgg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 370);
}
// AvatarEditor.SetChannelPhoto
NSString * _Nonnull _Lgh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 371);
}
// AvatarEditor.SetGroupPhoto
NSString * _Nonnull _Lgi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 372);
}
// AvatarEditor.SetProfilePhoto
NSString * _Nonnull _Lgj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 373);
}
// AvatarEditor.Stickers
NSString * _Nonnull _Lgk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 374);
}
// AvatarEditor.Suggest
NSString * _Nonnull _Lgl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 375);
}
// AvatarEditor.SuggestProfilePhoto
NSString * _Nonnull _Lgm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 376);
}
// AvatarEditor.SwitchToEmoji
NSString * _Nonnull _Lgn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 377);
}
// AvatarEditor.SwitchToStickers
NSString * _Nonnull _Lgo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 378);
}
// BlockedUsers.AddNew
NSString * _Nonnull _Lgp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 379);
}
// BlockedUsers.BlockTitle
NSString * _Nonnull _Lgq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 380);
}
// BlockedUsers.BlockUser
NSString * _Nonnull _Lgr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 381);
}
// BlockedUsers.Info
NSString * _Nonnull _Lgs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 382);
}
// BlockedUsers.LeavePrefix
NSString * _Nonnull _Lgt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 383);
}
// BlockedUsers.SelectUserTitle
NSString * _Nonnull _Lgu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 384);
}
// BlockedUsers.Title
NSString * _Nonnull _Lgv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 385);
}
// BlockedUsers.Unblock
NSString * _Nonnull _Lgw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 386);
}
// Bot.AccepRecurrentInfo
_FormattedString * _Nonnull _Lgx(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 387, _0);
}
// Bot.AddToChat
NSString * _Nonnull _Lgy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 388);
}
// Bot.AddToChat.Add.AddAsAdmin
NSString * _Nonnull _Lgz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 389);
}
// Bot.AddToChat.Add.AddAsMember
NSString * _Nonnull _LgA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 390);
}
// Bot.AddToChat.Add.AdminAlertAdd
NSString * _Nonnull _LgB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 391);
}
// Bot.AddToChat.Add.AdminAlertTextChannel
_FormattedString * _Nonnull _LgC(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 392, _0);
}
// Bot.AddToChat.Add.AdminAlertTextGroup
_FormattedString * _Nonnull _LgD(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 393, _0);
}
// Bot.AddToChat.Add.AdminAlertTitle
NSString * _Nonnull _LgE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 394);
}
// Bot.AddToChat.Add.AdminRights
NSString * _Nonnull _LgF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 395);
}
// Bot.AddToChat.Add.MemberAlertAdd
NSString * _Nonnull _LgG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 396);
}
// Bot.AddToChat.Add.MemberAlertTextChannel
_FormattedString * _Nonnull _LgH(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 397, _0);
}
// Bot.AddToChat.Add.MemberAlertTextGroup
_FormattedString * _Nonnull _LgI(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 398, _0);
}
// Bot.AddToChat.Add.MemberAlertTitle
NSString * _Nonnull _LgJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 399);
}
// Bot.AddToChat.Add.Title
NSString * _Nonnull _LgK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 400);
}
// Bot.AddToChat.MyChannels
NSString * _Nonnull _LgL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 401);
}
// Bot.AddToChat.MyGroups
NSString * _Nonnull _LgM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 402);
}
// Bot.AddToChat.OtherGroups
NSString * _Nonnull _LgN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 403);
}
// Bot.AddToChat.Title
NSString * _Nonnull _LgO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 404);
}
// Bot.AddToChatInfo
NSString * _Nonnull _LgP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 405);
}
// Bot.DescriptionTitle
NSString * _Nonnull _LgQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 406);
}
// Bot.GenericBotStatus
NSString * _Nonnull _LgR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 407);
}
// Bot.GenericSupportStatus
NSString * _Nonnull _LgS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 408);
}
// Bot.GroupStatusDoesNotReadHistory
NSString * _Nonnull _LgT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 409);
}
// Bot.GroupStatusReadsHistory
NSString * _Nonnull _LgU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 410);
}
// Bot.Start
NSString * _Nonnull _LgV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 411);
}
// Bot.Stop
NSString * _Nonnull _LgW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 412);
}
// Bot.Unblock
NSString * _Nonnull _LgX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 413);
}
// Broadcast.AdminLog.EmptyText
NSString * _Nonnull _LgY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 414);
}
// BroadcastGroups.Cancel
NSString * _Nonnull _LgZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 415);
}
// BroadcastGroups.ConfirmationAlert.Convert
NSString * _Nonnull _Lha(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 416);
}
// BroadcastGroups.ConfirmationAlert.Text
NSString * _Nonnull _Lhb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 417);
}
// BroadcastGroups.ConfirmationAlert.Title
NSString * _Nonnull _Lhc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 418);
}
// BroadcastGroups.Convert
NSString * _Nonnull _Lhd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 419);
}
// BroadcastGroups.IntroText
NSString * _Nonnull _Lhe(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 420);
}
// BroadcastGroups.IntroTitle
NSString * _Nonnull _Lhf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 421);
}
// BroadcastGroups.LimitAlert.LearnMore
NSString * _Nonnull _Lhg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 422);
}
// BroadcastGroups.LimitAlert.SettingsTip
NSString * _Nonnull _Lhh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 423);
}
// BroadcastGroups.LimitAlert.Text
_FormattedString * _Nonnull _Lhi(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 424, _0);
}
// BroadcastGroups.LimitAlert.Title
NSString * _Nonnull _Lhj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 425);
}
// BroadcastGroups.Success
_FormattedString * _Nonnull _Lhk(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 426, _0);
}
// BroadcastListInfo.AddRecipient
NSString * _Nonnull _Lhl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 427);
}
// CHAT_MESSAGE_INVOICE
_FormattedString * _Nonnull _Lhm(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2) {
    return getFormatted3(_self, 428, _0, _1, _2);
}
// CHAT_MESSAGE_NOTHEME
_FormattedString * _Nonnull _Lhn(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 429, _0, _1);
}
// CHAT_MESSAGE_RECURRING_PAY
_FormattedString * _Nonnull _Lho(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 430, _0, _1);
}
// Cache.ByPeerHeader
NSString * _Nonnull _Lhp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 431);
}
// Cache.Clear
_FormattedString * _Nonnull _Lhq(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 432, _0);
}
// Cache.ClearCache
NSString * _Nonnull _Lhr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 433);
}
// Cache.ClearEmpty
NSString * _Nonnull _Lhs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 434);
}
// Cache.ClearNone
NSString * _Nonnull _Lht(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 435);
}
// Cache.ClearProgress
NSString * _Nonnull _Lhu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 436);
}
// Cache.Files
NSString * _Nonnull _Lhv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 437);
}
// Cache.Help
NSString * _Nonnull _Lhw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 438);
}
// Cache.Indexing
NSString * _Nonnull _Lhx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 439);
}
// Cache.KeepMedia
NSString * _Nonnull _Lhy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 440);
}
// Cache.KeepMediaHelp
NSString * _Nonnull _Lhz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 441);
}
// Cache.LowDiskSpaceText
NSString * _Nonnull _LhA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 442);
}
// Cache.MaximumCacheSize
NSString * _Nonnull _LhB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 443);
}
// Cache.MaximumCacheSizeHelp
NSString * _Nonnull _LhC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 444);
}
// Cache.Music
NSString * _Nonnull _LhD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 445);
}
// Cache.NoLimit
NSString * _Nonnull _LhE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 446);
}
// Cache.Photos
NSString * _Nonnull _LhF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 447);
}
// Cache.ServiceFiles
NSString * _Nonnull _LhG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 448);
}
// Cache.Title
NSString * _Nonnull _LhH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 449);
}
// Cache.Videos
NSString * _Nonnull _LhI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 450);
}
// CacheEvictionMenu.CategoryExceptions
NSString * _Nonnull _LhJ(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 451, value);
}
// Calendar.ShortFri
NSString * _Nonnull _LhK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 452);
}
// Calendar.ShortMon
NSString * _Nonnull _LhL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 453);
}
// Calendar.ShortSat
NSString * _Nonnull _LhM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 454);
}
// Calendar.ShortSun
NSString * _Nonnull _LhN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 455);
}
// Calendar.ShortThu
NSString * _Nonnull _LhO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 456);
}
// Calendar.ShortTue
NSString * _Nonnull _LhP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 457);
}
// Calendar.ShortWed
NSString * _Nonnull _LhQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 458);
}
// Call.Accept
NSString * _Nonnull _LhR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 459);
}
// Call.AccountIsLoggedOnCurrentDevice
_FormattedString * _Nonnull _LhS(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 460, _0);
}
// Call.AnsweringWithAccount
_FormattedString * _Nonnull _LhT(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 461, _0);
}
// Call.Audio
NSString * _Nonnull _LhU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 462);
}
// Call.AudioRouteHeadphones
NSString * _Nonnull _LhV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 463);
}
// Call.AudioRouteHide
NSString * _Nonnull _LhW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 464);
}
// Call.AudioRouteMute
NSString * _Nonnull _LhX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 465);
}
// Call.AudioRouteSpeaker
NSString * _Nonnull _LhY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 466);
}
// Call.BatteryLow
_FormattedString * _Nonnull _LhZ(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 467, _0);
}
// Call.CallAgain
NSString * _Nonnull _Lia(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 468);
}
// Call.CallInProgressLiveStreamMessage
_FormattedString * _Nonnull _Lib(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 469, _0, _1);
}
// Call.CallInProgressMessage
_FormattedString * _Nonnull _Lic(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 470, _0, _1);
}
// Call.CallInProgressTitle
NSString * _Nonnull _Lid(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 471);
}
// Call.CallInProgressVoiceChatMessage
_FormattedString * _Nonnull _Lie(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 472, _0, _1);
}
// Call.Camera
NSString * _Nonnull _Lif(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 473);
}
// Call.CameraConfirmationConfirm
NSString * _Nonnull _Lig(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 474);
}
// Call.CameraConfirmationText
NSString * _Nonnull _Lih(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 475);
}
// Call.CameraOff
_FormattedString * _Nonnull _Lii(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 476, _0);
}
// Call.CameraOrScreenTooltip
NSString * _Nonnull _Lij(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 477);
}
// Call.CameraTooltip
NSString * _Nonnull _Lik(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 478);
}
// Call.ConnectionErrorMessage
NSString * _Nonnull _Lil(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 479);
}
// Call.ConnectionErrorTitle
NSString * _Nonnull _Lim(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 480);
}
// Call.Days
NSString * _Nonnull _Lin(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 481, value);
}
// Call.Decline
NSString * _Nonnull _Lio(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 482);
}
// Call.EmojiDescription
_FormattedString * _Nonnull _Lip(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 483, _0);
}
// Call.EncryptionKey.Title
NSString * _Nonnull _Liq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 484);
}
// Call.End
NSString * _Nonnull _Lir(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 485);
}
// Call.ExternalCallInProgressMessage
NSString * _Nonnull _Lis(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 486);
}
// Call.Flip
NSString * _Nonnull _Lit(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 487);
}
// Call.GroupFormat
_FormattedString * _Nonnull _Liu(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 488, _0, _1);
}
// Call.Hours
NSString * _Nonnull _Liv(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 489, value);
}
// Call.IncomingVideoCall
NSString * _Nonnull _Liw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 490);
}
// Call.IncomingVoiceCall
NSString * _Nonnull _Lix(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 491);
}
// Call.LiveStreamInProgressCallMessage
_FormattedString * _Nonnull _Liy(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 492, _0, _1);
}
// Call.LiveStreamInProgressMessage
_FormattedString * _Nonnull _Liz(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 493, _0, _1);
}
// Call.LiveStreamInProgressTitle
NSString * _Nonnull _LiA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 494);
}
// Call.Message
NSString * _Nonnull _LiB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 495);
}
// Call.MicrophoneOff
_FormattedString * _Nonnull _LiC(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 496, _0);
}
// Call.Minutes
NSString * _Nonnull _LiD(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 497, value);
}
// Call.Mute
NSString * _Nonnull _LiE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 498);
}
// Call.ParticipantVersionOutdatedError
_FormattedString * _Nonnull _LiF(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 499, _0);
}
// Call.ParticipantVideoVersionOutdatedError
_FormattedString * _Nonnull _LiG(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 500, _0);
}
// Call.PhoneCallInProgressMessage
NSString * _Nonnull _LiH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 501);
}
// Call.PrivacyErrorMessage
_FormattedString * _Nonnull _LiI(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 502, _0);
}
// Call.RateCall
NSString * _Nonnull _LiJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 503);
}
// Call.RecordingDisabledMessage
NSString * _Nonnull _LiK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 504);
}
// Call.RemoteVideoPaused
_FormattedString * _Nonnull _LiL(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 505, _0);
}
// Call.ReportIncludeLog
NSString * _Nonnull _LiM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 506);
}
// Call.ReportIncludeLogDescription
NSString * _Nonnull _LiN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 507);
}
// Call.ReportPlaceholder
NSString * _Nonnull _LiO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 508);
}
// Call.ReportSend
NSString * _Nonnull _LiP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 509);
}
// Call.ReportSkip
NSString * _Nonnull _LiQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 510);
}
// Call.Seconds
NSString * _Nonnull _LiR(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 511, value);
}
// Call.ShareStats
NSString * _Nonnull _LiS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 512);
}
// Call.ShortMinutes
NSString * _Nonnull _LiT(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 513, value);
}
// Call.ShortSeconds
NSString * _Nonnull _LiU(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 514, value);
}
// Call.Speaker
NSString * _Nonnull _LiV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 515);
}
// Call.StatusBar
_FormattedString * _Nonnull _LiW(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 516, _0);
}
// Call.StatusBusy
NSString * _Nonnull _LiX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 517);
}
// Call.StatusConnecting
NSString * _Nonnull _LiY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 518);
}
// Call.StatusEnded
NSString * _Nonnull _LiZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 519);
}
// Call.StatusFailed
NSString * _Nonnull _Lja(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 520);
}
// Call.StatusIncoming
NSString * _Nonnull _Ljb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 521);
}
// Call.StatusNoAnswer
NSString * _Nonnull _Ljc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 522);
}
// Call.StatusOngoing
_FormattedString * _Nonnull _Ljd(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 523, _0);
}
// Call.StatusRequesting
NSString * _Nonnull _Lje(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 524);
}
// Call.StatusRinging
NSString * _Nonnull _Ljf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 525);
}
// Call.StatusWaiting
NSString * _Nonnull _Ljg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 526);
}
// Call.VoiceChatInProgressCallMessage
_FormattedString * _Nonnull _Ljh(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 527, _0, _1);
}
// Call.VoiceChatInProgressMessage
_FormattedString * _Nonnull _Lji(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 528, _0, _1);
}
// Call.VoiceChatInProgressTitle
NSString * _Nonnull _Ljj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 529);
}
// Call.VoiceOver.Minimize
NSString * _Nonnull _Ljk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 530);
}
// Call.VoiceOver.VideoCallCanceled
NSString * _Nonnull _Ljl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 531);
}
// Call.VoiceOver.VideoCallIncoming
NSString * _Nonnull _Ljm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 532);
}
// Call.VoiceOver.VideoCallMissed
NSString * _Nonnull _Ljn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 533);
}
// Call.VoiceOver.VideoCallOutgoing
NSString * _Nonnull _Ljo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 534);
}
// Call.VoiceOver.VoiceCallCanceled
NSString * _Nonnull _Ljp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 535);
}
// Call.VoiceOver.VoiceCallIncoming
NSString * _Nonnull _Ljq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 536);
}
// Call.VoiceOver.VoiceCallMissed
NSString * _Nonnull _Ljr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 537);
}
// Call.VoiceOver.VoiceCallOutgoing
NSString * _Nonnull _Ljs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 538);
}
// Call.YourMicrophoneOff
NSString * _Nonnull _Ljt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 539);
}
// CallFeedback.AddComment
NSString * _Nonnull _Lju(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 540);
}
// CallFeedback.IncludeLogs
NSString * _Nonnull _Ljv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 541);
}
// CallFeedback.IncludeLogsInfo
NSString * _Nonnull _Ljw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 542);
}
// CallFeedback.ReasonDistortedSpeech
NSString * _Nonnull _Ljx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 543);
}
// CallFeedback.ReasonDropped
NSString * _Nonnull _Ljy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 544);
}
// CallFeedback.ReasonEcho
NSString * _Nonnull _Ljz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 545);
}
// CallFeedback.ReasonInterruption
NSString * _Nonnull _LjA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 546);
}
// CallFeedback.ReasonNoise
NSString * _Nonnull _LjB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 547);
}
// CallFeedback.ReasonSilentLocal
NSString * _Nonnull _LjC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 548);
}
// CallFeedback.ReasonSilentRemote
NSString * _Nonnull _LjD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 549);
}
// CallFeedback.Send
NSString * _Nonnull _LjE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 550);
}
// CallFeedback.Success
NSString * _Nonnull _LjF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 551);
}
// CallFeedback.Title
NSString * _Nonnull _LjG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 552);
}
// CallFeedback.VideoReasonDistorted
NSString * _Nonnull _LjH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 553);
}
// CallFeedback.VideoReasonLowQuality
NSString * _Nonnull _LjI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 554);
}
// CallFeedback.WhatWentWrong
NSString * _Nonnull _LjJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 555);
}
// CallList.ActiveVoiceChatsHeader
NSString * _Nonnull _LjK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 556);
}
// CallList.DeleteAll
NSString * _Nonnull _LjL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 557);
}
// CallList.DeleteAllForEveryone
NSString * _Nonnull _LjM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 558);
}
// CallList.DeleteAllForMe
NSString * _Nonnull _LjN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 559);
}
// CallList.RecentCallsHeader
NSString * _Nonnull _LjO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 560);
}
// CallSettings.Always
NSString * _Nonnull _LjP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 561);
}
// CallSettings.Never
NSString * _Nonnull _LjQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 562);
}
// CallSettings.OnMobile
NSString * _Nonnull _LjR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 563);
}
// CallSettings.RecentCalls
NSString * _Nonnull _LjS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 564);
}
// CallSettings.TabIcon
NSString * _Nonnull _LjT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 565);
}
// CallSettings.TabIconDescription
NSString * _Nonnull _LjU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 566);
}
// CallSettings.Title
NSString * _Nonnull _LjV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 567);
}
// CallSettings.UseLessData
NSString * _Nonnull _LjW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 568);
}
// CallSettings.UseLessDataLongDescription
NSString * _Nonnull _LjX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 569);
}
// Calls.AddTab
NSString * _Nonnull _LjY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 570);
}
// Calls.All
NSString * _Nonnull _LjZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 571);
}
// Calls.CallTabDescription
NSString * _Nonnull _Lka(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 572);
}
// Calls.CallTabTitle
NSString * _Nonnull _Lkb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 573);
}
// Calls.Missed
NSString * _Nonnull _Lkc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 574);
}
// Calls.NewCall
NSString * _Nonnull _Lkd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 575);
}
// Calls.NoCallsPlaceholder
NSString * _Nonnull _Lke(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 576);
}
// Calls.NoMissedCallsPlacehoder
NSString * _Nonnull _Lkf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 577);
}
// Calls.NoVoiceAndVideoCallsPlaceholder
NSString * _Nonnull _Lkg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 578);
}
// Calls.NotNow
NSString * _Nonnull _Lkh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 579);
}
// Calls.RatingFeedback
NSString * _Nonnull _Lki(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 580);
}
// Calls.RatingTitle
NSString * _Nonnull _Lkj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 581);
}
// Calls.StartNewCall
NSString * _Nonnull _Lkk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 582);
}
// Calls.SubmitRating
NSString * _Nonnull _Lkl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 583);
}
// Calls.TabTitle
NSString * _Nonnull _Lkm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 584);
}
// Camera.Discard
NSString * _Nonnull _Lkn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 585);
}
// Camera.FlashAuto
NSString * _Nonnull _Lko(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 586);
}
// Camera.FlashOff
NSString * _Nonnull _Lkp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 587);
}
// Camera.FlashOn
NSString * _Nonnull _Lkq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 588);
}
// Camera.PhotoMode
NSString * _Nonnull _Lkr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 589);
}
// Camera.Retake
NSString * _Nonnull _Lks(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 590);
}
// Camera.SquareMode
NSString * _Nonnull _Lkt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 591);
}
// Camera.TapAndHoldForVideo
NSString * _Nonnull _Lku(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 592);
}
// Camera.Title
NSString * _Nonnull _Lkv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 593);
}
// Camera.VideoMode
NSString * _Nonnull _Lkw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 594);
}
// CancelResetAccount.Success
_FormattedString * _Nonnull _Lkx(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 595, _0);
}
// CancelResetAccount.TextSMS
_FormattedString * _Nonnull _Lky(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 596, _0);
}
// CancelResetAccount.Title
NSString * _Nonnull _Lkz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 597);
}
// ChangePhone.ErrorOccupied
_FormattedString * _Nonnull _LkA(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 598, _0);
}
// ChangePhoneNumberCode.CallTimer
_FormattedString * _Nonnull _LkB(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 599, _0);
}
// ChangePhoneNumberCode.Called
NSString * _Nonnull _LkC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 600);
}
// ChangePhoneNumberCode.Code
NSString * _Nonnull _LkD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 601);
}
// ChangePhoneNumberCode.CodePlaceholder
NSString * _Nonnull _LkE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 602);
}
// ChangePhoneNumberCode.Help
NSString * _Nonnull _LkF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 603);
}
// ChangePhoneNumberCode.RequestingACall
NSString * _Nonnull _LkG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 604);
}
// ChangePhoneNumberNumber.Help
NSString * _Nonnull _LkH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 605);
}
// ChangePhoneNumberNumber.NewNumber
NSString * _Nonnull _LkI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 606);
}
// ChangePhoneNumberNumber.NumberPlaceholder
NSString * _Nonnull _LkJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 607);
}
// ChangePhoneNumberNumber.Title
NSString * _Nonnull _LkK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 608);
}
// Channel.About.Help
NSString * _Nonnull _LkL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 609);
}
// Channel.About.Placeholder
NSString * _Nonnull _LkM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 610);
}
// Channel.About.Title
NSString * _Nonnull _LkN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 611);
}
// Channel.AboutItem
NSString * _Nonnull _LkO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 612);
}
// Channel.AddAdminKickedError
NSString * _Nonnull _LkP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 613);
}
// Channel.AddBotAsAdmin
NSString * _Nonnull _LkQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 614);
}
// Channel.AddBotErrorHaveRights
NSString * _Nonnull _LkR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 615);
}
// Channel.AddBotErrorNoRights
NSString * _Nonnull _LkS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 616);
}
// Channel.AddUserKickedError
NSString * _Nonnull _LkT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 617);
}
// Channel.AddUserLeftError
NSString * _Nonnull _LkU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 618);
}
// Channel.AdminLog.AddMembers
NSString * _Nonnull _LkV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 619);
}
// Channel.AdminLog.AllowedNewMembersToSpeak
_FormattedString * _Nonnull _LkW(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 620, _0);
}
// Channel.AdminLog.AllowedReactionsUpdated
_FormattedString * _Nonnull _LkX(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 621, _0, _1);
}
// Channel.AdminLog.AntiSpamDisabled
_FormattedString * _Nonnull _LkY(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 622, _0);
}
// Channel.AdminLog.AntiSpamEnabled
_FormattedString * _Nonnull _LkZ(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 623, _0);
}
// Channel.AdminLog.BanEmbedLinks
NSString * _Nonnull _Lla(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 624);
}
// Channel.AdminLog.BanReadMessages
NSString * _Nonnull _Llb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 625);
}
// Channel.AdminLog.BanSendMedia
NSString * _Nonnull _Llc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 626);
}
// Channel.AdminLog.BanSendMessages
NSString * _Nonnull _Lld(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 627);
}
// Channel.AdminLog.BanSendStickersAndGifs
NSString * _Nonnull _Lle(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 628);
}
// Channel.AdminLog.CanAddAdmins
NSString * _Nonnull _Llf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 629);
}
// Channel.AdminLog.CanBanUsers
NSString * _Nonnull _Llg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 630);
}
// Channel.AdminLog.CanBeAnonymous
NSString * _Nonnull _Llh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 631);
}
// Channel.AdminLog.CanChangeInfo
NSString * _Nonnull _Lli(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 632);
}
// Channel.AdminLog.CanDeleteMessages
NSString * _Nonnull _Llj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 633);
}
// Channel.AdminLog.CanDeleteMessagesOfOthers
NSString * _Nonnull _Llk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 634);
}
// Channel.AdminLog.CanEditMessages
NSString * _Nonnull _Lll(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 635);
}
// Channel.AdminLog.CanInviteUsers
NSString * _Nonnull _Llm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 636);
}
// Channel.AdminLog.CanInviteUsersViaLink
NSString * _Nonnull _Lln(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 637);
}
// Channel.AdminLog.CanManageCalls
NSString * _Nonnull _Llo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 638);
}
// Channel.AdminLog.CanManageLiveStreams
NSString * _Nonnull _Llp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 639);
}
// Channel.AdminLog.CanManageTopics
NSString * _Nonnull _Llq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 640);
}
// Channel.AdminLog.CanPinMessages
NSString * _Nonnull _Llr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 641);
}
// Channel.AdminLog.CanSendMessages
NSString * _Nonnull _Lls(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 642);
}
// Channel.AdminLog.CaptionEdited
_FormattedString * _Nonnull _Llt(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 643, _0);
}
// Channel.AdminLog.ChangeInfo
NSString * _Nonnull _Llu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 644);
}
// Channel.AdminLog.ChannelEmptyText
NSString * _Nonnull _Llv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 645);
}
// Channel.AdminLog.CreatedInviteLink
_FormattedString * _Nonnull _Llw(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 646, _0, _1);
}
// Channel.AdminLog.DefaultRestrictionsUpdated
NSString * _Nonnull _Llx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 647);
}
// Channel.AdminLog.DeletedInviteLink
_FormattedString * _Nonnull _Lly(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 648, _0, _1);
}
// Channel.AdminLog.DisabledSlowmode
_FormattedString * _Nonnull _Llz(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 649, _0);
}
// Channel.AdminLog.EditedInviteLink
_FormattedString * _Nonnull _LlA(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 650, _0, _1);
}
// Channel.AdminLog.EmptyFilterQueryText
_FormattedString * _Nonnull _LlB(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 651, _0);
}
// Channel.AdminLog.EmptyFilterText
NSString * _Nonnull _LlC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 652);
}
// Channel.AdminLog.EmptyFilterTitle
NSString * _Nonnull _LlD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 653);
}
// Channel.AdminLog.EmptyMessageText
NSString * _Nonnull _LlE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 654);
}
// Channel.AdminLog.EmptyText
NSString * _Nonnull _LlF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 655);
}
// Channel.AdminLog.EmptyTitle
NSString * _Nonnull _LlG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 656);
}
// Channel.AdminLog.EndedLiveStream
_FormattedString * _Nonnull _LlH(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 657, _0);
}
// Channel.AdminLog.EndedVoiceChat
_FormattedString * _Nonnull _LlI(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 658, _0);
}
// Channel.AdminLog.InfoPanelAlertText
NSString * _Nonnull _LlJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 659);
}
// Channel.AdminLog.InfoPanelAlertTitle
NSString * _Nonnull _LlK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 660);
}
// Channel.AdminLog.InfoPanelChannelAlertText
NSString * _Nonnull _LlL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 661);
}
// Channel.AdminLog.InfoPanelTitle
NSString * _Nonnull _LlM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 662);
}
// Channel.AdminLog.JoinedViaInviteLink
_FormattedString * _Nonnull _LlN(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 663, _0, _1);
}
// Channel.AdminLog.JoinedViaPublicRequest
_FormattedString * _Nonnull _LlO(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 664, _0, _1);
}
// Channel.AdminLog.JoinedViaRequest
_FormattedString * _Nonnull _LlP(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2) {
    return getFormatted3(_self, 665, _0, _1, _2);
}
// Channel.AdminLog.ManageTopics
NSString * _Nonnull _LlQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 666);
}
// Channel.AdminLog.MessageAddedAdminName
_FormattedString * _Nonnull _LlR(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 667, _0);
}
// Channel.AdminLog.MessageAddedAdminNameUsername
_FormattedString * _Nonnull _LlS(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 668, _0, _1);
}
// Channel.AdminLog.MessageAdmin
_FormattedString * _Nonnull _LlT(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2) {
    return getFormatted3(_self, 669, _0, _1, _2);
}
// Channel.AdminLog.MessageChangedAutoremoveTimeoutRemove
_FormattedString * _Nonnull _LlU(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 670, _0);
}
// Channel.AdminLog.MessageChangedAutoremoveTimeoutSet
_FormattedString * _Nonnull _LlV(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 671, _0, _1);
}
// Channel.AdminLog.MessageChangedChannelAbout
_FormattedString * _Nonnull _LlW(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 672, _0);
}
// Channel.AdminLog.MessageChangedChannelUsername
_FormattedString * _Nonnull _LlX(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 673, _0);
}
// Channel.AdminLog.MessageChangedChannelUsernames
_FormattedString * _Nonnull _LlY(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 674, _0);
}
// Channel.AdminLog.MessageChangedGroupAbout
_FormattedString * _Nonnull _LlZ(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 675, _0);
}
// Channel.AdminLog.MessageChangedGroupGeoLocation
_FormattedString * _Nonnull _Lma(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 676, _0);
}
// Channel.AdminLog.MessageChangedGroupStickerPack
_FormattedString * _Nonnull _Lmb(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 677, _0);
}
// Channel.AdminLog.MessageChangedGroupUsername
_FormattedString * _Nonnull _Lmc(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 678, _0);
}
// Channel.AdminLog.MessageChangedGroupUsernames
_FormattedString * _Nonnull _Lmd(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 679, _0);
}
// Channel.AdminLog.MessageChangedLinkedChannel
_FormattedString * _Nonnull _Lme(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 680, _0, _1);
}
// Channel.AdminLog.MessageChangedLinkedGroup
_FormattedString * _Nonnull _Lmf(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 681, _0, _1);
}
// Channel.AdminLog.MessageChangedThemeRemove
_FormattedString * _Nonnull _Lmg(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 682, _0);
}
// Channel.AdminLog.MessageChangedThemeSet
_FormattedString * _Nonnull _Lmh(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 683, _0, _1);
}
// Channel.AdminLog.MessageChangedUnlinkedChannel
_FormattedString * _Nonnull _Lmi(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 684, _0, _1);
}
// Channel.AdminLog.MessageChangedUnlinkedGroup
_FormattedString * _Nonnull _Lmj(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 685, _0, _1);
}
// Channel.AdminLog.MessageDeleted
_FormattedString * _Nonnull _Lmk(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 686, _0);
}
// Channel.AdminLog.MessageEdited
_FormattedString * _Nonnull _Lml(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 687, _0);
}
// Channel.AdminLog.MessageGroupPreHistoryHidden
_FormattedString * _Nonnull _Lmm(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 688, _0);
}
// Channel.AdminLog.MessageGroupPreHistoryVisible
_FormattedString * _Nonnull _Lmn(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 689, _0);
}
// Channel.AdminLog.MessageInvitedName
_FormattedString * _Nonnull _Lmo(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 690, _0);
}
// Channel.AdminLog.MessageInvitedNameUsername
_FormattedString * _Nonnull _Lmp(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 691, _0, _1);
}
// Channel.AdminLog.MessageKickedName
_FormattedString * _Nonnull _Lmq(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 692, _0);
}
// Channel.AdminLog.MessageKickedNameUsername
_FormattedString * _Nonnull _Lmr(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 693, _0, _1);
}
// Channel.AdminLog.MessagePinned
_FormattedString * _Nonnull _Lms(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 694, _0);
}
// Channel.AdminLog.MessagePreviousCaption
NSString * _Nonnull _Lmt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 695);
}
// Channel.AdminLog.MessagePreviousDescription
NSString * _Nonnull _Lmu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 696);
}
// Channel.AdminLog.MessagePreviousLink
NSString * _Nonnull _Lmv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 697);
}
// Channel.AdminLog.MessagePreviousLinks
NSString * _Nonnull _Lmw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 698);
}
// Channel.AdminLog.MessagePreviousMessage
NSString * _Nonnull _Lmx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 699);
}
// Channel.AdminLog.MessagePromotedName
_FormattedString * _Nonnull _Lmy(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 700, _0);
}
// Channel.AdminLog.MessagePromotedNameUsername
_FormattedString * _Nonnull _Lmz(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 701, _0, _1);
}
// Channel.AdminLog.MessageRank
_FormattedString * _Nonnull _LmA(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 702, _0);
}
// Channel.AdminLog.MessageRankName
_FormattedString * _Nonnull _LmB(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 703, _0, _1);
}
// Channel.AdminLog.MessageRankUsername
_FormattedString * _Nonnull _LmC(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2) {
    return getFormatted3(_self, 704, _0, _1, _2);
}
// Channel.AdminLog.MessageRemovedAdminName
_FormattedString * _Nonnull _LmD(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 705, _0);
}
// Channel.AdminLog.MessageRemovedAdminNameUsername
_FormattedString * _Nonnull _LmE(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 706, _0, _1);
}
// Channel.AdminLog.MessageRemovedChannelUsername
_FormattedString * _Nonnull _LmF(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 707, _0);
}
// Channel.AdminLog.MessageRemovedGroupStickerPack
_FormattedString * _Nonnull _LmG(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 708, _0);
}
// Channel.AdminLog.MessageRemovedGroupUsername
_FormattedString * _Nonnull _LmH(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 709, _0);
}
// Channel.AdminLog.MessageRestricted
_FormattedString * _Nonnull _LmI(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2) {
    return getFormatted3(_self, 710, _0, _1, _2);
}
// Channel.AdminLog.MessageRestrictedForever
NSString * _Nonnull _LmJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 711);
}
// Channel.AdminLog.MessageRestrictedName
_FormattedString * _Nonnull _LmK(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 712, _0);
}
// Channel.AdminLog.MessageRestrictedNameUsername
_FormattedString * _Nonnull _LmL(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 713, _0, _1);
}
// Channel.AdminLog.MessageRestrictedNewSetting
_FormattedString * _Nonnull _LmM(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 714, _0);
}
// Channel.AdminLog.MessageRestrictedUntil
_FormattedString * _Nonnull _LmN(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 715, _0);
}
// Channel.AdminLog.MessageSent
_FormattedString * _Nonnull _LmO(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 716, _0);
}
// Channel.AdminLog.MessageToggleInvitesOff
_FormattedString * _Nonnull _LmP(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 717, _0);
}
// Channel.AdminLog.MessageToggleInvitesOn
_FormattedString * _Nonnull _LmQ(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 718, _0);
}
// Channel.AdminLog.MessageToggleNoForwardsOff
_FormattedString * _Nonnull _LmR(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 719, _0);
}
// Channel.AdminLog.MessageToggleNoForwardsOn
_FormattedString * _Nonnull _LmS(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 720, _0);
}
// Channel.AdminLog.MessageToggleSignaturesOff
_FormattedString * _Nonnull _LmT(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 721, _0);
}
// Channel.AdminLog.MessageToggleSignaturesOn
_FormattedString * _Nonnull _LmU(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 722, _0);
}
// Channel.AdminLog.MessageTransferedName
_FormattedString * _Nonnull _LmV(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 723, _0);
}
// Channel.AdminLog.MessageTransferedNameUsername
_FormattedString * _Nonnull _LmW(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 724, _0, _1);
}
// Channel.AdminLog.MessageUnkickedName
_FormattedString * _Nonnull _LmX(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 725, _0);
}
// Channel.AdminLog.MessageUnkickedNameUsername
_FormattedString * _Nonnull _LmY(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 726, _0, _1);
}
// Channel.AdminLog.MessageUnpinned
_FormattedString * _Nonnull _LmZ(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 727, _0);
}
// Channel.AdminLog.MessageUnpinnedExtended
_FormattedString * _Nonnull _Lna(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 728, _0);
}
// Channel.AdminLog.MutedNewMembers
_FormattedString * _Nonnull _Lnb(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 729, _0);
}
// Channel.AdminLog.MutedParticipant
_FormattedString * _Nonnull _Lnc(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 730, _0, _1);
}
// Channel.AdminLog.PinMessages
NSString * _Nonnull _Lnd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 731);
}
// Channel.AdminLog.PollStopped
_FormattedString * _Nonnull _Lne(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 732, _0);
}
// Channel.AdminLog.ReactionsDisabled
_FormattedString * _Nonnull _Lnf(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 733, _0);
}
// Channel.AdminLog.ReactionsEnabled
_FormattedString * _Nonnull _Lng(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 734, _0);
}
// Channel.AdminLog.RevokedInviteLink
_FormattedString * _Nonnull _Lnh(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 735, _0, _1);
}
// Channel.AdminLog.SendPolls
NSString * _Nonnull _Lni(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 736);
}
// Channel.AdminLog.SetSlowmode
_FormattedString * _Nonnull _Lnj(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 737, _0, _1);
}
// Channel.AdminLog.StartedLiveStream
_FormattedString * _Nonnull _Lnk(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 738, _0);
}
// Channel.AdminLog.StartedVoiceChat
_FormattedString * _Nonnull _Lnl(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 739, _0);
}
// Channel.AdminLog.TitleAllEvents
NSString * _Nonnull _Lnm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 740);
}
// Channel.AdminLog.TitleSelectedEvents
NSString * _Nonnull _Lnn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 741);
}
// Channel.AdminLog.TopicChangedIcon
_FormattedString * _Nonnull _Lno(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2) {
    return getFormatted3(_self, 742, _0, _1, _2);
}
// Channel.AdminLog.TopicClosed
_FormattedString * _Nonnull _Lnp(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 743, _0, _1);
}
// Channel.AdminLog.TopicCreated
_FormattedString * _Nonnull _Lnq(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 744, _0, _1);
}
// Channel.AdminLog.TopicDeleted
_FormattedString * _Nonnull _Lnr(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 745, _0, _1);
}
// Channel.AdminLog.TopicHidden
_FormattedString * _Nonnull _Lns(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 746, _0, _1);
}
// Channel.AdminLog.TopicPinned
_FormattedString * _Nonnull _Lnt(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 747, _0, _1);
}
// Channel.AdminLog.TopicRemovedIcon
_FormattedString * _Nonnull _Lnu(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 748, _0, _1);
}
// Channel.AdminLog.TopicRenamed
_FormattedString * _Nonnull _Lnv(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2) {
    return getFormatted3(_self, 749, _0, _1, _2);
}
// Channel.AdminLog.TopicRenamedWithIcon
_FormattedString * _Nonnull _Lnw(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2, NSString * _Nonnull _3) {
    return getFormatted4(_self, 750, _0, _1, _2, _3);
}
// Channel.AdminLog.TopicRenamedWithRemovedIcon
_FormattedString * _Nonnull _Lnx(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2) {
    return getFormatted3(_self, 751, _0, _1, _2);
}
// Channel.AdminLog.TopicReopened
_FormattedString * _Nonnull _Lny(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 752, _0, _1);
}
// Channel.AdminLog.TopicUnhidden
_FormattedString * _Nonnull _Lnz(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 753, _0, _1);
}
// Channel.AdminLog.TopicUnpinned
_FormattedString * _Nonnull _LnA(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 754, _0, _1);
}
// Channel.AdminLog.TopicsDisabled
_FormattedString * _Nonnull _LnB(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 755, _0);
}
// Channel.AdminLog.TopicsEnabled
_FormattedString * _Nonnull _LnC(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 756, _0);
}
// Channel.AdminLog.UnmutedMutedParticipant
_FormattedString * _Nonnull _LnD(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 757, _0, _1);
}
// Channel.AdminLog.UpdatedParticipantVolume
_FormattedString * _Nonnull _LnE(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2) {
    return getFormatted3(_self, 758, _0, _1, _2);
}
// Channel.AdminLogFilter.AdminsAll
NSString * _Nonnull _LnF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 759);
}
// Channel.AdminLogFilter.AdminsTitle
NSString * _Nonnull _LnG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 760);
}
// Channel.AdminLogFilter.ChannelEventsInfo
NSString * _Nonnull _LnH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 761);
}
// Channel.AdminLogFilter.EventsAdmins
NSString * _Nonnull _LnI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 762);
}
// Channel.AdminLogFilter.EventsAll
NSString * _Nonnull _LnJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 763);
}
// Channel.AdminLogFilter.EventsCalls
NSString * _Nonnull _LnK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 764);
}
// Channel.AdminLogFilter.EventsDeletedMessages
NSString * _Nonnull _LnL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 765);
}
// Channel.AdminLogFilter.EventsEditedMessages
NSString * _Nonnull _LnM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 766);
}
// Channel.AdminLogFilter.EventsInfo
NSString * _Nonnull _LnN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 767);
}
// Channel.AdminLogFilter.EventsInviteLinks
NSString * _Nonnull _LnO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 768);
}
// Channel.AdminLogFilter.EventsLeaving
NSString * _Nonnull _LnP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 769);
}
// Channel.AdminLogFilter.EventsLeavingSubscribers
NSString * _Nonnull _LnQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 770);
}
// Channel.AdminLogFilter.EventsLiveStreams
NSString * _Nonnull _LnR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 771);
}
// Channel.AdminLogFilter.EventsNewMembers
NSString * _Nonnull _LnS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 772);
}
// Channel.AdminLogFilter.EventsNewSubscribers
NSString * _Nonnull _LnT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 773);
}
// Channel.AdminLogFilter.EventsPinned
NSString * _Nonnull _LnU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 774);
}
// Channel.AdminLogFilter.EventsRestrictions
NSString * _Nonnull _LnV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 775);
}
// Channel.AdminLogFilter.EventsSentMessages
NSString * _Nonnull _LnW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 776);
}
// Channel.AdminLogFilter.EventsTitle
NSString * _Nonnull _LnX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 777);
}
// Channel.AdminLogFilter.Title
NSString * _Nonnull _LnY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 778);
}
// Channel.BanList.BlockedTitle
NSString * _Nonnull _LnZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 779);
}
// Channel.BanList.RestrictedTitle
NSString * _Nonnull _Loa(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 780);
}
// Channel.BanUser.BlockFor
NSString * _Nonnull _Lob(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 781);
}
// Channel.BanUser.PermissionAddMembers
NSString * _Nonnull _Loc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 782);
}
// Channel.BanUser.PermissionChangeGroupInfo
NSString * _Nonnull _Lod(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 783);
}
// Channel.BanUser.PermissionEmbedLinks
NSString * _Nonnull _Loe(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 784);
}
// Channel.BanUser.PermissionReadMessages
NSString * _Nonnull _Lof(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 785);
}
// Channel.BanUser.PermissionSendFile
NSString * _Nonnull _Log(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 786);
}
// Channel.BanUser.PermissionSendMedia
NSString * _Nonnull _Loh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 787);
}
// Channel.BanUser.PermissionSendMessages
NSString * _Nonnull _Loi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 788);
}
// Channel.BanUser.PermissionSendMusic
NSString * _Nonnull _Loj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 789);
}
// Channel.BanUser.PermissionSendPhoto
NSString * _Nonnull _Lok(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 790);
}
// Channel.BanUser.PermissionSendPolls
NSString * _Nonnull _Lol(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 791);
}
// Channel.BanUser.PermissionSendStickersAndGifs
NSString * _Nonnull _Lom(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 792);
}
// Channel.BanUser.PermissionSendVideo
NSString * _Nonnull _Lon(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 793);
}
// Channel.BanUser.PermissionSendVideoMessage
NSString * _Nonnull _Loo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 794);
}
// Channel.BanUser.PermissionSendVoiceMessage
NSString * _Nonnull _Lop(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 795);
}
// Channel.BanUser.PermissionsHeader
NSString * _Nonnull _Loq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 796);
}
// Channel.BanUser.Title
NSString * _Nonnull _Lor(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 797);
}
// Channel.BanUser.Unban
NSString * _Nonnull _Los(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 798);
}
// Channel.BlackList.Title
NSString * _Nonnull _Lot(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 799);
}
// Channel.BotDoesntSupportGroups
NSString * _Nonnull _Lou(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 800);
}
// Channel.ChannelSubscribersHeader
NSString * _Nonnull _Lov(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 801);
}
// Channel.CommentsGroup.Header
NSString * _Nonnull _Low(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 802);
}
// Channel.CommentsGroup.HeaderGroupSet
_FormattedString * _Nonnull _Lox(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 803, _0);
}
// Channel.CommentsGroup.HeaderSet
_FormattedString * _Nonnull _Loy(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 804, _0);
}
// Channel.DiscussionGroup
NSString * _Nonnull _Loz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 805);
}
// Channel.DiscussionGroup.Create
NSString * _Nonnull _LoA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 806);
}
// Channel.DiscussionGroup.Header
NSString * _Nonnull _LoB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 807);
}
// Channel.DiscussionGroup.HeaderGroupSet
_FormattedString * _Nonnull _LoC(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 808, _0);
}
// Channel.DiscussionGroup.HeaderLabel
NSString * _Nonnull _LoD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 809);
}
// Channel.DiscussionGroup.HeaderSet
_FormattedString * _Nonnull _LoE(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 810, _0);
}
// Channel.DiscussionGroup.Info
NSString * _Nonnull _LoF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 811);
}
// Channel.DiscussionGroup.LinkGroup
NSString * _Nonnull _LoG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 812);
}
// Channel.DiscussionGroup.MakeHistoryPublic
NSString * _Nonnull _LoH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 813);
}
// Channel.DiscussionGroup.MakeHistoryPublicProceed
NSString * _Nonnull _LoI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 814);
}
// Channel.DiscussionGroup.PrivateChannel
NSString * _Nonnull _LoJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 815);
}
// Channel.DiscussionGroup.PrivateChannelLink
_FormattedString * _Nonnull _LoK(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 816, _0, _1);
}
// Channel.DiscussionGroup.PrivateGroup
NSString * _Nonnull _LoL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 817);
}
// Channel.DiscussionGroup.PublicChannelLink
_FormattedString * _Nonnull _LoM(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 818, _0, _1);
}
// Channel.DiscussionGroup.SearchPlaceholder
NSString * _Nonnull _LoN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 819);
}
// Channel.DiscussionGroup.UnlinkChannel
NSString * _Nonnull _LoO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 820);
}
// Channel.DiscussionGroup.UnlinkGroup
NSString * _Nonnull _LoP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 821);
}
// Channel.DiscussionGroupAdd
NSString * _Nonnull _LoQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 822);
}
// Channel.DiscussionGroupInfo
NSString * _Nonnull _LoR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 823);
}
// Channel.DiscussionMessageUnavailable
NSString * _Nonnull _LoS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 824);
}
// Channel.Edit.AboutItem
NSString * _Nonnull _LoT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 825);
}
// Channel.Edit.LinkItem
NSString * _Nonnull _LoU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 826);
}
// Channel.Edit.PrivatePublicLinkAlert
NSString * _Nonnull _LoV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 827);
}
// Channel.EditAdmin.CannotEdit
NSString * _Nonnull _LoW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 828);
}
// Channel.EditAdmin.PermissinAddAdminOff
NSString * _Nonnull _LoX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 829);
}
// Channel.EditAdmin.PermissinAddAdminOn
NSString * _Nonnull _LoY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 830);
}
// Channel.EditAdmin.PermissionAddAdmins
NSString * _Nonnull _LoZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 831);
}
// Channel.EditAdmin.PermissionBanUsers
NSString * _Nonnull _Lpa(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 832);
}
// Channel.EditAdmin.PermissionChangeInfo
NSString * _Nonnull _Lpb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 833);
}
// Channel.EditAdmin.PermissionCreateTopics
NSString * _Nonnull _Lpc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 834);
}
// Channel.EditAdmin.PermissionDeleteMessages
NSString * _Nonnull _Lpd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 835);
}
// Channel.EditAdmin.PermissionDeleteMessagesOfOthers
NSString * _Nonnull _Lpe(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 836);
}
// Channel.EditAdmin.PermissionEditMessages
NSString * _Nonnull _Lpf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 837);
}
// Channel.EditAdmin.PermissionEnabledByDefault
NSString * _Nonnull _Lpg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 838);
}
// Channel.EditAdmin.PermissionInviteMembers
NSString * _Nonnull _Lph(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 839);
}
// Channel.EditAdmin.PermissionInviteSubscribers
NSString * _Nonnull _Lpi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 840);
}
// Channel.EditAdmin.PermissionInviteViaLink
NSString * _Nonnull _Lpj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 841);
}
// Channel.EditAdmin.PermissionManageTopics
NSString * _Nonnull _Lpk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 842);
}
// Channel.EditAdmin.PermissionPinMessages
NSString * _Nonnull _Lpl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 843);
}
// Channel.EditAdmin.PermissionPostMessages
NSString * _Nonnull _Lpm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 844);
}
// Channel.EditAdmin.PermissionsHeader
NSString * _Nonnull _Lpn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 845);
}
// Channel.EditAdmin.TransferOwnership
NSString * _Nonnull _Lpo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 846);
}
// Channel.EditMessageErrorGeneric
NSString * _Nonnull _Lpp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 847);
}
// Channel.ErrorAccessDenied
NSString * _Nonnull _Lpq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 848);
}
// Channel.ErrorAddBlocked
NSString * _Nonnull _Lpr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 849);
}
// Channel.ErrorAddTooMuch
NSString * _Nonnull _Lps(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 850);
}
// Channel.ErrorAdminsTooMuch
NSString * _Nonnull _Lpt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 851);
}
// Channel.Info.Banned
NSString * _Nonnull _Lpu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 852);
}
// Channel.Info.BlackList
NSString * _Nonnull _Lpv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 853);
}
// Channel.Info.Description
NSString * _Nonnull _Lpw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 854);
}
// Channel.Info.Management
NSString * _Nonnull _Lpx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 855);
}
// Channel.Info.Members
NSString * _Nonnull _Lpy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 856);
}
// Channel.Info.Stickers
NSString * _Nonnull _Lpz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 857);
}
// Channel.Info.Subscribers
NSString * _Nonnull _LpA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 858);
}
// Channel.JoinChannel
NSString * _Nonnull _LpB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 859);
}
// Channel.LeaveChannel
NSString * _Nonnull _LpC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 860);
}
// Channel.LinkItem
NSString * _Nonnull _LpD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 861);
}
// Channel.Management.AddModerator
NSString * _Nonnull _LpE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 862);
}
// Channel.Management.AddModeratorHelp
NSString * _Nonnull _LpF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 863);
}
// Channel.Management.ErrorNotMember
_FormattedString * _Nonnull _LpG(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 864, _0);
}
// Channel.Management.LabelAdministrator
NSString * _Nonnull _LpH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 865);
}
// Channel.Management.LabelCreator
NSString * _Nonnull _LpI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 866);
}
// Channel.Management.LabelEditor
NSString * _Nonnull _LpJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 867);
}
// Channel.Management.LabelOwner
NSString * _Nonnull _LpK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 868);
}
// Channel.Management.PromotedBy
_FormattedString * _Nonnull _LpL(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 869, _0);
}
// Channel.Management.RemovedBy
_FormattedString * _Nonnull _LpM(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 870, _0);
}
// Channel.Management.RestrictedBy
_FormattedString * _Nonnull _LpN(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 871, _0);
}
// Channel.Management.Title
NSString * _Nonnull _LpO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 872);
}
// Channel.Members.AddAdminErrorBlacklisted
NSString * _Nonnull _LpP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 873);
}
// Channel.Members.AddAdminErrorNotAMember
NSString * _Nonnull _LpQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 874);
}
// Channel.Members.AddBannedErrorAdmin
NSString * _Nonnull _LpR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 875);
}
// Channel.Members.AddMembers
NSString * _Nonnull _LpS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 876);
}
// Channel.Members.AddMembersHelp
NSString * _Nonnull _LpT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 877);
}
// Channel.Members.Contacts
NSString * _Nonnull _LpU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 878);
}
// Channel.Members.InviteLink
NSString * _Nonnull _LpV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 879);
}
// Channel.Members.Other
NSString * _Nonnull _LpW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 880);
}
// Channel.Members.Title
NSString * _Nonnull _LpX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 881);
}
// Channel.MessagePhotoRemoved
NSString * _Nonnull _LpY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 882);
}
// Channel.MessagePhotoUpdated
NSString * _Nonnull _LpZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 883);
}
// Channel.MessageTitleUpdated
_FormattedString * _Nonnull _Lqa(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 884, _0);
}
// Channel.MessageVideoUpdated
NSString * _Nonnull _Lqb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 885);
}
// Channel.Moderator.AccessLevelRevoke
NSString * _Nonnull _Lqc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 886);
}
// Channel.Moderator.Title
NSString * _Nonnull _Lqd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 887);
}
// Channel.NotificationLoading
NSString * _Nonnull _Lqe(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 888);
}
// Channel.OwnershipTransfer.ChangeOwner
NSString * _Nonnull _Lqf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 889);
}
// Channel.OwnershipTransfer.DescriptionInfo
_FormattedString * _Nonnull _Lqg(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 890, _0, _1);
}
// Channel.OwnershipTransfer.EnterPassword
NSString * _Nonnull _Lqh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 891);
}
// Channel.OwnershipTransfer.EnterPasswordText
NSString * _Nonnull _Lqi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 892);
}
// Channel.OwnershipTransfer.ErrorAdminsTooMuch
NSString * _Nonnull _Lqj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 893);
}
// Channel.OwnershipTransfer.ErrorPrivacyRestricted
NSString * _Nonnull _Lqk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 894);
}
// Channel.OwnershipTransfer.ErrorPublicChannelsTooMuch
NSString * _Nonnull _Lql(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 895);
}
// Channel.OwnershipTransfer.PasswordPlaceholder
NSString * _Nonnull _Lqm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 896);
}
// Channel.OwnershipTransfer.Title
NSString * _Nonnull _Lqn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 897);
}
// Channel.OwnershipTransfer.TransferCompleted
_FormattedString * _Nonnull _Lqo(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 898, _0, _1);
}
// Channel.Setup.ActivateAlertShow
NSString * _Nonnull _Lqp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 899);
}
// Channel.Setup.ActivateAlertText
NSString * _Nonnull _Lqq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 900);
}
// Channel.Setup.ActivateAlertTitle
NSString * _Nonnull _Lqr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 901);
}
// Channel.Setup.ActiveLimitReachedError
NSString * _Nonnull _Lqs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 902);
}
// Channel.Setup.DeactivateAlertHide
NSString * _Nonnull _Lqt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 903);
}
// Channel.Setup.DeactivateAlertText
NSString * _Nonnull _Lqu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 904);
}
// Channel.Setup.DeactivateAlertTitle
NSString * _Nonnull _Lqv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 905);
}
// Channel.Setup.LinkTypePrivate
NSString * _Nonnull _Lqw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 906);
}
// Channel.Setup.LinkTypePublic
NSString * _Nonnull _Lqx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 907);
}
// Channel.Setup.LinksOrder
NSString * _Nonnull _Lqy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 908);
}
// Channel.Setup.LinksOrderInfo
NSString * _Nonnull _Lqz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 909);
}
// Channel.Setup.PublicLink
NSString * _Nonnull _LqA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 910);
}
// Channel.Setup.PublicNoLink
NSString * _Nonnull _LqB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 911);
}
// Channel.Setup.Title
NSString * _Nonnull _LqC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 912);
}
// Channel.Setup.TypeHeader
NSString * _Nonnull _LqD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 913);
}
// Channel.Setup.TypePrivate
NSString * _Nonnull _LqE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 914);
}
// Channel.Setup.TypePrivateHelp
NSString * _Nonnull _LqF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 915);
}
// Channel.Setup.TypePublic
NSString * _Nonnull _LqG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 916);
}
// Channel.Setup.TypePublicHelp
NSString * _Nonnull _LqH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 917);
}
// Channel.SignMessages
NSString * _Nonnull _LqI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 918);
}
// Channel.SignMessages.Help
NSString * _Nonnull _LqJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 919);
}
// Channel.Status
NSString * _Nonnull _LqK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 920);
}
// Channel.Stickers.CreateYourOwn
NSString * _Nonnull _LqL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 921);
}
// Channel.Stickers.NotFound
NSString * _Nonnull _LqM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 922);
}
// Channel.Stickers.NotFoundHelp
NSString * _Nonnull _LqN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 923);
}
// Channel.Stickers.Placeholder
NSString * _Nonnull _LqO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 924);
}
// Channel.Stickers.Searching
NSString * _Nonnull _LqP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 925);
}
// Channel.Stickers.YourStickers
NSString * _Nonnull _LqQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 926);
}
// Channel.Subscribers.Title
NSString * _Nonnull _LqR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 927);
}
// Channel.TitleInfo
NSString * _Nonnull _LqS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 928);
}
// Channel.TooMuchBots
NSString * _Nonnull _LqT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 929);
}
// Channel.TypeSetup.Title
NSString * _Nonnull _LqU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 930);
}
// Channel.UpdatePhotoItem
NSString * _Nonnull _LqV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 931);
}
// Channel.Username.CheckingUsername
NSString * _Nonnull _LqW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 932);
}
// Channel.Username.CreatePrivateLinkHelp
NSString * _Nonnull _LqX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 933);
}
// Channel.Username.CreatePublicLinkHelp
NSString * _Nonnull _LqY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 934);
}
// Channel.Username.Help
NSString * _Nonnull _LqZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 935);
}
// Channel.Username.InvalidCharacters
NSString * _Nonnull _Lra(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 936);
}
// Channel.Username.InvalidEndsWithUnderscore
NSString * _Nonnull _Lrb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 937);
}
// Channel.Username.InvalidStartsWithNumber
NSString * _Nonnull _Lrc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 938);
}
// Channel.Username.InvalidStartsWithUnderscore
NSString * _Nonnull _Lrd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 939);
}
// Channel.Username.InvalidTaken
NSString * _Nonnull _Lre(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 940);
}
// Channel.Username.InvalidTooShort
NSString * _Nonnull _Lrf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 941);
}
// Channel.Username.LinkHint
_FormattedString * _Nonnull _Lrg(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 942, _0);
}
// Channel.Username.RevokeExistingUsernamesInfo
NSString * _Nonnull _Lrh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 943);
}
// Channel.Username.Title
NSString * _Nonnull _Lri(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 944);
}
// Channel.Username.UsernameIsAvailable
_FormattedString * _Nonnull _Lrj(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 945, _0);
}
// Channel.Username.UsernamePurchaseAvailable
NSString * _Nonnull _Lrk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 946);
}
// ChannelInfo.AddParticipantConfirmation
_FormattedString * _Nonnull _Lrl(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 947, _0);
}
// ChannelInfo.ChannelForbidden
_FormattedString * _Nonnull _Lrm(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 948, _0);
}
// ChannelInfo.ConfirmLeave
NSString * _Nonnull _Lrn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 949);
}
// ChannelInfo.CreateExternalStream
NSString * _Nonnull _Lro(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 950);
}
// ChannelInfo.CreateLiveStream
NSString * _Nonnull _Lrp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 951);
}
// ChannelInfo.CreateVoiceChat
NSString * _Nonnull _Lrq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 952);
}
// ChannelInfo.DeleteChannel
NSString * _Nonnull _Lrr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 953);
}
// ChannelInfo.DeleteChannelConfirmation
NSString * _Nonnull _Lrs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 954);
}
// ChannelInfo.DeleteGroup
NSString * _Nonnull _Lrt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 955);
}
// ChannelInfo.DeleteGroupConfirmation
NSString * _Nonnull _Lru(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 956);
}
// ChannelInfo.FakeChannelWarning
NSString * _Nonnull _Lrv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 957);
}
// ChannelInfo.InviteLink.RevokeAlert.Text
NSString * _Nonnull _Lrw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 958);
}
// ChannelInfo.ScamChannelWarning
NSString * _Nonnull _Lrx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 959);
}
// ChannelInfo.ScheduleLiveStream
NSString * _Nonnull _Lry(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 960);
}
// ChannelInfo.ScheduleVoiceChat
NSString * _Nonnull _Lrz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 961);
}
// ChannelInfo.Stats
NSString * _Nonnull _LrA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 962);
}
// ChannelIntro.CreateChannel
NSString * _Nonnull _LrB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 963);
}
// ChannelIntro.Text
NSString * _Nonnull _LrC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 964);
}
// ChannelIntro.Title
NSString * _Nonnull _LrD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 965);
}
// ChannelMembers.ChannelAdminsTitle
NSString * _Nonnull _LrE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 966);
}
// ChannelMembers.GroupAdminsTitle
NSString * _Nonnull _LrF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 967);
}
// ChannelMembers.WhoCanAddMembers
NSString * _Nonnull _LrG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 968);
}
// ChannelMembers.WhoCanAddMembers.Admins
NSString * _Nonnull _LrH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 969);
}
// ChannelMembers.WhoCanAddMembers.AllMembers
NSString * _Nonnull _LrI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 970);
}
// ChannelMembers.WhoCanAddMembersAdminsHelp
NSString * _Nonnull _LrJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 971);
}
// ChannelMembers.WhoCanAddMembersAllHelp
NSString * _Nonnull _LrK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 972);
}
// ChannelRemoved.RemoveInfo
NSString * _Nonnull _LrL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 973);
}
// Chat.AttachmentLimitReached
NSString * _Nonnull _LrM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 974);
}
// Chat.AttachmentMultipleFilesDisabled
NSString * _Nonnull _LrN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 975);
}
// Chat.AttachmentMultipleForwardDisabled
NSString * _Nonnull _LrO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 976);
}
// Chat.AudioTranscriptionFeedbackTip
NSString * _Nonnull _LrP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 977);
}
// Chat.AudioTranscriptionRateAction
NSString * _Nonnull _LrQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 978);
}
// Chat.ClearReactionsAlertAction
NSString * _Nonnull _LrR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 979);
}
// Chat.ClearReactionsAlertText
NSString * _Nonnull _LrS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 980);
}
// Chat.ContextReactionCount
NSString * _Nonnull _LrT(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 981, value);
}
// Chat.ContextViewAsMessages
NSString * _Nonnull _LrU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 982);
}
// Chat.ContextViewAsTopics
NSString * _Nonnull _LrV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 983);
}
// Chat.CreateTopic
NSString * _Nonnull _LrW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 984);
}
// Chat.DeleteMessagesConfirmation
NSString * _Nonnull _LrX(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 985, value);
}
// Chat.EmptyTopicPlaceholder.Text
NSString * _Nonnull _LrY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 986);
}
// Chat.EmptyTopicPlaceholder.Title
NSString * _Nonnull _LrZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 987);
}
// Chat.ErrorInvoiceNotFound
NSString * _Nonnull _Lsa(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 988);
}
// Chat.GenericPsaTooltip
NSString * _Nonnull _Lsb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 989);
}
// Chat.Gifs.SavedSectionHeader
NSString * _Nonnull _Lsc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 990);
}
// Chat.Gifs.TrendingSectionHeader
NSString * _Nonnull _Lsd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 991);
}
// Chat.JumpToDate
NSString * _Nonnull _Lse(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 992);
}
// Chat.Message.TopicAuthorBadge
NSString * _Nonnull _Lsf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 993);
}
// Chat.MessageRangeDeleted.ForBothSides
NSString * _Nonnull _Lsg(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 994, value);
}
// Chat.MessageRangeDeleted.ForMe
NSString * _Nonnull _Lsh(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 995, value);
}
// Chat.MessagesUnpinned
NSString * _Nonnull _Lsi(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 996, value);
}
// Chat.MultipleTextMessagesDisabled
NSString * _Nonnull _Lsj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 997);
}
// Chat.MultipleTypingMore
_FormattedString * _Nonnull _Lsk(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 998, _0, _1);
}
// Chat.MultipleTypingPair
_FormattedString * _Nonnull _Lsl(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 999, _0, _1);
}
// Chat.NavigationNoChannels
NSString * _Nonnull _Lsm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1000);
}
// Chat.NextChannelArchivedSwipeAction
NSString * _Nonnull _Lsn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1001);
}
// Chat.NextChannelArchivedSwipeProgress
NSString * _Nonnull _Lso(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1002);
}
// Chat.NextChannelFolderSwipeAction
_FormattedString * _Nonnull _Lsp(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1003, _0);
}
// Chat.NextChannelFolderSwipeProgress
_FormattedString * _Nonnull _Lsq(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1004, _0);
}
// Chat.NextChannelSameLocationSwipeAction
NSString * _Nonnull _Lsr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1005);
}
// Chat.NextChannelSameLocationSwipeProgress
NSString * _Nonnull _Lss(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1006);
}
// Chat.NextChannelUnarchivedSwipeAction
NSString * _Nonnull _Lst(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1007);
}
// Chat.NextChannelUnarchivedSwipeProgress
NSString * _Nonnull _Lsu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1008);
}
// Chat.OutgoingContextMixedReactionCount
_FormattedString * _Nonnull _Lsv(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 1009, _0, _1);
}
// Chat.OutgoingContextReactionCount
NSString * _Nonnull _Lsw(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 1010, value);
}
// Chat.PanelCustomStatusInfo
_FormattedString * _Nonnull _Lsx(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1011, _0);
}
// Chat.PanelForumModeReplyText
NSString * _Nonnull _Lsy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1012);
}
// Chat.PanelHidePinnedMessages
NSString * _Nonnull _Lsz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1013);
}
// Chat.PanelRestartTopic
NSString * _Nonnull _LsA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1014);
}
// Chat.PanelTopicClosedText
NSString * _Nonnull _LsB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1015);
}
// Chat.PanelUnpinAllMessages
NSString * _Nonnull _LsC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1016);
}
// Chat.PinnedListPreview.HidePinnedMessages
NSString * _Nonnull _LsD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1017);
}
// Chat.PinnedListPreview.ShowAllMessages
NSString * _Nonnull _LsE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1018);
}
// Chat.PinnedListPreview.UnpinAllMessages
NSString * _Nonnull _LsF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1019);
}
// Chat.PinnedMessagesHiddenText
NSString * _Nonnull _LsG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1020);
}
// Chat.PinnedMessagesHiddenTitle
NSString * _Nonnull _LsH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1021);
}
// Chat.PlaceholderTextNotAllowed
NSString * _Nonnull _LsI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1022);
}
// Chat.PremiumReactionToastAction
NSString * _Nonnull _LsJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1023);
}
// Chat.PremiumReactionToastTitle
NSString * _Nonnull _LsK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1024);
}
// Chat.PsaTooltip.covid
NSString * _Nonnull _LsL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1025);
}
// Chat.ReactionSection.Popular
NSString * _Nonnull _LsM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1026);
}
// Chat.ReactionSection.Recent
NSString * _Nonnull _LsN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1027);
}
// Chat.SaveForNotifications
NSString * _Nonnull _LsO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1028);
}
// Chat.SendAllowedContentPeerText
_FormattedString * _Nonnull _LsP(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 1029, _0, _1);
}
// Chat.SendAllowedContentText
_FormattedString * _Nonnull _LsQ(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1030, _0);
}
// Chat.SendAllowedContentTypeFile
NSString * _Nonnull _LsR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1031);
}
// Chat.SendAllowedContentTypeMusic
NSString * _Nonnull _LsS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1032);
}
// Chat.SendAllowedContentTypePhoto
NSString * _Nonnull _LsT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1033);
}
// Chat.SendAllowedContentTypeSticker
NSString * _Nonnull _LsU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1034);
}
// Chat.SendAllowedContentTypeText
NSString * _Nonnull _LsV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1035);
}
// Chat.SendAllowedContentTypeVideo
NSString * _Nonnull _LsW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1036);
}
// Chat.SendAllowedContentTypeVideoMessage
NSString * _Nonnull _LsX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1037);
}
// Chat.SendAllowedContentTypeVoiceMessage
NSString * _Nonnull _LsY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1038);
}
// Chat.SendNotAllowedAudioMessage
NSString * _Nonnull _LsZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1039);
}
// Chat.SendNotAllowedFile
NSString * _Nonnull _Lta(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1040);
}
// Chat.SendNotAllowedMusic
NSString * _Nonnull _Ltb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1041);
}
// Chat.SendNotAllowedPeerText
_FormattedString * _Nonnull _Ltc(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1042, _0);
}
// Chat.SendNotAllowedPhoto
NSString * _Nonnull _Ltd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1043);
}
// Chat.SendNotAllowedText
NSString * _Nonnull _Lte(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1044);
}
// Chat.SendNotAllowedVideo
NSString * _Nonnull _Ltf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1045);
}
// Chat.SendNotAllowedVideoMessage
NSString * _Nonnull _Ltg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1046);
}
// Chat.SlowmodeAttachmentLimitReached
NSString * _Nonnull _Lth(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1047);
}
// Chat.SlowmodeSendError
NSString * _Nonnull _Lti(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1048);
}
// Chat.SlowmodeTooltip
_FormattedString * _Nonnull _Ltj(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1049, _0);
}
// Chat.SlowmodeTooltipPending
NSString * _Nonnull _Ltk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1050);
}
// Chat.TitlePinnedMessages
NSString * _Nonnull _Ltl(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 1051, value);
}
// Chat.UnsendMyMessages
NSString * _Nonnull _Ltm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1052);
}
// Chat.UnsendMyMessagesAlertTitle
_FormattedString * _Nonnull _Ltn(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1053, _0);
}
// ChatAdmins.AdminLabel
NSString * _Nonnull _Lto(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1054);
}
// ChatAdmins.AllMembersAreAdmins
NSString * _Nonnull _Ltp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1055);
}
// ChatAdmins.AllMembersAreAdminsOffHelp
NSString * _Nonnull _Ltq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1056);
}
// ChatAdmins.AllMembersAreAdminsOnHelp
NSString * _Nonnull _Ltr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1057);
}
// ChatAdmins.Title
NSString * _Nonnull _Lts(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1058);
}
// ChatContextMenu.EmojiSet
NSString * _Nonnull _Ltt(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 1059, value);
}
// ChatContextMenu.EmojiSetSingle
_FormattedString * _Nonnull _Ltu(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1060, _0);
}
// ChatContextMenu.MessageViewsPrivacyTip
NSString * _Nonnull _Ltv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1061);
}
// ChatContextMenu.ReactionEmojiSet
NSString * _Nonnull _Ltw(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 1062, value);
}
// ChatContextMenu.ReactionEmojiSetSingle
_FormattedString * _Nonnull _Ltx(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1063, _0);
}
// ChatContextMenu.TextSelectionTip
NSString * _Nonnull _Lty(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1064);
}
// ChatImport.CreateGroupAlertImportAction
NSString * _Nonnull _Ltz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1065);
}
// ChatImport.CreateGroupAlertText
_FormattedString * _Nonnull _LtA(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1066, _0);
}
// ChatImport.CreateGroupAlertTitle
NSString * _Nonnull _LtB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1067);
}
// ChatImport.SelectionConfirmationAlertImportAction
NSString * _Nonnull _LtC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1068);
}
// ChatImport.SelectionConfirmationAlertTitle
NSString * _Nonnull _LtD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1069);
}
// ChatImport.SelectionConfirmationGroupWithTitle
_FormattedString * _Nonnull _LtE(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 1070, _0, _1);
}
// ChatImport.SelectionConfirmationGroupWithoutTitle
_FormattedString * _Nonnull _LtF(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1071, _0);
}
// ChatImport.SelectionConfirmationUserWithTitle
_FormattedString * _Nonnull _LtG(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 1072, _0, _1);
}
// ChatImport.SelectionConfirmationUserWithoutTitle
_FormattedString * _Nonnull _LtH(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1073, _0);
}
// ChatImport.SelectionErrorGroupGeneric
NSString * _Nonnull _LtI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1074);
}
// ChatImport.SelectionErrorNotAdmin
NSString * _Nonnull _LtJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1075);
}
// ChatImport.Title
NSString * _Nonnull _LtK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1076);
}
// ChatImport.UserErrorNotMutual
NSString * _Nonnull _LtL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1077);
}
// ChatImportActivity.ErrorGeneric
NSString * _Nonnull _LtM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1078);
}
// ChatImportActivity.ErrorInvalidChatType
NSString * _Nonnull _LtN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1079);
}
// ChatImportActivity.ErrorLimitExceeded
NSString * _Nonnull _LtO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1080);
}
// ChatImportActivity.ErrorNotAdmin
NSString * _Nonnull _LtP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1081);
}
// ChatImportActivity.ErrorUserBlocked
NSString * _Nonnull _LtQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1082);
}
// ChatImportActivity.InProgress
NSString * _Nonnull _LtR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1083);
}
// ChatImportActivity.OpenApp
NSString * _Nonnull _LtS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1084);
}
// ChatImportActivity.Retry
NSString * _Nonnull _LtT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1085);
}
// ChatImportActivity.Success
NSString * _Nonnull _LtU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1086);
}
// ChatImportActivity.Title
NSString * _Nonnull _LtV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1087);
}
// ChatList.AddChatsToFolder
NSString * _Nonnull _LtW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1088);
}
// ChatList.AddFolder
NSString * _Nonnull _LtX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1089);
}
// ChatList.AddedToFolderTooltip
_FormattedString * _Nonnull _LtY(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 1090, _0, _1);
}
// ChatList.Archive
NSString * _Nonnull _LtZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1091);
}
// ChatList.ArchiveAction
NSString * _Nonnull _Lua(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1092);
}
// ChatList.ArchivedChatsTitle
NSString * _Nonnull _Lub(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1093);
}
// ChatList.AutoarchiveSuggestion.OpenSettings
NSString * _Nonnull _Luc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1094);
}
// ChatList.AutoarchiveSuggestion.Text
NSString * _Nonnull _Lud(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1095);
}
// ChatList.AutoarchiveSuggestion.Title
NSString * _Nonnull _Lue(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1096);
}
// ChatList.ChatTypesSection
NSString * _Nonnull _Luf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1097);
}
// ChatList.ClearChatConfirmation
_FormattedString * _Nonnull _Lug(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1098, _0);
}
// ChatList.ClearSearchHistory
NSString * _Nonnull _Luh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1099);
}
// ChatList.CloseAction
NSString * _Nonnull _Lui(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1100);
}
// ChatList.Context.AddToContacts
NSString * _Nonnull _Luj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1101);
}
// ChatList.Context.AddToFolder
NSString * _Nonnull _Luk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1102);
}
// ChatList.Context.Archive
NSString * _Nonnull _Lul(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1103);
}
// ChatList.Context.Back
NSString * _Nonnull _Lum(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1104);
}
// ChatList.Context.CloseTopic
NSString * _Nonnull _Lun(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1105);
}
// ChatList.Context.Delete
NSString * _Nonnull _Luo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1106);
}
// ChatList.Context.HideArchive
NSString * _Nonnull _Lup(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1107);
}
// ChatList.Context.JoinChannel
NSString * _Nonnull _Luq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1108);
}
// ChatList.Context.JoinChat
NSString * _Nonnull _Lur(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1109);
}
// ChatList.Context.MarkAllAsRead
NSString * _Nonnull _Lus(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1110);
}
// ChatList.Context.MarkAsRead
NSString * _Nonnull _Lut(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1111);
}
// ChatList.Context.MarkAsUnread
NSString * _Nonnull _Luu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1112);
}
// ChatList.Context.Mute
NSString * _Nonnull _Luv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1113);
}
// ChatList.Context.Pin
NSString * _Nonnull _Luw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1114);
}
// ChatList.Context.RemoveFromFolder
NSString * _Nonnull _Lux(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1115);
}
// ChatList.Context.RemoveFromRecents
NSString * _Nonnull _Luy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1116);
}
// ChatList.Context.ReopenTopic
NSString * _Nonnull _Luz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1117);
}
// ChatList.Context.Select
NSString * _Nonnull _LuA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1118);
}
// ChatList.Context.Unarchive
NSString * _Nonnull _LuB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1119);
}
// ChatList.Context.UnhideArchive
NSString * _Nonnull _LuC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1120);
}
// ChatList.Context.Unmute
NSString * _Nonnull _LuD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1121);
}
// ChatList.Context.Unpin
NSString * _Nonnull _LuE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1122);
}
// ChatList.DeleteAndLeaveGroupConfirmation
_FormattedString * _Nonnull _LuF(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1123, _0);
}
// ChatList.DeleteChat
NSString * _Nonnull _LuG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1124);
}
// ChatList.DeleteChatConfirmation
_FormattedString * _Nonnull _LuH(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1125, _0);
}
// ChatList.DeleteConfirmation
NSString * _Nonnull _LuI(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 1126, value);
}
// ChatList.DeleteForAllMembers
NSString * _Nonnull _LuJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1127);
}
// ChatList.DeleteForAllMembersConfirmationText
NSString * _Nonnull _LuK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1128);
}
// ChatList.DeleteForAllSubscribers
NSString * _Nonnull _LuL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1129);
}
// ChatList.DeleteForAllSubscribersConfirmationText
NSString * _Nonnull _LuM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1130);
}
// ChatList.DeleteForCurrentUser
NSString * _Nonnull _LuN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1131);
}
// ChatList.DeleteForEveryone
_FormattedString * _Nonnull _LuO(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1132, _0);
}
// ChatList.DeleteForEveryoneConfirmationAction
NSString * _Nonnull _LuP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1133);
}
// ChatList.DeleteForEveryoneConfirmationText
NSString * _Nonnull _LuQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1134);
}
// ChatList.DeleteForEveryoneConfirmationTitle
NSString * _Nonnull _LuR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1135);
}
// ChatList.DeleteSavedMessagesConfirmation
NSString * _Nonnull _LuS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1136);
}
// ChatList.DeleteSavedMessagesConfirmationAction
NSString * _Nonnull _LuT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1137);
}
// ChatList.DeleteSavedMessagesConfirmationText
NSString * _Nonnull _LuU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1138);
}
// ChatList.DeleteSavedMessagesConfirmationTitle
NSString * _Nonnull _LuV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1139);
}
// ChatList.DeleteSecretChatConfirmation
_FormattedString * _Nonnull _LuW(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1140, _0);
}
// ChatList.DeleteThreadsConfirmation
NSString * _Nonnull _LuX(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 1141, value);
}
// ChatList.DeleteTopicConfirmationAction
NSString * _Nonnull _LuY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1142);
}
// ChatList.DeleteTopicConfirmationText
NSString * _Nonnull _LuZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1143);
}
// ChatList.DeletedChats
NSString * _Nonnull _Lva(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 1144, value);
}
// ChatList.DeletedThreads
NSString * _Nonnull _Lvb(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 1145, value);
}
// ChatList.EditFolder
NSString * _Nonnull _Lvc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1146);
}
// ChatList.EditFolders
NSString * _Nonnull _Lvd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1147);
}
// ChatList.EmptyChatList
NSString * _Nonnull _Lve(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1148);
}
// ChatList.EmptyChatListEditFilter
NSString * _Nonnull _Lvf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1149);
}
// ChatList.EmptyChatListFilterText
NSString * _Nonnull _Lvg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1150);
}
// ChatList.EmptyChatListFilterTitle
NSString * _Nonnull _Lvh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1151);
}
// ChatList.EmptyChatListNewMessage
NSString * _Nonnull _Lvi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1152);
}
// ChatList.EmptyTopicsCreate
NSString * _Nonnull _Lvj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1153);
}
// ChatList.EmptyTopicsDescription
NSString * _Nonnull _Lvk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1154);
}
// ChatList.EmptyTopicsShowAsMessages
NSString * _Nonnull _Lvl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1155);
}
// ChatList.EmptyTopicsTitle
NSString * _Nonnull _Lvm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1156);
}
// ChatList.FolderAllChats
NSString * _Nonnull _Lvn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1157);
}
// ChatList.GeneralHidden
NSString * _Nonnull _Lvo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1158);
}
// ChatList.GeneralHiddenInfo
NSString * _Nonnull _Lvp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1159);
}
// ChatList.GeneralUnhidden
NSString * _Nonnull _Lvq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1160);
}
// ChatList.GeneralUnhiddenInfo
NSString * _Nonnull _Lvr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1161);
}
// ChatList.GenericPsaAlert
NSString * _Nonnull _Lvs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1162);
}
// ChatList.GenericPsaLabel
NSString * _Nonnull _Lvt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1163);
}
// ChatList.HeaderImportIntoAnExistingGroup
NSString * _Nonnull _Lvu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1164);
}
// ChatList.HideAction
NSString * _Nonnull _Lvv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1165);
}
// ChatList.LabelAutodeleteAfter
_FormattedString * _Nonnull _Lvw(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1166, _0);
}
// ChatList.LabelAutodeleteDisabled
NSString * _Nonnull _Lvx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1167);
}
// ChatList.LeaveGroupConfirmation
_FormattedString * _Nonnull _Lvy(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1168, _0);
}
// ChatList.MaxThreadPinsFinalText
NSString * _Nonnull _Lvz(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 1169, value);
}
// ChatList.MessageFiles
NSString * _Nonnull _LvA(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 1170, value);
}
// ChatList.MessageMusic
NSString * _Nonnull _LvB(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 1171, value);
}
// ChatList.MessagePhotos
NSString * _Nonnull _LvC(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 1172, value);
}
// ChatList.MessageVideos
NSString * _Nonnull _LvD(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 1173, value);
}
// ChatList.Mute
NSString * _Nonnull _LvE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1174);
}
// ChatList.PeerTypeBot
NSString * _Nonnull _LvF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1175);
}
// ChatList.PeerTypeChannel
NSString * _Nonnull _LvG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1176);
}
// ChatList.PeerTypeContact
NSString * _Nonnull _LvH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1177);
}
// ChatList.PeerTypeGroup
NSString * _Nonnull _LvI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1178);
}
// ChatList.PeerTypeNonContact
NSString * _Nonnull _LvJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1179);
}
// ChatList.PremiumAnnualDiscountText
NSString * _Nonnull _LvK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1180);
}
// ChatList.PremiumAnnualDiscountTitle
_FormattedString * _Nonnull _LvL(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1181, _0);
}
// ChatList.PremiumAnnualUpgradeText
NSString * _Nonnull _LvM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1182);
}
// ChatList.PremiumAnnualUpgradeTitle
_FormattedString * _Nonnull _LvN(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1183, _0);
}
// ChatList.PsaAlert.covid
NSString * _Nonnull _LvO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1184);
}
// ChatList.PsaLabel.covid
NSString * _Nonnull _LvP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1185);
}
// ChatList.Read
NSString * _Nonnull _LvQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1186);
}
// ChatList.ReadAll
NSString * _Nonnull _LvR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1187);
}
// ChatList.RemoveFolder
NSString * _Nonnull _LvS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1188);
}
// ChatList.RemoveFolderAction
NSString * _Nonnull _LvT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1189);
}
// ChatList.RemoveFolderConfirmation
NSString * _Nonnull _LvU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1190);
}
// ChatList.RemovedFromFolderTooltip
_FormattedString * _Nonnull _LvV(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 1191, _0, _1);
}
// ChatList.ReorderTabs
NSString * _Nonnull _LvW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1192);
}
// ChatList.Search.FilterChats
NSString * _Nonnull _LvX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1193);
}
// ChatList.Search.FilterDownloads
NSString * _Nonnull _LvY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1194);
}
// ChatList.Search.FilterFiles
NSString * _Nonnull _LvZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1195);
}
// ChatList.Search.FilterLinks
NSString * _Nonnull _Lwa(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1196);
}
// ChatList.Search.FilterMedia
NSString * _Nonnull _Lwb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1197);
}
// ChatList.Search.FilterMusic
NSString * _Nonnull _Lwc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1198);
}
// ChatList.Search.FilterTopics
NSString * _Nonnull _Lwd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1199);
}
// ChatList.Search.FilterVoice
NSString * _Nonnull _Lwe(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1200);
}
// ChatList.Search.Messages
NSString * _Nonnull _Lwf(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 1201, value);
}
// ChatList.Search.NoResults
NSString * _Nonnull _Lwg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1202);
}
// ChatList.Search.NoResultsDescription
NSString * _Nonnull _Lwh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1203);
}
// ChatList.Search.NoResultsFilter
NSString * _Nonnull _Lwi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1204);
}
// ChatList.Search.NoResultsFitlerFiles
NSString * _Nonnull _Lwj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1205);
}
// ChatList.Search.NoResultsFitlerLinks
NSString * _Nonnull _Lwk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1206);
}
// ChatList.Search.NoResultsFitlerMedia
NSString * _Nonnull _Lwl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1207);
}
// ChatList.Search.NoResultsFitlerMusic
NSString * _Nonnull _Lwm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1208);
}
// ChatList.Search.NoResultsFitlerVoice
NSString * _Nonnull _Lwn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1209);
}
// ChatList.Search.NoResultsQueryDescription
_FormattedString * _Nonnull _Lwo(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1210, _0);
}
// ChatList.Search.ShowLess
NSString * _Nonnull _Lwp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1211);
}
// ChatList.Search.ShowMore
NSString * _Nonnull _Lwq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1212);
}
// ChatList.SelectedChats
NSString * _Nonnull _Lwr(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 1213, value);
}
// ChatList.SelectedTopics
NSString * _Nonnull _Lws(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 1214, value);
}
// ChatList.StartAction
NSString * _Nonnull _Lwt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1215);
}
// ChatList.StorageHintText
NSString * _Nonnull _Lwu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1216);
}
// ChatList.StorageHintTitle
_FormattedString * _Nonnull _Lwv(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1217, _0);
}
// ChatList.TabIconFoldersTooltipEmptyFolders
NSString * _Nonnull _Lww(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1218);
}
// ChatList.TabIconFoldersTooltipNonEmptyFolders
NSString * _Nonnull _Lwx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1219);
}
// ChatList.Tabs.All
NSString * _Nonnull _Lwy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1220);
}
// ChatList.Tabs.AllChats
NSString * _Nonnull _Lwz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1221);
}
// ChatList.ThreadHideAction
NSString * _Nonnull _LwA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1222);
}
// ChatList.ThreadUnhideAction
NSString * _Nonnull _LwB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1223);
}
// ChatList.UnarchiveAction
NSString * _Nonnull _LwC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1224);
}
// ChatList.UndoArchiveHiddenText
NSString * _Nonnull _LwD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1225);
}
// ChatList.UndoArchiveHiddenTitle
NSString * _Nonnull _LwE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1226);
}
// ChatList.UndoArchiveMultipleTitle
NSString * _Nonnull _LwF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1227);
}
// ChatList.UndoArchiveRevealedText
NSString * _Nonnull _LwG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1228);
}
// ChatList.UndoArchiveRevealedTitle
NSString * _Nonnull _LwH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1229);
}
// ChatList.UndoArchiveText1
NSString * _Nonnull _LwI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1230);
}
// ChatList.UndoArchiveTitle
NSString * _Nonnull _LwJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1231);
}
// ChatList.UnhideAction
NSString * _Nonnull _LwK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1232);
}
// ChatList.Unmute
NSString * _Nonnull _LwL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1233);
}
// ChatList.UserReacted
_FormattedString * _Nonnull _LwM(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1234, _0);
}
// ChatListFilter.AddChatsSearchPlaceholder
NSString * _Nonnull _LwN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1235);
}
// ChatListFilter.AddChatsTitle
NSString * _Nonnull _LwO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1236);
}
// ChatListFilter.ShowMoreChats
NSString * _Nonnull _LwP(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 1237, value);
}
// ChatListFolder.AddChats
NSString * _Nonnull _LwQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1238);
}
// ChatListFolder.CategoryArchived
NSString * _Nonnull _LwR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1239);
}
// ChatListFolder.CategoryBots
NSString * _Nonnull _LwS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1240);
}
// ChatListFolder.CategoryChannels
NSString * _Nonnull _LwT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1241);
}
// ChatListFolder.CategoryContacts
NSString * _Nonnull _LwU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1242);
}
// ChatListFolder.CategoryGroups
NSString * _Nonnull _LwV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1243);
}
// ChatListFolder.CategoryMuted
NSString * _Nonnull _LwW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1244);
}
// ChatListFolder.CategoryNonContacts
NSString * _Nonnull _LwX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1245);
}
// ChatListFolder.CategoryRead
NSString * _Nonnull _LwY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1246);
}
// ChatListFolder.DiscardCancel
NSString * _Nonnull _LwZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1247);
}
// ChatListFolder.DiscardConfirmation
NSString * _Nonnull _Lxa(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1248);
}
// ChatListFolder.DiscardDiscard
NSString * _Nonnull _Lxb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1249);
}
// ChatListFolder.ExcludeChatsTitle
NSString * _Nonnull _Lxc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1250);
}
// ChatListFolder.ExcludeSectionInfo
NSString * _Nonnull _Lxd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1251);
}
// ChatListFolder.ExcludedSectionHeader
NSString * _Nonnull _Lxe(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1252);
}
// ChatListFolder.IncludeChatsTitle
NSString * _Nonnull _Lxf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1253);
}
// ChatListFolder.IncludeSectionInfo
NSString * _Nonnull _Lxg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1254);
}
// ChatListFolder.IncludedSectionHeader
NSString * _Nonnull _Lxh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1255);
}
// ChatListFolder.NameBots
NSString * _Nonnull _Lxi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1256);
}
// ChatListFolder.NameChannels
NSString * _Nonnull _Lxj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1257);
}
// ChatListFolder.NameContacts
NSString * _Nonnull _Lxk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1258);
}
// ChatListFolder.NameGroups
NSString * _Nonnull _Lxl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1259);
}
// ChatListFolder.NameNonContacts
NSString * _Nonnull _Lxm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1260);
}
// ChatListFolder.NameNonMuted
NSString * _Nonnull _Lxn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1261);
}
// ChatListFolder.NamePlaceholder
NSString * _Nonnull _Lxo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1262);
}
// ChatListFolder.NameSectionHeader
NSString * _Nonnull _Lxp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1263);
}
// ChatListFolder.NameUnread
NSString * _Nonnull _Lxq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1264);
}
// ChatListFolder.TitleCreate
NSString * _Nonnull _Lxr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1265);
}
// ChatListFolder.TitleEdit
NSString * _Nonnull _Lxs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1266);
}
// ChatListFolderSettings.AddRecommended
NSString * _Nonnull _Lxt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1267);
}
// ChatListFolderSettings.EditFoldersInfo
NSString * _Nonnull _Lxu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1268);
}
// ChatListFolderSettings.FoldersSection
NSString * _Nonnull _Lxv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1269);
}
// ChatListFolderSettings.Info
NSString * _Nonnull _Lxw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1270);
}
// ChatListFolderSettings.NewFolder
NSString * _Nonnull _Lxx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1271);
}
// ChatListFolderSettings.RecommendedFoldersSection
NSString * _Nonnull _Lxy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1272);
}
// ChatListFolderSettings.RecommendedNewFolder
NSString * _Nonnull _Lxz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1273);
}
// ChatListFolderSettings.SubscribeToMoveAll
NSString * _Nonnull _LxA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1274);
}
// ChatListFolderSettings.SubscribeToMoveAllAction
NSString * _Nonnull _LxB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1275);
}
// ChatListFolderSettings.Title
NSString * _Nonnull _LxC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1276);
}
// ChatSearch.ResultsTooltip
NSString * _Nonnull _LxD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1277);
}
// ChatSearch.SearchPlaceholder
NSString * _Nonnull _LxE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1278);
}
// ChatSettings.Appearance
NSString * _Nonnull _LxF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1279);
}
// ChatSettings.AutoDownloadDocuments
NSString * _Nonnull _LxG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1280);
}
// ChatSettings.AutoDownloadEnabled
NSString * _Nonnull _LxH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1281);
}
// ChatSettings.AutoDownloadPhotos
NSString * _Nonnull _LxI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1282);
}
// ChatSettings.AutoDownloadReset
NSString * _Nonnull _LxJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1283);
}
// ChatSettings.AutoDownloadSettings.Delimeter
NSString * _Nonnull _LxK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1284);
}
// ChatSettings.AutoDownloadSettings.OffForAll
NSString * _Nonnull _LxL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1285);
}
// ChatSettings.AutoDownloadSettings.TypeFile
_FormattedString * _Nonnull _LxM(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1286, _0);
}
// ChatSettings.AutoDownloadSettings.TypeMedia
_FormattedString * _Nonnull _LxN(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1287, _0);
}
// ChatSettings.AutoDownloadSettings.TypePhoto
NSString * _Nonnull _LxO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1288);
}
// ChatSettings.AutoDownloadSettings.TypeVideo
_FormattedString * _Nonnull _LxP(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1289, _0);
}
// ChatSettings.AutoDownloadTitle
NSString * _Nonnull _LxQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1290);
}
// ChatSettings.AutoDownloadUsingCellular
NSString * _Nonnull _LxR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1291);
}
// ChatSettings.AutoDownloadUsingWiFi
NSString * _Nonnull _LxS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1292);
}
// ChatSettings.AutoDownloadVideoMessages
NSString * _Nonnull _LxT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1293);
}
// ChatSettings.AutoDownloadVideos
NSString * _Nonnull _LxU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1294);
}
// ChatSettings.AutoDownloadVoiceMessages
NSString * _Nonnull _LxV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1295);
}
// ChatSettings.AutoPlayAnimations
NSString * _Nonnull _LxW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1296);
}
// ChatSettings.AutoPlayGifs
NSString * _Nonnull _LxX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1297);
}
// ChatSettings.AutoPlayTitle
NSString * _Nonnull _LxY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1298);
}
// ChatSettings.AutoPlayVideos
NSString * _Nonnull _LxZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1299);
}
// ChatSettings.AutomaticAudioDownload
NSString * _Nonnull _Lya(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1300);
}
// ChatSettings.AutomaticPhotoDownload
NSString * _Nonnull _Lyb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1301);
}
// ChatSettings.AutomaticVideoMessageDownload
NSString * _Nonnull _Lyc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1302);
}
// ChatSettings.Cache
NSString * _Nonnull _Lyd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1303);
}
// ChatSettings.ConnectionType.Title
NSString * _Nonnull _Lye(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1304);
}
// ChatSettings.ConnectionType.UseProxy
NSString * _Nonnull _Lyf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1305);
}
// ChatSettings.ConnectionType.UseSocks5
NSString * _Nonnull _Lyg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1306);
}
// ChatSettings.DownloadInBackground
NSString * _Nonnull _Lyh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1307);
}
// ChatSettings.DownloadInBackgroundInfo
NSString * _Nonnull _Lyi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1308);
}
// ChatSettings.Groups
NSString * _Nonnull _Lyj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1309);
}
// ChatSettings.IntentsSettings
NSString * _Nonnull _Lyk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1310);
}
// ChatSettings.OpenLinksIn
NSString * _Nonnull _Lyl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1311);
}
// ChatSettings.Other
NSString * _Nonnull _Lym(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1312);
}
// ChatSettings.PrivateChats
NSString * _Nonnull _Lyn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1313);
}
// ChatSettings.Stickers
NSString * _Nonnull _Lyo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1314);
}
// ChatSettings.StickersAndReactions
NSString * _Nonnull _Lyp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1315);
}
// ChatSettings.TextSize
NSString * _Nonnull _Lyq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1316);
}
// ChatSettings.TextSizeUnits
NSString * _Nonnull _Lyr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1317);
}
// ChatSettings.Title
NSString * _Nonnull _Lys(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1318);
}
// ChatSettings.UseLessDataForCalls
NSString * _Nonnull _Lyt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1319);
}
// ChatSettings.WidgetSettings
NSString * _Nonnull _Lyu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1320);
}
// ChatState.Connecting
NSString * _Nonnull _Lyv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1321);
}
// ChatState.ConnectingToProxy
NSString * _Nonnull _Lyw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1322);
}
// ChatState.Updating
NSString * _Nonnull _Lyx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1323);
}
// ChatState.WaitingForNetwork
NSString * _Nonnull _Lyy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1324);
}
// Checkout.Email
NSString * _Nonnull _Lyz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1325);
}
// Checkout.EnterPassword
NSString * _Nonnull _LyA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1326);
}
// Checkout.ErrorGeneric
NSString * _Nonnull _LyB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1327);
}
// Checkout.ErrorInvoiceAlreadyPaid
NSString * _Nonnull _LyC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1328);
}
// Checkout.ErrorPaymentFailed
NSString * _Nonnull _LyD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1329);
}
// Checkout.ErrorPrecheckoutFailed
NSString * _Nonnull _LyE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1330);
}
// Checkout.ErrorProviderAccountInvalid
NSString * _Nonnull _LyF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1331);
}
// Checkout.ErrorProviderAccountTimeout
NSString * _Nonnull _LyG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1332);
}
// Checkout.LiabilityAlertTitle
NSString * _Nonnull _LyH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1333);
}
// Checkout.Name
NSString * _Nonnull _LyI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1334);
}
// Checkout.NewCard.CardholderNamePlaceholder
NSString * _Nonnull _LyJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1335);
}
// Checkout.NewCard.CardholderNameTitle
NSString * _Nonnull _LyK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1336);
}
// Checkout.NewCard.PaymentCard
NSString * _Nonnull _LyL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1337);
}
// Checkout.NewCard.PostcodePlaceholder
NSString * _Nonnull _LyM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1338);
}
// Checkout.NewCard.PostcodeTitle
NSString * _Nonnull _LyN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1339);
}
// Checkout.NewCard.SaveInfo
NSString * _Nonnull _LyO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1340);
}
// Checkout.NewCard.SaveInfoEnableHelp
NSString * _Nonnull _LyP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1341);
}
// Checkout.NewCard.SaveInfoHelp
NSString * _Nonnull _LyQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1342);
}
// Checkout.NewCard.Title
NSString * _Nonnull _LyR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1343);
}
// Checkout.OptionalTipItem
NSString * _Nonnull _LyS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1344);
}
// Checkout.OptionalTipItemPlaceholder
NSString * _Nonnull _LyT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1345);
}
// Checkout.PasswordEntry.Pay
NSString * _Nonnull _LyU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1346);
}
// Checkout.PasswordEntry.Text
_FormattedString * _Nonnull _LyV(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1347, _0);
}
// Checkout.PasswordEntry.Title
NSString * _Nonnull _LyW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1348);
}
// Checkout.PayNone
NSString * _Nonnull _LyX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1349);
}
// Checkout.PayPrice
_FormattedString * _Nonnull _LyY(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1350, _0);
}
// Checkout.PayWithFaceId
NSString * _Nonnull _LyZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1351);
}
// Checkout.PayWithTouchId
NSString * _Nonnull _Lza(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1352);
}
// Checkout.PaymentLiabilityAlert
NSString * _Nonnull _Lzb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1353);
}
// Checkout.PaymentLiabilityBothAlert
NSString * _Nonnull _Lzc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1354);
}
// Checkout.PaymentMethod
NSString * _Nonnull _Lzd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1355);
}
// Checkout.PaymentMethod.New
NSString * _Nonnull _Lze(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1356);
}
// Checkout.PaymentMethod.Title
NSString * _Nonnull _Lzf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1357);
}
// Checkout.Phone
NSString * _Nonnull _Lzg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1358);
}
// Checkout.Receipt.Title
NSString * _Nonnull _Lzh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1359);
}
// Checkout.SavePasswordTimeout
_FormattedString * _Nonnull _Lzi(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1360, _0);
}
// Checkout.SavePasswordTimeoutAndFaceId
_FormattedString * _Nonnull _Lzj(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1361, _0);
}
// Checkout.SavePasswordTimeoutAndTouchId
_FormattedString * _Nonnull _Lzk(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1362, _0);
}
// Checkout.ShippingAddress
NSString * _Nonnull _Lzl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1363);
}
// Checkout.ShippingMethod
NSString * _Nonnull _Lzm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1364);
}
// Checkout.ShippingOption.Title
NSString * _Nonnull _Lzn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1365);
}
// Checkout.SuccessfulTooltip
_FormattedString * _Nonnull _Lzo(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 1366, _0, _1);
}
// Checkout.TipItem
NSString * _Nonnull _Lzp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1367);
}
// Checkout.Title
NSString * _Nonnull _Lzq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1368);
}
// Checkout.TotalAmount
NSString * _Nonnull _Lzr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1369);
}
// Checkout.TotalPaidAmount
NSString * _Nonnull _Lzs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1370);
}
// Checkout.WebConfirmation.Title
NSString * _Nonnull _Lzt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1371);
}
// CheckoutInfo.ErrorCityInvalid
NSString * _Nonnull _Lzu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1372);
}
// CheckoutInfo.ErrorEmailInvalid
NSString * _Nonnull _Lzv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1373);
}
// CheckoutInfo.ErrorNameInvalid
NSString * _Nonnull _Lzw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1374);
}
// CheckoutInfo.ErrorPhoneInvalid
NSString * _Nonnull _Lzx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1375);
}
// CheckoutInfo.ErrorPostcodeInvalid
NSString * _Nonnull _Lzy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1376);
}
// CheckoutInfo.ErrorShippingNotAvailable
NSString * _Nonnull _Lzz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1377);
}
// CheckoutInfo.ErrorStateInvalid
NSString * _Nonnull _LzA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1378);
}
// CheckoutInfo.Pay
NSString * _Nonnull _LzB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1379);
}
// CheckoutInfo.ReceiverInfoEmail
NSString * _Nonnull _LzC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1380);
}
// CheckoutInfo.ReceiverInfoEmailPlaceholder
NSString * _Nonnull _LzD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1381);
}
// CheckoutInfo.ReceiverInfoName
NSString * _Nonnull _LzE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1382);
}
// CheckoutInfo.ReceiverInfoNamePlaceholder
NSString * _Nonnull _LzF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1383);
}
// CheckoutInfo.ReceiverInfoPhone
NSString * _Nonnull _LzG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1384);
}
// CheckoutInfo.ReceiverInfoTitle
NSString * _Nonnull _LzH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1385);
}
// CheckoutInfo.SaveInfo
NSString * _Nonnull _LzI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1386);
}
// CheckoutInfo.SaveInfoHelp
NSString * _Nonnull _LzJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1387);
}
// CheckoutInfo.ShippingInfoAddress1
NSString * _Nonnull _LzK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1388);
}
// CheckoutInfo.ShippingInfoAddress1Placeholder
NSString * _Nonnull _LzL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1389);
}
// CheckoutInfo.ShippingInfoAddress2
NSString * _Nonnull _LzM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1390);
}
// CheckoutInfo.ShippingInfoAddress2Placeholder
NSString * _Nonnull _LzN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1391);
}
// CheckoutInfo.ShippingInfoCity
NSString * _Nonnull _LzO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1392);
}
// CheckoutInfo.ShippingInfoCityPlaceholder
NSString * _Nonnull _LzP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1393);
}
// CheckoutInfo.ShippingInfoCountry
NSString * _Nonnull _LzQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1394);
}
// CheckoutInfo.ShippingInfoCountryPlaceholder
NSString * _Nonnull _LzR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1395);
}
// CheckoutInfo.ShippingInfoPostcode
NSString * _Nonnull _LzS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1396);
}
// CheckoutInfo.ShippingInfoPostcodePlaceholder
NSString * _Nonnull _LzT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1397);
}
// CheckoutInfo.ShippingInfoState
NSString * _Nonnull _LzU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1398);
}
// CheckoutInfo.ShippingInfoStatePlaceholder
NSString * _Nonnull _LzV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1399);
}
// CheckoutInfo.ShippingInfoTitle
NSString * _Nonnull _LzW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1400);
}
// CheckoutInfo.Title
NSString * _Nonnull _LzX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1401);
}
// ClearCache.Clear
NSString * _Nonnull _LzY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1402);
}
// ClearCache.ClearCache
NSString * _Nonnull _LzZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1403);
}
// ClearCache.ClearDescription
NSString * _Nonnull _LAa(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1404);
}
// ClearCache.Description
NSString * _Nonnull _LAb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1405);
}
// ClearCache.Forever
NSString * _Nonnull _LAc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1406);
}
// ClearCache.FreeSpace
NSString * _Nonnull _LAd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1407);
}
// ClearCache.FreeSpaceDescription
NSString * _Nonnull _LAe(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1408);
}
// ClearCache.KeepOpenedDescription
NSString * _Nonnull _LAf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1409);
}
// ClearCache.Never
NSString * _Nonnull _LAg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1410);
}
// ClearCache.NoProgress
NSString * _Nonnull _LAh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1411);
}
// ClearCache.Progress
_FormattedString * _Nonnull _LAi(_PresentationStrings * _Nonnull _self, NSInteger _0) {
    return getFormatted1(_self, 1412, @(_0));
}
// ClearCache.StorageCache
NSString * _Nonnull _LAj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1413);
}
// ClearCache.StorageFree
NSString * _Nonnull _LAk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1414);
}
// ClearCache.StorageOtherApps
NSString * _Nonnull _LAl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1415);
}
// ClearCache.StorageServiceFiles
NSString * _Nonnull _LAm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1416);
}
// ClearCache.StorageTitle
_FormattedString * _Nonnull _LAn(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1417, _0);
}
// ClearCache.StorageUsage
NSString * _Nonnull _LAo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1418);
}
// ClearCache.Success
_FormattedString * _Nonnull _LAp(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 1419, _0, _1);
}
// Clipboard.SendPhoto
NSString * _Nonnull _LAq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1420);
}
// CloudStorage.Title
NSString * _Nonnull _LAr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1421);
}
// CommentsGroup.ErrorAccessDenied
NSString * _Nonnull _LAs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1422);
}
// Common.ActionNotAllowedError
NSString * _Nonnull _LAt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1423);
}
// Common.Back
NSString * _Nonnull _LAu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1424);
}
// Common.Cancel
NSString * _Nonnull _LAv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1425);
}
// Common.ChoosePhoto
NSString * _Nonnull _LAw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1426);
}
// Common.Close
NSString * _Nonnull _LAx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1427);
}
// Common.Create
NSString * _Nonnull _LAy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1428);
}
// Common.Delete
NSString * _Nonnull _LAz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1429);
}
// Common.Done
NSString * _Nonnull _LAA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1430);
}
// Common.Edit
NSString * _Nonnull _LAB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1431);
}
// Common.More
NSString * _Nonnull _LAC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1432);
}
// Common.Next
NSString * _Nonnull _LAD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1433);
}
// Common.No
NSString * _Nonnull _LAE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1434);
}
// Common.NotNow
NSString * _Nonnull _LAF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1435);
}
// Common.OK
NSString * _Nonnull _LAG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1436);
}
// Common.Paste
NSString * _Nonnull _LAH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1437);
}
// Common.Save
NSString * _Nonnull _LAI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1438);
}
// Common.Search
NSString * _Nonnull _LAJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1439);
}
// Common.Select
NSString * _Nonnull _LAK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1440);
}
// Common.TakePhoto
NSString * _Nonnull _LAL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1441);
}
// Common.TakePhotoOrVideo
NSString * _Nonnull _LAM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1442);
}
// Common.Yes
NSString * _Nonnull _LAN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1443);
}
// Common.edit
NSString * _Nonnull _LAO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1444);
}
// Common.of
NSString * _Nonnull _LAP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1445);
}
// Compatibility.SecretMediaVersionTooLow
_FormattedString * _Nonnull _LAQ(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 1446, _0, _1);
}
// Compose.ChannelMembers
NSString * _Nonnull _LAR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1447);
}
// Compose.ChannelTokenListPlaceholder
NSString * _Nonnull _LAS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1448);
}
// Compose.Create
NSString * _Nonnull _LAT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1449);
}
// Compose.GroupTokenListPlaceholder
NSString * _Nonnull _LAU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1450);
}
// Compose.NewChannel
NSString * _Nonnull _LAV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1451);
}
// Compose.NewChannel.Members
NSString * _Nonnull _LAW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1452);
}
// Compose.NewEncryptedChat
NSString * _Nonnull _LAX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1453);
}
// Compose.NewEncryptedChatTitle
NSString * _Nonnull _LAY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1454);
}
// Compose.NewGroup
NSString * _Nonnull _LAZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1455);
}
// Compose.NewGroupTitle
NSString * _Nonnull _LBa(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1456);
}
// Compose.NewMessage
NSString * _Nonnull _LBb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1457);
}
// Compose.TokenListPlaceholder
NSString * _Nonnull _LBc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1458);
}
// ContactInfo.BirthdayLabel
NSString * _Nonnull _LBd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1459);
}
// ContactInfo.Job
NSString * _Nonnull _LBe(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1460);
}
// ContactInfo.Note
NSString * _Nonnull _LBf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1461);
}
// ContactInfo.PhoneLabelHome
NSString * _Nonnull _LBg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1462);
}
// ContactInfo.PhoneLabelHomeFax
NSString * _Nonnull _LBh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1463);
}
// ContactInfo.PhoneLabelMain
NSString * _Nonnull _LBi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1464);
}
// ContactInfo.PhoneLabelMobile
NSString * _Nonnull _LBj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1465);
}
// ContactInfo.PhoneLabelOther
NSString * _Nonnull _LBk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1466);
}
// ContactInfo.PhoneLabelPager
NSString * _Nonnull _LBl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1467);
}
// ContactInfo.PhoneLabelWork
NSString * _Nonnull _LBm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1468);
}
// ContactInfo.PhoneLabelWorkFax
NSString * _Nonnull _LBn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1469);
}
// ContactInfo.PhoneNumberHidden
NSString * _Nonnull _LBo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1470);
}
// ContactInfo.Title
NSString * _Nonnull _LBp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1471);
}
// ContactInfo.URLLabelHomepage
NSString * _Nonnull _LBq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1472);
}
// ContactList.Context.Call
NSString * _Nonnull _LBr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1473);
}
// ContactList.Context.SendMessage
NSString * _Nonnull _LBs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1474);
}
// ContactList.Context.StartSecretChat
NSString * _Nonnull _LBt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1475);
}
// ContactList.Context.VideoCall
NSString * _Nonnull _LBu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1476);
}
// Contacts.AccessDeniedError
NSString * _Nonnull _LBv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1477);
}
// Contacts.AccessDeniedHelpLandscape
_FormattedString * _Nonnull _LBw(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1478, _0);
}
// Contacts.AccessDeniedHelpON
NSString * _Nonnull _LBx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1479);
}
// Contacts.AccessDeniedHelpPortrait
_FormattedString * _Nonnull _LBy(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1480, _0);
}
// Contacts.AddContact
NSString * _Nonnull _LBz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1481);
}
// Contacts.AddPeopleNearby
NSString * _Nonnull _LBA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1482);
}
// Contacts.AddPhoneNumber
_FormattedString * _Nonnull _LBB(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1483, _0);
}
// Contacts.DeselectAll
NSString * _Nonnull _LBC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1484);
}
// Contacts.FailedToSendInvitesMessage
NSString * _Nonnull _LBD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1485);
}
// Contacts.GlobalSearch
NSString * _Nonnull _LBE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1486);
}
// Contacts.ImportersCount
NSString * _Nonnull _LBF(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 1487, value);
}
// Contacts.InviteContacts
NSString * _Nonnull _LBG(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 1488, value);
}
// Contacts.InviteFriends
NSString * _Nonnull _LBH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1489);
}
// Contacts.InviteSearchLabel
NSString * _Nonnull _LBI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1490);
}
// Contacts.InviteToTelegram
NSString * _Nonnull _LBJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1491);
}
// Contacts.MemberSearchSectionTitleGroup
NSString * _Nonnull _LBK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1492);
}
// Contacts.NotRegisteredSection
NSString * _Nonnull _LBL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1493);
}
// Contacts.PermissionsAllow
NSString * _Nonnull _LBM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1494);
}
// Contacts.PermissionsAllowInSettings
NSString * _Nonnull _LBN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1495);
}
// Contacts.PermissionsEnable
NSString * _Nonnull _LBO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1496);
}
// Contacts.PermissionsKeepDisabled
NSString * _Nonnull _LBP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1497);
}
// Contacts.PermissionsSuppressWarningText
NSString * _Nonnull _LBQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1498);
}
// Contacts.PermissionsSuppressWarningTitle
NSString * _Nonnull _LBR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1499);
}
// Contacts.PermissionsText
NSString * _Nonnull _LBS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1500);
}
// Contacts.PermissionsTitle
NSString * _Nonnull _LBT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1501);
}
// Contacts.PhoneNumber
NSString * _Nonnull _LBU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1502);
}
// Contacts.QrCode.MyCode
NSString * _Nonnull _LBV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1503);
}
// Contacts.QrCode.NoCodeFound
NSString * _Nonnull _LBW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1504);
}
// Contacts.ScanQrCode
NSString * _Nonnull _LBX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1505);
}
// Contacts.Search.NoResults
NSString * _Nonnull _LBY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1506);
}
// Contacts.Search.NoResultsQueryDescription
_FormattedString * _Nonnull _LBZ(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1507, _0);
}
// Contacts.SearchLabel
NSString * _Nonnull _LCa(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1508);
}
// Contacts.SearchUsersAndGroupsLabel
NSString * _Nonnull _LCb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1509);
}
// Contacts.SelectAll
NSString * _Nonnull _LCc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1510);
}
// Contacts.ShareTelegram
NSString * _Nonnull _LCd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1511);
}
// Contacts.Sort
NSString * _Nonnull _LCe(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1512);
}
// Contacts.Sort.ByLastSeen
NSString * _Nonnull _LCf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1513);
}
// Contacts.Sort.ByName
NSString * _Nonnull _LCg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1514);
}
// Contacts.SortBy
NSString * _Nonnull _LCh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1515);
}
// Contacts.SortByName
NSString * _Nonnull _LCi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1516);
}
// Contacts.SortByPresence
NSString * _Nonnull _LCj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1517);
}
// Contacts.SortedByName
NSString * _Nonnull _LCk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1518);
}
// Contacts.SortedByPresence
NSString * _Nonnull _LCl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1519);
}
// Contacts.TabTitle
NSString * _Nonnull _LCm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1520);
}
// Contacts.Title
NSString * _Nonnull _LCn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1521);
}
// Contacts.TopSection
NSString * _Nonnull _LCo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1522);
}
// Contacts.VoiceOver.AddContact
NSString * _Nonnull _LCp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1523);
}
// Conversation.AddContact
NSString * _Nonnull _LCq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1524);
}
// Conversation.AddMembers
NSString * _Nonnull _LCr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1525);
}
// Conversation.AddNameToContacts
_FormattedString * _Nonnull _LCs(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1526, _0);
}
// Conversation.AddToContacts
NSString * _Nonnull _LCt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1527);
}
// Conversation.AddToReadingList
NSString * _Nonnull _LCu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1528);
}
// Conversation.Admin
NSString * _Nonnull _LCv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1529);
}
// Conversation.AlsoClearCacheTitle
NSString * _Nonnull _LCw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1530);
}
// Conversation.ApplyLocalization
NSString * _Nonnull _LCx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1531);
}
// Conversation.AudioRateTooltipNormal
NSString * _Nonnull _LCy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1532);
}
// Conversation.AudioRateTooltipSpeedUp
NSString * _Nonnull _LCz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1533);
}
// Conversation.AutoremoveActionEdit
NSString * _Nonnull _LCA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1534);
}
// Conversation.AutoremoveActionEnable
NSString * _Nonnull _LCB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1535);
}
// Conversation.AutoremoveChanged
_FormattedString * _Nonnull _LCC(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1536, _0);
}
// Conversation.AutoremoveOff
NSString * _Nonnull _LCD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1537);
}
// Conversation.AutoremoveRemainingDays
NSString * _Nonnull _LCE(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 1538, value);
}
// Conversation.AutoremoveRemainingTime
_FormattedString * _Nonnull _LCF(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1539, _0);
}
// Conversation.AutoremoveTimerRemovedChannel
NSString * _Nonnull _LCG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1540);
}
// Conversation.AutoremoveTimerRemovedGroup
NSString * _Nonnull _LCH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1541);
}
// Conversation.AutoremoveTimerRemovedUser
_FormattedString * _Nonnull _LCI(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1542, _0);
}
// Conversation.AutoremoveTimerRemovedUserYou
NSString * _Nonnull _LCJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1543);
}
// Conversation.AutoremoveTimerSetChannel
_FormattedString * _Nonnull _LCK(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1544, _0);
}
// Conversation.AutoremoveTimerSetGroup
_FormattedString * _Nonnull _LCL(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1545, _0);
}
// Conversation.AutoremoveTimerSetToastText
_FormattedString * _Nonnull _LCM(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1546, _0);
}
// Conversation.AutoremoveTimerSetUser
_FormattedString * _Nonnull _LCN(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 1547, _0, _1);
}
// Conversation.AutoremoveTimerSetUserGlobal
_FormattedString * _Nonnull _LCO(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 1548, _0, _1);
}
// Conversation.AutoremoveTimerSetUserGlobalYou
_FormattedString * _Nonnull _LCP(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1549, _0);
}
// Conversation.AutoremoveTimerSetUserYou
_FormattedString * _Nonnull _LCQ(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1550, _0);
}
// Conversation.Block
NSString * _Nonnull _LCR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1551);
}
// Conversation.BlockUser
NSString * _Nonnull _LCS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1552);
}
// Conversation.BotInteractiveUrlAlert
_FormattedString * _Nonnull _LCT(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1553, _0);
}
// Conversation.Bytes
_FormattedString * _Nonnull _LCU(_PresentationStrings * _Nonnull _self, NSInteger _0) {
    return getFormatted1(_self, 1554, @(_0));
}
// Conversation.Call
NSString * _Nonnull _LCV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1555);
}
// Conversation.CancelForwardCancelForward
NSString * _Nonnull _LCW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1556);
}
// Conversation.CancelForwardSelectChat
NSString * _Nonnull _LCX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1557);
}
// Conversation.CancelForwardText
NSString * _Nonnull _LCY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1558);
}
// Conversation.CancelForwardTitle
NSString * _Nonnull _LCZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1559);
}
// Conversation.CantPhoneCallAnonymousNumberError
NSString * _Nonnull _LDa(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1560);
}
// Conversation.CardNumberCopied
NSString * _Nonnull _LDb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1561);
}
// Conversation.ChatBackground
NSString * _Nonnull _LDc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1562);
}
// Conversation.ChecksTooltip.Delivered
NSString * _Nonnull _LDd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1563);
}
// Conversation.ChecksTooltip.Read
NSString * _Nonnull _LDe(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1564);
}
// Conversation.ClearAll
NSString * _Nonnull _LDf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1565);
}
// Conversation.ClearCache
NSString * _Nonnull _LDg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1566);
}
// Conversation.ClearChannel
NSString * _Nonnull _LDh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1567);
}
// Conversation.ClearChatConfirmation
_FormattedString * _Nonnull _LDi(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1568, _0);
}
// Conversation.ClearGroupHistory
NSString * _Nonnull _LDj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1569);
}
// Conversation.ClearPrivateHistory
NSString * _Nonnull _LDk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1570);
}
// Conversation.ClearSecretHistory
NSString * _Nonnull _LDl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1571);
}
// Conversation.ClearSelfHistory
NSString * _Nonnull _LDm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1572);
}
// Conversation.CloudStorage.ChatStatus
NSString * _Nonnull _LDn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1573);
}
// Conversation.CloudStorageInfo.Title
NSString * _Nonnull _LDo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1574);
}
// Conversation.ClousStorageInfo.Description1
NSString * _Nonnull _LDp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1575);
}
// Conversation.ClousStorageInfo.Description2
NSString * _Nonnull _LDq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1576);
}
// Conversation.ClousStorageInfo.Description3
NSString * _Nonnull _LDr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1577);
}
// Conversation.ClousStorageInfo.Description4
NSString * _Nonnull _LDs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1578);
}
// Conversation.Contact
NSString * _Nonnull _LDt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1579);
}
// Conversation.ContextMenuBan
NSString * _Nonnull _LDu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1580);
}
// Conversation.ContextMenuBlock
NSString * _Nonnull _LDv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1581);
}
// Conversation.ContextMenuCancelEditing
NSString * _Nonnull _LDw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1582);
}
// Conversation.ContextMenuCancelSending
NSString * _Nonnull _LDx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1583);
}
// Conversation.ContextMenuCopy
NSString * _Nonnull _LDy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1584);
}
// Conversation.ContextMenuCopyLink
NSString * _Nonnull _LDz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1585);
}
// Conversation.ContextMenuDelete
NSString * _Nonnull _LDA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1586);
}
// Conversation.ContextMenuDiscuss
NSString * _Nonnull _LDB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1587);
}
// Conversation.ContextMenuForward
NSString * _Nonnull _LDC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1588);
}
// Conversation.ContextMenuListened
NSString * _Nonnull _LDD(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 1589, value);
}
// Conversation.ContextMenuLookUp
NSString * _Nonnull _LDE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1590);
}
// Conversation.ContextMenuMention
NSString * _Nonnull _LDF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1591);
}
// Conversation.ContextMenuMore
NSString * _Nonnull _LDG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1592);
}
// Conversation.ContextMenuNoViews
NSString * _Nonnull _LDH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1593);
}
// Conversation.ContextMenuNobodyListened
NSString * _Nonnull _LDI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1594);
}
// Conversation.ContextMenuNobodyWatched
NSString * _Nonnull _LDJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1595);
}
// Conversation.ContextMenuOpenChannel
NSString * _Nonnull _LDK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1596);
}
// Conversation.ContextMenuOpenChannelProfile
NSString * _Nonnull _LDL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1597);
}
// Conversation.ContextMenuOpenProfile
NSString * _Nonnull _LDM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1598);
}
// Conversation.ContextMenuReply
NSString * _Nonnull _LDN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1599);
}
// Conversation.ContextMenuReport
NSString * _Nonnull _LDO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1600);
}
// Conversation.ContextMenuReportFalsePositive
NSString * _Nonnull _LDP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1601);
}
// Conversation.ContextMenuSeen
NSString * _Nonnull _LDQ(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 1602, value);
}
// Conversation.ContextMenuSelect
NSString * _Nonnull _LDR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1603);
}
// Conversation.ContextMenuSelectAll
NSString * _Nonnull _LDS(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 1604, value);
}
// Conversation.ContextMenuSendMessage
NSString * _Nonnull _LDT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1605);
}
// Conversation.ContextMenuShare
NSString * _Nonnull _LDU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1606);
}
// Conversation.ContextMenuSpeak
NSString * _Nonnull _LDV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1607);
}
// Conversation.ContextMenuStickerPackAdd
NSString * _Nonnull _LDW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1608);
}
// Conversation.ContextMenuStickerPackInfo
NSString * _Nonnull _LDX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1609);
}
// Conversation.ContextMenuTranslate
NSString * _Nonnull _LDY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1610);
}
// Conversation.ContextMenuWatched
NSString * _Nonnull _LDZ(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 1611, value);
}
// Conversation.ContextViewReplies
NSString * _Nonnull _LEa(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 1612, value);
}
// Conversation.ContextViewStats
NSString * _Nonnull _LEb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1613);
}
// Conversation.ContextViewThread
NSString * _Nonnull _LEc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1614);
}
// Conversation.CopyProtectionForwardingDisabledBot
NSString * _Nonnull _LEd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1615);
}
// Conversation.CopyProtectionForwardingDisabledChannel
NSString * _Nonnull _LEe(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1616);
}
// Conversation.CopyProtectionForwardingDisabledGroup
NSString * _Nonnull _LEf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1617);
}
// Conversation.CopyProtectionForwardingDisabledSecret
NSString * _Nonnull _LEg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1618);
}
// Conversation.CopyProtectionInfoChannel
NSString * _Nonnull _LEh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1619);
}
// Conversation.CopyProtectionInfoGroup
NSString * _Nonnull _LEi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1620);
}
// Conversation.CopyProtectionSavingDisabledBot
NSString * _Nonnull _LEj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1621);
}
// Conversation.CopyProtectionSavingDisabledChannel
NSString * _Nonnull _LEk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1622);
}
// Conversation.CopyProtectionSavingDisabledGroup
NSString * _Nonnull _LEl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1623);
}
// Conversation.CopyProtectionSavingDisabledSecret
NSString * _Nonnull _LEm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1624);
}
// Conversation.DefaultRestrictedInline
NSString * _Nonnull _LEn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1625);
}
// Conversation.DefaultRestrictedMedia
NSString * _Nonnull _LEo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1626);
}
// Conversation.DefaultRestrictedStickers
NSString * _Nonnull _LEp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1627);
}
// Conversation.DefaultRestrictedText
NSString * _Nonnull _LEq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1628);
}
// Conversation.DeleteAllMessagesInChat
_FormattedString * _Nonnull _LEr(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1629, _0);
}
// Conversation.DeleteManyMessages
NSString * _Nonnull _LEs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1630);
}
// Conversation.DeleteMessagesFor
_FormattedString * _Nonnull _LEt(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1631, _0);
}
// Conversation.DeleteMessagesForEveryone
NSString * _Nonnull _LEu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1632);
}
// Conversation.DeleteMessagesForMe
NSString * _Nonnull _LEv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1633);
}
// Conversation.DeleteTimer.Apply
NSString * _Nonnull _LEw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1634);
}
// Conversation.DeleteTimer.Disable
NSString * _Nonnull _LEx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1635);
}
// Conversation.DeleteTimer.SetupTitle
NSString * _Nonnull _LEy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1636);
}
// Conversation.DeletedFromContacts
_FormattedString * _Nonnull _LEz(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1637, _0);
}
// Conversation.Dice.u1F3AF
NSString * _Nonnull _LEA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1638);
}
// Conversation.Dice.u1F3B0
NSString * _Nonnull _LEB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1639);
}
// Conversation.Dice.u1F3B2
NSString * _Nonnull _LEC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1640);
}
// Conversation.Dice.u1F3B3
NSString * _Nonnull _LED(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1641);
}
// Conversation.Dice.u1F3C0
NSString * _Nonnull _LEE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1642);
}
// Conversation.Dice.u26BD
NSString * _Nonnull _LEF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1643);
}
// Conversation.DiscardVoiceMessageAction
NSString * _Nonnull _LEG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1644);
}
// Conversation.DiscardVoiceMessageDescription
NSString * _Nonnull _LEH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1645);
}
// Conversation.DiscardVoiceMessageTitle
NSString * _Nonnull _LEI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1646);
}
// Conversation.DiscussionNotStarted
NSString * _Nonnull _LEJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1647);
}
// Conversation.DiscussionStarted
NSString * _Nonnull _LEK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1648);
}
// Conversation.Edit
NSString * _Nonnull _LEL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1649);
}
// Conversation.EditingCaptionPanelTitle
NSString * _Nonnull _LEM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1650);
}
// Conversation.EditingMessageMediaChange
NSString * _Nonnull _LEN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1651);
}
// Conversation.EditingMessageMediaEditCurrentPhoto
NSString * _Nonnull _LEO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1652);
}
// Conversation.EditingMessageMediaEditCurrentVideo
NSString * _Nonnull _LEP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1653);
}
// Conversation.EditingMessagePanelMedia
NSString * _Nonnull _LEQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1654);
}
// Conversation.EditingMessagePanelTitle
NSString * _Nonnull _LER(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1655);
}
// Conversation.EditingPhotoPanelTitle
NSString * _Nonnull _LES(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1656);
}
// Conversation.EmailCopied
NSString * _Nonnull _LET(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1657);
}
// Conversation.EmojiCopied
NSString * _Nonnull _LEU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1658);
}
// Conversation.EmojiTooltip
NSString * _Nonnull _LEV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1659);
}
// Conversation.EmptyGifPanelPlaceholder
NSString * _Nonnull _LEW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1660);
}
// Conversation.EmptyPlaceholder
NSString * _Nonnull _LEX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1661);
}
// Conversation.EncryptedDescription1
NSString * _Nonnull _LEY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1662);
}
// Conversation.EncryptedDescription2
NSString * _Nonnull _LEZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1663);
}
// Conversation.EncryptedDescription3
NSString * _Nonnull _LFa(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1664);
}
// Conversation.EncryptedDescription4
NSString * _Nonnull _LFb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1665);
}
// Conversation.EncryptedDescriptionTitle
NSString * _Nonnull _LFc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1666);
}
// Conversation.EncryptedPlaceholderTitleIncoming
_FormattedString * _Nonnull _LFd(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1667, _0);
}
// Conversation.EncryptedPlaceholderTitleOutgoing
_FormattedString * _Nonnull _LFe(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1668, _0);
}
// Conversation.EncryptionCanceled
NSString * _Nonnull _LFf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1669);
}
// Conversation.EncryptionProcessing
NSString * _Nonnull _LFg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1670);
}
// Conversation.EncryptionWaiting
_FormattedString * _Nonnull _LFh(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1671, _0);
}
// Conversation.ErrorInaccessibleMessage
NSString * _Nonnull _LFi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1672);
}
// Conversation.FileDropbox
NSString * _Nonnull _LFj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1673);
}
// Conversation.FileHowToText
_FormattedString * _Nonnull _LFk(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1674, _0);
}
// Conversation.FileICloudDrive
NSString * _Nonnull _LFl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1675);
}
// Conversation.FileOpenIn
NSString * _Nonnull _LFm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1676);
}
// Conversation.FilePhotoOrVideo
NSString * _Nonnull _LFn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1677);
}
// Conversation.ForwardAuthorHiddenTooltip
NSString * _Nonnull _LFo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1678);
}
// Conversation.ForwardChats
NSString * _Nonnull _LFp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1679);
}
// Conversation.ForwardContacts
NSString * _Nonnull _LFq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1680);
}
// Conversation.ForwardFrom
_FormattedString * _Nonnull _LFr(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1681, _0);
}
// Conversation.ForwardOptions.CancelForwarding
NSString * _Nonnull _LFs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1682);
}
// Conversation.ForwardOptions.ChangeRecipient
NSString * _Nonnull _LFt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1683);
}
// Conversation.ForwardOptions.ChannelMessageForwardHidden
NSString * _Nonnull _LFu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1684);
}
// Conversation.ForwardOptions.ChannelMessageForwardVisible
NSString * _Nonnull _LFv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1685);
}
// Conversation.ForwardOptions.ChannelMessagesForwardHidden
NSString * _Nonnull _LFw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1686);
}
// Conversation.ForwardOptions.ChannelMessagesForwardVisible
NSString * _Nonnull _LFx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1687);
}
// Conversation.ForwardOptions.ForwardTitle
NSString * _Nonnull _LFy(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 1688, value);
}
// Conversation.ForwardOptions.ForwardTitleSingle
NSString * _Nonnull _LFz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1689);
}
// Conversation.ForwardOptions.GroupMessageForwardHidden
NSString * _Nonnull _LFA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1690);
}
// Conversation.ForwardOptions.GroupMessageForwardVisible
NSString * _Nonnull _LFB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1691);
}
// Conversation.ForwardOptions.GroupMessagesForwardHidden
NSString * _Nonnull _LFC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1692);
}
// Conversation.ForwardOptions.GroupMessagesForwardVisible
NSString * _Nonnull _LFD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1693);
}
// Conversation.ForwardOptions.HideCaption
NSString * _Nonnull _LFE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1694);
}
// Conversation.ForwardOptions.HideSendersName
NSString * _Nonnull _LFF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1695);
}
// Conversation.ForwardOptions.HideSendersNames
NSString * _Nonnull _LFG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1696);
}
// Conversation.ForwardOptions.Messages
NSString * _Nonnull _LFH(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 1697, value);
}
// Conversation.ForwardOptions.SendMessage
NSString * _Nonnull _LFI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1698);
}
// Conversation.ForwardOptions.SendMessages
NSString * _Nonnull _LFJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1699);
}
// Conversation.ForwardOptions.ShowCaption
NSString * _Nonnull _LFK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1700);
}
// Conversation.ForwardOptions.ShowOptions
NSString * _Nonnull _LFL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1701);
}
// Conversation.ForwardOptions.ShowSendersName
NSString * _Nonnull _LFM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1702);
}
// Conversation.ForwardOptions.ShowSendersNames
NSString * _Nonnull _LFN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1703);
}
// Conversation.ForwardOptions.TapForOptions
NSString * _Nonnull _LFO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1704);
}
// Conversation.ForwardOptions.TapForOptionsShort
NSString * _Nonnull _LFP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1705);
}
// Conversation.ForwardOptions.Text
_FormattedString * _Nonnull _LFQ(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 1706, _0, _1);
}
// Conversation.ForwardOptions.TextPersonal
_FormattedString * _Nonnull _LFR(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 1707, _0, _1);
}
// Conversation.ForwardOptions.Title
NSString * _Nonnull _LFS(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 1708, value);
}
// Conversation.ForwardOptions.UserMessageForwardHidden
_FormattedString * _Nonnull _LFT(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1709, _0);
}
// Conversation.ForwardOptions.UserMessageForwardVisible
_FormattedString * _Nonnull _LFU(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1710, _0);
}
// Conversation.ForwardOptions.UserMessagesForwardHidden
_FormattedString * _Nonnull _LFV(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1711, _0);
}
// Conversation.ForwardOptions.UserMessagesForwardVisible
_FormattedString * _Nonnull _LFW(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1712, _0);
}
// Conversation.ForwardTitle
NSString * _Nonnull _LFX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1713);
}
// Conversation.ForwardTooltip.Chat.Many
_FormattedString * _Nonnull _LFY(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1714, _0);
}
// Conversation.ForwardTooltip.Chat.One
_FormattedString * _Nonnull _LFZ(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1715, _0);
}
// Conversation.ForwardTooltip.ManyChats.Many
_FormattedString * _Nonnull _LGa(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 1716, _0, _1);
}
// Conversation.ForwardTooltip.ManyChats.One
_FormattedString * _Nonnull _LGb(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 1717, _0, _1);
}
// Conversation.ForwardTooltip.SavedMessages.Many
NSString * _Nonnull _LGc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1718);
}
// Conversation.ForwardTooltip.SavedMessages.One
NSString * _Nonnull _LGd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1719);
}
// Conversation.ForwardTooltip.TwoChats.Many
_FormattedString * _Nonnull _LGe(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 1720, _0, _1);
}
// Conversation.ForwardTooltip.TwoChats.One
_FormattedString * _Nonnull _LGf(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 1721, _0, _1);
}
// Conversation.GifTooltip
NSString * _Nonnull _LGg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1722);
}
// Conversation.GigagroupDescription
NSString * _Nonnull _LGh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1723);
}
// Conversation.GreetingText
NSString * _Nonnull _LGi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1724);
}
// Conversation.HashtagCopied
NSString * _Nonnull _LGj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1725);
}
// Conversation.HoldForAudio
NSString * _Nonnull _LGk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1726);
}
// Conversation.HoldForAudioOnly
NSString * _Nonnull _LGl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1727);
}
// Conversation.HoldForVideo
NSString * _Nonnull _LGm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1728);
}
// Conversation.HoldForVideoOnly
NSString * _Nonnull _LGn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1729);
}
// Conversation.ImageCopied
NSString * _Nonnull _LGo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1730);
}
// Conversation.ImportProgress
_FormattedString * _Nonnull _LGp(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1731, _0);
}
// Conversation.ImportedMessageHint
NSString * _Nonnull _LGq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1732);
}
// Conversation.IncreaseSpeed
NSString * _Nonnull _LGr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1733);
}
// Conversation.Info
NSString * _Nonnull _LGs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1734);
}
// Conversation.InfoGroup
NSString * _Nonnull _LGt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1735);
}
// Conversation.InputMenu
NSString * _Nonnull _LGu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1736);
}
// Conversation.InputTextAnonymousPlaceholder
NSString * _Nonnull _LGv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1737);
}
// Conversation.InputTextBroadcastPlaceholder
NSString * _Nonnull _LGw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1738);
}
// Conversation.InputTextCaptionPlaceholder
NSString * _Nonnull _LGx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1739);
}
// Conversation.InputTextPlaceholder
NSString * _Nonnull _LGy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1740);
}
// Conversation.InputTextPlaceholderComment
NSString * _Nonnull _LGz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1741);
}
// Conversation.InputTextPlaceholderReply
NSString * _Nonnull _LGA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1742);
}
// Conversation.InputTextSilentBroadcastPlaceholder
NSString * _Nonnull _LGB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1743);
}
// Conversation.InstantPagePreview
NSString * _Nonnull _LGC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1744);
}
// Conversation.InteractiveEmojiSyncTip
_FormattedString * _Nonnull _LGD(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1745, _0);
}
// Conversation.InviteRequestAdminChannel
_FormattedString * _Nonnull _LGE(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 1746, _0, _1);
}
// Conversation.InviteRequestAdminGroup
_FormattedString * _Nonnull _LGF(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 1747, _0, _1);
}
// Conversation.InviteRequestInfo
_FormattedString * _Nonnull _LGG(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 1748, _0, _1);
}
// Conversation.InviteRequestInfoConfirm
NSString * _Nonnull _LGH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1749);
}
// Conversation.JoinVoiceChatAsListener
NSString * _Nonnull _LGI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1750);
}
// Conversation.JoinVoiceChatAsSpeaker
NSString * _Nonnull _LGJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1751);
}
// Conversation.JumpToDate
NSString * _Nonnull _LGK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1752);
}
// Conversation.Kilobytes
_FormattedString * _Nonnull _LGL(_PresentationStrings * _Nonnull _self, NSInteger _0) {
    return getFormatted1(_self, 1753, @(_0));
}
// Conversation.LargeEmojiDisabledInfo
NSString * _Nonnull _LGM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1754);
}
// Conversation.LargeEmojiEnable
NSString * _Nonnull _LGN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1755);
}
// Conversation.LargeEmojiEnabled
NSString * _Nonnull _LGO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1756);
}
// Conversation.LinkCopied
NSString * _Nonnull _LGP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1757);
}
// Conversation.LinkDialogCopy
NSString * _Nonnull _LGQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1758);
}
// Conversation.LinkDialogOpen
NSString * _Nonnull _LGR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1759);
}
// Conversation.LinkDialogSave
NSString * _Nonnull _LGS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1760);
}
// Conversation.LinksCopied
NSString * _Nonnull _LGT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1761);
}
// Conversation.LiveLocation
NSString * _Nonnull _LGU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1762);
}
// Conversation.LiveLocationMembersCount
NSString * _Nonnull _LGV(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 1763, value);
}
// Conversation.LiveLocationYou
NSString * _Nonnull _LGW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1764);
}
// Conversation.LiveLocationYouAnd
_FormattedString * _Nonnull _LGX(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1765, _0);
}
// Conversation.LiveLocationYouAndOther
_FormattedString * _Nonnull _LGY(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1766, _0);
}
// Conversation.LiveStream
NSString * _Nonnull _LGZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1767);
}
// Conversation.LiveStreamMediaRecordingRestricted
NSString * _Nonnull _LHa(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1768);
}
// Conversation.Location
NSString * _Nonnull _LHb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1769);
}
// Conversation.Megabytes
NSString * _Nonnull _LHc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1770);
}
// Conversation.MessageCopied
NSString * _Nonnull _LHd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1771);
}
// Conversation.MessageDeliveryFailed
NSString * _Nonnull _LHe(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1772);
}
// Conversation.MessageDialogDelete
NSString * _Nonnull _LHf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1773);
}
// Conversation.MessageDialogEdit
NSString * _Nonnull _LHg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1774);
}
// Conversation.MessageDialogRetry
NSString * _Nonnull _LHh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1775);
}
// Conversation.MessageDialogRetryAll
_FormattedString * _Nonnull _LHi(_PresentationStrings * _Nonnull _self, NSInteger _0) {
    return getFormatted1(_self, 1776, @(_0));
}
// Conversation.MessageDoesntExist
NSString * _Nonnull _LHj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1777);
}
// Conversation.MessageEditedLabel
NSString * _Nonnull _LHk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1778);
}
// Conversation.MessageLeaveComment
NSString * _Nonnull _LHl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1779);
}
// Conversation.MessageLeaveCommentShort
NSString * _Nonnull _LHm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1780);
}
// Conversation.MessageViaUser
_FormattedString * _Nonnull _LHn(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1781, _0);
}
// Conversation.MessageViewComments
NSString * _Nonnull _LHo(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 1782, value);
}
// Conversation.MessageViewCommentsFormat
_FormattedString * _Nonnull _LHp(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 1783, _0, _1);
}
// Conversation.Messages
NSString * _Nonnull _LHq(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 1784, value);
}
// Conversation.Moderate.Ban
NSString * _Nonnull _LHr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1785);
}
// Conversation.Moderate.Delete
NSString * _Nonnull _LHs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1786);
}
// Conversation.Moderate.DeleteAllMessages
_FormattedString * _Nonnull _LHt(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1787, _0);
}
// Conversation.Moderate.Report
NSString * _Nonnull _LHu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1788);
}
// Conversation.Mute
NSString * _Nonnull _LHv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1789);
}
// Conversation.Mute.ApplyMuteUntil
_FormattedString * _Nonnull _LHw(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1790, _0);
}
// Conversation.Mute.SetupTitle
NSString * _Nonnull _LHx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1791);
}
// Conversation.NoticeInvitedByInChannel
_FormattedString * _Nonnull _LHy(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1792, _0);
}
// Conversation.NoticeInvitedByInGroup
_FormattedString * _Nonnull _LHz(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1793, _0);
}
// Conversation.OpenBotLinkAllowMessages
_FormattedString * _Nonnull _LHA(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1794, _0);
}
// Conversation.OpenBotLinkLogin
_FormattedString * _Nonnull _LHB(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 1795, _0, _1);
}
// Conversation.OpenBotLinkOpen
NSString * _Nonnull _LHC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1796);
}
// Conversation.OpenBotLinkText
_FormattedString * _Nonnull _LHD(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1797, _0);
}
// Conversation.OpenBotLinkTitle
NSString * _Nonnull _LHE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1798);
}
// Conversation.OpenFile
NSString * _Nonnull _LHF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1799);
}
// Conversation.Owner
NSString * _Nonnull _LHG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1800);
}
// Conversation.PeerNearbyDistance
_FormattedString * _Nonnull _LHH(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 1801, _0, _1);
}
// Conversation.PeerNearbyText
NSString * _Nonnull _LHI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1802);
}
// Conversation.PeerNearbyTitle
_FormattedString * _Nonnull _LHJ(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 1803, _0, _1);
}
// Conversation.PhoneCopied
NSString * _Nonnull _LHK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1804);
}
// Conversation.Pin
NSString * _Nonnull _LHL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1805);
}
// Conversation.PinMessageAlert.OnlyPin
NSString * _Nonnull _LHM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1806);
}
// Conversation.PinMessageAlert.PinAndNotifyMembers
NSString * _Nonnull _LHN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1807);
}
// Conversation.PinMessageAlertGroup
NSString * _Nonnull _LHO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1808);
}
// Conversation.PinMessageAlertPin
NSString * _Nonnull _LHP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1809);
}
// Conversation.PinMessagesFor
_FormattedString * _Nonnull _LHQ(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1810, _0);
}
// Conversation.PinMessagesForMe
NSString * _Nonnull _LHR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1811);
}
// Conversation.PinOlderMessageAlertText
NSString * _Nonnull _LHS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1812);
}
// Conversation.PinOlderMessageAlertTitle
NSString * _Nonnull _LHT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1813);
}
// Conversation.PinnedMessage
NSString * _Nonnull _LHU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1814);
}
// Conversation.PinnedPoll
NSString * _Nonnull _LHV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1815);
}
// Conversation.PinnedPreviousMessage
NSString * _Nonnull _LHW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1816);
}
// Conversation.PinnedQuiz
NSString * _Nonnull _LHX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1817);
}
// Conversation.PremiumUploadFileTooLarge
NSString * _Nonnull _LHY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1818);
}
// Conversation.PressVolumeButtonForSound
NSString * _Nonnull _LHZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1819);
}
// Conversation.PrivateChannelTimeLimitedAlertJoin
NSString * _Nonnull _LIa(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1820);
}
// Conversation.PrivateChannelTimeLimitedAlertText
NSString * _Nonnull _LIb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1821);
}
// Conversation.PrivateChannelTimeLimitedAlertTitle
NSString * _Nonnull _LIc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1822);
}
// Conversation.PrivateChannelTooltip
NSString * _Nonnull _LId(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1823);
}
// Conversation.PrivateMessageLinkCopied
NSString * _Nonnull _LIe(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1824);
}
// Conversation.PrivateMessageLinkCopiedLong
NSString * _Nonnull _LIf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1825);
}
// Conversation.Processing
NSString * _Nonnull _LIg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1826);
}
// Conversation.ReadAllReactions
NSString * _Nonnull _LIh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1827);
}
// Conversation.ReplyMessagePanelTitle
_FormattedString * _Nonnull _LIi(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1828, _0);
}
// Conversation.Report
NSString * _Nonnull _LIj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1829);
}
// Conversation.ReportGroupLocation
NSString * _Nonnull _LIk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1830);
}
// Conversation.ReportMessages
NSString * _Nonnull _LIl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1831);
}
// Conversation.ReportSpam
NSString * _Nonnull _LIm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1832);
}
// Conversation.ReportSpamAndLeave
NSString * _Nonnull _LIn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1833);
}
// Conversation.ReportSpamChannelConfirmation
NSString * _Nonnull _LIo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1834);
}
// Conversation.ReportSpamConfirmation
NSString * _Nonnull _LIp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1835);
}
// Conversation.ReportSpamGroupConfirmation
NSString * _Nonnull _LIq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1836);
}
// Conversation.RequestToJoinChannel
NSString * _Nonnull _LIr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1837);
}
// Conversation.RequestToJoinGroup
NSString * _Nonnull _LIs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1838);
}
// Conversation.RequestsToJoin
NSString * _Nonnull _LIt(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 1839, value);
}
// Conversation.RestrictedInline
NSString * _Nonnull _LIu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1840);
}
// Conversation.RestrictedInlineTimed
_FormattedString * _Nonnull _LIv(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1841, _0);
}
// Conversation.RestrictedMedia
NSString * _Nonnull _LIw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1842);
}
// Conversation.RestrictedMediaTimed
_FormattedString * _Nonnull _LIx(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1843, _0);
}
// Conversation.RestrictedStickers
NSString * _Nonnull _LIy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1844);
}
// Conversation.RestrictedStickersTimed
_FormattedString * _Nonnull _LIz(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1845, _0);
}
// Conversation.RestrictedText
NSString * _Nonnull _LIA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1846);
}
// Conversation.RestrictedTextTimed
_FormattedString * _Nonnull _LIB(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1847, _0);
}
// Conversation.SaveGif
NSString * _Nonnull _LIC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1848);
}
// Conversation.SavedMessages
NSString * _Nonnull _LID(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1849);
}
// Conversation.ScamWarning
NSString * _Nonnull _LIE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1850);
}
// Conversation.ScheduleMessage.SendOn
_FormattedString * _Nonnull _LIF(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 1851, _0, _1);
}
// Conversation.ScheduleMessage.SendToday
_FormattedString * _Nonnull _LIG(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1852, _0);
}
// Conversation.ScheduleMessage.SendTomorrow
_FormattedString * _Nonnull _LIH(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1853, _0);
}
// Conversation.ScheduleMessage.SendWhenOnline
NSString * _Nonnull _LII(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1854);
}
// Conversation.ScheduleMessage.Title
NSString * _Nonnull _LIJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1855);
}
// Conversation.ScheduledLiveStream
NSString * _Nonnull _LIK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1856);
}
// Conversation.ScheduledLiveStreamStartsOn
_FormattedString * _Nonnull _LIL(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1857, _0);
}
// Conversation.ScheduledLiveStreamStartsToday
_FormattedString * _Nonnull _LIM(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1858, _0);
}
// Conversation.ScheduledLiveStreamStartsTomorrow
_FormattedString * _Nonnull _LIN(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1859, _0);
}
// Conversation.ScheduledVoiceChat
NSString * _Nonnull _LIO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1860);
}
// Conversation.ScheduledVoiceChatStartsOn
_FormattedString * _Nonnull _LIP(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1861, _0);
}
// Conversation.ScheduledVoiceChatStartsOnShort
_FormattedString * _Nonnull _LIQ(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1862, _0);
}
// Conversation.ScheduledVoiceChatStartsToday
_FormattedString * _Nonnull _LIR(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1863, _0);
}
// Conversation.ScheduledVoiceChatStartsTodayShort
_FormattedString * _Nonnull _LIS(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1864, _0);
}
// Conversation.ScheduledVoiceChatStartsTomorrow
_FormattedString * _Nonnull _LIT(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1865, _0);
}
// Conversation.ScheduledVoiceChatStartsTomorrowShort
_FormattedString * _Nonnull _LIU(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1866, _0);
}
// Conversation.Search
NSString * _Nonnull _LIV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1867);
}
// Conversation.SearchByName.Placeholder
NSString * _Nonnull _LIW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1868);
}
// Conversation.SearchByName.Prefix
NSString * _Nonnull _LIX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1869);
}
// Conversation.SearchNoResults
NSString * _Nonnull _LIY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1870);
}
// Conversation.SearchPlaceholder
NSString * _Nonnull _LIZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1871);
}
// Conversation.SecretChatContextBotAlert
NSString * _Nonnull _LJa(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1872);
}
// Conversation.SecretLinkPreviewAlert
NSString * _Nonnull _LJb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1873);
}
// Conversation.SelectMessages
NSString * _Nonnull _LJc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1874);
}
// Conversation.SelectedMessages
NSString * _Nonnull _LJd(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 1875, value);
}
// Conversation.SendDice
NSString * _Nonnull _LJe(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1876);
}
// Conversation.SendMesageAs
NSString * _Nonnull _LJf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1877);
}
// Conversation.SendMesageAsPremiumInfo
NSString * _Nonnull _LJg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1878);
}
// Conversation.SendMessage
NSString * _Nonnull _LJh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1879);
}
// Conversation.SendMessage.ScheduleMessage
NSString * _Nonnull _LJi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1880);
}
// Conversation.SendMessage.SendSilently
NSString * _Nonnull _LJj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1881);
}
// Conversation.SendMessage.SetReminder
NSString * _Nonnull _LJk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1882);
}
// Conversation.SendMessageErrorFlood
NSString * _Nonnull _LJl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1883);
}
// Conversation.SendMessageErrorGroupRestricted
NSString * _Nonnull _LJm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1884);
}
// Conversation.SendMessageErrorTooMuchScheduled
NSString * _Nonnull _LJn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1885);
}
// Conversation.SendingOptionsTooltip
NSString * _Nonnull _LJo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1886);
}
// Conversation.SetReminder.RemindOn
_FormattedString * _Nonnull _LJp(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 1887, _0, _1);
}
// Conversation.SetReminder.RemindToday
_FormattedString * _Nonnull _LJq(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1888, _0);
}
// Conversation.SetReminder.RemindTomorrow
_FormattedString * _Nonnull _LJr(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1889, _0);
}
// Conversation.SetReminder.Title
NSString * _Nonnull _LJs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1890);
}
// Conversation.ShareBotContactConfirmation
NSString * _Nonnull _LJt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1891);
}
// Conversation.ShareBotContactConfirmationTitle
NSString * _Nonnull _LJu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1892);
}
// Conversation.ShareBotLocationConfirmation
NSString * _Nonnull _LJv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1893);
}
// Conversation.ShareBotLocationConfirmationTitle
NSString * _Nonnull _LJw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1894);
}
// Conversation.ShareInlineBotLocationConfirmation
NSString * _Nonnull _LJx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1895);
}
// Conversation.ShareMyContactInfo
NSString * _Nonnull _LJy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1896);
}
// Conversation.ShareMyPhoneNumber
NSString * _Nonnull _LJz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1897);
}
// Conversation.ShareMyPhoneNumber.StatusSuccess
_FormattedString * _Nonnull _LJA(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1898, _0);
}
// Conversation.ShareMyPhoneNumberConfirmation
_FormattedString * _Nonnull _LJB(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 1899, _0, _1);
}
// Conversation.SilentBroadcastTooltipOff
NSString * _Nonnull _LJC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1900);
}
// Conversation.SilentBroadcastTooltipOn
NSString * _Nonnull _LJD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1901);
}
// Conversation.SlideToCancel
NSString * _Nonnull _LJE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1902);
}
// Conversation.StatusKickedFromChannel
NSString * _Nonnull _LJF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1903);
}
// Conversation.StatusKickedFromGroup
NSString * _Nonnull _LJG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1904);
}
// Conversation.StatusLeftGroup
NSString * _Nonnull _LJH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1905);
}
// Conversation.StatusMembers
NSString * _Nonnull _LJI(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 1906, value);
}
// Conversation.StatusOnline
NSString * _Nonnull _LJJ(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 1907, value);
}
// Conversation.StatusSubscribers
NSString * _Nonnull _LJK(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 1908, value);
}
// Conversation.StatusTyping
NSString * _Nonnull _LJL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1909);
}
// Conversation.StickerAddedToFavorites
NSString * _Nonnull _LJM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1910);
}
// Conversation.StickerRemovedFromFavorites
NSString * _Nonnull _LJN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1911);
}
// Conversation.StopLiveLocation
NSString * _Nonnull _LJO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1912);
}
// Conversation.StopPoll
NSString * _Nonnull _LJP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1913);
}
// Conversation.StopPollConfirmation
NSString * _Nonnull _LJQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1914);
}
// Conversation.StopPollConfirmationTitle
NSString * _Nonnull _LJR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1915);
}
// Conversation.StopQuiz
NSString * _Nonnull _LJS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1916);
}
// Conversation.StopQuizConfirmation
NSString * _Nonnull _LJT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1917);
}
// Conversation.StopQuizConfirmationTitle
NSString * _Nonnull _LJU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1918);
}
// Conversation.SuggestedPhotoSuccess
NSString * _Nonnull _LJV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1919);
}
// Conversation.SuggestedPhotoSuccessText
NSString * _Nonnull _LJW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1920);
}
// Conversation.SuggestedPhotoText
_FormattedString * _Nonnull _LJX(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1921, _0);
}
// Conversation.SuggestedPhotoTextExpanded
_FormattedString * _Nonnull _LJY(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1922, _0);
}
// Conversation.SuggestedPhotoTextYou
_FormattedString * _Nonnull _LJZ(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1923, _0);
}
// Conversation.SuggestedPhotoTitle
NSString * _Nonnull _LKa(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1924);
}
// Conversation.SuggestedPhotoView
NSString * _Nonnull _LKb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1925);
}
// Conversation.SuggestedVideoSuccess
NSString * _Nonnull _LKc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1926);
}
// Conversation.SuggestedVideoSuccessText
NSString * _Nonnull _LKd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1927);
}
// Conversation.SuggestedVideoText
_FormattedString * _Nonnull _LKe(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1928, _0);
}
// Conversation.SuggestedVideoTextExpanded
_FormattedString * _Nonnull _LKf(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1929, _0);
}
// Conversation.SuggestedVideoTextYou
_FormattedString * _Nonnull _LKg(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1930, _0);
}
// Conversation.SuggestedVideoTitle
NSString * _Nonnull _LKh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1931);
}
// Conversation.SuggestedVideoView
NSString * _Nonnull _LKi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1932);
}
// Conversation.SwipeToReplyHintText
NSString * _Nonnull _LKj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1933);
}
// Conversation.SwipeToReplyHintTitle
NSString * _Nonnull _LKk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1934);
}
// Conversation.TapAndHoldToRecord
NSString * _Nonnull _LKl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1935);
}
// Conversation.TextCopied
NSString * _Nonnull _LKm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1936);
}
// Conversation.Theme
NSString * _Nonnull _LKn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1937);
}
// Conversation.Theme.Apply
NSString * _Nonnull _LKo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1938);
}
// Conversation.Theme.DismissAlert
NSString * _Nonnull _LKp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1939);
}
// Conversation.Theme.DismissAlertApply
NSString * _Nonnull _LKq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1940);
}
// Conversation.Theme.DontSetTheme
NSString * _Nonnull _LKr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1941);
}
// Conversation.Theme.NoTheme
NSString * _Nonnull _LKs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1942);
}
// Conversation.Theme.PreviewDark
_FormattedString * _Nonnull _LKt(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1943, _0);
}
// Conversation.Theme.PreviewLight
_FormattedString * _Nonnull _LKu(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1944, _0);
}
// Conversation.Theme.Reset
NSString * _Nonnull _LKv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1945);
}
// Conversation.Theme.Subtitle
_FormattedString * _Nonnull _LKw(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1946, _0);
}
// Conversation.Theme.SwitchToDark
NSString * _Nonnull _LKx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1947);
}
// Conversation.Theme.SwitchToLight
NSString * _Nonnull _LKy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1948);
}
// Conversation.Theme.Title
NSString * _Nonnull _LKz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1949);
}
// Conversation.Timer.Send
NSString * _Nonnull _LKA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1950);
}
// Conversation.Timer.Title
NSString * _Nonnull _LKB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1951);
}
// Conversation.TitleComments
NSString * _Nonnull _LKC(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 1952, value);
}
// Conversation.TitleCommentsEmpty
NSString * _Nonnull _LKD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1953);
}
// Conversation.TitleCommentsFormat
_FormattedString * _Nonnull _LKE(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 1954, _0, _1);
}
// Conversation.TitleMute
NSString * _Nonnull _LKF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1955);
}
// Conversation.TitleNoComments
NSString * _Nonnull _LKG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1956);
}
// Conversation.TitleReplies
NSString * _Nonnull _LKH(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 1957, value);
}
// Conversation.TitleRepliesEmpty
NSString * _Nonnull _LKI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1958);
}
// Conversation.TitleRepliesFormat
_FormattedString * _Nonnull _LKJ(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 1959, _0, _1);
}
// Conversation.TitleUnmute
NSString * _Nonnull _LKK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1960);
}
// Conversation.Translation.AddedToDoNotTranslateText
_FormattedString * _Nonnull _LKL(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1961, _0);
}
// Conversation.Translation.ChooseLanguage
NSString * _Nonnull _LKM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1962);
}
// Conversation.Translation.DoNotTranslate
_FormattedString * _Nonnull _LKN(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1963, _0);
}
// Conversation.Translation.DoNotTranslateOther
_FormattedString * _Nonnull _LKO(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1964, _0);
}
// Conversation.Translation.Hide
NSString * _Nonnull _LKP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1965);
}
// Conversation.Translation.ShowOriginal
NSString * _Nonnull _LKQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1966);
}
// Conversation.Translation.TranslateTo
_FormattedString * _Nonnull _LKR(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1967, _0);
}
// Conversation.Translation.TranslateToOther
_FormattedString * _Nonnull _LKS(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 1968, _0);
}
// Conversation.Translation.TranslationBarHiddenChannelText
NSString * _Nonnull _LKT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1969);
}
// Conversation.Translation.TranslationBarHiddenChatText
NSString * _Nonnull _LKU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1970);
}
// Conversation.Translation.TranslationBarHiddenGroupText
NSString * _Nonnull _LKV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1971);
}
// Conversation.Unarchive
NSString * _Nonnull _LKW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1972);
}
// Conversation.UnarchiveDone
NSString * _Nonnull _LKX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1973);
}
// Conversation.Unblock
NSString * _Nonnull _LKY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1974);
}
// Conversation.UnblockUser
NSString * _Nonnull _LKZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1975);
}
// Conversation.Unmute
NSString * _Nonnull _LLa(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1976);
}
// Conversation.Unpin
NSString * _Nonnull _LLb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1977);
}
// Conversation.UnpinMessageAlert
NSString * _Nonnull _LLc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1978);
}
// Conversation.UnreadMessages
NSString * _Nonnull _LLd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1979);
}
// Conversation.UnsupportedMedia
NSString * _Nonnull _LLe(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1980);
}
// Conversation.UnsupportedMediaPlaceholder
NSString * _Nonnull _LLf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1981);
}
// Conversation.UnvotePoll
NSString * _Nonnull _LLg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1982);
}
// Conversation.UpdateTelegram
NSString * _Nonnull _LLh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1983);
}
// Conversation.UploadFileTooLarge
NSString * _Nonnull _LLi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1984);
}
// Conversation.UserSendMessage
NSString * _Nonnull _LLj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1985);
}
// Conversation.UsernameCopied
NSString * _Nonnull _LLk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1986);
}
// Conversation.UsersTooMuchError
NSString * _Nonnull _LLl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1987);
}
// Conversation.ViewBackground
NSString * _Nonnull _LLm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1988);
}
// Conversation.ViewBot
NSString * _Nonnull _LLn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1989);
}
// Conversation.ViewChannel
NSString * _Nonnull _LLo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1990);
}
// Conversation.ViewContactDetails
NSString * _Nonnull _LLp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1991);
}
// Conversation.ViewGroup
NSString * _Nonnull _LLq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1992);
}
// Conversation.ViewInChannel
NSString * _Nonnull _LLr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1993);
}
// Conversation.ViewMessage
NSString * _Nonnull _LLs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1994);
}
// Conversation.ViewPost
NSString * _Nonnull _LLt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1995);
}
// Conversation.ViewReply
NSString * _Nonnull _LLu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1996);
}
// Conversation.ViewTheme
NSString * _Nonnull _LLv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1997);
}
// Conversation.VoiceChat
NSString * _Nonnull _LLw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1998);
}
// Conversation.VoiceChatMediaRecordingRestricted
NSString * _Nonnull _LLx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 1999);
}
// Conversation.VoiceMessagesRestricted
_FormattedString * _Nonnull _LLy(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2000, _0);
}
// Conversation.typing
NSString * _Nonnull _LLz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2001);
}
// ConversationMedia.Title
NSString * _Nonnull _LLA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2002);
}
// ConversationProfile.ErrorCreatingConversation
NSString * _Nonnull _LLB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2003);
}
// ConversationProfile.LeaveDeleteAndExit
NSString * _Nonnull _LLC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2004);
}
// ConversationProfile.UnknownAddMemberError
NSString * _Nonnull _LLD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2005);
}
// ConversationProfile.UsersTooMuchError
NSString * _Nonnull _LLE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2006);
}
// ConvertToSupergroup.HelpText
NSString * _Nonnull _LLF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2007);
}
// ConvertToSupergroup.HelpTitle
NSString * _Nonnull _LLG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2008);
}
// ConvertToSupergroup.Note
NSString * _Nonnull _LLH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2009);
}
// ConvertToSupergroup.Title
NSString * _Nonnull _LLI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2010);
}
// Core.ServiceUserStatus
NSString * _Nonnull _LLJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2011);
}
// Coub.TapForSound
NSString * _Nonnull _LLK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2012);
}
// CreateExternalStream.ServerUrl
NSString * _Nonnull _LLL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2013);
}
// CreateExternalStream.StartStreaming
NSString * _Nonnull _LLM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2014);
}
// CreateExternalStream.StartStreamingInfo
NSString * _Nonnull _LLN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2015);
}
// CreateExternalStream.StreamKey
NSString * _Nonnull _LLO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2016);
}
// CreateExternalStream.StreamKeyTitle
NSString * _Nonnull _LLP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2017);
}
// CreateExternalStream.Text
NSString * _Nonnull _LLQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2018);
}
// CreateExternalStream.Title
NSString * _Nonnull _LLR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2019);
}
// CreateGroup.AutoDeleteText
NSString * _Nonnull _LLS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2020);
}
// CreateGroup.AutoDeleteTitle
NSString * _Nonnull _LLT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2021);
}
// CreateGroup.ChannelsTooMuch
NSString * _Nonnull _LLU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2022);
}
// CreateGroup.ErrorLocatedGroupsTooMuch
NSString * _Nonnull _LLV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2023);
}
// CreateGroup.PublicLinkInfo
NSString * _Nonnull _LLW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2024);
}
// CreateGroup.PublicLinkTitle
NSString * _Nonnull _LLX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2025);
}
// CreateGroup.SoftUserLimitAlert
NSString * _Nonnull _LLY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2026);
}
// CreatePoll.AddMoreOptions
NSString * _Nonnull _LLZ(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 2027, value);
}
// CreatePoll.AddOption
NSString * _Nonnull _LMa(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2028);
}
// CreatePoll.AllOptionsAdded
NSString * _Nonnull _LMb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2029);
}
// CreatePoll.Anonymous
NSString * _Nonnull _LMc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2030);
}
// CreatePoll.CancelConfirmation
NSString * _Nonnull _LMd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2031);
}
// CreatePoll.Create
NSString * _Nonnull _LMe(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2032);
}
// CreatePoll.Explanation
NSString * _Nonnull _LMf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2033);
}
// CreatePoll.ExplanationHeader
NSString * _Nonnull _LMg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2034);
}
// CreatePoll.ExplanationInfo
NSString * _Nonnull _LMh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2035);
}
// CreatePoll.MultipleChoice
NSString * _Nonnull _LMi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2036);
}
// CreatePoll.MultipleChoiceQuizAlert
NSString * _Nonnull _LMj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2037);
}
// CreatePoll.OptionPlaceholder
NSString * _Nonnull _LMk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2038);
}
// CreatePoll.OptionsHeader
NSString * _Nonnull _LMl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2039);
}
// CreatePoll.Quiz
NSString * _Nonnull _LMm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2040);
}
// CreatePoll.QuizInfo
NSString * _Nonnull _LMn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2041);
}
// CreatePoll.QuizOptionsHeader
NSString * _Nonnull _LMo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2042);
}
// CreatePoll.QuizTip
NSString * _Nonnull _LMp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2043);
}
// CreatePoll.QuizTitle
NSString * _Nonnull _LMq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2044);
}
// CreatePoll.TextHeader
NSString * _Nonnull _LMr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2045);
}
// CreatePoll.TextPlaceholder
NSString * _Nonnull _LMs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2046);
}
// CreatePoll.Title
NSString * _Nonnull _LMt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2047);
}
// CreateTopic.Create
NSString * _Nonnull _LMu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2048);
}
// CreateTopic.CreateTitle
NSString * _Nonnull _LMv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2049);
}
// CreateTopic.EditTitle
NSString * _Nonnull _LMw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2050);
}
// CreateTopic.EnterTopicTitle
NSString * _Nonnull _LMx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2051);
}
// CreateTopic.EnterTopicTitlePlaceholder
NSString * _Nonnull _LMy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2052);
}
// CreateTopic.SelectTopicIcon
NSString * _Nonnull _LMz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2053);
}
// CreateTopic.ShowGeneral
NSString * _Nonnull _LMA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2054);
}
// CreateTopic.ShowGeneralInfo
NSString * _Nonnull _LMB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2055);
}
// DataUsage.AutoDownloadSettings
NSString * _Nonnull _LMC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2056);
}
// DataUsage.InfoMobileUsageSinceTime
_FormattedString * _Nonnull _LMD(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2057, _0);
}
// DataUsage.InfoTotalUsageSinceTime
_FormattedString * _Nonnull _LME(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2058, _0);
}
// DataUsage.InfoWifiUsageSinceTime
_FormattedString * _Nonnull _LMF(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2059, _0);
}
// DataUsage.MediaDirectionIncoming
NSString * _Nonnull _LMG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2060);
}
// DataUsage.MediaDirectionOutgoing
NSString * _Nonnull _LMH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2061);
}
// DataUsage.SectionTotalIncoming
NSString * _Nonnull _LMI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2062);
}
// DataUsage.SectionTotalOutgoing
NSString * _Nonnull _LMJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2063);
}
// DataUsage.SectionUsageMobile
NSString * _Nonnull _LMK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2064);
}
// DataUsage.SectionUsageTotal
NSString * _Nonnull _LML(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2065);
}
// DataUsage.SectionUsageWifi
NSString * _Nonnull _LMM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2066);
}
// DataUsage.SectionsInfo
NSString * _Nonnull _LMN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2067);
}
// DataUsage.TopSectionAll
NSString * _Nonnull _LMO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2068);
}
// DataUsage.TopSectionMobile
NSString * _Nonnull _LMP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2069);
}
// DataUsage.TopSectionWifi
NSString * _Nonnull _LMQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2070);
}
// Date.ChatDateHeader
_FormattedString * _Nonnull _LMR(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 2071, _0, _1);
}
// Date.ChatDateHeaderYear
_FormattedString * _Nonnull _LMS(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2) {
    return getFormatted3(_self, 2072, _0, _1, _2);
}
// Date.DialogDateFormat
NSString * _Nonnull _LMT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2073);
}
// DeleteAccount.AlternativeOptionsTitle
NSString * _Nonnull _LMU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2074);
}
// DeleteAccount.CloudStorageText
NSString * _Nonnull _LMV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2075);
}
// DeleteAccount.CloudStorageTitle
NSString * _Nonnull _LMW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2076);
}
// DeleteAccount.ComeBackLater
NSString * _Nonnull _LMX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2077);
}
// DeleteAccount.ConfirmationAlertDelete
NSString * _Nonnull _LMY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2078);
}
// DeleteAccount.ConfirmationAlertText
NSString * _Nonnull _LMZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2079);
}
// DeleteAccount.ConfirmationAlertTitle
NSString * _Nonnull _LNa(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2080);
}
// DeleteAccount.Continue
NSString * _Nonnull _LNb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2081);
}
// DeleteAccount.DeleteMessagesURL
NSString * _Nonnull _LNc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2082);
}
// DeleteAccount.DeleteMyAccount
NSString * _Nonnull _LNd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2083);
}
// DeleteAccount.DeleteMyAccountTitle
NSString * _Nonnull _LNe(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2084);
}
// DeleteAccount.EnterPassword
NSString * _Nonnull _LNf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2085);
}
// DeleteAccount.EnterPhoneNumber
NSString * _Nonnull _LNg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2086);
}
// DeleteAccount.GroupsAndChannelsInfo
NSString * _Nonnull _LNh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2087);
}
// DeleteAccount.GroupsAndChannelsText
NSString * _Nonnull _LNi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2088);
}
// DeleteAccount.GroupsAndChannelsTitle
NSString * _Nonnull _LNj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2089);
}
// DeleteAccount.InvalidPasswordError
NSString * _Nonnull _LNk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2090);
}
// DeleteAccount.InvalidPhoneNumberError
NSString * _Nonnull _LNl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2091);
}
// DeleteAccount.MessageHistoryText
NSString * _Nonnull _LNm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2092);
}
// DeleteAccount.MessageHistoryTitle
NSString * _Nonnull _LNn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2093);
}
// DeleteAccount.Options.AddAccountPremiumText
NSString * _Nonnull _LNo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2094);
}
// DeleteAccount.Options.AddAccountText
NSString * _Nonnull _LNp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2095);
}
// DeleteAccount.Options.AddAccountTitle
NSString * _Nonnull _LNq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2096);
}
// DeleteAccount.Options.ChangePhoneNumberText
NSString * _Nonnull _LNr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2097);
}
// DeleteAccount.Options.ChangePhoneNumberTitle
NSString * _Nonnull _LNs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2098);
}
// DeleteAccount.Options.ChangePrivacyText
NSString * _Nonnull _LNt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2099);
}
// DeleteAccount.Options.ChangePrivacyTitle
NSString * _Nonnull _LNu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2100);
}
// DeleteAccount.Options.ClearCacheText
NSString * _Nonnull _LNv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2101);
}
// DeleteAccount.Options.ClearCacheTitle
NSString * _Nonnull _LNw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2102);
}
// DeleteAccount.Options.ClearSyncedContactsText
NSString * _Nonnull _LNx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2103);
}
// DeleteAccount.Options.ClearSyncedContactsTitle
NSString * _Nonnull _LNy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2104);
}
// DeleteAccount.Options.ContactSupportText
NSString * _Nonnull _LNz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2105);
}
// DeleteAccount.Options.ContactSupportTitle
NSString * _Nonnull _LNA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2106);
}
// DeleteAccount.Options.DeleteChatsText
NSString * _Nonnull _LNB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2107);
}
// DeleteAccount.Options.DeleteChatsTitle
NSString * _Nonnull _LNC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2108);
}
// DeleteAccount.Options.SetPasscodeText
NSString * _Nonnull _LND(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2109);
}
// DeleteAccount.Options.SetPasscodeTitle
NSString * _Nonnull _LNE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2110);
}
// DeleteAccount.Options.SetTwoStepAuthText
NSString * _Nonnull _LNF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2111);
}
// DeleteAccount.Options.SetTwoStepAuthTitle
NSString * _Nonnull _LNG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2112);
}
// DeleteAccount.SavedMessages
NSString * _Nonnull _LNH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2113);
}
// DeleteAccount.Success
NSString * _Nonnull _LNI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2114);
}
// DialogList.AdLabel
NSString * _Nonnull _LNJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2115);
}
// DialogList.AdNoticeAlert
NSString * _Nonnull _LNK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2116);
}
// DialogList.AwaitingEncryption
_FormattedString * _Nonnull _LNL(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2117, _0);
}
// DialogList.ClearHistoryConfirmation
NSString * _Nonnull _LNM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2118);
}
// DialogList.DeleteBotConfirmation
NSString * _Nonnull _LNN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2119);
}
// DialogList.DeleteBotConversationConfirmation
NSString * _Nonnull _LNP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2120);
}
// DialogList.DeleteConversationConfirmation
NSString * _Nonnull _LNQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2121);
}
// DialogList.Draft
NSString * _Nonnull _LNR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2122);
}
// DialogList.EncryptedChatStartedIncoming
_FormattedString * _Nonnull _LNS(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2123, _0);
}
// DialogList.EncryptedChatStartedOutgoing
_FormattedString * _Nonnull _LNT(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2124, _0);
}
// DialogList.EncryptionProcessing
NSString * _Nonnull _LNU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2125);
}
// DialogList.EncryptionRejected
NSString * _Nonnull _LNV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2126);
}
// DialogList.LanguageTooltip
NSString * _Nonnull _LNW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2127);
}
// DialogList.LiveLocationChatsCount
NSString * _Nonnull _LNX(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 2128, value);
}
// DialogList.LiveLocationSharingTo
_FormattedString * _Nonnull _LNY(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2129, _0);
}
// DialogList.MultipleTyping
_FormattedString * _Nonnull _LNZ(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 2130, _0, _1);
}
// DialogList.MultipleTypingPair
_FormattedString * _Nonnull _LOa(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 2131, _0, _1);
}
// DialogList.MultipleTypingSuffix
_FormattedString * _Nonnull _LOb(_PresentationStrings * _Nonnull _self, NSInteger _0) {
    return getFormatted1(_self, 2132, @(_0));
}
// DialogList.NoMessagesText
NSString * _Nonnull _LOc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2133);
}
// DialogList.NoMessagesTitle
NSString * _Nonnull _LOd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2134);
}
// DialogList.PasscodeLockHelp
NSString * _Nonnull _LOe(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2135);
}
// DialogList.Pin
NSString * _Nonnull _LOf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2136);
}
// DialogList.PinLimitError
_FormattedString * _Nonnull _LOg(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2137, _0);
}
// DialogList.ProxyConnectionIssuesTooltip
NSString * _Nonnull _LOh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2138);
}
// DialogList.Read
NSString * _Nonnull _LOi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2139);
}
// DialogList.RecentTitlePeople
NSString * _Nonnull _LOj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2140);
}
// DialogList.Replies
NSString * _Nonnull _LOk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2141);
}
// DialogList.SavedMessages
NSString * _Nonnull _LOl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2142);
}
// DialogList.SavedMessagesHelp
NSString * _Nonnull _LOm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2143);
}
// DialogList.SavedMessagesTooltip
NSString * _Nonnull _LOn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2144);
}
// DialogList.SearchLabel
NSString * _Nonnull _LOo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2145);
}
// DialogList.SearchLabelCompact
NSString * _Nonnull _LOp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2146);
}
// DialogList.SearchSectionChats
NSString * _Nonnull _LOq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2147);
}
// DialogList.SearchSectionDialogs
NSString * _Nonnull _LOr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2148);
}
// DialogList.SearchSectionGlobal
NSString * _Nonnull _LOs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2149);
}
// DialogList.SearchSectionMessages
NSString * _Nonnull _LOt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2150);
}
// DialogList.SearchSectionMessagesIn
_FormattedString * _Nonnull _LOu(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2151, _0);
}
// DialogList.SearchSectionRecent
NSString * _Nonnull _LOv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2152);
}
// DialogList.SearchSectionTopics
NSString * _Nonnull _LOw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2153);
}
// DialogList.SearchSubtitleFormat
_FormattedString * _Nonnull _LOx(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 2154, _0, _1);
}
// DialogList.SingleChoosingStickerSuffix
_FormattedString * _Nonnull _LOy(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2155, _0);
}
// DialogList.SinglePlayingGameSuffix
_FormattedString * _Nonnull _LOz(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2156, _0);
}
// DialogList.SingleRecordingAudioSuffix
_FormattedString * _Nonnull _LOA(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2157, _0);
}
// DialogList.SingleRecordingVideoMessageSuffix
_FormattedString * _Nonnull _LOB(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2158, _0);
}
// DialogList.SingleTypingSuffix
_FormattedString * _Nonnull _LOC(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2159, _0);
}
// DialogList.SingleUploadingFileSuffix
_FormattedString * _Nonnull _LOD(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2160, _0);
}
// DialogList.SingleUploadingPhotoSuffix
_FormattedString * _Nonnull _LOE(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2161, _0);
}
// DialogList.SingleUploadingVideoSuffix
_FormattedString * _Nonnull _LOF(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2162, _0);
}
// DialogList.TabTitle
NSString * _Nonnull _LOG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2163);
}
// DialogList.Title
NSString * _Nonnull _LOH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2164);
}
// DialogList.Typing
NSString * _Nonnull _LOI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2165);
}
// DialogList.UnknownPinLimitError
NSString * _Nonnull _LOJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2166);
}
// DialogList.Unpin
NSString * _Nonnull _LOK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2167);
}
// DialogList.Unread
NSString * _Nonnull _LOL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2168);
}
// DialogList.You
NSString * _Nonnull _LOM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2169);
}
// DoNotTranslate.Title
NSString * _Nonnull _LON(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2170);
}
// Document.TargetConfirmationFormat
NSString * _Nonnull _LOO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2171);
}
// DownloadList.CancelDownloading
NSString * _Nonnull _LOP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2172);
}
// DownloadList.Clear
NSString * _Nonnull _LOQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2173);
}
// DownloadList.ClearAlertText
NSString * _Nonnull _LOR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2174);
}
// DownloadList.ClearAlertTitle
NSString * _Nonnull _LOS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2175);
}
// DownloadList.ClearDownloadList
NSString * _Nonnull _LOT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2176);
}
// DownloadList.DeleteFromCache
NSString * _Nonnull _LOU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2177);
}
// DownloadList.DownloadedHeader
NSString * _Nonnull _LOV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2178);
}
// DownloadList.DownloadingHeader
NSString * _Nonnull _LOW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2179);
}
// DownloadList.IncreaseSpeed
NSString * _Nonnull _LOX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2180);
}
// DownloadList.OptionManageDeviceStorage
NSString * _Nonnull _LOY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2181);
}
// DownloadList.PauseAll
NSString * _Nonnull _LOZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2182);
}
// DownloadList.RaisePriority
NSString * _Nonnull _LPa(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2183);
}
// DownloadList.RemoveFileAlertRemove
NSString * _Nonnull _LPb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2184);
}
// DownloadList.RemoveFileAlertText
NSString * _Nonnull _LPc(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 2185, value);
}
// DownloadList.RemoveFileAlertTitle
NSString * _Nonnull _LPd(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 2186, value);
}
// DownloadList.ResumeAll
NSString * _Nonnull _LPe(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2187);
}
// DownloadingStatus
_FormattedString * _Nonnull _LPf(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 2188, _0, _1);
}
// EditProfile.NameAndPhotoHelp
NSString * _Nonnull _LPg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2189);
}
// EditProfile.NameAndPhotoOrVideoHelp
NSString * _Nonnull _LPh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2190);
}
// EditProfile.Title
NSString * _Nonnull _LPi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2191);
}
// EditTheme.ChangeColors
NSString * _Nonnull _LPj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2192);
}
// EditTheme.Create.BottomInfo
NSString * _Nonnull _LPk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2193);
}
// EditTheme.Create.Preview.IncomingReplyName
NSString * _Nonnull _LPl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2194);
}
// EditTheme.Create.Preview.IncomingReplyText
NSString * _Nonnull _LPm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2195);
}
// EditTheme.Create.Preview.IncomingText
NSString * _Nonnull _LPn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2196);
}
// EditTheme.Create.Preview.OutgoingText
NSString * _Nonnull _LPo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2197);
}
// EditTheme.Create.TopInfo
NSString * _Nonnull _LPp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2198);
}
// EditTheme.CreateTitle
NSString * _Nonnull _LPq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2199);
}
// EditTheme.Edit.BottomInfo
NSString * _Nonnull _LPr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2200);
}
// EditTheme.Edit.Preview.IncomingReplyName
NSString * _Nonnull _LPs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2201);
}
// EditTheme.Edit.Preview.IncomingReplyText
NSString * _Nonnull _LPt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2202);
}
// EditTheme.Edit.Preview.IncomingText
NSString * _Nonnull _LPu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2203);
}
// EditTheme.Edit.Preview.OutgoingText
NSString * _Nonnull _LPv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2204);
}
// EditTheme.Edit.TopInfo
NSString * _Nonnull _LPw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2205);
}
// EditTheme.EditTitle
NSString * _Nonnull _LPx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2206);
}
// EditTheme.ErrorInvalidCharacters
NSString * _Nonnull _LPy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2207);
}
// EditTheme.ErrorLinkTaken
NSString * _Nonnull _LPz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2208);
}
// EditTheme.Expand.BottomInfo
NSString * _Nonnull _LPA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2209);
}
// EditTheme.Expand.Preview.IncomingReplyName
NSString * _Nonnull _LPB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2210);
}
// EditTheme.Expand.Preview.IncomingReplyText
NSString * _Nonnull _LPC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2211);
}
// EditTheme.Expand.Preview.IncomingText
NSString * _Nonnull _LPD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2212);
}
// EditTheme.Expand.Preview.OutgoingText
NSString * _Nonnull _LPE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2213);
}
// EditTheme.Expand.TopInfo
NSString * _Nonnull _LPF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2214);
}
// EditTheme.FileReadError
NSString * _Nonnull _LPG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2215);
}
// EditTheme.Preview
NSString * _Nonnull _LPH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2216);
}
// EditTheme.ShortLink
NSString * _Nonnull _LPI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2217);
}
// EditTheme.ThemeTemplateAlertText
NSString * _Nonnull _LPJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2218);
}
// EditTheme.ThemeTemplateAlertTitle
NSString * _Nonnull _LPK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2219);
}
// EditTheme.Title
NSString * _Nonnull _LPL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2220);
}
// EditTheme.UploadEditedTheme
NSString * _Nonnull _LPM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2221);
}
// EditTheme.UploadNewTheme
NSString * _Nonnull _LPN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2222);
}
// Embed.PlayingInPIP
NSString * _Nonnull _LPO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2223);
}
// Emoji.ClearRecent
NSString * _Nonnull _LPP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2224);
}
// Emoji.FrequentlyUsed
NSString * _Nonnull _LPQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2225);
}
// EmojiInput.AddPack
_FormattedString * _Nonnull _LPR(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2226, _0);
}
// EmojiInput.PanelTitleEmoji
NSString * _Nonnull _LPS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2227);
}
// EmojiInput.PanelTitlePremium
NSString * _Nonnull _LPT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2228);
}
// EmojiInput.PanelTitleRecent
NSString * _Nonnull _LPU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2229);
}
// EmojiInput.PremiumEmojiToast.Action
NSString * _Nonnull _LPV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2230);
}
// EmojiInput.PremiumEmojiToast.Text
NSString * _Nonnull _LPW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2231);
}
// EmojiInput.PremiumEmojiToast.TryAction
NSString * _Nonnull _LPX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2232);
}
// EmojiInput.PremiumEmojiToast.TryText
NSString * _Nonnull _LPY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2233);
}
// EmojiInput.SectionTitleEmoji
NSString * _Nonnull _LPZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2234);
}
// EmojiInput.SectionTitleFavoriteStickers
NSString * _Nonnull _LQa(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2235);
}
// EmojiInput.SectionTitlePremiumStickers
NSString * _Nonnull _LQb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2236);
}
// EmojiInput.TabEmoji
NSString * _Nonnull _LQc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2237);
}
// EmojiInput.TabGifs
NSString * _Nonnull _LQd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2238);
}
// EmojiInput.TabMasks
NSString * _Nonnull _LQe(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2239);
}
// EmojiInput.TabStickers
NSString * _Nonnull _LQf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2240);
}
// EmojiInput.TrendingEmoji
NSString * _Nonnull _LQg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2241);
}
// EmojiInput.UnlockPack
_FormattedString * _Nonnull _LQh(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2242, _0);
}
// EmojiPack.Add
NSString * _Nonnull _LQi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2243);
}
// EmojiPack.Added
NSString * _Nonnull _LQj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2244);
}
// EmojiPack.Emoji
NSString * _Nonnull _LQk(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 2245, value);
}
// EmojiPack.Title
NSString * _Nonnull _LQl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2246);
}
// EmojiPackActionInfo.AddedText
_FormattedString * _Nonnull _LQm(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2247, _0);
}
// EmojiPackActionInfo.AddedTitle
NSString * _Nonnull _LQn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2248);
}
// EmojiPackActionInfo.ArchivedTitle
NSString * _Nonnull _LQo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2249);
}
// EmojiPackActionInfo.MultipleAddedText
NSString * _Nonnull _LQp(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 2250, value);
}
// EmojiPackActionInfo.MultipleRemovedText
NSString * _Nonnull _LQq(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 2251, value);
}
// EmojiPackActionInfo.RemovedText
_FormattedString * _Nonnull _LQr(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2252, _0);
}
// EmojiPackActionInfo.RemovedTitle
NSString * _Nonnull _LQs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2253);
}
// EmojiPacksSettings.Title
NSString * _Nonnull _LQt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2254);
}
// EmojiPreview.CopyEmoji
NSString * _Nonnull _LQu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2255);
}
// EmojiPreview.SendEmoji
NSString * _Nonnull _LQv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2256);
}
// EmojiPreview.SetAsStatus
NSString * _Nonnull _LQw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2257);
}
// EmojiSearch.SearchEmojiEmptyResult
NSString * _Nonnull _LQx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2258);
}
// EmojiSearch.SearchEmojiPlaceholder
NSString * _Nonnull _LQy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2259);
}
// EmojiSearch.SearchReactionsEmptyResult
NSString * _Nonnull _LQz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2260);
}
// EmojiSearch.SearchReactionsPlaceholder
NSString * _Nonnull _LQA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2261);
}
// EmojiSearch.SearchStatusesEmptyResult
NSString * _Nonnull _LQB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2262);
}
// EmojiSearch.SearchStatusesPlaceholder
NSString * _Nonnull _LQC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2263);
}
// EmojiSearch.SearchStickersEmptyResult
NSString * _Nonnull _LQD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2264);
}
// EmojiSearch.SearchTopicIconsEmptyResult
NSString * _Nonnull _LQE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2265);
}
// EmojiSearch.SearchTopicIconsPlaceholder
NSString * _Nonnull _LQF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2266);
}
// EmojiStatus.AppliedText
NSString * _Nonnull _LQG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2267);
}
// EmojiStatusSetup.SetUntil
NSString * _Nonnull _LQH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2268);
}
// EmojiStatusSetup.TimerOther
NSString * _Nonnull _LQI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2269);
}
// EmojiStickerSettings.Info
NSString * _Nonnull _LQJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2270);
}
// EmptyGroupInfo.Line1
_FormattedString * _Nonnull _LQK(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2271, _0);
}
// EmptyGroupInfo.Line2
NSString * _Nonnull _LQL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2272);
}
// EmptyGroupInfo.Line3
NSString * _Nonnull _LQM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2273);
}
// EmptyGroupInfo.Line4
NSString * _Nonnull _LQN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2274);
}
// EmptyGroupInfo.Subtitle
NSString * _Nonnull _LQO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2275);
}
// EmptyGroupInfo.Title
NSString * _Nonnull _LQP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2276);
}
// EncryptionKey.Description
_FormattedString * _Nonnull _LQQ(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 2277, _0, _1);
}
// EncryptionKey.Title
NSString * _Nonnull _LQR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2278);
}
// EnterPasscode.ChangeTitle
NSString * _Nonnull _LQS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2279);
}
// EnterPasscode.EnterCurrentPasscode
NSString * _Nonnull _LQT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2280);
}
// EnterPasscode.EnterNewPasscodeChange
NSString * _Nonnull _LQU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2281);
}
// EnterPasscode.EnterNewPasscodeNew
NSString * _Nonnull _LQV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2282);
}
// EnterPasscode.EnterPasscode
NSString * _Nonnull _LQW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2283);
}
// EnterPasscode.EnterTitle
NSString * _Nonnull _LQX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2284);
}
// EnterPasscode.RepeatNewPasscode
NSString * _Nonnull _LQY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2285);
}
// EnterPasscode.TouchId
NSString * _Nonnull _LQZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2286);
}
// Exceptions.AddToExceptions
NSString * _Nonnull _LRa(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2287);
}
// ExplicitContent.AlertChannel
NSString * _Nonnull _LRb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2288);
}
// ExplicitContent.AlertTitle
NSString * _Nonnull _LRc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2289);
}
// External.OpenIn
_FormattedString * _Nonnull _LRd(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2290, _0);
}
// FastTwoStepSetup.EmailHelp
NSString * _Nonnull _LRe(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2291);
}
// FastTwoStepSetup.EmailPlaceholder
NSString * _Nonnull _LRf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2292);
}
// FastTwoStepSetup.EmailSection
NSString * _Nonnull _LRg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2293);
}
// FastTwoStepSetup.HintHelp
NSString * _Nonnull _LRh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2294);
}
// FastTwoStepSetup.HintPlaceholder
NSString * _Nonnull _LRi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2295);
}
// FastTwoStepSetup.HintSection
NSString * _Nonnull _LRj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2296);
}
// FastTwoStepSetup.PasswordConfirmationPlaceholder
NSString * _Nonnull _LRk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2297);
}
// FastTwoStepSetup.PasswordHelp
NSString * _Nonnull _LRl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2298);
}
// FastTwoStepSetup.PasswordPlaceholder
NSString * _Nonnull _LRm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2299);
}
// FastTwoStepSetup.PasswordSection
NSString * _Nonnull _LRn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2300);
}
// FastTwoStepSetup.Title
NSString * _Nonnull _LRo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2301);
}
// FeatureDisabled.Oops
NSString * _Nonnull _LRp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2302);
}
// FeaturedStickerPacks.Title
NSString * _Nonnull _LRq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2303);
}
// FeaturedStickers.OtherSection
NSString * _Nonnull _LRr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2304);
}
// FileSize.B
_FormattedString * _Nonnull _LRs(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2305, _0);
}
// FileSize.GB
_FormattedString * _Nonnull _LRt(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2306, _0);
}
// FileSize.KB
_FormattedString * _Nonnull _LRu(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2307, _0);
}
// FileSize.MB
_FormattedString * _Nonnull _LRv(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2308, _0);
}
// ForcedPasswordSetup.Intro.Action
NSString * _Nonnull _LRw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2309);
}
// ForcedPasswordSetup.Intro.DismissActionCancel
NSString * _Nonnull _LRx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2310);
}
// ForcedPasswordSetup.Intro.DismissActionOK
NSString * _Nonnull _LRy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2311);
}
// ForcedPasswordSetup.Intro.DismissText
NSString * _Nonnull _LRz(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 2312, value);
}
// ForcedPasswordSetup.Intro.DismissTitle
NSString * _Nonnull _LRA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2313);
}
// ForcedPasswordSetup.Intro.DoneAction
NSString * _Nonnull _LRB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2314);
}
// ForcedPasswordSetup.Intro.Text
NSString * _Nonnull _LRC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2315);
}
// ForcedPasswordSetup.Intro.Title
NSString * _Nonnull _LRD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2316);
}
// Forward.ChannelReadOnly
NSString * _Nonnull _LRE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2317);
}
// Forward.ConfirmMultipleFiles
NSString * _Nonnull _LRF(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 2318, value);
}
// Forward.ErrorDisabledForChat
NSString * _Nonnull _LRG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2319);
}
// Forward.ErrorPublicPollDisabledInChannels
NSString * _Nonnull _LRH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2320);
}
// Forward.ErrorPublicQuizDisabledInChannels
NSString * _Nonnull _LRI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2321);
}
// ForwardedAudios
NSString * _Nonnull _LRJ(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 2322, value);
}
// ForwardedAuthors2
_FormattedString * _Nonnull _LRK(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 2323, _0, _1);
}
// ForwardedContacts
NSString * _Nonnull _LRL(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 2324, value);
}
// ForwardedFiles
NSString * _Nonnull _LRM(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 2325, value);
}
// ForwardedGifs
NSString * _Nonnull _LRN(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 2326, value);
}
// ForwardedLocations
NSString * _Nonnull _LRO(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 2327, value);
}
// ForwardedMessages
NSString * _Nonnull _LRP(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 2328, value);
}
// ForwardedPhotos
NSString * _Nonnull _LRQ(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 2329, value);
}
// ForwardedPolls
NSString * _Nonnull _LRR(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 2330, value);
}
// ForwardedStickers
NSString * _Nonnull _LRS(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 2331, value);
}
// ForwardedVideoMessages
NSString * _Nonnull _LRT(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 2332, value);
}
// ForwardedVideos
NSString * _Nonnull _LRU(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 2333, value);
}
// Gallery.AirPlay
NSString * _Nonnull _LRV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2334);
}
// Gallery.AirPlayPlaceholder
NSString * _Nonnull _LRW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2335);
}
// Gallery.GifSaved
NSString * _Nonnull _LRX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2336);
}
// Gallery.ImageSaved
NSString * _Nonnull _LRY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2337);
}
// Gallery.ImagesAndVideosSaved
NSString * _Nonnull _LRZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2338);
}
// Gallery.SaveImage
NSString * _Nonnull _LSa(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2339);
}
// Gallery.SaveToGallery
NSString * _Nonnull _LSb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2340);
}
// Gallery.SaveVideo
NSString * _Nonnull _LSc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2341);
}
// Gallery.VideoSaved
NSString * _Nonnull _LSd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2342);
}
// Gallery.VoiceOver.Delete
NSString * _Nonnull _LSe(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2343);
}
// Gallery.VoiceOver.Edit
NSString * _Nonnull _LSf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2344);
}
// Gallery.VoiceOver.Fullscreen
NSString * _Nonnull _LSg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2345);
}
// Gallery.VoiceOver.PictureInPicture
NSString * _Nonnull _LSh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2346);
}
// Gallery.VoiceOver.Share
NSString * _Nonnull _LSi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2347);
}
// Gallery.VoiceOver.Stickers
NSString * _Nonnull _LSj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2348);
}
// Gallery.WaitForVideoDownoad
NSString * _Nonnull _LSk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2349);
}
// Generic.ErrorMoreInfo
NSString * _Nonnull _LSl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2350);
}
// Generic.OpenHiddenLinkAlert
_FormattedString * _Nonnull _LSm(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2351, _0);
}
// Gif.Emotion.Angry
NSString * _Nonnull _LSn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2352);
}
// Gif.Emotion.Cool
NSString * _Nonnull _LSo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2353);
}
// Gif.Emotion.Hearts
NSString * _Nonnull _LSp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2354);
}
// Gif.Emotion.Joy
NSString * _Nonnull _LSq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2355);
}
// Gif.Emotion.Kiss
NSString * _Nonnull _LSr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2356);
}
// Gif.Emotion.Party
NSString * _Nonnull _LSs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2357);
}
// Gif.Emotion.RollEyes
NSString * _Nonnull _LSt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2358);
}
// Gif.Emotion.Surprised
NSString * _Nonnull _LSu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2359);
}
// Gif.Emotion.ThumbsDown
NSString * _Nonnull _LSv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2360);
}
// Gif.Emotion.ThumbsUp
NSString * _Nonnull _LSw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2361);
}
// Gif.NoGifsFound
NSString * _Nonnull _LSx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2362);
}
// Gif.NoGifsPlaceholder
NSString * _Nonnull _LSy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2363);
}
// Gif.Search
NSString * _Nonnull _LSz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2364);
}
// GifSearch.SearchGifPlaceholder
NSString * _Nonnull _LSA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2365);
}
// GlobalAutodeleteSettings.ApplyChatsPlaceholder
_FormattedString * _Nonnull _LSB(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2366, _0);
}
// GlobalAutodeleteSettings.ApplyChatsSubject
NSString * _Nonnull _LSC(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 2367, value);
}
// GlobalAutodeleteSettings.ApplyChatsTitle
NSString * _Nonnull _LSD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2368);
}
// GlobalAutodeleteSettings.ApplyChatsToast
_FormattedString * _Nonnull _LSE(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 2369, _0, _1);
}
// GlobalAutodeleteSettings.AttemptDisabledChannelSelection
NSString * _Nonnull _LSF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2370);
}
// GlobalAutodeleteSettings.AttemptDisabledGenericSelection
NSString * _Nonnull _LSG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2371);
}
// GlobalAutodeleteSettings.AttemptDisabledGroupSelection
NSString * _Nonnull _LSH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2372);
}
// GlobalAutodeleteSettings.InfoDisabled
NSString * _Nonnull _LSI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2373);
}
// GlobalAutodeleteSettings.InfoEnabled
_FormattedString * _Nonnull _LSJ(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2374, _0);
}
// GlobalAutodeleteSettings.OptionTitle
_FormattedString * _Nonnull _LSK(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2375, _0);
}
// GlobalAutodeleteSettings.OptionsHeader
NSString * _Nonnull _LSL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2376);
}
// GlobalAutodeleteSettings.SetConfirmAction
NSString * _Nonnull _LSM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2377);
}
// GlobalAutodeleteSettings.SetConfirmText
_FormattedString * _Nonnull _LSN(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2378, _0);
}
// GlobalAutodeleteSettings.SetConfirmTitle
NSString * _Nonnull _LSO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2379);
}
// GlobalAutodeleteSettings.SetConfirmToastDisabled
NSString * _Nonnull _LSP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2380);
}
// GlobalAutodeleteSettings.SetConfirmToastEnabled
_FormattedString * _Nonnull _LSQ(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2381, _0);
}
// GlobalAutodeleteSettings.SetCustomTime
NSString * _Nonnull _LSR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2382);
}
// GlobalAutodeleteSettings.Title
NSString * _Nonnull _LSS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2383);
}
// Group.About.Help
NSString * _Nonnull _LST(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2384);
}
// Group.AdminLog.AntiSpamFalsePositiveReportedText
NSString * _Nonnull _LSU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2385);
}
// Group.AdminLog.AntiSpamText
NSString * _Nonnull _LSV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2386);
}
// Group.AdminLog.AntiSpamTitle
NSString * _Nonnull _LSW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2387);
}
// Group.AdminLog.EmptyText
NSString * _Nonnull _LSX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2388);
}
// Group.ApplyToJoin
NSString * _Nonnull _LSY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2389);
}
// Group.DeleteGroup
NSString * _Nonnull _LSZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2390);
}
// Group.Edit.PrivatePublicLinkAlert
NSString * _Nonnull _LTa(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2391);
}
// Group.EditAdmin.PermissionChangeInfo
NSString * _Nonnull _LTb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2392);
}
// Group.EditAdmin.RankAdminPlaceholder
NSString * _Nonnull _LTc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2393);
}
// Group.EditAdmin.RankInfo
_FormattedString * _Nonnull _LTd(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2394, _0);
}
// Group.EditAdmin.RankOwnerPlaceholder
NSString * _Nonnull _LTe(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2395);
}
// Group.EditAdmin.RankTitle
NSString * _Nonnull _LTf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2396);
}
// Group.EditAdmin.TransferOwnership
NSString * _Nonnull _LTg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2397);
}
// Group.ErrorAccessDenied
NSString * _Nonnull _LTh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2398);
}
// Group.ErrorAddBlocked
NSString * _Nonnull _LTi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2399);
}
// Group.ErrorAddTooMuchAdmins
NSString * _Nonnull _LTj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2400);
}
// Group.ErrorAddTooMuchBots
NSString * _Nonnull _LTk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2401);
}
// Group.ErrorAdminsTooMuch
NSString * _Nonnull _LTl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2402);
}
// Group.ErrorNotMutualContact
NSString * _Nonnull _LTm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2403);
}
// Group.ErrorSendRestrictedMedia
NSString * _Nonnull _LTn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2404);
}
// Group.ErrorSendRestrictedStickers
NSString * _Nonnull _LTo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2405);
}
// Group.ErrorSupergroupConversionNotPossible
NSString * _Nonnull _LTp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2406);
}
// Group.GroupMembersHeader
NSString * _Nonnull _LTq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2407);
}
// Group.Info.AdminLog
NSString * _Nonnull _LTr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2408);
}
// Group.Info.Members
NSString * _Nonnull _LTs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2409);
}
// Group.JoinGroup
NSString * _Nonnull _LTt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2410);
}
// Group.LeaveGroup
NSString * _Nonnull _LTu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2411);
}
// Group.LinkedChannel
NSString * _Nonnull _LTv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2412);
}
// Group.Location.ChangeLocation
NSString * _Nonnull _LTw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2413);
}
// Group.Location.CreateInThisPlace
NSString * _Nonnull _LTx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2414);
}
// Group.Location.Info
NSString * _Nonnull _LTy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2415);
}
// Group.Location.Title
NSString * _Nonnull _LTz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2416);
}
// Group.Management.AddModeratorHelp
NSString * _Nonnull _LTA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2417);
}
// Group.Management.AntiSpam
NSString * _Nonnull _LTB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2418);
}
// Group.Management.AntiSpamInfo
NSString * _Nonnull _LTC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2419);
}
// Group.Management.AntiSpamMagic
NSString * _Nonnull _LTD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2420);
}
// Group.Members.AddMemberBotErrorNotAllowed
NSString * _Nonnull _LTE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2421);
}
// Group.Members.AddMembers
NSString * _Nonnull _LTF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2422);
}
// Group.Members.AddMembersHelp
NSString * _Nonnull _LTG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2423);
}
// Group.Members.Contacts
NSString * _Nonnull _LTH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2424);
}
// Group.Members.Other
NSString * _Nonnull _LTI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2425);
}
// Group.Members.Title
NSString * _Nonnull _LTJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2426);
}
// Group.MessagePhotoRemoved
NSString * _Nonnull _LTK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2427);
}
// Group.MessagePhotoUpdated
NSString * _Nonnull _LTL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2428);
}
// Group.MessageVideoUpdated
NSString * _Nonnull _LTM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2429);
}
// Group.OwnershipTransfer.DescriptionInfo
_FormattedString * _Nonnull _LTN(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 2430, _0, _1);
}
// Group.OwnershipTransfer.ErrorAdminsTooMuch
NSString * _Nonnull _LTO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2431);
}
// Group.OwnershipTransfer.ErrorLocatedGroupsTooMuch
NSString * _Nonnull _LTP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2432);
}
// Group.OwnershipTransfer.ErrorPrivacyRestricted
NSString * _Nonnull _LTQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2433);
}
// Group.OwnershipTransfer.Title
NSString * _Nonnull _LTR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2434);
}
// Group.PublicLink.Info
NSString * _Nonnull _LTS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2435);
}
// Group.PublicLink.Placeholder
NSString * _Nonnull _LTT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2436);
}
// Group.PublicLink.Title
NSString * _Nonnull _LTU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2437);
}
// Group.RequestToJoinSent
NSString * _Nonnull _LTV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2438);
}
// Group.RequestToJoinSentDescriptionGroup
NSString * _Nonnull _LTW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2439);
}
// Group.Setup.ActivateAlertShow
NSString * _Nonnull _LTX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2440);
}
// Group.Setup.ActivateAlertText
NSString * _Nonnull _LTY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2441);
}
// Group.Setup.ActivateAlertTitle
NSString * _Nonnull _LTZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2442);
}
// Group.Setup.ActiveLimitReachedError
NSString * _Nonnull _LUa(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2443);
}
// Group.Setup.ApproveNewMembers
NSString * _Nonnull _LUb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2444);
}
// Group.Setup.ApproveNewMembersInfo
NSString * _Nonnull _LUc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2445);
}
// Group.Setup.BasicHistoryHiddenHelp
NSString * _Nonnull _LUd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2446);
}
// Group.Setup.DeactivateAlertHide
NSString * _Nonnull _LUe(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2447);
}
// Group.Setup.DeactivateAlertText
NSString * _Nonnull _LUf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2448);
}
// Group.Setup.DeactivateAlertTitle
NSString * _Nonnull _LUg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2449);
}
// Group.Setup.ForwardingChannelInfo
NSString * _Nonnull _LUh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2450);
}
// Group.Setup.ForwardingChannelInfoDisabled
NSString * _Nonnull _LUi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2451);
}
// Group.Setup.ForwardingChannelTitle
NSString * _Nonnull _LUj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2452);
}
// Group.Setup.ForwardingDisabled
NSString * _Nonnull _LUk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2453);
}
// Group.Setup.ForwardingEnabled
NSString * _Nonnull _LUl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2454);
}
// Group.Setup.ForwardingGroupInfo
NSString * _Nonnull _LUm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2455);
}
// Group.Setup.ForwardingGroupInfoDisabled
NSString * _Nonnull _LUn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2456);
}
// Group.Setup.ForwardingGroupTitle
NSString * _Nonnull _LUo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2457);
}
// Group.Setup.HistoryHeader
NSString * _Nonnull _LUp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2458);
}
// Group.Setup.HistoryHidden
NSString * _Nonnull _LUq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2459);
}
// Group.Setup.HistoryHiddenHelp
NSString * _Nonnull _LUr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2460);
}
// Group.Setup.HistoryTitle
NSString * _Nonnull _LUs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2461);
}
// Group.Setup.HistoryVisible
NSString * _Nonnull _LUt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2462);
}
// Group.Setup.HistoryVisibleHelp
NSString * _Nonnull _LUu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2463);
}
// Group.Setup.LinkActive
NSString * _Nonnull _LUv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2464);
}
// Group.Setup.LinkInactive
NSString * _Nonnull _LUw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2465);
}
// Group.Setup.LinksOrder
NSString * _Nonnull _LUx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2466);
}
// Group.Setup.LinksOrderInfo
NSString * _Nonnull _LUy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2467);
}
// Group.Setup.PublicLink
NSString * _Nonnull _LUz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2468);
}
// Group.Setup.TypeHeader
NSString * _Nonnull _LUA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2469);
}
// Group.Setup.TypePrivate
NSString * _Nonnull _LUB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2470);
}
// Group.Setup.TypePrivateHelp
NSString * _Nonnull _LUC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2471);
}
// Group.Setup.TypePublic
NSString * _Nonnull _LUD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2472);
}
// Group.Setup.TypePublicHelp
NSString * _Nonnull _LUE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2473);
}
// Group.Setup.WhoCanSendMessages.Everyone
NSString * _Nonnull _LUF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2474);
}
// Group.Setup.WhoCanSendMessages.OnlyMembers
NSString * _Nonnull _LUG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2475);
}
// Group.Setup.WhoCanSendMessages.Title
NSString * _Nonnull _LUH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2476);
}
// Group.Status
NSString * _Nonnull _LUI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2477);
}
// Group.UpgradeConfirmation
NSString * _Nonnull _LUJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2478);
}
// Group.UpgradeNoticeHeader
NSString * _Nonnull _LUK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2479);
}
// Group.UpgradeNoticeText1
NSString * _Nonnull _LUL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2480);
}
// Group.UpgradeNoticeText2
NSString * _Nonnull _LUM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2481);
}
// Group.Username.CreatePrivateLinkHelp
NSString * _Nonnull _LUN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2482);
}
// Group.Username.CreatePublicLinkHelp
NSString * _Nonnull _LUO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2483);
}
// Group.Username.InvalidEndsWithUnderscore
NSString * _Nonnull _LUP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2484);
}
// Group.Username.InvalidStartsWithNumber
NSString * _Nonnull _LUQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2485);
}
// Group.Username.InvalidStartsWithUnderscore
NSString * _Nonnull _LUR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2486);
}
// Group.Username.InvalidTooShort
NSString * _Nonnull _LUS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2487);
}
// Group.Username.RemoveExistingUsernamesFinalInfo
NSString * _Nonnull _LUT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2488);
}
// Group.Username.RemoveExistingUsernamesInfo
NSString * _Nonnull _LUU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2489);
}
// Group.Username.RemoveExistingUsernamesNoPremiumInfo
NSString * _Nonnull _LUV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2490);
}
// Group.Username.RemoveExistingUsernamesOrExtendInfo
_FormattedString * _Nonnull _LUW(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2491, _0);
}
// Group.Username.RevokeExistingUsernamesInfo
NSString * _Nonnull _LUX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2492);
}
// GroupInfo.ActionPromote
NSString * _Nonnull _LUY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2493);
}
// GroupInfo.ActionRestrict
NSString * _Nonnull _LUZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2494);
}
// GroupInfo.AddParticipant
NSString * _Nonnull _LVa(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2495);
}
// GroupInfo.AddParticipantConfirmation
_FormattedString * _Nonnull _LVb(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2496, _0);
}
// GroupInfo.AddParticipantTitle
NSString * _Nonnull _LVc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2497);
}
// GroupInfo.AddUserLeftError
NSString * _Nonnull _LVd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2498);
}
// GroupInfo.Administrators
NSString * _Nonnull _LVe(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2499);
}
// GroupInfo.Administrators.Title
NSString * _Nonnull _LVf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2500);
}
// GroupInfo.BroadcastListNamePlaceholder
NSString * _Nonnull _LVg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2501);
}
// GroupInfo.ChannelListNamePlaceholder
NSString * _Nonnull _LVh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2502);
}
// GroupInfo.ChatAdmins
NSString * _Nonnull _LVi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2503);
}
// GroupInfo.ConvertToSupergroup
NSString * _Nonnull _LVj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2504);
}
// GroupInfo.DeactivatedStatus
NSString * _Nonnull _LVk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2505);
}
// GroupInfo.DeleteAndExit
NSString * _Nonnull _LVl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2506);
}
// GroupInfo.DeleteAndExitConfirmation
NSString * _Nonnull _LVm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2507);
}
// GroupInfo.FakeGroupWarning
NSString * _Nonnull _LVn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2508);
}
// GroupInfo.GroupHistory
NSString * _Nonnull _LVo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2509);
}
// GroupInfo.GroupHistoryHidden
NSString * _Nonnull _LVp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2510);
}
// GroupInfo.GroupHistoryShort
NSString * _Nonnull _LVq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2511);
}
// GroupInfo.GroupHistoryVisible
NSString * _Nonnull _LVr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2512);
}
// GroupInfo.GroupNamePlaceholder
NSString * _Nonnull _LVs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2513);
}
// GroupInfo.GroupType
NSString * _Nonnull _LVt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2514);
}
// GroupInfo.InvitationLinkAcceptChannel
_FormattedString * _Nonnull _LVu(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2515, _0);
}
// GroupInfo.InvitationLinkDoesNotExist
NSString * _Nonnull _LVv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2516);
}
// GroupInfo.InvitationLinkGroupFull
NSString * _Nonnull _LVw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2517);
}
// GroupInfo.InviteByLink
NSString * _Nonnull _LVx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2518);
}
// GroupInfo.InviteLink.CopyAlert.Success
NSString * _Nonnull _LVy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2519);
}
// GroupInfo.InviteLink.CopyLink
NSString * _Nonnull _LVz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2520);
}
// GroupInfo.InviteLink.Help
NSString * _Nonnull _LVA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2521);
}
// GroupInfo.InviteLink.LinkSection
NSString * _Nonnull _LVB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2522);
}
// GroupInfo.InviteLink.RevokeAlert.Revoke
NSString * _Nonnull _LVC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2523);
}
// GroupInfo.InviteLink.RevokeAlert.Success
NSString * _Nonnull _LVD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2524);
}
// GroupInfo.InviteLink.RevokeAlert.Text
NSString * _Nonnull _LVE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2525);
}
// GroupInfo.InviteLink.RevokeLink
NSString * _Nonnull _LVF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2526);
}
// GroupInfo.InviteLink.ShareLink
NSString * _Nonnull _LVG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2527);
}
// GroupInfo.InviteLink.Title
NSString * _Nonnull _LVH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2528);
}
// GroupInfo.InviteLinks
NSString * _Nonnull _LVI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2529);
}
// GroupInfo.LabelAdmin
NSString * _Nonnull _LVJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2530);
}
// GroupInfo.LabelOwner
NSString * _Nonnull _LVK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2531);
}
// GroupInfo.LeftStatus
NSString * _Nonnull _LVL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2532);
}
// GroupInfo.Location
NSString * _Nonnull _LVM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2533);
}
// GroupInfo.MemberRequests
NSString * _Nonnull _LVN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2534);
}
// GroupInfo.Notifications
NSString * _Nonnull _LVO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2535);
}
// GroupInfo.ParticipantCount
NSString * _Nonnull _LVP(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 2536, value);
}
// GroupInfo.Permissions
NSString * _Nonnull _LVQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2537);
}
// GroupInfo.Permissions.AddException
NSString * _Nonnull _LVR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2538);
}
// GroupInfo.Permissions.BroadcastConvert
NSString * _Nonnull _LVS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2539);
}
// GroupInfo.Permissions.BroadcastConvertInfo
_FormattedString * _Nonnull _LVT(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2540, _0);
}
// GroupInfo.Permissions.BroadcastTitle
NSString * _Nonnull _LVU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2541);
}
// GroupInfo.Permissions.EditingDisabled
NSString * _Nonnull _LVV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2542);
}
// GroupInfo.Permissions.Exceptions
NSString * _Nonnull _LVW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2543);
}
// GroupInfo.Permissions.Removed
NSString * _Nonnull _LVX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2544);
}
// GroupInfo.Permissions.SearchPlaceholder
NSString * _Nonnull _LVY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2545);
}
// GroupInfo.Permissions.SectionTitle
NSString * _Nonnull _LVZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2546);
}
// GroupInfo.Permissions.SlowmodeHeader
NSString * _Nonnull _LWa(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2547);
}
// GroupInfo.Permissions.SlowmodeInfo
NSString * _Nonnull _LWb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2548);
}
// GroupInfo.Permissions.SlowmodeValue.Off
NSString * _Nonnull _LWc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2549);
}
// GroupInfo.Permissions.Title
NSString * _Nonnull _LWd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2550);
}
// GroupInfo.PublicLink
NSString * _Nonnull _LWe(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2551);
}
// GroupInfo.PublicLinkAdd
NSString * _Nonnull _LWf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2552);
}
// GroupInfo.ScamGroupWarning
NSString * _Nonnull _LWg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2553);
}
// GroupInfo.SetGroupPhoto
NSString * _Nonnull _LWh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2554);
}
// GroupInfo.SetGroupPhotoDelete
NSString * _Nonnull _LWi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2555);
}
// GroupInfo.SetGroupPhotoStop
NSString * _Nonnull _LWj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2556);
}
// GroupInfo.SetSound
NSString * _Nonnull _LWk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2557);
}
// GroupInfo.SharedMedia
NSString * _Nonnull _LWl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2558);
}
// GroupInfo.SharedMediaNone
NSString * _Nonnull _LWm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2559);
}
// GroupInfo.ShowMoreMembers
NSString * _Nonnull _LWn(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 2560, value);
}
// GroupInfo.Sound
NSString * _Nonnull _LWo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2561);
}
// GroupInfo.Title
NSString * _Nonnull _LWp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2562);
}
// GroupInfo.TitleMembers
NSString * _Nonnull _LWq(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 2563, value);
}
// GroupInfo.UpgradeButton
NSString * _Nonnull _LWr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2564);
}
// GroupMembers.HideMembers
NSString * _Nonnull _LWs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2565);
}
// GroupMembers.MembersHiddenOff
NSString * _Nonnull _LWt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2566);
}
// GroupMembers.MembersHiddenOn
NSString * _Nonnull _LWu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2567);
}
// GroupPermission.AddMembersNotAvailable
NSString * _Nonnull _LWv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2568);
}
// GroupPermission.AddSuccess
NSString * _Nonnull _LWw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2569);
}
// GroupPermission.AddedInfo
_FormattedString * _Nonnull _LWx(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 2570, _0, _1);
}
// GroupPermission.ApplyAlertAction
NSString * _Nonnull _LWy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2571);
}
// GroupPermission.ApplyAlertText
_FormattedString * _Nonnull _LWz(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2572, _0);
}
// GroupPermission.Delete
NSString * _Nonnull _LWA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2573);
}
// GroupPermission.Duration
NSString * _Nonnull _LWB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2574);
}
// GroupPermission.EditingDisabled
NSString * _Nonnull _LWC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2575);
}
// GroupPermission.NewTitle
NSString * _Nonnull _LWD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2576);
}
// GroupPermission.NoAddMembers
NSString * _Nonnull _LWE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2577);
}
// GroupPermission.NoChangeInfo
NSString * _Nonnull _LWF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2578);
}
// GroupPermission.NoManageTopics
NSString * _Nonnull _LWG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2579);
}
// GroupPermission.NoPinMessages
NSString * _Nonnull _LWH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2580);
}
// GroupPermission.NoSendFile
NSString * _Nonnull _LWI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2581);
}
// GroupPermission.NoSendGifs
NSString * _Nonnull _LWJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2582);
}
// GroupPermission.NoSendLinks
NSString * _Nonnull _LWK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2583);
}
// GroupPermission.NoSendMedia
NSString * _Nonnull _LWL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2584);
}
// GroupPermission.NoSendMessages
NSString * _Nonnull _LWM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2585);
}
// GroupPermission.NoSendMusic
NSString * _Nonnull _LWN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2586);
}
// GroupPermission.NoSendPhoto
NSString * _Nonnull _LWO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2587);
}
// GroupPermission.NoSendPolls
NSString * _Nonnull _LWP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2588);
}
// GroupPermission.NoSendVideo
NSString * _Nonnull _LWQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2589);
}
// GroupPermission.NoSendVideoMessage
NSString * _Nonnull _LWR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2590);
}
// GroupPermission.NoSendVoiceMessage
NSString * _Nonnull _LWS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2591);
}
// GroupPermission.NotAvailableInPublicGroups
NSString * _Nonnull _LWT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2592);
}
// GroupPermission.PermissionDisabledByDefault
NSString * _Nonnull _LWU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2593);
}
// GroupPermission.PermissionGloballyDisabled
NSString * _Nonnull _LWV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2594);
}
// GroupPermission.SectionTitle
NSString * _Nonnull _LWW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2595);
}
// GroupPermission.Title
NSString * _Nonnull _LWX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2596);
}
// GroupRemoved.AddToGroup
NSString * _Nonnull _LWY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2597);
}
// GroupRemoved.DeleteUser
NSString * _Nonnull _LWZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2598);
}
// GroupRemoved.Remove
NSString * _Nonnull _LXa(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2599);
}
// GroupRemoved.RemoveInfo
NSString * _Nonnull _LXb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2600);
}
// GroupRemoved.Title
NSString * _Nonnull _LXc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2601);
}
// GroupRemoved.UsersSectionTitle
NSString * _Nonnull _LXd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2602);
}
// GroupRemoved.ViewChannelInfo
NSString * _Nonnull _LXe(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2603);
}
// GroupRemoved.ViewUserInfo
NSString * _Nonnull _LXf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2604);
}
// HashtagSearch.AllChats
NSString * _Nonnull _LXg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2605);
}
// ImportStickerPack.AddToExistingStickerSet
NSString * _Nonnull _LXh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2606);
}
// ImportStickerPack.CheckingLink
NSString * _Nonnull _LXi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2607);
}
// ImportStickerPack.ChooseLink
NSString * _Nonnull _LXj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2608);
}
// ImportStickerPack.ChooseLinkDescription
NSString * _Nonnull _LXk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2609);
}
// ImportStickerPack.ChooseName
NSString * _Nonnull _LXl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2610);
}
// ImportStickerPack.ChooseNameDescription
NSString * _Nonnull _LXm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2611);
}
// ImportStickerPack.ChooseStickerSet
NSString * _Nonnull _LXn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2612);
}
// ImportStickerPack.Create
NSString * _Nonnull _LXo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2613);
}
// ImportStickerPack.CreateNewStickerSet
NSString * _Nonnull _LXp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2614);
}
// ImportStickerPack.CreateStickerSet
NSString * _Nonnull _LXq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2615);
}
// ImportStickerPack.GeneratingLink
NSString * _Nonnull _LXr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2616);
}
// ImportStickerPack.ImportingStickers
NSString * _Nonnull _LXs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2617);
}
// ImportStickerPack.InProgress
NSString * _Nonnull _LXt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2618);
}
// ImportStickerPack.LinkAvailable
NSString * _Nonnull _LXu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2619);
}
// ImportStickerPack.LinkTaken
NSString * _Nonnull _LXv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2620);
}
// ImportStickerPack.NamePlaceholder
NSString * _Nonnull _LXw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2621);
}
// ImportStickerPack.Of
_FormattedString * _Nonnull _LXx(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 2622, _0, _1);
}
// ImportStickerPack.RemoveFromImport
NSString * _Nonnull _LXy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2623);
}
// ImportStickerPack.StickerCount
NSString * _Nonnull _LXz(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 2624, value);
}
// InfoPlist.NSCameraUsageDescription
NSString * _Nonnull _LXA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2625);
}
// InfoPlist.NSContactsUsageDescription
NSString * _Nonnull _LXB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2626);
}
// InfoPlist.NSFaceIDUsageDescription
NSString * _Nonnull _LXC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2627);
}
// InfoPlist.NSLocationAlwaysAndWhenInUseUsageDescription
NSString * _Nonnull _LXD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2628);
}
// InfoPlist.NSLocationAlwaysUsageDescription
NSString * _Nonnull _LXE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2629);
}
// InfoPlist.NSLocationWhenInUseUsageDescription
NSString * _Nonnull _LXF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2630);
}
// InfoPlist.NSMicrophoneUsageDescription
NSString * _Nonnull _LXG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2631);
}
// InfoPlist.NSPhotoLibraryAddUsageDescription
NSString * _Nonnull _LXH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2632);
}
// InfoPlist.NSPhotoLibraryUsageDescription
NSString * _Nonnull _LXI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2633);
}
// InfoPlist.NSSiriUsageDescription
NSString * _Nonnull _LXJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2634);
}
// InstantPage.AuthorAndDateTitle
_FormattedString * _Nonnull _LXK(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 2635, _0, _1);
}
// InstantPage.AutoNightTheme
NSString * _Nonnull _LXL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2636);
}
// InstantPage.FeedbackButton
NSString * _Nonnull _LXM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2637);
}
// InstantPage.FeedbackButtonShort
NSString * _Nonnull _LXN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2638);
}
// InstantPage.FontNewYork
NSString * _Nonnull _LXO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2639);
}
// InstantPage.FontSanFrancisco
NSString * _Nonnull _LXP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2640);
}
// InstantPage.OpenInBrowser
_FormattedString * _Nonnull _LXQ(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2641, _0);
}
// InstantPage.Reference
NSString * _Nonnull _LXR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2642);
}
// InstantPage.RelatedArticleAuthorAndDateTitle
_FormattedString * _Nonnull _LXS(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 2643, _0, _1);
}
// InstantPage.Search
NSString * _Nonnull _LXT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2644);
}
// InstantPage.TapToOpenLink
NSString * _Nonnull _LXU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2645);
}
// InstantPage.Views
NSString * _Nonnull _LXV(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 2646, value);
}
// InstantPage.VoiceOver.DecreaseFontSize
NSString * _Nonnull _LXW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2647);
}
// InstantPage.VoiceOver.IncreaseFontSize
NSString * _Nonnull _LXX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2648);
}
// InstantPage.VoiceOver.ResetFontSize
NSString * _Nonnull _LXY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2649);
}
// Intents.ErrorLockedText
NSString * _Nonnull _LXZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2650);
}
// Intents.ErrorLockedTitle
NSString * _Nonnull _LYa(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2651);
}
// IntentsSettings.MainAccount
NSString * _Nonnull _LYb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2652);
}
// IntentsSettings.MainAccountInfo
NSString * _Nonnull _LYc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2653);
}
// IntentsSettings.Reset
NSString * _Nonnull _LYd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2654);
}
// IntentsSettings.ResetAll
NSString * _Nonnull _LYe(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2655);
}
// IntentsSettings.SuggestBy
NSString * _Nonnull _LYf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2656);
}
// IntentsSettings.SuggestByAll
NSString * _Nonnull _LYg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2657);
}
// IntentsSettings.SuggestByShare
NSString * _Nonnull _LYh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2658);
}
// IntentsSettings.SuggestedAndSpotlightChatsInfo
NSString * _Nonnull _LYi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2659);
}
// IntentsSettings.SuggestedChats
NSString * _Nonnull _LYj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2660);
}
// IntentsSettings.SuggestedChatsContacts
NSString * _Nonnull _LYk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2661);
}
// IntentsSettings.SuggestedChatsGroups
NSString * _Nonnull _LYl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2662);
}
// IntentsSettings.SuggestedChatsInfo
NSString * _Nonnull _LYm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2663);
}
// IntentsSettings.SuggestedChatsPrivateChats
NSString * _Nonnull _LYn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2664);
}
// IntentsSettings.SuggestedChatsSavedMessages
NSString * _Nonnull _LYo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2665);
}
// IntentsSettings.Title
NSString * _Nonnull _LYp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2666);
}
// Invitation.JoinGroup
NSString * _Nonnull _LYq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2667);
}
// Invitation.JoinVoiceChatAsListener
NSString * _Nonnull _LYr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2668);
}
// Invitation.JoinVoiceChatAsSpeaker
NSString * _Nonnull _LYs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2669);
}
// Invitation.Members
NSString * _Nonnull _LYt(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 2670, value);
}
// Invite.ChannelsTooMuch
NSString * _Nonnull _LYu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2671);
}
// Invite.LargeRecipientsCountWarning
NSString * _Nonnull _LYv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2672);
}
// InviteLink.AdditionalLinks
NSString * _Nonnull _LYw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2673);
}
// InviteLink.ContextCopy
NSString * _Nonnull _LYx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2674);
}
// InviteLink.ContextDelete
NSString * _Nonnull _LYy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2675);
}
// InviteLink.ContextEdit
NSString * _Nonnull _LYz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2676);
}
// InviteLink.ContextGetQRCode
NSString * _Nonnull _LYA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2677);
}
// InviteLink.ContextRevoke
NSString * _Nonnull _LYB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2678);
}
// InviteLink.ContextShare
NSString * _Nonnull _LYC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2679);
}
// InviteLink.Create
NSString * _Nonnull _LYD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2680);
}
// InviteLink.Create.EditTitle
NSString * _Nonnull _LYE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2681);
}
// InviteLink.Create.LinkName
NSString * _Nonnull _LYF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2682);
}
// InviteLink.Create.LinkNameInfo
NSString * _Nonnull _LYG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2683);
}
// InviteLink.Create.LinkNameTitle
NSString * _Nonnull _LYH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2684);
}
// InviteLink.Create.RequestApproval
NSString * _Nonnull _LYI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2685);
}
// InviteLink.Create.RequestApprovalOffInfoChannel
NSString * _Nonnull _LYJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2686);
}
// InviteLink.Create.RequestApprovalOffInfoGroup
NSString * _Nonnull _LYK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2687);
}
// InviteLink.Create.RequestApprovalOnInfoChannel
NSString * _Nonnull _LYL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2688);
}
// InviteLink.Create.RequestApprovalOnInfoGroup
NSString * _Nonnull _LYM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2689);
}
// InviteLink.Create.Revoke
NSString * _Nonnull _LYN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2690);
}
// InviteLink.Create.TimeLimit
NSString * _Nonnull _LYO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2691);
}
// InviteLink.Create.TimeLimitExpiryDate
NSString * _Nonnull _LYP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2692);
}
// InviteLink.Create.TimeLimitExpiryDateNever
NSString * _Nonnull _LYQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2693);
}
// InviteLink.Create.TimeLimitExpiryTime
NSString * _Nonnull _LYR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2694);
}
// InviteLink.Create.TimeLimitInfo
NSString * _Nonnull _LYS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2695);
}
// InviteLink.Create.TimeLimitNoLimit
NSString * _Nonnull _LYT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2696);
}
// InviteLink.Create.Title
NSString * _Nonnull _LYU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2697);
}
// InviteLink.Create.UsersLimit
NSString * _Nonnull _LYV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2698);
}
// InviteLink.Create.UsersLimitInfo
NSString * _Nonnull _LYW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2699);
}
// InviteLink.Create.UsersLimitNoLimit
NSString * _Nonnull _LYX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2700);
}
// InviteLink.Create.UsersLimitNumberOfUsers
NSString * _Nonnull _LYY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2701);
}
// InviteLink.Create.UsersLimitNumberOfUsersUnlimited
NSString * _Nonnull _LYZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2702);
}
// InviteLink.CreateInfo
NSString * _Nonnull _LZa(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2703);
}
// InviteLink.CreatePrivateLinkHelp
NSString * _Nonnull _LZb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2704);
}
// InviteLink.CreatePrivateLinkHelpChannel
NSString * _Nonnull _LZc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2705);
}
// InviteLink.CreatedBy
NSString * _Nonnull _LZd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2706);
}
// InviteLink.DeleteAllRevokedLinks
NSString * _Nonnull _LZe(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2707);
}
// InviteLink.DeleteAllRevokedLinksAlert.Action
NSString * _Nonnull _LZf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2708);
}
// InviteLink.DeleteAllRevokedLinksAlert.Text
NSString * _Nonnull _LZg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2709);
}
// InviteLink.DeleteLinkAlert.Action
NSString * _Nonnull _LZh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2710);
}
// InviteLink.DeleteLinkAlert.Text
NSString * _Nonnull _LZi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2711);
}
// InviteLink.Expired
NSString * _Nonnull _LZj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2712);
}
// InviteLink.ExpiredLink
NSString * _Nonnull _LZk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2713);
}
// InviteLink.ExpiredLinkStatus
NSString * _Nonnull _LZl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2714);
}
// InviteLink.ExpiresIn
_FormattedString * _Nonnull _LZm(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2715, _0);
}
// InviteLink.InviteLink
NSString * _Nonnull _LZn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2716);
}
// InviteLink.InviteLinkCopiedText
NSString * _Nonnull _LZo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2717);
}
// InviteLink.InviteLinkForwardTooltip.Chat.One
_FormattedString * _Nonnull _LZp(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2718, _0);
}
// InviteLink.InviteLinkForwardTooltip.ManyChats.One
_FormattedString * _Nonnull _LZq(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 2719, _0, _1);
}
// InviteLink.InviteLinkForwardTooltip.SavedMessages.One
NSString * _Nonnull _LZr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2720);
}
// InviteLink.InviteLinkForwardTooltip.TwoChats.One
_FormattedString * _Nonnull _LZs(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 2721, _0, _1);
}
// InviteLink.InviteLinkRevoked
NSString * _Nonnull _LZt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2722);
}
// InviteLink.InviteLinks
NSString * _Nonnull _LZu(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 2723, value);
}
// InviteLink.Manage
NSString * _Nonnull _LZv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2724);
}
// InviteLink.OtherAdminsLinks
NSString * _Nonnull _LZw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2725);
}
// InviteLink.OtherPermanentLinkInfo
_FormattedString * _Nonnull _LZx(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 2726, _0, _1);
}
// InviteLink.PeopleCanJoin
NSString * _Nonnull _LZy(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 2727, value);
}
// InviteLink.PeopleJoined
NSString * _Nonnull _LZz(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 2728, value);
}
// InviteLink.PeopleJoinedNone
NSString * _Nonnull _LZA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2729);
}
// InviteLink.PeopleJoinedShort
NSString * _Nonnull _LZB(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 2730, value);
}
// InviteLink.PeopleJoinedShortNone
NSString * _Nonnull _LZC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2731);
}
// InviteLink.PeopleJoinedShortNoneExpired
NSString * _Nonnull _LZD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2732);
}
// InviteLink.PeopleRemaining
NSString * _Nonnull _LZE(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 2733, value);
}
// InviteLink.PermanentLink
NSString * _Nonnull _LZF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2734);
}
// InviteLink.PublicLink
NSString * _Nonnull _LZG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2735);
}
// InviteLink.QRCode.Info
NSString * _Nonnull _LZH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2736);
}
// InviteLink.QRCode.InfoChannel
NSString * _Nonnull _LZI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2737);
}
// InviteLink.QRCode.Share
NSString * _Nonnull _LZJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2738);
}
// InviteLink.QRCode.Title
NSString * _Nonnull _LZK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2739);
}
// InviteLink.ReactivateLink
NSString * _Nonnull _LZL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2740);
}
// InviteLink.Revoked
NSString * _Nonnull _LZM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2741);
}
// InviteLink.RevokedLinks
NSString * _Nonnull _LZN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2742);
}
// InviteLink.Share
NSString * _Nonnull _LZO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2743);
}
// InviteLink.Title
NSString * _Nonnull _LZP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2744);
}
// InviteLink.UsageLimitReached
NSString * _Nonnull _LZQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2745);
}
// InviteLinks.InviteLinkExpired
NSString * _Nonnull _LZR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2746);
}
// InviteText.ContactsCountText
NSString * _Nonnull _LZS(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 2747, value);
}
// InviteText.SingleContact
_FormattedString * _Nonnull _LZT(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2748, _0);
}
// InviteText.URL
NSString * _Nonnull _LZU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2749);
}
// Items.NOfM
_FormattedString * _Nonnull _LZV(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 2750, _0, _1);
}
// Join.ChannelsTooMuch
NSString * _Nonnull _LZW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2751);
}
// KeyCommand.ChatInfo
NSString * _Nonnull _LZX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2752);
}
// KeyCommand.EnterFullscreen
NSString * _Nonnull _LZY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2753);
}
// KeyCommand.ExitFullscreen
NSString * _Nonnull _LZZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2754);
}
// KeyCommand.Find
NSString * _Nonnull _Laaa(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2755);
}
// KeyCommand.FocusOnInputField
NSString * _Nonnull _Laab(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2756);
}
// KeyCommand.JumpToNextChat
NSString * _Nonnull _Laac(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2757);
}
// KeyCommand.JumpToNextUnreadChat
NSString * _Nonnull _Laad(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2758);
}
// KeyCommand.JumpToPreviousChat
NSString * _Nonnull _Laae(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2759);
}
// KeyCommand.JumpToPreviousUnreadChat
NSString * _Nonnull _Laaf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2760);
}
// KeyCommand.LockWithPasscode
NSString * _Nonnull _Laag(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2761);
}
// KeyCommand.NewMessage
NSString * _Nonnull _Laah(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2762);
}
// KeyCommand.Pause
NSString * _Nonnull _Laai(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2763);
}
// KeyCommand.Play
NSString * _Nonnull _Laaj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2764);
}
// KeyCommand.ScrollDown
NSString * _Nonnull _Laak(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2765);
}
// KeyCommand.ScrollUp
NSString * _Nonnull _Laal(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2766);
}
// KeyCommand.SearchInChat
NSString * _Nonnull _Laam(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2767);
}
// KeyCommand.SeekBackward
NSString * _Nonnull _Laan(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2768);
}
// KeyCommand.SeekForward
NSString * _Nonnull _Laao(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2769);
}
// KeyCommand.SendMessage
NSString * _Nonnull _Laap(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2770);
}
// KeyCommand.Share
NSString * _Nonnull _Laaq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2771);
}
// KeyCommand.SwitchToPIP
NSString * _Nonnull _Laar(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2772);
}
// LOCAL_CHANNEL_MESSAGE_FWDS
_FormattedString * _Nonnull _Laas(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSInteger _1) {
    return getFormatted2(_self, 2773, _0, @(_1));
}
// LOCAL_CHAT_MESSAGE_FWDS
_FormattedString * _Nonnull _Laat(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSInteger _1) {
    return getFormatted2(_self, 2774, _0, @(_1));
}
// LOCAL_MESSAGE_FWDS
_FormattedString * _Nonnull _Laau(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSInteger _1) {
    return getFormatted2(_self, 2775, _0, @(_1));
}
// LastSeen.ALongTimeAgo
NSString * _Nonnull _Laav(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2776);
}
// LastSeen.AtDate
_FormattedString * _Nonnull _Laaw(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2777, _0);
}
// LastSeen.HoursAgo
NSString * _Nonnull _Laax(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 2778, value);
}
// LastSeen.JustNow
NSString * _Nonnull _Laay(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2779);
}
// LastSeen.Lately
NSString * _Nonnull _Laaz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2780);
}
// LastSeen.MinutesAgo
NSString * _Nonnull _LaaA(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 2781, value);
}
// LastSeen.Offline
NSString * _Nonnull _LaaB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2782);
}
// LastSeen.TodayAt
_FormattedString * _Nonnull _LaaC(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2783, _0);
}
// LastSeen.WithinAMonth
NSString * _Nonnull _LaaD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2784);
}
// LastSeen.WithinAWeek
NSString * _Nonnull _LaaE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2785);
}
// LastSeen.YesterdayAt
_FormattedString * _Nonnull _LaaF(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2786, _0);
}
// LiveLocation.MenuChatsCount
NSString * _Nonnull _LaaG(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 2787, value);
}
// LiveLocation.MenuStopAll
NSString * _Nonnull _LaaH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2788);
}
// LiveLocationUpdated.JustNow
NSString * _Nonnull _LaaI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2789);
}
// LiveLocationUpdated.MinutesAgo
NSString * _Nonnull _LaaJ(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 2790, value);
}
// LiveLocationUpdated.TodayAt
_FormattedString * _Nonnull _LaaK(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2791, _0);
}
// LiveLocationUpdated.YesterdayAt
_FormattedString * _Nonnull _LaaL(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2792, _0);
}
// LiveStream.AnonymousDisabledAlertText
NSString * _Nonnull _LaaM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2793);
}
// LiveStream.CancelConfirmationText
NSString * _Nonnull _LaaN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2794);
}
// LiveStream.CancelConfirmationTitle
NSString * _Nonnull _LaaO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2795);
}
// LiveStream.ChatFullAlertText
NSString * _Nonnull _LaaP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2796);
}
// LiveStream.CreateNewVoiceChatText
NSString * _Nonnull _LaaQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2797);
}
// LiveStream.DisplayAsSuccess
_FormattedString * _Nonnull _LaaR(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2798, _0);
}
// LiveStream.EditTitle
NSString * _Nonnull _LaaS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2799);
}
// LiveStream.EditTitleRemoveSuccess
NSString * _Nonnull _LaaT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2800);
}
// LiveStream.EditTitleSuccess
_FormattedString * _Nonnull _LaaU(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2801, _0);
}
// LiveStream.EditTitleText
NSString * _Nonnull _LaaV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2802);
}
// LiveStream.EndConfirmationText
NSString * _Nonnull _LaaW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2803);
}
// LiveStream.EndConfirmationTitle
NSString * _Nonnull _LaaX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2804);
}
// LiveStream.InvitedPeerText
_FormattedString * _Nonnull _LaaY(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2805, _0);
}
// LiveStream.LeaveAndCancelVoiceChat
NSString * _Nonnull _LaaZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2806);
}
// LiveStream.LeaveAndEndVoiceChat
NSString * _Nonnull _Laba(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2807);
}
// LiveStream.LeaveConfirmation
NSString * _Nonnull _Labb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2808);
}
// LiveStream.LeaveVoiceChat
NSString * _Nonnull _Labc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2809);
}
// LiveStream.Listening.Members
NSString * _Nonnull _Labd(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 2810, value);
}
// LiveStream.NoSignalAdminText
NSString * _Nonnull _Labe(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2811);
}
// LiveStream.NoSignalUserText
_FormattedString * _Nonnull _Labf(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2812, _0);
}
// LiveStream.NoViewers
NSString * _Nonnull _Labg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2813);
}
// LiveStream.PeerJoinedText
_FormattedString * _Nonnull _Labh(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2814, _0);
}
// LiveStream.RecordTitle
NSString * _Nonnull _Labi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2815);
}
// LiveStream.RecordingInProgress
NSString * _Nonnull _Labj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2816);
}
// LiveStream.RecordingSaved
NSString * _Nonnull _Labk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2817);
}
// LiveStream.RecordingStarted
NSString * _Nonnull _Labl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2818);
}
// LiveStream.RemoveAndBanPeerConfirmation
_FormattedString * _Nonnull _Labm(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 2819, _0, _1);
}
// LiveStream.StartRecording
NSString * _Nonnull _Labn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2820);
}
// LiveStream.StartRecordingText
NSString * _Nonnull _Labo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2821);
}
// LiveStream.StartRecordingTextVideo
NSString * _Nonnull _Labp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2822);
}
// LiveStream.StartRecordingTitle
NSString * _Nonnull _Labq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2823);
}
// LiveStream.ViewCredentials
NSString * _Nonnull _Labr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2824);
}
// LiveStream.ViewerCount
NSString * _Nonnull _Labs(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 2825, value);
}
// LiveStream.Watching.Members
NSString * _Nonnull _Labt(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 2826, value);
}
// LocalGroup.ButtonTitle
NSString * _Nonnull _Labu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2827);
}
// LocalGroup.IrrelevantWarning
NSString * _Nonnull _Labv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2828);
}
// LocalGroup.Text
NSString * _Nonnull _Labw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2829);
}
// LocalGroup.Title
NSString * _Nonnull _Labx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2830);
}
// Localization.ChooseLanguage
NSString * _Nonnull _Laby(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2831);
}
// Localization.DoNotTranslate
NSString * _Nonnull _Labz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2832);
}
// Localization.DoNotTranslateInfo
NSString * _Nonnull _LabA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2833);
}
// Localization.DoNotTranslateManyInfo
NSString * _Nonnull _LabB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2834);
}
// Localization.EnglishLanguageName
NSString * _Nonnull _LabC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2835);
}
// Localization.InterfaceLanguage
NSString * _Nonnull _LabD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2836);
}
// Localization.LanguageCustom
NSString * _Nonnull _LabE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2837);
}
// Localization.LanguageName
NSString * _Nonnull _LabF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2838);
}
// Localization.LanguageOther
NSString * _Nonnull _LabG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2839);
}
// Localization.ShowTranslate
NSString * _Nonnull _LabH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2840);
}
// Localization.ShowTranslateInfo
NSString * _Nonnull _LabI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2841);
}
// Localization.ShowTranslateInfoExtended
NSString * _Nonnull _LabJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2842);
}
// Localization.TranslateEntireChat
NSString * _Nonnull _LabK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2843);
}
// Localization.TranslateMessages
NSString * _Nonnull _LabL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2844);
}
// Location.LiveLocationRequired.Description
NSString * _Nonnull _LabM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2845);
}
// Location.LiveLocationRequired.ShareLocation
NSString * _Nonnull _LabN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2846);
}
// Location.LiveLocationRequired.Title
NSString * _Nonnull _LabO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2847);
}
// Location.ProximityAlertCancelled
NSString * _Nonnull _LabP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2848);
}
// Location.ProximityAlertSetText
_FormattedString * _Nonnull _LabQ(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 2849, _0, _1);
}
// Location.ProximityAlertSetTextGroup
_FormattedString * _Nonnull _LabR(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2850, _0);
}
// Location.ProximityAlertSetTitle
NSString * _Nonnull _LabS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2851);
}
// Location.ProximityGroupTip
NSString * _Nonnull _LabT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2852);
}
// Location.ProximityNotification.AlreadyClose
_FormattedString * _Nonnull _LabU(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2853, _0);
}
// Location.ProximityNotification.DistanceKM
NSString * _Nonnull _LabV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2854);
}
// Location.ProximityNotification.DistanceM
NSString * _Nonnull _LabW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2855);
}
// Location.ProximityNotification.DistanceMI
NSString * _Nonnull _LabX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2856);
}
// Location.ProximityNotification.Notify
_FormattedString * _Nonnull _LabY(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2857, _0);
}
// Location.ProximityNotification.NotifyLong
_FormattedString * _Nonnull _LabZ(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 2858, _0, _1);
}
// Location.ProximityNotification.Title
NSString * _Nonnull _Laca(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2859);
}
// Location.ProximityTip
_FormattedString * _Nonnull _Lacb(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2860, _0);
}
// Login.AddEmailPlaceholder
NSString * _Nonnull _Lacc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2861);
}
// Login.AddEmailText
NSString * _Nonnull _Lacd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2862);
}
// Login.AddEmailTitle
NSString * _Nonnull _Lace(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2863);
}
// Login.AnonymousNumbers
NSString * _Nonnull _Lacf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2864);
}
// Login.BannedPhoneBody
_FormattedString * _Nonnull _Lacg(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2865, _0);
}
// Login.BannedPhoneSubject
_FormattedString * _Nonnull _Lach(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2866, _0);
}
// Login.CallRequestState2
NSString * _Nonnull _Laci(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2867);
}
// Login.CallRequestState3
NSString * _Nonnull _Lacj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2868);
}
// Login.CancelEmailVerification
NSString * _Nonnull _Lack(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2869);
}
// Login.CancelEmailVerificationContinue
NSString * _Nonnull _Lacl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2870);
}
// Login.CancelEmailVerificationStop
NSString * _Nonnull _Lacm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2871);
}
// Login.CancelPhoneVerification
NSString * _Nonnull _Lacn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2872);
}
// Login.CancelPhoneVerificationContinue
NSString * _Nonnull _Laco(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2873);
}
// Login.CancelPhoneVerificationStop
NSString * _Nonnull _Lacp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2874);
}
// Login.CancelSignUpConfirmation
NSString * _Nonnull _Lacq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2875);
}
// Login.CheckOtherSessionMessages
NSString * _Nonnull _Lacr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2876);
}
// Login.Code
NSString * _Nonnull _Lacs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2877);
}
// Login.CodeExpired
NSString * _Nonnull _Lact(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2878);
}
// Login.CodeExpiredError
NSString * _Nonnull _Lacu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2879);
}
// Login.CodeFloodError
NSString * _Nonnull _Lacv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2880);
}
// Login.CodePhonePatternInfoText
NSString * _Nonnull _Lacw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2881);
}
// Login.CodeSentCall
NSString * _Nonnull _Lacx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2882);
}
// Login.CodeSentCallText
_FormattedString * _Nonnull _Lacy(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2883, _0);
}
// Login.CodeSentInternal
NSString * _Nonnull _Lacz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2884);
}
// Login.CodeSentSms
NSString * _Nonnull _LacA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2885);
}
// Login.Continue
NSString * _Nonnull _LacB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2886);
}
// Login.ContinueWithLocalization
NSString * _Nonnull _LacC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2887);
}
// Login.CountryCode
NSString * _Nonnull _LacD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2888);
}
// Login.Edit
NSString * _Nonnull _LacE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2889);
}
// Login.EmailChanged
NSString * _Nonnull _LacF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2890);
}
// Login.EmailCodeBody
_FormattedString * _Nonnull _LacG(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2891, _0);
}
// Login.EmailCodeSubject
_FormattedString * _Nonnull _LacH(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2892, _0);
}
// Login.EmailNotAllowedError
NSString * _Nonnull _LacI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2893);
}
// Login.EmailNotConfiguredError
NSString * _Nonnull _LacJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2894);
}
// Login.EmailPhoneBody
_FormattedString * _Nonnull _LacK(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2) {
    return getFormatted3(_self, 2895, _0, _1, _2);
}
// Login.EmailPhoneSubject
_FormattedString * _Nonnull _LacL(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2896, _0);
}
// Login.EnterCodeEmailText
_FormattedString * _Nonnull _LacM(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2897, _0);
}
// Login.EnterCodeEmailTitle
NSString * _Nonnull _LacN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2898);
}
// Login.EnterCodeFragmentText
_FormattedString * _Nonnull _LacO(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2899, _0);
}
// Login.EnterCodeFragmentTitle
NSString * _Nonnull _LacP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2900);
}
// Login.EnterCodeNewEmailText
_FormattedString * _Nonnull _LacQ(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2901, _0);
}
// Login.EnterCodeNewEmailTitle
NSString * _Nonnull _LacR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2902);
}
// Login.EnterCodeSMSText
_FormattedString * _Nonnull _LacS(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2903, _0);
}
// Login.EnterCodeSMSTitle
NSString * _Nonnull _LacT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2904);
}
// Login.EnterCodeTelegramText
_FormattedString * _Nonnull _LacU(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2905, _0);
}
// Login.EnterCodeTelegramTitle
NSString * _Nonnull _LacV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2906);
}
// Login.EnterMissingDigits
NSString * _Nonnull _LacW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2907);
}
// Login.EnterNewEmailTitle
NSString * _Nonnull _LacX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2908);
}
// Login.HaveNotReceivedCodeInternal
NSString * _Nonnull _LacY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2909);
}
// Login.InfoAvatarAdd
NSString * _Nonnull _LacZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2910);
}
// Login.InfoAvatarPhoto
NSString * _Nonnull _Lada(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2911);
}
// Login.InfoDeletePhoto
NSString * _Nonnull _Ladb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2912);
}
// Login.InfoFirstNamePlaceholder
NSString * _Nonnull _Ladc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2913);
}
// Login.InfoHelp
NSString * _Nonnull _Ladd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2914);
}
// Login.InfoLastNamePlaceholder
NSString * _Nonnull _Lade(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2915);
}
// Login.InfoTitle
NSString * _Nonnull _Ladf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2916);
}
// Login.InvalidCodeError
NSString * _Nonnull _Ladg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2917);
}
// Login.InvalidCountryCode
NSString * _Nonnull _Ladh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2918);
}
// Login.InvalidEmailAddressError
NSString * _Nonnull _Ladi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2919);
}
// Login.InvalidEmailError
NSString * _Nonnull _Ladj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2920);
}
// Login.InvalidEmailTokenError
NSString * _Nonnull _Ladk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2921);
}
// Login.InvalidFirstNameError
NSString * _Nonnull _Ladl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2922);
}
// Login.InvalidLastNameError
NSString * _Nonnull _Ladm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2923);
}
// Login.InvalidPhoneEmailBody
_FormattedString * _Nonnull _Ladn(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2, NSString * _Nonnull _3, NSString * _Nonnull _4) {
    return getFormatted5(_self, 2924, _0, _1, _2, _3, _4);
}
// Login.InvalidPhoneEmailSubject
_FormattedString * _Nonnull _Lado(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2925, _0);
}
// Login.InvalidPhoneError
NSString * _Nonnull _Ladp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2926);
}
// Login.NetworkError
NSString * _Nonnull _Ladq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2927);
}
// Login.NewNumber
NSString * _Nonnull _Ladr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2928);
}
// Login.OpenFragment
NSString * _Nonnull _Lads(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2929);
}
// Login.Or
NSString * _Nonnull _Ladt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2930);
}
// Login.PadPhoneHelp
NSString * _Nonnull _Ladu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2931);
}
// Login.PadPhoneHelpTitle
NSString * _Nonnull _Ladv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2932);
}
// Login.PhoneAndCountryHelp
NSString * _Nonnull _Ladw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2933);
}
// Login.PhoneBannedEmailBody
_FormattedString * _Nonnull _Ladx(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2, NSString * _Nonnull _3, NSString * _Nonnull _4) {
    return getFormatted5(_self, 2934, _0, _1, _2, _3, _4);
}
// Login.PhoneBannedEmailSubject
_FormattedString * _Nonnull _Lady(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2935, _0);
}
// Login.PhoneBannedError
NSString * _Nonnull _Ladz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2936);
}
// Login.PhoneFloodError
NSString * _Nonnull _LadA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2937);
}
// Login.PhoneGenericEmailBody
_FormattedString * _Nonnull _LadB(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2, NSString * _Nonnull _3, NSString * _Nonnull _4, NSString * _Nonnull _5) {
    return getFormatted6(_self, 2938, _0, _1, _2, _3, _4, _5);
}
// Login.PhoneGenericEmailSubject
_FormattedString * _Nonnull _LadC(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2939, _0);
}
// Login.PhoneNumberAlreadyAuthorized
NSString * _Nonnull _LadD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2940);
}
// Login.PhoneNumberAlreadyAuthorizedSwitch
NSString * _Nonnull _LadE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2941);
}
// Login.PhoneNumberConfirmation
NSString * _Nonnull _LadF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2942);
}
// Login.PhoneNumberHelp
NSString * _Nonnull _LadG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2943);
}
// Login.PhonePlaceholder
NSString * _Nonnull _LadH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2944);
}
// Login.PhoneTitle
NSString * _Nonnull _LadI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2945);
}
// Login.ResetAccountProtected.LimitExceeded
NSString * _Nonnull _LadJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2946);
}
// Login.ResetAccountProtected.Reset
NSString * _Nonnull _LadK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2947);
}
// Login.ResetAccountProtected.Text
_FormattedString * _Nonnull _LadL(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2948, _0);
}
// Login.ResetAccountProtected.TimerTitle
NSString * _Nonnull _LadM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2949);
}
// Login.ResetAccountProtected.Title
NSString * _Nonnull _LadN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2950);
}
// Login.SelectCountry
NSString * _Nonnull _LadO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2951);
}
// Login.SelectCountry.Title
NSString * _Nonnull _LadP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2952);
}
// Login.SendCodeAsSMS
NSString * _Nonnull _LadQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2953);
}
// Login.SendCodeViaCall
NSString * _Nonnull _LadR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2954);
}
// Login.SendCodeViaFlashCall
NSString * _Nonnull _LadS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2955);
}
// Login.SendCodeViaSms
NSString * _Nonnull _LadT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2956);
}
// Login.ShortCallTitle
NSString * _Nonnull _LadU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2957);
}
// Login.SmsRequestState2
NSString * _Nonnull _LadV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2958);
}
// Login.SmsRequestState3
NSString * _Nonnull _LadW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2959);
}
// Login.TermsOfService.ProceedBot
_FormattedString * _Nonnull _LadX(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2960, _0);
}
// Login.TermsOfServiceAgree
NSString * _Nonnull _LadY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2961);
}
// Login.TermsOfServiceDecline
NSString * _Nonnull _LadZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2962);
}
// Login.TermsOfServiceHeader
NSString * _Nonnull _Laea(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2963);
}
// Login.TermsOfServiceLabel
NSString * _Nonnull _Laeb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2964);
}
// Login.TermsOfServiceSignupDecline
NSString * _Nonnull _Laec(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2965);
}
// Login.UnknownError
NSString * _Nonnull _Laed(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2966);
}
// Login.VoiceOver.Password
NSString * _Nonnull _Laee(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2967);
}
// Login.VoiceOver.PhoneCountryCode
NSString * _Nonnull _Laef(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2968);
}
// Login.VoiceOver.PhoneNumber
NSString * _Nonnull _Laeg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2969);
}
// Login.WillCallYou
_FormattedString * _Nonnull _Laeh(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2970, _0);
}
// Login.WillSendSms
_FormattedString * _Nonnull _Laei(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2971, _0);
}
// Login.WrongCodeError
NSString * _Nonnull _Laej(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2972);
}
// Login.Yes
NSString * _Nonnull _Laek(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2973);
}
// LoginPassword.FloodError
NSString * _Nonnull _Lael(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2974);
}
// LoginPassword.ForgotPassword
NSString * _Nonnull _Laem(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2975);
}
// LoginPassword.InvalidPasswordError
NSString * _Nonnull _Laen(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2976);
}
// LoginPassword.PasswordHelp
NSString * _Nonnull _Laeo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2977);
}
// LoginPassword.PasswordPlaceholder
NSString * _Nonnull _Laep(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2978);
}
// LoginPassword.ResetAccount
NSString * _Nonnull _Laeq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2979);
}
// LoginPassword.Title
NSString * _Nonnull _Laer(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2980);
}
// LogoutOptions.AddAccountText
NSString * _Nonnull _Laes(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2981);
}
// LogoutOptions.AddAccountTitle
NSString * _Nonnull _Laet(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2982);
}
// LogoutOptions.AlternativeOptionsSection
NSString * _Nonnull _Laeu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2983);
}
// LogoutOptions.ChangePhoneNumberText
NSString * _Nonnull _Laev(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2984);
}
// LogoutOptions.ChangePhoneNumberTitle
NSString * _Nonnull _Laew(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2985);
}
// LogoutOptions.ClearCacheText
NSString * _Nonnull _Laex(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2986);
}
// LogoutOptions.ClearCacheTitle
NSString * _Nonnull _Laey(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2987);
}
// LogoutOptions.ContactSupportText
NSString * _Nonnull _Laez(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2988);
}
// LogoutOptions.ContactSupportTitle
NSString * _Nonnull _LaeA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2989);
}
// LogoutOptions.LogOut
NSString * _Nonnull _LaeB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2990);
}
// LogoutOptions.LogOutInfo
NSString * _Nonnull _LaeC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2991);
}
// LogoutOptions.SetPasscodeText
NSString * _Nonnull _LaeD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2992);
}
// LogoutOptions.SetPasscodeTitle
NSString * _Nonnull _LaeE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2993);
}
// LogoutOptions.Title
NSString * _Nonnull _LaeF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2994);
}
// MESSAGE_INVOICE
_FormattedString * _Nonnull _LaeG(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 2995, _0, _1);
}
// MESSAGE_NOTHEME
_FormattedString * _Nonnull _LaeH(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2996, _0);
}
// Map.AccurateTo
_FormattedString * _Nonnull _LaeI(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 2997, _0);
}
// Map.AddressOnMap
NSString * _Nonnull _LaeJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2998);
}
// Map.ChooseAPlace
NSString * _Nonnull _LaeK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 2999);
}
// Map.ChooseLocationTitle
NSString * _Nonnull _LaeL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3000);
}
// Map.Directions
NSString * _Nonnull _LaeM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3001);
}
// Map.DirectionsDriveEta
_FormattedString * _Nonnull _LaeN(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3002, _0);
}
// Map.DistanceAway
_FormattedString * _Nonnull _LaeO(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3003, _0);
}
// Map.ETADays
NSString * _Nonnull _LaeP(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3004, value);
}
// Map.ETAHours
NSString * _Nonnull _LaeQ(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3005, value);
}
// Map.ETAMinutes
NSString * _Nonnull _LaeR(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3006, value);
}
// Map.GetDirections
NSString * _Nonnull _LaeS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3007);
}
// Map.Home
NSString * _Nonnull _LaeT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3008);
}
// Map.HomeAndWorkInfo
NSString * _Nonnull _LaeU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3009);
}
// Map.HomeAndWorkTitle
NSString * _Nonnull _LaeV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3010);
}
// Map.Hybrid
NSString * _Nonnull _LaeW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3011);
}
// Map.LiveLocationFor15Minutes
NSString * _Nonnull _LaeX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3012);
}
// Map.LiveLocationFor1Hour
NSString * _Nonnull _LaeY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3013);
}
// Map.LiveLocationFor8Hours
NSString * _Nonnull _LaeZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3014);
}
// Map.LiveLocationGroupDescription
NSString * _Nonnull _Lafa(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3015);
}
// Map.LiveLocationPrivateDescription
_FormattedString * _Nonnull _Lafb(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3016, _0);
}
// Map.LiveLocationShortHour
_FormattedString * _Nonnull _Lafc(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3017, _0);
}
// Map.LiveLocationShowAll
NSString * _Nonnull _Lafd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3018);
}
// Map.LiveLocationTitle
NSString * _Nonnull _Lafe(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3019);
}
// Map.LoadError
NSString * _Nonnull _Laff(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3020);
}
// Map.Locating
NSString * _Nonnull _Lafg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3021);
}
// Map.LocatingError
NSString * _Nonnull _Lafh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3022);
}
// Map.Location
NSString * _Nonnull _Lafi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3023);
}
// Map.LocationTitle
NSString * _Nonnull _Lafj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3024);
}
// Map.Map
NSString * _Nonnull _Lafk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3025);
}
// Map.NoPlacesNearby
NSString * _Nonnull _Lafl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3026);
}
// Map.OpenIn
NSString * _Nonnull _Lafm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3027);
}
// Map.OpenInGoogleMaps
NSString * _Nonnull _Lafn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3028);
}
// Map.OpenInHereMaps
NSString * _Nonnull _Lafo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3029);
}
// Map.OpenInMaps
NSString * _Nonnull _Lafp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3030);
}
// Map.OpenInWaze
NSString * _Nonnull _Lafq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3031);
}
// Map.OpenInYandexMaps
NSString * _Nonnull _Lafr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3032);
}
// Map.OpenInYandexNavigator
NSString * _Nonnull _Lafs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3033);
}
// Map.PlacesInThisArea
NSString * _Nonnull _Laft(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3034);
}
// Map.PlacesNearby
NSString * _Nonnull _Lafu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3035);
}
// Map.PullUpForPlaces
NSString * _Nonnull _Lafv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3036);
}
// Map.Satellite
NSString * _Nonnull _Lafw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3037);
}
// Map.Search
NSString * _Nonnull _Lafx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3038);
}
// Map.SearchNoResultsDescription
_FormattedString * _Nonnull _Lafy(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3039, _0);
}
// Map.SendMyCurrentLocation
NSString * _Nonnull _Lafz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3040);
}
// Map.SendThisLocation
NSString * _Nonnull _LafA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3041);
}
// Map.SendThisPlace
NSString * _Nonnull _LafB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3042);
}
// Map.SetThisLocation
NSString * _Nonnull _LafC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3043);
}
// Map.SetThisPlace
NSString * _Nonnull _LafD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3044);
}
// Map.ShareLiveLocation
NSString * _Nonnull _LafE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3045);
}
// Map.ShareLiveLocationHelp
NSString * _Nonnull _LafF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3046);
}
// Map.ShowPlaces
NSString * _Nonnull _LafG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3047);
}
// Map.StopLiveLocation
NSString * _Nonnull _LafH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3048);
}
// Map.Unknown
NSString * _Nonnull _LafI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3049);
}
// Map.Work
NSString * _Nonnull _LafJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3050);
}
// Map.YouAreHere
NSString * _Nonnull _LafK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3051);
}
// MaskPackActionInfo.ArchivedTitle
NSString * _Nonnull _LafL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3052);
}
// MaskPackActionInfo.RemovedText
_FormattedString * _Nonnull _LafM(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3053, _0);
}
// MaskPackActionInfo.RemovedTitle
NSString * _Nonnull _LafN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3054);
}
// MaskStickerSettings.Info
NSString * _Nonnull _LafO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3055);
}
// MaskStickerSettings.Title
NSString * _Nonnull _LafP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3056);
}
// Media.LimitedAccessChangeSettings
NSString * _Nonnull _LafQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3057);
}
// Media.LimitedAccessManage
NSString * _Nonnull _LafR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3058);
}
// Media.LimitedAccessSelectMore
NSString * _Nonnull _LafS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3059);
}
// Media.LimitedAccessText
NSString * _Nonnull _LafT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3060);
}
// Media.LimitedAccessTitle
NSString * _Nonnull _LafU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3061);
}
// Media.SendWithTimer
NSString * _Nonnull _LafV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3062);
}
// Media.SendingOptionsTooltip
NSString * _Nonnull _LafW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3063);
}
// Media.ShareItem
NSString * _Nonnull _LafX(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3064, value);
}
// Media.SharePhoto
NSString * _Nonnull _LafY(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3065, value);
}
// Media.ShareThisPhoto
NSString * _Nonnull _LafZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3066);
}
// Media.ShareThisVideo
NSString * _Nonnull _Laga(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3067);
}
// Media.ShareVideo
NSString * _Nonnull _Lagb(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3068, value);
}
// MediaPicker.AddCaption
NSString * _Nonnull _Lagc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3069);
}
// MediaPicker.CameraRoll
NSString * _Nonnull _Lagd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3070);
}
// MediaPicker.ConvertToJpeg
NSString * _Nonnull _Lage(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3071);
}
// MediaPicker.GroupDescription
NSString * _Nonnull _Lagf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3072);
}
// MediaPicker.JpegConversionText
NSString * _Nonnull _Lagg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3073);
}
// MediaPicker.KeepHeic
NSString * _Nonnull _Lagh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3074);
}
// MediaPicker.LivePhotoDescription
NSString * _Nonnull _Lagi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3075);
}
// MediaPicker.MomentsDateRangeSameMonthYearFormat
NSString * _Nonnull _Lagj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3076);
}
// MediaPicker.Nof
_FormattedString * _Nonnull _Lagk(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3077, _0);
}
// MediaPicker.Send
NSString * _Nonnull _Lagl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3078);
}
// MediaPicker.TapToUngroupDescription
NSString * _Nonnull _Lagm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3079);
}
// MediaPicker.TimerTooltip
NSString * _Nonnull _Lagn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3080);
}
// MediaPicker.UngroupDescription
NSString * _Nonnull _Lago(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3081);
}
// MediaPicker.VideoMuteDescription
NSString * _Nonnull _Lagp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3082);
}
// MediaPicker.Videos
NSString * _Nonnull _Lagq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3083);
}
// MediaPlayer.UnknownArtist
NSString * _Nonnull _Lagr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3084);
}
// MediaPlayer.UnknownTrack
NSString * _Nonnull _Lags(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3085);
}
// MemberRequests.AddToChannel
NSString * _Nonnull _Lagt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3086);
}
// MemberRequests.AddToGroup
NSString * _Nonnull _Lagu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3087);
}
// MemberRequests.DescriptionChannel
NSString * _Nonnull _Lagv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3088);
}
// MemberRequests.DescriptionGroup
NSString * _Nonnull _Lagw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3089);
}
// MemberRequests.Dismiss
NSString * _Nonnull _Lagx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3090);
}
// MemberRequests.NoRequests
NSString * _Nonnull _Lagy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3091);
}
// MemberRequests.NoRequestsDescriptionChannel
NSString * _Nonnull _Lagz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3092);
}
// MemberRequests.NoRequestsDescriptionGroup
NSString * _Nonnull _LagA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3093);
}
// MemberRequests.PeopleRequested
NSString * _Nonnull _LagB(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3094, value);
}
// MemberRequests.PeopleRequestedShort
NSString * _Nonnull _LagC(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3095, value);
}
// MemberRequests.RequestToJoinChannel
NSString * _Nonnull _LagD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3096);
}
// MemberRequests.RequestToJoinDescriptionChannel
NSString * _Nonnull _LagE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3097);
}
// MemberRequests.RequestToJoinDescriptionGroup
NSString * _Nonnull _LagF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3098);
}
// MemberRequests.RequestToJoinGroup
NSString * _Nonnull _LagG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3099);
}
// MemberRequests.RequestToJoinSent
NSString * _Nonnull _LagH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3100);
}
// MemberRequests.RequestToJoinSentDescriptionChannel
NSString * _Nonnull _LagI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3101);
}
// MemberRequests.RequestToJoinSentDescriptionGroup
NSString * _Nonnull _LagJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3102);
}
// MemberRequests.SearchPlaceholder
NSString * _Nonnull _LagK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3103);
}
// MemberRequests.Title
NSString * _Nonnull _LagL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3104);
}
// MemberRequests.UserAddedToChannel
_FormattedString * _Nonnull _LagM(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3105, _0);
}
// MemberRequests.UserAddedToGroup
_FormattedString * _Nonnull _LagN(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3106, _0);
}
// MemberSearch.BotSection
NSString * _Nonnull _LagO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3107);
}
// Message.Animation
NSString * _Nonnull _LagP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3108);
}
// Message.Audio
NSString * _Nonnull _LagQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3109);
}
// Message.AudioTranscription.ErrorEmpty
NSString * _Nonnull _LagR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3110);
}
// Message.AudioTranscription.ErrorTooLong
NSString * _Nonnull _LagS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3111);
}
// Message.AudioTranscription.SubscribeToPremium
NSString * _Nonnull _LagT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3112);
}
// Message.AudioTranscription.SubscribeToPremiumAction
NSString * _Nonnull _LagU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3113);
}
// Message.AuthorPinnedGame
_FormattedString * _Nonnull _LagV(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3114, _0);
}
// Message.Contact
NSString * _Nonnull _LagW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3115);
}
// Message.FakeAccount
NSString * _Nonnull _LagX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3116);
}
// Message.File
NSString * _Nonnull _LagY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3117);
}
// Message.ForwardedMessage
_FormattedString * _Nonnull _LagZ(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3118, _0);
}
// Message.ForwardedMessageShort
_FormattedString * _Nonnull _Laha(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3119, _0);
}
// Message.ForwardedPsa.covid
_FormattedString * _Nonnull _Lahb(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3120, _0);
}
// Message.Game
NSString * _Nonnull _Lahc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3121);
}
// Message.GenericForwardedPsa
_FormattedString * _Nonnull _Lahd(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3122, _0);
}
// Message.ImageExpired
NSString * _Nonnull _Lahe(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3123);
}
// Message.ImportedDateFormat
_FormattedString * _Nonnull _Lahf(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2) {
    return getFormatted3(_self, 3124, _0, _1, _2);
}
// Message.InvoiceLabel
NSString * _Nonnull _Lahg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3125);
}
// Message.LiveLocation
NSString * _Nonnull _Lahh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3126);
}
// Message.Location
NSString * _Nonnull _Lahi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3127);
}
// Message.PaymentSent
_FormattedString * _Nonnull _Lahj(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3128, _0);
}
// Message.Photo
NSString * _Nonnull _Lahk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3129);
}
// Message.PinnedAnimationMessage
NSString * _Nonnull _Lahl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3130);
}
// Message.PinnedAudioMessage
NSString * _Nonnull _Lahm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3131);
}
// Message.PinnedContactMessage
NSString * _Nonnull _Lahn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3132);
}
// Message.PinnedDocumentMessage
NSString * _Nonnull _Laho(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3133);
}
// Message.PinnedGame
NSString * _Nonnull _Lahp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3134);
}
// Message.PinnedGenericMessage
_FormattedString * _Nonnull _Lahq(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3135, _0);
}
// Message.PinnedInvoice
NSString * _Nonnull _Lahr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3136);
}
// Message.PinnedLiveLocationMessage
NSString * _Nonnull _Lahs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3137);
}
// Message.PinnedLocationMessage
NSString * _Nonnull _Laht(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3138);
}
// Message.PinnedPhotoMessage
NSString * _Nonnull _Lahu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3139);
}
// Message.PinnedStickerMessage
NSString * _Nonnull _Lahv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3140);
}
// Message.PinnedTextMessage
_FormattedString * _Nonnull _Lahw(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3141, _0);
}
// Message.PinnedVideoMessage
NSString * _Nonnull _Lahx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3142);
}
// Message.RecommendedLabel
NSString * _Nonnull _Lahy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3143);
}
// Message.ReplyActionButtonShowReceipt
NSString * _Nonnull _Lahz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3144);
}
// Message.ScamAccount
NSString * _Nonnull _LahA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3145);
}
// Message.SponsoredLabel
NSString * _Nonnull _LahB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3146);
}
// Message.Sticker
NSString * _Nonnull _LahC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3147);
}
// Message.StickerText
_FormattedString * _Nonnull _LahD(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3148, _0);
}
// Message.Theme
NSString * _Nonnull _LahE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3149);
}
// Message.Video
NSString * _Nonnull _LahF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3150);
}
// Message.VideoExpired
NSString * _Nonnull _LahG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3151);
}
// Message.VideoMessage
NSString * _Nonnull _LahH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3152);
}
// Message.Wallpaper
NSString * _Nonnull _LahI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3153);
}
// MessageCalendar.ClearHistoryForTheseDays
NSString * _Nonnull _LahJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3154);
}
// MessageCalendar.ClearHistoryForThisDay
NSString * _Nonnull _LahK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3155);
}
// MessageCalendar.DaysSelectedTitle
NSString * _Nonnull _LahL(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3156, value);
}
// MessageCalendar.DeleteAlertText
NSString * _Nonnull _LahM(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3157, value);
}
// MessageCalendar.EmptySelectionTooltip
NSString * _Nonnull _LahN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3158);
}
// MessageCalendar.Title
NSString * _Nonnull _LahO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3159);
}
// MessagePoll.LabelAnonymous
NSString * _Nonnull _LahP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3160);
}
// MessagePoll.LabelAnonymousQuiz
NSString * _Nonnull _LahQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3161);
}
// MessagePoll.LabelClosed
NSString * _Nonnull _LahR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3162);
}
// MessagePoll.LabelPoll
NSString * _Nonnull _LahS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3163);
}
// MessagePoll.LabelQuiz
NSString * _Nonnull _LahT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3164);
}
// MessagePoll.NoVotes
NSString * _Nonnull _LahU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3165);
}
// MessagePoll.QuizCount
NSString * _Nonnull _LahV(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3166, value);
}
// MessagePoll.QuizNoUsers
NSString * _Nonnull _LahW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3167);
}
// MessagePoll.SubmitVote
NSString * _Nonnull _LahX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3168);
}
// MessagePoll.ViewResults
NSString * _Nonnull _LahY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3169);
}
// MessagePoll.VotedCount
NSString * _Nonnull _LahZ(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3170, value);
}
// MessageTimer.Custom
NSString * _Nonnull _Laia(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3171);
}
// MessageTimer.Days
NSString * _Nonnull _Laib(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3172, value);
}
// MessageTimer.Forever
NSString * _Nonnull _Laic(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3173);
}
// MessageTimer.Hours
NSString * _Nonnull _Laid(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3174, value);
}
// MessageTimer.LargeShortDays
NSString * _Nonnull _Laie(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3175, value);
}
// MessageTimer.LargeShortHours
NSString * _Nonnull _Laif(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3176, value);
}
// MessageTimer.LargeShortMinutes
NSString * _Nonnull _Laig(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3177, value);
}
// MessageTimer.LargeShortMonths
NSString * _Nonnull _Laih(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3178, value);
}
// MessageTimer.LargeShortSeconds
NSString * _Nonnull _Laii(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3179, value);
}
// MessageTimer.LargeShortWeeks
NSString * _Nonnull _Laij(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3180, value);
}
// MessageTimer.LargeShortYears
NSString * _Nonnull _Laik(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3181, value);
}
// MessageTimer.Minutes
NSString * _Nonnull _Lail(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3182, value);
}
// MessageTimer.Months
NSString * _Nonnull _Laim(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3183, value);
}
// MessageTimer.Seconds
NSString * _Nonnull _Lain(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3184, value);
}
// MessageTimer.ShortDays
NSString * _Nonnull _Laio(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3185, value);
}
// MessageTimer.ShortHours
NSString * _Nonnull _Laip(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3186, value);
}
// MessageTimer.ShortMinutes
NSString * _Nonnull _Laiq(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3187, value);
}
// MessageTimer.ShortMonths
NSString * _Nonnull _Lair(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3188, value);
}
// MessageTimer.ShortSeconds
NSString * _Nonnull _Lais(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3189, value);
}
// MessageTimer.ShortWeeks
NSString * _Nonnull _Lait(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3190, value);
}
// MessageTimer.ShortYears
NSString * _Nonnull _Laiu(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3191, value);
}
// MessageTimer.Weeks
NSString * _Nonnull _Laiv(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3192, value);
}
// MessageTimer.Years
NSString * _Nonnull _Laiw(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3193, value);
}
// Month.GenApril
NSString * _Nonnull _Laix(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3194);
}
// Month.GenAugust
NSString * _Nonnull _Laiy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3195);
}
// Month.GenDecember
NSString * _Nonnull _Laiz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3196);
}
// Month.GenFebruary
NSString * _Nonnull _LaiA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3197);
}
// Month.GenJanuary
NSString * _Nonnull _LaiB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3198);
}
// Month.GenJuly
NSString * _Nonnull _LaiC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3199);
}
// Month.GenJune
NSString * _Nonnull _LaiD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3200);
}
// Month.GenMarch
NSString * _Nonnull _LaiE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3201);
}
// Month.GenMay
NSString * _Nonnull _LaiF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3202);
}
// Month.GenNovember
NSString * _Nonnull _LaiG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3203);
}
// Month.GenOctober
NSString * _Nonnull _LaiH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3204);
}
// Month.GenSeptember
NSString * _Nonnull _LaiI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3205);
}
// Month.ShortApril
NSString * _Nonnull _LaiJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3206);
}
// Month.ShortAugust
NSString * _Nonnull _LaiK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3207);
}
// Month.ShortDecember
NSString * _Nonnull _LaiL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3208);
}
// Month.ShortFebruary
NSString * _Nonnull _LaiM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3209);
}
// Month.ShortJanuary
NSString * _Nonnull _LaiN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3210);
}
// Month.ShortJuly
NSString * _Nonnull _LaiO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3211);
}
// Month.ShortJune
NSString * _Nonnull _LaiP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3212);
}
// Month.ShortMarch
NSString * _Nonnull _LaiQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3213);
}
// Month.ShortMay
NSString * _Nonnull _LaiR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3214);
}
// Month.ShortNovember
NSString * _Nonnull _LaiS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3215);
}
// Month.ShortOctober
NSString * _Nonnull _LaiT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3216);
}
// Month.ShortSeptember
NSString * _Nonnull _LaiU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3217);
}
// MusicPlayer.VoiceNote
NSString * _Nonnull _LaiV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3218);
}
// MuteExpires.Days
NSString * _Nonnull _LaiW(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3219, value);
}
// MuteExpires.Hours
NSString * _Nonnull _LaiX(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3220, value);
}
// MuteExpires.Minutes
NSString * _Nonnull _LaiY(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3221, value);
}
// MuteFor.Days
NSString * _Nonnull _LaiZ(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3222, value);
}
// MuteFor.Forever
NSString * _Nonnull _Laja(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3223);
}
// MuteFor.Hours
NSString * _Nonnull _Lajb(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3224, value);
}
// MuteFor.Minutes
NSString * _Nonnull _Lajc(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3225, value);
}
// MutedForTime.Days
NSString * _Nonnull _Lajd(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3226, value);
}
// MutedForTime.Hours
NSString * _Nonnull _Laje(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3227, value);
}
// MutedForTime.Minutes
NSString * _Nonnull _Lajf(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3228, value);
}
// Navigation.AllChats
NSString * _Nonnull _Lajg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3229);
}
// NetworkUsageSettings.BytesReceived
NSString * _Nonnull _Lajh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3230);
}
// NetworkUsageSettings.BytesSent
NSString * _Nonnull _Laji(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3231);
}
// NetworkUsageSettings.CallDataSection
NSString * _Nonnull _Lajj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3232);
}
// NetworkUsageSettings.Cellular
NSString * _Nonnull _Lajk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3233);
}
// NetworkUsageSettings.CellularUsageSince
_FormattedString * _Nonnull _Lajl(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3234, _0);
}
// NetworkUsageSettings.GeneralDataSection
NSString * _Nonnull _Lajm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3235);
}
// NetworkUsageSettings.MediaAudioDataSection
NSString * _Nonnull _Lajn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3236);
}
// NetworkUsageSettings.MediaDocumentDataSection
NSString * _Nonnull _Lajo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3237);
}
// NetworkUsageSettings.MediaImageDataSection
NSString * _Nonnull _Lajp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3238);
}
// NetworkUsageSettings.MediaVideoDataSection
NSString * _Nonnull _Lajq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3239);
}
// NetworkUsageSettings.ResetStats
NSString * _Nonnull _Lajr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3240);
}
// NetworkUsageSettings.ResetStatsConfirmation
NSString * _Nonnull _Lajs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3241);
}
// NetworkUsageSettings.Title
NSString * _Nonnull _Lajt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3242);
}
// NetworkUsageSettings.TotalSection
NSString * _Nonnull _Laju(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3243);
}
// NetworkUsageSettings.Wifi
NSString * _Nonnull _Lajv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3244);
}
// NetworkUsageSettings.WifiUsageSince
_FormattedString * _Nonnull _Lajw(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3245, _0);
}
// NewContact.Title
NSString * _Nonnull _Lajx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3246);
}
// Notification.BotWriteAllowed
NSString * _Nonnull _Lajy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3247);
}
// Notification.CallBack
NSString * _Nonnull _Lajz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3248);
}
// Notification.CallCanceled
NSString * _Nonnull _LajA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3249);
}
// Notification.CallCanceledShort
NSString * _Nonnull _LajB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3250);
}
// Notification.CallFormat
_FormattedString * _Nonnull _LajC(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3251, _0, _1);
}
// Notification.CallIncoming
NSString * _Nonnull _LajD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3252);
}
// Notification.CallIncomingShort
NSString * _Nonnull _LajE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3253);
}
// Notification.CallMissed
NSString * _Nonnull _LajF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3254);
}
// Notification.CallMissedShort
NSString * _Nonnull _LajG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3255);
}
// Notification.CallOutgoing
NSString * _Nonnull _LajH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3256);
}
// Notification.CallOutgoingShort
NSString * _Nonnull _LajI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3257);
}
// Notification.CallTimeFormat
_FormattedString * _Nonnull _LajJ(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3258, _0, _1);
}
// Notification.ChangedGroupName
_FormattedString * _Nonnull _LajK(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3259, _0, _1);
}
// Notification.ChangedGroupPhoto
_FormattedString * _Nonnull _LajL(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3260, _0);
}
// Notification.ChangedGroupVideo
_FormattedString * _Nonnull _LajM(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3261, _0);
}
// Notification.ChangedTheme
_FormattedString * _Nonnull _LajN(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3262, _0, _1);
}
// Notification.ChannelChangedTheme
_FormattedString * _Nonnull _LajO(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3263, _0);
}
// Notification.ChannelDisabledTheme
NSString * _Nonnull _LajP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3264);
}
// Notification.ChannelInviter
_FormattedString * _Nonnull _LajQ(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3265, _0);
}
// Notification.ChannelInviterSelf
NSString * _Nonnull _LajR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3266);
}
// Notification.CreatedChannel
NSString * _Nonnull _LajS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3267);
}
// Notification.CreatedChat
_FormattedString * _Nonnull _LajT(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3268, _0);
}
// Notification.CreatedChatWithTitle
_FormattedString * _Nonnull _LajU(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3269, _0, _1);
}
// Notification.CreatedGroup
NSString * _Nonnull _LajV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3270);
}
// Notification.DisabledTheme
_FormattedString * _Nonnull _LajW(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3271, _0);
}
// Notification.Exceptions.Add
NSString * _Nonnull _LajX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3272);
}
// Notification.Exceptions.AddException
NSString * _Nonnull _LajY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3273);
}
// Notification.Exceptions.AlwaysOff
NSString * _Nonnull _LajZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3274);
}
// Notification.Exceptions.AlwaysOn
NSString * _Nonnull _Laka(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3275);
}
// Notification.Exceptions.DeleteAll
NSString * _Nonnull _Lakb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3276);
}
// Notification.Exceptions.DeleteAllConfirmation
NSString * _Nonnull _Lakc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3277);
}
// Notification.Exceptions.MessagePreviewAlwaysOff
NSString * _Nonnull _Lakd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3278);
}
// Notification.Exceptions.MessagePreviewAlwaysOn
NSString * _Nonnull _Lake(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3279);
}
// Notification.Exceptions.MutedUntil
_FormattedString * _Nonnull _Lakf(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3280, _0);
}
// Notification.Exceptions.NewException
NSString * _Nonnull _Lakg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3281);
}
// Notification.Exceptions.NewException.MessagePreviewHeader
NSString * _Nonnull _Lakh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3282);
}
// Notification.Exceptions.NewException.NotificationHeader
NSString * _Nonnull _Laki(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3283);
}
// Notification.Exceptions.PreviewAlwaysOff
NSString * _Nonnull _Lakj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3284);
}
// Notification.Exceptions.PreviewAlwaysOn
NSString * _Nonnull _Lakk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3285);
}
// Notification.Exceptions.RemoveFromExceptions
NSString * _Nonnull _Lakl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3286);
}
// Notification.Exceptions.Sound
_FormattedString * _Nonnull _Lakm(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3287, _0);
}
// Notification.Exceptions.SoundCustom
NSString * _Nonnull _Lakn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3288);
}
// Notification.ForumTopicClosed
NSString * _Nonnull _Lako(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3289);
}
// Notification.ForumTopicClosedAuthor
_FormattedString * _Nonnull _Lakp(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3290, _0);
}
// Notification.ForumTopicCreated
NSString * _Nonnull _Lakq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3291);
}
// Notification.ForumTopicHidden
NSString * _Nonnull _Lakr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3292);
}
// Notification.ForumTopicHiddenAuthor
_FormattedString * _Nonnull _Laks(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3293, _0);
}
// Notification.ForumTopicIconChanged
_FormattedString * _Nonnull _Lakt(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3294, _0);
}
// Notification.ForumTopicIconChangedAuthor
_FormattedString * _Nonnull _Laku(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3295, _0, _1);
}
// Notification.ForumTopicRenamed
_FormattedString * _Nonnull _Lakv(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3296, _0);
}
// Notification.ForumTopicRenamedAuthor
_FormattedString * _Nonnull _Lakw(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3297, _0, _1);
}
// Notification.ForumTopicRenamedIconChangedAuthor
_FormattedString * _Nonnull _Lakx(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2) {
    return getFormatted3(_self, 3298, _0, _1, _2);
}
// Notification.ForumTopicReopened
NSString * _Nonnull _Laky(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3299);
}
// Notification.ForumTopicReopenedAuthor
_FormattedString * _Nonnull _Lakz(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3300, _0);
}
// Notification.ForumTopicUnhidden
NSString * _Nonnull _LakA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3301);
}
// Notification.ForumTopicUnhiddenAuthor
_FormattedString * _Nonnull _LakB(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3302, _0);
}
// Notification.GameScoreExtended
NSString * _Nonnull _LakC(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3303, value);
}
// Notification.GameScoreSelfExtended
NSString * _Nonnull _LakD(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3304, value);
}
// Notification.GameScoreSelfSimple
NSString * _Nonnull _LakE(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3305, value);
}
// Notification.GameScoreSimple
NSString * _Nonnull _LakF(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3306, value);
}
// Notification.GroupActivated
NSString * _Nonnull _LakG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3307);
}
// Notification.GroupInviter
_FormattedString * _Nonnull _LakH(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3308, _0);
}
// Notification.GroupInviterSelf
NSString * _Nonnull _LakI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3309);
}
// Notification.Invited
_FormattedString * _Nonnull _LakJ(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3310, _0, _1);
}
// Notification.InvitedMultiple
_FormattedString * _Nonnull _LakK(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3311, _0, _1);
}
// Notification.Joined
_FormattedString * _Nonnull _LakL(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3312, _0);
}
// Notification.JoinedChannel
_FormattedString * _Nonnull _LakM(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3313, _0);
}
// Notification.JoinedChannelByRequestYou
NSString * _Nonnull _LakN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3314);
}
// Notification.JoinedChat
_FormattedString * _Nonnull _LakO(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3315, _0);
}
// Notification.JoinedGroupByLink
_FormattedString * _Nonnull _LakP(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3316, _0);
}
// Notification.JoinedGroupByLinkYou
NSString * _Nonnull _LakQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3317);
}
// Notification.JoinedGroupByRequest
_FormattedString * _Nonnull _LakR(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3318, _0);
}
// Notification.JoinedGroupByRequestYou
NSString * _Nonnull _LakS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3319);
}
// Notification.Kicked
_FormattedString * _Nonnull _LakT(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3320, _0, _1);
}
// Notification.LeftChannel
_FormattedString * _Nonnull _LakU(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3321, _0);
}
// Notification.LeftChat
_FormattedString * _Nonnull _LakV(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3322, _0);
}
// Notification.LiveStreamEnded
_FormattedString * _Nonnull _LakW(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3323, _0);
}
// Notification.LiveStreamScheduled
_FormattedString * _Nonnull _LakX(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3324, _0);
}
// Notification.LiveStreamScheduledToday
_FormattedString * _Nonnull _LakY(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3325, _0);
}
// Notification.LiveStreamScheduledTomorrow
_FormattedString * _Nonnull _LakZ(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3326, _0);
}
// Notification.LiveStreamStarted
NSString * _Nonnull _Lala(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3327);
}
// Notification.MessageLifetime1d
NSString * _Nonnull _Lalb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3328);
}
// Notification.MessageLifetime1h
NSString * _Nonnull _Lalc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3329);
}
// Notification.MessageLifetime1m
NSString * _Nonnull _Lald(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3330);
}
// Notification.MessageLifetime1w
NSString * _Nonnull _Lale(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3331);
}
// Notification.MessageLifetime2s
NSString * _Nonnull _Lalf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3332);
}
// Notification.MessageLifetime5s
NSString * _Nonnull _Lalg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3333);
}
// Notification.MessageLifetimeChanged
_FormattedString * _Nonnull _Lalh(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3334, _0, _1);
}
// Notification.MessageLifetimeChangedOutgoing
_FormattedString * _Nonnull _Lali(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3335, _0);
}
// Notification.MessageLifetimeRemoved
_FormattedString * _Nonnull _Lalj(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3336, _0);
}
// Notification.MessageLifetimeRemovedOutgoing
NSString * _Nonnull _Lalk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3337);
}
// Notification.Mute1h
NSString * _Nonnull _Lall(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3338);
}
// Notification.Mute1hMin
NSString * _Nonnull _Lalm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3339);
}
// Notification.NewAuthDetected
_FormattedString * _Nonnull _Laln(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2, NSString * _Nonnull _3, NSString * _Nonnull _4, NSString * _Nonnull _5) {
    return getFormatted6(_self, 3340, _0, _1, _2, _3, _4, _5);
}
// Notification.OverviewTopicClosed
_FormattedString * _Nonnull _Lalo(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2) {
    return getFormatted3(_self, 3341, _0, _1, _2);
}
// Notification.OverviewTopicCreated
_FormattedString * _Nonnull _Lalp(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3342, _0, _1);
}
// Notification.OverviewTopicHidden
_FormattedString * _Nonnull _Lalq(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2) {
    return getFormatted3(_self, 3343, _0, _1, _2);
}
// Notification.OverviewTopicReopened
_FormattedString * _Nonnull _Lalr(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2) {
    return getFormatted3(_self, 3344, _0, _1, _2);
}
// Notification.OverviewTopicUnhidden
_FormattedString * _Nonnull _Lals(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2) {
    return getFormatted3(_self, 3345, _0, _1, _2);
}
// Notification.PassportValueAddress
NSString * _Nonnull _Lalt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3346);
}
// Notification.PassportValueEmail
NSString * _Nonnull _Lalu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3347);
}
// Notification.PassportValuePersonalDetails
NSString * _Nonnull _Lalv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3348);
}
// Notification.PassportValuePhone
NSString * _Nonnull _Lalw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3349);
}
// Notification.PassportValueProofOfAddress
NSString * _Nonnull _Lalx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3350);
}
// Notification.PassportValueProofOfIdentity
NSString * _Nonnull _Laly(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3351);
}
// Notification.PassportValuesSentMessage
_FormattedString * _Nonnull _Lalz(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3352, _0, _1);
}
// Notification.PaymentSent
NSString * _Nonnull _LalA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3353);
}
// Notification.PaymentSentNoTitle
NSString * _Nonnull _LalB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3354);
}
// Notification.PaymentSentRecurringInit
NSString * _Nonnull _LalC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3355);
}
// Notification.PaymentSentRecurringInitNoTitle
NSString * _Nonnull _LalD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3356);
}
// Notification.PaymentSentRecurringUsed
NSString * _Nonnull _LalE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3357);
}
// Notification.PaymentSentRecurringUsedNoTitle
NSString * _Nonnull _LalF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3358);
}
// Notification.PinnedAnimationMessage
_FormattedString * _Nonnull _LalG(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3359, _0);
}
// Notification.PinnedAudioMessage
_FormattedString * _Nonnull _LalH(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3360, _0);
}
// Notification.PinnedContactMessage
_FormattedString * _Nonnull _LalI(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3361, _0);
}
// Notification.PinnedDeletedMessage
_FormattedString * _Nonnull _LalJ(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3362, _0);
}
// Notification.PinnedDocumentMessage
_FormattedString * _Nonnull _LalK(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3363, _0);
}
// Notification.PinnedLiveLocationMessage
_FormattedString * _Nonnull _LalL(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3364, _0);
}
// Notification.PinnedLocationMessage
_FormattedString * _Nonnull _LalM(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3365, _0);
}
// Notification.PinnedMessage
NSString * _Nonnull _LalN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3366);
}
// Notification.PinnedPhotoMessage
_FormattedString * _Nonnull _LalO(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3367, _0);
}
// Notification.PinnedPollMessage
_FormattedString * _Nonnull _LalP(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3368, _0);
}
// Notification.PinnedQuizMessage
_FormattedString * _Nonnull _LalQ(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3369, _0);
}
// Notification.PinnedRoundMessage
_FormattedString * _Nonnull _LalR(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3370, _0);
}
// Notification.PinnedStickerMessage
_FormattedString * _Nonnull _LalS(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3371, _0);
}
// Notification.PinnedTextMessage
_FormattedString * _Nonnull _LalT(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3372, _0, _1);
}
// Notification.PinnedVideoMessage
_FormattedString * _Nonnull _LalU(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3373, _0);
}
// Notification.PremiumGift.Months
NSString * _Nonnull _LalV(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3374, value);
}
// Notification.PremiumGift.Sent
_FormattedString * _Nonnull _LalW(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3375, _0, _1);
}
// Notification.PremiumGift.SentYou
_FormattedString * _Nonnull _LalX(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3376, _0);
}
// Notification.PremiumGift.Subtitle
_FormattedString * _Nonnull _LalY(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3377, _0);
}
// Notification.PremiumGift.Title
NSString * _Nonnull _LalZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3378);
}
// Notification.PremiumGift.View
NSString * _Nonnull _Lama(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3379);
}
// Notification.ProximityReached
_FormattedString * _Nonnull _Lamb(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2) {
    return getFormatted3(_self, 3380, _0, _1, _2);
}
// Notification.ProximityReachedYou
_FormattedString * _Nonnull _Lamc(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3381, _0, _1);
}
// Notification.ProximityYouReached
_FormattedString * _Nonnull _Lamd(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3382, _0, _1);
}
// Notification.RemovedGroupPhoto
_FormattedString * _Nonnull _Lame(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3383, _0);
}
// Notification.RenamedChannel
NSString * _Nonnull _Lamf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3384);
}
// Notification.RenamedChat
_FormattedString * _Nonnull _Lamg(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3385, _0);
}
// Notification.RenamedGroup
NSString * _Nonnull _Lamh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3386);
}
// Notification.Reply
NSString * _Nonnull _Lami(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3387);
}
// Notification.RequestedPeer
_FormattedString * _Nonnull _Lamj(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3388, _0, _1);
}
// Notification.SecretChatMessageScreenshot
_FormattedString * _Nonnull _Lamk(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3389, _0);
}
// Notification.SecretChatMessageScreenshotSelf
NSString * _Nonnull _Laml(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3390);
}
// Notification.SecretChatScreenshot
NSString * _Nonnull _Lamm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3391);
}
// Notification.SuggestedProfilePhoto
NSString * _Nonnull _Lamn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3392);
}
// Notification.SuggestedProfileVideo
NSString * _Nonnull _Lamo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3393);
}
// Notification.VideoCallCanceled
NSString * _Nonnull _Lamp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3394);
}
// Notification.VideoCallIncoming
NSString * _Nonnull _Lamq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3395);
}
// Notification.VideoCallMissed
NSString * _Nonnull _Lamr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3396);
}
// Notification.VideoCallOutgoing
NSString * _Nonnull _Lams(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3397);
}
// Notification.VoiceChatEnded
_FormattedString * _Nonnull _Lamt(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3398, _0);
}
// Notification.VoiceChatEndedGroup
_FormattedString * _Nonnull _Lamu(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3399, _0, _1);
}
// Notification.VoiceChatInvitation
_FormattedString * _Nonnull _Lamv(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3400, _0, _1);
}
// Notification.VoiceChatInvitationForYou
_FormattedString * _Nonnull _Lamw(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3401, _0);
}
// Notification.VoiceChatScheduled
_FormattedString * _Nonnull _Lamx(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3402, _0, _1);
}
// Notification.VoiceChatScheduledChannel
_FormattedString * _Nonnull _Lamy(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3403, _0);
}
// Notification.VoiceChatScheduledToday
_FormattedString * _Nonnull _Lamz(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3404, _0, _1);
}
// Notification.VoiceChatScheduledTodayChannel
_FormattedString * _Nonnull _LamA(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3405, _0);
}
// Notification.VoiceChatScheduledTomorrow
_FormattedString * _Nonnull _LamB(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3406, _0, _1);
}
// Notification.VoiceChatScheduledTomorrowChannel
_FormattedString * _Nonnull _LamC(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3407, _0);
}
// Notification.VoiceChatStarted
_FormattedString * _Nonnull _LamD(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3408, _0);
}
// Notification.VoiceChatStartedChannel
NSString * _Nonnull _LamE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3409);
}
// Notification.WebAppSentData
_FormattedString * _Nonnull _LamF(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3410, _0);
}
// Notification.YouChangedTheme
_FormattedString * _Nonnull _LamG(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3411, _0);
}
// Notification.YouDisabledTheme
NSString * _Nonnull _LamH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3412);
}
// NotificationSettings.ContactJoined
NSString * _Nonnull _LamI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3413);
}
// NotificationSettings.ContactJoinedInfo
NSString * _Nonnull _LamJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3414);
}
// NotificationSettings.ShowNotificationsAllAccounts
NSString * _Nonnull _LamK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3415);
}
// NotificationSettings.ShowNotificationsAllAccountsInfoOff
NSString * _Nonnull _LamL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3416);
}
// NotificationSettings.ShowNotificationsAllAccountsInfoOn
NSString * _Nonnull _LamM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3417);
}
// NotificationSettings.ShowNotificationsFromAccountsSection
NSString * _Nonnull _LamN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3418);
}
// Notifications.AddExceptionTitle
NSString * _Nonnull _LamO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3419);
}
// Notifications.AlertTones
NSString * _Nonnull _LamP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3420);
}
// Notifications.Badge
NSString * _Nonnull _LamQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3421);
}
// Notifications.Badge.CountUnreadMessages
NSString * _Nonnull _LamR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3422);
}
// Notifications.Badge.CountUnreadMessages.InfoOff
NSString * _Nonnull _LamS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3423);
}
// Notifications.Badge.CountUnreadMessages.InfoOn
NSString * _Nonnull _LamT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3424);
}
// Notifications.Badge.IncludeChannels
NSString * _Nonnull _LamU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3425);
}
// Notifications.Badge.IncludeMutedChats
NSString * _Nonnull _LamV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3426);
}
// Notifications.Badge.IncludePublicGroups
NSString * _Nonnull _LamW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3427);
}
// Notifications.CategoryExceptions
NSString * _Nonnull _LamX(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3428, value);
}
// Notifications.ChannelNotifications
NSString * _Nonnull _LamY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3429);
}
// Notifications.ChannelNotificationsAlert
NSString * _Nonnull _LamZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3430);
}
// Notifications.ChannelNotificationsExceptionsHelp
NSString * _Nonnull _Lana(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3431);
}
// Notifications.ChannelNotificationsHelp
NSString * _Nonnull _Lanb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3432);
}
// Notifications.ChannelNotificationsPreview
NSString * _Nonnull _Lanc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3433);
}
// Notifications.ChannelNotificationsSound
NSString * _Nonnull _Land(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3434);
}
// Notifications.Channels
NSString * _Nonnull _Lane(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3435);
}
// Notifications.ChannelsTitle
NSString * _Nonnull _Lanf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3436);
}
// Notifications.ClassicTones
NSString * _Nonnull _Lang(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3437);
}
// Notifications.DeleteAllExceptions
NSString * _Nonnull _Lanh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3438);
}
// Notifications.DisplayNamesOnLockScreen
NSString * _Nonnull _Lani(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3439);
}
// Notifications.DisplayNamesOnLockScreenInfoWithLink
NSString * _Nonnull _Lanj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3440);
}
// Notifications.ExceptionMuteExpires.Days
NSString * _Nonnull _Lank(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3441, value);
}
// Notifications.ExceptionMuteExpires.Hours
NSString * _Nonnull _Lanl(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3442, value);
}
// Notifications.ExceptionMuteExpires.Minutes
NSString * _Nonnull _Lanm(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3443, value);
}
// Notifications.Exceptions
NSString * _Nonnull _Lann(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3444, value);
}
// Notifications.ExceptionsChangeSound
_FormattedString * _Nonnull _Lano(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3445, _0);
}
// Notifications.ExceptionsDefaultSound
NSString * _Nonnull _Lanp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3446);
}
// Notifications.ExceptionsGroupPlaceholder
NSString * _Nonnull _Lanq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3447);
}
// Notifications.ExceptionsMessagePlaceholder
NSString * _Nonnull _Lanr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3448);
}
// Notifications.ExceptionsMuted
NSString * _Nonnull _Lans(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3449);
}
// Notifications.ExceptionsNone
NSString * _Nonnull _Lant(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3450);
}
// Notifications.ExceptionsResetToDefaults
NSString * _Nonnull _Lanu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3451);
}
// Notifications.ExceptionsTitle
NSString * _Nonnull _Lanv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3452);
}
// Notifications.ExceptionsUnmuted
NSString * _Nonnull _Lanw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3453);
}
// Notifications.GroupChats
NSString * _Nonnull _Lanx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3454);
}
// Notifications.GroupChatsTitle
NSString * _Nonnull _Lany(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3455);
}
// Notifications.GroupNotifications
NSString * _Nonnull _Lanz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3456);
}
// Notifications.GroupNotificationsAlert
NSString * _Nonnull _LanA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3457);
}
// Notifications.GroupNotificationsExceptions
NSString * _Nonnull _LanB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3458);
}
// Notifications.GroupNotificationsExceptionsHelp
NSString * _Nonnull _LanC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3459);
}
// Notifications.GroupNotificationsHelp
NSString * _Nonnull _LanD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3460);
}
// Notifications.GroupNotificationsPreview
NSString * _Nonnull _LanE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3461);
}
// Notifications.GroupNotificationsSound
NSString * _Nonnull _LanF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3462);
}
// Notifications.InAppNotifications
NSString * _Nonnull _LanG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3463);
}
// Notifications.InAppNotificationsPreview
NSString * _Nonnull _LanH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3464);
}
// Notifications.InAppNotificationsSounds
NSString * _Nonnull _LanI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3465);
}
// Notifications.InAppNotificationsVibrate
NSString * _Nonnull _LanJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3466);
}
// Notifications.MessageNotifications
NSString * _Nonnull _LanK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3467);
}
// Notifications.MessageNotificationsAlert
NSString * _Nonnull _LanL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3468);
}
// Notifications.MessageNotificationsExceptions
NSString * _Nonnull _LanM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3469);
}
// Notifications.MessageNotificationsExceptionsHelp
NSString * _Nonnull _LanN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3470);
}
// Notifications.MessageNotificationsHelp
NSString * _Nonnull _LanO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3471);
}
// Notifications.MessageNotificationsPreview
NSString * _Nonnull _LanP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3472);
}
// Notifications.MessageNotificationsSound
NSString * _Nonnull _LanQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3473);
}
// Notifications.MessageSoundInfo
NSString * _Nonnull _LanR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3474);
}
// Notifications.Off
NSString * _Nonnull _LanS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3475);
}
// Notifications.On
NSString * _Nonnull _LanT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3476);
}
// Notifications.Options
NSString * _Nonnull _LanU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3477);
}
// Notifications.PermissionsAllow
NSString * _Nonnull _LanV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3478);
}
// Notifications.PermissionsAllowInSettings
NSString * _Nonnull _LanW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3479);
}
// Notifications.PermissionsEnable
NSString * _Nonnull _LanX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3480);
}
// Notifications.PermissionsKeepDisabled
NSString * _Nonnull _LanY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3481);
}
// Notifications.PermissionsOpenSettings
NSString * _Nonnull _LanZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3482);
}
// Notifications.PermissionsSuppressWarningText
NSString * _Nonnull _Laoa(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3483);
}
// Notifications.PermissionsSuppressWarningTitle
NSString * _Nonnull _Laob(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3484);
}
// Notifications.PermissionsText
NSString * _Nonnull _Laoc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3485);
}
// Notifications.PermissionsTitle
NSString * _Nonnull _Laod(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3486);
}
// Notifications.PermissionsUnreachableText
NSString * _Nonnull _Laoe(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3487);
}
// Notifications.PermissionsUnreachableTitle
NSString * _Nonnull _Laof(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3488);
}
// Notifications.PrivateChats
NSString * _Nonnull _Laog(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3489);
}
// Notifications.PrivateChatsTitle
NSString * _Nonnull _Laoh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3490);
}
// Notifications.Reset
NSString * _Nonnull _Laoi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3491);
}
// Notifications.ResetAllNotifications
NSString * _Nonnull _Laoj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3492);
}
// Notifications.ResetAllNotificationsHelp
NSString * _Nonnull _Laok(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3493);
}
// Notifications.ResetAllNotificationsText
NSString * _Nonnull _Laol(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3494);
}
// Notifications.SaveSuccess.Text
NSString * _Nonnull _Laom(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3495);
}
// Notifications.SystemTones
NSString * _Nonnull _Laon(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3496);
}
// Notifications.TelegramTones
NSString * _Nonnull _Laoo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3497);
}
// Notifications.TextTone
NSString * _Nonnull _Laop(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3498);
}
// Notifications.Title
NSString * _Nonnull _Laoq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3499);
}
// Notifications.UploadError.TooLarge.Text
_FormattedString * _Nonnull _Laor(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3500, _0);
}
// Notifications.UploadError.TooLarge.Title
NSString * _Nonnull _Laos(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3501);
}
// Notifications.UploadError.TooLong.Text
_FormattedString * _Nonnull _Laot(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3502, _0);
}
// Notifications.UploadError.TooLong.Title
_FormattedString * _Nonnull _Laou(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3503, _0);
}
// Notifications.UploadSound
NSString * _Nonnull _Laov(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3504);
}
// Notifications.UploadSuccess.Text
_FormattedString * _Nonnull _Laow(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3505, _0);
}
// Notifications.UploadSuccess.Title
NSString * _Nonnull _Laox(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3506);
}
// NotificationsSound.Alert
NSString * _Nonnull _Laoy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3507);
}
// NotificationsSound.Aurora
NSString * _Nonnull _Laoz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3508);
}
// NotificationsSound.Bamboo
NSString * _Nonnull _LaoA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3509);
}
// NotificationsSound.Bell
NSString * _Nonnull _LaoB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3510);
}
// NotificationsSound.Calypso
NSString * _Nonnull _LaoC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3511);
}
// NotificationsSound.Chime
NSString * _Nonnull _LaoD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3512);
}
// NotificationsSound.Chord
NSString * _Nonnull _LaoE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3513);
}
// NotificationsSound.Circles
NSString * _Nonnull _LaoF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3514);
}
// NotificationsSound.Complete
NSString * _Nonnull _LaoG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3515);
}
// NotificationsSound.Glass
NSString * _Nonnull _LaoH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3516);
}
// NotificationsSound.Hello
NSString * _Nonnull _LaoI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3517);
}
// NotificationsSound.Input
NSString * _Nonnull _LaoJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3518);
}
// NotificationsSound.Keys
NSString * _Nonnull _LaoK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3519);
}
// NotificationsSound.None
NSString * _Nonnull _LaoL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3520);
}
// NotificationsSound.Note
NSString * _Nonnull _LaoM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3521);
}
// NotificationsSound.Popcorn
NSString * _Nonnull _LaoN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3522);
}
// NotificationsSound.Pulse
NSString * _Nonnull _LaoO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3523);
}
// NotificationsSound.Synth
NSString * _Nonnull _LaoP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3524);
}
// NotificationsSound.Telegraph
NSString * _Nonnull _LaoQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3525);
}
// NotificationsSound.Tremolo
NSString * _Nonnull _LaoR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3526);
}
// NotificationsSound.Tritone
NSString * _Nonnull _LaoS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3527);
}
// OldChannels.ChannelFormat
NSString * _Nonnull _LaoT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3528);
}
// OldChannels.ChannelsHeader
NSString * _Nonnull _LaoU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3529);
}
// OldChannels.GroupEmptyFormat
NSString * _Nonnull _LaoV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3530);
}
// OldChannels.GroupFormat
NSString * _Nonnull _LaoW(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3531, value);
}
// OldChannels.InactiveMonth
NSString * _Nonnull _LaoX(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3532, value);
}
// OldChannels.InactiveWeek
NSString * _Nonnull _LaoY(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3533, value);
}
// OldChannels.InactiveYear
NSString * _Nonnull _LaoZ(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3534, value);
}
// OldChannels.Leave
NSString * _Nonnull _Lapa(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3535, value);
}
// OldChannels.LeaveCommunities
NSString * _Nonnull _Lapb(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3536, value);
}
// OldChannels.NoticeCreateText
NSString * _Nonnull _Lapc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3537);
}
// OldChannels.NoticeText
NSString * _Nonnull _Lapd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3538);
}
// OldChannels.NoticeTitle
NSString * _Nonnull _Lape(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3539);
}
// OldChannels.NoticeUpgradeText
NSString * _Nonnull _Lapf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3540);
}
// OldChannels.Title
NSString * _Nonnull _Lapg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3541);
}
// OldChannels.TooManyCommunitiesCreateFinalText
_FormattedString * _Nonnull _Laph(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3542, _0);
}
// OldChannels.TooManyCommunitiesCreateNoPremiumText
_FormattedString * _Nonnull _Lapi(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3543, _0);
}
// OldChannels.TooManyCommunitiesCreateText
_FormattedString * _Nonnull _Lapj(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3544, _0, _1);
}
// OldChannels.TooManyCommunitiesFinalText
_FormattedString * _Nonnull _Lapk(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3545, _0);
}
// OldChannels.TooManyCommunitiesNoPremiumText
_FormattedString * _Nonnull _Lapl(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3546, _0);
}
// OldChannels.TooManyCommunitiesText
_FormattedString * _Nonnull _Lapm(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3547, _0, _1);
}
// OldChannels.TooManyCommunitiesUpgradeFinalText
_FormattedString * _Nonnull _Lapn(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3548, _0);
}
// OldChannels.TooManyCommunitiesUpgradeNoPremiumText
_FormattedString * _Nonnull _Lapo(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3549, _0);
}
// OldChannels.TooManyCommunitiesUpgradeText
_FormattedString * _Nonnull _Lapp(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3550, _0, _1);
}
// OpenFile.PotentiallyDangerousContentAlert
NSString * _Nonnull _Lapq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3551);
}
// OpenFile.Proceed
NSString * _Nonnull _Lapr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3552);
}
// OwnershipTransfer.ComeBackLater
NSString * _Nonnull _Laps(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3553);
}
// OwnershipTransfer.EnterPassword
NSString * _Nonnull _Lapt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3554);
}
// OwnershipTransfer.EnterPasswordText
NSString * _Nonnull _Lapu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3555);
}
// OwnershipTransfer.SecurityCheck
NSString * _Nonnull _Lapv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3556);
}
// OwnershipTransfer.SecurityRequirements
NSString * _Nonnull _Lapw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3557);
}
// OwnershipTransfer.SetupTwoStepAuth
NSString * _Nonnull _Lapx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3558);
}
// OwnershipTransfer.Transfer
NSString * _Nonnull _Lapy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3559);
}
// PINNED_INVOICE
_FormattedString * _Nonnull _Lapz(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3560, _0);
}
// PUSH_ALBUM
_FormattedString * _Nonnull _LapA(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3561, _0);
}
// PUSH_AUTH_REGION
_FormattedString * _Nonnull _LapB(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3562, _0, _1);
}
// PUSH_AUTH_UNKNOWN
_FormattedString * _Nonnull _LapC(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3563, _0);
}
// PUSH_CHANNEL_ALBUM
_FormattedString * _Nonnull _LapD(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3564, _0);
}
// PUSH_CHANNEL_MESSAGE
_FormattedString * _Nonnull _LapE(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3565, _0);
}
// PUSH_CHANNEL_MESSAGES_TEXT
NSString * _Nonnull _LapF(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3566, value);
}
// PUSH_CHANNEL_MESSAGE_AUDIO
_FormattedString * _Nonnull _LapG(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3567, _0);
}
// PUSH_CHANNEL_MESSAGE_CONTACT
_FormattedString * _Nonnull _LapH(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3568, _0, _1);
}
// PUSH_CHANNEL_MESSAGE_DOC
_FormattedString * _Nonnull _LapI(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3569, _0);
}
// PUSH_CHANNEL_MESSAGE_DOCS_TEXT
NSString * _Nonnull _LapJ(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3570, value);
}
// PUSH_CHANNEL_MESSAGE_FWD
_FormattedString * _Nonnull _LapK(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3571, _0);
}
// PUSH_CHANNEL_MESSAGE_GAME
_FormattedString * _Nonnull _LapL(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3572, _0, _1);
}
// PUSH_CHANNEL_MESSAGE_GEO
_FormattedString * _Nonnull _LapM(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3573, _0);
}
// PUSH_CHANNEL_MESSAGE_GEOLIVE
_FormattedString * _Nonnull _LapN(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3574, _0);
}
// PUSH_CHANNEL_MESSAGE_GIF
_FormattedString * _Nonnull _LapO(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3575, _0);
}
// PUSH_CHANNEL_MESSAGE_NOTEXT
_FormattedString * _Nonnull _LapP(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3576, _0);
}
// PUSH_CHANNEL_MESSAGE_PHOTO
_FormattedString * _Nonnull _LapQ(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3577, _0);
}
// PUSH_CHANNEL_MESSAGE_PHOTOS_TEXT
NSString * _Nonnull _LapR(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3578, value);
}
// PUSH_CHANNEL_MESSAGE_POLL
_FormattedString * _Nonnull _LapS(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3579, _0, _1);
}
// PUSH_CHANNEL_MESSAGE_QUIZ
_FormattedString * _Nonnull _LapT(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3580, _0, _1);
}
// PUSH_CHANNEL_MESSAGE_ROUND
_FormattedString * _Nonnull _LapU(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3581, _0);
}
// PUSH_CHANNEL_MESSAGE_STICKER
_FormattedString * _Nonnull _LapV(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3582, _0, _1);
}
// PUSH_CHANNEL_MESSAGE_TEXT
_FormattedString * _Nonnull _LapW(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3583, _0, _1);
}
// PUSH_CHANNEL_MESSAGE_VIDEO
_FormattedString * _Nonnull _LapX(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3584, _0);
}
// PUSH_CHANNEL_MESSAGE_VIDEOS
_FormattedString * _Nonnull _LapY(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3585, _0, _1);
}
// PUSH_CHANNEL_MESSAGE_VIDEOS_TEXT
NSString * _Nonnull _LapZ(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3586, value);
}
// PUSH_CHAT_ADD_MEMBER
_FormattedString * _Nonnull _Laqa(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2) {
    return getFormatted3(_self, 3587, _0, _1, _2);
}
// PUSH_CHAT_ADD_YOU
_FormattedString * _Nonnull _Laqb(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3588, _0, _1);
}
// PUSH_CHAT_ALBUM
_FormattedString * _Nonnull _Laqc(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3589, _0, _1);
}
// PUSH_CHAT_CREATED
_FormattedString * _Nonnull _Laqd(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3590, _0, _1);
}
// PUSH_CHAT_DELETE_MEMBER
_FormattedString * _Nonnull _Laqe(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2) {
    return getFormatted3(_self, 3591, _0, _1, _2);
}
// PUSH_CHAT_DELETE_YOU
_FormattedString * _Nonnull _Laqf(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3592, _0, _1);
}
// PUSH_CHAT_JOINED
_FormattedString * _Nonnull _Laqg(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3593, _0, _1);
}
// PUSH_CHAT_LEFT
_FormattedString * _Nonnull _Laqh(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3594, _0, _1);
}
// PUSH_CHAT_LIVESTREAM_END
_FormattedString * _Nonnull _Laqi(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3595, _0, _1);
}
// PUSH_CHAT_LIVESTREAM_INVITE
_FormattedString * _Nonnull _Laqj(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2) {
    return getFormatted3(_self, 3596, _0, _1, _2);
}
// PUSH_CHAT_LIVESTREAM_INVITE_YOU
_FormattedString * _Nonnull _Laqk(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3597, _0, _1);
}
// PUSH_CHAT_LIVESTREAM_START
_FormattedString * _Nonnull _Laql(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3598, _0, _1);
}
// PUSH_CHAT_MESSAGE
_FormattedString * _Nonnull _Laqm(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3599, _0, _1);
}
// PUSH_CHAT_MESSAGES_TEXT
NSString * _Nonnull _Laqn(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3600, value);
}
// PUSH_CHAT_MESSAGE_AUDIO
_FormattedString * _Nonnull _Laqo(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3601, _0, _1);
}
// PUSH_CHAT_MESSAGE_CONTACT
_FormattedString * _Nonnull _Laqp(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2) {
    return getFormatted3(_self, 3602, _0, _1, _2);
}
// PUSH_CHAT_MESSAGE_DOC
_FormattedString * _Nonnull _Laqq(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3603, _0, _1);
}
// PUSH_CHAT_MESSAGE_DOCS_TEXT
NSString * _Nonnull _Laqr(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3604, value);
}
// PUSH_CHAT_MESSAGE_FWD
_FormattedString * _Nonnull _Laqs(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3605, _0, _1);
}
// PUSH_CHAT_MESSAGE_FWDS_TEXT
NSString * _Nonnull _Laqt(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3606, value);
}
// PUSH_CHAT_MESSAGE_GAME
_FormattedString * _Nonnull _Laqu(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2) {
    return getFormatted3(_self, 3607, _0, _1, _2);
}
// PUSH_CHAT_MESSAGE_GAME_SCORE
_FormattedString * _Nonnull _Laqv(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2, NSString * _Nonnull _3) {
    return getFormatted4(_self, 3608, _0, _1, _2, _3);
}
// PUSH_CHAT_MESSAGE_GEO
_FormattedString * _Nonnull _Laqw(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3609, _0, _1);
}
// PUSH_CHAT_MESSAGE_GEOLIVE
_FormattedString * _Nonnull _Laqx(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3610, _0, _1);
}
// PUSH_CHAT_MESSAGE_GIF
_FormattedString * _Nonnull _Laqy(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3611, _0, _1);
}
// PUSH_CHAT_MESSAGE_INVOICE
_FormattedString * _Nonnull _Laqz(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2) {
    return getFormatted3(_self, 3612, _0, _1, _2);
}
// PUSH_CHAT_MESSAGE_NOTEXT
_FormattedString * _Nonnull _LaqA(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3613, _0, _1);
}
// PUSH_CHAT_MESSAGE_NOTHEME
_FormattedString * _Nonnull _LaqB(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3614, _0, _1);
}
// PUSH_CHAT_MESSAGE_PHOTO
_FormattedString * _Nonnull _LaqC(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3615, _0, _1);
}
// PUSH_CHAT_MESSAGE_PHOTOS_TEXT
NSString * _Nonnull _LaqD(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3616, value);
}
// PUSH_CHAT_MESSAGE_POLL
_FormattedString * _Nonnull _LaqE(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2) {
    return getFormatted3(_self, 3617, _0, _1, _2);
}
// PUSH_CHAT_MESSAGE_QUIZ
_FormattedString * _Nonnull _LaqF(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2) {
    return getFormatted3(_self, 3618, _0, _1, _2);
}
// PUSH_CHAT_MESSAGE_ROUND
_FormattedString * _Nonnull _LaqG(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3619, _0, _1);
}
// PUSH_CHAT_MESSAGE_STICKER
_FormattedString * _Nonnull _LaqH(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2) {
    return getFormatted3(_self, 3620, _0, _1, _2);
}
// PUSH_CHAT_MESSAGE_TEXT
_FormattedString * _Nonnull _LaqI(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2) {
    return getFormatted3(_self, 3621, _0, _1, _2);
}
// PUSH_CHAT_MESSAGE_THEME
_FormattedString * _Nonnull _LaqJ(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2) {
    return getFormatted3(_self, 3622, _0, _1, _2);
}
// PUSH_CHAT_MESSAGE_VIDEO
_FormattedString * _Nonnull _LaqK(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3623, _0, _1);
}
// PUSH_CHAT_MESSAGE_VIDEOS
_FormattedString * _Nonnull _LaqL(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2) {
    return getFormatted3(_self, 3624, _0, _1, _2);
}
// PUSH_CHAT_MESSAGE_VIDEOS_TEXT
NSString * _Nonnull _LaqM(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3625, value);
}
// PUSH_CHAT_PHOTO_EDITED
_FormattedString * _Nonnull _LaqN(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3626, _0, _1);
}
// PUSH_CHAT_REACT_AUDIO
_FormattedString * _Nonnull _LaqO(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2) {
    return getFormatted3(_self, 3627, _0, _1, _2);
}
// PUSH_CHAT_REACT_CONTACT
_FormattedString * _Nonnull _LaqP(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2, NSString * _Nonnull _3) {
    return getFormatted4(_self, 3628, _0, _1, _2, _3);
}
// PUSH_CHAT_REACT_DOC
_FormattedString * _Nonnull _LaqQ(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2) {
    return getFormatted3(_self, 3629, _0, _1, _2);
}
// PUSH_CHAT_REACT_GAME
_FormattedString * _Nonnull _LaqR(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2) {
    return getFormatted3(_self, 3630, _0, _1, _2);
}
// PUSH_CHAT_REACT_GEO
_FormattedString * _Nonnull _LaqS(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2) {
    return getFormatted3(_self, 3631, _0, _1, _2);
}
// PUSH_CHAT_REACT_GEOLIVE
_FormattedString * _Nonnull _LaqT(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2) {
    return getFormatted3(_self, 3632, _0, _1, _2);
}
// PUSH_CHAT_REACT_GIF
_FormattedString * _Nonnull _LaqU(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2) {
    return getFormatted3(_self, 3633, _0, _1, _2);
}
// PUSH_CHAT_REACT_INVOICE
_FormattedString * _Nonnull _LaqV(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2) {
    return getFormatted3(_self, 3634, _0, _1, _2);
}
// PUSH_CHAT_REACT_NOTEXT
_FormattedString * _Nonnull _LaqW(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2) {
    return getFormatted3(_self, 3635, _0, _1, _2);
}
// PUSH_CHAT_REACT_PHOTO
_FormattedString * _Nonnull _LaqX(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2) {
    return getFormatted3(_self, 3636, _0, _1, _2);
}
// PUSH_CHAT_REACT_POLL
_FormattedString * _Nonnull _LaqY(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2, NSString * _Nonnull _3) {
    return getFormatted4(_self, 3637, _0, _1, _2, _3);
}
// PUSH_CHAT_REACT_QUIZ
_FormattedString * _Nonnull _LaqZ(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2, NSString * _Nonnull _3) {
    return getFormatted4(_self, 3638, _0, _1, _2, _3);
}
// PUSH_CHAT_REACT_ROUND
_FormattedString * _Nonnull _Lara(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2) {
    return getFormatted3(_self, 3639, _0, _1, _2);
}
// PUSH_CHAT_REACT_STICKER
_FormattedString * _Nonnull _Larb(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2, NSString * _Nonnull _3) {
    return getFormatted4(_self, 3640, _0, _1, _2, _3);
}
// PUSH_CHAT_REACT_TEXT
_FormattedString * _Nonnull _Larc(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2, NSString * _Nonnull _3) {
    return getFormatted4(_self, 3641, _0, _1, _2, _3);
}
// PUSH_CHAT_REACT_VIDEO
_FormattedString * _Nonnull _Lard(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2) {
    return getFormatted3(_self, 3642, _0, _1, _2);
}
// PUSH_CHAT_REQ_JOINED
_FormattedString * _Nonnull _Lare(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3643, _0, _1);
}
// PUSH_CHAT_RETURNED
_FormattedString * _Nonnull _Larf(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3644, _0, _1);
}
// PUSH_CHAT_TITLE_EDITED
_FormattedString * _Nonnull _Larg(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3645, _0, _1);
}
// PUSH_CHAT_VOICECHAT_END
_FormattedString * _Nonnull _Larh(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3646, _0, _1);
}
// PUSH_CHAT_VOICECHAT_INVITE
_FormattedString * _Nonnull _Lari(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2) {
    return getFormatted3(_self, 3647, _0, _1, _2);
}
// PUSH_CHAT_VOICECHAT_INVITE_YOU
_FormattedString * _Nonnull _Larj(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3648, _0, _1);
}
// PUSH_CHAT_VOICECHAT_START
_FormattedString * _Nonnull _Lark(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3649, _0, _1);
}
// PUSH_CONTACT_JOINED
_FormattedString * _Nonnull _Larl(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3650, _0);
}
// PUSH_ENCRYPTED_MESSAGE
_FormattedString * _Nonnull _Larm(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3651, _0);
}
// PUSH_ENCRYPTION_ACCEPT
_FormattedString * _Nonnull _Larn(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3652, _0);
}
// PUSH_ENCRYPTION_REQUEST
_FormattedString * _Nonnull _Laro(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3653, _0);
}
// PUSH_LOCKED_MESSAGE
_FormattedString * _Nonnull _Larp(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3654, _0);
}
// PUSH_MESSAGE
_FormattedString * _Nonnull _Larq(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3655, _0);
}
// PUSH_MESSAGES_TEXT
NSString * _Nonnull _Larr(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3656, value);
}
// PUSH_MESSAGE_AUDIO
_FormattedString * _Nonnull _Lars(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3657, _0);
}
// PUSH_MESSAGE_CHANNEL_MESSAGE_GAME_SCORE
_FormattedString * _Nonnull _Lart(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2) {
    return getFormatted3(_self, 3658, _0, _1, _2);
}
// PUSH_MESSAGE_CONTACT
_FormattedString * _Nonnull _Laru(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3659, _0, _1);
}
// PUSH_MESSAGE_DOC
_FormattedString * _Nonnull _Larv(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3660, _0);
}
// PUSH_MESSAGE_FILES_TEXT
NSString * _Nonnull _Larw(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3661, value);
}
// PUSH_MESSAGE_FWD
_FormattedString * _Nonnull _Larx(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3662, _0);
}
// PUSH_MESSAGE_FWDS_TEXT
NSString * _Nonnull _Lary(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3663, value);
}
// PUSH_MESSAGE_GAME
_FormattedString * _Nonnull _Larz(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3664, _0, _1);
}
// PUSH_MESSAGE_GAME_SCORE
_FormattedString * _Nonnull _LarA(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2) {
    return getFormatted3(_self, 3665, _0, _1, _2);
}
// PUSH_MESSAGE_GEO
_FormattedString * _Nonnull _LarB(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3666, _0);
}
// PUSH_MESSAGE_GEOLIVE
_FormattedString * _Nonnull _LarC(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3667, _0);
}
// PUSH_MESSAGE_GIF
_FormattedString * _Nonnull _LarD(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3668, _0);
}
// PUSH_MESSAGE_INVOICE
_FormattedString * _Nonnull _LarE(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3669, _0, _1);
}
// PUSH_MESSAGE_NOTEXT
_FormattedString * _Nonnull _LarF(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3670, _0);
}
// PUSH_MESSAGE_NOTHEME
_FormattedString * _Nonnull _LarG(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3671, _0);
}
// PUSH_MESSAGE_PHOTO
_FormattedString * _Nonnull _LarH(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3672, _0);
}
// PUSH_MESSAGE_PHOTOS_TEXT
NSString * _Nonnull _LarI(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3673, value);
}
// PUSH_MESSAGE_PHOTO_SECRET
_FormattedString * _Nonnull _LarJ(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3674, _0);
}
// PUSH_MESSAGE_POLL
_FormattedString * _Nonnull _LarK(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3675, _0, _1);
}
// PUSH_MESSAGE_QUIZ
_FormattedString * _Nonnull _LarL(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3676, _0, _1);
}
// PUSH_MESSAGE_RECURRING_PAY
_FormattedString * _Nonnull _LarM(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3677, _0, _1);
}
// PUSH_MESSAGE_ROUND
_FormattedString * _Nonnull _LarN(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3678, _0);
}
// PUSH_MESSAGE_SCREENSHOT
_FormattedString * _Nonnull _LarO(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3679, _0);
}
// PUSH_MESSAGE_STICKER
_FormattedString * _Nonnull _LarP(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3680, _0, _1);
}
// PUSH_MESSAGE_SUGGEST_USERPIC
_FormattedString * _Nonnull _LarQ(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3681, _0);
}
// PUSH_MESSAGE_TEXT
_FormattedString * _Nonnull _LarR(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3682, _0, _1);
}
// PUSH_MESSAGE_THEME
_FormattedString * _Nonnull _LarS(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3683, _0, _1);
}
// PUSH_MESSAGE_VIDEO
_FormattedString * _Nonnull _LarT(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3684, _0);
}
// PUSH_MESSAGE_VIDEOS
_FormattedString * _Nonnull _LarU(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3685, _0, _1);
}
// PUSH_MESSAGE_VIDEOS_TEXT
NSString * _Nonnull _LarV(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3686, value);
}
// PUSH_MESSAGE_VIDEO_SECRET
_FormattedString * _Nonnull _LarW(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3687, _0);
}
// PUSH_PHONE_CALL_MISSED
_FormattedString * _Nonnull _LarX(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3688, _0);
}
// PUSH_PHONE_CALL_REQUEST
_FormattedString * _Nonnull _LarY(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3689, _0);
}
// PUSH_PINNED_AUDIO
_FormattedString * _Nonnull _LarZ(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3690, _0);
}
// PUSH_PINNED_CONTACT
_FormattedString * _Nonnull _Lasa(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3691, _0, _1);
}
// PUSH_PINNED_DOC
_FormattedString * _Nonnull _Lasb(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3692, _0);
}
// PUSH_PINNED_GAME
_FormattedString * _Nonnull _Lasc(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3693, _0);
}
// PUSH_PINNED_GAME_SCORE
_FormattedString * _Nonnull _Lasd(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3694, _0);
}
// PUSH_PINNED_GEO
_FormattedString * _Nonnull _Lase(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3695, _0);
}
// PUSH_PINNED_GEOLIVE
_FormattedString * _Nonnull _Lasf(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3696, _0);
}
// PUSH_PINNED_GIF
_FormattedString * _Nonnull _Lasg(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3697, _0);
}
// PUSH_PINNED_INVOICE
_FormattedString * _Nonnull _Lash(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3698, _0);
}
// PUSH_PINNED_NOTEXT
_FormattedString * _Nonnull _Lasi(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3699, _0);
}
// PUSH_PINNED_PHOTO
_FormattedString * _Nonnull _Lasj(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3700, _0);
}
// PUSH_PINNED_POLL
_FormattedString * _Nonnull _Lask(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3701, _0);
}
// PUSH_PINNED_QUIZ
_FormattedString * _Nonnull _Lasl(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3702, _0);
}
// PUSH_PINNED_ROUND
_FormattedString * _Nonnull _Lasm(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3703, _0);
}
// PUSH_PINNED_STICKER
_FormattedString * _Nonnull _Lasn(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3704, _0, _1);
}
// PUSH_PINNED_TEXT
_FormattedString * _Nonnull _Laso(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3705, _0, _1);
}
// PUSH_PINNED_VIDEO
_FormattedString * _Nonnull _Lasp(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3706, _0);
}
// PUSH_REACT_AUDIO
_FormattedString * _Nonnull _Lasq(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3707, _0, _1);
}
// PUSH_REACT_CONTACT
_FormattedString * _Nonnull _Lasr(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2) {
    return getFormatted3(_self, 3708, _0, _1, _2);
}
// PUSH_REACT_DOC
_FormattedString * _Nonnull _Lass(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3709, _0, _1);
}
// PUSH_REACT_GAME
_FormattedString * _Nonnull _Last(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3710, _0, _1);
}
// PUSH_REACT_GEO
_FormattedString * _Nonnull _Lasu(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3711, _0, _1);
}
// PUSH_REACT_GEOLIVE
_FormattedString * _Nonnull _Lasv(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3712, _0, _1);
}
// PUSH_REACT_GIF
_FormattedString * _Nonnull _Lasw(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3713, _0, _1);
}
// PUSH_REACT_INVOICE
_FormattedString * _Nonnull _Lasx(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3714, _0, _1);
}
// PUSH_REACT_NOTEXT
_FormattedString * _Nonnull _Lasy(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3715, _0, _1);
}
// PUSH_REACT_PHOTO
_FormattedString * _Nonnull _Lasz(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3716, _0, _1);
}
// PUSH_REACT_POLL
_FormattedString * _Nonnull _LasA(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2) {
    return getFormatted3(_self, 3717, _0, _1, _2);
}
// PUSH_REACT_QUIZ
_FormattedString * _Nonnull _LasB(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2) {
    return getFormatted3(_self, 3718, _0, _1, _2);
}
// PUSH_REACT_ROUND
_FormattedString * _Nonnull _LasC(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3719, _0, _1);
}
// PUSH_REACT_STICKER
_FormattedString * _Nonnull _LasD(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2) {
    return getFormatted3(_self, 3720, _0, _1, _2);
}
// PUSH_REACT_TEXT
_FormattedString * _Nonnull _LasE(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2) {
    return getFormatted3(_self, 3721, _0, _1, _2);
}
// PUSH_REACT_VIDEO
_FormattedString * _Nonnull _LasF(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3722, _0, _1);
}
// PUSH_REMINDER_TITLE
NSString * _Nonnull _LasG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3723);
}
// PUSH_SENDER_YOU
NSString * _Nonnull _LasH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3724);
}
// PUSH_VIDEO_CALL_MISSED
_FormattedString * _Nonnull _LasI(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3725, _0);
}
// PUSH_VIDEO_CALL_REQUEST
_FormattedString * _Nonnull _LasJ(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3726, _0);
}
// Paint.Arrow
NSString * _Nonnull _LasK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3727);
}
// Paint.Bubble
NSString * _Nonnull _LasL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3728);
}
// Paint.Clear
NSString * _Nonnull _LasM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3729);
}
// Paint.ClearConfirm
NSString * _Nonnull _LasN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3730);
}
// Paint.ColorGrid
NSString * _Nonnull _LasO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3731);
}
// Paint.ColorOpacity
NSString * _Nonnull _LasP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3732);
}
// Paint.ColorSliders
NSString * _Nonnull _LasQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3733);
}
// Paint.ColorSpectrum
NSString * _Nonnull _LasR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3734);
}
// Paint.ColorTitle
NSString * _Nonnull _LasS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3735);
}
// Paint.Delete
NSString * _Nonnull _LasT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3736);
}
// Paint.Draw
NSString * _Nonnull _LasU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3737);
}
// Paint.Duplicate
NSString * _Nonnull _LasV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3738);
}
// Paint.Edit
NSString * _Nonnull _LasW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3739);
}
// Paint.Ellipse
NSString * _Nonnull _LasX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3740);
}
// Paint.Framed
NSString * _Nonnull _LasY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3741);
}
// Paint.Marker
NSString * _Nonnull _LasZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3742);
}
// Paint.Masks
NSString * _Nonnull _Lata(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3743);
}
// Paint.MoveForward
NSString * _Nonnull _Latb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3744);
}
// Paint.Neon
NSString * _Nonnull _Latc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3745);
}
// Paint.Outlined
NSString * _Nonnull _Latd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3746);
}
// Paint.Pen
NSString * _Nonnull _Late(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3747);
}
// Paint.RecentStickers
NSString * _Nonnull _Latf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3748);
}
// Paint.Rectangle
NSString * _Nonnull _Latg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3749);
}
// Paint.Regular
NSString * _Nonnull _Lath(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3750);
}
// Paint.Star
NSString * _Nonnull _Lati(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3751);
}
// Paint.Sticker
NSString * _Nonnull _Latj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3752);
}
// Paint.Stickers
NSString * _Nonnull _Latk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3753);
}
// Paint.Text
NSString * _Nonnull _Latl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3754);
}
// Paint.ZoomOut
NSString * _Nonnull _Latm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3755);
}
// Passcode.AppLockedAlert
NSString * _Nonnull _Latn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3756);
}
// PasscodeSettings.4DigitCode
NSString * _Nonnull _Lato(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3757);
}
// PasscodeSettings.6DigitCode
NSString * _Nonnull _Latp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3758);
}
// PasscodeSettings.AlphanumericCode
NSString * _Nonnull _Latq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3759);
}
// PasscodeSettings.AutoLock
NSString * _Nonnull _Latr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3760);
}
// PasscodeSettings.AutoLock.Disabled
NSString * _Nonnull _Lats(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3761);
}
// PasscodeSettings.AutoLock.IfAwayFor_1hour
NSString * _Nonnull _Latt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3762);
}
// PasscodeSettings.AutoLock.IfAwayFor_1minute
NSString * _Nonnull _Latu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3763);
}
// PasscodeSettings.AutoLock.IfAwayFor_5hours
NSString * _Nonnull _Latv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3764);
}
// PasscodeSettings.AutoLock.IfAwayFor_5minutes
NSString * _Nonnull _Latw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3765);
}
// PasscodeSettings.ChangePasscode
NSString * _Nonnull _Latx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3766);
}
// PasscodeSettings.DoNotMatch
NSString * _Nonnull _Laty(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3767);
}
// PasscodeSettings.EncryptData
NSString * _Nonnull _Latz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3768);
}
// PasscodeSettings.EncryptDataHelp
NSString * _Nonnull _LatA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3769);
}
// PasscodeSettings.FailedAttempts
NSString * _Nonnull _LatB(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 3770, value);
}
// PasscodeSettings.Help
NSString * _Nonnull _LatC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3771);
}
// PasscodeSettings.HelpBottom
NSString * _Nonnull _LatD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3772);
}
// PasscodeSettings.HelpTop
NSString * _Nonnull _LatE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3773);
}
// PasscodeSettings.PasscodeOptions
NSString * _Nonnull _LatF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3774);
}
// PasscodeSettings.SimplePasscode
NSString * _Nonnull _LatG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3775);
}
// PasscodeSettings.SimplePasscodeHelp
NSString * _Nonnull _LatH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3776);
}
// PasscodeSettings.Title
NSString * _Nonnull _LatI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3777);
}
// PasscodeSettings.TryAgainIn1Minute
NSString * _Nonnull _LatJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3778);
}
// PasscodeSettings.TurnPasscodeOff
NSString * _Nonnull _LatK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3779);
}
// PasscodeSettings.TurnPasscodeOn
NSString * _Nonnull _LatL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3780);
}
// PasscodeSettings.UnlockWithFaceId
NSString * _Nonnull _LatM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3781);
}
// PasscodeSettings.UnlockWithTouchId
NSString * _Nonnull _LatN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3782);
}
// Passport.AcceptHelp
_FormattedString * _Nonnull _LatO(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3783, _0, _1);
}
// Passport.Address.AddBankStatement
NSString * _Nonnull _LatP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3784);
}
// Passport.Address.AddPassportRegistration
NSString * _Nonnull _LatQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3785);
}
// Passport.Address.AddRentalAgreement
NSString * _Nonnull _LatR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3786);
}
// Passport.Address.AddResidentialAddress
NSString * _Nonnull _LatS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3787);
}
// Passport.Address.AddTemporaryRegistration
NSString * _Nonnull _LatT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3788);
}
// Passport.Address.AddUtilityBill
NSString * _Nonnull _LatU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3789);
}
// Passport.Address.Address
NSString * _Nonnull _LatV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3790);
}
// Passport.Address.City
NSString * _Nonnull _LatW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3791);
}
// Passport.Address.CityPlaceholder
NSString * _Nonnull _LatX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3792);
}
// Passport.Address.Country
NSString * _Nonnull _LatY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3793);
}
// Passport.Address.CountryPlaceholder
NSString * _Nonnull _LatZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3794);
}
// Passport.Address.EditBankStatement
NSString * _Nonnull _Laua(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3795);
}
// Passport.Address.EditPassportRegistration
NSString * _Nonnull _Laub(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3796);
}
// Passport.Address.EditRentalAgreement
NSString * _Nonnull _Lauc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3797);
}
// Passport.Address.EditResidentialAddress
NSString * _Nonnull _Laud(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3798);
}
// Passport.Address.EditTemporaryRegistration
NSString * _Nonnull _Laue(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3799);
}
// Passport.Address.EditUtilityBill
NSString * _Nonnull _Lauf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3800);
}
// Passport.Address.OneOfTypeBankStatement
NSString * _Nonnull _Laug(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3801);
}
// Passport.Address.OneOfTypePassportRegistration
NSString * _Nonnull _Lauh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3802);
}
// Passport.Address.OneOfTypeRentalAgreement
NSString * _Nonnull _Laui(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3803);
}
// Passport.Address.OneOfTypeTemporaryRegistration
NSString * _Nonnull _Lauj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3804);
}
// Passport.Address.OneOfTypeUtilityBill
NSString * _Nonnull _Lauk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3805);
}
// Passport.Address.Postcode
NSString * _Nonnull _Laul(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3806);
}
// Passport.Address.PostcodePlaceholder
NSString * _Nonnull _Laum(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3807);
}
// Passport.Address.Region
NSString * _Nonnull _Laun(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3808);
}
// Passport.Address.RegionPlaceholder
NSString * _Nonnull _Lauo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3809);
}
// Passport.Address.ScansHelp
NSString * _Nonnull _Laup(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3810);
}
// Passport.Address.Street
NSString * _Nonnull _Lauq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3811);
}
// Passport.Address.Street1Placeholder
NSString * _Nonnull _Laur(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3812);
}
// Passport.Address.Street2Placeholder
NSString * _Nonnull _Laus(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3813);
}
// Passport.Address.TypeBankStatement
NSString * _Nonnull _Laut(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3814);
}
// Passport.Address.TypeBankStatementUploadScan
NSString * _Nonnull _Lauu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3815);
}
// Passport.Address.TypePassportRegistration
NSString * _Nonnull _Lauv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3816);
}
// Passport.Address.TypePassportRegistrationUploadScan
NSString * _Nonnull _Lauw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3817);
}
// Passport.Address.TypeRentalAgreement
NSString * _Nonnull _Laux(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3818);
}
// Passport.Address.TypeRentalAgreementUploadScan
NSString * _Nonnull _Lauy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3819);
}
// Passport.Address.TypeResidentialAddress
NSString * _Nonnull _Lauz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3820);
}
// Passport.Address.TypeTemporaryRegistration
NSString * _Nonnull _LauA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3821);
}
// Passport.Address.TypeTemporaryRegistrationUploadScan
NSString * _Nonnull _LauB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3822);
}
// Passport.Address.TypeUtilityBill
NSString * _Nonnull _LauC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3823);
}
// Passport.Address.TypeUtilityBillUploadScan
NSString * _Nonnull _LauD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3824);
}
// Passport.Address.UploadOneOfScan
_FormattedString * _Nonnull _LauE(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3825, _0);
}
// Passport.Authorize
NSString * _Nonnull _LauF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3826);
}
// Passport.CorrectErrors
NSString * _Nonnull _LauG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3827);
}
// Passport.DeleteAddress
NSString * _Nonnull _LauH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3828);
}
// Passport.DeleteAddressConfirmation
NSString * _Nonnull _LauI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3829);
}
// Passport.DeleteDocument
NSString * _Nonnull _LauJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3830);
}
// Passport.DeleteDocumentConfirmation
NSString * _Nonnull _LauK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3831);
}
// Passport.DeletePassport
NSString * _Nonnull _LauL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3832);
}
// Passport.DeletePassportConfirmation
NSString * _Nonnull _LauM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3833);
}
// Passport.DeletePersonalDetails
NSString * _Nonnull _LauN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3834);
}
// Passport.DeletePersonalDetailsConfirmation
NSString * _Nonnull _LauO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3835);
}
// Passport.DiscardMessageAction
NSString * _Nonnull _LauP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3836);
}
// Passport.DiscardMessageDescription
NSString * _Nonnull _LauQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3837);
}
// Passport.DiscardMessageTitle
NSString * _Nonnull _LauR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3838);
}
// Passport.Email.CodeHelp
_FormattedString * _Nonnull _LauS(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3839, _0);
}
// Passport.Email.Delete
NSString * _Nonnull _LauT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3840);
}
// Passport.Email.EmailPlaceholder
NSString * _Nonnull _LauU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3841);
}
// Passport.Email.EnterOtherEmail
NSString * _Nonnull _LauV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3842);
}
// Passport.Email.Help
NSString * _Nonnull _LauW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3843);
}
// Passport.Email.Title
NSString * _Nonnull _LauX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3844);
}
// Passport.Email.UseTelegramEmail
_FormattedString * _Nonnull _LauY(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3845, _0);
}
// Passport.Email.UseTelegramEmailHelp
NSString * _Nonnull _LauZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3846);
}
// Passport.FieldAddress
NSString * _Nonnull _Lava(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3847);
}
// Passport.FieldAddressHelp
NSString * _Nonnull _Lavb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3848);
}
// Passport.FieldAddressTranslationHelp
NSString * _Nonnull _Lavc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3849);
}
// Passport.FieldAddressUploadHelp
NSString * _Nonnull _Lavd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3850);
}
// Passport.FieldEmail
NSString * _Nonnull _Lave(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3851);
}
// Passport.FieldEmailHelp
NSString * _Nonnull _Lavf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3852);
}
// Passport.FieldIdentity
NSString * _Nonnull _Lavg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3853);
}
// Passport.FieldIdentityDetailsHelp
NSString * _Nonnull _Lavh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3854);
}
// Passport.FieldIdentitySelfieHelp
NSString * _Nonnull _Lavi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3855);
}
// Passport.FieldIdentityTranslationHelp
NSString * _Nonnull _Lavj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3856);
}
// Passport.FieldIdentityUploadHelp
NSString * _Nonnull _Lavk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3857);
}
// Passport.FieldOneOf.Delimeter
NSString * _Nonnull _Lavl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3858);
}
// Passport.FieldOneOf.FinalDelimeter
NSString * _Nonnull _Lavm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3859);
}
// Passport.FieldOneOf.Or
_FormattedString * _Nonnull _Lavn(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 3860, _0, _1);
}
// Passport.FieldPhone
NSString * _Nonnull _Lavo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3861);
}
// Passport.FieldPhoneHelp
NSString * _Nonnull _Lavp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3862);
}
// Passport.FloodError
NSString * _Nonnull _Lavq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3863);
}
// Passport.ForgottenPassword
NSString * _Nonnull _Lavr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3864);
}
// Passport.Identity.AddDriversLicense
NSString * _Nonnull _Lavs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3865);
}
// Passport.Identity.AddIdentityCard
NSString * _Nonnull _Lavt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3866);
}
// Passport.Identity.AddInternalPassport
NSString * _Nonnull _Lavu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3867);
}
// Passport.Identity.AddPassport
NSString * _Nonnull _Lavv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3868);
}
// Passport.Identity.AddPersonalDetails
NSString * _Nonnull _Lavw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3869);
}
// Passport.Identity.Country
NSString * _Nonnull _Lavx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3870);
}
// Passport.Identity.CountryPlaceholder
NSString * _Nonnull _Lavy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3871);
}
// Passport.Identity.DateOfBirth
NSString * _Nonnull _Lavz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3872);
}
// Passport.Identity.DateOfBirthPlaceholder
NSString * _Nonnull _LavA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3873);
}
// Passport.Identity.DocumentDetails
NSString * _Nonnull _LavB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3874);
}
// Passport.Identity.DocumentNumber
NSString * _Nonnull _LavC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3875);
}
// Passport.Identity.DocumentNumberPlaceholder
NSString * _Nonnull _LavD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3876);
}
// Passport.Identity.DoesNotExpire
NSString * _Nonnull _LavE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3877);
}
// Passport.Identity.EditDriversLicense
NSString * _Nonnull _LavF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3878);
}
// Passport.Identity.EditIdentityCard
NSString * _Nonnull _LavG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3879);
}
// Passport.Identity.EditInternalPassport
NSString * _Nonnull _LavH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3880);
}
// Passport.Identity.EditPassport
NSString * _Nonnull _LavI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3881);
}
// Passport.Identity.EditPersonalDetails
NSString * _Nonnull _LavJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3882);
}
// Passport.Identity.ExpiryDate
NSString * _Nonnull _LavK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3883);
}
// Passport.Identity.ExpiryDateNone
NSString * _Nonnull _LavL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3884);
}
// Passport.Identity.ExpiryDatePlaceholder
NSString * _Nonnull _LavM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3885);
}
// Passport.Identity.FilesTitle
NSString * _Nonnull _LavN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3886);
}
// Passport.Identity.FilesUploadNew
NSString * _Nonnull _LavO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3887);
}
// Passport.Identity.FilesView
NSString * _Nonnull _LavP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3888);
}
// Passport.Identity.FrontSide
NSString * _Nonnull _LavQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3889);
}
// Passport.Identity.FrontSideHelp
NSString * _Nonnull _LavR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3890);
}
// Passport.Identity.Gender
NSString * _Nonnull _LavS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3891);
}
// Passport.Identity.GenderFemale
NSString * _Nonnull _LavT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3892);
}
// Passport.Identity.GenderMale
NSString * _Nonnull _LavU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3893);
}
// Passport.Identity.GenderPlaceholder
NSString * _Nonnull _LavV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3894);
}
// Passport.Identity.IssueDate
NSString * _Nonnull _LavW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3895);
}
// Passport.Identity.IssueDatePlaceholder
NSString * _Nonnull _LavX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3896);
}
// Passport.Identity.LatinNameHelp
NSString * _Nonnull _LavY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3897);
}
// Passport.Identity.MainPage
NSString * _Nonnull _LavZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3898);
}
// Passport.Identity.MainPageHelp
NSString * _Nonnull _Lawa(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3899);
}
// Passport.Identity.MiddleName
NSString * _Nonnull _Lawb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3900);
}
// Passport.Identity.MiddleNamePlaceholder
NSString * _Nonnull _Lawc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3901);
}
// Passport.Identity.Name
NSString * _Nonnull _Lawd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3902);
}
// Passport.Identity.NamePlaceholder
NSString * _Nonnull _Lawe(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3903);
}
// Passport.Identity.NativeNameGenericHelp
_FormattedString * _Nonnull _Lawf(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3904, _0);
}
// Passport.Identity.NativeNameGenericTitle
NSString * _Nonnull _Lawg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3905);
}
// Passport.Identity.NativeNameHelp
NSString * _Nonnull _Lawh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3906);
}
// Passport.Identity.NativeNameTitle
_FormattedString * _Nonnull _Lawi(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3907, _0);
}
// Passport.Identity.OneOfTypeDriversLicense
NSString * _Nonnull _Lawj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3908);
}
// Passport.Identity.OneOfTypeIdentityCard
NSString * _Nonnull _Lawk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3909);
}
// Passport.Identity.OneOfTypeInternalPassport
NSString * _Nonnull _Lawl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3910);
}
// Passport.Identity.OneOfTypePassport
NSString * _Nonnull _Lawm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3911);
}
// Passport.Identity.ResidenceCountry
NSString * _Nonnull _Lawn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3912);
}
// Passport.Identity.ResidenceCountryPlaceholder
NSString * _Nonnull _Lawo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3913);
}
// Passport.Identity.ReverseSide
NSString * _Nonnull _Lawp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3914);
}
// Passport.Identity.ReverseSideHelp
NSString * _Nonnull _Lawq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3915);
}
// Passport.Identity.ScansHelp
NSString * _Nonnull _Lawr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3916);
}
// Passport.Identity.Selfie
NSString * _Nonnull _Laws(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3917);
}
// Passport.Identity.SelfieHelp
NSString * _Nonnull _Lawt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3918);
}
// Passport.Identity.Surname
NSString * _Nonnull _Lawu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3919);
}
// Passport.Identity.SurnamePlaceholder
NSString * _Nonnull _Lawv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3920);
}
// Passport.Identity.Translation
NSString * _Nonnull _Laww(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3921);
}
// Passport.Identity.TranslationHelp
NSString * _Nonnull _Lawx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3922);
}
// Passport.Identity.Translations
NSString * _Nonnull _Lawy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3923);
}
// Passport.Identity.TranslationsHelp
NSString * _Nonnull _Lawz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3924);
}
// Passport.Identity.TypeDriversLicense
NSString * _Nonnull _LawA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3925);
}
// Passport.Identity.TypeDriversLicenseUploadScan
NSString * _Nonnull _LawB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3926);
}
// Passport.Identity.TypeIdentityCard
NSString * _Nonnull _LawC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3927);
}
// Passport.Identity.TypeIdentityCardUploadScan
NSString * _Nonnull _LawD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3928);
}
// Passport.Identity.TypeInternalPassport
NSString * _Nonnull _LawE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3929);
}
// Passport.Identity.TypeInternalPassportUploadScan
NSString * _Nonnull _LawF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3930);
}
// Passport.Identity.TypePassport
NSString * _Nonnull _LawG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3931);
}
// Passport.Identity.TypePassportUploadScan
NSString * _Nonnull _LawH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3932);
}
// Passport.Identity.TypePersonalDetails
NSString * _Nonnull _LawI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3933);
}
// Passport.Identity.UploadOneOfScan
_FormattedString * _Nonnull _LawJ(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 3934, _0);
}
// Passport.InfoFAQ_URL
NSString * _Nonnull _LawK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3935);
}
// Passport.InfoLearnMore
NSString * _Nonnull _LawL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3936);
}
// Passport.InfoText
NSString * _Nonnull _LawM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3937);
}
// Passport.InfoTitle
NSString * _Nonnull _LawN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3938);
}
// Passport.InvalidPasswordError
NSString * _Nonnull _LawO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3939);
}
// Passport.Language.ar
NSString * _Nonnull _LawP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3940);
}
// Passport.Language.az
NSString * _Nonnull _LawQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3941);
}
// Passport.Language.bg
NSString * _Nonnull _LawR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3942);
}
// Passport.Language.bn
NSString * _Nonnull _LawS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3943);
}
// Passport.Language.cs
NSString * _Nonnull _LawT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3944);
}
// Passport.Language.da
NSString * _Nonnull _LawU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3945);
}
// Passport.Language.de
NSString * _Nonnull _LawV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3946);
}
// Passport.Language.dv
NSString * _Nonnull _LawW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3947);
}
// Passport.Language.dz
NSString * _Nonnull _LawX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3948);
}
// Passport.Language.el
NSString * _Nonnull _LawY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3949);
}
// Passport.Language.en
NSString * _Nonnull _LawZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3950);
}
// Passport.Language.es
NSString * _Nonnull _Laxa(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3951);
}
// Passport.Language.et
NSString * _Nonnull _Laxb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3952);
}
// Passport.Language.fa
NSString * _Nonnull _Laxc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3953);
}
// Passport.Language.fr
NSString * _Nonnull _Laxd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3954);
}
// Passport.Language.he
NSString * _Nonnull _Laxe(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3955);
}
// Passport.Language.hr
NSString * _Nonnull _Laxf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3956);
}
// Passport.Language.hu
NSString * _Nonnull _Laxg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3957);
}
// Passport.Language.hy
NSString * _Nonnull _Laxh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3958);
}
// Passport.Language.id
NSString * _Nonnull _Laxi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3959);
}
// Passport.Language.is
NSString * _Nonnull _Laxj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3960);
}
// Passport.Language.it
NSString * _Nonnull _Laxk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3961);
}
// Passport.Language.ja
NSString * _Nonnull _Laxl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3962);
}
// Passport.Language.ka
NSString * _Nonnull _Laxm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3963);
}
// Passport.Language.km
NSString * _Nonnull _Laxn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3964);
}
// Passport.Language.ko
NSString * _Nonnull _Laxo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3965);
}
// Passport.Language.lo
NSString * _Nonnull _Laxp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3966);
}
// Passport.Language.lt
NSString * _Nonnull _Laxq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3967);
}
// Passport.Language.lv
NSString * _Nonnull _Laxr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3968);
}
// Passport.Language.mk
NSString * _Nonnull _Laxs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3969);
}
// Passport.Language.mn
NSString * _Nonnull _Laxt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3970);
}
// Passport.Language.ms
NSString * _Nonnull _Laxu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3971);
}
// Passport.Language.my
NSString * _Nonnull _Laxv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3972);
}
// Passport.Language.ne
NSString * _Nonnull _Laxw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3973);
}
// Passport.Language.nl
NSString * _Nonnull _Laxx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3974);
}
// Passport.Language.pl
NSString * _Nonnull _Laxy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3975);
}
// Passport.Language.pt
NSString * _Nonnull _Laxz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3976);
}
// Passport.Language.ro
NSString * _Nonnull _LaxA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3977);
}
// Passport.Language.ru
NSString * _Nonnull _LaxB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3978);
}
// Passport.Language.sk
NSString * _Nonnull _LaxC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3979);
}
// Passport.Language.sl
NSString * _Nonnull _LaxD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3980);
}
// Passport.Language.th
NSString * _Nonnull _LaxE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3981);
}
// Passport.Language.tk
NSString * _Nonnull _LaxF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3982);
}
// Passport.Language.tr
NSString * _Nonnull _LaxG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3983);
}
// Passport.Language.uk
NSString * _Nonnull _LaxH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3984);
}
// Passport.Language.uz
NSString * _Nonnull _LaxI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3985);
}
// Passport.Language.vi
NSString * _Nonnull _LaxJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3986);
}
// Passport.NotLoggedInMessage
NSString * _Nonnull _LaxK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3987);
}
// Passport.PassportInformation
NSString * _Nonnull _LaxL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3988);
}
// Passport.PasswordCompleteSetup
NSString * _Nonnull _LaxM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3989);
}
// Passport.PasswordCreate
NSString * _Nonnull _LaxN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3990);
}
// Passport.PasswordDescription
NSString * _Nonnull _LaxO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3991);
}
// Passport.PasswordHelp
NSString * _Nonnull _LaxP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3992);
}
// Passport.PasswordNext
NSString * _Nonnull _LaxQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3993);
}
// Passport.PasswordPlaceholder
NSString * _Nonnull _LaxR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3994);
}
// Passport.PasswordReset
NSString * _Nonnull _LaxS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3995);
}
// Passport.Phone.Delete
NSString * _Nonnull _LaxT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3996);
}
// Passport.Phone.EnterOtherNumber
NSString * _Nonnull _LaxU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3997);
}
// Passport.Phone.Help
NSString * _Nonnull _LaxV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3998);
}
// Passport.Phone.Title
NSString * _Nonnull _LaxW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 3999);
}
// Passport.Phone.UseTelegramNumber
_FormattedString * _Nonnull _LaxX(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4000, _0);
}
// Passport.Phone.UseTelegramNumberHelp
NSString * _Nonnull _LaxY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4001);
}
// Passport.PrivacyPolicy
_FormattedString * _Nonnull _LaxZ(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 4002, _0, _1);
}
// Passport.RequestHeader
_FormattedString * _Nonnull _Laya(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4003, _0);
}
// Passport.RequestedInformation
NSString * _Nonnull _Layb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4004);
}
// Passport.ScanPassport
NSString * _Nonnull _Layc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4005);
}
// Passport.ScanPassportHelp
NSString * _Nonnull _Layd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4006);
}
// Passport.Scans
NSString * _Nonnull _Laye(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 4007, value);
}
// Passport.Scans.ScanIndex
_FormattedString * _Nonnull _Layf(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4008, _0);
}
// Passport.Scans.Upload
NSString * _Nonnull _Layg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4009);
}
// Passport.Scans.UploadNew
NSString * _Nonnull _Layh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4010);
}
// Passport.ScansHeader
NSString * _Nonnull _Layi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4011);
}
// Passport.Title
NSString * _Nonnull _Layj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4012);
}
// Passport.UpdateRequiredError
NSString * _Nonnull _Layk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4013);
}
// PeerInfo.AddToContacts
NSString * _Nonnull _Layl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4014);
}
// PeerInfo.AdjustAutoDelete
NSString * _Nonnull _Laym(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4015);
}
// PeerInfo.AlertLeaveAction
NSString * _Nonnull _Layn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4016);
}
// PeerInfo.AllowedReactions.AllowAllChannelInfo
NSString * _Nonnull _Layo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4017);
}
// PeerInfo.AllowedReactions.AllowAllGroupInfo
NSString * _Nonnull _Layp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4018);
}
// PeerInfo.AllowedReactions.AllowAllText
NSString * _Nonnull _Layq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4019);
}
// PeerInfo.AllowedReactions.GroupOptionAllInfo
NSString * _Nonnull _Layr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4020);
}
// PeerInfo.AllowedReactions.GroupOptionNoInfo
NSString * _Nonnull _Lays(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4021);
}
// PeerInfo.AllowedReactions.GroupOptionSomeInfo
NSString * _Nonnull _Layt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4022);
}
// PeerInfo.AllowedReactions.OptionAllReactions
NSString * _Nonnull _Layu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4023);
}
// PeerInfo.AllowedReactions.OptionNoReactions
NSString * _Nonnull _Layv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4024);
}
// PeerInfo.AllowedReactions.OptionSomeReactions
NSString * _Nonnull _Layw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4025);
}
// PeerInfo.AllowedReactions.ReactionListHeader
NSString * _Nonnull _Layx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4026);
}
// PeerInfo.AllowedReactions.Title
NSString * _Nonnull _Layy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4027);
}
// PeerInfo.AutoDeleteDisable
NSString * _Nonnull _Layz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4028);
}
// PeerInfo.AutoDeleteInfo
NSString * _Nonnull _LayA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4029);
}
// PeerInfo.AutoDeleteSettingOther
NSString * _Nonnull _LayB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4030);
}
// PeerInfo.AutoremoveMessages
NSString * _Nonnull _LayC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4031);
}
// PeerInfo.AutoremoveMessagesDisabled
NSString * _Nonnull _LayD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4032);
}
// PeerInfo.BioExpand
NSString * _Nonnull _LayE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4033);
}
// PeerInfo.ButtonAddMember
NSString * _Nonnull _LayF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4034);
}
// PeerInfo.ButtonCall
NSString * _Nonnull _LayG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4035);
}
// PeerInfo.ButtonDiscuss
NSString * _Nonnull _LayH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4036);
}
// PeerInfo.ButtonLeave
NSString * _Nonnull _LayI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4037);
}
// PeerInfo.ButtonLiveStream
NSString * _Nonnull _LayJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4038);
}
// PeerInfo.ButtonMessage
NSString * _Nonnull _LayK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4039);
}
// PeerInfo.ButtonMore
NSString * _Nonnull _LayL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4040);
}
// PeerInfo.ButtonMute
NSString * _Nonnull _LayM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4041);
}
// PeerInfo.ButtonSearch
NSString * _Nonnull _LayN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4042);
}
// PeerInfo.ButtonStop
NSString * _Nonnull _LayO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4043);
}
// PeerInfo.ButtonUnmute
NSString * _Nonnull _LayP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4044);
}
// PeerInfo.ButtonVideoCall
NSString * _Nonnull _LayQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4045);
}
// PeerInfo.ButtonVoiceChat
NSString * _Nonnull _LayR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4046);
}
// PeerInfo.ChangeEmojiStatus
NSString * _Nonnull _LayS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4047);
}
// PeerInfo.ClearConfirmationGroup
_FormattedString * _Nonnull _LayT(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4048, _0);
}
// PeerInfo.ClearConfirmationUser
_FormattedString * _Nonnull _LayU(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4049, _0);
}
// PeerInfo.ClearMessages
NSString * _Nonnull _LayV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4050);
}
// PeerInfo.CustomizeNotifications
NSString * _Nonnull _LayW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4051);
}
// PeerInfo.DeleteChannelText
_FormattedString * _Nonnull _LayX(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4052, _0);
}
// PeerInfo.DeleteChannelTitle
NSString * _Nonnull _LayY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4053);
}
// PeerInfo.DeleteGroupText
_FormattedString * _Nonnull _LayZ(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4054, _0);
}
// PeerInfo.DeleteGroupTitle
NSString * _Nonnull _Laza(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4055);
}
// PeerInfo.DeleteToneText
_FormattedString * _Nonnull _Lazb(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4056, _0);
}
// PeerInfo.DeleteToneTitle
NSString * _Nonnull _Lazc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4057);
}
// PeerInfo.DisableSound
NSString * _Nonnull _Lazd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4058);
}
// PeerInfo.EnableAutoDelete
NSString * _Nonnull _Laze(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4059);
}
// PeerInfo.EnableSound
NSString * _Nonnull _Lazf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4060);
}
// PeerInfo.GiftPremium
NSString * _Nonnull _Lazg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4061);
}
// PeerInfo.GroupAboutItem
NSString * _Nonnull _Lazh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4062);
}
// PeerInfo.HideMembersLimitedParticipantCountText
NSString * _Nonnull _Lazi(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 4063, value);
}
// PeerInfo.HideMembersLimitedRights
NSString * _Nonnull _Lazj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4064);
}
// PeerInfo.LabelAllReactions
NSString * _Nonnull _Lazk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4065);
}
// PeerInfo.LeaveChannelText
_FormattedString * _Nonnull _Lazl(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4066, _0);
}
// PeerInfo.LeaveChannelTitle
NSString * _Nonnull _Lazm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4067);
}
// PeerInfo.LeaveGroupText
_FormattedString * _Nonnull _Lazn(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4068, _0);
}
// PeerInfo.LeaveGroupTitle
NSString * _Nonnull _Lazo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4069);
}
// PeerInfo.MuteFor
NSString * _Nonnull _Lazp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4070);
}
// PeerInfo.MuteForCustom
NSString * _Nonnull _Lazq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4071);
}
// PeerInfo.MuteForever
NSString * _Nonnull _Lazr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4072);
}
// PeerInfo.NotificationMemberAdded
_FormattedString * _Nonnull _Lazs(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4073, _0);
}
// PeerInfo.NotificationMultipleMembersAdded
NSString * _Nonnull _Lazt(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 4074, value);
}
// PeerInfo.NotificationsCustomize
NSString * _Nonnull _Lazu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4075);
}
// PeerInfo.OptionTopics
NSString * _Nonnull _Lazv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4076);
}
// PeerInfo.OptionTopicsText
NSString * _Nonnull _Lazw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4077);
}
// PeerInfo.PaneAudio
NSString * _Nonnull _Lazx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4078);
}
// PeerInfo.PaneFiles
NSString * _Nonnull _Lazy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4079);
}
// PeerInfo.PaneGifs
NSString * _Nonnull _Lazz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4080);
}
// PeerInfo.PaneGroups
NSString * _Nonnull _LazA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4081);
}
// PeerInfo.PaneLinks
NSString * _Nonnull _LazB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4082);
}
// PeerInfo.PaneMedia
NSString * _Nonnull _LazC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4083);
}
// PeerInfo.PaneMembers
NSString * _Nonnull _LazD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4084);
}
// PeerInfo.PaneVoiceAndVideo
NSString * _Nonnull _LazE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4085);
}
// PeerInfo.PrivateShareLinkInfo
NSString * _Nonnull _LazF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4086);
}
// PeerInfo.QRCode.Title
NSString * _Nonnull _LazG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4087);
}
// PeerInfo.Reactions
NSString * _Nonnull _LazH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4088);
}
// PeerInfo.ReactionsDisabled
NSString * _Nonnull _LazI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4089);
}
// PeerInfo.ReportProfilePhoto
NSString * _Nonnull _LazJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4090);
}
// PeerInfo.ReportProfileVideo
NSString * _Nonnull _LazK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4091);
}
// PeerInfo.SetEmojiStatus
NSString * _Nonnull _LazL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4092);
}
// PeerInfo.TooltipMutedFor
_FormattedString * _Nonnull _LazM(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4093, _0);
}
// PeerInfo.TooltipMutedForever
NSString * _Nonnull _LazN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4094);
}
// PeerInfo.TooltipMutedUntil
_FormattedString * _Nonnull _LazO(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4095, _0);
}
// PeerInfo.TooltipSoundDisabled
NSString * _Nonnull _LazP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4096);
}
// PeerInfo.TooltipSoundEnabled
NSString * _Nonnull _LazQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4097);
}
// PeerInfo.TooltipUnmuted
NSString * _Nonnull _LazR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4098);
}
// PeerInfo.TopicHeaderLocation
_FormattedString * _Nonnull _LazS(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4099, _0);
}
// PeerInfo.TopicIconInfoText
_FormattedString * _Nonnull _LazT(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4100, _0);
}
// PeerInfo.TopicNotificationExceptions
NSString * _Nonnull _LazU(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 4101, value);
}
// PeerInfo.TopicsLimitedDiscussionGroups
NSString * _Nonnull _LazV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4102);
}
// PeerInfo.TopicsLimitedParticipantCountText
NSString * _Nonnull _LazW(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 4103, value);
}
// PeerSelection.ImportIntoNewGroup
NSString * _Nonnull _LazX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4104);
}
// PeerStatusExpiration.AtDate
_FormattedString * _Nonnull _LazY(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4105, _0);
}
// PeerStatusExpiration.Hours
NSString * _Nonnull _LazZ(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 4106, value);
}
// PeerStatusExpiration.Minutes
NSString * _Nonnull _LaAa(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 4107, value);
}
// PeerStatusExpiration.TomorrowAt
_FormattedString * _Nonnull _LaAb(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4108, _0);
}
// PeerStatusSetup.NoTimerTitle
NSString * _Nonnull _LaAc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4109);
}
// PeopleNearby.CreateGroup
NSString * _Nonnull _LaAd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4110);
}
// PeopleNearby.Description
NSString * _Nonnull _LaAe(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4111);
}
// PeopleNearby.DiscoverDescription
NSString * _Nonnull _LaAf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4112);
}
// PeopleNearby.Groups
NSString * _Nonnull _LaAg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4113);
}
// PeopleNearby.MakeInvisible
NSString * _Nonnull _LaAh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4114);
}
// PeopleNearby.MakeVisible
NSString * _Nonnull _LaAi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4115);
}
// PeopleNearby.MakeVisibleDescription
NSString * _Nonnull _LaAj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4116);
}
// PeopleNearby.MakeVisibleTitle
NSString * _Nonnull _LaAk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4117);
}
// PeopleNearby.NoMembers
NSString * _Nonnull _LaAl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4118);
}
// PeopleNearby.ShowMorePeople
NSString * _Nonnull _LaAm(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 4119, value);
}
// PeopleNearby.Title
NSString * _Nonnull _LaAn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4120);
}
// PeopleNearby.Users
NSString * _Nonnull _LaAo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4121);
}
// PeopleNearby.UsersEmpty
NSString * _Nonnull _LaAp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4122);
}
// PeopleNearby.VisibleUntil
_FormattedString * _Nonnull _LaAq(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4123, _0);
}
// Permissions.CellularDataAllowInSettings.v0
NSString * _Nonnull _LaAr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4124);
}
// Permissions.CellularDataText.v0
NSString * _Nonnull _LaAs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4125);
}
// Permissions.CellularDataTitle.v0
NSString * _Nonnull _LaAt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4126);
}
// Permissions.ContactsAllow.v0
NSString * _Nonnull _LaAu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4127);
}
// Permissions.ContactsAllowInSettings.v0
NSString * _Nonnull _LaAv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4128);
}
// Permissions.ContactsText.v0
NSString * _Nonnull _LaAw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4129);
}
// Permissions.ContactsTitle.v0
NSString * _Nonnull _LaAx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4130);
}
// Permissions.NotificationsAllow.v0
NSString * _Nonnull _LaAy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4131);
}
// Permissions.NotificationsAllowInSettings.v0
NSString * _Nonnull _LaAz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4132);
}
// Permissions.NotificationsText.v0
NSString * _Nonnull _LaAA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4133);
}
// Permissions.NotificationsTitle.v0
NSString * _Nonnull _LaAB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4134);
}
// Permissions.NotificationsUnreachableText.v0
NSString * _Nonnull _LaAC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4135);
}
// Permissions.PeopleNearbyAllow.v0
NSString * _Nonnull _LaAD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4136);
}
// Permissions.PeopleNearbyAllowInSettings.v0
NSString * _Nonnull _LaAE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4137);
}
// Permissions.PeopleNearbyText.v0
NSString * _Nonnull _LaAF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4138);
}
// Permissions.PeopleNearbyTitle.v0
NSString * _Nonnull _LaAG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4139);
}
// Permissions.PrivacyPolicy
NSString * _Nonnull _LaAH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4140);
}
// Permissions.SiriAllow.v0
NSString * _Nonnull _LaAI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4141);
}
// Permissions.SiriAllowInSettings.v0
NSString * _Nonnull _LaAJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4142);
}
// Permissions.SiriText.v0
NSString * _Nonnull _LaAK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4143);
}
// Permissions.SiriTitle.v0
NSString * _Nonnull _LaAL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4144);
}
// Permissions.Skip
NSString * _Nonnull _LaAM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4145);
}
// PhoneLabel.Title
NSString * _Nonnull _LaAN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4146);
}
// PhoneNumberHelp.Alert
NSString * _Nonnull _LaAO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4147);
}
// PhoneNumberHelp.ChangeNumber
NSString * _Nonnull _LaAP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4148);
}
// PhoneNumberHelp.Help
NSString * _Nonnull _LaAQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4149);
}
// PhotoEditor.BlurToolLinear
NSString * _Nonnull _LaAR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4150);
}
// PhotoEditor.BlurToolOff
NSString * _Nonnull _LaAS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4151);
}
// PhotoEditor.BlurToolPortrait
NSString * _Nonnull _LaAT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4152);
}
// PhotoEditor.BlurToolRadial
NSString * _Nonnull _LaAU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4153);
}
// PhotoEditor.ContrastTool
NSString * _Nonnull _LaAV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4154);
}
// PhotoEditor.CropAspectRatioOriginal
NSString * _Nonnull _LaAW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4155);
}
// PhotoEditor.CropAspectRatioSquare
NSString * _Nonnull _LaAX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4156);
}
// PhotoEditor.CropAuto
NSString * _Nonnull _LaAY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4157);
}
// PhotoEditor.CropReset
NSString * _Nonnull _LaAZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4158);
}
// PhotoEditor.CurvesAll
NSString * _Nonnull _LaBa(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4159);
}
// PhotoEditor.CurvesBlue
NSString * _Nonnull _LaBb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4160);
}
// PhotoEditor.CurvesGreen
NSString * _Nonnull _LaBc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4161);
}
// PhotoEditor.CurvesRed
NSString * _Nonnull _LaBd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4162);
}
// PhotoEditor.CurvesTool
NSString * _Nonnull _LaBe(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4163);
}
// PhotoEditor.DiscardChanges
NSString * _Nonnull _LaBf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4164);
}
// PhotoEditor.EnhanceTool
NSString * _Nonnull _LaBg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4165);
}
// PhotoEditor.ExposureTool
NSString * _Nonnull _LaBh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4166);
}
// PhotoEditor.FadeTool
NSString * _Nonnull _LaBi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4167);
}
// PhotoEditor.GrainTool
NSString * _Nonnull _LaBj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4168);
}
// PhotoEditor.HighlightsTint
NSString * _Nonnull _LaBk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4169);
}
// PhotoEditor.HighlightsTool
NSString * _Nonnull _LaBl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4170);
}
// PhotoEditor.Original
NSString * _Nonnull _LaBm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4171);
}
// PhotoEditor.QualityHigh
NSString * _Nonnull _LaBn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4172);
}
// PhotoEditor.QualityLow
NSString * _Nonnull _LaBo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4173);
}
// PhotoEditor.QualityMedium
NSString * _Nonnull _LaBp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4174);
}
// PhotoEditor.QualityTool
NSString * _Nonnull _LaBq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4175);
}
// PhotoEditor.QualityVeryHigh
NSString * _Nonnull _LaBr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4176);
}
// PhotoEditor.QualityVeryLow
NSString * _Nonnull _LaBs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4177);
}
// PhotoEditor.SaturationTool
NSString * _Nonnull _LaBt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4178);
}
// PhotoEditor.SelectCoverFrame
NSString * _Nonnull _LaBu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4179);
}
// PhotoEditor.SelectCoverFrameSuggestion
NSString * _Nonnull _LaBv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4180);
}
// PhotoEditor.Set
NSString * _Nonnull _LaBw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4181);
}
// PhotoEditor.SetAsMyPhoto
NSString * _Nonnull _LaBx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4182);
}
// PhotoEditor.SetAsMyVideo
NSString * _Nonnull _LaBy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4183);
}
// PhotoEditor.ShadowsTint
NSString * _Nonnull _LaBz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4184);
}
// PhotoEditor.ShadowsTool
NSString * _Nonnull _LaBA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4185);
}
// PhotoEditor.SharpenTool
NSString * _Nonnull _LaBB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4186);
}
// PhotoEditor.SkinTool
NSString * _Nonnull _LaBC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4187);
}
// PhotoEditor.Skip
NSString * _Nonnull _LaBD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4188);
}
// PhotoEditor.TiltShift
NSString * _Nonnull _LaBE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4189);
}
// PhotoEditor.TintTool
NSString * _Nonnull _LaBF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4190);
}
// PhotoEditor.VignetteTool
NSString * _Nonnull _LaBG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4191);
}
// PhotoEditor.WarmthTool
NSString * _Nonnull _LaBH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4192);
}
// PlaybackSpeed.Normal
NSString * _Nonnull _LaBI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4193);
}
// PlaybackSpeed.Title
NSString * _Nonnull _LaBJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4194);
}
// PollResults.Collapse
NSString * _Nonnull _LaBK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4195);
}
// PollResults.ShowMore
NSString * _Nonnull _LaBL(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 4196, value);
}
// PollResults.Title
NSString * _Nonnull _LaBM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4197);
}
// Premium.AboutText
NSString * _Nonnull _LaBN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4198);
}
// Premium.AboutTitle
NSString * _Nonnull _LaBO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4199);
}
// Premium.AnimatedEmoji
NSString * _Nonnull _LaBP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4200);
}
// Premium.AnimatedEmoji.Proceed
NSString * _Nonnull _LaBQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4201);
}
// Premium.AnimatedEmojiInfo
NSString * _Nonnull _LaBR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4202);
}
// Premium.AnimatedEmojiStandaloneInfo
NSString * _Nonnull _LaBS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4203);
}
// Premium.Annual
NSString * _Nonnull _LaBT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4204);
}
// Premium.AppIcon
NSString * _Nonnull _LaBU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4205);
}
// Premium.AppIconInfo
NSString * _Nonnull _LaBV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4206);
}
// Premium.AppIconStandalone
NSString * _Nonnull _LaBW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4207);
}
// Premium.AppIconStandaloneInfo
NSString * _Nonnull _LaBX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4208);
}
// Premium.AppIcons.Proceed
NSString * _Nonnull _LaBY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4209);
}
// Premium.Avatar
NSString * _Nonnull _LaBZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4210);
}
// Premium.AvatarInfo
NSString * _Nonnull _LaCa(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4211);
}
// Premium.Badge
NSString * _Nonnull _LaCb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4212);
}
// Premium.BadgeInfo
NSString * _Nonnull _LaCc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4213);
}
// Premium.ChatManagement
NSString * _Nonnull _LaCd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4214);
}
// Premium.ChatManagement.Proceed
NSString * _Nonnull _LaCe(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4215);
}
// Premium.ChatManagementInfo
NSString * _Nonnull _LaCf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4216);
}
// Premium.ChatManagementStandaloneInfo
NSString * _Nonnull _LaCg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4217);
}
// Premium.CurrentPlan
NSString * _Nonnull _LaCh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4218);
}
// Premium.Description
NSString * _Nonnull _LaCi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4219);
}
// Premium.DoubledLimits
NSString * _Nonnull _LaCj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4220);
}
// Premium.DoubledLimitsInfo
NSString * _Nonnull _LaCk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4221);
}
// Premium.Emoji.Description
NSString * _Nonnull _LaCl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4222);
}
// Premium.Emoji.Proceed
NSString * _Nonnull _LaCm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4223);
}
// Premium.EmojiStatus
NSString * _Nonnull _LaCn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4224);
}
// Premium.EmojiStatusInfo
NSString * _Nonnull _LaCo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4225);
}
// Premium.EmojiStatusShortTitle
_FormattedString * _Nonnull _LaCp(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4226, _0);
}
// Premium.EmojiStatusText
NSString * _Nonnull _LaCq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4227);
}
// Premium.EmojiStatusTitle
_FormattedString * _Nonnull _LaCr(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 4228, _0, _1);
}
// Premium.FasterSpeed
NSString * _Nonnull _LaCs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4229);
}
// Premium.FasterSpeed.Proceed
NSString * _Nonnull _LaCt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4230);
}
// Premium.FasterSpeedInfo
NSString * _Nonnull _LaCu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4231);
}
// Premium.FasterSpeedStandaloneInfo
NSString * _Nonnull _LaCv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4232);
}
// Premium.FileTooLarge
NSString * _Nonnull _LaCw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4233);
}
// Premium.Free
NSString * _Nonnull _LaCx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4234);
}
// Premium.Gift.Description
_FormattedString * _Nonnull _LaCy(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4235, _0);
}
// Premium.Gift.GiftSubscription
_FormattedString * _Nonnull _LaCz(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4236, _0);
}
// Premium.Gift.Info
NSString * _Nonnull _LaCA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4237);
}
// Premium.Gift.Months
NSString * _Nonnull _LaCB(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 4238, value);
}
// Premium.Gift.Title
NSString * _Nonnull _LaCC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4239);
}
// Premium.Gift.Years
NSString * _Nonnull _LaCD(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 4240, value);
}
// Premium.GiftedDescription
NSString * _Nonnull _LaCE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4241);
}
// Premium.GiftedDescriptionYou
NSString * _Nonnull _LaCF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4242);
}
// Premium.GiftedTitle
NSString * _Nonnull _LaCG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4243);
}
// Premium.GiftedTitle.12Month
_FormattedString * _Nonnull _LaCH(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4244, _0);
}
// Premium.GiftedTitle.3Month
_FormattedString * _Nonnull _LaCI(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4245, _0);
}
// Premium.GiftedTitle.6Month
_FormattedString * _Nonnull _LaCJ(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4246, _0);
}
// Premium.GiftedTitleYou.12Month
_FormattedString * _Nonnull _LaCK(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4247, _0);
}
// Premium.GiftedTitleYou.3Month
_FormattedString * _Nonnull _LaCL(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4248, _0);
}
// Premium.GiftedTitleYou.6Month
_FormattedString * _Nonnull _LaCM(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4249, _0);
}
// Premium.IncreaseLimit
NSString * _Nonnull _LaCN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4250);
}
// Premium.InfiniteReactions
NSString * _Nonnull _LaCO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4251);
}
// Premium.InfiniteReactionsInfo
NSString * _Nonnull _LaCP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4252);
}
// Premium.LimitReached
NSString * _Nonnull _LaCQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4253);
}
// Premium.Limits.Accounts
NSString * _Nonnull _LaCR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4254);
}
// Premium.Limits.AccountsInfo
NSString * _Nonnull _LaCS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4255);
}
// Premium.Limits.Bio
NSString * _Nonnull _LaCT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4256);
}
// Premium.Limits.BioInfo
NSString * _Nonnull _LaCU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4257);
}
// Premium.Limits.Captions
NSString * _Nonnull _LaCV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4258);
}
// Premium.Limits.CaptionsInfo
NSString * _Nonnull _LaCW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4259);
}
// Premium.Limits.ChatsPerFolder
NSString * _Nonnull _LaCX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4260);
}
// Premium.Limits.ChatsPerFolderInfo
NSString * _Nonnull _LaCY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4261);
}
// Premium.Limits.FavedStickers
NSString * _Nonnull _LaCZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4262);
}
// Premium.Limits.FavedStickersInfo
NSString * _Nonnull _LaDa(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4263);
}
// Premium.Limits.Folders
NSString * _Nonnull _LaDb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4264);
}
// Premium.Limits.FoldersInfo
NSString * _Nonnull _LaDc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4265);
}
// Premium.Limits.GroupsAndChannels
NSString * _Nonnull _LaDd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4266);
}
// Premium.Limits.GroupsAndChannelsInfo
NSString * _Nonnull _LaDe(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4267);
}
// Premium.Limits.PinnedChats
NSString * _Nonnull _LaDf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4268);
}
// Premium.Limits.PinnedChatsInfo
NSString * _Nonnull _LaDg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4269);
}
// Premium.Limits.PublicLinks
NSString * _Nonnull _LaDh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4270);
}
// Premium.Limits.PublicLinksInfo
NSString * _Nonnull _LaDi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4271);
}
// Premium.Limits.SavedGifs
NSString * _Nonnull _LaDj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4272);
}
// Premium.Limits.SavedGifsInfo
NSString * _Nonnull _LaDk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4273);
}
// Premium.Limits.Title
NSString * _Nonnull _LaDl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4274);
}
// Premium.MaxAccountsFinalText
_FormattedString * _Nonnull _LaDm(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4275, _0);
}
// Premium.MaxAccountsNoPremiumText
_FormattedString * _Nonnull _LaDn(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4276, _0);
}
// Premium.MaxAccountsText
_FormattedString * _Nonnull _LaDo(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4277, _0);
}
// Premium.MaxChatsInFolderFinalText
_FormattedString * _Nonnull _LaDp(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4278, _0);
}
// Premium.MaxChatsInFolderNoPremiumText
_FormattedString * _Nonnull _LaDq(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4279, _0);
}
// Premium.MaxChatsInFolderText
_FormattedString * _Nonnull _LaDr(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 4280, _0, _1);
}
// Premium.MaxFavedStickersFinalText
NSString * _Nonnull _LaDs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4281);
}
// Premium.MaxFavedStickersText
_FormattedString * _Nonnull _LaDt(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4282, _0);
}
// Premium.MaxFavedStickersTitle
_FormattedString * _Nonnull _LaDu(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4283, _0);
}
// Premium.MaxFileSizeFinalText
_FormattedString * _Nonnull _LaDv(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4284, _0);
}
// Premium.MaxFileSizeNoPremiumText
_FormattedString * _Nonnull _LaDw(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4285, _0);
}
// Premium.MaxFileSizeText
_FormattedString * _Nonnull _LaDx(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4286, _0);
}
// Premium.MaxFoldersCountFinalText
_FormattedString * _Nonnull _LaDy(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4287, _0);
}
// Premium.MaxFoldersCountNoPremiumText
_FormattedString * _Nonnull _LaDz(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4288, _0);
}
// Premium.MaxFoldersCountText
_FormattedString * _Nonnull _LaDA(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 4289, _0, _1);
}
// Premium.MaxPinsFinalText
_FormattedString * _Nonnull _LaDB(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4290, _0);
}
// Premium.MaxPinsNoPremiumText
_FormattedString * _Nonnull _LaDC(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4291, _0);
}
// Premium.MaxPinsText
_FormattedString * _Nonnull _LaDD(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 4292, _0, _1);
}
// Premium.MaxSavedGifsFinalText
NSString * _Nonnull _LaDE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4293);
}
// Premium.MaxSavedGifsText
_FormattedString * _Nonnull _LaDF(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4294, _0);
}
// Premium.MaxSavedGifsTitle
_FormattedString * _Nonnull _LaDG(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4295, _0);
}
// Premium.Monthly
NSString * _Nonnull _LaDH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4296);
}
// Premium.NoAds
NSString * _Nonnull _LaDI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4297);
}
// Premium.NoAds.Proceed
NSString * _Nonnull _LaDJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4298);
}
// Premium.NoAdsInfo
NSString * _Nonnull _LaDK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4299);
}
// Premium.NoAdsStandaloneInfo
NSString * _Nonnull _LaDL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4300);
}
// Premium.PersonalDescription
NSString * _Nonnull _LaDM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4301);
}
// Premium.PersonalTitle
_FormattedString * _Nonnull _LaDN(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4302, _0);
}
// Premium.Premium
NSString * _Nonnull _LaDO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4303);
}
// Premium.PricePerMonth
_FormattedString * _Nonnull _LaDP(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4304, _0);
}
// Premium.PricePerYear
_FormattedString * _Nonnull _LaDQ(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4305, _0);
}
// Premium.Purchase.ErrorCantMakePayments
NSString * _Nonnull _LaDR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4306);
}
// Premium.Purchase.ErrorNetwork
NSString * _Nonnull _LaDS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4307);
}
// Premium.Purchase.ErrorNotAllowed
NSString * _Nonnull _LaDT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4308);
}
// Premium.Purchase.ErrorUnknown
NSString * _Nonnull _LaDU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4309);
}
// Premium.Purchase.OnlyOneSubscriptionAllowed
NSString * _Nonnull _LaDV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4310);
}
// Premium.Reactions
NSString * _Nonnull _LaDW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4311);
}
// Premium.Reactions.Proceed
NSString * _Nonnull _LaDX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4312);
}
// Premium.ReactionsInfo
NSString * _Nonnull _LaDY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4313);
}
// Premium.ReactionsStandalone
NSString * _Nonnull _LaDZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4314);
}
// Premium.ReactionsStandaloneInfo
NSString * _Nonnull _LaEa(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4315);
}
// Premium.Restore.ErrorUnknown
NSString * _Nonnull _LaEb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4316);
}
// Premium.Restore.Success
NSString * _Nonnull _LaEc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4317);
}
// Premium.Semiannual
NSString * _Nonnull _LaEd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4318);
}
// Premium.Stickers
NSString * _Nonnull _LaEe(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4319);
}
// Premium.Stickers.Description
NSString * _Nonnull _LaEf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4320);
}
// Premium.Stickers.Proceed
NSString * _Nonnull _LaEg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4321);
}
// Premium.StickersInfo
NSString * _Nonnull _LaEh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4322);
}
// Premium.SubscribeFor
_FormattedString * _Nonnull _LaEi(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4323, _0);
}
// Premium.SubscribeForAnnual
_FormattedString * _Nonnull _LaEj(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4324, _0);
}
// Premium.SubscribedDescription
NSString * _Nonnull _LaEk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4325);
}
// Premium.SubscribedTitle
NSString * _Nonnull _LaEl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4326);
}
// Premium.Terms
NSString * _Nonnull _LaEm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4327);
}
// Premium.Title
NSString * _Nonnull _LaEn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4328);
}
// Premium.Translation
NSString * _Nonnull _LaEo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4329);
}
// Premium.Translation.Proceed
NSString * _Nonnull _LaEp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4330);
}
// Premium.TranslationInfo
NSString * _Nonnull _LaEq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4331);
}
// Premium.TranslationStandaloneInfo
NSString * _Nonnull _LaEr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4332);
}
// Premium.UpgradeDescription
NSString * _Nonnull _LaEs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4333);
}
// Premium.UpgradeFor
_FormattedString * _Nonnull _LaEt(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4334, _0);
}
// Premium.UpgradeForAnnual
_FormattedString * _Nonnull _LaEu(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4335, _0);
}
// Premium.UploadSize
NSString * _Nonnull _LaEv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4336);
}
// Premium.UploadSizeInfo
NSString * _Nonnull _LaEw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4337);
}
// Premium.VoiceToText
NSString * _Nonnull _LaEx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4338);
}
// Premium.VoiceToTextInfo
NSString * _Nonnull _LaEy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4339);
}
// Premium.VoiceToTextStandaloneInfo
NSString * _Nonnull _LaEz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4340);
}
// Presence.online
NSString * _Nonnull _LaEA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4341);
}
// Preview.CopyAddress
NSString * _Nonnull _LaEB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4342);
}
// Preview.DeleteGif
NSString * _Nonnull _LaEC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4343);
}
// Preview.DeletePhoto
NSString * _Nonnull _LaED(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4344);
}
// Preview.OpenInInstagram
NSString * _Nonnull _LaEE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4345);
}
// Preview.SaveGif
NSString * _Nonnull _LaEF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4346);
}
// Preview.SaveToCameraRoll
NSString * _Nonnull _LaEG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4347);
}
// Privacy.AddNewPeer
NSString * _Nonnull _LaEH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4348);
}
// Privacy.Calls
NSString * _Nonnull _LaEI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4349);
}
// Privacy.Calls.AlwaysAllow
NSString * _Nonnull _LaEJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4350);
}
// Privacy.Calls.AlwaysAllow.Placeholder
NSString * _Nonnull _LaEK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4351);
}
// Privacy.Calls.AlwaysAllow.Title
NSString * _Nonnull _LaEL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4352);
}
// Privacy.Calls.CustomHelp
NSString * _Nonnull _LaEM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4353);
}
// Privacy.Calls.CustomShareHelp
NSString * _Nonnull _LaEN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4354);
}
// Privacy.Calls.Integration
NSString * _Nonnull _LaEO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4355);
}
// Privacy.Calls.IntegrationHelp
NSString * _Nonnull _LaEP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4356);
}
// Privacy.Calls.NeverAllow
NSString * _Nonnull _LaEQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4357);
}
// Privacy.Calls.NeverAllow.Placeholder
NSString * _Nonnull _LaER(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4358);
}
// Privacy.Calls.NeverAllow.Title
NSString * _Nonnull _LaES(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4359);
}
// Privacy.Calls.P2P
NSString * _Nonnull _LaET(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4360);
}
// Privacy.Calls.P2PAlways
NSString * _Nonnull _LaEU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4361);
}
// Privacy.Calls.P2PContacts
NSString * _Nonnull _LaEV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4362);
}
// Privacy.Calls.P2PHelp
NSString * _Nonnull _LaEW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4363);
}
// Privacy.Calls.P2PNever
NSString * _Nonnull _LaEX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4364);
}
// Privacy.Calls.WhoCanCallMe
NSString * _Nonnull _LaEY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4365);
}
// Privacy.ChatsTitle
NSString * _Nonnull _LaEZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4366);
}
// Privacy.ContactsReset
NSString * _Nonnull _LaFa(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4367);
}
// Privacy.ContactsReset.ContactsDeleted
NSString * _Nonnull _LaFb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4368);
}
// Privacy.ContactsResetConfirmation
NSString * _Nonnull _LaFc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4369);
}
// Privacy.ContactsSync
NSString * _Nonnull _LaFd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4370);
}
// Privacy.ContactsSyncHelp
NSString * _Nonnull _LaFe(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4371);
}
// Privacy.ContactsTitle
NSString * _Nonnull _LaFf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4372);
}
// Privacy.DeleteDrafts
NSString * _Nonnull _LaFg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4373);
}
// Privacy.DeleteDrafts.DraftsDeleted
NSString * _Nonnull _LaFh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4374);
}
// Privacy.Exceptions
NSString * _Nonnull _LaFi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4375);
}
// Privacy.Exceptions.DeleteAll
NSString * _Nonnull _LaFj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4376);
}
// Privacy.Exceptions.DeleteAllConfirmation
NSString * _Nonnull _LaFk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4377);
}
// Privacy.Exceptions.DeleteAllExceptions
NSString * _Nonnull _LaFl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4378);
}
// Privacy.ExceptionsCount
NSString * _Nonnull _LaFm(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 4379, value);
}
// Privacy.Forwards
NSString * _Nonnull _LaFn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4380);
}
// Privacy.Forwards.AlwaysAllow.Title
NSString * _Nonnull _LaFo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4381);
}
// Privacy.Forwards.AlwaysLink
NSString * _Nonnull _LaFp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4382);
}
// Privacy.Forwards.CustomHelp
NSString * _Nonnull _LaFq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4383);
}
// Privacy.Forwards.LinkIfAllowed
NSString * _Nonnull _LaFr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4384);
}
// Privacy.Forwards.NeverAllow.Title
NSString * _Nonnull _LaFs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4385);
}
// Privacy.Forwards.NeverLink
NSString * _Nonnull _LaFt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4386);
}
// Privacy.Forwards.Preview
NSString * _Nonnull _LaFu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4387);
}
// Privacy.Forwards.PreviewMessageText
NSString * _Nonnull _LaFv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4388);
}
// Privacy.Forwards.WhoCanForward
NSString * _Nonnull _LaFw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4389);
}
// Privacy.GroupsAndChannels
NSString * _Nonnull _LaFx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4390);
}
// Privacy.GroupsAndChannels.AlwaysAllow
NSString * _Nonnull _LaFy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4391);
}
// Privacy.GroupsAndChannels.AlwaysAllow.Placeholder
NSString * _Nonnull _LaFz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4392);
}
// Privacy.GroupsAndChannels.AlwaysAllow.Title
NSString * _Nonnull _LaFA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4393);
}
// Privacy.GroupsAndChannels.CustomHelp
NSString * _Nonnull _LaFB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4394);
}
// Privacy.GroupsAndChannels.CustomShareHelp
NSString * _Nonnull _LaFC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4395);
}
// Privacy.GroupsAndChannels.InviteToChannelError
_FormattedString * _Nonnull _LaFD(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 4396, _0, _1);
}
// Privacy.GroupsAndChannels.InviteToChannelMultipleError
NSString * _Nonnull _LaFE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4397);
}
// Privacy.GroupsAndChannels.InviteToGroupError
_FormattedString * _Nonnull _LaFF(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 4398, _0, _1);
}
// Privacy.GroupsAndChannels.NeverAllow
NSString * _Nonnull _LaFG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4399);
}
// Privacy.GroupsAndChannels.NeverAllow.Placeholder
NSString * _Nonnull _LaFH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4400);
}
// Privacy.GroupsAndChannels.NeverAllow.Title
NSString * _Nonnull _LaFI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4401);
}
// Privacy.GroupsAndChannels.WhoCanAddMe
NSString * _Nonnull _LaFJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4402);
}
// Privacy.PaymentsClear.AllInfoCleared
NSString * _Nonnull _LaFK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4403);
}
// Privacy.PaymentsClear.PaymentInfo
NSString * _Nonnull _LaFL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4404);
}
// Privacy.PaymentsClear.PaymentInfoCleared
NSString * _Nonnull _LaFM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4405);
}
// Privacy.PaymentsClear.ShippingInfo
NSString * _Nonnull _LaFN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4406);
}
// Privacy.PaymentsClear.ShippingInfoCleared
NSString * _Nonnull _LaFO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4407);
}
// Privacy.PaymentsClearInfo
NSString * _Nonnull _LaFP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4408);
}
// Privacy.PaymentsClearInfoDoneHelp
NSString * _Nonnull _LaFQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4409);
}
// Privacy.PaymentsClearInfoHelp
NSString * _Nonnull _LaFR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4410);
}
// Privacy.PaymentsTitle
NSString * _Nonnull _LaFS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4411);
}
// Privacy.PhoneNumber
NSString * _Nonnull _LaFT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4412);
}
// Privacy.ProfilePhoto
NSString * _Nonnull _LaFU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4413);
}
// Privacy.ProfilePhoto.AlwaysShareWith.Title
NSString * _Nonnull _LaFV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4414);
}
// Privacy.ProfilePhoto.CustomHelp
NSString * _Nonnull _LaFW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4415);
}
// Privacy.ProfilePhoto.CustomOverrideAddInfo
NSString * _Nonnull _LaFX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4416);
}
// Privacy.ProfilePhoto.CustomOverrideBothInfo
NSString * _Nonnull _LaFY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4417);
}
// Privacy.ProfilePhoto.CustomOverrideInfo
NSString * _Nonnull _LaFZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4418);
}
// Privacy.ProfilePhoto.NeverShareWith.Title
NSString * _Nonnull _LaGa(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4419);
}
// Privacy.ProfilePhoto.PublicPhotoInfo
NSString * _Nonnull _LaGb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4420);
}
// Privacy.ProfilePhoto.PublicPhotoSuccess
NSString * _Nonnull _LaGc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4421);
}
// Privacy.ProfilePhoto.PublicVideoSuccess
NSString * _Nonnull _LaGd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4422);
}
// Privacy.ProfilePhoto.RemovePublicPhoto
NSString * _Nonnull _LaGe(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4423);
}
// Privacy.ProfilePhoto.RemovePublicVideo
NSString * _Nonnull _LaGf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4424);
}
// Privacy.ProfilePhoto.SetPublicPhoto
NSString * _Nonnull _LaGg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4425);
}
// Privacy.ProfilePhoto.UpdatePublicPhoto
NSString * _Nonnull _LaGh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4426);
}
// Privacy.ProfilePhoto.WhoCanSeeMyPhoto
NSString * _Nonnull _LaGi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4427);
}
// Privacy.SecretChatsLinkPreviews
NSString * _Nonnull _LaGj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4428);
}
// Privacy.SecretChatsLinkPreviewsHelp
NSString * _Nonnull _LaGk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4429);
}
// Privacy.SecretChatsTitle
NSString * _Nonnull _LaGl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4430);
}
// Privacy.TopPeers
NSString * _Nonnull _LaGm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4431);
}
// Privacy.TopPeersDelete
NSString * _Nonnull _LaGn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4432);
}
// Privacy.TopPeersHelp
NSString * _Nonnull _LaGo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4433);
}
// Privacy.TopPeersWarning
NSString * _Nonnull _LaGp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4434);
}
// Privacy.VoiceMessages
NSString * _Nonnull _LaGq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4435);
}
// Privacy.VoiceMessages.AlwaysAllow.Title
NSString * _Nonnull _LaGr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4436);
}
// Privacy.VoiceMessages.CustomHelp
NSString * _Nonnull _LaGs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4437);
}
// Privacy.VoiceMessages.CustomShareHelp
NSString * _Nonnull _LaGt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4438);
}
// Privacy.VoiceMessages.NeverAllow.Title
NSString * _Nonnull _LaGu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4439);
}
// Privacy.VoiceMessages.Tooltip
NSString * _Nonnull _LaGv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4440);
}
// Privacy.VoiceMessages.WhoCanSend
NSString * _Nonnull _LaGw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4441);
}
// PrivacyLastSeenSettings.AddUsers
NSString * _Nonnull _LaGx(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 4442, value);
}
// PrivacyLastSeenSettings.AlwaysShareWith
NSString * _Nonnull _LaGy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4443);
}
// PrivacyLastSeenSettings.AlwaysShareWith.Placeholder
NSString * _Nonnull _LaGz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4444);
}
// PrivacyLastSeenSettings.AlwaysShareWith.Title
NSString * _Nonnull _LaGA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4445);
}
// PrivacyLastSeenSettings.CustomHelp
NSString * _Nonnull _LaGB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4446);
}
// PrivacyLastSeenSettings.CustomShareSettings.Delete
NSString * _Nonnull _LaGC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4447);
}
// PrivacyLastSeenSettings.CustomShareSettingsHelp
NSString * _Nonnull _LaGD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4448);
}
// PrivacyLastSeenSettings.EmpryUsersPlaceholder
NSString * _Nonnull _LaGE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4449);
}
// PrivacyLastSeenSettings.GroupsAndChannelsHelp
NSString * _Nonnull _LaGF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4450);
}
// PrivacyLastSeenSettings.NeverShareWith
NSString * _Nonnull _LaGG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4451);
}
// PrivacyLastSeenSettings.NeverShareWith.Placeholder
NSString * _Nonnull _LaGH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4452);
}
// PrivacyLastSeenSettings.NeverShareWith.Title
NSString * _Nonnull _LaGI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4453);
}
// PrivacyLastSeenSettings.Title
NSString * _Nonnull _LaGJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4454);
}
// PrivacyLastSeenSettings.WhoCanSeeMyTimestamp
NSString * _Nonnull _LaGK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4455);
}
// PrivacyPhoneNumberSettings.CustomDisabledHelp
NSString * _Nonnull _LaGL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4456);
}
// PrivacyPhoneNumberSettings.CustomHelp
NSString * _Nonnull _LaGM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4457);
}
// PrivacyPhoneNumberSettings.CustomPublicLink
_FormattedString * _Nonnull _LaGN(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4458, _0);
}
// PrivacyPhoneNumberSettings.DiscoveryHeader
NSString * _Nonnull _LaGO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4459);
}
// PrivacyPhoneNumberSettings.WhoCanSeeMyPhoneNumber
NSString * _Nonnull _LaGP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4460);
}
// PrivacyPolicy.Accept
NSString * _Nonnull _LaGQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4461);
}
// PrivacyPolicy.AgeVerificationAgree
NSString * _Nonnull _LaGR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4462);
}
// PrivacyPolicy.AgeVerificationMessage
_FormattedString * _Nonnull _LaGS(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4463, _0);
}
// PrivacyPolicy.AgeVerificationTitle
NSString * _Nonnull _LaGT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4464);
}
// PrivacyPolicy.Decline
NSString * _Nonnull _LaGU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4465);
}
// PrivacyPolicy.DeclineDeclineAndDelete
NSString * _Nonnull _LaGV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4466);
}
// PrivacyPolicy.DeclineDeleteNow
NSString * _Nonnull _LaGW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4467);
}
// PrivacyPolicy.DeclineLastWarning
NSString * _Nonnull _LaGX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4468);
}
// PrivacyPolicy.DeclineMessage
NSString * _Nonnull _LaGY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4469);
}
// PrivacyPolicy.DeclineTitle
NSString * _Nonnull _LaGZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4470);
}
// PrivacyPolicy.Title
NSString * _Nonnull _LaHa(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4471);
}
// PrivacySettings.AuthSessions
NSString * _Nonnull _LaHb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4472);
}
// PrivacySettings.AutoArchive
NSString * _Nonnull _LaHc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4473);
}
// PrivacySettings.AutoArchiveInfo
NSString * _Nonnull _LaHd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4474);
}
// PrivacySettings.AutoArchiveTitle
NSString * _Nonnull _LaHe(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4475);
}
// PrivacySettings.BlockedPeersEmpty
NSString * _Nonnull _LaHf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4476);
}
// PrivacySettings.DataSettings
NSString * _Nonnull _LaHg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4477);
}
// PrivacySettings.DataSettingsHelp
NSString * _Nonnull _LaHh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4478);
}
// PrivacySettings.DeleteAccountHelp
NSString * _Nonnull _LaHi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4479);
}
// PrivacySettings.DeleteAccountIfAwayFor
NSString * _Nonnull _LaHj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4480);
}
// PrivacySettings.DeleteAccountNow
NSString * _Nonnull _LaHk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4481);
}
// PrivacySettings.DeleteAccountTitle
NSString * _Nonnull _LaHl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4482);
}
// PrivacySettings.LastSeen
NSString * _Nonnull _LaHm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4483);
}
// PrivacySettings.LastSeenContacts
NSString * _Nonnull _LaHn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4484);
}
// PrivacySettings.LastSeenContactsMinus
_FormattedString * _Nonnull _LaHo(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4485, _0);
}
// PrivacySettings.LastSeenContactsMinusPlus
_FormattedString * _Nonnull _LaHp(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 4486, _0, _1);
}
// PrivacySettings.LastSeenContactsPlus
_FormattedString * _Nonnull _LaHq(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4487, _0);
}
// PrivacySettings.LastSeenEverybody
NSString * _Nonnull _LaHr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4488);
}
// PrivacySettings.LastSeenEverybodyMinus
_FormattedString * _Nonnull _LaHs(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4489, _0);
}
// PrivacySettings.LastSeenNobody
NSString * _Nonnull _LaHt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4490);
}
// PrivacySettings.LastSeenNobodyPlus
_FormattedString * _Nonnull _LaHu(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4491, _0);
}
// PrivacySettings.LastSeenTitle
NSString * _Nonnull _LaHv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4492);
}
// PrivacySettings.LoginEmail
NSString * _Nonnull _LaHw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4493);
}
// PrivacySettings.LoginEmailAlertChange
NSString * _Nonnull _LaHx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4494);
}
// PrivacySettings.LoginEmailAlertText
NSString * _Nonnull _LaHy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4495);
}
// PrivacySettings.LoginEmailInfo
NSString * _Nonnull _LaHz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4496);
}
// PrivacySettings.Passcode
NSString * _Nonnull _LaHA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4497);
}
// PrivacySettings.PasscodeAndFaceId
NSString * _Nonnull _LaHB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4498);
}
// PrivacySettings.PasscodeAndTouchId
NSString * _Nonnull _LaHC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4499);
}
// PrivacySettings.PasscodeOff
NSString * _Nonnull _LaHD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4500);
}
// PrivacySettings.PasscodeOn
NSString * _Nonnull _LaHE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4501);
}
// PrivacySettings.PhoneNumber
NSString * _Nonnull _LaHF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4502);
}
// PrivacySettings.PrivacyTitle
NSString * _Nonnull _LaHG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4503);
}
// PrivacySettings.SecurityTitle
NSString * _Nonnull _LaHH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4504);
}
// PrivacySettings.Title
NSString * _Nonnull _LaHI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4505);
}
// PrivacySettings.TwoStepAuth
NSString * _Nonnull _LaHJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4506);
}
// PrivacySettings.WebSessions
NSString * _Nonnull _LaHK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4507);
}
// PrivateDataSettings.Title
NSString * _Nonnull _LaHL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4508);
}
// Profile.About
NSString * _Nonnull _LaHM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4509);
}
// Profile.AddToExisting
NSString * _Nonnull _LaHN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4510);
}
// Profile.AdditionalUsernames
_FormattedString * _Nonnull _LaHO(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4511, _0);
}
// Profile.BotInfo
NSString * _Nonnull _LaHP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4512);
}
// Profile.CreateEncryptedChatError
NSString * _Nonnull _LaHQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4513);
}
// Profile.CreateEncryptedChatOutdatedError
_FormattedString * _Nonnull _LaHR(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 4514, _0, _1);
}
// Profile.CreateNewContact
NSString * _Nonnull _LaHS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4515);
}
// Profile.EncryptionKey
NSString * _Nonnull _LaHT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4516);
}
// Profile.MessageLifetime1d
NSString * _Nonnull _LaHU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4517);
}
// Profile.MessageLifetime1h
NSString * _Nonnull _LaHV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4518);
}
// Profile.MessageLifetime1m
NSString * _Nonnull _LaHW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4519);
}
// Profile.MessageLifetime1w
NSString * _Nonnull _LaHX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4520);
}
// Profile.MessageLifetime2s
NSString * _Nonnull _LaHY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4521);
}
// Profile.MessageLifetime5s
NSString * _Nonnull _LaHZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4522);
}
// Profile.MessageLifetimeForever
NSString * _Nonnull _LaIa(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4523);
}
// Profile.ShareContactButton
NSString * _Nonnull _LaIb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4524);
}
// Profile.Username
NSString * _Nonnull _LaIc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4525);
}
// ProfilePhoto.MainPhoto
NSString * _Nonnull _LaId(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4526);
}
// ProfilePhoto.MainVideo
NSString * _Nonnull _LaIe(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4527);
}
// ProfilePhoto.OpenGallery
NSString * _Nonnull _LaIf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4528);
}
// ProfilePhoto.OpenInEditor
NSString * _Nonnull _LaIg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4529);
}
// ProfilePhoto.PublicPhoto
NSString * _Nonnull _LaIh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4530);
}
// ProfilePhoto.PublicVideo
NSString * _Nonnull _LaIi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4531);
}
// ProfilePhoto.SearchWeb
NSString * _Nonnull _LaIj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4532);
}
// ProfilePhoto.SetEmoji
NSString * _Nonnull _LaIk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4533);
}
// ProfilePhoto.SetMainPhoto
NSString * _Nonnull _LaIl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4534);
}
// ProfilePhoto.SetMainVideo
NSString * _Nonnull _LaIm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4535);
}
// Proxy.TooltipUnavailable
NSString * _Nonnull _LaIn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4536);
}
// ProxyServer.VoiceOver.Active
NSString * _Nonnull _LaIo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4537);
}
// QuickSend.Photos
NSString * _Nonnull _LaIp(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 4538, value);
}
// Replies.BlockAndDeleteRepliesActionTitle
NSString * _Nonnull _LaIq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4539);
}
// RepliesChat.DescriptionText
NSString * _Nonnull _LaIr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4540);
}
// Report.AdditionalDetailsPlaceholder
NSString * _Nonnull _LaIs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4541);
}
// Report.AdditionalDetailsText
NSString * _Nonnull _LaIt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4542);
}
// Report.Report
NSString * _Nonnull _LaIu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4543);
}
// Report.Succeed
NSString * _Nonnull _LaIv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4544);
}
// ReportGroupLocation.Report
NSString * _Nonnull _LaIw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4545);
}
// ReportGroupLocation.Text
NSString * _Nonnull _LaIx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4546);
}
// ReportGroupLocation.Title
NSString * _Nonnull _LaIy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4547);
}
// ReportPeer.AlertSuccess
NSString * _Nonnull _LaIz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4548);
}
// ReportPeer.ReasonChildAbuse
NSString * _Nonnull _LaIA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4549);
}
// ReportPeer.ReasonCopyright
NSString * _Nonnull _LaIB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4550);
}
// ReportPeer.ReasonFake
NSString * _Nonnull _LaIC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4551);
}
// ReportPeer.ReasonIllegalDrugs
NSString * _Nonnull _LaID(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4552);
}
// ReportPeer.ReasonOther
NSString * _Nonnull _LaIE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4553);
}
// ReportPeer.ReasonOther.Placeholder
NSString * _Nonnull _LaIF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4554);
}
// ReportPeer.ReasonOther.Send
NSString * _Nonnull _LaIG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4555);
}
// ReportPeer.ReasonOther.Title
NSString * _Nonnull _LaIH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4556);
}
// ReportPeer.ReasonPersonalDetails
NSString * _Nonnull _LaII(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4557);
}
// ReportPeer.ReasonPornography
NSString * _Nonnull _LaIJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4558);
}
// ReportPeer.ReasonSpam
NSString * _Nonnull _LaIK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4559);
}
// ReportPeer.ReasonViolence
NSString * _Nonnull _LaIL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4560);
}
// ReportPeer.Report
NSString * _Nonnull _LaIM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4561);
}
// ReportPeer.ReportReaction
NSString * _Nonnull _LaIN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4562);
}
// ReportSpam.DeleteThisChat
NSString * _Nonnull _LaIO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4563);
}
// RequestPeer.BotsAllEmpty
NSString * _Nonnull _LaIP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4564);
}
// RequestPeer.ChannelsAllEmpty
NSString * _Nonnull _LaIQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4565);
}
// RequestPeer.ChannelsEmpty
NSString * _Nonnull _LaIR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4566);
}
// RequestPeer.ChooseBotTitle
NSString * _Nonnull _LaIS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4567);
}
// RequestPeer.ChooseChannelTitle
NSString * _Nonnull _LaIT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4568);
}
// RequestPeer.ChooseGroupTitle
NSString * _Nonnull _LaIU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4569);
}
// RequestPeer.ChooseUserTitle
NSString * _Nonnull _LaIV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4570);
}
// RequestPeer.CreateNewChannel
NSString * _Nonnull _LaIW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4571);
}
// RequestPeer.CreateNewGroup
NSString * _Nonnull _LaIX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4572);
}
// RequestPeer.GroupsAllEmpty
NSString * _Nonnull _LaIY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4573);
}
// RequestPeer.GroupsEmpty
NSString * _Nonnull _LaIZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4574);
}
// RequestPeer.Requirement.Channel.CreatorOn
NSString * _Nonnull _LaJa(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4575);
}
// RequestPeer.Requirement.Channel.HasUsernameOff
NSString * _Nonnull _LaJb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4576);
}
// RequestPeer.Requirement.Channel.HasUsernameOn
NSString * _Nonnull _LaJc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4577);
}
// RequestPeer.Requirement.Channel.Rights
_FormattedString * _Nonnull _LaJd(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4578, _0);
}
// RequestPeer.Requirement.Channel.Rights.AddAdmins
NSString * _Nonnull _LaJe(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4579);
}
// RequestPeer.Requirement.Channel.Rights.Anonymous
NSString * _Nonnull _LaJf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4580);
}
// RequestPeer.Requirement.Channel.Rights.Delete
NSString * _Nonnull _LaJg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4581);
}
// RequestPeer.Requirement.Channel.Rights.Edit
NSString * _Nonnull _LaJh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4582);
}
// RequestPeer.Requirement.Channel.Rights.Info
NSString * _Nonnull _LaJi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4583);
}
// RequestPeer.Requirement.Channel.Rights.Invite
NSString * _Nonnull _LaJj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4584);
}
// RequestPeer.Requirement.Channel.Rights.Pin
NSString * _Nonnull _LaJk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4585);
}
// RequestPeer.Requirement.Channel.Rights.Send
NSString * _Nonnull _LaJl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4586);
}
// RequestPeer.Requirement.Channel.Rights.Topics
NSString * _Nonnull _LaJm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4587);
}
// RequestPeer.Requirement.Channel.Rights.VideoChats
NSString * _Nonnull _LaJn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4588);
}
// RequestPeer.Requirement.Group.CreatorOn
NSString * _Nonnull _LaJo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4589);
}
// RequestPeer.Requirement.Group.ForumOff
NSString * _Nonnull _LaJp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4590);
}
// RequestPeer.Requirement.Group.ForumOn
NSString * _Nonnull _LaJq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4591);
}
// RequestPeer.Requirement.Group.HasUsernameOff
NSString * _Nonnull _LaJr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4592);
}
// RequestPeer.Requirement.Group.HasUsernameOn
NSString * _Nonnull _LaJs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4593);
}
// RequestPeer.Requirement.Group.ParticipantOn
NSString * _Nonnull _LaJt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4594);
}
// RequestPeer.Requirement.Group.Rights
_FormattedString * _Nonnull _LaJu(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4595, _0);
}
// RequestPeer.Requirement.Group.Rights.AddAdmins
NSString * _Nonnull _LaJv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4596);
}
// RequestPeer.Requirement.Group.Rights.Anonymous
NSString * _Nonnull _LaJw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4597);
}
// RequestPeer.Requirement.Group.Rights.Ban
NSString * _Nonnull _LaJx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4598);
}
// RequestPeer.Requirement.Group.Rights.Delete
NSString * _Nonnull _LaJy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4599);
}
// RequestPeer.Requirement.Group.Rights.Edit
NSString * _Nonnull _LaJz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4600);
}
// RequestPeer.Requirement.Group.Rights.Info
NSString * _Nonnull _LaJA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4601);
}
// RequestPeer.Requirement.Group.Rights.Invite
NSString * _Nonnull _LaJB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4602);
}
// RequestPeer.Requirement.Group.Rights.Pin
NSString * _Nonnull _LaJC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4603);
}
// RequestPeer.Requirement.Group.Rights.Send
NSString * _Nonnull _LaJD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4604);
}
// RequestPeer.Requirement.Group.Rights.Topics
NSString * _Nonnull _LaJE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4605);
}
// RequestPeer.Requirement.Group.Rights.VideoChats
NSString * _Nonnull _LaJF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4606);
}
// RequestPeer.Requirement.UserPremiumOff
NSString * _Nonnull _LaJG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4607);
}
// RequestPeer.Requirement.UserPremiumOn
NSString * _Nonnull _LaJH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4608);
}
// RequestPeer.Requirements
NSString * _Nonnull _LaJI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4609);
}
// RequestPeer.SelectionConfirmationInviteAdminText
_FormattedString * _Nonnull _LaJJ(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 4610, _0, _1);
}
// RequestPeer.SelectionConfirmationInviteText
_FormattedString * _Nonnull _LaJK(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 4611, _0, _1);
}
// RequestPeer.SelectionConfirmationInviteWithRightsText
_FormattedString * _Nonnull _LaJL(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2) {
    return getFormatted3(_self, 4612, _0, _1, _2);
}
// RequestPeer.SelectionConfirmationSend
NSString * _Nonnull _LaJM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4613);
}
// RequestPeer.SelectionConfirmationTitle
_FormattedString * _Nonnull _LaJN(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 4614, _0, _1);
}
// RequestPeer.UsersAllEmpty
NSString * _Nonnull _LaJO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4615);
}
// RequestPeer.UsersEmpty
NSString * _Nonnull _LaJP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4616);
}
// Resolve.ErrorNotFound
NSString * _Nonnull _LaJQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4617);
}
// SaveIncomingPhotosSettings.From
NSString * _Nonnull _LaJR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4618);
}
// SaveIncomingPhotosSettings.Title
NSString * _Nonnull _LaJS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4619);
}
// ScheduleLiveStream.ChannelText
_FormattedString * _Nonnull _LaJT(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4620, _0);
}
// ScheduleLiveStream.Title
NSString * _Nonnull _LaJU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4621);
}
// ScheduleVoiceChat.GroupText
_FormattedString * _Nonnull _LaJV(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4622, _0);
}
// ScheduleVoiceChat.ScheduleOn
_FormattedString * _Nonnull _LaJW(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 4623, _0, _1);
}
// ScheduleVoiceChat.ScheduleToday
_FormattedString * _Nonnull _LaJX(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4624, _0);
}
// ScheduleVoiceChat.ScheduleTomorrow
_FormattedString * _Nonnull _LaJY(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4625, _0);
}
// ScheduleVoiceChat.Title
NSString * _Nonnull _LaJZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4626);
}
// ScheduledIn.Days
NSString * _Nonnull _LaKa(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 4627, value);
}
// ScheduledIn.Hours
NSString * _Nonnull _LaKb(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 4628, value);
}
// ScheduledIn.Minutes
NSString * _Nonnull _LaKc(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 4629, value);
}
// ScheduledIn.Months
NSString * _Nonnull _LaKd(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 4630, value);
}
// ScheduledIn.Seconds
NSString * _Nonnull _LaKe(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 4631, value);
}
// ScheduledIn.Weeks
NSString * _Nonnull _LaKf(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 4632, value);
}
// ScheduledIn.Years
NSString * _Nonnull _LaKg(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 4633, value);
}
// ScheduledMessages.BotActionUnavailable
NSString * _Nonnull _LaKh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4634);
}
// ScheduledMessages.ClearAll
NSString * _Nonnull _LaKi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4635);
}
// ScheduledMessages.ClearAllConfirmation
NSString * _Nonnull _LaKj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4636);
}
// ScheduledMessages.Delete
NSString * _Nonnull _LaKk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4637);
}
// ScheduledMessages.DeleteMany
NSString * _Nonnull _LaKl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4638);
}
// ScheduledMessages.EditTime
NSString * _Nonnull _LaKm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4639);
}
// ScheduledMessages.EmptyPlaceholder
NSString * _Nonnull _LaKn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4640);
}
// ScheduledMessages.PollUnavailable
NSString * _Nonnull _LaKo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4641);
}
// ScheduledMessages.ReminderNotification
NSString * _Nonnull _LaKp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4642);
}
// ScheduledMessages.RemindersTitle
NSString * _Nonnull _LaKq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4643);
}
// ScheduledMessages.ScheduledDate
_FormattedString * _Nonnull _LaKr(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4644, _0);
}
// ScheduledMessages.ScheduledOnline
NSString * _Nonnull _LaKs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4645);
}
// ScheduledMessages.ScheduledToday
NSString * _Nonnull _LaKt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4646);
}
// ScheduledMessages.SendNow
NSString * _Nonnull _LaKu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4647);
}
// ScheduledMessages.Title
NSString * _Nonnull _LaKv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4648);
}
// SearchImages.NoImagesFound
NSString * _Nonnull _LaKw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4649);
}
// SearchImages.Title
NSString * _Nonnull _LaKx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4650);
}
// SecretChat.Title
NSString * _Nonnull _LaKy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4651);
}
// SecretGIF.NotViewedYet
_FormattedString * _Nonnull _LaKz(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4652, _0);
}
// SecretGif.Title
NSString * _Nonnull _LaKA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4653);
}
// SecretImage.NotViewedYet
_FormattedString * _Nonnull _LaKB(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4654, _0);
}
// SecretImage.Title
NSString * _Nonnull _LaKC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4655);
}
// SecretTimer.ImageDescription
NSString * _Nonnull _LaKD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4656);
}
// SecretTimer.VideoDescription
NSString * _Nonnull _LaKE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4657);
}
// SecretVideo.NotViewedYet
_FormattedString * _Nonnull _LaKF(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4658, _0);
}
// SecretVideo.Title
NSString * _Nonnull _LaKG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4659);
}
// ServiceMessage.GameScoreExtended
NSString * _Nonnull _LaKH(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 4660, value);
}
// ServiceMessage.GameScoreSelfExtended
NSString * _Nonnull _LaKI(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 4661, value);
}
// ServiceMessage.GameScoreSelfSimple
NSString * _Nonnull _LaKJ(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 4662, value);
}
// ServiceMessage.GameScoreSimple
NSString * _Nonnull _LaKK(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 4663, value);
}
// SetTimeoutFor.Days
NSString * _Nonnull _LaKL(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 4664, value);
}
// SetTimeoutFor.Hours
NSString * _Nonnull _LaKM(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 4665, value);
}
// SetTimeoutFor.Minutes
NSString * _Nonnull _LaKN(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 4666, value);
}
// Settings.About
NSString * _Nonnull _LaKO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4667);
}
// Settings.About.Help
NSString * _Nonnull _LaKP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4668);
}
// Settings.About.Title
NSString * _Nonnull _LaKQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4669);
}
// Settings.AboutEmpty
NSString * _Nonnull _LaKR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4670);
}
// Settings.AddAccount
NSString * _Nonnull _LaKS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4671);
}
// Settings.AddAnotherAccount
NSString * _Nonnull _LaKT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4672);
}
// Settings.AddAnotherAccount.Help
NSString * _Nonnull _LaKU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4673);
}
// Settings.AddAnotherAccount.PremiumHelp
NSString * _Nonnull _LaKV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4674);
}
// Settings.AddDevice
NSString * _Nonnull _LaKW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4675);
}
// Settings.AppLanguage
NSString * _Nonnull _LaKX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4676);
}
// Settings.AppLanguage.Unofficial
NSString * _Nonnull _LaKY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4677);
}
// Settings.Appearance
NSString * _Nonnull _LaKZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4678);
}
// Settings.AppleWatch
NSString * _Nonnull _LaLa(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4679);
}
// Settings.ApplyProxyAlert
_FormattedString * _Nonnull _LaLb(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 4680, _0, _1);
}
// Settings.ApplyProxyAlertCredentials
_FormattedString * _Nonnull _LaLc(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2, NSString * _Nonnull _3) {
    return getFormatted4(_self, 4681, _0, _1, _2, _3);
}
// Settings.ApplyProxyAlertEnable
NSString * _Nonnull _LaLd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4682);
}
// Settings.AutoDeleteInfo
NSString * _Nonnull _LaLe(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4683);
}
// Settings.AutoDeleteTitle
NSString * _Nonnull _LaLf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4684);
}
// Settings.AutosaveMediaAllMedia
_FormattedString * _Nonnull _LaLg(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4685, _0);
}
// Settings.AutosaveMediaNoPhoto
NSString * _Nonnull _LaLh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4686);
}
// Settings.AutosaveMediaNoVideo
NSString * _Nonnull _LaLi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4687);
}
// Settings.AutosaveMediaOff
NSString * _Nonnull _LaLj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4688);
}
// Settings.AutosaveMediaOn
NSString * _Nonnull _LaLk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4689);
}
// Settings.AutosaveMediaPhoto
NSString * _Nonnull _LaLl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4690);
}
// Settings.AutosaveMediaVideo
_FormattedString * _Nonnull _LaLm(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4691, _0);
}
// Settings.BlockedUsers
NSString * _Nonnull _LaLn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4692);
}
// Settings.CallSettings
NSString * _Nonnull _LaLo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4693);
}
// Settings.CancelUpload
NSString * _Nonnull _LaLp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4694);
}
// Settings.ChangePhoneNumber
NSString * _Nonnull _LaLq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4695);
}
// Settings.ChangeProfilePhoto
NSString * _Nonnull _LaLr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4696);
}
// Settings.ChatBackground
NSString * _Nonnull _LaLs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4697);
}
// Settings.ChatFolders
NSString * _Nonnull _LaLt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4698);
}
// Settings.ChatSettings
NSString * _Nonnull _LaLu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4699);
}
// Settings.ChatThemes
NSString * _Nonnull _LaLv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4700);
}
// Settings.CheckPasswordText
NSString * _Nonnull _LaLw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4701);
}
// Settings.CheckPasswordTitle
NSString * _Nonnull _LaLx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4702);
}
// Settings.CheckPhoneNumberFAQAnchor
NSString * _Nonnull _LaLy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4703);
}
// Settings.CheckPhoneNumberText
NSString * _Nonnull _LaLz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4704);
}
// Settings.CheckPhoneNumberTitle
_FormattedString * _Nonnull _LaLA(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4705, _0);
}
// Settings.Context.Logout
NSString * _Nonnull _LaLB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4706);
}
// Settings.CopyPhoneNumber
NSString * _Nonnull _LaLC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4707);
}
// Settings.CopyUsername
NSString * _Nonnull _LaLD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4708);
}
// Settings.Devices
NSString * _Nonnull _LaLE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4709);
}
// Settings.EditAccount
NSString * _Nonnull _LaLF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4710);
}
// Settings.EditPhoto
NSString * _Nonnull _LaLG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4711);
}
// Settings.EditVideo
NSString * _Nonnull _LaLH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4712);
}
// Settings.FAQ
NSString * _Nonnull _LaLI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4713);
}
// Settings.FAQ_Button
NSString * _Nonnull _LaLJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4714);
}
// Settings.FAQ_Intro
NSString * _Nonnull _LaLK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4715);
}
// Settings.FAQ_URL
NSString * _Nonnull _LaLL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4716);
}
// Settings.FrequentlyAskedQuestions
NSString * _Nonnull _LaLM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4717);
}
// Settings.KeepPassword
NSString * _Nonnull _LaLN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4718);
}
// Settings.KeepPhoneNumber
_FormattedString * _Nonnull _LaLO(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4719, _0);
}
// Settings.Logout
NSString * _Nonnull _LaLP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4720);
}
// Settings.LogoutConfirmationText
NSString * _Nonnull _LaLQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4721);
}
// Settings.LogoutConfirmationTitle
NSString * _Nonnull _LaLR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4722);
}
// Settings.NotificationsAndSounds
NSString * _Nonnull _LaLS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4723);
}
// Settings.Passport
NSString * _Nonnull _LaLT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4724);
}
// Settings.PauseMusicOnRecording
NSString * _Nonnull _LaLU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4725);
}
// Settings.PhoneNumber
NSString * _Nonnull _LaLV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4726);
}
// Settings.Premium
NSString * _Nonnull _LaLW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4727);
}
// Settings.PrivacyPolicy_URL
NSString * _Nonnull _LaLX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4728);
}
// Settings.PrivacySettings
NSString * _Nonnull _LaLY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4729);
}
// Settings.Proxy
NSString * _Nonnull _LaLZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4730);
}
// Settings.ProxyConnected
NSString * _Nonnull _LaMa(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4731);
}
// Settings.ProxyConnecting
NSString * _Nonnull _LaMb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4732);
}
// Settings.ProxyDisabled
NSString * _Nonnull _LaMc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4733);
}
// Settings.QuickReactionSetup.ChooseQuickReaction
NSString * _Nonnull _LaMd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4734);
}
// Settings.QuickReactionSetup.ChooseQuickReactionInfo
NSString * _Nonnull _LaMe(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4735);
}
// Settings.QuickReactionSetup.DemoHeader
NSString * _Nonnull _LaMf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4736);
}
// Settings.QuickReactionSetup.DemoInfo
NSString * _Nonnull _LaMg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4737);
}
// Settings.QuickReactionSetup.DemoMessageAuthor
NSString * _Nonnull _LaMh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4738);
}
// Settings.QuickReactionSetup.DemoMessageText
NSString * _Nonnull _LaMi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4739);
}
// Settings.QuickReactionSetup.NavigationTitle
NSString * _Nonnull _LaMj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4740);
}
// Settings.QuickReactionSetup.ReactionListHeader
NSString * _Nonnull _LaMk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4741);
}
// Settings.QuickReactionSetup.Title
NSString * _Nonnull _LaMl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4742);
}
// Settings.RaiseToListen
NSString * _Nonnull _LaMm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4743);
}
// Settings.RaiseToListenInfo
NSString * _Nonnull _LaMn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4744);
}
// Settings.RemoveConfirmation
NSString * _Nonnull _LaMo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4745);
}
// Settings.RemoveVideo
NSString * _Nonnull _LaMp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4746);
}
// Settings.SaveEditedPhotos
NSString * _Nonnull _LaMq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4747);
}
// Settings.SaveIncomingPhotos
NSString * _Nonnull _LaMr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4748);
}
// Settings.SaveToCameraRollInfo
NSString * _Nonnull _LaMs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4749);
}
// Settings.SaveToCameraRollSection
NSString * _Nonnull _LaMt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4750);
}
// Settings.SavedMessages
NSString * _Nonnull _LaMu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4751);
}
// Settings.Search
NSString * _Nonnull _LaMv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4752);
}
// Settings.SetNewProfilePhotoOrVideo
NSString * _Nonnull _LaMw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4753);
}
// Settings.SetProfilePhoto
NSString * _Nonnull _LaMx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4754);
}
// Settings.SetProfilePhotoOrVideo
NSString * _Nonnull _LaMy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4755);
}
// Settings.SetUsername
NSString * _Nonnull _LaMz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4756);
}
// Settings.SuggestSetupPasswordAction
NSString * _Nonnull _LaMA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4757);
}
// Settings.SuggestSetupPasswordText
NSString * _Nonnull _LaMB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4758);
}
// Settings.SuggestSetupPasswordTitle
NSString * _Nonnull _LaMC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4759);
}
// Settings.Support
NSString * _Nonnull _LaMD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4760);
}
// Settings.Terms_URL
NSString * _Nonnull _LaME(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4761);
}
// Settings.Tips
NSString * _Nonnull _LaMF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4762);
}
// Settings.TipsUsername
NSString * _Nonnull _LaMG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4763);
}
// Settings.Title
NSString * _Nonnull _LaMH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4764);
}
// Settings.TryEnterPassword
NSString * _Nonnull _LaMI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4765);
}
// Settings.Username
NSString * _Nonnull _LaMJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4766);
}
// Settings.UsernameEmpty
NSString * _Nonnull _LaMK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4767);
}
// Settings.ViewPhoto
NSString * _Nonnull _LaML(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4768);
}
// Settings.ViewVideo
NSString * _Nonnull _LaMM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4769);
}
// SettingsSearch.DeleteAccount.DeleteMyAccount
NSString * _Nonnull _LaMN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4770);
}
// SettingsSearch.FAQ
NSString * _Nonnull _LaMO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4771);
}
// SettingsSearch.Synonyms.AppLanguage
NSString * _Nonnull _LaMP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4772);
}
// SettingsSearch.Synonyms.Appearance.Animations
NSString * _Nonnull _LaMQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4773);
}
// SettingsSearch.Synonyms.Appearance.AutoNightTheme
NSString * _Nonnull _LaMR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4774);
}
// SettingsSearch.Synonyms.Appearance.ChatBackground
NSString * _Nonnull _LaMS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4775);
}
// SettingsSearch.Synonyms.Appearance.ChatBackground.Custom
NSString * _Nonnull _LaMT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4776);
}
// SettingsSearch.Synonyms.Appearance.ChatBackground.SetColor
NSString * _Nonnull _LaMU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4777);
}
// SettingsSearch.Synonyms.Appearance.ColorTheme
NSString * _Nonnull _LaMV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4778);
}
// SettingsSearch.Synonyms.Appearance.LargeEmoji
NSString * _Nonnull _LaMW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4779);
}
// SettingsSearch.Synonyms.Appearance.TextSize
NSString * _Nonnull _LaMX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4780);
}
// SettingsSearch.Synonyms.Appearance.Title
NSString * _Nonnull _LaMY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4781);
}
// SettingsSearch.Synonyms.Calls.CallTab
NSString * _Nonnull _LaMZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4782);
}
// SettingsSearch.Synonyms.Calls.Title
NSString * _Nonnull _LaNa(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4783);
}
// SettingsSearch.Synonyms.ChatSettings.IntentsSettings
NSString * _Nonnull _LaNb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4784);
}
// SettingsSearch.Synonyms.ChatSettings.OpenLinksIn
NSString * _Nonnull _LaNc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4785);
}
// SettingsSearch.Synonyms.Data.AutoDownloadReset
NSString * _Nonnull _LaNd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4786);
}
// SettingsSearch.Synonyms.Data.AutoDownloadUsingCellular
NSString * _Nonnull _LaNe(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4787);
}
// SettingsSearch.Synonyms.Data.AutoDownloadUsingWifi
NSString * _Nonnull _LaNf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4788);
}
// SettingsSearch.Synonyms.Data.AutoplayGifs
NSString * _Nonnull _LaNg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4789);
}
// SettingsSearch.Synonyms.Data.AutoplayVideos
NSString * _Nonnull _LaNh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4790);
}
// SettingsSearch.Synonyms.Data.CallsUseLessData
NSString * _Nonnull _LaNi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4791);
}
// SettingsSearch.Synonyms.Data.DownloadInBackground
NSString * _Nonnull _LaNj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4792);
}
// SettingsSearch.Synonyms.Data.NetworkUsage
NSString * _Nonnull _LaNk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4793);
}
// SettingsSearch.Synonyms.Data.SaveEditedPhotos
NSString * _Nonnull _LaNl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4794);
}
// SettingsSearch.Synonyms.Data.SaveIncomingPhotos
NSString * _Nonnull _LaNm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4795);
}
// SettingsSearch.Synonyms.Data.Storage.ClearCache
NSString * _Nonnull _LaNn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4796);
}
// SettingsSearch.Synonyms.Data.Storage.KeepMedia
NSString * _Nonnull _LaNo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4797);
}
// SettingsSearch.Synonyms.Data.Storage.Title
NSString * _Nonnull _LaNp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4798);
}
// SettingsSearch.Synonyms.Data.Title
NSString * _Nonnull _LaNq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4799);
}
// SettingsSearch.Synonyms.Devices.LinkDesktopDevice
NSString * _Nonnull _LaNr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4800);
}
// SettingsSearch.Synonyms.Devices.TerminateOtherSessions
NSString * _Nonnull _LaNs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4801);
}
// SettingsSearch.Synonyms.EditProfile.AddAccount
NSString * _Nonnull _LaNt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4802);
}
// SettingsSearch.Synonyms.EditProfile.Bio
NSString * _Nonnull _LaNu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4803);
}
// SettingsSearch.Synonyms.EditProfile.Logout
NSString * _Nonnull _LaNv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4804);
}
// SettingsSearch.Synonyms.EditProfile.PhoneNumber
NSString * _Nonnull _LaNw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4805);
}
// SettingsSearch.Synonyms.EditProfile.Title
NSString * _Nonnull _LaNx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4806);
}
// SettingsSearch.Synonyms.EditProfile.Username
NSString * _Nonnull _LaNy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4807);
}
// SettingsSearch.Synonyms.FAQ
NSString * _Nonnull _LaNz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4808);
}
// SettingsSearch.Synonyms.Language.DoNotTranslate
NSString * _Nonnull _LaNA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4809);
}
// SettingsSearch.Synonyms.Language.ShowTranslateButton
NSString * _Nonnull _LaNB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4810);
}
// SettingsSearch.Synonyms.Notifications.BadgeCountUnreadMessages
NSString * _Nonnull _LaNC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4811);
}
// SettingsSearch.Synonyms.Notifications.BadgeIncludeMutedChannels
NSString * _Nonnull _LaND(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4812);
}
// SettingsSearch.Synonyms.Notifications.BadgeIncludeMutedChats
NSString * _Nonnull _LaNE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4813);
}
// SettingsSearch.Synonyms.Notifications.BadgeIncludeMutedPublicGroups
NSString * _Nonnull _LaNF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4814);
}
// SettingsSearch.Synonyms.Notifications.ChannelNotificationsAlert
NSString * _Nonnull _LaNG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4815);
}
// SettingsSearch.Synonyms.Notifications.ChannelNotificationsExceptions
NSString * _Nonnull _LaNH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4816);
}
// SettingsSearch.Synonyms.Notifications.ChannelNotificationsPreview
NSString * _Nonnull _LaNI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4817);
}
// SettingsSearch.Synonyms.Notifications.ChannelNotificationsSound
NSString * _Nonnull _LaNJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4818);
}
// SettingsSearch.Synonyms.Notifications.ContactJoined
NSString * _Nonnull _LaNK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4819);
}
// SettingsSearch.Synonyms.Notifications.DisplayNamesOnLockScreen
NSString * _Nonnull _LaNL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4820);
}
// SettingsSearch.Synonyms.Notifications.GroupNotificationsAlert
NSString * _Nonnull _LaNM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4821);
}
// SettingsSearch.Synonyms.Notifications.GroupNotificationsExceptions
NSString * _Nonnull _LaNN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4822);
}
// SettingsSearch.Synonyms.Notifications.GroupNotificationsPreview
NSString * _Nonnull _LaNO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4823);
}
// SettingsSearch.Synonyms.Notifications.GroupNotificationsSound
NSString * _Nonnull _LaNP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4824);
}
// SettingsSearch.Synonyms.Notifications.InAppNotificationsPreview
NSString * _Nonnull _LaNQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4825);
}
// SettingsSearch.Synonyms.Notifications.InAppNotificationsSound
NSString * _Nonnull _LaNR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4826);
}
// SettingsSearch.Synonyms.Notifications.InAppNotificationsVibrate
NSString * _Nonnull _LaNS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4827);
}
// SettingsSearch.Synonyms.Notifications.MessageNotificationsAlert
NSString * _Nonnull _LaNT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4828);
}
// SettingsSearch.Synonyms.Notifications.MessageNotificationsExceptions
NSString * _Nonnull _LaNU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4829);
}
// SettingsSearch.Synonyms.Notifications.MessageNotificationsPreview
NSString * _Nonnull _LaNV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4830);
}
// SettingsSearch.Synonyms.Notifications.MessageNotificationsSound
NSString * _Nonnull _LaNW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4831);
}
// SettingsSearch.Synonyms.Notifications.ResetAllNotifications
NSString * _Nonnull _LaNX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4832);
}
// SettingsSearch.Synonyms.Notifications.Title
NSString * _Nonnull _LaNY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4833);
}
// SettingsSearch.Synonyms.Passport
NSString * _Nonnull _LaNZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4834);
}
// SettingsSearch.Synonyms.Premium
NSString * _Nonnull _LaOa(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4835);
}
// SettingsSearch.Synonyms.Premium.AnimatedEmoji
NSString * _Nonnull _LaOb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4836);
}
// SettingsSearch.Synonyms.Premium.AppIcon
NSString * _Nonnull _LaOc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4837);
}
// SettingsSearch.Synonyms.Premium.Avatar
NSString * _Nonnull _LaOd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4838);
}
// SettingsSearch.Synonyms.Premium.Badge
NSString * _Nonnull _LaOe(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4839);
}
// SettingsSearch.Synonyms.Premium.ChatManagement
NSString * _Nonnull _LaOf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4840);
}
// SettingsSearch.Synonyms.Premium.DoubledLimits
NSString * _Nonnull _LaOg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4841);
}
// SettingsSearch.Synonyms.Premium.EmojiStatus
NSString * _Nonnull _LaOh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4842);
}
// SettingsSearch.Synonyms.Premium.FasterSpeed
NSString * _Nonnull _LaOi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4843);
}
// SettingsSearch.Synonyms.Premium.NoAds
NSString * _Nonnull _LaOj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4844);
}
// SettingsSearch.Synonyms.Premium.Reactions
NSString * _Nonnull _LaOk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4845);
}
// SettingsSearch.Synonyms.Premium.Stickers
NSString * _Nonnull _LaOl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4846);
}
// SettingsSearch.Synonyms.Premium.UploadSize
NSString * _Nonnull _LaOm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4847);
}
// SettingsSearch.Synonyms.Premium.VoiceToText
NSString * _Nonnull _LaOn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4848);
}
// SettingsSearch.Synonyms.Privacy.AuthSessions
NSString * _Nonnull _LaOo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4849);
}
// SettingsSearch.Synonyms.Privacy.BlockedUsers
NSString * _Nonnull _LaOp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4850);
}
// SettingsSearch.Synonyms.Privacy.Calls
NSString * _Nonnull _LaOq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4851);
}
// SettingsSearch.Synonyms.Privacy.Data.ClearPaymentsInfo
NSString * _Nonnull _LaOr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4852);
}
// SettingsSearch.Synonyms.Privacy.Data.ContactsReset
NSString * _Nonnull _LaOs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4853);
}
// SettingsSearch.Synonyms.Privacy.Data.ContactsSync
NSString * _Nonnull _LaOt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4854);
}
// SettingsSearch.Synonyms.Privacy.Data.DeleteDrafts
NSString * _Nonnull _LaOu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4855);
}
// SettingsSearch.Synonyms.Privacy.Data.SecretChatLinkPreview
NSString * _Nonnull _LaOv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4856);
}
// SettingsSearch.Synonyms.Privacy.Data.Title
NSString * _Nonnull _LaOw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4857);
}
// SettingsSearch.Synonyms.Privacy.Data.TopPeers
NSString * _Nonnull _LaOx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4858);
}
// SettingsSearch.Synonyms.Privacy.DeleteAccountIfAwayFor
NSString * _Nonnull _LaOy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4859);
}
// SettingsSearch.Synonyms.Privacy.Forwards
NSString * _Nonnull _LaOz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4860);
}
// SettingsSearch.Synonyms.Privacy.GroupsAndChannels
NSString * _Nonnull _LaOA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4861);
}
// SettingsSearch.Synonyms.Privacy.LastSeen
NSString * _Nonnull _LaOB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4862);
}
// SettingsSearch.Synonyms.Privacy.Passcode
NSString * _Nonnull _LaOC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4863);
}
// SettingsSearch.Synonyms.Privacy.PasscodeAndFaceId
NSString * _Nonnull _LaOD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4864);
}
// SettingsSearch.Synonyms.Privacy.PasscodeAndTouchId
NSString * _Nonnull _LaOE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4865);
}
// SettingsSearch.Synonyms.Privacy.ProfilePhoto
NSString * _Nonnull _LaOF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4866);
}
// SettingsSearch.Synonyms.Privacy.Title
NSString * _Nonnull _LaOG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4867);
}
// SettingsSearch.Synonyms.Privacy.TwoStepAuth
NSString * _Nonnull _LaOH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4868);
}
// SettingsSearch.Synonyms.Proxy.AddProxy
NSString * _Nonnull _LaOI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4869);
}
// SettingsSearch.Synonyms.Proxy.Title
NSString * _Nonnull _LaOJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4870);
}
// SettingsSearch.Synonyms.Proxy.UseForCalls
NSString * _Nonnull _LaOK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4871);
}
// SettingsSearch.Synonyms.SavedMessages
NSString * _Nonnull _LaOL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4872);
}
// SettingsSearch.Synonyms.Stickers.ArchivedPacks
NSString * _Nonnull _LaOM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4873);
}
// SettingsSearch.Synonyms.Stickers.FeaturedPacks
NSString * _Nonnull _LaON(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4874);
}
// SettingsSearch.Synonyms.Stickers.Masks
NSString * _Nonnull _LaOO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4875);
}
// SettingsSearch.Synonyms.Stickers.SuggestStickers
NSString * _Nonnull _LaOP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4876);
}
// SettingsSearch.Synonyms.Stickers.Title
NSString * _Nonnull _LaOQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4877);
}
// SettingsSearch.Synonyms.Support
NSString * _Nonnull _LaOR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4878);
}
// SettingsSearch.Synonyms.Watch
NSString * _Nonnull _LaOS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4879);
}
// SettingsSearch_Synonyms_ChatFolders
NSString * _Nonnull _LaOT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4880);
}
// Share.AuthDescription
NSString * _Nonnull _LaOU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4881);
}
// Share.AuthTitle
NSString * _Nonnull _LaOV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4882);
}
// Share.MessagePreview
NSString * _Nonnull _LaOW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4883);
}
// Share.MultipleMessagesDisabled
NSString * _Nonnull _LaOX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4884);
}
// Share.ShareAsImage
NSString * _Nonnull _LaOY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4885);
}
// Share.ShareAsLink
NSString * _Nonnull _LaOZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4886);
}
// Share.ShareMessage
NSString * _Nonnull _LaPa(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4887);
}
// Share.ShareToInstagramStories
NSString * _Nonnull _LaPb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4888);
}
// Share.Title
NSString * _Nonnull _LaPc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4889);
}
// Share.UploadDone
NSString * _Nonnull _LaPd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4890);
}
// Share.UploadProgress
_FormattedString * _Nonnull _LaPe(_PresentationStrings * _Nonnull _self, NSInteger _0) {
    return getFormatted1(_self, 4891, @(_0));
}
// ShareFileTip.CloseTip
NSString * _Nonnull _LaPf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4892);
}
// ShareFileTip.Text
_FormattedString * _Nonnull _LaPg(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4893, _0);
}
// ShareFileTip.Title
NSString * _Nonnull _LaPh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4894);
}
// ShareMenu.Comment
NSString * _Nonnull _LaPi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4895);
}
// ShareMenu.CopyShareLink
NSString * _Nonnull _LaPj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4896);
}
// ShareMenu.CopyShareLinkGame
NSString * _Nonnull _LaPk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4897);
}
// ShareMenu.SelectChats
NSString * _Nonnull _LaPl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4898);
}
// ShareMenu.SelectTopic
NSString * _Nonnull _LaPm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4899);
}
// ShareMenu.Send
NSString * _Nonnull _LaPn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4900);
}
// ShareMenu.ShareTo
NSString * _Nonnull _LaPo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4901);
}
// SharedMedia.CalendarTooltip
NSString * _Nonnull _LaPp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4902);
}
// SharedMedia.CategoryDocs
NSString * _Nonnull _LaPq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4903);
}
// SharedMedia.CategoryLinks
NSString * _Nonnull _LaPr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4904);
}
// SharedMedia.CategoryMedia
NSString * _Nonnull _LaPs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4905);
}
// SharedMedia.CategoryOther
NSString * _Nonnull _LaPt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4906);
}
// SharedMedia.CommonGroupCount
NSString * _Nonnull _LaPu(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 4907, value);
}
// SharedMedia.DeleteItemsConfirmation
NSString * _Nonnull _LaPv(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 4908, value);
}
// SharedMedia.EmptyFilesText
NSString * _Nonnull _LaPw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4909);
}
// SharedMedia.EmptyLinksText
NSString * _Nonnull _LaPx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4910);
}
// SharedMedia.EmptyMusicText
NSString * _Nonnull _LaPy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4911);
}
// SharedMedia.EmptyText
NSString * _Nonnull _LaPz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4912);
}
// SharedMedia.EmptyTitle
NSString * _Nonnull _LaPA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4913);
}
// SharedMedia.FastScrollTooltip
NSString * _Nonnull _LaPB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4914);
}
// SharedMedia.File
NSString * _Nonnull _LaPC(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 4915, value);
}
// SharedMedia.FileCount
NSString * _Nonnull _LaPD(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 4916, value);
}
// SharedMedia.Generic
NSString * _Nonnull _LaPE(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 4917, value);
}
// SharedMedia.GifCount
NSString * _Nonnull _LaPF(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 4918, value);
}
// SharedMedia.Link
NSString * _Nonnull _LaPG(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 4919, value);
}
// SharedMedia.LinkCount
NSString * _Nonnull _LaPH(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 4920, value);
}
// SharedMedia.MusicCount
NSString * _Nonnull _LaPI(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 4921, value);
}
// SharedMedia.Photo
NSString * _Nonnull _LaPJ(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 4922, value);
}
// SharedMedia.PhotoCount
NSString * _Nonnull _LaPK(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 4923, value);
}
// SharedMedia.SearchNoResults
NSString * _Nonnull _LaPL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4924);
}
// SharedMedia.SearchNoResultsDescription
_FormattedString * _Nonnull _LaPM(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4925, _0);
}
// SharedMedia.ShowCalendar
NSString * _Nonnull _LaPN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4926);
}
// SharedMedia.ShowPhotos
NSString * _Nonnull _LaPO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4927);
}
// SharedMedia.ShowVideos
NSString * _Nonnull _LaPP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4928);
}
// SharedMedia.TitleAll
NSString * _Nonnull _LaPQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4929);
}
// SharedMedia.TitleLink
NSString * _Nonnull _LaPR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4930);
}
// SharedMedia.Video
NSString * _Nonnull _LaPS(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 4931, value);
}
// SharedMedia.VideoCount
NSString * _Nonnull _LaPT(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 4932, value);
}
// SharedMedia.ViewInChat
NSString * _Nonnull _LaPU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4933);
}
// SharedMedia.VoiceMessageCount
NSString * _Nonnull _LaPV(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 4934, value);
}
// SharedMedia.ZoomIn
NSString * _Nonnull _LaPW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4935);
}
// SharedMedia.ZoomOut
NSString * _Nonnull _LaPX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4936);
}
// Shortcut.SwitchAccount
NSString * _Nonnull _LaPY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4937);
}
// SocksProxySetup.AdNoticeHelp
NSString * _Nonnull _LaPZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4938);
}
// SocksProxySetup.AddProxy
NSString * _Nonnull _LaQa(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4939);
}
// SocksProxySetup.AddProxyTitle
NSString * _Nonnull _LaQb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4940);
}
// SocksProxySetup.ConnectAndSave
NSString * _Nonnull _LaQc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4941);
}
// SocksProxySetup.Connecting
NSString * _Nonnull _LaQd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4942);
}
// SocksProxySetup.Connection
NSString * _Nonnull _LaQe(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4943);
}
// SocksProxySetup.Credentials
NSString * _Nonnull _LaQf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4944);
}
// SocksProxySetup.FailedToConnect
NSString * _Nonnull _LaQg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4945);
}
// SocksProxySetup.Hostname
NSString * _Nonnull _LaQh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4946);
}
// SocksProxySetup.HostnamePlaceholder
NSString * _Nonnull _LaQi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4947);
}
// SocksProxySetup.Password
NSString * _Nonnull _LaQj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4948);
}
// SocksProxySetup.PasswordPlaceholder
NSString * _Nonnull _LaQk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4949);
}
// SocksProxySetup.PasteFromClipboard
NSString * _Nonnull _LaQl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4950);
}
// SocksProxySetup.Port
NSString * _Nonnull _LaQm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4951);
}
// SocksProxySetup.PortPlaceholder
NSString * _Nonnull _LaQn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4952);
}
// SocksProxySetup.ProxyDetailsTitle
NSString * _Nonnull _LaQo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4953);
}
// SocksProxySetup.ProxyEnabled
NSString * _Nonnull _LaQp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4954);
}
// SocksProxySetup.ProxySocks5
NSString * _Nonnull _LaQq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4955);
}
// SocksProxySetup.ProxyStatusChecking
NSString * _Nonnull _LaQr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4956);
}
// SocksProxySetup.ProxyStatusConnected
NSString * _Nonnull _LaQs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4957);
}
// SocksProxySetup.ProxyStatusConnecting
NSString * _Nonnull _LaQt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4958);
}
// SocksProxySetup.ProxyStatusPing
_FormattedString * _Nonnull _LaQu(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 4959, _0);
}
// SocksProxySetup.ProxyStatusUnavailable
NSString * _Nonnull _LaQv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4960);
}
// SocksProxySetup.ProxyTelegram
NSString * _Nonnull _LaQw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4961);
}
// SocksProxySetup.ProxyType
NSString * _Nonnull _LaQx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4962);
}
// SocksProxySetup.RequiredCredentials
NSString * _Nonnull _LaQy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4963);
}
// SocksProxySetup.SaveProxy
NSString * _Nonnull _LaQz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4964);
}
// SocksProxySetup.SavedProxies
NSString * _Nonnull _LaQA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4965);
}
// SocksProxySetup.Secret
NSString * _Nonnull _LaQB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4966);
}
// SocksProxySetup.SecretPlaceholder
NSString * _Nonnull _LaQC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4967);
}
// SocksProxySetup.ShareLink
NSString * _Nonnull _LaQD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4968);
}
// SocksProxySetup.ShareProxyList
NSString * _Nonnull _LaQE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4969);
}
// SocksProxySetup.ShareQRCode
NSString * _Nonnull _LaQF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4970);
}
// SocksProxySetup.ShareQRCodeInfo
NSString * _Nonnull _LaQG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4971);
}
// SocksProxySetup.Status
NSString * _Nonnull _LaQH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4972);
}
// SocksProxySetup.Title
NSString * _Nonnull _LaQI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4973);
}
// SocksProxySetup.TypeNone
NSString * _Nonnull _LaQJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4974);
}
// SocksProxySetup.TypeSocks
NSString * _Nonnull _LaQK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4975);
}
// SocksProxySetup.UseForCalls
NSString * _Nonnull _LaQL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4976);
}
// SocksProxySetup.UseForCallsHelp
NSString * _Nonnull _LaQM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4977);
}
// SocksProxySetup.UseProxy
NSString * _Nonnull _LaQN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4978);
}
// SocksProxySetup.Username
NSString * _Nonnull _LaQO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4979);
}
// SocksProxySetup.UsernamePlaceholder
NSString * _Nonnull _LaQP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4980);
}
// SponsoredMessageInfo.Action
NSString * _Nonnull _LaQQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4981);
}
// SponsoredMessageInfo.Url
NSString * _Nonnull _LaQR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4982);
}
// SponsoredMessageInfoScreen.Text
NSString * _Nonnull _LaQS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4983);
}
// SponsoredMessageInfoScreen.Title
NSString * _Nonnull _LaQT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4984);
}
// SponsoredMessageMenu.Hide
NSString * _Nonnull _LaQU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4985);
}
// SponsoredMessageMenu.Info
NSString * _Nonnull _LaQV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4986);
}
// State.Connecting
NSString * _Nonnull _LaQW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4987);
}
// State.ConnectingToProxy
NSString * _Nonnull _LaQX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4988);
}
// State.ConnectingToProxyInfo
NSString * _Nonnull _LaQY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4989);
}
// State.Updating
NSString * _Nonnull _LaQZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4990);
}
// State.WaitingForNetwork
NSString * _Nonnull _LaRa(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4991);
}
// State.connecting
NSString * _Nonnull _LaRb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4992);
}
// Stats.EnabledNotifications
NSString * _Nonnull _LaRc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4993);
}
// Stats.Followers
NSString * _Nonnull _LaRd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4994);
}
// Stats.FollowersBySourceTitle
NSString * _Nonnull _LaRe(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4995);
}
// Stats.FollowersTitle
NSString * _Nonnull _LaRf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4996);
}
// Stats.GroupActionsTitle
NSString * _Nonnull _LaRg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4997);
}
// Stats.GroupGrowthTitle
NSString * _Nonnull _LaRh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4998);
}
// Stats.GroupLanguagesTitle
NSString * _Nonnull _LaRi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 4999);
}
// Stats.GroupMembers
NSString * _Nonnull _LaRj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5000);
}
// Stats.GroupMembersTitle
NSString * _Nonnull _LaRk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5001);
}
// Stats.GroupMessages
NSString * _Nonnull _LaRl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5002);
}
// Stats.GroupMessagesTitle
NSString * _Nonnull _LaRm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5003);
}
// Stats.GroupNewMembersBySourceTitle
NSString * _Nonnull _LaRn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5004);
}
// Stats.GroupOverview
NSString * _Nonnull _LaRo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5005);
}
// Stats.GroupPosters
NSString * _Nonnull _LaRp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5006);
}
// Stats.GroupShowMoreTopAdmins
NSString * _Nonnull _LaRq(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 5007, value);
}
// Stats.GroupShowMoreTopInviters
NSString * _Nonnull _LaRr(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 5008, value);
}
// Stats.GroupShowMoreTopPosters
NSString * _Nonnull _LaRs(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 5009, value);
}
// Stats.GroupTopAdmin.Actions
NSString * _Nonnull _LaRt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5010);
}
// Stats.GroupTopAdmin.Promote
NSString * _Nonnull _LaRu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5011);
}
// Stats.GroupTopAdminBans
NSString * _Nonnull _LaRv(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 5012, value);
}
// Stats.GroupTopAdminDeletions
NSString * _Nonnull _LaRw(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 5013, value);
}
// Stats.GroupTopAdminKicks
NSString * _Nonnull _LaRx(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 5014, value);
}
// Stats.GroupTopAdminsTitle
NSString * _Nonnull _LaRy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5015);
}
// Stats.GroupTopHoursTitle
NSString * _Nonnull _LaRz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5016);
}
// Stats.GroupTopInviter.History
NSString * _Nonnull _LaRA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5017);
}
// Stats.GroupTopInviter.Promote
NSString * _Nonnull _LaRB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5018);
}
// Stats.GroupTopInviterInvites
NSString * _Nonnull _LaRC(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 5019, value);
}
// Stats.GroupTopInvitersTitle
NSString * _Nonnull _LaRD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5020);
}
// Stats.GroupTopPoster.History
NSString * _Nonnull _LaRE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5021);
}
// Stats.GroupTopPoster.Promote
NSString * _Nonnull _LaRF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5022);
}
// Stats.GroupTopPosterChars
NSString * _Nonnull _LaRG(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 5023, value);
}
// Stats.GroupTopPosterMessages
NSString * _Nonnull _LaRH(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 5024, value);
}
// Stats.GroupTopPostersTitle
NSString * _Nonnull _LaRI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5025);
}
// Stats.GroupTopWeekdaysTitle
NSString * _Nonnull _LaRJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5026);
}
// Stats.GroupViewers
NSString * _Nonnull _LaRK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5027);
}
// Stats.GrowthTitle
NSString * _Nonnull _LaRL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5028);
}
// Stats.InstantViewInteractionsTitle
NSString * _Nonnull _LaRM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5029);
}
// Stats.InteractionsTitle
NSString * _Nonnull _LaRN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5030);
}
// Stats.LanguagesTitle
NSString * _Nonnull _LaRO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5031);
}
// Stats.LoadingText
NSString * _Nonnull _LaRP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5032);
}
// Stats.LoadingTitle
NSString * _Nonnull _LaRQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5033);
}
// Stats.Message.PrivateShares
NSString * _Nonnull _LaRR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5034);
}
// Stats.Message.PublicShares
NSString * _Nonnull _LaRS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5035);
}
// Stats.Message.Views
NSString * _Nonnull _LaRT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5036);
}
// Stats.MessageForwards
NSString * _Nonnull _LaRU(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 5037, value);
}
// Stats.MessageInteractionsTitle
NSString * _Nonnull _LaRV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5038);
}
// Stats.MessageOverview
NSString * _Nonnull _LaRW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5039);
}
// Stats.MessagePublicForwardsTitle
NSString * _Nonnull _LaRX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5040);
}
// Stats.MessageTitle
NSString * _Nonnull _LaRY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5041);
}
// Stats.MessageViews
NSString * _Nonnull _LaRZ(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 5042, value);
}
// Stats.NotificationsTitle
NSString * _Nonnull _LaSa(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5043);
}
// Stats.Overview
NSString * _Nonnull _LaSb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5044);
}
// Stats.PostsTitle
NSString * _Nonnull _LaSc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5045);
}
// Stats.SharesPerPost
NSString * _Nonnull _LaSd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5046);
}
// Stats.Total
NSString * _Nonnull _LaSe(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5047);
}
// Stats.ViewsByHoursTitle
NSString * _Nonnull _LaSf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5048);
}
// Stats.ViewsBySourceTitle
NSString * _Nonnull _LaSg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5049);
}
// Stats.ViewsPerPost
NSString * _Nonnull _LaSh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5050);
}
// Stats.ZoomOut
NSString * _Nonnull _LaSi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5051);
}
// StickerPack.Add
NSString * _Nonnull _LaSj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5052);
}
// StickerPack.AddEmojiCount
NSString * _Nonnull _LaSk(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 5053, value);
}
// StickerPack.AddEmojiPacksCount
NSString * _Nonnull _LaSl(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 5054, value);
}
// StickerPack.AddMaskCount
NSString * _Nonnull _LaSm(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 5055, value);
}
// StickerPack.AddStickerCount
NSString * _Nonnull _LaSn(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 5056, value);
}
// StickerPack.BuiltinPackName
NSString * _Nonnull _LaSo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5057);
}
// StickerPack.CopyLink
NSString * _Nonnull _LaSp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5058);
}
// StickerPack.CopyLinks
NSString * _Nonnull _LaSq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5059);
}
// StickerPack.EmojiCount
NSString * _Nonnull _LaSr(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 5060, value);
}
// StickerPack.ErrorNotFound
NSString * _Nonnull _LaSs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5061);
}
// StickerPack.HideStickers
NSString * _Nonnull _LaSt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5062);
}
// StickerPack.MaskCount
NSString * _Nonnull _LaSu(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 5063, value);
}
// StickerPack.RemoveEmojiCount
NSString * _Nonnull _LaSv(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 5064, value);
}
// StickerPack.RemoveEmojiPacksCount
NSString * _Nonnull _LaSw(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 5065, value);
}
// StickerPack.RemoveMaskCount
NSString * _Nonnull _LaSx(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 5066, value);
}
// StickerPack.RemoveStickerCount
NSString * _Nonnull _LaSy(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 5067, value);
}
// StickerPack.Send
NSString * _Nonnull _LaSz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5068);
}
// StickerPack.Share
NSString * _Nonnull _LaSA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5069);
}
// StickerPack.ShowStickers
NSString * _Nonnull _LaSB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5070);
}
// StickerPack.StickerCount
NSString * _Nonnull _LaSC(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 5071, value);
}
// StickerPack.ViewPack
NSString * _Nonnull _LaSD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5072);
}
// StickerPackActionInfo.AddedText
_FormattedString * _Nonnull _LaSE(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5073, _0);
}
// StickerPackActionInfo.AddedTitle
NSString * _Nonnull _LaSF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5074);
}
// StickerPackActionInfo.ArchivedTitle
NSString * _Nonnull _LaSG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5075);
}
// StickerPackActionInfo.MultipleRemovedText
NSString * _Nonnull _LaSH(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 5076, value);
}
// StickerPackActionInfo.RemovedText
_FormattedString * _Nonnull _LaSI(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5077, _0);
}
// StickerPackActionInfo.RemovedTitle
NSString * _Nonnull _LaSJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5078);
}
// StickerPacks.ActionArchive
NSString * _Nonnull _LaSK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5079);
}
// StickerPacks.ActionDelete
NSString * _Nonnull _LaSL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5080);
}
// StickerPacks.ActionShare
NSString * _Nonnull _LaSM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5081);
}
// StickerPacks.ArchiveStickerPacksConfirmation
NSString * _Nonnull _LaSN(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 5082, value);
}
// StickerPacks.DeleteEmojiPacksConfirmation
NSString * _Nonnull _LaSO(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 5083, value);
}
// StickerPacks.DeleteStickerPacksConfirmation
NSString * _Nonnull _LaSP(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 5084, value);
}
// StickerPacksSettings.AnimatedStickers
NSString * _Nonnull _LaSQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5085);
}
// StickerPacksSettings.AnimatedStickersInfo
NSString * _Nonnull _LaSR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5086);
}
// StickerPacksSettings.ArchivedMasks
NSString * _Nonnull _LaSS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5087);
}
// StickerPacksSettings.ArchivedMasks.Info
NSString * _Nonnull _LaST(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5088);
}
// StickerPacksSettings.ArchivedPacks
NSString * _Nonnull _LaSU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5089);
}
// StickerPacksSettings.ArchivedPacks.Info
NSString * _Nonnull _LaSV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5090);
}
// StickerPacksSettings.FeaturedPacks
NSString * _Nonnull _LaSW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5091);
}
// StickerPacksSettings.ManagingHelp
NSString * _Nonnull _LaSX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5092);
}
// StickerPacksSettings.ShowStickersButton
NSString * _Nonnull _LaSY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5093);
}
// StickerPacksSettings.ShowStickersButtonHelp
NSString * _Nonnull _LaSZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5094);
}
// StickerPacksSettings.StickerPacksSection
NSString * _Nonnull _LaTa(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5095);
}
// StickerPacksSettings.SuggestAnimatedEmoji
NSString * _Nonnull _LaTb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5096);
}
// StickerPacksSettings.Title
NSString * _Nonnull _LaTc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5097);
}
// StickerSettings.ContextHide
NSString * _Nonnull _LaTd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5098);
}
// StickerSettings.ContextInfo
NSString * _Nonnull _LaTe(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5099);
}
// StickerSettings.EmojiContextInfo
NSString * _Nonnull _LaTf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5100);
}
// StickerSettings.MaskContextInfo
NSString * _Nonnull _LaTg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5101);
}
// Stickers.AddToFavorites
NSString * _Nonnull _LaTh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5102);
}
// Stickers.ClearRecent
NSString * _Nonnull _LaTi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5103);
}
// Stickers.EmojiPackInfoText
_FormattedString * _Nonnull _LaTj(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5104, _0);
}
// Stickers.FavoriteStickers
NSString * _Nonnull _LaTk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5105);
}
// Stickers.Favorites
NSString * _Nonnull _LaTl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5106);
}
// Stickers.FrequentlyUsed
NSString * _Nonnull _LaTm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5107);
}
// Stickers.Gifs
NSString * _Nonnull _LaTn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5108);
}
// Stickers.GroupChooseStickerPack
NSString * _Nonnull _LaTo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5109);
}
// Stickers.GroupStickers
NSString * _Nonnull _LaTp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5110);
}
// Stickers.GroupStickersHelp
NSString * _Nonnull _LaTq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5111);
}
// Stickers.Install
NSString * _Nonnull _LaTr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5112);
}
// Stickers.Installed
NSString * _Nonnull _LaTs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5113);
}
// Stickers.NoStickersFound
NSString * _Nonnull _LaTt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5114);
}
// Stickers.PremiumPackInfoText
NSString * _Nonnull _LaTu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5115);
}
// Stickers.PremiumPackView
NSString * _Nonnull _LaTv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5116);
}
// Stickers.PremiumStickers
NSString * _Nonnull _LaTw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5117);
}
// Stickers.Recent
NSString * _Nonnull _LaTx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5118);
}
// Stickers.RemoveFromFavorites
NSString * _Nonnull _LaTy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5119);
}
// Stickers.Search
NSString * _Nonnull _LaTz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5120);
}
// Stickers.Settings
NSString * _Nonnull _LaTA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5121);
}
// Stickers.ShowMore
NSString * _Nonnull _LaTB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5122);
}
// Stickers.Stickers
NSString * _Nonnull _LaTC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5123);
}
// Stickers.SuggestAdded
NSString * _Nonnull _LaTD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5124);
}
// Stickers.SuggestAll
NSString * _Nonnull _LaTE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5125);
}
// Stickers.SuggestNone
NSString * _Nonnull _LaTF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5126);
}
// Stickers.SuggestStickers
NSString * _Nonnull _LaTG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5127);
}
// Stickers.Trending
NSString * _Nonnull _LaTH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5128);
}
// Stickers.TrendingPremiumStickers
NSString * _Nonnull _LaTI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5129);
}
// StickersList.ArchivedEmojiItem
NSString * _Nonnull _LaTJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5130);
}
// StickersList.EmojiItem
NSString * _Nonnull _LaTK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5131);
}
// StickersSearch.SearchStickersPlaceholder
NSString * _Nonnull _LaTL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5132);
}
// StorageManagement.AutoremoveDescription
NSString * _Nonnull _LaTM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5133);
}
// StorageManagement.AutoremoveHeader
NSString * _Nonnull _LaTN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5134);
}
// StorageManagement.AutoremoveSpaceDescription
NSString * _Nonnull _LaTO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5135);
}
// StorageManagement.ClearAll
NSString * _Nonnull _LaTP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5136);
}
// StorageManagement.ClearCache
NSString * _Nonnull _LaTQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5137);
}
// StorageManagement.ClearConfirmationText
NSString * _Nonnull _LaTR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5138);
}
// StorageManagement.ClearSelected
NSString * _Nonnull _LaTS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5139);
}
// StorageManagement.ContextDeselect
NSString * _Nonnull _LaTT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5140);
}
// StorageManagement.ContextSelect
NSString * _Nonnull _LaTU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5141);
}
// StorageManagement.DescriptionAppUsage
_FormattedString * _Nonnull _LaTV(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5142, _0);
}
// StorageManagement.DescriptionChatUsage
_FormattedString * _Nonnull _LaTW(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5143, _0);
}
// StorageManagement.DescriptionCleared
NSString * _Nonnull _LaTX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5144);
}
// StorageManagement.OpenFile
NSString * _Nonnull _LaTY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5145);
}
// StorageManagement.OpenPhoto
NSString * _Nonnull _LaTZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5146);
}
// StorageManagement.OpenVideo
NSString * _Nonnull _LaUa(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5147);
}
// StorageManagement.PeerOpenProfile
NSString * _Nonnull _LaUb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5148);
}
// StorageManagement.PeerShowDetails
NSString * _Nonnull _LaUc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5149);
}
// StorageManagement.SectionAvatars
NSString * _Nonnull _LaUd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5150);
}
// StorageManagement.SectionCalls
NSString * _Nonnull _LaUe(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5151);
}
// StorageManagement.SectionFiles
NSString * _Nonnull _LaUf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5152);
}
// StorageManagement.SectionMessages
NSString * _Nonnull _LaUg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5153);
}
// StorageManagement.SectionMiscellaneous
NSString * _Nonnull _LaUh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5154);
}
// StorageManagement.SectionMusic
NSString * _Nonnull _LaUi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5155);
}
// StorageManagement.SectionOther
NSString * _Nonnull _LaUj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5156);
}
// StorageManagement.SectionPhotos
NSString * _Nonnull _LaUk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5157);
}
// StorageManagement.SectionStickers
NSString * _Nonnull _LaUl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5158);
}
// StorageManagement.SectionVideos
NSString * _Nonnull _LaUm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5159);
}
// StorageManagement.SectionVoiceMessages
NSString * _Nonnull _LaUn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5160);
}
// StorageManagement.SectionsDescription
NSString * _Nonnull _LaUo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5161);
}
// StorageManagement.TabChats
NSString * _Nonnull _LaUp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5162);
}
// StorageManagement.TabFiles
NSString * _Nonnull _LaUq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5163);
}
// StorageManagement.TabMedia
NSString * _Nonnull _LaUr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5164);
}
// StorageManagement.TabMusic
NSString * _Nonnull _LaUs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5165);
}
// StorageManagement.Title
NSString * _Nonnull _LaUt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5166);
}
// StorageManagement.TitleCleared
NSString * _Nonnull _LaUu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5167);
}
// Target.InviteToGroupConfirmation
_FormattedString * _Nonnull _LaUv(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5168, _0);
}
// Target.InviteToGroupErrorAlreadyInvited
NSString * _Nonnull _LaUw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5169);
}
// Target.SelectGroup
NSString * _Nonnull _LaUx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5170);
}
// Target.ShareGameConfirmationGroup
_FormattedString * _Nonnull _LaUy(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5171, _0);
}
// Target.ShareGameConfirmationPrivate
_FormattedString * _Nonnull _LaUz(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5172, _0);
}
// TextFormat.AddLinkPlaceholder
NSString * _Nonnull _LaUA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5173);
}
// TextFormat.AddLinkText
_FormattedString * _Nonnull _LaUB(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5174, _0);
}
// TextFormat.AddLinkTitle
NSString * _Nonnull _LaUC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5175);
}
// TextFormat.Bold
NSString * _Nonnull _LaUD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5176);
}
// TextFormat.Format
NSString * _Nonnull _LaUE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5177);
}
// TextFormat.Italic
NSString * _Nonnull _LaUF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5178);
}
// TextFormat.Link
NSString * _Nonnull _LaUG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5179);
}
// TextFormat.Monospace
NSString * _Nonnull _LaUH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5180);
}
// TextFormat.Spoiler
NSString * _Nonnull _LaUI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5181);
}
// TextFormat.Strikethrough
NSString * _Nonnull _LaUJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5182);
}
// TextFormat.Underline
NSString * _Nonnull _LaUK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5183);
}
// Theme.Colors.Accent
NSString * _Nonnull _LaUL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5184);
}
// Theme.Colors.Background
NSString * _Nonnull _LaUM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5185);
}
// Theme.Colors.ColorWallpaperWarning
NSString * _Nonnull _LaUN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5186);
}
// Theme.Colors.ColorWallpaperWarningProceed
NSString * _Nonnull _LaUO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5187);
}
// Theme.Colors.Messages
NSString * _Nonnull _LaUP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5188);
}
// Theme.Colors.Proceed
NSString * _Nonnull _LaUQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5189);
}
// Theme.Context.Apply
NSString * _Nonnull _LaUR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5190);
}
// Theme.Context.ChangeColors
NSString * _Nonnull _LaUS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5191);
}
// Theme.ErrorNotFound
NSString * _Nonnull _LaUT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5192);
}
// Theme.ThemeChanged
NSString * _Nonnull _LaUU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5193);
}
// Theme.ThemeChangedText
NSString * _Nonnull _LaUV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5194);
}
// Theme.Unsupported
NSString * _Nonnull _LaUW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5195);
}
// Theme.UsersCount
NSString * _Nonnull _LaUX(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 5196, value);
}
// Themes.BuildOwn
NSString * _Nonnull _LaUY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5197);
}
// Themes.CreateNewTheme
NSString * _Nonnull _LaUZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5198);
}
// Themes.EditCurrentTheme
NSString * _Nonnull _LaVa(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5199);
}
// Themes.SelectTheme
NSString * _Nonnull _LaVb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5200);
}
// Themes.Title
NSString * _Nonnull _LaVc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5201);
}
// Time.AfterDays
NSString * _Nonnull _LaVd(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 5202, value);
}
// Time.AfterHours
NSString * _Nonnull _LaVe(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 5203, value);
}
// Time.AfterMinutes
NSString * _Nonnull _LaVf(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 5204, value);
}
// Time.AfterMonths
NSString * _Nonnull _LaVg(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 5205, value);
}
// Time.AfterSeconds
NSString * _Nonnull _LaVh(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 5206, value);
}
// Time.AfterWeeks
NSString * _Nonnull _LaVi(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 5207, value);
}
// Time.AfterYears
NSString * _Nonnull _LaVj(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 5208, value);
}
// Time.AtDate
_FormattedString * _Nonnull _LaVk(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5209, _0);
}
// Time.HoursAgo
NSString * _Nonnull _LaVl(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 5210, value);
}
// Time.JustNow
NSString * _Nonnull _LaVm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5211);
}
// Time.MediumDate
_FormattedString * _Nonnull _LaVn(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 5212, _0, _1);
}
// Time.MinutesAgo
NSString * _Nonnull _LaVo(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 5213, value);
}
// Time.MonthOfYear_m1
_FormattedString * _Nonnull _LaVp(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5214, _0);
}
// Time.MonthOfYear_m10
_FormattedString * _Nonnull _LaVq(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5215, _0);
}
// Time.MonthOfYear_m11
_FormattedString * _Nonnull _LaVr(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5216, _0);
}
// Time.MonthOfYear_m12
_FormattedString * _Nonnull _LaVs(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5217, _0);
}
// Time.MonthOfYear_m2
_FormattedString * _Nonnull _LaVt(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5218, _0);
}
// Time.MonthOfYear_m3
_FormattedString * _Nonnull _LaVu(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5219, _0);
}
// Time.MonthOfYear_m4
_FormattedString * _Nonnull _LaVv(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5220, _0);
}
// Time.MonthOfYear_m5
_FormattedString * _Nonnull _LaVw(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5221, _0);
}
// Time.MonthOfYear_m6
_FormattedString * _Nonnull _LaVx(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5222, _0);
}
// Time.MonthOfYear_m7
_FormattedString * _Nonnull _LaVy(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5223, _0);
}
// Time.MonthOfYear_m8
_FormattedString * _Nonnull _LaVz(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5224, _0);
}
// Time.MonthOfYear_m9
_FormattedString * _Nonnull _LaVA(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5225, _0);
}
// Time.PreciseDate_m1
_FormattedString * _Nonnull _LaVB(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2) {
    return getFormatted3(_self, 5226, _0, _1, _2);
}
// Time.PreciseDate_m10
_FormattedString * _Nonnull _LaVC(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2) {
    return getFormatted3(_self, 5227, _0, _1, _2);
}
// Time.PreciseDate_m11
_FormattedString * _Nonnull _LaVD(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2) {
    return getFormatted3(_self, 5228, _0, _1, _2);
}
// Time.PreciseDate_m12
_FormattedString * _Nonnull _LaVE(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2) {
    return getFormatted3(_self, 5229, _0, _1, _2);
}
// Time.PreciseDate_m2
_FormattedString * _Nonnull _LaVF(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2) {
    return getFormatted3(_self, 5230, _0, _1, _2);
}
// Time.PreciseDate_m3
_FormattedString * _Nonnull _LaVG(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2) {
    return getFormatted3(_self, 5231, _0, _1, _2);
}
// Time.PreciseDate_m4
_FormattedString * _Nonnull _LaVH(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2) {
    return getFormatted3(_self, 5232, _0, _1, _2);
}
// Time.PreciseDate_m5
_FormattedString * _Nonnull _LaVI(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2) {
    return getFormatted3(_self, 5233, _0, _1, _2);
}
// Time.PreciseDate_m6
_FormattedString * _Nonnull _LaVJ(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2) {
    return getFormatted3(_self, 5234, _0, _1, _2);
}
// Time.PreciseDate_m7
_FormattedString * _Nonnull _LaVK(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2) {
    return getFormatted3(_self, 5235, _0, _1, _2);
}
// Time.PreciseDate_m8
_FormattedString * _Nonnull _LaVL(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2) {
    return getFormatted3(_self, 5236, _0, _1, _2);
}
// Time.PreciseDate_m9
_FormattedString * _Nonnull _LaVM(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1, NSString * _Nonnull _2) {
    return getFormatted3(_self, 5237, _0, _1, _2);
}
// Time.TimerDays
NSString * _Nonnull _LaVN(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 5238, value);
}
// Time.TimerHours
NSString * _Nonnull _LaVO(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 5239, value);
}
// Time.TimerMinutes
NSString * _Nonnull _LaVP(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 5240, value);
}
// Time.TimerMonths
NSString * _Nonnull _LaVQ(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 5241, value);
}
// Time.TimerSeconds
NSString * _Nonnull _LaVR(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 5242, value);
}
// Time.TimerWeeks
NSString * _Nonnull _LaVS(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 5243, value);
}
// Time.TimerYears
NSString * _Nonnull _LaVT(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 5244, value);
}
// Time.TodayAt
_FormattedString * _Nonnull _LaVU(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5245, _0);
}
// Time.TomorrowAt
_FormattedString * _Nonnull _LaVV(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5246, _0);
}
// Time.YesterdayAt
_FormattedString * _Nonnull _LaVW(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5247, _0);
}
// Tour.StartButton
NSString * _Nonnull _LaVX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5248);
}
// Tour.Text1
NSString * _Nonnull _LaVY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5249);
}
// Tour.Text2
NSString * _Nonnull _LaVZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5250);
}
// Tour.Text3
NSString * _Nonnull _LaWa(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5251);
}
// Tour.Text4
NSString * _Nonnull _LaWb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5252);
}
// Tour.Text5
NSString * _Nonnull _LaWc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5253);
}
// Tour.Text6
NSString * _Nonnull _LaWd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5254);
}
// Tour.Title1
NSString * _Nonnull _LaWe(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5255);
}
// Tour.Title2
NSString * _Nonnull _LaWf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5256);
}
// Tour.Title3
NSString * _Nonnull _LaWg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5257);
}
// Tour.Title4
NSString * _Nonnull _LaWh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5258);
}
// Tour.Title5
NSString * _Nonnull _LaWi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5259);
}
// Tour.Title6
NSString * _Nonnull _LaWj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5260);
}
// Translate.ChangeLanguage
NSString * _Nonnull _LaWk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5261);
}
// Translate.CopyTranslation
NSString * _Nonnull _LaWl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5262);
}
// Translate.Languages.Original
NSString * _Nonnull _LaWm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5263);
}
// Translate.Languages.Title
NSString * _Nonnull _LaWn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5264);
}
// Translate.Languages.Translation
NSString * _Nonnull _LaWo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5265);
}
// Translate.More
NSString * _Nonnull _LaWp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5266);
}
// Translate.Title
NSString * _Nonnull _LaWq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5267);
}
// Translation.Language.ar
NSString * _Nonnull _LaWr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5268);
}
// Translation.Language.be
NSString * _Nonnull _LaWs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5269);
}
// Translation.Language.ca
NSString * _Nonnull _LaWt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5270);
}
// Translation.Language.cs
NSString * _Nonnull _LaWu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5271);
}
// Translation.Language.de
NSString * _Nonnull _LaWv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5272);
}
// Translation.Language.en
NSString * _Nonnull _LaWw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5273);
}
// Translation.Language.eo
NSString * _Nonnull _LaWx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5274);
}
// Translation.Language.es
NSString * _Nonnull _LaWy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5275);
}
// Translation.Language.fa
NSString * _Nonnull _LaWz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5276);
}
// Translation.Language.fi
NSString * _Nonnull _LaWA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5277);
}
// Translation.Language.fr
NSString * _Nonnull _LaWB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5278);
}
// Translation.Language.he
NSString * _Nonnull _LaWC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5279);
}
// Translation.Language.hr
NSString * _Nonnull _LaWD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5280);
}
// Translation.Language.hu
NSString * _Nonnull _LaWE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5281);
}
// Translation.Language.id
NSString * _Nonnull _LaWF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5282);
}
// Translation.Language.it
NSString * _Nonnull _LaWG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5283);
}
// Translation.Language.ja
NSString * _Nonnull _LaWH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5284);
}
// Translation.Language.ko
NSString * _Nonnull _LaWI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5285);
}
// Translation.Language.ml
NSString * _Nonnull _LaWJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5286);
}
// Translation.Language.ms
NSString * _Nonnull _LaWK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5287);
}
// Translation.Language.nl
NSString * _Nonnull _LaWL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5288);
}
// Translation.Language.no
NSString * _Nonnull _LaWM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5289);
}
// Translation.Language.po
NSString * _Nonnull _LaWN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5290);
}
// Translation.Language.pt
NSString * _Nonnull _LaWO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5291);
}
// Translation.Language.ro
NSString * _Nonnull _LaWP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5292);
}
// Translation.Language.ru
NSString * _Nonnull _LaWQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5293);
}
// Translation.Language.sk
NSString * _Nonnull _LaWR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5294);
}
// Translation.Language.sr
NSString * _Nonnull _LaWS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5295);
}
// Translation.Language.sv
NSString * _Nonnull _LaWT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5296);
}
// Translation.Language.ta
NSString * _Nonnull _LaWU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5297);
}
// Translation.Language.tr
NSString * _Nonnull _LaWV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5298);
}
// Translation.Language.uk
NSString * _Nonnull _LaWW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5299);
}
// Translation.Language.uz
NSString * _Nonnull _LaWX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5300);
}
// Translation.Language.zh
NSString * _Nonnull _LaWY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5301);
}
// TwoFactorRemember.CheckPassword
NSString * _Nonnull _LaWZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5302);
}
// TwoFactorRemember.Done.Action
NSString * _Nonnull _LaXa(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5303);
}
// TwoFactorRemember.Done.Text
NSString * _Nonnull _LaXb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5304);
}
// TwoFactorRemember.Done.Title
NSString * _Nonnull _LaXc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5305);
}
// TwoFactorRemember.Forgot
NSString * _Nonnull _LaXd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5306);
}
// TwoFactorRemember.Placeholder
NSString * _Nonnull _LaXe(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5307);
}
// TwoFactorRemember.Text
NSString * _Nonnull _LaXf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5308);
}
// TwoFactorRemember.Title
NSString * _Nonnull _LaXg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5309);
}
// TwoFactorRemember.WrongPassword
NSString * _Nonnull _LaXh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5310);
}
// TwoFactorSetup.Done.Action
NSString * _Nonnull _LaXi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5311);
}
// TwoFactorSetup.Done.Text
NSString * _Nonnull _LaXj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5312);
}
// TwoFactorSetup.Done.Title
NSString * _Nonnull _LaXk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5313);
}
// TwoFactorSetup.Email.Action
NSString * _Nonnull _LaXl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5314);
}
// TwoFactorSetup.Email.Placeholder
NSString * _Nonnull _LaXm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5315);
}
// TwoFactorSetup.Email.SkipAction
NSString * _Nonnull _LaXn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5316);
}
// TwoFactorSetup.Email.SkipConfirmationSkip
NSString * _Nonnull _LaXo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5317);
}
// TwoFactorSetup.Email.SkipConfirmationText
NSString * _Nonnull _LaXp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5318);
}
// TwoFactorSetup.Email.SkipConfirmationTitle
NSString * _Nonnull _LaXq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5319);
}
// TwoFactorSetup.Email.Text
NSString * _Nonnull _LaXr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5320);
}
// TwoFactorSetup.Email.Title
NSString * _Nonnull _LaXs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5321);
}
// TwoFactorSetup.EmailVerification.Action
NSString * _Nonnull _LaXt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5322);
}
// TwoFactorSetup.EmailVerification.ChangeAction
NSString * _Nonnull _LaXu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5323);
}
// TwoFactorSetup.EmailVerification.Placeholder
NSString * _Nonnull _LaXv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5324);
}
// TwoFactorSetup.EmailVerification.ResendAction
NSString * _Nonnull _LaXw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5325);
}
// TwoFactorSetup.EmailVerification.Text
_FormattedString * _Nonnull _LaXx(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5326, _0);
}
// TwoFactorSetup.EmailVerification.Title
NSString * _Nonnull _LaXy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5327);
}
// TwoFactorSetup.Hint.Action
NSString * _Nonnull _LaXz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5328);
}
// TwoFactorSetup.Hint.Placeholder
NSString * _Nonnull _LaXA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5329);
}
// TwoFactorSetup.Hint.SkipAction
NSString * _Nonnull _LaXB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5330);
}
// TwoFactorSetup.Hint.Text
NSString * _Nonnull _LaXC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5331);
}
// TwoFactorSetup.Hint.Title
NSString * _Nonnull _LaXD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5332);
}
// TwoFactorSetup.Intro.Action
NSString * _Nonnull _LaXE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5333);
}
// TwoFactorSetup.Intro.Text
NSString * _Nonnull _LaXF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5334);
}
// TwoFactorSetup.Intro.Title
NSString * _Nonnull _LaXG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5335);
}
// TwoFactorSetup.Password.Action
NSString * _Nonnull _LaXH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5336);
}
// TwoFactorSetup.Password.PlaceholderConfirmPassword
NSString * _Nonnull _LaXI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5337);
}
// TwoFactorSetup.Password.PlaceholderPassword
NSString * _Nonnull _LaXJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5338);
}
// TwoFactorSetup.Password.Title
NSString * _Nonnull _LaXK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5339);
}
// TwoFactorSetup.PasswordRecovery.Action
NSString * _Nonnull _LaXL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5340);
}
// TwoFactorSetup.PasswordRecovery.PlaceholderConfirmPassword
NSString * _Nonnull _LaXM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5341);
}
// TwoFactorSetup.PasswordRecovery.PlaceholderPassword
NSString * _Nonnull _LaXN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5342);
}
// TwoFactorSetup.PasswordRecovery.Skip
NSString * _Nonnull _LaXO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5343);
}
// TwoFactorSetup.PasswordRecovery.SkipAlertAction
NSString * _Nonnull _LaXP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5344);
}
// TwoFactorSetup.PasswordRecovery.SkipAlertText
NSString * _Nonnull _LaXQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5345);
}
// TwoFactorSetup.PasswordRecovery.SkipAlertTitle
NSString * _Nonnull _LaXR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5346);
}
// TwoFactorSetup.PasswordRecovery.Text
NSString * _Nonnull _LaXS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5347);
}
// TwoFactorSetup.PasswordRecovery.Title
NSString * _Nonnull _LaXT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5348);
}
// TwoFactorSetup.ResetDone.Action
NSString * _Nonnull _LaXU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5349);
}
// TwoFactorSetup.ResetDone.Text
NSString * _Nonnull _LaXV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5350);
}
// TwoFactorSetup.ResetDone.TextNoPassword
NSString * _Nonnull _LaXW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5351);
}
// TwoFactorSetup.ResetDone.Title
NSString * _Nonnull _LaXX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5352);
}
// TwoFactorSetup.ResetDone.TitleNoPassword
NSString * _Nonnull _LaXY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5353);
}
// TwoFactorSetup.ResetFloodWait
_FormattedString * _Nonnull _LaXZ(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5354, _0);
}
// TwoStepAuth.AddHintDescription
NSString * _Nonnull _LaYa(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5355);
}
// TwoStepAuth.AddHintTitle
NSString * _Nonnull _LaYb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5356);
}
// TwoStepAuth.AdditionalPassword
NSString * _Nonnull _LaYc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5357);
}
// TwoStepAuth.CancelResetText
NSString * _Nonnull _LaYd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5358);
}
// TwoStepAuth.CancelResetTitle
NSString * _Nonnull _LaYe(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5359);
}
// TwoStepAuth.ChangeEmail
NSString * _Nonnull _LaYf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5360);
}
// TwoStepAuth.ChangePassword
NSString * _Nonnull _LaYg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5361);
}
// TwoStepAuth.ChangePasswordDescription
NSString * _Nonnull _LaYh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5362);
}
// TwoStepAuth.ConfirmEmailCodePlaceholder
NSString * _Nonnull _LaYi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5363);
}
// TwoStepAuth.ConfirmEmailDescription
_FormattedString * _Nonnull _LaYj(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5364, _0);
}
// TwoStepAuth.ConfirmEmailResendCode
NSString * _Nonnull _LaYk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5365);
}
// TwoStepAuth.ConfirmationAbort
NSString * _Nonnull _LaYl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5366);
}
// TwoStepAuth.ConfirmationText
NSString * _Nonnull _LaYm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5367);
}
// TwoStepAuth.ConfirmationTitle
NSString * _Nonnull _LaYn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5368);
}
// TwoStepAuth.Disable
NSString * _Nonnull _LaYo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5369);
}
// TwoStepAuth.DisableSuccess
NSString * _Nonnull _LaYp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5370);
}
// TwoStepAuth.Email
NSString * _Nonnull _LaYq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5371);
}
// TwoStepAuth.EmailAddSuccess
NSString * _Nonnull _LaYr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5372);
}
// TwoStepAuth.EmailChangeSuccess
NSString * _Nonnull _LaYs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5373);
}
// TwoStepAuth.EmailCodeExpired
NSString * _Nonnull _LaYt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5374);
}
// TwoStepAuth.EmailHelp
NSString * _Nonnull _LaYu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5375);
}
// TwoStepAuth.EmailInvalid
NSString * _Nonnull _LaYv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5376);
}
// TwoStepAuth.EmailPlaceholder
NSString * _Nonnull _LaYw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5377);
}
// TwoStepAuth.EmailSent
NSString * _Nonnull _LaYx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5378);
}
// TwoStepAuth.EmailSkip
NSString * _Nonnull _LaYy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5379);
}
// TwoStepAuth.EmailSkipAlert
NSString * _Nonnull _LaYz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5380);
}
// TwoStepAuth.EmailTitle
NSString * _Nonnull _LaYA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5381);
}
// TwoStepAuth.EnabledSuccess
NSString * _Nonnull _LaYB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5382);
}
// TwoStepAuth.EnterEmailCode
NSString * _Nonnull _LaYC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5383);
}
// TwoStepAuth.EnterPasswordForgot
NSString * _Nonnull _LaYD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5384);
}
// TwoStepAuth.EnterPasswordHelp
NSString * _Nonnull _LaYE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5385);
}
// TwoStepAuth.EnterPasswordHint
_FormattedString * _Nonnull _LaYF(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5386, _0);
}
// TwoStepAuth.EnterPasswordInvalid
NSString * _Nonnull _LaYG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5387);
}
// TwoStepAuth.EnterPasswordPassword
NSString * _Nonnull _LaYH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5388);
}
// TwoStepAuth.EnterPasswordTitle
NSString * _Nonnull _LaYI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5389);
}
// TwoStepAuth.FloodError
NSString * _Nonnull _LaYJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5390);
}
// TwoStepAuth.GenericHelp
NSString * _Nonnull _LaYK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5391);
}
// TwoStepAuth.HintPlaceholder
NSString * _Nonnull _LaYL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5392);
}
// TwoStepAuth.PasswordChangeSuccess
NSString * _Nonnull _LaYM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5393);
}
// TwoStepAuth.PasswordRemoveConfirmation
NSString * _Nonnull _LaYN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5394);
}
// TwoStepAuth.PasswordRemovePassportConfirmation
NSString * _Nonnull _LaYO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5395);
}
// TwoStepAuth.PasswordSet
NSString * _Nonnull _LaYP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5396);
}
// TwoStepAuth.PendingEmailHelp
_FormattedString * _Nonnull _LaYQ(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5397, _0);
}
// TwoStepAuth.ReEnterPasswordDescription
NSString * _Nonnull _LaYR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5398);
}
// TwoStepAuth.ReEnterPasswordTitle
NSString * _Nonnull _LaYS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5399);
}
// TwoStepAuth.RecoveryCode
NSString * _Nonnull _LaYT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5400);
}
// TwoStepAuth.RecoveryCodeExpired
NSString * _Nonnull _LaYU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5401);
}
// TwoStepAuth.RecoveryCodeHelp
NSString * _Nonnull _LaYV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5402);
}
// TwoStepAuth.RecoveryCodeInvalid
NSString * _Nonnull _LaYW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5403);
}
// TwoStepAuth.RecoveryEmailAddDescription
NSString * _Nonnull _LaYX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5404);
}
// TwoStepAuth.RecoveryEmailChangeDescription
NSString * _Nonnull _LaYY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5405);
}
// TwoStepAuth.RecoveryEmailResetNoAccess
NSString * _Nonnull _LaYZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5406);
}
// TwoStepAuth.RecoveryEmailResetText
NSString * _Nonnull _LaZa(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5407);
}
// TwoStepAuth.RecoveryEmailTitle
NSString * _Nonnull _LaZb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5408);
}
// TwoStepAuth.RecoveryEmailUnavailable
_FormattedString * _Nonnull _LaZc(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5409, _0);
}
// TwoStepAuth.RecoveryFailed
NSString * _Nonnull _LaZd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5410);
}
// TwoStepAuth.RecoveryTitle
NSString * _Nonnull _LaZe(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5411);
}
// TwoStepAuth.RecoveryUnavailable
NSString * _Nonnull _LaZf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5412);
}
// TwoStepAuth.RecoveryUnavailableResetAction
NSString * _Nonnull _LaZg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5413);
}
// TwoStepAuth.RecoveryUnavailableResetText
NSString * _Nonnull _LaZh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5414);
}
// TwoStepAuth.RecoveryUnavailableResetTitle
NSString * _Nonnull _LaZi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5415);
}
// TwoStepAuth.RemovePassword
NSString * _Nonnull _LaZj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5416);
}
// TwoStepAuth.ResetAccountConfirmation
NSString * _Nonnull _LaZk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5417);
}
// TwoStepAuth.ResetAccountHelp
NSString * _Nonnull _LaZl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5418);
}
// TwoStepAuth.ResetAction
NSString * _Nonnull _LaZm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5419);
}
// TwoStepAuth.ResetPendingText
_FormattedString * _Nonnull _LaZn(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5420, _0);
}
// TwoStepAuth.SetPassword
NSString * _Nonnull _LaZo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5421);
}
// TwoStepAuth.SetPasswordHelp
NSString * _Nonnull _LaZp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5422);
}
// TwoStepAuth.SetupEmail
NSString * _Nonnull _LaZq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5423);
}
// TwoStepAuth.SetupHint
NSString * _Nonnull _LaZr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5424);
}
// TwoStepAuth.SetupHintTitle
NSString * _Nonnull _LaZs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5425);
}
// TwoStepAuth.SetupPasswordConfirmFailed
NSString * _Nonnull _LaZt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5426);
}
// TwoStepAuth.SetupPasswordConfirmPassword
NSString * _Nonnull _LaZu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5427);
}
// TwoStepAuth.SetupPasswordDescription
NSString * _Nonnull _LaZv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5428);
}
// TwoStepAuth.SetupPasswordEnterPasswordChange
NSString * _Nonnull _LaZw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5429);
}
// TwoStepAuth.SetupPasswordEnterPasswordNew
NSString * _Nonnull _LaZx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5430);
}
// TwoStepAuth.SetupPasswordTitle
NSString * _Nonnull _LaZy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5431);
}
// TwoStepAuth.SetupPendingEmail
_FormattedString * _Nonnull _LaZz(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5432, _0);
}
// TwoStepAuth.SetupResendEmailCode
NSString * _Nonnull _LaZA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5433);
}
// TwoStepAuth.SetupResendEmailCodeAlert
NSString * _Nonnull _LaZB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5434);
}
// TwoStepAuth.Title
NSString * _Nonnull _LaZC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5435);
}
// Undo.ChatCleared
NSString * _Nonnull _LaZD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5436);
}
// Undo.ChatClearedForBothSides
NSString * _Nonnull _LaZE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5437);
}
// Undo.ChatClearedForEveryone
NSString * _Nonnull _LaZF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5438);
}
// Undo.ChatDeleted
NSString * _Nonnull _LaZG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5439);
}
// Undo.ChatDeletedForBothSides
NSString * _Nonnull _LaZH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5440);
}
// Undo.DeletedChannel
NSString * _Nonnull _LaZI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5441);
}
// Undo.DeletedGroup
NSString * _Nonnull _LaZJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5442);
}
// Undo.DeletedTopic
NSString * _Nonnull _LaZK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5443);
}
// Undo.LeftChannel
NSString * _Nonnull _LaZL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5444);
}
// Undo.LeftGroup
NSString * _Nonnull _LaZM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5445);
}
// Undo.ScheduledMessagesCleared
NSString * _Nonnull _LaZN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5446);
}
// Undo.SecretChatDeleted
NSString * _Nonnull _LaZO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5447);
}
// Undo.Undo
NSString * _Nonnull _LaZP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5448);
}
// Update.AppVersion
_FormattedString * _Nonnull _LaZQ(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5449, _0);
}
// Update.Skip
NSString * _Nonnull _LaZR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5450);
}
// Update.Title
NSString * _Nonnull _LaZS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5451);
}
// Update.UpdateApp
NSString * _Nonnull _LaZT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5452);
}
// User.DeletedAccount
NSString * _Nonnull _LaZU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5453);
}
// UserCount
NSString * _Nonnull _LaZV(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 5454, value);
}
// UserInfo.About.Placeholder
NSString * _Nonnull _LaZW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5455);
}
// UserInfo.AddContact
NSString * _Nonnull _LaZX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5456);
}
// UserInfo.AddPhone
NSString * _Nonnull _LaZY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5457);
}
// UserInfo.AddToExisting
NSString * _Nonnull _LaZZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5458);
}
// UserInfo.AnonymousNumberInfo
NSString * _Nonnull _Lbaa(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5459);
}
// UserInfo.AnonymousNumberLabel
NSString * _Nonnull _Lbab(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5460);
}
// UserInfo.BlockActionTitle
_FormattedString * _Nonnull _Lbac(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5461, _0);
}
// UserInfo.BlockConfirmation
_FormattedString * _Nonnull _Lbad(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5462, _0);
}
// UserInfo.BlockConfirmationTitle
_FormattedString * _Nonnull _Lbae(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5463, _0);
}
// UserInfo.BotHelp
NSString * _Nonnull _Lbaf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5464);
}
// UserInfo.BotPrivacy
NSString * _Nonnull _Lbag(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5465);
}
// UserInfo.BotSettings
NSString * _Nonnull _Lbah(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5466);
}
// UserInfo.ChangeColors
NSString * _Nonnull _Lbai(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5467);
}
// UserInfo.ChangeCustomPhoto
_FormattedString * _Nonnull _Lbaj(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5468, _0);
}
// UserInfo.ContactForwardTooltip.Chat.One
_FormattedString * _Nonnull _Lbak(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5469, _0);
}
// UserInfo.ContactForwardTooltip.ManyChats.One
_FormattedString * _Nonnull _Lbal(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 5470, _0, _1);
}
// UserInfo.ContactForwardTooltip.SavedMessages.One
NSString * _Nonnull _Lbam(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5471);
}
// UserInfo.ContactForwardTooltip.TwoChats.One
_FormattedString * _Nonnull _Lban(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 5472, _0, _1);
}
// UserInfo.CreateNewContact
NSString * _Nonnull _Lbao(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5473);
}
// UserInfo.CustomPhoto
NSString * _Nonnull _Lbap(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5474);
}
// UserInfo.CustomPhotoInfo
_FormattedString * _Nonnull _Lbaq(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5475, _0);
}
// UserInfo.CustomVideo
NSString * _Nonnull _Lbar(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5476);
}
// UserInfo.DeleteContact
NSString * _Nonnull _Lbas(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5477);
}
// UserInfo.FakeBotWarning
NSString * _Nonnull _Lbat(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5478);
}
// UserInfo.FakeUserWarning
NSString * _Nonnull _Lbau(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5479);
}
// UserInfo.FirstNamePlaceholder
NSString * _Nonnull _Lbav(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5480);
}
// UserInfo.GenericPhoneLabel
NSString * _Nonnull _Lbaw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5481);
}
// UserInfo.GroupsInCommon
NSString * _Nonnull _Lbax(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5482);
}
// UserInfo.Invite
NSString * _Nonnull _Lbay(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5483);
}
// UserInfo.InviteBotToGroup
NSString * _Nonnull _Lbaz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5484);
}
// UserInfo.LastNamePlaceholder
NSString * _Nonnull _LbaA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5485);
}
// UserInfo.LinkForwardTooltip.Chat.One
_FormattedString * _Nonnull _LbaB(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5486, _0);
}
// UserInfo.LinkForwardTooltip.ManyChats.One
_FormattedString * _Nonnull _LbaC(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 5487, _0, _1);
}
// UserInfo.LinkForwardTooltip.SavedMessages.One
NSString * _Nonnull _LbaD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5488);
}
// UserInfo.LinkForwardTooltip.TwoChats.One
_FormattedString * _Nonnull _LbaE(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 5489, _0, _1);
}
// UserInfo.NotificationsDefault
NSString * _Nonnull _LbaF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5490);
}
// UserInfo.NotificationsDefaultDisabled
NSString * _Nonnull _LbaG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5491);
}
// UserInfo.NotificationsDefaultEnabled
NSString * _Nonnull _LbaH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5492);
}
// UserInfo.NotificationsDefaultSound
_FormattedString * _Nonnull _LbaI(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5493, _0);
}
// UserInfo.NotificationsDisable
NSString * _Nonnull _LbaJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5494);
}
// UserInfo.NotificationsDisabled
NSString * _Nonnull _LbaK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5495);
}
// UserInfo.NotificationsEnable
NSString * _Nonnull _LbaL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5496);
}
// UserInfo.NotificationsEnabled
NSString * _Nonnull _LbaM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5497);
}
// UserInfo.PhoneCall
NSString * _Nonnull _LbaN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5498);
}
// UserInfo.PublicPhoto
NSString * _Nonnull _LbaO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5499);
}
// UserInfo.PublicVideo
NSString * _Nonnull _LbaP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5500);
}
// UserInfo.RemoveCustomPhoto
NSString * _Nonnull _LbaQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5501);
}
// UserInfo.RemoveCustomVideo
NSString * _Nonnull _LbaR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5502);
}
// UserInfo.ResetCustomPhoto
NSString * _Nonnull _LbaS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5503);
}
// UserInfo.ResetCustomVideo
NSString * _Nonnull _LbaT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5504);
}
// UserInfo.ResetToOriginalAlertReset
NSString * _Nonnull _LbaU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5505);
}
// UserInfo.ResetToOriginalAlertText
_FormattedString * _Nonnull _LbaV(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5506, _0);
}
// UserInfo.ScamBotWarning
NSString * _Nonnull _LbaW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5507);
}
// UserInfo.ScamUserWarning
NSString * _Nonnull _LbaX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5508);
}
// UserInfo.SendMessage
NSString * _Nonnull _LbaY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5509);
}
// UserInfo.SetCustomPhoto
_FormattedString * _Nonnull _LbaZ(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5510, _0);
}
// UserInfo.SetCustomPhoto.AlertPhotoText
_FormattedString * _Nonnull _Lbba(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 5511, _0, _1);
}
// UserInfo.SetCustomPhoto.AlertSet
NSString * _Nonnull _Lbbb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5512);
}
// UserInfo.SetCustomPhoto.AlertVideoText
_FormattedString * _Nonnull _Lbbc(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 5513, _0, _1);
}
// UserInfo.SetCustomPhoto.SuccessPhotoText
_FormattedString * _Nonnull _Lbbd(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5514, _0);
}
// UserInfo.SetCustomPhoto.SuccessVideoText
_FormattedString * _Nonnull _Lbbe(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5515, _0);
}
// UserInfo.SetCustomPhotoTitle
_FormattedString * _Nonnull _Lbbf(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5516, _0);
}
// UserInfo.ShareBot
NSString * _Nonnull _Lbbg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5517);
}
// UserInfo.ShareContact
NSString * _Nonnull _Lbbh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5518);
}
// UserInfo.ShareMyContactInfo
NSString * _Nonnull _Lbbi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5519);
}
// UserInfo.StartSecretChat
NSString * _Nonnull _Lbbj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5520);
}
// UserInfo.StartSecretChatConfirmation
_FormattedString * _Nonnull _Lbbk(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5521, _0);
}
// UserInfo.StartSecretChatStart
NSString * _Nonnull _Lbbl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5522);
}
// UserInfo.SuggestPhoto
_FormattedString * _Nonnull _Lbbm(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5523, _0);
}
// UserInfo.SuggestPhoto.AlertPhotoText
_FormattedString * _Nonnull _Lbbn(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5524, _0);
}
// UserInfo.SuggestPhoto.AlertSuggest
NSString * _Nonnull _Lbbo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5525);
}
// UserInfo.SuggestPhoto.AlertVideoText
_FormattedString * _Nonnull _Lbbp(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5526, _0);
}
// UserInfo.SuggestPhotoTitle
_FormattedString * _Nonnull _Lbbq(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5527, _0);
}
// UserInfo.TapToCall
NSString * _Nonnull _Lbbr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5528);
}
// UserInfo.TelegramCall
NSString * _Nonnull _Lbbs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5529);
}
// UserInfo.TelegramVideoCall
NSString * _Nonnull _Lbbt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5530);
}
// UserInfo.Title
NSString * _Nonnull _Lbbu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5531);
}
// UserInfo.UnblockConfirmation
_FormattedString * _Nonnull _Lbbv(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5532, _0);
}
// Username.ActivateAlertShow
NSString * _Nonnull _Lbbw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5533);
}
// Username.ActivateAlertText
NSString * _Nonnull _Lbbx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5534);
}
// Username.ActivateAlertTitle
NSString * _Nonnull _Lbby(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5535);
}
// Username.ActiveLimitReachedError
NSString * _Nonnull _Lbbz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5536);
}
// Username.CheckingUsername
NSString * _Nonnull _LbbA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5537);
}
// Username.DeactivateAlertHide
NSString * _Nonnull _LbbB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5538);
}
// Username.DeactivateAlertText
NSString * _Nonnull _LbbC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5539);
}
// Username.DeactivateAlertTitle
NSString * _Nonnull _LbbD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5540);
}
// Username.Help
NSString * _Nonnull _LbbE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5541);
}
// Username.InvalidCharacters
NSString * _Nonnull _LbbF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5542);
}
// Username.InvalidEndsWithUnderscore
NSString * _Nonnull _LbbG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5543);
}
// Username.InvalidStartsWithNumber
NSString * _Nonnull _LbbH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5544);
}
// Username.InvalidStartsWithUnderscore
NSString * _Nonnull _LbbI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5545);
}
// Username.InvalidTaken
NSString * _Nonnull _LbbJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5546);
}
// Username.InvalidTooShort
NSString * _Nonnull _LbbK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5547);
}
// Username.LinkCopied
NSString * _Nonnull _LbbL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5548);
}
// Username.LinkHint
_FormattedString * _Nonnull _LbbM(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5549, _0);
}
// Username.LinksOrder
NSString * _Nonnull _LbbN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5550);
}
// Username.LinksOrderInfo
NSString * _Nonnull _LbbO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5551);
}
// Username.Placeholder
NSString * _Nonnull _LbbP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5552);
}
// Username.Title
NSString * _Nonnull _LbbQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5553);
}
// Username.TooManyPublicUsernamesError
NSString * _Nonnull _LbbR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5554);
}
// Username.Username
NSString * _Nonnull _LbbS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5555);
}
// Username.UsernameIsAvailable
_FormattedString * _Nonnull _LbbT(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5556, _0);
}
// Username.UsernamePurchaseAvailable
NSString * _Nonnull _LbbU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5557);
}
// VideoChat.RecordingSaved
NSString * _Nonnull _LbbV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5558);
}
// VoiceChat.AddBio
NSString * _Nonnull _LbbW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5559);
}
// VoiceChat.AddPhoto
NSString * _Nonnull _LbbX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5560);
}
// VoiceChat.AnonymousDisabledAlertText
NSString * _Nonnull _LbbY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5561);
}
// VoiceChat.AskedToSpeak
NSString * _Nonnull _LbbZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5562);
}
// VoiceChat.AskedToSpeakHelp
NSString * _Nonnull _Lbca(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5563);
}
// VoiceChat.Audio
NSString * _Nonnull _Lbcb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5564);
}
// VoiceChat.CancelConfirmationEnd
NSString * _Nonnull _Lbcc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5565);
}
// VoiceChat.CancelConfirmationText
NSString * _Nonnull _Lbcd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5566);
}
// VoiceChat.CancelConfirmationTitle
NSString * _Nonnull _Lbce(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5567);
}
// VoiceChat.CancelLiveStream
NSString * _Nonnull _Lbcf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5568);
}
// VoiceChat.CancelReminder
NSString * _Nonnull _Lbcg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5569);
}
// VoiceChat.CancelSpeakRequest
NSString * _Nonnull _Lbch(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5570);
}
// VoiceChat.CancelVoiceChat
NSString * _Nonnull _Lbci(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5571);
}
// VoiceChat.ChangeName
NSString * _Nonnull _Lbcj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5572);
}
// VoiceChat.ChangeNameTitle
NSString * _Nonnull _Lbck(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5573);
}
// VoiceChat.ChangePhoto
NSString * _Nonnull _Lbcl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5574);
}
// VoiceChat.ChatFullAlertText
NSString * _Nonnull _Lbcm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5575);
}
// VoiceChat.Connecting
NSString * _Nonnull _Lbcn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5576);
}
// VoiceChat.ContextAudio
NSString * _Nonnull _Lbco(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5577);
}
// VoiceChat.CopyInviteLink
NSString * _Nonnull _Lbcp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5578);
}
// VoiceChat.CreateNewVoiceChatSchedule
NSString * _Nonnull _Lbcq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5579);
}
// VoiceChat.CreateNewVoiceChatStart
NSString * _Nonnull _Lbcr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5580);
}
// VoiceChat.CreateNewVoiceChatStartNow
NSString * _Nonnull _Lbcs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5581);
}
// VoiceChat.CreateNewVoiceChatText
NSString * _Nonnull _Lbct(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5582);
}
// VoiceChat.DiscussionGroup
NSString * _Nonnull _Lbcu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5583);
}
// VoiceChat.DisplayAs
NSString * _Nonnull _Lbcv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5584);
}
// VoiceChat.DisplayAsInfo
NSString * _Nonnull _Lbcw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5585);
}
// VoiceChat.DisplayAsInfoGroup
NSString * _Nonnull _Lbcx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5586);
}
// VoiceChat.DisplayAsSuccess
_FormattedString * _Nonnull _Lbcy(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5587, _0);
}
// VoiceChat.EditBio
NSString * _Nonnull _Lbcz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5588);
}
// VoiceChat.EditBioPlaceholder
NSString * _Nonnull _LbcA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5589);
}
// VoiceChat.EditBioSave
NSString * _Nonnull _LbcB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5590);
}
// VoiceChat.EditBioSuccess
NSString * _Nonnull _LbcC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5591);
}
// VoiceChat.EditBioText
NSString * _Nonnull _LbcD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5592);
}
// VoiceChat.EditBioTitle
NSString * _Nonnull _LbcE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5593);
}
// VoiceChat.EditDescription
NSString * _Nonnull _LbcF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5594);
}
// VoiceChat.EditDescriptionPlaceholder
NSString * _Nonnull _LbcG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5595);
}
// VoiceChat.EditDescriptionSave
NSString * _Nonnull _LbcH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5596);
}
// VoiceChat.EditDescriptionSuccess
NSString * _Nonnull _LbcI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5597);
}
// VoiceChat.EditDescriptionText
NSString * _Nonnull _LbcJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5598);
}
// VoiceChat.EditDescriptionTitle
NSString * _Nonnull _LbcK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5599);
}
// VoiceChat.EditNameSuccess
NSString * _Nonnull _LbcL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5600);
}
// VoiceChat.EditPermissions
NSString * _Nonnull _LbcM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5601);
}
// VoiceChat.EditTitle
NSString * _Nonnull _LbcN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5602);
}
// VoiceChat.EditTitleRemoveSuccess
NSString * _Nonnull _LbcO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5603);
}
// VoiceChat.EditTitleSuccess
_FormattedString * _Nonnull _LbcP(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5604, _0);
}
// VoiceChat.EditTitleText
NSString * _Nonnull _LbcQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5605);
}
// VoiceChat.EndConfirmationEnd
NSString * _Nonnull _LbcR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5606);
}
// VoiceChat.EndConfirmationText
NSString * _Nonnull _LbcS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5607);
}
// VoiceChat.EndConfirmationTitle
NSString * _Nonnull _LbcT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5608);
}
// VoiceChat.EndLiveStream
NSString * _Nonnull _LbcU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5609);
}
// VoiceChat.EndVoiceChat
NSString * _Nonnull _LbcV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5610);
}
// VoiceChat.ForwardTooltip.Chat
_FormattedString * _Nonnull _LbcW(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5611, _0);
}
// VoiceChat.ForwardTooltip.ManyChats
_FormattedString * _Nonnull _LbcX(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 5612, _0, _1);
}
// VoiceChat.ForwardTooltip.TwoChats
_FormattedString * _Nonnull _LbcY(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 5613, _0, _1);
}
// VoiceChat.ImproveYourProfileText
NSString * _Nonnull _LbcZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5614);
}
// VoiceChat.InviteLink.CopyListenerLink
NSString * _Nonnull _Lbda(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5615);
}
// VoiceChat.InviteLink.CopySpeakerLink
NSString * _Nonnull _Lbdb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5616);
}
// VoiceChat.InviteLink.InviteListeners
NSString * _Nonnull _Lbdc(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 5617, value);
}
// VoiceChat.InviteLink.InviteSpeakers
NSString * _Nonnull _Lbdd(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 5618, value);
}
// VoiceChat.InviteLink.Listener
NSString * _Nonnull _Lbde(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5619);
}
// VoiceChat.InviteLink.Speaker
NSString * _Nonnull _Lbdf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5620);
}
// VoiceChat.InviteLinkCopiedText
NSString * _Nonnull _Lbdg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5621);
}
// VoiceChat.InviteMember
NSString * _Nonnull _Lbdh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5622);
}
// VoiceChat.InviteMemberToChannelFirstText
_FormattedString * _Nonnull _Lbdi(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 5623, _0, _1);
}
// VoiceChat.InviteMemberToGroupFirstAdd
NSString * _Nonnull _Lbdj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5624);
}
// VoiceChat.InviteMemberToGroupFirstText
_FormattedString * _Nonnull _Lbdk(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 5625, _0, _1);
}
// VoiceChat.InvitedPeerText
_FormattedString * _Nonnull _Lbdl(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5626, _0);
}
// VoiceChat.LateBy
NSString * _Nonnull _Lbdm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5627);
}
// VoiceChat.Leave
NSString * _Nonnull _Lbdn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5628);
}
// VoiceChat.LeaveAndCancelVoiceChat
NSString * _Nonnull _Lbdo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5629);
}
// VoiceChat.LeaveAndEndVoiceChat
NSString * _Nonnull _Lbdp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5630);
}
// VoiceChat.LeaveConfirmation
NSString * _Nonnull _Lbdq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5631);
}
// VoiceChat.LeaveVoiceChat
NSString * _Nonnull _Lbdr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5632);
}
// VoiceChat.Live
NSString * _Nonnull _Lbds(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5633);
}
// VoiceChat.Mute
NSString * _Nonnull _Lbdt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5634);
}
// VoiceChat.MuteForMe
NSString * _Nonnull _Lbdu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5635);
}
// VoiceChat.MutePeer
NSString * _Nonnull _Lbdv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5636);
}
// VoiceChat.Muted
NSString * _Nonnull _Lbdw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5637);
}
// VoiceChat.MutedByAdmin
NSString * _Nonnull _Lbdx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5638);
}
// VoiceChat.MutedByAdminHelp
NSString * _Nonnull _Lbdy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5639);
}
// VoiceChat.MutedHelp
NSString * _Nonnull _Lbdz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5640);
}
// VoiceChat.NoiseSuppression
NSString * _Nonnull _LbdA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5641);
}
// VoiceChat.NoiseSuppressionDisabled
NSString * _Nonnull _LbdB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5642);
}
// VoiceChat.NoiseSuppressionEnabled
NSString * _Nonnull _LbdC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5643);
}
// VoiceChat.OpenChannel
NSString * _Nonnull _LbdD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5644);
}
// VoiceChat.OpenChat
NSString * _Nonnull _LbdE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5645);
}
// VoiceChat.OpenGroup
NSString * _Nonnull _LbdF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5646);
}
// VoiceChat.Panel.Members
NSString * _Nonnull _LbdG(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 5647, value);
}
// VoiceChat.Panel.TapToJoin
NSString * _Nonnull _LbdH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5648);
}
// VoiceChat.PanelJoin
NSString * _Nonnull _LbdI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5649);
}
// VoiceChat.ParticipantIsSpeaking
_FormattedString * _Nonnull _LbdJ(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5650, _0);
}
// VoiceChat.PeerJoinedText
_FormattedString * _Nonnull _LbdK(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5651, _0);
}
// VoiceChat.PersonalAccount
NSString * _Nonnull _LbdL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5652);
}
// VoiceChat.PinVideo
NSString * _Nonnull _LbdM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5653);
}
// VoiceChat.Reconnecting
NSString * _Nonnull _LbdN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5654);
}
// VoiceChat.RecordLandscape
NSString * _Nonnull _LbdO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5655);
}
// VoiceChat.RecordOnlyAudio
NSString * _Nonnull _LbdP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5656);
}
// VoiceChat.RecordPortrait
NSString * _Nonnull _LbdQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5657);
}
// VoiceChat.RecordStartRecording
NSString * _Nonnull _LbdR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5658);
}
// VoiceChat.RecordTitle
NSString * _Nonnull _LbdS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5659);
}
// VoiceChat.RecordVideoAndAudio
NSString * _Nonnull _LbdT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5660);
}
// VoiceChat.RecordingInProgress
NSString * _Nonnull _LbdU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5661);
}
// VoiceChat.RecordingSaved
NSString * _Nonnull _LbdV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5662);
}
// VoiceChat.RecordingStarted
NSString * _Nonnull _LbdW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5663);
}
// VoiceChat.RecordingTitlePlaceholder
NSString * _Nonnull _LbdX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5664);
}
// VoiceChat.RecordingTitlePlaceholderVideo
NSString * _Nonnull _LbdY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5665);
}
// VoiceChat.ReminderNotify
NSString * _Nonnull _LbdZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5666);
}
// VoiceChat.RemoveAndBanPeerConfirmation
_FormattedString * _Nonnull _Lbea(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 5667, _0, _1);
}
// VoiceChat.RemovePeer
NSString * _Nonnull _Lbeb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5668);
}
// VoiceChat.RemovePeerConfirmation
_FormattedString * _Nonnull _Lbec(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5669, _0);
}
// VoiceChat.RemovePeerConfirmationChannel
_FormattedString * _Nonnull _Lbed(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5670, _0);
}
// VoiceChat.RemovePeerRemove
NSString * _Nonnull _Lbee(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5671);
}
// VoiceChat.RemovedPeerText
_FormattedString * _Nonnull _Lbef(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5672, _0);
}
// VoiceChat.Scheduled
NSString * _Nonnull _Lbeg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5673);
}
// VoiceChat.SelectAccount
NSString * _Nonnull _Lbeh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5674);
}
// VoiceChat.SendPublicLinkSend
NSString * _Nonnull _Lbei(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5675);
}
// VoiceChat.SendPublicLinkText
_FormattedString * _Nonnull _Lbej(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 5676, _0, _1);
}
// VoiceChat.SetReminder
NSString * _Nonnull _Lbek(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5677);
}
// VoiceChat.Share
NSString * _Nonnull _Lbel(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5678);
}
// VoiceChat.ShareScreen
NSString * _Nonnull _Lbem(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5679);
}
// VoiceChat.ShareShort
NSString * _Nonnull _Lben(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5680);
}
// VoiceChat.SpeakPermissionAdmin
NSString * _Nonnull _Lbeo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5681);
}
// VoiceChat.SpeakPermissionEveryone
NSString * _Nonnull _Lbep(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5682);
}
// VoiceChat.StartNow
NSString * _Nonnull _Lbeq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5683);
}
// VoiceChat.StartRecording
NSString * _Nonnull _Lber(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5684);
}
// VoiceChat.StartRecordingStart
NSString * _Nonnull _Lbes(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5685);
}
// VoiceChat.StartRecordingText
NSString * _Nonnull _Lbet(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5686);
}
// VoiceChat.StartRecordingTextVideo
NSString * _Nonnull _Lbeu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5687);
}
// VoiceChat.StartRecordingTitle
NSString * _Nonnull _Lbev(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5688);
}
// VoiceChat.StartsIn
NSString * _Nonnull _Lbew(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5689);
}
// VoiceChat.Status.Members
NSString * _Nonnull _Lbex(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 5690, value);
}
// VoiceChat.Status.MembersFormat
_FormattedString * _Nonnull _Lbey(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 5691, _0, _1);
}
// VoiceChat.StatusInvited
NSString * _Nonnull _Lbez(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5692);
}
// VoiceChat.StatusLateBy
_FormattedString * _Nonnull _LbeA(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5693, _0);
}
// VoiceChat.StatusListening
NSString * _Nonnull _LbeB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5694);
}
// VoiceChat.StatusMutedForYou
NSString * _Nonnull _LbeC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5695);
}
// VoiceChat.StatusMutedYou
NSString * _Nonnull _LbeD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5696);
}
// VoiceChat.StatusSpeaking
NSString * _Nonnull _LbeE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5697);
}
// VoiceChat.StatusSpeakingVolume
_FormattedString * _Nonnull _LbeF(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5698, _0);
}
// VoiceChat.StatusStartsIn
_FormattedString * _Nonnull _LbeG(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5699, _0);
}
// VoiceChat.StatusWantsToSpeak
NSString * _Nonnull _LbeH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5700);
}
// VoiceChat.StopRecording
NSString * _Nonnull _LbeI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5701);
}
// VoiceChat.StopRecordingStop
NSString * _Nonnull _LbeJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5702);
}
// VoiceChat.StopRecordingTitle
NSString * _Nonnull _LbeK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5703);
}
// VoiceChat.StopScreenSharing
NSString * _Nonnull _LbeL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5704);
}
// VoiceChat.StopScreenSharingShort
NSString * _Nonnull _LbeM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5705);
}
// VoiceChat.TapToAddBio
NSString * _Nonnull _LbeN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5706);
}
// VoiceChat.TapToAddPhoto
NSString * _Nonnull _LbeO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5707);
}
// VoiceChat.TapToAddPhotoOrBio
NSString * _Nonnull _LbeP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5708);
}
// VoiceChat.TapToEditTitle
NSString * _Nonnull _LbeQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5709);
}
// VoiceChat.TapToViewCameraVideo
NSString * _Nonnull _LbeR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5710);
}
// VoiceChat.TapToViewScreenVideo
NSString * _Nonnull _LbeS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5711);
}
// VoiceChat.Title
NSString * _Nonnull _LbeT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5712);
}
// VoiceChat.Unmute
NSString * _Nonnull _LbeU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5713);
}
// VoiceChat.UnmuteForMe
NSString * _Nonnull _LbeV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5714);
}
// VoiceChat.UnmuteHelp
NSString * _Nonnull _LbeW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5715);
}
// VoiceChat.UnmutePeer
NSString * _Nonnull _LbeX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5716);
}
// VoiceChat.UnmuteSuggestion
NSString * _Nonnull _LbeY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5717);
}
// VoiceChat.Unpin
NSString * _Nonnull _LbeZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5718);
}
// VoiceChat.UnpinVideo
NSString * _Nonnull _Lbfa(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5719);
}
// VoiceChat.UserCanNowSpeak
_FormattedString * _Nonnull _Lbfb(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5720, _0);
}
// VoiceChat.Video
NSString * _Nonnull _Lbfc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5721);
}
// VoiceChat.VideoParticipantsLimitExceeded
_FormattedString * _Nonnull _Lbfd(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5722, _0);
}
// VoiceChat.VideoParticipantsLimitExceededExtended
_FormattedString * _Nonnull _Lbfe(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5723, _0);
}
// VoiceChat.VideoPaused
NSString * _Nonnull _Lbff(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5724);
}
// VoiceChat.VideoPreviewBackCamera
NSString * _Nonnull _Lbfg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5725);
}
// VoiceChat.VideoPreviewContinue
NSString * _Nonnull _Lbfh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5726);
}
// VoiceChat.VideoPreviewDescription
NSString * _Nonnull _Lbfi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5727);
}
// VoiceChat.VideoPreviewFrontCamera
NSString * _Nonnull _Lbfj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5728);
}
// VoiceChat.VideoPreviewPhoneScreen
NSString * _Nonnull _Lbfk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5729);
}
// VoiceChat.VideoPreviewShareCamera
NSString * _Nonnull _Lbfl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5730);
}
// VoiceChat.VideoPreviewShareScreen
NSString * _Nonnull _Lbfm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5731);
}
// VoiceChat.VideoPreviewShareScreenInfo
NSString * _Nonnull _Lbfn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5732);
}
// VoiceChat.VideoPreviewStopScreenSharing
NSString * _Nonnull _Lbfo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5733);
}
// VoiceChat.VideoPreviewTabletScreen
NSString * _Nonnull _Lbfp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5734);
}
// VoiceChat.VideoPreviewTitle
NSString * _Nonnull _Lbfq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5735);
}
// VoiceChat.You
NSString * _Nonnull _Lbfr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5736);
}
// VoiceChat.YouAreSharingScreen
NSString * _Nonnull _Lbfs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5737);
}
// VoiceChat.YouCanNowSpeak
NSString * _Nonnull _Lbft(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5738);
}
// VoiceChat.YouCanNowSpeakIn
_FormattedString * _Nonnull _Lbfu(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5739, _0);
}
// VoiceChatChannel.Title
NSString * _Nonnull _Lbfv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5740);
}
// VoiceOver.AttachMedia
NSString * _Nonnull _Lbfw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5741);
}
// VoiceOver.AuthSessions.CurrentSession
NSString * _Nonnull _Lbfx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5742);
}
// VoiceOver.BotCommands
NSString * _Nonnull _Lbfy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5743);
}
// VoiceOver.BotKeyboard
NSString * _Nonnull _Lbfz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5744);
}
// VoiceOver.Chat.AnimatedSticker
NSString * _Nonnull _LbfA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5745);
}
// VoiceOver.Chat.AnimatedStickerFrom
_FormattedString * _Nonnull _LbfB(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5746, _0);
}
// VoiceOver.Chat.AnonymousPoll
NSString * _Nonnull _LbfC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5747);
}
// VoiceOver.Chat.AnonymousPollFrom
_FormattedString * _Nonnull _LbfD(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5748, _0);
}
// VoiceOver.Chat.Caption
_FormattedString * _Nonnull _LbfE(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5749, _0);
}
// VoiceOver.Chat.ChannelInfo
NSString * _Nonnull _LbfF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5750);
}
// VoiceOver.Chat.Contact
NSString * _Nonnull _LbfG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5751);
}
// VoiceOver.Chat.ContactEmail
NSString * _Nonnull _LbfH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5752);
}
// VoiceOver.Chat.ContactEmailCount
NSString * _Nonnull _LbfI(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 5753, value);
}
// VoiceOver.Chat.ContactFrom
_FormattedString * _Nonnull _LbfJ(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5754, _0);
}
// VoiceOver.Chat.ContactOrganization
_FormattedString * _Nonnull _LbfK(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5755, _0);
}
// VoiceOver.Chat.ContactPhoneNumber
NSString * _Nonnull _LbfL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5756);
}
// VoiceOver.Chat.ContactPhoneNumberCount
NSString * _Nonnull _LbfM(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 5757, value);
}
// VoiceOver.Chat.Duration
_FormattedString * _Nonnull _LbfN(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5758, _0);
}
// VoiceOver.Chat.File
NSString * _Nonnull _LbfO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5759);
}
// VoiceOver.Chat.FileFrom
_FormattedString * _Nonnull _LbfP(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5760, _0);
}
// VoiceOver.Chat.ForwardedFrom
_FormattedString * _Nonnull _LbfQ(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5761, _0);
}
// VoiceOver.Chat.ForwardedFromYou
NSString * _Nonnull _LbfR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5762);
}
// VoiceOver.Chat.GoToOriginalMessage
NSString * _Nonnull _LbfS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5763);
}
// VoiceOver.Chat.GroupInfo
NSString * _Nonnull _LbfT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5764);
}
// VoiceOver.Chat.Message
NSString * _Nonnull _LbfU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5765);
}
// VoiceOver.Chat.MessagesSelected
NSString * _Nonnull _LbfV(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 5766, value);
}
// VoiceOver.Chat.Music
NSString * _Nonnull _LbfW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5767);
}
// VoiceOver.Chat.MusicFrom
_FormattedString * _Nonnull _LbfX(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5768, _0);
}
// VoiceOver.Chat.MusicTitle
_FormattedString * _Nonnull _LbfY(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 5769, _0, _1);
}
// VoiceOver.Chat.OpenHint
NSString * _Nonnull _LbfZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5770);
}
// VoiceOver.Chat.OpenLinkHint
NSString * _Nonnull _Lbga(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5771);
}
// VoiceOver.Chat.OptionSelected
NSString * _Nonnull _Lbgb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5772);
}
// VoiceOver.Chat.PagePreview
NSString * _Nonnull _Lbgc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5773);
}
// VoiceOver.Chat.Photo
NSString * _Nonnull _Lbgd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5774);
}
// VoiceOver.Chat.PhotoFrom
_FormattedString * _Nonnull _Lbge(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5775, _0);
}
// VoiceOver.Chat.PlayHint
NSString * _Nonnull _Lbgf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5776);
}
// VoiceOver.Chat.PollFinalResults
NSString * _Nonnull _Lbgg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5777);
}
// VoiceOver.Chat.PollNoVotes
NSString * _Nonnull _Lbgh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5778);
}
// VoiceOver.Chat.PollOptionCount
NSString * _Nonnull _Lbgi(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 5779, value);
}
// VoiceOver.Chat.PollVotes
NSString * _Nonnull _Lbgj(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 5780, value);
}
// VoiceOver.Chat.Profile
NSString * _Nonnull _Lbgk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5781);
}
// VoiceOver.Chat.RecordModeVideoMessage
NSString * _Nonnull _Lbgl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5782);
}
// VoiceOver.Chat.RecordModeVideoMessageInfo
NSString * _Nonnull _Lbgm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5783);
}
// VoiceOver.Chat.RecordModeVoiceMessage
NSString * _Nonnull _Lbgn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5784);
}
// VoiceOver.Chat.RecordModeVoiceMessageInfo
NSString * _Nonnull _Lbgo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5785);
}
// VoiceOver.Chat.RecordPreviewVoiceMessage
NSString * _Nonnull _Lbgp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5786);
}
// VoiceOver.Chat.Reply
NSString * _Nonnull _Lbgq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5787);
}
// VoiceOver.Chat.ReplyFrom
_FormattedString * _Nonnull _Lbgr(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5788, _0);
}
// VoiceOver.Chat.ReplyToYourMessage
NSString * _Nonnull _Lbgs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5789);
}
// VoiceOver.Chat.SeenByRecipient
NSString * _Nonnull _Lbgt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5790);
}
// VoiceOver.Chat.SeenByRecipients
NSString * _Nonnull _Lbgu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5791);
}
// VoiceOver.Chat.Selected
NSString * _Nonnull _Lbgv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5792);
}
// VoiceOver.Chat.Size
_FormattedString * _Nonnull _Lbgw(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5793, _0);
}
// VoiceOver.Chat.Sticker
NSString * _Nonnull _Lbgx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5794);
}
// VoiceOver.Chat.StickerFrom
_FormattedString * _Nonnull _Lbgy(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5795, _0);
}
// VoiceOver.Chat.Title
_FormattedString * _Nonnull _Lbgz(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5796, _0);
}
// VoiceOver.Chat.UnreadMessages
NSString * _Nonnull _LbgA(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 5797, value);
}
// VoiceOver.Chat.Video
NSString * _Nonnull _LbgB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5798);
}
// VoiceOver.Chat.VideoFrom
_FormattedString * _Nonnull _LbgC(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5799, _0);
}
// VoiceOver.Chat.VideoMessage
NSString * _Nonnull _LbgD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5800);
}
// VoiceOver.Chat.VideoMessageFrom
_FormattedString * _Nonnull _LbgE(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5801, _0);
}
// VoiceOver.Chat.VoiceMessage
NSString * _Nonnull _LbgF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5802);
}
// VoiceOver.Chat.VoiceMessageFrom
_FormattedString * _Nonnull _LbgG(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5803, _0);
}
// VoiceOver.Chat.YourAnimatedSticker
NSString * _Nonnull _LbgH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5804);
}
// VoiceOver.Chat.YourAnonymousPoll
NSString * _Nonnull _LbgI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5805);
}
// VoiceOver.Chat.YourContact
NSString * _Nonnull _LbgJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5806);
}
// VoiceOver.Chat.YourFile
NSString * _Nonnull _LbgK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5807);
}
// VoiceOver.Chat.YourMessage
NSString * _Nonnull _LbgL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5808);
}
// VoiceOver.Chat.YourMusic
NSString * _Nonnull _LbgM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5809);
}
// VoiceOver.Chat.YourPhoto
NSString * _Nonnull _LbgN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5810);
}
// VoiceOver.Chat.YourSticker
NSString * _Nonnull _LbgO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5811);
}
// VoiceOver.Chat.YourVideo
NSString * _Nonnull _LbgP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5812);
}
// VoiceOver.Chat.YourVideoMessage
NSString * _Nonnull _LbgQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5813);
}
// VoiceOver.Chat.YourVoiceMessage
NSString * _Nonnull _LbgR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5814);
}
// VoiceOver.ChatList.Message
NSString * _Nonnull _LbgS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5815);
}
// VoiceOver.ChatList.MessageEmpty
NSString * _Nonnull _LbgT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5816);
}
// VoiceOver.ChatList.MessageFrom
_FormattedString * _Nonnull _LbgU(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5817, _0);
}
// VoiceOver.ChatList.MessageRead
NSString * _Nonnull _LbgV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5818);
}
// VoiceOver.ChatList.OutgoingMessage
NSString * _Nonnull _LbgW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5819);
}
// VoiceOver.Common.Off
NSString * _Nonnull _LbgX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5820);
}
// VoiceOver.Common.On
NSString * _Nonnull _LbgY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5821);
}
// VoiceOver.Common.SwitchHint
NSString * _Nonnull _LbgZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5822);
}
// VoiceOver.DiscardPreparedContent
NSString * _Nonnull _Lbha(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5823);
}
// VoiceOver.DismissContextMenu
NSString * _Nonnull _Lbhb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5824);
}
// VoiceOver.Editing.ClearText
NSString * _Nonnull _Lbhc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5825);
}
// VoiceOver.Keyboard
NSString * _Nonnull _Lbhd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5826);
}
// VoiceOver.Media.PlaybackPause
NSString * _Nonnull _Lbhe(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5827);
}
// VoiceOver.Media.PlaybackPlay
NSString * _Nonnull _Lbhf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5828);
}
// VoiceOver.Media.PlaybackRate
NSString * _Nonnull _Lbhg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5829);
}
// VoiceOver.Media.PlaybackRateChange
NSString * _Nonnull _Lbhh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5830);
}
// VoiceOver.Media.PlaybackRateFast
NSString * _Nonnull _Lbhi(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5831);
}
// VoiceOver.Media.PlaybackRateNormal
NSString * _Nonnull _Lbhj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5832);
}
// VoiceOver.Media.PlaybackStop
NSString * _Nonnull _Lbhk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5833);
}
// VoiceOver.MessageContextDelete
NSString * _Nonnull _Lbhl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5834);
}
// VoiceOver.MessageContextForward
NSString * _Nonnull _Lbhm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5835);
}
// VoiceOver.MessageContextOpenMessageMenu
NSString * _Nonnull _Lbhn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5836);
}
// VoiceOver.MessageContextReply
NSString * _Nonnull _Lbho(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5837);
}
// VoiceOver.MessageContextReport
NSString * _Nonnull _Lbhp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5838);
}
// VoiceOver.MessageContextSend
NSString * _Nonnull _Lbhq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5839);
}
// VoiceOver.MessageContextShare
NSString * _Nonnull _Lbhr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5840);
}
// VoiceOver.Navigation.Compose
NSString * _Nonnull _Lbhs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5841);
}
// VoiceOver.Navigation.ProxySettings
NSString * _Nonnull _Lbht(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5842);
}
// VoiceOver.Navigation.Search
NSString * _Nonnull _Lbhu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5843);
}
// VoiceOver.Recording.StopAndPreview
NSString * _Nonnull _Lbhv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5844);
}
// VoiceOver.ScheduledMessages
NSString * _Nonnull _Lbhw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5845);
}
// VoiceOver.ScrollStatus
_FormattedString * _Nonnull _Lbhx(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 5846, _0, _1);
}
// VoiceOver.SelfDestructTimerOff
NSString * _Nonnull _Lbhy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5847);
}
// VoiceOver.SelfDestructTimerOn
_FormattedString * _Nonnull _Lbhz(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5848, _0);
}
// VoiceOver.SilentPostOff
NSString * _Nonnull _LbhA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5849);
}
// VoiceOver.SilentPostOn
NSString * _Nonnull _LbhB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5850);
}
// VoiceOver.Stickers
NSString * _Nonnull _LbhC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5851);
}
// Wallpaper.DeleteConfirmation
NSString * _Nonnull _LbhD(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 5852, value);
}
// Wallpaper.ErrorNotFound
NSString * _Nonnull _LbhE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5853);
}
// Wallpaper.PhotoLibrary
NSString * _Nonnull _LbhF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5854);
}
// Wallpaper.ResetWallpapers
NSString * _Nonnull _LbhG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5855);
}
// Wallpaper.ResetWallpapersConfirmation
NSString * _Nonnull _LbhH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5856);
}
// Wallpaper.ResetWallpapersInfo
NSString * _Nonnull _LbhI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5857);
}
// Wallpaper.Search
NSString * _Nonnull _LbhJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5858);
}
// Wallpaper.SearchShort
NSString * _Nonnull _LbhK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5859);
}
// Wallpaper.Set
NSString * _Nonnull _LbhL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5860);
}
// Wallpaper.SetColor
NSString * _Nonnull _LbhM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5861);
}
// Wallpaper.SetCustomBackground
NSString * _Nonnull _LbhN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5862);
}
// Wallpaper.SetCustomBackgroundInfo
NSString * _Nonnull _LbhO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5863);
}
// Wallpaper.Title
NSString * _Nonnull _LbhP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5864);
}
// Wallpaper.Wallpaper
NSString * _Nonnull _LbhQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5865);
}
// WallpaperColors.SetCustomColor
NSString * _Nonnull _LbhR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5866);
}
// WallpaperColors.Title
NSString * _Nonnull _LbhS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5867);
}
// WallpaperPreview.Animate
NSString * _Nonnull _LbhT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5868);
}
// WallpaperPreview.AnimateDescription
NSString * _Nonnull _LbhU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5869);
}
// WallpaperPreview.Blurred
NSString * _Nonnull _LbhV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5870);
}
// WallpaperPreview.CropBottomText
NSString * _Nonnull _LbhW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5871);
}
// WallpaperPreview.CropTopText
NSString * _Nonnull _LbhX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5872);
}
// WallpaperPreview.CustomColorBottomText
NSString * _Nonnull _LbhY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5873);
}
// WallpaperPreview.CustomColorTopText
NSString * _Nonnull _LbhZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5874);
}
// WallpaperPreview.Motion
NSString * _Nonnull _Lbia(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5875);
}
// WallpaperPreview.Pattern
NSString * _Nonnull _Lbib(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5876);
}
// WallpaperPreview.PatternIntensity
NSString * _Nonnull _Lbic(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5877);
}
// WallpaperPreview.PatternPaternApply
NSString * _Nonnull _Lbid(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5878);
}
// WallpaperPreview.PatternPaternDiscard
NSString * _Nonnull _Lbie(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5879);
}
// WallpaperPreview.PatternTitle
NSString * _Nonnull _Lbif(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5880);
}
// WallpaperPreview.PreviewBottomText
NSString * _Nonnull _Lbig(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5881);
}
// WallpaperPreview.PreviewBottomTextAnimatable
NSString * _Nonnull _Lbih(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5882);
}
// WallpaperPreview.PreviewTopText
NSString * _Nonnull _Lbii(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5883);
}
// WallpaperPreview.SwipeBottomText
NSString * _Nonnull _Lbij(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5884);
}
// WallpaperPreview.SwipeColorsBottomText
NSString * _Nonnull _Lbik(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5885);
}
// WallpaperPreview.SwipeColorsTopText
NSString * _Nonnull _Lbil(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5886);
}
// WallpaperPreview.SwipeTopText
NSString * _Nonnull _Lbim(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5887);
}
// WallpaperPreview.Title
NSString * _Nonnull _Lbin(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5888);
}
// WallpaperPreview.WallpaperColors
NSString * _Nonnull _Lbio(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5889);
}
// WallpaperSearch.ColorBlack
NSString * _Nonnull _Lbip(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5890);
}
// WallpaperSearch.ColorBlue
NSString * _Nonnull _Lbiq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5891);
}
// WallpaperSearch.ColorBrown
NSString * _Nonnull _Lbir(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5892);
}
// WallpaperSearch.ColorGray
NSString * _Nonnull _Lbis(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5893);
}
// WallpaperSearch.ColorGreen
NSString * _Nonnull _Lbit(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5894);
}
// WallpaperSearch.ColorOrange
NSString * _Nonnull _Lbiu(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5895);
}
// WallpaperSearch.ColorPink
NSString * _Nonnull _Lbiv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5896);
}
// WallpaperSearch.ColorPrefix
NSString * _Nonnull _Lbiw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5897);
}
// WallpaperSearch.ColorPurple
NSString * _Nonnull _Lbix(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5898);
}
// WallpaperSearch.ColorRed
NSString * _Nonnull _Lbiy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5899);
}
// WallpaperSearch.ColorTeal
NSString * _Nonnull _Lbiz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5900);
}
// WallpaperSearch.ColorTitle
NSString * _Nonnull _LbiA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5901);
}
// WallpaperSearch.ColorWhite
NSString * _Nonnull _LbiB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5902);
}
// WallpaperSearch.ColorYellow
NSString * _Nonnull _LbiC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5903);
}
// WallpaperSearch.Recent
NSString * _Nonnull _LbiD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5904);
}
// Watch.AppName
NSString * _Nonnull _LbiE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5905);
}
// Watch.AuthRequired
NSString * _Nonnull _LbiF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5906);
}
// Watch.Bot.Restart
NSString * _Nonnull _LbiG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5907);
}
// Watch.ChannelInfo.Title
NSString * _Nonnull _LbiH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5908);
}
// Watch.ChatList.Compose
NSString * _Nonnull _LbiI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5909);
}
// Watch.ChatList.NoConversationsText
NSString * _Nonnull _LbiJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5910);
}
// Watch.ChatList.NoConversationsTitle
NSString * _Nonnull _LbiK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5911);
}
// Watch.Compose.AddContact
NSString * _Nonnull _LbiL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5912);
}
// Watch.Compose.CreateMessage
NSString * _Nonnull _LbiM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5913);
}
// Watch.Compose.CurrentLocation
NSString * _Nonnull _LbiN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5914);
}
// Watch.Compose.Send
NSString * _Nonnull _LbiO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5915);
}
// Watch.ConnectionDescription
NSString * _Nonnull _LbiP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5916);
}
// Watch.Contacts.NoResults
NSString * _Nonnull _LbiQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5917);
}
// Watch.Conversation.GroupInfo
NSString * _Nonnull _LbiR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5918);
}
// Watch.Conversation.Reply
NSString * _Nonnull _LbiS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5919);
}
// Watch.Conversation.Unblock
NSString * _Nonnull _LbiT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5920);
}
// Watch.Conversation.UserInfo
NSString * _Nonnull _LbiU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5921);
}
// Watch.GroupInfo.Title
NSString * _Nonnull _LbiV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5922);
}
// Watch.LastSeen.ALongTimeAgo
NSString * _Nonnull _LbiW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5923);
}
// Watch.LastSeen.AtDate
_FormattedString * _Nonnull _LbiX(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5924, _0);
}
// Watch.LastSeen.HoursAgo
NSString * _Nonnull _LbiY(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 5925, value);
}
// Watch.LastSeen.JustNow
NSString * _Nonnull _LbiZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5926);
}
// Watch.LastSeen.Lately
NSString * _Nonnull _Lbja(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5927);
}
// Watch.LastSeen.MinutesAgo
NSString * _Nonnull _Lbjb(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 5928, value);
}
// Watch.LastSeen.WithinAMonth
NSString * _Nonnull _Lbjc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5929);
}
// Watch.LastSeen.WithinAWeek
NSString * _Nonnull _Lbjd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5930);
}
// Watch.LastSeen.YesterdayAt
_FormattedString * _Nonnull _Lbje(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5931, _0);
}
// Watch.Location.Access
NSString * _Nonnull _Lbjf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5932);
}
// Watch.Location.Current
NSString * _Nonnull _Lbjg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5933);
}
// Watch.Message.Call
NSString * _Nonnull _Lbjh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5934);
}
// Watch.Message.ForwardedFrom
NSString * _Nonnull _Lbji(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5935);
}
// Watch.Message.Game
NSString * _Nonnull _Lbjj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5936);
}
// Watch.Message.Invoice
NSString * _Nonnull _Lbjk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5937);
}
// Watch.Message.Poll
NSString * _Nonnull _Lbjl(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5938);
}
// Watch.Message.Unsupported
NSString * _Nonnull _Lbjm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5939);
}
// Watch.MessageView.Forward
NSString * _Nonnull _Lbjn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5940);
}
// Watch.MessageView.Reply
NSString * _Nonnull _Lbjo(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5941);
}
// Watch.MessageView.Title
NSString * _Nonnull _Lbjp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5942);
}
// Watch.MessageView.ViewOnPhone
NSString * _Nonnull _Lbjq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5943);
}
// Watch.Microphone.Access
NSString * _Nonnull _Lbjr(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5944);
}
// Watch.NoConnection
NSString * _Nonnull _Lbjs(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5945);
}
// Watch.Notification.Joined
NSString * _Nonnull _Lbjt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5946);
}
// Watch.PhotoView.Title
NSString * _Nonnull _Lbju(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5947);
}
// Watch.Stickers.RecentPlaceholder
NSString * _Nonnull _Lbjv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5948);
}
// Watch.Stickers.Recents
NSString * _Nonnull _Lbjw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5949);
}
// Watch.Stickers.StickerPacks
NSString * _Nonnull _Lbjx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5950);
}
// Watch.Suggestion.BRB
NSString * _Nonnull _Lbjy(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5951);
}
// Watch.Suggestion.CantTalk
NSString * _Nonnull _Lbjz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5952);
}
// Watch.Suggestion.HoldOn
NSString * _Nonnull _LbjA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5953);
}
// Watch.Suggestion.OK
NSString * _Nonnull _LbjB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5954);
}
// Watch.Suggestion.OnMyWay
NSString * _Nonnull _LbjC(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5955);
}
// Watch.Suggestion.TalkLater
NSString * _Nonnull _LbjD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5956);
}
// Watch.Suggestion.Thanks
NSString * _Nonnull _LbjE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5957);
}
// Watch.Suggestion.WhatsUp
NSString * _Nonnull _LbjF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5958);
}
// Watch.Time.ShortFullAt
_FormattedString * _Nonnull _LbjG(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 5959, _0, _1);
}
// Watch.Time.ShortTodayAt
_FormattedString * _Nonnull _LbjH(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5960, _0);
}
// Watch.Time.ShortWeekdayAt
_FormattedString * _Nonnull _LbjI(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 5961, _0, _1);
}
// Watch.Time.ShortYesterdayAt
_FormattedString * _Nonnull _LbjJ(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5962, _0);
}
// Watch.UserInfo.Block
NSString * _Nonnull _LbjK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5963);
}
// Watch.UserInfo.Mute
NSString * _Nonnull _LbjL(_PresentationStrings * _Nonnull _self, int32_t value) {
    return getPluralizedIndirect(_self, 5964, value);
}
// Watch.UserInfo.MuteTitle
NSString * _Nonnull _LbjM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5965);
}
// Watch.UserInfo.Service
NSString * _Nonnull _LbjN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5966);
}
// Watch.UserInfo.Title
NSString * _Nonnull _LbjO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5967);
}
// Watch.UserInfo.Unblock
NSString * _Nonnull _LbjP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5968);
}
// Watch.UserInfo.Unmute
NSString * _Nonnull _LbjQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5969);
}
// WatchRemote.AlertOpen
NSString * _Nonnull _LbjR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5970);
}
// WatchRemote.AlertText
NSString * _Nonnull _LbjS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5971);
}
// WatchRemote.AlertTitle
NSString * _Nonnull _LbjT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5972);
}
// WatchRemote.NotificationText
NSString * _Nonnull _LbjU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5973);
}
// Web.Error
NSString * _Nonnull _LbjV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5974);
}
// Web.OpenExternal
NSString * _Nonnull _LbjW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5975);
}
// WebApp.AddToAttachmentAdd
NSString * _Nonnull _LbjX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5976);
}
// WebApp.AddToAttachmentAllowMessages
_FormattedString * _Nonnull _LbjY(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5977, _0);
}
// WebApp.AddToAttachmentAlreadyAddedError
NSString * _Nonnull _LbjZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5978);
}
// WebApp.AddToAttachmentSucceeded
_FormattedString * _Nonnull _Lbka(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5979, _0);
}
// WebApp.AddToAttachmentText
_FormattedString * _Nonnull _Lbkb(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5980, _0);
}
// WebApp.AddToAttachmentUnavailableError
NSString * _Nonnull _Lbkc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5981);
}
// WebApp.CloseAnyway
NSString * _Nonnull _Lbkd(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5982);
}
// WebApp.CloseConfirmation
NSString * _Nonnull _Lbke(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5983);
}
// WebApp.MessagePreview
NSString * _Nonnull _Lbkf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5984);
}
// WebApp.OpenBot
NSString * _Nonnull _Lbkg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5985);
}
// WebApp.OpenWebViewAlertText
_FormattedString * _Nonnull _Lbkh(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5986, _0);
}
// WebApp.OpenWebViewAlertTitle
NSString * _Nonnull _Lbki(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5987);
}
// WebApp.ReloadPage
NSString * _Nonnull _Lbkj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5988);
}
// WebApp.RemoveBot
NSString * _Nonnull _Lbkk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5989);
}
// WebApp.RemoveConfirmationText
_FormattedString * _Nonnull _Lbkl(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 5990, _0);
}
// WebApp.RemoveConfirmationTitle
NSString * _Nonnull _Lbkm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5991);
}
// WebApp.SelectChat
NSString * _Nonnull _Lbkn(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5992);
}
// WebApp.Send
NSString * _Nonnull _Lbko(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5993);
}
// WebApp.Settings
NSString * _Nonnull _Lbkp(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5994);
}
// WebApp.ShareMyPhoneNumber
NSString * _Nonnull _Lbkq(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5995);
}
// WebApp.ShareMyPhoneNumberConfirmation
_FormattedString * _Nonnull _Lbkr(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0, NSString * _Nonnull _1) {
    return getFormatted2(_self, 5996, _0, _1);
}
// WebBrowser.DefaultBrowser
NSString * _Nonnull _Lbks(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5997);
}
// WebBrowser.InAppSafari
NSString * _Nonnull _Lbkt(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5998);
}
// WebBrowser.Title
NSString * _Nonnull _Lbku(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 5999);
}
// WebPreview.GettingLinkInfo
NSString * _Nonnull _Lbkv(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 6000);
}
// WebSearch.GIFs
NSString * _Nonnull _Lbkw(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 6001);
}
// WebSearch.Images
NSString * _Nonnull _Lbkx(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 6002);
}
// WebSearch.RecentClearConfirmation
NSString * _Nonnull _Lbky(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 6003);
}
// WebSearch.RecentSectionClear
NSString * _Nonnull _Lbkz(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 6004);
}
// WebSearch.RecentSectionTitle
NSString * _Nonnull _LbkA(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 6005);
}
// WebSearch.SearchNoResults
NSString * _Nonnull _LbkB(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 6006);
}
// WebSearch.SearchNoResultsDescription
_FormattedString * _Nonnull _LbkC(_PresentationStrings * _Nonnull _self, NSString * _Nonnull _0) {
    return getFormatted1(_self, 6007, _0);
}
// Weekday.Friday
NSString * _Nonnull _LbkD(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 6008);
}
// Weekday.Monday
NSString * _Nonnull _LbkE(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 6009);
}
// Weekday.Saturday
NSString * _Nonnull _LbkF(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 6010);
}
// Weekday.ShortFriday
NSString * _Nonnull _LbkG(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 6011);
}
// Weekday.ShortMonday
NSString * _Nonnull _LbkH(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 6012);
}
// Weekday.ShortSaturday
NSString * _Nonnull _LbkI(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 6013);
}
// Weekday.ShortSunday
NSString * _Nonnull _LbkJ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 6014);
}
// Weekday.ShortThursday
NSString * _Nonnull _LbkK(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 6015);
}
// Weekday.ShortTuesday
NSString * _Nonnull _LbkL(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 6016);
}
// Weekday.ShortWednesday
NSString * _Nonnull _LbkM(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 6017);
}
// Weekday.Sunday
NSString * _Nonnull _LbkN(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 6018);
}
// Weekday.Thursday
NSString * _Nonnull _LbkO(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 6019);
}
// Weekday.Today
NSString * _Nonnull _LbkP(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 6020);
}
// Weekday.Tuesday
NSString * _Nonnull _LbkQ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 6021);
}
// Weekday.Wednesday
NSString * _Nonnull _LbkR(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 6022);
}
// Weekday.Yesterday
NSString * _Nonnull _LbkS(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 6023);
}
// Widget.ApplicationLocked
NSString * _Nonnull _LbkT(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 6024);
}
// Widget.ApplicationStartRequired
NSString * _Nonnull _LbkU(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 6025);
}
// Widget.AuthRequired
NSString * _Nonnull _LbkV(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 6026);
}
// Widget.ChatsGalleryDescription
NSString * _Nonnull _LbkW(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 6027);
}
// Widget.ChatsGalleryTitle
NSString * _Nonnull _LbkX(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 6028);
}
// Widget.GalleryDescription
NSString * _Nonnull _LbkY(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 6029);
}
// Widget.GalleryTitle
NSString * _Nonnull _LbkZ(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 6030);
}
// Widget.LongTapToEdit
NSString * _Nonnull _Lbla(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 6031);
}
// Widget.MessageAutoremoveTimerRemoved
NSString * _Nonnull _Lblb(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 6032);
}
// Widget.MessageAutoremoveTimerUpdated
NSString * _Nonnull _Lblc(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 6033);
}
// Widget.NoUsers
NSString * _Nonnull _Lbld(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 6034);
}
// Widget.ShortcutsGalleryDescription
NSString * _Nonnull _Lble(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 6035);
}
// Widget.ShortcutsGalleryTitle
NSString * _Nonnull _Lblf(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 6036);
}
// Widget.UpdatedAt
NSString * _Nonnull _Lblg(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 6037);
}
// Widget.UpdatedTodayAt
NSString * _Nonnull _Lblh(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 6038);
}
// Your_card_has_expired
NSString * _Nonnull _Lbli(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 6039);
}
// Your_card_was_declined
NSString * _Nonnull _Lblj(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 6040);
}
// Your_cards_expiration_month_is_invalid
NSString * _Nonnull _Lblk(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 6041);
}
// Your_cards_expiration_year_is_invalid
NSString * _Nonnull _Lbll(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 6042);
}
// Your_cards_number_is_invalid
NSString * _Nonnull _Lblm(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 6043);
}
// Your_cards_security_code_is_invalid
NSString * _Nonnull _Lbln(_PresentationStrings * _Nonnull _self) {
    return getSingleIndirect(_self, 6044);
}
