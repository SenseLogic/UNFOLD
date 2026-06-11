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
unfold [options] <input folder path> <input file name filter> <output folder path> <output file name template>
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
unfold --copy --overwrite INPUT_FOLDER/ "*.*" OUTPUT_FOLDER/ "{D2^}/{D1}_{S|remove_suffix _code|remove_suffix _screen}{E}"
```

## Properties

```
F : file path
D : directory path
Dn : nth upper directory name
Dn- : nth upper directory path
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

0.2

## Author

Eric Pelzer (ecstatic.coder@gmail.com).

## License

This project is licensed under the GNU General Public License version 3.

See the [LICENSE.md](LICENSE.md) file for details.
