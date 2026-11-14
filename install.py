#!/usr/bin/env python3
"""Install pinned Vim packages in a-Shell without git or subprocesses."""
import argparse
import datetime
import io
import json
from pathlib import Path, PurePosixPath
import shutil
import tempfile
import urllib.request
import zipfile

SOURCE = Path(__file__).resolve().parent
OBSOLETE_MANAGED_PACKAGES = {
    'zenbones.nvim': '8304d8df9b823ff11e103afa62f38c39f534abe6',
}

def install(target):
    target = target.expanduser().resolve()
    target.mkdir(parents=True, exist_ok=True)
    opt = target / '.vim/pack/ashell/opt'
    opt.mkdir(parents=True, exist_ok=True)
    plugins = json.loads((SOURCE / 'plugins.lock.json').read_text())
    for name, revision in OBSOLETE_MANAGED_PACKAGES.items():
        destination = opt / name
        marker = destination / '.ashell-revision'
        if marker.exists() and marker.read_text().strip() == revision:
            shutil.rmtree(destination)
            print('Removed obsolete theme:', name, flush=True)
    # Download and validate every package before changing the active config.
    with tempfile.TemporaryDirectory(dir=target) as temp:
        staging = Path(temp)
        for plugin in plugins:
            name = plugin['repo'].split('/')[-1]
            destination = opt / name
            marker = destination / '.ashell-revision'
            if marker.exists() and marker.read_text().strip() == plugin['commit']:
                print('Already installed:', name, flush=True)
                continue
            if destination.exists():
                raise RuntimeError(f'Unmanaged/different package at {destination}; move it aside before installing.')
            print('Downloading:', plugin['repo'], flush=True)
            url = f"https://codeload.github.com/{plugin['repo']}/zip/{plugin['commit']}"
            with urllib.request.urlopen(url, timeout=60) as response:
                data = response.read()
            package = staging / name
            package.mkdir()
            with zipfile.ZipFile(io.BytesIO(data)) as archive:
                for member in archive.infolist():
                    parts = PurePosixPath(member.filename).parts
                    if not parts or member.filename.startswith('/') or '..' in parts:
                        raise ValueError('Unsafe archive path')
                    if len(parts) == 1:
                        continue
                    out = package.joinpath(*parts[1:])
                    if member.is_dir():
                        out.mkdir(parents=True, exist_ok=True)
                    else:
                        out.parent.mkdir(parents=True, exist_ok=True)
                        out.write_bytes(archive.read(member))
            (package / '.ashell-revision').write_text(plugin['commit'] + '\n')
        for package in staging.iterdir():
            shutil.move(str(package), str(opt / package.name))
    rc = target / '.vimrc'
    if rc.exists():
        suffix = datetime.datetime.now().strftime('%Y%m%d-%H%M%S-%f')
        backup = target / ('.vimrc.before-ashell-' + suffix)
        shutil.copy2(rc, backup)
        print('Previous config:', backup)
    temp_rc = target / '.vimrc.ashell-new'
    shutil.copy2(SOURCE / 'vimrc', temp_rc)
    temp_rc.replace(rc)
    print('Installed:', rc)
    print('Restart Vim, then run :helptags ALL and :AshellHealth')

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--target', type=Path, default=Path.home() / 'Documents')
    args = parser.parse_args()
    install(args.target)
