// this method will proxy your custom method with the original one
function proxy(context, method, message) { 
  return function() {
    method.apply(context, [message].concat(Array.prototype.slice.apply(arguments)))
  }
}

// let's do the actual proxying over originals
console.log = proxy(console, console.log, 'Log:')
console.error = proxy(console, console.error, 'Error:')
console.warn = proxy(console, console.warn, 'Warning:')

$(function() {
    window.addEventListener('message', function(event) {
        if (event.data.type == "enableui") {
            if (event.data.enable) {
              $("body").show();
            }
            else{
              $("body").hide();
            }
		} 
		else if (event.data.type == "backHome") {
            document.body.style.display = "block";
		
    }
    else if (event.data.type == "seturl") {
      document.getElementById("mdtFrame").src = event.data.url;
    }
    });

    document.onkeyup = function (data) {
      if (data.which == 27) { // Escape key
          $.post('http://tablet/NUIFocusOff', JSON.stringify({}));
          
      }
    }; 
    
    dragElement(document.getElementById("tablet"));
  });

	function backHome() {
		document.body.style.display = "block";
	};
function dragElement(elmnt) {
  var pos1 = 0, pos2 = 0, pos3 = 0, pos4 = 0;
  if (document.getElementById(elmnt.id + "header")) {
    // if present, the header is where you move the DIV from:
    document.getElementById(elmnt.id + "header").onmousedown = dragMouseDown;
  } else {
    // otherwise, move the DIV from anywhere inside the DIV: 
    elmnt.onmousedown = dragMouseDown;
  }

  function dragMouseDown(e) {
    e = e || window.event;
    e.preventDefault();
    // get the mouse cursor position at startup:
    pos3 = e.clientX;
    pos4 = e.clientY;
    document.onmouseup = closeDragElement;
    // call a function whenever the cursor moves:
    document.onmousemove = elementDrag;
  }

  function elementDrag(e) {
    e = e || window.event;
    e.preventDefault();
    // calculate the new cursor position:
    pos1 = pos3 - e.clientX;
    pos2 = pos4 - e.clientY;
    pos3 = e.clientX;
    pos4 = e.clientY;
    // set the element's new position:
    elmnt.style.top = (elmnt.offsetTop - pos2) + "px";
    elmnt.style.left = (elmnt.offsetLeft - pos1) + "px";
  }

  function closeDragElement() {
    // stop moving when mouse button is released:
    document.onmouseup = null;
    document.onmousemove = null;
  }
}
	