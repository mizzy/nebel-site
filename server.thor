require 'bundler/setup'
require 'guard'

class Server < Thor
  desc "start", "start server"
  def start
    pid = Process.spawn("nebel -s")
    trap("INT") {
      Process.kill(9, pid) rescue Errno::ESRCH
      exit 0
    }
    sleep 1
    `open http://localhost:5000`
    Guard.setup
    Guard.start
  end
end
