//this file needs heavy refactoring!
calls = [];
HTMLElement = typeof HTMLElement != "undefined" ? HTMLElement : Element;
last_id = 0;

HTMLElement.prototype.prepend = function(element) {
    if (this.firstChild) {
        return this.insertBefore(element, this.firstChild);
    } else {
        return this.appendChild(element);
    }
};

function processRequest(call) {
	$("#empty-box").hide();
    let old = calls.findIndex((x) => (x.id == call.id && x.waiting))

    if (call.waiting === false && old !== undefined && old !== -1) {
        calls[old] = call;
        document
            .getElementById(call.id)
            .replaceWith(getRequestHTML(call));
    } else {
        if (call.request != null) {
            calls.push(call);
            document.getElementById("requests_container")
                .prepend(getRequestHTML(call));
            applySearch();
        }
    }
}

function htmlToElement(html) {
    var template = document.createElement("template");
    html = html.trim(); // Never return a text node of whitespace as the result
    template.innerHTML = html;
    return template.content.firstChild;
}

function getRequestHTML(event) {
    request = event.request;
    response = event.response;
    id = event.id;
    if (baseURL != undefined && baseURL != "") {
        url = request.url.replace(baseURL, "<strong> {BASE_URL} </strong>/");
    } else {
        url = request.url
    }

    if (response == undefined) {
        status_code = request.status_code
        tookTime = "-"
        responseLength = "-"
        contentLength = "-"
    } else {
        status_code = response.status_code;
        tookTime = response.took_time;
        responseLength = parseInt(response.content_length);
        if (responseLength === undefined || responseLength < 0) responseLength = 0;
        contentLength =
            responseLength > 1000 ?
            parseInt(response.content_length / 1000) + " kilobytes" :
            responseLength + " bytes";
    }


    method = request.method;
    waiting = event.waiting;
    isSuccess = status_code >= 200 && status_code < 300;
    classname = waiting ? " pending-response " : (isSuccess ? "success" : "failure");
    success = waiting ? "" : (isSuccess ? "SUCCESS" : "FAILED");


    let html =
        (classname, id, requestId, URL, method, response, tookTime, currentTime) => `<div class="animatable request card ${classname}" id="${id}" request-id='${requestId}'> \
            <div class="url"> \
               <h3>${method}</h3> \
               <h2>${URL}</h2> \
            </div> \
            <div class="meta"> \
               <div class="response"> \
                   <span class="length">${response}</span> \
                   <span class="response_length"> \
                       <strong>${contentLength}</strong> \
                   </span> \
               </div> \
               <div class="date-container"> \
                   <span class="time"> \
                       <strong>${tookTime}</strong>ms \
                   </span> \
                   <span class="date">${currentTime}</span> \
                       <button class="copy" title="copy">copy</button> \
               </div> \
            </div> \
        </div>`
    return htmlToElement(html(classname, id, id, decodeURIComponent(url.replace(/\+/g, " ")), method, (waiting ? "Wait For Response" : success + " " + status_code), tookTime, getCurrentTime()));
}

function setupClickHandlers() {
    $(document).on("click", ".request", function(element) {
        var clickedId = this.id;
        call = calls.find(function(value) {
            return value["id"] === clickedId;
        });
        if (call === undefined) return;
        $(".request").removeClass("active");
        $(".selected-card")
            .html($(this).clone().prop("id", "selected_active_card"))
            .off("click")
            .off("mouseenter mouseleave")
            .off("hover")
            .unbind();

        $("#request_headers").html("");
        $("#response_headers").html("");
        $("#request_data").html("");
        $("#response_data").html("");
        $(".data-container ").show();


        call.request.headers.forEach(function(value) {
            $("#request_headers").append(
                createHighlightedRow(value["key"], value["value"])
            );
        });

        call.response.headers.forEach(function(value) {
            $("#response_headers").append(
                createHighlightedRow(value["key"], value["value"])
            );
        });

        url = call.request.url;
        urlWithoutParams = url;
        paramHTML = "";
        if (url.includes("?")) {
            urlWithoutParams = url.substring(0, url.indexOf("?"));
            params = url.substring(url.lastIndexOf("?"));
            urlParams = new URLSearchParams(params);
            urlParams.forEach(function(value, key) {
                paramHTML += createHighlightedRow(key, value);
            });
        }

        $("#request_url").html(urlWithoutParams);
        if (paramHTML.length > 1) {
            $("#request_params").html(paramHTML);
            $("#params_title").show();
        } else {
            $("#request_params").html("");
            $("#params_title").hide();
        }
        request_body =
            call.request.body != null ?
            formatBody(call.request.body) :
            "NO REQUEST BODY";
        response_body =
            call.response.body != null ? formatBody(call.response.body) : "NO RESPONSE BODY";
        $("#request_data").html(request_body);
        $("#response_data").html(response_body);
        document.querySelectorAll("code").forEach(function(codeBlock) {
            hljs.highlightBlock(codeBlock);
        });
        window.scrollTo({
            top: 0,
            behavior: "smooth"
        });
        $(".main-requests").addClass("card-hider");

        $(".selected-card-container").addClass("active");
        $(this).addClass("active");
    });
}

$(".previous").on("click", function() {
    $(".main-requests").removeClass("card-hider");
    $(".data-container").hide();
    $(".selected-card-container").removeClass("active");
});

$(".copy").on("click", function() {
    clipboard.writeText("hello world!");
});

function createHighlightedRow(key, value) {
    return (
        "<p> <span class='header_key'>" +
        key +
        " :</span><span class='header_value'>" +
        value +
        "</span></p>"
    );
}

function formatBody(body) {
    try {
        return (
            '<pre><code class="json">' +
            JSON.stringify(JSON.parse(body), null, 2) +
            "</code></pre>"
        );
    } catch (error) {
        return body;
    }
}

setupClickHandlers();

$(".tabgroup > div").hide();
$(".tabgroup > div:first-of-type").show();
$(".tabs a").click(function(e) {
    e.preventDefault();
    var $this = $(this),
        tabgroup = "#" + $this.parents(".tabs").data("tabgroup"),
        others = $this.closest("li").siblings().children("a"),
        target = $this.attr("href");
    others.removeClass("active");
    $this.addClass("active");
    $(tabgroup).children("div").hide();
    $(target).show();
});

function getCurrentTime() {
    var today = new Date();
    var date =
        today.getFullYear() +
        "-" +
        (today.getMonth() + 1) +
        "-" +
        today.getDate();
    var time =
        today.getHours() + ":" + today.getMinutes() + ":" + today.getSeconds();
    return date + " " + time;
}

/**
 WEBSOCKET
 **/
websocketAddress = undefined;
baseURL = undefined;

function connectToWebSocket() {
    if (websocketAddress === undefined) {
        $.get("config", function(data) {
            data = JSON.parse(data);
            websocketAddress = data["webSocketPort"];
            baseURL = data["baseURL"];
            updateBaseURL(baseURL);

            connectToWebSocket();
        });
        return;
    }
    if ("WebSocket" in window) {
        var wesocketAddress =
            "ws://" + location.hostname + ":" + websocketAddress + "/ws";

        // Let us open a web socket
        var ws = new WebSocket(wesocketAddress);

        ws.onopen = function() {
            // Web Socket is connected, send data using send()
            ws.send('{"connected": true}');
        };

        ws.onmessage = function(evt) {
            var data = evt.data;
            var received_msg = JSON.parse(data);
            processRequest(received_msg);

        };

        ws.onclose = function() {
            // websocket is closed.
            setTimeout(connectToWebSocket(), 3000);
        };
    } else {
        // The browser doesn't support WebSocket
        alert("WebSocket NOT supported by your Browser!");
    }
}

connectToWebSocket();

$("#clear-button").click(function() {
    $("#requests_container").html("");
    $(".data-container").hide();
	$("#empty-box").show();
});

$("#url_search").on("keyup", function() {
    applySearch();
});

function updateBaseURL(baseURL) {
    $("#base_url").html(baseURL);
}

function applySearch() {
    var value = $("#url_search").val().toLowerCase();
    $(".card").each(function() {
        if ($(this).find(".url h2").text().toLowerCase().search(value) > -1) {
            $(this).show();
        } else {
            $(this).hide();
        }
    });
}
