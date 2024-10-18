# Load the GME dataset from the specified path
gme_data <- read.csv("data/GME.csv", header = TRUE, stringsAsFactors = TRUE)

# Center the Day_Num data by subtracting the mean of Day_Num
centered_x <- gme_data$Day_Num - mean(gme_data$Day_Num)

# Plot the Adjusted Close price against the centered Day_Num
plot(centered_x, gme_data$Adj_Close, pch = 19, col = adjustcolor("black", 0.5),
     main = "Adj_Close versus Centered Day_Num", xlab = "Centered Day_Num (x)", ylab = "Adj_Close (y)")

# Extract Adjusted Close into y for easier reference
y <- gme_data$Adj_Close

# Fit a linear model using the centered x values
fit <- lm(y ~ centered_x, data = gme_data)

# Print the summary of the fitted linear model
print(fit)

# Add the fitted regression line to the existing plot
abline(fit, col = "red", lwd = 2)

