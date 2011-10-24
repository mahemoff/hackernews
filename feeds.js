google.load('feeds', '1')
google.setOnLoadCallback(function() {
  if (window.init) return window.init();
  setTimeout(arguments.callee, 500);
});
