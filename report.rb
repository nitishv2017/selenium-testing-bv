require 'selenium-webdriver'
require 'logger'
require_relative './general_functions.rb'

class Report
	NEW_REPORT_BUTTON = "//a[text()='NEW REPORT']"
	CREATE_REPORT_BUTTON = "//button[text()='CREATE REPORT']"
	ERROR_MESSAGE = "//p[text()='The report cannot be generated as we do not have enough information for the given date range.']"
	START_DATE_INPUT_NAME = "start_date"
	DOWNLOAD_LINK = "//a[text()='Download ']"
	RECENT_SITE = '.item-title'

	def initialize(driver, logger)
		@driver = driver
		@logger = logger
		@wait = Selenium::WebDriver::Wait.new(timeout: 300)
	end

	def run_script()
		begin
			self.navigate_to_site
			self.generate_report
		rescue => e
			handle_error(e)
		end
	end

	def navigate_to_site
		begin
			@wait.until{@driver.find_element(css: RECENT_SITE)}	
			@driver.find_element(css: RECENT_SITE).click
			@logger.info "Clicked on most recent site"
		rescue => e
			handle_error(e)
		end
	end

	def generate_report
		begin
			wait_for_loading
			@logger.info "Generating report"
			@driver.find_element(:xpath, NEW_REPORT_BUTTON).click
			wait_for_loading
			@logger.info "Edit start date of report"
			start_date_input = @driver.find_element(:name, START_DATE_INPUT_NAME)
			min_date = start_date_input.attribute("min")
			start_date_input.clear
			start_date_input.send_keys min_date
			@driver.save_screenshot "d.png"
			@driver.find_element(:xpath, CREATE_REPORT_BUTTON).click
			@logger.info "Create Report clicked"
			wait_for_loading
			download_link = @wait.until { @driver.find_element(:xpath, DOWNLOAD_LINK) }
			@logger.info "Report Generated"
			add_success_report
		rescue => e
			handle_error(e)
		end
	end
end
