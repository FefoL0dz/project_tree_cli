# project_tree_cli
Package to generate classes from the project tree or project tree from classes

# git\_tree\_cli

**A CLI tool and Dart library to**

* **Print** a Dart/Flutter project file tree (with ignore patterns)
* **Analyze** Dart import dependencies and detect circular references (export to Graphviz)
* **Scaffold** a project from a tree manifest (ASCII or YAML) with stub `.dart` classes

---

## 🔧 Installation

1. **Clone or include as a dependency**

   ```bash
   git clone https://github.com/yourusername/git_tree_cli.git
   cd git_tree_cli
   ```

2. **Activate globally** (optional)

   ```bash
   dart pub global activate --source path .
   ```

3. **Or add to your Dart/Flutter project**

   ```yaml
   dev_dependencies:
     git_tree_cli:
       path: ../path/to/git_tree_cli
   ```

4. **Install**

   ```bash
   dart pub get
   ```

---

## ⚙️ Configuration (`git_tree.yaml`)

Create a `git_tree.yaml` file in your project root to customize behavior:

```yaml
# Project root path (relative or absolute)
root: .

# Glob patterns (using package:glob) to ignore
ignore:
  - build/**
  - .dart_tool/**
  - **/*.g.dart

# Optional: where to save output instead of stdout
output: project-tree.txt

# Manifest for scaffold command
manifest: project-tree.txt       # or project-tree.yaml
format: ascii                    # 'ascii' or 'yaml'
indent: 2                        # spaces per level (for ASCII)

# Choose parsing for scaffold
# format: yaml
# indent: (ignored for YAML)
```

---

## 🚀 Usage

### 1. Print project tree

```bash
# to stdout:
dart run git_tree_cli tree

# save to a file:
dart run git_tree_cli tree > tree.txt
# or use config:
dart run git_tree_cli tree
```

### 2. Analyze dependencies

```bash
# print import graph:
dart run git_tree_cli deps

# export to DOT format:
# (set output: graph.dot in git_tree.yaml)
dart run git_tree_cli deps

# render with Graphviz:
dot -Tpng graph.dot -o deps.png
```

### 3. Scaffold from a manifest

```bash
# ensure `manifest` and `format` are set in git_tree.yaml
dart run git_tree_cli scaffold
```

* **ASCII manifest**: use plain-text tree dumps (`project-tree.txt`)
* **YAML manifest**: define a nested map in `project-tree.yaml`

Sample ASCII manifest (`project-tree.txt`):

```
lib
├── main.dart
└── src
    ├── models
    │   └── user.dart
    └── services
        └── api_service.dart
```

Sample YAML manifest (`project-tree.yaml`):

```yaml
lib:
  - main.dart
  src:
    models:
      - user.dart
    services:
      - api_service.dart
```

---

## 🗂️ Manifest Formats

| Format | File Ext.      | Description                                    |
| :----: | :------------- | :--------------------------------------------- |
|  ASCII | `.txt`         | Indented tree with box-drawing characters      |
|  YAML  | `.yaml`/`.yml` | Clean nested list/map of directories and files |

**ASCII parsing** strips `├──`, `│`, `└──` and computes depth from leading spaces.
**YAML parsing** uses `package:yaml` to build the tree.

---

## 💡 Examples

1. **Generate tree**

   ```bash
   dart run git_tree_cli tree > project-tree.txt
   ```
2. **Modify** `project-tree.txt` to add/remove files or directories.
3. **Scaffold** into an empty project:

   ```bash
   mkdir new_app && cd new_app
   flutter create .
   # copy project-tree.txt and git_tree.yaml here
   dart run git_tree_cli scaffold
   ```
4. **Verify** created files and stub classes in `lib/` and `test/`.

---

## 🛠️ Customization & Templates

* **Ignore patterns**: use glob syntax in `ignore:` to exclude paths.
* **Stub templates**: edit `_dartStubFor()` in `lib/src/scaffold_generator.dart` to change class templates (e.g. add imports, comments).
* **Output path**: `output:` in `git_tree.yaml` directs where CLI writes tree or graph.

---

## 🧪 Testing & CI

1. **Run tests**

   ```bash
   dart test
   ```
2. **Lint & format**

   ```bash
   dart format .
   dart analyze
   ```
3. **GitHub Actions**

   ```yaml
   name: Dart CI
   on: [push, pull_request]
   jobs:
     analyze:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v3
         - uses: dart-lang/setup-dart@v1
         - run: dart pub get
         - run: dart analyze
         - run: dart test
         - run: dart pub publish --dry-run
   ```

---

## 📦 Publishing

1. **Dry run**:

   ```bash
   dart pub publish --dry-run
   ```
2. **Publish**:

   ```bash
   dart pub publish
   ```

---

## 🤝 Contributing

Contributions are welcome! Please:

* Fork the repo
* Create a feature branch
* Write tests for new functionality
* Submit a pull request

---

## 📝 License

[MIT License](LICENSE)
