// From HN Search
(function(){Date.fromISO8601=function(b){var j=new Date(b);if(isNaN(j))j=(new Date).setISO8601(b);return j};Date.prototype.setISO8601=function(b){var j=/(\d\d\d\d)(-)?(\d\d)(-)?(\d\d)(T)?(\d\d)(:)?(\d\d)(:)?(\d\d)(\.\d+)?(Z|([+-])(\d\d)(:)?(\d\d))/;if(b.toString().match(new RegExp(j))){b=b.match(new RegExp(j));j=0;this.setUTCDate(1);this.setUTCFullYear(parseInt(b[1],10));this.setUTCMonth(parseInt(b[3],10)-1);this.setUTCDate(parseInt(b[5],10));this.setUTCHours(parseInt(b[7],10));this.setUTCMinutes(parseInt(b[9],
10));this.setUTCSeconds(parseInt(b[11],10));b[12]?this.setUTCMilliseconds(parseFloat(b[12])*1E3):this.setUTCMilliseconds(0);if(b[13]!="Z"){j=b[15]*60+parseInt(b[17],10);j*=b[14]=="-"?-1:1;this.setTime(this.getTime()-j*60*1E3)}}else this.setTime(Date.parse(b));return this};Date.prototype.timeago=function(){var b=((new Date).getTime()-this.getTime())/1E3,j=Math.floor(b/86400),d=Math.floor(j/30),l=Math.floor(d/12);if(!(isNaN(j)||j<0))return j==0?b<60&&"just now"||b<120&&"1 minute ago"||b<3600&&Math.floor(b/
60)+" minutes ago"||b<7200&&"1 hour ago"||b<86400&&Math.floor(b/3600)+" hours ago":d==0?j==1&&"Yesterday"||j<7&&j+" days ago"||j<31&&Math.ceil(j/7)+" weeks ago":l==0?d==1&&"1 month ago"||d<12&&d+" months ago":l+(l==1?" year ago":" years ago")}})();