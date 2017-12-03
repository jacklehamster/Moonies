package  {
	
	public class CollisionDetector {
		static public var OFF:Boolean = false;
		static const COLLISIONDIST = 1800;
		static public function processCreatures(creatures:Array, walls:Array, blocks:Array):void {
			var i:int;
			for(i=0;i<creatures.length;i++) {
				creatures[i].collisions.length = 0;
			}
			for(i=0;i<creatures.length;i++) {
				if (!OFF) {
					if(creatures[i].state==='grabbed' || creatures[i].state==='babygrabbed') {
						continue;
					}
					for(var j=i+1;j<creatures.length;j++) {
						if(creatures[j].state==='grabbed' || creatures[i].state==='babygrabbed') {
							continue;
						}
						var dx = creatures[i].x - creatures[j].x;
						var dy = creatures[i].y - creatures[j].y;
						var distSq = dx*dx + dy*dy;
						if (distSq < COLLISIONDIST) {
							creatures[i].collisions.push(creatures[j]);
							creatures[j].collisions.push(creatures[i]);
						}
					}
				}
				for(var w:int=0; w<walls.length; w++) {
					var wall:Wall = walls[w];
					if(wall.collideWall(creatures[i])) {
						creatures[i].collisions.push(wall);
					}
				}
				for(var b:int=0; b<blocks.length; b++) {
					var block:Block = blocks[b];
					if(block.collideBlock(creatures[i])) {
						creatures[i].collisions.push(block);
					}
				}
			}
		}
	}
	
}
