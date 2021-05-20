var isApiBeingChecked = false;

$(function () {
	window.addEventListener('message', function (event) {
		if (event.data.type == "enableui") {
			if (event.data.enable) {
				$("body").show();
				if (event.data.apiCheck) {
					isApiBeingChecked = true;
					$("#check-api-data").show();
				}
			}
			else {
				$("body").hide();
			}
		}
		else if (event.data.type == "backHome") {
			document.body.style.display = "block";

		}
		else if (event.data.type == "seturl") {
			document.getElementById("mdtFrame").src = event.data.url;
		}
		else if (event.data.type == "regbar") {
			isApiBeingChecked = true;
			$("#check-api-data").show();
		}
	});

	document.onkeyup = function (data) {
		if (data.which == 27) { // Escape key
			$.post('https://tablet/NUIFocusOff', JSON.stringify({}));

		}
	};

	dragElement(document.getElementById("tablet"));

	window.addEventListener("message", receiveMessage, false);
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

function receiveMessage(event) {

	let mdtframe = document.getElementById("mdtFrame");
	let frameorigin = new URL(mdtframe.src).origin;

	if (isApiBeingChecked && event.origin == frameorigin) {
		$.post('https://tablet/SetAPIData', JSON.stringify(event.data));
		$("#check-api-data").hide();
	}
}

function runApiCheck() {
	isApiBeingChecked = true;
	document.getElementById("mdtFrame").src += '';
	$.post('https://tablet/runApiCheck');
	$("#check-api-data").hide();
}