package  {
	
	public class Wall implements Element {
		
		public static const NORTH:String = 'north';
		public static const SOUTH:String = 'south';
		public static const EAST:String = 'east';
		public static const WEST:String = 'west';
		
		private var type:String;

		public function Wall(type:String) {
			this.type = type;
		}
		
		public function collideWall(element):Boolean {
			switch(type) {
				case NORTH:
					return element.y < 20;
					break;
				case SOUTH:
					return element.y > Game.HEIGHT-20;
					break;
				case EAST:
					return element.x < 20;
					break;
				case WEST:
					return element.x > Game.WIDTH-20;
					break;
			}
			return false;
		}
		
		public function moveAway(creature:Creature):void {
			var dx:Number, dy:Number;
			dy = Math.cos(creature.rotation * Math.PI / 180);
			dx = -Math.sin(creature.rotation * Math.PI / 180);
			switch(type) {
				case NORTH:
					dy = Math.abs(dy);
					break;
				case SOUTH:
					dy = -Math.abs(dy);
					break;
				case EAST:
					dx = Math.abs(dx);
					break;
				case WEST:
					dx = -Math.abs(dx);
					break;
			}
			creature.rotation = (Math.atan2(dy, dx) * 180 / Math.PI) - 90;							
		}
	}
	
}
