/**
 * jQuery Deserialize plugin
 * @author: Dawid Fatyga
 *
 * Forked from: http://github.com/jakubpawlowicz/jquery.deserialize
 *
**/

/* Builtin Array class extension, which converts itself to map */
Array.prototype.toHash = function(){
	var map = {}
	for(var i = 0;i < this.length; i++)
		map[this[i]] = ''
	return map
};

$.fn.deserialize = function(s, options) {
	var data = s.split("&")

	options = options || {}
	attr = options.attribute || "name"

	if(options.only && options.except)
		throw "You cannot pass both 'only' and 'except' options"

	var names = (options.except || []).toHash()
	var except = true
	if(options.only){
		names = options.only.toHash()
		except = false
	}

	callback = options.callback
	callback_on = options.callback_on || false
	if(callback_on)
		callback_on = callback_on.toHash()


	for (var i = 0; i < data.length; i++) {
		var pair = decodeURIComponent(data[i]).split("=")
		var _name = pair[0]
		var value = pair[1]
		if(except != _name in names){
			$("[" + attr + "='" + _name + "']", this).val(value)
			if(callback && ((!callback_on) || (_name in callback_on))){
				callback(_name, value)
			}
		}
	}
}

