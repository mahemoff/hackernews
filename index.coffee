
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

Object.prototype.attr = (name) ->
  try
    return this.xmlNode.getElementsByTagName(name)[0].firstChild.textContent
  catch e
    return '-'

Story = (entry) ->
  story = _(this).extend
    title: entry.attr 'title'
    url: entry.attr 'link'
    points: entry.attr 'points'
    username: entry.attr 'username'
    num_comments: entry.attr 'num_comments'
    commentsURL: entry.attr 'comments'
    created: Date.fromISO8601(entry.attr('create_ts')).getTime()
    posterURL: "http://news.ycombinator.com/user?id=#{entry.attr 'username'}"
    postedAgo: Date.fromISO8601(entry.attr 'create_ts').timeago()
    simpleURL: "http://www.instapaper.com/text?u=#{encode(entry.attr 'link')}"
  this
###
  window.entry = entry
  story.url = entry.link
  story.commentsURL = entry
  ## story.author = 
  _(attribs).each (val, attrib) -> story[attrib] = val
  story.url = story.link
  story.posterURL = "http://news.ycombinator.com/user?id=#{attribs.username}"
  story.commentsURL = "http://news.ycombinator.com/item?id=#{attribs.id}"
  story.url = this.commentsURL if not attribs.url?
  story.simpleURL = "http://www.instapaper.com/text?u=#{encode(story.url)}"
  story.postedAgo = (new Date.fromISO8601(story.create_ts)).timeago()
###

# content can be "page", "ask", or "new"
updateCount = 0
update = () ->
  feed = new google.feeds.Feed 'http://www.hnsearch.com/rss'
  feed.setResultFormat google.feeds.Feed.MIXED_FORMAT
  feed.setNumEntries 30
  feed.load (res) ->
    return if res.error
    stories = res.feed.entries.map (entry) -> new Story(entry)
    # stories = stories.sort (s1,s2) -> s1.created < s2.created
    stories.sort (s1,s2) -> s2.created - s1.created
    $("#stories").empty().hide()
    _(stories).each (story, i) ->
      story.prerender = !updateCount and i<3 #pre-render first 3 stories on first paint
      $("<tr class='story' />")
      .html(storyTemplate(story))
      .data("story", story)
      .appendTo($("#stories"))
    $('#stories').fadeIn 'slow'
    updateCount++

  # $.getJSON 'http://api.thriftdb.com/api.hnsearch.com/items/_search?limit=30&sortby=product(points,pow(2,div(div(ms(create_ts,NOW),3600000),3)))%20desc&pretty_print=true&callback=?',
  # search='http://api.thriftdb.com/api.hnsearch.com/items/_search?limit=90&sortby=product(points,pow(2,div(div(ms(create_ts,NOW),3600000),0.2))%20desc&pretty_print=true&callback=?'
  # $.getJSON search, (storyInfo) ->
  ###
  feed = new google.feeds.Feed 'http://news.ycombinator.com/rss'
  feed.setResultFormat google.feeds.Feed.MIXED_FORMAT
  feed.setNumEntries 10
  feed.load (result) ->
  ###

$(".url").live "click", (ev) ->
  $(window).trigger "selectStory", [$(this).closest(".story")]
  ev.preventDefault()

###
$('.page').click () -> update 'page'
$('.new').click  () -> update 'new'
$('.ask').click  () -> update 'ask'
###

###############################################################################
# INIT
###############################################################################

window.init = () ->
  update()
  setTimeout update, 10*60*1000

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
    $content.attr("src", story.simpleURL)
  else
    $content.attr("src", story.url)
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

loginToInstapaper = (success, error) ->
  $.getJSON "https://www.instapaper.com/api/authenticate?jsonp=?", $("#instapaper").serialize(), (response) ->
    if response.status==200
      $('html').addClass 'instapaperActive'
      success() if success
    else
      error() if error

if localStorage.instaParams
  $("#instapaper").deserialize localStorage.instaParams
  loginToInstapaper()

$(".saveSettings").click ->
  if this.checked
    wanted = confirm('This will save your name and password in plain-text on your machine (Instapaper API requires it work this way). Please, only do this if you are using your own machine!')
    if not wanted
      this.checked = null
      delete localStorage.instaParams

$("#instapaperogin").click () ->
  $("#instapaper .pending").show();
  loginToInstapaper ->
    localStorage.instaParams = $("#instapaper").serialize() if $(".saveSettings").is(":checked") 
    $("#instapaper .success").radio()
    setTimeout (-> $(".toggle span").parent().next().slideToggle()), 1000
  , ->
    $("#instapaper .error").radio()
  false

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

