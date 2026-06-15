![](https://github.com/senselogic/UNFOLD/blob/master/LOGO/unfold.png)

# Unfold

Batch file renamer.

## Installation

Install the [DMD 2 compiler](https://dlang.org/download.html) (using the MinGW setup option on Windows).

Build the executable with the following command line :

```bash
dmd -m64 unfold.d
```

## Command line

```
unfold [options] <input folder path> <input file path filter> <output folder path> <output file name template>
```

## Options

```
--copy
--move
--overwrite
--preview
```

## Examples

```bash
unfold --copy --overwrite INPUT_FOLDER/ "DESKTOP/*.*|MOBILE/*.*" OUTPUT_FOLDER/ "{D1}{S|remove_suffix _code|remove_suffix _screen}_{D!|lower_case}{E}"
```

## Properties

```
F : file path
D : directory path
D~ : directory path without ending /
D! : directory name
Dn : nth upper directory path
Dn~ : nth upper directory path without ending /
Dn! : nth upper directory name
N : file name
S : file stem
E : file extension
```

## Filters

```
upper_case
lower_case
title_case
add_prefix added¨prefix
add_suffix added¨suffix
remove_prefix removed¨prefix
remove_suffix removed¨suffix
remove_text removed¨text
replace_prefix old¨text new¨text
replace_suffix old¨text new¨text
replace_text old¨text new¨text
```

## Version

0.3

## Author

Eric Pelzer (ecstatic.coder@gmail.com).

## License

This project is licensed under the GNU General Public License version 3.

See the [LICENSE.md](LICENSE.md) file for details.
