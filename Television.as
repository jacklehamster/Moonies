package  {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	
	public class Television extends Block {
		
		
		public function Television() {
			addEventListener(MouseEvent.CLICK,				toggle);
		}
		
		private function toggle(e):void {
			gotoAndStop(currentLabel==='OFF'?'ON':'OFF');
		}
	}
	
}
