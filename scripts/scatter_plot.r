# Set up a plotting device with wider dimensions
png("GME_scatter_plot.png", width = 800, height = 600)  # Width is double the height

# Load the GME dataset from the specified path
gme_data <- read.csv("data/GME.csv", header = TRUE, stringsAsFactors = TRUE)

# Center the Day_Num data by subtracting the mean of Day_Num
centered_x <- gme_data$Day_Num - mean(gme_data$Day_Num)

# Plot the Adjusted Close price against the centered Day_Num, suppressing x-axis for customization
plot(centered_x, gme_data$Adj_Close, pch = 19, col = adjustcolor("black", 0.5),
     main = "Adj_Close versus Adjusted Day_Num", xlab = "Adjusted Day_Num (x)", ylab = "Adj_Close (y)",
     xaxt = "n")  # Suppress the default x-axis

# Define custom intervals for x-axis labels
x_breaks <- seq(-100, 100, by = 50)
adjusted_x_labels <- x_breaks + 100

# Add the custom x-axis
axis(1, at = x_breaks, labels = adjusted_x_labels)

# Extract Adjusted Close into y for easier reference
y <- gme_data$Adj_Close

# Fit a linear model using the centered x values
fit <- lm(y ~ centered_x, data = gme_data)

# Print the summary of the fitted linear model
print(summary(fit))

# Add the fitted regression line to the existing plot
abline(fit, col = "red", lwd = 2)

# Close the plotting device
dev.off()