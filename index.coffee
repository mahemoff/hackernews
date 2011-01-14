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
  $iframe = $("#content")
  $iframe.removeClass("mid")
  
  $comments = $("#comments")
  
  url = $(".url a", this)
  
  selected.removeClass "selected" if selected? 
  selected = url.parents(".story")
  
  selected.addClass "selected"
  
  $iframe.removeClass "none"
  $iframe.attr("src", url.attr("href"))
  
  if $comments.attr("src")? and $comments.attr("src") isnt ""
    $comments.attr("src", $(".commentsLink a", selected).attr("href"))
  
funcMap =
  "13": ($content, $comments) ->
    $content.attr("src", $(".url a", selected).attr("href"))
    $comments.attr("src", $(".commentsLink a", selected).attr("href"))
    
  "27": ($content, $comments) ->
    if $comments.attr("src") isnt ""
      $comments.removeClass "mid"
      $comments.attr("src", "")
    else
      $content.removeClass "mid"
      $content.attr("src", "") 
    
  "75": ($content, $comments) ->
    return if not selected?
    
    selected.removeClass "selected"
    selected = selected.prev()
    
    selected = null if selected.length is 0
    
    selected.addClass "selected"
    
    $content.attr("src", $(".url a", selected).attr("href"))
    $content.removeClass "mid"
    
    $comments.removeClass "mid"
    
    if $comments.attr("src")? and $comments.attr("src") isnt ""
      $comments.attr("src", $(".commentsLink a", selected).attr("href"))
    
  "74": ($content, $comments) ->
    console.log selected
    
    if not selected?
      selected = $("#stories tr").first()
    else
      selected.removeClass "selected"
      selected = selected.next()
      
    selected.addClass "selected"
    
    $content.attr("src", $(".url a", selected).attr("href"))
    $content.removeClass "mid"
    
    $comments.removeClass "mid"
    
    if $comments.attr("src")? and $comments.attr("src") isnt ""
      $comments.attr("src", $(".commentsLink a", selected).attr("href"))
    
$(window).bind "keyup", (ev) ->
  $content = $ "#content"
  $comments = $ "#comments"
  
  console.log ev.keyCode
  
  funcMap[ev.keyCode]($content, $comments) if funcMap[ev.keyCode]?

$(".readLaterStatus").live "click", (ev) -> 
  $(".pending", readLaterStatus = this).radio()
  $.getJSON "https://www.instapaper.com/api/add?jsonp=?",
    $("#instapaper").serialize()+"&url="+$(this).closest(".story").find(".url a").attr("href").replace(":","%3a").replace(/\//g, "%2f"),
    (response) ->
      console.log("success")
      $(".success", readLaterStatus).radio();
  return false
  
$("#instapaperLogin").click () ->
  $("#instapaper .pending").show();
  $.getJSON "https://www.instapaper.com/api/authenticate?jsonp=?",
    $("#instapaper").serialize()
    (response) ->
      $.exclusive response.status==200,
      $("#instapaper .success"), $("#instapaper .error")
  return false

$(".toggle span").click () ->
  $(this).parent().next().slideToggle()

/*****************************************************************************/
# TWITTER

twttr.anywhere (T) -> T("#tweetBox").tweetBox(
  label: "Tweet the story",
  defaultContent: "A good story that one"
)

/*****************************************************************************/
# GENERIC

$.fn.radio = () -> $(this).show().siblings().hide()

$.exclusive = (cond, $a, $b) -> if cond then $a.radio() else $b.radio()


$(window).bind "scroll", (ev) ->
  $content = $ "#content"
  $comments = $ "#comments"
  $content.addClass("mid") if $content.attr("src")
  $comments.addClass("mid") if $comments.attr("src")? and $content.attr("src")
