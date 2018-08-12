## QTEventBus

[![Build Status](https://travis-ci.org/LeoMobileDeveloper/QTEventBus.svg)](https://travis-ci.org/LeoMobileDeveloper/QTEventBus)
 [![Version](https://img.shields.io/cocoapods/v/QTEventBus.svg?style=flat)](http://cocoapods.org/pods/QTEventBus)  [![Platform](http://img.shields.io/badge/platform-ios-blue.svg?style=flat
)](https://developer.apple.com/iphone/index.action)
 [![License](http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat
)](http://mit-license.org)

QTEventBus是一个优雅的iOS事件总线，用来实现“发布-订阅”的消息通信模式。

<img src="./images/event_bus_1.png">

- 支持强类型/弱类型
- 自动取消订阅
- 快速
- 兼容`NSNotification`
- 单元测试覆盖

## 安装

```
pod QTEventBus
```

AppDelegate解耦：

```
pod QTEventBus/AppModule
```

## 文档

- [核心功能](./Doc/Basic.md)
- [扩展：AppDelegate解耦](./Doc/Module.md)


## 系统要求

- XCode 9 +
- iOS 8+

## 许可证

QTEventBus使用 MIT 许可证，详情见 LICENSE 文件。


## 文章

- [实现一个优雅的iOS消息总线](https://github.com/LeoMobileDeveloper/Blogs/blob/master/iOS/%E5%AE%9E%E7%8E%B0%E4%B8%80%E4%B8%AA%E4%BC%98%E9%9B%85%E7%9A%84iOS%E6%B6%88%E6%81%AF%E6%80%BB%E7%BA%BF.md)
- [聊聊AppDelegate解耦](https://github.com/LeoMobileDeveloper/Blogs/blob/master/iOS/AppDelegate%E8%A7%A3%E8%80%A6.md)
