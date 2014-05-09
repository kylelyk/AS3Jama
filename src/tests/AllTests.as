package tests {
	import asunit.framework.TestSuite;
	
	/**
	 * ...
	 * @author Kyle Howell
	 */
	public class AllTests extends TestSuite {
		public function AllTests() {
			super();
			
			//Binary Tree Class Tests (Relies on BinarySearchTree.addData())
			addTest(new MatrixTests("TestInorderTraverse"))
		}
	}
}
