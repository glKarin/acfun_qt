/*
 * This file is from qt-components by Nokia.
 * Some functions is from ToolBarLayout.js.
 * */

/// Helper code that is needed by CircleMenuLayout.

var connectedItems = [];

// Find item in an array
function contains(container, obj) {
  for (var i = 0 ; i < container.length; i++) {
    if (container[i] == obj)
        return true;
  }
  return false
}

// Remove item from an array
function remove(container, obj)
{
    for (var i = 0 ; i < container.length ; i++ )
        if (container[i] == obj)
            container.splice(i,1);
}

// Helper function to give us the sender id on slots
// This is needed to remove connectens on a reparent
Function.prototype.bind = function() {
    var func = this;
    var thisObject = arguments[0];
    var args = Array.prototype.slice.call(arguments, 1);
    return function() {
        return func.apply(thisObject, args);
    }
}

// Called whenever a child is added or removed in the toolbar
function childrenChanged() {
    for (var i = 0; i < children.length; i++) {
        if (!contains(connectedItems, children[i])) {
            connectedItems.push(children[i]);
            children[i].visibleChanged.connect(layout);
            children[i].parentChanged.connect(cleanup.bind(children[i]));
        }
    }
}

// Disconnects signals connected by this layout
function cleanup() {
    remove(connectedItems, this);
    this.visibleChanged.disconnect(layout);
    this.parentChanged.disconnect(arguments.callee);
}

/* by karin */
// angle to radius
function ator(a)
{
 return(a / 180.0 * Math.PI);
}

// get x and y by angle
function get_coord(a, w)
{
	var r = ator(a);
	return({
		x: Math.cos(r) * w,
		y: Math.sin(r) * w
	});
}

function sqrt_len(a, b)
{
	return(Math.sqrt(a * a + b * b));
}

// Circle Menu Main layout function
function layout() {

    if (parent === null || width === 0)
        return;

    var i;
    var items = new Array();          // Keep track of visible items

    for (i = 0; i < children.length; i++) {
        if (children[i].visible) {
            items.push(children[i])

        }
    }

    if (items.length === 0)
        return;

		var w = subWidth / 2 + (width / 2 - subWidth / 2) / 2;

		for(i = 0; i < items.length; i++)
		{
			var a = 360.0 * (parseFloat(i) / parseFloat(items.length));
			var c = get_coord(a - 90.0, w/* - sqrt_len(items[i].width, items[i].height) / 2*/);
			if(auto_scale_items)
			{
				items[i].width = width / 2 - subWidth / 2;
				items[i].height = items[i].width;
			}
			items[i].x = c.x + width / 2 - items[i].width / 2;
			items[i].y = c.y + width / 2 - items[i].height / 2;
		}
}

