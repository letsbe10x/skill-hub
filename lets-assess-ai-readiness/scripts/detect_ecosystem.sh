#!/usr/bin/env bash
# detect_ecosystem.sh — Detect repo ecosystem (language, package manager, build tool, test framework)
# Usage: ./detect_ecosystem.sh [repo_root]
# Outputs JSON with ecosystem detection results

set -euo pipefail

REPO_ROOT="${1:-.}"

# --- Language detection ---
LANGUAGE="unknown"
PACKAGE_MANAGER="unknown"
BUILD_TOOL="unknown"
TEST_FRAMEWORK="unknown"

# Python
if [ -f "$REPO_ROOT/pyproject.toml" ] || [ -f "$REPO_ROOT/setup.py" ] || [ -f "$REPO_ROOT/setup.cfg" ]; then
  LANGUAGE="python"
  if [ -f "$REPO_ROOT/uv.lock" ]; then
    PACKAGE_MANAGER="uv"
  elif [ -f "$REPO_ROOT/poetry.lock" ]; then
    PACKAGE_MANAGER="poetry"
  elif [ -f "$REPO_ROOT/Pipfile.lock" ]; then
    PACKAGE_MANAGER="pipenv"
  else
    PACKAGE_MANAGER="pip"
  fi
  if grep -q "pytest" "$REPO_ROOT/pyproject.toml" 2>/dev/null || [ -f "$REPO_ROOT/pytest.ini" ] || [ -f "$REPO_ROOT/conftest.py" ]; then
    TEST_FRAMEWORK="pytest"
  elif grep -q "unittest" "$REPO_ROOT/pyproject.toml" 2>/dev/null; then
    TEST_FRAMEWORK="unittest"
  fi
fi

# Node/TypeScript
if [ -f "$REPO_ROOT/package.json" ]; then
  [ "$LANGUAGE" = "unknown" ] && LANGUAGE="typescript"
  if [ -f "$REPO_ROOT/pnpm-lock.yaml" ]; then
    PACKAGE_MANAGER="pnpm"
  elif [ -f "$REPO_ROOT/yarn.lock" ]; then
    PACKAGE_MANAGER="yarn"
  elif [ -f "$REPO_ROOT/bun.lockb" ]; then
    PACKAGE_MANAGER="bun"
  else
    PACKAGE_MANAGER="npm"
  fi
  if grep -q "\"vitest\"" "$REPO_ROOT/package.json" 2>/dev/null; then
    TEST_FRAMEWORK="vitest"
  elif grep -q "\"jest\"" "$REPO_ROOT/package.json" 2>/dev/null; then
    TEST_FRAMEWORK="jest"
  elif grep -q "\"mocha\"" "$REPO_ROOT/package.json" 2>/dev/null; then
    TEST_FRAMEWORK="mocha"
  fi
  # Distinguish JS from TS
  if [ -f "$REPO_ROOT/tsconfig.json" ]; then
    LANGUAGE="typescript"
  elif [ "$LANGUAGE" != "python" ]; then
    LANGUAGE="javascript"
  fi
fi

# Go
if [ -f "$REPO_ROOT/go.mod" ]; then
  LANGUAGE="go"
  PACKAGE_MANAGER="go-modules"
  TEST_FRAMEWORK="go-test"
fi

# Rust
if [ -f "$REPO_ROOT/Cargo.toml" ]; then
  LANGUAGE="rust"
  PACKAGE_MANAGER="cargo"
  TEST_FRAMEWORK="cargo-test"
fi

# JVM
if [ -f "$REPO_ROOT/pom.xml" ]; then
  LANGUAGE="java"
  PACKAGE_MANAGER="maven"
  BUILD_TOOL="maven"
elif [ -f "$REPO_ROOT/build.gradle" ] || [ -f "$REPO_ROOT/build.gradle.kts" ]; then
  LANGUAGE="java"
  PACKAGE_MANAGER="gradle"
  BUILD_TOOL="gradle"
fi

# --- Build tool detection ---
if [ -f "$REPO_ROOT/Makefile" ]; then
  BUILD_TOOL="make"
elif [ "$BUILD_TOOL" = "unknown" ] && [ -f "$REPO_ROOT/package.json" ]; then
  BUILD_TOOL="npm-scripts"
fi

# --- Repo shape detection ---
SHAPE="service"
SERVICE_DIRS=$(find "$REPO_ROOT" -maxdepth 2 -name "go.mod" -o -name "package.json" -o -name "pyproject.toml" 2>/dev/null | wc -l | tr -d ' ')
if [ "$SERVICE_DIRS" -gt 3 ]; then
  SHAPE="monorepo"
elif [ -f "$REPO_ROOT/setup.py" ] || grep -q '"main"' "$REPO_ROOT/package.json" 2>/dev/null; then
  SHAPE="library"
fi
if grep -q "bin\|cli\|command" "$REPO_ROOT/pyproject.toml" 2>/dev/null || grep -q "\"bin\"" "$REPO_ROOT/package.json" 2>/dev/null; then
  SHAPE="tool"
fi

# --- CI detection ---
CI_SYSTEM="none"
if [ -d "$REPO_ROOT/.github/workflows" ]; then
  CI_SYSTEM="github-actions"
elif [ -f "$REPO_ROOT/.gitlab-ci.yml" ]; then
  CI_SYSTEM="gitlab-ci"
elif [ -f "$REPO_ROOT/Jenkinsfile" ]; then
  CI_SYSTEM="jenkins"
elif [ -f "$REPO_ROOT/.circleci/config.yml" ]; then
  CI_SYSTEM="circleci"
fi

# --- Lockfile detection ---
LOCKFILE="none"
for f in uv.lock poetry.lock Pipfile.lock package-lock.json pnpm-lock.yaml yarn.lock bun.lockb go.sum Cargo.lock; do
  if [ -f "$REPO_ROOT/$f" ]; then
    LOCKFILE="$f"
    break
  fi
done

# --- Formatter detection ---
FORMATTER="none"
for f in .prettierrc .prettierrc.json .prettierrc.yml prettier.config.js prettier.config.mjs biome.json; do
  if [ -f "$REPO_ROOT/$f" ]; then
    FORMATTER="prettier"
    break
  fi
done
if [ "$FORMATTER" = "none" ]; then
  if grep -q "black\|ruff.*format" "$REPO_ROOT/pyproject.toml" 2>/dev/null; then
    FORMATTER="black/ruff"
  elif [ -f "$REPO_ROOT/rustfmt.toml" ] || [ -f "$REPO_ROOT/.rustfmt.toml" ]; then
    FORMATTER="rustfmt"
  fi
fi

# --- Linter detection ---
LINTER="none"
if grep -q "ruff\|pylint\|flake8" "$REPO_ROOT/pyproject.toml" 2>/dev/null || [ -f "$REPO_ROOT/.flake8" ] || [ -f "$REPO_ROOT/ruff.toml" ]; then
  LINTER="ruff/pylint"
elif [ -f "$REPO_ROOT/.eslintrc.json" ] || [ -f "$REPO_ROOT/.eslintrc.js" ] || [ -f "$REPO_ROOT/eslint.config.js" ] || [ -f "$REPO_ROOT/eslint.config.mjs" ]; then
  LINTER="eslint"
elif [ -f "$REPO_ROOT/biome.json" ]; then
  LINTER="biome"
fi

cat <<EOF
{
  "language": "$LANGUAGE",
  "package_manager": "$PACKAGE_MANAGER",
  "build_tool": "$BUILD_TOOL",
  "test_framework": "$TEST_FRAMEWORK",
  "shape": "$SHAPE",
  "ci_system": "$CI_SYSTEM",
  "lockfile": "$LOCKFILE",
  "formatter": "$FORMATTER",
  "linter": "$LINTER"
}
EOF
