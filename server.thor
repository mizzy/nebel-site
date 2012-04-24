require 'guard'
class Server < Thor
  desc "start", "start server"
  def start
    pid = Process.spawn("stellar-server")
    trap("INT") {
      Process.kill(9, pid) rescue Errno::ESRCH
      exit 0
    }
    `open http://localhost:5000`
    Guard.setup
    Guard.start
  end
end
