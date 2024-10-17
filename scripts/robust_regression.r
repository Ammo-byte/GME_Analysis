# Load the necessary dataset
gme_data <- read.csv("data/GME.csv", header = TRUE, stringsAsFactors = TRUE)

# Center Day_Num by subtracting its mean
gme_data$Day_Num_centered <- gme_data$Day_Num - mean(gme_data$Day_Num)

# Prepare x (centered) and y for the regression model
x <- gme_data$Day_Num_centered
y <- gme_data$Adj_Close

# --------------------------------------------------------------------
# Geman-McClure Objective Function and Gradient Definitions
# --------------------------------------------------------------------

# Define the Geman-McClure objective function
robust.fn <- function(r) {
  val = (r^2 / 2) / (1 + r^2)  # Geman-McClure rho function
  return(val)
}

# Create the Geman-McClure robust regression objective function
createRobustGMRho <- function(x, y) {
  function(theta) {
    alpha <- theta[1]
    beta <- theta[2]
    sum(robust.fn(y - alpha - beta * x))  # Return the sum of the objective function (already centered)
  }
}

# Derivative of the Geman-McClure objective function (gradient function)
robust.fn.prime <- function(r) {
  val = r / (1 + r^2)^2  # The derivative of the rho function
  return(val)
}

# Create the gradient of the Geman-McClure robust regression function
createRobustGMGradient <- function(x, y) {
  function(theta) {
    alpha <- theta[1]
    beta <- theta[2]
    ru = y - alpha - beta * x  # Residuals (centered data)
    rhok = robust.fn.prime(ru)  # Derivative of the rho function
    -1 * c(sum(rhok * 1), sum(rhok * x))  # Compute the gradient vector
  }
}

# --------------------------------------------------------------------
# Gradient Descent Function
# --------------------------------------------------------------------

# Helper function to test convergence during gradient descent
testConvergence <- function(thetaNew, thetaOld, tolerance = 1e-10, relative = FALSE) {
  sum(abs(thetaNew - thetaOld)) < if (relative) tolerance * sum(abs(thetaOld)) else tolerance
}

# Helper function to perform line search for step size (lambda)
gridLineSearch <- function(theta, rhoFn, d, lambdaStepsize = 0.01, lambdaMax = 1) {
  lambdas <- seq(from = 0, by = lambdaStepsize, to = lambdaMax)
  rhoVals <- sapply(lambdas, function(lambda) { rhoFn(theta - lambda * d) })
  lambdas[which.min(rhoVals)]
}

# Gradient Descent function for robust regression
gradientDescent <- function(theta = 0, rhoFn, gradientFn, lineSearchFn, testConvergenceFn,
                            maxIterations = 100, tolerance = 1e-06, relative = FALSE,
                            lambdaStepsize = 0.01, lambdaMax = 0.5) {
  converged <- FALSE
  i <- 0
  while (!converged & i <= maxIterations) {
    g <- gradientFn(theta)  # Compute the gradient
    glength <- sqrt(sum(g^2))  # Gradient length
    if (glength > 0) d <- g / glength  # Normalize gradient direction
    lambda <- lineSearchFn(theta, rhoFn, d, lambdaStepsize = lambdaStepsize, lambdaMax = lambdaMax)  # Find optimal step size
    thetaNew <- theta - lambda * d  # Update parameters
    converged <- testConvergenceFn(thetaNew, theta, tolerance = tolerance, relative = relative)  # Check convergence
    theta <- thetaNew
    i <- i + 1
  }
  list(theta = theta, converged = converged, iteration = i, fnValue = rhoFn(theta))  # Return the results
}

# --------------------------------------------------------------------
# Fit the Least Squares Model (OLS) and Print Initial Values
# --------------------------------------------------------------------

fit <- lm(y ~ x, data = gme_data)  # Fit the OLS model with centered data
alpha_ls <- coef(fit)[1]  # OLS estimate for intercept
beta_ls <- coef(fit)[2]  # OLS estimate for slope

# Print OLS Estimates for Debugging
cat("OLS Estimates:\n")
cat("Alpha (Intercept):", alpha_ls, "\n")
cat("Beta (Slope):", beta_ls, "\n")

# --------------------------------------------------------------------
# Perform Robust Regression with Geman-McClure Objective
# --------------------------------------------------------------------

robust_theta_val <- gradientDescent(
  theta = c(alpha_ls, beta_ls),  # Start with OLS estimates
  rhoFn = createRobustGMRho(x, y),  # Use the Geman-McClure rho function
  gradientFn = createRobustGMGradient(x, y),  # Use the Geman-McClure gradient
  lineSearchFn = gridLineSearch,  # Perform line search to find optimal step size
  testConvergenceFn = testConvergence,  # Test for convergence
  maxIterations = 100,  # Set maximum iterations for gradient descent
  tolerance = 1e-06,  # Convergence tolerance
  lambdaStepsize = 0.01,  # Step size for lambda
  lambdaMax = 0.5  # Maximum lambda value
)

# Print the robust regression coefficients (Geman-McClure)
cat("\nRobust Regression Results:\n")
print(robust_theta_val)

# --------------------------------------------------------------------
# Plotting the Results: OLS vs Geman-McClure Regression
# --------------------------------------------------------------------

# Set up the plot: scatter plot of the data points
plot(gme_data$Day_Num_centered, gme_data$Adj_Close, 
     pch = 19, col = adjustcolor("black", 0.5), 
     main = "Adj_Close vs Day_Num (OLS vs Geman-McClure)", 
     xlab = "Day_Num (centered)", ylab = "Adj_Close")

# Add the OLS line (Least Squares)
abline(a = alpha_ls, b = beta_ls, col = "red", lwd = 2)

# Add the Geman-McClure robust regression line
robust_alpha <- robust_theta_val$theta[1]
robust_beta <- robust_theta_val$theta[2]
abline(a = robust_alpha, b = robust_beta, col = "blue", lwd = 2)

# Add a legend to distinguish between the two regression lines
legend("topleft", legend = c("Least Squares", "Geman-McClure"), 
       col = c("red", "blue"), lwd = 2)
