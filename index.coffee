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
  "27": (iframe) ->
    iframe.removeClass "mid"
    iframe.attr("src", "") 
    
  "74": (iframe) ->
    return if not selected?
    
    selected.removeClass "selected"
    selected = selected.prev()
    selected.addClass "selected"
    
    iframe.attr("src", $(".url", selected).attr("href"))
    iframe.removeClass "mid"
    
  "75": (iframe) ->
    console.log selected
    
    if not selected?
      selected = $("#stories li").first()
    else
      selected.removeClass "selected"
      selected = selected.next()
    console.log selected
    selected.addClass "selected"
    
    iframe.attr("src", $(".url", selected).attr("href"))
    iframe.removeClass "mid"
    
$(window).bind "keyup", (ev) ->
  iframe = $("#content")
  
  funcMap[ev.keyCode](iframe) if funcMap[ev.keyCode]?

$(window).bind "scroll", (ev) ->
  iframe = $("#content")
  iframe.addClass("mid") if iframe.hasClass ""
