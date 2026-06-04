/datum/book_entry/plated_dishes
	name = "Plated Dishes"
	category = "Instructions"

/datum/book_entry/plated_dishes/inner_book_html(mob/user)
	return {"
	<div>
	<h2>Plated Dishes</h2>
	The grandest meals are not cooked from scratch in one step - they are assembled by building upon a finished base.<br><br>

	<h3>How It Works</h3>
	<ul>
	<li>Start with a <b>cooked base</b> - a fried steak, a fried egg, a cooked fillet.</li>
	<li>Add the <b>ingredient</b> a recipe calls for, and the base transforms into the next dish.</li>
	<li>Some dishes are built in <b>several steps</b>, each adding another ingredient onto the last result.</li>
	<li>An ingredient may be an <b>item</b> or a <b>reagent</b> - a pinch of pepper, a splash of ale - so keep a varied pantry.</li>
	</ul>

	<h3>Meat</h3>
	<ul>
	<li>Fried steak + <b>pepper</b> = pepper steak.</li>
	<li>Fried steak + fried <b>onion</b> = onion steak.</li>
	<li>Fried steak + baked <b>carrot</b> = carrot steak.</li>
	</ul>

	<h3>Fish & Eggs</h3>
	<ul>
	<li>Cooked sole + <b>butter</b> = buttered sole; cooked cod + <b>ale</b> = ale cod.</li>
	<li>Fried eggs build into twin eggs, omelettes, wiener eggs, and bacon-and-eggs.</li>
	</ul>
	A clever cook learns these by heart - the same fried steak can become a dozen different suppers.<br>
	</div>
	"}
