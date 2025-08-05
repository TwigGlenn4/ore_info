# v1.1.0
### Additions
* New UI with better formatting and the selected ore's texture
* Reformatted depth and rarity information: `[y_min, y_max]: rarity%  (shape)`
* Added main page which explains on depth and rarity information
* Add buttons in `sfinv` and `inventory_plus`
* New scaling for better readability on smaller screens. Now easily readable in Luanti my phone!
### Fixes
* Fixed bad conditional possibly selecting the wrong ore in depth and rarity info
* Fixed rarity calculation using the size of a cluster (space the ores would be spread in) instead of the number of ores in a cluster.

# v1.2.0
### Additions
* Added support for Extended Tooltips: Base `tt_base`, Everness `everness`, Etheral NG `ethereal`, Nether (PilzAdam) `nether`, and more - Implemented by [adikalon](https://github.com/adikalon)
### Fixes
* No longer crashes when previewing animated nodes - Fixed by [adikalon](https://github.com/adikalon)
* There is not enough data in the Tile Animation Defintion to build an animated image in the menu, so the full texture is just squished.

# v1.3.0
### Additions
* Show which nodes an ore generates in. 
* Show thicknesss of stratum type.
### Fixes
* Update references to Minetest to now say Luanti.
* Update `minetest` code namespace to `core`.
* Avoid crashing if ore definition is missing `y_min`, `y_max`, or `wherein` parameters.