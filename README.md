# Dynamic Wallpaper Studio (macOS 动态壁纸大师)

一个专为 macOS 设计的**极致高性能、低功耗原生动态壁纸应用**。基于 **Swift 6 + SwiftUI + AppKit + Metal + AVFoundation** 开发。

在确保绚丽视觉效果的同时，内置全自动低功耗策略引擎，实现**全屏应用 0% CPU/GPU 占用**、屏幕休眠自动挂起与电池保护机制，保障 Mac 最佳电池续航与极温表现。

---

## ⚡️ 核心亮点 (Key Features)

### 1. 0% 功耗智能策略引擎 (`EnergySaverManager`)
- **🎮 全屏应用/游戏自动休眠 (0% CPU/GPU)**：监听系统前台窗口。检测到全屏视频、游戏或 IDE 全屏时，动态壁纸自动挂起渲染，释放 100% 显卡与 CPU 算力。
- **💤 屏幕休眠与锁屏保护**：锁屏或显示器休眠时，自动停止解码与绘制，避免无谓发热。
- **🔋 电池供电自动降帧**：拔掉电源或开启低电量模式时，帧率自动从 60 FPS 调整至 30 FPS，兼顾流畅度与续航。
- **🚀 AVFoundation 硬件加速**：视频播放采用 GPU 硬解码；静音模式下完全切断音频采样解码器。

---

### 2. 🎬 三大动态壁纸播放引擎
- **高清视频壁纸 (`VideoWallpaperView`)**：支持 `.mp4`, `.mov` 视频无缝循环播放。
- **Web 动态网页壁纸 (`WebWallpaperView`)**：基于 `WKWebView` 硬件加速 Canvas / WebGL 动画。
- **原生生成式视觉特效 (`NativeProceduralViews`)**：
  - 🌌 **浩瀚星云 (Cosmic Nebula)**：GPU 极简高帧率星云粒子。
  - 🟢 **黑客帝国 (Matrix Rain)**：经典代码流落特效。
  - 🌆 **赛博网格 (Cyber Grid)**：80s 霓虹透视网格与极光。
  - 🕒 **极简数字时钟 (Minimal Clock)**：4K 时间与渐变光束背景。

---

### 3. 🖥️ macOS 原生极简交互
- **底层桌面挂载 (`WallpaperWindow`)**：挂载于桌面图标下方 (`.desktopWindow` 层级)，完全透传鼠标操作，桌面图标框选与右键菜单不受任何影响。
- **顶部状态栏常驻 (`MenuBarController`)**：状态栏一键暂停/恢复、切换音量、随机下一张与实时查看渲染 FPS/功耗状态。
- **玻璃拟态控制面板 (`DashboardView`)**：现代 Glassmorphism UI 面板，支持自定义导入本地 MP4 视频与 HTML5 动态网页壁纸。

---

## 🛠️ 构建与运行 (Build & Run)

### 系统要求
- macOS 14.0 (Sonoma) 或更高版本
- Xcode 15+ / Swift 5.9+

### 命令行编译与构建
```bash
# 编译 Release 版本
swift build -c release

# 打包为 macOS 应用程序包
mkdir -p DynamicWallpaperStudio.app/Contents/MacOS DynamicWallpaperStudio.app/Contents/Resources
cp .build/release/DynamicWallpaperStudio DynamicWallpaperStudio.app/Contents/MacOS/

# 打开运行
open DynamicWallpaperStudio.app
```

---

## 📄 开源协议 (License)

MIT License
