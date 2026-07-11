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
	<li>Twin eggs + <b>cheese</b> = a valerian omelette.</li>
	<li>Twin eggs + fried <b>bacon</b> = bacon and eggs.</li>
	<li>Wiener egg + fried <b>bacon</b> = wiener egg with bacon (or bacon and eggs + <b>sausage</b>).</li>
	<li>Wiener egg with bacon + <b>toast</b> = the heartiest Hammerholdian breakfast of all.</li>
	</ul>

	<h3>Stuffed Eggs</h3>
	<ul>
	<li>Raw egg + <b>cheese wedge</b> = stuffed egg (raw). Cook or fry it to finish.</li>
	</ul>

	<h3>Omelettes</h3>
	A different path from fried eggs - these are beaten raw, then cooked:<br>
	<ul>
	<li>Raw egg + raw <b>egg</b> = raw omelette.</li>
	<li>Raw omelette + sliced <b>onion</b> = raw onion omelette.</li>
	<li>Raw onion omelette + sliced <b>cucumber</b> or <b>cabbage</b> = raw vegetable omelette.</li>
	<li>Raw omelette + <b>mince</b> = raw meat omelette.</li>
	<li>Fry the raw omelette on a pan to finish it. Omelettes can be sliced to share.</li>
	</ul>

	<h3>Toast</h3>
	<ul>
	<li>Toast + <b>butter</b> = buttered toast.</li>
	<li>Toast + fried <b>egg</b> = egg toast.</li>
	<li>Toast + <b>jamtallow</b> or <b>marmalade</b> = spread toast.</li>
	<li>Toast + sliced <b>ham</b> = ham bread.</li>
	</ul>
	</div>
	"}
