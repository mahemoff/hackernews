###############################################################################
# LOAD STORIES
###############################################################################

storiesTemplate = _.template($("#storiesTemplate").html())
show = () ->
  $.getJSON "http://api.ihackernews.com/page?format=jsonp&callback=?",
    (storyInfo) -> $("#stories").fadeOut () ->
      $(this).html(storiesTemplate(storyInfo))
      $(this).fadeIn()

$(".url").live "click", (ev) ->
  $(window).trigger "selectStory", [$(this).closest(".story")]
  ev.preventDefault()

show()
setInterval show, 10*60*1000

###############################################################################
# SHOW CONTENT AND COMMENTS
###############################################################################

$content = $("#content")
$comments = $("#comments")

# RESPOND TO UI EVENTS WITH SEMANTIC EVENTS

$(".story").live "click", (ev) -> $(window).trigger "selectStory", [$(this)]
 
keyBindings =
  13: () ->
    ev = if $("#content").attr("src")? then "selectComments" else "selectStory"
    $(window).trigger ev, [$(".selected")]

  27: () -> # ESCAPE
    ev = if $comments.attr("src")? then "clearComments" else "clearStory"
    $(window).trigger ev

  74: () -> # j==DOWN
    $(window).trigger "selectStory", 
     [if $(".selected").length then $(".selected").next() else $(".story").eq(0)]

   75: () -> $(window).trigger "selectStory", [$(".selected").prev()]
   
$(window).bind "keydown", (ev) ->
  keyBindings[ev.keyCode]($content, $comments) if keyBindings[ev.keyCode]?

$(window).click (ev) -> $(window).trigger "clearStory"

# Not handled right now
# $(window).bind "scroll", (ev) -> $(window).trigger "clearStory"

# HANDLE SEMANTIC EVENTS

$(window).bind "selectStory", (ev, $story, ensureComments) ->
  $(".selected").removeClass("selected")
  if $story and $story.length
    $story.addClass("selected")
    $content.src $(".selected .url a").attr("href")
    $(".mid").removeClass(".mid")
    if ensureComments or $comments.attr("src")?
      $comments.src $(".selected .commentsLink a").attr("href")
  else
    $content.removeAttr("src")

$(window).bind "selectComments", (ev, $story) ->
  $(window).trigger("selectStory", [$story, true]) # always require story

$(window).bind "clearStory", (ev, $story) ->
  $(window).trigger("clearComments")
  $content.removeAttr("src")

$(window).bind "clearComments", (ev, $story) ->
  $comments.removeAttr("src")

###############################################################################
# INSTAPAPER
###############################################################################

$("#instapaperLogin").click () ->
  $("#instapaper .pending").show();
  $.getJSON "https://www.instapaper.com/api/authenticate?jsonp=?",
    $("#instapaper").serialize()
    (response) ->
      $.exclusive response.status==200,
      $("#instapaper .success"), $("#instapaper .error")
  return false

$(".readLaterStatus").live "click", (ev) -> 
  $(".pending", readLaterStatus = this).radio()
  $.getJSON "https://www.instapaper.com/api/add?jsonp=?",
    $("#instapaper").serialize()+
    "&url="+escapeURL($(this).closest(".story").find(".url a").attr("href"))
    (response) ->
      $(".success", readLaterStatus).radio();
  return false

###############################################################################
# TWITTER
###############################################################################

twttr.anywhere (T) -> T("#tweetBox").tweetBox(
  label: "Tweet the story",
  defaultContent: "A good story that one"
)

###############################################################################
# GENERIC
###############################################################################

$.fn.radio = () -> $(this).show().siblings().hide()
$.fn.radioClass = (className) ->
  $(this).addClass(className).siblings().removeClass(className)

$.exclusive = (cond, $a, $b) -> if cond then $a.radio() else $b.radio()
$(".toggle span").click () -> $(this).parent().next().slideToggle()
$.fn.src = (url, throttle) -> 
  namespace = arguments.callee
  return if ($iframe=$(this)).attr("src")==url
  throttle = throttle||200
  now = +new Date
  clearTimeout(arguments.callee.timer)
  timeSinceLastReload = +new Date - (namespace.lastReload||0)
  timeTillReload = Math.max(0,throttle-timeSinceLastReload)
  namespace.timer = setTimeout( () ->
    $iframe.attr("src", url)
    namespace.lastReload = now
  , timeTillReload)
escapeURL = (s) -> s.replace(":","%3a").replace(/\//g, "%2f")
