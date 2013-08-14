$ ->
  $("#get_stat").click (e) ->
    e.preventDefault()
    username = $("#username").val()
    if username isnt ""
      resetData()
      getConnections username
    false

  $(".get_stat").live "click", (e) ->
    e.preventDefault()
    username = $(this).html()
    $("#username").val username
    resetData()
    getConnections username
    false

  $("#show_other_followers, #show_other_following").live "click", (e) ->
    e.preventDefault()
    link = $(this)
    link.parent().parent().find("div").each ->
      $(this).show()
      link.hide()

    false

  SETTINGS = show_followers_limit: 3
  
  # FOR FUTURE VERSION
  countries = [
    name: "unknown" # PATTERN
    aliaes: []
    users: []
    cities: []
  ]
  PATTERNS = location: (str) ->
    splitted = str.split(",")
    return country: str.toLowerCase()  if splitted.length is 1
    city: splitted[0]
    country: $.trim(splitted[1].toLowerCase())

  resetData = ->
    countries = [
      name: "unknown" # PATTERN
      aliaes: []
      users: []
      cities: []
    ]

  getConnections = (username) ->
    getFollowers username
    getFollowing username

  getFollowers = (username) ->
    $.ajax
      url: "https://api.github.com/users/" + username + "/followers?per_page=100"
      type: "GET"
      contentType: "application/json"
      dataType: "jsonp"
      beforeSend: ->
        $("#followers").hide()
        $("#loading_followers").show()

      success: (d, s, xhr) ->
        $("#followers").show()
        $("#loading_followers").hide()
        users = d.data
        i = 0
        n = users.length
        output = ""
        full_user_info = null
        user = null
        $("#followers_count").html n
        while i < n
          user = users[i]
          display = (if i > SETTINGS.show_followers_limit - 1 then "none" else "block")
          output += "<div><a href='#' id='show_other_followers'>(show other)</a></div>"  if i is SETTINGS.show_followers_limit
          output += "<div style='display:" + display + "'><a href='#' class='get_stat'>" + user["login"] + "</a> from <span></span></div>"
          i++
        $("#followers").html output
        i = 0
        while i < n
          user = users[i]
          islastUser = i + 1 is n
          getUserInfoLocation user["url"], i + 1, user["login"], islastUser, "followers"
          i++


  getFollowing = (username) ->
    $.ajax
      url: "https://api.github.com/users/" + username + "/following?per_page=100"
      type: "GET"
      contentType: "application/json"
      dataType: "jsonp"
      beforeSend: ->
        $("#following").hide()
        $("#loading_following").show()

      success: (d, s, xhr) ->
        $("#following").show()
        $("#loading_following").hide()
        users = d.data
        i = 0
        n = users.length
        output = ""
        full_user_info = null
        user = null
        $("#following_count").html n
        while i < n
          user = users[i]
          display = (if i > SETTINGS.show_followers_limit - 1 then "none" else "block")
          output += "<div><a href='#' id='show_other_following'>(show other)</a></div>"  if i is SETTINGS.show_followers_limit
          output += "<div style='display:" + display + "'><a href='#' class='get_stat'>" + user["login"] + "</a> from <span></span></div>"
          i++
        $("#following").html output
        i = 0
        while i < n
          user = users[i]
          islastUser = i + 1 is n
          getUserInfoLocation user["url"], i + 1, user["login"], islastUser, "following"
          i++


  getUserInfoLocation = (url, i, login, islastUser, target) ->
    $.ajax
      url: url
      type: "GET"
      contentType: "application/json"
      dataType: "jsonp"
      success: (d, s, xhr) ->
        user_info = d.data
        loc = user_info["location"]
        loc_html = $("#" + target + " div:nth-child(" + i + ") span")
        location = (if loc is "" or not loc? or loc is "undefined" then "unknown" else loc)
        loc_html.html location
        j = undefined
        n = countries.length
        countryNotFound = true
        j = 0
        while j < n
          country = PATTERNS.location(location).country
          if countries[j].name is country
            countries[j].users.push login
            city = PATTERNS.location(location).city
            countries[j].cities.push city  if city isnt "undefined" and countries[j].cities.indexOf(city) isnt -1
            countryNotFound = false
            break
          j++
        
        # console.log('add new country', country)
        if countryNotFound
          _cities = []
          city = PATTERNS.location(location).city
          _cities.push city  unless city is "undefined"
          countries.push
            name: country
            aliaes: []
            users: [login]
            cities: _cities

        if islastUser
          stat = ""
          n = countries.length
          stat += "<b>" + countries.length + " countries</b>"
          stat += "<br/>"
          j = 0
          while j < n
            stat += "<div>"
            stat += countries[j].name + " got " + countries[j].users.length + " users"
            stat += "</div>"
            j++
          $("#total").html stat

    return
