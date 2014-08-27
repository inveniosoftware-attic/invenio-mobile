CoffeeScript file structure
===========================

When writing a CoffeeScript file which is used by a single view (screen or tab), the following structure should be adhered to. Each section should have its own comment heading, like so:

	# Page elements #

Utility methods
---------------

This section should contain any methods which do not effect the state in any way (so, it shouldn't use variables, change the page state, etc.). They should be able to be extracted into a common file if they are needed elsewhere.

Page elements
-------------

Should contain only declarations of variables which act as a handle on page elements, or templates. It should not contain any function declarations. An example section might be as follows:

	$fooCount = $('#fooCount')
	$listOfFoos = $('#listOfFoos')

	fooTemplate = jinja.compile($('#fooTemplate').html())

Page methods
------------

The methods in this section should only be for displaying information, changing the page state, or acquiring data entered into the page by the user. They should not call methods in the Logic section, but can reference event handlers. Good examples for methods in this section would be `displayError` and `displayRecord` (from `record.coffee`) and the file list methods in `download.coffee`.

Logic
-----

The variables and methods in this section should perform the logic behind the page. They shouldn't really change the page directly, calling page methods instead. 

This section is a good place to declare state variables, including the `params` variable.

Event Handlers
--------------

As the name suggests, these methods should handle events such as mouse clicks.

On load
-------

This final section should contain the code which runs when the page (or maybe the settings) load.
