# SystemTools

[English Version / 英文文档](./README.md)

### 项目说明

这是一个用于整理系统工具与脚本的仓库，计划面向 Windows 和 Ubuntu 使用场景。

### 当前状态

- 当前已经提供 Windows 和 Ubuntu 两侧的基础哈希脚本。
- `Windows/` 目录中包含 PowerShell 版文件哈希、文本哈希和 MinIO 连接测试脚本。
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
│  ├─ file_md5.ps1
│  ├─ file_sha256.ps1
│  ├─ minio_connect_test.ps1
│  ├─ text_md5.ps1
│  └─ text_sha256.ps1
├─ README.md
└─ README.zh-CN.md
```

### 当前脚本

Windows：

- `file_md5.ps1`：计算单个文件的 MD5。
- `file_sha256.ps1`：计算单个文件的 SHA256。
- `minio_connect_test.ps1`：通过 `IP:Port` 检测 MinIO 服务是否可连接。
- `text_md5.ps1`：计算文本的 MD5，可选盐值。
- `text_sha256.ps1`：计算文本的 SHA256，可选盐值。

Ubuntu：

- `file_md5.sh`：计算单个文件的 MD5。
- `file_sha256.sh`：计算单个文件的 SHA256。
- `text_md5.sh`：计算文本的 MD5，可选盐值。
- `text_sha256.sh`：计算文本的 SHA256，可选盐值。

### 使用示例

Windows：

```powershell
powershell -ExecutionPolicy Bypass -File .\Windows\file_md5.ps1 .\README.md
powershell -ExecutionPolicy Bypass -File .\Windows\file_sha256.ps1 .\README.md
powershell -ExecutionPolicy Bypass -File .\Windows\minio_connect_test.ps1 192.168.1.100:9000
powershell -ExecutionPolicy Bypass -File .\Windows\text_md5.ps1 "abc"
powershell -ExecutionPolicy Bypass -File .\Windows\text_md5.ps1 "abc" "salt"
powershell -ExecutionPolicy Bypass -File .\Windows\text_sha256.ps1 "abc"
powershell -ExecutionPolicy Bypass -File .\Windows\text_sha256.ps1 "abc" "salt"
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
