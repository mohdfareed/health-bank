#!/usr/bin/env python3

"""
Imports app icons into the project. It generates `.appiconset` assets using
the icons at the provided path using the provided app icon configuration.
"""

import argparse
import shutil
from pathlib import Path

_APP = Path(__file__).parent.parent  # script -> Scripts -> repo
ASSETS_PATH = _APP / "Assets" / "Assets.xcassets"
ICON_CONFIG_PATH = _APP / "Configuration" / "AppIcon.json"


def main(icons: Path, path: Path, config: Path) -> None:
    # validation
    if not icons.is_dir() or not icons.exists():
        raise NotADirectoryError(f"Path is not a directory: {icons}")
    if not path.is_dir() and path.exists():
        raise NotADirectoryError(f"Path is not a directory: {path}")
    path.mkdir(parents=True, exist_ok=True)

    # create app icons
    for icon in sorted(icons.iterdir()):
        if icon.suffix != ".png":
            print(f"Skipping {icon.name}...")
            continue

        # create icon set
        print(f"Creating: {icon.name}")
        icon_set = (path / icon.stem).with_suffix(".appiconset")
        icon_set.mkdir(parents=True, exist_ok=True)

        # copy files
        shutil.copyfile(config, icon_set / "Contents.json")
        shutil.copyfile(icon, icon_set / "AppIcon.png")
        # icon.replace(icon_set / "AppIcon.png")


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
        "-p",
        "--path",
        type=Path,
        help="xcode assets path",
        default=ASSETS_PATH,
    )
    parser.add_argument(
        "-c",
        "--config",
        type=Path,
        help="xcode app icon configuration path",
        default=ICON_CONFIG_PATH,
    )
    parser.add_argument("icons", type=Path, help="the icons directory path")

    args = parser.parse_args()
    main(args.icons, args.path, args.config)


# endregion
