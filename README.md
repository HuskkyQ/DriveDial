# 行仪 / DriveDial

iPhone 横屏仪表原型。名称未定，屏幕上暂称「行仪」。原生 SwiftUI，不是网页套壳。读数、地图和音乐都是演示。

## 在 Mac 上打开

需要 Xcode 16 或更新，以及 iOS 17 SDK。当前环境没有 Xcode，下面的测试不能代替 iOS 编译。

1. 打开 `DriveDial.xcodeproj`。
2. 签名是关着的。模拟器不需要开发团队。不要注册 Bundle ID，不要 Archive，不要上架。
3. 选一台 iPhone 模拟器运行。应用只声明横屏左和横屏右，不改系统方向锁。
4. 逻辑测试：`swift test`

车模是 v6 HTML 里的两张原图：后上方 630×868，正俯视 626×1004。数字字体是同一份源稿里的 Outfit。

## 这次不推 GitHub

源码包由父级导入 Mac 上已经 clone 的 `/Users/sevan/ai-tasks/DriveDial`，保留那个目录里的 `.git`。推送由用户在自己的 Mac 上完成。本环境不再尝试 GitHub 认证或推送。
