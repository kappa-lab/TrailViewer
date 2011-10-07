package
{
    import caurina.transitions.Equations;
    import caurina.transitions.Tweener;
    
    import flash.display.DisplayObjectContainer;
    import flash.display.Graphics;
    import flash.display.Loader;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    
    [SWF (width="1000" , height="500")]
    public class HasetsuneViewer extends Sprite
    {
        private const FASTEST_TIME:uint = 6*60 + 20;
        private const TREKING_TIME:uint = 16*60 ;
        private const T_F_RATE:Number = TREKING_TIME/FASTEST_TIME*1.0;
        private const MARGIN:int = 30;
        private var _loader:URLLoader;
        private var _assetLoader:Loader;
        private var _g:Graphics;
        private var _xml:XML;
        private var _graphHeight:int;
        private var _graphWidth:int;
        private var _baseY:int;
        private var _baseX:int;
        private var _runner:MovieClip;
        private var _walker:MovieClip;
        private var _trkpts:XMLList;
        private var _numTrkpts:uint;
        private var _timeTF:TextField;
        private var _index:int = 0;
        private var _format:TextFormat;
        private var _vLabels:Array=[];
        private var _hLabels:Array=[];
        private var _pxPerDist:Number = .5;
        private var _pxPerElev:Number = .5;
        
        //http://kuler.adobe.com/#themeID/490657
        private var _colors:Array = [0x677F01,0x9ABF02,0xCDFF03,0x334001,0xB9E502];
        
        private var _monoTones:Array = [0xDEDEDE,0xA0A0A0,0x666666];
        
        public function HasetsuneViewer()
        {
            stage.scaleMode = "noScale";
            stage.align = "leftTop";
            stage.addEventListener(Event.RESIZE,onResize);

            _g = graphics;

            _timeTF = addChild(new TextField()) as TextField;
            _timeTF.width = 300;
            _format = new TextFormat("Verdana",10,_colors[3]);
            _timeTF.defaultTextFormat = _format;
            formatTime(0);
            
            for(var i:int = 0; i < 30 ;i++){
                _vLabels.push(new TextField());
                _hLabels.push(new TextField());
            }
            
            onResize()
         
            _loader = new URLLoader();
            _loader.addEventListener(Event.COMPLETE,loadComplete);
            _loader.load(new URLRequest("h1_ele.gpx"));
//            Util.genSrtmFromLazyGPX("h1.gpx");
//            Util.genSrtmFromLazyGPX("h1.gpx",function(xml:XML):void{
//                _xml = xml;
//                drawElevation();
//            });
            
        }
        
        private function onResize(e:Event=null):void
        {
            _g.clear();
            
            _baseY = int(stage.stageHeight - MARGIN);
            _baseX = MARGIN;
            _graphHeight = stage.stageHeight - MARGIN * 2;
            _graphWidth  = stage.stageWidth  - MARGIN * 2;
            
            _timeTF.y = MARGIN;
            _timeTF.x = stage.stageWidth - _timeTF.width - MARGIN;
            
            drawGrid();
            if(_trkpts)drawMap();
            
        }
        private function loadComplete(e:Event=null):void
        {
            _loader.removeEventListener(Event.COMPLETE,loadComplete);
            _xml = new XML(_loader.data);
            _trkpts = _xml.trk.trkseg.trkpt;
            _numTrkpts = _trkpts.length();

            _assetLoader = new Loader();
            _assetLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,assetLoadComplete);
            _assetLoader.load(new URLRequest("runner.swf"));
        }
        private function assetLoadComplete(e:Event=null):void
        {
            _assetLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE,assetLoadComplete);
            _runner = DisplayObjectContainer(_assetLoader.content).getChildAt(0) as MovieClip;
            _walker = DisplayObjectContainer(_assetLoader.content).getChildAt(1) as MovieClip;
            
            _runner.scaleX = _runner.scaleY = 
            _walker.scaleX = _walker.scaleY = .1
            var trkpt:XML = _trkpts[0];
            _runner.x = _walker.x = trkpt.distance*.015 + _baseX - _runner.width*.2;
            _runner.y = _walker.y = _graphHeight - trkpt.ele * .2 - _runner.height - 20;
            
            
            addChild(_runner);
            addChild(_walker);
            
            drawMap();
            
            var count:uint = _trkpts.length() * T_F_RATE;
           // Tweener.addCaller(this,{onUpdate:updateRun,time:count*.05,count:count,transition:Equations.easeNone});
        }

        private function updateRun():void
        {
            var trkpt:XML = _trkpts[int(_index*.3)];
            var x:Number = trkpt.distance*.015 + _baseX - _runner.width*.2;
            var y:Number = _graphHeight - trkpt.ele * .2 - _runner.height - 20;
            Tweener.addTween(_walker,{time:.1,transition:Equations.easeNone,x:x,y:y});

            if(_index<_numTrkpts){
                trkpt = _trkpts[_index];
                x = trkpt.distance*.015 + _baseX - _runner.width*.2;
                y = _graphHeight - trkpt.ele * .2 - _runner.height - 20;
                Tweener.addTween(_runner,{time:.1,transition:Equations.easeNone,x:x,y:y});
            }
            formatTime(_index/(_numTrkpts-1) * FASTEST_TIME);
            
            _index++;
        }
        private function drawMap():void
        {
            _g.lineStyle(1,_colors[0]);
            _g.moveTo(_baseX,_graphHeight - Number(_trkpts[0].ele) * .2);
            for each(var trkpt:XML in _trkpts){
                var x:Number = trkpt.distance*.015 + _baseX;
                var y:Number = _graphHeight - trkpt.ele * .2;
                _g.lineTo(x, y );
                if(trkpt.hasOwnProperty("gate")){
                    var tf:TextField = addChild(new TextField()) as TextField;
                    tf.text = trkpt.gate.name;
                    tf.x = x;
                    tf.y = y;
                    _g.lineStyle(1,_colors[4]);
                    _g.lineTo(x, _baseY);
                    _g.moveTo(x, y);
                    _g.lineStyle(1,_colors[1]);
                }
            }
        }
        private function drawGrid():void
        {
            
            _g.lineStyle(1,0xFFCCCCCC);
            var i:int;
            var n:int=20;
            var tf:TextField
            var x:int;
            n = 30;
            for(i=1;i<n;i+=2){
                 x=_graphWidth/n*i+_baseX;
                _g.moveTo(x,_baseY);
                _g.lineStyle(1,_monoTones[0]);
                _g.lineTo(x, _baseY - _graphHeight);
                    
            }

            n=20
            for(i=1; i < n; i++){
                var y:int =  _baseY - _graphHeight / n * i ;
                _g.moveTo(_baseX,y);
                if(i%2==1){
                    _g.lineStyle(1,_monoTones[0]);
                }else{
                    _g.lineStyle(1,_monoTones[1]);
                    tf = addChild(_vLabels[i]) as TextField;
                    tf.x = 0;
                    tf.y = y - 8;
                    tf.defaultTextFormat = _format;
                    tf.width = MARGIN;
                    tf.textColor = _colors[0]
                    tf.htmlText = "<p align='center'><font size='10'>"+(i).toFixed()+"</font><font size='8'>m</font></p>";
                }
                _g.lineTo(_baseX+_graphWidth, y);

            
            }

            n = 30;
            for(i=2;i<n;i+=2){
                x =_graphWidth/n*i+_baseX;
                _g.moveTo(x,_baseY);
                _g.lineStyle(1,_monoTones[1]);
                tf = addChild(_hLabels[i]) as TextField;
                tf.x = x;
                tf.y = _baseY + 1;
                tf.defaultTextFormat = _format;
                tf.width = MARGIN;
                tf.textColor = _colors[0]
                tf.htmlText = "<p align='center'><font size='10'>"+(i).toFixed()+"</font><font size='8'>m</font></p>";
                _g.lineTo(x, _baseY - _graphHeight);
                
            }

            _g.lineStyle(2,_monoTones[2]);
            _g.drawRect(MARGIN,MARGIN,_graphWidth,_graphHeight);
        }
        
        private function formatTime(min:int):void
        {
            var h:String = String(int(min / 60));
            var m:String = ("0" + String(min % 60)).substr(-2);
            
            _timeTF.htmlText =
                "<p align='right'><font size='40'>"+h+"</font><font size='24'>h </font></p>"
                +"<p align='right'><font size='40'>"+m+"</font><font size='24'>m</font></p>"
            
//            return h +":"+ m;
        }
    }
}   