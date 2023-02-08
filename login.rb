require 'selenium-webdriver'
require 'logger'
require_relative './general_functions.rb'

class Login
	LOGIN_URL = 'https://app.blogvault.net/users/signin'

	def initialize(driver, logger)
		@driver = driver
		@logger = logger
		@wait = Selenium::WebDriver::Wait.new(timeout: 30)
	end

	def login(username, password)
		begin
			@driver.get LOGIN_URL
			@logger.info "Navigated to Blogvault Login Dashboard"
			@wait.until{@driver.find_element(name: 'user[email]')}
			@logger.info "Entering username and password"
			username_field = @driver.find_element(name: 'user[email]')
			password_field = @driver.find_element(name: 'user[password]')
			username_field.send_keys username
			password_field.send_keys password
			@driver.find_element(css: '[type="submit"]').click
			@logger.info "Logged in into Blogvault"
		rescue => e
			handle_error(e)
		end
	end
end
