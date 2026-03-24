# SystemTools

[中文文档 / Chinese Version](./README.zh-CN.md)

### Project Overview

This repository is intended to organize system tools and scripts for future Windows and Ubuntu usage.

### Current Status

- Basic hashing scripts are available for both Windows and Ubuntu.
- `Windows/` scripts are now grouped by category into hashing, network testing, and system information subdirectories.
- `Ubuntu/` currently contains shell scripts for the same hashing tasks.
- `Assets/` is reserved for future supporting files.

### Current Structure

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

### Available Scripts

Windows:

- `Hash/`: File and text hashing scripts.
- `Network/minio_connect_test.ps1`: Test whether a MinIO service is reachable by `IP:Port`.
- `SystemInfo/system_info.ps1`: Dispatcher script that runs all system info components and prints a combined report.
- `SystemInfo/get_*.ps1`: Modular system info scripts for overview, motherboard, network, CPU, GPU, disk, memory, resource usage, and common ports.

Ubuntu:

- `file_md5.sh`: Compute the MD5 hash of a single file.
- `file_sha256.sh`: Compute the SHA256 hash of a single file.
- `text_md5.sh`: Compute the MD5 hash of input text, with an optional salt.
- `text_sha256.sh`: Compute the SHA256 hash of input text, with an optional salt.

### Usage

Windows:

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

Ubuntu:

```bash
./Ubuntu/file_md5.sh "./README.md"
./Ubuntu/file_sha256.sh "./README.md"
./Ubuntu/text_md5.sh "abc"
./Ubuntu/text_md5.sh "abc" "salt"
./Ubuntu/text_sha256.sh "abc"
./Ubuntu/text_sha256.sh "abc" "salt"
```

### Documentation Rules

- English documentation is the primary version by default.
- A separate Chinese document should be provided when needed.
- The English and Chinese documents should link to each other near the top.
- Documentation should reflect the actual current state and should not describe unfinished features in advance.
- When scripts or features are added in the future, their documentation can be updated accordingly.

### Maintenance Notes

- New documents should preferably follow the same pattern, for example `name.md` and `name.zh-CN.md`.
- If the documentation grows later, it can be split by topic while keeping cross-navigation between English and Chinese versions.
