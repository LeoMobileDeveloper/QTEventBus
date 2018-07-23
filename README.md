## QTEventBus

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

文章：[实现一个优雅的iOS消息总线](https://github.com/LeoMobileDeveloper/Blogs/blob/master/iOS/%E5%AE%9E%E7%8E%B0%E4%B8%80%E4%B8%AA%E4%BC%98%E9%9B%85%E7%9A%84iOS%E6%B6%88%E6%81%AF%E6%80%BB%E7%BA%BF.md)

## 安装

最新版本为0.1.2

CocoaPods

```
pod QTEventBus
```

## 三步

### 新建一个类作Event类，实现协议`QTEvent`

```
@interface QTLoginEvent : NSObject<QTEvent>
@property (copy, nonatomic) NSString * userId;
@end
```

### 订阅这个事件

> QTSub(object,className)宏的作用是在object的生命周期内，订阅className事件，当object释放的时候自动取消订阅。

```
//注意eventBus会持有这个block，需要弱引用self
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

### 二级事件

二级事件是对一级事件的进一步细分。比如下载完成是一个一级事件，特定id的音乐下载完成就是一个二级事件。

实现`QTEvent`协议，并且提供eventSubType

```
@interface DownloadedEvent: NSObject<QTEvent>
+ (instancetype)eventWithUid:(NSString *)uid;
@end

@implementation DownloadedEvent
- (NSString *)eventSubType{
    return self.uid;
}
@end
```

#### 订阅这个特定的id

```
[QTSub(self,DownloadedEvent).ofSubType("123") next:^(DownloadedEvent * event) {
    NSLog(@"%ld",event.uid);
}];
```

#### 发布这个事件

```
DownloadedEvent * event;
[QTEventBus.shared dispatch:event];
```

#### 通知

QTEventBus把通知当成一个类名称为`NSNotification`,eventSubType为通知name的事件。所以，你可以这样订阅通知：

> 会随着self dealloc自动取消订阅，不需要手动remove

```
[QTSubNoti(self,"name") next:^(NSNotification *noti){

}];
```

这段代码等价于

```
[QTEventBus.shared.on(NSNotification.class).freeWith(self).ofSubType("name") next:^(NSNotification *noti){

}];
```

除此之外，EventBus还提供了一些系统的通知订阅：

```
[[self subscribeAppDidBecomeActive] next:^(NSNotification *noti){ }];
[[self subscribeAppDidFinishLaunching] next:^(NSNotification *noti){}];
```

## 手动取消订阅

```
id<QTEventToken> token = [QTSubNoti(self,"name") next:^(NSNotification *noti){

}];
//取消订阅
[token dispose];
```

如果你只需要监听一次事件：

```
__block id<QTEventToken> token;
token = [QTSubNoti(self,"name") next:^(NSNotification *noti){
    //处理事件
    [token dispose];
}]

```
## 弱类型事件

有些场景下的事件传递是需要弱类型的，比如两个完全没关系的ViewController通信。

EventBus提供了QTJsonEvent来处理这类事件，这就是一个普通的事件，使用方式类似NSNotification，你需要为这个事件提供一个唯一的name:

```
[QTSubJSON(self,"unqiueName") next:^(QTJsonEvent * event){

}];
```

## 子类

由于QTEventBus采用类名作为标识符来唯一事件，所以如果运行时的类是子类，那么需要在父类中实现eventClass方法：

举例：`NSNotification`在运行时是`NSConcreteNotification`，通过提供`eventClass`方法来强制让EventBus识别为父类

```
@interface NSNotification (QTEvent)<QTEvent>

@end

@implementation NSNotification (QTEvent)

+ (Class)eventClass{
    return [NSNotification class];
}

- (NSString *)eventSubType{
    return self.name;
}

@end
```

## 线程模型

> 注意：默认回调是同步的，并且在dispatch event的线程上。

事件的产生包括两个步骤

1. 发布者publish
2. 接收者回调block

发布者可以选择同步或者异步publish

- 同步publish会在当前线程分发事件
- 异步publish则会在eventbus内部的gcd队列上分发

所以：

1. 如果发布者选择同步publish，那么接收者回调的block在发布的线程上
2. 如果发布者选择异步publish，那么接收者回调的block在eventbus的gcd队列上

当然，接收者可以用操作符`atQueue`来指明接收事件的队列

> 注意：使用atQueue后，线程模型一定会变成异步的。
