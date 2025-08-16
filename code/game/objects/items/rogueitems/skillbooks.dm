/obj/item/skillbook
	icon = 'icons/roguetown/items/books.dmi'
	desc = "A book to improve your skills."
	icon_state = "basic_book_0"
	var/open = FALSE
	var/iconval = 0

/obj/item/skillbook/Initialize()
	iconval = rand(0,9)//lets us randomize from all our books from books.dmi
	update_icon()
	..()

/obj/item/skillbook/update_icon()
	switch(iconval)
		if(0)
			icon_state = "basic_book_[open]"
		if(1)
			icon_state = "book_[open]"
		if(9)
			icon_state = "knowledge_[open]"
		else
			icon_state = "book[iconval]_[open]"

