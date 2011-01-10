storiesTemplate = _.template($("#storiesTemplate").html())
console.log("loading")
show = () ->
  $.getJSON "http://api.ihackernews.com/page?format=jsonp&callback=?",
    (storyInfo) -> $("#stories").fadeOut () ->
      $(this).html(storiesTemplate(storyInfo))
      $(this).fadeIn()

show()
setInterval show, 10*60*1000

$(".story").live "click", (ev) -> 
  return if $(ev.target).closest("a").length
  window.open($(".url", this).attr("href"), "hackernews"+Math.random());

