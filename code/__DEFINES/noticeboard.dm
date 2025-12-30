/// Global list to track all current viewers of noticeboards
GLOBAL_LIST_EMPTY(board_viewers)
/// Global list of all noticeboard posts
GLOBAL_LIST_EMPTY(noticeboard_posts)
/// Global list of premium noticeboard posts
GLOBAL_LIST_EMPTY(premium_noticeboardposts)
/// Global list of sellsword noticeboard posts
GLOBAL_LIST_EMPTY(sellsword_noticeboardposts)
/// Global list of merc DM enquiries. Exists to prevent answering a DM more than once
GLOBAL_LIST_EMPTY(merc_dm_enquiries)

#define NOTICEBOARD_CAT_POSTINGS "Postings"
#define NOTICEBOARD_CAT_PREMIUM "Premium Postings"
#define NOTICEBOARD_CAT_SELLSWORDS "Sellswords"
#define NOTICEBOARD_CAT_SCOUT "Scout Report"

/// Mercenary status for contract system - available, can be DM'd by others
#define MERC_STATUS_AVAILABLE "Available"
/// Mercenary status for contract system - is currently busy, cannot be DM'd by others, broadcasts to all mercs will still reach them
#define MERC_STATUS_CONTRACTED "Contracted"
/// Mercenary status for contract system - cannot be DM'd by others, does not receive broadcast messages
#define MERC_STATUS_DND "Do Not Disturb"
/// Lifespan of mercenary response links
#define MERC_DM_RESPONSE_LIFESPAN (2 MINUTES)
#define NOTICEBOARD_ALL_CATEGORIES list(NOTICEBOARD_CAT_POSTINGS, NOTICEBOARD_CAT_PREMIUM, NOTICEBOARD_CAT_SELLSWORDS, NOTICEBOARD_CAT_SCOUT)
