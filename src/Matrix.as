package {
	import util.Maths;
	import flash.errors.IllegalOperationError;
	
	/**
	 * ...
	 * @author Kyle Howell
	 */
	public class Matrix {
		
		/**
		   Jama = Java Matrix class.
		   <P>
		   The Java Matrix Class provides the fundamental operations of numerical
		   linear algebra.  Various constructors create Matrices from two dimensional
		   arrays of double precision floating point numbers.  Various "gets" and
		   "sets" provide access to submatrices and matrix elements.  Several methods
		   implement basic matrix arithmetic, including matrix addition and
		   multiplication, matrix norms, and element-by-element array operations.
		   Methods for reading and printing matrices are also included.  All the
		   operations in this version of the Matrix Class involve real matrices.
		   Complex matrices may be handled in a future version.
		   <P>
		   Five fundamental matrix decompositions, which consist of pairs or triples
		   of matrices, permutation vectors, and the like, produce results in five
		   decomposition classes.  These decompositions are accessed by the Matrix
		   class to compute solutions of simultaneous linear equations, determinants,
		   inverses and other matrix functions.  The five decompositions are:
		   <P><UL>
		   <LI>Cholesky Decomposition of symmetric, positive definite matrices.
		   <LI>LU Decomposition of rectangular matrices.
		   <LI>QR Decomposition of rectangular matrices.
		   <LI>Singular Value Decomposition of rectangular matrices.
		   <LI>Eigenvalue Decomposition of both symmetric and nonsymmetric square matrices.
		   </UL>
		   <DL>
		   <DT><B>Example of use:</B></DT>
		   <P>
		   <DD>Solve a linear system A x = b and compute the residual norm, ||b - A x||.
		   <P><PRE>
		   double[][] vals = {{1.,2.,3},{4.,5.,6.},{7.,8.,10.}};
		   Matrix A = new Matrix(vals);
		   Matrix b = Matrix.random(3,1);
		   Matrix x = A.solve(b);
		   Matrix r = A.times(x).minus(b);
		   double rnorm = r.normInf();
		   </PRE></DD>
		   </DL>
		
		   @author The MathWorks, Inc. and the National Institute of Standards and Technology.
		   @version 5 August 1998
		 */
		
		/* ------------------------
		   Class variables
		 * ------------------------ */
		
		/** Array for internal storage of elements.
		   @serial internal array storage.
		 */
		private var A:Vector.<Vector.<Number>>;
		
		/** Row and column dimensions.
		   @serial row dimension.
		   @serial column dimension.
		 */
		private var m:int, n:int;
		
		/* ------------------------
		   Constructors
		 * ------------------------ */
		
		/** If a 2D array is given, create a Matrix with that array ignoring all other parameters. Otherwise construct an m-by-n matrix with the scalar fill value of your chosing.
		 * @param m    Number of rows.
		 * @param n    Number of colums.
		 * @param fill Fill the matrix with this scalar value.
		 * @param A    A 2D array.
		 */
		public function Matrix(m:int, n:int, fill:Number = 0, A:Vector.<Vector.<Number>> = null) {
			if (A) {
				if (!isValidArray(A)) {
					throw new ArgumentError("Supplied 2D array is invalid and cannot be used to create a Matrix.");
				}
				this.m = A.length;
				this.n = A[0].length;
				this.A = A;
			} else {
				this.m = m;
				this.n = n;
				this.A = constructArray(m, n, fill);
			}
		}
		
		/* ------------------------
		   Static Methods
		 * ------------------------ */
		
		/**
		 * Construct a matrix from a copy of a 2-D array.
		 * @param A   	Two-dimensional array of numbers.
		 * @throws 		ArgumentError All rows must have the same length
		 */
		public static function constructWithCopy(A:Vector.<Vector.<Number>>):Matrix {
			var m:int = A.length;
			var n:int = A[0].length;
			var X:Matrix = new Matrix(m, n);
			var C:Vector.<Vector.<Number>> = X.data;
			for (var i:int = 0; i < m; i++) {
				if (A[i].length != n) {
					throw new ArgumentError("All rows must have the same length.");
				}
				for (var j:int = 0; j < n; j++) {
					C[i][j] = A[i][j];
				}
			}
			return X;
		}
		
		/**
		 * Construct a matrix from a 2-D array.
		 * @param A   	Two-dimensional array of numbers.
		 * @throws 		ArgumentError All rows must have the same length
		 */
		public static function construct(A:Vector.<Vector.<Number>>):Matrix {
			return new Matrix(-1, -1, -1, A);
		}
		
		/**
		 * Construct a 2D Array without the Matrix class.
		 * @param A   	Two-dimensional array of numbers.
		 * @param fill  Fill the matrix with this scalar value.
		 * @throws 		ArgumentError All rows must have the same length
		 */
		public static function constructArray(m:int, n:int, fill:Number = 0):Vector.<Vector.<Number>> {
			if (m < 1 || n < 1) {
				throw new ArgumentError("Array dimensions should be more than 0.");
			}
			var mat:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>(m);
			for (var i:int = 0; i < m; i++) {
				mat[i] = new Vector.<Number>(n);
				if (fill != 0) {
					for (var j:int = 0; j < n; j++) {
						mat[i][j] = fill;
					}
				}
			}
			return mat;
		}
		
		public static function isValidMat(A:Matrix):Boolean {
			return isValidArray(A.A);
		}
		
		public static function isValidArray(A:Vector.<Vector.<Number>>):Boolean {
			if (A.length == 1) {
				return A[0].length == 1;
			}
			var size:int = A[0].length;
			for (var i:int = 1; i < A.length; i++) {
				if (size != A[i].length) {
					return false;
				}
			}
			return true;
		}
		
		/**
		 * Flips a 1xN horizontal array into a Nx1 vertical array
		 * @param A   	Two-dimensional array of numbers.
		 * @throws 		ArgumentError All rows must have the same length
		 */
		public static function transposeArray(A:Vector.<Number>):Vector.<Vector.<Number>> {
			var M:Vector.<Vector.<Number>> = Matrix.constructArray(A.length, 1);
			for (var i:int = 0; i < A.length; i++) {
				M[i] = new <Number>[A[i]];
			}
			return M;
		}
		
		/** Generate matrix with random elements: min <= elm < max
		 * @param m    Number of rows.
		 * @param n    Number of colums.
		 * @param min  The minimum value of an element.
		 * @param max  The maximum value of an element.
		 * @return     An m-by-n matrix with uniformly distributed random elements.
		 */
		public static function random(m:int, n:int, min:Number = 0, max:Number = 1):Matrix {
			var A:Matrix = new Matrix(m, n);
			var X:Vector.<Vector.<Number>> = A.data;
			for (var i:int = 0; i < m; i++) {
				for (var j:int = 0; j < n; j++) {
					X[i][j] = Math.random() * (max - min) + min;
				}
			}
			return A;
		}
		
		/** Generate identity matrix
		 * @param m    Number of rows.
		 * @param n    Number of colums.
		 * @return     An m-by-n matrix with ones on the diagonal and zeros elsewhere.
		 */
		public static function identity(m:int, n:int):Matrix {
			var A:Matrix = new Matrix(m, n);
			var X:Vector.<Vector.<Number>> = A.data;
			for (var i:int = 0; i < m; i++) {
				for (var j:int = 0; j < n; j++) {
					X[i][j] = (i == j ? 1.0 : 0.0);
				}
			}
			return A;
		}
		
		/* ------------------------
		   Public Methods
		 * ------------------------ */
		
		/**
		 * Make a deep copy of a matrix
		 */
		public function copy():Matrix {
			var X:Matrix = new Matrix(m, n);
			var C:Vector.<Vector.<Number>> = X.data;
			for (var i:int = 0; i < m; i++) {
				for (var j:int = 0; j < n; j++) {
					C[i][j] = A[i][j];
				}
			}
			return X;
		}
		
		/**
		 * Clone the Matrix object.
		 */
		public function clone():Object {
			return copy();
		}
		
		/**
		 * Copy the internal two-dimensional array.
		 * @return     Two-dimensional array copy of matrix elements.
		 */
		public function getArrayCopy():Vector.<Vector.<Number>> {
			var C:Vector.<Vector.<Number>> = Matrix.constructArray(m, n);
			for (var i:int = 0; i < m; i++) {
				for (var j:int = 0; j < n; j++) {
					C[i][j] = A[i][j];
				}
			}
			return C;
		}
		
		/**
		 * Make a one-dimensional column packed copy of the internal array.
		 * @return     Matrix elements packed in a one-dimensional array by columns.
		 */
		public function getColumnPackedCopy():Vector.<Number> {
			var vals:Vector.<Number> = new Vector.<Number>(m * n);
			for (var i:int = 0; i < m; i++) {
				for (var j:int = 0; j < n; j++) {
					vals[i + j * m] = A[i][j];
				}
			}
			return vals;
		}
		
		/**
		 * Make a one-dimensional row packed copy of the internal array.
		 * @return     Matrix elements packed in a one-dimensional array by rows.
		 */
		public function getRowPackedCopy():Vector.<Number> {
			var vals:Vector.<Number> = new Vector.<Number>(m * n);
			for (var i:int = 0; i < m; i++) {
				for (var j:int = 0; j < n; j++) {
					vals[i * n + j] = A[i][j];
				}
			}
			return vals;
		}
		
		/**
		 * Get a single element.
		 * @param i    Row index.
		 * @param j    Column index.
		 * @return     A(i,j)
		 * @throws  RangeError
		 */
		public function getAt(i:int, j:int):Number {
			return A[i][j];
		}
		
		/**
		 * Get a submatrix.
		 * Specify either the range or the vector of values for both the row and column.
		 * Leaving default will ignore those options.
		 *
		 * Valid uses include:
		 * A.getMatrix(0, 3, 0, 4);											//get columns 0 through 4 of rows 0 through 3
		 * A.getMatrix(0, 3, -1, -1, null, new <int>[1,4,6,7]);				//get columns 1,4,6,7 of rows 0 through 3
		 * A.getMatrix(-1, -1, -1, -1, new <int>[1,2,6], new <int>[1,4,6]);	//matrix returned:	(1,1)	(1,4)	(1,6)
		 * 																						(2,1)	(2,4)	(2,6)
		 * 																						(6,1)	(6,4)	(6,6)
		 * A.getMatrix(-1, -1, 3, 5, new <int>[3,5,6]);						//get rows 3,5,6 of columns 3 through 5
		 *
		 * Calling A.getMatrix(1, 4, 0, 3, new <int>[1,2,4], new <int>[3,4]) is equivalent to A.getMatrix(1, 4, 0, 3) because the first valid parameter for row and column specification is always used.
		 *
		 * Specifying a smaller final row/column index than the initial row/column index reverses those rows/columns.
		 * Additionally, the individual values in the arrays can be in any order and repeats are allowed.
		 *
		 * @param r0   Initial row index
		 * @param r1   Final row index
		 * @param c0   Initial column index
		 * @param c1   Final column index
		 * @return     A(i0:i1,j0:j1)
		 * @throws  IllegalOperationError 	If not enough information if given (too many defaults left unchanged).
		 * @throws  RangeError 				If matrix index is out of bounds.
		 */
		public function getMatrix(r0:int = -1, r1:int = -1, c0:int = -1, c1:int = -1, rvect:Vector.<int> = null, cvect:Vector.<int> = null):Matrix {
			
			if ((r0 == -1 || r1 == -1) && !rvect) {
				throw new IllegalOperationError("Either Column list or Column range must be specified.");
			}else if ((c0 == -1 || c1 == -1) && !cvect) {
				throw new IllegalOperationError("Either Row list or Row range must be specified.");
			}
			
			var B:Vector.<Vector.<Number>>
			var X:Matrix;
			var i:int, j:int;
			var rRange:Boolean = (r0 != -1 || r1 != -1);
			var cRange:Boolean = (c0 != -1 || c1 != -1);
			if (rRange) {
				if (cRange) {
					
					//Row range and Column range
					X = new Matrix(Math.abs(r1 - r0) + 1, Math.abs(c1 - c0) + 1);
					B = X.data;
					try {
						if (r0 <= r1 && c0 <= c1) {
							for (i = r0; i <= r1; i++) {
								for (j = c0; j <= c1; j++) {
									B[i - r0][j - c0] = A[i][j];
								}
							}
						} else if (c0 <= c1) {
							for (i = r0; i >= r1; i--) {
								for (j = c0; j <= c1; j++) {
									trace("Setting (" + (r0 - i) + "," + (j - c0) + ") to " + A[i][j]);
									B[r0 - i][j - c0] = A[i][j];
								}
							}
						} else if (r0 <= r1) {
							for (i = r0; i <= r1; i++) {
								for (j = c0; j >= c1; j--) {
									B[i - r0][c0 - j] = A[i][j];
								}
							}
						} else {
							for (i = r0; i >= r1; i--) {
								for (j = c0; j >= c1; j--) {
									B[r0 - i][c0 - j] = A[i][j];
								}
							}
						}
					}
					catch (e:Error) {
						throw new RangeError("Submatrix indices are out of bounds.");
					}
					return X;
					
				} else {
					
					
					//Row range, Column list
					X = new Matrix(Math.abs(r1 - r0) + 1, cvect.length);
					B = X.data;
					try {
						if (r0 <= r1) {
							for (i = r0; i <= r1; i++) {
								for (j = 0; j < cvect.length; j++) {
									B[i - r0][j] = A[i][cvect[j]];
								}
							}
						} else {
							for (i = r0; i >= r1; i--) {
								for (j = 0; j < cvect.length; j++) {
									B[r0 - i][j] = A[i][cvect[j]];
								}
							}
						}
					}
					catch (e:Error) {
						throw new RangeError("Submatrix indices are out of bounds.");
					}
					return X;
					
				}
			} else {
				if (cRange) {
					
					//Row list, Column range
					X = new Matrix(rvect.length, Math.abs(c1 - c0) + 1);
					B = X.data;
					try {
						if (c0 <= c1) {
							for (i = 0; i < rvect.length; i++) {
								for (j = c0; j <= c1; j++) {
									B[i][j - c0] = A[rvect[i]][j];
								}
							}
						} else {
							for (i = 0; i < rvect.length; i++) {
								for (j = c0; j >= c1; j--) {
									B[i][c0 - j] = A[rvect[i]][j];
								}
							}
						}
					}
					catch (e:Error) {
						throw new RangeError("Submatrix indices are out of bounds.");
					}
					return X;
					
				} else {
					
					//Row list, Column list
					X = new Matrix(rvect.length, cvect.length);
					B = X.data;
					try {
						for (i = 0; i < rvect.length; i++) {
							for (j = 0; j < cvect.length; j++) {
								B[i][j] = A[rvect[i]][cvect[j]];
							}
						}
					}
					catch (e:Error) {
						throw new RangeError("Submatrix indices are out of bounds.");
					}
					return X;
					
				}
			}
		}
		
		/** Set a single element.
		 * @param i    Row index.
		 * @param j    Column index.
		 * @param s    A(i,j).
		 * @exception  ArrayIndexOutOfBoundsException
		 */
		public function setAt(i:int, j:int, s:Number):void {
			A[i][j] = s;
		}
		
		/**
		 * Set a submatrix.
		 * @param r0   Initial row index
		 * @param r1   Final row index
		 * @param c0   Initial column index
		 * @param c1   Final column index
		 * @param X    A(r0:r1,c0:c1)
		 * @throws  	IllegalOperationError Thrown when matrix indices are out of bounds.
		 */
		public function setMatrix(X:Matrix, r0:int = -1, r1:int = -1, c0:int = -1, c1:int = -1, rvect:Vector.<int> = null, cvect:Vector.<int> = null):void {
			if ((r0 == -1 || r1 == -1) && !rvect) {
				throw new IllegalOperationError("Either Column list or Column range must be specified.");
			}else if ((c0 == -1 || c1 == -1) && !cvect) {
				throw new IllegalOperationError("Either Row list or Row range must be specified.");
			}
			
			var B:Vector.<Vector.<Number>>
			var X:Matrix;
			var i:int, j:int;
			var rRange:Boolean = (r0 != -1 || r1 != -1);
			var cRange:Boolean = (c0 != -1 || c1 != -1);
			if (rRange) {
				if (cRange) {
					
					//Row range and Column range
					try {
						if (r0 <= r1 && c0 <= c1) {
							for (i = r0; i <= r1; i++) {
								for (j = c0; j <= c1; j++) {
									B[i - r0][j - c0] = A[i][j];
								}
							}
						} else if (c0 <= c1) {
							for (i = r0; i >= r1; i--) {
								for (j = c0; j <= c1; j++) {
									trace("Setting (" + (r0 - i) + "," + (j - c0) + ") to " + A[i][j]);
									B[r0 - i][j - c0] = A[i][j];
								}
							}
						} else if (r0 <= r1) {
							for (i = r0; i <= r1; i++) {
								for (j = c0; j >= c1; j--) {
									B[i - r0][c0 - j] = A[i][j];
								}
							}
						} else {
							for (i = r0; i >= r1; i--) {
								for (j = c0; j >= c1; j--) {
									B[r0 - i][c0 - j] = A[i][j];
								}
							}
						}
					}
					catch (e:Error) {
						throw new RangeError("Submatrix indices are out of bounds.");
					}
					return X;
					
				} else {
					
					
					//Row range, Column list
					try {
						if (r0 <= r1) {
							for (i = r0; i <= r1; i++) {
								for (j = 0; j < cvect.length; j++) {
									B[i - r0][j] = A[i][cvect[j]];
								}
							}
						} else {
							for (i = r0; i >= r1; i--) {
								for (j = 0; j < cvect.length; j++) {
									B[r0 - i][j] = A[i][cvect[j]];
								}
							}
						}
					}
					catch (e:Error) {
						throw new RangeError("Submatrix indices are out of bounds.");
					}
					
				}
			} else {
				if (cRange) {
					
					//Row list, Column range
					try {
						if (c0 <= c1) {
							for (i = 0; i < rvect.length; i++) {
								for (j = c0; j <= c1; j++) {
									B[i][j - c0] = A[rvect[i]][j];
								}
							}
						} else {
							for (i = 0; i < rvect.length; i++) {
								for (j = c0; j >= c1; j--) {
									B[i][c0 - j] = A[rvect[i]][j];
								}
							}
						}
					}
					catch (e:Error) {
						throw new RangeError("Submatrix indices are out of bounds.");
					}
					
				} else {
					
					//Row list, Column list
					try {
						for (i = 0; i < rvect.length; i++) {
							for (j = 0; j < cvect.length; j++) {
								B[i][j] = A[rvect[i]][cvect[j]];
							}
						}
					}
					catch (e:Error) {
						throw new RangeError("Submatrix indices are out of bounds.");
					}
					
				}
			}
		}
		
		/** Set a submatrix.
		   @param r    Array of row indices.
		   @param c    Array of column indices.
		   @param X    A(r(:),c(:))
		   @exception  ArrayIndexOutOfBoundsException Submatrix indices
		 */ /*public void setMatrix (int[] r, int[] c, Matrix X) {
		   try {
		   for (int i = 0; i < r.length; i++) {
		   for (int j = 0; j < c.length; j++) {
		   A[r[i]][c[j]] = X.get(i,j);
		   }
		   }
		   } catch(ArrayIndexOutOfBoundsException e) {
		   throw new ArrayIndexOutOfBoundsException("Submatrix indices");
		   }
		 }*/
		
		/** Set a submatrix.
		   @param r    Array of row indices.
		   @param j0   Initial column index
		   @param j1   Final column index
		   @param X    A(r(:),j0:j1)
		   @exception  ArrayIndexOutOfBoundsException Submatrix indices
		 */ /*public void setMatrix (int[] r, int j0, int j1, Matrix X) {
		   try {
		   for (int i = 0; i < r.length; i++) {
		   for (int j = j0; j <= j1; j++) {
		   A[r[i]][j] = X.get(i,j-j0);
		   }
		   }
		   } catch(ArrayIndexOutOfBoundsException e) {
		   throw new ArrayIndexOutOfBoundsException("Submatrix indices");
		   }
		 }*/
		
		/** Set a submatrix.
		   @param i0   Initial row index
		   @param i1   Final row index
		   @param c    Array of column indices.
		   @param X    A(i0:i1,c(:))
		   @exception  ArrayIndexOutOfBoundsException Submatrix indices
		 */ /*public void setMatrix (int i0, int i1, int[] c, Matrix X) {
		   try {
		   for (int i = i0; i <= i1; i++) {
		   for (int j = 0; j < c.length; j++) {
		   A[i][c[j]] = X.get(i-i0,j);
		   }
		   }
		   } catch(ArrayIndexOutOfBoundsException e) {
		   throw new ArrayIndexOutOfBoundsException("Submatrix indices");
		   }
		 }*/
		
		/**
		 * Extends the Matrix in place by r rows and c columns.
		 * @param r	  The number of rows to extend matrix A.
		 * @param c	  The number of columns to extend matrix A.
		 * @param fill The value to fill the extended portion.
		 * @return    A reference to the matrix.
		 */
		public function extend(r:uint, c:uint, fill:Number = 0):Matrix {
			//Add extra columns
			var i:int, j:int;
			for (i = 0; i < m; i++) {
				A[i].length = n + c;
				for (j = n; j < n + c; j++) {
					A[i][j] = fill;
				}
			}
			
			//Add extra rows
			A.length = m + r;
			for (i = m; i < r + m; i++) {
				A[i] = new Vector.<Number>(n + c);
				for (j = 0; j < n + c; j++) {
					A[i][j] = fill;
				}
			}
			m += r;
			n += c;
			return this;
		}
		
		/**
		 * Extends a copy of the Matrix by r rows and c columns.
		 * @param r	  The number of rows to extend matrix A.
		 * @param c	  The number of columns to extend matrix A.
		 * @param fill The value to fill the extended portion.
		 * @return    The edited copy of matrix A.
		 */
		public function extendWithCopy(r:uint, c:uint, fill:Number = 0):Matrix {
			//Add extra columns
			var C:Vector.<Vector.<Number>> = getArrayCopy();
			var i:int, j:int;
			for (i = 0; i < m; i++) {
				C[i].length = n + c;
				for (j = n; j < n + c; j++) {
					C[i][j] = fill;
				}
			}
			
			//Add extra rows
			C.length = m + r;
			for (i = m; i < r + m; i++) {
				C[i] = new Vector.<Number>(n + c);
				for (j = 0; j < n + c; j++) {
					C[i][j] = fill;
				}
			}
			m += r;
			n += c;
			return Matrix.construct(C);
		}
		
		/**
		 * Matrix transpose.
		 * @return    A'
		 */
		public function transpose():Matrix {
			var X:Matrix = new Matrix(n, m);
			var C:Vector.<Vector.<Number>> = X.data;
			for (var i:int = 0; i < m; i++) {
				for (var j:int = 0; j < n; j++) {
					C[j][i] = A[i][j];
				}
			}
			return X;
		}
		
		/**
		 * One norm
		 * @return    maximum column sum.
		 */
		public function norm1():Number {
			var f:Number = 0;
			for (var j:int = 0; j < n; j++) {
				var s:Number = 0;
				for (var i:int = 0; i < m; i++) {
					s += Math.abs(A[i][j]);
				}
				f = Math.max(f, s);
			}
			return f;
		}
		
		/**
		 * Two norm
		 * @return    maximum singular value.
		 */
		public function norm2():Number {
			throw new IllegalOperationError("Function has not been migrated/implemented yet. Please help us out!!)");
			//return (new SingularValueDecomposition(this).norm2());
			return 0;
		}
		
		/**
		 * Infinity norm
		 * @return    maximum row sum.
		 */
		public function normInf():Number {
			var f:Number = 0;
			for (var i:int = 0; i < m; i++) {
				var s:Number = 0;
				for (var j:int = 0; j < n; j++) {
					s += Math.abs(A[i][j]);
				}
				f = Math.max(f, s);
			}
			return f;
		}
		
		/**
		 * Frobenius norm
		 * @return    sqrt of sum of squares of all elements.
		 */
		public function normF():Number {
			var f:Number = 0;
			for (var i:int = 0; i < m; i++) {
				for (var j:int = 0; j < n; j++) {
					f = Maths.hypot(f, A[i][j]);
				}
			}
			return f;
		}
		
		/**
		 * Unary minus
		 * @return    -A
		 */
		public function uminus():Matrix {
			var X:Matrix = new Matrix(m, n);
			var C:Vector.<Vector.<Number>> = X.data;
			for (var i:int = 0; i < m; i++) {
				for (var j:int = 0; j < n; j++) {
					C[i][j] = -A[i][j];
				}
			}
			return X;
		}
		
		/**
		 * C = A + B
		 * @param B    another matrix
		 * @return     A + B
		 */
		public function plus(B:Matrix):Matrix {
			checkMatrixDimensions(B);
			var X:Matrix = new Matrix(m, n);
			var C:Vector.<Vector.<Number>> = X.data;
			for (var i:int = 0; i < m; i++) {
				for (var j:int = 0; j < n; j++) {
					C[i][j] = A[i][j] + B.A[i][j];
				}
			}
			return X;
		}
		
		/** A = A + B
		 * @param B    another matrix
		 * @return     A + B
		 */
		public function plusEquals(B:Matrix):Matrix {
			checkMatrixDimensions(B);
			for (var i:int = 0; i < m; i++) {
				for (var j:int = 0; j < n; j++) {
					A[i][j] = A[i][j] + B.A[i][j];
				}
			}
			return this;
		}
		
		/** C = A - B
		 * @param B    another matrix
		 * @return     A - B
		 */
		public function minus(B:Matrix):Matrix {
			checkMatrixDimensions(B);
			var X:Matrix = new Matrix(m, n);
			var C:Vector.<Vector.<Number>> = X.data;
			for (var i:int = 0; i < m; i++) {
				for (var j:int = 0; j < n; j++) {
					C[i][j] = A[i][j] - B.A[i][j];
				}
			}
			return X;
		}
		
		/** A = A - B
		 * @param B    another matrix
		 * @return     A - B
		 */
		public function minusEquals(B:Matrix):Matrix {
			checkMatrixDimensions(B);
			for (var i:int = 0; i < m; i++) {
				for (var j:int = 0; j < n; j++) {
					A[i][j] = A[i][j] - B.A[i][j];
				}
			}
			return this;
		}
		
		/** Element-by-element multiplication, C = A.*B
		 * @param B    another matrix
		 * @return     A.*B
		 */
		public function arrayTimes(B:Matrix):Matrix {
			checkMatrixDimensions(B);
			var X:Matrix = new Matrix(m, n);
			var C:Vector.<Vector.<Number>> = X.data;
			for (var i:int = 0; i < m; i++) {
				for (var j:int = 0; j < n; j++) {
					C[i][j] = A[i][j] * B.A[i][j];
				}
			}
			return X;
		}
		
		/** Element-by-element multiplication in place, A = A.*B
		 * @param B    another matrix
		 * @return     A.*B
		 */
		public function arrayTimesEquals(B:Matrix):Matrix {
			checkMatrixDimensions(B);
			for (var i:int = 0; i < m; i++) {
				for (var j:int = 0; j < n; j++) {
					A[i][j] = A[i][j] * B.A[i][j];
				}
			}
			return this;
		}
		
		/** Element-by-element right division, C = A./B
		 * @param B    another matrix
		 * @return     A./B
		 */
		public function arrayRightDivide(B:Matrix):Matrix {
			checkMatrixDimensions(B);
			var X:Matrix = new Matrix(m, n);
			var C:Vector.<Vector.<Number>> = X.data;
			for (var i:int = 0; i < m; i++) {
				for (var j:int = 0; j < n; j++) {
					C[i][j] = A[i][j] / B.A[i][j];
				}
			}
			return X;
		}
		
		/** Element-by-element right division in place, A = A./B
		 * @param B    another matrix
		 * @return     A./B
		 */
		public function arrayRightDivideEquals(B:Matrix):Matrix {
			checkMatrixDimensions(B);
			for (var i:int = 0; i < m; i++) {
				for (var j:int = 0; j < n; j++) {
					A[i][j] = A[i][j] / B.A[i][j];
				}
			}
			return this;
		}
		
		/** Element-by-element left division, C = A.\B
		 * @param B    another matrix
		 * @return     A.\B
		 */
		public function arrayLeftDivide(B:Matrix):Matrix {
			checkMatrixDimensions(B);
			var X:Matrix = new Matrix(m, n);
			var C:Vector.<Vector.<Number>> = X.data;
			for (var i:int = 0; i < m; i++) {
				for (var j:int = 0; j < n; j++) {
					C[i][j] = B.A[i][j] / A[i][j];
				}
			}
			return X;
		}
		
		/** Element-by-element left division in place, A = A.\B
		 * @param B    another matrix
		 * @return     A.\B
		 */
		public function arrayLeftDivideEquals(B:Matrix):Matrix {
			checkMatrixDimensions(B);
			for (var i:int = 0; i < m; i++) {
				for (var j:int = 0; j < n; j++) {
					A[i][j] = B.A[i][j] / A[i][j];
				}
			}
			return this;
		}
		
		/** Multiply a matrix by a scalar, C = s*A
		 * @param s    scalar
		 * @return     s*A
		 */
		public function timesSC(s:Number):Matrix {
			var X:Matrix = new Matrix(m, n);
			var C:Vector.<Vector.<Number>> = X.data;
			for (var i:int = 0; i < m; i++) {
				for (var j:int = 0; j < n; j++) {
					C[i][j] = s * A[i][j];
				}
			}
			return X;
		}
		
		/** Multiply a matrix by a scalar in place, A = s*A
		 * @param s    scalar
		 * @return     replace A by s*A
		 */
		public function timesEquals(s:Number):Matrix {
			for (var i:int = 0; i < m; i++) {
				for (var j:int = 0; j < n; j++) {
					A[i][j] = s * A[i][j];
				}
			}
			return this;
		}
		
		/** Linear algebraic matrix multiplication, A * B
		 * @param B    another matrix
		 * @return     Matrix product, A * B
		 * @throws  IllegalArgumentError Matrix inner dimensions must agree.
		 */
		public function times(B:Matrix):Matrix {
			if (B.m != n) {
				throw new ArgumentError("Matrix inner dimensions must agree.");
			}
			var X:Matrix = new Matrix(m, B.n);
			var C:Vector.<Vector.<Number>> = X.data;
			var Bcolj:Vector.<Number> = new Vector.<Number>(n);
			for (var j:int = 0; j < B.n; j++) {
				for (var k:int = 0; k < n; k++) {
					Bcolj[k] = B.A[k][j];
				}
				for (var i:int = 0; i < m; i++) {
					var Arowi:Vector.<Number> = A[i];
					var s:Number = 0;
					for (k = 0; k < n; k++) {
						s += Arowi[k] * Bcolj[k];
					}
					C[i][j] = s;
				}
			}
			return X;
		}
		
		/** LU Decomposition
		   @return     LUDecomposition
		   @see LUDecomposition
		 */ /*public function lu():LUDecomposition {
		   return new LUDecomposition(this);
		 }*/
		
		/** QR Decomposition
		   @return     QRDecomposition
		   @see QRDecomposition
		 */ /* public QRDecomposition qr () {
		   return new QRDecomposition(this);
		 }*/
		
		/** Cholesky Decomposition
		   @return     CholeskyDecomposition
		   @see CholeskyDecomposition
		 */ /*public CholeskyDecomposition chol () {
		   return new CholeskyDecomposition(this);
		 }*/
		
		/** Singular Value Decomposition
		   @return     SingularValueDecomposition
		   @see SingularValueDecomposition
		 */ /*public SingularValueDecomposition svd () {
		   return new SingularValueDecomposition(this);
		 }*/
		
		/** Eigenvalue Decomposition
		   @return     EigenvalueDecomposition
		   @see EigenvalueDecomposition
		 */ /*public EigenvalueDecomposition eig () {
		   return new EigenvalueDecomposition(this);
		 }*/
		
		/** Solve A*X = B
		   @param B    right hand side
		   @return     solution if A is square, least squares solution otherwise
		 */ /*public Matrix solve (Matrix B) {
		   return (m == n ? (new LUDecomposition(this)).solve(B) :
		   (new QRDecomposition(this)).solve(B));
		 }*/
		
		/** Solve X*A = B, which is also A'*X' = B'
		   @param B    right hand side
		   @return     solution if A is square, least squares solution otherwise.
		 */ /*public Matrix solveTranspose (Matrix B) {
		   return transpose().solve(B.transpose());
		 }*/
		
		/** Matrix inverse or pseudoinverse
		   @return     inverse(A) if A is square, pseudoinverse otherwise.
		 */ /*public Matrix inverse () {
		   return solve(identity(m,m));
		 }*/
		
		/** Matrix determinant
		   @return     determinant
		 */ /*public double det () {
		   return new LUDecomposition(this).det();
		 }*/
		
		/** Matrix rank
		   @return     effective numerical rank, obtained from SVD.
		 */ /*public int rank () {
		   return new SingularValueDecomposition(this).rank();
		 }*/
		
		/** Matrix condition (2 norm)
		 * @return     ratio of largest to smallest singular value.
		 */ /*public double cond () {
		   return new SingularValueDecomposition(this).cond();
		 }*/
		
		/** Matrix trace.
		 * @return     sum of the diagonal elements.
		 */
		public function getTrace():Number {
			var t:Number = 0;
			for (var i:int = 0; i < Math.min(m, n); i++) {
				t += A[i][i];
			}
			return t;
		}
		
		public function print(decimal:Number):void {
			var A:Vector.<Vector.<Number>> = this.data;
			trace("Matrix:");
			var precision:Number = Math.pow(10, decimal);
			var line:String = "";
			for (var i:int = 0; i < A.length; i++) {
				for (var j:int = 0; j < A[0].length; j++) {
					line += Math.round(A[i][j] * precision) / precision + "\t";
				}
				trace(line)
				line = "";
			}
		
		}
		
		/** Print the matrix to the output stream.   Line the elements up in
		 * columns with a Fortran-like 'Fw.d' style format.
		 * @param output Output stream.
		 * @param w      Column width.
		 * @param d      Number of digits after the decimal.
		 */ /*public void print (PrintWriter output, int w, int d) {
		   DecimalFormat format = new DecimalFormat();
		   format.setDecimalFormatSymbols(new DecimalFormatSymbols(Locale.US));
		   format.setMinimumIntegerDigits(1);
		   format.setMaximumFractionDigits(d);
		   format.setMinimumFractionDigits(d);
		   format.setGroupingUsed(false);
		   print(output,format,w+2);
		 }*/
		
		// DecimalFormat is a little disappointing coming from Fortran or C's printf.
		// Since it doesn't pad on the left, the elements will come out different
		// widths.  Consequently, we'll pass the desired column width in as an
		// argument and do the extra padding ourselves.
		
		/** Read a matrix from a stream.  The format is the same the print method,
		 * so printed matrices can be read back in (provided they were printed using
		 * US Locale).  Elements are separated by
		 * whitespace, all the elements for each row appear on a single line,
		 * the last row is followed by a blank line.
		 * @param input the input stream.
		 */ /*public static Matrix read (BufferedReader input) throws java.io.IOException {
		   StreamTokenizer tokenizer= new StreamTokenizer(input);
		
		   // Although StreamTokenizer will parse numbers, it doesn't recognize
		   // scientific notation (E or D); however, Double.valueOf does.
		   // The strategy here is to disable StreamTokenizer's number parsing.
		   // We'll only get whitespace delimited words, EOL's and EOF's.
		   // These words should all be numbers, for Double.valueOf to parse.
		
		   tokenizer.resetSyntax();
		   tokenizer.wordChars(0,255);
		   tokenizer.whitespaceChars(0, ' ');
		   tokenizer.eolIsSignificant(true);
		   java.util.Vector<Double> vD = new java.util.Vector<Double>();
		
		   // Ignore initial empty lines
		   while (tokenizer.nextToken() == StreamTokenizer.TT_EOL);
		   if (tokenizer.ttype == StreamTokenizer.TT_EOF)
		   throw new java.io.IOException("Unexpected EOF on matrix read.");
		   do {
		   vD.addElement(Double.valueOf(tokenizer.sval)); // Read & store 1st row.
		   } while (tokenizer.nextToken() == StreamTokenizer.TT_WORD);
		
		   int n = vD.size();  // Now we've got the number of columns!
		   double row[] = new double[n];
		   for (int j=0; j<n; j++)  // extract the elements of the 1st row.
		   row[j]=vD.elementAt(j).doubleValue();
		   java.util.Vector<double[]> v = new java.util.Vector<double[]>();
		   v.addElement(row);  // Start storing rows instead of columns.
		   while (tokenizer.nextToken() == StreamTokenizer.TT_WORD) {
		   // While non-empty lines
		   v.addElement(row = new double[n]);
		   int j = 0;
		   do {
		   if (j >= n) throw new java.io.IOException
		   ("Row " + v.size() + " is too long.");
		   row[j++] = Double.valueOf(tokenizer.sval).doubleValue();
		   } while (tokenizer.nextToken() == StreamTokenizer.TT_WORD);
		   if (j < n) throw new java.io.IOException
		   ("Row " + v.size() + " is too short.");
		   }
		   int m = v.size();  // Now we've got the number of rows.
		   double[][] A = new double[m][];
		   v.copyInto(A);  // copy the rows out of the vector
		   return new Matrix(A);
		 }*/
		
		/* ------------------------
		   Private Methods
		 * ------------------------ */
		
		/** Check if size(A) == size(B) **/
		private function checkMatrixDimensions(B:Matrix):void {
			if (B.m != m || B.n != n) {
				throw new ArgumentError("Matrix dimensions must agree.");
			}
		}
		
		/* ------------------------
		   Setter/Getter Methods
		 * ------------------------ */
		
		/**
		 * Access the internal two-dimensional array.
		 * @return     Reference to the two-dimensional array of matrix elements.
		 */
		public function get data():Vector.<Vector.<Number>> {
			return A;
		}
		
		/**
		 * Get row dimension.
		 *
		 * @return     m, the number of rows.
		 */
		public function get rows():int {
			return m;
		}
		
		/**
		 * Get column dimension.
		 *
		 * @return     n, the number of columns.
		 */
		public function get columns():int {
			return n;
		}
	}
}

