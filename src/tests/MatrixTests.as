package tests {
	import asunit.errors.AssertionFailedError;
	import asunit.framework.Assert;
	import asunit.framework.TestCase;
	import flash.errors.IllegalOperationError;
	import Matrix;
	
	/**
	 * Set of tests for Matrix.as Class. All tests require that the columns, rows, and data getters work.
	 *
	 * @author Kyle Howell
	 */
	public class MatrixTests extends TestCase {
		//private const
		public function MatrixTests(testMethod:String) {
			super(testMethod);
		}
		
		override protected function setUp():void {
			super.setUp();
		}
		
		override protected function tearDown():void {
			super.tearDown();
		}
		
		private function checkSame2D(A:Vector.<Vector.<Number>>, B:Vector.<Vector.<Number>>):void {
			assertEquals("2D arrays do not have matching row dimensions.", A.length, B.length);
			for (var i:int = 0; i < A.length; i++) {
				assertEquals("2D arrays do not have matching column dimensions.", A[i].length, B[i].length);
				for (var j:int = 0; j < A[0].length; j++) {
					if (A[i][j] != B[i][j]) {
						Assert.fail("2D arrays do not match on (" + i + "," + j + ")");
					}
				}
			}
		}
		
		private function checkSame(A:Vector.<Number>, B:Vector.<Number>):void {
			assertEquals("2D arrays do not have matching row dimensions.", A.length, B.length);
			for (var i:int = 0; i < A.length; i++) {
				if (A[i] != B[i]) {
					Assert.fail("2D arrays do not match on " + i);
				}
			}
		
		}
		
		private function checkMatrix(reqrows:int, reqcolumns:int, reqdata:Vector.<Vector.<Number>>, mat:Matrix):void {
			checkSame2D(reqdata, mat.data);
			//trace("reqrows is" +reqrows + ", rows: " + mat.rows)
			//trace("reqcols is" +reqcolumns + ", rows: " + mat.columns)
			assertEquals(reqrows, mat.rows);
			assertEquals(reqcolumns, mat.columns);
		}
		
		public function TestConstructor():void {
			var correct:Vector.<Vector.<Number>> = new <Vector.<Number>>[new <Number>[3, 3, 3, 3, 3, 3], new <Number>[3, 3, 3, 3, 3, 3], new <Number>[3, 3, 3, 3, 3, 3], new <Number>[3, 3, 3, 3, 3, 3], new <Number>[3, 3, 3, 3, 3, 3]];
			
			var M:Matrix = new Matrix(5, 6, 3);
			checkMatrix(5, 6, correct, M);
			
			M = new Matrix(5, 6, 3, null);
			checkMatrix(5, 6, correct, M);
			
			assertThrows(ArgumentError, function():void {
					new Matrix(-1, 6, 3);
				
				})
			assertThrows(ArgumentError, function():void {
					new Matrix(5, -1, 3);
				})
			
			correct = new <Vector.<Number>>[new <Number>[1, 2, 3], new <Number>[4, 5, 6], new <Number>[7, 8, 9]]
			M = new Matrix(5, 6, 3, correct);
			checkMatrix(3, 3, correct, M);
		}
		
		public function TestConstructFunctions():void {
			var correct:Vector.<Vector.<Number>> = new <Vector.<Number>>[new <Number>[3, 3, 3, 3, 3, 3], new <Number>[3, 3, 3, 3, 3, 3], new <Number>[3, 3, 3, 3, 3, 3], new <Number>[3, 3, 3, 3, 3, 3], new <Number>[3, 3, 3, 3, 3, 3]];
			
			//constructWithCopy()
			var M:Matrix = Matrix.constructWithCopy(correct);
			checkMatrix(5, 6, correct, M);
			assertThrows(AssertionFailedError, function():void {
					M.data[0][0] = -1;
					checkSame2D(correct, M.data);
				});
			
			//construct()
			M = Matrix.construct(correct);
			checkMatrix(5, 6, correct, M);
			
			//constructArray()
			checkSame2D(correct, Matrix.constructArray(5, 6, 3));
		}
		
		public function TestRemainingStaticFunctions():void {
			var correct:Vector.<Vector.<Number>> = new <Vector.<Number>>[new <Number>[3, 3, 3, 3, 3, 3], new <Number>[3, 3, 3, 3, 3, 3], new <Number>[3, 3, 3, 3, 3, 3], new <Number>[3, 3, 3, 3, 3, 3], new <Number>[3, 3, 3, 3, 3, 3]];
			
			//isValidMat(), isValidArray()
			var M:Matrix = new Matrix(5, 6, 3);
			assertTrue(Matrix.isValidMat(M));
			assertTrue(Matrix.isValidArray(M.data));
			M.data[0].pop();
			assertFalse(Matrix.isValidMat(M));
			assertFalse(Matrix.isValidArray(M.data));
			
			//transposeArray()
			correct = new <Vector.<Number>>[new <Number>[3], new <Number>[4], new <Number>[3], new <Number>[2], new <Number>[1]];
			checkSame2D(correct, Matrix.transposeArray(new <Number>[3, 4, 3, 2, 1]));
			
			//random()
			for (var i:int = 0; i < 5; i++) {
				M = Matrix.random(5, 6, 2, 5);
				for (var j:int = 0; j < 5; j++) {
					for (var k:int = 0; k < 6; k++) {
						if (M.data[j][k] < 2 || M.data[j][k] > 5) {
							fail("Element (" + j + "," + k + ") is " + M.data[j][k] + " and not in correct range");
						}
					}
				}
			}
			
			//identity()
			correct = new <Vector.<Number>>[new <Number>[1, 0, 0, 0], new <Number>[0, 1, 0, 0], new <Number>[0, 0, 1, 0], new <Number>[0, 0, 0, 1]];
			checkMatrix(4, 4, correct, Matrix.identity(4, 4));
			correct.pop();
			checkMatrix(3, 4, correct, Matrix.identity(3, 4));
			correct = new <Vector.<Number>>[new <Number>[1, 0, 0], new <Number>[0, 1, 0], new <Number>[0, 0, 1], new <Number>[0, 0, 0]];
			checkMatrix(4, 3, correct, Matrix.identity(4, 3));
		}
		
		public function TestCopyFunctions():void {
			var correct:Vector.<Vector.<Number>> = new <Vector.<Number>>[new <Number>[3, 3, 3, 3, 3, 3], new <Number>[3, 3, 3, 3, 3, 3], new <Number>[3, 3, 3, 3, 3, 3], new <Number>[3, 3, 3, 3, 3, 3], new <Number>[3, 3, 3, 3, 3, 3]];
			
			//copy()
			var M:Matrix = Matrix.construct(correct);
			var copy:Matrix = M.copy();
			checkMatrix(5, 6, correct, copy);
			assertThrows(AssertionFailedError, function():void {
					M.data[0][0] = -1;
					checkSame2D(correct, copy.data);
				});
			
			//getArrayCopy()
			var copyArray:Vector.<Vector.<Number>> = M.getArrayCopy();
			checkSame2D(correct, copyArray);
			assertThrows(AssertionFailedError, function():void {
					M.data[0][0] = -1;
					checkSame2D(correct, copyArray);
				});
			
			//getColumnPackedCopy()
			correct = new <Vector.<Number>>[new <Number>[3, 3], new <Number>[4, 4], new <Number>[5, 5], new <Number>[6, 6], new <Number>[7, 7]];
			M = Matrix.construct(correct);
			checkSame(new <Number>[3, 4, 5, 6, 7, 3, 4, 5, 6, 7], M.getColumnPackedCopy());
			
			//getRowPackedCopy()
			checkSame(new <Number>[3, 3, 4, 4, 5, 5, 6, 6, 7, 7], M.getRowPackedCopy());
		}
		
		public function TestGetSetFunctions():void {
			var correct:Vector.<Vector.<Number>> = new <Vector.<Number>>[new <Number>[0.0, 0.1, 0.2, 0.3], new <Number>[1.0, 1.1, 1.2, 1.3], new <Number>[2.0, 2.1, 2.2, 2.3], new <Number>[3.0, 3.1, 3.2, 3.3]];
			
			//getAt()
			var M:Matrix = Matrix.construct(correct);
			for (var i:int = 0; i < M.rows; i++) {
				for (var j:int = 0; j < M.columns; j++) {
					assertEquals(correct[i][j], M.getAt(i, j));
				}
			}
			assertThrows(RangeError, function():void {
					M.getAt(-1, 0);
				});
			assertThrows(RangeError, function():void {
					M.getAt(3, 4);
				});
			assertThrows(RangeError, function():void {
					M.getAt(4, 3);
				});
			
			//getMatrix()
			checkSame2D(new <Vector.<Number>>[new <Number>[1.2, 1.3], new <Number>[2.2, 2.3]], M.getMatrix(1, 2, 2, 3).data);
			checkSame2D(new <Vector.<Number>>[new <Number>[1.2]], M.getMatrix(1, 1, 2, 2).data);
			checkSame2D(new <Vector.<Number>>[new <Number>[2.2], new <Number>[1.2]], M.getMatrix(2, 1, 2, 2).data);
			checkSame2D(new <Vector.<Number>>[new <Number>[1.3, 1.2, 1.1], new <Number>[2.3, 2.2, 2.1], new <Number>[3.3, 3.2, 3.1]], M.getMatrix(1, 3, 3, 1).data);
			checkSame2D(new <Vector.<Number>>[new <Number>[3.3, 3.2, 3.1], new <Number>[2.3, 2.2, 2.1]], M.getMatrix(3, 2, 3, 1).data);
			
			checkSame2D(new <Vector.<Number>>[new <Number>[1.1, 1.2, 1.3], new <Number>[1.1, 1.2, 1.3], new <Number>[3.1, 3.2, 3.3], new <Number>[3.1, 3.2, 3.3]], M.getMatrix(-1, -1, 1, 3, new <int>[1, 1, 3, 3]).data);
			checkSame2D(new <Vector.<Number>>[new <Number>[1.3, 1.2, 1.1], new <Number>[1.3, 1.2, 1.1], new <Number>[3.3, 3.2, 3.1], new <Number>[3.3, 3.2, 3.1]], M.getMatrix(-1, -1, 3, 1, new <int>[1, 1, 3, 3]).data);
			checkSame2D(new <Vector.<Number>>[new <Number>[1.1, 1.1, 1.3, 1.3], new <Number>[2.1, 2.1, 2.3, 2.3], new <Number>[3.1, 3.1, 3.3, 3.3]], M.getMatrix(1, 3, -1, -1, null, new <int>[1, 1, 3, 3]).data);
			checkSame2D(new <Vector.<Number>>[new <Number>[3.1, 3.1, 3.3, 3.3], new <Number>[2.1, 2.1, 2.3, 2.3], new <Number>[1.1, 1.1, 1.3, 1.3]], M.getMatrix(3, 1, -1, -1, null, new <int>[1, 1, 3, 3]).data);
			checkSame2D(new <Vector.<Number>>[new <Number>[1.1, 1.1, 1.3, 1.3], new <Number>[2.1, 2.1, 2.3, 2.3], new <Number>[3.1, 3.1, 3.3, 3.3]], M.getMatrix(-1, -1, -1, -1, new <int>[1, 2, 3], new <int>[1, 1, 3, 3]).data);
			checkSame2D(new <Vector.<Number>>[new <Number>[3.1, 3.1, 3.3, 3.3], new <Number>[2.1, 2.1, 2.3, 2.3], new <Number>[1.1, 1.1, 1.3, 1.3]], M.getMatrix(-1, -1, -1, -1, new <int>[3, 2, 1], new <int>[1, 1, 3, 3]).data);
			
			assertThrows(RangeError, function():void {
					M.getMatrix(-2, 0, 0, 0);
				});
			assertThrows(RangeError, function():void {
					M.getMatrix(0, 0, -2, 0);
				});
			assertThrows(IllegalOperationError, function():void {
					M.getMatrix(0, 0, -1, 0);
				});
			assertThrows(IllegalOperationError, function():void {
					M.getMatrix(0, 0, -1, 0, new <int>[3, 2, 1]);
				});
			assertThrows(IllegalOperationError, function():void {
					M.getMatrix(0, -1, 0, 0, null, new <int>[3, 2, 1]);
				});
			
			//setAt()
			M.setAt(0, 1, -1);
			M.setAt(3, 3, -1);
			for (i = 0; i < M.rows; i++) {
				for (j = 0; j < M.columns; j++) {
					if ((i == 0 && j == 1) || (i == 3 && j == 3)) {
						assertEquals( -1, M.data[i][j]);
					} else {
						assertEquals(correct[i][j], M.data[i][j]);
					}
				}
			}
			assertThrows(Error, function():void {
					M.setAt(-1, 0, 42);
				});
			assertThrows(Error, function():void {
					M.setAt(3, 4, 42);
				});
			assertThrows(Error, function():void {
					M.setAt(4, 3, 42);
				});
		}
	}
}