# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Weatherman::Application.initialize!

#################################################
# Pagination
WillPaginate.per_page = 25
