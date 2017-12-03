package  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	
	
	public class CreatureDisplay extends MovieClip {
		
		private var creature:Creature;
		private var state:String;
		public var bitmap:Bitmap;
		
		public function CreatureDisplay(creature:Creature = null) {
			init(creature ? creature : new Creature(x,y,rotation, this));
		}
		
		private function init(creature:Creature):void {
			gotoAndStop(1);
			this.creature = creature;
			this.x = this.creature.x;
			this.y = this.creature.y;
			this.rotation = this.creature.rotation;
			this.scaleX = this.scaleY = .18;
			this.creature.hasDisplay = this;
			
			addEventListener(Event.ENTER_FRAME, live);
		}
		
		public function remove():void {
			if(parent) {
				parent.removeChild(this);				
			}
			if(bitmap) {
				if(bitmap.parent) {
					bitmap.parent.removeChild(bitmap);
				}
			}
			removeEventListener(Event.ENTER_FRAME, live);
		}
		
		private function live(e:Event) {
			if(parent) {
				var master:Game = parent as Game;
				master.removeChild(this);
				this.bitmap = new CreatureBitmap(this.creature);
				this.bitmap.scaleX = .5;
				this.bitmap.scaleY = .5;
				master.gameScene.addChild(this.bitmap);
			}
			creature.live();
			refresh();
		}
		
		private function refresh():void {
			if (state !== this.creature.state) {
				switch(this.creature.state) {
				case 'sex':
					if(this.creature.id < this.creature.hasSexWith.id) {
						gotoAndStop('INVIS');
					} else {
						gotoAndPlay('SEX');
					}
					break;
				case 'attack':
					gotoAndPlay('ATTACK');
					break;
				case 'fall':
					gotoAndPlay('FALL');
					if(bitmap) {
						bitmap.parent.setChildIndex(bitmap, 0);
					}
					break;
				case 'babywalk':
					gotoAndPlay('BABYWALK');
					break;
				case 'babystand':
					gotoAndStop('BABYSTAND');
					break;	
				case 'walk':
					gotoAndPlay('WALK');
					break;
				case 'stand':
					gotoAndStop(1);
					break;	
				case 'cocoon':
					gotoAndPlay('COCOON');
					break;
				case 'grabbed':
					gotoAndPlay('GRABBED');
					break;
				case 'babygrabbed':
					gotoAndPlay('BABYGRABBED');
					break;
				case 'hungry':
					gotoAndPlay('HUNGRY');
					break;
				case 'eat':
					gotoAndPlay('EAT');
					break;
				}
				state = this.creature.state;
			}
			x = this.creature.x;
			y = this.creature.y;
			//this.rotation = this.creature.rotation;
			if (this.creature.state==='fall' || this.creature.state==='attack') {
				this.rotation = this.creature.rotation;
			} else if (this.creature.state==='grabbed' 
					|| this.creature.state==='babygrabbed'
					|| this.creature.state==='cocoon'
					|| this.creature.state==='hungry'
					|| this.creature.state==='eat') {
				this.rotation = 0;
			} else {
				var diff = (this.creature.rotation - this.rotation + 360)%360;
				if (Math.abs(diff)> 5) {
					if (diff > 180) {
						this.rotation -= Math.abs(diff) > 20 ? 10 : 5;
					} else if(diff<180) {
						this.rotation += Math.abs(diff) > 20 ? 10 : 5;				
					}				
				}				
			}
		}
	}
	
}
