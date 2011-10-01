package
{
    import flash.display.Graphics;
    import flash.display.Sprite;
    
    public class HasetsuneViewer extends Sprite
    {
        private var g:Graphics;
        public function HasetsuneViewer()
        {
            trace("hoge")
            g = graphics;
            draw();
            
            
            Util.genSrtmFromLazyGPX("h1.gpx");
            
        }
        private function draw():void
        {
            g.lineStyle(1);
            g.drawRect(0,0,100,100);
        }
    }
}   