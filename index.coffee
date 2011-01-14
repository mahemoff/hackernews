storiesTemplate = _.template($("#storiesTemplate").html())
console.log("loading")
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
  
  url = $(".url", this)
  
  selected.removeClass "selected" if selected? 
  selected = url.parents(".story")
  
  selected.addClass "selected"
  
  $iframe.removeClass "none"
  $iframe.attr("src", url.attr("href"))
  
  if $comments.attr("src")? and $comments.attr("src") isnt ""
    $comments.attr("src", $(".commentsLink", selected).attr("href"))
  
funcMap =
  "13": ($content, $comments) ->
    $content.attr("src", $(".url", selected).attr("href"))
    $comments.attr("src", $(".commentsLink", selected).attr("href"))
    
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
    
    $content.attr("src", $(".url", selected).attr("href"))
    $content.removeClass "mid"
    
    $comments.removeClass "mid"
    
    if $comments.attr("src")? and $comments.attr("src") isnt ""
      $comments.attr("src", $(".commentsLink", selected).attr("href"))
    
  "74": ($content, $comments) ->
    console.log selected
    
    if not selected?
      selected = $("#stories li").first()
    else
      selected.removeClass "selected"
      selected = selected.next()
      
    selected.addClass "selected"
    
    $content.attr("src", $(".url", selected).attr("href"))
    $content.removeClass "mid"
    
    $comments.removeClass "mid"
    
    if $comments.attr("src")? and $comments.attr("src") isnt ""
      $comments.attr("src", $(".commentsLink", selected).attr("href"))
    
$(window).bind "keyup", (ev) ->
  $content = $ "#content"
  $comments = $ "#comments"
  
  console.log ev.keyCode
  
  funcMap[ev.keyCode]($content, $comments) if funcMap[ev.keyCode]?

$(window).bind "scroll", (ev) ->
  $content = $ "#content"
  $comments = $ "#comments"
  
  console.log($content.attr("src"))
  console.log($comments.attr("src"))
  
  $content.addClass("mid") if $content.attr("src")
  $comments.addClass("mid") if $comments.attr("src")? and $content.attr("src")
  
