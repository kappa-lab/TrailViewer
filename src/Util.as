package
{
    import flash.events.Event;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.net.URLRequestMethod;
    import flash.net.URLVariables;
    
    import flashx.textLayout.formats.FormatValue;

    public class Util
    {
        static function genSrtmFromLazyGPX(path:String):void
        {
            trace("genSrtmFromLazyGPX",path)
            var loader:URLLoader = new URLLoader();
            loader.addEventListener(Event.COMPLETE,function(e):void{
                loader.removeEventListener(Event.COMPLETE,arguments.callee);
                var xml:XML = new XML(loader.data);
                var trkpts:XMLList = xml.trk.trkseg.trkpt;
                var lat:Array = [];
                var lon:Array = [];
                
                for each(var trkpt:XML in trkpts){
                    lat.push(trkpt.attribute("lat"));
                    lon.push(trkpt.attribute("lon"));
                }
                
                var srtmLoader:URLLoader = new URLLoader();
                var srtmReq:URLRequest = new URLRequest("http://localhost:8000/cgi-bin/getsrtm.py");
                srtmReq.method = URLRequestMethod.POST;
                var data:URLVariables = new URLVariables()
                data.lat = lat.join(",");
                data.lon = lon.join(",");
                //trace(data.lat)
                //trace(data.lon)
                srtmReq.data = data;
                srtmLoader.addEventListener(Event.COMPLETE,function(e:Event):void{
                    srtmLoader.removeEventListener(Event.COMPLETE,arguments.callee);
                    trace(srtmLoader.data)
                    var elevations:Array = String(srtmLoader.data).split(","); 
                    var i:Number = 0;
                    for each(var trkpt:XML in trkpts){
                        try{
                            trkpt.ele = Number(elevations[i++]);
                        }catch(e:Error){
                            
                        }
                    }
                    trace(xml.toXMLString());
                });

                srtmLoader.load(srtmReq);
                
            });
            loader.load(new URLRequest(path));
        }
        
        static function getDistance(lat1:Number,lon1:Number,lat2:Number,lon2:Number):Number
        {
            trace("getDistance");
            var from_x:Number = lon1 * Math.PI / 180;
            var from_y:Number = lat1 * Math.PI / 180;
            var to_x:Number   = lon2 * Math.PI / 180;
            var to_y:Number   = lat2 * Math.PI / 180;
            
            var deg:Number = Math.sin(from_y) 
                            * Math.sin(to_y) 
                            + Math.cos(from_y)
                            * Math.cos(to_y)
                            * Math.cos(to_x-from_x);
            
            return 6378140 * (Math.atan( -deg / Math.sqrt( -deg * deg + 1)) + Math.PI / 2);            
        }
    }
}