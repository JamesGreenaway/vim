#!/usr/bin/env python3
"""Install this minimal Vim configuration in a-Shell's Documents folder."""
from datetime import datetime
from pathlib import Path
import shutil


SOURCE = Path(__file__).resolve().parent / 'vimrc'
TARGET = Path.home() / 'Documents' / '.vimrc'


def main():
    if not SOURCE.is_file():
        raise SystemExit(f'Missing Vim configuration: {SOURCE}')

    TARGET.parent.mkdir(parents=True, exist_ok=True)
    if TARGET.exists():
        stamp = datetime.now().strftime('%Y%m%d-%H%M%S')
        backup = TARGET.with_name(f'.vimrc.backup-{stamp}')
        shutil.copy2(TARGET, backup)
        print(f'Previous config backed up to: {backup}')

    shutil.copy2(SOURCE, TARGET)
    print(f'Installed: {TARGET}')
    print('Restart Vim to load the configuration.')


if __name__ == '__main__':
    main()
