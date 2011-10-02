package
{
    import flash.display.Graphics;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.text.TextField;
    
    [SWF (width="1000" , height="500")]
    public class HasetsuneViewer extends Sprite
    {
        private var _loader:URLLoader;
        private var _g:Graphics;
        private var _xml:XML;
        private var _graphHeight:int;
        private var _graphWidth:int;
        private var _baseY:int;
        private var _baseX:int;
        
        public function HasetsuneViewer()
        {
            _baseY = int(stage.stageHeight / 2);
            _baseX = 40;
            _graphHeight = stage.stageHeight - 40;
            _graphWidth  = stage.stageWidth;
            _g = graphics;
            drawGrid();
            
            _loader = new URLLoader();
            _loader.addEventListener(Event.COMPLETE,loadComplete);
            _loader.load(new URLRequest("h1_ele.gpx"));
//            Util.genSrtmFromLazyGPX("h1.gpx");
            
        }
        private function loadComplete(e:Event=null):void
        {
            _loader.removeEventListener(Event.COMPLETE,loadComplete);
            _xml = new XML(_loader.data);
            drawElevation();
        }
        private function drawElevation():void
        {
            _g.lineStyle(1,0xFFFF0000);
            var i:int = 0;
            var trkpts:XMLList = _xml.trk.trkseg.trkpt;

            _g.moveTo(_baseX,_graphHeight - Number(trkpts[0].ele) * .2);

            for each(var trkpt:XML in trkpts){
                _g.lineTo(Number(trkpt.distance*.01) + _baseX, _graphHeight - Number(trkpt.ele) * .2 );
                i++;
            }
        }
        private function drawGrid():void
        {
            
            _g.lineStyle(1,0xFFCCCCCC);
            var i:int;
            var n:int=20;
            var tf:TextField
            for(i=1;i<n;i++){
                var y:int = _graphHeight / n * i;
                tf = addChild(new TextField()) as TextField;
                tf.x = 5;
                tf.y = y;
                tf.text = String((_graphHeight-y)*5)+"m";

                _g.moveTo(_baseX,y);
                _g.lineTo(_graphWidth,y);
                
            }

            n = 20;
            for(i=1;i<n;i++){
                var x:int =_graphWidth/20*i+_baseX;
                tf = addChild(new TextField()) as TextField;
                tf.x = x;
                tf.y = _graphHeight+1;
                tf.text = String(x*.15)+"km";
                    
                _g.moveTo(x,0);
                _g.lineTo(x,_graphHeight);
                
            }

            _g.lineStyle(2);
            _g.moveTo(_baseX,0);
            _g.lineTo(_baseX,_graphHeight);
            _g.lineTo(_graphWidth,_graphHeight);
        }
    }
}   