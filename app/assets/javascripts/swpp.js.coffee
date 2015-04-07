@Init = () ->
    $('#status').text("Please enter your credentials below")

@Login = (username, cnt) -> 
    $('#container_logined').show()
    $('#container_login').hide()
    $('#status_login').text("Welcome " + username + " You have logged in " + cnt + " times.");

@Logout = () ->
    $('#container_logined').hide()
    $('#container_login').show()
    $.ajax
        type: "post"
        url: "/logout"
    Init()

@JSONPROCESSOR = (data, status) ->
    if (data["error_code"] == -1)
        $("#status").text("The user name should be 5~20 characters long. Please try again.")
    else if (data["error_code"] == -2)
        $("#status").text("The password should be 8~20 characters long. Please try again.");
    else if (data["error_code"] == -3)
        $("#status").text("This user name already exists. Please try again.");
    else if (data["error_code"] == -4)
        $("#status").text("Invalid username and password combination. Please try again.");
    else
        Login(data["user_name"], data["login_count"]);

$ ->
    Init()
    $('#logout').click ->
        Logout()

$ ->
    $('#login').click ->
        $.ajax
            type: "post"
            url: "/login"
            dataType: "json"
            data: { username: $("#username").val(), password: $("#password").val() }
            success: JSONPROCESSOR
    $('#signup').click ->
        $.ajax
            type: "post"
            url: "/signup"
            dataType: "json"
            data: { username: $("#username").val(), password: $("#password").val() }
            success: JSONPROCESSOR
