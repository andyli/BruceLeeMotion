// usage: log('inside coolFunc', this, arguments);
// paulirish.com/2009/log-a-lightweight-wrapper-for-consolelog/
window.log = function f(){ log.history = log.history || []; log.history.push(arguments); if(this.console) { var args = arguments, newarr; args.callee = args.callee.caller; newarr = [].slice.call(args); if (typeof console.log === 'object') log.apply.call(console.log, console, newarr); else console.log.apply(console, newarr);}};

// make it safe to use console.log always
(function(a){function b(){}for(var c="assert,count,debug,dir,dirxml,error,exception,group,groupCollapsed,groupEnd,info,log,markTimeline,profile,profileEnd,time,timeEnd,trace,warn".split(","),d;!!(d=c.pop());){a[d]=a[d]||b;}})
(function(){try{console.log();return window.console;}catch(a){return (window.console={});}}());


// place any jQuery/helper plugins in here, instead of separate, slower script files.

/*******JQUERY UI IMAGE LOADER PLUGIN v1.4 ************
*
*	by alan clarke
*	created: 6 Apr 2011
*	last update: 7 May 2011
*	alan@staticvoid.info
*
*	Special hanks to the following for their comments and bugfixes:
*		Romain Sauvaire, http://www.jefaisvotresite.com
*		Frank Boers, http://sevideo.se
*
*************************************************/
(function(c){c.widget("ui.imageLoader",{options:{async:true,images:[]},total:0,_init:function(){var a;this.total++;this.loaded=0;this.data=[];this.stats={loaded:0,errored:0,allcomplete:false};if(typeof this.options.images==="string"){var b=[];c.map(c(this.options.images),function(d){b.push(c(d).attr("src"))});this.options.images=b}for(a=0;a<this.options.images.length;a++)this.data.push({init:false,complete:false,error:false,src:this.options.images[a],img:new Image,i:a});for(a=0;a<this.data.length&&
(this.options.async===true||a===0||a<parseInt(this.options.async,10));a++)this._loadImg(a);return this},_loadImg:function(a){var b=this;if(a!==false&&a<b.data.length)if(!b.data[a].init){b.data[a].init=true;b._trigger("start",null,{i:a,data:b.getData()});setTimeout(function(){b.data[a].img.onerror=function(){b.loaded++;b.stats.errored++;b.data[a].error=true;b._trigger("error",null,{i:a,data:b.getData()});b._complete(a)};b.data[a].img.onload=function(){if(b.data[a].img.width<1)return b.data[a].img.onerror();
b.loaded++;b.stats.loaded++;b.data[a].complete=true;b._trigger("complete",null,{i:a,data:b.getData()});b._complete(a)};b.data[a].img.src=b.data[a].src},1)}},_complete:function(a){if(!this.options.async||typeof this.options.async==="number")this._loadImg(this._next(a));if(this.loaded===this.data.length){this._trigger("allcomplete",null,this.getData());this.stats.allcomplete=true}},_next:function(a){var b;for(b=0;b<this.data.length;b++)if(b!==a&&!this.data[b].init)return b;return false},getData:function(){return c.extend(true,
[],this.data)},getStats:function(){return c.extend(true,[],this.stats)},destroy:function(){c.Widget.prototype.destroy.apply(this,arguments)}})})(jQuery);