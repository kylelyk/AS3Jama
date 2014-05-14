package {
	import Matrix;
	import flash.errors.IllegalOperationError;
	
	/** LU Decomposition.
	   <P>
	   For an m-by-n matrix A with m >= n, the LU decomposition is an m-by-n
	   unit lower triangular matrix L, an n-by-n upper triangular matrix U,
	   and a permutation vector piv of length m so that A(piv,:) = L*U.
	   If m < n, then L is m-by-m and U is m-by-n.
	   <P>
	   The LU decompostion with pivoting always exists, even if the matrix is
	   singular, so the constructor will never fail.  The primary use of the
	   LU decomposition is in the solution of square systems of simultaneous
	   linear equations.  This will fail if isNonsingular() returns false.
	 *
	 * @author Kyle Howell
	 */
	public class LUDecomposition {
		
		/* ------------------------
		   Class variables
		 * ------------------------ */
		
		/** Array for internal storage of decomposition.
		   @serial internal array storage.
		 */
		private var LU:Vector.<Vector.<Number>>;
		
		/** Row and column dimensions, and pivot sign.
		   @serial column dimension.
		   @serial row dimension.
		   @serial pivot sign.
		 */
		private var m:int, n:int, pivsign:int;
		
		/** Internal storage of pivot vector.
		   @serial pivot vector.
		 */
		private var piv:Vector.<int>;
		
		/* ------------------------
		   Constructor
		 * ------------------------ */
		
		/** LU Decomposition
		   Structure to access L, U and piv.
		   @param  A Rectangular matrix
		 */
		public function LUDecomposition(A:Matrix) {
			
			// Use a "left-looking", dot-product, Crout/Doolittle algorithm.
			LU = A.getArrayCopy();
			m = A.rows;
			n = A.columns;
			piv = new Vector.<int>(m);
			var i:int, k:int;
			for (i = 0; i < m; i++) {
				piv[i] = i;
			}
			pivsign = 1;
			var LUrowi:Vector.<Number>;
			var LUcolj:Vector.<Number> = new Vector.<Number>(m);
			
			// Outer loop.
			for (var j:int = 0; j < n; j++) {
				
				// Make a copy of the j-th column to localize references.
				for (i = 0; i < m; i++) {
					LUcolj[i] = LU[i][j];
				}
				
				// Apply previous transformations.
				for (i = 0; i < m; i++) {
					LUrowi = LU[i];
					
					// Most of the time is spent in the following dot product.
					var kmax:int = Math.min(i, j);
					var s:Number = 0.0;
					for (k = 0; k < kmax; k++) {
						s += LUrowi[k] * LUcolj[k];
					}
					
					LUrowi[j] = LUcolj[i] -= s;
				}
				
				// Find pivot and exchange if necessary.
				var p:int = j;
				for (i = j + 1; i < m; i++) {
					if (Math.abs(LUcolj[i]) > Math.abs(LUcolj[p])) {
						p = i;
					}
				}
				if (p != j) {
					for (k = 0; k < n; k++) {
						var t:Number = LU[p][k];
						LU[p][k] = LU[j][k];
						LU[j][k] = t;
					}
					k = piv[p];
					piv[p] = piv[j];
					piv[j] = k;
					pivsign = -pivsign;
				}
				
				// Compute multipliers.
				if (j < m && LU[j][j] != 0.0) {
					for (i = j + 1; i < m; i++) {
						LU[i][j] /= LU[j][j];
					}
				}
			}
		}
		
		/* ------------------------
		   Temporary, experimental code.
		   ------------------------ *\
		
		   \** LU Decomposition, computed by Gaussian elimination.
		   <P>
		   This constructor computes L and U with the "daxpy"-based elimination
		   algorithm used in LINPACK and MATLAB.  In Java, we suspect the dot-product,
		   Crout algorithm will be faster.  We have temporarily included this
		   constructor until timing experiments confirm this suspicion.
		   <P>
		   @param  A             Rectangular matrix
		   @param  linpackflag   Use Gaussian elimination.  Actual value ignored.
		   @return               Structure to access L, U and piv.
		 *\
		
		   public LUDecomposition (Matrix A, int linpackflag) {
		   // Initialize.
		   LU = A.getArrayCopy();
		   m = A.getRowDimension();
		   n = A.getColumnDimension();
		   piv = new int[m];
		   for (var i:int = 0; i < m; i++) {
		   piv[i] = i;
		   }
		   pivsign = 1;
		   // Main loop.
		   for (int k = 0; k < n; k++) {
		   // Find pivot.
		   int p = k;
		   for (var i:int = k+1; i < m; i++) {
		   if (Math.abs(LU[i][k]) > Math.abs(LU[p][k])) {
		   p = i;
		   }
		   }
		   // Exchange if necessary.
		   if (p != k) {
		   for (var j:int = 0; j < n; j++) {
		   double t = LU[p][j]; LU[p][j] = LU[k][j]; LU[k][j] = t;
		   }
		   int t = piv[p]; piv[p] = piv[k]; piv[k] = t;
		   pivsign = -pivsign;
		   }
		   // Compute multipliers and eliminate k-th column.
		   if (LU[k][k] != 0.0) {
		   for (var i:int = k+1; i < m; i++) {
		   LU[i][k] /= LU[k][k];
		   for (var j:int = k+1; j < n; j++) {
		   LU[i][j] -= LU[i][k]*LU[k][j];
		   }
		   }
		   }
		   }
		   }
		
		   \* ------------------------
		   End of temporary code.
		 * ------------------------ */
		
		/* ------------------------
		   Public Methods
		 * ------------------------ */
		
		/** Is the matrix nonsingular?
		   @return     true if U, and hence A, is nonsingular.
		 */
		public function isNonsingular():Boolean {
			for (var j:int = 0; j < n; j++) {
				if (LU[j][j] == 0)
					return false;
			}
			return true;
		}
		
		/** Return lower triangular factor
		   @return     L
		 */
		public function getL():Matrix {
			var X:Matrix = new Matrix(m, n);
			var L:Vector.<Vector.<Number>> = X.data;
			for (var i:int = 0; i < m; i++) {
				for (var j:int = 0; j < n; j++) {
					if (i > j) {
						L[i][j] = LU[i][j];
					} else if (i == j) {
						L[i][j] = 1.0;
					} else {
						L[i][j] = 0.0;
					}
				}
			}
			return X;
		}
		
		/** Return upper triangular factor
		   @return     U
		 */
		public function getU():Matrix {
			var X:Matrix = new Matrix(n, n);
			var U:Vector.<Vector.<Number>> = X.data;
			for (var i:int = 0; i < n; i++) {
				for (var j:int = 0; j < n; j++) {
					if (i <= j) {
						U[i][j] = LU[i][j];
					} else {
						U[i][j] = 0.0;
					}
				}
			}
			return X;
		}
		
		/** Return pivot permutation vector
		   @return     piv
		 */
		public function getPivot():Vector.<int> {
			var p:Vector.<int> = new Vector.<int>(m);
			for (var i:int = 0; i < m; i++) {
				p[i] = piv[i];
			}
			return p;
		}
		
		/** Return pivot permutation vector as a one-dimensional double array
		   @return     (double) piv
		 */
		public function getDoublePivot():Vector.<Number> {
			var vals:Vector.<Number> = new Vector.<Number>(m);
			for (var i:int = 0; i < m; i++) {
				vals[i] = Number(piv[i]);
			}
			return vals;
		}
		
		/** Determinant
		   @return     det(A)
		   @exception  IllegalArgumentException  Matrix must be square
		 */
		public function det():Number {
			if (m != n) {
				throw new ArgumentError("Matrix must be square.");
			}
			var d:Number = Number(pivsign);
			for (var j:int = 0; j < n; j++) {
				d *= LU[j][j];
			}
			return d;
		}
		
		/** Solve A*X = B
		   @param  B   A Matrix with as many rows as A and any number of columns.
		   @return     X so that L*U*X = B(piv,:)
		   @exception  IllegalArgumentException Matrix row dimensions must agree.
		   @exception  RuntimeException  Matrix is singular.
		 */
		public function solve(B:Matrix):Matrix {
			if (B.rows != m) {
				throw new ArgumentError("Matrix row dimensions must agree.");
			}
			if (!this.isNonsingular()) {
				throw new IllegalOperationError("Matrix is singular.");
			}
			
			// Copy right hand side with pivoting
			var nx:int = B.columns;
			var Xmat:Matrix = B.getMatrix(-1, -1, 0, nx - 1, piv);
			var X:Vector.<Vector.<Number>> = Xmat.data;
			
			var k:int, i:int, j:int;
			// Solve L*Y = B(piv,:)
			for (k = 0; k < n; k++) {
				for (i = k + 1; i < n; i++) {
					for (j = 0; j < nx; j++) {
						X[i][j] -= X[k][j] * LU[i][k];
					}
				}
			}
			// Solve U*X = Y;
			for (k = n - 1; k >= 0; k--) {
				for (j = 0; j < nx; j++) {
					X[k][j] /= LU[k][k];
				}
				for (i = 0; i < k; i++) {
					for (j = 0; j < nx; j++) {
						X[i][j] -= X[k][j] * LU[i][k];
					}
				}
			}
			return Xmat;
		}
	}
}