require 'logger'
require 'selenium-webdriver'
require 'colored'
def handle_error e
	@driver.save_screenshot 'error.png'
	function_name = caller_locations(1,1)[0].base_label
	path = caller_locations(1,1)[0].path
	files = Dir["./logs/*"]
	latest_file = File.basename(files.max_by { |f| File.mtime(f) })
	File.open("./reports/Report_#{latest_file}", "a") do |file|
		file.write("#{Time.now.strftime("%Y-%m-%d %H:%M:%S")} :#{function_name} #{"FAILED".red}\n")
	end
	@logger.error "#{function_name} failed: #{e}"
end

def add_success_report
	function_name = caller_locations(1,1)[0].base_label
	path = caller_locations(1,1)[0].path
	files = Dir["./logs/*"]
	latest_file = File.basename(files.max_by { |f| File.mtime(f) })
	File.open("./reports/Report_#{latest_file}", "a") do |file|
		file.write("#{Time.now.strftime("%Y-%m-%d %H:%M:%S")} :#{function_name} #{"PASSED".green}\n")
	end
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
