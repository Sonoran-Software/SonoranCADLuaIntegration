$(function () {
	window.addEventListener('message', function (event) {
		if (event.data.type == "light_event") {
            $.post("http://localhost:" + event.data.port + "/lighting", JSON.stringify({ state: event.data.event }))
		}
    });
});