# UniGetUI Automated Deployment & Dependency Manager

An advanced, robust, and fully automated PowerShell deployment script designed to streamline the installation and configuration of **UniGetUI** and its complete dependency ecosystem on Windows 10 and Windows 11.

---

## 🚀 What It Does

This script provides a seamless **Out-Of-The-Box** setup by automating the management of foundational development tools and resolving common pitfalls—such as legacy Python versions and Microsoft Store execution alias conflicts (`WindowsApps`)—ensuring UniGetUI links directly to physical binaries.

### Key Features:
1. **Core Package Management**: Automatically installs or updates essential developer tools using exclusively `winget`:
   - PowerShell 7
   - .NET SDK
   - Node.js (`npm`)
   - Rustup / Cargo
   - C++ Build Tools
   - Chocolatey & Scoop
   - Bun & vcpkg
2. **Python Ecosystem Intelligence**:
   - **Legacy Cleanup**: Scans the system for obsolete `Python 2` packages and removes them silently via `winget` with onscreen logging.
   - **Dynamic Python 3 Management**: Dynamically queries the `winget` catalog, numerically sorts minor versions, and identifies the absolute latest stable release (e.g., Python 3.14+) without hardcoded version numbers.
   - **Path & Pip Resolution**: Automatically configures `pip`, adds Python's `Scripts` directory to the user's `PATH`, and ensures proper integration.
   - **UniGetUI Cache & Config Alignment**: Cleans up `DependencyManagement.json` and ensures UniGetUI binds directly to physical binaries (`C:\Program Files\Python3xx\python.exe`) rather than breaking Microsoft Store execution aliases.

---

## 📋 Prerequisites

- **Operating System**: Windows 10 or Windows 11.
- **Shell Environment**: PowerShell 7 (Recommended).
- **Permissions**: Administrator privileges (required for system-wide package installations and environment variable updates).

---

## ⚙️ How to Execute

1. Open **PowerShell 7** as an **Administrator**.
2. Run the deployment script directly from your repository using the following command:

```powershell
iex "& { $(irm https://raw.githubusercontent.com/federicolm/unigetui-repository/refs/heads/main/UnigetUI-config-repo.ps1) }"
```

Alternatively, you can clone the repository or download the script locally and run it:
```powershell
Set-ExecutionPolicy Unrestricted -Scope Process
.\UnigetUI-config-repo.ps1
```

---

## 🛠️ Script Architecture (Step-by-Step)

| Step | Component | Description |
| :--- | :--- | :--- |
| **[1/10]** | PowerShell 7 | Verifies and updates PowerShell 7 core. |
| **[2/10]** | .NET SDK | Installs or updates the latest .NET development environment. |
| **[3/10]** | Node.js | Sets up JavaScript runtime and `npm`. |
| **[4/10]** | Rustup / Cargo | Deploys the Rust toolchain. |
| **[5/10]** | C++ Build Tools | Ensures native compilation support. |
| **[6/10] & [7/10]** | Chocolatey & Scoop | Configures alternative package managers. |
| **[8/10]** | Bun | Installs the high-performance JavaScript runtime. |
| **[9/10]** | vcpkg | Sets up C/C++ dependency management. |
| **[10/10]** | Python & Pip | Performs Python 2 cleanup, dynamic latest Python 3 acquisition, environment path correction, and UniGetUI cache sanitization. |

---

## 📄 License

This project is open-source software licensed under the **GNU General Public License v3.0 (GPLv3)**. 

You are free to use, modify, and distribute this software under the terms of the GPLv3. See the [LICENSE](LICENSE) file for more details.
