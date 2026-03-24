# SystemTools

[English Version / 英文文档](./README.md)

### 项目说明

这是一个用于整理系统工具与脚本的仓库，计划面向 Windows 和 Ubuntu 使用场景。

### 当前状态

- 当前已经提供 Windows 和 Ubuntu 两侧的基础哈希脚本。
- `Windows/` 目录下的 PowerShell 脚本现已按哈希、网络测试、系统信息三个分类整理。
- `Ubuntu/` 目录中包含对应的 shell 版文件哈希与文本哈希脚本。
- `Assets/` 目录预留给后续辅助文件使用。

### 当前目录

```text
SystemTools/
├─ Assets/
├─ Ubuntu/
│  ├─ file_md5.sh
│  ├─ file_sha256.sh
│  ├─ text_md5.sh
│  └─ text_sha256.sh
├─ Windows/
│  ├─ Hash/
│  │  ├─ file_md5.ps1
│  │  ├─ file_sha256.ps1
│  │  ├─ text_md5.ps1
│  │  └─ text_sha256.ps1
│  ├─ Network/
│  │  └─ minio_connect_test.ps1
│  └─ SystemInfo/
│     ├─ common.ps1
│     ├─ get_common_port_status.ps1
│     ├─ get_cpu_info.ps1
│     ├─ get_disk_info.ps1
│     ├─ get_gpu_info.ps1
│     ├─ get_memory_info.ps1
│     ├─ get_motherboard_info.ps1
│     ├─ get_network_info.ps1
│     ├─ get_resource_usage.ps1
│     ├─ get_system_overview.ps1
│     └─ system_info.ps1
├─ README.md
└─ README.zh-CN.md
```

### 当前脚本

Windows：

- `Hash/`：文件哈希与文本哈希脚本。
- `Network/minio_connect_test.ps1`：通过 `IP:Port` 检测 MinIO 服务是否可连接。
- `SystemInfo/system_info.ps1`：统一调度系统信息各子脚本并输出完整报告。
- `SystemInfo/get_*.ps1`：按系统概览、主板、网络、CPU、显卡、硬盘、内存、资源占用、常用端口拆分的独立脚本。

Ubuntu：

- `file_md5.sh`：计算单个文件的 MD5。
- `file_sha256.sh`：计算单个文件的 SHA256。
- `text_md5.sh`：计算文本的 MD5，可选盐值。
- `text_sha256.sh`：计算文本的 SHA256，可选盐值。

### 使用示例

Windows：

```powershell
powershell -ExecutionPolicy Bypass -File .\Windows\Hash\file_md5.ps1 .\README.md
powershell -ExecutionPolicy Bypass -File .\Windows\Hash\file_sha256.ps1 .\README.md
powershell -ExecutionPolicy Bypass -File .\Windows\Hash\text_md5.ps1 "abc"
powershell -ExecutionPolicy Bypass -File .\Windows\Hash\text_md5.ps1 "abc" "salt"
powershell -ExecutionPolicy Bypass -File .\Windows\Hash\text_sha256.ps1 "abc"
powershell -ExecutionPolicy Bypass -File .\Windows\Hash\text_sha256.ps1 "abc" "salt"
powershell -ExecutionPolicy Bypass -File .\Windows\Network\minio_connect_test.ps1 192.168.1.100:9000
powershell -ExecutionPolicy Bypass -File .\Windows\SystemInfo\system_info.ps1
powershell -ExecutionPolicy Bypass -File .\Windows\SystemInfo\get_gpu_info.ps1
```

Ubuntu：

```bash
./Ubuntu/file_md5.sh "./README.md"
./Ubuntu/file_sha256.sh "./README.md"
./Ubuntu/text_md5.sh "abc"
./Ubuntu/text_md5.sh "abc" "salt"
./Ubuntu/text_sha256.sh "abc"
./Ubuntu/text_sha256.sh "abc" "salt"
```

### 文档约定

- 默认以英文文档为主文档。
- 中文内容使用单独文档维护。
- 中英文文档应在顶部提供互相跳转链接。
- 文档内容应基于当前真实状态，不提前描述尚未实现的功能。
- 当未来新增脚本或功能时，再同步补充对应文档说明。

### 后续维护建议

- 新增文档时，优先采用 `name.md` 和 `name.zh-CN.md` 的配对方式。
- 如果后续文档增多，可以按主题拆分，但仍保持中英文版本之间可直接跳转。
