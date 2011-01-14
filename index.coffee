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
  iframe = $("#content")
  iframe.removeClass("mid")
  
  url = $(".url", this)
  selected = url.parents(".story")
  
  selected.addClass "selected"
  
  iframe.removeClass "none"
  iframe.attr("src", url.attr("href"))
  
funcMap =
  "13": ($content, $comments) ->
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
    
$(window).bind "keyup", (ev) ->
  $content = $ "#content"
  $comments = $ "#comments"
  
  console.log ev.keyCode
  
  funcMap[ev.keyCode]($content, $comments) if funcMap[ev.keyCode]?

$(window).bind "scroll", (ev) ->
  $content = $ "#content"
  $comments = $ "#comments"
  $content.addClass("mid") if $content.hasClass "" and $content.attr("src") is ""
  $comments.addClass("mid") if $comments.hasClass "" and $comments.attr("src") is ""
  
