#!/usr/bin/env python3
"""Generates `.appiconset` assets."""

import argparse
import shutil
from pathlib import Path

_APP = Path(__file__).parent.parent  # script -> Scripts -> repo

ICONS = _APP / "Assets" / "Icons"
ASSETS = _APP / "Assets" / "Generated.xcassets"

ICON_CONFIG = _APP / "Configuration" / "Icon.json"
SYMBOL_CONFIG = _APP / "Configuration" / "Symbol.json"


def main() -> None:
    shutil.rmtree(ASSETS, ignore_errors=True)

    # create app icons
    for icon in sorted(ICONS.glob("*.png")):
        print(f"Creating icon: {icon.name}")
        asset = (ASSETS / icon.stem).with_suffix(".appiconset")
        create_asset(asset, icon, ICON_CONFIG)

    # create app symbols
    for symbol in sorted(ICONS.glob("*.svg")):
        print(f"Creating symbol: {symbol.name}")
        asset = (ASSETS / symbol.stem).with_suffix(".symbolset")
        create_asset(asset, symbol, SYMBOL_CONFIG)


def create_asset(path: Path, asset: Path, config: Path) -> None:
    path.mkdir(parents=True, exist_ok=True)
    asset_path = path / f"AppIcon{asset.suffix}"
    config_path = path / f"Contents.json"

    asset_path.unlink(missing_ok=True)
    asset_path.symlink_to(asset)
    config_path.unlink(missing_ok=True)
    config_path.symlink_to(config)


# region: CLI


class ScriptFormatter(
    argparse.ArgumentDefaultsHelpFormatter,
    argparse.RawDescriptionHelpFormatter,
): ...


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description=(__doc__ or "").strip(), formatter_class=ScriptFormatter
    )
    args = parser.parse_args()
    main()


# endregion
