<p align="center">
  <a href="https://github.com/baogutang/N1KO-STATE">
    <img src="docs/assets/readme-banner.jpg" alt="N1KO-STATE — Native macOS System Monitor" width="100%" />
  </a>
</p>

<p align="center">
  <strong>A lightweight, native macOS menu bar system monitor.</strong><br/>
  <strong>轻量原生 macOS 菜单栏系统监控工具。</strong>
</p>

<p align="center">
  <a href="#english">English</a> · <a href="#中文">中文</a> ·
  <a href="https://github.com/baogutang/N1KO-STATE/releases">Releases</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/macOS-12%2B-000000?style=flat-square&logo=apple&logoColor=white" alt="macOS 12+" />
  <img src="https://img.shields.io/badge/Swift-5.9-F05138?style=flat-square&logo=swift&logoColor=white" alt="Swift 5.9" />
  <img src="https://img.shields.io/badge/version-1.0.1-blue?style=flat-square" alt="1.0.1" />
  <img src="https://img.shields.io/badge/license-MIT-green?style=flat-square" alt="MIT" />
</p>

<p align="center">
  <a href="https://github.com/baogutang/N1KO-STATE/stargazers">
    <img src="https://img.shields.io/github/stars/baogutang/N1KO-STATE?style=social" alt="GitHub stars" />
  </a>
  <a href="https://github.com/baogutang/N1KO-STATE/releases">
    <img src="https://img.shields.io/github/v/release/baogutang/N1KO-STATE?style=social&label=Release" alt="Latest release" />
  </a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Built%20with-AI%20Vibecoding-8B5CF6?style=for-the-badge&logo=dependabot&logoColor=white" alt="Built with AI Vibecoding" />
</p>

<p align="center">
  <sub>
    An <strong>AI vibecoding</strong> project by <a href="https://github.com/baogutang">baogutang</a> — product intent meets AI-assisted Swift/macOS development.<br/>
    作者 <strong>AI vibecoding</strong> 作品：从架构设计到原生界面，人机协作快速迭代。
  </sub>
</p>

---

## English

**N1KO-STATE** lives quietly in your menu bar and surfaces the metrics that matter — CPU, memory, GPU, network, disk, battery, temperatures, and fans — without turning your Mac into a second monitoring workload.

Left-click the menu bar icon for the live dashboard. Right-click for settings, about, and quit.

### Highlights

| | Feature | Description |
|---|---------|-------------|
| 📊 | **Live metrics** | CPU cores, memory pressure, GPU utilization, disk I/O, network rates, battery health |
| 🌡️ | **Sensors** | Apple Silicon HID temperatures + Intel SMC fallback; peak temperature tracking |
| 🌀 | **Fan control** | Manual RPM with one-time admin authorization; temperature-based fan curve |
| 📈 | **History** | 24-hour trend charts (CPU / memory / network) at 30 s granularity |
| 🔔 | **Alerts** | Configurable thresholds for CPU, memory, temperature, disk space, battery |
| 🌍 | **Localization** | English, 简体中文, 繁體中文 |
| ⚡ | **Low overhead** | Visibility-driven sampling — idle ~0.3–0.5% CPU, ~20 MB footprint |

### Requirements

- macOS **12.0** (Monterey) or later
- Apple Silicon or Intel Mac

### Install

1. Download **`N1KO-STATE.dmg`** from [Releases](https://github.com/baogutang/N1KO-STATE/releases).
2. Open the DMG and drag **N1KO-STATE** to **Applications**.
3. First launch (ad-hoc build): **right-click → Open**, or run the included `修复打不开.command`.

> Fan control installs a small privileged helper (one administrator password, once). Without it, fan speeds are read-only.

### Build from source

```bash
git clone git@github.com:baogutang/N1KO-STATE.git
cd N1KO-STATE

# Universal release + DMG (for distribution)
./build_app.sh --dmg

# Fast local build (host arch only)
./build_app.sh --native

# Smoke test after build
./build_app.sh --native --smoke
```

Output: `build/N1KO-STATE.app` · DMG: `build/N1KO-STATE.dmg`

Optional Developer ID signing:

```bash
export SIGN_IDENTITY="Developer ID Application: Your Name (TEAMID)"
export NOTARY_PROFILE="your-notarytool-profile"
./build_app.sh --dmg
```

### Project layout

```
Sources/N1KOState/     App UI, monitors, settings
Sources/FanHelper/     Privileged fan-control daemon
Sources/SMCKit/        Vendored SMC client (MIT, beltex)
Localization/          en · zh-Hans · zh-Hant
Resources/             Info.plist, app icon
build_app.sh           Build, sign, DMG, smoke test
```

### Credits

- [SMCKit](https://github.com/beltex/SMCKit) — MIT © 2014–2017 beltex (vendored locally)

---

## 中文

**N1KO-STATE** 是一款原生 macOS **菜单栏系统监控**应用。它把 CPU、内存、GPU、网络、磁盘、电池、温度与风扇等关键指标收进菜单栏，自身占用极低，不会「监控你的 Mac 的同时再拖慢 Mac」。

左键点击菜单栏图标打开监控面板；右键打开设置、关于与退出。

### 功能亮点

| | 功能 | 说明 |
|---|------|------|
| 📊 | **实时监控** | CPU 核心、内存压力、GPU 利用率、磁盘 I/O、网速、电池健康 |
| 🌡️ | **传感器** | Apple Silicon HID 温度 + Intel SMC 回退；峰值温度追踪 |
| 🌀 | **风扇控制** | 手动 RPM（一次性管理员授权）；温度曲线自动调速 |
| 📈 | **历史趋势** | 24 小时图表（CPU / 内存 / 网络），30 秒粒度 |
| 🔔 | **告警通知** | CPU、内存、温度、磁盘空间、电量阈值可配置 |
| 🌍 | **多语言** | English · 简体中文 · 繁體中文 |
| ⚡ | **低占用** | 可见性驱动采样 — 空闲约 0.3–0.5% CPU、~20 MB 内存 |

### 系统要求

- macOS **12.0**（Monterey）或更高
- Apple Silicon 或 Intel Mac

### 安装

1. 从 [Releases](https://github.com/baogutang/N1KO-STATE/releases) 下载 **`N1KO-STATE.dmg`**。
2. 打开 DMG，将 **N1KO-STATE** 拖入「应用程序」。
3. 首次启动（ad-hoc 签名）：**右键 → 打开**，或运行 DMG 内的 `修复打不开.command`。

> 风扇控制需安装小型特权 Helper（仅需输入一次管理员密码）。未授权时风扇转速为只读。

### 从源码构建

```bash
git clone git@github.com:baogutang/N1KO-STATE.git
cd N1KO-STATE

# Universal 发布包 + DMG
./build_app.sh --dmg

# 本机架构快速构建
./build_app.sh --native

# 构建后冒烟测试
./build_app.sh --native --smoke
```

产物：`build/N1KO-STATE.app` · DMG：`build/N1KO-STATE.dmg`

### 致谢

- [SMCKit](https://github.com/beltex/SMCKit) — MIT © 2014–2017 beltex（本地 vendored）

---

## Star History / Star 趋势

<p align="center">
  <a href="https://github.com/baogutang/N1KO-STATE/stargazers">
    <img src="https://img.shields.io/github/stars/baogutang/N1KO-STATE?style=for-the-badge&logo=github&label=Stars" alt="GitHub Stars" />
  </a>
</p>

<p align="center">
  <a href="https://star-history.com/#baogutang/N1KO-STATE&Date">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/chart?repos=baogutang/N1KO-STATE&type=date&theme=dark&legend=top-left&v=2" />
      <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/chart?repos=baogutang/N1KO-STATE&type=date&legend=top-left&v=2" />
      <img alt="Star History Chart" src="https://api.star-history.com/chart?repos=baogutang/N1KO-STATE&type=date&legend=top-left&v=2" width="600" />
    </picture>
  </a>
</p>

<p align="center">
  <sub>
    Live star count above · chart may lag a few hours (GitHub image cache) · click chart for interactive view<br/>
    上方徽章为实时 Star 数 · 趋势图因 GitHub 缓存可能延迟更新 · 点击图表可查看交互版<br/>
    Title avatar may not render in README (GitHub blocks external images inside proxied SVG) · 标题处头像在 README 中可能无法显示
  </sub>
</p>

<p align="center">
  <sub>If this project helps you, a ⭐ on GitHub is appreciated · 若对你有帮助，欢迎点个 Star ⭐</sub>
</p>

---

## ⚡ N1KO API · From the Author / 作者的其他作品

<p align="center">
  <a href="https://token.baogutang.top">
    <img src="https://img.shields.io/badge/N1KO%20API-一个密钥%20·%20无限模型-0D9488?style=for-the-badge&logo=serverless&logoColor=white" alt="N1KO API" />
  </a>
</p>

<p align="center">
  <strong>One key · Claude · GPT · Gemini · 16+ models</strong><br/>
  <strong>OpenAI-compatible endpoint · pay-as-you-go · low latency</strong>
</p>

<p align="center">
  <a href="https://token.baogutang.top"><img src="https://img.shields.io/badge/Claude-3.5%20Sonnet-7C3AED?style=flat-square" alt="Claude" /></a>
  <a href="https://token.baogutang.top"><img src="https://img.shields.io/badge/GPT--4o-✓-10A981?style=flat-square" alt="GPT-4o" /></a>
  <a href="https://token.baogutang.top"><img src="https://img.shields.io/badge/Gemini-1.5%20Pro-3B82F6?style=flat-square" alt="Gemini" /></a>
  <a href="https://token.baogutang.top"><img src="https://img.shields.io/badge/OpenAI-Compatible-06B6D4?style=flat-square" alt="OpenAI Compatible" /></a>
  <a href="https://token.baogutang.top"><img src="https://img.shields.io/badge/Uptime-99.9%25-22C55E?style=flat-square" alt="99.9% uptime" /></a>
</p>

<table align="center">
  <tr>
    <td align="center" width="420">
      <br/>
      <strong>🚀 Unified LLM gateway for builders</strong><br/>
      <sub>Drop-in <code>base_url</code> swap — same SDK, every frontier model.<br/>
      统一中转 · OpenAI 格式 · 按量计费 · 稳定低延迟</sub>
      <br/><br/>
      <a href="https://token.baogutang.top"><strong>token.baogutang.top → Get Started</strong></a>
      <br/><br/>
    </td>
  </tr>
</table>

<p align="center">
  <sub>Also built with AI vibecoding · 同样是 AI vibecoding 驱动的产品</sub>
</p>

---

## ☕ Buy me a coffee / 请作者喝杯咖啡

<p align="center">
  <strong>N1KO-STATE</strong> is free and open source. If it saves you time or keeps your Mac running smoothly,<br/>
  consider buying the author a coffee — every bit of support helps keep the project alive.<br/>
  <br/>
  <strong>N1KO-STATE</strong> 免费开源。若它帮你省下了时间、或让你更安心地掌握 Mac 状态，<br/>
  欢迎请作者喝杯咖啡，你的支持是我持续维护的动力 ☕
</p>

<p align="center">
  <img src="docs/assets/alipay-donate.png" alt="Alipay donation QR code for Nikooh" width="240" />
</p>

<p align="center">
  <sub>Scan with Alipay · 支付宝扫一扫 · Account: Nikooh</sub>
</p>

---

<p align="center">
  <sub>N1KO-STATE · v1.0.1 · Made for macOS power users who want clarity without clutter.</sub>
</p>
