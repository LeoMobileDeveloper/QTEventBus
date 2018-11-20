
## 背景

在一些复杂的场景下，如果选择delegate或者block来传递事件会十分“困难”。

一个极端的例子：假设View一共有10层，那么如何把第10层View的点击事件，传递给第一层呢？

传统选择：

- delegate 需要一层一层的把delegate传递出来
- block 需要一层一层的把block注入进去

这些胶水代码会让开发变得异常困难，维护起来也会变得很难（通过MVVM的binding仍然不能解决View层次的问题，因为你要访问到View才能binding）。

## EventBus

EventBus为UIResponser新增了一个属性：`eventDispatcher`作为消息通信的枢纽。默认这个属性是挂在View所属的ViewController上的。


```
@property (readonly, nullable, nonatomic) QTEventBus * eventDispatcher;
```

这样，第10层View点击传递到第1层的实现方式如下

在第10层View中发布事件：

```
[self.eventDispatcher dispatch:@"View10Clicked"];
```

第1层View订阅事件：

```
[[self subscribeName:@"View10Clicked" on:self.eventDispatcher] next:^(NSString * event){

}];
```

## 原理

Controller作为EventBus的提供者，View和Controller都可以通过属性`eventDispatcher`沿着响应链找到Controller提供的eventBus，这样就可以实现间接通信。


## FAQ

- TODO


