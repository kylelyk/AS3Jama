package tests {
	import asunit.framework.TestSuite;
	import tests.MatrixTests;
	
	/**
	 * ...
	 * @author Kyle Howell
	 */
	public class AllTests extends TestSuite {
		public function AllTests() {
			super();
			
			//Matrix Class Tests
			addTest(new MatrixTests("TestConstructor"));
			addTest(new MatrixTests("TestConstructFunctions"));
			addTest(new MatrixTests("TestRemainingStaticFunctions"));
			addTest(new MatrixTests("TestCopyFunctions"));
			addTest(new MatrixTests("TestGetSetFunctions"));
		}
	}
}
