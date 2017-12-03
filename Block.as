package  {
	
	import flash.display.MovieClip;
	import flash.geom.Rectangle;
	import flash.events.Event;
	
	
	public class Block extends MovieClip implements Element {
		
		var rect:Rectangle;
		public static var blocks:Array = [];
		
		public function Block():void {
			if(stage) {
				init();
			} else {
				this.addEventListener(Event.ADDED_TO_STAGE, init);
			}
			blocks.push(this);
		}
		
		private function init(e:Event=null):void {
			rect = getRect(root);			
		}
		
		public function collideBlock(element):Boolean {
			var didCollide:Boolean = element.y > rect.top && element.y < rect.bottom
				&& element.x > rect.left && element.x < rect.right;
			return didCollide;
		}
		
		public function moveAway(creature:Creature):void {
			var dx:Number, dy:Number;			
			dx = creature.x - this.x;
			dy = creature.y - this.y;
			creature.rotation = (Math.atan2(dy, dx) * 180 / Math.PI) - 90;			
		}
	}
	
}
