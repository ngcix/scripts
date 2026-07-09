# 🚀 Combo Tối Ưu Build Python → Executable & Bảo Mật Code

## 1. COMBO CÔNG CỤ TỐI ƯU

```
┌─────────────────────────────────────────────────────────┐
│                    COMBO STACK                          │
├─────────────────────────────────────────────────────────┤
│  Build:       Nuitka (compile → C → binary)            │
│  Obfuscate:   PyArmor + Cython                         │
│  Pack:        UPX (compress binary)                    │
│  Installer:   NSIS / Inno Setup                        │
│  Config:      pyproject.toml (PEP 621)                 │
│  Env:         Poetry / uv                              │
│  CI/CD:       GitHub Actions                           │
└─────────────────────────────────────────────────────────┘
```

### So sánh các tool build:

```
┌──────────────┬────────────┬──────────┬───────────┬──────────────┐
│    Tool      │  Bảo mật   │ Tốc độ   │ File size │ Khó reverse  │
├──────────────┼────────────┼──────────┼───────────┼──────────────┤
│ PyInstaller  │ ⭐⭐       │ ⭐⭐⭐⭐  │ Lớn       │ Dễ unpack    │
│ cx_Freeze    │ ⭐⭐       │ ⭐⭐⭐   │ Trung bình│ Dễ unpack    │
│ Nuitka       │ ⭐⭐⭐⭐⭐ │ ⭐⭐⭐   │ Nhỏ       │ Rất khó      │
│ PyArmor      │ ⭐⭐⭐⭐   │ ⭐⭐⭐   │ Trung bình│ Khó          │
│ Cython       │ ⭐⭐⭐⭐   │ ⭐⭐     │ Nhỏ       │ Khó          │
└──────────────┴────────────┴──────────┴───────────┴──────────────┘

👑 WINNER: Nuitka + PyArmor + UPX = Combo bất bại
```

---

## 2. CẤU TRÚC PROJECT HIỆN ĐẠI (2024-2025)

```
my-awesome-app/
│
├── 📁 src/                          # Source layout (PEP 621)
│   └── 📁 my_app/                   # Package chính
│       ├── __init__.py              # Version, metadata
│       ├── __main__.py              # Entry point: python -m my_app
│       ├── app.py                   # Application bootstrap
│       │
│       ├── 📁 core/                 # Business logic thuần
│       │   ├── __init__.py
│       │   ├── engine.py
│       │   ├── processor.py
│       │   └── exceptions.py
│       │
│       ├── 📁 models/               # Data models
│       │   ├── __init__.py
│       │   ├── user.py
│       │   ├── product.py
│       │   └── schemas.py           # Pydantic schemas
│       │
│       ├── 📁 services/             # Service layer
│       │   ├── __init__.py
│       │   ├── auth_service.py
│       │   ├── data_service.py
│       │   └── external_api.py
│       │
│       ├── 📁 repositories/         # Data access layer
│       │   ├── __init__.py
│       │   ├── base.py
│       │   ├── user_repo.py
│       │   └── product_repo.py
│       │
│       ├── 📁 api/                  # API layer (nếu có)
│       │   ├── __init__.py
│       │   ├── routes/
│       │   │   ├── __init__.py
│       │   │   ├── users.py
│       │   │   └── products.py
│       │   ├── middleware.py
│       │   └── dependencies.py
│       │
│       ├── 📁 ui/                   # GUI layer (nếu có)
│       │   ├── __init__.py
│       │   ├── main_window.py
│       │   ├── dialogs/
│       │   └── widgets/
│       │
│       ├── 📁 utils/                # Utilities
│       │   ├── __init__.py
│       │   ├── helpers.py
│       │   ├── validators.py
│       │   ├── crypto.py
│       │   └── logger.py
│       │
│       ├── 📁 config/               # Configuration
│       │   ├── __init__.py
│       │   ├── settings.py          # Pydantic Settings
│       │   ├── constants.py
│       │   └── logging_config.py
│       │
│       └── 📁 infrastructure/       # External concerns
│           ├── __init__.py
│           ├── database.py
│           ├── cache.py
│           └── messaging.py
│
├── 📁 tests/                        # Tests mirror src structure
│   ├── __init__.py
│   ├── conftest.py                  # Pytest fixtures
│   ├── 📁 unit/
│   │   ├── __init__.py
│   │   ├── test_engine.py
│   │   └── test_processor.py
│   ├── 📁 integration/
│   │   ├── __init__.py
│   │   └── test_data_service.py
│   └── 📁 e2e/
│       └── test_full_workflow.py
│
├── 📁 scripts/                      # Build & automation scripts
│   ├── build.py                     # Main build script
│   ├── build_nuitka.py
│   ├── obfuscate.py
│   ├── create_installer.py
│   └── release.py
│
├── 📁 build/                        # Build output (gitignored)
│   ├── 📁 dist/
│   ├── 📁 artifacts/
│   └── 📁 installers/
│
├── 📁 resources/                    # Static resources
│   ├── 📁 assets/
│   │   ├── icons/
│   │   ├── images/
│   │   └── fonts/
│   ├── 📁 templates/
│   ├── 📁 i18n/                     # Internationalization
│   │   ├── en.json
│   │   └── vi.json
│   └── app.ico
│
├── 📁 configs/                      # Runtime configs
│   ├── default.toml
│   ├── development.toml
│   ├── production.toml
│   └── .env.example
│
├── 📁 docs/                         # Documentation
│   ├── architecture.md
│   ├── api.md
│   ├── deployment.md
│   └── 📁 diagrams/
│
├── 📁 .github/                      # CI/CD
│   └── 📁 workflows/
│       ├── ci.yml
│       ├── build.yml
│       └── release.yml
│
├── 📁 docker/                       # Docker (nếu cần)
│   ├── Dockerfile
│   ├── Dockerfile.build
│   └── docker-compose.yml
│
│── ── Config files (root) ──────
├── pyproject.toml                   # 👑 Single source of truth
├── poetry.lock                      # Lock file
├── nuitka.config.yml                # Nuitka build config
├── .pre-commit-config.yaml          # Pre-commit hooks
├── .gitignore
├── .env                             # Local env (gitignored)
├── Makefile                         # Common commands
├── README.md
├── LICENSE
└── CHANGELOG.md
```

---

## 3. CÁC FILE CONFIG CHI TIẾT

### 📄 `pyproject.toml` - Single Source of Truth

```toml
# ============================================================
# PROJECT METADATA (PEP 621)
# ============================================================
[project]
name = "my-awesome-app"
version = "1.0.0"
description = "My awesome application"
readme = "README.md"
license = { text = "MIT" }
requires-python = ">=3.11"
authors = [
    { name = "Your Name", email = "you@example.com" },
]
keywords = ["app", "tool"]
classifiers = [
    "Development Status :: 5 - Production/Stable",
    "Programming Language :: Python :: 3.11",
    "Programming Language :: Python :: 3.12",
]

dependencies = [
    "pydantic>=2.0",
    "pydantic-settings>=2.0",
    "httpx>=0.25",
    "rich>=13.0",
    "tomli>=2.0; python_version < '3.11'",
]

[project.optional-dependencies]
gui = ["PySide6>=6.6"]
api = ["fastapi>=0.104", "uvicorn>=0.24"]
dev = [
    "pytest>=7.4",
    "pytest-cov>=4.1",
    "pytest-asyncio>=0.23",
    "mypy>=1.7",
    "ruff>=0.1.6",
    "pre-commit>=3.6",
]
build = [
    "nuitka>=1.9",
    "pyarmor>=8.4",
    "ordered-set>=4.1",
]

[project.scripts]
my-app = "my_app.app:main"

[project.gui-scripts]
my-app-gui = "my_app.ui.main_window:main"

[project.urls]
Homepage = "https://github.com/you/my-awesome-app"
Documentation = "https://docs.example.com"
Repository = "https://github.com/you/my-awesome-app"

# ============================================================
# BUILD SYSTEM
# ============================================================
[build-system]
requires = ["poetry-core>=1.0.0"]
build-backend = "poetry.core.masonry.api"

# ============================================================
# POETRY CONFIG
# ============================================================
[tool.poetry]
packages = [{ include = "my_app", from = "src" }]

# ============================================================
# RUFF - Linter & Formatter (thay thế black + isort + flake8)
# ============================================================
[tool.ruff]
target-version = "py311"
line-length = 100
src = ["src", "tests"]

[tool.ruff.lint]
select = [
    "E",    # pycodestyle errors
    "W",    # pycodestyle warnings
    "F",    # pyflakes
    "I",    # isort
    "N",    # pep8-naming
    "UP",   # pyupgrade
    "B",    # flake8-bugbear
    "SIM",  # flake8-simplify
    "S",    # flake8-bandit (security)
    "A",    # flake8-builtins
    "C4",   # flake8-comprehensions
    "DTZ",  # flake8-datetimez
    "T20",  # flake8-print
    "RUF",  # ruff-specific
]
ignore = ["E501", "S101"]

[tool.ruff.lint.isort]
known-first-party = ["my_app"]

[tool.ruff.format]
quote-style = "double"
indent-style = "space"

# ============================================================
# MYPY - Type Checking
# ============================================================
[tool.mypy]
python_version = "3.11"
strict = true
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true
plugins = ["pydantic.mypy"]

[[tool.mypy.overrides]]
module = "tests.*"
disallow_untyped_defs = false

# ============================================================
# PYTEST
# ============================================================
[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = "test_*.py"
python_classes = "Test*"
python_functions = "test_*"
addopts = [
    "-v",
    "--strict-markers",
    "--cov=src/my_app",
    "--cov-report=term-missing",
    "--cov-report=html:build/coverage",
    "--tb=short",
]
markers = [
    "slow: marks tests as slow",
    "integration: integration tests",
    "e2e: end-to-end tests",
]
asyncio_mode = "auto"

[tool.coverage.run]
source = ["src/my_app"]
omit = ["*/tests/*", "*/__main__.py"]

[tool.coverage.report]
precision = 2
show_missing = true
fail_under = 80
```

### 📄 `src/my_app/config/settings.py`

```python
"""
Application settings using pydantic-settings.
Supports: .env files, environment variables, TOML configs.
"""
from __future__ import annotations

import tomllib
from enum import Enum
from functools import lru_cache
from pathlib import Path
from typing import Any

from pydantic import Field, SecretStr, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


# ── Paths ──────────────────────────────────────────────
ROOT_DIR = Path(__file__).resolve().parent.parent.parent.parent  # project root
CONFIGS_DIR = ROOT_DIR / "configs"
RESOURCES_DIR = ROOT_DIR / "resources"


class Environment(str, Enum):
    DEVELOPMENT = "development"
    STAGING = "staging"
    PRODUCTION = "production"


class DatabaseSettings(BaseSettings):
    """Database configuration."""
    model_config = SettingsConfigDict(env_prefix="DB_")

    host: str = "localhost"
    port: int = 5432
    name: str = "myapp"
    user: str = "postgres"
    password: SecretStr = SecretStr("changeme")
    pool_size: int = 10
    echo: bool = False

    @property
    def url(self) -> str:
        pwd = self.password.get_secret_value()
        return f"postgresql+asyncpg://{self.user}:{pwd}@{self.host}:{self.port}/{self.name}"


class SecuritySettings(BaseSettings):
    """Security configuration."""
    model_config = SettingsConfigDict(env_prefix="SECURITY_")

    secret_key: SecretStr = SecretStr("change-this-in-production")
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 30
    allowed_origins: list[str] = ["http://localhost:3000"]
    enable_https: bool = False


class LoggingSettings(BaseSettings):
    """Logging configuration."""
    model_config = SettingsConfigDict(env_prefix="LOG_")

    level: str = "INFO"
    format: str = "%(asctime)s | %(levelname)-8s | %(name)s | %(message)s"
    file: Path | None = None
    rotation: str = "10 MB"
    retention: str = "30 days"
    json_output: bool = False


class AppSettings(BaseSettings):
    """
    Main application settings.
    Priority: ENV vars > .env file > TOML config > defaults
    """
    model_config = SettingsConfigDict(
        env_prefix="APP_",
        env_file=".env",
        env_file_encoding="utf-8",
        env_nested_delimiter="__",
        case_sensitive=False,
        extra="ignore",
    )

    # ── App ────────────────────────────────────────────
    name: str = "My Awesome App"
    version: str = "1.0.0"
    env: Environment = Environment.DEVELOPMENT
    debug: bool = False
    host: str = "0.0.0.0"
    port: int = 8000

    # ── Sub-configs ────────────────────────────────────
    database: DatabaseSettings = Field(default_factory=DatabaseSettings)
    security: SecuritySettings = Field(default_factory=SecuritySettings)
    logging: LoggingSettings = Field(default_factory=LoggingSettings)

    # ── Paths ──────────────────────────────────────────
    data_dir: Path = ROOT_DIR / "data"
    resources_dir: Path = RESOURCES_DIR

    @field_validator("env", mode="before")
    @classmethod
    def validate_env(cls, v: Any) -> Environment:
        if isinstance(v, str):
            return Environment(v.lower())
        return v

    @property
    def is_production(self) -> bool:
        return self.env == Environment.PRODUCTION

    @property
    def is_development(self) -> bool:
        return self.env == Environment.DEVELOPMENT


@lru_cache(maxsize=1)
def get_settings(**overrides: Any) -> AppSettings:
    """Get cached settings instance."""
    return AppSettings(**overrides)


# Convenience
settings = get_settings()
```

### 📄 `src/my_app/__init__.py`

```python
"""My Awesome App."""
from importlib.metadata import version, PackageNotFoundError

try:
    __version__ = version("my-awesome-app")
except PackageNotFoundError:
    __version__ = "0.0.0-dev"

__all__ = ["__version__"]
```

### 📄 `src/my_app/__main__.py`

```python
"""Entry point for `python -m my_app`."""
from my_app.app import main

if __name__ == "__main__":
    main()
```

---

## 4. BUILD SCRIPTS

### 📄 `scripts/build.py` - Master Build Script

```python
#!/usr/bin/env python3
"""
Master build script - orchestrates the entire build pipeline.

Usage:
    python scripts/build.py --target windows --mode release
    python scripts/build.py --target linux --mode debug
"""
from __future__ import annotations

import argparse
import os
import platform
import shutil
import subprocess
import sys
from dataclasses import dataclass, field
from enum import Enum
from pathlib import Path
from typing import Sequence

# ── Constants ──────────────────────────────────────────
ROOT_DIR = Path(__file__).resolve().parent.parent
SRC_DIR = ROOT_DIR / "src"
BUILD_DIR = ROOT_DIR / "build"
DIST_DIR = BUILD_DIR / "dist"
RESOURCES_DIR = ROOT_DIR / "resources"


class BuildMode(str, Enum):
    DEBUG = "debug"
    RELEASE = "release"


class TargetPlatform(str, Enum):
    WINDOWS = "windows"
    LINUX = "linux"
    MACOS = "macos"
    AUTO = "auto"


@dataclass
class BuildConfig:
    """Build configuration."""
    app_name: str = "MyAwesomeApp"
    version: str = "1.0.0"
    mode: BuildMode = BuildMode.RELEASE
    target: TargetPlatform = TargetPlatform.AUTO
    icon: Path = RESOURCES_DIR / "app.ico"
    entry_point: Path = SRC_DIR / "my_app" / "app.py"
    output_dir: Path = DIST_DIR

    # Feature flags
    use_nuitka: bool = True
    use_pyarmor: bool = True
    use_upx: bool = True
    onefile: bool = True
    console: bool = False  # False = GUI app

    # Nuitka options
    nuitka_jobs: int = os.cpu_count() or 4
    include_packages: list[str] = field(default_factory=lambda: ["my_app"])
    include_data: list[tuple[str, str]] = field(default_factory=list)
    extra_nuitka_args: list[str] = field(default_factory=list)

    def __post_init__(self) -> None:
        if self.target == TargetPlatform.AUTO:
            system = platform.system().lower()
            self.target = {
                "windows": TargetPlatform.WINDOWS,
                "linux": TargetPlatform.LINUX,
                "darwin": TargetPlatform.MACOS,
            }.get(system, TargetPlatform.LINUX)


class Builder:
    """Main builder class."""

    def __init__(self, config: BuildConfig) -> None:
        self.config = config
        self.build_steps: list[str] = []

    def clean(self) -> None:
        """Clean previous build artifacts."""
        print("🧹 Cleaning build directory...")
        if BUILD_DIR.exists():
            shutil.rmtree(BUILD_DIR)
        BUILD_DIR.mkdir(parents=True, exist_ok=True)
        DIST_DIR.mkdir(parents=True, exist_ok=True)

    def obfuscate_with_pyarmor(self) -> Path:
        """Obfuscate source code with PyArmor."""
        print("🔒 Obfuscating with PyArmor...")
        obfuscated_dir = BUILD_DIR / "obfuscated"

        cmd = [
            sys.executable, "-m", "pyarmor",
            "gen",
            "--output", str(obfuscated_dir),
            "--platform", "windows.x86_64" if self.config.target == TargetPlatform.WINDOWS else "linux.x86_64",
            "--enable-rft",    # Rename Function/class names (chống reverse)
            "--enable-bcc",    # Compile to C (extra protection)
            "--enable-jit",    # JIT protection
            "--restrict",      # Restrict mode
            str(SRC_DIR / "my_app"),
        ]

        subprocess.run(cmd, check=True, cwd=ROOT_DIR)
        self.build_steps.append("PyArmor obfuscation")
        return obfuscated_dir

    def build_with_nuitka(self, source_dir: Path | None = None) -> Path:
        """Compile with Nuitka."""
        print("⚡ Building with Nuitka...")

        entry = source_dir / "my_app" / "app.py" if source_dir else self.config.entry_point

        cmd = [
            sys.executable, "-m", "nuitka",

            # ── Output ─────────────────────────────
            f"--output-dir={DIST_DIR}",
            f"--output-filename={self.config.app_name}",

            # ── Mode ───────────────────────────────
            *(["--onefile"] if self.config.onefile else ["--standalone"]),
            *(["--windows-console-mode=disable"] if not self.config.console and self.config.target == TargetPlatform.WINDOWS else []),

            # ── Performance ────────────────────────
            f"--jobs={self.config.nuitka_jobs}",
            "--lto=yes",
            "--clang" if self.config.target != TargetPlatform.WINDOWS else "--mingw64",

            # ── Icon ───────────────────────────────
            *(
                [f"--windows-icon-from-ico={self.config.icon}"]
                if self.config.target == TargetPlatform.WINDOWS and self.config.icon.exists()
                else []
            ),
            *(
                [f"--linux-icon={self.config.icon}"]
                if self.config.target == TargetPlatform.LINUX and self.config.icon.exists()
                else []
            ),

            # ── Metadata ───────────────────────────
            f"--product-name={self.config.app_name}",
            f"--product-version={self.config.version}",
            f"--file-version={self.config.version}",
            "--company-name=MyCompany",
            "--copyright=Copyright © 2024 MyCompany",

            # ── Include ───────────────────────────
            *[f"--include-package={pkg}" for pkg in self.config.include_packages],

            # ── Data files ─────────────────────────
            f"--include-data-dir={RESOURCES_DIR / 'assets'}=assets",
            f"--include-data-dir={ROOT_DIR / 'configs'}=configs",

            # ── Plugins ────────────────────────────
            "--enable-plugin=anti-bloat",
            "--enable-plugin=upx" if self.config.use_upx else "",

            # ── Optimization (Release) ─────────────
            *(["--remove-output"] if self.config.mode == BuildMode.RELEASE else []),

            # ── Extra ──────────────────────────────
            *self.config.extra_nuitka_args,

            # ── Entry point ────────────────────────
            str(entry),
        ]

        # Remove empty strings
        cmd = [c for c in cmd if c]

        subprocess.run(cmd, check=True, cwd=ROOT_DIR)
        self.build_steps.append("Nuitka compilation")

        # Return path to built executable
        exe_ext = ".exe" if self.config.target == TargetPlatform.WINDOWS else ""
        return DIST_DIR / f"{self.config.app_name}{exe_ext}"

    def compress_with_upx(self, executable: Path) -> None:
        """Compress executable with UPX."""
        if not self.config.use_upx:
            return

        upx_path = shutil.which("upx")
        if not upx_path:
            print("⚠️  UPX not found, skipping compression")
            return

        print("📦 Compressing with UPX...")
        cmd = [
            upx_path,
            "--best",         # Best compression
            "--lzma",         # LZMA algorithm
            "--overlay=copy", # Preserve overlay data
            str(executable),
        ]
        subprocess.run(cmd, check=True)
        self.build_steps.append("UPX compression")

    def create_checksum(self, executable: Path) -> None:
        """Create SHA256 checksum file."""
        import hashlib
        print("🔐 Creating checksum...")

        sha256 = hashlib.sha256()
        with open(executable, "rb") as f:
            for chunk in iter(lambda: f.read(8192), b""):
                sha256.update(chunk)

        checksum_file = executable.with_suffix(".sha256")
        checksum_file.write_text(f"{sha256.hexdigest()}  {executable.name}\n")
        print(f"   Checksum: {sha256.hexdigest()}")

    def build(self) -> Path:
        """Execute full build pipeline."""
        print(f"""
╔══════════════════════════════════════════════╗
║          🚀 BUILD PIPELINE START            ║
║  App:      {self.config.app_name:<32} ║
║  Version:  {self.config.version:<32} ║
║  Mode:     {self.config.mode.value:<32} ║
║  Target:   {self.config.target.value:<32} ║
╚══════════════════════════════════════════════╝
        """)

        # Step 1: Clean
        self.clean()

        # Step 2: Obfuscate (optional, for release)
        source_dir = None
        if self.config.use_pyarmor and self.config.mode == BuildMode.RELEASE:
            source_dir = self.obfuscate_with_pyarmor()

        # Step 3: Compile with Nuitka
        executable = self.build_with_nuitka(source_dir)

        # Step 4: Compress with UPX
        self.compress_with_upx(executable)

        # Step 5: Create checksum
        self.create_checksum(executable)

        # Summary
        size_mb = executable.stat().st_size / (1024 * 1024)
        print(f"""
╔══════════════════════════════════════════════╗
║          ✅ BUILD COMPLETE                   ║
║  Output:   {str(executable.name):<32} ║
║  Size:     {size_mb:.1f} MB{' ' * 27}║
║  Steps:    {', '.join(self.build_steps):<32} ║
╚══════════════════════════════════════════════╝
        """)

        return executable


def parse_args(argv: Sequence[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Build application")
    parser.add_argument(
        "--mode", "-m",
        type=BuildMode,
        default=BuildMode.RELEASE,
        choices=list(BuildMode),
    )
    parser.add_argument(
        "--target", "-t",
        type=TargetPlatform,
        default=TargetPlatform.AUTO,
        choices=list(TargetPlatform),
    )
    parser.add_argument("--no-pyarmor", action="store_true")
    parser.add_argument("--no-upx", action="store_true")
    parser.add_argument("--console", action="store_true")
    parser.add_argument("--no-onefile", action="store_true")
    return parser.parse_args(argv)


def main(argv: Sequence[str] | None = None) -> None:
    args = parse_args(argv)

    config = BuildConfig(
        mode=args.mode,
        target=args.target,
        use_pyarmor=not args.no_pyarmor,
        use_upx=not args.no_upx,
        console=args.console,
        onefile=not args.no_onefile,
    )

    builder = Builder(config)
    builder.build()


if __name__ == "__main__":
    main()
```

---

## 5. BẢO MẬT CODE - LAYERS OF PROTECTION

```
┌─────────────────────────────────────────────────────────┐
│                  LAYER 1: SOURCE                        │
│  • Cython compile .py → .so/.pyd (native C extension)  │
│  • Chỉ compile core business logic                     │
└────────────────────────┬────────────────────────────────┘
                         ▼
┌─────────────────────────────────────────────────────────┐
│                  LAYER 2: OBFUSCATION                   │
│  • PyArmor RFT: rename functions/classes                │
│  • PyArmor BCC: compile bytecode → C                   │
│  • PyArmor JIT: runtime protection                     │
└────────────────────────┬────────────────────────────────┘
                         ▼
┌─────────────────────────────────────────────────────────┐
│                  LAYER 3: COMPILATION                   │
│  • Nuitka: Python → C → Machine Code                   │
│  • Strips debug symbols                                │
│  • Static linking where possible                       │
└────────────────────────┬────────────────────────────────┘
                         ▼
┌─────────────────────────────────────────────────────────┐
│                  LAYER 4: BINARY PROTECTION             │
│  • UPX compression (anti-static analysis)              │
│  • Code signing (authenticode/gpg)                     │
│  • Anti-tamper checksums                               │
└─────────────────────────────────────────────────────────┘
```

### 📄 `scripts/cython_compile.py` - Compile core modules

```python
"""Compile critical modules with Cython for extra protection."""
from pathlib import Path
from Cython.Build import cythonize
from setuptools import Extension, setup

# Chỉ compile những module chứa business logic quan trọng
MODULES_TO_COMPILE = [
    "src/my_app/core/engine.py",
    "src/my_app/core/processor.py",
    "src/my_app/services/auth_service.py",
    "src/my_app/utils/crypto.py",
]

extensions = [
    Extension(
        name=str(Path(mod).with_suffix("")).replace("/", ".").replace("src.", ""),
        sources=[mod],
    )
    for mod in MODULES_TO_COMPILE
]

setup(
    ext_modules=cythonize(
        extensions,
        compiler_directives={
            "language_level": "3",
            "boundscheck": False,
            "wraparound": False,
        },
    ),
)
```

### 📄 Runtime protection trong code

```python
# src/my_app/utils/protection.py
"""Runtime anti-debugging and anti-tamper protection."""
from __future__ import annotations

import hashlib
import os
import sys
from functools import wraps
from pathlib import Path
from typing import Callable, TypeVar, ParamSpec

P = ParamSpec("P")
R = TypeVar("R")


def anti_debug() -> bool:
    """Detect if debugger is attached."""
    # Check common debugger indicators
    checks = [
        # Python debugger
        lambda: hasattr(sys, 'gettrace') and sys.gettrace() is not None,
        # PyDevd (PyCharm debugger)
        lambda: 'pydevd' in sys.modules,
        # Environment variables
        lambda: os.environ.get('PYTHONDONTWRITEBYTECODE') == '1' and os.environ.get('PYTHONUNBUFFERED') == '1',
    ]

    return any(check() for check in checks)


def verify_integrity(expected_hash: str | None = None) -> bool:
    """Verify executable hasn't been tampered with."""
    if getattr(sys, 'frozen', False):
        exe_path = Path(sys.executable)
        current_hash = hashlib.sha256(exe_path.read_bytes()).hexdigest()
        if expected_hash and current_hash != expected_hash:
            return False
    return True


def protected(func: Callable[P, R]) -> Callable[P, R]:
    """Decorator to protect critical functions."""
    @wraps(func)
    def wrapper(*args: P.args, **kwargs: P.kwargs) -> R:
        if anti_debug():
            raise RuntimeError("Debug environment detected")
        return func(*args, **kwargs)
    return wrapper


class LicenseManager:
    """Simple license verification."""

    def __init__(self, public_key: str) -> None:
        self._public_key = public_key

    def verify(self, license_key: str) -> bool:
        """Verify license key."""
        # Implement your license verification logic
        # Use RSA/ECDSA signature verification
        ...
        return True

    def get_machine_id(self) -> str:
        """Get unique machine identifier."""
        import uuid
        return str(uuid.getnode())
```

---

## 6. MAKEFILE - Convenient Commands

```makefile
# Makefile
.PHONY: help install dev test lint format build clean

PYTHON := python
APP_NAME := my-awesome-app

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# ── Development ────────────────────────────────────────
install: ## Install dependencies
	poetry install

dev: ## Install with dev dependencies
	poetry install --with dev,build

# ── Quality ────────────────────────────────────────────
lint: ## Run linter
	poetry run ruff check src/ tests/
	poetry run mypy src/

format: ## Format code
	poetry run ruff format src/ tests/
	poetry run ruff check --fix src/ tests/

test: ## Run tests
	poetry run pytest

test-cov: ## Run tests with coverage
	poetry run pytest --cov --cov-report=html
	@echo "Coverage report: build/coverage/index.html"

# ── Build ──────────────────────────────────────────────
build: ## Build release executable
	$(PYTHON) scripts/build.py --mode release

build-debug: ## Build debug executable
	$(PYTHON) scripts/build.py --mode debug --console --no-pyarmor

build-quick: ## Quick build (no obfuscation, no compression)
	$(PYTHON) scripts/build.py --mode debug --no-pyarmor --no-upx --console

# ── Clean ──────────────────────────────────────────────
clean: ## Clean build artifacts
	rm -rf build/ dist/ *.egg-info
	find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete 2>/dev/null || true
	find . -type f -name "*.pyo" -delete 2>/dev/null || true

# ── Docker ─────────────────────────────────────────────
docker-build: ## Build in Docker (cross-platform)
	docker build -f docker/Dockerfile.build -t $(APP_NAME)-builder .
	docker run --rm -v $(PWD)/build:/app/build $(APP_NAME)-builder

# ── Release ────────────────────────────────────────────
release: lint test build ## Full release pipeline
	@echo "✅ Release build complete!"
```

---

## 7. CI/CD - GitHub Actions

```yaml
# .github/workflows/build.yml
name: Build & Release

on:
  push:
    tags: ['v*']
  workflow_dispatch:

jobs:
  build:
    strategy:
      matrix:
        include:
          - os: windows-latest
            target: windows
            ext: .exe
          - os: ubuntu-latest
            target: linux
            ext: ""
          - os: macos-latest
            target: macos
            ext: ""

    runs-on: ${{ matrix.os }}

    steps:
      - uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.12"

      - name: Install Poetry
        uses: snok/install-poetry@v1

      - name: Install dependencies
        run: poetry install --with build

      - name: Install UPX (Linux)
        if: matrix.target == 'linux'
        run: sudo apt-get install -y upx

      - name: Install UPX (Windows)
        if: matrix.target == 'windows'
        run: choco install upx

      - name: Run tests
        run: poetry run pytest --tb=short

      - name: Build executable
        run: poetry run python scripts/build.py --target ${{ matrix.target }} --mode release

      - name: Upload artifact
        uses: actions/upload-artifact@v4
        with:
          name: ${{ matrix.target }}-build
          path: build/dist/*

  release:
    needs: build
    runs-on: ubuntu-latest
    if: startsWith(github.ref, 'refs/tags/v')

    steps:
      - name: Download all artifacts
        uses: actions/download-artifact@v4

      - name: Create Release
        uses: softprops/action-gh-release@v1
        with:
          files: |
            windows-build/*
            linux-build/*
            macos-build/*
          generate_release_notes: true
```

---

## 8. TỔNG KẾT - BEST PRACTICES

```
╔═══════════════════════════════════════════════════════════╗
║                    CHECKLIST                              ║
╠═══════════════════════════════════════════════════════════╣
║                                                           ║
║  📁 Structure:                                           ║
║  ✅ src/ layout (PEP 621 standard)                       ║
║  ✅ Tách layers: core/services/repos/api                 ║
║  ✅ Config riêng, resources riêng                        ║
║  ✅ Tests mirror source structure                        ║
║                                                           ║
║  📄 Config:                                              ║
║  ✅ pyproject.toml = single source of truth              ║
║  ✅ pydantic-settings cho runtime config                 ║
║  ✅ .env cho secrets (gitignored)                        ║
║  ✅ TOML cho app config (versioned)                      ║
║                                                           ║
║  🔒 Security (4 layers):                                 ║
║  ✅ Layer 1: Cython compile critical modules             ║
║  ✅ Layer 2: PyArmor obfuscation (RFT + BCC)            ║
║  ✅ Layer 3: Nuitka compile → native binary              ║
║  ✅ Layer 4: UPX + code signing + checksums             ║
║                                                           ║
║  🛠️ Tooling:                                             ║
║  ✅ Poetry/uv for dependency management                  ║
║  ✅ Ruff for linting + formatting (all-in-one)           ║
║  ✅ Mypy for type checking                               ║
║  ✅ Pre-commit hooks                                     ║
║  ✅ GitHub Actions CI/CD                                 ║
║                                                           ║
║  📦 Build:                                               ║
║  ✅ Nuitka (best protection + performance)               ║
║  ✅ Automated build script                               ║
║  ✅ Cross-platform support                               ║
║  ✅ Makefile for common commands                         ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
```

> **TL;DR**: Dùng **Nuitka + PyArmor + UPX** để build & bảo mật. Cấu trúc theo **src/ layout** với **pyproject.toml** làm single config. Tách code thành **core/services/repos** layers. Dùng **Poetry + Ruff + Mypy** cho development workflow.