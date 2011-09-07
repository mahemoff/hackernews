(function() {
  var app_id = "https://chrome.google.com/webstore/detail/npalbnjnpgfknopcnjofihcankbnngef";
  var app_name = "";
  var message = "Install in Chrome"; 
  var install_message = ""; 
  var install_image = "data:image/png;base64,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";
  var cancel_message = "";
  var cancel_image = "http://cws-badge.appspot.com/images/cancel.png";
  var css_url = "data:text/css;base64,Ll93ZWJzdG9yZV9iYWRnZSB7CiAgY29sb3I6IHdoaXRlOwogIHdpZHRoOiAxMjhweDsKICBoZWlnaHQ6IDEyNXB4OwogIHRvcDogMHB4OwogIHJpZ2h0OiAwcHg7CiAgcG9zaXRpb246IGFic29sdXRlOwogIG1hcmdpbjogMCA1MHB4IDAgNTBweDsKICBwYWRkaW5nOiA1cHggMTVweDsKICBib3gtc2hhZG93OiAjMDAwIDAgMCA1cHg7CiAgYmFja2dyb3VuZC1jb2xvcjogI2VhZTg4YzsKICBib3JkZXI6IHNvbGlkIDFweCAjYzljNzc4OwogIGJvcmRlci1ib3R0b20tbGVmdC1yYWRpdXM6IDVweDsKICBib3JkZXItYm90dG9tLXJpZ2h0LXJhZGl1czogNXB4OwogIGRpc3BsYXk6IGlubGluZTsKICBmb250LWZhbWlseTogQXJpYWw7CiAgb3BhY2l0eTogMTsKICAtd2Via2l0LXRyYW5zaXRpb246IGFsbCAwLjVzIGVhc2UtaW4tb3V0OwogICAgdGV4dC1hbGlnbjogY2VudGVyOwp9CgouX3dlYnN0b3JlX2JhZGdlOmhvdmVyIHsKICBiYWNrZ3JvdW5kLWNvbG9yOiAjZjJmMDkwOwp9CgouX3dlYnN0b3JlX2JhZGdlIC5fd2Vic3RvcmVfbWVzc2FnZSB7CiAgd2lkdGg6IDEwMCU7CiAgdGV4dC1zaGFkb3c6ICMxMTEgMHB4IDBweCAycHg7CiAgdGV4dC1hbGlnbjogY2VudGVyOwogIGZvbnQtd2VpZ2h0OiA3MDA7CiAgZGlzcGxheTogYmxvY2s7Cn0KCi5fd2Vic3RvcmVfYmFkZ2UgLl93ZWJzdG9yZV9pbnN0YWxsIHsKICB3aWR0aDogMTAwcHg7CiAgaGVpZ2h0OiAxMDBweDsKICBtYXJnaW4tdG9wOiA1cHg7CiAgZGlzcGxheTogYmxvY2s7Cn0KCi5fd2Vic3RvcmVfYmFkZ2UgLl93ZWJzdG9yZV9jYW5jZWwgewogIHRvcDogMDsKICByaWdodDogMnB4OwogIHBvc2l0aW9uOiBhYnNvbHV0ZTsKICBvcGFjaXR5OiAwOwogIC13ZWJraXQtdHJhbnNpdGlvbjogYWxsIDAuMnMgZWFzZS1pbi1vdXQ7Cn0KCi5fd2Vic3RvcmVfYmFkZ2U6aG92ZXIgLl93ZWJzdG9yZV9jYW5jZWwgewogIG9wYWNpdHk6IDE7Cn0KCi5fd2Vic3RvcmVfaW5zdGFsbCB7IHdpZHRoOiAxMDBweDsgbWFyZ2luOiAwIGF1dG87IH0KLl93ZWJzdG9yZV9pbnN0YWxsIGltZyB7IHdpZHRoOiAxMDAlOyB9";
  var cookie_name = "_webstore__rTyf";
  var isInstalled = !!(window.chrome && window.chrome.app && window.chrome.app.isInstalled && !(window.location.host == "badgemator.appspot.com"));
  var isCancelled = !!(document.cookie.indexOf(cookie_name + "=true") >= 0);
  
  if(window.navigator.userAgent.indexOf("Chrome/") >= 0 && (!isInstalled && !isCancelled)) {
    var onloaded = function() {
      var container = document.createElement("span");
      container.className = "_webstore_badge";
      
      document.styleSheets[0].addRule("._webstore_badge", "opacity:0", 0);
      
      if(message) {
        var message_element = document.createElement("span");
        message_element.className = "_webstore_message";
        message_element.innerText = message;
        container.appendChild(message_element);
      }
      
      var link = document.createElement("a");
      link.href = app_id;
      link.target = "_blank";
      link.className = "_webstore_install";
      container.appendChild(link);
       
      if(install_message) {
        link.innerText = install_message;
        link.alt = "Installs " + app_name; 
      }
      else if(install_image) {
        var img = new Image();
        img.src = install_image;
        link.appendChild(img);
        link.alt = "Installs " + app_name; 
        $(container).css('overflow', 'hidden');
        setTimeout(function() { $(container).animate({ height: 20}, function() { $(link).hide(); }) }, 5000);
      }
      
      var close = document.createElement("a");
      close.className = "_webstore_cancel";
      close.href = "#";
      
      close.addEventListener("click", function(e) {
        // Set a cookie, that we will respect if the user cancels.
        container.style.display = "none";
        document.cookie = cookie_name + "=true";
        e.preventDefault();
        return false;
      });
      if(cancel_message) {
        close.innerText = cancel_message;
      }
      else if(cancel_image) {
        var img = new Image();
        img.src = cancel_image;
        
        img.alt = "Cancel Prompt"; 
        close.appendChild(img);
      }
      container.appendChild(close);
      
      if(css_url) {
        var css_link = document.createElement("link");
        css_link.rel = "stylesheet";
        css_link.title = "webstore_badge";
        css_link.href = css_url;
        document.head.appendChild(css_link);
      }
      document.body.appendChild(container);
    };
    
    if(document.readyState == "complete") {
      onloaded();
    }
    else {
      document.addEventListener("DOMContentLoaded", onloaded);
    }
  }
})();
