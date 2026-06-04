# Master Prompt: Debian WSL2 Swiss-Army-Knife Development Environment

For the following task, produce two clearly separated outputs:

## Output 1: Architecture and Implementation Plan

First, produce a practical, opinionated architecture and implementation plan. Explain the recommended environment design, install strategy, dependency isolation model, folder structure, agent-discoverability approach, and maintenance strategy.

## Output 2: Bootstrap Implementation Proposal

Second, produce a separate bootstrap implementation proposal that follows the architecture from Output 1. The bootstrap should be safe, modular, idempotent, and should not blindly install every possible package without explaining the rationale.

Do not jump straight into a giant install script. First explain the plan, then provide the implementation proposal.

---

# Role

You are acting as a senior WSL, Debian, DevOps, security tooling, and developer-workstation architect.

Design a maintainable WSL2 Debian development environment for a senior developer using VS Code and AI coding agents.

The environment should function as a broad “Swiss Army knife” development workstation while avoiding:

- Uncontrolled global installs
- Duplicate tool installations
- Duplicate Python virtual environments
- One massive global Python environment
- One giant fragile PATH
- Repeated setup work by future AI agents
- Confusion about which tools are already installed
- Project dependency contamination across unrelated projects

The design should be practical, durable, and suitable for real day-to-day development work.

---

# Target Platform Assumptions

Assume the following unless stated otherwise:

- WSL2
- Debian-based WSL distribution
- Windows host machine
- VS Code as the primary editor
- VS Code Remote - WSL integration
- sudo access inside Debian
- User works primarily from the Linux filesystem for active projects
- Project folders should generally live under the WSL filesystem, not `/mnt/c`, when performance matters
- This is a personal development workstation, not a production server
- The user is comfortable with CLI workflows
- The environment will be used by both the human developer and AI coding agents
- The environment should support many unrelated projects over time

---

# Primary Goal

Design a reusable, maintainable, Debian WSL2 development environment that can support many types of projects without requiring constant reinstalling, rediscovery, or duplicate setup by future AI agents.

The result should make it easy for a human developer or AI agent to answer:

- What tools are already installed?
- Where are tools installed?
- Which tools are global?
- Which tools are project-specific?
- Which language runtimes are available?
- Which package managers are expected?
- Which tools should not be installed globally?
- How should a new project be initialized?
- How should future agents avoid duplicating work?

---

# Workloads the Environment Must Support

The environment should support the following workloads.

## 1. Modern Software Development

Support general development across:

- Python
- JavaScript
- TypeScript
- HTML
- CSS
- Node.js
- C
- C++
- C#
- .NET
- Rust
- Go
- Java
- Shell scripting
- SQL
- Markdown
- JSON / YAML / TOML

## 2. Legacy Code Modernization

Support modernization of older codebases, including:

- Reading and refactoring legacy source code
- Modernizing old C/C++ projects
- Migrating old scripts and utilities
- Understanding historical build systems
- Building or testing old source trees where feasible
- Using AI coding agents to explain, restructure, port, or document old code

## 3. Reverse Engineering and DOS-Era Application Analysis

Support analysis of older applications and binaries, especially DOS-era or legacy binaries.

Relevant capabilities include:

- Binary inspection
- Hex editing
- Disassembly
- Debugging
- File format inspection
- Static analysis
- Dynamic analysis where appropriate
- Emulator or compatibility tooling where appropriate
- Optional isolation for security-sensitive analysis

Candidate tools may include:

- GDB
- LLDB
- Ghidra
- Radare2
- ImHex
- Frida
- Binutils
- File
- Strings
- Hexdump / xxd
- ExifTool
- Wireshark
- DOSBox or DOSBox-X where appropriate
- QEMU where appropriate

## 4. Image Processing and Creative Automation

Support day-to-day workflows involving:

- Image cleanup
- Batch image manipulation
- Upscaling workflows
- Cell shading or stylization
- Computer vision
- Format conversion
- Metadata inspection
- Automation pipelines

Candidate tools and libraries may include:

- Pillow
- OpenCV
- ImageMagick
- FFmpeg
- NumPy
- PyTorch
- Keras / TensorFlow if appropriate
- Matplotlib
- Scikit-image if appropriate

Heavy GPU or CUDA-related tooling should be treated as optional unless explicitly requested.

## 5. Office Document Automation

Support automation and manipulation of:

- PowerPoint files
- Excel files
- Word documents
- PDFs
- CSV files
- Markdown documents
- Google Docs / Google Sheets-compatible workflows where practical

Candidate libraries and tools may include:

- python-docx
- python-pptx
- openpyxl
- pandas
- XlsxWriter
- PyPDF / pypdf
- pdfplumber
- reportlab
- pandoc
- LibreOffice CLI where useful
- OCR tooling where appropriate
- Google API client libraries where appropriate

The design should distinguish between general document automation tooling and project-specific dependencies.

## 6. Data Science, Analytics, and Machine Learning

Support data analysis and ML experimentation using:

- Pandas
- NumPy
- SQLAlchemy
- Dask
- Matplotlib
- Seaborn
- Plotly
- Scikit-learn
- JupyterLab
- PyTorch
- Keras / TensorFlow where appropriate

Large ML frameworks should not automatically be installed globally unless there is a strong reason. Prefer project-specific environments or optional install modules.

## 7. Web Research, Scraping, and API Collection

Support research-heavy workflows where newer web content may need to be retrieved, organized, processed, summarized, or archived.

Relevant capabilities include:

- HTTP requests
- API exploration
- HTML parsing
- Web scraping
- Browser automation
- Research note organization
- Local artifact storage
- Markdown output
- Structured data extraction

Candidate tools and libraries may include:

- requests
- httpx
- BeautifulSoup
- lxml
- Scrapy
- Playwright
- Selenium if needed
- Pandas
- JupyterLab
- sqlite-utils
- DuckDB
- ripgrep
- fd
- jq
- yq

## 8. AI-Assisted “Vibe Coding”

The environment should work well with VS Code and AI coding agents.

It should help AI agents:

- Discover installed tools
- Avoid duplicate installation
- Understand project conventions
- Use the correct package manager
- Use project-local virtual environments
- Respect global-vs-local dependency boundaries
- Generate scripts and code that match the environment
- Check a tool manifest before recommending installation
- Update documentation when tooling changes

---

# Candidate Tools and Ecosystems

Consider the following tools and ecosystems as candidates. You may add, remove, or reorganize tools based on best practices.

## Core Development

- git
- GitHub CLI
- curl
- wget
- unzip
- zip
- tar
- build-essential
- pkg-config
- make
- cmake
- ninja-build
- gcc
- g++
- clang
- gdb
- lldb
- valgrind
- strace
- ripgrep
- fd-find
- fzf
- bat
- delta
- jq
- yq
- tree
- sqlite3
- tmux
- entr
- tokei
- htop / btop
- shellcheck
- shfmt
- socat

Notes:
- `ltrace` removed — niche, not needed day-to-day
- `bat` replaces plain `cat` for file reading — syntax highlighting is essential for agents parsing source
- `delta` replaces the default git diff pager — makes diffs readable at a glance
- `fzf` is used constantly for fuzzy file/history search in agent-driven shell workflows
- `tmux` allows long-running agent tasks to survive disconnections
- `entr` re-runs commands when files change — lightweight watch without a build system
- `tokei` gives fast language/LOC breakdown of any codebase — agents use this to orient on first open
- `socat` for ad-hoc socket/pipe debugging
- `sqlite3` CLI should be globally available — it underpins many lightweight data tools

## Python

- Python 3 (system, managed by Debian)
- pip (system only — project work uses uv)
- venv
- pyenv (for managing multiple Python versions — legacy code work often needs older runtimes)
- pipx (global Python CLI tools only)
- uv (primary project dependency manager — replaces pip, venv, and poetry for new projects)
- ruff (linting + formatting — replaces black and flake8)
- pytest
- mypy
- ipython
- jupyterlab

Notes:
- `poetry` removed — uv covers all its use cases with better performance and simpler model
- `black` removed — ruff format replaces it
- Rule for agents: never run `pip install` globally; always use `uv` inside a project `.venv`

## Web Development

- Node.js (via NodeSource — system-wide runtime)
- npm (comes with Node.js)
- pnpm (preferred package manager for new projects)
- TypeScript (project-local via pnpm/npm, not global)
- ESLint (project-local)
- Prettier (project-local)
- tsx (global via npm — allows running TypeScript files directly without a build step)
- Vite or similar (project-local only)

Notes:
- `yarn` removed — pnpm covers it with better performance and disk efficiency
- TypeScript, ESLint, Prettier are project-local; only `tsx` warrants a global install for quick scripting

## C / C++

Compilers, debuggers, and build tools are covered under Core Development above.
C/C++-specific additions:

- clang-format
- clang-tidy
- address sanitizer / undefined behaviour sanitizer (asan/ubsan — built into gcc/clang, no separate install)
- lcov (coverage reporting)

## C# / .NET

- .NET SDK
- dotnet CLI
- C# VS Code tooling

## Rust

- rustup
- cargo
- rustfmt
- clippy

## Go

- Go toolchain
- gofmt
- golangci-lint if appropriate

## Java

- OpenJDK
- Gradle
- Maven if appropriate
- SDKMAN if justified

## Reverse Engineering

WSL-native (CLI tools, install inside WSL):
- Radare2
- Binutils (objdump, nm, readelf, strings, strip — part of build-essential)
- file
- xxd
- hexdump
- ExifTool
- tshark (CLI-only Wireshark — no GUI needed in WSL)
- binwalk (firmware and binary extraction)
- p7zip-full (archive inspection and extraction)
- foremost (file carving from raw binary data)
- Frida (dynamic instrumentation — install via pipx)

GUI tools — support both WSL and Windows paths:
- Ghidra (actively used — support both: WSL install via OpenJDK + direct download, AND Windows-native install; bootstrap should document both and install the WSL path by default)
- ImHex (native Windows build preferred; WSLg acceptable)
- Wireshark (GUI — Windows install preferred; tshark handles WSL capture needs)

Optional / isolated (container or VM recommended for risky samples):
- DOSBox-X (niche — optional install only)
- QEMU (large — optional, use containers where possible)

Notes:
- `strings` removed as separate entry — it is part of binutils
- Wireshark GUI removed from WSL layer; tshark is the right tool here
- Risky or unknown binaries should be analysed in an isolated container, not the base WSL environment

## Image and Media

- Pillow
- OpenCV
- ImageMagick
- FFmpeg
- scikit-image if appropriate
- PyTorch optional
- Keras / TensorFlow optional

## Data Science and ML

Global CLI tools (install via pipx):
- jupyterlab (global launch point — but kernels are project-local)
- duckdb CLI (fast local analytical queries on CSV/Parquet/JSON without a server)
- sqlite-utils (CLI for SQLite — pairs with DuckDB for lightweight data work)
- csvkit (CSV inspection, filtering, and conversion from the command line — agents use this constantly)

Project-local only (never global pip install):
- Pandas
- NumPy
- SQLAlchemy
- Dask
- Matplotlib
- Seaborn
- Plotly
- Scikit-learn
- PyTorch (optional, project-local or containerized)
- Keras / TensorFlow (optional, containerized preferred)

Notes:
- Heavy ML frameworks (PyTorch, TensorFlow) must be project-local or containerized — never global
- GPU/CUDA builds are a separate optional layer; do not assume GPU availability

## Office and PDF Automation

- python-docx
- python-pptx
- openpyxl
- XlsxWriter
- pypdf
- pdfplumber
- reportlab
- pandoc
- LibreOffice CLI
- OCR tooling if appropriate

## Research and Web Automation

Project-local Python libraries:
- requests
- httpx
- BeautifulSoup
- lxml
- Scrapy
- Playwright (install browsers via `playwright install` per project)

Global CLI tools:
- markdownlint-cli (via npm — validates markdown docs; agents use this before committing docs)
- pandoc (document conversion — global install justified by broad cross-project use)

Notes:
- `Selenium` removed — Playwright covers all its use cases with a cleaner API and better async support
- Browser binaries for Playwright should be installed per-project, not globally

## Containers and Isolation

- Docker Desktop with WSL integration
- Docker CLI inside WSL
- Docker Compose
- Devcontainers
- Podman if Docker is not desired
- Optional isolated containers for reverse-engineering or risky tooling

## VS Code Integration

Recommend VS Code extensions for:

- WSL
- Python
- Pylance
- Jupyter
- C/C++
- CMake Tools
- C#
- .NET
- Rust
- Go
- Java
- Docker
- Dev Containers
- GitHub Pull Requests
- GitLens if appropriate
- Markdown
- YAML
- JSON
- ESLint
- Prettier
- Playwright
- Hex editor
- Remote development
- AI coding agents where applicable

---

# Required Design Principles

Follow these principles.

## 1. Do Not Install Everything Globally

Global installs should be limited to:

- Stable OS packages
- Durable CLI tools
- Language runtime managers
- System build tools
- Tooling required broadly across many projects
- Agent-discoverability tools
- Safe productivity utilities

Avoid installing large Python, ML, web, or experimental stacks globally by default.

## 2. Python Must Be Carefully Managed

Do not create one massive global Python environment.

Recommended approach should distinguish between:

- System Python managed by Debian
- `pipx` for global Python CLI tools
- `uv` for fast project-local Python dependency management
- `.venv` inside individual project folders
- Optional `poetry` only where it adds value
- Project-specific dependency files such as `pyproject.toml`, `requirements.txt`, or `uv.lock`

Future agents should be instructed not to run global `pip install` unless explicitly justified.

## 3. Prefer Project-Local Dependencies

Project-specific libraries and frameworks should usually live in project-local environments.

Examples:

- Flask apps should have their own `.venv`
- FastAPI apps should have their own `.venv`
- Scrapy projects should have their own `.venv`
- ML experiments should have their own `.venv` or container
- PyTorch/TensorFlow should generally be project-specific or optional
- Node projects should use local `node_modules`
- Java/.NET/Rust/Go projects should follow normal project-local conventions

## 4. Use Containers for Heavy or Risky Workloads

Prefer Docker/devcontainers or other isolation for:

- Heavy ML stacks
- CUDA/GPU experimentation
- Risky reverse-engineering work
- Conflicting system dependencies
- Version-sensitive frameworks
- Reproducible client/project environments

## 5. Avoid a Giant Fragile PATH

Do not solve discoverability by blindly appending many directories to PATH.

Instead, recommend:

- Standard install locations
- Minimal PATH additions
- Tool manifest
- Shell helper commands
- Documentation
- Version manager initialization
- VS Code workspace settings
- Project templates

## 6. Make the Environment Agent-Discoverable

The environment must include an explicit agent-discoverability strategy.

Future AI coding agents should be able to inspect the environment before installing anything new.

Recommend a concrete approach using some or all of the following:

- Machine-readable manifest
- Human-readable README
- `devtools-report` command
- `devtools-check` command
- `devtools-doctor` command
- Standard folder layout
- Shell profile hints
- VS Code workspace defaults
- Project template README
- Agent instruction file

The manifest should track:

- Installed tools
- Install method
- Version or detection command
- Global vs project-specific status
- Path or location
- Notes
- Last verified date if applicable
- Whether tool is optional, core, experimental, or isolated

Future agents should be explicitly instructed to check the manifest and run the reporting command before installing anything.

## 7. Bootstrap Must Be Idempotent

The bootstrap implementation should be designed so it can be safely re-run.

It should:

- Check whether tools are already installed before installing them
- Avoid duplicate installs
- Avoid overwriting user config without backup
- Log actions
- Generate or update the tool manifest
- Generate or update human-readable documentation
- Be modular by category
- Support optional install groups
- Avoid installing massive optional stacks by default

Recommended install groups may include:

- core
- languages
- python-cli
- web
- data
- docs
- image
- reverse
- containers
- vscode
- research
- optional-heavy
- optional-gpu

## 8. WSL Filesystem Guidance

Include guidance for Windows/WSL file boundaries.

Address:

- Why active project work should generally live under the Linux filesystem, such as `~/projects`
- When `/mnt/c` is acceptable
- How to organize shared files between Windows and WSL
- How VS Code Remote - WSL should open project folders
- Any performance or file-watcher considerations

## 9. GPU/CUDA Should Be Optional

Do not assume GPU/CUDA by default.

If relevant, provide an optional design path for:

- NVIDIA GPU support in WSL
- CUDA compatibility
- PyTorch GPU builds
- TensorFlow GPU support
- Containerized GPU workflows

But keep this separate from the base environment.

## 10. GUI Tools Should Be Evaluated Carefully

Some GUI-heavy tools may work through WSLg, but may be better installed on Windows depending on usability.

For tools such as:

- Ghidra
- ImHex
- Wireshark
- GUI hex editors
- Image tooling
- Browser automation tooling

Discuss whether they should be installed:

- Inside WSL
- On Windows
- Both
- In a container
- As optional tools

---

# Required Output 1: Architecture and Implementation Plan

Produce a plan with the following sections.

## 1. Executive Summary

Give a concise summary of the recommended approach.

## 2. Recommended Architecture

Explain the high-level architecture, including:

- Debian WSL base
- Global OS packages
- Language runtimes
- Version managers
- Project-local dependency model
- Containers/devcontainers
- Reverse-engineering isolation
- Document/image/data/research tooling
- VS Code integration
- Agent-discoverability layer

## 3. Recommended Folder Structure

Propose a folder layout such as:

```text
~/projects/
~/sandboxes/
~/tools/
~/tools/bin/
~/tools/manifests/
~/tools/bootstrap/
~/tools/templates/
~/tools/research/
~/tools/reverse/
~/tools/logs/
~/tools/docs/
~/.local/bin/