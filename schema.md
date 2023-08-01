# Installation
If you would like to use docker, please read the docker subsection.

Bare-metal development dependencies:
- git (install with `pacman -S git`)
- openjdk 20 (install with `pacman -S jdk-openjdk`
- postgresql
Obs.: the code was test in the arch linux, and is not supposed to run on windows

Isolated development dependencies:
- docker (recent version)

The following command will create the directory structure


    ./install.sh


This shell scripts doesn't create by default following required directory:

- `.dynimport/` (the cache manager root directory)

Which should be created beforehand, with could be done with the following command:


    mkdir .dynimport


The following directories are creatd by default:
- `.libs/` (where the foreign dependecies will be installed (likely as a *.jar*)
- `.build/` (where the compiler will put the generated files)

## Docker

If you have **docker** and **docker-compose**, then the installation can  be done by typing the following command in the local repository directory:


    docker compose up -d


This should build and run the containers. Note that the docker service should be running, otherwise may raise a error.

You can create the database with the command provided in `create-database.sh`, and you can enter in the interactive shell inside the main container with the command provided in `enter.sh`. To compile ans run the program, you can then type in the main container's default workdir the following command


    ./run.sh


The container can be rebuilt with the folloeing container


    docker compose build


And to unistall the composed container, you can use the following command


    docker compose down


This was also tested inside the **cygwin** and **cmd.exe**. 
# Database
# Composite Types
Type: **Itempack**

Description: *Constains a collection of same item type*

Fields:
- `int amount`: the number of items in the pack
- `int itemid (FK)`: the identifier of the item or box
-------------------------------------------------------------------------------
Type: **Boxpack**

Description: *A selector-key is a random in the closed interval **0** and **1**.*
*A Boxpack matches the selector-key when it is in the closed interval `min_key` and `max_key`* 

Fields:
- `Itempack[] items`: a set of item that can be obtained by this
- `number min_key`: the minimum value of selector-key
- `number max_key`: the maximum value of selector-key
# Tables
Table: **Items**

Description: *Contains a item that can be exchanged, selled or obtained from a box*

Fields:
- `serial itemid (PK)`: the row identifier
- `varchar[32] name`: the name seen by the users
- `int units` - the number of existing units of this item
- `number min_prize`: the minimal prize that this item can be selled
- `number max_prize`: the maximum prize that this item can be selled
- `number prize`: the actual prize that this item can be selled
- `int typeid`: The supertype of item (1 = box, 0 = Collecionable)

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

Table: **Boxes**

Description: *Constain the box prototype*

Fields:
- `int itemid (FK)`: the itemid associated to the box (a box is also a item);
- `Boxpack option`:  the option associated with the box (can have multiple);
Constraint:
- `UNIQUE itemid, option;`
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
- `int balance`: the actual balance that the user holds
Optional Fields:
- `time login_expiration`: the time required to all sessions expires (required by json-web-token)
- `uuid live_token`: a security token (which needs to fecth the database to check)

Methods:
- `login(int userid, bytes(32) hash_pass)`: login and returns a `live_token` and/or json-web-token
- `rename(int userid, varchar(64) name)`: rename the user
- `update_image(int userid, varchar(128) profile_image)`: update the image used by the user
- `create(varchar(64) name, bytes(32) hash_pass, uuid pass_salt)`: create a new user (already logged)
- `update_pass(int userid, bytes(32) hash_pass, uuid pass_salt)`: updates the password

-------------------------------------------------------------------------------
Table: **Invetory**

Description: *Constains the item of the user*

Fields:
- `int userid (FK)`: the userid which the itempack is owned
- `Itempack single`: the items that are avaliable to the user
Constraint:
- `UNIQUE userid, single;`
-------------------------------------------------------------------------------
Table: **Exchage**

Description: *Exchange operation between users*

Fields:
- `serial exchangeid (PK)`: the identifier used in this transaction
- `int target (FK)`: the target of transaction (refers to a `userid`)
- `int sender (FK)`: the owner of transaction (refers to a `userid`)
- `Itempack[] send`: the items that can be sended to `target` by the `sender`
- `Itempack[] recv`: the items that can be sended to `sender` by the `target`
- `time expiration`: the maximum time before expiring and rejecting the transaction

# Database Algoritmhs

```
void Invetory.subtract_pack(User user, Itempack pack) uncommited {
	Itempack was = this.select_first(userid=user.userid, itemid=pack.itemid);
	if (was.amount > amount) {
		was.amount = was.amount - pack.amount;
	} else {
		abort "Insuficient Items";
	}
}
Itempack[] Boxes.get_reward(real key) nochange {
	Boxpack spec = this.options.select_first(min_key <= key and max_key >= key);
	return spec.items;
}

ITEM_TYPE = 0;
BOX_TYPE = 1;
void Items.create(itemname_t name, prize_t min_prize, prize_t max_prize, prize_t initial_prize) {
	this.name = name;
	this.min_prize = min_prize;
	this.max_prize = max_prize;
	this.prize = initial_prize;
	this.typeid = ITEM_TYPE;
	this.itemid.use_next();
	commit;
} 
void Invetory.sell(User user, Itempack pack) {
	Item kind = Items.select_first(itemid=pack.itemid);
	this.subtract_pack(user, pack);
	user.balance = user.balance + pack.amount * kind.prize;
	commit;
} 
void Invetory.open_box(User user, int itemid, real key) {
	Item kind = Items.select_first(itemid=itemid);
	if(kind.typeid != BOX_TYPE) {
		abort "Not is a box!";
	}
	Box to_open = Boxes.select_first(itemid=boxid);
	Itempack[] rewards = to_open.get_reward(key);
	for(Itempack reward in rewards) {
		this.add_itempack(reward);
	}
	commit;
}
```
