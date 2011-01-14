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

$(".story").live "click", (ev) -> 
  return if $(ev.target).closest("a").length
  window.open($(".url", this).attr("href"), "_blank");

/****************************************************************************/
# INSTAPAPER

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

showTweet = (story, url)
  twttr.anywhere (T) -> T("#tweetBox").tweetBox(
    label: "Tweet the story",
    defaultContent: "A good story that one"
  )

/*****************************************************************************/
# GENERIC

$.fn.radio = () -> $(this).show().siblings().hide()

$.exclusive = (cond, $a, $b) -> if cond then $a.radio() else $b.radio()


