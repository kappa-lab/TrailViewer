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
        
        static public function getSRTM(lat:Array,lon:Array,callBack:Function=null):void
        {
            var srtmLoader:URLLoader = new URLLoader();
            var srtmReq:URLRequest = new URLRequest("http://localhost:8000/cgi-bin/getsrtm.py");
            srtmReq.method = URLRequestMethod.POST;
            var data:URLVariables = new URLVariables()
            data.lat = lat.join(",");
            data.lon = lon.join(",");
            srtmReq.data = data;
            srtmLoader.addEventListener(Event.COMPLETE,function(e:Event):void{
                srtmLoader.removeEventListener(Event.COMPLETE,arguments.callee);
                
                var elevations:Array = String(srtmLoader.data).split(","); 
                if(callBack!=null)callBack(elevations);
            });
            
            srtmLoader.load(srtmReq);
            
        }
        static public function genSrtmFromLazyGPX(path:String):void
        {
            trace("genSrtmFromLazyGPX",path)
            var loader:URLLoader = new URLLoader();
            loader.addEventListener(Event.COMPLETE,function(e:Event):void{
                loader.removeEventListener(Event.COMPLETE,arguments.callee);
                var xml:XML = new XML(loader.data);
                var trkpts:XMLList = xml.trk.trkseg.trkpt;
                var lat:Array = [];
                var lon:Array = [];
                
                for each(var trkpt:XML in trkpts){
                    lat.push(trkpt.attribute("lat"));
                    lon.push(trkpt.attribute("lon"));
                }

                getSRTM(lat,lon,function(ele:Array):void{
                    var xml2=<gpx><trk><trkseg><trkpt/></trkseg></trk></gpx>;
                    var n:uint= ele.length;
                    var lat1:Number = trkpts[0].attribute("lat");
                    var lon1:Number = trkpts[0].attribute("lon");
                    var distance:Number=0;
                    for(var i:uint=0;i<n;i++){
                        var lat2:Number = trkpts[i].attribute("lat");
                        var lon2:Number = trkpts[i].attribute("lon");
                        var trkpt2:XML = <trkpt lat="" lon="" />;
                        distance += getDistance(lat1,lon1,lat2,lon2);
                        trkpt2.distance = distance;
                        trkpt2.ele=ele[i];
                        trkpt2.attribute("lat")[0]=lat2;
                        trkpt2.attribute("lon")[0]=lon2;
                        lat1=lat2;
                        lon1=lon2;
                        xml2.trk.trkseg.trkpt[i] = trkpt2;
                    }
                    trace(xml2)
                });
                
            });
            loader.load(new URLRequest(path));
        }
        
        static public function buildLazyGPX(elevations:Array,sorce:XML):XML
        {
            var trkpts:XMLList = sorce.trk.trkseg.trkpt;
            var i:Number = 0;
            var lat1:Number = trkpts[0].attribute("lat");
            var lon1:Number = trkpts[0].attribute("lon");
            for each(var trkpt:XML in trkpts){
                var distance:Number
                try{
                    trkpt.ele = Number(elevations[i]);
                    var lat2:Number = trkpts[i].attribute("lat");
                    var lon2:Number = trkpts[i].attribute("lon");
                    trkpt.distance = getDistance(lat1,lon1,lat2,lon2);
                    lat1=lat2;
                    lon1=lon2;
                    i++;
                }catch(e:Error){
                }
            }
            trace(sorce.toXMLString());
            return sorce;
        }            
            
        static public function getDistance(lat1:Number,lon1:Number,lat2:Number,lon2:Number):Number
        {
            //trace("getDistance");
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