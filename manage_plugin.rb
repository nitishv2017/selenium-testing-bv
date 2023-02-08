require 'selenium-webdriver'
require 'logger'
require 'json'
require_relative './general_functions.rb'

class ManagePlugin
	ADD_NEW_BUTTON = '//button[text()=" ADD NEW"]'
	SEARCH_FORM = '//input[@name="search"]'
	SEARCH_QUERY = "WooCommerce"
	SEARCH_RESULT_ADD_PLUGIN = "//div[@class='well'][.//strong[text()='#{SEARCH_QUERY}']]"
	INSTALL_BTN = ".//a[text()=' Install']"
	CONFIRM_BTN = '//button[text()="Confirm"]'
	SUCCESS_MSG = '//span[text()="Successful"]'
	SEARCH_BOX = '//div[text()="SEARCH PLUGINS"]'
	SEARCH_RESULT_MANAGE_PLUGIN = "//span[text()='#{SEARCH_QUERY}']"
	UPDATE_ICON = "mdi-update"
	NEXT_STEP = '//div[text()="Next Step"]'
	UPDATE_BUTTON = '//div[text()="Update"]'
	DELETE_ICON = 'mdi-delete'
	DELETE_BUTTON = '//div[text()="Delete"]'
	MANAGE_SECTION = '//div[@class="manage-section"][.//span[text()="PLUGINS"]]'
	MANAGE_BUTTON = './/a[text()="MANAGE"]'
	RECENT_SITE = '.item-title'
	HOME_URL_SITES = 'https://app.blogvault.net/app/sites'
	LIST_OF_SITES = 'item-title'

	def initialize(driver, logger)
		@driver = driver
		@logger = logger
		@wait = Selenium::WebDriver::Wait.new(timeout: 300)
	end

	def run_script(automate = false)
		begin
			self.navigate_to_site
			self.navigate_to_manage_plugins
			if automate
				self.search_add_plugin
				self.navigate_to_sites_list
				self.navigate_to_site
				self.navigate_to_manage_plugins
				self.search_update_plugin
				self.navigate_to_sites_list
				self.navigate_to_site
				self.navigate_to_manage_plugins
				self.search_delete_plugin
			else
				puts "Select one funtion:\n"
				puts "1. Add a plugin"
				puts "2. Update a plugin"
				puts "3. Delete a plugin"
				option = gets.chomp
				case option
				when "1"
					self.search_add_plugin
				when "2"
					self.search_update_plugin
				when "3"
					self.search_delete_plugin
				else
					puts "Invalid Option chosen"
				end
			end
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
			wait_for_loading
			@wait.until{!@driver.find_elements(class: 'bv-fa-spin').any?}
			manage_section = @driver.find_element(:xpath, MANAGE_SECTION)
			manage_btn = manage_section.find_element(:xpath, MANAGE_BUTTON)
			manage_btn.click
			wait_for_loading
			@logger.info "Clicked manage button of plugins section"
			wait_for_loading
		rescue => e
			handle_error(e)
		end
	end

	def search_add_plugin
		begin
			@driver.find_element(:xpath, ADD_NEW_BUTTON).click
			@wait.until{!@driver.find_elements(class: "bv-loader-text-container").any?}  
			@logger.info "Inputting #{SEARCH_QUERY} as an example"
			search_form = @driver.find_element(:xpath, SEARCH_FORM)
			search_form.send_keys SEARCH_QUERY
			search_form.send_keys :return
			wait_for_loading
			first_search_result = @driver.find_element(:xpath, SEARCH_RESULT_ADD_PLUGIN)
			install_btn = first_search_result.find_element(:xpath, INSTALL_BTN)
			install_btn.click
			@wait.until{@driver.find_element(:xpath, CONFIRM_BTN)}
			@driver.find_element(:xpath, CONFIRM_BTN).click
			@logger.info "Installation started"
			wait_for_loading
			@wait.until{@driver.find_element(:xpath, SUCCESS_MSG)}
			@logger.info "Successfully added plugin"
		rescue => e
			handle_error(e)
		end
	end

	def search_update_plugin
		begin
			#search_box = @driver.find_element(:xpath, SEARCH_BOX)
			#search_box.click
			#search_box.send_keys SEARCH_QUERY
			#search_box.send_keys :return
			wait_for_loading
			@logger.info "Searched a plugin"
			@driver.find_element(xpath: SEARCH_RESULT_MANAGE_PLUGIN).click
			@driver.find_element(class: UPDATE_ICON).click
			@logger.info "Clicked on update icon"
			@driver.find_element(xpath: NEXT_STEP).click
			@driver.find_element(xpath: UPDATE_BUTTON).click
			@logger.info "Update started"
			wait_for_loading
			@wait.until{@driver.find_element(xpath: SUCCESS_MSG)}
			@logger.info "Successfully Updated plugin"
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
			wait_for_loading
			@logger.info "Searched a plugin"
			@driver.find_element(xpath: SEARCH_RESULT_MANAGE_PLUGIN).click
			@driver.find_element(class: DELETE_ICON).click
			@logger.info "Clicked on delete icon"
			@driver.find_element(xpath: NEXT_STEP).click
			@driver.find_element(xpath: DELETE_BUTTON).click
			@logger.info "Deletion started"
			wait_for_loading
			@wait.until{@driver.find_element(xpath: SUCCESS_MSG)}
			@logger.info "Successfully deleted plugin"
		rescue => e
			handle_error(e)
		end
	end

	def navigate_to_sites_list
		@driver.get HOME_URL_SITES
		@wait.until{@driver.find_element(:class, LIST_OF_SITES)}	
	end
end
