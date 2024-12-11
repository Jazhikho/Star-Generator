# -*- mode: python ; coding: utf-8 -*-

block_cipher = None

a = Analysis(['gui.py'],
             pathex=['C:\\Users\\chris\\AppData\\Local\\Programs\\Python\\Python311\\star_gen'],
             binaries=[],
             datas=[('astro_methods.py', '.'),
                    ('roll.py', '.'),
                    ('space_and_stars.py', '.'),
                    ('star_data.json', '.'),
                    ('Stargen_Splash.png', '.'),
                    ('Stargen.png', '.')],
             hiddenimports=['pywin32-ctypes'],
             hookspath=[],
             runtime_hooks=[],
             excludes=[],
             win_no_prefer_redirects=False,
             win_private_assemblies=False,
             cipher=block_cipher,
             noarchive=False)

pyz = PYZ(a.pure, a.zipped_data,
          cipher=block_cipher)

exe = EXE(pyz,
          a.scripts,
          a.binaries,
          a.zipfiles,
          a.datas,
          [],
          name='StarGen',
          debug=False,
          bootloader_ignore_signals=False,
          strip=False,
          upx=True,
          upx_exclude=[],
          runtime_tmpdir=None,
          console=False,
          icon='Stargen.ico')
