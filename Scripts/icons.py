#!/usr/bin/env python3

"""
Imports app icons into the project. It generates `.appiconset` assets using
the PNG icons at the provided path using an app icon JSON configuration.
"""

import argparse
import shutil
from pathlib import Path

_APP = Path(__file__).parent.parent  # script -> Scripts -> repo
ICONS = _APP / "Configuration" / "Icons"
ASSETS = _APP / "Assets" / "Assets.xcassets"
ICON_CONFIG = _APP / "Configuration" / "AppIcon.json"


def main(icons: Path, path: Path, config: Path) -> None:
    # validation
    if not icons.is_dir():
        raise FileNotFoundError({"Icons": icons})
    if not path.is_dir():
        raise NotADirectoryError({"Assets": path})
    if not config.is_file():
        raise FileNotFoundError({"Configuration": config})

    # create icons
    for icon in icons.glob("*.png"):
        create_icon(icon, path, config)


def create_icon(icon: Path, path: Path, config: Path) -> None:
    # create app icon
    print(f"Creating: {icon.name}")
    icon_set = (path / icon.stem).with_suffix(".appiconset")
    icon_set.mkdir(parents=True, exist_ok=True)

    # copy files
    shutil.copyfile(config, icon_set / "Contents.json")
    shutil.copyfile(icon, icon_set / "AppIcon.png")


# region: CLI


class ScriptFormatter(
    argparse.ArgumentDefaultsHelpFormatter,
    argparse.RawDescriptionHelpFormatter,
): ...


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description=(__doc__ or "").strip(), formatter_class=ScriptFormatter
    )

    parser.add_argument(
        "-a",
        "--assets",
        type=Path,
        help="the xcode assets path",
        default=ASSETS,
    )

    parser.add_argument(
        "-c",
        "--config",
        type=Path,
        help="the xcode icon configuration path",
        default=ICON_CONFIG,
    )

    parser.add_argument(
        "icons",
        type=Path,
        help="the icons path",
        default=ICONS,
    )

    args = parser.parse_args()
    main(args.icons, args.path, args.config)


# endregion
