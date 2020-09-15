String.prototype.replaceAll = function (find, replace) {
     var str = this;
     return str.replace(new RegExp(find.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&'), 'g'), replace);
 };

function OkServer(url){
	var datos_server;
    $.ajax({
      type: "GET",
      url: url,
      dataType: "text",
      async:false,
      cache: false,
      success: function (html) {    
        var list = { 'PelisPedia' :[] };
       	$("div[data-module='OKVideo']", html).each(function(){
        var data_video = $(this).attr("data-options")        
		var final = "{" + data_video.substring(data_video.lastIndexOf("\\\"videos"), data_video.lastIndexOf(",\\\"metadataEmbedded")).replaceAll("\\&quot;", "\"").replaceAll("\\u0026", "&").replaceAll("\\", "").replaceAll("%3B", ";") + "}";
        var jsonData = JSON.parse(final);
        if (jsonData.videos.length > 0) {
        for (var i = 0; i < jsonData.videos.length; i++) {
            var file = jsonData.videos[i].url.replaceAll("ct=0", "ct=4");
            var label = jsonData.videos[i].name;
            var type = "mp4";
            list.PelisPedia.push({
              "file": file,
              "label": label,
              "type": type
            });
          }
         } else {
             datos_server = false;
         }
        });
        datos_server = JSON.stringify(list);
      }
    }).fail(function () {
        datos_server = false;
    });
 return datos_server;
}

function FembedServer(url){
	var datos_server;
    $.ajax({
      type: "POST",
      url: url.replaceAll('/v/', '/api/source/'),
      dataType: "json",
      async:false,
      cache: false,
      success: function (data) {    
        var list = { 'PelisPedia' :[] };
        if (data.data.length >= 1) {
        for (var i = 0; i < data.data.length; i++) {
            var file = data.data[i].file;
            var label = data.data[i].label;
            var type = data.data[i].type;
            list.PelisPedia.push({
              "file": file,
              "label": label,
              "type": type
            });
        }
        datos_server = JSON.stringify(list);
        }else{
           datos_server = false;
        }
      }
    }).fail(function () {
        datos_server = false;
    });
 return datos_server;
}

function Servidores(url){
    
    if (url.match(/drive.google/)) {
        return GoogleDriveServer(url);
    } else 
    if (url.match(/yadi.sk/)) {
        return YandexServer(url);
    } else 
    if (url.match(/pmo:/)) {
        return PlaymemoriesServer(url);
    } else 
    if (url.match(/ok.ru/)) {
        return OkServer(url);
    } else 
    if (url.match(/fembed/)) {
        return FembedServer(url);
    } else {
        return "not_supported";
    }
}
