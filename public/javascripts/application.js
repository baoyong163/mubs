// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
// 注册Ajax全局事件Handler，显示Ajax活动指示图标
// From http://mir.aculo.us/2005/11/14/ajax-activity-indicators-with-rails-0-14-3 
Ajax.Responders.register({
	onCreate: function() {
		if($('spinner') && Ajax.activeRequestCount > 0)
		// Effect.Appear('spinner',{duration:0.5,queue:'end'});
		Element.show('spinner');
	},
	onComplete: function() {
		if($('spinner') && Ajax.activeRequestCount == 0)
		Effect.Fade('spinner',{duration:1.0,queue:'end'});
		// Element.hide('spinner');
	}
});