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
unfold <input folder path> <input file name filter> <output folder path> <output file name template>
```

### Example

```bash
unfold INPUT_FOLDER/ "*.*" OUTPUT_FOLDER/ "{F2-}/{F1}_{S}{E}"
```

## Version

0.1

## Author

Eric Pelzer (ecstatic.coder@gmail.com).

## License

This project is licensed under the GNU General Public License version 3.

See the [LICENSE.md](LICENSE.md) file for details.
