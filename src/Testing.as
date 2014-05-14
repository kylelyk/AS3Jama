package {
	import flash.display.Sprite;
	import flash.events.Event;
	import Matrix;
	import LUDecomposition;
	import asunit.textui.TestRunner;
	import tests.AllTests;
	
	/**
	 * ...
	 * @author Kyle Howell
	 */
	public class Testing extends Sprite {
		
		public function Testing():void {
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			var unittests:TestRunner = new TestRunner();
			stage.addChild(unittests);
			unittests.start(tests.AllTests, null, TestRunner.SHOW_TRACE);
		}
	}
}