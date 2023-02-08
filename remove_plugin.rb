require 'selenium-webdriver'
require 'logger'
require 'json'
require_relative './error_handle.rb'

class RemovePlugin
	ADD_SITE_BUTTON = '//span[text()="ADD SITE"]'
	ADD_PLUGIN = '//span[text()=""]'
	SITE_URL_INPUT = '[class="form-control"]'
	RECENT_SITE = '.item-title'
	WP_ADMIN_USERNAME_INPUT = "//*[@placeholder='WP Admin Username']"
	WP_ADMIN_PASSWORD_INPUT = "//*[@placeholder='WP Admin Password']"
	CONTINUE_BUTTON = '[class="font14 btn btn-success text-up font-normal fontrob mt-2 continue-btn w-100"]'
	INITIATE_LINK = '//a[text()="Initiate Sync"]'

	def initialize(driver, logger)
		@driver = driver
		@logger = logger
		@wait = Selenium::WebDriver::Wait.new(timeout: 300)
	end

	def run_script	
		begin
			self.navigate_to_site
			self.navigate_to_manage_plugins
			self.search_delete_plugin
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

	def navigate_to_manage_plugins
		begin
			@wait.until{!@driver.find_elements(class: "bv-loader-text-container").any?}
			manage_section = @driver.find_element(xpath: "//div[@class='manage-section'][.//span[text()='PLUGINS']]")
			manage_button = manage_section.find_element(xpath: ".//a[text()='MANAGE']")
			manage_button.click
			@logger.info "Clicked manage button of plugins section"	
			@wait.until{!@driver.find_elements(class: "bv-loader-text-container").any?}
			@driver.save_screenshot("f.png")
		rescue => e
			handle_error(e)
		end
	end

	def search_delete_plugin
		begin
			#search_box = @driver.find_element(:xpath, '//div[text()="SEARCH PLUGINS"]')
			#search_box.click
			#search_box.send_keys "WooCommerce"
			#search_box.send_keys :return
			@wait.until{!@driver.find_elements(class: "bv-loader-text-container").any?}
			@logger.info "Searched a plugin"
			@driver.find_element(xpath: "//span[text()='WooCommerce']").click
			@driver.find_element(class: "mdi-delete").click
			@logger.info "Clicked on delete icon"
			@driver.find_element(xpath: '//div[text()="Next Step"]').click
			@driver.find_element(xpath: '//div[text()="Delete"]').click
			@logger.info "Deletion started"
			@wait.until{!@driver.find_elements(class: "bv_loader-text-container").any?}
			@wait.until{@driver.find_element(xpath: '//span[text()="Successful"]')}
			@logger.info "Successfully deleted plugin"
		rescue => e
			handle_error(e)
		end
	end
end
