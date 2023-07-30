# ------------------------------------------------------------------
# this program executes a single action in the name of user and exit
# priviligied action requires reading a token from stdin
# ------------------------------------------------------------------
# USAGE: ./client.sh [operation] ..args
# ------------------------------------------------------------------
# [auth required] client.sh adduser $USERNAME $PASSWORD
# [auth required] client.sh remuser $USERNAME $PASSWORD
# [priviligied] client.sh invetory use $ITEMNAME $AMOUNT
# [priviligied] client.sh invetory buy $ITEMNAME $AMOUNT
# [priviligied] client.sh invetory sell $ITEMNAME $AMOUNT
# [priviligied] client.sh invetory list
# [priviligied] client.sh exchange start $TARGET [...$TARGET_ITEMNAME[i] $TARGET_AMOUNT[i]] -- [...$SEND_ITEMNAME[i] $SEND_AMOUNT[i]]
# [priviligied] client.sh exchange list
# -- list all pendiding exchange operation
# [priviligied] client.sh exchange accept $EXCHANGE_ID
# -- accept a exchange operaion
# [priviligied] client.sh exchange reject $EXCHAGE_ID
# -- reject a exchange operation
