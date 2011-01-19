# todo return false -> ev.preventDefault()

storyTemplate = _.template $("#storyTemplate").html()
contentPanelTemplate = _.template($("#contentPanelTemplate").html())

###############################################################################
# LOAD STORIES
###############################################################################

Story = (attribs) ->
  story = this
  _(attribs).each (val, attrib) ->
    story[attrib] = val
  this.posterURL = "http://news.ycombinator.com/item?user=#{attribs.postedBy}"
  this.commentsURL = "http://news.ycombinator.com/item?id=#{attribs.id}"
  this.simpleURL = "http://www.instapaper.com/text?u=#{encode(attribs.url)}"
  this

show = () ->
  $.getJSON "http://api.ihackernews.com/page?format=jsonp&callback=?",
    (storyInfo) ->
      stories = storyInfo.items.map (storyData) -> new Story(storyData)
      $("#stories").fadeOut () ->
        _(stories).each (story) ->
          $("<tr class='story' />")
          .html(storyTemplate(story))
          .data("story", story)
          .appendTo($("#stories"))
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
$contentPanel = $("#contentPanel")
$comments = $("#comments")

# RESPOND TO UI EVENTS WITH SEMANTIC EVENTS

$(".story").live "click", (ev) ->
  console.log "live click"
  $(window).trigger "selectStory", [$(this)]
  return false
 
$("#stories .commentsLink").live "click", (ev) ->
   $(window).trigger "selectComments", [$(this).closest(".story")]
   return false

$("#contentPanel .commentsLink").click (ev) ->
  if $comments.attr("src")?
    console.log("hazzz")
    $(window).trigger "closeComments"
  else
    $(window).trigger "selectComments", [$(".selected")]
    console.log("hazzznt")
  return false

$(window).click (ev) ->
  console.log "clicked in window"
  unless $(ev.target).closest("#contentPanel").length
    $(window).trigger "closeStory"

keyBindings =
  13: () -> # CR
    ev = if $content.attr("src")? then "selectComments" else "selectStory"
    $(window).trigger ev, [$(".selected")]

  27: () -> # ESCAPE
    ev = if $comments.attr("src")? then "closeComments" else "closeStory"
    $(window).trigger ev

  74: () -> # j
    $(window).trigger "selectStory", 
     [if $(".selected").length then $(".selected").next() else $(".story").eq(0)]

   75: () -> $(window).trigger "selectStory", [$(".selected").prev()] # k
   
$(window).bind "keydown", (ev) ->
  keyBindings[ev.keyCode]($content, $comments) if keyBindings[ev.keyCode]?

# Not handled right now
# $(window).bind "scroll", () -> $(window).trigger "closeStory"

# HANDLE SEMANTIC EVENTS

$(window).bind "selectStory", (ev, $story, ensureComments) ->
  $(".selected").removeClass("selected")
  story = $story.data("story")
  # unless $story and $story.length
    # $content.removeAttr("src")
    # return

  $story.addClass("selected")
  console.log("story", story)
  if $("#simplified").checked()
    # $content.removeAttr("sandbox").src(story.simpleURL)
    $content.removeAttr("sandbox").attr("src", story.simpleURL)
  else
    console.log($content, "set src")
    # $content.attr("sandbox", "sandbox").src(story.url)
    $content.attr("sandbox", "sandbox").attr("src", story.url)
  console.log "SRRC", $content.attr("src"), story.url
  # $content.src story[if $("#simplified").checked() then "simpleURL" else "url"]
  if ensureComments or $comments.attr("src")?
    $(".commentsOn").radio()
    $comments.attr "src", $(".selected .commentsLink a").attr("href")

  $("[data-property]", $contentPanel).each () ->
    $(this).html(story[$(this).attr("data-property")])
  $("[data-href]", $contentPanel).each () ->
    $(this).attr("href", story[$(this).attr("data-href")])
  tweet().val "#{story.url} #{story.title}"

$(window).bind "selectComments", (ev, $story) ->
  $(window).trigger("selectStory", [$story, true]) # always require story

$(window).bind "closeStory", (ev, $story) ->
  console.log("closeStory")
  $(window).trigger("closeComments")
  $content.removeAttr("src")

$(window).bind "closeComments", (ev, $story) ->
  console.log("closeComments")
  $(".commentsOff").radio()
  $comments.removeAttr("src")

$(window).bind "changeSimplified", (ev) ->
  $(window).trigger("selectStory", [$(".selected")])

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
    "&url="+encode($(this).closest(".story").find(".url a").attr("href"))
    (response) ->
      $(".success", readLaterStatus).radio();
  return false

###############################################################################
# CONTROL PANEL
###############################################################################

$("#contentPanel .close").click () -> $(window).trigger "closeStory"

$("#simplified").click () ->
  $(window).trigger("changeSimplified", [$(this).checked()])

twttr.anywhere (T) -> T("#tweetBox").tweetBox(
  label: "Share on Twitter"
)

$("#shortenURLs").click () ->
  story = $(".selected").data("story")
  _(tweet().val().match /http:\/\/\S+/g).each (url) ->
    $.getJSON "http://api.bit.ly/v3/shorten?login=hackernewsreader&apiKey=R_5da1133ac51e981af704ea180486bdfc&longUrl=#{url}&format=json", (response) ->
      tweet().val(tweet().val().replace url, response.data.url)

tweet = () -> $("#tweetBox iframe").contents().eq(0).find("textarea")

###############################################################################
# GENERIC
###############################################################################

$.fn.radio = () -> $(this).show().siblings().hide()
$.fn.radioClass = (className) ->
  $(this).addClass(className).siblings().removeClass(className)

$.exclusive = (cond, $a, $b) -> if cond then $a.radio() else $b.radio()
$(".toggle span").live "click", () -> $(this).parent().next().slideToggle()
$.fn.src = (url, throttle) -> 
  $(this).attr("src", url)
  return
  namespace = arguments.callee
  return if ($iframe=$(this)).attr("src")==url
  throttle = throttle||200
  now = +new Date
  clearTimeout(arguments.callee.timer)
  timeSinceLastReload = +new Date - (namespace.lastReload||0)
  timeTillReload = Math.max(0,throttle-timeSinceLastReload)
  console.log("timeTill", timeTillReload)
  namespace.timer = setTimeout( () ->
    console.log("running")
    $iframe.attr("src", url)
    namespace.lastReload = now
  , timeTillReload)
  return $iframe
encode = (s) -> s.replace(":","%3a").replace(/\//g, "%2f")

$.fn.checked = () -> $(this).attr("checked")
