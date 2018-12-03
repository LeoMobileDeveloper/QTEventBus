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
- 支持AppDelegate解耦
- 支持基于响应链的局部总线

文章：

- [实现一个优雅的iOS消息总线](https://github.com/LeoMobileDeveloper/Blogs/blob/master/iOS/%E5%AE%9E%E7%8E%B0%E4%B8%80%E4%B8%AA%E4%BC%98%E9%9B%85%E7%9A%84iOS%E6%B6%88%E6%81%AF%E6%80%BB%E7%BA%BF.md)
- [聊聊AppDelegate解耦](https://github.com/LeoMobileDeveloper/Blogs/blob/master/iOS/AppDelegate%E8%A7%A3%E8%80%A6.md)

## 安装

消息总线：

```
pod QTEventBus
```

AppDelegate解耦：

```
pod QTEventBus/AppModule
```

基于响应链的事件传递：

```
pod QTEventBus/UIKit
```

## 系统要求

- XCode 9 +
- iOS 8+


## 使用

### 新建一个类作为事件，实现协议`QTEvent`

```
@interface QTLoginEvent : NSObject<QTEvent>
@property (copy, nonatomic) NSString * userId; //可以携带任意数据
@property (copy, nonatomic) NSString * userName; //可以携带任意数据
@end
```

### 订阅这个事件

> QTSub(object,className)宏的作用是在object的生命周期内，订阅className事件，当object释放的时候自动取消订阅。

```
//注意eventBus会持有这个block，需要弱引用object
[QTSub(self,QTLoginEvent) next:^(QTLoginEvent * event) {
    NSLog(@"%ld",event.userId);
}];
```

如果需要在主线程订阅，使用宏`QTSubMain`

### 发布事件

```
QTLoginEvent * event;
[QTEventBus.shared dispatch:event];
```

## 详细文档

- [核心功能](./Doc/Basic.md)
- [扩展：AppDelegate解耦](./Doc/Module.md)
- [扩展：基于响应链的事件传递](./Doc/UIKitSupport.md)


## 许可证

QTEventBus使用 MIT 许可证，详情见 LICENSE 文件。
