package  {
	import flash.display.Bitmap;
	
	public class CreatureBitmap extends Bitmap {
		public var creature:Creature;
		public function CreatureBitmap(creature:Creature) {
			this.creature = creature;
		}

	}
	
}
