
###############################################################################
# GENERIC
###############################################################################

$.fn.radio = () -> $(this).show().siblings().hide()
$.fn.radioClass = (className) ->
  $(this).addClass(className).siblings().removeClass(className)

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
  namespace.timer = setTimeout( () ->
    $iframe.attr("src", url)
    namespace.lastReload = now
  , timeTillReload)
  return $iframe
encode = (s) -> s.replace(":","%3a").replace(/\//g, "%2f")
delay = (ms, func) -> setTimeout func, ms

$.fn.checked = () -> $(this).attr("checked")

###############################################################################
# TEMPLATES
###############################################################################

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
  this.url = this.commentsURL if not ~attribs.url.search("(http|https):")
  this.simpleURL = "http://www.instapaper.com/text?u=#{encode(this.url)}"
  this

# content can be "page", "ask", or "new"
update = (content) ->

  $('.timedout').hide()
  delay 10000, -> $('.timedout').show()

  content ||= 'page'
  console.log "CONTENT #{content}"
  $.getJSON "http://api.ihackernews.com/#{content}?format=jsonp&callback=?",
    (storyInfo) ->
      stories = storyInfo.items.map (storyData) -> new Story(storyData)
      $("#stories").fadeOut () ->
        $("#stories :first-child").empty()
        _(stories).each (story) ->
          $("<tr class='story' />")
          .html(storyTemplate(story))
          .data("story", story)
          .appendTo($("#stories"))
        $(this).fadeIn()

$(".url").live "click", (ev) ->
  $(window).trigger "selectStory", [$(this).closest(".story")]
  ev.preventDefault()

$('.page').click () -> update 'page'
$('.new').click  () -> update 'new'
$('.ask').click  () -> update 'ask'

update()
setInterval update, 10*60*1000

###############################################################################
# SHOW CONTENT AND COMMENTS
###############################################################################

$content = $("#content")
$contentPanel = $("#contentPanel")
$comments = $("#comments")

# RESPOND TO UI EVENTS WITH SEMANTIC EVENTS

$(".story").live "click", (ev) ->
  $(window).trigger "selectStory", [$(this)]
  return false
 
$("#stories .commentsLink").live "click", (ev) ->
   $(window).trigger "selectComments", [$(this).closest(".story")]
   return false

$("#contentPanel .commentsLink").click (ev) ->
  if $comments.attr("src")?
    $(window).trigger "closeComments"
  else
    $(window).trigger "selectComments", [$(".selected")]
  return false

$(window).click (ev) ->
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
  if $("#simplified").checked()
    # $content.removeAttr("sandbox").src(story.simpleURL)
    $content.removeAttr("sandbox").attr("src", story.simpleURL)
  else
    # $content.attr("sandbox", "sandbox").src(story.url)
    $content.attr("sandbox", "sandbox").attr("src", story.url)
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
  $(window).trigger("closeComments")
  $content.removeAttr("src")

$(window).bind "closeComments", (ev, $story) ->
  $(".commentsOff").radio()
  $comments.removeAttr("src")

$(window).bind "changeSimplified", (ev) ->
  $(window).trigger("selectStory", [$(".selected")])

###############################################################################
# INSTAPAPER
###############################################################################

$("#instapaper").deserialize localStorage.instaParams if localStorage.instaParams
$(".saveSettings").click ->
  if this.checked
    wanted = confirm('This will save your details locally! Anyone with access to this computer/account (and a modicum of savvy) will be able to determine your Instapaper username and password.')
    if not wanted
      this.checked = null
      delete localStorage.instaParams

$("#instapaperLogin").click () ->
  $("#instapaper .pending").show();
  instaParams = $("#instapaper").serialize()
  $.getJSON "https://www.instapaper.com/api/authenticate?jsonp=?", instaParams,
    (response) ->
      if response.status==200
        localStorage.instaParams = instaParams if $(".saveSettings").is(":checked") 
        $("#instapaper .success").radio()
        setTimeout (-> $(".toggle span").parent().next().slideToggle()), 1000
      else
        $("#instapaper .error").radio()
  return false

$(".readLaterStatus").live "click", (ev) -> 
  $(".pending", readLaterStatus = this).radio()
  $.getJSON "https://www.instapaper.com/api/add?jsonp=?",
    $("#instapaper").serialize()+
    "&url="+encode($(this).closest(".story").find(".url a").attr("href"))
    (response) ->
      if response.status==201
        $(".success", readLaterStatus).radio()
      else
        $(".fresh", readLaterStatus).radio()
        $("#instapaper .error").radio()
        $(".toggle span").parent().next().slideToggle()
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

