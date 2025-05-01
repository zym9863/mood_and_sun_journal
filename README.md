[English Version](README_EN.md) | [中文版](README.md)

# mood_and_sun_journal

一个结合心情记录与天气、活动建议的 Flutter 应用。

## 项目简介
本项目旨在帮助用户记录每日心情、获取天气信息，并根据心情和天气智能推荐活动建议。支持本地数据存储、地理定位、天气查询、个性化设置等功能。

## 主要功能
- 心情记录与管理
- 天气信息获取与展示
- 智能活动推荐
- 历史心情与活动浏览
- 个性化设置

## 目录结构
```
lib/
  main.dart                  // 应用入口
  models/                    // 数据模型（如 mood_entry, weather, activity_suggestion）
  providers/                 // 状态管理（如 mood_provider, weather_provider, activity_recommendation_provider）
  screens/                   // 各功能页面（如 home_screen, mood_entry_screen, settings_screen 等）
  services/                  // 业务服务（如 database_helper, weather_service, location_service, settings_service）
```

## 依赖环境
- Flutter 3.x 及以上
- 主要依赖包：
  - provider
  - sqflite_common_ffi
  - path_provider
  - geolocator
  - 其他详见 pubspec.yaml

## 运行方式
1. 安装依赖：
   ```
   flutter pub get
   ```
2. 运行项目：
   ```
   flutter run
   ```

## 代码结构说明
- **models/**：定义心情、天气、活动建议等核心数据结构。
- **providers/**：负责应用状态管理，封装业务逻辑与数据流转。
- **screens/**：各功能页面的 UI 及交互逻辑。
- **services/**：如数据库操作、定位、天气接口、设置管理等服务类。

## 贡献与反馈
欢迎提出建议或提交 PR 改进本项目。

---

如需 Flutter 开发入门，可参考：
- [Flutter 官方文档](https://docs.flutter.dev/)
- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)
