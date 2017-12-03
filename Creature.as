package  {
	import flash.utils.getTimer;
	
	public class Creature implements Element {

		public static const SPEED:Number = 5;
		static public var creatures:Array = [];

		public var state:String = 'cocoon';
		public var rotation:Number = 0;
		public var x:Number, y:Number;
		public var id:int = 0;
		public var collisions:Array = [];
		
		public var born:int;
		public var proCreated:int;
		public var eaten:int;
		public var attacked:int;
		
		public var hasDisplay:CreatureDisplay;
		public var speed:Number;
		public var hasSexWith:Creature;
		public var hasPooped:Boolean = true;
		
		public function Creature(x:Number, y:Number, rotation:Number, hasDisplay:CreatureDisplay) {
			var newBorn:Boolean = hasDisplay===null;
			this.x = x;
			this.y = y;
			this.rotation = rotation;
			creatures.push(this);
			this.id = creatures.length;
			born = newBorn ? getTimer() : getTimer()-20000;
			proCreated = newBorn ? getTimer() : getTimer()-20000;
			attacked = newBorn ? getTimer() : getTimer()-5000;
			eaten = newBorn ? getTimer() : getTimer()-10000;
			this.hasDisplay = hasDisplay;
			speed = 0;
			Game.instance.updateUI();
		}
		
		public function isBaby():Boolean {
			return getTimer() - born < 20000;
		}
		
		public function moveAway(creature:Creature):void {
			var dx:Number, dy:Number;
			dx = creature.x - this.x;
			dy = creature.y - this.y;
			creature.rotation = (Math.atan2(dy, dx) * 180 / Math.PI) - 90;			
		}
		
		public function moveAwayFrom(element:Element):void {
			element.moveAway(this);
		}
		
		public function haveSexWith(creature:Creature):void {
			var dx:Number, dy:Number;
			dx = this.x - creature.x;
			dy = this.y - creature.y;
			this.rotation = (Math.atan2(dy, dx) * 180 / Math.PI) + 90;
			creature.rotation = this.rotation + 180;
			
			this.hasSexWith = creature;
			creature.hasSexWith = this;
			this.state = 'sex';
			creature.state = 'sex';
			proCreated = getTimer();
			creature.proCreated = getTimer();
			Game.instance.kissSound.play();

		}
		
		public function canProcreate():Boolean {
			var canProcreateBool:Boolean = !this.isBaby() && !isHungry() 
				&& getTimer() - proCreated > 20000 && getTimer() - attacked > 5000
				&& creatures.length < 50;
			return canProcreateBool;
		}
		
		public function canProcreateWith(element:Element):Boolean {
			if(!(element is Creature)) {
				return false;
			}
			if (!canProcreate()) {
				return false;
			}
			var creature:Creature = element as Creature;
			return (creature.state === 'walk'||creature.state==='stand') && creature.canProcreate();
		}
		
		public function procreateWith(element:Creature):void {
			new Creature(
				(this.x +element.x) / 2,
				(this.y + element.y)/2, 15 * Math.floor(Math.random()*360/15),
				null
			);
			stopSex();
			element.stopSex();
//			trace(Creature.creatures.length);
		}
		
		private function stopSex():void {
			this.hasSexWith = null;
			if(this.state==='sex') {
				this.state = 'stand';
			}
		}
		
		public function grab():Boolean {
			if(this.state !== 'cocoon' && this.state !== 'eat') {
				this.state = isBaby() ? 'babygrabbed' : 'grabbed';	
				if(this.hasSexWith) {
					this.hasSexWith.stopSex();
					this.stopSex();
				}				
				return true;
			}
			return false;
		}
		
		public function ungrab():void {
			this.state = 'stand';				
		}
		
		public function canAttackAnyone():Boolean {
			return !this.isBaby() && getTimer() - proCreated > 15000 && getTimer() - attacked > 3000;
		}
				
		public function canAttack(element:Element):Boolean {
			if(!(element is Creature)) {
				return false;
			}
			if (!canAttackAnyone()) {
				return false;
			}
			var creature:Creature = element as Creature;
			return (creature.state === 'walk'||creature.state==='stand');
		}
		
		public function attack(element:Creature):void {
			var dx:Number, dy:Number;
			dx = this.x - element.x;
			dy = this.y - element.y;
			this.rotation = (Math.atan2(dy, dx) * 180 / Math.PI) + 90;
			
			this.state='attack';
			element.state = 'fall';
			attacked = getTimer();
			element.attacked = getTimer();
			element.rotation = rotation + 180;
		}
		
		public function isHungry():Boolean {
			return !isBaby() && getTimer() - eaten > 60000 && getTimer() - proCreated > 15000;
		}
		
		public function isEating():Boolean {
			return !isBaby() && getTimer() - eaten < 10000;
		}
		
		public function eat():void {
			eaten = getTimer();
			this.state = 'eat';
			this.hasPooped = false;
		}
		
		public function live():void {
			if(this.state==='cocoon' && getTimer() - born < 5000) {
				return;
			}
			if(this.state==='grabbed' || this.state==='babygrabbed') {
				return;
			}
			if (this.state==='sex') {
				if(getTimer() - proCreated > 10000) {
					this.procreateWith(this.hasSexWith);
				}
				return;
			}
			if (this.state==='attack') {
				if(getTimer() - attacked > 1000) {
					this.state==='stand';
				} else {
					return;
				}
			}
			if (this.state==='fall' || this.state==='hungry') {
				return;
			}
			if (isHungry()) {
				this.state = 'hungry';
				return;
			} else if(isEating()) {
				this.state = 'eat';
				return;
			}
			
			if (!hasPooped && getTimer() - eaten > 20000) {
				hasPooped = true;
				if (Math.random()<.5) {
					Game.instance.addDung(this);					
				}
			}
			
			if (collisions.length) {
				var element = collisions[Math.floor(Math.random() * collisions.length)];
				if (this.canProcreateWith(element)) {
					this.haveSexWith(element);
					return;
				} else if(this.canAttack(element)) {
					this.attack(element);
					return;
				} else {
					moveAwayFrom(element);					
				}		
			}
			
			speed = Math.min(isBaby()?10:5,Math.max(0, speed + Math.floor(Math.random()*5 - 2)));
			
			var dx:Number, dy:Number;
			dy = Math.cos(this.rotation * Math.PI / 180);
			dx = -Math.sin(this.rotation * Math.PI / 180);
			if (state==='walk' || state==='babywalk') {
				x += dx * speed;
				y += dy * speed;				
			}
			state = speed > 0 ? (isBaby()?'babywalk':'walk'): (isBaby()?'babystand':'stand');
			if (Math.random() < .1) {
				this.rotation = (this.rotation + (Math.random()<.5 ? -15 : 15) + 360) % 360;
			}
			
		}
		
		public function get dx():Number {
			return -Math.sin(this.rotation * Math.PI / 180);			
		}
		
		public function get dy():Number {
			return Math.cos(this.rotation * Math.PI / 180);			
		}
		
		public function remove():void {
			if(this.hasDisplay) {
				this.hasDisplay.remove();
			}
			var index:int = Creature.creatures.indexOf(this);
			Creature.creatures[index] = Creature.creatures[Creature.creatures.length-1];
			Creature.creatures.pop();
		}

	}
	
}
