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

The testing function requires the **hello** database. Let's assume that the role
**postgres** have database creation priviliges, then you can type

	createdb hello -U postgres

This will create the database. The program may use the role **postgres** to connect to database,
if the program is unable to connect due insufficient priviligies, please create a issue.
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
# Composite Types
-------------------------------------------------------------------------------
Type: **Itempack**
Description: *Constains a collection of same item type*
Fields:
- `int amount`: the number of items in the pack
- `int itemid (FK)`: the identifier of the item or box
<!-- 
-------------------------------------------------------------------------------
 Type: **Boxpack**
Description: 
* A selector-key is a random in the closed interval **0** and **1**.*
* A Boxpack matches the selector-key when it is in the closed interval `min_key` and `max_key`* 
Fields:
- `Itempack[] items`: a set of item that can be obtained by this
- `number min_key`: the minimum value of selector-key
- `number max_key`: the maximum value of selector-key -->
# Tables
-------------------------------------------------------------------------------
Table: **Items**
Description: *Contains a item that can be exchanged, selled or obtained from a box*
Fields:
- `serial int itemid (PK)`: the row identifier
- `varchar[32] name`: the name seen by the users
- `int units` - the number of existing units of this item
- `number min_prize`: the minimal prize that this item can be selled
- `number max_prize`: the maximum prize that this item can be selled
- `number prize`: the actual prize that this item can be selled
- `int typeid`: The supertype of item (0 = box, 1 = Collecionable)
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
Table: **Invetory**
Description: *Constains the item of the user*
Fields:
- `int userid (FK-PK)`: the idetenfier of the user which the row is associeted with
- `Itempack[] avaliable`: the items that are avaliabre to the user
- `Itempack[][] transactions`: the items that are locked due a exchange transaction
- `int balance`: the actual balance that the user holds
-------------------------------------------------------------------------------
Table: **Boxes**
Description: *Constain the box prototype*
Fields:
- `int itemid (FK)`: contains a possibility associated to itemid (a box is also a item)
- `Itempack[] items`: the items that can be generated when matched this boxes
- `number min_key`
- `number max_key`
-------------------------------------------------------------------------------
Table: **User** (optional)
Description: *Auth information* 
Fields:
- `serial int userid (PK)`: the row id
- `varchar(64) name (UNIQUE)`: the name of the user
- `bytes(32) hash_pass`: the hashed password of the user using `pass_salt` as salt (hmac-sha256)
- `uuid pass_salt (UNIQUE)`: the salt used to generating the `hash_pass` (hmac-sha256)
- `time last_login`: the last attempt to login 
- `int tries`: the sequencial number of login failures
- `varchar(128) profile_image`: the image path
Optional Fields:
- `time login_expiration`: the time required to all sessions expires (required by json-web-token)
- `uuid live_token`: a security token (which needs to fecth the database to check)
Methods:
- `login(int userid, bytes(32) hash_pass)`: login and returns a `live_token` and/or json-web-token
- `rename(int userid, varchar(64) name)`: rename the user
- `update_image(int userid, varchar(128) profile_image)`: update the image used by the user
- `create(varchar(64) name, bytes(32) hash_pass, uuid pass_salt)`: create a new user (already logged)
- `update_pass(int userid, bytes(32) hash_pass, uuid pass_salt)`: updates the password
