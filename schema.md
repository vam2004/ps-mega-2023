# Installation
If you would like to use docker, please read the docker subsection.

Bare-metal development dependencies:
- git (install with `pacman -S git`)
- openjdk 20 (install with `pacman -S jdk-openjdk`
- postgresql

Obs.: the code was tested in the arch linux, and is not supposed to run on windows

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
Item Types (supertypes):
| identifier	| name		| description		|
| :----:	| :----:	| :----:		|
| 0		| Collectable	| Cannot be used	|
| 1		| Box		| Yields a random item	|

## Table: Items

*Contains a item that can be exchanged, selled or obtained from a box*

Fields:
| type		| name		| description		|
| :----:	| :----:	| :----:		|
| SERIAL	| itemid 	| row identifier	|
| VARCHAR(32)	| name		| item's name		|
| PRIZE_T	| min_prize	| sale's minimal prize	|
| PRIZE_T	| max_prize	| sale's maximum prize	|
| PRIZE_T	| prize		| sale's actual prize	|
| INT		| typeid	| supertype (item type)	|
| --- 		| (optional)	| ---			| 	
| VARCHAR(12)	| image		| item's image path 	|
| INT		| units		| reference counter	|

Constraints:
- `PRIMARY KEY (itemid)`

## Table: BoxSelectors

*Constains the box selector*

Fields:
| type		| name		| description		|
| :----:	| :----:	| :----:		|
| INT		| boxid		| itemid associated 	|
| REAL		| min_key 	| selector key begining	|
| REAL		| max_key 	| selector key ending	|

Constraints:
- `UNIQUE (boxid, min_key, max_key)`
- `FOREIGN KEY boxid REFERENCES Items(itemid) ON DELETE CASCADE` (boxid is the owner)

Observations:
- Multiple Boxpacks can be associated to a single box, which is done by using multiple pairs (`boxid`, `packid`)
- The item reference by `boxid` shall be a box

## Table: BoxOptions

*Constains the options associated to a box*

Fields:
| type 		| name 		| description 		|
| :----:	| :----:	| :----:		|
| INT		| boxid		| associated boxpack	|
| INT		| itemid	| associated itemid	|
| INT		| amount	| pack's amount		|

Constraints:
- `PRIMARY KEY (boxid, itemid)`
- `FOREIGN KEY boxid REFERENCES Items(itemid) ON DELETE CASCADE` (boxid is the owner)
- `FOREIGN KEY itemid REFERENCES Items(itemid) ON DELETE RESTRICT` (itemid is borrowed)


Observations:
- Multiple itempacks can be associated to a single box, which is done by using multiple pairs (`boxid`, `itemid`)
- The item reference by `boxid` shall be a box

## Table: Users

*Auth information* 

Fields:
| type		| name		| description			|
| :----:	| :----:	| :----:			|
| SERIAL	| userid	| the row id			|
| VARCHAR(64)	| name		| the name of the user		|
| BYTES(32)	| hash_pass	| password's hash (hmac-sha256)	|
| UUID		| pass_salt	| password hash's salt		|
| TIME		| last_login	| last attempt to login 	|
| INT		| tries		| login failures		|
| VARCHAR(12)	| profile_image	| profile's image path		|
| INT		| balance	| money avalible (balance)	|
| ---		| (optional)	| ---				|
| TIME		| expiration	| sessions's expiration time	|
| UUID		| live_token	| a nonfungible security token	|

Constraints:
- `PRIMARY KEY (userid)`
- `UNIQUE (name)`
- `UNIQUE hash_salt`

Observations:
- If json-web-token is used the field `expiration` shall be used.
- If a user is deleted, the field `userid` cannot safely be reused until the time in the field `expiration`

## Table: Invetory

*Constains the item of the user*

Fields:
| type		| name		| description		|
| :----:	| :----:	| :----:		|
| INT		| userid	| userid associated 	|
| INT		| itemid 	| itemid associated	|
| INT		| amount	| number of items	|

Constraints:
- `UNIQUE (userid, itemid)`
- `FOREIGN KEY (userid) REFERENCES Users(userid) ON DELETE CASCADE` (userid is the owner)
- `FOREIGN KEY (itemid) REFERENCES Items(itemid) ON DELETE RESTRICT` (itemid is borrowed)
Observations:
- Multiple items can be associated to a single user, which is done by using multiple pairs (`userid`, `itemid`)

## Table: Exchange

Description: *Exchange operation between users*

Fields:
| type		| name		| description			|
| :----:	| :----:	| :----:			|
| SERIAL	| exchangeid 	| identifier			|
| INT		| target 	| transaction's target userid	|
| INT		| owner 	| transaction's owner userid	|
| TIME		| expiration	| transaction's expiration 	|
| BOOLEAN	| active	| if it was confirmed		|

Constraints:
- `FOREIGN KEY (target) REFERENCES Users(userid) ON DELETE CASCADE` (target is the coowner)
- `FOREIGN KEY (sender) REFERENCES Users(userid) ON DELETE CASCADE` (sender is the coowner)
- `PRIMARY KEY (exchangeid)`

## Table: Sendpacks

*Constains a collection of packs that are sended during a transaction*

Fields:
| type 		| name 		| description 				|
| :----:	| :----:	| :----:				|
| INT		| sendid	| associated exchange transaction	|
| INT		| itemid	| associated itemid			|
| INT		| amount	| pack's amount				|

Constraints:
- `PRIMARY KEY (packid, itemid)`
- `FOREIGN KEY exchangeid REFERENCES exchange(exchangeid) ON DELETE CASCADE` (exchangeid is the owner)
- `FOREIGN KEY itemid REFERENCES Items(itemid) ON DELETE RESTRICT` (itemid is borrowed)

Observations:
- Multiple itempacks can be associated to a single boxpacks, which is done by using multiple pairs (`packid`, `itemid`)
- If `amount` is positive, then the associated item will be removed from `owner` and added to `target`
- If `amount` is negative, then the associated item will be removed from `target` and added to `owner`

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
