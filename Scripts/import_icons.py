#!/usr/bin/env python3

"""
Imports app icons into the project. It generates `.appiconset` assets using
the icons at the provided path. The icons must be 1024x1024 PNG files.
"""

import argparse
import dataclasses
import shutil
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

ASSETS_PATH = Path(__file__).parent.parent / "Assets" / "Assets.xcassets"
ICON_PATH = Path(__file__).parent.parent / "Configuration" / "AppIcon.json"
ICON_SIZE = "1024x1024"


def main(icons: Path, path: Path):
    # validation
    if not icons.exists():
        raise FileNotFoundError(f"Folder does not exist: {icons}")
    if not icons.is_dir():
        raise NotADirectoryError(f"Path is not a directory: {icons}")
    if not path.is_dir() and path.exists():
        raise NotADirectoryError(f"Path is not a directory: {path}")
    path.mkdir(parents=True, exist_ok=True)

    # create app icons
    for icon in sorted(icons.iterdir()):
        if icon.suffix != ".png":
            print(f"Skipping {icon.name}...")
            continue
        if icon.name.startswith("."):
            print(f"Skipping {icon.name}...")
            continue
        print(f"Creating: {icon.name}")
        create_icon_set(icon, path)


def create_icon_set(icon: Path, path: Path):
    # create icon set
    icon_set = (path / icon.stem).with_suffix(".appiconset")
    icon_set.mkdir(parents=True, exist_ok=True)

    # copy icon and configuration
    shutil.copyfile(ICON_PATH, icon_set / "Contents.json")
    shutil.copyfile(icon, icon_set / "AppIcon.png")
    # icon.replace(icon_set / "AppIcon.png")


# region: Models


@dataclass
class Appearance:
    appearance: str
    value: str


@dataclass
class Icon:
    filename: str
    idiom: str
    platform: str
    size: str
    appearances: list[Appearance] | None = None

    @property
    def json(self) -> dict[str, Any]:
        contents = dataclasses.asdict(self)
        return {k: v for k, v in contents.items() if v is not None}


@dataclass
class AppIcon:
    icons: list[Icon]
    info: dict[str, Any] = field(
        default_factory=lambda: {"author": "xcode", "version": 1}
    )

    @property
    def json(self) -> dict[str, Any]:
        return {
            "images": [icon.json for icon in self.icons],
            "info": self.info,
        }


# endregion

# region: CLI


class ScriptFormatter(
    argparse.ArgumentDefaultsHelpFormatter,
    argparse.RawDescriptionHelpFormatter,
): ...


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description=(__doc__ or "").strip(), formatter_class=ScriptFormatter
    )

    parser.add_argument("icons", type=Path, help="the icons directory path")
    parser.add_argument(
        "-p",
        "--path",
        type=Path,
        help="xcode assets path",
        default=ASSETS_PATH,
    )

    args = parser.parse_args()
    main(args.icons, args.path)


# endregion
