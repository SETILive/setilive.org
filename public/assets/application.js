/*
    http://www.JSON.org/json2.js
    2009-09-29

    Public Domain.

    NO WARRANTY EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.

    See http://www.JSON.org/js.html


    This code should be minified before deployment.
    See http://javascript.crockford.com/jsmin.html

    USE YOUR OWN COPY. IT IS EXTREMELY UNWISE TO LOAD CODE FROM SERVERS YOU DO
    NOT CONTROL.


    This file creates a global JSON object containing two methods: stringify
    and parse.

        JSON.stringify(value, replacer, space)
            value       any JavaScript value, usually an object or array.

            replacer    an optional parameter that determines how object
                        values are stringified for objects. It can be a
                        function or an array of strings.

            space       an optional parameter that specifies the indentation
                        of nested structures. If it is omitted, the text will
                        be packed without extra whitespace. If it is a number,
                        it will specify the number of spaces to indent at each
                        level. If it is a string (such as '\t' or '&nbsp;'),
                        it contains the characters used to indent at each level.

            This method produces a JSON text from a JavaScript value.

            When an object value is found, if the object contains a toJSON
            method, its toJSON method will be called and the result will be
            stringified. A toJSON method does not serialize: it returns the
            value represented by the name/value pair that should be serialized,
            or undefined if nothing should be serialized. The toJSON method
            will be passed the key associated with the value, and this will be
            bound to the value

            For example, this would serialize Dates as ISO strings.

                Date.prototype.toJSON = function (key) {
                    function f(n) {
                        // Format integers to have at least two digits.
                        return n < 10 ? '0' + n : n;
                    }

                    return this.getUTCFullYear()   + '-' +
                         f(this.getUTCMonth() + 1) + '-' +
                         f(this.getUTCDate())      + 'T' +
                         f(this.getUTCHours())     + ':' +
                         f(this.getUTCMinutes())   + ':' +
                         f(this.getUTCSeconds())   + 'Z';
                };

            You can provide an optional replacer method. It will be passed the
            key and value of each member, with this bound to the containing
            object. The value that is returned from your method will be
            serialized. If your method returns undefined, then the member will
            be excluded from the serialization.

            If the replacer parameter is an array of strings, then it will be
            used to select the members to be serialized. It filters the results
            such that only members with keys listed in the replacer array are
            stringified.

            Values that do not have JSON representations, such as undefined or
            functions, will not be serialized. Such values in objects will be
            dropped; in arrays they will be replaced with null. You can use
            a replacer function to replace those with JSON values.
            JSON.stringify(undefined) returns undefined.

            The optional space parameter produces a stringification of the
            value that is filled with line breaks and indentation to make it
            easier to read.

            If the space parameter is a non-empty string, then that string will
            be used for indentation. If the space parameter is a number, then
            the indentation will be that many spaces.

            Example:

            text = JSON.stringify(['e', {pluribus: 'unum'}]);
            // text is '["e",{"pluribus":"unum"}]'


            text = JSON.stringify(['e', {pluribus: 'unum'}], null, '\t');
            // text is '[\n\t"e",\n\t{\n\t\t"pluribus": "unum"\n\t}\n]'

            text = JSON.stringify([new Date()], function (key, value) {
                return this[key] instanceof Date ?
                    'Date(' + this[key] + ')' : value;
            });
            // text is '["Date(---current time---)"]'


        JSON.parse(text, reviver)
            This method parses a JSON text to produce an object or array.
            It can throw a SyntaxError exception.

            The optional reviver parameter is a function that can filter and
            transform the results. It receives each of the keys and values,
            and its return value is used instead of the original value.
            If it returns what it received, then the structure is not modified.
            If it returns undefined then the member is deleted.

            Example:

            // Parse the text. Values that look like ISO date strings will
            // be converted to Date objects.

            myData = JSON.parse(text, function (key, value) {
                var a;
                if (typeof value === 'string') {
                    a =
/^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2}(?:\.\d*)?)Z$/.exec(value);
                    if (a) {
                        return new Date(Date.UTC(+a[1], +a[2] - 1, +a[3], +a[4],
                            +a[5], +a[6]));
                    }
                }
                return value;
            });

            myData = JSON.parse('["Date(09/09/2001)"]', function (key, value) {
                var d;
                if (typeof value === 'string' &&
                        value.slice(0, 5) === 'Date(' &&
                        value.slice(-1) === ')') {
                    d = new Date(value.slice(5, -1));
                    if (d) {
                        return d;
                    }
                }
                return value;
            });


    This is a reference implementation. You are free to copy, modify, or
    redistribute.
*/

/*jslint evil: true, strict: false */

/*members "", "\b", "\t", "\n", "\f", "\r", "\"", JSON, "\\", apply,
    call, charCodeAt, getUTCDate, getUTCFullYear, getUTCHours,
    getUTCMinutes, getUTCMonth, getUTCSeconds, hasOwnProperty, join,
    lastIndex, length, parse, prototype, push, replace, slice, stringify,
    test, toJSON, toString, valueOf
*/


// Create a JSON object only if one does not already exist. We create the
// methods in a closure to avoid creating global variables.

if (!this.JSON) {
  this.JSON = {};
}

if (this.module)
  module.exports = JSON;

(function () {
  

    function f(n) {
        // Format integers to have at least two digits.
        return n < 10 ? '0' + n : n;
    }

    if (typeof Date.prototype.toJSON !== 'function') {

        Date.prototype.toJSON = function (key) {

            return isFinite(this.valueOf()) ?
                   this.getUTCFullYear()   + '-' +
                 f(this.getUTCMonth() + 1) + '-' +
                 f(this.getUTCDate())      + 'T' +
                 f(this.getUTCHours())     + ':' +
                 f(this.getUTCMinutes())   + ':' +
                 f(this.getUTCSeconds())   + 'Z' : null;
        };

        String.prototype.toJSON =
        Number.prototype.toJSON =
        Boolean.prototype.toJSON = function (key) {
            return this.valueOf();
        };
    }

    var cx = /[\u0000\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g,
        escapable = /[\\\"\x00-\x1f\x7f-\x9f\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g,
        gap,
        indent,
        meta = {    // table of character substitutions
            '\b': '\\b',
            '\t': '\\t',
            '\n': '\\n',
            '\f': '\\f',
            '\r': '\\r',
            '"' : '\\"',
            '\\': '\\\\'
        },
        rep;


    function quote(string) {

// If the string contains no control characters, no quote characters, and no
// backslash characters, then we can safely slap some quotes around it.
// Otherwise we must also replace the offending characters with safe escape
// sequences.

        escapable.lastIndex = 0;
        return escapable.test(string) ?
            '"' + string.replace(escapable, function (a) {
                var c = meta[a];
                return typeof c === 'string' ? c :
                    '\\u' + ('0000' + a.charCodeAt(0).toString(16)).slice(-4);
            }) + '"' :
            '"' + string + '"';
    }


    function str(key, holder) {

// Produce a string from holder[key].

        var i,          // The loop counter.
            k,          // The member key.
            v,          // The member value.
            length,
            mind = gap,
            partial,
            value = holder[key];

// If the value has a toJSON method, call it to obtain a replacement value.

        if (value && typeof value === 'object' &&
                typeof value.toJSON === 'function') {
            value = value.toJSON(key);
        }

// If we were called with a replacer function, then call the replacer to
// obtain a replacement value.

        if (typeof rep === 'function') {
            value = rep.call(holder, key, value);
        }

// What happens next depends on the value's type.

        switch (typeof value) {
        case 'string':
            return quote(value);

        case 'number':

// JSON numbers must be finite. Encode non-finite numbers as null.

            return isFinite(value) ? String(value) : 'null';

        case 'boolean':
        case 'null':

// If the value is a boolean or null, convert it to a string. Note:
// typeof null does not produce 'null'. The case is included here in
// the remote chance that this gets fixed someday.

            return String(value);

// If the type is 'object', we might be dealing with an object or an array or
// null.

        case 'object':

// Due to a specification blunder in ECMAScript, typeof null is 'object',
// so watch out for that case.

            if (!value) {
                return 'null';
            }

// Make an array to hold the partial results of stringifying this object value.

            gap += indent;
            partial = [];

// Is the value an array?

            if (Object.prototype.toString.apply(value) === '[object Array]') {

// The value is an array. Stringify every element. Use null as a placeholder
// for non-JSON values.

                length = value.length;
                for (i = 0; i < length; i += 1) {
                    partial[i] = str(i, value) || 'null';
                }

// Join all of the elements together, separated with commas, and wrap them in
// brackets.

                v = partial.length === 0 ? '[]' :
                    gap ? '[\n' + gap +
                            partial.join(',\n' + gap) + '\n' +
                                mind + ']' :
                          '[' + partial.join(',') + ']';
                gap = mind;
                return v;
            }

// If the replacer is an array, use it to select the members to be stringified.

            if (rep && typeof rep === 'object') {
                length = rep.length;
                for (i = 0; i < length; i += 1) {
                    k = rep[i];
                    if (typeof k === 'string') {
                        v = str(k, value);
                        if (v) {
                            partial.push(quote(k) + (gap ? ': ' : ':') + v);
                        }
                    }
                }
            } else {

// Otherwise, iterate through all of the keys in the object.

                for (k in value) {
                    if (Object.hasOwnProperty.call(value, k)) {
                        v = str(k, value);
                        if (v) {
                            partial.push(quote(k) + (gap ? ': ' : ':') + v);
                        }
                    }
                }
            }

// Join all of the member texts together, separated with commas,
// and wrap them in braces.

            v = partial.length === 0 ? '{}' :
                gap ? '{\n' + gap + partial.join(',\n' + gap) + '\n' +
                        mind + '}' : '{' + partial.join(',') + '}';
            gap = mind;
            return v;
        }
    }

// If the JSON object does not yet have a stringify method, give it one.

    if (typeof JSON.stringify !== 'function') {
        JSON.stringify = function (value, replacer, space) {

// The stringify method takes a value and an optional replacer, and an optional
// space parameter, and returns a JSON text. The replacer can be a function
// that can replace values, or an array of strings that will select the keys.
// A default replacer method can be provided. Use of the space parameter can
// produce text that is more easily readable.

            var i;
            gap = '';
            indent = '';

// If the space parameter is a number, make an indent string containing that
// many spaces.

            if (typeof space === 'number') {
                for (i = 0; i < space; i += 1) {
                    indent += ' ';
                }

// If the space parameter is a string, it will be used as the indent string.

            } else if (typeof space === 'string') {
                indent = space;
            }

// If there is a replacer, it must be a function or an array.
// Otherwise, throw an error.

            rep = replacer;
            if (replacer && typeof replacer !== 'function' &&
                    (typeof replacer !== 'object' ||
                     typeof replacer.length !== 'number')) {
                throw new Error('JSON.stringify');
            }

// Make a fake root object containing our value under the key of ''.
// Return the result of stringifying the value.

            return str('', {'': value});
        };
    }


// If the JSON object does not yet have a parse method, give it one.

    if (typeof JSON.parse !== 'function') {
        JSON.parse = function (text, reviver) {

// The parse method takes a text and an optional reviver function, and returns
// a JavaScript value if the text is a valid JSON text.

            var j;

            function walk(holder, key) {

// The walk method is used to recursively walk the resulting structure so
// that modifications can be made.

                var k, v, value = holder[key];
                if (value && typeof value === 'object') {
                    for (k in value) {
                        if (Object.hasOwnProperty.call(value, k)) {
                            v = walk(value, k);
                            if (v !== undefined) {
                                value[k] = v;
                            } else {
                                delete value[k];
                            }
                        }
                    }
                }
                return reviver.call(holder, key, value);
            }


// Parsing happens in four stages. In the first stage, we replace certain
// Unicode characters with escape sequences. JavaScript handles many characters
// incorrectly, either silently deleting them, or treating them as line endings.

            cx.lastIndex = 0;
            if (cx.test(text)) {
                text = text.replace(cx, function (a) {
                    return '\\u' +
                        ('0000' + a.charCodeAt(0).toString(16)).slice(-4);
                });
            }

// In the second stage, we run the text against regular expressions that look
// for non-JSON patterns. We are especially concerned with '()' and 'new'
// because they can cause invocation, and '=' because it can cause mutation.
// But just to be safe, we want to reject all unexpected forms.

// We split the second stage into 4 regexp operations in order to work around
// crippling inefficiencies in IE's and Safari's regexp engines. First we
// replace the JSON backslash pairs with '@' (a non-JSON character). Second, we
// replace all simple value tokens with ']' characters. Third, we delete all
// open brackets that follow a colon or comma or that begin the text. Finally,
// we look to see that the remaining characters are only whitespace or ']' or
// ',' or ':' or '{' or '}'. If that is so, then the text is safe for eval.

            if (/^[\],:{}\s]*$/.
test(text.replace(/\\(?:["\\\/bfnrt]|u[0-9a-fA-F]{4})/g, '@').
replace(/"[^"\\\n\r]*"|true|false|null|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?/g, ']').
replace(/(?:^|:|,)(?:\s*\[)+/g, ''))) {

// In the third stage we use the eval function to compile the text into a
// JavaScript structure. The '{' operator is subject to a syntactic ambiguity
// in JavaScript: it can begin a block or an object literal. We wrap the text
// in parens to eliminate the ambiguity.

                j = eval('(' + text + ')');

// In the optional fourth stage, we recursively walk the new structure, passing
// each name/value pair to a reviver function for possible transformation.

                return typeof reviver === 'function' ?
                    walk({'': j}, '') : j;
            }

// If the text is not JSON parseable, then a SyntaxError is thrown.

            throw new SyntaxError('JSON.parse');
        };
    }
}());
(function() {
  var $, Controller, Events, Log, Model, Module, Spine, guid, isArray, isBlank, makeArray, moduleKeywords;
  var __slice = Array.prototype.slice, __indexOf = Array.prototype.indexOf || function(item) {
    for (var i = 0, l = this.length; i < l; i++) {
      if (this[i] === item) return i;
    }
    return -1;
  }, __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  Events = {
    bind: function(ev, callback) {
      var calls, evs, name, _i, _len;
      evs = ev.split(' ');
      calls = this.hasOwnProperty('_callbacks') && this._callbacks || (this._callbacks = {});
      for (_i = 0, _len = evs.length; _i < _len; _i++) {
        name = evs[_i];
        calls[name] || (calls[name] = []);
        calls[name].push(callback);
      }
      return this;
    },
    one: function(ev, callback) {
      return this.bind(ev, function() {
        this.unbind(ev, arguments.callee);
        return callback.apply(this, arguments);
      });
    },
    trigger: function() {
      var args, callback, ev, list, _i, _len, _ref;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      ev = args.shift();
      list = this.hasOwnProperty('_callbacks') && ((_ref = this._callbacks) != null ? _ref[ev] : void 0);
      if (!list) {
        return false;
      }
      for (_i = 0, _len = list.length; _i < _len; _i++) {
        callback = list[_i];
        if (callback.apply(this, args) === false) {
          break;
        }
      }
      return true;
    },
    unbind: function(ev, callback) {
      var cb, i, list, _len, _ref;
      if (!ev) {
        this._callbacks = {};
        return this;
      }
      list = (_ref = this._callbacks) != null ? _ref[ev] : void 0;
      if (!list) {
        return this;
      }
      if (!callback) {
        delete this._callbacks[ev];
        return this;
      }
      for (i = 0, _len = list.length; i < _len; i++) {
        cb = list[i];
        if (cb === callback) {
          list = list.slice();
          list.splice(i, 1);
          this._callbacks[ev] = list;
          break;
        }
      }
      return this;
    }
  };
  Log = {
    trace: true,
    logPrefix: '(App)',
    log: function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      if (!this.trace) {
        return;
      }
      if (typeof console === 'undefined') {
        return;
      }
      if (this.logPrefix) {
        args.unshift(this.logPrefix);
      }
      console.log.apply(console, args);
      return this;
    }
  };
  moduleKeywords = ['included', 'extended'];
  Module = (function() {
    Module.include = function(obj) {
      var included, key, value;
      if (!obj) {
        throw 'include(obj) requires obj';
      }
      for (key in obj) {
        value = obj[key];
        if (__indexOf.call(moduleKeywords, key) < 0) {
          this.prototype[key] = value;
        }
      }
      included = obj.included;
      if (included) {
        included.apply(this);
      }
      return this;
    };
    Module.extend = function(obj) {
      var extended, key, value;
      if (!obj) {
        throw 'extend(obj) requires obj';
      }
      for (key in obj) {
        value = obj[key];
        if (__indexOf.call(moduleKeywords, key) < 0) {
          this[key] = value;
        }
      }
      extended = obj.extended;
      if (extended) {
        extended.apply(this);
      }
      return this;
    };
    Module.proxy = function(func) {
      return __bind(function() {
        return func.apply(this, arguments);
      }, this);
    };
    Module.prototype.proxy = function(func) {
      return __bind(function() {
        return func.apply(this, arguments);
      }, this);
    };
    function Module() {
      if (typeof this.init === "function") {
        this.init.apply(this, arguments);
      }
    }
    return Module;
  })();
  Model = (function() {
    __extends(Model, Module);
    Model.extend(Events);
    Model.records = {};
    Model.attributes = [];
    Model.configure = function() {
      var attributes, name;
      name = arguments[0], attributes = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      this.className = name;
      this.records = {};
      if (attributes.length) {
        this.attributes = attributes;
      }
      this.attributes && (this.attributes = makeArray(this.attributes));
      this.attributes || (this.attributes = []);
      this.unbind();
      return this;
    };
    Model.toString = function() {
      return "" + this.className + "(" + (this.attributes.join(", ")) + ")";
    };
    Model.find = function(id) {
      var record;
      record = this.records[id];
      if (!record) {
        throw 'Unknown record';
      }
      return record.clone();
    };
    Model.exists = function(id) {
      try {
        return this.find(id);
      } catch (e) {
        return false;
      }
    };
    Model.refresh = function(values, options) {
      var record, records, _i, _len;
      if (options == null) {
        options = {};
      }
      if (options.clear) {
        this.records = {};
      }
      records = this.fromJSON(values);
      if (!isArray(records)) {
        records = [records];
      }
      for (_i = 0, _len = records.length; _i < _len; _i++) {
        record = records[_i];
        record.newRecord = false;
        record.id || (record.id = guid());
        this.records[record.id] = record;
      }
      this.trigger('refresh', !options.clear && records);
      return this;
    };
    Model.select = function(callback) {
      var id, record, result;
      result = (function() {
        var _ref, _results;
        _ref = this.records;
        _results = [];
        for (id in _ref) {
          record = _ref[id];
          if (callback(record)) {
            _results.push(record);
          }
        }
        return _results;
      }).call(this);
      return this.cloneArray(result);
    };
    Model.findByAttribute = function(name, value) {
      var id, record, _ref;
      _ref = this.records;
      for (id in _ref) {
        record = _ref[id];
        if (record[name] === value) {
          return record.clone();
        }
      }
      return null;
    };
    Model.findAllByAttribute = function(name, value) {
      return this.select(function(item) {
        return item[name] === value;
      });
    };
    Model.each = function(callback) {
      var key, value, _ref, _results;
      _ref = this.records;
      _results = [];
      for (key in _ref) {
        value = _ref[key];
        _results.push(callback(value.clone()));
      }
      return _results;
    };
    Model.all = function() {
      return this.cloneArray(this.recordsValues());
    };
    Model.first = function() {
      var record;
      record = this.recordsValues()[0];
      return record != null ? record.clone() : void 0;
    };
    Model.last = function() {
      var record, values;
      values = this.recordsValues();
      record = values[values.length - 1];
      return record != null ? record.clone() : void 0;
    };
    Model.count = function() {
      return this.recordsValues().length;
    };
    Model.deleteAll = function() {
      var key, value, _ref, _results;
      _ref = this.records;
      _results = [];
      for (key in _ref) {
        value = _ref[key];
        _results.push(delete this.records[key]);
      }
      return _results;
    };
    Model.destroyAll = function() {
      var key, value, _ref, _results;
      _ref = this.records;
      _results = [];
      for (key in _ref) {
        value = _ref[key];
        _results.push(this.records[key].destroy());
      }
      return _results;
    };
    Model.update = function(id, atts) {
      return this.find(id).updateAttributes(atts);
    };
    Model.create = function(atts) {
      var record;
      record = new this(atts);
      return record.save();
    };
    Model.destroy = function(id) {
      return this.find(id).destroy();
    };
    Model.change = function(callbackOrParams) {
      if (typeof callbackOrParams === 'function') {
        return this.bind('change', callbackOrParams);
      } else {
        return this.trigger('change', callbackOrParams);
      }
    };
    Model.fetch = function(callbackOrParams) {
      if (typeof callbackOrParams === 'function') {
        return this.bind('fetch', callbackOrParams);
      } else {
        return this.trigger('fetch', callbackOrParams);
      }
    };
    Model.toJSON = function() {
      return this.recordsValues();
    };
    Model.fromJSON = function(objects) {
      var value, _i, _len, _results;
      if (!objects) {
        return;
      }
      if (typeof objects === 'string') {
        objects = JSON.parse(objects);
      }
      if (isArray(objects)) {
        _results = [];
        for (_i = 0, _len = objects.length; _i < _len; _i++) {
          value = objects[_i];
          _results.push(new this(value));
        }
        return _results;
      } else {
        return new this(objects);
      }
    };
    Model.fromForm = function() {
      var _ref;
      return (_ref = new this).fromForm.apply(_ref, arguments);
    };
    Model.recordsValues = function() {
      var key, result, value, _ref;
      result = [];
      _ref = this.records;
      for (key in _ref) {
        value = _ref[key];
        result.push(value);
      }
      return result;
    };
    Model.cloneArray = function(array) {
      var value, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = array.length; _i < _len; _i++) {
        value = array[_i];
        _results.push(value.clone());
      }
      return _results;
    };
    Model.prototype.newRecord = true;
    function Model(atts) {
      Model.__super__.constructor.apply(this, arguments);
      this.ids = [];
      if (atts) {
        this.load(atts);
      }
    }
    Model.prototype.isNew = function() {
      return this.newRecord;
    };
    Model.prototype.isValid = function() {
      return !this.validate();
    };
    Model.prototype.validate = function() {};
    Model.prototype.load = function(atts) {
      var key, value;
      for (key in atts) {
        value = atts[key];
        if (typeof this[key] === 'function') {
          this[key](value);
        } else {
          this[key] = value;
        }
      }
      return this;
    };
    Model.prototype.attributes = function() {
      var key, result, _i, _len, _ref;
      result = {};
      _ref = this.constructor.attributes;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        key = _ref[_i];
        if (key in this) {
          if (typeof this[key] === 'function') {
            result[key] = this[key]();
          } else {
            result[key] = this[key];
          }
        }
      }
      if (this.id) {
        result.id = this.id;
      }
      return result;
    };
    Model.prototype.eql = function(rec) {
      var _ref, _ref2;
      return rec && rec.constructor === this.constructor && (rec.id === this.id || (_ref = this.id, __indexOf.call(rec.ids, _ref) >= 0) || (_ref2 = rec.id, __indexOf.call(this.ids, _ref2) >= 0));
    };
    Model.prototype.save = function() {
      var error, record;
      error = this.validate();
      if (error) {
        this.trigger('error', error);
        return false;
      }
      this.trigger('beforeSave');
      record = this.newRecord ? this.create() : this.update();
      this.trigger('save');
      return record;
    };
    Model.prototype.updateAttribute = function(name, value) {
      this[name] = value;
      return this.save();
    };
    Model.prototype.updateAttributes = function(atts) {
      this.load(atts);
      return this.save();
    };
    Model.prototype.changeID = function(id) {
      var records;
      this.ids.push(this.id);
      records = this.constructor.records;
      records[id] = records[this.id];
      delete records[this.id];
      this.id = id;
      return this.save();
    };
    Model.prototype.destroy = function() {
      this.trigger('beforeDestroy');
      delete this.constructor.records[this.id];
      this.destroyed = true;
      this.trigger('destroy');
      this.trigger('change', 'destroy');
      this.unbind();
      return this;
    };
    Model.prototype.dup = function(newRecord) {
      var result;
      result = new this.constructor(this.attributes());
      if (newRecord === false) {
        result.newRecord = this.newRecord;
      } else {
        delete result.id;
      }
      return result;
    };
    Model.prototype.clone = function() {
      return Object.create(this);
    };
    Model.prototype.reload = function() {
      var original;
      if (this.newRecord) {
        return this;
      }
      original = this.constructor.find(this.id);
      this.load(original.attributes());
      return original;
    };
    Model.prototype.toJSON = function() {
      return this.attributes();
    };
    Model.prototype.toString = function() {
      return "<" + this.constructor.className + " (" + (JSON.stringify(this)) + ")>";
    };
    Model.prototype.fromForm = function(form) {
      var key, result, _i, _len, _ref;
      result = {};
      _ref = $(form).serializeArray();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        key = _ref[_i];
        result[key.name] = key.value;
      }
      return this.load(result);
    };
    Model.prototype.exists = function() {
      return this.id && this.id in this.constructor.records;
    };
    Model.prototype.update = function() {
      var clone, records;
      this.trigger('beforeUpdate');
      records = this.constructor.records;
      records[this.id].load(this.attributes());
      clone = records[this.id].clone();
      clone.trigger('update');
      clone.trigger('change', 'update');
      return clone;
    };
    Model.prototype.create = function() {
      var clone, records;
      this.trigger('beforeCreate');
      if (!this.id) {
        this.id = guid();
      }
      this.newRecord = false;
      records = this.constructor.records;
      records[this.id] = this.dup(false);
      clone = records[this.id].clone();
      clone.trigger('create');
      clone.trigger('change', 'create');
      return clone;
    };
    Model.prototype.bind = function(events, callback) {
      var binder, unbinder;
      this.constructor.bind(events, binder = __bind(function(record) {
        if (record && this.eql(record)) {
          return callback.apply(this, arguments);
        }
      }, this));
      this.constructor.bind('unbind', unbinder = __bind(function(record) {
        if (record && this.eql(record)) {
          this.constructor.unbind(events, binder);
          return this.constructor.unbind('unbind', unbinder);
        }
      }, this));
      return binder;
    };
    Model.prototype.trigger = function() {
      var args, _ref;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      args.splice(1, 0, this);
      return (_ref = this.constructor).trigger.apply(_ref, args);
    };
    Model.prototype.unbind = function() {
      return this.trigger('unbind');
    };
    return Model;
  })();
  Controller = (function() {
    __extends(Controller, Module);
    Controller.include(Events);
    Controller.include(Log);
    Controller.prototype.eventSplitter = /^(\S+)\s*(.*)$/;
    Controller.prototype.tag = 'div';
    function Controller(options) {
      this.release = __bind(this.release, this);
      var key, value, _ref;
      this.options = options;
      _ref = this.options;
      for (key in _ref) {
        value = _ref[key];
        this[key] = value;
      }
      if (!this.el) {
        this.el = document.createElement(this.tag);
      }
      this.el = $(this.el);
      if (this.className) {
        this.el.addClass(this.className);
      }
      this.release(function() {
        return this.el.remove();
      });
      if (!this.events) {
        this.events = this.constructor.events;
      }
      if (!this.elements) {
        this.elements = this.constructor.elements;
      }
      if (this.events) {
        this.delegateEvents();
      }
      if (this.elements) {
        this.refreshElements();
      }
      Controller.__super__.constructor.apply(this, arguments);
    }
    Controller.prototype.release = function(callback) {
      if (typeof callback === 'function') {
        return this.bind('release', callback);
      } else {
        return this.trigger('release');
      }
    };
    Controller.prototype.$ = function(selector) {
      return $(selector, this.el);
    };
    Controller.prototype.delegateEvents = function() {
      var eventName, key, match, method, selector, _ref, _results;
      _ref = this.events;
      _results = [];
      for (key in _ref) {
        method = _ref[key];
        if (typeof method !== 'function') {
          method = this.proxy(this[method]);
        }
        match = key.match(this.eventSplitter);
        eventName = match[1];
        selector = match[2];
        _results.push(selector === '' ? this.el.bind(eventName, method) : this.el.delegate(selector, eventName, method));
      }
      return _results;
    };
    Controller.prototype.refreshElements = function() {
      var key, value, _ref, _results;
      _ref = this.elements;
      _results = [];
      for (key in _ref) {
        value = _ref[key];
        _results.push(this[value] = this.$(key));
      }
      return _results;
    };
    Controller.prototype.delay = function(func, timeout) {
      return setTimeout(this.proxy(func), timeout || 0);
    };
    Controller.prototype.html = function(element) {
      this.el.html(element.el || element);
      this.refreshElements();
      return this.el;
    };
    Controller.prototype.append = function() {
      var e, elements, _ref;
      elements = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      elements = (function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = elements.length; _i < _len; _i++) {
          e = elements[_i];
          _results.push(e.el || e);
        }
        return _results;
      })();
      (_ref = this.el).append.apply(_ref, elements);
      this.refreshElements();
      return this.el;
    };
    Controller.prototype.appendTo = function(element) {
      this.el.appendTo(element.el || element);
      this.refreshElements();
      return this.el;
    };
    Controller.prototype.prepend = function() {
      var e, elements, _ref;
      elements = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      elements = (function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = elements.length; _i < _len; _i++) {
          e = elements[_i];
          _results.push(e.el || e);
        }
        return _results;
      })();
      (_ref = this.el).prepend.apply(_ref, elements);
      this.refreshElements();
      return this.el;
    };
    Controller.prototype.replace = function(element) {
      var previous, _ref;
      _ref = [this.el, element.el || element], previous = _ref[0], this.el = _ref[1];
      previous.replaceWith(this.el);
      this.delegateEvents();
      this.refreshElements();
      return this.el;
    };
    return Controller;
  })();
  $ = this.jQuery || this.Zepto || function(element) {
    return element;
  };
  if (typeof Object.create !== 'function') {
    Object.create = function(o) {
      var Func;
      Func = function() {};
      Func.prototype = o;
      return new Func();
    };
  }
  isArray = function(value) {
    return Object.prototype.toString.call(value) === '[object Array]';
  };
  isBlank = function(value) {
    var key;
    if (!value) {
      return true;
    }
    for (key in value) {
      return false;
    }
    return true;
  };
  makeArray = function(args) {
    return Array.prototype.slice.call(args, 0);
  };
  guid = function() {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
      var r, v;
      r = Math.random() * 16 | 0;
      v = c === 'x' ? r : r & 3 | 8;
      return v.toString(16);
    }).toUpperCase();
  };
  Spine = this.Spine = {};
  if (typeof module !== "undefined" && module !== null) {
    module.exports = Spine;
  }
  Spine.version = '1.0.3';
  Spine.isArray = isArray;
  Spine.isBlank = isBlank;
  Spine.$ = $;
  Spine.Events = Events;
  Spine.Log = Log;
  Spine.Module = Module;
  Spine.Controller = Controller;
  Spine.Model = Model;
  Module.extend.call(Spine, Events);
  Module.create = Module.sub = Controller.create = Controller.sub = Model.sub = function(instances, statics) {
    var result;
    result = (function() {
      __extends(result, this);
      function result() {
        result.__super__.constructor.apply(this, arguments);
      }
      return result;
    }).call(this);
    if (instances) {
      result.include(instances);
    }
    if (statics) {
      result.extend(statics);
    }
    if (typeof result.unbind === "function") {
      result.unbind();
    }
    return result;
  };
  Model.setup = function(name, attributes) {
    var Instance;
    if (attributes == null) {
      attributes = [];
    }
    Instance = (function() {
      __extends(Instance, this);
      function Instance() {
        Instance.__super__.constructor.apply(this, arguments);
      }
      return Instance;
    }).call(this);
    Instance.configure.apply(Instance, [name].concat(__slice.call(attributes)));
    return Instance;
  };
  Module.init = Controller.init = Model.init = function(a1, a2, a3, a4, a5) {
    return new this(a1, a2, a3, a4, a5);
  };
  Spine.Class = Module;
}).call(this);
(function() {
  var $;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  }, __slice = Array.prototype.slice, __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  if (typeof Spine === "undefined" || Spine === null) {
    Spine = require('spine');
  }
  $ = Spine.$;
  Spine.Manager = (function() {
    __extends(Manager, Spine.Module);
    Manager.include(Spine.Events);
    function Manager() {
      this.controllers = [];
      this.bind('change', this.change);
      this.add.apply(this, arguments);
    }
    Manager.prototype.add = function() {
      var cont, controllers, _i, _len, _results;
      controllers = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      _results = [];
      for (_i = 0, _len = controllers.length; _i < _len; _i++) {
        cont = controllers[_i];
        _results.push(this.addOne(cont));
      }
      return _results;
    };
    Manager.prototype.addOne = function(controller) {
      controller.bind('active', __bind(function() {
        var args;
        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        return this.trigger.apply(this, ['change', controller].concat(__slice.call(args)));
      }, this));
      controller.bind('release', __bind(function() {
        return this.controllers.splice(this.controllers.indexOf(controller), 1);
      }, this));
      return this.controllers.push(controller);
    };
    Manager.prototype.deactivate = function() {
      return this.trigger.apply(this, ['change', false].concat(__slice.call(arguments)));
    };
    Manager.prototype.change = function() {
      var args, cont, current, _i, _len, _ref, _results;
      current = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      _ref = this.controllers;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        cont = _ref[_i];
        _results.push(cont === current ? cont.activate.apply(cont, args) : cont.deactivate.apply(cont, args));
      }
      return _results;
    };
    return Manager;
  })();
  Spine.Controller.include({
    active: function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      if (typeof args[0] === 'function') {
        this.bind('active', args[0]);
      } else {
        args.unshift('active');
        this.trigger.apply(this, args);
      }
      return this;
    },
    isActive: function() {
      return this.el.hasClass('active');
    },
    activate: function() {
      this.el.addClass('active');
      return this;
    },
    deactivate: function() {
      this.el.removeClass('active');
      return this;
    }
  });
  Spine.Stack = (function() {
    __extends(Stack, Spine.Controller);
    Stack.prototype.controllers = {};
    Stack.prototype.routes = {};
    Stack.prototype.className = 'spine stack';
    function Stack() {
      var key, value, _fn, _ref, _ref2;
      Stack.__super__.constructor.apply(this, arguments);
      this.manager = new Spine.Manager;
      _ref = this.controllers;
      for (key in _ref) {
        value = _ref[key];
        this[key] = new value({
          stack: this
        });
        this.add(this[key]);
      }
      _ref2 = this.routes;
      _fn = __bind(function(key, value) {
        var callback;
        if (typeof value === 'function') {
          callback = value;
        }
        callback || (callback = __bind(function() {
          var _ref3;
          return (_ref3 = this[value]).active.apply(_ref3, arguments);
        }, this));
        return this.route(key, callback);
      }, this);
      for (key in _ref2) {
        value = _ref2[key];
        _fn(key, value);
      }
      if (this["default"]) {
        this[this["default"]].active();
      }
    }
    Stack.prototype.add = function(controller) {
      this.manager.add(controller);
      return this.append(controller);
    };
    return Stack;
  })();
  if (typeof module !== "undefined" && module !== null) {
    module.exports = Spine.Manager;
  }
}).call(this);
(function() {
  var $, Ajax, Base, Collection, Extend, Include, Model, Singleton;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  if (typeof Spine === "undefined" || Spine === null) {
    Spine = require('spine');
  }
  $ = Spine.$;
  Model = Spine.Model;
  Ajax = {
    getURL: function(object) {
      return object && (typeof object.url === "function" ? object.url() : void 0) || object.url;
    },
    enabled: true,
    pending: false,
    requests: [],
    disable: function(callback) {
      this.enabled = false;
      callback();
      return this.enabled = true;
    },
    requestNext: function() {
      var next;
      next = this.requests.shift();
      if (next) {
        return this.request(next);
      } else {
        return this.pending = false;
      }
    },
    request: function(callback) {
      return (callback()).complete(__bind(function() {
        return this.requestNext();
      }, this));
    },
    queue: function(callback) {
      if (!this.enabled) {
        return;
      }
      if (this.pending) {
        this.requests.push(callback);
      } else {
        this.pending = true;
        this.request(callback);
      }
      return callback;
    }
  };
  Base = (function() {
    function Base() {}
    Base.prototype.defaults = {
      contentType: 'application/json',
      dataType: 'json',
      processData: false,
      headers: {
        'X-Requested-With': 'XMLHttpRequest'
      }
    };
    Base.prototype.ajax = function(params, defaults) {
      return $.ajax($.extend({}, this.defaults, defaults, params));
    };
    Base.prototype.queue = function(callback) {
      return Ajax.queue(callback);
    };
    return Base;
  })();
  Collection = (function() {
    __extends(Collection, Base);
    function Collection(model) {
      this.model = model;
      this.errorResponse = __bind(this.errorResponse, this);
      this.recordsResponse = __bind(this.recordsResponse, this);
    }
    Collection.prototype.find = function(id, params) {
      var record;
      record = new this.model({
        id: id
      });
      return this.ajax(params, {
        type: 'GET',
        url: Ajax.getURL(record)
      }).success(this.recordsResponse).error(this.errorResponse);
    };
    Collection.prototype.all = function(params) {
      return this.ajax(params, {
        type: 'GET',
        url: Ajax.getURL(this.model)
      }).success(this.recordsResponse).error(this.errorResponse);
    };
    Collection.prototype.fetch = function(params) {
      var id;
      if (params == null) {
        params = {};
      }
      if (id = params.id) {
        delete params.id;
        return this.find(id, params).success(__bind(function(record) {
          return this.model.refresh(record);
        }, this));
      } else {
        return this.all(params).success(__bind(function(records) {
          return this.model.refresh(records);
        }, this));
      }
    };
    Collection.prototype.recordsResponse = function(data, status, xhr) {
      return this.model.trigger('ajaxSuccess', null, status, xhr);
    };
    Collection.prototype.errorResponse = function(xhr, statusText, error) {
      return this.model.trigger('ajaxError', null, xhr, statusText, error);
    };
    return Collection;
  })();
  Singleton = (function() {
    __extends(Singleton, Base);
    function Singleton(record) {
      this.record = record;
      this.errorResponse = __bind(this.errorResponse, this);
      this.blankResponse = __bind(this.blankResponse, this);
      this.recordResponse = __bind(this.recordResponse, this);
      this.model = this.record.constructor;
    }
    Singleton.prototype.reload = function(params) {
      return this.queue(__bind(function() {
        return this.ajax(params, {
          type: 'GET',
          url: Ajax.getURL(this.record)
        }).success(this.recordResponse).error(this.errorResponse);
      }, this));
    };
    Singleton.prototype.create = function(params) {
      return this.queue(__bind(function() {
        return this.ajax(params, {
          type: 'POST',
          data: JSON.stringify(this.record),
          url: Ajax.getURL(this.model)
        }).success(this.recordResponse).error(this.errorResponse);
      }, this));
    };
    Singleton.prototype.update = function(params) {
      return this.queue(__bind(function() {
        return this.ajax(params, {
          type: 'PUT',
          data: JSON.stringify(this.record),
          url: Ajax.getURL(this.record)
        }).success(this.recordResponse).error(this.errorResponse);
      }, this));
    };
    Singleton.prototype.destroy = function(params) {
      return this.queue(__bind(function() {
        return this.ajax(params, {
          type: 'DELETE',
          url: Ajax.getURL(this.record)
        }).success(this.recordResponse).error(this.errorResponse);
      }, this));
    };
    Singleton.prototype.recordResponse = function(data, status, xhr) {
      this.record.trigger('ajaxSuccess', status, xhr);
      if (Spine.isBlank(data)) {
        return;
      }
      data = this.model.fromJSON(data);
      return Ajax.disable(__bind(function() {
        if (data.id && this.record.id !== data.id) {
          this.record.changeID(data.id);
        }
        return this.record.updateAttributes(data.attributes());
      }, this));
    };
    Singleton.prototype.blankResponse = function(data, status, xhr) {
      return this.record.trigger('ajaxSuccess', status, xhr);
    };
    Singleton.prototype.errorResponse = function(xhr, statusText, error) {
      return this.record.trigger('ajaxError', xhr, statusText, error);
    };
    return Singleton;
  })();
  Model.host = '';
  Include = {
    ajax: function() {
      return new Singleton(this);
    },
    url: function() {
      var base;
      base = Ajax.getURL(this.constructor);
      if (base.charAt(base.length - 1) !== '/') {
        base += '/';
      }
      base += encodeURIComponent(this.id);
      return base;
    }
  };
  Extend = {
    ajax: function() {
      return new Collection(this);
    },
    url: function() {
      return "" + Model.host + "/" + (this.className.toLowerCase()) + "s";
    }
  };
  Model.Ajax = {
    extended: function() {
      this.fetch(this.ajaxFetch);
      this.change(this.ajaxChange);
      this.extend(Extend);
      return this.include(Include);
    },
    ajaxFetch: function() {
      var _ref;
      return (_ref = this.ajax()).fetch.apply(_ref, arguments);
    },
    ajaxChange: function(record, type) {
      return record.ajax()[type]();
    }
  };
  Model.Ajax.Methods = {
    extended: function() {
      this.extend(Extend);
      return this.include(Include);
    }
  };
  Spine.Ajax = Ajax;
  if (typeof module !== "undefined" && module !== null) {
    module.exports = Ajax;
  }
}).call(this);
(function() {
  var $, escapeRegExp, hashStrip, namedParam, splatParam;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  }, __slice = Array.prototype.slice;
  if (typeof Spine === "undefined" || Spine === null) {
    Spine = require('spine');
  }
  $ = Spine.$;
  hashStrip = /^#*/;
  namedParam = /:([\w\d]+)/g;
  splatParam = /\*([\w\d]+)/g;
  escapeRegExp = /[-[\]{}()+?.,\\^$|#\s]/g;
  Spine.Route = (function() {
    __extends(Route, Spine.Module);
    Route.extend(Spine.Events);
    Route.historySupport = "history" in window;
    Route.routes = [];
    Route.options = {
      trigger: true,
      history: false,
      shim: false
    };
    Route.add = function(path, callback) {
      var key, value, _results;
      if (typeof path === "object" && !(path instanceof RegExp)) {
        _results = [];
        for (key in path) {
          value = path[key];
          _results.push(this.add(key, value));
        }
        return _results;
      } else {
        return this.routes.push(new this(path, callback));
      }
    };
    Route.setup = function(options) {
      if (options == null) {
        options = {};
      }
      this.options = $.extend({}, this.options, options);
      if (this.options.history) {
        this.history = this.historySupport && this.options.history;
      }
      if (this.options.shim) {
        return;
      }
      if (this.history) {
        $(window).bind("popstate", this.change);
      } else {
        $(window).bind("hashchange", this.change);
      }
      return this.change();
    };
    Route.unbind = function() {
      if (this.history) {
        return $(window).unbind("popstate", this.change);
      } else {
        return $(window).unbind("hashchange", this.change);
      }
    };
    Route.navigate = function() {
      var args, lastArg, options, path;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      options = {};
      lastArg = args[args.length - 1];
      if (typeof lastArg === "object") {
        options = args.pop();
      } else if (typeof lastArg === "boolean") {
        options.trigger = args.pop();
      }
      options = $.extend({}, this.options, options);
      path = args.join("/");
      if (this.path === path) {
        return;
      }
      this.path = path;
      if (options.trigger) {
        this.matchRoute(this.path, options);
      }
      if (options.shim) {
        return;
      }
      if (this.history) {
        return history.pushState({}, document.title, this.getHost() + this.path);
      } else {
        return window.location.hash = this.path;
      }
    };
    Route.getPath = function() {
      return window.location.pathname;
    };
    Route.getHash = function() {
      return window.location.hash;
    };
    Route.getFragment = function() {
      return this.getHash().replace(hashStrip, "");
    };
    Route.getHost = function() {
      return (document.location + "").replace(this.getPath() + this.getHash(), "");
    };
    Route.change = function() {
      var path;
      path = this.history ? this.getPath() : this.getFragment();
      if (path === this.path) {
        return;
      }
      this.path = path;
      return this.matchRoute(this.path);
    };
    Route.matchRoute = function(path, options) {
      var route, _i, _len, _ref;
      _ref = this.routes;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        route = _ref[_i];
        if (route.match(path, options)) {
          this.trigger("change", route, path);
          return route;
        }
      }
    };
    function Route(path, callback) {
      var match;
      this.path = path;
      this.callback = callback;
      this.names = [];
      if (typeof path === "string") {
        while ((match = namedParam.exec(path)) !== null) {
          this.names.push(match[1]);
        }
        path = path.replace(escapeRegExp, "\\$&").replace(namedParam, "([^\/]*)").replace(splatParam, "(.*?)");
        this.route = new RegExp('^' + path + '$');
      } else {
        this.route = path;
      }
    }
    Route.prototype.match = function(path, options) {
      var i, match, param, params, _len;
      if (options == null) {
        options = {};
      }
      match = this.route.exec(path);
      if (!match) {
        return false;
      }
      options.match = match;
      params = match.slice(1);
      if (this.names.length) {
        for (i = 0, _len = params.length; i < _len; i++) {
          param = params[i];
          options[this.names[i]] = param;
        }
      }
      return this.callback.call(null, options) !== false;
    };
    return Route;
  })();
  Spine.Route.change = Spine.Route.proxy(Spine.Route.change);
  Spine.Controller.include({
    route: function(path, callback) {
      return Spine.Route.add(path, this.proxy(callback));
    },
    routes: function(routes) {
      var key, value, _results;
      _results = [];
      for (key in routes) {
        value = routes[key];
        _results.push(this.route(key, value));
      }
      return _results;
    },
    navigate: function() {
      return Spine.Route.navigate.apply(Spine.Route, arguments);
    }
  });
  if (typeof module !== "undefined" && module !== null) {
    module.exports = Spine.Route;
  }
}).call(this);
(function() {
  if (typeof Spine === "undefined" || Spine === null) {
    Spine = require('spine');
  }
  Spine.Model.Local = {
    extended: function() {
      this.change(this.saveLocal);
      return this.fetch(this.loadLocal);
    },
    saveLocal: function() {
      var result;
      result = JSON.stringify(this);
      return localStorage[this.className] = result;
    },
    loadLocal: function() {
      var result;
      result = localStorage[this.className];
      return this.refresh(result || [], {
        clear: true
      });
    }
  };
  if (typeof module !== "undefined" && module !== null) {
    module.exports = Spine.Model.Local;
  }
}).call(this);
(function() {
  var Collection, Instance, Singleton, singularize, underscore;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  }, __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  if (typeof Spine === "undefined" || Spine === null) {
    Spine = require('spine');
  }
  if (typeof require === "undefined" || require === null) {
    require = (function(value) {
      return eval(value);
    });
  }
  Collection = (function() {
    __extends(Collection, Spine.Module);
    function Collection(options) {
      var key, value;
      if (options == null) {
        options = {};
      }
      for (key in options) {
        value = options[key];
        this[key] = value;
      }
    }
    Collection.prototype.all = function() {
      return this.model.select(__bind(function(rec) {
        return this.associated(rec);
      }, this));
    };
    Collection.prototype.first = function() {
      return this.all()[0];
    };
    Collection.prototype.last = function() {
      var values;
      values = this.all();
      return values[values.length - 1];
    };
    Collection.prototype.find = function(id) {
      var records;
      records = this.model.select(__bind(function(rec) {
        return this.associated(rec) && rec.id === id;
      }, this));
      if (!records[0]) {
        throw 'Unknown record';
      }
      return records[0];
    };
    Collection.prototype.select = function(cb) {
      return this.model.select(__bind(function(rec) {
        return this.associated(rec) && cb(rec);
      }, this));
    };
    Collection.prototype.refresh = function(values) {
      var record, records, value, _i, _j, _len, _len2;
      records = this.all();
      for (_i = 0, _len = records.length; _i < _len; _i++) {
        record = records[_i];
        delete this.model.records[record.id];
      }
      values = this.model.fromJSON(values);
      for (_j = 0, _len2 = values.length; _j < _len2; _j++) {
        value = values[_j];
        value.newRecord = false;
        value[this.fkey] = this.record.id;
        this.model.records[value.id] = value;
      }
      return this.model.trigger('refresh');
    };
    Collection.prototype.create = function(record) {
      record[this.fkey] = this.record.id;
      return this.model.create(record);
    };
    Collection.prototype.associated = function(record) {
      return record[this.fkey] === this.record.id;
    };
    return Collection;
  })();
  Instance = (function() {
    __extends(Instance, Spine.Module);
    function Instance(options) {
      var key, value;
      if (options == null) {
        options = {};
      }
      for (key in options) {
        value = options[key];
        this[key] = value;
      }
    }
    Instance.prototype.exists = function() {
      return this.record[this.fkey] && this.model.exists(this.record[this.fkey]);
    };
    Instance.prototype.update = function(value) {
      return this.record[this.fkey] = value && value.id;
    };
    return Instance;
  })();
  Singleton = (function() {
    __extends(Singleton, Spine.Module);
    function Singleton(options) {
      var key, value;
      if (options == null) {
        options = {};
      }
      for (key in options) {
        value = options[key];
        this[key] = value;
      }
    }
    Singleton.prototype.find = function() {
      return this.record.id && this.model.findByAttribute(this.fkey, this.record.id);
    };
    Singleton.prototype.update = function(value) {
      if (value != null) {
        value[this.fkey] = this.id;
      }
      return value;
    };
    return Singleton;
  })();
  singularize = function(str) {
    return str.replace(/s$/, '');
  };
  underscore = function(str) {
    return str.replace(/::/g, '/').replace(/([A-Z]+)([A-Z][a-z])/g, '$1_$2').replace(/([a-z\d])([A-Z])/g, '$1_$2').replace(/-/g, '_').toLowerCase();
  };
  Spine.Model.extend({
    hasMany: function(name, model, fkey) {
      var association;
      if (fkey == null) {
        fkey = "" + (underscore(this.className)) + "_id";
      }
      association = function(record) {
        if (typeof model === 'string') {
          model = require(model);
        }
        return new Collection({
          name: name,
          model: model,
          record: record,
          fkey: fkey
        });
      };
      return this.prototype[name] = function(value) {
        if (value != null) {
          association(this).refresh(value);
        }
        return association(this);
      };
    },
    belongsTo: function(name, model, fkey) {
      var association;
      if (fkey == null) {
        fkey = "" + (singularize(name)) + "_id";
      }
      association = function(record) {
        if (typeof model === 'string') {
          model = require(model);
        }
        return new Instance({
          name: name,
          model: model,
          record: record,
          fkey: fkey
        });
      };
      this.prototype[name] = function(value) {
        if (value != null) {
          association(this).update(value);
        }
        return association(this).exists();
      };
      return this.attributes.push(fkey);
    },
    hasOne: function(name, model, fkey) {
      var association;
      if (fkey == null) {
        fkey = "" + (underscore(this.className)) + "_id";
      }
      association = function(record) {
        if (typeof model === 'string') {
          model = require(model);
        }
        return new Singleton({
          name: name,
          model: model,
          record: record,
          fkey: fkey
        });
      };
      return this.prototype[name] = function(value) {
        if (value != null) {
          association(this).update(value);
        }
        return association(this).find();
      };
    }
  });
}).call(this);
(function() {

  $.ajaxSetup({
    beforeSend: function(xhr) {
      return xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
    }
  });

  if (window.location.hostname === "0.0.0.0" || window.location.hostname === "localhost") {
    Spine.Model.host = "http://0.0.0.0:3000";
  } else {
    Spine.Model.host = "http://setiMarv.com";
  }

}).call(this);
(function() {

  Spine.Controller.include({
    view: function(name) {
      return JST["app/views/" + name];
    }
  });

}).call(this);
(function() {
  var SpinePusher;

  SpinePusher = {
    included: function() {
      var key, _i, _len, _ref;
      _ref = ['pusher', 'pusherKey', 'pusherChannel'];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        key = _ref[_i];
        this[key] = this.prototype[key];
      }
      this.prototype.pusherChannels = {};
      this.prototype.openPusher();
      return this.prototype.setupPusherBindings(this.defaultChannel, this.pusher);
    },
    setupPusherBindings: function(channel, bindings) {
      var key, method, _results,
        _this = this;
      _results = [];
      for (key in bindings) {
        method = bindings[key];
        if (typeof method === 'string' || 'function') {
          _results.push(this.defaultChannel.bind(key, function(data) {
            return _this.prototype[method](data);
          }));
        } else {
          channel = this.createChannel(key);
          _results.push(this.setupPusherBindings(channel, method));
        }
      }
      return _results;
    },
    openPusher: function() {
      console.log("opening pusher connection");
      if (this.pusherKey) {
        this.pusherConnection = new Pusher(this.pusherKey);
        return this.defaultChannel = this.openChannel(this.pusherChannel);
      } else {
        throw "You need to specify a pusher key";
      }
    },
    openChannel: function(channelName) {
      console.log("opening channel ", channelName);
      return this.pusherChannels[channelName] = this.pusherConnection.subscribe(channelName);
    },
    closeChannel: function(channelName) {
      if (this.pusherChannels[channelName]) {
        this.pusherConnection.unsubscribe(channelName);
        return delete this.pusherChannels[channelName];
      } else {
        throw "No channel " + channelName + " to unsubscribe from";
      }
    }
  };

  window.SpinePusher = SpinePusher;

}).call(this);
(function() {
  var Badge,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; },
    __slice = Array.prototype.slice;

  Badge = (function(_super) {

    __extends(Badge, _super);

    Badge.configure('Badge', 'title', 'description', 'condition', 'logo_url', 'type', 'levels');

    function Badge() {
      this.check_condition = __bind(this.check_condition, this);
      this.maxLevel = __bind(this.maxLevel, this);
      this.testUser = __bind(this.testUser, this);
      var _this = this;
      Badge.__super__.constructor.apply(this, arguments);
      if (User.count === 1) this.testUser(User.first());
      User.bind('refresh', function() {
        console.log("testing user");
        return _this.testUser(User.first());
      });
    }

    Badge.fetch = function() {
      var _this = this;
      return $.getJSON('/badges.json', function(data) {
        var badge, _i, _len;
        for (_i = 0, _len = data.length; _i < _len; _i++) {
          badge = data[_i];
          Badge.create(badge);
        }
        return Badge.trigger('refresh');
      });
    };

    Badge.prototype.testUser = function(user) {
      var level, _i, _len, _ref, _results;
      console.log("really testing user");
      if (this.type === 'one_off') {
        if (this.check_condition(user)) return user.award(this);
      } else {
        _ref = this.levels;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          level = _ref[_i];
          if (this.check_condition(user, level)) {
            _results.push(user.award(this, level));
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      }
    };

    Badge.prototype.maxLevel = function() {
      return this.levels[this.levels.length - 1];
    };

    Badge.prototype.check_condition = function() {
      var condition, level, user;
      user = arguments[0], level = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      condition = this.condition;
      console.log("level is " + level);
      if (level != null) condition.replace(/level/g, level);
      condition = condition + ";";
      console.log(condition);
      return eval(condition);
    };

    return Badge;

  })(Spine.Model);

  window.Badge = Badge;

}).call(this);
(function() {
  var Classification,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  Classification = (function(_super) {

    __extends(Classification, _super);

    function Classification() {
      this.updateSignal = __bind(this.updateSignal, this);
      this.persist = __bind(this.persist, this);
      this.newSignal = __bind(this.newSignal, this);
      Classification.__super__.constructor.apply(this, arguments);
    }

    Classification.configure('Classification', 'subject_id', 'user_id', 'start_time', 'end_time');

    Classification.hasMany('signals', 'Signal');

    Classification.prototype.newSignal = function(x, y, id) {
      return this.currentSignal = this.signals().create({
        timeStart: y,
        freqStart: x,
        observation_id: id
      });
    };

    Classification.prototype.persist = function() {
      this.signals = this.signals().all();
      return $.ajax({
        type: 'POST',
        url: '/classifications/',
        data: this.toJSON,
        dataType: 'json',
        success: function(response) {
          return window.location = '/classify';
        }
      });
    };

    Classification.prototype.updateSignal = function(x, y) {
      this.currentSignal.timeEnd = y;
      this.currentSignal.freqEnd = x;
      return this.currentSignal.save();
    };

    return Classification;

  })(Spine.Model);

  window.Classification = Classification;

}).call(this);
(function() {
  var Signal,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  Signal = (function(_super) {

    __extends(Signal, _super);

    Signal.configure('Signal', 'freqStart', 'freqEnd', 'timeStart', 'timeEnd', 'characterisations', "observation_id");

    Signal.belongsTo("classification", "models/Classification");

    function Signal() {
      Signal.__super__.constructor.apply(this, arguments);
      this.characterisations = [];
    }

    Signal.prototype.gradient = function() {
      return (this.timeEnd - this.timeStart) / (this.freqEnd - this.freqStart);
    };

    Signal.prototype.color = function() {
      var lookup, pair, _i, _len, _ref;
      lookup = {
        "4ecbcc1f40af4716ef000002": "white",
        "4ecbcc1f40af4716ef000003": "red",
        "4ecbcc1f40af4716ef000004": "blue",
        "4ecbcc1f40af4716ef000005": "green"
      };
      _ref = this.characterisations;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        pair = _ref[_i];
        if (pair.question_id === '4ecbcc1f40af4716ef000001') {
          return lookup[pair.answer_id];
        }
      }
    };

    Signal.prototype.signalType = function() {
      var lookup, pair, _i, _len, _ref;
      lookup = {
        "4ecbcc1f40af4716ef000007": "straight",
        "4ecbcc1f40af4716ef000008": "spiral",
        "4ecbcc1f40af4716ef000009": "diagional",
        "4ecbcc1f40af4716ef000010": "broken"
      };
      _ref = this.characterisations;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        pair = _ref[_i];
        if (pair.question_id === '4ecbcc1f40af4716ef000006') {
          return lookup[pair.answer_id];
        }
      }
    };

    Signal.prototype.interp = function(x) {
      return (x - this.freqStart) * this.gradient() + this.timeStart;
    };

    return Signal;

  })(Spine.Model);

  window.Signal = Signal;

}).call(this);
(function() {
  var Source,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  Source = (function(_super) {

    __extends(Source, _super);

    function Source() {
      Source.__super__.constructor.apply(this, arguments);
    }

    Source.configure('Source', 'name', 'coords', 'description', 'type', 'meta', 'zooniverse_id', 'seti_id');

    Source.extend(Spine.Events);

    Source.fetch = function() {
      var _this = this;
      return $.getJSON('/sources.json', function(data) {
        var source, _i, _len;
        for (_i = 0, _len = data.length; _i < _len; _i++) {
          source = data[_i];
          Source.create(source);
        }
        return Source.trigger('refresh', Source.all());
      });
    };

    Source.find_by_seti_id = function(id) {
      return this.select(function(item) {
        return item.seti_id === id;
      });
    };

    Source.prototype.kepler_no = function() {
      return this.name.replace('kplr', "");
    };

    Source.prototype.planetHuntersLink = function() {
      var sph;
      sph = this.zooniverse_id.replace("SSL", "SPH");
      return "http://www.planethunters.org/sources/" + sph;
    };

    return Source;

  })(Spine.Model);

  window.Source = Source;

}).call(this);
(function() {
  var Subject,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  Subject = (function(_super) {

    __extends(Subject, _super);

    function Subject() {
      Subject.__super__.constructor.apply(this, arguments);
    }

    Subject.configure('Subject', 'observations', 'activityId', 'bandwidthMhz', 'bitPix', 'centerFreqMhz', 'endTimeNanos', 'height', 'width');

    Subject.extend(Spine.Events);

    Subject.fetch_from_url = function(url) {
      return $.getJSON(url, function(data) {
        var subject;
        return subject = Subject.create(data);
      });
    };

    Subject.fetch = function() {
      return this.fetch_from_url("next_subject.json");
    };

    Subject.prototype.imageDataForBeam = function(beamNo, targetWidth, targetHeight) {
      var bY, bounds, bx, data, dataPos, dataPosX, dataPosY, dataVal, height, i, imageData, imagePos, width, x, y, _ref;
      imageData = [];
      for (i = 0, _ref = targetWidth * targetHeight; 0 <= _ref ? i <= _ref : i >= _ref; 0 <= _ref ? i++ : i--) {
        imageData[i] = 0;
      }
      data = this.observations[beamNo].data;
      bounds = this.calcBounds();
      width = this.observations[beamNo].width;
      height = this.observations[beamNo].height;
      for (x = 0; 0 <= targetWidth ? x <= targetWidth : x >= targetWidth; 0 <= targetWidth ? x++ : x--) {
        for (y = 0; 0 <= targetHeight ? y <= targetHeight : y >= targetHeight; 0 <= targetHeight ? y++ : y--) {
          imagePos = (y + x * targetWidth) * 4;
          dataPosX = Math.floor((x * 1.0) * width / (targetWidth * 1.0));
          dataPosY = Math.floor((y * 1.0) * height / (targetHeight * 1.0));
          dataVal = 0;
          for (bx = 0; bx <= 0; bx++) {
            for (bY = 0; bY <= 0; bY++) {
              dataPos = (dataPosX + bx) + (dataPosY + bY) * width;
              dataVal += data[dataPos];
            }
          }
          dataVal = this.scaleVal(dataVal, beamNo);
          Subject.setPixel(imageData, targetWidth, x, y, dataVal, dataVal, dataVal, 255);
        }
      }
      return imageData;
    };

    Subject.prototype.imageDataForCombinedBeam = function(targetWidth, targetHeight) {
      var bY, bx, dataB, dataG, dataPos, dataPosX, dataPosY, dataR, i, imageData, imagePos, x, y, _ref;
      imageData = [];
      for (i = 0, _ref = targetWidth * targetHeight; 0 <= _ref ? i <= _ref : i >= _ref; 0 <= _ref ? i++ : i--) {
        imageData.push(0);
      }
      for (x = 0; 0 <= targetWidth ? x <= targetWidth : x >= targetWidth; 0 <= targetWidth ? x++ : x--) {
        for (y = 0; 0 <= targetHeight ? y <= targetHeight : y >= targetHeight; 0 <= targetHeight ? y++ : y--) {
          imagePos = (y + x * targetWidth) * 4;
          dataPosX = Math.floor((x * 1.0) * this.width / (targetWidth * 1.0));
          dataPosY = Math.floor((y * 1.0) * this.height / (targetHeight * 1.0));
          dataR = 0;
          dataG = 0;
          dataB = 0;
          for (bx = -1; bx <= 1; bx++) {
            for (bY = -1; bY <= 1; bY++) {
              dataPos = (dataPosX + bx) + (dataPosY + bY) * this.width;
              dataR += this.beam1[dataPos] / 1.5;
              dataG += this.beam2[dataPos] / 1.5;
              dataB += this.beam3[dataPos] / 1.5;
            }
          }
          dataR = this.scaleVal(dataR, 1);
          dataG = this.scaleVal(dataG, 2);
          dataB = this.scaleVal(dataB, 3);
          Subject.setPixel(imageData, targetWidth, x, y, dataR, dataG, dataB, 255);
        }
      }
      return imageData;
    };

    Subject.prototype.calcBounds = function() {
      var beam, beamNo, max, min, val, _i, _len, _len2, _ref, _ref2;
      if (this.bounds == null) {
        this.bounds = [];
        _ref = this.observations;
        for (beamNo = 0, _len = _ref.length; beamNo < _len; beamNo++) {
          beam = _ref[beamNo];
          max = 0;
          min = 100000000;
          _ref2 = beam.data;
          for (_i = 0, _len2 = _ref2.length; _i < _len2; _i++) {
            val = _ref2[_i];
            if (val > max) max = val;
            if (val < min) min = val;
          }
          this.bounds[beamNo] = [min - (max - min) * 0.0, max];
        }
      }
      return this.bounds;
    };

    Subject.prototype.scaleVal = function(val, beamNo) {
      var bounds;
      bounds = this.calcBounds();
      return (val - bounds[beamNo][0]) * 255 / (bounds[beamNo][1] - bounds[beamNo][0]);
    };

    Subject.setPixel = function(imageData, width, x, y, r, g, b, a) {
      var index;
      index = (x + y * width) * 4;
      imageData[index + 0] = r;
      imageData[index + 1] = g;
      imageData[index + 2] = b;
      return imageData[index + 3] = a;
    };

    return Subject;

  })(Spine.Model);

  window.Subject = Subject;

}).call(this);
(function() {
  var System,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  System = (function(_super) {

    __extends(System, _super);

    System.configure('System', 'planets', 'kepler_id', 'ra', 'dec', 'star_type', 'spec_type', 'eff_temp', 'stellar_rad', "kepler_mag", "zooniverse_id");

    System.prototype.starColors = {
      "O": "#FFFFFF",
      "B": "#FFFFFF",
      "A": "#FFFFFF",
      "F": "#FFFFDF",
      "G": "#FFFFB7",
      "K": "#FFFF9B",
      "M": "#FEB873"
    };

    function System() {
      System.__super__.constructor.apply(this, arguments);
      this.calcLocations(0);
    }

    System.prototype.calcLocations = function(time) {
      var frac, planet, _i, _len, _ref;
      _ref = this.planets;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        planet = _ref[_i];
        frac = (time - planet.t0) / planet.period;
        planet.x = planet.a * Math.cos(frac * 360.0);
        planet.y = planet.a * Math.sin(frac * 360.0);
      }
      return this.planets;
    };

    System.prototype.color = function() {
      return this.starColors[this.spec_type];
    };

    return System;

  })(Spine.Model);

  window.System = System;

}).call(this);
(function() {
  var User,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; },
    __slice = Array.prototype.slice;

  User = (function(_super) {

    __extends(User, _super);

    User.configure('User', 'zooniverse_user_id', 'api_key', 'name', 'favourites', 'badges', 'total_classifications', 'classification_count', 'signal_count', "follow_up_count", "total_follow_ups", "total_signals");

    function User() {
      this.hasBadge = __bind(this.hasBadge, this);
      this.persistBadge = __bind(this.persistBadge, this);
      this.award = __bind(this.award, this);      User.__super__.constructor.apply(this, arguments);
      this.id = this.zooniverse_user_id;
    }

    User.fetch_current_user = function() {
      var _this = this;
      return $.getJSON('/current_user.json', function(data) {
        data.favourites = data.favourite_ids;
        User.create(data);
        return User.trigger('refresh');
      });
    };

    User.prototype.award = function() {
      var badge, data, level;
      badge = arguments[0], level = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      if (!this.hasBadge(badge, level)) {
        if (level.length > 0) {
          level = level[level.length - 1];
        } else {
          level = null;
        }
        data = {
          id: badge.id,
          level: level,
          name: badge.title
        };
        this.badges.push(data);
        User.trigger("badge_awarded", data);
        return this.persistBadge(data);
      }
    };

    User.prototype.persistBadge = function(data) {
      return $.ajax({
        type: 'POST',
        url: '/awardBadge',
        data: data,
        dataType: 'json',
        success: function(response) {
          return console.log("badge ", response);
        }
      });
    };

    User.prototype.hasBadge = function() {
      var badge, level, testBadge, _i, _len, _ref;
      testBadge = arguments[0], level = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      _ref = this.badges;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        badge = _ref[_i];
        if (testBadge.id === badge.id) {
          if (level.length > 0) {
            if (badge.levels.indexOf(level[0])) return true;
          } else {
            return true;
          }
        }
      }
      return false;
    };

    return User;

  })(Spine.Model);

  window.User = User;

}).call(this);
(function() {
  var Workflow,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  Workflow = (function(_super) {

    __extends(Workflow, _super);

    function Workflow() {
      Workflow.__super__.constructor.apply(this, arguments);
    }

    Workflow.configure('Workflow', 'description', 'primary', 'name', 'project', 'version', 'questions');

    Workflow.extend(Spine.Events);

    Workflow.fetch_from_url = function(url) {
      var _this = this;
      return $.getJSON(url, function(data) {
        return console.log(Workflow.create(data[0]));
      });
    };

    Workflow.fetch = function() {
      return this.fetch_from_url("workflow.json");
    };

    return Workflow;

  })(Spine.Model);

  window.Workflow = Workflow;

}).call(this);
(function() {
  var Info,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  Info = (function(_super) {

    __extends(Info, _super);

    Info.prototype.elements = {
      "#time": "time",
      "#extra_controlls": "controls",
      "#done": "done",
      "#current_targets": "targets",
      "#next_beam": "nextBeam"
    };

    Info.prototype.events = {
      "click #done ": "doneClassification",
      "click #talk_yes": "talk",
      "click #talk_no": "dontTalk",
      "click #favourite": "favourite",
      "click #next_beam": "nextBeam",
      "click #clear_signal": "clearSignals"
    };

    function Info() {
      this.nextBeam = __bind(this.nextBeam, this);
      this.favourite = __bind(this.favourite, this);
      this.dontTalk = __bind(this.dontTalk, this);
      this.talk = __bind(this.talk, this);
      this.doneClassification = __bind(this.doneClassification, this);
      this.resetTime = __bind(this.resetTime, this);
      this.updateTime = __bind(this.updateTime, this);
      this.setupTargets = __bind(this.setupTargets, this);      Info.__super__.constructor.apply(this, arguments);
      this.resetTime();
      setInterval(this.updateTime, 100);
      Subject.bind('create', this.setupTargets);
      Source.bind('refresh', this.setupTargets);
    }

    Info.prototype.setupTargets = function() {
      var observation, source, subject, targets, _i, _len, _ref;
      subject = Subject.first();
      if ((subject != null) && Source.count() > 0) {
        targets = [];
        _ref = subject.observations;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          observation = _ref[_i];
          source = Source.find(observation.source_id);
          if (source != null) targets.push(source);
        }
        return new TargetsSlide({
          el: this.targets,
          targets: targets
        });
      }
    };

    Info.prototype.updateTime = function() {
      var mins, secs, timeRemaining;
      timeRemaining = (this.targetTime - Date.now()) / 1000;
      mins = Math.floor(timeRemaining / 60);
      secs = Math.floor(timeRemaining - mins * 60);
      this.time.html("" + (mins < 10 ? "0" : "") + mins + ":" + (secs < 10 ? "0" : "") + secs);
      if (timeRemaining <= 0) return this.resetTime();
    };

    Info.prototype.resetTime = function() {
      return this.targetTime = 1..minutes().fromNow();
    };

    Info.prototype.doneClassification = function() {
      Spine.trigger("dissableSignalDraw");
      Spine.trigger('doneClassification');
      return console.log("rendering talk prompt ");
    };

    Info.prototype.talk = function() {
      window.open('http://talk.setilive.org');
      return Subject.trigger("done");
    };

    Info.prototype.dontTalk = function(e) {
      return Subject.trigger("done");
    };

    Info.prototype.favourite = function() {
      var u;
      u = User.first();
      return u.addFavourite(Subject.first);
    };

    Info.prototype.nextBeam = function() {
      this.nextBeam.replaceWith("<div class='extra_button' id='done'>Done</div>");
      return Spine.trigger("nextBeam");
    };

    return Info;

  })(Spine.Controller);

  window.Info = Info;

}).call(this);
(function() {
  var Notifications,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  Notifications = (function(_super) {

    __extends(Notifications, _super);

    Notifications.prototype.pusherKey = "***REMOVED***";

    Notifications.prototype.pusherChannel = 'telescope';

    Notifications.prototype.pusher = {
      "target_changed": "sourceChange",
      "new_data": "newData",
      "status_changed": "telescopeStatusChange"
    };

    Notifications.prototype.localEvents = {
      "User": {
        "badgeAwarded": "badgeAwarded"
      }
    };

    function Notifications() {
      this.addNotification = __bind(this.addNotification, this);
      this.badgeAwarded = __bind(this.badgeAwarded, this);
      this.telescopeStatusChange = __bind(this.telescopeStatusChange, this);
      this.newData = __bind(this.newData, this);
      this.sourceChange = __bind(this.sourceChange, this);
      this.setupLocal = __bind(this.setupLocal, this);
      this.setupPusher = __bind(this.setupPusher, this);      Notifications.__super__.constructor.apply(this, arguments);
      this.setupLocal();
      if (typeof Pusher !== "undefined" && Pusher !== null) this.setupPusher();
    }

    Notifications.prototype.openPusher = function() {
      if (this.pusherKey) {
        this.pusherConnection = new Pusher(this.pusherKey);
        return this.defaultChannel = this.openChannel(this.pusherChannel);
      } else {
        throw "You need to specify a pusher key";
      }
    };

    Notifications.prototype.openChannel = function(channelName) {
      return this.pusherChannels[channelName] = this.pusherConnection.subscribe(channelName);
    };

    Notifications.prototype.setupPusherBindings = function(channel, bindings) {
      var key, method, _results;
      _results = [];
      for (key in bindings) {
        method = bindings[key];
        if (typeof method === 'string' || 'function') {
          _results.push(this.defaultChannel.bind(key, this[method]));
        } else {
          channel = this.createChannel(key);
          _results.push(this.setupPusherBindings(channel, method));
        }
      }
      return _results;
    };

    Notifications.prototype.setupPusher = function() {
      this.pusherChannels = {};
      this.openPusher();
      return this.setupPusherBindings(this.defaultChannel, this.pusher);
    };

    Notifications.prototype.setupLocal = function() {
      var events, model, response, trigger, _ref, _results;
      _ref = this.localEvents;
      _results = [];
      for (model in _ref) {
        events = _ref[model];
        _results.push((function() {
          var _results2;
          _results2 = [];
          for (trigger in events) {
            response = events[trigger];
            _results2.push(window[model].bind(trigger, this[response]));
          }
          return _results2;
        }).call(this));
      }
      return _results;
    };

    Notifications.prototype.sourceChange = function(data) {
      return this.addNotification('source_change', data);
    };

    Notifications.prototype.newData = function(data) {
      return this.addNotification('new_data', data);
    };

    Notifications.prototype.telescopeStatusChange = function(data) {
      return this.addNotification('telescope_status_changed', data);
    };

    Notifications.prototype.badgeAwarded = function(data) {
      return this.addNotification('badge_awarded', data);
    };

    Notifications.prototype.addNotification = function(type, data) {
      var notification,
        _this = this;
      notification = $(this.view("notifications/" + type + "_notification")(data));
      this.append(notification);
      return $(notification).slideDown(1000, function() {
        return setTimeout(function() {
          return _this.removeNotification(notification);
        }, 4000);
      });
    };

    Notifications.prototype.removeNotification = function(notification) {
      return $(notification).fadeOut(10000, function() {
        return $(notification).remove();
      });
    };

    return Notifications;

  })(Spine.Controller);

  window.Notifications = Notifications;

}).call(this);
(function() {
  var Profile,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  Profile = (function(_super) {

    __extends(Profile, _super);

    Profile.prototype.pagination_no = 8;

    Profile.prototype.inital_collection_type = 'favourites';

    Profile.prototype.events = {
      'click .page': 'selectPage',
      'click .collectionType': 'selectCollectionType'
    };

    function Profile() {
      this.paginate = __bind(this.paginate, this);
      this.selectCollectionType = __bind(this.selectCollectionType, this);
      this.selectPage = __bind(this.selectPage, this);
      this.render = __bind(this.render, this);
      this.gotUser = __bind(this.gotUser, this);      Profile.__super__.constructor.apply(this, arguments);
      User.bind('refresh', this.gotUser);
      Badge.bind('refresh', this.gotUser);
      this.collectionType = 'favourites';
    }

    Profile.prototype.gotUser = function() {
      this.user = User.first();
      this.collectionType = this.inital_collection_type;
      this.paginate();
      return this.render();
    };

    Profile.prototype.render = function() {
      this.html("");
      this.append(this.view('user_stats')(this.user));
      return this.append(this.view('user_profile')({
        user: this.user,
        pagination: this.pagination,
        subjects: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20],
        collectionType: this.collectionType,
        badgeTemplate: this.view('badge')
      }));
    };

    Profile.prototype.selectPage = function(e) {
      e.preventDefault();
      this.pagination.page = $(e.currentTarget).data().id;
      return this.render();
    };

    Profile.prototype.selectCollectionType = function(e) {
      e.preventDefault();
      this.collectionType = $(e.currentTarget).data().collection_type;
      console.log("collection type", $(e.currentTarget).data().collection_type);
      this.paginate();
      return this.render();
    };

    Profile.prototype.paginate = function() {
      var collection;
      collection = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20];
      return this.pagination = {
        page: 0,
        pages: collection.length / this.pagination_no,
        noPerPage: this.pagination_no,
        start: function() {
          return this.page * this.noPerPage;
        },
        end: function() {
          return (this.page + 1) * this.noPerPage;
        },
        menu: function() {
          return JST["app/views/pagination"](this);
        }
      };
    };

    return Profile;

  })(Spine.Controller);

  window.Profile = Profile;

}).call(this);
(function() {
  var Stars,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  Stars = (function(_super) {

    __extends(Stars, _super);

    Stars.prototype.elements = {
      "#field": "field",
      ".star": "stars"
    };

    function Stars() {
      this.drawField = __bind(this.drawField, this);      Stars.__super__.constructor.apply(this, arguments);
      this.paper = Raphael("star_field", "100%", "100%");
      Source.bind("refresh", this.drawField);
    }

    Stars.prototype.updateTarget = function(data) {
      return alert(data);
    };

    Stars.prototype.drawField = function() {
      var star, stars_with_coords, _i, _len, _ref,
        _this = this;
      this.stars = Source.all();
      _ref = this.stars;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        star = _ref[_i];
        this.drawStar(star);
      }
      stars_with_coords = Source.select(function(s) {
        return s.coords[0] !== 0 && s.coords[1] !== 0;
      });
      this.drawIndicator(stars_with_coords[2], "#CDDC28");
      return this.drawIndicator(stars_with_coords[1], "red");
    };

    Stars.prototype.calcBounds = function() {
      var maxDec, maxRa, minDec, minRa, star, _i, _len, _ref;
      minRa = 360;
      minDec = 360;
      maxRa = 0;
      maxDec = 0;
      _ref = this.stars;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        star = _ref[_i];
        if (star.coords[0] < minRa && star.coords[0] > 0) minRa = star.coords[0];
        if (star.coords[0] > maxRa) maxRa = star.coords[0];
        if (star.coords[1] < minDec && star.coords[1] > 0) minDec = star.coords[1];
        if (star.coords[1] > maxDec) maxDec = star.coords[1];
      }
      return this.bounds = [minRa, minDec, maxRa, maxDec];
    };

    Stars.prototype.convertRaDec = function(pos) {
      var new_dec, new_ra;
      if (this.bounds == null) this.calcBounds();
      new_ra = (pos[0] - this.bounds[0]) * this.el.width() / (this.bounds[2] - this.bounds[0]);
      new_dec = (pos[1] - this.bounds[1]) * this.el.height() / (this.bounds[3] - this.bounds[1]);
      return [new_ra, new_dec];
    };

    Stars.prototype.convertMag = function(mag) {
      return mag / 6;
    };

    Stars.prototype.drawStar = function(star) {
      var circle, mag, pos;
      if (!(star.coords[0] === 0 && star.coords[1] === 0)) {
        pos = this.convertRaDec(star.coords);
        mag = this.convertMag(star.meta.kepler_mag);
        circle = this.paper.circle(pos[0], pos[1], mag);
        return circle.attr("fill", "white");
      }
    };

    Stars.prototype.drawIndicator = function(star, color) {
      var i, indicator, indicators, mag, pos, self, _i, _len,
        _this = this;
      pos = this.convertRaDec(star.coords);
      mag = this.convertMag(star.meta.kepler_mag);
      indicators = (function() {
        var _results;
        _results = [];
        for (i = 1; i <= 3; i++) {
          _results.push(this.paper.circle(pos[0], pos[1], mag));
        }
        return _results;
      }).call(this);
      for (_i = 0, _len = indicators.length; _i < _len; _i++) {
        indicator = indicators[_i];
        $(indicator.node).addClass("star_indicator");
      }
      self = this;
      return $.each(indicators, function(index, indicator) {
        var anim;
        indicator.attr("stroke-width", "3");
        indicator.attr("stroke", color);
        indicator.attr("opacity", 0.75);
        indicator.node.setAttribute("class", "indi");
        if (index === indicators.length - 1) {
          anim = Raphael.animation({
            "r": "50",
            "stroke-opacity": "0",
            "stroke-width": 0
          }, 2000, function() {
            indicator.remove();
            return self.drawIndicator(star, color);
          });
        } else {
          anim = Raphael.animation({
            "r": "50",
            "stroke-opacity": "0",
            "stroke-width": 0
          }, 2000, function() {
            return indicator.remove();
          });
        }
        return indicator.animate(anim.delay(index * 400));
      });
    };

    return Stars;

  })(Spine.Controller);

  window.Stars = Stars;

}).call(this);
(function() {
  var Stats,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  Stats = (function(_super) {

    __extends(Stats, _super);

    function Stats() {
      this.render = __bind(this.render, this);      Stats.__super__.constructor.apply(this, arguments);
      if (this.el[0]) setInterval(this.updateStats, 2000);
      this.render();
    }

    Stats.prototype.render = function() {
      var stats;
      stats = {
        people_online: 10,
        total_classifications: 20000,
        classifications_today: 1331,
        classifications_per_min: 23
      };
      return this.html(this.view('global_stats')(stats));
    };

    return Stats;

  })(Spine.Controller);

  window.Stats = Stats;

}).call(this);
(function() {
  var Subjects,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  Subjects = (function(_super) {

    __extends(Subjects, _super);

    Subjects.prototype.elements = {
      ".name": "name",
      "#main-waterfall": "main_beam",
      ".small-waterfall": "sub_beams",
      ".waterfall": "beams",
      "#workflow": 'workflowArea'
    };

    Subjects.prototype.events = {
      'click #main-waterfall': 'markerPlaced',
      'click .small-waterfall': 'selectBeam'
    };

    Subjects.prototype.canDrawSignal = true;

    Subjects.prototype.dragging = false;

    Subjects.prototype.stage = 0;

    Subjects.prototype.current_beam = 0;

    function Subjects() {
      this.saveClassification = __bind(this.saveClassification, this);
      this.drawLine = __bind(this.drawLine, this);
      this.updateLine = __bind(this.updateLine, this);
      this.drawIndicator = __bind(this.drawIndicator, this);
      this.markerPlaced = __bind(this.markerPlaced, this);
      this.wrapBeams = __bind(this.wrapBeams, this);
      this.setUpBeams = __bind(this.setUpBeams, this);
      this.getNextSubject = __bind(this.getNextSubject, this);
      this.dissableSignalDraw = __bind(this.dissableSignalDraw, this);
      this.finalizeSignal = __bind(this.finalizeSignal, this);
      this.enableSignalDraw = __bind(this.enableSignalDraw, this);
      this.selectBeam = __bind(this.selectBeam, this);
      this.render = __bind(this.render, this);
      var _this = this;
      Subjects.__super__.constructor.apply(this, arguments);
      Subject.bind('create', this.render);
      Subject.bind('done', this.saveClassification);
      Spine.bind("enableSignalDraw", this.enableSignalDraw);
      Spine.bind("dissableSignalDraw", this.dissableSignalDraw);
      Workflow.bind("workflowDone", this.enableSignalDraw);
      Workflow.bind("workflowDone", this.finalizeSignal);
      Subject.fetch();
      Spine.bind('nextBeam', function() {
        return _this.selectBeam(_this.current_beam + 1);
      });
      Spine.bind('doneClassification', this.saveClassification);
    }

    Subjects.prototype.render = function(subject) {
      this.current_subject = subject;
      this.html(this.view('waterfalls')(this.current_subject.observations));
      this.current_classification = new Classification({
        subject_id: this.current_subject.id,
        start_time: new Date()
      });
      return this.setUpBeams();
    };

    Subjects.prototype.selectBeam = function(beamNo) {
      if (typeof beamNo === 'object') {
        beamNo.preventDefault();
        beamNo = $(beamNo.currentTarget).data().id;
      }
      $("#main-waterfall .signal_beam_" + this.current_beam).hide();
      this.current_beam = beamNo;
      $(".waterfall").removeClass("selected_beam");
      $("main-waterfall path").hide();
      $("#waterfall-" + this.current_beam).addClass("selected_beam");
      this.drawBeam(this.main_beam.find("canvas"), this.current_subject, this.current_beam);
      return $("#main-waterfall .signal_beam_" + this.current_beam).show();
    };

    Subjects.prototype.enableSignalDraw = function() {
      return this.canDrawSignal = true;
    };

    Subjects.prototype.finalizeSignal = function() {
      var signal;
      signal = this.current_classification.currentSignal;
      $(".signal_" + signal.id).attr("opacity", "0.8");
      $(".signal_line_" + signal.id).attr("opacity", "0.8");
      return $(".signal_" + signal.id).removeClass("draggable");
    };

    Subjects.prototype.dissableSignalDraw = function() {
      return this.canDrawSignal = false;
    };

    Subjects.prototype.getNextSubject = function() {
      return Subject.fetch_from_url('data/test.json');
    };

    Subjects.prototype.setUpBeams = function() {
      var beam, index, _len, _ref;
      this.wrapBeams();
      this.current_beam || (this.current_beam = 0);
      _ref = this.sub_beams;
      for (index = 0, _len = _ref.length; index < _len; index++) {
        beam = _ref[index];
        this.drawBeam($(beam).find("canvas"), this.current_subject, index);
      }
      return this.selectBeam(this.current_beam);
    };

    Subjects.prototype.wrapBeams = function() {
      var beam, overlay, _i, _len, _ref;
      this.overlays = (function() {
        var _i, _len, _ref, _results;
        _ref = this.beams;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          beam = _ref[_i];
          _results.push(Raphael($(beam).attr("id"), '100%', '100%'));
        }
        return _results;
      }).call(this);
      _ref = this.overlays;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        overlay = _ref[_i];
        $(overlay.canvas).css("z-index", "10000");
      }
      return new Workflows({
        el: $(this.workflowArea)
      });
    };

    Subjects.prototype.drawBeam = function(target, subject, beam_no) {
      var ctx, data, i, imageData, targetHeight, targetWidth, _ref;
      ctx = target[0].getContext('2d');
      targetWidth = $(target[0]).width();
      targetHeight = $(target[0]).height();
      target[0].width = targetWidth;
      target[0].height = targetHeight;
      imageData = ctx.getImageData(0, 0, targetWidth, targetHeight);
      data = subject.imageDataForBeam(beam_no, targetWidth, targetHeight);
      for (i = 0, _ref = data.length; 0 <= _ref ? i <= _ref : i >= _ref; 0 <= _ref ? i++ : i--) {
        imageData.data[i] = data[i];
      }
      return ctx.putImageData(imageData, 0, 0);
    };

    Subjects.prototype.drawCombinedBeam = function(target, subject) {
      var ctx, data, i, imageData, targetHeight, targetWidth, _ref;
      ctx = target[0].getContext('2d');
      targetWidth = $(target[0]).width();
      targetHeight = $(target[0]).height();
      target[0].width = targetWidth;
      target[0].height = targetHeight;
      imageData = ctx.getImageData(0, 0, targetWidth, targetHeight);
      data = subject.imageDataForCombinedBeam(targetWidth, targetHeight);
      for (i = 0, _ref = data.length; 0 <= _ref ? i <= _ref : i >= _ref; 0 <= _ref ? i++ : i--) {
        imageData.data[i] = data[i];
      }
      return ctx.putImageData(imageData, 0, 0);
    };

    Subjects.prototype.markerPlaced = function(e) {
      var dx, dy;
      if (this.canDrawSignal && !this.dragging) {
        dx = e.offsetX * 1.0 / this.main_beam.width() * 1.0;
        dy = e.offsetY * 1.0 / this.main_beam.height() * 1.0;
        if (this.stage === 0) {
          this.current_classification.newSignal(dx, dy, this.current_subject.observations[this.current_beam].id);
        } else {
          this.current_classification.updateSignal(dx, dy);
        }
        return this.drawIndicator(dx, dy);
      }
    };

    Subjects.prototype.drawIndicator = function(x, y) {
      var beam, canvas, circle, radius, self, signal, _i, _len, _ref;
      signal = this.current_classification.currentSignal;
      _ref = [this.overlays[0]];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        beam = _ref[_i];
        canvas = $(beam.canvas);
        radius = canvas.height() * 0.017;
        circle = beam.circle(x * canvas.width(), y * canvas.height(), radius);
        circle.attr({
          "stroke": "#CDDC28",
          "stroke-width": "2",
          "fill": "purple",
          "fill-opacity": "1",
          "cursor": "move"
        });
        self = this;
        circle.drag(function(x, y) {
          if ($(this.node).hasClass("draggable")) {
            this.attr({
              cx: this.startX + x,
              cy: this.startY + y
            });
            if ($(this.node).hasClass("stage_0")) {
              signal.updateAttributes({
                "freqStart": this.attr("cx") / canvas.width(),
                "timeStart": this.attr("cy") / canvas.height()
              });
            } else {
              signal.updateAttributes({
                "freqEnd": this.attr("cx") / canvas.width(),
                "timeEnd": this.attr("cy") / canvas.height()
              });
            }
            return self.updateLine(signal);
          }
        }, function() {
          if ($(this.node).hasClass("draggable")) {
            this.startX = this.attr("cx");
            return this.startY = this.attr("cy");
          }
        });
        $(circle.node).addClass("signal_" + signal.id);
        $(circle.node).addClass("stage_" + this.stage);
        $(circle.node).addClass("signal_beam_" + this.current_beam);
        $(circle.node).addClass("draggable");
      }
      this.stage += 1;
      if (this.stage === 2) {
        this.drawLine(signal);
        this.canDrawSignal = false;
        return Spine.trigger("startWorkflow", signal);
      }
    };

    Subjects.prototype.updateLine = function(signal) {
      $(".signal_line_" + signal.id).remove();
      return this.drawLine(signal);
    };

    Subjects.prototype.drawLine = function(signal) {
      var beam, canvas, endX, endY, line, startX, startY, _i, _len, _ref;
      _ref = [this.overlays[0], this.overlays[this.current_beam + 1]];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        beam = _ref[_i];
        canvas = $(beam.canvas);
        startY = signal.interp(0) * canvas.height();
        endY = signal.interp(1) * canvas.height();
        startX = 0;
        endX = canvas.width();
        line = beam.path("M" + startX + "," + startY + "l" + (endX - startX) + "," + (endY - startY) + "z");
        line.attr({
          stroke: "#CDDC28",
          "stroke-width": 2,
          "stroke-opacity": 1
        });
        $(line.node).addClass("signal_line_" + signal.id);
        $(line.node).addClass("signal_beam_" + this.current_beam);
      }
      return this.stage = 0;
    };

    Subjects.prototype.saveClassification = function() {
      return this.current_classification.persist();
    };

    return Subjects;

  })(Spine.Controller);

  window.Subjects = Subjects;

}).call(this);
(function() {
  var SystemViewer,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  SystemViewer = (function(_super) {

    __extends(SystemViewer, _super);

    SystemViewer.prototype.sizeScale = 0.03;

    SystemViewer.prototype.distScale = 1;

    SystemViewer.prototype.time = 0;

    function SystemViewer() {
      this.updatePlanets = __bind(this.updatePlanets, this);      SystemViewer.__super__.constructor.apply(this, arguments);
      this.expanded = false;
      this.system = new System(this.source.meta);
      this.system.planets = this.source.meta.planets;
      this.render();
      setInterval(this.updatePlanets, 30);
    }

    SystemViewer.prototype.render = function() {
      this.setUpSVGTopDown();
      if (this.expanded) {
        this.expand();
        return this.setUpSVGProfile();
      }
    };

    SystemViewer.prototype.updatePlanets = function() {
      this.time += 0.0009;
      return this.update();
    };

    SystemViewer.prototype.setUpSVGTopDown = function() {
      var planet, _i, _len, _ref, _results;
      this.context = Raphael(this.el.attr("id"), "100%", "100%");
      this.localDistScale = this.distScale * this.el.width();
      this.localSizeScale = this.sizeScale * this.el.height();
      this.cent_x = this.el.width() / 2;
      this.cent_y = this.el.height() / 2;
      this.drawStar();
      _ref = this.system.planets;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        planet = _ref[_i];
        _results.push(this.drawPlanet(planet));
      }
      return _results;
    };

    SystemViewer.prototype.drawPlanet = function(planet) {
      var circle, orbit, r, x, y;
      r = planet.radius * this.localSizeScale / 5.0;
      x = this.cent_x + planet.x * this.localDistScale;
      y = this.cent_y + planet.y * this.localDistScale;
      orbit = this.context.circle(this.cent_x, this.cent_y, planet.a * this.localDistScale);
      circle = this.context.circle(x, y, r);
      circle.attr({
        fill: "black",
        stroke: "white",
        "stroke-width": 3
      });
      $(circle.node).attr("id", "planet_" + (planet.kio.replace('.', '_')));
      return orbit.attr({
        stroke: "white",
        "stroke-width": 3
      });
    };

    SystemViewer.prototype.drawStar = function(star) {
      var circle;
      circle = this.context.circle(this.cent_x, this.cent_y, this.system.stellar_rad * this.localSizeScale);
      circle.glow({
        color: "white",
        width: 30,
        opacity: 0.25,
        fill: true
      });
      return circle.attr({
        fill: "#AAAAAA",
        stroke: "white",
        "stroke-width": 3
      });
    };

    SystemViewer.prototype.update = function() {
      var planet, x, y, _i, _len, _ref, _results;
      this.system.calcLocations(this.time);
      _ref = this.system.planets;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        planet = _ref[_i];
        x = this.cent_x + planet.x * this.localDistScale;
        y = this.cent_y + planet.y * this.localDistScale;
        _results.push($("#planet_" + (planet.kio.replace('.', '_'))).attr({
          cx: x,
          cy: y
        }));
      }
      return _results;
    };

    return SystemViewer;

  })(Spine.Controller);

  window.SystemViewer = SystemViewer;

}).call(this);
(function() {
  var TargetsSlide,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  TargetsSlide = (function(_super) {

    __extends(TargetsSlide, _super);

    TargetsSlide.prototype.events = {
      'click .dot': 'selectTarget',
      'click #target': 'showTarget'
    };

    function TargetsSlide(args) {
      this.showTarget = __bind(this.showTarget, this);
      this.selectTarget = __bind(this.selectTarget, this);
      this.render = __bind(this.render, this);      TargetsSlide.__super__.constructor.apply(this, arguments);
      this.targets = args.targets;
      this.current_target = this.targets[0];
      this.render();
    }

    TargetsSlide.prototype.render = function() {
      return this.html(this.view('targets_slide_show')({
        targets: this.targets,
        current_target: this.current_target
      }));
    };

    TargetsSlide.prototype.selectTarget = function(e) {
      var target, targetId;
      targetId = $(e.currentTarget).data().id;
      this.current_target = ((function() {
        var _i, _len, _ref, _results;
        _ref = this.targets;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          target = _ref[_i];
          if (target.id === targetId) _results.push(target);
        }
        return _results;
      }).call(this))[0];
      return this.render();
    };

    TargetsSlide.prototype.showTarget = function(e) {
      return window.open("/sources/" + this.current_target.id);
    };

    return TargetsSlide;

  })(Spine.Controller);

  window.TargetsSlide = TargetsSlide;

}).call(this);
(function() {
  var TargetsIndex, TargetsShow,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  TargetsShow = (function(_super) {

    __extends(TargetsShow, _super);

    TargetsShow.prototype.events = {
      'click #back_button': 'goBack',
      'click #planethunters_button': 'openPlanetHunters'
    };

    TargetsShow.prototype.elements = {
      '#star_vis': "visualization"
    };

    function TargetsShow() {
      this.openPlanetHunters = __bind(this.openPlanetHunters, this);
      this.render = __bind(this.render, this);
      this.goBack = __bind(this.goBack, this);
      this.setupSource = __bind(this.setupSource, this);      TargetsShow.__super__.constructor.apply(this, arguments);
      this.source_id = window.location.pathname.split("/")[2];
      Source.bind('refresh', this.setupSource);
    }

    TargetsShow.prototype.setupSource = function() {
      this.source = Source.find(this.source_id);
      return this.render();
    };

    TargetsShow.prototype.goBack = function() {
      return window.location = '/sources/';
    };

    TargetsShow.prototype.render = function() {
      this.html(this.view('target_show')(this.source));
      return new SystemViewer({
        el: this.visualization,
        source: this.source
      });
    };

    TargetsShow.prototype.openPlanetHunters = function() {
      return window.open(this.source.planetHuntersLink(), '_newtab');
    };

    return TargetsShow;

  })(Spine.Controller);

  TargetsIndex = (function(_super) {

    __extends(TargetsIndex, _super);

    TargetsIndex.prototype.events = {
      'click .page_link': 'selectPage',
      'click .source': 'selectSource'
    };

    TargetsIndex.prototype.perPage = 12;

    function TargetsIndex() {
      this.selectSource = __bind(this.selectSource, this);
      this.selectPage = __bind(this.selectPage, this);
      this.render = __bind(this.render, this);      TargetsIndex.__super__.constructor.apply(this, arguments);
      this.page = 0;
      Source.bind('refresh', this.render);
    }

    TargetsIndex.prototype.render = function() {
      var sources;
      sources = Source.all();
      this.pages = Source.count() / this.perPage;
      return this.html(this.view('target_index')({
        page: this.page,
        pages: this.pages,
        perPage: this.perPage,
        sources: sources
      }));
    };

    TargetsIndex.prototype.selectPage = function(e) {
      e.preventDefault();
      this.page = $(e.currentTarget).data().id;
      return this.render();
    };

    TargetsIndex.prototype.selectSource = function(e) {
      return window.location = "/sources/" + ($(e.currentTarget).data().id);
    };

    return TargetsIndex;

  })(Spine.Controller);

  window.TargetsIndex = TargetsIndex;

  window.TargetsShow = TargetsShow;

}).call(this);
(function() {
  var Workflows,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  Workflows = (function(_super) {

    __extends(Workflows, _super);

    Workflows.prototype.elements = {
      ".answer_list": "answer_list",
      ".question": "question"
    };

    Workflows.prototype.events = {
      "click .answer": 'selectAnswer'
    };

    function Workflows() {
      this.selectAnswer = __bind(this.selectAnswer, this);
      this.startWorkflow = __bind(this.startWorkflow, this);
      this.render = __bind(this.render, this);      Workflows.__super__.constructor.apply(this, arguments);
      Spine.bind("startWorkflow", this.startWorkflow);
      this.render();
      this.el.hide();
    }

    Workflows.prototype.render = function() {
      return this.html(this.view('workflow')({
        question: this.current_question,
        helpers: this.helpers
      }));
    };

    Workflows.prototype.startWorkflow = function(signal) {
      var x, y;
      x = this.el.parent().width() * (Math.max(signal.freqEnd, signal.freqStart)) + 20;
      y = this.el.parent().height() * (signal.timeEnd + signal.timeStart) / 2.0 - this.el.height() / 2.0;
      this.el.css({
        top: y,
        left: x
      });
      this.el.show();
      this.currentSignal = signal;
      return this.setUpQuestion(Workflow.first().questions[0]._id);
    };

    Workflows.prototype.setUpQuestion = function(question_id) {
      var question, workflow, _i, _len, _ref;
      if (question_id == null) question_id = -1;
      workflow = Workflow.first();
      if (question_id === -1) question_id = workflow.questions[0]._id;
      _ref = workflow.questions;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        question = _ref[_i];
        if (question._id === question_id) this.current_question = question;
      }
      return this.render();
    };

    Workflows.prototype.selectAnswer = function(event) {
      var answer;
      answer = $(event.currentTarget).data();
      this.currentSignal.characterisations.push({
        question_id: this.current_question._id,
        answer_id: answer.id
      });
      if (answer.leads_to) {
        this.setUpQuestion(answer.leads_to);
      } else {
        this.doneWorkflow();
      }
      return Spine.trigger("updateSignal", this.currentSignal);
    };

    Workflows.prototype.doneWorkflow = function() {
      this.answer_list.html("");
      this.el.hide();
      return Workflow.trigger('workflowDone', 'done');
    };

    Workflows.prototype.helpers = {
      answer_icon: function(answer) {
        var lookup;
        lookup = {
          "red": "<div class='answer-icon' style='display:inline-block; width:10px; height:10px; background-color: red'></div>",
          "white": "<div class='answer-icon' style='display:inline-block; width:10px; height:10px; background-color:white'></div>",
          "blue": "<div class= 'answer-icon' style='display:inline-block; width:10px; height:10px; background-color:blue'></div>",
          "green": "<div class= 'answer-icon' style='display:inline-block; width:10px; height:10px; background-color:green'></div>",
          "spiral": "<img src='assets/question_icons/spiral.png' class ='answer-icon' style='display: inline-block'></img>",
          "diagonal": "<img src='assets/question_icons/diagonal.png' class ='answer-icon' style='display: inline-block'></img>",
          "broken": "<img src='assets/question_icons/broken.png' class ='answer-icon' style='display: inline-block'></img>",
          "straight": "<img src='assets/question_icons/straight.png' class ='answer-icon' style='display: inline-block'></img>"
        };
        return lookup[answer.name.toLowerCase()];
      }
    };

    return Workflows;

  })(Spine.Controller);

  window.Workflows = Workflows;

}).call(this);
(function() {
  var Scene,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  Scene = (function(_super) {

    __extends(Scene, _super);

    Scene.instances = [];

    Scene.prototype.active = false;

    Scene.prototype.enterDuration = 0;

    Scene.prototype.exitDuration = 0;

    Scene.prototype.timeouts = null;

    function Scene() {
      this.defer = __bind(this.defer, this);
      this.exit = __bind(this.exit, this);
      this.stopAnimating = __bind(this.stopAnimating, this);
      this.deactivate = __bind(this.deactivate, this);
      this.enter = __bind(this.enter, this);
      this.activate = __bind(this.activate, this);
      this.reset = __bind(this.reset, this);      Scene.instances.push(this);
      Scene.__super__.constructor.apply(this, arguments);
      this.timeouts = {};
      this.el.data('scene', this);
      this.reset();
    }

    Scene.prototype.reset = function() {};

    Scene.prototype.activate = function() {
      var activeSibling;
      this.el.addClass('active');
      this.active = true;
      activeSibling = this.el.siblings('.active').data('scene');
      if (activeSibling != null) activeSibling.deactivate();
      return setTimeout(this.enter, (activeSibling != null ? activeSibling.exitDuration : void 0) || 0);
    };

    Scene.prototype.enter = function() {};

    Scene.prototype.deactivate = function() {
      this.stopAnimating();
      this.active = false;
      this.el.removeClass('active');
      setTimeout(this.reset, this.exitDuration + 1000);
      return setTimeout(this.exit, 0);
    };

    Scene.prototype.stopAnimating = function() {
      var el, name, timeout, _ref, _ref2, _results;
      this.$(':animated').stop(true, true);
      _ref = this.elements;
      for (name in _ref) {
        el = _ref[name];
        this[el].clearQueue();
      }
      _ref2 = this.timeouts;
      _results = [];
      for (name in _ref2) {
        timeout = _ref2[name];
        _results.push(clearTimeout(timeout));
      }
      return _results;
    };

    Scene.prototype.exit = function() {};

    Scene.prototype.defer = function(name, wait, fn) {
      return this.timeouts[name] = setTimeout(this.proxy(fn), wait);
    };

    return Scene;

  })(Spine.Controller);

  window.Scene = Scene;

  window.scenes = Scene.instances;

}).call(this);
(function() {
  var Ata,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  Ata = (function(_super) {

    __extends(Ata, _super);

    function Ata() {
      this.exit = __bind(this.exit, this);
      this.enter = __bind(this.enter, this);
      this.reset = __bind(this.reset, this);
      Ata.__super__.constructor.apply(this, arguments);
    }

    Ata.prototype.exitDuration = 1000;

    Ata.prototype.elements = {
      '.mountain': 'mountain',
      '.far.scope': 'farScopes',
      '.first.far.scope': 'firstFarScope',
      '.second.far.scope': 'secondFarScope',
      '.third.far.scope': 'thirdFarScope',
      '.near.scope': 'nearScopes',
      '.first.near.scope': 'firstNearScope',
      '.second.near.scope': 'secondNearScope'
    };

    Ata.prototype.reset = function() {
      this.mountain.css({
        opacity: 0,
        transform: 'translateX(200px)'
      }, 2000);
      this.farScopes.css({
        opacity: 0,
        transform: 'translateX(400px)'
      }, 2000);
      return this.nearScopes.css({
        opacity: 0,
        transform: 'translateX(800px)'
      }, 2000);
    };

    Ata.prototype.enter = function() {
      this.mountain.animate({
        opacity: 1,
        transform: 'translateX(0)'
      }, 1000);
      this.farScopes.animate({
        opacity: 1,
        transform: 'translateX(0)'
      }, 1000);
      return this.nearScopes.animate({
        opacity: 1,
        transform: 'translateX(0)'
      }, 1000);
    };

    Ata.prototype.exit = function() {
      this.mountain.animate({
        opacity: 0,
        transform: 'translateX(-200px)'
      }, 1000);
      this.farScopes.animate({
        opacity: 0,
        transform: 'translateX(-400px)'
      }, 1000);
      return this.nearScopes.animate({
        opacity: 0,
        transform: 'translateX(-800px)'
      }, 1000);
    };

    return Ata;

  })(Scene);

  window.Ata = Ata;

}).call(this);
(function() {
  var Doppler,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  Doppler = (function(_super) {

    __extends(Doppler, _super);

    function Doppler() {
      this.exit = __bind(this.exit, this);
      this.towerPulse = __bind(this.towerPulse, this);
      this.satellitePulse = __bind(this.satellitePulse, this);
      this.satelliteGoesRight = __bind(this.satelliteGoesRight, this);
      this.enter = __bind(this.enter, this);
      this.reset = __bind(this.reset, this);
      Doppler.__super__.constructor.apply(this, arguments);
    }

    Doppler.prototype.exitDuration = 1000;

    Doppler.prototype.satelliteDuration = 30000;

    Doppler.prototype.elements = {
      '.mountain': 'mountain',
      '.satelliteGroup': 'satelliteGroup',
      '.satellite': 'satellite',
      '.waves.for-satellite': 'satelliteWaves',
      '.tower': 'tower',
      '.waves.for-tower': 'towerWaves',
      '.telescope': 'telescope'
    };

    Doppler.prototype.reset = function() {
      this.mountain.add(this.tower).add(this.towerWaves).css({
        opacity: 0,
        transform: 'translateX(200px)'
      });
      this.telescope.css({
        opacity: 0,
        transform: 'translateX(800px)'
      });
      return this.satelliteGroup.css({
        left: '',
        opacity: 0
      });
    };

    Doppler.prototype.enter = function() {
      this.mountain.add(this.tower).add(this.towerWaves).add(this.telescope).animate({
        opacity: 1,
        transform: ''
      });
      this.towerPulse();
      this.satelliteGoesRight();
      return this.satellitePulse();
    };

    Doppler.prototype.satelliteGoesRight = function() {
      var _this = this;
      this.satelliteGroup.css({
        left: '',
        opacity: 0
      });
      this.satelliteGroup.animate({
        opacity: 1
      }, {
        duration: 2500,
        queue: false
      });
      this.defer('satelliteFadeOut', this.satelliteDuration - 2500, function() {
        return _this.satelliteGroup.animate({
          opacity: 0
        }, {
          duration: 2500,
          queue: false
        });
      });
      this.satelliteGroup.animate({
        transform: 'translateY(-50%)'
      }, {
        duration: this.satelliteDuration / 2,
        queue: false
      });
      this.defer('satelliteFall', this.satelliteDuration / 2, function() {
        return _this.satelliteGroup.animate({
          transform: ''
        }, {
          duration: _this.satelliteDuration / 2,
          queue: false
        });
      });
      this.satelliteGroup.animate({
        left: '+=90%'
      }, {
        duration: this.satelliteDuration,
        queue: false
      });
      return this.defer('satelliteMove', this.satelliteDuration + 1000, this.satelliteGoesRight);
    };

    Doppler.prototype.satellitePulse = function() {
      var groupLeft, percentLeft, period;
      period = 1500;
      groupLeft = this.satelliteGroup.css('left');
      percentLeft = parseFloat(groupLeft);
      if (~groupLeft.indexOf('px')) {
        percentLeft /= this.el.width();
      } else {
        percentLeft /= 100;
      }
      if ((0.1 < percentLeft && percentLeft < 0.3)) period /= 2;
      this.satelliteWaves.animate({
        opacity: 1
      }, 200);
      this.satelliteWaves.animate({
        opacity: 0
      }, 300);
      return this.defer('satellitePulse', period, this.satellitePulse);
    };

    Doppler.prototype.towerPulse = function() {
      this.towerWaves.animate({
        opacity: 1
      }, 200);
      this.towerWaves.animate({
        opacity: 0
      }, 300);
      return this.defer('towerPulse', 1500, this.towerPulse);
    };

    Doppler.prototype.exit = function() {
      this.mountain.add(this.tower).add(this.towerWaves).animate({
        opacity: 0,
        transform: 'translateX(-200px)'
      }, 1000);
      this.telescope.animate({
        opacity: 0,
        transform: 'translateX(-800px)'
      }, 1000);
      return this.satelliteGroup.css({
        opacity: 0
      });
    };

    return Doppler;

  })(Scene);

  window.Doppler = Doppler;

}).call(this);
(function() {
  var HabitableZone,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  HabitableZone = (function(_super) {

    __extends(HabitableZone, _super);

    function HabitableZone() {
      this.exit = __bind(this.exit, this);
      this.enter = __bind(this.enter, this);
      this.reset = __bind(this.reset, this);
      HabitableZone.__super__.constructor.apply(this, arguments);
    }

    HabitableZone.prototype.exitDuration = 1000;

    HabitableZone.prototype.elements = {
      '.outer.ring': 'outerRing',
      '.inner.ring': 'innerRing',
      '.star': 'star',
      '.planet': 'planet',
      '.flag': 'flags',
      '.flag.for-star': 'starFlag',
      '.flag.for-planet': 'planetFlag',
      '.flag.for-zone': 'zoneFlag'
    };

    HabitableZone.prototype.reset = function() {
      this.outerRing.add(this.innerRing).add(this.star).css({
        opacity: 0,
        transform: 'translateY(-200%)'
      });
      return this.planet.add(this.flags).css({
        opacity: 0,
        transform: 'translateY(-400%)'
      });
    };

    HabitableZone.prototype.enter = function() {
      this.outerRing.animate({
        opacity: 1,
        transform: 'translateY(20%)'
      });
      this.outerRing.animate({
        transform: 'translateY(-10%)'
      });
      this.outerRing.animate({
        transform: ''
      });
      this.innerRing.delay(100).animate({
        opacity: 1,
        transform: 'translateY(20%)'
      });
      this.innerRing.animate({
        transform: 'translateY(-10%)'
      });
      this.innerRing.animate({
        transform: ''
      });
      this.star.delay(200).animate({
        opacity: 1,
        transform: 'translateY(0)'
      });
      this.star.animate({
        transform: 'scaleY(0.95)'
      });
      this.star.animate({
        transform: ''
      });
      this.planet.delay(300).animate({
        opacity: 1,
        transform: 'translateY(10%)'
      });
      this.planet.delay(300).animate({
        transform: ''
      });
      this.starFlag.delay(1000).animate({
        opacity: 1,
        transform: ''
      });
      this.planetFlag.delay(1500).animate({
        opacity: 1,
        transform: ''
      });
      return this.zoneFlag.delay(2000).animate({
        opacity: 1,
        transform: ''
      });
    };

    HabitableZone.prototype.exit = function() {
      this.outerRing.add(this.zoneFlag).animate({
        opacity: 0,
        transform: 'translateY(200%)'
      });
      this.innerRing.add(this.star).add(this.starFlag).delay(200).animate({
        opacity: 0,
        transform: 'translateY(200%)'
      });
      return this.planet.add(this.planetFlag).delay(600).animate({
        opacity: 0,
        transform: 'translateY(200%)'
      });
    };

    return HabitableZone;

  })(Scene);

  window.HabitableZone = HabitableZone;

}).call(this);
(function() {
  var Radiosphere,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  Radiosphere = (function(_super) {

    __extends(Radiosphere, _super);

    function Radiosphere() {
      this.exit = __bind(this.exit, this);
      this.loop = __bind(this.loop, this);
      this.enter = __bind(this.enter, this);
      this.reset = __bind(this.reset, this);
      Radiosphere.__super__.constructor.apply(this, arguments);
    }

    Radiosphere.prototype.exitDuration = 2500;

    Radiosphere.prototype.elements = {
      '.ring': 'rings',
      '.outer.ring': 'outerRing',
      '.middle.ring': 'middleRing',
      '.inner.ring': 'innerRing',
      '.radio-waves': 'radioWaves',
      '.main.planet': 'mainPlanet',
      '.radio': 'radio',
      '.planet': 'planets',
      '.tiny.planet': 'tinyPlanet',
      '.small.planet': 'smallPlanet',
      '.other.planet': 'otherPlanet'
    };

    Radiosphere.prototype.reset = function() {
      this.el.css({
        opacity: 0
      });
      this.mainPlanet.css({
        opacity: 1,
        transform: 'scale(0.01)'
      });
      this.innerRing.css({
        opacity: 1,
        transform: 'translateY(-21%) scale(0.01)'
      });
      this.middleRing.css({
        opacity: 1,
        transform: 'translateY(-23%) scale(0.01)'
      });
      this.outerRing.css({
        opacity: 1,
        transform: 'translateY(-25%) scale(0.01)'
      });
      this.tinyPlanet.css({
        opacity: 1,
        transform: 'translate(-10%, -10%) scale(0.01)'
      });
      this.smallPlanet.css({
        opacity: 1,
        transform: 'translate(300%, -150%) scale(0.01)'
      });
      this.otherPlanet.css({
        opacity: 1,
        transform: 'translate(-200%, -150%) scale(0.01)'
      });
      this.radio.css({
        opacity: 0,
        transform: 'scale(1, 0.01)'
      });
      return this.radioWaves.css({
        opacity: 0
      });
    };

    Radiosphere.prototype.enter = function() {
      this.el.css({
        opacity: 1
      });
      this.outerRing.animate({
        transform: ''
      }, 500);
      this.middleRing.animate({
        transform: ''
      }, 750);
      this.innerRing.animate({
        transform: ''
      }, 1000);
      this.mainPlanet.animate({
        transform: ''
      }, 1500);
      this.radio.delay(2000).animate({
        opacity: 1,
        transform: ''
      }, 250);
      this.tinyPlanet.animate({
        transform: ''
      }, 2000, this.loop);
      this.smallPlanet.animate({
        transform: ''
      }, 667);
      return this.otherPlanet.animate({
        transform: ''
      }, 333);
    };

    Radiosphere.prototype.loop = function() {
      this.radioWaves.animate({
        opacity: 1
      }, 250).animate({
        opacity: 0
      }, 250);
      this.innerRing.delay(250).animate({
        transform: 'scale(1.1)'
      }, 250).animate({
        transform: ''
      }, 250);
      this.middleRing.delay(500).animate({
        transform: 'scale(1.1)'
      }).animate({
        transform: ''
      });
      this.outerRing.delay(750).animate({
        transform: 'scale(1.1)'
      }).animate({
        transform: ''
      });
      this.smallPlanet.delay(750).animate({
        transform: 'scale(1.2)'
      }).animate({
        transform: ''
      });
      this.otherPlanet.delay(1000).animate({
        transform: 'scale(1.1)'
      }).animate({
        transform: ''
      });
      return this.defer('loop', 3000, this.loop);
    };

    Radiosphere.prototype.exit = function() {
      this.radio.animate({
        opacity: 0
      }, 250);
      this.outerRing.animate({
        opacity: 0,
        transform: 'translateY(170%) scale(3)'
      }, 500);
      this.middleRing.animate({
        opacity: 0,
        transform: 'translateY(175%) scale(3)'
      }, 1000);
      this.innerRing.animate({
        opacity: 0,
        transform: 'translateY(180%) scale(3)'
      }, 1500);
      this.mainPlanet.animate({
        opacity: 0,
        transform: 'translateY(185%) scale(3)'
      }, 1500);
      this.tinyPlanet.animate({
        opacity: 0,
        transform: 'translate(100%, -100%%) scale(3)'
      }, 2500);
      this.smallPlanet.animate({
        opacity: 0,
        transform: 'translate(-500%, 350%) scale(3)'
      }, 1500);
      return this.otherPlanet.animate({
        opacity: 0,
        transform: 'translate(1000%, 600%) scale(3)'
      }, 1000);
    };

    return Radiosphere;

  })(Scene);

  window.Radiosphere = Radiosphere;

}).call(this);
(function() {
  var Stage,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  Stage = (function(_super) {

    __extends(Stage, _super);

    Stage.instances = [];

    Stage.prototype.scenes = null;

    Stage.prototype.controlsTemplate = '<div class="controls">\n	<button class="previous">Previous</button>\n	<button class="next">Next</button>\n</div>';

    Stage.prototype.events = {
      'click .previous': 'goPrevious',
      'click .next': 'goNext'
    };

    function Stage() {
      this.goNext = __bind(this.goNext, this);
      this.goPrevious = __bind(this.goPrevious, this);
      this.addControls = __bind(this.addControls, this);      Stage.instances.push(this);
      Stage.__super__.constructor.apply(this, arguments);
      this.scenes = [];
      this.addControls();
    }

    Stage.prototype.addControls = function() {
      return this.el.append(this.controlsTemplate);
    };

    Stage.prototype.goPrevious = function() {
      return this.el.children('.active').prev().data('scene').activate();
    };

    Stage.prototype.goNext = function() {
      return this.el.children('.active').next().data('scene').activate();
    };

    return Stage;

  })(Spine.Controller);

  window.Stage = Stage;

  window.stages = Stage.instances;

  $(function() {
    return $('[data-animation-scene]').parent().each(function() {
      var stage;
      stage = new Stage({
        el: this
      });
      return $(this).children('[data-animation-scene]').each(function() {
        var $el, Ctor, scene;
        $el = $(this);
        Ctor = window[$el.data('animation-scene')];
        scene = new Ctor({
          el: this
        });
        stage.scenes.push(scene);
        if ($el.hasClass('active')) return setTimeout(scene.activate, 10);
      });
    });
  });

}).call(this);
(function() {
  var NavBar,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  NavBar = (function(_super) {

    __extends(NavBar, _super);

    function NavBar() {
      this.render = __bind(this.render, this);      NavBar.__super__.constructor.apply(this, arguments);
      this.el.attr("id", "top");
      User.bind('refresh', this.render);
      this.render();
    }

    NavBar.prototype.render = function() {
      return this.html(this.view('navBar')({
        user: User.first()
      }));
    };

    return NavBar;

  })(Spine.Controller);

  window.NavBar = NavBar;

}).call(this);
(function() {
  this.JST || (this.JST = {});
  this.JST["app/views/badge"] = function(__obj) {
    if (!__obj) __obj = {};
    var __out = [], __capture = function(callback) {
      var out = __out, result;
      __out = [];
      callback.call(this);
      result = __out.join('');
      __out = out;
      return __safe(result);
    }, __sanitize = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else if (typeof value !== 'undefined' && value != null) {
        return __escape(value);
      } else {
        return '';
      }
    }, __safe, __objSafe = __obj.safe, __escape = __obj.escape;
    __safe = __obj.safe = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else {
        if (!(typeof value !== 'undefined' && value != null)) value = '';
        var result = new String(value);
        result.ecoSafe = true;
        return result;
      }
    };
    if (!__escape) {
      __escape = __obj.escape = function(value) {
        return ('' + value)
          .replace(/&/g, '&amp;')
          .replace(/</g, '&lt;')
          .replace(/>/g, '&gt;')
          .replace(/"/g, '&quot;');
      };
    }
    (function() {
      (function() {
      
        __out.push('<div class=\'badge\' width=');
      
        __out.push(__sanitize(this.size));
      
        __out.push(' height=');
      
        __out.push(__sanitize(this.size));
      
        __out.push(' >\n  <img data-id=\'');
      
        __out.push(__sanitize(this.badge.id));
      
        __out.push('\' width=');
      
        __out.push(__sanitize(this.size));
      
        __out.push(' style=\'position:relative; left:1px;top:1px \' src=\'');
      
        __out.push(__sanitize(this.badge.logo_url));
      
        __out.push('\' alt= \'');
      
        __out.push(__sanitize(this.badge.description));
      
        __out.push('\'/>\n   \n   ');
      
        if ((this.level != null) > 0) {
          __out.push('\n      <div style = \' width: ');
          __out.push(__sanitize(this.size * 0.4));
          __out.push('; height: ');
          __out.push(__sanitize(this.size * 0.4));
          __out.push('; right:-1px; top:-5px \' class=\'badge_level\'>');
          __out.push(__sanitize(this.level));
          __out.push('</div>\n\n\n      <div style = \' width: ');
          __out.push(__sanitize(this.size * 0.4));
          __out.push('; height: ');
          __out.push(__sanitize(this.size * 0.4));
          __out.push('; right:-2px; top:-5px \' class=\'badge_level badge_level_shadow \'></div>\n\n    ');
        }
      
        __out.push(' \n</div>\n');
      
      }).call(this);
      
    }).call(__obj);
    __obj.safe = __objSafe, __obj.escape = __escape;
    return __out.join('');
  };
}).call(this);
(function() {
  this.JST || (this.JST = {});
  this.JST["app/views/global_stats"] = function(__obj) {
    if (!__obj) __obj = {};
    var __out = [], __capture = function(callback) {
      var out = __out, result;
      __out = [];
      callback.call(this);
      result = __out.join('');
      __out = out;
      return __safe(result);
    }, __sanitize = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else if (typeof value !== 'undefined' && value != null) {
        return __escape(value);
      } else {
        return '';
      }
    }, __safe, __objSafe = __obj.safe, __escape = __obj.escape;
    __safe = __obj.safe = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else {
        if (!(typeof value !== 'undefined' && value != null)) value = '';
        var result = new String(value);
        result.ecoSafe = true;
        return result;
      }
    };
    if (!__escape) {
      __escape = __obj.escape = function(value) {
        return ('' + value)
          .replace(/&/g, '&amp;')
          .replace(/</g, '&lt;')
          .replace(/>/g, '&gt;')
          .replace(/"/g, '&quot;');
      };
    }
    (function() {
      (function() {
      
        __out.push('<li>\n  <div class=\'stats_box\'>\n    <p>');
      
        __out.push(__sanitize(this.people_online));
      
        __out.push('</p>\n  </div> \n  <p>People Online</p>\n</li>\n<li>\n  <div class=\'stats_box\'>\n    <p>');
      
        __out.push(__sanitize(this.total_classifications));
      
        __out.push('</p>\n  </div> \n  <p>Total Classifications</p>\n</li>\n<li>\n  <div class=\'stats_box\'>\n    <p>');
      
        __out.push(__sanitize(this.classifications_today));
      
        __out.push('</p>\n  </div> \n  <p>Classifications Today</p>\n</li>\n<li>\n  <div class=\'stats_box\'>\n    <p>');
      
        __out.push(__sanitize(this.classifications_per_min));
      
        __out.push('</p>\n  </div> \n  <p>Classifications per min</p>\n</li>\n');
      
      }).call(this);
      
    }).call(__obj);
    __obj.safe = __objSafe, __obj.escape = __escape;
    return __out.join('');
  };
}).call(this);
(function() {
  this.JST || (this.JST = {});
  this.JST["app/views/home_badge"] = function(__obj) {
    if (!__obj) __obj = {};
    var __out = [], __capture = function(callback) {
      var out = __out, result;
      __out = [];
      callback.call(this);
      result = __out.join('');
      __out = out;
      return __safe(result);
    }, __sanitize = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else if (typeof value !== 'undefined' && value != null) {
        return __escape(value);
      } else {
        return '';
      }
    }, __safe, __objSafe = __obj.safe, __escape = __obj.escape;
    __safe = __obj.safe = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else {
        if (!(typeof value !== 'undefined' && value != null)) value = '';
        var result = new String(value);
        result.ecoSafe = true;
        return result;
      }
    };
    if (!__escape) {
      __escape = __obj.escape = function(value) {
        return ('' + value)
          .replace(/&/g, '&amp;')
          .replace(/</g, '&lt;')
          .replace(/>/g, '&gt;')
          .replace(/"/g, '&quot;');
      };
    }
    (function() {
      (function() {
      
        if (this.user != null) {
          __out.push('\n <img class=\'badge_icon\' src="assets/badges/200px/registration-200.png"></img>\n  <div class=\'right\'> \n    <h2>Congratulations!</h2>\n    <p>You earned the Registration Badge.</p>\n    <div id=\'view_all_button\'>View All</div>\n  </div>\n');
        } else {
          __out.push('\n   <img class=\'badge_icon\' src="assets/emptyBadge.png"></img>\n\n  <div class=\'right\'> \n    <h2> Sign in to earn badges</h2>\n    <div id=\'sign_in_button\'>Sign In</div>\n  </div>\n');
        }
      
        __out.push('\n');
      
      }).call(this);
      
    }).call(__obj);
    __obj.safe = __objSafe, __obj.escape = __escape;
    return __out.join('');
  };
}).call(this);
(function() {
  this.JST || (this.JST = {});
  this.JST["app/views/home_main_content"] = function(__obj) {
    if (!__obj) __obj = {};
    var __out = [], __capture = function(callback) {
      var out = __out, result;
      __out = [];
      callback.call(this);
      result = __out.join('');
      __out = out;
      return __safe(result);
    }, __sanitize = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else if (typeof value !== 'undefined' && value != null) {
        return __escape(value);
      } else {
        return '';
      }
    }, __safe, __objSafe = __obj.safe, __escape = __obj.escape;
    __safe = __obj.safe = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else {
        if (!(typeof value !== 'undefined' && value != null)) value = '';
        var result = new String(value);
        result.ecoSafe = true;
        return result;
      }
    };
    if (!__escape) {
      __escape = __obj.escape = function(value) {
        return ('' + value)
          .replace(/&/g, '&amp;')
          .replace(/</g, '&lt;')
          .replace(/>/g, '&gt;')
          .replace(/"/g, '&quot;');
      };
    }
    (function() {
      (function() {
        var subject, _i, _len, _ref;
      
        __out.push('<div id=\'home_content_top\'>\n  <h1 id=\'user_welcome\'>\n    We’re searching for interesting signals coming from \nthe Kepler Field. Will we find life on another planet? \n  </h1>\n  <div id=\'start_searching_button\'>\n    Start Searching\n  </div>\n\n\n</div>\n<div id=\'home_content_bottom\'>\n  \n  <div id=\'subjects\'>\n    ');
      
        _ref = this.subjects;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          subject = _ref[_i];
          __out.push('\n      <div class=\'waterfall\' data-id=\'');
          __out.push(__sanitize(subject.id));
          __out.push('\' >\n      </div>\n    ');
        }
      
        __out.push('\n  </div>\n  <h2>The Search</h2>\n  <p>The radio sphere shows the boundary of Earth\'s radio signals beginning in the late 1930s and into the early 1940s, when radar, tv carrier waves, and atomic testing started sending strong radio signals into space. Strong enough to pass through Earth\'s ionosphere, these signals travel into interstellar space at the speed of light these signals travel into at speed of light.signals travel into interstellar space at the speed of light these signals travel into at speed of light. signals travel into. interstellar space at the </p>\n</div>\n');
      
      }).call(this);
      
    }).call(__obj);
    __obj.safe = __objSafe, __obj.escape = __escape;
    return __out.join('');
  };
}).call(this);
(function() {
  this.JST || (this.JST = {});
  this.JST["app/views/navBar"] = function(__obj) {
    if (!__obj) __obj = {};
    var __out = [], __capture = function(callback) {
      var out = __out, result;
      __out = [];
      callback.call(this);
      result = __out.join('');
      __out = out;
      return __safe(result);
    }, __sanitize = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else if (typeof value !== 'undefined' && value != null) {
        return __escape(value);
      } else {
        return '';
      }
    }, __safe, __objSafe = __obj.safe, __escape = __obj.escape;
    __safe = __obj.safe = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else {
        if (!(typeof value !== 'undefined' && value != null)) value = '';
        var result = new String(value);
        result.ecoSafe = true;
        return result;
      }
    };
    if (!__escape) {
      __escape = __obj.escape = function(value) {
        return ('' + value)
          .replace(/&/g, '&amp;')
          .replace(/</g, '&lt;')
          .replace(/>/g, '&gt;')
          .replace(/"/g, '&quot;');
      };
    }
    (function() {
      (function() {
      
        __out.push('\n<a href=\'/\' id=\'logo\'>SETI<span class=\'green live\'>LIVE</span></a>\n<ul id=\'nav\'>\n  ');
      
        if (this.user == null) {
          __out.push('\n    <li><a href=\'/login\'>login</a> </li>\n  ');
        } else {
          __out.push('\n    <li><a href=\'/logout\'>logout </a> </li>\n    <li><a href=\'/profile\'>');
          __out.push(this.user.name);
          __out.push('</a> </li>\n  ');
        }
      
        __out.push('\n  <li><a href=\'/about\'>about</a> </li>\n  <li><a href=\'/classify.html\'>classify</a> </li>\n  <li><a href=\'/sources\'>targets</a> </li>\n  <li><a href=\'http://talk.setilive.org\'>talk</a> </li>\n</ul>\n');
      
      }).call(this);
      
    }).call(__obj);
    __obj.safe = __objSafe, __obj.escape = __escape;
    return __out.join('');
  };
}).call(this);
(function() {
  this.JST || (this.JST = {});
  this.JST["app/views/notifications/badge_awarded_notification"] = function(__obj) {
    if (!__obj) __obj = {};
    var __out = [], __capture = function(callback) {
      var out = __out, result;
      __out = [];
      callback.call(this);
      result = __out.join('');
      __out = out;
      return __safe(result);
    }, __sanitize = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else if (typeof value !== 'undefined' && value != null) {
        return __escape(value);
      } else {
        return '';
      }
    }, __safe, __objSafe = __obj.safe, __escape = __obj.escape;
    __safe = __obj.safe = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else {
        if (!(typeof value !== 'undefined' && value != null)) value = '';
        var result = new String(value);
        result.ecoSafe = true;
        return result;
      }
    };
    if (!__escape) {
      __escape = __obj.escape = function(value) {
        return ('' + value)
          .replace(/&/g, '&amp;')
          .replace(/</g, '&lt;')
          .replace(/>/g, '&gt;')
          .replace(/"/g, '&quot;');
      };
    }
    (function() {
      (function() {
      
        __out.push('<li class=\'notification\'> Badge awarded </li>\n');
      
      }).call(this);
      
    }).call(__obj);
    __obj.safe = __objSafe, __obj.escape = __escape;
    return __out.join('');
  };
}).call(this);
(function() {
  this.JST || (this.JST = {});
  this.JST["app/views/notifications/new_data_notification"] = function(__obj) {
    if (!__obj) __obj = {};
    var __out = [], __capture = function(callback) {
      var out = __out, result;
      __out = [];
      callback.call(this);
      result = __out.join('');
      __out = out;
      return __safe(result);
    }, __sanitize = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else if (typeof value !== 'undefined' && value != null) {
        return __escape(value);
      } else {
        return '';
      }
    }, __safe, __objSafe = __obj.safe, __escape = __obj.escape;
    __safe = __obj.safe = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else {
        if (!(typeof value !== 'undefined' && value != null)) value = '';
        var result = new String(value);
        result.ecoSafe = true;
        return result;
      }
    };
    if (!__escape) {
      __escape = __obj.escape = function(value) {
        return ('' + value)
          .replace(/&/g, '&amp;')
          .replace(/</g, '&lt;')
          .replace(/>/g, '&gt;')
          .replace(/"/g, '&quot;');
      };
    }
    (function() {
      (function() {
      
        __out.push('<li class=\'notification\'>TELESCOPE HAS NEW DATA </li>\n');
      
      }).call(this);
      
    }).call(__obj);
    __obj.safe = __objSafe, __obj.escape = __escape;
    return __out.join('');
  };
}).call(this);
(function() {
  this.JST || (this.JST = {});
  this.JST["app/views/notifications/source_change_notification"] = function(__obj) {
    if (!__obj) __obj = {};
    var __out = [], __capture = function(callback) {
      var out = __out, result;
      __out = [];
      callback.call(this);
      result = __out.join('');
      __out = out;
      return __safe(result);
    }, __sanitize = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else if (typeof value !== 'undefined' && value != null) {
        return __escape(value);
      } else {
        return '';
      }
    }, __safe, __objSafe = __obj.safe, __escape = __obj.escape;
    __safe = __obj.safe = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else {
        if (!(typeof value !== 'undefined' && value != null)) value = '';
        var result = new String(value);
        result.ecoSafe = true;
        return result;
      }
    };
    if (!__escape) {
      __escape = __obj.escape = function(value) {
        return ('' + value)
          .replace(/&/g, '&amp;')
          .replace(/</g, '&lt;')
          .replace(/>/g, '&gt;')
          .replace(/"/g, '&quot;');
      };
    }
    (function() {
      (function() {
      
        __out.push('<li class=\'notification\'>Beam no ');
      
        __out.push(__sanitize(this.target.beam_no));
      
        __out.push(' is now looking at target ');
      
        __out.push(__sanitize(this.target_id));
      
        __out.push(' </li>\n');
      
      }).call(this);
      
    }).call(__obj);
    __obj.safe = __objSafe, __obj.escape = __escape;
    return __out.join('');
  };
}).call(this);
(function() {
  this.JST || (this.JST = {});
  this.JST["app/views/notifications/telescope_status_changed_notification"] = function(__obj) {
    if (!__obj) __obj = {};
    var __out = [], __capture = function(callback) {
      var out = __out, result;
      __out = [];
      callback.call(this);
      result = __out.join('');
      __out = out;
      return __safe(result);
    }, __sanitize = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else if (typeof value !== 'undefined' && value != null) {
        return __escape(value);
      } else {
        return '';
      }
    }, __safe, __objSafe = __obj.safe, __escape = __obj.escape;
    __safe = __obj.safe = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else {
        if (!(typeof value !== 'undefined' && value != null)) value = '';
        var result = new String(value);
        result.ecoSafe = true;
        return result;
      }
    };
    if (!__escape) {
      __escape = __obj.escape = function(value) {
        return ('' + value)
          .replace(/&/g, '&amp;')
          .replace(/</g, '&lt;')
          .replace(/>/g, '&gt;')
          .replace(/"/g, '&quot;');
      };
    }
    (function() {
      (function() {
      
        __out.push('<li class=\'notification\'>TELESCOPE STATUS CHANGED TO ');
      
        __out.push(__sanitize(this));
      
        __out.push('</li>\n');
      
      }).call(this);
      
    }).call(__obj);
    __obj.safe = __objSafe, __obj.escape = __escape;
    return __out.join('');
  };
}).call(this);
(function() {
  this.JST || (this.JST = {});
  this.JST["app/views/pagination"] = function(__obj) {
    if (!__obj) __obj = {};
    var __out = [], __capture = function(callback) {
      var out = __out, result;
      __out = [];
      callback.call(this);
      result = __out.join('');
      __out = out;
      return __safe(result);
    }, __sanitize = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else if (typeof value !== 'undefined' && value != null) {
        return __escape(value);
      } else {
        return '';
      }
    }, __safe, __objSafe = __obj.safe, __escape = __obj.escape;
    __safe = __obj.safe = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else {
        if (!(typeof value !== 'undefined' && value != null)) value = '';
        var result = new String(value);
        result.ecoSafe = true;
        return result;
      }
    };
    if (!__escape) {
      __escape = __obj.escape = function(value) {
        return ('' + value)
          .replace(/&/g, '&amp;')
          .replace(/</g, '&lt;')
          .replace(/>/g, '&gt;')
          .replace(/"/g, '&quot;');
      };
    }
    (function() {
      (function() {
        var page, _ref;
      
        console.log("page", this);
      
        __out.push('\n<ul class=\'pagination\'>\n  ');
      
        for (page = 0, _ref = this.pages; 0 <= _ref ? page <= _ref : page >= _ref; 0 <= _ref ? page++ : page--) {
          __out.push('\n    <li class=\'page ');
          if (page === this.page) __out.push(__sanitize("selected_page"));
          __out.push('\' data-id=\'');
          __out.push(__sanitize(page));
          __out.push('\' >');
          __out.push(__sanitize(page));
          __out.push('</li>\n  ');
        }
      
        __out.push('\n</ul>\n');
      
      }).call(this);
      
    }).call(__obj);
    __obj.safe = __objSafe, __obj.escape = __escape;
    return __out.join('');
  };
}).call(this);
(function() {
  this.JST || (this.JST = {});
  this.JST["app/views/talk_prompt"] = function(__obj) {
    if (!__obj) __obj = {};
    var __out = [], __capture = function(callback) {
      var out = __out, result;
      __out = [];
      callback.call(this);
      result = __out.join('');
      __out = out;
      return __safe(result);
    }, __sanitize = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else if (typeof value !== 'undefined' && value != null) {
        return __escape(value);
      } else {
        return '';
      }
    }, __safe, __objSafe = __obj.safe, __escape = __obj.escape;
    __safe = __obj.safe = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else {
        if (!(typeof value !== 'undefined' && value != null)) value = '';
        var result = new String(value);
        result.ecoSafe = true;
        return result;
      }
    };
    if (!__escape) {
      __escape = __obj.escape = function(value) {
        return ('' + value)
          .replace(/&/g, '&amp;')
          .replace(/</g, '&lt;')
          .replace(/>/g, '&gt;')
          .replace(/"/g, '&quot;');
      };
    }
    (function() {
      (function() {
      
        __out.push('<div id=\'talk_yes\'> Yes </div>\n<div id=\'talk_no\'>  No  </div>\n<p id=\'talk_prompt\'> Would you like to discuss this signal ? </div>\n');
      
      }).call(this);
      
    }).call(__obj);
    __obj.safe = __objSafe, __obj.escape = __escape;
    return __out.join('');
  };
}).call(this);
(function() {
  this.JST || (this.JST = {});
  this.JST["app/views/target_index"] = function(__obj) {
    if (!__obj) __obj = {};
    var __out = [], __capture = function(callback) {
      var out = __out, result;
      __out = [];
      callback.call(this);
      result = __out.join('');
      __out = out;
      return __safe(result);
    }, __sanitize = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else if (typeof value !== 'undefined' && value != null) {
        return __escape(value);
      } else {
        return '';
      }
    }, __safe, __objSafe = __obj.safe, __escape = __obj.escape;
    __safe = __obj.safe = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else {
        if (!(typeof value !== 'undefined' && value != null)) value = '';
        var result = new String(value);
        result.ecoSafe = true;
        return result;
      }
    };
    if (!__escape) {
      __escape = __obj.escape = function(value) {
        return ('' + value)
          .replace(/&/g, '&amp;')
          .replace(/</g, '&lt;')
          .replace(/>/g, '&gt;')
          .replace(/"/g, '&quot;');
      };
    }
    (function() {
      (function() {
        var details, i, index, planet, planetStep, source, _i, _len, _len2, _ref, _ref2, _ref3;
      
        __out.push('<ul id=\'source_list\'>\n  ');
      
        _ref = this.sources.slice(this.page * this.perPage, ((this.page + 1) * this.perPage - 1) + 1 || 9e9);
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          source = _ref[_i];
          __out.push('\n    ');
          details = source.meta;
          __out.push('\n    <li class=\'source\' data-id=\'');
          __out.push(__sanitize(source.id));
          __out.push('\'>\n      <svg xmlns="http://www.w3.org/2000/svg" version="1.1" width = 100% height=100>\n        <circle r = "');
          __out.push(__sanitize(Math.max(details.stellar_rad * 10, 5)));
          __out.push('" cx="105" cy="51" fill="#E2E2E2" />\n        <circle r = "');
          __out.push(__sanitize(Math.max(details.stellar_rad * 10, 5)));
          __out.push('" cx="105" cy="50" fill="#A8A8A8" />\n      \n        ');
          planetStep = 100 / details.planets.length;
          __out.push('\n        ');
          _ref2 = details.planets;
          for (index = 0, _len2 = _ref2.length; index < _len2; index++) {
            planet = _ref2[index];
            __out.push('\n         <circle r = "');
            __out.push(__sanitize(Math.max(planet.radius, 2)));
            __out.push('" cx="');
            __out.push(__sanitize(index * planetStep + 80));
            __out.push('" cy="53" fill="#E2E2E2" />\n          <circle r = "');
            __out.push(__sanitize(Math.max(planet.radius, 2)));
            __out.push('" cx="');
            __out.push(__sanitize(index * planetStep + 80));
            __out.push('" cy="52" fill="#12161A" />\n        ');
          }
          __out.push('\n      </svg>\n      <p>Kepler ');
          __out.push(__sanitize(source.kepler_no()));
          __out.push('</p>\n    </li>\n  ');
        }
      
        __out.push('\n</ul>\n\n<ul id=\'pagination\'>\n  ');
      
        for (i = 0, _ref3 = this.sources.length / this.perPage; 0 <= _ref3 ? i <= _ref3 : i >= _ref3; 0 <= _ref3 ? i++ : i--) {
          __out.push('\n    <li data-id=\'');
          __out.push(__sanitize(i));
          __out.push('\' class=\'page_link\'> <a  ');
          if (this.page === i) __out.push(__sanitize("class='pagination_active'"));
          __out.push(' href=\'#\'>');
          __out.push(__sanitize(i));
          __out.push('</a></li>\n  ');
        }
      
        __out.push('\n</ul>\n');
      
      }).call(this);
      
    }).call(__obj);
    __obj.safe = __objSafe, __obj.escape = __escape;
    return __out.join('');
  };
}).call(this);
(function() {
  this.JST || (this.JST = {});
  this.JST["app/views/target_show"] = function(__obj) {
    if (!__obj) __obj = {};
    var __out = [], __capture = function(callback) {
      var out = __out, result;
      __out = [];
      callback.call(this);
      result = __out.join('');
      __out = out;
      return __safe(result);
    }, __sanitize = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else if (typeof value !== 'undefined' && value != null) {
        return __escape(value);
      } else {
        return '';
      }
    }, __safe, __objSafe = __obj.safe, __escape = __obj.escape;
    __safe = __obj.safe = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else {
        if (!(typeof value !== 'undefined' && value != null)) value = '';
        var result = new String(value);
        result.ecoSafe = true;
        return result;
      }
    };
    if (!__escape) {
      __escape = __obj.escape = function(value) {
        return ('' + value)
          .replace(/&/g, '&amp;')
          .replace(/</g, '&lt;')
          .replace(/>/g, '&gt;')
          .replace(/"/g, '&quot;');
      };
    }
    (function() {
      (function() {
      
        __out.push('<div id=\'source\'>\n\n  <div id=\'star_vis\'>\n  </div>\n\n\n  <div id=\'star_details\'>\n    <h1 class=\'star_title\'>Kepler ');
      
        __out.push(__sanitize(this.kepler_no()));
      
        __out.push('</h1>\n    <h2 class=\'star_type\'> ');
      
        __out.push(__sanitize(this.meta.star_type));
      
        __out.push('</h1>\n    <ul>\n      \n      <li> <span class=\'property\'>mag</span> <span class=\'property_val\'> ');
      
        __out.push(__sanitize(this.meta.kepler_mag));
      
        __out.push(' </span> </li>\n\n      <li> <span class=\'property\'>radius</span> <span class=\'property_val\'> ');
      
        __out.push(__sanitize(this.meta.stellar_rad));
      
        __out.push(' </span> </li>\n      <li> <span class=\'property\'>temparature</span> <span class=\'property_val\'> ');
      
        __out.push(__sanitize(this.meta.eff_temp));
      
        __out.push(' </span> </li>\n      <li> <span class=\'property\'>Planets</span> <span class=\'property_val\'> ');
      
        __out.push(__sanitize(this.meta.planets.length));
      
        __out.push(' </span> </li>\n    </ul>\n\n    <div id=\'buttons\'>\n      <div id=\'back_button\'>Back</div>\n      <div id=\'planethunters_button\'>Planet Hunters\n      </div>\n    </div>\n  </div>\n</div>\n');
      
      }).call(this);
      
    }).call(__obj);
    __obj.safe = __objSafe, __obj.escape = __escape;
    return __out.join('');
  };
}).call(this);
(function() {
  this.JST || (this.JST = {});
  this.JST["app/views/targets_slide_show"] = function(__obj) {
    if (!__obj) __obj = {};
    var __out = [], __capture = function(callback) {
      var out = __out, result;
      __out = [];
      callback.call(this);
      result = __out.join('');
      __out = out;
      return __safe(result);
    }, __sanitize = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else if (typeof value !== 'undefined' && value != null) {
        return __escape(value);
      } else {
        return '';
      }
    }, __safe, __objSafe = __obj.safe, __escape = __obj.escape;
    __safe = __obj.safe = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else {
        if (!(typeof value !== 'undefined' && value != null)) value = '';
        var result = new String(value);
        result.ecoSafe = true;
        return result;
      }
    };
    if (!__escape) {
      __escape = __obj.escape = function(value) {
        return ('' + value)
          .replace(/&/g, '&amp;')
          .replace(/</g, '&lt;')
          .replace(/>/g, '&gt;')
          .replace(/"/g, '&quot;');
      };
    }
    (function() {
      (function() {
        var details, index, planet, planetStep, source, _i, _len, _len2, _ref, _ref2;
      
        __out.push('<div id=\'targets\'>\n  <p>Kepler ');
      
        __out.push(__sanitize(this.current_target.kepler_no()));
      
        __out.push('</p>\n          ');
      
        details = this.current_target.meta;
      
        __out.push('\n  <div id=\'target\'>\n          \n          <svg xmlns="http://www.w3.org/2000/svg" version="1.1" width = 100% height=100>\n            <circle r = "');
      
        __out.push(__sanitize(Math.max(details.stellar_rad * 10, 5)));
      
        __out.push('" cx="105" cy="51" fill="#E2E2E2" />\n            <circle r = "');
      
        __out.push(__sanitize(Math.max(details.stellar_rad * 10, 5)));
      
        __out.push('" cx="105" cy="50" fill="#A8A8A8" />\n\n            ');
      
        planetStep = 100 / details.planets.length;
      
        __out.push('\n            ');
      
        _ref = details.planets;
        for (index = 0, _len = _ref.length; index < _len; index++) {
          planet = _ref[index];
          __out.push('\n             <circle r = "');
          __out.push(__sanitize(Math.max(planet.radius, 2)));
          __out.push('" cx="');
          __out.push(__sanitize(index * planetStep + 80));
          __out.push('" cy="53" fill="#E2E2E2" />\n              <circle r = "');
          __out.push(__sanitize(Math.max(planet.radius, 2)));
          __out.push('" cx="');
          __out.push(__sanitize(index * planetStep + 80));
          __out.push('" cy="52" fill="#12161A" />\n            ');
        }
      
        __out.push('\n        </svg>\n\n    \n  </div>\n  <ul id=\'controls\'>\n      ');
      
        _ref2 = this.targets;
        for (_i = 0, _len2 = _ref2.length; _i < _len2; _i++) {
          source = _ref2[_i];
          __out.push('\n        <li class=\'dot ');
          if (source.id === this.current_target.id) __out.push(__sanitize("selected"));
          __out.push('\' data-id=\'');
          __out.push(__sanitize(source.id));
          __out.push('\'></li>\n      ');
        }
      
        __out.push('\n    </ul>\n\n</div>\n\n<p class=\'title\'>Targets Currently in View</p>\n');
      
      }).call(this);
      
    }).call(__obj);
    __obj.safe = __objSafe, __obj.escape = __escape;
    return __out.join('');
  };
}).call(this);
(function() {
  this.JST || (this.JST = {});
  this.JST["app/views/user_profile"] = function(__obj) {
    if (!__obj) __obj = {};
    var __out = [], __capture = function(callback) {
      var out = __out, result;
      __out = [];
      callback.call(this);
      result = __out.join('');
      __out = out;
      return __safe(result);
    }, __sanitize = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else if (typeof value !== 'undefined' && value != null) {
        return __escape(value);
      } else {
        return '';
      }
    }, __safe, __objSafe = __obj.safe, __escape = __obj.escape;
    __safe = __obj.safe = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else {
        if (!(typeof value !== 'undefined' && value != null)) value = '';
        var result = new String(value);
        result.ecoSafe = true;
        return result;
      }
    };
    if (!__escape) {
      __escape = __obj.escape = function(value) {
        return ('' + value)
          .replace(/&/g, '&amp;')
          .replace(/</g, '&lt;')
          .replace(/>/g, '&gt;')
          .replace(/"/g, '&quot;');
      };
    }
    (function() {
      (function() {
        var badge, subject, _i, _j, _len, _len2, _ref, _ref2;
      
        __out.push('<div id=\'user_profile\'>\n  <div id=\'profile_top\'>\n    <h1 id=\'user_welcome\'>\n      Welcome back, ');
      
        __out.push(__sanitize(this.user.name));
      
        __out.push('.\n    </h1>\n    <ul id=\'user_badges\'>\n      ');
      
        console.log("badges are ", Badge.all());
      
        __out.push('\n      ');
      
        _ref = Badge.all();
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          badge = _ref[_i];
          __out.push('\n        <li  class=\'badge\'>\n\n          ');
          __out.push(this.badgeTemplate({
            badge: badge,
            size: 50,
            level: 10
          }));
          __out.push('\n        </li>\n      ');
        }
      
        __out.push('\n    </ul>\n  </div>\n  <div id=\'profile_bottom\'>\n    <div id=\'view_selection\'>\n      <span> View </span>\n      <ul id=\'view_selection\'>\n        <li  class= \'collectionType ');
      
        if (this.collectionType === 'recents') {
          __out.push(__sanitize("catagory_selection"));
        }
      
        __out.push('\' data-id="recents" >Recents / </li>\n        <li class= \'collectionType ');
      
        if (this.collectionType === 'followups') {
          __out.push(__sanitize("catagory_selection"));
        }
      
        __out.push('\' data-id="Followups">Followups /</li> \n        <li class= \'collectionType ');
      
        if (this.collectionType === 'favorites') {
          __out.push(__sanitize("catagory_selection"));
        }
      
        __out.push('\' data-id="favorites">Favorites</li> \n      </ul>\n    </div>\n\n    <div id=\'subjects\'>\n      ');
      
        _ref2 = this.subjects.slice(this.pagination.start(), this.pagination.end());
        for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
          subject = _ref2[_j];
          __out.push('\n        <div class=\'waterfall\' data-id=\'');
          __out.push(__sanitize(subject.id));
          __out.push('\' >\n        </div>\n      ');
        }
      
        __out.push('\n    </div>\n    ');
      
        __out.push(this.pagination.menu());
      
        __out.push('\n  </div>\n</div>\n');
      
      }).call(this);
      
    }).call(__obj);
    __obj.safe = __objSafe, __obj.escape = __escape;
    return __out.join('');
  };
}).call(this);
(function() {
  this.JST || (this.JST = {});
  this.JST["app/views/user_stats"] = function(__obj) {
    if (!__obj) __obj = {};
    var __out = [], __capture = function(callback) {
      var out = __out, result;
      __out = [];
      callback.call(this);
      result = __out.join('');
      __out = out;
      return __safe(result);
    }, __sanitize = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else if (typeof value !== 'undefined' && value != null) {
        return __escape(value);
      } else {
        return '';
      }
    }, __safe, __objSafe = __obj.safe, __escape = __obj.escape;
    __safe = __obj.safe = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else {
        if (!(typeof value !== 'undefined' && value != null)) value = '';
        var result = new String(value);
        result.ecoSafe = true;
        return result;
      }
    };
    if (!__escape) {
      __escape = __obj.escape = function(value) {
        return ('' + value)
          .replace(/&/g, '&amp;')
          .replace(/</g, '&lt;')
          .replace(/>/g, '&gt;')
          .replace(/"/g, '&quot;');
      };
    }
    (function() {
      (function() {
      
        __out.push('<ul id=\'user_stats\'>\n  <li>\n    <div class=\'stats_box\'>\n      <p>');
      
        __out.push(__sanitize(this.total_classifications));
      
        __out.push('</p>\n    </div> \n    <p>Total Classification</p>\n  </li>\n  <li>\n    <div class=\'stats_box\'>\n      <p>');
      
        __out.push(__sanitize(this.total_follow_ups));
      
        __out.push('</p>\n    </div> \n    <p>Follow Ups</p>\n  </li>\n  <li>\n    <div class=\'stats_box\'>\n      <p>');
      
        __out.push(__sanitize(this.total_signals));
      
        __out.push('</p>\n    </div> \n    <p>Signals Marked</p>\n  </li>\n  <li>\n    <div class=\'stats_box\'>\n      <p>0</p>\n    </div> \n    <p>Extraterrestrials Found</p>\n  </li>\n </ul>\n');
      
      }).call(this);
      
    }).call(__obj);
    __obj.safe = __objSafe, __obj.escape = __escape;
    return __out.join('');
  };
}).call(this);
(function() {
  this.JST || (this.JST = {});
  this.JST["app/views/waterfalls"] = function(__obj) {
    if (!__obj) __obj = {};
    var __out = [], __capture = function(callback) {
      var out = __out, result;
      __out = [];
      callback.call(this);
      result = __out.join('');
      __out = out;
      return __safe(result);
    }, __sanitize = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else if (typeof value !== 'undefined' && value != null) {
        return __escape(value);
      } else {
        return '';
      }
    }, __safe, __objSafe = __obj.safe, __escape = __obj.escape;
    __safe = __obj.safe = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else {
        if (!(typeof value !== 'undefined' && value != null)) value = '';
        var result = new String(value);
        result.ecoSafe = true;
        return result;
      }
    };
    if (!__escape) {
      __escape = __obj.escape = function(value) {
        return ('' + value)
          .replace(/&/g, '&amp;')
          .replace(/</g, '&lt;')
          .replace(/>/g, '&gt;')
          .replace(/"/g, '&quot;');
      };
    }
    (function() {
      (function() {
        var beam, index, _len;
      
        __out.push('<div class=\'waterfall large-waterfall\' id=\'main-waterfall\' style=\'position:relative\'>\n    <canvas style=\'width:100%;height:100%;position:absolute; top:0px; left:0px\'></canvas>\n    <div id=\'workflow\' class=\'workflow_area\'></div>\n</div>\n\n');
      
        for (index = 0, _len = this.length; index < _len; index++) {
          beam = this[index];
          __out.push('\n  <div class=\'waterfall small-waterfall\' id=\'waterfall-');
          __out.push(index);
          __out.push('\' data-id=\'');
          __out.push(index);
          __out.push('\' style=\'position:relative\'>\n    <canvas style=\'width:100%;height:100%;position:absolute; top:0px; left:0px\'></canvas>\n  </div>\n');
        }
      
        __out.push('\n');
      
      }).call(this);
      
    }).call(__obj);
    __obj.safe = __objSafe, __obj.escape = __escape;
    return __out.join('');
  };
}).call(this);
(function() {
  this.JST || (this.JST = {});
  this.JST["app/views/workflow"] = function(__obj) {
    if (!__obj) __obj = {};
    var __out = [], __capture = function(callback) {
      var out = __out, result;
      __out = [];
      callback.call(this);
      result = __out.join('');
      __out = out;
      return __safe(result);
    }, __sanitize = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else if (typeof value !== 'undefined' && value != null) {
        return __escape(value);
      } else {
        return '';
      }
    }, __safe, __objSafe = __obj.safe, __escape = __obj.escape;
    __safe = __obj.safe = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else {
        if (!(typeof value !== 'undefined' && value != null)) value = '';
        var result = new String(value);
        result.ecoSafe = true;
        return result;
      }
    };
    if (!__escape) {
      __escape = __obj.escape = function(value) {
        return ('' + value)
          .replace(/&/g, '&amp;')
          .replace(/</g, '&lt;')
          .replace(/>/g, '&gt;')
          .replace(/"/g, '&quot;');
      };
    }
    (function() {
      (function() {
        var answer, _i, _len, _ref;
      
        __out.push('  ');
      
        console.log("redering workflow ", this);
      
        __out.push('\n  <div class=\'question\'>\n    ');
      
        if (this.question != null) {
          __out.push('\n      <p id=\'question_text\'>');
          __out.push(__sanitize(this.question.name));
          __out.push('</p>\n    ');
        }
      
        __out.push('\n  </div>\n  <ul class=\'answer_list\'>\n    ');
      
        if (this.question != null) {
          __out.push('\n      ');
          _ref = this.question.answers;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            answer = _ref[_i];
            __out.push('\n        <li id=\'answer_');
            __out.push(__sanitize(answer._id));
            __out.push('\' class=\'answer\' data-id =\'');
            __out.push(__sanitize(answer._id));
            __out.push('\' data-leads_to=\'');
            __out.push(__sanitize(answer.leads_to));
            __out.push('\'\' >\n          ');
            this.helpers.answer_icon(answer);
            __out.push('\n          ');
            __out.push(answer.name);
            __out.push('\n        </li>      \n      ');
          }
          __out.push('\n    ');
        }
      
        __out.push('\n\n  </ul>\n');
      
      }).call(this);
      
    }).call(__obj);
    __obj.safe = __objSafe, __obj.escape = __escape;
    return __out.join('');
  };
}).call(this);
(function() {
  this.JST || (this.JST = {});
  this.JST["app/views/workflow_answers"] = function(__obj) {
    if (!__obj) __obj = {};
    var __out = [], __capture = function(callback) {
      var out = __out, result;
      __out = [];
      callback.call(this);
      result = __out.join('');
      __out = out;
      return __safe(result);
    }, __sanitize = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else if (typeof value !== 'undefined' && value != null) {
        return __escape(value);
      } else {
        return '';
      }
    }, __safe, __objSafe = __obj.safe, __escape = __obj.escape;
    __safe = __obj.safe = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else {
        if (!(typeof value !== 'undefined' && value != null)) value = '';
        var result = new String(value);
        result.ecoSafe = true;
        return result;
      }
    };
    if (!__escape) {
      __escape = __obj.escape = function(value) {
        return ('' + value)
          .replace(/&/g, '&amp;')
          .replace(/</g, '&lt;')
          .replace(/>/g, '&gt;')
          .replace(/"/g, '&quot;');
      };
    }
    (function() {
      (function() {
        var answer, _i, _len;
      
        for (_i = 0, _len = this.length; _i < _len; _i++) {
          answer = this[_i];
          __out.push('\n  <li id=\'answer_');
          __out.push(__sanitize(answer._id));
          __out.push('\' class=\'answer\'>\n    ');
          __out.push(answer.icon);
          __out.push('\n    ');
          __out.push(answer.name);
          __out.push('\n  </li>\n');
        }
      
        __out.push('\n');
      
      }).call(this);
      
    }).call(__obj);
    __obj.safe = __objSafe, __obj.escape = __escape;
    return __out.join('');
  };
}).call(this);
(function() {
  this.JST || (this.JST = {});
  this.JST["app/views/workflow_question"] = function(__obj) {
    if (!__obj) __obj = {};
    var __out = [], __capture = function(callback) {
      var out = __out, result;
      __out = [];
      callback.call(this);
      result = __out.join('');
      __out = out;
      return __safe(result);
    }, __sanitize = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else if (typeof value !== 'undefined' && value != null) {
        return __escape(value);
      } else {
        return '';
      }
    }, __safe, __objSafe = __obj.safe, __escape = __obj.escape;
    __safe = __obj.safe = function(value) {
      if (value && value.ecoSafe) {
        return value;
      } else {
        if (!(typeof value !== 'undefined' && value != null)) value = '';
        var result = new String(value);
        result.ecoSafe = true;
        return result;
      }
    };
    if (!__escape) {
      __escape = __obj.escape = function(value) {
        return ('' + value)
          .replace(/&/g, '&amp;')
          .replace(/</g, '&lt;')
          .replace(/>/g, '&gt;')
          .replace(/"/g, '&quot;');
      };
    }
    (function() {
      (function() {
      
        __out.push('<p id=\'question_text\'>');
      
        __out.push(__sanitize(this.name));
      
        __out.push('</p>\n');
      
      }).call(this);
      
    }).call(__obj);
    __obj.safe = __objSafe, __obj.escape = __escape;
    return __out.join('');
  };
}).call(this);
(function() {
  var AboutPage, ClassificationPage, HomePage, LoginPage, ProfilePage, SetiLiveController, TargetsIndexPage, TargetsShowPage,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  SetiLiveController = (function(_super) {

    __extends(SetiLiveController, _super);

    SetiLiveController.prototype.events = {
      "click #start_searching_button": function() {
        return window.location = '/classify';
      },
      "click #view_all_button": function() {
        return window.location = '/profile';
      }
    };

    function SetiLiveController() {
      SetiLiveController.__super__.constructor.apply(this, arguments);
      this.prepend(new NavBar());
      this.stars = new Stars({
        el: $("#star_field")
      });
      this.notifications = new Notifications({
        el: $("#notification_bar")
      });
      User.fetch_current_user();
      Source.fetch();
      Badge.fetch();
    }

    return SetiLiveController;

  })(Spine.Controller);

  HomePage = (function(_super) {

    __extends(HomePage, _super);

    HomePage.prototype.elements = {
      '#home_content': 'home_content',
      '#most_recent_badge': 'home_badge'
    };

    function HomePage() {
      HomePage.__super__.constructor.apply(this, arguments);
      this.stats = new Stats({
        el: $("#global_stats")
      });
      this.home_content.html(this.view('home_main_content')({
        subjects: [1, 2, 3, 4]
      }));
      this.home_badge.html(this.view('home_badge')({
        user: User.first
      }));
    }

    return HomePage;

  })(SetiLiveController);

  ClassificationPage = (function(_super) {

    __extends(ClassificationPage, _super);

    function ClassificationPage() {
      ClassificationPage.__super__.constructor.apply(this, arguments);
      this.subjects = new Subjects({
        el: $("#waterfalls")
      });
      this.info = new Info({
        el: $("#info")
      });
      Workflow.fetch_from_url("/workflows.json");
    }

    return ClassificationPage;

  })(SetiLiveController);

  LoginPage = (function(_super) {

    __extends(LoginPage, _super);

    function LoginPage() {
      LoginPage.__super__.constructor.apply(this, arguments);
      $("input").each(function() {
        return $(this).attr('data-placeholder', $(this).val());
      });
      $("input").focus(function() {
        $(this).val("");
        return $(this).css("color", "black");
      });
      $("input").blur(function() {
        if ($(this).val() === "") {
          if ($(this).val() === "") $(this).val($(this).data().placeholder);
          return $(this).css("color", "grey");
        }
      });
    }

    return LoginPage;

  })(SetiLiveController);

  AboutPage = (function(_super) {

    __extends(AboutPage, _super);

    function AboutPage() {
      AboutPage.__super__.constructor.apply(this, arguments);
      $('#star_field').hide();
    }

    return AboutPage;

  })(SetiLiveController);

  TargetsIndexPage = (function(_super) {

    __extends(TargetsIndexPage, _super);

    function TargetsIndexPage() {
      TargetsIndexPage.__super__.constructor.apply(this, arguments);
      new TargetsIndex({
        el: $("#sources")
      });
    }

    return TargetsIndexPage;

  })(SetiLiveController);

  TargetsShowPage = (function(_super) {

    __extends(TargetsShowPage, _super);

    function TargetsShowPage() {
      TargetsShowPage.__super__.constructor.apply(this, arguments);
      new TargetsShow({
        el: $("#source")
      });
    }

    return TargetsShowPage;

  })(SetiLiveController);

  ProfilePage = (function(_super) {

    __extends(ProfilePage, _super);

    function ProfilePage() {
      ProfilePage.__super__.constructor.apply(this, arguments);
      new Profile({
        el: $("#profile")
      });
    }

    return ProfilePage;

  })(SetiLiveController);

  window.HomePage = HomePage;

  window.ClassificationPage = ClassificationPage;

  window.LoginPage = LoginPage;

  window.ClassificationPage = ClassificationPage;

  window.AboutPage = AboutPage;

  window.TargetsIndexPage = TargetsIndexPage;

  window.TargetsShowPage = TargetsShowPage;

  window.ProfilePage = ProfilePage;

  jQuery.fx.interval = 50;

}).call(this);
// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
;
