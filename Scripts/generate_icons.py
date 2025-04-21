#!/usr/bin/env python3

"""
Generates the Xcode icon assets. It generates `.appiconset` folders with the
icons in the provided folder. The icons must be 1024x1024 PNG files.
"""

import argparse
import dataclasses
import json
import shutil
import subprocess
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

ASSETS_PATH = Path(__file__).parent.parent / "Assets" / "Assets.xcassets"
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
    # copy the icon
    icon_set = (path / icon.stem).with_suffix(".appiconset")
    icon_set.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(icon, icon_set / icon.name)
    # icon.replace(icon_set / icon.name)

    # create the contents.json file
    app_icon = create_icon(icon)
    contents = json.dumps(
        dataclasses.asdict(app_icon),
        indent=2,
        sort_keys=True,
    )
    (icon_set / "Contents.json").write_text(contents)


def create_icon(icon: Path) -> "AppIcon":
    watch_os_image = Icon(
        filename=icon.name,
        idiom="universal",
        platform="watchos",
        size=ICON_SIZE,
    )
    ios_image = Icon(
        filename=icon.name,
        idiom="universal",
        platform="ios",
        size=ICON_SIZE,
    )
    appearances = [
        Appearance(appearance="luminosity", value="dark"),
        Appearance(appearance="luminosity", value="tinted"),
    ]

    icons = [watch_os_image, ios_image]
    for appearance in appearances:
        app_icon = dataclasses.replace(ios_image)
        app_icon.appearances = [appearance]
        icons.append(app_icon)
    return AppIcon(icons=icons)


# region: CLI


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
    appearances: list[Appearance] = field(default_factory=lambda: [])


@dataclass
class AppIcon:
    icons: list[Icon]
    info: dict[str, Any] = field(
        default_factory=lambda: {"author": "xcode", "version": 1}
    )

    # def json(self) -> dict[str, Any]:
    #     contents = dataclasses.asdict(self)
    #     contents = {k: v for k, v in contents.items() if v is not None}


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

    parser.add_argument("icons", type=Path, help="the icons folder path")
    parser.add_argument(
        "-p",
        "--path",
        type=Path,
        help="xcode assets path",
        default=ASSETS_PATH,
    )

    # Parse arguments
    args = parser.parse_args()
    try:  # Install the application
        main(args.icons, args.path)

    # Handle user interrupts
    except KeyboardInterrupt:
        print("Aborted!")
        sys.exit(1)

    # Handle shell errors
    except subprocess.CalledProcessError as error:
        print(f"Error: {error}", file=sys.stderr)
        sys.exit(1)


# endregion
