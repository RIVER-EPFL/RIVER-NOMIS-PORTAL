install.packages("renv")
library(renv)

# Install dependencies from renv.lock file
renv::restore(prompt=FALSE)
