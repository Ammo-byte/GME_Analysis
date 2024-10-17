# Load the GME dataset from the 'data' folder
gme_data <- read.csv("data/GME.csv", header=TRUE, stringsAsFactors=TRUE)

# Number of observations (trading days)
N = nrow(gme_data)

# Initialize a matrix to store influence values for alpha and beta
delta_theta = matrix(0, nrow = N, ncol = 2)

# Center Day_Num for better interpretation
gme_data$Day_Num <- gme_data$Day_Num - mean(gme_data$Day_Num)

# Define x and y for regression
x <- gme_data$Day_Num
y <- gme_data$Adj_Close

# Fit the full linear regression model
fit = lm(y ~ x, data = gme_data)

# Loop through each observation to calculate influence
for (i in 1:N) {
  # Fit the model excluding the ith observation
  fit.no.i = lm(Adj_Close ~ Day_Num, data = gme_data[-i, ])
  
  # Calculate the influence on alpha and beta: ||coeff - coeff[-i]||_1
  delta_theta[i, ] = abs(coef(fit) - coef(fit.no.i))
}

# Calculate total influence on theta: ||theta - theta[-i]||_1
delta2 = apply(delta_theta, 1, function(z) sqrt(sum(z^2)))

# Set up a 3x1 plotting layout to show all plots on one page
par(mfrow = c(3, 1))

# Scatter plot for influence on alpha
plot(delta_theta[,1], ylab = bquote(Delta[alpha]), main = bquote("Influence on" ~ alpha),
     pch = 19, col = adjustcolor("grey", 0.6))

# Scatter plot for influence on beta
plot(delta_theta[,2], ylab = bquote(Delta[beta]), main = bquote("Influence on" ~ beta),
     pch = 19, col = adjustcolor("black", 0.6))

# Scatter plot for total influence on theta
plot(delta2, ylab = bquote(Delta[theta]), main = bquote("Influence on" ~ theta),
     pch = 19, col = adjustcolor("blue", 0.6))

# Reset the plotting layout
par(mfrow = c(1, 1))

# Identify the most influential days (those above a threshold, e.g., delta2 > 0.05)
gme_data[delta2 > 0.05, ]
# The days with the largest influence on the regression are:
# Date        Day_Num  Open   High   Low    Close  Adj_Close  Volume
# 2024-05-13   117     26.34  38.20  24.77  30.45   30.45     187241700
# 2024-05-14   118     64.83  64.83  36.00  48.75   48.75     206979100
# 2024-05-15   119     40.31  42.35  31.00  39.55   39.55     131790100
# 2024-05-16   120     33.98  35.24  27.59  27.67   27.67     76177600