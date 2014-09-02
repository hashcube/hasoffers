/* https://mobileapptracking.com
 * Installations and opens will be tracked automatically
 */

function pluginSend(evt, params) {
  NATIVE && NATIVE.plugins && NATIVE.plugins.sendEvent &&
    NATIVE.plugins.sendEvent("HasoffersPlugin", evt,
        JSON.stringify(params || {}));
}

var Hasoffers = Class(function () {
  this.init = function(){
    logger.log("{hasoffers} Registering for events on startup");
  }

  this.setUserIds = function (params) {
    // Allowed params
    // uid : custom user id
    // fb_id: facebook user ID
    // google_id: Google ID if login is based on google
    // twitter_id: Twitter ID
    pluginSend("setUserIds", params);
  }

  this.trackPurchase = function(receipt, sku, name, price, quantity, currency){
    quantity = quantity || 1;

    var params = {
      receipt: receipt,
      sku: sku,
      name: name,
      quantity: quantity,
      unitPrice: price,
      revenue: quantity * price,
      currency: currency || 'USD'
    }

    pluginSend("trackPurchase", params);
  }
  // level can be anything like milestone, ms-1
  // attr something that defines level
  this.trackLevel = function (level, attr) {
    var params = {
      level: level,
      attr: attr
    }
    pluginSend("trackLevel", params);
  }
});

exports = new Hasoffers();
