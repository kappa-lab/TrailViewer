package
{
    import flash.display.Graphics;
    import flash.display.Sprite;
    
    public class TrailViewer extends Sprite
    {
        public function TrailViewer()
        {
            var g:Graphics = graphics;
            g.beginFill(0);
            g.drawCircle(200,200,200);
                
            
            var runner:Runner = new Runner();
            addChild(runner);
        }
    }
}