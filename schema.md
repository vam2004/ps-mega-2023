# Installation
Development dependencies:
- git (install with `pacman -S git`)
- openjdk 20 (install with `pacman -S jdk-openjdk`
- python 3 (should be installed by default)
The following command should create the directory structure, init the cache manager and
download the dependecies

	python -B manage.py install

This will create by default the following directories:
- `.libs` (where the foreign dependecies will be installed (likely as a *.jar*)
- `.build` (where the compiler will put the generated files)
- `~/.dynimport/` (the cache manager root directory)

# The dependencie cache manager
The algorithm used by cache manager can be simplied as:
```js
function get_permanent_path(root_directory, urlhash) {
	let path = path_join([root_directory, "cache", urlhash]);
	let file = path_join(permanent_path, "file.bin");
	let info = path_join(permanent_path, "lock.txt");
	return { path, file, info };
}
async function force_download(root_directory, url, urlhash, checksum) {
	// cache miss
	let temporary_file = path_join([root_directory, "downloads", urlhash]);
	temporary_file.add_extension(".bin");
	await download_into(temporary_file, url);
	if(validate_checksum(temporary_file, checksum){
		let permanent = get_permanent_path(urlhash);
		await move_file(temporary_file, permanent.file);
		await dump_checksum(permanent.info, checksum);
		await database.update_checksum(urlhash, checksum);
		return permanent.file;
	} else {
		throw CorruptedDownload(temporary_file, checksum);
	}
}
async function download(root_directory, url, checksum) {
	let urlhash = await hash_the_url(url);
	let info = await database.get_info(urlhash);
	if(is_null(info)){
		file = await force_download(root_directory, url, urlhash, checksum); 
		return {file, fresh: true};
	} else {
		let permanent = get_permanent_path(urlhash);
		if(validate_cached_info(info, permanent.info){
			return {file: permanent.file, fresh: false};
		} else {
			throw ConflictedUrlhash(urlhash);
		}
	}
}
```
 
# Database
-------------------------------------------------------------------------------
Table: **Items**
Description: *Contains a item that can be exchanged, selled or obtained from a box*
Fields:
- `int uuid`: a universal unique identifier used to cross referencing
- `varchar[32] name`: the name seen by the users
- `int units` - the number of existing units of this item
- `number min_prize`: the minimal prize that this item can be selled
- `number max_prize`: the maximum prize that this item can be selled
- `number prize`: the actual prize that this item can be selled
Optional Fields:
- `varchar image`: the path to the item image
Local Methods:
- `add_item(varchar[32] name, number min_prize, number max_prize);`: add a item to the database
- `set_prize(int uuid, number prize);`: defines a new `prize`
Foreign Interactions:
- get the `prize` when selling a item (from method `user.sell`)
- decrement the `units` of when selling a item (from method `user.sell`)
- increment the `units` when a box is open (from method `user.open_box`)
-------------------------------------------------------------------------------
Table: