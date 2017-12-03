package  {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	
	public class DungDisplay extends Block {
		public function DungDisplay():void {
			stop();
			addEventListener(MouseEvent.MOUSE_DOWN, function(e):void {
				remove();
			});
		}
		
		private function remove():void {
			if (this.currentLabel === 'DISPLAY') {
				Game.instance.money -= 10;
				Game.instance.showBonus('CLEAN',-10);
				Game.instance.updateUI();
				gotoAndPlay('REMOVE');
			}
		}
	}
	
}
