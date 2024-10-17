# Load the GME dataset from the specified path
gme_data <- read.csv("data/GME.csv", header = TRUE, stringsAsFactors = TRUE)

# Plot the Adjusted Close price against Day_Num
# 'pch = 19' sets the plot character to filled circles
# 'adjustcolor("black", 0.5)' makes the points semi-transparent black
# 'main', 'xlab', and 'ylab' define the title and axis labels
plot(gme_data$Day_Num, gme_data$Adj_Close, pch = 19, col = adjustcolor("black", 0.5),
     main = "Adj_Close versus Day_Num", xlab = "Day_Num (x)", ylab = "Adj_Close (y)")

# Extract Day_Num and Adjusted Close columns into x and y for easier reference
x <- gme_data$Day_Num
y <- gme_data$Adj_Close

# Fit a linear model with Adjusted Close (y) as the response variable and Day_Num (x) as the predictor
# 'I(x - mean(x))' centers the x values by subtracting the mean, which helps interpret the intercept as the average value
fit = lm(y ~ I(x - mean(x)), data = gme_data)

# Print the summary of the fitted linear model
print(fit)

# Add the fitted regression line to the existing plot
# 'col = "red"' sets the line color to red
# 'lwd = 2' increases the line width
abline(fit, col = "red", lwd = 2)