require 'selenium-webdriver'
require 'logger'
require 'json'
require_relative './general_functions.rb'

class AddSite
	ADD_SITE_BUTTON = '//span[text()="ADD SITE"]'
	SITE_URL_INPUT = '[class="form-control"]'
	ADD_SITE_SUBMIT = '[class="font14 btn btn-success text-up font-normal fontrob w-100 py-half"]'
	WP_ADMIN_USERNAME_INPUT = "//*[@placeholder='WP Admin Username']"
	WP_ADMIN_PASSWORD_INPUT = "//*[@placeholder='WP Admin Password']"
	CONTINUE_BUTTON = '[class="font14 btn btn-success text-up font-normal fontrob mt-2 continue-btn w-100"]'
	INITIATE_SYNC = '//a[text()="Initiate Sync"]'
	RECENT_SITE = '.item-title'
	CONFIRM_DELETE = '//button[text()="Yes, remove it"]'
	DELETE_BUTTON = 'mdi-delete'
	SITE_REMOVED_NOTIFICATION = '//span[text()="Site Removed"]'
	INSTALLED_DIALOG = '//p[text()="Plugin installation successful"]'
	HOME_URL_SITES = 'https://app.blogvault.net/app/sites'
	LIST_OF_SITES = 'item-title'
	BACK_TO_DASH_BUTTON = '//a[text()="Back to Dashboard"]'

	def initialize(driver, logger)
		@driver = driver
		@logger = logger
		@wait = Selenium::WebDriver::Wait.new(timeout: 60)
	end

	def run_script	
		begin
			self.navigate_to_add_site
			file = File.read('credentials_instawp.json')
			site_credentials = JSON.parse(file)
			@logger.info site_credentials
			self.enter_site_url(site_credentials["url"])
			self.enter_wp_admin_credentials(site_credentials["username"], site_credentials["password"])
		rescue => e
			handle_error(e)
		end
	end

	def navigate_to_add_site
		begin
			@wait.until{@driver.find_element(:xpath, ADD_SITE_BUTTON)}	
			@driver.find_element(:xpath, ADD_SITE_BUTTON).click
			@logger.info "Clicked on ADD SITE and putting the url"
		rescue => e
			handle_error(e)
		end
	end

	def enter_site_url(url)
		begin
			entersite_url = @driver.find_element(css: SITE_URL_INPUT)
			entersite_url.send_keys url
			@driver.find_element(css: ADD_SITE_SUBMIT).click
			@logger.info "URL entered successfully, entering the admin username and password"
		rescue => e
			handle_error(e)
		end
	end

	def enter_wp_admin_credentials(username, password)
		begin
			@wait.until{@driver.find_element(:xpath, WP_ADMIN_PASSWORD_INPUT)}	
			admin_password = @driver.find_element(:xpath, WP_ADMIN_PASSWORD_INPUT)
			admin_username = @driver.find_element(:xpath, WP_ADMIN_USERNAME_INPUT)
			admin_username.send_keys username
			admin_password.send_keys password
			@driver.find_element(css: CONTINUE_BUTTON).click
			@logger.info "Wait for progress bar to load"
			@driver.save_screenshot "d.png"
			@wait.until{@driver.find_element(:xpath, INSTALLED_DIALOG)}
			@driver.find_element(:xpath, INITIATE_SYNC).click
			@logger.info "Clicked on Initiate Sync link."
			wait_for_loading
			@driver.find_element(:xpath, BACK_TO_DASH_BUTTON).click
			wait_for_loading
			sleep(20)
			@logger.info "Site Added"
			add_success_report
		rescue => e
			handle_error(e)
		end
	end

	def delete_site
		begin
			@logger.info "Rolling back by deleting the added site"
			wait_for_loading
			navigate_to_sites_list
			@wait.until{@driver.find_element(css: RECENT_SITE)}	
			@driver.find_element(css: RECENT_SITE).click
			@logger.info "Clicked on most recent site"
			wait_for_loading
			@driver.find_element(:class, DELETE_BUTTON).click
			@driver.find_element(:xpath, CONFIRM_DELETE).click
			@wait.until{@driver.find_element(:xpath, SITE_REMOVED_NOTIFICATION)}
			@logger.info "Site Deleted\n Rollbacked"
			add_success_report
		rescue => e
			handle_error(e)
		end
	end

	def navigate_to_sites_list
		@driver.get HOME_URL_SITES
		@wait.until{@driver.find_element(:class, LIST_OF_SITES)}	
	end
end
