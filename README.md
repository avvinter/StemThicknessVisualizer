# StemThicknessVisualizer
Processing tool to analyze the stem thickness of opentype font families (sans serif, not cursive only).

This tool was made to visualize how the stems of opentype font families grow.
The script uses fonttools ttx to generate an xml file and read the sidebearing and width values of the dotlessi.
It is assumed that the left and the right sidebearings are the same in the dotlessi.
The stem thickness results from two times the lsb substracted from the the width of the dotlessi.

you need:
- to have installed fonttools
- absolute path of your ttx application from fonttools
- a directory called "fonts" in the directory where the stemThickness Script is located
- subdirectories in the folder "fonts" - your font families you want to analyze. In those subdirectories you can only have .otf files.
  Other files will make trouble. StemThicknessVisualizer produces .ttx files of your opentype fonts, these files are the only files, next to the opentype itself that are allowed to be in the directory of your font family directory.
- to know what you are analyzing: only sans serif and not cursive fonts can be visualized.
