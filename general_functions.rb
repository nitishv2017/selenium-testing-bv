require 'logger'
require 'selenium-webdriver'
def handle_error e
	@driver.save_screenshot 'error.png'
	@logger.error e
end

def wait_for_loading
	@wait.until{!@driver.find_elements(class: "bv-loader-text-container").any?}
end

def get_logger
	logfile = "./logs/log-#{Time.now.strftime("%Y%m%d-%H%M%S")}.log"
	@logger = Logger.new(logfile)
	@logger.formatter = proc do |severity, datetime, progname, msg|
		puts "#{datetime}, #{progname}: #{msg}"
		"#{datetime}, #{progname}: #{msg}\n"
	end
	@logger
end
