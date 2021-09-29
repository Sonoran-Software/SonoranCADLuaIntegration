var isApiBeingChecked = false;

var myident = null;

var CallCache = {
	active: [],
	emergency: []
};

const KeyMaps = {
	previous: "",
	attach: "",
	detail: "",
	next: ""
}

var currCall = 0;

function toggleDetail() {
	$("#hudDetails")[0].style.display = ($("#hudDetails")[0].style.display === "" ? "none": "")
	// Not Yet Implemented!
	//$("#hudInput")[0].style.display = ($("#hudInput")[0].style.display === "" ? "none":"");
}

function setupHud() {
	$("#hudHeaderTime")[0].innerText = "Sonoran Mini-CAD";
}

function buttonShow(name, visible, label) {
	$(name)[0].style.color = (visible? '': 'rgb(70,70,70)');
	if (label) $(name)[0].innerText = label;
}

function setHotkeys(keyMap) {
	return;
	KeyMaps.previous = keyMap.previous,
	KeyMaps.attach = keyMap.attach,
	KeyMaps.detail = keyMap.detail,
	KeyMaps.next = keyMap.next
}

function refreshCall() {
	setupHud();

	let activeCall = true;

	if (CallCache.active.length === 0) activeCall = false;
	if (currCall > CallCache.active.length) currCall = 0;

	buttonShow("#btnPrevCall", false);
	buttonShow("#btnAttach", false, "Attach");
	buttonShow("#btnDetail", false, "Details");
	buttonShow("#btnNextCall", false);

	if (!activeCall) {
		$("#hudHeaderCalls")[0].innerText = '';
		$("#callCode")[0].innerText = 'No Active Calls';
		$("#callTitle")[0].innerText = 'There are currently no active calls';
		$("#callLocation")[0].innerText = '';
		$("#callDescription")[0].innerText = '';
		$("#callNotes")[0].innerHTML = '';
		$("#callUnits")[0].innerHTML = '';
		$("#hudDetails")[0].style.display = "none";
	} else {
		let currentCall = CallCache.active[currCall].dispatch;
		buttonShow("#btnAttach", true);
		if (isAttached(CallCache.active[currCall])) {
			buttonShow("#btnAttach", true, "Detach");
		} else {
			buttonShow("#btnAttach", true, "Attach");
		}
		buttonShow("#btnDetail", true);
		buttonShow("#btnPrevCall", hasPrevCall());
		buttonShow("#btnNextCall", hasNextCall());
		$("#hudHeaderCalls")[0].innerText = (currCall + 1) + "/" + CallCache.active.length;
		//$("#hudHeaderCalls")[0].innerText = "Call #" + currentCall.callId;
		$("#callCode")[0].innerText = currentCall.code;
		$("#callTitle")[0].innerText = currentCall.title;
		$("#callLocation")[0].innerText = (currentCall.postal != "" ? currentCall.postal + " ": "") + currentCall.address;
		$("#callDescription")[0].innerText = currentCall.description;
		$("#callNotes")[0].innerHTML = '';
		if (currentCall.notes) {
			for (var i = currentCall.notes.length-1; i>0; i--) {
				$("#callNotes")[0].innerHTML += '<span class="callnote">' + currentCall.notes[i] + '</span>';
			}
		}
		if (currentCall.units.length > 0) {
			$("#callUnits")[0].innerHTML = '';
			for (var i = 0; i<currentCall.units.length; i++) {
				//console.log(currentCall.units[i].status);
				let style = "unit";
				// Not Yet Implemented!
				// switch (currentCall.units[i].status) {
				// 	case 0:
				// 		style += " unavailable"
				// 		break;
				// 	case 1:
				// 		style += " busy"
				// 		break;
				// 	case 2:
				// 		style += " available"
				// 		break;
				// 	case 3:
				// 		style += " enroute"
				// 		break;
				// 	case 4:
				// 		style += " onscene"
				// 		break;
				// }
				$("#callUnits")[0].innerHTML += '<span class="' + style + '">' + currentCall.units[i].data.unitNum + '</span>'

			}
		} else {
			$("#callUnits")[0].innerHTML = '<span id="nounits">No units are attached to this call.</span>';
		}

	}
}

function prevCall() {
	if (currCall === 0) return;
	currCall -= 1;
	refreshCall();
}

function nextCall() {
	if (currCall === CallCache.active.length - 1) return;
	currCall += 1;
	refreshCall();
}

const hasPrevCall = () => {
	if (currCall === 0) return false;
	return true;
}

const hasNextCall = () => {
	if (currCall === CallCache.active.length - 1) return false;
	return true;
}

const isAttached = (call) => {
	return call.dispatch.idents.includes(myident);
}

function attach() {
	// Don't reattach to the same call.
	if (isAttached(CallCache.active[currCall])) {
		for (const call of CallCache.active) {
			// Detach from other calls.			
			if (isAttached(call)) {
				console.log("Detaching from call #" + call.dispatch.callId);
				$.post('https://tablet/DetachFromCall', JSON.stringify({callId: call.dispatch.callId}));
			}
		}
	} else {
		for (const call of CallCache.active) {
			// Detach from other calls.			
			if (isAttached(call)) {
				console.log("Detaching from call #" + call.dispatch.callId);
				$.post('https://tablet/DetachFromCall', JSON.stringify({callId: call.dispatch.callId}));
			}
		}
		// Attach to the current call.
		$.post('https://tablet/AttachToCall', JSON.stringify({callId: CallCache.active[currCall].dispatch.callId}));
	}
}

function moduleVisible(module, visible) {
	if (visible) {
		$("#"+ module + "Div").show();
	} else {
		$("#"+ module + "Div").hide();
	}
	$.post('https://tablet/VisibleEvent', JSON.stringify({ state: visible, module: module }));
}

function showHelp() {
	$.post('https://tablet/ShowHelp');
}

$(function () {
	window.addEventListener('message', function (event) {
		if (event.data.type == "display") {
			moduleVisible(event.data.module, event.data.enabled)
			if (event.data.apiCheck) {
				isApiBeingChecked = true;
				$("#check-api-data").show();
			}
			setHotkeys(event.data.keyMap);
		}
		else if (event.data.type == "command") {
			switch (event.data.key) {
				case 'prev':
					prevCall();
					break;
				case 'attach':
					attach();
					break;
				case 'detail':
					toggleDetail();
					break;
				case 'next':
					nextCall();
					break;
				default:
					break;
			}
		}
		else if (event.data.type == "callSync") {
			myident = event.data.ident;
			CallCache.active = [];
			for (const [key, call] of Object.entries(event.data.activeCalls)) {
				if (call != null) {
					if (call.dispatch_type) {
						if (call.dispatch_type != "CALL_CLOSE") CallCache.active.push(call);
					} else {
						CallCache.active.push(call);
					}
				}
			}
			CallCache.emergency = event.data.emergencyCalls;
			refreshCall();
		}
		else if (event.data.type == "setUrl") {
			if (event.data.module == "cad") {
				document.getElementById("cadFrame").src = event.data.url;
			}
		}
		else if (event.data.type == "regbar") {
			isApiBeingChecked = true;
			$("#check-api-data").show();
		}
		else if (event.data.type == "resize") {
			if (event.data.module == "cad") {
				document.getElementById('cadFrame').width = event.data.newWidth;
				document.getElementById('cadFrame').height = event.data.newHeight;
				document.getElementById('cadDiv').style.width = event.data.newWidth;
				document.getElementById('cadDiv').style.height = event.data.newHeight;
			} else if (event.data.module == "hud") {
				document.getElementById('hudFrame').width = event.data.newWidth;
				document.getElementById('hudFrame').height = event.data.newHeight;
				document.getElementById('hudDiv').style.width = event.data.newWidth;
				document.getElementById('hudDiv').style.height = event.data.newHeight;
			}
		}
		else if (event.data.type == "refresh") {
			let t = new Date().getTime();
			if (event.data.module == "cad") {
				let s = document.getElementById('cadFrame').src;
				document.getElementById('cadFrame').src = s + "&" + t.toString();
			}
		}
	});

	document.getElementById('cadFrame').onkeyup = function (data) {
		switch (data.which) {
			case 27:
				$.post('https://tablet/NUIFocusOff', JSON.stringify({}));
				break;
			default:
				break;
		}
	}

	document.onkeyup = function (data) {
		switch (data.which) {
			case 27:
				$.post('https://tablet/NUIFocusOff', JSON.stringify({}));
				break;	
			default:
				break;
		}
	};

	dragElement(document.getElementById("cadDiv"));
	dragElement(document.getElementById("hudDiv"));

	window.addEventListener("message", receiveMessage, false);
});

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

	let cadframe = document.getElementById("cadFrame");
	let frameorigin = new URL(cadframe.src).origin;

	if (isApiBeingChecked && event.origin == frameorigin) {
		$.post('https://tablet/SetAPIData', JSON.stringify(event.data));
		$("#check-api-data").hide();
	}
}

function addCallNote(call, data) {
	$.post('https://tablet/addCallNote', JSON.stringify(call), JSON.stringify(data));
}

function runApiCheck() {
	isApiBeingChecked = true;
	document.getElementById("cadFrame").src += '';
	$.post('https://tablet/runApiCheck');
	$("#check-api-data").hide();
}