# YFMessageCenter

基于 Protocol 实现通知机制，去掉硬编码，相比传统 NSNotificationCenter 更加的安全、优雅。

## 使用说明

**old**

```objc
// 1. 注册
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeText:) name:kChangTextNotification object:nil];

// 2. 实现
- (void)changeText:(NSNotification *)noti {
    self.titleLabel.text = noti.object;
}

// 3. 发送
[[NSNotificationCenter defaultCenter] postNotificationName:kChangTextNotification object:@"hello"];

// 4. 移除
[[NSNotificationCenter defaultCenter] removeObserver:self name:kChangTextNotification object:nil];
```

**new**

```objc
// 1. 定义
@protocol ChangeTextProtocol <NSObject>
- (void)changeText:(NSString *)text;
@end

// 2. 监听
OBSERVE_MESSAGE(self, ChangeTextProtocol);

// 3. 实现协议
- (void)changeText:(NSString *)text {
    self.titleLabel.text = text;
}

// 4. 分发消息
[DISPATCH_MESSAGE(ChangeTextProtocol) changeText:self.textField.text];

// 5. 移除
UN_OBSERVE_MESSAGE(self, ChangeTextProtocol);
```

### 协议继承

```objc
@protocol ChangeTextProtocol2 <ChangeTextProtocol>
- (void)changeText2:(NSString *)text;
@end

// 使用当前协议定义的方法 ✅
[DISPATCH_MESSAGE(ChangeTextProtocol2) changeText2:self.textField.text];

// 使用继承协议中的方法 ✅
[DISPATCH_MESSAGE(ChangeTextProtocol2) changeText:self.textField.text];
```
