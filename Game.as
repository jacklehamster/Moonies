package  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.getTimer;
	import flash.media.Sound;
	
	
	public class Game extends MovieClip {
	
		public var inited:Boolean = false;
		public static const HEIGHT:int = 600;
		public static const WIDTH:int = 800;
		private var walls:Array = [];
		public var gameScene:Sprite = new Sprite();
		public var dungArea:Sprite = new Sprite();
		public var grabbedCreature:Creature = null;
		private var lastOrder:int = 0;
		public var money:int = 100;
		private var orderCount:int = 0;
		private var gainCoin:Sound = new Coin1();
		private var loseCoin:Sound = new Coin2();
		public var kissSound:Sound = new KissSound();
		
		static public var instance:Game;
		
		public function Game() {
			instance = this;
		}
		
		public function addDung(creature:Creature):void {
			var dung = dungArea.addChild(new DungDisplay());
			dung.x = creature.x;
			dung.y = creature.y;
		}
		
		private function processOrders():void {
			if(Creature.creatures.length > 2 && order) {
				var orderAgo:int = getTimer() - lastOrder;
				if(orderAgo > this.orderCount * 10000) {
					if (order.currentLabel==='NOORDER') {
						order.gotoAndPlay("ORDER");
						lastOrder = getTimer();					
					}
				}
			}
		}
		
		private function init(e=null):void {
			addChild(dungArea);
			addChild(gameScene);
			gameScene.buttonMode = true;
			addEventListener(Event.ENTER_FRAME, function(e):void {
				CollisionDetector.processCreatures(Creature.creatures, walls, Block.blocks);
				processNewCreatures();
				displayCreatures();
				processOrders();
			});
			stage.addEventListener(MouseEvent.MOUSE_MOVE, function(e:MouseEvent):void {
				if(grabbedCreature) {
					grabbedCreature.x = e.stageX;
					grabbedCreature.y = e.stageY;
				}
			});
			stage.addEventListener(KeyboardEvent.KEY_DOWN, function(e:KeyboardEvent):void {
				if(e.keyCode===Keyboard.F) {
//					CollisionDetector.OFF = true;
				}
			});
			
			walls = [
				new Wall(Wall.NORTH),
				new Wall(Wall.SOUTH),
				new Wall(Wall.EAST),
				new Wall(Wall.WEST),
			];			
			
			var point:Point = new Point();
			gameScene.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void {
				point.x = e.localX; point.y = e.localY;
				if (!grabbedCreature) {
					var objects:Array = gameScene.getObjectsUnderPoint(point);
					var creature:Creature = objects[0].creature;
					var previousState:String = creature.state;
					if(previousState === 'hungry') {
						creature.eat();
						money -= 25;
						showBonus('FOOD', -25);
						updateUI();
					}else if(creature.grab()) {
						if(previousState === 'fall') {
							money -= 40;
							showBonus('FIRST AID', -40);
							updateUI();
						}
						grabbedCreature = creature;
						Mouse.cursor = MouseCursor.HAND;
						if(creature.hasDisplay.bitmap) {
							creature.hasDisplay.bitmap.parent.addChild(creature.hasDisplay.bitmap);
						}
					}
				} else {
					grabbedCreature.ungrab();
					Mouse.cursor = MouseCursor.AUTO;
					if(order.currentLabel==='ORDER') {
						var orderPoint:Point = order.order.globalToLocal(point);
						if(orderPoint.length < 45) {
							grabbedCreature.remove();
							money += 100;
							showBonus('FILL ORDER', 100);
							orderCount++;
							updateUI();
							order.gotoAndPlay('FULFILLED');
						}
					}
					grabbedCreature = null;
				}
			});
			updateUI();
		}
		
		public function showBonus(msg:String, bonus:int):void {
			if(bonus>0) {
				gainCoin.play();
			} else {
				loseCoin.play();
			}
			var bonusDisplay:Bonus = new Bonus();
			bonusDisplay.label.label.text = (bonus<0?'-':'+') + ' $' + Math.abs(bonus);
			bonusDisplay.label.label2.text = msg;
			bonusDisplay.x = mouseX;
			bonusDisplay.y = mouseY;
			addChild(bonusDisplay);
			bonusDisplay.gotoAndPlay(bonus<0?'NEGATIVE':'POSITIVE');
		}
		
		public function updateUI():void {
			if(ui && ui.label) {
				ui.label.text = "Money: $" + money + (money<=10?' !!!':'') + "\nOrders: " + orderCount + 
					"\nMoonies: " + Creature.creatures.length;
								
			}
			if(money < -100) {
				gameScene.visible = false;
				dungArea.visible = false;
				gotoAndPlay("GAMEOVER", 'GAMEOVER');
			}
		}
		
		private function processNewCreatures():void {
			Creature.creatures.filter(function(creature:Creature, index:int, array:Array):Boolean {
				return !creature.hasDisplay;
			}).forEach(function(creature:Creature, index:int, array:Array):void {
				addChild(new CreatureDisplay(creature));
			});			
		}
		
		private var model:MovieClip = new MovieClip();
		private var bitmapDatas:Object = {};
		public function displayCreatures():void {
			Creature.creatures.forEach(function(creature:Creature, index:int, array:Array):void {
				var creatureDisplay:CreatureDisplay = creature.hasDisplay;
				if(creatureDisplay && creatureDisplay.bitmap) {
					var tag:String = creatureDisplay.currentFrame + "," + creatureDisplay.rotation;
					if (!bitmapDatas[tag]) {
						model.addChild(creatureDisplay);
						var rect:Rectangle = creatureDisplay.getRect(model);
						
						
						var bitmapData:BitmapData = new BitmapData(
							rect.width * 2 + 1,
							rect.height * 2 + 1,
							true, 0
						);
						var matrix:Matrix = new Matrix(
								2,
								0,
								0,
								2,
								-rect.left * 2,
								-rect.top * 2
						);
						
						bitmapData.draw(
							model,
							matrix
						);
						bitmapDatas[tag] = {
							bitmapData: bitmapData,
							x: creatureDisplay.x - rect.left,
							y: creatureDisplay.y - rect.top
						};
						model.removeChild(creatureDisplay);
					}
					creatureDisplay.bitmap.bitmapData = bitmapDatas[tag].bitmapData;
					creatureDisplay.bitmap.x = creatureDisplay.x - bitmapDatas[tag].x;
					creatureDisplay.bitmap.y = creatureDisplay.y - bitmapDatas[tag].y;
				}
			});
		}
	}
	
}
