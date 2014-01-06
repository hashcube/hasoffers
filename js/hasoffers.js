function pluginSend(evt, params) {
	NATIVE && NATIVE.plugins && NATIVE.plugins.sendEvent &&
		NATIVE.plugins.sendEvent("HasoffersPlugin", evt,
				JSON.stringify(params || {}));
}

var Hasoffers = Class(function () {
	this.init = function(opts){
		logger.log("{hasoffers} Registering for events on startup");
	}

	this.trackInstall = function(oldClient){
		logger.log("Tracking install for "+oldClient+" user.");

		var params = {"userType":(oldClient)?"old":"new"};

		pluginSend("trackInstall", params);
	}

	this.trackPurchase = function(price, purchaseData, dataSignature){
		var params = {"price": price,
					  "purchaseData": purchaseData,
					  "dataSignature": dataSignature}

		pluginSend("trackPurchase", params);
	}

	this.trackOpen = function() {
		pluginSend("trackOpen");
	}
});

exports = new Hasoffers();