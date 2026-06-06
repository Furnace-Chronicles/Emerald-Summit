/datum/book_entry/eggs
	name = "Eggs & Breakfast"
	category = "Instructions"

/datum/book_entry/eggs/inner_book_html(mob/user)
	return {"
	<div>
	<h2>Eggs & Breakfast</h2>
	A humble egg is the foundation of many a morning meal. Fry an egg on a pan or over a fire to make a <b>fried egg</b> - the starting point for the rest.<br><br>

	<h3>Building a Plate</h3>
	Each dish is made by adding the next cooked ingredient onto the last:<br>
	<ul>
	<li>Fried egg + another <b>fried egg</b> = twin fried eggs.</li>
	<li>Fried egg + cooked <b>sausage</b> = wiener egg.</li>
	<li>Twin eggs + <b>cheese</b> = an omelette.</li>
	<li>Twin eggs + fried <b>bacon</b> = bacon and eggs.</li>
	<li>Bacon and eggs + a <b>sausage</b> = the heartiest breakfast of all.</li>
	</ul>
	Richer plates take a little longer to assemble - but a well-fed town is a happy one.<br>
	</div>
	"}
