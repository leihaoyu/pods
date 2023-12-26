#
#  Be sure to run `pod spec lint TelegramUI.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  spec.name         = "TelegramUI"
  spec.version      = "0.0.1"
  spec.summary      = "A short description of TelegramUI."

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  spec.description  = <<-DESC
Hello
                   DESC

  spec.homepage     = "/TelegramUI"
  # spec.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"


  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Licensing your code is important. See https://choosealicense.com for more info.
  #  CocoaPods will detect a license file if there is a named LICENSE*
  #  Popular ones are 'MIT', 'BSD' and 'Apache License, Version 2.0'.
  #

  spec.license      = "MIT"
  # spec.license      = { :type => "MIT", :file => "FILE_LICENSE" }


  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the authors of the library, with email addresses. Email addresses
  #  of the authors are extracted from the SCM log. E.g. $ git log. CocoaPods also
  #  accepts just a name if you'd rather not provide an email address.
  #
  #  Specify a social_media_url where others can refer to, for example a twitter
  #  profile URL.
  #

  spec.author             = { "thunder" => "" }
  # Or just: spec.author    = "thunder"
  # spec.authors            = { "thunder" => "" }
  # spec.social_media_url   = "https://twitter.com/thunder"

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If this Pod runs only on iOS or OS X, then specify the platform and
  #  the deployment target. You can optionally include the target after the platform.
  #

  # spec.platform     = :ios
   spec.platform     = :ios, "11.0"

  #  When using multiple platforms
  # spec.ios.deployment_target = "5.0"
  # spec.osx.deployment_target = "10.7"
  # spec.watchos.deployment_target = "2.0"
  # spec.tvos.deployment_target = "9.0"


  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the location from where the source should be retrieved.
  #  Supports git, hg, bzr, svn and HTTP.
  #

  spec.source       = { :git => "/TelegramUI.git", :tag => "#{spec.version}" }


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  CocoaPods is smart about how it includes source code. For source files
  #  giving a folder will include any swift, h, m, mm, c & cpp files.
  #  For header files it will include any header in the folder.
  #  Not including the public_header_files will make all headers public.
  #

  spec.source_files  = "Classes", "TelegramUI/**/*.{h,m,swift}"
  spec.exclude_files = "Classes/Exclude"

  # spec.public_header_files = "Classes/**/*.h"


  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  A list of resources included with the Pod. These are copied into the
  #  target bundle with a build phase script. Anything else will be cleaned.
  #  You can preserve files from being cleaned, please don't preserve
  #  non-essential files like tests, examples and documentation.
  #

  # spec.resource  = "icon.png"
  # spec.resources = "Resources/*.png"

  # spec.preserve_paths = "FilesToSave", "MoreFilesToSave"


  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Link your library with frameworks, or libraries. Libraries do not include
  #  the lib prefix of their name.
  #

  # spec.framework  = "SomeFramework"
  # spec.frameworks = "SomeFramework", "AnotherFramework"

  # spec.library   = "iconv"
  # spec.libraries = "iconv", "xml2"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.

  # spec.requires_arc = true

  # spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # spec.dependency "JSONKit", "~> 1.4"
  spec.dependency "SwiftSignalKit"
  spec.dependency "SSignalKit"
  spec.dependency "AsyncDisplayKit"
  spec.dependency "Display"
  spec.dependency "PostboxKit"
  spec.dependency "TelegramCore"
  spec.dependency "MtProtoKit"
  spec.dependency "TelegramPresentationData"
  spec.dependency "PresentationStringsKit"
  spec.dependency "AccountContextKit"
  spec.dependency "LegacyComponents"
  spec.dependency "Lottie"
  spec.dependency "FFMpegBinding"
  spec.dependency "WebPBinding"
  spec.dependency "RMIntro"
  spec.dependency "GZip"
#  spec.dependency "TelegramCallsUI"
  spec.dependency "TelegramUIPreferences"
  spec.dependency "UniversalMediaPlayer"
#  spec.dependency "TelegramVoip"
  spec.dependency "DeviceAccessKit"
#  spec.dependency "WatchCommon"
  spec.dependency "BuildConfig"
  spec.dependency "BuildConfigExtra"
  spec.dependency "RLottieBinding"
  spec.dependency "TelegramUpdateUI"
  spec.dependency "MergeLists"
  spec.dependency "ActivityIndicator"
  spec.dependency "ProgressNavigationButtonNodeKit"
  spec.dependency "ItemListUI"
  spec.dependency "TelegramBaseControllerKit"
  spec.dependency "DeviceLocationManagerKit"
  spec.dependency "AvatarNodeKit"
  spec.dependency "AvatarVideoNodeKit"
  spec.dependency "OverlayStatusController"
  spec.dependency "TelegramStringFormatting"
  spec.dependency "LiveLocationManagerKit"
  spec.dependency "LiveLocationTimerNode"
  spec.dependency "TemporaryCachedPeerDataManager"
  spec.dependency "ShareControllerKit"
  spec.dependency "RadialStatusNodeKit"
  spec.dependency "PeerOnlineMarkerNodeKit"
  spec.dependency "PeerPresenceStatusManagerKit"
  spec.dependency "ChatListSearchRecentPeersNodeKit"
  spec.dependency "ImageBlur"
  spec.dependency "ContextUI"
  spec.dependency "MediaResources"
  spec.dependency "TelegramAudio"
  spec.dependency "UrlEscaping"
  spec.dependency "Tuples"
  spec.dependency "TextFormat"
  spec.dependency "SwitchNode"
  spec.dependency "StickerResources"
  spec.dependency "SelectablePeerNodeKit"
  spec.dependency "SaveToCameraRoll"
  spec.dependency "LocalizedPeerData"
  spec.dependency "ListSectionHeaderNodeKit"
  spec.dependency "HorizontalPeerItemKit"
  spec.dependency "CheckNodeKit"
  spec.dependency "AnimationUI"
  spec.dependency "AnimatedStickerNodeKit"
  spec.dependency "TelegramAnimatedStickerNode"
  spec.dependency "ActionSheetPeerItemKit"
  spec.dependency "ComposePollUI"
  spec.dependency "AlertUI"
  spec.dependency "PresentationDataUtils"
  spec.dependency "TouchDownGesture"
  spec.dependency "SwipeToDismissGesture"
  spec.dependency "DirectionalPanGesture"
  spec.dependency "UndoUI"
  spec.dependency "PhotoResources"
  spec.dependency "TinyThumbnail"
  spec.dependency "ImageTransparency"
  spec.dependency "TelegramNotices"
  spec.dependency "TelegramPermissions"
  spec.dependency "GameUI"
  spec.dependency "WebUI"
  spec.dependency "PassportUI"
  spec.dependency "PhoneInputNodeKit"
  spec.dependency "CountrySelectionUI"
  spec.dependency "SearchBarNodeKit"
  spec.dependency "GalleryUI"
  spec.dependency "TelegramUniversalVideoContent"
  spec.dependency "WebsiteTypeKit"
  spec.dependency "ScreenCaptureDetection"
  spec.dependency "OpenInExternalAppUI"
  spec.dependency "LegacyUI"
  spec.dependency "ImageCompression"
  spec.dependency "DateSelectionUI"
  spec.dependency "PasswordSetupUI"
  spec.dependency "Pdf"
  spec.dependency "InstantPageUI"
  spec.dependency "MusicAlbumArtResources"
  spec.dependency "LiveLocationPositionNode"
  spec.dependency "MosaicLayout"
  spec.dependency "LocationUI"
  spec.dependency "Stripe"
  spec.dependency "BotPaymentsUI"
  spec.dependency "LocalAuth"
  spec.dependency "ContactListUI"
  spec.dependency "SearchUI"
  spec.dependency "ChatListSearchItemHeaderKit"
  spec.dependency "ItemListPeerItemKit"
  spec.dependency "ContactsPeerItemKit"
  spec.dependency "ChatListSearchItemNodeKit"
  spec.dependency "TelegramPermissionsUI"
  spec.dependency "PeersNearbyIconNode"
  spec.dependency "SolidRoundedButtonNodeKit"
  spec.dependency "PasscodeUI"
#  spec.dependency "CallListUI"
  spec.dependency "ChatListUI"
  spec.dependency "ChatTitleActivityNodeKit"
  spec.dependency "DeleteChatPeerActionSheetItemKit"
  spec.dependency "LanguageSuggestionUI"
  spec.dependency "TextSelectionNodeKit"
  spec.dependency "PlatformRestrictionMatching"
  spec.dependency "HashtagSearchUI"
  spec.dependency "ItemListAvatarAndNameInfoItemKit"
  spec.dependency "ItemListPeerActionItemKit"
  spec.dependency "StickerPackPreviewUI"
  spec.dependency "YuvConversion"
  spec.dependency "JoinLinkPreviewUI"
  spec.dependency "LanguageLinkPreviewUI"
  spec.dependency "WebSearchUI"
  spec.dependency "LegacyMediaPickerUI"
  spec.dependency "MimeTypes"
  spec.dependency "LocalMediaResources"
  spec.dependency "PeersNearbyUI"
  spec.dependency "Geocoding"
  spec.dependency "PeerInfoUI"
  spec.dependency "PeerAvatarGalleryUI"
  spec.dependency "Emoji"
  spec.dependency "ItemListStickerPackItemKit"
  spec.dependency "NotificationMuteSettingsUI"
  spec.dependency "SinglePhoneInputNodeKit"
  spec.dependency "MapResourceToAvatarSizes"
  spec.dependency "NotificationSoundSelectionUI"
  spec.dependency "EncryptionKeyVisualization"
  spec.dependency "ItemListAddressItemKit"
  spec.dependency "DeviceProximity"
  spec.dependency "RaiseToListen"
  spec.dependency "OpusBinding"
#  spec.dependency "opus"
  spec.dependency "WatchBridgeAudio"
  spec.dependency "WatchBridge"
  spec.dependency "ShareItems"
  spec.dependency "ShareItemsImpl"
  spec.dependency "SettingsUI"
  spec.dependency "UrlHandling"
  spec.dependency "HexColor"
  spec.dependency "QrCode"
  spec.dependency "WallpaperResources"
  spec.dependency "AuthorizationUI"
  spec.dependency "CounterContollerTitleViewKit"
  spec.dependency "GridMessageSelectionNodeKit"
  spec.dependency "InstantPageCache"
  spec.dependency "PersistentStringHash"
  spec.dependency "SegmentedControlNodeKit"
  spec.dependency "AppBundle"
  spec.dependency "Markdown"
  spec.dependency "SearchPeerMembers"
  spec.dependency "WidgetItems"
  spec.dependency "WidgetItemsUtils"
  spec.dependency "OpenSSLEncryptionProvider"
  spec.dependency "PhoneNumberFormat"
  spec.dependency "AppLock"
  spec.dependency "NotificationsPresentationDataKit"
  spec.dependency "UrlWhitelist"
  spec.dependency "TelegramIntents"
  spec.dependency "LocationResources"
  spec.dependency "ItemListVenueItemKit"
  spec.dependency "SemanticStatusNodeKit"
  spec.dependency "AccountUtils"
  spec.dependency "Svg"
  spec.dependency "ManagedAnimationNodeKit"
  spec.dependency "TooltipUI"
  spec.dependency "ListMessageItemKit"
  spec.dependency "FileMediaResourceStatusKit"
  spec.dependency "ChatMessageInteractiveMediaBadgeKit"
  spec.dependency "GalleryData"
  spec.dependency "ChatInterfaceStateKit"
  spec.dependency "AnimatedCountLabelNodeKit"
  spec.dependency "AnimatedAvatarSetNodeKit"
  spec.dependency "SlotMachineAnimationNodeKit"
  spec.dependency "AnimatedNavigationStripeNodeKit"
  spec.dependency "AudioBlob"
  spec.dependency "GeneratedSources"
  spec.dependency "ZipArchive"
  spec.dependency "ChatImportUI"
  spec.dependency "DatePickerNodeKit"
  spec.dependency "ConfettiEffect"
  spec.dependency "Speak"
  spec.dependency "PeerInfoAvatarListNodeKit"
  spec.dependency "DebugSettingsUI"
  spec.dependency "ImportStickerPackUI"
  spec.dependency "GradientBackground"
  spec.dependency "WallpaperBackgroundNodeKit"
  spec.dependency "ComponentFlow"
  spec.dependency "AdUI"
  spec.dependency "SparseItemGridKit"
  spec.dependency "CalendarMessageScreenKit"
  spec.dependency "LottieMeshSwift"
  spec.dependency "MeshAnimationCacheKit"
  spec.dependency "DirectMediaImageCacheKit"
  spec.dependency "CodeInputViewKit"
  spec.dependency "ReactionButtonListComponent"
  spec.dependency "InvisibleInkDustNodeKit"
  spec.dependency "QrCodeUI"
  spec.dependency "ReactionListContextMenuContentKit"
  spec.dependency "ReactionImageComponent"
  spec.dependency "TabBarUI"
  spec.dependency "SoftwareVideo"
  spec.dependency "ManagedFileKit"
  spec.dependency "FetchManagerImplKit"
  spec.dependency "AttachmentUI"
  spec.dependency "AttachmentTextInputPanelNodeKit"
  spec.dependency "ChatPresentationInterfaceStateKit"
  spec.dependency "Pasteboard"
  spec.dependency "ChatSendMessageActionUI"
  spec.dependency "ChatTextLinkEditUI"
  spec.dependency "MediaPickerUI"
  spec.dependency "ChatMessageBackgroundKit"
  spec.dependency "CreateExternalMediaStreamScreenKit"
  spec.dependency "TranslateUI"
  spec.dependency "BrowserUI"
  spec.dependency "PremiumUI"
  spec.dependency "HierarchyTrackingLayer"
  spec.dependency "RangeSetKit"
  spec.dependency "InAppPurchaseManagerKit"
  spec.dependency "AudioTranscriptionButtonComponentKit"
  spec.dependency "AudioTranscriptionPendingIndicatorComponentKit"
  spec.dependency "AudioWaveformComponentKit"
  spec.dependency "EditableChatTextNodeKit"
  spec.dependency "EmojiTextAttachmentViewKit"
  spec.dependency "EntityKeyboard"
  spec.dependency "AnimationCacheKit"
  spec.dependency "LottieAnimationCache"
  spec.dependency "VideoAnimationCache"
  spec.dependency "MultiAnimationRendererKit"
  spec.dependency "ChatInputPanelContainerKit"
  spec.dependency "TextNodeWithEntitiesKit"
  spec.dependency "EmojiSuggestionsComponentKit"
  spec.dependency "EmojiStatusSelectionComponentKit"
  spec.dependency "EmojiStatusComponentKit"
  spec.dependency "ChatControllerInteractionKit"
  spec.dependency "ComponentDisplayAdapters"
  spec.dependency "ConvertOpusToAAC"
  spec.dependency "LocalAudioTranscription"
  spec.dependency "PagerComponentKit"
  spec.dependency "LottieAnimationCompont"
  spec.dependency "NotificationExceptionsScreenKit"
  spec.dependency "ForumCreateTopicScreenKit"
  spec.dependency "ChatTitleViewKit"
  spec.dependency "InviteLinksUI"
  spec.dependency "NotificationPeerExceptionControllerKit"
  spec.dependency "ChatListHeaderComponentKit"
  spec.dependency "ChatInputNodeKit"
  spec.dependency "ChatEntityKeyboardInputNodeKit"
  spec.dependency "StorageUsageScreenKit"
  spec.dependency "AvatarEditorScreenKit"
  spec.dependency "MediaPasteboardUI"
  spec.dependency "DrawingUI"
  spec.dependency "FeaturedStickersScreenKit"
  
end
