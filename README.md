# flutter_pan

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


一、添加启动页
1、添加依赖
```
dev_dependencies:
  flutter_native_splash: ^1.2.0
```
2、在根目录添加flutter_native_splash.yaml，配置按项目里面的写，并配置assets中的图片
3、执行命令
`flutter pub run flutter_native_splash:create --path=./flutter_native_splash.yaml`