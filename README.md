# SystemTools

[中文文档 / Chinese Version](./README.zh-CN.md)

### Project Overview

This repository is intended to organize system tools and scripts for future Windows and Ubuntu usage.

### Current Status

- Basic hashing scripts are available for both Windows and Ubuntu.
- `Windows/` currently contains PowerShell scripts for file and text hashing.
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
│  ├─ file_md5.ps1
│  ├─ file_sha256.ps1
│  ├─ text_md5.ps1
│  └─ text_sha256.ps1
├─ README.md
└─ README.zh-CN.md
```

### Available Scripts

Windows:

- `file_md5.ps1`: Compute the MD5 hash of a single file.
- `file_sha256.ps1`: Compute the SHA256 hash of a single file.
- `text_md5.ps1`: Compute the MD5 hash of input text, with an optional salt.
- `text_sha256.ps1`: Compute the SHA256 hash of input text, with an optional salt.

Ubuntu:

- `file_md5.sh`: Compute the MD5 hash of a single file.
- `file_sha256.sh`: Compute the SHA256 hash of a single file.
- `text_md5.sh`: Compute the MD5 hash of input text, with an optional salt.
- `text_sha256.sh`: Compute the SHA256 hash of input text, with an optional salt.

### Usage

Windows:

```powershell
powershell -ExecutionPolicy Bypass -File .\Windows\file_md5.ps1 .\README.md
powershell -ExecutionPolicy Bypass -File .\Windows\file_sha256.ps1 .\README.md
powershell -ExecutionPolicy Bypass -File .\Windows\text_md5.ps1 "abc"
powershell -ExecutionPolicy Bypass -File .\Windows\text_md5.ps1 "abc" "salt"
powershell -ExecutionPolicy Bypass -File .\Windows\text_sha256.ps1 "abc"
powershell -ExecutionPolicy Bypass -File .\Windows\text_sha256.ps1 "abc" "salt"
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
