#!/usr/bin/env python3
from __future__ import annotations

import argparse
import shutil
from pathlib import Path


def _copy_file(src: Path, dst: Path) -> None:
    dst.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(src, dst)


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Scaffold design-system/MASTER.md + optional page override from skill assets."
    )
    parser.add_argument(
        "--repo-root",
        default=".",
        help="Target repository root where design-system/ will be created (default: .).",
    )
    parser.add_argument(
        "--page",
        default="",
        help="Optional page/flow name. Creates design-system/pages/<page>.md.",
    )
    args = parser.parse_args()

    skill_root = Path(__file__).resolve().parent.parent
    assets_root = skill_root / "assets" / "design-system"

    master_src = assets_root / "MASTER.md"
    page_src = assets_root / "pages" / "PAGE.md"

    if not master_src.is_file():
        raise FileNotFoundError(f"Missing asset template: {master_src}")
    if not page_src.is_file():
        raise FileNotFoundError(f"Missing asset template: {page_src}")

    repo_root = Path(args.repo_root).resolve()
    ds_root = repo_root / "design-system"

    master_dst = ds_root / "MASTER.md"
    _copy_file(master_src, master_dst)

    if args.page:
        page_slug = args.page.strip().lower().replace(" ", "-")
        page_dst = ds_root / "pages" / f"{page_slug}.md"
        _copy_file(page_src, page_dst)

    print(f"Created: {master_dst}")
    if args.page:
        print(f"Created: {page_dst}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
