require 'selenium-webdriver'
require 'logger'
require 'json'
require_relative './general_functions.rb'
require_relative './login.rb'
require_relative './add_site.rb'
require_relative './manage_plugin.rb'

class Main
	USERNAME_BV = 'nitishvaishnav2017@gmail.com'
	PASSWORD_BV = '12345678'
	HOME_URL_SITES = 'https://app.blogvault.net/app/sites'
	LIST_OF_SITES = 'item-title'

	def initialize
		options = Selenium::WebDriver::Chrome::Options.new
		options.add_argument('--headless')
		options.add_argument('--no-sandbox')
		options.add_argument('--disable-dev-shm-usage')
		options.add_argument("--window-size=1280,1024")
		@driver = Selenium::WebDriver.for :chrome, options: options
		@logger = get_logger
		@wait = Selenium::WebDriver::Wait.new(timeout: 30)
	end

	def run_script	
		begin
			login_bv = Login.new(@driver, @logger)
			login_bv.login(USERNAME_BV, PASSWORD_BV)
			while true
				puts "Select one function:"
				puts "1. Automate [AddSite -> AddPLugin -> UpdatePlugin -> DeletePlugin -> RollbackSiteAdded]"
				puts "2. Add site"
				puts "3. Manage Plugins"
				puts "4. Delete recent site that was added"
				puts "5. Exit"
				option = gets.chomp
				case option
				when "1"
					add_site = AddSite.new(@driver, @logger)
					add_site.run_script
					navigate_to_sites_list
					manage_plugin = ManagePlugin.new(@driver, @logger)
					manage_plugin.run_script(true)
					add_site.delete_site
				when "2"
					add_site = AddSite.new(@driver, @logger)
					add_site.run_script
				when "3"
					manage_plugin = ManagePlugin.new(@driver, @logger)
					manage_plugin.run_script
				when "4"
					add_site = AddSite.new(@driver, @logger)
					add_site.delete_site
				when "5"
					return
				else 
					puts "Invalid option"
				end
				navigate_to_sites_list
			end
		rescue => e
			handle_error(e)
		end
	end

	def navigate_to_sites_list
		@driver.get HOME_URL_SITES
		@wait.until{@driver.find_element(:class, LIST_OF_SITES)}	
	end
end

main = Main.new
main.run_script
