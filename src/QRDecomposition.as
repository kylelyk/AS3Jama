package  {
	import util.Maths;
	import Matrix;
	import flash.errors.IllegalOperationError;
	
	/** 
	 * QR Decomposition.
	 * <P>
	 * For an m-by-n matrix A with m >= n, the QR decomposition is an m-by-n
	 * orthogonal matrix Q and an n-by-n upper triangular matrix R so that
	 * A = Q*R.
	 * <P>
	 * The QR decompostion always exists, even if the matrix does not have
	 * full rank, so the constructor will never fail.  The primary use of the
	 * QR decomposition is in the least squares solution of nonsquare systems
	 * of simultaneous linear equations.  This will fail if isFullRank()
	 * returns false.
	 *
	 * @author Kyle Howell
	 */
	public class QRDecomposition {
		/* ------------------------
		   Class variables
		 * ------------------------ */
		
		/**
		 * Array for internal storage of decomposition.
		 * 
		 * @serial internal array storage.
		 */
		private var QR:Vector.<Vector.<Number>>;
		
		/**
		 * Row and column dimensions.
		 * 
		 * @serial column dimension.
		 * @serial row dimension.
		 */
		private var m:int, n:int;
		
		/**
		 * Array for internal storage of diagonal of R.
		 * 
		 * @serial diagonal of R.
		 */
		private var Rdiag:Vector.<Number>;
		
		/**
		 * QR Decomposition, computed by Householder reflections.
		 * Structure to access R and the Householder vectors and compute Q.
		 * 
		 * @param A    Rectangular matrix
		 */
		public function QRDecomposition(A:Matrix) {
			// Initialize.
			QR = A.getArrayCopy();
			m = A.rows;
			n = A.columns;
			Rdiag = new Vector.<Number>(n);
			var i:int, j:int, k:int;
			// Main loop.
			for (k = 0; k < n; k++) {
				// Compute 2-norm of k-th column without under/overflow.
				var nrm:Number = 0;
				for (i = k; i < m; i++) {
					nrm = Maths.hypot(nrm, QR[i][k]);
				}
				
				if (nrm != 0.0) {
					// Form k-th Householder vector.
					if (QR[k][k] < 0) {
						nrm = -nrm;
					}
					for (i = k; i < m; i++) {
						QR[i][k] /= nrm;
					}
					QR[k][k] += 1.0;
					
					// Apply transformation to remaining columns.
					for (j = k + 1; j < n; j++) {
						var s:Number = 0.0;
						for (i = k; i < m; i++) {
							s += QR[i][k] * QR[i][j];
						}
						s = -s / QR[k][k];
						for (i = k; i < m; i++) {
							QR[i][j] += s * QR[i][k];
						}
					}
				}
				Rdiag[k] = -nrm;
			}
		}
		
		/* ------------------------
		   Public Methods
		 * ------------------------ */
		
		/**
		 * Is the matrix full rank?
		 * 
		 * @return true if R, and hence A, has full rank.
		 */
		public function isFullRank():Boolean {
			for (var j:int = 0; j < n; j++) {
				if (Rdiag[j] == 0)
					return false;
			}
			return true;
		}
		
		/**
		 * Return the Householder vectors
		 * 
		 * @return Lower trapezoidal matrix whose columns define the reflections
		 */
		public function getH():Matrix {
			var H:Vector.<Vector.<Number>> = Matrix.constructArray(m, n);
			for (var i:int = 0; i < m; i++) {
				for (var j:int = 0; j < n; j++) {
					if (i >= j) {
						H[i][j] = QR[i][j];
					} else {
						H[i][j] = 0.0;
					}
				}
			}
			return Matrix.construct(H);
		}
		
		/**
		 * Return the upper triangular factor
		 * 
		 * @return R
		 */
		public function getR():Matrix {
			var R:Vector.<Vector.<Number>> = Matrix.constructArray(n, n);
			for (var i:int = 0; i < n; i++) {
				for (var j:int = 0; j < n; j++) {
					if (i < j) {
						R[i][j] = QR[i][j];
					} else if (i == j) {
						R[i][j] = Rdiag[i];
					} else {
						R[i][j] = 0.0;
					}
				}
			}
			return Matrix.construct(R);
		}
		
		/**
		 * Generate and return the (economy-sized) orthogonal factor
		 * 
		 * @return Q
		 */
		public function getQ():Matrix {
			var Q:Vector.<Vector.<Number>> = Matrix.constructArray(m, n);
			var i:int, j:int, k:int;
			for (k = n - 1; k >= 0; k--) {
				for (i = 0; i < m; i++) {
					Q[i][k] = 0.0;
				}
				Q[k][k] = 1.0;
				for (j = k; j < n; j++) {
					if (QR[k][k] != 0) {
						var s:Number = 0.0;
						for (i = k; i < m; i++) {
							s += QR[i][k] * Q[i][j];
						}
						s = -s / QR[k][k];
						for (i = k; i < m; i++) {
							Q[i][j] += s * QR[i][k];
						}
					}
				}
			}
			return Matrix.construct(Q);
		}
		
		/**
		 * Least squares solution of A*X = B
		 * 
		 * @param B    A Matrix with as many rows as A and any number of columns.
		 * @return X that minimizes the two norm of Q*R*X-B.
		 * @throws IllegalArgumentException  Matrix row dimensions must agree.
		 * @throws RuntimeException  Matrix is rank deficient.
		 */
		public function solve(B:Matrix):Matrix {
			if (B.rows != m) {
				throw new ArgumentError("Matrix row dimensions must agree.");
			}
			if (!this.isFullRank()) {
				throw new IllegalOperationError("Matrix is rank deficient.");
			}
			
			// Copy right hand side
			var nx:int = B.columns;
			var X:Vector.<Vector.<Number>> = B.getArrayCopy();
			var i:int, j:int, k:int;
			// Compute Y = transpose(Q)*B
			for (k = 0; k < n; k++) {
				for (j = 0; j < nx; j++) {
					var s:Number = 0.0;
					for (i = k; i < m; i++) {
						s += QR[i][k] * X[i][j];
					}
					s = -s / QR[k][k];
					for (i = k; i < m; i++) {
						X[i][j] += s * QR[i][k];
					}
				}
			}
			// Solve R*X = Y;
			for (k = n - 1; k >= 0; k--) {
				for (j = 0; j < nx; j++) {
					X[k][j] /= Rdiag[k];
				}
				for (i = 0; i < k; i++) {
					for (j = 0; j < nx; j++) {
						X[i][j] -= X[k][j] * QR[i][k];
					}
				}
			}
			return Matrix.construct(X).getMatrix(0,n-1,0,nx-1);
		}
	
	}
}