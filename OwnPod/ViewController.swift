//
//  ViewController.swift
//  OwnPod
//
//  Created by thunder on 12/14/23.
//

import UIKit
import AsyncDisplayKit
import Markdown
import SwiftSignalKit
import AppBundle
import UIKitRuntimeUtils
import ObjCRuntimeUtils
import SSignalKit
import ManagedFileKit
import TelegramAudio
import Crc32
import sqlcipher
import MurMurHash32
import StringTransliteration
import RangeSetKit
import CryptoUtils
import DarwinDirStat
import PostboxKit
import EncryptionProviderKit
import TelegramApi
import CloudDataKit
import CryptoUtils
import NetworkLogging
import TelegramCore
import DeviceLocationManagerKit
import FFMpegBinding
import RingBuffer
import YuvConversion
import Display
import MediaResources
import TextFormat
import TelegramPresentationData
import UniversalMediaPlayer
import MusicAlbumArtResources
import MeshAnimationCacheKit
import AccountContextKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let view = ASDisplayNode()
        self.view.addSubnode(view)
        view.backgroundColor = .lightGray
        view.frame = self.view.bounds
        let text = UILabel()
        text.numberOfLines = 0
//        text.text = "武\n运\n昌\n隆"
        text.textColor = .red
        text.font = .boldSystemFont(ofSize: 128)
        self.view.addSubview(text)
        text.sizeToFit()
        text.center = self.view.center
        // Do any additional setup after loading the view.
    }


}

