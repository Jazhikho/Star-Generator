import sys
from cx_Freeze import setup, Executable

# Dependencies are automatically detected, but it might need fine-tuning.
build_exe_options = {
    "packages": ["tkinter", "PIL", "simpleeval", "numpy"],
    "include_files": [
        "astro_methods.py",
        "roll.py",
        "space_and_stars.py",
        "star_data.json",
        "Stargen_Splash.png",
        "Stargen.png",
    ],
    "excludes": ["matplotlib", "scipy"],
}

base = None
if sys.platform == "win32":
    base = "Win32GUI"

setup(
    name="StarGen",
    version="0.1",
    description="Star Generation Application",
    options={"build_exe": build_exe_options},
    executables=[Executable("gui.py", base=base, icon="Stargen.ico")]
)
