/****************************************************************************/
# STORIES

storiesTemplate = _.template($("#storiesTemplate").html())
show = () ->
  $.getJSON "http://api.ihackernews.com/page?format=jsonp&callback=?",
    (storyInfo) -> $("#stories").fadeOut () ->
      $(this).html(storiesTemplate(storyInfo))
      $(this).fadeIn()

show()
setInterval show, 10*60*1000

selected = null

$(".story").live "click", (ev) -> 
  return if $(ev.target).closest("a").length
  $iframe = $("#content").removeClass("mid")
  $(this).radioClass(".selected")
  $iframe.attr("src", $(".url a", this).attr("href"))
  if ($comments = $("#comments")).attr("src")?
    $comments.attr("src", $(".commentsLink a", selected).attr("href"))
  
keyBindings =
  13: ($content, $comments) -> # ENTER
    $content.attr("src", $(".selected .url a").attr("href"))
    $comments.attr("src", $(".selected .commentsLink a").attr("href"))

  27: ($content, $comments) -> # ESCAPE
    if $comments.attr("src")?
      $comments.removeClass("mid").removeAttr("src")
    else
      $content.removeClass("mid").removeAttr("src")

  74: ($content, $comments) -> # j==DOWN
    $selected =
      if $(".selected").length then $(".selected").next() else $(".story").eq(0)
    $selected.radioClass("selected") 
    $content.attr("src", $(".selected .url a").attr("href"))
    $content.add($comments).removeClass "mid"
    if $comments.attr("src")?
      $comments.attr("src", $(".selected .commentsLink a").attr("href"))

   75: ($content, $comments) -> # k==UP
    return unless $(".selected").length
    $(".selected").removeClass("selected").prev().addClass("selected")
    $content.attr("src", $(".selected .url a").attr("href"))
    $content.add($comments).removeClass "mid"
    if $comments.attr("src")?
      $comments.attr("src", $(".commentsLink a", selected).attr("href"))
    
$(window).bind "keydown", (ev) ->
  $content = $ "#content"
  $comments = $ "#comments"
  keyBindings[ev.keyCode]($content, $comments) if keyBindings[ev.keyCode]?

$(window).bind "scroll", (ev) ->
  $content = $ "#content"
  $comments = $ "#comments"
  $content.addClass("mid") if $content.attr("src")
  $comments.addClass("mid") if $comments.attr("src")? and $content.attr("src")

/*****************************************************************************/
# INSTAPAPER

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
    $("#instapaper").serialize()+"&url="+$(this).closest(".story").find(".url a").attr("href").replace(":","%3a").replace(/\//g, "%2f"),
    (response) ->
      console.log("success")
      $(".success", readLaterStatus).radio();
  return false

/*****************************************************************************/
# TWITTER

twttr.anywhere (T) -> T("#tweetBox").tweetBox(
  label: "Tweet the story",
  defaultContent: "A good story that one"
)

/*****************************************************************************/
# GENERIC

$.fn.radio = () -> $(this).show().siblings().hide()
$.fn.radioClass = (className) ->
  $(this).addClass(className).siblings().removeClass(className)

$.exclusive = (cond, $a, $b) -> if cond then $a.radio() else $b.radio()

$(".toggle span").click () ->
  $(this).parent().next().slideToggle()

